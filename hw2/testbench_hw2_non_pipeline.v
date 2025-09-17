module testbench_hw2_non_pipeline ();

wire [15:0]d;
wire [7:0]a;
wire [7:0]b;
wire [7:0]c;

reg [7:0]randa_t;
reg [7:0]randa;
reg [7:0]randb;
reg [7:0]randc;
reg contr;
reg switch;
reg [7:0] MAX_num ;
integer  error_count;
integer expect_val;


non_pipeline non_pip(
    .a(randa),
    .b(randb),
    .c(randc),
    .contr(contr),
    .d(d)
    );

always  begin
    #5
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

always begin
#10 switch = ~switch;
    //contr = contr;
end

always  @(d)begin  //check result

    
    if(contr == 0) expect_val = (randa+randb)*randc;
    else if (contr ==1) expect_val = (randa-randb)*randc;
    #1
    if (d != expect_val) begin
        $display("Expect %d,but get %d on d,at %t.",expect_val,d,$time);
        error_count = error_count +1;
    end
end


initial begin
    
    
    contr = 0;
    error_count = 0;
    switch = 0;
    MAX_num = 63;

    
    
    
    #200 $display("error_count = %d.",error_count);
    $finish;

end

initial
begin
$dumpfile("wave_testbench_hw2_non_pipeline.vcd"); //生成的vcd文件名称
$dumpvars(0, testbench_hw2_non_pipeline); //tb模块名称
end

endmodule

module non_pipeline  (
    input [7:0]a,
    input [7:0]b,
    input [7:0]c,
    input contr,
    output reg [15:0]d
    
);

reg [7:0]temp1;
reg [15:0]temp2;

always @(a,b,c,contr) begin
    if (contr == 0) temp1 = a+b;
    else if (contr == 1) temp1 = a-b;
    temp2 = temp1 * c;
    d <= temp2;
end
    
endmodule
