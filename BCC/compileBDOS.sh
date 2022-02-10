#!/bin/bash

# script for compiling a BDOS. 

echo "Compiling C code to B332 ASM"
if (./bcc --os BDOS/BDOS.c ../Assembler/code.asm) # compile c code and write compiled code to code.asm in Assembler folder
then
    echo "C code successfully compiled"

    echo "Assembling B332 ASM code"
    if (cd ../Assembler && python3 Assembler.py os -O > ../Programmer/code.list) # compile and write to code.list in Programmer folder
    then
            echo "B332 ASM code successfully assembled"
            # convert list to binary files and send to FPGC

            # WSL1/Linux version
            if [[ $1 == "flash" ||  $1 == "write" ]]
            then
                (cd ../Programmer && bash compileROM.sh && echo "Flashing binary to FPGC flash" && python3 flash.py write -v verify.bin)
            else
                (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC" && python3 uartFlasher.py)
            fi

            # WSL2/Windows version
            #if [[ $1 == "flash" ||  $1 == "write" ]]
            #then
            #    (cd ../Programmer && bash compileROM.sh && echo "Flashing binary to FPGC flash" && python.exe flash_win.py write)
            #else
            #    (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC" && python.exe uartFlasher_win.py)
            #fi
    
    else # assemble failed, run again to show error
        echo "Failed to assemble B332 ASM code"
        cd ../Assembler && python3 Assembler.py os -O
    fi
else # compile failed
    echo "Failed to compile C code"
fi
