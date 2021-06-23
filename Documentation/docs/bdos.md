# BDOS
BDOS (or Barts Drive Operating System) is a single-tasking operating system for the FPGC5 written in C and assembly. Its goal is to provide a user interface (shell) to load programs from storage an to do other basic drive operations. These programs still have full access to all hardware as if it is running on bare metal. The only difference is that the program is ran from `0x400000` instead of `0x000000` and that interrupts first go through BDOS before reaching the program. Therefore, some compiler changes will need to be made for running programs on BDOS. Furthermore, BDOS user programs have access to the OS via system calls. These system calls can be used, for example, to get HID inputs from the HID FIFO, or to print characters to the shell. While technically not required, they do make the programs a lot simpler.

While this is definitely not a complex OS like Linux or Windows, it does add a lot of functionality to the FPGC5. Mainly the shell and the ability to load programs from USB and Network are a huge step-up over the MCU-like programming experience where you can only run one program until it is reprogrammed.

## Functionality
Currently, with BDOS you can:
- Navigate and do other operations on the file system on a USB drive using the shell
- Run programs from the file system
- Run programs sent over the network
- Use a PS/2 keyboard and/or USB keyboard to interface with shell
- Use system calls in your user programs
- Return to BDOS after a user program terminates (sucessfully)

### Future ideas
Features that I might want to implement in the future:
- History of commands (in file?), so I can use the arrow keys
- Path of executables that can be directly executed without RUN command
- Download a sent file from the network to the USB drive, using the headers of the network frame (!)


## Memory Map
BDOS has its own layout of the 32MiB SDRAM, which you can see here. Note: addresses are 32 bit

``` text
SDRAM
$000000 +------------------------+
        |                        | 
        |    BDOS Program Code   | 
        |                        | $0FFFFF
$100000 +------------------------+ 
        |                        |
        |    BDOS Heap Memory    |
        |                        | $1FFFFF
$200000 +------------------------+
        |                        | 
        |   TMP Output Buffer    |
        |           &            |
        | Syscall Arg + Retval   |
        |           &            |
        | Syscall Stack (at end) | $3FFFFF
$400000 +------------------------+ 
        |                        | 
        |   User Program Memory  | 
        |           &            |
        |User Main Stack (at end)|
        |                        | $73FFFF
$740000 +------------------------+ 
        |                        | 
        |BDOS Main Stack (at end)|
        |                        | $77FFFF
$780000 +------------------------+ 
        |                        | 
        | User Int Stack (at end)|
        |                        | $7BFFFF
$7C0000 +------------------------+ 
        |                        | 
        | BDOS Int Stack (at end)|
        |                        | $7FFFFF
        +------------------------+ 

```


## BDOS OS Libraries
BDOS has it own set of libraries and data, which you can see in the `Ccompiler/BDOS/` folder. These are not accessable to user programs. Those have their own set of libraries.

### gfx.h
The graphics library provides, on top of the basic functions from the general C library, functionality to write characters to screen as if it was a console. This means that the screen scrolls vertically when the last line is written. A cursor is also kept in memory. Newlines and backspaces are also supported.

### ps2.h
The PS2 keyboard library provides an interrupt handler for extracting keypresses from scancodes. It can handle shifted keys and extended keys. See ps2.h for more details on what is supported and what is not.

### usbkeyboard.h
A library for reading keypresses from an USB keyboard. AFAIK it currently only works for some USB2.0 keyboards. The top USB port is used for this. The keyboard is polled using a timer.

### hidfifo.h
A FIFO for storing keypresses from PS/2, USB keyboard and SNES controller. The shell can read these key presses without needing to know from which device.

### stdlib.h
Provides basic functions and the blocking delay() function using timer1.

### math.h
Provides very very basic math operations which are not efficiently implemented at all.

### fs.h
Provides functionality for operating the filesystem on a flash drive in the bottom usb port.

### wiz5500.h
Provides functionality for operating the Wiznet W5500 chip. Supports eight sockets.

### netloader.h
A network based bootloader using the wiz5500.h library.

### shell.h
Provides the implementation of the shell for operating the system.


## BDOS user program libraries
User programs have their own set of libraries and data, which you can see in the `Ccompiler/userBDOS/` folder. While mostly similar to the BDOS libraries, some libraries like HID related drivers and the shell are removed or different, since those are only useful for the OS or should be called using system calls. Most importantly, there is a library `sys.h` that allows for system calls to BDOS.
