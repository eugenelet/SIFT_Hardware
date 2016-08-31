`timescale 1ns/10ps
module CORE(
  clk,
  rst_n,
  in_valid,
  in_data,
  out_valid,
  out_data
);
input           clk;
input           rst_n;
input           in_valid;/*USED AS START SIGNAL FOR NOW*/
input   [15:0]  in_data;
output          out_valid;
output  [15:0]  out_data;






/*FSM*/
reg         [2:0] current_state,
                  next_state;

parameter         ST_IDLE       = 0,
                  ST_GAUSSIAN   = 1,
                  ST_DETECT_KP  = 2,
                  ST_FILTER_KP  = 3,
                  ST_MATCH      = 4,
                  ST_END        = 5; //FOR DEBUG

/*parameter  [1:0]  L_IDLE     = 'd0,
                  L_GAUSSIAN = 'd1;*/



wire    [8:0]     img_addr;
reg     [5119:0]  img_din;
wire    [5119:0]  img_dout;
/*SRAM for Original Image*/
bmem_480x5120 ori_img(
  .clk  (clk),
  .we   (1'b0),
  .addr (img_addr),
  .din  (1'b0),
  .dout (img_dout)
);


wire  [3:0]    blur_mem_we;
wire  [8:0]    blur_addr  [0:3];
wire  [5119:0] blur_din   [0:3];
wire  [5119:0] blur_dout  [0:3];
/*SRAM for Blurred Images(4)*/
bmem_480x5120 blur_img_0(
  .clk  (clk),
  .we   (blur_mem_we[0]),
  .addr (blur_addr[0]),
  .din  (blur_din[0]),
  .dout (blur_dout[0])
);
bmem_480x5120 blur_img_1(
  .clk  (clk),
  .we   (blur_mem_we[1]),
  .addr (blur_addr[1]),
  .din  (blur_din[1]),
  .dout (blur_dout[1])
);
bmem_480x5120 blur_img_2(
  .clk  (clk),
  .we   (blur_mem_we[2]),
  .addr (blur_addr[2]),
  .din  (blur_din[2]),
  .dout (blur_dout[2])
);
bmem_480x5120 blur_img_3(
  .clk  (clk),
  .we   (blur_mem_we[3]),
  .addr (blur_addr[3]),
  .din  (blur_din[3]),
  .dout (blur_dout[3])
);


wire    [5119:0]  buffer_data_0;
wire    [5119:0]  buffer_data_1;
wire    [5119:0]  buffer_data_2;
wire    [5119:0]  buffer_data_3;
wire    [5119:0]  buffer_data_4;
wire    [5119:0]  buffer_data_5;
wire    [5119:0]  buffer_data_6;
wire    [5119:0]  buffer_data_7;
wire    [5119:0]  buffer_data_8;
wire    [5119:0]  buffer_data_9;
wire              buffer_we;
// wire              buffer_mode = (gaussian_done)?L_IDLE:L_GAUSSIAN;
/*System Line Buffer*/
Line_Buffer_10 l_buf_10(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_mode    (current_state),
  .buffer_we      (buffer_we),
  .img_data       (img_dout),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .buffer_data_5  (buffer_data_5),
  .buffer_data_6  (buffer_data_6),
  .buffer_data_7  (buffer_data_7),
  .buffer_data_8  (buffer_data_8),
  .buffer_data_9  (buffer_data_9)
);

wire    gaussian_start = (current_state==ST_GAUSSIAN)?1:0;
wire [3:0]   gaussian_done;
Gaussian_Blur_3x3 g_blur_3x3(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .start          (gaussian_start),
  .done           (gaussian_done[0]),
  .blur_mem_we    (blur_mem_we[0]),
  .blur_addr      (blur_addr[0]),
  .blur_din       (blur_din[0]),
  .img_addr       (img_addr),
  .buffer_we      (buffer_we)
);

Gaussian_Blur_5x5_1 g_blur_5x5_1(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .start          (gaussian_start),
  .done           (gaussian_done[1]),
  .blur_mem_we    (blur_mem_we[1]),
  .blur_addr      (blur_addr[1]),
  .blur_din       (blur_din[1]),
  .img_addr       (img_addr),
  .buffer_we      (buffer_we)
);

Gaussian_Blur_5x5_2 g_blur_5x5_2(
  .clk            (clk),
  .rst_n          (rst_n),
  .buffer_data_0  (buffer_data_0),
  .buffer_data_1  (buffer_data_1),
  .buffer_data_2  (buffer_data_2),
  .buffer_data_3  (buffer_data_3),
  .buffer_data_4  (buffer_data_4),
  .start          (gaussian_start),
  .done           (gaussian_done[2]),
  .blur_mem_we    (blur_mem_we[2]),
  .blur_addr      (blur_addr[2]),
  .blur_din       (blur_din[2]),
  .img_addr       (img_addr),
  .buffer_we      (buffer_we)
);

Gaussian_Blur_7x7 g_blur_7x7(
  .clk            (clk),
  .rst_n          (rst_n),
  .img_dout       (img_dout),
  .buffer_data_1  (buffer_data_0),
  .buffer_data_2  (buffer_data_1),
  .buffer_data_3  (buffer_data_2),
  .buffer_data_4  (buffer_data_3),
  .buffer_data_5  (buffer_data_4),
  .buffer_data_6  (buffer_data_5),
  .start          (gaussian_start),
  .done           (gaussian_done[3]),
  .blur_mem_we    (blur_mem_we[3]),
  .blur_addr      (blur_addr[3]),
  .blur_din       (blur_din[3]),
  .img_addr       (img_addr),
  .buffer_we      (buffer_we)
);

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
      if(in_valid)
        next_state = ST_GAUSSIAN;
      else
        next_state = ST_IDLE;
    end
    ST_GAUSSIAN: begin
      if(gaussian_done[0])
        next_state = ST_END;
      else
        next_state = ST_GAUSSIAN;
    end
    ST_END: begin /*DEBUG STATE*/
        next_state = ST_END;
    end
    default:
      next_state = ST_IDLE;
  endcase
end


endmodule 