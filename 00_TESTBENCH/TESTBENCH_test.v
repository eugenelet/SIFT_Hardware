`timescale 1ns/10ps



`define COLS  640
`define ROWS  480
`define CLK_PERIOD  10.0

module TESTBENCH();
initial begin
  `ifdef GATE
    $sdf_annotate("CORE_syn.sdf",u_core);
  `endif
  `ifdef POST
    $sdf_annotate("CHIP.sdf",u_chip);
  `endif
  
  `ifdef FSDB
    $fsdbDumpfile("CHIP.fsdb");
    $fsdbDumpvars;
  `endif  
  `ifdef VCD
    $dumpfile("CHIP.vcd");
    $dumpvars;
  `endif
end

reg           clk;
reg           rst_n;
reg           in_valid;
wire  [15:0]  in_data;
wire          out_valid;
wire  [15:0]  out_data;

reg [8:0] test1, test2
reg signed [9:0] test3;

module sign_test(
  .sign1    (test1),
  .sign2    (test2),
  .sign3    (test3)
);


initial clk = 0;
always #(`CLK_PERIOD/2) clk = ~clk;

/*initial begin
  rst_n = 1;
  repeat(3) @(negedge clk);
  rst_n = 0;
  @(negedge clk);
  rst_n = 1;
end*/

/*integer counter;
initial begin
  for(counter=0;counter<`MAX_LATENCY;counter=counter+1)
    @(negedge clk);
  
  $display("");
  $display("FAIL: simulation time over %d cycles!!",`MAX_LATENCY);
  $display("");
  $finish;
end*/


// reg[5119:0]  originalImage[0:479];
integer   i,j;
integer       error;
integer imageFile, rc, errorFile, blur3x3, blur5x5_1, blur5x5_2, blur7x7; // rc: read check
integer blur3x3_ans, blur5x5_1_ans, blur5x5_2_ans, blur7x7_ans; // rc: read check
integer kpt_layer1, kpt_layer2, kpt_layer1_ans, kpt_layer2_ans;
integer tmp;
initial begin
  rst_n     = 1;
  in_valid  = 0;
  test1 = 5;
  test2 = 6;
  $display(test3);
  test1 = 6;
  test2 = 5;
  $display(test3);


  $finish;
end




/*
`ifdef RTL
CORE u_core(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);
`endif
`ifdef GATE
CORE u_core(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);
`endif
`ifdef POST
CHIP u_chip(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);
`endif*/
endmodule 