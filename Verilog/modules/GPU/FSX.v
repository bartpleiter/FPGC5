/*
* Graphical processor (Frame Synthesizer)
* Generates video from VRAM
*/
module FSX(
    //Clocks
    input clkPixel,
    input clkTMDShalf,

    //HDMI
    output [3:0] TMDS_p,
    output [3:0] TMDS_n,

    //NTSC composite
    output [7:0] composite,

    //Select output method
    input selectOutput,

    //VRAM32
    output [13:0]       vram32_addr,
    input  [31:0]       vram32_q, 

    //VRAM322
    output [13:0]       vram322_addr,
    input  [31:0]       vram322_q, 

    //VRAM8
    output [13:0]       vram8_addr,
    input  [7:0]        vram8_q,

    //VRAMSPR
    output [13:0]       vramSPR_addr,
    input  [8:0]        vramSPR_q,

    //Interrupt signal
    output              frameDrawn
);

// LVDS Converter
wire [3:0] TMDS;

lvds lvdsConverter(
    .datain     (TMDS),
    .dataout    (TMDS_p),
    .dataout_b  (TMDS_n)
);


wire [11:0] h_count;
wire [11:0] v_count;

wire hsync;
wire vsync;
wire csync;
wire blank;

TimingGenerator timingGenerator(
    // Clock
    .clkPixel(clkPixel),

    // Position counters
    .h_count(h_count),
    .v_count(v_count),

    // Video signals
    .hsync(hsync),
    .vsync(vsync),
    .csync(csync),
    .blank(blank),
    
    // Interrupt signal
    .frameDrawn(frameDrawn)
);


wire [2:0] BGW_r;
wire [2:0] BGW_g;
wire [1:0] BGW_b;


BGWrenderer bgwrenderer(
    // Video I/O
    .clk(clkPixel),
    .hs(hsync),
    .vs(vsync),
    .blank(blank),
    
    // Output colors
    .r(BGW_r),
    .g(BGW_g),
    .b(BGW_b),

    .h_count(h_count),  // line position in pixels including blanking 
    .v_count(v_count),  // frame position in lines including blanking 

    // VRAM32
    .vram32_addr(vram32_addr),
    .vram32_q(vram32_q), 

    // VRAM8
    .vram8_addr(vram8_addr),
    .vram8_q(vram8_q)
);



wire [2:0] r;
wire [2:0] g;
wire [1:0] b;

assign r = BGW_r;
assign g = BGW_g;
assign b = BGW_b;


wire [7:0] rByte;
wire [7:0] gByte;
wire [7:0] bByte;

assign rByte = r[0] ? {r, 5'b11111} : {r, 5'b00000};
assign gByte = g[0] ? {g, 5'b11111} : {g, 5'b00000};
assign bByte = b[0] ? {b, 6'b111111} : {b, 6'b000000};


// Convert VGA signal to HDMI signals
RGB2HDMI rgb2hdmi(
    .clkTMDS(clkTMDShalf),
    .clkRGB (clkPixel),
    .rRGB   (rByte),
    .gRGB   (gByte),
    .bRGB   (bByte),
    .blk    (blank),
    .hs     (hsync),
    .vs     (vsync), 
    .bTMDS  (TMDS[0]),
    .gTMDS  (TMDS[1]),
    .rTMDS  (TMDS[2]),
    .cTMDS  (TMDS[3])
);


// Image file generator for simulation
integer file;
integer framecounter = 0;
always @(negedge vsync)
begin
    //$display($sformatf("/home/bart/Documents/FPGA/FSX3/output/frame%0d.ppm", framecounter));
    file = $fopen($sformatf("/home/bart/Documents/FPGA/FSX3/output/frame%0d.ppm", framecounter), "w");
    $fwrite(file, "P3\n");
    $fwrite(file, "640 480\n");
    $fwrite(file, "7\n");
    framecounter = framecounter + 1;
end

always @(posedge clkPixel)
begin
    if (~blank)
    begin
        $fwrite(file, "%d  %d  %d\n", r, g, {1'b1, b});
    end
end





endmodule