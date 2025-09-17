`timescale 1ns / 1ns
`define period          10
`define img_max_size    224*224*3+54
`define path_img_in     "./cat224.bmp"
`define path_test_padding     "./test.bmp"
//`define path_img_out    "./cat224_after_sobel.bmp"
`define path_img_out    "./cat224_after_sobel"
`define path_img_name    "./cat_after_sobel"
`define path_img_name_v2    "./cat_after_sobel_v2"
`include "hw5_cnn_ver2.v"

module tb_cnn ();

integer n;
reg [15:0]bias_1[0:63];
reg [15:0]weight_1[0:1727];
reg [15:0]bias_2[0:63];
reg [15:0]weight_2[0:36863];
reg [1023:0]bias_tb_v1;
reg [27647:0]weight_tb_v1;
reg [1023:0]bias_tb_v2;
reg [589823:0]weight_tb_v2;
reg  clk;
reg  [7:0]  img_data [0:`img_max_size-1];
reg  [7:0]  R;
reg  [7:0]  G;
reg  [7:0]  B;
reg rst;
integer n_num;
integer counter;
integer cv1_wrtie_counter;
integer cv2_op_counter;
integer cv2_wrtie_counter;
integer cv2_read_counter;
integer tb_read_counter;
//integer tb_write_counter;
integer i;
integer for_loop;
integer for_loop_v2;
wire buf_full;
wire [7:0]cnn_pixel;
wire [31:0]counter_cnn;
wire [31:0]counter_cv2;
assign counter_cnn = counter;
assign counter_cv2 = cv2_read_counter;
//reg [23:0]padding_y[0:226*226]-1;
reg [23:0]y;
reg [511:0]y_v2;  

integer img_in;
integer img_out[63:0];
integer img_out_v2[63:0];
integer offset;
integer img_h;
integer img_w;
integer idx;
integer header;
integer test_padding;

reg [31:0]outbmp10;
reg [31:0]outbmp100;

reg [1535:0]cnn_out_reg;
//wire [1535:0]cnn_out;
wire [511:0]cnn_out; // 8*64
wire [511:0]cv2_output;
wire cv1_buffer_full;
wire cv2_buffer_full;
reg cv2_start; 
//assign cnn_out = cnn_out_reg;
reg [7:0]test_cv1;
reg [7:0]test_cv2;
reg [7:0]nxt_input;
reg [15:0]bias_tb;
reg [143:0]weight_tb;
reg bias_block_finish;
reg weight_block_finish;
wire bias_en;
wire bias_rst;
wire weight_en;
wire weight_rst;
wire pixel_en;
wire pixel_rst;

cnn cnn(
    .clk(clk),
    .mod(mod),
    .start(start),
    .transfer_start(transfer_start),
    .bias_en(bias_en),
    .bias_rst(bias_rst),
    .weight_en(weight_en),
    .weight_rst(weight_rst),
    .pixel_en(pixel_en),
    .pixel_rst(pixel_rst),
    .rst(rst),
    .counter_trigger(counter_trigger),
    .nxt_input(nxt_input),
    .bias_tb(bias_tb),
    .weight_tb(weight_tb),
    .bias_block_finish(bias_block_finish),
    .weight_block_finish(weight_block_finish),
    
    .buffer_full(buffer_full),
    .transfer_finish(transfer_finish),
    .cnn_out(cnn_out)

);


initial
	begin
		$readmemh("conv1_bias_hex.txt",bias_1); //讀取file1.txt中的數字到memory
        $readmemh("conv1_kernel_hex.txt",weight_1);
        $readmemh("conv2_bias_hex.txt",bias_2); //讀取file1.txt中的數字到memory
        $readmemh("conv2_kernel_hex.txt",weight_2);

        for (i = 0; i < 64; i = i+1) begin
            bias_tb_v1[1023-i*16-:16] = bias_1[i];
        end

        for (i = 0; i < 1728; i = i+1) begin
            weight_tb_v1[27647-i*16-:16] = weight_1[i];
        end

        for (i = 0; i < 64; i = i+1) begin
            bias_tb_v2[1023-i*16-:16] = bias_2[i];
        end

        for (i = 0; i < 36864; i = i+1) begin
            weight_tb_v2[589823-i*16-:16] = weight_2[i];
        end
	
	end

initial begin
        rst = 0;
        clk = 1'b1;
        i <= 0;
        counter <= 0;
        cv1_wrtie_counter <= 0;
        cv2_wrtie_counter <= 0;
        tb_read_counter <= 0;
        cv2_op_counter <=0;
        cv2_read_counter <=0;
        idx<=0;
        n<=0;
        
        for_loop <= 0;
        for_loop_v2 <= 0;

        cv2_start <=0;

        rst = 1;
        rst = 0;
        bias_block_finish = 0;
        weight_block_finish = 0;
        for (idx = 0;idx<64;idx = idx +1) begin
            bias_tb = bias_1[idx];
            weight_tb = weight_1[idx];
            #(`period);
        end
        

        
    #(`period) //提前1s
        for(idx = 0; idx < (img_h+2)*(img_w+2)+1; idx = idx+1) begin //最後227次給cv2

           if (idx < (img_h+2)*(img_w+2)+1) begin
           if (idx<226) begin
            nxt_input= 0;
            #(`period);
            nxt_input= 0;
            #(`period);
            nxt_input= 0;
            #(`period);
            end
           else if (idx >(226*226-226)) begin
            nxt_input= 0;
            #(`period);
            nxt_input= 0;
            #(`period);
            nxt_input= 0;
            #(`period);
            if (buffer_full) begin
            for (for_loop = 0;for_loop<64;for_loop = for_loop+1) begin
                //$fwrite(img_out[for_loop], "%c%c%c", cnn_out[1535-for_loop*24-:8], cnn_out[1535-for_loop*24-8 -:8], cnn_out[1535-for_loop*24-16 -:8]);
                $fwrite(img_out[for_loop], "%c%c%c", cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8]);
                
                //$display (cnn_out[1535-i*24-:8]);
                end
            cv1_wrtie_counter = cv1_wrtie_counter +1;
           end
           end 

           else if ((idx%226 == 0) || (idx%226 == 225)) begin
            nxt_input= 0;
           end
           else begin

            nxt_input= img_data[(tb_read_counter)*3 + offset + 2]; //B
            #(`period);
            nxt_input = img_data[(tb_read_counter)*3 + offset + 1]; //G
            #(`period);
            nxt_input = img_data[(tb_read_counter)*3 + offset + 0]; //R
            #(`period);
            //$fwrite(test_padding, "%c%c%c", y[23:16], y[15:8], y[7:0]);
            tb_read_counter = tb_read_counter +1;
            //$display ("%b",y);

           if (cv1_buffer_full) begin
            for (for_loop = 0;for_loop<64;for_loop = for_loop+1) begin
                //$fwrite(img_out[for_loop], "%c%c%c", cnn_out[1535-for_loop*24-:8], cnn_out[1535-for_loop*24-8 -:8], cnn_out[1535-for_loop*24-16 -:8]);
                $fwrite(img_out[for_loop], "%c%c%c", cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8]);
                
                //$display (cnn_out[1535-i*24-:8]);
                end
            cv1_wrtie_counter = cv1_wrtie_counter +1;
           end


           end
           
           /*if (cv1_buffer_full&&(cv1_wrtie_counter<50176)) begin
           for (for_loop = 0;for_loop<64;for_loop = for_loop+1) begin
            //$fwrite(img_out[for_loop], "%c%c%c", cnn_out[1535-for_loop*24-:8], cnn_out[1535-for_loop*24-8 -:8], cnn_out[1535-for_loop*24-16 -:8]);
            $fwrite(img_out[for_loop], "%c%c%c", cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8]);
            
            //$display (cnn_out[1535-i*24-:8]);
            end
            cv1_wrtie_counter = cv1_wrtie_counter +1;
           end*/

           counter <= counter + 1;

           if (idx == 455)
           test_cv1 = cnn_out;
           end

        #(`period);
        end

        for(idx = 0; idx < (img_h+2)*(img_w+2)+1; idx = idx+1) begin //最後227次給cv2

           if (idx < (img_h+2)*(img_w+2)+1) begin
           if (idx<226) begin
            y= 0;
            end
           else if (idx >(226*226-226)) begin
            y= 0;
            if (cv1_buffer_full) begin
            for (for_loop = 0;for_loop<64;for_loop = for_loop+1) begin
                //$fwrite(img_out[for_loop], "%c%c%c", cnn_out[1535-for_loop*24-:8], cnn_out[1535-for_loop*24-8 -:8], cnn_out[1535-for_loop*24-16 -:8]);
                $fwrite(img_out[for_loop], "%c%c%c", cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8]);
                
                //$display (cnn_out[1535-i*24-:8]);
                end
            cv1_wrtie_counter = cv1_wrtie_counter +1;
           end
           end 

           else if ((idx%226 == 0) || (idx%226 == 225)) begin
            y= 0;
           end
           else begin

            y[7:0] = img_data[(tb_read_counter)*3 + offset + 2]; //B
            y[15:8] = img_data[(tb_read_counter)*3 + offset + 1]; //G
            y[23:16] = img_data[(tb_read_counter)*3 + offset + 0]; //R
            $fwrite(test_padding, "%c%c%c", y[23:16], y[15:8], y[7:0]);
            tb_read_counter = tb_read_counter +1;
            //$display ("%b",y);

           if (cv1_buffer_full) begin
            for (for_loop = 0;for_loop<64;for_loop = for_loop+1) begin
                //$fwrite(img_out[for_loop], "%c%c%c", cnn_out[1535-for_loop*24-:8], cnn_out[1535-for_loop*24-8 -:8], cnn_out[1535-for_loop*24-16 -:8]);
                $fwrite(img_out[for_loop], "%c%c%c", cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8]);
                
                //$display (cnn_out[1535-i*24-:8]);
                end
            cv1_wrtie_counter = cv1_wrtie_counter +1;
           end


           end
           
           /*if (cv1_buffer_full&&(cv1_wrtie_counter<50176)) begin
           for (for_loop = 0;for_loop<64;for_loop = for_loop+1) begin
            //$fwrite(img_out[for_loop], "%c%c%c", cnn_out[1535-for_loop*24-:8], cnn_out[1535-for_loop*24-8 -:8], cnn_out[1535-for_loop*24-16 -:8]);
            $fwrite(img_out[for_loop], "%c%c%c", cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8], cnn_out[511-for_loop*8-:8]);
            
            //$display (cnn_out[1535-i*24-:8]);
            end
            cv1_wrtie_counter = cv1_wrtie_counter +1;
           end*/

           counter <= counter + 1;

           if (idx == 455)
           test_cv1 = cnn_out;
           end

        #(`period);
        end
        
        $display(test_cv1);
        $display(test_cv2);
        $display(cv2_wrtie_counter);
        $display(cv2_op_counter);
    #(`period)
        $fclose(img_in);
        for (i = 0;i<64;i = i+1) begin
        $fclose(img_out[i]);
        $fclose(img_out_v2[i]);
        end
        $fclose(test_padding);
        //$stop;
        $finish;
end

initial begin
        img_in  = $fopen(`path_img_in, "rb");
        test_padding = $fopen(`path_test_padding, "wb");

        for (i = 0;i<64;i = i+1) begin 
        outbmp10 = i%10;
        outbmp100 = i/10;
        img_out[i] = $fopen({`path_img_name,"0"+outbmp100 ,"0"+outbmp10 ,".bmp"}, "wb");
        end

        for (i = 0;i<64;i = i+1) begin 
        outbmp10 = i%10;
        outbmp100 = i/10;
        img_out_v2[i] = $fopen({`path_img_name_v2,"0"+outbmp100 ,"0"+outbmp10 ,".bmp"}, "wb");
        end

        n_num = $fread(img_data, img_in);

        img_w   = {img_data[21],img_data[20],img_data[19],img_data[18]};
        img_h   = {img_data[25],img_data[24],img_data[23],img_data[22]};
        offset  = {img_data[13],img_data[12],img_data[11],img_data[10]};

        for(header = 0; header < 54; header = header + 1) begin
			$fwrite(test_padding, "%c", img_data[header]);
        end

        for (i = 0; i<64; i = i+1) begin
        for(header = 0; header < 54; header = header + 1) begin
			$fwrite(img_out[i], "%c", img_data[header]);
            $fwrite(img_out_v2[i], "%c", img_data[header]);
        end
    end
    end

always begin
		#(`period/2.0) clk <= ~clk;
	end


initial
    begin
    $dumpfile("tb_cnn_ver2"); //生成的vcd文件名称
    $dumpvars(0, tb_cnn_ver2); //tb模块名称
    end





endmodule