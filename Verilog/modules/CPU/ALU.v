/*
* Performs basic arithmetic operations on a and b, based on the opcode.
* Indicates which input is bigger and if they are equal.
* When skip is high, b is passed through as output.
*/

module ALU(
    input       [31:0]  a, b,
    input       [3:0]   opcode,
    input               skip,   //do not do any operation, pass on b
    output reg  [31:0]  y,
    output              bga,    //b greater than a
    output              bea     //b equals a
);

// Opcodes
localparam 
    OP_OR       = 4'b0000, //OR
    OP_AND      = 4'b0001, //AND
    OP_XOR      = 4'b0010, //XOR
    OP_ADD      = 4'b0011, //ADD
    OP_SUB      = 4'b0100, //SUBSTRACT
    OP_SHIFTL   = 4'b0101, //SHIFT LEFT
    OP_SHIFTR   = 4'b0110, //SHIFT RIGHT
    OP_MULT     = 4'b0111, //MULTIPLICATION
    OP_NOTA     = 4'b1000, //NOT A
    OP_U1       = 4'b1001, //Unimplemented
    OP_U2       = 4'b1010, //Unimplemented
    OP_U3       = 4'b1011, //Unimplemented
    OP_U4       = 4'b1100, //Unimplemented
    OP_U5       = 4'b1101, //Unimplemented
    OP_U6       = 4'b1110, //Unimplemented
    OP_U7       = 4'b1111; //Unimplemented

// Flags
assign bga  = (b >  a);
assign bea  = (b == a);

// Calculate outputs
wire [31:0] res_OR      = a | b;
wire [31:0] res_AND     = a & b;
wire [31:0] res_XOR     = a ^ b;
wire [31:0] res_ADD     = a + b;
wire [31:0] res_SUB     = a - b;
wire [31:0] res_SHIFTL  = a << b[5:0];
wire [31:0] res_SHIFTR  = a >> b[5:0];
wire [31:0] res_MULT    = a * b;
wire [31:0] res_NOTA    = ~ a;

// Multiplexer to select output
always @ (*) 
begin
    if (skip)
    begin
        y = b;
    end
    else
    begin
        case (opcode)
            OP_OR:      y = res_OR;
            OP_AND:     y = res_AND;
            OP_XOR:     y = res_XOR;
            OP_ADD:     y = res_ADD;
            OP_SUB:     y = res_SUB;
            OP_SHIFTL:  y = res_SHIFTL;
            OP_SHIFTR:  y = res_SHIFTR;
            OP_MULT:    y = res_MULT;
            OP_NOTA:    y = res_NOTA;
            default:    y = 32'd0;
        endcase
    end
end

endmodule