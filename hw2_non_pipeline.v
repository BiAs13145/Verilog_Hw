`timescale 1ns/1ns

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
