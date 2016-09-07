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

/*Kernel Value*/
/*
0.092717418604014015
0.11906051350198525
0.092717418604014015
0.11906051350198525
0.15288827157600263
0.11906051350198525
*/

/*always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_3x3[0][31:0]  <=  31'h17BC5428; //18'b00_0101_1110_1111_0001;//'d092717;         
    G_Kernel_3x3[0][63:32] <=  31'h1E7ABFF3; //18'b00_0111_1001_1110_1010;//'d119061;         
    G_Kernel_3x3[0][95:64] <=  31'h17BC5428; //18'b00_0101_1110_1111_0001;//'d092717;         
    G_Kernel_3x3[1][31:0]  <=  31'h1E7ABFF3; //18'b00_0111_1001_1110_1010;//'d119061;         
    G_Kernel_3x3[1][63:32] <=  31'h2723AF8E; //18'b00_1001_1100_1000_1110;//'d152888;         
    G_Kernel_3x3[1][95:64] <=  31'h1E7ABFF3; //18'b00_0111_1001_1110_1011;//'d119061;         
  end
end*/


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

/*
always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_5x5_0[0][31:0]  <= 32'h05F2F79A;  // 18'b000001011111001011;//'d023238;         
    G_Kernel_5x5_0[0][63:32] <= 32'h08A86809;  // 18'b000010001010100001;//d033819;         
    G_Kernel_5x5_0[0][95:64] <= 32'h09CFB50A;  // 18'b000010011100111110;//d038325;        
    G_Kernel_5x5_0[0][127:96] <= 32'h08A86809;  // 18'b000010001010100001;//d033819;         
    G_Kernel_5x5_0[0][159:128] <= 32'h05F2F79A;  // 18'b000001011111001011;//'d023238;  
    G_Kernel_5x5_0[1][31:0]  <= 32'h08A86809;  // 18'b000010001010100001;//d033819;         
    G_Kernel_5x5_0[1][63:32] <= 32'h0C999546;  // 18'b000011001001100110;//d049218;         
    G_Kernel_5x5_0[1][95:64] <= 32'h0E475732;  // 18'b000011100100011101;//d055776;        
    G_Kernel_5x5_0[1][127:96] <= 32'h0C999546;  // 18'b000011001001100110;//d049218;         
    G_Kernel_5x5_0[1][159:128] <= 32'h08A86809;  // 18'b000010001010100001;//d033819;   
    G_Kernel_5x5_0[2][31:0]  <= 32'h09CFB50A;  // 18'b000010011100111110;//d038325;         
    G_Kernel_5x5_0[2][63:32] <= 32'h0E475732;  // 18'b000011100100011101;//d055776;         
    G_Kernel_5x5_0[2][95:64] <= 32'h102E5B3F;  // 18'b000100000010111001;//d063207;        
    G_Kernel_5x5_0[2][127:96] <= 32'h0E475732;  // 18'b000011100100011101;//d055776;         
    G_Kernel_5x5_0[2][159:128] <= 32'h09CFB50A;  // 18'b000010011100111110;//d038325;          
  end
end*/

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

/*always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_5x5_1[0][31:0]  <= 32'h07E31AF6; //18'b000001111110001100;//'d030809;         
    G_Kernel_5x5_1[0][63:32] <= 32'h0983EB80; //18'b000010011000001111;//'d037169;         
    G_Kernel_5x5_1[0][95:64] <= 32'h0A212B91; //18'b000010100010000100;//'d039568;        
    G_Kernel_5x5_1[0][127:96] <= 32'h0983EB80; //18'b000010011000001111;//'d037169;         
    G_Kernel_5x5_1[0][159:128] <= 32'h07E31AF6; //18'b000001111110001100;//'d030809;  
    G_Kernel_5x5_1[1][31:0]  <= 32'h0983EB80; //18'b000010011000001111;//'d037169;         
    G_Kernel_5x5_1[1][63:32] <= 32'h0B7AC7A0; //18'b000010110111101011;//'d044842;         
    G_Kernel_5x5_1[1][95:64] <= 32'h0C387DF7; //18'b000011000011100001;//'d047737;        
    G_Kernel_5x5_1[1][127:96] <= 32'h0B7AC7A0; //18'b000010110111101011;//'d044842;         
    G_Kernel_5x5_1[1][159:128] <= 32'h0983EB80; //18'b000010011000001111;//'d037169;   
    G_Kernel_5x5_1[2][31:0]  <= 32'h0A212B91; //18'b000010100010000100;//'d039568;         
    G_Kernel_5x5_1[2][63:32] <= 32'h0C387DF7; //18'b000011000011100001;//'d047737;         
    G_Kernel_5x5_1[2][95:64] <= 32'h0D02737E; //18'b000011010000001001;//'d050818;        
    G_Kernel_5x5_1[2][127:96] <= 32'h0C387DF7; //18'b000011000011100001;//'d047737;         
    G_Kernel_5x5_1[2][159:128] <= 32'h0A212B91; //18'b000010100010000100;//'d039568;          
  end
end*/

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

/*always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_7x7[0][31:0]    <= 32'h03C6EBCB; //18'b000000111100011011;//'d014754;         
    G_Kernel_7x7[0][63:32]   <= 32'h046AA8A8; //18'b000001000110101010;//'d017252;         
    G_Kernel_7x7[0][95:64]   <= 32'h04D9ED31; //18'b000001001101100111;//'d018950;        
    G_Kernel_7x7[0][127:96]   <= 32'h050165DE; //18'b000001010000000101;//'d019552;         
    G_Kernel_7x7[0][159:128]   <= 32'h04D9ED31; //18'b000001001101100111;//'d018950;       
    G_Kernel_7x7[0][191:160]  <= 32'h046AA8A8; //18'b000001000110101010;//'d017252;         
    G_Kernel_7x7[0][223:192] <= 32'h03C6EBCB; //18'b000000111100011011;//'d014754;  
    G_Kernel_7x7[1][31:0]    <= 32'h046AA8A8; //18'b000001000110101010;//'d017252;         
    G_Kernel_7x7[1][63:32]   <= 32'h052A1FB1; //18'b000001010010101000;//'d020174;         
    G_Kernel_7x7[1][95:64]   <= 32'h05AC3BC7; //18'b000001011010110000;//'d022159;        
    G_Kernel_7x7[1][127:96]   <= 32'h05DA6392; //18'b000001011101101001;//'d022863;         
    G_Kernel_7x7[1][159:128]   <= 32'h05AC3BC7; //18'b000001011010110000;//'d022159;       
    G_Kernel_7x7[1][191:160]  <= 32'h052A1FB1; //18'b000001010010101000;//'d020174;         
    G_Kernel_7x7[1][223:192] <= 32'h046AA8A8; //18'b000001000110101010;//'d017252;  
    G_Kernel_7x7[2][31:0]    <= 32'h04D9ED31; //18'b000001001101100111;//'d018950;         
    G_Kernel_7x7[2][63:32]   <= 32'h05AC3BC7; //18'b000001011010110000;//'d022159;         
    G_Kernel_7x7[2][95:64]   <= 32'h063B25B2; //18'b000001100011101100;//'d024340;        
    G_Kernel_7x7[2][127:96]   <= 32'h066DD847; //18'b000001100110110111;//'d025113;         
    G_Kernel_7x7[2][159:128]   <= 32'h063B25B2; //18'b000001100011101100;//'d024340;       
    G_Kernel_7x7[2][191:160]  <= 32'h05AC3BC7; //18'b000001011010110000;//'d022159;         
    G_Kernel_7x7[2][223:192] <= 32'h04D9ED31; //18'b000001001101100111;//'d018950;  
    G_Kernel_7x7[3][31:0]    <= 32'h050165DE; //18'b000001010000000101;//'d019552;         
    G_Kernel_7x7[3][63:32]   <= 32'h05DA6392; //18'b000001011101101001;//'d022863;         
    G_Kernel_7x7[3][95:64]   <= 32'h066DD847; //18'b000001100110110111;//'d025113;        
    G_Kernel_7x7[3][127:96]   <= 32'h06A2275A; //18'b000001101010001000;//'d025911;         
    G_Kernel_7x7[3][159:128]   <= 32'h066DD847; //18'b000001100110110111;//'d025113;       
    G_Kernel_7x7[3][191:160]  <= 32'h05DA6392; //18'b000001011101101001;//'d022863;         
    G_Kernel_7x7[3][223:192] <= 32'h050165DE; //18'b000001010000000101;//'d019552;          
  end
end*/
/*
always @(posedge clk) begin
  if (!rst_n)
    buffer_we <= 1'b0;    
  else if (start)
    buffer_we <= 1'b1;
  else if (img_addr=='d480 || current_state==ST_IDLE)
    buffer_we <= 1'b0;
end*/


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
  else if (img_addr=='d480)
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