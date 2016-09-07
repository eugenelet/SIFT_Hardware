`timescale 1ns/10ps
module Line_Buffer_10(
  clk,
  rst_n,
  buffer_mode,
  buffer_we,
  img_data,
  fill_zero,
  blur_data_0,
  blur_data_1,
  blur_data_2,
  blur_data_3,
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
input       [5119:0]  blur_data_0;
input       [5119:0]  blur_data_1;
input       [5119:0]  blur_data_2;
input       [5119:0]  blur_data_3;
/*From Working Module*/
input       [2:0]     buffer_mode;
input                 buffer_we;
input                 fill_zero;

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

/*System State*/
parameter         SYS_IDLE          = 0,
                  SYS_GAUSSIAN      = 1,
                  SYS_DETECT_FILTER = 2,
                  SYS_COMPUTE_MATCH = 3,
                  SYS_END           = 4; //FOR DEBUG





always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_0 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_0 <= 'd0;
  else if (buffer_mode==SYS_GAUSSIAN && buffer_we)
    buffer_data_0 <= img_data;
  else if (buffer_mode==SYS_GAUSSIAN && fill_zero)
    buffer_data_0 <= 'd0;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_0 <= img_data;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_1 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_1 <= 'd0;
  else if (buffer_mode==SYS_GAUSSIAN && buffer_we)
    buffer_data_1 <= buffer_data_0;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_1 <= buffer_data_0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_2 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_2 <= 'd0;
  else if (buffer_mode==SYS_GAUSSIAN && buffer_we)
    buffer_data_2 <= buffer_data_1;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_2 <= blur_data_0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_3 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_3 <= 'd0;
  else if (buffer_mode==SYS_GAUSSIAN && buffer_we)
    buffer_data_3 <= buffer_data_2;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_3 <= buffer_data_2;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_4 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_4 <= 'd0;
  else if (buffer_mode==SYS_GAUSSIAN && buffer_we)
    buffer_data_4 <= buffer_data_3;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_4 <= blur_data_1;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_5 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_5 <= 'd0;
  else if (buffer_mode==SYS_GAUSSIAN && buffer_we)
    buffer_data_5 <= buffer_data_4;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_5 <= buffer_data_4;
end


always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_6 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_6 <= 'd0;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_6 <= blur_data_2;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_7 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_7 <= 'd0;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_7 <= buffer_data_6;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_8 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_8 <= 'd0;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_8 <= blur_data_3;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_9 <= 'd0;    
  else if (buffer_mode==SYS_IDLE)
    buffer_data_9 <= 'd0;
  else if (buffer_mode==SYS_DETECT_FILTER && buffer_we)
    buffer_data_9 <= buffer_data_8;
end


endmodule 