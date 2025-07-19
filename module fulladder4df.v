module fulladder4df
      (A,B,SUM,Cin,Cout);

input [31:0]A;
input [31:0]B;
wire [31:0]C;
input Cin;
output Cout;
output [31:0]SUM;

assign {Cout,SUM}=A+B+Cin;



endmodule





module testBench_fulladder4str();

reg [31:0] A , B;
reg Cin;
output [31:0]S;
output Cout;

fulladder4str U(
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

initial
begin
$dumpfile("wave_fulladder4str.vcd");
$dumpvars(0, testBench_fulladder4str);
end
/*iverilog */

endmodule