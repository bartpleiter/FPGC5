/*
* Memory Unit
* Requests by CPU are made on the posedge of clk.
* Modules work on the negedge of clk.
*/
module MemoryUnit(
    //clock
    input           clk, reset,

    //CPU connection (bus)
    input  [26:0]   address,
    input  [31:0]   data,
    input           we,
    input           start,          //Start should be high until busy = low
    output          initDone,       //High when initialization is done
    output reg      busy,
    output reg [31:0]  q,

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
    output reg      SPI1_cs,
    output          SPI1_mosi,
    input           SPI1_miso,
    input           SPI1_nint,

    //SPI2 (USB1/CH376T)
    output          SPI2_clk,
    output reg      SPI2_cs,
    output          SPI2_mosi,
    input           SPI2_miso,
    input           SPI2_nint,

    //SPI3 (W5500)
    output          SPI3_clk,
    output reg      SPI3_cs,
    output          SPI3_mosi,
    input           SPI3_miso,
    input           SPI3_int,

    //SPI4 (EXT/GP)
    output          SPI4_clk,
    output reg      SPI4_cs,
    output          SPI4_mosi,
    input           SPI4_miso,
    input           SPI4_GP,

    //GPIO (Separated GPI and GPO until GPIO module is implemented)
    input [3:0]     GPI,
    output reg [3:0]GPO,

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
    reg  SPI0_enable; //high enables SPI0 and disables SPIreader
    wire SPI0_start;
    wire [7:0] SPI0_in;
    wire [7:0] SPI0_out;
    wire SPI0_busy;

    SimpleFastSPI SPI0(
    .clk        (clk),
    .reset      (reset),
    .t_start    (SPI0_start),
    .d_in       (SPI0_in),
    .d_out      (SPI0_out),
    .spi_clk    (SPI0_clk),
    .miso       (SPIflash_q),
    .mosi       (SPI0_mosi),
    .busy       (SPI0_busy)
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
    wire        sd_we;
    wire        sd_start;
    wire [31:0] sd_d; 
    wire [23:0] sd_addr;

    wire        sd_busy;
    wire        sd_initDone;
    wire        sd_q_ready;
    wire [31:0] sd_q;

    SDRAMcontroller sdramcontroller(
    .clk        (clk), // TODO: now must be 100MHz
    .reset      (reset),

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
    .o_Tx_Done_l(UART0_w_Tx_Done)
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
    .o_Tx_Done_l(UART1_w_Tx_Done)
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
    .o_Tx_Done_l(UART2_w_Tx_Done)
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
    wire SPI1_busy;

    SimpleSPI #(
    .CLKDIV(4))
    SPI1(
    .clk        (clk),
    .reset      (reset),
    .t_start    (SPI1_start),
    .d_in       (SPI1_in),
    .d_out      (SPI1_out),
    .spi_clk    (SPI1_clk),
    .miso       (SPI1_miso),
    .mosi       (SPI1_mosi),
    .busy       (SPI1_busy)
    );


    //------------
    //SPI2 (CH376T top)
    //------------
    wire SPI2_start;
    wire [7:0] SPI2_in;
    wire [7:0] SPI2_out;
    wire SPI2_busy;

    SimpleSPI #(
    .CLKDIV(4))
    SPI2(
    .clk        (clk),
    .reset      (reset),
    .t_start    (SPI2_start),
    .d_in       (SPI2_in),
    .d_out      (SPI2_out),
    .spi_clk    (SPI2_clk),
    .miso       (SPI2_miso),
    .mosi       (SPI2_mosi),
    .busy       (SPI2_busy)
    );


    //------------
    //SPI3 (W5500)
    //------------
    wire SPI3_start;
    wire [7:0] SPI3_in;
    wire [7:0] SPI3_out;
    wire SPI3_busy;

    SimpleFastSPI SPI3(
    .clk        (clk),
    .reset      (reset),
    .t_start    (SPI3_start),
    .d_in       (SPI3_in),
    .d_out      (SPI3_out),
    .spi_clk    (SPI3_clk),
    .miso       (SPI3_miso),
    .mosi       (SPI3_mosi),
    .busy       (SPI3_busy)
    );


    //------------
    //SPI4 (EXT/GP)
    //------------
    wire SPI4_start;
    wire [7:0] SPI4_in;
    wire [7:0] SPI4_out;
    wire SPI4_busy;

    SimpleSPI #(
    .CLKDIV(4))
    SPI4(
    .clk        (clk),
    .reset      (reset),
    .t_start    (SPI4_start),
    .d_in       (SPI4_in),
    .d_out      (SPI4_out),
    .spi_clk    (SPI4_clk),
    .miso       (SPI4_miso),
    .mosi       (SPI4_mosi),
    .busy       (SPI4_busy)
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

    NESpadReader npr (
    .clk(clk),
    .reset(reset),
    .nesc(SNES_clk),
    .nesl(SNES_latch),
    .nesd(SNES_data),
    .nesState(SNES_state)
    );




    //------------
    //PS/2 keyboard
    //------------
    wire [7:0] PS2_scanCode;

    Keyboard PS2Keyboard (
    .clk            (clk), 
    .reset          (reset), 
    .rx_en          (1'b1), 
    .ps2d           (PS2_data), 
    .ps2c           (PS2_clk), 
    .rx_done_tick   (PS2_int), 
    .rx_data        (PS2_scanCode)
    );






assign initDone         = (SPIflashReader_initDone && sd_initDone);

//----
//MEMORY
//----

//SDRAM
assign sd_addr              = (address < 27'h800000)                            ? address                   : 24'd0;
assign sd_d                 = (address < 27'h800000)                            ? data                      : 32'd0;
assign sd_we                = (address < 27'h800000)                            ? we                        : 1'd0;
assign sd_start             = (address < 27'h800000)                            ? start                     : 1'd0;

//SPI FLASH MEMORY
assign SPIflashReader_addr  = (address >= 27'h800000 && address < 27'hC00000)   ? address - 27'h800000      : 24'd0;
assign SPIflashReader_start = (address >= 27'h800000 && address < 27'hC00000)   ? start                     : 1'd0;

//VRAM32
assign VRAM32_cpu_addr      = (address >= 27'hC00000 && address < 27'hC00420)   ? address - 27'hC00000      : 14'd0;
assign VRAM32_cpu_d         = (address >= 27'hC00000 && address < 27'hC00420)   ? data                      : 32'd0;
assign VRAM32_cpu_we        = (address >= 27'hC00000 && address < 27'hC00420)   ? we                        : 1'd0;

//VRAM8
assign VRAM8_cpu_addr       = (address >= 27'hC00420 && address < 27'hC02422)   ? address - 27'hC00420      : 14'd0;
assign VRAM8_cpu_d          = (address >= 27'hC00420 && address < 27'hC02422)   ? data                      : 8'd0;
assign VRAM8_cpu_we         = (address >= 27'hC00420 && address < 27'hC02422)   ? we                        : 1'd0;

//VRAMspr
assign VRAMspr_cpu_addr     = (address >= 27'hC02422 && address < 27'hC02522)   ? address - 27'hC02422      : 14'd0;
assign VRAMspr_cpu_d        = (address >= 27'hC02422 && address < 27'hC02522)   ? data                      : 9'd0;
assign VRAMspr_cpu_we       = (address >= 27'hC02422 && address < 27'hC02522)   ? we                        : 1'd0;

//ROM
assign ROM_addr             = (address >= 27'hC02522 && address < 27'hC02722)   ? address - 27'hC02522      : 9'd0;

//----
//I/O
//----

//UART
assign UART0_r_Tx_DV    = (address == 27'hC02723 && we)                     ? start                     : 1'b0;
assign UART0_r_Tx_Byte  = (address == 27'hC02723)                           ? data                      : 8'd0;

assign UART1_r_Tx_DV    = (address == 27'hC02725 && we)                     ? start                     : 1'b0;
assign UART1_r_Tx_Byte  = (address == 27'hC02725)                           ? data                      : 8'd0;

assign UART2_r_Tx_DV    = (address == 27'hC02727 && we)                     ? start                     : 1'b0;
assign UART2_r_Tx_Byte  = (address == 27'hC02727)                           ? data                      : 8'd0;

//SPI
assign SPI0_in          = (address == 27'hC02728)                           ? data                      : 8'd0;
assign SPI0_start       = (address == 27'hC02728 && we)                     ? start                     : 1'b0;

assign SPI1_in          = (address == 27'hC0272B)                           ? data                      : 8'd0;
assign SPI1_start       = (address == 27'hC0272B && we)                     ? start                     : 1'b0;

assign SPI2_in          = (address == 27'hC0272E)                           ? data                      : 8'd0;
assign SPI2_start       = (address == 27'hC0272E && we)                     ? start                     : 1'b0;

assign SPI3_in          = (address == 27'hC02731)                           ? data                      : 8'd0;
assign SPI3_start       = (address == 27'hC02731 && we)                     ? start                     : 1'b0;

assign SPI4_in          = (address == 27'hC02734)                           ? data                      : 8'd0;
assign SPI4_start       = (address == 27'hC02734 && we)                     ? start                     : 1'b0;

//OS Timers
assign OST1_value       = (address == 27'hC02739 && we)                     ? data                      : 32'd0;
assign OST1_set         = (address == 27'hC02739 && we);
assign OST1_trigger     = (address == 27'hC0273A && we);

assign OST2_value       = (address == 27'hC0273B && we)                     ? data                      : 32'd0;
assign OST2_set         = (address == 27'hC0273B && we);
assign OST2_trigger     = (address == 27'hC0273C && we);

assign OST3_value       = (address == 27'hC0273D && we)                     ? data                      : 32'd0;
assign OST3_set         = (address == 27'hC0273D && we);
assign OST3_trigger     = (address == 27'hC0273E && we);


// TODO: minimize statements/return values by removing unnecessary ones

initial
begin
    busy        <= 0;
    q           <= 32'd0;

    GPO         <= 4'd0;
    SPI0_enable <= 1'b0;
end

always @(negedge clk)
begin
    if (reset)
    begin
        busy        <= 0;
        q           <= 32'd0;

        GPO         <= 4'd0;
        SPI0_enable <= 1'b0;
    end
    else 
    begin
        
        if (start)
            busy    <= 1;


        //------
        //MEMORY
        //------

        //SDRAM
        if (busy && address < 27'h800000 && sd_q_ready)
        begin
            busy    <= 0;
            q       <= sd_q;
        end

        //SPI FLASH
        if (busy && address >= 27'h800000 && address < 27'hC00000 && (SPIflashReader_recvDone || SPI0_enable))
        begin
            busy    <= 0;
            q       <= SPIflashReader_q;
        end

        //VRAM32
        if (busy && address >= 27'hC00000 && address < 27'hC00420)
        begin
            busy    <= 0;
            q       <= VRAM32_cpu_q;
        end

        //VRAM8
        if (busy && address >= 27'hC00420 && address < 27'hC02422)
        begin
            busy    <= 0;
            q       <= {24'd0, VRAM8_cpu_q};
        end

        //VRAMspr
        if (busy && address >= 27'hC02422 && address < 27'hC02522)
        begin
            busy    <= 0;
            q       <= {23'd0, VRAMspr_cpu_q};
        end

        //ROM
        if (busy && address >= 27'hC02522 && address < 27'hC02722)
        begin
            busy    <= 0;
            q       <= ROM_q;
        end


        //------
        //I/O
        //------

        //UART0 RX
        if (busy && address == 27'hC02722)
        begin
            busy    <= 0;
            q       <= UART0_w_Rx_Byte;
        end

        //UART0 TX
        if (busy && address == 27'hC02723)
        begin
            if (UART0_w_Tx_Done)
            begin
                busy    <= 0;
                q       <= 32'd0;
            end
        end

        //UART1 RX
        if (busy && address == 27'hC02724)
        begin
            busy    <= 0;
            q       <= UART1_w_Rx_Byte;
        end

        //UART1 TX
        if (busy && address == 27'hC02725)
        begin
            if (UART1_w_Tx_Done)
            begin
                busy    <= 0;
                q       <= 32'd0;
            end
        end

        //UART2 RX
        if (busy && address == 27'hC02726)
        begin
            busy    <= 0;
            q       <= UART2_w_Rx_Byte;
        end

        //UART2 TX
        if (busy && address == 27'hC02727)
        begin
            if (UART2_w_Tx_Done)
            begin
                busy    <= 0;
                q       <= 32'd0;
            end
        end


        //SPI0
        if (busy && address == 27'hC02728 && !SPI0_busy)
        begin
            busy    <= 0;
            q       <= SPI0_out;
        end

        //SPI0 CS
        if (busy && address == 27'hC02729)
        begin
            if (we)
            begin
                SPI0_cs <= data[0];
            end
            busy    <= 0;
            q       <= SPI0_cs;
        end

        //SPI0 enable
        if (busy && address == 27'hC0272A)
        begin
            if (we)
            begin
                SPI0_enable <= data[0];
            end
            busy    <= 0;
            q       <= SPI0_enable;
        end


        //SPI1
        if (busy && address == 27'hC0272B && !SPI1_busy)
        begin
            busy    <= 0;
            q       <= SPI1_out;
        end

        //SPI1 CS
        if (busy && address == 27'hC0272C)
        begin
            if (we)
            begin
                SPI1_cs <= data[0];
            end
            busy    <= 0;
            q       <= SPI1_cs;
        end

        //SPI1 nInt
        if (busy && address == 27'hC0272D)
        begin
            busy    <= 0;
            q       <= SPI1_nint;
        end


        //SPI2
        if (busy && address == 27'hC0272E && !SPI2_busy)
        begin
            busy    <= 0;
            q       <= SPI2_out;
        end

        //SPI2 CS
        if (busy && address == 27'hC0272F)
        begin
            if (we)
            begin
                SPI2_cs <= data[0];
            end
            busy    <= 0;
            q       <= SPI2_cs;
        end

        //SPI2 nInt
        if (busy && address == 27'hC02730)
        begin
            busy    <= 0;
            q       <= SPI2_nint;
        end


        //SPI3
        if (busy && address == 27'hC02731 && !SPI3_busy)
        begin
            busy    <= 0;
            q       <= SPI3_out;
        end

        //SPI3 CS
        if (busy && address == 27'hC02732)
        begin
            if (we)
            begin
                SPI3_cs <= data[0];
            end
            busy    <= 0;
            q       <= SPI3_cs;
        end

        //SPI3 int
        if (busy && address == 27'hC02733)
        begin
            busy    <= 0;
            q       <= SPI3_int;
        end


        //SPI4
        if (busy && address == 27'hC02734 && !SPI4_busy)
        begin
            busy    <= 0;
            q       <= SPI4_out;
        end

        //SPI4 CS
        if (busy && address == 27'hC02735)
        begin
            if (we)
            begin
                SPI4_cs <= data[0];
            end
            busy    <= 0;
            q       <= SPI4_cs;
        end

        //SPI4 GP (currently input)
        if (busy && address == 27'hC02736)
        begin
            busy    <= 0;
            q       <= SPI4_GP;
        end


        //GPIO TODO: implement true GPIO
        if (busy && address == 27'hC02737)
        begin
            if (we)
            begin
                GPO <= data[7:4];
            end
            busy    <= 0;
            q       <= {24'd0, GPO, GPI};
        end

        //GPIO Direction TODO: implement
        if (busy && address >= 27'hC02738)
        begin
            busy    <= 0;
            q       <= 32'd0;
        end

        //OS Timers (do not return anything)
        if (busy && address >= 27'hC02738 && address < 27'hC0273F)
        begin
            busy    <= 0;
            q       <= 32'd0;
        end


        //SNESpad
        if (busy && address == 27'hC0273F)
        begin
            busy    <= 0;
            q       <= {16'd0, SNES_state};
        end

        //PS/2 Keyboard
        if (busy && address == 27'hC02740)
        begin
            busy    <= 0;
            q       <= {24'd0, PS2_scanCode};
        end


        //Boot mode
        if (busy && address == 27'hC02741)
        begin
            busy    <= 0;
            q       <= {31'd0, boot_mode};
        end


        //Prevent lockups
        if (busy && address > 27'hC02741)
        begin
            busy    <= 0;
            q       <= 32'd0;
        end

    end
    
end

endmodule