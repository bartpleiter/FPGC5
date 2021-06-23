/*
* Communicates with NES (and probably also SNES) controller
* Stores button values in nesState
* Code mostly copied
*/

module NESpadReader(
    clk,
    reset,
    nesc,
    nesl,
    nesd,
    nesState
);

//General I/O
input clk;                      //clock for reading in controller
input reset;

//get slower clock from 25MHz clock
wire slow_clk;
ClockDivider #(
.DIVISOR(128))
 clkDivNES(
.clk_in(clk),
.reset(reset),
.clk_out(slow_clk)
);

//Inintialization code
initial
begin
    state <= WAIT_STATE;
    button_index <= 4'd0;
    button_state <= 16'hFFFF;
    nesState <= 16'd0;
end

//Controller I/O
input   nesd;                   //data from controller
output wire nesc;               //clock to controller
output wire nesl;               //latch to controller
output reg [15:0] nesState;     //contains button values from controller

//NESpadReader vars
reg  [1:0]  state;              //current state
reg  [3:0]  button_index;       //button index
reg [15:0]  button_state;       //button state

//States
parameter WAIT_STATE    = 0;    
parameter LATCH_STATE   = 1;
parameter READ_STATE    = 2;


//State transitions at positive edge of 1.2KHz clock
always @(posedge slow_clk or posedge reset) 
begin
    if (reset)
    begin
        state <= WAIT_STATE;
    end
    else
    begin
        if (state == WAIT_STATE)
            state <= LATCH_STATE;
        else if (state == LATCH_STATE)
            state <= READ_STATE;
        else if (state == READ_STATE) 
        begin
            if (button_index == 15) //if all 16 button bits are read
                state <= WAIT_STATE;
        end
    end
end
  

//Button reading at negative edge of 1.2KHz clock,
//to give values from the controller time to settle.
always @(negedge slow_clk or posedge reset) 
begin
    if (reset)
    begin
        button_index <= 4'd0;
        button_state <= 16'hFFFF;
        nesState <= 16'd0;
    end
    else
    begin
        if (state == WAIT_STATE)
        begin
            button_index <= 4'b0;   //reset
            nesState <= {4'd0, ~button_state[11:0]}; //Write button data to reg
        end
        else if (state == READ_STATE) 
        begin
            button_state[button_index] <= nesd;
            button_index <= button_index + 1;
        end
    end
end

assign nesl = (state == LATCH_STATE) ? 1'b1 : 1'b0;
assign nesc = (state == READ_STATE) ? slow_clk : 1'b1;


endmodule