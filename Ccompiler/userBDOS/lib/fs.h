/* fs.h
Handles filesystem for user programs for BDOS using CH376,
 so no PATH variable in memory
Uses only bottom USB port (SPI1 CH376), 
 allowing top USB top to be used for other USB devices.
Uses blocking delays for now.
*/

#include "stdlib.h" 

//CH376 Codes
#define CMD_GET_IC_VER           0x01
#define CMD_SET_BAUDRATE         0x02
#define CMD_ENTER_SLEEP          0x03
#define CMD_SET_USB_SPEED        0x04
#define CMD_RESET_ALL            0x05
#define CMD_CHECK_EXIST          0x06
#define CMD_SET_SD0_INT          0x0b
#define CMD_SET_RETRY            0x0b
#define CMD_GET_FILE_SIZE        0x0c
#define CMD_SET_FILE_SIZE        0x0d
#define CMD_SET_USB_ADDRESS      0x13
#define CMD_SET_USB_MODE         0x15
#define MODE_HOST_0              0x05
#define MODE_HOST_1              0x07
#define MODE_HOST_2              0x06
#define CMD_GET_STATUS           0x22
#define CMD_RD_USB_DATA0         0x27
#define CMD_WR_USB_DATA          0x2c
#define CMD_WR_REQ_DATA          0x2d
#define CMD_WR_OFS_DATA          0x2e
#define CMD_SET_FILE_NAME        0x2f
#define CMD_DISK_CONNECT         0x30
#define CMD_DISK_MOUNT           0x31
#define CMD_FILE_OPEN            0x32
#define CMD_FILE_ENUM_GO         0x33
#define CMD_FILE_CREATE          0x34
#define CMD_FILE_ERASE           0x35
#define CMD_FILE_CLOSE           0x36
#define CMD_DIR_INFO_READ        0x37
#define CMD_DIR_INFO_SAVE        0x38
#define CMD_BYTE_LOCATE          0x39
#define CMD_BYTE_READ            0x3a
#define CMD_BYTE_RD_GO           0x3b
#define CMD_BYTE_WRITE           0x3c
#define CMD_BYTE_WR_GO           0x3d
#define CMD_DISK_CAPACITY        0x3e
#define CMD_DISK_QUERY           0x3f
#define CMD_DIR_CREATE           0x40
#define CMD_SET_ADDRESS          0x45
#define CMD_GET_DESCR            0x46
#define CMD_SET_CONFIG           0x49
#define CMD_AUTO_CONFIG          0x4D
#define CMD_ISSUE_TKN_X          0x4E

#define ANSW_RET_SUCCESS         0x51
#define ANSW_USB_INT_SUCCESS     0x14
#define ANSW_USB_INT_CONNECT     0x15
#define ANSW_USB_INT_DISCONNECT  0x16
#define ANSW_USB_INT_USB_READY   0x18
#define ANSW_USB_INT_DISK_READ   0x1d
#define ANSW_USB_INT_DISK_WRITE  0x1e
#define ANSW_RET_ABORT           0x5F
#define ANSW_USB_INT_DISK_ERR    0x1f
#define ANSW_USB_INT_BUF_OVER    0x17
#define ANSW_ERR_OPEN_DIR        0x41
#define ANSW_ERR_MISS_FILE       0x42
#define ANSW_ERR_FOUND_NAME      0x43
#define ANSW_ERR_DISK_DISCON     0x82
#define ANSW_ERR_LARGE_SECTOR    0x84
#define ANSW_ERR_TYPE_ERROR      0x92
#define ANSW_ERR_BPB_ERROR       0xa1
#define ANSW_ERR_DISK_FULL       0xb1
#define ANSW_ERR_FDT_OVER        0xb2
#define ANSW_ERR_FILE_CLOSE      0xb4
#define ERR_LONGFILENAME         0x01
#define ATTR_READ_ONLY           0x01
#define ATTR_HIDDEN              0x02
#define ATTR_SYSTEM              0x04
#define ATTR_VOLUME_ID           0x08
#define ATTR_DIRECTORY           0x10 
#define ATTR_ARCHIVE             0x20


// Sets SPI1_CS low
void FS_spiBeginTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC0272C r2          // r2 = 0xC0272C | SPI1_CS ;\
    \
    load 0 r1                   // r1 = 0 (enable) ;\
    write 0 r2 r1               // write to SPI1_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets SPI1_CS high
void FS_spiEndTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC0272C r2          // r2 = 0xC0272C | SPI1_CS ;\
    \
    load 1 r1                   // r1 = 1 (disable) ;\
    write 0 r2 r1               // write to SPI1_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI1 to CH376
// INPUT:
//   r5: byte to write
// OUTPUT:
//   r1: read value
int FS_spiTransfer(int dataByte)
{
    ASM("\
    load32 0xC0272B r1      // r1 = 0xC0272B | SPI1 address     ;\
    write 0 r1 r5           // write r5 over SPI1               ;\
    read 0 r1 r1            // read return value                ;\
    ");
}




// Get status after waiting for an interrupt
int FS_WaitGetStatus()
{
    int intValue = 1;
    while(intValue)
    {
        int *i = (int *) 0xC0272D;
        intValue = *i;
    }
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_GET_STATUS);
    FS_spiEndTransfer(); 
    //delay(1);

    FS_spiBeginTransfer();
    int retval = FS_spiTransfer(0x00);
    FS_spiEndTransfer(); 

    return retval;
}


// Get status without using interrupts
int FS_noWaitGetStatus()
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_GET_STATUS);
    int retval = FS_spiTransfer(0x00);
    FS_spiEndTransfer(); 

    return retval;
}


// Function to send a string (without terminating 0)
void FS_sendString(char* str)
{
    char chr = *str;            // first character of str

    while (chr != 0)            // continue until null value
    {
        FS_spiTransfer(chr);
        str++;                  // go to next character address
        chr = *str;             // get character from address
    }
}


// Function to send data d of size s
void FS_sendData(char* d, int s)
{
    char chr = *d;          // first byte of data

    for(int i = 0; i < s; i++)  // write s bytes
    {
        FS_spiTransfer(chr);
        d++;                    // go to next data address
        chr = *d;           // get data from address
    }
}


// Returns IC version of CH376 chip
// Good test to know if the communication with chip works
int FS_getICver()
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_GET_IC_VER);
    delay(1);

    int icVer = FS_spiTransfer(0x00);
    FS_spiEndTransfer();

    return icVer;
}

// Sets USB mode to mode, returns status code
// Which should be ANSW_RET_SUCCESS when successful
int FS_setUSBmode(int mode)
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_SET_USB_MODE);
    FS_spiEndTransfer();
    delay(1);

    FS_spiBeginTransfer();
    FS_spiTransfer(mode);
    FS_spiEndTransfer();
    delay(1);

    FS_spiBeginTransfer();
    int status = FS_spiTransfer(0x00);
    FS_spiEndTransfer();
    delay(1);

    return status;
}


// resets and intitializes CH376
// returns ANSW_RET_SUCCESS on success
int FS_init()
{
    FS_spiEndTransfer(); // start with cs high
    delay(60);

    // Reset
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_RESET_ALL);
    FS_spiEndTransfer();
    delay(100); // wait after reset

    // USB mode 0
    return FS_setUSBmode(MODE_HOST_0);
}


// waits for drive connection,
// sets usb host mode
// waits for drive to be ready
// mounts drive
// also initializes current path to /
// returns ANSW_USB_INT_SUCCESS on success
int FS_connectDrive() 
{
    // Wait forever until an USB device is connected
    while(FS_WaitGetStatus() != ANSW_USB_INT_CONNECT);

    // USB mode 1
    int retval = FS_setUSBmode(MODE_HOST_1);
    // Return on error
    if (retval != ANSW_RET_SUCCESS)
        return retval;

    // USB mode 2
    retval = FS_setUSBmode(MODE_HOST_2);
    // Return on error
    if (retval != ANSW_RET_SUCCESS)
        return retval;

    // Need to check again for device connection after changing USB mode
    while(FS_WaitGetStatus() != ANSW_USB_INT_CONNECT);

    // Connect to drive
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_DISK_CONNECT);
    FS_spiEndTransfer();

    retval = FS_WaitGetStatus();
    // Return on error
    if (retval != ANSW_USB_INT_SUCCESS)
        return retval;

    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_DISK_MOUNT);
    FS_spiEndTransfer();

    return FS_WaitGetStatus();
}


// Returns file size of currently opened file (32 bits)
int FS_getFileSize()
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_GET_FILE_SIZE);
    FS_spiTransfer(0x68);
    int retval = FS_spiTransfer(0);
    retval = retval + (FS_spiTransfer(0) << 8);
    retval = retval + (FS_spiTransfer(0) << 16);
    retval = retval + (FS_spiTransfer(0) << 24);
    FS_spiEndTransfer();

    return retval;
}


// Sets cursor to position s
// Returns ANSW_USB_INT_SUCCESS on success
int FS_setCursor(int s) 
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_BYTE_LOCATE);
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
// Returns ANSW_USB_INT_SUCCESS on success
int FS_readFile(char* buf, int s, int bytesToWord) 
{
    if (s == 0)
        return ANSW_USB_INT_SUCCESS;

    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_BYTE_READ);
    FS_spiTransfer(s);
    FS_spiTransfer(s >> 8);
    FS_spiEndTransfer();

    int retval = FS_WaitGetStatus();
    // Return on error
    if (retval != ANSW_USB_INT_DISK_READ)
        return retval;


    int bytesRead = 0; 
    int wordsRead = 0;
    int doneReading = 0;

    // clear first address
    buf[wordsRead] = 0;

    // used for shifting bytes to word
    int currentByteShift = 24;

    while (doneReading == 0)
    {
        // Read set of bytes (max 255)
        FS_spiBeginTransfer();
        FS_spiTransfer(CMD_RD_USB_DATA0);
        int readLen = FS_spiTransfer(0x00);

        int readByte;

        for (int i = 0; i < readLen; i++) 
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
                    wordsRead += 1;
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
        FS_spiTransfer(CMD_BYTE_RD_GO);
        FS_spiEndTransfer();

        retval = FS_WaitGetStatus();
        if (retval == ANSW_USB_INT_SUCCESS)
            doneReading = 1;
        else if (retval == ANSW_USB_INT_DISK_READ)
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
// returns ANSW_USB_INT_SUCCESS on success
int FS_writeFile(char* d, int s) 
{
    if (s == 0)
        return ANSW_USB_INT_SUCCESS;

    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_BYTE_WRITE);
    FS_spiTransfer(s);
    FS_spiTransfer(s >> 8);
    FS_spiEndTransfer();

    int retval = FS_WaitGetStatus();
    // Return on error
    if (retval != ANSW_USB_INT_DISK_WRITE)
        return retval;


    int bytesWritten = 0;
    int doneWriting = 0;

    while (doneWriting == 0)
    {
        // Write set of bytes (max 255)
        FS_spiBeginTransfer();
        FS_spiTransfer(CMD_WR_REQ_DATA);
        int wrLen = FS_spiTransfer(0x00);

        FS_sendData(d + bytesWritten, wrLen);
        bytesWritten = bytesWritten + wrLen;
        FS_spiEndTransfer();

        // update file size
        FS_spiBeginTransfer();
        FS_spiTransfer(CMD_BYTE_WR_GO);
        FS_spiEndTransfer();


        retval = FS_WaitGetStatus();
        if (retval == ANSW_USB_INT_SUCCESS)
            doneWriting = 1;
        else if (retval == ANSW_USB_INT_DISK_WRITE)
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
//  ANSW_USB_INT_SUCCESS || ANSW_ERR_OPEN_DIR || ANSW_USB_INT_DISK_READ
int FS_open() 
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_FILE_OPEN);
    FS_spiEndTransfer();

    return FS_WaitGetStatus();
}


// returns ANSW_USB_INT_SUCCESS on success
int FS_delete() 
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_FILE_ERASE);
    FS_spiEndTransfer();

    return FS_WaitGetStatus();
}


// returns ANSW_USB_INT_SUCCESS on success
int FS_close() 
{  
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_FILE_CLOSE);
    FS_spiTransfer(0x01); //0x01 if update filesize, else 0x00
    FS_spiEndTransfer();

    return FS_WaitGetStatus();
}


// returns ANSW_USB_INT_SUCCESS on success
int FS_createDir() 
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_DIR_CREATE);
    FS_spiEndTransfer();

    return FS_WaitGetStatus();
}


// Creates file (recreates if exists)
// New files are 1 byte long
// Have not found a way to set it to 0 bytes, 
// since CMD_SET_FILE_SIZE does not work
// Automatically closes file
// returns ANSW_USB_INT_SUCCESS on success
int FS_createFile() 
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_FILE_CREATE);
    FS_spiEndTransfer();

    int retval = FS_WaitGetStatus();
    // Return on error
    if (retval != ANSW_USB_INT_SUCCESS)
        return retval;


    retval = FS_open();
    // Return on error
    if (retval != ANSW_USB_INT_SUCCESS)
        return retval;


    // setting file size to 0
    // works in memory, but does not update on disk
    /*
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_SET_FILE_SIZE);
    FS_spiTransfer(0x68);
    FS_spiTransfer(0);
    FS_spiTransfer(0);
    FS_spiTransfer(0);
    FS_spiTransfer(0);
    FS_spiEndTransfer();
    */

    // closing file
    return FS_close();
}


// Sends single path f
// No processing of f is done, it is directly sent
// This means no error checking on file length!
void FS_sendSinglePath(char* f) 
{

    // send buf
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_SET_FILE_NAME);
    FS_sendString(f);      // send file name
    FS_spiTransfer(0);       // close with null
    FS_spiEndTransfer();
}


// Sends path f
// Can be relative or absolute file or directory
// REQUIRES CAPITAL LETTERS and must conform the 8.3 filename standard
// Function can handle folders with forward slashes
// returns ANSW_USB_INT_SUCCESS on success
int FS_sendFullPath(char* f) 
{
    // path to uppercase and replace backslash by slash
    int i = 0;
    while (f[i] != 0)
    {
        f[i] = toUpper(f[i]);
        if (f[i] == '\\')
            f[i] = '/';
        i += 1;
    }

    // if first char is a /, then we go back to root
    if (f[0] == '/')
    {
        FS_sendSinglePath("/");
        FS_open();
    }

    i = 0;
    char buf[16]; // buffer for single folder/file name
    int bufi = 0;

    while (f[i] != 0)
    {
        // handle all directories
        if (f[i] == 47) // forward slash
        {
            // return error on opening folders containing a single or double dot
            if ((bufi == 1 && buf[0] == '.') || (bufi == 2 && buf[0] == '.' && buf[1] == '.'))
                return ANSW_ERR_OPEN_DIR;

            // add null to end of buf
            buf[bufi] = 0;
            // send buf
            FS_spiBeginTransfer();
            FS_spiTransfer(CMD_SET_FILE_NAME);
            FS_sendString(&buf[0]);      // send folder name
            FS_spiTransfer(0);       // close with null
            FS_spiEndTransfer();
            // reset bufi
            bufi = 0;
            // open folder
            int retval = FS_open();
            // Return on if failure / folder not found
            if (retval != ANSW_USB_INT_SUCCESS && retval != ANSW_ERR_OPEN_DIR)
                return retval;
        }
        else
        {
            buf[bufi] = f[i];
            bufi++;
            if (bufi > 13)
                return ERR_LONGFILENAME; // exit if folder/file name is too long
        }
        i++;
    }
    // handle filename itself (if any)
    // add null to end of buf
    buf[bufi] = 0;
    if (bufi == 0)
        return ANSW_USB_INT_SUCCESS; // exit if there is no filename after the folder

    // return error on opening folders containing a single or double dot
    if ((bufi == 1 && buf[0] == '.') || (bufi == 2 && buf[0] == '.' && buf[1] == '.'))
        return ANSW_ERR_OPEN_DIR;

    // send buf (last part of string)
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_SET_FILE_NAME);
    FS_sendString(&buf[0]);      // send file name
    FS_spiTransfer(0);       // close with null
    FS_spiEndTransfer();

    return ANSW_USB_INT_SUCCESS;
}


// Parses and prints a string (useful for name and extension) after removing trailing spaces
// Len should be <= 8 chars
// Does not add a new line at the end.
// Returns length of written string
int FS_parseFATstring(char* fatBuffer, int len, char* b, int* bufLen)
{
    if (len > 8)
    {
        uprintln("FATstring: Len argument > 8");
        return 0;
    }

    int retval = 0;

    // buffer of parsed string
    char nameBuf[9];
    nameBuf[len] = 0;

    // loop backwards until a non-space character is found
    // then, write string to nameBuf from there, keeping spaces in filename if any
    int foundChar = 0;
    for (int i = 0; i < len; i++)
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
    int i = 0;
    while (nameBuf[i] != 0)
    {
        b[*bufLen] = nameBuf[i];
        *bufLen += 1;
        i += 1;
    }
    
    return retval;
}


// Parses and writes name.extension and filesize on one line
void FS_parseFATdata(int datalen, char* fatBuffer, char* b, int* bufLen)
{
    if (datalen != 32)
    {
        uprintln("Unexpected FAT table length");
        return;
    }

    // parse filename
    int printLen = FS_parseFATstring(fatBuffer, 8, b, bufLen);

    // add '.' and parse extension
    if (fatBuffer[8] != ' ' || fatBuffer[9] != ' ' || fatBuffer[10] != ' ')
    {
        b[*bufLen] = '.';
        *bufLen += 1;
        printLen += FS_parseFATstring(fatBuffer+8, 3, b, bufLen) + 1;
    }
    
    // append with spaces until 16th char
    while (printLen < 16)
    {
        b[*bufLen] = ' ';
        *bufLen += 1;
        printLen += 1;
    }

    // filesize
    int fileSize = 0;
    fileSize += fatBuffer[28];
    fileSize += (fatBuffer[29] << 8);
    fileSize += (fatBuffer[30] << 16);
    fileSize += (fatBuffer[31] << 24);

    // filesize to integer string
    char buffer[10];
    itoa(fileSize, &buffer[0]);

    // write to buffer
    int i = 0;
    while (buffer[i] != 0)
    {
        b[*bufLen] = buffer[i];
        *bufLen += 1;
        i += 1;
    }
    b[*bufLen] = '\n';
    *bufLen += 1;
}


// Reads FAT data for single entry
// FAT data is parsed by FS_parseFatData()
void FS_readFATdata(char* b, int* bufLen)
{
    FS_spiBeginTransfer();
    FS_spiTransfer(CMD_RD_USB_DATA0);
    int datalen = FS_spiTransfer(0x0);
    char fatbuf[32];
    for (int i = 0; i < datalen; i++)
    {
        fatbuf[i] = FS_spiTransfer(0x00);
    }
    FS_parseFATdata(datalen, &fatbuf[0], b, bufLen);
    FS_spiEndTransfer();
}

// Lists directory of full path f
// f needs to start with / and not end with /
// Returns ANSW_USB_INT_SUCCESS if successful
// Writes parsed result to address b
// Length of output buffer is returned in bufLen
int FS_listDir(char* f, char* b, int* bufLen)
{
    int retval = FS_sendFullPath(f);
    // Return on failure
    if (retval != ANSW_USB_INT_SUCCESS)
        return retval;

    retval = FS_open();
    // Return on failure
    if (retval != ANSW_USB_INT_SUCCESS && retval != ANSW_ERR_OPEN_DIR)
        return retval;

    FS_sendSinglePath("*");

    retval = FS_open();
    // Return on failure
    if (retval != ANSW_USB_INT_DISK_READ)
        return retval;

    // Init length of output buffer
    *bufLen = 0;

    while (retval == ANSW_USB_INT_DISK_READ)
    {
        FS_readFATdata(b, bufLen);
        FS_spiBeginTransfer();
        FS_spiTransfer(CMD_FILE_ENUM_GO);
        FS_spiEndTransfer();
        retval = FS_WaitGetStatus();
    }

    // Terminate buffer
    b[*bufLen] = 0;
    *bufLen += 1;

    return ANSW_USB_INT_SUCCESS;
}


// Returns ANSW_USB_INT_SUCCESS on successful change of dir
// Will return error ANSW_ERR_FILE_CLOSE if dir is a file
int FS_changeDir(char* f)
{
    // Special case for root, since FS_open() returns as if it opened a file
    if (f[0] == '/' && f[1] == 0)
    {
        FS_sendSinglePath("/");
        FS_open();
        return ANSW_USB_INT_SUCCESS;
    }

    int retval = FS_sendFullPath(f);
    // Return on failure
    if (retval != ANSW_USB_INT_SUCCESS)
        return retval;

    retval = FS_open();
    
    // Return sucess on open dir
    if (retval == ANSW_ERR_OPEN_DIR)
        return ANSW_USB_INT_SUCCESS;

    // Close and return on opening file
    if (retval == ANSW_USB_INT_SUCCESS)
    {
        FS_close();
        return ANSW_ERR_FILE_CLOSE;
    }
    else // otherwise return error code
        return retval;

}
