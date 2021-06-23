/*
* Register Bank
*/
module Regbank(
    input               clk, reset,
    input               getRegs, writeBack,

    input       [3:0]   addr_a, addr_b, addr_d,
    input       [31:0]  data_d,
    output      [31:0]  data_a, data_b, 

    input               we, we_high,
    //Memory
    input               read_mem,
    input       [31:0]  mem_q
);

assign data_a = (addr_a == 4'd0) ? 32'd0 : {data_a_h, data_a_l};
assign data_b = (addr_b == 4'd0) ? 32'd0 : {data_b_h, data_b_l};

reg [15:0] regsH [0:15];    //highest 16 bits of regbank
reg [15:0] regsL [0:15];    //lowest 16 bits of regbank

reg [15:0] data_a_l, data_a_h, data_b_l, data_b_h;

//read at negedge clock
always @(negedge clk) 
begin
    if (getRegs)
    begin
        data_a_l <= regsL[addr_a];
        data_a_h <= regsH[addr_a]; 

        data_b_l <= regsL[addr_b];
        data_b_h <= regsH[addr_b]; 
    end
end

//write at negedge clock
always @(negedge clk) 
begin
    if (writeBack && we)
    begin
        if (read_mem) //when read_mem is high, ignore data from ALU and use data from memory instead
        begin
            regsL[addr_d] <= mem_q[15:0];
            regsH[addr_d] <= mem_q[31:16];
        end
        else
        begin
            if (we_high)
            begin
                regsH[addr_d] <= data_d[15:0];
            end
            else 
            begin
                regsL[addr_d] <= data_d[15:0];
                regsH[addr_d] <= data_d[31:16];
            end
        end
    end
end

integer i;
initial
begin
    data_a_l = 16'd0;
    data_b_l = 16'd0;
    data_a_h = 16'd0;
    data_b_h = 16'd0;

    for (i = 0; i < 16; i = i + 1)
    begin
        regsL[i] = 16'd0;
        regsH[i] = 16'd0;
    end
 
end

endmodule