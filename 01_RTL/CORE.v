`timescale 1ns/10ps
module CORE(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);
input           clk;
input           rst_n;
input           in_valid;/*USED AS START SIGNAL FOR NOW*/
input   [15:0]  in_data;
output          out_valid;
output  [15:0]  out_data;






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
  .din  (1'b0),
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
wire          keypoint_1_we;
wire  [10:0]  keypoint_1_addr;
wire  [18:0]  keypoint_1_din;
wire  [18:0]  keypoint_1_dout;
bmem_2000x19 keypoint_1_mem(
  .clk  (clk),
  .we   (keypoint_1_we),
  .addr (keypoint_1_addr),
  .din  (keypoint_1_din),
  .dout (keypoint_1_dout)
);

wire          keypoint_2_we;
wire  [10:0]  keypoint_2_addr;
wire  [18:0]  keypoint_2_din;
wire  [18:0]  keypoint_2_dout;
bmem_2000x19 keypoint_2_mem(
  .clk  (clk),
  .we   (keypoint_2_we),
  .addr (keypoint_2_addr),
  .din  (keypoint_2_din),
  .dout (keypoint_2_dout)
);

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
// wire              buffer_mode = (gaussian_done)?L_IDLE:L_GAUSSIAN;
/*System Line Buffer*/
Line_Buffer_10 l_buf_10(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_mode    (current_state),
  .buffer_we      (buffer_we),
  .img_data       (img_dout),
  .blur_data_0    (blur3x3_dout),
  .blur_data_1    (blur5x5_1_dout),
  .blur_data_2    (blur5x5_2_dout),
  .blur_data_3    (blur7x7_dout),
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

wire    gaussian_start = (current_state==ST_GAUSSIAN)?1:0;
wire  [8:0]    gaussian_blur_addr  [0:3];
wire  [8:0]    gaussian_img_addr;
wire  [3:0]    gaussian_done;
wire           gaussian_buffer_we;
Gaussian_Blur_3x3 g_blur_3x3(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .start          (gaussian_start),
  .done           (gaussian_done[0]),
  .blur_mem_we    (blur_mem_we[0]),
  .blur_addr      (gaussian_blur_addr[0]),
  .blur_din       (blur_din[0]),
  .img_addr       (gaussian_img_addr),
  .buffer_we      (gaussian_buffer_we)
);

Gaussian_Blur_5x5_1 g_blur_5x5_1(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .start          (gaussian_start),
  .done           (gaussian_done[1]),
  .blur_mem_we    (blur_mem_we[1]),
  .blur_addr      (gaussian_blur_addr[1]),
  .blur_din       (blur_din[1]),
  .img_addr       (gaussian_img_addr),
  .buffer_we      (gaussian_buffer_we)
);

Gaussian_Blur_5x5_2 g_blur_5x5_2(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .start          (gaussian_start),
  .done           (gaussian_done[2]),
  .blur_mem_we    (blur_mem_we[2]),
  .blur_addr      (gaussian_blur_addr[2]),
  .blur_din       (blur_din[2]),
  .img_addr       (gaussian_img_addr),
  .buffer_we      (gaussian_buffer_we)
);

Gaussian_Blur_7x7 g_blur_7x7(
  .clk            (clk),
  .rst_n          (rst_n),
  .img_dout       (img_dout),
  .buffer_data_1  (buffer_data_0),
  .buffer_data_2  (buffer_data_1),
  .buffer_data_3  (buffer_data_2),
  .buffer_data_4  (buffer_data_3),
  .buffer_data_5  (buffer_data_4),
  .buffer_data_6  (buffer_data_5),
  .start          (gaussian_start),
  .done           (gaussian_done[3]),
  .blur_mem_we    (blur_mem_we[3]),
  .blur_addr      (gaussian_blur_addr[3]),
  .blur_din       (blur_din[3]),
  .img_addr       (gaussian_img_addr),
  .buffer_we      (gaussian_buffer_we)
);

wire           detect_filter_start = (current_state==ST_DETECT_FILTER) ? 1:0;
wire           detect_filter_done;
wire  [8:0]    detect_filter_blur_addr  [0:3];
wire  [8:0]    detect_filter_img_addr;
wire           detect_filter_buffer_we;
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
  .keypoint_1_we    (keypoint_1_we),
  .keypoint_1_addr  (keypoint_1_addr),
  .keypoint_1_din   (keypoint_1_din),
  .keypoint_2_we    (keypoint_2_we),
  .keypoint_2_addr  (keypoint_2_addr),
  .keypoint_2_din   (keypoint_2_din)
);

always @(*) begin
  if (current_state == ST_GAUSSIAN) begin
    blur_addr[0] = gaussian_blur_addr[0];    
    blur_addr[1] = gaussian_blur_addr[1];    
    blur_addr[2] = gaussian_blur_addr[2];    
    blur_addr[3] = gaussian_blur_addr[3];    
    buffer_we = gaussian_buffer_we;
    img_addr  = gaussian_img_addr;
  end
  else if (current_state == ST_DETECT_FILTER) begin
    blur_addr[0] = detect_filter_blur_addr[0];  
    blur_addr[1] = detect_filter_blur_addr[1];  
    blur_addr[2] = detect_filter_blur_addr[2];  
    blur_addr[3] = detect_filter_blur_addr[3];  
    buffer_we = detect_filter_buffer_we;
    img_addr  = detect_filter_img_addr;
  end
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
      if(in_valid)
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
        next_state = ST_END;
      else
        next_state = ST_DETECT_FILTER;
    end
    ST_END: begin /*DEBUG STATE*/
        next_state = ST_END;
    end
    default:
      next_state = ST_IDLE;
  endcase
end


endmodule 