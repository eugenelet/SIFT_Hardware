`timescale 1ns/10ps
module Line_Buffer_10(
  clk,
  rst_n,
  buffer_mode,
  buffer_we,
  img_data,
  buffer_data_0,
  buffer_data_1,
  buffer_data_2,
  buffer_data_3,
  buffer_data_4,
  buffer_data_5,
  buffer_data_6,
  buffer_data_7,
  buffer_data_8,
  buffer_data_9
);
/*SYSTEM*/
input                 clk,
                      rst_n;

/*From SRAM*/
input       [5119:0]  img_data;

/*From Working Module*/
input       [2:0]     buffer_mode;
input                 buffer_we;

/*BUFFER OUT*/
output reg  [5119:0]  buffer_data_0;
output reg  [5119:0]  buffer_data_1;
output reg  [5119:0]  buffer_data_2;
output reg  [5119:0]  buffer_data_3;
output reg  [5119:0]  buffer_data_4;
output reg  [5119:0]  buffer_data_5;
output reg  [5119:0]  buffer_data_6;
output reg  [5119:0]  buffer_data_7;
output reg  [5119:0]  buffer_data_8;
output reg  [5119:0]  buffer_data_9;

/*FSM*/
reg         [2:0] current_state,
                  next_state;

/*System State*/
parameter         SYS_IDLE       = 0,
                  SYS_GAUSSIAN   = 1,
                  SYS_DETECT_KP  = 2,
                  SYS_FILTER_KP  = 3,
                  SYS_MATCH      = 4,
                  SYS_END        = 5; //FOR DEBUG

/*Module State*/
parameter         ST_IDLE             = 0,
                  ST_GAUSSIAN_START   = 1;




always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_0 <= 'd0;    
  else if (current_state==ST_IDLE && !buffer_we)
    buffer_data_0 <= 'd0;
  else if (current_state==ST_GAUSSIAN_START && buffer_we)
    buffer_data_0 <= img_data;
  else if (current_state==ST_GAUSSIAN_START && !buffer_we)
    buffer_data_0 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_1 <= 'd0;    
  else if (current_state==ST_IDLE)
    buffer_data_1 <= 'd0;
  else if (current_state==ST_GAUSSIAN_START)
    buffer_data_1 <= buffer_data_0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_2 <= 'd0;    
  else if (current_state==ST_IDLE)
    buffer_data_2 <= 'd0;
  else if (current_state==ST_GAUSSIAN_START)
    buffer_data_2 <= buffer_data_1;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_3 <= 'd0;    
  else if (current_state==ST_IDLE)
    buffer_data_3 <= 'd0;
  else if (current_state==ST_GAUSSIAN_START)
    buffer_data_3 <= buffer_data_2;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_4 <= 'd0;    
  else if (current_state==ST_IDLE)
    buffer_data_4 <= 'd0;
  else if (current_state==ST_GAUSSIAN_START)
    buffer_data_4 <= buffer_data_3;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_5 <= 'd0;    
  else if (current_state==ST_IDLE)
    buffer_data_5 <= 'd0;
  else if (current_state==ST_GAUSSIAN_START)
    buffer_data_5 <= buffer_data_4;
end


always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_6 <= 'd0;    
  else if (current_state == ST_IDLE)
    buffer_data_6 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_7 <= 'd0;    
  else if (current_state == ST_IDLE)
    buffer_data_7 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_8 <= 'd0;    
  else if (current_state == ST_IDLE)
    buffer_data_8 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_9 <= 'd0;    
  else if (current_state == ST_IDLE)
    buffer_data_9 <= 'd0;
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
      if(buffer_mode==SYS_GAUSSIAN)
        next_state = ST_GAUSSIAN_START;
      else
        next_state = ST_IDLE;
    end
    ST_GAUSSIAN_START: begin
      if(buffer_mode != SYS_GAUSSIAN)
        next_state = ST_IDLE;
      else
        next_state = ST_GAUSSIAN_START;
    end
    default:
      next_state = ST_IDLE;
  endcase
end

endmodule 