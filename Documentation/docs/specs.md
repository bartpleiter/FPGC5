# Specifications
These are the current specifications of the FPGC5:

- 50MHz CPU clock   
- 25MHz or 14MHz main GPU clock (depending on HDMI or NTSC being selected)
- 16MiB external SPI flash (QSPI with continous read mode) @ 25MHz. 32bit addresses (so not byte addressable!!!). Used as ROM, but has option to switch to direct access where it is connected to an SPI bus in the Memory Unit (allows for SPI flashing)
- 32MiB SDRAM @ 100MHz. 32bit addresses. Readable and writable. Used as main memory
- ~16.4KiB VRAM (SRAM). Combination of 32, 8 and 9bit addresses (three seperate modules for pixel data, tile indexes and sprites)
- 2KiB internal ROM for the Bootloader. 32bit addresses
- 4.125KiB Hardware Stack (SRAM). 32bit addresses
- 16 32bit registers, of which 15 are General Purpose
- 32bit instructions
- 27bit program counter for a possible address space of 0.5GiB at 32bit
- 320x200 video output (sent over 640x480 HDMI or 240P NTSC composite) with 256 colors
- Two layers of 8x8 Tiles of which one layer (background) has horizontal hardware scrolling support
- (currently not working anymore) One Sprite layer with support for 64 Sprites. Max 16 Sprites per horizontal line (double the amount of the NES!)
- Memory mapped I/O
- Three One Shot (OS) timers
- PS/2 Keyboard support
- UART and power over USB
- 4 GPI and 4 GPO pins (will become 8 true GPIO pins eventually)
- I2S DAC for future APU
- 2 USB host ports with FAT(12/16/32) file system support using a CH376T controller over SPI
- Ethernet using W5500 over SPI
- 8 interrupts, of which 4 normal interrupts (currently attached to two OS timers, UART RX and the frameDrawn signal of the FSX2), and 4 extended interrupts (currently attached to the PS/2 controller, a third OS timer and nothing for now) 
