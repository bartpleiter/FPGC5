/*
* Divides clk_in by the number specified in the DIVISOR parameter
* If DIVISOR is 0, then no clk_out == clk_in
*/
module ClockDivider
#(
    parameter DIVISOR = 25
) 
(
    input clk_in,
    input reset,
    output wire clk_out
);

reg [15:0] counter;

always @(posedge clk_in)
begin
	if (reset)
	begin
		counter <= 16'd0;
	end
	else 
	begin
		 counter <= counter + 16'd1;
	    if (counter >= (DIVISOR-1))
	        counter <= 16'd0;
	end
   
end

assign clk_out = (DIVISOR == 0) ? clk_in:
			(counter < DIVISOR/2) ? 1'b0:
        	1'b1;

initial
begin
    counter = 16'd0;
end

endmodule