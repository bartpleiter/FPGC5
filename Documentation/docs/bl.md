# Bootloader code
The bootloader, located at the first address of the internal ROM (see memory map for the address), is the first thing that is executed by the CPU, even though it is not located at address 0. The bootloader is used to copy a program from the relatively slow SPI flash to the faster SDRAM, or to copy a UART bootloader in SDRAM to allow for a program to be sent over UART. In either case, the bootloader ends with jumping to SDRAM address 0 after clearing all registers to 0, which starts the program or UART bootloader. Since the bootloader has room for 512 words (32 bit), a POST test has been added as well. This means that at the start of the bootloader, the FPGC4 logo is printed on the display in the color white. When the bootloader is almost done (just before clearing the registers and jumping to address 0), the color is changed to blue/green as indication that the bootloader has finished.

There are two modes for the bootloader:
- If the first slider of the DIP switch is positioned down, then the bootloader will copy the UART bootloader, which is stored in the ROM as well, to SDRAM.
- If the first slider of the DIP switch is positioned up, then the bootloader will copy X addresses, where X is the number in (32 bit) address 5 of the SPI flash.

All registers are reset before jumping to address 0, because the UARTbootloader has to halt in the first instruction and therefore has to assume all registers are empty (hard to explain, see UART bootloader code).
