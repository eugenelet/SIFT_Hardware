`timescale 1ns/10ps
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
                      rst_n
                      start,
                      done;

/*To line Buffer*/
output               buffer_we;

/*BUFFER IN*/
input      [5119:0]  buffer_data_0;
input      [5119:0]  buffer_data_1;
input      [5119:0]  buffer_data_2;
input      [5119:0]  buffer_data_3;
input      [5119:0]  buffer_data_4;
input      [5119:0]  buffer_data_5;
input      [5119:0]  buffer_data_6;
input      [5119:0]  buffer_data_7;
input      [5119:0]  buffer_data_8;
input      [5119:0]  buffer_data_9;

/*From SRAM (Used with Buffer)*/
input      [5119:0]  img_dout;
input      [5119:0]  blur3x3_dout;
input      [5119:0]  blur5x5_1_dout;
input      [5119:0]  blur5x5_2_dout;
input      [5119:0]  blur7x7_dout;

/*To Keypoint SRAM*/
output reg    keypoint_1_we;
output reg    [10:0] keypoint_1_addr; /*2K Keypoints*/
output reg    [20:0] keypoint_1_din; /*ROW: 9 bit COL: 10 bit*/

output reg    keypoint_2_we;
output reg    [10:0] keypoint_2_addr; /*2K Keypoints*/
output reg    [20:0] keypoint_2_din; /*ROW: 9 bit COL: 10 bit*/

/*FSM*/
reg         [2:0] current_state,
                  next_state;

/*System State*/
/*Module FSM*/
parameter ST_IDLE   = 0,
          ST_READY  = 1,/*Idle 1 state for SRAM to get READY*/
          ST_DETECT = 2,
          ST_FILTER = 3;

assign buffer_we = ((start || current_state==ST_FILTER) && !(current_state==ST_DETECT || current_state==ST_IDLE)) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_DETECT) && img_addr<'d480) /*Needs new address every 2 cycles*/
    img_addr <= img_addr + 'd1;
  else if (done)
    img_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur3x3_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_DETECT) && blur3x3_addr<'d480)
    blur3x3_addr <= blur3x3_addr + 'd1;
  else if (done)
    blur3x3_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_1_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_DETECT) && blur5x5_1_addr<'d480)
    blur5x5_1_addr <= blur5x5_1_addr + 'd1;
  else if (done)
    blur5x5_1_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur5x5_2_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_DETECT) && blur5x5_2_addr<'d480)
    blur5x5_2_addr <= blur5x5_2_addr + 'd1;
  else if (done)
    blur5x5_2_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    blur7x7_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || current_state==ST_DETECT) && blur7x7_addr<'d480)
    blur7x7_addr <= blur7x7_addr + 'd1;
  else if (done)
    blur7x7_addr <= 'd0;
end


/*Module DONE, inform SYSTEM*/
always @(posedge clk) begin
  if (!rst_n)
    done <= 1'b0;    
  else if (current_state==ST_DETECT && keypoint_1_addr=='d2000)
    done <= 1'b1;
  else if (current_state==ST_IDLE)
    done <= 1'b0;
end

/*Addr. increment done when current_state==ST_DETECT*/
always @(posedge clk) begin
  if (!rst_n)
    keypoint_1_addr <= 'd0;
  else if (keypoint_1_we && keypoint_1_addr<'d2000)
    keypoint_1_addr <= keypoint_1_addr + 'd1;
  else if (current_state==ST_IDLE)
    keypoint_1_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_addr <= 'd0;
  else if (keypoint_2_we && keypoint_2_addr<'d2000)
    keypoint_2_addr <= keypoint_2_addr + 'd1;
  else if (current_state==ST_IDLE)
    keypoint_2_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_1_we <= 1'b0;
  else if (current_state==ST_FILTER && keypoint_1_addr<'d2000)
    keypoint_1_we <= 1'b1;
  else if (keypoint_1_addr=='d2000 || current_state==ST_IDLE || current_state==ST_DETECT)
    keypoint_1_we <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    keypoint_2_we <= 1'b0;
  else if (current_state==ST_FILTER && keypoint_2_addr<'d2000)
    keypoint_2_we <= 1'b1;
  else if (keypoint_2_addr=='d2000 || current_state==ST_IDLE || current_state==ST_DETECT)
    keypoint_2_we <= 1'b0;
end


reg [1:0]    ready_start_relay;
always @(posedge clk) begin
  if (!rst_n) 
    ready_start_relay <= 1'b0;
  else if (current_state == ST_READY)
    ready_start_relay <= ready_start_relay + 1; 
  else if (current_state == ST_IDLE)
    ready_start_relay <= 1'b0;
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
        next_state = ST_IDLE
    end
    ST_READY: begin
      if(ready_start_relay == 'd2)
        next_state = ST_DETECT;
      else
        next_state = ST_READY;
    end
    ST_DETECT: begin
      if(current_state==ST_DETECT)
        next_state = ST_FILTER;
      else if(keypoint_1_addr=='d2000)
        next_state = ST_IDLE;
      else
        next_state = ST_DETECT;
    end
    ST_FILTER: begin
      if(current_state==ST_FILTER)
        next_state = ST_DETECT;
      else 
        next_state = ST_FILTER;
    end
    default:
      next_state = ST_IDLE;
  endcase
end

endmodule 