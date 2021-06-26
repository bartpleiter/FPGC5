# Build script for assembly files for simulation in verilog
cp $1 code.asm

if (python3 Assembler.py > ../Verilog/memory/mu.list) # compile and write to verilog memory folder
   then
         iverilog -o /home/bart/Documents/FPGA/FPGC5/Verilog/output/output /home/bart/Documents/FPGA/FPGC5/Verilog/testbench/B323_tb.v
         vvp /home/bart/Documents/FPGA/FPGC5/Verilog/output/output
   else
         # print the error, which is in code.list
         (cat ../Programmer/code.list)
fi
