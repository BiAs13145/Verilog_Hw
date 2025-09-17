module fulladder4str(A,B,SUM,Cin,Cout);
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

/*initial 
begin
$monitor($time,,,"part:%b %b", S, Cout);
#70
$finish;
end*/
/*iverilog */
initial
begin
$dumpfile("wave_fulladder4str.vcd");
$dumpvars(0, testBench_fulladder4str); 
end
/*iverilog */

endmodule


/*module full_add(a,b,cin,sum,cout);
  input a,b,cin;
  output sum,cout;
  wire x,y,z;
 
// instantiate building blocks of full adder 
  half_add h1(.a(a),.b(b),.s(x),.c(y));
  half_add h2(.a(x),.b(cin),.s(sum),.c(z));
  or o1(cout,y,z);
endmodule 

// code your half adder design             
module half_add(a,b,s,c); 
  input a,b;
  output s,c;
 
// gate level design of half adder  
  xor x1(s,a,b);
  and a1(c,a,b);
endmodule */


