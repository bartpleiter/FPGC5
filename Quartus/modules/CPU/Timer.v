/*
* Creates the timing signals
*/
module Timer(
    input clk, reset,
    output fetch, getRegs, readMem, writeBack,
    input busy
);  
    
reg [2:0] state;

parameter s_init        = 0;
parameter s_fetch       = 1;
parameter s_getRegs     = 2;
parameter s_readMem     = 3;
parameter s_writeBack   = 4;

assign fetch        = (state == s_fetch);
assign getRegs      = (state == s_getRegs);
assign readMem      = (state == s_readMem);
assign writeBack    = (state == s_writeBack);

always @(posedge clk)
begin
    if (reset)
    begin
        state       <= s_init;
    end
    else
    begin
        case (state)

            s_init:
            begin 
                state       <= s_fetch;
            end

            s_fetch: 
            begin
                if (!busy)
                begin
                    state   <= s_getRegs;
                end
            end

            s_getRegs: 
            begin
                state       <= s_readMem;
            end

            s_readMem: 
            begin
                if (!busy)
                begin
                    state   <= s_writeBack;
                end                
            end

            s_writeBack: 
            begin
                if (!busy)
                begin
                    state   <= s_fetch;
                end 
            end

            //should not get here
            default: 
            begin
                state       <= s_init;
            end

        endcase
    end
end

initial
begin
    state <= s_init;
end

endmodule