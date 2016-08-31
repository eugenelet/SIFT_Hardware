`ifdef RTL
  `define CLK_PERIOD  10.0
`endif

`ifdef GATE
  `define CLK_PERIOD  15.0
`endif

`ifdef POST
  `define CLK_PERIOD  15.0
`endif

`define MAX_LATENCY 50000000
`define CONF_K      4
`define CONF_N      4096

module PATTERN_mem(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);
output reg          clk;
output reg          rst_n;
output reg          in_valid;
output reg  [15:0]  in_data;
input               out_valid;
input       [15:0]  out_data;

initial clk = 0;
always #(`CLK_PERIOD/2) clk = ~clk;

initial begin
  rst_n = 1;
  repeat(3) @(negedge clk);
  rst_n = 0;
  @(negedge clk);
  rst_n = 1;
end

integer file, rc; // rc: read check
initial begin
  `ifdef P1   file  = $fopen("p1.txt","r");   `endif
  `ifdef P2   file  = $fopen("p2.txt","r");   `endif
  `ifdef P3   file  = $fopen("p3.txt","r");   `endif
end

integer counter;
initial begin
  for(counter=0;counter<`MAX_LATENCY;counter=counter+1)
    @(negedge clk);
  
  $display("");
  $display("FAIL: simulation time over %d cycles!!",`MAX_LATENCY);
  $display("");
  $finish;
end

initial begin
  
  in_valid  = 0;
  in_data   = 0;

  @(negedge clk)
  in_valid  = 1;
  in_data   = 'd1024;
  @(negedge clk)
  in_data   = 'd512;
  @(negedge clk)
  in_valid  = 0;
  in_data   = 0;
  // ****************************************************************************************************
  
  // wait out_valid signal
  wait(out_valid==='d1) @(negedge clk);
  // check out_data
  error = 0;
  for(i=0;i<2;i=i+1) begin
    if(out_valid!=='d1) begin
      $display("");
      $display("FAIL @%1d: out_valid should be 1",i);
      $display("");
      error = 1;
    end
    if(out_data!==(1024/i)) begin
      $display("");
      $display("FAIL %4d", 1024/i);
      $display("");
      error = 1;
    end
    @(negedge clk);
  end
  if(out_valid==='d1) begin
    $display("");
    $display("FAIL : out_valid should be 0",);
    $display("");
    error = 1;
  end
  
  repeat(3) @(negedge clk);
  $display("");
  if(error)
    $display("FAIL... > <");
  else
    $display("congratulation & you pass MEM TEST !!");
  $display("");
  
  $finish;
end

endmodule 
