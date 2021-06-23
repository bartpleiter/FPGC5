/*
 * Testbench
 * Simulates the entire FPGC
*/
//Set timescale
`timescale 1 ns/1 ns

//Include modules
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/FSX.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/BGWrenderer.v"
//`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/Spriterenderer.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/TimingGenerator.v"

`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/HDMI/RGB2HDMI.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/HDMI/TMDSenc.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/HDMI/lvds.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/GPU/HDMI/ddr.v"

`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/Memory/VRAM.v"

//Define testmodule
module FSX3_tb;

//Clock I/O
reg clkPixel, clkTMDShalf;
reg nreset;


//---------------------------VRAM32---------------------------------
//VRAM32 I/O
wire        vram32_gpu_clk;
wire [13:0] vram32_gpu_addr;
wire [31:0] vram32_gpu_d;
wire        vram32_gpu_we;
wire [31:0] vram32_gpu_q;

//because FSX will not write to VRAM
assign vram32_gpu_we    = 1'b0;
assign vram32_gpu_d     = 32'd0;

VRAM #(
.WIDTH(32), 
.WORDS(1056), 
.LIST("/home/bart/Documents/FPGA/FPGC5/Verilog/memory/vram32.list")
)   vram32(
//GPU port
.gpu_clk    (clkPixel),
.gpu_d      (vram32_gpu_d),
.gpu_addr   (vram32_gpu_addr),
.gpu_we     (vram32_gpu_we),
.gpu_q      (vram32_gpu_q)
);


//---------------------------VRAM322--------------------------------
//VRAM322 I/O
wire        vram322_gpu_clk;
wire [13:0] vram322_gpu_addr;
wire [31:0] vram322_gpu_d;
wire        vram322_gpu_we;
wire [31:0] vram322_gpu_q;

//because FSX will not write to VRAM
assign vram322_gpu_we    = 1'b0;
assign vram322_gpu_d     = 32'd0;

VRAM #(
.WIDTH(32), 
.WORDS(1056), 
.LIST("/home/bart/Documents/FPGA/FPGC5/Verilog/memory/vram32.list")
)   vram322(
//GPU port
.gpu_clk    (clkPixel),
.gpu_d      (vram322_gpu_d),
.gpu_addr   (vram322_gpu_addr),
.gpu_we     (vram322_gpu_we),
.gpu_q      (vram322_gpu_q)
);


//--------------------------VRAM8--------------------------------
//VRAM8 I/O
wire        vram8_gpu_clk;
wire [13:0] vram8_gpu_addr;
wire [7:0]  vram8_gpu_d;
wire        vram8_gpu_we;
wire [7:0]  vram8_gpu_q;

//because FSX will not write to VRAM
assign vram8_gpu_we     = 1'b0;
assign vram8_gpu_d      = 8'd0;

VRAM #(
.WIDTH(8), 
.WORDS(8194), 
.LIST("/home/bart/Documents/FPGA/FPGC5/Verilog/memory/vram8.list")
)   vram8(
//GPU port
.gpu_clk    (clkPixel),
.gpu_d      (vram8_gpu_d),
.gpu_addr   (vram8_gpu_addr),
.gpu_we     (vram8_gpu_we),
.gpu_q      (vram8_gpu_q)
);


//--------------------------VRAMSPR--------------------------------
//VRAMSPR I/O
wire        vramSPR_gpu_clk;
wire [13:0] vramSPR_gpu_addr;
wire [8:0]  vramSPR_gpu_d;
wire        vramSPR_gpu_we;
wire [8:0]  vramSPR_gpu_q;

//because FSX will not write to VRAM
assign vramSPR_gpu_we     = 1'b0;
assign vramSPR_gpu_d      = 9'd0;

VRAM #(
.WIDTH(9), 
.WORDS(256), 
.LIST("/home/bart/Documents/FPGA/FPGC5/Verilog/memory/vramSPR.list")
)   vramSPR(
//GPU port
.gpu_clk    (clkPixel),
.gpu_d      (vramSPR_gpu_d),
.gpu_addr   (vramSPR_gpu_addr),
.gpu_we     (vramSPR_gpu_we),
.gpu_q      (vramSPR_gpu_q)
);



//-----------------------FSX-------------------------
//FSX I/O
wire        frameDrawn; // interrupt signal for CPU
wire [7:0]  composite; // NTSC composite video signal
reg         selectOutput; // 1 -> HDMI, 0 -> Composite
// HDMI signals
wire [3:0] TMDS_p;
wire [3:0] TMDS_n;


FSX fsx(
//Clocks
.clkPixel       (clkPixel),
.clkTMDShalf    (clkTMDShalf),

//HDMI
.TMDS_p         (TMDS_p),
.TMDS_n         (TMDS_n),

//NTSC composite
.composite      (composite),

//Select output method
.selectOutput   (selectOutput),

//VRAM32
.vram32_addr    (vram32_gpu_addr),
.vram32_q       (vram32_gpu_q),

//VRAM32
.vram322_addr   (vram322_gpu_addr),
.vram322_q      (vram322_gpu_q),

//VRAM8
.vram8_addr     (vram8_gpu_addr),
.vram8_q        (vram8_gpu_q),

//VRAMSPR
.vramSPR_addr   (vramSPR_gpu_addr),
.vramSPR_q      (vramSPR_gpu_q),

//Interrupt signal
.frameDrawn     (frameDrawn)
);


initial
begin
    //Dump everything for GTKwave
    $dumpfile("/home/bart/Documents/FPGA/FPGC5/Verilog/output/wave.vcd");
    $dumpvars;
    
    clkTMDShalf = 0;
    clkPixel = 0;
    selectOutput = 1;
    nreset = 1;

    repeat(180000) // 850000 for exactly one frame at 640x480  (1110000 for exactly one frame at 1706x240)
    begin
        // TMDS: 125MHz, Pixel: 25MHz  (320x240 4x wide: TMDS: 165MHz, Pixel: 33MHz)
        #4 clkTMDShalf = ~clkTMDShalf;
        #4 clkTMDShalf = ~clkTMDShalf;
        #4 clkTMDShalf = ~clkTMDShalf;
        #4 clkTMDShalf = ~clkTMDShalf;
        #4 clkTMDShalf = ~clkTMDShalf; clkPixel = ~clkPixel;
    end

    #1 $finish;
end

endmodule
