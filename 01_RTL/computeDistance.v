module computeDistance(//combinational,should have m * n copies
    clk,
    rst_n,
    A,//each dim is an integer(12 bit)
    B,
    distance
);

    input               clk;
    input               rst_n;
    input       [383:0] A;//(12 bit) * (32 dim)
    input       [383:0] B;
    output      [14:0]  distance;
    
    //////////////////////////////
    
    reg     [14:0]  itmdaResult1, itmdaResult2;
    
    //////////////////////////////
    
    wire[11:0]  dim01; wire[11:0]  dim02; wire[11:0]  dim03; wire[11:0]  dim04;
    wire[11:0]  dim05; wire[11:0]  dim06; wire[11:0]  dim07; wire[11:0]  dim08;
    wire[11:0]  dim09; wire[11:0]  dim10; wire[11:0]  dim11; wire[11:0]  dim12;
    wire[11:0]  dim13; wire[11:0]  dim14; wire[11:0]  dim15; wire[11:0]  dim16;
    wire[11:0]  dim17; wire[11:0]  dim18; wire[11:0]  dim19; wire[11:0]  dim20;
    wire[11:0]  dim21; wire[11:0]  dim22; wire[11:0]  dim23; wire[11:0]  dim24;
    wire[11:0]  dim25; wire[11:0]  dim26; wire[11:0]  dim27; wire[11:0]  dim28;
    wire[11:0]  dim29; wire[11:0]  dim30; wire[11:0]  dim31; wire[11:0]  dim32;
    
    //////////////////////////////
    
    assign dim01 = (A[11:0] > B[11:0])? A[11:0] - B[11:0] : B[11:0] - A[11:0];
    assign dim02 = (A[23:12] > B[23:12])? A[23:12] - B[23:12] : B[23:12] - A[23:12];
    assign dim03 = (A[35:24] > B[35:24])? A[35:24] - B[35:24] : B[35:24] - A[35:24];
    assign dim04 = (A[47:36] > B[47:36])? A[47:36] - B[47:36] : B[47:36] - A[47:36];
    assign dim05 = (A[59:48] > B[59:48])? A[59:48] - B[59:48] : B[59:48] - A[59:48];
    assign dim06 = (A[71:60] > B[71:60])? A[71:60] - B[71:60] : B[71:60] - A[71:60];
    assign dim07 = (A[83:72] > B[83:72])? A[83:72] - B[83:72] : B[83:72] - A[83:72];
    assign dim08 = (A[95:84] > B[95:84])? A[95:84] - B[95:84] : B[95:84] - A[95:84];
    assign dim09 = (A[107:96] > B[107:96])? A[107:96] - B[107:96] : B[107:96] - A[107:96];
    assign dim10 = (A[119:108] > B[119:108])? A[119:108] - B[119:108] : B[119:108] - A[119:108];
    assign dim11 = (A[131:120] > B[131:120])? A[131:120] - B[131:120] : B[131:120] - A[131:120];
    assign dim12 = (A[143:132] > B[143:132])? A[143:132] - B[143:132] : B[143:132] - A[143:132];
    assign dim13 = (A[155:144] > B[155:144])? A[155:144] - B[155:144] : B[155:144] - A[155:144];
    assign dim14 = (A[167:156] > B[167:156])? A[167:156] - B[167:156] : B[167:156] - A[167:156];
    assign dim15 = (A[179:168] > B[179:168])? A[179:168] - B[179:168] : B[179:168] - A[179:168];
    assign dim16 = (A[191:180] > B[191:180])? A[191:180] - B[191:180] : B[191:180] - A[191:180];
    assign dim17 = (A[203:192] > B[203:192])? A[203:192] - B[203:192] : B[203:192] - A[203:192];
    assign dim18 = (A[215:204] > B[215:204])? A[215:204] - B[215:204] : B[215:204] - A[215:204];
    assign dim19 = (A[227:216] > B[227:216])? A[227:216] - B[227:216] : B[227:216] - A[227:216];
    assign dim20 = (A[239:228] > B[239:228])? A[239:228] - B[239:228] : B[239:228] - A[239:228];
    assign dim21 = (A[251:240] > B[251:240])? A[251:240] - B[251:240] : B[251:240] - A[251:240];
    assign dim22 = (A[263:252] > B[263:252])? A[263:252] - B[263:252] : B[263:252] - A[263:252];
    assign dim23 = (A[275:264] > B[275:264])? A[275:264] - B[275:264] : B[275:264] - A[275:264];
    assign dim24 = (A[287:276] > B[287:276])? A[287:276] - B[287:276] : B[287:276] - A[287:276];
    assign dim25 = (A[299:288] > B[299:288])? A[299:288] - B[299:288] : B[299:288] - A[299:288];
    assign dim26 = (A[311:300] > B[311:300])? A[311:300] - B[311:300] : B[311:300] - A[311:300];
    assign dim27 = (A[323:312] > B[323:312])? A[323:312] - B[323:312] : B[323:312] - A[323:312];
    assign dim28 = (A[335:324] > B[335:324])? A[335:324] - B[335:324] : B[335:324] - A[335:324];
    assign dim29 = (A[347:336] > B[347:336])? A[347:336] - B[347:336] : B[347:336] - A[347:336];
    assign dim30 = (A[359:348] > B[359:348])? A[359:348] - B[359:348] : B[359:348] - A[359:348];
    assign dim31 = (A[371:360] > B[371:360])? A[371:360] - B[371:360] : B[371:360] - A[371:360];
    assign dim32 = (A[383:372] > B[383:372])? A[383:372] - B[383:372] : B[383:372] - A[383:372];
    
    //assign distance = dim01 + dim02 + dim03 + dim04 + dim05 +
    //                  dim06 + dim07 + dim08 + dim09 + dim10 +
    //                  dim11 + dim12 + dim13 + dim14 + dim15 +
    //                  dim16 + dim17 + dim18 + dim19 + dim20 +
    //                  dim21 + dim22 + dim23 + dim24 + dim25 +
    //                  dim26 + dim27 + dim28 + dim29 + dim30 +
    //                  dim31 + dim32;
    
    assign distance = itmdaResult1 + itmdaResult2;
    
    //////////////////////////////
    
    always @(posedge clk) begin //itmdaResult1
    
        if(!rst_n)
            itmdaResult1 <= 'd0;
        else
            itmdaResult1 <= dim01 + dim02 + dim03 + dim04 + dim05 +
                            dim06 + dim07 + dim08 + dim09 + dim10 +
                            dim11 + dim12 + dim13 + dim14 + dim15 +
                            dim16;
    
    end
    
    always @(posedge clk) begin //itmdaResult2
    
        if(!rst_n)
            itmdaResult2 <= 'd0;
        else
            itmdaResult2 <= dim17 + dim18 + dim19 + dim20 +
                            dim21 + dim22 + dim23 + dim24 + dim25 +
                            dim26 + dim27 + dim28 + dim29 + dim30 +
                            dim31 + dim32;
    
    end
    
                      
endmodule