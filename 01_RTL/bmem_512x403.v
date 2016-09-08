module bmem_512x403(
  input               clk,
  input               we,
  input       [8:0]   addr, //ceil(log 480)=9
  input       [402:0]  din,
  output  reg [402:0]  dout
);
reg [402:0]  mem[0:511];

always @(posedge clk) begin
  dout <= mem[addr];
end

always @(posedge clk) begin
  if(we)
    mem[addr] <= din;
end

endmodule