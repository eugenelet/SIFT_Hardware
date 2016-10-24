`timescale 1ns/10ps
module CORE(
    clk,
    rst_n,
    start,
    done,
    filter_on,
    img_din,
    img_addr_in,
    img_we,
    target_0_we,
    target_1_we,
    target_2_we,
    target_3_we,
    target_0_din,
    target_1_din,
    target_2_din,
    target_3_din,
    target_addr_in,
    matched_addr1_in,
    matched_addr2_in,
    matched_we_in,
    in_matched_0_din,
    in_matched_1_din,
    in_matched_2_din,
    in_matched_3_din,
    matched_0_dout,
    matched_1_dout,
    matched_2_dout,
    matched_3_dout,
    adaptiveToggle,
    adaptiveMode
);
    /*Basic I/O*/
    input           clk,
                    rst_n;
    input           start;
    output          done;

    /*  Turns filter ON/OFF
     *  1:ON 
     *  0:OFF
     */
    input           filter_on;


    /*  Input Image SRAM 480x5120 (640x480)
     *  addr: 0~479
     */
    input[5119:0]   img_din;
    input           img_we;
    input[8:0]      img_addr_in;


    /*  Target SRAM x4 512x403
     *  addr: 0~511
     */
    input           target_0_we,
                    target_1_we,
                    target_2_we,
                    target_3_we;
    input[402:0]    target_0_din,
                    target_1_din,
                    target_2_din,
                    target_3_din;
    input[8:0]      target_addr_in;

    /*  Matched Pairs SRAM x4 512x49
     *  addr: 0~511
     */
    input[8:0]      matched_addr1_in,
                    matched_addr2_in;
    input           matched_we_in;
    output[48:0]    matched_0_dout,
                    matched_1_dout,
                    matched_2_dout,
                    matched_3_dout;
    input[48:0]     in_matched_0_din,
                    in_matched_1_din,
                    in_matched_2_din,
                    in_matched_3_din;

    /*  Adaptive Threshold Controller
     *  adaptiveToggle
     *  --------------
     *    1:ON 
     *    0:OFF
     *  adaptiveMode
     *  ------------
     *    0: High Throughput
     *    1: High Accuracy
     */
    input           adaptiveToggle;
    input[1:0]      adaptiveMode;

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
    wire    [5119:0]  img_dout;
    /*SRAM for Original Image*/
    bmem_480x5120 ori_img(
      .clk  (clk),
      .we   (img_we),
      .addr (img_addr),
      .din  (img_din),
      .dout (img_dout)
    );


    wire  [3:0]    blur_mem_we;
    reg   [8:0]    blur_addr1 [0:3]; /*wire*/
    reg   [8:0]    blur_addr2 [0:3]; /*wire*/
    wire  [5119:0] blur_din   [0:3];
    wire  [5119:0] blur_dout1 [0:3];
    wire  [5119:0] blur_dout2 [0:3];
    /*Dual Port SRAM for Blurred Images(4)*/
    bmem_480x5120 blur_img_0(
      .clk  (clk),
      .we   (blur_mem_we[0]),
      .addr (blur_addr1[0]),
      .addr (blur_addr2[0]),
      .din  (blur_din[0]),
      .dout (blur_dout1[0]),
      .dout (blur_dout2[0])
    );
    bmem_480x5120 blur_img_1(
      .clk  (clk),
      .we   (blur_mem_we[1]),
      .addr (blur_addr1[1]),
      .addr (blur_addr2[1]),
      .din  (blur_din[1]),
      .dout (blur_dout1[1]),
      .dout (blur_dout2[1])
    );
    bmem_480x5120 blur_img_2(
      .clk  (clk),
      .we   (blur_mem_we[2]),
      .addr (blur_addr1[2]),
      .addr (blur_addr2[2]),
      .din  (blur_din[2]),
      .dout (blur_dout1[2]),
      .dout (blur_dout2[2])
    );
    bmem_480x5120 blur_img_3(
      .clk  (clk),
      .we   (blur_mem_we[3]),
      .addr (blur_addr1[3]),
      .addr (blur_addr2[3]),
      .din  (blur_din[3]),
      .dout (blur_dout1[3]),
      .dout (blur_dout2[3])
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
    
    /*SRAM for Target*/
    reg[8:0]    target_addr;//shared
    wire[402:0] target_0_dout;
    bmem_512x403 target_0_mem(
      .clk  (clk),
      .we   (target_0_we),
      .addr (target_addr),
      .din  (target_0_din),
      .dout (target_0_dout)
    );

    wire  [402:0]  target_1_dout;
    bmem_512x403 target_1_mem(
      .clk  (clk),
      .we   (target_1_we),
      .addr (target_addr),
      .din  (target_1_din),
      .dout (target_1_dout)
    );

    wire  [402:0]  target_2_dout;
    bmem_512x403 target_2_mem(
      .clk  (clk),
      .we   (target_2_we),
      .addr (target_addr),
      .din  (target_2_din),
      .dout (target_2_dout)
    );

    wire  [402:0]  target_3_dout;
    bmem_512x403 target_3_mem(
      .clk  (clk),
      .we   (target_3_we),
      .addr (target_addr),
      .din  (target_3_din),
      .dout (target_3_dout)
    );
    
    /*SRAM for Matched*/
    reg   [8:0]  matched_addr1; /*WIRE*/
    reg   [8:0]  matched_addr2;//shared WIRE
    reg  [3:0]   matched_we;//write din to addr1 WIRE
    
    reg  [48:0]  matched_0_din; /*wire*/
    bmem_512x49 matched_0_mem(
      .clk  (clk),
      .we   (matched_we[0]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_0_din),
      .dout1(),
      .dout2(matched_0_dout)
    );

    reg  [48:0]  matched_1_din; /*wire*/
    bmem_512x49 matched_1_mem(
      .clk  (clk),
      .we   (matched_we[1]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_1_din),
      .dout1(),
      .dout2(matched_1_dout)
    );
    
    reg  [48:0]  matched_2_din; /*wire*/
    bmem_512x49 matched_2_mem(
      .clk  (clk),
      .we   (matched_we[2]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_2_din),
      .dout1(),
      .dout2(matched_2_dout)
    );
    
    reg  [48:0]  matched_3_din; /*wire*/
    bmem_512x49 matched_3_mem(
      .clk  (clk),
      .we   (matched_we[3]),
      .addr1(matched_addr1),
      .addr2(matched_addr2),
      .din  (matched_3_din),
      .dout1(),
      .dout2(matched_3_dout)
    );

    /* Adaptive Threshold Module*/
    reg[10:0]         keypoint_num;
    wire signed[9:0]  filter_threshold;
    adaptiveThreshold u_adapt(
      .clk              (clk),
      .rst_n            (rst_n),
      .adaptiveToggle   (adaptiveToggle),
      .adaptiveMode     (adaptiveMode),
      .filter_threshold (filter_threshold),
      .keypoint_num     (keypoint_num)
    );

    /*Line Buffer*/    
    wire    [175:0]   buffer_data_0;
    wire    [175:0]   buffer_data_1;
    wire    [175:0]   buffer_data_2;
    wire    [175:0]   buffer_data_3;
    wire    [175:0]   buffer_data_4;
    wire    [175:0]   buffer_data_5;
    wire    [175:0]   buffer_data_6;
    wire    [175:0]   buffer_data_7;
    wire    [175:0]   buffer_data_8;
    wire    [175:0]   buffer_data_9;
    reg               buffer_we; /*wire*/
    reg               fill_zero;  /*wire*/
    reg     [5119:0]  buffer_in;
    wire              buffer_mode = (current_state==ST_DETECT_FILTER) ? 1 : 0;
    wire    [5:0]     buffer_col;
    // wire              buffer_mode = (gaussian_done)?L_IDLE:L_GAUSSIAN;
    /*System Line Buffer*/
    Line_Buffer_10 l_buf_10(
      .clk            (clk),
      .rst_n          (rst_n),
      .buffer_mode    (buffer_mode),
      .buffer_we      (buffer_we),
      .fill_zero      (fill_zero),
      .in_data0       (buffer_in),
      .in_data1       (blur_dout1[0]),
      .in_data2       (blur_dout1[1]),
      .in_data3       (blur_dout1[2]),
      .in_data4       (blur_dout1[3]),
      .buffer_data_0  (buffer_data_0),
      .buffer_data_1  (buffer_data_1),
      .buffer_data_2  (buffer_data_2),
      .buffer_data_3  (buffer_data_3),
      .buffer_data_4  (buffer_data_4),
      .buffer_data_5  (buffer_data_5),
      .buffer_data_6  (buffer_data_6),
      .buffer_data_7  (buffer_data_7),
      .buffer_data_8  (buffer_data_8),
      .buffer_data_9  (buffer_data_9),
      .buffer_col     (buffer_col)
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
      .buffer_data_6  (buffer_data_6),
      .start          (gaussian_start),
      .done           (gaussian_done[0]),
      .blur_mem_we_0  (blur_mem_we[0]),
      .blur_mem_we_1  (blur_mem_we[1]),
      .blur_mem_we_2  (blur_mem_we[2]),
      .blur_mem_we_3  (blur_mem_we[3]),
      .blur_addr_w_0  (gaussian_blur_addr[0]),
      .blur_addr_w_1  (gaussian_blur_addr[1]),
      .blur_addr_w_2  (gaussian_blur_addr[2]),
      .blur_addr_w_3  (gaussian_blur_addr[3]),
      .blur_addr_r_0  (blur_addr2[0]),
      .blur_addr_r_1  (blur_addr2[1]),
      .blur_addr_r_2  (blur_addr2[2]),
      .blur_addr_r_3  (blur_addr2[3]),
      .blur_din_0     (blur_din[0]),
      .blur_din_1     (blur_din[1]),
      .blur_din_2     (blur_din[2]),
      .blur_din_3     (blur_din[3]),
      .blur_dout_0    (blur_dout2[0]),
      .blur_dout_1    (blur_dout2[1]),
      .blur_dout_2    (blur_dout2[2]),
      .blur_dout_3    (blur_dout2[3]),
      .img_addr       (gaussian_img_addr),
      .buffer_we      (gaussian_buffer_we),
      .fill_zero      (gaussian_fill_zero[0]),
      .current_col    (buffer_col)
    );


    /*wire           detect_filter_start = (current_state==ST_DETECT_FILTER) ? 1:0;
    wire           detect_filter_done;
    wire  [8:0]    detect_filter_blur_addr  [0:3];
    wire  [8:0]    detect_filter_img_addr;
    wire           detect_filter_buffer_we;
    wire  [10:0]   detect_filter_keypoint_addr;
                   // detect_filter_keypoint_2_addr;
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
      .filter_on        (filter_on),
      .filter_threshold (filter_threshold)
    );

    always @(posedge clk ) begin
      if (!rst_n) 
        keypoint_num <= 0;    
      else if (current_state==ST_DETECT_FILTER)
        keypoint_num <= detect_filter_keypoint_addr;
      else if (current_state==ST_IDLE)
        keypoint_num <= 0;
    end


    wire           compute_match_start = (current_state==ST_COMPUTE_MATCH) ? 1:0;
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
                   
    computeDescriptor u_computeDescriptor(
        .clk                (clk),
        .rst_n              (rst_n),
        .start              (compute_match_start),//同時也送進match
        .kptRowCol          (keypoint_dout),
        .line_buffer_0      (buffer_data_0),
        .line_buffer_1      (buffer_data_1),
        .line_buffer_2      (buffer_data_2),
        .kpt_num            (keypoint_num),//wire接進來，值不能改
        .kpt_addr           (kpt_addr),
        .blurred_addr       (blurred_addr),
        .row_col_descpt1    (row_col_descpt1),//FF，用wire送進match
        .row_col_descpt2    (row_col_descpt2),
        .row_col_descpt3    (row_col_descpt3),
        .row_col_descpt4    (row_col_descpt4),
        .descriptor_request (descriptor_request),//match在要了
        .descriptor_valid   (descriptor_valid),//告訴match，4個擺好了
        .readFrom           (readFrom),
        .LB_WE              (compute_match_buffer_we)
    );



    reg[8:0]  tar_descpt_group_num;
    wire[8:0] match_target_addr;
    wire[8:0] match_matched_addr1,
              match_matched_addr2;
    wire[48:0]match_matched_0_din,
              match_matched_1_din,
              match_matched_2_din,
              match_matched_3_din;
    wire[3:0] match_matched_we;
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
        .tar_addr             (match_target_addr),//讀target mem的addr(4個共用)
        .tar_R_C_D_0          (target_0_dout),
        .tar_R_C_D_1          (target_1_dout),
        .tar_R_C_D_2          (target_2_dout),
        .tar_R_C_D_3          (target_3_dout),
        .matched_addr_1       (match_matched_addr1),//4個共用
        .matched_WE           (match_matched_we),//4 bit
        .matched_din_0        (match_matched_0_din),//接給matched的din
        .matched_din_1        (match_matched_1_din),
        .matched_din_2        (match_matched_2_din),
        .matched_din_3        (match_matched_3_din),
        .matched_addr_2       (match_matched_addr2),//4個共用
        .matched_dout2_0      (matched_0_dout),
        .matched_dout2_1      (matched_1_dout),
        .matched_dout2_2      (matched_2_dout),
        .matched_dout2_3      (matched_3_dout),
        .kpt_num              (keypoint_num)
    );*/

    always @(*) begin
      case(current_state)
        ST_IDLE: begin
          blur_addr1[0] = 0;
          blur_addr1[1] = 0;  
          blur_addr1[2] = 0;  
          blur_addr1[3] = 0;  
          buffer_we = 0;
          img_addr  = img_addr_in;
          fill_zero = 0;
          keypoint_addr = 0;
          buffer_in = 0;
          /*target_addr = target_addr_in;
          matched_addr1 = matched_addr1_in;
          matched_addr2 = 0;
          matched_we = {matched_we_in, matched_we_in, matched_we_in, matched_we_in};
          matched_0_din = in_matched_0_din;
          matched_1_din = in_matched_1_din;
          matched_2_din = in_matched_2_din;
          matched_3_din = in_matched_3_din;*/
        end
        ST_GAUSSIAN: begin
          blur_addr1[0] = gaussian_blur_addr[0];    
          blur_addr1[1] = gaussian_blur_addr[1];    
          blur_addr1[2] = gaussian_blur_addr[2];    
          blur_addr1[3] = gaussian_blur_addr[3];    
          buffer_we = gaussian_buffer_we;
          img_addr  = gaussian_img_addr;
          fill_zero = |gaussian_fill_zero;
          keypoint_addr = 0;
          buffer_in = img_dout;
          /*target_addr = 0;
          matched_addr1 = 0;
          matched_addr2 = 0;
          matched_we = 0;
          matched_0_din = 0;
          matched_1_din = 0;
          matched_2_din = 0;
          matched_3_din = 0;*/
        end
        /*ST_DETECT_FILTER: begin
          blur_addr1[0] = detect_filter_blur_addr[0];  
          blur_addr1[1] = detect_filter_blur_addr[1];  
          blur_addr1[2] = detect_filter_blur_addr[2];  
          blur_addr1[3] = detect_filter_blur_addr[3];  
          buffer_we = detect_filter_buffer_we;
          img_addr  = detect_filter_img_addr;
          fill_zero = 0;
          keypoint_addr = detect_filter_keypoint_addr;
          buffer_in = img_dout;
          target_addr = 0;
          matched_addr1 = 0;
          matched_addr2 = 0;
          matched_we = 0;
          matched_0_din = 0;
          matched_1_din = 0;
          matched_2_din = 0;
          matched_3_din = 0;
        end
        ST_COMPUTE_MATCH: begin
          blur_addr1[0] = blurred_addr;  
          blur_addr1[1] = blurred_addr;  
          blur_addr1[2] = 0;  
          blur_addr1[3] = 0;  
          buffer_we = compute_match_buffer_we;
          img_addr  = 0;
          fill_zero = 0;
          keypoint_addr = kpt_addr;
          buffer_in = (readFrom) ? blur_dout[1] : blur_dout[0];
          target_addr = match_target_addr;
          matched_addr1 = match_matched_addr1;
          matched_addr2 = match_matched_addr2;
          matched_we = match_matched_we;
          matched_0_din = match_matched_0_din;
          matched_1_din = match_matched_1_din;
          matched_2_din = match_matched_2_din;
          matched_3_din = match_matched_3_din;
        end*/
        default: begin
          blur_addr1[0] = 0;
          blur_addr1[1] = 0;  
          blur_addr1[2] = 0;  
          blur_addr1[3] = 0;  
          buffer_we = 0;
          img_addr  = 0;
          fill_zero = 0;
          keypoint_addr = 0;
          buffer_in = 0;
          /*target_addr = 0;
          matched_addr1 = 0;
          matched_addr2 = matched_addr2_in;
          matched_we = 0;
          matched_0_din = 0;
          matched_1_din = 0;
          matched_2_din = 0;
          matched_3_din = 0;*/
        end
      endcase
    end

    assign done = compute_match_done;

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
            next_state = ST_END; //ST_DETECT_FILTER;
          else
            next_state = ST_GAUSSIAN;
        end
        ST_DETECT_FILTER: begin
          if(detect_filter_done)
            next_state = ST_COMPUTE_MATCH;
          else
            next_state = ST_DETECT_FILTER;
        end
        ST_COMPUTE_MATCH: begin
          if(compute_match_done)
            next_state = ST_END;
          else 
            next_state = ST_COMPUTE_MATCH;
        end
        ST_END: begin /*DEBUG STATE*/
            next_state = ST_END;
        end
        default:
          next_state = ST_IDLE;
      endcase
    end


endmodule 