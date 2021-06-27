/*
 * Testbench
 * Simulates the mt48lc16m16a2 SDRAM
*/
//Set timescale (same as SDRAM)
`timescale 1ns / 1ps

//Include modules
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/Memory/mt48lc16m16a2.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/Memory/SDRAMcontroller.v"

//Define testmodule
module SDRAM_tb;


reg clk;
reg reset;


//------------
//SDRAM
//------------

wire             SDRAM_CLK;     // SDRAM clock
wire    [15 : 0] SDRAM_DQ;      // SDRAM I/O
wire    [12 : 0] SDRAM_A;       // SDRAM Address
wire    [1 : 0]  SDRAM_BA;      // Bank Address
wire             SDRAM_CKE;     // Synchronous Clock Enable
wire             SDRAM_CSn;     // CS#
wire             SDRAM_RASn;    // RAS#
wire             SDRAM_CASn;    // CAS#
wire             SDRAM_WEn;     // WE#
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


//------------
//SDRAM Controller
//------------
reg        sd_we;
reg        sd_start;
reg [31:0] sd_d; 
reg [23:0] sd_addr;

wire        sd_busy;
wire        sd_initDone;
wire        sd_q_ready;
wire [31:0] sd_q;

SDRAMcontroller sdramcontroller(
.clk        (clk),
.reset      (reset),

.busy       (sd_busy),      // high if controller is busy
.addr       (sd_addr),      // addr to read or write
.d          (sd_d),         // data to write
.we         (sd_we),        // high if write, low if read
.q          (sd_q),         // read data output
.q_ready    (sd_q_ready),   // read data ready
.start      (sd_start),
.initDone   (sd_initDone),

// SDRAM
.SDRAM_CKE  (SDRAM_CKE), 
.SDRAM_CSn  (SDRAM_CSn),
.SDRAM_WEn  (SDRAM_WEn), 
.SDRAM_CASn (SDRAM_CASn), 
.SDRAM_RASn (SDRAM_RASn),
.SDRAM_A    (SDRAM_A),
.SDRAM_BA   (SDRAM_BA),
.SDRAM_DQM  (SDRAM_DQM),
.SDRAM_DQ   (SDRAM_DQ)
);


assign SDRAM_CLK = clk;

initial
begin
    //Dump everything for GTKwave
    $dumpfile("/home/bart/Documents/FPGA/FPGC5/Verilog/output/wave.vcd");
    $dumpvars;

    sd_we       = 1'b0;
    sd_start    = 1'b0;
    sd_d        = 32'd0; 
    sd_addr     = 24'd0;

    // reset first
    clk = 1'b0;
    reset = 1'b1;
    repeat(4) #5 clk = ~clk;
    reset = 1'b0;
    

    // start simulation


    repeat(100) #5 clk = ~clk;
    sd_we       = 1'b1;
    sd_start    = 1'b1;
    sd_d        = 32'd37; 
    sd_addr     = 24'd13;
    repeat(2) #5 clk = ~clk;
    sd_start    = 1'b0;



    repeat(32) #5 clk = ~clk;
    sd_we       = 1'b0;
    sd_start    = 1'b1;
    sd_d        = 32'd0; 
    sd_addr     = 24'd13;
    repeat(2) #5 clk = ~clk;
    sd_start    = 1'b0;
    repeat(100) #5 clk = ~clk;


    #1 $finish;
end

endmodule
