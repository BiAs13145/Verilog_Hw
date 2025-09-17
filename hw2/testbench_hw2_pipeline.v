module testbench_hw2_pipeline();

wire [7:0]a;
wire [7:0]b;
wire [7:0]c;
wire [15:0]d;
reg [7:0]randa_t;
reg [7:0]randa;
reg [7:0]randb;
reg [7:0]randc;
reg clk;
reg tclk;
reg nrst;
reg contr;
reg switch;

reg [7:0] MAX_num ;
integer  error_count;
integer expect_val;

assign a = randa;
assign b = randb;
assign c = randc;

pipeline pip(
    .a(a),
    .b(b),
    .c(c),
    .clk(clk),
    .contr(contr),
    .d(d)
    );

initial begin
    $dumpfile("wave_testbench_hw2_pipeline.vcd"); //生成的vcd文件名称
    $dumpvars(0, testbench_hw2_pipeline); //tb模块名称
    #215 $finish;
end

initial begin
    clk = 0;
    randa = 0;
    randb = 0;
    randc = 0;
    nrst = 1;
    contr = 0;
    error_count = 0;
    switch = 0;
    MAX_num = 63;
    
    #3 nrst = 0;
    #7tclk = 0;
    
    #200 $display("error_count = %d.",error_count);

end



always begin
#5 clk = ~clk;
end

always begin
#5    tclk = ~tclk;
end


always begin
#10 switch = ~switch;
    //contr = contr;
end

always @ (posedge clk) begin
    randa_t =($random)%MAX_num;
    

    randb =($random)%MAX_num;
    randa <= randa_t+randb;
    if (switch == 0) begin
    randc <=($random)%MAX_num;
    end
    else if (switch == 1 ) begin
    randc <= 0;
    end
end

always @(posedge tclk) begin
    #1
    if (contr == 0)
    expect_val <= (a + b)*c;
    else if (contr == 1)
    expect_val <= (a - b)*c;
end

always @(posedge tclk) begin  //check result

    #1
    if (d != expect_val) begin
        $display("Expect %d,but get %d on d,at %t.",expect_val,d,$time);
        error_count = error_count +1;
    end
end

endmodule

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