// Webserver
// uses multiple sockets, except for socket 7 which is reserved by netHID

#define word char

#include "LIB/MATH.C"
#include "LIB/STDLIB.C"
#include "LIB/SYS.C"
#include "LIB/FS.C"
#include "LIB/WIZ5500.C"

#define TMPMEM_LOCATION 0x440000
#define FILE_BUFFER_LOCATION 0x430000
#define FILE_BUFFER_SIZE 8192 // buffer size for reading files from USB storage

char* fileBuffer = (char *) FILE_BUFFER_LOCATION; //fileBuffer[FILE_BUFFER_SIZE];
char WIZrbuf[WIZNET_MAX_RBUF];

//-------------------
//LIST DIR CUSTOM FUNCTIONS
//-------------------

// Parses and writes name.extension and filesize on one line
void wiz_parseFATdata(word datalen, char* fatBuffer, char* b, word* bufLen)
{
  if (datalen != 32)
  {
    BDOS_PrintConsole("Unexpected FAT table length\n");
    return;
  }

  // start HTML link tag
  word catLen = strcpy(b + *bufLen, "<tr><td style=\"padding:0 15px 0 15px;\"><a href=\"");
  (*bufLen) += catLen;

  // parse filename
  word printLen = FS_parseFATstring(fatBuffer, 8, b, bufLen);

  // add '.' and parse extension
  if (fatBuffer[8] != ' ' || fatBuffer[9] != ' ' || fatBuffer[10] != ' ')
  {
    b[*bufLen] = '.';
    (*bufLen)++;
    printLen += FS_parseFATstring(fatBuffer+8, 3, b, bufLen) + 1;
  }

  // filesize
  word fileSize = 0;
  fileSize += fatBuffer[28];
  fileSize += (fatBuffer[29] << 8);
  fileSize += (fatBuffer[30] << 16);
  fileSize += (fatBuffer[31] << 24);

  // add slash if folder (filesize 0)
  if (fileSize == 0)
  {
    catLen = strcpy(b + *bufLen, "/");
    (*bufLen) += catLen;
  }

  // end the starting HTML link tag
  catLen = strcpy(b + *bufLen, "\">");
  (*bufLen) += catLen;

  // do again for the link text
  // parse filename
  printLen = FS_parseFATstring(fatBuffer, 8, b, bufLen);

  // add '.' and parse extension
  if (fatBuffer[8] != ' ' || fatBuffer[9] != ' ' || fatBuffer[10] != ' ')
  {
    b[*bufLen] = '.';
    (*bufLen)++;
    printLen += FS_parseFATstring(fatBuffer+8, 3, b, bufLen) + 1;
  }

  // add slash if folder (filesize 0)
  if (fileSize == 0)
  {
    catLen = strcpy(b + *bufLen, "/");
    (*bufLen) += catLen;
  }

  // end hyperlink
  catLen = strcpy(b + *bufLen, "</a></td><td style=\"padding:0 15px 0 15px;\">");
  (*bufLen) += catLen;

  

  // filesize to integer string
  char buffer[10];
  itoa(fileSize, &buffer[0]);

  // write to buffer
  word i = 0;
  while (buffer[i] != 0)
  {
    b[*bufLen] = buffer[i];
    (*bufLen)++;
    i++;
  }

  catLen = strcpy(b + *bufLen, "</td></tr>\n");
  (*bufLen) += catLen;
}


// Reads FAT data for single entry
// FAT data is parsed by FS_parseFatData()
void wiz_readFATdata(char* b, word* bufLen)
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_RD_USB_DATA0);
  word datalen = FS_spiTransfer(0x0);
  char fatbuf[32];
  word i;
  for (i = 0; i < datalen; i++)
  {
    fatbuf[i] = FS_spiTransfer(0x00);
  }
  wiz_parseFATdata(datalen, fatbuf, b, bufLen);
  FS_spiEndTransfer();
}

// Lists directory of full path f
// f needs to start with / and not end with /
// Returns ANSW_USB_INT_SUCCESS if successful
// Writes parsed result to address b
// Result is terminated with a \0
word wiz_listDir(char* f, char* b)
{
  word bufLen = 0;
  word* pBuflen = &bufLen;

  word retval = FS_sendFullPath(f);
  // Return on failure
  if (retval != FS_ANSW_USB_INT_SUCCESS)
    return retval;

  retval = FS_open();
  // Return on failure
  if (retval != FS_ANSW_USB_INT_SUCCESS && retval != FS_ANSW_ERR_OPEN_DIR)
    return retval;

  FS_sendSinglePath("*");

  retval = FS_open();
  // Return on failure
  if (retval != FS_ANSW_USB_INT_DISK_READ)
    return retval;

  // Init length of output buffer
  *pBuflen = 0;

  while (retval == FS_ANSW_USB_INT_DISK_READ)
  {
    wiz_readFATdata(b, pBuflen);
    FS_spiBeginTransfer();
    FS_spiTransfer(FS_CMD_FILE_ENUM_GO);
    FS_spiEndTransfer();
    retval = FS_WaitGetStatus();
  }

  // Terminate buffer
  b[*pBuflen] = 0;
  (*pBuflen)++;

  return FS_ANSW_USB_INT_SUCCESS;
}


word PercentageDone(word remaining, word full)
{
  word x = remaining * 100;
  return 100 - MATH_divU(x, full);
}

//-------------------
//W5500 CONNECTION HANDLING FUNCTIONS
//-------------------

// Writes response from (successfully) opened USB file
word wizWriteResponseFromUSB(word s, word fileSize)
{
  // file size is already checked on being > 0

  if (FS_setCursor(0) != FS_ANSW_USB_INT_SUCCESS)
    BDOS_PrintConsole("cursor error\n");

  word bytesSent = 0;
  char buffer[10];

  char dbuf[10]; // percentage done for progress indication
  dbuf[0] = 0; // terminate

  // loop until all bytes are sent
  while (bytesSent != fileSize)
  {
    word partToSend = fileSize - bytesSent;
    // send in parts of FILE_BUFFER_SIZE
    if (partToSend > FILE_BUFFER_SIZE)
      partToSend = FILE_BUFFER_SIZE;

    // read from usb to buffer
    if (FS_readFile(fileBuffer, partToSend, 0) != FS_ANSW_USB_INT_SUCCESS)
      BDOS_PrintConsole("read error\n");
    if (!wizWriteDataFromMemory(s, fileBuffer, partToSend))
    {
      //uprintln("wizTranser error");
      return 0;
    }

    // Update the amount of bytes sent
    bytesSent += partToSend;

    //BDOS_PrintConsole(".");

    // indicate progress
    // remove previous percentage
    word i = strlen(dbuf);
    while (i > 0)
    {
      BDOS_PrintcConsole(0x8); // backspace
      i--;
    }
    if (strlen(dbuf) != 0)
    {
      BDOS_PrintcConsole(0x8); // backspace
    }

    itoa(PercentageDone(fileSize - bytesSent, fileSize), dbuf);
    BDOS_PrintConsole(dbuf);
    BDOS_PrintcConsole('%');
  }

  // remove previous percentage
  word i = strlen(dbuf);
  while (i > 0)
  {
    BDOS_PrintcConsole(0x8); // backspace
    i--;
  }
  if (strlen(dbuf) != 0)
  {
    BDOS_PrintcConsole(0x8); // backspace
  }

  FS_close();
  return 1;
}


void wizSend404Response(word s)
{
  char* retTxt = "<!DOCTYPE html><html><head><title>ERROR404</title></head><body>ERROR 404: This is not the page you are looking for</body></html>";
  wizWriteDataFromMemory(s, retTxt, strlen(retTxt));
}


// Gets requested file path from request header
// Returns size of requested path (should be 1 or higher because '/')
// Fills pbuf with path
// Assumes a request header of appropiate size
word wizGetFilePath(char* rbuf, char* pbuf)
{
  word foundPath = 0;
  word foundSpace = 0;
  word cursor = 0;
  word pathIndex = 0;

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


void wizDirectoryListing(word s, char* path)
{

  // write start of html page
  wizWriteDataFromMemory(s, "<!DOCTYPE html><html><body><h2>", 31);

  word pathLen = 0;
  while (path[pathLen] != 0)
    pathLen++;

  wizWriteDataFromMemory(s, path, pathLen-1);

  wizWriteDataFromMemory(s, "</h2><table><tr><th>Name</th><th>Size</th></tr>", 47);


  char *b = (char *) TMPMEM_LOCATION;
  if (wiz_listDir(path, b) == FS_ANSW_USB_INT_SUCCESS)
  {
    word listSize = 0;
    while (b[listSize] != 0)
      listSize++;

    if (listSize == 0)
      listSize = 1;

    wizWriteDataFromMemory(s, b, listSize-1);
  }

  // write end of html page
  wizWriteDataFromMemory(s, "</table></body></html>", 22);
}


void wizServeFile(word s, char* path)
{
  BDOS_PrintConsole(path);
  BDOS_PrintConsole(": ");

  // Redirect "/" to "/INDEX.HTM"
  if (path[0] == 47 && path[1] == 0)
  {
    // send an actual redirect to the browser
    char* response = "HTTP/1.1 301 Moved Permanently\nLocation: /INDEX.HTM\n";
    BDOS_PrintConsole("Redirect to /INDEX.HTM\n");
    wizWriteDataFromMemory(s, response, strlen(response));
    // Disconnect after sending the redirect
    wizCmd(s, WIZNET_CR_DISCON);
    return;
  }

  word error = 0;
  word listDir = 0;

  if (FS_sendFullPath(&path[0]) != FS_ANSW_USB_INT_SUCCESS) // automatically upercases the path
    error = 404;

  if (!error)
  {
    word openStatus = FS_open();
    if (openStatus == FS_ANSW_ERR_OPEN_DIR)
      listDir = 1;
    else if (openStatus != FS_ANSW_USB_INT_SUCCESS)
      error = 404;
  }

  word fileSize = 0;
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
    BDOS_PrintConsole("404 ");
    // currently puts all errors under 404
    // write header
    char* header = "HTTP/1.1 404 Not Found\nServer: FPGC/1.0\nContent-Type: text/html\n\n";
    wizWriteDataFromMemory(s, header, strlen(header));

    FS_sendFullPath("/404.HTM");
    if (FS_open() != FS_ANSW_USB_INT_SUCCESS)
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
      BDOS_PrintConsole("/404.HTM ");
      wizWriteResponseFromUSB(s, fileSize);
      BDOS_PrintConsole("Done\n");
    }
  }
  else
  {
    if (listDir)
    {
      // check if last character is a /
      // if not, redirect to the path with / after it
      word i = 0;
      while (path[i] != 0)
        i++;

      if (path[i-1] != '/')
      {
        //BDOS_PrintConsole(path);
        //BDOS_PrintConsole("\n");
        path[i] = '/';
        path[i+1] = 0;
        char* response = "HTTP/1.1 301 Moved Permanently\nLocation: ";
        BDOS_PrintConsole("Redirect to ");
        BDOS_PrintConsole(path);
        BDOS_PrintConsole("\n");
        wizWriteDataFromMemory(s, response, strlen(response));
        wizWriteDataFromMemory(s, path, i+1);
        wizWriteDataFromMemory(s, "\n", 1);
      }
      else
      {
        BDOS_PrintConsole("200 ");
        // write header
        // currently omitting content type
        char* header = "HTTP/1.1 200 OK\nServer: FPGC/1.0\n\n";
        wizWriteDataFromMemory(s, header, strlen(header));
        wizDirectoryListing(s, path);
        BDOS_PrintConsole("Done\n");
      }
    }
    else
    {
      if (fileSize + 1 != 0) // really make sure no directory is being read
      {
        BDOS_PrintConsole("200 ");
        // write header
        // currently omitting content type
        // includes content length so the client knows how large a download is
        char header[128];
        header[0] = 0;
        strcat(header, "HTTP/1.1 200 OK\nServer: FPGC/1.0\nContent-Length: ");
        char fileSizeStr[24];
        itoa(fileSize, fileSizeStr);
        strcat(header, fileSizeStr);
        strcat(header, "\n\n");
        wizWriteDataFromMemory(s, header, strlen(header));
        // write the response from USB
        wizWriteResponseFromUSB(s, fileSize);
        BDOS_PrintConsole("Done\n");
      }
      
    }
  }

  // Disconnect after sending a response
  wizCmd(s, WIZNET_CR_DISCON);
} 





// Handle session for socket s
void wizHandleSession(word s)
{
  // Size of received data
  word rsize;
  rsize = wizGetSockReg16(s, WIZNET_SnRX_RSR);

  if (rsize == 0)
  {
    wizCmd(s, WIZNET_CR_DISCON);
    return;
  }

  char* rbuf = WIZrbuf;
  wizReadRecvData(s, rbuf, rsize);

  //  read rbuf for requested page
  //  parse from {GET /INFO.HTM HTTP/1.1}
  char pbuf[128]; // buffer for path name
  word pbufSize = wizGetFilePath(&rbuf[1], pbuf);

  wizServeFile(s, pbuf);

  // Free received data when not read
  // Not used, since we currently read the request
  //wizFlush(s, rsize);

}



int main() 
{

  BDOS_PrintConsole("Starting Web Server\n");

  // Assumes that the USB drive is already properly initialized by BDOS

  word ip_addr[4] = {192, 168, 0, 213};

  word gateway_addr[4] = {192, 168, 0, 1};

  word mac_addr[6] = {0xDE, 0xAD, 0xBE, 0xEF, 0x24, 0x64};

  word sub_mask[4] = {255, 255, 255, 0};

  wiz_Init(ip_addr, gateway_addr, mac_addr, sub_mask);

  // Open all sockets in TCP Server mode at port 80
  wizInitSocketTCP(0, 80);
  wizInitSocketTCP(1, 80);
  wizInitSocketTCP(2, 80);
  wizInitSocketTCP(3, 80);
  wizInitSocketTCP(4, 80);
  wizInitSocketTCP(5, 80);
  wizInitSocketTCP(6, 80);

  // Socket s status
  word sxStatus;

  while(1)
  {
    if (HID_FifoAvailable())
    {
      HID_FifoRead(); // remove it from the buffer
      return 'q';
    }
    // handle all sockets (socket 7 is reserved by netHID)
    word s;
    for (s = 0; s < 7; s++)
    {
      // Get status for socket s
      sxStatus = wizGetSockReg8(s, WIZNET_SnSR);

      if (sxStatus == WIZNET_SOCK_CLOSED)
      { 
        // Open the socket when closed
        // Set socket s in TCP Server mode at port 80
        wizInitSocketTCP(s, 80);
      }
      else if (sxStatus == WIZNET_SOCK_ESTABLISHED)
      {
        // Handle session when a connection is established
        // Also reinitialize socket
        wizHandleSession(s);
        // Set socket s in TCP Server mode at port 80
        wizInitSocketTCP(s, 80);
      }
      else if (sxStatus == WIZNET_SOCK_LISTEN || sxStatus == WIZNET_SOCK_SYNSENT || sxStatus == WIZNET_SOCK_SYNRECV)
      {
        // Do nothing in these cases
      }
      else
      {
        // In other cases, reset the socket
        // Set socket s in TCP Server mode at port 80
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