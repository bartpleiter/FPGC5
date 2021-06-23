/*
* Top level design of the FPGC4
*/
module FPGC4(
    input           clk, //25MHz
    input           nreset,

    //VGA for GM7123 module
    output          vga_clk,
    output          vga_hs,
    output          vga_vs,
    output [2:0]    vga_r,
    output [2:0]    vga_g,
    output [1:0]    vga_b,
    output          vga_blk,

    //RGBs video
    output          crt_sync,
    output          crt_clk,
    output [2:0]    crt_r,
    output [2:0]    crt_g,
    output [1:0]    crt_b,

    //SDRAM
    output          SDRAM_CLK,
    output          SDRAM_CSn,
    output          SDRAM_WEn,
    output          SDRAM_CASn,
    output          SDRAM_RASn,
    output          SDRAM_CKE,
    output [12:0]   SDRAM_A,
    output [1:0]    SDRAM_BA,
    output [1:0]    SDRAM_DQM,
    inout  [15:0]   SDRAM_DQ,

    //SPI0 flash
    output          SPI0_clk,
    output          SPI0_cs,
    inout           SPI0_data,
    inout           SPI0_q,
    inout           SPI0_wp,
    inout           SPI0_hold,
     
    //SPI1 CH376 bottom
    output          SPI1_clk,
    output          SPI1_cs,
    output          SPI1_mosi,
    input           SPI1_miso,
    input           SPI1_nint,
    output          SPI1_rst,
     
    //SPI2 CH376 top
    output          SPI2_clk,
    output          SPI2_cs,
    output          SPI2_mosi,
    input           SPI2_miso,
    input           SPI2_nint,
    output          SPI2_rst,
     
    //SPI3 W5500
    output          SPI3_clk,
    output          SPI3_cs,
    output          SPI3_mosi,
    input           SPI3_miso,
    input           SPI3_int,
    output          SPI3_nrst,
     
    //SPI4 GP
    output          SPI4_clk,
    output          SPI4_cs,
    output          SPI4_mosi,
    input           SPI4_miso,
    input           SPI4_gp,
     
    //UART0
    input           UART0_in,
    output          UART0_out,
    input           UART0_dtr,
     
    //UART1
    input           UART1_in,
    output          UART1_out,
     
    //UART2
    input           UART2_in,
    output          UART2_out,
     
    //PS/2
    input           PS2_clk, PS2_data,
     
    //SNESpad
    output          SNES_clk, SNES_latch,
    input           SNES_data,
     
    //Led for debugging
    output          led,
     
    //GPIO
    input [3:0]     GPI,
    output [3:0]    GPO,
     
    //DIP switch
    input [3:0]     DIPS
);


//-------------------CLK-------------------------
//In hardware a PLL should be used here
// to create the clk and crt_clk 
assign crt_clk = clk; //'fix' for simulation

//Run VGA at CRT speed
assign vga_clk = crt_clk;

//Run SDRAM at system speed
assign SDRAM_CLK = clk;


//--------------------Reset&Stabilizers-----------------------
//Reset signals
wire nreset_stable, UART0_dtr_stable, reset;

//Dip switch
wire boot_mode_stable;

//GPU: High when frame just rendered (needs to be stabilized)
wire frameDrawn, frameDrawn_stable;

//Stabilized SPI interrupt signals
wire SPI1_nint_stable, SPI2_nint_stable, SPI3_int_stable, SPI4_gp_stable; 

MultiStabilizer multistabilizer (
.clk(clk),
.u0(nreset),
.s0(nreset_stable),
.u1(UART0_dtr),
.s1(UART0_dtr_stable),
.u2(SPI1_nint),
.s2(SPI1_nint_stable),
.u3(SPI2_nint),
.s3(SPI2_nint_stable),
.u4(SPI3_int),
.s4(SPI3_int_stable),
.u5(SPI4_gp),
.s5(SPI4_gp_stable),
.u6(frameDrawn),
.s6(frameDrawn_stable),
.u7(DIPS[0]),
.s7(boot_mode_stable)
);

//Indicator for opened Serial port
assign led = UART0_dtr_stable;

//DRT to reset pulse
wire dtrRst;

DtrReset dtrReset (
.clk(clk),
.dtr(UART0_dtr_stable),
.dtrRst(dtrRst)
);

assign reset = (~nreset_stable) || dtrRst;

//External reset outputs
assign SPI1_rst = reset;
assign SPI2_rst = reset;
assign SPI3_nrst = ~reset;


//---------------------------VRAM32---------------------------------
//VRAM32 I/O
wire        vram32_gpu_clk;
wire [13:0] vram32_gpu_addr;
wire [31:0] vram32_gpu_d;
wire        vram32_gpu_we;
wire [31:0] vram32_gpu_q;

wire        vram32_cpu_clk;
wire [13:0] vram32_cpu_addr;
wire [31:0] vram32_cpu_d;
wire        vram32_cpu_we; 
wire [31:0] vram32_cpu_q;

//because FSX will not write to VRAM
assign vram32_gpu_we    = 1'b0;
assign vram32_gpu_d     = 32'd0;

VRAM #(
.WIDTH(32), 
.WORDS(1056), 
.LIST("/home/bart/Documents/FPGA/FPGC4/Verilog/memory/vram32.list")
)   vram32(
//CPU port
.cpu_clk    (clk),
.cpu_d      (vram32_cpu_d),
.cpu_addr   (vram32_cpu_addr),
.cpu_we     (vram32_cpu_we),
.cpu_q      (vram32_cpu_q),

//GPU port
.gpu_clk    (crt_clk),
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
.LIST("/home/bart/Documents/FPGA/FPGC4/Verilog/memory/vram32.list")
)   vram322(
//CPU port
.cpu_clk    (clk),
.cpu_d      (vram32_cpu_d),
.cpu_addr   (vram32_cpu_addr),
.cpu_we     (vram32_cpu_we),
.cpu_q      (),

//GPU port
.gpu_clk    (crt_clk),
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

wire        vram8_cpu_clk;
wire [13:0] vram8_cpu_addr;
wire [7:0]  vram8_cpu_d;
wire        vram8_cpu_we;
wire [7:0]  vram8_cpu_q;

//because FSX will not write to VRAM
assign vram8_gpu_we     = 1'b0;
assign vram8_gpu_d      = 8'd0;

VRAM #(
.WIDTH(8), 
.WORDS(8194), 
.LIST("/home/bart/Documents/FPGA/FPGC4/Verilog/memory/vram8.list")
)   vram8(
//CPU port
.cpu_clk    (clk),
.cpu_d      (vram8_cpu_d),
.cpu_addr   (vram8_cpu_addr),
.cpu_we     (vram8_cpu_we),
.cpu_q      (vram8_cpu_q),

//GPU port
.gpu_clk    (crt_clk),
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

wire        vramSPR_cpu_clk;
wire [13:0] vramSPR_cpu_addr;
wire [8:0]  vramSPR_cpu_d;
wire        vramSPR_cpu_we;
wire [8:0]  vramSPR_cpu_q;

//because FSX will not write to VRAM
assign vramSPR_gpu_we     = 1'b0;
assign vramSPR_gpu_d      = 9'd0;

VRAM #(
.WIDTH(9), 
.WORDS(256), 
.LIST("/home/bart/Documents/FPGA/FPGC4/Verilog/memory/vramSPR.list")
)   vramSPR(
//CPU port
.cpu_clk    (clk),
.cpu_d      (vramSPR_cpu_d),
.cpu_addr   (vramSPR_cpu_addr),
.cpu_we     (vramSPR_cpu_we),
.cpu_q      (vramSPR_cpu_q),

//GPU port
.gpu_clk    (crt_clk),
.gpu_d      (vramSPR_gpu_d),
.gpu_addr   (vramSPR_gpu_addr),
.gpu_we     (vramSPR_gpu_we),
.gpu_q      (vramSPR_gpu_q)
);


//-------------------ROM-------------------------
//ROM I/O
wire [8:0] rom_addr;
wire [31:0] rom_q;


ROM rom(
.clk            (clk),
.reset          (reset),
.address        (rom_addr),
.q              (rom_q)
);


//-----------------------FSX-------------------------
FSX fsx(
.vga_clk        (crt_clk),

//VGA
.vga_r          (vga_r),
.vga_g          (vga_g),
.vga_b          (vga_b),
.vga_hs         (vga_hs),
.vga_vs         (vga_vs),

//CRT
.crt_sync       (crt_sync),
.crt_r          (crt_r),
.crt_g          (crt_g),
.crt_b          (crt_b),

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



//----------------Memory Unit--------------------
//Memory Unit I/O
wire [26:0] address;
wire [31:0] data;
wire        we;
wire        start;
wire        initDone;
wire        busy;
wire [31:0] q;
//Interrupt signals
wire        OST1_int, OST2_int, OST3_int;
wire        UART0_rx_int, UART1_rx_int, UART2_rx_int;
wire        PS2_int;

MemoryUnit mu(
//clock
.clk            (clk),
.reset          (reset),

//CPU connection (bus)
.address        (address),
.data           (data),
.we             (we),
.start          (start),
.initDone       (initDone),       //High when initialization is done
.busy           (busy),
.q              (q),

/********
* MEMORY
********/

//SPI Flash / SPI0
.SPIflash_data  (SPI0_data), 
.SPIflash_q     (SPI0_q), 
.SPIflash_wp    (SPI0_wp), 
.SPIflash_hold  (SPI0_hold),
.SPIflash_cs    (SPI0_cs), 
.SPIflash_clk   (SPI0_clk),

//SDRAM
.SDRAM_CSn      (SDRAM_CSn), 
.SDRAM_WEn      (SDRAM_WEn), 
.SDRAM_CASn     (SDRAM_CASn),
.SDRAM_CKE      (SDRAM_CKE), 
.SDRAM_RASn     (SDRAM_RASn),
.SDRAM_A        (SDRAM_A),
.SDRAM_BA       (SDRAM_BA),
.SDRAM_DQM      (SDRAM_DQM),
.SDRAM_DQ       (SDRAM_DQ),

//VRAM32 cpu port
.VRAM32_cpu_d       (vram32_cpu_d),
.VRAM32_cpu_addr    (vram32_cpu_addr), 
.VRAM32_cpu_we      (vram32_cpu_we),
.VRAM32_cpu_q       (vram32_cpu_q),

//VRAM8 cpu port
.VRAM8_cpu_d        (vram8_cpu_d),
.VRAM8_cpu_addr     (vram8_cpu_addr), 
.VRAM8_cpu_we       (vram8_cpu_we),
.VRAM8_cpu_q        (vram8_cpu_q),

//VRAMspr cpu port
.VRAMspr_cpu_d      (vramSPR_cpu_d),
.VRAMspr_cpu_addr   (vramSPR_cpu_addr), 
.VRAMspr_cpu_we     (vramSPR_cpu_we),
.VRAMspr_cpu_q      (vramSPR_cpu_q),

//ROM
.ROM_addr           (rom_addr),
.ROM_q              (rom_q),

/********
* I/O
********/

//UART0 (Main USB)
.UART0_in           (UART0_in),
.UART0_out          (UART0_out),
.UART0_rx_interrupt (UART0_rx_int),

//UART1 (APU)
.UART1_in           (UART1_in),
.UART1_out          (UART1_out),
.UART1_rx_interrupt (UART1_rx_int),

//UART2 (GP)
.UART2_in           (UART2_in),
.UART2_out          (UART2_out),
.UART2_rx_interrupt (UART2_rx_int),

//SPI0 (Flash)
//declared under MEMORY

//SPI1 (USB0/CH376T)
.SPI1_clk       (SPI1_clk),
.SPI1_cs        (SPI1_cs),
.SPI1_mosi      (SPI1_mosi),
.SPI1_miso      (SPI1_miso),
.SPI1_nint      (SPI1_nint_stable),

//SPI2 (USB1/CH376T)
.SPI2_clk       (SPI2_clk),
.SPI2_cs        (SPI2_cs),
.SPI2_mosi      (SPI2_mosi),
.SPI2_miso      (SPI2_miso),
.SPI2_nint      (SPI2_nint_stable),

//SPI3 (W5500)
.SPI3_clk       (SPI3_clk),
.SPI3_cs        (SPI3_cs),
.SPI3_mosi      (SPI3_mosi),
.SPI3_miso      (SPI3_miso),
.SPI3_int       (SPI3_int_stable),

//SPI4 (EXT/GP)
.SPI4_clk       (SPI4_clk),
.SPI4_cs        (SPI4_cs),
.SPI4_mosi      (SPI4_mosi),
.SPI4_miso      (SPI4_miso),
.SPI4_GP        (SPI4_gp_stable),

//GPIO (Separated GPI and GPO until GPIO module is implemented)
.GPI        (GPI[3:0]),
.GPO        (GPO[3:0]),

//OStimers
.OST1_int   (OST1_int),
.OST2_int   (OST2_int),
.OST3_int   (OST3_int),

//SNESpad
.SNES_clk   (SNES_clk),
.SNES_latch (SNES_latch),
.SNES_data  (SNES_data),

//PS/2
.PS2_clk    (PS2_clk),
.PS2_data   (PS2_data),
.PS2_int    (PS2_int), //Scan code ready signal

//Boot mode
.boot_mode  (boot_mode_stable)
);


//---------------CPU----------------
//CPU I/O

CPU cpu(
.clk            (clk),
.reset          (reset),
.int1           (OST1_int),            //OStimer1
.int2           (OST2_int),            //OStimer2
.int3           (UART0_rx_int),        //UART0 rx (MAIN)
.int4           (frameDrawn_stable),   //GPU Frame Drawn
.ext_int1       (OST3_int),            //OStimer3
.ext_int2       (PS2_int),             //PS/2 scancode ready
.ext_int3       (UART1_rx_int),        //UART1 rx (APU)
.ext_int4       (UART2_rx_int),        //UART2 rx (EXT)
.address        (address),
.data           (data),
.we             (we),
.q              (q),
.start          (start),
.busy           (busy)
);

endmodule