`timescale 1ns / 1ns
`define period          10
`define img_max_size    480*360*3+54
//---------------------------------------------------------------
//You need specify the path of image in/out
//---------------------------------------------------------------
`define path_img_in     "./cat.bmp"
`define path_img_out    "./cat_after_sobel.bmp"
`include "cnn_vt.v"

module HDL_HW4_TB;
    integer img_in;
    integer img_out;
    integer offset;
    integer img_h;
    integer img_w;
    integer idx;
    integer header;

    reg         clk;
    reg  [7:0]  img_data [0:`img_max_size-1];
    reg  [7:0]  R;
    reg  [7:0]  G;
    reg  [7:0]  B;
    reg rst;
    reg [7:0]test;
    integer test_pixel_count ;
    integer max_y;
    //wire [19:0] Y;
    wire [19:0] Y;
    integer n_num;
    integer counter;
    integer i;
    //reg [7:0]max_255;
    wire buf_full;
    wire finish_write;
    wire [7:0]cnn_pixel;
    wire [31:0]counter_cnn;
    assign counter_cnn = counter;
    //integer counter;
    //wire [31:0] counter;
    

    //---------------------------------------------------------------
    //Insert your  verilog module at here
    cnn_hz hz(.clk(clk),.rst(rst),.nxt_grey_pixel(Y[19-:8]),.cnn_pixel(cnn_pixel),.buf_full(buf_full),.finish_write(finish_write),.counter(counter_cnn));
    //
    // ...
    //
    //---------------------------------------------------------------

//---------------------------------------------------------------------------------------Take out the color image(cat) of RGB----------------------------------------------
    //---------------------------------------------------------------
    //This initial block write the pixel 
    //---------------------------------------------------------------
    assign Y = R*299+G*587+B*114;
    initial begin
        rst = 0;
        clk = 1'b1;
        test_pixel_count  = 0;
        max_y = 0;
        counter <= 0;
        #1 rst = 1;
        #1 rst = 0;
        
    #(`period-2)
        for(idx = 0; idx < img_h*img_w; idx = idx+1) begin
            R <= img_data[idx*3 + offset + 2];
            G <= img_data[idx*3 + offset + 1];
            B <= img_data[idx*3 + offset + 0];
            
            test_pixel_count <= test_pixel_count + 1;
            test <= Y[19-:8];
            if (Y[19-:8] > max_y) begin
                max_y <= Y[19-:8];
            end

		  
		   //$fwrite(img_out, "%c%c%c", Y[7:0], Y[7:0], Y[7:0]);
           if (counter == 0 || counter == 172800) begin
            for (i = 0;i<480;i = i+1) begin
                $fwrite(img_out, "%c%c%c", 0, 0, 0);
            end
           end
           if (counter%480 == 0 || counter%480 == 479) begin
            $fwrite(img_out, "%c%c%c", 0, 0, 0);
           end
           else
           $fwrite(img_out, "%c%c%c", cnn_pixel, cnn_pixel, cnn_pixel);
           /*if (counter <480 || (172800 - counter)<480) begin
            
                $fwrite(img_out, "%c%c%c", 0, 0, 0);
            
           end
           else if (counter%480 == 0 || counter%480 == 479) begin
            $fwrite(img_out, "%c%c%c", 0, 0, 0);
           end
           else
           $fwrite(img_out, "%c%c%c", Y[19-:8], Y[19-:8], Y[19-:8]);*/


           counter <= counter + 1;
		  

        #(`period);
        end
    #(`period)
        $fclose(img_in);
        $fclose(img_out);
        //$stop;
        $finish;
    end 

    //---------------------------------------------------------------
    //This initial block read the pixel 
    //---------------------------------------------------------------
    initial begin
        img_in  = $fopen(`path_img_in, "rb");
        img_out = $fopen(`path_img_out, "wb");

        n_num = $fread(img_data, img_in);

        img_w   = {img_data[21],img_data[20],img_data[19],img_data[18]};
        img_h   = {img_data[25],img_data[24],img_data[23],img_data[22]};
        offset  = {img_data[13],img_data[12],img_data[11],img_data[10]};


        for(header = 0; header < 54; header = header + 1) begin
			$fwrite(img_out, "%c", img_data[header]);
        end
    end
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    always begin
		#(`period/2.0) clk <= ~clk;
	end



    /*
    initial begin
		$sdf_annotate (`path_sdf, <your instance name>);
	end
    */
    initial
    begin
    $dumpfile("HDL_HW4_TB"); //生成的vcd文件名称
    $dumpvars(0, HDL_HW4_TB); //tb模块名称
    end
endmodule