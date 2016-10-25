`timescale 1ns/10ps
`include  "Gaussian_Blur_3x3.v"
`include  "Gaussian_Blur_5x5_0.v"
`include  "Gaussian_Blur_5x5_1.v"
`include  "Gaussian_Blur_7x7.v"
module Gaussian_Blur(
  clk,
  rst_n,
  start,
  done,
  img_dout,
  buffer_data_0,
  buffer_data_1,
  buffer_data_2,
  buffer_data_3,
  buffer_data_4,
  buffer_data_5,
  buffer_data_6,
  blur_mem_we_0,
  blur_mem_we_1,
  blur_mem_we_2,
  blur_mem_we_3,
  blur_addr_w_0,
  blur_addr_w_1,
  blur_addr_w_2,
  blur_addr_w_3,
  blur_addr_r_0,
  blur_addr_r_1,
  blur_addr_r_2,
  blur_addr_r_3,
  blur_din_0,
  blur_din_1,
  blur_din_2,
  blur_din_3,
  blur_dout_0,
  blur_dout_1,
  blur_dout_2,
  blur_dout_3,
  img_addr,
  buffer_we,
  fill_zero,
  current_col
);


/*SYSTEM*/
input                 clk,
                      rst_n,
                      start;
output reg            done;
output                buffer_we;


/*LINE BUFFER*/
input       [5119:0]  img_dout;
input       [175:0]   buffer_data_0;
input       [175:0]   buffer_data_1;
input       [175:0]   buffer_data_2;
input       [175:0]   buffer_data_3;
input       [175:0]   buffer_data_4;
input       [175:0]   buffer_data_5;
input       [175:0]   buffer_data_6;
output  reg           fill_zero;

/*Image SRAM Control*/
output reg  [8:0]     img_addr;


/*BLUR SRAM Control*/
output reg  [5119:0]  blur_din_0,
                      blur_din_1,
                      blur_din_2,
                      blur_din_3;
input       [5119:0]  blur_dout_0,
                      blur_dout_1,
                      blur_dout_2,
                      blur_dout_3;
output reg  [8:0]     blur_addr_r_0,
                      blur_addr_r_1,
                      blur_addr_r_2,
                      blur_addr_r_3,
                      blur_addr_w_0,
                      blur_addr_w_1,
                      blur_addr_w_2,
                      blur_addr_w_3;

output reg            blur_mem_we_0,
                      blur_mem_we_1,
                      blur_mem_we_2,
                      blur_mem_we_3;

/*Sends the current working column to LB*/
output reg[5:0]       current_col;

/*Kernel Q0.18 (We take last 6 decimal digits for simplicity (<262144))*/
// reg       [95:0]  G_Kernel_3x3  [0:1];
// reg       [89:0]  G_Kernel_5x5_0[0:2];
// reg       [89:0]  G_Kernel_5x5_1[0:2];
// reg       [125:0] G_Kernel_7x7  [0:3];

/*Module FSM*/
parameter ST_IDLE        = 0,
          ST_READY       = 1,/*Idle 1 state for SRAM to get READY*/
          ST_FIRST_COL   = 2,/*Needed for column count to remain at 0 for first column*/
          ST_NEXT_COL    = 3,
          ST_NEXT_ROW    = 4;
          // ST_GAUSSIAN_0  = 2,
          // ST_GAUSSIAN_1  = 3,
          // ST_GAUSSIAN_2  = 4,
          // ST_GAUSSIAN_3  = 5,
          // ST_GAUSSIAN_4  = 6,
          // ST_GAUSSIAN_5  = 7,
          // ST_GAUSSIAN_6  = 8,
          // ST_GAUSSIAN_7  = 9,
          // ST_GAUSSIAN_8  = 10,
          // ST_GAUSSIAN_9  = 11;

reg     [3:0] current_state,
              next_state;

/*Switches column after every row of current column is processed*/
reg[1:0]     col_relay;
always @(posedge clk) begin
  if (!rst_n) 
    col_relay <= 1'b0;
  else if ((current_state==ST_NEXT_COL || current_state==ST_FIRST_COL) && col_relay < 2)
    col_relay <= col_relay + 1; 
  else if (current_state==ST_IDLE || current_state==ST_NEXT_ROW)
    col_relay <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    current_col <= 'd0;    
  else if (current_state==ST_IDLE || current_state==ST_FIRST_COL)
    current_col <= 'd0;
  else if (current_state==ST_NEXT_COL && col_relay==2) 
    current_col <= current_col + 1;
end

/*Fill zeros at the end of row
 *    addr     addr   fill
 *     479     480     1
 *-----------------------------------
 *                    LB      LB
 *                    479     0
 *    ___     ___     ___     ___     
 *  _|   \___|   \___|   \___|   \___
 */
always @(posedge clk) begin
  if (!rst_n) 
    fill_zero <= 1'b0;    
  else if (img_addr=='d480)
    fill_zero <= 1'b1;
  else
    fill_zero <= 1'b0;
end

/*Update buffer with data from SRAM (Consumes 2 cycle [addr0 and addr1])*/
assign buffer_we = (((current_state==ST_NEXT_COL || current_state==ST_FIRST_COL) && col_relay>0) 
  || (current_state==ST_NEXT_ROW && img_addr<'d480) ) ? 1:0;

/*Update Image SRAM addr*/
always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd0;    
  // to allow the condition below apply
  // img_addr will be > 0 right after NEXT_COL
  else if (current_state==ST_NEXT_COL || current_state==ST_FIRST_COL || (current_state==ST_NEXT_ROW && img_addr<'d480 && img_addr>0) )
    img_addr <= img_addr + 'd1;                                                                         
  else if (current_state==ST_NEXT_ROW && blur_addr_w_3=='d480)
    img_addr <= 'd0;
  else if (done || current_state==ST_IDLE)
    img_addr <= 'd0;
end

/*Module DONE, inform SYSTEM*/
always @(posedge clk) begin
  if (!rst_n)
    done <= 1'b0;    
  else if (current_state==ST_NEXT_ROW && blur_addr_w_3=='d480 && current_col=='d39)
    done <= 1'b1;
  else if (current_state==ST_IDLE)
    done <= 1'b0;
end

/*Needs a 3 cycle delay from READ to WRITE
 * Cycle 1: addr. 0 -> FF
 * Cycle 2: SRAM internal Delay
 * Cycle 3: concat blur SRAM dout with Gaussian Result
 */
/*reg[8:0] blur_addr_relay_0[0:3];
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_0[0] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_0[0] <= blur_addr_r_0;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_0[1] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_0[1] <= blur_addr_relay_0[0];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_0[2] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_0[2] <= blur_addr_relay_0[1];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_0[3] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_0[3] <= blur_addr_relay_0[2];
end

reg[8:0] blur_addr_relay_1[0:3];
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_1[0] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_1[0] <= blur_addr_r_1;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_1[1] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_1[1] <= blur_addr_relay_1[0];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_1[2] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_1[2] <= blur_addr_relay_1[1];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_1[3] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_1[3] <= blur_addr_relay_1[2];
end

reg[8:0] blur_addr_relay_2[0:3];
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_2[0] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_2[0] <= blur_addr_r_2;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_2[1] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_2[1] <= blur_addr_relay_2[0];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_2[2] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_2[2] <= blur_addr_relay_2[1];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_2[3] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_2[3] <= blur_addr_relay_2[2];
end

reg[8:0] blur_addr_relay_3[0:3];
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_3[0] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_3[0] <= blur_addr_r_3;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_3[1] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_3[1] <= blur_addr_relay_3[0];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_3[2] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_3[2] <= blur_addr_relay_3[1];
end
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_relay_3[3] <= 'd0;    
  else if (current_state==ST_NEXT_ROW) 
    blur_addr_relay_3[3] <= blur_addr_relay_3[2];
end*/

/*Addr. and WE of Blur SRAM for writing data into*/
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_w_0 <= 'd0;
  else if (blur_mem_we_0 && blur_addr_w_0<'d480)
    blur_addr_w_0 <= blur_addr_w_0 + 1; //blur_addr_relay_0[3];
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_w_0 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_w_1 <= 'd0;
  else if (blur_mem_we_1 && blur_addr_w_1<'d480)
    blur_addr_w_1 <= blur_addr_w_1 + 1;//blur_addr_relay_1[3];
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_w_1 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_w_2 <= 'd0;
  else if (blur_mem_we_2 && blur_addr_w_2<'d480)
    blur_addr_w_2 <= blur_addr_w_2 + 1;//blur_addr_relay_2[3];
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_w_2 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_w_3 <= 'd0;
  else if (blur_mem_we_3 && blur_addr_w_3<'d480)
    blur_addr_w_3 <= blur_addr_w_3 + 1;//blur_addr_relay_3[3];
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_w_3 <= 'd0;
end

/*Counter for blur SRAM WE*/
reg[2:0]  blur_mem_we_ctr;
always @(posedge clk) begin
  if (!rst_n) 
    blur_mem_we_ctr <= 'd0;    
  else if (current_state==ST_NEXT_ROW && blur_mem_we_ctr<'d5) 
    blur_mem_we_ctr <= blur_mem_we_ctr + 1;
  else if (current_state==ST_NEXT_COL)
    blur_mem_we_ctr <= 'd0;
end

/*Enable blur_mem_we once ctr reaches 3 (2 lines in LB)*/
always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_0 <= 1'b0;
  else if (current_state==ST_NEXT_ROW /*&& blur_mem_we_ctr>='d3*/ && blur_addr_w_0<'d480) // 3 cycles from MEM read to MEM write
    blur_mem_we_0 <= 1'b1;
  else
    blur_mem_we_0 <= 1'b0;
end

/*Enable blur_mem_we once ctr reaches 3 (3 lines in LB)*/
always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_1 <= 1'b0;
  else if (current_state==ST_NEXT_ROW && blur_mem_we_ctr>='d1 && blur_addr_w_1<'d480/* && img_addr>'d3*/) // 3 + 1 cycles from MEM read to MEM write
    blur_mem_we_1 <= 1'b1;
  else
    blur_mem_we_1 <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_2 <= 1'b0;
  else if (current_state==ST_NEXT_ROW && blur_mem_we_ctr>='d1 && blur_addr_w_2<'d480/* && img_addr>'d3*/) // 3 + 1 cycles from MEM read to MEM write
    blur_mem_we_2 <= 1'b1;
  else
    blur_mem_we_2 <= 1'b0;
end

/*Enable blur_mem_we once ctr reaches 3 (4 lines in LB)*/
always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_3 <= 1'b0;
  else if (current_state==ST_NEXT_ROW && blur_mem_we_ctr>='d2 && blur_addr_w_3<'d480/* && img_addr>'d4*/) // 3 + 2 cycles from MEM read to MEM write
    blur_mem_we_3 <= 1'b1;
  else
    blur_mem_we_3 <= 1'b0;
end

/*Addr. to Read from SRAM*/
always @(posedge clk) begin
  if (!rst_n)
    blur_addr_r_0 <= 'd0;
  else if (((current_state==ST_FIRST_COL || current_state==ST_NEXT_COL) && col_relay==2) && blur_addr_r_0<'d480)
    blur_addr_r_0 <= blur_addr_r_0 + 'd1;
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_r_0 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_r_1 <= 'd0;
  else if (current_state==ST_NEXT_ROW && blur_addr_r_1<'d480 /*&& blur_mem_we_ctr>='d1*/)
    blur_addr_r_1 <= blur_addr_r_1 + 'd1;
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_r_1 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_r_2 <= 'd0;
  else if (current_state==ST_NEXT_ROW && blur_addr_r_2<'d480 /*&& blur_mem_we_ctr>='d1*/)
    blur_addr_r_2 <= blur_addr_r_2 + 'd1;
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_r_2 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_r_3 <= 'd0;
  else if (current_state==ST_NEXT_ROW && blur_addr_r_3<'d480 && blur_mem_we_ctr>='d1)
    blur_addr_r_3 <= blur_addr_r_3 + 'd1;
  else if (current_state==ST_IDLE || current_state==ST_NEXT_COL)
    blur_addr_r_3 <= 'd0;
end



/*Blurs 16 pixel in 1 Iteration*/
wire  [127:0]  blur_result_0; // 16 * 8
Gaussian_Blur_3x3 u_g_blur0(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .current_col    (current_col),
  .blur_out       (blur_result_0)
);

wire  [127:0]  blur_result_1; // 16 * 8
Gaussian_Blur_5x5_0 u_g_blur1(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .current_col    (current_col),
  .blur_out       (blur_result_1)
);

wire  [127:0]  blur_result_2; // 16 * 8
Gaussian_Blur_5x5_1 u_g_blur2(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .current_col    (current_col),
  .blur_out       (blur_result_2)
);

wire  [127:0]  blur_result_3; // 16 * 8
Gaussian_Blur_7x7 u_g_blur3(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .buffer_data_5  (buffer_data_5),
  .buffer_data_6  (buffer_data_6),
  .current_col    (current_col),
  .blur_out       (blur_result_3)
);

/*Concats current blur SRAM storage with currently computed blur_result to be written back to memory*/
reg[5119:0]   blur_concat_0, // wire
              blur_concat_1,
              blur_concat_2,
              blur_concat_3;
always @(*) begin
  case(current_col)
    'd0: begin
      blur_concat_0 = {blur_result_0, 4992'b0};
      blur_concat_1 = {blur_result_1, 4992'b0};
      blur_concat_2 = {blur_result_2, 4992'b0};
      blur_concat_3 = {blur_result_3, 4992'b0};
    end
    'd1: begin
      blur_concat_0 = {blur_dout_0[127:0], blur_result_0, 4864'b0};
      blur_concat_1 = {blur_dout_1[127:0], blur_result_1, 4864'b0};
      blur_concat_2 = {blur_dout_2[127:0], blur_result_2, 4864'b0};
      blur_concat_3 = {blur_dout_3[127:0], blur_result_3, 4864'b0};
    end
    'd2: begin
      blur_concat_0 = {blur_dout_0[255:0], blur_result_0, 4736'b0};
      blur_concat_1 = {blur_dout_1[255:0], blur_result_1, 4736'b0};
      blur_concat_2 = {blur_dout_2[255:0], blur_result_2, 4736'b0};
      blur_concat_3 = {blur_dout_3[255:0], blur_result_3, 4736'b0};
    end
    'd3: begin
      blur_concat_0 = {blur_dout_0[383:0], blur_result_0, 4608'b0};
      blur_concat_1 = {blur_dout_1[383:0], blur_result_1, 4608'b0};
      blur_concat_2 = {blur_dout_2[383:0], blur_result_2, 4608'b0};
      blur_concat_3 = {blur_dout_3[383:0], blur_result_3, 4608'b0};
    end
    'd4: begin
      blur_concat_0 = {blur_dout_0[511:0], blur_result_0, 4480'b0};
      blur_concat_1 = {blur_dout_1[511:0], blur_result_1, 4480'b0};
      blur_concat_2 = {blur_dout_2[511:0], blur_result_2, 4480'b0};
      blur_concat_3 = {blur_dout_3[511:0], blur_result_3, 4480'b0};
    end
    'd5: begin
      blur_concat_0 = {blur_dout_0[639:0], blur_result_0, 4352'b0};
      blur_concat_1 = {blur_dout_1[639:0], blur_result_1, 4352'b0};
      blur_concat_2 = {blur_dout_2[639:0], blur_result_2, 4352'b0};
      blur_concat_3 = {blur_dout_3[639:0], blur_result_3, 4352'b0};
    end
    'd6: begin
      blur_concat_0 = {blur_dout_0[767:0], blur_result_0, 4224'b0};
      blur_concat_1 = {blur_dout_1[767:0], blur_result_1, 4224'b0};
      blur_concat_2 = {blur_dout_2[767:0], blur_result_2, 4224'b0};
      blur_concat_3 = {blur_dout_3[767:0], blur_result_3, 4224'b0};
    end
    'd7: begin
      blur_concat_0 = {blur_dout_0[895:0], blur_result_0, 4096'b0};
      blur_concat_1 = {blur_dout_1[895:0], blur_result_1, 4096'b0};
      blur_concat_2 = {blur_dout_2[895:0], blur_result_2, 4096'b0};
      blur_concat_3 = {blur_dout_3[895:0], blur_result_3, 4096'b0};
    end
    'd8: begin
      blur_concat_0 = {blur_dout_0[1023:0], blur_result_0, 3968'b0};
      blur_concat_1 = {blur_dout_1[1023:0], blur_result_1, 3968'b0};
      blur_concat_2 = {blur_dout_2[1023:0], blur_result_2, 3968'b0};
      blur_concat_3 = {blur_dout_3[1023:0], blur_result_3, 3968'b0};
    end
    'd9: begin
      blur_concat_0 = {blur_dout_0[1151:0], blur_result_0, 3840'b0};
      blur_concat_1 = {blur_dout_1[1151:0], blur_result_1, 3840'b0};
      blur_concat_2 = {blur_dout_2[1151:0], blur_result_2, 3840'b0};
      blur_concat_3 = {blur_dout_3[1151:0], blur_result_3, 3840'b0};
    end
    'd10: begin
      blur_concat_0 = {blur_dout_0[1279:0], blur_result_0, 3712'b0};
      blur_concat_1 = {blur_dout_1[1279:0], blur_result_1, 3712'b0};
      blur_concat_2 = {blur_dout_2[1279:0], blur_result_2, 3712'b0};
      blur_concat_3 = {blur_dout_3[1279:0], blur_result_3, 3712'b0};
    end
    'd11: begin
      blur_concat_0 = {blur_dout_0[1407:0], blur_result_0, 3584'b0};
      blur_concat_1 = {blur_dout_1[1407:0], blur_result_1, 3584'b0};
      blur_concat_2 = {blur_dout_2[1407:0], blur_result_2, 3584'b0};
      blur_concat_3 = {blur_dout_3[1407:0], blur_result_3, 3584'b0};
    end
    'd12: begin
      blur_concat_0 = {blur_dout_0[1535:0], blur_result_0, 3456'b0};
      blur_concat_1 = {blur_dout_1[1535:0], blur_result_1, 3456'b0};
      blur_concat_2 = {blur_dout_2[1535:0], blur_result_2, 3456'b0};
      blur_concat_3 = {blur_dout_3[1535:0], blur_result_3, 3456'b0};
    end
    'd13: begin
      blur_concat_0 = {blur_dout_0[1663:0], blur_result_0, 3328'b0};
      blur_concat_1 = {blur_dout_1[1663:0], blur_result_1, 3328'b0};
      blur_concat_2 = {blur_dout_2[1663:0], blur_result_2, 3328'b0};
      blur_concat_3 = {blur_dout_3[1663:0], blur_result_3, 3328'b0};
    end
    'd14: begin
      blur_concat_0 = {blur_dout_0[1791:0], blur_result_0, 3200'b0};
      blur_concat_1 = {blur_dout_1[1791:0], blur_result_1, 3200'b0};
      blur_concat_2 = {blur_dout_2[1791:0], blur_result_2, 3200'b0};
      blur_concat_3 = {blur_dout_3[1791:0], blur_result_3, 3200'b0};
    end
    'd15: begin
      blur_concat_0 = {blur_dout_0[1919:0], blur_result_0, 3072'b0};
      blur_concat_1 = {blur_dout_1[1919:0], blur_result_1, 3072'b0};
      blur_concat_2 = {blur_dout_2[1919:0], blur_result_2, 3072'b0};
      blur_concat_3 = {blur_dout_3[1919:0], blur_result_3, 3072'b0};
    end
    'd16: begin
      blur_concat_0 = {blur_dout_0[2047:0], blur_result_0, 2944'b0};
      blur_concat_1 = {blur_dout_1[2047:0], blur_result_1, 2944'b0};
      blur_concat_2 = {blur_dout_2[2047:0], blur_result_2, 2944'b0};
      blur_concat_3 = {blur_dout_3[2047:0], blur_result_3, 2944'b0};
    end
    'd17: begin
      blur_concat_0 = {blur_dout_0[2175:0], blur_result_0, 2816'b0};
      blur_concat_1 = {blur_dout_1[2175:0], blur_result_1, 2816'b0};
      blur_concat_2 = {blur_dout_2[2175:0], blur_result_2, 2816'b0};
      blur_concat_3 = {blur_dout_3[2175:0], blur_result_3, 2816'b0};
    end
    'd18: begin
      blur_concat_0 = {blur_dout_0[2303:0], blur_result_0, 2688'b0};
      blur_concat_1 = {blur_dout_1[2303:0], blur_result_1, 2688'b0};
      blur_concat_2 = {blur_dout_2[2303:0], blur_result_2, 2688'b0};
      blur_concat_3 = {blur_dout_3[2303:0], blur_result_3, 2688'b0};
    end
    'd19: begin
      blur_concat_0 = {blur_dout_0[2431:0], blur_result_0, 2560'b0};
      blur_concat_1 = {blur_dout_1[2431:0], blur_result_1, 2560'b0};
      blur_concat_2 = {blur_dout_2[2431:0], blur_result_2, 2560'b0};
      blur_concat_3 = {blur_dout_3[2431:0], blur_result_3, 2560'b0};
    end
    'd20: begin
      blur_concat_0 = {blur_dout_0[2559:0], blur_result_0, 2432'b0};
      blur_concat_1 = {blur_dout_1[2559:0], blur_result_1, 2432'b0};
      blur_concat_2 = {blur_dout_2[2559:0], blur_result_2, 2432'b0};
      blur_concat_3 = {blur_dout_3[2559:0], blur_result_3, 2432'b0};
    end
    'd21: begin
      blur_concat_0 = {blur_dout_0[2687:0], blur_result_0, 2304'b0};
      blur_concat_1 = {blur_dout_1[2687:0], blur_result_1, 2304'b0};
      blur_concat_2 = {blur_dout_2[2687:0], blur_result_2, 2304'b0};
      blur_concat_3 = {blur_dout_3[2687:0], blur_result_3, 2304'b0};
    end
    'd22: begin
      blur_concat_0 = {blur_dout_0[2815:0], blur_result_0, 2176'b0};
      blur_concat_1 = {blur_dout_1[2815:0], blur_result_1, 2176'b0};
      blur_concat_2 = {blur_dout_2[2815:0], blur_result_2, 2176'b0};
      blur_concat_3 = {blur_dout_3[2815:0], blur_result_3, 2176'b0};
    end
    'd23: begin
      blur_concat_0 = {blur_dout_0[2943:0], blur_result_0, 2048'b0};
      blur_concat_1 = {blur_dout_1[2943:0], blur_result_1, 2048'b0};
      blur_concat_2 = {blur_dout_2[2943:0], blur_result_2, 2048'b0};
      blur_concat_3 = {blur_dout_3[2943:0], blur_result_3, 2048'b0};
    end
    'd24: begin
      blur_concat_0 = {blur_dout_0[3071:0], blur_result_0, 1920'b0};
      blur_concat_1 = {blur_dout_1[3071:0], blur_result_1, 1920'b0};
      blur_concat_2 = {blur_dout_2[3071:0], blur_result_2, 1920'b0};
      blur_concat_3 = {blur_dout_3[3071:0], blur_result_3, 1920'b0};
    end
    'd25: begin
      blur_concat_0 = {blur_dout_0[3199:0], blur_result_0, 1792'b0};
      blur_concat_1 = {blur_dout_1[3199:0], blur_result_1, 1792'b0};
      blur_concat_2 = {blur_dout_2[3199:0], blur_result_2, 1792'b0};
      blur_concat_3 = {blur_dout_3[3199:0], blur_result_3, 1792'b0};
    end
    'd26: begin
      blur_concat_0 = {blur_dout_0[3327:0], blur_result_0, 1664'b0};
      blur_concat_1 = {blur_dout_1[3327:0], blur_result_1, 1664'b0};
      blur_concat_2 = {blur_dout_2[3327:0], blur_result_2, 1664'b0};
      blur_concat_3 = {blur_dout_3[3327:0], blur_result_3, 1664'b0};
    end
    'd27: begin
      blur_concat_0 = {blur_dout_0[3455:0], blur_result_0, 1536'b0};
      blur_concat_1 = {blur_dout_1[3455:0], blur_result_1, 1536'b0};
      blur_concat_2 = {blur_dout_2[3455:0], blur_result_2, 1536'b0};
      blur_concat_3 = {blur_dout_3[3455:0], blur_result_3, 1536'b0};
    end
    'd28: begin
      blur_concat_0 = {blur_dout_0[3583:0], blur_result_0, 1408'b0};
      blur_concat_1 = {blur_dout_1[3583:0], blur_result_1, 1408'b0};
      blur_concat_2 = {blur_dout_2[3583:0], blur_result_2, 1408'b0};
      blur_concat_3 = {blur_dout_3[3583:0], blur_result_3, 1408'b0};
    end
    'd29: begin
      blur_concat_0 = {blur_dout_0[3711:0], blur_result_0, 1280'b0};
      blur_concat_1 = {blur_dout_1[3711:0], blur_result_1, 1280'b0};
      blur_concat_2 = {blur_dout_2[3711:0], blur_result_2, 1280'b0};
      blur_concat_3 = {blur_dout_3[3711:0], blur_result_3, 1280'b0};
    end
    'd30: begin
      blur_concat_0 = {blur_dout_0[3839:0], blur_result_0, 1152'b0};
      blur_concat_1 = {blur_dout_1[3839:0], blur_result_1, 1152'b0};
      blur_concat_2 = {blur_dout_2[3839:0], blur_result_2, 1152'b0};
      blur_concat_3 = {blur_dout_3[3839:0], blur_result_3, 1152'b0};
    end
    'd31: begin
      blur_concat_0 = {blur_dout_0[3967:0], blur_result_0, 1024'b0};
      blur_concat_1 = {blur_dout_1[3967:0], blur_result_1, 1024'b0};
      blur_concat_2 = {blur_dout_2[3967:0], blur_result_2, 1024'b0};
      blur_concat_3 = {blur_dout_3[3967:0], blur_result_3, 1024'b0};
    end
    'd32: begin
      blur_concat_0 = {blur_dout_0[4095:0], blur_result_0, 896'b0};
      blur_concat_1 = {blur_dout_1[4095:0], blur_result_1, 896'b0};
      blur_concat_2 = {blur_dout_2[4095:0], blur_result_2, 896'b0};
      blur_concat_3 = {blur_dout_3[4095:0], blur_result_3, 896'b0};
    end
    'd33: begin
      blur_concat_0 = {blur_dout_0[4223:0], blur_result_0, 768'b0};
      blur_concat_1 = {blur_dout_1[4223:0], blur_result_1, 768'b0};
      blur_concat_2 = {blur_dout_2[4223:0], blur_result_2, 768'b0};
      blur_concat_3 = {blur_dout_3[4223:0], blur_result_3, 768'b0};
    end
    'd34: begin
      blur_concat_0 = {blur_dout_0[4351:0], blur_result_0, 640'b0};
      blur_concat_1 = {blur_dout_1[4351:0], blur_result_1, 640'b0};
      blur_concat_2 = {blur_dout_2[4351:0], blur_result_2, 640'b0};
      blur_concat_3 = {blur_dout_3[4351:0], blur_result_3, 640'b0};
    end
    'd35: begin
      blur_concat_0 = {blur_dout_0[4479:0], blur_result_0, 512'b0};
      blur_concat_1 = {blur_dout_1[4479:0], blur_result_1, 512'b0};
      blur_concat_2 = {blur_dout_2[4479:0], blur_result_2, 512'b0};
      blur_concat_3 = {blur_dout_3[4479:0], blur_result_3, 512'b0};
    end
    'd36: begin
      blur_concat_0 = {blur_dout_0[4607:0], blur_result_0, 384'b0};
      blur_concat_1 = {blur_dout_1[4607:0], blur_result_1, 384'b0};
      blur_concat_2 = {blur_dout_2[4607:0], blur_result_2, 384'b0};
      blur_concat_3 = {blur_dout_3[4607:0], blur_result_3, 384'b0};
    end
    'd37: begin
      blur_concat_0 = {blur_dout_0[4735:0], blur_result_0, 256'b0};
      blur_concat_1 = {blur_dout_1[4735:0], blur_result_1, 256'b0};
      blur_concat_2 = {blur_dout_2[4735:0], blur_result_2, 256'b0};
      blur_concat_3 = {blur_dout_3[4735:0], blur_result_3, 256'b0};
    end
    'd38: begin
      blur_concat_0 = {blur_dout_0[4863:0], blur_result_0, 128'b0};
      blur_concat_1 = {blur_dout_1[4863:0], blur_result_1, 128'b0};
      blur_concat_2 = {blur_dout_2[4863:0], blur_result_2, 128'b0};
      blur_concat_3 = {blur_dout_3[4863:0], blur_result_3, 128'b0};
    end
    'd39: begin
      blur_concat_0 = {blur_dout_0[4953:0], blur_result_0};
      blur_concat_1 = {blur_dout_1[4953:0], blur_result_1};
      blur_concat_2 = {blur_dout_2[4953:0], blur_result_2};
      blur_concat_3 = {blur_dout_3[4953:0], blur_result_3};
    end
    default: begin
      blur_concat_0 = 'd0;
      blur_concat_1 = 'd0;
      blur_concat_2 = 'd0;
      blur_concat_3 = 'd0;
    end
  endcase
end

/*Write concat-ed data into input FF of blur SRAM*/
always @(posedge clk) begin
  if (!rst_n)
    blur_din_0 <= 'd0;    
  else if (current_state==ST_NEXT_ROW)
    blur_din_0 <= blur_concat_0;
  else if (current_state==ST_IDLE)
    blur_din_0 <= 'd0;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_din_1 <= 'd0;    
  else if (current_state==ST_NEXT_ROW)
    blur_din_1 <= blur_concat_1;
  else if (current_state==ST_IDLE)
    blur_din_1 <= 'd0;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_din_2 <= 'd0;    
  else if (current_state==ST_NEXT_ROW)
    blur_din_2 <= blur_concat_2;
  else if (current_state==ST_IDLE)
    blur_din_2 <= 'd0;
end
always @(posedge clk) begin
  if (!rst_n)
    blur_din_3 <= 'd0;    
  else if (current_state==ST_NEXT_ROW)
    blur_din_3 <= blur_concat_3;
  else if (current_state==ST_IDLE)
    blur_din_3 <= 'd0;
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
        next_state = ST_FIRST_COL;
      else
        next_state = ST_IDLE;
    end
    ST_FIRST_COL: begin
      if(col_relay == 2)
        next_state = ST_NEXT_ROW;
      else 
        next_state = ST_FIRST_COL;
    end
    ST_NEXT_COL: begin
      if(col_relay == 2)
        next_state = ST_NEXT_ROW;
      else 
        next_state = ST_NEXT_COL;
    end
    ST_NEXT_ROW: begin
      if(blur_addr_w_3=='d480)
        next_state = ST_NEXT_COL;
      else 
        next_state = ST_NEXT_ROW;
    end
    default:
      next_state = ST_IDLE;
  endcase
end



endmodule 