module filter_keypoint(
  current_col,
  top_row,
  mid_row,
  btm_row,
  valid_keypoint,
  filter_threshold
);

input[5119:0]     top_row;
input[5119:0]     mid_row;
input[5119:0]     btm_row;
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
    'd1: begin
      top[0] = top_row[7:0];
      top[1] = top_row[15:8];
      top[2] = top_row[23:16];
      mid[0] = mid_row[7:0];
      mid[1] = mid_row[15:8];
      mid[2] = mid_row[23:16];
      btm[0] = btm_row[7:0];
      btm[1] = btm_row[15:8];
      btm[2] = btm_row[23:16];
    end
    'd2: begin
      top[0] = top_row[15:8];
      top[1] = top_row[23:16];
      top[2] = top_row[31:24];
      mid[0] = mid_row[15:8];
      mid[1] = mid_row[23:16];
      mid[2] = mid_row[31:24];
      btm[0] = btm_row[15:8];
      btm[1] = btm_row[23:16];
      btm[2] = btm_row[31:24];
    end
    'd3: begin
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
    'd4: begin
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
    'd5: begin
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
    'd6: begin
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
    'd7: begin
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
    'd8: begin
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
    'd9: begin
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
    'd10: begin
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
    'd11: begin
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
    'd12: begin
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
    'd13: begin
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
    'd14: begin
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
    'd15: begin
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
    'd16: begin
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
    'd17: begin
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
    'd18: begin
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
    'd19: begin
      top[0] = top_row[151:144];
      top[1] = top_row[159:152];
      top[2] = top_row[167:160];
      mid[0] = mid_row[151:144];
      mid[1] = mid_row[159:152];
      mid[2] = mid_row[167:160];
      btm[0] = btm_row[151:144];
      btm[1] = btm_row[159:152];
      btm[2] = btm_row[167:160];
    end
    'd20: begin
      top[0] = top_row[159:152];
      top[1] = top_row[167:160];
      top[2] = top_row[175:168];
      mid[0] = mid_row[159:152];
      mid[1] = mid_row[167:160];
      mid[2] = mid_row[175:168];
      btm[0] = btm_row[159:152];
      btm[1] = btm_row[167:160];
      btm[2] = btm_row[175:168];
    end
    'd21: begin
      top[0] = top_row[167:160];
      top[1] = top_row[175:168];
      top[2] = top_row[183:176];
      mid[0] = mid_row[167:160];
      mid[1] = mid_row[175:168];
      mid[2] = mid_row[183:176];
      btm[0] = btm_row[167:160];
      btm[1] = btm_row[175:168];
      btm[2] = btm_row[183:176];
    end
    'd22: begin
      top[0] = top_row[175:168];
      top[1] = top_row[183:176];
      top[2] = top_row[191:184];
      mid[0] = mid_row[175:168];
      mid[1] = mid_row[183:176];
      mid[2] = mid_row[191:184];
      btm[0] = btm_row[175:168];
      btm[1] = btm_row[183:176];
      btm[2] = btm_row[191:184];
    end
    'd23: begin
      top[0] = top_row[183:176];
      top[1] = top_row[191:184];
      top[2] = top_row[199:192];
      mid[0] = mid_row[183:176];
      mid[1] = mid_row[191:184];
      mid[2] = mid_row[199:192];
      btm[0] = btm_row[183:176];
      btm[1] = btm_row[191:184];
      btm[2] = btm_row[199:192];
    end
    'd24: begin
      top[0] = top_row[191:184];
      top[1] = top_row[199:192];
      top[2] = top_row[207:200];
      mid[0] = mid_row[191:184];
      mid[1] = mid_row[199:192];
      mid[2] = mid_row[207:200];
      btm[0] = btm_row[191:184];
      btm[1] = btm_row[199:192];
      btm[2] = btm_row[207:200];
    end
    'd25: begin
      top[0] = top_row[199:192];
      top[1] = top_row[207:200];
      top[2] = top_row[215:208];
      mid[0] = mid_row[199:192];
      mid[1] = mid_row[207:200];
      mid[2] = mid_row[215:208];
      btm[0] = btm_row[199:192];
      btm[1] = btm_row[207:200];
      btm[2] = btm_row[215:208];
    end
    'd26: begin
      top[0] = top_row[207:200];
      top[1] = top_row[215:208];
      top[2] = top_row[223:216];
      mid[0] = mid_row[207:200];
      mid[1] = mid_row[215:208];
      mid[2] = mid_row[223:216];
      btm[0] = btm_row[207:200];
      btm[1] = btm_row[215:208];
      btm[2] = btm_row[223:216];
    end
    'd27: begin
      top[0] = top_row[215:208];
      top[1] = top_row[223:216];
      top[2] = top_row[231:224];
      mid[0] = mid_row[215:208];
      mid[1] = mid_row[223:216];
      mid[2] = mid_row[231:224];
      btm[0] = btm_row[215:208];
      btm[1] = btm_row[223:216];
      btm[2] = btm_row[231:224];
    end
    'd28: begin
      top[0] = top_row[223:216];
      top[1] = top_row[231:224];
      top[2] = top_row[239:232];
      mid[0] = mid_row[223:216];
      mid[1] = mid_row[231:224];
      mid[2] = mid_row[239:232];
      btm[0] = btm_row[223:216];
      btm[1] = btm_row[231:224];
      btm[2] = btm_row[239:232];
    end
    'd29: begin
      top[0] = top_row[231:224];
      top[1] = top_row[239:232];
      top[2] = top_row[247:240];
      mid[0] = mid_row[231:224];
      mid[1] = mid_row[239:232];
      mid[2] = mid_row[247:240];
      btm[0] = btm_row[231:224];
      btm[1] = btm_row[239:232];
      btm[2] = btm_row[247:240];
    end
    'd30: begin
      top[0] = top_row[239:232];
      top[1] = top_row[247:240];
      top[2] = top_row[255:248];
      mid[0] = mid_row[239:232];
      mid[1] = mid_row[247:240];
      mid[2] = mid_row[255:248];
      btm[0] = btm_row[239:232];
      btm[1] = btm_row[247:240];
      btm[2] = btm_row[255:248];
    end
    'd31: begin
      top[0] = top_row[247:240];
      top[1] = top_row[255:248];
      top[2] = top_row[263:256];
      mid[0] = mid_row[247:240];
      mid[1] = mid_row[255:248];
      mid[2] = mid_row[263:256];
      btm[0] = btm_row[247:240];
      btm[1] = btm_row[255:248];
      btm[2] = btm_row[263:256];
    end
    'd32: begin
      top[0] = top_row[255:248];
      top[1] = top_row[263:256];
      top[2] = top_row[271:264];
      mid[0] = mid_row[255:248];
      mid[1] = mid_row[263:256];
      mid[2] = mid_row[271:264];
      btm[0] = btm_row[255:248];
      btm[1] = btm_row[263:256];
      btm[2] = btm_row[271:264];
    end
    'd33: begin
      top[0] = top_row[263:256];
      top[1] = top_row[271:264];
      top[2] = top_row[279:272];
      mid[0] = mid_row[263:256];
      mid[1] = mid_row[271:264];
      mid[2] = mid_row[279:272];
      btm[0] = btm_row[263:256];
      btm[1] = btm_row[271:264];
      btm[2] = btm_row[279:272];
    end
    'd34: begin
      top[0] = top_row[271:264];
      top[1] = top_row[279:272];
      top[2] = top_row[287:280];
      mid[0] = mid_row[271:264];
      mid[1] = mid_row[279:272];
      mid[2] = mid_row[287:280];
      btm[0] = btm_row[271:264];
      btm[1] = btm_row[279:272];
      btm[2] = btm_row[287:280];
    end
    'd35: begin
      top[0] = top_row[279:272];
      top[1] = top_row[287:280];
      top[2] = top_row[295:288];
      mid[0] = mid_row[279:272];
      mid[1] = mid_row[287:280];
      mid[2] = mid_row[295:288];
      btm[0] = btm_row[279:272];
      btm[1] = btm_row[287:280];
      btm[2] = btm_row[295:288];
    end
    'd36: begin
      top[0] = top_row[287:280];
      top[1] = top_row[295:288];
      top[2] = top_row[303:296];
      mid[0] = mid_row[287:280];
      mid[1] = mid_row[295:288];
      mid[2] = mid_row[303:296];
      btm[0] = btm_row[287:280];
      btm[1] = btm_row[295:288];
      btm[2] = btm_row[303:296];
    end
    'd37: begin
      top[0] = top_row[295:288];
      top[1] = top_row[303:296];
      top[2] = top_row[311:304];
      mid[0] = mid_row[295:288];
      mid[1] = mid_row[303:296];
      mid[2] = mid_row[311:304];
      btm[0] = btm_row[295:288];
      btm[1] = btm_row[303:296];
      btm[2] = btm_row[311:304];
    end
    'd38: begin
      top[0] = top_row[303:296];
      top[1] = top_row[311:304];
      top[2] = top_row[319:312];
      mid[0] = mid_row[303:296];
      mid[1] = mid_row[311:304];
      mid[2] = mid_row[319:312];
      btm[0] = btm_row[303:296];
      btm[1] = btm_row[311:304];
      btm[2] = btm_row[319:312];
    end
    'd39: begin
      top[0] = top_row[311:304];
      top[1] = top_row[319:312];
      top[2] = top_row[327:320];
      mid[0] = mid_row[311:304];
      mid[1] = mid_row[319:312];
      mid[2] = mid_row[327:320];
      btm[0] = btm_row[311:304];
      btm[1] = btm_row[319:312];
      btm[2] = btm_row[327:320];
    end
    'd40: begin
      top[0] = top_row[319:312];
      top[1] = top_row[327:320];
      top[2] = top_row[335:328];
      mid[0] = mid_row[319:312];
      mid[1] = mid_row[327:320];
      mid[2] = mid_row[335:328];
      btm[0] = btm_row[319:312];
      btm[1] = btm_row[327:320];
      btm[2] = btm_row[335:328];
    end
    'd41: begin
      top[0] = top_row[327:320];
      top[1] = top_row[335:328];
      top[2] = top_row[343:336];
      mid[0] = mid_row[327:320];
      mid[1] = mid_row[335:328];
      mid[2] = mid_row[343:336];
      btm[0] = btm_row[327:320];
      btm[1] = btm_row[335:328];
      btm[2] = btm_row[343:336];
    end
    'd42: begin
      top[0] = top_row[335:328];
      top[1] = top_row[343:336];
      top[2] = top_row[351:344];
      mid[0] = mid_row[335:328];
      mid[1] = mid_row[343:336];
      mid[2] = mid_row[351:344];
      btm[0] = btm_row[335:328];
      btm[1] = btm_row[343:336];
      btm[2] = btm_row[351:344];
    end
    'd43: begin
      top[0] = top_row[343:336];
      top[1] = top_row[351:344];
      top[2] = top_row[359:352];
      mid[0] = mid_row[343:336];
      mid[1] = mid_row[351:344];
      mid[2] = mid_row[359:352];
      btm[0] = btm_row[343:336];
      btm[1] = btm_row[351:344];
      btm[2] = btm_row[359:352];
    end
    'd44: begin
      top[0] = top_row[351:344];
      top[1] = top_row[359:352];
      top[2] = top_row[367:360];
      mid[0] = mid_row[351:344];
      mid[1] = mid_row[359:352];
      mid[2] = mid_row[367:360];
      btm[0] = btm_row[351:344];
      btm[1] = btm_row[359:352];
      btm[2] = btm_row[367:360];
    end
    'd45: begin
      top[0] = top_row[359:352];
      top[1] = top_row[367:360];
      top[2] = top_row[375:368];
      mid[0] = mid_row[359:352];
      mid[1] = mid_row[367:360];
      mid[2] = mid_row[375:368];
      btm[0] = btm_row[359:352];
      btm[1] = btm_row[367:360];
      btm[2] = btm_row[375:368];
    end
    'd46: begin
      top[0] = top_row[367:360];
      top[1] = top_row[375:368];
      top[2] = top_row[383:376];
      mid[0] = mid_row[367:360];
      mid[1] = mid_row[375:368];
      mid[2] = mid_row[383:376];
      btm[0] = btm_row[367:360];
      btm[1] = btm_row[375:368];
      btm[2] = btm_row[383:376];
    end
    'd47: begin
      top[0] = top_row[375:368];
      top[1] = top_row[383:376];
      top[2] = top_row[391:384];
      mid[0] = mid_row[375:368];
      mid[1] = mid_row[383:376];
      mid[2] = mid_row[391:384];
      btm[0] = btm_row[375:368];
      btm[1] = btm_row[383:376];
      btm[2] = btm_row[391:384];
    end
    'd48: begin
      top[0] = top_row[383:376];
      top[1] = top_row[391:384];
      top[2] = top_row[399:392];
      mid[0] = mid_row[383:376];
      mid[1] = mid_row[391:384];
      mid[2] = mid_row[399:392];
      btm[0] = btm_row[383:376];
      btm[1] = btm_row[391:384];
      btm[2] = btm_row[399:392];
    end
    'd49: begin
      top[0] = top_row[391:384];
      top[1] = top_row[399:392];
      top[2] = top_row[407:400];
      mid[0] = mid_row[391:384];
      mid[1] = mid_row[399:392];
      mid[2] = mid_row[407:400];
      btm[0] = btm_row[391:384];
      btm[1] = btm_row[399:392];
      btm[2] = btm_row[407:400];
    end
    'd50: begin
      top[0] = top_row[399:392];
      top[1] = top_row[407:400];
      top[2] = top_row[415:408];
      mid[0] = mid_row[399:392];
      mid[1] = mid_row[407:400];
      mid[2] = mid_row[415:408];
      btm[0] = btm_row[399:392];
      btm[1] = btm_row[407:400];
      btm[2] = btm_row[415:408];
    end
    'd51: begin
      top[0] = top_row[407:400];
      top[1] = top_row[415:408];
      top[2] = top_row[423:416];
      mid[0] = mid_row[407:400];
      mid[1] = mid_row[415:408];
      mid[2] = mid_row[423:416];
      btm[0] = btm_row[407:400];
      btm[1] = btm_row[415:408];
      btm[2] = btm_row[423:416];
    end
    'd52: begin
      top[0] = top_row[415:408];
      top[1] = top_row[423:416];
      top[2] = top_row[431:424];
      mid[0] = mid_row[415:408];
      mid[1] = mid_row[423:416];
      mid[2] = mid_row[431:424];
      btm[0] = btm_row[415:408];
      btm[1] = btm_row[423:416];
      btm[2] = btm_row[431:424];
    end
    'd53: begin
      top[0] = top_row[423:416];
      top[1] = top_row[431:424];
      top[2] = top_row[439:432];
      mid[0] = mid_row[423:416];
      mid[1] = mid_row[431:424];
      mid[2] = mid_row[439:432];
      btm[0] = btm_row[423:416];
      btm[1] = btm_row[431:424];
      btm[2] = btm_row[439:432];
    end
    'd54: begin
      top[0] = top_row[431:424];
      top[1] = top_row[439:432];
      top[2] = top_row[447:440];
      mid[0] = mid_row[431:424];
      mid[1] = mid_row[439:432];
      mid[2] = mid_row[447:440];
      btm[0] = btm_row[431:424];
      btm[1] = btm_row[439:432];
      btm[2] = btm_row[447:440];
    end
    'd55: begin
      top[0] = top_row[439:432];
      top[1] = top_row[447:440];
      top[2] = top_row[455:448];
      mid[0] = mid_row[439:432];
      mid[1] = mid_row[447:440];
      mid[2] = mid_row[455:448];
      btm[0] = btm_row[439:432];
      btm[1] = btm_row[447:440];
      btm[2] = btm_row[455:448];
    end
    'd56: begin
      top[0] = top_row[447:440];
      top[1] = top_row[455:448];
      top[2] = top_row[463:456];
      mid[0] = mid_row[447:440];
      mid[1] = mid_row[455:448];
      mid[2] = mid_row[463:456];
      btm[0] = btm_row[447:440];
      btm[1] = btm_row[455:448];
      btm[2] = btm_row[463:456];
    end
    'd57: begin
      top[0] = top_row[455:448];
      top[1] = top_row[463:456];
      top[2] = top_row[471:464];
      mid[0] = mid_row[455:448];
      mid[1] = mid_row[463:456];
      mid[2] = mid_row[471:464];
      btm[0] = btm_row[455:448];
      btm[1] = btm_row[463:456];
      btm[2] = btm_row[471:464];
    end
    'd58: begin
      top[0] = top_row[463:456];
      top[1] = top_row[471:464];
      top[2] = top_row[479:472];
      mid[0] = mid_row[463:456];
      mid[1] = mid_row[471:464];
      mid[2] = mid_row[479:472];
      btm[0] = btm_row[463:456];
      btm[1] = btm_row[471:464];
      btm[2] = btm_row[479:472];
    end
    'd59: begin
      top[0] = top_row[471:464];
      top[1] = top_row[479:472];
      top[2] = top_row[487:480];
      mid[0] = mid_row[471:464];
      mid[1] = mid_row[479:472];
      mid[2] = mid_row[487:480];
      btm[0] = btm_row[471:464];
      btm[1] = btm_row[479:472];
      btm[2] = btm_row[487:480];
    end
    'd60: begin
      top[0] = top_row[479:472];
      top[1] = top_row[487:480];
      top[2] = top_row[495:488];
      mid[0] = mid_row[479:472];
      mid[1] = mid_row[487:480];
      mid[2] = mid_row[495:488];
      btm[0] = btm_row[479:472];
      btm[1] = btm_row[487:480];
      btm[2] = btm_row[495:488];
    end
    'd61: begin
      top[0] = top_row[487:480];
      top[1] = top_row[495:488];
      top[2] = top_row[503:496];
      mid[0] = mid_row[487:480];
      mid[1] = mid_row[495:488];
      mid[2] = mid_row[503:496];
      btm[0] = btm_row[487:480];
      btm[1] = btm_row[495:488];
      btm[2] = btm_row[503:496];
    end
    'd62: begin
      top[0] = top_row[495:488];
      top[1] = top_row[503:496];
      top[2] = top_row[511:504];
      mid[0] = mid_row[495:488];
      mid[1] = mid_row[503:496];
      mid[2] = mid_row[511:504];
      btm[0] = btm_row[495:488];
      btm[1] = btm_row[503:496];
      btm[2] = btm_row[511:504];
    end
    'd63: begin
      top[0] = top_row[503:496];
      top[1] = top_row[511:504];
      top[2] = top_row[519:512];
      mid[0] = mid_row[503:496];
      mid[1] = mid_row[511:504];
      mid[2] = mid_row[519:512];
      btm[0] = btm_row[503:496];
      btm[1] = btm_row[511:504];
      btm[2] = btm_row[519:512];
    end
    'd64: begin
      top[0] = top_row[511:504];
      top[1] = top_row[519:512];
      top[2] = top_row[527:520];
      mid[0] = mid_row[511:504];
      mid[1] = mid_row[519:512];
      mid[2] = mid_row[527:520];
      btm[0] = btm_row[511:504];
      btm[1] = btm_row[519:512];
      btm[2] = btm_row[527:520];
    end
    'd65: begin
      top[0] = top_row[519:512];
      top[1] = top_row[527:520];
      top[2] = top_row[535:528];
      mid[0] = mid_row[519:512];
      mid[1] = mid_row[527:520];
      mid[2] = mid_row[535:528];
      btm[0] = btm_row[519:512];
      btm[1] = btm_row[527:520];
      btm[2] = btm_row[535:528];
    end
    'd66: begin
      top[0] = top_row[527:520];
      top[1] = top_row[535:528];
      top[2] = top_row[543:536];
      mid[0] = mid_row[527:520];
      mid[1] = mid_row[535:528];
      mid[2] = mid_row[543:536];
      btm[0] = btm_row[527:520];
      btm[1] = btm_row[535:528];
      btm[2] = btm_row[543:536];
    end
    'd67: begin
      top[0] = top_row[535:528];
      top[1] = top_row[543:536];
      top[2] = top_row[551:544];
      mid[0] = mid_row[535:528];
      mid[1] = mid_row[543:536];
      mid[2] = mid_row[551:544];
      btm[0] = btm_row[535:528];
      btm[1] = btm_row[543:536];
      btm[2] = btm_row[551:544];
    end
    'd68: begin
      top[0] = top_row[543:536];
      top[1] = top_row[551:544];
      top[2] = top_row[559:552];
      mid[0] = mid_row[543:536];
      mid[1] = mid_row[551:544];
      mid[2] = mid_row[559:552];
      btm[0] = btm_row[543:536];
      btm[1] = btm_row[551:544];
      btm[2] = btm_row[559:552];
    end
    'd69: begin
      top[0] = top_row[551:544];
      top[1] = top_row[559:552];
      top[2] = top_row[567:560];
      mid[0] = mid_row[551:544];
      mid[1] = mid_row[559:552];
      mid[2] = mid_row[567:560];
      btm[0] = btm_row[551:544];
      btm[1] = btm_row[559:552];
      btm[2] = btm_row[567:560];
    end
    'd70: begin
      top[0] = top_row[559:552];
      top[1] = top_row[567:560];
      top[2] = top_row[575:568];
      mid[0] = mid_row[559:552];
      mid[1] = mid_row[567:560];
      mid[2] = mid_row[575:568];
      btm[0] = btm_row[559:552];
      btm[1] = btm_row[567:560];
      btm[2] = btm_row[575:568];
    end
    'd71: begin
      top[0] = top_row[567:560];
      top[1] = top_row[575:568];
      top[2] = top_row[583:576];
      mid[0] = mid_row[567:560];
      mid[1] = mid_row[575:568];
      mid[2] = mid_row[583:576];
      btm[0] = btm_row[567:560];
      btm[1] = btm_row[575:568];
      btm[2] = btm_row[583:576];
    end
    'd72: begin
      top[0] = top_row[575:568];
      top[1] = top_row[583:576];
      top[2] = top_row[591:584];
      mid[0] = mid_row[575:568];
      mid[1] = mid_row[583:576];
      mid[2] = mid_row[591:584];
      btm[0] = btm_row[575:568];
      btm[1] = btm_row[583:576];
      btm[2] = btm_row[591:584];
    end
    'd73: begin
      top[0] = top_row[583:576];
      top[1] = top_row[591:584];
      top[2] = top_row[599:592];
      mid[0] = mid_row[583:576];
      mid[1] = mid_row[591:584];
      mid[2] = mid_row[599:592];
      btm[0] = btm_row[583:576];
      btm[1] = btm_row[591:584];
      btm[2] = btm_row[599:592];
    end
    'd74: begin
      top[0] = top_row[591:584];
      top[1] = top_row[599:592];
      top[2] = top_row[607:600];
      mid[0] = mid_row[591:584];
      mid[1] = mid_row[599:592];
      mid[2] = mid_row[607:600];
      btm[0] = btm_row[591:584];
      btm[1] = btm_row[599:592];
      btm[2] = btm_row[607:600];
    end
    'd75: begin
      top[0] = top_row[599:592];
      top[1] = top_row[607:600];
      top[2] = top_row[615:608];
      mid[0] = mid_row[599:592];
      mid[1] = mid_row[607:600];
      mid[2] = mid_row[615:608];
      btm[0] = btm_row[599:592];
      btm[1] = btm_row[607:600];
      btm[2] = btm_row[615:608];
    end
    'd76: begin
      top[0] = top_row[607:600];
      top[1] = top_row[615:608];
      top[2] = top_row[623:616];
      mid[0] = mid_row[607:600];
      mid[1] = mid_row[615:608];
      mid[2] = mid_row[623:616];
      btm[0] = btm_row[607:600];
      btm[1] = btm_row[615:608];
      btm[2] = btm_row[623:616];
    end
    'd77: begin
      top[0] = top_row[615:608];
      top[1] = top_row[623:616];
      top[2] = top_row[631:624];
      mid[0] = mid_row[615:608];
      mid[1] = mid_row[623:616];
      mid[2] = mid_row[631:624];
      btm[0] = btm_row[615:608];
      btm[1] = btm_row[623:616];
      btm[2] = btm_row[631:624];
    end
    'd78: begin
      top[0] = top_row[623:616];
      top[1] = top_row[631:624];
      top[2] = top_row[639:632];
      mid[0] = mid_row[623:616];
      mid[1] = mid_row[631:624];
      mid[2] = mid_row[639:632];
      btm[0] = btm_row[623:616];
      btm[1] = btm_row[631:624];
      btm[2] = btm_row[639:632];
    end
    'd79: begin
      top[0] = top_row[631:624];
      top[1] = top_row[639:632];
      top[2] = top_row[647:640];
      mid[0] = mid_row[631:624];
      mid[1] = mid_row[639:632];
      mid[2] = mid_row[647:640];
      btm[0] = btm_row[631:624];
      btm[1] = btm_row[639:632];
      btm[2] = btm_row[647:640];
    end
    'd80: begin
      top[0] = top_row[639:632];
      top[1] = top_row[647:640];
      top[2] = top_row[655:648];
      mid[0] = mid_row[639:632];
      mid[1] = mid_row[647:640];
      mid[2] = mid_row[655:648];
      btm[0] = btm_row[639:632];
      btm[1] = btm_row[647:640];
      btm[2] = btm_row[655:648];
    end
    'd81: begin
      top[0] = top_row[647:640];
      top[1] = top_row[655:648];
      top[2] = top_row[663:656];
      mid[0] = mid_row[647:640];
      mid[1] = mid_row[655:648];
      mid[2] = mid_row[663:656];
      btm[0] = btm_row[647:640];
      btm[1] = btm_row[655:648];
      btm[2] = btm_row[663:656];
    end
    'd82: begin
      top[0] = top_row[655:648];
      top[1] = top_row[663:656];
      top[2] = top_row[671:664];
      mid[0] = mid_row[655:648];
      mid[1] = mid_row[663:656];
      mid[2] = mid_row[671:664];
      btm[0] = btm_row[655:648];
      btm[1] = btm_row[663:656];
      btm[2] = btm_row[671:664];
    end
    'd83: begin
      top[0] = top_row[663:656];
      top[1] = top_row[671:664];
      top[2] = top_row[679:672];
      mid[0] = mid_row[663:656];
      mid[1] = mid_row[671:664];
      mid[2] = mid_row[679:672];
      btm[0] = btm_row[663:656];
      btm[1] = btm_row[671:664];
      btm[2] = btm_row[679:672];
    end
    'd84: begin
      top[0] = top_row[671:664];
      top[1] = top_row[679:672];
      top[2] = top_row[687:680];
      mid[0] = mid_row[671:664];
      mid[1] = mid_row[679:672];
      mid[2] = mid_row[687:680];
      btm[0] = btm_row[671:664];
      btm[1] = btm_row[679:672];
      btm[2] = btm_row[687:680];
    end
    'd85: begin
      top[0] = top_row[679:672];
      top[1] = top_row[687:680];
      top[2] = top_row[695:688];
      mid[0] = mid_row[679:672];
      mid[1] = mid_row[687:680];
      mid[2] = mid_row[695:688];
      btm[0] = btm_row[679:672];
      btm[1] = btm_row[687:680];
      btm[2] = btm_row[695:688];
    end
    'd86: begin
      top[0] = top_row[687:680];
      top[1] = top_row[695:688];
      top[2] = top_row[703:696];
      mid[0] = mid_row[687:680];
      mid[1] = mid_row[695:688];
      mid[2] = mid_row[703:696];
      btm[0] = btm_row[687:680];
      btm[1] = btm_row[695:688];
      btm[2] = btm_row[703:696];
    end
    'd87: begin
      top[0] = top_row[695:688];
      top[1] = top_row[703:696];
      top[2] = top_row[711:704];
      mid[0] = mid_row[695:688];
      mid[1] = mid_row[703:696];
      mid[2] = mid_row[711:704];
      btm[0] = btm_row[695:688];
      btm[1] = btm_row[703:696];
      btm[2] = btm_row[711:704];
    end
    'd88: begin
      top[0] = top_row[703:696];
      top[1] = top_row[711:704];
      top[2] = top_row[719:712];
      mid[0] = mid_row[703:696];
      mid[1] = mid_row[711:704];
      mid[2] = mid_row[719:712];
      btm[0] = btm_row[703:696];
      btm[1] = btm_row[711:704];
      btm[2] = btm_row[719:712];
    end
    'd89: begin
      top[0] = top_row[711:704];
      top[1] = top_row[719:712];
      top[2] = top_row[727:720];
      mid[0] = mid_row[711:704];
      mid[1] = mid_row[719:712];
      mid[2] = mid_row[727:720];
      btm[0] = btm_row[711:704];
      btm[1] = btm_row[719:712];
      btm[2] = btm_row[727:720];
    end
    'd90: begin
      top[0] = top_row[719:712];
      top[1] = top_row[727:720];
      top[2] = top_row[735:728];
      mid[0] = mid_row[719:712];
      mid[1] = mid_row[727:720];
      mid[2] = mid_row[735:728];
      btm[0] = btm_row[719:712];
      btm[1] = btm_row[727:720];
      btm[2] = btm_row[735:728];
    end
    'd91: begin
      top[0] = top_row[727:720];
      top[1] = top_row[735:728];
      top[2] = top_row[743:736];
      mid[0] = mid_row[727:720];
      mid[1] = mid_row[735:728];
      mid[2] = mid_row[743:736];
      btm[0] = btm_row[727:720];
      btm[1] = btm_row[735:728];
      btm[2] = btm_row[743:736];
    end
    'd92: begin
      top[0] = top_row[735:728];
      top[1] = top_row[743:736];
      top[2] = top_row[751:744];
      mid[0] = mid_row[735:728];
      mid[1] = mid_row[743:736];
      mid[2] = mid_row[751:744];
      btm[0] = btm_row[735:728];
      btm[1] = btm_row[743:736];
      btm[2] = btm_row[751:744];
    end
    'd93: begin
      top[0] = top_row[743:736];
      top[1] = top_row[751:744];
      top[2] = top_row[759:752];
      mid[0] = mid_row[743:736];
      mid[1] = mid_row[751:744];
      mid[2] = mid_row[759:752];
      btm[0] = btm_row[743:736];
      btm[1] = btm_row[751:744];
      btm[2] = btm_row[759:752];
    end
    'd94: begin
      top[0] = top_row[751:744];
      top[1] = top_row[759:752];
      top[2] = top_row[767:760];
      mid[0] = mid_row[751:744];
      mid[1] = mid_row[759:752];
      mid[2] = mid_row[767:760];
      btm[0] = btm_row[751:744];
      btm[1] = btm_row[759:752];
      btm[2] = btm_row[767:760];
    end
    'd95: begin
      top[0] = top_row[759:752];
      top[1] = top_row[767:760];
      top[2] = top_row[775:768];
      mid[0] = mid_row[759:752];
      mid[1] = mid_row[767:760];
      mid[2] = mid_row[775:768];
      btm[0] = btm_row[759:752];
      btm[1] = btm_row[767:760];
      btm[2] = btm_row[775:768];
    end
    'd96: begin
      top[0] = top_row[767:760];
      top[1] = top_row[775:768];
      top[2] = top_row[783:776];
      mid[0] = mid_row[767:760];
      mid[1] = mid_row[775:768];
      mid[2] = mid_row[783:776];
      btm[0] = btm_row[767:760];
      btm[1] = btm_row[775:768];
      btm[2] = btm_row[783:776];
    end
    'd97: begin
      top[0] = top_row[775:768];
      top[1] = top_row[783:776];
      top[2] = top_row[791:784];
      mid[0] = mid_row[775:768];
      mid[1] = mid_row[783:776];
      mid[2] = mid_row[791:784];
      btm[0] = btm_row[775:768];
      btm[1] = btm_row[783:776];
      btm[2] = btm_row[791:784];
    end
    'd98: begin
      top[0] = top_row[783:776];
      top[1] = top_row[791:784];
      top[2] = top_row[799:792];
      mid[0] = mid_row[783:776];
      mid[1] = mid_row[791:784];
      mid[2] = mid_row[799:792];
      btm[0] = btm_row[783:776];
      btm[1] = btm_row[791:784];
      btm[2] = btm_row[799:792];
    end
    'd99: begin
      top[0] = top_row[791:784];
      top[1] = top_row[799:792];
      top[2] = top_row[807:800];
      mid[0] = mid_row[791:784];
      mid[1] = mid_row[799:792];
      mid[2] = mid_row[807:800];
      btm[0] = btm_row[791:784];
      btm[1] = btm_row[799:792];
      btm[2] = btm_row[807:800];
    end
    'd100: begin
      top[0] = top_row[799:792];
      top[1] = top_row[807:800];
      top[2] = top_row[815:808];
      mid[0] = mid_row[799:792];
      mid[1] = mid_row[807:800];
      mid[2] = mid_row[815:808];
      btm[0] = btm_row[799:792];
      btm[1] = btm_row[807:800];
      btm[2] = btm_row[815:808];
    end
    'd101: begin
      top[0] = top_row[807:800];
      top[1] = top_row[815:808];
      top[2] = top_row[823:816];
      mid[0] = mid_row[807:800];
      mid[1] = mid_row[815:808];
      mid[2] = mid_row[823:816];
      btm[0] = btm_row[807:800];
      btm[1] = btm_row[815:808];
      btm[2] = btm_row[823:816];
    end
    'd102: begin
      top[0] = top_row[815:808];
      top[1] = top_row[823:816];
      top[2] = top_row[831:824];
      mid[0] = mid_row[815:808];
      mid[1] = mid_row[823:816];
      mid[2] = mid_row[831:824];
      btm[0] = btm_row[815:808];
      btm[1] = btm_row[823:816];
      btm[2] = btm_row[831:824];
    end
    'd103: begin
      top[0] = top_row[823:816];
      top[1] = top_row[831:824];
      top[2] = top_row[839:832];
      mid[0] = mid_row[823:816];
      mid[1] = mid_row[831:824];
      mid[2] = mid_row[839:832];
      btm[0] = btm_row[823:816];
      btm[1] = btm_row[831:824];
      btm[2] = btm_row[839:832];
    end
    'd104: begin
      top[0] = top_row[831:824];
      top[1] = top_row[839:832];
      top[2] = top_row[847:840];
      mid[0] = mid_row[831:824];
      mid[1] = mid_row[839:832];
      mid[2] = mid_row[847:840];
      btm[0] = btm_row[831:824];
      btm[1] = btm_row[839:832];
      btm[2] = btm_row[847:840];
    end
    'd105: begin
      top[0] = top_row[839:832];
      top[1] = top_row[847:840];
      top[2] = top_row[855:848];
      mid[0] = mid_row[839:832];
      mid[1] = mid_row[847:840];
      mid[2] = mid_row[855:848];
      btm[0] = btm_row[839:832];
      btm[1] = btm_row[847:840];
      btm[2] = btm_row[855:848];
    end
    'd106: begin
      top[0] = top_row[847:840];
      top[1] = top_row[855:848];
      top[2] = top_row[863:856];
      mid[0] = mid_row[847:840];
      mid[1] = mid_row[855:848];
      mid[2] = mid_row[863:856];
      btm[0] = btm_row[847:840];
      btm[1] = btm_row[855:848];
      btm[2] = btm_row[863:856];
    end
    'd107: begin
      top[0] = top_row[855:848];
      top[1] = top_row[863:856];
      top[2] = top_row[871:864];
      mid[0] = mid_row[855:848];
      mid[1] = mid_row[863:856];
      mid[2] = mid_row[871:864];
      btm[0] = btm_row[855:848];
      btm[1] = btm_row[863:856];
      btm[2] = btm_row[871:864];
    end
    'd108: begin
      top[0] = top_row[863:856];
      top[1] = top_row[871:864];
      top[2] = top_row[879:872];
      mid[0] = mid_row[863:856];
      mid[1] = mid_row[871:864];
      mid[2] = mid_row[879:872];
      btm[0] = btm_row[863:856];
      btm[1] = btm_row[871:864];
      btm[2] = btm_row[879:872];
    end
    'd109: begin
      top[0] = top_row[871:864];
      top[1] = top_row[879:872];
      top[2] = top_row[887:880];
      mid[0] = mid_row[871:864];
      mid[1] = mid_row[879:872];
      mid[2] = mid_row[887:880];
      btm[0] = btm_row[871:864];
      btm[1] = btm_row[879:872];
      btm[2] = btm_row[887:880];
    end
    'd110: begin
      top[0] = top_row[879:872];
      top[1] = top_row[887:880];
      top[2] = top_row[895:888];
      mid[0] = mid_row[879:872];
      mid[1] = mid_row[887:880];
      mid[2] = mid_row[895:888];
      btm[0] = btm_row[879:872];
      btm[1] = btm_row[887:880];
      btm[2] = btm_row[895:888];
    end
    'd111: begin
      top[0] = top_row[887:880];
      top[1] = top_row[895:888];
      top[2] = top_row[903:896];
      mid[0] = mid_row[887:880];
      mid[1] = mid_row[895:888];
      mid[2] = mid_row[903:896];
      btm[0] = btm_row[887:880];
      btm[1] = btm_row[895:888];
      btm[2] = btm_row[903:896];
    end
    'd112: begin
      top[0] = top_row[895:888];
      top[1] = top_row[903:896];
      top[2] = top_row[911:904];
      mid[0] = mid_row[895:888];
      mid[1] = mid_row[903:896];
      mid[2] = mid_row[911:904];
      btm[0] = btm_row[895:888];
      btm[1] = btm_row[903:896];
      btm[2] = btm_row[911:904];
    end
    'd113: begin
      top[0] = top_row[903:896];
      top[1] = top_row[911:904];
      top[2] = top_row[919:912];
      mid[0] = mid_row[903:896];
      mid[1] = mid_row[911:904];
      mid[2] = mid_row[919:912];
      btm[0] = btm_row[903:896];
      btm[1] = btm_row[911:904];
      btm[2] = btm_row[919:912];
    end
    'd114: begin
      top[0] = top_row[911:904];
      top[1] = top_row[919:912];
      top[2] = top_row[927:920];
      mid[0] = mid_row[911:904];
      mid[1] = mid_row[919:912];
      mid[2] = mid_row[927:920];
      btm[0] = btm_row[911:904];
      btm[1] = btm_row[919:912];
      btm[2] = btm_row[927:920];
    end
    'd115: begin
      top[0] = top_row[919:912];
      top[1] = top_row[927:920];
      top[2] = top_row[935:928];
      mid[0] = mid_row[919:912];
      mid[1] = mid_row[927:920];
      mid[2] = mid_row[935:928];
      btm[0] = btm_row[919:912];
      btm[1] = btm_row[927:920];
      btm[2] = btm_row[935:928];
    end
    'd116: begin
      top[0] = top_row[927:920];
      top[1] = top_row[935:928];
      top[2] = top_row[943:936];
      mid[0] = mid_row[927:920];
      mid[1] = mid_row[935:928];
      mid[2] = mid_row[943:936];
      btm[0] = btm_row[927:920];
      btm[1] = btm_row[935:928];
      btm[2] = btm_row[943:936];
    end
    'd117: begin
      top[0] = top_row[935:928];
      top[1] = top_row[943:936];
      top[2] = top_row[951:944];
      mid[0] = mid_row[935:928];
      mid[1] = mid_row[943:936];
      mid[2] = mid_row[951:944];
      btm[0] = btm_row[935:928];
      btm[1] = btm_row[943:936];
      btm[2] = btm_row[951:944];
    end
    'd118: begin
      top[0] = top_row[943:936];
      top[1] = top_row[951:944];
      top[2] = top_row[959:952];
      mid[0] = mid_row[943:936];
      mid[1] = mid_row[951:944];
      mid[2] = mid_row[959:952];
      btm[0] = btm_row[943:936];
      btm[1] = btm_row[951:944];
      btm[2] = btm_row[959:952];
    end
    'd119: begin
      top[0] = top_row[951:944];
      top[1] = top_row[959:952];
      top[2] = top_row[967:960];
      mid[0] = mid_row[951:944];
      mid[1] = mid_row[959:952];
      mid[2] = mid_row[967:960];
      btm[0] = btm_row[951:944];
      btm[1] = btm_row[959:952];
      btm[2] = btm_row[967:960];
    end
    'd120: begin
      top[0] = top_row[959:952];
      top[1] = top_row[967:960];
      top[2] = top_row[975:968];
      mid[0] = mid_row[959:952];
      mid[1] = mid_row[967:960];
      mid[2] = mid_row[975:968];
      btm[0] = btm_row[959:952];
      btm[1] = btm_row[967:960];
      btm[2] = btm_row[975:968];
    end
    'd121: begin
      top[0] = top_row[967:960];
      top[1] = top_row[975:968];
      top[2] = top_row[983:976];
      mid[0] = mid_row[967:960];
      mid[1] = mid_row[975:968];
      mid[2] = mid_row[983:976];
      btm[0] = btm_row[967:960];
      btm[1] = btm_row[975:968];
      btm[2] = btm_row[983:976];
    end
    'd122: begin
      top[0] = top_row[975:968];
      top[1] = top_row[983:976];
      top[2] = top_row[991:984];
      mid[0] = mid_row[975:968];
      mid[1] = mid_row[983:976];
      mid[2] = mid_row[991:984];
      btm[0] = btm_row[975:968];
      btm[1] = btm_row[983:976];
      btm[2] = btm_row[991:984];
    end
    'd123: begin
      top[0] = top_row[983:976];
      top[1] = top_row[991:984];
      top[2] = top_row[999:992];
      mid[0] = mid_row[983:976];
      mid[1] = mid_row[991:984];
      mid[2] = mid_row[999:992];
      btm[0] = btm_row[983:976];
      btm[1] = btm_row[991:984];
      btm[2] = btm_row[999:992];
    end
    'd124: begin
      top[0] = top_row[991:984];
      top[1] = top_row[999:992];
      top[2] = top_row[1007:1000];
      mid[0] = mid_row[991:984];
      mid[1] = mid_row[999:992];
      mid[2] = mid_row[1007:1000];
      btm[0] = btm_row[991:984];
      btm[1] = btm_row[999:992];
      btm[2] = btm_row[1007:1000];
    end
    'd125: begin
      top[0] = top_row[999:992];
      top[1] = top_row[1007:1000];
      top[2] = top_row[1015:1008];
      mid[0] = mid_row[999:992];
      mid[1] = mid_row[1007:1000];
      mid[2] = mid_row[1015:1008];
      btm[0] = btm_row[999:992];
      btm[1] = btm_row[1007:1000];
      btm[2] = btm_row[1015:1008];
    end
    'd126: begin
      top[0] = top_row[1007:1000];
      top[1] = top_row[1015:1008];
      top[2] = top_row[1023:1016];
      mid[0] = mid_row[1007:1000];
      mid[1] = mid_row[1015:1008];
      mid[2] = mid_row[1023:1016];
      btm[0] = btm_row[1007:1000];
      btm[1] = btm_row[1015:1008];
      btm[2] = btm_row[1023:1016];
    end
    'd127: begin
      top[0] = top_row[1015:1008];
      top[1] = top_row[1023:1016];
      top[2] = top_row[1031:1024];
      mid[0] = mid_row[1015:1008];
      mid[1] = mid_row[1023:1016];
      mid[2] = mid_row[1031:1024];
      btm[0] = btm_row[1015:1008];
      btm[1] = btm_row[1023:1016];
      btm[2] = btm_row[1031:1024];
    end
    'd128: begin
      top[0] = top_row[1023:1016];
      top[1] = top_row[1031:1024];
      top[2] = top_row[1039:1032];
      mid[0] = mid_row[1023:1016];
      mid[1] = mid_row[1031:1024];
      mid[2] = mid_row[1039:1032];
      btm[0] = btm_row[1023:1016];
      btm[1] = btm_row[1031:1024];
      btm[2] = btm_row[1039:1032];
    end
    'd129: begin
      top[0] = top_row[1031:1024];
      top[1] = top_row[1039:1032];
      top[2] = top_row[1047:1040];
      mid[0] = mid_row[1031:1024];
      mid[1] = mid_row[1039:1032];
      mid[2] = mid_row[1047:1040];
      btm[0] = btm_row[1031:1024];
      btm[1] = btm_row[1039:1032];
      btm[2] = btm_row[1047:1040];
    end
    'd130: begin
      top[0] = top_row[1039:1032];
      top[1] = top_row[1047:1040];
      top[2] = top_row[1055:1048];
      mid[0] = mid_row[1039:1032];
      mid[1] = mid_row[1047:1040];
      mid[2] = mid_row[1055:1048];
      btm[0] = btm_row[1039:1032];
      btm[1] = btm_row[1047:1040];
      btm[2] = btm_row[1055:1048];
    end
    'd131: begin
      top[0] = top_row[1047:1040];
      top[1] = top_row[1055:1048];
      top[2] = top_row[1063:1056];
      mid[0] = mid_row[1047:1040];
      mid[1] = mid_row[1055:1048];
      mid[2] = mid_row[1063:1056];
      btm[0] = btm_row[1047:1040];
      btm[1] = btm_row[1055:1048];
      btm[2] = btm_row[1063:1056];
    end
    'd132: begin
      top[0] = top_row[1055:1048];
      top[1] = top_row[1063:1056];
      top[2] = top_row[1071:1064];
      mid[0] = mid_row[1055:1048];
      mid[1] = mid_row[1063:1056];
      mid[2] = mid_row[1071:1064];
      btm[0] = btm_row[1055:1048];
      btm[1] = btm_row[1063:1056];
      btm[2] = btm_row[1071:1064];
    end
    'd133: begin
      top[0] = top_row[1063:1056];
      top[1] = top_row[1071:1064];
      top[2] = top_row[1079:1072];
      mid[0] = mid_row[1063:1056];
      mid[1] = mid_row[1071:1064];
      mid[2] = mid_row[1079:1072];
      btm[0] = btm_row[1063:1056];
      btm[1] = btm_row[1071:1064];
      btm[2] = btm_row[1079:1072];
    end
    'd134: begin
      top[0] = top_row[1071:1064];
      top[1] = top_row[1079:1072];
      top[2] = top_row[1087:1080];
      mid[0] = mid_row[1071:1064];
      mid[1] = mid_row[1079:1072];
      mid[2] = mid_row[1087:1080];
      btm[0] = btm_row[1071:1064];
      btm[1] = btm_row[1079:1072];
      btm[2] = btm_row[1087:1080];
    end
    'd135: begin
      top[0] = top_row[1079:1072];
      top[1] = top_row[1087:1080];
      top[2] = top_row[1095:1088];
      mid[0] = mid_row[1079:1072];
      mid[1] = mid_row[1087:1080];
      mid[2] = mid_row[1095:1088];
      btm[0] = btm_row[1079:1072];
      btm[1] = btm_row[1087:1080];
      btm[2] = btm_row[1095:1088];
    end
    'd136: begin
      top[0] = top_row[1087:1080];
      top[1] = top_row[1095:1088];
      top[2] = top_row[1103:1096];
      mid[0] = mid_row[1087:1080];
      mid[1] = mid_row[1095:1088];
      mid[2] = mid_row[1103:1096];
      btm[0] = btm_row[1087:1080];
      btm[1] = btm_row[1095:1088];
      btm[2] = btm_row[1103:1096];
    end
    'd137: begin
      top[0] = top_row[1095:1088];
      top[1] = top_row[1103:1096];
      top[2] = top_row[1111:1104];
      mid[0] = mid_row[1095:1088];
      mid[1] = mid_row[1103:1096];
      mid[2] = mid_row[1111:1104];
      btm[0] = btm_row[1095:1088];
      btm[1] = btm_row[1103:1096];
      btm[2] = btm_row[1111:1104];
    end
    'd138: begin
      top[0] = top_row[1103:1096];
      top[1] = top_row[1111:1104];
      top[2] = top_row[1119:1112];
      mid[0] = mid_row[1103:1096];
      mid[1] = mid_row[1111:1104];
      mid[2] = mid_row[1119:1112];
      btm[0] = btm_row[1103:1096];
      btm[1] = btm_row[1111:1104];
      btm[2] = btm_row[1119:1112];
    end
    'd139: begin
      top[0] = top_row[1111:1104];
      top[1] = top_row[1119:1112];
      top[2] = top_row[1127:1120];
      mid[0] = mid_row[1111:1104];
      mid[1] = mid_row[1119:1112];
      mid[2] = mid_row[1127:1120];
      btm[0] = btm_row[1111:1104];
      btm[1] = btm_row[1119:1112];
      btm[2] = btm_row[1127:1120];
    end
    'd140: begin
      top[0] = top_row[1119:1112];
      top[1] = top_row[1127:1120];
      top[2] = top_row[1135:1128];
      mid[0] = mid_row[1119:1112];
      mid[1] = mid_row[1127:1120];
      mid[2] = mid_row[1135:1128];
      btm[0] = btm_row[1119:1112];
      btm[1] = btm_row[1127:1120];
      btm[2] = btm_row[1135:1128];
    end
    'd141: begin
      top[0] = top_row[1127:1120];
      top[1] = top_row[1135:1128];
      top[2] = top_row[1143:1136];
      mid[0] = mid_row[1127:1120];
      mid[1] = mid_row[1135:1128];
      mid[2] = mid_row[1143:1136];
      btm[0] = btm_row[1127:1120];
      btm[1] = btm_row[1135:1128];
      btm[2] = btm_row[1143:1136];
    end
    'd142: begin
      top[0] = top_row[1135:1128];
      top[1] = top_row[1143:1136];
      top[2] = top_row[1151:1144];
      mid[0] = mid_row[1135:1128];
      mid[1] = mid_row[1143:1136];
      mid[2] = mid_row[1151:1144];
      btm[0] = btm_row[1135:1128];
      btm[1] = btm_row[1143:1136];
      btm[2] = btm_row[1151:1144];
    end
    'd143: begin
      top[0] = top_row[1143:1136];
      top[1] = top_row[1151:1144];
      top[2] = top_row[1159:1152];
      mid[0] = mid_row[1143:1136];
      mid[1] = mid_row[1151:1144];
      mid[2] = mid_row[1159:1152];
      btm[0] = btm_row[1143:1136];
      btm[1] = btm_row[1151:1144];
      btm[2] = btm_row[1159:1152];
    end
    'd144: begin
      top[0] = top_row[1151:1144];
      top[1] = top_row[1159:1152];
      top[2] = top_row[1167:1160];
      mid[0] = mid_row[1151:1144];
      mid[1] = mid_row[1159:1152];
      mid[2] = mid_row[1167:1160];
      btm[0] = btm_row[1151:1144];
      btm[1] = btm_row[1159:1152];
      btm[2] = btm_row[1167:1160];
    end
    'd145: begin
      top[0] = top_row[1159:1152];
      top[1] = top_row[1167:1160];
      top[2] = top_row[1175:1168];
      mid[0] = mid_row[1159:1152];
      mid[1] = mid_row[1167:1160];
      mid[2] = mid_row[1175:1168];
      btm[0] = btm_row[1159:1152];
      btm[1] = btm_row[1167:1160];
      btm[2] = btm_row[1175:1168];
    end
    'd146: begin
      top[0] = top_row[1167:1160];
      top[1] = top_row[1175:1168];
      top[2] = top_row[1183:1176];
      mid[0] = mid_row[1167:1160];
      mid[1] = mid_row[1175:1168];
      mid[2] = mid_row[1183:1176];
      btm[0] = btm_row[1167:1160];
      btm[1] = btm_row[1175:1168];
      btm[2] = btm_row[1183:1176];
    end
    'd147: begin
      top[0] = top_row[1175:1168];
      top[1] = top_row[1183:1176];
      top[2] = top_row[1191:1184];
      mid[0] = mid_row[1175:1168];
      mid[1] = mid_row[1183:1176];
      mid[2] = mid_row[1191:1184];
      btm[0] = btm_row[1175:1168];
      btm[1] = btm_row[1183:1176];
      btm[2] = btm_row[1191:1184];
    end
    'd148: begin
      top[0] = top_row[1183:1176];
      top[1] = top_row[1191:1184];
      top[2] = top_row[1199:1192];
      mid[0] = mid_row[1183:1176];
      mid[1] = mid_row[1191:1184];
      mid[2] = mid_row[1199:1192];
      btm[0] = btm_row[1183:1176];
      btm[1] = btm_row[1191:1184];
      btm[2] = btm_row[1199:1192];
    end
    'd149: begin
      top[0] = top_row[1191:1184];
      top[1] = top_row[1199:1192];
      top[2] = top_row[1207:1200];
      mid[0] = mid_row[1191:1184];
      mid[1] = mid_row[1199:1192];
      mid[2] = mid_row[1207:1200];
      btm[0] = btm_row[1191:1184];
      btm[1] = btm_row[1199:1192];
      btm[2] = btm_row[1207:1200];
    end
    'd150: begin
      top[0] = top_row[1199:1192];
      top[1] = top_row[1207:1200];
      top[2] = top_row[1215:1208];
      mid[0] = mid_row[1199:1192];
      mid[1] = mid_row[1207:1200];
      mid[2] = mid_row[1215:1208];
      btm[0] = btm_row[1199:1192];
      btm[1] = btm_row[1207:1200];
      btm[2] = btm_row[1215:1208];
    end
    'd151: begin
      top[0] = top_row[1207:1200];
      top[1] = top_row[1215:1208];
      top[2] = top_row[1223:1216];
      mid[0] = mid_row[1207:1200];
      mid[1] = mid_row[1215:1208];
      mid[2] = mid_row[1223:1216];
      btm[0] = btm_row[1207:1200];
      btm[1] = btm_row[1215:1208];
      btm[2] = btm_row[1223:1216];
    end
    'd152: begin
      top[0] = top_row[1215:1208];
      top[1] = top_row[1223:1216];
      top[2] = top_row[1231:1224];
      mid[0] = mid_row[1215:1208];
      mid[1] = mid_row[1223:1216];
      mid[2] = mid_row[1231:1224];
      btm[0] = btm_row[1215:1208];
      btm[1] = btm_row[1223:1216];
      btm[2] = btm_row[1231:1224];
    end
    'd153: begin
      top[0] = top_row[1223:1216];
      top[1] = top_row[1231:1224];
      top[2] = top_row[1239:1232];
      mid[0] = mid_row[1223:1216];
      mid[1] = mid_row[1231:1224];
      mid[2] = mid_row[1239:1232];
      btm[0] = btm_row[1223:1216];
      btm[1] = btm_row[1231:1224];
      btm[2] = btm_row[1239:1232];
    end
    'd154: begin
      top[0] = top_row[1231:1224];
      top[1] = top_row[1239:1232];
      top[2] = top_row[1247:1240];
      mid[0] = mid_row[1231:1224];
      mid[1] = mid_row[1239:1232];
      mid[2] = mid_row[1247:1240];
      btm[0] = btm_row[1231:1224];
      btm[1] = btm_row[1239:1232];
      btm[2] = btm_row[1247:1240];
    end
    'd155: begin
      top[0] = top_row[1239:1232];
      top[1] = top_row[1247:1240];
      top[2] = top_row[1255:1248];
      mid[0] = mid_row[1239:1232];
      mid[1] = mid_row[1247:1240];
      mid[2] = mid_row[1255:1248];
      btm[0] = btm_row[1239:1232];
      btm[1] = btm_row[1247:1240];
      btm[2] = btm_row[1255:1248];
    end
    'd156: begin
      top[0] = top_row[1247:1240];
      top[1] = top_row[1255:1248];
      top[2] = top_row[1263:1256];
      mid[0] = mid_row[1247:1240];
      mid[1] = mid_row[1255:1248];
      mid[2] = mid_row[1263:1256];
      btm[0] = btm_row[1247:1240];
      btm[1] = btm_row[1255:1248];
      btm[2] = btm_row[1263:1256];
    end
    'd157: begin
      top[0] = top_row[1255:1248];
      top[1] = top_row[1263:1256];
      top[2] = top_row[1271:1264];
      mid[0] = mid_row[1255:1248];
      mid[1] = mid_row[1263:1256];
      mid[2] = mid_row[1271:1264];
      btm[0] = btm_row[1255:1248];
      btm[1] = btm_row[1263:1256];
      btm[2] = btm_row[1271:1264];
    end
    'd158: begin
      top[0] = top_row[1263:1256];
      top[1] = top_row[1271:1264];
      top[2] = top_row[1279:1272];
      mid[0] = mid_row[1263:1256];
      mid[1] = mid_row[1271:1264];
      mid[2] = mid_row[1279:1272];
      btm[0] = btm_row[1263:1256];
      btm[1] = btm_row[1271:1264];
      btm[2] = btm_row[1279:1272];
    end
    'd159: begin
      top[0] = top_row[1271:1264];
      top[1] = top_row[1279:1272];
      top[2] = top_row[1287:1280];
      mid[0] = mid_row[1271:1264];
      mid[1] = mid_row[1279:1272];
      mid[2] = mid_row[1287:1280];
      btm[0] = btm_row[1271:1264];
      btm[1] = btm_row[1279:1272];
      btm[2] = btm_row[1287:1280];
    end
    'd160: begin
      top[0] = top_row[1279:1272];
      top[1] = top_row[1287:1280];
      top[2] = top_row[1295:1288];
      mid[0] = mid_row[1279:1272];
      mid[1] = mid_row[1287:1280];
      mid[2] = mid_row[1295:1288];
      btm[0] = btm_row[1279:1272];
      btm[1] = btm_row[1287:1280];
      btm[2] = btm_row[1295:1288];
    end
    'd161: begin
      top[0] = top_row[1287:1280];
      top[1] = top_row[1295:1288];
      top[2] = top_row[1303:1296];
      mid[0] = mid_row[1287:1280];
      mid[1] = mid_row[1295:1288];
      mid[2] = mid_row[1303:1296];
      btm[0] = btm_row[1287:1280];
      btm[1] = btm_row[1295:1288];
      btm[2] = btm_row[1303:1296];
    end
    'd162: begin
      top[0] = top_row[1295:1288];
      top[1] = top_row[1303:1296];
      top[2] = top_row[1311:1304];
      mid[0] = mid_row[1295:1288];
      mid[1] = mid_row[1303:1296];
      mid[2] = mid_row[1311:1304];
      btm[0] = btm_row[1295:1288];
      btm[1] = btm_row[1303:1296];
      btm[2] = btm_row[1311:1304];
    end
    'd163: begin
      top[0] = top_row[1303:1296];
      top[1] = top_row[1311:1304];
      top[2] = top_row[1319:1312];
      mid[0] = mid_row[1303:1296];
      mid[1] = mid_row[1311:1304];
      mid[2] = mid_row[1319:1312];
      btm[0] = btm_row[1303:1296];
      btm[1] = btm_row[1311:1304];
      btm[2] = btm_row[1319:1312];
    end
    'd164: begin
      top[0] = top_row[1311:1304];
      top[1] = top_row[1319:1312];
      top[2] = top_row[1327:1320];
      mid[0] = mid_row[1311:1304];
      mid[1] = mid_row[1319:1312];
      mid[2] = mid_row[1327:1320];
      btm[0] = btm_row[1311:1304];
      btm[1] = btm_row[1319:1312];
      btm[2] = btm_row[1327:1320];
    end
    'd165: begin
      top[0] = top_row[1319:1312];
      top[1] = top_row[1327:1320];
      top[2] = top_row[1335:1328];
      mid[0] = mid_row[1319:1312];
      mid[1] = mid_row[1327:1320];
      mid[2] = mid_row[1335:1328];
      btm[0] = btm_row[1319:1312];
      btm[1] = btm_row[1327:1320];
      btm[2] = btm_row[1335:1328];
    end
    'd166: begin
      top[0] = top_row[1327:1320];
      top[1] = top_row[1335:1328];
      top[2] = top_row[1343:1336];
      mid[0] = mid_row[1327:1320];
      mid[1] = mid_row[1335:1328];
      mid[2] = mid_row[1343:1336];
      btm[0] = btm_row[1327:1320];
      btm[1] = btm_row[1335:1328];
      btm[2] = btm_row[1343:1336];
    end
    'd167: begin
      top[0] = top_row[1335:1328];
      top[1] = top_row[1343:1336];
      top[2] = top_row[1351:1344];
      mid[0] = mid_row[1335:1328];
      mid[1] = mid_row[1343:1336];
      mid[2] = mid_row[1351:1344];
      btm[0] = btm_row[1335:1328];
      btm[1] = btm_row[1343:1336];
      btm[2] = btm_row[1351:1344];
    end
    'd168: begin
      top[0] = top_row[1343:1336];
      top[1] = top_row[1351:1344];
      top[2] = top_row[1359:1352];
      mid[0] = mid_row[1343:1336];
      mid[1] = mid_row[1351:1344];
      mid[2] = mid_row[1359:1352];
      btm[0] = btm_row[1343:1336];
      btm[1] = btm_row[1351:1344];
      btm[2] = btm_row[1359:1352];
    end
    'd169: begin
      top[0] = top_row[1351:1344];
      top[1] = top_row[1359:1352];
      top[2] = top_row[1367:1360];
      mid[0] = mid_row[1351:1344];
      mid[1] = mid_row[1359:1352];
      mid[2] = mid_row[1367:1360];
      btm[0] = btm_row[1351:1344];
      btm[1] = btm_row[1359:1352];
      btm[2] = btm_row[1367:1360];
    end
    'd170: begin
      top[0] = top_row[1359:1352];
      top[1] = top_row[1367:1360];
      top[2] = top_row[1375:1368];
      mid[0] = mid_row[1359:1352];
      mid[1] = mid_row[1367:1360];
      mid[2] = mid_row[1375:1368];
      btm[0] = btm_row[1359:1352];
      btm[1] = btm_row[1367:1360];
      btm[2] = btm_row[1375:1368];
    end
    'd171: begin
      top[0] = top_row[1367:1360];
      top[1] = top_row[1375:1368];
      top[2] = top_row[1383:1376];
      mid[0] = mid_row[1367:1360];
      mid[1] = mid_row[1375:1368];
      mid[2] = mid_row[1383:1376];
      btm[0] = btm_row[1367:1360];
      btm[1] = btm_row[1375:1368];
      btm[2] = btm_row[1383:1376];
    end
    'd172: begin
      top[0] = top_row[1375:1368];
      top[1] = top_row[1383:1376];
      top[2] = top_row[1391:1384];
      mid[0] = mid_row[1375:1368];
      mid[1] = mid_row[1383:1376];
      mid[2] = mid_row[1391:1384];
      btm[0] = btm_row[1375:1368];
      btm[1] = btm_row[1383:1376];
      btm[2] = btm_row[1391:1384];
    end
    'd173: begin
      top[0] = top_row[1383:1376];
      top[1] = top_row[1391:1384];
      top[2] = top_row[1399:1392];
      mid[0] = mid_row[1383:1376];
      mid[1] = mid_row[1391:1384];
      mid[2] = mid_row[1399:1392];
      btm[0] = btm_row[1383:1376];
      btm[1] = btm_row[1391:1384];
      btm[2] = btm_row[1399:1392];
    end
    'd174: begin
      top[0] = top_row[1391:1384];
      top[1] = top_row[1399:1392];
      top[2] = top_row[1407:1400];
      mid[0] = mid_row[1391:1384];
      mid[1] = mid_row[1399:1392];
      mid[2] = mid_row[1407:1400];
      btm[0] = btm_row[1391:1384];
      btm[1] = btm_row[1399:1392];
      btm[2] = btm_row[1407:1400];
    end
    'd175: begin
      top[0] = top_row[1399:1392];
      top[1] = top_row[1407:1400];
      top[2] = top_row[1415:1408];
      mid[0] = mid_row[1399:1392];
      mid[1] = mid_row[1407:1400];
      mid[2] = mid_row[1415:1408];
      btm[0] = btm_row[1399:1392];
      btm[1] = btm_row[1407:1400];
      btm[2] = btm_row[1415:1408];
    end
    'd176: begin
      top[0] = top_row[1407:1400];
      top[1] = top_row[1415:1408];
      top[2] = top_row[1423:1416];
      mid[0] = mid_row[1407:1400];
      mid[1] = mid_row[1415:1408];
      mid[2] = mid_row[1423:1416];
      btm[0] = btm_row[1407:1400];
      btm[1] = btm_row[1415:1408];
      btm[2] = btm_row[1423:1416];
    end
    'd177: begin
      top[0] = top_row[1415:1408];
      top[1] = top_row[1423:1416];
      top[2] = top_row[1431:1424];
      mid[0] = mid_row[1415:1408];
      mid[1] = mid_row[1423:1416];
      mid[2] = mid_row[1431:1424];
      btm[0] = btm_row[1415:1408];
      btm[1] = btm_row[1423:1416];
      btm[2] = btm_row[1431:1424];
    end
    'd178: begin
      top[0] = top_row[1423:1416];
      top[1] = top_row[1431:1424];
      top[2] = top_row[1439:1432];
      mid[0] = mid_row[1423:1416];
      mid[1] = mid_row[1431:1424];
      mid[2] = mid_row[1439:1432];
      btm[0] = btm_row[1423:1416];
      btm[1] = btm_row[1431:1424];
      btm[2] = btm_row[1439:1432];
    end
    'd179: begin
      top[0] = top_row[1431:1424];
      top[1] = top_row[1439:1432];
      top[2] = top_row[1447:1440];
      mid[0] = mid_row[1431:1424];
      mid[1] = mid_row[1439:1432];
      mid[2] = mid_row[1447:1440];
      btm[0] = btm_row[1431:1424];
      btm[1] = btm_row[1439:1432];
      btm[2] = btm_row[1447:1440];
    end
    'd180: begin
      top[0] = top_row[1439:1432];
      top[1] = top_row[1447:1440];
      top[2] = top_row[1455:1448];
      mid[0] = mid_row[1439:1432];
      mid[1] = mid_row[1447:1440];
      mid[2] = mid_row[1455:1448];
      btm[0] = btm_row[1439:1432];
      btm[1] = btm_row[1447:1440];
      btm[2] = btm_row[1455:1448];
    end
    'd181: begin
      top[0] = top_row[1447:1440];
      top[1] = top_row[1455:1448];
      top[2] = top_row[1463:1456];
      mid[0] = mid_row[1447:1440];
      mid[1] = mid_row[1455:1448];
      mid[2] = mid_row[1463:1456];
      btm[0] = btm_row[1447:1440];
      btm[1] = btm_row[1455:1448];
      btm[2] = btm_row[1463:1456];
    end
    'd182: begin
      top[0] = top_row[1455:1448];
      top[1] = top_row[1463:1456];
      top[2] = top_row[1471:1464];
      mid[0] = mid_row[1455:1448];
      mid[1] = mid_row[1463:1456];
      mid[2] = mid_row[1471:1464];
      btm[0] = btm_row[1455:1448];
      btm[1] = btm_row[1463:1456];
      btm[2] = btm_row[1471:1464];
    end
    'd183: begin
      top[0] = top_row[1463:1456];
      top[1] = top_row[1471:1464];
      top[2] = top_row[1479:1472];
      mid[0] = mid_row[1463:1456];
      mid[1] = mid_row[1471:1464];
      mid[2] = mid_row[1479:1472];
      btm[0] = btm_row[1463:1456];
      btm[1] = btm_row[1471:1464];
      btm[2] = btm_row[1479:1472];
    end
    'd184: begin
      top[0] = top_row[1471:1464];
      top[1] = top_row[1479:1472];
      top[2] = top_row[1487:1480];
      mid[0] = mid_row[1471:1464];
      mid[1] = mid_row[1479:1472];
      mid[2] = mid_row[1487:1480];
      btm[0] = btm_row[1471:1464];
      btm[1] = btm_row[1479:1472];
      btm[2] = btm_row[1487:1480];
    end
    'd185: begin
      top[0] = top_row[1479:1472];
      top[1] = top_row[1487:1480];
      top[2] = top_row[1495:1488];
      mid[0] = mid_row[1479:1472];
      mid[1] = mid_row[1487:1480];
      mid[2] = mid_row[1495:1488];
      btm[0] = btm_row[1479:1472];
      btm[1] = btm_row[1487:1480];
      btm[2] = btm_row[1495:1488];
    end
    'd186: begin
      top[0] = top_row[1487:1480];
      top[1] = top_row[1495:1488];
      top[2] = top_row[1503:1496];
      mid[0] = mid_row[1487:1480];
      mid[1] = mid_row[1495:1488];
      mid[2] = mid_row[1503:1496];
      btm[0] = btm_row[1487:1480];
      btm[1] = btm_row[1495:1488];
      btm[2] = btm_row[1503:1496];
    end
    'd187: begin
      top[0] = top_row[1495:1488];
      top[1] = top_row[1503:1496];
      top[2] = top_row[1511:1504];
      mid[0] = mid_row[1495:1488];
      mid[1] = mid_row[1503:1496];
      mid[2] = mid_row[1511:1504];
      btm[0] = btm_row[1495:1488];
      btm[1] = btm_row[1503:1496];
      btm[2] = btm_row[1511:1504];
    end
    'd188: begin
      top[0] = top_row[1503:1496];
      top[1] = top_row[1511:1504];
      top[2] = top_row[1519:1512];
      mid[0] = mid_row[1503:1496];
      mid[1] = mid_row[1511:1504];
      mid[2] = mid_row[1519:1512];
      btm[0] = btm_row[1503:1496];
      btm[1] = btm_row[1511:1504];
      btm[2] = btm_row[1519:1512];
    end
    'd189: begin
      top[0] = top_row[1511:1504];
      top[1] = top_row[1519:1512];
      top[2] = top_row[1527:1520];
      mid[0] = mid_row[1511:1504];
      mid[1] = mid_row[1519:1512];
      mid[2] = mid_row[1527:1520];
      btm[0] = btm_row[1511:1504];
      btm[1] = btm_row[1519:1512];
      btm[2] = btm_row[1527:1520];
    end
    'd190: begin
      top[0] = top_row[1519:1512];
      top[1] = top_row[1527:1520];
      top[2] = top_row[1535:1528];
      mid[0] = mid_row[1519:1512];
      mid[1] = mid_row[1527:1520];
      mid[2] = mid_row[1535:1528];
      btm[0] = btm_row[1519:1512];
      btm[1] = btm_row[1527:1520];
      btm[2] = btm_row[1535:1528];
    end
    'd191: begin
      top[0] = top_row[1527:1520];
      top[1] = top_row[1535:1528];
      top[2] = top_row[1543:1536];
      mid[0] = mid_row[1527:1520];
      mid[1] = mid_row[1535:1528];
      mid[2] = mid_row[1543:1536];
      btm[0] = btm_row[1527:1520];
      btm[1] = btm_row[1535:1528];
      btm[2] = btm_row[1543:1536];
    end
    'd192: begin
      top[0] = top_row[1535:1528];
      top[1] = top_row[1543:1536];
      top[2] = top_row[1551:1544];
      mid[0] = mid_row[1535:1528];
      mid[1] = mid_row[1543:1536];
      mid[2] = mid_row[1551:1544];
      btm[0] = btm_row[1535:1528];
      btm[1] = btm_row[1543:1536];
      btm[2] = btm_row[1551:1544];
    end
    'd193: begin
      top[0] = top_row[1543:1536];
      top[1] = top_row[1551:1544];
      top[2] = top_row[1559:1552];
      mid[0] = mid_row[1543:1536];
      mid[1] = mid_row[1551:1544];
      mid[2] = mid_row[1559:1552];
      btm[0] = btm_row[1543:1536];
      btm[1] = btm_row[1551:1544];
      btm[2] = btm_row[1559:1552];
    end
    'd194: begin
      top[0] = top_row[1551:1544];
      top[1] = top_row[1559:1552];
      top[2] = top_row[1567:1560];
      mid[0] = mid_row[1551:1544];
      mid[1] = mid_row[1559:1552];
      mid[2] = mid_row[1567:1560];
      btm[0] = btm_row[1551:1544];
      btm[1] = btm_row[1559:1552];
      btm[2] = btm_row[1567:1560];
    end
    'd195: begin
      top[0] = top_row[1559:1552];
      top[1] = top_row[1567:1560];
      top[2] = top_row[1575:1568];
      mid[0] = mid_row[1559:1552];
      mid[1] = mid_row[1567:1560];
      mid[2] = mid_row[1575:1568];
      btm[0] = btm_row[1559:1552];
      btm[1] = btm_row[1567:1560];
      btm[2] = btm_row[1575:1568];
    end
    'd196: begin
      top[0] = top_row[1567:1560];
      top[1] = top_row[1575:1568];
      top[2] = top_row[1583:1576];
      mid[0] = mid_row[1567:1560];
      mid[1] = mid_row[1575:1568];
      mid[2] = mid_row[1583:1576];
      btm[0] = btm_row[1567:1560];
      btm[1] = btm_row[1575:1568];
      btm[2] = btm_row[1583:1576];
    end
    'd197: begin
      top[0] = top_row[1575:1568];
      top[1] = top_row[1583:1576];
      top[2] = top_row[1591:1584];
      mid[0] = mid_row[1575:1568];
      mid[1] = mid_row[1583:1576];
      mid[2] = mid_row[1591:1584];
      btm[0] = btm_row[1575:1568];
      btm[1] = btm_row[1583:1576];
      btm[2] = btm_row[1591:1584];
    end
    'd198: begin
      top[0] = top_row[1583:1576];
      top[1] = top_row[1591:1584];
      top[2] = top_row[1599:1592];
      mid[0] = mid_row[1583:1576];
      mid[1] = mid_row[1591:1584];
      mid[2] = mid_row[1599:1592];
      btm[0] = btm_row[1583:1576];
      btm[1] = btm_row[1591:1584];
      btm[2] = btm_row[1599:1592];
    end
    'd199: begin
      top[0] = top_row[1591:1584];
      top[1] = top_row[1599:1592];
      top[2] = top_row[1607:1600];
      mid[0] = mid_row[1591:1584];
      mid[1] = mid_row[1599:1592];
      mid[2] = mid_row[1607:1600];
      btm[0] = btm_row[1591:1584];
      btm[1] = btm_row[1599:1592];
      btm[2] = btm_row[1607:1600];
    end
    'd200: begin
      top[0] = top_row[1599:1592];
      top[1] = top_row[1607:1600];
      top[2] = top_row[1615:1608];
      mid[0] = mid_row[1599:1592];
      mid[1] = mid_row[1607:1600];
      mid[2] = mid_row[1615:1608];
      btm[0] = btm_row[1599:1592];
      btm[1] = btm_row[1607:1600];
      btm[2] = btm_row[1615:1608];
    end
    'd201: begin
      top[0] = top_row[1607:1600];
      top[1] = top_row[1615:1608];
      top[2] = top_row[1623:1616];
      mid[0] = mid_row[1607:1600];
      mid[1] = mid_row[1615:1608];
      mid[2] = mid_row[1623:1616];
      btm[0] = btm_row[1607:1600];
      btm[1] = btm_row[1615:1608];
      btm[2] = btm_row[1623:1616];
    end
    'd202: begin
      top[0] = top_row[1615:1608];
      top[1] = top_row[1623:1616];
      top[2] = top_row[1631:1624];
      mid[0] = mid_row[1615:1608];
      mid[1] = mid_row[1623:1616];
      mid[2] = mid_row[1631:1624];
      btm[0] = btm_row[1615:1608];
      btm[1] = btm_row[1623:1616];
      btm[2] = btm_row[1631:1624];
    end
    'd203: begin
      top[0] = top_row[1623:1616];
      top[1] = top_row[1631:1624];
      top[2] = top_row[1639:1632];
      mid[0] = mid_row[1623:1616];
      mid[1] = mid_row[1631:1624];
      mid[2] = mid_row[1639:1632];
      btm[0] = btm_row[1623:1616];
      btm[1] = btm_row[1631:1624];
      btm[2] = btm_row[1639:1632];
    end
    'd204: begin
      top[0] = top_row[1631:1624];
      top[1] = top_row[1639:1632];
      top[2] = top_row[1647:1640];
      mid[0] = mid_row[1631:1624];
      mid[1] = mid_row[1639:1632];
      mid[2] = mid_row[1647:1640];
      btm[0] = btm_row[1631:1624];
      btm[1] = btm_row[1639:1632];
      btm[2] = btm_row[1647:1640];
    end
    'd205: begin
      top[0] = top_row[1639:1632];
      top[1] = top_row[1647:1640];
      top[2] = top_row[1655:1648];
      mid[0] = mid_row[1639:1632];
      mid[1] = mid_row[1647:1640];
      mid[2] = mid_row[1655:1648];
      btm[0] = btm_row[1639:1632];
      btm[1] = btm_row[1647:1640];
      btm[2] = btm_row[1655:1648];
    end
    'd206: begin
      top[0] = top_row[1647:1640];
      top[1] = top_row[1655:1648];
      top[2] = top_row[1663:1656];
      mid[0] = mid_row[1647:1640];
      mid[1] = mid_row[1655:1648];
      mid[2] = mid_row[1663:1656];
      btm[0] = btm_row[1647:1640];
      btm[1] = btm_row[1655:1648];
      btm[2] = btm_row[1663:1656];
    end
    'd207: begin
      top[0] = top_row[1655:1648];
      top[1] = top_row[1663:1656];
      top[2] = top_row[1671:1664];
      mid[0] = mid_row[1655:1648];
      mid[1] = mid_row[1663:1656];
      mid[2] = mid_row[1671:1664];
      btm[0] = btm_row[1655:1648];
      btm[1] = btm_row[1663:1656];
      btm[2] = btm_row[1671:1664];
    end
    'd208: begin
      top[0] = top_row[1663:1656];
      top[1] = top_row[1671:1664];
      top[2] = top_row[1679:1672];
      mid[0] = mid_row[1663:1656];
      mid[1] = mid_row[1671:1664];
      mid[2] = mid_row[1679:1672];
      btm[0] = btm_row[1663:1656];
      btm[1] = btm_row[1671:1664];
      btm[2] = btm_row[1679:1672];
    end
    'd209: begin
      top[0] = top_row[1671:1664];
      top[1] = top_row[1679:1672];
      top[2] = top_row[1687:1680];
      mid[0] = mid_row[1671:1664];
      mid[1] = mid_row[1679:1672];
      mid[2] = mid_row[1687:1680];
      btm[0] = btm_row[1671:1664];
      btm[1] = btm_row[1679:1672];
      btm[2] = btm_row[1687:1680];
    end
    'd210: begin
      top[0] = top_row[1679:1672];
      top[1] = top_row[1687:1680];
      top[2] = top_row[1695:1688];
      mid[0] = mid_row[1679:1672];
      mid[1] = mid_row[1687:1680];
      mid[2] = mid_row[1695:1688];
      btm[0] = btm_row[1679:1672];
      btm[1] = btm_row[1687:1680];
      btm[2] = btm_row[1695:1688];
    end
    'd211: begin
      top[0] = top_row[1687:1680];
      top[1] = top_row[1695:1688];
      top[2] = top_row[1703:1696];
      mid[0] = mid_row[1687:1680];
      mid[1] = mid_row[1695:1688];
      mid[2] = mid_row[1703:1696];
      btm[0] = btm_row[1687:1680];
      btm[1] = btm_row[1695:1688];
      btm[2] = btm_row[1703:1696];
    end
    'd212: begin
      top[0] = top_row[1695:1688];
      top[1] = top_row[1703:1696];
      top[2] = top_row[1711:1704];
      mid[0] = mid_row[1695:1688];
      mid[1] = mid_row[1703:1696];
      mid[2] = mid_row[1711:1704];
      btm[0] = btm_row[1695:1688];
      btm[1] = btm_row[1703:1696];
      btm[2] = btm_row[1711:1704];
    end
    'd213: begin
      top[0] = top_row[1703:1696];
      top[1] = top_row[1711:1704];
      top[2] = top_row[1719:1712];
      mid[0] = mid_row[1703:1696];
      mid[1] = mid_row[1711:1704];
      mid[2] = mid_row[1719:1712];
      btm[0] = btm_row[1703:1696];
      btm[1] = btm_row[1711:1704];
      btm[2] = btm_row[1719:1712];
    end
    'd214: begin
      top[0] = top_row[1711:1704];
      top[1] = top_row[1719:1712];
      top[2] = top_row[1727:1720];
      mid[0] = mid_row[1711:1704];
      mid[1] = mid_row[1719:1712];
      mid[2] = mid_row[1727:1720];
      btm[0] = btm_row[1711:1704];
      btm[1] = btm_row[1719:1712];
      btm[2] = btm_row[1727:1720];
    end
    'd215: begin
      top[0] = top_row[1719:1712];
      top[1] = top_row[1727:1720];
      top[2] = top_row[1735:1728];
      mid[0] = mid_row[1719:1712];
      mid[1] = mid_row[1727:1720];
      mid[2] = mid_row[1735:1728];
      btm[0] = btm_row[1719:1712];
      btm[1] = btm_row[1727:1720];
      btm[2] = btm_row[1735:1728];
    end
    'd216: begin
      top[0] = top_row[1727:1720];
      top[1] = top_row[1735:1728];
      top[2] = top_row[1743:1736];
      mid[0] = mid_row[1727:1720];
      mid[1] = mid_row[1735:1728];
      mid[2] = mid_row[1743:1736];
      btm[0] = btm_row[1727:1720];
      btm[1] = btm_row[1735:1728];
      btm[2] = btm_row[1743:1736];
    end
    'd217: begin
      top[0] = top_row[1735:1728];
      top[1] = top_row[1743:1736];
      top[2] = top_row[1751:1744];
      mid[0] = mid_row[1735:1728];
      mid[1] = mid_row[1743:1736];
      mid[2] = mid_row[1751:1744];
      btm[0] = btm_row[1735:1728];
      btm[1] = btm_row[1743:1736];
      btm[2] = btm_row[1751:1744];
    end
    'd218: begin
      top[0] = top_row[1743:1736];
      top[1] = top_row[1751:1744];
      top[2] = top_row[1759:1752];
      mid[0] = mid_row[1743:1736];
      mid[1] = mid_row[1751:1744];
      mid[2] = mid_row[1759:1752];
      btm[0] = btm_row[1743:1736];
      btm[1] = btm_row[1751:1744];
      btm[2] = btm_row[1759:1752];
    end
    'd219: begin
      top[0] = top_row[1751:1744];
      top[1] = top_row[1759:1752];
      top[2] = top_row[1767:1760];
      mid[0] = mid_row[1751:1744];
      mid[1] = mid_row[1759:1752];
      mid[2] = mid_row[1767:1760];
      btm[0] = btm_row[1751:1744];
      btm[1] = btm_row[1759:1752];
      btm[2] = btm_row[1767:1760];
    end
    'd220: begin
      top[0] = top_row[1759:1752];
      top[1] = top_row[1767:1760];
      top[2] = top_row[1775:1768];
      mid[0] = mid_row[1759:1752];
      mid[1] = mid_row[1767:1760];
      mid[2] = mid_row[1775:1768];
      btm[0] = btm_row[1759:1752];
      btm[1] = btm_row[1767:1760];
      btm[2] = btm_row[1775:1768];
    end
    'd221: begin
      top[0] = top_row[1767:1760];
      top[1] = top_row[1775:1768];
      top[2] = top_row[1783:1776];
      mid[0] = mid_row[1767:1760];
      mid[1] = mid_row[1775:1768];
      mid[2] = mid_row[1783:1776];
      btm[0] = btm_row[1767:1760];
      btm[1] = btm_row[1775:1768];
      btm[2] = btm_row[1783:1776];
    end
    'd222: begin
      top[0] = top_row[1775:1768];
      top[1] = top_row[1783:1776];
      top[2] = top_row[1791:1784];
      mid[0] = mid_row[1775:1768];
      mid[1] = mid_row[1783:1776];
      mid[2] = mid_row[1791:1784];
      btm[0] = btm_row[1775:1768];
      btm[1] = btm_row[1783:1776];
      btm[2] = btm_row[1791:1784];
    end
    'd223: begin
      top[0] = top_row[1783:1776];
      top[1] = top_row[1791:1784];
      top[2] = top_row[1799:1792];
      mid[0] = mid_row[1783:1776];
      mid[1] = mid_row[1791:1784];
      mid[2] = mid_row[1799:1792];
      btm[0] = btm_row[1783:1776];
      btm[1] = btm_row[1791:1784];
      btm[2] = btm_row[1799:1792];
    end
    'd224: begin
      top[0] = top_row[1791:1784];
      top[1] = top_row[1799:1792];
      top[2] = top_row[1807:1800];
      mid[0] = mid_row[1791:1784];
      mid[1] = mid_row[1799:1792];
      mid[2] = mid_row[1807:1800];
      btm[0] = btm_row[1791:1784];
      btm[1] = btm_row[1799:1792];
      btm[2] = btm_row[1807:1800];
    end
    'd225: begin
      top[0] = top_row[1799:1792];
      top[1] = top_row[1807:1800];
      top[2] = top_row[1815:1808];
      mid[0] = mid_row[1799:1792];
      mid[1] = mid_row[1807:1800];
      mid[2] = mid_row[1815:1808];
      btm[0] = btm_row[1799:1792];
      btm[1] = btm_row[1807:1800];
      btm[2] = btm_row[1815:1808];
    end
    'd226: begin
      top[0] = top_row[1807:1800];
      top[1] = top_row[1815:1808];
      top[2] = top_row[1823:1816];
      mid[0] = mid_row[1807:1800];
      mid[1] = mid_row[1815:1808];
      mid[2] = mid_row[1823:1816];
      btm[0] = btm_row[1807:1800];
      btm[1] = btm_row[1815:1808];
      btm[2] = btm_row[1823:1816];
    end
    'd227: begin
      top[0] = top_row[1815:1808];
      top[1] = top_row[1823:1816];
      top[2] = top_row[1831:1824];
      mid[0] = mid_row[1815:1808];
      mid[1] = mid_row[1823:1816];
      mid[2] = mid_row[1831:1824];
      btm[0] = btm_row[1815:1808];
      btm[1] = btm_row[1823:1816];
      btm[2] = btm_row[1831:1824];
    end
    'd228: begin
      top[0] = top_row[1823:1816];
      top[1] = top_row[1831:1824];
      top[2] = top_row[1839:1832];
      mid[0] = mid_row[1823:1816];
      mid[1] = mid_row[1831:1824];
      mid[2] = mid_row[1839:1832];
      btm[0] = btm_row[1823:1816];
      btm[1] = btm_row[1831:1824];
      btm[2] = btm_row[1839:1832];
    end
    'd229: begin
      top[0] = top_row[1831:1824];
      top[1] = top_row[1839:1832];
      top[2] = top_row[1847:1840];
      mid[0] = mid_row[1831:1824];
      mid[1] = mid_row[1839:1832];
      mid[2] = mid_row[1847:1840];
      btm[0] = btm_row[1831:1824];
      btm[1] = btm_row[1839:1832];
      btm[2] = btm_row[1847:1840];
    end
    'd230: begin
      top[0] = top_row[1839:1832];
      top[1] = top_row[1847:1840];
      top[2] = top_row[1855:1848];
      mid[0] = mid_row[1839:1832];
      mid[1] = mid_row[1847:1840];
      mid[2] = mid_row[1855:1848];
      btm[0] = btm_row[1839:1832];
      btm[1] = btm_row[1847:1840];
      btm[2] = btm_row[1855:1848];
    end
    'd231: begin
      top[0] = top_row[1847:1840];
      top[1] = top_row[1855:1848];
      top[2] = top_row[1863:1856];
      mid[0] = mid_row[1847:1840];
      mid[1] = mid_row[1855:1848];
      mid[2] = mid_row[1863:1856];
      btm[0] = btm_row[1847:1840];
      btm[1] = btm_row[1855:1848];
      btm[2] = btm_row[1863:1856];
    end
    'd232: begin
      top[0] = top_row[1855:1848];
      top[1] = top_row[1863:1856];
      top[2] = top_row[1871:1864];
      mid[0] = mid_row[1855:1848];
      mid[1] = mid_row[1863:1856];
      mid[2] = mid_row[1871:1864];
      btm[0] = btm_row[1855:1848];
      btm[1] = btm_row[1863:1856];
      btm[2] = btm_row[1871:1864];
    end
    'd233: begin
      top[0] = top_row[1863:1856];
      top[1] = top_row[1871:1864];
      top[2] = top_row[1879:1872];
      mid[0] = mid_row[1863:1856];
      mid[1] = mid_row[1871:1864];
      mid[2] = mid_row[1879:1872];
      btm[0] = btm_row[1863:1856];
      btm[1] = btm_row[1871:1864];
      btm[2] = btm_row[1879:1872];
    end
    'd234: begin
      top[0] = top_row[1871:1864];
      top[1] = top_row[1879:1872];
      top[2] = top_row[1887:1880];
      mid[0] = mid_row[1871:1864];
      mid[1] = mid_row[1879:1872];
      mid[2] = mid_row[1887:1880];
      btm[0] = btm_row[1871:1864];
      btm[1] = btm_row[1879:1872];
      btm[2] = btm_row[1887:1880];
    end
    'd235: begin
      top[0] = top_row[1879:1872];
      top[1] = top_row[1887:1880];
      top[2] = top_row[1895:1888];
      mid[0] = mid_row[1879:1872];
      mid[1] = mid_row[1887:1880];
      mid[2] = mid_row[1895:1888];
      btm[0] = btm_row[1879:1872];
      btm[1] = btm_row[1887:1880];
      btm[2] = btm_row[1895:1888];
    end
    'd236: begin
      top[0] = top_row[1887:1880];
      top[1] = top_row[1895:1888];
      top[2] = top_row[1903:1896];
      mid[0] = mid_row[1887:1880];
      mid[1] = mid_row[1895:1888];
      mid[2] = mid_row[1903:1896];
      btm[0] = btm_row[1887:1880];
      btm[1] = btm_row[1895:1888];
      btm[2] = btm_row[1903:1896];
    end
    'd237: begin
      top[0] = top_row[1895:1888];
      top[1] = top_row[1903:1896];
      top[2] = top_row[1911:1904];
      mid[0] = mid_row[1895:1888];
      mid[1] = mid_row[1903:1896];
      mid[2] = mid_row[1911:1904];
      btm[0] = btm_row[1895:1888];
      btm[1] = btm_row[1903:1896];
      btm[2] = btm_row[1911:1904];
    end
    'd238: begin
      top[0] = top_row[1903:1896];
      top[1] = top_row[1911:1904];
      top[2] = top_row[1919:1912];
      mid[0] = mid_row[1903:1896];
      mid[1] = mid_row[1911:1904];
      mid[2] = mid_row[1919:1912];
      btm[0] = btm_row[1903:1896];
      btm[1] = btm_row[1911:1904];
      btm[2] = btm_row[1919:1912];
    end
    'd239: begin
      top[0] = top_row[1911:1904];
      top[1] = top_row[1919:1912];
      top[2] = top_row[1927:1920];
      mid[0] = mid_row[1911:1904];
      mid[1] = mid_row[1919:1912];
      mid[2] = mid_row[1927:1920];
      btm[0] = btm_row[1911:1904];
      btm[1] = btm_row[1919:1912];
      btm[2] = btm_row[1927:1920];
    end
    'd240: begin
      top[0] = top_row[1919:1912];
      top[1] = top_row[1927:1920];
      top[2] = top_row[1935:1928];
      mid[0] = mid_row[1919:1912];
      mid[1] = mid_row[1927:1920];
      mid[2] = mid_row[1935:1928];
      btm[0] = btm_row[1919:1912];
      btm[1] = btm_row[1927:1920];
      btm[2] = btm_row[1935:1928];
    end
    'd241: begin
      top[0] = top_row[1927:1920];
      top[1] = top_row[1935:1928];
      top[2] = top_row[1943:1936];
      mid[0] = mid_row[1927:1920];
      mid[1] = mid_row[1935:1928];
      mid[2] = mid_row[1943:1936];
      btm[0] = btm_row[1927:1920];
      btm[1] = btm_row[1935:1928];
      btm[2] = btm_row[1943:1936];
    end
    'd242: begin
      top[0] = top_row[1935:1928];
      top[1] = top_row[1943:1936];
      top[2] = top_row[1951:1944];
      mid[0] = mid_row[1935:1928];
      mid[1] = mid_row[1943:1936];
      mid[2] = mid_row[1951:1944];
      btm[0] = btm_row[1935:1928];
      btm[1] = btm_row[1943:1936];
      btm[2] = btm_row[1951:1944];
    end
    'd243: begin
      top[0] = top_row[1943:1936];
      top[1] = top_row[1951:1944];
      top[2] = top_row[1959:1952];
      mid[0] = mid_row[1943:1936];
      mid[1] = mid_row[1951:1944];
      mid[2] = mid_row[1959:1952];
      btm[0] = btm_row[1943:1936];
      btm[1] = btm_row[1951:1944];
      btm[2] = btm_row[1959:1952];
    end
    'd244: begin
      top[0] = top_row[1951:1944];
      top[1] = top_row[1959:1952];
      top[2] = top_row[1967:1960];
      mid[0] = mid_row[1951:1944];
      mid[1] = mid_row[1959:1952];
      mid[2] = mid_row[1967:1960];
      btm[0] = btm_row[1951:1944];
      btm[1] = btm_row[1959:1952];
      btm[2] = btm_row[1967:1960];
    end
    'd245: begin
      top[0] = top_row[1959:1952];
      top[1] = top_row[1967:1960];
      top[2] = top_row[1975:1968];
      mid[0] = mid_row[1959:1952];
      mid[1] = mid_row[1967:1960];
      mid[2] = mid_row[1975:1968];
      btm[0] = btm_row[1959:1952];
      btm[1] = btm_row[1967:1960];
      btm[2] = btm_row[1975:1968];
    end
    'd246: begin
      top[0] = top_row[1967:1960];
      top[1] = top_row[1975:1968];
      top[2] = top_row[1983:1976];
      mid[0] = mid_row[1967:1960];
      mid[1] = mid_row[1975:1968];
      mid[2] = mid_row[1983:1976];
      btm[0] = btm_row[1967:1960];
      btm[1] = btm_row[1975:1968];
      btm[2] = btm_row[1983:1976];
    end
    'd247: begin
      top[0] = top_row[1975:1968];
      top[1] = top_row[1983:1976];
      top[2] = top_row[1991:1984];
      mid[0] = mid_row[1975:1968];
      mid[1] = mid_row[1983:1976];
      mid[2] = mid_row[1991:1984];
      btm[0] = btm_row[1975:1968];
      btm[1] = btm_row[1983:1976];
      btm[2] = btm_row[1991:1984];
    end
    'd248: begin
      top[0] = top_row[1983:1976];
      top[1] = top_row[1991:1984];
      top[2] = top_row[1999:1992];
      mid[0] = mid_row[1983:1976];
      mid[1] = mid_row[1991:1984];
      mid[2] = mid_row[1999:1992];
      btm[0] = btm_row[1983:1976];
      btm[1] = btm_row[1991:1984];
      btm[2] = btm_row[1999:1992];
    end
    'd249: begin
      top[0] = top_row[1991:1984];
      top[1] = top_row[1999:1992];
      top[2] = top_row[2007:2000];
      mid[0] = mid_row[1991:1984];
      mid[1] = mid_row[1999:1992];
      mid[2] = mid_row[2007:2000];
      btm[0] = btm_row[1991:1984];
      btm[1] = btm_row[1999:1992];
      btm[2] = btm_row[2007:2000];
    end
    'd250: begin
      top[0] = top_row[1999:1992];
      top[1] = top_row[2007:2000];
      top[2] = top_row[2015:2008];
      mid[0] = mid_row[1999:1992];
      mid[1] = mid_row[2007:2000];
      mid[2] = mid_row[2015:2008];
      btm[0] = btm_row[1999:1992];
      btm[1] = btm_row[2007:2000];
      btm[2] = btm_row[2015:2008];
    end
    'd251: begin
      top[0] = top_row[2007:2000];
      top[1] = top_row[2015:2008];
      top[2] = top_row[2023:2016];
      mid[0] = mid_row[2007:2000];
      mid[1] = mid_row[2015:2008];
      mid[2] = mid_row[2023:2016];
      btm[0] = btm_row[2007:2000];
      btm[1] = btm_row[2015:2008];
      btm[2] = btm_row[2023:2016];
    end
    'd252: begin
      top[0] = top_row[2015:2008];
      top[1] = top_row[2023:2016];
      top[2] = top_row[2031:2024];
      mid[0] = mid_row[2015:2008];
      mid[1] = mid_row[2023:2016];
      mid[2] = mid_row[2031:2024];
      btm[0] = btm_row[2015:2008];
      btm[1] = btm_row[2023:2016];
      btm[2] = btm_row[2031:2024];
    end
    'd253: begin
      top[0] = top_row[2023:2016];
      top[1] = top_row[2031:2024];
      top[2] = top_row[2039:2032];
      mid[0] = mid_row[2023:2016];
      mid[1] = mid_row[2031:2024];
      mid[2] = mid_row[2039:2032];
      btm[0] = btm_row[2023:2016];
      btm[1] = btm_row[2031:2024];
      btm[2] = btm_row[2039:2032];
    end
    'd254: begin
      top[0] = top_row[2031:2024];
      top[1] = top_row[2039:2032];
      top[2] = top_row[2047:2040];
      mid[0] = mid_row[2031:2024];
      mid[1] = mid_row[2039:2032];
      mid[2] = mid_row[2047:2040];
      btm[0] = btm_row[2031:2024];
      btm[1] = btm_row[2039:2032];
      btm[2] = btm_row[2047:2040];
    end
    'd255: begin
      top[0] = top_row[2039:2032];
      top[1] = top_row[2047:2040];
      top[2] = top_row[2055:2048];
      mid[0] = mid_row[2039:2032];
      mid[1] = mid_row[2047:2040];
      mid[2] = mid_row[2055:2048];
      btm[0] = btm_row[2039:2032];
      btm[1] = btm_row[2047:2040];
      btm[2] = btm_row[2055:2048];
    end
    'd256: begin
      top[0] = top_row[2047:2040];
      top[1] = top_row[2055:2048];
      top[2] = top_row[2063:2056];
      mid[0] = mid_row[2047:2040];
      mid[1] = mid_row[2055:2048];
      mid[2] = mid_row[2063:2056];
      btm[0] = btm_row[2047:2040];
      btm[1] = btm_row[2055:2048];
      btm[2] = btm_row[2063:2056];
    end
    'd257: begin
      top[0] = top_row[2055:2048];
      top[1] = top_row[2063:2056];
      top[2] = top_row[2071:2064];
      mid[0] = mid_row[2055:2048];
      mid[1] = mid_row[2063:2056];
      mid[2] = mid_row[2071:2064];
      btm[0] = btm_row[2055:2048];
      btm[1] = btm_row[2063:2056];
      btm[2] = btm_row[2071:2064];
    end
    'd258: begin
      top[0] = top_row[2063:2056];
      top[1] = top_row[2071:2064];
      top[2] = top_row[2079:2072];
      mid[0] = mid_row[2063:2056];
      mid[1] = mid_row[2071:2064];
      mid[2] = mid_row[2079:2072];
      btm[0] = btm_row[2063:2056];
      btm[1] = btm_row[2071:2064];
      btm[2] = btm_row[2079:2072];
    end
    'd259: begin
      top[0] = top_row[2071:2064];
      top[1] = top_row[2079:2072];
      top[2] = top_row[2087:2080];
      mid[0] = mid_row[2071:2064];
      mid[1] = mid_row[2079:2072];
      mid[2] = mid_row[2087:2080];
      btm[0] = btm_row[2071:2064];
      btm[1] = btm_row[2079:2072];
      btm[2] = btm_row[2087:2080];
    end
    'd260: begin
      top[0] = top_row[2079:2072];
      top[1] = top_row[2087:2080];
      top[2] = top_row[2095:2088];
      mid[0] = mid_row[2079:2072];
      mid[1] = mid_row[2087:2080];
      mid[2] = mid_row[2095:2088];
      btm[0] = btm_row[2079:2072];
      btm[1] = btm_row[2087:2080];
      btm[2] = btm_row[2095:2088];
    end
    'd261: begin
      top[0] = top_row[2087:2080];
      top[1] = top_row[2095:2088];
      top[2] = top_row[2103:2096];
      mid[0] = mid_row[2087:2080];
      mid[1] = mid_row[2095:2088];
      mid[2] = mid_row[2103:2096];
      btm[0] = btm_row[2087:2080];
      btm[1] = btm_row[2095:2088];
      btm[2] = btm_row[2103:2096];
    end
    'd262: begin
      top[0] = top_row[2095:2088];
      top[1] = top_row[2103:2096];
      top[2] = top_row[2111:2104];
      mid[0] = mid_row[2095:2088];
      mid[1] = mid_row[2103:2096];
      mid[2] = mid_row[2111:2104];
      btm[0] = btm_row[2095:2088];
      btm[1] = btm_row[2103:2096];
      btm[2] = btm_row[2111:2104];
    end
    'd263: begin
      top[0] = top_row[2103:2096];
      top[1] = top_row[2111:2104];
      top[2] = top_row[2119:2112];
      mid[0] = mid_row[2103:2096];
      mid[1] = mid_row[2111:2104];
      mid[2] = mid_row[2119:2112];
      btm[0] = btm_row[2103:2096];
      btm[1] = btm_row[2111:2104];
      btm[2] = btm_row[2119:2112];
    end
    'd264: begin
      top[0] = top_row[2111:2104];
      top[1] = top_row[2119:2112];
      top[2] = top_row[2127:2120];
      mid[0] = mid_row[2111:2104];
      mid[1] = mid_row[2119:2112];
      mid[2] = mid_row[2127:2120];
      btm[0] = btm_row[2111:2104];
      btm[1] = btm_row[2119:2112];
      btm[2] = btm_row[2127:2120];
    end
    'd265: begin
      top[0] = top_row[2119:2112];
      top[1] = top_row[2127:2120];
      top[2] = top_row[2135:2128];
      mid[0] = mid_row[2119:2112];
      mid[1] = mid_row[2127:2120];
      mid[2] = mid_row[2135:2128];
      btm[0] = btm_row[2119:2112];
      btm[1] = btm_row[2127:2120];
      btm[2] = btm_row[2135:2128];
    end
    'd266: begin
      top[0] = top_row[2127:2120];
      top[1] = top_row[2135:2128];
      top[2] = top_row[2143:2136];
      mid[0] = mid_row[2127:2120];
      mid[1] = mid_row[2135:2128];
      mid[2] = mid_row[2143:2136];
      btm[0] = btm_row[2127:2120];
      btm[1] = btm_row[2135:2128];
      btm[2] = btm_row[2143:2136];
    end
    'd267: begin
      top[0] = top_row[2135:2128];
      top[1] = top_row[2143:2136];
      top[2] = top_row[2151:2144];
      mid[0] = mid_row[2135:2128];
      mid[1] = mid_row[2143:2136];
      mid[2] = mid_row[2151:2144];
      btm[0] = btm_row[2135:2128];
      btm[1] = btm_row[2143:2136];
      btm[2] = btm_row[2151:2144];
    end
    'd268: begin
      top[0] = top_row[2143:2136];
      top[1] = top_row[2151:2144];
      top[2] = top_row[2159:2152];
      mid[0] = mid_row[2143:2136];
      mid[1] = mid_row[2151:2144];
      mid[2] = mid_row[2159:2152];
      btm[0] = btm_row[2143:2136];
      btm[1] = btm_row[2151:2144];
      btm[2] = btm_row[2159:2152];
    end
    'd269: begin
      top[0] = top_row[2151:2144];
      top[1] = top_row[2159:2152];
      top[2] = top_row[2167:2160];
      mid[0] = mid_row[2151:2144];
      mid[1] = mid_row[2159:2152];
      mid[2] = mid_row[2167:2160];
      btm[0] = btm_row[2151:2144];
      btm[1] = btm_row[2159:2152];
      btm[2] = btm_row[2167:2160];
    end
    'd270: begin
      top[0] = top_row[2159:2152];
      top[1] = top_row[2167:2160];
      top[2] = top_row[2175:2168];
      mid[0] = mid_row[2159:2152];
      mid[1] = mid_row[2167:2160];
      mid[2] = mid_row[2175:2168];
      btm[0] = btm_row[2159:2152];
      btm[1] = btm_row[2167:2160];
      btm[2] = btm_row[2175:2168];
    end
    'd271: begin
      top[0] = top_row[2167:2160];
      top[1] = top_row[2175:2168];
      top[2] = top_row[2183:2176];
      mid[0] = mid_row[2167:2160];
      mid[1] = mid_row[2175:2168];
      mid[2] = mid_row[2183:2176];
      btm[0] = btm_row[2167:2160];
      btm[1] = btm_row[2175:2168];
      btm[2] = btm_row[2183:2176];
    end
    'd272: begin
      top[0] = top_row[2175:2168];
      top[1] = top_row[2183:2176];
      top[2] = top_row[2191:2184];
      mid[0] = mid_row[2175:2168];
      mid[1] = mid_row[2183:2176];
      mid[2] = mid_row[2191:2184];
      btm[0] = btm_row[2175:2168];
      btm[1] = btm_row[2183:2176];
      btm[2] = btm_row[2191:2184];
    end
    'd273: begin
      top[0] = top_row[2183:2176];
      top[1] = top_row[2191:2184];
      top[2] = top_row[2199:2192];
      mid[0] = mid_row[2183:2176];
      mid[1] = mid_row[2191:2184];
      mid[2] = mid_row[2199:2192];
      btm[0] = btm_row[2183:2176];
      btm[1] = btm_row[2191:2184];
      btm[2] = btm_row[2199:2192];
    end
    'd274: begin
      top[0] = top_row[2191:2184];
      top[1] = top_row[2199:2192];
      top[2] = top_row[2207:2200];
      mid[0] = mid_row[2191:2184];
      mid[1] = mid_row[2199:2192];
      mid[2] = mid_row[2207:2200];
      btm[0] = btm_row[2191:2184];
      btm[1] = btm_row[2199:2192];
      btm[2] = btm_row[2207:2200];
    end
    'd275: begin
      top[0] = top_row[2199:2192];
      top[1] = top_row[2207:2200];
      top[2] = top_row[2215:2208];
      mid[0] = mid_row[2199:2192];
      mid[1] = mid_row[2207:2200];
      mid[2] = mid_row[2215:2208];
      btm[0] = btm_row[2199:2192];
      btm[1] = btm_row[2207:2200];
      btm[2] = btm_row[2215:2208];
    end
    'd276: begin
      top[0] = top_row[2207:2200];
      top[1] = top_row[2215:2208];
      top[2] = top_row[2223:2216];
      mid[0] = mid_row[2207:2200];
      mid[1] = mid_row[2215:2208];
      mid[2] = mid_row[2223:2216];
      btm[0] = btm_row[2207:2200];
      btm[1] = btm_row[2215:2208];
      btm[2] = btm_row[2223:2216];
    end
    'd277: begin
      top[0] = top_row[2215:2208];
      top[1] = top_row[2223:2216];
      top[2] = top_row[2231:2224];
      mid[0] = mid_row[2215:2208];
      mid[1] = mid_row[2223:2216];
      mid[2] = mid_row[2231:2224];
      btm[0] = btm_row[2215:2208];
      btm[1] = btm_row[2223:2216];
      btm[2] = btm_row[2231:2224];
    end
    'd278: begin
      top[0] = top_row[2223:2216];
      top[1] = top_row[2231:2224];
      top[2] = top_row[2239:2232];
      mid[0] = mid_row[2223:2216];
      mid[1] = mid_row[2231:2224];
      mid[2] = mid_row[2239:2232];
      btm[0] = btm_row[2223:2216];
      btm[1] = btm_row[2231:2224];
      btm[2] = btm_row[2239:2232];
    end
    'd279: begin
      top[0] = top_row[2231:2224];
      top[1] = top_row[2239:2232];
      top[2] = top_row[2247:2240];
      mid[0] = mid_row[2231:2224];
      mid[1] = mid_row[2239:2232];
      mid[2] = mid_row[2247:2240];
      btm[0] = btm_row[2231:2224];
      btm[1] = btm_row[2239:2232];
      btm[2] = btm_row[2247:2240];
    end
    'd280: begin
      top[0] = top_row[2239:2232];
      top[1] = top_row[2247:2240];
      top[2] = top_row[2255:2248];
      mid[0] = mid_row[2239:2232];
      mid[1] = mid_row[2247:2240];
      mid[2] = mid_row[2255:2248];
      btm[0] = btm_row[2239:2232];
      btm[1] = btm_row[2247:2240];
      btm[2] = btm_row[2255:2248];
    end
    'd281: begin
      top[0] = top_row[2247:2240];
      top[1] = top_row[2255:2248];
      top[2] = top_row[2263:2256];
      mid[0] = mid_row[2247:2240];
      mid[1] = mid_row[2255:2248];
      mid[2] = mid_row[2263:2256];
      btm[0] = btm_row[2247:2240];
      btm[1] = btm_row[2255:2248];
      btm[2] = btm_row[2263:2256];
    end
    'd282: begin
      top[0] = top_row[2255:2248];
      top[1] = top_row[2263:2256];
      top[2] = top_row[2271:2264];
      mid[0] = mid_row[2255:2248];
      mid[1] = mid_row[2263:2256];
      mid[2] = mid_row[2271:2264];
      btm[0] = btm_row[2255:2248];
      btm[1] = btm_row[2263:2256];
      btm[2] = btm_row[2271:2264];
    end
    'd283: begin
      top[0] = top_row[2263:2256];
      top[1] = top_row[2271:2264];
      top[2] = top_row[2279:2272];
      mid[0] = mid_row[2263:2256];
      mid[1] = mid_row[2271:2264];
      mid[2] = mid_row[2279:2272];
      btm[0] = btm_row[2263:2256];
      btm[1] = btm_row[2271:2264];
      btm[2] = btm_row[2279:2272];
    end
    'd284: begin
      top[0] = top_row[2271:2264];
      top[1] = top_row[2279:2272];
      top[2] = top_row[2287:2280];
      mid[0] = mid_row[2271:2264];
      mid[1] = mid_row[2279:2272];
      mid[2] = mid_row[2287:2280];
      btm[0] = btm_row[2271:2264];
      btm[1] = btm_row[2279:2272];
      btm[2] = btm_row[2287:2280];
    end
    'd285: begin
      top[0] = top_row[2279:2272];
      top[1] = top_row[2287:2280];
      top[2] = top_row[2295:2288];
      mid[0] = mid_row[2279:2272];
      mid[1] = mid_row[2287:2280];
      mid[2] = mid_row[2295:2288];
      btm[0] = btm_row[2279:2272];
      btm[1] = btm_row[2287:2280];
      btm[2] = btm_row[2295:2288];
    end
    'd286: begin
      top[0] = top_row[2287:2280];
      top[1] = top_row[2295:2288];
      top[2] = top_row[2303:2296];
      mid[0] = mid_row[2287:2280];
      mid[1] = mid_row[2295:2288];
      mid[2] = mid_row[2303:2296];
      btm[0] = btm_row[2287:2280];
      btm[1] = btm_row[2295:2288];
      btm[2] = btm_row[2303:2296];
    end
    'd287: begin
      top[0] = top_row[2295:2288];
      top[1] = top_row[2303:2296];
      top[2] = top_row[2311:2304];
      mid[0] = mid_row[2295:2288];
      mid[1] = mid_row[2303:2296];
      mid[2] = mid_row[2311:2304];
      btm[0] = btm_row[2295:2288];
      btm[1] = btm_row[2303:2296];
      btm[2] = btm_row[2311:2304];
    end
    'd288: begin
      top[0] = top_row[2303:2296];
      top[1] = top_row[2311:2304];
      top[2] = top_row[2319:2312];
      mid[0] = mid_row[2303:2296];
      mid[1] = mid_row[2311:2304];
      mid[2] = mid_row[2319:2312];
      btm[0] = btm_row[2303:2296];
      btm[1] = btm_row[2311:2304];
      btm[2] = btm_row[2319:2312];
    end
    'd289: begin
      top[0] = top_row[2311:2304];
      top[1] = top_row[2319:2312];
      top[2] = top_row[2327:2320];
      mid[0] = mid_row[2311:2304];
      mid[1] = mid_row[2319:2312];
      mid[2] = mid_row[2327:2320];
      btm[0] = btm_row[2311:2304];
      btm[1] = btm_row[2319:2312];
      btm[2] = btm_row[2327:2320];
    end
    'd290: begin
      top[0] = top_row[2319:2312];
      top[1] = top_row[2327:2320];
      top[2] = top_row[2335:2328];
      mid[0] = mid_row[2319:2312];
      mid[1] = mid_row[2327:2320];
      mid[2] = mid_row[2335:2328];
      btm[0] = btm_row[2319:2312];
      btm[1] = btm_row[2327:2320];
      btm[2] = btm_row[2335:2328];
    end
    'd291: begin
      top[0] = top_row[2327:2320];
      top[1] = top_row[2335:2328];
      top[2] = top_row[2343:2336];
      mid[0] = mid_row[2327:2320];
      mid[1] = mid_row[2335:2328];
      mid[2] = mid_row[2343:2336];
      btm[0] = btm_row[2327:2320];
      btm[1] = btm_row[2335:2328];
      btm[2] = btm_row[2343:2336];
    end
    'd292: begin
      top[0] = top_row[2335:2328];
      top[1] = top_row[2343:2336];
      top[2] = top_row[2351:2344];
      mid[0] = mid_row[2335:2328];
      mid[1] = mid_row[2343:2336];
      mid[2] = mid_row[2351:2344];
      btm[0] = btm_row[2335:2328];
      btm[1] = btm_row[2343:2336];
      btm[2] = btm_row[2351:2344];
    end
    'd293: begin
      top[0] = top_row[2343:2336];
      top[1] = top_row[2351:2344];
      top[2] = top_row[2359:2352];
      mid[0] = mid_row[2343:2336];
      mid[1] = mid_row[2351:2344];
      mid[2] = mid_row[2359:2352];
      btm[0] = btm_row[2343:2336];
      btm[1] = btm_row[2351:2344];
      btm[2] = btm_row[2359:2352];
    end
    'd294: begin
      top[0] = top_row[2351:2344];
      top[1] = top_row[2359:2352];
      top[2] = top_row[2367:2360];
      mid[0] = mid_row[2351:2344];
      mid[1] = mid_row[2359:2352];
      mid[2] = mid_row[2367:2360];
      btm[0] = btm_row[2351:2344];
      btm[1] = btm_row[2359:2352];
      btm[2] = btm_row[2367:2360];
    end
    'd295: begin
      top[0] = top_row[2359:2352];
      top[1] = top_row[2367:2360];
      top[2] = top_row[2375:2368];
      mid[0] = mid_row[2359:2352];
      mid[1] = mid_row[2367:2360];
      mid[2] = mid_row[2375:2368];
      btm[0] = btm_row[2359:2352];
      btm[1] = btm_row[2367:2360];
      btm[2] = btm_row[2375:2368];
    end
    'd296: begin
      top[0] = top_row[2367:2360];
      top[1] = top_row[2375:2368];
      top[2] = top_row[2383:2376];
      mid[0] = mid_row[2367:2360];
      mid[1] = mid_row[2375:2368];
      mid[2] = mid_row[2383:2376];
      btm[0] = btm_row[2367:2360];
      btm[1] = btm_row[2375:2368];
      btm[2] = btm_row[2383:2376];
    end
    'd297: begin
      top[0] = top_row[2375:2368];
      top[1] = top_row[2383:2376];
      top[2] = top_row[2391:2384];
      mid[0] = mid_row[2375:2368];
      mid[1] = mid_row[2383:2376];
      mid[2] = mid_row[2391:2384];
      btm[0] = btm_row[2375:2368];
      btm[1] = btm_row[2383:2376];
      btm[2] = btm_row[2391:2384];
    end
    'd298: begin
      top[0] = top_row[2383:2376];
      top[1] = top_row[2391:2384];
      top[2] = top_row[2399:2392];
      mid[0] = mid_row[2383:2376];
      mid[1] = mid_row[2391:2384];
      mid[2] = mid_row[2399:2392];
      btm[0] = btm_row[2383:2376];
      btm[1] = btm_row[2391:2384];
      btm[2] = btm_row[2399:2392];
    end
    'd299: begin
      top[0] = top_row[2391:2384];
      top[1] = top_row[2399:2392];
      top[2] = top_row[2407:2400];
      mid[0] = mid_row[2391:2384];
      mid[1] = mid_row[2399:2392];
      mid[2] = mid_row[2407:2400];
      btm[0] = btm_row[2391:2384];
      btm[1] = btm_row[2399:2392];
      btm[2] = btm_row[2407:2400];
    end
    'd300: begin
      top[0] = top_row[2399:2392];
      top[1] = top_row[2407:2400];
      top[2] = top_row[2415:2408];
      mid[0] = mid_row[2399:2392];
      mid[1] = mid_row[2407:2400];
      mid[2] = mid_row[2415:2408];
      btm[0] = btm_row[2399:2392];
      btm[1] = btm_row[2407:2400];
      btm[2] = btm_row[2415:2408];
    end
    'd301: begin
      top[0] = top_row[2407:2400];
      top[1] = top_row[2415:2408];
      top[2] = top_row[2423:2416];
      mid[0] = mid_row[2407:2400];
      mid[1] = mid_row[2415:2408];
      mid[2] = mid_row[2423:2416];
      btm[0] = btm_row[2407:2400];
      btm[1] = btm_row[2415:2408];
      btm[2] = btm_row[2423:2416];
    end
    'd302: begin
      top[0] = top_row[2415:2408];
      top[1] = top_row[2423:2416];
      top[2] = top_row[2431:2424];
      mid[0] = mid_row[2415:2408];
      mid[1] = mid_row[2423:2416];
      mid[2] = mid_row[2431:2424];
      btm[0] = btm_row[2415:2408];
      btm[1] = btm_row[2423:2416];
      btm[2] = btm_row[2431:2424];
    end
    'd303: begin
      top[0] = top_row[2423:2416];
      top[1] = top_row[2431:2424];
      top[2] = top_row[2439:2432];
      mid[0] = mid_row[2423:2416];
      mid[1] = mid_row[2431:2424];
      mid[2] = mid_row[2439:2432];
      btm[0] = btm_row[2423:2416];
      btm[1] = btm_row[2431:2424];
      btm[2] = btm_row[2439:2432];
    end
    'd304: begin
      top[0] = top_row[2431:2424];
      top[1] = top_row[2439:2432];
      top[2] = top_row[2447:2440];
      mid[0] = mid_row[2431:2424];
      mid[1] = mid_row[2439:2432];
      mid[2] = mid_row[2447:2440];
      btm[0] = btm_row[2431:2424];
      btm[1] = btm_row[2439:2432];
      btm[2] = btm_row[2447:2440];
    end
    'd305: begin
      top[0] = top_row[2439:2432];
      top[1] = top_row[2447:2440];
      top[2] = top_row[2455:2448];
      mid[0] = mid_row[2439:2432];
      mid[1] = mid_row[2447:2440];
      mid[2] = mid_row[2455:2448];
      btm[0] = btm_row[2439:2432];
      btm[1] = btm_row[2447:2440];
      btm[2] = btm_row[2455:2448];
    end
    'd306: begin
      top[0] = top_row[2447:2440];
      top[1] = top_row[2455:2448];
      top[2] = top_row[2463:2456];
      mid[0] = mid_row[2447:2440];
      mid[1] = mid_row[2455:2448];
      mid[2] = mid_row[2463:2456];
      btm[0] = btm_row[2447:2440];
      btm[1] = btm_row[2455:2448];
      btm[2] = btm_row[2463:2456];
    end
    'd307: begin
      top[0] = top_row[2455:2448];
      top[1] = top_row[2463:2456];
      top[2] = top_row[2471:2464];
      mid[0] = mid_row[2455:2448];
      mid[1] = mid_row[2463:2456];
      mid[2] = mid_row[2471:2464];
      btm[0] = btm_row[2455:2448];
      btm[1] = btm_row[2463:2456];
      btm[2] = btm_row[2471:2464];
    end
    'd308: begin
      top[0] = top_row[2463:2456];
      top[1] = top_row[2471:2464];
      top[2] = top_row[2479:2472];
      mid[0] = mid_row[2463:2456];
      mid[1] = mid_row[2471:2464];
      mid[2] = mid_row[2479:2472];
      btm[0] = btm_row[2463:2456];
      btm[1] = btm_row[2471:2464];
      btm[2] = btm_row[2479:2472];
    end
    'd309: begin
      top[0] = top_row[2471:2464];
      top[1] = top_row[2479:2472];
      top[2] = top_row[2487:2480];
      mid[0] = mid_row[2471:2464];
      mid[1] = mid_row[2479:2472];
      mid[2] = mid_row[2487:2480];
      btm[0] = btm_row[2471:2464];
      btm[1] = btm_row[2479:2472];
      btm[2] = btm_row[2487:2480];
    end
    'd310: begin
      top[0] = top_row[2479:2472];
      top[1] = top_row[2487:2480];
      top[2] = top_row[2495:2488];
      mid[0] = mid_row[2479:2472];
      mid[1] = mid_row[2487:2480];
      mid[2] = mid_row[2495:2488];
      btm[0] = btm_row[2479:2472];
      btm[1] = btm_row[2487:2480];
      btm[2] = btm_row[2495:2488];
    end
    'd311: begin
      top[0] = top_row[2487:2480];
      top[1] = top_row[2495:2488];
      top[2] = top_row[2503:2496];
      mid[0] = mid_row[2487:2480];
      mid[1] = mid_row[2495:2488];
      mid[2] = mid_row[2503:2496];
      btm[0] = btm_row[2487:2480];
      btm[1] = btm_row[2495:2488];
      btm[2] = btm_row[2503:2496];
    end
    'd312: begin
      top[0] = top_row[2495:2488];
      top[1] = top_row[2503:2496];
      top[2] = top_row[2511:2504];
      mid[0] = mid_row[2495:2488];
      mid[1] = mid_row[2503:2496];
      mid[2] = mid_row[2511:2504];
      btm[0] = btm_row[2495:2488];
      btm[1] = btm_row[2503:2496];
      btm[2] = btm_row[2511:2504];
    end
    'd313: begin
      top[0] = top_row[2503:2496];
      top[1] = top_row[2511:2504];
      top[2] = top_row[2519:2512];
      mid[0] = mid_row[2503:2496];
      mid[1] = mid_row[2511:2504];
      mid[2] = mid_row[2519:2512];
      btm[0] = btm_row[2503:2496];
      btm[1] = btm_row[2511:2504];
      btm[2] = btm_row[2519:2512];
    end
    'd314: begin
      top[0] = top_row[2511:2504];
      top[1] = top_row[2519:2512];
      top[2] = top_row[2527:2520];
      mid[0] = mid_row[2511:2504];
      mid[1] = mid_row[2519:2512];
      mid[2] = mid_row[2527:2520];
      btm[0] = btm_row[2511:2504];
      btm[1] = btm_row[2519:2512];
      btm[2] = btm_row[2527:2520];
    end
    'd315: begin
      top[0] = top_row[2519:2512];
      top[1] = top_row[2527:2520];
      top[2] = top_row[2535:2528];
      mid[0] = mid_row[2519:2512];
      mid[1] = mid_row[2527:2520];
      mid[2] = mid_row[2535:2528];
      btm[0] = btm_row[2519:2512];
      btm[1] = btm_row[2527:2520];
      btm[2] = btm_row[2535:2528];
    end
    'd316: begin
      top[0] = top_row[2527:2520];
      top[1] = top_row[2535:2528];
      top[2] = top_row[2543:2536];
      mid[0] = mid_row[2527:2520];
      mid[1] = mid_row[2535:2528];
      mid[2] = mid_row[2543:2536];
      btm[0] = btm_row[2527:2520];
      btm[1] = btm_row[2535:2528];
      btm[2] = btm_row[2543:2536];
    end
    'd317: begin
      top[0] = top_row[2535:2528];
      top[1] = top_row[2543:2536];
      top[2] = top_row[2551:2544];
      mid[0] = mid_row[2535:2528];
      mid[1] = mid_row[2543:2536];
      mid[2] = mid_row[2551:2544];
      btm[0] = btm_row[2535:2528];
      btm[1] = btm_row[2543:2536];
      btm[2] = btm_row[2551:2544];
    end
    'd318: begin
      top[0] = top_row[2543:2536];
      top[1] = top_row[2551:2544];
      top[2] = top_row[2559:2552];
      mid[0] = mid_row[2543:2536];
      mid[1] = mid_row[2551:2544];
      mid[2] = mid_row[2559:2552];
      btm[0] = btm_row[2543:2536];
      btm[1] = btm_row[2551:2544];
      btm[2] = btm_row[2559:2552];
    end
    'd319: begin
      top[0] = top_row[2551:2544];
      top[1] = top_row[2559:2552];
      top[2] = top_row[2567:2560];
      mid[0] = mid_row[2551:2544];
      mid[1] = mid_row[2559:2552];
      mid[2] = mid_row[2567:2560];
      btm[0] = btm_row[2551:2544];
      btm[1] = btm_row[2559:2552];
      btm[2] = btm_row[2567:2560];
    end
    'd320: begin
      top[0] = top_row[2559:2552];
      top[1] = top_row[2567:2560];
      top[2] = top_row[2575:2568];
      mid[0] = mid_row[2559:2552];
      mid[1] = mid_row[2567:2560];
      mid[2] = mid_row[2575:2568];
      btm[0] = btm_row[2559:2552];
      btm[1] = btm_row[2567:2560];
      btm[2] = btm_row[2575:2568];
    end
    'd321: begin
      top[0] = top_row[2567:2560];
      top[1] = top_row[2575:2568];
      top[2] = top_row[2583:2576];
      mid[0] = mid_row[2567:2560];
      mid[1] = mid_row[2575:2568];
      mid[2] = mid_row[2583:2576];
      btm[0] = btm_row[2567:2560];
      btm[1] = btm_row[2575:2568];
      btm[2] = btm_row[2583:2576];
    end
    'd322: begin
      top[0] = top_row[2575:2568];
      top[1] = top_row[2583:2576];
      top[2] = top_row[2591:2584];
      mid[0] = mid_row[2575:2568];
      mid[1] = mid_row[2583:2576];
      mid[2] = mid_row[2591:2584];
      btm[0] = btm_row[2575:2568];
      btm[1] = btm_row[2583:2576];
      btm[2] = btm_row[2591:2584];
    end
    'd323: begin
      top[0] = top_row[2583:2576];
      top[1] = top_row[2591:2584];
      top[2] = top_row[2599:2592];
      mid[0] = mid_row[2583:2576];
      mid[1] = mid_row[2591:2584];
      mid[2] = mid_row[2599:2592];
      btm[0] = btm_row[2583:2576];
      btm[1] = btm_row[2591:2584];
      btm[2] = btm_row[2599:2592];
    end
    'd324: begin
      top[0] = top_row[2591:2584];
      top[1] = top_row[2599:2592];
      top[2] = top_row[2607:2600];
      mid[0] = mid_row[2591:2584];
      mid[1] = mid_row[2599:2592];
      mid[2] = mid_row[2607:2600];
      btm[0] = btm_row[2591:2584];
      btm[1] = btm_row[2599:2592];
      btm[2] = btm_row[2607:2600];
    end
    'd325: begin
      top[0] = top_row[2599:2592];
      top[1] = top_row[2607:2600];
      top[2] = top_row[2615:2608];
      mid[0] = mid_row[2599:2592];
      mid[1] = mid_row[2607:2600];
      mid[2] = mid_row[2615:2608];
      btm[0] = btm_row[2599:2592];
      btm[1] = btm_row[2607:2600];
      btm[2] = btm_row[2615:2608];
    end
    'd326: begin
      top[0] = top_row[2607:2600];
      top[1] = top_row[2615:2608];
      top[2] = top_row[2623:2616];
      mid[0] = mid_row[2607:2600];
      mid[1] = mid_row[2615:2608];
      mid[2] = mid_row[2623:2616];
      btm[0] = btm_row[2607:2600];
      btm[1] = btm_row[2615:2608];
      btm[2] = btm_row[2623:2616];
    end
    'd327: begin
      top[0] = top_row[2615:2608];
      top[1] = top_row[2623:2616];
      top[2] = top_row[2631:2624];
      mid[0] = mid_row[2615:2608];
      mid[1] = mid_row[2623:2616];
      mid[2] = mid_row[2631:2624];
      btm[0] = btm_row[2615:2608];
      btm[1] = btm_row[2623:2616];
      btm[2] = btm_row[2631:2624];
    end
    'd328: begin
      top[0] = top_row[2623:2616];
      top[1] = top_row[2631:2624];
      top[2] = top_row[2639:2632];
      mid[0] = mid_row[2623:2616];
      mid[1] = mid_row[2631:2624];
      mid[2] = mid_row[2639:2632];
      btm[0] = btm_row[2623:2616];
      btm[1] = btm_row[2631:2624];
      btm[2] = btm_row[2639:2632];
    end
    'd329: begin
      top[0] = top_row[2631:2624];
      top[1] = top_row[2639:2632];
      top[2] = top_row[2647:2640];
      mid[0] = mid_row[2631:2624];
      mid[1] = mid_row[2639:2632];
      mid[2] = mid_row[2647:2640];
      btm[0] = btm_row[2631:2624];
      btm[1] = btm_row[2639:2632];
      btm[2] = btm_row[2647:2640];
    end
    'd330: begin
      top[0] = top_row[2639:2632];
      top[1] = top_row[2647:2640];
      top[2] = top_row[2655:2648];
      mid[0] = mid_row[2639:2632];
      mid[1] = mid_row[2647:2640];
      mid[2] = mid_row[2655:2648];
      btm[0] = btm_row[2639:2632];
      btm[1] = btm_row[2647:2640];
      btm[2] = btm_row[2655:2648];
    end
    'd331: begin
      top[0] = top_row[2647:2640];
      top[1] = top_row[2655:2648];
      top[2] = top_row[2663:2656];
      mid[0] = mid_row[2647:2640];
      mid[1] = mid_row[2655:2648];
      mid[2] = mid_row[2663:2656];
      btm[0] = btm_row[2647:2640];
      btm[1] = btm_row[2655:2648];
      btm[2] = btm_row[2663:2656];
    end
    'd332: begin
      top[0] = top_row[2655:2648];
      top[1] = top_row[2663:2656];
      top[2] = top_row[2671:2664];
      mid[0] = mid_row[2655:2648];
      mid[1] = mid_row[2663:2656];
      mid[2] = mid_row[2671:2664];
      btm[0] = btm_row[2655:2648];
      btm[1] = btm_row[2663:2656];
      btm[2] = btm_row[2671:2664];
    end
    'd333: begin
      top[0] = top_row[2663:2656];
      top[1] = top_row[2671:2664];
      top[2] = top_row[2679:2672];
      mid[0] = mid_row[2663:2656];
      mid[1] = mid_row[2671:2664];
      mid[2] = mid_row[2679:2672];
      btm[0] = btm_row[2663:2656];
      btm[1] = btm_row[2671:2664];
      btm[2] = btm_row[2679:2672];
    end
    'd334: begin
      top[0] = top_row[2671:2664];
      top[1] = top_row[2679:2672];
      top[2] = top_row[2687:2680];
      mid[0] = mid_row[2671:2664];
      mid[1] = mid_row[2679:2672];
      mid[2] = mid_row[2687:2680];
      btm[0] = btm_row[2671:2664];
      btm[1] = btm_row[2679:2672];
      btm[2] = btm_row[2687:2680];
    end
    'd335: begin
      top[0] = top_row[2679:2672];
      top[1] = top_row[2687:2680];
      top[2] = top_row[2695:2688];
      mid[0] = mid_row[2679:2672];
      mid[1] = mid_row[2687:2680];
      mid[2] = mid_row[2695:2688];
      btm[0] = btm_row[2679:2672];
      btm[1] = btm_row[2687:2680];
      btm[2] = btm_row[2695:2688];
    end
    'd336: begin
      top[0] = top_row[2687:2680];
      top[1] = top_row[2695:2688];
      top[2] = top_row[2703:2696];
      mid[0] = mid_row[2687:2680];
      mid[1] = mid_row[2695:2688];
      mid[2] = mid_row[2703:2696];
      btm[0] = btm_row[2687:2680];
      btm[1] = btm_row[2695:2688];
      btm[2] = btm_row[2703:2696];
    end
    'd337: begin
      top[0] = top_row[2695:2688];
      top[1] = top_row[2703:2696];
      top[2] = top_row[2711:2704];
      mid[0] = mid_row[2695:2688];
      mid[1] = mid_row[2703:2696];
      mid[2] = mid_row[2711:2704];
      btm[0] = btm_row[2695:2688];
      btm[1] = btm_row[2703:2696];
      btm[2] = btm_row[2711:2704];
    end
    'd338: begin
      top[0] = top_row[2703:2696];
      top[1] = top_row[2711:2704];
      top[2] = top_row[2719:2712];
      mid[0] = mid_row[2703:2696];
      mid[1] = mid_row[2711:2704];
      mid[2] = mid_row[2719:2712];
      btm[0] = btm_row[2703:2696];
      btm[1] = btm_row[2711:2704];
      btm[2] = btm_row[2719:2712];
    end
    'd339: begin
      top[0] = top_row[2711:2704];
      top[1] = top_row[2719:2712];
      top[2] = top_row[2727:2720];
      mid[0] = mid_row[2711:2704];
      mid[1] = mid_row[2719:2712];
      mid[2] = mid_row[2727:2720];
      btm[0] = btm_row[2711:2704];
      btm[1] = btm_row[2719:2712];
      btm[2] = btm_row[2727:2720];
    end
    'd340: begin
      top[0] = top_row[2719:2712];
      top[1] = top_row[2727:2720];
      top[2] = top_row[2735:2728];
      mid[0] = mid_row[2719:2712];
      mid[1] = mid_row[2727:2720];
      mid[2] = mid_row[2735:2728];
      btm[0] = btm_row[2719:2712];
      btm[1] = btm_row[2727:2720];
      btm[2] = btm_row[2735:2728];
    end
    'd341: begin
      top[0] = top_row[2727:2720];
      top[1] = top_row[2735:2728];
      top[2] = top_row[2743:2736];
      mid[0] = mid_row[2727:2720];
      mid[1] = mid_row[2735:2728];
      mid[2] = mid_row[2743:2736];
      btm[0] = btm_row[2727:2720];
      btm[1] = btm_row[2735:2728];
      btm[2] = btm_row[2743:2736];
    end
    'd342: begin
      top[0] = top_row[2735:2728];
      top[1] = top_row[2743:2736];
      top[2] = top_row[2751:2744];
      mid[0] = mid_row[2735:2728];
      mid[1] = mid_row[2743:2736];
      mid[2] = mid_row[2751:2744];
      btm[0] = btm_row[2735:2728];
      btm[1] = btm_row[2743:2736];
      btm[2] = btm_row[2751:2744];
    end
    'd343: begin
      top[0] = top_row[2743:2736];
      top[1] = top_row[2751:2744];
      top[2] = top_row[2759:2752];
      mid[0] = mid_row[2743:2736];
      mid[1] = mid_row[2751:2744];
      mid[2] = mid_row[2759:2752];
      btm[0] = btm_row[2743:2736];
      btm[1] = btm_row[2751:2744];
      btm[2] = btm_row[2759:2752];
    end
    'd344: begin
      top[0] = top_row[2751:2744];
      top[1] = top_row[2759:2752];
      top[2] = top_row[2767:2760];
      mid[0] = mid_row[2751:2744];
      mid[1] = mid_row[2759:2752];
      mid[2] = mid_row[2767:2760];
      btm[0] = btm_row[2751:2744];
      btm[1] = btm_row[2759:2752];
      btm[2] = btm_row[2767:2760];
    end
    'd345: begin
      top[0] = top_row[2759:2752];
      top[1] = top_row[2767:2760];
      top[2] = top_row[2775:2768];
      mid[0] = mid_row[2759:2752];
      mid[1] = mid_row[2767:2760];
      mid[2] = mid_row[2775:2768];
      btm[0] = btm_row[2759:2752];
      btm[1] = btm_row[2767:2760];
      btm[2] = btm_row[2775:2768];
    end
    'd346: begin
      top[0] = top_row[2767:2760];
      top[1] = top_row[2775:2768];
      top[2] = top_row[2783:2776];
      mid[0] = mid_row[2767:2760];
      mid[1] = mid_row[2775:2768];
      mid[2] = mid_row[2783:2776];
      btm[0] = btm_row[2767:2760];
      btm[1] = btm_row[2775:2768];
      btm[2] = btm_row[2783:2776];
    end
    'd347: begin
      top[0] = top_row[2775:2768];
      top[1] = top_row[2783:2776];
      top[2] = top_row[2791:2784];
      mid[0] = mid_row[2775:2768];
      mid[1] = mid_row[2783:2776];
      mid[2] = mid_row[2791:2784];
      btm[0] = btm_row[2775:2768];
      btm[1] = btm_row[2783:2776];
      btm[2] = btm_row[2791:2784];
    end
    'd348: begin
      top[0] = top_row[2783:2776];
      top[1] = top_row[2791:2784];
      top[2] = top_row[2799:2792];
      mid[0] = mid_row[2783:2776];
      mid[1] = mid_row[2791:2784];
      mid[2] = mid_row[2799:2792];
      btm[0] = btm_row[2783:2776];
      btm[1] = btm_row[2791:2784];
      btm[2] = btm_row[2799:2792];
    end
    'd349: begin
      top[0] = top_row[2791:2784];
      top[1] = top_row[2799:2792];
      top[2] = top_row[2807:2800];
      mid[0] = mid_row[2791:2784];
      mid[1] = mid_row[2799:2792];
      mid[2] = mid_row[2807:2800];
      btm[0] = btm_row[2791:2784];
      btm[1] = btm_row[2799:2792];
      btm[2] = btm_row[2807:2800];
    end
    'd350: begin
      top[0] = top_row[2799:2792];
      top[1] = top_row[2807:2800];
      top[2] = top_row[2815:2808];
      mid[0] = mid_row[2799:2792];
      mid[1] = mid_row[2807:2800];
      mid[2] = mid_row[2815:2808];
      btm[0] = btm_row[2799:2792];
      btm[1] = btm_row[2807:2800];
      btm[2] = btm_row[2815:2808];
    end
    'd351: begin
      top[0] = top_row[2807:2800];
      top[1] = top_row[2815:2808];
      top[2] = top_row[2823:2816];
      mid[0] = mid_row[2807:2800];
      mid[1] = mid_row[2815:2808];
      mid[2] = mid_row[2823:2816];
      btm[0] = btm_row[2807:2800];
      btm[1] = btm_row[2815:2808];
      btm[2] = btm_row[2823:2816];
    end
    'd352: begin
      top[0] = top_row[2815:2808];
      top[1] = top_row[2823:2816];
      top[2] = top_row[2831:2824];
      mid[0] = mid_row[2815:2808];
      mid[1] = mid_row[2823:2816];
      mid[2] = mid_row[2831:2824];
      btm[0] = btm_row[2815:2808];
      btm[1] = btm_row[2823:2816];
      btm[2] = btm_row[2831:2824];
    end
    'd353: begin
      top[0] = top_row[2823:2816];
      top[1] = top_row[2831:2824];
      top[2] = top_row[2839:2832];
      mid[0] = mid_row[2823:2816];
      mid[1] = mid_row[2831:2824];
      mid[2] = mid_row[2839:2832];
      btm[0] = btm_row[2823:2816];
      btm[1] = btm_row[2831:2824];
      btm[2] = btm_row[2839:2832];
    end
    'd354: begin
      top[0] = top_row[2831:2824];
      top[1] = top_row[2839:2832];
      top[2] = top_row[2847:2840];
      mid[0] = mid_row[2831:2824];
      mid[1] = mid_row[2839:2832];
      mid[2] = mid_row[2847:2840];
      btm[0] = btm_row[2831:2824];
      btm[1] = btm_row[2839:2832];
      btm[2] = btm_row[2847:2840];
    end
    'd355: begin
      top[0] = top_row[2839:2832];
      top[1] = top_row[2847:2840];
      top[2] = top_row[2855:2848];
      mid[0] = mid_row[2839:2832];
      mid[1] = mid_row[2847:2840];
      mid[2] = mid_row[2855:2848];
      btm[0] = btm_row[2839:2832];
      btm[1] = btm_row[2847:2840];
      btm[2] = btm_row[2855:2848];
    end
    'd356: begin
      top[0] = top_row[2847:2840];
      top[1] = top_row[2855:2848];
      top[2] = top_row[2863:2856];
      mid[0] = mid_row[2847:2840];
      mid[1] = mid_row[2855:2848];
      mid[2] = mid_row[2863:2856];
      btm[0] = btm_row[2847:2840];
      btm[1] = btm_row[2855:2848];
      btm[2] = btm_row[2863:2856];
    end
    'd357: begin
      top[0] = top_row[2855:2848];
      top[1] = top_row[2863:2856];
      top[2] = top_row[2871:2864];
      mid[0] = mid_row[2855:2848];
      mid[1] = mid_row[2863:2856];
      mid[2] = mid_row[2871:2864];
      btm[0] = btm_row[2855:2848];
      btm[1] = btm_row[2863:2856];
      btm[2] = btm_row[2871:2864];
    end
    'd358: begin
      top[0] = top_row[2863:2856];
      top[1] = top_row[2871:2864];
      top[2] = top_row[2879:2872];
      mid[0] = mid_row[2863:2856];
      mid[1] = mid_row[2871:2864];
      mid[2] = mid_row[2879:2872];
      btm[0] = btm_row[2863:2856];
      btm[1] = btm_row[2871:2864];
      btm[2] = btm_row[2879:2872];
    end
    'd359: begin
      top[0] = top_row[2871:2864];
      top[1] = top_row[2879:2872];
      top[2] = top_row[2887:2880];
      mid[0] = mid_row[2871:2864];
      mid[1] = mid_row[2879:2872];
      mid[2] = mid_row[2887:2880];
      btm[0] = btm_row[2871:2864];
      btm[1] = btm_row[2879:2872];
      btm[2] = btm_row[2887:2880];
    end
    'd360: begin
      top[0] = top_row[2879:2872];
      top[1] = top_row[2887:2880];
      top[2] = top_row[2895:2888];
      mid[0] = mid_row[2879:2872];
      mid[1] = mid_row[2887:2880];
      mid[2] = mid_row[2895:2888];
      btm[0] = btm_row[2879:2872];
      btm[1] = btm_row[2887:2880];
      btm[2] = btm_row[2895:2888];
    end
    'd361: begin
      top[0] = top_row[2887:2880];
      top[1] = top_row[2895:2888];
      top[2] = top_row[2903:2896];
      mid[0] = mid_row[2887:2880];
      mid[1] = mid_row[2895:2888];
      mid[2] = mid_row[2903:2896];
      btm[0] = btm_row[2887:2880];
      btm[1] = btm_row[2895:2888];
      btm[2] = btm_row[2903:2896];
    end
    'd362: begin
      top[0] = top_row[2895:2888];
      top[1] = top_row[2903:2896];
      top[2] = top_row[2911:2904];
      mid[0] = mid_row[2895:2888];
      mid[1] = mid_row[2903:2896];
      mid[2] = mid_row[2911:2904];
      btm[0] = btm_row[2895:2888];
      btm[1] = btm_row[2903:2896];
      btm[2] = btm_row[2911:2904];
    end
    'd363: begin
      top[0] = top_row[2903:2896];
      top[1] = top_row[2911:2904];
      top[2] = top_row[2919:2912];
      mid[0] = mid_row[2903:2896];
      mid[1] = mid_row[2911:2904];
      mid[2] = mid_row[2919:2912];
      btm[0] = btm_row[2903:2896];
      btm[1] = btm_row[2911:2904];
      btm[2] = btm_row[2919:2912];
    end
    'd364: begin
      top[0] = top_row[2911:2904];
      top[1] = top_row[2919:2912];
      top[2] = top_row[2927:2920];
      mid[0] = mid_row[2911:2904];
      mid[1] = mid_row[2919:2912];
      mid[2] = mid_row[2927:2920];
      btm[0] = btm_row[2911:2904];
      btm[1] = btm_row[2919:2912];
      btm[2] = btm_row[2927:2920];
    end
    'd365: begin
      top[0] = top_row[2919:2912];
      top[1] = top_row[2927:2920];
      top[2] = top_row[2935:2928];
      mid[0] = mid_row[2919:2912];
      mid[1] = mid_row[2927:2920];
      mid[2] = mid_row[2935:2928];
      btm[0] = btm_row[2919:2912];
      btm[1] = btm_row[2927:2920];
      btm[2] = btm_row[2935:2928];
    end
    'd366: begin
      top[0] = top_row[2927:2920];
      top[1] = top_row[2935:2928];
      top[2] = top_row[2943:2936];
      mid[0] = mid_row[2927:2920];
      mid[1] = mid_row[2935:2928];
      mid[2] = mid_row[2943:2936];
      btm[0] = btm_row[2927:2920];
      btm[1] = btm_row[2935:2928];
      btm[2] = btm_row[2943:2936];
    end
    'd367: begin
      top[0] = top_row[2935:2928];
      top[1] = top_row[2943:2936];
      top[2] = top_row[2951:2944];
      mid[0] = mid_row[2935:2928];
      mid[1] = mid_row[2943:2936];
      mid[2] = mid_row[2951:2944];
      btm[0] = btm_row[2935:2928];
      btm[1] = btm_row[2943:2936];
      btm[2] = btm_row[2951:2944];
    end
    'd368: begin
      top[0] = top_row[2943:2936];
      top[1] = top_row[2951:2944];
      top[2] = top_row[2959:2952];
      mid[0] = mid_row[2943:2936];
      mid[1] = mid_row[2951:2944];
      mid[2] = mid_row[2959:2952];
      btm[0] = btm_row[2943:2936];
      btm[1] = btm_row[2951:2944];
      btm[2] = btm_row[2959:2952];
    end
    'd369: begin
      top[0] = top_row[2951:2944];
      top[1] = top_row[2959:2952];
      top[2] = top_row[2967:2960];
      mid[0] = mid_row[2951:2944];
      mid[1] = mid_row[2959:2952];
      mid[2] = mid_row[2967:2960];
      btm[0] = btm_row[2951:2944];
      btm[1] = btm_row[2959:2952];
      btm[2] = btm_row[2967:2960];
    end
    'd370: begin
      top[0] = top_row[2959:2952];
      top[1] = top_row[2967:2960];
      top[2] = top_row[2975:2968];
      mid[0] = mid_row[2959:2952];
      mid[1] = mid_row[2967:2960];
      mid[2] = mid_row[2975:2968];
      btm[0] = btm_row[2959:2952];
      btm[1] = btm_row[2967:2960];
      btm[2] = btm_row[2975:2968];
    end
    'd371: begin
      top[0] = top_row[2967:2960];
      top[1] = top_row[2975:2968];
      top[2] = top_row[2983:2976];
      mid[0] = mid_row[2967:2960];
      mid[1] = mid_row[2975:2968];
      mid[2] = mid_row[2983:2976];
      btm[0] = btm_row[2967:2960];
      btm[1] = btm_row[2975:2968];
      btm[2] = btm_row[2983:2976];
    end
    'd372: begin
      top[0] = top_row[2975:2968];
      top[1] = top_row[2983:2976];
      top[2] = top_row[2991:2984];
      mid[0] = mid_row[2975:2968];
      mid[1] = mid_row[2983:2976];
      mid[2] = mid_row[2991:2984];
      btm[0] = btm_row[2975:2968];
      btm[1] = btm_row[2983:2976];
      btm[2] = btm_row[2991:2984];
    end
    'd373: begin
      top[0] = top_row[2983:2976];
      top[1] = top_row[2991:2984];
      top[2] = top_row[2999:2992];
      mid[0] = mid_row[2983:2976];
      mid[1] = mid_row[2991:2984];
      mid[2] = mid_row[2999:2992];
      btm[0] = btm_row[2983:2976];
      btm[1] = btm_row[2991:2984];
      btm[2] = btm_row[2999:2992];
    end
    'd374: begin
      top[0] = top_row[2991:2984];
      top[1] = top_row[2999:2992];
      top[2] = top_row[3007:3000];
      mid[0] = mid_row[2991:2984];
      mid[1] = mid_row[2999:2992];
      mid[2] = mid_row[3007:3000];
      btm[0] = btm_row[2991:2984];
      btm[1] = btm_row[2999:2992];
      btm[2] = btm_row[3007:3000];
    end
    'd375: begin
      top[0] = top_row[2999:2992];
      top[1] = top_row[3007:3000];
      top[2] = top_row[3015:3008];
      mid[0] = mid_row[2999:2992];
      mid[1] = mid_row[3007:3000];
      mid[2] = mid_row[3015:3008];
      btm[0] = btm_row[2999:2992];
      btm[1] = btm_row[3007:3000];
      btm[2] = btm_row[3015:3008];
    end
    'd376: begin
      top[0] = top_row[3007:3000];
      top[1] = top_row[3015:3008];
      top[2] = top_row[3023:3016];
      mid[0] = mid_row[3007:3000];
      mid[1] = mid_row[3015:3008];
      mid[2] = mid_row[3023:3016];
      btm[0] = btm_row[3007:3000];
      btm[1] = btm_row[3015:3008];
      btm[2] = btm_row[3023:3016];
    end
    'd377: begin
      top[0] = top_row[3015:3008];
      top[1] = top_row[3023:3016];
      top[2] = top_row[3031:3024];
      mid[0] = mid_row[3015:3008];
      mid[1] = mid_row[3023:3016];
      mid[2] = mid_row[3031:3024];
      btm[0] = btm_row[3015:3008];
      btm[1] = btm_row[3023:3016];
      btm[2] = btm_row[3031:3024];
    end
    'd378: begin
      top[0] = top_row[3023:3016];
      top[1] = top_row[3031:3024];
      top[2] = top_row[3039:3032];
      mid[0] = mid_row[3023:3016];
      mid[1] = mid_row[3031:3024];
      mid[2] = mid_row[3039:3032];
      btm[0] = btm_row[3023:3016];
      btm[1] = btm_row[3031:3024];
      btm[2] = btm_row[3039:3032];
    end
    'd379: begin
      top[0] = top_row[3031:3024];
      top[1] = top_row[3039:3032];
      top[2] = top_row[3047:3040];
      mid[0] = mid_row[3031:3024];
      mid[1] = mid_row[3039:3032];
      mid[2] = mid_row[3047:3040];
      btm[0] = btm_row[3031:3024];
      btm[1] = btm_row[3039:3032];
      btm[2] = btm_row[3047:3040];
    end
    'd380: begin
      top[0] = top_row[3039:3032];
      top[1] = top_row[3047:3040];
      top[2] = top_row[3055:3048];
      mid[0] = mid_row[3039:3032];
      mid[1] = mid_row[3047:3040];
      mid[2] = mid_row[3055:3048];
      btm[0] = btm_row[3039:3032];
      btm[1] = btm_row[3047:3040];
      btm[2] = btm_row[3055:3048];
    end
    'd381: begin
      top[0] = top_row[3047:3040];
      top[1] = top_row[3055:3048];
      top[2] = top_row[3063:3056];
      mid[0] = mid_row[3047:3040];
      mid[1] = mid_row[3055:3048];
      mid[2] = mid_row[3063:3056];
      btm[0] = btm_row[3047:3040];
      btm[1] = btm_row[3055:3048];
      btm[2] = btm_row[3063:3056];
    end
    'd382: begin
      top[0] = top_row[3055:3048];
      top[1] = top_row[3063:3056];
      top[2] = top_row[3071:3064];
      mid[0] = mid_row[3055:3048];
      mid[1] = mid_row[3063:3056];
      mid[2] = mid_row[3071:3064];
      btm[0] = btm_row[3055:3048];
      btm[1] = btm_row[3063:3056];
      btm[2] = btm_row[3071:3064];
    end
    'd383: begin
      top[0] = top_row[3063:3056];
      top[1] = top_row[3071:3064];
      top[2] = top_row[3079:3072];
      mid[0] = mid_row[3063:3056];
      mid[1] = mid_row[3071:3064];
      mid[2] = mid_row[3079:3072];
      btm[0] = btm_row[3063:3056];
      btm[1] = btm_row[3071:3064];
      btm[2] = btm_row[3079:3072];
    end
    'd384: begin
      top[0] = top_row[3071:3064];
      top[1] = top_row[3079:3072];
      top[2] = top_row[3087:3080];
      mid[0] = mid_row[3071:3064];
      mid[1] = mid_row[3079:3072];
      mid[2] = mid_row[3087:3080];
      btm[0] = btm_row[3071:3064];
      btm[1] = btm_row[3079:3072];
      btm[2] = btm_row[3087:3080];
    end
    'd385: begin
      top[0] = top_row[3079:3072];
      top[1] = top_row[3087:3080];
      top[2] = top_row[3095:3088];
      mid[0] = mid_row[3079:3072];
      mid[1] = mid_row[3087:3080];
      mid[2] = mid_row[3095:3088];
      btm[0] = btm_row[3079:3072];
      btm[1] = btm_row[3087:3080];
      btm[2] = btm_row[3095:3088];
    end
    'd386: begin
      top[0] = top_row[3087:3080];
      top[1] = top_row[3095:3088];
      top[2] = top_row[3103:3096];
      mid[0] = mid_row[3087:3080];
      mid[1] = mid_row[3095:3088];
      mid[2] = mid_row[3103:3096];
      btm[0] = btm_row[3087:3080];
      btm[1] = btm_row[3095:3088];
      btm[2] = btm_row[3103:3096];
    end
    'd387: begin
      top[0] = top_row[3095:3088];
      top[1] = top_row[3103:3096];
      top[2] = top_row[3111:3104];
      mid[0] = mid_row[3095:3088];
      mid[1] = mid_row[3103:3096];
      mid[2] = mid_row[3111:3104];
      btm[0] = btm_row[3095:3088];
      btm[1] = btm_row[3103:3096];
      btm[2] = btm_row[3111:3104];
    end
    'd388: begin
      top[0] = top_row[3103:3096];
      top[1] = top_row[3111:3104];
      top[2] = top_row[3119:3112];
      mid[0] = mid_row[3103:3096];
      mid[1] = mid_row[3111:3104];
      mid[2] = mid_row[3119:3112];
      btm[0] = btm_row[3103:3096];
      btm[1] = btm_row[3111:3104];
      btm[2] = btm_row[3119:3112];
    end
    'd389: begin
      top[0] = top_row[3111:3104];
      top[1] = top_row[3119:3112];
      top[2] = top_row[3127:3120];
      mid[0] = mid_row[3111:3104];
      mid[1] = mid_row[3119:3112];
      mid[2] = mid_row[3127:3120];
      btm[0] = btm_row[3111:3104];
      btm[1] = btm_row[3119:3112];
      btm[2] = btm_row[3127:3120];
    end
    'd390: begin
      top[0] = top_row[3119:3112];
      top[1] = top_row[3127:3120];
      top[2] = top_row[3135:3128];
      mid[0] = mid_row[3119:3112];
      mid[1] = mid_row[3127:3120];
      mid[2] = mid_row[3135:3128];
      btm[0] = btm_row[3119:3112];
      btm[1] = btm_row[3127:3120];
      btm[2] = btm_row[3135:3128];
    end
    'd391: begin
      top[0] = top_row[3127:3120];
      top[1] = top_row[3135:3128];
      top[2] = top_row[3143:3136];
      mid[0] = mid_row[3127:3120];
      mid[1] = mid_row[3135:3128];
      mid[2] = mid_row[3143:3136];
      btm[0] = btm_row[3127:3120];
      btm[1] = btm_row[3135:3128];
      btm[2] = btm_row[3143:3136];
    end
    'd392: begin
      top[0] = top_row[3135:3128];
      top[1] = top_row[3143:3136];
      top[2] = top_row[3151:3144];
      mid[0] = mid_row[3135:3128];
      mid[1] = mid_row[3143:3136];
      mid[2] = mid_row[3151:3144];
      btm[0] = btm_row[3135:3128];
      btm[1] = btm_row[3143:3136];
      btm[2] = btm_row[3151:3144];
    end
    'd393: begin
      top[0] = top_row[3143:3136];
      top[1] = top_row[3151:3144];
      top[2] = top_row[3159:3152];
      mid[0] = mid_row[3143:3136];
      mid[1] = mid_row[3151:3144];
      mid[2] = mid_row[3159:3152];
      btm[0] = btm_row[3143:3136];
      btm[1] = btm_row[3151:3144];
      btm[2] = btm_row[3159:3152];
    end
    'd394: begin
      top[0] = top_row[3151:3144];
      top[1] = top_row[3159:3152];
      top[2] = top_row[3167:3160];
      mid[0] = mid_row[3151:3144];
      mid[1] = mid_row[3159:3152];
      mid[2] = mid_row[3167:3160];
      btm[0] = btm_row[3151:3144];
      btm[1] = btm_row[3159:3152];
      btm[2] = btm_row[3167:3160];
    end
    'd395: begin
      top[0] = top_row[3159:3152];
      top[1] = top_row[3167:3160];
      top[2] = top_row[3175:3168];
      mid[0] = mid_row[3159:3152];
      mid[1] = mid_row[3167:3160];
      mid[2] = mid_row[3175:3168];
      btm[0] = btm_row[3159:3152];
      btm[1] = btm_row[3167:3160];
      btm[2] = btm_row[3175:3168];
    end
    'd396: begin
      top[0] = top_row[3167:3160];
      top[1] = top_row[3175:3168];
      top[2] = top_row[3183:3176];
      mid[0] = mid_row[3167:3160];
      mid[1] = mid_row[3175:3168];
      mid[2] = mid_row[3183:3176];
      btm[0] = btm_row[3167:3160];
      btm[1] = btm_row[3175:3168];
      btm[2] = btm_row[3183:3176];
    end
    'd397: begin
      top[0] = top_row[3175:3168];
      top[1] = top_row[3183:3176];
      top[2] = top_row[3191:3184];
      mid[0] = mid_row[3175:3168];
      mid[1] = mid_row[3183:3176];
      mid[2] = mid_row[3191:3184];
      btm[0] = btm_row[3175:3168];
      btm[1] = btm_row[3183:3176];
      btm[2] = btm_row[3191:3184];
    end
    'd398: begin
      top[0] = top_row[3183:3176];
      top[1] = top_row[3191:3184];
      top[2] = top_row[3199:3192];
      mid[0] = mid_row[3183:3176];
      mid[1] = mid_row[3191:3184];
      mid[2] = mid_row[3199:3192];
      btm[0] = btm_row[3183:3176];
      btm[1] = btm_row[3191:3184];
      btm[2] = btm_row[3199:3192];
    end
    'd399: begin
      top[0] = top_row[3191:3184];
      top[1] = top_row[3199:3192];
      top[2] = top_row[3207:3200];
      mid[0] = mid_row[3191:3184];
      mid[1] = mid_row[3199:3192];
      mid[2] = mid_row[3207:3200];
      btm[0] = btm_row[3191:3184];
      btm[1] = btm_row[3199:3192];
      btm[2] = btm_row[3207:3200];
    end
    'd400: begin
      top[0] = top_row[3199:3192];
      top[1] = top_row[3207:3200];
      top[2] = top_row[3215:3208];
      mid[0] = mid_row[3199:3192];
      mid[1] = mid_row[3207:3200];
      mid[2] = mid_row[3215:3208];
      btm[0] = btm_row[3199:3192];
      btm[1] = btm_row[3207:3200];
      btm[2] = btm_row[3215:3208];
    end
    'd401: begin
      top[0] = top_row[3207:3200];
      top[1] = top_row[3215:3208];
      top[2] = top_row[3223:3216];
      mid[0] = mid_row[3207:3200];
      mid[1] = mid_row[3215:3208];
      mid[2] = mid_row[3223:3216];
      btm[0] = btm_row[3207:3200];
      btm[1] = btm_row[3215:3208];
      btm[2] = btm_row[3223:3216];
    end
    'd402: begin
      top[0] = top_row[3215:3208];
      top[1] = top_row[3223:3216];
      top[2] = top_row[3231:3224];
      mid[0] = mid_row[3215:3208];
      mid[1] = mid_row[3223:3216];
      mid[2] = mid_row[3231:3224];
      btm[0] = btm_row[3215:3208];
      btm[1] = btm_row[3223:3216];
      btm[2] = btm_row[3231:3224];
    end
    'd403: begin
      top[0] = top_row[3223:3216];
      top[1] = top_row[3231:3224];
      top[2] = top_row[3239:3232];
      mid[0] = mid_row[3223:3216];
      mid[1] = mid_row[3231:3224];
      mid[2] = mid_row[3239:3232];
      btm[0] = btm_row[3223:3216];
      btm[1] = btm_row[3231:3224];
      btm[2] = btm_row[3239:3232];
    end
    'd404: begin
      top[0] = top_row[3231:3224];
      top[1] = top_row[3239:3232];
      top[2] = top_row[3247:3240];
      mid[0] = mid_row[3231:3224];
      mid[1] = mid_row[3239:3232];
      mid[2] = mid_row[3247:3240];
      btm[0] = btm_row[3231:3224];
      btm[1] = btm_row[3239:3232];
      btm[2] = btm_row[3247:3240];
    end
    'd405: begin
      top[0] = top_row[3239:3232];
      top[1] = top_row[3247:3240];
      top[2] = top_row[3255:3248];
      mid[0] = mid_row[3239:3232];
      mid[1] = mid_row[3247:3240];
      mid[2] = mid_row[3255:3248];
      btm[0] = btm_row[3239:3232];
      btm[1] = btm_row[3247:3240];
      btm[2] = btm_row[3255:3248];
    end
    'd406: begin
      top[0] = top_row[3247:3240];
      top[1] = top_row[3255:3248];
      top[2] = top_row[3263:3256];
      mid[0] = mid_row[3247:3240];
      mid[1] = mid_row[3255:3248];
      mid[2] = mid_row[3263:3256];
      btm[0] = btm_row[3247:3240];
      btm[1] = btm_row[3255:3248];
      btm[2] = btm_row[3263:3256];
    end
    'd407: begin
      top[0] = top_row[3255:3248];
      top[1] = top_row[3263:3256];
      top[2] = top_row[3271:3264];
      mid[0] = mid_row[3255:3248];
      mid[1] = mid_row[3263:3256];
      mid[2] = mid_row[3271:3264];
      btm[0] = btm_row[3255:3248];
      btm[1] = btm_row[3263:3256];
      btm[2] = btm_row[3271:3264];
    end
    'd408: begin
      top[0] = top_row[3263:3256];
      top[1] = top_row[3271:3264];
      top[2] = top_row[3279:3272];
      mid[0] = mid_row[3263:3256];
      mid[1] = mid_row[3271:3264];
      mid[2] = mid_row[3279:3272];
      btm[0] = btm_row[3263:3256];
      btm[1] = btm_row[3271:3264];
      btm[2] = btm_row[3279:3272];
    end
    'd409: begin
      top[0] = top_row[3271:3264];
      top[1] = top_row[3279:3272];
      top[2] = top_row[3287:3280];
      mid[0] = mid_row[3271:3264];
      mid[1] = mid_row[3279:3272];
      mid[2] = mid_row[3287:3280];
      btm[0] = btm_row[3271:3264];
      btm[1] = btm_row[3279:3272];
      btm[2] = btm_row[3287:3280];
    end
    'd410: begin
      top[0] = top_row[3279:3272];
      top[1] = top_row[3287:3280];
      top[2] = top_row[3295:3288];
      mid[0] = mid_row[3279:3272];
      mid[1] = mid_row[3287:3280];
      mid[2] = mid_row[3295:3288];
      btm[0] = btm_row[3279:3272];
      btm[1] = btm_row[3287:3280];
      btm[2] = btm_row[3295:3288];
    end
    'd411: begin
      top[0] = top_row[3287:3280];
      top[1] = top_row[3295:3288];
      top[2] = top_row[3303:3296];
      mid[0] = mid_row[3287:3280];
      mid[1] = mid_row[3295:3288];
      mid[2] = mid_row[3303:3296];
      btm[0] = btm_row[3287:3280];
      btm[1] = btm_row[3295:3288];
      btm[2] = btm_row[3303:3296];
    end
    'd412: begin
      top[0] = top_row[3295:3288];
      top[1] = top_row[3303:3296];
      top[2] = top_row[3311:3304];
      mid[0] = mid_row[3295:3288];
      mid[1] = mid_row[3303:3296];
      mid[2] = mid_row[3311:3304];
      btm[0] = btm_row[3295:3288];
      btm[1] = btm_row[3303:3296];
      btm[2] = btm_row[3311:3304];
    end
    'd413: begin
      top[0] = top_row[3303:3296];
      top[1] = top_row[3311:3304];
      top[2] = top_row[3319:3312];
      mid[0] = mid_row[3303:3296];
      mid[1] = mid_row[3311:3304];
      mid[2] = mid_row[3319:3312];
      btm[0] = btm_row[3303:3296];
      btm[1] = btm_row[3311:3304];
      btm[2] = btm_row[3319:3312];
    end
    'd414: begin
      top[0] = top_row[3311:3304];
      top[1] = top_row[3319:3312];
      top[2] = top_row[3327:3320];
      mid[0] = mid_row[3311:3304];
      mid[1] = mid_row[3319:3312];
      mid[2] = mid_row[3327:3320];
      btm[0] = btm_row[3311:3304];
      btm[1] = btm_row[3319:3312];
      btm[2] = btm_row[3327:3320];
    end
    'd415: begin
      top[0] = top_row[3319:3312];
      top[1] = top_row[3327:3320];
      top[2] = top_row[3335:3328];
      mid[0] = mid_row[3319:3312];
      mid[1] = mid_row[3327:3320];
      mid[2] = mid_row[3335:3328];
      btm[0] = btm_row[3319:3312];
      btm[1] = btm_row[3327:3320];
      btm[2] = btm_row[3335:3328];
    end
    'd416: begin
      top[0] = top_row[3327:3320];
      top[1] = top_row[3335:3328];
      top[2] = top_row[3343:3336];
      mid[0] = mid_row[3327:3320];
      mid[1] = mid_row[3335:3328];
      mid[2] = mid_row[3343:3336];
      btm[0] = btm_row[3327:3320];
      btm[1] = btm_row[3335:3328];
      btm[2] = btm_row[3343:3336];
    end
    'd417: begin
      top[0] = top_row[3335:3328];
      top[1] = top_row[3343:3336];
      top[2] = top_row[3351:3344];
      mid[0] = mid_row[3335:3328];
      mid[1] = mid_row[3343:3336];
      mid[2] = mid_row[3351:3344];
      btm[0] = btm_row[3335:3328];
      btm[1] = btm_row[3343:3336];
      btm[2] = btm_row[3351:3344];
    end
    'd418: begin
      top[0] = top_row[3343:3336];
      top[1] = top_row[3351:3344];
      top[2] = top_row[3359:3352];
      mid[0] = mid_row[3343:3336];
      mid[1] = mid_row[3351:3344];
      mid[2] = mid_row[3359:3352];
      btm[0] = btm_row[3343:3336];
      btm[1] = btm_row[3351:3344];
      btm[2] = btm_row[3359:3352];
    end
    'd419: begin
      top[0] = top_row[3351:3344];
      top[1] = top_row[3359:3352];
      top[2] = top_row[3367:3360];
      mid[0] = mid_row[3351:3344];
      mid[1] = mid_row[3359:3352];
      mid[2] = mid_row[3367:3360];
      btm[0] = btm_row[3351:3344];
      btm[1] = btm_row[3359:3352];
      btm[2] = btm_row[3367:3360];
    end
    'd420: begin
      top[0] = top_row[3359:3352];
      top[1] = top_row[3367:3360];
      top[2] = top_row[3375:3368];
      mid[0] = mid_row[3359:3352];
      mid[1] = mid_row[3367:3360];
      mid[2] = mid_row[3375:3368];
      btm[0] = btm_row[3359:3352];
      btm[1] = btm_row[3367:3360];
      btm[2] = btm_row[3375:3368];
    end
    'd421: begin
      top[0] = top_row[3367:3360];
      top[1] = top_row[3375:3368];
      top[2] = top_row[3383:3376];
      mid[0] = mid_row[3367:3360];
      mid[1] = mid_row[3375:3368];
      mid[2] = mid_row[3383:3376];
      btm[0] = btm_row[3367:3360];
      btm[1] = btm_row[3375:3368];
      btm[2] = btm_row[3383:3376];
    end
    'd422: begin
      top[0] = top_row[3375:3368];
      top[1] = top_row[3383:3376];
      top[2] = top_row[3391:3384];
      mid[0] = mid_row[3375:3368];
      mid[1] = mid_row[3383:3376];
      mid[2] = mid_row[3391:3384];
      btm[0] = btm_row[3375:3368];
      btm[1] = btm_row[3383:3376];
      btm[2] = btm_row[3391:3384];
    end
    'd423: begin
      top[0] = top_row[3383:3376];
      top[1] = top_row[3391:3384];
      top[2] = top_row[3399:3392];
      mid[0] = mid_row[3383:3376];
      mid[1] = mid_row[3391:3384];
      mid[2] = mid_row[3399:3392];
      btm[0] = btm_row[3383:3376];
      btm[1] = btm_row[3391:3384];
      btm[2] = btm_row[3399:3392];
    end
    'd424: begin
      top[0] = top_row[3391:3384];
      top[1] = top_row[3399:3392];
      top[2] = top_row[3407:3400];
      mid[0] = mid_row[3391:3384];
      mid[1] = mid_row[3399:3392];
      mid[2] = mid_row[3407:3400];
      btm[0] = btm_row[3391:3384];
      btm[1] = btm_row[3399:3392];
      btm[2] = btm_row[3407:3400];
    end
    'd425: begin
      top[0] = top_row[3399:3392];
      top[1] = top_row[3407:3400];
      top[2] = top_row[3415:3408];
      mid[0] = mid_row[3399:3392];
      mid[1] = mid_row[3407:3400];
      mid[2] = mid_row[3415:3408];
      btm[0] = btm_row[3399:3392];
      btm[1] = btm_row[3407:3400];
      btm[2] = btm_row[3415:3408];
    end
    'd426: begin
      top[0] = top_row[3407:3400];
      top[1] = top_row[3415:3408];
      top[2] = top_row[3423:3416];
      mid[0] = mid_row[3407:3400];
      mid[1] = mid_row[3415:3408];
      mid[2] = mid_row[3423:3416];
      btm[0] = btm_row[3407:3400];
      btm[1] = btm_row[3415:3408];
      btm[2] = btm_row[3423:3416];
    end
    'd427: begin
      top[0] = top_row[3415:3408];
      top[1] = top_row[3423:3416];
      top[2] = top_row[3431:3424];
      mid[0] = mid_row[3415:3408];
      mid[1] = mid_row[3423:3416];
      mid[2] = mid_row[3431:3424];
      btm[0] = btm_row[3415:3408];
      btm[1] = btm_row[3423:3416];
      btm[2] = btm_row[3431:3424];
    end
    'd428: begin
      top[0] = top_row[3423:3416];
      top[1] = top_row[3431:3424];
      top[2] = top_row[3439:3432];
      mid[0] = mid_row[3423:3416];
      mid[1] = mid_row[3431:3424];
      mid[2] = mid_row[3439:3432];
      btm[0] = btm_row[3423:3416];
      btm[1] = btm_row[3431:3424];
      btm[2] = btm_row[3439:3432];
    end
    'd429: begin
      top[0] = top_row[3431:3424];
      top[1] = top_row[3439:3432];
      top[2] = top_row[3447:3440];
      mid[0] = mid_row[3431:3424];
      mid[1] = mid_row[3439:3432];
      mid[2] = mid_row[3447:3440];
      btm[0] = btm_row[3431:3424];
      btm[1] = btm_row[3439:3432];
      btm[2] = btm_row[3447:3440];
    end
    'd430: begin
      top[0] = top_row[3439:3432];
      top[1] = top_row[3447:3440];
      top[2] = top_row[3455:3448];
      mid[0] = mid_row[3439:3432];
      mid[1] = mid_row[3447:3440];
      mid[2] = mid_row[3455:3448];
      btm[0] = btm_row[3439:3432];
      btm[1] = btm_row[3447:3440];
      btm[2] = btm_row[3455:3448];
    end
    'd431: begin
      top[0] = top_row[3447:3440];
      top[1] = top_row[3455:3448];
      top[2] = top_row[3463:3456];
      mid[0] = mid_row[3447:3440];
      mid[1] = mid_row[3455:3448];
      mid[2] = mid_row[3463:3456];
      btm[0] = btm_row[3447:3440];
      btm[1] = btm_row[3455:3448];
      btm[2] = btm_row[3463:3456];
    end
    'd432: begin
      top[0] = top_row[3455:3448];
      top[1] = top_row[3463:3456];
      top[2] = top_row[3471:3464];
      mid[0] = mid_row[3455:3448];
      mid[1] = mid_row[3463:3456];
      mid[2] = mid_row[3471:3464];
      btm[0] = btm_row[3455:3448];
      btm[1] = btm_row[3463:3456];
      btm[2] = btm_row[3471:3464];
    end
    'd433: begin
      top[0] = top_row[3463:3456];
      top[1] = top_row[3471:3464];
      top[2] = top_row[3479:3472];
      mid[0] = mid_row[3463:3456];
      mid[1] = mid_row[3471:3464];
      mid[2] = mid_row[3479:3472];
      btm[0] = btm_row[3463:3456];
      btm[1] = btm_row[3471:3464];
      btm[2] = btm_row[3479:3472];
    end
    'd434: begin
      top[0] = top_row[3471:3464];
      top[1] = top_row[3479:3472];
      top[2] = top_row[3487:3480];
      mid[0] = mid_row[3471:3464];
      mid[1] = mid_row[3479:3472];
      mid[2] = mid_row[3487:3480];
      btm[0] = btm_row[3471:3464];
      btm[1] = btm_row[3479:3472];
      btm[2] = btm_row[3487:3480];
    end
    'd435: begin
      top[0] = top_row[3479:3472];
      top[1] = top_row[3487:3480];
      top[2] = top_row[3495:3488];
      mid[0] = mid_row[3479:3472];
      mid[1] = mid_row[3487:3480];
      mid[2] = mid_row[3495:3488];
      btm[0] = btm_row[3479:3472];
      btm[1] = btm_row[3487:3480];
      btm[2] = btm_row[3495:3488];
    end
    'd436: begin
      top[0] = top_row[3487:3480];
      top[1] = top_row[3495:3488];
      top[2] = top_row[3503:3496];
      mid[0] = mid_row[3487:3480];
      mid[1] = mid_row[3495:3488];
      mid[2] = mid_row[3503:3496];
      btm[0] = btm_row[3487:3480];
      btm[1] = btm_row[3495:3488];
      btm[2] = btm_row[3503:3496];
    end
    'd437: begin
      top[0] = top_row[3495:3488];
      top[1] = top_row[3503:3496];
      top[2] = top_row[3511:3504];
      mid[0] = mid_row[3495:3488];
      mid[1] = mid_row[3503:3496];
      mid[2] = mid_row[3511:3504];
      btm[0] = btm_row[3495:3488];
      btm[1] = btm_row[3503:3496];
      btm[2] = btm_row[3511:3504];
    end
    'd438: begin
      top[0] = top_row[3503:3496];
      top[1] = top_row[3511:3504];
      top[2] = top_row[3519:3512];
      mid[0] = mid_row[3503:3496];
      mid[1] = mid_row[3511:3504];
      mid[2] = mid_row[3519:3512];
      btm[0] = btm_row[3503:3496];
      btm[1] = btm_row[3511:3504];
      btm[2] = btm_row[3519:3512];
    end
    'd439: begin
      top[0] = top_row[3511:3504];
      top[1] = top_row[3519:3512];
      top[2] = top_row[3527:3520];
      mid[0] = mid_row[3511:3504];
      mid[1] = mid_row[3519:3512];
      mid[2] = mid_row[3527:3520];
      btm[0] = btm_row[3511:3504];
      btm[1] = btm_row[3519:3512];
      btm[2] = btm_row[3527:3520];
    end
    'd440: begin
      top[0] = top_row[3519:3512];
      top[1] = top_row[3527:3520];
      top[2] = top_row[3535:3528];
      mid[0] = mid_row[3519:3512];
      mid[1] = mid_row[3527:3520];
      mid[2] = mid_row[3535:3528];
      btm[0] = btm_row[3519:3512];
      btm[1] = btm_row[3527:3520];
      btm[2] = btm_row[3535:3528];
    end
    'd441: begin
      top[0] = top_row[3527:3520];
      top[1] = top_row[3535:3528];
      top[2] = top_row[3543:3536];
      mid[0] = mid_row[3527:3520];
      mid[1] = mid_row[3535:3528];
      mid[2] = mid_row[3543:3536];
      btm[0] = btm_row[3527:3520];
      btm[1] = btm_row[3535:3528];
      btm[2] = btm_row[3543:3536];
    end
    'd442: begin
      top[0] = top_row[3535:3528];
      top[1] = top_row[3543:3536];
      top[2] = top_row[3551:3544];
      mid[0] = mid_row[3535:3528];
      mid[1] = mid_row[3543:3536];
      mid[2] = mid_row[3551:3544];
      btm[0] = btm_row[3535:3528];
      btm[1] = btm_row[3543:3536];
      btm[2] = btm_row[3551:3544];
    end
    'd443: begin
      top[0] = top_row[3543:3536];
      top[1] = top_row[3551:3544];
      top[2] = top_row[3559:3552];
      mid[0] = mid_row[3543:3536];
      mid[1] = mid_row[3551:3544];
      mid[2] = mid_row[3559:3552];
      btm[0] = btm_row[3543:3536];
      btm[1] = btm_row[3551:3544];
      btm[2] = btm_row[3559:3552];
    end
    'd444: begin
      top[0] = top_row[3551:3544];
      top[1] = top_row[3559:3552];
      top[2] = top_row[3567:3560];
      mid[0] = mid_row[3551:3544];
      mid[1] = mid_row[3559:3552];
      mid[2] = mid_row[3567:3560];
      btm[0] = btm_row[3551:3544];
      btm[1] = btm_row[3559:3552];
      btm[2] = btm_row[3567:3560];
    end
    'd445: begin
      top[0] = top_row[3559:3552];
      top[1] = top_row[3567:3560];
      top[2] = top_row[3575:3568];
      mid[0] = mid_row[3559:3552];
      mid[1] = mid_row[3567:3560];
      mid[2] = mid_row[3575:3568];
      btm[0] = btm_row[3559:3552];
      btm[1] = btm_row[3567:3560];
      btm[2] = btm_row[3575:3568];
    end
    'd446: begin
      top[0] = top_row[3567:3560];
      top[1] = top_row[3575:3568];
      top[2] = top_row[3583:3576];
      mid[0] = mid_row[3567:3560];
      mid[1] = mid_row[3575:3568];
      mid[2] = mid_row[3583:3576];
      btm[0] = btm_row[3567:3560];
      btm[1] = btm_row[3575:3568];
      btm[2] = btm_row[3583:3576];
    end
    'd447: begin
      top[0] = top_row[3575:3568];
      top[1] = top_row[3583:3576];
      top[2] = top_row[3591:3584];
      mid[0] = mid_row[3575:3568];
      mid[1] = mid_row[3583:3576];
      mid[2] = mid_row[3591:3584];
      btm[0] = btm_row[3575:3568];
      btm[1] = btm_row[3583:3576];
      btm[2] = btm_row[3591:3584];
    end
    'd448: begin
      top[0] = top_row[3583:3576];
      top[1] = top_row[3591:3584];
      top[2] = top_row[3599:3592];
      mid[0] = mid_row[3583:3576];
      mid[1] = mid_row[3591:3584];
      mid[2] = mid_row[3599:3592];
      btm[0] = btm_row[3583:3576];
      btm[1] = btm_row[3591:3584];
      btm[2] = btm_row[3599:3592];
    end
    'd449: begin
      top[0] = top_row[3591:3584];
      top[1] = top_row[3599:3592];
      top[2] = top_row[3607:3600];
      mid[0] = mid_row[3591:3584];
      mid[1] = mid_row[3599:3592];
      mid[2] = mid_row[3607:3600];
      btm[0] = btm_row[3591:3584];
      btm[1] = btm_row[3599:3592];
      btm[2] = btm_row[3607:3600];
    end
    'd450: begin
      top[0] = top_row[3599:3592];
      top[1] = top_row[3607:3600];
      top[2] = top_row[3615:3608];
      mid[0] = mid_row[3599:3592];
      mid[1] = mid_row[3607:3600];
      mid[2] = mid_row[3615:3608];
      btm[0] = btm_row[3599:3592];
      btm[1] = btm_row[3607:3600];
      btm[2] = btm_row[3615:3608];
    end
    'd451: begin
      top[0] = top_row[3607:3600];
      top[1] = top_row[3615:3608];
      top[2] = top_row[3623:3616];
      mid[0] = mid_row[3607:3600];
      mid[1] = mid_row[3615:3608];
      mid[2] = mid_row[3623:3616];
      btm[0] = btm_row[3607:3600];
      btm[1] = btm_row[3615:3608];
      btm[2] = btm_row[3623:3616];
    end
    'd452: begin
      top[0] = top_row[3615:3608];
      top[1] = top_row[3623:3616];
      top[2] = top_row[3631:3624];
      mid[0] = mid_row[3615:3608];
      mid[1] = mid_row[3623:3616];
      mid[2] = mid_row[3631:3624];
      btm[0] = btm_row[3615:3608];
      btm[1] = btm_row[3623:3616];
      btm[2] = btm_row[3631:3624];
    end
    'd453: begin
      top[0] = top_row[3623:3616];
      top[1] = top_row[3631:3624];
      top[2] = top_row[3639:3632];
      mid[0] = mid_row[3623:3616];
      mid[1] = mid_row[3631:3624];
      mid[2] = mid_row[3639:3632];
      btm[0] = btm_row[3623:3616];
      btm[1] = btm_row[3631:3624];
      btm[2] = btm_row[3639:3632];
    end
    'd454: begin
      top[0] = top_row[3631:3624];
      top[1] = top_row[3639:3632];
      top[2] = top_row[3647:3640];
      mid[0] = mid_row[3631:3624];
      mid[1] = mid_row[3639:3632];
      mid[2] = mid_row[3647:3640];
      btm[0] = btm_row[3631:3624];
      btm[1] = btm_row[3639:3632];
      btm[2] = btm_row[3647:3640];
    end
    'd455: begin
      top[0] = top_row[3639:3632];
      top[1] = top_row[3647:3640];
      top[2] = top_row[3655:3648];
      mid[0] = mid_row[3639:3632];
      mid[1] = mid_row[3647:3640];
      mid[2] = mid_row[3655:3648];
      btm[0] = btm_row[3639:3632];
      btm[1] = btm_row[3647:3640];
      btm[2] = btm_row[3655:3648];
    end
    'd456: begin
      top[0] = top_row[3647:3640];
      top[1] = top_row[3655:3648];
      top[2] = top_row[3663:3656];
      mid[0] = mid_row[3647:3640];
      mid[1] = mid_row[3655:3648];
      mid[2] = mid_row[3663:3656];
      btm[0] = btm_row[3647:3640];
      btm[1] = btm_row[3655:3648];
      btm[2] = btm_row[3663:3656];
    end
    'd457: begin
      top[0] = top_row[3655:3648];
      top[1] = top_row[3663:3656];
      top[2] = top_row[3671:3664];
      mid[0] = mid_row[3655:3648];
      mid[1] = mid_row[3663:3656];
      mid[2] = mid_row[3671:3664];
      btm[0] = btm_row[3655:3648];
      btm[1] = btm_row[3663:3656];
      btm[2] = btm_row[3671:3664];
    end
    'd458: begin
      top[0] = top_row[3663:3656];
      top[1] = top_row[3671:3664];
      top[2] = top_row[3679:3672];
      mid[0] = mid_row[3663:3656];
      mid[1] = mid_row[3671:3664];
      mid[2] = mid_row[3679:3672];
      btm[0] = btm_row[3663:3656];
      btm[1] = btm_row[3671:3664];
      btm[2] = btm_row[3679:3672];
    end
    'd459: begin
      top[0] = top_row[3671:3664];
      top[1] = top_row[3679:3672];
      top[2] = top_row[3687:3680];
      mid[0] = mid_row[3671:3664];
      mid[1] = mid_row[3679:3672];
      mid[2] = mid_row[3687:3680];
      btm[0] = btm_row[3671:3664];
      btm[1] = btm_row[3679:3672];
      btm[2] = btm_row[3687:3680];
    end
    'd460: begin
      top[0] = top_row[3679:3672];
      top[1] = top_row[3687:3680];
      top[2] = top_row[3695:3688];
      mid[0] = mid_row[3679:3672];
      mid[1] = mid_row[3687:3680];
      mid[2] = mid_row[3695:3688];
      btm[0] = btm_row[3679:3672];
      btm[1] = btm_row[3687:3680];
      btm[2] = btm_row[3695:3688];
    end
    'd461: begin
      top[0] = top_row[3687:3680];
      top[1] = top_row[3695:3688];
      top[2] = top_row[3703:3696];
      mid[0] = mid_row[3687:3680];
      mid[1] = mid_row[3695:3688];
      mid[2] = mid_row[3703:3696];
      btm[0] = btm_row[3687:3680];
      btm[1] = btm_row[3695:3688];
      btm[2] = btm_row[3703:3696];
    end
    'd462: begin
      top[0] = top_row[3695:3688];
      top[1] = top_row[3703:3696];
      top[2] = top_row[3711:3704];
      mid[0] = mid_row[3695:3688];
      mid[1] = mid_row[3703:3696];
      mid[2] = mid_row[3711:3704];
      btm[0] = btm_row[3695:3688];
      btm[1] = btm_row[3703:3696];
      btm[2] = btm_row[3711:3704];
    end
    'd463: begin
      top[0] = top_row[3703:3696];
      top[1] = top_row[3711:3704];
      top[2] = top_row[3719:3712];
      mid[0] = mid_row[3703:3696];
      mid[1] = mid_row[3711:3704];
      mid[2] = mid_row[3719:3712];
      btm[0] = btm_row[3703:3696];
      btm[1] = btm_row[3711:3704];
      btm[2] = btm_row[3719:3712];
    end
    'd464: begin
      top[0] = top_row[3711:3704];
      top[1] = top_row[3719:3712];
      top[2] = top_row[3727:3720];
      mid[0] = mid_row[3711:3704];
      mid[1] = mid_row[3719:3712];
      mid[2] = mid_row[3727:3720];
      btm[0] = btm_row[3711:3704];
      btm[1] = btm_row[3719:3712];
      btm[2] = btm_row[3727:3720];
    end
    'd465: begin
      top[0] = top_row[3719:3712];
      top[1] = top_row[3727:3720];
      top[2] = top_row[3735:3728];
      mid[0] = mid_row[3719:3712];
      mid[1] = mid_row[3727:3720];
      mid[2] = mid_row[3735:3728];
      btm[0] = btm_row[3719:3712];
      btm[1] = btm_row[3727:3720];
      btm[2] = btm_row[3735:3728];
    end
    'd466: begin
      top[0] = top_row[3727:3720];
      top[1] = top_row[3735:3728];
      top[2] = top_row[3743:3736];
      mid[0] = mid_row[3727:3720];
      mid[1] = mid_row[3735:3728];
      mid[2] = mid_row[3743:3736];
      btm[0] = btm_row[3727:3720];
      btm[1] = btm_row[3735:3728];
      btm[2] = btm_row[3743:3736];
    end
    'd467: begin
      top[0] = top_row[3735:3728];
      top[1] = top_row[3743:3736];
      top[2] = top_row[3751:3744];
      mid[0] = mid_row[3735:3728];
      mid[1] = mid_row[3743:3736];
      mid[2] = mid_row[3751:3744];
      btm[0] = btm_row[3735:3728];
      btm[1] = btm_row[3743:3736];
      btm[2] = btm_row[3751:3744];
    end
    'd468: begin
      top[0] = top_row[3743:3736];
      top[1] = top_row[3751:3744];
      top[2] = top_row[3759:3752];
      mid[0] = mid_row[3743:3736];
      mid[1] = mid_row[3751:3744];
      mid[2] = mid_row[3759:3752];
      btm[0] = btm_row[3743:3736];
      btm[1] = btm_row[3751:3744];
      btm[2] = btm_row[3759:3752];
    end
    'd469: begin
      top[0] = top_row[3751:3744];
      top[1] = top_row[3759:3752];
      top[2] = top_row[3767:3760];
      mid[0] = mid_row[3751:3744];
      mid[1] = mid_row[3759:3752];
      mid[2] = mid_row[3767:3760];
      btm[0] = btm_row[3751:3744];
      btm[1] = btm_row[3759:3752];
      btm[2] = btm_row[3767:3760];
    end
    'd470: begin
      top[0] = top_row[3759:3752];
      top[1] = top_row[3767:3760];
      top[2] = top_row[3775:3768];
      mid[0] = mid_row[3759:3752];
      mid[1] = mid_row[3767:3760];
      mid[2] = mid_row[3775:3768];
      btm[0] = btm_row[3759:3752];
      btm[1] = btm_row[3767:3760];
      btm[2] = btm_row[3775:3768];
    end
    'd471: begin
      top[0] = top_row[3767:3760];
      top[1] = top_row[3775:3768];
      top[2] = top_row[3783:3776];
      mid[0] = mid_row[3767:3760];
      mid[1] = mid_row[3775:3768];
      mid[2] = mid_row[3783:3776];
      btm[0] = btm_row[3767:3760];
      btm[1] = btm_row[3775:3768];
      btm[2] = btm_row[3783:3776];
    end
    'd472: begin
      top[0] = top_row[3775:3768];
      top[1] = top_row[3783:3776];
      top[2] = top_row[3791:3784];
      mid[0] = mid_row[3775:3768];
      mid[1] = mid_row[3783:3776];
      mid[2] = mid_row[3791:3784];
      btm[0] = btm_row[3775:3768];
      btm[1] = btm_row[3783:3776];
      btm[2] = btm_row[3791:3784];
    end
    'd473: begin
      top[0] = top_row[3783:3776];
      top[1] = top_row[3791:3784];
      top[2] = top_row[3799:3792];
      mid[0] = mid_row[3783:3776];
      mid[1] = mid_row[3791:3784];
      mid[2] = mid_row[3799:3792];
      btm[0] = btm_row[3783:3776];
      btm[1] = btm_row[3791:3784];
      btm[2] = btm_row[3799:3792];
    end
    'd474: begin
      top[0] = top_row[3791:3784];
      top[1] = top_row[3799:3792];
      top[2] = top_row[3807:3800];
      mid[0] = mid_row[3791:3784];
      mid[1] = mid_row[3799:3792];
      mid[2] = mid_row[3807:3800];
      btm[0] = btm_row[3791:3784];
      btm[1] = btm_row[3799:3792];
      btm[2] = btm_row[3807:3800];
    end
    'd475: begin
      top[0] = top_row[3799:3792];
      top[1] = top_row[3807:3800];
      top[2] = top_row[3815:3808];
      mid[0] = mid_row[3799:3792];
      mid[1] = mid_row[3807:3800];
      mid[2] = mid_row[3815:3808];
      btm[0] = btm_row[3799:3792];
      btm[1] = btm_row[3807:3800];
      btm[2] = btm_row[3815:3808];
    end
    'd476: begin
      top[0] = top_row[3807:3800];
      top[1] = top_row[3815:3808];
      top[2] = top_row[3823:3816];
      mid[0] = mid_row[3807:3800];
      mid[1] = mid_row[3815:3808];
      mid[2] = mid_row[3823:3816];
      btm[0] = btm_row[3807:3800];
      btm[1] = btm_row[3815:3808];
      btm[2] = btm_row[3823:3816];
    end
    'd477: begin
      top[0] = top_row[3815:3808];
      top[1] = top_row[3823:3816];
      top[2] = top_row[3831:3824];
      mid[0] = mid_row[3815:3808];
      mid[1] = mid_row[3823:3816];
      mid[2] = mid_row[3831:3824];
      btm[0] = btm_row[3815:3808];
      btm[1] = btm_row[3823:3816];
      btm[2] = btm_row[3831:3824];
    end
    'd478: begin
      top[0] = top_row[3823:3816];
      top[1] = top_row[3831:3824];
      top[2] = top_row[3839:3832];
      mid[0] = mid_row[3823:3816];
      mid[1] = mid_row[3831:3824];
      mid[2] = mid_row[3839:3832];
      btm[0] = btm_row[3823:3816];
      btm[1] = btm_row[3831:3824];
      btm[2] = btm_row[3839:3832];
    end
    'd479: begin
      top[0] = top_row[3831:3824];
      top[1] = top_row[3839:3832];
      top[2] = top_row[3847:3840];
      mid[0] = mid_row[3831:3824];
      mid[1] = mid_row[3839:3832];
      mid[2] = mid_row[3847:3840];
      btm[0] = btm_row[3831:3824];
      btm[1] = btm_row[3839:3832];
      btm[2] = btm_row[3847:3840];
    end
    'd480: begin
      top[0] = top_row[3839:3832];
      top[1] = top_row[3847:3840];
      top[2] = top_row[3855:3848];
      mid[0] = mid_row[3839:3832];
      mid[1] = mid_row[3847:3840];
      mid[2] = mid_row[3855:3848];
      btm[0] = btm_row[3839:3832];
      btm[1] = btm_row[3847:3840];
      btm[2] = btm_row[3855:3848];
    end
    'd481: begin
      top[0] = top_row[3847:3840];
      top[1] = top_row[3855:3848];
      top[2] = top_row[3863:3856];
      mid[0] = mid_row[3847:3840];
      mid[1] = mid_row[3855:3848];
      mid[2] = mid_row[3863:3856];
      btm[0] = btm_row[3847:3840];
      btm[1] = btm_row[3855:3848];
      btm[2] = btm_row[3863:3856];
    end
    'd482: begin
      top[0] = top_row[3855:3848];
      top[1] = top_row[3863:3856];
      top[2] = top_row[3871:3864];
      mid[0] = mid_row[3855:3848];
      mid[1] = mid_row[3863:3856];
      mid[2] = mid_row[3871:3864];
      btm[0] = btm_row[3855:3848];
      btm[1] = btm_row[3863:3856];
      btm[2] = btm_row[3871:3864];
    end
    'd483: begin
      top[0] = top_row[3863:3856];
      top[1] = top_row[3871:3864];
      top[2] = top_row[3879:3872];
      mid[0] = mid_row[3863:3856];
      mid[1] = mid_row[3871:3864];
      mid[2] = mid_row[3879:3872];
      btm[0] = btm_row[3863:3856];
      btm[1] = btm_row[3871:3864];
      btm[2] = btm_row[3879:3872];
    end
    'd484: begin
      top[0] = top_row[3871:3864];
      top[1] = top_row[3879:3872];
      top[2] = top_row[3887:3880];
      mid[0] = mid_row[3871:3864];
      mid[1] = mid_row[3879:3872];
      mid[2] = mid_row[3887:3880];
      btm[0] = btm_row[3871:3864];
      btm[1] = btm_row[3879:3872];
      btm[2] = btm_row[3887:3880];
    end
    'd485: begin
      top[0] = top_row[3879:3872];
      top[1] = top_row[3887:3880];
      top[2] = top_row[3895:3888];
      mid[0] = mid_row[3879:3872];
      mid[1] = mid_row[3887:3880];
      mid[2] = mid_row[3895:3888];
      btm[0] = btm_row[3879:3872];
      btm[1] = btm_row[3887:3880];
      btm[2] = btm_row[3895:3888];
    end
    'd486: begin
      top[0] = top_row[3887:3880];
      top[1] = top_row[3895:3888];
      top[2] = top_row[3903:3896];
      mid[0] = mid_row[3887:3880];
      mid[1] = mid_row[3895:3888];
      mid[2] = mid_row[3903:3896];
      btm[0] = btm_row[3887:3880];
      btm[1] = btm_row[3895:3888];
      btm[2] = btm_row[3903:3896];
    end
    'd487: begin
      top[0] = top_row[3895:3888];
      top[1] = top_row[3903:3896];
      top[2] = top_row[3911:3904];
      mid[0] = mid_row[3895:3888];
      mid[1] = mid_row[3903:3896];
      mid[2] = mid_row[3911:3904];
      btm[0] = btm_row[3895:3888];
      btm[1] = btm_row[3903:3896];
      btm[2] = btm_row[3911:3904];
    end
    'd488: begin
      top[0] = top_row[3903:3896];
      top[1] = top_row[3911:3904];
      top[2] = top_row[3919:3912];
      mid[0] = mid_row[3903:3896];
      mid[1] = mid_row[3911:3904];
      mid[2] = mid_row[3919:3912];
      btm[0] = btm_row[3903:3896];
      btm[1] = btm_row[3911:3904];
      btm[2] = btm_row[3919:3912];
    end
    'd489: begin
      top[0] = top_row[3911:3904];
      top[1] = top_row[3919:3912];
      top[2] = top_row[3927:3920];
      mid[0] = mid_row[3911:3904];
      mid[1] = mid_row[3919:3912];
      mid[2] = mid_row[3927:3920];
      btm[0] = btm_row[3911:3904];
      btm[1] = btm_row[3919:3912];
      btm[2] = btm_row[3927:3920];
    end
    'd490: begin
      top[0] = top_row[3919:3912];
      top[1] = top_row[3927:3920];
      top[2] = top_row[3935:3928];
      mid[0] = mid_row[3919:3912];
      mid[1] = mid_row[3927:3920];
      mid[2] = mid_row[3935:3928];
      btm[0] = btm_row[3919:3912];
      btm[1] = btm_row[3927:3920];
      btm[2] = btm_row[3935:3928];
    end
    'd491: begin
      top[0] = top_row[3927:3920];
      top[1] = top_row[3935:3928];
      top[2] = top_row[3943:3936];
      mid[0] = mid_row[3927:3920];
      mid[1] = mid_row[3935:3928];
      mid[2] = mid_row[3943:3936];
      btm[0] = btm_row[3927:3920];
      btm[1] = btm_row[3935:3928];
      btm[2] = btm_row[3943:3936];
    end
    'd492: begin
      top[0] = top_row[3935:3928];
      top[1] = top_row[3943:3936];
      top[2] = top_row[3951:3944];
      mid[0] = mid_row[3935:3928];
      mid[1] = mid_row[3943:3936];
      mid[2] = mid_row[3951:3944];
      btm[0] = btm_row[3935:3928];
      btm[1] = btm_row[3943:3936];
      btm[2] = btm_row[3951:3944];
    end
    'd493: begin
      top[0] = top_row[3943:3936];
      top[1] = top_row[3951:3944];
      top[2] = top_row[3959:3952];
      mid[0] = mid_row[3943:3936];
      mid[1] = mid_row[3951:3944];
      mid[2] = mid_row[3959:3952];
      btm[0] = btm_row[3943:3936];
      btm[1] = btm_row[3951:3944];
      btm[2] = btm_row[3959:3952];
    end
    'd494: begin
      top[0] = top_row[3951:3944];
      top[1] = top_row[3959:3952];
      top[2] = top_row[3967:3960];
      mid[0] = mid_row[3951:3944];
      mid[1] = mid_row[3959:3952];
      mid[2] = mid_row[3967:3960];
      btm[0] = btm_row[3951:3944];
      btm[1] = btm_row[3959:3952];
      btm[2] = btm_row[3967:3960];
    end
    'd495: begin
      top[0] = top_row[3959:3952];
      top[1] = top_row[3967:3960];
      top[2] = top_row[3975:3968];
      mid[0] = mid_row[3959:3952];
      mid[1] = mid_row[3967:3960];
      mid[2] = mid_row[3975:3968];
      btm[0] = btm_row[3959:3952];
      btm[1] = btm_row[3967:3960];
      btm[2] = btm_row[3975:3968];
    end
    'd496: begin
      top[0] = top_row[3967:3960];
      top[1] = top_row[3975:3968];
      top[2] = top_row[3983:3976];
      mid[0] = mid_row[3967:3960];
      mid[1] = mid_row[3975:3968];
      mid[2] = mid_row[3983:3976];
      btm[0] = btm_row[3967:3960];
      btm[1] = btm_row[3975:3968];
      btm[2] = btm_row[3983:3976];
    end
    'd497: begin
      top[0] = top_row[3975:3968];
      top[1] = top_row[3983:3976];
      top[2] = top_row[3991:3984];
      mid[0] = mid_row[3975:3968];
      mid[1] = mid_row[3983:3976];
      mid[2] = mid_row[3991:3984];
      btm[0] = btm_row[3975:3968];
      btm[1] = btm_row[3983:3976];
      btm[2] = btm_row[3991:3984];
    end
    'd498: begin
      top[0] = top_row[3983:3976];
      top[1] = top_row[3991:3984];
      top[2] = top_row[3999:3992];
      mid[0] = mid_row[3983:3976];
      mid[1] = mid_row[3991:3984];
      mid[2] = mid_row[3999:3992];
      btm[0] = btm_row[3983:3976];
      btm[1] = btm_row[3991:3984];
      btm[2] = btm_row[3999:3992];
    end
    'd499: begin
      top[0] = top_row[3991:3984];
      top[1] = top_row[3999:3992];
      top[2] = top_row[4007:4000];
      mid[0] = mid_row[3991:3984];
      mid[1] = mid_row[3999:3992];
      mid[2] = mid_row[4007:4000];
      btm[0] = btm_row[3991:3984];
      btm[1] = btm_row[3999:3992];
      btm[2] = btm_row[4007:4000];
    end
    'd500: begin
      top[0] = top_row[3999:3992];
      top[1] = top_row[4007:4000];
      top[2] = top_row[4015:4008];
      mid[0] = mid_row[3999:3992];
      mid[1] = mid_row[4007:4000];
      mid[2] = mid_row[4015:4008];
      btm[0] = btm_row[3999:3992];
      btm[1] = btm_row[4007:4000];
      btm[2] = btm_row[4015:4008];
    end
    'd501: begin
      top[0] = top_row[4007:4000];
      top[1] = top_row[4015:4008];
      top[2] = top_row[4023:4016];
      mid[0] = mid_row[4007:4000];
      mid[1] = mid_row[4015:4008];
      mid[2] = mid_row[4023:4016];
      btm[0] = btm_row[4007:4000];
      btm[1] = btm_row[4015:4008];
      btm[2] = btm_row[4023:4016];
    end
    'd502: begin
      top[0] = top_row[4015:4008];
      top[1] = top_row[4023:4016];
      top[2] = top_row[4031:4024];
      mid[0] = mid_row[4015:4008];
      mid[1] = mid_row[4023:4016];
      mid[2] = mid_row[4031:4024];
      btm[0] = btm_row[4015:4008];
      btm[1] = btm_row[4023:4016];
      btm[2] = btm_row[4031:4024];
    end
    'd503: begin
      top[0] = top_row[4023:4016];
      top[1] = top_row[4031:4024];
      top[2] = top_row[4039:4032];
      mid[0] = mid_row[4023:4016];
      mid[1] = mid_row[4031:4024];
      mid[2] = mid_row[4039:4032];
      btm[0] = btm_row[4023:4016];
      btm[1] = btm_row[4031:4024];
      btm[2] = btm_row[4039:4032];
    end
    'd504: begin
      top[0] = top_row[4031:4024];
      top[1] = top_row[4039:4032];
      top[2] = top_row[4047:4040];
      mid[0] = mid_row[4031:4024];
      mid[1] = mid_row[4039:4032];
      mid[2] = mid_row[4047:4040];
      btm[0] = btm_row[4031:4024];
      btm[1] = btm_row[4039:4032];
      btm[2] = btm_row[4047:4040];
    end
    'd505: begin
      top[0] = top_row[4039:4032];
      top[1] = top_row[4047:4040];
      top[2] = top_row[4055:4048];
      mid[0] = mid_row[4039:4032];
      mid[1] = mid_row[4047:4040];
      mid[2] = mid_row[4055:4048];
      btm[0] = btm_row[4039:4032];
      btm[1] = btm_row[4047:4040];
      btm[2] = btm_row[4055:4048];
    end
    'd506: begin
      top[0] = top_row[4047:4040];
      top[1] = top_row[4055:4048];
      top[2] = top_row[4063:4056];
      mid[0] = mid_row[4047:4040];
      mid[1] = mid_row[4055:4048];
      mid[2] = mid_row[4063:4056];
      btm[0] = btm_row[4047:4040];
      btm[1] = btm_row[4055:4048];
      btm[2] = btm_row[4063:4056];
    end
    'd507: begin
      top[0] = top_row[4055:4048];
      top[1] = top_row[4063:4056];
      top[2] = top_row[4071:4064];
      mid[0] = mid_row[4055:4048];
      mid[1] = mid_row[4063:4056];
      mid[2] = mid_row[4071:4064];
      btm[0] = btm_row[4055:4048];
      btm[1] = btm_row[4063:4056];
      btm[2] = btm_row[4071:4064];
    end
    'd508: begin
      top[0] = top_row[4063:4056];
      top[1] = top_row[4071:4064];
      top[2] = top_row[4079:4072];
      mid[0] = mid_row[4063:4056];
      mid[1] = mid_row[4071:4064];
      mid[2] = mid_row[4079:4072];
      btm[0] = btm_row[4063:4056];
      btm[1] = btm_row[4071:4064];
      btm[2] = btm_row[4079:4072];
    end
    'd509: begin
      top[0] = top_row[4071:4064];
      top[1] = top_row[4079:4072];
      top[2] = top_row[4087:4080];
      mid[0] = mid_row[4071:4064];
      mid[1] = mid_row[4079:4072];
      mid[2] = mid_row[4087:4080];
      btm[0] = btm_row[4071:4064];
      btm[1] = btm_row[4079:4072];
      btm[2] = btm_row[4087:4080];
    end
    'd510: begin
      top[0] = top_row[4079:4072];
      top[1] = top_row[4087:4080];
      top[2] = top_row[4095:4088];
      mid[0] = mid_row[4079:4072];
      mid[1] = mid_row[4087:4080];
      mid[2] = mid_row[4095:4088];
      btm[0] = btm_row[4079:4072];
      btm[1] = btm_row[4087:4080];
      btm[2] = btm_row[4095:4088];
    end
    'd511: begin
      top[0] = top_row[4087:4080];
      top[1] = top_row[4095:4088];
      top[2] = top_row[4103:4096];
      mid[0] = mid_row[4087:4080];
      mid[1] = mid_row[4095:4088];
      mid[2] = mid_row[4103:4096];
      btm[0] = btm_row[4087:4080];
      btm[1] = btm_row[4095:4088];
      btm[2] = btm_row[4103:4096];
    end
    'd512: begin
      top[0] = top_row[4095:4088];
      top[1] = top_row[4103:4096];
      top[2] = top_row[4111:4104];
      mid[0] = mid_row[4095:4088];
      mid[1] = mid_row[4103:4096];
      mid[2] = mid_row[4111:4104];
      btm[0] = btm_row[4095:4088];
      btm[1] = btm_row[4103:4096];
      btm[2] = btm_row[4111:4104];
    end
    'd513: begin
      top[0] = top_row[4103:4096];
      top[1] = top_row[4111:4104];
      top[2] = top_row[4119:4112];
      mid[0] = mid_row[4103:4096];
      mid[1] = mid_row[4111:4104];
      mid[2] = mid_row[4119:4112];
      btm[0] = btm_row[4103:4096];
      btm[1] = btm_row[4111:4104];
      btm[2] = btm_row[4119:4112];
    end
    'd514: begin
      top[0] = top_row[4111:4104];
      top[1] = top_row[4119:4112];
      top[2] = top_row[4127:4120];
      mid[0] = mid_row[4111:4104];
      mid[1] = mid_row[4119:4112];
      mid[2] = mid_row[4127:4120];
      btm[0] = btm_row[4111:4104];
      btm[1] = btm_row[4119:4112];
      btm[2] = btm_row[4127:4120];
    end
    'd515: begin
      top[0] = top_row[4119:4112];
      top[1] = top_row[4127:4120];
      top[2] = top_row[4135:4128];
      mid[0] = mid_row[4119:4112];
      mid[1] = mid_row[4127:4120];
      mid[2] = mid_row[4135:4128];
      btm[0] = btm_row[4119:4112];
      btm[1] = btm_row[4127:4120];
      btm[2] = btm_row[4135:4128];
    end
    'd516: begin
      top[0] = top_row[4127:4120];
      top[1] = top_row[4135:4128];
      top[2] = top_row[4143:4136];
      mid[0] = mid_row[4127:4120];
      mid[1] = mid_row[4135:4128];
      mid[2] = mid_row[4143:4136];
      btm[0] = btm_row[4127:4120];
      btm[1] = btm_row[4135:4128];
      btm[2] = btm_row[4143:4136];
    end
    'd517: begin
      top[0] = top_row[4135:4128];
      top[1] = top_row[4143:4136];
      top[2] = top_row[4151:4144];
      mid[0] = mid_row[4135:4128];
      mid[1] = mid_row[4143:4136];
      mid[2] = mid_row[4151:4144];
      btm[0] = btm_row[4135:4128];
      btm[1] = btm_row[4143:4136];
      btm[2] = btm_row[4151:4144];
    end
    'd518: begin
      top[0] = top_row[4143:4136];
      top[1] = top_row[4151:4144];
      top[2] = top_row[4159:4152];
      mid[0] = mid_row[4143:4136];
      mid[1] = mid_row[4151:4144];
      mid[2] = mid_row[4159:4152];
      btm[0] = btm_row[4143:4136];
      btm[1] = btm_row[4151:4144];
      btm[2] = btm_row[4159:4152];
    end
    'd519: begin
      top[0] = top_row[4151:4144];
      top[1] = top_row[4159:4152];
      top[2] = top_row[4167:4160];
      mid[0] = mid_row[4151:4144];
      mid[1] = mid_row[4159:4152];
      mid[2] = mid_row[4167:4160];
      btm[0] = btm_row[4151:4144];
      btm[1] = btm_row[4159:4152];
      btm[2] = btm_row[4167:4160];
    end
    'd520: begin
      top[0] = top_row[4159:4152];
      top[1] = top_row[4167:4160];
      top[2] = top_row[4175:4168];
      mid[0] = mid_row[4159:4152];
      mid[1] = mid_row[4167:4160];
      mid[2] = mid_row[4175:4168];
      btm[0] = btm_row[4159:4152];
      btm[1] = btm_row[4167:4160];
      btm[2] = btm_row[4175:4168];
    end
    'd521: begin
      top[0] = top_row[4167:4160];
      top[1] = top_row[4175:4168];
      top[2] = top_row[4183:4176];
      mid[0] = mid_row[4167:4160];
      mid[1] = mid_row[4175:4168];
      mid[2] = mid_row[4183:4176];
      btm[0] = btm_row[4167:4160];
      btm[1] = btm_row[4175:4168];
      btm[2] = btm_row[4183:4176];
    end
    'd522: begin
      top[0] = top_row[4175:4168];
      top[1] = top_row[4183:4176];
      top[2] = top_row[4191:4184];
      mid[0] = mid_row[4175:4168];
      mid[1] = mid_row[4183:4176];
      mid[2] = mid_row[4191:4184];
      btm[0] = btm_row[4175:4168];
      btm[1] = btm_row[4183:4176];
      btm[2] = btm_row[4191:4184];
    end
    'd523: begin
      top[0] = top_row[4183:4176];
      top[1] = top_row[4191:4184];
      top[2] = top_row[4199:4192];
      mid[0] = mid_row[4183:4176];
      mid[1] = mid_row[4191:4184];
      mid[2] = mid_row[4199:4192];
      btm[0] = btm_row[4183:4176];
      btm[1] = btm_row[4191:4184];
      btm[2] = btm_row[4199:4192];
    end
    'd524: begin
      top[0] = top_row[4191:4184];
      top[1] = top_row[4199:4192];
      top[2] = top_row[4207:4200];
      mid[0] = mid_row[4191:4184];
      mid[1] = mid_row[4199:4192];
      mid[2] = mid_row[4207:4200];
      btm[0] = btm_row[4191:4184];
      btm[1] = btm_row[4199:4192];
      btm[2] = btm_row[4207:4200];
    end
    'd525: begin
      top[0] = top_row[4199:4192];
      top[1] = top_row[4207:4200];
      top[2] = top_row[4215:4208];
      mid[0] = mid_row[4199:4192];
      mid[1] = mid_row[4207:4200];
      mid[2] = mid_row[4215:4208];
      btm[0] = btm_row[4199:4192];
      btm[1] = btm_row[4207:4200];
      btm[2] = btm_row[4215:4208];
    end
    'd526: begin
      top[0] = top_row[4207:4200];
      top[1] = top_row[4215:4208];
      top[2] = top_row[4223:4216];
      mid[0] = mid_row[4207:4200];
      mid[1] = mid_row[4215:4208];
      mid[2] = mid_row[4223:4216];
      btm[0] = btm_row[4207:4200];
      btm[1] = btm_row[4215:4208];
      btm[2] = btm_row[4223:4216];
    end
    'd527: begin
      top[0] = top_row[4215:4208];
      top[1] = top_row[4223:4216];
      top[2] = top_row[4231:4224];
      mid[0] = mid_row[4215:4208];
      mid[1] = mid_row[4223:4216];
      mid[2] = mid_row[4231:4224];
      btm[0] = btm_row[4215:4208];
      btm[1] = btm_row[4223:4216];
      btm[2] = btm_row[4231:4224];
    end
    'd528: begin
      top[0] = top_row[4223:4216];
      top[1] = top_row[4231:4224];
      top[2] = top_row[4239:4232];
      mid[0] = mid_row[4223:4216];
      mid[1] = mid_row[4231:4224];
      mid[2] = mid_row[4239:4232];
      btm[0] = btm_row[4223:4216];
      btm[1] = btm_row[4231:4224];
      btm[2] = btm_row[4239:4232];
    end
    'd529: begin
      top[0] = top_row[4231:4224];
      top[1] = top_row[4239:4232];
      top[2] = top_row[4247:4240];
      mid[0] = mid_row[4231:4224];
      mid[1] = mid_row[4239:4232];
      mid[2] = mid_row[4247:4240];
      btm[0] = btm_row[4231:4224];
      btm[1] = btm_row[4239:4232];
      btm[2] = btm_row[4247:4240];
    end
    'd530: begin
      top[0] = top_row[4239:4232];
      top[1] = top_row[4247:4240];
      top[2] = top_row[4255:4248];
      mid[0] = mid_row[4239:4232];
      mid[1] = mid_row[4247:4240];
      mid[2] = mid_row[4255:4248];
      btm[0] = btm_row[4239:4232];
      btm[1] = btm_row[4247:4240];
      btm[2] = btm_row[4255:4248];
    end
    'd531: begin
      top[0] = top_row[4247:4240];
      top[1] = top_row[4255:4248];
      top[2] = top_row[4263:4256];
      mid[0] = mid_row[4247:4240];
      mid[1] = mid_row[4255:4248];
      mid[2] = mid_row[4263:4256];
      btm[0] = btm_row[4247:4240];
      btm[1] = btm_row[4255:4248];
      btm[2] = btm_row[4263:4256];
    end
    'd532: begin
      top[0] = top_row[4255:4248];
      top[1] = top_row[4263:4256];
      top[2] = top_row[4271:4264];
      mid[0] = mid_row[4255:4248];
      mid[1] = mid_row[4263:4256];
      mid[2] = mid_row[4271:4264];
      btm[0] = btm_row[4255:4248];
      btm[1] = btm_row[4263:4256];
      btm[2] = btm_row[4271:4264];
    end
    'd533: begin
      top[0] = top_row[4263:4256];
      top[1] = top_row[4271:4264];
      top[2] = top_row[4279:4272];
      mid[0] = mid_row[4263:4256];
      mid[1] = mid_row[4271:4264];
      mid[2] = mid_row[4279:4272];
      btm[0] = btm_row[4263:4256];
      btm[1] = btm_row[4271:4264];
      btm[2] = btm_row[4279:4272];
    end
    'd534: begin
      top[0] = top_row[4271:4264];
      top[1] = top_row[4279:4272];
      top[2] = top_row[4287:4280];
      mid[0] = mid_row[4271:4264];
      mid[1] = mid_row[4279:4272];
      mid[2] = mid_row[4287:4280];
      btm[0] = btm_row[4271:4264];
      btm[1] = btm_row[4279:4272];
      btm[2] = btm_row[4287:4280];
    end
    'd535: begin
      top[0] = top_row[4279:4272];
      top[1] = top_row[4287:4280];
      top[2] = top_row[4295:4288];
      mid[0] = mid_row[4279:4272];
      mid[1] = mid_row[4287:4280];
      mid[2] = mid_row[4295:4288];
      btm[0] = btm_row[4279:4272];
      btm[1] = btm_row[4287:4280];
      btm[2] = btm_row[4295:4288];
    end
    'd536: begin
      top[0] = top_row[4287:4280];
      top[1] = top_row[4295:4288];
      top[2] = top_row[4303:4296];
      mid[0] = mid_row[4287:4280];
      mid[1] = mid_row[4295:4288];
      mid[2] = mid_row[4303:4296];
      btm[0] = btm_row[4287:4280];
      btm[1] = btm_row[4295:4288];
      btm[2] = btm_row[4303:4296];
    end
    'd537: begin
      top[0] = top_row[4295:4288];
      top[1] = top_row[4303:4296];
      top[2] = top_row[4311:4304];
      mid[0] = mid_row[4295:4288];
      mid[1] = mid_row[4303:4296];
      mid[2] = mid_row[4311:4304];
      btm[0] = btm_row[4295:4288];
      btm[1] = btm_row[4303:4296];
      btm[2] = btm_row[4311:4304];
    end
    'd538: begin
      top[0] = top_row[4303:4296];
      top[1] = top_row[4311:4304];
      top[2] = top_row[4319:4312];
      mid[0] = mid_row[4303:4296];
      mid[1] = mid_row[4311:4304];
      mid[2] = mid_row[4319:4312];
      btm[0] = btm_row[4303:4296];
      btm[1] = btm_row[4311:4304];
      btm[2] = btm_row[4319:4312];
    end
    'd539: begin
      top[0] = top_row[4311:4304];
      top[1] = top_row[4319:4312];
      top[2] = top_row[4327:4320];
      mid[0] = mid_row[4311:4304];
      mid[1] = mid_row[4319:4312];
      mid[2] = mid_row[4327:4320];
      btm[0] = btm_row[4311:4304];
      btm[1] = btm_row[4319:4312];
      btm[2] = btm_row[4327:4320];
    end
    'd540: begin
      top[0] = top_row[4319:4312];
      top[1] = top_row[4327:4320];
      top[2] = top_row[4335:4328];
      mid[0] = mid_row[4319:4312];
      mid[1] = mid_row[4327:4320];
      mid[2] = mid_row[4335:4328];
      btm[0] = btm_row[4319:4312];
      btm[1] = btm_row[4327:4320];
      btm[2] = btm_row[4335:4328];
    end
    'd541: begin
      top[0] = top_row[4327:4320];
      top[1] = top_row[4335:4328];
      top[2] = top_row[4343:4336];
      mid[0] = mid_row[4327:4320];
      mid[1] = mid_row[4335:4328];
      mid[2] = mid_row[4343:4336];
      btm[0] = btm_row[4327:4320];
      btm[1] = btm_row[4335:4328];
      btm[2] = btm_row[4343:4336];
    end
    'd542: begin
      top[0] = top_row[4335:4328];
      top[1] = top_row[4343:4336];
      top[2] = top_row[4351:4344];
      mid[0] = mid_row[4335:4328];
      mid[1] = mid_row[4343:4336];
      mid[2] = mid_row[4351:4344];
      btm[0] = btm_row[4335:4328];
      btm[1] = btm_row[4343:4336];
      btm[2] = btm_row[4351:4344];
    end
    'd543: begin
      top[0] = top_row[4343:4336];
      top[1] = top_row[4351:4344];
      top[2] = top_row[4359:4352];
      mid[0] = mid_row[4343:4336];
      mid[1] = mid_row[4351:4344];
      mid[2] = mid_row[4359:4352];
      btm[0] = btm_row[4343:4336];
      btm[1] = btm_row[4351:4344];
      btm[2] = btm_row[4359:4352];
    end
    'd544: begin
      top[0] = top_row[4351:4344];
      top[1] = top_row[4359:4352];
      top[2] = top_row[4367:4360];
      mid[0] = mid_row[4351:4344];
      mid[1] = mid_row[4359:4352];
      mid[2] = mid_row[4367:4360];
      btm[0] = btm_row[4351:4344];
      btm[1] = btm_row[4359:4352];
      btm[2] = btm_row[4367:4360];
    end
    'd545: begin
      top[0] = top_row[4359:4352];
      top[1] = top_row[4367:4360];
      top[2] = top_row[4375:4368];
      mid[0] = mid_row[4359:4352];
      mid[1] = mid_row[4367:4360];
      mid[2] = mid_row[4375:4368];
      btm[0] = btm_row[4359:4352];
      btm[1] = btm_row[4367:4360];
      btm[2] = btm_row[4375:4368];
    end
    'd546: begin
      top[0] = top_row[4367:4360];
      top[1] = top_row[4375:4368];
      top[2] = top_row[4383:4376];
      mid[0] = mid_row[4367:4360];
      mid[1] = mid_row[4375:4368];
      mid[2] = mid_row[4383:4376];
      btm[0] = btm_row[4367:4360];
      btm[1] = btm_row[4375:4368];
      btm[2] = btm_row[4383:4376];
    end
    'd547: begin
      top[0] = top_row[4375:4368];
      top[1] = top_row[4383:4376];
      top[2] = top_row[4391:4384];
      mid[0] = mid_row[4375:4368];
      mid[1] = mid_row[4383:4376];
      mid[2] = mid_row[4391:4384];
      btm[0] = btm_row[4375:4368];
      btm[1] = btm_row[4383:4376];
      btm[2] = btm_row[4391:4384];
    end
    'd548: begin
      top[0] = top_row[4383:4376];
      top[1] = top_row[4391:4384];
      top[2] = top_row[4399:4392];
      mid[0] = mid_row[4383:4376];
      mid[1] = mid_row[4391:4384];
      mid[2] = mid_row[4399:4392];
      btm[0] = btm_row[4383:4376];
      btm[1] = btm_row[4391:4384];
      btm[2] = btm_row[4399:4392];
    end
    'd549: begin
      top[0] = top_row[4391:4384];
      top[1] = top_row[4399:4392];
      top[2] = top_row[4407:4400];
      mid[0] = mid_row[4391:4384];
      mid[1] = mid_row[4399:4392];
      mid[2] = mid_row[4407:4400];
      btm[0] = btm_row[4391:4384];
      btm[1] = btm_row[4399:4392];
      btm[2] = btm_row[4407:4400];
    end
    'd550: begin
      top[0] = top_row[4399:4392];
      top[1] = top_row[4407:4400];
      top[2] = top_row[4415:4408];
      mid[0] = mid_row[4399:4392];
      mid[1] = mid_row[4407:4400];
      mid[2] = mid_row[4415:4408];
      btm[0] = btm_row[4399:4392];
      btm[1] = btm_row[4407:4400];
      btm[2] = btm_row[4415:4408];
    end
    'd551: begin
      top[0] = top_row[4407:4400];
      top[1] = top_row[4415:4408];
      top[2] = top_row[4423:4416];
      mid[0] = mid_row[4407:4400];
      mid[1] = mid_row[4415:4408];
      mid[2] = mid_row[4423:4416];
      btm[0] = btm_row[4407:4400];
      btm[1] = btm_row[4415:4408];
      btm[2] = btm_row[4423:4416];
    end
    'd552: begin
      top[0] = top_row[4415:4408];
      top[1] = top_row[4423:4416];
      top[2] = top_row[4431:4424];
      mid[0] = mid_row[4415:4408];
      mid[1] = mid_row[4423:4416];
      mid[2] = mid_row[4431:4424];
      btm[0] = btm_row[4415:4408];
      btm[1] = btm_row[4423:4416];
      btm[2] = btm_row[4431:4424];
    end
    'd553: begin
      top[0] = top_row[4423:4416];
      top[1] = top_row[4431:4424];
      top[2] = top_row[4439:4432];
      mid[0] = mid_row[4423:4416];
      mid[1] = mid_row[4431:4424];
      mid[2] = mid_row[4439:4432];
      btm[0] = btm_row[4423:4416];
      btm[1] = btm_row[4431:4424];
      btm[2] = btm_row[4439:4432];
    end
    'd554: begin
      top[0] = top_row[4431:4424];
      top[1] = top_row[4439:4432];
      top[2] = top_row[4447:4440];
      mid[0] = mid_row[4431:4424];
      mid[1] = mid_row[4439:4432];
      mid[2] = mid_row[4447:4440];
      btm[0] = btm_row[4431:4424];
      btm[1] = btm_row[4439:4432];
      btm[2] = btm_row[4447:4440];
    end
    'd555: begin
      top[0] = top_row[4439:4432];
      top[1] = top_row[4447:4440];
      top[2] = top_row[4455:4448];
      mid[0] = mid_row[4439:4432];
      mid[1] = mid_row[4447:4440];
      mid[2] = mid_row[4455:4448];
      btm[0] = btm_row[4439:4432];
      btm[1] = btm_row[4447:4440];
      btm[2] = btm_row[4455:4448];
    end
    'd556: begin
      top[0] = top_row[4447:4440];
      top[1] = top_row[4455:4448];
      top[2] = top_row[4463:4456];
      mid[0] = mid_row[4447:4440];
      mid[1] = mid_row[4455:4448];
      mid[2] = mid_row[4463:4456];
      btm[0] = btm_row[4447:4440];
      btm[1] = btm_row[4455:4448];
      btm[2] = btm_row[4463:4456];
    end
    'd557: begin
      top[0] = top_row[4455:4448];
      top[1] = top_row[4463:4456];
      top[2] = top_row[4471:4464];
      mid[0] = mid_row[4455:4448];
      mid[1] = mid_row[4463:4456];
      mid[2] = mid_row[4471:4464];
      btm[0] = btm_row[4455:4448];
      btm[1] = btm_row[4463:4456];
      btm[2] = btm_row[4471:4464];
    end
    'd558: begin
      top[0] = top_row[4463:4456];
      top[1] = top_row[4471:4464];
      top[2] = top_row[4479:4472];
      mid[0] = mid_row[4463:4456];
      mid[1] = mid_row[4471:4464];
      mid[2] = mid_row[4479:4472];
      btm[0] = btm_row[4463:4456];
      btm[1] = btm_row[4471:4464];
      btm[2] = btm_row[4479:4472];
    end
    'd559: begin
      top[0] = top_row[4471:4464];
      top[1] = top_row[4479:4472];
      top[2] = top_row[4487:4480];
      mid[0] = mid_row[4471:4464];
      mid[1] = mid_row[4479:4472];
      mid[2] = mid_row[4487:4480];
      btm[0] = btm_row[4471:4464];
      btm[1] = btm_row[4479:4472];
      btm[2] = btm_row[4487:4480];
    end
    'd560: begin
      top[0] = top_row[4479:4472];
      top[1] = top_row[4487:4480];
      top[2] = top_row[4495:4488];
      mid[0] = mid_row[4479:4472];
      mid[1] = mid_row[4487:4480];
      mid[2] = mid_row[4495:4488];
      btm[0] = btm_row[4479:4472];
      btm[1] = btm_row[4487:4480];
      btm[2] = btm_row[4495:4488];
    end
    'd561: begin
      top[0] = top_row[4487:4480];
      top[1] = top_row[4495:4488];
      top[2] = top_row[4503:4496];
      mid[0] = mid_row[4487:4480];
      mid[1] = mid_row[4495:4488];
      mid[2] = mid_row[4503:4496];
      btm[0] = btm_row[4487:4480];
      btm[1] = btm_row[4495:4488];
      btm[2] = btm_row[4503:4496];
    end
    'd562: begin
      top[0] = top_row[4495:4488];
      top[1] = top_row[4503:4496];
      top[2] = top_row[4511:4504];
      mid[0] = mid_row[4495:4488];
      mid[1] = mid_row[4503:4496];
      mid[2] = mid_row[4511:4504];
      btm[0] = btm_row[4495:4488];
      btm[1] = btm_row[4503:4496];
      btm[2] = btm_row[4511:4504];
    end
    'd563: begin
      top[0] = top_row[4503:4496];
      top[1] = top_row[4511:4504];
      top[2] = top_row[4519:4512];
      mid[0] = mid_row[4503:4496];
      mid[1] = mid_row[4511:4504];
      mid[2] = mid_row[4519:4512];
      btm[0] = btm_row[4503:4496];
      btm[1] = btm_row[4511:4504];
      btm[2] = btm_row[4519:4512];
    end
    'd564: begin
      top[0] = top_row[4511:4504];
      top[1] = top_row[4519:4512];
      top[2] = top_row[4527:4520];
      mid[0] = mid_row[4511:4504];
      mid[1] = mid_row[4519:4512];
      mid[2] = mid_row[4527:4520];
      btm[0] = btm_row[4511:4504];
      btm[1] = btm_row[4519:4512];
      btm[2] = btm_row[4527:4520];
    end
    'd565: begin
      top[0] = top_row[4519:4512];
      top[1] = top_row[4527:4520];
      top[2] = top_row[4535:4528];
      mid[0] = mid_row[4519:4512];
      mid[1] = mid_row[4527:4520];
      mid[2] = mid_row[4535:4528];
      btm[0] = btm_row[4519:4512];
      btm[1] = btm_row[4527:4520];
      btm[2] = btm_row[4535:4528];
    end
    'd566: begin
      top[0] = top_row[4527:4520];
      top[1] = top_row[4535:4528];
      top[2] = top_row[4543:4536];
      mid[0] = mid_row[4527:4520];
      mid[1] = mid_row[4535:4528];
      mid[2] = mid_row[4543:4536];
      btm[0] = btm_row[4527:4520];
      btm[1] = btm_row[4535:4528];
      btm[2] = btm_row[4543:4536];
    end
    'd567: begin
      top[0] = top_row[4535:4528];
      top[1] = top_row[4543:4536];
      top[2] = top_row[4551:4544];
      mid[0] = mid_row[4535:4528];
      mid[1] = mid_row[4543:4536];
      mid[2] = mid_row[4551:4544];
      btm[0] = btm_row[4535:4528];
      btm[1] = btm_row[4543:4536];
      btm[2] = btm_row[4551:4544];
    end
    'd568: begin
      top[0] = top_row[4543:4536];
      top[1] = top_row[4551:4544];
      top[2] = top_row[4559:4552];
      mid[0] = mid_row[4543:4536];
      mid[1] = mid_row[4551:4544];
      mid[2] = mid_row[4559:4552];
      btm[0] = btm_row[4543:4536];
      btm[1] = btm_row[4551:4544];
      btm[2] = btm_row[4559:4552];
    end
    'd569: begin
      top[0] = top_row[4551:4544];
      top[1] = top_row[4559:4552];
      top[2] = top_row[4567:4560];
      mid[0] = mid_row[4551:4544];
      mid[1] = mid_row[4559:4552];
      mid[2] = mid_row[4567:4560];
      btm[0] = btm_row[4551:4544];
      btm[1] = btm_row[4559:4552];
      btm[2] = btm_row[4567:4560];
    end
    'd570: begin
      top[0] = top_row[4559:4552];
      top[1] = top_row[4567:4560];
      top[2] = top_row[4575:4568];
      mid[0] = mid_row[4559:4552];
      mid[1] = mid_row[4567:4560];
      mid[2] = mid_row[4575:4568];
      btm[0] = btm_row[4559:4552];
      btm[1] = btm_row[4567:4560];
      btm[2] = btm_row[4575:4568];
    end
    'd571: begin
      top[0] = top_row[4567:4560];
      top[1] = top_row[4575:4568];
      top[2] = top_row[4583:4576];
      mid[0] = mid_row[4567:4560];
      mid[1] = mid_row[4575:4568];
      mid[2] = mid_row[4583:4576];
      btm[0] = btm_row[4567:4560];
      btm[1] = btm_row[4575:4568];
      btm[2] = btm_row[4583:4576];
    end
    'd572: begin
      top[0] = top_row[4575:4568];
      top[1] = top_row[4583:4576];
      top[2] = top_row[4591:4584];
      mid[0] = mid_row[4575:4568];
      mid[1] = mid_row[4583:4576];
      mid[2] = mid_row[4591:4584];
      btm[0] = btm_row[4575:4568];
      btm[1] = btm_row[4583:4576];
      btm[2] = btm_row[4591:4584];
    end
    'd573: begin
      top[0] = top_row[4583:4576];
      top[1] = top_row[4591:4584];
      top[2] = top_row[4599:4592];
      mid[0] = mid_row[4583:4576];
      mid[1] = mid_row[4591:4584];
      mid[2] = mid_row[4599:4592];
      btm[0] = btm_row[4583:4576];
      btm[1] = btm_row[4591:4584];
      btm[2] = btm_row[4599:4592];
    end
    'd574: begin
      top[0] = top_row[4591:4584];
      top[1] = top_row[4599:4592];
      top[2] = top_row[4607:4600];
      mid[0] = mid_row[4591:4584];
      mid[1] = mid_row[4599:4592];
      mid[2] = mid_row[4607:4600];
      btm[0] = btm_row[4591:4584];
      btm[1] = btm_row[4599:4592];
      btm[2] = btm_row[4607:4600];
    end
    'd575: begin
      top[0] = top_row[4599:4592];
      top[1] = top_row[4607:4600];
      top[2] = top_row[4615:4608];
      mid[0] = mid_row[4599:4592];
      mid[1] = mid_row[4607:4600];
      mid[2] = mid_row[4615:4608];
      btm[0] = btm_row[4599:4592];
      btm[1] = btm_row[4607:4600];
      btm[2] = btm_row[4615:4608];
    end
    'd576: begin
      top[0] = top_row[4607:4600];
      top[1] = top_row[4615:4608];
      top[2] = top_row[4623:4616];
      mid[0] = mid_row[4607:4600];
      mid[1] = mid_row[4615:4608];
      mid[2] = mid_row[4623:4616];
      btm[0] = btm_row[4607:4600];
      btm[1] = btm_row[4615:4608];
      btm[2] = btm_row[4623:4616];
    end
    'd577: begin
      top[0] = top_row[4615:4608];
      top[1] = top_row[4623:4616];
      top[2] = top_row[4631:4624];
      mid[0] = mid_row[4615:4608];
      mid[1] = mid_row[4623:4616];
      mid[2] = mid_row[4631:4624];
      btm[0] = btm_row[4615:4608];
      btm[1] = btm_row[4623:4616];
      btm[2] = btm_row[4631:4624];
    end
    'd578: begin
      top[0] = top_row[4623:4616];
      top[1] = top_row[4631:4624];
      top[2] = top_row[4639:4632];
      mid[0] = mid_row[4623:4616];
      mid[1] = mid_row[4631:4624];
      mid[2] = mid_row[4639:4632];
      btm[0] = btm_row[4623:4616];
      btm[1] = btm_row[4631:4624];
      btm[2] = btm_row[4639:4632];
    end
    'd579: begin
      top[0] = top_row[4631:4624];
      top[1] = top_row[4639:4632];
      top[2] = top_row[4647:4640];
      mid[0] = mid_row[4631:4624];
      mid[1] = mid_row[4639:4632];
      mid[2] = mid_row[4647:4640];
      btm[0] = btm_row[4631:4624];
      btm[1] = btm_row[4639:4632];
      btm[2] = btm_row[4647:4640];
    end
    'd580: begin
      top[0] = top_row[4639:4632];
      top[1] = top_row[4647:4640];
      top[2] = top_row[4655:4648];
      mid[0] = mid_row[4639:4632];
      mid[1] = mid_row[4647:4640];
      mid[2] = mid_row[4655:4648];
      btm[0] = btm_row[4639:4632];
      btm[1] = btm_row[4647:4640];
      btm[2] = btm_row[4655:4648];
    end
    'd581: begin
      top[0] = top_row[4647:4640];
      top[1] = top_row[4655:4648];
      top[2] = top_row[4663:4656];
      mid[0] = mid_row[4647:4640];
      mid[1] = mid_row[4655:4648];
      mid[2] = mid_row[4663:4656];
      btm[0] = btm_row[4647:4640];
      btm[1] = btm_row[4655:4648];
      btm[2] = btm_row[4663:4656];
    end
    'd582: begin
      top[0] = top_row[4655:4648];
      top[1] = top_row[4663:4656];
      top[2] = top_row[4671:4664];
      mid[0] = mid_row[4655:4648];
      mid[1] = mid_row[4663:4656];
      mid[2] = mid_row[4671:4664];
      btm[0] = btm_row[4655:4648];
      btm[1] = btm_row[4663:4656];
      btm[2] = btm_row[4671:4664];
    end
    'd583: begin
      top[0] = top_row[4663:4656];
      top[1] = top_row[4671:4664];
      top[2] = top_row[4679:4672];
      mid[0] = mid_row[4663:4656];
      mid[1] = mid_row[4671:4664];
      mid[2] = mid_row[4679:4672];
      btm[0] = btm_row[4663:4656];
      btm[1] = btm_row[4671:4664];
      btm[2] = btm_row[4679:4672];
    end
    'd584: begin
      top[0] = top_row[4671:4664];
      top[1] = top_row[4679:4672];
      top[2] = top_row[4687:4680];
      mid[0] = mid_row[4671:4664];
      mid[1] = mid_row[4679:4672];
      mid[2] = mid_row[4687:4680];
      btm[0] = btm_row[4671:4664];
      btm[1] = btm_row[4679:4672];
      btm[2] = btm_row[4687:4680];
    end
    'd585: begin
      top[0] = top_row[4679:4672];
      top[1] = top_row[4687:4680];
      top[2] = top_row[4695:4688];
      mid[0] = mid_row[4679:4672];
      mid[1] = mid_row[4687:4680];
      mid[2] = mid_row[4695:4688];
      btm[0] = btm_row[4679:4672];
      btm[1] = btm_row[4687:4680];
      btm[2] = btm_row[4695:4688];
    end
    'd586: begin
      top[0] = top_row[4687:4680];
      top[1] = top_row[4695:4688];
      top[2] = top_row[4703:4696];
      mid[0] = mid_row[4687:4680];
      mid[1] = mid_row[4695:4688];
      mid[2] = mid_row[4703:4696];
      btm[0] = btm_row[4687:4680];
      btm[1] = btm_row[4695:4688];
      btm[2] = btm_row[4703:4696];
    end
    'd587: begin
      top[0] = top_row[4695:4688];
      top[1] = top_row[4703:4696];
      top[2] = top_row[4711:4704];
      mid[0] = mid_row[4695:4688];
      mid[1] = mid_row[4703:4696];
      mid[2] = mid_row[4711:4704];
      btm[0] = btm_row[4695:4688];
      btm[1] = btm_row[4703:4696];
      btm[2] = btm_row[4711:4704];
    end
    'd588: begin
      top[0] = top_row[4703:4696];
      top[1] = top_row[4711:4704];
      top[2] = top_row[4719:4712];
      mid[0] = mid_row[4703:4696];
      mid[1] = mid_row[4711:4704];
      mid[2] = mid_row[4719:4712];
      btm[0] = btm_row[4703:4696];
      btm[1] = btm_row[4711:4704];
      btm[2] = btm_row[4719:4712];
    end
    'd589: begin
      top[0] = top_row[4711:4704];
      top[1] = top_row[4719:4712];
      top[2] = top_row[4727:4720];
      mid[0] = mid_row[4711:4704];
      mid[1] = mid_row[4719:4712];
      mid[2] = mid_row[4727:4720];
      btm[0] = btm_row[4711:4704];
      btm[1] = btm_row[4719:4712];
      btm[2] = btm_row[4727:4720];
    end
    'd590: begin
      top[0] = top_row[4719:4712];
      top[1] = top_row[4727:4720];
      top[2] = top_row[4735:4728];
      mid[0] = mid_row[4719:4712];
      mid[1] = mid_row[4727:4720];
      mid[2] = mid_row[4735:4728];
      btm[0] = btm_row[4719:4712];
      btm[1] = btm_row[4727:4720];
      btm[2] = btm_row[4735:4728];
    end
    'd591: begin
      top[0] = top_row[4727:4720];
      top[1] = top_row[4735:4728];
      top[2] = top_row[4743:4736];
      mid[0] = mid_row[4727:4720];
      mid[1] = mid_row[4735:4728];
      mid[2] = mid_row[4743:4736];
      btm[0] = btm_row[4727:4720];
      btm[1] = btm_row[4735:4728];
      btm[2] = btm_row[4743:4736];
    end
    'd592: begin
      top[0] = top_row[4735:4728];
      top[1] = top_row[4743:4736];
      top[2] = top_row[4751:4744];
      mid[0] = mid_row[4735:4728];
      mid[1] = mid_row[4743:4736];
      mid[2] = mid_row[4751:4744];
      btm[0] = btm_row[4735:4728];
      btm[1] = btm_row[4743:4736];
      btm[2] = btm_row[4751:4744];
    end
    'd593: begin
      top[0] = top_row[4743:4736];
      top[1] = top_row[4751:4744];
      top[2] = top_row[4759:4752];
      mid[0] = mid_row[4743:4736];
      mid[1] = mid_row[4751:4744];
      mid[2] = mid_row[4759:4752];
      btm[0] = btm_row[4743:4736];
      btm[1] = btm_row[4751:4744];
      btm[2] = btm_row[4759:4752];
    end
    'd594: begin
      top[0] = top_row[4751:4744];
      top[1] = top_row[4759:4752];
      top[2] = top_row[4767:4760];
      mid[0] = mid_row[4751:4744];
      mid[1] = mid_row[4759:4752];
      mid[2] = mid_row[4767:4760];
      btm[0] = btm_row[4751:4744];
      btm[1] = btm_row[4759:4752];
      btm[2] = btm_row[4767:4760];
    end
    'd595: begin
      top[0] = top_row[4759:4752];
      top[1] = top_row[4767:4760];
      top[2] = top_row[4775:4768];
      mid[0] = mid_row[4759:4752];
      mid[1] = mid_row[4767:4760];
      mid[2] = mid_row[4775:4768];
      btm[0] = btm_row[4759:4752];
      btm[1] = btm_row[4767:4760];
      btm[2] = btm_row[4775:4768];
    end
    'd596: begin
      top[0] = top_row[4767:4760];
      top[1] = top_row[4775:4768];
      top[2] = top_row[4783:4776];
      mid[0] = mid_row[4767:4760];
      mid[1] = mid_row[4775:4768];
      mid[2] = mid_row[4783:4776];
      btm[0] = btm_row[4767:4760];
      btm[1] = btm_row[4775:4768];
      btm[2] = btm_row[4783:4776];
    end
    'd597: begin
      top[0] = top_row[4775:4768];
      top[1] = top_row[4783:4776];
      top[2] = top_row[4791:4784];
      mid[0] = mid_row[4775:4768];
      mid[1] = mid_row[4783:4776];
      mid[2] = mid_row[4791:4784];
      btm[0] = btm_row[4775:4768];
      btm[1] = btm_row[4783:4776];
      btm[2] = btm_row[4791:4784];
    end
    'd598: begin
      top[0] = top_row[4783:4776];
      top[1] = top_row[4791:4784];
      top[2] = top_row[4799:4792];
      mid[0] = mid_row[4783:4776];
      mid[1] = mid_row[4791:4784];
      mid[2] = mid_row[4799:4792];
      btm[0] = btm_row[4783:4776];
      btm[1] = btm_row[4791:4784];
      btm[2] = btm_row[4799:4792];
    end
    'd599: begin
      top[0] = top_row[4791:4784];
      top[1] = top_row[4799:4792];
      top[2] = top_row[4807:4800];
      mid[0] = mid_row[4791:4784];
      mid[1] = mid_row[4799:4792];
      mid[2] = mid_row[4807:4800];
      btm[0] = btm_row[4791:4784];
      btm[1] = btm_row[4799:4792];
      btm[2] = btm_row[4807:4800];
    end
    'd600: begin
      top[0] = top_row[4799:4792];
      top[1] = top_row[4807:4800];
      top[2] = top_row[4815:4808];
      mid[0] = mid_row[4799:4792];
      mid[1] = mid_row[4807:4800];
      mid[2] = mid_row[4815:4808];
      btm[0] = btm_row[4799:4792];
      btm[1] = btm_row[4807:4800];
      btm[2] = btm_row[4815:4808];
    end
    'd601: begin
      top[0] = top_row[4807:4800];
      top[1] = top_row[4815:4808];
      top[2] = top_row[4823:4816];
      mid[0] = mid_row[4807:4800];
      mid[1] = mid_row[4815:4808];
      mid[2] = mid_row[4823:4816];
      btm[0] = btm_row[4807:4800];
      btm[1] = btm_row[4815:4808];
      btm[2] = btm_row[4823:4816];
    end
    'd602: begin
      top[0] = top_row[4815:4808];
      top[1] = top_row[4823:4816];
      top[2] = top_row[4831:4824];
      mid[0] = mid_row[4815:4808];
      mid[1] = mid_row[4823:4816];
      mid[2] = mid_row[4831:4824];
      btm[0] = btm_row[4815:4808];
      btm[1] = btm_row[4823:4816];
      btm[2] = btm_row[4831:4824];
    end
    'd603: begin
      top[0] = top_row[4823:4816];
      top[1] = top_row[4831:4824];
      top[2] = top_row[4839:4832];
      mid[0] = mid_row[4823:4816];
      mid[1] = mid_row[4831:4824];
      mid[2] = mid_row[4839:4832];
      btm[0] = btm_row[4823:4816];
      btm[1] = btm_row[4831:4824];
      btm[2] = btm_row[4839:4832];
    end
    'd604: begin
      top[0] = top_row[4831:4824];
      top[1] = top_row[4839:4832];
      top[2] = top_row[4847:4840];
      mid[0] = mid_row[4831:4824];
      mid[1] = mid_row[4839:4832];
      mid[2] = mid_row[4847:4840];
      btm[0] = btm_row[4831:4824];
      btm[1] = btm_row[4839:4832];
      btm[2] = btm_row[4847:4840];
    end
    'd605: begin
      top[0] = top_row[4839:4832];
      top[1] = top_row[4847:4840];
      top[2] = top_row[4855:4848];
      mid[0] = mid_row[4839:4832];
      mid[1] = mid_row[4847:4840];
      mid[2] = mid_row[4855:4848];
      btm[0] = btm_row[4839:4832];
      btm[1] = btm_row[4847:4840];
      btm[2] = btm_row[4855:4848];
    end
    'd606: begin
      top[0] = top_row[4847:4840];
      top[1] = top_row[4855:4848];
      top[2] = top_row[4863:4856];
      mid[0] = mid_row[4847:4840];
      mid[1] = mid_row[4855:4848];
      mid[2] = mid_row[4863:4856];
      btm[0] = btm_row[4847:4840];
      btm[1] = btm_row[4855:4848];
      btm[2] = btm_row[4863:4856];
    end
    'd607: begin
      top[0] = top_row[4855:4848];
      top[1] = top_row[4863:4856];
      top[2] = top_row[4871:4864];
      mid[0] = mid_row[4855:4848];
      mid[1] = mid_row[4863:4856];
      mid[2] = mid_row[4871:4864];
      btm[0] = btm_row[4855:4848];
      btm[1] = btm_row[4863:4856];
      btm[2] = btm_row[4871:4864];
    end
    'd608: begin
      top[0] = top_row[4863:4856];
      top[1] = top_row[4871:4864];
      top[2] = top_row[4879:4872];
      mid[0] = mid_row[4863:4856];
      mid[1] = mid_row[4871:4864];
      mid[2] = mid_row[4879:4872];
      btm[0] = btm_row[4863:4856];
      btm[1] = btm_row[4871:4864];
      btm[2] = btm_row[4879:4872];
    end
    'd609: begin
      top[0] = top_row[4871:4864];
      top[1] = top_row[4879:4872];
      top[2] = top_row[4887:4880];
      mid[0] = mid_row[4871:4864];
      mid[1] = mid_row[4879:4872];
      mid[2] = mid_row[4887:4880];
      btm[0] = btm_row[4871:4864];
      btm[1] = btm_row[4879:4872];
      btm[2] = btm_row[4887:4880];
    end
    'd610: begin
      top[0] = top_row[4879:4872];
      top[1] = top_row[4887:4880];
      top[2] = top_row[4895:4888];
      mid[0] = mid_row[4879:4872];
      mid[1] = mid_row[4887:4880];
      mid[2] = mid_row[4895:4888];
      btm[0] = btm_row[4879:4872];
      btm[1] = btm_row[4887:4880];
      btm[2] = btm_row[4895:4888];
    end
    'd611: begin
      top[0] = top_row[4887:4880];
      top[1] = top_row[4895:4888];
      top[2] = top_row[4903:4896];
      mid[0] = mid_row[4887:4880];
      mid[1] = mid_row[4895:4888];
      mid[2] = mid_row[4903:4896];
      btm[0] = btm_row[4887:4880];
      btm[1] = btm_row[4895:4888];
      btm[2] = btm_row[4903:4896];
    end
    'd612: begin
      top[0] = top_row[4895:4888];
      top[1] = top_row[4903:4896];
      top[2] = top_row[4911:4904];
      mid[0] = mid_row[4895:4888];
      mid[1] = mid_row[4903:4896];
      mid[2] = mid_row[4911:4904];
      btm[0] = btm_row[4895:4888];
      btm[1] = btm_row[4903:4896];
      btm[2] = btm_row[4911:4904];
    end
    'd613: begin
      top[0] = top_row[4903:4896];
      top[1] = top_row[4911:4904];
      top[2] = top_row[4919:4912];
      mid[0] = mid_row[4903:4896];
      mid[1] = mid_row[4911:4904];
      mid[2] = mid_row[4919:4912];
      btm[0] = btm_row[4903:4896];
      btm[1] = btm_row[4911:4904];
      btm[2] = btm_row[4919:4912];
    end
    'd614: begin
      top[0] = top_row[4911:4904];
      top[1] = top_row[4919:4912];
      top[2] = top_row[4927:4920];
      mid[0] = mid_row[4911:4904];
      mid[1] = mid_row[4919:4912];
      mid[2] = mid_row[4927:4920];
      btm[0] = btm_row[4911:4904];
      btm[1] = btm_row[4919:4912];
      btm[2] = btm_row[4927:4920];
    end
    'd615: begin
      top[0] = top_row[4919:4912];
      top[1] = top_row[4927:4920];
      top[2] = top_row[4935:4928];
      mid[0] = mid_row[4919:4912];
      mid[1] = mid_row[4927:4920];
      mid[2] = mid_row[4935:4928];
      btm[0] = btm_row[4919:4912];
      btm[1] = btm_row[4927:4920];
      btm[2] = btm_row[4935:4928];
    end
    'd616: begin
      top[0] = top_row[4927:4920];
      top[1] = top_row[4935:4928];
      top[2] = top_row[4943:4936];
      mid[0] = mid_row[4927:4920];
      mid[1] = mid_row[4935:4928];
      mid[2] = mid_row[4943:4936];
      btm[0] = btm_row[4927:4920];
      btm[1] = btm_row[4935:4928];
      btm[2] = btm_row[4943:4936];
    end
    'd617: begin
      top[0] = top_row[4935:4928];
      top[1] = top_row[4943:4936];
      top[2] = top_row[4951:4944];
      mid[0] = mid_row[4935:4928];
      mid[1] = mid_row[4943:4936];
      mid[2] = mid_row[4951:4944];
      btm[0] = btm_row[4935:4928];
      btm[1] = btm_row[4943:4936];
      btm[2] = btm_row[4951:4944];
    end
    'd618: begin
      top[0] = top_row[4943:4936];
      top[1] = top_row[4951:4944];
      top[2] = top_row[4959:4952];
      mid[0] = mid_row[4943:4936];
      mid[1] = mid_row[4951:4944];
      mid[2] = mid_row[4959:4952];
      btm[0] = btm_row[4943:4936];
      btm[1] = btm_row[4951:4944];
      btm[2] = btm_row[4959:4952];
    end
    'd619: begin
      top[0] = top_row[4951:4944];
      top[1] = top_row[4959:4952];
      top[2] = top_row[4967:4960];
      mid[0] = mid_row[4951:4944];
      mid[1] = mid_row[4959:4952];
      mid[2] = mid_row[4967:4960];
      btm[0] = btm_row[4951:4944];
      btm[1] = btm_row[4959:4952];
      btm[2] = btm_row[4967:4960];
    end
    'd620: begin
      top[0] = top_row[4959:4952];
      top[1] = top_row[4967:4960];
      top[2] = top_row[4975:4968];
      mid[0] = mid_row[4959:4952];
      mid[1] = mid_row[4967:4960];
      mid[2] = mid_row[4975:4968];
      btm[0] = btm_row[4959:4952];
      btm[1] = btm_row[4967:4960];
      btm[2] = btm_row[4975:4968];
    end
    'd621: begin
      top[0] = top_row[4967:4960];
      top[1] = top_row[4975:4968];
      top[2] = top_row[4983:4976];
      mid[0] = mid_row[4967:4960];
      mid[1] = mid_row[4975:4968];
      mid[2] = mid_row[4983:4976];
      btm[0] = btm_row[4967:4960];
      btm[1] = btm_row[4975:4968];
      btm[2] = btm_row[4983:4976];
    end
    'd622: begin
      top[0] = top_row[4975:4968];
      top[1] = top_row[4983:4976];
      top[2] = top_row[4991:4984];
      mid[0] = mid_row[4975:4968];
      mid[1] = mid_row[4983:4976];
      mid[2] = mid_row[4991:4984];
      btm[0] = btm_row[4975:4968];
      btm[1] = btm_row[4983:4976];
      btm[2] = btm_row[4991:4984];
    end
    'd623: begin
      top[0] = top_row[4983:4976];
      top[1] = top_row[4991:4984];
      top[2] = top_row[4999:4992];
      mid[0] = mid_row[4983:4976];
      mid[1] = mid_row[4991:4984];
      mid[2] = mid_row[4999:4992];
      btm[0] = btm_row[4983:4976];
      btm[1] = btm_row[4991:4984];
      btm[2] = btm_row[4999:4992];
    end
    'd624: begin
      top[0] = top_row[4991:4984];
      top[1] = top_row[4999:4992];
      top[2] = top_row[5007:5000];
      mid[0] = mid_row[4991:4984];
      mid[1] = mid_row[4999:4992];
      mid[2] = mid_row[5007:5000];
      btm[0] = btm_row[4991:4984];
      btm[1] = btm_row[4999:4992];
      btm[2] = btm_row[5007:5000];
    end
    'd625: begin
      top[0] = top_row[4999:4992];
      top[1] = top_row[5007:5000];
      top[2] = top_row[5015:5008];
      mid[0] = mid_row[4999:4992];
      mid[1] = mid_row[5007:5000];
      mid[2] = mid_row[5015:5008];
      btm[0] = btm_row[4999:4992];
      btm[1] = btm_row[5007:5000];
      btm[2] = btm_row[5015:5008];
    end
    'd626: begin
      top[0] = top_row[5007:5000];
      top[1] = top_row[5015:5008];
      top[2] = top_row[5023:5016];
      mid[0] = mid_row[5007:5000];
      mid[1] = mid_row[5015:5008];
      mid[2] = mid_row[5023:5016];
      btm[0] = btm_row[5007:5000];
      btm[1] = btm_row[5015:5008];
      btm[2] = btm_row[5023:5016];
    end
    'd627: begin
      top[0] = top_row[5015:5008];
      top[1] = top_row[5023:5016];
      top[2] = top_row[5031:5024];
      mid[0] = mid_row[5015:5008];
      mid[1] = mid_row[5023:5016];
      mid[2] = mid_row[5031:5024];
      btm[0] = btm_row[5015:5008];
      btm[1] = btm_row[5023:5016];
      btm[2] = btm_row[5031:5024];
    end
    'd628: begin
      top[0] = top_row[5023:5016];
      top[1] = top_row[5031:5024];
      top[2] = top_row[5039:5032];
      mid[0] = mid_row[5023:5016];
      mid[1] = mid_row[5031:5024];
      mid[2] = mid_row[5039:5032];
      btm[0] = btm_row[5023:5016];
      btm[1] = btm_row[5031:5024];
      btm[2] = btm_row[5039:5032];
    end
    'd629: begin
      top[0] = top_row[5031:5024];
      top[1] = top_row[5039:5032];
      top[2] = top_row[5047:5040];
      mid[0] = mid_row[5031:5024];
      mid[1] = mid_row[5039:5032];
      mid[2] = mid_row[5047:5040];
      btm[0] = btm_row[5031:5024];
      btm[1] = btm_row[5039:5032];
      btm[2] = btm_row[5047:5040];
    end
    'd630: begin
      top[0] = top_row[5039:5032];
      top[1] = top_row[5047:5040];
      top[2] = top_row[5055:5048];
      mid[0] = mid_row[5039:5032];
      mid[1] = mid_row[5047:5040];
      mid[2] = mid_row[5055:5048];
      btm[0] = btm_row[5039:5032];
      btm[1] = btm_row[5047:5040];
      btm[2] = btm_row[5055:5048];
    end
    'd631: begin
      top[0] = top_row[5047:5040];
      top[1] = top_row[5055:5048];
      top[2] = top_row[5063:5056];
      mid[0] = mid_row[5047:5040];
      mid[1] = mid_row[5055:5048];
      mid[2] = mid_row[5063:5056];
      btm[0] = btm_row[5047:5040];
      btm[1] = btm_row[5055:5048];
      btm[2] = btm_row[5063:5056];
    end
    'd632: begin
      top[0] = top_row[5055:5048];
      top[1] = top_row[5063:5056];
      top[2] = top_row[5071:5064];
      mid[0] = mid_row[5055:5048];
      mid[1] = mid_row[5063:5056];
      mid[2] = mid_row[5071:5064];
      btm[0] = btm_row[5055:5048];
      btm[1] = btm_row[5063:5056];
      btm[2] = btm_row[5071:5064];
    end
    'd633: begin
      top[0] = top_row[5063:5056];
      top[1] = top_row[5071:5064];
      top[2] = top_row[5079:5072];
      mid[0] = mid_row[5063:5056];
      mid[1] = mid_row[5071:5064];
      mid[2] = mid_row[5079:5072];
      btm[0] = btm_row[5063:5056];
      btm[1] = btm_row[5071:5064];
      btm[2] = btm_row[5079:5072];
    end
    'd634: begin
      top[0] = top_row[5071:5064];
      top[1] = top_row[5079:5072];
      top[2] = top_row[5087:5080];
      mid[0] = mid_row[5071:5064];
      mid[1] = mid_row[5079:5072];
      mid[2] = mid_row[5087:5080];
      btm[0] = btm_row[5071:5064];
      btm[1] = btm_row[5079:5072];
      btm[2] = btm_row[5087:5080];
    end
    'd635: begin
      top[0] = top_row[5079:5072];
      top[1] = top_row[5087:5080];
      top[2] = top_row[5095:5088];
      mid[0] = mid_row[5079:5072];
      mid[1] = mid_row[5087:5080];
      mid[2] = mid_row[5095:5088];
      btm[0] = btm_row[5079:5072];
      btm[1] = btm_row[5087:5080];
      btm[2] = btm_row[5095:5088];
    end
    'd636: begin
      top[0] = top_row[5087:5080];
      top[1] = top_row[5095:5088];
      top[2] = top_row[5103:5096];
      mid[0] = mid_row[5087:5080];
      mid[1] = mid_row[5095:5088];
      mid[2] = mid_row[5103:5096];
      btm[0] = btm_row[5087:5080];
      btm[1] = btm_row[5095:5088];
      btm[2] = btm_row[5103:5096];
    end
    'd637: begin
      top[0] = top_row[5095:5088];
      top[1] = top_row[5103:5096];
      top[2] = top_row[5111:5104];
      mid[0] = mid_row[5095:5088];
      mid[1] = mid_row[5103:5096];
      mid[2] = mid_row[5111:5104];
      btm[0] = btm_row[5095:5088];
      btm[1] = btm_row[5103:5096];
      btm[2] = btm_row[5111:5104];
    end
    'd638: begin
      top[0] = top_row[5103:5096];
      top[1] = top_row[5111:5104];
      top[2] = top_row[5119:5112];
      mid[0] = mid_row[5103:5096];
      mid[1] = mid_row[5111:5104];
      mid[2] = mid_row[5119:5112];
      btm[0] = btm_row[5103:5096];
      btm[1] = btm_row[5111:5104];
      btm[2] = btm_row[5119:5112];
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