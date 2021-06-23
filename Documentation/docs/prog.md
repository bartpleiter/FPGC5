# Programmer

The Programmer folder contains all files related to programming the FPGC4 and the SPI flash. 

The compileROM.sh script converts the code.list file, the file with machine instructions in text, to a binary (code.bin) file. The file size will be a multiple of 4096 bytes, because the old external SPI flash programmer expects a file of this size. 

!!! info "TODO"
	Since the new SPI flash programmer does not have this restriction, this can be removed but should be tested first to make sure writing half a page does not break anything.

The final command in compileROM.sh sends the binary over UART to the FPGC4 using uartFlasher.py.

!!! info "TODO"
	Update the script to accept arguments, so you can choose to send it over UART (with a Windows verion option as well), program it to the SPI flash, or don't program it at all and write it to spi.txt for the Verilog simulator

## flash.py
To write a binary to the SPI flash, you can use the flash.py script. It uploads an SPI flasher binary to the FPGC4, which then accepts commands over UART and executes them to do operations on the SPI flash chip. This allows programming the SPI flash without the use of an external programmer. Currently it can erase, read and write the flash memory. When writing a binary and the verify argument is specified, the script will read the binary after writing to verify that the flash was successful (by comparing the two binary files using 'diff').

## uartFlasher.py
Since the second version of the I/O Board PCB, the SPI flash chip is not removable anymore. This means that using the UART interface remains the only way to send a program to the FPGC4. Therefore, I have added the UART bootloader code to the internal ROM of the FPGC4, which will be copied to SDRAM and executed when SPI boot is disabled.

The UART flasher script is used to send a binary file to the FPGC4 over UART (via the USB port) with a 115200 baud rate. When a Serial port is opened, the FPGC4 will reset allowing for fast programming without having to touch the board (assuming SPI boot is disabled).

All of this works by using some fancy tricks in the UART bootloader. The goal is to receive the bitstream from UART and copying it to SDRAM, starting from address 0, and jumping to address 0 after all bits are received. This gives the first problem: the bootloader should not overwrite itself, since it is also located and executed from SDRAM. All the copy instructions are placed around 16MiB. The first instruction is a HALT, which is placed at address 0 so the PC will always be at the first address. All the copy instructions are executed from the UART receive interrupt. When a byte is received, it is placed on SDRAM starting from 16MiB. This way the first HALT instruction remains the same. After all bytes are copied, a timer interrupt is used to copy the SDRAM from 16MiB to 0MiB. Then, when the interrupt has ended, the PC will start from the first instruction (where the HALT used to be), which should now be the first instruction of the sent code. See UARTSPIbootloader.asm for the code (warning: large file, because of the offset to 16MiB).

The uartFlasher_win.py version is a special version that should be executed from Windows (for use with WSL2).

After programming the FPGC4, a Serial monitor is opened where you can send text (by typing and pressing enter) and receive text from the FPGC4. Closing the Serial monitor (by pressing Ctrl-C) does NOT reset the FPGC4, only opening a Serial port does.

## netFlash.py
Using this script, you can currently send a binary file to the FPGC4 running BDOS. When successful, BDOS will execute the sent binary. In the future this script should become more of a network interface script with more functionality.