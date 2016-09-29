`timescale 1ns/10ps
`include "prepare_filter.v"
`include "filter_keypoint.v"
`include "detect_keypoint.v"
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
  keypoint_1_we,
  keypoint_1_addr,
  keypoint_1_din,
  keypoint_2_we,
  keypoint_2_addr,
  keypoint_2_din,
  filter_on,
  filter_threshold
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

/*BUFFER IN*/
input      [5119:0]  buffer_data_0,
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
          ST_READY      = 1,/*Idle 1 state for SRAM to get READY*/
          ST_DETECT     = 2,
          ST_NO_FILTER  = 3,
          ST_FILTER     = 4,
          ST_UPDATE     = 5,/*Grants a cycle to update MEM addr*/
          ST_BUFFER     = 6;/*Grants buffer a cycle to update*/

assign done = (img_addr=='d480) ? 1 : 0;

/*Provide 2 Cycle for READY STATE*/
reg     ready_start_relay;
always @(posedge clk) begin
  if (!rst_n) 
    ready_start_relay <= 1'b0;
  else if (current_state == ST_READY)
    ready_start_relay <= 1'b1; 
  else if (current_state == ST_IDLE)
    ready_start_relay <= 1'b0;
end


assign buffer_we = ((current_state==ST_READY && start) || current_state==ST_BUFFER) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd7;/*'d0;*/
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) ||  current_state==ST_UPDATE) && img_addr<'d472/*'d480*/) /*Needs new address every 2 cycles*/
    img_addr <= img_addr + 'd1;
  else if (done)
    img_addr <= 'd7;/*'d0;*/
end

always @(posedge clk) begin
  if (!rst_n) 
    blur3x3_addr <= 'd7;    
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) ||  current_state==ST_UPDATE) && blur3x3_addr<'d472)
    blur3x3_addr <= blur3x3_addr + 'd1;
  else if (done)
    blur3x3_addr <= 'd7;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_1_addr <= 'd7;    
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) ||  current_state==ST_UPDATE) && blur5x5_1_addr<'d472)
    blur5x5_1_addr <= blur5x5_1_addr + 'd1;
  else if (done)
    blur5x5_1_addr <= 'd7;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_2_addr <= 'd7;    
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) ||  current_state==ST_UPDATE) && blur5x5_2_addr<'d472)
    blur5x5_2_addr <= blur5x5_2_addr + 'd1;
  else if (done)
    blur5x5_2_addr <= 'd7;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur7x7_addr <= 'd7;    
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) ||  current_state==ST_UPDATE) && blur7x7_addr<'d472)
    blur7x7_addr <= blur7x7_addr + 'd1;
  else if (done)
    blur7x7_addr <= 'd7;
end




/*Counter for current column*/
reg   [9:0] current_col;
wire   [63:0] is_keypoint_0;
wire   [63:0] is_keypoint_1;
detect_keypoint u_detect_keypoint_0_0(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 0),
  .is_keypoint      (is_keypoint_0[0])
);
detect_keypoint u_detect_keypoint_0_1(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 1),
  .is_keypoint      (is_keypoint_0[1])
);
detect_keypoint u_detect_keypoint_0_2(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 2),
  .is_keypoint      (is_keypoint_0[2])
);
detect_keypoint u_detect_keypoint_0_3(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 3),
  .is_keypoint      (is_keypoint_0[3])
);
detect_keypoint u_detect_keypoint_0_4(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 4),
  .is_keypoint      (is_keypoint_0[4])
);
detect_keypoint u_detect_keypoint_0_5(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 5),
  .is_keypoint      (is_keypoint_0[5])
);
detect_keypoint u_detect_keypoint_0_6(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 6),
  .is_keypoint      (is_keypoint_0[6])
);
detect_keypoint u_detect_keypoint_0_7(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 7),
  .is_keypoint      (is_keypoint_0[7])
);
detect_keypoint u_detect_keypoint_0_8(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 8),
  .is_keypoint      (is_keypoint_0[8])
);
detect_keypoint u_detect_keypoint_0_9(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 9),
  .is_keypoint      (is_keypoint_0[9])
);
detect_keypoint u_detect_keypoint_0_10(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 10),
  .is_keypoint      (is_keypoint_0[10])
);
detect_keypoint u_detect_keypoint_0_11(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 11),
  .is_keypoint      (is_keypoint_0[11])
);
detect_keypoint u_detect_keypoint_0_12(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 12),
  .is_keypoint      (is_keypoint_0[12])
);
detect_keypoint u_detect_keypoint_0_13(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 13),
  .is_keypoint      (is_keypoint_0[13])
);
detect_keypoint u_detect_keypoint_0_14(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 14),
  .is_keypoint      (is_keypoint_0[14])
);
detect_keypoint u_detect_keypoint_0_15(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 15),
  .is_keypoint      (is_keypoint_0[15])
);
detect_keypoint u_detect_keypoint_0_16(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 16),
  .is_keypoint      (is_keypoint_0[16])
);
detect_keypoint u_detect_keypoint_0_17(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 17),
  .is_keypoint      (is_keypoint_0[17])
);
detect_keypoint u_detect_keypoint_0_18(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 18),
  .is_keypoint      (is_keypoint_0[18])
);
detect_keypoint u_detect_keypoint_0_19(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 19),
  .is_keypoint      (is_keypoint_0[19])
);
detect_keypoint u_detect_keypoint_0_20(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 20),
  .is_keypoint      (is_keypoint_0[20])
);
detect_keypoint u_detect_keypoint_0_21(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 21),
  .is_keypoint      (is_keypoint_0[21])
);
detect_keypoint u_detect_keypoint_0_22(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 22),
  .is_keypoint      (is_keypoint_0[22])
);
detect_keypoint u_detect_keypoint_0_23(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 23),
  .is_keypoint      (is_keypoint_0[23])
);
detect_keypoint u_detect_keypoint_0_24(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 24),
  .is_keypoint      (is_keypoint_0[24])
);
detect_keypoint u_detect_keypoint_0_25(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 25),
  .is_keypoint      (is_keypoint_0[25])
);
detect_keypoint u_detect_keypoint_0_26(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 26),
  .is_keypoint      (is_keypoint_0[26])
);
detect_keypoint u_detect_keypoint_0_27(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 27),
  .is_keypoint      (is_keypoint_0[27])
);
detect_keypoint u_detect_keypoint_0_28(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 28),
  .is_keypoint      (is_keypoint_0[28])
);
detect_keypoint u_detect_keypoint_0_29(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 29),
  .is_keypoint      (is_keypoint_0[29])
);
detect_keypoint u_detect_keypoint_0_30(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 30),
  .is_keypoint      (is_keypoint_0[30])
);
detect_keypoint u_detect_keypoint_0_31(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 31),
  .is_keypoint      (is_keypoint_0[31])
);
detect_keypoint u_detect_keypoint_0_32(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 32),
  .is_keypoint      (is_keypoint_0[32])
);
detect_keypoint u_detect_keypoint_0_33(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 33),
  .is_keypoint      (is_keypoint_0[33])
);
detect_keypoint u_detect_keypoint_0_34(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 34),
  .is_keypoint      (is_keypoint_0[34])
);
detect_keypoint u_detect_keypoint_0_35(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 35),
  .is_keypoint      (is_keypoint_0[35])
);
detect_keypoint u_detect_keypoint_0_36(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 36),
  .is_keypoint      (is_keypoint_0[36])
);
detect_keypoint u_detect_keypoint_0_37(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 37),
  .is_keypoint      (is_keypoint_0[37])
);
detect_keypoint u_detect_keypoint_0_38(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 38),
  .is_keypoint      (is_keypoint_0[38])
);
detect_keypoint u_detect_keypoint_0_39(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 39),
  .is_keypoint      (is_keypoint_0[39])
);
detect_keypoint u_detect_keypoint_0_40(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 40),
  .is_keypoint      (is_keypoint_0[40])
);
detect_keypoint u_detect_keypoint_0_41(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 41),
  .is_keypoint      (is_keypoint_0[41])
);
detect_keypoint u_detect_keypoint_0_42(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 42),
  .is_keypoint      (is_keypoint_0[42])
);
detect_keypoint u_detect_keypoint_0_43(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 43),
  .is_keypoint      (is_keypoint_0[43])
);
detect_keypoint u_detect_keypoint_0_44(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 44),
  .is_keypoint      (is_keypoint_0[44])
);
detect_keypoint u_detect_keypoint_0_45(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 45),
  .is_keypoint      (is_keypoint_0[45])
);
detect_keypoint u_detect_keypoint_0_46(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 46),
  .is_keypoint      (is_keypoint_0[46])
);
detect_keypoint u_detect_keypoint_0_47(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 47),
  .is_keypoint      (is_keypoint_0[47])
);
detect_keypoint u_detect_keypoint_0_48(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 48),
  .is_keypoint      (is_keypoint_0[48])
);
detect_keypoint u_detect_keypoint_0_49(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 49),
  .is_keypoint      (is_keypoint_0[49])
);
detect_keypoint u_detect_keypoint_0_50(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 50),
  .is_keypoint      (is_keypoint_0[50])
);
detect_keypoint u_detect_keypoint_0_51(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 51),
  .is_keypoint      (is_keypoint_0[51])
);
detect_keypoint u_detect_keypoint_0_52(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 52),
  .is_keypoint      (is_keypoint_0[52])
);
detect_keypoint u_detect_keypoint_0_53(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 53),
  .is_keypoint      (is_keypoint_0[53])
);
detect_keypoint u_detect_keypoint_0_54(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 54),
  .is_keypoint      (is_keypoint_0[54])
);
detect_keypoint u_detect_keypoint_0_55(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 55),
  .is_keypoint      (is_keypoint_0[55])
);
detect_keypoint u_detect_keypoint_0_56(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 56),
  .is_keypoint      (is_keypoint_0[56])
);
detect_keypoint u_detect_keypoint_0_57(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 57),
  .is_keypoint      (is_keypoint_0[57])
);
detect_keypoint u_detect_keypoint_0_58(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 58),
  .is_keypoint      (is_keypoint_0[58])
);
detect_keypoint u_detect_keypoint_0_59(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 59),
  .is_keypoint      (is_keypoint_0[59])
);
detect_keypoint u_detect_keypoint_0_60(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 60),
  .is_keypoint      (is_keypoint_0[60])
);
detect_keypoint u_detect_keypoint_0_61(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 61),
  .is_keypoint      (is_keypoint_0[61])
);
detect_keypoint u_detect_keypoint_0_62(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 62),
  .is_keypoint      (is_keypoint_0[62])
);
detect_keypoint u_detect_keypoint_0_63(
  .layer_0_0        (buffer_data_1),
  .layer_0_1        (buffer_data_0),
  .layer_0_2        (img_dout),
  .layer_1_0        (buffer_data_3),
  .layer_1_1        (buffer_data_2),
  .layer_1_2        (blur3x3_dout),
  .layer_2_0        (buffer_data_5),
  .layer_2_1        (buffer_data_4),
  .layer_2_2        (blur5x5_1_dout),
  .layer_3_0        (buffer_data_7),
  .layer_3_1        (buffer_data_6),
  .layer_3_2        (blur5x5_2_dout),
  .current_col      (current_col + 63),
  .is_keypoint      (is_keypoint_0[63])
);

detect_keypoint u_detect_keypoint_1_0(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 0),
  .is_keypoint      (is_keypoint_1[0])
);
detect_keypoint u_detect_keypoint_1_1(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 1),
  .is_keypoint      (is_keypoint_1[1])
);
detect_keypoint u_detect_keypoint_1_2(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 2),
  .is_keypoint      (is_keypoint_1[2])
);
detect_keypoint u_detect_keypoint_1_3(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 3),
  .is_keypoint      (is_keypoint_1[3])
);
detect_keypoint u_detect_keypoint_1_4(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 4),
  .is_keypoint      (is_keypoint_1[4])
);
detect_keypoint u_detect_keypoint_1_5(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 5),
  .is_keypoint      (is_keypoint_1[5])
);
detect_keypoint u_detect_keypoint_1_6(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 6),
  .is_keypoint      (is_keypoint_1[6])
);
detect_keypoint u_detect_keypoint_1_7(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 7),
  .is_keypoint      (is_keypoint_1[7])
);
detect_keypoint u_detect_keypoint_1_8(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 8),
  .is_keypoint      (is_keypoint_1[8])
);
detect_keypoint u_detect_keypoint_1_9(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 9),
  .is_keypoint      (is_keypoint_1[9])
);
detect_keypoint u_detect_keypoint_1_10(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 10),
  .is_keypoint      (is_keypoint_1[10])
);
detect_keypoint u_detect_keypoint_1_11(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 11),
  .is_keypoint      (is_keypoint_1[11])
);
detect_keypoint u_detect_keypoint_1_12(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 12),
  .is_keypoint      (is_keypoint_1[12])
);
detect_keypoint u_detect_keypoint_1_13(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 13),
  .is_keypoint      (is_keypoint_1[13])
);
detect_keypoint u_detect_keypoint_1_14(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 14),
  .is_keypoint      (is_keypoint_1[14])
);
detect_keypoint u_detect_keypoint_1_15(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 15),
  .is_keypoint      (is_keypoint_1[15])
);
detect_keypoint u_detect_keypoint_1_16(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 16),
  .is_keypoint      (is_keypoint_1[16])
);
detect_keypoint u_detect_keypoint_1_17(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 17),
  .is_keypoint      (is_keypoint_1[17])
);
detect_keypoint u_detect_keypoint_1_18(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 18),
  .is_keypoint      (is_keypoint_1[18])
);
detect_keypoint u_detect_keypoint_1_19(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 19),
  .is_keypoint      (is_keypoint_1[19])
);
detect_keypoint u_detect_keypoint_1_20(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 20),
  .is_keypoint      (is_keypoint_1[20])
);
detect_keypoint u_detect_keypoint_1_21(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 21),
  .is_keypoint      (is_keypoint_1[21])
);
detect_keypoint u_detect_keypoint_1_22(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 22),
  .is_keypoint      (is_keypoint_1[22])
);
detect_keypoint u_detect_keypoint_1_23(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 23),
  .is_keypoint      (is_keypoint_1[23])
);
detect_keypoint u_detect_keypoint_1_24(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 24),
  .is_keypoint      (is_keypoint_1[24])
);
detect_keypoint u_detect_keypoint_1_25(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 25),
  .is_keypoint      (is_keypoint_1[25])
);
detect_keypoint u_detect_keypoint_1_26(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 26),
  .is_keypoint      (is_keypoint_1[26])
);
detect_keypoint u_detect_keypoint_1_27(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 27),
  .is_keypoint      (is_keypoint_1[27])
);
detect_keypoint u_detect_keypoint_1_28(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 28),
  .is_keypoint      (is_keypoint_1[28])
);
detect_keypoint u_detect_keypoint_1_29(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 29),
  .is_keypoint      (is_keypoint_1[29])
);
detect_keypoint u_detect_keypoint_1_30(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 30),
  .is_keypoint      (is_keypoint_1[30])
);
detect_keypoint u_detect_keypoint_1_31(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 31),
  .is_keypoint      (is_keypoint_1[31])
);
detect_keypoint u_detect_keypoint_1_32(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 32),
  .is_keypoint      (is_keypoint_1[32])
);
detect_keypoint u_detect_keypoint_1_33(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 33),
  .is_keypoint      (is_keypoint_1[33])
);
detect_keypoint u_detect_keypoint_1_34(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 34),
  .is_keypoint      (is_keypoint_1[34])
);
detect_keypoint u_detect_keypoint_1_35(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 35),
  .is_keypoint      (is_keypoint_1[35])
);
detect_keypoint u_detect_keypoint_1_36(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 36),
  .is_keypoint      (is_keypoint_1[36])
);
detect_keypoint u_detect_keypoint_1_37(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 37),
  .is_keypoint      (is_keypoint_1[37])
);
detect_keypoint u_detect_keypoint_1_38(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 38),
  .is_keypoint      (is_keypoint_1[38])
);
detect_keypoint u_detect_keypoint_1_39(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 39),
  .is_keypoint      (is_keypoint_1[39])
);
detect_keypoint u_detect_keypoint_1_40(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 40),
  .is_keypoint      (is_keypoint_1[40])
);
detect_keypoint u_detect_keypoint_1_41(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 41),
  .is_keypoint      (is_keypoint_1[41])
);
detect_keypoint u_detect_keypoint_1_42(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 42),
  .is_keypoint      (is_keypoint_1[42])
);
detect_keypoint u_detect_keypoint_1_43(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 43),
  .is_keypoint      (is_keypoint_1[43])
);
detect_keypoint u_detect_keypoint_1_44(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 44),
  .is_keypoint      (is_keypoint_1[44])
);
detect_keypoint u_detect_keypoint_1_45(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 45),
  .is_keypoint      (is_keypoint_1[45])
);
detect_keypoint u_detect_keypoint_1_46(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 46),
  .is_keypoint      (is_keypoint_1[46])
);
detect_keypoint u_detect_keypoint_1_47(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 47),
  .is_keypoint      (is_keypoint_1[47])
);
detect_keypoint u_detect_keypoint_1_48(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 48),
  .is_keypoint      (is_keypoint_1[48])
);
detect_keypoint u_detect_keypoint_1_49(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 49),
  .is_keypoint      (is_keypoint_1[49])
);
detect_keypoint u_detect_keypoint_1_50(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 50),
  .is_keypoint      (is_keypoint_1[50])
);
detect_keypoint u_detect_keypoint_1_51(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 51),
  .is_keypoint      (is_keypoint_1[51])
);
detect_keypoint u_detect_keypoint_1_52(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 52),
  .is_keypoint      (is_keypoint_1[52])
);
detect_keypoint u_detect_keypoint_1_53(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 53),
  .is_keypoint      (is_keypoint_1[53])
);
detect_keypoint u_detect_keypoint_1_54(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 54),
  .is_keypoint      (is_keypoint_1[54])
);
detect_keypoint u_detect_keypoint_1_55(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 55),
  .is_keypoint      (is_keypoint_1[55])
);
detect_keypoint u_detect_keypoint_1_56(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 56),
  .is_keypoint      (is_keypoint_1[56])
);
detect_keypoint u_detect_keypoint_1_57(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 57),
  .is_keypoint      (is_keypoint_1[57])
);
detect_keypoint u_detect_keypoint_1_58(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 58),
  .is_keypoint      (is_keypoint_1[58])
);
detect_keypoint u_detect_keypoint_1_59(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 59),
  .is_keypoint      (is_keypoint_1[59])
);
detect_keypoint u_detect_keypoint_1_60(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 60),
  .is_keypoint      (is_keypoint_1[60])
);
detect_keypoint u_detect_keypoint_1_61(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 61),
  .is_keypoint      (is_keypoint_1[61])
);
detect_keypoint u_detect_keypoint_1_62(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 62),
  .is_keypoint      (is_keypoint_1[62])
);
detect_keypoint u_detect_keypoint_1_63(
  .layer_0_0        (buffer_data_3),
  .layer_0_1        (buffer_data_2),
  .layer_0_2        (blur3x3_dout),
  .layer_1_0        (buffer_data_5),
  .layer_1_1        (buffer_data_4),
  .layer_1_2        (blur5x5_1_dout),
  .layer_2_0        (buffer_data_7),
  .layer_2_1        (buffer_data_6),
  .layer_2_2        (blur5x5_2_dout),
  .layer_3_0        (buffer_data_9),
  .layer_3_1        (buffer_data_8),
  .layer_3_2        (blur7x7_dout),
  .current_col      (current_col + 63),
  .is_keypoint      (is_keypoint_1[63])
);


reg[63:0] is_keypoint_reg_0;
reg[63:0] is_keypoint_reg_1;

wire  keypoint_layer_1_empty = !(|is_keypoint_reg_0) ? 1:0;
wire  keypoint_layer_2_empty = !(|is_keypoint_reg_1) ? 1:0;

/*Picks layer to dump into filter*/
wire  filter_layer = (!keypoint_layer_1_empty) ? 0:1;

always @(posedge clk) begin
  if (!rst_n)
    is_keypoint_reg_0 <= 'd0;    
  else if (current_state == ST_DETECT) 
    is_keypoint_reg_0 <= is_keypoint_0;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && is_keypoint_reg_0[0]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffffe;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!is_keypoint_reg_0[0] && is_keypoint_reg_0[1]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffffd;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[1:0]) && is_keypoint_reg_0[2]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffffb;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[2:0]) && is_keypoint_reg_0[3]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffff7;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[3:0]) && is_keypoint_reg_0[4]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffffef;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[4:0]) && is_keypoint_reg_0[5]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffffdf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[5:0]) && is_keypoint_reg_0[6]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffffbf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[6:0]) && is_keypoint_reg_0[7]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffff7f;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[7:0]) && is_keypoint_reg_0[8]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffeff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[8:0]) && is_keypoint_reg_0[9]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffdff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[9:0]) && is_keypoint_reg_0[10]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffffbff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[10:0]) && is_keypoint_reg_0[11]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffff7ff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[11:0]) && is_keypoint_reg_0[12]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffefff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[12:0]) && is_keypoint_reg_0[13]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffdfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[13:0]) && is_keypoint_reg_0[14]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffffbfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[14:0]) && is_keypoint_reg_0[15]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffff7fff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[15:0]) && is_keypoint_reg_0[16]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffeffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[16:0]) && is_keypoint_reg_0[17]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffdffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[17:0]) && is_keypoint_reg_0[18]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffffbffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[18:0]) && is_keypoint_reg_0[19]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffff7ffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[19:0]) && is_keypoint_reg_0[20]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffefffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[20:0]) && is_keypoint_reg_0[21]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffdfffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[21:0]) && is_keypoint_reg_0[22]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffffbfffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[22:0]) && is_keypoint_reg_0[23]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffff7fffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[23:0]) && is_keypoint_reg_0[24]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffeffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[24:0]) && is_keypoint_reg_0[25]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffdffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[25:0]) && is_keypoint_reg_0[26]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffffbffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[26:0]) && is_keypoint_reg_0[27]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffff7ffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[27:0]) && is_keypoint_reg_0[28]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffefffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[28:0]) && is_keypoint_reg_0[29]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffdfffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[29:0]) && is_keypoint_reg_0[30]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffffbfffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[30:0]) && is_keypoint_reg_0[31]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffff7fffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[31:0]) && is_keypoint_reg_0[32]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffeffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[32:0]) && is_keypoint_reg_0[33]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffdffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[33:0]) && is_keypoint_reg_0[34]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffffbffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[34:0]) && is_keypoint_reg_0[35]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffff7ffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[35:0]) && is_keypoint_reg_0[36]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffefffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[36:0]) && is_keypoint_reg_0[37]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffdfffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[37:0]) && is_keypoint_reg_0[38]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffffbfffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[38:0]) && is_keypoint_reg_0[39]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffff7fffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[39:0]) && is_keypoint_reg_0[40]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffeffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[40:0]) && is_keypoint_reg_0[41]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffdffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[41:0]) && is_keypoint_reg_0[42]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffffbffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[42:0]) && is_keypoint_reg_0[43]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffff7ffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[43:0]) && is_keypoint_reg_0[44]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffefffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[44:0]) && is_keypoint_reg_0[45]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffdfffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[45:0]) && is_keypoint_reg_0[46]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffffbfffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[46:0]) && is_keypoint_reg_0[47]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffff7fffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[47:0]) && is_keypoint_reg_0[48]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffeffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[48:0]) && is_keypoint_reg_0[49]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffdffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[49:0]) && is_keypoint_reg_0[50]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfffbffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[50:0]) && is_keypoint_reg_0[51]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfff7ffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[51:0]) && is_keypoint_reg_0[52]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffefffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[52:0]) && is_keypoint_reg_0[53]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffdfffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[53:0]) && is_keypoint_reg_0[54]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hffbfffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[54:0]) && is_keypoint_reg_0[55]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hff7fffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[55:0]) && is_keypoint_reg_0[56]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfeffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[56:0]) && is_keypoint_reg_0[57]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfdffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[57:0]) && is_keypoint_reg_0[58]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hfbffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[58:0]) && is_keypoint_reg_0[59]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hf7ffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[59:0]) && is_keypoint_reg_0[60]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hefffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[60:0]) && is_keypoint_reg_0[61]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hdfffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[61:0]) && is_keypoint_reg_0[62]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'hbfffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && !filter_layer && (!(|is_keypoint_reg_0[62:0]) && is_keypoint_reg_0[63]) )
    is_keypoint_reg_0 <= is_keypoint_reg_0 & 64'h7fffffffffffffff;
  else if (current_state == ST_IDLE)
    is_keypoint_reg_0 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    is_keypoint_reg_1 <= 'd0;    
  else if (current_state == ST_DETECT) 
    is_keypoint_reg_1 <= is_keypoint_1;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && is_keypoint_reg_1[0] ) 
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffffe;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!is_keypoint_reg_1[0] && is_keypoint_reg_1[1]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffffd;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[1:0]) && is_keypoint_reg_1[2]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffffb;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[2:0]) && is_keypoint_reg_1[3]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffff7;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[3:0]) && is_keypoint_reg_1[4]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffffef;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[4:0]) && is_keypoint_reg_1[5]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffffdf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[5:0]) && is_keypoint_reg_1[6]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffffbf;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[6:0]) && is_keypoint_reg_1[7]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffff7f;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[7:0]) && is_keypoint_reg_1[8]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffeff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[8:0]) && is_keypoint_reg_1[9]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffdff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[9:0]) && is_keypoint_reg_1[10]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffffbff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[10:0]) && is_keypoint_reg_1[11]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffff7ff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[11:0]) && is_keypoint_reg_1[12]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffefff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[12:0]) && is_keypoint_reg_1[13]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffdfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[13:0]) && is_keypoint_reg_1[14]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffffbfff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[14:0]) && is_keypoint_reg_1[15]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffff7fff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[15:0]) && is_keypoint_reg_1[16]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffeffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[16:0]) && is_keypoint_reg_1[17]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffdffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[17:0]) && is_keypoint_reg_1[18]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffffbffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[18:0]) && is_keypoint_reg_1[19]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffff7ffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[19:0]) && is_keypoint_reg_1[20]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffefffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[20:0]) && is_keypoint_reg_1[21]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffdfffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[21:0]) && is_keypoint_reg_1[22]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffffbfffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[22:0]) && is_keypoint_reg_1[23]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffff7fffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[23:0]) && is_keypoint_reg_1[24]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffeffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[24:0]) && is_keypoint_reg_1[25]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffdffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[25:0]) && is_keypoint_reg_1[26]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffffbffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[26:0]) && is_keypoint_reg_1[27]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffff7ffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[27:0]) && is_keypoint_reg_1[28]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffefffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[28:0]) && is_keypoint_reg_1[29]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffdfffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[29:0]) && is_keypoint_reg_1[30]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffffbfffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[30:0]) && is_keypoint_reg_1[31]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffff7fffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[31:0]) && is_keypoint_reg_1[32]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffeffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[32:0]) && is_keypoint_reg_1[33]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffdffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[33:0]) && is_keypoint_reg_1[34]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffffbffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[34:0]) && is_keypoint_reg_1[35]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffff7ffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[35:0]) && is_keypoint_reg_1[36]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffefffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[36:0]) && is_keypoint_reg_1[37]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffdfffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[37:0]) && is_keypoint_reg_1[38]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffffbfffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[38:0]) && is_keypoint_reg_1[39]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffff7fffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[39:0]) && is_keypoint_reg_1[40]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffeffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[40:0]) && is_keypoint_reg_1[41]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffdffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[41:0]) && is_keypoint_reg_1[42]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffffbffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[42:0]) && is_keypoint_reg_1[43]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffff7ffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[43:0]) && is_keypoint_reg_1[44]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffefffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[44:0]) && is_keypoint_reg_1[45]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffdfffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[45:0]) && is_keypoint_reg_1[46]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffffbfffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[46:0]) && is_keypoint_reg_1[47]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffff7fffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[47:0]) && is_keypoint_reg_1[48]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffeffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[48:0]) && is_keypoint_reg_1[49]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffdffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[49:0]) && is_keypoint_reg_1[50]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfffbffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[50:0]) && is_keypoint_reg_1[51]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfff7ffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[51:0]) && is_keypoint_reg_1[52]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffefffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[52:0]) && is_keypoint_reg_1[53]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffdfffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[53:0]) && is_keypoint_reg_1[54]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hffbfffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[54:0]) && is_keypoint_reg_1[55]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hff7fffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[55:0]) && is_keypoint_reg_1[56]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfeffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[56:0]) && is_keypoint_reg_1[57]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfdffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[57:0]) && is_keypoint_reg_1[58]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hfbffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[58:0]) && is_keypoint_reg_1[59]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hf7ffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[59:0]) && is_keypoint_reg_1[60]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hefffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[60:0]) && is_keypoint_reg_1[61]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hdfffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[61:0]) && is_keypoint_reg_1[62]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'hbfffffffffffffff;
  else if ( (current_state==ST_FILTER || current_state==ST_NO_FILTER) && filter_layer && (!(|is_keypoint_reg_1[62:0]) && is_keypoint_reg_1[63]) )
    is_keypoint_reg_1 <= is_keypoint_reg_1 & 64'h7fffffffffffffff;
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
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[15:0]) && is_keypoint_reg_0[16] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[15:0]) && is_keypoint_reg_1[16]) )
    filter_col = current_col + 16;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[16:0]) && is_keypoint_reg_0[17] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[16:0]) && is_keypoint_reg_1[17]) )
    filter_col = current_col + 17;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[17:0]) && is_keypoint_reg_0[18] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[17:0]) && is_keypoint_reg_1[18]) )
    filter_col = current_col + 18;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[18:0]) && is_keypoint_reg_0[19] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[18:0]) && is_keypoint_reg_1[19]) )
    filter_col = current_col + 19;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[19:0]) && is_keypoint_reg_0[20] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[19:0]) && is_keypoint_reg_1[20]) )
    filter_col = current_col + 20;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[20:0]) && is_keypoint_reg_0[21] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[20:0]) && is_keypoint_reg_1[21]) )
    filter_col = current_col + 21;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[21:0]) && is_keypoint_reg_0[22] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[21:0]) && is_keypoint_reg_1[22]) )
    filter_col = current_col + 22;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[22:0]) && is_keypoint_reg_0[23] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[22:0]) && is_keypoint_reg_1[23]) )
    filter_col = current_col + 23;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[23:0]) && is_keypoint_reg_0[24] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[23:0]) && is_keypoint_reg_1[24]) )
    filter_col = current_col + 24;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[24:0]) && is_keypoint_reg_0[25] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[24:0]) && is_keypoint_reg_1[25]) )
    filter_col = current_col + 25;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[25:0]) && is_keypoint_reg_0[26] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[25:0]) && is_keypoint_reg_1[26]) )
    filter_col = current_col + 26;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[26:0]) && is_keypoint_reg_0[27] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[26:0]) && is_keypoint_reg_1[27]) )
    filter_col = current_col + 27;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[27:0]) && is_keypoint_reg_0[28] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[27:0]) && is_keypoint_reg_1[28]) )
    filter_col = current_col + 28;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[28:0]) && is_keypoint_reg_0[29] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[28:0]) && is_keypoint_reg_1[29]) )
    filter_col = current_col + 29;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[29:0]) && is_keypoint_reg_0[30] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[29:0]) && is_keypoint_reg_1[30]) )
    filter_col = current_col + 30;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[30:0]) && is_keypoint_reg_0[31] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[30:0]) && is_keypoint_reg_1[31]) )
    filter_col = current_col + 31;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[31:0]) && is_keypoint_reg_0[32] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[31:0]) && is_keypoint_reg_1[32]) )
    filter_col = current_col + 32;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[32:0]) && is_keypoint_reg_0[33] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[32:0]) && is_keypoint_reg_1[33]) )
    filter_col = current_col + 33;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[33:0]) && is_keypoint_reg_0[34] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[33:0]) && is_keypoint_reg_1[34]) )
    filter_col = current_col + 34;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[34:0]) && is_keypoint_reg_0[35] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[34:0]) && is_keypoint_reg_1[35]) )
    filter_col = current_col + 35;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[35:0]) && is_keypoint_reg_0[36] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[35:0]) && is_keypoint_reg_1[36]) )
    filter_col = current_col + 36;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[36:0]) && is_keypoint_reg_0[37] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[36:0]) && is_keypoint_reg_1[37]) )
    filter_col = current_col + 37;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[37:0]) && is_keypoint_reg_0[38] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[37:0]) && is_keypoint_reg_1[38]) )
    filter_col = current_col + 38;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[38:0]) && is_keypoint_reg_0[39] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[38:0]) && is_keypoint_reg_1[39]) )
    filter_col = current_col + 39;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[39:0]) && is_keypoint_reg_0[40] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[39:0]) && is_keypoint_reg_1[40]) )
    filter_col = current_col + 40;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[40:0]) && is_keypoint_reg_0[41] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[40:0]) && is_keypoint_reg_1[41]) )
    filter_col = current_col + 41;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[41:0]) && is_keypoint_reg_0[42] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[41:0]) && is_keypoint_reg_1[42]) )
    filter_col = current_col + 42;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[42:0]) && is_keypoint_reg_0[43] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[42:0]) && is_keypoint_reg_1[43]) )
    filter_col = current_col + 43;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[43:0]) && is_keypoint_reg_0[44] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[43:0]) && is_keypoint_reg_1[44]) )
    filter_col = current_col + 44;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[44:0]) && is_keypoint_reg_0[45] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[44:0]) && is_keypoint_reg_1[45]) )
    filter_col = current_col + 45;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[45:0]) && is_keypoint_reg_0[46] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[45:0]) && is_keypoint_reg_1[46]) )
    filter_col = current_col + 46;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[46:0]) && is_keypoint_reg_0[47] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[46:0]) && is_keypoint_reg_1[47]) )
    filter_col = current_col + 47;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[47:0]) && is_keypoint_reg_0[48] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[47:0]) && is_keypoint_reg_1[48]) )
    filter_col = current_col + 48;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[48:0]) && is_keypoint_reg_0[49] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[48:0]) && is_keypoint_reg_1[49]) )
    filter_col = current_col + 49;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[49:0]) && is_keypoint_reg_0[50] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[49:0]) && is_keypoint_reg_1[50]) )
    filter_col = current_col + 50;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[50:0]) && is_keypoint_reg_0[51] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[50:0]) && is_keypoint_reg_1[51]) )
    filter_col = current_col + 51;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[51:0]) && is_keypoint_reg_0[52] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[51:0]) && is_keypoint_reg_1[52]) )
    filter_col = current_col + 52;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[52:0]) && is_keypoint_reg_0[53] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[52:0]) && is_keypoint_reg_1[53]) )
    filter_col = current_col + 53;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[53:0]) && is_keypoint_reg_0[54] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[53:0]) && is_keypoint_reg_1[54]) )
    filter_col = current_col + 54;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[54:0]) && is_keypoint_reg_0[55] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[54:0]) && is_keypoint_reg_1[55]) )
    filter_col = current_col + 55;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[55:0]) && is_keypoint_reg_0[56] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[55:0]) && is_keypoint_reg_1[56]) )
    filter_col = current_col + 56;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[56:0]) && is_keypoint_reg_0[57] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[56:0]) && is_keypoint_reg_1[57]) )
    filter_col = current_col + 57;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[57:0]) && is_keypoint_reg_0[58] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[57:0]) && is_keypoint_reg_1[58]) )
    filter_col = current_col + 58;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[58:0]) && is_keypoint_reg_0[59] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[58:0]) && is_keypoint_reg_1[59]) )
    filter_col = current_col + 59;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[59:0]) && is_keypoint_reg_0[60] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[59:0]) && is_keypoint_reg_1[60]) )
    filter_col = current_col + 60;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[60:0]) && is_keypoint_reg_0[61] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[60:0]) && is_keypoint_reg_1[61]) )
    filter_col = current_col + 61;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[61:0]) && is_keypoint_reg_0[62] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[61:0]) && is_keypoint_reg_1[62]) )
    filter_col = current_col + 62;
  else if (!keypoint_layer_1_empty&&(!(|is_keypoint_reg_0[62:0]) && is_keypoint_reg_0[63] ) ||
     keypoint_layer_1_empty&&(!(|is_keypoint_reg_1[62:0]) && is_keypoint_reg_1[63]) )
    filter_col = current_col + 63;
  else 
    filter_col = 0;
end

/* Scheduling of Keypoints */

/*reg[1:0]  keypoint_count;
always @(posedge clk) begin
  if (!rst_n) 
    keypoint_count <= 0;    
  else if (current_state==ST_DETECT) 
    keypoint_count <= is_keypoint[0] + is_keypoint[1];
  else if (current_state==ST_UPDATE)
    keypoint_count <= 0;
end

reg[1:0] filter_count;
always @(posedge clk) begin
  if (!rst_n) 
    filter_count <= 0;    
  else if (current_state==ST_FILTER && filter_count<keypoint_count) 
    filter_count <= filter_count + 1;
  else if (current_state==ST_UPDATE || current_state==ST_DETECT)
    filter_count <= 0;
end*/


always @(posedge clk) begin
  if (!rst_n) 
    current_col <= 'd8;    
  else if (  (current_state==ST_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_NO_FILTER && keypoint_layer_1_empty && keypoint_layer_2_empty) ||
             (current_state==ST_DETECT && keypoint_layer_1_empty && keypoint_layer_2_empty) && /*if no keypoints found*/
             current_col < 'd631/*'d639*/) 
    current_col <= current_col + 'd64;
  else if (current_state==ST_UPDATE || current_state==ST_IDLE)
    current_col <= 'd8;
end

reg[5119:0]   top_row,
              mid_row,
              btm_row;
wire          valid_keypoint;

always @(*) begin
  /*2 Keypoints*/
  if (current_state==ST_FILTER && !filter_layer) begin
    top_row = buffer_data_3;
    mid_row = buffer_data_2;
    btm_row = blur3x3_dout;
  end
  else if (current_state==ST_FILTER && filter_layer) begin
    top_row = buffer_data_5;
    mid_row = buffer_data_4;
    btm_row = blur5x5_1_dout;
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

always @(posedge clk) begin
  if (!rst_n)
    keypoint_din <= 1'b0;
  else if (current_state==ST_NO_FILTER && !filter_on && (!keypoint_layer_1_empty || !keypoint_layer_2_empty))
    keypoint_din <= {filter_layer, img_addr - 1, filter_col};
  else if (current_state==ST_FILTER && valid_keypoint && (!keypoint_layer_1_empty || !keypoint_layer_2_empty))
    keypoint_din <= {filter_layer, img_addr - 1, filter_col};
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
        next_state = ST_READY;
      else
        next_state = ST_IDLE;
    end
    ST_READY: begin
      if(ready_start_relay)
        next_state = ST_DETECT;
      else
        next_state = ST_READY;
    end
    ST_DETECT: begin
      if((|is_keypoint_0 || |is_keypoint_1) && filter_on)
        next_state = ST_FILTER;
      else if(|is_keypoint_0 || |is_keypoint_1)
        next_state = ST_NO_FILTER;
      else if(current_col>'d631/*'d639*/)
        next_state = ST_UPDATE;
      else
        next_state = ST_DETECT;
    end
    ST_NO_FILTER: begin
      if(!keypoint_layer_1_empty && !keypoint_layer_2_empty)
        next_state = ST_NO_FILTER;
      else if(current_col > 'd631/*'d639*/)
        next_state = ST_UPDATE;
      else if(current_col<'d631 && keypoint_layer_1_empty && keypoint_layer_2_empty /*'d639*/)
        next_state = ST_DETECT;
      else 
        next_state = ST_NO_FILTER;
    end
    ST_FILTER: begin
      if(!keypoint_layer_1_empty && !keypoint_layer_2_empty)
        next_state = ST_FILTER;
      else if(current_col > 'd631)
        next_state = ST_UPDATE;
      else if(current_col<'d631 && keypoint_layer_1_empty && keypoint_layer_2_empty)
        next_state = ST_DETECT;
      else 
        next_state = ST_FILTER;
    end
    ST_UPDATE: begin
      if(current_state==ST_UPDATE && img_addr!='d472/*'d479*/)
        next_state = ST_BUFFER;
      else if(img_addr == 'd472/*'d479*/)
        next_state = ST_IDLE;
      else
        next_state = ST_UPDATE;
    end
    ST_BUFFER: begin
      if(current_state==ST_BUFFER)
        next_state = ST_DETECT;
      else
        next_state = ST_BUFFER;
    end
    default:
      next_state = ST_IDLE;
  endcase
end

endmodule 