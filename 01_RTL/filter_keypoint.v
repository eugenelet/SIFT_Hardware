module filter_keypoint(
  current_col,
  top_row,
  mid_row,
  btm_row,
  valid_keypoint,
  filter_threshold
);

input[175:0]      top_row;
input[175:0]      mid_row;
input[175:0]      btm_row;
input[9:0]        current_col;
input signed[9:0] filter_threshold;   

output          valid_keypoint;

reg signed[8:0] top[0:2],
                mid[0:2],
                btm[0:2];


wire signed [8:0] top_0 = top[0];
wire signed [8:0] top_1 = top[1];
wire signed [8:0] top_2 = top[2];
wire signed [8:0] mid_0 = mid[0];
wire signed [8:0] mid_1 = mid[1];
wire signed [8:0] mid_2 = mid[2];
wire signed [8:0] btm_0 = btm[0];
wire signed [8:0] btm_1 = btm[1];
wire signed [8:0] btm_2 = btm[2];

always@(*) begin
  case(current_col)
    'd8: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd9: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd10: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd11: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd12: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd13: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd14: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd15: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd16: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd17: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd18: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd19: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd20: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd21: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd22: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd23: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd24: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd25: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd26: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd27: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd28: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd29: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd30: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd31: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd32: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd33: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd34: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd35: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd36: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd37: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd38: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd39: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd40: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd41: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd42: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd43: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd44: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd45: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd46: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd47: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd48: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd49: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd50: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd51: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd52: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd53: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd54: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd55: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd56: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd57: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd58: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd59: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd60: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd61: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd62: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd63: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd64: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd65: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd66: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd67: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd68: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd69: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd70: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd71: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd72: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd73: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd74: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd75: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd76: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd77: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd78: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd79: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd80: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd81: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd82: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd83: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd84: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd85: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd86: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd87: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd88: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd89: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd90: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd91: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd92: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd93: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd94: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd95: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd96: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd97: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd98: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd99: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd100: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd101: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd102: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd103: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd104: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd105: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd106: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd107: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd108: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd109: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd110: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd111: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd112: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd113: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd114: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd115: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd116: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd117: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd118: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd119: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd120: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd121: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd122: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd123: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd124: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd125: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd126: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd127: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd128: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd129: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd130: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd131: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd132: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd133: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd134: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd135: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd136: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd137: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd138: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd139: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd140: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd141: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd142: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd143: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd144: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd145: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd146: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd147: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd148: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd149: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd150: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd151: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd152: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd153: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd154: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd155: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd156: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd157: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd158: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd159: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd160: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd161: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd162: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd163: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd164: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd165: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd166: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd167: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd168: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd169: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd170: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd171: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd172: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd173: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd174: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd175: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd176: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd177: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd178: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd179: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd180: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd181: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd182: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd183: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd184: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd185: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd186: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd187: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd188: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd189: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd190: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd191: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd192: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd193: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd194: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd195: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd196: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd197: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd198: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd199: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd200: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd201: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd202: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd203: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd204: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd205: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd206: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd207: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd208: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd209: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd210: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd211: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd212: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd213: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd214: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd215: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd216: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd217: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd218: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd219: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd220: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd221: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd222: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd223: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd224: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd225: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd226: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd227: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd228: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd229: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd230: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd231: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd232: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd233: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd234: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd235: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd236: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd237: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd238: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd239: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd240: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd241: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd242: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd243: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd244: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd245: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd246: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd247: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd248: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd249: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd250: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd251: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd252: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd253: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd254: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd255: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd256: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd257: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd258: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd259: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd260: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd261: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd262: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd263: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd264: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd265: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd266: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd267: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd268: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd269: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd270: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd271: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd272: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd273: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd274: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd275: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd276: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd277: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd278: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd279: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd280: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd281: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd282: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd283: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd284: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd285: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd286: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd287: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd288: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd289: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd290: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd291: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd292: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd293: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd294: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd295: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd296: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd297: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd298: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd299: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd300: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd301: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd302: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd303: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd304: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd305: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd306: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd307: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd308: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd309: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd310: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd311: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd312: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd313: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd314: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd315: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd316: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd317: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd318: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd319: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd320: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd321: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd322: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd323: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd324: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd325: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd326: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd327: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd328: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd329: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd330: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd331: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd332: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd333: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd334: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd335: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd336: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd337: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd338: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd339: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd340: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd341: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd342: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd343: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd344: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd345: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd346: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd347: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd348: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd349: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd350: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd351: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd352: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd353: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd354: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd355: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd356: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd357: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd358: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd359: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd360: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd361: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd362: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd363: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd364: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd365: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd366: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd367: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd368: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd369: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd370: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd371: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd372: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd373: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd374: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd375: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd376: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd377: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd378: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd379: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd380: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd381: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd382: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd383: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd384: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd385: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd386: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd387: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd388: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd389: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd390: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd391: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd392: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd393: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd394: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd395: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd396: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd397: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd398: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd399: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd400: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd401: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd402: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd403: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd404: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd405: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd406: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd407: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd408: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd409: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd410: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd411: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd412: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd413: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd414: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd415: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd416: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd417: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd418: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd419: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd420: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd421: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd422: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd423: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd424: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd425: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd426: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd427: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd428: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd429: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd430: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd431: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd432: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd433: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd434: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd435: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd436: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd437: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd438: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd439: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd440: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd441: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd442: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd443: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd444: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd445: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd446: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd447: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd448: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd449: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd450: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd451: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd452: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd453: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd454: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd455: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd456: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd457: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd458: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd459: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd460: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd461: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd462: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd463: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd464: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd465: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd466: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd467: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd468: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd469: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd470: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd471: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd472: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd473: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd474: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd475: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd476: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd477: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd478: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd479: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd480: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd481: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd482: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd483: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd484: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd485: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd486: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd487: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd488: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd489: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd490: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd491: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd492: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd493: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd494: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd495: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd496: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd497: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd498: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd499: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd500: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd501: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd502: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd503: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd504: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd505: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd506: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd507: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd508: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd509: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd510: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd511: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd512: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd513: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd514: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd515: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd516: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd517: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd518: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd519: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd520: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd521: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd522: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd523: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd524: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd525: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd526: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd527: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd528: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd529: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd530: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd531: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd532: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd533: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd534: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd535: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd536: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd537: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd538: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd539: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd540: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd541: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd542: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd543: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd544: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd545: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd546: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd547: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd548: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd549: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd550: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd551: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd552: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd553: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd554: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd555: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd556: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd557: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd558: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd559: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd560: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd561: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd562: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd563: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd564: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd565: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd566: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd567: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd568: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd569: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd570: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd571: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd572: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd573: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd574: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd575: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd576: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd577: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd578: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd579: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd580: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd581: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd582: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd583: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd584: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd585: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd586: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd587: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd588: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd589: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd590: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd591: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd592: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd593: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd594: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd595: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd596: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd597: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd598: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd599: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd600: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd601: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd602: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd603: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd604: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd605: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd606: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd607: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd608: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd609: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd610: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd611: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd612: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd613: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd614: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd615: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    'd616: begin
      top[0] = top_row[87:80];
      top[1] = top_row[95:88];
      top[2] = top_row[103:96];
      mid[0] = mid_row[87:80];
      mid[1] = mid_row[95:88];
      mid[2] = mid_row[103:96];
      btm[0] = btm_row[87:80];
      btm[1] = btm_row[95:88];
      btm[2] = btm_row[103:96];
    end
    'd617: begin
      top[0] = top_row[95:88];
      top[1] = top_row[103:96];
      top[2] = top_row[111:104];
      mid[0] = mid_row[95:88];
      mid[1] = mid_row[103:96];
      mid[2] = mid_row[111:104];
      btm[0] = btm_row[95:88];
      btm[1] = btm_row[103:96];
      btm[2] = btm_row[111:104];
    end
    'd618: begin
      top[0] = top_row[103:96];
      top[1] = top_row[111:104];
      top[2] = top_row[119:112];
      mid[0] = mid_row[103:96];
      mid[1] = mid_row[111:104];
      mid[2] = mid_row[119:112];
      btm[0] = btm_row[103:96];
      btm[1] = btm_row[111:104];
      btm[2] = btm_row[119:112];
    end
    'd619: begin
      top[0] = top_row[111:104];
      top[1] = top_row[119:112];
      top[2] = top_row[127:120];
      mid[0] = mid_row[111:104];
      mid[1] = mid_row[119:112];
      mid[2] = mid_row[127:120];
      btm[0] = btm_row[111:104];
      btm[1] = btm_row[119:112];
      btm[2] = btm_row[127:120];
    end
    'd620: begin
      top[0] = top_row[119:112];
      top[1] = top_row[127:120];
      top[2] = top_row[135:128];
      mid[0] = mid_row[119:112];
      mid[1] = mid_row[127:120];
      mid[2] = mid_row[135:128];
      btm[0] = btm_row[119:112];
      btm[1] = btm_row[127:120];
      btm[2] = btm_row[135:128];
    end
    'd621: begin
      top[0] = top_row[127:120];
      top[1] = top_row[135:128];
      top[2] = top_row[143:136];
      mid[0] = mid_row[127:120];
      mid[1] = mid_row[135:128];
      mid[2] = mid_row[143:136];
      btm[0] = btm_row[127:120];
      btm[1] = btm_row[135:128];
      btm[2] = btm_row[143:136];
    end
    'd622: begin
      top[0] = top_row[135:128];
      top[1] = top_row[143:136];
      top[2] = top_row[151:144];
      mid[0] = mid_row[135:128];
      mid[1] = mid_row[143:136];
      mid[2] = mid_row[151:144];
      btm[0] = btm_row[135:128];
      btm[1] = btm_row[143:136];
      btm[2] = btm_row[151:144];
    end
    'd623: begin
      top[0] = top_row[143:136];
      top[1] = top_row[151:144];
      top[2] = top_row[159:152];
      mid[0] = mid_row[143:136];
      mid[1] = mid_row[151:144];
      mid[2] = mid_row[159:152];
      btm[0] = btm_row[143:136];
      btm[1] = btm_row[151:144];
      btm[2] = btm_row[159:152];
    end
    'd624: begin
      top[0] = top_row[23:16];
      top[1] = top_row[31:24];
      top[2] = top_row[39:32];
      mid[0] = mid_row[23:16];
      mid[1] = mid_row[31:24];
      mid[2] = mid_row[39:32];
      btm[0] = btm_row[23:16];
      btm[1] = btm_row[31:24];
      btm[2] = btm_row[39:32];
    end
    'd625: begin
      top[0] = top_row[31:24];
      top[1] = top_row[39:32];
      top[2] = top_row[47:40];
      mid[0] = mid_row[31:24];
      mid[1] = mid_row[39:32];
      mid[2] = mid_row[47:40];
      btm[0] = btm_row[31:24];
      btm[1] = btm_row[39:32];
      btm[2] = btm_row[47:40];
    end
    'd626: begin
      top[0] = top_row[39:32];
      top[1] = top_row[47:40];
      top[2] = top_row[55:48];
      mid[0] = mid_row[39:32];
      mid[1] = mid_row[47:40];
      mid[2] = mid_row[55:48];
      btm[0] = btm_row[39:32];
      btm[1] = btm_row[47:40];
      btm[2] = btm_row[55:48];
    end
    'd627: begin
      top[0] = top_row[47:40];
      top[1] = top_row[55:48];
      top[2] = top_row[63:56];
      mid[0] = mid_row[47:40];
      mid[1] = mid_row[55:48];
      mid[2] = mid_row[63:56];
      btm[0] = btm_row[47:40];
      btm[1] = btm_row[55:48];
      btm[2] = btm_row[63:56];
    end
    'd628: begin
      top[0] = top_row[55:48];
      top[1] = top_row[63:56];
      top[2] = top_row[71:64];
      mid[0] = mid_row[55:48];
      mid[1] = mid_row[63:56];
      mid[2] = mid_row[71:64];
      btm[0] = btm_row[55:48];
      btm[1] = btm_row[63:56];
      btm[2] = btm_row[71:64];
    end
    'd629: begin
      top[0] = top_row[63:56];
      top[1] = top_row[71:64];
      top[2] = top_row[79:72];
      mid[0] = mid_row[63:56];
      mid[1] = mid_row[71:64];
      mid[2] = mid_row[79:72];
      btm[0] = btm_row[63:56];
      btm[1] = btm_row[71:64];
      btm[2] = btm_row[79:72];
    end
    'd630: begin
      top[0] = top_row[71:64];
      top[1] = top_row[79:72];
      top[2] = top_row[87:80];
      mid[0] = mid_row[71:64];
      mid[1] = mid_row[79:72];
      mid[2] = mid_row[87:80];
      btm[0] = btm_row[71:64];
      btm[1] = btm_row[79:72];
      btm[2] = btm_row[87:80];
    end
    'd631: begin
      top[0] = top_row[79:72];
      top[1] = top_row[87:80];
      top[2] = top_row[95:88];
      mid[0] = mid_row[79:72];
      mid[1] = mid_row[87:80];
      mid[2] = mid_row[95:88];
      btm[0] = btm_row[79:72];
      btm[1] = btm_row[87:80];
      btm[2] = btm_row[95:88];
    end
    default: begin
      top[0] = 'd0;
      top[1] = 'd0;
      top[2] = 'd0;
      mid[0] = 'd0;
      mid[1] = 'd0;
      mid[2] = 'd0;
      btm[0] = 'd0;
      btm[1] = 'd0;
      btm[2] = 'd0;
    end
  endcase
end



wire  [7:0] brighter;
wire  [7:0] darker;

assign brighter[0] = (top[0] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[1] = (top[1] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[2] = (top[2] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[3] = (mid[2] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[4] = (btm[2] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[5] = (btm[1] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[6] = (btm[0] > (mid[1] + filter_threshold)) ? 1 : 0;
assign brighter[7] = (mid[0] > (mid[1] + filter_threshold)) ? 1 : 0;

assign darker[0] = (top[0] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[1] = (top[1] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[2] = (top[2] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[3] = (mid[2] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[4] = (btm[2] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[5] = (btm[1] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[6] = (btm[0] < (mid[1] - filter_threshold)) ? 1 : 0;
assign darker[7] = (mid[0] < (mid[1] - filter_threshold)) ? 1 : 0;

wire  brighter_valid = (&brighter[3:0] | &brighter[4:1] | &brighter[5:2] | &brighter[6:3] | &brighter[7:4] | &{brighter[7:5], brighter[0]}
                        | &{brighter[7:6], brighter[1:0]} | &{brighter[7], brighter[2:0]}) ? 1:0;


wire  darker_valid = (&darker[3:0] | &darker[4:1] | &darker[5:2] | &darker[6:3] | &darker[7:4] | &{darker[7:5], darker[0]}
                        | &{darker[7:6], darker[1:0]} | &{darker[7], darker[2:0]}) ? 1:0;


assign valid_keypoint = brighter_valid | darker_valid;

endmodule