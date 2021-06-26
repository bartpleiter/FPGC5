# Build script for assembly files
if (python3 Assembler.py > ../Programmer/code.list) # compile and write to code.list in Programmer folder
   then
   		# convert list to binary files, then copy the files to verilog folder
   		# comment out the uart flasher to use simulation instead
       	
       	# WSL2 version
       	#(cd ../Programmer && bash compileROM.sh && powershell.exe "python uartFlasher_win.py" && cp code.bin  ../Verilog/memory/code.bin && echo "Compile and Copy done")
       	
       	# WSL1/Linux version
       	(cd ../Programmer && bash compileROM.sh && python3 uartFlasher.py && cp code.bin  ../Verilog/memory/code.bin && echo "Compile and Copy done")
       	
        # Simulation only version
        #(cd ../Programmer && bash compileROM.sh && cp code.bin  ../Verilog/memory/code.bin && echo "Compile and Copy done")

       	# convert to text file
		(cd ../Verilog/memory && bash bin2txt.sh && echo "Converted to txt")
   else
   		# print the error, which is in code.list
       	(cat ../Programmer/code.list)
fi
