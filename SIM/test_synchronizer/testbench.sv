module testbench;

    localparam RST_VAL          = 0;
    localparam STAGE            = 3;
    localparam DW               = 32;
    localparam CLK_A_PERIOD     = 50; // 20MHz
    localparam CLK_B_PERIOD     = 40; // 25MHz

    reg             r_clk_a     ;
    reg             r_clk_b     ;
    reg             r_rst_n     ;
    reg  [DW-1:0]   r_data      ;
    wire [DW-1:0]   w_data      ;

    SYNCHRONIZER #( 
         .RST_VAL(  RST_VAL )
        ,.STAGE  (  STAGE   )
        ,.DW     (  DW      )
    )
    Inst_SYNCHRONIZER (
         .I_CLK  (  r_clk_b )       //    input           I_CLK
        ,.I_RST_N(  r_rst_n )       //    input           I_RST_N
        ,.I_DATA (  r_data  )       //    input  [DW-1:0] I_DATA
        ,.O_DATA (  w_data  )       //    output [DW-1:0] O_DATA
    );

    initial begin
        forever #(CLK_A_PERIOD/2) r_clk_a = ~r_clk_a;
    end

    initial begin
        forever #(CLK_B_PERIOD/2) r_clk_b = ~r_clk_b;
    end
    
    initial begin
        r_clk_a = 'h0;
        r_clk_b = 'h0;
        r_rst_n = 'h0;
        r_data  = 'h0;

        #200; r_rst_n = 'h1;
        
        repeat(30) begin
            @(posedge r_clk_a); #1;
            r_data = $urandom();
            repeat(STAGE) @(posedge r_clk_b); #1;
            if(w_data != r_data) begin
                $display("%c[1;31m",27);
                $display("=========================================================");
                $display("*I,                    TEST FAILED!                      ");
                $display("=========================================================");
                $display("*E, Input Data = %x, Output Data = %x are not the same !",r_data, w_data);
                $display("%c[0m",27);
                $finish();
            end
        end
        
        $display("%c[1;34m",27);
        $display("=========================================================");
        $display("*I,                    TEST PASSED!                      ");
        $display("=========================================================");
        $display("%c[0m",27);
        $finish();
    end

endmodule: testbench
