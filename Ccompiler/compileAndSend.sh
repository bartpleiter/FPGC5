#!/bin/bash

# script for compiling a bare metal C program, and send it to the FPGC, without doing tests

echo "Processing: $1"
# for each c file, compile and run
echo "Compiling C code to B332 ASM"
if (pypy3 B322_shivyC.py $1 > ../Assembler/code.asm) # compile c code and write compiled code to code.asm in Assembler folder
then
    echo "C code successfully compiled"

    echo "Assembling B332 ASM code"
    if (cd ../Assembler && python3 Assembler.py > ../Programmer/code.list) # compile and write to code.list in Programmer folder
    then
            echo "B332 ASM code successfully assembled"
            # convert list to binary files and send to FPGC

            # WSL1/Linux version
            if [[ $1 == "flash" ||  $1 == "write" ]]
            then
                (cd ../Programmer && bash compileROM.sh && echo "Flashing binary to FPGC flash" && python3 flash.py write)
            else
                (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC" && python3 uartFlasher.py)
            fi

            # WSL2/Windows version
            #if [[ $2 == "flash" ||  $2 == "write" ]]
            #then
            #    (cd ../Programmer && bash compileROM.sh && echo "Flashing binary to FPGC flash" && python.exe flash_win.py write)
            #else
            #    (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC" && python.exe uartFlasher_win.py)
            #fi
    
    else # assemble failed, run again to show error
        echo "Failed to assemble B332 ASM code"
        cd ../Assembler && python3 Assembler.py
    fi
else # compile failed, run again to show error
    echo "Failed to compile C code"
    pypy3 B322_shivyC.py $1
fi
