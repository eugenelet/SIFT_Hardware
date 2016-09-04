module sign_test(
  input  signed	[9:0] sign1,
  input  signed	[9:0] sign2,
  output signed	[9:0] sign3
);

assign sign3 = sign2 - sign1;

endmodule