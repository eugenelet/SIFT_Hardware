module bmem_2048x20(
  input               clk,
  input               we,
  input       [10:0]   addr, //ceil(log 2000)=11
  input       [19:0]  din,
  output  reg [19:0]  dout
);
reg [19:0]  mem[0:2047];

always @(posedge clk) begin
  dout <= mem[addr];
end

always @(posedge clk) begin
  if(we)
    mem[addr] <= din;
end

endmodule