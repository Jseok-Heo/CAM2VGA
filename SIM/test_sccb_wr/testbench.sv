module testbench;

    reg         r_clk       ;
    reg         r_rst_n     ;
    reg [23:0]  r_data      ;
    wire        w_sccb_e_n  ;
    wire        w_sio_c     ;
    wire        w_sio_d     ;

    localparam CLK_PERIOD = 40;

    SCCB_MST Inst_SCCB_MST (
         .I_CLK         (   r_clk                  )   // input          I_CLK
        ,.I_RST_N       (   r_rst_n                )   //,input          I_RST_N
        ,.I_DATA        (   r_data                 )   //,input [23:0]   I_DATA
        ,.O_SCCB_E_N    (   w_sccb_e_n             )   //,output         O_SCCB_E_N       // Not available with only single slave device
        ,.O_SIO_C       (   w_sio_c                )   //,output         O_SIO_C
        ,.IO_SIO_D      (   w_sio_d                )   //,inout          IO_SIO_D
    );

    initial begin
        forever #(CLK_PERIOD/2) r_clk = ~r_clk;
    end

    initial begin
        r_clk   = 'h0;
        r_rst_n = 'h0;
        r_data  = 'hab_cd_ef;

        #200; r_rst_n = 'h1;

        #1000;
        $finish();
    end
    
endmodule: testbench
