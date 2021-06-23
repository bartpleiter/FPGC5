/*
 * Testbench
 * Simulates the entire FPGC
*/
//Set timescale
`timescale 1 ns/1 ns

//Include top level design
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/FPGC4.v"

//Include modules
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/MultiStabilizer.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/ClockDivider.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/DtrReset.v"

`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/GPU/FSX.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/GPU/BGWrenderer.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/GPU/Spriterenderer.v"

`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/VRAM.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/mt48lc16m16a2.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/w25q128jv.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/SDRAMcontroller.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/SPIreader.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/ROM.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/Memory/MemoryUnit.v"

`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/CPU.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/ALU.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/ControlUnit.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/InstructionDecoder.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/PC.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/Regbank.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/Stack.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/CPU/Timer.v"

`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/Keyboard.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/NESpadReader.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/OStimer.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/UARTtx.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/UARTrx.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/SimpleSPI.v"
`include "/home/bart/Documents/FPGA/FPGC4/Verilog/modules/IO/SimpleFastSPI.v"

//Define testmodule
module FPGC_tb;

//Clock I/O
reg clk;
reg nreset;


//SPI0 Flash
wire SPI0_clk;
wire SPI0_cs; 
wire SPI0_data; 
wire SPI0_wp;
wire SPI0_q;  
wire SPI0_hold; 

W25Q128JV spiFlash (
.CLK    (SPI0_clk), 
.DIO    (SPI0_data), 
.CSn    (SPI0_cs), 
.WPn    (SPI0_wp), 
.HOLDn  (SPI0_hold), 
.DO     (SPI0_q)
);

//SDRAM
wire             SDRAM_CLK;     // SDRAM clock
wire    [15 : 0] SDRAM_DQ;      // SDRAM I/O
wire    [12 : 0] SDRAM_A;    // SDRAM Address
wire    [1 : 0]  SDRAM_BA;      // Bank Address
wire             SDRAM_CKE;     // Synchronous Clock Enable
wire             SDRAM_CSn;    // CS#
wire             SDRAM_RASn;   // RAS#
wire             SDRAM_CASn;   // CAS#
wire             SDRAM_WEn;    // WE#
wire    [1 : 0]  SDRAM_DQM;     // Mask

mt48lc16m16a2 sdram (
.Dq     (SDRAM_DQ), 
.Addr   (SDRAM_A), 
.Ba     (SDRAM_BA), 
.Clk    (SDRAM_CLK), 
.Cke    (SDRAM_CKE), 
.Cs_n   (SDRAM_CSn), 
.Ras_n  (SDRAM_RASn), 
.Cas_n  (SDRAM_CASn), 
.We_n   (SDRAM_WEn), 
.Dqm    (SDRAM_DQM)
);

//VGA
wire        vga_clk;
wire        vga_hs;
wire        vga_vs;
wire [2:0]  vga_r;
wire [2:0]  vga_g;
wire [1:0]  vga_b;
wire        vga_blk;

//CRT
wire        crt_clk;
wire        crt_sync;
wire [2:0]  crt_r;
wire [2:0]  crt_g;
wire [1:0]  crt_b;

//SPI1
wire SPI1_clk;
wire SPI1_cs;
wire SPI1_mosi;
wire SPI1_miso;
wire SPI1_rst;
reg  SPI1_nint;

//SPI2
wire SPI2_clk;
wire SPI2_cs;
wire SPI2_mosi;
wire SPI2_miso;
wire SPI2_rst;
reg  SPI2_nint;

//SPI3
wire SPI3_clk;
wire SPI3_cs;
wire SPI3_mosi;
wire SPI3_miso;
wire SPI3_nrst;
reg  SPI3_int;

//SPI4
wire SPI4_clk;
wire SPI4_cs;
wire SPI4_mosi;
wire SPI4_miso;
reg  SPI4_gp;

//UART0
reg  UART0_in;
wire UART0_out;
reg  UART0_dtr;

//UART1
reg  UART1_in;
wire UART1_out;

//UART2
reg  UART2_in;
wire UART2_out;

//PS/2
reg PS2_clk;
reg PS2_data;

//SNESpad
wire SNES_clk; 
wire SNES_latch;
reg  SNES_data;

//Led
wire led;

//GPIO
wire [3:0]  GPO;
reg  [3:0]  GPI;

//DIP Switch
reg [3:0] DIPS;

FPGC4 fpgc (
.clk(clk), //25MHz
.nreset(nreset),

//VGA for GM7123 module
.vga_clk(vga_clk),
.vga_hs(vga_hs),
.vga_vs(vga_vs),
.vga_r(vga_r),
.vga_g(vga_g),
.vga_b(vga_b),
.vga_blk(vga_blk),

//RGBs video
.crt_sync(crt_sync),
.crt_clk(crt_clk),
.crt_r(crt_r),
.crt_g(crt_g),
.crt_b(crt_b),

//SDRAM
.SDRAM_CLK(SDRAM_CLK),
.SDRAM_CSn(SDRAM_CSn),
.SDRAM_WEn(SDRAM_WEn),
.SDRAM_CASn(SDRAM_CASn),
.SDRAM_RASn(SDRAM_RASn),
.SDRAM_CKE(SDRAM_CKE),
.SDRAM_A(SDRAM_A),
.SDRAM_BA(SDRAM_BA),
.SDRAM_DQM(SDRAM_DQM),
.SDRAM_DQ(SDRAM_DQ),

//SPI0 flash
.SPI0_clk(SPI0_clk),
.SPI0_cs(SPI0_cs),
.SPI0_data(SPI0_data),
.SPI0_q(SPI0_q),
.SPI0_wp(SPI0_wp),
.SPI0_hold(SPI0_hold),
     
//SPI1 CH376 bottom
.SPI1_clk(SPI1_clk),
.SPI1_cs(SPI1_cs),
.SPI1_mosi(SPI1_mosi),
.SPI1_miso(SPI1_miso),
.SPI1_nint(SPI1_nint),
.SPI1_rst(SPI1_rst),
     
//SPI2 CH376 top
.SPI2_clk(SPI2_clk),
.SPI2_cs(SPI2_cs),
.SPI2_mosi(SPI2_mosi),
.SPI2_miso(SPI2_miso),
.SPI2_nint(SPI2_nint),
.SPI2_rst(SPI2_rst),
     
//SPI3 W5500
.SPI3_clk(SPI3_clk),
.SPI3_cs(SPI3_cs),
.SPI3_mosi(SPI3_mosi),
.SPI3_miso(SPI3_miso),
.SPI3_int(SPI3_int),
.SPI3_nrst(SPI3_nrst),
     
//SPI4 GP
.SPI4_clk(SPI4_clk),
.SPI4_cs(SPI4_cs),
.SPI4_mosi(SPI4_mosi),
.SPI4_miso(SPI4_miso),
.SPI4_gp(SPI4_gp),
     
//UART0
.UART0_in(UART0_in),
.UART0_out(UART0_out),
.UART0_dtr(UART0_dtr),
     
//UART1
.UART1_in(UART1_in),
.UART1_out(UART1_out),
     
//UART2
.UART2_in(UART2_in),
.UART2_out(UART2_out),
     
//PS/2
.PS2_clk(PS2_clk), 
.PS2_data(PS2_data),
     
//SNESpad
.SNES_clk(SNES_clk), 
.SNES_latch(SNES_latch),
.SNES_data(SNES_data),
     
//Led for debugging
.led(led),
     
//GPIO
.GPI(GPI),
.GPO(GPO),
     
//DIP switch
.DIPS(DIPS)
);


initial
begin
    //Dump everything for GTKwave
    $dumpfile("/home/bart/Documents/FPGA/FPGC4/Verilog/output/wave.vcd");
    $dumpvars;
    
    clk = 0;
    nreset = 1;

    SPI1_nint = 1;
    SPI2_nint = 1;
    SPI3_int = 0;
    SPI4_gp = 1;

    UART0_in = 1;
    UART0_dtr = 1;
    UART1_in = 1;
    UART2_in = 1;

    PS2_clk = 1;
    PS2_data = 0;

    SNES_data = 0;

    GPI = 4'b1111;

    DIPS = 4'b1111;


    
    repeat(5000) #20 clk = ~clk; //25MHz


    #1 $finish;
end

endmodule
