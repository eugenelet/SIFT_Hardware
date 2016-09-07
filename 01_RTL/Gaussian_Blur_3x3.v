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
input       [5119:0]  buffer_data_0;
input       [5119:0]  buffer_data_1;
input       [5119:0]  buffer_data_2;
output  reg           fill_zero;

/*Image SRAM Control*/
output reg  [8:0]     img_addr;


/*BLUR SRAM Control*/
output reg  [5119:0]  blur_din;
output reg  [8:0]     blur_addr;
output reg            blur_mem_we;

/*Kernel Q0.18 (We take last 6 decimal digits for simplicity (<262144))*/
reg       [95:0]  G_Kernel_3x3  [0:1];
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

always @(posedge clk) begin
  if (!rst_n) begin
    G_Kernel_3x3[0][31:0]  <=  31'h17BC5428; //18'b00_0101_1110_1111_0001;//'d092717;         
    G_Kernel_3x3[0][63:32] <=  31'h1E7ABFF3; //18'b00_0111_1001_1110_1010;//'d119061;         
    G_Kernel_3x3[0][95:64] <=  31'h17BC5428; //18'b00_0101_1110_1111_0001;//'d092717;         
    G_Kernel_3x3[1][31:0]  <=  31'h1E7ABFF3; //18'b00_0111_1001_1110_1010;//'d119061;         
    G_Kernel_3x3[1][63:32] <=  31'h2723AF8E; //18'b00_1001_1100_1000_1110;//'d152888;         
    G_Kernel_3x3[1][95:64] <=  31'h1E7ABFF3; //18'b00_0111_1001_1110_1011;//'d119061;         
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
always @(posedge clk) begin
  if (!rst_n) 
    fill_zero <= 1'b0;    
  else if (img_addr=='d480)
    fill_zero <= 1'b1;
  else
    fill_zero <= 1'b0;
end

assign buffer_we = ((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) || current_state==ST_GAUSSIAN_9 ) ? 1:0;

always @(posedge clk) begin
  if (!rst_n) 
    img_addr <= 'd0;    
  else if (((current_state==ST_IDLE && start) || (current_state==ST_READY && !ready_start_relay) || current_state==ST_GAUSSIAN_7) && img_addr<'d480)
    img_addr <= img_addr + 'd1;
  else if (done)
    img_addr <= 'd0;
end

/*Module DONE, inform SYSTEM*/
always @(posedge clk) begin
  if (!rst_n)
    done <= 1'b0;    
  else if (current_state==ST_GAUSSIAN_9 && blur_addr=='d480)
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
  else if (current_state==ST_GAUSSIAN_9 && blur_addr<'d480)
    blur_mem_we <= 1'b1;
  else
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

reg [23:0]  layer0[0:63]; //wire
reg [23:0]  layer1[0:63]; //wire
reg [23:0]  layer2[0:63]; //wire
always @(*) begin
  case(current_state)
    ST_GAUSSIAN_0: begin
        layer0[0][7:0] = 0;
        layer0[0][15:8] = buffer_data_2[7:0];
        layer0[0][23:16] = buffer_data_2[15:8];
        layer1[0][7:0] = 0;
        layer1[0][15:8] = buffer_data_1[7:0];
        layer1[0][23:16] = buffer_data_1[15:8];
        layer2[0][7:0] = 0;
        layer2[0][15:8] = buffer_data_0[7:0];
        layer2[0][23:16] = buffer_data_0[15:8];
        layer0[1][7:0] = buffer_data_2[7:0];
        layer0[1][15:8] = buffer_data_2[15:8];
        layer0[1][23:16] = buffer_data_2[23:16];
        layer1[1][7:0] = buffer_data_1[7:0];
        layer1[1][15:8] = buffer_data_1[15:8];
        layer1[1][23:16] = buffer_data_1[23:16];
        layer2[1][7:0] = buffer_data_0[7:0];
        layer2[1][15:8] = buffer_data_0[15:8];
        layer2[1][23:16] = buffer_data_0[23:16];
        layer0[2][7:0] = buffer_data_2[15:8];
        layer0[2][15:8] = buffer_data_2[23:16];
        layer0[2][23:16] = buffer_data_2[31:24];
        layer1[2][7:0] = buffer_data_1[15:8];
        layer1[2][15:8] = buffer_data_1[23:16];
        layer1[2][23:16] = buffer_data_1[31:24];
        layer2[2][7:0] = buffer_data_0[15:8];
        layer2[2][15:8] = buffer_data_0[23:16];
        layer2[2][23:16] = buffer_data_0[31:24];
        layer0[3][7:0] = buffer_data_2[23:16];
        layer0[3][15:8] = buffer_data_2[31:24];
        layer0[3][23:16] = buffer_data_2[39:32];
        layer1[3][7:0] = buffer_data_1[23:16];
        layer1[3][15:8] = buffer_data_1[31:24];
        layer1[3][23:16] = buffer_data_1[39:32];
        layer2[3][7:0] = buffer_data_0[23:16];
        layer2[3][15:8] = buffer_data_0[31:24];
        layer2[3][23:16] = buffer_data_0[39:32];
        layer0[4][7:0] = buffer_data_2[31:24];
        layer0[4][15:8] = buffer_data_2[39:32];
        layer0[4][23:16] = buffer_data_2[47:40];
        layer1[4][7:0] = buffer_data_1[31:24];
        layer1[4][15:8] = buffer_data_1[39:32];
        layer1[4][23:16] = buffer_data_1[47:40];
        layer2[4][7:0] = buffer_data_0[31:24];
        layer2[4][15:8] = buffer_data_0[39:32];
        layer2[4][23:16] = buffer_data_0[47:40];
        layer0[5][7:0] = buffer_data_2[39:32];
        layer0[5][15:8] = buffer_data_2[47:40];
        layer0[5][23:16] = buffer_data_2[55:48];
        layer1[5][7:0] = buffer_data_1[39:32];
        layer1[5][15:8] = buffer_data_1[47:40];
        layer1[5][23:16] = buffer_data_1[55:48];
        layer2[5][7:0] = buffer_data_0[39:32];
        layer2[5][15:8] = buffer_data_0[47:40];
        layer2[5][23:16] = buffer_data_0[55:48];
        layer0[6][7:0] = buffer_data_2[47:40];
        layer0[6][15:8] = buffer_data_2[55:48];
        layer0[6][23:16] = buffer_data_2[63:56];
        layer1[6][7:0] = buffer_data_1[47:40];
        layer1[6][15:8] = buffer_data_1[55:48];
        layer1[6][23:16] = buffer_data_1[63:56];
        layer2[6][7:0] = buffer_data_0[47:40];
        layer2[6][15:8] = buffer_data_0[55:48];
        layer2[6][23:16] = buffer_data_0[63:56];
        layer0[7][7:0] = buffer_data_2[55:48];
        layer0[7][15:8] = buffer_data_2[63:56];
        layer0[7][23:16] = buffer_data_2[71:64];
        layer1[7][7:0] = buffer_data_1[55:48];
        layer1[7][15:8] = buffer_data_1[63:56];
        layer1[7][23:16] = buffer_data_1[71:64];
        layer2[7][7:0] = buffer_data_0[55:48];
        layer2[7][15:8] = buffer_data_0[63:56];
        layer2[7][23:16] = buffer_data_0[71:64];
        layer0[8][7:0] = buffer_data_2[63:56];
        layer0[8][15:8] = buffer_data_2[71:64];
        layer0[8][23:16] = buffer_data_2[79:72];
        layer1[8][7:0] = buffer_data_1[63:56];
        layer1[8][15:8] = buffer_data_1[71:64];
        layer1[8][23:16] = buffer_data_1[79:72];
        layer2[8][7:0] = buffer_data_0[63:56];
        layer2[8][15:8] = buffer_data_0[71:64];
        layer2[8][23:16] = buffer_data_0[79:72];
        layer0[9][7:0] = buffer_data_2[71:64];
        layer0[9][15:8] = buffer_data_2[79:72];
        layer0[9][23:16] = buffer_data_2[87:80];
        layer1[9][7:0] = buffer_data_1[71:64];
        layer1[9][15:8] = buffer_data_1[79:72];
        layer1[9][23:16] = buffer_data_1[87:80];
        layer2[9][7:0] = buffer_data_0[71:64];
        layer2[9][15:8] = buffer_data_0[79:72];
        layer2[9][23:16] = buffer_data_0[87:80];
        layer0[10][7:0] = buffer_data_2[79:72];
        layer0[10][15:8] = buffer_data_2[87:80];
        layer0[10][23:16] = buffer_data_2[95:88];
        layer1[10][7:0] = buffer_data_1[79:72];
        layer1[10][15:8] = buffer_data_1[87:80];
        layer1[10][23:16] = buffer_data_1[95:88];
        layer2[10][7:0] = buffer_data_0[79:72];
        layer2[10][15:8] = buffer_data_0[87:80];
        layer2[10][23:16] = buffer_data_0[95:88];
        layer0[11][7:0] = buffer_data_2[87:80];
        layer0[11][15:8] = buffer_data_2[95:88];
        layer0[11][23:16] = buffer_data_2[103:96];
        layer1[11][7:0] = buffer_data_1[87:80];
        layer1[11][15:8] = buffer_data_1[95:88];
        layer1[11][23:16] = buffer_data_1[103:96];
        layer2[11][7:0] = buffer_data_0[87:80];
        layer2[11][15:8] = buffer_data_0[95:88];
        layer2[11][23:16] = buffer_data_0[103:96];
        layer0[12][7:0] = buffer_data_2[95:88];
        layer0[12][15:8] = buffer_data_2[103:96];
        layer0[12][23:16] = buffer_data_2[111:104];
        layer1[12][7:0] = buffer_data_1[95:88];
        layer1[12][15:8] = buffer_data_1[103:96];
        layer1[12][23:16] = buffer_data_1[111:104];
        layer2[12][7:0] = buffer_data_0[95:88];
        layer2[12][15:8] = buffer_data_0[103:96];
        layer2[12][23:16] = buffer_data_0[111:104];
        layer0[13][7:0] = buffer_data_2[103:96];
        layer0[13][15:8] = buffer_data_2[111:104];
        layer0[13][23:16] = buffer_data_2[119:112];
        layer1[13][7:0] = buffer_data_1[103:96];
        layer1[13][15:8] = buffer_data_1[111:104];
        layer1[13][23:16] = buffer_data_1[119:112];
        layer2[13][7:0] = buffer_data_0[103:96];
        layer2[13][15:8] = buffer_data_0[111:104];
        layer2[13][23:16] = buffer_data_0[119:112];
        layer0[14][7:0] = buffer_data_2[111:104];
        layer0[14][15:8] = buffer_data_2[119:112];
        layer0[14][23:16] = buffer_data_2[127:120];
        layer1[14][7:0] = buffer_data_1[111:104];
        layer1[14][15:8] = buffer_data_1[119:112];
        layer1[14][23:16] = buffer_data_1[127:120];
        layer2[14][7:0] = buffer_data_0[111:104];
        layer2[14][15:8] = buffer_data_0[119:112];
        layer2[14][23:16] = buffer_data_0[127:120];
        layer0[15][7:0] = buffer_data_2[119:112];
        layer0[15][15:8] = buffer_data_2[127:120];
        layer0[15][23:16] = buffer_data_2[135:128];
        layer1[15][7:0] = buffer_data_1[119:112];
        layer1[15][15:8] = buffer_data_1[127:120];
        layer1[15][23:16] = buffer_data_1[135:128];
        layer2[15][7:0] = buffer_data_0[119:112];
        layer2[15][15:8] = buffer_data_0[127:120];
        layer2[15][23:16] = buffer_data_0[135:128];
        layer0[16][7:0] = buffer_data_2[127:120];
        layer0[16][15:8] = buffer_data_2[135:128];
        layer0[16][23:16] = buffer_data_2[143:136];
        layer1[16][7:0] = buffer_data_1[127:120];
        layer1[16][15:8] = buffer_data_1[135:128];
        layer1[16][23:16] = buffer_data_1[143:136];
        layer2[16][7:0] = buffer_data_0[127:120];
        layer2[16][15:8] = buffer_data_0[135:128];
        layer2[16][23:16] = buffer_data_0[143:136];
        layer0[17][7:0] = buffer_data_2[135:128];
        layer0[17][15:8] = buffer_data_2[143:136];
        layer0[17][23:16] = buffer_data_2[151:144];
        layer1[17][7:0] = buffer_data_1[135:128];
        layer1[17][15:8] = buffer_data_1[143:136];
        layer1[17][23:16] = buffer_data_1[151:144];
        layer2[17][7:0] = buffer_data_0[135:128];
        layer2[17][15:8] = buffer_data_0[143:136];
        layer2[17][23:16] = buffer_data_0[151:144];
        layer0[18][7:0] = buffer_data_2[143:136];
        layer0[18][15:8] = buffer_data_2[151:144];
        layer0[18][23:16] = buffer_data_2[159:152];
        layer1[18][7:0] = buffer_data_1[143:136];
        layer1[18][15:8] = buffer_data_1[151:144];
        layer1[18][23:16] = buffer_data_1[159:152];
        layer2[18][7:0] = buffer_data_0[143:136];
        layer2[18][15:8] = buffer_data_0[151:144];
        layer2[18][23:16] = buffer_data_0[159:152];
        layer0[19][7:0] = buffer_data_2[151:144];
        layer0[19][15:8] = buffer_data_2[159:152];
        layer0[19][23:16] = buffer_data_2[167:160];
        layer1[19][7:0] = buffer_data_1[151:144];
        layer1[19][15:8] = buffer_data_1[159:152];
        layer1[19][23:16] = buffer_data_1[167:160];
        layer2[19][7:0] = buffer_data_0[151:144];
        layer2[19][15:8] = buffer_data_0[159:152];
        layer2[19][23:16] = buffer_data_0[167:160];
        layer0[20][7:0] = buffer_data_2[159:152];
        layer0[20][15:8] = buffer_data_2[167:160];
        layer0[20][23:16] = buffer_data_2[175:168];
        layer1[20][7:0] = buffer_data_1[159:152];
        layer1[20][15:8] = buffer_data_1[167:160];
        layer1[20][23:16] = buffer_data_1[175:168];
        layer2[20][7:0] = buffer_data_0[159:152];
        layer2[20][15:8] = buffer_data_0[167:160];
        layer2[20][23:16] = buffer_data_0[175:168];
        layer0[21][7:0] = buffer_data_2[167:160];
        layer0[21][15:8] = buffer_data_2[175:168];
        layer0[21][23:16] = buffer_data_2[183:176];
        layer1[21][7:0] = buffer_data_1[167:160];
        layer1[21][15:8] = buffer_data_1[175:168];
        layer1[21][23:16] = buffer_data_1[183:176];
        layer2[21][7:0] = buffer_data_0[167:160];
        layer2[21][15:8] = buffer_data_0[175:168];
        layer2[21][23:16] = buffer_data_0[183:176];
        layer0[22][7:0] = buffer_data_2[175:168];
        layer0[22][15:8] = buffer_data_2[183:176];
        layer0[22][23:16] = buffer_data_2[191:184];
        layer1[22][7:0] = buffer_data_1[175:168];
        layer1[22][15:8] = buffer_data_1[183:176];
        layer1[22][23:16] = buffer_data_1[191:184];
        layer2[22][7:0] = buffer_data_0[175:168];
        layer2[22][15:8] = buffer_data_0[183:176];
        layer2[22][23:16] = buffer_data_0[191:184];
        layer0[23][7:0] = buffer_data_2[183:176];
        layer0[23][15:8] = buffer_data_2[191:184];
        layer0[23][23:16] = buffer_data_2[199:192];
        layer1[23][7:0] = buffer_data_1[183:176];
        layer1[23][15:8] = buffer_data_1[191:184];
        layer1[23][23:16] = buffer_data_1[199:192];
        layer2[23][7:0] = buffer_data_0[183:176];
        layer2[23][15:8] = buffer_data_0[191:184];
        layer2[23][23:16] = buffer_data_0[199:192];
        layer0[24][7:0] = buffer_data_2[191:184];
        layer0[24][15:8] = buffer_data_2[199:192];
        layer0[24][23:16] = buffer_data_2[207:200];
        layer1[24][7:0] = buffer_data_1[191:184];
        layer1[24][15:8] = buffer_data_1[199:192];
        layer1[24][23:16] = buffer_data_1[207:200];
        layer2[24][7:0] = buffer_data_0[191:184];
        layer2[24][15:8] = buffer_data_0[199:192];
        layer2[24][23:16] = buffer_data_0[207:200];
        layer0[25][7:0] = buffer_data_2[199:192];
        layer0[25][15:8] = buffer_data_2[207:200];
        layer0[25][23:16] = buffer_data_2[215:208];
        layer1[25][7:0] = buffer_data_1[199:192];
        layer1[25][15:8] = buffer_data_1[207:200];
        layer1[25][23:16] = buffer_data_1[215:208];
        layer2[25][7:0] = buffer_data_0[199:192];
        layer2[25][15:8] = buffer_data_0[207:200];
        layer2[25][23:16] = buffer_data_0[215:208];
        layer0[26][7:0] = buffer_data_2[207:200];
        layer0[26][15:8] = buffer_data_2[215:208];
        layer0[26][23:16] = buffer_data_2[223:216];
        layer1[26][7:0] = buffer_data_1[207:200];
        layer1[26][15:8] = buffer_data_1[215:208];
        layer1[26][23:16] = buffer_data_1[223:216];
        layer2[26][7:0] = buffer_data_0[207:200];
        layer2[26][15:8] = buffer_data_0[215:208];
        layer2[26][23:16] = buffer_data_0[223:216];
        layer0[27][7:0] = buffer_data_2[215:208];
        layer0[27][15:8] = buffer_data_2[223:216];
        layer0[27][23:16] = buffer_data_2[231:224];
        layer1[27][7:0] = buffer_data_1[215:208];
        layer1[27][15:8] = buffer_data_1[223:216];
        layer1[27][23:16] = buffer_data_1[231:224];
        layer2[27][7:0] = buffer_data_0[215:208];
        layer2[27][15:8] = buffer_data_0[223:216];
        layer2[27][23:16] = buffer_data_0[231:224];
        layer0[28][7:0] = buffer_data_2[223:216];
        layer0[28][15:8] = buffer_data_2[231:224];
        layer0[28][23:16] = buffer_data_2[239:232];
        layer1[28][7:0] = buffer_data_1[223:216];
        layer1[28][15:8] = buffer_data_1[231:224];
        layer1[28][23:16] = buffer_data_1[239:232];
        layer2[28][7:0] = buffer_data_0[223:216];
        layer2[28][15:8] = buffer_data_0[231:224];
        layer2[28][23:16] = buffer_data_0[239:232];
        layer0[29][7:0] = buffer_data_2[231:224];
        layer0[29][15:8] = buffer_data_2[239:232];
        layer0[29][23:16] = buffer_data_2[247:240];
        layer1[29][7:0] = buffer_data_1[231:224];
        layer1[29][15:8] = buffer_data_1[239:232];
        layer1[29][23:16] = buffer_data_1[247:240];
        layer2[29][7:0] = buffer_data_0[231:224];
        layer2[29][15:8] = buffer_data_0[239:232];
        layer2[29][23:16] = buffer_data_0[247:240];
        layer0[30][7:0] = buffer_data_2[239:232];
        layer0[30][15:8] = buffer_data_2[247:240];
        layer0[30][23:16] = buffer_data_2[255:248];
        layer1[30][7:0] = buffer_data_1[239:232];
        layer1[30][15:8] = buffer_data_1[247:240];
        layer1[30][23:16] = buffer_data_1[255:248];
        layer2[30][7:0] = buffer_data_0[239:232];
        layer2[30][15:8] = buffer_data_0[247:240];
        layer2[30][23:16] = buffer_data_0[255:248];
        layer0[31][7:0] = buffer_data_2[247:240];
        layer0[31][15:8] = buffer_data_2[255:248];
        layer0[31][23:16] = buffer_data_2[263:256];
        layer1[31][7:0] = buffer_data_1[247:240];
        layer1[31][15:8] = buffer_data_1[255:248];
        layer1[31][23:16] = buffer_data_1[263:256];
        layer2[31][7:0] = buffer_data_0[247:240];
        layer2[31][15:8] = buffer_data_0[255:248];
        layer2[31][23:16] = buffer_data_0[263:256];
        layer0[32][7:0] = buffer_data_2[255:248];
        layer0[32][15:8] = buffer_data_2[263:256];
        layer0[32][23:16] = buffer_data_2[271:264];
        layer1[32][7:0] = buffer_data_1[255:248];
        layer1[32][15:8] = buffer_data_1[263:256];
        layer1[32][23:16] = buffer_data_1[271:264];
        layer2[32][7:0] = buffer_data_0[255:248];
        layer2[32][15:8] = buffer_data_0[263:256];
        layer2[32][23:16] = buffer_data_0[271:264];
        layer0[33][7:0] = buffer_data_2[263:256];
        layer0[33][15:8] = buffer_data_2[271:264];
        layer0[33][23:16] = buffer_data_2[279:272];
        layer1[33][7:0] = buffer_data_1[263:256];
        layer1[33][15:8] = buffer_data_1[271:264];
        layer1[33][23:16] = buffer_data_1[279:272];
        layer2[33][7:0] = buffer_data_0[263:256];
        layer2[33][15:8] = buffer_data_0[271:264];
        layer2[33][23:16] = buffer_data_0[279:272];
        layer0[34][7:0] = buffer_data_2[271:264];
        layer0[34][15:8] = buffer_data_2[279:272];
        layer0[34][23:16] = buffer_data_2[287:280];
        layer1[34][7:0] = buffer_data_1[271:264];
        layer1[34][15:8] = buffer_data_1[279:272];
        layer1[34][23:16] = buffer_data_1[287:280];
        layer2[34][7:0] = buffer_data_0[271:264];
        layer2[34][15:8] = buffer_data_0[279:272];
        layer2[34][23:16] = buffer_data_0[287:280];
        layer0[35][7:0] = buffer_data_2[279:272];
        layer0[35][15:8] = buffer_data_2[287:280];
        layer0[35][23:16] = buffer_data_2[295:288];
        layer1[35][7:0] = buffer_data_1[279:272];
        layer1[35][15:8] = buffer_data_1[287:280];
        layer1[35][23:16] = buffer_data_1[295:288];
        layer2[35][7:0] = buffer_data_0[279:272];
        layer2[35][15:8] = buffer_data_0[287:280];
        layer2[35][23:16] = buffer_data_0[295:288];
        layer0[36][7:0] = buffer_data_2[287:280];
        layer0[36][15:8] = buffer_data_2[295:288];
        layer0[36][23:16] = buffer_data_2[303:296];
        layer1[36][7:0] = buffer_data_1[287:280];
        layer1[36][15:8] = buffer_data_1[295:288];
        layer1[36][23:16] = buffer_data_1[303:296];
        layer2[36][7:0] = buffer_data_0[287:280];
        layer2[36][15:8] = buffer_data_0[295:288];
        layer2[36][23:16] = buffer_data_0[303:296];
        layer0[37][7:0] = buffer_data_2[295:288];
        layer0[37][15:8] = buffer_data_2[303:296];
        layer0[37][23:16] = buffer_data_2[311:304];
        layer1[37][7:0] = buffer_data_1[295:288];
        layer1[37][15:8] = buffer_data_1[303:296];
        layer1[37][23:16] = buffer_data_1[311:304];
        layer2[37][7:0] = buffer_data_0[295:288];
        layer2[37][15:8] = buffer_data_0[303:296];
        layer2[37][23:16] = buffer_data_0[311:304];
        layer0[38][7:0] = buffer_data_2[303:296];
        layer0[38][15:8] = buffer_data_2[311:304];
        layer0[38][23:16] = buffer_data_2[319:312];
        layer1[38][7:0] = buffer_data_1[303:296];
        layer1[38][15:8] = buffer_data_1[311:304];
        layer1[38][23:16] = buffer_data_1[319:312];
        layer2[38][7:0] = buffer_data_0[303:296];
        layer2[38][15:8] = buffer_data_0[311:304];
        layer2[38][23:16] = buffer_data_0[319:312];
        layer0[39][7:0] = buffer_data_2[311:304];
        layer0[39][15:8] = buffer_data_2[319:312];
        layer0[39][23:16] = buffer_data_2[327:320];
        layer1[39][7:0] = buffer_data_1[311:304];
        layer1[39][15:8] = buffer_data_1[319:312];
        layer1[39][23:16] = buffer_data_1[327:320];
        layer2[39][7:0] = buffer_data_0[311:304];
        layer2[39][15:8] = buffer_data_0[319:312];
        layer2[39][23:16] = buffer_data_0[327:320];
        layer0[40][7:0] = buffer_data_2[319:312];
        layer0[40][15:8] = buffer_data_2[327:320];
        layer0[40][23:16] = buffer_data_2[335:328];
        layer1[40][7:0] = buffer_data_1[319:312];
        layer1[40][15:8] = buffer_data_1[327:320];
        layer1[40][23:16] = buffer_data_1[335:328];
        layer2[40][7:0] = buffer_data_0[319:312];
        layer2[40][15:8] = buffer_data_0[327:320];
        layer2[40][23:16] = buffer_data_0[335:328];
        layer0[41][7:0] = buffer_data_2[327:320];
        layer0[41][15:8] = buffer_data_2[335:328];
        layer0[41][23:16] = buffer_data_2[343:336];
        layer1[41][7:0] = buffer_data_1[327:320];
        layer1[41][15:8] = buffer_data_1[335:328];
        layer1[41][23:16] = buffer_data_1[343:336];
        layer2[41][7:0] = buffer_data_0[327:320];
        layer2[41][15:8] = buffer_data_0[335:328];
        layer2[41][23:16] = buffer_data_0[343:336];
        layer0[42][7:0] = buffer_data_2[335:328];
        layer0[42][15:8] = buffer_data_2[343:336];
        layer0[42][23:16] = buffer_data_2[351:344];
        layer1[42][7:0] = buffer_data_1[335:328];
        layer1[42][15:8] = buffer_data_1[343:336];
        layer1[42][23:16] = buffer_data_1[351:344];
        layer2[42][7:0] = buffer_data_0[335:328];
        layer2[42][15:8] = buffer_data_0[343:336];
        layer2[42][23:16] = buffer_data_0[351:344];
        layer0[43][7:0] = buffer_data_2[343:336];
        layer0[43][15:8] = buffer_data_2[351:344];
        layer0[43][23:16] = buffer_data_2[359:352];
        layer1[43][7:0] = buffer_data_1[343:336];
        layer1[43][15:8] = buffer_data_1[351:344];
        layer1[43][23:16] = buffer_data_1[359:352];
        layer2[43][7:0] = buffer_data_0[343:336];
        layer2[43][15:8] = buffer_data_0[351:344];
        layer2[43][23:16] = buffer_data_0[359:352];
        layer0[44][7:0] = buffer_data_2[351:344];
        layer0[44][15:8] = buffer_data_2[359:352];
        layer0[44][23:16] = buffer_data_2[367:360];
        layer1[44][7:0] = buffer_data_1[351:344];
        layer1[44][15:8] = buffer_data_1[359:352];
        layer1[44][23:16] = buffer_data_1[367:360];
        layer2[44][7:0] = buffer_data_0[351:344];
        layer2[44][15:8] = buffer_data_0[359:352];
        layer2[44][23:16] = buffer_data_0[367:360];
        layer0[45][7:0] = buffer_data_2[359:352];
        layer0[45][15:8] = buffer_data_2[367:360];
        layer0[45][23:16] = buffer_data_2[375:368];
        layer1[45][7:0] = buffer_data_1[359:352];
        layer1[45][15:8] = buffer_data_1[367:360];
        layer1[45][23:16] = buffer_data_1[375:368];
        layer2[45][7:0] = buffer_data_0[359:352];
        layer2[45][15:8] = buffer_data_0[367:360];
        layer2[45][23:16] = buffer_data_0[375:368];
        layer0[46][7:0] = buffer_data_2[367:360];
        layer0[46][15:8] = buffer_data_2[375:368];
        layer0[46][23:16] = buffer_data_2[383:376];
        layer1[46][7:0] = buffer_data_1[367:360];
        layer1[46][15:8] = buffer_data_1[375:368];
        layer1[46][23:16] = buffer_data_1[383:376];
        layer2[46][7:0] = buffer_data_0[367:360];
        layer2[46][15:8] = buffer_data_0[375:368];
        layer2[46][23:16] = buffer_data_0[383:376];
        layer0[47][7:0] = buffer_data_2[375:368];
        layer0[47][15:8] = buffer_data_2[383:376];
        layer0[47][23:16] = buffer_data_2[391:384];
        layer1[47][7:0] = buffer_data_1[375:368];
        layer1[47][15:8] = buffer_data_1[383:376];
        layer1[47][23:16] = buffer_data_1[391:384];
        layer2[47][7:0] = buffer_data_0[375:368];
        layer2[47][15:8] = buffer_data_0[383:376];
        layer2[47][23:16] = buffer_data_0[391:384];
        layer0[48][7:0] = buffer_data_2[383:376];
        layer0[48][15:8] = buffer_data_2[391:384];
        layer0[48][23:16] = buffer_data_2[399:392];
        layer1[48][7:0] = buffer_data_1[383:376];
        layer1[48][15:8] = buffer_data_1[391:384];
        layer1[48][23:16] = buffer_data_1[399:392];
        layer2[48][7:0] = buffer_data_0[383:376];
        layer2[48][15:8] = buffer_data_0[391:384];
        layer2[48][23:16] = buffer_data_0[399:392];
        layer0[49][7:0] = buffer_data_2[391:384];
        layer0[49][15:8] = buffer_data_2[399:392];
        layer0[49][23:16] = buffer_data_2[407:400];
        layer1[49][7:0] = buffer_data_1[391:384];
        layer1[49][15:8] = buffer_data_1[399:392];
        layer1[49][23:16] = buffer_data_1[407:400];
        layer2[49][7:0] = buffer_data_0[391:384];
        layer2[49][15:8] = buffer_data_0[399:392];
        layer2[49][23:16] = buffer_data_0[407:400];
        layer0[50][7:0] = buffer_data_2[399:392];
        layer0[50][15:8] = buffer_data_2[407:400];
        layer0[50][23:16] = buffer_data_2[415:408];
        layer1[50][7:0] = buffer_data_1[399:392];
        layer1[50][15:8] = buffer_data_1[407:400];
        layer1[50][23:16] = buffer_data_1[415:408];
        layer2[50][7:0] = buffer_data_0[399:392];
        layer2[50][15:8] = buffer_data_0[407:400];
        layer2[50][23:16] = buffer_data_0[415:408];
        layer0[51][7:0] = buffer_data_2[407:400];
        layer0[51][15:8] = buffer_data_2[415:408];
        layer0[51][23:16] = buffer_data_2[423:416];
        layer1[51][7:0] = buffer_data_1[407:400];
        layer1[51][15:8] = buffer_data_1[415:408];
        layer1[51][23:16] = buffer_data_1[423:416];
        layer2[51][7:0] = buffer_data_0[407:400];
        layer2[51][15:8] = buffer_data_0[415:408];
        layer2[51][23:16] = buffer_data_0[423:416];
        layer0[52][7:0] = buffer_data_2[415:408];
        layer0[52][15:8] = buffer_data_2[423:416];
        layer0[52][23:16] = buffer_data_2[431:424];
        layer1[52][7:0] = buffer_data_1[415:408];
        layer1[52][15:8] = buffer_data_1[423:416];
        layer1[52][23:16] = buffer_data_1[431:424];
        layer2[52][7:0] = buffer_data_0[415:408];
        layer2[52][15:8] = buffer_data_0[423:416];
        layer2[52][23:16] = buffer_data_0[431:424];
        layer0[53][7:0] = buffer_data_2[423:416];
        layer0[53][15:8] = buffer_data_2[431:424];
        layer0[53][23:16] = buffer_data_2[439:432];
        layer1[53][7:0] = buffer_data_1[423:416];
        layer1[53][15:8] = buffer_data_1[431:424];
        layer1[53][23:16] = buffer_data_1[439:432];
        layer2[53][7:0] = buffer_data_0[423:416];
        layer2[53][15:8] = buffer_data_0[431:424];
        layer2[53][23:16] = buffer_data_0[439:432];
        layer0[54][7:0] = buffer_data_2[431:424];
        layer0[54][15:8] = buffer_data_2[439:432];
        layer0[54][23:16] = buffer_data_2[447:440];
        layer1[54][7:0] = buffer_data_1[431:424];
        layer1[54][15:8] = buffer_data_1[439:432];
        layer1[54][23:16] = buffer_data_1[447:440];
        layer2[54][7:0] = buffer_data_0[431:424];
        layer2[54][15:8] = buffer_data_0[439:432];
        layer2[54][23:16] = buffer_data_0[447:440];
        layer0[55][7:0] = buffer_data_2[439:432];
        layer0[55][15:8] = buffer_data_2[447:440];
        layer0[55][23:16] = buffer_data_2[455:448];
        layer1[55][7:0] = buffer_data_1[439:432];
        layer1[55][15:8] = buffer_data_1[447:440];
        layer1[55][23:16] = buffer_data_1[455:448];
        layer2[55][7:0] = buffer_data_0[439:432];
        layer2[55][15:8] = buffer_data_0[447:440];
        layer2[55][23:16] = buffer_data_0[455:448];
        layer0[56][7:0] = buffer_data_2[447:440];
        layer0[56][15:8] = buffer_data_2[455:448];
        layer0[56][23:16] = buffer_data_2[463:456];
        layer1[56][7:0] = buffer_data_1[447:440];
        layer1[56][15:8] = buffer_data_1[455:448];
        layer1[56][23:16] = buffer_data_1[463:456];
        layer2[56][7:0] = buffer_data_0[447:440];
        layer2[56][15:8] = buffer_data_0[455:448];
        layer2[56][23:16] = buffer_data_0[463:456];
        layer0[57][7:0] = buffer_data_2[455:448];
        layer0[57][15:8] = buffer_data_2[463:456];
        layer0[57][23:16] = buffer_data_2[471:464];
        layer1[57][7:0] = buffer_data_1[455:448];
        layer1[57][15:8] = buffer_data_1[463:456];
        layer1[57][23:16] = buffer_data_1[471:464];
        layer2[57][7:0] = buffer_data_0[455:448];
        layer2[57][15:8] = buffer_data_0[463:456];
        layer2[57][23:16] = buffer_data_0[471:464];
        layer0[58][7:0] = buffer_data_2[463:456];
        layer0[58][15:8] = buffer_data_2[471:464];
        layer0[58][23:16] = buffer_data_2[479:472];
        layer1[58][7:0] = buffer_data_1[463:456];
        layer1[58][15:8] = buffer_data_1[471:464];
        layer1[58][23:16] = buffer_data_1[479:472];
        layer2[58][7:0] = buffer_data_0[463:456];
        layer2[58][15:8] = buffer_data_0[471:464];
        layer2[58][23:16] = buffer_data_0[479:472];
        layer0[59][7:0] = buffer_data_2[471:464];
        layer0[59][15:8] = buffer_data_2[479:472];
        layer0[59][23:16] = buffer_data_2[487:480];
        layer1[59][7:0] = buffer_data_1[471:464];
        layer1[59][15:8] = buffer_data_1[479:472];
        layer1[59][23:16] = buffer_data_1[487:480];
        layer2[59][7:0] = buffer_data_0[471:464];
        layer2[59][15:8] = buffer_data_0[479:472];
        layer2[59][23:16] = buffer_data_0[487:480];
        layer0[60][7:0] = buffer_data_2[479:472];
        layer0[60][15:8] = buffer_data_2[487:480];
        layer0[60][23:16] = buffer_data_2[495:488];
        layer1[60][7:0] = buffer_data_1[479:472];
        layer1[60][15:8] = buffer_data_1[487:480];
        layer1[60][23:16] = buffer_data_1[495:488];
        layer2[60][7:0] = buffer_data_0[479:472];
        layer2[60][15:8] = buffer_data_0[487:480];
        layer2[60][23:16] = buffer_data_0[495:488];
        layer0[61][7:0] = buffer_data_2[487:480];
        layer0[61][15:8] = buffer_data_2[495:488];
        layer0[61][23:16] = buffer_data_2[503:496];
        layer1[61][7:0] = buffer_data_1[487:480];
        layer1[61][15:8] = buffer_data_1[495:488];
        layer1[61][23:16] = buffer_data_1[503:496];
        layer2[61][7:0] = buffer_data_0[487:480];
        layer2[61][15:8] = buffer_data_0[495:488];
        layer2[61][23:16] = buffer_data_0[503:496];
        layer0[62][7:0] = buffer_data_2[495:488];
        layer0[62][15:8] = buffer_data_2[503:496];
        layer0[62][23:16] = buffer_data_2[511:504];
        layer1[62][7:0] = buffer_data_1[495:488];
        layer1[62][15:8] = buffer_data_1[503:496];
        layer1[62][23:16] = buffer_data_1[511:504];
        layer2[62][7:0] = buffer_data_0[495:488];
        layer2[62][15:8] = buffer_data_0[503:496];
        layer2[62][23:16] = buffer_data_0[511:504];
        layer0[63][7:0] = buffer_data_2[503:496];
        layer0[63][15:8] = buffer_data_2[511:504];
        layer0[63][23:16] = buffer_data_2[519:512];
        layer1[63][7:0] = buffer_data_1[503:496];
        layer1[63][15:8] = buffer_data_1[511:504];
        layer1[63][23:16] = buffer_data_1[519:512];
        layer2[63][7:0] = buffer_data_0[503:496];
        layer2[63][15:8] = buffer_data_0[511:504];
        layer2[63][23:16] = buffer_data_0[519:512];
    end
    ST_GAUSSIAN_1: begin
        layer0[0][7:0] = buffer_data_2[511:504];
        layer0[0][15:8] = buffer_data_2[519:512];
        layer0[0][23:16] = buffer_data_2[527:520];
        layer1[0][7:0] = buffer_data_1[511:504];
        layer1[0][15:8] = buffer_data_1[519:512];
        layer1[0][23:16] = buffer_data_1[527:520];
        layer2[0][7:0] = buffer_data_0[511:504];
        layer2[0][15:8] = buffer_data_0[519:512];
        layer2[0][23:16] = buffer_data_0[527:520];
        layer0[1][7:0] = buffer_data_2[519:512];
        layer0[1][15:8] = buffer_data_2[527:520];
        layer0[1][23:16] = buffer_data_2[535:528];
        layer1[1][7:0] = buffer_data_1[519:512];
        layer1[1][15:8] = buffer_data_1[527:520];
        layer1[1][23:16] = buffer_data_1[535:528];
        layer2[1][7:0] = buffer_data_0[519:512];
        layer2[1][15:8] = buffer_data_0[527:520];
        layer2[1][23:16] = buffer_data_0[535:528];
        layer0[2][7:0] = buffer_data_2[527:520];
        layer0[2][15:8] = buffer_data_2[535:528];
        layer0[2][23:16] = buffer_data_2[543:536];
        layer1[2][7:0] = buffer_data_1[527:520];
        layer1[2][15:8] = buffer_data_1[535:528];
        layer1[2][23:16] = buffer_data_1[543:536];
        layer2[2][7:0] = buffer_data_0[527:520];
        layer2[2][15:8] = buffer_data_0[535:528];
        layer2[2][23:16] = buffer_data_0[543:536];
        layer0[3][7:0] = buffer_data_2[535:528];
        layer0[3][15:8] = buffer_data_2[543:536];
        layer0[3][23:16] = buffer_data_2[551:544];
        layer1[3][7:0] = buffer_data_1[535:528];
        layer1[3][15:8] = buffer_data_1[543:536];
        layer1[3][23:16] = buffer_data_1[551:544];
        layer2[3][7:0] = buffer_data_0[535:528];
        layer2[3][15:8] = buffer_data_0[543:536];
        layer2[3][23:16] = buffer_data_0[551:544];
        layer0[4][7:0] = buffer_data_2[543:536];
        layer0[4][15:8] = buffer_data_2[551:544];
        layer0[4][23:16] = buffer_data_2[559:552];
        layer1[4][7:0] = buffer_data_1[543:536];
        layer1[4][15:8] = buffer_data_1[551:544];
        layer1[4][23:16] = buffer_data_1[559:552];
        layer2[4][7:0] = buffer_data_0[543:536];
        layer2[4][15:8] = buffer_data_0[551:544];
        layer2[4][23:16] = buffer_data_0[559:552];
        layer0[5][7:0] = buffer_data_2[551:544];
        layer0[5][15:8] = buffer_data_2[559:552];
        layer0[5][23:16] = buffer_data_2[567:560];
        layer1[5][7:0] = buffer_data_1[551:544];
        layer1[5][15:8] = buffer_data_1[559:552];
        layer1[5][23:16] = buffer_data_1[567:560];
        layer2[5][7:0] = buffer_data_0[551:544];
        layer2[5][15:8] = buffer_data_0[559:552];
        layer2[5][23:16] = buffer_data_0[567:560];
        layer0[6][7:0] = buffer_data_2[559:552];
        layer0[6][15:8] = buffer_data_2[567:560];
        layer0[6][23:16] = buffer_data_2[575:568];
        layer1[6][7:0] = buffer_data_1[559:552];
        layer1[6][15:8] = buffer_data_1[567:560];
        layer1[6][23:16] = buffer_data_1[575:568];
        layer2[6][7:0] = buffer_data_0[559:552];
        layer2[6][15:8] = buffer_data_0[567:560];
        layer2[6][23:16] = buffer_data_0[575:568];
        layer0[7][7:0] = buffer_data_2[567:560];
        layer0[7][15:8] = buffer_data_2[575:568];
        layer0[7][23:16] = buffer_data_2[583:576];
        layer1[7][7:0] = buffer_data_1[567:560];
        layer1[7][15:8] = buffer_data_1[575:568];
        layer1[7][23:16] = buffer_data_1[583:576];
        layer2[7][7:0] = buffer_data_0[567:560];
        layer2[7][15:8] = buffer_data_0[575:568];
        layer2[7][23:16] = buffer_data_0[583:576];
        layer0[8][7:0] = buffer_data_2[575:568];
        layer0[8][15:8] = buffer_data_2[583:576];
        layer0[8][23:16] = buffer_data_2[591:584];
        layer1[8][7:0] = buffer_data_1[575:568];
        layer1[8][15:8] = buffer_data_1[583:576];
        layer1[8][23:16] = buffer_data_1[591:584];
        layer2[8][7:0] = buffer_data_0[575:568];
        layer2[8][15:8] = buffer_data_0[583:576];
        layer2[8][23:16] = buffer_data_0[591:584];
        layer0[9][7:0] = buffer_data_2[583:576];
        layer0[9][15:8] = buffer_data_2[591:584];
        layer0[9][23:16] = buffer_data_2[599:592];
        layer1[9][7:0] = buffer_data_1[583:576];
        layer1[9][15:8] = buffer_data_1[591:584];
        layer1[9][23:16] = buffer_data_1[599:592];
        layer2[9][7:0] = buffer_data_0[583:576];
        layer2[9][15:8] = buffer_data_0[591:584];
        layer2[9][23:16] = buffer_data_0[599:592];
        layer0[10][7:0] = buffer_data_2[591:584];
        layer0[10][15:8] = buffer_data_2[599:592];
        layer0[10][23:16] = buffer_data_2[607:600];
        layer1[10][7:0] = buffer_data_1[591:584];
        layer1[10][15:8] = buffer_data_1[599:592];
        layer1[10][23:16] = buffer_data_1[607:600];
        layer2[10][7:0] = buffer_data_0[591:584];
        layer2[10][15:8] = buffer_data_0[599:592];
        layer2[10][23:16] = buffer_data_0[607:600];
        layer0[11][7:0] = buffer_data_2[599:592];
        layer0[11][15:8] = buffer_data_2[607:600];
        layer0[11][23:16] = buffer_data_2[615:608];
        layer1[11][7:0] = buffer_data_1[599:592];
        layer1[11][15:8] = buffer_data_1[607:600];
        layer1[11][23:16] = buffer_data_1[615:608];
        layer2[11][7:0] = buffer_data_0[599:592];
        layer2[11][15:8] = buffer_data_0[607:600];
        layer2[11][23:16] = buffer_data_0[615:608];
        layer0[12][7:0] = buffer_data_2[607:600];
        layer0[12][15:8] = buffer_data_2[615:608];
        layer0[12][23:16] = buffer_data_2[623:616];
        layer1[12][7:0] = buffer_data_1[607:600];
        layer1[12][15:8] = buffer_data_1[615:608];
        layer1[12][23:16] = buffer_data_1[623:616];
        layer2[12][7:0] = buffer_data_0[607:600];
        layer2[12][15:8] = buffer_data_0[615:608];
        layer2[12][23:16] = buffer_data_0[623:616];
        layer0[13][7:0] = buffer_data_2[615:608];
        layer0[13][15:8] = buffer_data_2[623:616];
        layer0[13][23:16] = buffer_data_2[631:624];
        layer1[13][7:0] = buffer_data_1[615:608];
        layer1[13][15:8] = buffer_data_1[623:616];
        layer1[13][23:16] = buffer_data_1[631:624];
        layer2[13][7:0] = buffer_data_0[615:608];
        layer2[13][15:8] = buffer_data_0[623:616];
        layer2[13][23:16] = buffer_data_0[631:624];
        layer0[14][7:0] = buffer_data_2[623:616];
        layer0[14][15:8] = buffer_data_2[631:624];
        layer0[14][23:16] = buffer_data_2[639:632];
        layer1[14][7:0] = buffer_data_1[623:616];
        layer1[14][15:8] = buffer_data_1[631:624];
        layer1[14][23:16] = buffer_data_1[639:632];
        layer2[14][7:0] = buffer_data_0[623:616];
        layer2[14][15:8] = buffer_data_0[631:624];
        layer2[14][23:16] = buffer_data_0[639:632];
        layer0[15][7:0] = buffer_data_2[631:624];
        layer0[15][15:8] = buffer_data_2[639:632];
        layer0[15][23:16] = buffer_data_2[647:640];
        layer1[15][7:0] = buffer_data_1[631:624];
        layer1[15][15:8] = buffer_data_1[639:632];
        layer1[15][23:16] = buffer_data_1[647:640];
        layer2[15][7:0] = buffer_data_0[631:624];
        layer2[15][15:8] = buffer_data_0[639:632];
        layer2[15][23:16] = buffer_data_0[647:640];
        layer0[16][7:0] = buffer_data_2[639:632];
        layer0[16][15:8] = buffer_data_2[647:640];
        layer0[16][23:16] = buffer_data_2[655:648];
        layer1[16][7:0] = buffer_data_1[639:632];
        layer1[16][15:8] = buffer_data_1[647:640];
        layer1[16][23:16] = buffer_data_1[655:648];
        layer2[16][7:0] = buffer_data_0[639:632];
        layer2[16][15:8] = buffer_data_0[647:640];
        layer2[16][23:16] = buffer_data_0[655:648];
        layer0[17][7:0] = buffer_data_2[647:640];
        layer0[17][15:8] = buffer_data_2[655:648];
        layer0[17][23:16] = buffer_data_2[663:656];
        layer1[17][7:0] = buffer_data_1[647:640];
        layer1[17][15:8] = buffer_data_1[655:648];
        layer1[17][23:16] = buffer_data_1[663:656];
        layer2[17][7:0] = buffer_data_0[647:640];
        layer2[17][15:8] = buffer_data_0[655:648];
        layer2[17][23:16] = buffer_data_0[663:656];
        layer0[18][7:0] = buffer_data_2[655:648];
        layer0[18][15:8] = buffer_data_2[663:656];
        layer0[18][23:16] = buffer_data_2[671:664];
        layer1[18][7:0] = buffer_data_1[655:648];
        layer1[18][15:8] = buffer_data_1[663:656];
        layer1[18][23:16] = buffer_data_1[671:664];
        layer2[18][7:0] = buffer_data_0[655:648];
        layer2[18][15:8] = buffer_data_0[663:656];
        layer2[18][23:16] = buffer_data_0[671:664];
        layer0[19][7:0] = buffer_data_2[663:656];
        layer0[19][15:8] = buffer_data_2[671:664];
        layer0[19][23:16] = buffer_data_2[679:672];
        layer1[19][7:0] = buffer_data_1[663:656];
        layer1[19][15:8] = buffer_data_1[671:664];
        layer1[19][23:16] = buffer_data_1[679:672];
        layer2[19][7:0] = buffer_data_0[663:656];
        layer2[19][15:8] = buffer_data_0[671:664];
        layer2[19][23:16] = buffer_data_0[679:672];
        layer0[20][7:0] = buffer_data_2[671:664];
        layer0[20][15:8] = buffer_data_2[679:672];
        layer0[20][23:16] = buffer_data_2[687:680];
        layer1[20][7:0] = buffer_data_1[671:664];
        layer1[20][15:8] = buffer_data_1[679:672];
        layer1[20][23:16] = buffer_data_1[687:680];
        layer2[20][7:0] = buffer_data_0[671:664];
        layer2[20][15:8] = buffer_data_0[679:672];
        layer2[20][23:16] = buffer_data_0[687:680];
        layer0[21][7:0] = buffer_data_2[679:672];
        layer0[21][15:8] = buffer_data_2[687:680];
        layer0[21][23:16] = buffer_data_2[695:688];
        layer1[21][7:0] = buffer_data_1[679:672];
        layer1[21][15:8] = buffer_data_1[687:680];
        layer1[21][23:16] = buffer_data_1[695:688];
        layer2[21][7:0] = buffer_data_0[679:672];
        layer2[21][15:8] = buffer_data_0[687:680];
        layer2[21][23:16] = buffer_data_0[695:688];
        layer0[22][7:0] = buffer_data_2[687:680];
        layer0[22][15:8] = buffer_data_2[695:688];
        layer0[22][23:16] = buffer_data_2[703:696];
        layer1[22][7:0] = buffer_data_1[687:680];
        layer1[22][15:8] = buffer_data_1[695:688];
        layer1[22][23:16] = buffer_data_1[703:696];
        layer2[22][7:0] = buffer_data_0[687:680];
        layer2[22][15:8] = buffer_data_0[695:688];
        layer2[22][23:16] = buffer_data_0[703:696];
        layer0[23][7:0] = buffer_data_2[695:688];
        layer0[23][15:8] = buffer_data_2[703:696];
        layer0[23][23:16] = buffer_data_2[711:704];
        layer1[23][7:0] = buffer_data_1[695:688];
        layer1[23][15:8] = buffer_data_1[703:696];
        layer1[23][23:16] = buffer_data_1[711:704];
        layer2[23][7:0] = buffer_data_0[695:688];
        layer2[23][15:8] = buffer_data_0[703:696];
        layer2[23][23:16] = buffer_data_0[711:704];
        layer0[24][7:0] = buffer_data_2[703:696];
        layer0[24][15:8] = buffer_data_2[711:704];
        layer0[24][23:16] = buffer_data_2[719:712];
        layer1[24][7:0] = buffer_data_1[703:696];
        layer1[24][15:8] = buffer_data_1[711:704];
        layer1[24][23:16] = buffer_data_1[719:712];
        layer2[24][7:0] = buffer_data_0[703:696];
        layer2[24][15:8] = buffer_data_0[711:704];
        layer2[24][23:16] = buffer_data_0[719:712];
        layer0[25][7:0] = buffer_data_2[711:704];
        layer0[25][15:8] = buffer_data_2[719:712];
        layer0[25][23:16] = buffer_data_2[727:720];
        layer1[25][7:0] = buffer_data_1[711:704];
        layer1[25][15:8] = buffer_data_1[719:712];
        layer1[25][23:16] = buffer_data_1[727:720];
        layer2[25][7:0] = buffer_data_0[711:704];
        layer2[25][15:8] = buffer_data_0[719:712];
        layer2[25][23:16] = buffer_data_0[727:720];
        layer0[26][7:0] = buffer_data_2[719:712];
        layer0[26][15:8] = buffer_data_2[727:720];
        layer0[26][23:16] = buffer_data_2[735:728];
        layer1[26][7:0] = buffer_data_1[719:712];
        layer1[26][15:8] = buffer_data_1[727:720];
        layer1[26][23:16] = buffer_data_1[735:728];
        layer2[26][7:0] = buffer_data_0[719:712];
        layer2[26][15:8] = buffer_data_0[727:720];
        layer2[26][23:16] = buffer_data_0[735:728];
        layer0[27][7:0] = buffer_data_2[727:720];
        layer0[27][15:8] = buffer_data_2[735:728];
        layer0[27][23:16] = buffer_data_2[743:736];
        layer1[27][7:0] = buffer_data_1[727:720];
        layer1[27][15:8] = buffer_data_1[735:728];
        layer1[27][23:16] = buffer_data_1[743:736];
        layer2[27][7:0] = buffer_data_0[727:720];
        layer2[27][15:8] = buffer_data_0[735:728];
        layer2[27][23:16] = buffer_data_0[743:736];
        layer0[28][7:0] = buffer_data_2[735:728];
        layer0[28][15:8] = buffer_data_2[743:736];
        layer0[28][23:16] = buffer_data_2[751:744];
        layer1[28][7:0] = buffer_data_1[735:728];
        layer1[28][15:8] = buffer_data_1[743:736];
        layer1[28][23:16] = buffer_data_1[751:744];
        layer2[28][7:0] = buffer_data_0[735:728];
        layer2[28][15:8] = buffer_data_0[743:736];
        layer2[28][23:16] = buffer_data_0[751:744];
        layer0[29][7:0] = buffer_data_2[743:736];
        layer0[29][15:8] = buffer_data_2[751:744];
        layer0[29][23:16] = buffer_data_2[759:752];
        layer1[29][7:0] = buffer_data_1[743:736];
        layer1[29][15:8] = buffer_data_1[751:744];
        layer1[29][23:16] = buffer_data_1[759:752];
        layer2[29][7:0] = buffer_data_0[743:736];
        layer2[29][15:8] = buffer_data_0[751:744];
        layer2[29][23:16] = buffer_data_0[759:752];
        layer0[30][7:0] = buffer_data_2[751:744];
        layer0[30][15:8] = buffer_data_2[759:752];
        layer0[30][23:16] = buffer_data_2[767:760];
        layer1[30][7:0] = buffer_data_1[751:744];
        layer1[30][15:8] = buffer_data_1[759:752];
        layer1[30][23:16] = buffer_data_1[767:760];
        layer2[30][7:0] = buffer_data_0[751:744];
        layer2[30][15:8] = buffer_data_0[759:752];
        layer2[30][23:16] = buffer_data_0[767:760];
        layer0[31][7:0] = buffer_data_2[759:752];
        layer0[31][15:8] = buffer_data_2[767:760];
        layer0[31][23:16] = buffer_data_2[775:768];
        layer1[31][7:0] = buffer_data_1[759:752];
        layer1[31][15:8] = buffer_data_1[767:760];
        layer1[31][23:16] = buffer_data_1[775:768];
        layer2[31][7:0] = buffer_data_0[759:752];
        layer2[31][15:8] = buffer_data_0[767:760];
        layer2[31][23:16] = buffer_data_0[775:768];
        layer0[32][7:0] = buffer_data_2[767:760];
        layer0[32][15:8] = buffer_data_2[775:768];
        layer0[32][23:16] = buffer_data_2[783:776];
        layer1[32][7:0] = buffer_data_1[767:760];
        layer1[32][15:8] = buffer_data_1[775:768];
        layer1[32][23:16] = buffer_data_1[783:776];
        layer2[32][7:0] = buffer_data_0[767:760];
        layer2[32][15:8] = buffer_data_0[775:768];
        layer2[32][23:16] = buffer_data_0[783:776];
        layer0[33][7:0] = buffer_data_2[775:768];
        layer0[33][15:8] = buffer_data_2[783:776];
        layer0[33][23:16] = buffer_data_2[791:784];
        layer1[33][7:0] = buffer_data_1[775:768];
        layer1[33][15:8] = buffer_data_1[783:776];
        layer1[33][23:16] = buffer_data_1[791:784];
        layer2[33][7:0] = buffer_data_0[775:768];
        layer2[33][15:8] = buffer_data_0[783:776];
        layer2[33][23:16] = buffer_data_0[791:784];
        layer0[34][7:0] = buffer_data_2[783:776];
        layer0[34][15:8] = buffer_data_2[791:784];
        layer0[34][23:16] = buffer_data_2[799:792];
        layer1[34][7:0] = buffer_data_1[783:776];
        layer1[34][15:8] = buffer_data_1[791:784];
        layer1[34][23:16] = buffer_data_1[799:792];
        layer2[34][7:0] = buffer_data_0[783:776];
        layer2[34][15:8] = buffer_data_0[791:784];
        layer2[34][23:16] = buffer_data_0[799:792];
        layer0[35][7:0] = buffer_data_2[791:784];
        layer0[35][15:8] = buffer_data_2[799:792];
        layer0[35][23:16] = buffer_data_2[807:800];
        layer1[35][7:0] = buffer_data_1[791:784];
        layer1[35][15:8] = buffer_data_1[799:792];
        layer1[35][23:16] = buffer_data_1[807:800];
        layer2[35][7:0] = buffer_data_0[791:784];
        layer2[35][15:8] = buffer_data_0[799:792];
        layer2[35][23:16] = buffer_data_0[807:800];
        layer0[36][7:0] = buffer_data_2[799:792];
        layer0[36][15:8] = buffer_data_2[807:800];
        layer0[36][23:16] = buffer_data_2[815:808];
        layer1[36][7:0] = buffer_data_1[799:792];
        layer1[36][15:8] = buffer_data_1[807:800];
        layer1[36][23:16] = buffer_data_1[815:808];
        layer2[36][7:0] = buffer_data_0[799:792];
        layer2[36][15:8] = buffer_data_0[807:800];
        layer2[36][23:16] = buffer_data_0[815:808];
        layer0[37][7:0] = buffer_data_2[807:800];
        layer0[37][15:8] = buffer_data_2[815:808];
        layer0[37][23:16] = buffer_data_2[823:816];
        layer1[37][7:0] = buffer_data_1[807:800];
        layer1[37][15:8] = buffer_data_1[815:808];
        layer1[37][23:16] = buffer_data_1[823:816];
        layer2[37][7:0] = buffer_data_0[807:800];
        layer2[37][15:8] = buffer_data_0[815:808];
        layer2[37][23:16] = buffer_data_0[823:816];
        layer0[38][7:0] = buffer_data_2[815:808];
        layer0[38][15:8] = buffer_data_2[823:816];
        layer0[38][23:16] = buffer_data_2[831:824];
        layer1[38][7:0] = buffer_data_1[815:808];
        layer1[38][15:8] = buffer_data_1[823:816];
        layer1[38][23:16] = buffer_data_1[831:824];
        layer2[38][7:0] = buffer_data_0[815:808];
        layer2[38][15:8] = buffer_data_0[823:816];
        layer2[38][23:16] = buffer_data_0[831:824];
        layer0[39][7:0] = buffer_data_2[823:816];
        layer0[39][15:8] = buffer_data_2[831:824];
        layer0[39][23:16] = buffer_data_2[839:832];
        layer1[39][7:0] = buffer_data_1[823:816];
        layer1[39][15:8] = buffer_data_1[831:824];
        layer1[39][23:16] = buffer_data_1[839:832];
        layer2[39][7:0] = buffer_data_0[823:816];
        layer2[39][15:8] = buffer_data_0[831:824];
        layer2[39][23:16] = buffer_data_0[839:832];
        layer0[40][7:0] = buffer_data_2[831:824];
        layer0[40][15:8] = buffer_data_2[839:832];
        layer0[40][23:16] = buffer_data_2[847:840];
        layer1[40][7:0] = buffer_data_1[831:824];
        layer1[40][15:8] = buffer_data_1[839:832];
        layer1[40][23:16] = buffer_data_1[847:840];
        layer2[40][7:0] = buffer_data_0[831:824];
        layer2[40][15:8] = buffer_data_0[839:832];
        layer2[40][23:16] = buffer_data_0[847:840];
        layer0[41][7:0] = buffer_data_2[839:832];
        layer0[41][15:8] = buffer_data_2[847:840];
        layer0[41][23:16] = buffer_data_2[855:848];
        layer1[41][7:0] = buffer_data_1[839:832];
        layer1[41][15:8] = buffer_data_1[847:840];
        layer1[41][23:16] = buffer_data_1[855:848];
        layer2[41][7:0] = buffer_data_0[839:832];
        layer2[41][15:8] = buffer_data_0[847:840];
        layer2[41][23:16] = buffer_data_0[855:848];
        layer0[42][7:0] = buffer_data_2[847:840];
        layer0[42][15:8] = buffer_data_2[855:848];
        layer0[42][23:16] = buffer_data_2[863:856];
        layer1[42][7:0] = buffer_data_1[847:840];
        layer1[42][15:8] = buffer_data_1[855:848];
        layer1[42][23:16] = buffer_data_1[863:856];
        layer2[42][7:0] = buffer_data_0[847:840];
        layer2[42][15:8] = buffer_data_0[855:848];
        layer2[42][23:16] = buffer_data_0[863:856];
        layer0[43][7:0] = buffer_data_2[855:848];
        layer0[43][15:8] = buffer_data_2[863:856];
        layer0[43][23:16] = buffer_data_2[871:864];
        layer1[43][7:0] = buffer_data_1[855:848];
        layer1[43][15:8] = buffer_data_1[863:856];
        layer1[43][23:16] = buffer_data_1[871:864];
        layer2[43][7:0] = buffer_data_0[855:848];
        layer2[43][15:8] = buffer_data_0[863:856];
        layer2[43][23:16] = buffer_data_0[871:864];
        layer0[44][7:0] = buffer_data_2[863:856];
        layer0[44][15:8] = buffer_data_2[871:864];
        layer0[44][23:16] = buffer_data_2[879:872];
        layer1[44][7:0] = buffer_data_1[863:856];
        layer1[44][15:8] = buffer_data_1[871:864];
        layer1[44][23:16] = buffer_data_1[879:872];
        layer2[44][7:0] = buffer_data_0[863:856];
        layer2[44][15:8] = buffer_data_0[871:864];
        layer2[44][23:16] = buffer_data_0[879:872];
        layer0[45][7:0] = buffer_data_2[871:864];
        layer0[45][15:8] = buffer_data_2[879:872];
        layer0[45][23:16] = buffer_data_2[887:880];
        layer1[45][7:0] = buffer_data_1[871:864];
        layer1[45][15:8] = buffer_data_1[879:872];
        layer1[45][23:16] = buffer_data_1[887:880];
        layer2[45][7:0] = buffer_data_0[871:864];
        layer2[45][15:8] = buffer_data_0[879:872];
        layer2[45][23:16] = buffer_data_0[887:880];
        layer0[46][7:0] = buffer_data_2[879:872];
        layer0[46][15:8] = buffer_data_2[887:880];
        layer0[46][23:16] = buffer_data_2[895:888];
        layer1[46][7:0] = buffer_data_1[879:872];
        layer1[46][15:8] = buffer_data_1[887:880];
        layer1[46][23:16] = buffer_data_1[895:888];
        layer2[46][7:0] = buffer_data_0[879:872];
        layer2[46][15:8] = buffer_data_0[887:880];
        layer2[46][23:16] = buffer_data_0[895:888];
        layer0[47][7:0] = buffer_data_2[887:880];
        layer0[47][15:8] = buffer_data_2[895:888];
        layer0[47][23:16] = buffer_data_2[903:896];
        layer1[47][7:0] = buffer_data_1[887:880];
        layer1[47][15:8] = buffer_data_1[895:888];
        layer1[47][23:16] = buffer_data_1[903:896];
        layer2[47][7:0] = buffer_data_0[887:880];
        layer2[47][15:8] = buffer_data_0[895:888];
        layer2[47][23:16] = buffer_data_0[903:896];
        layer0[48][7:0] = buffer_data_2[895:888];
        layer0[48][15:8] = buffer_data_2[903:896];
        layer0[48][23:16] = buffer_data_2[911:904];
        layer1[48][7:0] = buffer_data_1[895:888];
        layer1[48][15:8] = buffer_data_1[903:896];
        layer1[48][23:16] = buffer_data_1[911:904];
        layer2[48][7:0] = buffer_data_0[895:888];
        layer2[48][15:8] = buffer_data_0[903:896];
        layer2[48][23:16] = buffer_data_0[911:904];
        layer0[49][7:0] = buffer_data_2[903:896];
        layer0[49][15:8] = buffer_data_2[911:904];
        layer0[49][23:16] = buffer_data_2[919:912];
        layer1[49][7:0] = buffer_data_1[903:896];
        layer1[49][15:8] = buffer_data_1[911:904];
        layer1[49][23:16] = buffer_data_1[919:912];
        layer2[49][7:0] = buffer_data_0[903:896];
        layer2[49][15:8] = buffer_data_0[911:904];
        layer2[49][23:16] = buffer_data_0[919:912];
        layer0[50][7:0] = buffer_data_2[911:904];
        layer0[50][15:8] = buffer_data_2[919:912];
        layer0[50][23:16] = buffer_data_2[927:920];
        layer1[50][7:0] = buffer_data_1[911:904];
        layer1[50][15:8] = buffer_data_1[919:912];
        layer1[50][23:16] = buffer_data_1[927:920];
        layer2[50][7:0] = buffer_data_0[911:904];
        layer2[50][15:8] = buffer_data_0[919:912];
        layer2[50][23:16] = buffer_data_0[927:920];
        layer0[51][7:0] = buffer_data_2[919:912];
        layer0[51][15:8] = buffer_data_2[927:920];
        layer0[51][23:16] = buffer_data_2[935:928];
        layer1[51][7:0] = buffer_data_1[919:912];
        layer1[51][15:8] = buffer_data_1[927:920];
        layer1[51][23:16] = buffer_data_1[935:928];
        layer2[51][7:0] = buffer_data_0[919:912];
        layer2[51][15:8] = buffer_data_0[927:920];
        layer2[51][23:16] = buffer_data_0[935:928];
        layer0[52][7:0] = buffer_data_2[927:920];
        layer0[52][15:8] = buffer_data_2[935:928];
        layer0[52][23:16] = buffer_data_2[943:936];
        layer1[52][7:0] = buffer_data_1[927:920];
        layer1[52][15:8] = buffer_data_1[935:928];
        layer1[52][23:16] = buffer_data_1[943:936];
        layer2[52][7:0] = buffer_data_0[927:920];
        layer2[52][15:8] = buffer_data_0[935:928];
        layer2[52][23:16] = buffer_data_0[943:936];
        layer0[53][7:0] = buffer_data_2[935:928];
        layer0[53][15:8] = buffer_data_2[943:936];
        layer0[53][23:16] = buffer_data_2[951:944];
        layer1[53][7:0] = buffer_data_1[935:928];
        layer1[53][15:8] = buffer_data_1[943:936];
        layer1[53][23:16] = buffer_data_1[951:944];
        layer2[53][7:0] = buffer_data_0[935:928];
        layer2[53][15:8] = buffer_data_0[943:936];
        layer2[53][23:16] = buffer_data_0[951:944];
        layer0[54][7:0] = buffer_data_2[943:936];
        layer0[54][15:8] = buffer_data_2[951:944];
        layer0[54][23:16] = buffer_data_2[959:952];
        layer1[54][7:0] = buffer_data_1[943:936];
        layer1[54][15:8] = buffer_data_1[951:944];
        layer1[54][23:16] = buffer_data_1[959:952];
        layer2[54][7:0] = buffer_data_0[943:936];
        layer2[54][15:8] = buffer_data_0[951:944];
        layer2[54][23:16] = buffer_data_0[959:952];
        layer0[55][7:0] = buffer_data_2[951:944];
        layer0[55][15:8] = buffer_data_2[959:952];
        layer0[55][23:16] = buffer_data_2[967:960];
        layer1[55][7:0] = buffer_data_1[951:944];
        layer1[55][15:8] = buffer_data_1[959:952];
        layer1[55][23:16] = buffer_data_1[967:960];
        layer2[55][7:0] = buffer_data_0[951:944];
        layer2[55][15:8] = buffer_data_0[959:952];
        layer2[55][23:16] = buffer_data_0[967:960];
        layer0[56][7:0] = buffer_data_2[959:952];
        layer0[56][15:8] = buffer_data_2[967:960];
        layer0[56][23:16] = buffer_data_2[975:968];
        layer1[56][7:0] = buffer_data_1[959:952];
        layer1[56][15:8] = buffer_data_1[967:960];
        layer1[56][23:16] = buffer_data_1[975:968];
        layer2[56][7:0] = buffer_data_0[959:952];
        layer2[56][15:8] = buffer_data_0[967:960];
        layer2[56][23:16] = buffer_data_0[975:968];
        layer0[57][7:0] = buffer_data_2[967:960];
        layer0[57][15:8] = buffer_data_2[975:968];
        layer0[57][23:16] = buffer_data_2[983:976];
        layer1[57][7:0] = buffer_data_1[967:960];
        layer1[57][15:8] = buffer_data_1[975:968];
        layer1[57][23:16] = buffer_data_1[983:976];
        layer2[57][7:0] = buffer_data_0[967:960];
        layer2[57][15:8] = buffer_data_0[975:968];
        layer2[57][23:16] = buffer_data_0[983:976];
        layer0[58][7:0] = buffer_data_2[975:968];
        layer0[58][15:8] = buffer_data_2[983:976];
        layer0[58][23:16] = buffer_data_2[991:984];
        layer1[58][7:0] = buffer_data_1[975:968];
        layer1[58][15:8] = buffer_data_1[983:976];
        layer1[58][23:16] = buffer_data_1[991:984];
        layer2[58][7:0] = buffer_data_0[975:968];
        layer2[58][15:8] = buffer_data_0[983:976];
        layer2[58][23:16] = buffer_data_0[991:984];
        layer0[59][7:0] = buffer_data_2[983:976];
        layer0[59][15:8] = buffer_data_2[991:984];
        layer0[59][23:16] = buffer_data_2[999:992];
        layer1[59][7:0] = buffer_data_1[983:976];
        layer1[59][15:8] = buffer_data_1[991:984];
        layer1[59][23:16] = buffer_data_1[999:992];
        layer2[59][7:0] = buffer_data_0[983:976];
        layer2[59][15:8] = buffer_data_0[991:984];
        layer2[59][23:16] = buffer_data_0[999:992];
        layer0[60][7:0] = buffer_data_2[991:984];
        layer0[60][15:8] = buffer_data_2[999:992];
        layer0[60][23:16] = buffer_data_2[1007:1000];
        layer1[60][7:0] = buffer_data_1[991:984];
        layer1[60][15:8] = buffer_data_1[999:992];
        layer1[60][23:16] = buffer_data_1[1007:1000];
        layer2[60][7:0] = buffer_data_0[991:984];
        layer2[60][15:8] = buffer_data_0[999:992];
        layer2[60][23:16] = buffer_data_0[1007:1000];
        layer0[61][7:0] = buffer_data_2[999:992];
        layer0[61][15:8] = buffer_data_2[1007:1000];
        layer0[61][23:16] = buffer_data_2[1015:1008];
        layer1[61][7:0] = buffer_data_1[999:992];
        layer1[61][15:8] = buffer_data_1[1007:1000];
        layer1[61][23:16] = buffer_data_1[1015:1008];
        layer2[61][7:0] = buffer_data_0[999:992];
        layer2[61][15:8] = buffer_data_0[1007:1000];
        layer2[61][23:16] = buffer_data_0[1015:1008];
        layer0[62][7:0] = buffer_data_2[1007:1000];
        layer0[62][15:8] = buffer_data_2[1015:1008];
        layer0[62][23:16] = buffer_data_2[1023:1016];
        layer1[62][7:0] = buffer_data_1[1007:1000];
        layer1[62][15:8] = buffer_data_1[1015:1008];
        layer1[62][23:16] = buffer_data_1[1023:1016];
        layer2[62][7:0] = buffer_data_0[1007:1000];
        layer2[62][15:8] = buffer_data_0[1015:1008];
        layer2[62][23:16] = buffer_data_0[1023:1016];
        layer0[63][7:0] = buffer_data_2[1015:1008];
        layer0[63][15:8] = buffer_data_2[1023:1016];
        layer0[63][23:16] = buffer_data_2[1031:1024];
        layer1[63][7:0] = buffer_data_1[1015:1008];
        layer1[63][15:8] = buffer_data_1[1023:1016];
        layer1[63][23:16] = buffer_data_1[1031:1024];
        layer2[63][7:0] = buffer_data_0[1015:1008];
        layer2[63][15:8] = buffer_data_0[1023:1016];
        layer2[63][23:16] = buffer_data_0[1031:1024];
    end
    ST_GAUSSIAN_2: begin
        layer0[0][7:0] = buffer_data_2[1023:1016];
        layer0[0][15:8] = buffer_data_2[1031:1024];
        layer0[0][23:16] = buffer_data_2[1039:1032];
        layer1[0][7:0] = buffer_data_1[1023:1016];
        layer1[0][15:8] = buffer_data_1[1031:1024];
        layer1[0][23:16] = buffer_data_1[1039:1032];
        layer2[0][7:0] = buffer_data_0[1023:1016];
        layer2[0][15:8] = buffer_data_0[1031:1024];
        layer2[0][23:16] = buffer_data_0[1039:1032];
        layer0[1][7:0] = buffer_data_2[1031:1024];
        layer0[1][15:8] = buffer_data_2[1039:1032];
        layer0[1][23:16] = buffer_data_2[1047:1040];
        layer1[1][7:0] = buffer_data_1[1031:1024];
        layer1[1][15:8] = buffer_data_1[1039:1032];
        layer1[1][23:16] = buffer_data_1[1047:1040];
        layer2[1][7:0] = buffer_data_0[1031:1024];
        layer2[1][15:8] = buffer_data_0[1039:1032];
        layer2[1][23:16] = buffer_data_0[1047:1040];
        layer0[2][7:0] = buffer_data_2[1039:1032];
        layer0[2][15:8] = buffer_data_2[1047:1040];
        layer0[2][23:16] = buffer_data_2[1055:1048];
        layer1[2][7:0] = buffer_data_1[1039:1032];
        layer1[2][15:8] = buffer_data_1[1047:1040];
        layer1[2][23:16] = buffer_data_1[1055:1048];
        layer2[2][7:0] = buffer_data_0[1039:1032];
        layer2[2][15:8] = buffer_data_0[1047:1040];
        layer2[2][23:16] = buffer_data_0[1055:1048];
        layer0[3][7:0] = buffer_data_2[1047:1040];
        layer0[3][15:8] = buffer_data_2[1055:1048];
        layer0[3][23:16] = buffer_data_2[1063:1056];
        layer1[3][7:0] = buffer_data_1[1047:1040];
        layer1[3][15:8] = buffer_data_1[1055:1048];
        layer1[3][23:16] = buffer_data_1[1063:1056];
        layer2[3][7:0] = buffer_data_0[1047:1040];
        layer2[3][15:8] = buffer_data_0[1055:1048];
        layer2[3][23:16] = buffer_data_0[1063:1056];
        layer0[4][7:0] = buffer_data_2[1055:1048];
        layer0[4][15:8] = buffer_data_2[1063:1056];
        layer0[4][23:16] = buffer_data_2[1071:1064];
        layer1[4][7:0] = buffer_data_1[1055:1048];
        layer1[4][15:8] = buffer_data_1[1063:1056];
        layer1[4][23:16] = buffer_data_1[1071:1064];
        layer2[4][7:0] = buffer_data_0[1055:1048];
        layer2[4][15:8] = buffer_data_0[1063:1056];
        layer2[4][23:16] = buffer_data_0[1071:1064];
        layer0[5][7:0] = buffer_data_2[1063:1056];
        layer0[5][15:8] = buffer_data_2[1071:1064];
        layer0[5][23:16] = buffer_data_2[1079:1072];
        layer1[5][7:0] = buffer_data_1[1063:1056];
        layer1[5][15:8] = buffer_data_1[1071:1064];
        layer1[5][23:16] = buffer_data_1[1079:1072];
        layer2[5][7:0] = buffer_data_0[1063:1056];
        layer2[5][15:8] = buffer_data_0[1071:1064];
        layer2[5][23:16] = buffer_data_0[1079:1072];
        layer0[6][7:0] = buffer_data_2[1071:1064];
        layer0[6][15:8] = buffer_data_2[1079:1072];
        layer0[6][23:16] = buffer_data_2[1087:1080];
        layer1[6][7:0] = buffer_data_1[1071:1064];
        layer1[6][15:8] = buffer_data_1[1079:1072];
        layer1[6][23:16] = buffer_data_1[1087:1080];
        layer2[6][7:0] = buffer_data_0[1071:1064];
        layer2[6][15:8] = buffer_data_0[1079:1072];
        layer2[6][23:16] = buffer_data_0[1087:1080];
        layer0[7][7:0] = buffer_data_2[1079:1072];
        layer0[7][15:8] = buffer_data_2[1087:1080];
        layer0[7][23:16] = buffer_data_2[1095:1088];
        layer1[7][7:0] = buffer_data_1[1079:1072];
        layer1[7][15:8] = buffer_data_1[1087:1080];
        layer1[7][23:16] = buffer_data_1[1095:1088];
        layer2[7][7:0] = buffer_data_0[1079:1072];
        layer2[7][15:8] = buffer_data_0[1087:1080];
        layer2[7][23:16] = buffer_data_0[1095:1088];
        layer0[8][7:0] = buffer_data_2[1087:1080];
        layer0[8][15:8] = buffer_data_2[1095:1088];
        layer0[8][23:16] = buffer_data_2[1103:1096];
        layer1[8][7:0] = buffer_data_1[1087:1080];
        layer1[8][15:8] = buffer_data_1[1095:1088];
        layer1[8][23:16] = buffer_data_1[1103:1096];
        layer2[8][7:0] = buffer_data_0[1087:1080];
        layer2[8][15:8] = buffer_data_0[1095:1088];
        layer2[8][23:16] = buffer_data_0[1103:1096];
        layer0[9][7:0] = buffer_data_2[1095:1088];
        layer0[9][15:8] = buffer_data_2[1103:1096];
        layer0[9][23:16] = buffer_data_2[1111:1104];
        layer1[9][7:0] = buffer_data_1[1095:1088];
        layer1[9][15:8] = buffer_data_1[1103:1096];
        layer1[9][23:16] = buffer_data_1[1111:1104];
        layer2[9][7:0] = buffer_data_0[1095:1088];
        layer2[9][15:8] = buffer_data_0[1103:1096];
        layer2[9][23:16] = buffer_data_0[1111:1104];
        layer0[10][7:0] = buffer_data_2[1103:1096];
        layer0[10][15:8] = buffer_data_2[1111:1104];
        layer0[10][23:16] = buffer_data_2[1119:1112];
        layer1[10][7:0] = buffer_data_1[1103:1096];
        layer1[10][15:8] = buffer_data_1[1111:1104];
        layer1[10][23:16] = buffer_data_1[1119:1112];
        layer2[10][7:0] = buffer_data_0[1103:1096];
        layer2[10][15:8] = buffer_data_0[1111:1104];
        layer2[10][23:16] = buffer_data_0[1119:1112];
        layer0[11][7:0] = buffer_data_2[1111:1104];
        layer0[11][15:8] = buffer_data_2[1119:1112];
        layer0[11][23:16] = buffer_data_2[1127:1120];
        layer1[11][7:0] = buffer_data_1[1111:1104];
        layer1[11][15:8] = buffer_data_1[1119:1112];
        layer1[11][23:16] = buffer_data_1[1127:1120];
        layer2[11][7:0] = buffer_data_0[1111:1104];
        layer2[11][15:8] = buffer_data_0[1119:1112];
        layer2[11][23:16] = buffer_data_0[1127:1120];
        layer0[12][7:0] = buffer_data_2[1119:1112];
        layer0[12][15:8] = buffer_data_2[1127:1120];
        layer0[12][23:16] = buffer_data_2[1135:1128];
        layer1[12][7:0] = buffer_data_1[1119:1112];
        layer1[12][15:8] = buffer_data_1[1127:1120];
        layer1[12][23:16] = buffer_data_1[1135:1128];
        layer2[12][7:0] = buffer_data_0[1119:1112];
        layer2[12][15:8] = buffer_data_0[1127:1120];
        layer2[12][23:16] = buffer_data_0[1135:1128];
        layer0[13][7:0] = buffer_data_2[1127:1120];
        layer0[13][15:8] = buffer_data_2[1135:1128];
        layer0[13][23:16] = buffer_data_2[1143:1136];
        layer1[13][7:0] = buffer_data_1[1127:1120];
        layer1[13][15:8] = buffer_data_1[1135:1128];
        layer1[13][23:16] = buffer_data_1[1143:1136];
        layer2[13][7:0] = buffer_data_0[1127:1120];
        layer2[13][15:8] = buffer_data_0[1135:1128];
        layer2[13][23:16] = buffer_data_0[1143:1136];
        layer0[14][7:0] = buffer_data_2[1135:1128];
        layer0[14][15:8] = buffer_data_2[1143:1136];
        layer0[14][23:16] = buffer_data_2[1151:1144];
        layer1[14][7:0] = buffer_data_1[1135:1128];
        layer1[14][15:8] = buffer_data_1[1143:1136];
        layer1[14][23:16] = buffer_data_1[1151:1144];
        layer2[14][7:0] = buffer_data_0[1135:1128];
        layer2[14][15:8] = buffer_data_0[1143:1136];
        layer2[14][23:16] = buffer_data_0[1151:1144];
        layer0[15][7:0] = buffer_data_2[1143:1136];
        layer0[15][15:8] = buffer_data_2[1151:1144];
        layer0[15][23:16] = buffer_data_2[1159:1152];
        layer1[15][7:0] = buffer_data_1[1143:1136];
        layer1[15][15:8] = buffer_data_1[1151:1144];
        layer1[15][23:16] = buffer_data_1[1159:1152];
        layer2[15][7:0] = buffer_data_0[1143:1136];
        layer2[15][15:8] = buffer_data_0[1151:1144];
        layer2[15][23:16] = buffer_data_0[1159:1152];
        layer0[16][7:0] = buffer_data_2[1151:1144];
        layer0[16][15:8] = buffer_data_2[1159:1152];
        layer0[16][23:16] = buffer_data_2[1167:1160];
        layer1[16][7:0] = buffer_data_1[1151:1144];
        layer1[16][15:8] = buffer_data_1[1159:1152];
        layer1[16][23:16] = buffer_data_1[1167:1160];
        layer2[16][7:0] = buffer_data_0[1151:1144];
        layer2[16][15:8] = buffer_data_0[1159:1152];
        layer2[16][23:16] = buffer_data_0[1167:1160];
        layer0[17][7:0] = buffer_data_2[1159:1152];
        layer0[17][15:8] = buffer_data_2[1167:1160];
        layer0[17][23:16] = buffer_data_2[1175:1168];
        layer1[17][7:0] = buffer_data_1[1159:1152];
        layer1[17][15:8] = buffer_data_1[1167:1160];
        layer1[17][23:16] = buffer_data_1[1175:1168];
        layer2[17][7:0] = buffer_data_0[1159:1152];
        layer2[17][15:8] = buffer_data_0[1167:1160];
        layer2[17][23:16] = buffer_data_0[1175:1168];
        layer0[18][7:0] = buffer_data_2[1167:1160];
        layer0[18][15:8] = buffer_data_2[1175:1168];
        layer0[18][23:16] = buffer_data_2[1183:1176];
        layer1[18][7:0] = buffer_data_1[1167:1160];
        layer1[18][15:8] = buffer_data_1[1175:1168];
        layer1[18][23:16] = buffer_data_1[1183:1176];
        layer2[18][7:0] = buffer_data_0[1167:1160];
        layer2[18][15:8] = buffer_data_0[1175:1168];
        layer2[18][23:16] = buffer_data_0[1183:1176];
        layer0[19][7:0] = buffer_data_2[1175:1168];
        layer0[19][15:8] = buffer_data_2[1183:1176];
        layer0[19][23:16] = buffer_data_2[1191:1184];
        layer1[19][7:0] = buffer_data_1[1175:1168];
        layer1[19][15:8] = buffer_data_1[1183:1176];
        layer1[19][23:16] = buffer_data_1[1191:1184];
        layer2[19][7:0] = buffer_data_0[1175:1168];
        layer2[19][15:8] = buffer_data_0[1183:1176];
        layer2[19][23:16] = buffer_data_0[1191:1184];
        layer0[20][7:0] = buffer_data_2[1183:1176];
        layer0[20][15:8] = buffer_data_2[1191:1184];
        layer0[20][23:16] = buffer_data_2[1199:1192];
        layer1[20][7:0] = buffer_data_1[1183:1176];
        layer1[20][15:8] = buffer_data_1[1191:1184];
        layer1[20][23:16] = buffer_data_1[1199:1192];
        layer2[20][7:0] = buffer_data_0[1183:1176];
        layer2[20][15:8] = buffer_data_0[1191:1184];
        layer2[20][23:16] = buffer_data_0[1199:1192];
        layer0[21][7:0] = buffer_data_2[1191:1184];
        layer0[21][15:8] = buffer_data_2[1199:1192];
        layer0[21][23:16] = buffer_data_2[1207:1200];
        layer1[21][7:0] = buffer_data_1[1191:1184];
        layer1[21][15:8] = buffer_data_1[1199:1192];
        layer1[21][23:16] = buffer_data_1[1207:1200];
        layer2[21][7:0] = buffer_data_0[1191:1184];
        layer2[21][15:8] = buffer_data_0[1199:1192];
        layer2[21][23:16] = buffer_data_0[1207:1200];
        layer0[22][7:0] = buffer_data_2[1199:1192];
        layer0[22][15:8] = buffer_data_2[1207:1200];
        layer0[22][23:16] = buffer_data_2[1215:1208];
        layer1[22][7:0] = buffer_data_1[1199:1192];
        layer1[22][15:8] = buffer_data_1[1207:1200];
        layer1[22][23:16] = buffer_data_1[1215:1208];
        layer2[22][7:0] = buffer_data_0[1199:1192];
        layer2[22][15:8] = buffer_data_0[1207:1200];
        layer2[22][23:16] = buffer_data_0[1215:1208];
        layer0[23][7:0] = buffer_data_2[1207:1200];
        layer0[23][15:8] = buffer_data_2[1215:1208];
        layer0[23][23:16] = buffer_data_2[1223:1216];
        layer1[23][7:0] = buffer_data_1[1207:1200];
        layer1[23][15:8] = buffer_data_1[1215:1208];
        layer1[23][23:16] = buffer_data_1[1223:1216];
        layer2[23][7:0] = buffer_data_0[1207:1200];
        layer2[23][15:8] = buffer_data_0[1215:1208];
        layer2[23][23:16] = buffer_data_0[1223:1216];
        layer0[24][7:0] = buffer_data_2[1215:1208];
        layer0[24][15:8] = buffer_data_2[1223:1216];
        layer0[24][23:16] = buffer_data_2[1231:1224];
        layer1[24][7:0] = buffer_data_1[1215:1208];
        layer1[24][15:8] = buffer_data_1[1223:1216];
        layer1[24][23:16] = buffer_data_1[1231:1224];
        layer2[24][7:0] = buffer_data_0[1215:1208];
        layer2[24][15:8] = buffer_data_0[1223:1216];
        layer2[24][23:16] = buffer_data_0[1231:1224];
        layer0[25][7:0] = buffer_data_2[1223:1216];
        layer0[25][15:8] = buffer_data_2[1231:1224];
        layer0[25][23:16] = buffer_data_2[1239:1232];
        layer1[25][7:0] = buffer_data_1[1223:1216];
        layer1[25][15:8] = buffer_data_1[1231:1224];
        layer1[25][23:16] = buffer_data_1[1239:1232];
        layer2[25][7:0] = buffer_data_0[1223:1216];
        layer2[25][15:8] = buffer_data_0[1231:1224];
        layer2[25][23:16] = buffer_data_0[1239:1232];
        layer0[26][7:0] = buffer_data_2[1231:1224];
        layer0[26][15:8] = buffer_data_2[1239:1232];
        layer0[26][23:16] = buffer_data_2[1247:1240];
        layer1[26][7:0] = buffer_data_1[1231:1224];
        layer1[26][15:8] = buffer_data_1[1239:1232];
        layer1[26][23:16] = buffer_data_1[1247:1240];
        layer2[26][7:0] = buffer_data_0[1231:1224];
        layer2[26][15:8] = buffer_data_0[1239:1232];
        layer2[26][23:16] = buffer_data_0[1247:1240];
        layer0[27][7:0] = buffer_data_2[1239:1232];
        layer0[27][15:8] = buffer_data_2[1247:1240];
        layer0[27][23:16] = buffer_data_2[1255:1248];
        layer1[27][7:0] = buffer_data_1[1239:1232];
        layer1[27][15:8] = buffer_data_1[1247:1240];
        layer1[27][23:16] = buffer_data_1[1255:1248];
        layer2[27][7:0] = buffer_data_0[1239:1232];
        layer2[27][15:8] = buffer_data_0[1247:1240];
        layer2[27][23:16] = buffer_data_0[1255:1248];
        layer0[28][7:0] = buffer_data_2[1247:1240];
        layer0[28][15:8] = buffer_data_2[1255:1248];
        layer0[28][23:16] = buffer_data_2[1263:1256];
        layer1[28][7:0] = buffer_data_1[1247:1240];
        layer1[28][15:8] = buffer_data_1[1255:1248];
        layer1[28][23:16] = buffer_data_1[1263:1256];
        layer2[28][7:0] = buffer_data_0[1247:1240];
        layer2[28][15:8] = buffer_data_0[1255:1248];
        layer2[28][23:16] = buffer_data_0[1263:1256];
        layer0[29][7:0] = buffer_data_2[1255:1248];
        layer0[29][15:8] = buffer_data_2[1263:1256];
        layer0[29][23:16] = buffer_data_2[1271:1264];
        layer1[29][7:0] = buffer_data_1[1255:1248];
        layer1[29][15:8] = buffer_data_1[1263:1256];
        layer1[29][23:16] = buffer_data_1[1271:1264];
        layer2[29][7:0] = buffer_data_0[1255:1248];
        layer2[29][15:8] = buffer_data_0[1263:1256];
        layer2[29][23:16] = buffer_data_0[1271:1264];
        layer0[30][7:0] = buffer_data_2[1263:1256];
        layer0[30][15:8] = buffer_data_2[1271:1264];
        layer0[30][23:16] = buffer_data_2[1279:1272];
        layer1[30][7:0] = buffer_data_1[1263:1256];
        layer1[30][15:8] = buffer_data_1[1271:1264];
        layer1[30][23:16] = buffer_data_1[1279:1272];
        layer2[30][7:0] = buffer_data_0[1263:1256];
        layer2[30][15:8] = buffer_data_0[1271:1264];
        layer2[30][23:16] = buffer_data_0[1279:1272];
        layer0[31][7:0] = buffer_data_2[1271:1264];
        layer0[31][15:8] = buffer_data_2[1279:1272];
        layer0[31][23:16] = buffer_data_2[1287:1280];
        layer1[31][7:0] = buffer_data_1[1271:1264];
        layer1[31][15:8] = buffer_data_1[1279:1272];
        layer1[31][23:16] = buffer_data_1[1287:1280];
        layer2[31][7:0] = buffer_data_0[1271:1264];
        layer2[31][15:8] = buffer_data_0[1279:1272];
        layer2[31][23:16] = buffer_data_0[1287:1280];
        layer0[32][7:0] = buffer_data_2[1279:1272];
        layer0[32][15:8] = buffer_data_2[1287:1280];
        layer0[32][23:16] = buffer_data_2[1295:1288];
        layer1[32][7:0] = buffer_data_1[1279:1272];
        layer1[32][15:8] = buffer_data_1[1287:1280];
        layer1[32][23:16] = buffer_data_1[1295:1288];
        layer2[32][7:0] = buffer_data_0[1279:1272];
        layer2[32][15:8] = buffer_data_0[1287:1280];
        layer2[32][23:16] = buffer_data_0[1295:1288];
        layer0[33][7:0] = buffer_data_2[1287:1280];
        layer0[33][15:8] = buffer_data_2[1295:1288];
        layer0[33][23:16] = buffer_data_2[1303:1296];
        layer1[33][7:0] = buffer_data_1[1287:1280];
        layer1[33][15:8] = buffer_data_1[1295:1288];
        layer1[33][23:16] = buffer_data_1[1303:1296];
        layer2[33][7:0] = buffer_data_0[1287:1280];
        layer2[33][15:8] = buffer_data_0[1295:1288];
        layer2[33][23:16] = buffer_data_0[1303:1296];
        layer0[34][7:0] = buffer_data_2[1295:1288];
        layer0[34][15:8] = buffer_data_2[1303:1296];
        layer0[34][23:16] = buffer_data_2[1311:1304];
        layer1[34][7:0] = buffer_data_1[1295:1288];
        layer1[34][15:8] = buffer_data_1[1303:1296];
        layer1[34][23:16] = buffer_data_1[1311:1304];
        layer2[34][7:0] = buffer_data_0[1295:1288];
        layer2[34][15:8] = buffer_data_0[1303:1296];
        layer2[34][23:16] = buffer_data_0[1311:1304];
        layer0[35][7:0] = buffer_data_2[1303:1296];
        layer0[35][15:8] = buffer_data_2[1311:1304];
        layer0[35][23:16] = buffer_data_2[1319:1312];
        layer1[35][7:0] = buffer_data_1[1303:1296];
        layer1[35][15:8] = buffer_data_1[1311:1304];
        layer1[35][23:16] = buffer_data_1[1319:1312];
        layer2[35][7:0] = buffer_data_0[1303:1296];
        layer2[35][15:8] = buffer_data_0[1311:1304];
        layer2[35][23:16] = buffer_data_0[1319:1312];
        layer0[36][7:0] = buffer_data_2[1311:1304];
        layer0[36][15:8] = buffer_data_2[1319:1312];
        layer0[36][23:16] = buffer_data_2[1327:1320];
        layer1[36][7:0] = buffer_data_1[1311:1304];
        layer1[36][15:8] = buffer_data_1[1319:1312];
        layer1[36][23:16] = buffer_data_1[1327:1320];
        layer2[36][7:0] = buffer_data_0[1311:1304];
        layer2[36][15:8] = buffer_data_0[1319:1312];
        layer2[36][23:16] = buffer_data_0[1327:1320];
        layer0[37][7:0] = buffer_data_2[1319:1312];
        layer0[37][15:8] = buffer_data_2[1327:1320];
        layer0[37][23:16] = buffer_data_2[1335:1328];
        layer1[37][7:0] = buffer_data_1[1319:1312];
        layer1[37][15:8] = buffer_data_1[1327:1320];
        layer1[37][23:16] = buffer_data_1[1335:1328];
        layer2[37][7:0] = buffer_data_0[1319:1312];
        layer2[37][15:8] = buffer_data_0[1327:1320];
        layer2[37][23:16] = buffer_data_0[1335:1328];
        layer0[38][7:0] = buffer_data_2[1327:1320];
        layer0[38][15:8] = buffer_data_2[1335:1328];
        layer0[38][23:16] = buffer_data_2[1343:1336];
        layer1[38][7:0] = buffer_data_1[1327:1320];
        layer1[38][15:8] = buffer_data_1[1335:1328];
        layer1[38][23:16] = buffer_data_1[1343:1336];
        layer2[38][7:0] = buffer_data_0[1327:1320];
        layer2[38][15:8] = buffer_data_0[1335:1328];
        layer2[38][23:16] = buffer_data_0[1343:1336];
        layer0[39][7:0] = buffer_data_2[1335:1328];
        layer0[39][15:8] = buffer_data_2[1343:1336];
        layer0[39][23:16] = buffer_data_2[1351:1344];
        layer1[39][7:0] = buffer_data_1[1335:1328];
        layer1[39][15:8] = buffer_data_1[1343:1336];
        layer1[39][23:16] = buffer_data_1[1351:1344];
        layer2[39][7:0] = buffer_data_0[1335:1328];
        layer2[39][15:8] = buffer_data_0[1343:1336];
        layer2[39][23:16] = buffer_data_0[1351:1344];
        layer0[40][7:0] = buffer_data_2[1343:1336];
        layer0[40][15:8] = buffer_data_2[1351:1344];
        layer0[40][23:16] = buffer_data_2[1359:1352];
        layer1[40][7:0] = buffer_data_1[1343:1336];
        layer1[40][15:8] = buffer_data_1[1351:1344];
        layer1[40][23:16] = buffer_data_1[1359:1352];
        layer2[40][7:0] = buffer_data_0[1343:1336];
        layer2[40][15:8] = buffer_data_0[1351:1344];
        layer2[40][23:16] = buffer_data_0[1359:1352];
        layer0[41][7:0] = buffer_data_2[1351:1344];
        layer0[41][15:8] = buffer_data_2[1359:1352];
        layer0[41][23:16] = buffer_data_2[1367:1360];
        layer1[41][7:0] = buffer_data_1[1351:1344];
        layer1[41][15:8] = buffer_data_1[1359:1352];
        layer1[41][23:16] = buffer_data_1[1367:1360];
        layer2[41][7:0] = buffer_data_0[1351:1344];
        layer2[41][15:8] = buffer_data_0[1359:1352];
        layer2[41][23:16] = buffer_data_0[1367:1360];
        layer0[42][7:0] = buffer_data_2[1359:1352];
        layer0[42][15:8] = buffer_data_2[1367:1360];
        layer0[42][23:16] = buffer_data_2[1375:1368];
        layer1[42][7:0] = buffer_data_1[1359:1352];
        layer1[42][15:8] = buffer_data_1[1367:1360];
        layer1[42][23:16] = buffer_data_1[1375:1368];
        layer2[42][7:0] = buffer_data_0[1359:1352];
        layer2[42][15:8] = buffer_data_0[1367:1360];
        layer2[42][23:16] = buffer_data_0[1375:1368];
        layer0[43][7:0] = buffer_data_2[1367:1360];
        layer0[43][15:8] = buffer_data_2[1375:1368];
        layer0[43][23:16] = buffer_data_2[1383:1376];
        layer1[43][7:0] = buffer_data_1[1367:1360];
        layer1[43][15:8] = buffer_data_1[1375:1368];
        layer1[43][23:16] = buffer_data_1[1383:1376];
        layer2[43][7:0] = buffer_data_0[1367:1360];
        layer2[43][15:8] = buffer_data_0[1375:1368];
        layer2[43][23:16] = buffer_data_0[1383:1376];
        layer0[44][7:0] = buffer_data_2[1375:1368];
        layer0[44][15:8] = buffer_data_2[1383:1376];
        layer0[44][23:16] = buffer_data_2[1391:1384];
        layer1[44][7:0] = buffer_data_1[1375:1368];
        layer1[44][15:8] = buffer_data_1[1383:1376];
        layer1[44][23:16] = buffer_data_1[1391:1384];
        layer2[44][7:0] = buffer_data_0[1375:1368];
        layer2[44][15:8] = buffer_data_0[1383:1376];
        layer2[44][23:16] = buffer_data_0[1391:1384];
        layer0[45][7:0] = buffer_data_2[1383:1376];
        layer0[45][15:8] = buffer_data_2[1391:1384];
        layer0[45][23:16] = buffer_data_2[1399:1392];
        layer1[45][7:0] = buffer_data_1[1383:1376];
        layer1[45][15:8] = buffer_data_1[1391:1384];
        layer1[45][23:16] = buffer_data_1[1399:1392];
        layer2[45][7:0] = buffer_data_0[1383:1376];
        layer2[45][15:8] = buffer_data_0[1391:1384];
        layer2[45][23:16] = buffer_data_0[1399:1392];
        layer0[46][7:0] = buffer_data_2[1391:1384];
        layer0[46][15:8] = buffer_data_2[1399:1392];
        layer0[46][23:16] = buffer_data_2[1407:1400];
        layer1[46][7:0] = buffer_data_1[1391:1384];
        layer1[46][15:8] = buffer_data_1[1399:1392];
        layer1[46][23:16] = buffer_data_1[1407:1400];
        layer2[46][7:0] = buffer_data_0[1391:1384];
        layer2[46][15:8] = buffer_data_0[1399:1392];
        layer2[46][23:16] = buffer_data_0[1407:1400];
        layer0[47][7:0] = buffer_data_2[1399:1392];
        layer0[47][15:8] = buffer_data_2[1407:1400];
        layer0[47][23:16] = buffer_data_2[1415:1408];
        layer1[47][7:0] = buffer_data_1[1399:1392];
        layer1[47][15:8] = buffer_data_1[1407:1400];
        layer1[47][23:16] = buffer_data_1[1415:1408];
        layer2[47][7:0] = buffer_data_0[1399:1392];
        layer2[47][15:8] = buffer_data_0[1407:1400];
        layer2[47][23:16] = buffer_data_0[1415:1408];
        layer0[48][7:0] = buffer_data_2[1407:1400];
        layer0[48][15:8] = buffer_data_2[1415:1408];
        layer0[48][23:16] = buffer_data_2[1423:1416];
        layer1[48][7:0] = buffer_data_1[1407:1400];
        layer1[48][15:8] = buffer_data_1[1415:1408];
        layer1[48][23:16] = buffer_data_1[1423:1416];
        layer2[48][7:0] = buffer_data_0[1407:1400];
        layer2[48][15:8] = buffer_data_0[1415:1408];
        layer2[48][23:16] = buffer_data_0[1423:1416];
        layer0[49][7:0] = buffer_data_2[1415:1408];
        layer0[49][15:8] = buffer_data_2[1423:1416];
        layer0[49][23:16] = buffer_data_2[1431:1424];
        layer1[49][7:0] = buffer_data_1[1415:1408];
        layer1[49][15:8] = buffer_data_1[1423:1416];
        layer1[49][23:16] = buffer_data_1[1431:1424];
        layer2[49][7:0] = buffer_data_0[1415:1408];
        layer2[49][15:8] = buffer_data_0[1423:1416];
        layer2[49][23:16] = buffer_data_0[1431:1424];
        layer0[50][7:0] = buffer_data_2[1423:1416];
        layer0[50][15:8] = buffer_data_2[1431:1424];
        layer0[50][23:16] = buffer_data_2[1439:1432];
        layer1[50][7:0] = buffer_data_1[1423:1416];
        layer1[50][15:8] = buffer_data_1[1431:1424];
        layer1[50][23:16] = buffer_data_1[1439:1432];
        layer2[50][7:0] = buffer_data_0[1423:1416];
        layer2[50][15:8] = buffer_data_0[1431:1424];
        layer2[50][23:16] = buffer_data_0[1439:1432];
        layer0[51][7:0] = buffer_data_2[1431:1424];
        layer0[51][15:8] = buffer_data_2[1439:1432];
        layer0[51][23:16] = buffer_data_2[1447:1440];
        layer1[51][7:0] = buffer_data_1[1431:1424];
        layer1[51][15:8] = buffer_data_1[1439:1432];
        layer1[51][23:16] = buffer_data_1[1447:1440];
        layer2[51][7:0] = buffer_data_0[1431:1424];
        layer2[51][15:8] = buffer_data_0[1439:1432];
        layer2[51][23:16] = buffer_data_0[1447:1440];
        layer0[52][7:0] = buffer_data_2[1439:1432];
        layer0[52][15:8] = buffer_data_2[1447:1440];
        layer0[52][23:16] = buffer_data_2[1455:1448];
        layer1[52][7:0] = buffer_data_1[1439:1432];
        layer1[52][15:8] = buffer_data_1[1447:1440];
        layer1[52][23:16] = buffer_data_1[1455:1448];
        layer2[52][7:0] = buffer_data_0[1439:1432];
        layer2[52][15:8] = buffer_data_0[1447:1440];
        layer2[52][23:16] = buffer_data_0[1455:1448];
        layer0[53][7:0] = buffer_data_2[1447:1440];
        layer0[53][15:8] = buffer_data_2[1455:1448];
        layer0[53][23:16] = buffer_data_2[1463:1456];
        layer1[53][7:0] = buffer_data_1[1447:1440];
        layer1[53][15:8] = buffer_data_1[1455:1448];
        layer1[53][23:16] = buffer_data_1[1463:1456];
        layer2[53][7:0] = buffer_data_0[1447:1440];
        layer2[53][15:8] = buffer_data_0[1455:1448];
        layer2[53][23:16] = buffer_data_0[1463:1456];
        layer0[54][7:0] = buffer_data_2[1455:1448];
        layer0[54][15:8] = buffer_data_2[1463:1456];
        layer0[54][23:16] = buffer_data_2[1471:1464];
        layer1[54][7:0] = buffer_data_1[1455:1448];
        layer1[54][15:8] = buffer_data_1[1463:1456];
        layer1[54][23:16] = buffer_data_1[1471:1464];
        layer2[54][7:0] = buffer_data_0[1455:1448];
        layer2[54][15:8] = buffer_data_0[1463:1456];
        layer2[54][23:16] = buffer_data_0[1471:1464];
        layer0[55][7:0] = buffer_data_2[1463:1456];
        layer0[55][15:8] = buffer_data_2[1471:1464];
        layer0[55][23:16] = buffer_data_2[1479:1472];
        layer1[55][7:0] = buffer_data_1[1463:1456];
        layer1[55][15:8] = buffer_data_1[1471:1464];
        layer1[55][23:16] = buffer_data_1[1479:1472];
        layer2[55][7:0] = buffer_data_0[1463:1456];
        layer2[55][15:8] = buffer_data_0[1471:1464];
        layer2[55][23:16] = buffer_data_0[1479:1472];
        layer0[56][7:0] = buffer_data_2[1471:1464];
        layer0[56][15:8] = buffer_data_2[1479:1472];
        layer0[56][23:16] = buffer_data_2[1487:1480];
        layer1[56][7:0] = buffer_data_1[1471:1464];
        layer1[56][15:8] = buffer_data_1[1479:1472];
        layer1[56][23:16] = buffer_data_1[1487:1480];
        layer2[56][7:0] = buffer_data_0[1471:1464];
        layer2[56][15:8] = buffer_data_0[1479:1472];
        layer2[56][23:16] = buffer_data_0[1487:1480];
        layer0[57][7:0] = buffer_data_2[1479:1472];
        layer0[57][15:8] = buffer_data_2[1487:1480];
        layer0[57][23:16] = buffer_data_2[1495:1488];
        layer1[57][7:0] = buffer_data_1[1479:1472];
        layer1[57][15:8] = buffer_data_1[1487:1480];
        layer1[57][23:16] = buffer_data_1[1495:1488];
        layer2[57][7:0] = buffer_data_0[1479:1472];
        layer2[57][15:8] = buffer_data_0[1487:1480];
        layer2[57][23:16] = buffer_data_0[1495:1488];
        layer0[58][7:0] = buffer_data_2[1487:1480];
        layer0[58][15:8] = buffer_data_2[1495:1488];
        layer0[58][23:16] = buffer_data_2[1503:1496];
        layer1[58][7:0] = buffer_data_1[1487:1480];
        layer1[58][15:8] = buffer_data_1[1495:1488];
        layer1[58][23:16] = buffer_data_1[1503:1496];
        layer2[58][7:0] = buffer_data_0[1487:1480];
        layer2[58][15:8] = buffer_data_0[1495:1488];
        layer2[58][23:16] = buffer_data_0[1503:1496];
        layer0[59][7:0] = buffer_data_2[1495:1488];
        layer0[59][15:8] = buffer_data_2[1503:1496];
        layer0[59][23:16] = buffer_data_2[1511:1504];
        layer1[59][7:0] = buffer_data_1[1495:1488];
        layer1[59][15:8] = buffer_data_1[1503:1496];
        layer1[59][23:16] = buffer_data_1[1511:1504];
        layer2[59][7:0] = buffer_data_0[1495:1488];
        layer2[59][15:8] = buffer_data_0[1503:1496];
        layer2[59][23:16] = buffer_data_0[1511:1504];
        layer0[60][7:0] = buffer_data_2[1503:1496];
        layer0[60][15:8] = buffer_data_2[1511:1504];
        layer0[60][23:16] = buffer_data_2[1519:1512];
        layer1[60][7:0] = buffer_data_1[1503:1496];
        layer1[60][15:8] = buffer_data_1[1511:1504];
        layer1[60][23:16] = buffer_data_1[1519:1512];
        layer2[60][7:0] = buffer_data_0[1503:1496];
        layer2[60][15:8] = buffer_data_0[1511:1504];
        layer2[60][23:16] = buffer_data_0[1519:1512];
        layer0[61][7:0] = buffer_data_2[1511:1504];
        layer0[61][15:8] = buffer_data_2[1519:1512];
        layer0[61][23:16] = buffer_data_2[1527:1520];
        layer1[61][7:0] = buffer_data_1[1511:1504];
        layer1[61][15:8] = buffer_data_1[1519:1512];
        layer1[61][23:16] = buffer_data_1[1527:1520];
        layer2[61][7:0] = buffer_data_0[1511:1504];
        layer2[61][15:8] = buffer_data_0[1519:1512];
        layer2[61][23:16] = buffer_data_0[1527:1520];
        layer0[62][7:0] = buffer_data_2[1519:1512];
        layer0[62][15:8] = buffer_data_2[1527:1520];
        layer0[62][23:16] = buffer_data_2[1535:1528];
        layer1[62][7:0] = buffer_data_1[1519:1512];
        layer1[62][15:8] = buffer_data_1[1527:1520];
        layer1[62][23:16] = buffer_data_1[1535:1528];
        layer2[62][7:0] = buffer_data_0[1519:1512];
        layer2[62][15:8] = buffer_data_0[1527:1520];
        layer2[62][23:16] = buffer_data_0[1535:1528];
        layer0[63][7:0] = buffer_data_2[1527:1520];
        layer0[63][15:8] = buffer_data_2[1535:1528];
        layer0[63][23:16] = buffer_data_2[1543:1536];
        layer1[63][7:0] = buffer_data_1[1527:1520];
        layer1[63][15:8] = buffer_data_1[1535:1528];
        layer1[63][23:16] = buffer_data_1[1543:1536];
        layer2[63][7:0] = buffer_data_0[1527:1520];
        layer2[63][15:8] = buffer_data_0[1535:1528];
        layer2[63][23:16] = buffer_data_0[1543:1536];
    end
    ST_GAUSSIAN_3: begin
        layer0[0][7:0] = buffer_data_2[1535:1528];
        layer0[0][15:8] = buffer_data_2[1543:1536];
        layer0[0][23:16] = buffer_data_2[1551:1544];
        layer1[0][7:0] = buffer_data_1[1535:1528];
        layer1[0][15:8] = buffer_data_1[1543:1536];
        layer1[0][23:16] = buffer_data_1[1551:1544];
        layer2[0][7:0] = buffer_data_0[1535:1528];
        layer2[0][15:8] = buffer_data_0[1543:1536];
        layer2[0][23:16] = buffer_data_0[1551:1544];
        layer0[1][7:0] = buffer_data_2[1543:1536];
        layer0[1][15:8] = buffer_data_2[1551:1544];
        layer0[1][23:16] = buffer_data_2[1559:1552];
        layer1[1][7:0] = buffer_data_1[1543:1536];
        layer1[1][15:8] = buffer_data_1[1551:1544];
        layer1[1][23:16] = buffer_data_1[1559:1552];
        layer2[1][7:0] = buffer_data_0[1543:1536];
        layer2[1][15:8] = buffer_data_0[1551:1544];
        layer2[1][23:16] = buffer_data_0[1559:1552];
        layer0[2][7:0] = buffer_data_2[1551:1544];
        layer0[2][15:8] = buffer_data_2[1559:1552];
        layer0[2][23:16] = buffer_data_2[1567:1560];
        layer1[2][7:0] = buffer_data_1[1551:1544];
        layer1[2][15:8] = buffer_data_1[1559:1552];
        layer1[2][23:16] = buffer_data_1[1567:1560];
        layer2[2][7:0] = buffer_data_0[1551:1544];
        layer2[2][15:8] = buffer_data_0[1559:1552];
        layer2[2][23:16] = buffer_data_0[1567:1560];
        layer0[3][7:0] = buffer_data_2[1559:1552];
        layer0[3][15:8] = buffer_data_2[1567:1560];
        layer0[3][23:16] = buffer_data_2[1575:1568];
        layer1[3][7:0] = buffer_data_1[1559:1552];
        layer1[3][15:8] = buffer_data_1[1567:1560];
        layer1[3][23:16] = buffer_data_1[1575:1568];
        layer2[3][7:0] = buffer_data_0[1559:1552];
        layer2[3][15:8] = buffer_data_0[1567:1560];
        layer2[3][23:16] = buffer_data_0[1575:1568];
        layer0[4][7:0] = buffer_data_2[1567:1560];
        layer0[4][15:8] = buffer_data_2[1575:1568];
        layer0[4][23:16] = buffer_data_2[1583:1576];
        layer1[4][7:0] = buffer_data_1[1567:1560];
        layer1[4][15:8] = buffer_data_1[1575:1568];
        layer1[4][23:16] = buffer_data_1[1583:1576];
        layer2[4][7:0] = buffer_data_0[1567:1560];
        layer2[4][15:8] = buffer_data_0[1575:1568];
        layer2[4][23:16] = buffer_data_0[1583:1576];
        layer0[5][7:0] = buffer_data_2[1575:1568];
        layer0[5][15:8] = buffer_data_2[1583:1576];
        layer0[5][23:16] = buffer_data_2[1591:1584];
        layer1[5][7:0] = buffer_data_1[1575:1568];
        layer1[5][15:8] = buffer_data_1[1583:1576];
        layer1[5][23:16] = buffer_data_1[1591:1584];
        layer2[5][7:0] = buffer_data_0[1575:1568];
        layer2[5][15:8] = buffer_data_0[1583:1576];
        layer2[5][23:16] = buffer_data_0[1591:1584];
        layer0[6][7:0] = buffer_data_2[1583:1576];
        layer0[6][15:8] = buffer_data_2[1591:1584];
        layer0[6][23:16] = buffer_data_2[1599:1592];
        layer1[6][7:0] = buffer_data_1[1583:1576];
        layer1[6][15:8] = buffer_data_1[1591:1584];
        layer1[6][23:16] = buffer_data_1[1599:1592];
        layer2[6][7:0] = buffer_data_0[1583:1576];
        layer2[6][15:8] = buffer_data_0[1591:1584];
        layer2[6][23:16] = buffer_data_0[1599:1592];
        layer0[7][7:0] = buffer_data_2[1591:1584];
        layer0[7][15:8] = buffer_data_2[1599:1592];
        layer0[7][23:16] = buffer_data_2[1607:1600];
        layer1[7][7:0] = buffer_data_1[1591:1584];
        layer1[7][15:8] = buffer_data_1[1599:1592];
        layer1[7][23:16] = buffer_data_1[1607:1600];
        layer2[7][7:0] = buffer_data_0[1591:1584];
        layer2[7][15:8] = buffer_data_0[1599:1592];
        layer2[7][23:16] = buffer_data_0[1607:1600];
        layer0[8][7:0] = buffer_data_2[1599:1592];
        layer0[8][15:8] = buffer_data_2[1607:1600];
        layer0[8][23:16] = buffer_data_2[1615:1608];
        layer1[8][7:0] = buffer_data_1[1599:1592];
        layer1[8][15:8] = buffer_data_1[1607:1600];
        layer1[8][23:16] = buffer_data_1[1615:1608];
        layer2[8][7:0] = buffer_data_0[1599:1592];
        layer2[8][15:8] = buffer_data_0[1607:1600];
        layer2[8][23:16] = buffer_data_0[1615:1608];
        layer0[9][7:0] = buffer_data_2[1607:1600];
        layer0[9][15:8] = buffer_data_2[1615:1608];
        layer0[9][23:16] = buffer_data_2[1623:1616];
        layer1[9][7:0] = buffer_data_1[1607:1600];
        layer1[9][15:8] = buffer_data_1[1615:1608];
        layer1[9][23:16] = buffer_data_1[1623:1616];
        layer2[9][7:0] = buffer_data_0[1607:1600];
        layer2[9][15:8] = buffer_data_0[1615:1608];
        layer2[9][23:16] = buffer_data_0[1623:1616];
        layer0[10][7:0] = buffer_data_2[1615:1608];
        layer0[10][15:8] = buffer_data_2[1623:1616];
        layer0[10][23:16] = buffer_data_2[1631:1624];
        layer1[10][7:0] = buffer_data_1[1615:1608];
        layer1[10][15:8] = buffer_data_1[1623:1616];
        layer1[10][23:16] = buffer_data_1[1631:1624];
        layer2[10][7:0] = buffer_data_0[1615:1608];
        layer2[10][15:8] = buffer_data_0[1623:1616];
        layer2[10][23:16] = buffer_data_0[1631:1624];
        layer0[11][7:0] = buffer_data_2[1623:1616];
        layer0[11][15:8] = buffer_data_2[1631:1624];
        layer0[11][23:16] = buffer_data_2[1639:1632];
        layer1[11][7:0] = buffer_data_1[1623:1616];
        layer1[11][15:8] = buffer_data_1[1631:1624];
        layer1[11][23:16] = buffer_data_1[1639:1632];
        layer2[11][7:0] = buffer_data_0[1623:1616];
        layer2[11][15:8] = buffer_data_0[1631:1624];
        layer2[11][23:16] = buffer_data_0[1639:1632];
        layer0[12][7:0] = buffer_data_2[1631:1624];
        layer0[12][15:8] = buffer_data_2[1639:1632];
        layer0[12][23:16] = buffer_data_2[1647:1640];
        layer1[12][7:0] = buffer_data_1[1631:1624];
        layer1[12][15:8] = buffer_data_1[1639:1632];
        layer1[12][23:16] = buffer_data_1[1647:1640];
        layer2[12][7:0] = buffer_data_0[1631:1624];
        layer2[12][15:8] = buffer_data_0[1639:1632];
        layer2[12][23:16] = buffer_data_0[1647:1640];
        layer0[13][7:0] = buffer_data_2[1639:1632];
        layer0[13][15:8] = buffer_data_2[1647:1640];
        layer0[13][23:16] = buffer_data_2[1655:1648];
        layer1[13][7:0] = buffer_data_1[1639:1632];
        layer1[13][15:8] = buffer_data_1[1647:1640];
        layer1[13][23:16] = buffer_data_1[1655:1648];
        layer2[13][7:0] = buffer_data_0[1639:1632];
        layer2[13][15:8] = buffer_data_0[1647:1640];
        layer2[13][23:16] = buffer_data_0[1655:1648];
        layer0[14][7:0] = buffer_data_2[1647:1640];
        layer0[14][15:8] = buffer_data_2[1655:1648];
        layer0[14][23:16] = buffer_data_2[1663:1656];
        layer1[14][7:0] = buffer_data_1[1647:1640];
        layer1[14][15:8] = buffer_data_1[1655:1648];
        layer1[14][23:16] = buffer_data_1[1663:1656];
        layer2[14][7:0] = buffer_data_0[1647:1640];
        layer2[14][15:8] = buffer_data_0[1655:1648];
        layer2[14][23:16] = buffer_data_0[1663:1656];
        layer0[15][7:0] = buffer_data_2[1655:1648];
        layer0[15][15:8] = buffer_data_2[1663:1656];
        layer0[15][23:16] = buffer_data_2[1671:1664];
        layer1[15][7:0] = buffer_data_1[1655:1648];
        layer1[15][15:8] = buffer_data_1[1663:1656];
        layer1[15][23:16] = buffer_data_1[1671:1664];
        layer2[15][7:0] = buffer_data_0[1655:1648];
        layer2[15][15:8] = buffer_data_0[1663:1656];
        layer2[15][23:16] = buffer_data_0[1671:1664];
        layer0[16][7:0] = buffer_data_2[1663:1656];
        layer0[16][15:8] = buffer_data_2[1671:1664];
        layer0[16][23:16] = buffer_data_2[1679:1672];
        layer1[16][7:0] = buffer_data_1[1663:1656];
        layer1[16][15:8] = buffer_data_1[1671:1664];
        layer1[16][23:16] = buffer_data_1[1679:1672];
        layer2[16][7:0] = buffer_data_0[1663:1656];
        layer2[16][15:8] = buffer_data_0[1671:1664];
        layer2[16][23:16] = buffer_data_0[1679:1672];
        layer0[17][7:0] = buffer_data_2[1671:1664];
        layer0[17][15:8] = buffer_data_2[1679:1672];
        layer0[17][23:16] = buffer_data_2[1687:1680];
        layer1[17][7:0] = buffer_data_1[1671:1664];
        layer1[17][15:8] = buffer_data_1[1679:1672];
        layer1[17][23:16] = buffer_data_1[1687:1680];
        layer2[17][7:0] = buffer_data_0[1671:1664];
        layer2[17][15:8] = buffer_data_0[1679:1672];
        layer2[17][23:16] = buffer_data_0[1687:1680];
        layer0[18][7:0] = buffer_data_2[1679:1672];
        layer0[18][15:8] = buffer_data_2[1687:1680];
        layer0[18][23:16] = buffer_data_2[1695:1688];
        layer1[18][7:0] = buffer_data_1[1679:1672];
        layer1[18][15:8] = buffer_data_1[1687:1680];
        layer1[18][23:16] = buffer_data_1[1695:1688];
        layer2[18][7:0] = buffer_data_0[1679:1672];
        layer2[18][15:8] = buffer_data_0[1687:1680];
        layer2[18][23:16] = buffer_data_0[1695:1688];
        layer0[19][7:0] = buffer_data_2[1687:1680];
        layer0[19][15:8] = buffer_data_2[1695:1688];
        layer0[19][23:16] = buffer_data_2[1703:1696];
        layer1[19][7:0] = buffer_data_1[1687:1680];
        layer1[19][15:8] = buffer_data_1[1695:1688];
        layer1[19][23:16] = buffer_data_1[1703:1696];
        layer2[19][7:0] = buffer_data_0[1687:1680];
        layer2[19][15:8] = buffer_data_0[1695:1688];
        layer2[19][23:16] = buffer_data_0[1703:1696];
        layer0[20][7:0] = buffer_data_2[1695:1688];
        layer0[20][15:8] = buffer_data_2[1703:1696];
        layer0[20][23:16] = buffer_data_2[1711:1704];
        layer1[20][7:0] = buffer_data_1[1695:1688];
        layer1[20][15:8] = buffer_data_1[1703:1696];
        layer1[20][23:16] = buffer_data_1[1711:1704];
        layer2[20][7:0] = buffer_data_0[1695:1688];
        layer2[20][15:8] = buffer_data_0[1703:1696];
        layer2[20][23:16] = buffer_data_0[1711:1704];
        layer0[21][7:0] = buffer_data_2[1703:1696];
        layer0[21][15:8] = buffer_data_2[1711:1704];
        layer0[21][23:16] = buffer_data_2[1719:1712];
        layer1[21][7:0] = buffer_data_1[1703:1696];
        layer1[21][15:8] = buffer_data_1[1711:1704];
        layer1[21][23:16] = buffer_data_1[1719:1712];
        layer2[21][7:0] = buffer_data_0[1703:1696];
        layer2[21][15:8] = buffer_data_0[1711:1704];
        layer2[21][23:16] = buffer_data_0[1719:1712];
        layer0[22][7:0] = buffer_data_2[1711:1704];
        layer0[22][15:8] = buffer_data_2[1719:1712];
        layer0[22][23:16] = buffer_data_2[1727:1720];
        layer1[22][7:0] = buffer_data_1[1711:1704];
        layer1[22][15:8] = buffer_data_1[1719:1712];
        layer1[22][23:16] = buffer_data_1[1727:1720];
        layer2[22][7:0] = buffer_data_0[1711:1704];
        layer2[22][15:8] = buffer_data_0[1719:1712];
        layer2[22][23:16] = buffer_data_0[1727:1720];
        layer0[23][7:0] = buffer_data_2[1719:1712];
        layer0[23][15:8] = buffer_data_2[1727:1720];
        layer0[23][23:16] = buffer_data_2[1735:1728];
        layer1[23][7:0] = buffer_data_1[1719:1712];
        layer1[23][15:8] = buffer_data_1[1727:1720];
        layer1[23][23:16] = buffer_data_1[1735:1728];
        layer2[23][7:0] = buffer_data_0[1719:1712];
        layer2[23][15:8] = buffer_data_0[1727:1720];
        layer2[23][23:16] = buffer_data_0[1735:1728];
        layer0[24][7:0] = buffer_data_2[1727:1720];
        layer0[24][15:8] = buffer_data_2[1735:1728];
        layer0[24][23:16] = buffer_data_2[1743:1736];
        layer1[24][7:0] = buffer_data_1[1727:1720];
        layer1[24][15:8] = buffer_data_1[1735:1728];
        layer1[24][23:16] = buffer_data_1[1743:1736];
        layer2[24][7:0] = buffer_data_0[1727:1720];
        layer2[24][15:8] = buffer_data_0[1735:1728];
        layer2[24][23:16] = buffer_data_0[1743:1736];
        layer0[25][7:0] = buffer_data_2[1735:1728];
        layer0[25][15:8] = buffer_data_2[1743:1736];
        layer0[25][23:16] = buffer_data_2[1751:1744];
        layer1[25][7:0] = buffer_data_1[1735:1728];
        layer1[25][15:8] = buffer_data_1[1743:1736];
        layer1[25][23:16] = buffer_data_1[1751:1744];
        layer2[25][7:0] = buffer_data_0[1735:1728];
        layer2[25][15:8] = buffer_data_0[1743:1736];
        layer2[25][23:16] = buffer_data_0[1751:1744];
        layer0[26][7:0] = buffer_data_2[1743:1736];
        layer0[26][15:8] = buffer_data_2[1751:1744];
        layer0[26][23:16] = buffer_data_2[1759:1752];
        layer1[26][7:0] = buffer_data_1[1743:1736];
        layer1[26][15:8] = buffer_data_1[1751:1744];
        layer1[26][23:16] = buffer_data_1[1759:1752];
        layer2[26][7:0] = buffer_data_0[1743:1736];
        layer2[26][15:8] = buffer_data_0[1751:1744];
        layer2[26][23:16] = buffer_data_0[1759:1752];
        layer0[27][7:0] = buffer_data_2[1751:1744];
        layer0[27][15:8] = buffer_data_2[1759:1752];
        layer0[27][23:16] = buffer_data_2[1767:1760];
        layer1[27][7:0] = buffer_data_1[1751:1744];
        layer1[27][15:8] = buffer_data_1[1759:1752];
        layer1[27][23:16] = buffer_data_1[1767:1760];
        layer2[27][7:0] = buffer_data_0[1751:1744];
        layer2[27][15:8] = buffer_data_0[1759:1752];
        layer2[27][23:16] = buffer_data_0[1767:1760];
        layer0[28][7:0] = buffer_data_2[1759:1752];
        layer0[28][15:8] = buffer_data_2[1767:1760];
        layer0[28][23:16] = buffer_data_2[1775:1768];
        layer1[28][7:0] = buffer_data_1[1759:1752];
        layer1[28][15:8] = buffer_data_1[1767:1760];
        layer1[28][23:16] = buffer_data_1[1775:1768];
        layer2[28][7:0] = buffer_data_0[1759:1752];
        layer2[28][15:8] = buffer_data_0[1767:1760];
        layer2[28][23:16] = buffer_data_0[1775:1768];
        layer0[29][7:0] = buffer_data_2[1767:1760];
        layer0[29][15:8] = buffer_data_2[1775:1768];
        layer0[29][23:16] = buffer_data_2[1783:1776];
        layer1[29][7:0] = buffer_data_1[1767:1760];
        layer1[29][15:8] = buffer_data_1[1775:1768];
        layer1[29][23:16] = buffer_data_1[1783:1776];
        layer2[29][7:0] = buffer_data_0[1767:1760];
        layer2[29][15:8] = buffer_data_0[1775:1768];
        layer2[29][23:16] = buffer_data_0[1783:1776];
        layer0[30][7:0] = buffer_data_2[1775:1768];
        layer0[30][15:8] = buffer_data_2[1783:1776];
        layer0[30][23:16] = buffer_data_2[1791:1784];
        layer1[30][7:0] = buffer_data_1[1775:1768];
        layer1[30][15:8] = buffer_data_1[1783:1776];
        layer1[30][23:16] = buffer_data_1[1791:1784];
        layer2[30][7:0] = buffer_data_0[1775:1768];
        layer2[30][15:8] = buffer_data_0[1783:1776];
        layer2[30][23:16] = buffer_data_0[1791:1784];
        layer0[31][7:0] = buffer_data_2[1783:1776];
        layer0[31][15:8] = buffer_data_2[1791:1784];
        layer0[31][23:16] = buffer_data_2[1799:1792];
        layer1[31][7:0] = buffer_data_1[1783:1776];
        layer1[31][15:8] = buffer_data_1[1791:1784];
        layer1[31][23:16] = buffer_data_1[1799:1792];
        layer2[31][7:0] = buffer_data_0[1783:1776];
        layer2[31][15:8] = buffer_data_0[1791:1784];
        layer2[31][23:16] = buffer_data_0[1799:1792];
        layer0[32][7:0] = buffer_data_2[1791:1784];
        layer0[32][15:8] = buffer_data_2[1799:1792];
        layer0[32][23:16] = buffer_data_2[1807:1800];
        layer1[32][7:0] = buffer_data_1[1791:1784];
        layer1[32][15:8] = buffer_data_1[1799:1792];
        layer1[32][23:16] = buffer_data_1[1807:1800];
        layer2[32][7:0] = buffer_data_0[1791:1784];
        layer2[32][15:8] = buffer_data_0[1799:1792];
        layer2[32][23:16] = buffer_data_0[1807:1800];
        layer0[33][7:0] = buffer_data_2[1799:1792];
        layer0[33][15:8] = buffer_data_2[1807:1800];
        layer0[33][23:16] = buffer_data_2[1815:1808];
        layer1[33][7:0] = buffer_data_1[1799:1792];
        layer1[33][15:8] = buffer_data_1[1807:1800];
        layer1[33][23:16] = buffer_data_1[1815:1808];
        layer2[33][7:0] = buffer_data_0[1799:1792];
        layer2[33][15:8] = buffer_data_0[1807:1800];
        layer2[33][23:16] = buffer_data_0[1815:1808];
        layer0[34][7:0] = buffer_data_2[1807:1800];
        layer0[34][15:8] = buffer_data_2[1815:1808];
        layer0[34][23:16] = buffer_data_2[1823:1816];
        layer1[34][7:0] = buffer_data_1[1807:1800];
        layer1[34][15:8] = buffer_data_1[1815:1808];
        layer1[34][23:16] = buffer_data_1[1823:1816];
        layer2[34][7:0] = buffer_data_0[1807:1800];
        layer2[34][15:8] = buffer_data_0[1815:1808];
        layer2[34][23:16] = buffer_data_0[1823:1816];
        layer0[35][7:0] = buffer_data_2[1815:1808];
        layer0[35][15:8] = buffer_data_2[1823:1816];
        layer0[35][23:16] = buffer_data_2[1831:1824];
        layer1[35][7:0] = buffer_data_1[1815:1808];
        layer1[35][15:8] = buffer_data_1[1823:1816];
        layer1[35][23:16] = buffer_data_1[1831:1824];
        layer2[35][7:0] = buffer_data_0[1815:1808];
        layer2[35][15:8] = buffer_data_0[1823:1816];
        layer2[35][23:16] = buffer_data_0[1831:1824];
        layer0[36][7:0] = buffer_data_2[1823:1816];
        layer0[36][15:8] = buffer_data_2[1831:1824];
        layer0[36][23:16] = buffer_data_2[1839:1832];
        layer1[36][7:0] = buffer_data_1[1823:1816];
        layer1[36][15:8] = buffer_data_1[1831:1824];
        layer1[36][23:16] = buffer_data_1[1839:1832];
        layer2[36][7:0] = buffer_data_0[1823:1816];
        layer2[36][15:8] = buffer_data_0[1831:1824];
        layer2[36][23:16] = buffer_data_0[1839:1832];
        layer0[37][7:0] = buffer_data_2[1831:1824];
        layer0[37][15:8] = buffer_data_2[1839:1832];
        layer0[37][23:16] = buffer_data_2[1847:1840];
        layer1[37][7:0] = buffer_data_1[1831:1824];
        layer1[37][15:8] = buffer_data_1[1839:1832];
        layer1[37][23:16] = buffer_data_1[1847:1840];
        layer2[37][7:0] = buffer_data_0[1831:1824];
        layer2[37][15:8] = buffer_data_0[1839:1832];
        layer2[37][23:16] = buffer_data_0[1847:1840];
        layer0[38][7:0] = buffer_data_2[1839:1832];
        layer0[38][15:8] = buffer_data_2[1847:1840];
        layer0[38][23:16] = buffer_data_2[1855:1848];
        layer1[38][7:0] = buffer_data_1[1839:1832];
        layer1[38][15:8] = buffer_data_1[1847:1840];
        layer1[38][23:16] = buffer_data_1[1855:1848];
        layer2[38][7:0] = buffer_data_0[1839:1832];
        layer2[38][15:8] = buffer_data_0[1847:1840];
        layer2[38][23:16] = buffer_data_0[1855:1848];
        layer0[39][7:0] = buffer_data_2[1847:1840];
        layer0[39][15:8] = buffer_data_2[1855:1848];
        layer0[39][23:16] = buffer_data_2[1863:1856];
        layer1[39][7:0] = buffer_data_1[1847:1840];
        layer1[39][15:8] = buffer_data_1[1855:1848];
        layer1[39][23:16] = buffer_data_1[1863:1856];
        layer2[39][7:0] = buffer_data_0[1847:1840];
        layer2[39][15:8] = buffer_data_0[1855:1848];
        layer2[39][23:16] = buffer_data_0[1863:1856];
        layer0[40][7:0] = buffer_data_2[1855:1848];
        layer0[40][15:8] = buffer_data_2[1863:1856];
        layer0[40][23:16] = buffer_data_2[1871:1864];
        layer1[40][7:0] = buffer_data_1[1855:1848];
        layer1[40][15:8] = buffer_data_1[1863:1856];
        layer1[40][23:16] = buffer_data_1[1871:1864];
        layer2[40][7:0] = buffer_data_0[1855:1848];
        layer2[40][15:8] = buffer_data_0[1863:1856];
        layer2[40][23:16] = buffer_data_0[1871:1864];
        layer0[41][7:0] = buffer_data_2[1863:1856];
        layer0[41][15:8] = buffer_data_2[1871:1864];
        layer0[41][23:16] = buffer_data_2[1879:1872];
        layer1[41][7:0] = buffer_data_1[1863:1856];
        layer1[41][15:8] = buffer_data_1[1871:1864];
        layer1[41][23:16] = buffer_data_1[1879:1872];
        layer2[41][7:0] = buffer_data_0[1863:1856];
        layer2[41][15:8] = buffer_data_0[1871:1864];
        layer2[41][23:16] = buffer_data_0[1879:1872];
        layer0[42][7:0] = buffer_data_2[1871:1864];
        layer0[42][15:8] = buffer_data_2[1879:1872];
        layer0[42][23:16] = buffer_data_2[1887:1880];
        layer1[42][7:0] = buffer_data_1[1871:1864];
        layer1[42][15:8] = buffer_data_1[1879:1872];
        layer1[42][23:16] = buffer_data_1[1887:1880];
        layer2[42][7:0] = buffer_data_0[1871:1864];
        layer2[42][15:8] = buffer_data_0[1879:1872];
        layer2[42][23:16] = buffer_data_0[1887:1880];
        layer0[43][7:0] = buffer_data_2[1879:1872];
        layer0[43][15:8] = buffer_data_2[1887:1880];
        layer0[43][23:16] = buffer_data_2[1895:1888];
        layer1[43][7:0] = buffer_data_1[1879:1872];
        layer1[43][15:8] = buffer_data_1[1887:1880];
        layer1[43][23:16] = buffer_data_1[1895:1888];
        layer2[43][7:0] = buffer_data_0[1879:1872];
        layer2[43][15:8] = buffer_data_0[1887:1880];
        layer2[43][23:16] = buffer_data_0[1895:1888];
        layer0[44][7:0] = buffer_data_2[1887:1880];
        layer0[44][15:8] = buffer_data_2[1895:1888];
        layer0[44][23:16] = buffer_data_2[1903:1896];
        layer1[44][7:0] = buffer_data_1[1887:1880];
        layer1[44][15:8] = buffer_data_1[1895:1888];
        layer1[44][23:16] = buffer_data_1[1903:1896];
        layer2[44][7:0] = buffer_data_0[1887:1880];
        layer2[44][15:8] = buffer_data_0[1895:1888];
        layer2[44][23:16] = buffer_data_0[1903:1896];
        layer0[45][7:0] = buffer_data_2[1895:1888];
        layer0[45][15:8] = buffer_data_2[1903:1896];
        layer0[45][23:16] = buffer_data_2[1911:1904];
        layer1[45][7:0] = buffer_data_1[1895:1888];
        layer1[45][15:8] = buffer_data_1[1903:1896];
        layer1[45][23:16] = buffer_data_1[1911:1904];
        layer2[45][7:0] = buffer_data_0[1895:1888];
        layer2[45][15:8] = buffer_data_0[1903:1896];
        layer2[45][23:16] = buffer_data_0[1911:1904];
        layer0[46][7:0] = buffer_data_2[1903:1896];
        layer0[46][15:8] = buffer_data_2[1911:1904];
        layer0[46][23:16] = buffer_data_2[1919:1912];
        layer1[46][7:0] = buffer_data_1[1903:1896];
        layer1[46][15:8] = buffer_data_1[1911:1904];
        layer1[46][23:16] = buffer_data_1[1919:1912];
        layer2[46][7:0] = buffer_data_0[1903:1896];
        layer2[46][15:8] = buffer_data_0[1911:1904];
        layer2[46][23:16] = buffer_data_0[1919:1912];
        layer0[47][7:0] = buffer_data_2[1911:1904];
        layer0[47][15:8] = buffer_data_2[1919:1912];
        layer0[47][23:16] = buffer_data_2[1927:1920];
        layer1[47][7:0] = buffer_data_1[1911:1904];
        layer1[47][15:8] = buffer_data_1[1919:1912];
        layer1[47][23:16] = buffer_data_1[1927:1920];
        layer2[47][7:0] = buffer_data_0[1911:1904];
        layer2[47][15:8] = buffer_data_0[1919:1912];
        layer2[47][23:16] = buffer_data_0[1927:1920];
        layer0[48][7:0] = buffer_data_2[1919:1912];
        layer0[48][15:8] = buffer_data_2[1927:1920];
        layer0[48][23:16] = buffer_data_2[1935:1928];
        layer1[48][7:0] = buffer_data_1[1919:1912];
        layer1[48][15:8] = buffer_data_1[1927:1920];
        layer1[48][23:16] = buffer_data_1[1935:1928];
        layer2[48][7:0] = buffer_data_0[1919:1912];
        layer2[48][15:8] = buffer_data_0[1927:1920];
        layer2[48][23:16] = buffer_data_0[1935:1928];
        layer0[49][7:0] = buffer_data_2[1927:1920];
        layer0[49][15:8] = buffer_data_2[1935:1928];
        layer0[49][23:16] = buffer_data_2[1943:1936];
        layer1[49][7:0] = buffer_data_1[1927:1920];
        layer1[49][15:8] = buffer_data_1[1935:1928];
        layer1[49][23:16] = buffer_data_1[1943:1936];
        layer2[49][7:0] = buffer_data_0[1927:1920];
        layer2[49][15:8] = buffer_data_0[1935:1928];
        layer2[49][23:16] = buffer_data_0[1943:1936];
        layer0[50][7:0] = buffer_data_2[1935:1928];
        layer0[50][15:8] = buffer_data_2[1943:1936];
        layer0[50][23:16] = buffer_data_2[1951:1944];
        layer1[50][7:0] = buffer_data_1[1935:1928];
        layer1[50][15:8] = buffer_data_1[1943:1936];
        layer1[50][23:16] = buffer_data_1[1951:1944];
        layer2[50][7:0] = buffer_data_0[1935:1928];
        layer2[50][15:8] = buffer_data_0[1943:1936];
        layer2[50][23:16] = buffer_data_0[1951:1944];
        layer0[51][7:0] = buffer_data_2[1943:1936];
        layer0[51][15:8] = buffer_data_2[1951:1944];
        layer0[51][23:16] = buffer_data_2[1959:1952];
        layer1[51][7:0] = buffer_data_1[1943:1936];
        layer1[51][15:8] = buffer_data_1[1951:1944];
        layer1[51][23:16] = buffer_data_1[1959:1952];
        layer2[51][7:0] = buffer_data_0[1943:1936];
        layer2[51][15:8] = buffer_data_0[1951:1944];
        layer2[51][23:16] = buffer_data_0[1959:1952];
        layer0[52][7:0] = buffer_data_2[1951:1944];
        layer0[52][15:8] = buffer_data_2[1959:1952];
        layer0[52][23:16] = buffer_data_2[1967:1960];
        layer1[52][7:0] = buffer_data_1[1951:1944];
        layer1[52][15:8] = buffer_data_1[1959:1952];
        layer1[52][23:16] = buffer_data_1[1967:1960];
        layer2[52][7:0] = buffer_data_0[1951:1944];
        layer2[52][15:8] = buffer_data_0[1959:1952];
        layer2[52][23:16] = buffer_data_0[1967:1960];
        layer0[53][7:0] = buffer_data_2[1959:1952];
        layer0[53][15:8] = buffer_data_2[1967:1960];
        layer0[53][23:16] = buffer_data_2[1975:1968];
        layer1[53][7:0] = buffer_data_1[1959:1952];
        layer1[53][15:8] = buffer_data_1[1967:1960];
        layer1[53][23:16] = buffer_data_1[1975:1968];
        layer2[53][7:0] = buffer_data_0[1959:1952];
        layer2[53][15:8] = buffer_data_0[1967:1960];
        layer2[53][23:16] = buffer_data_0[1975:1968];
        layer0[54][7:0] = buffer_data_2[1967:1960];
        layer0[54][15:8] = buffer_data_2[1975:1968];
        layer0[54][23:16] = buffer_data_2[1983:1976];
        layer1[54][7:0] = buffer_data_1[1967:1960];
        layer1[54][15:8] = buffer_data_1[1975:1968];
        layer1[54][23:16] = buffer_data_1[1983:1976];
        layer2[54][7:0] = buffer_data_0[1967:1960];
        layer2[54][15:8] = buffer_data_0[1975:1968];
        layer2[54][23:16] = buffer_data_0[1983:1976];
        layer0[55][7:0] = buffer_data_2[1975:1968];
        layer0[55][15:8] = buffer_data_2[1983:1976];
        layer0[55][23:16] = buffer_data_2[1991:1984];
        layer1[55][7:0] = buffer_data_1[1975:1968];
        layer1[55][15:8] = buffer_data_1[1983:1976];
        layer1[55][23:16] = buffer_data_1[1991:1984];
        layer2[55][7:0] = buffer_data_0[1975:1968];
        layer2[55][15:8] = buffer_data_0[1983:1976];
        layer2[55][23:16] = buffer_data_0[1991:1984];
        layer0[56][7:0] = buffer_data_2[1983:1976];
        layer0[56][15:8] = buffer_data_2[1991:1984];
        layer0[56][23:16] = buffer_data_2[1999:1992];
        layer1[56][7:0] = buffer_data_1[1983:1976];
        layer1[56][15:8] = buffer_data_1[1991:1984];
        layer1[56][23:16] = buffer_data_1[1999:1992];
        layer2[56][7:0] = buffer_data_0[1983:1976];
        layer2[56][15:8] = buffer_data_0[1991:1984];
        layer2[56][23:16] = buffer_data_0[1999:1992];
        layer0[57][7:0] = buffer_data_2[1991:1984];
        layer0[57][15:8] = buffer_data_2[1999:1992];
        layer0[57][23:16] = buffer_data_2[2007:2000];
        layer1[57][7:0] = buffer_data_1[1991:1984];
        layer1[57][15:8] = buffer_data_1[1999:1992];
        layer1[57][23:16] = buffer_data_1[2007:2000];
        layer2[57][7:0] = buffer_data_0[1991:1984];
        layer2[57][15:8] = buffer_data_0[1999:1992];
        layer2[57][23:16] = buffer_data_0[2007:2000];
        layer0[58][7:0] = buffer_data_2[1999:1992];
        layer0[58][15:8] = buffer_data_2[2007:2000];
        layer0[58][23:16] = buffer_data_2[2015:2008];
        layer1[58][7:0] = buffer_data_1[1999:1992];
        layer1[58][15:8] = buffer_data_1[2007:2000];
        layer1[58][23:16] = buffer_data_1[2015:2008];
        layer2[58][7:0] = buffer_data_0[1999:1992];
        layer2[58][15:8] = buffer_data_0[2007:2000];
        layer2[58][23:16] = buffer_data_0[2015:2008];
        layer0[59][7:0] = buffer_data_2[2007:2000];
        layer0[59][15:8] = buffer_data_2[2015:2008];
        layer0[59][23:16] = buffer_data_2[2023:2016];
        layer1[59][7:0] = buffer_data_1[2007:2000];
        layer1[59][15:8] = buffer_data_1[2015:2008];
        layer1[59][23:16] = buffer_data_1[2023:2016];
        layer2[59][7:0] = buffer_data_0[2007:2000];
        layer2[59][15:8] = buffer_data_0[2015:2008];
        layer2[59][23:16] = buffer_data_0[2023:2016];
        layer0[60][7:0] = buffer_data_2[2015:2008];
        layer0[60][15:8] = buffer_data_2[2023:2016];
        layer0[60][23:16] = buffer_data_2[2031:2024];
        layer1[60][7:0] = buffer_data_1[2015:2008];
        layer1[60][15:8] = buffer_data_1[2023:2016];
        layer1[60][23:16] = buffer_data_1[2031:2024];
        layer2[60][7:0] = buffer_data_0[2015:2008];
        layer2[60][15:8] = buffer_data_0[2023:2016];
        layer2[60][23:16] = buffer_data_0[2031:2024];
        layer0[61][7:0] = buffer_data_2[2023:2016];
        layer0[61][15:8] = buffer_data_2[2031:2024];
        layer0[61][23:16] = buffer_data_2[2039:2032];
        layer1[61][7:0] = buffer_data_1[2023:2016];
        layer1[61][15:8] = buffer_data_1[2031:2024];
        layer1[61][23:16] = buffer_data_1[2039:2032];
        layer2[61][7:0] = buffer_data_0[2023:2016];
        layer2[61][15:8] = buffer_data_0[2031:2024];
        layer2[61][23:16] = buffer_data_0[2039:2032];
        layer0[62][7:0] = buffer_data_2[2031:2024];
        layer0[62][15:8] = buffer_data_2[2039:2032];
        layer0[62][23:16] = buffer_data_2[2047:2040];
        layer1[62][7:0] = buffer_data_1[2031:2024];
        layer1[62][15:8] = buffer_data_1[2039:2032];
        layer1[62][23:16] = buffer_data_1[2047:2040];
        layer2[62][7:0] = buffer_data_0[2031:2024];
        layer2[62][15:8] = buffer_data_0[2039:2032];
        layer2[62][23:16] = buffer_data_0[2047:2040];
        layer0[63][7:0] = buffer_data_2[2039:2032];
        layer0[63][15:8] = buffer_data_2[2047:2040];
        layer0[63][23:16] = buffer_data_2[2055:2048];
        layer1[63][7:0] = buffer_data_1[2039:2032];
        layer1[63][15:8] = buffer_data_1[2047:2040];
        layer1[63][23:16] = buffer_data_1[2055:2048];
        layer2[63][7:0] = buffer_data_0[2039:2032];
        layer2[63][15:8] = buffer_data_0[2047:2040];
        layer2[63][23:16] = buffer_data_0[2055:2048];
    end
    ST_GAUSSIAN_4: begin
        layer0[0][7:0] = buffer_data_2[2047:2040];
        layer0[0][15:8] = buffer_data_2[2055:2048];
        layer0[0][23:16] = buffer_data_2[2063:2056];
        layer1[0][7:0] = buffer_data_1[2047:2040];
        layer1[0][15:8] = buffer_data_1[2055:2048];
        layer1[0][23:16] = buffer_data_1[2063:2056];
        layer2[0][7:0] = buffer_data_0[2047:2040];
        layer2[0][15:8] = buffer_data_0[2055:2048];
        layer2[0][23:16] = buffer_data_0[2063:2056];
        layer0[1][7:0] = buffer_data_2[2055:2048];
        layer0[1][15:8] = buffer_data_2[2063:2056];
        layer0[1][23:16] = buffer_data_2[2071:2064];
        layer1[1][7:0] = buffer_data_1[2055:2048];
        layer1[1][15:8] = buffer_data_1[2063:2056];
        layer1[1][23:16] = buffer_data_1[2071:2064];
        layer2[1][7:0] = buffer_data_0[2055:2048];
        layer2[1][15:8] = buffer_data_0[2063:2056];
        layer2[1][23:16] = buffer_data_0[2071:2064];
        layer0[2][7:0] = buffer_data_2[2063:2056];
        layer0[2][15:8] = buffer_data_2[2071:2064];
        layer0[2][23:16] = buffer_data_2[2079:2072];
        layer1[2][7:0] = buffer_data_1[2063:2056];
        layer1[2][15:8] = buffer_data_1[2071:2064];
        layer1[2][23:16] = buffer_data_1[2079:2072];
        layer2[2][7:0] = buffer_data_0[2063:2056];
        layer2[2][15:8] = buffer_data_0[2071:2064];
        layer2[2][23:16] = buffer_data_0[2079:2072];
        layer0[3][7:0] = buffer_data_2[2071:2064];
        layer0[3][15:8] = buffer_data_2[2079:2072];
        layer0[3][23:16] = buffer_data_2[2087:2080];
        layer1[3][7:0] = buffer_data_1[2071:2064];
        layer1[3][15:8] = buffer_data_1[2079:2072];
        layer1[3][23:16] = buffer_data_1[2087:2080];
        layer2[3][7:0] = buffer_data_0[2071:2064];
        layer2[3][15:8] = buffer_data_0[2079:2072];
        layer2[3][23:16] = buffer_data_0[2087:2080];
        layer0[4][7:0] = buffer_data_2[2079:2072];
        layer0[4][15:8] = buffer_data_2[2087:2080];
        layer0[4][23:16] = buffer_data_2[2095:2088];
        layer1[4][7:0] = buffer_data_1[2079:2072];
        layer1[4][15:8] = buffer_data_1[2087:2080];
        layer1[4][23:16] = buffer_data_1[2095:2088];
        layer2[4][7:0] = buffer_data_0[2079:2072];
        layer2[4][15:8] = buffer_data_0[2087:2080];
        layer2[4][23:16] = buffer_data_0[2095:2088];
        layer0[5][7:0] = buffer_data_2[2087:2080];
        layer0[5][15:8] = buffer_data_2[2095:2088];
        layer0[5][23:16] = buffer_data_2[2103:2096];
        layer1[5][7:0] = buffer_data_1[2087:2080];
        layer1[5][15:8] = buffer_data_1[2095:2088];
        layer1[5][23:16] = buffer_data_1[2103:2096];
        layer2[5][7:0] = buffer_data_0[2087:2080];
        layer2[5][15:8] = buffer_data_0[2095:2088];
        layer2[5][23:16] = buffer_data_0[2103:2096];
        layer0[6][7:0] = buffer_data_2[2095:2088];
        layer0[6][15:8] = buffer_data_2[2103:2096];
        layer0[6][23:16] = buffer_data_2[2111:2104];
        layer1[6][7:0] = buffer_data_1[2095:2088];
        layer1[6][15:8] = buffer_data_1[2103:2096];
        layer1[6][23:16] = buffer_data_1[2111:2104];
        layer2[6][7:0] = buffer_data_0[2095:2088];
        layer2[6][15:8] = buffer_data_0[2103:2096];
        layer2[6][23:16] = buffer_data_0[2111:2104];
        layer0[7][7:0] = buffer_data_2[2103:2096];
        layer0[7][15:8] = buffer_data_2[2111:2104];
        layer0[7][23:16] = buffer_data_2[2119:2112];
        layer1[7][7:0] = buffer_data_1[2103:2096];
        layer1[7][15:8] = buffer_data_1[2111:2104];
        layer1[7][23:16] = buffer_data_1[2119:2112];
        layer2[7][7:0] = buffer_data_0[2103:2096];
        layer2[7][15:8] = buffer_data_0[2111:2104];
        layer2[7][23:16] = buffer_data_0[2119:2112];
        layer0[8][7:0] = buffer_data_2[2111:2104];
        layer0[8][15:8] = buffer_data_2[2119:2112];
        layer0[8][23:16] = buffer_data_2[2127:2120];
        layer1[8][7:0] = buffer_data_1[2111:2104];
        layer1[8][15:8] = buffer_data_1[2119:2112];
        layer1[8][23:16] = buffer_data_1[2127:2120];
        layer2[8][7:0] = buffer_data_0[2111:2104];
        layer2[8][15:8] = buffer_data_0[2119:2112];
        layer2[8][23:16] = buffer_data_0[2127:2120];
        layer0[9][7:0] = buffer_data_2[2119:2112];
        layer0[9][15:8] = buffer_data_2[2127:2120];
        layer0[9][23:16] = buffer_data_2[2135:2128];
        layer1[9][7:0] = buffer_data_1[2119:2112];
        layer1[9][15:8] = buffer_data_1[2127:2120];
        layer1[9][23:16] = buffer_data_1[2135:2128];
        layer2[9][7:0] = buffer_data_0[2119:2112];
        layer2[9][15:8] = buffer_data_0[2127:2120];
        layer2[9][23:16] = buffer_data_0[2135:2128];
        layer0[10][7:0] = buffer_data_2[2127:2120];
        layer0[10][15:8] = buffer_data_2[2135:2128];
        layer0[10][23:16] = buffer_data_2[2143:2136];
        layer1[10][7:0] = buffer_data_1[2127:2120];
        layer1[10][15:8] = buffer_data_1[2135:2128];
        layer1[10][23:16] = buffer_data_1[2143:2136];
        layer2[10][7:0] = buffer_data_0[2127:2120];
        layer2[10][15:8] = buffer_data_0[2135:2128];
        layer2[10][23:16] = buffer_data_0[2143:2136];
        layer0[11][7:0] = buffer_data_2[2135:2128];
        layer0[11][15:8] = buffer_data_2[2143:2136];
        layer0[11][23:16] = buffer_data_2[2151:2144];
        layer1[11][7:0] = buffer_data_1[2135:2128];
        layer1[11][15:8] = buffer_data_1[2143:2136];
        layer1[11][23:16] = buffer_data_1[2151:2144];
        layer2[11][7:0] = buffer_data_0[2135:2128];
        layer2[11][15:8] = buffer_data_0[2143:2136];
        layer2[11][23:16] = buffer_data_0[2151:2144];
        layer0[12][7:0] = buffer_data_2[2143:2136];
        layer0[12][15:8] = buffer_data_2[2151:2144];
        layer0[12][23:16] = buffer_data_2[2159:2152];
        layer1[12][7:0] = buffer_data_1[2143:2136];
        layer1[12][15:8] = buffer_data_1[2151:2144];
        layer1[12][23:16] = buffer_data_1[2159:2152];
        layer2[12][7:0] = buffer_data_0[2143:2136];
        layer2[12][15:8] = buffer_data_0[2151:2144];
        layer2[12][23:16] = buffer_data_0[2159:2152];
        layer0[13][7:0] = buffer_data_2[2151:2144];
        layer0[13][15:8] = buffer_data_2[2159:2152];
        layer0[13][23:16] = buffer_data_2[2167:2160];
        layer1[13][7:0] = buffer_data_1[2151:2144];
        layer1[13][15:8] = buffer_data_1[2159:2152];
        layer1[13][23:16] = buffer_data_1[2167:2160];
        layer2[13][7:0] = buffer_data_0[2151:2144];
        layer2[13][15:8] = buffer_data_0[2159:2152];
        layer2[13][23:16] = buffer_data_0[2167:2160];
        layer0[14][7:0] = buffer_data_2[2159:2152];
        layer0[14][15:8] = buffer_data_2[2167:2160];
        layer0[14][23:16] = buffer_data_2[2175:2168];
        layer1[14][7:0] = buffer_data_1[2159:2152];
        layer1[14][15:8] = buffer_data_1[2167:2160];
        layer1[14][23:16] = buffer_data_1[2175:2168];
        layer2[14][7:0] = buffer_data_0[2159:2152];
        layer2[14][15:8] = buffer_data_0[2167:2160];
        layer2[14][23:16] = buffer_data_0[2175:2168];
        layer0[15][7:0] = buffer_data_2[2167:2160];
        layer0[15][15:8] = buffer_data_2[2175:2168];
        layer0[15][23:16] = buffer_data_2[2183:2176];
        layer1[15][7:0] = buffer_data_1[2167:2160];
        layer1[15][15:8] = buffer_data_1[2175:2168];
        layer1[15][23:16] = buffer_data_1[2183:2176];
        layer2[15][7:0] = buffer_data_0[2167:2160];
        layer2[15][15:8] = buffer_data_0[2175:2168];
        layer2[15][23:16] = buffer_data_0[2183:2176];
        layer0[16][7:0] = buffer_data_2[2175:2168];
        layer0[16][15:8] = buffer_data_2[2183:2176];
        layer0[16][23:16] = buffer_data_2[2191:2184];
        layer1[16][7:0] = buffer_data_1[2175:2168];
        layer1[16][15:8] = buffer_data_1[2183:2176];
        layer1[16][23:16] = buffer_data_1[2191:2184];
        layer2[16][7:0] = buffer_data_0[2175:2168];
        layer2[16][15:8] = buffer_data_0[2183:2176];
        layer2[16][23:16] = buffer_data_0[2191:2184];
        layer0[17][7:0] = buffer_data_2[2183:2176];
        layer0[17][15:8] = buffer_data_2[2191:2184];
        layer0[17][23:16] = buffer_data_2[2199:2192];
        layer1[17][7:0] = buffer_data_1[2183:2176];
        layer1[17][15:8] = buffer_data_1[2191:2184];
        layer1[17][23:16] = buffer_data_1[2199:2192];
        layer2[17][7:0] = buffer_data_0[2183:2176];
        layer2[17][15:8] = buffer_data_0[2191:2184];
        layer2[17][23:16] = buffer_data_0[2199:2192];
        layer0[18][7:0] = buffer_data_2[2191:2184];
        layer0[18][15:8] = buffer_data_2[2199:2192];
        layer0[18][23:16] = buffer_data_2[2207:2200];
        layer1[18][7:0] = buffer_data_1[2191:2184];
        layer1[18][15:8] = buffer_data_1[2199:2192];
        layer1[18][23:16] = buffer_data_1[2207:2200];
        layer2[18][7:0] = buffer_data_0[2191:2184];
        layer2[18][15:8] = buffer_data_0[2199:2192];
        layer2[18][23:16] = buffer_data_0[2207:2200];
        layer0[19][7:0] = buffer_data_2[2199:2192];
        layer0[19][15:8] = buffer_data_2[2207:2200];
        layer0[19][23:16] = buffer_data_2[2215:2208];
        layer1[19][7:0] = buffer_data_1[2199:2192];
        layer1[19][15:8] = buffer_data_1[2207:2200];
        layer1[19][23:16] = buffer_data_1[2215:2208];
        layer2[19][7:0] = buffer_data_0[2199:2192];
        layer2[19][15:8] = buffer_data_0[2207:2200];
        layer2[19][23:16] = buffer_data_0[2215:2208];
        layer0[20][7:0] = buffer_data_2[2207:2200];
        layer0[20][15:8] = buffer_data_2[2215:2208];
        layer0[20][23:16] = buffer_data_2[2223:2216];
        layer1[20][7:0] = buffer_data_1[2207:2200];
        layer1[20][15:8] = buffer_data_1[2215:2208];
        layer1[20][23:16] = buffer_data_1[2223:2216];
        layer2[20][7:0] = buffer_data_0[2207:2200];
        layer2[20][15:8] = buffer_data_0[2215:2208];
        layer2[20][23:16] = buffer_data_0[2223:2216];
        layer0[21][7:0] = buffer_data_2[2215:2208];
        layer0[21][15:8] = buffer_data_2[2223:2216];
        layer0[21][23:16] = buffer_data_2[2231:2224];
        layer1[21][7:0] = buffer_data_1[2215:2208];
        layer1[21][15:8] = buffer_data_1[2223:2216];
        layer1[21][23:16] = buffer_data_1[2231:2224];
        layer2[21][7:0] = buffer_data_0[2215:2208];
        layer2[21][15:8] = buffer_data_0[2223:2216];
        layer2[21][23:16] = buffer_data_0[2231:2224];
        layer0[22][7:0] = buffer_data_2[2223:2216];
        layer0[22][15:8] = buffer_data_2[2231:2224];
        layer0[22][23:16] = buffer_data_2[2239:2232];
        layer1[22][7:0] = buffer_data_1[2223:2216];
        layer1[22][15:8] = buffer_data_1[2231:2224];
        layer1[22][23:16] = buffer_data_1[2239:2232];
        layer2[22][7:0] = buffer_data_0[2223:2216];
        layer2[22][15:8] = buffer_data_0[2231:2224];
        layer2[22][23:16] = buffer_data_0[2239:2232];
        layer0[23][7:0] = buffer_data_2[2231:2224];
        layer0[23][15:8] = buffer_data_2[2239:2232];
        layer0[23][23:16] = buffer_data_2[2247:2240];
        layer1[23][7:0] = buffer_data_1[2231:2224];
        layer1[23][15:8] = buffer_data_1[2239:2232];
        layer1[23][23:16] = buffer_data_1[2247:2240];
        layer2[23][7:0] = buffer_data_0[2231:2224];
        layer2[23][15:8] = buffer_data_0[2239:2232];
        layer2[23][23:16] = buffer_data_0[2247:2240];
        layer0[24][7:0] = buffer_data_2[2239:2232];
        layer0[24][15:8] = buffer_data_2[2247:2240];
        layer0[24][23:16] = buffer_data_2[2255:2248];
        layer1[24][7:0] = buffer_data_1[2239:2232];
        layer1[24][15:8] = buffer_data_1[2247:2240];
        layer1[24][23:16] = buffer_data_1[2255:2248];
        layer2[24][7:0] = buffer_data_0[2239:2232];
        layer2[24][15:8] = buffer_data_0[2247:2240];
        layer2[24][23:16] = buffer_data_0[2255:2248];
        layer0[25][7:0] = buffer_data_2[2247:2240];
        layer0[25][15:8] = buffer_data_2[2255:2248];
        layer0[25][23:16] = buffer_data_2[2263:2256];
        layer1[25][7:0] = buffer_data_1[2247:2240];
        layer1[25][15:8] = buffer_data_1[2255:2248];
        layer1[25][23:16] = buffer_data_1[2263:2256];
        layer2[25][7:0] = buffer_data_0[2247:2240];
        layer2[25][15:8] = buffer_data_0[2255:2248];
        layer2[25][23:16] = buffer_data_0[2263:2256];
        layer0[26][7:0] = buffer_data_2[2255:2248];
        layer0[26][15:8] = buffer_data_2[2263:2256];
        layer0[26][23:16] = buffer_data_2[2271:2264];
        layer1[26][7:0] = buffer_data_1[2255:2248];
        layer1[26][15:8] = buffer_data_1[2263:2256];
        layer1[26][23:16] = buffer_data_1[2271:2264];
        layer2[26][7:0] = buffer_data_0[2255:2248];
        layer2[26][15:8] = buffer_data_0[2263:2256];
        layer2[26][23:16] = buffer_data_0[2271:2264];
        layer0[27][7:0] = buffer_data_2[2263:2256];
        layer0[27][15:8] = buffer_data_2[2271:2264];
        layer0[27][23:16] = buffer_data_2[2279:2272];
        layer1[27][7:0] = buffer_data_1[2263:2256];
        layer1[27][15:8] = buffer_data_1[2271:2264];
        layer1[27][23:16] = buffer_data_1[2279:2272];
        layer2[27][7:0] = buffer_data_0[2263:2256];
        layer2[27][15:8] = buffer_data_0[2271:2264];
        layer2[27][23:16] = buffer_data_0[2279:2272];
        layer0[28][7:0] = buffer_data_2[2271:2264];
        layer0[28][15:8] = buffer_data_2[2279:2272];
        layer0[28][23:16] = buffer_data_2[2287:2280];
        layer1[28][7:0] = buffer_data_1[2271:2264];
        layer1[28][15:8] = buffer_data_1[2279:2272];
        layer1[28][23:16] = buffer_data_1[2287:2280];
        layer2[28][7:0] = buffer_data_0[2271:2264];
        layer2[28][15:8] = buffer_data_0[2279:2272];
        layer2[28][23:16] = buffer_data_0[2287:2280];
        layer0[29][7:0] = buffer_data_2[2279:2272];
        layer0[29][15:8] = buffer_data_2[2287:2280];
        layer0[29][23:16] = buffer_data_2[2295:2288];
        layer1[29][7:0] = buffer_data_1[2279:2272];
        layer1[29][15:8] = buffer_data_1[2287:2280];
        layer1[29][23:16] = buffer_data_1[2295:2288];
        layer2[29][7:0] = buffer_data_0[2279:2272];
        layer2[29][15:8] = buffer_data_0[2287:2280];
        layer2[29][23:16] = buffer_data_0[2295:2288];
        layer0[30][7:0] = buffer_data_2[2287:2280];
        layer0[30][15:8] = buffer_data_2[2295:2288];
        layer0[30][23:16] = buffer_data_2[2303:2296];
        layer1[30][7:0] = buffer_data_1[2287:2280];
        layer1[30][15:8] = buffer_data_1[2295:2288];
        layer1[30][23:16] = buffer_data_1[2303:2296];
        layer2[30][7:0] = buffer_data_0[2287:2280];
        layer2[30][15:8] = buffer_data_0[2295:2288];
        layer2[30][23:16] = buffer_data_0[2303:2296];
        layer0[31][7:0] = buffer_data_2[2295:2288];
        layer0[31][15:8] = buffer_data_2[2303:2296];
        layer0[31][23:16] = buffer_data_2[2311:2304];
        layer1[31][7:0] = buffer_data_1[2295:2288];
        layer1[31][15:8] = buffer_data_1[2303:2296];
        layer1[31][23:16] = buffer_data_1[2311:2304];
        layer2[31][7:0] = buffer_data_0[2295:2288];
        layer2[31][15:8] = buffer_data_0[2303:2296];
        layer2[31][23:16] = buffer_data_0[2311:2304];
        layer0[32][7:0] = buffer_data_2[2303:2296];
        layer0[32][15:8] = buffer_data_2[2311:2304];
        layer0[32][23:16] = buffer_data_2[2319:2312];
        layer1[32][7:0] = buffer_data_1[2303:2296];
        layer1[32][15:8] = buffer_data_1[2311:2304];
        layer1[32][23:16] = buffer_data_1[2319:2312];
        layer2[32][7:0] = buffer_data_0[2303:2296];
        layer2[32][15:8] = buffer_data_0[2311:2304];
        layer2[32][23:16] = buffer_data_0[2319:2312];
        layer0[33][7:0] = buffer_data_2[2311:2304];
        layer0[33][15:8] = buffer_data_2[2319:2312];
        layer0[33][23:16] = buffer_data_2[2327:2320];
        layer1[33][7:0] = buffer_data_1[2311:2304];
        layer1[33][15:8] = buffer_data_1[2319:2312];
        layer1[33][23:16] = buffer_data_1[2327:2320];
        layer2[33][7:0] = buffer_data_0[2311:2304];
        layer2[33][15:8] = buffer_data_0[2319:2312];
        layer2[33][23:16] = buffer_data_0[2327:2320];
        layer0[34][7:0] = buffer_data_2[2319:2312];
        layer0[34][15:8] = buffer_data_2[2327:2320];
        layer0[34][23:16] = buffer_data_2[2335:2328];
        layer1[34][7:0] = buffer_data_1[2319:2312];
        layer1[34][15:8] = buffer_data_1[2327:2320];
        layer1[34][23:16] = buffer_data_1[2335:2328];
        layer2[34][7:0] = buffer_data_0[2319:2312];
        layer2[34][15:8] = buffer_data_0[2327:2320];
        layer2[34][23:16] = buffer_data_0[2335:2328];
        layer0[35][7:0] = buffer_data_2[2327:2320];
        layer0[35][15:8] = buffer_data_2[2335:2328];
        layer0[35][23:16] = buffer_data_2[2343:2336];
        layer1[35][7:0] = buffer_data_1[2327:2320];
        layer1[35][15:8] = buffer_data_1[2335:2328];
        layer1[35][23:16] = buffer_data_1[2343:2336];
        layer2[35][7:0] = buffer_data_0[2327:2320];
        layer2[35][15:8] = buffer_data_0[2335:2328];
        layer2[35][23:16] = buffer_data_0[2343:2336];
        layer0[36][7:0] = buffer_data_2[2335:2328];
        layer0[36][15:8] = buffer_data_2[2343:2336];
        layer0[36][23:16] = buffer_data_2[2351:2344];
        layer1[36][7:0] = buffer_data_1[2335:2328];
        layer1[36][15:8] = buffer_data_1[2343:2336];
        layer1[36][23:16] = buffer_data_1[2351:2344];
        layer2[36][7:0] = buffer_data_0[2335:2328];
        layer2[36][15:8] = buffer_data_0[2343:2336];
        layer2[36][23:16] = buffer_data_0[2351:2344];
        layer0[37][7:0] = buffer_data_2[2343:2336];
        layer0[37][15:8] = buffer_data_2[2351:2344];
        layer0[37][23:16] = buffer_data_2[2359:2352];
        layer1[37][7:0] = buffer_data_1[2343:2336];
        layer1[37][15:8] = buffer_data_1[2351:2344];
        layer1[37][23:16] = buffer_data_1[2359:2352];
        layer2[37][7:0] = buffer_data_0[2343:2336];
        layer2[37][15:8] = buffer_data_0[2351:2344];
        layer2[37][23:16] = buffer_data_0[2359:2352];
        layer0[38][7:0] = buffer_data_2[2351:2344];
        layer0[38][15:8] = buffer_data_2[2359:2352];
        layer0[38][23:16] = buffer_data_2[2367:2360];
        layer1[38][7:0] = buffer_data_1[2351:2344];
        layer1[38][15:8] = buffer_data_1[2359:2352];
        layer1[38][23:16] = buffer_data_1[2367:2360];
        layer2[38][7:0] = buffer_data_0[2351:2344];
        layer2[38][15:8] = buffer_data_0[2359:2352];
        layer2[38][23:16] = buffer_data_0[2367:2360];
        layer0[39][7:0] = buffer_data_2[2359:2352];
        layer0[39][15:8] = buffer_data_2[2367:2360];
        layer0[39][23:16] = buffer_data_2[2375:2368];
        layer1[39][7:0] = buffer_data_1[2359:2352];
        layer1[39][15:8] = buffer_data_1[2367:2360];
        layer1[39][23:16] = buffer_data_1[2375:2368];
        layer2[39][7:0] = buffer_data_0[2359:2352];
        layer2[39][15:8] = buffer_data_0[2367:2360];
        layer2[39][23:16] = buffer_data_0[2375:2368];
        layer0[40][7:0] = buffer_data_2[2367:2360];
        layer0[40][15:8] = buffer_data_2[2375:2368];
        layer0[40][23:16] = buffer_data_2[2383:2376];
        layer1[40][7:0] = buffer_data_1[2367:2360];
        layer1[40][15:8] = buffer_data_1[2375:2368];
        layer1[40][23:16] = buffer_data_1[2383:2376];
        layer2[40][7:0] = buffer_data_0[2367:2360];
        layer2[40][15:8] = buffer_data_0[2375:2368];
        layer2[40][23:16] = buffer_data_0[2383:2376];
        layer0[41][7:0] = buffer_data_2[2375:2368];
        layer0[41][15:8] = buffer_data_2[2383:2376];
        layer0[41][23:16] = buffer_data_2[2391:2384];
        layer1[41][7:0] = buffer_data_1[2375:2368];
        layer1[41][15:8] = buffer_data_1[2383:2376];
        layer1[41][23:16] = buffer_data_1[2391:2384];
        layer2[41][7:0] = buffer_data_0[2375:2368];
        layer2[41][15:8] = buffer_data_0[2383:2376];
        layer2[41][23:16] = buffer_data_0[2391:2384];
        layer0[42][7:0] = buffer_data_2[2383:2376];
        layer0[42][15:8] = buffer_data_2[2391:2384];
        layer0[42][23:16] = buffer_data_2[2399:2392];
        layer1[42][7:0] = buffer_data_1[2383:2376];
        layer1[42][15:8] = buffer_data_1[2391:2384];
        layer1[42][23:16] = buffer_data_1[2399:2392];
        layer2[42][7:0] = buffer_data_0[2383:2376];
        layer2[42][15:8] = buffer_data_0[2391:2384];
        layer2[42][23:16] = buffer_data_0[2399:2392];
        layer0[43][7:0] = buffer_data_2[2391:2384];
        layer0[43][15:8] = buffer_data_2[2399:2392];
        layer0[43][23:16] = buffer_data_2[2407:2400];
        layer1[43][7:0] = buffer_data_1[2391:2384];
        layer1[43][15:8] = buffer_data_1[2399:2392];
        layer1[43][23:16] = buffer_data_1[2407:2400];
        layer2[43][7:0] = buffer_data_0[2391:2384];
        layer2[43][15:8] = buffer_data_0[2399:2392];
        layer2[43][23:16] = buffer_data_0[2407:2400];
        layer0[44][7:0] = buffer_data_2[2399:2392];
        layer0[44][15:8] = buffer_data_2[2407:2400];
        layer0[44][23:16] = buffer_data_2[2415:2408];
        layer1[44][7:0] = buffer_data_1[2399:2392];
        layer1[44][15:8] = buffer_data_1[2407:2400];
        layer1[44][23:16] = buffer_data_1[2415:2408];
        layer2[44][7:0] = buffer_data_0[2399:2392];
        layer2[44][15:8] = buffer_data_0[2407:2400];
        layer2[44][23:16] = buffer_data_0[2415:2408];
        layer0[45][7:0] = buffer_data_2[2407:2400];
        layer0[45][15:8] = buffer_data_2[2415:2408];
        layer0[45][23:16] = buffer_data_2[2423:2416];
        layer1[45][7:0] = buffer_data_1[2407:2400];
        layer1[45][15:8] = buffer_data_1[2415:2408];
        layer1[45][23:16] = buffer_data_1[2423:2416];
        layer2[45][7:0] = buffer_data_0[2407:2400];
        layer2[45][15:8] = buffer_data_0[2415:2408];
        layer2[45][23:16] = buffer_data_0[2423:2416];
        layer0[46][7:0] = buffer_data_2[2415:2408];
        layer0[46][15:8] = buffer_data_2[2423:2416];
        layer0[46][23:16] = buffer_data_2[2431:2424];
        layer1[46][7:0] = buffer_data_1[2415:2408];
        layer1[46][15:8] = buffer_data_1[2423:2416];
        layer1[46][23:16] = buffer_data_1[2431:2424];
        layer2[46][7:0] = buffer_data_0[2415:2408];
        layer2[46][15:8] = buffer_data_0[2423:2416];
        layer2[46][23:16] = buffer_data_0[2431:2424];
        layer0[47][7:0] = buffer_data_2[2423:2416];
        layer0[47][15:8] = buffer_data_2[2431:2424];
        layer0[47][23:16] = buffer_data_2[2439:2432];
        layer1[47][7:0] = buffer_data_1[2423:2416];
        layer1[47][15:8] = buffer_data_1[2431:2424];
        layer1[47][23:16] = buffer_data_1[2439:2432];
        layer2[47][7:0] = buffer_data_0[2423:2416];
        layer2[47][15:8] = buffer_data_0[2431:2424];
        layer2[47][23:16] = buffer_data_0[2439:2432];
        layer0[48][7:0] = buffer_data_2[2431:2424];
        layer0[48][15:8] = buffer_data_2[2439:2432];
        layer0[48][23:16] = buffer_data_2[2447:2440];
        layer1[48][7:0] = buffer_data_1[2431:2424];
        layer1[48][15:8] = buffer_data_1[2439:2432];
        layer1[48][23:16] = buffer_data_1[2447:2440];
        layer2[48][7:0] = buffer_data_0[2431:2424];
        layer2[48][15:8] = buffer_data_0[2439:2432];
        layer2[48][23:16] = buffer_data_0[2447:2440];
        layer0[49][7:0] = buffer_data_2[2439:2432];
        layer0[49][15:8] = buffer_data_2[2447:2440];
        layer0[49][23:16] = buffer_data_2[2455:2448];
        layer1[49][7:0] = buffer_data_1[2439:2432];
        layer1[49][15:8] = buffer_data_1[2447:2440];
        layer1[49][23:16] = buffer_data_1[2455:2448];
        layer2[49][7:0] = buffer_data_0[2439:2432];
        layer2[49][15:8] = buffer_data_0[2447:2440];
        layer2[49][23:16] = buffer_data_0[2455:2448];
        layer0[50][7:0] = buffer_data_2[2447:2440];
        layer0[50][15:8] = buffer_data_2[2455:2448];
        layer0[50][23:16] = buffer_data_2[2463:2456];
        layer1[50][7:0] = buffer_data_1[2447:2440];
        layer1[50][15:8] = buffer_data_1[2455:2448];
        layer1[50][23:16] = buffer_data_1[2463:2456];
        layer2[50][7:0] = buffer_data_0[2447:2440];
        layer2[50][15:8] = buffer_data_0[2455:2448];
        layer2[50][23:16] = buffer_data_0[2463:2456];
        layer0[51][7:0] = buffer_data_2[2455:2448];
        layer0[51][15:8] = buffer_data_2[2463:2456];
        layer0[51][23:16] = buffer_data_2[2471:2464];
        layer1[51][7:0] = buffer_data_1[2455:2448];
        layer1[51][15:8] = buffer_data_1[2463:2456];
        layer1[51][23:16] = buffer_data_1[2471:2464];
        layer2[51][7:0] = buffer_data_0[2455:2448];
        layer2[51][15:8] = buffer_data_0[2463:2456];
        layer2[51][23:16] = buffer_data_0[2471:2464];
        layer0[52][7:0] = buffer_data_2[2463:2456];
        layer0[52][15:8] = buffer_data_2[2471:2464];
        layer0[52][23:16] = buffer_data_2[2479:2472];
        layer1[52][7:0] = buffer_data_1[2463:2456];
        layer1[52][15:8] = buffer_data_1[2471:2464];
        layer1[52][23:16] = buffer_data_1[2479:2472];
        layer2[52][7:0] = buffer_data_0[2463:2456];
        layer2[52][15:8] = buffer_data_0[2471:2464];
        layer2[52][23:16] = buffer_data_0[2479:2472];
        layer0[53][7:0] = buffer_data_2[2471:2464];
        layer0[53][15:8] = buffer_data_2[2479:2472];
        layer0[53][23:16] = buffer_data_2[2487:2480];
        layer1[53][7:0] = buffer_data_1[2471:2464];
        layer1[53][15:8] = buffer_data_1[2479:2472];
        layer1[53][23:16] = buffer_data_1[2487:2480];
        layer2[53][7:0] = buffer_data_0[2471:2464];
        layer2[53][15:8] = buffer_data_0[2479:2472];
        layer2[53][23:16] = buffer_data_0[2487:2480];
        layer0[54][7:0] = buffer_data_2[2479:2472];
        layer0[54][15:8] = buffer_data_2[2487:2480];
        layer0[54][23:16] = buffer_data_2[2495:2488];
        layer1[54][7:0] = buffer_data_1[2479:2472];
        layer1[54][15:8] = buffer_data_1[2487:2480];
        layer1[54][23:16] = buffer_data_1[2495:2488];
        layer2[54][7:0] = buffer_data_0[2479:2472];
        layer2[54][15:8] = buffer_data_0[2487:2480];
        layer2[54][23:16] = buffer_data_0[2495:2488];
        layer0[55][7:0] = buffer_data_2[2487:2480];
        layer0[55][15:8] = buffer_data_2[2495:2488];
        layer0[55][23:16] = buffer_data_2[2503:2496];
        layer1[55][7:0] = buffer_data_1[2487:2480];
        layer1[55][15:8] = buffer_data_1[2495:2488];
        layer1[55][23:16] = buffer_data_1[2503:2496];
        layer2[55][7:0] = buffer_data_0[2487:2480];
        layer2[55][15:8] = buffer_data_0[2495:2488];
        layer2[55][23:16] = buffer_data_0[2503:2496];
        layer0[56][7:0] = buffer_data_2[2495:2488];
        layer0[56][15:8] = buffer_data_2[2503:2496];
        layer0[56][23:16] = buffer_data_2[2511:2504];
        layer1[56][7:0] = buffer_data_1[2495:2488];
        layer1[56][15:8] = buffer_data_1[2503:2496];
        layer1[56][23:16] = buffer_data_1[2511:2504];
        layer2[56][7:0] = buffer_data_0[2495:2488];
        layer2[56][15:8] = buffer_data_0[2503:2496];
        layer2[56][23:16] = buffer_data_0[2511:2504];
        layer0[57][7:0] = buffer_data_2[2503:2496];
        layer0[57][15:8] = buffer_data_2[2511:2504];
        layer0[57][23:16] = buffer_data_2[2519:2512];
        layer1[57][7:0] = buffer_data_1[2503:2496];
        layer1[57][15:8] = buffer_data_1[2511:2504];
        layer1[57][23:16] = buffer_data_1[2519:2512];
        layer2[57][7:0] = buffer_data_0[2503:2496];
        layer2[57][15:8] = buffer_data_0[2511:2504];
        layer2[57][23:16] = buffer_data_0[2519:2512];
        layer0[58][7:0] = buffer_data_2[2511:2504];
        layer0[58][15:8] = buffer_data_2[2519:2512];
        layer0[58][23:16] = buffer_data_2[2527:2520];
        layer1[58][7:0] = buffer_data_1[2511:2504];
        layer1[58][15:8] = buffer_data_1[2519:2512];
        layer1[58][23:16] = buffer_data_1[2527:2520];
        layer2[58][7:0] = buffer_data_0[2511:2504];
        layer2[58][15:8] = buffer_data_0[2519:2512];
        layer2[58][23:16] = buffer_data_0[2527:2520];
        layer0[59][7:0] = buffer_data_2[2519:2512];
        layer0[59][15:8] = buffer_data_2[2527:2520];
        layer0[59][23:16] = buffer_data_2[2535:2528];
        layer1[59][7:0] = buffer_data_1[2519:2512];
        layer1[59][15:8] = buffer_data_1[2527:2520];
        layer1[59][23:16] = buffer_data_1[2535:2528];
        layer2[59][7:0] = buffer_data_0[2519:2512];
        layer2[59][15:8] = buffer_data_0[2527:2520];
        layer2[59][23:16] = buffer_data_0[2535:2528];
        layer0[60][7:0] = buffer_data_2[2527:2520];
        layer0[60][15:8] = buffer_data_2[2535:2528];
        layer0[60][23:16] = buffer_data_2[2543:2536];
        layer1[60][7:0] = buffer_data_1[2527:2520];
        layer1[60][15:8] = buffer_data_1[2535:2528];
        layer1[60][23:16] = buffer_data_1[2543:2536];
        layer2[60][7:0] = buffer_data_0[2527:2520];
        layer2[60][15:8] = buffer_data_0[2535:2528];
        layer2[60][23:16] = buffer_data_0[2543:2536];
        layer0[61][7:0] = buffer_data_2[2535:2528];
        layer0[61][15:8] = buffer_data_2[2543:2536];
        layer0[61][23:16] = buffer_data_2[2551:2544];
        layer1[61][7:0] = buffer_data_1[2535:2528];
        layer1[61][15:8] = buffer_data_1[2543:2536];
        layer1[61][23:16] = buffer_data_1[2551:2544];
        layer2[61][7:0] = buffer_data_0[2535:2528];
        layer2[61][15:8] = buffer_data_0[2543:2536];
        layer2[61][23:16] = buffer_data_0[2551:2544];
        layer0[62][7:0] = buffer_data_2[2543:2536];
        layer0[62][15:8] = buffer_data_2[2551:2544];
        layer0[62][23:16] = buffer_data_2[2559:2552];
        layer1[62][7:0] = buffer_data_1[2543:2536];
        layer1[62][15:8] = buffer_data_1[2551:2544];
        layer1[62][23:16] = buffer_data_1[2559:2552];
        layer2[62][7:0] = buffer_data_0[2543:2536];
        layer2[62][15:8] = buffer_data_0[2551:2544];
        layer2[62][23:16] = buffer_data_0[2559:2552];
        layer0[63][7:0] = buffer_data_2[2551:2544];
        layer0[63][15:8] = buffer_data_2[2559:2552];
        layer0[63][23:16] = buffer_data_2[2567:2560];
        layer1[63][7:0] = buffer_data_1[2551:2544];
        layer1[63][15:8] = buffer_data_1[2559:2552];
        layer1[63][23:16] = buffer_data_1[2567:2560];
        layer2[63][7:0] = buffer_data_0[2551:2544];
        layer2[63][15:8] = buffer_data_0[2559:2552];
        layer2[63][23:16] = buffer_data_0[2567:2560];
    end
    ST_GAUSSIAN_5: begin
        layer0[0][7:0] = buffer_data_2[2559:2552];
        layer0[0][15:8] = buffer_data_2[2567:2560];
        layer0[0][23:16] = buffer_data_2[2575:2568];
        layer1[0][7:0] = buffer_data_1[2559:2552];
        layer1[0][15:8] = buffer_data_1[2567:2560];
        layer1[0][23:16] = buffer_data_1[2575:2568];
        layer2[0][7:0] = buffer_data_0[2559:2552];
        layer2[0][15:8] = buffer_data_0[2567:2560];
        layer2[0][23:16] = buffer_data_0[2575:2568];
        layer0[1][7:0] = buffer_data_2[2567:2560];
        layer0[1][15:8] = buffer_data_2[2575:2568];
        layer0[1][23:16] = buffer_data_2[2583:2576];
        layer1[1][7:0] = buffer_data_1[2567:2560];
        layer1[1][15:8] = buffer_data_1[2575:2568];
        layer1[1][23:16] = buffer_data_1[2583:2576];
        layer2[1][7:0] = buffer_data_0[2567:2560];
        layer2[1][15:8] = buffer_data_0[2575:2568];
        layer2[1][23:16] = buffer_data_0[2583:2576];
        layer0[2][7:0] = buffer_data_2[2575:2568];
        layer0[2][15:8] = buffer_data_2[2583:2576];
        layer0[2][23:16] = buffer_data_2[2591:2584];
        layer1[2][7:0] = buffer_data_1[2575:2568];
        layer1[2][15:8] = buffer_data_1[2583:2576];
        layer1[2][23:16] = buffer_data_1[2591:2584];
        layer2[2][7:0] = buffer_data_0[2575:2568];
        layer2[2][15:8] = buffer_data_0[2583:2576];
        layer2[2][23:16] = buffer_data_0[2591:2584];
        layer0[3][7:0] = buffer_data_2[2583:2576];
        layer0[3][15:8] = buffer_data_2[2591:2584];
        layer0[3][23:16] = buffer_data_2[2599:2592];
        layer1[3][7:0] = buffer_data_1[2583:2576];
        layer1[3][15:8] = buffer_data_1[2591:2584];
        layer1[3][23:16] = buffer_data_1[2599:2592];
        layer2[3][7:0] = buffer_data_0[2583:2576];
        layer2[3][15:8] = buffer_data_0[2591:2584];
        layer2[3][23:16] = buffer_data_0[2599:2592];
        layer0[4][7:0] = buffer_data_2[2591:2584];
        layer0[4][15:8] = buffer_data_2[2599:2592];
        layer0[4][23:16] = buffer_data_2[2607:2600];
        layer1[4][7:0] = buffer_data_1[2591:2584];
        layer1[4][15:8] = buffer_data_1[2599:2592];
        layer1[4][23:16] = buffer_data_1[2607:2600];
        layer2[4][7:0] = buffer_data_0[2591:2584];
        layer2[4][15:8] = buffer_data_0[2599:2592];
        layer2[4][23:16] = buffer_data_0[2607:2600];
        layer0[5][7:0] = buffer_data_2[2599:2592];
        layer0[5][15:8] = buffer_data_2[2607:2600];
        layer0[5][23:16] = buffer_data_2[2615:2608];
        layer1[5][7:0] = buffer_data_1[2599:2592];
        layer1[5][15:8] = buffer_data_1[2607:2600];
        layer1[5][23:16] = buffer_data_1[2615:2608];
        layer2[5][7:0] = buffer_data_0[2599:2592];
        layer2[5][15:8] = buffer_data_0[2607:2600];
        layer2[5][23:16] = buffer_data_0[2615:2608];
        layer0[6][7:0] = buffer_data_2[2607:2600];
        layer0[6][15:8] = buffer_data_2[2615:2608];
        layer0[6][23:16] = buffer_data_2[2623:2616];
        layer1[6][7:0] = buffer_data_1[2607:2600];
        layer1[6][15:8] = buffer_data_1[2615:2608];
        layer1[6][23:16] = buffer_data_1[2623:2616];
        layer2[6][7:0] = buffer_data_0[2607:2600];
        layer2[6][15:8] = buffer_data_0[2615:2608];
        layer2[6][23:16] = buffer_data_0[2623:2616];
        layer0[7][7:0] = buffer_data_2[2615:2608];
        layer0[7][15:8] = buffer_data_2[2623:2616];
        layer0[7][23:16] = buffer_data_2[2631:2624];
        layer1[7][7:0] = buffer_data_1[2615:2608];
        layer1[7][15:8] = buffer_data_1[2623:2616];
        layer1[7][23:16] = buffer_data_1[2631:2624];
        layer2[7][7:0] = buffer_data_0[2615:2608];
        layer2[7][15:8] = buffer_data_0[2623:2616];
        layer2[7][23:16] = buffer_data_0[2631:2624];
        layer0[8][7:0] = buffer_data_2[2623:2616];
        layer0[8][15:8] = buffer_data_2[2631:2624];
        layer0[8][23:16] = buffer_data_2[2639:2632];
        layer1[8][7:0] = buffer_data_1[2623:2616];
        layer1[8][15:8] = buffer_data_1[2631:2624];
        layer1[8][23:16] = buffer_data_1[2639:2632];
        layer2[8][7:0] = buffer_data_0[2623:2616];
        layer2[8][15:8] = buffer_data_0[2631:2624];
        layer2[8][23:16] = buffer_data_0[2639:2632];
        layer0[9][7:0] = buffer_data_2[2631:2624];
        layer0[9][15:8] = buffer_data_2[2639:2632];
        layer0[9][23:16] = buffer_data_2[2647:2640];
        layer1[9][7:0] = buffer_data_1[2631:2624];
        layer1[9][15:8] = buffer_data_1[2639:2632];
        layer1[9][23:16] = buffer_data_1[2647:2640];
        layer2[9][7:0] = buffer_data_0[2631:2624];
        layer2[9][15:8] = buffer_data_0[2639:2632];
        layer2[9][23:16] = buffer_data_0[2647:2640];
        layer0[10][7:0] = buffer_data_2[2639:2632];
        layer0[10][15:8] = buffer_data_2[2647:2640];
        layer0[10][23:16] = buffer_data_2[2655:2648];
        layer1[10][7:0] = buffer_data_1[2639:2632];
        layer1[10][15:8] = buffer_data_1[2647:2640];
        layer1[10][23:16] = buffer_data_1[2655:2648];
        layer2[10][7:0] = buffer_data_0[2639:2632];
        layer2[10][15:8] = buffer_data_0[2647:2640];
        layer2[10][23:16] = buffer_data_0[2655:2648];
        layer0[11][7:0] = buffer_data_2[2647:2640];
        layer0[11][15:8] = buffer_data_2[2655:2648];
        layer0[11][23:16] = buffer_data_2[2663:2656];
        layer1[11][7:0] = buffer_data_1[2647:2640];
        layer1[11][15:8] = buffer_data_1[2655:2648];
        layer1[11][23:16] = buffer_data_1[2663:2656];
        layer2[11][7:0] = buffer_data_0[2647:2640];
        layer2[11][15:8] = buffer_data_0[2655:2648];
        layer2[11][23:16] = buffer_data_0[2663:2656];
        layer0[12][7:0] = buffer_data_2[2655:2648];
        layer0[12][15:8] = buffer_data_2[2663:2656];
        layer0[12][23:16] = buffer_data_2[2671:2664];
        layer1[12][7:0] = buffer_data_1[2655:2648];
        layer1[12][15:8] = buffer_data_1[2663:2656];
        layer1[12][23:16] = buffer_data_1[2671:2664];
        layer2[12][7:0] = buffer_data_0[2655:2648];
        layer2[12][15:8] = buffer_data_0[2663:2656];
        layer2[12][23:16] = buffer_data_0[2671:2664];
        layer0[13][7:0] = buffer_data_2[2663:2656];
        layer0[13][15:8] = buffer_data_2[2671:2664];
        layer0[13][23:16] = buffer_data_2[2679:2672];
        layer1[13][7:0] = buffer_data_1[2663:2656];
        layer1[13][15:8] = buffer_data_1[2671:2664];
        layer1[13][23:16] = buffer_data_1[2679:2672];
        layer2[13][7:0] = buffer_data_0[2663:2656];
        layer2[13][15:8] = buffer_data_0[2671:2664];
        layer2[13][23:16] = buffer_data_0[2679:2672];
        layer0[14][7:0] = buffer_data_2[2671:2664];
        layer0[14][15:8] = buffer_data_2[2679:2672];
        layer0[14][23:16] = buffer_data_2[2687:2680];
        layer1[14][7:0] = buffer_data_1[2671:2664];
        layer1[14][15:8] = buffer_data_1[2679:2672];
        layer1[14][23:16] = buffer_data_1[2687:2680];
        layer2[14][7:0] = buffer_data_0[2671:2664];
        layer2[14][15:8] = buffer_data_0[2679:2672];
        layer2[14][23:16] = buffer_data_0[2687:2680];
        layer0[15][7:0] = buffer_data_2[2679:2672];
        layer0[15][15:8] = buffer_data_2[2687:2680];
        layer0[15][23:16] = buffer_data_2[2695:2688];
        layer1[15][7:0] = buffer_data_1[2679:2672];
        layer1[15][15:8] = buffer_data_1[2687:2680];
        layer1[15][23:16] = buffer_data_1[2695:2688];
        layer2[15][7:0] = buffer_data_0[2679:2672];
        layer2[15][15:8] = buffer_data_0[2687:2680];
        layer2[15][23:16] = buffer_data_0[2695:2688];
        layer0[16][7:0] = buffer_data_2[2687:2680];
        layer0[16][15:8] = buffer_data_2[2695:2688];
        layer0[16][23:16] = buffer_data_2[2703:2696];
        layer1[16][7:0] = buffer_data_1[2687:2680];
        layer1[16][15:8] = buffer_data_1[2695:2688];
        layer1[16][23:16] = buffer_data_1[2703:2696];
        layer2[16][7:0] = buffer_data_0[2687:2680];
        layer2[16][15:8] = buffer_data_0[2695:2688];
        layer2[16][23:16] = buffer_data_0[2703:2696];
        layer0[17][7:0] = buffer_data_2[2695:2688];
        layer0[17][15:8] = buffer_data_2[2703:2696];
        layer0[17][23:16] = buffer_data_2[2711:2704];
        layer1[17][7:0] = buffer_data_1[2695:2688];
        layer1[17][15:8] = buffer_data_1[2703:2696];
        layer1[17][23:16] = buffer_data_1[2711:2704];
        layer2[17][7:0] = buffer_data_0[2695:2688];
        layer2[17][15:8] = buffer_data_0[2703:2696];
        layer2[17][23:16] = buffer_data_0[2711:2704];
        layer0[18][7:0] = buffer_data_2[2703:2696];
        layer0[18][15:8] = buffer_data_2[2711:2704];
        layer0[18][23:16] = buffer_data_2[2719:2712];
        layer1[18][7:0] = buffer_data_1[2703:2696];
        layer1[18][15:8] = buffer_data_1[2711:2704];
        layer1[18][23:16] = buffer_data_1[2719:2712];
        layer2[18][7:0] = buffer_data_0[2703:2696];
        layer2[18][15:8] = buffer_data_0[2711:2704];
        layer2[18][23:16] = buffer_data_0[2719:2712];
        layer0[19][7:0] = buffer_data_2[2711:2704];
        layer0[19][15:8] = buffer_data_2[2719:2712];
        layer0[19][23:16] = buffer_data_2[2727:2720];
        layer1[19][7:0] = buffer_data_1[2711:2704];
        layer1[19][15:8] = buffer_data_1[2719:2712];
        layer1[19][23:16] = buffer_data_1[2727:2720];
        layer2[19][7:0] = buffer_data_0[2711:2704];
        layer2[19][15:8] = buffer_data_0[2719:2712];
        layer2[19][23:16] = buffer_data_0[2727:2720];
        layer0[20][7:0] = buffer_data_2[2719:2712];
        layer0[20][15:8] = buffer_data_2[2727:2720];
        layer0[20][23:16] = buffer_data_2[2735:2728];
        layer1[20][7:0] = buffer_data_1[2719:2712];
        layer1[20][15:8] = buffer_data_1[2727:2720];
        layer1[20][23:16] = buffer_data_1[2735:2728];
        layer2[20][7:0] = buffer_data_0[2719:2712];
        layer2[20][15:8] = buffer_data_0[2727:2720];
        layer2[20][23:16] = buffer_data_0[2735:2728];
        layer0[21][7:0] = buffer_data_2[2727:2720];
        layer0[21][15:8] = buffer_data_2[2735:2728];
        layer0[21][23:16] = buffer_data_2[2743:2736];
        layer1[21][7:0] = buffer_data_1[2727:2720];
        layer1[21][15:8] = buffer_data_1[2735:2728];
        layer1[21][23:16] = buffer_data_1[2743:2736];
        layer2[21][7:0] = buffer_data_0[2727:2720];
        layer2[21][15:8] = buffer_data_0[2735:2728];
        layer2[21][23:16] = buffer_data_0[2743:2736];
        layer0[22][7:0] = buffer_data_2[2735:2728];
        layer0[22][15:8] = buffer_data_2[2743:2736];
        layer0[22][23:16] = buffer_data_2[2751:2744];
        layer1[22][7:0] = buffer_data_1[2735:2728];
        layer1[22][15:8] = buffer_data_1[2743:2736];
        layer1[22][23:16] = buffer_data_1[2751:2744];
        layer2[22][7:0] = buffer_data_0[2735:2728];
        layer2[22][15:8] = buffer_data_0[2743:2736];
        layer2[22][23:16] = buffer_data_0[2751:2744];
        layer0[23][7:0] = buffer_data_2[2743:2736];
        layer0[23][15:8] = buffer_data_2[2751:2744];
        layer0[23][23:16] = buffer_data_2[2759:2752];
        layer1[23][7:0] = buffer_data_1[2743:2736];
        layer1[23][15:8] = buffer_data_1[2751:2744];
        layer1[23][23:16] = buffer_data_1[2759:2752];
        layer2[23][7:0] = buffer_data_0[2743:2736];
        layer2[23][15:8] = buffer_data_0[2751:2744];
        layer2[23][23:16] = buffer_data_0[2759:2752];
        layer0[24][7:0] = buffer_data_2[2751:2744];
        layer0[24][15:8] = buffer_data_2[2759:2752];
        layer0[24][23:16] = buffer_data_2[2767:2760];
        layer1[24][7:0] = buffer_data_1[2751:2744];
        layer1[24][15:8] = buffer_data_1[2759:2752];
        layer1[24][23:16] = buffer_data_1[2767:2760];
        layer2[24][7:0] = buffer_data_0[2751:2744];
        layer2[24][15:8] = buffer_data_0[2759:2752];
        layer2[24][23:16] = buffer_data_0[2767:2760];
        layer0[25][7:0] = buffer_data_2[2759:2752];
        layer0[25][15:8] = buffer_data_2[2767:2760];
        layer0[25][23:16] = buffer_data_2[2775:2768];
        layer1[25][7:0] = buffer_data_1[2759:2752];
        layer1[25][15:8] = buffer_data_1[2767:2760];
        layer1[25][23:16] = buffer_data_1[2775:2768];
        layer2[25][7:0] = buffer_data_0[2759:2752];
        layer2[25][15:8] = buffer_data_0[2767:2760];
        layer2[25][23:16] = buffer_data_0[2775:2768];
        layer0[26][7:0] = buffer_data_2[2767:2760];
        layer0[26][15:8] = buffer_data_2[2775:2768];
        layer0[26][23:16] = buffer_data_2[2783:2776];
        layer1[26][7:0] = buffer_data_1[2767:2760];
        layer1[26][15:8] = buffer_data_1[2775:2768];
        layer1[26][23:16] = buffer_data_1[2783:2776];
        layer2[26][7:0] = buffer_data_0[2767:2760];
        layer2[26][15:8] = buffer_data_0[2775:2768];
        layer2[26][23:16] = buffer_data_0[2783:2776];
        layer0[27][7:0] = buffer_data_2[2775:2768];
        layer0[27][15:8] = buffer_data_2[2783:2776];
        layer0[27][23:16] = buffer_data_2[2791:2784];
        layer1[27][7:0] = buffer_data_1[2775:2768];
        layer1[27][15:8] = buffer_data_1[2783:2776];
        layer1[27][23:16] = buffer_data_1[2791:2784];
        layer2[27][7:0] = buffer_data_0[2775:2768];
        layer2[27][15:8] = buffer_data_0[2783:2776];
        layer2[27][23:16] = buffer_data_0[2791:2784];
        layer0[28][7:0] = buffer_data_2[2783:2776];
        layer0[28][15:8] = buffer_data_2[2791:2784];
        layer0[28][23:16] = buffer_data_2[2799:2792];
        layer1[28][7:0] = buffer_data_1[2783:2776];
        layer1[28][15:8] = buffer_data_1[2791:2784];
        layer1[28][23:16] = buffer_data_1[2799:2792];
        layer2[28][7:0] = buffer_data_0[2783:2776];
        layer2[28][15:8] = buffer_data_0[2791:2784];
        layer2[28][23:16] = buffer_data_0[2799:2792];
        layer0[29][7:0] = buffer_data_2[2791:2784];
        layer0[29][15:8] = buffer_data_2[2799:2792];
        layer0[29][23:16] = buffer_data_2[2807:2800];
        layer1[29][7:0] = buffer_data_1[2791:2784];
        layer1[29][15:8] = buffer_data_1[2799:2792];
        layer1[29][23:16] = buffer_data_1[2807:2800];
        layer2[29][7:0] = buffer_data_0[2791:2784];
        layer2[29][15:8] = buffer_data_0[2799:2792];
        layer2[29][23:16] = buffer_data_0[2807:2800];
        layer0[30][7:0] = buffer_data_2[2799:2792];
        layer0[30][15:8] = buffer_data_2[2807:2800];
        layer0[30][23:16] = buffer_data_2[2815:2808];
        layer1[30][7:0] = buffer_data_1[2799:2792];
        layer1[30][15:8] = buffer_data_1[2807:2800];
        layer1[30][23:16] = buffer_data_1[2815:2808];
        layer2[30][7:0] = buffer_data_0[2799:2792];
        layer2[30][15:8] = buffer_data_0[2807:2800];
        layer2[30][23:16] = buffer_data_0[2815:2808];
        layer0[31][7:0] = buffer_data_2[2807:2800];
        layer0[31][15:8] = buffer_data_2[2815:2808];
        layer0[31][23:16] = buffer_data_2[2823:2816];
        layer1[31][7:0] = buffer_data_1[2807:2800];
        layer1[31][15:8] = buffer_data_1[2815:2808];
        layer1[31][23:16] = buffer_data_1[2823:2816];
        layer2[31][7:0] = buffer_data_0[2807:2800];
        layer2[31][15:8] = buffer_data_0[2815:2808];
        layer2[31][23:16] = buffer_data_0[2823:2816];
        layer0[32][7:0] = buffer_data_2[2815:2808];
        layer0[32][15:8] = buffer_data_2[2823:2816];
        layer0[32][23:16] = buffer_data_2[2831:2824];
        layer1[32][7:0] = buffer_data_1[2815:2808];
        layer1[32][15:8] = buffer_data_1[2823:2816];
        layer1[32][23:16] = buffer_data_1[2831:2824];
        layer2[32][7:0] = buffer_data_0[2815:2808];
        layer2[32][15:8] = buffer_data_0[2823:2816];
        layer2[32][23:16] = buffer_data_0[2831:2824];
        layer0[33][7:0] = buffer_data_2[2823:2816];
        layer0[33][15:8] = buffer_data_2[2831:2824];
        layer0[33][23:16] = buffer_data_2[2839:2832];
        layer1[33][7:0] = buffer_data_1[2823:2816];
        layer1[33][15:8] = buffer_data_1[2831:2824];
        layer1[33][23:16] = buffer_data_1[2839:2832];
        layer2[33][7:0] = buffer_data_0[2823:2816];
        layer2[33][15:8] = buffer_data_0[2831:2824];
        layer2[33][23:16] = buffer_data_0[2839:2832];
        layer0[34][7:0] = buffer_data_2[2831:2824];
        layer0[34][15:8] = buffer_data_2[2839:2832];
        layer0[34][23:16] = buffer_data_2[2847:2840];
        layer1[34][7:0] = buffer_data_1[2831:2824];
        layer1[34][15:8] = buffer_data_1[2839:2832];
        layer1[34][23:16] = buffer_data_1[2847:2840];
        layer2[34][7:0] = buffer_data_0[2831:2824];
        layer2[34][15:8] = buffer_data_0[2839:2832];
        layer2[34][23:16] = buffer_data_0[2847:2840];
        layer0[35][7:0] = buffer_data_2[2839:2832];
        layer0[35][15:8] = buffer_data_2[2847:2840];
        layer0[35][23:16] = buffer_data_2[2855:2848];
        layer1[35][7:0] = buffer_data_1[2839:2832];
        layer1[35][15:8] = buffer_data_1[2847:2840];
        layer1[35][23:16] = buffer_data_1[2855:2848];
        layer2[35][7:0] = buffer_data_0[2839:2832];
        layer2[35][15:8] = buffer_data_0[2847:2840];
        layer2[35][23:16] = buffer_data_0[2855:2848];
        layer0[36][7:0] = buffer_data_2[2847:2840];
        layer0[36][15:8] = buffer_data_2[2855:2848];
        layer0[36][23:16] = buffer_data_2[2863:2856];
        layer1[36][7:0] = buffer_data_1[2847:2840];
        layer1[36][15:8] = buffer_data_1[2855:2848];
        layer1[36][23:16] = buffer_data_1[2863:2856];
        layer2[36][7:0] = buffer_data_0[2847:2840];
        layer2[36][15:8] = buffer_data_0[2855:2848];
        layer2[36][23:16] = buffer_data_0[2863:2856];
        layer0[37][7:0] = buffer_data_2[2855:2848];
        layer0[37][15:8] = buffer_data_2[2863:2856];
        layer0[37][23:16] = buffer_data_2[2871:2864];
        layer1[37][7:0] = buffer_data_1[2855:2848];
        layer1[37][15:8] = buffer_data_1[2863:2856];
        layer1[37][23:16] = buffer_data_1[2871:2864];
        layer2[37][7:0] = buffer_data_0[2855:2848];
        layer2[37][15:8] = buffer_data_0[2863:2856];
        layer2[37][23:16] = buffer_data_0[2871:2864];
        layer0[38][7:0] = buffer_data_2[2863:2856];
        layer0[38][15:8] = buffer_data_2[2871:2864];
        layer0[38][23:16] = buffer_data_2[2879:2872];
        layer1[38][7:0] = buffer_data_1[2863:2856];
        layer1[38][15:8] = buffer_data_1[2871:2864];
        layer1[38][23:16] = buffer_data_1[2879:2872];
        layer2[38][7:0] = buffer_data_0[2863:2856];
        layer2[38][15:8] = buffer_data_0[2871:2864];
        layer2[38][23:16] = buffer_data_0[2879:2872];
        layer0[39][7:0] = buffer_data_2[2871:2864];
        layer0[39][15:8] = buffer_data_2[2879:2872];
        layer0[39][23:16] = buffer_data_2[2887:2880];
        layer1[39][7:0] = buffer_data_1[2871:2864];
        layer1[39][15:8] = buffer_data_1[2879:2872];
        layer1[39][23:16] = buffer_data_1[2887:2880];
        layer2[39][7:0] = buffer_data_0[2871:2864];
        layer2[39][15:8] = buffer_data_0[2879:2872];
        layer2[39][23:16] = buffer_data_0[2887:2880];
        layer0[40][7:0] = buffer_data_2[2879:2872];
        layer0[40][15:8] = buffer_data_2[2887:2880];
        layer0[40][23:16] = buffer_data_2[2895:2888];
        layer1[40][7:0] = buffer_data_1[2879:2872];
        layer1[40][15:8] = buffer_data_1[2887:2880];
        layer1[40][23:16] = buffer_data_1[2895:2888];
        layer2[40][7:0] = buffer_data_0[2879:2872];
        layer2[40][15:8] = buffer_data_0[2887:2880];
        layer2[40][23:16] = buffer_data_0[2895:2888];
        layer0[41][7:0] = buffer_data_2[2887:2880];
        layer0[41][15:8] = buffer_data_2[2895:2888];
        layer0[41][23:16] = buffer_data_2[2903:2896];
        layer1[41][7:0] = buffer_data_1[2887:2880];
        layer1[41][15:8] = buffer_data_1[2895:2888];
        layer1[41][23:16] = buffer_data_1[2903:2896];
        layer2[41][7:0] = buffer_data_0[2887:2880];
        layer2[41][15:8] = buffer_data_0[2895:2888];
        layer2[41][23:16] = buffer_data_0[2903:2896];
        layer0[42][7:0] = buffer_data_2[2895:2888];
        layer0[42][15:8] = buffer_data_2[2903:2896];
        layer0[42][23:16] = buffer_data_2[2911:2904];
        layer1[42][7:0] = buffer_data_1[2895:2888];
        layer1[42][15:8] = buffer_data_1[2903:2896];
        layer1[42][23:16] = buffer_data_1[2911:2904];
        layer2[42][7:0] = buffer_data_0[2895:2888];
        layer2[42][15:8] = buffer_data_0[2903:2896];
        layer2[42][23:16] = buffer_data_0[2911:2904];
        layer0[43][7:0] = buffer_data_2[2903:2896];
        layer0[43][15:8] = buffer_data_2[2911:2904];
        layer0[43][23:16] = buffer_data_2[2919:2912];
        layer1[43][7:0] = buffer_data_1[2903:2896];
        layer1[43][15:8] = buffer_data_1[2911:2904];
        layer1[43][23:16] = buffer_data_1[2919:2912];
        layer2[43][7:0] = buffer_data_0[2903:2896];
        layer2[43][15:8] = buffer_data_0[2911:2904];
        layer2[43][23:16] = buffer_data_0[2919:2912];
        layer0[44][7:0] = buffer_data_2[2911:2904];
        layer0[44][15:8] = buffer_data_2[2919:2912];
        layer0[44][23:16] = buffer_data_2[2927:2920];
        layer1[44][7:0] = buffer_data_1[2911:2904];
        layer1[44][15:8] = buffer_data_1[2919:2912];
        layer1[44][23:16] = buffer_data_1[2927:2920];
        layer2[44][7:0] = buffer_data_0[2911:2904];
        layer2[44][15:8] = buffer_data_0[2919:2912];
        layer2[44][23:16] = buffer_data_0[2927:2920];
        layer0[45][7:0] = buffer_data_2[2919:2912];
        layer0[45][15:8] = buffer_data_2[2927:2920];
        layer0[45][23:16] = buffer_data_2[2935:2928];
        layer1[45][7:0] = buffer_data_1[2919:2912];
        layer1[45][15:8] = buffer_data_1[2927:2920];
        layer1[45][23:16] = buffer_data_1[2935:2928];
        layer2[45][7:0] = buffer_data_0[2919:2912];
        layer2[45][15:8] = buffer_data_0[2927:2920];
        layer2[45][23:16] = buffer_data_0[2935:2928];
        layer0[46][7:0] = buffer_data_2[2927:2920];
        layer0[46][15:8] = buffer_data_2[2935:2928];
        layer0[46][23:16] = buffer_data_2[2943:2936];
        layer1[46][7:0] = buffer_data_1[2927:2920];
        layer1[46][15:8] = buffer_data_1[2935:2928];
        layer1[46][23:16] = buffer_data_1[2943:2936];
        layer2[46][7:0] = buffer_data_0[2927:2920];
        layer2[46][15:8] = buffer_data_0[2935:2928];
        layer2[46][23:16] = buffer_data_0[2943:2936];
        layer0[47][7:0] = buffer_data_2[2935:2928];
        layer0[47][15:8] = buffer_data_2[2943:2936];
        layer0[47][23:16] = buffer_data_2[2951:2944];
        layer1[47][7:0] = buffer_data_1[2935:2928];
        layer1[47][15:8] = buffer_data_1[2943:2936];
        layer1[47][23:16] = buffer_data_1[2951:2944];
        layer2[47][7:0] = buffer_data_0[2935:2928];
        layer2[47][15:8] = buffer_data_0[2943:2936];
        layer2[47][23:16] = buffer_data_0[2951:2944];
        layer0[48][7:0] = buffer_data_2[2943:2936];
        layer0[48][15:8] = buffer_data_2[2951:2944];
        layer0[48][23:16] = buffer_data_2[2959:2952];
        layer1[48][7:0] = buffer_data_1[2943:2936];
        layer1[48][15:8] = buffer_data_1[2951:2944];
        layer1[48][23:16] = buffer_data_1[2959:2952];
        layer2[48][7:0] = buffer_data_0[2943:2936];
        layer2[48][15:8] = buffer_data_0[2951:2944];
        layer2[48][23:16] = buffer_data_0[2959:2952];
        layer0[49][7:0] = buffer_data_2[2951:2944];
        layer0[49][15:8] = buffer_data_2[2959:2952];
        layer0[49][23:16] = buffer_data_2[2967:2960];
        layer1[49][7:0] = buffer_data_1[2951:2944];
        layer1[49][15:8] = buffer_data_1[2959:2952];
        layer1[49][23:16] = buffer_data_1[2967:2960];
        layer2[49][7:0] = buffer_data_0[2951:2944];
        layer2[49][15:8] = buffer_data_0[2959:2952];
        layer2[49][23:16] = buffer_data_0[2967:2960];
        layer0[50][7:0] = buffer_data_2[2959:2952];
        layer0[50][15:8] = buffer_data_2[2967:2960];
        layer0[50][23:16] = buffer_data_2[2975:2968];
        layer1[50][7:0] = buffer_data_1[2959:2952];
        layer1[50][15:8] = buffer_data_1[2967:2960];
        layer1[50][23:16] = buffer_data_1[2975:2968];
        layer2[50][7:0] = buffer_data_0[2959:2952];
        layer2[50][15:8] = buffer_data_0[2967:2960];
        layer2[50][23:16] = buffer_data_0[2975:2968];
        layer0[51][7:0] = buffer_data_2[2967:2960];
        layer0[51][15:8] = buffer_data_2[2975:2968];
        layer0[51][23:16] = buffer_data_2[2983:2976];
        layer1[51][7:0] = buffer_data_1[2967:2960];
        layer1[51][15:8] = buffer_data_1[2975:2968];
        layer1[51][23:16] = buffer_data_1[2983:2976];
        layer2[51][7:0] = buffer_data_0[2967:2960];
        layer2[51][15:8] = buffer_data_0[2975:2968];
        layer2[51][23:16] = buffer_data_0[2983:2976];
        layer0[52][7:0] = buffer_data_2[2975:2968];
        layer0[52][15:8] = buffer_data_2[2983:2976];
        layer0[52][23:16] = buffer_data_2[2991:2984];
        layer1[52][7:0] = buffer_data_1[2975:2968];
        layer1[52][15:8] = buffer_data_1[2983:2976];
        layer1[52][23:16] = buffer_data_1[2991:2984];
        layer2[52][7:0] = buffer_data_0[2975:2968];
        layer2[52][15:8] = buffer_data_0[2983:2976];
        layer2[52][23:16] = buffer_data_0[2991:2984];
        layer0[53][7:0] = buffer_data_2[2983:2976];
        layer0[53][15:8] = buffer_data_2[2991:2984];
        layer0[53][23:16] = buffer_data_2[2999:2992];
        layer1[53][7:0] = buffer_data_1[2983:2976];
        layer1[53][15:8] = buffer_data_1[2991:2984];
        layer1[53][23:16] = buffer_data_1[2999:2992];
        layer2[53][7:0] = buffer_data_0[2983:2976];
        layer2[53][15:8] = buffer_data_0[2991:2984];
        layer2[53][23:16] = buffer_data_0[2999:2992];
        layer0[54][7:0] = buffer_data_2[2991:2984];
        layer0[54][15:8] = buffer_data_2[2999:2992];
        layer0[54][23:16] = buffer_data_2[3007:3000];
        layer1[54][7:0] = buffer_data_1[2991:2984];
        layer1[54][15:8] = buffer_data_1[2999:2992];
        layer1[54][23:16] = buffer_data_1[3007:3000];
        layer2[54][7:0] = buffer_data_0[2991:2984];
        layer2[54][15:8] = buffer_data_0[2999:2992];
        layer2[54][23:16] = buffer_data_0[3007:3000];
        layer0[55][7:0] = buffer_data_2[2999:2992];
        layer0[55][15:8] = buffer_data_2[3007:3000];
        layer0[55][23:16] = buffer_data_2[3015:3008];
        layer1[55][7:0] = buffer_data_1[2999:2992];
        layer1[55][15:8] = buffer_data_1[3007:3000];
        layer1[55][23:16] = buffer_data_1[3015:3008];
        layer2[55][7:0] = buffer_data_0[2999:2992];
        layer2[55][15:8] = buffer_data_0[3007:3000];
        layer2[55][23:16] = buffer_data_0[3015:3008];
        layer0[56][7:0] = buffer_data_2[3007:3000];
        layer0[56][15:8] = buffer_data_2[3015:3008];
        layer0[56][23:16] = buffer_data_2[3023:3016];
        layer1[56][7:0] = buffer_data_1[3007:3000];
        layer1[56][15:8] = buffer_data_1[3015:3008];
        layer1[56][23:16] = buffer_data_1[3023:3016];
        layer2[56][7:0] = buffer_data_0[3007:3000];
        layer2[56][15:8] = buffer_data_0[3015:3008];
        layer2[56][23:16] = buffer_data_0[3023:3016];
        layer0[57][7:0] = buffer_data_2[3015:3008];
        layer0[57][15:8] = buffer_data_2[3023:3016];
        layer0[57][23:16] = buffer_data_2[3031:3024];
        layer1[57][7:0] = buffer_data_1[3015:3008];
        layer1[57][15:8] = buffer_data_1[3023:3016];
        layer1[57][23:16] = buffer_data_1[3031:3024];
        layer2[57][7:0] = buffer_data_0[3015:3008];
        layer2[57][15:8] = buffer_data_0[3023:3016];
        layer2[57][23:16] = buffer_data_0[3031:3024];
        layer0[58][7:0] = buffer_data_2[3023:3016];
        layer0[58][15:8] = buffer_data_2[3031:3024];
        layer0[58][23:16] = buffer_data_2[3039:3032];
        layer1[58][7:0] = buffer_data_1[3023:3016];
        layer1[58][15:8] = buffer_data_1[3031:3024];
        layer1[58][23:16] = buffer_data_1[3039:3032];
        layer2[58][7:0] = buffer_data_0[3023:3016];
        layer2[58][15:8] = buffer_data_0[3031:3024];
        layer2[58][23:16] = buffer_data_0[3039:3032];
        layer0[59][7:0] = buffer_data_2[3031:3024];
        layer0[59][15:8] = buffer_data_2[3039:3032];
        layer0[59][23:16] = buffer_data_2[3047:3040];
        layer1[59][7:0] = buffer_data_1[3031:3024];
        layer1[59][15:8] = buffer_data_1[3039:3032];
        layer1[59][23:16] = buffer_data_1[3047:3040];
        layer2[59][7:0] = buffer_data_0[3031:3024];
        layer2[59][15:8] = buffer_data_0[3039:3032];
        layer2[59][23:16] = buffer_data_0[3047:3040];
        layer0[60][7:0] = buffer_data_2[3039:3032];
        layer0[60][15:8] = buffer_data_2[3047:3040];
        layer0[60][23:16] = buffer_data_2[3055:3048];
        layer1[60][7:0] = buffer_data_1[3039:3032];
        layer1[60][15:8] = buffer_data_1[3047:3040];
        layer1[60][23:16] = buffer_data_1[3055:3048];
        layer2[60][7:0] = buffer_data_0[3039:3032];
        layer2[60][15:8] = buffer_data_0[3047:3040];
        layer2[60][23:16] = buffer_data_0[3055:3048];
        layer0[61][7:0] = buffer_data_2[3047:3040];
        layer0[61][15:8] = buffer_data_2[3055:3048];
        layer0[61][23:16] = buffer_data_2[3063:3056];
        layer1[61][7:0] = buffer_data_1[3047:3040];
        layer1[61][15:8] = buffer_data_1[3055:3048];
        layer1[61][23:16] = buffer_data_1[3063:3056];
        layer2[61][7:0] = buffer_data_0[3047:3040];
        layer2[61][15:8] = buffer_data_0[3055:3048];
        layer2[61][23:16] = buffer_data_0[3063:3056];
        layer0[62][7:0] = buffer_data_2[3055:3048];
        layer0[62][15:8] = buffer_data_2[3063:3056];
        layer0[62][23:16] = buffer_data_2[3071:3064];
        layer1[62][7:0] = buffer_data_1[3055:3048];
        layer1[62][15:8] = buffer_data_1[3063:3056];
        layer1[62][23:16] = buffer_data_1[3071:3064];
        layer2[62][7:0] = buffer_data_0[3055:3048];
        layer2[62][15:8] = buffer_data_0[3063:3056];
        layer2[62][23:16] = buffer_data_0[3071:3064];
        layer0[63][7:0] = buffer_data_2[3063:3056];
        layer0[63][15:8] = buffer_data_2[3071:3064];
        layer0[63][23:16] = buffer_data_2[3079:3072];
        layer1[63][7:0] = buffer_data_1[3063:3056];
        layer1[63][15:8] = buffer_data_1[3071:3064];
        layer1[63][23:16] = buffer_data_1[3079:3072];
        layer2[63][7:0] = buffer_data_0[3063:3056];
        layer2[63][15:8] = buffer_data_0[3071:3064];
        layer2[63][23:16] = buffer_data_0[3079:3072];
    end
    ST_GAUSSIAN_6: begin
        layer0[0][7:0] = buffer_data_2[3071:3064];
        layer0[0][15:8] = buffer_data_2[3079:3072];
        layer0[0][23:16] = buffer_data_2[3087:3080];
        layer1[0][7:0] = buffer_data_1[3071:3064];
        layer1[0][15:8] = buffer_data_1[3079:3072];
        layer1[0][23:16] = buffer_data_1[3087:3080];
        layer2[0][7:0] = buffer_data_0[3071:3064];
        layer2[0][15:8] = buffer_data_0[3079:3072];
        layer2[0][23:16] = buffer_data_0[3087:3080];
        layer0[1][7:0] = buffer_data_2[3079:3072];
        layer0[1][15:8] = buffer_data_2[3087:3080];
        layer0[1][23:16] = buffer_data_2[3095:3088];
        layer1[1][7:0] = buffer_data_1[3079:3072];
        layer1[1][15:8] = buffer_data_1[3087:3080];
        layer1[1][23:16] = buffer_data_1[3095:3088];
        layer2[1][7:0] = buffer_data_0[3079:3072];
        layer2[1][15:8] = buffer_data_0[3087:3080];
        layer2[1][23:16] = buffer_data_0[3095:3088];
        layer0[2][7:0] = buffer_data_2[3087:3080];
        layer0[2][15:8] = buffer_data_2[3095:3088];
        layer0[2][23:16] = buffer_data_2[3103:3096];
        layer1[2][7:0] = buffer_data_1[3087:3080];
        layer1[2][15:8] = buffer_data_1[3095:3088];
        layer1[2][23:16] = buffer_data_1[3103:3096];
        layer2[2][7:0] = buffer_data_0[3087:3080];
        layer2[2][15:8] = buffer_data_0[3095:3088];
        layer2[2][23:16] = buffer_data_0[3103:3096];
        layer0[3][7:0] = buffer_data_2[3095:3088];
        layer0[3][15:8] = buffer_data_2[3103:3096];
        layer0[3][23:16] = buffer_data_2[3111:3104];
        layer1[3][7:0] = buffer_data_1[3095:3088];
        layer1[3][15:8] = buffer_data_1[3103:3096];
        layer1[3][23:16] = buffer_data_1[3111:3104];
        layer2[3][7:0] = buffer_data_0[3095:3088];
        layer2[3][15:8] = buffer_data_0[3103:3096];
        layer2[3][23:16] = buffer_data_0[3111:3104];
        layer0[4][7:0] = buffer_data_2[3103:3096];
        layer0[4][15:8] = buffer_data_2[3111:3104];
        layer0[4][23:16] = buffer_data_2[3119:3112];
        layer1[4][7:0] = buffer_data_1[3103:3096];
        layer1[4][15:8] = buffer_data_1[3111:3104];
        layer1[4][23:16] = buffer_data_1[3119:3112];
        layer2[4][7:0] = buffer_data_0[3103:3096];
        layer2[4][15:8] = buffer_data_0[3111:3104];
        layer2[4][23:16] = buffer_data_0[3119:3112];
        layer0[5][7:0] = buffer_data_2[3111:3104];
        layer0[5][15:8] = buffer_data_2[3119:3112];
        layer0[5][23:16] = buffer_data_2[3127:3120];
        layer1[5][7:0] = buffer_data_1[3111:3104];
        layer1[5][15:8] = buffer_data_1[3119:3112];
        layer1[5][23:16] = buffer_data_1[3127:3120];
        layer2[5][7:0] = buffer_data_0[3111:3104];
        layer2[5][15:8] = buffer_data_0[3119:3112];
        layer2[5][23:16] = buffer_data_0[3127:3120];
        layer0[6][7:0] = buffer_data_2[3119:3112];
        layer0[6][15:8] = buffer_data_2[3127:3120];
        layer0[6][23:16] = buffer_data_2[3135:3128];
        layer1[6][7:0] = buffer_data_1[3119:3112];
        layer1[6][15:8] = buffer_data_1[3127:3120];
        layer1[6][23:16] = buffer_data_1[3135:3128];
        layer2[6][7:0] = buffer_data_0[3119:3112];
        layer2[6][15:8] = buffer_data_0[3127:3120];
        layer2[6][23:16] = buffer_data_0[3135:3128];
        layer0[7][7:0] = buffer_data_2[3127:3120];
        layer0[7][15:8] = buffer_data_2[3135:3128];
        layer0[7][23:16] = buffer_data_2[3143:3136];
        layer1[7][7:0] = buffer_data_1[3127:3120];
        layer1[7][15:8] = buffer_data_1[3135:3128];
        layer1[7][23:16] = buffer_data_1[3143:3136];
        layer2[7][7:0] = buffer_data_0[3127:3120];
        layer2[7][15:8] = buffer_data_0[3135:3128];
        layer2[7][23:16] = buffer_data_0[3143:3136];
        layer0[8][7:0] = buffer_data_2[3135:3128];
        layer0[8][15:8] = buffer_data_2[3143:3136];
        layer0[8][23:16] = buffer_data_2[3151:3144];
        layer1[8][7:0] = buffer_data_1[3135:3128];
        layer1[8][15:8] = buffer_data_1[3143:3136];
        layer1[8][23:16] = buffer_data_1[3151:3144];
        layer2[8][7:0] = buffer_data_0[3135:3128];
        layer2[8][15:8] = buffer_data_0[3143:3136];
        layer2[8][23:16] = buffer_data_0[3151:3144];
        layer0[9][7:0] = buffer_data_2[3143:3136];
        layer0[9][15:8] = buffer_data_2[3151:3144];
        layer0[9][23:16] = buffer_data_2[3159:3152];
        layer1[9][7:0] = buffer_data_1[3143:3136];
        layer1[9][15:8] = buffer_data_1[3151:3144];
        layer1[9][23:16] = buffer_data_1[3159:3152];
        layer2[9][7:0] = buffer_data_0[3143:3136];
        layer2[9][15:8] = buffer_data_0[3151:3144];
        layer2[9][23:16] = buffer_data_0[3159:3152];
        layer0[10][7:0] = buffer_data_2[3151:3144];
        layer0[10][15:8] = buffer_data_2[3159:3152];
        layer0[10][23:16] = buffer_data_2[3167:3160];
        layer1[10][7:0] = buffer_data_1[3151:3144];
        layer1[10][15:8] = buffer_data_1[3159:3152];
        layer1[10][23:16] = buffer_data_1[3167:3160];
        layer2[10][7:0] = buffer_data_0[3151:3144];
        layer2[10][15:8] = buffer_data_0[3159:3152];
        layer2[10][23:16] = buffer_data_0[3167:3160];
        layer0[11][7:0] = buffer_data_2[3159:3152];
        layer0[11][15:8] = buffer_data_2[3167:3160];
        layer0[11][23:16] = buffer_data_2[3175:3168];
        layer1[11][7:0] = buffer_data_1[3159:3152];
        layer1[11][15:8] = buffer_data_1[3167:3160];
        layer1[11][23:16] = buffer_data_1[3175:3168];
        layer2[11][7:0] = buffer_data_0[3159:3152];
        layer2[11][15:8] = buffer_data_0[3167:3160];
        layer2[11][23:16] = buffer_data_0[3175:3168];
        layer0[12][7:0] = buffer_data_2[3167:3160];
        layer0[12][15:8] = buffer_data_2[3175:3168];
        layer0[12][23:16] = buffer_data_2[3183:3176];
        layer1[12][7:0] = buffer_data_1[3167:3160];
        layer1[12][15:8] = buffer_data_1[3175:3168];
        layer1[12][23:16] = buffer_data_1[3183:3176];
        layer2[12][7:0] = buffer_data_0[3167:3160];
        layer2[12][15:8] = buffer_data_0[3175:3168];
        layer2[12][23:16] = buffer_data_0[3183:3176];
        layer0[13][7:0] = buffer_data_2[3175:3168];
        layer0[13][15:8] = buffer_data_2[3183:3176];
        layer0[13][23:16] = buffer_data_2[3191:3184];
        layer1[13][7:0] = buffer_data_1[3175:3168];
        layer1[13][15:8] = buffer_data_1[3183:3176];
        layer1[13][23:16] = buffer_data_1[3191:3184];
        layer2[13][7:0] = buffer_data_0[3175:3168];
        layer2[13][15:8] = buffer_data_0[3183:3176];
        layer2[13][23:16] = buffer_data_0[3191:3184];
        layer0[14][7:0] = buffer_data_2[3183:3176];
        layer0[14][15:8] = buffer_data_2[3191:3184];
        layer0[14][23:16] = buffer_data_2[3199:3192];
        layer1[14][7:0] = buffer_data_1[3183:3176];
        layer1[14][15:8] = buffer_data_1[3191:3184];
        layer1[14][23:16] = buffer_data_1[3199:3192];
        layer2[14][7:0] = buffer_data_0[3183:3176];
        layer2[14][15:8] = buffer_data_0[3191:3184];
        layer2[14][23:16] = buffer_data_0[3199:3192];
        layer0[15][7:0] = buffer_data_2[3191:3184];
        layer0[15][15:8] = buffer_data_2[3199:3192];
        layer0[15][23:16] = buffer_data_2[3207:3200];
        layer1[15][7:0] = buffer_data_1[3191:3184];
        layer1[15][15:8] = buffer_data_1[3199:3192];
        layer1[15][23:16] = buffer_data_1[3207:3200];
        layer2[15][7:0] = buffer_data_0[3191:3184];
        layer2[15][15:8] = buffer_data_0[3199:3192];
        layer2[15][23:16] = buffer_data_0[3207:3200];
        layer0[16][7:0] = buffer_data_2[3199:3192];
        layer0[16][15:8] = buffer_data_2[3207:3200];
        layer0[16][23:16] = buffer_data_2[3215:3208];
        layer1[16][7:0] = buffer_data_1[3199:3192];
        layer1[16][15:8] = buffer_data_1[3207:3200];
        layer1[16][23:16] = buffer_data_1[3215:3208];
        layer2[16][7:0] = buffer_data_0[3199:3192];
        layer2[16][15:8] = buffer_data_0[3207:3200];
        layer2[16][23:16] = buffer_data_0[3215:3208];
        layer0[17][7:0] = buffer_data_2[3207:3200];
        layer0[17][15:8] = buffer_data_2[3215:3208];
        layer0[17][23:16] = buffer_data_2[3223:3216];
        layer1[17][7:0] = buffer_data_1[3207:3200];
        layer1[17][15:8] = buffer_data_1[3215:3208];
        layer1[17][23:16] = buffer_data_1[3223:3216];
        layer2[17][7:0] = buffer_data_0[3207:3200];
        layer2[17][15:8] = buffer_data_0[3215:3208];
        layer2[17][23:16] = buffer_data_0[3223:3216];
        layer0[18][7:0] = buffer_data_2[3215:3208];
        layer0[18][15:8] = buffer_data_2[3223:3216];
        layer0[18][23:16] = buffer_data_2[3231:3224];
        layer1[18][7:0] = buffer_data_1[3215:3208];
        layer1[18][15:8] = buffer_data_1[3223:3216];
        layer1[18][23:16] = buffer_data_1[3231:3224];
        layer2[18][7:0] = buffer_data_0[3215:3208];
        layer2[18][15:8] = buffer_data_0[3223:3216];
        layer2[18][23:16] = buffer_data_0[3231:3224];
        layer0[19][7:0] = buffer_data_2[3223:3216];
        layer0[19][15:8] = buffer_data_2[3231:3224];
        layer0[19][23:16] = buffer_data_2[3239:3232];
        layer1[19][7:0] = buffer_data_1[3223:3216];
        layer1[19][15:8] = buffer_data_1[3231:3224];
        layer1[19][23:16] = buffer_data_1[3239:3232];
        layer2[19][7:0] = buffer_data_0[3223:3216];
        layer2[19][15:8] = buffer_data_0[3231:3224];
        layer2[19][23:16] = buffer_data_0[3239:3232];
        layer0[20][7:0] = buffer_data_2[3231:3224];
        layer0[20][15:8] = buffer_data_2[3239:3232];
        layer0[20][23:16] = buffer_data_2[3247:3240];
        layer1[20][7:0] = buffer_data_1[3231:3224];
        layer1[20][15:8] = buffer_data_1[3239:3232];
        layer1[20][23:16] = buffer_data_1[3247:3240];
        layer2[20][7:0] = buffer_data_0[3231:3224];
        layer2[20][15:8] = buffer_data_0[3239:3232];
        layer2[20][23:16] = buffer_data_0[3247:3240];
        layer0[21][7:0] = buffer_data_2[3239:3232];
        layer0[21][15:8] = buffer_data_2[3247:3240];
        layer0[21][23:16] = buffer_data_2[3255:3248];
        layer1[21][7:0] = buffer_data_1[3239:3232];
        layer1[21][15:8] = buffer_data_1[3247:3240];
        layer1[21][23:16] = buffer_data_1[3255:3248];
        layer2[21][7:0] = buffer_data_0[3239:3232];
        layer2[21][15:8] = buffer_data_0[3247:3240];
        layer2[21][23:16] = buffer_data_0[3255:3248];
        layer0[22][7:0] = buffer_data_2[3247:3240];
        layer0[22][15:8] = buffer_data_2[3255:3248];
        layer0[22][23:16] = buffer_data_2[3263:3256];
        layer1[22][7:0] = buffer_data_1[3247:3240];
        layer1[22][15:8] = buffer_data_1[3255:3248];
        layer1[22][23:16] = buffer_data_1[3263:3256];
        layer2[22][7:0] = buffer_data_0[3247:3240];
        layer2[22][15:8] = buffer_data_0[3255:3248];
        layer2[22][23:16] = buffer_data_0[3263:3256];
        layer0[23][7:0] = buffer_data_2[3255:3248];
        layer0[23][15:8] = buffer_data_2[3263:3256];
        layer0[23][23:16] = buffer_data_2[3271:3264];
        layer1[23][7:0] = buffer_data_1[3255:3248];
        layer1[23][15:8] = buffer_data_1[3263:3256];
        layer1[23][23:16] = buffer_data_1[3271:3264];
        layer2[23][7:0] = buffer_data_0[3255:3248];
        layer2[23][15:8] = buffer_data_0[3263:3256];
        layer2[23][23:16] = buffer_data_0[3271:3264];
        layer0[24][7:0] = buffer_data_2[3263:3256];
        layer0[24][15:8] = buffer_data_2[3271:3264];
        layer0[24][23:16] = buffer_data_2[3279:3272];
        layer1[24][7:0] = buffer_data_1[3263:3256];
        layer1[24][15:8] = buffer_data_1[3271:3264];
        layer1[24][23:16] = buffer_data_1[3279:3272];
        layer2[24][7:0] = buffer_data_0[3263:3256];
        layer2[24][15:8] = buffer_data_0[3271:3264];
        layer2[24][23:16] = buffer_data_0[3279:3272];
        layer0[25][7:0] = buffer_data_2[3271:3264];
        layer0[25][15:8] = buffer_data_2[3279:3272];
        layer0[25][23:16] = buffer_data_2[3287:3280];
        layer1[25][7:0] = buffer_data_1[3271:3264];
        layer1[25][15:8] = buffer_data_1[3279:3272];
        layer1[25][23:16] = buffer_data_1[3287:3280];
        layer2[25][7:0] = buffer_data_0[3271:3264];
        layer2[25][15:8] = buffer_data_0[3279:3272];
        layer2[25][23:16] = buffer_data_0[3287:3280];
        layer0[26][7:0] = buffer_data_2[3279:3272];
        layer0[26][15:8] = buffer_data_2[3287:3280];
        layer0[26][23:16] = buffer_data_2[3295:3288];
        layer1[26][7:0] = buffer_data_1[3279:3272];
        layer1[26][15:8] = buffer_data_1[3287:3280];
        layer1[26][23:16] = buffer_data_1[3295:3288];
        layer2[26][7:0] = buffer_data_0[3279:3272];
        layer2[26][15:8] = buffer_data_0[3287:3280];
        layer2[26][23:16] = buffer_data_0[3295:3288];
        layer0[27][7:0] = buffer_data_2[3287:3280];
        layer0[27][15:8] = buffer_data_2[3295:3288];
        layer0[27][23:16] = buffer_data_2[3303:3296];
        layer1[27][7:0] = buffer_data_1[3287:3280];
        layer1[27][15:8] = buffer_data_1[3295:3288];
        layer1[27][23:16] = buffer_data_1[3303:3296];
        layer2[27][7:0] = buffer_data_0[3287:3280];
        layer2[27][15:8] = buffer_data_0[3295:3288];
        layer2[27][23:16] = buffer_data_0[3303:3296];
        layer0[28][7:0] = buffer_data_2[3295:3288];
        layer0[28][15:8] = buffer_data_2[3303:3296];
        layer0[28][23:16] = buffer_data_2[3311:3304];
        layer1[28][7:0] = buffer_data_1[3295:3288];
        layer1[28][15:8] = buffer_data_1[3303:3296];
        layer1[28][23:16] = buffer_data_1[3311:3304];
        layer2[28][7:0] = buffer_data_0[3295:3288];
        layer2[28][15:8] = buffer_data_0[3303:3296];
        layer2[28][23:16] = buffer_data_0[3311:3304];
        layer0[29][7:0] = buffer_data_2[3303:3296];
        layer0[29][15:8] = buffer_data_2[3311:3304];
        layer0[29][23:16] = buffer_data_2[3319:3312];
        layer1[29][7:0] = buffer_data_1[3303:3296];
        layer1[29][15:8] = buffer_data_1[3311:3304];
        layer1[29][23:16] = buffer_data_1[3319:3312];
        layer2[29][7:0] = buffer_data_0[3303:3296];
        layer2[29][15:8] = buffer_data_0[3311:3304];
        layer2[29][23:16] = buffer_data_0[3319:3312];
        layer0[30][7:0] = buffer_data_2[3311:3304];
        layer0[30][15:8] = buffer_data_2[3319:3312];
        layer0[30][23:16] = buffer_data_2[3327:3320];
        layer1[30][7:0] = buffer_data_1[3311:3304];
        layer1[30][15:8] = buffer_data_1[3319:3312];
        layer1[30][23:16] = buffer_data_1[3327:3320];
        layer2[30][7:0] = buffer_data_0[3311:3304];
        layer2[30][15:8] = buffer_data_0[3319:3312];
        layer2[30][23:16] = buffer_data_0[3327:3320];
        layer0[31][7:0] = buffer_data_2[3319:3312];
        layer0[31][15:8] = buffer_data_2[3327:3320];
        layer0[31][23:16] = buffer_data_2[3335:3328];
        layer1[31][7:0] = buffer_data_1[3319:3312];
        layer1[31][15:8] = buffer_data_1[3327:3320];
        layer1[31][23:16] = buffer_data_1[3335:3328];
        layer2[31][7:0] = buffer_data_0[3319:3312];
        layer2[31][15:8] = buffer_data_0[3327:3320];
        layer2[31][23:16] = buffer_data_0[3335:3328];
        layer0[32][7:0] = buffer_data_2[3327:3320];
        layer0[32][15:8] = buffer_data_2[3335:3328];
        layer0[32][23:16] = buffer_data_2[3343:3336];
        layer1[32][7:0] = buffer_data_1[3327:3320];
        layer1[32][15:8] = buffer_data_1[3335:3328];
        layer1[32][23:16] = buffer_data_1[3343:3336];
        layer2[32][7:0] = buffer_data_0[3327:3320];
        layer2[32][15:8] = buffer_data_0[3335:3328];
        layer2[32][23:16] = buffer_data_0[3343:3336];
        layer0[33][7:0] = buffer_data_2[3335:3328];
        layer0[33][15:8] = buffer_data_2[3343:3336];
        layer0[33][23:16] = buffer_data_2[3351:3344];
        layer1[33][7:0] = buffer_data_1[3335:3328];
        layer1[33][15:8] = buffer_data_1[3343:3336];
        layer1[33][23:16] = buffer_data_1[3351:3344];
        layer2[33][7:0] = buffer_data_0[3335:3328];
        layer2[33][15:8] = buffer_data_0[3343:3336];
        layer2[33][23:16] = buffer_data_0[3351:3344];
        layer0[34][7:0] = buffer_data_2[3343:3336];
        layer0[34][15:8] = buffer_data_2[3351:3344];
        layer0[34][23:16] = buffer_data_2[3359:3352];
        layer1[34][7:0] = buffer_data_1[3343:3336];
        layer1[34][15:8] = buffer_data_1[3351:3344];
        layer1[34][23:16] = buffer_data_1[3359:3352];
        layer2[34][7:0] = buffer_data_0[3343:3336];
        layer2[34][15:8] = buffer_data_0[3351:3344];
        layer2[34][23:16] = buffer_data_0[3359:3352];
        layer0[35][7:0] = buffer_data_2[3351:3344];
        layer0[35][15:8] = buffer_data_2[3359:3352];
        layer0[35][23:16] = buffer_data_2[3367:3360];
        layer1[35][7:0] = buffer_data_1[3351:3344];
        layer1[35][15:8] = buffer_data_1[3359:3352];
        layer1[35][23:16] = buffer_data_1[3367:3360];
        layer2[35][7:0] = buffer_data_0[3351:3344];
        layer2[35][15:8] = buffer_data_0[3359:3352];
        layer2[35][23:16] = buffer_data_0[3367:3360];
        layer0[36][7:0] = buffer_data_2[3359:3352];
        layer0[36][15:8] = buffer_data_2[3367:3360];
        layer0[36][23:16] = buffer_data_2[3375:3368];
        layer1[36][7:0] = buffer_data_1[3359:3352];
        layer1[36][15:8] = buffer_data_1[3367:3360];
        layer1[36][23:16] = buffer_data_1[3375:3368];
        layer2[36][7:0] = buffer_data_0[3359:3352];
        layer2[36][15:8] = buffer_data_0[3367:3360];
        layer2[36][23:16] = buffer_data_0[3375:3368];
        layer0[37][7:0] = buffer_data_2[3367:3360];
        layer0[37][15:8] = buffer_data_2[3375:3368];
        layer0[37][23:16] = buffer_data_2[3383:3376];
        layer1[37][7:0] = buffer_data_1[3367:3360];
        layer1[37][15:8] = buffer_data_1[3375:3368];
        layer1[37][23:16] = buffer_data_1[3383:3376];
        layer2[37][7:0] = buffer_data_0[3367:3360];
        layer2[37][15:8] = buffer_data_0[3375:3368];
        layer2[37][23:16] = buffer_data_0[3383:3376];
        layer0[38][7:0] = buffer_data_2[3375:3368];
        layer0[38][15:8] = buffer_data_2[3383:3376];
        layer0[38][23:16] = buffer_data_2[3391:3384];
        layer1[38][7:0] = buffer_data_1[3375:3368];
        layer1[38][15:8] = buffer_data_1[3383:3376];
        layer1[38][23:16] = buffer_data_1[3391:3384];
        layer2[38][7:0] = buffer_data_0[3375:3368];
        layer2[38][15:8] = buffer_data_0[3383:3376];
        layer2[38][23:16] = buffer_data_0[3391:3384];
        layer0[39][7:0] = buffer_data_2[3383:3376];
        layer0[39][15:8] = buffer_data_2[3391:3384];
        layer0[39][23:16] = buffer_data_2[3399:3392];
        layer1[39][7:0] = buffer_data_1[3383:3376];
        layer1[39][15:8] = buffer_data_1[3391:3384];
        layer1[39][23:16] = buffer_data_1[3399:3392];
        layer2[39][7:0] = buffer_data_0[3383:3376];
        layer2[39][15:8] = buffer_data_0[3391:3384];
        layer2[39][23:16] = buffer_data_0[3399:3392];
        layer0[40][7:0] = buffer_data_2[3391:3384];
        layer0[40][15:8] = buffer_data_2[3399:3392];
        layer0[40][23:16] = buffer_data_2[3407:3400];
        layer1[40][7:0] = buffer_data_1[3391:3384];
        layer1[40][15:8] = buffer_data_1[3399:3392];
        layer1[40][23:16] = buffer_data_1[3407:3400];
        layer2[40][7:0] = buffer_data_0[3391:3384];
        layer2[40][15:8] = buffer_data_0[3399:3392];
        layer2[40][23:16] = buffer_data_0[3407:3400];
        layer0[41][7:0] = buffer_data_2[3399:3392];
        layer0[41][15:8] = buffer_data_2[3407:3400];
        layer0[41][23:16] = buffer_data_2[3415:3408];
        layer1[41][7:0] = buffer_data_1[3399:3392];
        layer1[41][15:8] = buffer_data_1[3407:3400];
        layer1[41][23:16] = buffer_data_1[3415:3408];
        layer2[41][7:0] = buffer_data_0[3399:3392];
        layer2[41][15:8] = buffer_data_0[3407:3400];
        layer2[41][23:16] = buffer_data_0[3415:3408];
        layer0[42][7:0] = buffer_data_2[3407:3400];
        layer0[42][15:8] = buffer_data_2[3415:3408];
        layer0[42][23:16] = buffer_data_2[3423:3416];
        layer1[42][7:0] = buffer_data_1[3407:3400];
        layer1[42][15:8] = buffer_data_1[3415:3408];
        layer1[42][23:16] = buffer_data_1[3423:3416];
        layer2[42][7:0] = buffer_data_0[3407:3400];
        layer2[42][15:8] = buffer_data_0[3415:3408];
        layer2[42][23:16] = buffer_data_0[3423:3416];
        layer0[43][7:0] = buffer_data_2[3415:3408];
        layer0[43][15:8] = buffer_data_2[3423:3416];
        layer0[43][23:16] = buffer_data_2[3431:3424];
        layer1[43][7:0] = buffer_data_1[3415:3408];
        layer1[43][15:8] = buffer_data_1[3423:3416];
        layer1[43][23:16] = buffer_data_1[3431:3424];
        layer2[43][7:0] = buffer_data_0[3415:3408];
        layer2[43][15:8] = buffer_data_0[3423:3416];
        layer2[43][23:16] = buffer_data_0[3431:3424];
        layer0[44][7:0] = buffer_data_2[3423:3416];
        layer0[44][15:8] = buffer_data_2[3431:3424];
        layer0[44][23:16] = buffer_data_2[3439:3432];
        layer1[44][7:0] = buffer_data_1[3423:3416];
        layer1[44][15:8] = buffer_data_1[3431:3424];
        layer1[44][23:16] = buffer_data_1[3439:3432];
        layer2[44][7:0] = buffer_data_0[3423:3416];
        layer2[44][15:8] = buffer_data_0[3431:3424];
        layer2[44][23:16] = buffer_data_0[3439:3432];
        layer0[45][7:0] = buffer_data_2[3431:3424];
        layer0[45][15:8] = buffer_data_2[3439:3432];
        layer0[45][23:16] = buffer_data_2[3447:3440];
        layer1[45][7:0] = buffer_data_1[3431:3424];
        layer1[45][15:8] = buffer_data_1[3439:3432];
        layer1[45][23:16] = buffer_data_1[3447:3440];
        layer2[45][7:0] = buffer_data_0[3431:3424];
        layer2[45][15:8] = buffer_data_0[3439:3432];
        layer2[45][23:16] = buffer_data_0[3447:3440];
        layer0[46][7:0] = buffer_data_2[3439:3432];
        layer0[46][15:8] = buffer_data_2[3447:3440];
        layer0[46][23:16] = buffer_data_2[3455:3448];
        layer1[46][7:0] = buffer_data_1[3439:3432];
        layer1[46][15:8] = buffer_data_1[3447:3440];
        layer1[46][23:16] = buffer_data_1[3455:3448];
        layer2[46][7:0] = buffer_data_0[3439:3432];
        layer2[46][15:8] = buffer_data_0[3447:3440];
        layer2[46][23:16] = buffer_data_0[3455:3448];
        layer0[47][7:0] = buffer_data_2[3447:3440];
        layer0[47][15:8] = buffer_data_2[3455:3448];
        layer0[47][23:16] = buffer_data_2[3463:3456];
        layer1[47][7:0] = buffer_data_1[3447:3440];
        layer1[47][15:8] = buffer_data_1[3455:3448];
        layer1[47][23:16] = buffer_data_1[3463:3456];
        layer2[47][7:0] = buffer_data_0[3447:3440];
        layer2[47][15:8] = buffer_data_0[3455:3448];
        layer2[47][23:16] = buffer_data_0[3463:3456];
        layer0[48][7:0] = buffer_data_2[3455:3448];
        layer0[48][15:8] = buffer_data_2[3463:3456];
        layer0[48][23:16] = buffer_data_2[3471:3464];
        layer1[48][7:0] = buffer_data_1[3455:3448];
        layer1[48][15:8] = buffer_data_1[3463:3456];
        layer1[48][23:16] = buffer_data_1[3471:3464];
        layer2[48][7:0] = buffer_data_0[3455:3448];
        layer2[48][15:8] = buffer_data_0[3463:3456];
        layer2[48][23:16] = buffer_data_0[3471:3464];
        layer0[49][7:0] = buffer_data_2[3463:3456];
        layer0[49][15:8] = buffer_data_2[3471:3464];
        layer0[49][23:16] = buffer_data_2[3479:3472];
        layer1[49][7:0] = buffer_data_1[3463:3456];
        layer1[49][15:8] = buffer_data_1[3471:3464];
        layer1[49][23:16] = buffer_data_1[3479:3472];
        layer2[49][7:0] = buffer_data_0[3463:3456];
        layer2[49][15:8] = buffer_data_0[3471:3464];
        layer2[49][23:16] = buffer_data_0[3479:3472];
        layer0[50][7:0] = buffer_data_2[3471:3464];
        layer0[50][15:8] = buffer_data_2[3479:3472];
        layer0[50][23:16] = buffer_data_2[3487:3480];
        layer1[50][7:0] = buffer_data_1[3471:3464];
        layer1[50][15:8] = buffer_data_1[3479:3472];
        layer1[50][23:16] = buffer_data_1[3487:3480];
        layer2[50][7:0] = buffer_data_0[3471:3464];
        layer2[50][15:8] = buffer_data_0[3479:3472];
        layer2[50][23:16] = buffer_data_0[3487:3480];
        layer0[51][7:0] = buffer_data_2[3479:3472];
        layer0[51][15:8] = buffer_data_2[3487:3480];
        layer0[51][23:16] = buffer_data_2[3495:3488];
        layer1[51][7:0] = buffer_data_1[3479:3472];
        layer1[51][15:8] = buffer_data_1[3487:3480];
        layer1[51][23:16] = buffer_data_1[3495:3488];
        layer2[51][7:0] = buffer_data_0[3479:3472];
        layer2[51][15:8] = buffer_data_0[3487:3480];
        layer2[51][23:16] = buffer_data_0[3495:3488];
        layer0[52][7:0] = buffer_data_2[3487:3480];
        layer0[52][15:8] = buffer_data_2[3495:3488];
        layer0[52][23:16] = buffer_data_2[3503:3496];
        layer1[52][7:0] = buffer_data_1[3487:3480];
        layer1[52][15:8] = buffer_data_1[3495:3488];
        layer1[52][23:16] = buffer_data_1[3503:3496];
        layer2[52][7:0] = buffer_data_0[3487:3480];
        layer2[52][15:8] = buffer_data_0[3495:3488];
        layer2[52][23:16] = buffer_data_0[3503:3496];
        layer0[53][7:0] = buffer_data_2[3495:3488];
        layer0[53][15:8] = buffer_data_2[3503:3496];
        layer0[53][23:16] = buffer_data_2[3511:3504];
        layer1[53][7:0] = buffer_data_1[3495:3488];
        layer1[53][15:8] = buffer_data_1[3503:3496];
        layer1[53][23:16] = buffer_data_1[3511:3504];
        layer2[53][7:0] = buffer_data_0[3495:3488];
        layer2[53][15:8] = buffer_data_0[3503:3496];
        layer2[53][23:16] = buffer_data_0[3511:3504];
        layer0[54][7:0] = buffer_data_2[3503:3496];
        layer0[54][15:8] = buffer_data_2[3511:3504];
        layer0[54][23:16] = buffer_data_2[3519:3512];
        layer1[54][7:0] = buffer_data_1[3503:3496];
        layer1[54][15:8] = buffer_data_1[3511:3504];
        layer1[54][23:16] = buffer_data_1[3519:3512];
        layer2[54][7:0] = buffer_data_0[3503:3496];
        layer2[54][15:8] = buffer_data_0[3511:3504];
        layer2[54][23:16] = buffer_data_0[3519:3512];
        layer0[55][7:0] = buffer_data_2[3511:3504];
        layer0[55][15:8] = buffer_data_2[3519:3512];
        layer0[55][23:16] = buffer_data_2[3527:3520];
        layer1[55][7:0] = buffer_data_1[3511:3504];
        layer1[55][15:8] = buffer_data_1[3519:3512];
        layer1[55][23:16] = buffer_data_1[3527:3520];
        layer2[55][7:0] = buffer_data_0[3511:3504];
        layer2[55][15:8] = buffer_data_0[3519:3512];
        layer2[55][23:16] = buffer_data_0[3527:3520];
        layer0[56][7:0] = buffer_data_2[3519:3512];
        layer0[56][15:8] = buffer_data_2[3527:3520];
        layer0[56][23:16] = buffer_data_2[3535:3528];
        layer1[56][7:0] = buffer_data_1[3519:3512];
        layer1[56][15:8] = buffer_data_1[3527:3520];
        layer1[56][23:16] = buffer_data_1[3535:3528];
        layer2[56][7:0] = buffer_data_0[3519:3512];
        layer2[56][15:8] = buffer_data_0[3527:3520];
        layer2[56][23:16] = buffer_data_0[3535:3528];
        layer0[57][7:0] = buffer_data_2[3527:3520];
        layer0[57][15:8] = buffer_data_2[3535:3528];
        layer0[57][23:16] = buffer_data_2[3543:3536];
        layer1[57][7:0] = buffer_data_1[3527:3520];
        layer1[57][15:8] = buffer_data_1[3535:3528];
        layer1[57][23:16] = buffer_data_1[3543:3536];
        layer2[57][7:0] = buffer_data_0[3527:3520];
        layer2[57][15:8] = buffer_data_0[3535:3528];
        layer2[57][23:16] = buffer_data_0[3543:3536];
        layer0[58][7:0] = buffer_data_2[3535:3528];
        layer0[58][15:8] = buffer_data_2[3543:3536];
        layer0[58][23:16] = buffer_data_2[3551:3544];
        layer1[58][7:0] = buffer_data_1[3535:3528];
        layer1[58][15:8] = buffer_data_1[3543:3536];
        layer1[58][23:16] = buffer_data_1[3551:3544];
        layer2[58][7:0] = buffer_data_0[3535:3528];
        layer2[58][15:8] = buffer_data_0[3543:3536];
        layer2[58][23:16] = buffer_data_0[3551:3544];
        layer0[59][7:0] = buffer_data_2[3543:3536];
        layer0[59][15:8] = buffer_data_2[3551:3544];
        layer0[59][23:16] = buffer_data_2[3559:3552];
        layer1[59][7:0] = buffer_data_1[3543:3536];
        layer1[59][15:8] = buffer_data_1[3551:3544];
        layer1[59][23:16] = buffer_data_1[3559:3552];
        layer2[59][7:0] = buffer_data_0[3543:3536];
        layer2[59][15:8] = buffer_data_0[3551:3544];
        layer2[59][23:16] = buffer_data_0[3559:3552];
        layer0[60][7:0] = buffer_data_2[3551:3544];
        layer0[60][15:8] = buffer_data_2[3559:3552];
        layer0[60][23:16] = buffer_data_2[3567:3560];
        layer1[60][7:0] = buffer_data_1[3551:3544];
        layer1[60][15:8] = buffer_data_1[3559:3552];
        layer1[60][23:16] = buffer_data_1[3567:3560];
        layer2[60][7:0] = buffer_data_0[3551:3544];
        layer2[60][15:8] = buffer_data_0[3559:3552];
        layer2[60][23:16] = buffer_data_0[3567:3560];
        layer0[61][7:0] = buffer_data_2[3559:3552];
        layer0[61][15:8] = buffer_data_2[3567:3560];
        layer0[61][23:16] = buffer_data_2[3575:3568];
        layer1[61][7:0] = buffer_data_1[3559:3552];
        layer1[61][15:8] = buffer_data_1[3567:3560];
        layer1[61][23:16] = buffer_data_1[3575:3568];
        layer2[61][7:0] = buffer_data_0[3559:3552];
        layer2[61][15:8] = buffer_data_0[3567:3560];
        layer2[61][23:16] = buffer_data_0[3575:3568];
        layer0[62][7:0] = buffer_data_2[3567:3560];
        layer0[62][15:8] = buffer_data_2[3575:3568];
        layer0[62][23:16] = buffer_data_2[3583:3576];
        layer1[62][7:0] = buffer_data_1[3567:3560];
        layer1[62][15:8] = buffer_data_1[3575:3568];
        layer1[62][23:16] = buffer_data_1[3583:3576];
        layer2[62][7:0] = buffer_data_0[3567:3560];
        layer2[62][15:8] = buffer_data_0[3575:3568];
        layer2[62][23:16] = buffer_data_0[3583:3576];
        layer0[63][7:0] = buffer_data_2[3575:3568];
        layer0[63][15:8] = buffer_data_2[3583:3576];
        layer0[63][23:16] = buffer_data_2[3591:3584];
        layer1[63][7:0] = buffer_data_1[3575:3568];
        layer1[63][15:8] = buffer_data_1[3583:3576];
        layer1[63][23:16] = buffer_data_1[3591:3584];
        layer2[63][7:0] = buffer_data_0[3575:3568];
        layer2[63][15:8] = buffer_data_0[3583:3576];
        layer2[63][23:16] = buffer_data_0[3591:3584];
    end
    ST_GAUSSIAN_7: begin
        layer0[0][7:0] = buffer_data_2[3583:3576];
        layer0[0][15:8] = buffer_data_2[3591:3584];
        layer0[0][23:16] = buffer_data_2[3599:3592];
        layer1[0][7:0] = buffer_data_1[3583:3576];
        layer1[0][15:8] = buffer_data_1[3591:3584];
        layer1[0][23:16] = buffer_data_1[3599:3592];
        layer2[0][7:0] = buffer_data_0[3583:3576];
        layer2[0][15:8] = buffer_data_0[3591:3584];
        layer2[0][23:16] = buffer_data_0[3599:3592];
        layer0[1][7:0] = buffer_data_2[3591:3584];
        layer0[1][15:8] = buffer_data_2[3599:3592];
        layer0[1][23:16] = buffer_data_2[3607:3600];
        layer1[1][7:0] = buffer_data_1[3591:3584];
        layer1[1][15:8] = buffer_data_1[3599:3592];
        layer1[1][23:16] = buffer_data_1[3607:3600];
        layer2[1][7:0] = buffer_data_0[3591:3584];
        layer2[1][15:8] = buffer_data_0[3599:3592];
        layer2[1][23:16] = buffer_data_0[3607:3600];
        layer0[2][7:0] = buffer_data_2[3599:3592];
        layer0[2][15:8] = buffer_data_2[3607:3600];
        layer0[2][23:16] = buffer_data_2[3615:3608];
        layer1[2][7:0] = buffer_data_1[3599:3592];
        layer1[2][15:8] = buffer_data_1[3607:3600];
        layer1[2][23:16] = buffer_data_1[3615:3608];
        layer2[2][7:0] = buffer_data_0[3599:3592];
        layer2[2][15:8] = buffer_data_0[3607:3600];
        layer2[2][23:16] = buffer_data_0[3615:3608];
        layer0[3][7:0] = buffer_data_2[3607:3600];
        layer0[3][15:8] = buffer_data_2[3615:3608];
        layer0[3][23:16] = buffer_data_2[3623:3616];
        layer1[3][7:0] = buffer_data_1[3607:3600];
        layer1[3][15:8] = buffer_data_1[3615:3608];
        layer1[3][23:16] = buffer_data_1[3623:3616];
        layer2[3][7:0] = buffer_data_0[3607:3600];
        layer2[3][15:8] = buffer_data_0[3615:3608];
        layer2[3][23:16] = buffer_data_0[3623:3616];
        layer0[4][7:0] = buffer_data_2[3615:3608];
        layer0[4][15:8] = buffer_data_2[3623:3616];
        layer0[4][23:16] = buffer_data_2[3631:3624];
        layer1[4][7:0] = buffer_data_1[3615:3608];
        layer1[4][15:8] = buffer_data_1[3623:3616];
        layer1[4][23:16] = buffer_data_1[3631:3624];
        layer2[4][7:0] = buffer_data_0[3615:3608];
        layer2[4][15:8] = buffer_data_0[3623:3616];
        layer2[4][23:16] = buffer_data_0[3631:3624];
        layer0[5][7:0] = buffer_data_2[3623:3616];
        layer0[5][15:8] = buffer_data_2[3631:3624];
        layer0[5][23:16] = buffer_data_2[3639:3632];
        layer1[5][7:0] = buffer_data_1[3623:3616];
        layer1[5][15:8] = buffer_data_1[3631:3624];
        layer1[5][23:16] = buffer_data_1[3639:3632];
        layer2[5][7:0] = buffer_data_0[3623:3616];
        layer2[5][15:8] = buffer_data_0[3631:3624];
        layer2[5][23:16] = buffer_data_0[3639:3632];
        layer0[6][7:0] = buffer_data_2[3631:3624];
        layer0[6][15:8] = buffer_data_2[3639:3632];
        layer0[6][23:16] = buffer_data_2[3647:3640];
        layer1[6][7:0] = buffer_data_1[3631:3624];
        layer1[6][15:8] = buffer_data_1[3639:3632];
        layer1[6][23:16] = buffer_data_1[3647:3640];
        layer2[6][7:0] = buffer_data_0[3631:3624];
        layer2[6][15:8] = buffer_data_0[3639:3632];
        layer2[6][23:16] = buffer_data_0[3647:3640];
        layer0[7][7:0] = buffer_data_2[3639:3632];
        layer0[7][15:8] = buffer_data_2[3647:3640];
        layer0[7][23:16] = buffer_data_2[3655:3648];
        layer1[7][7:0] = buffer_data_1[3639:3632];
        layer1[7][15:8] = buffer_data_1[3647:3640];
        layer1[7][23:16] = buffer_data_1[3655:3648];
        layer2[7][7:0] = buffer_data_0[3639:3632];
        layer2[7][15:8] = buffer_data_0[3647:3640];
        layer2[7][23:16] = buffer_data_0[3655:3648];
        layer0[8][7:0] = buffer_data_2[3647:3640];
        layer0[8][15:8] = buffer_data_2[3655:3648];
        layer0[8][23:16] = buffer_data_2[3663:3656];
        layer1[8][7:0] = buffer_data_1[3647:3640];
        layer1[8][15:8] = buffer_data_1[3655:3648];
        layer1[8][23:16] = buffer_data_1[3663:3656];
        layer2[8][7:0] = buffer_data_0[3647:3640];
        layer2[8][15:8] = buffer_data_0[3655:3648];
        layer2[8][23:16] = buffer_data_0[3663:3656];
        layer0[9][7:0] = buffer_data_2[3655:3648];
        layer0[9][15:8] = buffer_data_2[3663:3656];
        layer0[9][23:16] = buffer_data_2[3671:3664];
        layer1[9][7:0] = buffer_data_1[3655:3648];
        layer1[9][15:8] = buffer_data_1[3663:3656];
        layer1[9][23:16] = buffer_data_1[3671:3664];
        layer2[9][7:0] = buffer_data_0[3655:3648];
        layer2[9][15:8] = buffer_data_0[3663:3656];
        layer2[9][23:16] = buffer_data_0[3671:3664];
        layer0[10][7:0] = buffer_data_2[3663:3656];
        layer0[10][15:8] = buffer_data_2[3671:3664];
        layer0[10][23:16] = buffer_data_2[3679:3672];
        layer1[10][7:0] = buffer_data_1[3663:3656];
        layer1[10][15:8] = buffer_data_1[3671:3664];
        layer1[10][23:16] = buffer_data_1[3679:3672];
        layer2[10][7:0] = buffer_data_0[3663:3656];
        layer2[10][15:8] = buffer_data_0[3671:3664];
        layer2[10][23:16] = buffer_data_0[3679:3672];
        layer0[11][7:0] = buffer_data_2[3671:3664];
        layer0[11][15:8] = buffer_data_2[3679:3672];
        layer0[11][23:16] = buffer_data_2[3687:3680];
        layer1[11][7:0] = buffer_data_1[3671:3664];
        layer1[11][15:8] = buffer_data_1[3679:3672];
        layer1[11][23:16] = buffer_data_1[3687:3680];
        layer2[11][7:0] = buffer_data_0[3671:3664];
        layer2[11][15:8] = buffer_data_0[3679:3672];
        layer2[11][23:16] = buffer_data_0[3687:3680];
        layer0[12][7:0] = buffer_data_2[3679:3672];
        layer0[12][15:8] = buffer_data_2[3687:3680];
        layer0[12][23:16] = buffer_data_2[3695:3688];
        layer1[12][7:0] = buffer_data_1[3679:3672];
        layer1[12][15:8] = buffer_data_1[3687:3680];
        layer1[12][23:16] = buffer_data_1[3695:3688];
        layer2[12][7:0] = buffer_data_0[3679:3672];
        layer2[12][15:8] = buffer_data_0[3687:3680];
        layer2[12][23:16] = buffer_data_0[3695:3688];
        layer0[13][7:0] = buffer_data_2[3687:3680];
        layer0[13][15:8] = buffer_data_2[3695:3688];
        layer0[13][23:16] = buffer_data_2[3703:3696];
        layer1[13][7:0] = buffer_data_1[3687:3680];
        layer1[13][15:8] = buffer_data_1[3695:3688];
        layer1[13][23:16] = buffer_data_1[3703:3696];
        layer2[13][7:0] = buffer_data_0[3687:3680];
        layer2[13][15:8] = buffer_data_0[3695:3688];
        layer2[13][23:16] = buffer_data_0[3703:3696];
        layer0[14][7:0] = buffer_data_2[3695:3688];
        layer0[14][15:8] = buffer_data_2[3703:3696];
        layer0[14][23:16] = buffer_data_2[3711:3704];
        layer1[14][7:0] = buffer_data_1[3695:3688];
        layer1[14][15:8] = buffer_data_1[3703:3696];
        layer1[14][23:16] = buffer_data_1[3711:3704];
        layer2[14][7:0] = buffer_data_0[3695:3688];
        layer2[14][15:8] = buffer_data_0[3703:3696];
        layer2[14][23:16] = buffer_data_0[3711:3704];
        layer0[15][7:0] = buffer_data_2[3703:3696];
        layer0[15][15:8] = buffer_data_2[3711:3704];
        layer0[15][23:16] = buffer_data_2[3719:3712];
        layer1[15][7:0] = buffer_data_1[3703:3696];
        layer1[15][15:8] = buffer_data_1[3711:3704];
        layer1[15][23:16] = buffer_data_1[3719:3712];
        layer2[15][7:0] = buffer_data_0[3703:3696];
        layer2[15][15:8] = buffer_data_0[3711:3704];
        layer2[15][23:16] = buffer_data_0[3719:3712];
        layer0[16][7:0] = buffer_data_2[3711:3704];
        layer0[16][15:8] = buffer_data_2[3719:3712];
        layer0[16][23:16] = buffer_data_2[3727:3720];
        layer1[16][7:0] = buffer_data_1[3711:3704];
        layer1[16][15:8] = buffer_data_1[3719:3712];
        layer1[16][23:16] = buffer_data_1[3727:3720];
        layer2[16][7:0] = buffer_data_0[3711:3704];
        layer2[16][15:8] = buffer_data_0[3719:3712];
        layer2[16][23:16] = buffer_data_0[3727:3720];
        layer0[17][7:0] = buffer_data_2[3719:3712];
        layer0[17][15:8] = buffer_data_2[3727:3720];
        layer0[17][23:16] = buffer_data_2[3735:3728];
        layer1[17][7:0] = buffer_data_1[3719:3712];
        layer1[17][15:8] = buffer_data_1[3727:3720];
        layer1[17][23:16] = buffer_data_1[3735:3728];
        layer2[17][7:0] = buffer_data_0[3719:3712];
        layer2[17][15:8] = buffer_data_0[3727:3720];
        layer2[17][23:16] = buffer_data_0[3735:3728];
        layer0[18][7:0] = buffer_data_2[3727:3720];
        layer0[18][15:8] = buffer_data_2[3735:3728];
        layer0[18][23:16] = buffer_data_2[3743:3736];
        layer1[18][7:0] = buffer_data_1[3727:3720];
        layer1[18][15:8] = buffer_data_1[3735:3728];
        layer1[18][23:16] = buffer_data_1[3743:3736];
        layer2[18][7:0] = buffer_data_0[3727:3720];
        layer2[18][15:8] = buffer_data_0[3735:3728];
        layer2[18][23:16] = buffer_data_0[3743:3736];
        layer0[19][7:0] = buffer_data_2[3735:3728];
        layer0[19][15:8] = buffer_data_2[3743:3736];
        layer0[19][23:16] = buffer_data_2[3751:3744];
        layer1[19][7:0] = buffer_data_1[3735:3728];
        layer1[19][15:8] = buffer_data_1[3743:3736];
        layer1[19][23:16] = buffer_data_1[3751:3744];
        layer2[19][7:0] = buffer_data_0[3735:3728];
        layer2[19][15:8] = buffer_data_0[3743:3736];
        layer2[19][23:16] = buffer_data_0[3751:3744];
        layer0[20][7:0] = buffer_data_2[3743:3736];
        layer0[20][15:8] = buffer_data_2[3751:3744];
        layer0[20][23:16] = buffer_data_2[3759:3752];
        layer1[20][7:0] = buffer_data_1[3743:3736];
        layer1[20][15:8] = buffer_data_1[3751:3744];
        layer1[20][23:16] = buffer_data_1[3759:3752];
        layer2[20][7:0] = buffer_data_0[3743:3736];
        layer2[20][15:8] = buffer_data_0[3751:3744];
        layer2[20][23:16] = buffer_data_0[3759:3752];
        layer0[21][7:0] = buffer_data_2[3751:3744];
        layer0[21][15:8] = buffer_data_2[3759:3752];
        layer0[21][23:16] = buffer_data_2[3767:3760];
        layer1[21][7:0] = buffer_data_1[3751:3744];
        layer1[21][15:8] = buffer_data_1[3759:3752];
        layer1[21][23:16] = buffer_data_1[3767:3760];
        layer2[21][7:0] = buffer_data_0[3751:3744];
        layer2[21][15:8] = buffer_data_0[3759:3752];
        layer2[21][23:16] = buffer_data_0[3767:3760];
        layer0[22][7:0] = buffer_data_2[3759:3752];
        layer0[22][15:8] = buffer_data_2[3767:3760];
        layer0[22][23:16] = buffer_data_2[3775:3768];
        layer1[22][7:0] = buffer_data_1[3759:3752];
        layer1[22][15:8] = buffer_data_1[3767:3760];
        layer1[22][23:16] = buffer_data_1[3775:3768];
        layer2[22][7:0] = buffer_data_0[3759:3752];
        layer2[22][15:8] = buffer_data_0[3767:3760];
        layer2[22][23:16] = buffer_data_0[3775:3768];
        layer0[23][7:0] = buffer_data_2[3767:3760];
        layer0[23][15:8] = buffer_data_2[3775:3768];
        layer0[23][23:16] = buffer_data_2[3783:3776];
        layer1[23][7:0] = buffer_data_1[3767:3760];
        layer1[23][15:8] = buffer_data_1[3775:3768];
        layer1[23][23:16] = buffer_data_1[3783:3776];
        layer2[23][7:0] = buffer_data_0[3767:3760];
        layer2[23][15:8] = buffer_data_0[3775:3768];
        layer2[23][23:16] = buffer_data_0[3783:3776];
        layer0[24][7:0] = buffer_data_2[3775:3768];
        layer0[24][15:8] = buffer_data_2[3783:3776];
        layer0[24][23:16] = buffer_data_2[3791:3784];
        layer1[24][7:0] = buffer_data_1[3775:3768];
        layer1[24][15:8] = buffer_data_1[3783:3776];
        layer1[24][23:16] = buffer_data_1[3791:3784];
        layer2[24][7:0] = buffer_data_0[3775:3768];
        layer2[24][15:8] = buffer_data_0[3783:3776];
        layer2[24][23:16] = buffer_data_0[3791:3784];
        layer0[25][7:0] = buffer_data_2[3783:3776];
        layer0[25][15:8] = buffer_data_2[3791:3784];
        layer0[25][23:16] = buffer_data_2[3799:3792];
        layer1[25][7:0] = buffer_data_1[3783:3776];
        layer1[25][15:8] = buffer_data_1[3791:3784];
        layer1[25][23:16] = buffer_data_1[3799:3792];
        layer2[25][7:0] = buffer_data_0[3783:3776];
        layer2[25][15:8] = buffer_data_0[3791:3784];
        layer2[25][23:16] = buffer_data_0[3799:3792];
        layer0[26][7:0] = buffer_data_2[3791:3784];
        layer0[26][15:8] = buffer_data_2[3799:3792];
        layer0[26][23:16] = buffer_data_2[3807:3800];
        layer1[26][7:0] = buffer_data_1[3791:3784];
        layer1[26][15:8] = buffer_data_1[3799:3792];
        layer1[26][23:16] = buffer_data_1[3807:3800];
        layer2[26][7:0] = buffer_data_0[3791:3784];
        layer2[26][15:8] = buffer_data_0[3799:3792];
        layer2[26][23:16] = buffer_data_0[3807:3800];
        layer0[27][7:0] = buffer_data_2[3799:3792];
        layer0[27][15:8] = buffer_data_2[3807:3800];
        layer0[27][23:16] = buffer_data_2[3815:3808];
        layer1[27][7:0] = buffer_data_1[3799:3792];
        layer1[27][15:8] = buffer_data_1[3807:3800];
        layer1[27][23:16] = buffer_data_1[3815:3808];
        layer2[27][7:0] = buffer_data_0[3799:3792];
        layer2[27][15:8] = buffer_data_0[3807:3800];
        layer2[27][23:16] = buffer_data_0[3815:3808];
        layer0[28][7:0] = buffer_data_2[3807:3800];
        layer0[28][15:8] = buffer_data_2[3815:3808];
        layer0[28][23:16] = buffer_data_2[3823:3816];
        layer1[28][7:0] = buffer_data_1[3807:3800];
        layer1[28][15:8] = buffer_data_1[3815:3808];
        layer1[28][23:16] = buffer_data_1[3823:3816];
        layer2[28][7:0] = buffer_data_0[3807:3800];
        layer2[28][15:8] = buffer_data_0[3815:3808];
        layer2[28][23:16] = buffer_data_0[3823:3816];
        layer0[29][7:0] = buffer_data_2[3815:3808];
        layer0[29][15:8] = buffer_data_2[3823:3816];
        layer0[29][23:16] = buffer_data_2[3831:3824];
        layer1[29][7:0] = buffer_data_1[3815:3808];
        layer1[29][15:8] = buffer_data_1[3823:3816];
        layer1[29][23:16] = buffer_data_1[3831:3824];
        layer2[29][7:0] = buffer_data_0[3815:3808];
        layer2[29][15:8] = buffer_data_0[3823:3816];
        layer2[29][23:16] = buffer_data_0[3831:3824];
        layer0[30][7:0] = buffer_data_2[3823:3816];
        layer0[30][15:8] = buffer_data_2[3831:3824];
        layer0[30][23:16] = buffer_data_2[3839:3832];
        layer1[30][7:0] = buffer_data_1[3823:3816];
        layer1[30][15:8] = buffer_data_1[3831:3824];
        layer1[30][23:16] = buffer_data_1[3839:3832];
        layer2[30][7:0] = buffer_data_0[3823:3816];
        layer2[30][15:8] = buffer_data_0[3831:3824];
        layer2[30][23:16] = buffer_data_0[3839:3832];
        layer0[31][7:0] = buffer_data_2[3831:3824];
        layer0[31][15:8] = buffer_data_2[3839:3832];
        layer0[31][23:16] = buffer_data_2[3847:3840];
        layer1[31][7:0] = buffer_data_1[3831:3824];
        layer1[31][15:8] = buffer_data_1[3839:3832];
        layer1[31][23:16] = buffer_data_1[3847:3840];
        layer2[31][7:0] = buffer_data_0[3831:3824];
        layer2[31][15:8] = buffer_data_0[3839:3832];
        layer2[31][23:16] = buffer_data_0[3847:3840];
        layer0[32][7:0] = buffer_data_2[3839:3832];
        layer0[32][15:8] = buffer_data_2[3847:3840];
        layer0[32][23:16] = buffer_data_2[3855:3848];
        layer1[32][7:0] = buffer_data_1[3839:3832];
        layer1[32][15:8] = buffer_data_1[3847:3840];
        layer1[32][23:16] = buffer_data_1[3855:3848];
        layer2[32][7:0] = buffer_data_0[3839:3832];
        layer2[32][15:8] = buffer_data_0[3847:3840];
        layer2[32][23:16] = buffer_data_0[3855:3848];
        layer0[33][7:0] = buffer_data_2[3847:3840];
        layer0[33][15:8] = buffer_data_2[3855:3848];
        layer0[33][23:16] = buffer_data_2[3863:3856];
        layer1[33][7:0] = buffer_data_1[3847:3840];
        layer1[33][15:8] = buffer_data_1[3855:3848];
        layer1[33][23:16] = buffer_data_1[3863:3856];
        layer2[33][7:0] = buffer_data_0[3847:3840];
        layer2[33][15:8] = buffer_data_0[3855:3848];
        layer2[33][23:16] = buffer_data_0[3863:3856];
        layer0[34][7:0] = buffer_data_2[3855:3848];
        layer0[34][15:8] = buffer_data_2[3863:3856];
        layer0[34][23:16] = buffer_data_2[3871:3864];
        layer1[34][7:0] = buffer_data_1[3855:3848];
        layer1[34][15:8] = buffer_data_1[3863:3856];
        layer1[34][23:16] = buffer_data_1[3871:3864];
        layer2[34][7:0] = buffer_data_0[3855:3848];
        layer2[34][15:8] = buffer_data_0[3863:3856];
        layer2[34][23:16] = buffer_data_0[3871:3864];
        layer0[35][7:0] = buffer_data_2[3863:3856];
        layer0[35][15:8] = buffer_data_2[3871:3864];
        layer0[35][23:16] = buffer_data_2[3879:3872];
        layer1[35][7:0] = buffer_data_1[3863:3856];
        layer1[35][15:8] = buffer_data_1[3871:3864];
        layer1[35][23:16] = buffer_data_1[3879:3872];
        layer2[35][7:0] = buffer_data_0[3863:3856];
        layer2[35][15:8] = buffer_data_0[3871:3864];
        layer2[35][23:16] = buffer_data_0[3879:3872];
        layer0[36][7:0] = buffer_data_2[3871:3864];
        layer0[36][15:8] = buffer_data_2[3879:3872];
        layer0[36][23:16] = buffer_data_2[3887:3880];
        layer1[36][7:0] = buffer_data_1[3871:3864];
        layer1[36][15:8] = buffer_data_1[3879:3872];
        layer1[36][23:16] = buffer_data_1[3887:3880];
        layer2[36][7:0] = buffer_data_0[3871:3864];
        layer2[36][15:8] = buffer_data_0[3879:3872];
        layer2[36][23:16] = buffer_data_0[3887:3880];
        layer0[37][7:0] = buffer_data_2[3879:3872];
        layer0[37][15:8] = buffer_data_2[3887:3880];
        layer0[37][23:16] = buffer_data_2[3895:3888];
        layer1[37][7:0] = buffer_data_1[3879:3872];
        layer1[37][15:8] = buffer_data_1[3887:3880];
        layer1[37][23:16] = buffer_data_1[3895:3888];
        layer2[37][7:0] = buffer_data_0[3879:3872];
        layer2[37][15:8] = buffer_data_0[3887:3880];
        layer2[37][23:16] = buffer_data_0[3895:3888];
        layer0[38][7:0] = buffer_data_2[3887:3880];
        layer0[38][15:8] = buffer_data_2[3895:3888];
        layer0[38][23:16] = buffer_data_2[3903:3896];
        layer1[38][7:0] = buffer_data_1[3887:3880];
        layer1[38][15:8] = buffer_data_1[3895:3888];
        layer1[38][23:16] = buffer_data_1[3903:3896];
        layer2[38][7:0] = buffer_data_0[3887:3880];
        layer2[38][15:8] = buffer_data_0[3895:3888];
        layer2[38][23:16] = buffer_data_0[3903:3896];
        layer0[39][7:0] = buffer_data_2[3895:3888];
        layer0[39][15:8] = buffer_data_2[3903:3896];
        layer0[39][23:16] = buffer_data_2[3911:3904];
        layer1[39][7:0] = buffer_data_1[3895:3888];
        layer1[39][15:8] = buffer_data_1[3903:3896];
        layer1[39][23:16] = buffer_data_1[3911:3904];
        layer2[39][7:0] = buffer_data_0[3895:3888];
        layer2[39][15:8] = buffer_data_0[3903:3896];
        layer2[39][23:16] = buffer_data_0[3911:3904];
        layer0[40][7:0] = buffer_data_2[3903:3896];
        layer0[40][15:8] = buffer_data_2[3911:3904];
        layer0[40][23:16] = buffer_data_2[3919:3912];
        layer1[40][7:0] = buffer_data_1[3903:3896];
        layer1[40][15:8] = buffer_data_1[3911:3904];
        layer1[40][23:16] = buffer_data_1[3919:3912];
        layer2[40][7:0] = buffer_data_0[3903:3896];
        layer2[40][15:8] = buffer_data_0[3911:3904];
        layer2[40][23:16] = buffer_data_0[3919:3912];
        layer0[41][7:0] = buffer_data_2[3911:3904];
        layer0[41][15:8] = buffer_data_2[3919:3912];
        layer0[41][23:16] = buffer_data_2[3927:3920];
        layer1[41][7:0] = buffer_data_1[3911:3904];
        layer1[41][15:8] = buffer_data_1[3919:3912];
        layer1[41][23:16] = buffer_data_1[3927:3920];
        layer2[41][7:0] = buffer_data_0[3911:3904];
        layer2[41][15:8] = buffer_data_0[3919:3912];
        layer2[41][23:16] = buffer_data_0[3927:3920];
        layer0[42][7:0] = buffer_data_2[3919:3912];
        layer0[42][15:8] = buffer_data_2[3927:3920];
        layer0[42][23:16] = buffer_data_2[3935:3928];
        layer1[42][7:0] = buffer_data_1[3919:3912];
        layer1[42][15:8] = buffer_data_1[3927:3920];
        layer1[42][23:16] = buffer_data_1[3935:3928];
        layer2[42][7:0] = buffer_data_0[3919:3912];
        layer2[42][15:8] = buffer_data_0[3927:3920];
        layer2[42][23:16] = buffer_data_0[3935:3928];
        layer0[43][7:0] = buffer_data_2[3927:3920];
        layer0[43][15:8] = buffer_data_2[3935:3928];
        layer0[43][23:16] = buffer_data_2[3943:3936];
        layer1[43][7:0] = buffer_data_1[3927:3920];
        layer1[43][15:8] = buffer_data_1[3935:3928];
        layer1[43][23:16] = buffer_data_1[3943:3936];
        layer2[43][7:0] = buffer_data_0[3927:3920];
        layer2[43][15:8] = buffer_data_0[3935:3928];
        layer2[43][23:16] = buffer_data_0[3943:3936];
        layer0[44][7:0] = buffer_data_2[3935:3928];
        layer0[44][15:8] = buffer_data_2[3943:3936];
        layer0[44][23:16] = buffer_data_2[3951:3944];
        layer1[44][7:0] = buffer_data_1[3935:3928];
        layer1[44][15:8] = buffer_data_1[3943:3936];
        layer1[44][23:16] = buffer_data_1[3951:3944];
        layer2[44][7:0] = buffer_data_0[3935:3928];
        layer2[44][15:8] = buffer_data_0[3943:3936];
        layer2[44][23:16] = buffer_data_0[3951:3944];
        layer0[45][7:0] = buffer_data_2[3943:3936];
        layer0[45][15:8] = buffer_data_2[3951:3944];
        layer0[45][23:16] = buffer_data_2[3959:3952];
        layer1[45][7:0] = buffer_data_1[3943:3936];
        layer1[45][15:8] = buffer_data_1[3951:3944];
        layer1[45][23:16] = buffer_data_1[3959:3952];
        layer2[45][7:0] = buffer_data_0[3943:3936];
        layer2[45][15:8] = buffer_data_0[3951:3944];
        layer2[45][23:16] = buffer_data_0[3959:3952];
        layer0[46][7:0] = buffer_data_2[3951:3944];
        layer0[46][15:8] = buffer_data_2[3959:3952];
        layer0[46][23:16] = buffer_data_2[3967:3960];
        layer1[46][7:0] = buffer_data_1[3951:3944];
        layer1[46][15:8] = buffer_data_1[3959:3952];
        layer1[46][23:16] = buffer_data_1[3967:3960];
        layer2[46][7:0] = buffer_data_0[3951:3944];
        layer2[46][15:8] = buffer_data_0[3959:3952];
        layer2[46][23:16] = buffer_data_0[3967:3960];
        layer0[47][7:0] = buffer_data_2[3959:3952];
        layer0[47][15:8] = buffer_data_2[3967:3960];
        layer0[47][23:16] = buffer_data_2[3975:3968];
        layer1[47][7:0] = buffer_data_1[3959:3952];
        layer1[47][15:8] = buffer_data_1[3967:3960];
        layer1[47][23:16] = buffer_data_1[3975:3968];
        layer2[47][7:0] = buffer_data_0[3959:3952];
        layer2[47][15:8] = buffer_data_0[3967:3960];
        layer2[47][23:16] = buffer_data_0[3975:3968];
        layer0[48][7:0] = buffer_data_2[3967:3960];
        layer0[48][15:8] = buffer_data_2[3975:3968];
        layer0[48][23:16] = buffer_data_2[3983:3976];
        layer1[48][7:0] = buffer_data_1[3967:3960];
        layer1[48][15:8] = buffer_data_1[3975:3968];
        layer1[48][23:16] = buffer_data_1[3983:3976];
        layer2[48][7:0] = buffer_data_0[3967:3960];
        layer2[48][15:8] = buffer_data_0[3975:3968];
        layer2[48][23:16] = buffer_data_0[3983:3976];
        layer0[49][7:0] = buffer_data_2[3975:3968];
        layer0[49][15:8] = buffer_data_2[3983:3976];
        layer0[49][23:16] = buffer_data_2[3991:3984];
        layer1[49][7:0] = buffer_data_1[3975:3968];
        layer1[49][15:8] = buffer_data_1[3983:3976];
        layer1[49][23:16] = buffer_data_1[3991:3984];
        layer2[49][7:0] = buffer_data_0[3975:3968];
        layer2[49][15:8] = buffer_data_0[3983:3976];
        layer2[49][23:16] = buffer_data_0[3991:3984];
        layer0[50][7:0] = buffer_data_2[3983:3976];
        layer0[50][15:8] = buffer_data_2[3991:3984];
        layer0[50][23:16] = buffer_data_2[3999:3992];
        layer1[50][7:0] = buffer_data_1[3983:3976];
        layer1[50][15:8] = buffer_data_1[3991:3984];
        layer1[50][23:16] = buffer_data_1[3999:3992];
        layer2[50][7:0] = buffer_data_0[3983:3976];
        layer2[50][15:8] = buffer_data_0[3991:3984];
        layer2[50][23:16] = buffer_data_0[3999:3992];
        layer0[51][7:0] = buffer_data_2[3991:3984];
        layer0[51][15:8] = buffer_data_2[3999:3992];
        layer0[51][23:16] = buffer_data_2[4007:4000];
        layer1[51][7:0] = buffer_data_1[3991:3984];
        layer1[51][15:8] = buffer_data_1[3999:3992];
        layer1[51][23:16] = buffer_data_1[4007:4000];
        layer2[51][7:0] = buffer_data_0[3991:3984];
        layer2[51][15:8] = buffer_data_0[3999:3992];
        layer2[51][23:16] = buffer_data_0[4007:4000];
        layer0[52][7:0] = buffer_data_2[3999:3992];
        layer0[52][15:8] = buffer_data_2[4007:4000];
        layer0[52][23:16] = buffer_data_2[4015:4008];
        layer1[52][7:0] = buffer_data_1[3999:3992];
        layer1[52][15:8] = buffer_data_1[4007:4000];
        layer1[52][23:16] = buffer_data_1[4015:4008];
        layer2[52][7:0] = buffer_data_0[3999:3992];
        layer2[52][15:8] = buffer_data_0[4007:4000];
        layer2[52][23:16] = buffer_data_0[4015:4008];
        layer0[53][7:0] = buffer_data_2[4007:4000];
        layer0[53][15:8] = buffer_data_2[4015:4008];
        layer0[53][23:16] = buffer_data_2[4023:4016];
        layer1[53][7:0] = buffer_data_1[4007:4000];
        layer1[53][15:8] = buffer_data_1[4015:4008];
        layer1[53][23:16] = buffer_data_1[4023:4016];
        layer2[53][7:0] = buffer_data_0[4007:4000];
        layer2[53][15:8] = buffer_data_0[4015:4008];
        layer2[53][23:16] = buffer_data_0[4023:4016];
        layer0[54][7:0] = buffer_data_2[4015:4008];
        layer0[54][15:8] = buffer_data_2[4023:4016];
        layer0[54][23:16] = buffer_data_2[4031:4024];
        layer1[54][7:0] = buffer_data_1[4015:4008];
        layer1[54][15:8] = buffer_data_1[4023:4016];
        layer1[54][23:16] = buffer_data_1[4031:4024];
        layer2[54][7:0] = buffer_data_0[4015:4008];
        layer2[54][15:8] = buffer_data_0[4023:4016];
        layer2[54][23:16] = buffer_data_0[4031:4024];
        layer0[55][7:0] = buffer_data_2[4023:4016];
        layer0[55][15:8] = buffer_data_2[4031:4024];
        layer0[55][23:16] = buffer_data_2[4039:4032];
        layer1[55][7:0] = buffer_data_1[4023:4016];
        layer1[55][15:8] = buffer_data_1[4031:4024];
        layer1[55][23:16] = buffer_data_1[4039:4032];
        layer2[55][7:0] = buffer_data_0[4023:4016];
        layer2[55][15:8] = buffer_data_0[4031:4024];
        layer2[55][23:16] = buffer_data_0[4039:4032];
        layer0[56][7:0] = buffer_data_2[4031:4024];
        layer0[56][15:8] = buffer_data_2[4039:4032];
        layer0[56][23:16] = buffer_data_2[4047:4040];
        layer1[56][7:0] = buffer_data_1[4031:4024];
        layer1[56][15:8] = buffer_data_1[4039:4032];
        layer1[56][23:16] = buffer_data_1[4047:4040];
        layer2[56][7:0] = buffer_data_0[4031:4024];
        layer2[56][15:8] = buffer_data_0[4039:4032];
        layer2[56][23:16] = buffer_data_0[4047:4040];
        layer0[57][7:0] = buffer_data_2[4039:4032];
        layer0[57][15:8] = buffer_data_2[4047:4040];
        layer0[57][23:16] = buffer_data_2[4055:4048];
        layer1[57][7:0] = buffer_data_1[4039:4032];
        layer1[57][15:8] = buffer_data_1[4047:4040];
        layer1[57][23:16] = buffer_data_1[4055:4048];
        layer2[57][7:0] = buffer_data_0[4039:4032];
        layer2[57][15:8] = buffer_data_0[4047:4040];
        layer2[57][23:16] = buffer_data_0[4055:4048];
        layer0[58][7:0] = buffer_data_2[4047:4040];
        layer0[58][15:8] = buffer_data_2[4055:4048];
        layer0[58][23:16] = buffer_data_2[4063:4056];
        layer1[58][7:0] = buffer_data_1[4047:4040];
        layer1[58][15:8] = buffer_data_1[4055:4048];
        layer1[58][23:16] = buffer_data_1[4063:4056];
        layer2[58][7:0] = buffer_data_0[4047:4040];
        layer2[58][15:8] = buffer_data_0[4055:4048];
        layer2[58][23:16] = buffer_data_0[4063:4056];
        layer0[59][7:0] = buffer_data_2[4055:4048];
        layer0[59][15:8] = buffer_data_2[4063:4056];
        layer0[59][23:16] = buffer_data_2[4071:4064];
        layer1[59][7:0] = buffer_data_1[4055:4048];
        layer1[59][15:8] = buffer_data_1[4063:4056];
        layer1[59][23:16] = buffer_data_1[4071:4064];
        layer2[59][7:0] = buffer_data_0[4055:4048];
        layer2[59][15:8] = buffer_data_0[4063:4056];
        layer2[59][23:16] = buffer_data_0[4071:4064];
        layer0[60][7:0] = buffer_data_2[4063:4056];
        layer0[60][15:8] = buffer_data_2[4071:4064];
        layer0[60][23:16] = buffer_data_2[4079:4072];
        layer1[60][7:0] = buffer_data_1[4063:4056];
        layer1[60][15:8] = buffer_data_1[4071:4064];
        layer1[60][23:16] = buffer_data_1[4079:4072];
        layer2[60][7:0] = buffer_data_0[4063:4056];
        layer2[60][15:8] = buffer_data_0[4071:4064];
        layer2[60][23:16] = buffer_data_0[4079:4072];
        layer0[61][7:0] = buffer_data_2[4071:4064];
        layer0[61][15:8] = buffer_data_2[4079:4072];
        layer0[61][23:16] = buffer_data_2[4087:4080];
        layer1[61][7:0] = buffer_data_1[4071:4064];
        layer1[61][15:8] = buffer_data_1[4079:4072];
        layer1[61][23:16] = buffer_data_1[4087:4080];
        layer2[61][7:0] = buffer_data_0[4071:4064];
        layer2[61][15:8] = buffer_data_0[4079:4072];
        layer2[61][23:16] = buffer_data_0[4087:4080];
        layer0[62][7:0] = buffer_data_2[4079:4072];
        layer0[62][15:8] = buffer_data_2[4087:4080];
        layer0[62][23:16] = buffer_data_2[4095:4088];
        layer1[62][7:0] = buffer_data_1[4079:4072];
        layer1[62][15:8] = buffer_data_1[4087:4080];
        layer1[62][23:16] = buffer_data_1[4095:4088];
        layer2[62][7:0] = buffer_data_0[4079:4072];
        layer2[62][15:8] = buffer_data_0[4087:4080];
        layer2[62][23:16] = buffer_data_0[4095:4088];
        layer0[63][7:0] = buffer_data_2[4087:4080];
        layer0[63][15:8] = buffer_data_2[4095:4088];
        layer0[63][23:16] = buffer_data_2[4103:4096];
        layer1[63][7:0] = buffer_data_1[4087:4080];
        layer1[63][15:8] = buffer_data_1[4095:4088];
        layer1[63][23:16] = buffer_data_1[4103:4096];
        layer2[63][7:0] = buffer_data_0[4087:4080];
        layer2[63][15:8] = buffer_data_0[4095:4088];
        layer2[63][23:16] = buffer_data_0[4103:4096];
    end
    ST_GAUSSIAN_8: begin
        layer0[0][7:0] = buffer_data_2[4095:4088];
        layer0[0][15:8] = buffer_data_2[4103:4096];
        layer0[0][23:16] = buffer_data_2[4111:4104];
        layer1[0][7:0] = buffer_data_1[4095:4088];
        layer1[0][15:8] = buffer_data_1[4103:4096];
        layer1[0][23:16] = buffer_data_1[4111:4104];
        layer2[0][7:0] = buffer_data_0[4095:4088];
        layer2[0][15:8] = buffer_data_0[4103:4096];
        layer2[0][23:16] = buffer_data_0[4111:4104];
        layer0[1][7:0] = buffer_data_2[4103:4096];
        layer0[1][15:8] = buffer_data_2[4111:4104];
        layer0[1][23:16] = buffer_data_2[4119:4112];
        layer1[1][7:0] = buffer_data_1[4103:4096];
        layer1[1][15:8] = buffer_data_1[4111:4104];
        layer1[1][23:16] = buffer_data_1[4119:4112];
        layer2[1][7:0] = buffer_data_0[4103:4096];
        layer2[1][15:8] = buffer_data_0[4111:4104];
        layer2[1][23:16] = buffer_data_0[4119:4112];
        layer0[2][7:0] = buffer_data_2[4111:4104];
        layer0[2][15:8] = buffer_data_2[4119:4112];
        layer0[2][23:16] = buffer_data_2[4127:4120];
        layer1[2][7:0] = buffer_data_1[4111:4104];
        layer1[2][15:8] = buffer_data_1[4119:4112];
        layer1[2][23:16] = buffer_data_1[4127:4120];
        layer2[2][7:0] = buffer_data_0[4111:4104];
        layer2[2][15:8] = buffer_data_0[4119:4112];
        layer2[2][23:16] = buffer_data_0[4127:4120];
        layer0[3][7:0] = buffer_data_2[4119:4112];
        layer0[3][15:8] = buffer_data_2[4127:4120];
        layer0[3][23:16] = buffer_data_2[4135:4128];
        layer1[3][7:0] = buffer_data_1[4119:4112];
        layer1[3][15:8] = buffer_data_1[4127:4120];
        layer1[3][23:16] = buffer_data_1[4135:4128];
        layer2[3][7:0] = buffer_data_0[4119:4112];
        layer2[3][15:8] = buffer_data_0[4127:4120];
        layer2[3][23:16] = buffer_data_0[4135:4128];
        layer0[4][7:0] = buffer_data_2[4127:4120];
        layer0[4][15:8] = buffer_data_2[4135:4128];
        layer0[4][23:16] = buffer_data_2[4143:4136];
        layer1[4][7:0] = buffer_data_1[4127:4120];
        layer1[4][15:8] = buffer_data_1[4135:4128];
        layer1[4][23:16] = buffer_data_1[4143:4136];
        layer2[4][7:0] = buffer_data_0[4127:4120];
        layer2[4][15:8] = buffer_data_0[4135:4128];
        layer2[4][23:16] = buffer_data_0[4143:4136];
        layer0[5][7:0] = buffer_data_2[4135:4128];
        layer0[5][15:8] = buffer_data_2[4143:4136];
        layer0[5][23:16] = buffer_data_2[4151:4144];
        layer1[5][7:0] = buffer_data_1[4135:4128];
        layer1[5][15:8] = buffer_data_1[4143:4136];
        layer1[5][23:16] = buffer_data_1[4151:4144];
        layer2[5][7:0] = buffer_data_0[4135:4128];
        layer2[5][15:8] = buffer_data_0[4143:4136];
        layer2[5][23:16] = buffer_data_0[4151:4144];
        layer0[6][7:0] = buffer_data_2[4143:4136];
        layer0[6][15:8] = buffer_data_2[4151:4144];
        layer0[6][23:16] = buffer_data_2[4159:4152];
        layer1[6][7:0] = buffer_data_1[4143:4136];
        layer1[6][15:8] = buffer_data_1[4151:4144];
        layer1[6][23:16] = buffer_data_1[4159:4152];
        layer2[6][7:0] = buffer_data_0[4143:4136];
        layer2[6][15:8] = buffer_data_0[4151:4144];
        layer2[6][23:16] = buffer_data_0[4159:4152];
        layer0[7][7:0] = buffer_data_2[4151:4144];
        layer0[7][15:8] = buffer_data_2[4159:4152];
        layer0[7][23:16] = buffer_data_2[4167:4160];
        layer1[7][7:0] = buffer_data_1[4151:4144];
        layer1[7][15:8] = buffer_data_1[4159:4152];
        layer1[7][23:16] = buffer_data_1[4167:4160];
        layer2[7][7:0] = buffer_data_0[4151:4144];
        layer2[7][15:8] = buffer_data_0[4159:4152];
        layer2[7][23:16] = buffer_data_0[4167:4160];
        layer0[8][7:0] = buffer_data_2[4159:4152];
        layer0[8][15:8] = buffer_data_2[4167:4160];
        layer0[8][23:16] = buffer_data_2[4175:4168];
        layer1[8][7:0] = buffer_data_1[4159:4152];
        layer1[8][15:8] = buffer_data_1[4167:4160];
        layer1[8][23:16] = buffer_data_1[4175:4168];
        layer2[8][7:0] = buffer_data_0[4159:4152];
        layer2[8][15:8] = buffer_data_0[4167:4160];
        layer2[8][23:16] = buffer_data_0[4175:4168];
        layer0[9][7:0] = buffer_data_2[4167:4160];
        layer0[9][15:8] = buffer_data_2[4175:4168];
        layer0[9][23:16] = buffer_data_2[4183:4176];
        layer1[9][7:0] = buffer_data_1[4167:4160];
        layer1[9][15:8] = buffer_data_1[4175:4168];
        layer1[9][23:16] = buffer_data_1[4183:4176];
        layer2[9][7:0] = buffer_data_0[4167:4160];
        layer2[9][15:8] = buffer_data_0[4175:4168];
        layer2[9][23:16] = buffer_data_0[4183:4176];
        layer0[10][7:0] = buffer_data_2[4175:4168];
        layer0[10][15:8] = buffer_data_2[4183:4176];
        layer0[10][23:16] = buffer_data_2[4191:4184];
        layer1[10][7:0] = buffer_data_1[4175:4168];
        layer1[10][15:8] = buffer_data_1[4183:4176];
        layer1[10][23:16] = buffer_data_1[4191:4184];
        layer2[10][7:0] = buffer_data_0[4175:4168];
        layer2[10][15:8] = buffer_data_0[4183:4176];
        layer2[10][23:16] = buffer_data_0[4191:4184];
        layer0[11][7:0] = buffer_data_2[4183:4176];
        layer0[11][15:8] = buffer_data_2[4191:4184];
        layer0[11][23:16] = buffer_data_2[4199:4192];
        layer1[11][7:0] = buffer_data_1[4183:4176];
        layer1[11][15:8] = buffer_data_1[4191:4184];
        layer1[11][23:16] = buffer_data_1[4199:4192];
        layer2[11][7:0] = buffer_data_0[4183:4176];
        layer2[11][15:8] = buffer_data_0[4191:4184];
        layer2[11][23:16] = buffer_data_0[4199:4192];
        layer0[12][7:0] = buffer_data_2[4191:4184];
        layer0[12][15:8] = buffer_data_2[4199:4192];
        layer0[12][23:16] = buffer_data_2[4207:4200];
        layer1[12][7:0] = buffer_data_1[4191:4184];
        layer1[12][15:8] = buffer_data_1[4199:4192];
        layer1[12][23:16] = buffer_data_1[4207:4200];
        layer2[12][7:0] = buffer_data_0[4191:4184];
        layer2[12][15:8] = buffer_data_0[4199:4192];
        layer2[12][23:16] = buffer_data_0[4207:4200];
        layer0[13][7:0] = buffer_data_2[4199:4192];
        layer0[13][15:8] = buffer_data_2[4207:4200];
        layer0[13][23:16] = buffer_data_2[4215:4208];
        layer1[13][7:0] = buffer_data_1[4199:4192];
        layer1[13][15:8] = buffer_data_1[4207:4200];
        layer1[13][23:16] = buffer_data_1[4215:4208];
        layer2[13][7:0] = buffer_data_0[4199:4192];
        layer2[13][15:8] = buffer_data_0[4207:4200];
        layer2[13][23:16] = buffer_data_0[4215:4208];
        layer0[14][7:0] = buffer_data_2[4207:4200];
        layer0[14][15:8] = buffer_data_2[4215:4208];
        layer0[14][23:16] = buffer_data_2[4223:4216];
        layer1[14][7:0] = buffer_data_1[4207:4200];
        layer1[14][15:8] = buffer_data_1[4215:4208];
        layer1[14][23:16] = buffer_data_1[4223:4216];
        layer2[14][7:0] = buffer_data_0[4207:4200];
        layer2[14][15:8] = buffer_data_0[4215:4208];
        layer2[14][23:16] = buffer_data_0[4223:4216];
        layer0[15][7:0] = buffer_data_2[4215:4208];
        layer0[15][15:8] = buffer_data_2[4223:4216];
        layer0[15][23:16] = buffer_data_2[4231:4224];
        layer1[15][7:0] = buffer_data_1[4215:4208];
        layer1[15][15:8] = buffer_data_1[4223:4216];
        layer1[15][23:16] = buffer_data_1[4231:4224];
        layer2[15][7:0] = buffer_data_0[4215:4208];
        layer2[15][15:8] = buffer_data_0[4223:4216];
        layer2[15][23:16] = buffer_data_0[4231:4224];
        layer0[16][7:0] = buffer_data_2[4223:4216];
        layer0[16][15:8] = buffer_data_2[4231:4224];
        layer0[16][23:16] = buffer_data_2[4239:4232];
        layer1[16][7:0] = buffer_data_1[4223:4216];
        layer1[16][15:8] = buffer_data_1[4231:4224];
        layer1[16][23:16] = buffer_data_1[4239:4232];
        layer2[16][7:0] = buffer_data_0[4223:4216];
        layer2[16][15:8] = buffer_data_0[4231:4224];
        layer2[16][23:16] = buffer_data_0[4239:4232];
        layer0[17][7:0] = buffer_data_2[4231:4224];
        layer0[17][15:8] = buffer_data_2[4239:4232];
        layer0[17][23:16] = buffer_data_2[4247:4240];
        layer1[17][7:0] = buffer_data_1[4231:4224];
        layer1[17][15:8] = buffer_data_1[4239:4232];
        layer1[17][23:16] = buffer_data_1[4247:4240];
        layer2[17][7:0] = buffer_data_0[4231:4224];
        layer2[17][15:8] = buffer_data_0[4239:4232];
        layer2[17][23:16] = buffer_data_0[4247:4240];
        layer0[18][7:0] = buffer_data_2[4239:4232];
        layer0[18][15:8] = buffer_data_2[4247:4240];
        layer0[18][23:16] = buffer_data_2[4255:4248];
        layer1[18][7:0] = buffer_data_1[4239:4232];
        layer1[18][15:8] = buffer_data_1[4247:4240];
        layer1[18][23:16] = buffer_data_1[4255:4248];
        layer2[18][7:0] = buffer_data_0[4239:4232];
        layer2[18][15:8] = buffer_data_0[4247:4240];
        layer2[18][23:16] = buffer_data_0[4255:4248];
        layer0[19][7:0] = buffer_data_2[4247:4240];
        layer0[19][15:8] = buffer_data_2[4255:4248];
        layer0[19][23:16] = buffer_data_2[4263:4256];
        layer1[19][7:0] = buffer_data_1[4247:4240];
        layer1[19][15:8] = buffer_data_1[4255:4248];
        layer1[19][23:16] = buffer_data_1[4263:4256];
        layer2[19][7:0] = buffer_data_0[4247:4240];
        layer2[19][15:8] = buffer_data_0[4255:4248];
        layer2[19][23:16] = buffer_data_0[4263:4256];
        layer0[20][7:0] = buffer_data_2[4255:4248];
        layer0[20][15:8] = buffer_data_2[4263:4256];
        layer0[20][23:16] = buffer_data_2[4271:4264];
        layer1[20][7:0] = buffer_data_1[4255:4248];
        layer1[20][15:8] = buffer_data_1[4263:4256];
        layer1[20][23:16] = buffer_data_1[4271:4264];
        layer2[20][7:0] = buffer_data_0[4255:4248];
        layer2[20][15:8] = buffer_data_0[4263:4256];
        layer2[20][23:16] = buffer_data_0[4271:4264];
        layer0[21][7:0] = buffer_data_2[4263:4256];
        layer0[21][15:8] = buffer_data_2[4271:4264];
        layer0[21][23:16] = buffer_data_2[4279:4272];
        layer1[21][7:0] = buffer_data_1[4263:4256];
        layer1[21][15:8] = buffer_data_1[4271:4264];
        layer1[21][23:16] = buffer_data_1[4279:4272];
        layer2[21][7:0] = buffer_data_0[4263:4256];
        layer2[21][15:8] = buffer_data_0[4271:4264];
        layer2[21][23:16] = buffer_data_0[4279:4272];
        layer0[22][7:0] = buffer_data_2[4271:4264];
        layer0[22][15:8] = buffer_data_2[4279:4272];
        layer0[22][23:16] = buffer_data_2[4287:4280];
        layer1[22][7:0] = buffer_data_1[4271:4264];
        layer1[22][15:8] = buffer_data_1[4279:4272];
        layer1[22][23:16] = buffer_data_1[4287:4280];
        layer2[22][7:0] = buffer_data_0[4271:4264];
        layer2[22][15:8] = buffer_data_0[4279:4272];
        layer2[22][23:16] = buffer_data_0[4287:4280];
        layer0[23][7:0] = buffer_data_2[4279:4272];
        layer0[23][15:8] = buffer_data_2[4287:4280];
        layer0[23][23:16] = buffer_data_2[4295:4288];
        layer1[23][7:0] = buffer_data_1[4279:4272];
        layer1[23][15:8] = buffer_data_1[4287:4280];
        layer1[23][23:16] = buffer_data_1[4295:4288];
        layer2[23][7:0] = buffer_data_0[4279:4272];
        layer2[23][15:8] = buffer_data_0[4287:4280];
        layer2[23][23:16] = buffer_data_0[4295:4288];
        layer0[24][7:0] = buffer_data_2[4287:4280];
        layer0[24][15:8] = buffer_data_2[4295:4288];
        layer0[24][23:16] = buffer_data_2[4303:4296];
        layer1[24][7:0] = buffer_data_1[4287:4280];
        layer1[24][15:8] = buffer_data_1[4295:4288];
        layer1[24][23:16] = buffer_data_1[4303:4296];
        layer2[24][7:0] = buffer_data_0[4287:4280];
        layer2[24][15:8] = buffer_data_0[4295:4288];
        layer2[24][23:16] = buffer_data_0[4303:4296];
        layer0[25][7:0] = buffer_data_2[4295:4288];
        layer0[25][15:8] = buffer_data_2[4303:4296];
        layer0[25][23:16] = buffer_data_2[4311:4304];
        layer1[25][7:0] = buffer_data_1[4295:4288];
        layer1[25][15:8] = buffer_data_1[4303:4296];
        layer1[25][23:16] = buffer_data_1[4311:4304];
        layer2[25][7:0] = buffer_data_0[4295:4288];
        layer2[25][15:8] = buffer_data_0[4303:4296];
        layer2[25][23:16] = buffer_data_0[4311:4304];
        layer0[26][7:0] = buffer_data_2[4303:4296];
        layer0[26][15:8] = buffer_data_2[4311:4304];
        layer0[26][23:16] = buffer_data_2[4319:4312];
        layer1[26][7:0] = buffer_data_1[4303:4296];
        layer1[26][15:8] = buffer_data_1[4311:4304];
        layer1[26][23:16] = buffer_data_1[4319:4312];
        layer2[26][7:0] = buffer_data_0[4303:4296];
        layer2[26][15:8] = buffer_data_0[4311:4304];
        layer2[26][23:16] = buffer_data_0[4319:4312];
        layer0[27][7:0] = buffer_data_2[4311:4304];
        layer0[27][15:8] = buffer_data_2[4319:4312];
        layer0[27][23:16] = buffer_data_2[4327:4320];
        layer1[27][7:0] = buffer_data_1[4311:4304];
        layer1[27][15:8] = buffer_data_1[4319:4312];
        layer1[27][23:16] = buffer_data_1[4327:4320];
        layer2[27][7:0] = buffer_data_0[4311:4304];
        layer2[27][15:8] = buffer_data_0[4319:4312];
        layer2[27][23:16] = buffer_data_0[4327:4320];
        layer0[28][7:0] = buffer_data_2[4319:4312];
        layer0[28][15:8] = buffer_data_2[4327:4320];
        layer0[28][23:16] = buffer_data_2[4335:4328];
        layer1[28][7:0] = buffer_data_1[4319:4312];
        layer1[28][15:8] = buffer_data_1[4327:4320];
        layer1[28][23:16] = buffer_data_1[4335:4328];
        layer2[28][7:0] = buffer_data_0[4319:4312];
        layer2[28][15:8] = buffer_data_0[4327:4320];
        layer2[28][23:16] = buffer_data_0[4335:4328];
        layer0[29][7:0] = buffer_data_2[4327:4320];
        layer0[29][15:8] = buffer_data_2[4335:4328];
        layer0[29][23:16] = buffer_data_2[4343:4336];
        layer1[29][7:0] = buffer_data_1[4327:4320];
        layer1[29][15:8] = buffer_data_1[4335:4328];
        layer1[29][23:16] = buffer_data_1[4343:4336];
        layer2[29][7:0] = buffer_data_0[4327:4320];
        layer2[29][15:8] = buffer_data_0[4335:4328];
        layer2[29][23:16] = buffer_data_0[4343:4336];
        layer0[30][7:0] = buffer_data_2[4335:4328];
        layer0[30][15:8] = buffer_data_2[4343:4336];
        layer0[30][23:16] = buffer_data_2[4351:4344];
        layer1[30][7:0] = buffer_data_1[4335:4328];
        layer1[30][15:8] = buffer_data_1[4343:4336];
        layer1[30][23:16] = buffer_data_1[4351:4344];
        layer2[30][7:0] = buffer_data_0[4335:4328];
        layer2[30][15:8] = buffer_data_0[4343:4336];
        layer2[30][23:16] = buffer_data_0[4351:4344];
        layer0[31][7:0] = buffer_data_2[4343:4336];
        layer0[31][15:8] = buffer_data_2[4351:4344];
        layer0[31][23:16] = buffer_data_2[4359:4352];
        layer1[31][7:0] = buffer_data_1[4343:4336];
        layer1[31][15:8] = buffer_data_1[4351:4344];
        layer1[31][23:16] = buffer_data_1[4359:4352];
        layer2[31][7:0] = buffer_data_0[4343:4336];
        layer2[31][15:8] = buffer_data_0[4351:4344];
        layer2[31][23:16] = buffer_data_0[4359:4352];
        layer0[32][7:0] = buffer_data_2[4351:4344];
        layer0[32][15:8] = buffer_data_2[4359:4352];
        layer0[32][23:16] = buffer_data_2[4367:4360];
        layer1[32][7:0] = buffer_data_1[4351:4344];
        layer1[32][15:8] = buffer_data_1[4359:4352];
        layer1[32][23:16] = buffer_data_1[4367:4360];
        layer2[32][7:0] = buffer_data_0[4351:4344];
        layer2[32][15:8] = buffer_data_0[4359:4352];
        layer2[32][23:16] = buffer_data_0[4367:4360];
        layer0[33][7:0] = buffer_data_2[4359:4352];
        layer0[33][15:8] = buffer_data_2[4367:4360];
        layer0[33][23:16] = buffer_data_2[4375:4368];
        layer1[33][7:0] = buffer_data_1[4359:4352];
        layer1[33][15:8] = buffer_data_1[4367:4360];
        layer1[33][23:16] = buffer_data_1[4375:4368];
        layer2[33][7:0] = buffer_data_0[4359:4352];
        layer2[33][15:8] = buffer_data_0[4367:4360];
        layer2[33][23:16] = buffer_data_0[4375:4368];
        layer0[34][7:0] = buffer_data_2[4367:4360];
        layer0[34][15:8] = buffer_data_2[4375:4368];
        layer0[34][23:16] = buffer_data_2[4383:4376];
        layer1[34][7:0] = buffer_data_1[4367:4360];
        layer1[34][15:8] = buffer_data_1[4375:4368];
        layer1[34][23:16] = buffer_data_1[4383:4376];
        layer2[34][7:0] = buffer_data_0[4367:4360];
        layer2[34][15:8] = buffer_data_0[4375:4368];
        layer2[34][23:16] = buffer_data_0[4383:4376];
        layer0[35][7:0] = buffer_data_2[4375:4368];
        layer0[35][15:8] = buffer_data_2[4383:4376];
        layer0[35][23:16] = buffer_data_2[4391:4384];
        layer1[35][7:0] = buffer_data_1[4375:4368];
        layer1[35][15:8] = buffer_data_1[4383:4376];
        layer1[35][23:16] = buffer_data_1[4391:4384];
        layer2[35][7:0] = buffer_data_0[4375:4368];
        layer2[35][15:8] = buffer_data_0[4383:4376];
        layer2[35][23:16] = buffer_data_0[4391:4384];
        layer0[36][7:0] = buffer_data_2[4383:4376];
        layer0[36][15:8] = buffer_data_2[4391:4384];
        layer0[36][23:16] = buffer_data_2[4399:4392];
        layer1[36][7:0] = buffer_data_1[4383:4376];
        layer1[36][15:8] = buffer_data_1[4391:4384];
        layer1[36][23:16] = buffer_data_1[4399:4392];
        layer2[36][7:0] = buffer_data_0[4383:4376];
        layer2[36][15:8] = buffer_data_0[4391:4384];
        layer2[36][23:16] = buffer_data_0[4399:4392];
        layer0[37][7:0] = buffer_data_2[4391:4384];
        layer0[37][15:8] = buffer_data_2[4399:4392];
        layer0[37][23:16] = buffer_data_2[4407:4400];
        layer1[37][7:0] = buffer_data_1[4391:4384];
        layer1[37][15:8] = buffer_data_1[4399:4392];
        layer1[37][23:16] = buffer_data_1[4407:4400];
        layer2[37][7:0] = buffer_data_0[4391:4384];
        layer2[37][15:8] = buffer_data_0[4399:4392];
        layer2[37][23:16] = buffer_data_0[4407:4400];
        layer0[38][7:0] = buffer_data_2[4399:4392];
        layer0[38][15:8] = buffer_data_2[4407:4400];
        layer0[38][23:16] = buffer_data_2[4415:4408];
        layer1[38][7:0] = buffer_data_1[4399:4392];
        layer1[38][15:8] = buffer_data_1[4407:4400];
        layer1[38][23:16] = buffer_data_1[4415:4408];
        layer2[38][7:0] = buffer_data_0[4399:4392];
        layer2[38][15:8] = buffer_data_0[4407:4400];
        layer2[38][23:16] = buffer_data_0[4415:4408];
        layer0[39][7:0] = buffer_data_2[4407:4400];
        layer0[39][15:8] = buffer_data_2[4415:4408];
        layer0[39][23:16] = buffer_data_2[4423:4416];
        layer1[39][7:0] = buffer_data_1[4407:4400];
        layer1[39][15:8] = buffer_data_1[4415:4408];
        layer1[39][23:16] = buffer_data_1[4423:4416];
        layer2[39][7:0] = buffer_data_0[4407:4400];
        layer2[39][15:8] = buffer_data_0[4415:4408];
        layer2[39][23:16] = buffer_data_0[4423:4416];
        layer0[40][7:0] = buffer_data_2[4415:4408];
        layer0[40][15:8] = buffer_data_2[4423:4416];
        layer0[40][23:16] = buffer_data_2[4431:4424];
        layer1[40][7:0] = buffer_data_1[4415:4408];
        layer1[40][15:8] = buffer_data_1[4423:4416];
        layer1[40][23:16] = buffer_data_1[4431:4424];
        layer2[40][7:0] = buffer_data_0[4415:4408];
        layer2[40][15:8] = buffer_data_0[4423:4416];
        layer2[40][23:16] = buffer_data_0[4431:4424];
        layer0[41][7:0] = buffer_data_2[4423:4416];
        layer0[41][15:8] = buffer_data_2[4431:4424];
        layer0[41][23:16] = buffer_data_2[4439:4432];
        layer1[41][7:0] = buffer_data_1[4423:4416];
        layer1[41][15:8] = buffer_data_1[4431:4424];
        layer1[41][23:16] = buffer_data_1[4439:4432];
        layer2[41][7:0] = buffer_data_0[4423:4416];
        layer2[41][15:8] = buffer_data_0[4431:4424];
        layer2[41][23:16] = buffer_data_0[4439:4432];
        layer0[42][7:0] = buffer_data_2[4431:4424];
        layer0[42][15:8] = buffer_data_2[4439:4432];
        layer0[42][23:16] = buffer_data_2[4447:4440];
        layer1[42][7:0] = buffer_data_1[4431:4424];
        layer1[42][15:8] = buffer_data_1[4439:4432];
        layer1[42][23:16] = buffer_data_1[4447:4440];
        layer2[42][7:0] = buffer_data_0[4431:4424];
        layer2[42][15:8] = buffer_data_0[4439:4432];
        layer2[42][23:16] = buffer_data_0[4447:4440];
        layer0[43][7:0] = buffer_data_2[4439:4432];
        layer0[43][15:8] = buffer_data_2[4447:4440];
        layer0[43][23:16] = buffer_data_2[4455:4448];
        layer1[43][7:0] = buffer_data_1[4439:4432];
        layer1[43][15:8] = buffer_data_1[4447:4440];
        layer1[43][23:16] = buffer_data_1[4455:4448];
        layer2[43][7:0] = buffer_data_0[4439:4432];
        layer2[43][15:8] = buffer_data_0[4447:4440];
        layer2[43][23:16] = buffer_data_0[4455:4448];
        layer0[44][7:0] = buffer_data_2[4447:4440];
        layer0[44][15:8] = buffer_data_2[4455:4448];
        layer0[44][23:16] = buffer_data_2[4463:4456];
        layer1[44][7:0] = buffer_data_1[4447:4440];
        layer1[44][15:8] = buffer_data_1[4455:4448];
        layer1[44][23:16] = buffer_data_1[4463:4456];
        layer2[44][7:0] = buffer_data_0[4447:4440];
        layer2[44][15:8] = buffer_data_0[4455:4448];
        layer2[44][23:16] = buffer_data_0[4463:4456];
        layer0[45][7:0] = buffer_data_2[4455:4448];
        layer0[45][15:8] = buffer_data_2[4463:4456];
        layer0[45][23:16] = buffer_data_2[4471:4464];
        layer1[45][7:0] = buffer_data_1[4455:4448];
        layer1[45][15:8] = buffer_data_1[4463:4456];
        layer1[45][23:16] = buffer_data_1[4471:4464];
        layer2[45][7:0] = buffer_data_0[4455:4448];
        layer2[45][15:8] = buffer_data_0[4463:4456];
        layer2[45][23:16] = buffer_data_0[4471:4464];
        layer0[46][7:0] = buffer_data_2[4463:4456];
        layer0[46][15:8] = buffer_data_2[4471:4464];
        layer0[46][23:16] = buffer_data_2[4479:4472];
        layer1[46][7:0] = buffer_data_1[4463:4456];
        layer1[46][15:8] = buffer_data_1[4471:4464];
        layer1[46][23:16] = buffer_data_1[4479:4472];
        layer2[46][7:0] = buffer_data_0[4463:4456];
        layer2[46][15:8] = buffer_data_0[4471:4464];
        layer2[46][23:16] = buffer_data_0[4479:4472];
        layer0[47][7:0] = buffer_data_2[4471:4464];
        layer0[47][15:8] = buffer_data_2[4479:4472];
        layer0[47][23:16] = buffer_data_2[4487:4480];
        layer1[47][7:0] = buffer_data_1[4471:4464];
        layer1[47][15:8] = buffer_data_1[4479:4472];
        layer1[47][23:16] = buffer_data_1[4487:4480];
        layer2[47][7:0] = buffer_data_0[4471:4464];
        layer2[47][15:8] = buffer_data_0[4479:4472];
        layer2[47][23:16] = buffer_data_0[4487:4480];
        layer0[48][7:0] = buffer_data_2[4479:4472];
        layer0[48][15:8] = buffer_data_2[4487:4480];
        layer0[48][23:16] = buffer_data_2[4495:4488];
        layer1[48][7:0] = buffer_data_1[4479:4472];
        layer1[48][15:8] = buffer_data_1[4487:4480];
        layer1[48][23:16] = buffer_data_1[4495:4488];
        layer2[48][7:0] = buffer_data_0[4479:4472];
        layer2[48][15:8] = buffer_data_0[4487:4480];
        layer2[48][23:16] = buffer_data_0[4495:4488];
        layer0[49][7:0] = buffer_data_2[4487:4480];
        layer0[49][15:8] = buffer_data_2[4495:4488];
        layer0[49][23:16] = buffer_data_2[4503:4496];
        layer1[49][7:0] = buffer_data_1[4487:4480];
        layer1[49][15:8] = buffer_data_1[4495:4488];
        layer1[49][23:16] = buffer_data_1[4503:4496];
        layer2[49][7:0] = buffer_data_0[4487:4480];
        layer2[49][15:8] = buffer_data_0[4495:4488];
        layer2[49][23:16] = buffer_data_0[4503:4496];
        layer0[50][7:0] = buffer_data_2[4495:4488];
        layer0[50][15:8] = buffer_data_2[4503:4496];
        layer0[50][23:16] = buffer_data_2[4511:4504];
        layer1[50][7:0] = buffer_data_1[4495:4488];
        layer1[50][15:8] = buffer_data_1[4503:4496];
        layer1[50][23:16] = buffer_data_1[4511:4504];
        layer2[50][7:0] = buffer_data_0[4495:4488];
        layer2[50][15:8] = buffer_data_0[4503:4496];
        layer2[50][23:16] = buffer_data_0[4511:4504];
        layer0[51][7:0] = buffer_data_2[4503:4496];
        layer0[51][15:8] = buffer_data_2[4511:4504];
        layer0[51][23:16] = buffer_data_2[4519:4512];
        layer1[51][7:0] = buffer_data_1[4503:4496];
        layer1[51][15:8] = buffer_data_1[4511:4504];
        layer1[51][23:16] = buffer_data_1[4519:4512];
        layer2[51][7:0] = buffer_data_0[4503:4496];
        layer2[51][15:8] = buffer_data_0[4511:4504];
        layer2[51][23:16] = buffer_data_0[4519:4512];
        layer0[52][7:0] = buffer_data_2[4511:4504];
        layer0[52][15:8] = buffer_data_2[4519:4512];
        layer0[52][23:16] = buffer_data_2[4527:4520];
        layer1[52][7:0] = buffer_data_1[4511:4504];
        layer1[52][15:8] = buffer_data_1[4519:4512];
        layer1[52][23:16] = buffer_data_1[4527:4520];
        layer2[52][7:0] = buffer_data_0[4511:4504];
        layer2[52][15:8] = buffer_data_0[4519:4512];
        layer2[52][23:16] = buffer_data_0[4527:4520];
        layer0[53][7:0] = buffer_data_2[4519:4512];
        layer0[53][15:8] = buffer_data_2[4527:4520];
        layer0[53][23:16] = buffer_data_2[4535:4528];
        layer1[53][7:0] = buffer_data_1[4519:4512];
        layer1[53][15:8] = buffer_data_1[4527:4520];
        layer1[53][23:16] = buffer_data_1[4535:4528];
        layer2[53][7:0] = buffer_data_0[4519:4512];
        layer2[53][15:8] = buffer_data_0[4527:4520];
        layer2[53][23:16] = buffer_data_0[4535:4528];
        layer0[54][7:0] = buffer_data_2[4527:4520];
        layer0[54][15:8] = buffer_data_2[4535:4528];
        layer0[54][23:16] = buffer_data_2[4543:4536];
        layer1[54][7:0] = buffer_data_1[4527:4520];
        layer1[54][15:8] = buffer_data_1[4535:4528];
        layer1[54][23:16] = buffer_data_1[4543:4536];
        layer2[54][7:0] = buffer_data_0[4527:4520];
        layer2[54][15:8] = buffer_data_0[4535:4528];
        layer2[54][23:16] = buffer_data_0[4543:4536];
        layer0[55][7:0] = buffer_data_2[4535:4528];
        layer0[55][15:8] = buffer_data_2[4543:4536];
        layer0[55][23:16] = buffer_data_2[4551:4544];
        layer1[55][7:0] = buffer_data_1[4535:4528];
        layer1[55][15:8] = buffer_data_1[4543:4536];
        layer1[55][23:16] = buffer_data_1[4551:4544];
        layer2[55][7:0] = buffer_data_0[4535:4528];
        layer2[55][15:8] = buffer_data_0[4543:4536];
        layer2[55][23:16] = buffer_data_0[4551:4544];
        layer0[56][7:0] = buffer_data_2[4543:4536];
        layer0[56][15:8] = buffer_data_2[4551:4544];
        layer0[56][23:16] = buffer_data_2[4559:4552];
        layer1[56][7:0] = buffer_data_1[4543:4536];
        layer1[56][15:8] = buffer_data_1[4551:4544];
        layer1[56][23:16] = buffer_data_1[4559:4552];
        layer2[56][7:0] = buffer_data_0[4543:4536];
        layer2[56][15:8] = buffer_data_0[4551:4544];
        layer2[56][23:16] = buffer_data_0[4559:4552];
        layer0[57][7:0] = buffer_data_2[4551:4544];
        layer0[57][15:8] = buffer_data_2[4559:4552];
        layer0[57][23:16] = buffer_data_2[4567:4560];
        layer1[57][7:0] = buffer_data_1[4551:4544];
        layer1[57][15:8] = buffer_data_1[4559:4552];
        layer1[57][23:16] = buffer_data_1[4567:4560];
        layer2[57][7:0] = buffer_data_0[4551:4544];
        layer2[57][15:8] = buffer_data_0[4559:4552];
        layer2[57][23:16] = buffer_data_0[4567:4560];
        layer0[58][7:0] = buffer_data_2[4559:4552];
        layer0[58][15:8] = buffer_data_2[4567:4560];
        layer0[58][23:16] = buffer_data_2[4575:4568];
        layer1[58][7:0] = buffer_data_1[4559:4552];
        layer1[58][15:8] = buffer_data_1[4567:4560];
        layer1[58][23:16] = buffer_data_1[4575:4568];
        layer2[58][7:0] = buffer_data_0[4559:4552];
        layer2[58][15:8] = buffer_data_0[4567:4560];
        layer2[58][23:16] = buffer_data_0[4575:4568];
        layer0[59][7:0] = buffer_data_2[4567:4560];
        layer0[59][15:8] = buffer_data_2[4575:4568];
        layer0[59][23:16] = buffer_data_2[4583:4576];
        layer1[59][7:0] = buffer_data_1[4567:4560];
        layer1[59][15:8] = buffer_data_1[4575:4568];
        layer1[59][23:16] = buffer_data_1[4583:4576];
        layer2[59][7:0] = buffer_data_0[4567:4560];
        layer2[59][15:8] = buffer_data_0[4575:4568];
        layer2[59][23:16] = buffer_data_0[4583:4576];
        layer0[60][7:0] = buffer_data_2[4575:4568];
        layer0[60][15:8] = buffer_data_2[4583:4576];
        layer0[60][23:16] = buffer_data_2[4591:4584];
        layer1[60][7:0] = buffer_data_1[4575:4568];
        layer1[60][15:8] = buffer_data_1[4583:4576];
        layer1[60][23:16] = buffer_data_1[4591:4584];
        layer2[60][7:0] = buffer_data_0[4575:4568];
        layer2[60][15:8] = buffer_data_0[4583:4576];
        layer2[60][23:16] = buffer_data_0[4591:4584];
        layer0[61][7:0] = buffer_data_2[4583:4576];
        layer0[61][15:8] = buffer_data_2[4591:4584];
        layer0[61][23:16] = buffer_data_2[4599:4592];
        layer1[61][7:0] = buffer_data_1[4583:4576];
        layer1[61][15:8] = buffer_data_1[4591:4584];
        layer1[61][23:16] = buffer_data_1[4599:4592];
        layer2[61][7:0] = buffer_data_0[4583:4576];
        layer2[61][15:8] = buffer_data_0[4591:4584];
        layer2[61][23:16] = buffer_data_0[4599:4592];
        layer0[62][7:0] = buffer_data_2[4591:4584];
        layer0[62][15:8] = buffer_data_2[4599:4592];
        layer0[62][23:16] = buffer_data_2[4607:4600];
        layer1[62][7:0] = buffer_data_1[4591:4584];
        layer1[62][15:8] = buffer_data_1[4599:4592];
        layer1[62][23:16] = buffer_data_1[4607:4600];
        layer2[62][7:0] = buffer_data_0[4591:4584];
        layer2[62][15:8] = buffer_data_0[4599:4592];
        layer2[62][23:16] = buffer_data_0[4607:4600];
        layer0[63][7:0] = buffer_data_2[4599:4592];
        layer0[63][15:8] = buffer_data_2[4607:4600];
        layer0[63][23:16] = buffer_data_2[4615:4608];
        layer1[63][7:0] = buffer_data_1[4599:4592];
        layer1[63][15:8] = buffer_data_1[4607:4600];
        layer1[63][23:16] = buffer_data_1[4615:4608];
        layer2[63][7:0] = buffer_data_0[4599:4592];
        layer2[63][15:8] = buffer_data_0[4607:4600];
        layer2[63][23:16] = buffer_data_0[4615:4608];
    end
    ST_GAUSSIAN_9: begin
        layer0[0][7:0] = buffer_data_2[4607:4600];
        layer0[0][15:8] = buffer_data_2[4615:4608];
        layer0[0][23:16] = buffer_data_2[4623:4616];
        layer1[0][7:0] = buffer_data_1[4607:4600];
        layer1[0][15:8] = buffer_data_1[4615:4608];
        layer1[0][23:16] = buffer_data_1[4623:4616];
        layer2[0][7:0] = buffer_data_0[4607:4600];
        layer2[0][15:8] = buffer_data_0[4615:4608];
        layer2[0][23:16] = buffer_data_0[4623:4616];
        layer0[1][7:0] = buffer_data_2[4615:4608];
        layer0[1][15:8] = buffer_data_2[4623:4616];
        layer0[1][23:16] = buffer_data_2[4631:4624];
        layer1[1][7:0] = buffer_data_1[4615:4608];
        layer1[1][15:8] = buffer_data_1[4623:4616];
        layer1[1][23:16] = buffer_data_1[4631:4624];
        layer2[1][7:0] = buffer_data_0[4615:4608];
        layer2[1][15:8] = buffer_data_0[4623:4616];
        layer2[1][23:16] = buffer_data_0[4631:4624];
        layer0[2][7:0] = buffer_data_2[4623:4616];
        layer0[2][15:8] = buffer_data_2[4631:4624];
        layer0[2][23:16] = buffer_data_2[4639:4632];
        layer1[2][7:0] = buffer_data_1[4623:4616];
        layer1[2][15:8] = buffer_data_1[4631:4624];
        layer1[2][23:16] = buffer_data_1[4639:4632];
        layer2[2][7:0] = buffer_data_0[4623:4616];
        layer2[2][15:8] = buffer_data_0[4631:4624];
        layer2[2][23:16] = buffer_data_0[4639:4632];
        layer0[3][7:0] = buffer_data_2[4631:4624];
        layer0[3][15:8] = buffer_data_2[4639:4632];
        layer0[3][23:16] = buffer_data_2[4647:4640];
        layer1[3][7:0] = buffer_data_1[4631:4624];
        layer1[3][15:8] = buffer_data_1[4639:4632];
        layer1[3][23:16] = buffer_data_1[4647:4640];
        layer2[3][7:0] = buffer_data_0[4631:4624];
        layer2[3][15:8] = buffer_data_0[4639:4632];
        layer2[3][23:16] = buffer_data_0[4647:4640];
        layer0[4][7:0] = buffer_data_2[4639:4632];
        layer0[4][15:8] = buffer_data_2[4647:4640];
        layer0[4][23:16] = buffer_data_2[4655:4648];
        layer1[4][7:0] = buffer_data_1[4639:4632];
        layer1[4][15:8] = buffer_data_1[4647:4640];
        layer1[4][23:16] = buffer_data_1[4655:4648];
        layer2[4][7:0] = buffer_data_0[4639:4632];
        layer2[4][15:8] = buffer_data_0[4647:4640];
        layer2[4][23:16] = buffer_data_0[4655:4648];
        layer0[5][7:0] = buffer_data_2[4647:4640];
        layer0[5][15:8] = buffer_data_2[4655:4648];
        layer0[5][23:16] = buffer_data_2[4663:4656];
        layer1[5][7:0] = buffer_data_1[4647:4640];
        layer1[5][15:8] = buffer_data_1[4655:4648];
        layer1[5][23:16] = buffer_data_1[4663:4656];
        layer2[5][7:0] = buffer_data_0[4647:4640];
        layer2[5][15:8] = buffer_data_0[4655:4648];
        layer2[5][23:16] = buffer_data_0[4663:4656];
        layer0[6][7:0] = buffer_data_2[4655:4648];
        layer0[6][15:8] = buffer_data_2[4663:4656];
        layer0[6][23:16] = buffer_data_2[4671:4664];
        layer1[6][7:0] = buffer_data_1[4655:4648];
        layer1[6][15:8] = buffer_data_1[4663:4656];
        layer1[6][23:16] = buffer_data_1[4671:4664];
        layer2[6][7:0] = buffer_data_0[4655:4648];
        layer2[6][15:8] = buffer_data_0[4663:4656];
        layer2[6][23:16] = buffer_data_0[4671:4664];
        layer0[7][7:0] = buffer_data_2[4663:4656];
        layer0[7][15:8] = buffer_data_2[4671:4664];
        layer0[7][23:16] = buffer_data_2[4679:4672];
        layer1[7][7:0] = buffer_data_1[4663:4656];
        layer1[7][15:8] = buffer_data_1[4671:4664];
        layer1[7][23:16] = buffer_data_1[4679:4672];
        layer2[7][7:0] = buffer_data_0[4663:4656];
        layer2[7][15:8] = buffer_data_0[4671:4664];
        layer2[7][23:16] = buffer_data_0[4679:4672];
        layer0[8][7:0] = buffer_data_2[4671:4664];
        layer0[8][15:8] = buffer_data_2[4679:4672];
        layer0[8][23:16] = buffer_data_2[4687:4680];
        layer1[8][7:0] = buffer_data_1[4671:4664];
        layer1[8][15:8] = buffer_data_1[4679:4672];
        layer1[8][23:16] = buffer_data_1[4687:4680];
        layer2[8][7:0] = buffer_data_0[4671:4664];
        layer2[8][15:8] = buffer_data_0[4679:4672];
        layer2[8][23:16] = buffer_data_0[4687:4680];
        layer0[9][7:0] = buffer_data_2[4679:4672];
        layer0[9][15:8] = buffer_data_2[4687:4680];
        layer0[9][23:16] = buffer_data_2[4695:4688];
        layer1[9][7:0] = buffer_data_1[4679:4672];
        layer1[9][15:8] = buffer_data_1[4687:4680];
        layer1[9][23:16] = buffer_data_1[4695:4688];
        layer2[9][7:0] = buffer_data_0[4679:4672];
        layer2[9][15:8] = buffer_data_0[4687:4680];
        layer2[9][23:16] = buffer_data_0[4695:4688];
        layer0[10][7:0] = buffer_data_2[4687:4680];
        layer0[10][15:8] = buffer_data_2[4695:4688];
        layer0[10][23:16] = buffer_data_2[4703:4696];
        layer1[10][7:0] = buffer_data_1[4687:4680];
        layer1[10][15:8] = buffer_data_1[4695:4688];
        layer1[10][23:16] = buffer_data_1[4703:4696];
        layer2[10][7:0] = buffer_data_0[4687:4680];
        layer2[10][15:8] = buffer_data_0[4695:4688];
        layer2[10][23:16] = buffer_data_0[4703:4696];
        layer0[11][7:0] = buffer_data_2[4695:4688];
        layer0[11][15:8] = buffer_data_2[4703:4696];
        layer0[11][23:16] = buffer_data_2[4711:4704];
        layer1[11][7:0] = buffer_data_1[4695:4688];
        layer1[11][15:8] = buffer_data_1[4703:4696];
        layer1[11][23:16] = buffer_data_1[4711:4704];
        layer2[11][7:0] = buffer_data_0[4695:4688];
        layer2[11][15:8] = buffer_data_0[4703:4696];
        layer2[11][23:16] = buffer_data_0[4711:4704];
        layer0[12][7:0] = buffer_data_2[4703:4696];
        layer0[12][15:8] = buffer_data_2[4711:4704];
        layer0[12][23:16] = buffer_data_2[4719:4712];
        layer1[12][7:0] = buffer_data_1[4703:4696];
        layer1[12][15:8] = buffer_data_1[4711:4704];
        layer1[12][23:16] = buffer_data_1[4719:4712];
        layer2[12][7:0] = buffer_data_0[4703:4696];
        layer2[12][15:8] = buffer_data_0[4711:4704];
        layer2[12][23:16] = buffer_data_0[4719:4712];
        layer0[13][7:0] = buffer_data_2[4711:4704];
        layer0[13][15:8] = buffer_data_2[4719:4712];
        layer0[13][23:16] = buffer_data_2[4727:4720];
        layer1[13][7:0] = buffer_data_1[4711:4704];
        layer1[13][15:8] = buffer_data_1[4719:4712];
        layer1[13][23:16] = buffer_data_1[4727:4720];
        layer2[13][7:0] = buffer_data_0[4711:4704];
        layer2[13][15:8] = buffer_data_0[4719:4712];
        layer2[13][23:16] = buffer_data_0[4727:4720];
        layer0[14][7:0] = buffer_data_2[4719:4712];
        layer0[14][15:8] = buffer_data_2[4727:4720];
        layer0[14][23:16] = buffer_data_2[4735:4728];
        layer1[14][7:0] = buffer_data_1[4719:4712];
        layer1[14][15:8] = buffer_data_1[4727:4720];
        layer1[14][23:16] = buffer_data_1[4735:4728];
        layer2[14][7:0] = buffer_data_0[4719:4712];
        layer2[14][15:8] = buffer_data_0[4727:4720];
        layer2[14][23:16] = buffer_data_0[4735:4728];
        layer0[15][7:0] = buffer_data_2[4727:4720];
        layer0[15][15:8] = buffer_data_2[4735:4728];
        layer0[15][23:16] = buffer_data_2[4743:4736];
        layer1[15][7:0] = buffer_data_1[4727:4720];
        layer1[15][15:8] = buffer_data_1[4735:4728];
        layer1[15][23:16] = buffer_data_1[4743:4736];
        layer2[15][7:0] = buffer_data_0[4727:4720];
        layer2[15][15:8] = buffer_data_0[4735:4728];
        layer2[15][23:16] = buffer_data_0[4743:4736];
        layer0[16][7:0] = buffer_data_2[4735:4728];
        layer0[16][15:8] = buffer_data_2[4743:4736];
        layer0[16][23:16] = buffer_data_2[4751:4744];
        layer1[16][7:0] = buffer_data_1[4735:4728];
        layer1[16][15:8] = buffer_data_1[4743:4736];
        layer1[16][23:16] = buffer_data_1[4751:4744];
        layer2[16][7:0] = buffer_data_0[4735:4728];
        layer2[16][15:8] = buffer_data_0[4743:4736];
        layer2[16][23:16] = buffer_data_0[4751:4744];
        layer0[17][7:0] = buffer_data_2[4743:4736];
        layer0[17][15:8] = buffer_data_2[4751:4744];
        layer0[17][23:16] = buffer_data_2[4759:4752];
        layer1[17][7:0] = buffer_data_1[4743:4736];
        layer1[17][15:8] = buffer_data_1[4751:4744];
        layer1[17][23:16] = buffer_data_1[4759:4752];
        layer2[17][7:0] = buffer_data_0[4743:4736];
        layer2[17][15:8] = buffer_data_0[4751:4744];
        layer2[17][23:16] = buffer_data_0[4759:4752];
        layer0[18][7:0] = buffer_data_2[4751:4744];
        layer0[18][15:8] = buffer_data_2[4759:4752];
        layer0[18][23:16] = buffer_data_2[4767:4760];
        layer1[18][7:0] = buffer_data_1[4751:4744];
        layer1[18][15:8] = buffer_data_1[4759:4752];
        layer1[18][23:16] = buffer_data_1[4767:4760];
        layer2[18][7:0] = buffer_data_0[4751:4744];
        layer2[18][15:8] = buffer_data_0[4759:4752];
        layer2[18][23:16] = buffer_data_0[4767:4760];
        layer0[19][7:0] = buffer_data_2[4759:4752];
        layer0[19][15:8] = buffer_data_2[4767:4760];
        layer0[19][23:16] = buffer_data_2[4775:4768];
        layer1[19][7:0] = buffer_data_1[4759:4752];
        layer1[19][15:8] = buffer_data_1[4767:4760];
        layer1[19][23:16] = buffer_data_1[4775:4768];
        layer2[19][7:0] = buffer_data_0[4759:4752];
        layer2[19][15:8] = buffer_data_0[4767:4760];
        layer2[19][23:16] = buffer_data_0[4775:4768];
        layer0[20][7:0] = buffer_data_2[4767:4760];
        layer0[20][15:8] = buffer_data_2[4775:4768];
        layer0[20][23:16] = buffer_data_2[4783:4776];
        layer1[20][7:0] = buffer_data_1[4767:4760];
        layer1[20][15:8] = buffer_data_1[4775:4768];
        layer1[20][23:16] = buffer_data_1[4783:4776];
        layer2[20][7:0] = buffer_data_0[4767:4760];
        layer2[20][15:8] = buffer_data_0[4775:4768];
        layer2[20][23:16] = buffer_data_0[4783:4776];
        layer0[21][7:0] = buffer_data_2[4775:4768];
        layer0[21][15:8] = buffer_data_2[4783:4776];
        layer0[21][23:16] = buffer_data_2[4791:4784];
        layer1[21][7:0] = buffer_data_1[4775:4768];
        layer1[21][15:8] = buffer_data_1[4783:4776];
        layer1[21][23:16] = buffer_data_1[4791:4784];
        layer2[21][7:0] = buffer_data_0[4775:4768];
        layer2[21][15:8] = buffer_data_0[4783:4776];
        layer2[21][23:16] = buffer_data_0[4791:4784];
        layer0[22][7:0] = buffer_data_2[4783:4776];
        layer0[22][15:8] = buffer_data_2[4791:4784];
        layer0[22][23:16] = buffer_data_2[4799:4792];
        layer1[22][7:0] = buffer_data_1[4783:4776];
        layer1[22][15:8] = buffer_data_1[4791:4784];
        layer1[22][23:16] = buffer_data_1[4799:4792];
        layer2[22][7:0] = buffer_data_0[4783:4776];
        layer2[22][15:8] = buffer_data_0[4791:4784];
        layer2[22][23:16] = buffer_data_0[4799:4792];
        layer0[23][7:0] = buffer_data_2[4791:4784];
        layer0[23][15:8] = buffer_data_2[4799:4792];
        layer0[23][23:16] = buffer_data_2[4807:4800];
        layer1[23][7:0] = buffer_data_1[4791:4784];
        layer1[23][15:8] = buffer_data_1[4799:4792];
        layer1[23][23:16] = buffer_data_1[4807:4800];
        layer2[23][7:0] = buffer_data_0[4791:4784];
        layer2[23][15:8] = buffer_data_0[4799:4792];
        layer2[23][23:16] = buffer_data_0[4807:4800];
        layer0[24][7:0] = buffer_data_2[4799:4792];
        layer0[24][15:8] = buffer_data_2[4807:4800];
        layer0[24][23:16] = buffer_data_2[4815:4808];
        layer1[24][7:0] = buffer_data_1[4799:4792];
        layer1[24][15:8] = buffer_data_1[4807:4800];
        layer1[24][23:16] = buffer_data_1[4815:4808];
        layer2[24][7:0] = buffer_data_0[4799:4792];
        layer2[24][15:8] = buffer_data_0[4807:4800];
        layer2[24][23:16] = buffer_data_0[4815:4808];
        layer0[25][7:0] = buffer_data_2[4807:4800];
        layer0[25][15:8] = buffer_data_2[4815:4808];
        layer0[25][23:16] = buffer_data_2[4823:4816];
        layer1[25][7:0] = buffer_data_1[4807:4800];
        layer1[25][15:8] = buffer_data_1[4815:4808];
        layer1[25][23:16] = buffer_data_1[4823:4816];
        layer2[25][7:0] = buffer_data_0[4807:4800];
        layer2[25][15:8] = buffer_data_0[4815:4808];
        layer2[25][23:16] = buffer_data_0[4823:4816];
        layer0[26][7:0] = buffer_data_2[4815:4808];
        layer0[26][15:8] = buffer_data_2[4823:4816];
        layer0[26][23:16] = buffer_data_2[4831:4824];
        layer1[26][7:0] = buffer_data_1[4815:4808];
        layer1[26][15:8] = buffer_data_1[4823:4816];
        layer1[26][23:16] = buffer_data_1[4831:4824];
        layer2[26][7:0] = buffer_data_0[4815:4808];
        layer2[26][15:8] = buffer_data_0[4823:4816];
        layer2[26][23:16] = buffer_data_0[4831:4824];
        layer0[27][7:0] = buffer_data_2[4823:4816];
        layer0[27][15:8] = buffer_data_2[4831:4824];
        layer0[27][23:16] = buffer_data_2[4839:4832];
        layer1[27][7:0] = buffer_data_1[4823:4816];
        layer1[27][15:8] = buffer_data_1[4831:4824];
        layer1[27][23:16] = buffer_data_1[4839:4832];
        layer2[27][7:0] = buffer_data_0[4823:4816];
        layer2[27][15:8] = buffer_data_0[4831:4824];
        layer2[27][23:16] = buffer_data_0[4839:4832];
        layer0[28][7:0] = buffer_data_2[4831:4824];
        layer0[28][15:8] = buffer_data_2[4839:4832];
        layer0[28][23:16] = buffer_data_2[4847:4840];
        layer1[28][7:0] = buffer_data_1[4831:4824];
        layer1[28][15:8] = buffer_data_1[4839:4832];
        layer1[28][23:16] = buffer_data_1[4847:4840];
        layer2[28][7:0] = buffer_data_0[4831:4824];
        layer2[28][15:8] = buffer_data_0[4839:4832];
        layer2[28][23:16] = buffer_data_0[4847:4840];
        layer0[29][7:0] = buffer_data_2[4839:4832];
        layer0[29][15:8] = buffer_data_2[4847:4840];
        layer0[29][23:16] = buffer_data_2[4855:4848];
        layer1[29][7:0] = buffer_data_1[4839:4832];
        layer1[29][15:8] = buffer_data_1[4847:4840];
        layer1[29][23:16] = buffer_data_1[4855:4848];
        layer2[29][7:0] = buffer_data_0[4839:4832];
        layer2[29][15:8] = buffer_data_0[4847:4840];
        layer2[29][23:16] = buffer_data_0[4855:4848];
        layer0[30][7:0] = buffer_data_2[4847:4840];
        layer0[30][15:8] = buffer_data_2[4855:4848];
        layer0[30][23:16] = buffer_data_2[4863:4856];
        layer1[30][7:0] = buffer_data_1[4847:4840];
        layer1[30][15:8] = buffer_data_1[4855:4848];
        layer1[30][23:16] = buffer_data_1[4863:4856];
        layer2[30][7:0] = buffer_data_0[4847:4840];
        layer2[30][15:8] = buffer_data_0[4855:4848];
        layer2[30][23:16] = buffer_data_0[4863:4856];
        layer0[31][7:0] = buffer_data_2[4855:4848];
        layer0[31][15:8] = buffer_data_2[4863:4856];
        layer0[31][23:16] = buffer_data_2[4871:4864];
        layer1[31][7:0] = buffer_data_1[4855:4848];
        layer1[31][15:8] = buffer_data_1[4863:4856];
        layer1[31][23:16] = buffer_data_1[4871:4864];
        layer2[31][7:0] = buffer_data_0[4855:4848];
        layer2[31][15:8] = buffer_data_0[4863:4856];
        layer2[31][23:16] = buffer_data_0[4871:4864];
        layer0[32][7:0] = buffer_data_2[4863:4856];
        layer0[32][15:8] = buffer_data_2[4871:4864];
        layer0[32][23:16] = buffer_data_2[4879:4872];
        layer1[32][7:0] = buffer_data_1[4863:4856];
        layer1[32][15:8] = buffer_data_1[4871:4864];
        layer1[32][23:16] = buffer_data_1[4879:4872];
        layer2[32][7:0] = buffer_data_0[4863:4856];
        layer2[32][15:8] = buffer_data_0[4871:4864];
        layer2[32][23:16] = buffer_data_0[4879:4872];
        layer0[33][7:0] = buffer_data_2[4871:4864];
        layer0[33][15:8] = buffer_data_2[4879:4872];
        layer0[33][23:16] = buffer_data_2[4887:4880];
        layer1[33][7:0] = buffer_data_1[4871:4864];
        layer1[33][15:8] = buffer_data_1[4879:4872];
        layer1[33][23:16] = buffer_data_1[4887:4880];
        layer2[33][7:0] = buffer_data_0[4871:4864];
        layer2[33][15:8] = buffer_data_0[4879:4872];
        layer2[33][23:16] = buffer_data_0[4887:4880];
        layer0[34][7:0] = buffer_data_2[4879:4872];
        layer0[34][15:8] = buffer_data_2[4887:4880];
        layer0[34][23:16] = buffer_data_2[4895:4888];
        layer1[34][7:0] = buffer_data_1[4879:4872];
        layer1[34][15:8] = buffer_data_1[4887:4880];
        layer1[34][23:16] = buffer_data_1[4895:4888];
        layer2[34][7:0] = buffer_data_0[4879:4872];
        layer2[34][15:8] = buffer_data_0[4887:4880];
        layer2[34][23:16] = buffer_data_0[4895:4888];
        layer0[35][7:0] = buffer_data_2[4887:4880];
        layer0[35][15:8] = buffer_data_2[4895:4888];
        layer0[35][23:16] = buffer_data_2[4903:4896];
        layer1[35][7:0] = buffer_data_1[4887:4880];
        layer1[35][15:8] = buffer_data_1[4895:4888];
        layer1[35][23:16] = buffer_data_1[4903:4896];
        layer2[35][7:0] = buffer_data_0[4887:4880];
        layer2[35][15:8] = buffer_data_0[4895:4888];
        layer2[35][23:16] = buffer_data_0[4903:4896];
        layer0[36][7:0] = buffer_data_2[4895:4888];
        layer0[36][15:8] = buffer_data_2[4903:4896];
        layer0[36][23:16] = buffer_data_2[4911:4904];
        layer1[36][7:0] = buffer_data_1[4895:4888];
        layer1[36][15:8] = buffer_data_1[4903:4896];
        layer1[36][23:16] = buffer_data_1[4911:4904];
        layer2[36][7:0] = buffer_data_0[4895:4888];
        layer2[36][15:8] = buffer_data_0[4903:4896];
        layer2[36][23:16] = buffer_data_0[4911:4904];
        layer0[37][7:0] = buffer_data_2[4903:4896];
        layer0[37][15:8] = buffer_data_2[4911:4904];
        layer0[37][23:16] = buffer_data_2[4919:4912];
        layer1[37][7:0] = buffer_data_1[4903:4896];
        layer1[37][15:8] = buffer_data_1[4911:4904];
        layer1[37][23:16] = buffer_data_1[4919:4912];
        layer2[37][7:0] = buffer_data_0[4903:4896];
        layer2[37][15:8] = buffer_data_0[4911:4904];
        layer2[37][23:16] = buffer_data_0[4919:4912];
        layer0[38][7:0] = buffer_data_2[4911:4904];
        layer0[38][15:8] = buffer_data_2[4919:4912];
        layer0[38][23:16] = buffer_data_2[4927:4920];
        layer1[38][7:0] = buffer_data_1[4911:4904];
        layer1[38][15:8] = buffer_data_1[4919:4912];
        layer1[38][23:16] = buffer_data_1[4927:4920];
        layer2[38][7:0] = buffer_data_0[4911:4904];
        layer2[38][15:8] = buffer_data_0[4919:4912];
        layer2[38][23:16] = buffer_data_0[4927:4920];
        layer0[39][7:0] = buffer_data_2[4919:4912];
        layer0[39][15:8] = buffer_data_2[4927:4920];
        layer0[39][23:16] = buffer_data_2[4935:4928];
        layer1[39][7:0] = buffer_data_1[4919:4912];
        layer1[39][15:8] = buffer_data_1[4927:4920];
        layer1[39][23:16] = buffer_data_1[4935:4928];
        layer2[39][7:0] = buffer_data_0[4919:4912];
        layer2[39][15:8] = buffer_data_0[4927:4920];
        layer2[39][23:16] = buffer_data_0[4935:4928];
        layer0[40][7:0] = buffer_data_2[4927:4920];
        layer0[40][15:8] = buffer_data_2[4935:4928];
        layer0[40][23:16] = buffer_data_2[4943:4936];
        layer1[40][7:0] = buffer_data_1[4927:4920];
        layer1[40][15:8] = buffer_data_1[4935:4928];
        layer1[40][23:16] = buffer_data_1[4943:4936];
        layer2[40][7:0] = buffer_data_0[4927:4920];
        layer2[40][15:8] = buffer_data_0[4935:4928];
        layer2[40][23:16] = buffer_data_0[4943:4936];
        layer0[41][7:0] = buffer_data_2[4935:4928];
        layer0[41][15:8] = buffer_data_2[4943:4936];
        layer0[41][23:16] = buffer_data_2[4951:4944];
        layer1[41][7:0] = buffer_data_1[4935:4928];
        layer1[41][15:8] = buffer_data_1[4943:4936];
        layer1[41][23:16] = buffer_data_1[4951:4944];
        layer2[41][7:0] = buffer_data_0[4935:4928];
        layer2[41][15:8] = buffer_data_0[4943:4936];
        layer2[41][23:16] = buffer_data_0[4951:4944];
        layer0[42][7:0] = buffer_data_2[4943:4936];
        layer0[42][15:8] = buffer_data_2[4951:4944];
        layer0[42][23:16] = buffer_data_2[4959:4952];
        layer1[42][7:0] = buffer_data_1[4943:4936];
        layer1[42][15:8] = buffer_data_1[4951:4944];
        layer1[42][23:16] = buffer_data_1[4959:4952];
        layer2[42][7:0] = buffer_data_0[4943:4936];
        layer2[42][15:8] = buffer_data_0[4951:4944];
        layer2[42][23:16] = buffer_data_0[4959:4952];
        layer0[43][7:0] = buffer_data_2[4951:4944];
        layer0[43][15:8] = buffer_data_2[4959:4952];
        layer0[43][23:16] = buffer_data_2[4967:4960];
        layer1[43][7:0] = buffer_data_1[4951:4944];
        layer1[43][15:8] = buffer_data_1[4959:4952];
        layer1[43][23:16] = buffer_data_1[4967:4960];
        layer2[43][7:0] = buffer_data_0[4951:4944];
        layer2[43][15:8] = buffer_data_0[4959:4952];
        layer2[43][23:16] = buffer_data_0[4967:4960];
        layer0[44][7:0] = buffer_data_2[4959:4952];
        layer0[44][15:8] = buffer_data_2[4967:4960];
        layer0[44][23:16] = buffer_data_2[4975:4968];
        layer1[44][7:0] = buffer_data_1[4959:4952];
        layer1[44][15:8] = buffer_data_1[4967:4960];
        layer1[44][23:16] = buffer_data_1[4975:4968];
        layer2[44][7:0] = buffer_data_0[4959:4952];
        layer2[44][15:8] = buffer_data_0[4967:4960];
        layer2[44][23:16] = buffer_data_0[4975:4968];
        layer0[45][7:0] = buffer_data_2[4967:4960];
        layer0[45][15:8] = buffer_data_2[4975:4968];
        layer0[45][23:16] = buffer_data_2[4983:4976];
        layer1[45][7:0] = buffer_data_1[4967:4960];
        layer1[45][15:8] = buffer_data_1[4975:4968];
        layer1[45][23:16] = buffer_data_1[4983:4976];
        layer2[45][7:0] = buffer_data_0[4967:4960];
        layer2[45][15:8] = buffer_data_0[4975:4968];
        layer2[45][23:16] = buffer_data_0[4983:4976];
        layer0[46][7:0] = buffer_data_2[4975:4968];
        layer0[46][15:8] = buffer_data_2[4983:4976];
        layer0[46][23:16] = buffer_data_2[4991:4984];
        layer1[46][7:0] = buffer_data_1[4975:4968];
        layer1[46][15:8] = buffer_data_1[4983:4976];
        layer1[46][23:16] = buffer_data_1[4991:4984];
        layer2[46][7:0] = buffer_data_0[4975:4968];
        layer2[46][15:8] = buffer_data_0[4983:4976];
        layer2[46][23:16] = buffer_data_0[4991:4984];
        layer0[47][7:0] = buffer_data_2[4983:4976];
        layer0[47][15:8] = buffer_data_2[4991:4984];
        layer0[47][23:16] = buffer_data_2[4999:4992];
        layer1[47][7:0] = buffer_data_1[4983:4976];
        layer1[47][15:8] = buffer_data_1[4991:4984];
        layer1[47][23:16] = buffer_data_1[4999:4992];
        layer2[47][7:0] = buffer_data_0[4983:4976];
        layer2[47][15:8] = buffer_data_0[4991:4984];
        layer2[47][23:16] = buffer_data_0[4999:4992];
        layer0[48][7:0] = buffer_data_2[4991:4984];
        layer0[48][15:8] = buffer_data_2[4999:4992];
        layer0[48][23:16] = buffer_data_2[5007:5000];
        layer1[48][7:0] = buffer_data_1[4991:4984];
        layer1[48][15:8] = buffer_data_1[4999:4992];
        layer1[48][23:16] = buffer_data_1[5007:5000];
        layer2[48][7:0] = buffer_data_0[4991:4984];
        layer2[48][15:8] = buffer_data_0[4999:4992];
        layer2[48][23:16] = buffer_data_0[5007:5000];
        layer0[49][7:0] = buffer_data_2[4999:4992];
        layer0[49][15:8] = buffer_data_2[5007:5000];
        layer0[49][23:16] = buffer_data_2[5015:5008];
        layer1[49][7:0] = buffer_data_1[4999:4992];
        layer1[49][15:8] = buffer_data_1[5007:5000];
        layer1[49][23:16] = buffer_data_1[5015:5008];
        layer2[49][7:0] = buffer_data_0[4999:4992];
        layer2[49][15:8] = buffer_data_0[5007:5000];
        layer2[49][23:16] = buffer_data_0[5015:5008];
        layer0[50][7:0] = buffer_data_2[5007:5000];
        layer0[50][15:8] = buffer_data_2[5015:5008];
        layer0[50][23:16] = buffer_data_2[5023:5016];
        layer1[50][7:0] = buffer_data_1[5007:5000];
        layer1[50][15:8] = buffer_data_1[5015:5008];
        layer1[50][23:16] = buffer_data_1[5023:5016];
        layer2[50][7:0] = buffer_data_0[5007:5000];
        layer2[50][15:8] = buffer_data_0[5015:5008];
        layer2[50][23:16] = buffer_data_0[5023:5016];
        layer0[51][7:0] = buffer_data_2[5015:5008];
        layer0[51][15:8] = buffer_data_2[5023:5016];
        layer0[51][23:16] = buffer_data_2[5031:5024];
        layer1[51][7:0] = buffer_data_1[5015:5008];
        layer1[51][15:8] = buffer_data_1[5023:5016];
        layer1[51][23:16] = buffer_data_1[5031:5024];
        layer2[51][7:0] = buffer_data_0[5015:5008];
        layer2[51][15:8] = buffer_data_0[5023:5016];
        layer2[51][23:16] = buffer_data_0[5031:5024];
        layer0[52][7:0] = buffer_data_2[5023:5016];
        layer0[52][15:8] = buffer_data_2[5031:5024];
        layer0[52][23:16] = buffer_data_2[5039:5032];
        layer1[52][7:0] = buffer_data_1[5023:5016];
        layer1[52][15:8] = buffer_data_1[5031:5024];
        layer1[52][23:16] = buffer_data_1[5039:5032];
        layer2[52][7:0] = buffer_data_0[5023:5016];
        layer2[52][15:8] = buffer_data_0[5031:5024];
        layer2[52][23:16] = buffer_data_0[5039:5032];
        layer0[53][7:0] = buffer_data_2[5031:5024];
        layer0[53][15:8] = buffer_data_2[5039:5032];
        layer0[53][23:16] = buffer_data_2[5047:5040];
        layer1[53][7:0] = buffer_data_1[5031:5024];
        layer1[53][15:8] = buffer_data_1[5039:5032];
        layer1[53][23:16] = buffer_data_1[5047:5040];
        layer2[53][7:0] = buffer_data_0[5031:5024];
        layer2[53][15:8] = buffer_data_0[5039:5032];
        layer2[53][23:16] = buffer_data_0[5047:5040];
        layer0[54][7:0] = buffer_data_2[5039:5032];
        layer0[54][15:8] = buffer_data_2[5047:5040];
        layer0[54][23:16] = buffer_data_2[5055:5048];
        layer1[54][7:0] = buffer_data_1[5039:5032];
        layer1[54][15:8] = buffer_data_1[5047:5040];
        layer1[54][23:16] = buffer_data_1[5055:5048];
        layer2[54][7:0] = buffer_data_0[5039:5032];
        layer2[54][15:8] = buffer_data_0[5047:5040];
        layer2[54][23:16] = buffer_data_0[5055:5048];
        layer0[55][7:0] = buffer_data_2[5047:5040];
        layer0[55][15:8] = buffer_data_2[5055:5048];
        layer0[55][23:16] = buffer_data_2[5063:5056];
        layer1[55][7:0] = buffer_data_1[5047:5040];
        layer1[55][15:8] = buffer_data_1[5055:5048];
        layer1[55][23:16] = buffer_data_1[5063:5056];
        layer2[55][7:0] = buffer_data_0[5047:5040];
        layer2[55][15:8] = buffer_data_0[5055:5048];
        layer2[55][23:16] = buffer_data_0[5063:5056];
        layer0[56][7:0] = buffer_data_2[5055:5048];
        layer0[56][15:8] = buffer_data_2[5063:5056];
        layer0[56][23:16] = buffer_data_2[5071:5064];
        layer1[56][7:0] = buffer_data_1[5055:5048];
        layer1[56][15:8] = buffer_data_1[5063:5056];
        layer1[56][23:16] = buffer_data_1[5071:5064];
        layer2[56][7:0] = buffer_data_0[5055:5048];
        layer2[56][15:8] = buffer_data_0[5063:5056];
        layer2[56][23:16] = buffer_data_0[5071:5064];
        layer0[57][7:0] = buffer_data_2[5063:5056];
        layer0[57][15:8] = buffer_data_2[5071:5064];
        layer0[57][23:16] = buffer_data_2[5079:5072];
        layer1[57][7:0] = buffer_data_1[5063:5056];
        layer1[57][15:8] = buffer_data_1[5071:5064];
        layer1[57][23:16] = buffer_data_1[5079:5072];
        layer2[57][7:0] = buffer_data_0[5063:5056];
        layer2[57][15:8] = buffer_data_0[5071:5064];
        layer2[57][23:16] = buffer_data_0[5079:5072];
        layer0[58][7:0] = buffer_data_2[5071:5064];
        layer0[58][15:8] = buffer_data_2[5079:5072];
        layer0[58][23:16] = buffer_data_2[5087:5080];
        layer1[58][7:0] = buffer_data_1[5071:5064];
        layer1[58][15:8] = buffer_data_1[5079:5072];
        layer1[58][23:16] = buffer_data_1[5087:5080];
        layer2[58][7:0] = buffer_data_0[5071:5064];
        layer2[58][15:8] = buffer_data_0[5079:5072];
        layer2[58][23:16] = buffer_data_0[5087:5080];
        layer0[59][7:0] = buffer_data_2[5079:5072];
        layer0[59][15:8] = buffer_data_2[5087:5080];
        layer0[59][23:16] = buffer_data_2[5095:5088];
        layer1[59][7:0] = buffer_data_1[5079:5072];
        layer1[59][15:8] = buffer_data_1[5087:5080];
        layer1[59][23:16] = buffer_data_1[5095:5088];
        layer2[59][7:0] = buffer_data_0[5079:5072];
        layer2[59][15:8] = buffer_data_0[5087:5080];
        layer2[59][23:16] = buffer_data_0[5095:5088];
        layer0[60][7:0] = buffer_data_2[5087:5080];
        layer0[60][15:8] = buffer_data_2[5095:5088];
        layer0[60][23:16] = buffer_data_2[5103:5096];
        layer1[60][7:0] = buffer_data_1[5087:5080];
        layer1[60][15:8] = buffer_data_1[5095:5088];
        layer1[60][23:16] = buffer_data_1[5103:5096];
        layer2[60][7:0] = buffer_data_0[5087:5080];
        layer2[60][15:8] = buffer_data_0[5095:5088];
        layer2[60][23:16] = buffer_data_0[5103:5096];
        layer0[61][7:0] = buffer_data_2[5095:5088];
        layer0[61][15:8] = buffer_data_2[5103:5096];
        layer0[61][23:16] = buffer_data_2[5111:5104];
        layer1[61][7:0] = buffer_data_1[5095:5088];
        layer1[61][15:8] = buffer_data_1[5103:5096];
        layer1[61][23:16] = buffer_data_1[5111:5104];
        layer2[61][7:0] = buffer_data_0[5095:5088];
        layer2[61][15:8] = buffer_data_0[5103:5096];
        layer2[61][23:16] = buffer_data_0[5111:5104];
        layer0[62][7:0] = buffer_data_2[5103:5096];
        layer0[62][15:8] = buffer_data_2[5111:5104];
        layer0[62][23:16] = buffer_data_2[5119:5112];
        layer1[62][7:0] = buffer_data_1[5103:5096];
        layer1[62][15:8] = buffer_data_1[5111:5104];
        layer1[62][23:16] = buffer_data_1[5119:5112];
        layer2[62][7:0] = buffer_data_0[5103:5096];
        layer2[62][15:8] = buffer_data_0[5111:5104];
        layer2[62][23:16] = buffer_data_0[5119:5112];
        layer0[63][7:0] = buffer_data_2[5111:5104];
        layer0[63][15:8] = buffer_data_2[5119:5112];
        layer0[63][23:16] = 0;
        layer1[63][7:0] = buffer_data_1[5111:5104];
        layer1[63][15:8] = buffer_data_1[5119:5112];
        layer1[63][23:16] = 0;
        layer2[63][7:0] = buffer_data_0[5111:5104];
        layer2[63][15:8] = buffer_data_0[5119:5112];
        layer2[63][23:16] = 0;
    end
  endcase
end

wire  [39:0]  kernel_img_mul_0[0:8];
assign kernel_img_mul_0[0] = layer0[0][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_0[1] = layer0[0][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_0[2] = layer0[0][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_0[3] = layer1[0][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_0[4] = layer1[0][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_0[5] = layer1[0][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_0[6] = layer2[0][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_0[7] = layer2[0][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_0[8] = layer2[0][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_0 = kernel_img_mul_0[0] + kernel_img_mul_0[1] + kernel_img_mul_0[2] + 
                kernel_img_mul_0[3] + kernel_img_mul_0[4] + kernel_img_mul_0[5] + 
                kernel_img_mul_0[6] + kernel_img_mul_0[7] + kernel_img_mul_0[8];
wire  [39:0]  kernel_img_mul_1[0:8];
assign kernel_img_mul_1[0] = layer0[1][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_1[1] = layer0[1][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_1[2] = layer0[1][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_1[3] = layer1[1][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_1[4] = layer1[1][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_1[5] = layer1[1][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_1[6] = layer2[1][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_1[7] = layer2[1][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_1[8] = layer2[1][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_1 = kernel_img_mul_1[0] + kernel_img_mul_1[1] + kernel_img_mul_1[2] + 
                kernel_img_mul_1[3] + kernel_img_mul_1[4] + kernel_img_mul_1[5] + 
                kernel_img_mul_1[6] + kernel_img_mul_1[7] + kernel_img_mul_1[8];
wire  [39:0]  kernel_img_mul_2[0:8];
assign kernel_img_mul_2[0] = layer0[2][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_2[1] = layer0[2][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_2[2] = layer0[2][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_2[3] = layer1[2][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_2[4] = layer1[2][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_2[5] = layer1[2][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_2[6] = layer2[2][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_2[7] = layer2[2][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_2[8] = layer2[2][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_2 = kernel_img_mul_2[0] + kernel_img_mul_2[1] + kernel_img_mul_2[2] + 
                kernel_img_mul_2[3] + kernel_img_mul_2[4] + kernel_img_mul_2[5] + 
                kernel_img_mul_2[6] + kernel_img_mul_2[7] + kernel_img_mul_2[8];
wire  [39:0]  kernel_img_mul_3[0:8];
assign kernel_img_mul_3[0] = layer0[3][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_3[1] = layer0[3][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_3[2] = layer0[3][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_3[3] = layer1[3][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_3[4] = layer1[3][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_3[5] = layer1[3][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_3[6] = layer2[3][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_3[7] = layer2[3][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_3[8] = layer2[3][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_3 = kernel_img_mul_3[0] + kernel_img_mul_3[1] + kernel_img_mul_3[2] + 
                kernel_img_mul_3[3] + kernel_img_mul_3[4] + kernel_img_mul_3[5] + 
                kernel_img_mul_3[6] + kernel_img_mul_3[7] + kernel_img_mul_3[8];
wire  [39:0]  kernel_img_mul_4[0:8];
assign kernel_img_mul_4[0] = layer0[4][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_4[1] = layer0[4][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_4[2] = layer0[4][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_4[3] = layer1[4][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_4[4] = layer1[4][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_4[5] = layer1[4][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_4[6] = layer2[4][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_4[7] = layer2[4][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_4[8] = layer2[4][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_4 = kernel_img_mul_4[0] + kernel_img_mul_4[1] + kernel_img_mul_4[2] + 
                kernel_img_mul_4[3] + kernel_img_mul_4[4] + kernel_img_mul_4[5] + 
                kernel_img_mul_4[6] + kernel_img_mul_4[7] + kernel_img_mul_4[8];
wire  [39:0]  kernel_img_mul_5[0:8];
assign kernel_img_mul_5[0] = layer0[5][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_5[1] = layer0[5][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_5[2] = layer0[5][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_5[3] = layer1[5][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_5[4] = layer1[5][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_5[5] = layer1[5][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_5[6] = layer2[5][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_5[7] = layer2[5][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_5[8] = layer2[5][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_5 = kernel_img_mul_5[0] + kernel_img_mul_5[1] + kernel_img_mul_5[2] + 
                kernel_img_mul_5[3] + kernel_img_mul_5[4] + kernel_img_mul_5[5] + 
                kernel_img_mul_5[6] + kernel_img_mul_5[7] + kernel_img_mul_5[8];
wire  [39:0]  kernel_img_mul_6[0:8];
assign kernel_img_mul_6[0] = layer0[6][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_6[1] = layer0[6][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_6[2] = layer0[6][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_6[3] = layer1[6][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_6[4] = layer1[6][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_6[5] = layer1[6][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_6[6] = layer2[6][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_6[7] = layer2[6][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_6[8] = layer2[6][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_6 = kernel_img_mul_6[0] + kernel_img_mul_6[1] + kernel_img_mul_6[2] + 
                kernel_img_mul_6[3] + kernel_img_mul_6[4] + kernel_img_mul_6[5] + 
                kernel_img_mul_6[6] + kernel_img_mul_6[7] + kernel_img_mul_6[8];
wire  [39:0]  kernel_img_mul_7[0:8];
assign kernel_img_mul_7[0] = layer0[7][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_7[1] = layer0[7][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_7[2] = layer0[7][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_7[3] = layer1[7][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_7[4] = layer1[7][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_7[5] = layer1[7][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_7[6] = layer2[7][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_7[7] = layer2[7][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_7[8] = layer2[7][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_7 = kernel_img_mul_7[0] + kernel_img_mul_7[1] + kernel_img_mul_7[2] + 
                kernel_img_mul_7[3] + kernel_img_mul_7[4] + kernel_img_mul_7[5] + 
                kernel_img_mul_7[6] + kernel_img_mul_7[7] + kernel_img_mul_7[8];
wire  [39:0]  kernel_img_mul_8[0:8];
assign kernel_img_mul_8[0] = layer0[8][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_8[1] = layer0[8][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_8[2] = layer0[8][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_8[3] = layer1[8][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_8[4] = layer1[8][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_8[5] = layer1[8][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_8[6] = layer2[8][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_8[7] = layer2[8][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_8[8] = layer2[8][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_8 = kernel_img_mul_8[0] + kernel_img_mul_8[1] + kernel_img_mul_8[2] + 
                kernel_img_mul_8[3] + kernel_img_mul_8[4] + kernel_img_mul_8[5] + 
                kernel_img_mul_8[6] + kernel_img_mul_8[7] + kernel_img_mul_8[8];
wire  [39:0]  kernel_img_mul_9[0:8];
assign kernel_img_mul_9[0] = layer0[9][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_9[1] = layer0[9][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_9[2] = layer0[9][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_9[3] = layer1[9][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_9[4] = layer1[9][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_9[5] = layer1[9][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_9[6] = layer2[9][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_9[7] = layer2[9][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_9[8] = layer2[9][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_9 = kernel_img_mul_9[0] + kernel_img_mul_9[1] + kernel_img_mul_9[2] + 
                kernel_img_mul_9[3] + kernel_img_mul_9[4] + kernel_img_mul_9[5] + 
                kernel_img_mul_9[6] + kernel_img_mul_9[7] + kernel_img_mul_9[8];
wire  [39:0]  kernel_img_mul_10[0:8];
assign kernel_img_mul_10[0] = layer0[10][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_10[1] = layer0[10][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_10[2] = layer0[10][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_10[3] = layer1[10][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_10[4] = layer1[10][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_10[5] = layer1[10][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_10[6] = layer2[10][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_10[7] = layer2[10][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_10[8] = layer2[10][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_10 = kernel_img_mul_10[0] + kernel_img_mul_10[1] + kernel_img_mul_10[2] + 
                kernel_img_mul_10[3] + kernel_img_mul_10[4] + kernel_img_mul_10[5] + 
                kernel_img_mul_10[6] + kernel_img_mul_10[7] + kernel_img_mul_10[8];
wire  [39:0]  kernel_img_mul_11[0:8];
assign kernel_img_mul_11[0] = layer0[11][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_11[1] = layer0[11][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_11[2] = layer0[11][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_11[3] = layer1[11][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_11[4] = layer1[11][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_11[5] = layer1[11][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_11[6] = layer2[11][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_11[7] = layer2[11][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_11[8] = layer2[11][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_11 = kernel_img_mul_11[0] + kernel_img_mul_11[1] + kernel_img_mul_11[2] + 
                kernel_img_mul_11[3] + kernel_img_mul_11[4] + kernel_img_mul_11[5] + 
                kernel_img_mul_11[6] + kernel_img_mul_11[7] + kernel_img_mul_11[8];
wire  [39:0]  kernel_img_mul_12[0:8];
assign kernel_img_mul_12[0] = layer0[12][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_12[1] = layer0[12][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_12[2] = layer0[12][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_12[3] = layer1[12][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_12[4] = layer1[12][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_12[5] = layer1[12][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_12[6] = layer2[12][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_12[7] = layer2[12][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_12[8] = layer2[12][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_12 = kernel_img_mul_12[0] + kernel_img_mul_12[1] + kernel_img_mul_12[2] + 
                kernel_img_mul_12[3] + kernel_img_mul_12[4] + kernel_img_mul_12[5] + 
                kernel_img_mul_12[6] + kernel_img_mul_12[7] + kernel_img_mul_12[8];
wire  [39:0]  kernel_img_mul_13[0:8];
assign kernel_img_mul_13[0] = layer0[13][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_13[1] = layer0[13][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_13[2] = layer0[13][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_13[3] = layer1[13][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_13[4] = layer1[13][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_13[5] = layer1[13][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_13[6] = layer2[13][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_13[7] = layer2[13][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_13[8] = layer2[13][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_13 = kernel_img_mul_13[0] + kernel_img_mul_13[1] + kernel_img_mul_13[2] + 
                kernel_img_mul_13[3] + kernel_img_mul_13[4] + kernel_img_mul_13[5] + 
                kernel_img_mul_13[6] + kernel_img_mul_13[7] + kernel_img_mul_13[8];
wire  [39:0]  kernel_img_mul_14[0:8];
assign kernel_img_mul_14[0] = layer0[14][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_14[1] = layer0[14][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_14[2] = layer0[14][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_14[3] = layer1[14][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_14[4] = layer1[14][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_14[5] = layer1[14][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_14[6] = layer2[14][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_14[7] = layer2[14][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_14[8] = layer2[14][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_14 = kernel_img_mul_14[0] + kernel_img_mul_14[1] + kernel_img_mul_14[2] + 
                kernel_img_mul_14[3] + kernel_img_mul_14[4] + kernel_img_mul_14[5] + 
                kernel_img_mul_14[6] + kernel_img_mul_14[7] + kernel_img_mul_14[8];
wire  [39:0]  kernel_img_mul_15[0:8];
assign kernel_img_mul_15[0] = layer0[15][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_15[1] = layer0[15][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_15[2] = layer0[15][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_15[3] = layer1[15][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_15[4] = layer1[15][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_15[5] = layer1[15][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_15[6] = layer2[15][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_15[7] = layer2[15][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_15[8] = layer2[15][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_15 = kernel_img_mul_15[0] + kernel_img_mul_15[1] + kernel_img_mul_15[2] + 
                kernel_img_mul_15[3] + kernel_img_mul_15[4] + kernel_img_mul_15[5] + 
                kernel_img_mul_15[6] + kernel_img_mul_15[7] + kernel_img_mul_15[8];
wire  [39:0]  kernel_img_mul_16[0:8];
assign kernel_img_mul_16[0] = layer0[16][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_16[1] = layer0[16][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_16[2] = layer0[16][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_16[3] = layer1[16][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_16[4] = layer1[16][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_16[5] = layer1[16][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_16[6] = layer2[16][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_16[7] = layer2[16][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_16[8] = layer2[16][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_16 = kernel_img_mul_16[0] + kernel_img_mul_16[1] + kernel_img_mul_16[2] + 
                kernel_img_mul_16[3] + kernel_img_mul_16[4] + kernel_img_mul_16[5] + 
                kernel_img_mul_16[6] + kernel_img_mul_16[7] + kernel_img_mul_16[8];
wire  [39:0]  kernel_img_mul_17[0:8];
assign kernel_img_mul_17[0] = layer0[17][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_17[1] = layer0[17][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_17[2] = layer0[17][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_17[3] = layer1[17][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_17[4] = layer1[17][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_17[5] = layer1[17][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_17[6] = layer2[17][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_17[7] = layer2[17][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_17[8] = layer2[17][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_17 = kernel_img_mul_17[0] + kernel_img_mul_17[1] + kernel_img_mul_17[2] + 
                kernel_img_mul_17[3] + kernel_img_mul_17[4] + kernel_img_mul_17[5] + 
                kernel_img_mul_17[6] + kernel_img_mul_17[7] + kernel_img_mul_17[8];
wire  [39:0]  kernel_img_mul_18[0:8];
assign kernel_img_mul_18[0] = layer0[18][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_18[1] = layer0[18][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_18[2] = layer0[18][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_18[3] = layer1[18][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_18[4] = layer1[18][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_18[5] = layer1[18][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_18[6] = layer2[18][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_18[7] = layer2[18][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_18[8] = layer2[18][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_18 = kernel_img_mul_18[0] + kernel_img_mul_18[1] + kernel_img_mul_18[2] + 
                kernel_img_mul_18[3] + kernel_img_mul_18[4] + kernel_img_mul_18[5] + 
                kernel_img_mul_18[6] + kernel_img_mul_18[7] + kernel_img_mul_18[8];
wire  [39:0]  kernel_img_mul_19[0:8];
assign kernel_img_mul_19[0] = layer0[19][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_19[1] = layer0[19][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_19[2] = layer0[19][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_19[3] = layer1[19][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_19[4] = layer1[19][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_19[5] = layer1[19][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_19[6] = layer2[19][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_19[7] = layer2[19][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_19[8] = layer2[19][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_19 = kernel_img_mul_19[0] + kernel_img_mul_19[1] + kernel_img_mul_19[2] + 
                kernel_img_mul_19[3] + kernel_img_mul_19[4] + kernel_img_mul_19[5] + 
                kernel_img_mul_19[6] + kernel_img_mul_19[7] + kernel_img_mul_19[8];
wire  [39:0]  kernel_img_mul_20[0:8];
assign kernel_img_mul_20[0] = layer0[20][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_20[1] = layer0[20][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_20[2] = layer0[20][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_20[3] = layer1[20][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_20[4] = layer1[20][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_20[5] = layer1[20][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_20[6] = layer2[20][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_20[7] = layer2[20][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_20[8] = layer2[20][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_20 = kernel_img_mul_20[0] + kernel_img_mul_20[1] + kernel_img_mul_20[2] + 
                kernel_img_mul_20[3] + kernel_img_mul_20[4] + kernel_img_mul_20[5] + 
                kernel_img_mul_20[6] + kernel_img_mul_20[7] + kernel_img_mul_20[8];
wire  [39:0]  kernel_img_mul_21[0:8];
assign kernel_img_mul_21[0] = layer0[21][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_21[1] = layer0[21][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_21[2] = layer0[21][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_21[3] = layer1[21][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_21[4] = layer1[21][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_21[5] = layer1[21][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_21[6] = layer2[21][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_21[7] = layer2[21][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_21[8] = layer2[21][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_21 = kernel_img_mul_21[0] + kernel_img_mul_21[1] + kernel_img_mul_21[2] + 
                kernel_img_mul_21[3] + kernel_img_mul_21[4] + kernel_img_mul_21[5] + 
                kernel_img_mul_21[6] + kernel_img_mul_21[7] + kernel_img_mul_21[8];
wire  [39:0]  kernel_img_mul_22[0:8];
assign kernel_img_mul_22[0] = layer0[22][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_22[1] = layer0[22][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_22[2] = layer0[22][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_22[3] = layer1[22][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_22[4] = layer1[22][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_22[5] = layer1[22][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_22[6] = layer2[22][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_22[7] = layer2[22][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_22[8] = layer2[22][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_22 = kernel_img_mul_22[0] + kernel_img_mul_22[1] + kernel_img_mul_22[2] + 
                kernel_img_mul_22[3] + kernel_img_mul_22[4] + kernel_img_mul_22[5] + 
                kernel_img_mul_22[6] + kernel_img_mul_22[7] + kernel_img_mul_22[8];
wire  [39:0]  kernel_img_mul_23[0:8];
assign kernel_img_mul_23[0] = layer0[23][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_23[1] = layer0[23][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_23[2] = layer0[23][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_23[3] = layer1[23][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_23[4] = layer1[23][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_23[5] = layer1[23][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_23[6] = layer2[23][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_23[7] = layer2[23][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_23[8] = layer2[23][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_23 = kernel_img_mul_23[0] + kernel_img_mul_23[1] + kernel_img_mul_23[2] + 
                kernel_img_mul_23[3] + kernel_img_mul_23[4] + kernel_img_mul_23[5] + 
                kernel_img_mul_23[6] + kernel_img_mul_23[7] + kernel_img_mul_23[8];
wire  [39:0]  kernel_img_mul_24[0:8];
assign kernel_img_mul_24[0] = layer0[24][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_24[1] = layer0[24][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_24[2] = layer0[24][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_24[3] = layer1[24][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_24[4] = layer1[24][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_24[5] = layer1[24][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_24[6] = layer2[24][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_24[7] = layer2[24][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_24[8] = layer2[24][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_24 = kernel_img_mul_24[0] + kernel_img_mul_24[1] + kernel_img_mul_24[2] + 
                kernel_img_mul_24[3] + kernel_img_mul_24[4] + kernel_img_mul_24[5] + 
                kernel_img_mul_24[6] + kernel_img_mul_24[7] + kernel_img_mul_24[8];
wire  [39:0]  kernel_img_mul_25[0:8];
assign kernel_img_mul_25[0] = layer0[25][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_25[1] = layer0[25][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_25[2] = layer0[25][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_25[3] = layer1[25][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_25[4] = layer1[25][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_25[5] = layer1[25][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_25[6] = layer2[25][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_25[7] = layer2[25][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_25[8] = layer2[25][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_25 = kernel_img_mul_25[0] + kernel_img_mul_25[1] + kernel_img_mul_25[2] + 
                kernel_img_mul_25[3] + kernel_img_mul_25[4] + kernel_img_mul_25[5] + 
                kernel_img_mul_25[6] + kernel_img_mul_25[7] + kernel_img_mul_25[8];
wire  [39:0]  kernel_img_mul_26[0:8];
assign kernel_img_mul_26[0] = layer0[26][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_26[1] = layer0[26][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_26[2] = layer0[26][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_26[3] = layer1[26][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_26[4] = layer1[26][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_26[5] = layer1[26][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_26[6] = layer2[26][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_26[7] = layer2[26][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_26[8] = layer2[26][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_26 = kernel_img_mul_26[0] + kernel_img_mul_26[1] + kernel_img_mul_26[2] + 
                kernel_img_mul_26[3] + kernel_img_mul_26[4] + kernel_img_mul_26[5] + 
                kernel_img_mul_26[6] + kernel_img_mul_26[7] + kernel_img_mul_26[8];
wire  [39:0]  kernel_img_mul_27[0:8];
assign kernel_img_mul_27[0] = layer0[27][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_27[1] = layer0[27][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_27[2] = layer0[27][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_27[3] = layer1[27][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_27[4] = layer1[27][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_27[5] = layer1[27][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_27[6] = layer2[27][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_27[7] = layer2[27][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_27[8] = layer2[27][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_27 = kernel_img_mul_27[0] + kernel_img_mul_27[1] + kernel_img_mul_27[2] + 
                kernel_img_mul_27[3] + kernel_img_mul_27[4] + kernel_img_mul_27[5] + 
                kernel_img_mul_27[6] + kernel_img_mul_27[7] + kernel_img_mul_27[8];
wire  [39:0]  kernel_img_mul_28[0:8];
assign kernel_img_mul_28[0] = layer0[28][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_28[1] = layer0[28][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_28[2] = layer0[28][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_28[3] = layer1[28][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_28[4] = layer1[28][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_28[5] = layer1[28][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_28[6] = layer2[28][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_28[7] = layer2[28][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_28[8] = layer2[28][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_28 = kernel_img_mul_28[0] + kernel_img_mul_28[1] + kernel_img_mul_28[2] + 
                kernel_img_mul_28[3] + kernel_img_mul_28[4] + kernel_img_mul_28[5] + 
                kernel_img_mul_28[6] + kernel_img_mul_28[7] + kernel_img_mul_28[8];
wire  [39:0]  kernel_img_mul_29[0:8];
assign kernel_img_mul_29[0] = layer0[29][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_29[1] = layer0[29][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_29[2] = layer0[29][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_29[3] = layer1[29][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_29[4] = layer1[29][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_29[5] = layer1[29][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_29[6] = layer2[29][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_29[7] = layer2[29][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_29[8] = layer2[29][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_29 = kernel_img_mul_29[0] + kernel_img_mul_29[1] + kernel_img_mul_29[2] + 
                kernel_img_mul_29[3] + kernel_img_mul_29[4] + kernel_img_mul_29[5] + 
                kernel_img_mul_29[6] + kernel_img_mul_29[7] + kernel_img_mul_29[8];
wire  [39:0]  kernel_img_mul_30[0:8];
assign kernel_img_mul_30[0] = layer0[30][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_30[1] = layer0[30][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_30[2] = layer0[30][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_30[3] = layer1[30][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_30[4] = layer1[30][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_30[5] = layer1[30][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_30[6] = layer2[30][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_30[7] = layer2[30][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_30[8] = layer2[30][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_30 = kernel_img_mul_30[0] + kernel_img_mul_30[1] + kernel_img_mul_30[2] + 
                kernel_img_mul_30[3] + kernel_img_mul_30[4] + kernel_img_mul_30[5] + 
                kernel_img_mul_30[6] + kernel_img_mul_30[7] + kernel_img_mul_30[8];
wire  [39:0]  kernel_img_mul_31[0:8];
assign kernel_img_mul_31[0] = layer0[31][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_31[1] = layer0[31][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_31[2] = layer0[31][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_31[3] = layer1[31][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_31[4] = layer1[31][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_31[5] = layer1[31][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_31[6] = layer2[31][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_31[7] = layer2[31][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_31[8] = layer2[31][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_31 = kernel_img_mul_31[0] + kernel_img_mul_31[1] + kernel_img_mul_31[2] + 
                kernel_img_mul_31[3] + kernel_img_mul_31[4] + kernel_img_mul_31[5] + 
                kernel_img_mul_31[6] + kernel_img_mul_31[7] + kernel_img_mul_31[8];
wire  [39:0]  kernel_img_mul_32[0:8];
assign kernel_img_mul_32[0] = layer0[32][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_32[1] = layer0[32][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_32[2] = layer0[32][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_32[3] = layer1[32][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_32[4] = layer1[32][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_32[5] = layer1[32][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_32[6] = layer2[32][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_32[7] = layer2[32][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_32[8] = layer2[32][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_32 = kernel_img_mul_32[0] + kernel_img_mul_32[1] + kernel_img_mul_32[2] + 
                kernel_img_mul_32[3] + kernel_img_mul_32[4] + kernel_img_mul_32[5] + 
                kernel_img_mul_32[6] + kernel_img_mul_32[7] + kernel_img_mul_32[8];
wire  [39:0]  kernel_img_mul_33[0:8];
assign kernel_img_mul_33[0] = layer0[33][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_33[1] = layer0[33][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_33[2] = layer0[33][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_33[3] = layer1[33][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_33[4] = layer1[33][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_33[5] = layer1[33][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_33[6] = layer2[33][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_33[7] = layer2[33][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_33[8] = layer2[33][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_33 = kernel_img_mul_33[0] + kernel_img_mul_33[1] + kernel_img_mul_33[2] + 
                kernel_img_mul_33[3] + kernel_img_mul_33[4] + kernel_img_mul_33[5] + 
                kernel_img_mul_33[6] + kernel_img_mul_33[7] + kernel_img_mul_33[8];
wire  [39:0]  kernel_img_mul_34[0:8];
assign kernel_img_mul_34[0] = layer0[34][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_34[1] = layer0[34][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_34[2] = layer0[34][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_34[3] = layer1[34][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_34[4] = layer1[34][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_34[5] = layer1[34][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_34[6] = layer2[34][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_34[7] = layer2[34][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_34[8] = layer2[34][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_34 = kernel_img_mul_34[0] + kernel_img_mul_34[1] + kernel_img_mul_34[2] + 
                kernel_img_mul_34[3] + kernel_img_mul_34[4] + kernel_img_mul_34[5] + 
                kernel_img_mul_34[6] + kernel_img_mul_34[7] + kernel_img_mul_34[8];
wire  [39:0]  kernel_img_mul_35[0:8];
assign kernel_img_mul_35[0] = layer0[35][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_35[1] = layer0[35][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_35[2] = layer0[35][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_35[3] = layer1[35][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_35[4] = layer1[35][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_35[5] = layer1[35][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_35[6] = layer2[35][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_35[7] = layer2[35][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_35[8] = layer2[35][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_35 = kernel_img_mul_35[0] + kernel_img_mul_35[1] + kernel_img_mul_35[2] + 
                kernel_img_mul_35[3] + kernel_img_mul_35[4] + kernel_img_mul_35[5] + 
                kernel_img_mul_35[6] + kernel_img_mul_35[7] + kernel_img_mul_35[8];
wire  [39:0]  kernel_img_mul_36[0:8];
assign kernel_img_mul_36[0] = layer0[36][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_36[1] = layer0[36][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_36[2] = layer0[36][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_36[3] = layer1[36][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_36[4] = layer1[36][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_36[5] = layer1[36][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_36[6] = layer2[36][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_36[7] = layer2[36][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_36[8] = layer2[36][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_36 = kernel_img_mul_36[0] + kernel_img_mul_36[1] + kernel_img_mul_36[2] + 
                kernel_img_mul_36[3] + kernel_img_mul_36[4] + kernel_img_mul_36[5] + 
                kernel_img_mul_36[6] + kernel_img_mul_36[7] + kernel_img_mul_36[8];
wire  [39:0]  kernel_img_mul_37[0:8];
assign kernel_img_mul_37[0] = layer0[37][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_37[1] = layer0[37][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_37[2] = layer0[37][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_37[3] = layer1[37][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_37[4] = layer1[37][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_37[5] = layer1[37][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_37[6] = layer2[37][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_37[7] = layer2[37][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_37[8] = layer2[37][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_37 = kernel_img_mul_37[0] + kernel_img_mul_37[1] + kernel_img_mul_37[2] + 
                kernel_img_mul_37[3] + kernel_img_mul_37[4] + kernel_img_mul_37[5] + 
                kernel_img_mul_37[6] + kernel_img_mul_37[7] + kernel_img_mul_37[8];
wire  [39:0]  kernel_img_mul_38[0:8];
assign kernel_img_mul_38[0] = layer0[38][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_38[1] = layer0[38][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_38[2] = layer0[38][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_38[3] = layer1[38][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_38[4] = layer1[38][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_38[5] = layer1[38][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_38[6] = layer2[38][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_38[7] = layer2[38][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_38[8] = layer2[38][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_38 = kernel_img_mul_38[0] + kernel_img_mul_38[1] + kernel_img_mul_38[2] + 
                kernel_img_mul_38[3] + kernel_img_mul_38[4] + kernel_img_mul_38[5] + 
                kernel_img_mul_38[6] + kernel_img_mul_38[7] + kernel_img_mul_38[8];
wire  [39:0]  kernel_img_mul_39[0:8];
assign kernel_img_mul_39[0] = layer0[39][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_39[1] = layer0[39][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_39[2] = layer0[39][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_39[3] = layer1[39][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_39[4] = layer1[39][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_39[5] = layer1[39][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_39[6] = layer2[39][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_39[7] = layer2[39][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_39[8] = layer2[39][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_39 = kernel_img_mul_39[0] + kernel_img_mul_39[1] + kernel_img_mul_39[2] + 
                kernel_img_mul_39[3] + kernel_img_mul_39[4] + kernel_img_mul_39[5] + 
                kernel_img_mul_39[6] + kernel_img_mul_39[7] + kernel_img_mul_39[8];
wire  [39:0]  kernel_img_mul_40[0:8];
assign kernel_img_mul_40[0] = layer0[40][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_40[1] = layer0[40][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_40[2] = layer0[40][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_40[3] = layer1[40][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_40[4] = layer1[40][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_40[5] = layer1[40][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_40[6] = layer2[40][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_40[7] = layer2[40][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_40[8] = layer2[40][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_40 = kernel_img_mul_40[0] + kernel_img_mul_40[1] + kernel_img_mul_40[2] + 
                kernel_img_mul_40[3] + kernel_img_mul_40[4] + kernel_img_mul_40[5] + 
                kernel_img_mul_40[6] + kernel_img_mul_40[7] + kernel_img_mul_40[8];
wire  [39:0]  kernel_img_mul_41[0:8];
assign kernel_img_mul_41[0] = layer0[41][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_41[1] = layer0[41][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_41[2] = layer0[41][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_41[3] = layer1[41][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_41[4] = layer1[41][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_41[5] = layer1[41][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_41[6] = layer2[41][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_41[7] = layer2[41][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_41[8] = layer2[41][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_41 = kernel_img_mul_41[0] + kernel_img_mul_41[1] + kernel_img_mul_41[2] + 
                kernel_img_mul_41[3] + kernel_img_mul_41[4] + kernel_img_mul_41[5] + 
                kernel_img_mul_41[6] + kernel_img_mul_41[7] + kernel_img_mul_41[8];
wire  [39:0]  kernel_img_mul_42[0:8];
assign kernel_img_mul_42[0] = layer0[42][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_42[1] = layer0[42][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_42[2] = layer0[42][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_42[3] = layer1[42][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_42[4] = layer1[42][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_42[5] = layer1[42][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_42[6] = layer2[42][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_42[7] = layer2[42][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_42[8] = layer2[42][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_42 = kernel_img_mul_42[0] + kernel_img_mul_42[1] + kernel_img_mul_42[2] + 
                kernel_img_mul_42[3] + kernel_img_mul_42[4] + kernel_img_mul_42[5] + 
                kernel_img_mul_42[6] + kernel_img_mul_42[7] + kernel_img_mul_42[8];
wire  [39:0]  kernel_img_mul_43[0:8];
assign kernel_img_mul_43[0] = layer0[43][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_43[1] = layer0[43][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_43[2] = layer0[43][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_43[3] = layer1[43][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_43[4] = layer1[43][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_43[5] = layer1[43][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_43[6] = layer2[43][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_43[7] = layer2[43][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_43[8] = layer2[43][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_43 = kernel_img_mul_43[0] + kernel_img_mul_43[1] + kernel_img_mul_43[2] + 
                kernel_img_mul_43[3] + kernel_img_mul_43[4] + kernel_img_mul_43[5] + 
                kernel_img_mul_43[6] + kernel_img_mul_43[7] + kernel_img_mul_43[8];
wire  [39:0]  kernel_img_mul_44[0:8];
assign kernel_img_mul_44[0] = layer0[44][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_44[1] = layer0[44][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_44[2] = layer0[44][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_44[3] = layer1[44][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_44[4] = layer1[44][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_44[5] = layer1[44][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_44[6] = layer2[44][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_44[7] = layer2[44][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_44[8] = layer2[44][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_44 = kernel_img_mul_44[0] + kernel_img_mul_44[1] + kernel_img_mul_44[2] + 
                kernel_img_mul_44[3] + kernel_img_mul_44[4] + kernel_img_mul_44[5] + 
                kernel_img_mul_44[6] + kernel_img_mul_44[7] + kernel_img_mul_44[8];
wire  [39:0]  kernel_img_mul_45[0:8];
assign kernel_img_mul_45[0] = layer0[45][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_45[1] = layer0[45][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_45[2] = layer0[45][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_45[3] = layer1[45][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_45[4] = layer1[45][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_45[5] = layer1[45][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_45[6] = layer2[45][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_45[7] = layer2[45][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_45[8] = layer2[45][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_45 = kernel_img_mul_45[0] + kernel_img_mul_45[1] + kernel_img_mul_45[2] + 
                kernel_img_mul_45[3] + kernel_img_mul_45[4] + kernel_img_mul_45[5] + 
                kernel_img_mul_45[6] + kernel_img_mul_45[7] + kernel_img_mul_45[8];
wire  [39:0]  kernel_img_mul_46[0:8];
assign kernel_img_mul_46[0] = layer0[46][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_46[1] = layer0[46][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_46[2] = layer0[46][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_46[3] = layer1[46][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_46[4] = layer1[46][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_46[5] = layer1[46][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_46[6] = layer2[46][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_46[7] = layer2[46][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_46[8] = layer2[46][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_46 = kernel_img_mul_46[0] + kernel_img_mul_46[1] + kernel_img_mul_46[2] + 
                kernel_img_mul_46[3] + kernel_img_mul_46[4] + kernel_img_mul_46[5] + 
                kernel_img_mul_46[6] + kernel_img_mul_46[7] + kernel_img_mul_46[8];
wire  [39:0]  kernel_img_mul_47[0:8];
assign kernel_img_mul_47[0] = layer0[47][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_47[1] = layer0[47][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_47[2] = layer0[47][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_47[3] = layer1[47][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_47[4] = layer1[47][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_47[5] = layer1[47][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_47[6] = layer2[47][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_47[7] = layer2[47][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_47[8] = layer2[47][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_47 = kernel_img_mul_47[0] + kernel_img_mul_47[1] + kernel_img_mul_47[2] + 
                kernel_img_mul_47[3] + kernel_img_mul_47[4] + kernel_img_mul_47[5] + 
                kernel_img_mul_47[6] + kernel_img_mul_47[7] + kernel_img_mul_47[8];
wire  [39:0]  kernel_img_mul_48[0:8];
assign kernel_img_mul_48[0] = layer0[48][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_48[1] = layer0[48][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_48[2] = layer0[48][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_48[3] = layer1[48][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_48[4] = layer1[48][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_48[5] = layer1[48][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_48[6] = layer2[48][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_48[7] = layer2[48][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_48[8] = layer2[48][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_48 = kernel_img_mul_48[0] + kernel_img_mul_48[1] + kernel_img_mul_48[2] + 
                kernel_img_mul_48[3] + kernel_img_mul_48[4] + kernel_img_mul_48[5] + 
                kernel_img_mul_48[6] + kernel_img_mul_48[7] + kernel_img_mul_48[8];
wire  [39:0]  kernel_img_mul_49[0:8];
assign kernel_img_mul_49[0] = layer0[49][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_49[1] = layer0[49][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_49[2] = layer0[49][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_49[3] = layer1[49][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_49[4] = layer1[49][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_49[5] = layer1[49][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_49[6] = layer2[49][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_49[7] = layer2[49][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_49[8] = layer2[49][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_49 = kernel_img_mul_49[0] + kernel_img_mul_49[1] + kernel_img_mul_49[2] + 
                kernel_img_mul_49[3] + kernel_img_mul_49[4] + kernel_img_mul_49[5] + 
                kernel_img_mul_49[6] + kernel_img_mul_49[7] + kernel_img_mul_49[8];
wire  [39:0]  kernel_img_mul_50[0:8];
assign kernel_img_mul_50[0] = layer0[50][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_50[1] = layer0[50][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_50[2] = layer0[50][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_50[3] = layer1[50][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_50[4] = layer1[50][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_50[5] = layer1[50][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_50[6] = layer2[50][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_50[7] = layer2[50][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_50[8] = layer2[50][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_50 = kernel_img_mul_50[0] + kernel_img_mul_50[1] + kernel_img_mul_50[2] + 
                kernel_img_mul_50[3] + kernel_img_mul_50[4] + kernel_img_mul_50[5] + 
                kernel_img_mul_50[6] + kernel_img_mul_50[7] + kernel_img_mul_50[8];
wire  [39:0]  kernel_img_mul_51[0:8];
assign kernel_img_mul_51[0] = layer0[51][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_51[1] = layer0[51][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_51[2] = layer0[51][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_51[3] = layer1[51][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_51[4] = layer1[51][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_51[5] = layer1[51][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_51[6] = layer2[51][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_51[7] = layer2[51][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_51[8] = layer2[51][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_51 = kernel_img_mul_51[0] + kernel_img_mul_51[1] + kernel_img_mul_51[2] + 
                kernel_img_mul_51[3] + kernel_img_mul_51[4] + kernel_img_mul_51[5] + 
                kernel_img_mul_51[6] + kernel_img_mul_51[7] + kernel_img_mul_51[8];
wire  [39:0]  kernel_img_mul_52[0:8];
assign kernel_img_mul_52[0] = layer0[52][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_52[1] = layer0[52][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_52[2] = layer0[52][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_52[3] = layer1[52][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_52[4] = layer1[52][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_52[5] = layer1[52][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_52[6] = layer2[52][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_52[7] = layer2[52][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_52[8] = layer2[52][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_52 = kernel_img_mul_52[0] + kernel_img_mul_52[1] + kernel_img_mul_52[2] + 
                kernel_img_mul_52[3] + kernel_img_mul_52[4] + kernel_img_mul_52[5] + 
                kernel_img_mul_52[6] + kernel_img_mul_52[7] + kernel_img_mul_52[8];
wire  [39:0]  kernel_img_mul_53[0:8];
assign kernel_img_mul_53[0] = layer0[53][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_53[1] = layer0[53][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_53[2] = layer0[53][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_53[3] = layer1[53][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_53[4] = layer1[53][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_53[5] = layer1[53][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_53[6] = layer2[53][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_53[7] = layer2[53][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_53[8] = layer2[53][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_53 = kernel_img_mul_53[0] + kernel_img_mul_53[1] + kernel_img_mul_53[2] + 
                kernel_img_mul_53[3] + kernel_img_mul_53[4] + kernel_img_mul_53[5] + 
                kernel_img_mul_53[6] + kernel_img_mul_53[7] + kernel_img_mul_53[8];
wire  [39:0]  kernel_img_mul_54[0:8];
assign kernel_img_mul_54[0] = layer0[54][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_54[1] = layer0[54][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_54[2] = layer0[54][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_54[3] = layer1[54][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_54[4] = layer1[54][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_54[5] = layer1[54][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_54[6] = layer2[54][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_54[7] = layer2[54][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_54[8] = layer2[54][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_54 = kernel_img_mul_54[0] + kernel_img_mul_54[1] + kernel_img_mul_54[2] + 
                kernel_img_mul_54[3] + kernel_img_mul_54[4] + kernel_img_mul_54[5] + 
                kernel_img_mul_54[6] + kernel_img_mul_54[7] + kernel_img_mul_54[8];
wire  [39:0]  kernel_img_mul_55[0:8];
assign kernel_img_mul_55[0] = layer0[55][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_55[1] = layer0[55][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_55[2] = layer0[55][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_55[3] = layer1[55][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_55[4] = layer1[55][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_55[5] = layer1[55][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_55[6] = layer2[55][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_55[7] = layer2[55][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_55[8] = layer2[55][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_55 = kernel_img_mul_55[0] + kernel_img_mul_55[1] + kernel_img_mul_55[2] + 
                kernel_img_mul_55[3] + kernel_img_mul_55[4] + kernel_img_mul_55[5] + 
                kernel_img_mul_55[6] + kernel_img_mul_55[7] + kernel_img_mul_55[8];
wire  [39:0]  kernel_img_mul_56[0:8];
assign kernel_img_mul_56[0] = layer0[56][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_56[1] = layer0[56][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_56[2] = layer0[56][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_56[3] = layer1[56][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_56[4] = layer1[56][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_56[5] = layer1[56][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_56[6] = layer2[56][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_56[7] = layer2[56][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_56[8] = layer2[56][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_56 = kernel_img_mul_56[0] + kernel_img_mul_56[1] + kernel_img_mul_56[2] + 
                kernel_img_mul_56[3] + kernel_img_mul_56[4] + kernel_img_mul_56[5] + 
                kernel_img_mul_56[6] + kernel_img_mul_56[7] + kernel_img_mul_56[8];
wire  [39:0]  kernel_img_mul_57[0:8];
assign kernel_img_mul_57[0] = layer0[57][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_57[1] = layer0[57][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_57[2] = layer0[57][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_57[3] = layer1[57][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_57[4] = layer1[57][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_57[5] = layer1[57][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_57[6] = layer2[57][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_57[7] = layer2[57][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_57[8] = layer2[57][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_57 = kernel_img_mul_57[0] + kernel_img_mul_57[1] + kernel_img_mul_57[2] + 
                kernel_img_mul_57[3] + kernel_img_mul_57[4] + kernel_img_mul_57[5] + 
                kernel_img_mul_57[6] + kernel_img_mul_57[7] + kernel_img_mul_57[8];
wire  [39:0]  kernel_img_mul_58[0:8];
assign kernel_img_mul_58[0] = layer0[58][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_58[1] = layer0[58][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_58[2] = layer0[58][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_58[3] = layer1[58][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_58[4] = layer1[58][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_58[5] = layer1[58][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_58[6] = layer2[58][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_58[7] = layer2[58][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_58[8] = layer2[58][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_58 = kernel_img_mul_58[0] + kernel_img_mul_58[1] + kernel_img_mul_58[2] + 
                kernel_img_mul_58[3] + kernel_img_mul_58[4] + kernel_img_mul_58[5] + 
                kernel_img_mul_58[6] + kernel_img_mul_58[7] + kernel_img_mul_58[8];
wire  [39:0]  kernel_img_mul_59[0:8];
assign kernel_img_mul_59[0] = layer0[59][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_59[1] = layer0[59][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_59[2] = layer0[59][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_59[3] = layer1[59][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_59[4] = layer1[59][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_59[5] = layer1[59][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_59[6] = layer2[59][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_59[7] = layer2[59][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_59[8] = layer2[59][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_59 = kernel_img_mul_59[0] + kernel_img_mul_59[1] + kernel_img_mul_59[2] + 
                kernel_img_mul_59[3] + kernel_img_mul_59[4] + kernel_img_mul_59[5] + 
                kernel_img_mul_59[6] + kernel_img_mul_59[7] + kernel_img_mul_59[8];
wire  [39:0]  kernel_img_mul_60[0:8];
assign kernel_img_mul_60[0] = layer0[60][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_60[1] = layer0[60][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_60[2] = layer0[60][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_60[3] = layer1[60][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_60[4] = layer1[60][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_60[5] = layer1[60][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_60[6] = layer2[60][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_60[7] = layer2[60][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_60[8] = layer2[60][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_60 = kernel_img_mul_60[0] + kernel_img_mul_60[1] + kernel_img_mul_60[2] + 
                kernel_img_mul_60[3] + kernel_img_mul_60[4] + kernel_img_mul_60[5] + 
                kernel_img_mul_60[6] + kernel_img_mul_60[7] + kernel_img_mul_60[8];
wire  [39:0]  kernel_img_mul_61[0:8];
assign kernel_img_mul_61[0] = layer0[61][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_61[1] = layer0[61][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_61[2] = layer0[61][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_61[3] = layer1[61][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_61[4] = layer1[61][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_61[5] = layer1[61][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_61[6] = layer2[61][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_61[7] = layer2[61][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_61[8] = layer2[61][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_61 = kernel_img_mul_61[0] + kernel_img_mul_61[1] + kernel_img_mul_61[2] + 
                kernel_img_mul_61[3] + kernel_img_mul_61[4] + kernel_img_mul_61[5] + 
                kernel_img_mul_61[6] + kernel_img_mul_61[7] + kernel_img_mul_61[8];
wire  [39:0]  kernel_img_mul_62[0:8];
assign kernel_img_mul_62[0] = layer0[62][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_62[1] = layer0[62][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_62[2] = layer0[62][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_62[3] = layer1[62][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_62[4] = layer1[62][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_62[5] = layer1[62][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_62[6] = layer2[62][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_62[7] = layer2[62][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_62[8] = layer2[62][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_62 = kernel_img_mul_62[0] + kernel_img_mul_62[1] + kernel_img_mul_62[2] + 
                kernel_img_mul_62[3] + kernel_img_mul_62[4] + kernel_img_mul_62[5] + 
                kernel_img_mul_62[6] + kernel_img_mul_62[7] + kernel_img_mul_62[8];
wire  [39:0]  kernel_img_mul_63[0:8];
assign kernel_img_mul_63[0] = layer0[63][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_63[1] = layer0[63][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_63[2] = layer0[63][23:16] *  G_Kernel_3x3[0][95:64];
assign kernel_img_mul_63[3] = layer1[63][7:0] *  G_Kernel_3x3[1][31:0];
assign kernel_img_mul_63[4] = layer1[63][15:8] *  G_Kernel_3x3[1][63:32];
assign kernel_img_mul_63[5] = layer1[63][23:16] *  G_Kernel_3x3[1][95:64];
assign kernel_img_mul_63[6] = layer2[63][7:0] *  G_Kernel_3x3[0][31:0];
assign kernel_img_mul_63[7] = layer2[63][15:8] *  G_Kernel_3x3[0][63:32];
assign kernel_img_mul_63[8] = layer2[63][23:16] *  G_Kernel_3x3[0][95:64];
wire  [39:0]  kernel_img_sum_63 = kernel_img_mul_63[0] + kernel_img_mul_63[1] + kernel_img_mul_63[2] + 
                kernel_img_mul_63[3] + kernel_img_mul_63[4] + kernel_img_mul_63[5] + 
                kernel_img_mul_63[6] + kernel_img_mul_63[7] + kernel_img_mul_63[8];
always @(posedge clk) begin
  if (!rst_n)
    blur_din[7:0] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[7:0] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[7:0] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[15:8] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[15:8] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[15:8] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[23:16] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[23:16] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[23:16] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[31:24] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[31:24] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[31:24] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[39:32] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[39:32] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[39:32] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[47:40] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[47:40] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[47:40] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[55:48] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[55:48] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[55:48] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[63:56] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[63:56] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[63:56] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[71:64] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[71:64] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[71:64] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[79:72] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[79:72] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[79:72] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[87:80] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[87:80] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[87:80] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[95:88] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[95:88] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[95:88] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[103:96] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[103:96] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[103:96] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[111:104] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[111:104] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[111:104] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[119:112] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[119:112] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[119:112] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[127:120] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[127:120] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[127:120] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[135:128] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[135:128] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[135:128] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[143:136] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[143:136] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[143:136] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[151:144] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[151:144] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[151:144] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[159:152] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[159:152] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[159:152] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[167:160] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[167:160] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[167:160] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[175:168] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[175:168] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[175:168] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[183:176] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[183:176] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[183:176] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[191:184] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[191:184] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[191:184] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[199:192] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[199:192] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[199:192] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[207:200] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[207:200] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[207:200] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[215:208] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[215:208] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[215:208] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[223:216] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[223:216] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[223:216] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[231:224] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[231:224] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[231:224] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[239:232] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[239:232] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[239:232] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[247:240] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[247:240] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[247:240] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[255:248] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[255:248] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[255:248] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[263:256] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[263:256] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[263:256] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[271:264] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[271:264] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[271:264] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[279:272] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[279:272] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[279:272] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[287:280] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[287:280] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[287:280] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[295:288] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[295:288] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[295:288] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[303:296] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[303:296] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[303:296] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[311:304] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[311:304] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[311:304] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[319:312] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[319:312] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[319:312] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[327:320] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[327:320] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[327:320] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[335:328] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[335:328] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[335:328] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[343:336] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[343:336] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[343:336] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[351:344] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[351:344] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[351:344] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[359:352] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[359:352] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[359:352] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[367:360] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[367:360] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[367:360] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[375:368] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[375:368] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[375:368] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[383:376] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[383:376] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[383:376] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[391:384] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[391:384] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[391:384] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[399:392] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[399:392] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[399:392] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[407:400] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[407:400] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[407:400] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[415:408] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[415:408] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[415:408] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[423:416] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[423:416] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[423:416] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[431:424] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[431:424] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[431:424] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[439:432] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[439:432] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[439:432] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[447:440] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[447:440] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[447:440] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[455:448] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[455:448] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[455:448] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[463:456] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[463:456] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[463:456] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[471:464] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[471:464] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[471:464] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[479:472] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[479:472] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[479:472] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[487:480] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[487:480] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[487:480] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[495:488] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[495:488] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[495:488] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[503:496] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[503:496] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[503:496] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[511:504] <= 'd0;
  else if (current_state==ST_GAUSSIAN_0)
    blur_din[511:504] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[511:504] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[519:512] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[519:512] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[519:512] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[527:520] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[527:520] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[527:520] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[535:528] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[535:528] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[535:528] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[543:536] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[543:536] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[543:536] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[551:544] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[551:544] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[551:544] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[559:552] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[559:552] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[559:552] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[567:560] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[567:560] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[567:560] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[575:568] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[575:568] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[575:568] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[583:576] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[583:576] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[583:576] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[591:584] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[591:584] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[591:584] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[599:592] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[599:592] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[599:592] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[607:600] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[607:600] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[607:600] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[615:608] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[615:608] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[615:608] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[623:616] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[623:616] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[623:616] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[631:624] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[631:624] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[631:624] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[639:632] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[639:632] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[639:632] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[647:640] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[647:640] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[647:640] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[655:648] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[655:648] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[655:648] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[663:656] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[663:656] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[663:656] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[671:664] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[671:664] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[671:664] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[679:672] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[679:672] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[679:672] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[687:680] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[687:680] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[687:680] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[695:688] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[695:688] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[695:688] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[703:696] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[703:696] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[703:696] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[711:704] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[711:704] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[711:704] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[719:712] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[719:712] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[719:712] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[727:720] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[727:720] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[727:720] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[735:728] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[735:728] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[735:728] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[743:736] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[743:736] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[743:736] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[751:744] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[751:744] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[751:744] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[759:752] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[759:752] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[759:752] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[767:760] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[767:760] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[767:760] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[775:768] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[775:768] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[775:768] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[783:776] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[783:776] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[783:776] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[791:784] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[791:784] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[791:784] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[799:792] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[799:792] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[799:792] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[807:800] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[807:800] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[807:800] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[815:808] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[815:808] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[815:808] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[823:816] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[823:816] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[823:816] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[831:824] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[831:824] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[831:824] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[839:832] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[839:832] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[839:832] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[847:840] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[847:840] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[847:840] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[855:848] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[855:848] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[855:848] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[863:856] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[863:856] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[863:856] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[871:864] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[871:864] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[871:864] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[879:872] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[879:872] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[879:872] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[887:880] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[887:880] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[887:880] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[895:888] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[895:888] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[895:888] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[903:896] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[903:896] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[903:896] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[911:904] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[911:904] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[911:904] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[919:912] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[919:912] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[919:912] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[927:920] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[927:920] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[927:920] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[935:928] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[935:928] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[935:928] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[943:936] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[943:936] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[943:936] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[951:944] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[951:944] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[951:944] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[959:952] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[959:952] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[959:952] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[967:960] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[967:960] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[967:960] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[975:968] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[975:968] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[975:968] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[983:976] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[983:976] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[983:976] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[991:984] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[991:984] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[991:984] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[999:992] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[999:992] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[999:992] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1007:1000] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[1007:1000] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1007:1000] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1015:1008] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[1015:1008] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1015:1008] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1023:1016] <= 'd0;
  else if (current_state==ST_GAUSSIAN_1)
    blur_din[1023:1016] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1023:1016] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1031:1024] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1031:1024] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1031:1024] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1039:1032] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1039:1032] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1039:1032] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1047:1040] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1047:1040] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1047:1040] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1055:1048] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1055:1048] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1055:1048] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1063:1056] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1063:1056] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1063:1056] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1071:1064] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1071:1064] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1071:1064] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1079:1072] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1079:1072] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1079:1072] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1087:1080] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1087:1080] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1087:1080] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1095:1088] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1095:1088] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1095:1088] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1103:1096] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1103:1096] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1103:1096] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1111:1104] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1111:1104] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1111:1104] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1119:1112] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1119:1112] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1119:1112] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1127:1120] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1127:1120] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1127:1120] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1135:1128] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1135:1128] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1135:1128] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1143:1136] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1143:1136] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1143:1136] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1151:1144] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1151:1144] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1151:1144] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1159:1152] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1159:1152] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1159:1152] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1167:1160] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1167:1160] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1167:1160] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1175:1168] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1175:1168] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1175:1168] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1183:1176] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1183:1176] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1183:1176] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1191:1184] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1191:1184] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1191:1184] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1199:1192] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1199:1192] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1199:1192] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1207:1200] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1207:1200] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1207:1200] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1215:1208] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1215:1208] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1215:1208] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1223:1216] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1223:1216] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1223:1216] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1231:1224] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1231:1224] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1231:1224] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1239:1232] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1239:1232] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1239:1232] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1247:1240] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1247:1240] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1247:1240] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1255:1248] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1255:1248] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1255:1248] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1263:1256] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1263:1256] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1263:1256] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1271:1264] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1271:1264] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1271:1264] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1279:1272] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1279:1272] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1279:1272] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1287:1280] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1287:1280] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1287:1280] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1295:1288] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1295:1288] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1295:1288] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1303:1296] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1303:1296] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1303:1296] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1311:1304] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1311:1304] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1311:1304] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1319:1312] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1319:1312] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1319:1312] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1327:1320] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1327:1320] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1327:1320] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1335:1328] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1335:1328] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1335:1328] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1343:1336] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1343:1336] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1343:1336] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1351:1344] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1351:1344] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1351:1344] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1359:1352] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1359:1352] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1359:1352] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1367:1360] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1367:1360] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1367:1360] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1375:1368] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1375:1368] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1375:1368] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1383:1376] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1383:1376] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1383:1376] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1391:1384] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1391:1384] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1391:1384] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1399:1392] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1399:1392] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1399:1392] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1407:1400] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1407:1400] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1407:1400] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1415:1408] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1415:1408] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1415:1408] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1423:1416] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1423:1416] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1423:1416] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1431:1424] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1431:1424] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1431:1424] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1439:1432] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1439:1432] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1439:1432] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1447:1440] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1447:1440] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1447:1440] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1455:1448] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1455:1448] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1455:1448] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1463:1456] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1463:1456] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1463:1456] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1471:1464] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1471:1464] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1471:1464] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1479:1472] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1479:1472] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1479:1472] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1487:1480] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1487:1480] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1487:1480] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1495:1488] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1495:1488] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1495:1488] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1503:1496] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1503:1496] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1503:1496] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1511:1504] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1511:1504] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1511:1504] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1519:1512] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1519:1512] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1519:1512] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1527:1520] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1527:1520] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1527:1520] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1535:1528] <= 'd0;
  else if (current_state==ST_GAUSSIAN_2)
    blur_din[1535:1528] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1535:1528] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1543:1536] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1543:1536] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1543:1536] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1551:1544] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1551:1544] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1551:1544] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1559:1552] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1559:1552] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1559:1552] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1567:1560] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1567:1560] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1567:1560] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1575:1568] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1575:1568] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1575:1568] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1583:1576] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1583:1576] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1583:1576] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1591:1584] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1591:1584] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1591:1584] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1599:1592] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1599:1592] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1599:1592] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1607:1600] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1607:1600] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1607:1600] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1615:1608] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1615:1608] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1615:1608] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1623:1616] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1623:1616] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1623:1616] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1631:1624] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1631:1624] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1631:1624] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1639:1632] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1639:1632] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1639:1632] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1647:1640] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1647:1640] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1647:1640] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1655:1648] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1655:1648] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1655:1648] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1663:1656] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1663:1656] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1663:1656] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1671:1664] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1671:1664] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1671:1664] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1679:1672] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1679:1672] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1679:1672] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1687:1680] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1687:1680] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1687:1680] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1695:1688] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1695:1688] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1695:1688] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1703:1696] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1703:1696] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1703:1696] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1711:1704] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1711:1704] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1711:1704] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1719:1712] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1719:1712] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1719:1712] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1727:1720] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1727:1720] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1727:1720] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1735:1728] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1735:1728] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1735:1728] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1743:1736] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1743:1736] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1743:1736] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1751:1744] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1751:1744] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1751:1744] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1759:1752] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1759:1752] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1759:1752] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1767:1760] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1767:1760] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1767:1760] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1775:1768] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1775:1768] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1775:1768] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1783:1776] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1783:1776] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1783:1776] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1791:1784] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1791:1784] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1791:1784] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1799:1792] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1799:1792] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1799:1792] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1807:1800] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1807:1800] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1807:1800] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1815:1808] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1815:1808] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1815:1808] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1823:1816] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1823:1816] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1823:1816] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1831:1824] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1831:1824] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1831:1824] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1839:1832] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1839:1832] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1839:1832] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1847:1840] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1847:1840] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1847:1840] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1855:1848] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1855:1848] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1855:1848] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1863:1856] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1863:1856] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1863:1856] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1871:1864] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1871:1864] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1871:1864] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1879:1872] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1879:1872] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1879:1872] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1887:1880] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1887:1880] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1887:1880] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1895:1888] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1895:1888] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1895:1888] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1903:1896] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1903:1896] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1903:1896] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1911:1904] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1911:1904] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1911:1904] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1919:1912] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1919:1912] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1919:1912] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1927:1920] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1927:1920] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1927:1920] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1935:1928] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1935:1928] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1935:1928] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1943:1936] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1943:1936] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1943:1936] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1951:1944] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1951:1944] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1951:1944] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1959:1952] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1959:1952] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1959:1952] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1967:1960] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1967:1960] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1967:1960] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1975:1968] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1975:1968] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1975:1968] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1983:1976] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1983:1976] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1983:1976] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1991:1984] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1991:1984] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1991:1984] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[1999:1992] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[1999:1992] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[1999:1992] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2007:2000] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[2007:2000] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2007:2000] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2015:2008] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[2015:2008] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2015:2008] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2023:2016] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[2023:2016] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2023:2016] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2031:2024] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[2031:2024] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2031:2024] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2039:2032] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[2039:2032] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2039:2032] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2047:2040] <= 'd0;
  else if (current_state==ST_GAUSSIAN_3)
    blur_din[2047:2040] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2047:2040] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2055:2048] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2055:2048] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2055:2048] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2063:2056] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2063:2056] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2063:2056] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2071:2064] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2071:2064] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2071:2064] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2079:2072] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2079:2072] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2079:2072] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2087:2080] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2087:2080] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2087:2080] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2095:2088] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2095:2088] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2095:2088] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2103:2096] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2103:2096] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2103:2096] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2111:2104] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2111:2104] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2111:2104] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2119:2112] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2119:2112] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2119:2112] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2127:2120] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2127:2120] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2127:2120] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2135:2128] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2135:2128] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2135:2128] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2143:2136] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2143:2136] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2143:2136] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2151:2144] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2151:2144] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2151:2144] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2159:2152] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2159:2152] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2159:2152] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2167:2160] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2167:2160] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2167:2160] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2175:2168] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2175:2168] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2175:2168] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2183:2176] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2183:2176] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2183:2176] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2191:2184] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2191:2184] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2191:2184] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2199:2192] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2199:2192] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2199:2192] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2207:2200] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2207:2200] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2207:2200] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2215:2208] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2215:2208] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2215:2208] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2223:2216] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2223:2216] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2223:2216] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2231:2224] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2231:2224] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2231:2224] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2239:2232] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2239:2232] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2239:2232] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2247:2240] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2247:2240] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2247:2240] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2255:2248] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2255:2248] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2255:2248] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2263:2256] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2263:2256] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2263:2256] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2271:2264] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2271:2264] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2271:2264] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2279:2272] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2279:2272] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2279:2272] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2287:2280] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2287:2280] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2287:2280] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2295:2288] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2295:2288] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2295:2288] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2303:2296] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2303:2296] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2303:2296] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2311:2304] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2311:2304] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2311:2304] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2319:2312] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2319:2312] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2319:2312] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2327:2320] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2327:2320] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2327:2320] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2335:2328] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2335:2328] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2335:2328] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2343:2336] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2343:2336] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2343:2336] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2351:2344] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2351:2344] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2351:2344] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2359:2352] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2359:2352] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2359:2352] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2367:2360] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2367:2360] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2367:2360] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2375:2368] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2375:2368] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2375:2368] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2383:2376] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2383:2376] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2383:2376] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2391:2384] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2391:2384] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2391:2384] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2399:2392] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2399:2392] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2399:2392] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2407:2400] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2407:2400] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2407:2400] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2415:2408] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2415:2408] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2415:2408] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2423:2416] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2423:2416] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2423:2416] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2431:2424] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2431:2424] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2431:2424] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2439:2432] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2439:2432] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2439:2432] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2447:2440] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2447:2440] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2447:2440] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2455:2448] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2455:2448] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2455:2448] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2463:2456] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2463:2456] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2463:2456] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2471:2464] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2471:2464] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2471:2464] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2479:2472] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2479:2472] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2479:2472] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2487:2480] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2487:2480] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2487:2480] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2495:2488] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2495:2488] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2495:2488] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2503:2496] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2503:2496] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2503:2496] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2511:2504] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2511:2504] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2511:2504] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2519:2512] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2519:2512] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2519:2512] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2527:2520] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2527:2520] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2527:2520] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2535:2528] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2535:2528] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2535:2528] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2543:2536] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2543:2536] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2543:2536] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2551:2544] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2551:2544] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2551:2544] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2559:2552] <= 'd0;
  else if (current_state==ST_GAUSSIAN_4)
    blur_din[2559:2552] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2559:2552] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2567:2560] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2567:2560] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2567:2560] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2575:2568] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2575:2568] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2575:2568] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2583:2576] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2583:2576] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2583:2576] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2591:2584] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2591:2584] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2591:2584] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2599:2592] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2599:2592] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2599:2592] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2607:2600] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2607:2600] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2607:2600] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2615:2608] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2615:2608] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2615:2608] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2623:2616] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2623:2616] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2623:2616] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2631:2624] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2631:2624] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2631:2624] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2639:2632] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2639:2632] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2639:2632] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2647:2640] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2647:2640] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2647:2640] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2655:2648] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2655:2648] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2655:2648] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2663:2656] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2663:2656] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2663:2656] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2671:2664] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2671:2664] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2671:2664] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2679:2672] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2679:2672] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2679:2672] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2687:2680] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2687:2680] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2687:2680] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2695:2688] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2695:2688] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2695:2688] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2703:2696] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2703:2696] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2703:2696] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2711:2704] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2711:2704] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2711:2704] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2719:2712] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2719:2712] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2719:2712] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2727:2720] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2727:2720] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2727:2720] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2735:2728] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2735:2728] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2735:2728] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2743:2736] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2743:2736] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2743:2736] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2751:2744] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2751:2744] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2751:2744] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2759:2752] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2759:2752] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2759:2752] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2767:2760] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2767:2760] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2767:2760] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2775:2768] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2775:2768] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2775:2768] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2783:2776] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2783:2776] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2783:2776] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2791:2784] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2791:2784] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2791:2784] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2799:2792] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2799:2792] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2799:2792] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2807:2800] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2807:2800] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2807:2800] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2815:2808] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2815:2808] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2815:2808] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2823:2816] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2823:2816] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2823:2816] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2831:2824] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2831:2824] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2831:2824] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2839:2832] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2839:2832] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2839:2832] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2847:2840] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2847:2840] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2847:2840] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2855:2848] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2855:2848] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2855:2848] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2863:2856] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2863:2856] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2863:2856] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2871:2864] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2871:2864] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2871:2864] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2879:2872] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2879:2872] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2879:2872] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2887:2880] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2887:2880] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2887:2880] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2895:2888] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2895:2888] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2895:2888] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2903:2896] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2903:2896] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2903:2896] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2911:2904] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2911:2904] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2911:2904] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2919:2912] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2919:2912] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2919:2912] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2927:2920] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2927:2920] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2927:2920] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2935:2928] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2935:2928] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2935:2928] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2943:2936] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2943:2936] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2943:2936] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2951:2944] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2951:2944] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2951:2944] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2959:2952] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2959:2952] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2959:2952] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2967:2960] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2967:2960] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2967:2960] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2975:2968] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2975:2968] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2975:2968] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2983:2976] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2983:2976] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2983:2976] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2991:2984] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2991:2984] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2991:2984] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[2999:2992] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[2999:2992] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[2999:2992] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3007:3000] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3007:3000] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3007:3000] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3015:3008] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3015:3008] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3015:3008] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3023:3016] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3023:3016] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3023:3016] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3031:3024] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3031:3024] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3031:3024] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3039:3032] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3039:3032] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3039:3032] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3047:3040] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3047:3040] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3047:3040] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3055:3048] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3055:3048] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3055:3048] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3063:3056] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3063:3056] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3063:3056] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3071:3064] <= 'd0;
  else if (current_state==ST_GAUSSIAN_5)
    blur_din[3071:3064] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3071:3064] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3079:3072] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3079:3072] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3079:3072] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3087:3080] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3087:3080] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3087:3080] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3095:3088] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3095:3088] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3095:3088] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3103:3096] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3103:3096] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3103:3096] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3111:3104] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3111:3104] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3111:3104] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3119:3112] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3119:3112] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3119:3112] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3127:3120] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3127:3120] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3127:3120] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3135:3128] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3135:3128] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3135:3128] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3143:3136] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3143:3136] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3143:3136] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3151:3144] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3151:3144] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3151:3144] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3159:3152] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3159:3152] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3159:3152] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3167:3160] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3167:3160] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3167:3160] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3175:3168] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3175:3168] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3175:3168] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3183:3176] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3183:3176] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3183:3176] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3191:3184] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3191:3184] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3191:3184] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3199:3192] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3199:3192] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3199:3192] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3207:3200] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3207:3200] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3207:3200] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3215:3208] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3215:3208] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3215:3208] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3223:3216] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3223:3216] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3223:3216] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3231:3224] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3231:3224] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3231:3224] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3239:3232] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3239:3232] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3239:3232] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3247:3240] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3247:3240] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3247:3240] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3255:3248] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3255:3248] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3255:3248] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3263:3256] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3263:3256] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3263:3256] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3271:3264] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3271:3264] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3271:3264] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3279:3272] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3279:3272] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3279:3272] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3287:3280] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3287:3280] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3287:3280] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3295:3288] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3295:3288] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3295:3288] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3303:3296] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3303:3296] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3303:3296] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3311:3304] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3311:3304] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3311:3304] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3319:3312] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3319:3312] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3319:3312] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3327:3320] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3327:3320] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3327:3320] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3335:3328] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3335:3328] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3335:3328] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3343:3336] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3343:3336] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3343:3336] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3351:3344] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3351:3344] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3351:3344] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3359:3352] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3359:3352] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3359:3352] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3367:3360] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3367:3360] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3367:3360] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3375:3368] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3375:3368] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3375:3368] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3383:3376] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3383:3376] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3383:3376] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3391:3384] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3391:3384] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3391:3384] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3399:3392] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3399:3392] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3399:3392] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3407:3400] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3407:3400] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3407:3400] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3415:3408] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3415:3408] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3415:3408] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3423:3416] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3423:3416] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3423:3416] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3431:3424] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3431:3424] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3431:3424] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3439:3432] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3439:3432] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3439:3432] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3447:3440] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3447:3440] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3447:3440] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3455:3448] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3455:3448] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3455:3448] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3463:3456] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3463:3456] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3463:3456] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3471:3464] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3471:3464] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3471:3464] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3479:3472] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3479:3472] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3479:3472] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3487:3480] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3487:3480] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3487:3480] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3495:3488] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3495:3488] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3495:3488] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3503:3496] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3503:3496] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3503:3496] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3511:3504] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3511:3504] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3511:3504] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3519:3512] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3519:3512] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3519:3512] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3527:3520] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3527:3520] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3527:3520] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3535:3528] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3535:3528] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3535:3528] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3543:3536] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3543:3536] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3543:3536] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3551:3544] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3551:3544] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3551:3544] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3559:3552] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3559:3552] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3559:3552] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3567:3560] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3567:3560] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3567:3560] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3575:3568] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3575:3568] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3575:3568] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3583:3576] <= 'd0;
  else if (current_state==ST_GAUSSIAN_6)
    blur_din[3583:3576] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3583:3576] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3591:3584] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3591:3584] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3591:3584] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3599:3592] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3599:3592] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3599:3592] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3607:3600] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3607:3600] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3607:3600] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3615:3608] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3615:3608] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3615:3608] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3623:3616] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3623:3616] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3623:3616] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3631:3624] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3631:3624] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3631:3624] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3639:3632] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3639:3632] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3639:3632] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3647:3640] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3647:3640] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3647:3640] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3655:3648] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3655:3648] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3655:3648] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3663:3656] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3663:3656] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3663:3656] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3671:3664] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3671:3664] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3671:3664] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3679:3672] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3679:3672] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3679:3672] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3687:3680] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3687:3680] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3687:3680] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3695:3688] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3695:3688] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3695:3688] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3703:3696] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3703:3696] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3703:3696] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3711:3704] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3711:3704] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3711:3704] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3719:3712] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3719:3712] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3719:3712] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3727:3720] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3727:3720] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3727:3720] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3735:3728] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3735:3728] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3735:3728] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3743:3736] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3743:3736] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3743:3736] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3751:3744] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3751:3744] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3751:3744] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3759:3752] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3759:3752] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3759:3752] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3767:3760] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3767:3760] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3767:3760] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3775:3768] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3775:3768] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3775:3768] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3783:3776] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3783:3776] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3783:3776] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3791:3784] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3791:3784] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3791:3784] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3799:3792] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3799:3792] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3799:3792] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3807:3800] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3807:3800] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3807:3800] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3815:3808] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3815:3808] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3815:3808] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3823:3816] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3823:3816] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3823:3816] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3831:3824] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3831:3824] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3831:3824] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3839:3832] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3839:3832] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3839:3832] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3847:3840] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3847:3840] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3847:3840] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3855:3848] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3855:3848] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3855:3848] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3863:3856] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3863:3856] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3863:3856] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3871:3864] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3871:3864] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3871:3864] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3879:3872] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3879:3872] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3879:3872] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3887:3880] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3887:3880] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3887:3880] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3895:3888] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3895:3888] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3895:3888] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3903:3896] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3903:3896] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3903:3896] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3911:3904] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3911:3904] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3911:3904] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3919:3912] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3919:3912] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3919:3912] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3927:3920] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3927:3920] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3927:3920] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3935:3928] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3935:3928] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3935:3928] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3943:3936] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3943:3936] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3943:3936] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3951:3944] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3951:3944] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3951:3944] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3959:3952] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3959:3952] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3959:3952] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3967:3960] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3967:3960] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3967:3960] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3975:3968] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3975:3968] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3975:3968] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3983:3976] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3983:3976] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3983:3976] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3991:3984] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3991:3984] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3991:3984] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[3999:3992] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[3999:3992] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[3999:3992] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4007:4000] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4007:4000] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4007:4000] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4015:4008] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4015:4008] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4015:4008] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4023:4016] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4023:4016] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4023:4016] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4031:4024] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4031:4024] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4031:4024] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4039:4032] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4039:4032] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4039:4032] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4047:4040] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4047:4040] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4047:4040] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4055:4048] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4055:4048] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4055:4048] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4063:4056] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4063:4056] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4063:4056] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4071:4064] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4071:4064] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4071:4064] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4079:4072] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4079:4072] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4079:4072] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4087:4080] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4087:4080] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4087:4080] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4095:4088] <= 'd0;
  else if (current_state==ST_GAUSSIAN_7)
    blur_din[4095:4088] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4095:4088] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4103:4096] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4103:4096] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4103:4096] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4111:4104] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4111:4104] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4111:4104] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4119:4112] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4119:4112] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4119:4112] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4127:4120] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4127:4120] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4127:4120] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4135:4128] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4135:4128] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4135:4128] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4143:4136] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4143:4136] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4143:4136] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4151:4144] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4151:4144] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4151:4144] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4159:4152] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4159:4152] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4159:4152] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4167:4160] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4167:4160] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4167:4160] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4175:4168] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4175:4168] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4175:4168] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4183:4176] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4183:4176] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4183:4176] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4191:4184] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4191:4184] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4191:4184] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4199:4192] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4199:4192] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4199:4192] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4207:4200] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4207:4200] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4207:4200] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4215:4208] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4215:4208] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4215:4208] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4223:4216] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4223:4216] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4223:4216] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4231:4224] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4231:4224] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4231:4224] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4239:4232] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4239:4232] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4239:4232] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4247:4240] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4247:4240] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4247:4240] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4255:4248] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4255:4248] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4255:4248] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4263:4256] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4263:4256] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4263:4256] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4271:4264] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4271:4264] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4271:4264] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4279:4272] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4279:4272] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4279:4272] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4287:4280] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4287:4280] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4287:4280] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4295:4288] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4295:4288] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4295:4288] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4303:4296] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4303:4296] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4303:4296] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4311:4304] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4311:4304] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4311:4304] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4319:4312] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4319:4312] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4319:4312] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4327:4320] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4327:4320] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4327:4320] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4335:4328] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4335:4328] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4335:4328] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4343:4336] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4343:4336] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4343:4336] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4351:4344] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4351:4344] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4351:4344] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4359:4352] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4359:4352] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4359:4352] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4367:4360] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4367:4360] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4367:4360] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4375:4368] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4375:4368] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4375:4368] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4383:4376] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4383:4376] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4383:4376] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4391:4384] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4391:4384] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4391:4384] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4399:4392] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4399:4392] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4399:4392] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4407:4400] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4407:4400] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4407:4400] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4415:4408] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4415:4408] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4415:4408] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4423:4416] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4423:4416] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4423:4416] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4431:4424] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4431:4424] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4431:4424] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4439:4432] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4439:4432] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4439:4432] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4447:4440] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4447:4440] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4447:4440] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4455:4448] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4455:4448] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4455:4448] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4463:4456] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4463:4456] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4463:4456] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4471:4464] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4471:4464] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4471:4464] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4479:4472] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4479:4472] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4479:4472] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4487:4480] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4487:4480] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4487:4480] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4495:4488] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4495:4488] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4495:4488] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4503:4496] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4503:4496] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4503:4496] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4511:4504] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4511:4504] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4511:4504] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4519:4512] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4519:4512] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4519:4512] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4527:4520] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4527:4520] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4527:4520] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4535:4528] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4535:4528] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4535:4528] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4543:4536] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4543:4536] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4543:4536] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4551:4544] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4551:4544] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4551:4544] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4559:4552] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4559:4552] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4559:4552] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4567:4560] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4567:4560] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4567:4560] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4575:4568] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4575:4568] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4575:4568] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4583:4576] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4583:4576] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4583:4576] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4591:4584] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4591:4584] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4591:4584] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4599:4592] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4599:4592] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4599:4592] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4607:4600] <= 'd0;
  else if (current_state==ST_GAUSSIAN_8)
    blur_din[4607:4600] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4607:4600] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4615:4608] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4615:4608] <= kernel_img_sum_0[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4615:4608] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4623:4616] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4623:4616] <= kernel_img_sum_1[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4623:4616] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4631:4624] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4631:4624] <= kernel_img_sum_2[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4631:4624] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4639:4632] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4639:4632] <= kernel_img_sum_3[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4639:4632] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4647:4640] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4647:4640] <= kernel_img_sum_4[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4647:4640] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4655:4648] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4655:4648] <= kernel_img_sum_5[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4655:4648] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4663:4656] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4663:4656] <= kernel_img_sum_6[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4663:4656] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4671:4664] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4671:4664] <= kernel_img_sum_7[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4671:4664] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4679:4672] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4679:4672] <= kernel_img_sum_8[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4679:4672] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4687:4680] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4687:4680] <= kernel_img_sum_9[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4687:4680] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4695:4688] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4695:4688] <= kernel_img_sum_10[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4695:4688] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4703:4696] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4703:4696] <= kernel_img_sum_11[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4703:4696] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4711:4704] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4711:4704] <= kernel_img_sum_12[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4711:4704] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4719:4712] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4719:4712] <= kernel_img_sum_13[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4719:4712] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4727:4720] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4727:4720] <= kernel_img_sum_14[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4727:4720] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4735:4728] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4735:4728] <= kernel_img_sum_15[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4735:4728] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4743:4736] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4743:4736] <= kernel_img_sum_16[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4743:4736] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4751:4744] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4751:4744] <= kernel_img_sum_17[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4751:4744] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4759:4752] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4759:4752] <= kernel_img_sum_18[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4759:4752] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4767:4760] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4767:4760] <= kernel_img_sum_19[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4767:4760] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4775:4768] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4775:4768] <= kernel_img_sum_20[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4775:4768] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4783:4776] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4783:4776] <= kernel_img_sum_21[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4783:4776] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4791:4784] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4791:4784] <= kernel_img_sum_22[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4791:4784] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4799:4792] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4799:4792] <= kernel_img_sum_23[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4799:4792] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4807:4800] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4807:4800] <= kernel_img_sum_24[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4807:4800] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4815:4808] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4815:4808] <= kernel_img_sum_25[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4815:4808] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4823:4816] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4823:4816] <= kernel_img_sum_26[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4823:4816] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4831:4824] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4831:4824] <= kernel_img_sum_27[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4831:4824] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4839:4832] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4839:4832] <= kernel_img_sum_28[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4839:4832] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4847:4840] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4847:4840] <= kernel_img_sum_29[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4847:4840] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4855:4848] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4855:4848] <= kernel_img_sum_30[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4855:4848] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4863:4856] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4863:4856] <= kernel_img_sum_31[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4863:4856] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4871:4864] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4871:4864] <= kernel_img_sum_32[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4871:4864] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4879:4872] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4879:4872] <= kernel_img_sum_33[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4879:4872] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4887:4880] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4887:4880] <= kernel_img_sum_34[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4887:4880] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4895:4888] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4895:4888] <= kernel_img_sum_35[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4895:4888] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4903:4896] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4903:4896] <= kernel_img_sum_36[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4903:4896] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4911:4904] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4911:4904] <= kernel_img_sum_37[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4911:4904] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4919:4912] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4919:4912] <= kernel_img_sum_38[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4919:4912] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4927:4920] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4927:4920] <= kernel_img_sum_39[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4927:4920] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4935:4928] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4935:4928] <= kernel_img_sum_40[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4935:4928] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4943:4936] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4943:4936] <= kernel_img_sum_41[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4943:4936] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4951:4944] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4951:4944] <= kernel_img_sum_42[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4951:4944] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4959:4952] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4959:4952] <= kernel_img_sum_43[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4959:4952] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4967:4960] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4967:4960] <= kernel_img_sum_44[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4967:4960] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4975:4968] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4975:4968] <= kernel_img_sum_45[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4975:4968] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4983:4976] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4983:4976] <= kernel_img_sum_46[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4983:4976] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4991:4984] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4991:4984] <= kernel_img_sum_47[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4991:4984] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[4999:4992] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[4999:4992] <= kernel_img_sum_48[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[4999:4992] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5007:5000] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5007:5000] <= kernel_img_sum_49[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5007:5000] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5015:5008] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5015:5008] <= kernel_img_sum_50[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5015:5008] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5023:5016] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5023:5016] <= kernel_img_sum_51[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5023:5016] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5031:5024] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5031:5024] <= kernel_img_sum_52[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5031:5024] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5039:5032] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5039:5032] <= kernel_img_sum_53[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5039:5032] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5047:5040] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5047:5040] <= kernel_img_sum_54[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5047:5040] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5055:5048] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5055:5048] <= kernel_img_sum_55[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5055:5048] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5063:5056] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5063:5056] <= kernel_img_sum_56[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5063:5056] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5071:5064] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5071:5064] <= kernel_img_sum_57[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5071:5064] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5079:5072] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5079:5072] <= kernel_img_sum_58[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5079:5072] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5087:5080] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5087:5080] <= kernel_img_sum_59[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5087:5080] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5095:5088] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5095:5088] <= kernel_img_sum_60[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5095:5088] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5103:5096] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5103:5096] <= kernel_img_sum_61[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5103:5096] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5111:5104] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5111:5104] <= kernel_img_sum_62[39:32];/*Q8.32 -> Q8.0*/
  else if (current_state==ST_IDLE)
    blur_din[5111:5104] <= 'd0;
end

always @(posedge clk) begin
  if (!rst_n)
    blur_din[5119:5112] <= 'd0;
  else if (current_state==ST_GAUSSIAN_9)
    blur_din[5119:5112] <= kernel_img_sum_63[39:32];/*Q8.32 -> Q8.0*/
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