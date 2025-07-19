`timescale 1ns/1ns

module pipeline  (
    input [7:0]a,
    input [7:0]b,
    input [7:0]c,
    input clk,
    input contr,
    output reg [15:0]d   
);


wire [7:0]stage1_result;
wire [7:0]c_out;
wire [15:0]stage2_result;

pipeline_stage1 stage1 (
    .a(a),
    .b(b),
    .c(c),
    .clk(clk),
    .contr(contr),
    .stage1_result(stage1_result),
    .c_out(c_out)
);
pipeline_stage2 stage2 (
    .c(c_out),
    .stage1_result(stage1_result),
    .clk(clk),
    .stage2_result(stage2_result)
);
always @(stage2_result)begin
    d<=stage2_result;
end
    
endmodule

module pipeline_stage1(
    input [7:0]a,
    input [7:0]b,
    input [7:0]c,
    input clk,
    input contr,
    output reg [7:0]stage1_result,
    output reg [7:0]c_out

);
reg [7:0]stage1_temp;
always @(a,b) begin
    if (contr == 0)stage1_temp <= a+b;
    else if (contr == 1)stage1_temp <= a-b;
end

always @(negedge clk) begin
    stage1_result<=stage1_temp;
    c_out  <=c;
end

endmodule

module pipeline_stage2(
    input [7:0]c,
    input [7:0]stage1_result,
    input clk,
    output reg [15:0]stage2_result
);
reg [15:0]stage2_temp;
always @(posedge clk) begin
    stage2_temp <= c*stage1_result;
end
always @(negedge clk) begin
    stage2_result<=stage2_temp;
end

endmodule