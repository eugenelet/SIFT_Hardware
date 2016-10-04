module adaptiveThreshold(
  clk,
  rst_n,
  adaptiveToogle,
  adaptiveMode,
  filter_threshold,
  keypoint_num
);

parameter   HIGH_THROUGHPUT = 0,
            HIGH_ACCURACY   = 1;

input     clk,
          rst_n;

input               adaptiveToogle;
input[1:0]          adaptiveMode;
output signed[9:0]  filter_threshold;
input[10:0]         keypoint_num;

always @(posedge clk) begin
  if (!rst_n)
    filter_threshold <= 'd2;
  else if (!adaptiveToogle)
    filter_threshold <= 'd2;
  else if ((adaptiveMode==HIGH_THROUGHPUT && keypoint_num<500) || (adaptiveMode==HIGH_ACCURACY && keypoint_num<1500))
    filter_threshold <= filter_threshold - 1; 
  else if ((adaptiveMode==HIGH_THROUGHPUT && keypoint_num>1000) || (adaptiveMode==HIGH_ACCURACY && keypoint_num>2000))
    filter_threshold <= filter_threshold + 1;
end

endmodule
