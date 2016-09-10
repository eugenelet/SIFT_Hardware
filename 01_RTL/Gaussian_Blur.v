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
  blur_mem_we_0,
  blur_mem_we_1,
  blur_mem_we_2,
  blur_mem_we_3,
  blur_addr_0,
  blur_addr_1,
  blur_addr_2,
  blur_addr_3,
  blur_din_0,
  blur_din_1,
  blur_din_2,
  blur_din_3,
  img_addr,
  buffer_we,
  fill_zero
);


/*SYSTEM*/
input                 clk,
                      rst_n,
                      start;
output reg            done;
output                buffer_we;


/*LINE BUFFER*/
input       [5119:0]  img_dout;
input       [5119:0]  buffer_data_0;
input       [5119:0]  buffer_data_1;
input       [5119:0]  buffer_data_2;
input       [5119:0]  buffer_data_3;
input       [5119:0]  buffer_data_4;
input       [5119:0]  buffer_data_5;
output  reg           fill_zero;

/*Image SRAM Control*/
output reg  [8:0]     img_addr;


/*BLUR SRAM Control*/
output      [5119:0]  blur_din_0,
                      blur_din_1,
                      blur_din_2,
                      blur_din_3;
output reg  [8:0]     blur_addr_0,
                      blur_addr_1,
                      blur_addr_2,
                      blur_addr_3;
output reg            blur_mem_we_0,
                      blur_mem_we_1,
                      blur_mem_we_2,
                      blur_mem_we_3;

/*Kernel Q0.18 (We take last 6 decimal digits for simplicity (<262144))*/
// reg       [95:0]  G_Kernel_3x3  [0:1];
// reg       [89:0]  G_Kernel_5x5_0[0:2];
// reg       [89:0]  G_Kernel_5x5_1[0:2];
// reg       [125:0] G_Kernel_7x7  [0:3];

/*Module FSM*/
parameter ST_IDLE        = 0,
          ST_READY       = 1,/*Idle 1 state for SRAM to get READY*/
          ST_GAUSSIAN_0  = 2,
          ST_GAUSSIAN_1  = 3,
          ST_GAUSSIAN_2  = 4,
          ST_GAUSSIAN_3  = 5,
          ST_GAUSSIAN_4  = 6,
          ST_GAUSSIAN_5  = 7,
          ST_GAUSSIAN_6  = 8,
          ST_GAUSSIAN_7  = 9,
          ST_GAUSSIAN_8  = 10,
          ST_GAUSSIAN_9  = 11;

reg     [3:0] current_state,
              next_state;




reg     ready_start_relay;
always @(posedge clk) begin
  if (!rst_n) 
    ready_start_relay <= 1'b0;
  else if (current_state == ST_READY)
    ready_start_relay <= 1'b1; 
  else if (current_state == ST_IDLE)
    ready_start_relay <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n) 
    fill_zero <= 1'b0;    
  else if (img_addr=='d480 && current_state==ST_GAUSSIAN_8)
    fill_zero <= 1'b1;
  else
    fill_zero <= 1'b0;
end

assign buffer_we = ((current_state==ST_IDLE && start) || (current_state==ST_READY && ready_start_relay) || current_state==ST_GAUSSIAN_9 ) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && ready_start_relay) || current_state==ST_GAUSSIAN_8) && img_addr<'d480)
    img_addr <= img_addr + 'd1;
  else if (done)
    img_addr <= 'd0;
end

/*Module DONE, inform SYSTEM*/
always @(posedge clk) begin
  if (!rst_n)
    done <= 1'b0;    
  else if (current_state==ST_GAUSSIAN_9  && blur_addr_3=='d480)
    done <= 1'b1;
  else if (current_state==ST_IDLE)
    done <= 1'b0;
end


always @(posedge clk) begin
  if (!rst_n)
    blur_addr_0 <= 'd0;
  else if (blur_mem_we_0 && blur_addr_0<'d480)
    blur_addr_0 <= blur_addr_0 + 'd1;
  else if (current_state==ST_IDLE)
    blur_addr_0 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_1 <= 'd0;
  else if (blur_mem_we_1 && blur_addr_1<'d480)
    blur_addr_1 <= blur_addr_1 + 'd1;
  else if (current_state==ST_IDLE)
    blur_addr_1 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_2 <= 'd0;
  else if (blur_mem_we_2 && blur_addr_2<'d480)
    blur_addr_2 <= blur_addr_2 + 'd1;
  else if (current_state==ST_IDLE)
    blur_addr_2 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_addr_3 <= 'd0;
  else if (blur_mem_we_3 && blur_addr_3<'d480)
    blur_addr_3 <= blur_addr_3 + 'd1;
  else if (current_state==ST_IDLE)
    blur_addr_3 <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_0 <= 1'b0;
  else if (current_state==ST_GAUSSIAN_9 && blur_addr_0<'d480)
    blur_mem_we_0 <= 1'b1;
  else
    blur_mem_we_0 <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_1 <= 1'b0;
  else if (current_state==ST_GAUSSIAN_9 && blur_addr_1<'d480 && img_addr > 'd3)
    blur_mem_we_1 <= 1'b1;
  else
    blur_mem_we_1 <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_2 <= 1'b0;
  else if (current_state==ST_GAUSSIAN_9 && blur_addr_2<'d480 && img_addr > 'd3)
    blur_mem_we_2 <= 1'b1;
  else
    blur_mem_we_2 <= 1'b0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we_3 <= 1'b0;
  else if (current_state==ST_GAUSSIAN_9 && blur_addr_3<'d480 && img_addr > 'd3)
    blur_mem_we_3 <= 1'b1;
  else
    blur_mem_we_3 <= 1'b0;
end

wire  [5119:0]  blur_result_0;
Gaussian_Blur_3x3 u_g_blur0(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .current_state  (current_state),
  .blur_din       (blur_result_0)
);
assign blur_din_0 = blur_result_0;

wire  [5119:0]  blur_result_1;
Gaussian_Blur_5x5_0 u_g_blur1(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .current_state  (current_state),
  .blur_din       (blur_din_1)
);
assign blur_din_1 = blur_result_1;

wire  [5119:0]  blur_result_2;
Gaussian_Blur_5x5_1 u_g_blur2(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .current_state  (current_state),
  .blur_din       (blur_din_2)
);
assign blur_din_2 = blur_result_2;

wire  [5119:0]  blur_result_3;
Gaussian_Blur_7x7 u_g_blur3(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (img_dout),
  .buffer_data_1  (buffer_data_0),
  .buffer_data_2  (buffer_data_1),
  .buffer_data_3  (buffer_data_2),
  .buffer_data_4  (buffer_data_3),
  .buffer_data_5  (buffer_data_4),
  .buffer_data_6  (buffer_data_5),
  .current_state  (current_state),
  .blur_din       (blur_din_3)
);
assign blur_din_3 = blur_result_3;



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
        next_state = ST_GAUSSIAN_0;
      else 
        next_state = ST_READY;
    end
    ST_GAUSSIAN_0: begin
      if(current_state==ST_GAUSSIAN_0)
        next_state = ST_GAUSSIAN_1;
      else 
        next_state = ST_GAUSSIAN_0;
    end
    ST_GAUSSIAN_1: begin
      if(current_state==ST_GAUSSIAN_1)
        next_state = ST_GAUSSIAN_2;
      else 
        next_state = ST_GAUSSIAN_1;
    end
    ST_GAUSSIAN_2: begin
      if(current_state==ST_GAUSSIAN_2)
        next_state = ST_GAUSSIAN_3;
      else 
        next_state = ST_GAUSSIAN_2;
    end
    ST_GAUSSIAN_3: begin
      if(current_state==ST_GAUSSIAN_3)
        next_state = ST_GAUSSIAN_4;
      else 
        next_state = ST_GAUSSIAN_3;
    end
    ST_GAUSSIAN_4: begin
      if(current_state==ST_GAUSSIAN_4)
        next_state = ST_GAUSSIAN_5;
      else 
        next_state = ST_GAUSSIAN_4;
    end
    ST_GAUSSIAN_5: begin
      if(current_state==ST_GAUSSIAN_5)
        next_state = ST_GAUSSIAN_6;
      else 
        next_state = ST_GAUSSIAN_5;
    end
    ST_GAUSSIAN_6: begin
      if(current_state==ST_GAUSSIAN_6)
        next_state = ST_GAUSSIAN_7;
      else 
        next_state = ST_GAUSSIAN_6;
    end
    ST_GAUSSIAN_7: begin
      if(current_state==ST_GAUSSIAN_7)
        next_state = ST_GAUSSIAN_8;
      else 
        next_state = ST_GAUSSIAN_7;
    end
    ST_GAUSSIAN_8: begin
      if(current_state==ST_GAUSSIAN_8)
        next_state = ST_GAUSSIAN_9;
      else 
        next_state = ST_GAUSSIAN_8;
    end
    ST_GAUSSIAN_9: begin
      if(current_state==ST_GAUSSIAN_9 && !done)
        next_state = ST_GAUSSIAN_0;
      else if(current_state==ST_GAUSSIAN_9 && done)
        next_state = ST_IDLE;
      else 
        next_state = ST_GAUSSIAN_9;
    end
    default:
      next_state = ST_IDLE;
  endcase
end



endmodule 