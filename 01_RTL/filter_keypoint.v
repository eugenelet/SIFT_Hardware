module filter_keypoint(
  filter_input,
  valid_keypoint
);

input  [23:0]    filter_input[0:2],

output          valid_keypoint;

wire  [23:0]    top = filter_input[0],
                mid = filter_input[1],
                btm = filter_input[2];

wire  [7:0] brighter;
wire  [7:0] darker;

assign brighter[0] = (top[7:0]   > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[1] = (top[15:8]  > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[2] = (top[23:16] > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[3] = (mid[23:16] > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[4] = (btm[23:16] > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[5] = (btm[15:8]  > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[6] = (btm[7:0]   > (mid[15:8] + 'd7)) ? 1 : 0;
assign brighter[7] = (mid[7:0]   > (mid[15:8] + 'd7)) ? 1 : 0;

assign darker[0] = (top[7:0]   < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[1] = (top[15:8]  < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[2] = (top[23:16] < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[3] = (mid[23:16] < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[4] = (btm[23:16] < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[5] = (btm[15:8]  < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[6] = (btm[7:0]   < (mid[15:8] - 'd7)) ? 1 : 0;
assign darker[7] = (mid[7:0]   < (mid[15:8] - 'd7)) ? 1 : 0;

wire  brighter_valid;
always @(*) begin
  if(&brighter[3:0])
    brighter_valid = 1;
  else if(&brighter[4:1])
    brighter_valid = 1;
  else if(&brighter[5:2])
    brighter_valid = 1;
  else if(&brighter[6:3])
    brighter_valid = 1;
  else if(&brighter[7:4])
    brighter_valid = 1;
  else if(&{brighter[7:5], brighter[0]})
    brighter_valid = 1;
  else if(&{brighter[7:6], brighter[1:0]})
    brighter_valid = 1;
  else if(&{brighter[7], brighter[2:0]})
    brighter_valid = 1;
  else
    brighter_valid = 0;
end

wire  darker_valid;
always @(*) begin
  if(&darker[3:0])
    darker_valid = 1;
  else if(&darker[4:1])
    darker_valid = 1;
  else if(&darker[5:2])
    darker_valid = 1;
  else if(&darker[6:3])
    darker_valid = 1;
  else if(&darker[7:4])
    darker_valid = 1;
  else if(&{darker[7:5], darker[0]})
    darker_valid = 1;
  else if(&{darker[7:6], darker[1:0]})
    darker_valid = 1;
  else if(&{darker[7], darker[2:0]})
    darker_valid = 1;
  else
    darker_valid = 0;
end

assign valid_keypoint = brighter_valid | darker_valid;

endmodule