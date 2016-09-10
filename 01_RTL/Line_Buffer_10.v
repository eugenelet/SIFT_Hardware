`timescale 1ns/10ps
module Line_Buffer_10(
  clk,
  rst_n,
  buffer_mode,
  buffer_we,
  fill_zero,
  in_data0,
  in_data1,
  in_data2,
  in_data3,
  in_data4,
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
input       [5119:0]  in_data0;
input       [5119:0]  in_data1;
input       [5119:0]  in_data2;
input       [5119:0]  in_data3;
input       [5119:0]  in_data4;
/*From Working Module*/
input                 buffer_mode; /*0: 10 regs as a group   1: 5 groups, 2 each*/
input                 buffer_we;
input                 fill_zero; /*Used in Gaussian blur & Match*/

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


always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_0 <= 'd0;
  else if (!buffer_mode && fill_zero)
    buffer_data_0 <= 'd0;
  else if (!buffer_mode && buffer_we)
    buffer_data_0 <= in_data0;
  else if (buffer_mode && buffer_we)
    buffer_data_0 <= in_data0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_1 <= 'd0; 
  else if (buffer_we)
    buffer_data_1 <= buffer_data_0;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_2 <= 'd0;    
  else if (!buffer_mode && buffer_we)
    buffer_data_2 <= buffer_data_1;
  else if (buffer_mode && buffer_we)
    buffer_data_2 <= in_data1;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_3 <= 'd0;    
  else if (buffer_we)
    buffer_data_3 <= buffer_data_2;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_4 <= 'd0;    
  else if (!buffer_mode && buffer_we)
    buffer_data_4 <= buffer_data_3;
  else if (buffer_mode && buffer_we)
    buffer_data_4 <= in_data2;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_5 <= 'd0;    
  else if (buffer_we)
    buffer_data_5 <= buffer_data_4;
end


always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_6 <= 'd0;    
  else if (!buffer_mode && buffer_we)
    buffer_data_6 <= buffer_data_5;
  else if (buffer_mode && buffer_we)
    buffer_data_6 <= in_data3;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_7 <= 'd0;    
  else if (buffer_we)
    buffer_data_7 <= buffer_data_6;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_8 <= 'd0;    
  else if (!buffer_mode && buffer_we)
    buffer_data_8 <= buffer_data_7;
  else if (buffer_mode && buffer_we)
    buffer_data_8 <= in_data4;
end

always @(posedge clk) begin
  if (!rst_n) 
    buffer_data_9 <= 'd0;    
  else if (buffer_we)
    buffer_data_9 <= buffer_data_8;
end


endmodule 