# Quartus

!!! info "TODO"
	Add picture of usage

The Quartus folder contains all files for actually implementing the FPGC4 into hardware on an FPGA. The targeted development board is the QMTECH EP4CE15 core board with 32MiB SDRAM.

There are some slight changes between the code in the Verilog folder and the code in the Quartus folder. For example, the Verilog folder contains simulation files for the SPI flash and SDRAM memory. The Quartus project is on the top level slightly modified to work on an actual FPGA. This also includes the use of PLLs for creating clocks.

The current design (as of writing this line in documentation) uses 7.35k LEs (48%), 106 pins, 1 PLL, 6 9-bit multipliers and 186kbit SRAM (36%).