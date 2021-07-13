#include "lib/stdlib.h"
#include "lib/sys.h"
#include "lib/fs.h"
#include "lib/wiz5500.h"

#define WIZNET_DEBUG 0

#define HEAP_LOCATION 0x500000

#define FILE_BUFFER_SIZE 1024 // buffer size for reading files from USB storage
char fileBuffer[FILE_BUFFER_SIZE] = 0;


//-------------------
//W5500 CONNECTION HANDLING FUNCTIONS
//-------------------


int wizWriteResponseFromMemory(int s, char* buf, int buflen)
{
  // Make sure there is something to send
  if (buflen <= 0)
  {
    return 0;
  }

  int bytesSent = 0;

  // loop until all bytes are sent
  while (bytesSent != buflen)
  {

    if (wizGetSockReg8(s, SnSR) == SOCK_CLOSED)
    {
      //uprintln("connection closed");
      return 0;
    }

    int partToSend = buflen - bytesSent;
    if (partToSend > WIZ_MAX_TBUF)
      partToSend = WIZ_MAX_TBUF;

    // Make sure there is room in the transmit buffer for what we want to send
    int txfree = wizGetSockReg16(s, SnTX_FSR); // Size of the available buffer area

    int timeout = 0;
    while (txfree < partToSend) 
    {
      timeout++; // Increase timeout counter
      delay(1); // Wait a bit
      txfree = wizGetSockReg16(s, SnTX_FSR); // Size of the available buffer area
      
      // After a second
      if (timeout > 1000) 
      {
        wizCmd(s, CR_DISCON); // Disconnect the connection
        //uprintln("timeout");
        return 0;
      }
    }

     // Space is available so we will send the buffer
    int txwr = wizGetSockReg16(s, SnTX_WR);  // Read the Tx Write Pointer

    // Write the outgoing data to the transmit buffer
    wizWrite(txwr, WIZNET_WRITE_SnTX + (s << 5), buf + bytesSent, partToSend);

    // update the buffer pointer
    int newSize = txwr + partToSend;
    wizSetSockReg16(s, SnTX_WR, newSize);

    // Now Send the SEND command which tells the wiznet the pointer is updated
    wizCmd(s, CR_SEND);

    // Update the amount of bytes sent
    bytesSent += partToSend;
  }


  return 1;
}


// Writes response from (successfully) opened USB file
int wizWriteResponseFromUSB(int s, int fileSize)
{
  // file size is already checked on being > 0

  if (FS_setCursor(0) != ANSW_USB_INT_SUCCESS)
      uprintln("cursor error");

  int bytesSent = 0;
  char buffer[10];

  // loop until all bytes are sent
  while (bytesSent != fileSize)
  {
    int partToSend = fileSize - bytesSent;
    // send in parts of FILE_BUFFER_SIZE
    if (partToSend > FILE_BUFFER_SIZE)
      partToSend = FILE_BUFFER_SIZE;

    // read from usb to buffer
    if (FS_readFile(fileBuffer, partToSend, 0) != ANSW_USB_INT_SUCCESS)
      uprintln("read error");
    if (!wizWriteResponseFromMemory(s, fileBuffer, partToSend))
    {
      //uprintln("wizTranser error");
      return 0;
    }

    // Update the amount of bytes sent
    bytesSent += partToSend;

    BDOS_PrintConsole(".");
  }

  FS_close();
  return 1;
}


void wizSend404Response(int s)
{
  char* retTxt = "<!DOCTYPE html><html><head><title>ERROR404</title></head><body>ERROR 404: This is not the page you are looking for</body></html>";
  wizWriteResponseFromMemory(s, retTxt, 128);
}


// Gets requested file path from request header
// Returns size of requested path (should be 1 or higher because '/')
// Fills pbuf with path
// Assumes a request header of appropiate size
int wizGetFilePath(char* rbuf, char* pbuf)
{
  int foundPath = 0;
  int foundSpace = 0;
  int cursor = 0;
  int pathIndex = 0;

  while (foundPath == 0)
  {
    // until we found the first space after GET (or POST)
    if (foundSpace == 0 && rbuf[cursor] == 32)
    {
      foundSpace = 1;
    }
    else 
    {
        if (foundSpace == 1)
        {
          // until we found the second space (after the file path)
          if (rbuf[cursor] == 32)
          {
            // exit the loop, we are done
            foundPath = 1;
          }
          else
          {
            // copy the character
            pbuf[pathIndex] = rbuf[cursor];
            //uprintc(rbuf[cursor]);
            pathIndex++;
          }
        }
    }
    // go to next character
    cursor++;
  }

  pbuf[pathIndex] = 0; // terminate string

  // return the path length
  return (pathIndex + 1);
}


void wizListDir(int s, char* path)
{
  char *b = (char *) HEAP_LOCATION;

  if (FS_listDir(path, b) == ANSW_USB_INT_SUCCESS)
  {
    int listSize = 0;
    while (b[listSize] != 0)
      listSize++;

    if (listSize == 0)
      listSize = 1;

    wizWriteResponseFromMemory(s, b, listSize-1);
  }
}


void wizServeFile(int s, char* path)
{
  BDOS_PrintConsole("Request: ");
  BDOS_PrintConsole(&path[0]);
  BDOS_PrintConsole("\n");

  // Remove trailing slashes
  // remove (single) trailing slash if exists

  int i = 0;
  while (path[i] != 0)
    i++;

  if (i > 1) // ignore the root path
  {
    if (path[i-1] == '/')
      path[i-1] = 0;
  }

  // Redirect "/" to "/INDEX.HTM"
  if (path[0] == 47 && path[1] == 0)
  {
    // send an actual redirect to the browser
    char* response = "HTTP/1.1 301 Moved Permanently\nLocation: /INDEX.HTM\n";
    BDOS_PrintConsole("Response: redirect to /INDEX.HTM\n");
    wizWriteResponseFromMemory(s, response, 52);
    // Disconnect after sending the redirect
    wizCmd(s, CR_DISCON);
    return;
  }

  int error = 0;
  int listDir = 0;

  if (FS_sendFullPath(&path[0]) != ANSW_USB_INT_SUCCESS) // automatically upercases the path
    error = 404;

  if (!error)
  {
    int openStatus = FS_open();
    if (openStatus == ANSW_ERR_OPEN_DIR)
      listDir = 1;
    else if (openStatus != ANSW_USB_INT_SUCCESS)
      error = 404;
  }

  int fileSize = 0;
  if (!error && !listDir)
    fileSize = FS_getFileSize();

  if (!error && !listDir)
  {
    if (fileSize == 0)
      error = 404; // handle empty files as if they do not exist
  }

  // send error response on error
  if (error)
  {
    BDOS_PrintConsole("Response: 404 ");
    // currently puts all errors under 404
    // write header
    char* header = "HTTP/1.1 404 Not Found\nServer: FPGC4/1.0\nContent-Type: text/html\n\n";
    wizWriteResponseFromMemory(s, header, 66);

    FS_sendFullPath("/404.HTM");
    if (FS_open() != ANSW_USB_INT_SUCCESS)
    {
      // if the custom 404 does not exist, return own error code
      BDOS_PrintConsole("no 404.HTM\n");
      wizSend404Response(s);
    }
    else
    {
      // send custom 404
      fileSize = FS_getFileSize();
      // write the response from USB
      BDOS_PrintConsole("404.HTM ");
      wizWriteResponseFromUSB(s, fileSize);
      BDOS_PrintConsole("Done\n");
    }
  }
  else
  {
    BDOS_PrintConsole("Response: 200 OK ");
    // write header
    // currently omitting content type
    char* header = "HTTP/1.1 200 OK\nServer: FPGC4/1.0\n\n";
    wizWriteResponseFromMemory(s, header, 35);

    if (listDir)
    {
      wizListDir(s, path);
      BDOS_PrintConsole("\n");
    }
    else
    {
      // write the response from USB
      wizWriteResponseFromUSB(s, fileSize);
      BDOS_PrintConsole("Done\n");
    }
  }

  // Disconnect after sending a response
  wizCmd(s, CR_DISCON);
} 





// Handle session for socket s
void wizHandleSession(int s)
{
  // Size of received data
  int rsize;
  rsize = wizGetSockReg16(s, SnRX_RSR);

  if (rsize == 0)
  {
    wizCmd(s, CR_DISCON);
    return;
  }
  
  char rbuf[WIZ_MAX_RBUF];
  wizReadRecvData(s, &rbuf[0], rsize);

  //  read rbuf for requested page
  //  parse from {GET /INFO.HTM HTTP/1.1}
  char pbuf[128]; // buffer for path name
  int pbufSize = wizGetFilePath(&rbuf[1], &pbuf[0]);

  wizServeFile(s, &pbuf[0]);

  // Free received data when not read
  // Not used, since we currently read the request
  //wizFlush(s, rsize);

}



int main() 
{

    BDOS_PrintConsole("Starting Web Server\n");

    // Assumes that the USB drive is already properly initialized by BDOS

    char ip_addr[4];
    ip_addr[0] = 192;
    ip_addr[1] = 168;
    ip_addr[2] = 0;
    ip_addr[3] = 213;

    char gateway_addr[4];
    gateway_addr[0] = 192;
    gateway_addr[1] = 168;
    gateway_addr[2] = 0;
    gateway_addr[3] = 1;

    char mac_addr[6];
    mac_addr[0] = 0xDE;
    mac_addr[1] = 0xAD;
    mac_addr[2] = 0xBE;
    mac_addr[3] = 0xEF;
    mac_addr[4] = 0x24;
    mac_addr[5] = 0x64;

    char sub_mask[4];
    sub_mask[0] = 255;
    sub_mask[1] = 255;
    sub_mask[2] = 255;
    sub_mask[3] = 0;

    wiz_Init(&ip_addr[0], &gateway_addr[0], &mac_addr[0], &sub_mask[0]);

    // Open all sockets in TCP Server mode at port 80
    wizInitSocketTCP(0, 80);
    wizInitSocketTCP(1, 80);
    wizInitSocketTCP(2, 80);
    wizInitSocketTCP(3, 80);
    wizInitSocketTCP(4, 80);
    wizInitSocketTCP(5, 80);
    wizInitSocketTCP(6, 80);
    wizInitSocketTCP(7, 80);

    // Socket s status
    int sxStatus;

    while(1)
    {
      if (HID_FifoAvailable())
      {
        HID_FifoRead(); // remove it from the buffer
        return 'q';
      }
      // handle all sockets
      for (int s = 0; s < 8; s++)
      {
        // Get status for socket s
        sxStatus = wizGetSockReg8(s, SnSR);

        if (sxStatus == SOCK_CLOSED)
        { 
          // Open the socket when closed
          if (WIZNET_DEBUG)
            uprintln("Socket closed");
          // Set socket s in TCP Server mode at port 80
          wizInitSocketTCP(s, 80);
        }
        else if (sxStatus == SOCK_ESTABLISHED)
        {
          // Handle session when a connection is established
          // Also reinitialize socket
          if (WIZNET_DEBUG)
            uprintln("Got connection");
          wizHandleSession(s);
          // Set socket s in TCP Server mode at port 80
          wizInitSocketTCP(s, 80);
        }
        else if (sxStatus == SOCK_LISTEN || sxStatus == SOCK_SYNSENT || sxStatus == SOCK_SYNRECV)
        {
          // Do nothing in these cases
        }
        else
        {
          // In other cases, reset the socket
          // Set socket s in TCP Server mode at port 80
          if (WIZNET_DEBUG)
            uprintln("Resetting socket");
          wizInitSocketTCP(s, 80);
        }
      }
      // Delay a few milliseconds
      // Should (could) eventually be replaced by an interrupt checker
      delay(10);
    }

    return 'q';
}

// timer1 interrupt handler
void int1()
{
   timer1Value = 1; // notify ending of timer1
}

void int2()
{
}

void int3()
{
}

void int4()
{
}