class bmp_driver;
    string input_bmp;
    string output_bmp;

    unsigned int bmp_header_len;
    unsigned int bmp_color_num;
    unsigned int bmp_width;
    unsigned int bmp_height;
    unsigned int bmp_pixel_len;
    unsigned int bmp_array_len;
    unsigned int bits_per_color;
    unsigned int clk_period;
    unsigned int padding_pixel;

    function new(string _input_bmp, _output_bmp);
        input_bmp       = _input_bmp;
        output_bmp      = _output_bmp;
        bmp_header_len  = 54;
        bmp_color_num   = 3;
        bmp_width       = 640;
        bmp_height      = 480;
        bmp_pixel_len   = bmp_width * bmp_height;
        bmp_array_len   = bmp_header_len + (bmp_color_num * bmp_pixel_len);
        bits_per_color  = 8;
        clk_period      = 2;
        padding_pixel   = 255;
    endfunction : new

//    bit [BITS_PER_COLOR-1:0] bmp_data[0:BMP_ARRAY_LEN-1];
    bit [BITS_PER_COLOR-1:0] bmp_data[0:bmp_header_len-1];
//    bit [BITS_PER_COLOR-1:0] bmp_pixel_r[0:BMP_PIXEL_LEN-1];
//    bit [BITS_PER_COLOR-1:0] bmp_pixel_g[0:BMP_PIXEL_LEN-1];
//    bit [BITS_PER_COLOR-1:0] bmp_pixel_b[0:BMP_PIXEL_LEN-1];
//    bit [BITS_PER_COLOR-1:0] bmp_pixel_y[0:BMP_PIXEL_LEN-1];
//    bit [BITS_PER_COLOR-1:0] bmp_r[0:BMP_HEIGHT-1][0:BMP_WIDTH-1];
//    bit [BITS_PER_COLOR-1:0] bmp_g[0:BMP_HEIGHT-1][0:BMP_WIDTH-1];
//    bit [BITS_PER_COLOR-1:0] bmp_b[0:BMP_HEIGHT-1][0:BMP_WIDTH-1];
//    bit [BITS_PER_COLOR-1:0] bmp_y[0:BMP_HEIGHT-1][0:BMP_WIDTH-1];
//    bit [BITS_PER_COLOR-1:0] source_frame[0:BMP_HEIGHT+1][0:BMP_WIDTH+1];
//    bit [BITS_PER_COLOR-1:0] target_frame[0:BMP_HEIGHT+1][0:BMP_WIDTH+1];
//
    reg [31:0] bmp_size;
    reg [31:0] bmp_pixel_start_offset; // 14 + 40 = 54 bytes
    reg [31:0] bmp_width;
    reg [31:0] bmp_height;
    reg [31:0] bmp_bits_per_pixel;
//
//    integer kernel_x [0:8] = '{1, 0, -1, 2, 0, -2, 1, 0, -1};
//    integer kernel_y [0:8] = '{1, 2, 1, 0, 0, 0, -1, -2, -1};
//
//    reg CLK, RSTn;
//
//    reg START_OF_FRAME;
//    reg END_OF_FRAME;
//
//    reg [BITS_PER_COLOR-1:0] PIXEL_R;
//    reg [BITS_PER_COLOR-1:0] PIXEL_G;
//    reg [BITS_PER_COLOR-1:0] PIXEL_B;
//
//    integer i;
//
    function read_bmp(input string file_name);
        int fd, i, j, k;

        fd = $fopen(file_name, "rb");

        if(fd == 0) begin
            $display("%c[1;31m",27);
            $display("[DEBUG] *E, Failed to open BMP file!"); 
            $display("%c[0m",27);
            $finish;
        end
        else begin
            void'($fread(bmp_data, fd));
            $fclose(fd);

            bmp_size = {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
            $display("BMP_SIZE = %d", bmp_size);

            bmp_pixel_start_offset = {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
            $display("BMP_PIXEL_START_OFFSET = %d", bmp_pixel_start_offset);

            bmp_width = {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
            $display("BMP_WIDTH = %d", bmp_width);

            bmp_height = {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
            $display("BMP_HEIGHT = %d", bmp_height);

            bmp_bits_per_pixel = {bmp_data[29], bmp_data[28]};
            $display("BMP_BITS_PER_PIXEL = %d", bmp_bits_per_pixel);

            if (bmp_bits_per_pixel != 24) begin
                $display("*E, Bits per pixel should be 24 bits!");
                $finish;
            end

            if(bmp_width % 4) begin
                $display("*E, BMP_WIDTH %% 4 need to be zero");
                $finish;
            end

//            // B G R
//            for(i = bmp_pixel_start_offset; i < bmp_size; i+=3) begin
//                bmp_pixel_b[j] = bmp_data[i];
//                bmp_pixel_g[j] = bmp_data[i+1];
//                bmp_pixel_r[j] = bmp_data[i+2];
//                j += 1;
//            end
//
//            for(i=0; i<BMP_HEIGHT; i=i+1) begin
//                for(j=0; j<BMP_WIDTH; j=j+1) begin
//                    bmp_r[i][j] = bmp_pixel_r[k];
//                    bmp_g[i][j] = bmp_pixel_g[k];
//                    bmp_b[i][j] = bmp_pixel_b[k];
//                    k=k+1;
//                end
//            end
        end
    endfunction: read_bmp

//    task write_bmp(input string file_name);
//        integer fd, i;
//        integer row, col;
//
//        fd = $fopen(file_name);
//
//        if(fd == 0) begin
//            $display("*E, Failed to open BMP file!");
//            $finish;
//        end
//        
//        $display("*I, Write BMP Header Info\n");
//        //$fwrite(fd, "%c", 8'hff);
//        for(i=0; i<BMP_ARRAY_LEN; i=+1)
//            $fwrite(fd, "%c", bmp_data[i]);
//
//        //for(row=0; row<BMP_HEIGHT; row=row+1) begin
//        //    for(col=0; col<BMP_WIDTH; col=col+1) begin
//        //        $fwrite(fd, "%c", target_frame[row][col]);
//        //        $display("*I, ROW=%0d, COL=%0d, Sobel=%0d\n",row, col, target_frame[row][col]);
//        //    end
//        //end
//
//        $fclose(fd);
//        $display("write_BMP done!");
//
//    endtask: write_bmp
//
//    task convert_bmp_rgb2gray;
//        integer row, col;
//        reg [BITS_PER_COLOR-1:0] _r;
//        reg [BITS_PER_COLOR-1:0] _g;
//        reg [BITS_PER_COLOR-1:0] _b;
//
//        $display("*I, Convert RGB to Gray from BMP");
//        for(row=0; row<BMP_HEIGHT; row=row+1) begin
//            for(col=0; col<BMP_WIDTH; col=col+1) begin
//            _r = bmp_r[row][col];
//            _g = bmp_g[row][col];
//            _b = bmp_b[row][col];
//            bmp_y[row][col] = (_r >> 2) + (_r >> 5) +
//                              (_g >> 1) + (_g >> 4) + (_g >> 5) +
//                              (_b >> 3);
//            $display("*I, ROW=%0d, COL=%0d", row, col);
//            $display("*I, R=%0d, G=%0d, B=%0d, Y=%0d\n",_r, _g, _b, bmp_y[row][col]);
//            end
//        end
//    endtask: convert_bmp_rgb2gray
//
//    task conv_bmp;
//        static reg [31:0] row, col;
//        static reg [31:0] padding_val = 0;
//
//        $display("*I, Convolution Operation");
//        $display("*I, Source Frame Generation (Grayscale with Padding)");
//        for(row=0; row<BMP_HEIGHT+2; row+=1) begin
//            for(col=0; col<BMP_WIDTH+2; col+=1) begin
//                if     (row==0)            source_frame[row][col] = padding_val;
//                else if(col==0)            source_frame[row][col] = padding_val;
//                else if(col==BMP_WIDTH+1)  source_frame[row][col] = padding_val;
//                else if(row==BMP_HEIGHT+1) source_frame[row][col] = padding_val;
//                else                       source_frame[row][col] = bmp_y[row-1][col-1];
//                $display("*I, ROW=%0d, COL=%0d, Y=%0d\n",row, col, source_frame[row][col]);
//            end
//        end
//
//        $display("*I, Target Frame Generation (Sobel)");
//        for(row=1; row<BMP_HEIGHT+1; row+=1) begin
//            for(col=1; col<BMP_WIDTH+1; col+=1) begin
//                target_frame[row-1][col-1] = kernel_x[0]*source_frame[row-1][col-1] +
//                                             kernel_x[1]*source_frame[row-1][col]   +
//                                             kernel_x[2]*source_frame[row-1][col+1] +
//                                             kernel_x[3]*source_frame[row][col-1]   +
//                                             kernel_x[4]*source_frame[row][col]     +
//                                             kernel_x[5]*source_frame[row][col+1]   +
//                                             kernel_x[6]*source_frame[row+1][col-1] +
//                                             kernel_x[7]*source_frame[row+1][col]   +
//                                             kernel_x[8]*source_frame[row+1][col+1];
//                $display("*I, ROW=%0d, COL=%0d, Sobel=%0d\n",row, col, target_frame[row-1][col-1]);
//            end
//        end
//    endtask: conv_bmp

endclass : bmp_driver
