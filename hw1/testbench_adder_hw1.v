module test_adder_hw1 ();


wire[31:0]A;
wire [31:0]B;
wire [31:0]C;
reg Cin;
wire Cout_adder_structure;
wire Cout_adder_dataflow;
wire Cout_adder_behavior;
wire Cout_adder_structure_reg;
wire Cout_adder_dataflow_reg;
wire Cout_adder_behavior_reg;

wire [31:0]SUM_adder_structure;
wire [31:0]SUM_adder_dataflow;
wire [31:0]SUM_adder_behavior;
wire [31:0]SUM_adder_structure_reg;
wire [31:0]SUM_adder_dataflow_reg;
wire [31:0]SUM_adder_behavior_reg;
wire [31:0] result_adder_structure_reg;
wire [31:0] result_adder_dataflow_reg;
wire [31:0] result_adder_behavior_reg;

reg clk;
wire [31:0]result;
integer  MAX_num;
wire [30:0]randAB;
integer expect_val;
integer  error_count;


//without flip-----------------------------
adder_structure STR(
.A(A),
.B(B),
.SUM(SUM_adder_structure),
.Cin(Cin),
.Cout(Cout_adder_structure)
);

adder_dataflow DF(
.A(A),
.B(B),
.SUM(SUM_adder_dataflow),
.Cin(Cin),
.Cout(Cout_adder_dataflow)
);

adder_behavior BH(
.A(A),
.B(B),
.SUM(SUM_adder_behavior),
.Cin(Cin),
.Cout(Cout_adder_behavior)
);

//with flip-------------------------------

adder_structure_reg STR_reg(
.A(A),
.B(B),
.Cin(Cin),
.Cout(Cout_adder_structure_reg),
.clk(clk),
.result(result_adder_structure_reg)
);

adder_dataflow_reg DF_reg(
.A(A),
.B(B),
.Cin(Cin),
.Cout(Cout_adder_dataflow_reg),
.clk(clk),
.result(result_adder_dataflow_reg)
);

adder_behavior_reg BH_reg(
.A(A),
.B(B),
.Cin(Cin),
.clk(clk),
.result(result_adder_behavior_reg)
);

rand_num ran(
    .clk(clk),
    .MAX_num(MAX_num),
    .randA(A),
    .randB(B)
);

//--------------------------------------------------------------------------------------------------------------------------------

initial begin
    $dumpfile("wave_adder_hw1.vcd"); //生成的vcd文件名称
    $dumpvars(0, test_adder_hw1); //tb模块名称
    #105 $finish;
end

initial begin
    clk = 0;
    Cin = 0;
    error_count = 0;
    MAX_num = 2147483647;

    #105 $display("error_count = %d.",error_count);
    

end

always begin
#10 clk = ~clk;
end



always @(negedge clk) begin  //check result

    #3
    expect_val = (A + B);
    
    if (SUM_adder_structure != expect_val) begin
        $display("Expect %d,but get %d on SUM_adder_structure,at %t.",expect_val,SUM_adder_structure,$time);
        error_count = error_count +1;
    end

    if (SUM_adder_dataflow != expect_val) begin
        $display("Expect %d,but get %d on SUM_adder_dataflow,at %t.",expect_val,SUM_adder_dataflow,$time);
        error_count = error_count +1;
    end

    if (SUM_adder_behavior != expect_val) begin
        //$display("Expect %d,but get %d on SUM_adder_behaivor,at %t.",expect_val,SUM_adder_behaivor,$time);
        error_count = error_count +1;
    end
//---------------------------------------------------------------------------------------------------------------
    if (result_adder_structure_reg != expect_val) begin
        $display("Expect %d,but get %d on SUM_adder_structure_reg,at %t.",expect_val,result_adder_structure_reg,$time);
        error_count = error_count +1;
    end

    if (result_adder_dataflow_reg!= expect_val) begin
        $display("Expect %d,but get %d on SUM_adder_dataflow_reg,at %t.",expect_val,result_adder_dataflow_reg,$time);
        error_count = error_count +1;
    end

    if (result_adder_behavior_reg != expect_val) begin
        $display("Expect %d,but get %d on SUM_adder_behaivor_reg,at %t.",expect_val,result_adder_behavior_reg,$time);
        error_count = error_count +1;
    end

end

endmodule

//-------------------------------------------------------------------------------------------------------------------------------------------------
module rand_num (clk,MAX_num,randA,randB);
input clk;
input [31:0]MAX_num;
output reg [31:0]randA;
output reg [31:0]randB;


always @ (posedge clk) begin
    randA <=($random)%MAX_num;
    randB <=($random)%MAX_num;
    end

endmodule


module adder_structure(A,B,SUM,Cin,Cout);
input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
output Cout;
output [31:0]SUM;

genvar i;


generate
  
  for (i=0;i<=31;i=i+1) begin:gen_add
  if (i==0) begin 
    bit4str mo (.a(A[0]),   .b(B[0]),  .s(SUM[0]),   .Cin(Cin),    .Cout(C[0]));
  end
  else
  begin
      bit4str mo (.a(A[i]),.b(B[i]),.s(SUM[i]),.Cin(C[i-1]),.Cout(C[i]));
  end
  end   
endgenerate

assign Cout = C[31]; 


endmodule

module bit4str(a,b,s,Cin,Cout);

input a;
input b;
input Cin;
output s;
output Cout;
wire sf;
wire cf;
wire cf2;

xor(sf,a,b);
and(cf,a,b);
xor(s,Cin,sf);
and(cf2,Cin,sf);
or(Cout,cf,cf2);

endmodule

module adder_dataflow
      (A,B,SUM,Cin,Cout);

input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
output Cout;
output [31:0]SUM;



assign {Cout,SUM}=A+B+Cin;

endmodule

module adder_behavior
      (A,B,SUM,Cin,Cout);

input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
output reg Cout;
output reg [31:0]SUM;

always @ (A,B)
{Cout,SUM}=A+B+Cin;

endmodule

module adder_structure_reg(A,B,Cin,Cout,clk,result);
input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
output Cout;
wire [31:0]SUM;
input clk;
output reg [31:0]result;

genvar i;


generate
  
  for (i=0;i<=31;i=i+1) begin:gen_add
  if (i==0) begin 
    bit4str mo (.a(A[0]),   .b(B[0]),  .s(SUM[0]),   .Cin(Cin),    .Cout(C[0]));
  end
  else
  begin
      bit4str mo (.a(A[i]),.b(B[i]),.s(SUM[i]),.Cin(C[i-1]),.Cout(C[i]));
  end
  end   
endgenerate

assign Cout = C[31]; 

always @(negedge clk)
 result<=SUM;


endmodule

module adder_dataflow_reg 
         (A,B,Cin,Cout,clk,result);

input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
output Cout;
wire [31:0]SUM;
input clk;
output reg [31:0]result;

assign {Cout,SUM}=A+B+Cin;

always @(negedge clk)
 result<=SUM;


endmodule

module adder_behavior_reg
      (A,B,Cin,clk,result);

input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
reg Cout;
reg [31:0]SUM;
input clk;
output reg [31:0]result;

always @ (A,B)
{Cout,SUM}=A+B+Cin;

always @(negedge clk)
result = SUM;

endmodule

