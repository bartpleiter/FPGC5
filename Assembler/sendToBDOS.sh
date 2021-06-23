#!/bin/bash

# script for compiling a asm program, and send it to the FPGC4
echo "Assembling B332 ASM code"
if (python3 Assembler.py bdos 0x400000 > ../Programmer/code.list) # compile and write to code.list in Programmer folder
then
        echo "B332 ASM code successfully assembled"

        # WSL1/linux version
        (cd ../Programmer && bash compileROM.sh && echo "Sending binary to FPGC4 over Network" && python3 netFlash.py code.bin)

else # assemble failed, run again to show error
    echo "Failed to assemble B332 ASM code"
    python3 Assembler.py bdos 0x400000
fi
