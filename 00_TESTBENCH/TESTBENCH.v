`timescale 1ns/10ps



`define COLS  640
`define ROWS  480
`define CLK_PERIOD  10.0

module TESTBENCH();

/*Module FSM*/
parameter ST_IDLE       = 0,
          ST_FIRST_COL  = 1,/*Idle 1 state for SRAM to get READY*/
          ST_PRE_DETECT = 2,/*Buffers data from SRAM*/
          ST_PRE_DETECT2= 3,/*Buffers data from SRAM*/
          ST_DETECT     = 4,/*Includes switching of row*/
          ST_NO_FILTER  = 5,/*Includes switching of row*/
          ST_FILTER     = 6,/*Includes switching of row*/
          ST_NEXT_COL   = 7,/*Grants 3 cycle to update MEM addr for next column*/
          ST_BUFFER     = 8;/*Grants buffer a cycle to update*/

initial begin
  `ifdef GATE
    $sdf_annotate("CORE_syn.sdf",u_sift_proc);
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

reg             clk;
reg             rst_n;
reg             start;
wire            done;
reg             filter_on;
reg signed[9:0] filter_threshold;
reg[5119:0]     img_din;
reg             img_we;
reg[8:0]        img_addr_in;

reg             target_0_we,
                target_1_we,
                target_2_we,
                target_3_we;
reg[402:0]      target_0_din,
                target_1_din,
                target_2_din,
                target_3_din;
reg[8:0]        target_addr_in;
reg[8:0]        matched_addr2_in;
wire[48:0]      matched_0_dout,
                matched_1_dout,
                matched_2_dout,
                matched_3_dout;
reg             adaptiveToggle;
reg[1:0]        adaptiveMode;

/* Only for TB */
reg[5119:0]     ori_img_mem[0:479];
reg[402:0]      target_mem_0[0:511],
                target_mem_1[0:511],
                target_mem_2[0:511],
                target_mem_3[0:511];
reg[8:0]        target_addr_0,
                target_addr_1,
                target_addr_2,
                target_addr_3;
reg[48:0]       matched_mem_0[0:511],
                matched_mem_1[0:511],
                matched_mem_2[0:511],
                matched_mem_3[0:511];

reg[9:0]        tar_descpt_group_num;

initial clk = 0;
always #(`CLK_PERIOD/2) clk = ~clk;


SIFT_PROC u_sift_proc(
    .clk              (clk),
    .rst_n            (rst_n),
    .start            (start),
    .done             (done),
    .filter_on        (filter_on),
    .img_din          (img_din),
    .img_addr_in      (img_addr_in),
    .img_we           (img_we),
    .target_0_we      (target_0_we),
    .target_1_we      (target_1_we),
    .target_2_we      (target_2_we),
    .target_3_we      (target_3_we),
    .target_0_din     (target_0_din),
    .target_1_din     (target_1_din),
    .target_2_din     (target_2_din),
    .target_3_din     (target_3_din),
    .target_addr_in   (target_addr_in),
    .matched_addr2_in (matched_addr2_in),
    .matched_0_dout   (matched_0_dout),
    .matched_1_dout   (matched_1_dout),
    .matched_2_dout   (matched_2_dout),
    .matched_3_dout   (matched_3_dout),
    .adaptiveToggle   (adaptiveToggle),
    .adaptiveMode     (adaptiveMode),
    .tar_descpt_group_num (tar_descpt_group_num)
);


// reg[5119:0]  originalImage[0:479];
integer   i,j;
integer       error;
integer imageFile, rc, errorFile, blur3x3, blur5x5_1, blur5x5_2, blur7x7; // rc: read check
integer blur3x3_ans, blur5x5_1_ans, blur5x5_2_ans, blur7x7_ans; // rc: read check
integer kpt_layer1, kpt_layer2, kpt_layer1_ans, kpt_layer2_ans;
integer kpt_total, kpt_total_ans;
integer kp_errorFile;
integer tmp;
integer debug_0, debug_1;
integer dummy;
integer error1, error2, error3;
integer ans1, ans2, ans3;
integer targetFile;
integer targetKptNum;
integer temp;
integer cycleCount, detectCount, filterCount, kp_count;
integer match;
integer matched_pairs, match_result;
initial begin
  rst_n             = 1;
  start             = 0;
  imageFile         = $fopen("originalImage.txt","r");
  filter_on         = 1; /*Turns filter on*/
  adaptiveMode      = 0; /*HIGH_THROUGHPUT*/
  adaptiveToggle    = 0; /*Adaptive Mode OFF*/

  /* Write Image SRAM*/
  img_addr_in = 0;
  img_we = 1;
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      rc=$fscanf(imageFile,"%d",ori_img_mem[i][j*8-1-:8]);
    end
    img_din = ori_img_mem[i];
    @(negedge clk);
    img_addr_in = img_addr_in + 1;
  end 
  img_we = 0;
  $fclose(imageFile);

  /* Write Target SRAM */
  targetFile = $fopen("targetRowColDespt.txt", "r");
  rc = $fscanf(targetFile, "%d", targetKptNum);

  /*Initialize number of target desc. group*/
  tar_descpt_group_num = targetKptNum/4;


  target_0_we = 0;
  target_1_we = 0;
  target_2_we = 0;
  target_3_we = 0;
  target_addr_in = 0;
  target_addr_0 = 0;
  target_addr_1 = 0;
  target_addr_2 = 0;
  target_addr_3 = 0;
    for(i = 0; i < targetKptNum; i = i + 1) begin
      temp = i & 2'b11;
      if(temp[1:0] == 2'b00) begin
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][402:394]);//row
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][393:384]);//col
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][383:372]);//32th dim
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][371:360]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][359:348]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][347:336]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][335:324]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][323:312]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][311:300]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][299:288]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][287:276]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][275:264]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][263:252]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][251:240]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][239:228]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][227:216]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][215:204]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][203:192]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][191:180]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][179:168]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][167:156]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][155:144]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][143:132]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][131:120]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][119:108]);
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][107:96] );  
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][95:84]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][83:72]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][71:60]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][59:48]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][47:36]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][35:24]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][23:12]  );    
          rc = $fscanf(targetFile, "%d", target_mem_0[i / 4][11:0]   );//1st dim
          target_0_din = target_mem_0[i / 4];
          target_0_we = 1;
          target_addr_in = target_addr_0;
          @(negedge clk);
          target_0_we = 0;
          target_addr_0 = target_addr_0 + 1;
      end
      else if(temp[1:0] == 2'b01) begin
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][402:394]);//row
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][393:384]);//col
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][383:372]);//32th dim
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][371:360]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][359:348]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][347:336]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][335:324]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][323:312]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][311:300]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][299:288]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][287:276]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][275:264]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][263:252]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][251:240]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][239:228]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][227:216]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][215:204]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][203:192]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][191:180]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][179:168]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][167:156]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][155:144]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][143:132]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][131:120]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][119:108]);
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][107:96] );  
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][95:84]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][83:72]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][71:60]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][59:48]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][47:36]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][35:24]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][23:12]  );    
          rc = $fscanf(targetFile, "%d", target_mem_1[i / 4][11:0]   );//1st dim
          target_1_din = target_mem_1[i / 4];
          target_1_we = 1;
          target_addr_in = target_addr_1;
          @(negedge clk);
          target_1_we = 0;
          target_addr_1 = target_addr_1 + 1;
      end
      else if(temp[1:0] == 2'b10) begin
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][402:394]);//row
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][393:384]);//col
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][383:372]);//32th dim
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][371:360]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][359:348]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][347:336]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][335:324]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][323:312]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][311:300]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][299:288]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][287:276]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][275:264]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][263:252]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][251:240]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][239:228]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][227:216]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][215:204]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][203:192]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][191:180]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][179:168]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][167:156]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][155:144]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][143:132]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][131:120]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][119:108]);
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][107:96] );  
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][95:84]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][83:72]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][71:60]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][59:48]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][47:36]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][35:24]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][23:12]  );    
          rc = $fscanf(targetFile, "%d", target_mem_2[i / 4][11:0]   );//1st dim
          target_2_din = target_mem_2[i / 4];
          target_2_we = 1;
          target_addr_in = target_addr_2;
          @(negedge clk);
          target_2_we = 0;
          target_addr_2 = target_addr_2 + 1;
      end
      else begin
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][402:394]);//row
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][393:384]);//col
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][383:372]);//32th dim
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][371:360]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][359:348]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][347:336]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][335:324]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][323:312]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][311:300]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][299:288]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][287:276]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][275:264]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][263:252]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][251:240]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][239:228]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][227:216]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][215:204]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][203:192]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][191:180]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][179:168]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][167:156]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][155:144]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][143:132]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][131:120]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][119:108]);
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][107:96] );  
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][95:84]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][83:72]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][71:60]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][59:48]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][47:36]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][35:24]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][23:12]  );    
          rc = $fscanf(targetFile, "%d", target_mem_3[i / 4][11:0]   );//1st dim
          target_3_din = target_mem_3[i / 4];
          target_3_we = 1;
          target_addr_in = target_addr_3;
          @(negedge clk);
          target_3_we = 0;
          target_addr_3 = target_addr_3 + 1;
      end
  end
  $fclose(targetFile);

  /* Initialize and start CORE */
  repeat(3) @(negedge clk);
  rst_n     = 0;
  @(negedge clk);
  rst_n     = 1;
  start  = 1;

  /* Compute cycle count for Gaussian*/
  cycleCount = 0;
  while(!u_sift_proc.gaussian_done[0]) begin
    @(negedge clk);
    cycleCount = cycleCount + 1;
  end
  $display("========= Gaussian DONE =========");
  $display("Gaussian Cycle:%d Cycles", cycleCount);

  /* Generate Error Log for Gaussian */
  errorFile = $fopen("error.txt","w");
  blur3x3 = $fopen("blur3x3.txt","w");
  blur3x3_ans  = $fopen("blurredImgs1.txt","r");
  for(i=0;i<`ROWS;i=i+1) begin
    for(j=1;j<=`COLS;j=j+1) begin
      $fwrite(blur3x3,"%d ",u_sift_proc.blur_img_0.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur3x3_ans,"%d",tmp);
      if(u_sift_proc.blur_img_0.mem[i][j*8-1-:8] != tmp) begin
        error = u_sift_proc.blur_img_0.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "3x3 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_sift_proc.blur_img_0.mem[i][j*8-1-:8], tmp, error);
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
      $fwrite(blur5x5_1,"%d ",u_sift_proc.blur_img_1.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur5x5_1_ans,"%d",tmp);
      if(u_sift_proc.blur_img_1.mem[i][j*8-1-:8] != tmp) begin
        error = u_sift_proc.blur_img_1.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "5x5_1 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_sift_proc.blur_img_1.mem[i][j*8-1-:8], tmp, error);
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
      $fwrite(blur5x5_2,"%d ",u_sift_proc.blur_img_2.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur5x5_2_ans,"%d",tmp);
      if(u_sift_proc.blur_img_2.mem[i][j*8-1-:8] != tmp) begin
        error = u_sift_proc.blur_img_2.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "5x5_2 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_sift_proc.blur_img_2.mem[i][j*8-1-:8], tmp, error);
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
      $fwrite(blur7x7,"%d ",u_sift_proc.blur_img_3.mem[i][j*8-1-:8]);
      dummy = $fscanf(blur7x7_ans,"%d",tmp);
      if(u_sift_proc.blur_img_3.mem[i][j*8-1-:8] != tmp) begin
        error = u_sift_proc.blur_img_3.mem[i][j*8-1-:8] - tmp;
        $fwrite(errorFile, "7x7 i:%d j:%d wrong value:%d correct value:%d error:%d\n", i, j, u_sift_proc.blur_img_3.mem[i][j*8-1-:8], tmp, error);
      end
    end
    $fwrite(blur7x7,"\n",);
  end 
  $fclose(blur7x7);
  $fclose(blur7x7_ans);
  $fclose(errorFile);


  /* DETECT AND FILTER 
   * - Compute Cycle Count
   */
  cycleCount = 0;
  filterCount = 0;
  detectCount = 0;
  kp_count = 0;
  while(!u_sift_proc.detect_filter_done) begin
    @(negedge clk);
    cycleCount = cycleCount + 1;
    if(u_sift_proc.u_detect_filter_keypoints.current_state == ST_FILTER)
      filterCount = filterCount + 1;
    if(u_sift_proc.u_detect_filter_keypoints.current_state == ST_DETECT)
      detectCount = detectCount + 1;
    if(u_sift_proc.u_detect_filter_keypoints.current_state==ST_FILTER)
      kp_count = kp_count + 1;
  end

  $display("========= Detect & Filter DONE =========");
  $display("Detect and Filter:%d Cycles", cycleCount);
  $display("Detect Cycle : %d", detectCount);
  $display("Filter Cycle : %d", filterCount);
  
  /* Error Log for Detect and Filter*/
  error1 = 0;
  error2 = 0;
  kp_errorFile = $fopen("kp_error.txt", "w");
  kpt_total_ans = $fopen("keypoint.txt", "r");
  kpt_total = $fopen("kpt_RTL.txt", "w");
  for(i=0; i < u_sift_proc.u_detect_filter_keypoints.keypoint_addr; i=i+1) 
    $fwrite(kpt_total, "%d %d %d\n", u_sift_proc.keypoint_mem.mem[i][19], u_sift_proc.keypoint_mem.mem[i][18:10], u_sift_proc.keypoint_mem.mem[i][9:0]);

  while (!$feof(kpt_total_ans)) begin
    dummy = $fscanf(kpt_total_ans,"%d",ans1);
    dummy = $fscanf(kpt_total_ans,"%d",ans2);
    dummy = $fscanf(kpt_total_ans,"%d",ans3);
    for(i=0; i < u_sift_proc.u_detect_filter_keypoints.keypoint_addr; i=i+1) 
      if (u_sift_proc.keypoint_mem.mem[i][19]==ans1 && u_sift_proc.keypoint_mem.mem[i][18:10]==ans2 && u_sift_proc.keypoint_mem.mem[i][9:0]==ans3)
        match = 1;
    if (match == 1)
      match = 0;
    else 
      $fwrite(kp_errorFile, "layer:%d row:%d col:%d \n", ans1, ans2, ans3);
  end

  $fclose(kpt_total);
  $fclose(kpt_total_ans);
  $fclose(kp_errorFile);



  cycleCount = 0;
  while(!u_sift_proc.compute_match_done) begin
      // $display("kpt_addr : %d", u_sift_proc.kpt_addr);
      @(negedge clk);
      cycleCount = cycleCount + 1;
  end
  $display("========= Compute and Match DONE =========");
  $display("Compute and Match:%d Cycles", cycleCount);
  $display("%d", targetKptNum);

  /*Dump Output and check answer*/   
  @(negedge clk);
  matched_pairs = $fopen("matched_pairs.txt", "w");
  matched_addr2_in = 0;
  @(negedge clk);
  for(i = 0; i < targetKptNum; i = i + 1) begin
    temp = i & 2'b11;
    if(temp[1:0] == 2'b00) begin
       matched_mem_0[i / 4] = matched_0_dout;
       $fwrite(matched_pairs, "0 %d %d\n", matched_mem_0[i / 4][48:40], matched_mem_0[i / 4][39:30]);
    end
    else if(temp[1:0] == 2'b01) begin
       matched_mem_1[i / 4] = matched_1_dout;
       $fwrite(matched_pairs, "1 %d %d\n", matched_mem_1[i / 4][48:40], matched_mem_1[i / 4][39:30]);
    end
    else if(temp[1:0] == 2'b10) begin
       matched_mem_2[i / 4] = matched_2_dout;
       $fwrite(matched_pairs, "2 %d %d\n", matched_mem_2[i / 4][48:40], matched_mem_2[i / 4][39:30]);
    end
    else begin
       matched_mem_3[i / 4] = matched_3_dout;
       $fwrite(matched_pairs, "3 %d %d\n", matched_mem_3[i / 4][48:40], matched_mem_3[i / 4][39:30]);
       matched_addr2_in = matched_addr2_in + 1;
       @(negedge clk);
    end
  end

  $fclose(matched_pairs);

  match_result = $fopen("match_result.txt", "w");
  for(i = 0; i < targetKptNum; i = i + 1) begin
      temp = i & 2'b11;
      if(temp[1:0] == 2'b00) begin
           if(matched_mem_0[i / 4][29:15] < matched_mem_0[i / 4][14:0] * 0.72) begin//dist < dist2
              $fwrite(match_result, "%d %d %d %d\n", target_mem_0[i / 4][402:394], target_mem_0[i / 4][393:384], matched_mem_0[i / 4][48:40], matched_mem_0[i / 4][39:30]);
          end
      end
      else if(temp[1:0] == 2'b01) begin
          if(matched_mem_1[i / 4][29:15] < matched_mem_1[i / 4][14:0] * 0.72) begin//dist < dist2
              $fwrite(match_result, "%d %d %d %d\n", target_mem_1[i / 4][402:394], target_mem_1[i / 4][393:384], matched_mem_1[i / 4][48:40], matched_mem_1[i / 4][39:30]);
          end
      end
      else if(temp[1:0] == 2'b10) begin
          if(matched_mem_2[i / 4][29:15] < matched_mem_2[i / 4][14:0] * 0.72) begin//dist < dist2
              $fwrite(match_result, "%d %d %d %d\n", target_mem_2[i / 4][402:394], target_mem_2[i / 4][393:384], matched_mem_2[i / 4][48:40], matched_mem_2[i / 4][39:30]);
          end
      end
      else begin
          if(matched_mem_3[i / 4][29:15] < matched_mem_3[i / 4][14:0] * 0.72) begin//dist < dist2
              $fwrite(match_result, "%d %d %d %d\n", target_mem_3[i / 4][402:394], target_mem_3[i / 4][393:384], matched_mem_3[i / 4][48:40], matched_mem_3[i / 4][39:30]);
          end
      end    
  end
  $fclose(match_result);
  $finish;
end


endmodule 