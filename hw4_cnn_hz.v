`timescale 1ns/1ns
module cnn_hz (
    //input [7735:0]line_buffer_in, //8*967
    input [7:0]nxt_grey_pixel,
    input clk,
    input rst,
    input [31:0]counter,
    //output [7:0]cnn_pixel,
    output reg [7:0]cnn_pixel,
    output reg buf_full,
    output reg finish_write
    //output [31:0]counter_cnn
    
);

reg signed [31:0]pixel;
integer pix_max;
//reg [7:0]cnn_pixel_reg;
reg [7:0]buffer_1;
reg [7:0]buffer_2;
reg [7:0]buffer_3;
reg [7:0]buffer_7;
reg [7:0]buffer_8;
reg [7:0]buffer_9;


    





//assign cnn_pixel = cnn_pixel_reg;
//assign counter_cnn = counter;

//genvar  i;
//reg [7735:0]line_buffer;

/*generate
    for (i = 0:i<=966;i++) begin :line_buffer_loop
      line_buffer lb(.in(7735-i*8-:8),.clk(clk),.out())*/
/*assign pixel = line_buffer[7:0] + line_buffer[15:8]*2 + line_buffer[23:16] - line_buffer[7735-:8] - 2*line_buffer[7727-:8] - line_buffer[7719-:8];
always @(posedge clk) begin
    
    if (pixel[9-:8]>128)
    cnn_pixel <= 255;
    else cnn_pixel <= 0;
    line_buffer [7735:0]<= {nxt_grey_pixel,line_buffer[7735:8]};
end*/




/*always @(negedge clk) begin
    line_buffer[7735-:8] <= nxt_grey_pixel;
end*/

//assign cnn_pixel = line_buff[0] + line_buff[1] * 2 + line_buff[2] -line_buff[964] - 2*line_buff[965] - line_buff[966];

/*always @(posedge clk) begin
    for (i = 0;i<967;i++) begin
        line_buff[i] <= line_buff[i+1];
    end
    line_buff[966] <= nxt_grey_pixel;

end*/


reg [7:0]line_buffer[0:966];
integer i;
//assign pixel = line_buffer[0] + line_buffer[1] * 2 + line_buffer[2] -line_buffer[964] - 2*line_buffer[965] - line_buffer[966];
//integer counter;

always @(posedge clk,posedge rst) begin
    if (rst) begin
        buf_full <= 0;
        //cnn_pixel <= 0;
        pix_max <= 0;
        //counter <= 0;
        for (i = 0;i<=966;i = i+1) begin
            line_buffer[i] <= 0;
        end
    end
    else begin
    //finish_write = 0;
    //if (!buf_full) begin
        //counter <= counter +1;
        if (counter > 966)
         buf_full <= 1;
    //end

    

    for (i = 0;i<966;i = i+1) begin
        line_buffer[i] <= line_buffer[i+1];
    end
    line_buffer[966] <= nxt_grey_pixel;

    end
end

always @(negedge clk) begin
    //finish_write = 0;

    if (buf_full) begin
       buffer_1 <= line_buffer[0];
       buffer_2 <= line_buffer[1];
       buffer_3 <= line_buffer[2];
       buffer_7 <= line_buffer[964];
       buffer_8 <= line_buffer[965];
       buffer_9 <= line_buffer[966];


       pixel <= line_buffer[0] + line_buffer[1] * 2 + line_buffer[2] -line_buffer[964] - 2*line_buffer[965] - line_buffer[966];

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
end


endmodule

/*module line_buffer (
    input [7:0] in,
    input clk,
    output reg [7:0]out
);
always @(posedge clk) begin
    out <= in;
end*/


