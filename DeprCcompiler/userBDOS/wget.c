#include "lib/stdlib.h"
#include "lib/sys.h"
#include "lib/fs.h"
#include "lib/wiz5500.h"

#define HEAP_LOCATION 0x500000

// Which socket to use
#define SOCKET_CLIENT 0

#define CONNECT_MAX_RETRIES 1000


// Initializes w5500 in client TCP mode, with a static ip (last digit as arg)
// Port is also given as arg
void initClient(int ip, int port)
{
  char ip_addr[4];
  ip_addr[0] = 192;
  ip_addr[1] = 168;
  ip_addr[2] = 0;
  ip_addr[3] = ip;

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

  // Open socket in TCP Client mode at port
  wizInitSocketTCPClient(SOCKET_CLIENT, port);
}


// Connect to target at given ip and port
// Return 1 on success, 0 on failure
int connectToTarget(char* ipTarget, int portTarget)
{
  wizWrite(SnDIPR,  WIZNET_WRITE_SnR + (SOCKET_CLIENT << 5), &ipTarget[0], 4);
  wizSetSockReg16(SOCKET_CLIENT, SnDPORT, portTarget);
  wizCmd(SOCKET_CLIENT, CR_CONNECT);

  int sxStatus = wizGetSockReg8(SOCKET_CLIENT, SnSR);

  int retries = 0;

  while (sxStatus != SOCK_ESTABLISHED && retries < CONNECT_MAX_RETRIES)
  {
    //BDOS_PrintHexConsole(sxStatus);
    if (sxStatus == SOCK_CLOSED)
    {
      return 0;
    }

    sxStatus = wizGetSockReg8(SOCKET_CLIENT, SnSR);

    if (sxStatus != SOCK_ESTABLISHED)
    {
      retries++;
      delay(1);
    }
  }

  return 1;
}



// Send request (headers should use \r\n according to the HTTP specs)
void sendRequest()
{
  char* rTxt = (char*) HEAP_LOCATION; // we use heap for the request text
  int rLen = 0;
  int catLen = 0;

  catLen = strcpy(rTxt + rLen, "GET /");
  rLen += catLen;

  char targetURL[64];
  BDOS_GetArgN(2, &targetURL[0]);
  catLen = strcpy(rTxt + rLen, &targetURL[0]);
  rLen += catLen;

  catLen = strcpy(rTxt + rLen, " HTTP/1.1\r\nUser-Agent: WGET(FPGC)\r\nAccept: */*\r\nHost: ");
  rLen += catLen;

  char ipstr[24];
  BDOS_GetArgN(1, &ipstr[0]);
  catLen = strcpy(rTxt + rLen, &ipstr[0]);
  rLen += catLen;

  catLen = strcpy(rTxt + rLen, "\r\n\r\n");
  rLen += catLen;

  wizWriteDataFromMemory(SOCKET_CLIENT, rTxt, rLen);
  BDOS_PrintConsole("Request sent\n");
}


// Init output file for download
// Returns 1 on success, else 0
int initOutputFile(char* path, char* fname, char* rbuf, int rsize)
{
  // sanity check current path
  if (FS_sendFullPath(&path[0]) == ANSW_USB_INT_SUCCESS)
  {
    int retval = FS_open();
    // check that we can open the path
    if (retval == ANSW_USB_INT_SUCCESS || retval == ANSW_ERR_OPEN_DIR)
    {
      // check length of filename
      if (strlen(&fname[0]) <= 12)
      {
        // uppercase filename
        strToUpper(&fname[0]);
        // send filename
        FS_sendSinglePath(&fname[0]);

        // create the file
        if (FS_createFile() == ANSW_USB_INT_SUCCESS)
        {
          // open the path again
          FS_sendFullPath(&path[0]);
          FS_open();

          // send filename again
          FS_sendSinglePath(&fname[0]);
          // open the newly created file
          if (FS_open() == ANSW_USB_INT_SUCCESS)
          {
            // set cursor to start
            if (FS_setCursor(0) == ANSW_USB_INT_SUCCESS)
            {
              if (FS_writeFile(&rbuf[0], rsize) != ANSW_USB_INT_SUCCESS)
              {
                FS_close();
                BDOS_PrintConsole("Error while writing to file\n");
                return 0;
              }
            }
            else
            {
              FS_close();
              BDOS_PrintConsole("Cursor error\n");
              return 0;
            }
          }
        }
        else
        {
          BDOS_PrintConsole("Error while creating output file\n");
          return 0;
        }
      }
      else
      {
        BDOS_PrintConsole("Filename too long\n");
        return 0;
      }
    }
    else
    {
      BDOS_PrintConsole("Could not open path\n");
      return 0;
    }
  }
  else
  {
    BDOS_PrintConsole("Error sending path\n");
    return 0;
  }
  return 1;
}


// Parses HTTP header, returns location of the first data byte
int getDataStart(char* rbuf, int rsize)
{
  int dataStart = 0;

  int i = 0;
  while (i < rsize - 4 && dataStart == 0)
  {
    //BDOS_PrintcConsole(rbuf[i]);
    if (rbuf[i] == '\r' && rbuf[i+1] == '\n' && rbuf[i+2] == '\r' && rbuf[i+3] == '\n')
    {
      dataStart = i+4;
    }
    else if (rbuf[i] == '\n' && rbuf[i+1] == '\n')
    {
      dataStart = i+2;
    }

    i++;
  }

  return dataStart;
}


// Parses HTTP header, returns status code
int getStatusCode(char* rbuf, int rsize)
{
  int i = 0;
  // look for first space, then 3 digits
  while (i < rsize - 4)
  {
    if (rbuf[i] == ' ')
    {
      char statusStr[4];
      statusStr[0] = rbuf[i+1];
      statusStr[1] = rbuf[i+2];
      statusStr[2] = rbuf[i+3];
      statusStr[3] = 0;
      return strToInt(&statusStr[0]);
    }

    i++;
  }

  return 0;
}


// Parses HTTP header, returns content length header field
int getContentLength(char* rbuf, int rsize)
{
  int i = 0;
  int strBufIndex = 0;
  // look for Content-Length field
  while (i < rsize - 4)
  {
    if (memcmp(&rbuf[i], "Content-Length: ", 16))
    {
      i = i + 16;
      // when found, add all following characters to buffer until newline
      char contentLengthStrBuf[32];
      contentLengthStrBuf[0] = 0;

      while (rbuf[i] != '\r' && rbuf[i] != '\n')
      {
        contentLengthStrBuf[strBufIndex] = rbuf[i];
        i++;
        strBufIndex++;
      }

      contentLengthStrBuf[strBufIndex] = 0; // terminate buffer
      // finally, convert to int and return
      return strToInt(&contentLengthStrBuf[0]);
    }
    i++;
  }
  return 0;
}


int getPercentageDone(int remaining, int full)
{
  int x = remaining * 100;
  return 100 - MATH_div(x, full);
}

// Receive response while connected
// Write to file and terminal
void receiveResponse(char* path, char* fname)
{

  int firstResponse = 1;
  int contentLengthOrig[1]; // its an array now, because of a compiler bug
  contentLengthOrig[0] = 0;
  int contentLength = 0;

  int currentProgress = 0;

  BDOS_PrintConsole("Downloading response (any key to stop)\n");
  while (wizGetSockReg8(SOCKET_CLIENT, SnSR) == SOCK_ESTABLISHED)
  {
    int rsize = wizGetSockReg16(SOCKET_CLIENT, SnRX_RSR);
    if (rsize != 0)
    {
      char* rbuf = (char*) HEAP_LOCATION; // we use heap for the receive data buffer
      wizReadRecvData(SOCKET_CLIENT, &rbuf[0], rsize);
      if (firstResponse)
      {
        int dataStart = getDataStart(&rbuf[0], rsize);
        contentLength = getContentLength(&rbuf[0], rsize);
        contentLengthOrig[0] = contentLength;

        BDOS_PrintConsole("Status code: ");
        BDOS_PrintDecConsole(getStatusCode(&rbuf[0], rsize));
        BDOS_PrintConsole("\n");

        if (!initOutputFile(&path[0], &fname[0], &rbuf[dataStart], rsize - dataStart))
          return;

        contentLength -= (rsize - dataStart);

        firstResponse = 0;

        // all data downloaded
        if (contentLength == 0)
          break;
      }
      else
      {
        if (FS_writeFile(&rbuf[0], rsize) != ANSW_USB_INT_SUCCESS)
        {
          FS_close();
          BDOS_PrintConsole("Error while writing to file\n");
          return;
        }
        contentLength -= rsize;

        if (getPercentageDone(contentLength, contentLengthOrig[0]) >= currentProgress)
        {
          BDOS_PrintDecConsole(currentProgress);
          BDOS_PrintConsole("%\n");
          currentProgress += 10;
        }

        // all data downloaded
        if (contentLength == 0)
          break;
      }
    }

    // Allow manual cancel
    if (HID_FifoAvailable())
    {
      HID_FifoRead(); // remove it from the buffer
      break;
    }
  }
  wizCmd(SOCKET_CLIENT, CR_DISCON);
  BDOS_PrintConsole("Output written to ");
  BDOS_PrintConsole(&path[0]);
  BDOS_PrintConsole("/");
  BDOS_PrintConsole(&fname[0]);
  BDOS_PrintConsole("\n");
  FS_close();
}


// convert string to IP by looking at the dots
void strToIP(char* str, char* IP)
{
  int i = 0;
  int dotsFound = 0;
  int digitCounter = 0;
  char tmp[16];
  while (str[i] != 0)
  {
    if (str[i] == '.')
    {
      tmp[digitCounter] = 0;
      IP[dotsFound] = strToInt(&tmp[0]);
      dotsFound += 1;
      digitCounter = 0;
    }
    else
    {
      tmp[digitCounter] = str[i];
      digitCounter++;
    }

    i++;
  }
  tmp[digitCounter] = 0;
  IP[dotsFound] = strToInt(&tmp[0]);
}


int main()
{
  // Init
  BDOS_PrintConsole("WGET (IP path output [port])\n");
  initClient(213, 1024);

  // TODO: DNS lookup

  // IP
  char ipstr[24];
  BDOS_GetArgN(1, &ipstr[0]);
  char ipTarget[4];
  strToIP(&ipstr[0], &ipTarget[0]);

  // Port
  int portTarget = 0;
  char portstr[16];
  BDOS_GetArgN(4, &portstr[0]);
  if (portstr[0] != 0)
    portTarget = strToInt(&portstr[0]);

  if (portTarget == 0)
      portTarget = 80;


  // Connect to target
  if (!connectToTarget(&ipTarget[0], portTarget))
  {
    BDOS_PrintConsole("Could not connect to host\n");
    return 'q';
  }
  else
    BDOS_PrintConsole("Connected to host\n");


  // Send request
  sendRequest();

  // Receive response
  char* path = BDOS_GetPath();

  // If no filename is given, use OUT.TXT as default
  char fname[16];
  BDOS_GetArgN(3, &fname[0]);
  if (fname[0] == 0)
  {
    strcpy(&fname[0], "OUT.TXT");
  }
  receiveResponse(&path[0], &fname[0]);


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