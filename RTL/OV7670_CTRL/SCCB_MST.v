

// 1. the master device must be able to support and maintain the data line of the bus in a tri-state mode
// 2. the alternative method if the master cannot maintain a tri-state condition of the data line is to drive
//    the data line either high or low and to note the transition there to assert communications with the slave
//    CAMERA CHIP

// O_SCCB_E_N : Serial Chip Select Output (Where SCCB_E is not present on the CAMERA CHIP, this signal is by default enabled and held high)
//              Indicates the start or stop of the data transmission. (Active-low, Driven by Master only)
//              H -> L : a start of transmission.
//              L -> H : a stop  of transmission.
//              Drives at logical 1       : the bus is idle.
//              Drives at logical 0       : the master asserts transmissions or the system is in Suspend mode.
//              => SCCB_E must remain at logical 0 during a data transmission

// O_SIO_C    : Serial I/O Signal 1 Output
//              Indicates each transmitted bit. (Active-high, Driven by Master only)
//              Data transmission starts when SIO_C is driven at logical 0 after the start of transmission.
//              logical 1 of SIO_C during a data transmission indicates a single transmitted bit.
//              Thus, SIO_D can occur only when SIO_C is driven at 0.
//              The period of a signle transmitted bit is defined as tCYC as shown in Figure 3-8.
//              The minimum of tCYC is 10us.
//              Drives at logical 1       : the bus is idle.
//              Drives at logical 0 and 1 : O_SCCB_E is driven at 0.

// IO_SIO_D   : Serial I/O Signal 0 input and Output
//              Driven by either Master or Slave)
//              The master must avoid propagating an unknown bus state condition when the bus is floating or conflicting
//              A conflict-protection resistor is required to redute static current when the bus conflicts (Figure 4-2)
//              A single-bit transmission is indicated by a logical 1 of O_SIO_C
//              SIO_D can occur only when SIO_C is driven at logical 0
//              An exception is allowed at the beginning and the end of a transmission.
//              During the period that SCCB_E is asserted and before SIO_C goes to 0, SIO_D can be driven at 0
//              During the period that SIO_C goes to 1 and before SCCB_E is de-asserted, SIO_D can also be driven at 0
//              Bus float and contention are allowed during transmission of Dont-Care or NA bits.
//              Remains floating          : the bus is idle.
//              Drives at logical 0       : the system is Suspend mode.
// O_PWDN     : Power down output

module SCCB_MST
(
     input          I_CLK
    ,input          I_RST_N
    ,input [23:0]   I_DATA
    // I2C Interface
    ,output         O_SCCB_E_N       // Not available with only single slave device
    ,output         O_SIO_C
    ,inout          IO_SIO_D
);
    
    localparam H = 1'b1;
    localparam L = 1'b0;

    //10101011_11001101_11101111
    wire        w_trans_type = I_DATA[16];       // 0 for write, 1 for read
    reg  [9:0]  r_state_cnt;
    reg         r_scl;
    reg         r_sda;
    reg         r_sio_d_oe_m_n;
//    wire        w_is_wr_done;
//    wire        w_is_rd_done;
    wire        w_is_data_valid;

//    wire        w_is_wr_started = ~w_trans_type;
//    wire        w_is_rd_started = w_trans_type;

    assign w_is_data_valid = r_state_cnt >= 10'd3 && r_state_cnt <= 10'd29;


    always @(posedge I_CLK, negedge I_RST_N)
             if(!I_RST_N)           r_state_cnt <= 10'h0;
//        else if(w_is_wr_done)       r_state_cnt <= 10'h0;
//        else if(w_is_rd_done)       r_state_cnt <= 10'h0;
//        else if(w_is_wr_started)    r_state_cnt <= 10'h0;
//        else if(w_is_rd_started)    r_state_cnt <= 10'h0;
        else                        r_state_cnt <= r_state_cnt + 10'd1;

    always @(*) begin
             if(!I_RST_N)               r_scl = H;
        else if(r_state_cnt == 10'd0)   r_scl = H;
        else if(r_state_cnt == 10'd1)   r_scl = H;
        else if(r_state_cnt == 10'd2)   r_scl = L;
        else if(r_state_cnt == 10'd30)  r_scl = H;
        else if(r_state_cnt == 10'd31)  r_scl = H;
        else                            r_scl = L;
    end

    always @(*) begin
             if(!I_RST_N)               r_sda = H;
        else if(r_state_cnt == 10'd0)   r_sda = H;
        else if(r_state_cnt == 10'd1)   r_sda = L;
        // ID ADDR
        else if(r_state_cnt == 10'd3)   r_sda = I_DATA[23];
        else if(r_state_cnt == 10'd4)   r_sda = I_DATA[22];
        else if(r_state_cnt == 10'd5)   r_sda = I_DATA[21];
        else if(r_state_cnt == 10'd6)   r_sda = I_DATA[20];
        else if(r_state_cnt == 10'd7)   r_sda = I_DATA[19];
        else if(r_state_cnt == 10'd8)   r_sda = I_DATA[18];
        else if(r_state_cnt == 10'd9)   r_sda = I_DATA[17];
        else if(r_state_cnt == 10'd10)  r_sda = I_DATA[16];
        else if(r_state_cnt == 10'd11)  r_sda = H; // ACK
        // SUB ADDR
        else if(r_state_cnt == 10'd12)  r_sda = I_DATA[15];
        else if(r_state_cnt == 10'd13)  r_sda = I_DATA[14];
        else if(r_state_cnt == 10'd14)  r_sda = I_DATA[13];
        else if(r_state_cnt == 10'd15)  r_sda = I_DATA[12];
        else if(r_state_cnt == 10'd16)  r_sda = I_DATA[11];
        else if(r_state_cnt == 10'd17)  r_sda = I_DATA[10];
        else if(r_state_cnt == 10'd18)  r_sda = I_DATA[ 9];
        else if(r_state_cnt == 10'd19)  r_sda = I_DATA[ 8];
        else if(r_state_cnt == 10'd20)  r_sda = H; // ACK
        // WDATA
        else if(r_state_cnt == 10'd21)  r_sda = I_DATA[ 7];
        else if(r_state_cnt == 10'd22)  r_sda = I_DATA[ 6];
        else if(r_state_cnt == 10'd23)  r_sda = I_DATA[ 5];
        else if(r_state_cnt == 10'd24)  r_sda = I_DATA[ 4];
        else if(r_state_cnt == 10'd25)  r_sda = I_DATA[ 3];
        else if(r_state_cnt == 10'd26)  r_sda = I_DATA[ 2];
        else if(r_state_cnt == 10'd27)  r_sda = I_DATA[ 1];
        else if(r_state_cnt == 10'd28)  r_sda = I_DATA[ 0];
        else if(r_state_cnt == 10'd29)  r_sda = H; // ACK
        else if(r_state_cnt == 10'd30)  r_sda = L;
        else if(r_state_cnt == 10'd32)  r_sda = H;
        else                            r_sda = L;
    end

    always @(*) begin
             if(r_state_cnt == 10'd11)  r_sio_d_oe_m_n = H;   // ACK
        else if(r_state_cnt == 10'd20)  r_sio_d_oe_m_n = H;   // ACK
        else if(r_state_cnt == 10'd29)  r_sio_d_oe_m_n = H;   // ACK
        else                            r_sio_d_oe_m_n = L;
    end

    assign O_SIO_C  = r_scl | w_is_data_valid ? ~I_CLK : L;
    assign IO_SIO_D = r_sio_d_oe_m_n ? 1'hz : r_sda;
//    assign O_SCCB_E_N = r_state == IDLE ? H : L;

endmodule

