#include "lib/stdlib.h" 

// Sets SPI0_CS low
void SpiBeginTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC02729 r2          // r2 = 0xC02729 | SPI0_CS ;\
    \
    load 0 r1                   // r1 = 0 (enable) ;\
    write 0 r2 r1               // write to SPI0_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// Sets SPI0_CS high
void SpiEndTransfer()
{
    ASM("\
    // backup regs ;\
    push r1 ;\
    push r2 ;\
    \
    load32 0xC02729 r2          // r2 = 0xC02729 | SPI0_CS ;\
    \
    load 1 r1                   // r1 = 1 (disable) ;\
    write 0 r2 r1               // write to SPI0_CS ;\
    \
    // restore regs ;\
    pop r2 ;\
    pop r1 ;\
    ");
}

// write dataByte and return read value
// write 0x00 for a read
// INPUT:
//   r5: byte to write
// OUTPUT:
//   r1: read value
int SpiTransfer(int dataByte)
{
    ASM("\
    load32 0xC02728 r1      // r1 = 0xC02728 | SPI address      ;\
    write 0 r1 r5           // write r5 over SPI                ;\
    read 0 r1 r1            // read return value                ;\
    ");
}


#define COMMAND_IDLE                    0
#define COMMAND_FLASH_READ              114 // 'r'
#define COMMAND_FLASH_ERASE_BLOCK       101 // 'e'
#define COMMAND_FLASH_WRITE             119 // 'w'
#define COMMAND_FILL_BUFFER             98  // 'b'

#define BLOCK_SIZE 32768
#define SECTOR_SIZE 4096
#define PAGE_SIZE 256
#define COMMAND_SIZE 8


// the current command the program is busy with
// if idle, should listen to UART for new command
int currentCommand = COMMAND_IDLE;

// UART buffer that stores a single command
int UARTbufferIndex = 0;
int UARTbuffer[COMMAND_SIZE] = 0;

// Buffer of a page to write
int pageBufferIndex = 0;
int pageBuffer[PAGE_SIZE] = 0;

/* Description of commands:

READ x(24bit) Bytes from address y(24bit):
    b0: 'r'
    b1: x[23:16]
    b2: x[15:8]
    b3: x[7:0]
    b4: y[23:16]
    b5: y[15:8]
    b6: y[7:0]
    b7: '\n' (indicate end of command)
*/

// inits SPI by enabling SPI0 and resetting the chip
void initSPI()
{
    // already set CS high before enabling SPI0
    SpiEndTransfer();

    // enable SPI0
    int *p = (int *) 0xC0272A; // set address (SPI0 enable)
    *p = 1; // write value
    delay(10);

    // reset to get out of continuous read mode
    SpiBeginTransfer();
    SpiTransfer(0x66);
    SpiEndTransfer();
    delay(1);
    SpiBeginTransfer();
    SpiTransfer(0x99);
    SpiEndTransfer();
    delay(1);
    SpiBeginTransfer();
    SpiTransfer(0x66);
    SpiEndTransfer();
    delay(1);
    SpiBeginTransfer();
    SpiTransfer(0x99);
    SpiEndTransfer();
    delay(1);
}



// Should print 0xEF as Winbond device ID, and 0x17 for W25Q128
void readDeviceID()
{
    SpiBeginTransfer();
    SpiTransfer(0x90);
    SpiTransfer(0);
    SpiTransfer(0);
    SpiTransfer(0);
    int manufacturer = SpiTransfer(0);
    int deviceID = SpiTransfer(0);
    SpiEndTransfer();

    char buffer[10];
    itoah(manufacturer, &buffer[0]);
    uprintln(&buffer[0]);

    itoah(deviceID, &buffer[0]);
    uprintln(&buffer[0]);
}


void readAndPrint(int len, int addr24, int addr16, int addr8)
{
    int l = len;
    int a24 = addr24;
    int a16 = addr16;
    int a8 = addr8;

    SpiBeginTransfer();
    SpiTransfer(0x03);
    SpiTransfer(a24);
    SpiTransfer(a16);
    SpiTransfer(a8);


    for (int i = 0; i < l; i++)
    {
        int b = SpiTransfer(0x00);
        uprintc((char)b);
    }

    SpiEndTransfer();
}


/* Returns status register 1 2 or 3, depending on the value of reg (1, 2 or 3)

Status register description:

Register 1: (default: 0x0)
    b7: Status Register Protect 0
    b6: Sector Protect Bit
    b5: Top/Bottom Protect Bit
    b4: Block Protect Bit 2
    b3: Block Protect Bit 1
    b2: Block Protect Bit 0
    b1: Write Enable Latch
    b0: BUSY: Erase/Write in Progress

Register 2: (default: 0x2)
    b7: Suspend Status
    b6: Complement Protect
    b5: Security Register Lock bit 2
    b4: Security Register Lock bit 1
    b3: Security Register Lock bit 0
    b2: Reserved
    b1: Quad Enable
    b0: Status Register Protect 1

Register 3: (default: 0x60)
    b7: Reserved
    b6: Output Driver Strength bit 1
    b5: Output Driver Strength bit 0
    b4: Reserved
    b3: Reserved
    b2: Write Protect Selection
    b1: Reserved
    b0: Reserved


*/

int readStatusRegister(int reg)
{
    SpiBeginTransfer();

    if (reg == 2)
        SpiTransfer(0x35);
    else if (reg == 3)
        SpiTransfer(0x15);
    else
        SpiTransfer(0x05);

    int status = SpiTransfer(0);
    SpiEndTransfer();

    return status;
}



void enableWrite()
{
    SpiBeginTransfer();
    SpiTransfer(0x06);
    SpiEndTransfer();
    delay(10);
}


// Executes chip erase operation
// TAKES AT LEAST 20 SECONDS!
// Returns 1 on success
int chipErase()
{
    enableWrite();

    int status = readStatusRegister(1);

    // Check if write is enabled
    if ((status &&& 0x2) == 0)
        return 0;

    // Send command
    SpiBeginTransfer();
    SpiTransfer(0xC7);
    SpiEndTransfer();


    // Wait for busy bit to be 0
    status = 1;

    while((status &&& 0x1) == 1) 
    {
        delay(1);
        status = readStatusRegister(1);
    }

    return 1;
}



// Executes 32KiB block erase operation
// Erases the 32KiB block that contains the given byte address
// Returns 1 on success
int blockErase(int addr24, int addr16, int addr8)
{

    int a24 = addr24;
    int a16 = addr16;
    int a8 = addr8;

    enableWrite();

    int status = readStatusRegister(1);

    // Check if write is enabled
    if ((status &&& 0x2) == 0)
        return 0;

    // Send command
    SpiBeginTransfer();
    SpiTransfer(0x52);
    SpiTransfer(a24);
    SpiTransfer(a16);
    SpiTransfer(a8);
    SpiEndTransfer();


    // Wait for busy bit to be 0
    status = 1;

    while((status &&& 0x1) == 1) 
    {
        delay(1);
        status = readStatusRegister(1);
    }

    return 1;
}


// Executes 256 byte page program operation
// The address is the byte address of the first byte to write
// Data wraps around at the end of a page,
//  so last address byte will usually be 0
// Currently writes only A's to test without having to fill a buffer
// A 256 byte write buffer should be used in the future
// Returns 1 on success
int pageProgram(int addr24, int addr16, int addr8)
{

    int a24 = addr24;
    int a16 = addr16;
    int a8 = addr8;

    enableWrite();

    int status = readStatusRegister(1);

    // Check if write is enabled
    if ((status &&& 0x2) == 0)
        return 0;

    // Send command
    SpiBeginTransfer();
    SpiTransfer(0x2);
    SpiTransfer(a24);
    SpiTransfer(a16);
    SpiTransfer(a8);

    // Send page
    int *p_pageBuffer = pageBuffer;
    for (int i = 0; i < 256; i++)
    {
        SpiTransfer(*(p_pageBuffer + i));
    }

    SpiEndTransfer();


    // Wait for busy bit to be 0
    status = 1;

    while((status &&& 0x1) == 1) 
    {
        delay(1);
        status = readStatusRegister(1);
    }

    return 1;
}


void processCommand()
{
    if (currentCommand == COMMAND_IDLE)
    {
        // do nothing
    }
    else if (currentCommand == COMMAND_FLASH_READ)
    {

        int len = UARTbuffer[1] << 16;
        len += UARTbuffer[2] << 8;
        len += UARTbuffer[3];

        int addr24 = UARTbuffer[4];
        int addr16 = UARTbuffer[5];
        int addr8 = UARTbuffer[6];

        readAndPrint(len, addr24, addr16, addr8);

        currentCommand = COMMAND_IDLE;
        uprintc('r');
    }
    else if (currentCommand == COMMAND_FLASH_ERASE_BLOCK)
    {
        int addr24 = UARTbuffer[4];
        int addr16 = UARTbuffer[5];
        int addr8 = UARTbuffer[6];

        blockErase(addr24, addr16, addr8);

        currentCommand = COMMAND_IDLE;
        uprintc('r');
    }
    else if (currentCommand == COMMAND_FLASH_WRITE)
    {
        int addr24 = UARTbuffer[4];
        int addr16 = UARTbuffer[5];
        int addr8 = UARTbuffer[6];

        pageProgram(addr24, addr16, addr8);

        currentCommand = COMMAND_IDLE;
        uprintc('r');
    }
    else if (currentCommand == COMMAND_FILL_BUFFER)
    {
        // done when full page is received
        if (pageBufferIndex == PAGE_SIZE)
        {
            pageBufferIndex = 0;
            currentCommand = COMMAND_IDLE;
            uprintc('r');
        }
    }
}


int main() 
{
    
    initSPI();

    // Notify that we are ready to recieve commands
    uprintc('r');

    while (1)
    {
        processCommand();
    }

    return 48;
}

void int1()
{
    int *p = (int *) 0x4C0000; // set address (timer1 state)
    *p = 1; // write value
}

void int2()
{
   
}


void int3()
{
    // UART RX interrupt

    // Fill buffer
    if (currentCommand == COMMAND_FILL_BUFFER)
    {
        // read byte
        int *p = (int *)0xC02722;   // address of UART RX
        int b = *p;                 // read byte from UART

        // write byte to buffer, increase index
        int *p_pageBuffer = pageBuffer;
        *(p_pageBuffer + pageBufferIndex) = b;
        pageBufferIndex++;

    }
    // Get command
    else if (currentCommand == COMMAND_IDLE)
    {
        // read byte
        int *p = (int *)0xC02722;   // address of UART RX
        int b = *p;                 // read byte from UART

        // write byte to buffer, increase index
        int *p_UARTbuffer = UARTbuffer;
        *(p_UARTbuffer + UARTbufferIndex) = b;
        UARTbufferIndex++;

        // execute command when 8 bytes received
        if (UARTbufferIndex == COMMAND_SIZE)
        {
            currentCommand = *(p_UARTbuffer);
            UARTbufferIndex = 0;

            // notify ready to receive when filling buffer
            if (currentCommand == COMMAND_FILL_BUFFER)
            {
                uprintc('b');
            }
        }

    }
   
}

void int4()
{
}



