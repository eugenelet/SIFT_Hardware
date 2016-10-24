module bmem_480x5120(
  input               clk,
  input               we,
  input       [8:0]   addr, //ceil(log 480)=9
  input       [5119:0]  din,
  output  reg [5119:0]  dout
);
reg [5119:0]  mem[0:479];

always @(posedge clk) begin
  dout <= mem[addr];
end

always @(posedge clk) begin
  if(we)
    mem[addr] <= din;
end

endmodule

