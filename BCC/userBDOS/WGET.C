// Wget
// Tool to do a HTTP GET request

#define word char

#include "LIB/MATH.C"
#include "LIB/STDLIB.C"
#include "LIB/SYS.C"
#include "LIB/FS.C"
#include "LIB/WIZ5500.C"

#define HEAP_LOCATION 0x500000

// Which socket to use
#define SOCKET_CLIENT 0

#define CONNECT_MAX_RETRIES 1000


// Initializes w5500 in client TCP mode, with a static ip (last digit as arg)
// Port is also given as arg
void initClient(word ip, word port)
{
  word ip_addr[4] = {192, 168, 0, 213};

  word gateway_addr[4] = {192, 168, 0, 1};

  word mac_addr[6] = {0xDE, 0xAD, 0xBE, 0xEF, 0x24, 0x64};

  word sub_mask[4] = {255, 255, 255, 0};

  wiz_Init(ip_addr, gateway_addr, mac_addr, sub_mask);

  // Open socket in TCP Client mode at port
  wizInitSocketTCPClient(SOCKET_CLIENT, port);
}


// Connect to target at given ip and port
// Return 1 on success, 0 on failure
word connectToTarget(char* ipTarget, word portTarget)
{
  wizWrite(WIZNET_SnDIPR,  WIZNET_WRITE_SnR + (SOCKET_CLIENT << 5), ipTarget, 4);
  wizSetSockReg16(SOCKET_CLIENT, WIZNET_SnDPORT, portTarget);
  wizCmd(SOCKET_CLIENT, WIZNET_CR_CONNECT);

  word sxStatus = wizGetSockReg8(SOCKET_CLIENT, WIZNET_SnSR);

  word retries = 0;

  while (sxStatus != WIZNET_SOCK_ESTABLISHED && retries < CONNECT_MAX_RETRIES)
  {
    //BDOS_PrintHexConsole(sxStatus);
    if (sxStatus == WIZNET_SOCK_CLOSED)
    {
      return 0;
    }

    sxStatus = wizGetSockReg8(SOCKET_CLIENT, WIZNET_SnSR);

    if (sxStatus != WIZNET_SOCK_ESTABLISHED)
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
  word rLen = 0;
  word catLen = 0;

  catLen = strcpy(rTxt + rLen, "GET /");
  rLen += catLen;

  char targetURL[64];
  BDOS_GetArgN(2, targetURL);
  catLen = strcpy(rTxt + rLen, targetURL);
  rLen += catLen;

  catLen = strcpy(rTxt + rLen, " HTTP/1.1\r\nUser-Agent: WGET(FPGC)\r\nAccept: */*\r\nHost: ");
  rLen += catLen;

  char ipstr[24];
  BDOS_GetArgN(1, ipstr);
  catLen = strcpy(rTxt + rLen, ipstr);
  rLen += catLen;

  catLen = strcpy(rTxt + rLen, "\r\n\r\n");
  rLen += catLen;

  wizWriteDataFromMemory(SOCKET_CLIENT, rTxt, rLen);
  BDOS_PrintConsole("Request sent\n");
}


// Init output file for download
// Returns 1 on success, else 0
word initOutputFile(char* path, char* fname, char* rbuf, word rsize)
{
  // sanity check current path
  if (FS_sendFullPath(path) == FS_ANSW_USB_INT_SUCCESS)
  {
    word retval = FS_open();
    // check that we can open the path
    if (retval == FS_ANSW_USB_INT_SUCCESS || retval == FS_ANSW_ERR_OPEN_DIR)
    {
      // check length of filename
      if (strlen(fname) <= 12)
      {
        // uppercase filename
        strToUpper(fname);
        // send filename
        FS_sendSinglePath(fname);

        // create the file
        if (FS_createFile() == FS_ANSW_USB_INT_SUCCESS)
        {
          // open the path again
          FS_sendFullPath(path);
          FS_open();

          // send filename again
          FS_sendSinglePath(fname);
          // open the newly created file
          if (FS_open() == FS_ANSW_USB_INT_SUCCESS)
          {
            // set cursor to start
            if (FS_setCursor(0) == FS_ANSW_USB_INT_SUCCESS)
            {
              if (FS_writeFile(rbuf, rsize) != FS_ANSW_USB_INT_SUCCESS)
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
word getDataStart(char* rbuf, word rsize)
{
  word dataStart = 0;

  word i = 0;
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
word getStatusCode(char* rbuf, word rsize)
{
  word i = 0;
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
      return strToInt(statusStr);
    }

    i++;
  }

  return 0;
}


// Parses HTTP header, returns content length header field
word getContentLength(char* rbuf, word rsize)
{
  word i = 0;
  word strBufIndex = 0;
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
      return strToInt(contentLengthStrBuf);
    }
    i++;
  }
  return 0;
}


word getPercentageDone(word remaining, word full)
{
  word x = remaining * 100;
  return 100 - MATH_divU(x, full);
}

// Receive response while connected
// Write to file and terminal
void receiveResponse(char* path, char* fname)
{

  word firstResponse = 1;
  word contentLengthOrig[1]; // its an array now, because of a compiler bug in DeprCcompiler (ShivyC)
  contentLengthOrig[0] = 0;
  word contentLength = 0;

  word currentProgress = 0;

  BDOS_PrintConsole("Downloading response (any key to stop)\n");
  while (wizGetSockReg8(SOCKET_CLIENT, WIZNET_SnSR) == WIZNET_SOCK_ESTABLISHED)
  {
    word rsize = wizGetSockReg16(SOCKET_CLIENT, WIZNET_SnRX_RSR);
    if (rsize != 0)
    {
      char* rbuf = (char*) HEAP_LOCATION; // we use heap for the receive data buffer
      wizReadRecvData(SOCKET_CLIENT, rbuf, rsize);
      if (firstResponse)
      {
        word dataStart = getDataStart(rbuf, rsize);
        contentLength = getContentLength(rbuf, rsize);
        contentLengthOrig[0] = contentLength;

        BDOS_PrintConsole("Status code: ");
        BDOS_PrintDecConsole(getStatusCode(rbuf, rsize));
        BDOS_PrintConsole("\n");

        if (!initOutputFile(path, fname, &rbuf[dataStart], rsize - dataStart))
          return;

        contentLength -= (rsize - dataStart);

        firstResponse = 0;

        // all data downloaded
        if (contentLength == 0)
          break;
      }
      else
      {
        if (FS_writeFile(rbuf, rsize) != FS_ANSW_USB_INT_SUCCESS)
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
  wizCmd(SOCKET_CLIENT, WIZNET_CR_DISCON);
  BDOS_PrintConsole("Output written to ");
  BDOS_PrintConsole(path);
  BDOS_PrintConsole("/");
  BDOS_PrintConsole(fname);
  BDOS_PrintConsole("\n");
  FS_close();
}


// convert string to IP by looking at the dots
void strToIP(char* str, char* IP)
{
  word i = 0;
  word dotsFound = 0;
  word digitCounter = 0;
  char tmp[16];
  while (str[i] != 0)
  {
    if (str[i] == '.')
    {
      tmp[digitCounter] = 0;
      IP[dotsFound] = strToInt(tmp);
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
  IP[dotsFound] = strToInt(tmp);
}


int main()
{
  // Init
  BDOS_PrintConsole("WGET (IP path output [port])\n");
  initClient(213, 1024);

  // TODO: DNS lookup

  // IP
  char ipstr[24];
  BDOS_GetArgN(1, ipstr);
  char ipTarget[4];
  strToIP(ipstr, ipTarget);

  // Port
  word portTarget = 0;
  char portstr[16];
  BDOS_GetArgN(4, portstr);
  if (portstr[0] != 0)
    portTarget = strToInt(portstr);

  if (portTarget == 0)
      portTarget = 80;


  // Connect to target
  if (!connectToTarget(ipTarget, portTarget))
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
  BDOS_GetArgN(3, fname);
  if (fname[0] == 0)
  {
    strcpy(fname, "OUT.TXT");
  }
  receiveResponse(path, fname);


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