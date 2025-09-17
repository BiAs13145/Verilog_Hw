module fulladder4bh
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

module testBench_fulladder4bh();

reg [31:0] A , B;
reg Cin;
output [31:0]S;
output Cout;

fulladder4bh U(
.A(A),
.B(B),
.SUM(S),
.Cin(Cin),
.Cout(Cout)
);

initial begin
A = 16;
B = 11;
Cin = 0;
#10 A = 25;
#10 Cin = 0;
#10 B = 12;
#20 A = 3;
#30 Cin = 0;
#40 B = 3;
#50 Cin = 0;
end

/*initial 
begin
$monitor($time,,,"part:%b %b", S, Cout);
#70
$finish;
end*/
/*iverilog */
initial
begin
$dumpfile("wave_fulladder4bh.vcd"); //生成的vcd文件名称
$dumpvars(0, testBench_fulladder4bh); //tb模块名称
end
/*iverilog */

endmodule