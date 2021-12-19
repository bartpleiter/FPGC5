// Flash programmer
// Tool to flash the SPI flash chip

#define word char

#include "data/ASCII_BW.c"
#include "lib/math.c"
#include "lib/stdlib.c"
#include "lib/gfx.c"


#define COMMAND_IDLE                    0
#define COMMAND_FLASH_READ              114 // 'r'
#define COMMAND_FLASH_ERASE_BLOCK       101 // 'e'
#define COMMAND_FLASH_WRITE             119 // 'w'
#define COMMAND_FILL_BUFFER             98  // 'b'
#define COMMAND_DONE                    100 // 'd'

#define BLOCK_SIZE 32768
#define SECTOR_SIZE 4096
#define PAGE_SIZE 256
#define COMMAND_SIZE 8


// the current command the program is busy with
// if idle, should listen to UART for new command
word currentCommand;

// UART buffer that stores a single command
word UARTbufferIndex = 0;
word UARTbuffer[COMMAND_SIZE];

// Buffer of a page to write
word pageBufferIndex = 0;
word pageBuffer[PAGE_SIZE];

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

void initVram()
{
    GFX_initVram(); // clear all VRAM
    GFX_copyPaletteTable((word)DATA_PALETTE_DEFAULT);
    GFX_copyPatternTable((word)DATA_ASCII_DEFAULT);

    GFX_cursor = 0;
}

// Workaround for defines in ASM
void SpiFlash_asmDefines()
{
    asm(
        "define W5500_SPI0_CS_ADDR = 0xC02729 ; address of SPI0_CS\n"
        "define W5500_SPI0_ADDR = 0xC02728    ; address of SPI0\n"
        );
}

// Sets SPI0_CS low
void SpiBeginTransfer()
{
    asm(
        "; backup regs\n"
        "push r1\n"
        "push r2\n"

        "load32 W5500_SPI0_CS_ADDR r2       ; r2 = W5500_SPI0_CS_ADDR\n"

        "load 0 r1                          ; r1 = 0 (enable)\n"
        "write 0 r2 r1                      ; write to SPI0_CS\n"

        "; restore regs\n"
        "pop r2\n"
        "pop r1\n"
        );
}

// Sets SPI0_CS high
void SpiEndTransfer()
{
    asm(
        "; backup regs\n"
        "push r1\n"
        "push r2\n"

        "load32 W5500_SPI0_CS_ADDR r2       ; r2 = W5500_SPI0_CS_ADDR\n"

        "load 1 r1                          ; r1 = 1 (disable)\n"
        "write 0 r2 r1                      ; write to SPI0_CS\n"

        "; restore regs\n"
        "pop r2\n"
        "pop r1\n"
        );
}

// write dataByte and return read value
// write 0x00 for a read
// Writes byte over SPI0
word SpiTransfer(word dataByte)
{
    word retval = 0;
    asm(
        "load32 W5500_SPI0_ADDR r2          ; r2 = W5500_SPI0_ADDR\n"
        "write 0 r2 r4                      ; write r4 over SPI0\n"
        "read 0 r2 r2                       ; read return value\n"
        "write -4 r14 r2                    ; write to stack to return\n"
        );

    return retval;
}



// inits SPI by enabling SPI0 and resetting the chip
void initSPI()
{
    // already set CS high before enabling SPI0
    SpiEndTransfer();

    // enable SPI0
    word *p = (word *) 0xC0272A; // set address (SPI0 enable)
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
    word manufacturer = SpiTransfer(0);
    word deviceID = SpiTransfer(0);
    SpiEndTransfer();

    char b[10];
    itoah(manufacturer, b);
    GFX_PrintConsole("Chip manufacturer: ");
    GFX_PrintConsole(b);
    GFX_PrintConsole("\n");

    GFX_PrintConsole("Chip ID: ");
    itoah(deviceID, b);
    GFX_PrintConsole(b);
    GFX_PrintConsole("\n");
}


void readAndPrint(word len, word addr24, word addr16, word addr8)
{
    word l = len;
    word a24 = addr24;
    word a16 = addr16;
    word a8 = addr8;

    SpiBeginTransfer();
    SpiTransfer(0x03);
    SpiTransfer(a24);
    SpiTransfer(a16);
    SpiTransfer(a8);


    word i;
    for (i = 0; i < l; i++)
    {
        uprintc(SpiTransfer(0x00));
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

word readStatusRegister(word reg)
{
    SpiBeginTransfer();

    if (reg == 2)
        SpiTransfer(0x35);
    else if (reg == 3)
        SpiTransfer(0x15);
    else
        SpiTransfer(0x05);

    word status = SpiTransfer(0);
    SpiEndTransfer();

    return status;
}



void enableWrite()
{
    SpiBeginTransfer();
    SpiTransfer(0x06);
    SpiEndTransfer();
}


// Executes chip erase operation
// TAKES AT LEAST 20 SECONDS!
// Returns 1 on success
word chipErase()
{
    enableWrite();

    word status = readStatusRegister(1);

    // Check if write is enabled
    if ((status & 0x2) == 0)
        return 0;

    // Send command
    SpiBeginTransfer();
    SpiTransfer(0xC7);
    SpiEndTransfer();


    // Wait for busy bit to be 0
    status = 1;

    while((status & 0x1) == 1) 
    {
        status = readStatusRegister(1);
    }

    return 1;
}



// Executes 32KiB block erase operation
// Erases the 32KiB block that contains the given byte address
// Returns 1 on success
word blockErase(word addr24, word addr16, word addr8)
{

    word a24 = addr24;
    word a16 = addr16;
    word a8 = addr8;

    enableWrite();

    word status = readStatusRegister(1);

    // Check if write is enabled
    if ((status & 0x2) == 0)
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

    while((status & 0x1) == 1) 
    {
        status = readStatusRegister(1);
    }

    return 1;
}


// Executes 256 byte page program operation
// The address is the byte address of the first byte to write
// Data wraps around at the end of a page,
//  so last address byte will usually be 0
// Returns 1 on success
word pageProgram(word addr24, word addr16, word addr8)
{

    word a24 = addr24;
    word a16 = addr16;
    word a8 = addr8;

    enableWrite();

    word status = readStatusRegister(1);

    // Check if write is enabled
    if ((status & 0x2) == 0)
        return 0;

    // Send command
    SpiBeginTransfer();
    SpiTransfer(0x2);
    SpiTransfer(a24);
    SpiTransfer(a16);
    SpiTransfer(a8);

    // Send page
    word *p_pageBuffer = pageBuffer;
    word i;
    for (i = 0; i < 256; i++)
    {
        SpiTransfer(*(p_pageBuffer + i));
    }

    SpiEndTransfer();


    // Wait for busy bit to be 0
    status = 1;

    while((status & 0x1) == 1) 
    {
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

        word len = UARTbuffer[1] << 16;
        len += UARTbuffer[2] << 8;
        len += UARTbuffer[3];

        word addr24 = UARTbuffer[4];
        word addr16 = UARTbuffer[5];
        word addr8 = UARTbuffer[6];

        GFX_printWindowColored("                                        ", 40, GFX_WindowPosFromXY(0, 8), 0);
        GFX_printWindowColored("Reading ", 8, GFX_WindowPosFromXY(0, 8), 0);
        char b[10];
        itoa(len, b);
        GFX_printWindowColored(b, strlen(b), GFX_WindowPosFromXY(8, 8), 0);
        GFX_printWindowColored(" bytes", 6, GFX_WindowPosFromXY(8 + strlen(b), 8), 0);

        readAndPrint(len, addr24, addr16, addr8);

        GFX_printWindowColored(" done!", 5, GFX_WindowPosFromXY(8 + strlen(b) + 6, 8), 0);

        currentCommand = COMMAND_IDLE;
        uprintc('r');
    }
    else if (currentCommand == COMMAND_FLASH_ERASE_BLOCK)
    {
        word addr24 = UARTbuffer[4];
        word addr16 = UARTbuffer[5];
        word addr8 = UARTbuffer[6];

        blockErase(addr24, addr16, addr8);
        word addrCombined = ((addr24 << 16) + (addr16 << 8) + addr8) >> 15;

        GFX_printWindowColored("                                        ", 40, GFX_WindowPosFromXY(0, 8), 0);
        GFX_printWindowColored("Block ", 6, GFX_WindowPosFromXY(0, 8), 0);
        char b[10];
        itoa(addrCombined, b);
        GFX_printWindowColored(b, strlen(b), GFX_WindowPosFromXY(6, 8), 0);
        GFX_printWindowColored(" erased", 7, GFX_WindowPosFromXY(6 + strlen(b), 8), 0);

        currentCommand = COMMAND_IDLE;
        uprintc('r');
    }
    else if (currentCommand == COMMAND_FLASH_WRITE)
    {
        word addr24 = UARTbuffer[4];
        word addr16 = UARTbuffer[5];
        word addr8 = UARTbuffer[6];

        pageProgram(addr24, addr16, addr8);
        word addrCombined = (addr24 << 8) + addr16;

        GFX_printWindowColored("                                        ", 40, GFX_WindowPosFromXY(0, 8), 0);
        GFX_printWindowColored("Page ", 5, GFX_WindowPosFromXY(0, 8), 0);
        char b[10];
        itoa(addrCombined, b);
        GFX_printWindowColored(b, strlen(b), GFX_WindowPosFromXY(5, 8), 0);
        GFX_printWindowColored(" written", 8, GFX_WindowPosFromXY(5 + strlen(b), 8), 0);

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
    else if (currentCommand == COMMAND_DONE)
    {
        // notify done
        GFX_printWindowColored("                                        ", 40, GFX_WindowPosFromXY(0, 6), 0);
        GFX_printWindowColored("                                        ", 40, GFX_WindowPosFromXY(0, 8), 0);
        GFX_printWindowColored("Done!", 5, GFX_WindowPosFromXY(0, 6), 0);

        // allow new commands, just in case
        currentCommand = COMMAND_IDLE;
    }
}


int main() 
{
    initVram();
    GFX_PrintConsole("Flash Programmer\n\n");

    currentCommand = COMMAND_IDLE;

    initSPI();
    GFX_PrintConsole("SPI0 mode set\n");

    readDeviceID();


    GFX_PrintConsole("\nReady to receive commands\n\n");
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
    /*
    word *p = (word *) 0x4C0000; // set address (timer1 state)
    *p = 1; // write value
    */
    timer1Value = 1; // notify ending of timer1
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
        word *p = (word *)0xC02722;   // address of UART RX
        word b = *p;                 // read byte from UART

        // write byte to buffer, increase index
        word *p_pageBuffer = pageBuffer;
        *(p_pageBuffer + pageBufferIndex) = b;
        pageBufferIndex++;

    }
    // Get command
    else if (currentCommand == COMMAND_IDLE)
    {
        // read byte
        word *p = (word *)0xC02722;   // address of UART RX
        word b = *p;                 // read byte from UART

        // write byte to buffer, increase index
        word *p_UARTbuffer = UARTbuffer;
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

