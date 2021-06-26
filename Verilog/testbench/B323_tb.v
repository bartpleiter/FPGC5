/*
 * Testbench
 * Simulates the B323 CPU
*/
//Set timescale
`timescale 1 ns/1 ns

//Include modules
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/CPU.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/ALU.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/ControlUnit.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/InstructionDecoder.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/PC.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/Regbank.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/Stack.v"
`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/CPU/Timer.v"

//Define testmodule
module B323_tb;

//---------------CPU----------------
//CPU I/O
reg clk = 0;
reg reset = 0;
reg int1, int2, int3, int4, ext_int1, ext_int2, ext_int3, ext_int4 = 0;

wire [26:0] address;    //out
wire [31:0] data;       //out
wire we;                //out
reg [31:0] q = 32'd0;   //in
wire start;             //out
reg busy = 1'b0;        //in

CPU cpu(
.clk        (clk),
.reset      (reset),
.int1       (int1),     //OStimer1
.int2       (int2),     //OStimer2
.int3       (int3),     //UART0 rx (MAIN)
.int4       (int4),     //GPU Frame Drawn
.ext_int1   (ext_int1), //OStimer3
.ext_int2   (ext_int2), //PS/2 scancode ready
.ext_int3   (ext_int3), //UART1 rx (APU)
.ext_int4   (ext_int4), //UART2 rx (EXT)
.address    (address),
.data       (data),
.we         (we),
.q          (q),
.start      (start),
.busy       (busy)
);

//-------------MU replacement---------------

reg [31:0] rom [0:511];

always @(posedge clk) 
begin
    if (start)
        q <= rom[address];
end


initial
begin
    $readmemb("/home/bart/Documents/FPGA/FPGC5/Verilog/memory/mu.list", rom);

    //Dump everything for GTKwave
    $dumpfile("/home/bart/Documents/FPGA/FPGC5/Verilog/output/wave.vcd");
    $dumpvars;
    
    repeat(5000) #20 clk = ~clk; //25MHz


    #1 $finish;
end

endmodule
