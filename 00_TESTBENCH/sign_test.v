module sign_test(
  input  clk,
  input  rst_n,
  input  [8:0] sign1,
  input  [8:0] sign2,
  output reg signed	[9:0] sign3
);

wire signed [4:0] sign_1 = {1'b0, sign1[3:0]};
wire signed [4:0] sign_2 = {1'b0, sign2[3:0]};


always @(posedge clk) begin
	if (!rst_n) 
		sign3[4:0] <= 0;
	else 
		sign3[4:0] <= sign_2 - sign_1;
end

endmodule