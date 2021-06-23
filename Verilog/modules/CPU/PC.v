/*
* Controlls all program counter related things, including interrupts
*/
module PC(
    input clk, reset, writeBack, jump,
    input [26:0] jump_addr,
    output reg [26:0] pc_out,
    output reg [7:0] ext_int_id,
    input reti,
    input offset,
    input int1, int2, int3, int4,
    input ext_int1, ext_int2, ext_int3, ext_int4
);

//Start value of PC
parameter PCstart = 27'hC02522; //Internal ROM addr 0

reg [26:0] PCintBackup;         //Backup of PC. Used when there is an interrupt. Is restored when reti is high
reg int_en;                     //enable interrupts

reg writeBack_prev;             //previous value of writeBack. To detect rising edge
reg rising_int1, rising_int2, rising_int3, rising_int4;
reg int1_prev, int2_prev, int3_prev, int4_prev; //previous values to detect rising edge

reg rising_ext_int1, rising_ext_int2, rising_ext_int3, rising_ext_int4;
reg ext_int1_prev, ext_int2_prev, ext_int3_prev, ext_int4_prev; //previous values to detect rising edge

always @(negedge clk) 
begin

    if (reset)
    begin
        pc_out <= PCstart;
        int_en <= 1'b1;
        PCintBackup     <= 27'd0;
        writeBack_prev  <= 1'b0;

        int1_prev       <= 1'b0;
        int2_prev       <= 1'b0;
        int3_prev       <= 1'b0;
        int4_prev       <= 1'b0;
        ext_int1_prev   <= 1'b0;
        ext_int2_prev   <= 1'b0;
        ext_int3_prev   <= 1'b0;
        ext_int4_prev   <= 1'b0;

        rising_int1     <= 1'b0; 
        rising_int2     <= 1'b0; 
        rising_int3     <= 1'b0;
        rising_int4     <= 1'b0;
        rising_ext_int1 <= 1'b0; 
        rising_ext_int2 <= 1'b0; 
        rising_ext_int3 <= 1'b0;
        rising_ext_int4 <= 1'b0;
    end
    else 
    begin
        writeBack_prev <= writeBack;
        int1_prev <= int1;
        int2_prev <= int2;
        int3_prev <= int3;
        int4_prev <= int4;
        ext_int1_prev <= ext_int1;
        ext_int2_prev <= ext_int2;
        ext_int3_prev <= ext_int3;
        ext_int4_prev <= ext_int4;

        if (int1 && ~int1_prev)
            rising_int1 <= 1'b1;
        if (int2 && ~int2_prev)
            rising_int2 <= 1'b1;
        if (int3 && ~int3_prev)
            rising_int3 <= 1'b1;
        if (int4 && ~int4_prev)
            rising_int4 <= 1'b1;

        if (ext_int1 && ~ext_int1_prev)
            rising_ext_int1 <= 1'b1;
        if (ext_int2 && ~ext_int2_prev)
            rising_ext_int2 <= 1'b1;
        if (ext_int3 && ~ext_int3_prev)
            rising_ext_int3 <= 1'b1;
        if (ext_int4 && ~ext_int4_prev)
            rising_ext_int4 <= 1'b1;
    end

    if (writeBack && ~writeBack_prev)
        begin
            //Restore PC and re-enable interrupts when reti is high
            if (reti)
            begin
                pc_out <= PCintBackup;
                int_en <= 1'b1;
            end

            else if (int_en && rising_int1 && pc_out < PCstart) //if interrupt1 is valid
            begin
                rising_int1 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 27'd1;
            end

            else if (int_en && rising_int2 && pc_out < PCstart) //if interrupt2 is valid
            begin
                rising_int2 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                pc_out <= 27'd2;
                int_en <= 1'b0;
                ext_int_id <= 0; // ext int id is zero for the original int 3
            end

            else if (int_en && rising_int3 && pc_out < PCstart) //if interrupt3 is valid
            begin
                rising_int3 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 17'd3;
            end

            else if (int_en && rising_int4 && pc_out < PCstart) //if interrupt4 is valid
            begin
                rising_int4 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 17'd4;
            end

            else if (int_en && rising_ext_int1 && pc_out < PCstart) //if ext_interrupt 1 is valid
            begin
                rising_ext_int1 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 17'd2;
                ext_int_id <= 1;
            end

            else if (int_en && rising_ext_int2 && pc_out < PCstart) //if ext_interrupt 2 is valid
            begin
                rising_ext_int2 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 17'd2;
                ext_int_id <= 2;
            end

            else if (int_en && rising_ext_int3 && pc_out < PCstart) //if ext_interrupt 3 is valid
            begin
                rising_ext_int3 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 17'd2;
                ext_int_id <= 3;
            end

            else if (int_en && rising_ext_int4 && pc_out < PCstart) //if ext_interrupt 4 is valid
            begin
                rising_ext_int4 <= 1'b0;
                if (jump)
                begin
                    if (offset) //jump with offset
                        PCintBackup <= pc_out + jump_addr;
                    else
                        PCintBackup <= jump_addr;
                end
                else
                    PCintBackup <= pc_out + 1'b1;
                int_en <= 1'b0;
                pc_out <= 17'd2;
                ext_int_id <= 4;
            end

            else if (jump) //when jump is high, do jump
            begin
                if (offset) //jump with offset
                    pc_out <= pc_out + jump_addr;
                else
                    pc_out <= jump_addr;
            end
            else 
                pc_out <= pc_out + 1'b1;   //if all these cases fail, then just increase the PC
        end


    else
    begin
        
    end
end

initial
begin
    int_en          <= 1'b1;
    PCintBackup     <= 27'd0;
    pc_out          <= PCstart;
    ext_int_id      <= 8'd0;
    writeBack_prev  <= 1'b0;
    int1_prev       <= 1'b0;
    int2_prev       <= 1'b0;
    int3_prev       <= 1'b0;
    int4_prev       <= 1'b0;
    ext_int1_prev       <= 1'b0;
    ext_int2_prev       <= 1'b0;
    ext_int3_prev       <= 1'b0;
    ext_int4_prev       <= 1'b0;
    rising_int1     <= 1'b0; 
    rising_int2     <= 1'b0; 
    rising_int3     <= 1'b0;
    rising_int4     <= 1'b0;
    rising_ext_int1     <= 1'b0; 
    rising_ext_int2     <= 1'b0; 
    rising_ext_int3     <= 1'b0;
    rising_ext_int4     <= 1'b0;
end
endmodule