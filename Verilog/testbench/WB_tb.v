/*
 * Testbench
 * To simulate a WishBone interface
*/
//Set timescale
`timescale 1ns / 1ns

`include "/home/bart/Documents/FPGA/FPGC5/Verilog/modules/Memory/VRAM.v"


//Define testmodule
module WB_tb;


reg [31:0] count = 32'd0;



reg i_clk = 1'b0;
reg i_reset = 1'b0;

//VRAM32 I/O
wire [13:0] vram32_cpu_addr;
wire [31:0] vram32_cpu_d;
wire        vram32_cpu_we; 
wire [31:0] vram32_cpu_q;


// Master
wire bus_start;
reg bus_we = 1'b0;
reg [26:0] bus_addr = 27'd0;
reg [31:0] bus_data = 32'd0;


reg start = 1'b0;
assign bus_start = (start)&&(!bus_done);

reg mstate = 1'd0;

localparam MSTATE_IDLE = 1'd0;
localparam MSTATE_WAIT_RESPONSE = 1'd1;

always @(posedge i_clk)
begin

    case(mstate)
        MSTATE_IDLE:
        begin
            if (count == 32'd4)
            begin
                bus_we <= 1'b1;
                bus_addr <= 27'd4;
                bus_data <= 32'd37;
                start <= 1'b1;
                mstate <= MSTATE_WAIT_RESPONSE;
            end
        end
        MSTATE_WAIT_RESPONSE:
        begin
            if(bus_done)
            begin
                start = 1'b0;
                bus_we = 1'b0;
                bus_addr = 27'd0;
                bus_data = bus_q;
                mstate <= MSTATE_IDLE;
            end
        end
    endcase

end




// Slave
reg bus_done = 1'b0;
wire [31:0] bus_q; // Only valid when bus_done is true
assign bus_q = (bus_addr == 3) ? vram32_cpu_q + 1 : bus_addr + 7; // Only valid when bus_done is true


reg [1:0] state = 0;
reg busy = 1'b0;


always @(posedge i_clk)
begin

    case(state)
    0:  
    begin
        bus_done  <= 1'b0;
        if ((bus_start)&&(!busy))
        begin

            if (bus_addr == 3)
            begin
                state <= 0;
                bus_done <= 1;
            end
            else
            begin
                state <= 1;
                //local_data <= bus_data;
                busy <= 1'b1;
            end
        end 

    end
    1:  
    begin
        state <= 2;
    end
    2:  
    begin
        state <= 0;
        busy <= 1'b0;
        bus_done  <= 1'b1;
    end
    endcase
end




//---------------------------VRAM32---------------------------------


assign vram32_cpu_addr = bus_addr + 1;
assign vram32_cpu_d = bus_data;
assign vram32_cpu_we = (bus_addr == 3) ? bus_we : 1'b0;


VRAM #(
.WIDTH(32), 
.WORDS(1056), 
.LIST("/home/bart/Documents/FPGA/FPGC5/Verilog/memory/vram32.list")
)   vram32(
//CPU port
.cpu_clk    (i_clk),
.cpu_d      (vram32_cpu_d),
.cpu_addr   (vram32_cpu_addr),
.cpu_we     (vram32_cpu_we),
.cpu_q      (vram32_cpu_q),

//GPU port
.gpu_clk    (1'b0)
);



initial
begin
    //Dump everything for GTKwave
    $dumpfile("/home/bart/Documents/FPGA/FPGC5/Verilog/output/wave.vcd");
    $dumpvars;

    /*
    // reset first
    clk = 1'b0;
    reset = 1'b1;
    repeat(4) #5 clk = ~clk;
    reset = 1'b0;
    */
    #5 i_clk <= ~i_clk;

    repeat(100) begin #5 i_clk <= ~i_clk; #5 i_clk <= ~i_clk; count <= count + 1'b1;end

    #1 $finish;
end

endmodule
