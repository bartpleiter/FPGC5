/*
* Interrupt module
* Allows multiple interrupts to be handled within a single interrupt handler
* By providing the interrupt ID in memory
* Lower interrupt IDs have higher priority
* TODO: find a way to handle simultanious interrupts without skipping them (find a way to delay)
*/
module InterruptExtender(
    input clk, reset,
    output reg [31:0] o_int_id,
    output o_int,
    input i_int_1, i_int_2, i_int_3, i_int_4
);  
    
assign o_int_id = i_int_1 || i_int_2 || i_int_3 || i_int_4;

always @(posedge clk)
begin
    if (i_int_1)
        o_int_id = 32'd1;
    else if (i_int_2)
        o_int_id = 32'd2;
    else if (i_int_3)
        o_int_id = 32'd3;
    else if (i_int_4)
        o_int_id = 32'd4;
end

initial
begin
    o_int_id = 32'd0;
end

endmodule