module cnn(
    input clk,
    input mod,
    input start,
    input transfer_start,
    input bias_en,
    input bias_rst,
    input weight_en,
    input weight_rst,
    input pixel_en,
    input pixel_rst,
    input rst,
    input counter_trigger,
    input [7:0]nxt_input,
    input [15:0]bias_tb,
    input [143:0]weight_tb,
    output bias_block_finish,
    output weight_block_finish,
    
    output buffer_full,
    output transfer_finish,
    output [7:0]cnn_out

);


wire [1023:0]bias;
wire [27647:0]weight;
wire [3639:0]pixel;
wire [511:0]input_batch;
//wire bias_block_finish;
//wire weight_block_finish;
//wire buffer_full;

wire bias_gclk;
assign bias_gclk = clk&&bias_en;
wire weight_gclk;
assign weight_gclk = clk&&pixel_en;
wire pixel_gclk;
assign pixel_gclk = clk&&pixel_en;


bias_buffer bias_buf (
    .bias_gclk(bias_gclk),
    .bias_rst(bias_rst),
    .input_bias(bias_tb),
    .bias_block_finish(bias_block_finish),
    .bias_buff_out(bias)
);
weight_buffer weight_buf (
    .weight_gclk(weight_gclk),
    .weight_rst(weight_rst),
    .input_weight(weight_tb),
    .weight_block_finish(weight_block_finish),
    .weight_buff_out(weight)
);
pixel_buffer pixel_buf (
    .pixel_gclk(weight_gclk),
    .pixel_rst(weight_rst),
    .input_pixel(nxt_input),
    .buffer_full(buffer_full),
    .pixel_buff_out(pixel)
);

output_buffer out_buf(
    .clk(clk),
    .output_rst(output_rst),
    .input_batch(input_batch),
    .output_finish(output_finish),
    .cnn_out(cnn_out) //8*455
);

wire [7:0]element0;
wire [7:0]element1;
wire [7:0]element2;
wire [7:0]element3;
wire [7:0]element4;
wire [7:0]element5;
wire [7:0]element6;
wire [7:0]element7; 
wire [7:0]element8;
wire [1535:0]cu_out;
assign element0 = pixel[1*8-1-:8];
assign element1 = pixel[2*8-1-:8];
assign element2 = pixel[3*8-1-:8];
assign element3 = pixel[227*8-1-:8];
assign element4 = pixel[228*8-1-:8];
assign element5 = pixel[229*8-1-:8];
assign element6 = pixel[3623-:8];
assign element7 = pixel[3631-:8];
assign element8 = pixel[3639-:8];

comput_unit cu(
    .clk(clk),
    //.mod(mod),

    .element0(element0),
    .element1(element1),
    .element2(element2),
    .element3(element3),
    .element4(element4),
    .element5(element5),
    .element6(element6),
    .element7(element7),
    .element8(element8),
    .bias_tb(bias), //16*64
    .weight_tb(weight), //16*3*3*3*64
    .buf_full(buf_full),
    .cu_out(cu_out) //8*64
);

/*if (mod == 0) //cv1
begin
   if (bias_block_finish && weight_block_finish) begin
    cnn_out = cu_out;
   end
end*/
assign cnn_out = (bias_block_finish && weight_block_finish)?cu_out:0;

always @ (posedge clk) begin
if (mod == 0) //cv1
begin

end

if (mod == 1) //cv2
begin

end

end

always @ (negedge clk) begin
if (mod == 0) //cv1
begin

end

if (mod == 1) //cv2
begin

end

end

endmodule




module comput_unit (
    input clk,
    //input mod,

    input [7:0]element0,
    input [7:0]element1,
    input [7:0]element2,
    input [7:0]element3,
    input [7:0]element4,
    input [7:0]element5,
    input [7:0]element6,
    input [7:0]element7,
    input [7:0]element8,
    input [1023:0]bias_tb, //16*64
    input [27647:0]weight_tb, //16*3*3*3*64
    input buf_full,
    output wire [1535:0]cu_out //8*192
);
genvar i;
wire [1535:0]cu_out_t;

generate
    for (i = 0;i <191; i = i+1)
    begin : gen_loop
    
    kernel_op cv1(
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
    .bias(bias_tb[1023-(i/3)*16-:16]),
    .weight(weight_tb[27647-i*144-:144]), 
    
    .kernel_out(cu_out_t[1535-i*8-:8])
    );

    end
    
    endgenerate
/*always @(negedge clk) begin
    if (buf_full) begin
        if (rgb_kernel_out_t >0)
        rgb_kernel_out <= rgb_kernel_out_t[11-:8];
        else
        rgb_kernel_out <= 0;
    end
end*/

/*if (buf_full) begin
    cu_out = cu_out_t;
end
else begin
    cu_out = x;
end*/
assign cu_out = (buf_full)?cu_out_t:0;
    
endmodule

module kernel_op (
    input clk,
    input [7:0]element0,
    input [7:0]element1,
    input [7:0]element2,
    input [7:0]element3,
    input [7:0]element4,
    input [7:0]element5,
    input [7:0]element6,
    input [7:0]element7,
    input [7:0]element8,

    input [15:0]bias,
    input [143:0]weight, //16*3*3

    //input buf_full,
    output reg [7:0]kernel_out
    //output wire signed [23:0]kernel_out_t
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


wire signed [20:0]temp_e01;
wire signed [20:0]temp_e23;
wire signed [20:0]temp_e45;
wire signed [20:0]temp_e67;
wire signed [20:0]temp_e8b;
wire signed [21:0]temp_e0123;
wire signed [21:0]temp_e4567;
wire signed [22:0]temp_e0123b8;
wire signed [23:0]temp_all;



assign temp_e01 = $signed(selement0)*$signed(w0) +$signed(selement1)*$signed(w1);
assign temp_e23 = $signed(selement2)*$signed(w2) +$signed(selement3)*$signed(w3);
assign temp_e45 = $signed(selement4)*$signed(w4) +$signed(selement5)*$signed(w5);
assign temp_e67 = $signed(selement6)*$signed(w6) +$signed(selement7)*$signed(w7);
assign temp_e8b = $signed(bias) +$signed(selement8)*$signed(w8);
assign temp_e0123 = $signed(temp_e23) +$signed(temp_e01);
assign temp_e04567 = $signed(temp_e45) +$signed(temp_e67);
assign temp_e0123b8= $signed(temp_e0123) +$signed(temp_e8b);
assign temp_all= $signed(temp_e0123) +$signed(temp_e8b);

//assign kernel_out_t = temp_all;



assign {w0,w1,w2,w3,w4,w5,w6,w7,w8} = weight;


//assign temp = $signed(kernel_out_t[11-:8])+$signed(bias);
//assign kernel_out = $signed(kernel_out_t[11-:8]);
always @(negedge clk) begin
    
    
     if(temp_all<0)
     kernel_out <= 0;
     else 
     kernel_out <= temp_all[14-:8];  
    

end


endmodule

module bias_buffer (
    input bias_gclk,
    input bias_rst,
    input [15:0]input_bias,
    output reg bias_block_finish,
    output reg [1023:0]bias_buff_out
);


integer bias_counter;

always @(posedge bias_gclk,posedge bias_rst) begin
   if (bias_rst) begin
    bias_counter <= 0;
    bias_buff_out <= 0;
    bias_block_finish <=0;
   end
   else begin
   bias_counter <= bias_counter +1;
   bias_buff_out[1023-:16]<=input_bias;
   bias_buff_out <= bias_buff_out >>16;
   
   if (bias_counter == 63) begin
    bias_block_finish <= 1;
   end
   end 
end

endmodule

module weight_buffer (
    input weight_gclk,
    input weight_rst,
    input [143:0]input_weight,
    output reg weight_block_finish,
    output reg [27647:0]weight_buff_out
);


integer weight_counter;

always @(posedge weight_gclk,posedge weight_rst) begin
   if (weight_rst) begin
    weight_counter <= 0;
    weight_buff_out <= 0;
    weight_block_finish <=0;
   end
   else begin
   weight_counter <= weight_counter +1;
   weight_buff_out[27647-:144]<=input_weight;
   weight_buff_out <= weight_buff_out >>144;
   
   if (weight_counter == 191) begin
    weight_block_finish <= 1;
   end
   end 
end

endmodule

module pixel_buffer (
    input pixel_gclk,
    input pixel_rst,
    input [7:0]input_pixel,
    output reg buffer_full,
    output reg [3639:0]pixel_buff_out //8*455
);


integer pixel_counter;

always @(posedge pixel_gclk,posedge pixel_rst) begin
   if (pixel_rst) begin
    pixel_counter <= 0;
    pixel_buff_out <= 0;
    buffer_full <=0;
   end
   else begin
   pixel_counter <= pixel_counter +1;
   pixel_buff_out[3639-:8]<=input_pixel;
   pixel_buff_out <= pixel_buff_out >>8;
   
   if (pixel_counter == 454) begin
    buffer_full <= 1;
   end
   end 
end

endmodule

module output_buffer (
    input clk,
    input output_rst,
    input [511:0]input_batch,
    output reg output_finish,
    output reg [7:0]cnn_out //8*455
);

reg [511:0]batch;
integer pixel_counter;

always @(posedge clk,posedge output_rst) begin
   if (output_rst) begin
    pixel_counter <= 0;
    cnn_out <= 0;
    output_finish <= 0;
    batch <= input_batch;
   end
   else begin
   pixel_counter <= pixel_counter +1;
   cnn_out <= batch[7:0];
   batch <= batch >>8;
   
   if (pixel_counter == 63) begin
    output_finish <= 1;
   end
   end 
end

endmodule