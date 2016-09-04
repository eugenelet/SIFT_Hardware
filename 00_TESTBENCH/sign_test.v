module sign_test(
  input  clk,
  input  rst_n,
  input  [8:0] sign1,
  input  [8:0] sign2,
  output signed	[4:0] sign3
);

reg signed [4:0] test[0:1];
assign sign3 = test[0];

wire signed [4:0] sign_1 = {1'b0, sign1[3:0]};
wire signed [4:0] sign_2 = {1'b0, sign2[3:0]};


always @(posedge clk) begin
	if (!rst_n) 
		test[0] <= 0;
	else 
		test[0] <= sign_2 - sign_1;
end

endmodule