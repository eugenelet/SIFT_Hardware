module bmem_2000x19(
  input               clk,
  input               we,
  input       [10:0]   addr, //ceil(log 480)=9
  input       [18:0]  din,
  output  reg [18:0]  dout
);
reg [18:0]  mem[0:1999];

always @(posedge clk) begin
  dout <= mem[addr];
end

always @(posedge clk) begin
  if(we)
    mem[addr] <= din;
end

endmodule