/*
* Decodes the instruction by selecting bits
*/
module InstructionDecoder(
    input clk, reset, fetch, getRegs,
    input [31:0] q,
    
    output [3:0] instrOP,

    output [10:0] const11,
    output [15:0] const16,
    output [26:0] const27,

    output [3:0] areg, breg, dreg,

    output [3:0] opcode,
    output ce, he, oe, intf, n1, n2
);

wire [31:0] instruction;

assign instruction =    (fetch || getRegs) ? q:
                        instructionReg;

reg [31:0] instructionReg;

//Save instruction just after fetch
always @(negedge clk)
begin
    if (reset)
    begin
        instructionReg <= 32'd0;
    end
    else
    begin
        if (getRegs)
        begin
            instructionReg <= q;
        end
    end
end

assign instrOP  = instruction[31:28];  

assign const11  = instruction[22:12];
assign const16  = instruction[27:12];
assign const27  = instruction[27:1];

assign areg     = instruction[11:8];
assign breg     = instruction[7:4];
assign dreg     = instruction[3:0];

assign opcode   = instruction[26:23];
assign ce       = instruction[27];
assign he       = instruction[8];
assign oe       = instruction[0];
assign intf     = instruction[4];
assign n1       = instruction[0];
assign n2       = instruction[5];

initial
begin
    instructionReg <= 32'd0;
end

endmodule