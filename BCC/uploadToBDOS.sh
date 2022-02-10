#!/bin/bash

# script for compiling a C program for BDOS, and upload it to the FPGC over the network, whithout running it

if [ "$1" == "" ]
then
    echo "No program to compile given"
    exit 1
fi

OUTFILE="file.out"

if [ "$2" != "" ]
then
    OUTFILE=$2
fi

echo "Processing: $1"
# compile and upload
echo "Compiling C code to B332 ASM"
if (./bcc --bdos $1 ../Assembler/code.asm) # compile c code with BDOS flag and write compiled code to code.asm in Assembler folder
then
    echo "C code successfully compiled"

    echo "Assembling B332 ASM code"
    if (cd ../Assembler && python3 Assembler.py bdos 0x400000 -O > ../Programmer/code.list) # assemble with offset for BDOS and write to code.list in Programmer folder
    then
            echo "B332 ASM code successfully assembled"
            # convert list to binary files and upload to FPGC

            # WSL1/linux version
            (cd ../Programmer && bash compileROM.sh noPadding && cp code.bin $OUTFILE && echo "Uploading $OUTFILE to FPGC over Network" && python3 netUpload.py $OUTFILE && rm $OUTFILE)

            # WSL2/windows version
            #(cd ../Programmer && bash compileROM.sh noPadding && cp code.bin $2 && echo "Uploading $2 to FPGC over Network" && python.exe netUpload.py $2 && rm $2)
    
    else # assemble failed, run again to show error
        echo "Failed to assemble B332 ASM code"
        cd ../Assembler && python3 Assembler.py bdos 0x400000 -O
    fi
else # compile failed
    echo "Failed to compile C code"
fi
