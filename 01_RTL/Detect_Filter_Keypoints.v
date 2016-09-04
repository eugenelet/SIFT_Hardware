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

assign buffer_we = ((current_state==ST_READY && start) || current_state==ST_BUFFER) ? 1:0;

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

/*Counter for current column*/
reg   [9:0] current_col;
wire   [1:0] is_keypoint;
always @(posedge clk) begin
  if (!rst_n) 
    current_col <= 'd1;    
  else if ((current_state==ST_FILTER || (current_state==ST_DETECT && !(|is_keypoint))) && current_col < 'd639) /*if no keypoints found*/
    current_col <= current_col + 1;
  else if (current_state==ST_UPDATE || current_state==ST_IDLE)
    current_col <= 'd1;
end


detect_keypoint u_detect_keypoint_0(
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
  .current_col      (current_col),
  .is_keypoint      (is_keypoint[0])
);


detect_keypoint u_detect_keypoint_1(
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
  .current_col      (current_col),
  .is_keypoint      (is_keypoint[1])
);


reg [12:0] dog_addr_0;
always @(posedge clk ) begin
  if (!rst_n)
    dog_addr_0 <= 0;
  else if (current_state==ST_DETECT && is_keypoint[0])
    dog_addr_0 <= dog_addr_0 + 1;
end
reg [12:0] dog_addr_0;
always @(posedge clk ) begin
  if (!rst_n)
    dog_addr_1 <= 0;
  else if (current_state==ST_DETECT && is_keypoint[0])
    dog_addr_1 <= dog_addr_1 + 1;
end

reg [18:0] dog_results_0[0:5000];
always @(posedge clk ) begin
  if (!rst_n)
    dog_results_0[dog_addr_0] <= 0;
  else if (current_state==ST_DETECT && is_keypoint[0])
    dog_results_0[dog_addr_0] <= {img_addr, current_col};
end
reg [18:0] dog_results_1[0:5000];
always @(posedge clk ) begin
  if (!rst_n)
    dog_results_1[dog_addr_1] <= 0;
  else if (current_state==ST_DETECT && is_keypoint[0])
    dog_results_1[dog_addr_1] <= {img_addr, current_col};
end
wire  [1:0] valid_keypoint;
filter_keypoint u_filter_keypoint_0(
  .current_col    (current_col),
  .top_row        (buffer_data_3),
  .mid_row        (buffer_data_2),
  .btm_row        (blur3x3_dout),
  .valid_keypoint (valid_keypoint[0])
);

filter_keypoint u_filter_keypoint_1(
  .current_col    (current_col),
  .top_row        (buffer_data_5),
  .mid_row        (buffer_data_4),
  .btm_row        (blur5x5_1_dout),
  .valid_keypoint (valid_keypoint[1])
);


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
  else if (current_state==ST_FILTER && valid_keypoint[0])
    keypoint_1_we <= 1'b1;
  else
    keypoint_1_we <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_we <= 1'b0;
  else if (current_state==ST_FILTER && valid_keypoint[1])
    keypoint_2_we <= 1'b1;
  else
    keypoint_2_we <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_1_din <= 1'b0;
  else if (current_state==ST_FILTER && valid_keypoint[0])
    keypoint_1_din <= {img_addr, current_col};
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_din <= 1'b0;
  else if (current_state==ST_FILTER && valid_keypoint[1])
    keypoint_2_din <= {img_addr, current_col};
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
      if(|is_keypoint)
        next_state = ST_FILTER;
      else if(current_col=='d639)
        next_state = ST_UPDATE;
      else
        next_state = ST_DETECT;
    end
    ST_FILTER: begin
      if(current_col == 'd639)
        next_state = ST_UPDATE;
      else if(current_col < 'd639)
        next_state = ST_DETECT;
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
        next_state = ST_DETECT;
      else
        next_state = ST_BUFFER;
    end
    default:
      next_state = ST_IDLE;
  endcase
end

endmodule 