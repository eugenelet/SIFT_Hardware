`timescale 1ns/10ps
module Gaussian_Blur_3x3(
  clk,
  rst_n,
  start,
  done,
  buffer_data_0,
  buffer_data_1,
  buffer_data_2,
  blur_mem_we,
  blur_addr,
  blur_din,
  img_addr,
  buffer_we
);


/*SYSTEM*/
input                 clk,
                      rst_n,
                      start;
output reg            done;
output                buffer_we;


/*LINE BUFFER*/
input       [5119:0]  buffer_data_0;
input       [5119:0]  buffer_data_1;
input       [5119:0]  buffer_data_2;

/*Image SRAM Control*/
output reg  [8:0]     img_addr;


/*BLUR SRAM Control*/
output reg  [5119:0]  blur_din;
output reg  [8:0]     blur_addr;
output reg            blur_mem_we;

/*Kernel Q0.18 (We take last 6 decimal digits for simplicity (<262144))*/
reg       [53:0]  G_Kernel_3x3  [0:1];
reg       [89:0]  G_Kernel_5x5_0[0:2];
reg       [89:0]  G_Kernel_5x5_1[0:2];
reg       [125:0] G_Kernel_7x7  [0:3];

/*Module FSM*/
parameter ST_IDLE   = 0,
          ST_READY  = 1,/*Idle 1 state for SRAM to get READY*/
          ST_START  = 2;

reg     [1:0] current_state,
              next_state;

/*Kernel Value*/
/*
0.092717418604014015
0.11906051350198525
0.092717418604014015
0.11906051350198525
0.15288827157600263
0.11906051350198525
*/

always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_3x3[0][17:0]  <= 18'b00_0101_1110_1111_0001;//'d092717;         
    G_Kernel_3x3[0][35:18] <= 18'b00_0111_1001_1110_1010;//'d119061;         
    G_Kernel_3x3[0][53:36] <= 18'b00_0101_1110_1111_0001;//'d092717;         
    G_Kernel_3x3[1][17:0]  <= 18'b00_0111_1001_1110_1010;//'d119061;         
    G_Kernel_3x3[1][35:18] <= 18'b00_1001_1100_1000_1110;//'d152888;         
    G_Kernel_3x3[1][53:36] <= 18'b00_0111_1001_1110_1011;//'d119061;         
  end
end


/*
0.023238635292513864
0.033819677598242469
0.038325610139225079
0.033819677598242469
0.023238635292513864
0.033819677598242469
0.049218492327624749
0.055776071285996383
0.049218492327624749
0.033819677598242469
0.038325610139225079
0.055776071285996383
0.063207343032619934
0.055776071285996383
0.038325610139225079
*/


always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_5x5_0[0][17:0]  <= 18'b000001011111001011;//'d023238;         
    G_Kernel_5x5_0[0][35:18] <= 18'b000010001010100001;//d033819;         
    G_Kernel_5x5_0[0][53:36] <= 18'b000010011100111110;//d038325;        
    G_Kernel_5x5_0[0][71:54] <= 18'b000010001010100001;//d033819;         
    G_Kernel_5x5_0[0][89:72] <= 18'b000001011111001011;//'d023238;  
    G_Kernel_5x5_0[1][17:0]  <= 18'b000010001010100001;//d033819;         
    G_Kernel_5x5_0[1][35:18] <= 18'b000011001001100110;//d049218;         
    G_Kernel_5x5_0[1][53:36] <= 18'b000011100100011101;//d055776;        
    G_Kernel_5x5_0[1][71:54] <= 18'b000011001001100110;//d049218;         
    G_Kernel_5x5_0[1][89:72] <= 18'b000010001010100001;//d033819;   
    G_Kernel_5x5_0[2][17:0]  <= 18'b000010011100111110;//d038325;         
    G_Kernel_5x5_0[2][35:18] <= 18'b000011100100011101;//d055776;         
    G_Kernel_5x5_0[2][53:36] <= 18'b000100000010111001;//d063207;        
    G_Kernel_5x5_0[2][71:54] <= 18'b000011100100011101;//d055776;         
    G_Kernel_5x5_0[2][89:72] <= 18'b000010011100111110;//d038325;          
  end
end

/*
0.030809102162597531
0.037169188380625919
0.039568636938193465
0.037169188380625919
0.030809102162597531
0.037169188380625919
0.04484222089898051
0.047737000337055836
0.04484222089898051
0.037169188380625919
0.039568636938193465
0.047737000337055836
0.050818651607683375
0.047737000337055836
0.039568636938193465
*/

always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_5x5_1[0][17:0]  <= 18'b000001111110001100;//'d030809;         
    G_Kernel_5x5_1[0][35:18] <= 18'b000010011000001111;//'d037169;         
    G_Kernel_5x5_1[0][53:36] <= 18'b000010100010000100;//'d039568;        
    G_Kernel_5x5_1[0][71:54] <= 18'b000010011000001111;//'d037169;         
    G_Kernel_5x5_1[0][89:72] <= 18'b000001111110001100;//'d030809;  
    G_Kernel_5x5_1[1][17:0]  <= 18'b000010011000001111;//'d037169;         
    G_Kernel_5x5_1[1][35:18] <= 18'b000010110111101011;//'d044842;         
    G_Kernel_5x5_1[1][53:36] <= 18'b000011000011100001;//'d047737;        
    G_Kernel_5x5_1[1][71:54] <= 18'b000010110111101011;//'d044842;         
    G_Kernel_5x5_1[1][89:72] <= 18'b000010011000001111;//'d037169;   
    G_Kernel_5x5_1[2][17:0]  <= 18'b000010100010000100;//'d039568;         
    G_Kernel_5x5_1[2][35:18] <= 18'b000011000011100001;//'d047737;         
    G_Kernel_5x5_1[2][53:36] <= 18'b000011010000001001;//'d050818;        
    G_Kernel_5x5_1[2][71:54] <= 18'b000011000011100001;//'d047737;         
    G_Kernel_5x5_1[2][89:72] <= 18'b000010100010000100;//'d039568;          
  end
end

/*
0.014754044793808502
0.017252484482802938
0.018950294961355484
0.019552580550114801
0.018950294961355484
0.017252484482802938
0.014754044793808502
0.017252484482802938
0.020174008211921897
0.022159324736666357
0.022863600948342663
0.022159324736666357
0.020174008211921897
0.017252484482802938
0.018950294961355484
0.022159324736666357
0.024340015510395913
0.025113599277930113
0.024340015510395913
0.022159324736666357
0.018950294961355484
0.019552580550114801
0.022863600948342663
0.025113599277930113
0.025911769383346342
0.025113599277930113
0.022863600948342663
0.019552580550114801
*/

always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_7x7[0][17:0]    <= 18'b000000111100011011;//'d014754;         
    G_Kernel_7x7[0][35:18]   <= 18'b000001000110101010;//'d017252;         
    G_Kernel_7x7[0][53:36]   <= 18'b000001001101100111;//'d018950;        
    G_Kernel_7x7[0][71:54]   <= 18'b000001010000000101;//'d019552;         
    G_Kernel_7x7[0][89:72]   <= 18'b000001001101100111;//'d018950;       
    G_Kernel_7x7[0][107:90]  <= 18'b000001000110101010;//'d017252;         
    G_Kernel_7x7[0][125:108] <= 18'b000000111100011011;//'d014754;  
    G_Kernel_7x7[1][17:0]    <= 18'b000001000110101010;//'d017252;         
    G_Kernel_7x7[1][35:18]   <= 18'b000001010010101000;//'d020174;         
    G_Kernel_7x7[1][53:36]   <= 18'b000001011010110000;//'d022159;        
    G_Kernel_7x7[1][71:54]   <= 18'b000001011101101001;//'d022863;         
    G_Kernel_7x7[1][89:72]   <= 18'b000001011010110000;//'d022159;       
    G_Kernel_7x7[1][107:90]  <= 18'b000001010010101000;//'d020174;         
    G_Kernel_7x7[1][125:108] <= 18'b000001000110101010;//'d017252;  
    G_Kernel_7x7[2][17:0]    <= 18'b000001001101100111;//'d018950;         
    G_Kernel_7x7[2][35:18]   <= 18'b000001011010110000;//'d022159;         
    G_Kernel_7x7[2][53:36]   <= 18'b000001100011101100;//'d024340;        
    G_Kernel_7x7[2][71:54]   <= 18'b000001100110110111;//'d025113;         
    G_Kernel_7x7[2][89:72]   <= 18'b000001100011101100;//'d024340;       
    G_Kernel_7x7[2][107:90]  <= 18'b000001011010110000;//'d022159;         
    G_Kernel_7x7[2][125:108] <= 18'b000001001101100111;//'d018950;  
    G_Kernel_7x7[3][17:0]    <= 18'b000001010000000101;//'d019552;         
    G_Kernel_7x7[3][35:18]   <= 18'b000001011101101001;//'d022863;         
    G_Kernel_7x7[3][53:36]   <= 18'b000001100110110111;//'d025113;        
    G_Kernel_7x7[3][71:54]   <= 18'b000001101010001000;//'d025911;         
    G_Kernel_7x7[3][89:72]   <= 18'b000001100110110111;//'d025113;       
    G_Kernel_7x7[3][107:90]  <= 18'b000001011101101001;//'d022863;         
    G_Kernel_7x7[3][125:108] <= 18'b000001010000000101;//'d019552;          
  end
end
/*
always @(posedge clk) begin
  if (!rst_n)
    buffer_we <= 1'b0;    
  else if (start)
    buffer_we <= 1'b1;
  else if (img_addr=='d480 || current_state==ST_IDLE)
    buffer_we <= 1'b0;
end*/
reg   buffer_we_stop;
always @(posedge clk) begin
  if (!rst_n) 
    buffer_we_stop <= 1'b0;    
  else if (img_addr=='d480)
    buffer_we_stop <= 1'b1;
  else
    buffer_we_stop <= 1'b0;
end

assign buffer_we = (start && !(buffer_we_stop || current_state==ST_IDLE)) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd0;    
  else if (start && img_addr<'d480)
    img_addr <= img_addr + 'd1;
  else if (done)
    img_addr <= 'd0;
end

/*Module DONE, inform SYSTEM*/
always @(posedge clk) begin
  if (!rst_n)
    done <= 1'b0;    
  else if (current_state==ST_START && blur_addr=='d480)
    done <= 1'b1;
  else if (current_state==ST_IDLE)
    done <= 1'b0;
end


always @(posedge clk) begin
  if (!rst_n)
    blur_addr <= 'd0;
  else if (blur_mem_we && blur_addr<'d480)
    blur_addr <= blur_addr + 'd1;
  else if (current_state==ST_IDLE)
    blur_addr <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_mem_we <= 1'b0;
  else if (current_state==ST_START && blur_addr<'d480)
    blur_mem_we <= 1'b1;
  else if (blur_addr=='d480 || current_state==ST_IDLE)
    blur_mem_we <= 1'b0;
end

reg     ready_start_relay;
always @(posedge clk) begin
  if (!rst_n) 
    ready_start_relay <= 1'b0;
  else if (current_state == ST_READY)
    ready_start_relay <= 1'b1; 
  else if (current_state == ST_IDLE)
    ready_start_relay <= 1'b0;
end




// /*LEFT EDGE CASE*/
// wire  [25:0]  kernel_img_mul_0[0:8];/*Q0.18 * Q8.0 -> Q8.18*/
// assign kernel_img_mul_0[0] = buffer_data_2[7:0]   * G_Kernel_3x3[0][35:18];
// assign kernel_img_mul_0[1] = buffer_data_2[15:8]  * G_Kernel_3x3[0][53:36];
// assign kernel_img_mul_0[3] = buffer_data_1[7:0]   * G_Kernel_3x3[1][35:18];
// assign kernel_img_mul_0[4] = buffer_data_1[15:8]  * G_Kernel_3x3[1][53:36];
// assign kernel_img_mul_0[6] = buffer_data_0[7:0]   * G_Kernel_3x3[0][35:18];
// assign kernel_img_mul_0[7] = buffer_data_0[15:8]  * G_Kernel_3x3[0][53:36];
// /*Q12.18*/
// wire  [29:0]  kernel_img_sum_0 = kernel_img_mul_0[0] + kernel_img_mul_0[1] + kernel_img_mul_0[3] +
//                          kernel_img_mul_0[4] + kernel_img_mul_0[6] + kernel_img_mul_0[7];
// always @(posedge clk) begin
//   if (!rst_n)
//     blur_din[7:0] <= 'd0;
//   else if (current_state==ST_START || (current_state==ST_IDLE)&&buffer_valid)
//     blur_din[7:0] <= kernel_img_sum_0[25:18];/*Q12.18 -> Q8.0*/
//   else if (current_state==ST_IDLE)
//     blur_din[7:0] <= 'd0;
// end

// /*RIGHT EDGE CASE*/
// wire  [25:0]  kernel_img_mul_639[0:8];
// assign kernel_img_mul_639[0] = buffer_data_2[5111:5104] * G_Kernel_3x3[0][17:0];
// assign kernel_img_mul_639[1] = buffer_data_2[5119:5112] * G_Kernel_3x3[0][35:18];
// assign kernel_img_mul_639[3] = buffer_data_1[5111:5104] * G_Kernel_3x3[1][17:0];
// assign kernel_img_mul_639[4] = buffer_data_1[5119:5112] * G_Kernel_3x3[1][35:18];
// assign kernel_img_mul_639[6] = buffer_data_0[5111:5104] * G_Kernel_3x3[0][17:0];
// assign kernel_img_mul_639[7] = buffer_data_0[5119:5112] * G_Kernel_3x3[0][35:18];
// wire  [29:0]  kernel_img_sum_639 = kernel_img_mul_639[0] + kernel_img_mul_639[1] + 
//                 kernel_img_mul_639[3] + kernel_img_mul_639[4] +
//                 kernel_img_mul_639[6] + kernel_img_mul_639[7];
// always @(posedge clk) begin
//   if (!rst_n)
//     blur_din[5119:5112] <= 'd0;
//   else if (current_state==ST_START || (current_state==ST_IDLE)&&buffer_valid)
//     blur_din[5119:5112] <= kernel_img_sum_639[25:18];/*Q12.18 -> Q8.0*/
//   else if (current_state==ST_IDLE)
//     blur_din[5119:5112] <= 'd0;
// end


/*Default Case*/
wire  [25:0]  kernel_img_mul_0[0:8];
assign kernel_img_mul_0[0] = buffer_data_2[7:0] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_0[1] = buffer_data_2[15:8] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_0[3] = buffer_data_1[7:0] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_0[4] = buffer_data_1[15:8] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_0[6] = buffer_data_0[7:0] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_0[7] = buffer_data_0[15:8] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_0 = kernel_img_mul_0[0] + kernel_img_mul_0[1] + kernel_img_mul_0[3] + 
                kernel_img_mul_0[4] + kernel_img_mul_0[6] + kernel_img_mul_0[7] + 
                'd0;
always @(posedge clk) begin
  if (!rst_n)
    blur_din[7:0] <= 'd0;
  else if (current_state==ST_START)
    blur_din[7:0] <= kernel_img_sum_0[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[7:0] <= 'd0;
end

wire  [25:0]  kernel_img_mul_1[0:8];
assign kernel_img_mul_1[0] = buffer_data_2[7:0] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_1[1] = buffer_data_2[15:8] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_1[2] = buffer_data_2[23:16] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_1[3] = buffer_data_1[7:0] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_1[4] = buffer_data_1[15:8] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_1[5] = buffer_data_1[23:16] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_1[6] = buffer_data_0[7:0] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_1[7] = buffer_data_0[15:8] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_1[8] = buffer_data_0[23:16] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_1 = kernel_img_mul_1[0] + kernel_img_mul_1[1] + kernel_img_mul_1[2] + 
                kernel_img_mul_1[3] + kernel_img_mul_1[4] + kernel_img_mul_1[5] + 
                kernel_img_mul_1[6] + kernel_img_mul_1[7] + kernel_img_mul_1[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[15:8] <= 'd0;
  else if (current_state==ST_START)
    blur_din[15:8] <= kernel_img_sum_1[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[15:8] <= 'd0;
end

wire  [25:0]  kernel_img_mul_2[0:8];
assign kernel_img_mul_2[0] = buffer_data_2[15:8] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_2[1] = buffer_data_2[23:16] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_2[2] = buffer_data_2[31:24] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_2[3] = buffer_data_1[15:8] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_2[4] = buffer_data_1[23:16] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_2[5] = buffer_data_1[31:24] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_2[6] = buffer_data_0[15:8] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_2[7] = buffer_data_0[23:16] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_2[8] = buffer_data_0[31:24] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_2 = kernel_img_mul_2[0] + kernel_img_mul_2[1] + kernel_img_mul_2[2] + 
                kernel_img_mul_2[3] + kernel_img_mul_2[4] + kernel_img_mul_2[5] + 
                kernel_img_mul_2[6] + kernel_img_mul_2[7] + kernel_img_mul_2[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[23:16] <= 'd0;
  else if (current_state==ST_START)
    blur_din[23:16] <= kernel_img_sum_2[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[23:16] <= 'd0;
end

wire  [25:0]  kernel_img_mul_3[0:8];
assign kernel_img_mul_3[0] = buffer_data_2[23:16] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_3[1] = buffer_data_2[31:24] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_3[2] = buffer_data_2[39:32] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_3[3] = buffer_data_1[23:16] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_3[4] = buffer_data_1[31:24] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_3[5] = buffer_data_1[39:32] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_3[6] = buffer_data_0[23:16] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_3[7] = buffer_data_0[31:24] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_3[8] = buffer_data_0[39:32] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_3 = kernel_img_mul_3[0] + kernel_img_mul_3[1] + kernel_img_mul_3[2] + 
                kernel_img_mul_3[3] + kernel_img_mul_3[4] + kernel_img_mul_3[5] + 
                kernel_img_mul_3[6] + kernel_img_mul_3[7] + kernel_img_mul_3[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[31:24] <= 'd0;
  else if (current_state==ST_START)
    blur_din[31:24] <= kernel_img_sum_3[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[31:24] <= 'd0;
end

wire  [25:0]  kernel_img_mul_4[0:8];
assign kernel_img_mul_4[0] = buffer_data_2[31:24] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_4[1] = buffer_data_2[39:32] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_4[2] = buffer_data_2[47:40] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_4[3] = buffer_data_1[31:24] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_4[4] = buffer_data_1[39:32] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_4[5] = buffer_data_1[47:40] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_4[6] = buffer_data_0[31:24] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_4[7] = buffer_data_0[39:32] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_4[8] = buffer_data_0[47:40] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_4 = kernel_img_mul_4[0] + kernel_img_mul_4[1] + kernel_img_mul_4[2] + 
                kernel_img_mul_4[3] + kernel_img_mul_4[4] + kernel_img_mul_4[5] + 
                kernel_img_mul_4[6] + kernel_img_mul_4[7] + kernel_img_mul_4[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[39:32] <= 'd0;
  else if (current_state==ST_START)
    blur_din[39:32] <= kernel_img_sum_4[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[39:32] <= 'd0;
end

wire  [25:0]  kernel_img_mul_5[0:8];
assign kernel_img_mul_5[0] = buffer_data_2[39:32] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_5[1] = buffer_data_2[47:40] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_5[2] = buffer_data_2[55:48] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_5[3] = buffer_data_1[39:32] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_5[4] = buffer_data_1[47:40] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_5[5] = buffer_data_1[55:48] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_5[6] = buffer_data_0[39:32] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_5[7] = buffer_data_0[47:40] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_5[8] = buffer_data_0[55:48] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_5 = kernel_img_mul_5[0] + kernel_img_mul_5[1] + kernel_img_mul_5[2] + 
                kernel_img_mul_5[3] + kernel_img_mul_5[4] + kernel_img_mul_5[5] + 
                kernel_img_mul_5[6] + kernel_img_mul_5[7] + kernel_img_mul_5[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[47:40] <= 'd0;
  else if (current_state==ST_START)
    blur_din[47:40] <= kernel_img_sum_5[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[47:40] <= 'd0;
end

wire  [25:0]  kernel_img_mul_6[0:8];
assign kernel_img_mul_6[0] = buffer_data_2[47:40] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_6[1] = buffer_data_2[55:48] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_6[2] = buffer_data_2[63:56] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_6[3] = buffer_data_1[47:40] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_6[4] = buffer_data_1[55:48] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_6[5] = buffer_data_1[63:56] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_6[6] = buffer_data_0[47:40] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_6[7] = buffer_data_0[55:48] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_6[8] = buffer_data_0[63:56] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_6 = kernel_img_mul_6[0] + kernel_img_mul_6[1] + kernel_img_mul_6[2] + 
                kernel_img_mul_6[3] + kernel_img_mul_6[4] + kernel_img_mul_6[5] + 
                kernel_img_mul_6[6] + kernel_img_mul_6[7] + kernel_img_mul_6[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[55:48] <= 'd0;
  else if (current_state==ST_START)
    blur_din[55:48] <= kernel_img_sum_6[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[55:48] <= 'd0;
end

wire  [25:0]  kernel_img_mul_7[0:8];
assign kernel_img_mul_7[0] = buffer_data_2[55:48] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_7[1] = buffer_data_2[63:56] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_7[2] = buffer_data_2[71:64] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_7[3] = buffer_data_1[55:48] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_7[4] = buffer_data_1[63:56] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_7[5] = buffer_data_1[71:64] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_7[6] = buffer_data_0[55:48] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_7[7] = buffer_data_0[63:56] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_7[8] = buffer_data_0[71:64] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_7 = kernel_img_mul_7[0] + kernel_img_mul_7[1] + kernel_img_mul_7[2] + 
                kernel_img_mul_7[3] + kernel_img_mul_7[4] + kernel_img_mul_7[5] + 
                kernel_img_mul_7[6] + kernel_img_mul_7[7] + kernel_img_mul_7[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[63:56] <= 'd0;
  else if (current_state==ST_START)
    blur_din[63:56] <= kernel_img_sum_7[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[63:56] <= 'd0;
end

wire  [25:0]  kernel_img_mul_8[0:8];
assign kernel_img_mul_8[0] = buffer_data_2[63:56] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_8[1] = buffer_data_2[71:64] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_8[2] = buffer_data_2[79:72] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_8[3] = buffer_data_1[63:56] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_8[4] = buffer_data_1[71:64] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_8[5] = buffer_data_1[79:72] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_8[6] = buffer_data_0[63:56] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_8[7] = buffer_data_0[71:64] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_8[8] = buffer_data_0[79:72] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_8 = kernel_img_mul_8[0] + kernel_img_mul_8[1] + kernel_img_mul_8[2] + 
                kernel_img_mul_8[3] + kernel_img_mul_8[4] + kernel_img_mul_8[5] + 
                kernel_img_mul_8[6] + kernel_img_mul_8[7] + kernel_img_mul_8[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[71:64] <= 'd0;
  else if (current_state==ST_START)
    blur_din[71:64] <= kernel_img_sum_8[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[71:64] <= 'd0;
end

wire  [25:0]  kernel_img_mul_9[0:8];
assign kernel_img_mul_9[0] = buffer_data_2[71:64] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_9[1] = buffer_data_2[79:72] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_9[2] = buffer_data_2[87:80] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_9[3] = buffer_data_1[71:64] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_9[4] = buffer_data_1[79:72] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_9[5] = buffer_data_1[87:80] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_9[6] = buffer_data_0[71:64] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_9[7] = buffer_data_0[79:72] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_9[8] = buffer_data_0[87:80] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_9 = kernel_img_mul_9[0] + kernel_img_mul_9[1] + kernel_img_mul_9[2] + 
                kernel_img_mul_9[3] + kernel_img_mul_9[4] + kernel_img_mul_9[5] + 
                kernel_img_mul_9[6] + kernel_img_mul_9[7] + kernel_img_mul_9[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[79:72] <= 'd0;
  else if (current_state==ST_START)
    blur_din[79:72] <= kernel_img_sum_9[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[79:72] <= 'd0;
end

wire  [25:0]  kernel_img_mul_10[0:8];
assign kernel_img_mul_10[0] = buffer_data_2[79:72] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_10[1] = buffer_data_2[87:80] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_10[2] = buffer_data_2[95:88] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_10[3] = buffer_data_1[79:72] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_10[4] = buffer_data_1[87:80] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_10[5] = buffer_data_1[95:88] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_10[6] = buffer_data_0[79:72] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_10[7] = buffer_data_0[87:80] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_10[8] = buffer_data_0[95:88] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_10 = kernel_img_mul_10[0] + kernel_img_mul_10[1] + kernel_img_mul_10[2] + 
                kernel_img_mul_10[3] + kernel_img_mul_10[4] + kernel_img_mul_10[5] + 
                kernel_img_mul_10[6] + kernel_img_mul_10[7] + kernel_img_mul_10[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[87:80] <= 'd0;
  else if (current_state==ST_START)
    blur_din[87:80] <= kernel_img_sum_10[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[87:80] <= 'd0;
end

wire  [25:0]  kernel_img_mul_11[0:8];
assign kernel_img_mul_11[0] = buffer_data_2[87:80] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_11[1] = buffer_data_2[95:88] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_11[2] = buffer_data_2[103:96] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_11[3] = buffer_data_1[87:80] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_11[4] = buffer_data_1[95:88] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_11[5] = buffer_data_1[103:96] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_11[6] = buffer_data_0[87:80] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_11[7] = buffer_data_0[95:88] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_11[8] = buffer_data_0[103:96] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_11 = kernel_img_mul_11[0] + kernel_img_mul_11[1] + kernel_img_mul_11[2] + 
                kernel_img_mul_11[3] + kernel_img_mul_11[4] + kernel_img_mul_11[5] + 
                kernel_img_mul_11[6] + kernel_img_mul_11[7] + kernel_img_mul_11[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[95:88] <= 'd0;
  else if (current_state==ST_START)
    blur_din[95:88] <= kernel_img_sum_11[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[95:88] <= 'd0;
end

wire  [25:0]  kernel_img_mul_12[0:8];
assign kernel_img_mul_12[0] = buffer_data_2[95:88] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_12[1] = buffer_data_2[103:96] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_12[2] = buffer_data_2[111:104] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_12[3] = buffer_data_1[95:88] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_12[4] = buffer_data_1[103:96] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_12[5] = buffer_data_1[111:104] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_12[6] = buffer_data_0[95:88] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_12[7] = buffer_data_0[103:96] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_12[8] = buffer_data_0[111:104] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_12 = kernel_img_mul_12[0] + kernel_img_mul_12[1] + kernel_img_mul_12[2] + 
                kernel_img_mul_12[3] + kernel_img_mul_12[4] + kernel_img_mul_12[5] + 
                kernel_img_mul_12[6] + kernel_img_mul_12[7] + kernel_img_mul_12[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[103:96] <= 'd0;
  else if (current_state==ST_START)
    blur_din[103:96] <= kernel_img_sum_12[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[103:96] <= 'd0;
end

wire  [25:0]  kernel_img_mul_13[0:8];
assign kernel_img_mul_13[0] = buffer_data_2[103:96] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_13[1] = buffer_data_2[111:104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_13[2] = buffer_data_2[119:112] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_13[3] = buffer_data_1[103:96] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_13[4] = buffer_data_1[111:104] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_13[5] = buffer_data_1[119:112] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_13[6] = buffer_data_0[103:96] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_13[7] = buffer_data_0[111:104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_13[8] = buffer_data_0[119:112] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_13 = kernel_img_mul_13[0] + kernel_img_mul_13[1] + kernel_img_mul_13[2] + 
                kernel_img_mul_13[3] + kernel_img_mul_13[4] + kernel_img_mul_13[5] + 
                kernel_img_mul_13[6] + kernel_img_mul_13[7] + kernel_img_mul_13[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[111:104] <= 'd0;
  else if (current_state==ST_START)
    blur_din[111:104] <= kernel_img_sum_13[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[111:104] <= 'd0;
end

wire  [25:0]  kernel_img_mul_14[0:8];
assign kernel_img_mul_14[0] = buffer_data_2[111:104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_14[1] = buffer_data_2[119:112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_14[2] = buffer_data_2[127:120] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_14[3] = buffer_data_1[111:104] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_14[4] = buffer_data_1[119:112] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_14[5] = buffer_data_1[127:120] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_14[6] = buffer_data_0[111:104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_14[7] = buffer_data_0[119:112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_14[8] = buffer_data_0[127:120] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_14 = kernel_img_mul_14[0] + kernel_img_mul_14[1] + kernel_img_mul_14[2] + 
                kernel_img_mul_14[3] + kernel_img_mul_14[4] + kernel_img_mul_14[5] + 
                kernel_img_mul_14[6] + kernel_img_mul_14[7] + kernel_img_mul_14[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[119:112] <= 'd0;
  else if (current_state==ST_START)
    blur_din[119:112] <= kernel_img_sum_14[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[119:112] <= 'd0;
end

wire  [25:0]  kernel_img_mul_15[0:8];
assign kernel_img_mul_15[0] = buffer_data_2[119:112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_15[1] = buffer_data_2[127:120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_15[2] = buffer_data_2[135:128] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_15[3] = buffer_data_1[119:112] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_15[4] = buffer_data_1[127:120] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_15[5] = buffer_data_1[135:128] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_15[6] = buffer_data_0[119:112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_15[7] = buffer_data_0[127:120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_15[8] = buffer_data_0[135:128] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_15 = kernel_img_mul_15[0] + kernel_img_mul_15[1] + kernel_img_mul_15[2] + 
                kernel_img_mul_15[3] + kernel_img_mul_15[4] + kernel_img_mul_15[5] + 
                kernel_img_mul_15[6] + kernel_img_mul_15[7] + kernel_img_mul_15[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[127:120] <= 'd0;
  else if (current_state==ST_START)
    blur_din[127:120] <= kernel_img_sum_15[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[127:120] <= 'd0;
end

wire  [25:0]  kernel_img_mul_16[0:8];
assign kernel_img_mul_16[0] = buffer_data_2[127:120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_16[1] = buffer_data_2[135:128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_16[2] = buffer_data_2[143:136] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_16[3] = buffer_data_1[127:120] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_16[4] = buffer_data_1[135:128] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_16[5] = buffer_data_1[143:136] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_16[6] = buffer_data_0[127:120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_16[7] = buffer_data_0[135:128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_16[8] = buffer_data_0[143:136] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_16 = kernel_img_mul_16[0] + kernel_img_mul_16[1] + kernel_img_mul_16[2] + 
                kernel_img_mul_16[3] + kernel_img_mul_16[4] + kernel_img_mul_16[5] + 
                kernel_img_mul_16[6] + kernel_img_mul_16[7] + kernel_img_mul_16[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[135:128] <= 'd0;
  else if (current_state==ST_START)
    blur_din[135:128] <= kernel_img_sum_16[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[135:128] <= 'd0;
end

wire  [25:0]  kernel_img_mul_17[0:8];
assign kernel_img_mul_17[0] = buffer_data_2[135:128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_17[1] = buffer_data_2[143:136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_17[2] = buffer_data_2[151:144] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_17[3] = buffer_data_1[135:128] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_17[4] = buffer_data_1[143:136] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_17[5] = buffer_data_1[151:144] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_17[6] = buffer_data_0[135:128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_17[7] = buffer_data_0[143:136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_17[8] = buffer_data_0[151:144] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_17 = kernel_img_mul_17[0] + kernel_img_mul_17[1] + kernel_img_mul_17[2] + 
                kernel_img_mul_17[3] + kernel_img_mul_17[4] + kernel_img_mul_17[5] + 
                kernel_img_mul_17[6] + kernel_img_mul_17[7] + kernel_img_mul_17[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[143:136] <= 'd0;
  else if (current_state==ST_START)
    blur_din[143:136] <= kernel_img_sum_17[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[143:136] <= 'd0;
end

wire  [25:0]  kernel_img_mul_18[0:8];
assign kernel_img_mul_18[0] = buffer_data_2[143:136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_18[1] = buffer_data_2[151:144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_18[2] = buffer_data_2[159:152] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_18[3] = buffer_data_1[143:136] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_18[4] = buffer_data_1[151:144] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_18[5] = buffer_data_1[159:152] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_18[6] = buffer_data_0[143:136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_18[7] = buffer_data_0[151:144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_18[8] = buffer_data_0[159:152] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_18 = kernel_img_mul_18[0] + kernel_img_mul_18[1] + kernel_img_mul_18[2] + 
                kernel_img_mul_18[3] + kernel_img_mul_18[4] + kernel_img_mul_18[5] + 
                kernel_img_mul_18[6] + kernel_img_mul_18[7] + kernel_img_mul_18[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[151:144] <= 'd0;
  else if (current_state==ST_START)
    blur_din[151:144] <= kernel_img_sum_18[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[151:144] <= 'd0;
end

wire  [25:0]  kernel_img_mul_19[0:8];
assign kernel_img_mul_19[0] = buffer_data_2[151:144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_19[1] = buffer_data_2[159:152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_19[2] = buffer_data_2[167:160] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_19[3] = buffer_data_1[151:144] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_19[4] = buffer_data_1[159:152] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_19[5] = buffer_data_1[167:160] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_19[6] = buffer_data_0[151:144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_19[7] = buffer_data_0[159:152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_19[8] = buffer_data_0[167:160] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_19 = kernel_img_mul_19[0] + kernel_img_mul_19[1] + kernel_img_mul_19[2] + 
                kernel_img_mul_19[3] + kernel_img_mul_19[4] + kernel_img_mul_19[5] + 
                kernel_img_mul_19[6] + kernel_img_mul_19[7] + kernel_img_mul_19[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[159:152] <= 'd0;
  else if (current_state==ST_START)
    blur_din[159:152] <= kernel_img_sum_19[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[159:152] <= 'd0;
end

wire  [25:0]  kernel_img_mul_20[0:8];
assign kernel_img_mul_20[0] = buffer_data_2[159:152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_20[1] = buffer_data_2[167:160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_20[2] = buffer_data_2[175:168] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_20[3] = buffer_data_1[159:152] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_20[4] = buffer_data_1[167:160] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_20[5] = buffer_data_1[175:168] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_20[6] = buffer_data_0[159:152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_20[7] = buffer_data_0[167:160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_20[8] = buffer_data_0[175:168] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_20 = kernel_img_mul_20[0] + kernel_img_mul_20[1] + kernel_img_mul_20[2] + 
                kernel_img_mul_20[3] + kernel_img_mul_20[4] + kernel_img_mul_20[5] + 
                kernel_img_mul_20[6] + kernel_img_mul_20[7] + kernel_img_mul_20[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[167:160] <= 'd0;
  else if (current_state==ST_START)
    blur_din[167:160] <= kernel_img_sum_20[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[167:160] <= 'd0;
end

wire  [25:0]  kernel_img_mul_21[0:8];
assign kernel_img_mul_21[0] = buffer_data_2[167:160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_21[1] = buffer_data_2[175:168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_21[2] = buffer_data_2[183:176] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_21[3] = buffer_data_1[167:160] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_21[4] = buffer_data_1[175:168] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_21[5] = buffer_data_1[183:176] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_21[6] = buffer_data_0[167:160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_21[7] = buffer_data_0[175:168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_21[8] = buffer_data_0[183:176] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_21 = kernel_img_mul_21[0] + kernel_img_mul_21[1] + kernel_img_mul_21[2] + 
                kernel_img_mul_21[3] + kernel_img_mul_21[4] + kernel_img_mul_21[5] + 
                kernel_img_mul_21[6] + kernel_img_mul_21[7] + kernel_img_mul_21[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[175:168] <= 'd0;
  else if (current_state==ST_START)
    blur_din[175:168] <= kernel_img_sum_21[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[175:168] <= 'd0;
end

wire  [25:0]  kernel_img_mul_22[0:8];
assign kernel_img_mul_22[0] = buffer_data_2[175:168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_22[1] = buffer_data_2[183:176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_22[2] = buffer_data_2[191:184] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_22[3] = buffer_data_1[175:168] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_22[4] = buffer_data_1[183:176] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_22[5] = buffer_data_1[191:184] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_22[6] = buffer_data_0[175:168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_22[7] = buffer_data_0[183:176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_22[8] = buffer_data_0[191:184] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_22 = kernel_img_mul_22[0] + kernel_img_mul_22[1] + kernel_img_mul_22[2] + 
                kernel_img_mul_22[3] + kernel_img_mul_22[4] + kernel_img_mul_22[5] + 
                kernel_img_mul_22[6] + kernel_img_mul_22[7] + kernel_img_mul_22[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[183:176] <= 'd0;
  else if (current_state==ST_START)
    blur_din[183:176] <= kernel_img_sum_22[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[183:176] <= 'd0;
end

wire  [25:0]  kernel_img_mul_23[0:8];
assign kernel_img_mul_23[0] = buffer_data_2[183:176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_23[1] = buffer_data_2[191:184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_23[2] = buffer_data_2[199:192] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_23[3] = buffer_data_1[183:176] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_23[4] = buffer_data_1[191:184] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_23[5] = buffer_data_1[199:192] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_23[6] = buffer_data_0[183:176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_23[7] = buffer_data_0[191:184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_23[8] = buffer_data_0[199:192] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_23 = kernel_img_mul_23[0] + kernel_img_mul_23[1] + kernel_img_mul_23[2] + 
                kernel_img_mul_23[3] + kernel_img_mul_23[4] + kernel_img_mul_23[5] + 
                kernel_img_mul_23[6] + kernel_img_mul_23[7] + kernel_img_mul_23[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[191:184] <= 'd0;
  else if (current_state==ST_START)
    blur_din[191:184] <= kernel_img_sum_23[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[191:184] <= 'd0;
end

wire  [25:0]  kernel_img_mul_24[0:8];
assign kernel_img_mul_24[0] = buffer_data_2[191:184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_24[1] = buffer_data_2[199:192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_24[2] = buffer_data_2[207:200] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_24[3] = buffer_data_1[191:184] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_24[4] = buffer_data_1[199:192] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_24[5] = buffer_data_1[207:200] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_24[6] = buffer_data_0[191:184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_24[7] = buffer_data_0[199:192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_24[8] = buffer_data_0[207:200] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_24 = kernel_img_mul_24[0] + kernel_img_mul_24[1] + kernel_img_mul_24[2] + 
                kernel_img_mul_24[3] + kernel_img_mul_24[4] + kernel_img_mul_24[5] + 
                kernel_img_mul_24[6] + kernel_img_mul_24[7] + kernel_img_mul_24[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[199:192] <= 'd0;
  else if (current_state==ST_START)
    blur_din[199:192] <= kernel_img_sum_24[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[199:192] <= 'd0;
end

wire  [25:0]  kernel_img_mul_25[0:8];
assign kernel_img_mul_25[0] = buffer_data_2[199:192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_25[1] = buffer_data_2[207:200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_25[2] = buffer_data_2[215:208] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_25[3] = buffer_data_1[199:192] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_25[4] = buffer_data_1[207:200] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_25[5] = buffer_data_1[215:208] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_25[6] = buffer_data_0[199:192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_25[7] = buffer_data_0[207:200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_25[8] = buffer_data_0[215:208] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_25 = kernel_img_mul_25[0] + kernel_img_mul_25[1] + kernel_img_mul_25[2] + 
                kernel_img_mul_25[3] + kernel_img_mul_25[4] + kernel_img_mul_25[5] + 
                kernel_img_mul_25[6] + kernel_img_mul_25[7] + kernel_img_mul_25[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[207:200] <= 'd0;
  else if (current_state==ST_START)
    blur_din[207:200] <= kernel_img_sum_25[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[207:200] <= 'd0;
end

wire  [25:0]  kernel_img_mul_26[0:8];
assign kernel_img_mul_26[0] = buffer_data_2[207:200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_26[1] = buffer_data_2[215:208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_26[2] = buffer_data_2[223:216] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_26[3] = buffer_data_1[207:200] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_26[4] = buffer_data_1[215:208] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_26[5] = buffer_data_1[223:216] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_26[6] = buffer_data_0[207:200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_26[7] = buffer_data_0[215:208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_26[8] = buffer_data_0[223:216] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_26 = kernel_img_mul_26[0] + kernel_img_mul_26[1] + kernel_img_mul_26[2] + 
                kernel_img_mul_26[3] + kernel_img_mul_26[4] + kernel_img_mul_26[5] + 
                kernel_img_mul_26[6] + kernel_img_mul_26[7] + kernel_img_mul_26[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[215:208] <= 'd0;
  else if (current_state==ST_START)
    blur_din[215:208] <= kernel_img_sum_26[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[215:208] <= 'd0;
end

wire  [25:0]  kernel_img_mul_27[0:8];
assign kernel_img_mul_27[0] = buffer_data_2[215:208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_27[1] = buffer_data_2[223:216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_27[2] = buffer_data_2[231:224] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_27[3] = buffer_data_1[215:208] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_27[4] = buffer_data_1[223:216] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_27[5] = buffer_data_1[231:224] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_27[6] = buffer_data_0[215:208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_27[7] = buffer_data_0[223:216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_27[8] = buffer_data_0[231:224] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_27 = kernel_img_mul_27[0] + kernel_img_mul_27[1] + kernel_img_mul_27[2] + 
                kernel_img_mul_27[3] + kernel_img_mul_27[4] + kernel_img_mul_27[5] + 
                kernel_img_mul_27[6] + kernel_img_mul_27[7] + kernel_img_mul_27[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[223:216] <= 'd0;
  else if (current_state==ST_START)
    blur_din[223:216] <= kernel_img_sum_27[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[223:216] <= 'd0;
end

wire  [25:0]  kernel_img_mul_28[0:8];
assign kernel_img_mul_28[0] = buffer_data_2[223:216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_28[1] = buffer_data_2[231:224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_28[2] = buffer_data_2[239:232] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_28[3] = buffer_data_1[223:216] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_28[4] = buffer_data_1[231:224] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_28[5] = buffer_data_1[239:232] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_28[6] = buffer_data_0[223:216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_28[7] = buffer_data_0[231:224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_28[8] = buffer_data_0[239:232] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_28 = kernel_img_mul_28[0] + kernel_img_mul_28[1] + kernel_img_mul_28[2] + 
                kernel_img_mul_28[3] + kernel_img_mul_28[4] + kernel_img_mul_28[5] + 
                kernel_img_mul_28[6] + kernel_img_mul_28[7] + kernel_img_mul_28[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[231:224] <= 'd0;
  else if (current_state==ST_START)
    blur_din[231:224] <= kernel_img_sum_28[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[231:224] <= 'd0;
end

wire  [25:0]  kernel_img_mul_29[0:8];
assign kernel_img_mul_29[0] = buffer_data_2[231:224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_29[1] = buffer_data_2[239:232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_29[2] = buffer_data_2[247:240] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_29[3] = buffer_data_1[231:224] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_29[4] = buffer_data_1[239:232] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_29[5] = buffer_data_1[247:240] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_29[6] = buffer_data_0[231:224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_29[7] = buffer_data_0[239:232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_29[8] = buffer_data_0[247:240] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_29 = kernel_img_mul_29[0] + kernel_img_mul_29[1] + kernel_img_mul_29[2] + 
                kernel_img_mul_29[3] + kernel_img_mul_29[4] + kernel_img_mul_29[5] + 
                kernel_img_mul_29[6] + kernel_img_mul_29[7] + kernel_img_mul_29[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[239:232] <= 'd0;
  else if (current_state==ST_START)
    blur_din[239:232] <= kernel_img_sum_29[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[239:232] <= 'd0;
end

wire  [25:0]  kernel_img_mul_30[0:8];
assign kernel_img_mul_30[0] = buffer_data_2[239:232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_30[1] = buffer_data_2[247:240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_30[2] = buffer_data_2[255:248] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_30[3] = buffer_data_1[239:232] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_30[4] = buffer_data_1[247:240] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_30[5] = buffer_data_1[255:248] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_30[6] = buffer_data_0[239:232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_30[7] = buffer_data_0[247:240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_30[8] = buffer_data_0[255:248] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_30 = kernel_img_mul_30[0] + kernel_img_mul_30[1] + kernel_img_mul_30[2] + 
                kernel_img_mul_30[3] + kernel_img_mul_30[4] + kernel_img_mul_30[5] + 
                kernel_img_mul_30[6] + kernel_img_mul_30[7] + kernel_img_mul_30[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[247:240] <= 'd0;
  else if (current_state==ST_START)
    blur_din[247:240] <= kernel_img_sum_30[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[247:240] <= 'd0;
end

wire  [25:0]  kernel_img_mul_31[0:8];
assign kernel_img_mul_31[0] = buffer_data_2[247:240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_31[1] = buffer_data_2[255:248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_31[2] = buffer_data_2[263:256] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_31[3] = buffer_data_1[247:240] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_31[4] = buffer_data_1[255:248] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_31[5] = buffer_data_1[263:256] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_31[6] = buffer_data_0[247:240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_31[7] = buffer_data_0[255:248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_31[8] = buffer_data_0[263:256] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_31 = kernel_img_mul_31[0] + kernel_img_mul_31[1] + kernel_img_mul_31[2] + 
                kernel_img_mul_31[3] + kernel_img_mul_31[4] + kernel_img_mul_31[5] + 
                kernel_img_mul_31[6] + kernel_img_mul_31[7] + kernel_img_mul_31[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[255:248] <= 'd0;
  else if (current_state==ST_START)
    blur_din[255:248] <= kernel_img_sum_31[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[255:248] <= 'd0;
end

wire  [25:0]  kernel_img_mul_32[0:8];
assign kernel_img_mul_32[0] = buffer_data_2[255:248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_32[1] = buffer_data_2[263:256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_32[2] = buffer_data_2[271:264] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_32[3] = buffer_data_1[255:248] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_32[4] = buffer_data_1[263:256] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_32[5] = buffer_data_1[271:264] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_32[6] = buffer_data_0[255:248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_32[7] = buffer_data_0[263:256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_32[8] = buffer_data_0[271:264] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_32 = kernel_img_mul_32[0] + kernel_img_mul_32[1] + kernel_img_mul_32[2] + 
                kernel_img_mul_32[3] + kernel_img_mul_32[4] + kernel_img_mul_32[5] + 
                kernel_img_mul_32[6] + kernel_img_mul_32[7] + kernel_img_mul_32[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[263:256] <= 'd0;
  else if (current_state==ST_START)
    blur_din[263:256] <= kernel_img_sum_32[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[263:256] <= 'd0;
end

wire  [25:0]  kernel_img_mul_33[0:8];
assign kernel_img_mul_33[0] = buffer_data_2[263:256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_33[1] = buffer_data_2[271:264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_33[2] = buffer_data_2[279:272] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_33[3] = buffer_data_1[263:256] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_33[4] = buffer_data_1[271:264] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_33[5] = buffer_data_1[279:272] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_33[6] = buffer_data_0[263:256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_33[7] = buffer_data_0[271:264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_33[8] = buffer_data_0[279:272] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_33 = kernel_img_mul_33[0] + kernel_img_mul_33[1] + kernel_img_mul_33[2] + 
                kernel_img_mul_33[3] + kernel_img_mul_33[4] + kernel_img_mul_33[5] + 
                kernel_img_mul_33[6] + kernel_img_mul_33[7] + kernel_img_mul_33[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[271:264] <= 'd0;
  else if (current_state==ST_START)
    blur_din[271:264] <= kernel_img_sum_33[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[271:264] <= 'd0;
end

wire  [25:0]  kernel_img_mul_34[0:8];
assign kernel_img_mul_34[0] = buffer_data_2[271:264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_34[1] = buffer_data_2[279:272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_34[2] = buffer_data_2[287:280] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_34[3] = buffer_data_1[271:264] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_34[4] = buffer_data_1[279:272] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_34[5] = buffer_data_1[287:280] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_34[6] = buffer_data_0[271:264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_34[7] = buffer_data_0[279:272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_34[8] = buffer_data_0[287:280] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_34 = kernel_img_mul_34[0] + kernel_img_mul_34[1] + kernel_img_mul_34[2] + 
                kernel_img_mul_34[3] + kernel_img_mul_34[4] + kernel_img_mul_34[5] + 
                kernel_img_mul_34[6] + kernel_img_mul_34[7] + kernel_img_mul_34[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[279:272] <= 'd0;
  else if (current_state==ST_START)
    blur_din[279:272] <= kernel_img_sum_34[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[279:272] <= 'd0;
end

wire  [25:0]  kernel_img_mul_35[0:8];
assign kernel_img_mul_35[0] = buffer_data_2[279:272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_35[1] = buffer_data_2[287:280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_35[2] = buffer_data_2[295:288] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_35[3] = buffer_data_1[279:272] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_35[4] = buffer_data_1[287:280] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_35[5] = buffer_data_1[295:288] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_35[6] = buffer_data_0[279:272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_35[7] = buffer_data_0[287:280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_35[8] = buffer_data_0[295:288] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_35 = kernel_img_mul_35[0] + kernel_img_mul_35[1] + kernel_img_mul_35[2] + 
                kernel_img_mul_35[3] + kernel_img_mul_35[4] + kernel_img_mul_35[5] + 
                kernel_img_mul_35[6] + kernel_img_mul_35[7] + kernel_img_mul_35[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[287:280] <= 'd0;
  else if (current_state==ST_START)
    blur_din[287:280] <= kernel_img_sum_35[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[287:280] <= 'd0;
end

wire  [25:0]  kernel_img_mul_36[0:8];
assign kernel_img_mul_36[0] = buffer_data_2[287:280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_36[1] = buffer_data_2[295:288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_36[2] = buffer_data_2[303:296] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_36[3] = buffer_data_1[287:280] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_36[4] = buffer_data_1[295:288] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_36[5] = buffer_data_1[303:296] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_36[6] = buffer_data_0[287:280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_36[7] = buffer_data_0[295:288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_36[8] = buffer_data_0[303:296] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_36 = kernel_img_mul_36[0] + kernel_img_mul_36[1] + kernel_img_mul_36[2] + 
                kernel_img_mul_36[3] + kernel_img_mul_36[4] + kernel_img_mul_36[5] + 
                kernel_img_mul_36[6] + kernel_img_mul_36[7] + kernel_img_mul_36[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[295:288] <= 'd0;
  else if (current_state==ST_START)
    blur_din[295:288] <= kernel_img_sum_36[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[295:288] <= 'd0;
end

wire  [25:0]  kernel_img_mul_37[0:8];
assign kernel_img_mul_37[0] = buffer_data_2[295:288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_37[1] = buffer_data_2[303:296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_37[2] = buffer_data_2[311:304] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_37[3] = buffer_data_1[295:288] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_37[4] = buffer_data_1[303:296] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_37[5] = buffer_data_1[311:304] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_37[6] = buffer_data_0[295:288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_37[7] = buffer_data_0[303:296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_37[8] = buffer_data_0[311:304] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_37 = kernel_img_mul_37[0] + kernel_img_mul_37[1] + kernel_img_mul_37[2] + 
                kernel_img_mul_37[3] + kernel_img_mul_37[4] + kernel_img_mul_37[5] + 
                kernel_img_mul_37[6] + kernel_img_mul_37[7] + kernel_img_mul_37[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[303:296] <= 'd0;
  else if (current_state==ST_START)
    blur_din[303:296] <= kernel_img_sum_37[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[303:296] <= 'd0;
end

wire  [25:0]  kernel_img_mul_38[0:8];
assign kernel_img_mul_38[0] = buffer_data_2[303:296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_38[1] = buffer_data_2[311:304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_38[2] = buffer_data_2[319:312] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_38[3] = buffer_data_1[303:296] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_38[4] = buffer_data_1[311:304] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_38[5] = buffer_data_1[319:312] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_38[6] = buffer_data_0[303:296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_38[7] = buffer_data_0[311:304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_38[8] = buffer_data_0[319:312] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_38 = kernel_img_mul_38[0] + kernel_img_mul_38[1] + kernel_img_mul_38[2] + 
                kernel_img_mul_38[3] + kernel_img_mul_38[4] + kernel_img_mul_38[5] + 
                kernel_img_mul_38[6] + kernel_img_mul_38[7] + kernel_img_mul_38[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[311:304] <= 'd0;
  else if (current_state==ST_START)
    blur_din[311:304] <= kernel_img_sum_38[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[311:304] <= 'd0;
end

wire  [25:0]  kernel_img_mul_39[0:8];
assign kernel_img_mul_39[0] = buffer_data_2[311:304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_39[1] = buffer_data_2[319:312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_39[2] = buffer_data_2[327:320] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_39[3] = buffer_data_1[311:304] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_39[4] = buffer_data_1[319:312] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_39[5] = buffer_data_1[327:320] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_39[6] = buffer_data_0[311:304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_39[7] = buffer_data_0[319:312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_39[8] = buffer_data_0[327:320] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_39 = kernel_img_mul_39[0] + kernel_img_mul_39[1] + kernel_img_mul_39[2] + 
                kernel_img_mul_39[3] + kernel_img_mul_39[4] + kernel_img_mul_39[5] + 
                kernel_img_mul_39[6] + kernel_img_mul_39[7] + kernel_img_mul_39[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[319:312] <= 'd0;
  else if (current_state==ST_START)
    blur_din[319:312] <= kernel_img_sum_39[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[319:312] <= 'd0;
end

wire  [25:0]  kernel_img_mul_40[0:8];
assign kernel_img_mul_40[0] = buffer_data_2[319:312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_40[1] = buffer_data_2[327:320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_40[2] = buffer_data_2[335:328] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_40[3] = buffer_data_1[319:312] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_40[4] = buffer_data_1[327:320] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_40[5] = buffer_data_1[335:328] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_40[6] = buffer_data_0[319:312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_40[7] = buffer_data_0[327:320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_40[8] = buffer_data_0[335:328] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_40 = kernel_img_mul_40[0] + kernel_img_mul_40[1] + kernel_img_mul_40[2] + 
                kernel_img_mul_40[3] + kernel_img_mul_40[4] + kernel_img_mul_40[5] + 
                kernel_img_mul_40[6] + kernel_img_mul_40[7] + kernel_img_mul_40[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[327:320] <= 'd0;
  else if (current_state==ST_START)
    blur_din[327:320] <= kernel_img_sum_40[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[327:320] <= 'd0;
end

wire  [25:0]  kernel_img_mul_41[0:8];
assign kernel_img_mul_41[0] = buffer_data_2[327:320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_41[1] = buffer_data_2[335:328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_41[2] = buffer_data_2[343:336] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_41[3] = buffer_data_1[327:320] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_41[4] = buffer_data_1[335:328] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_41[5] = buffer_data_1[343:336] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_41[6] = buffer_data_0[327:320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_41[7] = buffer_data_0[335:328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_41[8] = buffer_data_0[343:336] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_41 = kernel_img_mul_41[0] + kernel_img_mul_41[1] + kernel_img_mul_41[2] + 
                kernel_img_mul_41[3] + kernel_img_mul_41[4] + kernel_img_mul_41[5] + 
                kernel_img_mul_41[6] + kernel_img_mul_41[7] + kernel_img_mul_41[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[335:328] <= 'd0;
  else if (current_state==ST_START)
    blur_din[335:328] <= kernel_img_sum_41[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[335:328] <= 'd0;
end

wire  [25:0]  kernel_img_mul_42[0:8];
assign kernel_img_mul_42[0] = buffer_data_2[335:328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_42[1] = buffer_data_2[343:336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_42[2] = buffer_data_2[351:344] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_42[3] = buffer_data_1[335:328] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_42[4] = buffer_data_1[343:336] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_42[5] = buffer_data_1[351:344] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_42[6] = buffer_data_0[335:328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_42[7] = buffer_data_0[343:336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_42[8] = buffer_data_0[351:344] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_42 = kernel_img_mul_42[0] + kernel_img_mul_42[1] + kernel_img_mul_42[2] + 
                kernel_img_mul_42[3] + kernel_img_mul_42[4] + kernel_img_mul_42[5] + 
                kernel_img_mul_42[6] + kernel_img_mul_42[7] + kernel_img_mul_42[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[343:336] <= 'd0;
  else if (current_state==ST_START)
    blur_din[343:336] <= kernel_img_sum_42[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[343:336] <= 'd0;
end

wire  [25:0]  kernel_img_mul_43[0:8];
assign kernel_img_mul_43[0] = buffer_data_2[343:336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_43[1] = buffer_data_2[351:344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_43[2] = buffer_data_2[359:352] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_43[3] = buffer_data_1[343:336] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_43[4] = buffer_data_1[351:344] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_43[5] = buffer_data_1[359:352] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_43[6] = buffer_data_0[343:336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_43[7] = buffer_data_0[351:344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_43[8] = buffer_data_0[359:352] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_43 = kernel_img_mul_43[0] + kernel_img_mul_43[1] + kernel_img_mul_43[2] + 
                kernel_img_mul_43[3] + kernel_img_mul_43[4] + kernel_img_mul_43[5] + 
                kernel_img_mul_43[6] + kernel_img_mul_43[7] + kernel_img_mul_43[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[351:344] <= 'd0;
  else if (current_state==ST_START)
    blur_din[351:344] <= kernel_img_sum_43[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[351:344] <= 'd0;
end

wire  [25:0]  kernel_img_mul_44[0:8];
assign kernel_img_mul_44[0] = buffer_data_2[351:344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_44[1] = buffer_data_2[359:352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_44[2] = buffer_data_2[367:360] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_44[3] = buffer_data_1[351:344] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_44[4] = buffer_data_1[359:352] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_44[5] = buffer_data_1[367:360] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_44[6] = buffer_data_0[351:344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_44[7] = buffer_data_0[359:352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_44[8] = buffer_data_0[367:360] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_44 = kernel_img_mul_44[0] + kernel_img_mul_44[1] + kernel_img_mul_44[2] + 
                kernel_img_mul_44[3] + kernel_img_mul_44[4] + kernel_img_mul_44[5] + 
                kernel_img_mul_44[6] + kernel_img_mul_44[7] + kernel_img_mul_44[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[359:352] <= 'd0;
  else if (current_state==ST_START)
    blur_din[359:352] <= kernel_img_sum_44[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[359:352] <= 'd0;
end

wire  [25:0]  kernel_img_mul_45[0:8];
assign kernel_img_mul_45[0] = buffer_data_2[359:352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_45[1] = buffer_data_2[367:360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_45[2] = buffer_data_2[375:368] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_45[3] = buffer_data_1[359:352] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_45[4] = buffer_data_1[367:360] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_45[5] = buffer_data_1[375:368] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_45[6] = buffer_data_0[359:352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_45[7] = buffer_data_0[367:360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_45[8] = buffer_data_0[375:368] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_45 = kernel_img_mul_45[0] + kernel_img_mul_45[1] + kernel_img_mul_45[2] + 
                kernel_img_mul_45[3] + kernel_img_mul_45[4] + kernel_img_mul_45[5] + 
                kernel_img_mul_45[6] + kernel_img_mul_45[7] + kernel_img_mul_45[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[367:360] <= 'd0;
  else if (current_state==ST_START)
    blur_din[367:360] <= kernel_img_sum_45[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[367:360] <= 'd0;
end

wire  [25:0]  kernel_img_mul_46[0:8];
assign kernel_img_mul_46[0] = buffer_data_2[367:360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_46[1] = buffer_data_2[375:368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_46[2] = buffer_data_2[383:376] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_46[3] = buffer_data_1[367:360] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_46[4] = buffer_data_1[375:368] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_46[5] = buffer_data_1[383:376] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_46[6] = buffer_data_0[367:360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_46[7] = buffer_data_0[375:368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_46[8] = buffer_data_0[383:376] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_46 = kernel_img_mul_46[0] + kernel_img_mul_46[1] + kernel_img_mul_46[2] + 
                kernel_img_mul_46[3] + kernel_img_mul_46[4] + kernel_img_mul_46[5] + 
                kernel_img_mul_46[6] + kernel_img_mul_46[7] + kernel_img_mul_46[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[375:368] <= 'd0;
  else if (current_state==ST_START)
    blur_din[375:368] <= kernel_img_sum_46[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[375:368] <= 'd0;
end

wire  [25:0]  kernel_img_mul_47[0:8];
assign kernel_img_mul_47[0] = buffer_data_2[375:368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_47[1] = buffer_data_2[383:376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_47[2] = buffer_data_2[391:384] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_47[3] = buffer_data_1[375:368] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_47[4] = buffer_data_1[383:376] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_47[5] = buffer_data_1[391:384] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_47[6] = buffer_data_0[375:368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_47[7] = buffer_data_0[383:376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_47[8] = buffer_data_0[391:384] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_47 = kernel_img_mul_47[0] + kernel_img_mul_47[1] + kernel_img_mul_47[2] + 
                kernel_img_mul_47[3] + kernel_img_mul_47[4] + kernel_img_mul_47[5] + 
                kernel_img_mul_47[6] + kernel_img_mul_47[7] + kernel_img_mul_47[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[383:376] <= 'd0;
  else if (current_state==ST_START)
    blur_din[383:376] <= kernel_img_sum_47[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[383:376] <= 'd0;
end

wire  [25:0]  kernel_img_mul_48[0:8];
assign kernel_img_mul_48[0] = buffer_data_2[383:376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_48[1] = buffer_data_2[391:384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_48[2] = buffer_data_2[399:392] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_48[3] = buffer_data_1[383:376] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_48[4] = buffer_data_1[391:384] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_48[5] = buffer_data_1[399:392] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_48[6] = buffer_data_0[383:376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_48[7] = buffer_data_0[391:384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_48[8] = buffer_data_0[399:392] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_48 = kernel_img_mul_48[0] + kernel_img_mul_48[1] + kernel_img_mul_48[2] + 
                kernel_img_mul_48[3] + kernel_img_mul_48[4] + kernel_img_mul_48[5] + 
                kernel_img_mul_48[6] + kernel_img_mul_48[7] + kernel_img_mul_48[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[391:384] <= 'd0;
  else if (current_state==ST_START)
    blur_din[391:384] <= kernel_img_sum_48[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[391:384] <= 'd0;
end

wire  [25:0]  kernel_img_mul_49[0:8];
assign kernel_img_mul_49[0] = buffer_data_2[391:384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_49[1] = buffer_data_2[399:392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_49[2] = buffer_data_2[407:400] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_49[3] = buffer_data_1[391:384] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_49[4] = buffer_data_1[399:392] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_49[5] = buffer_data_1[407:400] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_49[6] = buffer_data_0[391:384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_49[7] = buffer_data_0[399:392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_49[8] = buffer_data_0[407:400] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_49 = kernel_img_mul_49[0] + kernel_img_mul_49[1] + kernel_img_mul_49[2] + 
                kernel_img_mul_49[3] + kernel_img_mul_49[4] + kernel_img_mul_49[5] + 
                kernel_img_mul_49[6] + kernel_img_mul_49[7] + kernel_img_mul_49[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[399:392] <= 'd0;
  else if (current_state==ST_START)
    blur_din[399:392] <= kernel_img_sum_49[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[399:392] <= 'd0;
end

wire  [25:0]  kernel_img_mul_50[0:8];
assign kernel_img_mul_50[0] = buffer_data_2[399:392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_50[1] = buffer_data_2[407:400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_50[2] = buffer_data_2[415:408] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_50[3] = buffer_data_1[399:392] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_50[4] = buffer_data_1[407:400] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_50[5] = buffer_data_1[415:408] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_50[6] = buffer_data_0[399:392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_50[7] = buffer_data_0[407:400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_50[8] = buffer_data_0[415:408] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_50 = kernel_img_mul_50[0] + kernel_img_mul_50[1] + kernel_img_mul_50[2] + 
                kernel_img_mul_50[3] + kernel_img_mul_50[4] + kernel_img_mul_50[5] + 
                kernel_img_mul_50[6] + kernel_img_mul_50[7] + kernel_img_mul_50[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[407:400] <= 'd0;
  else if (current_state==ST_START)
    blur_din[407:400] <= kernel_img_sum_50[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[407:400] <= 'd0;
end

wire  [25:0]  kernel_img_mul_51[0:8];
assign kernel_img_mul_51[0] = buffer_data_2[407:400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_51[1] = buffer_data_2[415:408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_51[2] = buffer_data_2[423:416] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_51[3] = buffer_data_1[407:400] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_51[4] = buffer_data_1[415:408] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_51[5] = buffer_data_1[423:416] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_51[6] = buffer_data_0[407:400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_51[7] = buffer_data_0[415:408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_51[8] = buffer_data_0[423:416] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_51 = kernel_img_mul_51[0] + kernel_img_mul_51[1] + kernel_img_mul_51[2] + 
                kernel_img_mul_51[3] + kernel_img_mul_51[4] + kernel_img_mul_51[5] + 
                kernel_img_mul_51[6] + kernel_img_mul_51[7] + kernel_img_mul_51[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[415:408] <= 'd0;
  else if (current_state==ST_START)
    blur_din[415:408] <= kernel_img_sum_51[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[415:408] <= 'd0;
end

wire  [25:0]  kernel_img_mul_52[0:8];
assign kernel_img_mul_52[0] = buffer_data_2[415:408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_52[1] = buffer_data_2[423:416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_52[2] = buffer_data_2[431:424] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_52[3] = buffer_data_1[415:408] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_52[4] = buffer_data_1[423:416] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_52[5] = buffer_data_1[431:424] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_52[6] = buffer_data_0[415:408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_52[7] = buffer_data_0[423:416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_52[8] = buffer_data_0[431:424] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_52 = kernel_img_mul_52[0] + kernel_img_mul_52[1] + kernel_img_mul_52[2] + 
                kernel_img_mul_52[3] + kernel_img_mul_52[4] + kernel_img_mul_52[5] + 
                kernel_img_mul_52[6] + kernel_img_mul_52[7] + kernel_img_mul_52[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[423:416] <= 'd0;
  else if (current_state==ST_START)
    blur_din[423:416] <= kernel_img_sum_52[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[423:416] <= 'd0;
end

wire  [25:0]  kernel_img_mul_53[0:8];
assign kernel_img_mul_53[0] = buffer_data_2[423:416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_53[1] = buffer_data_2[431:424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_53[2] = buffer_data_2[439:432] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_53[3] = buffer_data_1[423:416] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_53[4] = buffer_data_1[431:424] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_53[5] = buffer_data_1[439:432] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_53[6] = buffer_data_0[423:416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_53[7] = buffer_data_0[431:424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_53[8] = buffer_data_0[439:432] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_53 = kernel_img_mul_53[0] + kernel_img_mul_53[1] + kernel_img_mul_53[2] + 
                kernel_img_mul_53[3] + kernel_img_mul_53[4] + kernel_img_mul_53[5] + 
                kernel_img_mul_53[6] + kernel_img_mul_53[7] + kernel_img_mul_53[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[431:424] <= 'd0;
  else if (current_state==ST_START)
    blur_din[431:424] <= kernel_img_sum_53[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[431:424] <= 'd0;
end

wire  [25:0]  kernel_img_mul_54[0:8];
assign kernel_img_mul_54[0] = buffer_data_2[431:424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_54[1] = buffer_data_2[439:432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_54[2] = buffer_data_2[447:440] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_54[3] = buffer_data_1[431:424] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_54[4] = buffer_data_1[439:432] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_54[5] = buffer_data_1[447:440] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_54[6] = buffer_data_0[431:424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_54[7] = buffer_data_0[439:432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_54[8] = buffer_data_0[447:440] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_54 = kernel_img_mul_54[0] + kernel_img_mul_54[1] + kernel_img_mul_54[2] + 
                kernel_img_mul_54[3] + kernel_img_mul_54[4] + kernel_img_mul_54[5] + 
                kernel_img_mul_54[6] + kernel_img_mul_54[7] + kernel_img_mul_54[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[439:432] <= 'd0;
  else if (current_state==ST_START)
    blur_din[439:432] <= kernel_img_sum_54[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[439:432] <= 'd0;
end

wire  [25:0]  kernel_img_mul_55[0:8];
assign kernel_img_mul_55[0] = buffer_data_2[439:432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_55[1] = buffer_data_2[447:440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_55[2] = buffer_data_2[455:448] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_55[3] = buffer_data_1[439:432] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_55[4] = buffer_data_1[447:440] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_55[5] = buffer_data_1[455:448] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_55[6] = buffer_data_0[439:432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_55[7] = buffer_data_0[447:440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_55[8] = buffer_data_0[455:448] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_55 = kernel_img_mul_55[0] + kernel_img_mul_55[1] + kernel_img_mul_55[2] + 
                kernel_img_mul_55[3] + kernel_img_mul_55[4] + kernel_img_mul_55[5] + 
                kernel_img_mul_55[6] + kernel_img_mul_55[7] + kernel_img_mul_55[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[447:440] <= 'd0;
  else if (current_state==ST_START)
    blur_din[447:440] <= kernel_img_sum_55[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[447:440] <= 'd0;
end

wire  [25:0]  kernel_img_mul_56[0:8];
assign kernel_img_mul_56[0] = buffer_data_2[447:440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_56[1] = buffer_data_2[455:448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_56[2] = buffer_data_2[463:456] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_56[3] = buffer_data_1[447:440] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_56[4] = buffer_data_1[455:448] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_56[5] = buffer_data_1[463:456] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_56[6] = buffer_data_0[447:440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_56[7] = buffer_data_0[455:448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_56[8] = buffer_data_0[463:456] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_56 = kernel_img_mul_56[0] + kernel_img_mul_56[1] + kernel_img_mul_56[2] + 
                kernel_img_mul_56[3] + kernel_img_mul_56[4] + kernel_img_mul_56[5] + 
                kernel_img_mul_56[6] + kernel_img_mul_56[7] + kernel_img_mul_56[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[455:448] <= 'd0;
  else if (current_state==ST_START)
    blur_din[455:448] <= kernel_img_sum_56[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[455:448] <= 'd0;
end

wire  [25:0]  kernel_img_mul_57[0:8];
assign kernel_img_mul_57[0] = buffer_data_2[455:448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_57[1] = buffer_data_2[463:456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_57[2] = buffer_data_2[471:464] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_57[3] = buffer_data_1[455:448] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_57[4] = buffer_data_1[463:456] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_57[5] = buffer_data_1[471:464] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_57[6] = buffer_data_0[455:448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_57[7] = buffer_data_0[463:456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_57[8] = buffer_data_0[471:464] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_57 = kernel_img_mul_57[0] + kernel_img_mul_57[1] + kernel_img_mul_57[2] + 
                kernel_img_mul_57[3] + kernel_img_mul_57[4] + kernel_img_mul_57[5] + 
                kernel_img_mul_57[6] + kernel_img_mul_57[7] + kernel_img_mul_57[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[463:456] <= 'd0;
  else if (current_state==ST_START)
    blur_din[463:456] <= kernel_img_sum_57[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[463:456] <= 'd0;
end

wire  [25:0]  kernel_img_mul_58[0:8];
assign kernel_img_mul_58[0] = buffer_data_2[463:456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_58[1] = buffer_data_2[471:464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_58[2] = buffer_data_2[479:472] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_58[3] = buffer_data_1[463:456] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_58[4] = buffer_data_1[471:464] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_58[5] = buffer_data_1[479:472] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_58[6] = buffer_data_0[463:456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_58[7] = buffer_data_0[471:464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_58[8] = buffer_data_0[479:472] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_58 = kernel_img_mul_58[0] + kernel_img_mul_58[1] + kernel_img_mul_58[2] + 
                kernel_img_mul_58[3] + kernel_img_mul_58[4] + kernel_img_mul_58[5] + 
                kernel_img_mul_58[6] + kernel_img_mul_58[7] + kernel_img_mul_58[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[471:464] <= 'd0;
  else if (current_state==ST_START)
    blur_din[471:464] <= kernel_img_sum_58[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[471:464] <= 'd0;
end

wire  [25:0]  kernel_img_mul_59[0:8];
assign kernel_img_mul_59[0] = buffer_data_2[471:464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_59[1] = buffer_data_2[479:472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_59[2] = buffer_data_2[487:480] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_59[3] = buffer_data_1[471:464] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_59[4] = buffer_data_1[479:472] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_59[5] = buffer_data_1[487:480] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_59[6] = buffer_data_0[471:464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_59[7] = buffer_data_0[479:472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_59[8] = buffer_data_0[487:480] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_59 = kernel_img_mul_59[0] + kernel_img_mul_59[1] + kernel_img_mul_59[2] + 
                kernel_img_mul_59[3] + kernel_img_mul_59[4] + kernel_img_mul_59[5] + 
                kernel_img_mul_59[6] + kernel_img_mul_59[7] + kernel_img_mul_59[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[479:472] <= 'd0;
  else if (current_state==ST_START)
    blur_din[479:472] <= kernel_img_sum_59[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[479:472] <= 'd0;
end

wire  [25:0]  kernel_img_mul_60[0:8];
assign kernel_img_mul_60[0] = buffer_data_2[479:472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_60[1] = buffer_data_2[487:480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_60[2] = buffer_data_2[495:488] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_60[3] = buffer_data_1[479:472] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_60[4] = buffer_data_1[487:480] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_60[5] = buffer_data_1[495:488] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_60[6] = buffer_data_0[479:472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_60[7] = buffer_data_0[487:480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_60[8] = buffer_data_0[495:488] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_60 = kernel_img_mul_60[0] + kernel_img_mul_60[1] + kernel_img_mul_60[2] + 
                kernel_img_mul_60[3] + kernel_img_mul_60[4] + kernel_img_mul_60[5] + 
                kernel_img_mul_60[6] + kernel_img_mul_60[7] + kernel_img_mul_60[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[487:480] <= 'd0;
  else if (current_state==ST_START)
    blur_din[487:480] <= kernel_img_sum_60[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[487:480] <= 'd0;
end

wire  [25:0]  kernel_img_mul_61[0:8];
assign kernel_img_mul_61[0] = buffer_data_2[487:480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_61[1] = buffer_data_2[495:488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_61[2] = buffer_data_2[503:496] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_61[3] = buffer_data_1[487:480] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_61[4] = buffer_data_1[495:488] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_61[5] = buffer_data_1[503:496] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_61[6] = buffer_data_0[487:480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_61[7] = buffer_data_0[495:488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_61[8] = buffer_data_0[503:496] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_61 = kernel_img_mul_61[0] + kernel_img_mul_61[1] + kernel_img_mul_61[2] + 
                kernel_img_mul_61[3] + kernel_img_mul_61[4] + kernel_img_mul_61[5] + 
                kernel_img_mul_61[6] + kernel_img_mul_61[7] + kernel_img_mul_61[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[495:488] <= 'd0;
  else if (current_state==ST_START)
    blur_din[495:488] <= kernel_img_sum_61[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[495:488] <= 'd0;
end

wire  [25:0]  kernel_img_mul_62[0:8];
assign kernel_img_mul_62[0] = buffer_data_2[495:488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_62[1] = buffer_data_2[503:496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_62[2] = buffer_data_2[511:504] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_62[3] = buffer_data_1[495:488] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_62[4] = buffer_data_1[503:496] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_62[5] = buffer_data_1[511:504] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_62[6] = buffer_data_0[495:488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_62[7] = buffer_data_0[503:496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_62[8] = buffer_data_0[511:504] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_62 = kernel_img_mul_62[0] + kernel_img_mul_62[1] + kernel_img_mul_62[2] + 
                kernel_img_mul_62[3] + kernel_img_mul_62[4] + kernel_img_mul_62[5] + 
                kernel_img_mul_62[6] + kernel_img_mul_62[7] + kernel_img_mul_62[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[503:496] <= 'd0;
  else if (current_state==ST_START)
    blur_din[503:496] <= kernel_img_sum_62[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[503:496] <= 'd0;
end

wire  [25:0]  kernel_img_mul_63[0:8];
assign kernel_img_mul_63[0] = buffer_data_2[503:496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_63[1] = buffer_data_2[511:504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_63[2] = buffer_data_2[519:512] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_63[3] = buffer_data_1[503:496] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_63[4] = buffer_data_1[511:504] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_63[5] = buffer_data_1[519:512] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_63[6] = buffer_data_0[503:496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_63[7] = buffer_data_0[511:504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_63[8] = buffer_data_0[519:512] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_63 = kernel_img_mul_63[0] + kernel_img_mul_63[1] + kernel_img_mul_63[2] + 
                kernel_img_mul_63[3] + kernel_img_mul_63[4] + kernel_img_mul_63[5] + 
                kernel_img_mul_63[6] + kernel_img_mul_63[7] + kernel_img_mul_63[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[511:504] <= 'd0;
  else if (current_state==ST_START)
    blur_din[511:504] <= kernel_img_sum_63[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[511:504] <= 'd0;
end

wire  [25:0]  kernel_img_mul_64[0:8];
assign kernel_img_mul_64[0] = buffer_data_2[511:504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_64[1] = buffer_data_2[519:512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_64[2] = buffer_data_2[527:520] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_64[3] = buffer_data_1[511:504] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_64[4] = buffer_data_1[519:512] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_64[5] = buffer_data_1[527:520] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_64[6] = buffer_data_0[511:504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_64[7] = buffer_data_0[519:512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_64[8] = buffer_data_0[527:520] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_64 = kernel_img_mul_64[0] + kernel_img_mul_64[1] + kernel_img_mul_64[2] + 
                kernel_img_mul_64[3] + kernel_img_mul_64[4] + kernel_img_mul_64[5] + 
                kernel_img_mul_64[6] + kernel_img_mul_64[7] + kernel_img_mul_64[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[519:512] <= 'd0;
  else if (current_state==ST_START)
    blur_din[519:512] <= kernel_img_sum_64[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[519:512] <= 'd0;
end

wire  [25:0]  kernel_img_mul_65[0:8];
assign kernel_img_mul_65[0] = buffer_data_2[519:512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_65[1] = buffer_data_2[527:520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_65[2] = buffer_data_2[535:528] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_65[3] = buffer_data_1[519:512] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_65[4] = buffer_data_1[527:520] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_65[5] = buffer_data_1[535:528] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_65[6] = buffer_data_0[519:512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_65[7] = buffer_data_0[527:520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_65[8] = buffer_data_0[535:528] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_65 = kernel_img_mul_65[0] + kernel_img_mul_65[1] + kernel_img_mul_65[2] + 
                kernel_img_mul_65[3] + kernel_img_mul_65[4] + kernel_img_mul_65[5] + 
                kernel_img_mul_65[6] + kernel_img_mul_65[7] + kernel_img_mul_65[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[527:520] <= 'd0;
  else if (current_state==ST_START)
    blur_din[527:520] <= kernel_img_sum_65[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[527:520] <= 'd0;
end

wire  [25:0]  kernel_img_mul_66[0:8];
assign kernel_img_mul_66[0] = buffer_data_2[527:520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_66[1] = buffer_data_2[535:528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_66[2] = buffer_data_2[543:536] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_66[3] = buffer_data_1[527:520] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_66[4] = buffer_data_1[535:528] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_66[5] = buffer_data_1[543:536] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_66[6] = buffer_data_0[527:520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_66[7] = buffer_data_0[535:528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_66[8] = buffer_data_0[543:536] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_66 = kernel_img_mul_66[0] + kernel_img_mul_66[1] + kernel_img_mul_66[2] + 
                kernel_img_mul_66[3] + kernel_img_mul_66[4] + kernel_img_mul_66[5] + 
                kernel_img_mul_66[6] + kernel_img_mul_66[7] + kernel_img_mul_66[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[535:528] <= 'd0;
  else if (current_state==ST_START)
    blur_din[535:528] <= kernel_img_sum_66[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[535:528] <= 'd0;
end

wire  [25:0]  kernel_img_mul_67[0:8];
assign kernel_img_mul_67[0] = buffer_data_2[535:528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_67[1] = buffer_data_2[543:536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_67[2] = buffer_data_2[551:544] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_67[3] = buffer_data_1[535:528] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_67[4] = buffer_data_1[543:536] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_67[5] = buffer_data_1[551:544] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_67[6] = buffer_data_0[535:528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_67[7] = buffer_data_0[543:536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_67[8] = buffer_data_0[551:544] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_67 = kernel_img_mul_67[0] + kernel_img_mul_67[1] + kernel_img_mul_67[2] + 
                kernel_img_mul_67[3] + kernel_img_mul_67[4] + kernel_img_mul_67[5] + 
                kernel_img_mul_67[6] + kernel_img_mul_67[7] + kernel_img_mul_67[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[543:536] <= 'd0;
  else if (current_state==ST_START)
    blur_din[543:536] <= kernel_img_sum_67[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[543:536] <= 'd0;
end

wire  [25:0]  kernel_img_mul_68[0:8];
assign kernel_img_mul_68[0] = buffer_data_2[543:536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_68[1] = buffer_data_2[551:544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_68[2] = buffer_data_2[559:552] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_68[3] = buffer_data_1[543:536] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_68[4] = buffer_data_1[551:544] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_68[5] = buffer_data_1[559:552] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_68[6] = buffer_data_0[543:536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_68[7] = buffer_data_0[551:544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_68[8] = buffer_data_0[559:552] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_68 = kernel_img_mul_68[0] + kernel_img_mul_68[1] + kernel_img_mul_68[2] + 
                kernel_img_mul_68[3] + kernel_img_mul_68[4] + kernel_img_mul_68[5] + 
                kernel_img_mul_68[6] + kernel_img_mul_68[7] + kernel_img_mul_68[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[551:544] <= 'd0;
  else if (current_state==ST_START)
    blur_din[551:544] <= kernel_img_sum_68[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[551:544] <= 'd0;
end

wire  [25:0]  kernel_img_mul_69[0:8];
assign kernel_img_mul_69[0] = buffer_data_2[551:544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_69[1] = buffer_data_2[559:552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_69[2] = buffer_data_2[567:560] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_69[3] = buffer_data_1[551:544] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_69[4] = buffer_data_1[559:552] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_69[5] = buffer_data_1[567:560] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_69[6] = buffer_data_0[551:544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_69[7] = buffer_data_0[559:552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_69[8] = buffer_data_0[567:560] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_69 = kernel_img_mul_69[0] + kernel_img_mul_69[1] + kernel_img_mul_69[2] + 
                kernel_img_mul_69[3] + kernel_img_mul_69[4] + kernel_img_mul_69[5] + 
                kernel_img_mul_69[6] + kernel_img_mul_69[7] + kernel_img_mul_69[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[559:552] <= 'd0;
  else if (current_state==ST_START)
    blur_din[559:552] <= kernel_img_sum_69[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[559:552] <= 'd0;
end

wire  [25:0]  kernel_img_mul_70[0:8];
assign kernel_img_mul_70[0] = buffer_data_2[559:552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_70[1] = buffer_data_2[567:560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_70[2] = buffer_data_2[575:568] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_70[3] = buffer_data_1[559:552] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_70[4] = buffer_data_1[567:560] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_70[5] = buffer_data_1[575:568] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_70[6] = buffer_data_0[559:552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_70[7] = buffer_data_0[567:560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_70[8] = buffer_data_0[575:568] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_70 = kernel_img_mul_70[0] + kernel_img_mul_70[1] + kernel_img_mul_70[2] + 
                kernel_img_mul_70[3] + kernel_img_mul_70[4] + kernel_img_mul_70[5] + 
                kernel_img_mul_70[6] + kernel_img_mul_70[7] + kernel_img_mul_70[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[567:560] <= 'd0;
  else if (current_state==ST_START)
    blur_din[567:560] <= kernel_img_sum_70[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[567:560] <= 'd0;
end

wire  [25:0]  kernel_img_mul_71[0:8];
assign kernel_img_mul_71[0] = buffer_data_2[567:560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_71[1] = buffer_data_2[575:568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_71[2] = buffer_data_2[583:576] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_71[3] = buffer_data_1[567:560] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_71[4] = buffer_data_1[575:568] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_71[5] = buffer_data_1[583:576] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_71[6] = buffer_data_0[567:560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_71[7] = buffer_data_0[575:568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_71[8] = buffer_data_0[583:576] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_71 = kernel_img_mul_71[0] + kernel_img_mul_71[1] + kernel_img_mul_71[2] + 
                kernel_img_mul_71[3] + kernel_img_mul_71[4] + kernel_img_mul_71[5] + 
                kernel_img_mul_71[6] + kernel_img_mul_71[7] + kernel_img_mul_71[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[575:568] <= 'd0;
  else if (current_state==ST_START)
    blur_din[575:568] <= kernel_img_sum_71[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[575:568] <= 'd0;
end

wire  [25:0]  kernel_img_mul_72[0:8];
assign kernel_img_mul_72[0] = buffer_data_2[575:568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_72[1] = buffer_data_2[583:576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_72[2] = buffer_data_2[591:584] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_72[3] = buffer_data_1[575:568] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_72[4] = buffer_data_1[583:576] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_72[5] = buffer_data_1[591:584] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_72[6] = buffer_data_0[575:568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_72[7] = buffer_data_0[583:576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_72[8] = buffer_data_0[591:584] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_72 = kernel_img_mul_72[0] + kernel_img_mul_72[1] + kernel_img_mul_72[2] + 
                kernel_img_mul_72[3] + kernel_img_mul_72[4] + kernel_img_mul_72[5] + 
                kernel_img_mul_72[6] + kernel_img_mul_72[7] + kernel_img_mul_72[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[583:576] <= 'd0;
  else if (current_state==ST_START)
    blur_din[583:576] <= kernel_img_sum_72[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[583:576] <= 'd0;
end

wire  [25:0]  kernel_img_mul_73[0:8];
assign kernel_img_mul_73[0] = buffer_data_2[583:576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_73[1] = buffer_data_2[591:584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_73[2] = buffer_data_2[599:592] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_73[3] = buffer_data_1[583:576] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_73[4] = buffer_data_1[591:584] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_73[5] = buffer_data_1[599:592] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_73[6] = buffer_data_0[583:576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_73[7] = buffer_data_0[591:584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_73[8] = buffer_data_0[599:592] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_73 = kernel_img_mul_73[0] + kernel_img_mul_73[1] + kernel_img_mul_73[2] + 
                kernel_img_mul_73[3] + kernel_img_mul_73[4] + kernel_img_mul_73[5] + 
                kernel_img_mul_73[6] + kernel_img_mul_73[7] + kernel_img_mul_73[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[591:584] <= 'd0;
  else if (current_state==ST_START)
    blur_din[591:584] <= kernel_img_sum_73[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[591:584] <= 'd0;
end

wire  [25:0]  kernel_img_mul_74[0:8];
assign kernel_img_mul_74[0] = buffer_data_2[591:584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_74[1] = buffer_data_2[599:592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_74[2] = buffer_data_2[607:600] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_74[3] = buffer_data_1[591:584] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_74[4] = buffer_data_1[599:592] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_74[5] = buffer_data_1[607:600] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_74[6] = buffer_data_0[591:584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_74[7] = buffer_data_0[599:592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_74[8] = buffer_data_0[607:600] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_74 = kernel_img_mul_74[0] + kernel_img_mul_74[1] + kernel_img_mul_74[2] + 
                kernel_img_mul_74[3] + kernel_img_mul_74[4] + kernel_img_mul_74[5] + 
                kernel_img_mul_74[6] + kernel_img_mul_74[7] + kernel_img_mul_74[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[599:592] <= 'd0;
  else if (current_state==ST_START)
    blur_din[599:592] <= kernel_img_sum_74[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[599:592] <= 'd0;
end

wire  [25:0]  kernel_img_mul_75[0:8];
assign kernel_img_mul_75[0] = buffer_data_2[599:592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_75[1] = buffer_data_2[607:600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_75[2] = buffer_data_2[615:608] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_75[3] = buffer_data_1[599:592] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_75[4] = buffer_data_1[607:600] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_75[5] = buffer_data_1[615:608] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_75[6] = buffer_data_0[599:592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_75[7] = buffer_data_0[607:600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_75[8] = buffer_data_0[615:608] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_75 = kernel_img_mul_75[0] + kernel_img_mul_75[1] + kernel_img_mul_75[2] + 
                kernel_img_mul_75[3] + kernel_img_mul_75[4] + kernel_img_mul_75[5] + 
                kernel_img_mul_75[6] + kernel_img_mul_75[7] + kernel_img_mul_75[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[607:600] <= 'd0;
  else if (current_state==ST_START)
    blur_din[607:600] <= kernel_img_sum_75[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[607:600] <= 'd0;
end

wire  [25:0]  kernel_img_mul_76[0:8];
assign kernel_img_mul_76[0] = buffer_data_2[607:600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_76[1] = buffer_data_2[615:608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_76[2] = buffer_data_2[623:616] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_76[3] = buffer_data_1[607:600] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_76[4] = buffer_data_1[615:608] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_76[5] = buffer_data_1[623:616] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_76[6] = buffer_data_0[607:600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_76[7] = buffer_data_0[615:608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_76[8] = buffer_data_0[623:616] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_76 = kernel_img_mul_76[0] + kernel_img_mul_76[1] + kernel_img_mul_76[2] + 
                kernel_img_mul_76[3] + kernel_img_mul_76[4] + kernel_img_mul_76[5] + 
                kernel_img_mul_76[6] + kernel_img_mul_76[7] + kernel_img_mul_76[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[615:608] <= 'd0;
  else if (current_state==ST_START)
    blur_din[615:608] <= kernel_img_sum_76[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[615:608] <= 'd0;
end

wire  [25:0]  kernel_img_mul_77[0:8];
assign kernel_img_mul_77[0] = buffer_data_2[615:608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_77[1] = buffer_data_2[623:616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_77[2] = buffer_data_2[631:624] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_77[3] = buffer_data_1[615:608] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_77[4] = buffer_data_1[623:616] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_77[5] = buffer_data_1[631:624] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_77[6] = buffer_data_0[615:608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_77[7] = buffer_data_0[623:616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_77[8] = buffer_data_0[631:624] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_77 = kernel_img_mul_77[0] + kernel_img_mul_77[1] + kernel_img_mul_77[2] + 
                kernel_img_mul_77[3] + kernel_img_mul_77[4] + kernel_img_mul_77[5] + 
                kernel_img_mul_77[6] + kernel_img_mul_77[7] + kernel_img_mul_77[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[623:616] <= 'd0;
  else if (current_state==ST_START)
    blur_din[623:616] <= kernel_img_sum_77[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[623:616] <= 'd0;
end

wire  [25:0]  kernel_img_mul_78[0:8];
assign kernel_img_mul_78[0] = buffer_data_2[623:616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_78[1] = buffer_data_2[631:624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_78[2] = buffer_data_2[639:632] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_78[3] = buffer_data_1[623:616] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_78[4] = buffer_data_1[631:624] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_78[5] = buffer_data_1[639:632] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_78[6] = buffer_data_0[623:616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_78[7] = buffer_data_0[631:624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_78[8] = buffer_data_0[639:632] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_78 = kernel_img_mul_78[0] + kernel_img_mul_78[1] + kernel_img_mul_78[2] + 
                kernel_img_mul_78[3] + kernel_img_mul_78[4] + kernel_img_mul_78[5] + 
                kernel_img_mul_78[6] + kernel_img_mul_78[7] + kernel_img_mul_78[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[631:624] <= 'd0;
  else if (current_state==ST_START)
    blur_din[631:624] <= kernel_img_sum_78[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[631:624] <= 'd0;
end

wire  [25:0]  kernel_img_mul_79[0:8];
assign kernel_img_mul_79[0] = buffer_data_2[631:624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_79[1] = buffer_data_2[639:632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_79[2] = buffer_data_2[647:640] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_79[3] = buffer_data_1[631:624] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_79[4] = buffer_data_1[639:632] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_79[5] = buffer_data_1[647:640] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_79[6] = buffer_data_0[631:624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_79[7] = buffer_data_0[639:632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_79[8] = buffer_data_0[647:640] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_79 = kernel_img_mul_79[0] + kernel_img_mul_79[1] + kernel_img_mul_79[2] + 
                kernel_img_mul_79[3] + kernel_img_mul_79[4] + kernel_img_mul_79[5] + 
                kernel_img_mul_79[6] + kernel_img_mul_79[7] + kernel_img_mul_79[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[639:632] <= 'd0;
  else if (current_state==ST_START)
    blur_din[639:632] <= kernel_img_sum_79[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[639:632] <= 'd0;
end

wire  [25:0]  kernel_img_mul_80[0:8];
assign kernel_img_mul_80[0] = buffer_data_2[639:632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_80[1] = buffer_data_2[647:640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_80[2] = buffer_data_2[655:648] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_80[3] = buffer_data_1[639:632] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_80[4] = buffer_data_1[647:640] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_80[5] = buffer_data_1[655:648] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_80[6] = buffer_data_0[639:632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_80[7] = buffer_data_0[647:640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_80[8] = buffer_data_0[655:648] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_80 = kernel_img_mul_80[0] + kernel_img_mul_80[1] + kernel_img_mul_80[2] + 
                kernel_img_mul_80[3] + kernel_img_mul_80[4] + kernel_img_mul_80[5] + 
                kernel_img_mul_80[6] + kernel_img_mul_80[7] + kernel_img_mul_80[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[647:640] <= 'd0;
  else if (current_state==ST_START)
    blur_din[647:640] <= kernel_img_sum_80[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[647:640] <= 'd0;
end

wire  [25:0]  kernel_img_mul_81[0:8];
assign kernel_img_mul_81[0] = buffer_data_2[647:640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_81[1] = buffer_data_2[655:648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_81[2] = buffer_data_2[663:656] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_81[3] = buffer_data_1[647:640] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_81[4] = buffer_data_1[655:648] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_81[5] = buffer_data_1[663:656] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_81[6] = buffer_data_0[647:640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_81[7] = buffer_data_0[655:648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_81[8] = buffer_data_0[663:656] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_81 = kernel_img_mul_81[0] + kernel_img_mul_81[1] + kernel_img_mul_81[2] + 
                kernel_img_mul_81[3] + kernel_img_mul_81[4] + kernel_img_mul_81[5] + 
                kernel_img_mul_81[6] + kernel_img_mul_81[7] + kernel_img_mul_81[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[655:648] <= 'd0;
  else if (current_state==ST_START)
    blur_din[655:648] <= kernel_img_sum_81[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[655:648] <= 'd0;
end

wire  [25:0]  kernel_img_mul_82[0:8];
assign kernel_img_mul_82[0] = buffer_data_2[655:648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_82[1] = buffer_data_2[663:656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_82[2] = buffer_data_2[671:664] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_82[3] = buffer_data_1[655:648] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_82[4] = buffer_data_1[663:656] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_82[5] = buffer_data_1[671:664] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_82[6] = buffer_data_0[655:648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_82[7] = buffer_data_0[663:656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_82[8] = buffer_data_0[671:664] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_82 = kernel_img_mul_82[0] + kernel_img_mul_82[1] + kernel_img_mul_82[2] + 
                kernel_img_mul_82[3] + kernel_img_mul_82[4] + kernel_img_mul_82[5] + 
                kernel_img_mul_82[6] + kernel_img_mul_82[7] + kernel_img_mul_82[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[663:656] <= 'd0;
  else if (current_state==ST_START)
    blur_din[663:656] <= kernel_img_sum_82[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[663:656] <= 'd0;
end

wire  [25:0]  kernel_img_mul_83[0:8];
assign kernel_img_mul_83[0] = buffer_data_2[663:656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_83[1] = buffer_data_2[671:664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_83[2] = buffer_data_2[679:672] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_83[3] = buffer_data_1[663:656] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_83[4] = buffer_data_1[671:664] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_83[5] = buffer_data_1[679:672] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_83[6] = buffer_data_0[663:656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_83[7] = buffer_data_0[671:664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_83[8] = buffer_data_0[679:672] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_83 = kernel_img_mul_83[0] + kernel_img_mul_83[1] + kernel_img_mul_83[2] + 
                kernel_img_mul_83[3] + kernel_img_mul_83[4] + kernel_img_mul_83[5] + 
                kernel_img_mul_83[6] + kernel_img_mul_83[7] + kernel_img_mul_83[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[671:664] <= 'd0;
  else if (current_state==ST_START)
    blur_din[671:664] <= kernel_img_sum_83[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[671:664] <= 'd0;
end

wire  [25:0]  kernel_img_mul_84[0:8];
assign kernel_img_mul_84[0] = buffer_data_2[671:664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_84[1] = buffer_data_2[679:672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_84[2] = buffer_data_2[687:680] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_84[3] = buffer_data_1[671:664] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_84[4] = buffer_data_1[679:672] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_84[5] = buffer_data_1[687:680] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_84[6] = buffer_data_0[671:664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_84[7] = buffer_data_0[679:672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_84[8] = buffer_data_0[687:680] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_84 = kernel_img_mul_84[0] + kernel_img_mul_84[1] + kernel_img_mul_84[2] + 
                kernel_img_mul_84[3] + kernel_img_mul_84[4] + kernel_img_mul_84[5] + 
                kernel_img_mul_84[6] + kernel_img_mul_84[7] + kernel_img_mul_84[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[679:672] <= 'd0;
  else if (current_state==ST_START)
    blur_din[679:672] <= kernel_img_sum_84[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[679:672] <= 'd0;
end

wire  [25:0]  kernel_img_mul_85[0:8];
assign kernel_img_mul_85[0] = buffer_data_2[679:672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_85[1] = buffer_data_2[687:680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_85[2] = buffer_data_2[695:688] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_85[3] = buffer_data_1[679:672] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_85[4] = buffer_data_1[687:680] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_85[5] = buffer_data_1[695:688] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_85[6] = buffer_data_0[679:672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_85[7] = buffer_data_0[687:680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_85[8] = buffer_data_0[695:688] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_85 = kernel_img_mul_85[0] + kernel_img_mul_85[1] + kernel_img_mul_85[2] + 
                kernel_img_mul_85[3] + kernel_img_mul_85[4] + kernel_img_mul_85[5] + 
                kernel_img_mul_85[6] + kernel_img_mul_85[7] + kernel_img_mul_85[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[687:680] <= 'd0;
  else if (current_state==ST_START)
    blur_din[687:680] <= kernel_img_sum_85[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[687:680] <= 'd0;
end

wire  [25:0]  kernel_img_mul_86[0:8];
assign kernel_img_mul_86[0] = buffer_data_2[687:680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_86[1] = buffer_data_2[695:688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_86[2] = buffer_data_2[703:696] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_86[3] = buffer_data_1[687:680] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_86[4] = buffer_data_1[695:688] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_86[5] = buffer_data_1[703:696] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_86[6] = buffer_data_0[687:680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_86[7] = buffer_data_0[695:688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_86[8] = buffer_data_0[703:696] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_86 = kernel_img_mul_86[0] + kernel_img_mul_86[1] + kernel_img_mul_86[2] + 
                kernel_img_mul_86[3] + kernel_img_mul_86[4] + kernel_img_mul_86[5] + 
                kernel_img_mul_86[6] + kernel_img_mul_86[7] + kernel_img_mul_86[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[695:688] <= 'd0;
  else if (current_state==ST_START)
    blur_din[695:688] <= kernel_img_sum_86[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[695:688] <= 'd0;
end

wire  [25:0]  kernel_img_mul_87[0:8];
assign kernel_img_mul_87[0] = buffer_data_2[695:688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_87[1] = buffer_data_2[703:696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_87[2] = buffer_data_2[711:704] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_87[3] = buffer_data_1[695:688] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_87[4] = buffer_data_1[703:696] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_87[5] = buffer_data_1[711:704] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_87[6] = buffer_data_0[695:688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_87[7] = buffer_data_0[703:696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_87[8] = buffer_data_0[711:704] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_87 = kernel_img_mul_87[0] + kernel_img_mul_87[1] + kernel_img_mul_87[2] + 
                kernel_img_mul_87[3] + kernel_img_mul_87[4] + kernel_img_mul_87[5] + 
                kernel_img_mul_87[6] + kernel_img_mul_87[7] + kernel_img_mul_87[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[703:696] <= 'd0;
  else if (current_state==ST_START)
    blur_din[703:696] <= kernel_img_sum_87[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[703:696] <= 'd0;
end

wire  [25:0]  kernel_img_mul_88[0:8];
assign kernel_img_mul_88[0] = buffer_data_2[703:696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_88[1] = buffer_data_2[711:704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_88[2] = buffer_data_2[719:712] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_88[3] = buffer_data_1[703:696] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_88[4] = buffer_data_1[711:704] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_88[5] = buffer_data_1[719:712] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_88[6] = buffer_data_0[703:696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_88[7] = buffer_data_0[711:704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_88[8] = buffer_data_0[719:712] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_88 = kernel_img_mul_88[0] + kernel_img_mul_88[1] + kernel_img_mul_88[2] + 
                kernel_img_mul_88[3] + kernel_img_mul_88[4] + kernel_img_mul_88[5] + 
                kernel_img_mul_88[6] + kernel_img_mul_88[7] + kernel_img_mul_88[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[711:704] <= 'd0;
  else if (current_state==ST_START)
    blur_din[711:704] <= kernel_img_sum_88[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[711:704] <= 'd0;
end

wire  [25:0]  kernel_img_mul_89[0:8];
assign kernel_img_mul_89[0] = buffer_data_2[711:704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_89[1] = buffer_data_2[719:712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_89[2] = buffer_data_2[727:720] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_89[3] = buffer_data_1[711:704] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_89[4] = buffer_data_1[719:712] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_89[5] = buffer_data_1[727:720] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_89[6] = buffer_data_0[711:704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_89[7] = buffer_data_0[719:712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_89[8] = buffer_data_0[727:720] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_89 = kernel_img_mul_89[0] + kernel_img_mul_89[1] + kernel_img_mul_89[2] + 
                kernel_img_mul_89[3] + kernel_img_mul_89[4] + kernel_img_mul_89[5] + 
                kernel_img_mul_89[6] + kernel_img_mul_89[7] + kernel_img_mul_89[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[719:712] <= 'd0;
  else if (current_state==ST_START)
    blur_din[719:712] <= kernel_img_sum_89[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[719:712] <= 'd0;
end

wire  [25:0]  kernel_img_mul_90[0:8];
assign kernel_img_mul_90[0] = buffer_data_2[719:712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_90[1] = buffer_data_2[727:720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_90[2] = buffer_data_2[735:728] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_90[3] = buffer_data_1[719:712] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_90[4] = buffer_data_1[727:720] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_90[5] = buffer_data_1[735:728] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_90[6] = buffer_data_0[719:712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_90[7] = buffer_data_0[727:720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_90[8] = buffer_data_0[735:728] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_90 = kernel_img_mul_90[0] + kernel_img_mul_90[1] + kernel_img_mul_90[2] + 
                kernel_img_mul_90[3] + kernel_img_mul_90[4] + kernel_img_mul_90[5] + 
                kernel_img_mul_90[6] + kernel_img_mul_90[7] + kernel_img_mul_90[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[727:720] <= 'd0;
  else if (current_state==ST_START)
    blur_din[727:720] <= kernel_img_sum_90[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[727:720] <= 'd0;
end

wire  [25:0]  kernel_img_mul_91[0:8];
assign kernel_img_mul_91[0] = buffer_data_2[727:720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_91[1] = buffer_data_2[735:728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_91[2] = buffer_data_2[743:736] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_91[3] = buffer_data_1[727:720] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_91[4] = buffer_data_1[735:728] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_91[5] = buffer_data_1[743:736] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_91[6] = buffer_data_0[727:720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_91[7] = buffer_data_0[735:728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_91[8] = buffer_data_0[743:736] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_91 = kernel_img_mul_91[0] + kernel_img_mul_91[1] + kernel_img_mul_91[2] + 
                kernel_img_mul_91[3] + kernel_img_mul_91[4] + kernel_img_mul_91[5] + 
                kernel_img_mul_91[6] + kernel_img_mul_91[7] + kernel_img_mul_91[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[735:728] <= 'd0;
  else if (current_state==ST_START)
    blur_din[735:728] <= kernel_img_sum_91[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[735:728] <= 'd0;
end

wire  [25:0]  kernel_img_mul_92[0:8];
assign kernel_img_mul_92[0] = buffer_data_2[735:728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_92[1] = buffer_data_2[743:736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_92[2] = buffer_data_2[751:744] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_92[3] = buffer_data_1[735:728] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_92[4] = buffer_data_1[743:736] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_92[5] = buffer_data_1[751:744] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_92[6] = buffer_data_0[735:728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_92[7] = buffer_data_0[743:736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_92[8] = buffer_data_0[751:744] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_92 = kernel_img_mul_92[0] + kernel_img_mul_92[1] + kernel_img_mul_92[2] + 
                kernel_img_mul_92[3] + kernel_img_mul_92[4] + kernel_img_mul_92[5] + 
                kernel_img_mul_92[6] + kernel_img_mul_92[7] + kernel_img_mul_92[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[743:736] <= 'd0;
  else if (current_state==ST_START)
    blur_din[743:736] <= kernel_img_sum_92[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[743:736] <= 'd0;
end

wire  [25:0]  kernel_img_mul_93[0:8];
assign kernel_img_mul_93[0] = buffer_data_2[743:736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_93[1] = buffer_data_2[751:744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_93[2] = buffer_data_2[759:752] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_93[3] = buffer_data_1[743:736] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_93[4] = buffer_data_1[751:744] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_93[5] = buffer_data_1[759:752] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_93[6] = buffer_data_0[743:736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_93[7] = buffer_data_0[751:744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_93[8] = buffer_data_0[759:752] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_93 = kernel_img_mul_93[0] + kernel_img_mul_93[1] + kernel_img_mul_93[2] + 
                kernel_img_mul_93[3] + kernel_img_mul_93[4] + kernel_img_mul_93[5] + 
                kernel_img_mul_93[6] + kernel_img_mul_93[7] + kernel_img_mul_93[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[751:744] <= 'd0;
  else if (current_state==ST_START)
    blur_din[751:744] <= kernel_img_sum_93[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[751:744] <= 'd0;
end

wire  [25:0]  kernel_img_mul_94[0:8];
assign kernel_img_mul_94[0] = buffer_data_2[751:744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_94[1] = buffer_data_2[759:752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_94[2] = buffer_data_2[767:760] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_94[3] = buffer_data_1[751:744] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_94[4] = buffer_data_1[759:752] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_94[5] = buffer_data_1[767:760] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_94[6] = buffer_data_0[751:744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_94[7] = buffer_data_0[759:752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_94[8] = buffer_data_0[767:760] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_94 = kernel_img_mul_94[0] + kernel_img_mul_94[1] + kernel_img_mul_94[2] + 
                kernel_img_mul_94[3] + kernel_img_mul_94[4] + kernel_img_mul_94[5] + 
                kernel_img_mul_94[6] + kernel_img_mul_94[7] + kernel_img_mul_94[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[759:752] <= 'd0;
  else if (current_state==ST_START)
    blur_din[759:752] <= kernel_img_sum_94[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[759:752] <= 'd0;
end

wire  [25:0]  kernel_img_mul_95[0:8];
assign kernel_img_mul_95[0] = buffer_data_2[759:752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_95[1] = buffer_data_2[767:760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_95[2] = buffer_data_2[775:768] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_95[3] = buffer_data_1[759:752] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_95[4] = buffer_data_1[767:760] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_95[5] = buffer_data_1[775:768] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_95[6] = buffer_data_0[759:752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_95[7] = buffer_data_0[767:760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_95[8] = buffer_data_0[775:768] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_95 = kernel_img_mul_95[0] + kernel_img_mul_95[1] + kernel_img_mul_95[2] + 
                kernel_img_mul_95[3] + kernel_img_mul_95[4] + kernel_img_mul_95[5] + 
                kernel_img_mul_95[6] + kernel_img_mul_95[7] + kernel_img_mul_95[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[767:760] <= 'd0;
  else if (current_state==ST_START)
    blur_din[767:760] <= kernel_img_sum_95[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[767:760] <= 'd0;
end

wire  [25:0]  kernel_img_mul_96[0:8];
assign kernel_img_mul_96[0] = buffer_data_2[767:760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_96[1] = buffer_data_2[775:768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_96[2] = buffer_data_2[783:776] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_96[3] = buffer_data_1[767:760] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_96[4] = buffer_data_1[775:768] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_96[5] = buffer_data_1[783:776] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_96[6] = buffer_data_0[767:760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_96[7] = buffer_data_0[775:768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_96[8] = buffer_data_0[783:776] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_96 = kernel_img_mul_96[0] + kernel_img_mul_96[1] + kernel_img_mul_96[2] + 
                kernel_img_mul_96[3] + kernel_img_mul_96[4] + kernel_img_mul_96[5] + 
                kernel_img_mul_96[6] + kernel_img_mul_96[7] + kernel_img_mul_96[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[775:768] <= 'd0;
  else if (current_state==ST_START)
    blur_din[775:768] <= kernel_img_sum_96[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[775:768] <= 'd0;
end

wire  [25:0]  kernel_img_mul_97[0:8];
assign kernel_img_mul_97[0] = buffer_data_2[775:768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_97[1] = buffer_data_2[783:776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_97[2] = buffer_data_2[791:784] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_97[3] = buffer_data_1[775:768] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_97[4] = buffer_data_1[783:776] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_97[5] = buffer_data_1[791:784] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_97[6] = buffer_data_0[775:768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_97[7] = buffer_data_0[783:776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_97[8] = buffer_data_0[791:784] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_97 = kernel_img_mul_97[0] + kernel_img_mul_97[1] + kernel_img_mul_97[2] + 
                kernel_img_mul_97[3] + kernel_img_mul_97[4] + kernel_img_mul_97[5] + 
                kernel_img_mul_97[6] + kernel_img_mul_97[7] + kernel_img_mul_97[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[783:776] <= 'd0;
  else if (current_state==ST_START)
    blur_din[783:776] <= kernel_img_sum_97[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[783:776] <= 'd0;
end

wire  [25:0]  kernel_img_mul_98[0:8];
assign kernel_img_mul_98[0] = buffer_data_2[783:776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_98[1] = buffer_data_2[791:784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_98[2] = buffer_data_2[799:792] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_98[3] = buffer_data_1[783:776] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_98[4] = buffer_data_1[791:784] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_98[5] = buffer_data_1[799:792] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_98[6] = buffer_data_0[783:776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_98[7] = buffer_data_0[791:784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_98[8] = buffer_data_0[799:792] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_98 = kernel_img_mul_98[0] + kernel_img_mul_98[1] + kernel_img_mul_98[2] + 
                kernel_img_mul_98[3] + kernel_img_mul_98[4] + kernel_img_mul_98[5] + 
                kernel_img_mul_98[6] + kernel_img_mul_98[7] + kernel_img_mul_98[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[791:784] <= 'd0;
  else if (current_state==ST_START)
    blur_din[791:784] <= kernel_img_sum_98[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[791:784] <= 'd0;
end

wire  [25:0]  kernel_img_mul_99[0:8];
assign kernel_img_mul_99[0] = buffer_data_2[791:784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_99[1] = buffer_data_2[799:792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_99[2] = buffer_data_2[807:800] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_99[3] = buffer_data_1[791:784] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_99[4] = buffer_data_1[799:792] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_99[5] = buffer_data_1[807:800] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_99[6] = buffer_data_0[791:784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_99[7] = buffer_data_0[799:792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_99[8] = buffer_data_0[807:800] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_99 = kernel_img_mul_99[0] + kernel_img_mul_99[1] + kernel_img_mul_99[2] + 
                kernel_img_mul_99[3] + kernel_img_mul_99[4] + kernel_img_mul_99[5] + 
                kernel_img_mul_99[6] + kernel_img_mul_99[7] + kernel_img_mul_99[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[799:792] <= 'd0;
  else if (current_state==ST_START)
    blur_din[799:792] <= kernel_img_sum_99[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[799:792] <= 'd0;
end

wire  [25:0]  kernel_img_mul_100[0:8];
assign kernel_img_mul_100[0] = buffer_data_2[799:792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_100[1] = buffer_data_2[807:800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_100[2] = buffer_data_2[815:808] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_100[3] = buffer_data_1[799:792] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_100[4] = buffer_data_1[807:800] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_100[5] = buffer_data_1[815:808] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_100[6] = buffer_data_0[799:792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_100[7] = buffer_data_0[807:800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_100[8] = buffer_data_0[815:808] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_100 = kernel_img_mul_100[0] + kernel_img_mul_100[1] + kernel_img_mul_100[2] + 
                kernel_img_mul_100[3] + kernel_img_mul_100[4] + kernel_img_mul_100[5] + 
                kernel_img_mul_100[6] + kernel_img_mul_100[7] + kernel_img_mul_100[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[807:800] <= 'd0;
  else if (current_state==ST_START)
    blur_din[807:800] <= kernel_img_sum_100[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[807:800] <= 'd0;
end

wire  [25:0]  kernel_img_mul_101[0:8];
assign kernel_img_mul_101[0] = buffer_data_2[807:800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_101[1] = buffer_data_2[815:808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_101[2] = buffer_data_2[823:816] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_101[3] = buffer_data_1[807:800] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_101[4] = buffer_data_1[815:808] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_101[5] = buffer_data_1[823:816] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_101[6] = buffer_data_0[807:800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_101[7] = buffer_data_0[815:808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_101[8] = buffer_data_0[823:816] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_101 = kernel_img_mul_101[0] + kernel_img_mul_101[1] + kernel_img_mul_101[2] + 
                kernel_img_mul_101[3] + kernel_img_mul_101[4] + kernel_img_mul_101[5] + 
                kernel_img_mul_101[6] + kernel_img_mul_101[7] + kernel_img_mul_101[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[815:808] <= 'd0;
  else if (current_state==ST_START)
    blur_din[815:808] <= kernel_img_sum_101[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[815:808] <= 'd0;
end

wire  [25:0]  kernel_img_mul_102[0:8];
assign kernel_img_mul_102[0] = buffer_data_2[815:808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_102[1] = buffer_data_2[823:816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_102[2] = buffer_data_2[831:824] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_102[3] = buffer_data_1[815:808] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_102[4] = buffer_data_1[823:816] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_102[5] = buffer_data_1[831:824] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_102[6] = buffer_data_0[815:808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_102[7] = buffer_data_0[823:816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_102[8] = buffer_data_0[831:824] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_102 = kernel_img_mul_102[0] + kernel_img_mul_102[1] + kernel_img_mul_102[2] + 
                kernel_img_mul_102[3] + kernel_img_mul_102[4] + kernel_img_mul_102[5] + 
                kernel_img_mul_102[6] + kernel_img_mul_102[7] + kernel_img_mul_102[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[823:816] <= 'd0;
  else if (current_state==ST_START)
    blur_din[823:816] <= kernel_img_sum_102[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[823:816] <= 'd0;
end

wire  [25:0]  kernel_img_mul_103[0:8];
assign kernel_img_mul_103[0] = buffer_data_2[823:816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_103[1] = buffer_data_2[831:824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_103[2] = buffer_data_2[839:832] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_103[3] = buffer_data_1[823:816] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_103[4] = buffer_data_1[831:824] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_103[5] = buffer_data_1[839:832] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_103[6] = buffer_data_0[823:816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_103[7] = buffer_data_0[831:824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_103[8] = buffer_data_0[839:832] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_103 = kernel_img_mul_103[0] + kernel_img_mul_103[1] + kernel_img_mul_103[2] + 
                kernel_img_mul_103[3] + kernel_img_mul_103[4] + kernel_img_mul_103[5] + 
                kernel_img_mul_103[6] + kernel_img_mul_103[7] + kernel_img_mul_103[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[831:824] <= 'd0;
  else if (current_state==ST_START)
    blur_din[831:824] <= kernel_img_sum_103[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[831:824] <= 'd0;
end

wire  [25:0]  kernel_img_mul_104[0:8];
assign kernel_img_mul_104[0] = buffer_data_2[831:824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_104[1] = buffer_data_2[839:832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_104[2] = buffer_data_2[847:840] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_104[3] = buffer_data_1[831:824] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_104[4] = buffer_data_1[839:832] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_104[5] = buffer_data_1[847:840] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_104[6] = buffer_data_0[831:824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_104[7] = buffer_data_0[839:832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_104[8] = buffer_data_0[847:840] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_104 = kernel_img_mul_104[0] + kernel_img_mul_104[1] + kernel_img_mul_104[2] + 
                kernel_img_mul_104[3] + kernel_img_mul_104[4] + kernel_img_mul_104[5] + 
                kernel_img_mul_104[6] + kernel_img_mul_104[7] + kernel_img_mul_104[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[839:832] <= 'd0;
  else if (current_state==ST_START)
    blur_din[839:832] <= kernel_img_sum_104[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[839:832] <= 'd0;
end

wire  [25:0]  kernel_img_mul_105[0:8];
assign kernel_img_mul_105[0] = buffer_data_2[839:832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_105[1] = buffer_data_2[847:840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_105[2] = buffer_data_2[855:848] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_105[3] = buffer_data_1[839:832] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_105[4] = buffer_data_1[847:840] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_105[5] = buffer_data_1[855:848] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_105[6] = buffer_data_0[839:832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_105[7] = buffer_data_0[847:840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_105[8] = buffer_data_0[855:848] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_105 = kernel_img_mul_105[0] + kernel_img_mul_105[1] + kernel_img_mul_105[2] + 
                kernel_img_mul_105[3] + kernel_img_mul_105[4] + kernel_img_mul_105[5] + 
                kernel_img_mul_105[6] + kernel_img_mul_105[7] + kernel_img_mul_105[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[847:840] <= 'd0;
  else if (current_state==ST_START)
    blur_din[847:840] <= kernel_img_sum_105[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[847:840] <= 'd0;
end

wire  [25:0]  kernel_img_mul_106[0:8];
assign kernel_img_mul_106[0] = buffer_data_2[847:840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_106[1] = buffer_data_2[855:848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_106[2] = buffer_data_2[863:856] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_106[3] = buffer_data_1[847:840] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_106[4] = buffer_data_1[855:848] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_106[5] = buffer_data_1[863:856] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_106[6] = buffer_data_0[847:840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_106[7] = buffer_data_0[855:848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_106[8] = buffer_data_0[863:856] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_106 = kernel_img_mul_106[0] + kernel_img_mul_106[1] + kernel_img_mul_106[2] + 
                kernel_img_mul_106[3] + kernel_img_mul_106[4] + kernel_img_mul_106[5] + 
                kernel_img_mul_106[6] + kernel_img_mul_106[7] + kernel_img_mul_106[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[855:848] <= 'd0;
  else if (current_state==ST_START)
    blur_din[855:848] <= kernel_img_sum_106[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[855:848] <= 'd0;
end

wire  [25:0]  kernel_img_mul_107[0:8];
assign kernel_img_mul_107[0] = buffer_data_2[855:848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_107[1] = buffer_data_2[863:856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_107[2] = buffer_data_2[871:864] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_107[3] = buffer_data_1[855:848] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_107[4] = buffer_data_1[863:856] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_107[5] = buffer_data_1[871:864] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_107[6] = buffer_data_0[855:848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_107[7] = buffer_data_0[863:856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_107[8] = buffer_data_0[871:864] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_107 = kernel_img_mul_107[0] + kernel_img_mul_107[1] + kernel_img_mul_107[2] + 
                kernel_img_mul_107[3] + kernel_img_mul_107[4] + kernel_img_mul_107[5] + 
                kernel_img_mul_107[6] + kernel_img_mul_107[7] + kernel_img_mul_107[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[863:856] <= 'd0;
  else if (current_state==ST_START)
    blur_din[863:856] <= kernel_img_sum_107[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[863:856] <= 'd0;
end

wire  [25:0]  kernel_img_mul_108[0:8];
assign kernel_img_mul_108[0] = buffer_data_2[863:856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_108[1] = buffer_data_2[871:864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_108[2] = buffer_data_2[879:872] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_108[3] = buffer_data_1[863:856] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_108[4] = buffer_data_1[871:864] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_108[5] = buffer_data_1[879:872] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_108[6] = buffer_data_0[863:856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_108[7] = buffer_data_0[871:864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_108[8] = buffer_data_0[879:872] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_108 = kernel_img_mul_108[0] + kernel_img_mul_108[1] + kernel_img_mul_108[2] + 
                kernel_img_mul_108[3] + kernel_img_mul_108[4] + kernel_img_mul_108[5] + 
                kernel_img_mul_108[6] + kernel_img_mul_108[7] + kernel_img_mul_108[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[871:864] <= 'd0;
  else if (current_state==ST_START)
    blur_din[871:864] <= kernel_img_sum_108[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[871:864] <= 'd0;
end

wire  [25:0]  kernel_img_mul_109[0:8];
assign kernel_img_mul_109[0] = buffer_data_2[871:864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_109[1] = buffer_data_2[879:872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_109[2] = buffer_data_2[887:880] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_109[3] = buffer_data_1[871:864] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_109[4] = buffer_data_1[879:872] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_109[5] = buffer_data_1[887:880] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_109[6] = buffer_data_0[871:864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_109[7] = buffer_data_0[879:872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_109[8] = buffer_data_0[887:880] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_109 = kernel_img_mul_109[0] + kernel_img_mul_109[1] + kernel_img_mul_109[2] + 
                kernel_img_mul_109[3] + kernel_img_mul_109[4] + kernel_img_mul_109[5] + 
                kernel_img_mul_109[6] + kernel_img_mul_109[7] + kernel_img_mul_109[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[879:872] <= 'd0;
  else if (current_state==ST_START)
    blur_din[879:872] <= kernel_img_sum_109[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[879:872] <= 'd0;
end

wire  [25:0]  kernel_img_mul_110[0:8];
assign kernel_img_mul_110[0] = buffer_data_2[879:872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_110[1] = buffer_data_2[887:880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_110[2] = buffer_data_2[895:888] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_110[3] = buffer_data_1[879:872] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_110[4] = buffer_data_1[887:880] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_110[5] = buffer_data_1[895:888] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_110[6] = buffer_data_0[879:872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_110[7] = buffer_data_0[887:880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_110[8] = buffer_data_0[895:888] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_110 = kernel_img_mul_110[0] + kernel_img_mul_110[1] + kernel_img_mul_110[2] + 
                kernel_img_mul_110[3] + kernel_img_mul_110[4] + kernel_img_mul_110[5] + 
                kernel_img_mul_110[6] + kernel_img_mul_110[7] + kernel_img_mul_110[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[887:880] <= 'd0;
  else if (current_state==ST_START)
    blur_din[887:880] <= kernel_img_sum_110[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[887:880] <= 'd0;
end

wire  [25:0]  kernel_img_mul_111[0:8];
assign kernel_img_mul_111[0] = buffer_data_2[887:880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_111[1] = buffer_data_2[895:888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_111[2] = buffer_data_2[903:896] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_111[3] = buffer_data_1[887:880] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_111[4] = buffer_data_1[895:888] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_111[5] = buffer_data_1[903:896] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_111[6] = buffer_data_0[887:880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_111[7] = buffer_data_0[895:888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_111[8] = buffer_data_0[903:896] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_111 = kernel_img_mul_111[0] + kernel_img_mul_111[1] + kernel_img_mul_111[2] + 
                kernel_img_mul_111[3] + kernel_img_mul_111[4] + kernel_img_mul_111[5] + 
                kernel_img_mul_111[6] + kernel_img_mul_111[7] + kernel_img_mul_111[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[895:888] <= 'd0;
  else if (current_state==ST_START)
    blur_din[895:888] <= kernel_img_sum_111[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[895:888] <= 'd0;
end

wire  [25:0]  kernel_img_mul_112[0:8];
assign kernel_img_mul_112[0] = buffer_data_2[895:888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_112[1] = buffer_data_2[903:896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_112[2] = buffer_data_2[911:904] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_112[3] = buffer_data_1[895:888] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_112[4] = buffer_data_1[903:896] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_112[5] = buffer_data_1[911:904] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_112[6] = buffer_data_0[895:888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_112[7] = buffer_data_0[903:896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_112[8] = buffer_data_0[911:904] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_112 = kernel_img_mul_112[0] + kernel_img_mul_112[1] + kernel_img_mul_112[2] + 
                kernel_img_mul_112[3] + kernel_img_mul_112[4] + kernel_img_mul_112[5] + 
                kernel_img_mul_112[6] + kernel_img_mul_112[7] + kernel_img_mul_112[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[903:896] <= 'd0;
  else if (current_state==ST_START)
    blur_din[903:896] <= kernel_img_sum_112[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[903:896] <= 'd0;
end

wire  [25:0]  kernel_img_mul_113[0:8];
assign kernel_img_mul_113[0] = buffer_data_2[903:896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_113[1] = buffer_data_2[911:904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_113[2] = buffer_data_2[919:912] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_113[3] = buffer_data_1[903:896] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_113[4] = buffer_data_1[911:904] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_113[5] = buffer_data_1[919:912] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_113[6] = buffer_data_0[903:896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_113[7] = buffer_data_0[911:904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_113[8] = buffer_data_0[919:912] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_113 = kernel_img_mul_113[0] + kernel_img_mul_113[1] + kernel_img_mul_113[2] + 
                kernel_img_mul_113[3] + kernel_img_mul_113[4] + kernel_img_mul_113[5] + 
                kernel_img_mul_113[6] + kernel_img_mul_113[7] + kernel_img_mul_113[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[911:904] <= 'd0;
  else if (current_state==ST_START)
    blur_din[911:904] <= kernel_img_sum_113[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[911:904] <= 'd0;
end

wire  [25:0]  kernel_img_mul_114[0:8];
assign kernel_img_mul_114[0] = buffer_data_2[911:904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_114[1] = buffer_data_2[919:912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_114[2] = buffer_data_2[927:920] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_114[3] = buffer_data_1[911:904] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_114[4] = buffer_data_1[919:912] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_114[5] = buffer_data_1[927:920] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_114[6] = buffer_data_0[911:904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_114[7] = buffer_data_0[919:912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_114[8] = buffer_data_0[927:920] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_114 = kernel_img_mul_114[0] + kernel_img_mul_114[1] + kernel_img_mul_114[2] + 
                kernel_img_mul_114[3] + kernel_img_mul_114[4] + kernel_img_mul_114[5] + 
                kernel_img_mul_114[6] + kernel_img_mul_114[7] + kernel_img_mul_114[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[919:912] <= 'd0;
  else if (current_state==ST_START)
    blur_din[919:912] <= kernel_img_sum_114[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[919:912] <= 'd0;
end

wire  [25:0]  kernel_img_mul_115[0:8];
assign kernel_img_mul_115[0] = buffer_data_2[919:912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_115[1] = buffer_data_2[927:920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_115[2] = buffer_data_2[935:928] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_115[3] = buffer_data_1[919:912] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_115[4] = buffer_data_1[927:920] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_115[5] = buffer_data_1[935:928] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_115[6] = buffer_data_0[919:912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_115[7] = buffer_data_0[927:920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_115[8] = buffer_data_0[935:928] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_115 = kernel_img_mul_115[0] + kernel_img_mul_115[1] + kernel_img_mul_115[2] + 
                kernel_img_mul_115[3] + kernel_img_mul_115[4] + kernel_img_mul_115[5] + 
                kernel_img_mul_115[6] + kernel_img_mul_115[7] + kernel_img_mul_115[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[927:920] <= 'd0;
  else if (current_state==ST_START)
    blur_din[927:920] <= kernel_img_sum_115[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[927:920] <= 'd0;
end

wire  [25:0]  kernel_img_mul_116[0:8];
assign kernel_img_mul_116[0] = buffer_data_2[927:920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_116[1] = buffer_data_2[935:928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_116[2] = buffer_data_2[943:936] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_116[3] = buffer_data_1[927:920] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_116[4] = buffer_data_1[935:928] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_116[5] = buffer_data_1[943:936] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_116[6] = buffer_data_0[927:920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_116[7] = buffer_data_0[935:928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_116[8] = buffer_data_0[943:936] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_116 = kernel_img_mul_116[0] + kernel_img_mul_116[1] + kernel_img_mul_116[2] + 
                kernel_img_mul_116[3] + kernel_img_mul_116[4] + kernel_img_mul_116[5] + 
                kernel_img_mul_116[6] + kernel_img_mul_116[7] + kernel_img_mul_116[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[935:928] <= 'd0;
  else if (current_state==ST_START)
    blur_din[935:928] <= kernel_img_sum_116[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[935:928] <= 'd0;
end

wire  [25:0]  kernel_img_mul_117[0:8];
assign kernel_img_mul_117[0] = buffer_data_2[935:928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_117[1] = buffer_data_2[943:936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_117[2] = buffer_data_2[951:944] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_117[3] = buffer_data_1[935:928] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_117[4] = buffer_data_1[943:936] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_117[5] = buffer_data_1[951:944] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_117[6] = buffer_data_0[935:928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_117[7] = buffer_data_0[943:936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_117[8] = buffer_data_0[951:944] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_117 = kernel_img_mul_117[0] + kernel_img_mul_117[1] + kernel_img_mul_117[2] + 
                kernel_img_mul_117[3] + kernel_img_mul_117[4] + kernel_img_mul_117[5] + 
                kernel_img_mul_117[6] + kernel_img_mul_117[7] + kernel_img_mul_117[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[943:936] <= 'd0;
  else if (current_state==ST_START)
    blur_din[943:936] <= kernel_img_sum_117[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[943:936] <= 'd0;
end

wire  [25:0]  kernel_img_mul_118[0:8];
assign kernel_img_mul_118[0] = buffer_data_2[943:936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_118[1] = buffer_data_2[951:944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_118[2] = buffer_data_2[959:952] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_118[3] = buffer_data_1[943:936] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_118[4] = buffer_data_1[951:944] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_118[5] = buffer_data_1[959:952] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_118[6] = buffer_data_0[943:936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_118[7] = buffer_data_0[951:944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_118[8] = buffer_data_0[959:952] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_118 = kernel_img_mul_118[0] + kernel_img_mul_118[1] + kernel_img_mul_118[2] + 
                kernel_img_mul_118[3] + kernel_img_mul_118[4] + kernel_img_mul_118[5] + 
                kernel_img_mul_118[6] + kernel_img_mul_118[7] + kernel_img_mul_118[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[951:944] <= 'd0;
  else if (current_state==ST_START)
    blur_din[951:944] <= kernel_img_sum_118[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[951:944] <= 'd0;
end

wire  [25:0]  kernel_img_mul_119[0:8];
assign kernel_img_mul_119[0] = buffer_data_2[951:944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_119[1] = buffer_data_2[959:952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_119[2] = buffer_data_2[967:960] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_119[3] = buffer_data_1[951:944] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_119[4] = buffer_data_1[959:952] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_119[5] = buffer_data_1[967:960] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_119[6] = buffer_data_0[951:944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_119[7] = buffer_data_0[959:952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_119[8] = buffer_data_0[967:960] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_119 = kernel_img_mul_119[0] + kernel_img_mul_119[1] + kernel_img_mul_119[2] + 
                kernel_img_mul_119[3] + kernel_img_mul_119[4] + kernel_img_mul_119[5] + 
                kernel_img_mul_119[6] + kernel_img_mul_119[7] + kernel_img_mul_119[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[959:952] <= 'd0;
  else if (current_state==ST_START)
    blur_din[959:952] <= kernel_img_sum_119[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[959:952] <= 'd0;
end

wire  [25:0]  kernel_img_mul_120[0:8];
assign kernel_img_mul_120[0] = buffer_data_2[959:952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_120[1] = buffer_data_2[967:960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_120[2] = buffer_data_2[975:968] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_120[3] = buffer_data_1[959:952] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_120[4] = buffer_data_1[967:960] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_120[5] = buffer_data_1[975:968] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_120[6] = buffer_data_0[959:952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_120[7] = buffer_data_0[967:960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_120[8] = buffer_data_0[975:968] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_120 = kernel_img_mul_120[0] + kernel_img_mul_120[1] + kernel_img_mul_120[2] + 
                kernel_img_mul_120[3] + kernel_img_mul_120[4] + kernel_img_mul_120[5] + 
                kernel_img_mul_120[6] + kernel_img_mul_120[7] + kernel_img_mul_120[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[967:960] <= 'd0;
  else if (current_state==ST_START)
    blur_din[967:960] <= kernel_img_sum_120[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[967:960] <= 'd0;
end

wire  [25:0]  kernel_img_mul_121[0:8];
assign kernel_img_mul_121[0] = buffer_data_2[967:960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_121[1] = buffer_data_2[975:968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_121[2] = buffer_data_2[983:976] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_121[3] = buffer_data_1[967:960] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_121[4] = buffer_data_1[975:968] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_121[5] = buffer_data_1[983:976] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_121[6] = buffer_data_0[967:960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_121[7] = buffer_data_0[975:968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_121[8] = buffer_data_0[983:976] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_121 = kernel_img_mul_121[0] + kernel_img_mul_121[1] + kernel_img_mul_121[2] + 
                kernel_img_mul_121[3] + kernel_img_mul_121[4] + kernel_img_mul_121[5] + 
                kernel_img_mul_121[6] + kernel_img_mul_121[7] + kernel_img_mul_121[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[975:968] <= 'd0;
  else if (current_state==ST_START)
    blur_din[975:968] <= kernel_img_sum_121[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[975:968] <= 'd0;
end

wire  [25:0]  kernel_img_mul_122[0:8];
assign kernel_img_mul_122[0] = buffer_data_2[975:968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_122[1] = buffer_data_2[983:976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_122[2] = buffer_data_2[991:984] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_122[3] = buffer_data_1[975:968] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_122[4] = buffer_data_1[983:976] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_122[5] = buffer_data_1[991:984] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_122[6] = buffer_data_0[975:968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_122[7] = buffer_data_0[983:976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_122[8] = buffer_data_0[991:984] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_122 = kernel_img_mul_122[0] + kernel_img_mul_122[1] + kernel_img_mul_122[2] + 
                kernel_img_mul_122[3] + kernel_img_mul_122[4] + kernel_img_mul_122[5] + 
                kernel_img_mul_122[6] + kernel_img_mul_122[7] + kernel_img_mul_122[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[983:976] <= 'd0;
  else if (current_state==ST_START)
    blur_din[983:976] <= kernel_img_sum_122[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[983:976] <= 'd0;
end

wire  [25:0]  kernel_img_mul_123[0:8];
assign kernel_img_mul_123[0] = buffer_data_2[983:976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_123[1] = buffer_data_2[991:984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_123[2] = buffer_data_2[999:992] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_123[3] = buffer_data_1[983:976] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_123[4] = buffer_data_1[991:984] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_123[5] = buffer_data_1[999:992] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_123[6] = buffer_data_0[983:976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_123[7] = buffer_data_0[991:984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_123[8] = buffer_data_0[999:992] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_123 = kernel_img_mul_123[0] + kernel_img_mul_123[1] + kernel_img_mul_123[2] + 
                kernel_img_mul_123[3] + kernel_img_mul_123[4] + kernel_img_mul_123[5] + 
                kernel_img_mul_123[6] + kernel_img_mul_123[7] + kernel_img_mul_123[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[991:984] <= 'd0;
  else if (current_state==ST_START)
    blur_din[991:984] <= kernel_img_sum_123[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[991:984] <= 'd0;
end

wire  [25:0]  kernel_img_mul_124[0:8];
assign kernel_img_mul_124[0] = buffer_data_2[991:984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_124[1] = buffer_data_2[999:992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_124[2] = buffer_data_2[1007:1000] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_124[3] = buffer_data_1[991:984] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_124[4] = buffer_data_1[999:992] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_124[5] = buffer_data_1[1007:1000] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_124[6] = buffer_data_0[991:984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_124[7] = buffer_data_0[999:992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_124[8] = buffer_data_0[1007:1000] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_124 = kernel_img_mul_124[0] + kernel_img_mul_124[1] + kernel_img_mul_124[2] + 
                kernel_img_mul_124[3] + kernel_img_mul_124[4] + kernel_img_mul_124[5] + 
                kernel_img_mul_124[6] + kernel_img_mul_124[7] + kernel_img_mul_124[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[999:992] <= 'd0;
  else if (current_state==ST_START)
    blur_din[999:992] <= kernel_img_sum_124[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[999:992] <= 'd0;
end

wire  [25:0]  kernel_img_mul_125[0:8];
assign kernel_img_mul_125[0] = buffer_data_2[999:992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_125[1] = buffer_data_2[1007:1000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_125[2] = buffer_data_2[1015:1008] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_125[3] = buffer_data_1[999:992] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_125[4] = buffer_data_1[1007:1000] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_125[5] = buffer_data_1[1015:1008] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_125[6] = buffer_data_0[999:992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_125[7] = buffer_data_0[1007:1000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_125[8] = buffer_data_0[1015:1008] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_125 = kernel_img_mul_125[0] + kernel_img_mul_125[1] + kernel_img_mul_125[2] + 
                kernel_img_mul_125[3] + kernel_img_mul_125[4] + kernel_img_mul_125[5] + 
                kernel_img_mul_125[6] + kernel_img_mul_125[7] + kernel_img_mul_125[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1007:1000] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1007:1000] <= kernel_img_sum_125[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1007:1000] <= 'd0;
end

wire  [25:0]  kernel_img_mul_126[0:8];
assign kernel_img_mul_126[0] = buffer_data_2[1007:1000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_126[1] = buffer_data_2[1015:1008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_126[2] = buffer_data_2[1023:1016] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_126[3] = buffer_data_1[1007:1000] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_126[4] = buffer_data_1[1015:1008] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_126[5] = buffer_data_1[1023:1016] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_126[6] = buffer_data_0[1007:1000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_126[7] = buffer_data_0[1015:1008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_126[8] = buffer_data_0[1023:1016] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_126 = kernel_img_mul_126[0] + kernel_img_mul_126[1] + kernel_img_mul_126[2] + 
                kernel_img_mul_126[3] + kernel_img_mul_126[4] + kernel_img_mul_126[5] + 
                kernel_img_mul_126[6] + kernel_img_mul_126[7] + kernel_img_mul_126[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1015:1008] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1015:1008] <= kernel_img_sum_126[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1015:1008] <= 'd0;
end

wire  [25:0]  kernel_img_mul_127[0:8];
assign kernel_img_mul_127[0] = buffer_data_2[1015:1008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_127[1] = buffer_data_2[1023:1016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_127[2] = buffer_data_2[1031:1024] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_127[3] = buffer_data_1[1015:1008] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_127[4] = buffer_data_1[1023:1016] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_127[5] = buffer_data_1[1031:1024] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_127[6] = buffer_data_0[1015:1008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_127[7] = buffer_data_0[1023:1016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_127[8] = buffer_data_0[1031:1024] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_127 = kernel_img_mul_127[0] + kernel_img_mul_127[1] + kernel_img_mul_127[2] + 
                kernel_img_mul_127[3] + kernel_img_mul_127[4] + kernel_img_mul_127[5] + 
                kernel_img_mul_127[6] + kernel_img_mul_127[7] + kernel_img_mul_127[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1023:1016] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1023:1016] <= kernel_img_sum_127[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1023:1016] <= 'd0;
end

wire  [25:0]  kernel_img_mul_128[0:8];
assign kernel_img_mul_128[0] = buffer_data_2[1023:1016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_128[1] = buffer_data_2[1031:1024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_128[2] = buffer_data_2[1039:1032] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_128[3] = buffer_data_1[1023:1016] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_128[4] = buffer_data_1[1031:1024] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_128[5] = buffer_data_1[1039:1032] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_128[6] = buffer_data_0[1023:1016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_128[7] = buffer_data_0[1031:1024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_128[8] = buffer_data_0[1039:1032] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_128 = kernel_img_mul_128[0] + kernel_img_mul_128[1] + kernel_img_mul_128[2] + 
                kernel_img_mul_128[3] + kernel_img_mul_128[4] + kernel_img_mul_128[5] + 
                kernel_img_mul_128[6] + kernel_img_mul_128[7] + kernel_img_mul_128[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1031:1024] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1031:1024] <= kernel_img_sum_128[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1031:1024] <= 'd0;
end

wire  [25:0]  kernel_img_mul_129[0:8];
assign kernel_img_mul_129[0] = buffer_data_2[1031:1024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_129[1] = buffer_data_2[1039:1032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_129[2] = buffer_data_2[1047:1040] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_129[3] = buffer_data_1[1031:1024] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_129[4] = buffer_data_1[1039:1032] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_129[5] = buffer_data_1[1047:1040] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_129[6] = buffer_data_0[1031:1024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_129[7] = buffer_data_0[1039:1032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_129[8] = buffer_data_0[1047:1040] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_129 = kernel_img_mul_129[0] + kernel_img_mul_129[1] + kernel_img_mul_129[2] + 
                kernel_img_mul_129[3] + kernel_img_mul_129[4] + kernel_img_mul_129[5] + 
                kernel_img_mul_129[6] + kernel_img_mul_129[7] + kernel_img_mul_129[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1039:1032] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1039:1032] <= kernel_img_sum_129[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1039:1032] <= 'd0;
end

wire  [25:0]  kernel_img_mul_130[0:8];
assign kernel_img_mul_130[0] = buffer_data_2[1039:1032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_130[1] = buffer_data_2[1047:1040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_130[2] = buffer_data_2[1055:1048] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_130[3] = buffer_data_1[1039:1032] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_130[4] = buffer_data_1[1047:1040] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_130[5] = buffer_data_1[1055:1048] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_130[6] = buffer_data_0[1039:1032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_130[7] = buffer_data_0[1047:1040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_130[8] = buffer_data_0[1055:1048] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_130 = kernel_img_mul_130[0] + kernel_img_mul_130[1] + kernel_img_mul_130[2] + 
                kernel_img_mul_130[3] + kernel_img_mul_130[4] + kernel_img_mul_130[5] + 
                kernel_img_mul_130[6] + kernel_img_mul_130[7] + kernel_img_mul_130[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1047:1040] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1047:1040] <= kernel_img_sum_130[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1047:1040] <= 'd0;
end

wire  [25:0]  kernel_img_mul_131[0:8];
assign kernel_img_mul_131[0] = buffer_data_2[1047:1040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_131[1] = buffer_data_2[1055:1048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_131[2] = buffer_data_2[1063:1056] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_131[3] = buffer_data_1[1047:1040] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_131[4] = buffer_data_1[1055:1048] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_131[5] = buffer_data_1[1063:1056] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_131[6] = buffer_data_0[1047:1040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_131[7] = buffer_data_0[1055:1048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_131[8] = buffer_data_0[1063:1056] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_131 = kernel_img_mul_131[0] + kernel_img_mul_131[1] + kernel_img_mul_131[2] + 
                kernel_img_mul_131[3] + kernel_img_mul_131[4] + kernel_img_mul_131[5] + 
                kernel_img_mul_131[6] + kernel_img_mul_131[7] + kernel_img_mul_131[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1055:1048] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1055:1048] <= kernel_img_sum_131[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1055:1048] <= 'd0;
end

wire  [25:0]  kernel_img_mul_132[0:8];
assign kernel_img_mul_132[0] = buffer_data_2[1055:1048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_132[1] = buffer_data_2[1063:1056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_132[2] = buffer_data_2[1071:1064] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_132[3] = buffer_data_1[1055:1048] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_132[4] = buffer_data_1[1063:1056] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_132[5] = buffer_data_1[1071:1064] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_132[6] = buffer_data_0[1055:1048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_132[7] = buffer_data_0[1063:1056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_132[8] = buffer_data_0[1071:1064] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_132 = kernel_img_mul_132[0] + kernel_img_mul_132[1] + kernel_img_mul_132[2] + 
                kernel_img_mul_132[3] + kernel_img_mul_132[4] + kernel_img_mul_132[5] + 
                kernel_img_mul_132[6] + kernel_img_mul_132[7] + kernel_img_mul_132[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1063:1056] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1063:1056] <= kernel_img_sum_132[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1063:1056] <= 'd0;
end

wire  [25:0]  kernel_img_mul_133[0:8];
assign kernel_img_mul_133[0] = buffer_data_2[1063:1056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_133[1] = buffer_data_2[1071:1064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_133[2] = buffer_data_2[1079:1072] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_133[3] = buffer_data_1[1063:1056] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_133[4] = buffer_data_1[1071:1064] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_133[5] = buffer_data_1[1079:1072] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_133[6] = buffer_data_0[1063:1056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_133[7] = buffer_data_0[1071:1064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_133[8] = buffer_data_0[1079:1072] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_133 = kernel_img_mul_133[0] + kernel_img_mul_133[1] + kernel_img_mul_133[2] + 
                kernel_img_mul_133[3] + kernel_img_mul_133[4] + kernel_img_mul_133[5] + 
                kernel_img_mul_133[6] + kernel_img_mul_133[7] + kernel_img_mul_133[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1071:1064] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1071:1064] <= kernel_img_sum_133[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1071:1064] <= 'd0;
end

wire  [25:0]  kernel_img_mul_134[0:8];
assign kernel_img_mul_134[0] = buffer_data_2[1071:1064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_134[1] = buffer_data_2[1079:1072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_134[2] = buffer_data_2[1087:1080] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_134[3] = buffer_data_1[1071:1064] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_134[4] = buffer_data_1[1079:1072] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_134[5] = buffer_data_1[1087:1080] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_134[6] = buffer_data_0[1071:1064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_134[7] = buffer_data_0[1079:1072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_134[8] = buffer_data_0[1087:1080] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_134 = kernel_img_mul_134[0] + kernel_img_mul_134[1] + kernel_img_mul_134[2] + 
                kernel_img_mul_134[3] + kernel_img_mul_134[4] + kernel_img_mul_134[5] + 
                kernel_img_mul_134[6] + kernel_img_mul_134[7] + kernel_img_mul_134[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1079:1072] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1079:1072] <= kernel_img_sum_134[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1079:1072] <= 'd0;
end

wire  [25:0]  kernel_img_mul_135[0:8];
assign kernel_img_mul_135[0] = buffer_data_2[1079:1072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_135[1] = buffer_data_2[1087:1080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_135[2] = buffer_data_2[1095:1088] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_135[3] = buffer_data_1[1079:1072] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_135[4] = buffer_data_1[1087:1080] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_135[5] = buffer_data_1[1095:1088] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_135[6] = buffer_data_0[1079:1072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_135[7] = buffer_data_0[1087:1080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_135[8] = buffer_data_0[1095:1088] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_135 = kernel_img_mul_135[0] + kernel_img_mul_135[1] + kernel_img_mul_135[2] + 
                kernel_img_mul_135[3] + kernel_img_mul_135[4] + kernel_img_mul_135[5] + 
                kernel_img_mul_135[6] + kernel_img_mul_135[7] + kernel_img_mul_135[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1087:1080] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1087:1080] <= kernel_img_sum_135[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1087:1080] <= 'd0;
end

wire  [25:0]  kernel_img_mul_136[0:8];
assign kernel_img_mul_136[0] = buffer_data_2[1087:1080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_136[1] = buffer_data_2[1095:1088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_136[2] = buffer_data_2[1103:1096] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_136[3] = buffer_data_1[1087:1080] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_136[4] = buffer_data_1[1095:1088] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_136[5] = buffer_data_1[1103:1096] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_136[6] = buffer_data_0[1087:1080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_136[7] = buffer_data_0[1095:1088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_136[8] = buffer_data_0[1103:1096] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_136 = kernel_img_mul_136[0] + kernel_img_mul_136[1] + kernel_img_mul_136[2] + 
                kernel_img_mul_136[3] + kernel_img_mul_136[4] + kernel_img_mul_136[5] + 
                kernel_img_mul_136[6] + kernel_img_mul_136[7] + kernel_img_mul_136[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1095:1088] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1095:1088] <= kernel_img_sum_136[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1095:1088] <= 'd0;
end

wire  [25:0]  kernel_img_mul_137[0:8];
assign kernel_img_mul_137[0] = buffer_data_2[1095:1088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_137[1] = buffer_data_2[1103:1096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_137[2] = buffer_data_2[1111:1104] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_137[3] = buffer_data_1[1095:1088] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_137[4] = buffer_data_1[1103:1096] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_137[5] = buffer_data_1[1111:1104] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_137[6] = buffer_data_0[1095:1088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_137[7] = buffer_data_0[1103:1096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_137[8] = buffer_data_0[1111:1104] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_137 = kernel_img_mul_137[0] + kernel_img_mul_137[1] + kernel_img_mul_137[2] + 
                kernel_img_mul_137[3] + kernel_img_mul_137[4] + kernel_img_mul_137[5] + 
                kernel_img_mul_137[6] + kernel_img_mul_137[7] + kernel_img_mul_137[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1103:1096] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1103:1096] <= kernel_img_sum_137[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1103:1096] <= 'd0;
end

wire  [25:0]  kernel_img_mul_138[0:8];
assign kernel_img_mul_138[0] = buffer_data_2[1103:1096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_138[1] = buffer_data_2[1111:1104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_138[2] = buffer_data_2[1119:1112] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_138[3] = buffer_data_1[1103:1096] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_138[4] = buffer_data_1[1111:1104] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_138[5] = buffer_data_1[1119:1112] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_138[6] = buffer_data_0[1103:1096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_138[7] = buffer_data_0[1111:1104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_138[8] = buffer_data_0[1119:1112] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_138 = kernel_img_mul_138[0] + kernel_img_mul_138[1] + kernel_img_mul_138[2] + 
                kernel_img_mul_138[3] + kernel_img_mul_138[4] + kernel_img_mul_138[5] + 
                kernel_img_mul_138[6] + kernel_img_mul_138[7] + kernel_img_mul_138[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1111:1104] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1111:1104] <= kernel_img_sum_138[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1111:1104] <= 'd0;
end

wire  [25:0]  kernel_img_mul_139[0:8];
assign kernel_img_mul_139[0] = buffer_data_2[1111:1104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_139[1] = buffer_data_2[1119:1112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_139[2] = buffer_data_2[1127:1120] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_139[3] = buffer_data_1[1111:1104] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_139[4] = buffer_data_1[1119:1112] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_139[5] = buffer_data_1[1127:1120] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_139[6] = buffer_data_0[1111:1104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_139[7] = buffer_data_0[1119:1112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_139[8] = buffer_data_0[1127:1120] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_139 = kernel_img_mul_139[0] + kernel_img_mul_139[1] + kernel_img_mul_139[2] + 
                kernel_img_mul_139[3] + kernel_img_mul_139[4] + kernel_img_mul_139[5] + 
                kernel_img_mul_139[6] + kernel_img_mul_139[7] + kernel_img_mul_139[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1119:1112] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1119:1112] <= kernel_img_sum_139[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1119:1112] <= 'd0;
end

wire  [25:0]  kernel_img_mul_140[0:8];
assign kernel_img_mul_140[0] = buffer_data_2[1119:1112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_140[1] = buffer_data_2[1127:1120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_140[2] = buffer_data_2[1135:1128] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_140[3] = buffer_data_1[1119:1112] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_140[4] = buffer_data_1[1127:1120] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_140[5] = buffer_data_1[1135:1128] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_140[6] = buffer_data_0[1119:1112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_140[7] = buffer_data_0[1127:1120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_140[8] = buffer_data_0[1135:1128] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_140 = kernel_img_mul_140[0] + kernel_img_mul_140[1] + kernel_img_mul_140[2] + 
                kernel_img_mul_140[3] + kernel_img_mul_140[4] + kernel_img_mul_140[5] + 
                kernel_img_mul_140[6] + kernel_img_mul_140[7] + kernel_img_mul_140[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1127:1120] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1127:1120] <= kernel_img_sum_140[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1127:1120] <= 'd0;
end

wire  [25:0]  kernel_img_mul_141[0:8];
assign kernel_img_mul_141[0] = buffer_data_2[1127:1120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_141[1] = buffer_data_2[1135:1128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_141[2] = buffer_data_2[1143:1136] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_141[3] = buffer_data_1[1127:1120] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_141[4] = buffer_data_1[1135:1128] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_141[5] = buffer_data_1[1143:1136] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_141[6] = buffer_data_0[1127:1120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_141[7] = buffer_data_0[1135:1128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_141[8] = buffer_data_0[1143:1136] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_141 = kernel_img_mul_141[0] + kernel_img_mul_141[1] + kernel_img_mul_141[2] + 
                kernel_img_mul_141[3] + kernel_img_mul_141[4] + kernel_img_mul_141[5] + 
                kernel_img_mul_141[6] + kernel_img_mul_141[7] + kernel_img_mul_141[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1135:1128] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1135:1128] <= kernel_img_sum_141[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1135:1128] <= 'd0;
end

wire  [25:0]  kernel_img_mul_142[0:8];
assign kernel_img_mul_142[0] = buffer_data_2[1135:1128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_142[1] = buffer_data_2[1143:1136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_142[2] = buffer_data_2[1151:1144] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_142[3] = buffer_data_1[1135:1128] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_142[4] = buffer_data_1[1143:1136] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_142[5] = buffer_data_1[1151:1144] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_142[6] = buffer_data_0[1135:1128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_142[7] = buffer_data_0[1143:1136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_142[8] = buffer_data_0[1151:1144] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_142 = kernel_img_mul_142[0] + kernel_img_mul_142[1] + kernel_img_mul_142[2] + 
                kernel_img_mul_142[3] + kernel_img_mul_142[4] + kernel_img_mul_142[5] + 
                kernel_img_mul_142[6] + kernel_img_mul_142[7] + kernel_img_mul_142[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1143:1136] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1143:1136] <= kernel_img_sum_142[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1143:1136] <= 'd0;
end

wire  [25:0]  kernel_img_mul_143[0:8];
assign kernel_img_mul_143[0] = buffer_data_2[1143:1136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_143[1] = buffer_data_2[1151:1144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_143[2] = buffer_data_2[1159:1152] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_143[3] = buffer_data_1[1143:1136] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_143[4] = buffer_data_1[1151:1144] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_143[5] = buffer_data_1[1159:1152] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_143[6] = buffer_data_0[1143:1136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_143[7] = buffer_data_0[1151:1144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_143[8] = buffer_data_0[1159:1152] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_143 = kernel_img_mul_143[0] + kernel_img_mul_143[1] + kernel_img_mul_143[2] + 
                kernel_img_mul_143[3] + kernel_img_mul_143[4] + kernel_img_mul_143[5] + 
                kernel_img_mul_143[6] + kernel_img_mul_143[7] + kernel_img_mul_143[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1151:1144] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1151:1144] <= kernel_img_sum_143[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1151:1144] <= 'd0;
end

wire  [25:0]  kernel_img_mul_144[0:8];
assign kernel_img_mul_144[0] = buffer_data_2[1151:1144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_144[1] = buffer_data_2[1159:1152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_144[2] = buffer_data_2[1167:1160] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_144[3] = buffer_data_1[1151:1144] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_144[4] = buffer_data_1[1159:1152] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_144[5] = buffer_data_1[1167:1160] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_144[6] = buffer_data_0[1151:1144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_144[7] = buffer_data_0[1159:1152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_144[8] = buffer_data_0[1167:1160] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_144 = kernel_img_mul_144[0] + kernel_img_mul_144[1] + kernel_img_mul_144[2] + 
                kernel_img_mul_144[3] + kernel_img_mul_144[4] + kernel_img_mul_144[5] + 
                kernel_img_mul_144[6] + kernel_img_mul_144[7] + kernel_img_mul_144[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1159:1152] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1159:1152] <= kernel_img_sum_144[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1159:1152] <= 'd0;
end

wire  [25:0]  kernel_img_mul_145[0:8];
assign kernel_img_mul_145[0] = buffer_data_2[1159:1152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_145[1] = buffer_data_2[1167:1160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_145[2] = buffer_data_2[1175:1168] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_145[3] = buffer_data_1[1159:1152] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_145[4] = buffer_data_1[1167:1160] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_145[5] = buffer_data_1[1175:1168] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_145[6] = buffer_data_0[1159:1152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_145[7] = buffer_data_0[1167:1160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_145[8] = buffer_data_0[1175:1168] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_145 = kernel_img_mul_145[0] + kernel_img_mul_145[1] + kernel_img_mul_145[2] + 
                kernel_img_mul_145[3] + kernel_img_mul_145[4] + kernel_img_mul_145[5] + 
                kernel_img_mul_145[6] + kernel_img_mul_145[7] + kernel_img_mul_145[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1167:1160] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1167:1160] <= kernel_img_sum_145[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1167:1160] <= 'd0;
end

wire  [25:0]  kernel_img_mul_146[0:8];
assign kernel_img_mul_146[0] = buffer_data_2[1167:1160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_146[1] = buffer_data_2[1175:1168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_146[2] = buffer_data_2[1183:1176] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_146[3] = buffer_data_1[1167:1160] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_146[4] = buffer_data_1[1175:1168] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_146[5] = buffer_data_1[1183:1176] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_146[6] = buffer_data_0[1167:1160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_146[7] = buffer_data_0[1175:1168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_146[8] = buffer_data_0[1183:1176] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_146 = kernel_img_mul_146[0] + kernel_img_mul_146[1] + kernel_img_mul_146[2] + 
                kernel_img_mul_146[3] + kernel_img_mul_146[4] + kernel_img_mul_146[5] + 
                kernel_img_mul_146[6] + kernel_img_mul_146[7] + kernel_img_mul_146[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1175:1168] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1175:1168] <= kernel_img_sum_146[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1175:1168] <= 'd0;
end

wire  [25:0]  kernel_img_mul_147[0:8];
assign kernel_img_mul_147[0] = buffer_data_2[1175:1168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_147[1] = buffer_data_2[1183:1176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_147[2] = buffer_data_2[1191:1184] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_147[3] = buffer_data_1[1175:1168] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_147[4] = buffer_data_1[1183:1176] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_147[5] = buffer_data_1[1191:1184] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_147[6] = buffer_data_0[1175:1168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_147[7] = buffer_data_0[1183:1176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_147[8] = buffer_data_0[1191:1184] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_147 = kernel_img_mul_147[0] + kernel_img_mul_147[1] + kernel_img_mul_147[2] + 
                kernel_img_mul_147[3] + kernel_img_mul_147[4] + kernel_img_mul_147[5] + 
                kernel_img_mul_147[6] + kernel_img_mul_147[7] + kernel_img_mul_147[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1183:1176] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1183:1176] <= kernel_img_sum_147[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1183:1176] <= 'd0;
end

wire  [25:0]  kernel_img_mul_148[0:8];
assign kernel_img_mul_148[0] = buffer_data_2[1183:1176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_148[1] = buffer_data_2[1191:1184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_148[2] = buffer_data_2[1199:1192] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_148[3] = buffer_data_1[1183:1176] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_148[4] = buffer_data_1[1191:1184] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_148[5] = buffer_data_1[1199:1192] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_148[6] = buffer_data_0[1183:1176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_148[7] = buffer_data_0[1191:1184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_148[8] = buffer_data_0[1199:1192] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_148 = kernel_img_mul_148[0] + kernel_img_mul_148[1] + kernel_img_mul_148[2] + 
                kernel_img_mul_148[3] + kernel_img_mul_148[4] + kernel_img_mul_148[5] + 
                kernel_img_mul_148[6] + kernel_img_mul_148[7] + kernel_img_mul_148[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1191:1184] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1191:1184] <= kernel_img_sum_148[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1191:1184] <= 'd0;
end

wire  [25:0]  kernel_img_mul_149[0:8];
assign kernel_img_mul_149[0] = buffer_data_2[1191:1184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_149[1] = buffer_data_2[1199:1192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_149[2] = buffer_data_2[1207:1200] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_149[3] = buffer_data_1[1191:1184] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_149[4] = buffer_data_1[1199:1192] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_149[5] = buffer_data_1[1207:1200] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_149[6] = buffer_data_0[1191:1184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_149[7] = buffer_data_0[1199:1192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_149[8] = buffer_data_0[1207:1200] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_149 = kernel_img_mul_149[0] + kernel_img_mul_149[1] + kernel_img_mul_149[2] + 
                kernel_img_mul_149[3] + kernel_img_mul_149[4] + kernel_img_mul_149[5] + 
                kernel_img_mul_149[6] + kernel_img_mul_149[7] + kernel_img_mul_149[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1199:1192] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1199:1192] <= kernel_img_sum_149[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1199:1192] <= 'd0;
end

wire  [25:0]  kernel_img_mul_150[0:8];
assign kernel_img_mul_150[0] = buffer_data_2[1199:1192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_150[1] = buffer_data_2[1207:1200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_150[2] = buffer_data_2[1215:1208] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_150[3] = buffer_data_1[1199:1192] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_150[4] = buffer_data_1[1207:1200] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_150[5] = buffer_data_1[1215:1208] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_150[6] = buffer_data_0[1199:1192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_150[7] = buffer_data_0[1207:1200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_150[8] = buffer_data_0[1215:1208] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_150 = kernel_img_mul_150[0] + kernel_img_mul_150[1] + kernel_img_mul_150[2] + 
                kernel_img_mul_150[3] + kernel_img_mul_150[4] + kernel_img_mul_150[5] + 
                kernel_img_mul_150[6] + kernel_img_mul_150[7] + kernel_img_mul_150[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1207:1200] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1207:1200] <= kernel_img_sum_150[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1207:1200] <= 'd0;
end

wire  [25:0]  kernel_img_mul_151[0:8];
assign kernel_img_mul_151[0] = buffer_data_2[1207:1200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_151[1] = buffer_data_2[1215:1208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_151[2] = buffer_data_2[1223:1216] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_151[3] = buffer_data_1[1207:1200] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_151[4] = buffer_data_1[1215:1208] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_151[5] = buffer_data_1[1223:1216] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_151[6] = buffer_data_0[1207:1200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_151[7] = buffer_data_0[1215:1208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_151[8] = buffer_data_0[1223:1216] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_151 = kernel_img_mul_151[0] + kernel_img_mul_151[1] + kernel_img_mul_151[2] + 
                kernel_img_mul_151[3] + kernel_img_mul_151[4] + kernel_img_mul_151[5] + 
                kernel_img_mul_151[6] + kernel_img_mul_151[7] + kernel_img_mul_151[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1215:1208] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1215:1208] <= kernel_img_sum_151[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1215:1208] <= 'd0;
end

wire  [25:0]  kernel_img_mul_152[0:8];
assign kernel_img_mul_152[0] = buffer_data_2[1215:1208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_152[1] = buffer_data_2[1223:1216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_152[2] = buffer_data_2[1231:1224] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_152[3] = buffer_data_1[1215:1208] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_152[4] = buffer_data_1[1223:1216] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_152[5] = buffer_data_1[1231:1224] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_152[6] = buffer_data_0[1215:1208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_152[7] = buffer_data_0[1223:1216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_152[8] = buffer_data_0[1231:1224] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_152 = kernel_img_mul_152[0] + kernel_img_mul_152[1] + kernel_img_mul_152[2] + 
                kernel_img_mul_152[3] + kernel_img_mul_152[4] + kernel_img_mul_152[5] + 
                kernel_img_mul_152[6] + kernel_img_mul_152[7] + kernel_img_mul_152[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1223:1216] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1223:1216] <= kernel_img_sum_152[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1223:1216] <= 'd0;
end

wire  [25:0]  kernel_img_mul_153[0:8];
assign kernel_img_mul_153[0] = buffer_data_2[1223:1216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_153[1] = buffer_data_2[1231:1224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_153[2] = buffer_data_2[1239:1232] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_153[3] = buffer_data_1[1223:1216] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_153[4] = buffer_data_1[1231:1224] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_153[5] = buffer_data_1[1239:1232] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_153[6] = buffer_data_0[1223:1216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_153[7] = buffer_data_0[1231:1224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_153[8] = buffer_data_0[1239:1232] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_153 = kernel_img_mul_153[0] + kernel_img_mul_153[1] + kernel_img_mul_153[2] + 
                kernel_img_mul_153[3] + kernel_img_mul_153[4] + kernel_img_mul_153[5] + 
                kernel_img_mul_153[6] + kernel_img_mul_153[7] + kernel_img_mul_153[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1231:1224] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1231:1224] <= kernel_img_sum_153[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1231:1224] <= 'd0;
end

wire  [25:0]  kernel_img_mul_154[0:8];
assign kernel_img_mul_154[0] = buffer_data_2[1231:1224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_154[1] = buffer_data_2[1239:1232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_154[2] = buffer_data_2[1247:1240] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_154[3] = buffer_data_1[1231:1224] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_154[4] = buffer_data_1[1239:1232] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_154[5] = buffer_data_1[1247:1240] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_154[6] = buffer_data_0[1231:1224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_154[7] = buffer_data_0[1239:1232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_154[8] = buffer_data_0[1247:1240] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_154 = kernel_img_mul_154[0] + kernel_img_mul_154[1] + kernel_img_mul_154[2] + 
                kernel_img_mul_154[3] + kernel_img_mul_154[4] + kernel_img_mul_154[5] + 
                kernel_img_mul_154[6] + kernel_img_mul_154[7] + kernel_img_mul_154[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1239:1232] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1239:1232] <= kernel_img_sum_154[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1239:1232] <= 'd0;
end

wire  [25:0]  kernel_img_mul_155[0:8];
assign kernel_img_mul_155[0] = buffer_data_2[1239:1232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_155[1] = buffer_data_2[1247:1240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_155[2] = buffer_data_2[1255:1248] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_155[3] = buffer_data_1[1239:1232] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_155[4] = buffer_data_1[1247:1240] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_155[5] = buffer_data_1[1255:1248] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_155[6] = buffer_data_0[1239:1232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_155[7] = buffer_data_0[1247:1240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_155[8] = buffer_data_0[1255:1248] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_155 = kernel_img_mul_155[0] + kernel_img_mul_155[1] + kernel_img_mul_155[2] + 
                kernel_img_mul_155[3] + kernel_img_mul_155[4] + kernel_img_mul_155[5] + 
                kernel_img_mul_155[6] + kernel_img_mul_155[7] + kernel_img_mul_155[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1247:1240] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1247:1240] <= kernel_img_sum_155[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1247:1240] <= 'd0;
end

wire  [25:0]  kernel_img_mul_156[0:8];
assign kernel_img_mul_156[0] = buffer_data_2[1247:1240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_156[1] = buffer_data_2[1255:1248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_156[2] = buffer_data_2[1263:1256] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_156[3] = buffer_data_1[1247:1240] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_156[4] = buffer_data_1[1255:1248] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_156[5] = buffer_data_1[1263:1256] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_156[6] = buffer_data_0[1247:1240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_156[7] = buffer_data_0[1255:1248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_156[8] = buffer_data_0[1263:1256] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_156 = kernel_img_mul_156[0] + kernel_img_mul_156[1] + kernel_img_mul_156[2] + 
                kernel_img_mul_156[3] + kernel_img_mul_156[4] + kernel_img_mul_156[5] + 
                kernel_img_mul_156[6] + kernel_img_mul_156[7] + kernel_img_mul_156[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1255:1248] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1255:1248] <= kernel_img_sum_156[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1255:1248] <= 'd0;
end

wire  [25:0]  kernel_img_mul_157[0:8];
assign kernel_img_mul_157[0] = buffer_data_2[1255:1248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_157[1] = buffer_data_2[1263:1256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_157[2] = buffer_data_2[1271:1264] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_157[3] = buffer_data_1[1255:1248] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_157[4] = buffer_data_1[1263:1256] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_157[5] = buffer_data_1[1271:1264] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_157[6] = buffer_data_0[1255:1248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_157[7] = buffer_data_0[1263:1256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_157[8] = buffer_data_0[1271:1264] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_157 = kernel_img_mul_157[0] + kernel_img_mul_157[1] + kernel_img_mul_157[2] + 
                kernel_img_mul_157[3] + kernel_img_mul_157[4] + kernel_img_mul_157[5] + 
                kernel_img_mul_157[6] + kernel_img_mul_157[7] + kernel_img_mul_157[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1263:1256] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1263:1256] <= kernel_img_sum_157[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1263:1256] <= 'd0;
end

wire  [25:0]  kernel_img_mul_158[0:8];
assign kernel_img_mul_158[0] = buffer_data_2[1263:1256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_158[1] = buffer_data_2[1271:1264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_158[2] = buffer_data_2[1279:1272] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_158[3] = buffer_data_1[1263:1256] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_158[4] = buffer_data_1[1271:1264] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_158[5] = buffer_data_1[1279:1272] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_158[6] = buffer_data_0[1263:1256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_158[7] = buffer_data_0[1271:1264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_158[8] = buffer_data_0[1279:1272] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_158 = kernel_img_mul_158[0] + kernel_img_mul_158[1] + kernel_img_mul_158[2] + 
                kernel_img_mul_158[3] + kernel_img_mul_158[4] + kernel_img_mul_158[5] + 
                kernel_img_mul_158[6] + kernel_img_mul_158[7] + kernel_img_mul_158[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1271:1264] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1271:1264] <= kernel_img_sum_158[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1271:1264] <= 'd0;
end

wire  [25:0]  kernel_img_mul_159[0:8];
assign kernel_img_mul_159[0] = buffer_data_2[1271:1264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_159[1] = buffer_data_2[1279:1272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_159[2] = buffer_data_2[1287:1280] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_159[3] = buffer_data_1[1271:1264] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_159[4] = buffer_data_1[1279:1272] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_159[5] = buffer_data_1[1287:1280] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_159[6] = buffer_data_0[1271:1264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_159[7] = buffer_data_0[1279:1272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_159[8] = buffer_data_0[1287:1280] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_159 = kernel_img_mul_159[0] + kernel_img_mul_159[1] + kernel_img_mul_159[2] + 
                kernel_img_mul_159[3] + kernel_img_mul_159[4] + kernel_img_mul_159[5] + 
                kernel_img_mul_159[6] + kernel_img_mul_159[7] + kernel_img_mul_159[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1279:1272] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1279:1272] <= kernel_img_sum_159[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1279:1272] <= 'd0;
end

wire  [25:0]  kernel_img_mul_160[0:8];
assign kernel_img_mul_160[0] = buffer_data_2[1279:1272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_160[1] = buffer_data_2[1287:1280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_160[2] = buffer_data_2[1295:1288] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_160[3] = buffer_data_1[1279:1272] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_160[4] = buffer_data_1[1287:1280] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_160[5] = buffer_data_1[1295:1288] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_160[6] = buffer_data_0[1279:1272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_160[7] = buffer_data_0[1287:1280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_160[8] = buffer_data_0[1295:1288] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_160 = kernel_img_mul_160[0] + kernel_img_mul_160[1] + kernel_img_mul_160[2] + 
                kernel_img_mul_160[3] + kernel_img_mul_160[4] + kernel_img_mul_160[5] + 
                kernel_img_mul_160[6] + kernel_img_mul_160[7] + kernel_img_mul_160[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1287:1280] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1287:1280] <= kernel_img_sum_160[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1287:1280] <= 'd0;
end

wire  [25:0]  kernel_img_mul_161[0:8];
assign kernel_img_mul_161[0] = buffer_data_2[1287:1280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_161[1] = buffer_data_2[1295:1288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_161[2] = buffer_data_2[1303:1296] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_161[3] = buffer_data_1[1287:1280] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_161[4] = buffer_data_1[1295:1288] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_161[5] = buffer_data_1[1303:1296] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_161[6] = buffer_data_0[1287:1280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_161[7] = buffer_data_0[1295:1288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_161[8] = buffer_data_0[1303:1296] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_161 = kernel_img_mul_161[0] + kernel_img_mul_161[1] + kernel_img_mul_161[2] + 
                kernel_img_mul_161[3] + kernel_img_mul_161[4] + kernel_img_mul_161[5] + 
                kernel_img_mul_161[6] + kernel_img_mul_161[7] + kernel_img_mul_161[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1295:1288] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1295:1288] <= kernel_img_sum_161[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1295:1288] <= 'd0;
end

wire  [25:0]  kernel_img_mul_162[0:8];
assign kernel_img_mul_162[0] = buffer_data_2[1295:1288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_162[1] = buffer_data_2[1303:1296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_162[2] = buffer_data_2[1311:1304] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_162[3] = buffer_data_1[1295:1288] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_162[4] = buffer_data_1[1303:1296] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_162[5] = buffer_data_1[1311:1304] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_162[6] = buffer_data_0[1295:1288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_162[7] = buffer_data_0[1303:1296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_162[8] = buffer_data_0[1311:1304] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_162 = kernel_img_mul_162[0] + kernel_img_mul_162[1] + kernel_img_mul_162[2] + 
                kernel_img_mul_162[3] + kernel_img_mul_162[4] + kernel_img_mul_162[5] + 
                kernel_img_mul_162[6] + kernel_img_mul_162[7] + kernel_img_mul_162[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1303:1296] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1303:1296] <= kernel_img_sum_162[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1303:1296] <= 'd0;
end

wire  [25:0]  kernel_img_mul_163[0:8];
assign kernel_img_mul_163[0] = buffer_data_2[1303:1296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_163[1] = buffer_data_2[1311:1304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_163[2] = buffer_data_2[1319:1312] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_163[3] = buffer_data_1[1303:1296] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_163[4] = buffer_data_1[1311:1304] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_163[5] = buffer_data_1[1319:1312] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_163[6] = buffer_data_0[1303:1296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_163[7] = buffer_data_0[1311:1304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_163[8] = buffer_data_0[1319:1312] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_163 = kernel_img_mul_163[0] + kernel_img_mul_163[1] + kernel_img_mul_163[2] + 
                kernel_img_mul_163[3] + kernel_img_mul_163[4] + kernel_img_mul_163[5] + 
                kernel_img_mul_163[6] + kernel_img_mul_163[7] + kernel_img_mul_163[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1311:1304] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1311:1304] <= kernel_img_sum_163[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1311:1304] <= 'd0;
end

wire  [25:0]  kernel_img_mul_164[0:8];
assign kernel_img_mul_164[0] = buffer_data_2[1311:1304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_164[1] = buffer_data_2[1319:1312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_164[2] = buffer_data_2[1327:1320] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_164[3] = buffer_data_1[1311:1304] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_164[4] = buffer_data_1[1319:1312] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_164[5] = buffer_data_1[1327:1320] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_164[6] = buffer_data_0[1311:1304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_164[7] = buffer_data_0[1319:1312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_164[8] = buffer_data_0[1327:1320] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_164 = kernel_img_mul_164[0] + kernel_img_mul_164[1] + kernel_img_mul_164[2] + 
                kernel_img_mul_164[3] + kernel_img_mul_164[4] + kernel_img_mul_164[5] + 
                kernel_img_mul_164[6] + kernel_img_mul_164[7] + kernel_img_mul_164[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1319:1312] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1319:1312] <= kernel_img_sum_164[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1319:1312] <= 'd0;
end

wire  [25:0]  kernel_img_mul_165[0:8];
assign kernel_img_mul_165[0] = buffer_data_2[1319:1312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_165[1] = buffer_data_2[1327:1320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_165[2] = buffer_data_2[1335:1328] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_165[3] = buffer_data_1[1319:1312] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_165[4] = buffer_data_1[1327:1320] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_165[5] = buffer_data_1[1335:1328] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_165[6] = buffer_data_0[1319:1312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_165[7] = buffer_data_0[1327:1320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_165[8] = buffer_data_0[1335:1328] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_165 = kernel_img_mul_165[0] + kernel_img_mul_165[1] + kernel_img_mul_165[2] + 
                kernel_img_mul_165[3] + kernel_img_mul_165[4] + kernel_img_mul_165[5] + 
                kernel_img_mul_165[6] + kernel_img_mul_165[7] + kernel_img_mul_165[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1327:1320] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1327:1320] <= kernel_img_sum_165[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1327:1320] <= 'd0;
end

wire  [25:0]  kernel_img_mul_166[0:8];
assign kernel_img_mul_166[0] = buffer_data_2[1327:1320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_166[1] = buffer_data_2[1335:1328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_166[2] = buffer_data_2[1343:1336] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_166[3] = buffer_data_1[1327:1320] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_166[4] = buffer_data_1[1335:1328] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_166[5] = buffer_data_1[1343:1336] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_166[6] = buffer_data_0[1327:1320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_166[7] = buffer_data_0[1335:1328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_166[8] = buffer_data_0[1343:1336] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_166 = kernel_img_mul_166[0] + kernel_img_mul_166[1] + kernel_img_mul_166[2] + 
                kernel_img_mul_166[3] + kernel_img_mul_166[4] + kernel_img_mul_166[5] + 
                kernel_img_mul_166[6] + kernel_img_mul_166[7] + kernel_img_mul_166[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1335:1328] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1335:1328] <= kernel_img_sum_166[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1335:1328] <= 'd0;
end

wire  [25:0]  kernel_img_mul_167[0:8];
assign kernel_img_mul_167[0] = buffer_data_2[1335:1328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_167[1] = buffer_data_2[1343:1336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_167[2] = buffer_data_2[1351:1344] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_167[3] = buffer_data_1[1335:1328] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_167[4] = buffer_data_1[1343:1336] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_167[5] = buffer_data_1[1351:1344] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_167[6] = buffer_data_0[1335:1328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_167[7] = buffer_data_0[1343:1336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_167[8] = buffer_data_0[1351:1344] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_167 = kernel_img_mul_167[0] + kernel_img_mul_167[1] + kernel_img_mul_167[2] + 
                kernel_img_mul_167[3] + kernel_img_mul_167[4] + kernel_img_mul_167[5] + 
                kernel_img_mul_167[6] + kernel_img_mul_167[7] + kernel_img_mul_167[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1343:1336] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1343:1336] <= kernel_img_sum_167[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1343:1336] <= 'd0;
end

wire  [25:0]  kernel_img_mul_168[0:8];
assign kernel_img_mul_168[0] = buffer_data_2[1343:1336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_168[1] = buffer_data_2[1351:1344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_168[2] = buffer_data_2[1359:1352] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_168[3] = buffer_data_1[1343:1336] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_168[4] = buffer_data_1[1351:1344] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_168[5] = buffer_data_1[1359:1352] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_168[6] = buffer_data_0[1343:1336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_168[7] = buffer_data_0[1351:1344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_168[8] = buffer_data_0[1359:1352] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_168 = kernel_img_mul_168[0] + kernel_img_mul_168[1] + kernel_img_mul_168[2] + 
                kernel_img_mul_168[3] + kernel_img_mul_168[4] + kernel_img_mul_168[5] + 
                kernel_img_mul_168[6] + kernel_img_mul_168[7] + kernel_img_mul_168[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1351:1344] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1351:1344] <= kernel_img_sum_168[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1351:1344] <= 'd0;
end

wire  [25:0]  kernel_img_mul_169[0:8];
assign kernel_img_mul_169[0] = buffer_data_2[1351:1344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_169[1] = buffer_data_2[1359:1352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_169[2] = buffer_data_2[1367:1360] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_169[3] = buffer_data_1[1351:1344] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_169[4] = buffer_data_1[1359:1352] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_169[5] = buffer_data_1[1367:1360] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_169[6] = buffer_data_0[1351:1344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_169[7] = buffer_data_0[1359:1352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_169[8] = buffer_data_0[1367:1360] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_169 = kernel_img_mul_169[0] + kernel_img_mul_169[1] + kernel_img_mul_169[2] + 
                kernel_img_mul_169[3] + kernel_img_mul_169[4] + kernel_img_mul_169[5] + 
                kernel_img_mul_169[6] + kernel_img_mul_169[7] + kernel_img_mul_169[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1359:1352] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1359:1352] <= kernel_img_sum_169[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1359:1352] <= 'd0;
end

wire  [25:0]  kernel_img_mul_170[0:8];
assign kernel_img_mul_170[0] = buffer_data_2[1359:1352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_170[1] = buffer_data_2[1367:1360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_170[2] = buffer_data_2[1375:1368] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_170[3] = buffer_data_1[1359:1352] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_170[4] = buffer_data_1[1367:1360] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_170[5] = buffer_data_1[1375:1368] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_170[6] = buffer_data_0[1359:1352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_170[7] = buffer_data_0[1367:1360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_170[8] = buffer_data_0[1375:1368] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_170 = kernel_img_mul_170[0] + kernel_img_mul_170[1] + kernel_img_mul_170[2] + 
                kernel_img_mul_170[3] + kernel_img_mul_170[4] + kernel_img_mul_170[5] + 
                kernel_img_mul_170[6] + kernel_img_mul_170[7] + kernel_img_mul_170[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1367:1360] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1367:1360] <= kernel_img_sum_170[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1367:1360] <= 'd0;
end

wire  [25:0]  kernel_img_mul_171[0:8];
assign kernel_img_mul_171[0] = buffer_data_2[1367:1360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_171[1] = buffer_data_2[1375:1368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_171[2] = buffer_data_2[1383:1376] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_171[3] = buffer_data_1[1367:1360] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_171[4] = buffer_data_1[1375:1368] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_171[5] = buffer_data_1[1383:1376] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_171[6] = buffer_data_0[1367:1360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_171[7] = buffer_data_0[1375:1368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_171[8] = buffer_data_0[1383:1376] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_171 = kernel_img_mul_171[0] + kernel_img_mul_171[1] + kernel_img_mul_171[2] + 
                kernel_img_mul_171[3] + kernel_img_mul_171[4] + kernel_img_mul_171[5] + 
                kernel_img_mul_171[6] + kernel_img_mul_171[7] + kernel_img_mul_171[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1375:1368] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1375:1368] <= kernel_img_sum_171[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1375:1368] <= 'd0;
end

wire  [25:0]  kernel_img_mul_172[0:8];
assign kernel_img_mul_172[0] = buffer_data_2[1375:1368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_172[1] = buffer_data_2[1383:1376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_172[2] = buffer_data_2[1391:1384] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_172[3] = buffer_data_1[1375:1368] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_172[4] = buffer_data_1[1383:1376] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_172[5] = buffer_data_1[1391:1384] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_172[6] = buffer_data_0[1375:1368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_172[7] = buffer_data_0[1383:1376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_172[8] = buffer_data_0[1391:1384] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_172 = kernel_img_mul_172[0] + kernel_img_mul_172[1] + kernel_img_mul_172[2] + 
                kernel_img_mul_172[3] + kernel_img_mul_172[4] + kernel_img_mul_172[5] + 
                kernel_img_mul_172[6] + kernel_img_mul_172[7] + kernel_img_mul_172[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1383:1376] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1383:1376] <= kernel_img_sum_172[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1383:1376] <= 'd0;
end

wire  [25:0]  kernel_img_mul_173[0:8];
assign kernel_img_mul_173[0] = buffer_data_2[1383:1376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_173[1] = buffer_data_2[1391:1384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_173[2] = buffer_data_2[1399:1392] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_173[3] = buffer_data_1[1383:1376] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_173[4] = buffer_data_1[1391:1384] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_173[5] = buffer_data_1[1399:1392] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_173[6] = buffer_data_0[1383:1376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_173[7] = buffer_data_0[1391:1384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_173[8] = buffer_data_0[1399:1392] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_173 = kernel_img_mul_173[0] + kernel_img_mul_173[1] + kernel_img_mul_173[2] + 
                kernel_img_mul_173[3] + kernel_img_mul_173[4] + kernel_img_mul_173[5] + 
                kernel_img_mul_173[6] + kernel_img_mul_173[7] + kernel_img_mul_173[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1391:1384] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1391:1384] <= kernel_img_sum_173[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1391:1384] <= 'd0;
end

wire  [25:0]  kernel_img_mul_174[0:8];
assign kernel_img_mul_174[0] = buffer_data_2[1391:1384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_174[1] = buffer_data_2[1399:1392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_174[2] = buffer_data_2[1407:1400] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_174[3] = buffer_data_1[1391:1384] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_174[4] = buffer_data_1[1399:1392] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_174[5] = buffer_data_1[1407:1400] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_174[6] = buffer_data_0[1391:1384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_174[7] = buffer_data_0[1399:1392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_174[8] = buffer_data_0[1407:1400] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_174 = kernel_img_mul_174[0] + kernel_img_mul_174[1] + kernel_img_mul_174[2] + 
                kernel_img_mul_174[3] + kernel_img_mul_174[4] + kernel_img_mul_174[5] + 
                kernel_img_mul_174[6] + kernel_img_mul_174[7] + kernel_img_mul_174[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1399:1392] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1399:1392] <= kernel_img_sum_174[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1399:1392] <= 'd0;
end

wire  [25:0]  kernel_img_mul_175[0:8];
assign kernel_img_mul_175[0] = buffer_data_2[1399:1392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_175[1] = buffer_data_2[1407:1400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_175[2] = buffer_data_2[1415:1408] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_175[3] = buffer_data_1[1399:1392] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_175[4] = buffer_data_1[1407:1400] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_175[5] = buffer_data_1[1415:1408] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_175[6] = buffer_data_0[1399:1392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_175[7] = buffer_data_0[1407:1400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_175[8] = buffer_data_0[1415:1408] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_175 = kernel_img_mul_175[0] + kernel_img_mul_175[1] + kernel_img_mul_175[2] + 
                kernel_img_mul_175[3] + kernel_img_mul_175[4] + kernel_img_mul_175[5] + 
                kernel_img_mul_175[6] + kernel_img_mul_175[7] + kernel_img_mul_175[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1407:1400] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1407:1400] <= kernel_img_sum_175[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1407:1400] <= 'd0;
end

wire  [25:0]  kernel_img_mul_176[0:8];
assign kernel_img_mul_176[0] = buffer_data_2[1407:1400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_176[1] = buffer_data_2[1415:1408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_176[2] = buffer_data_2[1423:1416] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_176[3] = buffer_data_1[1407:1400] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_176[4] = buffer_data_1[1415:1408] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_176[5] = buffer_data_1[1423:1416] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_176[6] = buffer_data_0[1407:1400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_176[7] = buffer_data_0[1415:1408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_176[8] = buffer_data_0[1423:1416] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_176 = kernel_img_mul_176[0] + kernel_img_mul_176[1] + kernel_img_mul_176[2] + 
                kernel_img_mul_176[3] + kernel_img_mul_176[4] + kernel_img_mul_176[5] + 
                kernel_img_mul_176[6] + kernel_img_mul_176[7] + kernel_img_mul_176[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1415:1408] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1415:1408] <= kernel_img_sum_176[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1415:1408] <= 'd0;
end

wire  [25:0]  kernel_img_mul_177[0:8];
assign kernel_img_mul_177[0] = buffer_data_2[1415:1408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_177[1] = buffer_data_2[1423:1416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_177[2] = buffer_data_2[1431:1424] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_177[3] = buffer_data_1[1415:1408] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_177[4] = buffer_data_1[1423:1416] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_177[5] = buffer_data_1[1431:1424] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_177[6] = buffer_data_0[1415:1408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_177[7] = buffer_data_0[1423:1416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_177[8] = buffer_data_0[1431:1424] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_177 = kernel_img_mul_177[0] + kernel_img_mul_177[1] + kernel_img_mul_177[2] + 
                kernel_img_mul_177[3] + kernel_img_mul_177[4] + kernel_img_mul_177[5] + 
                kernel_img_mul_177[6] + kernel_img_mul_177[7] + kernel_img_mul_177[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1423:1416] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1423:1416] <= kernel_img_sum_177[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1423:1416] <= 'd0;
end

wire  [25:0]  kernel_img_mul_178[0:8];
assign kernel_img_mul_178[0] = buffer_data_2[1423:1416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_178[1] = buffer_data_2[1431:1424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_178[2] = buffer_data_2[1439:1432] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_178[3] = buffer_data_1[1423:1416] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_178[4] = buffer_data_1[1431:1424] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_178[5] = buffer_data_1[1439:1432] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_178[6] = buffer_data_0[1423:1416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_178[7] = buffer_data_0[1431:1424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_178[8] = buffer_data_0[1439:1432] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_178 = kernel_img_mul_178[0] + kernel_img_mul_178[1] + kernel_img_mul_178[2] + 
                kernel_img_mul_178[3] + kernel_img_mul_178[4] + kernel_img_mul_178[5] + 
                kernel_img_mul_178[6] + kernel_img_mul_178[7] + kernel_img_mul_178[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1431:1424] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1431:1424] <= kernel_img_sum_178[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1431:1424] <= 'd0;
end

wire  [25:0]  kernel_img_mul_179[0:8];
assign kernel_img_mul_179[0] = buffer_data_2[1431:1424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_179[1] = buffer_data_2[1439:1432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_179[2] = buffer_data_2[1447:1440] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_179[3] = buffer_data_1[1431:1424] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_179[4] = buffer_data_1[1439:1432] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_179[5] = buffer_data_1[1447:1440] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_179[6] = buffer_data_0[1431:1424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_179[7] = buffer_data_0[1439:1432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_179[8] = buffer_data_0[1447:1440] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_179 = kernel_img_mul_179[0] + kernel_img_mul_179[1] + kernel_img_mul_179[2] + 
                kernel_img_mul_179[3] + kernel_img_mul_179[4] + kernel_img_mul_179[5] + 
                kernel_img_mul_179[6] + kernel_img_mul_179[7] + kernel_img_mul_179[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1439:1432] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1439:1432] <= kernel_img_sum_179[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1439:1432] <= 'd0;
end

wire  [25:0]  kernel_img_mul_180[0:8];
assign kernel_img_mul_180[0] = buffer_data_2[1439:1432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_180[1] = buffer_data_2[1447:1440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_180[2] = buffer_data_2[1455:1448] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_180[3] = buffer_data_1[1439:1432] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_180[4] = buffer_data_1[1447:1440] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_180[5] = buffer_data_1[1455:1448] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_180[6] = buffer_data_0[1439:1432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_180[7] = buffer_data_0[1447:1440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_180[8] = buffer_data_0[1455:1448] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_180 = kernel_img_mul_180[0] + kernel_img_mul_180[1] + kernel_img_mul_180[2] + 
                kernel_img_mul_180[3] + kernel_img_mul_180[4] + kernel_img_mul_180[5] + 
                kernel_img_mul_180[6] + kernel_img_mul_180[7] + kernel_img_mul_180[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1447:1440] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1447:1440] <= kernel_img_sum_180[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1447:1440] <= 'd0;
end

wire  [25:0]  kernel_img_mul_181[0:8];
assign kernel_img_mul_181[0] = buffer_data_2[1447:1440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_181[1] = buffer_data_2[1455:1448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_181[2] = buffer_data_2[1463:1456] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_181[3] = buffer_data_1[1447:1440] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_181[4] = buffer_data_1[1455:1448] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_181[5] = buffer_data_1[1463:1456] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_181[6] = buffer_data_0[1447:1440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_181[7] = buffer_data_0[1455:1448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_181[8] = buffer_data_0[1463:1456] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_181 = kernel_img_mul_181[0] + kernel_img_mul_181[1] + kernel_img_mul_181[2] + 
                kernel_img_mul_181[3] + kernel_img_mul_181[4] + kernel_img_mul_181[5] + 
                kernel_img_mul_181[6] + kernel_img_mul_181[7] + kernel_img_mul_181[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1455:1448] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1455:1448] <= kernel_img_sum_181[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1455:1448] <= 'd0;
end

wire  [25:0]  kernel_img_mul_182[0:8];
assign kernel_img_mul_182[0] = buffer_data_2[1455:1448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_182[1] = buffer_data_2[1463:1456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_182[2] = buffer_data_2[1471:1464] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_182[3] = buffer_data_1[1455:1448] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_182[4] = buffer_data_1[1463:1456] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_182[5] = buffer_data_1[1471:1464] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_182[6] = buffer_data_0[1455:1448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_182[7] = buffer_data_0[1463:1456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_182[8] = buffer_data_0[1471:1464] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_182 = kernel_img_mul_182[0] + kernel_img_mul_182[1] + kernel_img_mul_182[2] + 
                kernel_img_mul_182[3] + kernel_img_mul_182[4] + kernel_img_mul_182[5] + 
                kernel_img_mul_182[6] + kernel_img_mul_182[7] + kernel_img_mul_182[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1463:1456] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1463:1456] <= kernel_img_sum_182[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1463:1456] <= 'd0;
end

wire  [25:0]  kernel_img_mul_183[0:8];
assign kernel_img_mul_183[0] = buffer_data_2[1463:1456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_183[1] = buffer_data_2[1471:1464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_183[2] = buffer_data_2[1479:1472] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_183[3] = buffer_data_1[1463:1456] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_183[4] = buffer_data_1[1471:1464] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_183[5] = buffer_data_1[1479:1472] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_183[6] = buffer_data_0[1463:1456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_183[7] = buffer_data_0[1471:1464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_183[8] = buffer_data_0[1479:1472] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_183 = kernel_img_mul_183[0] + kernel_img_mul_183[1] + kernel_img_mul_183[2] + 
                kernel_img_mul_183[3] + kernel_img_mul_183[4] + kernel_img_mul_183[5] + 
                kernel_img_mul_183[6] + kernel_img_mul_183[7] + kernel_img_mul_183[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1471:1464] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1471:1464] <= kernel_img_sum_183[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1471:1464] <= 'd0;
end

wire  [25:0]  kernel_img_mul_184[0:8];
assign kernel_img_mul_184[0] = buffer_data_2[1471:1464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_184[1] = buffer_data_2[1479:1472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_184[2] = buffer_data_2[1487:1480] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_184[3] = buffer_data_1[1471:1464] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_184[4] = buffer_data_1[1479:1472] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_184[5] = buffer_data_1[1487:1480] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_184[6] = buffer_data_0[1471:1464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_184[7] = buffer_data_0[1479:1472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_184[8] = buffer_data_0[1487:1480] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_184 = kernel_img_mul_184[0] + kernel_img_mul_184[1] + kernel_img_mul_184[2] + 
                kernel_img_mul_184[3] + kernel_img_mul_184[4] + kernel_img_mul_184[5] + 
                kernel_img_mul_184[6] + kernel_img_mul_184[7] + kernel_img_mul_184[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1479:1472] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1479:1472] <= kernel_img_sum_184[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1479:1472] <= 'd0;
end

wire  [25:0]  kernel_img_mul_185[0:8];
assign kernel_img_mul_185[0] = buffer_data_2[1479:1472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_185[1] = buffer_data_2[1487:1480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_185[2] = buffer_data_2[1495:1488] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_185[3] = buffer_data_1[1479:1472] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_185[4] = buffer_data_1[1487:1480] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_185[5] = buffer_data_1[1495:1488] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_185[6] = buffer_data_0[1479:1472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_185[7] = buffer_data_0[1487:1480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_185[8] = buffer_data_0[1495:1488] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_185 = kernel_img_mul_185[0] + kernel_img_mul_185[1] + kernel_img_mul_185[2] + 
                kernel_img_mul_185[3] + kernel_img_mul_185[4] + kernel_img_mul_185[5] + 
                kernel_img_mul_185[6] + kernel_img_mul_185[7] + kernel_img_mul_185[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1487:1480] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1487:1480] <= kernel_img_sum_185[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1487:1480] <= 'd0;
end

wire  [25:0]  kernel_img_mul_186[0:8];
assign kernel_img_mul_186[0] = buffer_data_2[1487:1480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_186[1] = buffer_data_2[1495:1488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_186[2] = buffer_data_2[1503:1496] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_186[3] = buffer_data_1[1487:1480] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_186[4] = buffer_data_1[1495:1488] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_186[5] = buffer_data_1[1503:1496] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_186[6] = buffer_data_0[1487:1480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_186[7] = buffer_data_0[1495:1488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_186[8] = buffer_data_0[1503:1496] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_186 = kernel_img_mul_186[0] + kernel_img_mul_186[1] + kernel_img_mul_186[2] + 
                kernel_img_mul_186[3] + kernel_img_mul_186[4] + kernel_img_mul_186[5] + 
                kernel_img_mul_186[6] + kernel_img_mul_186[7] + kernel_img_mul_186[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1495:1488] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1495:1488] <= kernel_img_sum_186[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1495:1488] <= 'd0;
end

wire  [25:0]  kernel_img_mul_187[0:8];
assign kernel_img_mul_187[0] = buffer_data_2[1495:1488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_187[1] = buffer_data_2[1503:1496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_187[2] = buffer_data_2[1511:1504] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_187[3] = buffer_data_1[1495:1488] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_187[4] = buffer_data_1[1503:1496] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_187[5] = buffer_data_1[1511:1504] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_187[6] = buffer_data_0[1495:1488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_187[7] = buffer_data_0[1503:1496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_187[8] = buffer_data_0[1511:1504] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_187 = kernel_img_mul_187[0] + kernel_img_mul_187[1] + kernel_img_mul_187[2] + 
                kernel_img_mul_187[3] + kernel_img_mul_187[4] + kernel_img_mul_187[5] + 
                kernel_img_mul_187[6] + kernel_img_mul_187[7] + kernel_img_mul_187[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1503:1496] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1503:1496] <= kernel_img_sum_187[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1503:1496] <= 'd0;
end

wire  [25:0]  kernel_img_mul_188[0:8];
assign kernel_img_mul_188[0] = buffer_data_2[1503:1496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_188[1] = buffer_data_2[1511:1504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_188[2] = buffer_data_2[1519:1512] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_188[3] = buffer_data_1[1503:1496] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_188[4] = buffer_data_1[1511:1504] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_188[5] = buffer_data_1[1519:1512] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_188[6] = buffer_data_0[1503:1496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_188[7] = buffer_data_0[1511:1504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_188[8] = buffer_data_0[1519:1512] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_188 = kernel_img_mul_188[0] + kernel_img_mul_188[1] + kernel_img_mul_188[2] + 
                kernel_img_mul_188[3] + kernel_img_mul_188[4] + kernel_img_mul_188[5] + 
                kernel_img_mul_188[6] + kernel_img_mul_188[7] + kernel_img_mul_188[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1511:1504] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1511:1504] <= kernel_img_sum_188[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1511:1504] <= 'd0;
end

wire  [25:0]  kernel_img_mul_189[0:8];
assign kernel_img_mul_189[0] = buffer_data_2[1511:1504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_189[1] = buffer_data_2[1519:1512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_189[2] = buffer_data_2[1527:1520] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_189[3] = buffer_data_1[1511:1504] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_189[4] = buffer_data_1[1519:1512] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_189[5] = buffer_data_1[1527:1520] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_189[6] = buffer_data_0[1511:1504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_189[7] = buffer_data_0[1519:1512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_189[8] = buffer_data_0[1527:1520] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_189 = kernel_img_mul_189[0] + kernel_img_mul_189[1] + kernel_img_mul_189[2] + 
                kernel_img_mul_189[3] + kernel_img_mul_189[4] + kernel_img_mul_189[5] + 
                kernel_img_mul_189[6] + kernel_img_mul_189[7] + kernel_img_mul_189[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1519:1512] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1519:1512] <= kernel_img_sum_189[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1519:1512] <= 'd0;
end

wire  [25:0]  kernel_img_mul_190[0:8];
assign kernel_img_mul_190[0] = buffer_data_2[1519:1512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_190[1] = buffer_data_2[1527:1520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_190[2] = buffer_data_2[1535:1528] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_190[3] = buffer_data_1[1519:1512] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_190[4] = buffer_data_1[1527:1520] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_190[5] = buffer_data_1[1535:1528] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_190[6] = buffer_data_0[1519:1512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_190[7] = buffer_data_0[1527:1520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_190[8] = buffer_data_0[1535:1528] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_190 = kernel_img_mul_190[0] + kernel_img_mul_190[1] + kernel_img_mul_190[2] + 
                kernel_img_mul_190[3] + kernel_img_mul_190[4] + kernel_img_mul_190[5] + 
                kernel_img_mul_190[6] + kernel_img_mul_190[7] + kernel_img_mul_190[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1527:1520] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1527:1520] <= kernel_img_sum_190[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1527:1520] <= 'd0;
end

wire  [25:0]  kernel_img_mul_191[0:8];
assign kernel_img_mul_191[0] = buffer_data_2[1527:1520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_191[1] = buffer_data_2[1535:1528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_191[2] = buffer_data_2[1543:1536] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_191[3] = buffer_data_1[1527:1520] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_191[4] = buffer_data_1[1535:1528] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_191[5] = buffer_data_1[1543:1536] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_191[6] = buffer_data_0[1527:1520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_191[7] = buffer_data_0[1535:1528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_191[8] = buffer_data_0[1543:1536] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_191 = kernel_img_mul_191[0] + kernel_img_mul_191[1] + kernel_img_mul_191[2] + 
                kernel_img_mul_191[3] + kernel_img_mul_191[4] + kernel_img_mul_191[5] + 
                kernel_img_mul_191[6] + kernel_img_mul_191[7] + kernel_img_mul_191[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1535:1528] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1535:1528] <= kernel_img_sum_191[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1535:1528] <= 'd0;
end

wire  [25:0]  kernel_img_mul_192[0:8];
assign kernel_img_mul_192[0] = buffer_data_2[1535:1528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_192[1] = buffer_data_2[1543:1536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_192[2] = buffer_data_2[1551:1544] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_192[3] = buffer_data_1[1535:1528] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_192[4] = buffer_data_1[1543:1536] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_192[5] = buffer_data_1[1551:1544] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_192[6] = buffer_data_0[1535:1528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_192[7] = buffer_data_0[1543:1536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_192[8] = buffer_data_0[1551:1544] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_192 = kernel_img_mul_192[0] + kernel_img_mul_192[1] + kernel_img_mul_192[2] + 
                kernel_img_mul_192[3] + kernel_img_mul_192[4] + kernel_img_mul_192[5] + 
                kernel_img_mul_192[6] + kernel_img_mul_192[7] + kernel_img_mul_192[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1543:1536] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1543:1536] <= kernel_img_sum_192[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1543:1536] <= 'd0;
end

wire  [25:0]  kernel_img_mul_193[0:8];
assign kernel_img_mul_193[0] = buffer_data_2[1543:1536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_193[1] = buffer_data_2[1551:1544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_193[2] = buffer_data_2[1559:1552] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_193[3] = buffer_data_1[1543:1536] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_193[4] = buffer_data_1[1551:1544] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_193[5] = buffer_data_1[1559:1552] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_193[6] = buffer_data_0[1543:1536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_193[7] = buffer_data_0[1551:1544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_193[8] = buffer_data_0[1559:1552] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_193 = kernel_img_mul_193[0] + kernel_img_mul_193[1] + kernel_img_mul_193[2] + 
                kernel_img_mul_193[3] + kernel_img_mul_193[4] + kernel_img_mul_193[5] + 
                kernel_img_mul_193[6] + kernel_img_mul_193[7] + kernel_img_mul_193[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1551:1544] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1551:1544] <= kernel_img_sum_193[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1551:1544] <= 'd0;
end

wire  [25:0]  kernel_img_mul_194[0:8];
assign kernel_img_mul_194[0] = buffer_data_2[1551:1544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_194[1] = buffer_data_2[1559:1552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_194[2] = buffer_data_2[1567:1560] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_194[3] = buffer_data_1[1551:1544] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_194[4] = buffer_data_1[1559:1552] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_194[5] = buffer_data_1[1567:1560] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_194[6] = buffer_data_0[1551:1544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_194[7] = buffer_data_0[1559:1552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_194[8] = buffer_data_0[1567:1560] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_194 = kernel_img_mul_194[0] + kernel_img_mul_194[1] + kernel_img_mul_194[2] + 
                kernel_img_mul_194[3] + kernel_img_mul_194[4] + kernel_img_mul_194[5] + 
                kernel_img_mul_194[6] + kernel_img_mul_194[7] + kernel_img_mul_194[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1559:1552] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1559:1552] <= kernel_img_sum_194[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1559:1552] <= 'd0;
end

wire  [25:0]  kernel_img_mul_195[0:8];
assign kernel_img_mul_195[0] = buffer_data_2[1559:1552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_195[1] = buffer_data_2[1567:1560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_195[2] = buffer_data_2[1575:1568] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_195[3] = buffer_data_1[1559:1552] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_195[4] = buffer_data_1[1567:1560] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_195[5] = buffer_data_1[1575:1568] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_195[6] = buffer_data_0[1559:1552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_195[7] = buffer_data_0[1567:1560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_195[8] = buffer_data_0[1575:1568] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_195 = kernel_img_mul_195[0] + kernel_img_mul_195[1] + kernel_img_mul_195[2] + 
                kernel_img_mul_195[3] + kernel_img_mul_195[4] + kernel_img_mul_195[5] + 
                kernel_img_mul_195[6] + kernel_img_mul_195[7] + kernel_img_mul_195[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1567:1560] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1567:1560] <= kernel_img_sum_195[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1567:1560] <= 'd0;
end

wire  [25:0]  kernel_img_mul_196[0:8];
assign kernel_img_mul_196[0] = buffer_data_2[1567:1560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_196[1] = buffer_data_2[1575:1568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_196[2] = buffer_data_2[1583:1576] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_196[3] = buffer_data_1[1567:1560] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_196[4] = buffer_data_1[1575:1568] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_196[5] = buffer_data_1[1583:1576] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_196[6] = buffer_data_0[1567:1560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_196[7] = buffer_data_0[1575:1568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_196[8] = buffer_data_0[1583:1576] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_196 = kernel_img_mul_196[0] + kernel_img_mul_196[1] + kernel_img_mul_196[2] + 
                kernel_img_mul_196[3] + kernel_img_mul_196[4] + kernel_img_mul_196[5] + 
                kernel_img_mul_196[6] + kernel_img_mul_196[7] + kernel_img_mul_196[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1575:1568] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1575:1568] <= kernel_img_sum_196[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1575:1568] <= 'd0;
end

wire  [25:0]  kernel_img_mul_197[0:8];
assign kernel_img_mul_197[0] = buffer_data_2[1575:1568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_197[1] = buffer_data_2[1583:1576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_197[2] = buffer_data_2[1591:1584] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_197[3] = buffer_data_1[1575:1568] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_197[4] = buffer_data_1[1583:1576] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_197[5] = buffer_data_1[1591:1584] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_197[6] = buffer_data_0[1575:1568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_197[7] = buffer_data_0[1583:1576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_197[8] = buffer_data_0[1591:1584] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_197 = kernel_img_mul_197[0] + kernel_img_mul_197[1] + kernel_img_mul_197[2] + 
                kernel_img_mul_197[3] + kernel_img_mul_197[4] + kernel_img_mul_197[5] + 
                kernel_img_mul_197[6] + kernel_img_mul_197[7] + kernel_img_mul_197[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1583:1576] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1583:1576] <= kernel_img_sum_197[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1583:1576] <= 'd0;
end

wire  [25:0]  kernel_img_mul_198[0:8];
assign kernel_img_mul_198[0] = buffer_data_2[1583:1576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_198[1] = buffer_data_2[1591:1584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_198[2] = buffer_data_2[1599:1592] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_198[3] = buffer_data_1[1583:1576] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_198[4] = buffer_data_1[1591:1584] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_198[5] = buffer_data_1[1599:1592] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_198[6] = buffer_data_0[1583:1576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_198[7] = buffer_data_0[1591:1584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_198[8] = buffer_data_0[1599:1592] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_198 = kernel_img_mul_198[0] + kernel_img_mul_198[1] + kernel_img_mul_198[2] + 
                kernel_img_mul_198[3] + kernel_img_mul_198[4] + kernel_img_mul_198[5] + 
                kernel_img_mul_198[6] + kernel_img_mul_198[7] + kernel_img_mul_198[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1591:1584] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1591:1584] <= kernel_img_sum_198[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1591:1584] <= 'd0;
end

wire  [25:0]  kernel_img_mul_199[0:8];
assign kernel_img_mul_199[0] = buffer_data_2[1591:1584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_199[1] = buffer_data_2[1599:1592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_199[2] = buffer_data_2[1607:1600] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_199[3] = buffer_data_1[1591:1584] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_199[4] = buffer_data_1[1599:1592] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_199[5] = buffer_data_1[1607:1600] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_199[6] = buffer_data_0[1591:1584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_199[7] = buffer_data_0[1599:1592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_199[8] = buffer_data_0[1607:1600] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_199 = kernel_img_mul_199[0] + kernel_img_mul_199[1] + kernel_img_mul_199[2] + 
                kernel_img_mul_199[3] + kernel_img_mul_199[4] + kernel_img_mul_199[5] + 
                kernel_img_mul_199[6] + kernel_img_mul_199[7] + kernel_img_mul_199[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1599:1592] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1599:1592] <= kernel_img_sum_199[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1599:1592] <= 'd0;
end

wire  [25:0]  kernel_img_mul_200[0:8];
assign kernel_img_mul_200[0] = buffer_data_2[1599:1592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_200[1] = buffer_data_2[1607:1600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_200[2] = buffer_data_2[1615:1608] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_200[3] = buffer_data_1[1599:1592] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_200[4] = buffer_data_1[1607:1600] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_200[5] = buffer_data_1[1615:1608] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_200[6] = buffer_data_0[1599:1592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_200[7] = buffer_data_0[1607:1600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_200[8] = buffer_data_0[1615:1608] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_200 = kernel_img_mul_200[0] + kernel_img_mul_200[1] + kernel_img_mul_200[2] + 
                kernel_img_mul_200[3] + kernel_img_mul_200[4] + kernel_img_mul_200[5] + 
                kernel_img_mul_200[6] + kernel_img_mul_200[7] + kernel_img_mul_200[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1607:1600] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1607:1600] <= kernel_img_sum_200[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1607:1600] <= 'd0;
end

wire  [25:0]  kernel_img_mul_201[0:8];
assign kernel_img_mul_201[0] = buffer_data_2[1607:1600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_201[1] = buffer_data_2[1615:1608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_201[2] = buffer_data_2[1623:1616] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_201[3] = buffer_data_1[1607:1600] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_201[4] = buffer_data_1[1615:1608] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_201[5] = buffer_data_1[1623:1616] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_201[6] = buffer_data_0[1607:1600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_201[7] = buffer_data_0[1615:1608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_201[8] = buffer_data_0[1623:1616] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_201 = kernel_img_mul_201[0] + kernel_img_mul_201[1] + kernel_img_mul_201[2] + 
                kernel_img_mul_201[3] + kernel_img_mul_201[4] + kernel_img_mul_201[5] + 
                kernel_img_mul_201[6] + kernel_img_mul_201[7] + kernel_img_mul_201[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1615:1608] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1615:1608] <= kernel_img_sum_201[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1615:1608] <= 'd0;
end

wire  [25:0]  kernel_img_mul_202[0:8];
assign kernel_img_mul_202[0] = buffer_data_2[1615:1608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_202[1] = buffer_data_2[1623:1616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_202[2] = buffer_data_2[1631:1624] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_202[3] = buffer_data_1[1615:1608] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_202[4] = buffer_data_1[1623:1616] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_202[5] = buffer_data_1[1631:1624] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_202[6] = buffer_data_0[1615:1608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_202[7] = buffer_data_0[1623:1616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_202[8] = buffer_data_0[1631:1624] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_202 = kernel_img_mul_202[0] + kernel_img_mul_202[1] + kernel_img_mul_202[2] + 
                kernel_img_mul_202[3] + kernel_img_mul_202[4] + kernel_img_mul_202[5] + 
                kernel_img_mul_202[6] + kernel_img_mul_202[7] + kernel_img_mul_202[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1623:1616] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1623:1616] <= kernel_img_sum_202[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1623:1616] <= 'd0;
end

wire  [25:0]  kernel_img_mul_203[0:8];
assign kernel_img_mul_203[0] = buffer_data_2[1623:1616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_203[1] = buffer_data_2[1631:1624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_203[2] = buffer_data_2[1639:1632] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_203[3] = buffer_data_1[1623:1616] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_203[4] = buffer_data_1[1631:1624] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_203[5] = buffer_data_1[1639:1632] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_203[6] = buffer_data_0[1623:1616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_203[7] = buffer_data_0[1631:1624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_203[8] = buffer_data_0[1639:1632] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_203 = kernel_img_mul_203[0] + kernel_img_mul_203[1] + kernel_img_mul_203[2] + 
                kernel_img_mul_203[3] + kernel_img_mul_203[4] + kernel_img_mul_203[5] + 
                kernel_img_mul_203[6] + kernel_img_mul_203[7] + kernel_img_mul_203[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1631:1624] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1631:1624] <= kernel_img_sum_203[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1631:1624] <= 'd0;
end

wire  [25:0]  kernel_img_mul_204[0:8];
assign kernel_img_mul_204[0] = buffer_data_2[1631:1624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_204[1] = buffer_data_2[1639:1632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_204[2] = buffer_data_2[1647:1640] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_204[3] = buffer_data_1[1631:1624] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_204[4] = buffer_data_1[1639:1632] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_204[5] = buffer_data_1[1647:1640] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_204[6] = buffer_data_0[1631:1624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_204[7] = buffer_data_0[1639:1632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_204[8] = buffer_data_0[1647:1640] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_204 = kernel_img_mul_204[0] + kernel_img_mul_204[1] + kernel_img_mul_204[2] + 
                kernel_img_mul_204[3] + kernel_img_mul_204[4] + kernel_img_mul_204[5] + 
                kernel_img_mul_204[6] + kernel_img_mul_204[7] + kernel_img_mul_204[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1639:1632] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1639:1632] <= kernel_img_sum_204[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1639:1632] <= 'd0;
end

wire  [25:0]  kernel_img_mul_205[0:8];
assign kernel_img_mul_205[0] = buffer_data_2[1639:1632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_205[1] = buffer_data_2[1647:1640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_205[2] = buffer_data_2[1655:1648] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_205[3] = buffer_data_1[1639:1632] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_205[4] = buffer_data_1[1647:1640] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_205[5] = buffer_data_1[1655:1648] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_205[6] = buffer_data_0[1639:1632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_205[7] = buffer_data_0[1647:1640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_205[8] = buffer_data_0[1655:1648] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_205 = kernel_img_mul_205[0] + kernel_img_mul_205[1] + kernel_img_mul_205[2] + 
                kernel_img_mul_205[3] + kernel_img_mul_205[4] + kernel_img_mul_205[5] + 
                kernel_img_mul_205[6] + kernel_img_mul_205[7] + kernel_img_mul_205[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1647:1640] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1647:1640] <= kernel_img_sum_205[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1647:1640] <= 'd0;
end

wire  [25:0]  kernel_img_mul_206[0:8];
assign kernel_img_mul_206[0] = buffer_data_2[1647:1640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_206[1] = buffer_data_2[1655:1648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_206[2] = buffer_data_2[1663:1656] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_206[3] = buffer_data_1[1647:1640] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_206[4] = buffer_data_1[1655:1648] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_206[5] = buffer_data_1[1663:1656] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_206[6] = buffer_data_0[1647:1640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_206[7] = buffer_data_0[1655:1648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_206[8] = buffer_data_0[1663:1656] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_206 = kernel_img_mul_206[0] + kernel_img_mul_206[1] + kernel_img_mul_206[2] + 
                kernel_img_mul_206[3] + kernel_img_mul_206[4] + kernel_img_mul_206[5] + 
                kernel_img_mul_206[6] + kernel_img_mul_206[7] + kernel_img_mul_206[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1655:1648] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1655:1648] <= kernel_img_sum_206[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1655:1648] <= 'd0;
end

wire  [25:0]  kernel_img_mul_207[0:8];
assign kernel_img_mul_207[0] = buffer_data_2[1655:1648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_207[1] = buffer_data_2[1663:1656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_207[2] = buffer_data_2[1671:1664] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_207[3] = buffer_data_1[1655:1648] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_207[4] = buffer_data_1[1663:1656] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_207[5] = buffer_data_1[1671:1664] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_207[6] = buffer_data_0[1655:1648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_207[7] = buffer_data_0[1663:1656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_207[8] = buffer_data_0[1671:1664] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_207 = kernel_img_mul_207[0] + kernel_img_mul_207[1] + kernel_img_mul_207[2] + 
                kernel_img_mul_207[3] + kernel_img_mul_207[4] + kernel_img_mul_207[5] + 
                kernel_img_mul_207[6] + kernel_img_mul_207[7] + kernel_img_mul_207[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1663:1656] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1663:1656] <= kernel_img_sum_207[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1663:1656] <= 'd0;
end

wire  [25:0]  kernel_img_mul_208[0:8];
assign kernel_img_mul_208[0] = buffer_data_2[1663:1656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_208[1] = buffer_data_2[1671:1664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_208[2] = buffer_data_2[1679:1672] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_208[3] = buffer_data_1[1663:1656] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_208[4] = buffer_data_1[1671:1664] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_208[5] = buffer_data_1[1679:1672] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_208[6] = buffer_data_0[1663:1656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_208[7] = buffer_data_0[1671:1664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_208[8] = buffer_data_0[1679:1672] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_208 = kernel_img_mul_208[0] + kernel_img_mul_208[1] + kernel_img_mul_208[2] + 
                kernel_img_mul_208[3] + kernel_img_mul_208[4] + kernel_img_mul_208[5] + 
                kernel_img_mul_208[6] + kernel_img_mul_208[7] + kernel_img_mul_208[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1671:1664] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1671:1664] <= kernel_img_sum_208[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1671:1664] <= 'd0;
end

wire  [25:0]  kernel_img_mul_209[0:8];
assign kernel_img_mul_209[0] = buffer_data_2[1671:1664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_209[1] = buffer_data_2[1679:1672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_209[2] = buffer_data_2[1687:1680] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_209[3] = buffer_data_1[1671:1664] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_209[4] = buffer_data_1[1679:1672] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_209[5] = buffer_data_1[1687:1680] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_209[6] = buffer_data_0[1671:1664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_209[7] = buffer_data_0[1679:1672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_209[8] = buffer_data_0[1687:1680] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_209 = kernel_img_mul_209[0] + kernel_img_mul_209[1] + kernel_img_mul_209[2] + 
                kernel_img_mul_209[3] + kernel_img_mul_209[4] + kernel_img_mul_209[5] + 
                kernel_img_mul_209[6] + kernel_img_mul_209[7] + kernel_img_mul_209[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1679:1672] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1679:1672] <= kernel_img_sum_209[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1679:1672] <= 'd0;
end

wire  [25:0]  kernel_img_mul_210[0:8];
assign kernel_img_mul_210[0] = buffer_data_2[1679:1672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_210[1] = buffer_data_2[1687:1680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_210[2] = buffer_data_2[1695:1688] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_210[3] = buffer_data_1[1679:1672] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_210[4] = buffer_data_1[1687:1680] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_210[5] = buffer_data_1[1695:1688] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_210[6] = buffer_data_0[1679:1672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_210[7] = buffer_data_0[1687:1680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_210[8] = buffer_data_0[1695:1688] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_210 = kernel_img_mul_210[0] + kernel_img_mul_210[1] + kernel_img_mul_210[2] + 
                kernel_img_mul_210[3] + kernel_img_mul_210[4] + kernel_img_mul_210[5] + 
                kernel_img_mul_210[6] + kernel_img_mul_210[7] + kernel_img_mul_210[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1687:1680] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1687:1680] <= kernel_img_sum_210[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1687:1680] <= 'd0;
end

wire  [25:0]  kernel_img_mul_211[0:8];
assign kernel_img_mul_211[0] = buffer_data_2[1687:1680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_211[1] = buffer_data_2[1695:1688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_211[2] = buffer_data_2[1703:1696] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_211[3] = buffer_data_1[1687:1680] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_211[4] = buffer_data_1[1695:1688] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_211[5] = buffer_data_1[1703:1696] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_211[6] = buffer_data_0[1687:1680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_211[7] = buffer_data_0[1695:1688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_211[8] = buffer_data_0[1703:1696] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_211 = kernel_img_mul_211[0] + kernel_img_mul_211[1] + kernel_img_mul_211[2] + 
                kernel_img_mul_211[3] + kernel_img_mul_211[4] + kernel_img_mul_211[5] + 
                kernel_img_mul_211[6] + kernel_img_mul_211[7] + kernel_img_mul_211[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1695:1688] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1695:1688] <= kernel_img_sum_211[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1695:1688] <= 'd0;
end

wire  [25:0]  kernel_img_mul_212[0:8];
assign kernel_img_mul_212[0] = buffer_data_2[1695:1688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_212[1] = buffer_data_2[1703:1696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_212[2] = buffer_data_2[1711:1704] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_212[3] = buffer_data_1[1695:1688] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_212[4] = buffer_data_1[1703:1696] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_212[5] = buffer_data_1[1711:1704] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_212[6] = buffer_data_0[1695:1688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_212[7] = buffer_data_0[1703:1696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_212[8] = buffer_data_0[1711:1704] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_212 = kernel_img_mul_212[0] + kernel_img_mul_212[1] + kernel_img_mul_212[2] + 
                kernel_img_mul_212[3] + kernel_img_mul_212[4] + kernel_img_mul_212[5] + 
                kernel_img_mul_212[6] + kernel_img_mul_212[7] + kernel_img_mul_212[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1703:1696] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1703:1696] <= kernel_img_sum_212[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1703:1696] <= 'd0;
end

wire  [25:0]  kernel_img_mul_213[0:8];
assign kernel_img_mul_213[0] = buffer_data_2[1703:1696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_213[1] = buffer_data_2[1711:1704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_213[2] = buffer_data_2[1719:1712] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_213[3] = buffer_data_1[1703:1696] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_213[4] = buffer_data_1[1711:1704] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_213[5] = buffer_data_1[1719:1712] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_213[6] = buffer_data_0[1703:1696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_213[7] = buffer_data_0[1711:1704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_213[8] = buffer_data_0[1719:1712] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_213 = kernel_img_mul_213[0] + kernel_img_mul_213[1] + kernel_img_mul_213[2] + 
                kernel_img_mul_213[3] + kernel_img_mul_213[4] + kernel_img_mul_213[5] + 
                kernel_img_mul_213[6] + kernel_img_mul_213[7] + kernel_img_mul_213[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1711:1704] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1711:1704] <= kernel_img_sum_213[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1711:1704] <= 'd0;
end

wire  [25:0]  kernel_img_mul_214[0:8];
assign kernel_img_mul_214[0] = buffer_data_2[1711:1704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_214[1] = buffer_data_2[1719:1712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_214[2] = buffer_data_2[1727:1720] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_214[3] = buffer_data_1[1711:1704] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_214[4] = buffer_data_1[1719:1712] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_214[5] = buffer_data_1[1727:1720] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_214[6] = buffer_data_0[1711:1704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_214[7] = buffer_data_0[1719:1712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_214[8] = buffer_data_0[1727:1720] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_214 = kernel_img_mul_214[0] + kernel_img_mul_214[1] + kernel_img_mul_214[2] + 
                kernel_img_mul_214[3] + kernel_img_mul_214[4] + kernel_img_mul_214[5] + 
                kernel_img_mul_214[6] + kernel_img_mul_214[7] + kernel_img_mul_214[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1719:1712] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1719:1712] <= kernel_img_sum_214[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1719:1712] <= 'd0;
end

wire  [25:0]  kernel_img_mul_215[0:8];
assign kernel_img_mul_215[0] = buffer_data_2[1719:1712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_215[1] = buffer_data_2[1727:1720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_215[2] = buffer_data_2[1735:1728] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_215[3] = buffer_data_1[1719:1712] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_215[4] = buffer_data_1[1727:1720] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_215[5] = buffer_data_1[1735:1728] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_215[6] = buffer_data_0[1719:1712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_215[7] = buffer_data_0[1727:1720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_215[8] = buffer_data_0[1735:1728] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_215 = kernel_img_mul_215[0] + kernel_img_mul_215[1] + kernel_img_mul_215[2] + 
                kernel_img_mul_215[3] + kernel_img_mul_215[4] + kernel_img_mul_215[5] + 
                kernel_img_mul_215[6] + kernel_img_mul_215[7] + kernel_img_mul_215[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1727:1720] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1727:1720] <= kernel_img_sum_215[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1727:1720] <= 'd0;
end

wire  [25:0]  kernel_img_mul_216[0:8];
assign kernel_img_mul_216[0] = buffer_data_2[1727:1720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_216[1] = buffer_data_2[1735:1728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_216[2] = buffer_data_2[1743:1736] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_216[3] = buffer_data_1[1727:1720] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_216[4] = buffer_data_1[1735:1728] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_216[5] = buffer_data_1[1743:1736] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_216[6] = buffer_data_0[1727:1720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_216[7] = buffer_data_0[1735:1728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_216[8] = buffer_data_0[1743:1736] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_216 = kernel_img_mul_216[0] + kernel_img_mul_216[1] + kernel_img_mul_216[2] + 
                kernel_img_mul_216[3] + kernel_img_mul_216[4] + kernel_img_mul_216[5] + 
                kernel_img_mul_216[6] + kernel_img_mul_216[7] + kernel_img_mul_216[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1735:1728] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1735:1728] <= kernel_img_sum_216[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1735:1728] <= 'd0;
end

wire  [25:0]  kernel_img_mul_217[0:8];
assign kernel_img_mul_217[0] = buffer_data_2[1735:1728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_217[1] = buffer_data_2[1743:1736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_217[2] = buffer_data_2[1751:1744] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_217[3] = buffer_data_1[1735:1728] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_217[4] = buffer_data_1[1743:1736] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_217[5] = buffer_data_1[1751:1744] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_217[6] = buffer_data_0[1735:1728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_217[7] = buffer_data_0[1743:1736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_217[8] = buffer_data_0[1751:1744] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_217 = kernel_img_mul_217[0] + kernel_img_mul_217[1] + kernel_img_mul_217[2] + 
                kernel_img_mul_217[3] + kernel_img_mul_217[4] + kernel_img_mul_217[5] + 
                kernel_img_mul_217[6] + kernel_img_mul_217[7] + kernel_img_mul_217[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1743:1736] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1743:1736] <= kernel_img_sum_217[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1743:1736] <= 'd0;
end

wire  [25:0]  kernel_img_mul_218[0:8];
assign kernel_img_mul_218[0] = buffer_data_2[1743:1736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_218[1] = buffer_data_2[1751:1744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_218[2] = buffer_data_2[1759:1752] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_218[3] = buffer_data_1[1743:1736] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_218[4] = buffer_data_1[1751:1744] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_218[5] = buffer_data_1[1759:1752] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_218[6] = buffer_data_0[1743:1736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_218[7] = buffer_data_0[1751:1744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_218[8] = buffer_data_0[1759:1752] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_218 = kernel_img_mul_218[0] + kernel_img_mul_218[1] + kernel_img_mul_218[2] + 
                kernel_img_mul_218[3] + kernel_img_mul_218[4] + kernel_img_mul_218[5] + 
                kernel_img_mul_218[6] + kernel_img_mul_218[7] + kernel_img_mul_218[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1751:1744] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1751:1744] <= kernel_img_sum_218[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1751:1744] <= 'd0;
end

wire  [25:0]  kernel_img_mul_219[0:8];
assign kernel_img_mul_219[0] = buffer_data_2[1751:1744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_219[1] = buffer_data_2[1759:1752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_219[2] = buffer_data_2[1767:1760] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_219[3] = buffer_data_1[1751:1744] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_219[4] = buffer_data_1[1759:1752] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_219[5] = buffer_data_1[1767:1760] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_219[6] = buffer_data_0[1751:1744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_219[7] = buffer_data_0[1759:1752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_219[8] = buffer_data_0[1767:1760] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_219 = kernel_img_mul_219[0] + kernel_img_mul_219[1] + kernel_img_mul_219[2] + 
                kernel_img_mul_219[3] + kernel_img_mul_219[4] + kernel_img_mul_219[5] + 
                kernel_img_mul_219[6] + kernel_img_mul_219[7] + kernel_img_mul_219[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1759:1752] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1759:1752] <= kernel_img_sum_219[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1759:1752] <= 'd0;
end

wire  [25:0]  kernel_img_mul_220[0:8];
assign kernel_img_mul_220[0] = buffer_data_2[1759:1752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_220[1] = buffer_data_2[1767:1760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_220[2] = buffer_data_2[1775:1768] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_220[3] = buffer_data_1[1759:1752] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_220[4] = buffer_data_1[1767:1760] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_220[5] = buffer_data_1[1775:1768] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_220[6] = buffer_data_0[1759:1752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_220[7] = buffer_data_0[1767:1760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_220[8] = buffer_data_0[1775:1768] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_220 = kernel_img_mul_220[0] + kernel_img_mul_220[1] + kernel_img_mul_220[2] + 
                kernel_img_mul_220[3] + kernel_img_mul_220[4] + kernel_img_mul_220[5] + 
                kernel_img_mul_220[6] + kernel_img_mul_220[7] + kernel_img_mul_220[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1767:1760] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1767:1760] <= kernel_img_sum_220[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1767:1760] <= 'd0;
end

wire  [25:0]  kernel_img_mul_221[0:8];
assign kernel_img_mul_221[0] = buffer_data_2[1767:1760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_221[1] = buffer_data_2[1775:1768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_221[2] = buffer_data_2[1783:1776] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_221[3] = buffer_data_1[1767:1760] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_221[4] = buffer_data_1[1775:1768] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_221[5] = buffer_data_1[1783:1776] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_221[6] = buffer_data_0[1767:1760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_221[7] = buffer_data_0[1775:1768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_221[8] = buffer_data_0[1783:1776] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_221 = kernel_img_mul_221[0] + kernel_img_mul_221[1] + kernel_img_mul_221[2] + 
                kernel_img_mul_221[3] + kernel_img_mul_221[4] + kernel_img_mul_221[5] + 
                kernel_img_mul_221[6] + kernel_img_mul_221[7] + kernel_img_mul_221[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1775:1768] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1775:1768] <= kernel_img_sum_221[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1775:1768] <= 'd0;
end

wire  [25:0]  kernel_img_mul_222[0:8];
assign kernel_img_mul_222[0] = buffer_data_2[1775:1768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_222[1] = buffer_data_2[1783:1776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_222[2] = buffer_data_2[1791:1784] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_222[3] = buffer_data_1[1775:1768] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_222[4] = buffer_data_1[1783:1776] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_222[5] = buffer_data_1[1791:1784] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_222[6] = buffer_data_0[1775:1768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_222[7] = buffer_data_0[1783:1776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_222[8] = buffer_data_0[1791:1784] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_222 = kernel_img_mul_222[0] + kernel_img_mul_222[1] + kernel_img_mul_222[2] + 
                kernel_img_mul_222[3] + kernel_img_mul_222[4] + kernel_img_mul_222[5] + 
                kernel_img_mul_222[6] + kernel_img_mul_222[7] + kernel_img_mul_222[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1783:1776] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1783:1776] <= kernel_img_sum_222[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1783:1776] <= 'd0;
end

wire  [25:0]  kernel_img_mul_223[0:8];
assign kernel_img_mul_223[0] = buffer_data_2[1783:1776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_223[1] = buffer_data_2[1791:1784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_223[2] = buffer_data_2[1799:1792] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_223[3] = buffer_data_1[1783:1776] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_223[4] = buffer_data_1[1791:1784] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_223[5] = buffer_data_1[1799:1792] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_223[6] = buffer_data_0[1783:1776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_223[7] = buffer_data_0[1791:1784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_223[8] = buffer_data_0[1799:1792] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_223 = kernel_img_mul_223[0] + kernel_img_mul_223[1] + kernel_img_mul_223[2] + 
                kernel_img_mul_223[3] + kernel_img_mul_223[4] + kernel_img_mul_223[5] + 
                kernel_img_mul_223[6] + kernel_img_mul_223[7] + kernel_img_mul_223[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1791:1784] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1791:1784] <= kernel_img_sum_223[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1791:1784] <= 'd0;
end

wire  [25:0]  kernel_img_mul_224[0:8];
assign kernel_img_mul_224[0] = buffer_data_2[1791:1784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_224[1] = buffer_data_2[1799:1792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_224[2] = buffer_data_2[1807:1800] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_224[3] = buffer_data_1[1791:1784] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_224[4] = buffer_data_1[1799:1792] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_224[5] = buffer_data_1[1807:1800] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_224[6] = buffer_data_0[1791:1784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_224[7] = buffer_data_0[1799:1792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_224[8] = buffer_data_0[1807:1800] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_224 = kernel_img_mul_224[0] + kernel_img_mul_224[1] + kernel_img_mul_224[2] + 
                kernel_img_mul_224[3] + kernel_img_mul_224[4] + kernel_img_mul_224[5] + 
                kernel_img_mul_224[6] + kernel_img_mul_224[7] + kernel_img_mul_224[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1799:1792] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1799:1792] <= kernel_img_sum_224[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1799:1792] <= 'd0;
end

wire  [25:0]  kernel_img_mul_225[0:8];
assign kernel_img_mul_225[0] = buffer_data_2[1799:1792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_225[1] = buffer_data_2[1807:1800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_225[2] = buffer_data_2[1815:1808] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_225[3] = buffer_data_1[1799:1792] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_225[4] = buffer_data_1[1807:1800] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_225[5] = buffer_data_1[1815:1808] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_225[6] = buffer_data_0[1799:1792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_225[7] = buffer_data_0[1807:1800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_225[8] = buffer_data_0[1815:1808] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_225 = kernel_img_mul_225[0] + kernel_img_mul_225[1] + kernel_img_mul_225[2] + 
                kernel_img_mul_225[3] + kernel_img_mul_225[4] + kernel_img_mul_225[5] + 
                kernel_img_mul_225[6] + kernel_img_mul_225[7] + kernel_img_mul_225[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1807:1800] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1807:1800] <= kernel_img_sum_225[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1807:1800] <= 'd0;
end

wire  [25:0]  kernel_img_mul_226[0:8];
assign kernel_img_mul_226[0] = buffer_data_2[1807:1800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_226[1] = buffer_data_2[1815:1808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_226[2] = buffer_data_2[1823:1816] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_226[3] = buffer_data_1[1807:1800] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_226[4] = buffer_data_1[1815:1808] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_226[5] = buffer_data_1[1823:1816] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_226[6] = buffer_data_0[1807:1800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_226[7] = buffer_data_0[1815:1808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_226[8] = buffer_data_0[1823:1816] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_226 = kernel_img_mul_226[0] + kernel_img_mul_226[1] + kernel_img_mul_226[2] + 
                kernel_img_mul_226[3] + kernel_img_mul_226[4] + kernel_img_mul_226[5] + 
                kernel_img_mul_226[6] + kernel_img_mul_226[7] + kernel_img_mul_226[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1815:1808] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1815:1808] <= kernel_img_sum_226[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1815:1808] <= 'd0;
end

wire  [25:0]  kernel_img_mul_227[0:8];
assign kernel_img_mul_227[0] = buffer_data_2[1815:1808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_227[1] = buffer_data_2[1823:1816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_227[2] = buffer_data_2[1831:1824] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_227[3] = buffer_data_1[1815:1808] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_227[4] = buffer_data_1[1823:1816] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_227[5] = buffer_data_1[1831:1824] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_227[6] = buffer_data_0[1815:1808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_227[7] = buffer_data_0[1823:1816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_227[8] = buffer_data_0[1831:1824] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_227 = kernel_img_mul_227[0] + kernel_img_mul_227[1] + kernel_img_mul_227[2] + 
                kernel_img_mul_227[3] + kernel_img_mul_227[4] + kernel_img_mul_227[5] + 
                kernel_img_mul_227[6] + kernel_img_mul_227[7] + kernel_img_mul_227[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1823:1816] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1823:1816] <= kernel_img_sum_227[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1823:1816] <= 'd0;
end

wire  [25:0]  kernel_img_mul_228[0:8];
assign kernel_img_mul_228[0] = buffer_data_2[1823:1816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_228[1] = buffer_data_2[1831:1824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_228[2] = buffer_data_2[1839:1832] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_228[3] = buffer_data_1[1823:1816] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_228[4] = buffer_data_1[1831:1824] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_228[5] = buffer_data_1[1839:1832] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_228[6] = buffer_data_0[1823:1816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_228[7] = buffer_data_0[1831:1824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_228[8] = buffer_data_0[1839:1832] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_228 = kernel_img_mul_228[0] + kernel_img_mul_228[1] + kernel_img_mul_228[2] + 
                kernel_img_mul_228[3] + kernel_img_mul_228[4] + kernel_img_mul_228[5] + 
                kernel_img_mul_228[6] + kernel_img_mul_228[7] + kernel_img_mul_228[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1831:1824] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1831:1824] <= kernel_img_sum_228[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1831:1824] <= 'd0;
end

wire  [25:0]  kernel_img_mul_229[0:8];
assign kernel_img_mul_229[0] = buffer_data_2[1831:1824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_229[1] = buffer_data_2[1839:1832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_229[2] = buffer_data_2[1847:1840] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_229[3] = buffer_data_1[1831:1824] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_229[4] = buffer_data_1[1839:1832] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_229[5] = buffer_data_1[1847:1840] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_229[6] = buffer_data_0[1831:1824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_229[7] = buffer_data_0[1839:1832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_229[8] = buffer_data_0[1847:1840] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_229 = kernel_img_mul_229[0] + kernel_img_mul_229[1] + kernel_img_mul_229[2] + 
                kernel_img_mul_229[3] + kernel_img_mul_229[4] + kernel_img_mul_229[5] + 
                kernel_img_mul_229[6] + kernel_img_mul_229[7] + kernel_img_mul_229[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1839:1832] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1839:1832] <= kernel_img_sum_229[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1839:1832] <= 'd0;
end

wire  [25:0]  kernel_img_mul_230[0:8];
assign kernel_img_mul_230[0] = buffer_data_2[1839:1832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_230[1] = buffer_data_2[1847:1840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_230[2] = buffer_data_2[1855:1848] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_230[3] = buffer_data_1[1839:1832] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_230[4] = buffer_data_1[1847:1840] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_230[5] = buffer_data_1[1855:1848] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_230[6] = buffer_data_0[1839:1832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_230[7] = buffer_data_0[1847:1840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_230[8] = buffer_data_0[1855:1848] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_230 = kernel_img_mul_230[0] + kernel_img_mul_230[1] + kernel_img_mul_230[2] + 
                kernel_img_mul_230[3] + kernel_img_mul_230[4] + kernel_img_mul_230[5] + 
                kernel_img_mul_230[6] + kernel_img_mul_230[7] + kernel_img_mul_230[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1847:1840] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1847:1840] <= kernel_img_sum_230[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1847:1840] <= 'd0;
end

wire  [25:0]  kernel_img_mul_231[0:8];
assign kernel_img_mul_231[0] = buffer_data_2[1847:1840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_231[1] = buffer_data_2[1855:1848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_231[2] = buffer_data_2[1863:1856] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_231[3] = buffer_data_1[1847:1840] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_231[4] = buffer_data_1[1855:1848] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_231[5] = buffer_data_1[1863:1856] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_231[6] = buffer_data_0[1847:1840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_231[7] = buffer_data_0[1855:1848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_231[8] = buffer_data_0[1863:1856] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_231 = kernel_img_mul_231[0] + kernel_img_mul_231[1] + kernel_img_mul_231[2] + 
                kernel_img_mul_231[3] + kernel_img_mul_231[4] + kernel_img_mul_231[5] + 
                kernel_img_mul_231[6] + kernel_img_mul_231[7] + kernel_img_mul_231[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1855:1848] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1855:1848] <= kernel_img_sum_231[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1855:1848] <= 'd0;
end

wire  [25:0]  kernel_img_mul_232[0:8];
assign kernel_img_mul_232[0] = buffer_data_2[1855:1848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_232[1] = buffer_data_2[1863:1856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_232[2] = buffer_data_2[1871:1864] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_232[3] = buffer_data_1[1855:1848] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_232[4] = buffer_data_1[1863:1856] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_232[5] = buffer_data_1[1871:1864] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_232[6] = buffer_data_0[1855:1848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_232[7] = buffer_data_0[1863:1856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_232[8] = buffer_data_0[1871:1864] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_232 = kernel_img_mul_232[0] + kernel_img_mul_232[1] + kernel_img_mul_232[2] + 
                kernel_img_mul_232[3] + kernel_img_mul_232[4] + kernel_img_mul_232[5] + 
                kernel_img_mul_232[6] + kernel_img_mul_232[7] + kernel_img_mul_232[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1863:1856] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1863:1856] <= kernel_img_sum_232[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1863:1856] <= 'd0;
end

wire  [25:0]  kernel_img_mul_233[0:8];
assign kernel_img_mul_233[0] = buffer_data_2[1863:1856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_233[1] = buffer_data_2[1871:1864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_233[2] = buffer_data_2[1879:1872] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_233[3] = buffer_data_1[1863:1856] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_233[4] = buffer_data_1[1871:1864] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_233[5] = buffer_data_1[1879:1872] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_233[6] = buffer_data_0[1863:1856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_233[7] = buffer_data_0[1871:1864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_233[8] = buffer_data_0[1879:1872] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_233 = kernel_img_mul_233[0] + kernel_img_mul_233[1] + kernel_img_mul_233[2] + 
                kernel_img_mul_233[3] + kernel_img_mul_233[4] + kernel_img_mul_233[5] + 
                kernel_img_mul_233[6] + kernel_img_mul_233[7] + kernel_img_mul_233[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1871:1864] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1871:1864] <= kernel_img_sum_233[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1871:1864] <= 'd0;
end

wire  [25:0]  kernel_img_mul_234[0:8];
assign kernel_img_mul_234[0] = buffer_data_2[1871:1864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_234[1] = buffer_data_2[1879:1872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_234[2] = buffer_data_2[1887:1880] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_234[3] = buffer_data_1[1871:1864] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_234[4] = buffer_data_1[1879:1872] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_234[5] = buffer_data_1[1887:1880] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_234[6] = buffer_data_0[1871:1864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_234[7] = buffer_data_0[1879:1872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_234[8] = buffer_data_0[1887:1880] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_234 = kernel_img_mul_234[0] + kernel_img_mul_234[1] + kernel_img_mul_234[2] + 
                kernel_img_mul_234[3] + kernel_img_mul_234[4] + kernel_img_mul_234[5] + 
                kernel_img_mul_234[6] + kernel_img_mul_234[7] + kernel_img_mul_234[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1879:1872] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1879:1872] <= kernel_img_sum_234[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1879:1872] <= 'd0;
end

wire  [25:0]  kernel_img_mul_235[0:8];
assign kernel_img_mul_235[0] = buffer_data_2[1879:1872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_235[1] = buffer_data_2[1887:1880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_235[2] = buffer_data_2[1895:1888] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_235[3] = buffer_data_1[1879:1872] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_235[4] = buffer_data_1[1887:1880] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_235[5] = buffer_data_1[1895:1888] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_235[6] = buffer_data_0[1879:1872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_235[7] = buffer_data_0[1887:1880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_235[8] = buffer_data_0[1895:1888] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_235 = kernel_img_mul_235[0] + kernel_img_mul_235[1] + kernel_img_mul_235[2] + 
                kernel_img_mul_235[3] + kernel_img_mul_235[4] + kernel_img_mul_235[5] + 
                kernel_img_mul_235[6] + kernel_img_mul_235[7] + kernel_img_mul_235[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1887:1880] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1887:1880] <= kernel_img_sum_235[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1887:1880] <= 'd0;
end

wire  [25:0]  kernel_img_mul_236[0:8];
assign kernel_img_mul_236[0] = buffer_data_2[1887:1880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_236[1] = buffer_data_2[1895:1888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_236[2] = buffer_data_2[1903:1896] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_236[3] = buffer_data_1[1887:1880] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_236[4] = buffer_data_1[1895:1888] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_236[5] = buffer_data_1[1903:1896] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_236[6] = buffer_data_0[1887:1880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_236[7] = buffer_data_0[1895:1888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_236[8] = buffer_data_0[1903:1896] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_236 = kernel_img_mul_236[0] + kernel_img_mul_236[1] + kernel_img_mul_236[2] + 
                kernel_img_mul_236[3] + kernel_img_mul_236[4] + kernel_img_mul_236[5] + 
                kernel_img_mul_236[6] + kernel_img_mul_236[7] + kernel_img_mul_236[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1895:1888] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1895:1888] <= kernel_img_sum_236[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1895:1888] <= 'd0;
end

wire  [25:0]  kernel_img_mul_237[0:8];
assign kernel_img_mul_237[0] = buffer_data_2[1895:1888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_237[1] = buffer_data_2[1903:1896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_237[2] = buffer_data_2[1911:1904] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_237[3] = buffer_data_1[1895:1888] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_237[4] = buffer_data_1[1903:1896] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_237[5] = buffer_data_1[1911:1904] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_237[6] = buffer_data_0[1895:1888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_237[7] = buffer_data_0[1903:1896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_237[8] = buffer_data_0[1911:1904] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_237 = kernel_img_mul_237[0] + kernel_img_mul_237[1] + kernel_img_mul_237[2] + 
                kernel_img_mul_237[3] + kernel_img_mul_237[4] + kernel_img_mul_237[5] + 
                kernel_img_mul_237[6] + kernel_img_mul_237[7] + kernel_img_mul_237[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1903:1896] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1903:1896] <= kernel_img_sum_237[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1903:1896] <= 'd0;
end

wire  [25:0]  kernel_img_mul_238[0:8];
assign kernel_img_mul_238[0] = buffer_data_2[1903:1896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_238[1] = buffer_data_2[1911:1904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_238[2] = buffer_data_2[1919:1912] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_238[3] = buffer_data_1[1903:1896] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_238[4] = buffer_data_1[1911:1904] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_238[5] = buffer_data_1[1919:1912] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_238[6] = buffer_data_0[1903:1896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_238[7] = buffer_data_0[1911:1904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_238[8] = buffer_data_0[1919:1912] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_238 = kernel_img_mul_238[0] + kernel_img_mul_238[1] + kernel_img_mul_238[2] + 
                kernel_img_mul_238[3] + kernel_img_mul_238[4] + kernel_img_mul_238[5] + 
                kernel_img_mul_238[6] + kernel_img_mul_238[7] + kernel_img_mul_238[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1911:1904] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1911:1904] <= kernel_img_sum_238[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1911:1904] <= 'd0;
end

wire  [25:0]  kernel_img_mul_239[0:8];
assign kernel_img_mul_239[0] = buffer_data_2[1911:1904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_239[1] = buffer_data_2[1919:1912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_239[2] = buffer_data_2[1927:1920] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_239[3] = buffer_data_1[1911:1904] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_239[4] = buffer_data_1[1919:1912] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_239[5] = buffer_data_1[1927:1920] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_239[6] = buffer_data_0[1911:1904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_239[7] = buffer_data_0[1919:1912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_239[8] = buffer_data_0[1927:1920] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_239 = kernel_img_mul_239[0] + kernel_img_mul_239[1] + kernel_img_mul_239[2] + 
                kernel_img_mul_239[3] + kernel_img_mul_239[4] + kernel_img_mul_239[5] + 
                kernel_img_mul_239[6] + kernel_img_mul_239[7] + kernel_img_mul_239[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1919:1912] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1919:1912] <= kernel_img_sum_239[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1919:1912] <= 'd0;
end

wire  [25:0]  kernel_img_mul_240[0:8];
assign kernel_img_mul_240[0] = buffer_data_2[1919:1912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_240[1] = buffer_data_2[1927:1920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_240[2] = buffer_data_2[1935:1928] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_240[3] = buffer_data_1[1919:1912] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_240[4] = buffer_data_1[1927:1920] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_240[5] = buffer_data_1[1935:1928] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_240[6] = buffer_data_0[1919:1912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_240[7] = buffer_data_0[1927:1920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_240[8] = buffer_data_0[1935:1928] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_240 = kernel_img_mul_240[0] + kernel_img_mul_240[1] + kernel_img_mul_240[2] + 
                kernel_img_mul_240[3] + kernel_img_mul_240[4] + kernel_img_mul_240[5] + 
                kernel_img_mul_240[6] + kernel_img_mul_240[7] + kernel_img_mul_240[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1927:1920] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1927:1920] <= kernel_img_sum_240[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1927:1920] <= 'd0;
end

wire  [25:0]  kernel_img_mul_241[0:8];
assign kernel_img_mul_241[0] = buffer_data_2[1927:1920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_241[1] = buffer_data_2[1935:1928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_241[2] = buffer_data_2[1943:1936] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_241[3] = buffer_data_1[1927:1920] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_241[4] = buffer_data_1[1935:1928] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_241[5] = buffer_data_1[1943:1936] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_241[6] = buffer_data_0[1927:1920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_241[7] = buffer_data_0[1935:1928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_241[8] = buffer_data_0[1943:1936] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_241 = kernel_img_mul_241[0] + kernel_img_mul_241[1] + kernel_img_mul_241[2] + 
                kernel_img_mul_241[3] + kernel_img_mul_241[4] + kernel_img_mul_241[5] + 
                kernel_img_mul_241[6] + kernel_img_mul_241[7] + kernel_img_mul_241[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1935:1928] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1935:1928] <= kernel_img_sum_241[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1935:1928] <= 'd0;
end

wire  [25:0]  kernel_img_mul_242[0:8];
assign kernel_img_mul_242[0] = buffer_data_2[1935:1928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_242[1] = buffer_data_2[1943:1936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_242[2] = buffer_data_2[1951:1944] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_242[3] = buffer_data_1[1935:1928] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_242[4] = buffer_data_1[1943:1936] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_242[5] = buffer_data_1[1951:1944] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_242[6] = buffer_data_0[1935:1928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_242[7] = buffer_data_0[1943:1936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_242[8] = buffer_data_0[1951:1944] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_242 = kernel_img_mul_242[0] + kernel_img_mul_242[1] + kernel_img_mul_242[2] + 
                kernel_img_mul_242[3] + kernel_img_mul_242[4] + kernel_img_mul_242[5] + 
                kernel_img_mul_242[6] + kernel_img_mul_242[7] + kernel_img_mul_242[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1943:1936] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1943:1936] <= kernel_img_sum_242[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1943:1936] <= 'd0;
end

wire  [25:0]  kernel_img_mul_243[0:8];
assign kernel_img_mul_243[0] = buffer_data_2[1943:1936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_243[1] = buffer_data_2[1951:1944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_243[2] = buffer_data_2[1959:1952] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_243[3] = buffer_data_1[1943:1936] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_243[4] = buffer_data_1[1951:1944] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_243[5] = buffer_data_1[1959:1952] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_243[6] = buffer_data_0[1943:1936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_243[7] = buffer_data_0[1951:1944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_243[8] = buffer_data_0[1959:1952] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_243 = kernel_img_mul_243[0] + kernel_img_mul_243[1] + kernel_img_mul_243[2] + 
                kernel_img_mul_243[3] + kernel_img_mul_243[4] + kernel_img_mul_243[5] + 
                kernel_img_mul_243[6] + kernel_img_mul_243[7] + kernel_img_mul_243[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1951:1944] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1951:1944] <= kernel_img_sum_243[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1951:1944] <= 'd0;
end

wire  [25:0]  kernel_img_mul_244[0:8];
assign kernel_img_mul_244[0] = buffer_data_2[1951:1944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_244[1] = buffer_data_2[1959:1952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_244[2] = buffer_data_2[1967:1960] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_244[3] = buffer_data_1[1951:1944] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_244[4] = buffer_data_1[1959:1952] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_244[5] = buffer_data_1[1967:1960] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_244[6] = buffer_data_0[1951:1944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_244[7] = buffer_data_0[1959:1952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_244[8] = buffer_data_0[1967:1960] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_244 = kernel_img_mul_244[0] + kernel_img_mul_244[1] + kernel_img_mul_244[2] + 
                kernel_img_mul_244[3] + kernel_img_mul_244[4] + kernel_img_mul_244[5] + 
                kernel_img_mul_244[6] + kernel_img_mul_244[7] + kernel_img_mul_244[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1959:1952] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1959:1952] <= kernel_img_sum_244[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1959:1952] <= 'd0;
end

wire  [25:0]  kernel_img_mul_245[0:8];
assign kernel_img_mul_245[0] = buffer_data_2[1959:1952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_245[1] = buffer_data_2[1967:1960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_245[2] = buffer_data_2[1975:1968] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_245[3] = buffer_data_1[1959:1952] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_245[4] = buffer_data_1[1967:1960] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_245[5] = buffer_data_1[1975:1968] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_245[6] = buffer_data_0[1959:1952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_245[7] = buffer_data_0[1967:1960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_245[8] = buffer_data_0[1975:1968] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_245 = kernel_img_mul_245[0] + kernel_img_mul_245[1] + kernel_img_mul_245[2] + 
                kernel_img_mul_245[3] + kernel_img_mul_245[4] + kernel_img_mul_245[5] + 
                kernel_img_mul_245[6] + kernel_img_mul_245[7] + kernel_img_mul_245[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1967:1960] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1967:1960] <= kernel_img_sum_245[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1967:1960] <= 'd0;
end

wire  [25:0]  kernel_img_mul_246[0:8];
assign kernel_img_mul_246[0] = buffer_data_2[1967:1960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_246[1] = buffer_data_2[1975:1968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_246[2] = buffer_data_2[1983:1976] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_246[3] = buffer_data_1[1967:1960] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_246[4] = buffer_data_1[1975:1968] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_246[5] = buffer_data_1[1983:1976] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_246[6] = buffer_data_0[1967:1960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_246[7] = buffer_data_0[1975:1968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_246[8] = buffer_data_0[1983:1976] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_246 = kernel_img_mul_246[0] + kernel_img_mul_246[1] + kernel_img_mul_246[2] + 
                kernel_img_mul_246[3] + kernel_img_mul_246[4] + kernel_img_mul_246[5] + 
                kernel_img_mul_246[6] + kernel_img_mul_246[7] + kernel_img_mul_246[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1975:1968] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1975:1968] <= kernel_img_sum_246[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1975:1968] <= 'd0;
end

wire  [25:0]  kernel_img_mul_247[0:8];
assign kernel_img_mul_247[0] = buffer_data_2[1975:1968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_247[1] = buffer_data_2[1983:1976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_247[2] = buffer_data_2[1991:1984] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_247[3] = buffer_data_1[1975:1968] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_247[4] = buffer_data_1[1983:1976] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_247[5] = buffer_data_1[1991:1984] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_247[6] = buffer_data_0[1975:1968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_247[7] = buffer_data_0[1983:1976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_247[8] = buffer_data_0[1991:1984] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_247 = kernel_img_mul_247[0] + kernel_img_mul_247[1] + kernel_img_mul_247[2] + 
                kernel_img_mul_247[3] + kernel_img_mul_247[4] + kernel_img_mul_247[5] + 
                kernel_img_mul_247[6] + kernel_img_mul_247[7] + kernel_img_mul_247[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1983:1976] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1983:1976] <= kernel_img_sum_247[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1983:1976] <= 'd0;
end

wire  [25:0]  kernel_img_mul_248[0:8];
assign kernel_img_mul_248[0] = buffer_data_2[1983:1976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_248[1] = buffer_data_2[1991:1984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_248[2] = buffer_data_2[1999:1992] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_248[3] = buffer_data_1[1983:1976] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_248[4] = buffer_data_1[1991:1984] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_248[5] = buffer_data_1[1999:1992] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_248[6] = buffer_data_0[1983:1976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_248[7] = buffer_data_0[1991:1984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_248[8] = buffer_data_0[1999:1992] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_248 = kernel_img_mul_248[0] + kernel_img_mul_248[1] + kernel_img_mul_248[2] + 
                kernel_img_mul_248[3] + kernel_img_mul_248[4] + kernel_img_mul_248[5] + 
                kernel_img_mul_248[6] + kernel_img_mul_248[7] + kernel_img_mul_248[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1991:1984] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1991:1984] <= kernel_img_sum_248[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1991:1984] <= 'd0;
end

wire  [25:0]  kernel_img_mul_249[0:8];
assign kernel_img_mul_249[0] = buffer_data_2[1991:1984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_249[1] = buffer_data_2[1999:1992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_249[2] = buffer_data_2[2007:2000] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_249[3] = buffer_data_1[1991:1984] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_249[4] = buffer_data_1[1999:1992] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_249[5] = buffer_data_1[2007:2000] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_249[6] = buffer_data_0[1991:1984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_249[7] = buffer_data_0[1999:1992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_249[8] = buffer_data_0[2007:2000] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_249 = kernel_img_mul_249[0] + kernel_img_mul_249[1] + kernel_img_mul_249[2] + 
                kernel_img_mul_249[3] + kernel_img_mul_249[4] + kernel_img_mul_249[5] + 
                kernel_img_mul_249[6] + kernel_img_mul_249[7] + kernel_img_mul_249[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[1999:1992] <= 'd0;
  else if (current_state==ST_START)
    blur_din[1999:1992] <= kernel_img_sum_249[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1999:1992] <= 'd0;
end

wire  [25:0]  kernel_img_mul_250[0:8];
assign kernel_img_mul_250[0] = buffer_data_2[1999:1992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_250[1] = buffer_data_2[2007:2000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_250[2] = buffer_data_2[2015:2008] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_250[3] = buffer_data_1[1999:1992] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_250[4] = buffer_data_1[2007:2000] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_250[5] = buffer_data_1[2015:2008] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_250[6] = buffer_data_0[1999:1992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_250[7] = buffer_data_0[2007:2000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_250[8] = buffer_data_0[2015:2008] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_250 = kernel_img_mul_250[0] + kernel_img_mul_250[1] + kernel_img_mul_250[2] + 
                kernel_img_mul_250[3] + kernel_img_mul_250[4] + kernel_img_mul_250[5] + 
                kernel_img_mul_250[6] + kernel_img_mul_250[7] + kernel_img_mul_250[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2007:2000] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2007:2000] <= kernel_img_sum_250[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2007:2000] <= 'd0;
end

wire  [25:0]  kernel_img_mul_251[0:8];
assign kernel_img_mul_251[0] = buffer_data_2[2007:2000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_251[1] = buffer_data_2[2015:2008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_251[2] = buffer_data_2[2023:2016] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_251[3] = buffer_data_1[2007:2000] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_251[4] = buffer_data_1[2015:2008] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_251[5] = buffer_data_1[2023:2016] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_251[6] = buffer_data_0[2007:2000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_251[7] = buffer_data_0[2015:2008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_251[8] = buffer_data_0[2023:2016] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_251 = kernel_img_mul_251[0] + kernel_img_mul_251[1] + kernel_img_mul_251[2] + 
                kernel_img_mul_251[3] + kernel_img_mul_251[4] + kernel_img_mul_251[5] + 
                kernel_img_mul_251[6] + kernel_img_mul_251[7] + kernel_img_mul_251[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2015:2008] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2015:2008] <= kernel_img_sum_251[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2015:2008] <= 'd0;
end

wire  [25:0]  kernel_img_mul_252[0:8];
assign kernel_img_mul_252[0] = buffer_data_2[2015:2008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_252[1] = buffer_data_2[2023:2016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_252[2] = buffer_data_2[2031:2024] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_252[3] = buffer_data_1[2015:2008] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_252[4] = buffer_data_1[2023:2016] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_252[5] = buffer_data_1[2031:2024] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_252[6] = buffer_data_0[2015:2008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_252[7] = buffer_data_0[2023:2016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_252[8] = buffer_data_0[2031:2024] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_252 = kernel_img_mul_252[0] + kernel_img_mul_252[1] + kernel_img_mul_252[2] + 
                kernel_img_mul_252[3] + kernel_img_mul_252[4] + kernel_img_mul_252[5] + 
                kernel_img_mul_252[6] + kernel_img_mul_252[7] + kernel_img_mul_252[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2023:2016] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2023:2016] <= kernel_img_sum_252[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2023:2016] <= 'd0;
end

wire  [25:0]  kernel_img_mul_253[0:8];
assign kernel_img_mul_253[0] = buffer_data_2[2023:2016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_253[1] = buffer_data_2[2031:2024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_253[2] = buffer_data_2[2039:2032] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_253[3] = buffer_data_1[2023:2016] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_253[4] = buffer_data_1[2031:2024] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_253[5] = buffer_data_1[2039:2032] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_253[6] = buffer_data_0[2023:2016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_253[7] = buffer_data_0[2031:2024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_253[8] = buffer_data_0[2039:2032] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_253 = kernel_img_mul_253[0] + kernel_img_mul_253[1] + kernel_img_mul_253[2] + 
                kernel_img_mul_253[3] + kernel_img_mul_253[4] + kernel_img_mul_253[5] + 
                kernel_img_mul_253[6] + kernel_img_mul_253[7] + kernel_img_mul_253[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2031:2024] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2031:2024] <= kernel_img_sum_253[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2031:2024] <= 'd0;
end

wire  [25:0]  kernel_img_mul_254[0:8];
assign kernel_img_mul_254[0] = buffer_data_2[2031:2024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_254[1] = buffer_data_2[2039:2032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_254[2] = buffer_data_2[2047:2040] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_254[3] = buffer_data_1[2031:2024] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_254[4] = buffer_data_1[2039:2032] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_254[5] = buffer_data_1[2047:2040] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_254[6] = buffer_data_0[2031:2024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_254[7] = buffer_data_0[2039:2032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_254[8] = buffer_data_0[2047:2040] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_254 = kernel_img_mul_254[0] + kernel_img_mul_254[1] + kernel_img_mul_254[2] + 
                kernel_img_mul_254[3] + kernel_img_mul_254[4] + kernel_img_mul_254[5] + 
                kernel_img_mul_254[6] + kernel_img_mul_254[7] + kernel_img_mul_254[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2039:2032] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2039:2032] <= kernel_img_sum_254[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2039:2032] <= 'd0;
end

wire  [25:0]  kernel_img_mul_255[0:8];
assign kernel_img_mul_255[0] = buffer_data_2[2039:2032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_255[1] = buffer_data_2[2047:2040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_255[2] = buffer_data_2[2055:2048] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_255[3] = buffer_data_1[2039:2032] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_255[4] = buffer_data_1[2047:2040] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_255[5] = buffer_data_1[2055:2048] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_255[6] = buffer_data_0[2039:2032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_255[7] = buffer_data_0[2047:2040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_255[8] = buffer_data_0[2055:2048] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_255 = kernel_img_mul_255[0] + kernel_img_mul_255[1] + kernel_img_mul_255[2] + 
                kernel_img_mul_255[3] + kernel_img_mul_255[4] + kernel_img_mul_255[5] + 
                kernel_img_mul_255[6] + kernel_img_mul_255[7] + kernel_img_mul_255[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2047:2040] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2047:2040] <= kernel_img_sum_255[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2047:2040] <= 'd0;
end

wire  [25:0]  kernel_img_mul_256[0:8];
assign kernel_img_mul_256[0] = buffer_data_2[2047:2040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_256[1] = buffer_data_2[2055:2048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_256[2] = buffer_data_2[2063:2056] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_256[3] = buffer_data_1[2047:2040] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_256[4] = buffer_data_1[2055:2048] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_256[5] = buffer_data_1[2063:2056] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_256[6] = buffer_data_0[2047:2040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_256[7] = buffer_data_0[2055:2048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_256[8] = buffer_data_0[2063:2056] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_256 = kernel_img_mul_256[0] + kernel_img_mul_256[1] + kernel_img_mul_256[2] + 
                kernel_img_mul_256[3] + kernel_img_mul_256[4] + kernel_img_mul_256[5] + 
                kernel_img_mul_256[6] + kernel_img_mul_256[7] + kernel_img_mul_256[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2055:2048] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2055:2048] <= kernel_img_sum_256[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2055:2048] <= 'd0;
end

wire  [25:0]  kernel_img_mul_257[0:8];
assign kernel_img_mul_257[0] = buffer_data_2[2055:2048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_257[1] = buffer_data_2[2063:2056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_257[2] = buffer_data_2[2071:2064] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_257[3] = buffer_data_1[2055:2048] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_257[4] = buffer_data_1[2063:2056] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_257[5] = buffer_data_1[2071:2064] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_257[6] = buffer_data_0[2055:2048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_257[7] = buffer_data_0[2063:2056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_257[8] = buffer_data_0[2071:2064] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_257 = kernel_img_mul_257[0] + kernel_img_mul_257[1] + kernel_img_mul_257[2] + 
                kernel_img_mul_257[3] + kernel_img_mul_257[4] + kernel_img_mul_257[5] + 
                kernel_img_mul_257[6] + kernel_img_mul_257[7] + kernel_img_mul_257[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2063:2056] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2063:2056] <= kernel_img_sum_257[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2063:2056] <= 'd0;
end

wire  [25:0]  kernel_img_mul_258[0:8];
assign kernel_img_mul_258[0] = buffer_data_2[2063:2056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_258[1] = buffer_data_2[2071:2064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_258[2] = buffer_data_2[2079:2072] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_258[3] = buffer_data_1[2063:2056] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_258[4] = buffer_data_1[2071:2064] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_258[5] = buffer_data_1[2079:2072] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_258[6] = buffer_data_0[2063:2056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_258[7] = buffer_data_0[2071:2064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_258[8] = buffer_data_0[2079:2072] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_258 = kernel_img_mul_258[0] + kernel_img_mul_258[1] + kernel_img_mul_258[2] + 
                kernel_img_mul_258[3] + kernel_img_mul_258[4] + kernel_img_mul_258[5] + 
                kernel_img_mul_258[6] + kernel_img_mul_258[7] + kernel_img_mul_258[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2071:2064] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2071:2064] <= kernel_img_sum_258[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2071:2064] <= 'd0;
end

wire  [25:0]  kernel_img_mul_259[0:8];
assign kernel_img_mul_259[0] = buffer_data_2[2071:2064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_259[1] = buffer_data_2[2079:2072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_259[2] = buffer_data_2[2087:2080] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_259[3] = buffer_data_1[2071:2064] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_259[4] = buffer_data_1[2079:2072] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_259[5] = buffer_data_1[2087:2080] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_259[6] = buffer_data_0[2071:2064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_259[7] = buffer_data_0[2079:2072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_259[8] = buffer_data_0[2087:2080] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_259 = kernel_img_mul_259[0] + kernel_img_mul_259[1] + kernel_img_mul_259[2] + 
                kernel_img_mul_259[3] + kernel_img_mul_259[4] + kernel_img_mul_259[5] + 
                kernel_img_mul_259[6] + kernel_img_mul_259[7] + kernel_img_mul_259[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2079:2072] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2079:2072] <= kernel_img_sum_259[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2079:2072] <= 'd0;
end

wire  [25:0]  kernel_img_mul_260[0:8];
assign kernel_img_mul_260[0] = buffer_data_2[2079:2072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_260[1] = buffer_data_2[2087:2080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_260[2] = buffer_data_2[2095:2088] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_260[3] = buffer_data_1[2079:2072] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_260[4] = buffer_data_1[2087:2080] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_260[5] = buffer_data_1[2095:2088] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_260[6] = buffer_data_0[2079:2072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_260[7] = buffer_data_0[2087:2080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_260[8] = buffer_data_0[2095:2088] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_260 = kernel_img_mul_260[0] + kernel_img_mul_260[1] + kernel_img_mul_260[2] + 
                kernel_img_mul_260[3] + kernel_img_mul_260[4] + kernel_img_mul_260[5] + 
                kernel_img_mul_260[6] + kernel_img_mul_260[7] + kernel_img_mul_260[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2087:2080] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2087:2080] <= kernel_img_sum_260[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2087:2080] <= 'd0;
end

wire  [25:0]  kernel_img_mul_261[0:8];
assign kernel_img_mul_261[0] = buffer_data_2[2087:2080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_261[1] = buffer_data_2[2095:2088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_261[2] = buffer_data_2[2103:2096] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_261[3] = buffer_data_1[2087:2080] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_261[4] = buffer_data_1[2095:2088] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_261[5] = buffer_data_1[2103:2096] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_261[6] = buffer_data_0[2087:2080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_261[7] = buffer_data_0[2095:2088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_261[8] = buffer_data_0[2103:2096] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_261 = kernel_img_mul_261[0] + kernel_img_mul_261[1] + kernel_img_mul_261[2] + 
                kernel_img_mul_261[3] + kernel_img_mul_261[4] + kernel_img_mul_261[5] + 
                kernel_img_mul_261[6] + kernel_img_mul_261[7] + kernel_img_mul_261[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2095:2088] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2095:2088] <= kernel_img_sum_261[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2095:2088] <= 'd0;
end

wire  [25:0]  kernel_img_mul_262[0:8];
assign kernel_img_mul_262[0] = buffer_data_2[2095:2088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_262[1] = buffer_data_2[2103:2096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_262[2] = buffer_data_2[2111:2104] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_262[3] = buffer_data_1[2095:2088] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_262[4] = buffer_data_1[2103:2096] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_262[5] = buffer_data_1[2111:2104] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_262[6] = buffer_data_0[2095:2088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_262[7] = buffer_data_0[2103:2096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_262[8] = buffer_data_0[2111:2104] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_262 = kernel_img_mul_262[0] + kernel_img_mul_262[1] + kernel_img_mul_262[2] + 
                kernel_img_mul_262[3] + kernel_img_mul_262[4] + kernel_img_mul_262[5] + 
                kernel_img_mul_262[6] + kernel_img_mul_262[7] + kernel_img_mul_262[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2103:2096] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2103:2096] <= kernel_img_sum_262[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2103:2096] <= 'd0;
end

wire  [25:0]  kernel_img_mul_263[0:8];
assign kernel_img_mul_263[0] = buffer_data_2[2103:2096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_263[1] = buffer_data_2[2111:2104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_263[2] = buffer_data_2[2119:2112] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_263[3] = buffer_data_1[2103:2096] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_263[4] = buffer_data_1[2111:2104] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_263[5] = buffer_data_1[2119:2112] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_263[6] = buffer_data_0[2103:2096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_263[7] = buffer_data_0[2111:2104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_263[8] = buffer_data_0[2119:2112] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_263 = kernel_img_mul_263[0] + kernel_img_mul_263[1] + kernel_img_mul_263[2] + 
                kernel_img_mul_263[3] + kernel_img_mul_263[4] + kernel_img_mul_263[5] + 
                kernel_img_mul_263[6] + kernel_img_mul_263[7] + kernel_img_mul_263[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2111:2104] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2111:2104] <= kernel_img_sum_263[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2111:2104] <= 'd0;
end

wire  [25:0]  kernel_img_mul_264[0:8];
assign kernel_img_mul_264[0] = buffer_data_2[2111:2104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_264[1] = buffer_data_2[2119:2112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_264[2] = buffer_data_2[2127:2120] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_264[3] = buffer_data_1[2111:2104] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_264[4] = buffer_data_1[2119:2112] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_264[5] = buffer_data_1[2127:2120] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_264[6] = buffer_data_0[2111:2104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_264[7] = buffer_data_0[2119:2112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_264[8] = buffer_data_0[2127:2120] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_264 = kernel_img_mul_264[0] + kernel_img_mul_264[1] + kernel_img_mul_264[2] + 
                kernel_img_mul_264[3] + kernel_img_mul_264[4] + kernel_img_mul_264[5] + 
                kernel_img_mul_264[6] + kernel_img_mul_264[7] + kernel_img_mul_264[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2119:2112] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2119:2112] <= kernel_img_sum_264[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2119:2112] <= 'd0;
end

wire  [25:0]  kernel_img_mul_265[0:8];
assign kernel_img_mul_265[0] = buffer_data_2[2119:2112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_265[1] = buffer_data_2[2127:2120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_265[2] = buffer_data_2[2135:2128] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_265[3] = buffer_data_1[2119:2112] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_265[4] = buffer_data_1[2127:2120] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_265[5] = buffer_data_1[2135:2128] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_265[6] = buffer_data_0[2119:2112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_265[7] = buffer_data_0[2127:2120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_265[8] = buffer_data_0[2135:2128] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_265 = kernel_img_mul_265[0] + kernel_img_mul_265[1] + kernel_img_mul_265[2] + 
                kernel_img_mul_265[3] + kernel_img_mul_265[4] + kernel_img_mul_265[5] + 
                kernel_img_mul_265[6] + kernel_img_mul_265[7] + kernel_img_mul_265[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2127:2120] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2127:2120] <= kernel_img_sum_265[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2127:2120] <= 'd0;
end

wire  [25:0]  kernel_img_mul_266[0:8];
assign kernel_img_mul_266[0] = buffer_data_2[2127:2120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_266[1] = buffer_data_2[2135:2128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_266[2] = buffer_data_2[2143:2136] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_266[3] = buffer_data_1[2127:2120] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_266[4] = buffer_data_1[2135:2128] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_266[5] = buffer_data_1[2143:2136] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_266[6] = buffer_data_0[2127:2120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_266[7] = buffer_data_0[2135:2128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_266[8] = buffer_data_0[2143:2136] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_266 = kernel_img_mul_266[0] + kernel_img_mul_266[1] + kernel_img_mul_266[2] + 
                kernel_img_mul_266[3] + kernel_img_mul_266[4] + kernel_img_mul_266[5] + 
                kernel_img_mul_266[6] + kernel_img_mul_266[7] + kernel_img_mul_266[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2135:2128] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2135:2128] <= kernel_img_sum_266[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2135:2128] <= 'd0;
end

wire  [25:0]  kernel_img_mul_267[0:8];
assign kernel_img_mul_267[0] = buffer_data_2[2135:2128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_267[1] = buffer_data_2[2143:2136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_267[2] = buffer_data_2[2151:2144] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_267[3] = buffer_data_1[2135:2128] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_267[4] = buffer_data_1[2143:2136] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_267[5] = buffer_data_1[2151:2144] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_267[6] = buffer_data_0[2135:2128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_267[7] = buffer_data_0[2143:2136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_267[8] = buffer_data_0[2151:2144] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_267 = kernel_img_mul_267[0] + kernel_img_mul_267[1] + kernel_img_mul_267[2] + 
                kernel_img_mul_267[3] + kernel_img_mul_267[4] + kernel_img_mul_267[5] + 
                kernel_img_mul_267[6] + kernel_img_mul_267[7] + kernel_img_mul_267[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2143:2136] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2143:2136] <= kernel_img_sum_267[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2143:2136] <= 'd0;
end

wire  [25:0]  kernel_img_mul_268[0:8];
assign kernel_img_mul_268[0] = buffer_data_2[2143:2136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_268[1] = buffer_data_2[2151:2144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_268[2] = buffer_data_2[2159:2152] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_268[3] = buffer_data_1[2143:2136] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_268[4] = buffer_data_1[2151:2144] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_268[5] = buffer_data_1[2159:2152] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_268[6] = buffer_data_0[2143:2136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_268[7] = buffer_data_0[2151:2144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_268[8] = buffer_data_0[2159:2152] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_268 = kernel_img_mul_268[0] + kernel_img_mul_268[1] + kernel_img_mul_268[2] + 
                kernel_img_mul_268[3] + kernel_img_mul_268[4] + kernel_img_mul_268[5] + 
                kernel_img_mul_268[6] + kernel_img_mul_268[7] + kernel_img_mul_268[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2151:2144] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2151:2144] <= kernel_img_sum_268[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2151:2144] <= 'd0;
end

wire  [25:0]  kernel_img_mul_269[0:8];
assign kernel_img_mul_269[0] = buffer_data_2[2151:2144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_269[1] = buffer_data_2[2159:2152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_269[2] = buffer_data_2[2167:2160] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_269[3] = buffer_data_1[2151:2144] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_269[4] = buffer_data_1[2159:2152] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_269[5] = buffer_data_1[2167:2160] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_269[6] = buffer_data_0[2151:2144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_269[7] = buffer_data_0[2159:2152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_269[8] = buffer_data_0[2167:2160] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_269 = kernel_img_mul_269[0] + kernel_img_mul_269[1] + kernel_img_mul_269[2] + 
                kernel_img_mul_269[3] + kernel_img_mul_269[4] + kernel_img_mul_269[5] + 
                kernel_img_mul_269[6] + kernel_img_mul_269[7] + kernel_img_mul_269[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2159:2152] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2159:2152] <= kernel_img_sum_269[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2159:2152] <= 'd0;
end

wire  [25:0]  kernel_img_mul_270[0:8];
assign kernel_img_mul_270[0] = buffer_data_2[2159:2152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_270[1] = buffer_data_2[2167:2160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_270[2] = buffer_data_2[2175:2168] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_270[3] = buffer_data_1[2159:2152] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_270[4] = buffer_data_1[2167:2160] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_270[5] = buffer_data_1[2175:2168] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_270[6] = buffer_data_0[2159:2152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_270[7] = buffer_data_0[2167:2160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_270[8] = buffer_data_0[2175:2168] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_270 = kernel_img_mul_270[0] + kernel_img_mul_270[1] + kernel_img_mul_270[2] + 
                kernel_img_mul_270[3] + kernel_img_mul_270[4] + kernel_img_mul_270[5] + 
                kernel_img_mul_270[6] + kernel_img_mul_270[7] + kernel_img_mul_270[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2167:2160] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2167:2160] <= kernel_img_sum_270[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2167:2160] <= 'd0;
end

wire  [25:0]  kernel_img_mul_271[0:8];
assign kernel_img_mul_271[0] = buffer_data_2[2167:2160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_271[1] = buffer_data_2[2175:2168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_271[2] = buffer_data_2[2183:2176] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_271[3] = buffer_data_1[2167:2160] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_271[4] = buffer_data_1[2175:2168] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_271[5] = buffer_data_1[2183:2176] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_271[6] = buffer_data_0[2167:2160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_271[7] = buffer_data_0[2175:2168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_271[8] = buffer_data_0[2183:2176] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_271 = kernel_img_mul_271[0] + kernel_img_mul_271[1] + kernel_img_mul_271[2] + 
                kernel_img_mul_271[3] + kernel_img_mul_271[4] + kernel_img_mul_271[5] + 
                kernel_img_mul_271[6] + kernel_img_mul_271[7] + kernel_img_mul_271[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2175:2168] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2175:2168] <= kernel_img_sum_271[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2175:2168] <= 'd0;
end

wire  [25:0]  kernel_img_mul_272[0:8];
assign kernel_img_mul_272[0] = buffer_data_2[2175:2168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_272[1] = buffer_data_2[2183:2176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_272[2] = buffer_data_2[2191:2184] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_272[3] = buffer_data_1[2175:2168] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_272[4] = buffer_data_1[2183:2176] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_272[5] = buffer_data_1[2191:2184] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_272[6] = buffer_data_0[2175:2168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_272[7] = buffer_data_0[2183:2176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_272[8] = buffer_data_0[2191:2184] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_272 = kernel_img_mul_272[0] + kernel_img_mul_272[1] + kernel_img_mul_272[2] + 
                kernel_img_mul_272[3] + kernel_img_mul_272[4] + kernel_img_mul_272[5] + 
                kernel_img_mul_272[6] + kernel_img_mul_272[7] + kernel_img_mul_272[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2183:2176] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2183:2176] <= kernel_img_sum_272[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2183:2176] <= 'd0;
end

wire  [25:0]  kernel_img_mul_273[0:8];
assign kernel_img_mul_273[0] = buffer_data_2[2183:2176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_273[1] = buffer_data_2[2191:2184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_273[2] = buffer_data_2[2199:2192] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_273[3] = buffer_data_1[2183:2176] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_273[4] = buffer_data_1[2191:2184] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_273[5] = buffer_data_1[2199:2192] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_273[6] = buffer_data_0[2183:2176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_273[7] = buffer_data_0[2191:2184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_273[8] = buffer_data_0[2199:2192] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_273 = kernel_img_mul_273[0] + kernel_img_mul_273[1] + kernel_img_mul_273[2] + 
                kernel_img_mul_273[3] + kernel_img_mul_273[4] + kernel_img_mul_273[5] + 
                kernel_img_mul_273[6] + kernel_img_mul_273[7] + kernel_img_mul_273[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2191:2184] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2191:2184] <= kernel_img_sum_273[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2191:2184] <= 'd0;
end

wire  [25:0]  kernel_img_mul_274[0:8];
assign kernel_img_mul_274[0] = buffer_data_2[2191:2184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_274[1] = buffer_data_2[2199:2192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_274[2] = buffer_data_2[2207:2200] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_274[3] = buffer_data_1[2191:2184] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_274[4] = buffer_data_1[2199:2192] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_274[5] = buffer_data_1[2207:2200] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_274[6] = buffer_data_0[2191:2184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_274[7] = buffer_data_0[2199:2192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_274[8] = buffer_data_0[2207:2200] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_274 = kernel_img_mul_274[0] + kernel_img_mul_274[1] + kernel_img_mul_274[2] + 
                kernel_img_mul_274[3] + kernel_img_mul_274[4] + kernel_img_mul_274[5] + 
                kernel_img_mul_274[6] + kernel_img_mul_274[7] + kernel_img_mul_274[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2199:2192] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2199:2192] <= kernel_img_sum_274[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2199:2192] <= 'd0;
end

wire  [25:0]  kernel_img_mul_275[0:8];
assign kernel_img_mul_275[0] = buffer_data_2[2199:2192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_275[1] = buffer_data_2[2207:2200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_275[2] = buffer_data_2[2215:2208] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_275[3] = buffer_data_1[2199:2192] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_275[4] = buffer_data_1[2207:2200] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_275[5] = buffer_data_1[2215:2208] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_275[6] = buffer_data_0[2199:2192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_275[7] = buffer_data_0[2207:2200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_275[8] = buffer_data_0[2215:2208] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_275 = kernel_img_mul_275[0] + kernel_img_mul_275[1] + kernel_img_mul_275[2] + 
                kernel_img_mul_275[3] + kernel_img_mul_275[4] + kernel_img_mul_275[5] + 
                kernel_img_mul_275[6] + kernel_img_mul_275[7] + kernel_img_mul_275[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2207:2200] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2207:2200] <= kernel_img_sum_275[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2207:2200] <= 'd0;
end

wire  [25:0]  kernel_img_mul_276[0:8];
assign kernel_img_mul_276[0] = buffer_data_2[2207:2200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_276[1] = buffer_data_2[2215:2208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_276[2] = buffer_data_2[2223:2216] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_276[3] = buffer_data_1[2207:2200] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_276[4] = buffer_data_1[2215:2208] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_276[5] = buffer_data_1[2223:2216] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_276[6] = buffer_data_0[2207:2200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_276[7] = buffer_data_0[2215:2208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_276[8] = buffer_data_0[2223:2216] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_276 = kernel_img_mul_276[0] + kernel_img_mul_276[1] + kernel_img_mul_276[2] + 
                kernel_img_mul_276[3] + kernel_img_mul_276[4] + kernel_img_mul_276[5] + 
                kernel_img_mul_276[6] + kernel_img_mul_276[7] + kernel_img_mul_276[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2215:2208] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2215:2208] <= kernel_img_sum_276[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2215:2208] <= 'd0;
end

wire  [25:0]  kernel_img_mul_277[0:8];
assign kernel_img_mul_277[0] = buffer_data_2[2215:2208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_277[1] = buffer_data_2[2223:2216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_277[2] = buffer_data_2[2231:2224] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_277[3] = buffer_data_1[2215:2208] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_277[4] = buffer_data_1[2223:2216] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_277[5] = buffer_data_1[2231:2224] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_277[6] = buffer_data_0[2215:2208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_277[7] = buffer_data_0[2223:2216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_277[8] = buffer_data_0[2231:2224] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_277 = kernel_img_mul_277[0] + kernel_img_mul_277[1] + kernel_img_mul_277[2] + 
                kernel_img_mul_277[3] + kernel_img_mul_277[4] + kernel_img_mul_277[5] + 
                kernel_img_mul_277[6] + kernel_img_mul_277[7] + kernel_img_mul_277[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2223:2216] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2223:2216] <= kernel_img_sum_277[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2223:2216] <= 'd0;
end

wire  [25:0]  kernel_img_mul_278[0:8];
assign kernel_img_mul_278[0] = buffer_data_2[2223:2216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_278[1] = buffer_data_2[2231:2224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_278[2] = buffer_data_2[2239:2232] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_278[3] = buffer_data_1[2223:2216] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_278[4] = buffer_data_1[2231:2224] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_278[5] = buffer_data_1[2239:2232] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_278[6] = buffer_data_0[2223:2216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_278[7] = buffer_data_0[2231:2224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_278[8] = buffer_data_0[2239:2232] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_278 = kernel_img_mul_278[0] + kernel_img_mul_278[1] + kernel_img_mul_278[2] + 
                kernel_img_mul_278[3] + kernel_img_mul_278[4] + kernel_img_mul_278[5] + 
                kernel_img_mul_278[6] + kernel_img_mul_278[7] + kernel_img_mul_278[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2231:2224] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2231:2224] <= kernel_img_sum_278[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2231:2224] <= 'd0;
end

wire  [25:0]  kernel_img_mul_279[0:8];
assign kernel_img_mul_279[0] = buffer_data_2[2231:2224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_279[1] = buffer_data_2[2239:2232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_279[2] = buffer_data_2[2247:2240] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_279[3] = buffer_data_1[2231:2224] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_279[4] = buffer_data_1[2239:2232] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_279[5] = buffer_data_1[2247:2240] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_279[6] = buffer_data_0[2231:2224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_279[7] = buffer_data_0[2239:2232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_279[8] = buffer_data_0[2247:2240] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_279 = kernel_img_mul_279[0] + kernel_img_mul_279[1] + kernel_img_mul_279[2] + 
                kernel_img_mul_279[3] + kernel_img_mul_279[4] + kernel_img_mul_279[5] + 
                kernel_img_mul_279[6] + kernel_img_mul_279[7] + kernel_img_mul_279[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2239:2232] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2239:2232] <= kernel_img_sum_279[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2239:2232] <= 'd0;
end

wire  [25:0]  kernel_img_mul_280[0:8];
assign kernel_img_mul_280[0] = buffer_data_2[2239:2232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_280[1] = buffer_data_2[2247:2240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_280[2] = buffer_data_2[2255:2248] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_280[3] = buffer_data_1[2239:2232] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_280[4] = buffer_data_1[2247:2240] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_280[5] = buffer_data_1[2255:2248] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_280[6] = buffer_data_0[2239:2232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_280[7] = buffer_data_0[2247:2240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_280[8] = buffer_data_0[2255:2248] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_280 = kernel_img_mul_280[0] + kernel_img_mul_280[1] + kernel_img_mul_280[2] + 
                kernel_img_mul_280[3] + kernel_img_mul_280[4] + kernel_img_mul_280[5] + 
                kernel_img_mul_280[6] + kernel_img_mul_280[7] + kernel_img_mul_280[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2247:2240] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2247:2240] <= kernel_img_sum_280[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2247:2240] <= 'd0;
end

wire  [25:0]  kernel_img_mul_281[0:8];
assign kernel_img_mul_281[0] = buffer_data_2[2247:2240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_281[1] = buffer_data_2[2255:2248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_281[2] = buffer_data_2[2263:2256] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_281[3] = buffer_data_1[2247:2240] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_281[4] = buffer_data_1[2255:2248] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_281[5] = buffer_data_1[2263:2256] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_281[6] = buffer_data_0[2247:2240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_281[7] = buffer_data_0[2255:2248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_281[8] = buffer_data_0[2263:2256] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_281 = kernel_img_mul_281[0] + kernel_img_mul_281[1] + kernel_img_mul_281[2] + 
                kernel_img_mul_281[3] + kernel_img_mul_281[4] + kernel_img_mul_281[5] + 
                kernel_img_mul_281[6] + kernel_img_mul_281[7] + kernel_img_mul_281[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2255:2248] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2255:2248] <= kernel_img_sum_281[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2255:2248] <= 'd0;
end

wire  [25:0]  kernel_img_mul_282[0:8];
assign kernel_img_mul_282[0] = buffer_data_2[2255:2248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_282[1] = buffer_data_2[2263:2256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_282[2] = buffer_data_2[2271:2264] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_282[3] = buffer_data_1[2255:2248] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_282[4] = buffer_data_1[2263:2256] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_282[5] = buffer_data_1[2271:2264] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_282[6] = buffer_data_0[2255:2248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_282[7] = buffer_data_0[2263:2256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_282[8] = buffer_data_0[2271:2264] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_282 = kernel_img_mul_282[0] + kernel_img_mul_282[1] + kernel_img_mul_282[2] + 
                kernel_img_mul_282[3] + kernel_img_mul_282[4] + kernel_img_mul_282[5] + 
                kernel_img_mul_282[6] + kernel_img_mul_282[7] + kernel_img_mul_282[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2263:2256] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2263:2256] <= kernel_img_sum_282[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2263:2256] <= 'd0;
end

wire  [25:0]  kernel_img_mul_283[0:8];
assign kernel_img_mul_283[0] = buffer_data_2[2263:2256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_283[1] = buffer_data_2[2271:2264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_283[2] = buffer_data_2[2279:2272] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_283[3] = buffer_data_1[2263:2256] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_283[4] = buffer_data_1[2271:2264] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_283[5] = buffer_data_1[2279:2272] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_283[6] = buffer_data_0[2263:2256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_283[7] = buffer_data_0[2271:2264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_283[8] = buffer_data_0[2279:2272] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_283 = kernel_img_mul_283[0] + kernel_img_mul_283[1] + kernel_img_mul_283[2] + 
                kernel_img_mul_283[3] + kernel_img_mul_283[4] + kernel_img_mul_283[5] + 
                kernel_img_mul_283[6] + kernel_img_mul_283[7] + kernel_img_mul_283[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2271:2264] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2271:2264] <= kernel_img_sum_283[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2271:2264] <= 'd0;
end

wire  [25:0]  kernel_img_mul_284[0:8];
assign kernel_img_mul_284[0] = buffer_data_2[2271:2264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_284[1] = buffer_data_2[2279:2272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_284[2] = buffer_data_2[2287:2280] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_284[3] = buffer_data_1[2271:2264] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_284[4] = buffer_data_1[2279:2272] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_284[5] = buffer_data_1[2287:2280] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_284[6] = buffer_data_0[2271:2264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_284[7] = buffer_data_0[2279:2272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_284[8] = buffer_data_0[2287:2280] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_284 = kernel_img_mul_284[0] + kernel_img_mul_284[1] + kernel_img_mul_284[2] + 
                kernel_img_mul_284[3] + kernel_img_mul_284[4] + kernel_img_mul_284[5] + 
                kernel_img_mul_284[6] + kernel_img_mul_284[7] + kernel_img_mul_284[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2279:2272] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2279:2272] <= kernel_img_sum_284[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2279:2272] <= 'd0;
end

wire  [25:0]  kernel_img_mul_285[0:8];
assign kernel_img_mul_285[0] = buffer_data_2[2279:2272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_285[1] = buffer_data_2[2287:2280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_285[2] = buffer_data_2[2295:2288] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_285[3] = buffer_data_1[2279:2272] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_285[4] = buffer_data_1[2287:2280] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_285[5] = buffer_data_1[2295:2288] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_285[6] = buffer_data_0[2279:2272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_285[7] = buffer_data_0[2287:2280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_285[8] = buffer_data_0[2295:2288] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_285 = kernel_img_mul_285[0] + kernel_img_mul_285[1] + kernel_img_mul_285[2] + 
                kernel_img_mul_285[3] + kernel_img_mul_285[4] + kernel_img_mul_285[5] + 
                kernel_img_mul_285[6] + kernel_img_mul_285[7] + kernel_img_mul_285[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2287:2280] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2287:2280] <= kernel_img_sum_285[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2287:2280] <= 'd0;
end

wire  [25:0]  kernel_img_mul_286[0:8];
assign kernel_img_mul_286[0] = buffer_data_2[2287:2280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_286[1] = buffer_data_2[2295:2288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_286[2] = buffer_data_2[2303:2296] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_286[3] = buffer_data_1[2287:2280] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_286[4] = buffer_data_1[2295:2288] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_286[5] = buffer_data_1[2303:2296] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_286[6] = buffer_data_0[2287:2280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_286[7] = buffer_data_0[2295:2288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_286[8] = buffer_data_0[2303:2296] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_286 = kernel_img_mul_286[0] + kernel_img_mul_286[1] + kernel_img_mul_286[2] + 
                kernel_img_mul_286[3] + kernel_img_mul_286[4] + kernel_img_mul_286[5] + 
                kernel_img_mul_286[6] + kernel_img_mul_286[7] + kernel_img_mul_286[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2295:2288] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2295:2288] <= kernel_img_sum_286[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2295:2288] <= 'd0;
end

wire  [25:0]  kernel_img_mul_287[0:8];
assign kernel_img_mul_287[0] = buffer_data_2[2295:2288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_287[1] = buffer_data_2[2303:2296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_287[2] = buffer_data_2[2311:2304] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_287[3] = buffer_data_1[2295:2288] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_287[4] = buffer_data_1[2303:2296] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_287[5] = buffer_data_1[2311:2304] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_287[6] = buffer_data_0[2295:2288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_287[7] = buffer_data_0[2303:2296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_287[8] = buffer_data_0[2311:2304] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_287 = kernel_img_mul_287[0] + kernel_img_mul_287[1] + kernel_img_mul_287[2] + 
                kernel_img_mul_287[3] + kernel_img_mul_287[4] + kernel_img_mul_287[5] + 
                kernel_img_mul_287[6] + kernel_img_mul_287[7] + kernel_img_mul_287[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2303:2296] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2303:2296] <= kernel_img_sum_287[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2303:2296] <= 'd0;
end

wire  [25:0]  kernel_img_mul_288[0:8];
assign kernel_img_mul_288[0] = buffer_data_2[2303:2296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_288[1] = buffer_data_2[2311:2304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_288[2] = buffer_data_2[2319:2312] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_288[3] = buffer_data_1[2303:2296] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_288[4] = buffer_data_1[2311:2304] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_288[5] = buffer_data_1[2319:2312] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_288[6] = buffer_data_0[2303:2296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_288[7] = buffer_data_0[2311:2304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_288[8] = buffer_data_0[2319:2312] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_288 = kernel_img_mul_288[0] + kernel_img_mul_288[1] + kernel_img_mul_288[2] + 
                kernel_img_mul_288[3] + kernel_img_mul_288[4] + kernel_img_mul_288[5] + 
                kernel_img_mul_288[6] + kernel_img_mul_288[7] + kernel_img_mul_288[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2311:2304] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2311:2304] <= kernel_img_sum_288[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2311:2304] <= 'd0;
end

wire  [25:0]  kernel_img_mul_289[0:8];
assign kernel_img_mul_289[0] = buffer_data_2[2311:2304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_289[1] = buffer_data_2[2319:2312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_289[2] = buffer_data_2[2327:2320] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_289[3] = buffer_data_1[2311:2304] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_289[4] = buffer_data_1[2319:2312] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_289[5] = buffer_data_1[2327:2320] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_289[6] = buffer_data_0[2311:2304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_289[7] = buffer_data_0[2319:2312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_289[8] = buffer_data_0[2327:2320] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_289 = kernel_img_mul_289[0] + kernel_img_mul_289[1] + kernel_img_mul_289[2] + 
                kernel_img_mul_289[3] + kernel_img_mul_289[4] + kernel_img_mul_289[5] + 
                kernel_img_mul_289[6] + kernel_img_mul_289[7] + kernel_img_mul_289[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2319:2312] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2319:2312] <= kernel_img_sum_289[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2319:2312] <= 'd0;
end

wire  [25:0]  kernel_img_mul_290[0:8];
assign kernel_img_mul_290[0] = buffer_data_2[2319:2312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_290[1] = buffer_data_2[2327:2320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_290[2] = buffer_data_2[2335:2328] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_290[3] = buffer_data_1[2319:2312] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_290[4] = buffer_data_1[2327:2320] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_290[5] = buffer_data_1[2335:2328] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_290[6] = buffer_data_0[2319:2312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_290[7] = buffer_data_0[2327:2320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_290[8] = buffer_data_0[2335:2328] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_290 = kernel_img_mul_290[0] + kernel_img_mul_290[1] + kernel_img_mul_290[2] + 
                kernel_img_mul_290[3] + kernel_img_mul_290[4] + kernel_img_mul_290[5] + 
                kernel_img_mul_290[6] + kernel_img_mul_290[7] + kernel_img_mul_290[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2327:2320] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2327:2320] <= kernel_img_sum_290[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2327:2320] <= 'd0;
end

wire  [25:0]  kernel_img_mul_291[0:8];
assign kernel_img_mul_291[0] = buffer_data_2[2327:2320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_291[1] = buffer_data_2[2335:2328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_291[2] = buffer_data_2[2343:2336] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_291[3] = buffer_data_1[2327:2320] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_291[4] = buffer_data_1[2335:2328] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_291[5] = buffer_data_1[2343:2336] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_291[6] = buffer_data_0[2327:2320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_291[7] = buffer_data_0[2335:2328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_291[8] = buffer_data_0[2343:2336] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_291 = kernel_img_mul_291[0] + kernel_img_mul_291[1] + kernel_img_mul_291[2] + 
                kernel_img_mul_291[3] + kernel_img_mul_291[4] + kernel_img_mul_291[5] + 
                kernel_img_mul_291[6] + kernel_img_mul_291[7] + kernel_img_mul_291[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2335:2328] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2335:2328] <= kernel_img_sum_291[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2335:2328] <= 'd0;
end

wire  [25:0]  kernel_img_mul_292[0:8];
assign kernel_img_mul_292[0] = buffer_data_2[2335:2328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_292[1] = buffer_data_2[2343:2336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_292[2] = buffer_data_2[2351:2344] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_292[3] = buffer_data_1[2335:2328] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_292[4] = buffer_data_1[2343:2336] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_292[5] = buffer_data_1[2351:2344] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_292[6] = buffer_data_0[2335:2328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_292[7] = buffer_data_0[2343:2336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_292[8] = buffer_data_0[2351:2344] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_292 = kernel_img_mul_292[0] + kernel_img_mul_292[1] + kernel_img_mul_292[2] + 
                kernel_img_mul_292[3] + kernel_img_mul_292[4] + kernel_img_mul_292[5] + 
                kernel_img_mul_292[6] + kernel_img_mul_292[7] + kernel_img_mul_292[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2343:2336] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2343:2336] <= kernel_img_sum_292[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2343:2336] <= 'd0;
end

wire  [25:0]  kernel_img_mul_293[0:8];
assign kernel_img_mul_293[0] = buffer_data_2[2343:2336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_293[1] = buffer_data_2[2351:2344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_293[2] = buffer_data_2[2359:2352] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_293[3] = buffer_data_1[2343:2336] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_293[4] = buffer_data_1[2351:2344] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_293[5] = buffer_data_1[2359:2352] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_293[6] = buffer_data_0[2343:2336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_293[7] = buffer_data_0[2351:2344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_293[8] = buffer_data_0[2359:2352] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_293 = kernel_img_mul_293[0] + kernel_img_mul_293[1] + kernel_img_mul_293[2] + 
                kernel_img_mul_293[3] + kernel_img_mul_293[4] + kernel_img_mul_293[5] + 
                kernel_img_mul_293[6] + kernel_img_mul_293[7] + kernel_img_mul_293[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2351:2344] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2351:2344] <= kernel_img_sum_293[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2351:2344] <= 'd0;
end

wire  [25:0]  kernel_img_mul_294[0:8];
assign kernel_img_mul_294[0] = buffer_data_2[2351:2344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_294[1] = buffer_data_2[2359:2352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_294[2] = buffer_data_2[2367:2360] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_294[3] = buffer_data_1[2351:2344] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_294[4] = buffer_data_1[2359:2352] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_294[5] = buffer_data_1[2367:2360] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_294[6] = buffer_data_0[2351:2344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_294[7] = buffer_data_0[2359:2352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_294[8] = buffer_data_0[2367:2360] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_294 = kernel_img_mul_294[0] + kernel_img_mul_294[1] + kernel_img_mul_294[2] + 
                kernel_img_mul_294[3] + kernel_img_mul_294[4] + kernel_img_mul_294[5] + 
                kernel_img_mul_294[6] + kernel_img_mul_294[7] + kernel_img_mul_294[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2359:2352] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2359:2352] <= kernel_img_sum_294[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2359:2352] <= 'd0;
end

wire  [25:0]  kernel_img_mul_295[0:8];
assign kernel_img_mul_295[0] = buffer_data_2[2359:2352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_295[1] = buffer_data_2[2367:2360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_295[2] = buffer_data_2[2375:2368] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_295[3] = buffer_data_1[2359:2352] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_295[4] = buffer_data_1[2367:2360] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_295[5] = buffer_data_1[2375:2368] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_295[6] = buffer_data_0[2359:2352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_295[7] = buffer_data_0[2367:2360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_295[8] = buffer_data_0[2375:2368] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_295 = kernel_img_mul_295[0] + kernel_img_mul_295[1] + kernel_img_mul_295[2] + 
                kernel_img_mul_295[3] + kernel_img_mul_295[4] + kernel_img_mul_295[5] + 
                kernel_img_mul_295[6] + kernel_img_mul_295[7] + kernel_img_mul_295[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2367:2360] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2367:2360] <= kernel_img_sum_295[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2367:2360] <= 'd0;
end

wire  [25:0]  kernel_img_mul_296[0:8];
assign kernel_img_mul_296[0] = buffer_data_2[2367:2360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_296[1] = buffer_data_2[2375:2368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_296[2] = buffer_data_2[2383:2376] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_296[3] = buffer_data_1[2367:2360] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_296[4] = buffer_data_1[2375:2368] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_296[5] = buffer_data_1[2383:2376] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_296[6] = buffer_data_0[2367:2360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_296[7] = buffer_data_0[2375:2368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_296[8] = buffer_data_0[2383:2376] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_296 = kernel_img_mul_296[0] + kernel_img_mul_296[1] + kernel_img_mul_296[2] + 
                kernel_img_mul_296[3] + kernel_img_mul_296[4] + kernel_img_mul_296[5] + 
                kernel_img_mul_296[6] + kernel_img_mul_296[7] + kernel_img_mul_296[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2375:2368] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2375:2368] <= kernel_img_sum_296[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2375:2368] <= 'd0;
end

wire  [25:0]  kernel_img_mul_297[0:8];
assign kernel_img_mul_297[0] = buffer_data_2[2375:2368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_297[1] = buffer_data_2[2383:2376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_297[2] = buffer_data_2[2391:2384] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_297[3] = buffer_data_1[2375:2368] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_297[4] = buffer_data_1[2383:2376] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_297[5] = buffer_data_1[2391:2384] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_297[6] = buffer_data_0[2375:2368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_297[7] = buffer_data_0[2383:2376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_297[8] = buffer_data_0[2391:2384] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_297 = kernel_img_mul_297[0] + kernel_img_mul_297[1] + kernel_img_mul_297[2] + 
                kernel_img_mul_297[3] + kernel_img_mul_297[4] + kernel_img_mul_297[5] + 
                kernel_img_mul_297[6] + kernel_img_mul_297[7] + kernel_img_mul_297[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2383:2376] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2383:2376] <= kernel_img_sum_297[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2383:2376] <= 'd0;
end

wire  [25:0]  kernel_img_mul_298[0:8];
assign kernel_img_mul_298[0] = buffer_data_2[2383:2376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_298[1] = buffer_data_2[2391:2384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_298[2] = buffer_data_2[2399:2392] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_298[3] = buffer_data_1[2383:2376] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_298[4] = buffer_data_1[2391:2384] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_298[5] = buffer_data_1[2399:2392] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_298[6] = buffer_data_0[2383:2376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_298[7] = buffer_data_0[2391:2384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_298[8] = buffer_data_0[2399:2392] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_298 = kernel_img_mul_298[0] + kernel_img_mul_298[1] + kernel_img_mul_298[2] + 
                kernel_img_mul_298[3] + kernel_img_mul_298[4] + kernel_img_mul_298[5] + 
                kernel_img_mul_298[6] + kernel_img_mul_298[7] + kernel_img_mul_298[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2391:2384] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2391:2384] <= kernel_img_sum_298[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2391:2384] <= 'd0;
end

wire  [25:0]  kernel_img_mul_299[0:8];
assign kernel_img_mul_299[0] = buffer_data_2[2391:2384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_299[1] = buffer_data_2[2399:2392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_299[2] = buffer_data_2[2407:2400] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_299[3] = buffer_data_1[2391:2384] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_299[4] = buffer_data_1[2399:2392] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_299[5] = buffer_data_1[2407:2400] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_299[6] = buffer_data_0[2391:2384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_299[7] = buffer_data_0[2399:2392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_299[8] = buffer_data_0[2407:2400] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_299 = kernel_img_mul_299[0] + kernel_img_mul_299[1] + kernel_img_mul_299[2] + 
                kernel_img_mul_299[3] + kernel_img_mul_299[4] + kernel_img_mul_299[5] + 
                kernel_img_mul_299[6] + kernel_img_mul_299[7] + kernel_img_mul_299[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2399:2392] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2399:2392] <= kernel_img_sum_299[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2399:2392] <= 'd0;
end

wire  [25:0]  kernel_img_mul_300[0:8];
assign kernel_img_mul_300[0] = buffer_data_2[2399:2392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_300[1] = buffer_data_2[2407:2400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_300[2] = buffer_data_2[2415:2408] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_300[3] = buffer_data_1[2399:2392] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_300[4] = buffer_data_1[2407:2400] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_300[5] = buffer_data_1[2415:2408] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_300[6] = buffer_data_0[2399:2392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_300[7] = buffer_data_0[2407:2400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_300[8] = buffer_data_0[2415:2408] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_300 = kernel_img_mul_300[0] + kernel_img_mul_300[1] + kernel_img_mul_300[2] + 
                kernel_img_mul_300[3] + kernel_img_mul_300[4] + kernel_img_mul_300[5] + 
                kernel_img_mul_300[6] + kernel_img_mul_300[7] + kernel_img_mul_300[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2407:2400] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2407:2400] <= kernel_img_sum_300[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2407:2400] <= 'd0;
end

wire  [25:0]  kernel_img_mul_301[0:8];
assign kernel_img_mul_301[0] = buffer_data_2[2407:2400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_301[1] = buffer_data_2[2415:2408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_301[2] = buffer_data_2[2423:2416] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_301[3] = buffer_data_1[2407:2400] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_301[4] = buffer_data_1[2415:2408] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_301[5] = buffer_data_1[2423:2416] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_301[6] = buffer_data_0[2407:2400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_301[7] = buffer_data_0[2415:2408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_301[8] = buffer_data_0[2423:2416] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_301 = kernel_img_mul_301[0] + kernel_img_mul_301[1] + kernel_img_mul_301[2] + 
                kernel_img_mul_301[3] + kernel_img_mul_301[4] + kernel_img_mul_301[5] + 
                kernel_img_mul_301[6] + kernel_img_mul_301[7] + kernel_img_mul_301[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2415:2408] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2415:2408] <= kernel_img_sum_301[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2415:2408] <= 'd0;
end

wire  [25:0]  kernel_img_mul_302[0:8];
assign kernel_img_mul_302[0] = buffer_data_2[2415:2408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_302[1] = buffer_data_2[2423:2416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_302[2] = buffer_data_2[2431:2424] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_302[3] = buffer_data_1[2415:2408] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_302[4] = buffer_data_1[2423:2416] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_302[5] = buffer_data_1[2431:2424] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_302[6] = buffer_data_0[2415:2408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_302[7] = buffer_data_0[2423:2416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_302[8] = buffer_data_0[2431:2424] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_302 = kernel_img_mul_302[0] + kernel_img_mul_302[1] + kernel_img_mul_302[2] + 
                kernel_img_mul_302[3] + kernel_img_mul_302[4] + kernel_img_mul_302[5] + 
                kernel_img_mul_302[6] + kernel_img_mul_302[7] + kernel_img_mul_302[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2423:2416] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2423:2416] <= kernel_img_sum_302[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2423:2416] <= 'd0;
end

wire  [25:0]  kernel_img_mul_303[0:8];
assign kernel_img_mul_303[0] = buffer_data_2[2423:2416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_303[1] = buffer_data_2[2431:2424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_303[2] = buffer_data_2[2439:2432] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_303[3] = buffer_data_1[2423:2416] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_303[4] = buffer_data_1[2431:2424] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_303[5] = buffer_data_1[2439:2432] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_303[6] = buffer_data_0[2423:2416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_303[7] = buffer_data_0[2431:2424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_303[8] = buffer_data_0[2439:2432] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_303 = kernel_img_mul_303[0] + kernel_img_mul_303[1] + kernel_img_mul_303[2] + 
                kernel_img_mul_303[3] + kernel_img_mul_303[4] + kernel_img_mul_303[5] + 
                kernel_img_mul_303[6] + kernel_img_mul_303[7] + kernel_img_mul_303[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2431:2424] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2431:2424] <= kernel_img_sum_303[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2431:2424] <= 'd0;
end

wire  [25:0]  kernel_img_mul_304[0:8];
assign kernel_img_mul_304[0] = buffer_data_2[2431:2424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_304[1] = buffer_data_2[2439:2432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_304[2] = buffer_data_2[2447:2440] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_304[3] = buffer_data_1[2431:2424] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_304[4] = buffer_data_1[2439:2432] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_304[5] = buffer_data_1[2447:2440] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_304[6] = buffer_data_0[2431:2424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_304[7] = buffer_data_0[2439:2432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_304[8] = buffer_data_0[2447:2440] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_304 = kernel_img_mul_304[0] + kernel_img_mul_304[1] + kernel_img_mul_304[2] + 
                kernel_img_mul_304[3] + kernel_img_mul_304[4] + kernel_img_mul_304[5] + 
                kernel_img_mul_304[6] + kernel_img_mul_304[7] + kernel_img_mul_304[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2439:2432] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2439:2432] <= kernel_img_sum_304[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2439:2432] <= 'd0;
end

wire  [25:0]  kernel_img_mul_305[0:8];
assign kernel_img_mul_305[0] = buffer_data_2[2439:2432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_305[1] = buffer_data_2[2447:2440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_305[2] = buffer_data_2[2455:2448] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_305[3] = buffer_data_1[2439:2432] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_305[4] = buffer_data_1[2447:2440] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_305[5] = buffer_data_1[2455:2448] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_305[6] = buffer_data_0[2439:2432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_305[7] = buffer_data_0[2447:2440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_305[8] = buffer_data_0[2455:2448] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_305 = kernel_img_mul_305[0] + kernel_img_mul_305[1] + kernel_img_mul_305[2] + 
                kernel_img_mul_305[3] + kernel_img_mul_305[4] + kernel_img_mul_305[5] + 
                kernel_img_mul_305[6] + kernel_img_mul_305[7] + kernel_img_mul_305[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2447:2440] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2447:2440] <= kernel_img_sum_305[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2447:2440] <= 'd0;
end

wire  [25:0]  kernel_img_mul_306[0:8];
assign kernel_img_mul_306[0] = buffer_data_2[2447:2440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_306[1] = buffer_data_2[2455:2448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_306[2] = buffer_data_2[2463:2456] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_306[3] = buffer_data_1[2447:2440] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_306[4] = buffer_data_1[2455:2448] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_306[5] = buffer_data_1[2463:2456] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_306[6] = buffer_data_0[2447:2440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_306[7] = buffer_data_0[2455:2448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_306[8] = buffer_data_0[2463:2456] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_306 = kernel_img_mul_306[0] + kernel_img_mul_306[1] + kernel_img_mul_306[2] + 
                kernel_img_mul_306[3] + kernel_img_mul_306[4] + kernel_img_mul_306[5] + 
                kernel_img_mul_306[6] + kernel_img_mul_306[7] + kernel_img_mul_306[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2455:2448] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2455:2448] <= kernel_img_sum_306[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2455:2448] <= 'd0;
end

wire  [25:0]  kernel_img_mul_307[0:8];
assign kernel_img_mul_307[0] = buffer_data_2[2455:2448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_307[1] = buffer_data_2[2463:2456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_307[2] = buffer_data_2[2471:2464] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_307[3] = buffer_data_1[2455:2448] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_307[4] = buffer_data_1[2463:2456] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_307[5] = buffer_data_1[2471:2464] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_307[6] = buffer_data_0[2455:2448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_307[7] = buffer_data_0[2463:2456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_307[8] = buffer_data_0[2471:2464] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_307 = kernel_img_mul_307[0] + kernel_img_mul_307[1] + kernel_img_mul_307[2] + 
                kernel_img_mul_307[3] + kernel_img_mul_307[4] + kernel_img_mul_307[5] + 
                kernel_img_mul_307[6] + kernel_img_mul_307[7] + kernel_img_mul_307[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2463:2456] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2463:2456] <= kernel_img_sum_307[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2463:2456] <= 'd0;
end

wire  [25:0]  kernel_img_mul_308[0:8];
assign kernel_img_mul_308[0] = buffer_data_2[2463:2456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_308[1] = buffer_data_2[2471:2464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_308[2] = buffer_data_2[2479:2472] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_308[3] = buffer_data_1[2463:2456] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_308[4] = buffer_data_1[2471:2464] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_308[5] = buffer_data_1[2479:2472] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_308[6] = buffer_data_0[2463:2456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_308[7] = buffer_data_0[2471:2464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_308[8] = buffer_data_0[2479:2472] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_308 = kernel_img_mul_308[0] + kernel_img_mul_308[1] + kernel_img_mul_308[2] + 
                kernel_img_mul_308[3] + kernel_img_mul_308[4] + kernel_img_mul_308[5] + 
                kernel_img_mul_308[6] + kernel_img_mul_308[7] + kernel_img_mul_308[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2471:2464] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2471:2464] <= kernel_img_sum_308[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2471:2464] <= 'd0;
end

wire  [25:0]  kernel_img_mul_309[0:8];
assign kernel_img_mul_309[0] = buffer_data_2[2471:2464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_309[1] = buffer_data_2[2479:2472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_309[2] = buffer_data_2[2487:2480] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_309[3] = buffer_data_1[2471:2464] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_309[4] = buffer_data_1[2479:2472] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_309[5] = buffer_data_1[2487:2480] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_309[6] = buffer_data_0[2471:2464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_309[7] = buffer_data_0[2479:2472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_309[8] = buffer_data_0[2487:2480] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_309 = kernel_img_mul_309[0] + kernel_img_mul_309[1] + kernel_img_mul_309[2] + 
                kernel_img_mul_309[3] + kernel_img_mul_309[4] + kernel_img_mul_309[5] + 
                kernel_img_mul_309[6] + kernel_img_mul_309[7] + kernel_img_mul_309[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2479:2472] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2479:2472] <= kernel_img_sum_309[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2479:2472] <= 'd0;
end

wire  [25:0]  kernel_img_mul_310[0:8];
assign kernel_img_mul_310[0] = buffer_data_2[2479:2472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_310[1] = buffer_data_2[2487:2480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_310[2] = buffer_data_2[2495:2488] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_310[3] = buffer_data_1[2479:2472] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_310[4] = buffer_data_1[2487:2480] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_310[5] = buffer_data_1[2495:2488] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_310[6] = buffer_data_0[2479:2472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_310[7] = buffer_data_0[2487:2480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_310[8] = buffer_data_0[2495:2488] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_310 = kernel_img_mul_310[0] + kernel_img_mul_310[1] + kernel_img_mul_310[2] + 
                kernel_img_mul_310[3] + kernel_img_mul_310[4] + kernel_img_mul_310[5] + 
                kernel_img_mul_310[6] + kernel_img_mul_310[7] + kernel_img_mul_310[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2487:2480] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2487:2480] <= kernel_img_sum_310[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2487:2480] <= 'd0;
end

wire  [25:0]  kernel_img_mul_311[0:8];
assign kernel_img_mul_311[0] = buffer_data_2[2487:2480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_311[1] = buffer_data_2[2495:2488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_311[2] = buffer_data_2[2503:2496] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_311[3] = buffer_data_1[2487:2480] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_311[4] = buffer_data_1[2495:2488] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_311[5] = buffer_data_1[2503:2496] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_311[6] = buffer_data_0[2487:2480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_311[7] = buffer_data_0[2495:2488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_311[8] = buffer_data_0[2503:2496] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_311 = kernel_img_mul_311[0] + kernel_img_mul_311[1] + kernel_img_mul_311[2] + 
                kernel_img_mul_311[3] + kernel_img_mul_311[4] + kernel_img_mul_311[5] + 
                kernel_img_mul_311[6] + kernel_img_mul_311[7] + kernel_img_mul_311[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2495:2488] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2495:2488] <= kernel_img_sum_311[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2495:2488] <= 'd0;
end

wire  [25:0]  kernel_img_mul_312[0:8];
assign kernel_img_mul_312[0] = buffer_data_2[2495:2488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_312[1] = buffer_data_2[2503:2496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_312[2] = buffer_data_2[2511:2504] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_312[3] = buffer_data_1[2495:2488] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_312[4] = buffer_data_1[2503:2496] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_312[5] = buffer_data_1[2511:2504] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_312[6] = buffer_data_0[2495:2488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_312[7] = buffer_data_0[2503:2496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_312[8] = buffer_data_0[2511:2504] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_312 = kernel_img_mul_312[0] + kernel_img_mul_312[1] + kernel_img_mul_312[2] + 
                kernel_img_mul_312[3] + kernel_img_mul_312[4] + kernel_img_mul_312[5] + 
                kernel_img_mul_312[6] + kernel_img_mul_312[7] + kernel_img_mul_312[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2503:2496] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2503:2496] <= kernel_img_sum_312[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2503:2496] <= 'd0;
end

wire  [25:0]  kernel_img_mul_313[0:8];
assign kernel_img_mul_313[0] = buffer_data_2[2503:2496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_313[1] = buffer_data_2[2511:2504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_313[2] = buffer_data_2[2519:2512] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_313[3] = buffer_data_1[2503:2496] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_313[4] = buffer_data_1[2511:2504] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_313[5] = buffer_data_1[2519:2512] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_313[6] = buffer_data_0[2503:2496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_313[7] = buffer_data_0[2511:2504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_313[8] = buffer_data_0[2519:2512] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_313 = kernel_img_mul_313[0] + kernel_img_mul_313[1] + kernel_img_mul_313[2] + 
                kernel_img_mul_313[3] + kernel_img_mul_313[4] + kernel_img_mul_313[5] + 
                kernel_img_mul_313[6] + kernel_img_mul_313[7] + kernel_img_mul_313[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2511:2504] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2511:2504] <= kernel_img_sum_313[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2511:2504] <= 'd0;
end

wire  [25:0]  kernel_img_mul_314[0:8];
assign kernel_img_mul_314[0] = buffer_data_2[2511:2504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_314[1] = buffer_data_2[2519:2512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_314[2] = buffer_data_2[2527:2520] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_314[3] = buffer_data_1[2511:2504] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_314[4] = buffer_data_1[2519:2512] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_314[5] = buffer_data_1[2527:2520] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_314[6] = buffer_data_0[2511:2504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_314[7] = buffer_data_0[2519:2512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_314[8] = buffer_data_0[2527:2520] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_314 = kernel_img_mul_314[0] + kernel_img_mul_314[1] + kernel_img_mul_314[2] + 
                kernel_img_mul_314[3] + kernel_img_mul_314[4] + kernel_img_mul_314[5] + 
                kernel_img_mul_314[6] + kernel_img_mul_314[7] + kernel_img_mul_314[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2519:2512] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2519:2512] <= kernel_img_sum_314[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2519:2512] <= 'd0;
end

wire  [25:0]  kernel_img_mul_315[0:8];
assign kernel_img_mul_315[0] = buffer_data_2[2519:2512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_315[1] = buffer_data_2[2527:2520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_315[2] = buffer_data_2[2535:2528] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_315[3] = buffer_data_1[2519:2512] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_315[4] = buffer_data_1[2527:2520] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_315[5] = buffer_data_1[2535:2528] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_315[6] = buffer_data_0[2519:2512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_315[7] = buffer_data_0[2527:2520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_315[8] = buffer_data_0[2535:2528] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_315 = kernel_img_mul_315[0] + kernel_img_mul_315[1] + kernel_img_mul_315[2] + 
                kernel_img_mul_315[3] + kernel_img_mul_315[4] + kernel_img_mul_315[5] + 
                kernel_img_mul_315[6] + kernel_img_mul_315[7] + kernel_img_mul_315[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2527:2520] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2527:2520] <= kernel_img_sum_315[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2527:2520] <= 'd0;
end

wire  [25:0]  kernel_img_mul_316[0:8];
assign kernel_img_mul_316[0] = buffer_data_2[2527:2520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_316[1] = buffer_data_2[2535:2528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_316[2] = buffer_data_2[2543:2536] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_316[3] = buffer_data_1[2527:2520] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_316[4] = buffer_data_1[2535:2528] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_316[5] = buffer_data_1[2543:2536] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_316[6] = buffer_data_0[2527:2520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_316[7] = buffer_data_0[2535:2528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_316[8] = buffer_data_0[2543:2536] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_316 = kernel_img_mul_316[0] + kernel_img_mul_316[1] + kernel_img_mul_316[2] + 
                kernel_img_mul_316[3] + kernel_img_mul_316[4] + kernel_img_mul_316[5] + 
                kernel_img_mul_316[6] + kernel_img_mul_316[7] + kernel_img_mul_316[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2535:2528] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2535:2528] <= kernel_img_sum_316[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2535:2528] <= 'd0;
end

wire  [25:0]  kernel_img_mul_317[0:8];
assign kernel_img_mul_317[0] = buffer_data_2[2535:2528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_317[1] = buffer_data_2[2543:2536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_317[2] = buffer_data_2[2551:2544] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_317[3] = buffer_data_1[2535:2528] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_317[4] = buffer_data_1[2543:2536] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_317[5] = buffer_data_1[2551:2544] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_317[6] = buffer_data_0[2535:2528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_317[7] = buffer_data_0[2543:2536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_317[8] = buffer_data_0[2551:2544] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_317 = kernel_img_mul_317[0] + kernel_img_mul_317[1] + kernel_img_mul_317[2] + 
                kernel_img_mul_317[3] + kernel_img_mul_317[4] + kernel_img_mul_317[5] + 
                kernel_img_mul_317[6] + kernel_img_mul_317[7] + kernel_img_mul_317[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2543:2536] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2543:2536] <= kernel_img_sum_317[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2543:2536] <= 'd0;
end

wire  [25:0]  kernel_img_mul_318[0:8];
assign kernel_img_mul_318[0] = buffer_data_2[2543:2536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_318[1] = buffer_data_2[2551:2544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_318[2] = buffer_data_2[2559:2552] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_318[3] = buffer_data_1[2543:2536] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_318[4] = buffer_data_1[2551:2544] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_318[5] = buffer_data_1[2559:2552] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_318[6] = buffer_data_0[2543:2536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_318[7] = buffer_data_0[2551:2544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_318[8] = buffer_data_0[2559:2552] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_318 = kernel_img_mul_318[0] + kernel_img_mul_318[1] + kernel_img_mul_318[2] + 
                kernel_img_mul_318[3] + kernel_img_mul_318[4] + kernel_img_mul_318[5] + 
                kernel_img_mul_318[6] + kernel_img_mul_318[7] + kernel_img_mul_318[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2551:2544] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2551:2544] <= kernel_img_sum_318[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2551:2544] <= 'd0;
end

wire  [25:0]  kernel_img_mul_319[0:8];
assign kernel_img_mul_319[0] = buffer_data_2[2551:2544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_319[1] = buffer_data_2[2559:2552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_319[2] = buffer_data_2[2567:2560] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_319[3] = buffer_data_1[2551:2544] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_319[4] = buffer_data_1[2559:2552] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_319[5] = buffer_data_1[2567:2560] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_319[6] = buffer_data_0[2551:2544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_319[7] = buffer_data_0[2559:2552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_319[8] = buffer_data_0[2567:2560] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_319 = kernel_img_mul_319[0] + kernel_img_mul_319[1] + kernel_img_mul_319[2] + 
                kernel_img_mul_319[3] + kernel_img_mul_319[4] + kernel_img_mul_319[5] + 
                kernel_img_mul_319[6] + kernel_img_mul_319[7] + kernel_img_mul_319[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2559:2552] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2559:2552] <= kernel_img_sum_319[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2559:2552] <= 'd0;
end

wire  [25:0]  kernel_img_mul_320[0:8];
assign kernel_img_mul_320[0] = buffer_data_2[2559:2552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_320[1] = buffer_data_2[2567:2560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_320[2] = buffer_data_2[2575:2568] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_320[3] = buffer_data_1[2559:2552] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_320[4] = buffer_data_1[2567:2560] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_320[5] = buffer_data_1[2575:2568] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_320[6] = buffer_data_0[2559:2552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_320[7] = buffer_data_0[2567:2560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_320[8] = buffer_data_0[2575:2568] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_320 = kernel_img_mul_320[0] + kernel_img_mul_320[1] + kernel_img_mul_320[2] + 
                kernel_img_mul_320[3] + kernel_img_mul_320[4] + kernel_img_mul_320[5] + 
                kernel_img_mul_320[6] + kernel_img_mul_320[7] + kernel_img_mul_320[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2567:2560] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2567:2560] <= kernel_img_sum_320[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2567:2560] <= 'd0;
end

wire  [25:0]  kernel_img_mul_321[0:8];
assign kernel_img_mul_321[0] = buffer_data_2[2567:2560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_321[1] = buffer_data_2[2575:2568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_321[2] = buffer_data_2[2583:2576] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_321[3] = buffer_data_1[2567:2560] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_321[4] = buffer_data_1[2575:2568] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_321[5] = buffer_data_1[2583:2576] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_321[6] = buffer_data_0[2567:2560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_321[7] = buffer_data_0[2575:2568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_321[8] = buffer_data_0[2583:2576] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_321 = kernel_img_mul_321[0] + kernel_img_mul_321[1] + kernel_img_mul_321[2] + 
                kernel_img_mul_321[3] + kernel_img_mul_321[4] + kernel_img_mul_321[5] + 
                kernel_img_mul_321[6] + kernel_img_mul_321[7] + kernel_img_mul_321[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2575:2568] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2575:2568] <= kernel_img_sum_321[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2575:2568] <= 'd0;
end

wire  [25:0]  kernel_img_mul_322[0:8];
assign kernel_img_mul_322[0] = buffer_data_2[2575:2568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_322[1] = buffer_data_2[2583:2576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_322[2] = buffer_data_2[2591:2584] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_322[3] = buffer_data_1[2575:2568] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_322[4] = buffer_data_1[2583:2576] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_322[5] = buffer_data_1[2591:2584] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_322[6] = buffer_data_0[2575:2568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_322[7] = buffer_data_0[2583:2576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_322[8] = buffer_data_0[2591:2584] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_322 = kernel_img_mul_322[0] + kernel_img_mul_322[1] + kernel_img_mul_322[2] + 
                kernel_img_mul_322[3] + kernel_img_mul_322[4] + kernel_img_mul_322[5] + 
                kernel_img_mul_322[6] + kernel_img_mul_322[7] + kernel_img_mul_322[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2583:2576] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2583:2576] <= kernel_img_sum_322[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2583:2576] <= 'd0;
end

wire  [25:0]  kernel_img_mul_323[0:8];
assign kernel_img_mul_323[0] = buffer_data_2[2583:2576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_323[1] = buffer_data_2[2591:2584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_323[2] = buffer_data_2[2599:2592] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_323[3] = buffer_data_1[2583:2576] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_323[4] = buffer_data_1[2591:2584] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_323[5] = buffer_data_1[2599:2592] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_323[6] = buffer_data_0[2583:2576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_323[7] = buffer_data_0[2591:2584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_323[8] = buffer_data_0[2599:2592] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_323 = kernel_img_mul_323[0] + kernel_img_mul_323[1] + kernel_img_mul_323[2] + 
                kernel_img_mul_323[3] + kernel_img_mul_323[4] + kernel_img_mul_323[5] + 
                kernel_img_mul_323[6] + kernel_img_mul_323[7] + kernel_img_mul_323[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2591:2584] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2591:2584] <= kernel_img_sum_323[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2591:2584] <= 'd0;
end

wire  [25:0]  kernel_img_mul_324[0:8];
assign kernel_img_mul_324[0] = buffer_data_2[2591:2584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_324[1] = buffer_data_2[2599:2592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_324[2] = buffer_data_2[2607:2600] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_324[3] = buffer_data_1[2591:2584] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_324[4] = buffer_data_1[2599:2592] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_324[5] = buffer_data_1[2607:2600] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_324[6] = buffer_data_0[2591:2584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_324[7] = buffer_data_0[2599:2592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_324[8] = buffer_data_0[2607:2600] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_324 = kernel_img_mul_324[0] + kernel_img_mul_324[1] + kernel_img_mul_324[2] + 
                kernel_img_mul_324[3] + kernel_img_mul_324[4] + kernel_img_mul_324[5] + 
                kernel_img_mul_324[6] + kernel_img_mul_324[7] + kernel_img_mul_324[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2599:2592] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2599:2592] <= kernel_img_sum_324[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2599:2592] <= 'd0;
end

wire  [25:0]  kernel_img_mul_325[0:8];
assign kernel_img_mul_325[0] = buffer_data_2[2599:2592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_325[1] = buffer_data_2[2607:2600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_325[2] = buffer_data_2[2615:2608] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_325[3] = buffer_data_1[2599:2592] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_325[4] = buffer_data_1[2607:2600] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_325[5] = buffer_data_1[2615:2608] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_325[6] = buffer_data_0[2599:2592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_325[7] = buffer_data_0[2607:2600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_325[8] = buffer_data_0[2615:2608] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_325 = kernel_img_mul_325[0] + kernel_img_mul_325[1] + kernel_img_mul_325[2] + 
                kernel_img_mul_325[3] + kernel_img_mul_325[4] + kernel_img_mul_325[5] + 
                kernel_img_mul_325[6] + kernel_img_mul_325[7] + kernel_img_mul_325[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2607:2600] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2607:2600] <= kernel_img_sum_325[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2607:2600] <= 'd0;
end

wire  [25:0]  kernel_img_mul_326[0:8];
assign kernel_img_mul_326[0] = buffer_data_2[2607:2600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_326[1] = buffer_data_2[2615:2608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_326[2] = buffer_data_2[2623:2616] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_326[3] = buffer_data_1[2607:2600] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_326[4] = buffer_data_1[2615:2608] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_326[5] = buffer_data_1[2623:2616] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_326[6] = buffer_data_0[2607:2600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_326[7] = buffer_data_0[2615:2608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_326[8] = buffer_data_0[2623:2616] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_326 = kernel_img_mul_326[0] + kernel_img_mul_326[1] + kernel_img_mul_326[2] + 
                kernel_img_mul_326[3] + kernel_img_mul_326[4] + kernel_img_mul_326[5] + 
                kernel_img_mul_326[6] + kernel_img_mul_326[7] + kernel_img_mul_326[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2615:2608] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2615:2608] <= kernel_img_sum_326[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2615:2608] <= 'd0;
end

wire  [25:0]  kernel_img_mul_327[0:8];
assign kernel_img_mul_327[0] = buffer_data_2[2615:2608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_327[1] = buffer_data_2[2623:2616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_327[2] = buffer_data_2[2631:2624] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_327[3] = buffer_data_1[2615:2608] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_327[4] = buffer_data_1[2623:2616] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_327[5] = buffer_data_1[2631:2624] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_327[6] = buffer_data_0[2615:2608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_327[7] = buffer_data_0[2623:2616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_327[8] = buffer_data_0[2631:2624] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_327 = kernel_img_mul_327[0] + kernel_img_mul_327[1] + kernel_img_mul_327[2] + 
                kernel_img_mul_327[3] + kernel_img_mul_327[4] + kernel_img_mul_327[5] + 
                kernel_img_mul_327[6] + kernel_img_mul_327[7] + kernel_img_mul_327[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2623:2616] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2623:2616] <= kernel_img_sum_327[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2623:2616] <= 'd0;
end

wire  [25:0]  kernel_img_mul_328[0:8];
assign kernel_img_mul_328[0] = buffer_data_2[2623:2616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_328[1] = buffer_data_2[2631:2624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_328[2] = buffer_data_2[2639:2632] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_328[3] = buffer_data_1[2623:2616] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_328[4] = buffer_data_1[2631:2624] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_328[5] = buffer_data_1[2639:2632] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_328[6] = buffer_data_0[2623:2616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_328[7] = buffer_data_0[2631:2624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_328[8] = buffer_data_0[2639:2632] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_328 = kernel_img_mul_328[0] + kernel_img_mul_328[1] + kernel_img_mul_328[2] + 
                kernel_img_mul_328[3] + kernel_img_mul_328[4] + kernel_img_mul_328[5] + 
                kernel_img_mul_328[6] + kernel_img_mul_328[7] + kernel_img_mul_328[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2631:2624] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2631:2624] <= kernel_img_sum_328[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2631:2624] <= 'd0;
end

wire  [25:0]  kernel_img_mul_329[0:8];
assign kernel_img_mul_329[0] = buffer_data_2[2631:2624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_329[1] = buffer_data_2[2639:2632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_329[2] = buffer_data_2[2647:2640] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_329[3] = buffer_data_1[2631:2624] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_329[4] = buffer_data_1[2639:2632] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_329[5] = buffer_data_1[2647:2640] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_329[6] = buffer_data_0[2631:2624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_329[7] = buffer_data_0[2639:2632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_329[8] = buffer_data_0[2647:2640] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_329 = kernel_img_mul_329[0] + kernel_img_mul_329[1] + kernel_img_mul_329[2] + 
                kernel_img_mul_329[3] + kernel_img_mul_329[4] + kernel_img_mul_329[5] + 
                kernel_img_mul_329[6] + kernel_img_mul_329[7] + kernel_img_mul_329[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2639:2632] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2639:2632] <= kernel_img_sum_329[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2639:2632] <= 'd0;
end

wire  [25:0]  kernel_img_mul_330[0:8];
assign kernel_img_mul_330[0] = buffer_data_2[2639:2632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_330[1] = buffer_data_2[2647:2640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_330[2] = buffer_data_2[2655:2648] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_330[3] = buffer_data_1[2639:2632] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_330[4] = buffer_data_1[2647:2640] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_330[5] = buffer_data_1[2655:2648] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_330[6] = buffer_data_0[2639:2632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_330[7] = buffer_data_0[2647:2640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_330[8] = buffer_data_0[2655:2648] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_330 = kernel_img_mul_330[0] + kernel_img_mul_330[1] + kernel_img_mul_330[2] + 
                kernel_img_mul_330[3] + kernel_img_mul_330[4] + kernel_img_mul_330[5] + 
                kernel_img_mul_330[6] + kernel_img_mul_330[7] + kernel_img_mul_330[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2647:2640] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2647:2640] <= kernel_img_sum_330[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2647:2640] <= 'd0;
end

wire  [25:0]  kernel_img_mul_331[0:8];
assign kernel_img_mul_331[0] = buffer_data_2[2647:2640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_331[1] = buffer_data_2[2655:2648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_331[2] = buffer_data_2[2663:2656] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_331[3] = buffer_data_1[2647:2640] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_331[4] = buffer_data_1[2655:2648] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_331[5] = buffer_data_1[2663:2656] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_331[6] = buffer_data_0[2647:2640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_331[7] = buffer_data_0[2655:2648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_331[8] = buffer_data_0[2663:2656] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_331 = kernel_img_mul_331[0] + kernel_img_mul_331[1] + kernel_img_mul_331[2] + 
                kernel_img_mul_331[3] + kernel_img_mul_331[4] + kernel_img_mul_331[5] + 
                kernel_img_mul_331[6] + kernel_img_mul_331[7] + kernel_img_mul_331[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2655:2648] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2655:2648] <= kernel_img_sum_331[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2655:2648] <= 'd0;
end

wire  [25:0]  kernel_img_mul_332[0:8];
assign kernel_img_mul_332[0] = buffer_data_2[2655:2648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_332[1] = buffer_data_2[2663:2656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_332[2] = buffer_data_2[2671:2664] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_332[3] = buffer_data_1[2655:2648] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_332[4] = buffer_data_1[2663:2656] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_332[5] = buffer_data_1[2671:2664] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_332[6] = buffer_data_0[2655:2648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_332[7] = buffer_data_0[2663:2656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_332[8] = buffer_data_0[2671:2664] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_332 = kernel_img_mul_332[0] + kernel_img_mul_332[1] + kernel_img_mul_332[2] + 
                kernel_img_mul_332[3] + kernel_img_mul_332[4] + kernel_img_mul_332[5] + 
                kernel_img_mul_332[6] + kernel_img_mul_332[7] + kernel_img_mul_332[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2663:2656] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2663:2656] <= kernel_img_sum_332[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2663:2656] <= 'd0;
end

wire  [25:0]  kernel_img_mul_333[0:8];
assign kernel_img_mul_333[0] = buffer_data_2[2663:2656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_333[1] = buffer_data_2[2671:2664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_333[2] = buffer_data_2[2679:2672] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_333[3] = buffer_data_1[2663:2656] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_333[4] = buffer_data_1[2671:2664] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_333[5] = buffer_data_1[2679:2672] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_333[6] = buffer_data_0[2663:2656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_333[7] = buffer_data_0[2671:2664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_333[8] = buffer_data_0[2679:2672] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_333 = kernel_img_mul_333[0] + kernel_img_mul_333[1] + kernel_img_mul_333[2] + 
                kernel_img_mul_333[3] + kernel_img_mul_333[4] + kernel_img_mul_333[5] + 
                kernel_img_mul_333[6] + kernel_img_mul_333[7] + kernel_img_mul_333[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2671:2664] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2671:2664] <= kernel_img_sum_333[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2671:2664] <= 'd0;
end

wire  [25:0]  kernel_img_mul_334[0:8];
assign kernel_img_mul_334[0] = buffer_data_2[2671:2664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_334[1] = buffer_data_2[2679:2672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_334[2] = buffer_data_2[2687:2680] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_334[3] = buffer_data_1[2671:2664] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_334[4] = buffer_data_1[2679:2672] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_334[5] = buffer_data_1[2687:2680] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_334[6] = buffer_data_0[2671:2664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_334[7] = buffer_data_0[2679:2672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_334[8] = buffer_data_0[2687:2680] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_334 = kernel_img_mul_334[0] + kernel_img_mul_334[1] + kernel_img_mul_334[2] + 
                kernel_img_mul_334[3] + kernel_img_mul_334[4] + kernel_img_mul_334[5] + 
                kernel_img_mul_334[6] + kernel_img_mul_334[7] + kernel_img_mul_334[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2679:2672] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2679:2672] <= kernel_img_sum_334[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2679:2672] <= 'd0;
end

wire  [25:0]  kernel_img_mul_335[0:8];
assign kernel_img_mul_335[0] = buffer_data_2[2679:2672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_335[1] = buffer_data_2[2687:2680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_335[2] = buffer_data_2[2695:2688] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_335[3] = buffer_data_1[2679:2672] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_335[4] = buffer_data_1[2687:2680] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_335[5] = buffer_data_1[2695:2688] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_335[6] = buffer_data_0[2679:2672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_335[7] = buffer_data_0[2687:2680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_335[8] = buffer_data_0[2695:2688] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_335 = kernel_img_mul_335[0] + kernel_img_mul_335[1] + kernel_img_mul_335[2] + 
                kernel_img_mul_335[3] + kernel_img_mul_335[4] + kernel_img_mul_335[5] + 
                kernel_img_mul_335[6] + kernel_img_mul_335[7] + kernel_img_mul_335[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2687:2680] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2687:2680] <= kernel_img_sum_335[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2687:2680] <= 'd0;
end

wire  [25:0]  kernel_img_mul_336[0:8];
assign kernel_img_mul_336[0] = buffer_data_2[2687:2680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_336[1] = buffer_data_2[2695:2688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_336[2] = buffer_data_2[2703:2696] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_336[3] = buffer_data_1[2687:2680] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_336[4] = buffer_data_1[2695:2688] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_336[5] = buffer_data_1[2703:2696] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_336[6] = buffer_data_0[2687:2680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_336[7] = buffer_data_0[2695:2688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_336[8] = buffer_data_0[2703:2696] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_336 = kernel_img_mul_336[0] + kernel_img_mul_336[1] + kernel_img_mul_336[2] + 
                kernel_img_mul_336[3] + kernel_img_mul_336[4] + kernel_img_mul_336[5] + 
                kernel_img_mul_336[6] + kernel_img_mul_336[7] + kernel_img_mul_336[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2695:2688] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2695:2688] <= kernel_img_sum_336[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2695:2688] <= 'd0;
end

wire  [25:0]  kernel_img_mul_337[0:8];
assign kernel_img_mul_337[0] = buffer_data_2[2695:2688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_337[1] = buffer_data_2[2703:2696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_337[2] = buffer_data_2[2711:2704] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_337[3] = buffer_data_1[2695:2688] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_337[4] = buffer_data_1[2703:2696] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_337[5] = buffer_data_1[2711:2704] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_337[6] = buffer_data_0[2695:2688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_337[7] = buffer_data_0[2703:2696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_337[8] = buffer_data_0[2711:2704] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_337 = kernel_img_mul_337[0] + kernel_img_mul_337[1] + kernel_img_mul_337[2] + 
                kernel_img_mul_337[3] + kernel_img_mul_337[4] + kernel_img_mul_337[5] + 
                kernel_img_mul_337[6] + kernel_img_mul_337[7] + kernel_img_mul_337[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2703:2696] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2703:2696] <= kernel_img_sum_337[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2703:2696] <= 'd0;
end

wire  [25:0]  kernel_img_mul_338[0:8];
assign kernel_img_mul_338[0] = buffer_data_2[2703:2696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_338[1] = buffer_data_2[2711:2704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_338[2] = buffer_data_2[2719:2712] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_338[3] = buffer_data_1[2703:2696] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_338[4] = buffer_data_1[2711:2704] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_338[5] = buffer_data_1[2719:2712] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_338[6] = buffer_data_0[2703:2696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_338[7] = buffer_data_0[2711:2704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_338[8] = buffer_data_0[2719:2712] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_338 = kernel_img_mul_338[0] + kernel_img_mul_338[1] + kernel_img_mul_338[2] + 
                kernel_img_mul_338[3] + kernel_img_mul_338[4] + kernel_img_mul_338[5] + 
                kernel_img_mul_338[6] + kernel_img_mul_338[7] + kernel_img_mul_338[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2711:2704] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2711:2704] <= kernel_img_sum_338[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2711:2704] <= 'd0;
end

wire  [25:0]  kernel_img_mul_339[0:8];
assign kernel_img_mul_339[0] = buffer_data_2[2711:2704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_339[1] = buffer_data_2[2719:2712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_339[2] = buffer_data_2[2727:2720] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_339[3] = buffer_data_1[2711:2704] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_339[4] = buffer_data_1[2719:2712] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_339[5] = buffer_data_1[2727:2720] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_339[6] = buffer_data_0[2711:2704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_339[7] = buffer_data_0[2719:2712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_339[8] = buffer_data_0[2727:2720] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_339 = kernel_img_mul_339[0] + kernel_img_mul_339[1] + kernel_img_mul_339[2] + 
                kernel_img_mul_339[3] + kernel_img_mul_339[4] + kernel_img_mul_339[5] + 
                kernel_img_mul_339[6] + kernel_img_mul_339[7] + kernel_img_mul_339[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2719:2712] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2719:2712] <= kernel_img_sum_339[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2719:2712] <= 'd0;
end

wire  [25:0]  kernel_img_mul_340[0:8];
assign kernel_img_mul_340[0] = buffer_data_2[2719:2712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_340[1] = buffer_data_2[2727:2720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_340[2] = buffer_data_2[2735:2728] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_340[3] = buffer_data_1[2719:2712] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_340[4] = buffer_data_1[2727:2720] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_340[5] = buffer_data_1[2735:2728] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_340[6] = buffer_data_0[2719:2712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_340[7] = buffer_data_0[2727:2720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_340[8] = buffer_data_0[2735:2728] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_340 = kernel_img_mul_340[0] + kernel_img_mul_340[1] + kernel_img_mul_340[2] + 
                kernel_img_mul_340[3] + kernel_img_mul_340[4] + kernel_img_mul_340[5] + 
                kernel_img_mul_340[6] + kernel_img_mul_340[7] + kernel_img_mul_340[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2727:2720] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2727:2720] <= kernel_img_sum_340[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2727:2720] <= 'd0;
end

wire  [25:0]  kernel_img_mul_341[0:8];
assign kernel_img_mul_341[0] = buffer_data_2[2727:2720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_341[1] = buffer_data_2[2735:2728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_341[2] = buffer_data_2[2743:2736] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_341[3] = buffer_data_1[2727:2720] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_341[4] = buffer_data_1[2735:2728] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_341[5] = buffer_data_1[2743:2736] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_341[6] = buffer_data_0[2727:2720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_341[7] = buffer_data_0[2735:2728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_341[8] = buffer_data_0[2743:2736] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_341 = kernel_img_mul_341[0] + kernel_img_mul_341[1] + kernel_img_mul_341[2] + 
                kernel_img_mul_341[3] + kernel_img_mul_341[4] + kernel_img_mul_341[5] + 
                kernel_img_mul_341[6] + kernel_img_mul_341[7] + kernel_img_mul_341[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2735:2728] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2735:2728] <= kernel_img_sum_341[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2735:2728] <= 'd0;
end

wire  [25:0]  kernel_img_mul_342[0:8];
assign kernel_img_mul_342[0] = buffer_data_2[2735:2728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_342[1] = buffer_data_2[2743:2736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_342[2] = buffer_data_2[2751:2744] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_342[3] = buffer_data_1[2735:2728] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_342[4] = buffer_data_1[2743:2736] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_342[5] = buffer_data_1[2751:2744] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_342[6] = buffer_data_0[2735:2728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_342[7] = buffer_data_0[2743:2736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_342[8] = buffer_data_0[2751:2744] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_342 = kernel_img_mul_342[0] + kernel_img_mul_342[1] + kernel_img_mul_342[2] + 
                kernel_img_mul_342[3] + kernel_img_mul_342[4] + kernel_img_mul_342[5] + 
                kernel_img_mul_342[6] + kernel_img_mul_342[7] + kernel_img_mul_342[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2743:2736] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2743:2736] <= kernel_img_sum_342[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2743:2736] <= 'd0;
end

wire  [25:0]  kernel_img_mul_343[0:8];
assign kernel_img_mul_343[0] = buffer_data_2[2743:2736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_343[1] = buffer_data_2[2751:2744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_343[2] = buffer_data_2[2759:2752] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_343[3] = buffer_data_1[2743:2736] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_343[4] = buffer_data_1[2751:2744] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_343[5] = buffer_data_1[2759:2752] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_343[6] = buffer_data_0[2743:2736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_343[7] = buffer_data_0[2751:2744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_343[8] = buffer_data_0[2759:2752] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_343 = kernel_img_mul_343[0] + kernel_img_mul_343[1] + kernel_img_mul_343[2] + 
                kernel_img_mul_343[3] + kernel_img_mul_343[4] + kernel_img_mul_343[5] + 
                kernel_img_mul_343[6] + kernel_img_mul_343[7] + kernel_img_mul_343[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2751:2744] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2751:2744] <= kernel_img_sum_343[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2751:2744] <= 'd0;
end

wire  [25:0]  kernel_img_mul_344[0:8];
assign kernel_img_mul_344[0] = buffer_data_2[2751:2744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_344[1] = buffer_data_2[2759:2752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_344[2] = buffer_data_2[2767:2760] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_344[3] = buffer_data_1[2751:2744] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_344[4] = buffer_data_1[2759:2752] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_344[5] = buffer_data_1[2767:2760] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_344[6] = buffer_data_0[2751:2744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_344[7] = buffer_data_0[2759:2752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_344[8] = buffer_data_0[2767:2760] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_344 = kernel_img_mul_344[0] + kernel_img_mul_344[1] + kernel_img_mul_344[2] + 
                kernel_img_mul_344[3] + kernel_img_mul_344[4] + kernel_img_mul_344[5] + 
                kernel_img_mul_344[6] + kernel_img_mul_344[7] + kernel_img_mul_344[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2759:2752] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2759:2752] <= kernel_img_sum_344[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2759:2752] <= 'd0;
end

wire  [25:0]  kernel_img_mul_345[0:8];
assign kernel_img_mul_345[0] = buffer_data_2[2759:2752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_345[1] = buffer_data_2[2767:2760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_345[2] = buffer_data_2[2775:2768] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_345[3] = buffer_data_1[2759:2752] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_345[4] = buffer_data_1[2767:2760] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_345[5] = buffer_data_1[2775:2768] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_345[6] = buffer_data_0[2759:2752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_345[7] = buffer_data_0[2767:2760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_345[8] = buffer_data_0[2775:2768] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_345 = kernel_img_mul_345[0] + kernel_img_mul_345[1] + kernel_img_mul_345[2] + 
                kernel_img_mul_345[3] + kernel_img_mul_345[4] + kernel_img_mul_345[5] + 
                kernel_img_mul_345[6] + kernel_img_mul_345[7] + kernel_img_mul_345[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2767:2760] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2767:2760] <= kernel_img_sum_345[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2767:2760] <= 'd0;
end

wire  [25:0]  kernel_img_mul_346[0:8];
assign kernel_img_mul_346[0] = buffer_data_2[2767:2760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_346[1] = buffer_data_2[2775:2768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_346[2] = buffer_data_2[2783:2776] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_346[3] = buffer_data_1[2767:2760] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_346[4] = buffer_data_1[2775:2768] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_346[5] = buffer_data_1[2783:2776] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_346[6] = buffer_data_0[2767:2760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_346[7] = buffer_data_0[2775:2768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_346[8] = buffer_data_0[2783:2776] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_346 = kernel_img_mul_346[0] + kernel_img_mul_346[1] + kernel_img_mul_346[2] + 
                kernel_img_mul_346[3] + kernel_img_mul_346[4] + kernel_img_mul_346[5] + 
                kernel_img_mul_346[6] + kernel_img_mul_346[7] + kernel_img_mul_346[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2775:2768] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2775:2768] <= kernel_img_sum_346[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2775:2768] <= 'd0;
end

wire  [25:0]  kernel_img_mul_347[0:8];
assign kernel_img_mul_347[0] = buffer_data_2[2775:2768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_347[1] = buffer_data_2[2783:2776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_347[2] = buffer_data_2[2791:2784] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_347[3] = buffer_data_1[2775:2768] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_347[4] = buffer_data_1[2783:2776] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_347[5] = buffer_data_1[2791:2784] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_347[6] = buffer_data_0[2775:2768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_347[7] = buffer_data_0[2783:2776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_347[8] = buffer_data_0[2791:2784] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_347 = kernel_img_mul_347[0] + kernel_img_mul_347[1] + kernel_img_mul_347[2] + 
                kernel_img_mul_347[3] + kernel_img_mul_347[4] + kernel_img_mul_347[5] + 
                kernel_img_mul_347[6] + kernel_img_mul_347[7] + kernel_img_mul_347[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2783:2776] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2783:2776] <= kernel_img_sum_347[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2783:2776] <= 'd0;
end

wire  [25:0]  kernel_img_mul_348[0:8];
assign kernel_img_mul_348[0] = buffer_data_2[2783:2776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_348[1] = buffer_data_2[2791:2784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_348[2] = buffer_data_2[2799:2792] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_348[3] = buffer_data_1[2783:2776] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_348[4] = buffer_data_1[2791:2784] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_348[5] = buffer_data_1[2799:2792] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_348[6] = buffer_data_0[2783:2776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_348[7] = buffer_data_0[2791:2784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_348[8] = buffer_data_0[2799:2792] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_348 = kernel_img_mul_348[0] + kernel_img_mul_348[1] + kernel_img_mul_348[2] + 
                kernel_img_mul_348[3] + kernel_img_mul_348[4] + kernel_img_mul_348[5] + 
                kernel_img_mul_348[6] + kernel_img_mul_348[7] + kernel_img_mul_348[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2791:2784] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2791:2784] <= kernel_img_sum_348[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2791:2784] <= 'd0;
end

wire  [25:0]  kernel_img_mul_349[0:8];
assign kernel_img_mul_349[0] = buffer_data_2[2791:2784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_349[1] = buffer_data_2[2799:2792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_349[2] = buffer_data_2[2807:2800] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_349[3] = buffer_data_1[2791:2784] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_349[4] = buffer_data_1[2799:2792] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_349[5] = buffer_data_1[2807:2800] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_349[6] = buffer_data_0[2791:2784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_349[7] = buffer_data_0[2799:2792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_349[8] = buffer_data_0[2807:2800] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_349 = kernel_img_mul_349[0] + kernel_img_mul_349[1] + kernel_img_mul_349[2] + 
                kernel_img_mul_349[3] + kernel_img_mul_349[4] + kernel_img_mul_349[5] + 
                kernel_img_mul_349[6] + kernel_img_mul_349[7] + kernel_img_mul_349[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2799:2792] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2799:2792] <= kernel_img_sum_349[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2799:2792] <= 'd0;
end

wire  [25:0]  kernel_img_mul_350[0:8];
assign kernel_img_mul_350[0] = buffer_data_2[2799:2792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_350[1] = buffer_data_2[2807:2800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_350[2] = buffer_data_2[2815:2808] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_350[3] = buffer_data_1[2799:2792] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_350[4] = buffer_data_1[2807:2800] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_350[5] = buffer_data_1[2815:2808] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_350[6] = buffer_data_0[2799:2792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_350[7] = buffer_data_0[2807:2800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_350[8] = buffer_data_0[2815:2808] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_350 = kernel_img_mul_350[0] + kernel_img_mul_350[1] + kernel_img_mul_350[2] + 
                kernel_img_mul_350[3] + kernel_img_mul_350[4] + kernel_img_mul_350[5] + 
                kernel_img_mul_350[6] + kernel_img_mul_350[7] + kernel_img_mul_350[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2807:2800] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2807:2800] <= kernel_img_sum_350[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2807:2800] <= 'd0;
end

wire  [25:0]  kernel_img_mul_351[0:8];
assign kernel_img_mul_351[0] = buffer_data_2[2807:2800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_351[1] = buffer_data_2[2815:2808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_351[2] = buffer_data_2[2823:2816] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_351[3] = buffer_data_1[2807:2800] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_351[4] = buffer_data_1[2815:2808] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_351[5] = buffer_data_1[2823:2816] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_351[6] = buffer_data_0[2807:2800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_351[7] = buffer_data_0[2815:2808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_351[8] = buffer_data_0[2823:2816] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_351 = kernel_img_mul_351[0] + kernel_img_mul_351[1] + kernel_img_mul_351[2] + 
                kernel_img_mul_351[3] + kernel_img_mul_351[4] + kernel_img_mul_351[5] + 
                kernel_img_mul_351[6] + kernel_img_mul_351[7] + kernel_img_mul_351[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2815:2808] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2815:2808] <= kernel_img_sum_351[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2815:2808] <= 'd0;
end

wire  [25:0]  kernel_img_mul_352[0:8];
assign kernel_img_mul_352[0] = buffer_data_2[2815:2808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_352[1] = buffer_data_2[2823:2816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_352[2] = buffer_data_2[2831:2824] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_352[3] = buffer_data_1[2815:2808] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_352[4] = buffer_data_1[2823:2816] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_352[5] = buffer_data_1[2831:2824] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_352[6] = buffer_data_0[2815:2808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_352[7] = buffer_data_0[2823:2816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_352[8] = buffer_data_0[2831:2824] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_352 = kernel_img_mul_352[0] + kernel_img_mul_352[1] + kernel_img_mul_352[2] + 
                kernel_img_mul_352[3] + kernel_img_mul_352[4] + kernel_img_mul_352[5] + 
                kernel_img_mul_352[6] + kernel_img_mul_352[7] + kernel_img_mul_352[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2823:2816] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2823:2816] <= kernel_img_sum_352[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2823:2816] <= 'd0;
end

wire  [25:0]  kernel_img_mul_353[0:8];
assign kernel_img_mul_353[0] = buffer_data_2[2823:2816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_353[1] = buffer_data_2[2831:2824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_353[2] = buffer_data_2[2839:2832] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_353[3] = buffer_data_1[2823:2816] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_353[4] = buffer_data_1[2831:2824] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_353[5] = buffer_data_1[2839:2832] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_353[6] = buffer_data_0[2823:2816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_353[7] = buffer_data_0[2831:2824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_353[8] = buffer_data_0[2839:2832] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_353 = kernel_img_mul_353[0] + kernel_img_mul_353[1] + kernel_img_mul_353[2] + 
                kernel_img_mul_353[3] + kernel_img_mul_353[4] + kernel_img_mul_353[5] + 
                kernel_img_mul_353[6] + kernel_img_mul_353[7] + kernel_img_mul_353[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2831:2824] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2831:2824] <= kernel_img_sum_353[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2831:2824] <= 'd0;
end

wire  [25:0]  kernel_img_mul_354[0:8];
assign kernel_img_mul_354[0] = buffer_data_2[2831:2824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_354[1] = buffer_data_2[2839:2832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_354[2] = buffer_data_2[2847:2840] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_354[3] = buffer_data_1[2831:2824] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_354[4] = buffer_data_1[2839:2832] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_354[5] = buffer_data_1[2847:2840] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_354[6] = buffer_data_0[2831:2824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_354[7] = buffer_data_0[2839:2832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_354[8] = buffer_data_0[2847:2840] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_354 = kernel_img_mul_354[0] + kernel_img_mul_354[1] + kernel_img_mul_354[2] + 
                kernel_img_mul_354[3] + kernel_img_mul_354[4] + kernel_img_mul_354[5] + 
                kernel_img_mul_354[6] + kernel_img_mul_354[7] + kernel_img_mul_354[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2839:2832] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2839:2832] <= kernel_img_sum_354[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2839:2832] <= 'd0;
end

wire  [25:0]  kernel_img_mul_355[0:8];
assign kernel_img_mul_355[0] = buffer_data_2[2839:2832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_355[1] = buffer_data_2[2847:2840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_355[2] = buffer_data_2[2855:2848] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_355[3] = buffer_data_1[2839:2832] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_355[4] = buffer_data_1[2847:2840] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_355[5] = buffer_data_1[2855:2848] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_355[6] = buffer_data_0[2839:2832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_355[7] = buffer_data_0[2847:2840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_355[8] = buffer_data_0[2855:2848] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_355 = kernel_img_mul_355[0] + kernel_img_mul_355[1] + kernel_img_mul_355[2] + 
                kernel_img_mul_355[3] + kernel_img_mul_355[4] + kernel_img_mul_355[5] + 
                kernel_img_mul_355[6] + kernel_img_mul_355[7] + kernel_img_mul_355[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2847:2840] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2847:2840] <= kernel_img_sum_355[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2847:2840] <= 'd0;
end

wire  [25:0]  kernel_img_mul_356[0:8];
assign kernel_img_mul_356[0] = buffer_data_2[2847:2840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_356[1] = buffer_data_2[2855:2848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_356[2] = buffer_data_2[2863:2856] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_356[3] = buffer_data_1[2847:2840] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_356[4] = buffer_data_1[2855:2848] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_356[5] = buffer_data_1[2863:2856] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_356[6] = buffer_data_0[2847:2840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_356[7] = buffer_data_0[2855:2848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_356[8] = buffer_data_0[2863:2856] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_356 = kernel_img_mul_356[0] + kernel_img_mul_356[1] + kernel_img_mul_356[2] + 
                kernel_img_mul_356[3] + kernel_img_mul_356[4] + kernel_img_mul_356[5] + 
                kernel_img_mul_356[6] + kernel_img_mul_356[7] + kernel_img_mul_356[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2855:2848] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2855:2848] <= kernel_img_sum_356[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2855:2848] <= 'd0;
end

wire  [25:0]  kernel_img_mul_357[0:8];
assign kernel_img_mul_357[0] = buffer_data_2[2855:2848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_357[1] = buffer_data_2[2863:2856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_357[2] = buffer_data_2[2871:2864] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_357[3] = buffer_data_1[2855:2848] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_357[4] = buffer_data_1[2863:2856] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_357[5] = buffer_data_1[2871:2864] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_357[6] = buffer_data_0[2855:2848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_357[7] = buffer_data_0[2863:2856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_357[8] = buffer_data_0[2871:2864] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_357 = kernel_img_mul_357[0] + kernel_img_mul_357[1] + kernel_img_mul_357[2] + 
                kernel_img_mul_357[3] + kernel_img_mul_357[4] + kernel_img_mul_357[5] + 
                kernel_img_mul_357[6] + kernel_img_mul_357[7] + kernel_img_mul_357[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2863:2856] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2863:2856] <= kernel_img_sum_357[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2863:2856] <= 'd0;
end

wire  [25:0]  kernel_img_mul_358[0:8];
assign kernel_img_mul_358[0] = buffer_data_2[2863:2856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_358[1] = buffer_data_2[2871:2864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_358[2] = buffer_data_2[2879:2872] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_358[3] = buffer_data_1[2863:2856] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_358[4] = buffer_data_1[2871:2864] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_358[5] = buffer_data_1[2879:2872] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_358[6] = buffer_data_0[2863:2856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_358[7] = buffer_data_0[2871:2864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_358[8] = buffer_data_0[2879:2872] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_358 = kernel_img_mul_358[0] + kernel_img_mul_358[1] + kernel_img_mul_358[2] + 
                kernel_img_mul_358[3] + kernel_img_mul_358[4] + kernel_img_mul_358[5] + 
                kernel_img_mul_358[6] + kernel_img_mul_358[7] + kernel_img_mul_358[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2871:2864] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2871:2864] <= kernel_img_sum_358[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2871:2864] <= 'd0;
end

wire  [25:0]  kernel_img_mul_359[0:8];
assign kernel_img_mul_359[0] = buffer_data_2[2871:2864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_359[1] = buffer_data_2[2879:2872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_359[2] = buffer_data_2[2887:2880] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_359[3] = buffer_data_1[2871:2864] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_359[4] = buffer_data_1[2879:2872] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_359[5] = buffer_data_1[2887:2880] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_359[6] = buffer_data_0[2871:2864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_359[7] = buffer_data_0[2879:2872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_359[8] = buffer_data_0[2887:2880] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_359 = kernel_img_mul_359[0] + kernel_img_mul_359[1] + kernel_img_mul_359[2] + 
                kernel_img_mul_359[3] + kernel_img_mul_359[4] + kernel_img_mul_359[5] + 
                kernel_img_mul_359[6] + kernel_img_mul_359[7] + kernel_img_mul_359[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2879:2872] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2879:2872] <= kernel_img_sum_359[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2879:2872] <= 'd0;
end

wire  [25:0]  kernel_img_mul_360[0:8];
assign kernel_img_mul_360[0] = buffer_data_2[2879:2872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_360[1] = buffer_data_2[2887:2880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_360[2] = buffer_data_2[2895:2888] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_360[3] = buffer_data_1[2879:2872] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_360[4] = buffer_data_1[2887:2880] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_360[5] = buffer_data_1[2895:2888] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_360[6] = buffer_data_0[2879:2872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_360[7] = buffer_data_0[2887:2880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_360[8] = buffer_data_0[2895:2888] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_360 = kernel_img_mul_360[0] + kernel_img_mul_360[1] + kernel_img_mul_360[2] + 
                kernel_img_mul_360[3] + kernel_img_mul_360[4] + kernel_img_mul_360[5] + 
                kernel_img_mul_360[6] + kernel_img_mul_360[7] + kernel_img_mul_360[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2887:2880] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2887:2880] <= kernel_img_sum_360[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2887:2880] <= 'd0;
end

wire  [25:0]  kernel_img_mul_361[0:8];
assign kernel_img_mul_361[0] = buffer_data_2[2887:2880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_361[1] = buffer_data_2[2895:2888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_361[2] = buffer_data_2[2903:2896] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_361[3] = buffer_data_1[2887:2880] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_361[4] = buffer_data_1[2895:2888] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_361[5] = buffer_data_1[2903:2896] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_361[6] = buffer_data_0[2887:2880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_361[7] = buffer_data_0[2895:2888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_361[8] = buffer_data_0[2903:2896] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_361 = kernel_img_mul_361[0] + kernel_img_mul_361[1] + kernel_img_mul_361[2] + 
                kernel_img_mul_361[3] + kernel_img_mul_361[4] + kernel_img_mul_361[5] + 
                kernel_img_mul_361[6] + kernel_img_mul_361[7] + kernel_img_mul_361[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2895:2888] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2895:2888] <= kernel_img_sum_361[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2895:2888] <= 'd0;
end

wire  [25:0]  kernel_img_mul_362[0:8];
assign kernel_img_mul_362[0] = buffer_data_2[2895:2888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_362[1] = buffer_data_2[2903:2896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_362[2] = buffer_data_2[2911:2904] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_362[3] = buffer_data_1[2895:2888] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_362[4] = buffer_data_1[2903:2896] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_362[5] = buffer_data_1[2911:2904] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_362[6] = buffer_data_0[2895:2888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_362[7] = buffer_data_0[2903:2896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_362[8] = buffer_data_0[2911:2904] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_362 = kernel_img_mul_362[0] + kernel_img_mul_362[1] + kernel_img_mul_362[2] + 
                kernel_img_mul_362[3] + kernel_img_mul_362[4] + kernel_img_mul_362[5] + 
                kernel_img_mul_362[6] + kernel_img_mul_362[7] + kernel_img_mul_362[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2903:2896] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2903:2896] <= kernel_img_sum_362[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2903:2896] <= 'd0;
end

wire  [25:0]  kernel_img_mul_363[0:8];
assign kernel_img_mul_363[0] = buffer_data_2[2903:2896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_363[1] = buffer_data_2[2911:2904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_363[2] = buffer_data_2[2919:2912] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_363[3] = buffer_data_1[2903:2896] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_363[4] = buffer_data_1[2911:2904] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_363[5] = buffer_data_1[2919:2912] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_363[6] = buffer_data_0[2903:2896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_363[7] = buffer_data_0[2911:2904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_363[8] = buffer_data_0[2919:2912] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_363 = kernel_img_mul_363[0] + kernel_img_mul_363[1] + kernel_img_mul_363[2] + 
                kernel_img_mul_363[3] + kernel_img_mul_363[4] + kernel_img_mul_363[5] + 
                kernel_img_mul_363[6] + kernel_img_mul_363[7] + kernel_img_mul_363[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2911:2904] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2911:2904] <= kernel_img_sum_363[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2911:2904] <= 'd0;
end

wire  [25:0]  kernel_img_mul_364[0:8];
assign kernel_img_mul_364[0] = buffer_data_2[2911:2904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_364[1] = buffer_data_2[2919:2912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_364[2] = buffer_data_2[2927:2920] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_364[3] = buffer_data_1[2911:2904] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_364[4] = buffer_data_1[2919:2912] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_364[5] = buffer_data_1[2927:2920] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_364[6] = buffer_data_0[2911:2904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_364[7] = buffer_data_0[2919:2912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_364[8] = buffer_data_0[2927:2920] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_364 = kernel_img_mul_364[0] + kernel_img_mul_364[1] + kernel_img_mul_364[2] + 
                kernel_img_mul_364[3] + kernel_img_mul_364[4] + kernel_img_mul_364[5] + 
                kernel_img_mul_364[6] + kernel_img_mul_364[7] + kernel_img_mul_364[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2919:2912] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2919:2912] <= kernel_img_sum_364[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2919:2912] <= 'd0;
end

wire  [25:0]  kernel_img_mul_365[0:8];
assign kernel_img_mul_365[0] = buffer_data_2[2919:2912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_365[1] = buffer_data_2[2927:2920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_365[2] = buffer_data_2[2935:2928] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_365[3] = buffer_data_1[2919:2912] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_365[4] = buffer_data_1[2927:2920] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_365[5] = buffer_data_1[2935:2928] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_365[6] = buffer_data_0[2919:2912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_365[7] = buffer_data_0[2927:2920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_365[8] = buffer_data_0[2935:2928] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_365 = kernel_img_mul_365[0] + kernel_img_mul_365[1] + kernel_img_mul_365[2] + 
                kernel_img_mul_365[3] + kernel_img_mul_365[4] + kernel_img_mul_365[5] + 
                kernel_img_mul_365[6] + kernel_img_mul_365[7] + kernel_img_mul_365[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2927:2920] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2927:2920] <= kernel_img_sum_365[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2927:2920] <= 'd0;
end

wire  [25:0]  kernel_img_mul_366[0:8];
assign kernel_img_mul_366[0] = buffer_data_2[2927:2920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_366[1] = buffer_data_2[2935:2928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_366[2] = buffer_data_2[2943:2936] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_366[3] = buffer_data_1[2927:2920] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_366[4] = buffer_data_1[2935:2928] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_366[5] = buffer_data_1[2943:2936] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_366[6] = buffer_data_0[2927:2920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_366[7] = buffer_data_0[2935:2928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_366[8] = buffer_data_0[2943:2936] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_366 = kernel_img_mul_366[0] + kernel_img_mul_366[1] + kernel_img_mul_366[2] + 
                kernel_img_mul_366[3] + kernel_img_mul_366[4] + kernel_img_mul_366[5] + 
                kernel_img_mul_366[6] + kernel_img_mul_366[7] + kernel_img_mul_366[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2935:2928] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2935:2928] <= kernel_img_sum_366[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2935:2928] <= 'd0;
end

wire  [25:0]  kernel_img_mul_367[0:8];
assign kernel_img_mul_367[0] = buffer_data_2[2935:2928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_367[1] = buffer_data_2[2943:2936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_367[2] = buffer_data_2[2951:2944] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_367[3] = buffer_data_1[2935:2928] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_367[4] = buffer_data_1[2943:2936] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_367[5] = buffer_data_1[2951:2944] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_367[6] = buffer_data_0[2935:2928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_367[7] = buffer_data_0[2943:2936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_367[8] = buffer_data_0[2951:2944] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_367 = kernel_img_mul_367[0] + kernel_img_mul_367[1] + kernel_img_mul_367[2] + 
                kernel_img_mul_367[3] + kernel_img_mul_367[4] + kernel_img_mul_367[5] + 
                kernel_img_mul_367[6] + kernel_img_mul_367[7] + kernel_img_mul_367[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2943:2936] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2943:2936] <= kernel_img_sum_367[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2943:2936] <= 'd0;
end

wire  [25:0]  kernel_img_mul_368[0:8];
assign kernel_img_mul_368[0] = buffer_data_2[2943:2936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_368[1] = buffer_data_2[2951:2944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_368[2] = buffer_data_2[2959:2952] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_368[3] = buffer_data_1[2943:2936] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_368[4] = buffer_data_1[2951:2944] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_368[5] = buffer_data_1[2959:2952] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_368[6] = buffer_data_0[2943:2936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_368[7] = buffer_data_0[2951:2944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_368[8] = buffer_data_0[2959:2952] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_368 = kernel_img_mul_368[0] + kernel_img_mul_368[1] + kernel_img_mul_368[2] + 
                kernel_img_mul_368[3] + kernel_img_mul_368[4] + kernel_img_mul_368[5] + 
                kernel_img_mul_368[6] + kernel_img_mul_368[7] + kernel_img_mul_368[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2951:2944] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2951:2944] <= kernel_img_sum_368[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2951:2944] <= 'd0;
end

wire  [25:0]  kernel_img_mul_369[0:8];
assign kernel_img_mul_369[0] = buffer_data_2[2951:2944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_369[1] = buffer_data_2[2959:2952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_369[2] = buffer_data_2[2967:2960] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_369[3] = buffer_data_1[2951:2944] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_369[4] = buffer_data_1[2959:2952] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_369[5] = buffer_data_1[2967:2960] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_369[6] = buffer_data_0[2951:2944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_369[7] = buffer_data_0[2959:2952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_369[8] = buffer_data_0[2967:2960] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_369 = kernel_img_mul_369[0] + kernel_img_mul_369[1] + kernel_img_mul_369[2] + 
                kernel_img_mul_369[3] + kernel_img_mul_369[4] + kernel_img_mul_369[5] + 
                kernel_img_mul_369[6] + kernel_img_mul_369[7] + kernel_img_mul_369[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2959:2952] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2959:2952] <= kernel_img_sum_369[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2959:2952] <= 'd0;
end

wire  [25:0]  kernel_img_mul_370[0:8];
assign kernel_img_mul_370[0] = buffer_data_2[2959:2952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_370[1] = buffer_data_2[2967:2960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_370[2] = buffer_data_2[2975:2968] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_370[3] = buffer_data_1[2959:2952] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_370[4] = buffer_data_1[2967:2960] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_370[5] = buffer_data_1[2975:2968] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_370[6] = buffer_data_0[2959:2952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_370[7] = buffer_data_0[2967:2960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_370[8] = buffer_data_0[2975:2968] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_370 = kernel_img_mul_370[0] + kernel_img_mul_370[1] + kernel_img_mul_370[2] + 
                kernel_img_mul_370[3] + kernel_img_mul_370[4] + kernel_img_mul_370[5] + 
                kernel_img_mul_370[6] + kernel_img_mul_370[7] + kernel_img_mul_370[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2967:2960] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2967:2960] <= kernel_img_sum_370[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2967:2960] <= 'd0;
end

wire  [25:0]  kernel_img_mul_371[0:8];
assign kernel_img_mul_371[0] = buffer_data_2[2967:2960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_371[1] = buffer_data_2[2975:2968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_371[2] = buffer_data_2[2983:2976] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_371[3] = buffer_data_1[2967:2960] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_371[4] = buffer_data_1[2975:2968] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_371[5] = buffer_data_1[2983:2976] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_371[6] = buffer_data_0[2967:2960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_371[7] = buffer_data_0[2975:2968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_371[8] = buffer_data_0[2983:2976] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_371 = kernel_img_mul_371[0] + kernel_img_mul_371[1] + kernel_img_mul_371[2] + 
                kernel_img_mul_371[3] + kernel_img_mul_371[4] + kernel_img_mul_371[5] + 
                kernel_img_mul_371[6] + kernel_img_mul_371[7] + kernel_img_mul_371[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2975:2968] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2975:2968] <= kernel_img_sum_371[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2975:2968] <= 'd0;
end

wire  [25:0]  kernel_img_mul_372[0:8];
assign kernel_img_mul_372[0] = buffer_data_2[2975:2968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_372[1] = buffer_data_2[2983:2976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_372[2] = buffer_data_2[2991:2984] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_372[3] = buffer_data_1[2975:2968] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_372[4] = buffer_data_1[2983:2976] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_372[5] = buffer_data_1[2991:2984] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_372[6] = buffer_data_0[2975:2968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_372[7] = buffer_data_0[2983:2976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_372[8] = buffer_data_0[2991:2984] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_372 = kernel_img_mul_372[0] + kernel_img_mul_372[1] + kernel_img_mul_372[2] + 
                kernel_img_mul_372[3] + kernel_img_mul_372[4] + kernel_img_mul_372[5] + 
                kernel_img_mul_372[6] + kernel_img_mul_372[7] + kernel_img_mul_372[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2983:2976] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2983:2976] <= kernel_img_sum_372[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2983:2976] <= 'd0;
end

wire  [25:0]  kernel_img_mul_373[0:8];
assign kernel_img_mul_373[0] = buffer_data_2[2983:2976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_373[1] = buffer_data_2[2991:2984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_373[2] = buffer_data_2[2999:2992] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_373[3] = buffer_data_1[2983:2976] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_373[4] = buffer_data_1[2991:2984] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_373[5] = buffer_data_1[2999:2992] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_373[6] = buffer_data_0[2983:2976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_373[7] = buffer_data_0[2991:2984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_373[8] = buffer_data_0[2999:2992] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_373 = kernel_img_mul_373[0] + kernel_img_mul_373[1] + kernel_img_mul_373[2] + 
                kernel_img_mul_373[3] + kernel_img_mul_373[4] + kernel_img_mul_373[5] + 
                kernel_img_mul_373[6] + kernel_img_mul_373[7] + kernel_img_mul_373[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2991:2984] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2991:2984] <= kernel_img_sum_373[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2991:2984] <= 'd0;
end

wire  [25:0]  kernel_img_mul_374[0:8];
assign kernel_img_mul_374[0] = buffer_data_2[2991:2984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_374[1] = buffer_data_2[2999:2992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_374[2] = buffer_data_2[3007:3000] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_374[3] = buffer_data_1[2991:2984] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_374[4] = buffer_data_1[2999:2992] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_374[5] = buffer_data_1[3007:3000] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_374[6] = buffer_data_0[2991:2984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_374[7] = buffer_data_0[2999:2992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_374[8] = buffer_data_0[3007:3000] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_374 = kernel_img_mul_374[0] + kernel_img_mul_374[1] + kernel_img_mul_374[2] + 
                kernel_img_mul_374[3] + kernel_img_mul_374[4] + kernel_img_mul_374[5] + 
                kernel_img_mul_374[6] + kernel_img_mul_374[7] + kernel_img_mul_374[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[2999:2992] <= 'd0;
  else if (current_state==ST_START)
    blur_din[2999:2992] <= kernel_img_sum_374[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2999:2992] <= 'd0;
end

wire  [25:0]  kernel_img_mul_375[0:8];
assign kernel_img_mul_375[0] = buffer_data_2[2999:2992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_375[1] = buffer_data_2[3007:3000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_375[2] = buffer_data_2[3015:3008] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_375[3] = buffer_data_1[2999:2992] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_375[4] = buffer_data_1[3007:3000] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_375[5] = buffer_data_1[3015:3008] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_375[6] = buffer_data_0[2999:2992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_375[7] = buffer_data_0[3007:3000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_375[8] = buffer_data_0[3015:3008] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_375 = kernel_img_mul_375[0] + kernel_img_mul_375[1] + kernel_img_mul_375[2] + 
                kernel_img_mul_375[3] + kernel_img_mul_375[4] + kernel_img_mul_375[5] + 
                kernel_img_mul_375[6] + kernel_img_mul_375[7] + kernel_img_mul_375[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3007:3000] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3007:3000] <= kernel_img_sum_375[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3007:3000] <= 'd0;
end

wire  [25:0]  kernel_img_mul_376[0:8];
assign kernel_img_mul_376[0] = buffer_data_2[3007:3000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_376[1] = buffer_data_2[3015:3008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_376[2] = buffer_data_2[3023:3016] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_376[3] = buffer_data_1[3007:3000] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_376[4] = buffer_data_1[3015:3008] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_376[5] = buffer_data_1[3023:3016] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_376[6] = buffer_data_0[3007:3000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_376[7] = buffer_data_0[3015:3008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_376[8] = buffer_data_0[3023:3016] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_376 = kernel_img_mul_376[0] + kernel_img_mul_376[1] + kernel_img_mul_376[2] + 
                kernel_img_mul_376[3] + kernel_img_mul_376[4] + kernel_img_mul_376[5] + 
                kernel_img_mul_376[6] + kernel_img_mul_376[7] + kernel_img_mul_376[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3015:3008] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3015:3008] <= kernel_img_sum_376[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3015:3008] <= 'd0;
end

wire  [25:0]  kernel_img_mul_377[0:8];
assign kernel_img_mul_377[0] = buffer_data_2[3015:3008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_377[1] = buffer_data_2[3023:3016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_377[2] = buffer_data_2[3031:3024] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_377[3] = buffer_data_1[3015:3008] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_377[4] = buffer_data_1[3023:3016] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_377[5] = buffer_data_1[3031:3024] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_377[6] = buffer_data_0[3015:3008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_377[7] = buffer_data_0[3023:3016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_377[8] = buffer_data_0[3031:3024] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_377 = kernel_img_mul_377[0] + kernel_img_mul_377[1] + kernel_img_mul_377[2] + 
                kernel_img_mul_377[3] + kernel_img_mul_377[4] + kernel_img_mul_377[5] + 
                kernel_img_mul_377[6] + kernel_img_mul_377[7] + kernel_img_mul_377[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3023:3016] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3023:3016] <= kernel_img_sum_377[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3023:3016] <= 'd0;
end

wire  [25:0]  kernel_img_mul_378[0:8];
assign kernel_img_mul_378[0] = buffer_data_2[3023:3016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_378[1] = buffer_data_2[3031:3024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_378[2] = buffer_data_2[3039:3032] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_378[3] = buffer_data_1[3023:3016] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_378[4] = buffer_data_1[3031:3024] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_378[5] = buffer_data_1[3039:3032] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_378[6] = buffer_data_0[3023:3016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_378[7] = buffer_data_0[3031:3024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_378[8] = buffer_data_0[3039:3032] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_378 = kernel_img_mul_378[0] + kernel_img_mul_378[1] + kernel_img_mul_378[2] + 
                kernel_img_mul_378[3] + kernel_img_mul_378[4] + kernel_img_mul_378[5] + 
                kernel_img_mul_378[6] + kernel_img_mul_378[7] + kernel_img_mul_378[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3031:3024] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3031:3024] <= kernel_img_sum_378[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3031:3024] <= 'd0;
end

wire  [25:0]  kernel_img_mul_379[0:8];
assign kernel_img_mul_379[0] = buffer_data_2[3031:3024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_379[1] = buffer_data_2[3039:3032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_379[2] = buffer_data_2[3047:3040] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_379[3] = buffer_data_1[3031:3024] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_379[4] = buffer_data_1[3039:3032] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_379[5] = buffer_data_1[3047:3040] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_379[6] = buffer_data_0[3031:3024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_379[7] = buffer_data_0[3039:3032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_379[8] = buffer_data_0[3047:3040] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_379 = kernel_img_mul_379[0] + kernel_img_mul_379[1] + kernel_img_mul_379[2] + 
                kernel_img_mul_379[3] + kernel_img_mul_379[4] + kernel_img_mul_379[5] + 
                kernel_img_mul_379[6] + kernel_img_mul_379[7] + kernel_img_mul_379[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3039:3032] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3039:3032] <= kernel_img_sum_379[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3039:3032] <= 'd0;
end

wire  [25:0]  kernel_img_mul_380[0:8];
assign kernel_img_mul_380[0] = buffer_data_2[3039:3032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_380[1] = buffer_data_2[3047:3040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_380[2] = buffer_data_2[3055:3048] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_380[3] = buffer_data_1[3039:3032] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_380[4] = buffer_data_1[3047:3040] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_380[5] = buffer_data_1[3055:3048] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_380[6] = buffer_data_0[3039:3032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_380[7] = buffer_data_0[3047:3040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_380[8] = buffer_data_0[3055:3048] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_380 = kernel_img_mul_380[0] + kernel_img_mul_380[1] + kernel_img_mul_380[2] + 
                kernel_img_mul_380[3] + kernel_img_mul_380[4] + kernel_img_mul_380[5] + 
                kernel_img_mul_380[6] + kernel_img_mul_380[7] + kernel_img_mul_380[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3047:3040] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3047:3040] <= kernel_img_sum_380[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3047:3040] <= 'd0;
end

wire  [25:0]  kernel_img_mul_381[0:8];
assign kernel_img_mul_381[0] = buffer_data_2[3047:3040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_381[1] = buffer_data_2[3055:3048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_381[2] = buffer_data_2[3063:3056] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_381[3] = buffer_data_1[3047:3040] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_381[4] = buffer_data_1[3055:3048] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_381[5] = buffer_data_1[3063:3056] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_381[6] = buffer_data_0[3047:3040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_381[7] = buffer_data_0[3055:3048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_381[8] = buffer_data_0[3063:3056] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_381 = kernel_img_mul_381[0] + kernel_img_mul_381[1] + kernel_img_mul_381[2] + 
                kernel_img_mul_381[3] + kernel_img_mul_381[4] + kernel_img_mul_381[5] + 
                kernel_img_mul_381[6] + kernel_img_mul_381[7] + kernel_img_mul_381[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3055:3048] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3055:3048] <= kernel_img_sum_381[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3055:3048] <= 'd0;
end

wire  [25:0]  kernel_img_mul_382[0:8];
assign kernel_img_mul_382[0] = buffer_data_2[3055:3048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_382[1] = buffer_data_2[3063:3056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_382[2] = buffer_data_2[3071:3064] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_382[3] = buffer_data_1[3055:3048] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_382[4] = buffer_data_1[3063:3056] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_382[5] = buffer_data_1[3071:3064] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_382[6] = buffer_data_0[3055:3048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_382[7] = buffer_data_0[3063:3056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_382[8] = buffer_data_0[3071:3064] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_382 = kernel_img_mul_382[0] + kernel_img_mul_382[1] + kernel_img_mul_382[2] + 
                kernel_img_mul_382[3] + kernel_img_mul_382[4] + kernel_img_mul_382[5] + 
                kernel_img_mul_382[6] + kernel_img_mul_382[7] + kernel_img_mul_382[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3063:3056] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3063:3056] <= kernel_img_sum_382[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3063:3056] <= 'd0;
end

wire  [25:0]  kernel_img_mul_383[0:8];
assign kernel_img_mul_383[0] = buffer_data_2[3063:3056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_383[1] = buffer_data_2[3071:3064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_383[2] = buffer_data_2[3079:3072] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_383[3] = buffer_data_1[3063:3056] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_383[4] = buffer_data_1[3071:3064] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_383[5] = buffer_data_1[3079:3072] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_383[6] = buffer_data_0[3063:3056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_383[7] = buffer_data_0[3071:3064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_383[8] = buffer_data_0[3079:3072] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_383 = kernel_img_mul_383[0] + kernel_img_mul_383[1] + kernel_img_mul_383[2] + 
                kernel_img_mul_383[3] + kernel_img_mul_383[4] + kernel_img_mul_383[5] + 
                kernel_img_mul_383[6] + kernel_img_mul_383[7] + kernel_img_mul_383[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3071:3064] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3071:3064] <= kernel_img_sum_383[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3071:3064] <= 'd0;
end

wire  [25:0]  kernel_img_mul_384[0:8];
assign kernel_img_mul_384[0] = buffer_data_2[3071:3064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_384[1] = buffer_data_2[3079:3072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_384[2] = buffer_data_2[3087:3080] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_384[3] = buffer_data_1[3071:3064] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_384[4] = buffer_data_1[3079:3072] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_384[5] = buffer_data_1[3087:3080] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_384[6] = buffer_data_0[3071:3064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_384[7] = buffer_data_0[3079:3072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_384[8] = buffer_data_0[3087:3080] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_384 = kernel_img_mul_384[0] + kernel_img_mul_384[1] + kernel_img_mul_384[2] + 
                kernel_img_mul_384[3] + kernel_img_mul_384[4] + kernel_img_mul_384[5] + 
                kernel_img_mul_384[6] + kernel_img_mul_384[7] + kernel_img_mul_384[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3079:3072] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3079:3072] <= kernel_img_sum_384[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3079:3072] <= 'd0;
end

wire  [25:0]  kernel_img_mul_385[0:8];
assign kernel_img_mul_385[0] = buffer_data_2[3079:3072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_385[1] = buffer_data_2[3087:3080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_385[2] = buffer_data_2[3095:3088] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_385[3] = buffer_data_1[3079:3072] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_385[4] = buffer_data_1[3087:3080] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_385[5] = buffer_data_1[3095:3088] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_385[6] = buffer_data_0[3079:3072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_385[7] = buffer_data_0[3087:3080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_385[8] = buffer_data_0[3095:3088] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_385 = kernel_img_mul_385[0] + kernel_img_mul_385[1] + kernel_img_mul_385[2] + 
                kernel_img_mul_385[3] + kernel_img_mul_385[4] + kernel_img_mul_385[5] + 
                kernel_img_mul_385[6] + kernel_img_mul_385[7] + kernel_img_mul_385[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3087:3080] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3087:3080] <= kernel_img_sum_385[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3087:3080] <= 'd0;
end

wire  [25:0]  kernel_img_mul_386[0:8];
assign kernel_img_mul_386[0] = buffer_data_2[3087:3080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_386[1] = buffer_data_2[3095:3088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_386[2] = buffer_data_2[3103:3096] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_386[3] = buffer_data_1[3087:3080] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_386[4] = buffer_data_1[3095:3088] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_386[5] = buffer_data_1[3103:3096] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_386[6] = buffer_data_0[3087:3080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_386[7] = buffer_data_0[3095:3088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_386[8] = buffer_data_0[3103:3096] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_386 = kernel_img_mul_386[0] + kernel_img_mul_386[1] + kernel_img_mul_386[2] + 
                kernel_img_mul_386[3] + kernel_img_mul_386[4] + kernel_img_mul_386[5] + 
                kernel_img_mul_386[6] + kernel_img_mul_386[7] + kernel_img_mul_386[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3095:3088] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3095:3088] <= kernel_img_sum_386[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3095:3088] <= 'd0;
end

wire  [25:0]  kernel_img_mul_387[0:8];
assign kernel_img_mul_387[0] = buffer_data_2[3095:3088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_387[1] = buffer_data_2[3103:3096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_387[2] = buffer_data_2[3111:3104] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_387[3] = buffer_data_1[3095:3088] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_387[4] = buffer_data_1[3103:3096] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_387[5] = buffer_data_1[3111:3104] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_387[6] = buffer_data_0[3095:3088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_387[7] = buffer_data_0[3103:3096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_387[8] = buffer_data_0[3111:3104] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_387 = kernel_img_mul_387[0] + kernel_img_mul_387[1] + kernel_img_mul_387[2] + 
                kernel_img_mul_387[3] + kernel_img_mul_387[4] + kernel_img_mul_387[5] + 
                kernel_img_mul_387[6] + kernel_img_mul_387[7] + kernel_img_mul_387[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3103:3096] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3103:3096] <= kernel_img_sum_387[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3103:3096] <= 'd0;
end

wire  [25:0]  kernel_img_mul_388[0:8];
assign kernel_img_mul_388[0] = buffer_data_2[3103:3096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_388[1] = buffer_data_2[3111:3104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_388[2] = buffer_data_2[3119:3112] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_388[3] = buffer_data_1[3103:3096] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_388[4] = buffer_data_1[3111:3104] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_388[5] = buffer_data_1[3119:3112] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_388[6] = buffer_data_0[3103:3096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_388[7] = buffer_data_0[3111:3104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_388[8] = buffer_data_0[3119:3112] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_388 = kernel_img_mul_388[0] + kernel_img_mul_388[1] + kernel_img_mul_388[2] + 
                kernel_img_mul_388[3] + kernel_img_mul_388[4] + kernel_img_mul_388[5] + 
                kernel_img_mul_388[6] + kernel_img_mul_388[7] + kernel_img_mul_388[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3111:3104] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3111:3104] <= kernel_img_sum_388[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3111:3104] <= 'd0;
end

wire  [25:0]  kernel_img_mul_389[0:8];
assign kernel_img_mul_389[0] = buffer_data_2[3111:3104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_389[1] = buffer_data_2[3119:3112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_389[2] = buffer_data_2[3127:3120] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_389[3] = buffer_data_1[3111:3104] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_389[4] = buffer_data_1[3119:3112] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_389[5] = buffer_data_1[3127:3120] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_389[6] = buffer_data_0[3111:3104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_389[7] = buffer_data_0[3119:3112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_389[8] = buffer_data_0[3127:3120] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_389 = kernel_img_mul_389[0] + kernel_img_mul_389[1] + kernel_img_mul_389[2] + 
                kernel_img_mul_389[3] + kernel_img_mul_389[4] + kernel_img_mul_389[5] + 
                kernel_img_mul_389[6] + kernel_img_mul_389[7] + kernel_img_mul_389[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3119:3112] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3119:3112] <= kernel_img_sum_389[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3119:3112] <= 'd0;
end

wire  [25:0]  kernel_img_mul_390[0:8];
assign kernel_img_mul_390[0] = buffer_data_2[3119:3112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_390[1] = buffer_data_2[3127:3120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_390[2] = buffer_data_2[3135:3128] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_390[3] = buffer_data_1[3119:3112] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_390[4] = buffer_data_1[3127:3120] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_390[5] = buffer_data_1[3135:3128] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_390[6] = buffer_data_0[3119:3112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_390[7] = buffer_data_0[3127:3120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_390[8] = buffer_data_0[3135:3128] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_390 = kernel_img_mul_390[0] + kernel_img_mul_390[1] + kernel_img_mul_390[2] + 
                kernel_img_mul_390[3] + kernel_img_mul_390[4] + kernel_img_mul_390[5] + 
                kernel_img_mul_390[6] + kernel_img_mul_390[7] + kernel_img_mul_390[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3127:3120] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3127:3120] <= kernel_img_sum_390[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3127:3120] <= 'd0;
end

wire  [25:0]  kernel_img_mul_391[0:8];
assign kernel_img_mul_391[0] = buffer_data_2[3127:3120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_391[1] = buffer_data_2[3135:3128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_391[2] = buffer_data_2[3143:3136] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_391[3] = buffer_data_1[3127:3120] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_391[4] = buffer_data_1[3135:3128] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_391[5] = buffer_data_1[3143:3136] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_391[6] = buffer_data_0[3127:3120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_391[7] = buffer_data_0[3135:3128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_391[8] = buffer_data_0[3143:3136] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_391 = kernel_img_mul_391[0] + kernel_img_mul_391[1] + kernel_img_mul_391[2] + 
                kernel_img_mul_391[3] + kernel_img_mul_391[4] + kernel_img_mul_391[5] + 
                kernel_img_mul_391[6] + kernel_img_mul_391[7] + kernel_img_mul_391[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3135:3128] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3135:3128] <= kernel_img_sum_391[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3135:3128] <= 'd0;
end

wire  [25:0]  kernel_img_mul_392[0:8];
assign kernel_img_mul_392[0] = buffer_data_2[3135:3128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_392[1] = buffer_data_2[3143:3136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_392[2] = buffer_data_2[3151:3144] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_392[3] = buffer_data_1[3135:3128] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_392[4] = buffer_data_1[3143:3136] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_392[5] = buffer_data_1[3151:3144] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_392[6] = buffer_data_0[3135:3128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_392[7] = buffer_data_0[3143:3136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_392[8] = buffer_data_0[3151:3144] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_392 = kernel_img_mul_392[0] + kernel_img_mul_392[1] + kernel_img_mul_392[2] + 
                kernel_img_mul_392[3] + kernel_img_mul_392[4] + kernel_img_mul_392[5] + 
                kernel_img_mul_392[6] + kernel_img_mul_392[7] + kernel_img_mul_392[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3143:3136] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3143:3136] <= kernel_img_sum_392[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3143:3136] <= 'd0;
end

wire  [25:0]  kernel_img_mul_393[0:8];
assign kernel_img_mul_393[0] = buffer_data_2[3143:3136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_393[1] = buffer_data_2[3151:3144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_393[2] = buffer_data_2[3159:3152] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_393[3] = buffer_data_1[3143:3136] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_393[4] = buffer_data_1[3151:3144] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_393[5] = buffer_data_1[3159:3152] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_393[6] = buffer_data_0[3143:3136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_393[7] = buffer_data_0[3151:3144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_393[8] = buffer_data_0[3159:3152] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_393 = kernel_img_mul_393[0] + kernel_img_mul_393[1] + kernel_img_mul_393[2] + 
                kernel_img_mul_393[3] + kernel_img_mul_393[4] + kernel_img_mul_393[5] + 
                kernel_img_mul_393[6] + kernel_img_mul_393[7] + kernel_img_mul_393[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3151:3144] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3151:3144] <= kernel_img_sum_393[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3151:3144] <= 'd0;
end

wire  [25:0]  kernel_img_mul_394[0:8];
assign kernel_img_mul_394[0] = buffer_data_2[3151:3144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_394[1] = buffer_data_2[3159:3152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_394[2] = buffer_data_2[3167:3160] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_394[3] = buffer_data_1[3151:3144] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_394[4] = buffer_data_1[3159:3152] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_394[5] = buffer_data_1[3167:3160] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_394[6] = buffer_data_0[3151:3144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_394[7] = buffer_data_0[3159:3152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_394[8] = buffer_data_0[3167:3160] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_394 = kernel_img_mul_394[0] + kernel_img_mul_394[1] + kernel_img_mul_394[2] + 
                kernel_img_mul_394[3] + kernel_img_mul_394[4] + kernel_img_mul_394[5] + 
                kernel_img_mul_394[6] + kernel_img_mul_394[7] + kernel_img_mul_394[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3159:3152] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3159:3152] <= kernel_img_sum_394[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3159:3152] <= 'd0;
end

wire  [25:0]  kernel_img_mul_395[0:8];
assign kernel_img_mul_395[0] = buffer_data_2[3159:3152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_395[1] = buffer_data_2[3167:3160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_395[2] = buffer_data_2[3175:3168] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_395[3] = buffer_data_1[3159:3152] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_395[4] = buffer_data_1[3167:3160] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_395[5] = buffer_data_1[3175:3168] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_395[6] = buffer_data_0[3159:3152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_395[7] = buffer_data_0[3167:3160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_395[8] = buffer_data_0[3175:3168] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_395 = kernel_img_mul_395[0] + kernel_img_mul_395[1] + kernel_img_mul_395[2] + 
                kernel_img_mul_395[3] + kernel_img_mul_395[4] + kernel_img_mul_395[5] + 
                kernel_img_mul_395[6] + kernel_img_mul_395[7] + kernel_img_mul_395[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3167:3160] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3167:3160] <= kernel_img_sum_395[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3167:3160] <= 'd0;
end

wire  [25:0]  kernel_img_mul_396[0:8];
assign kernel_img_mul_396[0] = buffer_data_2[3167:3160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_396[1] = buffer_data_2[3175:3168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_396[2] = buffer_data_2[3183:3176] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_396[3] = buffer_data_1[3167:3160] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_396[4] = buffer_data_1[3175:3168] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_396[5] = buffer_data_1[3183:3176] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_396[6] = buffer_data_0[3167:3160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_396[7] = buffer_data_0[3175:3168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_396[8] = buffer_data_0[3183:3176] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_396 = kernel_img_mul_396[0] + kernel_img_mul_396[1] + kernel_img_mul_396[2] + 
                kernel_img_mul_396[3] + kernel_img_mul_396[4] + kernel_img_mul_396[5] + 
                kernel_img_mul_396[6] + kernel_img_mul_396[7] + kernel_img_mul_396[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3175:3168] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3175:3168] <= kernel_img_sum_396[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3175:3168] <= 'd0;
end

wire  [25:0]  kernel_img_mul_397[0:8];
assign kernel_img_mul_397[0] = buffer_data_2[3175:3168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_397[1] = buffer_data_2[3183:3176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_397[2] = buffer_data_2[3191:3184] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_397[3] = buffer_data_1[3175:3168] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_397[4] = buffer_data_1[3183:3176] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_397[5] = buffer_data_1[3191:3184] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_397[6] = buffer_data_0[3175:3168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_397[7] = buffer_data_0[3183:3176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_397[8] = buffer_data_0[3191:3184] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_397 = kernel_img_mul_397[0] + kernel_img_mul_397[1] + kernel_img_mul_397[2] + 
                kernel_img_mul_397[3] + kernel_img_mul_397[4] + kernel_img_mul_397[5] + 
                kernel_img_mul_397[6] + kernel_img_mul_397[7] + kernel_img_mul_397[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3183:3176] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3183:3176] <= kernel_img_sum_397[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3183:3176] <= 'd0;
end

wire  [25:0]  kernel_img_mul_398[0:8];
assign kernel_img_mul_398[0] = buffer_data_2[3183:3176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_398[1] = buffer_data_2[3191:3184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_398[2] = buffer_data_2[3199:3192] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_398[3] = buffer_data_1[3183:3176] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_398[4] = buffer_data_1[3191:3184] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_398[5] = buffer_data_1[3199:3192] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_398[6] = buffer_data_0[3183:3176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_398[7] = buffer_data_0[3191:3184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_398[8] = buffer_data_0[3199:3192] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_398 = kernel_img_mul_398[0] + kernel_img_mul_398[1] + kernel_img_mul_398[2] + 
                kernel_img_mul_398[3] + kernel_img_mul_398[4] + kernel_img_mul_398[5] + 
                kernel_img_mul_398[6] + kernel_img_mul_398[7] + kernel_img_mul_398[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3191:3184] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3191:3184] <= kernel_img_sum_398[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3191:3184] <= 'd0;
end

wire  [25:0]  kernel_img_mul_399[0:8];
assign kernel_img_mul_399[0] = buffer_data_2[3191:3184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_399[1] = buffer_data_2[3199:3192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_399[2] = buffer_data_2[3207:3200] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_399[3] = buffer_data_1[3191:3184] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_399[4] = buffer_data_1[3199:3192] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_399[5] = buffer_data_1[3207:3200] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_399[6] = buffer_data_0[3191:3184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_399[7] = buffer_data_0[3199:3192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_399[8] = buffer_data_0[3207:3200] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_399 = kernel_img_mul_399[0] + kernel_img_mul_399[1] + kernel_img_mul_399[2] + 
                kernel_img_mul_399[3] + kernel_img_mul_399[4] + kernel_img_mul_399[5] + 
                kernel_img_mul_399[6] + kernel_img_mul_399[7] + kernel_img_mul_399[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3199:3192] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3199:3192] <= kernel_img_sum_399[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3199:3192] <= 'd0;
end

wire  [25:0]  kernel_img_mul_400[0:8];
assign kernel_img_mul_400[0] = buffer_data_2[3199:3192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_400[1] = buffer_data_2[3207:3200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_400[2] = buffer_data_2[3215:3208] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_400[3] = buffer_data_1[3199:3192] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_400[4] = buffer_data_1[3207:3200] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_400[5] = buffer_data_1[3215:3208] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_400[6] = buffer_data_0[3199:3192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_400[7] = buffer_data_0[3207:3200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_400[8] = buffer_data_0[3215:3208] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_400 = kernel_img_mul_400[0] + kernel_img_mul_400[1] + kernel_img_mul_400[2] + 
                kernel_img_mul_400[3] + kernel_img_mul_400[4] + kernel_img_mul_400[5] + 
                kernel_img_mul_400[6] + kernel_img_mul_400[7] + kernel_img_mul_400[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3207:3200] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3207:3200] <= kernel_img_sum_400[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3207:3200] <= 'd0;
end

wire  [25:0]  kernel_img_mul_401[0:8];
assign kernel_img_mul_401[0] = buffer_data_2[3207:3200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_401[1] = buffer_data_2[3215:3208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_401[2] = buffer_data_2[3223:3216] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_401[3] = buffer_data_1[3207:3200] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_401[4] = buffer_data_1[3215:3208] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_401[5] = buffer_data_1[3223:3216] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_401[6] = buffer_data_0[3207:3200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_401[7] = buffer_data_0[3215:3208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_401[8] = buffer_data_0[3223:3216] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_401 = kernel_img_mul_401[0] + kernel_img_mul_401[1] + kernel_img_mul_401[2] + 
                kernel_img_mul_401[3] + kernel_img_mul_401[4] + kernel_img_mul_401[5] + 
                kernel_img_mul_401[6] + kernel_img_mul_401[7] + kernel_img_mul_401[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3215:3208] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3215:3208] <= kernel_img_sum_401[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3215:3208] <= 'd0;
end

wire  [25:0]  kernel_img_mul_402[0:8];
assign kernel_img_mul_402[0] = buffer_data_2[3215:3208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_402[1] = buffer_data_2[3223:3216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_402[2] = buffer_data_2[3231:3224] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_402[3] = buffer_data_1[3215:3208] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_402[4] = buffer_data_1[3223:3216] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_402[5] = buffer_data_1[3231:3224] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_402[6] = buffer_data_0[3215:3208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_402[7] = buffer_data_0[3223:3216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_402[8] = buffer_data_0[3231:3224] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_402 = kernel_img_mul_402[0] + kernel_img_mul_402[1] + kernel_img_mul_402[2] + 
                kernel_img_mul_402[3] + kernel_img_mul_402[4] + kernel_img_mul_402[5] + 
                kernel_img_mul_402[6] + kernel_img_mul_402[7] + kernel_img_mul_402[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3223:3216] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3223:3216] <= kernel_img_sum_402[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3223:3216] <= 'd0;
end

wire  [25:0]  kernel_img_mul_403[0:8];
assign kernel_img_mul_403[0] = buffer_data_2[3223:3216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_403[1] = buffer_data_2[3231:3224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_403[2] = buffer_data_2[3239:3232] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_403[3] = buffer_data_1[3223:3216] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_403[4] = buffer_data_1[3231:3224] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_403[5] = buffer_data_1[3239:3232] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_403[6] = buffer_data_0[3223:3216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_403[7] = buffer_data_0[3231:3224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_403[8] = buffer_data_0[3239:3232] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_403 = kernel_img_mul_403[0] + kernel_img_mul_403[1] + kernel_img_mul_403[2] + 
                kernel_img_mul_403[3] + kernel_img_mul_403[4] + kernel_img_mul_403[5] + 
                kernel_img_mul_403[6] + kernel_img_mul_403[7] + kernel_img_mul_403[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3231:3224] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3231:3224] <= kernel_img_sum_403[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3231:3224] <= 'd0;
end

wire  [25:0]  kernel_img_mul_404[0:8];
assign kernel_img_mul_404[0] = buffer_data_2[3231:3224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_404[1] = buffer_data_2[3239:3232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_404[2] = buffer_data_2[3247:3240] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_404[3] = buffer_data_1[3231:3224] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_404[4] = buffer_data_1[3239:3232] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_404[5] = buffer_data_1[3247:3240] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_404[6] = buffer_data_0[3231:3224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_404[7] = buffer_data_0[3239:3232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_404[8] = buffer_data_0[3247:3240] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_404 = kernel_img_mul_404[0] + kernel_img_mul_404[1] + kernel_img_mul_404[2] + 
                kernel_img_mul_404[3] + kernel_img_mul_404[4] + kernel_img_mul_404[5] + 
                kernel_img_mul_404[6] + kernel_img_mul_404[7] + kernel_img_mul_404[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3239:3232] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3239:3232] <= kernel_img_sum_404[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3239:3232] <= 'd0;
end

wire  [25:0]  kernel_img_mul_405[0:8];
assign kernel_img_mul_405[0] = buffer_data_2[3239:3232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_405[1] = buffer_data_2[3247:3240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_405[2] = buffer_data_2[3255:3248] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_405[3] = buffer_data_1[3239:3232] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_405[4] = buffer_data_1[3247:3240] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_405[5] = buffer_data_1[3255:3248] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_405[6] = buffer_data_0[3239:3232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_405[7] = buffer_data_0[3247:3240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_405[8] = buffer_data_0[3255:3248] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_405 = kernel_img_mul_405[0] + kernel_img_mul_405[1] + kernel_img_mul_405[2] + 
                kernel_img_mul_405[3] + kernel_img_mul_405[4] + kernel_img_mul_405[5] + 
                kernel_img_mul_405[6] + kernel_img_mul_405[7] + kernel_img_mul_405[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3247:3240] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3247:3240] <= kernel_img_sum_405[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3247:3240] <= 'd0;
end

wire  [25:0]  kernel_img_mul_406[0:8];
assign kernel_img_mul_406[0] = buffer_data_2[3247:3240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_406[1] = buffer_data_2[3255:3248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_406[2] = buffer_data_2[3263:3256] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_406[3] = buffer_data_1[3247:3240] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_406[4] = buffer_data_1[3255:3248] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_406[5] = buffer_data_1[3263:3256] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_406[6] = buffer_data_0[3247:3240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_406[7] = buffer_data_0[3255:3248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_406[8] = buffer_data_0[3263:3256] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_406 = kernel_img_mul_406[0] + kernel_img_mul_406[1] + kernel_img_mul_406[2] + 
                kernel_img_mul_406[3] + kernel_img_mul_406[4] + kernel_img_mul_406[5] + 
                kernel_img_mul_406[6] + kernel_img_mul_406[7] + kernel_img_mul_406[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3255:3248] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3255:3248] <= kernel_img_sum_406[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3255:3248] <= 'd0;
end

wire  [25:0]  kernel_img_mul_407[0:8];
assign kernel_img_mul_407[0] = buffer_data_2[3255:3248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_407[1] = buffer_data_2[3263:3256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_407[2] = buffer_data_2[3271:3264] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_407[3] = buffer_data_1[3255:3248] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_407[4] = buffer_data_1[3263:3256] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_407[5] = buffer_data_1[3271:3264] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_407[6] = buffer_data_0[3255:3248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_407[7] = buffer_data_0[3263:3256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_407[8] = buffer_data_0[3271:3264] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_407 = kernel_img_mul_407[0] + kernel_img_mul_407[1] + kernel_img_mul_407[2] + 
                kernel_img_mul_407[3] + kernel_img_mul_407[4] + kernel_img_mul_407[5] + 
                kernel_img_mul_407[6] + kernel_img_mul_407[7] + kernel_img_mul_407[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3263:3256] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3263:3256] <= kernel_img_sum_407[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3263:3256] <= 'd0;
end

wire  [25:0]  kernel_img_mul_408[0:8];
assign kernel_img_mul_408[0] = buffer_data_2[3263:3256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_408[1] = buffer_data_2[3271:3264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_408[2] = buffer_data_2[3279:3272] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_408[3] = buffer_data_1[3263:3256] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_408[4] = buffer_data_1[3271:3264] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_408[5] = buffer_data_1[3279:3272] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_408[6] = buffer_data_0[3263:3256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_408[7] = buffer_data_0[3271:3264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_408[8] = buffer_data_0[3279:3272] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_408 = kernel_img_mul_408[0] + kernel_img_mul_408[1] + kernel_img_mul_408[2] + 
                kernel_img_mul_408[3] + kernel_img_mul_408[4] + kernel_img_mul_408[5] + 
                kernel_img_mul_408[6] + kernel_img_mul_408[7] + kernel_img_mul_408[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3271:3264] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3271:3264] <= kernel_img_sum_408[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3271:3264] <= 'd0;
end

wire  [25:0]  kernel_img_mul_409[0:8];
assign kernel_img_mul_409[0] = buffer_data_2[3271:3264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_409[1] = buffer_data_2[3279:3272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_409[2] = buffer_data_2[3287:3280] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_409[3] = buffer_data_1[3271:3264] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_409[4] = buffer_data_1[3279:3272] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_409[5] = buffer_data_1[3287:3280] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_409[6] = buffer_data_0[3271:3264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_409[7] = buffer_data_0[3279:3272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_409[8] = buffer_data_0[3287:3280] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_409 = kernel_img_mul_409[0] + kernel_img_mul_409[1] + kernel_img_mul_409[2] + 
                kernel_img_mul_409[3] + kernel_img_mul_409[4] + kernel_img_mul_409[5] + 
                kernel_img_mul_409[6] + kernel_img_mul_409[7] + kernel_img_mul_409[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3279:3272] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3279:3272] <= kernel_img_sum_409[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3279:3272] <= 'd0;
end

wire  [25:0]  kernel_img_mul_410[0:8];
assign kernel_img_mul_410[0] = buffer_data_2[3279:3272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_410[1] = buffer_data_2[3287:3280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_410[2] = buffer_data_2[3295:3288] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_410[3] = buffer_data_1[3279:3272] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_410[4] = buffer_data_1[3287:3280] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_410[5] = buffer_data_1[3295:3288] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_410[6] = buffer_data_0[3279:3272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_410[7] = buffer_data_0[3287:3280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_410[8] = buffer_data_0[3295:3288] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_410 = kernel_img_mul_410[0] + kernel_img_mul_410[1] + kernel_img_mul_410[2] + 
                kernel_img_mul_410[3] + kernel_img_mul_410[4] + kernel_img_mul_410[5] + 
                kernel_img_mul_410[6] + kernel_img_mul_410[7] + kernel_img_mul_410[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3287:3280] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3287:3280] <= kernel_img_sum_410[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3287:3280] <= 'd0;
end

wire  [25:0]  kernel_img_mul_411[0:8];
assign kernel_img_mul_411[0] = buffer_data_2[3287:3280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_411[1] = buffer_data_2[3295:3288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_411[2] = buffer_data_2[3303:3296] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_411[3] = buffer_data_1[3287:3280] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_411[4] = buffer_data_1[3295:3288] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_411[5] = buffer_data_1[3303:3296] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_411[6] = buffer_data_0[3287:3280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_411[7] = buffer_data_0[3295:3288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_411[8] = buffer_data_0[3303:3296] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_411 = kernel_img_mul_411[0] + kernel_img_mul_411[1] + kernel_img_mul_411[2] + 
                kernel_img_mul_411[3] + kernel_img_mul_411[4] + kernel_img_mul_411[5] + 
                kernel_img_mul_411[6] + kernel_img_mul_411[7] + kernel_img_mul_411[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3295:3288] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3295:3288] <= kernel_img_sum_411[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3295:3288] <= 'd0;
end

wire  [25:0]  kernel_img_mul_412[0:8];
assign kernel_img_mul_412[0] = buffer_data_2[3295:3288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_412[1] = buffer_data_2[3303:3296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_412[2] = buffer_data_2[3311:3304] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_412[3] = buffer_data_1[3295:3288] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_412[4] = buffer_data_1[3303:3296] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_412[5] = buffer_data_1[3311:3304] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_412[6] = buffer_data_0[3295:3288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_412[7] = buffer_data_0[3303:3296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_412[8] = buffer_data_0[3311:3304] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_412 = kernel_img_mul_412[0] + kernel_img_mul_412[1] + kernel_img_mul_412[2] + 
                kernel_img_mul_412[3] + kernel_img_mul_412[4] + kernel_img_mul_412[5] + 
                kernel_img_mul_412[6] + kernel_img_mul_412[7] + kernel_img_mul_412[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3303:3296] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3303:3296] <= kernel_img_sum_412[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3303:3296] <= 'd0;
end

wire  [25:0]  kernel_img_mul_413[0:8];
assign kernel_img_mul_413[0] = buffer_data_2[3303:3296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_413[1] = buffer_data_2[3311:3304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_413[2] = buffer_data_2[3319:3312] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_413[3] = buffer_data_1[3303:3296] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_413[4] = buffer_data_1[3311:3304] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_413[5] = buffer_data_1[3319:3312] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_413[6] = buffer_data_0[3303:3296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_413[7] = buffer_data_0[3311:3304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_413[8] = buffer_data_0[3319:3312] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_413 = kernel_img_mul_413[0] + kernel_img_mul_413[1] + kernel_img_mul_413[2] + 
                kernel_img_mul_413[3] + kernel_img_mul_413[4] + kernel_img_mul_413[5] + 
                kernel_img_mul_413[6] + kernel_img_mul_413[7] + kernel_img_mul_413[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3311:3304] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3311:3304] <= kernel_img_sum_413[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3311:3304] <= 'd0;
end

wire  [25:0]  kernel_img_mul_414[0:8];
assign kernel_img_mul_414[0] = buffer_data_2[3311:3304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_414[1] = buffer_data_2[3319:3312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_414[2] = buffer_data_2[3327:3320] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_414[3] = buffer_data_1[3311:3304] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_414[4] = buffer_data_1[3319:3312] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_414[5] = buffer_data_1[3327:3320] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_414[6] = buffer_data_0[3311:3304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_414[7] = buffer_data_0[3319:3312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_414[8] = buffer_data_0[3327:3320] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_414 = kernel_img_mul_414[0] + kernel_img_mul_414[1] + kernel_img_mul_414[2] + 
                kernel_img_mul_414[3] + kernel_img_mul_414[4] + kernel_img_mul_414[5] + 
                kernel_img_mul_414[6] + kernel_img_mul_414[7] + kernel_img_mul_414[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3319:3312] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3319:3312] <= kernel_img_sum_414[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3319:3312] <= 'd0;
end

wire  [25:0]  kernel_img_mul_415[0:8];
assign kernel_img_mul_415[0] = buffer_data_2[3319:3312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_415[1] = buffer_data_2[3327:3320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_415[2] = buffer_data_2[3335:3328] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_415[3] = buffer_data_1[3319:3312] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_415[4] = buffer_data_1[3327:3320] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_415[5] = buffer_data_1[3335:3328] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_415[6] = buffer_data_0[3319:3312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_415[7] = buffer_data_0[3327:3320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_415[8] = buffer_data_0[3335:3328] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_415 = kernel_img_mul_415[0] + kernel_img_mul_415[1] + kernel_img_mul_415[2] + 
                kernel_img_mul_415[3] + kernel_img_mul_415[4] + kernel_img_mul_415[5] + 
                kernel_img_mul_415[6] + kernel_img_mul_415[7] + kernel_img_mul_415[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3327:3320] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3327:3320] <= kernel_img_sum_415[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3327:3320] <= 'd0;
end

wire  [25:0]  kernel_img_mul_416[0:8];
assign kernel_img_mul_416[0] = buffer_data_2[3327:3320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_416[1] = buffer_data_2[3335:3328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_416[2] = buffer_data_2[3343:3336] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_416[3] = buffer_data_1[3327:3320] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_416[4] = buffer_data_1[3335:3328] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_416[5] = buffer_data_1[3343:3336] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_416[6] = buffer_data_0[3327:3320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_416[7] = buffer_data_0[3335:3328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_416[8] = buffer_data_0[3343:3336] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_416 = kernel_img_mul_416[0] + kernel_img_mul_416[1] + kernel_img_mul_416[2] + 
                kernel_img_mul_416[3] + kernel_img_mul_416[4] + kernel_img_mul_416[5] + 
                kernel_img_mul_416[6] + kernel_img_mul_416[7] + kernel_img_mul_416[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3335:3328] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3335:3328] <= kernel_img_sum_416[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3335:3328] <= 'd0;
end

wire  [25:0]  kernel_img_mul_417[0:8];
assign kernel_img_mul_417[0] = buffer_data_2[3335:3328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_417[1] = buffer_data_2[3343:3336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_417[2] = buffer_data_2[3351:3344] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_417[3] = buffer_data_1[3335:3328] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_417[4] = buffer_data_1[3343:3336] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_417[5] = buffer_data_1[3351:3344] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_417[6] = buffer_data_0[3335:3328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_417[7] = buffer_data_0[3343:3336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_417[8] = buffer_data_0[3351:3344] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_417 = kernel_img_mul_417[0] + kernel_img_mul_417[1] + kernel_img_mul_417[2] + 
                kernel_img_mul_417[3] + kernel_img_mul_417[4] + kernel_img_mul_417[5] + 
                kernel_img_mul_417[6] + kernel_img_mul_417[7] + kernel_img_mul_417[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3343:3336] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3343:3336] <= kernel_img_sum_417[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3343:3336] <= 'd0;
end

wire  [25:0]  kernel_img_mul_418[0:8];
assign kernel_img_mul_418[0] = buffer_data_2[3343:3336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_418[1] = buffer_data_2[3351:3344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_418[2] = buffer_data_2[3359:3352] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_418[3] = buffer_data_1[3343:3336] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_418[4] = buffer_data_1[3351:3344] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_418[5] = buffer_data_1[3359:3352] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_418[6] = buffer_data_0[3343:3336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_418[7] = buffer_data_0[3351:3344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_418[8] = buffer_data_0[3359:3352] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_418 = kernel_img_mul_418[0] + kernel_img_mul_418[1] + kernel_img_mul_418[2] + 
                kernel_img_mul_418[3] + kernel_img_mul_418[4] + kernel_img_mul_418[5] + 
                kernel_img_mul_418[6] + kernel_img_mul_418[7] + kernel_img_mul_418[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3351:3344] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3351:3344] <= kernel_img_sum_418[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3351:3344] <= 'd0;
end

wire  [25:0]  kernel_img_mul_419[0:8];
assign kernel_img_mul_419[0] = buffer_data_2[3351:3344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_419[1] = buffer_data_2[3359:3352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_419[2] = buffer_data_2[3367:3360] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_419[3] = buffer_data_1[3351:3344] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_419[4] = buffer_data_1[3359:3352] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_419[5] = buffer_data_1[3367:3360] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_419[6] = buffer_data_0[3351:3344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_419[7] = buffer_data_0[3359:3352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_419[8] = buffer_data_0[3367:3360] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_419 = kernel_img_mul_419[0] + kernel_img_mul_419[1] + kernel_img_mul_419[2] + 
                kernel_img_mul_419[3] + kernel_img_mul_419[4] + kernel_img_mul_419[5] + 
                kernel_img_mul_419[6] + kernel_img_mul_419[7] + kernel_img_mul_419[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3359:3352] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3359:3352] <= kernel_img_sum_419[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3359:3352] <= 'd0;
end

wire  [25:0]  kernel_img_mul_420[0:8];
assign kernel_img_mul_420[0] = buffer_data_2[3359:3352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_420[1] = buffer_data_2[3367:3360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_420[2] = buffer_data_2[3375:3368] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_420[3] = buffer_data_1[3359:3352] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_420[4] = buffer_data_1[3367:3360] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_420[5] = buffer_data_1[3375:3368] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_420[6] = buffer_data_0[3359:3352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_420[7] = buffer_data_0[3367:3360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_420[8] = buffer_data_0[3375:3368] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_420 = kernel_img_mul_420[0] + kernel_img_mul_420[1] + kernel_img_mul_420[2] + 
                kernel_img_mul_420[3] + kernel_img_mul_420[4] + kernel_img_mul_420[5] + 
                kernel_img_mul_420[6] + kernel_img_mul_420[7] + kernel_img_mul_420[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3367:3360] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3367:3360] <= kernel_img_sum_420[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3367:3360] <= 'd0;
end

wire  [25:0]  kernel_img_mul_421[0:8];
assign kernel_img_mul_421[0] = buffer_data_2[3367:3360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_421[1] = buffer_data_2[3375:3368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_421[2] = buffer_data_2[3383:3376] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_421[3] = buffer_data_1[3367:3360] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_421[4] = buffer_data_1[3375:3368] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_421[5] = buffer_data_1[3383:3376] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_421[6] = buffer_data_0[3367:3360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_421[7] = buffer_data_0[3375:3368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_421[8] = buffer_data_0[3383:3376] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_421 = kernel_img_mul_421[0] + kernel_img_mul_421[1] + kernel_img_mul_421[2] + 
                kernel_img_mul_421[3] + kernel_img_mul_421[4] + kernel_img_mul_421[5] + 
                kernel_img_mul_421[6] + kernel_img_mul_421[7] + kernel_img_mul_421[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3375:3368] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3375:3368] <= kernel_img_sum_421[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3375:3368] <= 'd0;
end

wire  [25:0]  kernel_img_mul_422[0:8];
assign kernel_img_mul_422[0] = buffer_data_2[3375:3368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_422[1] = buffer_data_2[3383:3376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_422[2] = buffer_data_2[3391:3384] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_422[3] = buffer_data_1[3375:3368] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_422[4] = buffer_data_1[3383:3376] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_422[5] = buffer_data_1[3391:3384] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_422[6] = buffer_data_0[3375:3368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_422[7] = buffer_data_0[3383:3376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_422[8] = buffer_data_0[3391:3384] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_422 = kernel_img_mul_422[0] + kernel_img_mul_422[1] + kernel_img_mul_422[2] + 
                kernel_img_mul_422[3] + kernel_img_mul_422[4] + kernel_img_mul_422[5] + 
                kernel_img_mul_422[6] + kernel_img_mul_422[7] + kernel_img_mul_422[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3383:3376] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3383:3376] <= kernel_img_sum_422[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3383:3376] <= 'd0;
end

wire  [25:0]  kernel_img_mul_423[0:8];
assign kernel_img_mul_423[0] = buffer_data_2[3383:3376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_423[1] = buffer_data_2[3391:3384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_423[2] = buffer_data_2[3399:3392] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_423[3] = buffer_data_1[3383:3376] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_423[4] = buffer_data_1[3391:3384] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_423[5] = buffer_data_1[3399:3392] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_423[6] = buffer_data_0[3383:3376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_423[7] = buffer_data_0[3391:3384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_423[8] = buffer_data_0[3399:3392] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_423 = kernel_img_mul_423[0] + kernel_img_mul_423[1] + kernel_img_mul_423[2] + 
                kernel_img_mul_423[3] + kernel_img_mul_423[4] + kernel_img_mul_423[5] + 
                kernel_img_mul_423[6] + kernel_img_mul_423[7] + kernel_img_mul_423[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3391:3384] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3391:3384] <= kernel_img_sum_423[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3391:3384] <= 'd0;
end

wire  [25:0]  kernel_img_mul_424[0:8];
assign kernel_img_mul_424[0] = buffer_data_2[3391:3384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_424[1] = buffer_data_2[3399:3392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_424[2] = buffer_data_2[3407:3400] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_424[3] = buffer_data_1[3391:3384] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_424[4] = buffer_data_1[3399:3392] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_424[5] = buffer_data_1[3407:3400] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_424[6] = buffer_data_0[3391:3384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_424[7] = buffer_data_0[3399:3392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_424[8] = buffer_data_0[3407:3400] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_424 = kernel_img_mul_424[0] + kernel_img_mul_424[1] + kernel_img_mul_424[2] + 
                kernel_img_mul_424[3] + kernel_img_mul_424[4] + kernel_img_mul_424[5] + 
                kernel_img_mul_424[6] + kernel_img_mul_424[7] + kernel_img_mul_424[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3399:3392] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3399:3392] <= kernel_img_sum_424[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3399:3392] <= 'd0;
end

wire  [25:0]  kernel_img_mul_425[0:8];
assign kernel_img_mul_425[0] = buffer_data_2[3399:3392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_425[1] = buffer_data_2[3407:3400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_425[2] = buffer_data_2[3415:3408] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_425[3] = buffer_data_1[3399:3392] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_425[4] = buffer_data_1[3407:3400] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_425[5] = buffer_data_1[3415:3408] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_425[6] = buffer_data_0[3399:3392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_425[7] = buffer_data_0[3407:3400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_425[8] = buffer_data_0[3415:3408] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_425 = kernel_img_mul_425[0] + kernel_img_mul_425[1] + kernel_img_mul_425[2] + 
                kernel_img_mul_425[3] + kernel_img_mul_425[4] + kernel_img_mul_425[5] + 
                kernel_img_mul_425[6] + kernel_img_mul_425[7] + kernel_img_mul_425[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3407:3400] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3407:3400] <= kernel_img_sum_425[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3407:3400] <= 'd0;
end

wire  [25:0]  kernel_img_mul_426[0:8];
assign kernel_img_mul_426[0] = buffer_data_2[3407:3400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_426[1] = buffer_data_2[3415:3408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_426[2] = buffer_data_2[3423:3416] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_426[3] = buffer_data_1[3407:3400] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_426[4] = buffer_data_1[3415:3408] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_426[5] = buffer_data_1[3423:3416] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_426[6] = buffer_data_0[3407:3400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_426[7] = buffer_data_0[3415:3408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_426[8] = buffer_data_0[3423:3416] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_426 = kernel_img_mul_426[0] + kernel_img_mul_426[1] + kernel_img_mul_426[2] + 
                kernel_img_mul_426[3] + kernel_img_mul_426[4] + kernel_img_mul_426[5] + 
                kernel_img_mul_426[6] + kernel_img_mul_426[7] + kernel_img_mul_426[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3415:3408] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3415:3408] <= kernel_img_sum_426[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3415:3408] <= 'd0;
end

wire  [25:0]  kernel_img_mul_427[0:8];
assign kernel_img_mul_427[0] = buffer_data_2[3415:3408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_427[1] = buffer_data_2[3423:3416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_427[2] = buffer_data_2[3431:3424] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_427[3] = buffer_data_1[3415:3408] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_427[4] = buffer_data_1[3423:3416] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_427[5] = buffer_data_1[3431:3424] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_427[6] = buffer_data_0[3415:3408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_427[7] = buffer_data_0[3423:3416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_427[8] = buffer_data_0[3431:3424] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_427 = kernel_img_mul_427[0] + kernel_img_mul_427[1] + kernel_img_mul_427[2] + 
                kernel_img_mul_427[3] + kernel_img_mul_427[4] + kernel_img_mul_427[5] + 
                kernel_img_mul_427[6] + kernel_img_mul_427[7] + kernel_img_mul_427[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3423:3416] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3423:3416] <= kernel_img_sum_427[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3423:3416] <= 'd0;
end

wire  [25:0]  kernel_img_mul_428[0:8];
assign kernel_img_mul_428[0] = buffer_data_2[3423:3416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_428[1] = buffer_data_2[3431:3424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_428[2] = buffer_data_2[3439:3432] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_428[3] = buffer_data_1[3423:3416] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_428[4] = buffer_data_1[3431:3424] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_428[5] = buffer_data_1[3439:3432] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_428[6] = buffer_data_0[3423:3416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_428[7] = buffer_data_0[3431:3424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_428[8] = buffer_data_0[3439:3432] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_428 = kernel_img_mul_428[0] + kernel_img_mul_428[1] + kernel_img_mul_428[2] + 
                kernel_img_mul_428[3] + kernel_img_mul_428[4] + kernel_img_mul_428[5] + 
                kernel_img_mul_428[6] + kernel_img_mul_428[7] + kernel_img_mul_428[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3431:3424] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3431:3424] <= kernel_img_sum_428[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3431:3424] <= 'd0;
end

wire  [25:0]  kernel_img_mul_429[0:8];
assign kernel_img_mul_429[0] = buffer_data_2[3431:3424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_429[1] = buffer_data_2[3439:3432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_429[2] = buffer_data_2[3447:3440] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_429[3] = buffer_data_1[3431:3424] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_429[4] = buffer_data_1[3439:3432] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_429[5] = buffer_data_1[3447:3440] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_429[6] = buffer_data_0[3431:3424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_429[7] = buffer_data_0[3439:3432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_429[8] = buffer_data_0[3447:3440] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_429 = kernel_img_mul_429[0] + kernel_img_mul_429[1] + kernel_img_mul_429[2] + 
                kernel_img_mul_429[3] + kernel_img_mul_429[4] + kernel_img_mul_429[5] + 
                kernel_img_mul_429[6] + kernel_img_mul_429[7] + kernel_img_mul_429[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3439:3432] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3439:3432] <= kernel_img_sum_429[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3439:3432] <= 'd0;
end

wire  [25:0]  kernel_img_mul_430[0:8];
assign kernel_img_mul_430[0] = buffer_data_2[3439:3432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_430[1] = buffer_data_2[3447:3440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_430[2] = buffer_data_2[3455:3448] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_430[3] = buffer_data_1[3439:3432] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_430[4] = buffer_data_1[3447:3440] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_430[5] = buffer_data_1[3455:3448] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_430[6] = buffer_data_0[3439:3432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_430[7] = buffer_data_0[3447:3440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_430[8] = buffer_data_0[3455:3448] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_430 = kernel_img_mul_430[0] + kernel_img_mul_430[1] + kernel_img_mul_430[2] + 
                kernel_img_mul_430[3] + kernel_img_mul_430[4] + kernel_img_mul_430[5] + 
                kernel_img_mul_430[6] + kernel_img_mul_430[7] + kernel_img_mul_430[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3447:3440] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3447:3440] <= kernel_img_sum_430[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3447:3440] <= 'd0;
end

wire  [25:0]  kernel_img_mul_431[0:8];
assign kernel_img_mul_431[0] = buffer_data_2[3447:3440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_431[1] = buffer_data_2[3455:3448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_431[2] = buffer_data_2[3463:3456] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_431[3] = buffer_data_1[3447:3440] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_431[4] = buffer_data_1[3455:3448] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_431[5] = buffer_data_1[3463:3456] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_431[6] = buffer_data_0[3447:3440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_431[7] = buffer_data_0[3455:3448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_431[8] = buffer_data_0[3463:3456] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_431 = kernel_img_mul_431[0] + kernel_img_mul_431[1] + kernel_img_mul_431[2] + 
                kernel_img_mul_431[3] + kernel_img_mul_431[4] + kernel_img_mul_431[5] + 
                kernel_img_mul_431[6] + kernel_img_mul_431[7] + kernel_img_mul_431[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3455:3448] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3455:3448] <= kernel_img_sum_431[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3455:3448] <= 'd0;
end

wire  [25:0]  kernel_img_mul_432[0:8];
assign kernel_img_mul_432[0] = buffer_data_2[3455:3448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_432[1] = buffer_data_2[3463:3456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_432[2] = buffer_data_2[3471:3464] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_432[3] = buffer_data_1[3455:3448] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_432[4] = buffer_data_1[3463:3456] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_432[5] = buffer_data_1[3471:3464] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_432[6] = buffer_data_0[3455:3448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_432[7] = buffer_data_0[3463:3456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_432[8] = buffer_data_0[3471:3464] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_432 = kernel_img_mul_432[0] + kernel_img_mul_432[1] + kernel_img_mul_432[2] + 
                kernel_img_mul_432[3] + kernel_img_mul_432[4] + kernel_img_mul_432[5] + 
                kernel_img_mul_432[6] + kernel_img_mul_432[7] + kernel_img_mul_432[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3463:3456] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3463:3456] <= kernel_img_sum_432[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3463:3456] <= 'd0;
end

wire  [25:0]  kernel_img_mul_433[0:8];
assign kernel_img_mul_433[0] = buffer_data_2[3463:3456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_433[1] = buffer_data_2[3471:3464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_433[2] = buffer_data_2[3479:3472] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_433[3] = buffer_data_1[3463:3456] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_433[4] = buffer_data_1[3471:3464] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_433[5] = buffer_data_1[3479:3472] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_433[6] = buffer_data_0[3463:3456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_433[7] = buffer_data_0[3471:3464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_433[8] = buffer_data_0[3479:3472] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_433 = kernel_img_mul_433[0] + kernel_img_mul_433[1] + kernel_img_mul_433[2] + 
                kernel_img_mul_433[3] + kernel_img_mul_433[4] + kernel_img_mul_433[5] + 
                kernel_img_mul_433[6] + kernel_img_mul_433[7] + kernel_img_mul_433[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3471:3464] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3471:3464] <= kernel_img_sum_433[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3471:3464] <= 'd0;
end

wire  [25:0]  kernel_img_mul_434[0:8];
assign kernel_img_mul_434[0] = buffer_data_2[3471:3464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_434[1] = buffer_data_2[3479:3472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_434[2] = buffer_data_2[3487:3480] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_434[3] = buffer_data_1[3471:3464] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_434[4] = buffer_data_1[3479:3472] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_434[5] = buffer_data_1[3487:3480] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_434[6] = buffer_data_0[3471:3464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_434[7] = buffer_data_0[3479:3472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_434[8] = buffer_data_0[3487:3480] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_434 = kernel_img_mul_434[0] + kernel_img_mul_434[1] + kernel_img_mul_434[2] + 
                kernel_img_mul_434[3] + kernel_img_mul_434[4] + kernel_img_mul_434[5] + 
                kernel_img_mul_434[6] + kernel_img_mul_434[7] + kernel_img_mul_434[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3479:3472] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3479:3472] <= kernel_img_sum_434[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3479:3472] <= 'd0;
end

wire  [25:0]  kernel_img_mul_435[0:8];
assign kernel_img_mul_435[0] = buffer_data_2[3479:3472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_435[1] = buffer_data_2[3487:3480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_435[2] = buffer_data_2[3495:3488] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_435[3] = buffer_data_1[3479:3472] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_435[4] = buffer_data_1[3487:3480] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_435[5] = buffer_data_1[3495:3488] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_435[6] = buffer_data_0[3479:3472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_435[7] = buffer_data_0[3487:3480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_435[8] = buffer_data_0[3495:3488] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_435 = kernel_img_mul_435[0] + kernel_img_mul_435[1] + kernel_img_mul_435[2] + 
                kernel_img_mul_435[3] + kernel_img_mul_435[4] + kernel_img_mul_435[5] + 
                kernel_img_mul_435[6] + kernel_img_mul_435[7] + kernel_img_mul_435[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3487:3480] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3487:3480] <= kernel_img_sum_435[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3487:3480] <= 'd0;
end

wire  [25:0]  kernel_img_mul_436[0:8];
assign kernel_img_mul_436[0] = buffer_data_2[3487:3480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_436[1] = buffer_data_2[3495:3488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_436[2] = buffer_data_2[3503:3496] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_436[3] = buffer_data_1[3487:3480] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_436[4] = buffer_data_1[3495:3488] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_436[5] = buffer_data_1[3503:3496] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_436[6] = buffer_data_0[3487:3480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_436[7] = buffer_data_0[3495:3488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_436[8] = buffer_data_0[3503:3496] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_436 = kernel_img_mul_436[0] + kernel_img_mul_436[1] + kernel_img_mul_436[2] + 
                kernel_img_mul_436[3] + kernel_img_mul_436[4] + kernel_img_mul_436[5] + 
                kernel_img_mul_436[6] + kernel_img_mul_436[7] + kernel_img_mul_436[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3495:3488] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3495:3488] <= kernel_img_sum_436[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3495:3488] <= 'd0;
end

wire  [25:0]  kernel_img_mul_437[0:8];
assign kernel_img_mul_437[0] = buffer_data_2[3495:3488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_437[1] = buffer_data_2[3503:3496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_437[2] = buffer_data_2[3511:3504] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_437[3] = buffer_data_1[3495:3488] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_437[4] = buffer_data_1[3503:3496] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_437[5] = buffer_data_1[3511:3504] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_437[6] = buffer_data_0[3495:3488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_437[7] = buffer_data_0[3503:3496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_437[8] = buffer_data_0[3511:3504] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_437 = kernel_img_mul_437[0] + kernel_img_mul_437[1] + kernel_img_mul_437[2] + 
                kernel_img_mul_437[3] + kernel_img_mul_437[4] + kernel_img_mul_437[5] + 
                kernel_img_mul_437[6] + kernel_img_mul_437[7] + kernel_img_mul_437[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3503:3496] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3503:3496] <= kernel_img_sum_437[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3503:3496] <= 'd0;
end

wire  [25:0]  kernel_img_mul_438[0:8];
assign kernel_img_mul_438[0] = buffer_data_2[3503:3496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_438[1] = buffer_data_2[3511:3504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_438[2] = buffer_data_2[3519:3512] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_438[3] = buffer_data_1[3503:3496] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_438[4] = buffer_data_1[3511:3504] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_438[5] = buffer_data_1[3519:3512] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_438[6] = buffer_data_0[3503:3496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_438[7] = buffer_data_0[3511:3504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_438[8] = buffer_data_0[3519:3512] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_438 = kernel_img_mul_438[0] + kernel_img_mul_438[1] + kernel_img_mul_438[2] + 
                kernel_img_mul_438[3] + kernel_img_mul_438[4] + kernel_img_mul_438[5] + 
                kernel_img_mul_438[6] + kernel_img_mul_438[7] + kernel_img_mul_438[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3511:3504] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3511:3504] <= kernel_img_sum_438[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3511:3504] <= 'd0;
end

wire  [25:0]  kernel_img_mul_439[0:8];
assign kernel_img_mul_439[0] = buffer_data_2[3511:3504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_439[1] = buffer_data_2[3519:3512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_439[2] = buffer_data_2[3527:3520] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_439[3] = buffer_data_1[3511:3504] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_439[4] = buffer_data_1[3519:3512] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_439[5] = buffer_data_1[3527:3520] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_439[6] = buffer_data_0[3511:3504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_439[7] = buffer_data_0[3519:3512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_439[8] = buffer_data_0[3527:3520] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_439 = kernel_img_mul_439[0] + kernel_img_mul_439[1] + kernel_img_mul_439[2] + 
                kernel_img_mul_439[3] + kernel_img_mul_439[4] + kernel_img_mul_439[5] + 
                kernel_img_mul_439[6] + kernel_img_mul_439[7] + kernel_img_mul_439[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3519:3512] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3519:3512] <= kernel_img_sum_439[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3519:3512] <= 'd0;
end

wire  [25:0]  kernel_img_mul_440[0:8];
assign kernel_img_mul_440[0] = buffer_data_2[3519:3512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_440[1] = buffer_data_2[3527:3520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_440[2] = buffer_data_2[3535:3528] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_440[3] = buffer_data_1[3519:3512] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_440[4] = buffer_data_1[3527:3520] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_440[5] = buffer_data_1[3535:3528] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_440[6] = buffer_data_0[3519:3512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_440[7] = buffer_data_0[3527:3520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_440[8] = buffer_data_0[3535:3528] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_440 = kernel_img_mul_440[0] + kernel_img_mul_440[1] + kernel_img_mul_440[2] + 
                kernel_img_mul_440[3] + kernel_img_mul_440[4] + kernel_img_mul_440[5] + 
                kernel_img_mul_440[6] + kernel_img_mul_440[7] + kernel_img_mul_440[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3527:3520] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3527:3520] <= kernel_img_sum_440[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3527:3520] <= 'd0;
end

wire  [25:0]  kernel_img_mul_441[0:8];
assign kernel_img_mul_441[0] = buffer_data_2[3527:3520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_441[1] = buffer_data_2[3535:3528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_441[2] = buffer_data_2[3543:3536] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_441[3] = buffer_data_1[3527:3520] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_441[4] = buffer_data_1[3535:3528] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_441[5] = buffer_data_1[3543:3536] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_441[6] = buffer_data_0[3527:3520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_441[7] = buffer_data_0[3535:3528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_441[8] = buffer_data_0[3543:3536] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_441 = kernel_img_mul_441[0] + kernel_img_mul_441[1] + kernel_img_mul_441[2] + 
                kernel_img_mul_441[3] + kernel_img_mul_441[4] + kernel_img_mul_441[5] + 
                kernel_img_mul_441[6] + kernel_img_mul_441[7] + kernel_img_mul_441[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3535:3528] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3535:3528] <= kernel_img_sum_441[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3535:3528] <= 'd0;
end

wire  [25:0]  kernel_img_mul_442[0:8];
assign kernel_img_mul_442[0] = buffer_data_2[3535:3528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_442[1] = buffer_data_2[3543:3536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_442[2] = buffer_data_2[3551:3544] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_442[3] = buffer_data_1[3535:3528] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_442[4] = buffer_data_1[3543:3536] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_442[5] = buffer_data_1[3551:3544] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_442[6] = buffer_data_0[3535:3528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_442[7] = buffer_data_0[3543:3536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_442[8] = buffer_data_0[3551:3544] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_442 = kernel_img_mul_442[0] + kernel_img_mul_442[1] + kernel_img_mul_442[2] + 
                kernel_img_mul_442[3] + kernel_img_mul_442[4] + kernel_img_mul_442[5] + 
                kernel_img_mul_442[6] + kernel_img_mul_442[7] + kernel_img_mul_442[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3543:3536] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3543:3536] <= kernel_img_sum_442[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3543:3536] <= 'd0;
end

wire  [25:0]  kernel_img_mul_443[0:8];
assign kernel_img_mul_443[0] = buffer_data_2[3543:3536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_443[1] = buffer_data_2[3551:3544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_443[2] = buffer_data_2[3559:3552] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_443[3] = buffer_data_1[3543:3536] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_443[4] = buffer_data_1[3551:3544] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_443[5] = buffer_data_1[3559:3552] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_443[6] = buffer_data_0[3543:3536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_443[7] = buffer_data_0[3551:3544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_443[8] = buffer_data_0[3559:3552] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_443 = kernel_img_mul_443[0] + kernel_img_mul_443[1] + kernel_img_mul_443[2] + 
                kernel_img_mul_443[3] + kernel_img_mul_443[4] + kernel_img_mul_443[5] + 
                kernel_img_mul_443[6] + kernel_img_mul_443[7] + kernel_img_mul_443[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3551:3544] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3551:3544] <= kernel_img_sum_443[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3551:3544] <= 'd0;
end

wire  [25:0]  kernel_img_mul_444[0:8];
assign kernel_img_mul_444[0] = buffer_data_2[3551:3544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_444[1] = buffer_data_2[3559:3552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_444[2] = buffer_data_2[3567:3560] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_444[3] = buffer_data_1[3551:3544] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_444[4] = buffer_data_1[3559:3552] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_444[5] = buffer_data_1[3567:3560] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_444[6] = buffer_data_0[3551:3544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_444[7] = buffer_data_0[3559:3552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_444[8] = buffer_data_0[3567:3560] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_444 = kernel_img_mul_444[0] + kernel_img_mul_444[1] + kernel_img_mul_444[2] + 
                kernel_img_mul_444[3] + kernel_img_mul_444[4] + kernel_img_mul_444[5] + 
                kernel_img_mul_444[6] + kernel_img_mul_444[7] + kernel_img_mul_444[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3559:3552] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3559:3552] <= kernel_img_sum_444[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3559:3552] <= 'd0;
end

wire  [25:0]  kernel_img_mul_445[0:8];
assign kernel_img_mul_445[0] = buffer_data_2[3559:3552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_445[1] = buffer_data_2[3567:3560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_445[2] = buffer_data_2[3575:3568] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_445[3] = buffer_data_1[3559:3552] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_445[4] = buffer_data_1[3567:3560] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_445[5] = buffer_data_1[3575:3568] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_445[6] = buffer_data_0[3559:3552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_445[7] = buffer_data_0[3567:3560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_445[8] = buffer_data_0[3575:3568] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_445 = kernel_img_mul_445[0] + kernel_img_mul_445[1] + kernel_img_mul_445[2] + 
                kernel_img_mul_445[3] + kernel_img_mul_445[4] + kernel_img_mul_445[5] + 
                kernel_img_mul_445[6] + kernel_img_mul_445[7] + kernel_img_mul_445[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3567:3560] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3567:3560] <= kernel_img_sum_445[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3567:3560] <= 'd0;
end

wire  [25:0]  kernel_img_mul_446[0:8];
assign kernel_img_mul_446[0] = buffer_data_2[3567:3560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_446[1] = buffer_data_2[3575:3568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_446[2] = buffer_data_2[3583:3576] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_446[3] = buffer_data_1[3567:3560] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_446[4] = buffer_data_1[3575:3568] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_446[5] = buffer_data_1[3583:3576] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_446[6] = buffer_data_0[3567:3560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_446[7] = buffer_data_0[3575:3568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_446[8] = buffer_data_0[3583:3576] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_446 = kernel_img_mul_446[0] + kernel_img_mul_446[1] + kernel_img_mul_446[2] + 
                kernel_img_mul_446[3] + kernel_img_mul_446[4] + kernel_img_mul_446[5] + 
                kernel_img_mul_446[6] + kernel_img_mul_446[7] + kernel_img_mul_446[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3575:3568] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3575:3568] <= kernel_img_sum_446[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3575:3568] <= 'd0;
end

wire  [25:0]  kernel_img_mul_447[0:8];
assign kernel_img_mul_447[0] = buffer_data_2[3575:3568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_447[1] = buffer_data_2[3583:3576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_447[2] = buffer_data_2[3591:3584] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_447[3] = buffer_data_1[3575:3568] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_447[4] = buffer_data_1[3583:3576] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_447[5] = buffer_data_1[3591:3584] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_447[6] = buffer_data_0[3575:3568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_447[7] = buffer_data_0[3583:3576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_447[8] = buffer_data_0[3591:3584] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_447 = kernel_img_mul_447[0] + kernel_img_mul_447[1] + kernel_img_mul_447[2] + 
                kernel_img_mul_447[3] + kernel_img_mul_447[4] + kernel_img_mul_447[5] + 
                kernel_img_mul_447[6] + kernel_img_mul_447[7] + kernel_img_mul_447[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3583:3576] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3583:3576] <= kernel_img_sum_447[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3583:3576] <= 'd0;
end

wire  [25:0]  kernel_img_mul_448[0:8];
assign kernel_img_mul_448[0] = buffer_data_2[3583:3576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_448[1] = buffer_data_2[3591:3584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_448[2] = buffer_data_2[3599:3592] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_448[3] = buffer_data_1[3583:3576] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_448[4] = buffer_data_1[3591:3584] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_448[5] = buffer_data_1[3599:3592] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_448[6] = buffer_data_0[3583:3576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_448[7] = buffer_data_0[3591:3584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_448[8] = buffer_data_0[3599:3592] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_448 = kernel_img_mul_448[0] + kernel_img_mul_448[1] + kernel_img_mul_448[2] + 
                kernel_img_mul_448[3] + kernel_img_mul_448[4] + kernel_img_mul_448[5] + 
                kernel_img_mul_448[6] + kernel_img_mul_448[7] + kernel_img_mul_448[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3591:3584] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3591:3584] <= kernel_img_sum_448[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3591:3584] <= 'd0;
end

wire  [25:0]  kernel_img_mul_449[0:8];
assign kernel_img_mul_449[0] = buffer_data_2[3591:3584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_449[1] = buffer_data_2[3599:3592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_449[2] = buffer_data_2[3607:3600] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_449[3] = buffer_data_1[3591:3584] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_449[4] = buffer_data_1[3599:3592] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_449[5] = buffer_data_1[3607:3600] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_449[6] = buffer_data_0[3591:3584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_449[7] = buffer_data_0[3599:3592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_449[8] = buffer_data_0[3607:3600] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_449 = kernel_img_mul_449[0] + kernel_img_mul_449[1] + kernel_img_mul_449[2] + 
                kernel_img_mul_449[3] + kernel_img_mul_449[4] + kernel_img_mul_449[5] + 
                kernel_img_mul_449[6] + kernel_img_mul_449[7] + kernel_img_mul_449[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3599:3592] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3599:3592] <= kernel_img_sum_449[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3599:3592] <= 'd0;
end

wire  [25:0]  kernel_img_mul_450[0:8];
assign kernel_img_mul_450[0] = buffer_data_2[3599:3592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_450[1] = buffer_data_2[3607:3600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_450[2] = buffer_data_2[3615:3608] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_450[3] = buffer_data_1[3599:3592] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_450[4] = buffer_data_1[3607:3600] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_450[5] = buffer_data_1[3615:3608] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_450[6] = buffer_data_0[3599:3592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_450[7] = buffer_data_0[3607:3600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_450[8] = buffer_data_0[3615:3608] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_450 = kernel_img_mul_450[0] + kernel_img_mul_450[1] + kernel_img_mul_450[2] + 
                kernel_img_mul_450[3] + kernel_img_mul_450[4] + kernel_img_mul_450[5] + 
                kernel_img_mul_450[6] + kernel_img_mul_450[7] + kernel_img_mul_450[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3607:3600] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3607:3600] <= kernel_img_sum_450[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3607:3600] <= 'd0;
end

wire  [25:0]  kernel_img_mul_451[0:8];
assign kernel_img_mul_451[0] = buffer_data_2[3607:3600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_451[1] = buffer_data_2[3615:3608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_451[2] = buffer_data_2[3623:3616] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_451[3] = buffer_data_1[3607:3600] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_451[4] = buffer_data_1[3615:3608] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_451[5] = buffer_data_1[3623:3616] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_451[6] = buffer_data_0[3607:3600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_451[7] = buffer_data_0[3615:3608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_451[8] = buffer_data_0[3623:3616] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_451 = kernel_img_mul_451[0] + kernel_img_mul_451[1] + kernel_img_mul_451[2] + 
                kernel_img_mul_451[3] + kernel_img_mul_451[4] + kernel_img_mul_451[5] + 
                kernel_img_mul_451[6] + kernel_img_mul_451[7] + kernel_img_mul_451[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3615:3608] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3615:3608] <= kernel_img_sum_451[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3615:3608] <= 'd0;
end

wire  [25:0]  kernel_img_mul_452[0:8];
assign kernel_img_mul_452[0] = buffer_data_2[3615:3608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_452[1] = buffer_data_2[3623:3616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_452[2] = buffer_data_2[3631:3624] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_452[3] = buffer_data_1[3615:3608] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_452[4] = buffer_data_1[3623:3616] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_452[5] = buffer_data_1[3631:3624] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_452[6] = buffer_data_0[3615:3608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_452[7] = buffer_data_0[3623:3616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_452[8] = buffer_data_0[3631:3624] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_452 = kernel_img_mul_452[0] + kernel_img_mul_452[1] + kernel_img_mul_452[2] + 
                kernel_img_mul_452[3] + kernel_img_mul_452[4] + kernel_img_mul_452[5] + 
                kernel_img_mul_452[6] + kernel_img_mul_452[7] + kernel_img_mul_452[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3623:3616] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3623:3616] <= kernel_img_sum_452[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3623:3616] <= 'd0;
end

wire  [25:0]  kernel_img_mul_453[0:8];
assign kernel_img_mul_453[0] = buffer_data_2[3623:3616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_453[1] = buffer_data_2[3631:3624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_453[2] = buffer_data_2[3639:3632] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_453[3] = buffer_data_1[3623:3616] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_453[4] = buffer_data_1[3631:3624] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_453[5] = buffer_data_1[3639:3632] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_453[6] = buffer_data_0[3623:3616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_453[7] = buffer_data_0[3631:3624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_453[8] = buffer_data_0[3639:3632] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_453 = kernel_img_mul_453[0] + kernel_img_mul_453[1] + kernel_img_mul_453[2] + 
                kernel_img_mul_453[3] + kernel_img_mul_453[4] + kernel_img_mul_453[5] + 
                kernel_img_mul_453[6] + kernel_img_mul_453[7] + kernel_img_mul_453[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3631:3624] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3631:3624] <= kernel_img_sum_453[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3631:3624] <= 'd0;
end

wire  [25:0]  kernel_img_mul_454[0:8];
assign kernel_img_mul_454[0] = buffer_data_2[3631:3624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_454[1] = buffer_data_2[3639:3632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_454[2] = buffer_data_2[3647:3640] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_454[3] = buffer_data_1[3631:3624] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_454[4] = buffer_data_1[3639:3632] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_454[5] = buffer_data_1[3647:3640] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_454[6] = buffer_data_0[3631:3624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_454[7] = buffer_data_0[3639:3632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_454[8] = buffer_data_0[3647:3640] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_454 = kernel_img_mul_454[0] + kernel_img_mul_454[1] + kernel_img_mul_454[2] + 
                kernel_img_mul_454[3] + kernel_img_mul_454[4] + kernel_img_mul_454[5] + 
                kernel_img_mul_454[6] + kernel_img_mul_454[7] + kernel_img_mul_454[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3639:3632] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3639:3632] <= kernel_img_sum_454[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3639:3632] <= 'd0;
end

wire  [25:0]  kernel_img_mul_455[0:8];
assign kernel_img_mul_455[0] = buffer_data_2[3639:3632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_455[1] = buffer_data_2[3647:3640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_455[2] = buffer_data_2[3655:3648] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_455[3] = buffer_data_1[3639:3632] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_455[4] = buffer_data_1[3647:3640] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_455[5] = buffer_data_1[3655:3648] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_455[6] = buffer_data_0[3639:3632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_455[7] = buffer_data_0[3647:3640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_455[8] = buffer_data_0[3655:3648] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_455 = kernel_img_mul_455[0] + kernel_img_mul_455[1] + kernel_img_mul_455[2] + 
                kernel_img_mul_455[3] + kernel_img_mul_455[4] + kernel_img_mul_455[5] + 
                kernel_img_mul_455[6] + kernel_img_mul_455[7] + kernel_img_mul_455[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3647:3640] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3647:3640] <= kernel_img_sum_455[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3647:3640] <= 'd0;
end

wire  [25:0]  kernel_img_mul_456[0:8];
assign kernel_img_mul_456[0] = buffer_data_2[3647:3640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_456[1] = buffer_data_2[3655:3648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_456[2] = buffer_data_2[3663:3656] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_456[3] = buffer_data_1[3647:3640] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_456[4] = buffer_data_1[3655:3648] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_456[5] = buffer_data_1[3663:3656] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_456[6] = buffer_data_0[3647:3640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_456[7] = buffer_data_0[3655:3648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_456[8] = buffer_data_0[3663:3656] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_456 = kernel_img_mul_456[0] + kernel_img_mul_456[1] + kernel_img_mul_456[2] + 
                kernel_img_mul_456[3] + kernel_img_mul_456[4] + kernel_img_mul_456[5] + 
                kernel_img_mul_456[6] + kernel_img_mul_456[7] + kernel_img_mul_456[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3655:3648] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3655:3648] <= kernel_img_sum_456[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3655:3648] <= 'd0;
end

wire  [25:0]  kernel_img_mul_457[0:8];
assign kernel_img_mul_457[0] = buffer_data_2[3655:3648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_457[1] = buffer_data_2[3663:3656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_457[2] = buffer_data_2[3671:3664] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_457[3] = buffer_data_1[3655:3648] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_457[4] = buffer_data_1[3663:3656] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_457[5] = buffer_data_1[3671:3664] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_457[6] = buffer_data_0[3655:3648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_457[7] = buffer_data_0[3663:3656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_457[8] = buffer_data_0[3671:3664] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_457 = kernel_img_mul_457[0] + kernel_img_mul_457[1] + kernel_img_mul_457[2] + 
                kernel_img_mul_457[3] + kernel_img_mul_457[4] + kernel_img_mul_457[5] + 
                kernel_img_mul_457[6] + kernel_img_mul_457[7] + kernel_img_mul_457[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3663:3656] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3663:3656] <= kernel_img_sum_457[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3663:3656] <= 'd0;
end

wire  [25:0]  kernel_img_mul_458[0:8];
assign kernel_img_mul_458[0] = buffer_data_2[3663:3656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_458[1] = buffer_data_2[3671:3664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_458[2] = buffer_data_2[3679:3672] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_458[3] = buffer_data_1[3663:3656] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_458[4] = buffer_data_1[3671:3664] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_458[5] = buffer_data_1[3679:3672] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_458[6] = buffer_data_0[3663:3656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_458[7] = buffer_data_0[3671:3664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_458[8] = buffer_data_0[3679:3672] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_458 = kernel_img_mul_458[0] + kernel_img_mul_458[1] + kernel_img_mul_458[2] + 
                kernel_img_mul_458[3] + kernel_img_mul_458[4] + kernel_img_mul_458[5] + 
                kernel_img_mul_458[6] + kernel_img_mul_458[7] + kernel_img_mul_458[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3671:3664] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3671:3664] <= kernel_img_sum_458[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3671:3664] <= 'd0;
end

wire  [25:0]  kernel_img_mul_459[0:8];
assign kernel_img_mul_459[0] = buffer_data_2[3671:3664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_459[1] = buffer_data_2[3679:3672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_459[2] = buffer_data_2[3687:3680] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_459[3] = buffer_data_1[3671:3664] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_459[4] = buffer_data_1[3679:3672] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_459[5] = buffer_data_1[3687:3680] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_459[6] = buffer_data_0[3671:3664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_459[7] = buffer_data_0[3679:3672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_459[8] = buffer_data_0[3687:3680] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_459 = kernel_img_mul_459[0] + kernel_img_mul_459[1] + kernel_img_mul_459[2] + 
                kernel_img_mul_459[3] + kernel_img_mul_459[4] + kernel_img_mul_459[5] + 
                kernel_img_mul_459[6] + kernel_img_mul_459[7] + kernel_img_mul_459[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3679:3672] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3679:3672] <= kernel_img_sum_459[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3679:3672] <= 'd0;
end

wire  [25:0]  kernel_img_mul_460[0:8];
assign kernel_img_mul_460[0] = buffer_data_2[3679:3672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_460[1] = buffer_data_2[3687:3680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_460[2] = buffer_data_2[3695:3688] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_460[3] = buffer_data_1[3679:3672] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_460[4] = buffer_data_1[3687:3680] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_460[5] = buffer_data_1[3695:3688] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_460[6] = buffer_data_0[3679:3672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_460[7] = buffer_data_0[3687:3680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_460[8] = buffer_data_0[3695:3688] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_460 = kernel_img_mul_460[0] + kernel_img_mul_460[1] + kernel_img_mul_460[2] + 
                kernel_img_mul_460[3] + kernel_img_mul_460[4] + kernel_img_mul_460[5] + 
                kernel_img_mul_460[6] + kernel_img_mul_460[7] + kernel_img_mul_460[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3687:3680] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3687:3680] <= kernel_img_sum_460[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3687:3680] <= 'd0;
end

wire  [25:0]  kernel_img_mul_461[0:8];
assign kernel_img_mul_461[0] = buffer_data_2[3687:3680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_461[1] = buffer_data_2[3695:3688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_461[2] = buffer_data_2[3703:3696] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_461[3] = buffer_data_1[3687:3680] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_461[4] = buffer_data_1[3695:3688] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_461[5] = buffer_data_1[3703:3696] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_461[6] = buffer_data_0[3687:3680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_461[7] = buffer_data_0[3695:3688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_461[8] = buffer_data_0[3703:3696] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_461 = kernel_img_mul_461[0] + kernel_img_mul_461[1] + kernel_img_mul_461[2] + 
                kernel_img_mul_461[3] + kernel_img_mul_461[4] + kernel_img_mul_461[5] + 
                kernel_img_mul_461[6] + kernel_img_mul_461[7] + kernel_img_mul_461[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3695:3688] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3695:3688] <= kernel_img_sum_461[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3695:3688] <= 'd0;
end

wire  [25:0]  kernel_img_mul_462[0:8];
assign kernel_img_mul_462[0] = buffer_data_2[3695:3688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_462[1] = buffer_data_2[3703:3696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_462[2] = buffer_data_2[3711:3704] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_462[3] = buffer_data_1[3695:3688] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_462[4] = buffer_data_1[3703:3696] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_462[5] = buffer_data_1[3711:3704] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_462[6] = buffer_data_0[3695:3688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_462[7] = buffer_data_0[3703:3696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_462[8] = buffer_data_0[3711:3704] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_462 = kernel_img_mul_462[0] + kernel_img_mul_462[1] + kernel_img_mul_462[2] + 
                kernel_img_mul_462[3] + kernel_img_mul_462[4] + kernel_img_mul_462[5] + 
                kernel_img_mul_462[6] + kernel_img_mul_462[7] + kernel_img_mul_462[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3703:3696] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3703:3696] <= kernel_img_sum_462[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3703:3696] <= 'd0;
end

wire  [25:0]  kernel_img_mul_463[0:8];
assign kernel_img_mul_463[0] = buffer_data_2[3703:3696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_463[1] = buffer_data_2[3711:3704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_463[2] = buffer_data_2[3719:3712] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_463[3] = buffer_data_1[3703:3696] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_463[4] = buffer_data_1[3711:3704] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_463[5] = buffer_data_1[3719:3712] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_463[6] = buffer_data_0[3703:3696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_463[7] = buffer_data_0[3711:3704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_463[8] = buffer_data_0[3719:3712] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_463 = kernel_img_mul_463[0] + kernel_img_mul_463[1] + kernel_img_mul_463[2] + 
                kernel_img_mul_463[3] + kernel_img_mul_463[4] + kernel_img_mul_463[5] + 
                kernel_img_mul_463[6] + kernel_img_mul_463[7] + kernel_img_mul_463[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3711:3704] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3711:3704] <= kernel_img_sum_463[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3711:3704] <= 'd0;
end

wire  [25:0]  kernel_img_mul_464[0:8];
assign kernel_img_mul_464[0] = buffer_data_2[3711:3704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_464[1] = buffer_data_2[3719:3712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_464[2] = buffer_data_2[3727:3720] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_464[3] = buffer_data_1[3711:3704] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_464[4] = buffer_data_1[3719:3712] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_464[5] = buffer_data_1[3727:3720] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_464[6] = buffer_data_0[3711:3704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_464[7] = buffer_data_0[3719:3712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_464[8] = buffer_data_0[3727:3720] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_464 = kernel_img_mul_464[0] + kernel_img_mul_464[1] + kernel_img_mul_464[2] + 
                kernel_img_mul_464[3] + kernel_img_mul_464[4] + kernel_img_mul_464[5] + 
                kernel_img_mul_464[6] + kernel_img_mul_464[7] + kernel_img_mul_464[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3719:3712] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3719:3712] <= kernel_img_sum_464[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3719:3712] <= 'd0;
end

wire  [25:0]  kernel_img_mul_465[0:8];
assign kernel_img_mul_465[0] = buffer_data_2[3719:3712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_465[1] = buffer_data_2[3727:3720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_465[2] = buffer_data_2[3735:3728] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_465[3] = buffer_data_1[3719:3712] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_465[4] = buffer_data_1[3727:3720] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_465[5] = buffer_data_1[3735:3728] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_465[6] = buffer_data_0[3719:3712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_465[7] = buffer_data_0[3727:3720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_465[8] = buffer_data_0[3735:3728] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_465 = kernel_img_mul_465[0] + kernel_img_mul_465[1] + kernel_img_mul_465[2] + 
                kernel_img_mul_465[3] + kernel_img_mul_465[4] + kernel_img_mul_465[5] + 
                kernel_img_mul_465[6] + kernel_img_mul_465[7] + kernel_img_mul_465[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3727:3720] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3727:3720] <= kernel_img_sum_465[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3727:3720] <= 'd0;
end

wire  [25:0]  kernel_img_mul_466[0:8];
assign kernel_img_mul_466[0] = buffer_data_2[3727:3720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_466[1] = buffer_data_2[3735:3728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_466[2] = buffer_data_2[3743:3736] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_466[3] = buffer_data_1[3727:3720] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_466[4] = buffer_data_1[3735:3728] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_466[5] = buffer_data_1[3743:3736] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_466[6] = buffer_data_0[3727:3720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_466[7] = buffer_data_0[3735:3728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_466[8] = buffer_data_0[3743:3736] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_466 = kernel_img_mul_466[0] + kernel_img_mul_466[1] + kernel_img_mul_466[2] + 
                kernel_img_mul_466[3] + kernel_img_mul_466[4] + kernel_img_mul_466[5] + 
                kernel_img_mul_466[6] + kernel_img_mul_466[7] + kernel_img_mul_466[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3735:3728] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3735:3728] <= kernel_img_sum_466[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3735:3728] <= 'd0;
end

wire  [25:0]  kernel_img_mul_467[0:8];
assign kernel_img_mul_467[0] = buffer_data_2[3735:3728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_467[1] = buffer_data_2[3743:3736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_467[2] = buffer_data_2[3751:3744] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_467[3] = buffer_data_1[3735:3728] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_467[4] = buffer_data_1[3743:3736] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_467[5] = buffer_data_1[3751:3744] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_467[6] = buffer_data_0[3735:3728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_467[7] = buffer_data_0[3743:3736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_467[8] = buffer_data_0[3751:3744] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_467 = kernel_img_mul_467[0] + kernel_img_mul_467[1] + kernel_img_mul_467[2] + 
                kernel_img_mul_467[3] + kernel_img_mul_467[4] + kernel_img_mul_467[5] + 
                kernel_img_mul_467[6] + kernel_img_mul_467[7] + kernel_img_mul_467[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3743:3736] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3743:3736] <= kernel_img_sum_467[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3743:3736] <= 'd0;
end

wire  [25:0]  kernel_img_mul_468[0:8];
assign kernel_img_mul_468[0] = buffer_data_2[3743:3736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_468[1] = buffer_data_2[3751:3744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_468[2] = buffer_data_2[3759:3752] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_468[3] = buffer_data_1[3743:3736] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_468[4] = buffer_data_1[3751:3744] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_468[5] = buffer_data_1[3759:3752] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_468[6] = buffer_data_0[3743:3736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_468[7] = buffer_data_0[3751:3744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_468[8] = buffer_data_0[3759:3752] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_468 = kernel_img_mul_468[0] + kernel_img_mul_468[1] + kernel_img_mul_468[2] + 
                kernel_img_mul_468[3] + kernel_img_mul_468[4] + kernel_img_mul_468[5] + 
                kernel_img_mul_468[6] + kernel_img_mul_468[7] + kernel_img_mul_468[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3751:3744] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3751:3744] <= kernel_img_sum_468[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3751:3744] <= 'd0;
end

wire  [25:0]  kernel_img_mul_469[0:8];
assign kernel_img_mul_469[0] = buffer_data_2[3751:3744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_469[1] = buffer_data_2[3759:3752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_469[2] = buffer_data_2[3767:3760] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_469[3] = buffer_data_1[3751:3744] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_469[4] = buffer_data_1[3759:3752] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_469[5] = buffer_data_1[3767:3760] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_469[6] = buffer_data_0[3751:3744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_469[7] = buffer_data_0[3759:3752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_469[8] = buffer_data_0[3767:3760] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_469 = kernel_img_mul_469[0] + kernel_img_mul_469[1] + kernel_img_mul_469[2] + 
                kernel_img_mul_469[3] + kernel_img_mul_469[4] + kernel_img_mul_469[5] + 
                kernel_img_mul_469[6] + kernel_img_mul_469[7] + kernel_img_mul_469[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3759:3752] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3759:3752] <= kernel_img_sum_469[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3759:3752] <= 'd0;
end

wire  [25:0]  kernel_img_mul_470[0:8];
assign kernel_img_mul_470[0] = buffer_data_2[3759:3752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_470[1] = buffer_data_2[3767:3760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_470[2] = buffer_data_2[3775:3768] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_470[3] = buffer_data_1[3759:3752] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_470[4] = buffer_data_1[3767:3760] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_470[5] = buffer_data_1[3775:3768] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_470[6] = buffer_data_0[3759:3752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_470[7] = buffer_data_0[3767:3760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_470[8] = buffer_data_0[3775:3768] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_470 = kernel_img_mul_470[0] + kernel_img_mul_470[1] + kernel_img_mul_470[2] + 
                kernel_img_mul_470[3] + kernel_img_mul_470[4] + kernel_img_mul_470[5] + 
                kernel_img_mul_470[6] + kernel_img_mul_470[7] + kernel_img_mul_470[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3767:3760] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3767:3760] <= kernel_img_sum_470[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3767:3760] <= 'd0;
end

wire  [25:0]  kernel_img_mul_471[0:8];
assign kernel_img_mul_471[0] = buffer_data_2[3767:3760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_471[1] = buffer_data_2[3775:3768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_471[2] = buffer_data_2[3783:3776] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_471[3] = buffer_data_1[3767:3760] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_471[4] = buffer_data_1[3775:3768] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_471[5] = buffer_data_1[3783:3776] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_471[6] = buffer_data_0[3767:3760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_471[7] = buffer_data_0[3775:3768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_471[8] = buffer_data_0[3783:3776] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_471 = kernel_img_mul_471[0] + kernel_img_mul_471[1] + kernel_img_mul_471[2] + 
                kernel_img_mul_471[3] + kernel_img_mul_471[4] + kernel_img_mul_471[5] + 
                kernel_img_mul_471[6] + kernel_img_mul_471[7] + kernel_img_mul_471[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3775:3768] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3775:3768] <= kernel_img_sum_471[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3775:3768] <= 'd0;
end

wire  [25:0]  kernel_img_mul_472[0:8];
assign kernel_img_mul_472[0] = buffer_data_2[3775:3768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_472[1] = buffer_data_2[3783:3776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_472[2] = buffer_data_2[3791:3784] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_472[3] = buffer_data_1[3775:3768] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_472[4] = buffer_data_1[3783:3776] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_472[5] = buffer_data_1[3791:3784] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_472[6] = buffer_data_0[3775:3768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_472[7] = buffer_data_0[3783:3776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_472[8] = buffer_data_0[3791:3784] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_472 = kernel_img_mul_472[0] + kernel_img_mul_472[1] + kernel_img_mul_472[2] + 
                kernel_img_mul_472[3] + kernel_img_mul_472[4] + kernel_img_mul_472[5] + 
                kernel_img_mul_472[6] + kernel_img_mul_472[7] + kernel_img_mul_472[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3783:3776] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3783:3776] <= kernel_img_sum_472[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3783:3776] <= 'd0;
end

wire  [25:0]  kernel_img_mul_473[0:8];
assign kernel_img_mul_473[0] = buffer_data_2[3783:3776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_473[1] = buffer_data_2[3791:3784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_473[2] = buffer_data_2[3799:3792] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_473[3] = buffer_data_1[3783:3776] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_473[4] = buffer_data_1[3791:3784] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_473[5] = buffer_data_1[3799:3792] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_473[6] = buffer_data_0[3783:3776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_473[7] = buffer_data_0[3791:3784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_473[8] = buffer_data_0[3799:3792] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_473 = kernel_img_mul_473[0] + kernel_img_mul_473[1] + kernel_img_mul_473[2] + 
                kernel_img_mul_473[3] + kernel_img_mul_473[4] + kernel_img_mul_473[5] + 
                kernel_img_mul_473[6] + kernel_img_mul_473[7] + kernel_img_mul_473[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3791:3784] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3791:3784] <= kernel_img_sum_473[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3791:3784] <= 'd0;
end

wire  [25:0]  kernel_img_mul_474[0:8];
assign kernel_img_mul_474[0] = buffer_data_2[3791:3784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_474[1] = buffer_data_2[3799:3792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_474[2] = buffer_data_2[3807:3800] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_474[3] = buffer_data_1[3791:3784] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_474[4] = buffer_data_1[3799:3792] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_474[5] = buffer_data_1[3807:3800] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_474[6] = buffer_data_0[3791:3784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_474[7] = buffer_data_0[3799:3792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_474[8] = buffer_data_0[3807:3800] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_474 = kernel_img_mul_474[0] + kernel_img_mul_474[1] + kernel_img_mul_474[2] + 
                kernel_img_mul_474[3] + kernel_img_mul_474[4] + kernel_img_mul_474[5] + 
                kernel_img_mul_474[6] + kernel_img_mul_474[7] + kernel_img_mul_474[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3799:3792] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3799:3792] <= kernel_img_sum_474[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3799:3792] <= 'd0;
end

wire  [25:0]  kernel_img_mul_475[0:8];
assign kernel_img_mul_475[0] = buffer_data_2[3799:3792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_475[1] = buffer_data_2[3807:3800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_475[2] = buffer_data_2[3815:3808] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_475[3] = buffer_data_1[3799:3792] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_475[4] = buffer_data_1[3807:3800] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_475[5] = buffer_data_1[3815:3808] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_475[6] = buffer_data_0[3799:3792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_475[7] = buffer_data_0[3807:3800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_475[8] = buffer_data_0[3815:3808] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_475 = kernel_img_mul_475[0] + kernel_img_mul_475[1] + kernel_img_mul_475[2] + 
                kernel_img_mul_475[3] + kernel_img_mul_475[4] + kernel_img_mul_475[5] + 
                kernel_img_mul_475[6] + kernel_img_mul_475[7] + kernel_img_mul_475[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3807:3800] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3807:3800] <= kernel_img_sum_475[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3807:3800] <= 'd0;
end

wire  [25:0]  kernel_img_mul_476[0:8];
assign kernel_img_mul_476[0] = buffer_data_2[3807:3800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_476[1] = buffer_data_2[3815:3808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_476[2] = buffer_data_2[3823:3816] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_476[3] = buffer_data_1[3807:3800] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_476[4] = buffer_data_1[3815:3808] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_476[5] = buffer_data_1[3823:3816] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_476[6] = buffer_data_0[3807:3800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_476[7] = buffer_data_0[3815:3808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_476[8] = buffer_data_0[3823:3816] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_476 = kernel_img_mul_476[0] + kernel_img_mul_476[1] + kernel_img_mul_476[2] + 
                kernel_img_mul_476[3] + kernel_img_mul_476[4] + kernel_img_mul_476[5] + 
                kernel_img_mul_476[6] + kernel_img_mul_476[7] + kernel_img_mul_476[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3815:3808] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3815:3808] <= kernel_img_sum_476[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3815:3808] <= 'd0;
end

wire  [25:0]  kernel_img_mul_477[0:8];
assign kernel_img_mul_477[0] = buffer_data_2[3815:3808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_477[1] = buffer_data_2[3823:3816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_477[2] = buffer_data_2[3831:3824] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_477[3] = buffer_data_1[3815:3808] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_477[4] = buffer_data_1[3823:3816] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_477[5] = buffer_data_1[3831:3824] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_477[6] = buffer_data_0[3815:3808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_477[7] = buffer_data_0[3823:3816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_477[8] = buffer_data_0[3831:3824] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_477 = kernel_img_mul_477[0] + kernel_img_mul_477[1] + kernel_img_mul_477[2] + 
                kernel_img_mul_477[3] + kernel_img_mul_477[4] + kernel_img_mul_477[5] + 
                kernel_img_mul_477[6] + kernel_img_mul_477[7] + kernel_img_mul_477[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3823:3816] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3823:3816] <= kernel_img_sum_477[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3823:3816] <= 'd0;
end

wire  [25:0]  kernel_img_mul_478[0:8];
assign kernel_img_mul_478[0] = buffer_data_2[3823:3816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_478[1] = buffer_data_2[3831:3824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_478[2] = buffer_data_2[3839:3832] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_478[3] = buffer_data_1[3823:3816] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_478[4] = buffer_data_1[3831:3824] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_478[5] = buffer_data_1[3839:3832] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_478[6] = buffer_data_0[3823:3816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_478[7] = buffer_data_0[3831:3824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_478[8] = buffer_data_0[3839:3832] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_478 = kernel_img_mul_478[0] + kernel_img_mul_478[1] + kernel_img_mul_478[2] + 
                kernel_img_mul_478[3] + kernel_img_mul_478[4] + kernel_img_mul_478[5] + 
                kernel_img_mul_478[6] + kernel_img_mul_478[7] + kernel_img_mul_478[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3831:3824] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3831:3824] <= kernel_img_sum_478[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3831:3824] <= 'd0;
end

wire  [25:0]  kernel_img_mul_479[0:8];
assign kernel_img_mul_479[0] = buffer_data_2[3831:3824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_479[1] = buffer_data_2[3839:3832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_479[2] = buffer_data_2[3847:3840] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_479[3] = buffer_data_1[3831:3824] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_479[4] = buffer_data_1[3839:3832] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_479[5] = buffer_data_1[3847:3840] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_479[6] = buffer_data_0[3831:3824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_479[7] = buffer_data_0[3839:3832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_479[8] = buffer_data_0[3847:3840] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_479 = kernel_img_mul_479[0] + kernel_img_mul_479[1] + kernel_img_mul_479[2] + 
                kernel_img_mul_479[3] + kernel_img_mul_479[4] + kernel_img_mul_479[5] + 
                kernel_img_mul_479[6] + kernel_img_mul_479[7] + kernel_img_mul_479[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3839:3832] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3839:3832] <= kernel_img_sum_479[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3839:3832] <= 'd0;
end

wire  [25:0]  kernel_img_mul_480[0:8];
assign kernel_img_mul_480[0] = buffer_data_2[3839:3832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_480[1] = buffer_data_2[3847:3840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_480[2] = buffer_data_2[3855:3848] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_480[3] = buffer_data_1[3839:3832] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_480[4] = buffer_data_1[3847:3840] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_480[5] = buffer_data_1[3855:3848] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_480[6] = buffer_data_0[3839:3832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_480[7] = buffer_data_0[3847:3840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_480[8] = buffer_data_0[3855:3848] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_480 = kernel_img_mul_480[0] + kernel_img_mul_480[1] + kernel_img_mul_480[2] + 
                kernel_img_mul_480[3] + kernel_img_mul_480[4] + kernel_img_mul_480[5] + 
                kernel_img_mul_480[6] + kernel_img_mul_480[7] + kernel_img_mul_480[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3847:3840] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3847:3840] <= kernel_img_sum_480[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3847:3840] <= 'd0;
end

wire  [25:0]  kernel_img_mul_481[0:8];
assign kernel_img_mul_481[0] = buffer_data_2[3847:3840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_481[1] = buffer_data_2[3855:3848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_481[2] = buffer_data_2[3863:3856] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_481[3] = buffer_data_1[3847:3840] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_481[4] = buffer_data_1[3855:3848] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_481[5] = buffer_data_1[3863:3856] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_481[6] = buffer_data_0[3847:3840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_481[7] = buffer_data_0[3855:3848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_481[8] = buffer_data_0[3863:3856] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_481 = kernel_img_mul_481[0] + kernel_img_mul_481[1] + kernel_img_mul_481[2] + 
                kernel_img_mul_481[3] + kernel_img_mul_481[4] + kernel_img_mul_481[5] + 
                kernel_img_mul_481[6] + kernel_img_mul_481[7] + kernel_img_mul_481[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3855:3848] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3855:3848] <= kernel_img_sum_481[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3855:3848] <= 'd0;
end

wire  [25:0]  kernel_img_mul_482[0:8];
assign kernel_img_mul_482[0] = buffer_data_2[3855:3848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_482[1] = buffer_data_2[3863:3856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_482[2] = buffer_data_2[3871:3864] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_482[3] = buffer_data_1[3855:3848] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_482[4] = buffer_data_1[3863:3856] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_482[5] = buffer_data_1[3871:3864] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_482[6] = buffer_data_0[3855:3848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_482[7] = buffer_data_0[3863:3856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_482[8] = buffer_data_0[3871:3864] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_482 = kernel_img_mul_482[0] + kernel_img_mul_482[1] + kernel_img_mul_482[2] + 
                kernel_img_mul_482[3] + kernel_img_mul_482[4] + kernel_img_mul_482[5] + 
                kernel_img_mul_482[6] + kernel_img_mul_482[7] + kernel_img_mul_482[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3863:3856] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3863:3856] <= kernel_img_sum_482[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3863:3856] <= 'd0;
end

wire  [25:0]  kernel_img_mul_483[0:8];
assign kernel_img_mul_483[0] = buffer_data_2[3863:3856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_483[1] = buffer_data_2[3871:3864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_483[2] = buffer_data_2[3879:3872] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_483[3] = buffer_data_1[3863:3856] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_483[4] = buffer_data_1[3871:3864] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_483[5] = buffer_data_1[3879:3872] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_483[6] = buffer_data_0[3863:3856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_483[7] = buffer_data_0[3871:3864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_483[8] = buffer_data_0[3879:3872] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_483 = kernel_img_mul_483[0] + kernel_img_mul_483[1] + kernel_img_mul_483[2] + 
                kernel_img_mul_483[3] + kernel_img_mul_483[4] + kernel_img_mul_483[5] + 
                kernel_img_mul_483[6] + kernel_img_mul_483[7] + kernel_img_mul_483[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3871:3864] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3871:3864] <= kernel_img_sum_483[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3871:3864] <= 'd0;
end

wire  [25:0]  kernel_img_mul_484[0:8];
assign kernel_img_mul_484[0] = buffer_data_2[3871:3864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_484[1] = buffer_data_2[3879:3872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_484[2] = buffer_data_2[3887:3880] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_484[3] = buffer_data_1[3871:3864] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_484[4] = buffer_data_1[3879:3872] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_484[5] = buffer_data_1[3887:3880] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_484[6] = buffer_data_0[3871:3864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_484[7] = buffer_data_0[3879:3872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_484[8] = buffer_data_0[3887:3880] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_484 = kernel_img_mul_484[0] + kernel_img_mul_484[1] + kernel_img_mul_484[2] + 
                kernel_img_mul_484[3] + kernel_img_mul_484[4] + kernel_img_mul_484[5] + 
                kernel_img_mul_484[6] + kernel_img_mul_484[7] + kernel_img_mul_484[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3879:3872] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3879:3872] <= kernel_img_sum_484[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3879:3872] <= 'd0;
end

wire  [25:0]  kernel_img_mul_485[0:8];
assign kernel_img_mul_485[0] = buffer_data_2[3879:3872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_485[1] = buffer_data_2[3887:3880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_485[2] = buffer_data_2[3895:3888] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_485[3] = buffer_data_1[3879:3872] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_485[4] = buffer_data_1[3887:3880] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_485[5] = buffer_data_1[3895:3888] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_485[6] = buffer_data_0[3879:3872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_485[7] = buffer_data_0[3887:3880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_485[8] = buffer_data_0[3895:3888] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_485 = kernel_img_mul_485[0] + kernel_img_mul_485[1] + kernel_img_mul_485[2] + 
                kernel_img_mul_485[3] + kernel_img_mul_485[4] + kernel_img_mul_485[5] + 
                kernel_img_mul_485[6] + kernel_img_mul_485[7] + kernel_img_mul_485[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3887:3880] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3887:3880] <= kernel_img_sum_485[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3887:3880] <= 'd0;
end

wire  [25:0]  kernel_img_mul_486[0:8];
assign kernel_img_mul_486[0] = buffer_data_2[3887:3880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_486[1] = buffer_data_2[3895:3888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_486[2] = buffer_data_2[3903:3896] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_486[3] = buffer_data_1[3887:3880] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_486[4] = buffer_data_1[3895:3888] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_486[5] = buffer_data_1[3903:3896] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_486[6] = buffer_data_0[3887:3880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_486[7] = buffer_data_0[3895:3888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_486[8] = buffer_data_0[3903:3896] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_486 = kernel_img_mul_486[0] + kernel_img_mul_486[1] + kernel_img_mul_486[2] + 
                kernel_img_mul_486[3] + kernel_img_mul_486[4] + kernel_img_mul_486[5] + 
                kernel_img_mul_486[6] + kernel_img_mul_486[7] + kernel_img_mul_486[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3895:3888] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3895:3888] <= kernel_img_sum_486[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3895:3888] <= 'd0;
end

wire  [25:0]  kernel_img_mul_487[0:8];
assign kernel_img_mul_487[0] = buffer_data_2[3895:3888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_487[1] = buffer_data_2[3903:3896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_487[2] = buffer_data_2[3911:3904] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_487[3] = buffer_data_1[3895:3888] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_487[4] = buffer_data_1[3903:3896] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_487[5] = buffer_data_1[3911:3904] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_487[6] = buffer_data_0[3895:3888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_487[7] = buffer_data_0[3903:3896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_487[8] = buffer_data_0[3911:3904] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_487 = kernel_img_mul_487[0] + kernel_img_mul_487[1] + kernel_img_mul_487[2] + 
                kernel_img_mul_487[3] + kernel_img_mul_487[4] + kernel_img_mul_487[5] + 
                kernel_img_mul_487[6] + kernel_img_mul_487[7] + kernel_img_mul_487[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3903:3896] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3903:3896] <= kernel_img_sum_487[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3903:3896] <= 'd0;
end

wire  [25:0]  kernel_img_mul_488[0:8];
assign kernel_img_mul_488[0] = buffer_data_2[3903:3896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_488[1] = buffer_data_2[3911:3904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_488[2] = buffer_data_2[3919:3912] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_488[3] = buffer_data_1[3903:3896] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_488[4] = buffer_data_1[3911:3904] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_488[5] = buffer_data_1[3919:3912] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_488[6] = buffer_data_0[3903:3896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_488[7] = buffer_data_0[3911:3904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_488[8] = buffer_data_0[3919:3912] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_488 = kernel_img_mul_488[0] + kernel_img_mul_488[1] + kernel_img_mul_488[2] + 
                kernel_img_mul_488[3] + kernel_img_mul_488[4] + kernel_img_mul_488[5] + 
                kernel_img_mul_488[6] + kernel_img_mul_488[7] + kernel_img_mul_488[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3911:3904] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3911:3904] <= kernel_img_sum_488[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3911:3904] <= 'd0;
end

wire  [25:0]  kernel_img_mul_489[0:8];
assign kernel_img_mul_489[0] = buffer_data_2[3911:3904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_489[1] = buffer_data_2[3919:3912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_489[2] = buffer_data_2[3927:3920] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_489[3] = buffer_data_1[3911:3904] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_489[4] = buffer_data_1[3919:3912] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_489[5] = buffer_data_1[3927:3920] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_489[6] = buffer_data_0[3911:3904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_489[7] = buffer_data_0[3919:3912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_489[8] = buffer_data_0[3927:3920] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_489 = kernel_img_mul_489[0] + kernel_img_mul_489[1] + kernel_img_mul_489[2] + 
                kernel_img_mul_489[3] + kernel_img_mul_489[4] + kernel_img_mul_489[5] + 
                kernel_img_mul_489[6] + kernel_img_mul_489[7] + kernel_img_mul_489[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3919:3912] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3919:3912] <= kernel_img_sum_489[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3919:3912] <= 'd0;
end

wire  [25:0]  kernel_img_mul_490[0:8];
assign kernel_img_mul_490[0] = buffer_data_2[3919:3912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_490[1] = buffer_data_2[3927:3920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_490[2] = buffer_data_2[3935:3928] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_490[3] = buffer_data_1[3919:3912] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_490[4] = buffer_data_1[3927:3920] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_490[5] = buffer_data_1[3935:3928] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_490[6] = buffer_data_0[3919:3912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_490[7] = buffer_data_0[3927:3920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_490[8] = buffer_data_0[3935:3928] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_490 = kernel_img_mul_490[0] + kernel_img_mul_490[1] + kernel_img_mul_490[2] + 
                kernel_img_mul_490[3] + kernel_img_mul_490[4] + kernel_img_mul_490[5] + 
                kernel_img_mul_490[6] + kernel_img_mul_490[7] + kernel_img_mul_490[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3927:3920] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3927:3920] <= kernel_img_sum_490[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3927:3920] <= 'd0;
end

wire  [25:0]  kernel_img_mul_491[0:8];
assign kernel_img_mul_491[0] = buffer_data_2[3927:3920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_491[1] = buffer_data_2[3935:3928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_491[2] = buffer_data_2[3943:3936] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_491[3] = buffer_data_1[3927:3920] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_491[4] = buffer_data_1[3935:3928] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_491[5] = buffer_data_1[3943:3936] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_491[6] = buffer_data_0[3927:3920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_491[7] = buffer_data_0[3935:3928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_491[8] = buffer_data_0[3943:3936] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_491 = kernel_img_mul_491[0] + kernel_img_mul_491[1] + kernel_img_mul_491[2] + 
                kernel_img_mul_491[3] + kernel_img_mul_491[4] + kernel_img_mul_491[5] + 
                kernel_img_mul_491[6] + kernel_img_mul_491[7] + kernel_img_mul_491[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3935:3928] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3935:3928] <= kernel_img_sum_491[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3935:3928] <= 'd0;
end

wire  [25:0]  kernel_img_mul_492[0:8];
assign kernel_img_mul_492[0] = buffer_data_2[3935:3928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_492[1] = buffer_data_2[3943:3936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_492[2] = buffer_data_2[3951:3944] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_492[3] = buffer_data_1[3935:3928] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_492[4] = buffer_data_1[3943:3936] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_492[5] = buffer_data_1[3951:3944] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_492[6] = buffer_data_0[3935:3928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_492[7] = buffer_data_0[3943:3936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_492[8] = buffer_data_0[3951:3944] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_492 = kernel_img_mul_492[0] + kernel_img_mul_492[1] + kernel_img_mul_492[2] + 
                kernel_img_mul_492[3] + kernel_img_mul_492[4] + kernel_img_mul_492[5] + 
                kernel_img_mul_492[6] + kernel_img_mul_492[7] + kernel_img_mul_492[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3943:3936] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3943:3936] <= kernel_img_sum_492[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3943:3936] <= 'd0;
end

wire  [25:0]  kernel_img_mul_493[0:8];
assign kernel_img_mul_493[0] = buffer_data_2[3943:3936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_493[1] = buffer_data_2[3951:3944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_493[2] = buffer_data_2[3959:3952] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_493[3] = buffer_data_1[3943:3936] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_493[4] = buffer_data_1[3951:3944] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_493[5] = buffer_data_1[3959:3952] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_493[6] = buffer_data_0[3943:3936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_493[7] = buffer_data_0[3951:3944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_493[8] = buffer_data_0[3959:3952] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_493 = kernel_img_mul_493[0] + kernel_img_mul_493[1] + kernel_img_mul_493[2] + 
                kernel_img_mul_493[3] + kernel_img_mul_493[4] + kernel_img_mul_493[5] + 
                kernel_img_mul_493[6] + kernel_img_mul_493[7] + kernel_img_mul_493[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3951:3944] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3951:3944] <= kernel_img_sum_493[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3951:3944] <= 'd0;
end

wire  [25:0]  kernel_img_mul_494[0:8];
assign kernel_img_mul_494[0] = buffer_data_2[3951:3944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_494[1] = buffer_data_2[3959:3952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_494[2] = buffer_data_2[3967:3960] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_494[3] = buffer_data_1[3951:3944] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_494[4] = buffer_data_1[3959:3952] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_494[5] = buffer_data_1[3967:3960] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_494[6] = buffer_data_0[3951:3944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_494[7] = buffer_data_0[3959:3952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_494[8] = buffer_data_0[3967:3960] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_494 = kernel_img_mul_494[0] + kernel_img_mul_494[1] + kernel_img_mul_494[2] + 
                kernel_img_mul_494[3] + kernel_img_mul_494[4] + kernel_img_mul_494[5] + 
                kernel_img_mul_494[6] + kernel_img_mul_494[7] + kernel_img_mul_494[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3959:3952] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3959:3952] <= kernel_img_sum_494[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3959:3952] <= 'd0;
end

wire  [25:0]  kernel_img_mul_495[0:8];
assign kernel_img_mul_495[0] = buffer_data_2[3959:3952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_495[1] = buffer_data_2[3967:3960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_495[2] = buffer_data_2[3975:3968] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_495[3] = buffer_data_1[3959:3952] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_495[4] = buffer_data_1[3967:3960] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_495[5] = buffer_data_1[3975:3968] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_495[6] = buffer_data_0[3959:3952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_495[7] = buffer_data_0[3967:3960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_495[8] = buffer_data_0[3975:3968] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_495 = kernel_img_mul_495[0] + kernel_img_mul_495[1] + kernel_img_mul_495[2] + 
                kernel_img_mul_495[3] + kernel_img_mul_495[4] + kernel_img_mul_495[5] + 
                kernel_img_mul_495[6] + kernel_img_mul_495[7] + kernel_img_mul_495[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3967:3960] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3967:3960] <= kernel_img_sum_495[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3967:3960] <= 'd0;
end

wire  [25:0]  kernel_img_mul_496[0:8];
assign kernel_img_mul_496[0] = buffer_data_2[3967:3960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_496[1] = buffer_data_2[3975:3968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_496[2] = buffer_data_2[3983:3976] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_496[3] = buffer_data_1[3967:3960] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_496[4] = buffer_data_1[3975:3968] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_496[5] = buffer_data_1[3983:3976] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_496[6] = buffer_data_0[3967:3960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_496[7] = buffer_data_0[3975:3968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_496[8] = buffer_data_0[3983:3976] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_496 = kernel_img_mul_496[0] + kernel_img_mul_496[1] + kernel_img_mul_496[2] + 
                kernel_img_mul_496[3] + kernel_img_mul_496[4] + kernel_img_mul_496[5] + 
                kernel_img_mul_496[6] + kernel_img_mul_496[7] + kernel_img_mul_496[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3975:3968] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3975:3968] <= kernel_img_sum_496[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3975:3968] <= 'd0;
end

wire  [25:0]  kernel_img_mul_497[0:8];
assign kernel_img_mul_497[0] = buffer_data_2[3975:3968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_497[1] = buffer_data_2[3983:3976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_497[2] = buffer_data_2[3991:3984] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_497[3] = buffer_data_1[3975:3968] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_497[4] = buffer_data_1[3983:3976] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_497[5] = buffer_data_1[3991:3984] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_497[6] = buffer_data_0[3975:3968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_497[7] = buffer_data_0[3983:3976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_497[8] = buffer_data_0[3991:3984] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_497 = kernel_img_mul_497[0] + kernel_img_mul_497[1] + kernel_img_mul_497[2] + 
                kernel_img_mul_497[3] + kernel_img_mul_497[4] + kernel_img_mul_497[5] + 
                kernel_img_mul_497[6] + kernel_img_mul_497[7] + kernel_img_mul_497[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3983:3976] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3983:3976] <= kernel_img_sum_497[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3983:3976] <= 'd0;
end

wire  [25:0]  kernel_img_mul_498[0:8];
assign kernel_img_mul_498[0] = buffer_data_2[3983:3976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_498[1] = buffer_data_2[3991:3984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_498[2] = buffer_data_2[3999:3992] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_498[3] = buffer_data_1[3983:3976] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_498[4] = buffer_data_1[3991:3984] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_498[5] = buffer_data_1[3999:3992] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_498[6] = buffer_data_0[3983:3976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_498[7] = buffer_data_0[3991:3984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_498[8] = buffer_data_0[3999:3992] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_498 = kernel_img_mul_498[0] + kernel_img_mul_498[1] + kernel_img_mul_498[2] + 
                kernel_img_mul_498[3] + kernel_img_mul_498[4] + kernel_img_mul_498[5] + 
                kernel_img_mul_498[6] + kernel_img_mul_498[7] + kernel_img_mul_498[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3991:3984] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3991:3984] <= kernel_img_sum_498[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3991:3984] <= 'd0;
end

wire  [25:0]  kernel_img_mul_499[0:8];
assign kernel_img_mul_499[0] = buffer_data_2[3991:3984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_499[1] = buffer_data_2[3999:3992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_499[2] = buffer_data_2[4007:4000] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_499[3] = buffer_data_1[3991:3984] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_499[4] = buffer_data_1[3999:3992] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_499[5] = buffer_data_1[4007:4000] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_499[6] = buffer_data_0[3991:3984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_499[7] = buffer_data_0[3999:3992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_499[8] = buffer_data_0[4007:4000] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_499 = kernel_img_mul_499[0] + kernel_img_mul_499[1] + kernel_img_mul_499[2] + 
                kernel_img_mul_499[3] + kernel_img_mul_499[4] + kernel_img_mul_499[5] + 
                kernel_img_mul_499[6] + kernel_img_mul_499[7] + kernel_img_mul_499[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[3999:3992] <= 'd0;
  else if (current_state==ST_START)
    blur_din[3999:3992] <= kernel_img_sum_499[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3999:3992] <= 'd0;
end

wire  [25:0]  kernel_img_mul_500[0:8];
assign kernel_img_mul_500[0] = buffer_data_2[3999:3992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_500[1] = buffer_data_2[4007:4000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_500[2] = buffer_data_2[4015:4008] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_500[3] = buffer_data_1[3999:3992] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_500[4] = buffer_data_1[4007:4000] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_500[5] = buffer_data_1[4015:4008] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_500[6] = buffer_data_0[3999:3992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_500[7] = buffer_data_0[4007:4000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_500[8] = buffer_data_0[4015:4008] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_500 = kernel_img_mul_500[0] + kernel_img_mul_500[1] + kernel_img_mul_500[2] + 
                kernel_img_mul_500[3] + kernel_img_mul_500[4] + kernel_img_mul_500[5] + 
                kernel_img_mul_500[6] + kernel_img_mul_500[7] + kernel_img_mul_500[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4007:4000] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4007:4000] <= kernel_img_sum_500[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4007:4000] <= 'd0;
end

wire  [25:0]  kernel_img_mul_501[0:8];
assign kernel_img_mul_501[0] = buffer_data_2[4007:4000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_501[1] = buffer_data_2[4015:4008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_501[2] = buffer_data_2[4023:4016] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_501[3] = buffer_data_1[4007:4000] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_501[4] = buffer_data_1[4015:4008] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_501[5] = buffer_data_1[4023:4016] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_501[6] = buffer_data_0[4007:4000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_501[7] = buffer_data_0[4015:4008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_501[8] = buffer_data_0[4023:4016] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_501 = kernel_img_mul_501[0] + kernel_img_mul_501[1] + kernel_img_mul_501[2] + 
                kernel_img_mul_501[3] + kernel_img_mul_501[4] + kernel_img_mul_501[5] + 
                kernel_img_mul_501[6] + kernel_img_mul_501[7] + kernel_img_mul_501[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4015:4008] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4015:4008] <= kernel_img_sum_501[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4015:4008] <= 'd0;
end

wire  [25:0]  kernel_img_mul_502[0:8];
assign kernel_img_mul_502[0] = buffer_data_2[4015:4008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_502[1] = buffer_data_2[4023:4016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_502[2] = buffer_data_2[4031:4024] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_502[3] = buffer_data_1[4015:4008] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_502[4] = buffer_data_1[4023:4016] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_502[5] = buffer_data_1[4031:4024] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_502[6] = buffer_data_0[4015:4008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_502[7] = buffer_data_0[4023:4016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_502[8] = buffer_data_0[4031:4024] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_502 = kernel_img_mul_502[0] + kernel_img_mul_502[1] + kernel_img_mul_502[2] + 
                kernel_img_mul_502[3] + kernel_img_mul_502[4] + kernel_img_mul_502[5] + 
                kernel_img_mul_502[6] + kernel_img_mul_502[7] + kernel_img_mul_502[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4023:4016] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4023:4016] <= kernel_img_sum_502[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4023:4016] <= 'd0;
end

wire  [25:0]  kernel_img_mul_503[0:8];
assign kernel_img_mul_503[0] = buffer_data_2[4023:4016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_503[1] = buffer_data_2[4031:4024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_503[2] = buffer_data_2[4039:4032] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_503[3] = buffer_data_1[4023:4016] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_503[4] = buffer_data_1[4031:4024] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_503[5] = buffer_data_1[4039:4032] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_503[6] = buffer_data_0[4023:4016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_503[7] = buffer_data_0[4031:4024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_503[8] = buffer_data_0[4039:4032] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_503 = kernel_img_mul_503[0] + kernel_img_mul_503[1] + kernel_img_mul_503[2] + 
                kernel_img_mul_503[3] + kernel_img_mul_503[4] + kernel_img_mul_503[5] + 
                kernel_img_mul_503[6] + kernel_img_mul_503[7] + kernel_img_mul_503[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4031:4024] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4031:4024] <= kernel_img_sum_503[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4031:4024] <= 'd0;
end

wire  [25:0]  kernel_img_mul_504[0:8];
assign kernel_img_mul_504[0] = buffer_data_2[4031:4024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_504[1] = buffer_data_2[4039:4032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_504[2] = buffer_data_2[4047:4040] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_504[3] = buffer_data_1[4031:4024] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_504[4] = buffer_data_1[4039:4032] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_504[5] = buffer_data_1[4047:4040] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_504[6] = buffer_data_0[4031:4024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_504[7] = buffer_data_0[4039:4032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_504[8] = buffer_data_0[4047:4040] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_504 = kernel_img_mul_504[0] + kernel_img_mul_504[1] + kernel_img_mul_504[2] + 
                kernel_img_mul_504[3] + kernel_img_mul_504[4] + kernel_img_mul_504[5] + 
                kernel_img_mul_504[6] + kernel_img_mul_504[7] + kernel_img_mul_504[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4039:4032] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4039:4032] <= kernel_img_sum_504[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4039:4032] <= 'd0;
end

wire  [25:0]  kernel_img_mul_505[0:8];
assign kernel_img_mul_505[0] = buffer_data_2[4039:4032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_505[1] = buffer_data_2[4047:4040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_505[2] = buffer_data_2[4055:4048] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_505[3] = buffer_data_1[4039:4032] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_505[4] = buffer_data_1[4047:4040] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_505[5] = buffer_data_1[4055:4048] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_505[6] = buffer_data_0[4039:4032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_505[7] = buffer_data_0[4047:4040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_505[8] = buffer_data_0[4055:4048] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_505 = kernel_img_mul_505[0] + kernel_img_mul_505[1] + kernel_img_mul_505[2] + 
                kernel_img_mul_505[3] + kernel_img_mul_505[4] + kernel_img_mul_505[5] + 
                kernel_img_mul_505[6] + kernel_img_mul_505[7] + kernel_img_mul_505[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4047:4040] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4047:4040] <= kernel_img_sum_505[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4047:4040] <= 'd0;
end

wire  [25:0]  kernel_img_mul_506[0:8];
assign kernel_img_mul_506[0] = buffer_data_2[4047:4040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_506[1] = buffer_data_2[4055:4048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_506[2] = buffer_data_2[4063:4056] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_506[3] = buffer_data_1[4047:4040] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_506[4] = buffer_data_1[4055:4048] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_506[5] = buffer_data_1[4063:4056] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_506[6] = buffer_data_0[4047:4040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_506[7] = buffer_data_0[4055:4048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_506[8] = buffer_data_0[4063:4056] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_506 = kernel_img_mul_506[0] + kernel_img_mul_506[1] + kernel_img_mul_506[2] + 
                kernel_img_mul_506[3] + kernel_img_mul_506[4] + kernel_img_mul_506[5] + 
                kernel_img_mul_506[6] + kernel_img_mul_506[7] + kernel_img_mul_506[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4055:4048] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4055:4048] <= kernel_img_sum_506[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4055:4048] <= 'd0;
end

wire  [25:0]  kernel_img_mul_507[0:8];
assign kernel_img_mul_507[0] = buffer_data_2[4055:4048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_507[1] = buffer_data_2[4063:4056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_507[2] = buffer_data_2[4071:4064] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_507[3] = buffer_data_1[4055:4048] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_507[4] = buffer_data_1[4063:4056] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_507[5] = buffer_data_1[4071:4064] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_507[6] = buffer_data_0[4055:4048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_507[7] = buffer_data_0[4063:4056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_507[8] = buffer_data_0[4071:4064] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_507 = kernel_img_mul_507[0] + kernel_img_mul_507[1] + kernel_img_mul_507[2] + 
                kernel_img_mul_507[3] + kernel_img_mul_507[4] + kernel_img_mul_507[5] + 
                kernel_img_mul_507[6] + kernel_img_mul_507[7] + kernel_img_mul_507[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4063:4056] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4063:4056] <= kernel_img_sum_507[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4063:4056] <= 'd0;
end

wire  [25:0]  kernel_img_mul_508[0:8];
assign kernel_img_mul_508[0] = buffer_data_2[4063:4056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_508[1] = buffer_data_2[4071:4064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_508[2] = buffer_data_2[4079:4072] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_508[3] = buffer_data_1[4063:4056] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_508[4] = buffer_data_1[4071:4064] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_508[5] = buffer_data_1[4079:4072] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_508[6] = buffer_data_0[4063:4056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_508[7] = buffer_data_0[4071:4064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_508[8] = buffer_data_0[4079:4072] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_508 = kernel_img_mul_508[0] + kernel_img_mul_508[1] + kernel_img_mul_508[2] + 
                kernel_img_mul_508[3] + kernel_img_mul_508[4] + kernel_img_mul_508[5] + 
                kernel_img_mul_508[6] + kernel_img_mul_508[7] + kernel_img_mul_508[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4071:4064] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4071:4064] <= kernel_img_sum_508[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4071:4064] <= 'd0;
end

wire  [25:0]  kernel_img_mul_509[0:8];
assign kernel_img_mul_509[0] = buffer_data_2[4071:4064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_509[1] = buffer_data_2[4079:4072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_509[2] = buffer_data_2[4087:4080] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_509[3] = buffer_data_1[4071:4064] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_509[4] = buffer_data_1[4079:4072] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_509[5] = buffer_data_1[4087:4080] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_509[6] = buffer_data_0[4071:4064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_509[7] = buffer_data_0[4079:4072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_509[8] = buffer_data_0[4087:4080] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_509 = kernel_img_mul_509[0] + kernel_img_mul_509[1] + kernel_img_mul_509[2] + 
                kernel_img_mul_509[3] + kernel_img_mul_509[4] + kernel_img_mul_509[5] + 
                kernel_img_mul_509[6] + kernel_img_mul_509[7] + kernel_img_mul_509[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4079:4072] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4079:4072] <= kernel_img_sum_509[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4079:4072] <= 'd0;
end

wire  [25:0]  kernel_img_mul_510[0:8];
assign kernel_img_mul_510[0] = buffer_data_2[4079:4072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_510[1] = buffer_data_2[4087:4080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_510[2] = buffer_data_2[4095:4088] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_510[3] = buffer_data_1[4079:4072] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_510[4] = buffer_data_1[4087:4080] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_510[5] = buffer_data_1[4095:4088] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_510[6] = buffer_data_0[4079:4072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_510[7] = buffer_data_0[4087:4080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_510[8] = buffer_data_0[4095:4088] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_510 = kernel_img_mul_510[0] + kernel_img_mul_510[1] + kernel_img_mul_510[2] + 
                kernel_img_mul_510[3] + kernel_img_mul_510[4] + kernel_img_mul_510[5] + 
                kernel_img_mul_510[6] + kernel_img_mul_510[7] + kernel_img_mul_510[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4087:4080] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4087:4080] <= kernel_img_sum_510[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4087:4080] <= 'd0;
end

wire  [25:0]  kernel_img_mul_511[0:8];
assign kernel_img_mul_511[0] = buffer_data_2[4087:4080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_511[1] = buffer_data_2[4095:4088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_511[2] = buffer_data_2[4103:4096] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_511[3] = buffer_data_1[4087:4080] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_511[4] = buffer_data_1[4095:4088] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_511[5] = buffer_data_1[4103:4096] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_511[6] = buffer_data_0[4087:4080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_511[7] = buffer_data_0[4095:4088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_511[8] = buffer_data_0[4103:4096] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_511 = kernel_img_mul_511[0] + kernel_img_mul_511[1] + kernel_img_mul_511[2] + 
                kernel_img_mul_511[3] + kernel_img_mul_511[4] + kernel_img_mul_511[5] + 
                kernel_img_mul_511[6] + kernel_img_mul_511[7] + kernel_img_mul_511[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4095:4088] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4095:4088] <= kernel_img_sum_511[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4095:4088] <= 'd0;
end

wire  [25:0]  kernel_img_mul_512[0:8];
assign kernel_img_mul_512[0] = buffer_data_2[4095:4088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_512[1] = buffer_data_2[4103:4096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_512[2] = buffer_data_2[4111:4104] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_512[3] = buffer_data_1[4095:4088] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_512[4] = buffer_data_1[4103:4096] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_512[5] = buffer_data_1[4111:4104] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_512[6] = buffer_data_0[4095:4088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_512[7] = buffer_data_0[4103:4096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_512[8] = buffer_data_0[4111:4104] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_512 = kernel_img_mul_512[0] + kernel_img_mul_512[1] + kernel_img_mul_512[2] + 
                kernel_img_mul_512[3] + kernel_img_mul_512[4] + kernel_img_mul_512[5] + 
                kernel_img_mul_512[6] + kernel_img_mul_512[7] + kernel_img_mul_512[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4103:4096] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4103:4096] <= kernel_img_sum_512[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4103:4096] <= 'd0;
end

wire  [25:0]  kernel_img_mul_513[0:8];
assign kernel_img_mul_513[0] = buffer_data_2[4103:4096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_513[1] = buffer_data_2[4111:4104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_513[2] = buffer_data_2[4119:4112] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_513[3] = buffer_data_1[4103:4096] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_513[4] = buffer_data_1[4111:4104] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_513[5] = buffer_data_1[4119:4112] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_513[6] = buffer_data_0[4103:4096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_513[7] = buffer_data_0[4111:4104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_513[8] = buffer_data_0[4119:4112] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_513 = kernel_img_mul_513[0] + kernel_img_mul_513[1] + kernel_img_mul_513[2] + 
                kernel_img_mul_513[3] + kernel_img_mul_513[4] + kernel_img_mul_513[5] + 
                kernel_img_mul_513[6] + kernel_img_mul_513[7] + kernel_img_mul_513[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4111:4104] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4111:4104] <= kernel_img_sum_513[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4111:4104] <= 'd0;
end

wire  [25:0]  kernel_img_mul_514[0:8];
assign kernel_img_mul_514[0] = buffer_data_2[4111:4104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_514[1] = buffer_data_2[4119:4112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_514[2] = buffer_data_2[4127:4120] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_514[3] = buffer_data_1[4111:4104] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_514[4] = buffer_data_1[4119:4112] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_514[5] = buffer_data_1[4127:4120] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_514[6] = buffer_data_0[4111:4104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_514[7] = buffer_data_0[4119:4112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_514[8] = buffer_data_0[4127:4120] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_514 = kernel_img_mul_514[0] + kernel_img_mul_514[1] + kernel_img_mul_514[2] + 
                kernel_img_mul_514[3] + kernel_img_mul_514[4] + kernel_img_mul_514[5] + 
                kernel_img_mul_514[6] + kernel_img_mul_514[7] + kernel_img_mul_514[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4119:4112] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4119:4112] <= kernel_img_sum_514[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4119:4112] <= 'd0;
end

wire  [25:0]  kernel_img_mul_515[0:8];
assign kernel_img_mul_515[0] = buffer_data_2[4119:4112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_515[1] = buffer_data_2[4127:4120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_515[2] = buffer_data_2[4135:4128] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_515[3] = buffer_data_1[4119:4112] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_515[4] = buffer_data_1[4127:4120] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_515[5] = buffer_data_1[4135:4128] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_515[6] = buffer_data_0[4119:4112] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_515[7] = buffer_data_0[4127:4120] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_515[8] = buffer_data_0[4135:4128] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_515 = kernel_img_mul_515[0] + kernel_img_mul_515[1] + kernel_img_mul_515[2] + 
                kernel_img_mul_515[3] + kernel_img_mul_515[4] + kernel_img_mul_515[5] + 
                kernel_img_mul_515[6] + kernel_img_mul_515[7] + kernel_img_mul_515[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4127:4120] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4127:4120] <= kernel_img_sum_515[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4127:4120] <= 'd0;
end

wire  [25:0]  kernel_img_mul_516[0:8];
assign kernel_img_mul_516[0] = buffer_data_2[4127:4120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_516[1] = buffer_data_2[4135:4128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_516[2] = buffer_data_2[4143:4136] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_516[3] = buffer_data_1[4127:4120] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_516[4] = buffer_data_1[4135:4128] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_516[5] = buffer_data_1[4143:4136] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_516[6] = buffer_data_0[4127:4120] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_516[7] = buffer_data_0[4135:4128] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_516[8] = buffer_data_0[4143:4136] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_516 = kernel_img_mul_516[0] + kernel_img_mul_516[1] + kernel_img_mul_516[2] + 
                kernel_img_mul_516[3] + kernel_img_mul_516[4] + kernel_img_mul_516[5] + 
                kernel_img_mul_516[6] + kernel_img_mul_516[7] + kernel_img_mul_516[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4135:4128] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4135:4128] <= kernel_img_sum_516[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4135:4128] <= 'd0;
end

wire  [25:0]  kernel_img_mul_517[0:8];
assign kernel_img_mul_517[0] = buffer_data_2[4135:4128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_517[1] = buffer_data_2[4143:4136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_517[2] = buffer_data_2[4151:4144] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_517[3] = buffer_data_1[4135:4128] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_517[4] = buffer_data_1[4143:4136] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_517[5] = buffer_data_1[4151:4144] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_517[6] = buffer_data_0[4135:4128] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_517[7] = buffer_data_0[4143:4136] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_517[8] = buffer_data_0[4151:4144] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_517 = kernel_img_mul_517[0] + kernel_img_mul_517[1] + kernel_img_mul_517[2] + 
                kernel_img_mul_517[3] + kernel_img_mul_517[4] + kernel_img_mul_517[5] + 
                kernel_img_mul_517[6] + kernel_img_mul_517[7] + kernel_img_mul_517[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4143:4136] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4143:4136] <= kernel_img_sum_517[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4143:4136] <= 'd0;
end

wire  [25:0]  kernel_img_mul_518[0:8];
assign kernel_img_mul_518[0] = buffer_data_2[4143:4136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_518[1] = buffer_data_2[4151:4144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_518[2] = buffer_data_2[4159:4152] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_518[3] = buffer_data_1[4143:4136] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_518[4] = buffer_data_1[4151:4144] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_518[5] = buffer_data_1[4159:4152] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_518[6] = buffer_data_0[4143:4136] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_518[7] = buffer_data_0[4151:4144] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_518[8] = buffer_data_0[4159:4152] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_518 = kernel_img_mul_518[0] + kernel_img_mul_518[1] + kernel_img_mul_518[2] + 
                kernel_img_mul_518[3] + kernel_img_mul_518[4] + kernel_img_mul_518[5] + 
                kernel_img_mul_518[6] + kernel_img_mul_518[7] + kernel_img_mul_518[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4151:4144] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4151:4144] <= kernel_img_sum_518[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4151:4144] <= 'd0;
end

wire  [25:0]  kernel_img_mul_519[0:8];
assign kernel_img_mul_519[0] = buffer_data_2[4151:4144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_519[1] = buffer_data_2[4159:4152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_519[2] = buffer_data_2[4167:4160] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_519[3] = buffer_data_1[4151:4144] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_519[4] = buffer_data_1[4159:4152] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_519[5] = buffer_data_1[4167:4160] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_519[6] = buffer_data_0[4151:4144] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_519[7] = buffer_data_0[4159:4152] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_519[8] = buffer_data_0[4167:4160] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_519 = kernel_img_mul_519[0] + kernel_img_mul_519[1] + kernel_img_mul_519[2] + 
                kernel_img_mul_519[3] + kernel_img_mul_519[4] + kernel_img_mul_519[5] + 
                kernel_img_mul_519[6] + kernel_img_mul_519[7] + kernel_img_mul_519[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4159:4152] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4159:4152] <= kernel_img_sum_519[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4159:4152] <= 'd0;
end

wire  [25:0]  kernel_img_mul_520[0:8];
assign kernel_img_mul_520[0] = buffer_data_2[4159:4152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_520[1] = buffer_data_2[4167:4160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_520[2] = buffer_data_2[4175:4168] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_520[3] = buffer_data_1[4159:4152] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_520[4] = buffer_data_1[4167:4160] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_520[5] = buffer_data_1[4175:4168] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_520[6] = buffer_data_0[4159:4152] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_520[7] = buffer_data_0[4167:4160] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_520[8] = buffer_data_0[4175:4168] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_520 = kernel_img_mul_520[0] + kernel_img_mul_520[1] + kernel_img_mul_520[2] + 
                kernel_img_mul_520[3] + kernel_img_mul_520[4] + kernel_img_mul_520[5] + 
                kernel_img_mul_520[6] + kernel_img_mul_520[7] + kernel_img_mul_520[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4167:4160] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4167:4160] <= kernel_img_sum_520[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4167:4160] <= 'd0;
end

wire  [25:0]  kernel_img_mul_521[0:8];
assign kernel_img_mul_521[0] = buffer_data_2[4167:4160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_521[1] = buffer_data_2[4175:4168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_521[2] = buffer_data_2[4183:4176] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_521[3] = buffer_data_1[4167:4160] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_521[4] = buffer_data_1[4175:4168] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_521[5] = buffer_data_1[4183:4176] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_521[6] = buffer_data_0[4167:4160] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_521[7] = buffer_data_0[4175:4168] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_521[8] = buffer_data_0[4183:4176] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_521 = kernel_img_mul_521[0] + kernel_img_mul_521[1] + kernel_img_mul_521[2] + 
                kernel_img_mul_521[3] + kernel_img_mul_521[4] + kernel_img_mul_521[5] + 
                kernel_img_mul_521[6] + kernel_img_mul_521[7] + kernel_img_mul_521[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4175:4168] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4175:4168] <= kernel_img_sum_521[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4175:4168] <= 'd0;
end

wire  [25:0]  kernel_img_mul_522[0:8];
assign kernel_img_mul_522[0] = buffer_data_2[4175:4168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_522[1] = buffer_data_2[4183:4176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_522[2] = buffer_data_2[4191:4184] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_522[3] = buffer_data_1[4175:4168] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_522[4] = buffer_data_1[4183:4176] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_522[5] = buffer_data_1[4191:4184] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_522[6] = buffer_data_0[4175:4168] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_522[7] = buffer_data_0[4183:4176] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_522[8] = buffer_data_0[4191:4184] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_522 = kernel_img_mul_522[0] + kernel_img_mul_522[1] + kernel_img_mul_522[2] + 
                kernel_img_mul_522[3] + kernel_img_mul_522[4] + kernel_img_mul_522[5] + 
                kernel_img_mul_522[6] + kernel_img_mul_522[7] + kernel_img_mul_522[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4183:4176] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4183:4176] <= kernel_img_sum_522[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4183:4176] <= 'd0;
end

wire  [25:0]  kernel_img_mul_523[0:8];
assign kernel_img_mul_523[0] = buffer_data_2[4183:4176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_523[1] = buffer_data_2[4191:4184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_523[2] = buffer_data_2[4199:4192] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_523[3] = buffer_data_1[4183:4176] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_523[4] = buffer_data_1[4191:4184] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_523[5] = buffer_data_1[4199:4192] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_523[6] = buffer_data_0[4183:4176] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_523[7] = buffer_data_0[4191:4184] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_523[8] = buffer_data_0[4199:4192] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_523 = kernel_img_mul_523[0] + kernel_img_mul_523[1] + kernel_img_mul_523[2] + 
                kernel_img_mul_523[3] + kernel_img_mul_523[4] + kernel_img_mul_523[5] + 
                kernel_img_mul_523[6] + kernel_img_mul_523[7] + kernel_img_mul_523[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4191:4184] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4191:4184] <= kernel_img_sum_523[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4191:4184] <= 'd0;
end

wire  [25:0]  kernel_img_mul_524[0:8];
assign kernel_img_mul_524[0] = buffer_data_2[4191:4184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_524[1] = buffer_data_2[4199:4192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_524[2] = buffer_data_2[4207:4200] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_524[3] = buffer_data_1[4191:4184] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_524[4] = buffer_data_1[4199:4192] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_524[5] = buffer_data_1[4207:4200] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_524[6] = buffer_data_0[4191:4184] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_524[7] = buffer_data_0[4199:4192] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_524[8] = buffer_data_0[4207:4200] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_524 = kernel_img_mul_524[0] + kernel_img_mul_524[1] + kernel_img_mul_524[2] + 
                kernel_img_mul_524[3] + kernel_img_mul_524[4] + kernel_img_mul_524[5] + 
                kernel_img_mul_524[6] + kernel_img_mul_524[7] + kernel_img_mul_524[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4199:4192] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4199:4192] <= kernel_img_sum_524[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4199:4192] <= 'd0;
end

wire  [25:0]  kernel_img_mul_525[0:8];
assign kernel_img_mul_525[0] = buffer_data_2[4199:4192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_525[1] = buffer_data_2[4207:4200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_525[2] = buffer_data_2[4215:4208] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_525[3] = buffer_data_1[4199:4192] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_525[4] = buffer_data_1[4207:4200] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_525[5] = buffer_data_1[4215:4208] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_525[6] = buffer_data_0[4199:4192] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_525[7] = buffer_data_0[4207:4200] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_525[8] = buffer_data_0[4215:4208] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_525 = kernel_img_mul_525[0] + kernel_img_mul_525[1] + kernel_img_mul_525[2] + 
                kernel_img_mul_525[3] + kernel_img_mul_525[4] + kernel_img_mul_525[5] + 
                kernel_img_mul_525[6] + kernel_img_mul_525[7] + kernel_img_mul_525[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4207:4200] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4207:4200] <= kernel_img_sum_525[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4207:4200] <= 'd0;
end

wire  [25:0]  kernel_img_mul_526[0:8];
assign kernel_img_mul_526[0] = buffer_data_2[4207:4200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_526[1] = buffer_data_2[4215:4208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_526[2] = buffer_data_2[4223:4216] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_526[3] = buffer_data_1[4207:4200] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_526[4] = buffer_data_1[4215:4208] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_526[5] = buffer_data_1[4223:4216] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_526[6] = buffer_data_0[4207:4200] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_526[7] = buffer_data_0[4215:4208] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_526[8] = buffer_data_0[4223:4216] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_526 = kernel_img_mul_526[0] + kernel_img_mul_526[1] + kernel_img_mul_526[2] + 
                kernel_img_mul_526[3] + kernel_img_mul_526[4] + kernel_img_mul_526[5] + 
                kernel_img_mul_526[6] + kernel_img_mul_526[7] + kernel_img_mul_526[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4215:4208] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4215:4208] <= kernel_img_sum_526[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4215:4208] <= 'd0;
end

wire  [25:0]  kernel_img_mul_527[0:8];
assign kernel_img_mul_527[0] = buffer_data_2[4215:4208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_527[1] = buffer_data_2[4223:4216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_527[2] = buffer_data_2[4231:4224] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_527[3] = buffer_data_1[4215:4208] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_527[4] = buffer_data_1[4223:4216] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_527[5] = buffer_data_1[4231:4224] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_527[6] = buffer_data_0[4215:4208] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_527[7] = buffer_data_0[4223:4216] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_527[8] = buffer_data_0[4231:4224] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_527 = kernel_img_mul_527[0] + kernel_img_mul_527[1] + kernel_img_mul_527[2] + 
                kernel_img_mul_527[3] + kernel_img_mul_527[4] + kernel_img_mul_527[5] + 
                kernel_img_mul_527[6] + kernel_img_mul_527[7] + kernel_img_mul_527[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4223:4216] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4223:4216] <= kernel_img_sum_527[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4223:4216] <= 'd0;
end

wire  [25:0]  kernel_img_mul_528[0:8];
assign kernel_img_mul_528[0] = buffer_data_2[4223:4216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_528[1] = buffer_data_2[4231:4224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_528[2] = buffer_data_2[4239:4232] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_528[3] = buffer_data_1[4223:4216] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_528[4] = buffer_data_1[4231:4224] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_528[5] = buffer_data_1[4239:4232] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_528[6] = buffer_data_0[4223:4216] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_528[7] = buffer_data_0[4231:4224] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_528[8] = buffer_data_0[4239:4232] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_528 = kernel_img_mul_528[0] + kernel_img_mul_528[1] + kernel_img_mul_528[2] + 
                kernel_img_mul_528[3] + kernel_img_mul_528[4] + kernel_img_mul_528[5] + 
                kernel_img_mul_528[6] + kernel_img_mul_528[7] + kernel_img_mul_528[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4231:4224] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4231:4224] <= kernel_img_sum_528[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4231:4224] <= 'd0;
end

wire  [25:0]  kernel_img_mul_529[0:8];
assign kernel_img_mul_529[0] = buffer_data_2[4231:4224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_529[1] = buffer_data_2[4239:4232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_529[2] = buffer_data_2[4247:4240] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_529[3] = buffer_data_1[4231:4224] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_529[4] = buffer_data_1[4239:4232] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_529[5] = buffer_data_1[4247:4240] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_529[6] = buffer_data_0[4231:4224] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_529[7] = buffer_data_0[4239:4232] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_529[8] = buffer_data_0[4247:4240] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_529 = kernel_img_mul_529[0] + kernel_img_mul_529[1] + kernel_img_mul_529[2] + 
                kernel_img_mul_529[3] + kernel_img_mul_529[4] + kernel_img_mul_529[5] + 
                kernel_img_mul_529[6] + kernel_img_mul_529[7] + kernel_img_mul_529[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4239:4232] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4239:4232] <= kernel_img_sum_529[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4239:4232] <= 'd0;
end

wire  [25:0]  kernel_img_mul_530[0:8];
assign kernel_img_mul_530[0] = buffer_data_2[4239:4232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_530[1] = buffer_data_2[4247:4240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_530[2] = buffer_data_2[4255:4248] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_530[3] = buffer_data_1[4239:4232] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_530[4] = buffer_data_1[4247:4240] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_530[5] = buffer_data_1[4255:4248] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_530[6] = buffer_data_0[4239:4232] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_530[7] = buffer_data_0[4247:4240] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_530[8] = buffer_data_0[4255:4248] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_530 = kernel_img_mul_530[0] + kernel_img_mul_530[1] + kernel_img_mul_530[2] + 
                kernel_img_mul_530[3] + kernel_img_mul_530[4] + kernel_img_mul_530[5] + 
                kernel_img_mul_530[6] + kernel_img_mul_530[7] + kernel_img_mul_530[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4247:4240] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4247:4240] <= kernel_img_sum_530[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4247:4240] <= 'd0;
end

wire  [25:0]  kernel_img_mul_531[0:8];
assign kernel_img_mul_531[0] = buffer_data_2[4247:4240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_531[1] = buffer_data_2[4255:4248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_531[2] = buffer_data_2[4263:4256] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_531[3] = buffer_data_1[4247:4240] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_531[4] = buffer_data_1[4255:4248] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_531[5] = buffer_data_1[4263:4256] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_531[6] = buffer_data_0[4247:4240] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_531[7] = buffer_data_0[4255:4248] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_531[8] = buffer_data_0[4263:4256] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_531 = kernel_img_mul_531[0] + kernel_img_mul_531[1] + kernel_img_mul_531[2] + 
                kernel_img_mul_531[3] + kernel_img_mul_531[4] + kernel_img_mul_531[5] + 
                kernel_img_mul_531[6] + kernel_img_mul_531[7] + kernel_img_mul_531[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4255:4248] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4255:4248] <= kernel_img_sum_531[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4255:4248] <= 'd0;
end

wire  [25:0]  kernel_img_mul_532[0:8];
assign kernel_img_mul_532[0] = buffer_data_2[4255:4248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_532[1] = buffer_data_2[4263:4256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_532[2] = buffer_data_2[4271:4264] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_532[3] = buffer_data_1[4255:4248] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_532[4] = buffer_data_1[4263:4256] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_532[5] = buffer_data_1[4271:4264] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_532[6] = buffer_data_0[4255:4248] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_532[7] = buffer_data_0[4263:4256] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_532[8] = buffer_data_0[4271:4264] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_532 = kernel_img_mul_532[0] + kernel_img_mul_532[1] + kernel_img_mul_532[2] + 
                kernel_img_mul_532[3] + kernel_img_mul_532[4] + kernel_img_mul_532[5] + 
                kernel_img_mul_532[6] + kernel_img_mul_532[7] + kernel_img_mul_532[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4263:4256] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4263:4256] <= kernel_img_sum_532[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4263:4256] <= 'd0;
end

wire  [25:0]  kernel_img_mul_533[0:8];
assign kernel_img_mul_533[0] = buffer_data_2[4263:4256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_533[1] = buffer_data_2[4271:4264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_533[2] = buffer_data_2[4279:4272] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_533[3] = buffer_data_1[4263:4256] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_533[4] = buffer_data_1[4271:4264] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_533[5] = buffer_data_1[4279:4272] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_533[6] = buffer_data_0[4263:4256] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_533[7] = buffer_data_0[4271:4264] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_533[8] = buffer_data_0[4279:4272] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_533 = kernel_img_mul_533[0] + kernel_img_mul_533[1] + kernel_img_mul_533[2] + 
                kernel_img_mul_533[3] + kernel_img_mul_533[4] + kernel_img_mul_533[5] + 
                kernel_img_mul_533[6] + kernel_img_mul_533[7] + kernel_img_mul_533[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4271:4264] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4271:4264] <= kernel_img_sum_533[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4271:4264] <= 'd0;
end

wire  [25:0]  kernel_img_mul_534[0:8];
assign kernel_img_mul_534[0] = buffer_data_2[4271:4264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_534[1] = buffer_data_2[4279:4272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_534[2] = buffer_data_2[4287:4280] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_534[3] = buffer_data_1[4271:4264] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_534[4] = buffer_data_1[4279:4272] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_534[5] = buffer_data_1[4287:4280] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_534[6] = buffer_data_0[4271:4264] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_534[7] = buffer_data_0[4279:4272] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_534[8] = buffer_data_0[4287:4280] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_534 = kernel_img_mul_534[0] + kernel_img_mul_534[1] + kernel_img_mul_534[2] + 
                kernel_img_mul_534[3] + kernel_img_mul_534[4] + kernel_img_mul_534[5] + 
                kernel_img_mul_534[6] + kernel_img_mul_534[7] + kernel_img_mul_534[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4279:4272] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4279:4272] <= kernel_img_sum_534[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4279:4272] <= 'd0;
end

wire  [25:0]  kernel_img_mul_535[0:8];
assign kernel_img_mul_535[0] = buffer_data_2[4279:4272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_535[1] = buffer_data_2[4287:4280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_535[2] = buffer_data_2[4295:4288] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_535[3] = buffer_data_1[4279:4272] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_535[4] = buffer_data_1[4287:4280] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_535[5] = buffer_data_1[4295:4288] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_535[6] = buffer_data_0[4279:4272] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_535[7] = buffer_data_0[4287:4280] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_535[8] = buffer_data_0[4295:4288] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_535 = kernel_img_mul_535[0] + kernel_img_mul_535[1] + kernel_img_mul_535[2] + 
                kernel_img_mul_535[3] + kernel_img_mul_535[4] + kernel_img_mul_535[5] + 
                kernel_img_mul_535[6] + kernel_img_mul_535[7] + kernel_img_mul_535[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4287:4280] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4287:4280] <= kernel_img_sum_535[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4287:4280] <= 'd0;
end

wire  [25:0]  kernel_img_mul_536[0:8];
assign kernel_img_mul_536[0] = buffer_data_2[4287:4280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_536[1] = buffer_data_2[4295:4288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_536[2] = buffer_data_2[4303:4296] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_536[3] = buffer_data_1[4287:4280] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_536[4] = buffer_data_1[4295:4288] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_536[5] = buffer_data_1[4303:4296] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_536[6] = buffer_data_0[4287:4280] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_536[7] = buffer_data_0[4295:4288] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_536[8] = buffer_data_0[4303:4296] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_536 = kernel_img_mul_536[0] + kernel_img_mul_536[1] + kernel_img_mul_536[2] + 
                kernel_img_mul_536[3] + kernel_img_mul_536[4] + kernel_img_mul_536[5] + 
                kernel_img_mul_536[6] + kernel_img_mul_536[7] + kernel_img_mul_536[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4295:4288] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4295:4288] <= kernel_img_sum_536[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4295:4288] <= 'd0;
end

wire  [25:0]  kernel_img_mul_537[0:8];
assign kernel_img_mul_537[0] = buffer_data_2[4295:4288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_537[1] = buffer_data_2[4303:4296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_537[2] = buffer_data_2[4311:4304] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_537[3] = buffer_data_1[4295:4288] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_537[4] = buffer_data_1[4303:4296] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_537[5] = buffer_data_1[4311:4304] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_537[6] = buffer_data_0[4295:4288] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_537[7] = buffer_data_0[4303:4296] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_537[8] = buffer_data_0[4311:4304] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_537 = kernel_img_mul_537[0] + kernel_img_mul_537[1] + kernel_img_mul_537[2] + 
                kernel_img_mul_537[3] + kernel_img_mul_537[4] + kernel_img_mul_537[5] + 
                kernel_img_mul_537[6] + kernel_img_mul_537[7] + kernel_img_mul_537[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4303:4296] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4303:4296] <= kernel_img_sum_537[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4303:4296] <= 'd0;
end

wire  [25:0]  kernel_img_mul_538[0:8];
assign kernel_img_mul_538[0] = buffer_data_2[4303:4296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_538[1] = buffer_data_2[4311:4304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_538[2] = buffer_data_2[4319:4312] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_538[3] = buffer_data_1[4303:4296] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_538[4] = buffer_data_1[4311:4304] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_538[5] = buffer_data_1[4319:4312] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_538[6] = buffer_data_0[4303:4296] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_538[7] = buffer_data_0[4311:4304] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_538[8] = buffer_data_0[4319:4312] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_538 = kernel_img_mul_538[0] + kernel_img_mul_538[1] + kernel_img_mul_538[2] + 
                kernel_img_mul_538[3] + kernel_img_mul_538[4] + kernel_img_mul_538[5] + 
                kernel_img_mul_538[6] + kernel_img_mul_538[7] + kernel_img_mul_538[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4311:4304] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4311:4304] <= kernel_img_sum_538[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4311:4304] <= 'd0;
end

wire  [25:0]  kernel_img_mul_539[0:8];
assign kernel_img_mul_539[0] = buffer_data_2[4311:4304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_539[1] = buffer_data_2[4319:4312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_539[2] = buffer_data_2[4327:4320] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_539[3] = buffer_data_1[4311:4304] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_539[4] = buffer_data_1[4319:4312] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_539[5] = buffer_data_1[4327:4320] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_539[6] = buffer_data_0[4311:4304] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_539[7] = buffer_data_0[4319:4312] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_539[8] = buffer_data_0[4327:4320] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_539 = kernel_img_mul_539[0] + kernel_img_mul_539[1] + kernel_img_mul_539[2] + 
                kernel_img_mul_539[3] + kernel_img_mul_539[4] + kernel_img_mul_539[5] + 
                kernel_img_mul_539[6] + kernel_img_mul_539[7] + kernel_img_mul_539[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4319:4312] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4319:4312] <= kernel_img_sum_539[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4319:4312] <= 'd0;
end

wire  [25:0]  kernel_img_mul_540[0:8];
assign kernel_img_mul_540[0] = buffer_data_2[4319:4312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_540[1] = buffer_data_2[4327:4320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_540[2] = buffer_data_2[4335:4328] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_540[3] = buffer_data_1[4319:4312] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_540[4] = buffer_data_1[4327:4320] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_540[5] = buffer_data_1[4335:4328] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_540[6] = buffer_data_0[4319:4312] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_540[7] = buffer_data_0[4327:4320] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_540[8] = buffer_data_0[4335:4328] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_540 = kernel_img_mul_540[0] + kernel_img_mul_540[1] + kernel_img_mul_540[2] + 
                kernel_img_mul_540[3] + kernel_img_mul_540[4] + kernel_img_mul_540[5] + 
                kernel_img_mul_540[6] + kernel_img_mul_540[7] + kernel_img_mul_540[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4327:4320] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4327:4320] <= kernel_img_sum_540[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4327:4320] <= 'd0;
end

wire  [25:0]  kernel_img_mul_541[0:8];
assign kernel_img_mul_541[0] = buffer_data_2[4327:4320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_541[1] = buffer_data_2[4335:4328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_541[2] = buffer_data_2[4343:4336] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_541[3] = buffer_data_1[4327:4320] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_541[4] = buffer_data_1[4335:4328] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_541[5] = buffer_data_1[4343:4336] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_541[6] = buffer_data_0[4327:4320] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_541[7] = buffer_data_0[4335:4328] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_541[8] = buffer_data_0[4343:4336] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_541 = kernel_img_mul_541[0] + kernel_img_mul_541[1] + kernel_img_mul_541[2] + 
                kernel_img_mul_541[3] + kernel_img_mul_541[4] + kernel_img_mul_541[5] + 
                kernel_img_mul_541[6] + kernel_img_mul_541[7] + kernel_img_mul_541[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4335:4328] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4335:4328] <= kernel_img_sum_541[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4335:4328] <= 'd0;
end

wire  [25:0]  kernel_img_mul_542[0:8];
assign kernel_img_mul_542[0] = buffer_data_2[4335:4328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_542[1] = buffer_data_2[4343:4336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_542[2] = buffer_data_2[4351:4344] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_542[3] = buffer_data_1[4335:4328] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_542[4] = buffer_data_1[4343:4336] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_542[5] = buffer_data_1[4351:4344] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_542[6] = buffer_data_0[4335:4328] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_542[7] = buffer_data_0[4343:4336] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_542[8] = buffer_data_0[4351:4344] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_542 = kernel_img_mul_542[0] + kernel_img_mul_542[1] + kernel_img_mul_542[2] + 
                kernel_img_mul_542[3] + kernel_img_mul_542[4] + kernel_img_mul_542[5] + 
                kernel_img_mul_542[6] + kernel_img_mul_542[7] + kernel_img_mul_542[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4343:4336] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4343:4336] <= kernel_img_sum_542[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4343:4336] <= 'd0;
end

wire  [25:0]  kernel_img_mul_543[0:8];
assign kernel_img_mul_543[0] = buffer_data_2[4343:4336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_543[1] = buffer_data_2[4351:4344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_543[2] = buffer_data_2[4359:4352] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_543[3] = buffer_data_1[4343:4336] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_543[4] = buffer_data_1[4351:4344] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_543[5] = buffer_data_1[4359:4352] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_543[6] = buffer_data_0[4343:4336] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_543[7] = buffer_data_0[4351:4344] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_543[8] = buffer_data_0[4359:4352] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_543 = kernel_img_mul_543[0] + kernel_img_mul_543[1] + kernel_img_mul_543[2] + 
                kernel_img_mul_543[3] + kernel_img_mul_543[4] + kernel_img_mul_543[5] + 
                kernel_img_mul_543[6] + kernel_img_mul_543[7] + kernel_img_mul_543[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4351:4344] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4351:4344] <= kernel_img_sum_543[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4351:4344] <= 'd0;
end

wire  [25:0]  kernel_img_mul_544[0:8];
assign kernel_img_mul_544[0] = buffer_data_2[4351:4344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_544[1] = buffer_data_2[4359:4352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_544[2] = buffer_data_2[4367:4360] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_544[3] = buffer_data_1[4351:4344] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_544[4] = buffer_data_1[4359:4352] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_544[5] = buffer_data_1[4367:4360] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_544[6] = buffer_data_0[4351:4344] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_544[7] = buffer_data_0[4359:4352] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_544[8] = buffer_data_0[4367:4360] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_544 = kernel_img_mul_544[0] + kernel_img_mul_544[1] + kernel_img_mul_544[2] + 
                kernel_img_mul_544[3] + kernel_img_mul_544[4] + kernel_img_mul_544[5] + 
                kernel_img_mul_544[6] + kernel_img_mul_544[7] + kernel_img_mul_544[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4359:4352] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4359:4352] <= kernel_img_sum_544[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4359:4352] <= 'd0;
end

wire  [25:0]  kernel_img_mul_545[0:8];
assign kernel_img_mul_545[0] = buffer_data_2[4359:4352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_545[1] = buffer_data_2[4367:4360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_545[2] = buffer_data_2[4375:4368] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_545[3] = buffer_data_1[4359:4352] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_545[4] = buffer_data_1[4367:4360] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_545[5] = buffer_data_1[4375:4368] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_545[6] = buffer_data_0[4359:4352] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_545[7] = buffer_data_0[4367:4360] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_545[8] = buffer_data_0[4375:4368] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_545 = kernel_img_mul_545[0] + kernel_img_mul_545[1] + kernel_img_mul_545[2] + 
                kernel_img_mul_545[3] + kernel_img_mul_545[4] + kernel_img_mul_545[5] + 
                kernel_img_mul_545[6] + kernel_img_mul_545[7] + kernel_img_mul_545[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4367:4360] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4367:4360] <= kernel_img_sum_545[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4367:4360] <= 'd0;
end

wire  [25:0]  kernel_img_mul_546[0:8];
assign kernel_img_mul_546[0] = buffer_data_2[4367:4360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_546[1] = buffer_data_2[4375:4368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_546[2] = buffer_data_2[4383:4376] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_546[3] = buffer_data_1[4367:4360] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_546[4] = buffer_data_1[4375:4368] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_546[5] = buffer_data_1[4383:4376] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_546[6] = buffer_data_0[4367:4360] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_546[7] = buffer_data_0[4375:4368] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_546[8] = buffer_data_0[4383:4376] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_546 = kernel_img_mul_546[0] + kernel_img_mul_546[1] + kernel_img_mul_546[2] + 
                kernel_img_mul_546[3] + kernel_img_mul_546[4] + kernel_img_mul_546[5] + 
                kernel_img_mul_546[6] + kernel_img_mul_546[7] + kernel_img_mul_546[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4375:4368] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4375:4368] <= kernel_img_sum_546[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4375:4368] <= 'd0;
end

wire  [25:0]  kernel_img_mul_547[0:8];
assign kernel_img_mul_547[0] = buffer_data_2[4375:4368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_547[1] = buffer_data_2[4383:4376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_547[2] = buffer_data_2[4391:4384] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_547[3] = buffer_data_1[4375:4368] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_547[4] = buffer_data_1[4383:4376] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_547[5] = buffer_data_1[4391:4384] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_547[6] = buffer_data_0[4375:4368] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_547[7] = buffer_data_0[4383:4376] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_547[8] = buffer_data_0[4391:4384] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_547 = kernel_img_mul_547[0] + kernel_img_mul_547[1] + kernel_img_mul_547[2] + 
                kernel_img_mul_547[3] + kernel_img_mul_547[4] + kernel_img_mul_547[5] + 
                kernel_img_mul_547[6] + kernel_img_mul_547[7] + kernel_img_mul_547[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4383:4376] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4383:4376] <= kernel_img_sum_547[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4383:4376] <= 'd0;
end

wire  [25:0]  kernel_img_mul_548[0:8];
assign kernel_img_mul_548[0] = buffer_data_2[4383:4376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_548[1] = buffer_data_2[4391:4384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_548[2] = buffer_data_2[4399:4392] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_548[3] = buffer_data_1[4383:4376] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_548[4] = buffer_data_1[4391:4384] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_548[5] = buffer_data_1[4399:4392] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_548[6] = buffer_data_0[4383:4376] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_548[7] = buffer_data_0[4391:4384] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_548[8] = buffer_data_0[4399:4392] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_548 = kernel_img_mul_548[0] + kernel_img_mul_548[1] + kernel_img_mul_548[2] + 
                kernel_img_mul_548[3] + kernel_img_mul_548[4] + kernel_img_mul_548[5] + 
                kernel_img_mul_548[6] + kernel_img_mul_548[7] + kernel_img_mul_548[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4391:4384] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4391:4384] <= kernel_img_sum_548[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4391:4384] <= 'd0;
end

wire  [25:0]  kernel_img_mul_549[0:8];
assign kernel_img_mul_549[0] = buffer_data_2[4391:4384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_549[1] = buffer_data_2[4399:4392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_549[2] = buffer_data_2[4407:4400] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_549[3] = buffer_data_1[4391:4384] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_549[4] = buffer_data_1[4399:4392] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_549[5] = buffer_data_1[4407:4400] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_549[6] = buffer_data_0[4391:4384] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_549[7] = buffer_data_0[4399:4392] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_549[8] = buffer_data_0[4407:4400] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_549 = kernel_img_mul_549[0] + kernel_img_mul_549[1] + kernel_img_mul_549[2] + 
                kernel_img_mul_549[3] + kernel_img_mul_549[4] + kernel_img_mul_549[5] + 
                kernel_img_mul_549[6] + kernel_img_mul_549[7] + kernel_img_mul_549[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4399:4392] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4399:4392] <= kernel_img_sum_549[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4399:4392] <= 'd0;
end

wire  [25:0]  kernel_img_mul_550[0:8];
assign kernel_img_mul_550[0] = buffer_data_2[4399:4392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_550[1] = buffer_data_2[4407:4400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_550[2] = buffer_data_2[4415:4408] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_550[3] = buffer_data_1[4399:4392] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_550[4] = buffer_data_1[4407:4400] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_550[5] = buffer_data_1[4415:4408] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_550[6] = buffer_data_0[4399:4392] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_550[7] = buffer_data_0[4407:4400] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_550[8] = buffer_data_0[4415:4408] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_550 = kernel_img_mul_550[0] + kernel_img_mul_550[1] + kernel_img_mul_550[2] + 
                kernel_img_mul_550[3] + kernel_img_mul_550[4] + kernel_img_mul_550[5] + 
                kernel_img_mul_550[6] + kernel_img_mul_550[7] + kernel_img_mul_550[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4407:4400] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4407:4400] <= kernel_img_sum_550[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4407:4400] <= 'd0;
end

wire  [25:0]  kernel_img_mul_551[0:8];
assign kernel_img_mul_551[0] = buffer_data_2[4407:4400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_551[1] = buffer_data_2[4415:4408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_551[2] = buffer_data_2[4423:4416] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_551[3] = buffer_data_1[4407:4400] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_551[4] = buffer_data_1[4415:4408] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_551[5] = buffer_data_1[4423:4416] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_551[6] = buffer_data_0[4407:4400] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_551[7] = buffer_data_0[4415:4408] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_551[8] = buffer_data_0[4423:4416] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_551 = kernel_img_mul_551[0] + kernel_img_mul_551[1] + kernel_img_mul_551[2] + 
                kernel_img_mul_551[3] + kernel_img_mul_551[4] + kernel_img_mul_551[5] + 
                kernel_img_mul_551[6] + kernel_img_mul_551[7] + kernel_img_mul_551[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4415:4408] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4415:4408] <= kernel_img_sum_551[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4415:4408] <= 'd0;
end

wire  [25:0]  kernel_img_mul_552[0:8];
assign kernel_img_mul_552[0] = buffer_data_2[4415:4408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_552[1] = buffer_data_2[4423:4416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_552[2] = buffer_data_2[4431:4424] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_552[3] = buffer_data_1[4415:4408] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_552[4] = buffer_data_1[4423:4416] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_552[5] = buffer_data_1[4431:4424] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_552[6] = buffer_data_0[4415:4408] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_552[7] = buffer_data_0[4423:4416] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_552[8] = buffer_data_0[4431:4424] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_552 = kernel_img_mul_552[0] + kernel_img_mul_552[1] + kernel_img_mul_552[2] + 
                kernel_img_mul_552[3] + kernel_img_mul_552[4] + kernel_img_mul_552[5] + 
                kernel_img_mul_552[6] + kernel_img_mul_552[7] + kernel_img_mul_552[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4423:4416] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4423:4416] <= kernel_img_sum_552[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4423:4416] <= 'd0;
end

wire  [25:0]  kernel_img_mul_553[0:8];
assign kernel_img_mul_553[0] = buffer_data_2[4423:4416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_553[1] = buffer_data_2[4431:4424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_553[2] = buffer_data_2[4439:4432] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_553[3] = buffer_data_1[4423:4416] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_553[4] = buffer_data_1[4431:4424] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_553[5] = buffer_data_1[4439:4432] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_553[6] = buffer_data_0[4423:4416] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_553[7] = buffer_data_0[4431:4424] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_553[8] = buffer_data_0[4439:4432] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_553 = kernel_img_mul_553[0] + kernel_img_mul_553[1] + kernel_img_mul_553[2] + 
                kernel_img_mul_553[3] + kernel_img_mul_553[4] + kernel_img_mul_553[5] + 
                kernel_img_mul_553[6] + kernel_img_mul_553[7] + kernel_img_mul_553[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4431:4424] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4431:4424] <= kernel_img_sum_553[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4431:4424] <= 'd0;
end

wire  [25:0]  kernel_img_mul_554[0:8];
assign kernel_img_mul_554[0] = buffer_data_2[4431:4424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_554[1] = buffer_data_2[4439:4432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_554[2] = buffer_data_2[4447:4440] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_554[3] = buffer_data_1[4431:4424] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_554[4] = buffer_data_1[4439:4432] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_554[5] = buffer_data_1[4447:4440] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_554[6] = buffer_data_0[4431:4424] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_554[7] = buffer_data_0[4439:4432] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_554[8] = buffer_data_0[4447:4440] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_554 = kernel_img_mul_554[0] + kernel_img_mul_554[1] + kernel_img_mul_554[2] + 
                kernel_img_mul_554[3] + kernel_img_mul_554[4] + kernel_img_mul_554[5] + 
                kernel_img_mul_554[6] + kernel_img_mul_554[7] + kernel_img_mul_554[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4439:4432] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4439:4432] <= kernel_img_sum_554[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4439:4432] <= 'd0;
end

wire  [25:0]  kernel_img_mul_555[0:8];
assign kernel_img_mul_555[0] = buffer_data_2[4439:4432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_555[1] = buffer_data_2[4447:4440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_555[2] = buffer_data_2[4455:4448] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_555[3] = buffer_data_1[4439:4432] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_555[4] = buffer_data_1[4447:4440] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_555[5] = buffer_data_1[4455:4448] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_555[6] = buffer_data_0[4439:4432] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_555[7] = buffer_data_0[4447:4440] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_555[8] = buffer_data_0[4455:4448] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_555 = kernel_img_mul_555[0] + kernel_img_mul_555[1] + kernel_img_mul_555[2] + 
                kernel_img_mul_555[3] + kernel_img_mul_555[4] + kernel_img_mul_555[5] + 
                kernel_img_mul_555[6] + kernel_img_mul_555[7] + kernel_img_mul_555[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4447:4440] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4447:4440] <= kernel_img_sum_555[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4447:4440] <= 'd0;
end

wire  [25:0]  kernel_img_mul_556[0:8];
assign kernel_img_mul_556[0] = buffer_data_2[4447:4440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_556[1] = buffer_data_2[4455:4448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_556[2] = buffer_data_2[4463:4456] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_556[3] = buffer_data_1[4447:4440] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_556[4] = buffer_data_1[4455:4448] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_556[5] = buffer_data_1[4463:4456] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_556[6] = buffer_data_0[4447:4440] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_556[7] = buffer_data_0[4455:4448] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_556[8] = buffer_data_0[4463:4456] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_556 = kernel_img_mul_556[0] + kernel_img_mul_556[1] + kernel_img_mul_556[2] + 
                kernel_img_mul_556[3] + kernel_img_mul_556[4] + kernel_img_mul_556[5] + 
                kernel_img_mul_556[6] + kernel_img_mul_556[7] + kernel_img_mul_556[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4455:4448] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4455:4448] <= kernel_img_sum_556[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4455:4448] <= 'd0;
end

wire  [25:0]  kernel_img_mul_557[0:8];
assign kernel_img_mul_557[0] = buffer_data_2[4455:4448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_557[1] = buffer_data_2[4463:4456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_557[2] = buffer_data_2[4471:4464] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_557[3] = buffer_data_1[4455:4448] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_557[4] = buffer_data_1[4463:4456] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_557[5] = buffer_data_1[4471:4464] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_557[6] = buffer_data_0[4455:4448] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_557[7] = buffer_data_0[4463:4456] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_557[8] = buffer_data_0[4471:4464] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_557 = kernel_img_mul_557[0] + kernel_img_mul_557[1] + kernel_img_mul_557[2] + 
                kernel_img_mul_557[3] + kernel_img_mul_557[4] + kernel_img_mul_557[5] + 
                kernel_img_mul_557[6] + kernel_img_mul_557[7] + kernel_img_mul_557[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4463:4456] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4463:4456] <= kernel_img_sum_557[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4463:4456] <= 'd0;
end

wire  [25:0]  kernel_img_mul_558[0:8];
assign kernel_img_mul_558[0] = buffer_data_2[4463:4456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_558[1] = buffer_data_2[4471:4464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_558[2] = buffer_data_2[4479:4472] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_558[3] = buffer_data_1[4463:4456] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_558[4] = buffer_data_1[4471:4464] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_558[5] = buffer_data_1[4479:4472] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_558[6] = buffer_data_0[4463:4456] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_558[7] = buffer_data_0[4471:4464] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_558[8] = buffer_data_0[4479:4472] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_558 = kernel_img_mul_558[0] + kernel_img_mul_558[1] + kernel_img_mul_558[2] + 
                kernel_img_mul_558[3] + kernel_img_mul_558[4] + kernel_img_mul_558[5] + 
                kernel_img_mul_558[6] + kernel_img_mul_558[7] + kernel_img_mul_558[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4471:4464] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4471:4464] <= kernel_img_sum_558[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4471:4464] <= 'd0;
end

wire  [25:0]  kernel_img_mul_559[0:8];
assign kernel_img_mul_559[0] = buffer_data_2[4471:4464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_559[1] = buffer_data_2[4479:4472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_559[2] = buffer_data_2[4487:4480] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_559[3] = buffer_data_1[4471:4464] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_559[4] = buffer_data_1[4479:4472] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_559[5] = buffer_data_1[4487:4480] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_559[6] = buffer_data_0[4471:4464] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_559[7] = buffer_data_0[4479:4472] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_559[8] = buffer_data_0[4487:4480] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_559 = kernel_img_mul_559[0] + kernel_img_mul_559[1] + kernel_img_mul_559[2] + 
                kernel_img_mul_559[3] + kernel_img_mul_559[4] + kernel_img_mul_559[5] + 
                kernel_img_mul_559[6] + kernel_img_mul_559[7] + kernel_img_mul_559[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4479:4472] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4479:4472] <= kernel_img_sum_559[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4479:4472] <= 'd0;
end

wire  [25:0]  kernel_img_mul_560[0:8];
assign kernel_img_mul_560[0] = buffer_data_2[4479:4472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_560[1] = buffer_data_2[4487:4480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_560[2] = buffer_data_2[4495:4488] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_560[3] = buffer_data_1[4479:4472] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_560[4] = buffer_data_1[4487:4480] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_560[5] = buffer_data_1[4495:4488] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_560[6] = buffer_data_0[4479:4472] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_560[7] = buffer_data_0[4487:4480] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_560[8] = buffer_data_0[4495:4488] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_560 = kernel_img_mul_560[0] + kernel_img_mul_560[1] + kernel_img_mul_560[2] + 
                kernel_img_mul_560[3] + kernel_img_mul_560[4] + kernel_img_mul_560[5] + 
                kernel_img_mul_560[6] + kernel_img_mul_560[7] + kernel_img_mul_560[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4487:4480] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4487:4480] <= kernel_img_sum_560[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4487:4480] <= 'd0;
end

wire  [25:0]  kernel_img_mul_561[0:8];
assign kernel_img_mul_561[0] = buffer_data_2[4487:4480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_561[1] = buffer_data_2[4495:4488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_561[2] = buffer_data_2[4503:4496] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_561[3] = buffer_data_1[4487:4480] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_561[4] = buffer_data_1[4495:4488] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_561[5] = buffer_data_1[4503:4496] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_561[6] = buffer_data_0[4487:4480] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_561[7] = buffer_data_0[4495:4488] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_561[8] = buffer_data_0[4503:4496] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_561 = kernel_img_mul_561[0] + kernel_img_mul_561[1] + kernel_img_mul_561[2] + 
                kernel_img_mul_561[3] + kernel_img_mul_561[4] + kernel_img_mul_561[5] + 
                kernel_img_mul_561[6] + kernel_img_mul_561[7] + kernel_img_mul_561[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4495:4488] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4495:4488] <= kernel_img_sum_561[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4495:4488] <= 'd0;
end

wire  [25:0]  kernel_img_mul_562[0:8];
assign kernel_img_mul_562[0] = buffer_data_2[4495:4488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_562[1] = buffer_data_2[4503:4496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_562[2] = buffer_data_2[4511:4504] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_562[3] = buffer_data_1[4495:4488] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_562[4] = buffer_data_1[4503:4496] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_562[5] = buffer_data_1[4511:4504] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_562[6] = buffer_data_0[4495:4488] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_562[7] = buffer_data_0[4503:4496] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_562[8] = buffer_data_0[4511:4504] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_562 = kernel_img_mul_562[0] + kernel_img_mul_562[1] + kernel_img_mul_562[2] + 
                kernel_img_mul_562[3] + kernel_img_mul_562[4] + kernel_img_mul_562[5] + 
                kernel_img_mul_562[6] + kernel_img_mul_562[7] + kernel_img_mul_562[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4503:4496] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4503:4496] <= kernel_img_sum_562[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4503:4496] <= 'd0;
end

wire  [25:0]  kernel_img_mul_563[0:8];
assign kernel_img_mul_563[0] = buffer_data_2[4503:4496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_563[1] = buffer_data_2[4511:4504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_563[2] = buffer_data_2[4519:4512] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_563[3] = buffer_data_1[4503:4496] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_563[4] = buffer_data_1[4511:4504] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_563[5] = buffer_data_1[4519:4512] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_563[6] = buffer_data_0[4503:4496] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_563[7] = buffer_data_0[4511:4504] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_563[8] = buffer_data_0[4519:4512] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_563 = kernel_img_mul_563[0] + kernel_img_mul_563[1] + kernel_img_mul_563[2] + 
                kernel_img_mul_563[3] + kernel_img_mul_563[4] + kernel_img_mul_563[5] + 
                kernel_img_mul_563[6] + kernel_img_mul_563[7] + kernel_img_mul_563[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4511:4504] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4511:4504] <= kernel_img_sum_563[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4511:4504] <= 'd0;
end

wire  [25:0]  kernel_img_mul_564[0:8];
assign kernel_img_mul_564[0] = buffer_data_2[4511:4504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_564[1] = buffer_data_2[4519:4512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_564[2] = buffer_data_2[4527:4520] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_564[3] = buffer_data_1[4511:4504] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_564[4] = buffer_data_1[4519:4512] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_564[5] = buffer_data_1[4527:4520] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_564[6] = buffer_data_0[4511:4504] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_564[7] = buffer_data_0[4519:4512] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_564[8] = buffer_data_0[4527:4520] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_564 = kernel_img_mul_564[0] + kernel_img_mul_564[1] + kernel_img_mul_564[2] + 
                kernel_img_mul_564[3] + kernel_img_mul_564[4] + kernel_img_mul_564[5] + 
                kernel_img_mul_564[6] + kernel_img_mul_564[7] + kernel_img_mul_564[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4519:4512] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4519:4512] <= kernel_img_sum_564[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4519:4512] <= 'd0;
end

wire  [25:0]  kernel_img_mul_565[0:8];
assign kernel_img_mul_565[0] = buffer_data_2[4519:4512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_565[1] = buffer_data_2[4527:4520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_565[2] = buffer_data_2[4535:4528] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_565[3] = buffer_data_1[4519:4512] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_565[4] = buffer_data_1[4527:4520] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_565[5] = buffer_data_1[4535:4528] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_565[6] = buffer_data_0[4519:4512] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_565[7] = buffer_data_0[4527:4520] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_565[8] = buffer_data_0[4535:4528] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_565 = kernel_img_mul_565[0] + kernel_img_mul_565[1] + kernel_img_mul_565[2] + 
                kernel_img_mul_565[3] + kernel_img_mul_565[4] + kernel_img_mul_565[5] + 
                kernel_img_mul_565[6] + kernel_img_mul_565[7] + kernel_img_mul_565[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4527:4520] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4527:4520] <= kernel_img_sum_565[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4527:4520] <= 'd0;
end

wire  [25:0]  kernel_img_mul_566[0:8];
assign kernel_img_mul_566[0] = buffer_data_2[4527:4520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_566[1] = buffer_data_2[4535:4528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_566[2] = buffer_data_2[4543:4536] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_566[3] = buffer_data_1[4527:4520] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_566[4] = buffer_data_1[4535:4528] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_566[5] = buffer_data_1[4543:4536] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_566[6] = buffer_data_0[4527:4520] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_566[7] = buffer_data_0[4535:4528] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_566[8] = buffer_data_0[4543:4536] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_566 = kernel_img_mul_566[0] + kernel_img_mul_566[1] + kernel_img_mul_566[2] + 
                kernel_img_mul_566[3] + kernel_img_mul_566[4] + kernel_img_mul_566[5] + 
                kernel_img_mul_566[6] + kernel_img_mul_566[7] + kernel_img_mul_566[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4535:4528] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4535:4528] <= kernel_img_sum_566[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4535:4528] <= 'd0;
end

wire  [25:0]  kernel_img_mul_567[0:8];
assign kernel_img_mul_567[0] = buffer_data_2[4535:4528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_567[1] = buffer_data_2[4543:4536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_567[2] = buffer_data_2[4551:4544] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_567[3] = buffer_data_1[4535:4528] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_567[4] = buffer_data_1[4543:4536] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_567[5] = buffer_data_1[4551:4544] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_567[6] = buffer_data_0[4535:4528] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_567[7] = buffer_data_0[4543:4536] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_567[8] = buffer_data_0[4551:4544] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_567 = kernel_img_mul_567[0] + kernel_img_mul_567[1] + kernel_img_mul_567[2] + 
                kernel_img_mul_567[3] + kernel_img_mul_567[4] + kernel_img_mul_567[5] + 
                kernel_img_mul_567[6] + kernel_img_mul_567[7] + kernel_img_mul_567[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4543:4536] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4543:4536] <= kernel_img_sum_567[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4543:4536] <= 'd0;
end

wire  [25:0]  kernel_img_mul_568[0:8];
assign kernel_img_mul_568[0] = buffer_data_2[4543:4536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_568[1] = buffer_data_2[4551:4544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_568[2] = buffer_data_2[4559:4552] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_568[3] = buffer_data_1[4543:4536] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_568[4] = buffer_data_1[4551:4544] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_568[5] = buffer_data_1[4559:4552] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_568[6] = buffer_data_0[4543:4536] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_568[7] = buffer_data_0[4551:4544] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_568[8] = buffer_data_0[4559:4552] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_568 = kernel_img_mul_568[0] + kernel_img_mul_568[1] + kernel_img_mul_568[2] + 
                kernel_img_mul_568[3] + kernel_img_mul_568[4] + kernel_img_mul_568[5] + 
                kernel_img_mul_568[6] + kernel_img_mul_568[7] + kernel_img_mul_568[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4551:4544] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4551:4544] <= kernel_img_sum_568[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4551:4544] <= 'd0;
end

wire  [25:0]  kernel_img_mul_569[0:8];
assign kernel_img_mul_569[0] = buffer_data_2[4551:4544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_569[1] = buffer_data_2[4559:4552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_569[2] = buffer_data_2[4567:4560] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_569[3] = buffer_data_1[4551:4544] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_569[4] = buffer_data_1[4559:4552] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_569[5] = buffer_data_1[4567:4560] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_569[6] = buffer_data_0[4551:4544] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_569[7] = buffer_data_0[4559:4552] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_569[8] = buffer_data_0[4567:4560] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_569 = kernel_img_mul_569[0] + kernel_img_mul_569[1] + kernel_img_mul_569[2] + 
                kernel_img_mul_569[3] + kernel_img_mul_569[4] + kernel_img_mul_569[5] + 
                kernel_img_mul_569[6] + kernel_img_mul_569[7] + kernel_img_mul_569[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4559:4552] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4559:4552] <= kernel_img_sum_569[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4559:4552] <= 'd0;
end

wire  [25:0]  kernel_img_mul_570[0:8];
assign kernel_img_mul_570[0] = buffer_data_2[4559:4552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_570[1] = buffer_data_2[4567:4560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_570[2] = buffer_data_2[4575:4568] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_570[3] = buffer_data_1[4559:4552] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_570[4] = buffer_data_1[4567:4560] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_570[5] = buffer_data_1[4575:4568] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_570[6] = buffer_data_0[4559:4552] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_570[7] = buffer_data_0[4567:4560] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_570[8] = buffer_data_0[4575:4568] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_570 = kernel_img_mul_570[0] + kernel_img_mul_570[1] + kernel_img_mul_570[2] + 
                kernel_img_mul_570[3] + kernel_img_mul_570[4] + kernel_img_mul_570[5] + 
                kernel_img_mul_570[6] + kernel_img_mul_570[7] + kernel_img_mul_570[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4567:4560] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4567:4560] <= kernel_img_sum_570[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4567:4560] <= 'd0;
end

wire  [25:0]  kernel_img_mul_571[0:8];
assign kernel_img_mul_571[0] = buffer_data_2[4567:4560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_571[1] = buffer_data_2[4575:4568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_571[2] = buffer_data_2[4583:4576] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_571[3] = buffer_data_1[4567:4560] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_571[4] = buffer_data_1[4575:4568] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_571[5] = buffer_data_1[4583:4576] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_571[6] = buffer_data_0[4567:4560] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_571[7] = buffer_data_0[4575:4568] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_571[8] = buffer_data_0[4583:4576] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_571 = kernel_img_mul_571[0] + kernel_img_mul_571[1] + kernel_img_mul_571[2] + 
                kernel_img_mul_571[3] + kernel_img_mul_571[4] + kernel_img_mul_571[5] + 
                kernel_img_mul_571[6] + kernel_img_mul_571[7] + kernel_img_mul_571[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4575:4568] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4575:4568] <= kernel_img_sum_571[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4575:4568] <= 'd0;
end

wire  [25:0]  kernel_img_mul_572[0:8];
assign kernel_img_mul_572[0] = buffer_data_2[4575:4568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_572[1] = buffer_data_2[4583:4576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_572[2] = buffer_data_2[4591:4584] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_572[3] = buffer_data_1[4575:4568] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_572[4] = buffer_data_1[4583:4576] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_572[5] = buffer_data_1[4591:4584] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_572[6] = buffer_data_0[4575:4568] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_572[7] = buffer_data_0[4583:4576] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_572[8] = buffer_data_0[4591:4584] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_572 = kernel_img_mul_572[0] + kernel_img_mul_572[1] + kernel_img_mul_572[2] + 
                kernel_img_mul_572[3] + kernel_img_mul_572[4] + kernel_img_mul_572[5] + 
                kernel_img_mul_572[6] + kernel_img_mul_572[7] + kernel_img_mul_572[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4583:4576] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4583:4576] <= kernel_img_sum_572[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4583:4576] <= 'd0;
end

wire  [25:0]  kernel_img_mul_573[0:8];
assign kernel_img_mul_573[0] = buffer_data_2[4583:4576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_573[1] = buffer_data_2[4591:4584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_573[2] = buffer_data_2[4599:4592] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_573[3] = buffer_data_1[4583:4576] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_573[4] = buffer_data_1[4591:4584] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_573[5] = buffer_data_1[4599:4592] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_573[6] = buffer_data_0[4583:4576] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_573[7] = buffer_data_0[4591:4584] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_573[8] = buffer_data_0[4599:4592] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_573 = kernel_img_mul_573[0] + kernel_img_mul_573[1] + kernel_img_mul_573[2] + 
                kernel_img_mul_573[3] + kernel_img_mul_573[4] + kernel_img_mul_573[5] + 
                kernel_img_mul_573[6] + kernel_img_mul_573[7] + kernel_img_mul_573[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4591:4584] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4591:4584] <= kernel_img_sum_573[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4591:4584] <= 'd0;
end

wire  [25:0]  kernel_img_mul_574[0:8];
assign kernel_img_mul_574[0] = buffer_data_2[4591:4584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_574[1] = buffer_data_2[4599:4592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_574[2] = buffer_data_2[4607:4600] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_574[3] = buffer_data_1[4591:4584] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_574[4] = buffer_data_1[4599:4592] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_574[5] = buffer_data_1[4607:4600] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_574[6] = buffer_data_0[4591:4584] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_574[7] = buffer_data_0[4599:4592] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_574[8] = buffer_data_0[4607:4600] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_574 = kernel_img_mul_574[0] + kernel_img_mul_574[1] + kernel_img_mul_574[2] + 
                kernel_img_mul_574[3] + kernel_img_mul_574[4] + kernel_img_mul_574[5] + 
                kernel_img_mul_574[6] + kernel_img_mul_574[7] + kernel_img_mul_574[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4599:4592] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4599:4592] <= kernel_img_sum_574[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4599:4592] <= 'd0;
end

wire  [25:0]  kernel_img_mul_575[0:8];
assign kernel_img_mul_575[0] = buffer_data_2[4599:4592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_575[1] = buffer_data_2[4607:4600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_575[2] = buffer_data_2[4615:4608] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_575[3] = buffer_data_1[4599:4592] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_575[4] = buffer_data_1[4607:4600] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_575[5] = buffer_data_1[4615:4608] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_575[6] = buffer_data_0[4599:4592] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_575[7] = buffer_data_0[4607:4600] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_575[8] = buffer_data_0[4615:4608] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_575 = kernel_img_mul_575[0] + kernel_img_mul_575[1] + kernel_img_mul_575[2] + 
                kernel_img_mul_575[3] + kernel_img_mul_575[4] + kernel_img_mul_575[5] + 
                kernel_img_mul_575[6] + kernel_img_mul_575[7] + kernel_img_mul_575[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4607:4600] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4607:4600] <= kernel_img_sum_575[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4607:4600] <= 'd0;
end

wire  [25:0]  kernel_img_mul_576[0:8];
assign kernel_img_mul_576[0] = buffer_data_2[4607:4600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_576[1] = buffer_data_2[4615:4608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_576[2] = buffer_data_2[4623:4616] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_576[3] = buffer_data_1[4607:4600] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_576[4] = buffer_data_1[4615:4608] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_576[5] = buffer_data_1[4623:4616] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_576[6] = buffer_data_0[4607:4600] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_576[7] = buffer_data_0[4615:4608] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_576[8] = buffer_data_0[4623:4616] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_576 = kernel_img_mul_576[0] + kernel_img_mul_576[1] + kernel_img_mul_576[2] + 
                kernel_img_mul_576[3] + kernel_img_mul_576[4] + kernel_img_mul_576[5] + 
                kernel_img_mul_576[6] + kernel_img_mul_576[7] + kernel_img_mul_576[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4615:4608] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4615:4608] <= kernel_img_sum_576[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4615:4608] <= 'd0;
end

wire  [25:0]  kernel_img_mul_577[0:8];
assign kernel_img_mul_577[0] = buffer_data_2[4615:4608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_577[1] = buffer_data_2[4623:4616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_577[2] = buffer_data_2[4631:4624] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_577[3] = buffer_data_1[4615:4608] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_577[4] = buffer_data_1[4623:4616] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_577[5] = buffer_data_1[4631:4624] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_577[6] = buffer_data_0[4615:4608] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_577[7] = buffer_data_0[4623:4616] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_577[8] = buffer_data_0[4631:4624] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_577 = kernel_img_mul_577[0] + kernel_img_mul_577[1] + kernel_img_mul_577[2] + 
                kernel_img_mul_577[3] + kernel_img_mul_577[4] + kernel_img_mul_577[5] + 
                kernel_img_mul_577[6] + kernel_img_mul_577[7] + kernel_img_mul_577[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4623:4616] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4623:4616] <= kernel_img_sum_577[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4623:4616] <= 'd0;
end

wire  [25:0]  kernel_img_mul_578[0:8];
assign kernel_img_mul_578[0] = buffer_data_2[4623:4616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_578[1] = buffer_data_2[4631:4624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_578[2] = buffer_data_2[4639:4632] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_578[3] = buffer_data_1[4623:4616] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_578[4] = buffer_data_1[4631:4624] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_578[5] = buffer_data_1[4639:4632] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_578[6] = buffer_data_0[4623:4616] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_578[7] = buffer_data_0[4631:4624] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_578[8] = buffer_data_0[4639:4632] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_578 = kernel_img_mul_578[0] + kernel_img_mul_578[1] + kernel_img_mul_578[2] + 
                kernel_img_mul_578[3] + kernel_img_mul_578[4] + kernel_img_mul_578[5] + 
                kernel_img_mul_578[6] + kernel_img_mul_578[7] + kernel_img_mul_578[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4631:4624] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4631:4624] <= kernel_img_sum_578[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4631:4624] <= 'd0;
end

wire  [25:0]  kernel_img_mul_579[0:8];
assign kernel_img_mul_579[0] = buffer_data_2[4631:4624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_579[1] = buffer_data_2[4639:4632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_579[2] = buffer_data_2[4647:4640] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_579[3] = buffer_data_1[4631:4624] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_579[4] = buffer_data_1[4639:4632] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_579[5] = buffer_data_1[4647:4640] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_579[6] = buffer_data_0[4631:4624] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_579[7] = buffer_data_0[4639:4632] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_579[8] = buffer_data_0[4647:4640] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_579 = kernel_img_mul_579[0] + kernel_img_mul_579[1] + kernel_img_mul_579[2] + 
                kernel_img_mul_579[3] + kernel_img_mul_579[4] + kernel_img_mul_579[5] + 
                kernel_img_mul_579[6] + kernel_img_mul_579[7] + kernel_img_mul_579[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4639:4632] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4639:4632] <= kernel_img_sum_579[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4639:4632] <= 'd0;
end

wire  [25:0]  kernel_img_mul_580[0:8];
assign kernel_img_mul_580[0] = buffer_data_2[4639:4632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_580[1] = buffer_data_2[4647:4640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_580[2] = buffer_data_2[4655:4648] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_580[3] = buffer_data_1[4639:4632] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_580[4] = buffer_data_1[4647:4640] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_580[5] = buffer_data_1[4655:4648] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_580[6] = buffer_data_0[4639:4632] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_580[7] = buffer_data_0[4647:4640] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_580[8] = buffer_data_0[4655:4648] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_580 = kernel_img_mul_580[0] + kernel_img_mul_580[1] + kernel_img_mul_580[2] + 
                kernel_img_mul_580[3] + kernel_img_mul_580[4] + kernel_img_mul_580[5] + 
                kernel_img_mul_580[6] + kernel_img_mul_580[7] + kernel_img_mul_580[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4647:4640] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4647:4640] <= kernel_img_sum_580[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4647:4640] <= 'd0;
end

wire  [25:0]  kernel_img_mul_581[0:8];
assign kernel_img_mul_581[0] = buffer_data_2[4647:4640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_581[1] = buffer_data_2[4655:4648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_581[2] = buffer_data_2[4663:4656] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_581[3] = buffer_data_1[4647:4640] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_581[4] = buffer_data_1[4655:4648] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_581[5] = buffer_data_1[4663:4656] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_581[6] = buffer_data_0[4647:4640] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_581[7] = buffer_data_0[4655:4648] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_581[8] = buffer_data_0[4663:4656] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_581 = kernel_img_mul_581[0] + kernel_img_mul_581[1] + kernel_img_mul_581[2] + 
                kernel_img_mul_581[3] + kernel_img_mul_581[4] + kernel_img_mul_581[5] + 
                kernel_img_mul_581[6] + kernel_img_mul_581[7] + kernel_img_mul_581[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4655:4648] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4655:4648] <= kernel_img_sum_581[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4655:4648] <= 'd0;
end

wire  [25:0]  kernel_img_mul_582[0:8];
assign kernel_img_mul_582[0] = buffer_data_2[4655:4648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_582[1] = buffer_data_2[4663:4656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_582[2] = buffer_data_2[4671:4664] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_582[3] = buffer_data_1[4655:4648] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_582[4] = buffer_data_1[4663:4656] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_582[5] = buffer_data_1[4671:4664] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_582[6] = buffer_data_0[4655:4648] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_582[7] = buffer_data_0[4663:4656] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_582[8] = buffer_data_0[4671:4664] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_582 = kernel_img_mul_582[0] + kernel_img_mul_582[1] + kernel_img_mul_582[2] + 
                kernel_img_mul_582[3] + kernel_img_mul_582[4] + kernel_img_mul_582[5] + 
                kernel_img_mul_582[6] + kernel_img_mul_582[7] + kernel_img_mul_582[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4663:4656] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4663:4656] <= kernel_img_sum_582[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4663:4656] <= 'd0;
end

wire  [25:0]  kernel_img_mul_583[0:8];
assign kernel_img_mul_583[0] = buffer_data_2[4663:4656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_583[1] = buffer_data_2[4671:4664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_583[2] = buffer_data_2[4679:4672] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_583[3] = buffer_data_1[4663:4656] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_583[4] = buffer_data_1[4671:4664] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_583[5] = buffer_data_1[4679:4672] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_583[6] = buffer_data_0[4663:4656] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_583[7] = buffer_data_0[4671:4664] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_583[8] = buffer_data_0[4679:4672] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_583 = kernel_img_mul_583[0] + kernel_img_mul_583[1] + kernel_img_mul_583[2] + 
                kernel_img_mul_583[3] + kernel_img_mul_583[4] + kernel_img_mul_583[5] + 
                kernel_img_mul_583[6] + kernel_img_mul_583[7] + kernel_img_mul_583[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4671:4664] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4671:4664] <= kernel_img_sum_583[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4671:4664] <= 'd0;
end

wire  [25:0]  kernel_img_mul_584[0:8];
assign kernel_img_mul_584[0] = buffer_data_2[4671:4664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_584[1] = buffer_data_2[4679:4672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_584[2] = buffer_data_2[4687:4680] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_584[3] = buffer_data_1[4671:4664] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_584[4] = buffer_data_1[4679:4672] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_584[5] = buffer_data_1[4687:4680] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_584[6] = buffer_data_0[4671:4664] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_584[7] = buffer_data_0[4679:4672] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_584[8] = buffer_data_0[4687:4680] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_584 = kernel_img_mul_584[0] + kernel_img_mul_584[1] + kernel_img_mul_584[2] + 
                kernel_img_mul_584[3] + kernel_img_mul_584[4] + kernel_img_mul_584[5] + 
                kernel_img_mul_584[6] + kernel_img_mul_584[7] + kernel_img_mul_584[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4679:4672] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4679:4672] <= kernel_img_sum_584[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4679:4672] <= 'd0;
end

wire  [25:0]  kernel_img_mul_585[0:8];
assign kernel_img_mul_585[0] = buffer_data_2[4679:4672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_585[1] = buffer_data_2[4687:4680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_585[2] = buffer_data_2[4695:4688] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_585[3] = buffer_data_1[4679:4672] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_585[4] = buffer_data_1[4687:4680] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_585[5] = buffer_data_1[4695:4688] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_585[6] = buffer_data_0[4679:4672] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_585[7] = buffer_data_0[4687:4680] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_585[8] = buffer_data_0[4695:4688] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_585 = kernel_img_mul_585[0] + kernel_img_mul_585[1] + kernel_img_mul_585[2] + 
                kernel_img_mul_585[3] + kernel_img_mul_585[4] + kernel_img_mul_585[5] + 
                kernel_img_mul_585[6] + kernel_img_mul_585[7] + kernel_img_mul_585[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4687:4680] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4687:4680] <= kernel_img_sum_585[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4687:4680] <= 'd0;
end

wire  [25:0]  kernel_img_mul_586[0:8];
assign kernel_img_mul_586[0] = buffer_data_2[4687:4680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_586[1] = buffer_data_2[4695:4688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_586[2] = buffer_data_2[4703:4696] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_586[3] = buffer_data_1[4687:4680] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_586[4] = buffer_data_1[4695:4688] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_586[5] = buffer_data_1[4703:4696] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_586[6] = buffer_data_0[4687:4680] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_586[7] = buffer_data_0[4695:4688] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_586[8] = buffer_data_0[4703:4696] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_586 = kernel_img_mul_586[0] + kernel_img_mul_586[1] + kernel_img_mul_586[2] + 
                kernel_img_mul_586[3] + kernel_img_mul_586[4] + kernel_img_mul_586[5] + 
                kernel_img_mul_586[6] + kernel_img_mul_586[7] + kernel_img_mul_586[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4695:4688] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4695:4688] <= kernel_img_sum_586[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4695:4688] <= 'd0;
end

wire  [25:0]  kernel_img_mul_587[0:8];
assign kernel_img_mul_587[0] = buffer_data_2[4695:4688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_587[1] = buffer_data_2[4703:4696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_587[2] = buffer_data_2[4711:4704] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_587[3] = buffer_data_1[4695:4688] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_587[4] = buffer_data_1[4703:4696] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_587[5] = buffer_data_1[4711:4704] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_587[6] = buffer_data_0[4695:4688] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_587[7] = buffer_data_0[4703:4696] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_587[8] = buffer_data_0[4711:4704] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_587 = kernel_img_mul_587[0] + kernel_img_mul_587[1] + kernel_img_mul_587[2] + 
                kernel_img_mul_587[3] + kernel_img_mul_587[4] + kernel_img_mul_587[5] + 
                kernel_img_mul_587[6] + kernel_img_mul_587[7] + kernel_img_mul_587[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4703:4696] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4703:4696] <= kernel_img_sum_587[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4703:4696] <= 'd0;
end

wire  [25:0]  kernel_img_mul_588[0:8];
assign kernel_img_mul_588[0] = buffer_data_2[4703:4696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_588[1] = buffer_data_2[4711:4704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_588[2] = buffer_data_2[4719:4712] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_588[3] = buffer_data_1[4703:4696] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_588[4] = buffer_data_1[4711:4704] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_588[5] = buffer_data_1[4719:4712] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_588[6] = buffer_data_0[4703:4696] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_588[7] = buffer_data_0[4711:4704] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_588[8] = buffer_data_0[4719:4712] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_588 = kernel_img_mul_588[0] + kernel_img_mul_588[1] + kernel_img_mul_588[2] + 
                kernel_img_mul_588[3] + kernel_img_mul_588[4] + kernel_img_mul_588[5] + 
                kernel_img_mul_588[6] + kernel_img_mul_588[7] + kernel_img_mul_588[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4711:4704] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4711:4704] <= kernel_img_sum_588[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4711:4704] <= 'd0;
end

wire  [25:0]  kernel_img_mul_589[0:8];
assign kernel_img_mul_589[0] = buffer_data_2[4711:4704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_589[1] = buffer_data_2[4719:4712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_589[2] = buffer_data_2[4727:4720] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_589[3] = buffer_data_1[4711:4704] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_589[4] = buffer_data_1[4719:4712] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_589[5] = buffer_data_1[4727:4720] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_589[6] = buffer_data_0[4711:4704] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_589[7] = buffer_data_0[4719:4712] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_589[8] = buffer_data_0[4727:4720] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_589 = kernel_img_mul_589[0] + kernel_img_mul_589[1] + kernel_img_mul_589[2] + 
                kernel_img_mul_589[3] + kernel_img_mul_589[4] + kernel_img_mul_589[5] + 
                kernel_img_mul_589[6] + kernel_img_mul_589[7] + kernel_img_mul_589[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4719:4712] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4719:4712] <= kernel_img_sum_589[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4719:4712] <= 'd0;
end

wire  [25:0]  kernel_img_mul_590[0:8];
assign kernel_img_mul_590[0] = buffer_data_2[4719:4712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_590[1] = buffer_data_2[4727:4720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_590[2] = buffer_data_2[4735:4728] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_590[3] = buffer_data_1[4719:4712] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_590[4] = buffer_data_1[4727:4720] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_590[5] = buffer_data_1[4735:4728] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_590[6] = buffer_data_0[4719:4712] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_590[7] = buffer_data_0[4727:4720] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_590[8] = buffer_data_0[4735:4728] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_590 = kernel_img_mul_590[0] + kernel_img_mul_590[1] + kernel_img_mul_590[2] + 
                kernel_img_mul_590[3] + kernel_img_mul_590[4] + kernel_img_mul_590[5] + 
                kernel_img_mul_590[6] + kernel_img_mul_590[7] + kernel_img_mul_590[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4727:4720] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4727:4720] <= kernel_img_sum_590[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4727:4720] <= 'd0;
end

wire  [25:0]  kernel_img_mul_591[0:8];
assign kernel_img_mul_591[0] = buffer_data_2[4727:4720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_591[1] = buffer_data_2[4735:4728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_591[2] = buffer_data_2[4743:4736] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_591[3] = buffer_data_1[4727:4720] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_591[4] = buffer_data_1[4735:4728] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_591[5] = buffer_data_1[4743:4736] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_591[6] = buffer_data_0[4727:4720] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_591[7] = buffer_data_0[4735:4728] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_591[8] = buffer_data_0[4743:4736] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_591 = kernel_img_mul_591[0] + kernel_img_mul_591[1] + kernel_img_mul_591[2] + 
                kernel_img_mul_591[3] + kernel_img_mul_591[4] + kernel_img_mul_591[5] + 
                kernel_img_mul_591[6] + kernel_img_mul_591[7] + kernel_img_mul_591[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4735:4728] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4735:4728] <= kernel_img_sum_591[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4735:4728] <= 'd0;
end

wire  [25:0]  kernel_img_mul_592[0:8];
assign kernel_img_mul_592[0] = buffer_data_2[4735:4728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_592[1] = buffer_data_2[4743:4736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_592[2] = buffer_data_2[4751:4744] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_592[3] = buffer_data_1[4735:4728] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_592[4] = buffer_data_1[4743:4736] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_592[5] = buffer_data_1[4751:4744] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_592[6] = buffer_data_0[4735:4728] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_592[7] = buffer_data_0[4743:4736] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_592[8] = buffer_data_0[4751:4744] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_592 = kernel_img_mul_592[0] + kernel_img_mul_592[1] + kernel_img_mul_592[2] + 
                kernel_img_mul_592[3] + kernel_img_mul_592[4] + kernel_img_mul_592[5] + 
                kernel_img_mul_592[6] + kernel_img_mul_592[7] + kernel_img_mul_592[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4743:4736] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4743:4736] <= kernel_img_sum_592[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4743:4736] <= 'd0;
end

wire  [25:0]  kernel_img_mul_593[0:8];
assign kernel_img_mul_593[0] = buffer_data_2[4743:4736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_593[1] = buffer_data_2[4751:4744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_593[2] = buffer_data_2[4759:4752] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_593[3] = buffer_data_1[4743:4736] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_593[4] = buffer_data_1[4751:4744] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_593[5] = buffer_data_1[4759:4752] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_593[6] = buffer_data_0[4743:4736] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_593[7] = buffer_data_0[4751:4744] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_593[8] = buffer_data_0[4759:4752] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_593 = kernel_img_mul_593[0] + kernel_img_mul_593[1] + kernel_img_mul_593[2] + 
                kernel_img_mul_593[3] + kernel_img_mul_593[4] + kernel_img_mul_593[5] + 
                kernel_img_mul_593[6] + kernel_img_mul_593[7] + kernel_img_mul_593[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4751:4744] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4751:4744] <= kernel_img_sum_593[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4751:4744] <= 'd0;
end

wire  [25:0]  kernel_img_mul_594[0:8];
assign kernel_img_mul_594[0] = buffer_data_2[4751:4744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_594[1] = buffer_data_2[4759:4752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_594[2] = buffer_data_2[4767:4760] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_594[3] = buffer_data_1[4751:4744] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_594[4] = buffer_data_1[4759:4752] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_594[5] = buffer_data_1[4767:4760] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_594[6] = buffer_data_0[4751:4744] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_594[7] = buffer_data_0[4759:4752] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_594[8] = buffer_data_0[4767:4760] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_594 = kernel_img_mul_594[0] + kernel_img_mul_594[1] + kernel_img_mul_594[2] + 
                kernel_img_mul_594[3] + kernel_img_mul_594[4] + kernel_img_mul_594[5] + 
                kernel_img_mul_594[6] + kernel_img_mul_594[7] + kernel_img_mul_594[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4759:4752] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4759:4752] <= kernel_img_sum_594[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4759:4752] <= 'd0;
end

wire  [25:0]  kernel_img_mul_595[0:8];
assign kernel_img_mul_595[0] = buffer_data_2[4759:4752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_595[1] = buffer_data_2[4767:4760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_595[2] = buffer_data_2[4775:4768] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_595[3] = buffer_data_1[4759:4752] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_595[4] = buffer_data_1[4767:4760] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_595[5] = buffer_data_1[4775:4768] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_595[6] = buffer_data_0[4759:4752] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_595[7] = buffer_data_0[4767:4760] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_595[8] = buffer_data_0[4775:4768] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_595 = kernel_img_mul_595[0] + kernel_img_mul_595[1] + kernel_img_mul_595[2] + 
                kernel_img_mul_595[3] + kernel_img_mul_595[4] + kernel_img_mul_595[5] + 
                kernel_img_mul_595[6] + kernel_img_mul_595[7] + kernel_img_mul_595[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4767:4760] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4767:4760] <= kernel_img_sum_595[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4767:4760] <= 'd0;
end

wire  [25:0]  kernel_img_mul_596[0:8];
assign kernel_img_mul_596[0] = buffer_data_2[4767:4760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_596[1] = buffer_data_2[4775:4768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_596[2] = buffer_data_2[4783:4776] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_596[3] = buffer_data_1[4767:4760] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_596[4] = buffer_data_1[4775:4768] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_596[5] = buffer_data_1[4783:4776] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_596[6] = buffer_data_0[4767:4760] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_596[7] = buffer_data_0[4775:4768] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_596[8] = buffer_data_0[4783:4776] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_596 = kernel_img_mul_596[0] + kernel_img_mul_596[1] + kernel_img_mul_596[2] + 
                kernel_img_mul_596[3] + kernel_img_mul_596[4] + kernel_img_mul_596[5] + 
                kernel_img_mul_596[6] + kernel_img_mul_596[7] + kernel_img_mul_596[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4775:4768] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4775:4768] <= kernel_img_sum_596[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4775:4768] <= 'd0;
end

wire  [25:0]  kernel_img_mul_597[0:8];
assign kernel_img_mul_597[0] = buffer_data_2[4775:4768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_597[1] = buffer_data_2[4783:4776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_597[2] = buffer_data_2[4791:4784] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_597[3] = buffer_data_1[4775:4768] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_597[4] = buffer_data_1[4783:4776] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_597[5] = buffer_data_1[4791:4784] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_597[6] = buffer_data_0[4775:4768] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_597[7] = buffer_data_0[4783:4776] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_597[8] = buffer_data_0[4791:4784] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_597 = kernel_img_mul_597[0] + kernel_img_mul_597[1] + kernel_img_mul_597[2] + 
                kernel_img_mul_597[3] + kernel_img_mul_597[4] + kernel_img_mul_597[5] + 
                kernel_img_mul_597[6] + kernel_img_mul_597[7] + kernel_img_mul_597[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4783:4776] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4783:4776] <= kernel_img_sum_597[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4783:4776] <= 'd0;
end

wire  [25:0]  kernel_img_mul_598[0:8];
assign kernel_img_mul_598[0] = buffer_data_2[4783:4776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_598[1] = buffer_data_2[4791:4784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_598[2] = buffer_data_2[4799:4792] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_598[3] = buffer_data_1[4783:4776] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_598[4] = buffer_data_1[4791:4784] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_598[5] = buffer_data_1[4799:4792] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_598[6] = buffer_data_0[4783:4776] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_598[7] = buffer_data_0[4791:4784] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_598[8] = buffer_data_0[4799:4792] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_598 = kernel_img_mul_598[0] + kernel_img_mul_598[1] + kernel_img_mul_598[2] + 
                kernel_img_mul_598[3] + kernel_img_mul_598[4] + kernel_img_mul_598[5] + 
                kernel_img_mul_598[6] + kernel_img_mul_598[7] + kernel_img_mul_598[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4791:4784] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4791:4784] <= kernel_img_sum_598[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4791:4784] <= 'd0;
end

wire  [25:0]  kernel_img_mul_599[0:8];
assign kernel_img_mul_599[0] = buffer_data_2[4791:4784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_599[1] = buffer_data_2[4799:4792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_599[2] = buffer_data_2[4807:4800] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_599[3] = buffer_data_1[4791:4784] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_599[4] = buffer_data_1[4799:4792] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_599[5] = buffer_data_1[4807:4800] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_599[6] = buffer_data_0[4791:4784] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_599[7] = buffer_data_0[4799:4792] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_599[8] = buffer_data_0[4807:4800] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_599 = kernel_img_mul_599[0] + kernel_img_mul_599[1] + kernel_img_mul_599[2] + 
                kernel_img_mul_599[3] + kernel_img_mul_599[4] + kernel_img_mul_599[5] + 
                kernel_img_mul_599[6] + kernel_img_mul_599[7] + kernel_img_mul_599[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4799:4792] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4799:4792] <= kernel_img_sum_599[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4799:4792] <= 'd0;
end

wire  [25:0]  kernel_img_mul_600[0:8];
assign kernel_img_mul_600[0] = buffer_data_2[4799:4792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_600[1] = buffer_data_2[4807:4800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_600[2] = buffer_data_2[4815:4808] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_600[3] = buffer_data_1[4799:4792] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_600[4] = buffer_data_1[4807:4800] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_600[5] = buffer_data_1[4815:4808] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_600[6] = buffer_data_0[4799:4792] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_600[7] = buffer_data_0[4807:4800] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_600[8] = buffer_data_0[4815:4808] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_600 = kernel_img_mul_600[0] + kernel_img_mul_600[1] + kernel_img_mul_600[2] + 
                kernel_img_mul_600[3] + kernel_img_mul_600[4] + kernel_img_mul_600[5] + 
                kernel_img_mul_600[6] + kernel_img_mul_600[7] + kernel_img_mul_600[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4807:4800] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4807:4800] <= kernel_img_sum_600[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4807:4800] <= 'd0;
end

wire  [25:0]  kernel_img_mul_601[0:8];
assign kernel_img_mul_601[0] = buffer_data_2[4807:4800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_601[1] = buffer_data_2[4815:4808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_601[2] = buffer_data_2[4823:4816] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_601[3] = buffer_data_1[4807:4800] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_601[4] = buffer_data_1[4815:4808] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_601[5] = buffer_data_1[4823:4816] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_601[6] = buffer_data_0[4807:4800] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_601[7] = buffer_data_0[4815:4808] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_601[8] = buffer_data_0[4823:4816] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_601 = kernel_img_mul_601[0] + kernel_img_mul_601[1] + kernel_img_mul_601[2] + 
                kernel_img_mul_601[3] + kernel_img_mul_601[4] + kernel_img_mul_601[5] + 
                kernel_img_mul_601[6] + kernel_img_mul_601[7] + kernel_img_mul_601[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4815:4808] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4815:4808] <= kernel_img_sum_601[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4815:4808] <= 'd0;
end

wire  [25:0]  kernel_img_mul_602[0:8];
assign kernel_img_mul_602[0] = buffer_data_2[4815:4808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_602[1] = buffer_data_2[4823:4816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_602[2] = buffer_data_2[4831:4824] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_602[3] = buffer_data_1[4815:4808] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_602[4] = buffer_data_1[4823:4816] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_602[5] = buffer_data_1[4831:4824] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_602[6] = buffer_data_0[4815:4808] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_602[7] = buffer_data_0[4823:4816] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_602[8] = buffer_data_0[4831:4824] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_602 = kernel_img_mul_602[0] + kernel_img_mul_602[1] + kernel_img_mul_602[2] + 
                kernel_img_mul_602[3] + kernel_img_mul_602[4] + kernel_img_mul_602[5] + 
                kernel_img_mul_602[6] + kernel_img_mul_602[7] + kernel_img_mul_602[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4823:4816] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4823:4816] <= kernel_img_sum_602[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4823:4816] <= 'd0;
end

wire  [25:0]  kernel_img_mul_603[0:8];
assign kernel_img_mul_603[0] = buffer_data_2[4823:4816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_603[1] = buffer_data_2[4831:4824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_603[2] = buffer_data_2[4839:4832] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_603[3] = buffer_data_1[4823:4816] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_603[4] = buffer_data_1[4831:4824] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_603[5] = buffer_data_1[4839:4832] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_603[6] = buffer_data_0[4823:4816] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_603[7] = buffer_data_0[4831:4824] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_603[8] = buffer_data_0[4839:4832] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_603 = kernel_img_mul_603[0] + kernel_img_mul_603[1] + kernel_img_mul_603[2] + 
                kernel_img_mul_603[3] + kernel_img_mul_603[4] + kernel_img_mul_603[5] + 
                kernel_img_mul_603[6] + kernel_img_mul_603[7] + kernel_img_mul_603[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4831:4824] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4831:4824] <= kernel_img_sum_603[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4831:4824] <= 'd0;
end

wire  [25:0]  kernel_img_mul_604[0:8];
assign kernel_img_mul_604[0] = buffer_data_2[4831:4824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_604[1] = buffer_data_2[4839:4832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_604[2] = buffer_data_2[4847:4840] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_604[3] = buffer_data_1[4831:4824] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_604[4] = buffer_data_1[4839:4832] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_604[5] = buffer_data_1[4847:4840] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_604[6] = buffer_data_0[4831:4824] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_604[7] = buffer_data_0[4839:4832] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_604[8] = buffer_data_0[4847:4840] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_604 = kernel_img_mul_604[0] + kernel_img_mul_604[1] + kernel_img_mul_604[2] + 
                kernel_img_mul_604[3] + kernel_img_mul_604[4] + kernel_img_mul_604[5] + 
                kernel_img_mul_604[6] + kernel_img_mul_604[7] + kernel_img_mul_604[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4839:4832] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4839:4832] <= kernel_img_sum_604[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4839:4832] <= 'd0;
end

wire  [25:0]  kernel_img_mul_605[0:8];
assign kernel_img_mul_605[0] = buffer_data_2[4839:4832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_605[1] = buffer_data_2[4847:4840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_605[2] = buffer_data_2[4855:4848] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_605[3] = buffer_data_1[4839:4832] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_605[4] = buffer_data_1[4847:4840] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_605[5] = buffer_data_1[4855:4848] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_605[6] = buffer_data_0[4839:4832] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_605[7] = buffer_data_0[4847:4840] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_605[8] = buffer_data_0[4855:4848] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_605 = kernel_img_mul_605[0] + kernel_img_mul_605[1] + kernel_img_mul_605[2] + 
                kernel_img_mul_605[3] + kernel_img_mul_605[4] + kernel_img_mul_605[5] + 
                kernel_img_mul_605[6] + kernel_img_mul_605[7] + kernel_img_mul_605[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4847:4840] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4847:4840] <= kernel_img_sum_605[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4847:4840] <= 'd0;
end

wire  [25:0]  kernel_img_mul_606[0:8];
assign kernel_img_mul_606[0] = buffer_data_2[4847:4840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_606[1] = buffer_data_2[4855:4848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_606[2] = buffer_data_2[4863:4856] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_606[3] = buffer_data_1[4847:4840] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_606[4] = buffer_data_1[4855:4848] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_606[5] = buffer_data_1[4863:4856] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_606[6] = buffer_data_0[4847:4840] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_606[7] = buffer_data_0[4855:4848] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_606[8] = buffer_data_0[4863:4856] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_606 = kernel_img_mul_606[0] + kernel_img_mul_606[1] + kernel_img_mul_606[2] + 
                kernel_img_mul_606[3] + kernel_img_mul_606[4] + kernel_img_mul_606[5] + 
                kernel_img_mul_606[6] + kernel_img_mul_606[7] + kernel_img_mul_606[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4855:4848] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4855:4848] <= kernel_img_sum_606[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4855:4848] <= 'd0;
end

wire  [25:0]  kernel_img_mul_607[0:8];
assign kernel_img_mul_607[0] = buffer_data_2[4855:4848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_607[1] = buffer_data_2[4863:4856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_607[2] = buffer_data_2[4871:4864] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_607[3] = buffer_data_1[4855:4848] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_607[4] = buffer_data_1[4863:4856] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_607[5] = buffer_data_1[4871:4864] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_607[6] = buffer_data_0[4855:4848] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_607[7] = buffer_data_0[4863:4856] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_607[8] = buffer_data_0[4871:4864] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_607 = kernel_img_mul_607[0] + kernel_img_mul_607[1] + kernel_img_mul_607[2] + 
                kernel_img_mul_607[3] + kernel_img_mul_607[4] + kernel_img_mul_607[5] + 
                kernel_img_mul_607[6] + kernel_img_mul_607[7] + kernel_img_mul_607[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4863:4856] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4863:4856] <= kernel_img_sum_607[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4863:4856] <= 'd0;
end

wire  [25:0]  kernel_img_mul_608[0:8];
assign kernel_img_mul_608[0] = buffer_data_2[4863:4856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_608[1] = buffer_data_2[4871:4864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_608[2] = buffer_data_2[4879:4872] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_608[3] = buffer_data_1[4863:4856] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_608[4] = buffer_data_1[4871:4864] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_608[5] = buffer_data_1[4879:4872] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_608[6] = buffer_data_0[4863:4856] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_608[7] = buffer_data_0[4871:4864] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_608[8] = buffer_data_0[4879:4872] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_608 = kernel_img_mul_608[0] + kernel_img_mul_608[1] + kernel_img_mul_608[2] + 
                kernel_img_mul_608[3] + kernel_img_mul_608[4] + kernel_img_mul_608[5] + 
                kernel_img_mul_608[6] + kernel_img_mul_608[7] + kernel_img_mul_608[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4871:4864] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4871:4864] <= kernel_img_sum_608[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4871:4864] <= 'd0;
end

wire  [25:0]  kernel_img_mul_609[0:8];
assign kernel_img_mul_609[0] = buffer_data_2[4871:4864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_609[1] = buffer_data_2[4879:4872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_609[2] = buffer_data_2[4887:4880] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_609[3] = buffer_data_1[4871:4864] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_609[4] = buffer_data_1[4879:4872] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_609[5] = buffer_data_1[4887:4880] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_609[6] = buffer_data_0[4871:4864] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_609[7] = buffer_data_0[4879:4872] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_609[8] = buffer_data_0[4887:4880] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_609 = kernel_img_mul_609[0] + kernel_img_mul_609[1] + kernel_img_mul_609[2] + 
                kernel_img_mul_609[3] + kernel_img_mul_609[4] + kernel_img_mul_609[5] + 
                kernel_img_mul_609[6] + kernel_img_mul_609[7] + kernel_img_mul_609[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4879:4872] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4879:4872] <= kernel_img_sum_609[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4879:4872] <= 'd0;
end

wire  [25:0]  kernel_img_mul_610[0:8];
assign kernel_img_mul_610[0] = buffer_data_2[4879:4872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_610[1] = buffer_data_2[4887:4880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_610[2] = buffer_data_2[4895:4888] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_610[3] = buffer_data_1[4879:4872] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_610[4] = buffer_data_1[4887:4880] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_610[5] = buffer_data_1[4895:4888] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_610[6] = buffer_data_0[4879:4872] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_610[7] = buffer_data_0[4887:4880] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_610[8] = buffer_data_0[4895:4888] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_610 = kernel_img_mul_610[0] + kernel_img_mul_610[1] + kernel_img_mul_610[2] + 
                kernel_img_mul_610[3] + kernel_img_mul_610[4] + kernel_img_mul_610[5] + 
                kernel_img_mul_610[6] + kernel_img_mul_610[7] + kernel_img_mul_610[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4887:4880] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4887:4880] <= kernel_img_sum_610[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4887:4880] <= 'd0;
end

wire  [25:0]  kernel_img_mul_611[0:8];
assign kernel_img_mul_611[0] = buffer_data_2[4887:4880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_611[1] = buffer_data_2[4895:4888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_611[2] = buffer_data_2[4903:4896] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_611[3] = buffer_data_1[4887:4880] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_611[4] = buffer_data_1[4895:4888] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_611[5] = buffer_data_1[4903:4896] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_611[6] = buffer_data_0[4887:4880] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_611[7] = buffer_data_0[4895:4888] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_611[8] = buffer_data_0[4903:4896] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_611 = kernel_img_mul_611[0] + kernel_img_mul_611[1] + kernel_img_mul_611[2] + 
                kernel_img_mul_611[3] + kernel_img_mul_611[4] + kernel_img_mul_611[5] + 
                kernel_img_mul_611[6] + kernel_img_mul_611[7] + kernel_img_mul_611[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4895:4888] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4895:4888] <= kernel_img_sum_611[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4895:4888] <= 'd0;
end

wire  [25:0]  kernel_img_mul_612[0:8];
assign kernel_img_mul_612[0] = buffer_data_2[4895:4888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_612[1] = buffer_data_2[4903:4896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_612[2] = buffer_data_2[4911:4904] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_612[3] = buffer_data_1[4895:4888] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_612[4] = buffer_data_1[4903:4896] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_612[5] = buffer_data_1[4911:4904] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_612[6] = buffer_data_0[4895:4888] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_612[7] = buffer_data_0[4903:4896] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_612[8] = buffer_data_0[4911:4904] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_612 = kernel_img_mul_612[0] + kernel_img_mul_612[1] + kernel_img_mul_612[2] + 
                kernel_img_mul_612[3] + kernel_img_mul_612[4] + kernel_img_mul_612[5] + 
                kernel_img_mul_612[6] + kernel_img_mul_612[7] + kernel_img_mul_612[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4903:4896] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4903:4896] <= kernel_img_sum_612[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4903:4896] <= 'd0;
end

wire  [25:0]  kernel_img_mul_613[0:8];
assign kernel_img_mul_613[0] = buffer_data_2[4903:4896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_613[1] = buffer_data_2[4911:4904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_613[2] = buffer_data_2[4919:4912] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_613[3] = buffer_data_1[4903:4896] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_613[4] = buffer_data_1[4911:4904] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_613[5] = buffer_data_1[4919:4912] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_613[6] = buffer_data_0[4903:4896] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_613[7] = buffer_data_0[4911:4904] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_613[8] = buffer_data_0[4919:4912] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_613 = kernel_img_mul_613[0] + kernel_img_mul_613[1] + kernel_img_mul_613[2] + 
                kernel_img_mul_613[3] + kernel_img_mul_613[4] + kernel_img_mul_613[5] + 
                kernel_img_mul_613[6] + kernel_img_mul_613[7] + kernel_img_mul_613[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4911:4904] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4911:4904] <= kernel_img_sum_613[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4911:4904] <= 'd0;
end

wire  [25:0]  kernel_img_mul_614[0:8];
assign kernel_img_mul_614[0] = buffer_data_2[4911:4904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_614[1] = buffer_data_2[4919:4912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_614[2] = buffer_data_2[4927:4920] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_614[3] = buffer_data_1[4911:4904] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_614[4] = buffer_data_1[4919:4912] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_614[5] = buffer_data_1[4927:4920] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_614[6] = buffer_data_0[4911:4904] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_614[7] = buffer_data_0[4919:4912] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_614[8] = buffer_data_0[4927:4920] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_614 = kernel_img_mul_614[0] + kernel_img_mul_614[1] + kernel_img_mul_614[2] + 
                kernel_img_mul_614[3] + kernel_img_mul_614[4] + kernel_img_mul_614[5] + 
                kernel_img_mul_614[6] + kernel_img_mul_614[7] + kernel_img_mul_614[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4919:4912] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4919:4912] <= kernel_img_sum_614[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4919:4912] <= 'd0;
end

wire  [25:0]  kernel_img_mul_615[0:8];
assign kernel_img_mul_615[0] = buffer_data_2[4919:4912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_615[1] = buffer_data_2[4927:4920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_615[2] = buffer_data_2[4935:4928] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_615[3] = buffer_data_1[4919:4912] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_615[4] = buffer_data_1[4927:4920] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_615[5] = buffer_data_1[4935:4928] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_615[6] = buffer_data_0[4919:4912] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_615[7] = buffer_data_0[4927:4920] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_615[8] = buffer_data_0[4935:4928] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_615 = kernel_img_mul_615[0] + kernel_img_mul_615[1] + kernel_img_mul_615[2] + 
                kernel_img_mul_615[3] + kernel_img_mul_615[4] + kernel_img_mul_615[5] + 
                kernel_img_mul_615[6] + kernel_img_mul_615[7] + kernel_img_mul_615[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4927:4920] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4927:4920] <= kernel_img_sum_615[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4927:4920] <= 'd0;
end

wire  [25:0]  kernel_img_mul_616[0:8];
assign kernel_img_mul_616[0] = buffer_data_2[4927:4920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_616[1] = buffer_data_2[4935:4928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_616[2] = buffer_data_2[4943:4936] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_616[3] = buffer_data_1[4927:4920] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_616[4] = buffer_data_1[4935:4928] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_616[5] = buffer_data_1[4943:4936] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_616[6] = buffer_data_0[4927:4920] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_616[7] = buffer_data_0[4935:4928] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_616[8] = buffer_data_0[4943:4936] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_616 = kernel_img_mul_616[0] + kernel_img_mul_616[1] + kernel_img_mul_616[2] + 
                kernel_img_mul_616[3] + kernel_img_mul_616[4] + kernel_img_mul_616[5] + 
                kernel_img_mul_616[6] + kernel_img_mul_616[7] + kernel_img_mul_616[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4935:4928] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4935:4928] <= kernel_img_sum_616[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4935:4928] <= 'd0;
end

wire  [25:0]  kernel_img_mul_617[0:8];
assign kernel_img_mul_617[0] = buffer_data_2[4935:4928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_617[1] = buffer_data_2[4943:4936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_617[2] = buffer_data_2[4951:4944] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_617[3] = buffer_data_1[4935:4928] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_617[4] = buffer_data_1[4943:4936] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_617[5] = buffer_data_1[4951:4944] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_617[6] = buffer_data_0[4935:4928] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_617[7] = buffer_data_0[4943:4936] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_617[8] = buffer_data_0[4951:4944] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_617 = kernel_img_mul_617[0] + kernel_img_mul_617[1] + kernel_img_mul_617[2] + 
                kernel_img_mul_617[3] + kernel_img_mul_617[4] + kernel_img_mul_617[5] + 
                kernel_img_mul_617[6] + kernel_img_mul_617[7] + kernel_img_mul_617[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4943:4936] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4943:4936] <= kernel_img_sum_617[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4943:4936] <= 'd0;
end

wire  [25:0]  kernel_img_mul_618[0:8];
assign kernel_img_mul_618[0] = buffer_data_2[4943:4936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_618[1] = buffer_data_2[4951:4944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_618[2] = buffer_data_2[4959:4952] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_618[3] = buffer_data_1[4943:4936] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_618[4] = buffer_data_1[4951:4944] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_618[5] = buffer_data_1[4959:4952] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_618[6] = buffer_data_0[4943:4936] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_618[7] = buffer_data_0[4951:4944] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_618[8] = buffer_data_0[4959:4952] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_618 = kernel_img_mul_618[0] + kernel_img_mul_618[1] + kernel_img_mul_618[2] + 
                kernel_img_mul_618[3] + kernel_img_mul_618[4] + kernel_img_mul_618[5] + 
                kernel_img_mul_618[6] + kernel_img_mul_618[7] + kernel_img_mul_618[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4951:4944] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4951:4944] <= kernel_img_sum_618[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4951:4944] <= 'd0;
end

wire  [25:0]  kernel_img_mul_619[0:8];
assign kernel_img_mul_619[0] = buffer_data_2[4951:4944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_619[1] = buffer_data_2[4959:4952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_619[2] = buffer_data_2[4967:4960] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_619[3] = buffer_data_1[4951:4944] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_619[4] = buffer_data_1[4959:4952] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_619[5] = buffer_data_1[4967:4960] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_619[6] = buffer_data_0[4951:4944] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_619[7] = buffer_data_0[4959:4952] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_619[8] = buffer_data_0[4967:4960] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_619 = kernel_img_mul_619[0] + kernel_img_mul_619[1] + kernel_img_mul_619[2] + 
                kernel_img_mul_619[3] + kernel_img_mul_619[4] + kernel_img_mul_619[5] + 
                kernel_img_mul_619[6] + kernel_img_mul_619[7] + kernel_img_mul_619[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4959:4952] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4959:4952] <= kernel_img_sum_619[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4959:4952] <= 'd0;
end

wire  [25:0]  kernel_img_mul_620[0:8];
assign kernel_img_mul_620[0] = buffer_data_2[4959:4952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_620[1] = buffer_data_2[4967:4960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_620[2] = buffer_data_2[4975:4968] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_620[3] = buffer_data_1[4959:4952] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_620[4] = buffer_data_1[4967:4960] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_620[5] = buffer_data_1[4975:4968] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_620[6] = buffer_data_0[4959:4952] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_620[7] = buffer_data_0[4967:4960] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_620[8] = buffer_data_0[4975:4968] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_620 = kernel_img_mul_620[0] + kernel_img_mul_620[1] + kernel_img_mul_620[2] + 
                kernel_img_mul_620[3] + kernel_img_mul_620[4] + kernel_img_mul_620[5] + 
                kernel_img_mul_620[6] + kernel_img_mul_620[7] + kernel_img_mul_620[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4967:4960] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4967:4960] <= kernel_img_sum_620[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4967:4960] <= 'd0;
end

wire  [25:0]  kernel_img_mul_621[0:8];
assign kernel_img_mul_621[0] = buffer_data_2[4967:4960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_621[1] = buffer_data_2[4975:4968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_621[2] = buffer_data_2[4983:4976] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_621[3] = buffer_data_1[4967:4960] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_621[4] = buffer_data_1[4975:4968] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_621[5] = buffer_data_1[4983:4976] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_621[6] = buffer_data_0[4967:4960] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_621[7] = buffer_data_0[4975:4968] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_621[8] = buffer_data_0[4983:4976] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_621 = kernel_img_mul_621[0] + kernel_img_mul_621[1] + kernel_img_mul_621[2] + 
                kernel_img_mul_621[3] + kernel_img_mul_621[4] + kernel_img_mul_621[5] + 
                kernel_img_mul_621[6] + kernel_img_mul_621[7] + kernel_img_mul_621[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4975:4968] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4975:4968] <= kernel_img_sum_621[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4975:4968] <= 'd0;
end

wire  [25:0]  kernel_img_mul_622[0:8];
assign kernel_img_mul_622[0] = buffer_data_2[4975:4968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_622[1] = buffer_data_2[4983:4976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_622[2] = buffer_data_2[4991:4984] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_622[3] = buffer_data_1[4975:4968] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_622[4] = buffer_data_1[4983:4976] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_622[5] = buffer_data_1[4991:4984] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_622[6] = buffer_data_0[4975:4968] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_622[7] = buffer_data_0[4983:4976] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_622[8] = buffer_data_0[4991:4984] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_622 = kernel_img_mul_622[0] + kernel_img_mul_622[1] + kernel_img_mul_622[2] + 
                kernel_img_mul_622[3] + kernel_img_mul_622[4] + kernel_img_mul_622[5] + 
                kernel_img_mul_622[6] + kernel_img_mul_622[7] + kernel_img_mul_622[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4983:4976] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4983:4976] <= kernel_img_sum_622[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4983:4976] <= 'd0;
end

wire  [25:0]  kernel_img_mul_623[0:8];
assign kernel_img_mul_623[0] = buffer_data_2[4983:4976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_623[1] = buffer_data_2[4991:4984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_623[2] = buffer_data_2[4999:4992] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_623[3] = buffer_data_1[4983:4976] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_623[4] = buffer_data_1[4991:4984] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_623[5] = buffer_data_1[4999:4992] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_623[6] = buffer_data_0[4983:4976] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_623[7] = buffer_data_0[4991:4984] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_623[8] = buffer_data_0[4999:4992] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_623 = kernel_img_mul_623[0] + kernel_img_mul_623[1] + kernel_img_mul_623[2] + 
                kernel_img_mul_623[3] + kernel_img_mul_623[4] + kernel_img_mul_623[5] + 
                kernel_img_mul_623[6] + kernel_img_mul_623[7] + kernel_img_mul_623[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4991:4984] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4991:4984] <= kernel_img_sum_623[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4991:4984] <= 'd0;
end

wire  [25:0]  kernel_img_mul_624[0:8];
assign kernel_img_mul_624[0] = buffer_data_2[4991:4984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_624[1] = buffer_data_2[4999:4992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_624[2] = buffer_data_2[5007:5000] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_624[3] = buffer_data_1[4991:4984] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_624[4] = buffer_data_1[4999:4992] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_624[5] = buffer_data_1[5007:5000] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_624[6] = buffer_data_0[4991:4984] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_624[7] = buffer_data_0[4999:4992] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_624[8] = buffer_data_0[5007:5000] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_624 = kernel_img_mul_624[0] + kernel_img_mul_624[1] + kernel_img_mul_624[2] + 
                kernel_img_mul_624[3] + kernel_img_mul_624[4] + kernel_img_mul_624[5] + 
                kernel_img_mul_624[6] + kernel_img_mul_624[7] + kernel_img_mul_624[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[4999:4992] <= 'd0;
  else if (current_state==ST_START)
    blur_din[4999:4992] <= kernel_img_sum_624[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4999:4992] <= 'd0;
end

wire  [25:0]  kernel_img_mul_625[0:8];
assign kernel_img_mul_625[0] = buffer_data_2[4999:4992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_625[1] = buffer_data_2[5007:5000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_625[2] = buffer_data_2[5015:5008] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_625[3] = buffer_data_1[4999:4992] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_625[4] = buffer_data_1[5007:5000] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_625[5] = buffer_data_1[5015:5008] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_625[6] = buffer_data_0[4999:4992] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_625[7] = buffer_data_0[5007:5000] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_625[8] = buffer_data_0[5015:5008] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_625 = kernel_img_mul_625[0] + kernel_img_mul_625[1] + kernel_img_mul_625[2] + 
                kernel_img_mul_625[3] + kernel_img_mul_625[4] + kernel_img_mul_625[5] + 
                kernel_img_mul_625[6] + kernel_img_mul_625[7] + kernel_img_mul_625[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5007:5000] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5007:5000] <= kernel_img_sum_625[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5007:5000] <= 'd0;
end

wire  [25:0]  kernel_img_mul_626[0:8];
assign kernel_img_mul_626[0] = buffer_data_2[5007:5000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_626[1] = buffer_data_2[5015:5008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_626[2] = buffer_data_2[5023:5016] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_626[3] = buffer_data_1[5007:5000] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_626[4] = buffer_data_1[5015:5008] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_626[5] = buffer_data_1[5023:5016] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_626[6] = buffer_data_0[5007:5000] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_626[7] = buffer_data_0[5015:5008] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_626[8] = buffer_data_0[5023:5016] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_626 = kernel_img_mul_626[0] + kernel_img_mul_626[1] + kernel_img_mul_626[2] + 
                kernel_img_mul_626[3] + kernel_img_mul_626[4] + kernel_img_mul_626[5] + 
                kernel_img_mul_626[6] + kernel_img_mul_626[7] + kernel_img_mul_626[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5015:5008] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5015:5008] <= kernel_img_sum_626[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5015:5008] <= 'd0;
end

wire  [25:0]  kernel_img_mul_627[0:8];
assign kernel_img_mul_627[0] = buffer_data_2[5015:5008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_627[1] = buffer_data_2[5023:5016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_627[2] = buffer_data_2[5031:5024] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_627[3] = buffer_data_1[5015:5008] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_627[4] = buffer_data_1[5023:5016] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_627[5] = buffer_data_1[5031:5024] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_627[6] = buffer_data_0[5015:5008] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_627[7] = buffer_data_0[5023:5016] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_627[8] = buffer_data_0[5031:5024] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_627 = kernel_img_mul_627[0] + kernel_img_mul_627[1] + kernel_img_mul_627[2] + 
                kernel_img_mul_627[3] + kernel_img_mul_627[4] + kernel_img_mul_627[5] + 
                kernel_img_mul_627[6] + kernel_img_mul_627[7] + kernel_img_mul_627[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5023:5016] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5023:5016] <= kernel_img_sum_627[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5023:5016] <= 'd0;
end

wire  [25:0]  kernel_img_mul_628[0:8];
assign kernel_img_mul_628[0] = buffer_data_2[5023:5016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_628[1] = buffer_data_2[5031:5024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_628[2] = buffer_data_2[5039:5032] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_628[3] = buffer_data_1[5023:5016] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_628[4] = buffer_data_1[5031:5024] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_628[5] = buffer_data_1[5039:5032] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_628[6] = buffer_data_0[5023:5016] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_628[7] = buffer_data_0[5031:5024] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_628[8] = buffer_data_0[5039:5032] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_628 = kernel_img_mul_628[0] + kernel_img_mul_628[1] + kernel_img_mul_628[2] + 
                kernel_img_mul_628[3] + kernel_img_mul_628[4] + kernel_img_mul_628[5] + 
                kernel_img_mul_628[6] + kernel_img_mul_628[7] + kernel_img_mul_628[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5031:5024] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5031:5024] <= kernel_img_sum_628[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5031:5024] <= 'd0;
end

wire  [25:0]  kernel_img_mul_629[0:8];
assign kernel_img_mul_629[0] = buffer_data_2[5031:5024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_629[1] = buffer_data_2[5039:5032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_629[2] = buffer_data_2[5047:5040] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_629[3] = buffer_data_1[5031:5024] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_629[4] = buffer_data_1[5039:5032] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_629[5] = buffer_data_1[5047:5040] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_629[6] = buffer_data_0[5031:5024] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_629[7] = buffer_data_0[5039:5032] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_629[8] = buffer_data_0[5047:5040] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_629 = kernel_img_mul_629[0] + kernel_img_mul_629[1] + kernel_img_mul_629[2] + 
                kernel_img_mul_629[3] + kernel_img_mul_629[4] + kernel_img_mul_629[5] + 
                kernel_img_mul_629[6] + kernel_img_mul_629[7] + kernel_img_mul_629[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5039:5032] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5039:5032] <= kernel_img_sum_629[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5039:5032] <= 'd0;
end

wire  [25:0]  kernel_img_mul_630[0:8];
assign kernel_img_mul_630[0] = buffer_data_2[5039:5032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_630[1] = buffer_data_2[5047:5040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_630[2] = buffer_data_2[5055:5048] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_630[3] = buffer_data_1[5039:5032] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_630[4] = buffer_data_1[5047:5040] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_630[5] = buffer_data_1[5055:5048] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_630[6] = buffer_data_0[5039:5032] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_630[7] = buffer_data_0[5047:5040] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_630[8] = buffer_data_0[5055:5048] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_630 = kernel_img_mul_630[0] + kernel_img_mul_630[1] + kernel_img_mul_630[2] + 
                kernel_img_mul_630[3] + kernel_img_mul_630[4] + kernel_img_mul_630[5] + 
                kernel_img_mul_630[6] + kernel_img_mul_630[7] + kernel_img_mul_630[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5047:5040] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5047:5040] <= kernel_img_sum_630[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5047:5040] <= 'd0;
end

wire  [25:0]  kernel_img_mul_631[0:8];
assign kernel_img_mul_631[0] = buffer_data_2[5047:5040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_631[1] = buffer_data_2[5055:5048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_631[2] = buffer_data_2[5063:5056] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_631[3] = buffer_data_1[5047:5040] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_631[4] = buffer_data_1[5055:5048] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_631[5] = buffer_data_1[5063:5056] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_631[6] = buffer_data_0[5047:5040] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_631[7] = buffer_data_0[5055:5048] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_631[8] = buffer_data_0[5063:5056] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_631 = kernel_img_mul_631[0] + kernel_img_mul_631[1] + kernel_img_mul_631[2] + 
                kernel_img_mul_631[3] + kernel_img_mul_631[4] + kernel_img_mul_631[5] + 
                kernel_img_mul_631[6] + kernel_img_mul_631[7] + kernel_img_mul_631[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5055:5048] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5055:5048] <= kernel_img_sum_631[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5055:5048] <= 'd0;
end

wire  [25:0]  kernel_img_mul_632[0:8];
assign kernel_img_mul_632[0] = buffer_data_2[5055:5048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_632[1] = buffer_data_2[5063:5056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_632[2] = buffer_data_2[5071:5064] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_632[3] = buffer_data_1[5055:5048] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_632[4] = buffer_data_1[5063:5056] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_632[5] = buffer_data_1[5071:5064] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_632[6] = buffer_data_0[5055:5048] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_632[7] = buffer_data_0[5063:5056] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_632[8] = buffer_data_0[5071:5064] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_632 = kernel_img_mul_632[0] + kernel_img_mul_632[1] + kernel_img_mul_632[2] + 
                kernel_img_mul_632[3] + kernel_img_mul_632[4] + kernel_img_mul_632[5] + 
                kernel_img_mul_632[6] + kernel_img_mul_632[7] + kernel_img_mul_632[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5063:5056] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5063:5056] <= kernel_img_sum_632[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5063:5056] <= 'd0;
end

wire  [25:0]  kernel_img_mul_633[0:8];
assign kernel_img_mul_633[0] = buffer_data_2[5063:5056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_633[1] = buffer_data_2[5071:5064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_633[2] = buffer_data_2[5079:5072] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_633[3] = buffer_data_1[5063:5056] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_633[4] = buffer_data_1[5071:5064] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_633[5] = buffer_data_1[5079:5072] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_633[6] = buffer_data_0[5063:5056] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_633[7] = buffer_data_0[5071:5064] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_633[8] = buffer_data_0[5079:5072] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_633 = kernel_img_mul_633[0] + kernel_img_mul_633[1] + kernel_img_mul_633[2] + 
                kernel_img_mul_633[3] + kernel_img_mul_633[4] + kernel_img_mul_633[5] + 
                kernel_img_mul_633[6] + kernel_img_mul_633[7] + kernel_img_mul_633[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5071:5064] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5071:5064] <= kernel_img_sum_633[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5071:5064] <= 'd0;
end

wire  [25:0]  kernel_img_mul_634[0:8];
assign kernel_img_mul_634[0] = buffer_data_2[5071:5064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_634[1] = buffer_data_2[5079:5072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_634[2] = buffer_data_2[5087:5080] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_634[3] = buffer_data_1[5071:5064] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_634[4] = buffer_data_1[5079:5072] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_634[5] = buffer_data_1[5087:5080] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_634[6] = buffer_data_0[5071:5064] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_634[7] = buffer_data_0[5079:5072] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_634[8] = buffer_data_0[5087:5080] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_634 = kernel_img_mul_634[0] + kernel_img_mul_634[1] + kernel_img_mul_634[2] + 
                kernel_img_mul_634[3] + kernel_img_mul_634[4] + kernel_img_mul_634[5] + 
                kernel_img_mul_634[6] + kernel_img_mul_634[7] + kernel_img_mul_634[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5079:5072] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5079:5072] <= kernel_img_sum_634[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5079:5072] <= 'd0;
end

wire  [25:0]  kernel_img_mul_635[0:8];
assign kernel_img_mul_635[0] = buffer_data_2[5079:5072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_635[1] = buffer_data_2[5087:5080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_635[2] = buffer_data_2[5095:5088] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_635[3] = buffer_data_1[5079:5072] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_635[4] = buffer_data_1[5087:5080] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_635[5] = buffer_data_1[5095:5088] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_635[6] = buffer_data_0[5079:5072] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_635[7] = buffer_data_0[5087:5080] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_635[8] = buffer_data_0[5095:5088] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_635 = kernel_img_mul_635[0] + kernel_img_mul_635[1] + kernel_img_mul_635[2] + 
                kernel_img_mul_635[3] + kernel_img_mul_635[4] + kernel_img_mul_635[5] + 
                kernel_img_mul_635[6] + kernel_img_mul_635[7] + kernel_img_mul_635[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5087:5080] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5087:5080] <= kernel_img_sum_635[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5087:5080] <= 'd0;
end

wire  [25:0]  kernel_img_mul_636[0:8];
assign kernel_img_mul_636[0] = buffer_data_2[5087:5080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_636[1] = buffer_data_2[5095:5088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_636[2] = buffer_data_2[5103:5096] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_636[3] = buffer_data_1[5087:5080] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_636[4] = buffer_data_1[5095:5088] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_636[5] = buffer_data_1[5103:5096] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_636[6] = buffer_data_0[5087:5080] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_636[7] = buffer_data_0[5095:5088] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_636[8] = buffer_data_0[5103:5096] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_636 = kernel_img_mul_636[0] + kernel_img_mul_636[1] + kernel_img_mul_636[2] + 
                kernel_img_mul_636[3] + kernel_img_mul_636[4] + kernel_img_mul_636[5] + 
                kernel_img_mul_636[6] + kernel_img_mul_636[7] + kernel_img_mul_636[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5095:5088] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5095:5088] <= kernel_img_sum_636[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5095:5088] <= 'd0;
end

wire  [25:0]  kernel_img_mul_637[0:8];
assign kernel_img_mul_637[0] = buffer_data_2[5095:5088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_637[1] = buffer_data_2[5103:5096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_637[2] = buffer_data_2[5111:5104] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_637[3] = buffer_data_1[5095:5088] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_637[4] = buffer_data_1[5103:5096] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_637[5] = buffer_data_1[5111:5104] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_637[6] = buffer_data_0[5095:5088] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_637[7] = buffer_data_0[5103:5096] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_637[8] = buffer_data_0[5111:5104] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_637 = kernel_img_mul_637[0] + kernel_img_mul_637[1] + kernel_img_mul_637[2] + 
                kernel_img_mul_637[3] + kernel_img_mul_637[4] + kernel_img_mul_637[5] + 
                kernel_img_mul_637[6] + kernel_img_mul_637[7] + kernel_img_mul_637[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5103:5096] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5103:5096] <= kernel_img_sum_637[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5103:5096] <= 'd0;
end

wire  [25:0]  kernel_img_mul_638[0:8];
assign kernel_img_mul_638[0] = buffer_data_2[5103:5096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_638[1] = buffer_data_2[5111:5104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_638[2] = buffer_data_2[5119:5112] * G_Kernel_3x3[0][53:36];
assign kernel_img_mul_638[3] = buffer_data_1[5103:5096] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_638[4] = buffer_data_1[5111:5104] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_638[5] = buffer_data_1[5119:5112] * G_Kernel_3x3[1][53:36];
assign kernel_img_mul_638[6] = buffer_data_0[5103:5096] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_638[7] = buffer_data_0[5111:5104] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_638[8] = buffer_data_0[5119:5112] * G_Kernel_3x3[0][53:36];
wire  [29:0]  kernel_img_sum_638 = kernel_img_mul_638[0] + kernel_img_mul_638[1] + kernel_img_mul_638[2] + 
                kernel_img_mul_638[3] + kernel_img_mul_638[4] + kernel_img_mul_638[5] + 
                kernel_img_mul_638[6] + kernel_img_mul_638[7] + kernel_img_mul_638[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5111:5104] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5111:5104] <= kernel_img_sum_638[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5111:5104] <= 'd0;
end

wire  [25:0]  kernel_img_mul_639[0:8];
assign kernel_img_mul_639[0] = buffer_data_2[5111:5104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_639[1] = buffer_data_2[5119:5112] * G_Kernel_3x3[0][35:18];
assign kernel_img_mul_639[3] = buffer_data_1[5111:5104] * G_Kernel_3x3[1][17:0];
assign kernel_img_mul_639[4] = buffer_data_1[5119:5112] * G_Kernel_3x3[1][35:18];
assign kernel_img_mul_639[6] = buffer_data_0[5111:5104] * G_Kernel_3x3[0][17:0];
assign kernel_img_mul_639[7] = buffer_data_0[5119:5112] * G_Kernel_3x3[0][35:18];
wire  [29:0]  kernel_img_sum_639 = kernel_img_mul_639[0] + kernel_img_mul_639[1] + kernel_img_mul_639[3] + 
                kernel_img_mul_639[4] + kernel_img_mul_639[6] + kernel_img_mul_639[7] + 
                'd0;
always @(posedge clk) begin
  if (!rst_n)
    blur_din[5119:5112] <= 'd0;
  else if (current_state==ST_START)
    blur_din[5119:5112] <= kernel_img_sum_639[25:18];/*Q12.18 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5119:5112] <= 'd0;
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
        next_state = ST_START;
      else 
        next_state = ST_READY;
    end
    ST_START: begin
      if(done)//CHANGE LATER
        next_state = ST_IDLE;
      else
        next_state = ST_START;
    end
    default:
      next_state = ST_IDLE;
  endcase
end



endmodule 