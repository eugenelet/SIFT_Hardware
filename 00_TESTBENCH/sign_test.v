module sign_test(
  input  clk,
  input  rst_n,
  input  signed	[9:0] sign1,
  input  signed	[9:0] sign2,
  output reg signed	[9:0] sign3
);

always @(posedge clk) begin
	if (!rst_n) 
		sign3 <= 0;
	else 
		sign3 = sign2 - sign1;
end

endmodule