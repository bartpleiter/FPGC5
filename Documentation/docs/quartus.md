# Quartus

!!! info "TODO"
	Add picture of usage

The Quartus folder contains all files for actually implementing the FPGC5 into hardware on an FPGA. The targeted development board is the QMTECH EP4CE15 core board with 32MiB SDRAM.

There are some slight changes between the code in the Verilog folder and the code in the Quartus folder. For example, the Verilog folder contains simulation files for the SPI flash and SDRAM memory. The Quartus project is on the top level slightly modified to work on an actual FPGA. This also includes the use of PLLs for creating clocks.