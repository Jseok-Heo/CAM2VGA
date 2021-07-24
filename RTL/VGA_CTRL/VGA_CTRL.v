/* 
 * VGA Controller
 * Copyright (C) 2021, Jaeseok Heo (jseok.heo@gmail.com)
 *                                 (jseok_heo@korea.ac.kr)
 * 
 * Description:     VGA (Video Graphic Array) Timing Controller
 *                  Supports 640 x 480 Resolution
 *                  
 * History:              
 *          2021.07.18 - Initial release
 */

module VGA_CTRL
#(
     parameter DW_R = 8
    ,parameter DW_G = 8
    ,parameter DW_B = 8
)
(
     input				I_CLK					// Clock 25 MHz, VGA_CLK = 25 MHz
    ,input				I_RST_N					// Reset

    ,input	[DW_R-1:0]	I_R						//	input R,G,B Pixel Value
    ,input	[DW_G-1:0]	I_G
    ,input	[DW_B-1:0]	I_B

    ,output	[DW_R-1:0]	O_VGA_R					// output Signals for VIDEO DAC
    ,output	[DW_G-1:0]	O_VGA_G
    ,output [DW_B-1:0]  O_VGA_B		

    ,output	            O_VGA_H_SYNC			// Horizontal_Sync
    ,output	            O_VGA_V_SYNC			// Vertical_Sync

//    ,output	[7:0]		O_VGA_SYNC_N			// 0 for Activating Sync
//    ,output				O_VGA_BLANK_N			// 0 for BLANK

//    ,output				out_Request
//    ,output				Disp_Valid				// H & V Sync is in the Visible Area
//    
//    ,output				H_Video_ON				// H sync is in the visible Area
//    ,output				V_Video_ON				// V sync is in the visible Area
    
);

//	Horizontal Parameter	( Pixel )
localparam	H_SYNC_RETRACE		=	96;             // Returning to the Left Edge
localparam	H_SYNC_LEFT_BORDER	=	48;             // Back Porch
localparam	H_SYNC_ACTIVE   	=	640;	
localparam	H_SYNC_RIGHT_BORDER	=	16;             // Front Portch
localparam	H_SYNC_TOTAL        =   H_SYNC_RETRACE
                                +   H_SYNC_LEFT_BORDER
                                +   H_SYNC_ACTIVE
                                +   H_SYNC_RIGHT_BORDER;    // 800

//	Vertical Parameter		( Line )
localparam	V_SYNC_RETRACE		    =	2;                      // V_SYNC
localparam	V_SYNC_TOP_BORDER	    =	33;	                    // Back Porch
localparam	V_SYNC_ACTIVE	        =	480;
localparam	V_SYNC_BOTTOM_BORDER    =	10;                     // Front Porch
localparam	V_SYNC_TOTAL    	    =	V_SYNC_RETRACE
                                    +	V_SYNC_TOP_BORDER
                                    +	V_SYNC_ACTIVE
                                    +	V_SYNC_BOTTOM_BORDER;   // 525

localparam  H           = 1'b1;
localparam  L           = 1'b0;
localparam  DISABLED    = 1'b0;
localparam  ENABLED     = 1'b1;

localparam	X_START		=	H_SYNC_RETRACE + H_SYNC_LEFT_BORDER;    // 96 + 48 = 144
localparam	X_END		=	X_START + H_SYNC_ACTIVE;                // 144 + 640 = 784

localparam	Y_START		=	V_SYNC_RETRACE + V_SYNC_TOP_BORDER;		// 2  + 33 = 35
localparam	Y_END		=	Y_START + V_SYNC_ACTIVE;                // 35 + 480 = 515

reg [9:0] r_h_cnt;
reg [9:0] r_v_cnt;
reg       r_h_data_enable;
reg       r_v_data_enable;

wire    w_is_h_cnt_ended                = (r_h_cnt == H_SYNC_TOTAL-1);
wire    w_is_left_border_almost_ended   = (r_h_cnt == X_START-2);
wire    w_is_left_border_ended          = (r_h_cnt == X_START-1);
wire    w_start_of_h_active             = (r_h_cnt == X_START);
wire    w_is_h_active                   = (r_h_cnt >= X_START && r_h_cnt < X_END);
wire    w_is_h_active_almost_ended      = (r_h_cnt == X_END-2);
wire    w_end_of_h_active               = (r_h_cnt == X_END-1);

wire    w_is_v_cnt_ended                = (r_v_cnt == V_SYNC_TOTAL-1);
wire    w_is_top_border_almost_ended    = (r_v_cnt == Y_START-2);
wire    w_is_top_border_ended           = (r_v_cnt == Y_START-1);
wire    w_start_of_v_active             = (r_v_cnt >= Y_START);
wire    w_is_v_active                   = (r_v_cnt >= Y_START && r_v_cnt < Y_END);
wire    w_is_v_active_almost_ended      = (r_v_cnt == Y_END-2);
wire    w_end_of_v_active               = (r_v_cnt == Y_END-1);

wire    w_is_data_writable              = r_h_data_enable && r_v_data_enable;

wire    w_is_start_of_frame             = (r_h_cnt == X_START && r_v_cnt == 10'd0);
wire    w_is_end_of_frame               = (r_h_cnt == X_END   && r_v_cnt == Y_END);

reg [DW_R-1:0]  r_R;
reg [DW_R-1:0]  r_G;
reg [DW_R-1:0]  r_B;

always @(posedge I_CLK, negedge I_RST_N)
         if(!I_RST_N)           r_R <= {DW_R{1'b0}};
    else if(w_is_data_writable) r_R <= I_R;

always @(posedge I_CLK, negedge I_RST_N)
         if(!I_RST_N)           r_G <= {DW_G{1'b0}};
    else if(w_is_data_writable) r_G <= I_G;

always @(posedge I_CLK, negedge I_RST_N)
         if(!I_RST_N)           r_B <= {DW_B{1'b0}};
    else if(w_is_data_writable) r_B <= I_B;

assign O_VGA_R = r_R;
assign O_VGA_G = r_G;
assign O_VGA_B = r_B;

always @(posedge I_CLK, negedge I_RST_N)
         if(!I_RST_N)                       r_h_data_enable <= DISABLED;
    else if(w_is_left_border_almost_ended)  r_h_data_enable <= ENABLED;
    else if(w_is_h_active_almost_ended)     r_h_data_enable <= DISABLED;

always @(posedge I_CLK, negedge I_RST_N) 
         if(!I_RST_N)                       r_v_data_enable <= DISABLED;
    else if(w_is_top_border_almost_ended)   r_v_data_enable <= ENABLED;
    else if(w_is_v_active_almost_ended)     r_v_data_enable <= DISABLED;

always @(posedge I_CLK, negedge I_RST_N)
         if(!I_RST_N)           r_h_cnt <= 10'h0;
    else if(w_is_h_cnt_ended)   r_h_cnt <= 10'h0;
    else                        r_h_cnt <= r_h_cnt + 10'd1;

assign O_VGA_H_SYNC = (r_h_cnt >= 0) && (r_h_cnt < H_SYNC_RETRACE) ? L : H;

always @(posedge I_CLK, negedge I_RST_N)
         if(!I_RST_N)           r_v_cnt <= 10'h0;
    else if(w_is_v_cnt_ended)   r_v_cnt <= 10'h0;
    else if(w_is_h_cnt_ended)   r_v_cnt <= r_v_cnt + 10'd1;

assign O_VGA_V_SYNC = (r_v_cnt >= 0) && (r_v_cnt < V_SYNC_RETRACE) ? L : H;

endmodule

