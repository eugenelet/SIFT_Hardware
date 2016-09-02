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
  keypoint_2_din
);
/*SYSTEM*/
input                 clk,
                      rst_n,
                      start;
output                done;

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
output reg    keypoint_1_we;
output reg    [10:0] keypoint_1_addr; /*2K Keypoints*/
output reg    [18:0] keypoint_1_din; /*ROW: 9 bit COL: 10 bit*/

output reg    keypoint_2_we;
output reg    [10:0] keypoint_2_addr; /*2K Keypoints*/
output reg    [18:0] keypoint_2_din; /*ROW: 9 bit COL: 10 bit*/

/*FSM*/
reg         [2:0] current_state,
                  next_state;

/*System State*/
/*Module FSM*/
parameter ST_IDLE   = 0,
          ST_READY  = 1,/*Idle 1 state for SRAM to get READY*/
          ST_DETECT = 2,
          ST_FILTER = 3,
          ST_UPDATE = 4,/*Grants a cycle to update MEM addr*/
          ST_BUFFER = 5;/*Grants buffer a cycle to update*/

assign done = (img_addr=='d480) ? 1 : 0;

assign buffer_we = ((start || current_state==ST_BUFFER) && 
  !(current_state==ST_UPDATE || current_state==ST_FILTER || current_state==ST_DETECT || current_state==ST_IDLE)) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_UPDATE) && img_addr<'d480) /*Needs new address every 2 cycles*/
    img_addr <= img_addr + 'd1;
  else if (done)
    img_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur3x3_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_UPDATE) && blur3x3_addr<'d480)
    blur3x3_addr <= blur3x3_addr + 'd1;
  else if (done)
    blur3x3_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_1_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_UPDATE) && blur5x5_1_addr<'d480)
    blur5x5_1_addr <= blur5x5_1_addr + 'd1;
  else if (done)
    blur5x5_1_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_2_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_UPDATE) && blur5x5_2_addr<'d480)
    blur5x5_2_addr <= blur5x5_2_addr + 'd1;
  else if (done)
    blur5x5_2_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur7x7_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_UPDATE) && blur7x7_addr<'d480)
    blur7x7_addr <= blur7x7_addr + 'd1;
  else if (done)
    blur7x7_addr <= 'd0;
end


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


wire   [637:0] is_keypoint[0:1];
detect_keypoint u_detect_keypoint_0(
  .top_0        (buffer_data_1),
  .top_1        (buffer_data_0),
  .top_2        (img_dout),
  .mid_0        (buffer_data_3),
  .mid_1        (buffer_data_2),
  .mid_2        (blur3x3_dout),
  .btm_0        (buffer_data_5),
  .btm_1        (buffer_data_4),
  .btm_2        (blur5x5_1_dout),
  .is_keypoint  (is_keypoint[0])
);

detect_keypoint u_detect_keypoint_1(
  .top_0        (buffer_data_5),
  .top_1        (buffer_data_4),
  .top_2        (blur5x5_1_dout),
  .mid_0        (buffer_data_7),
  .mid_1        (buffer_data_6),
  .mid_2        (blur5x5_2_dout),
  .btm_0        (buffer_data_9),
  .btm_1        (buffer_data_8),
  .btm_2        (blur7x7_dout),
  .is_keypoint  (is_keypoint[1])
);

wire  [23:0]    filter_input_0[0:2];
wire  [23:0]    filter_input_1[0:2];
wire  [1:0]     no_keypoint;
wire  [18:0]    current_RowCol[0:1];
/*prepare_filter u_prepare_filter(
  .clk            (clk),
  .rst_n          (rst_n),
  .current_state  (current_state),
  .img_addr       (img_addr),
  .filter_input_0_0 (filter_input_0[0]),
  .filter_input_0_1 (filter_input_0[1]),
  .filter_input_0_2 (filter_input_0[2]),
  .filter_input_1_0 (filter_input_1[0]),
  .filter_input_1_1 (filter_input_1[1]),
  .filter_input_1_2 (filter_input_1[2]),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .buffer_data_5  (buffer_data_5),
  .blur3x3_dout   (blur3x3_dout),
  .blur5x5_1_dout (blur5x5_1_dout),
  .no_keypoint    (no_keypoint),
  .is_keypoint_0  (is_keypoint[0]),
  .is_keypoint_1  (is_keypoint[1]),
  .current_RowCol_0 (current_RowCol[0]),
  .current_RowCol_1 (current_RowCol[1])
);
*/
wire  [1:0] valid_keypoint;
/*filter_keypoint u_filter_keypoint_0(
  .filter_input_0 (filter_input_0[0]),
  .filter_input_1 (filter_input_0[1]),
  .filter_input_2 (filter_input_0[2]),
  .valid_keypoint (valid_keypoint[0])
);

filter_keypoint u_filter_keypoint_1(
  .filter_input_0 (filter_input_1[0]),
  .filter_input_1 (filter_input_1[1]),
  .filter_input_2 (filter_input_1[2]),
  .valid_keypoint (valid_keypoint[1])
);*/


/*Addr. increment done when current_state==ST_DETECT*/
always @(posedge clk) begin
  if (!rst_n)
    keypoint_1_addr <= 'd0;
  else if (keypoint_1_we)
    keypoint_1_addr <= keypoint_1_addr + 'd1;
  else if (current_state==ST_IDLE)
    keypoint_1_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_addr <= 'd0;
  else if (keypoint_2_we)
    keypoint_2_addr <= keypoint_2_addr + 'd1;
  else if (current_state==ST_IDLE)
    keypoint_2_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_1_we <= 1'b0;
  else if (current_state==ST_FILTER && !no_keypoint[0] && valid_keypoint[0])
    keypoint_1_we <= 1'b1;
  else if (no_keypoint[0])
    keypoint_1_we <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_we <= 1'b0;
  else if (current_state==ST_FILTER && !no_keypoint[1] && valid_keypoint[1])
    keypoint_2_we <= 1'b1;
  else if (no_keypoint[1])
    keypoint_2_we <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_1_din <= 1'b0;
  else if (current_state==ST_FILTER && !no_keypoint[0] && valid_keypoint[0])
    keypoint_1_din <= current_RowCol[0];
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_din <= 1'b0;
  else if (current_state==ST_FILTER && !no_keypoint[1] && valid_keypoint[1])
    keypoint_2_din <= current_RowCol[1];
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
      if(current_state==ST_DETECT)
        next_state = ST_FILTER;
      else
        next_state = ST_DETECT;
    end
    ST_FILTER: begin
      if(no_keypoint[0] && no_keypoint[1])
        next_state = ST_UPDATE;
      else 
        next_state = ST_FILTER;
    end
    ST_UPDATE: begin
      if(current_state==ST_UPDATE && img_addr!='d479)
        next_state = ST_BUFFER;
      else if(img_addr == 'd479)
        next_state = ST_IDLE;
      else
        next_state = ST_UPDATE;
    end
    ST_BUFFER: begin
      if(current_state==ST_BUFFER)
        next_state = ST_READY;
      else
        next_state = ST_BUFFER;
    end
    default:
      next_state = ST_IDLE;
  endcase
end

endmodule 