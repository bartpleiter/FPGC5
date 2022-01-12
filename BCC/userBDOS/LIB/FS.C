/*
* Filesystem library
* Handles all filesystem related work for userBDOS programs using CH376.
* Uses only bottom USB port (SPI1 CH376), 
*  allowing top USB top to be used for other USB devices (like HID).
* Uses blocking delays for now.
*/

// uses stdlib.c

#define FS_INTERRUPT_ADDR 0xC0272D

//CH376 Codes
#define FS_CMD_GET_IC_VER       0x01
#define FS_CMD_SET_BAUDRATE     0x02
#define FS_CMD_ENTER_SLEEP      0x03
#define FS_CMD_SET_USB_SPEED    0x04
#define FS_CMD_RESET_ALL      0x05
#define FS_CMD_CHECK_EXIST      0x06
#define FS_CMD_SET_SD0_INT      0x0b
#define FS_CMD_SET_RETRY      0x0b
#define FS_CMD_GET_FILE_SIZE    0x0c
#define FS_CMD_SET_FILE_SIZE    0x0d
#define FS_CMD_SET_USB_ADDRESS    0x13
#define FS_CMD_SET_USB_MODE     0x15
#define FS_MODE_HOST_0        0x05
#define FS_MODE_HOST_1        0x07
#define FS_MODE_HOST_2        0x06
#define FS_CMD_GET_STATUS       0x22
#define FS_CMD_RD_USB_DATA0     0x27
#define FS_CMD_WR_USB_DATA      0x2c
#define FS_CMD_WR_REQ_DATA      0x2d
#define FS_CMD_WR_OFS_DATA      0x2e
#define FS_CMD_SET_FILE_NAME    0x2f
#define FS_CMD_DISK_CONNECT     0x30
#define FS_CMD_DISK_MOUNT       0x31
#define FS_CMD_FILE_OPEN      0x32
#define FS_CMD_FILE_ENUM_GO     0x33
#define FS_CMD_FILE_CREATE      0x34
#define FS_CMD_FILE_ERASE       0x35
#define FS_CMD_FILE_CLOSE       0x36
#define FS_CMD_DIR_INFO_READ    0x37
#define FS_CMD_DIR_INFO_SAVE    0x38
#define FS_CMD_BYTE_LOCATE      0x39
#define FS_CMD_BYTE_READ      0x3a
#define FS_CMD_BYTE_RD_GO       0x3b
#define FS_CMD_BYTE_WRITE       0x3c
#define FS_CMD_BYTE_WR_GO       0x3d
#define FS_CMD_DISK_CAPACITY    0x3e
#define FS_CMD_DISK_QUERY       0x3f
#define FS_CMD_DIR_CREATE       0x40
#define FS_CMD_SET_ADDRESS      0x45
#define FS_CMD_GET_DESCR      0x46
#define FS_CMD_SET_CONFIG       0x49
#define FS_CMD_AUTO_CONFIG      0x4D
#define FS_CMD_ISSUE_TKN_X      0x4E

#define FS_ANSW_RET_SUCCESS     0x51
#define FS_ANSW_USB_INT_SUCCESS   0x14
#define FS_ANSW_USB_INT_CONNECT   0x15
#define FS_ANSW_USB_INT_DISCONNECT  0x16
#define FS_ANSW_USB_INT_USB_READY   0x18
#define FS_ANSW_USB_INT_DISK_READ   0x1d
#define FS_ANSW_USB_INT_DISK_WRITE  0x1e
#define FS_ANSW_RET_ABORT       0x5F
#define FS_ANSW_USB_INT_DISK_ERR  0x1f
#define FS_ANSW_USB_INT_BUF_OVER  0x17
#define FS_ANSW_ERR_OPEN_DIR    0x41
#define FS_ANSW_ERR_MISS_FILE     0x42
#define FS_ANSW_ERR_FOUND_NAME    0x43
#define FS_ANSW_ERR_DISK_DISCON   0x82
#define FS_ANSW_ERR_LARGE_SECTOR  0x84
#define FS_ANSW_ERR_TYPE_ERROR    0x92
#define FS_ANSW_ERR_BPB_ERROR     0xa1
#define FS_ANSW_ERR_DISK_FULL     0xb1
#define FS_ANSW_ERR_FDT_OVER    0xb2
#define FS_ANSW_ERR_FILE_CLOSE    0xb4
#define FS_ERR_LONGFILENAME     0x01
#define FS_ATTR_READ_ONLY       0x01
#define FS_ATTR_HIDDEN        0x02
#define FS_ATTR_SYSTEM        0x04
#define FS_ATTR_VOLUME_ID       0x08
#define FS_ATTR_DIRECTORY       0x10 
#define FS_ATTR_ARCHIVE       0x20

// Sets SPI1_CS low
void FS_spiBeginTransfer()
{
  asm(
    "; backup regs\n"
    "push r1\n"
    "push r2\n"

    "load32 0xC0272C r2      ; r2 = 0xC0272C\n"

    "load 0 r1              ; r1 = 0 (enable)\n"
    "write 0 r2 r1            ; write to SPI1_CS\n"

    "; restore regs\n"
    "pop r2\n"
    "pop r1\n"
    );
}

// Sets SPI1_CS high
void FS_spiEndTransfer()
{
  asm(
    "; backup regs\n"
    "push r1\n"
    "push r2\n"

    "load32 0xC0272C r2      ; r2 = 0xC0272C\n"

    "load 1 r1              ; r1 = 1 (disable)\n"
    "write 0 r2 r1            ; write to SPI1_CS\n"

    "; restore regs\n"
    "pop r2\n"
    "pop r1\n"
    );
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI1 to CH376
word FS_spiTransfer(word dataByte)
{
  word retval = 0;
  asm(
    "load32 0xC0272B r2       ; r2 = 0xC0272B\n"
    "write 0 r2 r4            ; write r4 over SPI1\n"
    "read 0 r2 r2             ; read return value\n"
    "write -4 r14 r2          ; write to stack to return\n"
    );

  return retval;
}




// Get status after waiting for an interrupt
word FS_WaitGetStatus()
{
  word intValue = 1;
  while(intValue)
  {
    word *i = (word *) FS_INTERRUPT_ADDR;
    intValue = *i;
  }
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_GET_STATUS);
  FS_spiEndTransfer(); 
  //delay(1);

  FS_spiBeginTransfer();
  word retval = FS_spiTransfer(0x00);
  FS_spiEndTransfer(); 

  return retval;
}


// Get status without using interrupts
word FS_noWaitGetStatus()
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_GET_STATUS);
  word retval = FS_spiTransfer(0x00);
  FS_spiEndTransfer(); 

  return retval;
}


// Function to send a string (without terminating 0)
void FS_sendString(char* str)
{
  char chr = *str;      // first character of str

  while (chr != 0)      // continue until null value
  {
    FS_spiTransfer(chr);
    str++;          // go to next character address
    chr = *str;       // get character from address
  }
}


// Function to send data d of size s
void FS_sendData(char* d, word s)
{
  char chr = *d;      // first byte of data

  word i;
  for(i = 0; (unsigned int) i < (unsigned int)s; i++)  // write s bytes
  {
    FS_spiTransfer(chr);
    d++;          // go to next data address
    chr = *d;       // get data from address
  }
}


// Returns IC version of CH376 chip
// Good test to know if the communication with chip works
word FS_getICver()
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_GET_IC_VER);
  delay(1);

  word icVer = FS_spiTransfer(0x00);
  FS_spiEndTransfer();

  return icVer;
}

// Sets USB mode to mode, returns status code
// Which should be FS_ANSW_RET_SUCCESS when successful
word FS_setUSBmode(word mode)
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_SET_USB_MODE);
  FS_spiEndTransfer();
  delay(1);

  FS_spiBeginTransfer();
  FS_spiTransfer(mode);
  FS_spiEndTransfer();
  delay(1);

  FS_spiBeginTransfer();
  word status = FS_spiTransfer(0x00);
  FS_spiEndTransfer();
  delay(1);

  return status;
}


// resets and intitializes CH376
// returns FS_ANSW_RET_SUCCESS on success
word FS_init()
{
  FS_spiEndTransfer(); // start with cs high
  delay(10);

  // Reset
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_RESET_ALL);
  FS_spiEndTransfer();
  delay(100); // wait after reset

  // USB mode 0
  return FS_setUSBmode(FS_MODE_HOST_0);
}


// waits for drive connection,
// sets usb host mode
// waits for drive to be ready
// mounts drive
// also initializes current path to /
// returns FS_ANSW_USB_INT_SUCCESS on success
word FS_connectDrive() 
{
  // Wait forever until an USB device is connected
  while(FS_WaitGetStatus() != FS_ANSW_USB_INT_CONNECT);

  // USB mode 1
  word retval = FS_setUSBmode(FS_MODE_HOST_1);
  // Return on error
  if (retval != FS_ANSW_RET_SUCCESS)
    return retval;

  // USB mode 2
  retval = FS_setUSBmode(FS_MODE_HOST_2);
  // Return on error
  if (retval != FS_ANSW_RET_SUCCESS)
    return retval;

  // Need to check again for device connection after changing USB mode
  while(FS_WaitGetStatus() != FS_ANSW_USB_INT_CONNECT);

  // Connect to drive
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_DISK_CONNECT);
  FS_spiEndTransfer();

  retval = FS_WaitGetStatus();
  // Return on error
  if (retval != FS_ANSW_USB_INT_SUCCESS)
    return retval;

  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_DISK_MOUNT);
  FS_spiEndTransfer();

  return FS_WaitGetStatus();
}


// Returns file size of currently opened file (32 bits)
word FS_getFileSize()
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_GET_FILE_SIZE);
  FS_spiTransfer(0x68);
  word retval = FS_spiTransfer(0);
  retval = retval + (FS_spiTransfer(0) << 8);
  retval = retval + (FS_spiTransfer(0) << 16);
  retval = retval + (FS_spiTransfer(0) << 24);
  FS_spiEndTransfer();

  return retval;
}


// Sets cursor to position s
// Returns FS_ANSW_USB_INT_SUCCESS on success
word FS_setCursor(word s) 
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_BYTE_LOCATE);
  FS_spiTransfer(s);
  FS_spiTransfer(s >> 8);
  FS_spiTransfer(s >> 16);
  FS_spiTransfer(s >> 24);
  FS_spiEndTransfer();

  return FS_WaitGetStatus();
}


// Reads s bytes into buf
// If bytesToWord is true, four bytes will be stored in one address/word
// Can read 65536 bytes per call
// Returns FS_ANSW_USB_INT_SUCCESS on success
// TODO: this surely can be optimized for speed in some way!
word FS_readFile(char* buf, word s, word bytesToWord) 
{
  if (s == 0)
    return FS_ANSW_USB_INT_SUCCESS;

  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_BYTE_READ);
  FS_spiTransfer(s);
  FS_spiTransfer(s >> 8);
  FS_spiEndTransfer();

  word retval = FS_WaitGetStatus();
  // Return on error or EOF
  if (retval == FS_ANSW_USB_INT_SUCCESS) // eof
    return 0;
  if (retval != FS_ANSW_USB_INT_DISK_READ)
    return retval;


  word bytesRead = 0; 
  word wordsRead = 0;
  word doneReading = 0;

  // clear first address
  buf[wordsRead] = 0;

  // used for shifting bytes to word
  word currentByteShift = 24;

  while (doneReading == 0)
  {
    // Read set of bytes (max 255)
    FS_spiBeginTransfer();
    FS_spiTransfer(FS_CMD_RD_USB_DATA0);
    word readLen = FS_spiTransfer(0x00);

    word readByte;

    word i;
    for (i = 0; i < readLen; i++) 
    {
      readByte = FS_spiTransfer(0x00);

      // Read 4 bytes into one word, from left to right
      if (bytesToWord)
      {
        readByte = readByte << currentByteShift;
        buf[wordsRead] = buf[wordsRead] + readByte;


        if (currentByteShift == 0)
        {
          currentByteShift = 24;
          wordsRead++;
          buf[wordsRead] = 0;
        }
        else
        {
          currentByteShift -= 8;
        }

      }
      else
      {
        buf[bytesRead] = (char)readByte;
        bytesRead = bytesRead + 1;
      }
    }
    FS_spiEndTransfer();

    // requesting another set of data
    FS_spiBeginTransfer();
    FS_spiTransfer(FS_CMD_BYTE_RD_GO);
    FS_spiEndTransfer();

    retval = FS_WaitGetStatus();
    if (retval == FS_ANSW_USB_INT_SUCCESS)
      doneReading = 1;
    else if (retval == FS_ANSW_USB_INT_DISK_READ)
    {
      // read another block
    }
    else
    {
      uprintln("E: Error while reading data");
      return retval;
    }
  }

  return retval;
}


// Writes data d of size s
// Can only write 65536 bytes at a time
// returns FS_ANSW_USB_INT_SUCCESS on success
// TODO: optimize for speed
word FS_writeFile(char* d, word s) 
{
  if (s == 0)
    return FS_ANSW_USB_INT_SUCCESS;

  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_BYTE_WRITE);
  FS_spiTransfer(s);
  FS_spiTransfer(s >> 8);
  FS_spiEndTransfer();

  word retval = FS_WaitGetStatus();
  // Return on error
  if (retval != FS_ANSW_USB_INT_DISK_WRITE)
    return retval;


  word bytesWritten = 0;
  word doneWriting = 0;

  while (doneWriting == 0)
  {
    // Write set of bytes (max 255)
    FS_spiBeginTransfer();
    FS_spiTransfer(FS_CMD_WR_REQ_DATA);
    word wrLen = FS_spiTransfer(0x00);

    FS_sendData(d + bytesWritten, wrLen);
    bytesWritten = bytesWritten + wrLen;
    FS_spiEndTransfer();

    // update file size
    FS_spiBeginTransfer();
    FS_spiTransfer(FS_CMD_BYTE_WR_GO);
    FS_spiEndTransfer();


    retval = FS_WaitGetStatus();
    if (retval == FS_ANSW_USB_INT_SUCCESS)
      doneWriting = 1;
    else if (retval == FS_ANSW_USB_INT_DISK_WRITE)
    {
      // write another block
    }
    else
    {
      uprintln("E: Error while writing data");
      return retval;
    }

  }
  
  return retval;
}


// returns status of opening a file/directory
// Usually the successful status codes are:
//  FS_ANSW_USB_INT_SUCCESS || FS_ANSW_ERR_OPEN_DIR || FS_ANSW_USB_INT_DISK_READ
word FS_open() 
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_FILE_OPEN);
  FS_spiEndTransfer();

  return FS_WaitGetStatus();
}


// returns FS_ANSW_USB_INT_SUCCESS on success
word FS_delete() 
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_FILE_ERASE);
  FS_spiEndTransfer();

  return FS_WaitGetStatus();
}


// returns FS_ANSW_USB_INT_SUCCESS on success
word FS_close() 
{  
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_FILE_CLOSE);
  FS_spiTransfer(0x01); //0x01 if update filesize, else 0x00
  FS_spiEndTransfer();

  return FS_WaitGetStatus();
}


// returns FS_ANSW_USB_INT_SUCCESS on success
word FS_createDir() 
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_DIR_CREATE);
  FS_spiEndTransfer();

  return FS_WaitGetStatus();
}


// Creates file (recreates if exists)
// New files are 1 byte long
// Have not found a way to set it to 0 bytes, 
// since FS_CMD_SET_FILE_SIZE does not work
// Automatically closes file
// returns FS_ANSW_USB_INT_SUCCESS on success
word FS_createFile() 
{
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_FILE_CREATE);
  FS_spiEndTransfer();

  word retval = FS_WaitGetStatus();
  // Return on error
  if (retval != FS_ANSW_USB_INT_SUCCESS)
    return retval;

  // open and close file
  FS_open();
  FS_close();

  return FS_ANSW_USB_INT_SUCCESS;
}


// Sends single path f
// No processing of f is done, it is directly sent
// This means no error checking on file length!
void FS_sendSinglePath(char* f) 
{

  // send buf
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_SET_FILE_NAME);
  FS_sendString(f);    // send file name
  FS_spiTransfer(0);     // close with null
  FS_spiEndTransfer();
}


// Sends path f
// Can be relative or absolute file or directory
// REQUIRES CAPITAL LETTERS and must conform the 8.3 filename standard
// Function can handle folders with forward slashes
// returns FS_ANSW_USB_INT_SUCCESS on success
word FS_sendFullPath(char* f) 
{
  // path to uppercase and replace backslash by slash
  word i = 0;
  while (f[i] != 0)
  {
    f[i] = toUpper(f[i]);
    if (f[i] == '\\')
      f[i] = '/';
    i++;
  }

  word removedSlash = 0; // to restore removed slash
  // remove (single) trailing slash if exists
  // we reuse i here since it points to the end of the path
  if (i > 1) // ignore the root path
  {
    if (f[i-1] == '/')
    {
      f[i-1] = 0;
      removedSlash = 1;
    }
  }

  // if first char is a /, then we go back to root
  if (f[0] == '/')
  {
    FS_sendSinglePath("/");
    FS_open();
  }

  i = 0;
  char buf[16]; // buffer for single folder/file name
  word bufi = 0;

  while (f[i] != 0)
  {
    // handle all directories
    if (f[i] == 47) // forward slash
    {
      // return error on opening folders containing a single or double dot
      if ((bufi == 1 && buf[0] == '.') || (bufi == 2 && buf[0] == '.' && buf[1] == '.'))
        return FS_ANSW_ERR_OPEN_DIR;

      // add null to end of buf
      buf[bufi] = 0;
      // send buf
      FS_spiBeginTransfer();
      FS_spiTransfer(FS_CMD_SET_FILE_NAME);
      FS_sendString(buf);    // send folder name
      FS_spiTransfer(0);     // close with null
      FS_spiEndTransfer();
      // reset bufi
      bufi = 0;
      // open folder
      word retval = FS_open();
      // Return on if failure / folder not found
      if (retval != FS_ANSW_USB_INT_SUCCESS && retval != FS_ANSW_ERR_OPEN_DIR)
        return retval;
    }
    else
    {
      buf[bufi] = f[i];
      bufi++;
      if (bufi > 13)
        return FS_ERR_LONGFILENAME; // exit if folder/file name is too long
    }
    i++;
  }
  if (removedSlash) // restore removed slash if there
  {
    f[i] = '/';
    f[i+1] = 0;
  }

  // handle filename itself (if any)
  // add null to end of buf
  buf[bufi] = 0;
  if (bufi == 0)
    return FS_ANSW_USB_INT_SUCCESS; // exit if there is no filename after the folder

  // return error on opening folders containing a single or double dot
  if ((bufi == 1 && buf[0] == '.') || (bufi == 2 && buf[0] == '.' && buf[1] == '.'))
    return FS_ANSW_ERR_OPEN_DIR;

  // send buf (last part of string)
  FS_spiBeginTransfer();
  FS_spiTransfer(FS_CMD_SET_FILE_NAME);
  FS_sendString(buf);    // send file name
  FS_spiTransfer(0);     // close with null
  FS_spiEndTransfer();

  return FS_ANSW_USB_INT_SUCCESS;
}


// Parses and prints a string (useful for name and extension) after removing trailing spaces
// Len should be <= 8 chars
// Does not add a new line at the end.
// Returns length of written string
word FS_parseFATstring(char* fatBuffer, word len, char* b, word* bufLen)
{
  //uprintlnDec(bufLen);
  //uprintlnDec(*bufLen);
  if (len > 8)
  {
    uprintln("FATstring: Len argument > 8");
    return 0;
  }

  word retval = 0;

  // buffer of parsed string
  char nameBuf[9];
  nameBuf[len] = 0;

  // loop backwards until a non-space character is found
  // then, write string to nameBuf from there, keeping spaces in filename if any
  word foundChar = 0;
  word i;
  for (i = 0; i < len; i++)
  {
    if (!foundChar)
    {
      if (fatBuffer[len-1-i] == ' ')
        nameBuf[len-1-i] = 0; // set null until a non-space char is found
      else
      {
        foundChar = 1;
        retval = len-i;
        nameBuf[len-1-i] = fatBuffer[len-1-i]; // write the non-space char
      }
    }
    else
      nameBuf[len-1-i] = fatBuffer[len-1-i]; // copy char
  }

  // write to buffer
  i = 0;
  while (nameBuf[i] != 0)
  {
    b[*bufLen] = nameBuf[i];
    (*bufLen)++;
    i++;
  }
  
  return retval;
}


// Parses and writes name.extension and filesize on one line
void FS_parseFATdata(word datalen, char* fatBuffer, char* b, word* bufLen)
{
  if (datalen != 32)
  {
    uprintln("Unexpected FAT table length");
    return;
  }

  /* // Ignore lines with '.' and ".." as filename
  // ignore '.'
  if (memcmp(fatBuffer, ".      ", 11))
    return;

  // ignore ".."
  if (memcmp(fatBuffer, "..     ", 11))
    return;
  */

  // parse filename
  word printLen = FS_parseFATstring(fatBuffer, 8, b, bufLen);

  // add '.' and parse extension
  if (fatBuffer[8] != ' ' || fatBuffer[9] != ' ' || fatBuffer[10] != ' ')
  {
    b[*bufLen] = '.';
    (*bufLen)++;
    printLen += FS_parseFATstring(fatBuffer+8, 3, b, bufLen) + 1;
  }
  
  // append with spaces until 16th char
  while (printLen < 16)
  {
    b[*bufLen] = ' ';
    (*bufLen)++;
    printLen++;
  }

  // filesize
  word fileSize = 0;
  fileSize += fatBuffer[28];
  fileSize += (fatBuffer[29] << 8);
  fileSize += (fatBuffer[30] << 16);
  fileSize += (fatBuffer[31] << 24);

  // filesize to integer string
  char buffer[10];
  itoa(fileSize, buffer);

  // write to buffer
  word i = 0;
  while (buffer[i] != 0)
  {
    b[*bufLen] = buffer[i];
    (*bufLen)++;
    i++;
  }
  b[*bufLen] = '\n';
  (*bufLen)++;

  //uprintlnDec(*bufLen);
}


// Reads FAT data for single entry
// FAT data is parsed by FS_parseFatData()
void FS_readFATdata(char* b, word* bufLen)
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
  FS_parseFATdata(datalen, fatbuf, b, bufLen);
  FS_spiEndTransfer();
}

// Lists directory of full path f
// f needs to start with / and not end with /
// Returns FS_ANSW_USB_INT_SUCCESS if successful
// Writes parsed result to address b
// Result is terminated with a \0
word FS_listDir(char* f, char* b)
{
  word bufLen = 0;

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
  bufLen = 0;

  while (retval == FS_ANSW_USB_INT_DISK_READ)
  {
    FS_readFATdata(b, &bufLen);
    FS_spiBeginTransfer();
    FS_spiTransfer(FS_CMD_FILE_ENUM_GO);
    FS_spiEndTransfer();
    retval = FS_WaitGetStatus();
  }

  // Terminate buffer
  b[bufLen] = 0;
  bufLen++;

  return FS_ANSW_USB_INT_SUCCESS;
}


// Returns FS_ANSW_USB_INT_SUCCESS on successful change of dir
// Will return error FS_ANSW_ERR_FILE_CLOSE if dir is a file
word FS_changeDir(char* f)
{
  // Special case for root, since FS_open() returns as if it opened a file
  if (f[0] == '/' && f[1] == 0)
  {
    FS_sendSinglePath("/");
    FS_open();
    return FS_ANSW_USB_INT_SUCCESS;
  }

  word retval = FS_sendFullPath(f);
  // Return on failure
  if (retval != FS_ANSW_USB_INT_SUCCESS)
    return retval;

  retval = FS_open();
  
  // Return sucess on open dir
  if (retval == FS_ANSW_ERR_OPEN_DIR)
    return FS_ANSW_USB_INT_SUCCESS;

  // Close and return on opening file
  if (retval == FS_ANSW_USB_INT_SUCCESS)
  {
    FS_close();
    return FS_ANSW_ERR_FILE_CLOSE;
  }
  else // otherwise return error code
    return retval;

}
