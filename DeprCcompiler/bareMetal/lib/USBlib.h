/* USBlib.h
Library for interfacing to the two USB ports on the FPGC4.
Uses two CH376T ICs for interfacing.
*/

#include "stdlib.h" 

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
void USB1_spiBeginTransfer()
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
void USB1_spiEndTransfer()
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
int USB1_spiTransfer(int dataByte)
{
    ASM("\
    load32 0xC0272B r1      // r1 = 0xC0272B | SPI1 address     ;\
    write 0 r1 r5           // write r5 over SPI1               ;\
    read 0 r1 r1            // read return value                ;\
    ");
}


// Sets SPI2_CS low
void USB2_spiBeginTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC0272F r2          // r2 = 0xC0272F | SPI2_CS ;\
    \
    load 0 r1                   // r1 = 0 (enable) ;\
    write 0 r2 r1               // write to SPI2_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets SPI2_CS high
void USB2_spiEndTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC0272F r2          // r2 = 0xC0272F | SPI2_CS ;\
    \
    load 1 r1                   // r1 = 1 (disable) ;\
    write 0 r2 r1               // write to SPI2_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI2 to CH376
// INPUT:
//   r5: byte to write
// OUTPUT:
//   r1: read value
int USB2_spiTransfer(int dataByte)
{
    ASM("\
    load32 0xC0272E r1      // r1 = 0xC0272E | SPI2 address     ;\
    write 0 r1 r5           // write r5 over SPI2               ;\
    read 0 r1 r1            // read return value                ;\
    ");
}


// Enable CH376 chip for the correct USB port
void CH376_spiBeginTransfer(int USB)
{
    if(USB == 1)
        USB1_spiBeginTransfer();
    if(USB == 2)
        USB2_spiBeginTransfer();
}

// Disable CH376 chip for the correct USB port
void CH376_spiEndTransfer(int USB)
{
    if(USB == 1)
        USB1_spiEndTransfer();
    if(USB == 2)
        USB2_spiEndTransfer();
}

// Transfer byte b to CH376 chip for the correct USB port
int CH376_spiTransfer(int USB, int b)
{
    if(USB == 1)
        return USB1_spiTransfer(b);
    if(USB == 2)
        return USB2_spiTransfer(b);
}


// Get status after waiting for an interrupt
int CH376_WaitGetStatus(int USB)
{
    int intValue = 1;
    while(intValue)
    {
        if(USB == 1)
        {
            int *i = (int *) 0xC0272D;
            intValue = *i;
        }
        if(USB == 2)
        {
            int *i = (int *) 0xC02730;
            intValue = *i;
        }
        
    }
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_GET_STATUS);
    CH376_spiEndTransfer(USB); 
    delay(1);

    CH376_spiBeginTransfer(USB);
    int retval = CH376_spiTransfer(USB, 0x00);
    CH376_spiEndTransfer(USB); 

    return retval;
}

// Get status without using interrupts
int CH376_noWaitGetStatus(int USB)
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_GET_STATUS);
    int retval = CH376_spiTransfer(USB, 0x00);
    CH376_spiEndTransfer(USB); 

    return retval;
}


// Function to send a string (without terminating 0)
void CH376_sendString(int USB, char* str)
{
    char chr = *str;            // first character of str

    while (chr != 0)            // continue until null value
    {
        CH376_spiTransfer(USB, chr);
        str++;                  // go to next character address
        chr = *str;             // get character from address
    }
}


// Function to send data d of size s
void CH376_sendData(int USB, char* d, int s)
{
    char chr = *d;          // first byte of data

    for(int i = 0; i < s; i++)  // write s bytes
    {
        CH376_spiTransfer(USB, chr);
        d++;                    // go to next data address
        chr = *d;           // get data from address
    }
}


// Good test to know if the communication works
void CH376_printICver(int USB)
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_GET_IC_VER);
    delay(1);

    int icVer = CH376_spiTransfer(USB, 0x00);
    CH376_spiEndTransfer(USB);

    char buffer[10];
    itoah(icVer, &buffer[0]);
    uprint(&buffer[0]);
    uprintln(", IC version");
}

// Sets USB mode to mode, returns status code
// Which should be 0x51 when successful
int CH376_setUSBmode(int USB, int mode)
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_SET_USB_MODE);
    CH376_spiEndTransfer(USB);
    delay(1);

    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, mode);
    CH376_spiEndTransfer(USB);
    delay(1);

    CH376_spiBeginTransfer(USB);
    int status = CH376_spiTransfer(USB, 0x00);
    CH376_spiEndTransfer(USB);
    delay(1);

    return status;
}


// resets and intitializes CH376
// returns 1 on success
int CH376_init(int USB)
{
    CH376_spiEndTransfer(USB); // start with cs high
    delay(60);

    // Reset
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_RESET_ALL);
    CH376_spiEndTransfer(USB);
    delay(100); // wait after reset

    // USB mode 0
    int retval = CH376_setUSBmode(USB, MODE_HOST_0);
    if (retval == 0x51)
        return 1;
    else
        return 0;
}


// waits for drive connection,
// sets usb host mode
// waits for drive to be ready
// mounts drive
// returns 1 on success
int CH376_connectDrive(int USB) 
{
    // Wait forever until an USB device is connected
    while(CH376_WaitGetStatus(USB) != ANSW_USB_INT_CONNECT);

    int retval = CH376_setUSBmode(USB, MODE_HOST_1);
    // Return on error
    if (retval != 0x51)
        return 0;

    // USB mode 2
    retval = CH376_setUSBmode(USB, MODE_HOST_2);
    // Return on error
    if (retval != 0x51)
        return 0;

    // Device connection
    while(CH376_WaitGetStatus(USB) != ANSW_USB_INT_CONNECT);

    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_DISK_CONNECT);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) != ANSW_USB_INT_SUCCESS)
        return 0;

    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_DISK_MOUNT);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) != ANSW_USB_INT_SUCCESS)
        return 0;

    return 1;
}


// Returns file size of currently opened file (32 bits)
int CH376_getFileSize(int USB)
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_GET_FILE_SIZE);
    CH376_spiTransfer(USB, 0x68);
    int retval = CH376_spiTransfer(USB, 0);
    retval = retval + (CH376_spiTransfer(USB, 0) << 8);
    retval = retval + (CH376_spiTransfer(USB, 0) << 16);
    retval = retval + (CH376_spiTransfer(USB, 0) << 24);
    CH376_spiEndTransfer(USB);

    return retval;
}


// Sets cursor to position s
// Returns 1 on success
int CH376_setCursor(int USB, int s) 
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_BYTE_LOCATE);
    CH376_spiTransfer(USB, s);
    CH376_spiTransfer(USB, s >> 8);
    CH376_spiTransfer(USB, s >> 16);
    CH376_spiTransfer(USB, s >> 24);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) != ANSW_USB_INT_SUCCESS)
        return 0;

    return 1;
}


// Reads s bytes into buf
// Can read 65536 bytes per call
// Returns 1 on success
int CH376_readFile(int USB, char* buf, int s) 
{
    if (s == 0)
        return 1;

    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_BYTE_READ);
    CH376_spiTransfer(USB, s);
    CH376_spiTransfer(USB, s >> 8);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) != ANSW_USB_INT_DISK_READ)
        return 0;

    int bytesRead = 0; 
    int doneReading = 0;

    while (doneReading == 0)
    {
        // Read set of bytes (max 255)
        CH376_spiBeginTransfer(USB);
        CH376_spiTransfer(USB, CMD_RD_USB_DATA0);
        int readLen = CH376_spiTransfer(USB, 0x00);

        int readByte;

        for (int i = 0; i < readLen; i++) 
        {
            readByte = CH376_spiTransfer(USB, 0x00);
            buf[bytesRead] = (char)readByte;
            bytesRead = bytesRead + 1;
        }
        CH376_spiEndTransfer(USB);

        // requesting another set of data
        CH376_spiBeginTransfer(USB);
        CH376_spiTransfer(USB, CMD_BYTE_RD_GO);
        CH376_spiEndTransfer(USB);

        int IntStatus = CH376_WaitGetStatus(USB);
        if (IntStatus == ANSW_USB_INT_SUCCESS)
            doneReading = 1;
        else if (IntStatus == ANSW_USB_INT_DISK_READ)
        {
            // read another block
        }
        else
        {
            uprintln("Error while reading data");
            return 0;
        }
    }

    return 1;
}


// Writes data d of size s
// Can only write 65536 bytes at a time
// returns 1 on success
int CH376_writeFile(int USB, char* d, int s) 
{
    if (s == 0)
        return 1;

    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_BYTE_WRITE);
    CH376_spiTransfer(USB, s);
    CH376_spiTransfer(USB, s >> 8);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) != ANSW_USB_INT_DISK_WRITE)
        return 0;

    int bytesWritten = 0;
    int doneWriting = 0;

    while (doneWriting == 0)
    {
        // Write set of bytes (max 255)
        CH376_spiBeginTransfer(USB);
        CH376_spiTransfer(USB, CMD_WR_REQ_DATA);
        int wrLen = CH376_spiTransfer(USB, 0x00);

        CH376_sendData(USB, d + bytesWritten, wrLen);
        bytesWritten = bytesWritten + wrLen;
        CH376_spiEndTransfer(USB);

        // update file size
        CH376_spiBeginTransfer(USB);
        CH376_spiTransfer(USB, CMD_BYTE_WR_GO);
        CH376_spiEndTransfer(USB);


        int IntStatus = CH376_WaitGetStatus(USB);
        if (IntStatus == ANSW_USB_INT_SUCCESS)
            doneWriting = 1;
        else if (IntStatus == ANSW_USB_INT_DISK_WRITE)
        {
            // write another block
        }
        else
        {
            uprintln("Error while writing data");
            return 0;
        }

    }
    
    return 1;
}


// returns 1 on success
int CH376_openFile(int USB) 
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_FILE_OPEN);
    CH376_spiEndTransfer(USB);

    int status = CH376_WaitGetStatus(USB);
    // opening a file returns int_success, 
    //  opening a directory returns ERR_OPEN_DIR on success (WTF)
    //  this is all according to the official documentation
    if (status == ANSW_USB_INT_SUCCESS || status == ANSW_ERR_OPEN_DIR)
        return 1;
    else
        return 0;
}


// returns 1 on success
int CH376_deleteFile(int USB) 
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_FILE_ERASE);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) == ANSW_USB_INT_SUCCESS)
        return 1;
    else
        return 0;
}


// returns 1 on success
int CH376_closeFile(int USB) 
{  
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_FILE_CLOSE);
    CH376_spiTransfer(USB, 0x01); //0x01 if update filesize, else 0x00
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) == ANSW_USB_INT_SUCCESS)
        return 1;
    else
        return 0;
}


// returns 1 on success
int CH376_createDir(int USB) 
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_DIR_CREATE);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) == ANSW_USB_INT_SUCCESS)
        return 1;
    else
        return 0;
}


// Creates file (recreates if exists)
// New files are 1 byte long
// Have not found a way to set it to 0 bytes, 
// since CMD_SET_FILE_SIZE does not work
// Automatically closes file
// returns 1 on success
int CH376_createFile(int USB) 
{
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_FILE_CREATE);
    CH376_spiEndTransfer(USB);

    if (CH376_WaitGetStatus(USB) != ANSW_USB_INT_SUCCESS)
        return 0;

    if (!CH376_openFile(USB))
        return 0;

    // setting file size to 0
    // works in memory, but does not update on disk
    /*
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_SET_FILE_SIZE);
    CH376_spiTransfer(USB, 0x68);
    CH376_spiTransfer(USB, 0);
    CH376_spiTransfer(USB, 0);
    CH376_spiTransfer(USB, 0);
    CH376_spiTransfer(USB, 0);
    CH376_spiEndTransfer(USB);
    */

    // closing file
    if (!CH376_closeFile(USB))
        return 0;

    return 1;
}





// Sends filename f
// REQUIRES CAPITAL LETTERS and must conform the 8.3 filename standard
// Function can handle folders with forward slashes
// returns 1 on success
int CH376_sendFileName(int USB, char* f) 
{

    int i = 1; // skip first slash
    char buf[16]; // buffer for single folder/file name
    buf[0] = 47; // add first slash
    int bufi = 1; // skip first slash

    while (f[i] != 0)
    {
        // handle all directories
        if (f[i] == 47) // forward slash
        {
            // add null to end of buf
            buf[bufi] = 0;
            // send buf
            CH376_spiBeginTransfer(USB);
            CH376_spiTransfer(USB, CMD_SET_FILE_NAME);
            CH376_sendString(USB, &buf[0]);      // send folder name
            CH376_spiTransfer(USB, 0);       // close with null
            CH376_spiEndTransfer(USB);
            // reset bufi
            bufi = 0;
            // open folder
            if (!CH376_openFile(USB))
                return 0; // exit if failure / folder not found
        }
        else
        {
            buf[bufi] = f[i];
            bufi++;
            if (bufi > 13)
                return 0; // exit if folder/file name is too long
        }
        i++;
    }
    // handle filename itself
    // add null to end of buf
    buf[bufi] = 0;
    if (bufi == 0)
        return 0; // exit if there is no filename after the folder

    // send buf
    CH376_spiBeginTransfer(USB);
    CH376_spiTransfer(USB, CMD_SET_FILE_NAME);
    CH376_sendString(USB, &buf[0]);      // send folder name
    CH376_spiTransfer(USB, 0);       // close with null
    CH376_spiEndTransfer(USB);

    return 1;
}