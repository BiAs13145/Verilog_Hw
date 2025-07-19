module cnnv1 (
    input [23:0]nxt_in_pixel,
    input clk,
    input rst,
    input [1023:0]bias_tb,
    input [27647:0]weight_tb, //16*3*3*3*64
    input [31:0]counter,
    output buf_full_out,
    //output [1535:0]cv1_output_pixel_rgb, //8*3*64
    output [511:0]cv1_output_pixel //8*64
);
reg [23:0]line_buffer[0:454];//226*2+3=455
wire [23:0]element0;
wire [23:0]element1;
wire [23:0]element2;
wire [23:0]element3;
wire [23:0]element4;
wire [23:0]element5;
wire [23:0]element6;
wire [23:0]element7; 
wire [23:0]element8;

assign element0 = line_buffer[0];
assign element1 = line_buffer[1];
assign element2 = line_buffer[2];
assign element3 = line_buffer[226];
assign element4 = line_buffer[227];
assign element5 = line_buffer[228];
assign element6 = line_buffer[452];
assign element7 = line_buffer[453];
assign element8 = line_buffer[454];

reg buf_full;
//wire buf_full_in;
assign buf_full_out = buf_full;


genvar i;
integer n;
//integer counter;

/*generate 
    for (i=0;i<4;i=i+1) 
    begin:conv1
    kernel_op R(.clk(clk),.element0(element0[23-:8]),
                            .element1(element1[23-:8]),
                            .element2(element2[23-:8]),
                            .element3(element3[23-:8]),
                            .element4(element4[23-:8]),
                            .element5(element5[23-:8]),
                            .element6(element6[23-:8]),
                            .element7(element7[23-:8]),
                            .element8(element8[23-:8]),
                            .bias(bias_tb[1023-i*16-:16]),
                            .weight(weight_tb[27647-i*16*3*3*3-:16*9]),
                            .buf_full_in(buf_full),
                            .kernel_out(cv1_output_pixel[1535-i*24-:8])
                            );
    kernel_op G(.clk(clk),.element0(element0[15-:8]),
                            .element1(element1[15-:8]),
                            .element2(element2[15-:8]),
                            .element3(element3[15-:8]),
                            .element4(element4[15-:8]),
                            .element5(element5[15-:8]),
                            .element6(element6[15-:8]),
                            .element7(element7[15-:8]),
                            .element8(element8[15-:8]),
                            .bias(bias_tb[1023-i*16-:16]),
                            .weight(weight_tb[27647-144-i*16*3*3*3-:16*9]),
                            .buf_full_in(buf_full),
                            .kernel_out(cv1_output_pixel[1535-i*24-8 -:8])
                            );
    kernel_op B(.clk(clk),.element0(element0[7-:8]),
                            .element1(element1[7-:8]),
                            .element2(element2[7-:8]),
                            .element3(element3[7-:8]),
                            .element4(element4[7-:8]),
                            .element5(element5[7-:8]),
                            .element6(element6[7-:8]),
                            .element7(element7[7-:8]),
                            .element8(element8[7-:8]),
                            .bias(bias_tb[1023-i*16-:16]),
                            .weight(weight_tb[27647-144*2-i*16*3*3*3-:16*9]),
                            .buf_full_in(buf_full),
                            .kernel_out(cv1_output_pixel[1535-i*24-16 -:8])
                            );
    end
    endgenerate*/
generate
    for (i = 0;i <64; i = i+1)
    begin :conv1_64
    kernel_RGB_channel_cv1 rgb(
        .clk(clk),
    .element0(element0),
    .element1(element1),
    .element2(element2),
    .element3(element3),
    .element4(element4),
    .element5(element5),
    .element6(element6),
    .element7(element7), 
    .element8(element8),
    .bias(bias_tb[1023-i*16-:16]),
    .weight(weight_tb[27647-i*432-:432]), 
    .buf_full(buf_full),
    .rgb_kernel_out(cv1_output_pixel[511-i*8-:8])
    );
    end
    endgenerate

always @(posedge clk,posedge rst) begin
    if (rst) begin
        buf_full <= 0;
        
        
        for (n = 0;n<=454;n = n+1) begin
            line_buffer[n] <= 0;
        end
    end
    else begin

        if (counter > 454)
         buf_full <= 1;
    //end

    

    for (n = 0;n<454;n = n+1) begin
        line_buffer[n] <= line_buffer[n+1];
    end
    line_buffer[454] <= nxt_in_pixel;

    end
end
/*always @(negedge clk) begin
    
    if (buf_full_in) begin
     if(cv1_output_pixel<0)
     kernel_out <= 0;
     else 
     kernel_out <= temp;  
    end

end*/

/*always @(negedge clk) begin
    //finish_write = 0;

    if (buf_full) begin

       

       if (pixel < 0 )
       cnn_pixel<= 0;
       else if (pixel > 31) 
       cnn_pixel<=255;
       else 
       cnn_pixel<= 0;

       if (pixel > pix_max)
       pix_max <= pixel;

       //finish_write = 1;    
    end
end*/

endmodule




module kernel_op (
    //input clk,
    input [7:0]element0,
    input [7:0]element1,
    input [7:0]element2,
    input [7:0]element3,
    input [7:0]element4,
    input [7:0]element5,
    input [7:0]element6,
    input [7:0]element7,
    input [7:0]element8,

    //input [15:0]bias,
    input [143:0]weight, //16*3*3

    //input buf_full_in,
    //output reg signed [7:0]kernel_out
    output wire signed [18:0]kernel_out_t
);
wire [15:0]w0;
wire [15:0]w1;
wire [15:0]w2;
wire [15:0]w3;
wire [15:0]w4;
wire [15:0]w5;
wire [15:0]w6;
wire [15:0]w7;
wire [15:0]w8;

wire [8:0]selement0;
wire [8:0]selement1;
wire [8:0]selement2;
wire [8:0]selement3;
wire [8:0]selement4;
wire [8:0]selement5;
wire [8:0]selement6;
wire [8:0]selement7;
wire [8:0]selement8;
assign selement0 ={1'b0,element0};
assign selement1 ={1'b0,element1};
assign selement2 ={1'b0,element2};
assign selement3 ={1'b0,element3};
assign selement4 ={1'b0,element4};
assign selement5 ={1'b0,element5};
assign selement6 ={1'b0,element6};
assign selement7 ={1'b0,element7};
assign selement8 ={1'b0,element8};

//wire signed [7:0]temp;
wire signed [16:0]temp_e01;
wire signed [16:0]temp_e23;
wire signed [16:0]temp_e45;
wire signed [16:0]temp_e67;
wire signed [17:0]temp_e018;
wire signed [17:0]temp_e2345;
wire signed [18:0]temp_e01867;
wire signed [18:0]temp_eall;

assign temp_e01 = $signed(selement0)*$signed(w0) +$signed(selement1)*$signed(w1);
assign temp_e23 = $signed(selement2)*$signed(w2) +$signed(selement3)*$signed(w3);
assign temp_e45 = $signed(selement4)*$signed(w4) +$signed(selement5)*$signed(w5);
assign temp_e67 = $signed(selement6)*$signed(w6) +$signed(selement7)*$signed(w7);
assign temp_e018 = $signed(temp_e01) +$signed(selement8)*$signed(w8);
assign temp_e2345 = $signed(temp_e23) +$signed(temp_e45);
assign temp_e01867 = $signed(temp_e018) +$signed(temp_e67);
assign temp_eall= $signed(temp_e2345) +$signed(temp_e01867);

assign kernel_out_t = temp_eall;

//wire signed [11:0]kernel_out_t;

assign {w0,w1,w2,w3,w4,w5,w6,w7,w8} = weight;

/*assign kernel_out_t = $signed(element0)*$signed(w0) +
                  $signed(element1)*$signed(w1) +
                  $signed(element2)*$signed(w2) +
                  $signed(element3)*$signed(w3) +
                  $signed(element4)*$signed(w4) +
                  $signed(element5)*$signed(w5) +
                  $signed(element6)*$signed(w6) +
                  $signed(element7)*$signed(w7) +
                  $signed(element8)*$signed(w8) 
                  
                  ;*/

//assign temp = $signed(kernel_out_t[11-:8])+$signed(bias);
//assign kernel_out = $signed(kernel_out_t[11-:8]);
/*always @(negedge clk) begin
    
    if (buf_full_in) begin
     if(temp<0)
     kernel_out <= 0;
     else 
     kernel_out <= temp;  
    end

end*/


endmodule

module kernel_RGB_channel_cv1 (
    input clk,
    input [23:0]element0,
    input [23:0]element1,
    input [23:0]element2,
    input [23:0]element3,
    input [23:0]element4,
    input [23:0]element5,
    input [23:0]element6,
    input [23:0]element7, 
    input [23:0]element8,
    input [15:0]bias,
    input [431:0]weight, //16*3*3*3
    input buf_full,
    output reg [7:0]rgb_kernel_out

);
//wire [35:0]rgb_out_temp;
wire signed [18:0]rgb_kernel_out_t;
wire signed[18:0]RGB_kernel_out[0:2];
wire signed [18:0]R_out;
wire signed [18:0]G_out;
wire signed [18:0]B_out;

assign R_out = RGB_kernel_out[0];
assign G_out = RGB_kernel_out[1];
assign B_out = RGB_kernel_out[2];
genvar i;

generate for (i=0;i<3;i=i+1)  //channel R G B
    begin:conv1_kernel
    kernel_op RGB(          .element0(element0[23-i*8-:8]),
                            .element1(element1[23-i*8-:8]),
                            .element2(element2[23-i*8-:8]),
                            .element3(element3[23-i*8-:8]),
                            .element4(element4[23-i*8-:8]),
                            .element5(element5[23-i*8-:8]),
                            .element6(element6[23-i*8-:8]),
                            .element7(element7[23-i*8-:8]),
                            .element8(element8[23-i*8-:8]),
                            //.bias(bias),
                            .weight(weight[431-i*16*3*3-:16*9]),
                            //.buf_full_in(buf_full),
                            .kernel_out_t(RGB_kernel_out[i])
                            );
    end
    endgenerate
assign rgb_kernel_out_t = $signed(RGB_kernel_out[0]) + $signed(RGB_kernel_out[1]) + $signed(RGB_kernel_out[2]) + $signed(bias);

always @(negedge clk) begin
    if (buf_full) begin
        if (rgb_kernel_out_t >0)
        rgb_kernel_out <= rgb_kernel_out_t[11-:8];
        else
        rgb_kernel_out <= 0;
    end
end

endmodule

module cnnv2 (
    input [511:0]nxt_in_pixel,
    input clk,
    input rst,
    input [1023:0]bias_tb,
    input [589823:0]weight_tb, //16*9*64*64
    input [31:0]counter,
    //input bull_full_out_cv1,
    input cv2_start,
    output buf_full_out,
    //output [1535:0]cv1_output_pixel_rgb, //8*3*64
    output reg [511:0]cv2_output_pixel //8*64
);

reg [511:0]line_buffer[0:454];//226*2+3=455
wire [511:0]element0;
wire [511:0]element1;
wire [511:0]element2;
wire [511:0]element3;
wire [511:0]element4;
wire [511:0]element5;
wire [511:0]element6;
wire [511:0]element7; 
wire [511:0]element8;

assign element0 = line_buffer[0];
assign element1 = line_buffer[1];
assign element2 = line_buffer[2];
assign element3 = line_buffer[226];
assign element4 = line_buffer[227];
assign element5 = line_buffer[228];
assign element6 = line_buffer[452];
assign element7 = line_buffer[453];
assign element8 = line_buffer[454];

reg buf_full;
integer n;

assign buf_full_out = buf_full;

wire signed[22:0]little_kernel_out[0:63];

genvar i;

generate for (i=0;i<64;i=i+1)  //channel R G B
    begin:conv2_64_kernel
    kernel_single_channel_cv2 big64(       .element0(element0),
                                            .element1(element1),
                                            .element2(element2),
                                            .element3(element3),
                                            .element4(element4),
                                            .element5(element5),
                                            .element6(element6),
                                            .element7(element7),
                                            .element8(element8),
                                            .bias(bias_tb[1023-i*16-:16]),
                                            .weight(weight_tb[589823-i*9216-:9216]),
                                            //.buf_full_in(buf_full),
                                            .single_kernel_out(little_kernel_out[i])
                                            );
    end
    endgenerate

always @(posedge clk,posedge rst) begin
    if (rst) begin
        buf_full <= 0;
        
        
        for (n = 0;n<=454;n = n+1) begin
            line_buffer[n] <= 0;
        end
    end
    else begin

        if (counter > 454)
         buf_full <= 1;
    //end

    

    for (n = 0;n<454;n = n+1) begin
        line_buffer[n] <= line_buffer[n+1];
    end
    line_buffer[454] <= nxt_in_pixel;

    end
end

always @(negedge clk) begin
    for (n = 0;n<64;n = n+1) begin
        if (little_kernel_out[n]>0)
        cv2_output_pixel[511-n*8-:8] = little_kernel_out[n][14-:8];
        else cv2_output_pixel[511-n*8-:8] = 0;
    end
end

endmodule

module kernel_single_channel_cv2 (
    input clk,
    input [511:0]element0,
    input [511:0]element1,
    input [511:0]element2,
    input [511:0]element3,
    input [511:0]element4,
    input [511:0]element5,
    input [511:0]element6,
    input [511:0]element7, 
    input [511:0]element8,
    input [15:0]bias,
    input [9215:0]weight, //16*9*64
    input buf_full,
    output signed [22:0]single_kernel_out
);

//wire signed [22:0]single_kernel_out_t;
//wire signed[18:0]SIN_kernel_out[0:63];
wire signed[1215:0]SIN_kernel_out;
wire signed [19:0]addertree_level1_out[0:31];
wire signed [20:0]addertree_level2_out[0:15];
wire signed [21:0]addertree_level3_out[0:7];
wire signed [22:0]addertree_level4_out[0:3];
wire signed [23:0]addertree_level5_out[0:1];
wire signed [24:0]addertree_level6_out;


genvar i;

generate for (i=0;i<64;i=i+1)  //channel R G B
    begin:conv2_single_kernel
    kernel_op litttle9(       .element0(element0[511-i*8-:8]),
                            .element1(element1[511-i*8-:8]),
                            .element2(element2[511-i*8-:8]),
                            .element3(element3[511-i*8-:8]),
                            .element4(element4[511-i*8-:8]),
                            .element5(element5[511-i*8-:8]),
                            .element6(element6[511-i*8-:8]),
                            .element7(element7[511-i*8-:8]),
                            .element8(element8[511-i*8-:8]),
                            //.bias(bias),
                            .weight(weight[9215-i*16*3*3-:16*9]),
                            //.buf_full_in(buf_full),
                            .kernel_out_t(SIN_kernel_out[1215-i*19-:19])
                            );
    end
    endgenerate
assign single_kernel_out = $signed(addertree_level6_out)  + $signed(bias);


generate for (i = 0;i<32;i = i+1)
   begin:add_tree_lv1
   addertree_1 lv1(
    .a(SIN_kernel_out[1215-i*38-:19]),
    .b(SIN_kernel_out[1215-i*38-19-:19]),
    .c(addertree_level1_out[i])
   );
   end
   endgenerate

generate for (i = 0;i<16;i = i+1)
   begin:add_tree_lv2
   addertree_2 lv2(
    .a(addertree_level1_out[i]),
    .b(addertree_level1_out[i+1]),
    .c(addertree_level2_out[i])
   );
   end
   endgenerate

generate for (i = 0;i<8;i = i+1)
   begin:add_tree_lv3
   addertree_3 lv3(
    .a(addertree_level2_out[i]),
    .b(addertree_level2_out[i+1]),
    .c(addertree_level3_out[i])
   );
   end
   endgenerate

generate for (i = 0;i<4;i = i+1)
   begin:add_tree_lv4
   addertree_4 lv4(
    .a(addertree_level3_out[i]),
    .b(addertree_level3_out[i+1]),
    .c(addertree_level4_out[i])
   );
   end
   endgenerate

generate for (i = 0;i<2;i = i+1)
   begin:add_tree_lv5
   addertree_5 lv5(
    .a(addertree_level4_out[i]),
    .b(addertree_level4_out[i+1]),
    .c(addertree_level5_out[i])
   );
   end
   endgenerate

assign addertree_level6_out = addertree_level5_out[0] + addertree_level5_out[1];

endmodule







module addertree_1 (
    input [18:0]a,
    input [18:0]b,
    output wire signed [19:0]c
);

assign c = $signed(a) + $signed(b);

endmodule

module addertree_2 (
    input [19:0]a,
    input [19:0]b,
    output wire signed [20:0]c
);

assign c = $signed(a) + $signed(b);

endmodule

module addertree_3 (
    input [20:0]a,
    input [20:0]b,
    output wire signed [21:0]c
);

assign c = $signed(a) + $signed(b);

endmodule

module addertree_4 (
    input [21:0]a,
    input [21:0]b,
    output wire signed [22:0]c
);

assign c = $signed(a) + $signed(b);

endmodule

module addertree_5 (
    input [22:0]a,
    input [22:0]b,
    output wire signed [23:0]c
);

assign c = $signed(a) + $signed(b);

endmodule

module addertree_6 (
    input [23:0]a,
    input [23:0]b,
    output wire signed [24:0]c
);

assign c = $signed(a) + $signed(b);

endmodule

