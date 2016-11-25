module Detect_Filter_Keypoints(
  clk,
  rst_n,
  start,
  done,
  img_dout,
  blur3x3_dout,
  blur5x5_1_dout,
  blur5x5_2_dout,
  blur7x7_dout,
  img_addr,
  blur3x3_addr,
  blur5x5_1_addr,
  blur5x5_2_addr,
  blur7x7_addr,
  buffer_we,
  buffer_data_0,
  buffer_data_1,
  buffer_data_2,
  buffer_data_3,
  buffer_data_4,
  buffer_data_5,
  buffer_data_6,
  buffer_data_7,
  buffer_data_8,
  buffer_data_9,
  keypoint_we,
  keypoint_addr,
  keypoint_din,
  filter_on,
  filter_threshold,
  buffer_col
);
/*SYSTEM*/
input             clk,
                  rst_n,
                  start,
                  filter_on;
input signed[9:0] filter_threshold;
output       done;

/*To line Buffer*/
output               buffer_we;
output[5:0]          buffer_col;
/*BUFFER IN*/
input      [175:0]   buffer_data_0,
                     buffer_data_1,
                     buffer_data_2,
                     buffer_data_3,
                     buffer_data_4,
                     buffer_data_5,
                     buffer_data_6,
                     buffer_data_7,
                     buffer_data_8,
                     buffer_data_9;

/*From SRAM (Used with Buffer)*/
input      [5119:0]  img_dout,
                     blur3x3_dout,
                     blur5x5_1_dout,
                     blur5x5_2_dout,
                     blur7x7_dout;

/*To SRAM*/
output reg[8:0] img_addr,
                blur3x3_addr,
                blur5x5_1_addr,
                blur5x5_2_addr,
                blur7x7_addr;

/*To Keypoint SRAM*/
output reg    keypoint_we;
output reg    [10:0] keypoint_addr; /*2K Keypoints*/
output reg    [19:0] keypoint_din; /*ROW: 9 bit COL: 10 bit*/

// output reg    keypoint_2_we;
// output reg    [10:0] keypoint_2_addr; /*2K Keypoints*/
// output reg    [18:0] keypoint_2_din; /*ROW: 9 bit COL: 10 bit*/


/*FSM*/
reg         [2:0] current_state,
                  next_state;

parameter MAX_KEYPOINT = 'd2048;

/*Module FSM*/
parameter ST_IDLE       = 0,
          ST_FIRST_COL  = 1,/*Idle 1 state for SRAM to get READY*/
          ST_PRE_DETECT = 2,/*Buffers data from SRAM*/
          ST_DETECT     = 3,/*Includes switching of row*/
          ST_NO_FILTER  = 4,/*Includes switching of row*/
          ST_FILTER     = 5,/*Includes switching of row*/
          ST_NEXT_COL   = 6,/*Grants 3 cycle to update MEM addr for next column*/
          ST_BUFFER     = 7;/*Grants buffer a cycle to update*/

assign done = (current_state==ST_BUFFER && img_addr=='d472 && buffer_col=='d39) ? 1 : 0;


/*Use for filter keypoint on turning off bits one-by-one*/
reg[15:0] is_keypoint_reg_0;
reg[15:0] is_keypoint_reg_1;

/*From Detect keypoint modules*/
wire   [15:0] is_keypoint_0;
wire   [15:0] is_keypoint_1;

/*Check whether keypoint is empty*/
wire  keypoint_layer_1_empty = !(|is_keypoint_reg_0) ? 1:0;
wire  keypoint_layer_2_empty = !(|is_keypoint_reg_1) ? 1:0;

reg[1:0]  next_col_count;
always @(posedge clk ) begin
  if (!rst_n) 
    next_col_count <= 'd0;    
  else if ((current_state==ST_NEXT_COL || current_state==ST_FIRST_COL) && next_col_count<'d3) 
    next_col_count <= next_col_count + 1;
  else 
    next_col_count <= 'd0;
end

assign buffer_we = (current_state==ST_FIRST_COL || current_state==ST_NEXT_COL || current_state==ST_BUFFER) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd8;    
  else if (  (current_state==ST_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_NO_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_DETECT && !(|is_keypoint_0) && !(|is_keypoint_1)) || /*if no keypoints found*/
             current_state==ST_FIRST_COL || current_state==ST_NEXT_COL &&
             img_addr < 'd472/*'d480*/) 
    img_addr <= img_addr + 1;
  else if ((current_state==ST_BUFFER && img_addr=='d472) || current_state==ST_IDLE)
    img_addr <= 'd8;
end
always @(posedge clk) begin
  if (!rst_n) 
    blur3x3_addr <= 'd8;    
  else if (  (current_state==ST_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_NO_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_DETECT && !(|is_keypoint_0) && !(|is_keypoint_1)) || /*if no keypoints found*/
             current_state==ST_FIRST_COL || current_state==ST_NEXT_COL &&
             blur3x3_addr < 'd472/*'d480*/)
    blur3x3_addr <= blur3x3_addr + 1;
  else if ((current_state==ST_BUFFER && blur3x3_addr=='d472) || current_state==ST_IDLE)
    blur3x3_addr <= 'd8;
end
always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_1_addr <= 'd8;    
  else if (  (current_state==ST_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_NO_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_DETECT && !(|is_keypoint_0) && !(|is_keypoint_1)) || /*if no keypoints found*/
             current_state==ST_FIRST_COL || current_state==ST_NEXT_COL &&
             blur5x5_1_addr < 'd472/*'d480*/)
    blur5x5_1_addr <= blur5x5_1_addr + 1;
  else if ((current_state==ST_BUFFER && blur5x5_1_addr=='d472) || current_state==ST_IDLE)
    blur5x5_1_addr <= 'd8;
end
always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_2_addr <= 'd8;    
  else if (  (current_state==ST_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_NO_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_DETECT && !(|is_keypoint_0) && !(|is_keypoint_1)) || /*if no keypoints found*/
             current_state==ST_FIRST_COL || current_state==ST_NEXT_COL &&
             blur5x5_2_addr < 'd472/*'d480*/)
    blur5x5_2_addr <= blur5x5_2_addr + 1;
  else if ((current_state==ST_BUFFER && blur5x5_2_addr=='d472) || current_state==ST_IDLE)
    blur5x5_2_addr <= 'd8;
end
always @(posedge clk) begin
  if (!rst_n) 
    blur7x7_addr <= 'd8;    
  else if (  (current_state==ST_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_NO_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_DETECT && !(|is_keypoint_0) && !(|is_keypoint_1)) || /*if no keypoints found*/
             current_state==ST_FIRST_COL || current_state==ST_NEXT_COL &&
             blur7x7_addr < 'd472/*'d480*/)
    blur7x7_addr <= blur7x7_addr + 1;
  else if ((current_state==ST_BUFFER && blur7x7_addr=='d472) || current_state==ST_IDLE)
    blur7x7_addr <= 'd8;
end

/*Counter for current column*/
// remember to remove  <'d7 '>d631
reg[5:0]  buffer_col;
always @(posedge clk) begin
  if (!rst_n) 
    buffer_col <= 'd0;    
  else if (current_state==ST_BUFFER && img_addr=='d472 && buffer_col<'d40)
    buffer_col <= buffer_col + 1;
  else if (done)
    buffer_col <= 'd0;
end

wire[9:0] current_col = buffer_col << 'd4; // mul 16


wire[175:0] img_dout_wire;
wire[175:0] blur3x3_dout_wire;
wire[175:0] blur5x5_1_dout_wire;
wire[175:0] blur5x5_2_dout_wire;
wire[175:0] blur7x7_dout_wire;
bus_partition u_bus_partition(
  .img0       (img_dout),
  .img1       (blur3x3_dout),
  .img2       (blur5x5_1_dout),
  .img3       (blur5x5_2_dout),
  .img4       (blur7x7_dout),
  .img_out0   (img_dout_wire),
  .img_out1   (blur3x3_dout_wire),
  .img_out2   (blur5x5_1_dout_wire),
  .img_out3   (blur5x5_2_dout_wire),
  .img_out4   (blur7x7_dout_wire),
  .buffer_col (buffer_col)
);

reg[175:0] img_dout_buffer;
reg[175:0] blur3x3_dout_buffer;
reg[175:0] blur5x5_1_dout_buffer;
reg[175:0] blur5x5_2_dout_buffer;
reg[175:0] blur7x7_dout_buffer;
always @(posedge clk) begin
  if (!rst_n)
    img_dout_buffer <= 'd0;    
  else if (current_state==ST_PRE_DETECT) 
    img_dout_buffer <= img_dout_wire;
end
always @(posedge clk) begin
  if (!rst_n)
    blur3x3_dout_buffer <= 'd0;    
  else if (current_state==ST_PRE_DETECT) 
    blur3x3_dout_buffer <= blur3x3_dout_wire;
end
always @(posedge clk) begin
  if (!rst_n)
    blur5x5_1_dout_buffer <= 'd0;    
  else if (current_state==ST_PRE_DETECT) 
    blur5x5_1_dout_buffer <= blur5x5_1_dout_wire;
end
always @(posedge clk) begin
  if (!rst_n)
    blur5x5_2_dout_buffer <= 'd0;    
  else if (current_state==ST_PRE_DETECT) 
    blur5x5_2_dout_buffer <= blur5x5_2_dout_wire;
end
always @(posedge clk) begin
  if (!rst_n)
    blur7x7_dout_buffer <= 'd0;    
  else if (current_state==ST_PRE_DETECT) 
    blur7x7_dout_buffer <= blur7x7_dout_wire;
end
/*Detect Keypoints Modules*/
detect_keypoint u_detect_keypoint_0_0(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd0),
  .is_keypoint      (is_keypoint_0[0])
);
detect_keypoint u_detect_keypoint_0_1(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd1),
  .is_keypoint      (is_keypoint_0[1])
);
detect_keypoint u_detect_keypoint_0_2(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd2),
  .is_keypoint      (is_keypoint_0[2])
);
detect_keypoint u_detect_keypoint_0_3(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd3),
  .is_keypoint      (is_keypoint_0[3])
);
detect_keypoint u_detect_keypoint_0_4(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd4),
  .is_keypoint      (is_keypoint_0[4])
);
detect_keypoint u_detect_keypoint_0_5(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd5),
  .is_keypoint      (is_keypoint_0[5])
);
detect_keypoint u_detect_keypoint_0_6(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd6),
  .is_keypoint      (is_keypoint_0[6])
);
detect_keypoint u_detect_keypoint_0_7(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd7),
  .is_keypoint      (is_keypoint_0[7])
);
detect_keypoint u_detect_keypoint_0_8(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd8),
  .is_keypoint      (is_keypoint_0[8])
);
detect_keypoint u_detect_keypoint_0_9(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd9),
  .is_keypoint      (is_keypoint_0[9])
);
detect_keypoint u_detect_keypoint_0_10(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd10),
  .is_keypoint      (is_keypoint_0[10])
);
detect_keypoint u_detect_keypoint_0_11(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd11),
  .is_keypoint      (is_keypoint_0[11])
);
detect_keypoint u_detect_keypoint_0_12(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd12),
  .is_keypoint      (is_keypoint_0[12])
);
detect_keypoint u_detect_keypoint_0_13(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd13),
  .is_keypoint      (is_keypoint_0[13])
);
detect_keypoint u_detect_keypoint_0_14(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd14),
  .is_keypoint      (is_keypoint_0[14])
);
detect_keypoint u_detect_keypoint_0_15(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout_buffer),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout_buffer),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout_buffer),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout_buffer),
  .current_col      (current_col + 10'd15),
  .is_keypoint      (is_keypoint_0[15])
);

detect_keypoint u_detect_keypoint_1_0(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd0),
  .is_keypoint      (is_keypoint_1[0])
);
detect_keypoint u_detect_keypoint_1_1(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd1),
  .is_keypoint      (is_keypoint_1[1])
);
detect_keypoint u_detect_keypoint_1_2(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd2),
  .is_keypoint      (is_keypoint_1[2])
);
detect_keypoint u_detect_keypoint_1_3(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd3),
  .is_keypoint      (is_keypoint_1[3])
);
detect_keypoint u_detect_keypoint_1_4(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd4),
  .is_keypoint      (is_keypoint_1[4])
);
detect_keypoint u_detect_keypoint_1_5(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd5),
  .is_keypoint      (is_keypoint_1[5])
);
detect_keypoint u_detect_keypoint_1_6(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd6),
  .is_keypoint      (is_keypoint_1[6])
);
detect_keypoint u_detect_keypoint_1_7(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd7),
  .is_keypoint      (is_keypoint_1[7])
);
detect_keypoint u_detect_keypoint_1_8(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd8),
  .is_keypoint      (is_keypoint_1[8])
);
detect_keypoint u_detect_keypoint_1_9(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd9),
  .is_keypoint      (is_keypoint_1[9])
);
detect_keypoint u_detect_keypoint_1_10(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd10),
  .is_keypoint      (is_keypoint_1[10])
);
detect_keypoint u_detect_keypoint_1_11(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd11),
  .is_keypoint      (is_keypoint_1[11])
);
detect_keypoint u_detect_keypoint_1_12(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd12),
  .is_keypoint      (is_keypoint_1[12])
);
detect_keypoint u_detect_keypoint_1_13(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd13),
  .is_keypoint      (is_keypoint_1[13])
);
detect_keypoint u_detect_keypoint_1_14(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd14),
  .is_keypoint      (is_keypoint_1[14])
);
detect_keypoint u_detect_keypoint_1_15(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout_buffer),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout_buffer),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout_buffer),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout_buffer),
  .current_col      (current_col + 10'd15),
  .is_keypoint      (is_keypoint_1[15])
);



/*Picks layer to dump into filter*/
wire  filter_layer = (!keypoint_layer_1_empty) ? 0:1;

always @(posedge clk) begin
  if (!rst_n)
    is_keypoint_reg_0 <= 'd0;    
  else if (current_state==ST_DETECT && buffer_col==0) // Mask unwanted bits out
    is_keypoint_reg_0 <= is_keypoint_0 & 16'b1111_1111_0000_0000; // Masked bit would most probably be filtered by detect kp
  else if (current_state==ST_DETECT && buffer_col=='d39)
    is_keypoint_reg_0 <= is_keypoint_0 & 16'b0000_0000_1111_1111; 
  else if (current_state==ST_DETECT)
    is_keypoint_reg_0 <= is_keypoint_0;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && is_keypoint_reg_0[0]) 
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfffe;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!is_keypoint_reg_0[0] && is_keypoint_reg_0[1]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfffd;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[1:0]) && is_keypoint_reg_0[2]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfffb;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[2:0]) && is_keypoint_reg_0[3]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfff7;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[3:0]) && is_keypoint_reg_0[4]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hffef;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[4:0]) && is_keypoint_reg_0[5]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hffdf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[5:0]) && is_keypoint_reg_0[6]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hffbf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[6:0]) && is_keypoint_reg_0[7]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hff7f;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[7:0]) && is_keypoint_reg_0[8]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfeff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[8:0]) && is_keypoint_reg_0[9]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfdff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[9:0]) && is_keypoint_reg_0[10]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hfbff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[10:0]) && is_keypoint_reg_0[11]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hf7ff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[11:0]) && is_keypoint_reg_0[12]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hefff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[12:0]) && is_keypoint_reg_0[13]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hdfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[13:0]) && is_keypoint_reg_0[14]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'hbfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[14:0]) && is_keypoint_reg_0[15]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 16'h7fff;
  else if (current_state == ST_IDLE)
    is_keypoint_reg_0 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    is_keypoint_reg_1 <= 'd0;    
  else if (current_state == ST_DETECT) 
    is_keypoint_reg_1 <= is_keypoint_1;
  else if (current_state==ST_DETECT && buffer_col==0) // Mask unwanted bits out
    is_keypoint_reg_1 <= is_keypoint_1 & 16'b1111_1111_0000_0000; 
  else if (current_state==ST_DETECT && buffer_col=='d39)
    is_keypoint_reg_1 <= is_keypoint_1 & 16'b0000_0000_1111_1111; 
  else if (current_state==ST_DETECT)
    is_keypoint_reg_1 <= is_keypoint_1;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && is_keypoint_reg_1[0] ) 
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfffe;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!is_keypoint_reg_1[0] && is_keypoint_reg_1[1]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfffd;
    else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[1:0]) && is_keypoint_reg_1[2]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfffb;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[2:0]) && is_keypoint_reg_1[3]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfff7;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[3:0]) && is_keypoint_reg_1[4]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hffef;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[4:0]) && is_keypoint_reg_1[5]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hffdf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[5:0]) && is_keypoint_reg_1[6]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hffbf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[6:0]) && is_keypoint_reg_1[7]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hff7f;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[7:0]) && is_keypoint_reg_1[8]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfeff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[8:0]) && is_keypoint_reg_1[9]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfdff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[9:0]) && is_keypoint_reg_1[10]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hfbff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[10:0]) && is_keypoint_reg_1[11]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hf7ff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[11:0]) && is_keypoint_reg_1[12]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hefff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[12:0]) && is_keypoint_reg_1[13]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hdfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[13:0]) && is_keypoint_reg_1[14]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'hbfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[14:0]) && is_keypoint_reg_1[15]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 16'h7fff;
  else if (current_state == ST_IDLE)
    is_keypoint_reg_1 <= 'd0;
end

/* Generates Column Number of Current Pixel for Filter */
reg[9:0] filter_col; /*wire*/
always @(*) begin
  if (!keypoint_layer_1_empty&&is_keypoint_reg_0[0] || keypoint_layer_1_empty&&is_keypoint_reg_1[0])
    filter_col = current_col;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[0]) && is_keypoint_reg_0[1] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[0]) && is_keypoint_reg_1[1]) )
    filter_col = current_col + 1;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[1:0]) && is_keypoint_reg_0[2] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[1:0]) && is_keypoint_reg_1[2]) )
    filter_col = current_col + 2;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[2:0]) && is_keypoint_reg_0[3] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[2:0]) && is_keypoint_reg_1[3]) )
    filter_col = current_col + 3;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[3:0]) && is_keypoint_reg_0[4] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[3:0]) && is_keypoint_reg_1[4]) )
    filter_col = current_col + 4;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[4:0]) && is_keypoint_reg_0[5] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[4:0]) && is_keypoint_reg_1[5]) )
    filter_col = current_col + 5;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[5:0]) && is_keypoint_reg_0[6] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[5:0]) && is_keypoint_reg_1[6]) )
    filter_col = current_col + 6;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[6:0]) && is_keypoint_reg_0[7] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[6:0]) && is_keypoint_reg_1[7]) )
    filter_col = current_col + 7;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[7:0]) && is_keypoint_reg_0[8] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[7:0]) && is_keypoint_reg_1[8]) )
    filter_col = current_col + 8;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[8:0]) && is_keypoint_reg_0[9] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[8:0]) && is_keypoint_reg_1[9]) )
    filter_col = current_col + 9;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[9:0]) && is_keypoint_reg_0[10] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[9:0]) && is_keypoint_reg_1[10]) )
    filter_col = current_col + 10;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[10:0]) && is_keypoint_reg_0[11] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[10:0]) && is_keypoint_reg_1[11]) )
    filter_col = current_col + 11;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[11:0]) && is_keypoint_reg_0[12] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[11:0]) && is_keypoint_reg_1[12]) )
    filter_col = current_col + 12;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[12:0]) && is_keypoint_reg_0[13] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[12:0]) && is_keypoint_reg_1[13]) )
    filter_col = current_col + 13;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[13:0]) && is_keypoint_reg_0[14] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[13:0]) && is_keypoint_reg_1[14]) )
    filter_col = current_col + 14;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[14:0]) && is_keypoint_reg_0[15] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[14:0]) && is_keypoint_reg_1[15]) )
    filter_col = current_col + 15;
  else 
    filter_col = 0;
end


reg[175:0]    top_row,
              mid_row,
              btm_row;
wire          valid_keypoint;

always @(*) begin
  /*2 Keypoints*/
  if (current_state==ST_FILTER && !filter_layer) begin
    top_row = buffer_data_3;
    mid_row = buffer_data_2;
    btm_row = blur3x3_dout_buffer;
  end
  else if (current_state==ST_FILTER && filter_layer) begin
    top_row = buffer_data_5;
    mid_row = buffer_data_4;
    btm_row = blur5x5_1_dout_buffer;
  end
  else begin
    top_row = 0;
    mid_row = 0;
    btm_row = 0;
  end
end

filter_keypoint u_filter_keypoint(
  .current_col      (filter_col),
  .top_row          (top_row),
  .mid_row          (mid_row),
  .btm_row          (btm_row),
  .valid_keypoint   (valid_keypoint),
  .filter_threshold (filter_threshold)
);

/* MEMORY */

/*Addr. increment done when current_state==ST_DETECT*/
always @(posedge clk) begin
  if (!rst_n)
    keypoint_addr <= 'd0;
  else if (keypoint_we)
    keypoint_addr <= keypoint_addr + 'd1;
  else if (current_state==ST_IDLE)
    keypoint_addr <= 'd0;
end
/*
always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_addr <= 'd0;
  else if (keypoint_2_we)
    keypoint_2_addr <= keypoint_2_addr + 'd1;
  else if (current_state==ST_IDLE)
    keypoint_2_addr <= 'd0;
end*/

/*Mangement of Keypoint SRAM Overflow*/
wire  keypoint_full = (keypoint_addr == (MAX_KEYPOINT - 1)) ? 1 : 0;
// wire  keypoint_2_full = (keypoint_2_addr == (MAX_KEYPOINT - 1)) ? 1 : 0;

always @(posedge clk) begin
  if (!rst_n)
    keypoint_we <= 1'b0;
  else if (current_state==ST_NO_FILTER && !filter_on && (!keypoint_layer_1_empty || !keypoint_layer_2_empty) && !keypoint_full)
    keypoint_we <= 1'b1;
  else if (current_state==ST_FILTER && valid_keypoint && (!keypoint_layer_1_empty || !keypoint_layer_2_empty) && !keypoint_full)
    keypoint_we <= 1'b1;
  else
    keypoint_we <= 1'b0;
end

/*always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_we <= 1'b0;
  else if (current_state==ST_NO_FILTER && !filter_on && is_keypoint[1] && !keypoint_2_full)
    keypoint_2_we <= 1'b1;
  else if (current_state==ST_NO_FILTER && !filter_on && is_keypoint[0] && !keypoint_2_full && keypoint_1_full)
    keypoint_2_we <= 1'b1;
  else if (current_state==ST_FILTER && valid_keypoint[1] && is_keypoint[1] && !keypoint_2_full)
    keypoint_2_we <= 1'b1;
  else if (current_state==ST_FILTER && valid_keypoint[0] && is_keypoint[0] && !keypoint_2_full && keypoint_1_full)
    keypoint_2_we <= 1'b1;
  else
    keypoint_2_we <= 1'b0;
end*/
wire[8:0] img_addr_1 = img_addr - 1;
always @(posedge clk) begin
  if (!rst_n)
    keypoint_din <= 1'b0;
  else if (current_state==ST_NO_FILTER && !filter_on && (!keypoint_layer_1_empty || !keypoint_layer_2_empty))
    keypoint_din <= {filter_layer, img_addr_1, filter_col};
  else if (current_state==ST_FILTER && valid_keypoint && (!keypoint_layer_1_empty || !keypoint_layer_2_empty))
    keypoint_din <= {filter_layer, img_addr_1, filter_col};
end

/*always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_din <= 1'b0;
  else if (current_state==ST_NO_FILTER && !filter_on && is_keypoint[1])
    keypoint_2_din <= {img_addr - 1, current_col};
  else if (current_state==ST_FILTER && valid_keypoint[1] && is_keypoint[1])
    keypoint_2_din <= {img_addr - 1, current_col};
end*/


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
        next_state = ST_FIRST_COL;
      else
        next_state = ST_IDLE;
    end
    ST_FIRST_COL: begin
      if(next_col_count == 'd3)
        next_state = ST_PRE_DETECT;
      else
        next_state = ST_FIRST_COL;
    end
    ST_NEXT_COL: begin
      if(next_col_count == 'd3)
        next_state = ST_PRE_DETECT;
      else
        next_state = ST_NEXT_COL;
    end
    ST_DETECT: begin
      if((|is_keypoint_0 || |is_keypoint_1) && filter_on)
        next_state = ST_FILTER;
      else if(|is_keypoint_0 || |is_keypoint_1)
        next_state = ST_NO_FILTER;
      // else if(img_addr>'d473/*'d631*//*'d639*/)
        // next_state = ST_NEXT_COL;
      else if(!(|is_keypoint_0) && !(|is_keypoint_1))
        next_state = ST_BUFFER;
      else
        next_state = ST_DETECT;
    end
    ST_NO_FILTER: begin
      if(!keypoint_layer_1_empty || !keypoint_layer_2_empty)
        next_state = ST_NO_FILTER;
      // else if(img_addr > 'd473/*'d631*//*'d639*/)
        // next_state = ST_UPDATE;
      else if(/*img_addr<'d473*//*'d631*/  keypoint_layer_1_empty && keypoint_layer_2_empty /*'d639*/)
        next_state = ST_BUFFER;
      else 
        next_state = ST_NO_FILTER;
    end
    ST_FILTER: begin
      if(!keypoint_layer_1_empty || !keypoint_layer_2_empty)
        next_state = ST_FILTER;
      // else if(img_addr > 'd473/*current_col > 'd631*/)
        // next_state = ST_UPDATE;
      else if(/*current_col<'d631*//*img_addr<'d473 &&*/ keypoint_layer_1_empty && keypoint_layer_2_empty)
        next_state = ST_BUFFER;
      else 
        next_state = ST_FILTER;
    end
    
    ST_BUFFER: begin
      if(img_addr=='d472 && buffer_col=='d39)
        next_state = ST_IDLE;
      else if(img_addr=='d472/*'d631*//*'d639*/)
        next_state = ST_NEXT_COL;
      else if(current_state==ST_BUFFER)
        next_state = ST_PRE_DETECT;
      else
        next_state = ST_BUFFER;
    end
    ST_PRE_DETECT: begin
      if (current_state==ST_PRE_DETECT)
        next_state = ST_DETECT;
      else 
        next_state = ST_PRE_DETECT;
    end
    default:
      next_state = ST_IDLE;
  endcase
end

endmodule 