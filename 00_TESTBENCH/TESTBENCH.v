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

CORE u_core(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);


// reg[5119:0]  originalImage[0:479];
integer   i,j;
integer       error;
integer imageFile, rc, errorFile, blur3x3, blur5x5_1, blur5x5_2, blur7x7; // rc: read check
integer blur3x3_ans, blur5x5_1_ans, blur5x5_2_ans, blur7x7_ans; // rc: read check
integer kpt_layer1, kpt_layer2, kpt_layer1_ans, kpt_layer2_ans;
integer kp_errorFile;
integer tmp;
integer debug_0, debug_1;
integer dummy;
initial begin
  rst_n     = 1;
  in_valid  = 0;
  imageFile  = $fopen("originalImage.txt","r");

  // repeat(5) @(negedge clk);
  
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=0;j<`COLS*8;j=j+1) begin
      u_core.ori_img.mem[i][j] = 1'b1;
      // $display("test:%d", originalImage[i][j]);
    end
  end 
  // read test pattern from file
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      rc=$fscanf(imageFile,"%d",u_core.ori_img.mem[i][j*8-1-:8]);
      // $display("i:%d j:%d valuee:%d", i, j, originalImage[i][j*8-1-:8]);
    end
  end 
  $fclose(imageFile);

  repeat(3) @(negedge clk);
  rst_n     = 0;
  @(negedge clk);
  rst_n     = 1;
  in_valid  = 1;

  // repeat(1000) @(negedge clk);
  $display("test!");
  while(!u_core.gaussian_done[0]) //begin
    @(negedge clk);
    // $display("gaussian");    
  // end

  errorFile = $fopen("error.txt","w");

  blur3x3 = $fopen("blur3x3.txt","w");
  blur3x3_ans  = $fopen("blurredImgs1.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur3x3,"%d ",u_core.blur_img_0.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur3x3_ans,"%d",tmp);
      if(u_core.blur_img_0.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_0.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "3x3 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_0.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur3x3,"\n",);
  end 
  $fclose(blur3x3);
  $fclose(blur3x3_ans);
  
  blur5x5_1 = $fopen("blur5x5_1.txt","w");
  blur5x5_1_ans  = $fopen("blurredImgs2.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur5x5_1,"%d ",u_core.blur_img_1.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur5x5_1_ans,"%d",tmp);
      if(u_core.blur_img_1.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_1.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "5x5_1 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_1.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur5x5_1,"\n",);
  end 
  $fclose(blur5x5_1);
  $fclose(blur5x5_1_ans);

  blur5x5_2 = $fopen("blur5x5_2.txt","w");
  blur5x5_2_ans  = $fopen("blurredImgs3.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur5x5_2,"%d ",u_core.blur_img_2.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur5x5_2_ans,"%d",tmp);
      if(u_core.blur_img_2.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_2.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "5x5_2 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_2.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur5x5_2,"\n",);
  end 
  $fclose(blur5x5_2);
  $fclose(blur5x5_2_ans);

  blur7x7 = $fopen("blur7x7.txt","w");
  blur7x7_ans  = $fopen("blurredImgs4.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur7x7,"%d ",u_core.blur_img_3.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur7x7_ans,"%d",tmp);
      if(u_core.blur_img_3.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_3.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "7x7 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_3.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur7x7,"\n",);
  end 
  $fclose(blur7x7);
  $fclose(blur7x7_ans);
  $fclose(errorFile);

/*==========================================*/
  imageFile  = $fopen("blurredImgs1.txt","r");

 
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      rc=$fscanf(imageFile,"%d",u_core.blur_img_0.mem[i][j*8-1-:8]);
    end
  end 
  imageFile  = $fopen("blurredImgs2.txt","r");

 
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      rc=$fscanf(imageFile,"%d",u_core.blur_img_1.mem[i][j*8-1-:8]);
    end
  end 
  imageFile  = $fopen("blurredImgs3.txt","r");

 
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      rc=$fscanf(imageFile,"%d",u_core.blur_img_2.mem[i][j*8-1-:8]);
    end
  end 
  imageFile  = $fopen("blurredImgs4.txt","r");

 
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      rc=$fscanf(imageFile,"%d",u_core.blur_img_3.mem[i][j*8-1-:8]);
    end
  end 
  $fclose(imageFile);


/*===========================================*/
  errorFile = $fopen("error.txt","w");

  blur3x3 = $fopen("blur3x3.txt","w");
  blur3x3_ans  = $fopen("blurredImgs1.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur3x3,"%d ",u_core.blur_img_0.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur3x3_ans,"%d",tmp);
      if(u_core.blur_img_0.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_0.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "3x3 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_0.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur3x3,"\n",);
  end 
  $fclose(blur3x3);
  $fclose(blur3x3_ans);
  
  blur5x5_1 = $fopen("blur5x5_1.txt","w");
  blur5x5_1_ans  = $fopen("blurredImgs2.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur5x5_1,"%d ",u_core.blur_img_1.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur5x5_1_ans,"%d",tmp);
      if(u_core.blur_img_1.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_1.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "5x5_1 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_1.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur5x5_1,"\n",);
  end 
  $fclose(blur5x5_1);
  $fclose(blur5x5_1_ans);

  blur5x5_2 = $fopen("blur5x5_2.txt","w");
  blur5x5_2_ans  = $fopen("blurredImgs3.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur5x5_2,"%d ",u_core.blur_img_2.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur5x5_2_ans,"%d",tmp);
      if(u_core.blur_img_2.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_2.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "5x5_2 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_2.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur5x5_2,"\n",);
  end 
  $fclose(blur5x5_2);
  $fclose(blur5x5_2_ans);

  blur7x7 = $fopen("blur7x7.txt","w");
  blur7x7_ans  = $fopen("blurredImgs4.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur7x7,"%d ",u_core.blur_img_3.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur7x7_ans,"%d",tmp);
      if(u_core.blur_img_3.mem[i][j*8-1-:8] != tmp) begin
        error = u_core.blur_img_3.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "7x7 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_core.blur_img_3.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur7x7,"\n",);
  end 
  $fclose(blur7x7);
  $fclose(blur7x7_ans);
  $fclose(errorFile);

/*==========================================*/


  while(!u_core.detect_filter_done) begin
    @(negedge clk);
  end
  error = 0;
  kp_errorFile = $fopen("kp_error.txt", "w");
  kpt_layer1_ans = $fopen("keypoint_layer1.txt", "r");
  kpt_layer2_ans = $fopen("keypoint_layer2.txt", "r");
  kpt_layer1 = $fopen("kpt1_RTL.txt", "w");
  kpt_layer2 = $fopen("kpt2_RTL.txt", "w");
  for(i=0; i < u_core.u_detect_filter_keypoints.keypoint_1_count; i=i+1) begin
    $fwrite(kpt_layer1, "%d %d\n", u_core.keypoint_1_mem.mem[i][18:10], u_core.keypoint_1_mem.mem[i][9:0]);
    dummy = $fscanf(kpt_layer1_ans,"%d",tmp);
    error = u_core.keypoint_1_mem.mem[i][18:10] - tmp;
    dummy = $fscanf(kpt_layer1_ans,"%d",tmp);
    error = error + u_core.keypoint_1_mem.mem[i][9:0] - tmp;
    if(error!=0);
      $fwrite(kp_errorFile, "row:%d col:%d\n",u_core.keypoint_1_mem.mem[i][18:10], u_core.keypoint_1_mem.mem[i][9:0]);
    error = 0;
  end

  for(i=0; i < u_core.u_detect_filter_keypoints.keypoint_2_count; i=i+1) begin
    $fwrite(kpt_layer2, "%d %d\n", u_core.keypoint_2_mem.mem[i][18:10], u_core.keypoint_2_mem.mem[i][9:0]);
    dummy = $fscanf(kpt_layer2_ans,"%d",tmp);
    error = u_core.keypoint_2_mem.mem[i][18:10] - tmp;
    dummy = $fscanf(kpt_layer1_ans,"%d",tmp);
    error = error + u_core.keypoint_2_mem.mem[i][9:0] - tmp;
    if(error!=0);
      $fwrite(kp_errorFile, "row:%d col:%d\n",u_core.keypoint_2_mem.mem[i][18:10], u_core.keypoint_2_mem.mem[i][9:0]);
    error = 0;
  end
  $fclose(kpt_layer1);
  $fclose(kpt_layer2);
  $fclose(kp_errorFile);

/*  debug_0 = $fopen("is_kp0", "w");
  debug_1 = $fopen("is_kp1", "w");

  for(i=0; i< u_core.u_detect_filter_keypoints.dog_addr_0; i=i+1)
    $fwrite(debug_0, "%d %d\n", u_core.u_detect_filter_keypoints.dog_results_0[i][18:10], u_core.u_detect_filter_keypoints.dog_results_0[i][9:0]);

  for(i=0; i<u_core.u_detect_filter_keypoints.dog_addr_1; i=i+1)
    $fwrite(debug_1, "%d %d\n", u_core.u_detect_filter_keypoints.dog_results_1[i][18:10], u_core.u_detect_filter_keypoints.dog_results_1[i][9:0]);

  $fclose(debug_0);  
  $fclose(debug_1);*/

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