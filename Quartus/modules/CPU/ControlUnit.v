/*
* Basically controls what should happen in the CPU based on the instruction opcode
*/

module ControlUnit(
    //Clocks and timings
    input           clk, reset,
    input           fetch, getRegs, readMem, writeBack,
    //Instr. decoder
    input           ce, oe, he, intf, n1, n2,
    input [3:0]     areg, breg, dreg,
    input [10:0]    const11,
    input [15:0]    const16,
    input [26:0]    const27,
    input [3:0]     instrOP,
    //Memory
    output [31:0]   data,
    input  [31:0]   q,
    output [26:0]   address,
    output          we,
    output          read_mem,
    input           busy,
    output          start,
    //Stack
    input  [31:0]   stack_q,
    output [31:0]   stack_d,
    output          push,
    output          pop,
    //PC
    output [26:0]   jump_addr,
    output          jump,
    input  [26:0]   pc_in,
    output          reti,
    output          offset,
    input  [7:0]    ext_int_id,
    //Regbank
    input  [31:0]   data_a, data_b,
    output          dreg_we, dreg_we_high,
    //ALU
    output [31:0]   input_b,
    input           bga, bea,
    output          skip
);  

localparam  INSTR_HALT      = 4'b1111,
            INSTR_READ      = 4'b1110,
			INSTR_WRITE     = 4'b1101,
			INSTR_COPY      = 4'b1100,
			INSTR_PUSH      = 4'b1011,
			INSTR_POP       = 4'b1010,
			INSTR_JUMP      = 4'b1001,
			INSTR_JUMPR     = 4'b1000,
			INSTR_LOAD      = 4'b0111,
			INSTR_BEQ       = 4'b0110,
			INSTR_BNE       = 4'b0101,
			INSTR_BGT       = 4'b0100,
			INSTR_BGE       = 4'b0011,
			INSTR_SAVPC     = 4'b0010,
			INSTR_RETI      = 4'b0001,
			INSTR_ARITH     = 4'b0000;


//-----------MEMORY-----------
assign address      =   (fetch)                                         ? pc_in:
                        (readMem && !n2)                                ? data_a + const16: //address is usually in areg
                        (readMem && n2)                                 ? data_a - const16: //address is usually in areg
                        (writeBack && instrOP == INSTR_WRITE && !n1)    ? data_a + const16: //address is usually in areg
                        (writeBack && instrOP == INSTR_WRITE && n1)     ? data_a - const16: //address is usually in areg
                        (writeBack && instrOP == INSTR_COPY && !n1)     ? data_b + const16: //for copy, the write address is in breg
                        (writeBack && instrOP == INSTR_COPY && n1)      ? data_b - const16: //for copy, the write address is in breg
                        32'd0;

assign data         =   (instrOP == INSTR_COPY) ? q: //for copy we want to write the read result
                        data_b; //data is otherwise stored in breg

assign start        =   (fetch)                                         ||
                        (instrOP == INSTR_READ && readMem)              ||
                        (instrOP == INSTR_WRITE && writeBack)           ||
                        (instrOP == INSTR_COPY && (readMem || writeBack));

assign we           =   (instrOP == INSTR_WRITE && writeBack)           ||
                        (instrOP == INSTR_COPY && writeBack);

assign read_mem     =   (instrOP == INSTR_READ && !intf);

//-----------ALU------------
assign input_b      =   (instrOP == INSTR_ARITH && ce)  ?   {21'd0, const11}    :
                        (instrOP == INSTR_LOAD)         ?   {16'd0, const16}    :
                        (instrOP == INSTR_SAVPC)        ?   {5'd0, pc_in}       :
                        (instrOP == INSTR_POP)          ?   stack_q             :
                        (instrOP == INSTR_READ && intf) ?   {24'd0, ext_int_id} :
                        data_b;

assign skip         =   (instrOP == INSTR_LOAD)     ||
                        (instrOP == INSTR_SAVPC)    ||
                        (instrOP == INSTR_POP)      ||
                        (instrOP == INSTR_READ && intf);

assign dreg_we      =   (instrOP == INSTR_ARITH &&  writeBack) ||
                        (instrOP == INSTR_LOAD  &&  writeBack) ||
                        (instrOP == INSTR_READ  &&  writeBack) ||
                        (instrOP == INSTR_SAVPC &&  writeBack) ||
                        (instrOP == INSTR_POP   &&  writeBack);

assign dreg_we_high =   (instrOP == INSTR_LOAD && he);

//----------Stack-----------
assign stack_d      =   data_b;

assign push         =   (instrOP == INSTR_PUSH && readMem); //no need for writeBack

assign pop          =   (instrOP == INSTR_POP && readMem);


//---------Jumps------------
assign jump_addr    =   (instrOP == INSTR_JUMP)             ?   const27            :
                        (instrOP == INSTR_JUMPR)            ?   data_b + const16   :
                        (instrOP == INSTR_HALT)             ?   pc_in              : //halt: current implementation of halt is jumping to current address
                        (instrOP == INSTR_BEQ)              ?   const16            :
                        (instrOP == INSTR_BNE)              ?   const16            :
                        (instrOP == INSTR_BGT)              ?   const16            :
                        (instrOP == INSTR_BGE)              ?   const16            :
                        27'd0;

assign jump         =   (instrOP == INSTR_JUMP)                 ||
                        (instrOP == INSTR_JUMPR)                ||
                        (instrOP == INSTR_HALT)                 || //halt: current implementation of halt is jumping to current address
                        (instrOP == INSTR_BEQ && bea)           ||
                        (instrOP == INSTR_BNE && ~bea)          ||
                        (instrOP == INSTR_BGT && (~bga && ~bea))||
                        (instrOP == INSTR_BGE && ~bga);

assign offset       =   (instrOP == INSTR_JUMPR && oe) ||
                        (instrOP == INSTR_JUMP && oe)  ||
                        (instrOP == INSTR_BEQ)         ||
                        (instrOP == INSTR_BNE)         ||
                        (instrOP == INSTR_BGT)         ||
                        (instrOP == INSTR_BGE);

assign reti         =   (instrOP == INSTR_RETI);

endmodule