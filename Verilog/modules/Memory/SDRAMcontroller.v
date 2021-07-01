/*
* SDRAM controller
*/
module SDRAMcontroller(
    input clk,

    // read
    output busy,                // high if controller is busy
    input [23:0] addr,          // addr to read or write 2*24 * 16 = 32MiBytes
    input [31:0] d,             // data to write
    input we,                   // high if write, low if read
    input start,                // high when controller should start reading/writing
    output [31:0] q,            // read data output
    //output reg q_ready_reg_delay,   // read data ready
    output q_ready,   // read data ready
    output initDone,            // high when initialization done

    // SDRAM
    output SDRAM_CSn, SDRAM_WEn, SDRAM_CASn, SDRAM_RASn,
    output reg SDRAM_CKE, 
    output reg [12:0] SDRAM_A,
    output reg [1:0] SDRAM_BA,
    output reg [1:0] SDRAM_DQM,
    inout [15:0] SDRAM_DQ
);

reg q_ready_reg;

assign q_ready = (start && q_ready_reg);

assign busy = (state != s_idle);
assign initDone = (state != s_init);

reg [3:0] SDRAM_CMD;
parameter [3:0] SDRAM_CMD_UNSELECTED= 4'b1000;
parameter [3:0] SDRAM_CMD_NOP       = 4'b0111;
parameter [3:0] SDRAM_CMD_ACTIVE    = 4'b0011;
parameter [3:0] SDRAM_CMD_READ      = 4'b0101;
parameter [3:0] SDRAM_CMD_WRITE     = 4'b0100;
parameter [3:0] SDRAM_CMD_TERMINATE = 4'b0110;
parameter [3:0] SDRAM_CMD_PRECHARGE = 4'b0010;
parameter [3:0] SDRAM_CMD_REFRESH   = 4'b0001;
parameter [3:0] SDRAM_CMD_LOADMODE  = 4'b0000;

assign {SDRAM_CSn, SDRAM_RASn, SDRAM_CASn, SDRAM_WEn} = SDRAM_CMD;

// 48LC16M16A2-7E specs
parameter sdram_column_bits    = 10; 
parameter sdram_address_width  = 25; 
parameter sdram_startup_cycles = 10100; // -- 100us, plus a little more, @ 100MHz
parameter cycles_per_refresh   = 780; // 25MHz -> 195;  // (64000*100)/8192-1 Cycled as (64ms @100MHz)/8192 rows (780 for 100mhz)

// bit indexes used when splitting the address into row/colum/bank.
parameter start_of_col  = 0;
parameter end_of_col    = sdram_column_bits-2;
parameter start_of_bank = sdram_column_bits-1;
parameter end_of_bank   = sdram_column_bits;
parameter START_OF_ROW  = sdram_column_bits+1;
parameter END_OF_ROW    = sdram_address_width-2;
parameter prefresh_cmd  = 10;
parameter ROW_PAD_BITS  = 12 + START_OF_ROW - END_OF_ROW;

wire [12:0] addr_row;
wire [12:0] addr_col;
wire [1:0]  addr_bank;
//--------------------------------------------------------------------------
// Seperate the address into row / bank / address
//--------------------------------------------------------------------------
//11111111110 111010100
wire [24:0] bigaddr;
assign bigaddr = addr << 1;

assign addr_col  = bigaddr[8:0];
assign addr_row  = bigaddr[21:9];
assign addr_bank = bigaddr[23:22];

//DQ write port
reg [15:0] WrData;
reg SDRAM_DQ_OE;
assign SDRAM_DQ = SDRAM_DQ_OE ? WrData : 16'hZZZZ;

wire [15:0] SDRAM_Q;
assign SDRAM_Q = SDRAM_DQ;

//Input data
wire [15:0] data_low, data_high;
assign data_low = d[15:0];
assign data_high = d[31:16];

//Output data
reg [15:0] q_low, q_high;
assign q = {q_high, q_low};

// state of controller
reg [6:0] state; 
parameter s_init = 0;
parameter s_idle = 1;
parameter s_open_in_2 = 2;
parameter s_open_in_1 = 3;
parameter s_write_1 = 4;
parameter s_write_2 = 5;
parameter s_write_3 = 6;
parameter s_read_1 = 7;
parameter s_read_2 = 8;
parameter s_read_3 = 9;
parameter s_read_4 = 10;
parameter s_precharge = 11;
parameter s_idle_in_6 = 12;
parameter s_idle_in_5 = 13;
parameter s_idle_in_4 = 14;
parameter s_idle_in_3 = 15;
parameter s_idle_in_2 = 16;
parameter s_idle_in_1 = 17;
parameter s_read_precharge = 18;

reg  [9:0] startup_refresh_count = 0;

wire refresh;
assign refresh = (SDRAM_CMD == SDRAM_CMD_REFRESH);

//140ns = 1clk
//63980 - 42820 = 21160
// 21160 / 40 = 529 cycles

// 25MHz -> 25.000.000 cycles per sec
// 25.000.000*0.064 -> 1.600.000 cycles per 64ms
// 1.600.000 / 8192 auto refreshes -> refresh after 196 cycles
// for 50mhz this should be 196*2 cycles and for 100mhz this should be 196*4 cycles

reg [31:0] InitCounter = 0;

reg isRefreshing = 1'b0;

always @(posedge clk)
begin

    /*if (reset)
    begin
        SDRAM_BA      <= 2'b00;
        SDRAM_DQM     <= 2'b11;
        SDRAM_A       <= 0;  
        SDRAM_CMD     <= SDRAM_CMD_UNSELECTED;
        SDRAM_CKE     <= 0;
        SDRAM_DQ_OE   <= 0;
        state         <= 0;
        WrData        <= 0;
        q_ready_reg       <= 0;
        q_low         <= 0;
        q_high        <= 0;
        startup_refresh_count <= 0;
    end
    else */
    begin
     
        startup_refresh_count <= startup_refresh_count+1;

        case(state)
            s_init: 
            begin
                    q_ready_reg <= 1'b0;
                SDRAM_CKE <= 1'b1;
                SDRAM_DQM <= 2'b00;
                case(InitCounter)
                    1010: begin
                        SDRAM_CMD <= SDRAM_CMD_PRECHARGE;
                        SDRAM_A <= 1024;
                    end
                    1015: begin
                        SDRAM_CMD <= SDRAM_CMD_REFRESH;
                    end
                    1025: begin
                        SDRAM_CMD <= SDRAM_CMD_REFRESH;
                    end
                    1035: begin
                        SDRAM_CMD <= SDRAM_CMD_LOADMODE;
                        SDRAM_A <= 6'b100001; //cas = 2, and burst length = 2, burst type = sequenctial
                    end
                    1036: begin
                        SDRAM_CMD <= SDRAM_CMD_NOP;
                        SDRAM_A <= 0;
                        state <= s_idle;
                    end
                    default: begin
                        SDRAM_CMD <= SDRAM_CMD_NOP;
                    end
                endcase
                InitCounter <= InitCounter + 1'b1;
            end
            s_idle:
            begin
                q_ready_reg <= 1'b0;

                if (startup_refresh_count > cycles_per_refresh) //refresh has priority!
                    begin
                        state       <= s_idle_in_6;
                        isRefreshing <= 1'b1;
                        SDRAM_CMD   <= SDRAM_CMD_REFRESH;
                        startup_refresh_count <= 0;
                    end
                else 
                begin     
                    if (start)
                    begin
                        //--------------------------------
                        //-- Start the read or write cycle. 
                        //-- First task is to open the row
                        //--------------------------------
                        state       <= s_open_in_2;
                        SDRAM_CMD   <= SDRAM_CMD_ACTIVE;
                        SDRAM_A     <= addr_row;
                        SDRAM_BA    <= addr_bank;
                    end
                    else //if nothing happens, just nop
                    begin
                        SDRAM_DQM <= 2'b00;
                        SDRAM_CMD <= SDRAM_CMD_NOP;
                        SDRAM_A <= 0;  
                    end
                end                
                                
            end
            s_open_in_2: 
            begin
                state <= s_open_in_1;
                SDRAM_CMD <= SDRAM_CMD_NOP;
            end 
            s_open_in_1:
            begin
                // if write command
                if (we)
                begin
                    state <= s_write_1;
                    WrData <= data_low;
                    SDRAM_DQ_OE <= 1'b1;
                end
                else // if read command
                begin
                    state <= s_read_1;
                    SDRAM_DQ_OE <= 1'b0;
                end
            end
            s_write_1: 
            begin
                state                   <= s_write_2;
                SDRAM_CMD               <= SDRAM_CMD_WRITE;
                SDRAM_A                 <= addr_col; 
                SDRAM_A[prefresh_cmd]   <= 1'b0; // A10 actually matters - it selects auto precharge
                SDRAM_BA                <= addr_bank;
                SDRAM_DQM               <= 2'b00;  
                WrData                  <= data_low;
            end   
            s_write_2:
            begin
                WrData                  <= data_high;
                SDRAM_CMD               <= SDRAM_CMD_NOP;
                state                   <= s_write_3;
            end
            s_write_3:
            begin
                state                   <= s_precharge;
                SDRAM_DQ_OE             <= 1'b0;
            end
            s_precharge:
            begin
                q_ready_reg                     <= 1'b1;
                state                       <= s_idle_in_3;
                SDRAM_CMD                   <= SDRAM_CMD_PRECHARGE;
                SDRAM_A[prefresh_cmd]       <= 1'b1; // A10 actually matters - it selects all banks or just one
            end
            s_idle_in_6: 
            begin
                state <= s_idle_in_5;
                SDRAM_CMD <= SDRAM_CMD_NOP;
            end
            s_idle_in_5: state <= s_idle_in_4;
            s_idle_in_4: state <= s_idle_in_3;
            s_idle_in_3: 
            begin
                if (!start) q_ready_reg <= 1'b0;
                state           <= s_idle_in_2;
                SDRAM_CMD       <= SDRAM_CMD_NOP;
            end
            s_idle_in_2: 
            begin
                state <= s_idle_in_1;
                if (!start) q_ready_reg <= 1'b0;
            end
            s_idle_in_1: 
            begin
                if (!start || isRefreshing || !q_ready_reg)
                begin
                    q_ready_reg     <= 1'b0;
                    state       <= s_idle;
                    isRefreshing <= 1'b0;
                end
            end
            s_read_1: 
            begin
                state           <= s_read_2;
                SDRAM_CMD       <= SDRAM_CMD_READ;
                SDRAM_A         <= addr_col; 
                SDRAM_BA        <= addr_bank;
                SDRAM_A[prefresh_cmd] <= 1'b0; // A10 actually matters - it selects auto precharge
                SDRAM_DQM       <= 2'b00;
            end   
            s_read_2: begin
                SDRAM_CMD       <= SDRAM_CMD_NOP;
                state <= s_read_3;
            end   
            s_read_3: begin
                state <= s_read_4;
                     
            end

            s_read_4: 
            begin
                state <= s_read_precharge;
                     q_low                       <= SDRAM_Q;
                
                
            end
            s_read_precharge:
            begin
                q_high                      <= SDRAM_Q;
                q_ready_reg                     <= 1'b1;
                state                       <= s_idle_in_3;
                SDRAM_CMD                   <= SDRAM_CMD_PRECHARGE;
                SDRAM_A[prefresh_cmd]       <= 1'b1; // A10 actually matters - it selects all banks or just one
            end

        endcase


    end

   
end


/*
reg q_ready_reg;

always @(posedge clk)
begin
    if (reset)
    begin
        q_ready_reg_delay <= 0;
    end
    else 
    begin
        q_ready_reg_delay <= q_ready_reg;
        
        //if (state == s_read_4)
        //    q_low <= SDRAM_Q;
        //if (state == s_read_precharge)
        //    q_high <= SDRAM_Q;
    end
end
*/


initial
begin
  SDRAM_BA      <= 2'b00;
  SDRAM_DQM     <= 2'b11;
  SDRAM_A       <= 0;  
  SDRAM_CMD     <= SDRAM_CMD_UNSELECTED;
  SDRAM_CKE     <= 0;
  SDRAM_DQ_OE   <= 0;
  state         <= 0;
  WrData        <= 0;
  q_ready_reg       <= 0;
  q_low         <= 0;
  q_high        <= 0;
  startup_refresh_count <= 0;
  //q_ready_reg_delay <= 0;
end

endmodule