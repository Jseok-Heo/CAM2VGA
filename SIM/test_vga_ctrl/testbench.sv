module testbench;

    localparam CLK_PERIOD = 40; // 25MHz
    localparam DW_R = 8;
    localparam DW_G = 8;
    localparam DW_B = 8;
    string input_file = "/home/jseok/CAM2VGA/SIM/lib/img/lenna_640x480.bmp";
    string output_file = "result.bmp";

    reg             r_clk		;
    reg             r_rst_n	    ;
    reg  [DW_R-1:0] r_R         ;
    reg  [DW_G-1:0] r_G         ;
    reg  [DW_B-1:0] r_B         ;
    wire [DW_R-1:0] w_VGA_R     ;
    wire [DW_G-1:0] w_VGA_G     ;
    wire [DW_B-1:0] w_VGA_B     ;
    wire            w_vga_h_sync;
    wire            w_vga_v_sync;

    VGA_CTRL
    #(
         .DW_R(DW_R)
        ,.DW_G(DW_G)
        ,.DW_B(DW_B)
    ) Inst_VGA_CTRL (
         .I_CLK			(  r_clk		    )  // input				I_CLK					// Clock 25 MHz, VGA_CLK = 25 MHz
        ,.I_RST_N		(  r_rst_n	        )  // input				I_RST_N					// Reset
        ,.I_R           (  r_R              )  // input	 [DW_R-1:0]	I_R						//	input R,G,B Pixel Value
        ,.I_G           (  r_G              )  // input	 [DW_G-1:0]	I_G
        ,.I_B           (  r_B              )  // input	 [DW_B-1:0]	I_B
        ,.O_VGA_R       (  w_VGA_R          )  // output [DW_R-1:0]	O_VGA_R					// output Signals for VIDEO DAC
        ,.O_VGA_G       (  w_VGA_G          )  // output [DW_G-1:0]	O_VGA_G
        ,.O_VGA_B       (  w_VGA_B          )  // output [DW_B-1:0] O_VGA_B		
        ,.O_VGA_H_SYNC	(  w_vga_h_sync     )  // output	        O_VGA_H_SYNC			// Horizontal_Sync
        ,.O_VGA_V_SYNC	(  w_vga_v_sync     )  // output	        O_VGA_V_SYNC			// Vertical_Sync
    );

    bmp_driver _bmp_driver;

    initial begin
        forever #(CLK_PERIOD/2) r_clk = ~r_clk;
    end
    
    initial begin
        r_clk   = 'h0;
        r_rst_n = 'h0;

        repeat(10) @(posedge r_clk); 
        #1; r_rst_n = 'h1;

        _bmp_driver = new();
        _bmp_driver.read_bmp(input_file);
        
//        repeat(30) begin
//            @(posedge r_clk_a); #1;
//            r_data = $urandom();
//            repeat(STAGE) @(posedge r_clk_b); #1;
//            if(w_data != r_data) begin
//                $display("%c[1;31m",27);
//                $display("=========================================================");
//                $display("*I,                    TEST FAILED!                      ");
//                $display("=========================================================");
//                $display("*E, Input Data = %x, Output Data = %x are not the same !",r_data, w_data);
//                $display("%c[0m",27);
//                $finish();
//            end
//        end
//        
//        $display("%c[1;34m",27);
//        $display("=========================================================");
//        $display("*I,                    TEST PASSED!                      ");
//        $display("=========================================================");
//        $display("%c[0m",27);
//        $finish();

        repeat(1000000) @(posedge r_clk);
        $finish();
    end

endmodule: testbench
