/*
* Top level design of the FPGC5
*/
module FPGC5(
    input           clock, //50MHz
    input           nreset, nBtnl, nBtnr,

    //HDMI
    output [3:0]    TMDS_p,
    output [3:0]    TMDS_n,
    
    //NTSC composite video signal
    output [7:0]    composite,

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

    //UART1 (currently unused because no UART midi synth anymore)
    //input           UART1_in,
    //output          UART1_out,

    //UART2
    input           UART2_in,
    output          UART2_out,

    //PS/2
    input           PS2_clk, PS2_data,

    //Led for debugging
    output          led,

    //GPIO
    input [3:0]     GPI,
    output [3:0]    GPO,

    //DIP switch
    input [3:0]     DIPS,

    //I2S audio
    output          I2S_SDIN, I2S_SCLK, I2S_LRCLK, I2S_MCLK,
    
    //Status leds
    output          led_Booted, led_Eth, led_Flash, led_USB0, led_USB1, led_PS2, led_HDMI, led_QSPI, led_GPU, led_I2S
);

// TMP FIXES FOR NEW PCB
assign I2S_SDIN = 1'b0;
assign I2S_SCLK = 1'b0;
assign I2S_LRCLK = 1'b0;
assign I2S_MCLK = 1'b0;


//-------------------CLK-------------------------
// Clock generator PLL
wire clkPixel;          // Pixel clock                          (25MHz)
wire clkTMDShalf;       // TMDS clock (pre-DDR), 5x pixel clock (125MHz)
wire clk_SDRAM;         // SDRAM clock                          (100MHz)
wire clk;               // System clock                         (50MHz)

clock_pll clkPll(
.inclk0 (clock),
//.c0     (clkPixel),
//.c1     (clkTMDShalf),
.c2     (clk_SDRAM),
.c3     (SDRAM_CLK),
.c4     (clk)
);

wire clk14; //14.31818MHz (50*63/220)
wire clk114; //14.31818 * 8 MHz = 114.5454MHz (50*(63*2)/55)

NTSC_pll ntscPll(
.inclk0 (clock),
.c0     (clk14),
.c1     (clk114),
.c2     (clkPixel), // 25.2MHz dirty fix to allow ALTCLKBUF
.c3     (clkTMDShalf)
);

wire clkMuxOut;
wire selectOutput;    // 1 -> HDMI, 0 -> Composite

clkMux clkmux(
.inclk0x(clk14),
.inclk1x(clkPixel),
.clkselect(selectOutput),
.outclk(clkMuxOut)
);

//--------------------Reset&Stabilizers-----------------------
// Reset signals
wire nreset_stable, UART0_dtr_stable;
wire nreset_unstable;
assign nreset_unstable = nreset & nBtnl & nBtnr;

// Dip switch
wire boot_mode_stable;

// GPU: High when frame just rendered (needs to be stabilized)
wire frameDrawn, frameDrawn_stable;

// Stabilized SPI interrupt signals
wire SPI1_nint_stable, SPI2_nint_stable, SPI3_int_stable, SPI4_gp_stable;

MultiStabilizer multistabilizer(
.clk    (clk),
.u0     (nreset_unstable),
.s0     (nreset_stable),
.u1     (UART0_dtr),
.s1     (UART0_dtr_stable),
.u2     (SPI1_nint),
.s2     (SPI1_nint_stable),
.u3     (SPI2_nint),
.s3     (SPI2_nint_stable),
.u4     (SPI3_int),
.s4     (SPI3_int_stable),
.u5     (SPI4_gp),
.s5     (SPI4_gp_stable),
.u6     (frameDrawn),
.s6     (frameDrawn_stable),
.u7     (DIPS[0]),
.s7     (boot_mode_stable),
.u8     (DIPS[1]),
.s8     (selectOutput)
);

// Debug: indicator for opened Serial port
assign led = UART0_dtr_stable;

// DTR to reset pulse
wire dtrRst;

DtrReset dtrReset(
.clk    (clk),
.dtr    (UART0_dtr_stable),
.dtrRst (dtrRst)
);

wire reset = (~nreset_stable) || dtrRst; // Global reset

// External reset outputs
assign SPI1_rst = reset;
assign SPI2_rst = reset;
assign SPI3_nrst = ~reset;


//---------------------------VRAM32---------------------------------
// VRAM32 I/O
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

// FSX will not write to VRAM
assign vram32_gpu_we    = 1'b0;
assign vram32_gpu_d     = 32'd0;

VRAM #(
.WIDTH(32),
.WORDS(1056),
.LIST("memory/vram32.list")
) vram32(
// CPU port
.cpu_clk    (clk),
.cpu_d      (vram32_cpu_d),
.cpu_addr   (vram32_cpu_addr),
.cpu_we     (vram32_cpu_we),
.cpu_q      (vram32_cpu_q),

// GPU port
.gpu_clk    (clkMuxOut),
.gpu_d      (vram32_gpu_d),
.gpu_addr   (vram32_gpu_addr),
.gpu_we     (vram32_gpu_we),
.gpu_q      (vram32_gpu_q)
);


//---------------------------VRAM322--------------------------------
// VRAM322 I/O
wire        vram322_gpu_clk;
wire [13:0] vram322_gpu_addr;
wire [31:0] vram322_gpu_d;
wire        vram322_gpu_we;
wire [31:0] vram322_gpu_q;

// FSX will not write to VRAM
assign vram322_gpu_we    = 1'b0;
assign vram322_gpu_d     = 32'd0;

VRAM #(
.WIDTH(32),
.WORDS(1056),
.LIST("memory/vram32.list")
) vram322(
// CPU port
.cpu_clk    (clk),
.cpu_d      (vram32_cpu_d),
.cpu_addr   (vram32_cpu_addr),
.cpu_we     (vram32_cpu_we),
.cpu_q      (),

// GPU port
.gpu_clk    (clkMuxOut),
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

// FSX will not write to VRAM
assign vram8_gpu_we     = 1'b0;
assign vram8_gpu_d      = 8'd0;

VRAM #(
.WIDTH(8),
.WORDS(8194),
.LIST("memory/vram8.list")
) vram8(
// CPU port
.cpu_clk    (clk),
.cpu_d      (vram8_cpu_d),
.cpu_addr   (vram8_cpu_addr),
.cpu_we     (vram8_cpu_we),
.cpu_q      (vram8_cpu_q),

// GPU port
.gpu_clk    (clkMuxOut),
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

// FSX will not write to VRAM
assign vramSPR_gpu_we     = 1'b0;
assign vramSPR_gpu_d      = 9'd0;

VRAM #(
.WIDTH(9),
.WORDS(256),
.LIST("memory/vramSPR.list")
) vramSPR(
// CPU port
.cpu_clk    (clk),
.cpu_d      (vramSPR_cpu_d),
.cpu_addr   (vramSPR_cpu_addr),
.cpu_we     (vramSPR_cpu_we),
.cpu_q      (vramSPR_cpu_q),

// GPU port
.gpu_clk    (clkMuxOut),
.gpu_d      (vramSPR_gpu_d),
.gpu_addr   (vramSPR_gpu_addr),
.gpu_we     (vramSPR_gpu_we),
.gpu_q      (vramSPR_gpu_q)
);


//-------------------ROM-------------------------
// ROM I/O
wire [8:0] rom_addr;
wire [31:0] rom_q;

ROM rom(
.clk        (clk),
.reset      (reset),
.address    (rom_addr),
.q          (rom_q)
);


//-----------------------FSX-------------------------
// FSX I/O

//wire [7:0]  composite;              // NTSC composite video signal

FSX fsx(
// Clocks
.clkPixel       (clkPixel),
.clkTMDShalf    (clkTMDShalf),
.clk14          (clk14),
.clk114         (clk114),
.clkMuxOut      (clkMuxOut),

// HDMI
.TMDS_p         (TMDS_p),
.TMDS_n         (TMDS_n),

// NTSC composite
.composite      (composite),

// Select output method
.selectOutput   (selectOutput),

// VRAM32
.vram32_addr    (vram32_gpu_addr),
.vram32_q       (vram32_gpu_q),

// VRAM32
.vram322_addr   (vram322_gpu_addr),
.vram322_q      (vram322_gpu_q),

// VRAM8
.vram8_addr     (vram8_gpu_addr),
.vram8_q        (vram8_gpu_q),

// VRAMSPR
.vramSPR_addr   (vramSPR_gpu_addr),
.vramSPR_q      (vramSPR_gpu_q),

// Interrupt signal
.frameDrawn     (frameDrawn)
);


//----------------Memory Unit--------------------
// Memory Unit I/O

// Bus
wire [26:0] bus_addr;
wire [31:0] bus_data;
wire        bus_we;
wire        bus_start;
wire [31:0] bus_q;
wire        bus_done;

// Interrupt signals
wire        OST1_int, OST2_int, OST3_int;
wire        UART0_rx_int, UART2_rx_int;
wire        PS2_int;
wire        SPI0_QSPI;

MemoryUnit mu(
// Clocks
.clk            (clk),
.clk_SDRAM      (clk_SDRAM),
.reset          (reset),

// Bus
.bus_addr       (bus_addr),
.bus_data       (bus_data),
.bus_we         (bus_we),
.bus_start      (bus_start),
.bus_q          (bus_q),
.bus_done       (bus_done),

/********
* MEMORY
********/

// SPI Flash / SPI0
.SPIflash_data  (SPI0_data),
.SPIflash_q     (SPI0_q),
.SPIflash_wp    (SPI0_wp),
.SPIflash_hold  (SPI0_hold),
.SPIflash_cs    (SPI0_cs),
.SPIflash_clk   (SPI0_clk),

// SDRAM
.SDRAM_CSn      (SDRAM_CSn),
.SDRAM_WEn      (SDRAM_WEn),
.SDRAM_CASn     (SDRAM_CASn),
.SDRAM_CKE      (SDRAM_CKE),
.SDRAM_RASn     (SDRAM_RASn),
.SDRAM_A        (SDRAM_A),
.SDRAM_BA       (SDRAM_BA),
.SDRAM_DQM      (SDRAM_DQM),
.SDRAM_DQ       (SDRAM_DQ),

// VRAM32 cpu port
.VRAM32_cpu_d       (vram32_cpu_d),
.VRAM32_cpu_addr    (vram32_cpu_addr),
.VRAM32_cpu_we      (vram32_cpu_we),
.VRAM32_cpu_q       (vram32_cpu_q),

// VRAM8 cpu port
.VRAM8_cpu_d        (vram8_cpu_d),
.VRAM8_cpu_addr     (vram8_cpu_addr),
.VRAM8_cpu_we       (vram8_cpu_we),
.VRAM8_cpu_q        (vram8_cpu_q),

// VRAMspr cpu port
.VRAMspr_cpu_d      (vramSPR_cpu_d),
.VRAMspr_cpu_addr   (vramSPR_cpu_addr),
.VRAMspr_cpu_we     (vramSPR_cpu_we),
.VRAMspr_cpu_q      (vramSPR_cpu_q),

// ROM
.ROM_addr           (rom_addr),
.ROM_q              (rom_q),

/********
* I/O
********/

// UART0 (Main USB)
.UART0_in           (UART0_in),
.UART0_out          (UART0_out),
.UART0_rx_interrupt (UART0_rx_int),

// UART1 (APU)
/*
.UART1_in           (),
.UART1_out          (),
.UART1_rx_interrupt (),
*/

// UART2 (GP)
.UART2_in           (UART2_in),
.UART2_out          (UART2_out),
.UART2_rx_interrupt (UART2_rx_int),

//SPI0 (Flash)
//declared under MEMORY
.SPI0_QSPI      (SPI0_QSPI),

// SPI1 (USB0/CH376T, bottom)
.SPI1_clk       (SPI1_clk),
.SPI1_cs        (SPI1_cs),
.SPI1_mosi      (SPI1_mosi),
.SPI1_miso      (SPI1_miso),
.SPI1_nint      (SPI1_nint_stable),

// SPI2 (USB1/CH376T, top)
.SPI2_clk       (SPI2_clk),
.SPI2_cs        (SPI2_cs),
.SPI2_mosi      (SPI2_mosi),
.SPI2_miso      (SPI2_miso),
.SPI2_nint      (SPI2_nint_stable),

// SPI3 (W5500)
.SPI3_clk       (SPI3_clk),
.SPI3_cs        (SPI3_cs),
.SPI3_mosi      (SPI3_mosi),
.SPI3_miso      (SPI3_miso),
.SPI3_int       (SPI3_int_stable),

// SPI4 (EXT/GP)
.SPI4_clk       (SPI4_clk),
.SPI4_cs        (SPI4_cs),
.SPI4_mosi      (SPI4_mosi),
.SPI4_miso      (SPI4_miso),
.SPI4_GP        (SPI4_gp_stable),

// GPIO (Separated GPI and GPO until GPIO module is implemented)
.GPI        (GPI[3:0]),
.GPO        (GPO[3:0]),

// OStimers
.OST1_int   (OST1_int),
.OST2_int   (OST2_int),
.OST3_int   (OST3_int),

// SNESpad
/*
.SNES_clk   (),
.SNES_latch (),
.SNES_data  (),
*/

// PS/2
.PS2_clk    (PS2_clk),
.PS2_data   (PS2_data),
.PS2_int    (PS2_int), //Scan code ready signal

// Boot mode
.boot_mode  (boot_mode_stable)
);


//---------------CPU----------------
// CPU I/O
wire [26:0] PC;

CPU cpu(
// Clock/reset
.clk            (clk),
.reset          (reset),

// Interrupts
.int1           (OST1_int),            //OStimer1
.int2           (OST2_int),            //OStimer2
.int3           (UART0_rx_int),        //UART0 rx (MAIN)
.int4           (frameDrawn_stable),   //GPU Frame Drawn
.ext_int1       (OST3_int),            //OStimer3
.ext_int2       (PS2_int),             //PS/2 scancode ready
.ext_int3       (1'b0),                //UART1 rx (APU)
.ext_int4       (UART2_rx_int),        //UART2 rx (EXT)

// Bus
.bus_addr       (bus_addr),
.bus_data       (bus_data),
.bus_we         (bus_we),
.bus_start      (bus_start),
.bus_q          (bus_q),
.bus_done       (bus_done),
.PC             (PC)
);


//-----------STATUS LEDS-----------
assign led_Booted = (PC >= 27'hC02522 | reset);
assign led_HDMI = (~selectOutput | reset);
assign led_QSPI = (~SPI0_QSPI | reset);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisUSB0
(
.clk(clk),
.reset(reset),
.activity(~SPI1_cs),
.LED(led_USB0)
);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisUSB1
(
.clk(clk),
.reset(reset),
.activity(~SPI2_cs),
.LED(led_USB1)
);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisEth
(
.clk(clk),
.reset(reset),
.activity(~SPI3_cs),
.LED(led_Eth)
);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisPS2
(
.clk(clk),
.reset(reset),
.activity(PS2_int),
.LED(led_PS2)
);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisFlash
(
.clk(clk),
.reset(reset),
.activity(~SPI0_cs),
.LED(led_Flash)
);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisGPU
(
.clk(clk),
.reset(reset),
.activity(vram32_cpu_we|vram8_cpu_we|vramSPR_cpu_we),
.LED(led_GPU)
);

LEDvisualizer #(.MIN_CLK(100000))
LEDvisI2S
(
.clk(clk),
.reset(reset),
.activity(I2S_SDIN),
.LED(led_I2S)
);

endmodule
