/*
* Reads SPI flash module
* Enables quad spi mode with coninous mode on
* Reads instructions of 32 bits
*/
module SPIreader (
    input clk, reset,
    output cs, 
    input [23:0] address, 
    output [31:0] instr, 
    input start, 
    output reg initDone, recvDone,
    output wire write,
    output wire io0_out, io1_out, io2_out, io3_out, //d, q wp, hold
    input wire io0_in, io1_in, io2_in, io3_in       //d, q wp, hold
);



wire recvDoneWire;
assign recvDoneWire = (initDone && phase == 2 && counter == 2);

always @(negedge clk)
begin
  if (reset)
  begin
    recvDone <= 1'b0;
  end
  else 
  begin
    recvDone <= recvDoneWire;
  end
end


wire [23:0] a; //address
assign a = address << 2;


reg [7:0] b0, b1, b2, b3;
reg [6:0] counter;
reg [2:0] phase;
/*
0 = initial wait (goto 5)
1 = send quad fast read opcode (goto 3)
2 = idle - ready to read
3 = send address, continuous mode bits and dummy bits
4 = receive 32 bits (goto 2)
5 = reset continuous mode
6 = wait after reset (goto 1)
*/

//COMMANDS
wire [7:0] opcode;
assign opcode = 8'hEB;

wire [11:0] addr_io0;
assign addr_io0 = {a[20], a[16], a[12], a[8], a[4], a[0], 2'b00, 4'b0000};

wire [11:0] addr_io1;
assign addr_io1 = {a[21], a[17], a[13], a[9], a[5], a[1], 2'b10, 4'b0000};

wire [11:0] addr_io2;
assign addr_io2 = {a[22], a[18], a[14], a[10], a[6], a[2], 2'b00, 4'b0000};

wire [11:0] addr_io3;
assign addr_io3 = {a[23], a[19], a[15], a[11], a[7], a[3], 2'b00, 4'b0000};


assign write = (phase == 5) ? 1'b1 :
               (phase == 1) ? 1'b1 :
               (phase == 3) ? 1'b1 :
               1'b0;

assign cs   =  (phase == 1) ? 1'b0 :
               (phase == 3) ? 1'b0 :
               (phase == 4) ? 1'b0 :
               (phase == 5) ? 1'b0 :
               1'b1;


//d
assign io0_out =  (phase == 5) ? 1'b1 :
                  (phase == 1) ? opcode[7-counter] :
                  (phase == 3) ? addr_io0[11-counter] :
                   1'b0;
//q
assign io1_out =  (phase == 1) ? 1'b1 :
                  (phase == 3) ? addr_io1[11-counter] :
                   1'b0;
//wp
assign io2_out =  (phase == 1) ? 1'b1 :
                  (phase == 3) ? addr_io2[11-counter] :
                   1'b0;
//hold
assign io3_out =  (phase == 1) ? 1'b1 :
                  (phase == 3) ? addr_io3[11-counter] :
                   1'b0;


//mapping read data to instruction
assign instr = {
               b3[7], b2[7], b1[7], b0[7], b3[6], b2[6], b1[6], b0[6], 
               b3[5], b2[5], b1[5], b0[5], b3[4], b2[4], b1[4], b0[4], 
               b3[3], b2[3], b1[3], b0[3], b3[2], b2[2], b1[2], b0[2], 
               b3[1], b2[1], b1[1], b0[1], b3[0], b2[0], b1[0], b0[0]
            };


initial begin
   phase = 3'd0;
   counter = 7'd0;
   b0 = 8'd0;
   b1 = 8'd0;
   b2 = 8'd0;
   b3 = 8'd0;
   initDone = 1'd0;
end


always @(negedge clk)
begin
    if (reset)
    begin
      phase <= 3'd0;
      counter <= 7'd0;
      initDone <= 1'd0;
    end
    else 
    begin 

       case (phase)
       //initial state,
       3'd0: 
       begin
           if (counter == 7'd3)
           begin
               counter <= 7'd0;
               phase <= 5;
           end
           else begin
               counter <= counter + 1'b1;
           end
      end

         //send quad fast read opcode
         3'd1:
         begin
            if (counter == 7'd7)
            begin
               counter <= 7'd0;
               phase <= 3;
            end
            else begin
               counter <= counter + 1'b1;
            end
         end

         //idle - ready to read when triggered (after some instruction delay)
         3'd2:
         begin
            if (counter == 7'd4) //could be 3, but one extra cycle delay to wait for start from MU to go low
            begin
               initDone <= 1'b1;
               if (start)
               begin
                  counter <= 7'd0;
                  phase <= 3'd3;
               end
            end
            else begin
               counter <= counter + 1'b1;
            end
         end

         //send address, continuous mode bits and dummy bits
         3'd3:
         begin
            if (counter == 7'd11)
            begin
               counter <= 7'd0;
               phase <= 3'd4;
            end
            else begin
               counter <= counter + 1'b1;
            end
         end

         //receive 32 bits
         3'd4:
         begin
            if (counter == 7'd7)
            begin
               counter <= 7'd0;
               phase <= 3'd2;
            end
            else begin
               counter <= counter + 1'b1;
            end
         end

         //reset
         3'd5:
         begin
            if (counter == 7)
            begin
               counter <= 7'd0;
               phase <= 3'd6;
            end
            else begin
               counter <= counter + 1'b1;
            end
         end

         //wait after reset
         3'd6:
         begin
            if (counter == 7'd3)
            begin
               counter <= 7'd0;
               phase <= 3'd1;
            end
            else begin
               counter <= counter + 1'b1;
            end
         end

      endcase

   end
end


always @(posedge clk)
begin
  if (reset)
  begin
    b0 <= 8'd0;
    b1 <= 8'd0;
    b2 <= 8'd0;
    b3 <= 8'd0;
  end
  else 
  begin
    if (phase == 3'd4)
    begin
      b0[7-counter] <= io0_in;
      b1[7-counter] <= io1_in;
      b2[7-counter] <= io2_in;
      b3[7-counter] <= io3_in;
    end
  end
   
end

endmodule