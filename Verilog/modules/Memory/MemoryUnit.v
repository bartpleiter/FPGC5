/*
* Memory Unit
* Requests by CPU are made on the posedge of clk.
* Modules work on the negedge of clk.
*/
module MemoryUnit(
    //clock
    input           clk, clk_SDRAM, reset,

    //CPU connection (bus)
    /*
    input  [26:0]   address,
    input  [31:0]   data,
    input           we,
    input           start,          //Start should be high until busy = low
    output          initDone,       //High when initialization is done
    output reg      busy,
    output reg [31:0]  q,
    */

    // Bus
    input [26:0]        bus_addr,
    input [31:0]        bus_data,
    input               bus_we,
    input               bus_start,
    output [31:0]       bus_q,
    output reg          bus_done = 1'b0,

    /********
    * MEMORY
    ********/

    //SPI Flash / SPI0
    inout           SPIflash_data, SPIflash_q, SPIflash_wp, SPIflash_hold,
    output          SPIflash_cs, 
    output          SPIflash_clk,

    //SDRAM
    output          SDRAM_CSn, SDRAM_WEn, SDRAM_CASn,
    output          SDRAM_CKE, SDRAM_RASn,
    output [12:0]   SDRAM_A,
    output [1:0]    SDRAM_BA,
    output [1:0]    SDRAM_DQM,
    inout [15:0]    SDRAM_DQ,

    //VRAM32 cpu port
    output [31:0]   VRAM32_cpu_d,
    output [13:0]   VRAM32_cpu_addr, 
    output          VRAM32_cpu_we,
    input  [31:0]   VRAM32_cpu_q,

    //VRAM8 cpu port
    output [7:0]    VRAM8_cpu_d,
    output [13:0]   VRAM8_cpu_addr, 
    output          VRAM8_cpu_we,
    input  [7:0]    VRAM8_cpu_q,

    //VRAMspr cpu port
    output [8:0]    VRAMspr_cpu_d,
    output [13:0]   VRAMspr_cpu_addr, 
    output          VRAMspr_cpu_we,
    input  [8:0]    VRAMspr_cpu_q,

    //ROM
    output [8:0]    ROM_addr,
    input  [31:0]   ROM_q,

    /********
    * I/O
    ********/

    //UART0 (Main USB)
    input           UART0_in,
    output          UART0_out,
    output          UART0_rx_interrupt,

    //UART1 (APU)
    input           UART1_in,
    output          UART1_out,
    output          UART1_rx_interrupt,

    //UART2 (GP)
    input           UART2_in,
    output          UART2_out,
    output          UART2_rx_interrupt,

    //SPI0 (Flash)
    //declared under MEMORY

    //SPI1 (USB0/CH376T)
    output          SPI1_clk,
    output reg      SPI1_cs = 1'b1,
    output          SPI1_mosi,
    input           SPI1_miso,
    input           SPI1_nint,

    //SPI2 (USB1/CH376T)
    output          SPI2_clk,
    output reg      SPI2_cs = 1'b1,
    output          SPI2_mosi,
    input           SPI2_miso,
    input           SPI2_nint,

    //SPI3 (W5500)
    output          SPI3_clk,
    output reg      SPI3_cs = 1'b1,
    output          SPI3_mosi,
    input           SPI3_miso,
    input           SPI3_int,

    //SPI4 (EXT/GP)
    output          SPI4_clk,
    output reg      SPI4_cs = 1'b1,
    output          SPI4_mosi,
    input           SPI4_miso,
    input           SPI4_GP,

    //GPIO (Separated GPI and GPO until GPIO module is implemented)
    input [3:0]     GPI,
    output reg [3:0]GPO = 4'd0,

    //OStimers
    output          OST1_int,
    output          OST2_int,
    output          OST3_int,

    //SNESpad
    output          SNES_clk, SNES_latch,
    input           SNES_data,

    //PS/2
    input           PS2_clk, PS2_data,
    output          PS2_int,            //Scan code ready signal
    
    //Boot mode
    input           boot_mode
    
);  


    //------------
    //SPI0 (flash) TODO: move this to a separate module
    //------------

    //SPIreader
    wire [23:0] SPIflashReader_addr;            //address of flash (32 bit)
    wire        SPIflashReader_start;           //start signal for SPIreader
    wire        SPIflashReader_cs;              //cs
    wire [31:0] SPIflashReader_q;               //data out
    wire        SPIflashReader_initDone;        //initdone of SPIreader
    wire        SPIflashReader_recvDone;        //recvdone of SPIreader TODO might change this to busy
    wire        SPIflashReader_reset;           //reset SPIreader
    wire        SPIflashReader_write;           //output mode of inout pins (high when writing to SPI flash)

    wire io0_out, io1_out, io2_out, io3_out;    //d, q wp, hold output
    wire io0_in,  io1_in,  io2_in,  io3_in;     //d, q wp, hold input

    SPIreader sreader (
    .clk        (clk),
    .reset      (SPIflashReader_reset),
    .cs         (SPIflashReader_cs),
    .address    (SPIflashReader_addr),
    .instr      (SPIflashReader_q),
    .start      (SPIflashReader_start),
    .initDone   (SPIflashReader_initDone), 
    .recvDone   (SPIflashReader_recvDone),
    .write      (SPIflashReader_write),
    .io0_out    (io0_out),
    .io1_out    (io1_out),
    .io2_out    (io2_out),
    .io3_out    (io3_out),
    .io0_in     (io0_in),
    .io1_in     (io1_in),
    .io2_in     (io2_in),
    .io3_in     (io3_in)
    );

    //SPI0 (flash)
    wire SPI0_clk;
    wire SPI0_mosi;
    reg  SPI0_cs;
    reg  SPI0_enable = 1'b0; //high enables SPI0 and disables SPIreader
    wire SPI0_start;
    wire [7:0] SPI0_in;
    wire [7:0] SPI0_out;
    wire SPI0_done;

    SimpleSPI #(
    .CLKS_PER_HALF_BIT(1))
    SPI0(
    .clk        (clk),
    .reset      (reset),
    .in_byte    (SPI0_in),
    .start      (SPI0_start),
    .done       (SPI0_done),
    .out_byte   (SPI0_out),
    .spi_clk    (SPI0_clk),
    .miso       (SPIflash_q),
    .mosi       (SPI0_mosi)
    );

    //Tri-state signals
    wire SPIcombined_d, SPIcombined_q, SPIcombined_wp, SPIcombined_hold, SPIcombined_OutputEnable;

    assign SPIflash_clk             = (SPI0_enable) ? SPI0_clk  : clk;
    assign SPIflash_cs              = (SPI0_enable) ? SPI0_cs   : SPIflashReader_cs;
    assign SPIflashReader_reset     = (SPI0_enable) ? 1'b1      : reset;    

    assign SPIcombined_d            = (SPI0_enable) ? SPI0_mosi : io0_out;
    assign SPIcombined_q            = (SPI0_enable) ? 'bz       : io1_out;
    assign SPIcombined_wp           = (SPI0_enable) ? 1'b1      : io2_out;
    assign SPIcombined_hold         = (SPI0_enable) ? 1'b1      : io3_out;
    assign SPIcombined_OutputEnable = (SPI0_enable) ? 1'b1      : SPIflashReader_write;

    assign SPIflash_data = (SPIcombined_OutputEnable) ? SPIcombined_d    : 'bz;
    assign SPIflash_q    = (SPIcombined_OutputEnable) ? SPIcombined_q    : 'bz;
    assign SPIflash_wp   = (SPIcombined_OutputEnable) ? SPIcombined_wp   : 'bz;
    assign SPIflash_hold = (SPIcombined_OutputEnable) ? SPIcombined_hold : 'bz;

    assign io0_in = (~SPIcombined_OutputEnable) ? SPIflash_data : 'bz;
    assign io1_in = (~SPIcombined_OutputEnable) ? SPIflash_q    : 'bz;
    assign io2_in = (~SPIcombined_OutputEnable) ? SPIflash_wp   : 'bz;
    assign io3_in = (~SPIcombined_OutputEnable) ? SPIflash_hold : 'bz;




    //------------
    //SDRAM
    //------------
    reg        sd_we = 1'b0;
    reg        sd_start = 1'b0;
    reg [31:0] sd_d = 32'd0; 
    reg [23:0] sd_addr = 24'd0;

    wire        sd_busy;
    wire        sd_initDone;
    wire        sd_q_ready;
    wire [31:0] sd_q;

    SDRAMcontroller sdramcontroller(
    .clk        (clk_SDRAM), // now must be 100MHz
    //.reset      (reset),

    .busy       (sd_busy),       // high if controller is busy
    .addr       (sd_addr),       // addr to read or write
    .d          (sd_d),          // data to write
    .we         (sd_we),         // high if write, low if read
    .q          (sd_q),          // read data output
    .q_ready    (sd_q_ready),  // read data ready
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




    //------------
    //UART0
    //------------
    wire UART0_r_Tx_DV, UART0_w_Tx_Done;
    wire [7:0] UART0_r_Tx_Byte;

    UARTtx UART0_tx(
    .i_Clock    (clk),
    .reset      (reset),
    .i_Tx_DV    (UART0_r_Tx_DV),
    .i_Tx_Byte  (UART0_r_Tx_Byte),
    .o_Tx_Active(),
    .o_Tx_Serial(UART0_out),
    .o_Tx_Done  (UART0_w_Tx_Done)
    );

    wire [7:0] UART0_w_Rx_Byte;

    UARTrx UART0_rx(
    .i_Clock    (clk),
    .reset      (reset),
    .i_Rx_Serial(UART0_in),
    .o_Rx_DV    (UART0_rx_interrupt),
    .o_Rx_Byte  (UART0_w_Rx_Byte)
    );

    
    //------------
    //UART1
    //------------
    wire UART1_r_Tx_DV, UART1_w_Tx_Done;
    wire [7:0] UART1_r_Tx_Byte;

    UARTtx UART1_tx(
    .i_Clock    (clk),
    .reset      (reset),
    .i_Tx_DV    (UART1_r_Tx_DV),
    .i_Tx_Byte  (UART1_r_Tx_Byte),
    .o_Tx_Active(),
    .o_Tx_Serial(UART1_out),
    .o_Tx_Done  (UART1_w_Tx_Done)
    );

    wire [7:0] UART1_w_Rx_Byte;

    UARTrx UART1_rx(
    .i_Clock    (clk),
    .reset      (reset),
    .i_Rx_Serial(UART1_in),
    .o_Rx_DV    (UART1_rx_interrupt),
    .o_Rx_Byte  (UART1_w_Rx_Byte)
    );


    //------------
    //UART2
    //------------
    wire UART2_r_Tx_DV, UART2_w_Tx_Done;
    wire [7:0] UART2_r_Tx_Byte;

    UARTtx UART2_tx(
    .i_Clock    (clk),
    .reset      (reset),
    .i_Tx_DV    (UART2_r_Tx_DV),
    .i_Tx_Byte  (UART2_r_Tx_Byte),
    .o_Tx_Active(),
    .o_Tx_Serial(UART2_out),
    .o_Tx_Done  (UART2_w_Tx_Done)
    );

    wire [7:0] UART2_w_Rx_Byte;

    UARTrx UART2_rx(
    .i_Clock    (clk),
    .reset      (reset),
    .i_Rx_Serial(UART2_in),
    .o_Rx_DV    (UART2_rx_interrupt),
    .o_Rx_Byte  (UART2_w_Rx_Byte)
    );




    //------------
    //SPI1 (CH376T bottom)
    //------------
    wire SPI1_start;
    wire [7:0] SPI1_in;
    wire [7:0] SPI1_out;
    wire SPI1_done;

    SimpleSPI #(
    .CLKS_PER_HALF_BIT(2))
    SPI1(
    .clk        (clk),
    .reset      (reset),
    .in_byte    (SPI1_in),
    .start      (SPI1_start),
    .done       (SPI1_done),
    .out_byte   (SPI1_out),
    .spi_clk    (SPI1_clk),
    .miso       (SPI1_miso),
    .mosi       (SPI1_mosi)
    );


    //------------
    //SPI2 (CH376T top)
    //------------
    wire SPI2_start;
    wire [7:0] SPI2_in;
    wire [7:0] SPI2_out;
    wire SPI2_done;

    SimpleSPI #(
    .CLKS_PER_HALF_BIT(2))
    SPI2(
    .clk        (clk),
    .reset      (reset),
    .in_byte    (SPI2_in),
    .start      (SPI2_start),
    .done       (SPI2_done),
    .out_byte   (SPI2_out),
    .spi_clk    (SPI2_clk),
    .miso       (SPI2_miso),
    .mosi       (SPI2_mosi)
    );


    //------------
    //SPI3 (W5500)
    //------------
    wire SPI3_start;
    wire [7:0] SPI3_in;
    wire [7:0] SPI3_out;
    wire SPI3_done;

    SimpleSPI #(
    .CLKS_PER_HALF_BIT(1))
    SPI3(
    .clk        (clk),
    .reset      (reset),
    .in_byte    (SPI3_in),
    .start      (SPI3_start),
    .done       (SPI3_done),
    .out_byte   (SPI3_out),
    .spi_clk    (SPI3_clk),
    .miso       (SPI3_miso),
    .mosi       (SPI3_mosi)
    );


    //------------
    //SPI4 (EXT/GP)
    //------------
    wire SPI4_start;
    wire [7:0] SPI4_in;
    wire [7:0] SPI4_out;
    wire SPI4_done;

    SimpleSPI #(
    .CLKS_PER_HALF_BIT(2))
    SPI4(
    .clk        (clk),
    .reset      (reset),
    .in_byte    (SPI4_in),
    .start      (SPI4_start),
    .done       (SPI4_done),
    .out_byte   (SPI4_out),
    .spi_clk    (SPI4_clk),
    .miso       (SPI4_miso),
    .mosi       (SPI4_mosi)
    );




    //------------
    //GPIO
    //------------
    // TODO: To be implemented




    //------------
    //OS timer 1
    //------------
    wire OST1_trigger, OST1_set;
    wire [31:0] OST1_value;

    OStimer OST1(
    .clk        (clk),
    .reset      (reset),
    .timerValue (OST1_value),
    .setValue   (OST1_set),
    .trigger    (OST1_trigger),
    .interrupt  (OST1_int)
    );

    
    //------------
    //OS timer 2
    //------------
    wire OST2_trigger, OST2_set;
    wire [31:0] OST2_value;

    OStimer OST2(
    .clk        (clk),
    .reset      (reset),
    .timerValue (OST2_value),
    .setValue   (OST2_set),
    .trigger    (OST2_trigger),
    .interrupt  (OST2_int)
    );


    //------------
    //OS timer 3
    //------------
    wire OST3_trigger, OST3_set;
    wire [31:0] OST3_value;

    OStimer OST3(
    .clk        (clk),
    .reset      (reset),
    .timerValue (OST3_value),
    .setValue   (OST3_set),
    .trigger    (OST3_trigger),
    .interrupt  (OST3_int)
    );




    //------------
    //SNES controller
    //------------
    wire [15:0] SNES_state;
    wire SNES_done;
    wire SNES_start;

    NESpadReader npr (
    .clk(clk),
    .reset(reset),
    .nesc(SNES_clk),
    .nesl(SNES_latch),
    .nesd(SNES_data),
    .nesState(SNES_state),
    .frame(SNES_start),
    .done(SNES_done)
    );




    //------------
    //PS/2 keyboard
    //------------
    wire [7:0] PS2_scanCode;

    Keyboard PS2Keyboard (
    .clk            (clk), 
    .reset          (reset),
    .ps2d           (PS2_data), 
    .ps2c           (PS2_clk), 
    .rx_done_tick   (PS2_int), 
    .rx_data        (PS2_scanCode)
    );


reg [31:0] bus_d_reg = 32'd0;
reg [31:0] bus_q_reg = 32'd0;

//TODO: remove address clauses for data and address lines, since these only matter during writes, and we is protected anyways.

//assign initDone         = (SPIflashReader_initDone && sd_initDone);

//----
//MEMORY
//----

//SDRAM
/*
assign sd_addr              = (bus_addr < 27'h800000)                            ? bus_addr                   : 24'd0;
assign sd_d                 = (bus_addr < 27'h800000)                            ? bus_data                      : 32'd0;
assign sd_we                = (bus_addr < 27'h800000)                            ? bus_we                        : 1'd0;
assign sd_start             = (bus_addr < 27'h800000)                            ? bus_start                     : 1'd0;
*/

//SPI FLASH MEMORY
assign SPIflashReader_addr  = (bus_addr >= 27'h800000 && bus_addr < 27'hC00000)   ? bus_addr - 27'h800000      : 24'd0;
assign SPIflashReader_start = (bus_addr >= 27'h800000 && bus_addr < 27'hC00000)   ? bus_start                     : 1'd0;

//VRAM32
assign VRAM32_cpu_addr      = (bus_addr >= 27'hC00000 && bus_addr < 27'hC00420)   ? bus_addr - 27'hC00000      : 14'd0;
assign VRAM32_cpu_d         = (bus_addr >= 27'hC00000 && bus_addr < 27'hC00420)   ? bus_d_reg                      : 32'd0;
assign VRAM32_cpu_we        = (bus_addr >= 27'hC00000 && bus_addr < 27'hC00420)   ? bus_we                        : 1'd0;

//VRAM8
assign VRAM8_cpu_addr       = (bus_addr >= 27'hC00420 && bus_addr < 27'hC02422)   ? bus_addr - 27'hC00420      : 14'd0;
assign VRAM8_cpu_d          = (bus_addr >= 27'hC00420 && bus_addr < 27'hC02422)   ? bus_data                      : 8'd0;
assign VRAM8_cpu_we         = (bus_addr >= 27'hC00420 && bus_addr < 27'hC02422)   ? bus_we                        : 1'd0;

//VRAMspr
assign VRAMspr_cpu_addr     = (bus_addr >= 27'hC02422 && bus_addr < 27'hC02522)   ? bus_addr - 27'hC02422      : 14'd0;
assign VRAMspr_cpu_d        = (bus_addr >= 27'hC02422 && bus_addr < 27'hC02522)   ? bus_data                      : 9'd0;
assign VRAMspr_cpu_we       = (bus_addr >= 27'hC02422 && bus_addr < 27'hC02522)   ? bus_we                        : 1'd0;

//ROM
assign ROM_addr             = (bus_addr >= 27'hC02522 && bus_addr < 27'hC02722)   ? bus_addr - 27'hC02522      : 9'd0;

/* does not play nicely in simulation because of XX stuff. hardware is fine it appears. need to investigate further
//SPI FLASH MEMORY
assign SPIflashReader_addr  = (bus_addr >= 27'h800000 && bus_addr < 27'hC00000)   ? bus_addr - 27'h800000      : 24'd0;
assign SPIflashReader_start = (bus_addr >= 27'h800000 && bus_addr < 27'hC00000)   ? bus_start                     : 1'd0;

//VRAM32
assign VRAM32_cpu_addr      = bus_addr - 27'hC00000;
assign VRAM32_cpu_d         = bus_data;
assign VRAM32_cpu_we        = (bus_addr >= 27'hC00000 && bus_addr < 27'hC00420 && bus_we);

//VRAM8
assign VRAM8_cpu_addr       = bus_addr - 27'hC00420;
assign VRAM8_cpu_d          = bus_data;
assign VRAM8_cpu_we         = (bus_addr >= 27'hC00420 && bus_addr < 27'hC02422 && bus_we);

//VRAMspr
assign VRAMspr_cpu_addr     = bus_addr - 27'hC02422;
assign VRAMspr_cpu_d        = bus_data;
assign VRAMspr_cpu_we       = (bus_addr >= 27'hC02422 && bus_addr < 27'hC02522 && bus_we);

//ROM
assign ROM_addr             = bus_addr - 27'hC02522;
*/

//----
//I/O
//----

//UART
assign UART0_r_Tx_DV    = (bus_addr == 27'hC02723 && bus_we)                     ? bus_start                     : 1'b0;
assign UART0_r_Tx_Byte  = (bus_addr == 27'hC02723)                           ? bus_data                      : 8'd0;


assign UART1_r_Tx_DV    = (bus_addr == 27'hC02725 && bus_we)                     ? bus_start                     : 1'b0;
assign UART1_r_Tx_Byte  = (bus_addr == 27'hC02725)                           ? bus_data                      : 8'd0;

assign UART2_r_Tx_DV    = (bus_addr == 27'hC02727 && bus_we)                     ? bus_start                     : 1'b0;
assign UART2_r_Tx_Byte  = (bus_addr == 27'hC02727)                           ? bus_data                      : 8'd0;

//SPI
assign SPI0_in          = (bus_addr == 27'hC02728)                           ? bus_data                      : 8'd0;
assign SPI0_start       = (bus_addr == 27'hC02728 && bus_we)                     ? bus_start                     : 1'b0;

assign SPI1_in          = (bus_addr == 27'hC0272B)                           ? bus_data                      : 8'd0;
assign SPI1_start       = (bus_addr == 27'hC0272B && bus_we)                     ? bus_start                     : 1'b0;

assign SPI2_in          = (bus_addr == 27'hC0272E)                           ? bus_data                      : 8'd0;
assign SPI2_start       = (bus_addr == 27'hC0272E && bus_we)                     ? bus_start                     : 1'b0;

assign SPI3_in          = (bus_addr == 27'hC02731)                           ? bus_data                      : 8'd0;
assign SPI3_start       = (bus_addr == 27'hC02731 && bus_we)                     ? bus_start                     : 1'b0;

assign SPI4_in          = (bus_addr == 27'hC02734)                           ? bus_data                      : 8'd0;
assign SPI4_start       = (bus_addr == 27'hC02734 && bus_we)                     ? bus_start                     : 1'b0;

//OS Timers
assign OST1_value       = (bus_addr == 27'hC02739 && bus_we)                     ? bus_data                      : 32'd0;
assign OST1_set         = (bus_addr == 27'hC02739 && bus_we);
assign OST1_trigger     = (bus_addr == 27'hC0273A && bus_we);

assign OST2_value       = (bus_addr == 27'hC0273B && bus_we)                     ? bus_data                      : 32'd0;
assign OST2_set         = (bus_addr == 27'hC0273B && bus_we);
assign OST2_trigger     = (bus_addr == 27'hC0273C && bus_we);

assign OST3_value       = (bus_addr == 27'hC0273D && bus_we)                     ? bus_data                      : 32'd0;
assign OST3_set         = (bus_addr == 27'hC0273D && bus_we);
assign OST3_trigger     = (bus_addr == 27'hC0273E && bus_we);

//SNES
assign SNES_start       = (bus_addr == 27'hC0273F)                              ? bus_start                     : 1'b0;


assign bus_q =      //(bus_start && bus_addr >= 27'hC00000 && bus_addr < 27'hC00420) ? VRAM32_cpu_q:
                    //(bus_start && bus_addr >= 27'hC00420 && bus_addr < 27'hC02422) ? {24'd0, VRAM8_cpu_q}:
                    //(bus_start && bus_addr >= 27'hC02422 && bus_addr < 27'hC02522) ? {23'd0, VRAMspr_cpu_q}:
                    (bus_addr >= 27'hC02522 && bus_addr < 27'hC02722) ? ROM_q: // safe because ROM cannot be the destination of a copy instruction
                    bus_q_reg;

reg bus_done_next = 1'b0;

always @(posedge clk)
begin
    if (reset)
    begin
        GPO         <= 4'd0;
        SPI0_enable <= 1'b0;
        bus_q_reg <= 32'd0;
        bus_done <= 1'b0;
        bus_done_next <= 1'b0;
        sd_addr     <= 27'd0;
        sd_d        <= 32'd0;
        sd_we       <= 1'b0;
        sd_start    <= 1'b0;
        bus_d_reg <= 32'd0;
    end
    else 
    begin
        bus_d_reg <= bus_data; // latch for copy instructions to SRAM/regs


        if (bus_done_next)
        begin
            bus_done_next <= 1'b0;
            bus_done <= 1'b1;
        end
        else 
        begin
            bus_done <= 1'b0;
        end
        
        

        //------
        //MEMORY
        //------

        //SDRAM
        if (bus_start && bus_addr < 27'h800000 && (!bus_done_next))
        begin
            sd_addr     <= bus_addr;
            sd_d        <= bus_data;
            sd_we       <= bus_we;
            sd_start    <= bus_start;
            if (sd_q_ready && sd_initDone)
            begin
                bus_done <= 1'b1;
                //bus_done_next <= 1'b1;
                sd_addr     <= 24'd0;
                sd_d        <= 32'd0;
                sd_we       <= 1'b0;
                sd_start    <= 1'b0;
                bus_q_reg       <= sd_q;
            end
        end

        //SPI FLASH
        if (bus_start && bus_addr >= 27'h800000 && bus_addr < 27'hC00000)
        begin
            if (SPIflashReader_recvDone || SPI0_enable)
            begin
                bus_done <= 1'b1;
                //if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= SPIflashReader_q;
            end
        end

        if (bus_addr >= 27'h800000 && bus_addr < 27'hC00000) bus_q_reg <= SPIflashReader_q;

        if (bus_addr >= 27'hC00000 && bus_addr < 27'hC00420) bus_q_reg <= VRAM32_cpu_q;

        if (bus_addr >= 27'hC00420 && bus_addr < 27'hC02422) bus_q_reg <= {24'd0, VRAM8_cpu_q};

        if (bus_addr >= 27'hC02422 && bus_addr < 27'hC02522) bus_q_reg <= {23'd0, VRAMspr_cpu_q};
        
        if (bus_addr >= 27'hC02522 && bus_addr < 27'hC02722) bus_q_reg <= ROM_q;
                
        if (bus_addr == 27'hC02722) bus_q_reg <= UART0_w_Rx_Byte;

        //UART0 TX
        if (bus_start && bus_addr == 27'hC02723)
        begin
            if (UART0_w_Tx_Done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= 32'd0;
            end
        end
            
        if (bus_addr == 27'hC02724) bus_q_reg <= UART1_w_Rx_Byte;

        //UART1 TX
        if (bus_start && bus_addr == 27'hC02725)
        begin
            if (UART1_w_Tx_Done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= 32'd0;
            end
        end

        if (bus_addr == 27'hC02726) bus_q_reg <= UART2_w_Rx_Byte;

        //UART2 TX
        if (bus_start && bus_addr == 27'hC02727)
        begin
            if (UART2_w_Tx_Done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= 32'd0;
            end
        end


        //SPI0
        if (bus_start && bus_addr == 27'hC02728)
        begin
            if (SPI0_done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= SPI0_out;
            end
        end

        //SPI0 CS
        if (bus_start && bus_addr == 27'hC02729)
        begin
            if (bus_we)
            begin
                SPI0_cs <= bus_data[0];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= SPI0_cs;
        end

        //SPI0 enable
        if (bus_start && bus_addr == 27'hC0272A)
        begin
            if (bus_we)
            begin
                SPI0_enable <= bus_data[0];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= SPI0_enable;
        end


        //SPI1
        if (bus_start && bus_addr == 27'hC0272B)
        begin
            if (SPI1_done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= SPI1_out;
            end
        end

        //SPI1 CS
        if (bus_start && bus_addr == 27'hC0272C)
        begin
            if (bus_we)
            begin
                SPI1_cs <= bus_data[0];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= SPI1_cs;
        end

        if (bus_addr == 27'hC0272D) bus_q_reg <= SPI1_nint;

        //SPI2
        if (bus_start && bus_addr == 27'hC0272E)
        begin
            if (SPI2_done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= SPI2_out;
            end
        end


        //SPI2 CS
        if (bus_start && bus_addr == 27'hC0272F)
        begin
            if (bus_we)
            begin
                SPI2_cs <= bus_data[0];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= SPI2_cs;
        end

        if (bus_addr == 27'hC02730) bus_q_reg <= SPI2_nint;

        //SPI3
        if (bus_start && bus_addr == 27'hC02731)
        begin
            if (SPI3_done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= SPI3_out;
            end
        end

        //SPI3 CS
        if (bus_start && bus_addr == 27'hC02732)
        begin
            if (bus_we)
            begin
                SPI3_cs <= bus_data[0];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= SPI3_cs;
        end

        if (bus_addr == 27'hC02733) bus_q_reg <= SPI3_int;

        //SPI4
        if (bus_start && bus_addr == 27'hC02734)
        begin
            if (SPI4_done)
            begin
                if (!bus_done_next) bus_done_next <= 1'b1;
                bus_q_reg <= SPI4_out;
            end
        end

        //SPI4 CS
        if (bus_start && bus_addr == 27'hC02735)
        begin
            if (bus_we)
            begin
                SPI4_cs <= bus_data[0];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= SPI4_cs;
        end

        if (bus_addr == 27'hC02736) bus_q_reg <= SPI4_GP;

        //GPIO TODO: implement true GPIO
        if (bus_start && bus_addr == 27'hC02737)
        begin
            if (bus_we)
            begin
                GPO <= bus_data[7:4];
            end
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= {24'd0, GPO, GPI};
        end

        //GPIO Direction TODO: implement
        if (bus_start && bus_addr == 27'hC02738)
        begin
            if (!bus_done_next) bus_done_next <= 1'b1;
            bus_q_reg <= 32'd0;
        end


        if (bus_start && bus_addr == 27'hC0273F) 
        begin
            if (SNES_done)
                begin
                    if (!bus_done_next) bus_done_next <= 1'b1;
                    bus_q_reg <= {16'd0, SNES_state};
                end
        end

        if (bus_addr == 27'hC02740) bus_q_reg <= {24'd0, PS2_scanCode};
        
        if (bus_addr == 27'hC02741) bus_q_reg <= {31'd0, boot_mode};

        //Instant return addresses
        if (bus_start)
        begin
            //VRAM & ROM
            if (bus_addr >= 27'hC00000 && bus_addr < 27'hC02522) // VRAM
                if (bus_we)
                    bus_done <= 1'b1;
                else
                    if (!bus_done_next) bus_done_next <= 1'b1;
            if (bus_addr >= 27'hC02522 && bus_addr < 27'hC02722) // ROM
                    bus_done <= 1'b1;
            if (bus_addr == 27'hC02722 ||
                bus_addr == 27'hC02724 ||
                bus_addr == 27'hC02726 ||
                bus_addr == 27'hC0272D ||
                bus_addr == 27'hC02730 ||
                bus_addr == 27'hC02733 ||
                bus_addr == 27'hC02736 ||
                bus_addr == 27'hC02739 ||
                bus_addr == 27'hC0273A ||
                bus_addr == 27'hC0273B ||
                bus_addr == 27'hC0273C ||
                bus_addr == 27'hC0273D ||
                bus_addr == 27'hC0273E ||
                bus_addr > 27'hC0273F)
                if (!bus_done_next) bus_done_next <= 1'b1;
        end

    end
    
end

endmodule