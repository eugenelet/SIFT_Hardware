module bmem_512x49(//dual port
    input               clk,
    input               we,
    input       [8:0]   addr1,
    input       [8:0]   addr2,//
    input       [48:0]  din,
    output  reg [48:0]  dout1,
    output  reg [48:0]  dout2
);
    reg [48:0]  mem[0:511];//row, col, dist, dist2(9 + 10 + 14 + 14 = 47)

    always @(posedge clk) begin
        dout1 <= mem[addr1];
    end
    
    always @(posedge clk) begin
        dout2 <= mem[addr2];
    end
    
    always @(posedge clk) begin
        if(we)
            mem[addr1] <= din;
    end

endmodule
