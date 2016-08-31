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

module PATTERN(
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

reg [7:0] p_pre_x[0:3];
reg [7:0] p_pre_y[0:3];
reg [7:0] p_cur_x[0:3];
reg [7:0] p_cur_y[0:3];
integer   data_num[0:3];
integer   p_new_x[0:3];
integer   p_new_y[0:3];
reg [7:0] data_x[0:4095];
reg [7:0] data_y[0:4095];
integer   i,j;
integer   min_idx,min_dis,dis;
reg       error;
initial begin
  in_valid  = 0;
  in_data   = 0;
  
  for(i=0;i<`CONF_K;i=i+1) begin
    p_pre_x[i]  = 0;
    p_pre_y[i]  = 0;
    p_cur_x[i]  = 0;
    p_cur_y[i]  = 0;
  end
  repeat(5) @(negedge clk);
  
  // read test pattern from file
  for(i=0;i<`CONF_K;i=i+1) rc=$fscanf(file,"%d %d",p_cur_x[i],p_cur_y[i]);
  for(i=0;i<`CONF_N;i=i+1) rc=$fscanf(file,"%d %d",data_x[i],data_y[i]);
  
  // enter input data (initial point x4 & sample data x 4096)
  for(i=0;i<`CONF_K;i=i+1) begin
    @(negedge clk);
    in_valid  = 1;
    in_data   = {p_cur_x[i],p_cur_y[i]};
  end
  for(i=0;i<`CONF_N;i=i+1) begin
    @(negedge clk);
    in_valid  = 1;
    in_data   = {data_x[i],data_y[i]};
  end
  @(negedge clk);
  in_valid    = 0;
  in_data     = 0;
  
  // ****************************************************************************************************
  // calculate the golden ans of K-means
  while(  /********** check() **********/
          p_pre_x[0]!=p_cur_x[0] || p_pre_y[0]!=p_cur_y[0] ||
          p_pre_x[1]!=p_cur_x[1] || p_pre_y[1]!=p_cur_y[1] ||
          p_pre_x[2]!=p_cur_x[2] || p_pre_y[2]!=p_cur_y[2] ||
          p_pre_x[3]!=p_cur_x[3] || p_pre_y[3]!=p_cur_y[3]
          /********** end of check() **********/
        ) begin
        
    // clean variables
    for(i=0;i<`CONF_K;i=i+1) begin
      data_num[i] = 0;
      p_new_x[i]  = 0;
      p_new_y[i]  = 0;
    end
    
    /********** CalculateNewCentroid() **********/
    // the major process for K-means
    for(i=0;i<`CONF_N;i=i+1) begin
      for(j=0;j<`CONF_K;j=j+1) begin
        // dis = |cur_x[j]-data_x[i]| + |cur_y[j]-data_y[i]|
        if(p_cur_x[j]>data_x[i])  dis = p_cur_x[j]-data_x[i];
        else                      dis = data_x[i]-p_cur_x[j];
        if(p_cur_y[j]>data_y[i])  dis = dis+(p_cur_y[j]-data_y[i]);
        else                      dis = dis+(data_y[i]-p_cur_y[j]);
        // update the nearest cluster index & distance
        if(j==0 || dis<min_dis) begin
          min_idx = j;
          min_dis = dis;
        end
      end
      data_num[min_idx] = data_num[min_idx]+1;
      p_new_x[min_idx]  = p_new_x[min_idx]+data_x[i];
      p_new_y[min_idx]  = p_new_y[min_idx]+data_y[i];
    end
    /********** end of CalculateNewCentroid() **********/
    
    /********** UpdateCurCentroid() **********/
    for(i=0;i<`CONF_K;i=i+1) begin
      p_pre_x[i]  = p_cur_x[i];
      p_pre_y[i]  = p_cur_y[i];
      if(data_num[i]>0) begin
        p_cur_x[i]  = p_new_x[i]/data_num[i];
        p_cur_y[i]  = p_new_y[i]/data_num[i];
      end
    end
    /********** end of UpdateCurCentroid() **********/
  end
  // ****************************************************************************************************
  
  // wait out_valid signal
  wait(out_valid==='d1) @(negedge clk);
  // check out_data
  error = 0;
  for(i=0;i<`CONF_K;i=i+1) begin
    if(out_valid!=='d1) begin
      $display("");
      $display("FAIL @%1d: out_valid should be 1",i);
      $display("");
      error = 1;
    end
    if(out_data[15:8]!==p_cur_x[i] || out_data[7:0]!==p_cur_y[i]) begin
      $display("");
      $display("FAIL @%1d: user ans=(%3d,%3d), golden ans=(%3d,%3d)",i,out_data[15:8],out_data[7:0],p_cur_x[i],p_cur_y[i]);
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
    $display("congratulation & you pass the final project !!");
  $display("");
  
  $finish;
end

endmodule 
