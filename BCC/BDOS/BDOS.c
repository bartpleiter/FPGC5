// Bart's Drive Operating System(BDOS)
/* TODO:
- Reimplement (and optimize?!) using BCC
- Implement more Syscalls (network?)
- More shell functionality (folders, copy, move, etc.)
*/

// As of writing, BCC assigns 4 memory addresses to ints, so we should use chars instead
// However, this is confusing, so we typedef it to word, since that is what it basically is
#define word char

// Flag that indicates whether a user program is running
// Defined above the defines, so netloader and shell can also access it
word UserprogramRunning = 0;

// These functions are used by some of the other libraries
void BDOS_Backup();
void BDOS_Restore();

// Note that these directories are relative to the directory from this file
#include "lib/math.c"
#include "lib/gfx.c"
#include "lib/stdlib.c"


/* TODO: convert to BCC
#include "data/ASCII_BW.h"
#include "lib/fs.h"
#include "lib/hidfifo.h"
#include "lib/ps2.h"
#include "lib/usbkeyboard.h"
#include "lib/wiz5500.h"
#include "lib/netloader.h"
#include "lib/shell.h"
*/


// Data includes
#include "data/ASCII_BW.c"


// Address of loaded user program
#define RUN_ADDR 0x400000

// Temp address for (potentially) large temporary outputs/buffers
// eg: output of listDir or print chunks. 
#define TEMP_ADDR 0x200000

// Syscalls use the same tmp address for input and output
#define SYSCALL_RETVAL_ADDR 0x200000

// Interrupt IDs for extended interrupt handler
#define INTID_TIMER2 0x0
#define INTID_TIMER3 0x1
#define INTID_PS2 0x2
#define INTID_UART1 0x3
#define INTID_UART2 0x4


// Initializes CH376 and mounts drive
// returns 1 on success
word BDOS_Init_FS()
{
    /*
    if (FS_init() != ANSW_RET_SUCCESS)
    {
        GFX_PrintConsole("Error initializing CH376 for FS");
        return 0;
    }

    delay(10);

    if (FS_connectDrive() != ANSW_USB_INT_SUCCESS)
    {
        GFX_PrintConsole("Could not mount drive");
        return 0;
    }
    return 1;
    */
}

void BDOS_Reinit_VRAM()
{
    GFX_initVram(); // clear all VRAM
    GFX_copyPaletteTable((word)DATA_PALETTE_DEFAULT);
    GFX_copyPatternTable((word)DATA_ASCII_DEFAULT);

    GFX_cursor = 0;
}

void BDOS_Backup()
{
    // TODO look into what to backup
}

void BDOS_Restore()
{
    /*
    // Restore graphics (trying to keep text in window plane)
    GFX_copyPaletteTable((int)DATA_PALETTE_DEFAULT);
    GFX_copyPatternTable((int)DATA_ASCII_DEFAULT);
    GFX_clearBGtileTable();
    GFX_clearBGpaletteTable();
    GFX_clearWindowpaletteTable();
    GFX_clearSprites();

    // Restore netloader
    NETLOADER_init(NETLOADER_SOCKET);
    */
}




int main() 
{
    // Indicate that no user program is running
    UserprogramRunning = 0;

    // Start with loading ASCII table and set palette
    BDOS_Reinit_VRAM();
    
    // Print welcome message
    GFX_PrintConsole("BDOS\n");

    GFX_printWindowColored("Hello", 5, 81, 1);
    GFX_printBGColored("TEST123", 7, 130, 2);


    hexdump(0, 128);

    /*

    NETLOADER_init(NETLOADER_SOCKET);

    // Init file system
    if (!BDOS_Init_FS())
        return 0;

    // Init USB keyboard driver
    USBkeyboard_init();

    // Init shell
    SHELL_init();

    // Main loop
    while (1)
    {
        // Block when downloading file
        if (NETLOADER_transferState == NETLOADER_STATE_USB_DATA)
        {
            GFX_PrintConsole("Downloading file");
            while (NETLOADER_transferState == NETLOADER_STATE_USB_DATA)
            {
                NETLOADER_loop(NETLOADER_SOCKET);
                GFX_PrintcConsole('.');
            }
            GFX_PrintConsole("Done!\n");

            // New shell line
            char* p = (char *) SHELL_CMD_ADDR;
            // clear buffer
            p[0] = 0;
            SHELL_commandIdx = 0;
            // print shell prompt
            SHELL_print_prompt();

        }
        SHELL_loop();
        NETLOADER_loop(NETLOADER_SOCKET);

        // If we received a program, run it and print shell prompt afterwards
        if (NETLOADER_checkDone())
        {
            BDOS_Restore();
            SHELL_print_prompt();
        }
    }

    */
    return 0;
}


// System call handler
/* Syscall table:
0 - Nothing
1 - HID_FifoAvailable
2 - HID_FifoRead
3 - GFX_PrintcConsole
4 - Get arguments
*/
void syscall()
{
    word* p = (word*) SYSCALL_RETVAL_ADDR;
    word ID = p[0];

    /*

    // HID_FifoAvailable()
    if (ID == 1)
    {
        word x = HID_FifoAvailable();
        p[0] = x;
    }
    // HID_FifoRead()
    else if (ID == 2)
    {
        word x = HID_FifoRead();
        p[0] = x;
    }
    // GFX_PrintcConsole()
    else if (ID == 3)
    {
        GFX_PrintcConsole(p[1]);
        p[0] = 0;
    }
    // Get arguments
    else if (ID == 4)
    {
        p[0] = SHELL_CMD_ADDR;
    }
    // Get path (backup)
    else if (ID == 5)
    {
        p[0] = SHELL_PATH_BACKUP;
    }
    else
    {
        p[0] = 0;
    }
    */
}

// timer1 interrupt handler
void int1()
{
    
    timer1Value = 1; // notify ending of timer1 (in BDOS)

    /*
    // Check if a user program is running
    if (UserprogramRunning)
    {
        // Call int1() of user program
        ASM("\
        push r1 ;\
        push r2 ;\
        push r3 ;\
        push r4 ;\
        push r5 ;\
        push r6 ;\
        push r7 ;\
        push r8 ;\
        push r9 ;\
        push r10 ;\
        push r11 ;\
        push r12 ;\
        push r13 ;\
        push rbp ;\
        push rsp ;\
        load32 0x400001 r2 ;\
        savpc r1 ;\
        push r1 ;\
        jumpr 0 r2 ;\
        pop rsp ;\
        pop rbp ;\
        pop r13 ;\
        pop r12 ;\
        pop r11 ;\
        pop r10 ;\
        pop r9 ;\
        pop r8 ;\
        pop r7 ;\
        pop r6 ;\
        pop r5 ;\
        pop r4 ;\
        pop r3 ;\
        pop r2 ;\
        pop r1 ;\
        ");
        return;
    }
    else
    {
        
    }
    */
}

// extended interrupt handler
void int2()
{
    /*
    int i = getIntID();
    if (i == INTID_PS2)
    {
        // handle PS2 interrupt
        PS2_HandleInterrupt();
    }
    else if (i == INTID_TIMER2)
    {
        // handle USB keyboard interrupt
        USBkeyboard_HandleInterrupt();
    }


    // Check if a user program is running
    if (UserprogramRunning)
    {
        // Call int2() of user program
        ASM("\
        push r1 ;\
        push r2 ;\
        push r3 ;\
        push r4 ;\
        push r5 ;\
        push r6 ;\
        push r7 ;\
        push r8 ;\
        push r9 ;\
        push r10 ;\
        push r11 ;\
        push r12 ;\
        push r13 ;\
        push rbp ;\
        push rsp ;\
        load32 0x400002 r2 ;\
        savpc r1 ;\
        push r1 ;\
        jumpr 0 r2 ;\
        pop rsp ;\
        pop rbp ;\
        pop r13 ;\
        pop r12 ;\
        pop r11 ;\
        pop r10 ;\
        pop r9 ;\
        pop r8 ;\
        pop r7 ;\
        pop r6 ;\
        pop r5 ;\
        pop r4 ;\
        pop r3 ;\
        pop r2 ;\
        pop r1 ;\
        ");
        return;
    }
    else
    {
        
    }
    */

    
}

// UART0 interrupt handler
void int3()
{
    /*
    // Check if a user program is running
    if (UserprogramRunning)
    {
        // Call int3() of user program
        ASM("\
        push r1 ;\
        push r2 ;\
        push r3 ;\
        push r4 ;\
        push r5 ;\
        push r6 ;\
        push r7 ;\
        push r8 ;\
        push r9 ;\
        push r10 ;\
        push r11 ;\
        push r12 ;\
        push r13 ;\
        push rbp ;\
        push rsp ;\
        load32 0x400003 r2 ;\
        savpc r1 ;\
        push r1 ;\
        jumpr 0 r2 ;\
        pop rsp ;\
        pop rbp ;\
        pop r13 ;\
        pop r12 ;\
        pop r11 ;\
        pop r10 ;\
        pop r9 ;\
        pop r8 ;\
        pop r7 ;\
        pop r6 ;\
        pop r5 ;\
        pop r4 ;\
        pop r3 ;\
        pop r2 ;\
        pop r1 ;\
        ");
        return;
    }
    else
    {
        
    }
    */
}

// GFX framedrawn interrupt handler
void int4()
{
    /*
    // Check if a user program is running
    if (UserprogramRunning)
    {
        // Call int4() of user program
        ASM("\
        push r1 ;\
        push r2 ;\
        push r3 ;\
        push r4 ;\
        push r5 ;\
        push r6 ;\
        push r7 ;\
        push r8 ;\
        push r9 ;\
        push r10 ;\
        push r11 ;\
        push r12 ;\
        push r13 ;\
        push rbp ;\
        push rsp ;\
        load32 0x400004 r2 ;\
        savpc r1 ;\
        push r1 ;\
        jumpr 0 r2 ;\
        pop rsp ;\
        pop rbp ;\
        pop r13 ;\
        pop r12 ;\
        pop r11 ;\
        pop r10 ;\
        pop r9 ;\
        pop r8 ;\
        pop r7 ;\
        pop r6 ;\
        pop r5 ;\
        pop r4 ;\
        pop r3 ;\
        pop r2 ;\
        pop r1 ;\
        ");
        return;
    }
    else
    {
        
    }
    */
}