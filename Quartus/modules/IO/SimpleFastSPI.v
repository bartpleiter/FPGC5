module SimpleFastSPI
(
    // System side
    input reset,
    input clk,
    input t_start,
    input [7:0] d_in,
    output reg [7:0] d_out,
    output reg busy,

    // SPI side
    input miso,
    output wire mosi,
    output wire spi_clk
);

    parameter rst = 0, idle = 1, load = 2, transact = 3, unload = 4, cooldown = 5; // states

    reg [7:0] mosi_d;
    reg [7:0] miso_d;
    reg [3:0] count;
    reg [2:0] state;
    reg [2:0] cooldownCounter;

    // read on rising clock
    always @(posedge spi_clk)
    begin
        miso_d <= {miso_d[7-1:0], miso};
    end
    
    always @(negedge clk)
    begin
        case (state)
            rst:
            begin
                state <= idle;
                d_out <= 0;
            end
            idle:
            begin
                count <= 0;
                if (t_start)
                begin
                    busy <= 1;
                    state <= load;
                end
            end
            load:
            begin
                mosi_d <= d_in;
                count <= 8;
                if (count != 0)
                    state <= transact;
            end
            transact:
            begin
                mosi_d <= {mosi_d[7-1:0], 1'b0};
                count <= count-1;
                if (count == 0)
                    state <= unload;
            end
            unload:
            begin
                state <= cooldown;
                cooldownCounter <= 1;
                d_out <= miso_d;
            end
            cooldown:
            begin
                busy <= 0;
                if (cooldownCounter == 0)
                    state <= idle;
                else
                    cooldownCounter <= cooldownCounter - 1;
            end
        endcase
    end
    // end state machine

    // begin SPI logic
    assign mosi = ( state == transact || state == load) ? mosi_d[7] : 1'bz;
    assign spi_clk = ( count > 1'b0 && state == transact) ? clk : 1'b0;
    // end SPI logic

    initial
    begin
        d_out <= 0;
        mosi_d <= 0;
        miso_d <= 0;
        state <= 0;
        count <= 0;
        busy <= 0;
        cooldownCounter <= 0;
    end

endmodule