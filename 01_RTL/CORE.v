`timescale 1ns/10ps
module CORE(
    clk,
    rst_n,
    start,
    filter_on,
    filter_threshold
);
    input           clk;
    input           rst_n;
    input           start;
    input           filter_on;
    input signed[9:0]      filter_threshold;

    /*FSM*/
    reg         [2:0] current_state,
                      next_state;

    /*System State*/
    parameter         ST_IDLE          = 0,
                      ST_GAUSSIAN      = 1,
                      ST_DETECT_FILTER = 2,
                      ST_COMPUTE_MATCH = 3,
                      ST_END           = 4; //FOR DEBUG




    reg     [8:0]     img_addr; /*wire*/
    reg     [5119:0]  img_din;
    wire    [5119:0]  img_dout;
    /*SRAM for Original Image*/
    bmem_480x5120 ori_img(
      .clk  (clk),
      .we   (1'b0),
      .addr (img_addr),
      .din  (img_din),
      .dout (img_dout)
    );


    wire  [3:0]    blur_mem_we;
    reg   [8:0]    blur_addr  [0:3]; /*wire*/
    wire  [5119:0] blur_din   [0:3];
    wire  [5119:0] blur_dout  [0:3];
    /*SRAM for Blurred Images(4)*/
    bmem_480x5120 blur_img_0(
      .clk  (clk),
      .we   (blur_mem_we[0]),
      .addr (blur_addr[0]),
      .din  (blur_din[0]),
      .dout (blur_dout[0])
    );
    bmem_480x5120 blur_img_1(
      .clk  (clk),
      .we   (blur_mem_we[1]),
      .addr (blur_addr[1]),
      .din  (blur_din[1]),
      .dout (blur_dout[1])
    );
    bmem_480x5120 blur_img_2(
      .clk  (clk),
      .we   (blur_mem_we[2]),
      .addr (blur_addr[2]),
      .din  (blur_din[2]),
      .dout (blur_dout[2])
    );
    bmem_480x5120 blur_img_3(
      .clk  (clk),
      .we   (blur_mem_we[3]),
      .addr (blur_addr[3]),
      .din  (blur_din[3]),
      .dout (blur_dout[3])
    );

    /*SRAM for KeyPoints*/
    wire          keypoint_we;
    reg   [10:0]  keypoint_addr;
    wire  [19:0]  keypoint_din;
    wire  [19:0]  keypoint_dout;
    bmem_2048x20 keypoint_mem(
      .clk  (clk),
      .we   (keypoint_we),
      .addr (keypoint_addr),
      .din  (keypoint_din),
      .dout (keypoint_dout)
    );

/*    wire          keypoint_2_we;
    reg   [10:0]  keypoint_2_addr;
    wire  [18:0]  keypoint_2_din;
    wire  [18:0]  keypoint_2_dout;
    bmem_2048x19 keypoint_2_mem(
      .clk  (clk),
      .we   (keypoint_2_we),
      .addr (keypoint_2_addr),
      .din  (keypoint_2_din),
      .dout (keypoint_2_dout)
    );*/
    
    /*SRAM for Target*/
    wire  [8:0]    target_addr;//shared
    wire           target_0_we;
    wire  [402:0]  target_0_din;
    wire  [402:0]  target_0_dout;
    bmem_512x403 target_0_mem(
      .clk  (clk),
      .we   (target_0_we),
      .addr (target_addr),
      .din  (target_0_din),
      .dout (target_0_dout)
    );

    wire           target_1_we;
    wire  [402:0]  target_1_din;
    wire  [402:0]  target_1_dout;
    bmem_512x403 target_1_mem(
      .clk  (clk),
      .we   (target_1_we),
      .addr (target_addr),
      .din  (target_1_din),
      .dout (target_1_dout)
    );

    wire           target_2_we;
    wire  [402:0]  target_2_din;
    wire  [402:0]  target_2_dout;
    bmem_512x403 target_2_mem(
      .clk  (clk),
      .we   (target_2_we),
      .addr (target_addr),
      .din  (target_2_din),
      .dout (target_2_dout)
    );

    wire           target_3_we;
    wire  [402:0]  target_3_din;
    wire  [402:0]  target_3_dout;
    bmem_512x403 target_3_mem(
      .clk  (clk),
      .we   (target_3_we),
      .addr (target_addr),
      .din  (target_3_din),
      .dout (target_3_dout)
    );
    
    /*SRAM for Matched*/
    wire  [8:0]  matched_addr1, matched_addr2;//shared
    wire  [3:0]   matched_we;//write din to addr1
    
    wire  [46:0]  matched_0_din;
    wire  [46:0]  matched_0_dout;
    bmem_512x47 matched_0_mem(
      .clk  (clk),
      .we   (matched_we[0]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_0_din),
      .dout1(),
      .dout2(matched_0_dout)
    );

    wire  [46:0]  matched_1_din;
    wire  [46:0]  matched_1_dout;
    bmem_512x47 matched_1_mem(
      .clk  (clk),
      .we   (matched_we[1]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_1_din),
      .dout1(),
      .dout2(matched_1_dout)
    );
    
    wire  [46:0]  matched_2_din;
    wire  [46:0]  matched_2_dout;
    bmem_512x47 matched_2_mem(
      .clk  (clk),
      .we   (matched_we[2]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_2_din),
      .dout1(),
      .dout2(matched_2_dout)
    );
    
    wire  [46:0]  matched_3_din;
    wire  [46:0]  matched_3_dout;
    bmem_512x47 matched_3_mem(
      .clk  (clk),
      .we   (matched_we[3]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_3_din),
      .dout1(),
      .dout2(matched_3_dout)
    );

    /*Line Buffer*/    
    wire    [5119:0]  buffer_data_0;
    wire    [5119:0]  buffer_data_1;
    wire    [5119:0]  buffer_data_2;
    wire    [5119:0]  buffer_data_3;
    wire    [5119:0]  buffer_data_4;
    wire    [5119:0]  buffer_data_5;
    wire    [5119:0]  buffer_data_6;
    wire    [5119:0]  buffer_data_7;
    wire    [5119:0]  buffer_data_8;
    wire    [5119:0]  buffer_data_9;
    reg               buffer_we; /*wire*/
    reg               fill_zero;  /*wire*/
    reg     [5119:0]  buffer_in;
    wire              buffer_mode = (current_state==ST_DETECT_FILTER) ? 1 : 0;
    // wire              buffer_mode = (gaussian_done)?L_IDLE:L_GAUSSIAN;
    /*System Line Buffer*/
    Line_Buffer_10 l_buf_10(
      .clk            (clk),
      .rst_n          (rst_n),
      .buffer_mode    (buffer_mode),
      .buffer_we      (buffer_we),
      .fill_zero      (fill_zero),
      .in_data0       (buffer_in),
      .in_data1       (blur_dout[0]),
      .in_data2       (blur_dout[1]),
      .in_data3       (blur_dout[2]),
      .in_data4       (blur_dout[3]),
      .buffer_data_0  (buffer_data_0),
      .buffer_data_1  (buffer_data_1),
      .buffer_data_2  (buffer_data_2),
      .buffer_data_3  (buffer_data_3),
      .buffer_data_4  (buffer_data_4),
      .buffer_data_5  (buffer_data_5),
      .buffer_data_6  (buffer_data_6),
      .buffer_data_7  (buffer_data_7),
      .buffer_data_8  (buffer_data_8),
      .buffer_data_9  (buffer_data_9)
    );

    wire           gaussian_start = (current_state==ST_GAUSSIAN)?1:0;
    wire  [8:0]    gaussian_blur_addr  [0:3];
    wire  [8:0]    gaussian_img_addr;
    wire  [3:0]    gaussian_done;
    wire           gaussian_buffer_we;
    wire  [3:0]    gaussian_fill_zero;
    Gaussian_Blur g_blur(
      .clk            (clk),
      .rst_n          (rst_n),
      .img_dout       (img_dout),
      .buffer_data_0  (buffer_data_0),
      .buffer_data_1  (buffer_data_1),
      .buffer_data_2  (buffer_data_2),
      .buffer_data_3  (buffer_data_3),
      .buffer_data_4  (buffer_data_4),
      .buffer_data_5  (buffer_data_5),
      .start          (gaussian_start),
      .done           (gaussian_done[0]),
      .blur_mem_we_0  (blur_mem_we[0]),
      .blur_mem_we_1  (blur_mem_we[1]),
      .blur_mem_we_2  (blur_mem_we[2]),
      .blur_mem_we_3  (blur_mem_we[3]),
      .blur_addr_0    (gaussian_blur_addr[0]),
      .blur_addr_1    (gaussian_blur_addr[1]),
      .blur_addr_2    (gaussian_blur_addr[2]),
      .blur_addr_3    (gaussian_blur_addr[3]),
      .blur_din_0     (blur_din[0]),
      .blur_din_1     (blur_din[1]),
      .blur_din_2     (blur_din[2]),
      .blur_din_3     (blur_din[3]),
      .img_addr       (gaussian_img_addr),
      .buffer_we      (gaussian_buffer_we),
      .fill_zero      (gaussian_fill_zero[0])
    );


    wire           detect_filter_start = (current_state==ST_DETECT_FILTER) ? 1:0;
    wire           detect_filter_done;
    wire  [8:0]    detect_filter_blur_addr  [0:3];
    wire  [8:0]    detect_filter_img_addr;
    wire           detect_filter_buffer_we;
    wire  [10:0]   detect_filter_keypoint_1_addr,
                   detect_filter_keypoint_2_addr;
    Detect_Filter_Keypoints u_detect_filter_keypoints(
      .clk              (clk),
      .rst_n            (rst_n),
      .start            (detect_filter_start),
      .done             (detect_filter_done),
      .img_dout         (img_dout),
      .blur3x3_dout     (blur_dout[0]),
      .blur5x5_1_dout   (blur_dout[1]),
      .blur5x5_2_dout   (blur_dout[2]),
      .blur7x7_dout     (blur_dout[3]),
      .img_addr         (detect_filter_img_addr),
      .blur3x3_addr     (detect_filter_blur_addr[0]),
      .blur5x5_1_addr   (detect_filter_blur_addr[1]),
      .blur5x5_2_addr   (detect_filter_blur_addr[2]),
      .blur7x7_addr     (detect_filter_blur_addr[3]),
      .buffer_we        (detect_filter_buffer_we),
      .buffer_data_0    (buffer_data_0),
      .buffer_data_1    (buffer_data_1),
      .buffer_data_2    (buffer_data_2),
      .buffer_data_3    (buffer_data_3),
      .buffer_data_4    (buffer_data_4),
      .buffer_data_5    (buffer_data_5),
      .buffer_data_6    (buffer_data_6),
      .buffer_data_7    (buffer_data_7),
      .buffer_data_8    (buffer_data_8),
      .buffer_data_9    (buffer_data_9),
      .keypoint_we    (keypoint_we),
      .keypoint_addr  (detect_filter_keypoint_addr),
      .keypoint_din   (keypoint_din),
      // .keypoint_2_we    (keypoint_2_we),
      // .keypoint_2_addr  (detect_filter_keypoint_2_addr),
      // .keypoint_2_din   (keypoint_2_din),
      .filter_on        (filter_on),
      .filter_threshold (filter_threshold)
    );

    reg [10:0]  keypoint_num;
    always @(posedge clk ) begin
      if (!rst_n) 
        keypoint_num <= 0;    
      else if (current_state==ST_DETECT_FILTER)
        keypoint_num <= detect_filter_keypoint_addr;
      else if (current_state==ST_IDLE)
        keypoint_num <= 0;
    end

    /*reg [10:0]  keypoint_num_2;
    always @(posedge clk ) begin
      if (!rst_n) 
        keypoint_num_2 <= 0;    
      else if (current_state==ST_DETECT_FILTER)
        keypoint_num_2 <= detect_filter_keypoint_2_addr;
      else if (current_state==ST_IDLE)
        keypoint_num_2 <= 0;
    end*/

    /*wire           compute_match_start = (current_state==ST_COMPUTE_MATCH) ? 1:0;
    wire           compute_match_done;
    wire  [10:0]   kpt_addr;
    wire           compute_match_buffer_we;
    wire  [8:0]    blurred_addr;
    wire           readFrom;
    wire  [402:0]  row_col_descpt1,
                   row_col_descpt2,
                   row_col_descpt3,
                   row_col_descpt4;   
    wire           descriptor_request,
                   descriptor_valid;
    wire           compute_match_fill_zero;
                   
    computeDescriptor u_computeDescriptor(
        .clk                (clk),
        .rst_n              (rst_n),
        .start              (compute_match_start),//同時也送進match
        .kptRowCol1         (keypoint_1_dout),
        .kptRowCol2         (keypoint_2_dout),
        .layer1_num         (keypoint_num_1),//wire接進來，值不能改
        .layer2_num         (keypoint_num_2),
        .line_buffer_0      (buffer_data_0),
        .line_buffer_1      (buffer_data_1),
        .line_buffer_2      (buffer_data_2),
        .kpt_addr           (kpt_addr),
        .modified_blurred_addr(blurred_addr),
        .row_col_descpt1    (row_col_descpt1),//FF，用wire送進match
        .row_col_descpt2    (row_col_descpt2),
        .row_col_descpt3    (row_col_descpt3),
        .row_col_descpt4    (row_col_descpt4),
        .descriptor_request (descriptor_request),//match在要了
        .descriptor_valid   (descriptor_valid),//告訴match，4個擺好了
        .readFrom           (readFrom),
        .LB_WE              (compute_match_buffer_we),
        .fillZero           (compute_match_fill_zero)
    );




    reg[8:0]  tar_descpt_group_num;
    
    match u_match(
        .clk                  (clk),
        .rst_n                (rst_n),
        .start                (compute_match_start),
        .done                 (compute_match_done),
        .descriptor_request   (descriptor_request),
        .descriptor_valid     (descriptor_valid),
        .tar_descpt_group_num (tar_descpt_group_num),
        .image_R_C_D_0        (row_col_descpt1),//image's row col descriptor
        .image_R_C_D_1        (row_col_descpt2),
        .image_R_C_D_2        (row_col_descpt3),
        .image_R_C_D_3        (row_col_descpt4),
        .tar_addr             (target_addr),//讀target mem的addr(4個共用)
        .tar_R_C_D_0          (target_0_dout),
        .tar_R_C_D_1          (target_1_dout),
        .tar_R_C_D_2          (target_2_dout),
        .tar_R_C_D_3          (target_3_dout),
        .matched_addr_1       (matched_addr1),//4個共用
        .matched_WE           (matched_we),//4 bit
        .matched_din_0        (matched_0_din),//接給matched的din
        .matched_din_1        (matched_1_din),
        .matched_din_2        (matched_2_din),
        .matched_din_3        (matched_3_din),
        .matched_addr_2       (matched_addr2),//4個共用
        .matched_dout2_0      (matched_0_dout),
        .matched_dout2_1      (matched_1_dout),
        .matched_dout2_2      (matched_2_dout),
        .matched_dout2_3      (matched_3_dout),
        .layer1_num           (keypoint_num_1),
        .layer2_num           (keypoint_num_2)
    );*/

    always @(*) begin
      case(current_state)
        ST_GAUSSIAN: begin
          blur_addr[0] = gaussian_blur_addr[0];    
          blur_addr[1] = gaussian_blur_addr[1];    
          blur_addr[2] = gaussian_blur_addr[2];    
          blur_addr[3] = gaussian_blur_addr[3];    
          buffer_we = gaussian_buffer_we;
          img_addr  = gaussian_img_addr;
          fill_zero = |gaussian_fill_zero;
          keypoint_addr = 0;
          buffer_in = img_dout;
        end
      ST_DETECT_FILTER: begin
        blur_addr[0] = detect_filter_blur_addr[0];  
        blur_addr[1] = detect_filter_blur_addr[1];  
        blur_addr[2] = detect_filter_blur_addr[2];  
        blur_addr[3] = detect_filter_blur_addr[3];  
        buffer_we = detect_filter_buffer_we;
        img_addr  = detect_filter_img_addr;
        fill_zero = 0;
        keypoint_addr = detect_filter_keypoint_addr;
        // keypoint_2_addr = detect_filter_keypoint_2_addr;
        buffer_in = img_dout;
      end
      /*ST_COMPUTE_MATCH: begin
        blur_addr[0] = blurred_addr;  
        blur_addr[1] = blurred_addr;  
        blur_addr[2] = 0;  
        blur_addr[3] = 0;  
        buffer_we = compute_match_buffer_we;
        img_addr  = 0;
        fill_zero = compute_match_fill_zero;
        keypoint_1_addr = kpt_addr;
        keypoint_2_addr = kpt_addr;
        buffer_in = (readFrom) ? blur_dout[1] : blur_dout[0];
      end*/
      default: begin
        blur_addr[0] = 0;
        blur_addr[1] = 0;  
        blur_addr[2] = 0;  
        blur_addr[3] = 0;  
        buffer_we = 0;
        img_addr  = 0;
        fill_zero = 0;
        keypoint_addr = 0;
        buffer_in = 0;
      end
    endcase
  end


    /*
     *  FSM
     *
     */

    always @(posedge clk) begin
      if (!rst_n) begin
        current_state <= ST_IDLE;    
      end
      else begin
        current_state <= next_state;
      end
    end

    always @(*) begin
      case(current_state)
        ST_IDLE: begin
          if(start)
            next_state = ST_GAUSSIAN;
          else
            next_state = ST_IDLE;
        end
        ST_GAUSSIAN: begin
          if(gaussian_done[0])
            next_state = ST_DETECT_FILTER;
          else
            next_state = ST_GAUSSIAN;
        end
        ST_DETECT_FILTER: begin
          if(detect_filter_done)
            next_state = ST_END;//ST_COMPUTE_MATCH;
          else
            next_state = ST_DETECT_FILTER;
        end/*
        ST_COMPUTE_MATCH: begin
          if(compute_match_done)
            next_state = ST_END;
          else 
            next_state = ST_COMPUTE_MATCH;
        end*/
        ST_END: begin /*DEBUG STATE*/
            next_state = ST_END;
        end
        default:
          next_state = ST_IDLE;
      endcase
    end


endmodule 