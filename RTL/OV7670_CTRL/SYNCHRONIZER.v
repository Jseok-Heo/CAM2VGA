/* 
 * Synchronizer
 * Copyright (C) 2021, Jaeseok Heo (jseok.heo@gmail.com)
 *                                 (jseok_heo@korea.ac.kr)
 * 
 * Description:
 *
 *
 * History:              
 *          2021.07.11 - Initial release
 *
 */
module SYNCHRONIZER
#(
     parameter RST_VAL = 1'b0
    ,parameter STAGE   = 2
    ,parameter DW      = 1
)
(
     input           I_CLK
    ,input           I_RST_N
    ,input  [DW-1:0] I_DATA
    ,output [DW-1:0] O_DATA
);

    reg [0:STAGE-1][DW-1:0]    r_data;

    genvar i;

    generate
        for(i=0; i<STAGE; i=i+1) begin
            if(i==0) begin
                always @(posedge I_CLK, negedge I_RST_N)
                    if(!I_RST_N)    r_data[i]   <= {DW{RST_VAL}};
                    else            r_data[i]   <= I_DATA;

            end
            else begin
                always @(posedge I_CLK, negedge I_RST_N)
                    if(!I_RST_N)    r_data[i]   <= {DW{RST_VAL}};
                    else            r_data[i]   <= r_data[i-1];
            end

            if(i==STAGE-1)  assign O_DATA = r_data[i];
        end

    endgenerate


    initial begin
        if(STAGE <= 1)  $error("*E, STAGE must be at least 2");
    end
endmodule
