/*
* Stack of CPU (4096 bytes)
* Is 32 bits wide, and therefore can store an entire register per entry
* Is 1024 words long
*/
module Stack (
    input             clk,
    input             reset,
    input      [31:0] d,
    output reg [31:0] q,
    input             push,
    input             pop
);

reg [9:0] ptr;              //stack pointer
reg [31:0] stack [1023:0];  //stack

always @(negedge clk)
begin
    if (reset)
    begin
        ptr <= 10'd0;
    end
    else 
    begin
        if (push)
        begin
            stack[ptr] <= d;
            ptr <= ptr + 1'b1;
        end

        if (pop)
        begin
            q <= stack[ptr - 1'b1]; //simulation does not like this when ptr = 0
            ptr <= ptr - 1'b1;
        end
    end
    
end

//integer i;
initial
begin
    ptr = 6'd0;
    q = 32'd0;
/*
    for (i = 0; i < 1024; i = i + 1)
    begin
        stack[i] = 32'd0;
    end
*/
end

endmodule