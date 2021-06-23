# Assembly Libraries (deprecated)
Using the include statements, you can include other files, which can be used as libraries.
Before working on the C compiler, I started writing some libraries in assembly (which I now do not use anymore because of C).
As you can probably notice, these are not finished.

!!! danger
    I do not update these anymore since C is a thing. So if I, for example, decide to change the memory addresses or change the assembler, these libraries will not work anymore. I will keep them here since they might be useful in some way.

### GFX.asm
Contains basic graphics functions like printing text and copying VRAM tables. Lacks many other useful functions (sprites for example).

### STD.asm
Contains some standard functions. Currently only contains a function to convert a byte to a ASCII Hex string with 0x prefix.

### UART.asm
Contains functions to send certain data over UART. Receiving is done in interrupts and therefore not included in this library.

### SPI.asm
Library for writing and reading to the SPI module. Uses GPO[0] as CS and can read and send a byte.

### CH376.asm
Library for reading and writing files using the CH376 USB controller. Uses SPI for communication and UART/STD for debugging.
Currently not finished.