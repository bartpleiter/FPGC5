#!/bin/bash

# script for compiling a C program for BDOS, and upload it to the FPGC over the network, whithout running it

echo "Processing: $1"
# compile and upload
echo "Compiling C code to B332 ASM"
if (python3 B322_shivyC.py $1 --bdos > ../Assembler/code.asm) # compile c code with BDOS flag and write compiled code to code.asm in Assembler folder
then
    echo "C code successfully compiled"

    echo "Assembling B332 ASM code"
    if (cd ../Assembler && python3 Assembler.py bdos 0x400000 > ../Programmer/code.list) # assemble with offset for BDOS and write to code.list in Programmer folder
    then
            echo "B332 ASM code successfully assembled"
            # convert list to binary files and upload to FPGC

            # WSL1/linux version
            (cd ../Programmer && bash compileROM.sh noPadding && cp code.bin $2 && echo "Uploading $2 to FPGC over Network" && python3 netUpload.py $2 && rm $2)

            # WSL2/windows version
            #(cd ../Programmer && bash compileROM.sh noPadding && cp code.bin $2 && echo "Uploading $2 to FPGC over Network" && python.exe netUpload.py $2 && rm $2)
    
    else # assemble failed, run again to show error
        echo "Failed to assemble B332 ASM code"
        cd ../Assembler && python3 Assembler.py bdos 0x400000
    fi
else # compile failed, run again to show error
    echo "Failed to compile C code"
    python3 B322_shivyC.py $1 --bdos
fi
