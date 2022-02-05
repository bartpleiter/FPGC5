/* Bart's Drive Operating System(BDOS)
* A relatively simple OS that allows for some basic features including:
* - Running a single user program with full hardware control
* - Some system calls
* - A basic shell
* - Network loaders for sending data and controlling the FPGC
* - HID fifo including USB keyboard driver
*/


/* List of reserved stuff:
- Timer2 is used for USB keyboard polling, even when a user program is running
- Socket 7 is used for netHID
*/


/*
* Defines (also might be used by included libraries below)
*/

// As of writing, BCC assigns 4 memory addresses to ints, so we should use chars instead
// However, this is confusing, so we typedef it to word, since that is what it basically is
#define word char

#define SYSCALL_RETVAL_ADDR 0x200000    // address for system call communication with user program
#define FS_LDIR_FNAME_ADDR  0x210000    // address for filename list in ldir command
#define FS_LDIR_FSIZE_ADDR  0x218000    // address for filesize list in ldir command
#define TEMP_ADDR           0x220000    // address for (potentially) large temporary outputs/buffers
#define RUN_ADDR            0x400000    // address of loaded user program

#define FS_PATH_MAX_LENGHT  256         // max length of a path

// Interrupt IDs for extended interrupt handler
#define INTID_TIMER2  0x0
#define INTID_TIMER3  0x1
#define INTID_PS2     0x2
#define INTID_UART1   0x3
#define INTID_UART2   0x4

// System call IDs
#define SYSCALL_FIFO_AVAILABLE  1
#define SYSCALL_FIFO_READ       2
#define SYSCALL_PRINT_C_CONSOLE 3
#define SYSCALL_GET_ARGS        4 // get arguments for executed program
#define SYSCALL_GET_PATH        5 // get OS path
#define SYSCALL_GET_USB_KB_BUF  6 // get the 8 bytes of the USB keyboard buffer


/*
* Global vars (also might be used by included libraries below)
*/

// Flag that indicates whether a user program is running
word BDOS_userprogramRunning = 0;

// Path variable and its backup variable
char SHELL_path[FS_PATH_MAX_LENGHT];
char SHELL_pathBackup[FS_PATH_MAX_LENGHT];


/*
* Function prototypes, so they can be called in all libraries below
*/

// These functions are used by some of the other libraries
void BDOS_Backup();
void BDOS_Restore();
void SHELL_clearCommand();


/*
* Included libraries
*/

// Data includes
#include "data/ASCII_BW.c"
#include "data/PS2SCANCODES.c"
#include "data/USBSCANCODES.c"

// Code includes
#include "lib/stdlib.c"
#include "lib/math.c"
#include "lib/gfx.c"
#include "lib/hidfifo.c"
#include "lib/ps2.c"
#include "lib/usbkeyboard.c"
#include "lib/fs.c"
#include "lib/wiz5500.c"
#include "lib/netloader.c"
#include "lib/nethid.c"
#include "lib/shell.c"


/*
* Functions
*/

// Initializes CH376 and mounts drive
// returns 1 on success
word BDOS_Init_FS()
{
    if (FS_init() != FS_ANSW_RET_SUCCESS)
    {
        GFX_PrintConsole("Error initializing CH376 for FS");
        return 0;
    }

    delay(10);

    if (FS_connectDrive() != FS_ANSW_USB_INT_SUCCESS)
    {
        GFX_PrintConsole("Could not mount drive");
        return 0;
    }
    return 1;
}

// Clears all VRAM
//  and copies the default ASCII pattern table and palette table
// also resets the cursor
void BDOS_Reinit_VRAM()
{
    GFX_initVram();
    GFX_copyPaletteTable((word)DATA_PALETTE_DEFAULT);
    GFX_copyPatternTable((word)DATA_ASCII_DEFAULT);
    GFX_cursor = 0;
}

// Initialize the W5500
void BDOS_initNetwork()
{
    word ip_addr[4] = {192, 168, 0, 213};

    word gateway_addr[4] = {192, 168, 0, 1};

    word mac_addr[6] = {0xDE, 0xAD, 0xBE, 0xEF, 0x24, 0x64};

    word sub_mask[4] = {255, 255, 255, 0};

    wiz_Init(ip_addr, gateway_addr, mac_addr, sub_mask);
}

// Backup important things before running a user program
void BDOS_Backup()
{
    // TODO look into what to backup
}

// Restores certain things when returning from a user program
void BDOS_Restore()
{
    // restore graphics (trying to keep text in window plane)
    GFX_copyPaletteTable((word)DATA_PALETTE_DEFAULT);
    GFX_copyPatternTable((word)DATA_ASCII_DEFAULT);
    GFX_clearBGtileTable();
    GFX_clearBGpaletteTable();
    GFX_clearWindowpaletteTable();
    GFX_clearSprites();

    // restore netloader
    NETLOADER_init(NETLOADER_SOCKET);
}

// Main BDOS code
int main() 
{
    // all kinds of initialisations

    BDOS_userprogramRunning = 0; // indicate that no user program is running

    BDOS_Reinit_VRAM(); // start with loading ASCII table and set palette
    
    GFX_PrintConsole("Starting BDOS\n"); // print welcome message

    GFX_PrintConsole("Init network...");
    BDOS_initNetwork();
    GFX_PrintConsole("DONE\n");

    GFX_PrintConsole("Init netloader...");
    NETLOADER_init(NETLOADER_SOCKET);
    GFX_PrintConsole("DONE\n");

    GFX_PrintConsole("Init netHID...");
    NETHID_init(NETHID_SOCKET);
    GFX_PrintConsole("DONE\n");

    GFX_PrintConsole("Init USB keyboard...");
    USBkeyboard_init();
    GFX_PrintConsole("DONE\n");

    GFX_PrintConsole("Init filesystem...");
    if (!BDOS_Init_FS())
        return 0;
    GFX_PrintConsole("DONE\n");

    // init shell
    SHELL_init();

    // main loop
    while (1)
    {
        SHELL_loop();                       // update the shell state
        NETLOADER_loop(NETLOADER_SOCKET);   // update the netloader state
    }

    return 1;
}


// System call handler
// Returns at the same address it reads the command from
void syscall()
{
    word* p = (word*) SYSCALL_RETVAL_ADDR;
    word ID = p[0];

    switch(ID)
    {
        case SYSCALL_FIFO_AVAILABLE:
            p[0] = HID_FifoAvailable();
            break;
        case SYSCALL_FIFO_READ:
            p[0] = HID_FifoRead();
            break;
        case SYSCALL_PRINT_C_CONSOLE:
            GFX_PrintcConsole(p[1]);
            p[0] = 0;
            break;
        case SYSCALL_GET_ARGS:
            p[0] = SHELL_command;
            break;
        case SYSCALL_GET_PATH:
            p[0] = SHELL_pathBackup;
            break;
        case SYSCALL_GET_USB_KB_BUF:
            p[0] = USBkeyboard_buffer_parsed;
            break;
        default:
            p[0] = 0;
            break;
    }
}

// Timer1 interrupt handler
void int1()
{
    timer1Value = 1; // notify ending of timer1

    // check if a user program is running
    if (BDOS_userprogramRunning)
    {
        // call int1() of user program
        asm(
            "; backup registers\n"
            "push r1\n"
            "push r2\n"
            "push r3\n"
            "push r4\n"
            "push r5\n"
            "push r6\n"
            "push r7\n"
            "push r8\n"
            "push r9\n"
            "push r10\n"
            "push r11\n"
            "push r12\n"
            "push r13\n"
            "push r14\n"
            "push r15\n"

            "savpc r1\n"
            "push r1\n"
            "jump 0x400001\n"

            "; restore registers\n"
            "pop r15\n"
            "pop r14\n"
            "pop r13\n"
            "pop r12\n"
            "pop r11\n"
            "pop r10\n"
            "pop r9\n"
            "pop r8\n"
            "pop r7\n"
            "pop r6\n"
            "pop r5\n"
            "pop r4\n"
            "pop r3\n"
            "pop r2\n"
            "pop r1\n"
            );
        return;
    }
    else // code to only run when not running a user program
    {
        
    }
}

// Extended interrupt handler
// use getIntID to get the id of the interrupt
void int2()
{
    int i = getIntID();
    switch(i)
    {
        case INTID_PS2:
            PS2_HandleInterrupt(); // handle PS2 interrupt
            break;

        case INTID_TIMER2:
            USBkeyboard_HandleInterrupt(); // handle USB keyboard interrupt
            break;
    }

    // check if a user program is running
    if (BDOS_userprogramRunning)
    {
        // call int2() of user program
        asm(
            "; backup registers\n"
            "push r1\n"
            "push r2\n"
            "push r3\n"
            "push r4\n"
            "push r5\n"
            "push r6\n"
            "push r7\n"
            "push r8\n"
            "push r9\n"
            "push r10\n"
            "push r11\n"
            "push r12\n"
            "push r13\n"
            "push r14\n"
            "push r15\n"

            "savpc r1\n"
            "push r1\n"
            "jump 0x400002\n"

            "; restore registers\n"
            "pop r15\n"
            "pop r14\n"
            "pop r13\n"
            "pop r12\n"
            "pop r11\n"
            "pop r10\n"
            "pop r9\n"
            "pop r8\n"
            "pop r7\n"
            "pop r6\n"
            "pop r5\n"
            "pop r4\n"
            "pop r3\n"
            "pop r2\n"
            "pop r1\n"
            );
        return;
    }
    else // code to only run when not running a user program
    {
        
    }
}

// UART0 (TTYUSB) interrupt handler
void int3()
{
    // check if a user program is running
    if (BDOS_userprogramRunning)
    {
        // call int3() of user program
        asm(
            "; backup registers\n"
            "push r1\n"
            "push r2\n"
            "push r3\n"
            "push r4\n"
            "push r5\n"
            "push r6\n"
            "push r7\n"
            "push r8\n"
            "push r9\n"
            "push r10\n"
            "push r11\n"
            "push r12\n"
            "push r13\n"
            "push r14\n"
            "push r15\n"

            "savpc r1\n"
            "push r1\n"
            "jump 0x400003\n"

            "; restore registers\n"
            "pop r15\n"
            "pop r14\n"
            "pop r13\n"
            "pop r12\n"
            "pop r11\n"
            "pop r10\n"
            "pop r9\n"
            "pop r8\n"
            "pop r7\n"
            "pop r6\n"
            "pop r5\n"
            "pop r4\n"
            "pop r3\n"
            "pop r2\n"
            "pop r1\n"
            );
        return;
    }
    else // code to only run when not running a user program
    {
        
    }
}

// GFX framedrawn interrupt handler
// is called every frame, which is ~60 times per second
void int4()
{
    if (NETHID_isInitialized == 1)
    {
        // check using CS if we are not interrupting any critical access to the W5500
        word* spi3ChipSelect = (word*) 0xC02732;
        if (*spi3ChipSelect == 1)
        {
            NETHID_loop(NETHID_SOCKET); // look for an input sent to netHID
        }
    }

    // check if a user program is running
    if (BDOS_userprogramRunning)
    {
        // call int4() of user program
        asm(
            "; backup registers\n"
            "push r1\n"
            "push r2\n"
            "push r3\n"
            "push r4\n"
            "push r5\n"
            "push r6\n"
            "push r7\n"
            "push r8\n"
            "push r9\n"
            "push r10\n"
            "push r11\n"
            "push r12\n"
            "push r13\n"
            "push r14\n"
            "push r15\n"

            "savpc r1\n"
            "push r1\n"
            "jump 0x400004\n"

            "; restore registers\n"
            "pop r15\n"
            "pop r14\n"
            "pop r13\n"
            "pop r12\n"
            "pop r11\n"
            "pop r10\n"
            "pop r9\n"
            "pop r8\n"
            "pop r7\n"
            "pop r6\n"
            "pop r5\n"
            "pop r4\n"
            "pop r3\n"
            "pop r2\n"
            "pop r1\n"
            );
        return;
    }
    else // code to only run when not running a user program
    {
        
    }
}