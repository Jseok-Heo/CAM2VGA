class packet;
    rand bit [7:0] r_id_addr    ;
    rand bit [7:0] r_sub_addr   ;
    rand bit [7:0] r_byte_data  ;

    constraint trans_type { r_id_addr[0] == 0; }

    function bit [31:0] get_packet();
        get_packet = {r_id_addr, r_sub_addr, r_byte_data, 8'h00};
    endfunction : get_packet

    function void display();
        $display("ID_ADDR : %x, SUB_ADDR : %x, DATA : %x", r_id_addr, r_sub_addr, r_byte_data);
    endfunction : display

endclass: packet

module testbench;

    reg         r_clk           ;
    reg         r_rst_n         ;
    reg  [31:0] r_data          ;
    reg         r_start         ;
    wire        w_busy          ;
    wire        w_wait_intr_clr ;
    reg         r_intr_clr      ;
    wire        w_sccb_e_n      ;
    wire        w_sio_c         ;
    wire        w_sio_d         ;

    localparam CLK_PERIOD = 40;

    SCCB_MST Inst_SCCB_MST (
         .I_CLK             (   r_clk           )   // input          I_CLK
        ,.I_RST_N           (   r_rst_n         )   //,input          I_RST_N
        ,.I_DATA            (   r_data          )   //,input [23:0]   I_DATA
        ,.I_START           (   r_start         )   //.input          I_START
        ,.O_BUSY            (   w_busy          )   //.output         O_BUSY
        ,.O_WAIT_INTR_CLR   (   w_wait_intr_clr )   //.output         O_WAIT_INTR_CLR
        ,.I_INTR_CLR        (   r_intr_clr      )   //.input          I_INTR_CLR
        ,.O_SCCB_E_N        (   w_sccb_e_n      )   //,output         O_SCCB_E_N       // Not available with only single slave device
        ,.O_SIO_C           (   w_sio_c         )   //,output         O_SIO_C
        ,.IO_SIO_D          (   w_sio_d         )   //,inout          IO_SIO_D
    );

    packet _pkt = new();

    initial begin
        forever #(CLK_PERIOD/2) r_clk = ~r_clk;
    end

    initial begin
        r_clk       = 'h0;
        r_rst_n     = 'h0;
        r_data      = 'h0;
        r_start     = 'h0;
        r_intr_clr  = 'h0;


        #200; r_rst_n = 'h1;
        repeat(4) begin
            repeat(100) @(posedge r_clk); #1;
            _pkt.randomize();
            _pkt.display();
            r_data = _pkt.get_packet();
            @(posedge r_clk); #1;
            r_start    = 1;
            r_intr_clr = 0;

            repeat(100) @(posedge r_clk); #1;

            if(w_wait_intr_clr == 1) begin
                repeat(3) @(posedge r_clk);
                #1;
                r_intr_clr = 1;
                r_start    = 0;
            end
        end

        $finish();
    end
    
endmodule: testbench
