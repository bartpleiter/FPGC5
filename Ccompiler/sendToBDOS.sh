#!/bin/bash

# script for compiling a C program for BDOS, and send it to the FPGC4 over the network

echo "Processing: $1"
# compile and send
echo "Compiling C code to B332 ASM"
if (python3 B322_shivyC.py $1 --bdos > ../Assembler/code.asm) # compile c code with BDOS flag and write compiled code to code.asm in Assembler folder
then
    echo "C code successfully compiled"

    echo "Assembling B332 ASM code"
    if (cd ../Assembler && python3 Assembler.py bdos 0x400000 > ../Programmer/code.list) # assemble with offset for BDOS and write to code.list in Programmer folder
    then
            echo "B332 ASM code successfully assembled"
            # convert list to binary files and send to FPGC4

            # WSL1/linux version
            (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC4 over Network" && python3 netFlash.py code.bin)
    
    else # assemble failed, run again to show error
        echo "Failed to assemble B332 ASM code"
        cd ../Assembler && python3 Assembler.py bdos 0x400000
    fi
else # compile failed, run again to show error
    echo "Failed to compile C code"
    python3 B322_shivyC.py $1 --bdos
fi
