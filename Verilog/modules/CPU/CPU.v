/*
* B322 CPU
*/
module CPU(
    input clk, reset, int1, int2, int3, int4, ext_int1, ext_int2, ext_int3, ext_int4,
    output [26:0] address,
    output [31:0] data,
    output        we,
    output        start,
    input [31:0]  q,
    input         busy
);


//----------------------Timer------------------------
//Timer I/O
wire fetch, getRegs, readMem, writeBack;

Timer timer (
.clk(clk),
.reset(reset),
.fetch(fetch), 
.getRegs(getRegs), 
.readMem(readMem), 
.writeBack(writeBack),
.busy(busy)
//very maybe a .wait signal to indicate if we need to wait for busy to go low
);


//-----------------------PC--------------------------
//PC I/O
wire [26:0] jump_addr;
wire [26:0] pc_out;
wire jump, reti, offset;
wire [7:0] ext_int_id;

PC pc(
.clk(clk), 
.reset(reset),
.writeBack(writeBack),
.jump(jump),
.reti(reti),
.offset(offset),
.jump_addr(jump_addr),
.pc_out(pc_out),
.ext_int_id(ext_int_id),
.int1(int1),
.int2(int2),
.int3(int3),
.int4(int4),
.ext_int1(ext_int1),
.ext_int2(ext_int2),
.ext_int3(ext_int3),
.ext_int4(ext_int4)
);


//--------------------Regbank------------------------
//Regbank I/O
wire [3:0] areg, breg, dreg;
wire dreg_we, dreg_we_high, read_mem;
wire [31:0] data_a, data_b, data_d;

Regbank regbank(
.clk(clk),
.reset(reset),
.getRegs(getRegs),
.writeBack(writeBack),
.addr_a(areg), 
.addr_b(breg), 
.addr_d(dreg),
.data_a(data_a), 
.data_b(data_b),
.data_d(data_d),
.we(dreg_we),
.we_high(dreg_we_high),
.read_mem(read_mem),
.mem_q(q)
);


//--------------------Stack------------------------
//Stack I/O
//TODO writable stack pointer
wire push, pop;
wire [31:0] stack_q, stack_d;

Stack stack(
.clk(clk),
.reset(reset),
.q(stack_q),
.d(stack_d),
.push(push),
.pop(pop)
);


//----------------------ALU------------------------
//ALU I/O
wire [3:0] opcode;
wire [31:0] input_b;
wire bga, bea;          //flags
wire skip;

ALU alu (
.a(data_a),
.b(input_b),
.opcode(opcode),
.y(data_d),
.bga(bga),
.bea(bea),
.skip(skip)
);


//---------------InstructionDecoder----------------
//InstructionDecoder I/O
wire [3:0] instrOP;
wire ce, he, oe, intf, n1, n2;        //constant enable, high enable, offset enable and interruptFlag, neg offset (write/copy), neg offset (read)
wire [10:0] const11;
wire [15:0] const16;
wire [26:0] const27;

InstructionDecoder instDec(
.clk(clk),
.reset(reset),
.fetch(fetch),
.getRegs(getRegs),
.q(q),
.instrOP(instrOP),
.const11(const11),
.const16(const16),
.const27(const27),
.areg(areg), 
.breg(breg), 
.dreg(dreg), 
.opcode(opcode),
.ce(ce),
.he(he),
.oe(oe),
.n1(n1),
.n2(n2),
.intf(intf)
);


//------------------ControlUnit---------------------
ControlUnit cu(
//clocks/reset
.clk(clk),
.reset(reset),
.fetch(fetch),
.getRegs(getRegs),
.readMem(readMem),
.writeBack(writeBack), 
//instrDecoder
.areg(areg), 
.breg(breg), 
.dreg(dreg), 
.ce(ce),
.oe(oe),
.he(he),
.intf(intf),
.n1(n1),
.n2(n2),
.instrOP(instrOP),
.const11(const11),
.const16(const16),
.const27(const27),
//Memory
.data(data),
.address(address),
.we(we),
.q(q),
.read_mem(read_mem),
.busy(busy),
.start(start),
//Stack
.stack_q(stack_q),
.stack_d(stack_d),
.push(push),
.pop(pop),
//PC
.jump_addr(jump_addr),
.jump(jump),
.reti(reti),
.pc_in(pc_out),
.offset(offset),
.ext_int_id(ext_int_id),
//Regbank
.data_a(data_a),
.data_b(data_b),
.dreg_we(dreg_we),
.dreg_we_high(dreg_we_high),
//ALU
.input_b(input_b),
.bga(bga),
.bea(bea),
.skip(skip)
);

endmodule