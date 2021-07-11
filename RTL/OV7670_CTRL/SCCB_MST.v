/* 
 * SCCB Master
 * Copyright (C) 2021, Jaeseok Heo (jseok.heo@gmail.com)
 *                                 (jseok_heo@korea.ac.kr)
 * 
 * Description:     SCCB Master Interface for controlling OV7670 Camera module 
 *                  Supports Write Transmission only
 *                  Supports Single slave device only
 * History:              
 *          2021.07.11 - Initial release
 *          2021.07.11 - Removed r_busy
 */

module SCCB_MST
(
     input          I_CLK
    ,input          I_RST_N
    ,input [31:0]   I_DATA              // Sync to I_CLK
    ,input          I_START             // Sync to I_CLK
    ,output         O_BUSY              // Sync to I_CLK
    ,output         O_WAIT_INTR_CLR     // Sync to I_CLK
    ,input          I_INTR_CLR          // Sync to I_CLK, Interrupt clear
    // SCCB Interface
    ,output         O_SCCB_E_N          // Not available with only single slave device
    ,output         O_SIO_C             // SCL
    ,inout          IO_SIO_D            // SDA
);
    
    localparam H = 1'b1;
    localparam L = 1'b0;
    localparam STATE_IDLE = 2'd0;
    localparam STATE_RUN  = 2'd1;
    localparam STATE_INTR = 2'd2;

    reg  [ 5:0] r_phase_bit_cnt;
    reg  [31:0] r_data;
    reg         r_scl;
    reg         r_sda;
    reg         r_sio_d_oe_m_n;
    wire        w_is_wr_done;
    wire        w_is_data_valid;
    wire        w_exit_STATE_IDLE;
    wire        w_exit_STATE_RUN;
    wire        w_exit_STATE_INTR;

    reg  [ 1:0] r_state;
    reg  [ 1:0] r_next_state;
    reg         r_start;
    reg         r_intr_clr;

    always @(posedge I_CLK, negedge I_RST_N)
        if(!I_RST_N)    r_state <= STATE_IDLE;
        else            r_state <= r_next_state;

    always @(*) begin
             if(!I_RST_N)           r_next_state = STATE_IDLE;
        else if(w_exit_STATE_IDLE)  r_next_state = STATE_RUN;
        else if(w_exit_STATE_RUN)   r_next_state = STATE_INTR;
        else if(w_exit_STATE_INTR)  r_next_state = STATE_IDLE;
    end

    always @(posedge I_CLK, negedge I_RST_N)
             if(!I_RST_N)               r_data <= 32'h0;
        else if(r_state == STATE_IDLE)  r_data <= I_DATA;

    assign O_BUSY = r_state == STATE_RUN;

    assign O_WAIT_INTR_CLR = r_state == STATE_INTR;

    always @(posedge I_CLK, negedge I_RST_N)
             if(!I_RST_N)               r_start <= L;
        else if(w_exit_STATE_IDLE)      r_start <= L;
        else if(r_state == STATE_IDLE)  r_start <= I_START;

    always @(posedge I_CLK, negedge I_RST_N)
             if(!I_RST_N)               r_intr_clr <= L;
        else if(w_exit_STATE_INTR)      r_intr_clr <= L;
        else if(r_state == STATE_INTR)  r_intr_clr <= I_INTR_CLR;
        else                            r_intr_clr <= L;

    assign w_exit_STATE_IDLE = r_start      & (r_state == STATE_IDLE);
    assign w_exit_STATE_RUN  = w_is_wr_done & (r_state == STATE_RUN );
    assign w_exit_STATE_INTR = r_intr_clr   & (r_state == STATE_INTR);

    assign w_is_wr_done = r_phase_bit_cnt == 6'd33;

    assign w_is_data_valid   = (r_phase_bit_cnt >= 6'd3) && (r_phase_bit_cnt <= 6'd29);


    always @(posedge I_CLK, negedge I_RST_N)
        if(!I_RST_N)                    r_phase_bit_cnt <= 10'h0;
        else if(w_exit_STATE_RUN)       r_phase_bit_cnt <= 10'h0;
        else if(r_state == STATE_RUN)   r_phase_bit_cnt <= r_phase_bit_cnt + 6'd1;

    always @(*) begin
             if(!I_RST_N)                   r_scl = H;
        else if(r_phase_bit_cnt == 6'd0 )   r_scl = H;
        else if(r_phase_bit_cnt == 6'd1 )   r_scl = H;
        else if(r_phase_bit_cnt == 6'd2 )   r_scl = L;
        else if(r_phase_bit_cnt == 6'd30)   r_scl = H;
        else if(r_phase_bit_cnt == 6'd31)   r_scl = H;
        else                                r_scl = L;
    end

    always @(*) begin
             if(!I_RST_N)                   r_sda = H;
        else if(r_phase_bit_cnt == 6'd0 )   r_sda = H;
        else if(r_phase_bit_cnt == 6'd1 )   r_sda = L;
        // ID ADDR
        else if(r_phase_bit_cnt == 6'd3 )   r_sda = I_DATA[23];
        else if(r_phase_bit_cnt == 6'd4 )   r_sda = I_DATA[22];
        else if(r_phase_bit_cnt == 6'd5 )   r_sda = I_DATA[21];
        else if(r_phase_bit_cnt == 6'd6 )   r_sda = I_DATA[20];
        else if(r_phase_bit_cnt == 6'd7 )   r_sda = I_DATA[19];
        else if(r_phase_bit_cnt == 6'd8 )   r_sda = I_DATA[18];
        else if(r_phase_bit_cnt == 6'd9 )   r_sda = I_DATA[17];
        else if(r_phase_bit_cnt == 6'd10)   r_sda = I_DATA[16];
        else if(r_phase_bit_cnt == 6'd11)   r_sda = H; // Phase 0 ACK
        // SUB ADDR
        else if(r_phase_bit_cnt == 6'd12)   r_sda = I_DATA[15];
        else if(r_phase_bit_cnt == 6'd13)   r_sda = I_DATA[14];
        else if(r_phase_bit_cnt == 6'd14)   r_sda = I_DATA[13];
        else if(r_phase_bit_cnt == 6'd15)   r_sda = I_DATA[12];
        else if(r_phase_bit_cnt == 6'd16)   r_sda = I_DATA[11];
        else if(r_phase_bit_cnt == 6'd17)   r_sda = I_DATA[10];
        else if(r_phase_bit_cnt == 6'd18)   r_sda = I_DATA[ 9];
        else if(r_phase_bit_cnt == 6'd19)   r_sda = I_DATA[ 8];
        else if(r_phase_bit_cnt == 6'd20)   r_sda = H; // Phase 1 ACK
        // WDATA
        else if(r_phase_bit_cnt == 6'd21)   r_sda = I_DATA[ 7];
        else if(r_phase_bit_cnt == 6'd22)   r_sda = I_DATA[ 6];
        else if(r_phase_bit_cnt == 6'd23)   r_sda = I_DATA[ 5];
        else if(r_phase_bit_cnt == 6'd24)   r_sda = I_DATA[ 4];
        else if(r_phase_bit_cnt == 6'd25)   r_sda = I_DATA[ 3];
        else if(r_phase_bit_cnt == 6'd26)   r_sda = I_DATA[ 2];
        else if(r_phase_bit_cnt == 6'd27)   r_sda = I_DATA[ 1];
        else if(r_phase_bit_cnt == 6'd28)   r_sda = I_DATA[ 0];
        else if(r_phase_bit_cnt == 6'd29)   r_sda = H; // Phase 2 ACK
        else if(r_phase_bit_cnt == 6'd30)   r_sda = L;
        else if(r_phase_bit_cnt == 6'd32)   r_sda = H;
        else                                r_sda = L;
    end

    always @(*) begin
             if(r_phase_bit_cnt == 6'd11)   r_sio_d_oe_m_n = H;   // Phase 0 ACK => SIO D is used as input
        else if(r_phase_bit_cnt == 6'd20)   r_sio_d_oe_m_n = H;   // Phase 1 ACK => SIO D is used as input
        else if(r_phase_bit_cnt == 6'd29)   r_sio_d_oe_m_n = H;   // Phase 2 ACK => SIO D is used as input
        else                                r_sio_d_oe_m_n = L;
    end

    assign O_SIO_C  = r_scl | w_is_data_valid ? ~I_CLK : L;
    assign IO_SIO_D = r_sio_d_oe_m_n ? 1'hz : r_sda;
//    assign O_SCCB_E_N = r_state == IDLE ? H : L;
    assign O_SCCB_E_N = H;

endmodule

