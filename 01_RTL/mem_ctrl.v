`timescale 1ns/10ps
module mem_ctrl(
  clk,
  rst_n,
  state,
  addr,
  img_valid,
  buffer_req
);


/*SYSTEM*/
input                 clk,
                      rst_n;
input         [2:0]   state;

/*SRAM Control*/
output reg      [8:0] addr;
output reg            img_valid;
input                 buffer_req;

parameter       ST_IDLE       = 0,
                ST_GAUSSIAN   = 1,
                ST_DETECT_KP  = 2,
                ST_FILTER_KP  = 3,
                ST_MATCH      = 4,
                ST_END        = 5; //FOR DEBUG


always @(posedge clk) begin
  if (!rst_n) 
    addr <= 'd0;    
  else if (state==ST_GAUSSIAN && addr<'d480 && buffer_req)
    addr <= addr + 'd1;
  else if (state==ST_END || state==ST_IDLE)
    addr <= 'd0;
end


always @(posedge clk) begin
  if (!rst_n) 
    img_valid <= 'b0;    
  else if (state==ST_GAUSSIAN && addr<'d480 && buffer_req)
    img_valid <= 'b1;
  else if (state==ST_END || state==ST_IDLE || addr=='d480)
    img_valid <= 'd0;
end

endmodule 