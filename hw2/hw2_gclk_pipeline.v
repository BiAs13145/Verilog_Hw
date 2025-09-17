`timescale 1ns/1ns


module gclk_pipeline  (
    input [7:0]a,
    input [7:0]b,
    input [7:0]c,
    input clk,
    input contr,
    input nrst,
    output reg [15:0]d   
);


wire [7:0]stage1_result;
wire [7:0]stage1_cout;
wire [15:0]stage2_result;
wire [15:0]stage2_mux_out;



gclk_pipeline_stage1 gclk_stage1 (
    .a(a),
    .b(b),
    .c(c),
    .clk(clk),
    .contr(contr),
    .nrst(nrst),
    .stage1_result(stage1_result),
    .en_out(en_out),
    .c_out(stage1_cout)
);
gclk_pipeline_stage2 gclk_stage2 (
    .c(stage1_cout),
    .stage1_result(stage1_result),
    .clk(clk),
    .stage2_result(stage2_result),
    .en(en_out),
    .nrst(nrst)
);
mux_stage2 mux(
    .en(en_out),
    .stage2_result(stage2_result),
    .stage2_mux_out(stage2_mux_out)
);
always @(stage2_mux_out)begin
    d<=stage2_mux_out;
end
    
endmodule

module gclk_pipeline_stage1(
    input [7:0]a,
    input [7:0]b,
    input [7:0]c,
    input clk,
    input contr,
    input nrst,
    output reg [7:0]stage1_result,
    output reg [7:0]c_out,
    output reg en_out
);
reg en;
reg [7:0]stage1_temp;
assign gclk = clk && en;




always @(a,b) begin
    if (contr == 0) stage1_temp <= a+b;
    else if (contr == 1) stage1_temp <= a-b;
    
    
end

always @ (c) begin
    
    if (c!=0) en <= 1;
    else en <= 0;
end

always @(negedge clk) begin
    if (c == 0) begin 
         en_out <= en;
    end
    else  begin 
        en_out <= en;
    end
end



always @(posedge gclk or negedge nrst) begin
    if (!nrst) begin stage1_result <= 0;
              en_out <= 0;
              c_out <= 0;
              stage1_temp<=0;
    end
    
    else 
    begin
         
        if(en == 1) begin 
        stage1_result <= stage1_temp;
         
         c_out <= c;
         end
    end
end

endmodule

module gclk_pipeline_stage2(
    input [7:0]c,
    input [7:0]stage1_result,
    input clk,
    input en,
    input nrst,
    output reg [15:0]stage2_result
);
assign gclk = clk && en;
reg [15:0]stage2_temp;


always @(posedge gclk or negedge nrst) begin
    if (!nrst) stage2_result<=0;
    else stage2_result<=c*stage1_result;
end

endmodule

module mux_stage2 (
    input en,
    input [15:0]stage2_result,
    output reg [15:0]stage2_mux_out 
);
always @(en,stage2_result)
begin
    case(en)
    1'b0 : stage2_mux_out <= 0;
    1'b1 : stage2_mux_out <= stage2_result;
    endcase
end

endmodule
