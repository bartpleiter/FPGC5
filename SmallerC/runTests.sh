#!/bin/bash

retList=()
# loop though c file arguments, compile them and run them
for filename in "$@"
do
    echo "Processing: $filename"
    # for each c file, compile and run
    echo "Compiling C code to B332 ASM"
    if (./bcc $filename ../Assembler/code.asm) # compile c code and write compiled code to code.asm in Assembler folder
    then
        echo "C code successfully compiled"

        echo "Assembling B332 ASM code"
        if (cd ../Assembler && python3 Assembler.py > ../Programmer/code.list) # compile and write to code.list in Programmer folder
        then
                echo "B332 ASM code successfully assembled"
                # convert list to binary files and send to FPGC

                # WSL1/linux version
                (cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC" && python3 uartFlasher.py testMode)

                # WSL2/windows version
                #(cd ../Programmer && bash compileROM.sh noPadding && echo "Sending binary to FPGC" && python.exe uartFlasher_win.py testMode)

                retVal="$?"
                echo "$filename exited with code: $retVal"
                retList+=("$retVal")

        else # assemble failed, run again to show error
            echo "Failed to assemble B332 ASM code"
            cd ../Assembler && python3 Assembler.py
        fi
    else # compile failed
        echo "Failed to compile C code"
    fi

    # sleep alternative since it is broken in WSL1
    read -t 0.1

done

echo "Got the follwing return values:"
echo ${retList[@]} 