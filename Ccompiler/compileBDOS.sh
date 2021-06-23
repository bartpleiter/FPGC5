#!/bin/bash

# script for compiling a BDOS. 

echo "Compiling C code to B332 ASM"
if (python3 B322_shivyC.py BDOS/BDOS.c --os > ../Assembler/code.asm) # compile c code and write compiled code to code.asm in Assembler folder
then
    echo "C code successfully compiled"

    echo "Assembling B332 ASM code"
    if (cd ../Assembler && python3 Assembler.py os > ../Programmer/code.list) # compile and write to code.list in Programmer folder
    then
            echo "B332 ASM code successfully assembled"
            # convert list to binary files and send to FPGC4

            if [[ $1 == "flash" ||  $1 == "write" ]]
            then
                (cd ../Programmer && bash compileROM.sh && echo "Flashing binary to FPGC4 flash" && python3 flash.py write)
            else
                (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC4" && python3 uartFlasher.py)
            fi
    
    else # assemble failed, run again to show error
        echo "Failed to assemble B332 ASM code"
        cd ../Assembler && python3 Assembler.py os
    fi
else # compile failed, run again to show error
    echo "Failed to compile C code"
    python3 B322_shivyC.py BDOS/BDOS.c --os
fi
