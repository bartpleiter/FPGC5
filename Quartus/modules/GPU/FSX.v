/*
* Graphical processor (Frame Synthesizer)
* Generates video from VRAM
*/
module FSX(
    //Clocks
    input clkPixel,
    input clkTMDShalf,
    input clk14,
    input clk114,
    input clkMuxOut,

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
    .dataout    (TMDS_n),
    .dataout_b  (TMDS_p) // Reversed because of a LVDS polarity swap on the V3 PCB
);


wire [11:0] h_count_hdmi;
wire [11:0] v_count_hdmi;

wire hsync_hdmi;
wire vsync_hdmi;
wire csync;
wire blank_hdmi;
wire frameDrawn_hdmi;

TimingGenerator timingGenerator(
    // Clock
    .clkPixel(clkPixel),

    // Position counters
    .h_count(h_count_hdmi),
    .v_count(v_count_hdmi),

    // Video signals
    .hsync(hsync_hdmi),
    .vsync(vsync_hdmi),
    .csync(csync),
    .blank(blank_hdmi),
    
    // Interrupt signal
    .frameDrawn(frameDrawn_hdmi)
);


wire [2:0] r_ntsc;
wire [2:0] g_ntsc;
wire [1:0] b_ntsc;


wire frameDrawn_ntsc;
wire [11:0] h_count_ntsc;
wire [11:0] v_count_ntsc;

wire hsync_ntsc;
wire vsync_ntsc;
wire blank_ntsc;


RGB332toNTSC rgb2ntsc(
    .clk(clk14), //14.318MHz
    .clkColor(clk114), //114.5454MHz
    .r(r_ntsc),
    .g(g_ntsc),
    .b(b_ntsc),
    .hcount(h_count_ntsc),
    .vcount(v_count_ntsc),
    .hs(hsync_ntsc),
    .vs(vsync_ntsc),
    .blank(blank_ntsc),
    .composite(composite), // video output signal
    .frameDrawn(frameDrawn_ntsc) // interrupt signal
);


wire hsync;
wire vsync;
wire blank;
wire [11:0] h_count;
wire [11:0] v_count;

assign frameDrawn   = (selectOutput == 1'b1) ? frameDrawn_hdmi : frameDrawn_ntsc;
assign hsync        = (selectOutput == 1'b1) ? hsync_hdmi : hsync_ntsc;
assign vsync        = (selectOutput == 1'b1) ? vsync_hdmi : ~vsync_ntsc; // ntsc vsync is inverted
assign blank        = (selectOutput == 1'b1) ? blank_hdmi : blank_ntsc;
assign h_count      = (selectOutput == 1'b1) ? h_count_hdmi : h_count_ntsc;
assign v_count      = (selectOutput == 1'b1) ? v_count_hdmi : v_count_ntsc;


wire [2:0] BGW_r;
wire [2:0] BGW_g;
wire [1:0] BGW_b;


BGWrenderer bgwrenderer(
    // Video I/O
    .clk(clkMuxOut),
    .hs(hsync),
    .vs(vsync),
    .blank(blank),

    .scale2x(selectOutput),
    
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


assign r_ntsc = (!selectOutput) ? BGW_r : 3'd0;
assign g_ntsc = (!selectOutput) ? BGW_g : 3'd0;
assign b_ntsc = (!selectOutput) ? BGW_b : 2'd0;


wire [2:0] r_hdmi;
wire [2:0] g_hdmi;
wire [1:0] b_hdmi;

assign r_hdmi = (selectOutput) ? BGW_r : 3'd0;
assign g_hdmi = (selectOutput) ? BGW_g : 3'd0;
assign b_hdmi = (selectOutput) ? BGW_b : 2'd0;

wire [7:0] rByte;
wire [7:0] gByte;
wire [7:0] bByte;

assign rByte = (r_hdmi == 3'd0) ?  {r_hdmi, 5'b00000} : {r_hdmi, 5'b11111};
assign gByte = (g_hdmi == 3'd0) ?  {g_hdmi, 5'b00000} : {g_hdmi, 5'b11111};
assign bByte = (b_hdmi == 2'd0) ?  {b_hdmi, 6'b000000} : {b_hdmi, 6'b111111};


// Convert VGA signal to HDMI signals
RGB2HDMI rgb2hdmi(
    .clkTMDS(clkTMDShalf),
    .clkRGB (clkPixel),
    .rRGB   (rByte),
    .gRGB   (gByte),
    .bRGB   (bByte),
    .blk    (blank_hdmi),
    .hs     (hsync_hdmi),
    .vs     (vsync_hdmi), 
    .bTMDS  (TMDS[0]),
    .gTMDS  (TMDS[1]),
    .rTMDS  (TMDS[2]),
    .cTMDS  (TMDS[3])
);


/*
// Image file generator for simulation
integer file;
integer framecounter = 0;
always @(negedge vsync_hdmi)
begin
    file = $fopen($sformatf("/home/bart/Documents/FPGA/FPGC5/Verilog/output/frame%0d.ppm", framecounter), "w");
    $fwrite(file, "P3\n");
    $fwrite(file, "640 480\n");
    $fwrite(file, "255\n");
    framecounter = framecounter + 1;
end

always @(posedge clkPixel)
begin
    if (~blank_hdmi)
    begin
        $fwrite(file, "%d  %d  %d\n", rByte, gByte, bByte);
    end
end
*/

endmodule
