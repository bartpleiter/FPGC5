// One shot timer that counts in milliseconds
// Uses a delay of 25000-1 cycles per timerValue

module OStimer(
    input clk,
    input reset,
    input [31:0] timerValue,
    input trigger,
    input setValue,
    output reg interrupt
);

reg [31:0] counterValue;                // 32 bits for timerValue
reg [31:0] delayCounter;                // counter for timer delay
reg [3:0] keepInterruptHighCounter;     // we want to keep the interrupt high for multiple cycles
reg [1:0] state;                        // state of timer

// States
parameter s_idle        = 0;
parameter s_start       = 1;
parameter s_done        = 2;

parameter delay         = 24999; // Clock cycles delay per timerValue, could eventually become programmable, should then default to 1ms


initial
begin
    counterValue                <= 32'd0;
    delayCounter                <= 32'd0;
    state                       <= s_idle;
    keepInterruptHighCounter    <= 4'd0;
    interrupt                   <= 1'b0;
end

always @(negedge clk)
begin
    if (reset)
    begin
        counterValue                <= 32'd0;
        delayCounter                <= 32'd0;
        state                       <= s_idle;
        interrupt                   <= 1'd0;  
        keepInterruptHighCounter    <= 4'd0;
    end
    else
    begin
        case (state)
            s_idle:
            begin
                if (trigger)
                begin
                    state <= s_start;
                    delayCounter <= delay;
                end
                if (setValue)
                begin
                    counterValue <= timerValue;
                end
            end
            s_start:
            begin
                if (setValue)
                begin
                    counterValue <= timerValue;
                end
                else if (counterValue == 0)
                begin
                    state <= s_done;
                    interrupt <= 1'b1;
                    keepInterruptHighCounter <= 0;
                end
                else 
                begin

                    if (delayCounter == 0)
                    begin
                        counterValue <= counterValue - 1'b1;
                        delayCounter <= delay;
                    end
                    else 
                    begin
                        delayCounter <= delayCounter - 1'b1;    
                    end
                end
            end
            s_done:
            begin
                if (setValue)
                begin
                    counterValue <= timerValue;
                end
                else if (trigger)
                begin
                    state <= s_start;
                    delayCounter <= delay;
                    interrupt <= 0;
                end
                else if (keepInterruptHighCounter == 4'b1111)
                begin
                    interrupt <= 0;
                    state <= s_idle;
                end
                else 
                begin
                    keepInterruptHighCounter <= keepInterruptHighCounter + 1'b1;
                end
            end

        endcase
    end
end


endmodule


