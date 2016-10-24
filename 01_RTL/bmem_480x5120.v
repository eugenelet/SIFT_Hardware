module bmem_480x5120( // dual port
  input               clk,
  input               we,
  input       [8:0]   addr1, //ceil(log 480)=9
  input       [8:0]   addr2, //ceil(log 480)=9
  input       [5119:0]  din,
  output  reg [5119:0]  dout1,
  output  reg [5119:0]  dout2
);
reg [5119:0]  mem[0:479];

always @(posedge clk) begin
  dout1 <= mem[addr1];
end

always @(posedge clk) begin
  dout2 <= mem[addr2];
end

always @(posedge clk) begin
  if(we)
    mem[addr1] <= din;
end

endmodule
