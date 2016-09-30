module accumulateOrientation( //combinational
    LB_0,//newest
    LB_1,
    LB_2,
    row,//kpt's row
    col,//kpt's col
    row_accu_result1,
    row_accu_result2
);

    input       [8:0]   row;
    input       [9:0]   col;
    
    input       [5119:0]LB_0,
                        LB_1,
                        LB_2;
                        
    output      [95:0]  row_accu_result1,
                        row_accu_result2;
                        
    //////////////////////////////
    
    //wire                not_garbageRow;//contain garbageRow，output of this cycle = 0 (row's valid)
    
    //wire                p1_valid,//pixel 1 valid or not(col's的valid)
    //                    p2_valid, 
    //                    p3_valid,
    //                    p5_valid,
    //                    p6_valid,
    //                    p7_valid;
        
    reg         [95:0]  pixel_1, pixel_2, pixel_3, pixel_4, pixel_5, pixel_6, pixel_7, pixel_8,
                        pixel_9, pixel_10, pixel_11, pixel_12, pixel_13, pixel_14, pixel_15;
    
    //wire        [95:0]  modified_pixel_1,
    //                    modified_pixel_2,
    //                    modified_pixel_3,
    //                    modified_pixel_4,
    //                    modified_pixel_5,
    //                    modified_pixel_6,
    //                    modified_pixel_7;
                        
    reg         [135:0] LB_0_Wanted,//newest[col大~col小] (17 x 8 = 136)
                        LB_1_Wanted,
                        LB_2_Wanted;
                    
    wire        [8:0]   pixel_1_temp1, pixel_1_temp2,
                        pixel_2_temp1, pixel_2_temp2,
                        pixel_3_temp1, pixel_3_temp2,
                        pixel_4_temp1, pixel_4_temp2,
                        pixel_5_temp1, pixel_5_temp2,
                        pixel_6_temp1, pixel_6_temp2,
                        pixel_7_temp1, pixel_7_temp2,
                        pixel_8_temp1, pixel_8_temp2,
                        pixel_9_temp1, pixel_9_temp2,
                        pixel_10_temp1, pixel_10_temp2,
                        pixel_11_temp1, pixel_11_temp2,
                        pixel_12_temp1, pixel_12_temp2,
                        pixel_13_temp1, pixel_13_temp2,
                        pixel_14_temp1, pixel_14_temp2,
                        pixel_15_temp1, pixel_15_temp2;
                        
    wire        [8:0]   abs_pixel_1_temp1, abs_pixel_1_temp2,
                        abs_pixel_2_temp1, abs_pixel_2_temp2,
                        abs_pixel_3_temp1, abs_pixel_3_temp2,
                        abs_pixel_4_temp1, abs_pixel_4_temp2,
                        abs_pixel_5_temp1, abs_pixel_5_temp2,
                        abs_pixel_6_temp1, abs_pixel_6_temp2,
                        abs_pixel_7_temp1, abs_pixel_7_temp2,
                        abs_pixel_8_temp1, abs_pixel_8_temp2,
                        abs_pixel_9_temp1, abs_pixel_9_temp2,
                        abs_pixel_10_temp1, abs_pixel_10_temp2,
                        abs_pixel_11_temp1, abs_pixel_11_temp2,
                        abs_pixel_12_temp1, abs_pixel_12_temp2,
                        abs_pixel_13_temp1, abs_pixel_13_temp2,
                        abs_pixel_14_temp1, abs_pixel_14_temp2,
                        abs_pixel_15_temp1, abs_pixel_15_temp2;
                        
    wire        [9:0]   p1_mag, p2_mag, p3_mag, p4_mag, p5_mag, p6_mag, p7_mag, p8_mag,
                        p9_mag, p10_mag, p11_mag, p12_mag, p13_mag, p14_mag, p15_mag;
                        
    reg         [2:0]   p1_bin, p2_bin, p3_bin, p4_bin, p5_bin, p6_bin, p7_bin, p8_bin,
                        p9_bin, p10_bin, p11_bin, p12_bin, p13_bin, p14_bin, p15_bin;
    
    //////////////////////////////
    
    //assign not_garbageRow       = (row + cycle_count - 3'b101)>='d0 && (row + cycle_count - 3'b101)<='d639 &&
    //                              (row + cycle_count - 3'b110)>='d0 && (row + cycle_count - 3'b110)<='d639 &&
    //                              (row + cycle_count - 3'b111)>='d0 && (row + cycle_count - 3'b111)<='d639;
    //    
    //assign p1_valid             = col-2'b11>='d1 && col-2'b11<='d638;//p1, p2, p3 is on the left of kpt
    //assign p2_valid             = col-2'b10>='d1 && col-2'b10<='d638;
    //assign p3_valid             = col-2'b01>='d1 && col-2'b01<='d638;
    //assign p5_valid             = col+2'b01 <= 'd638;//p5, p6, p7 is on the right of kpt
    //assign p6_valid             = col+2'b10 <= 'd638;
    //assign p7_valid             = col+2'b11 <= 'd638;
    //    
    //assign modified_pixel_1     = (p1_valid)? pixel_1 : 'd0;
    //assign modified_pixel_2     = (p2_valid)? pixel_2 : 'd0;
    //assign modified_pixel_3     = (p3_valid)? pixel_3 : 'd0;
    //assign modified_pixel_4     = pixel_4;
    //assign modified_pixel_5     = (p5_valid)? pixel_5 : 'd0;
    //assign modified_pixel_6     = (p6_valid)? pixel_6 : 'd0;
    //assign modified_pixel_7     = (p7_valid)? pixel_7 : 'd0;
        
    assign pixel_1_temp1        = LB_1_Wanted[23:16] - LB_1_Wanted[7:0];//pixel(col+1) - pixel(col-1)
    assign pixel_2_temp1        = LB_1_Wanted[31:24] - LB_1_Wanted[15:8];
    assign pixel_3_temp1        = LB_1_Wanted[39:32] - LB_1_Wanted[23:16];
    assign pixel_4_temp1        = LB_1_Wanted[47:40] - LB_1_Wanted[31:24];
    assign pixel_5_temp1        = LB_1_Wanted[55:48] - LB_1_Wanted[39:32];
    assign pixel_6_temp1        = LB_1_Wanted[63:56] - LB_1_Wanted[47:40];
    assign pixel_7_temp1        = LB_1_Wanted[71:64] - LB_1_Wanted[55:48];
    assign pixel_8_temp1        = LB_1_Wanted[79:72] - LB_1_Wanted[63:56];
    assign pixel_9_temp1        = LB_1_Wanted[87:80] - LB_1_Wanted[71:64];
    assign pixel_10_temp1       = LB_1_Wanted[95:88] - LB_1_Wanted[79:72];
    assign pixel_11_temp1       = LB_1_Wanted[103:96] - LB_1_Wanted[87:80];
    assign pixel_12_temp1       = LB_1_Wanted[111:104] - LB_1_Wanted[95:88];
    assign pixel_13_temp1       = LB_1_Wanted[119:112] - LB_1_Wanted[103:96];
    assign pixel_14_temp1       = LB_1_Wanted[127:120] - LB_1_Wanted[111:104];
    assign pixel_15_temp1       = LB_1_Wanted[135:128] - LB_1_Wanted[119:112];
        
    assign pixel_1_temp2        = LB_0_Wanted[15:8] - LB_2_Wanted[15:8];//pixel(row+1) - pixel(row-1)
    assign pixel_2_temp2        = LB_0_Wanted[23:16] - LB_2_Wanted[23:16];
    assign pixel_3_temp2        = LB_0_Wanted[31:24] - LB_2_Wanted[31:24];
    assign pixel_4_temp2        = LB_0_Wanted[39:32] - LB_2_Wanted[39:32];
    assign pixel_5_temp2        = LB_0_Wanted[47:40] - LB_2_Wanted[47:40];
    assign pixel_6_temp2        = LB_0_Wanted[55:48] - LB_2_Wanted[55:48];
    assign pixel_7_temp2        = LB_0_Wanted[63:56] - LB_2_Wanted[63:56];
    assign pixel_8_temp2        = LB_0_Wanted[79:72] - LB_2_Wanted[63:56];
    assign pixel_9_temp2        = LB_0_Wanted[87:80] - LB_2_Wanted[71:64];
    assign pixel_10_temp2       = LB_0_Wanted[95:88] - LB_2_Wanted[79:72];
    assign pixel_11_temp2       = LB_0_Wanted[103:96] - LB_2_Wanted[87:80];
    assign pixel_12_temp2       = LB_0_Wanted[111:104] - LB_2_Wanted[95:88];
    assign pixel_13_temp2       = LB_0_Wanted[119:112] - LB_2_Wanted[103:96];
    assign pixel_14_temp2       = LB_0_Wanted[127:120] - LB_2_Wanted[111:104];
    assign pixel_15_temp2       = LB_0_Wanted[135:128] - LB_2_Wanted[119:112];
        
    assign abs_pixel_1_temp1    = ~pixel_1_temp1 + 1'b1;
    assign abs_pixel_1_temp2    = ~pixel_1_temp2 + 1'b1;
    assign abs_pixel_2_temp1    = ~pixel_2_temp1 + 1'b1;
    assign abs_pixel_2_temp2    = ~pixel_2_temp2 + 1'b1;
    assign abs_pixel_3_temp1    = ~pixel_3_temp1 + 1'b1;
    assign abs_pixel_3_temp2    = ~pixel_3_temp2 + 1'b1;
    assign abs_pixel_4_temp1    = ~pixel_4_temp1 + 1'b1;
    assign abs_pixel_4_temp2    = ~pixel_4_temp2 + 1'b1;
    assign abs_pixel_5_temp1    = ~pixel_5_temp1 + 1'b1;
    assign abs_pixel_5_temp2    = ~pixel_5_temp2 + 1'b1;
    assign abs_pixel_6_temp1    = ~pixel_6_temp1 + 1'b1;
    assign abs_pixel_6_temp2    = ~pixel_6_temp2 + 1'b1;
    assign abs_pixel_7_temp1    = ~pixel_7_temp1 + 1'b1;
    assign abs_pixel_7_temp2    = ~pixel_7_temp2 + 1'b1;
    assign abs_pixel_8_temp1    = ~pixel_8_temp1 + 1'b1;
    assign abs_pixel_8_temp2    = ~pixel_8_temp2 + 1'b1;
    assign abs_pixel_9_temp1    = ~pixel_9_temp1 + 1'b1;
    assign abs_pixel_9_temp2    = ~pixel_9_temp2 + 1'b1;
    assign abs_pixel_10_temp1   = ~pixel_10_temp1 + 1'b1;
    assign abs_pixel_10_temp2   = ~pixel_10_temp2 + 1'b1;
    assign abs_pixel_11_temp1   = ~pixel_11_temp1 + 1'b1;
    assign abs_pixel_11_temp2   = ~pixel_11_temp2 + 1'b1;
    assign abs_pixel_12_temp1   = ~pixel_12_temp1 + 1'b1;
    assign abs_pixel_12_temp2   = ~pixel_12_temp2 + 1'b1;
    assign abs_pixel_13_temp1   = ~pixel_13_temp1 + 1'b1;
    assign abs_pixel_13_temp2   = ~pixel_13_temp2 + 1'b1;
    assign abs_pixel_14_temp1   = ~pixel_14_temp1 + 1'b1;
    assign abs_pixel_14_temp2   = ~pixel_14_temp2 + 1'b1;
    assign abs_pixel_15_temp1   = ~pixel_15_temp1 + 1'b1;
    assign abs_pixel_15_temp2   = ~pixel_15_temp2 + 1'b1;
        
    assign p1_mag               = ((pixel_1_temp1[8])? abs_pixel_1_temp1 : pixel_1_temp1) + 
                                  ((pixel_1_temp2[8])? abs_pixel_1_temp2 : pixel_1_temp2);
    assign p2_mag               = ((pixel_2_temp1[8])? abs_pixel_2_temp1 : pixel_2_temp1) + 
                                  ((pixel_2_temp2[8])? abs_pixel_2_temp2 : pixel_2_temp2);
    assign p3_mag               = ((pixel_3_temp1[8])? abs_pixel_3_temp1 : pixel_3_temp1) + 
                                  ((pixel_3_temp2[8])? abs_pixel_3_temp2 : pixel_3_temp2);
    assign p4_mag               = ((pixel_4_temp1[8])? abs_pixel_4_temp1 : pixel_4_temp1) + 
                                  ((pixel_4_temp2[8])? abs_pixel_4_temp2 : pixel_4_temp2);
    assign p5_mag               = ((pixel_5_temp1[8])? abs_pixel_5_temp1 : pixel_5_temp1) + 
                                  ((pixel_5_temp2[8])? abs_pixel_5_temp2 : pixel_5_temp2);
    assign p6_mag               = ((pixel_6_temp1[8])? abs_pixel_6_temp1 : pixel_6_temp1) + 
                                  ((pixel_6_temp2[8])? abs_pixel_6_temp2 : pixel_6_temp2);
    assign p7_mag               = ((pixel_7_temp1[8])? abs_pixel_7_temp1 : pixel_7_temp1) + 
                                  ((pixel_7_temp2[8])? abs_pixel_7_temp2 : pixel_7_temp2);
    assign p8_mag               = ((pixel_8_temp1[8])? abs_pixel_8_temp1 : pixel_8_temp1) + 
                                  ((pixel_8_temp2[8])? abs_pixel_8_temp2 : pixel_8_temp2);
    assign p9_mag               = ((pixel_9_temp1[8])? abs_pixel_9_temp1 : pixel_9_temp1) + 
                                  ((pixel_9_temp2[8])? abs_pixel_9_temp2 : pixel_9_temp2);
    assign p10_mag              = ((pixel_10_temp1[8])? abs_pixel_10_temp1 : pixel_10_temp1) + 
                                  ((pixel_10_temp2[8])? abs_pixel_10_temp2 : pixel_10_temp2);
    assign p11_mag              = ((pixel_11_temp1[8])? abs_pixel_11_temp1 : pixel_11_temp1) + 
                                  ((pixel_11_temp2[8])? abs_pixel_11_temp2 : pixel_11_temp2);
    assign p12_mag              = ((pixel_12_temp1[8])? abs_pixel_12_temp1 : pixel_12_temp1) + 
                                  ((pixel_12_temp2[8])? abs_pixel_12_temp2 : pixel_12_temp2);
    assign p13_mag              = ((pixel_13_temp1[8])? abs_pixel_13_temp1 : pixel_13_temp1) + 
                                  ((pixel_13_temp2[8])? abs_pixel_13_temp2 : pixel_13_temp2);
    assign p14_mag              = ((pixel_14_temp1[8])? abs_pixel_14_temp1 : pixel_14_temp1) + 
                                  ((pixel_14_temp2[8])? abs_pixel_14_temp2 : pixel_14_temp2);
    assign p15_mag              = ((pixel_15_temp1[8])? abs_pixel_15_temp1 : pixel_15_temp1) + 
                                  ((pixel_15_temp2[8])? abs_pixel_15_temp2 : pixel_15_temp2);
        
    //assign row_accu_result1     = (not_garbageRow)? modified_pixel_1 + modified_pixel_2 + modified_pixel_3 + modified_pixel_4 : 'd0;//不會進位
    //assign row_accu_result2     = (not_garbageRow)? modified_pixel_4 + modified_pixel_5 + modified_pixel_6 + modified_pixel_7 : 'd0;
    
    //will not carry over to next orientation
    assign row_accu_result1     = pixel_1 + pixel_2 + pixel_3 + pixel_4 + pixel_5 + pixel_6 + pixel_7 + pixel_8;
    assign row_accu_result2     = pixel_8 + pixel_9 + pixel_10 + pixel_11 + pixel_12 + pixel_13 + pixel_14 + pixel_15;
    
    //////////////////////////////
    
    always @(*) begin //p1_bin
    
        case({pixel_1_temp1[8], pixel_1_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_1_temp1 > pixel_1_temp2)
                    p1_bin = 'd0;
                else
                    p1_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_1_temp1 > abs_pixel_1_temp2)
                    p1_bin = 'd7;
                else
                    p1_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_1_temp1 > pixel_1_temp2)
                    p1_bin = 'd3;
                else
                    p1_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_1_temp1 > abs_pixel_1_temp2)
                    p1_bin = 'd4;
                else
                    p1_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_1
    
        case(p1_bin)
            'd0:
                pixel_1 = { 2'b00, p1_mag, {84{1'b0}} };
            'd1:         
                pixel_1 = { {12{1'b0}}, 2'b00, p1_mag, {72{1'b0}} };
            'd2:         
                pixel_1 = { {24{1'b0}}, 2'b00, p1_mag, {60{1'b0}} };
            'd3:         
                pixel_1 = { {36{1'b0}}, 2'b00, p1_mag, {48{1'b0}} };
            'd4:         
                pixel_1 = { {48{1'b0}}, 2'b00, p1_mag, {36{1'b0}} };
            'd5:         
                pixel_1 = { {60{1'b0}}, 2'b00, p1_mag, {24{1'b0}} };
            'd6:         
                pixel_1 = { {72{1'b0}}, 2'b00, p1_mag, {12{1'b0}} };
            default:     
                pixel_1 = { {84{1'b0}}, 2'b00, p1_mag };
        endcase
    
    end
    
    always @(*) begin //p2_bin
    
        case({pixel_2_temp1[8], pixel_2_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_2_temp1 > pixel_2_temp2)
                    p2_bin = 'd0;
                else
                    p2_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_2_temp1 > abs_pixel_2_temp2)
                    p2_bin = 'd7;
                else
                    p2_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_2_temp1 > pixel_2_temp2)
                    p2_bin = 'd3;
                else
                    p2_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_2_temp1 > abs_pixel_2_temp2)
                    p2_bin = 'd4;
                else
                    p2_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_2
    
        case(p2_bin)
            'd0:
                pixel_2 = { 2'b00, p2_mag, {84{1'b0}} };
            'd1:         
                pixel_2 = { {12{1'b0}}, 2'b00, p2_mag, {72{1'b0}} };
            'd2:         
                pixel_2 = { {24{1'b0}}, 2'b00, p2_mag, {60{1'b0}} };
            'd3:         
                pixel_2 = { {36{1'b0}}, 2'b00, p2_mag, {48{1'b0}} };
            'd4:         
                pixel_2 = { {48{1'b0}}, 2'b00, p2_mag, {36{1'b0}} };
            'd5:         
                pixel_2 = { {60{1'b0}}, 2'b00, p2_mag, {24{1'b0}} };
            'd6:         
                pixel_2 = { {72{1'b0}}, 2'b00, p2_mag, {12{1'b0}} };
            default:     
                pixel_2 = { {84{1'b0}}, 2'b00, p2_mag };
        endcase
    
    end
    
    always @(*) begin //p3_bin
    
        case({pixel_3_temp1[8], pixel_3_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_3_temp1 > pixel_3_temp2)
                    p3_bin = 'd0;
                else
                    p3_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_3_temp1 > abs_pixel_3_temp2)
                    p3_bin = 'd7;
                else
                    p3_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_3_temp1 > pixel_3_temp2)
                    p3_bin = 'd3;
                else
                    p3_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_3_temp1 > abs_pixel_3_temp2)
                    p3_bin = 'd4;
                else
                    p3_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_3
    
        case(p3_bin)
            'd0:
                pixel_3 = { 2'b00, p3_mag, {84{1'b0}} };
            'd1:         
                pixel_3 = { {12{1'b0}}, 2'b00, p3_mag, {72{1'b0}} };
            'd2:         
                pixel_3 = { {24{1'b0}}, 2'b00, p3_mag, {60{1'b0}} };
            'd3:         
                pixel_3 = { {36{1'b0}}, 2'b00, p3_mag, {48{1'b0}} };
            'd4:         
                pixel_3 = { {48{1'b0}}, 2'b00, p3_mag, {36{1'b0}} };
            'd5:         
                pixel_3 = { {60{1'b0}}, 2'b00, p3_mag, {24{1'b0}} };
            'd6:         
                pixel_3 = { {72{1'b0}}, 2'b00, p3_mag, {12{1'b0}} };
            default:     
                pixel_3 = { {84{1'b0}}, 2'b00, p3_mag };
        endcase
    
    end
    
    always @(*) begin //p4_bin
    
        case({pixel_4_temp1[8], pixel_4_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_4_temp1 > pixel_4_temp2)
                    p4_bin = 'd0;
                else
                    p4_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_4_temp1 > abs_pixel_4_temp2)
                    p4_bin = 'd7;
                else
                    p4_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_4_temp1 > pixel_4_temp2)
                    p4_bin = 'd3;
                else
                    p4_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_4_temp1 > abs_pixel_4_temp2)
                    p4_bin = 'd4;
                else
                    p4_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_4
    
        case(p4_bin)
            'd0:
                pixel_4 = { 2'b00, p4_mag, {84{1'b0}} };
            'd1:         
                pixel_4 = { {12{1'b0}}, 2'b00, p4_mag, {72{1'b0}} };
            'd2:         
                pixel_4 = { {24{1'b0}}, 2'b00, p4_mag, {60{1'b0}} };
            'd3:         
                pixel_4 = { {36{1'b0}}, 2'b00, p4_mag, {48{1'b0}} };
            'd4:         
                pixel_4 = { {48{1'b0}}, 2'b00, p4_mag, {36{1'b0}} };
            'd5:         
                pixel_4 = { {60{1'b0}}, 2'b00, p4_mag, {24{1'b0}} };
            'd6:         
                pixel_4 = { {72{1'b0}}, 2'b00, p4_mag, {12{1'b0}} };
            default:     
                pixel_4 = { {84{1'b0}}, 2'b00, p4_mag };
        endcase
    
    end
    
    always @(*) begin //p5_bin
    
        case({pixel_5_temp1[8], pixel_5_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_5_temp1 > pixel_5_temp2)
                    p5_bin = 'd0;
                else
                    p5_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_5_temp1 > abs_pixel_5_temp2)
                    p5_bin = 'd7;
                else
                    p5_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_5_temp1 > pixel_5_temp2)
                    p5_bin = 'd3;
                else
                    p5_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_5_temp1 > abs_pixel_5_temp2)
                    p5_bin = 'd4;
                else
                    p5_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_5
    
        case(p5_bin)
            'd0:
                pixel_5 = { 2'b00, p5_mag, {84{1'b0}} };
            'd1:         
                pixel_5 = { {12{1'b0}}, 2'b00, p5_mag, {72{1'b0}} };
            'd2:         
                pixel_5 = { {24{1'b0}}, 2'b00, p5_mag, {60{1'b0}} };
            'd3:         
                pixel_5 = { {36{1'b0}}, 2'b00, p5_mag, {48{1'b0}} };
            'd4:         
                pixel_5 = { {48{1'b0}}, 2'b00, p5_mag, {36{1'b0}} };
            'd5:         
                pixel_5 = { {60{1'b0}}, 2'b00, p5_mag, {24{1'b0}} };
            'd6:         
                pixel_5 = { {72{1'b0}}, 2'b00, p5_mag, {12{1'b0}} };
            default:     
                pixel_5 = { {84{1'b0}}, 2'b00, p5_mag };
        endcase
    
    end
    
    always @(*) begin //p6_bin
    
        case({pixel_6_temp1[8], pixel_6_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_6_temp1 > pixel_6_temp2)
                    p6_bin = 'd0;
                else
                    p6_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_6_temp1 > abs_pixel_6_temp2)
                    p6_bin = 'd7;
                else
                    p6_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_6_temp1 > pixel_6_temp2)
                    p6_bin = 'd3;
                else
                    p6_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_6_temp1 > abs_pixel_6_temp2)
                    p6_bin = 'd4;
                else
                    p6_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_6
    
        case(p6_bin)
            'd0:
                pixel_6 = { 2'b00, p6_mag, {84{1'b0}} };
            'd1:         
                pixel_6 = { {12{1'b0}}, 2'b00, p6_mag, {72{1'b0}} };
            'd2:         
                pixel_6 = { {24{1'b0}}, 2'b00, p6_mag, {60{1'b0}} };
            'd3:         
                pixel_6 = { {36{1'b0}}, 2'b00, p6_mag, {48{1'b0}} };
            'd4:         
                pixel_6 = { {48{1'b0}}, 2'b00, p6_mag, {36{1'b0}} };
            'd5:         
                pixel_6 = { {60{1'b0}}, 2'b00, p6_mag, {24{1'b0}} };
            'd6:         
                pixel_6 = { {72{1'b0}}, 2'b00, p6_mag, {12{1'b0}} };
            default:     
                pixel_6 = { {84{1'b0}}, 2'b00, p6_mag };
        endcase
    
    end
    
    always @(*) begin //p7_bin
    
        case({pixel_7_temp1[8], pixel_7_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_7_temp1 > pixel_7_temp2)
                    p7_bin = 'd0;
                else
                    p7_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_7_temp1 > abs_pixel_7_temp2)
                    p7_bin = 'd7;
                else
                    p7_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_7_temp1 > pixel_7_temp2)
                    p7_bin = 'd3;
                else
                    p7_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_7_temp1 > abs_pixel_7_temp2)
                    p7_bin = 'd4;
                else
                    p7_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_7
    
        case(p7_bin)
            'd0:
                pixel_7 = { 2'b00, p7_mag, {84{1'b0}} };
            'd1:         
                pixel_7 = { {12{1'b0}}, 2'b00, p7_mag, {72{1'b0}} };
            'd2:         
                pixel_7 = { {24{1'b0}}, 2'b00, p7_mag, {60{1'b0}} };
            'd3:         
                pixel_7 = { {36{1'b0}}, 2'b00, p7_mag, {48{1'b0}} };
            'd4:         
                pixel_7 = { {48{1'b0}}, 2'b00, p7_mag, {36{1'b0}} };
            'd5:         
                pixel_7 = { {60{1'b0}}, 2'b00, p7_mag, {24{1'b0}} };
            'd6:         
                pixel_7 = { {72{1'b0}}, 2'b00, p7_mag, {12{1'b0}} };
            default:     
                pixel_7 = { {84{1'b0}}, 2'b00, p7_mag };
        endcase
    
    end
    
    always @(*) begin //p8_bin
    
        case({pixel_8_temp1[8], pixel_8_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_8_temp1 > pixel_8_temp2)
                    p8_bin = 'd0;
                else
                    p8_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_8_temp1 > abs_pixel_8_temp2)
                    p8_bin = 'd7;
                else
                    p8_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_8_temp1 > pixel_8_temp2)
                    p8_bin = 'd3;
                else
                    p8_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_8_temp1 > abs_pixel_8_temp2)
                    p8_bin = 'd4;
                else
                    p8_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_8
    
        case(p8_bin)
            'd0:
                pixel_8 = { 2'b00, p8_mag, {84{1'b0}} };
            'd1:        
                pixel_8 = { {12{1'b0}}, 2'b00, p8_mag, {72{1'b0}} };
            'd2:       
                pixel_8 = { {24{1'b0}}, 2'b00, p8_mag, {60{1'b0}} };
            'd3:        
                pixel_8 = { {36{1'b0}}, 2'b00, p8_mag, {48{1'b0}} };
            'd4:        
                pixel_8 = { {48{1'b0}}, 2'b00, p8_mag, {36{1'b0}} };
            'd5:        
                pixel_8 = { {60{1'b0}}, 2'b00, p8_mag, {24{1'b0}} };
            'd6:        
                pixel_8 = { {72{1'b0}}, 2'b00, p8_mag, {12{1'b0}} };
            default:    
                pixel_8 = { {84{1'b0}}, 2'b00, p8_mag };
        endcase
    
    end
    
    always @(*) begin //p9_bin
    
        case({pixel_9_temp1[8], pixel_9_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_9_temp1 > pixel_9_temp2)
                    p9_bin = 'd0;
                else
                    p9_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_9_temp1 > abs_pixel_9_temp2)
                    p9_bin = 'd7;
                else
                    p9_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_9_temp1 > pixel_9_temp2)
                    p9_bin = 'd3;
                else
                    p9_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_9_temp1 > abs_pixel_9_temp2)
                    p9_bin = 'd4;
                else
                    p9_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_9
    
        case(p9_bin)
            'd0:
                pixel_9 = { 2'b00, p9_mag, {84{1'b0}} };
            'd1:  
                pixel_9 = { {12{1'b0}}, 2'b00, p9_mag, {72{1'b0}} };
            'd2:        
                pixel_9 = { {24{1'b0}}, 2'b00, p9_mag, {60{1'b0}} };
            'd3:        
                pixel_9 = { {36{1'b0}}, 2'b00, p9_mag, {48{1'b0}} };
            'd4:        
                pixel_9 = { {48{1'b0}}, 2'b00, p9_mag, {36{1'b0}} };
            'd5:        
                pixel_9 = { {60{1'b0}}, 2'b00, p9_mag, {24{1'b0}} };
            'd6:        
                pixel_9 = { {72{1'b0}}, 2'b00, p9_mag, {12{1'b0}} };
            default:    
                pixel_9 = { {84{1'b0}}, 2'b00, p9_mag };
        endcase
    
    end
    
    always @(*) begin //p10_bin
    
        case({pixel_10_temp1[8], pixel_10_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_10_temp1 > pixel_10_temp2)
                    p10_bin = 'd0;
                else
                    p10_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_10_temp1 > abs_pixel_10_temp2)
                    p10_bin = 'd7;
                else
                    p10_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_10_temp1 > pixel_10_temp2)
                    p10_bin = 'd3;
                else
                    p10_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_10_temp1 > abs_pixel_10_temp2)
                    p10_bin = 'd4;
                else
                    p10_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_10
    
        case(p10_bin)
            'd0:
                pixel_10 = { 2'b00, p10_mag, {84{1'b0}} };
            'd1:        
                pixel_10 = { {12{1'b0}}, 2'b00, p10_mag, {72{1'b0}} };
            'd2:        
                pixel_10 = { {24{1'b0}}, 2'b00, p10_mag, {60{1'b0}} };
            'd3:        
                pixel_10 = { {36{1'b0}}, 2'b00, p10_mag, {48{1'b0}} };
            'd4:        
                pixel_10 = { {48{1'b0}}, 2'b00, p10_mag, {36{1'b0}} };
            'd5:        
                pixel_10 = { {60{1'b0}}, 2'b00, p10_mag, {24{1'b0}} };
            'd6:        
                pixel_10 = { {72{1'b0}}, 2'b00, p10_mag, {12{1'b0}} };
            default:    
                pixel_10 = { {84{1'b0}}, 2'b00, p10_mag };
        endcase
    
    end
    
    always @(*) begin //p11_bin
    
        case({pixel_11_temp1[8], pixel_11_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_11_temp1 > pixel_11_temp2)
                    p11_bin = 'd0;
                else
                    p11_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_11_temp1 > abs_pixel_11_temp2)
                    p11_bin = 'd7;
                else
                    p11_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_11_temp1 > pixel_11_temp2)
                    p11_bin = 'd3;
                else
                    p11_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_11_temp1 > abs_pixel_11_temp2)
                    p11_bin = 'd4;
                else
                    p11_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_11
    
        case(p11_bin)
            'd0:
                pixel_11 = { 2'b00, p11_mag, {84{1'b0}} };
            'd1:        
                pixel_11 = { {12{1'b0}}, 2'b00, p11_mag, {72{1'b0}} };
            'd2:        
                pixel_11 = { {24{1'b0}}, 2'b00, p11_mag, {60{1'b0}} };
            'd3:        
                pixel_11 = { {36{1'b0}}, 2'b00, p11_mag, {48{1'b0}} };
            'd4:        
                pixel_11 = { {48{1'b0}}, 2'b00, p11_mag, {36{1'b0}} };
            'd5:        
                pixel_11 = { {60{1'b0}}, 2'b00, p11_mag, {24{1'b0}} };
            'd6:        
                pixel_11 = { {72{1'b0}}, 2'b00, p11_mag, {12{1'b0}} };
            default:    
                pixel_11 = { {84{1'b0}}, 2'b00, p11_mag };
        endcase
    
    end
    
    always @(*) begin //p12_bin
    
        case({pixel_12_temp1[8], pixel_12_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_12_temp1 > pixel_12_temp2)
                    p12_bin = 'd0;
                else
                    p12_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_12_temp1 > abs_pixel_12_temp2)
                    p12_bin = 'd7;
                else
                    p12_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_12_temp1 > pixel_12_temp2)
                    p12_bin = 'd3;
                else
                    p12_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_12_temp1 > abs_pixel_12_temp2)
                    p12_bin = 'd4;
                else
                    p12_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_12
    
        case(p12_bin)
            'd0:
                pixel_12 = { 2'b00, p12_mag, {84{1'b0}} };
            'd1:        
                pixel_12 = { {12{1'b0}}, 2'b00, p12_mag, {72{1'b0}} };
            'd2:        
                pixel_12 = { {24{1'b0}}, 2'b00, p12_mag, {60{1'b0}} };
            'd3:        
                pixel_12 = { {36{1'b0}}, 2'b00, p12_mag, {48{1'b0}} };
            'd4:        
                pixel_12 = { {48{1'b0}}, 2'b00, p12_mag, {36{1'b0}} };
            'd5:        
                pixel_12 = { {60{1'b0}}, 2'b00, p12_mag, {24{1'b0}} };
            'd6:        
                pixel_12 = { {72{1'b0}}, 2'b00, p12_mag, {12{1'b0}} };
            default:    
                pixel_12 = { {84{1'b0}}, 2'b00, p12_mag };
        endcase
    
    end
    
    always @(*) begin //p13_bin
    
        case({pixel_13_temp1[8], pixel_13_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_13_temp1 > pixel_13_temp2)
                    p13_bin = 'd0;
                else
                    p13_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_13_temp1 > abs_pixel_13_temp2)
                    p13_bin = 'd7;
                else
                    p13_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_13_temp1 > pixel_13_temp2)
                    p13_bin = 'd3;
                else
                    p13_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_13_temp1 > abs_pixel_13_temp2)
                    p13_bin = 'd4;
                else
                    p13_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_13
    
        case(p13_bin)
            'd0:
                pixel_13 = { 2'b00, p13_mag, {84{1'b0}} };
            'd1:        
                pixel_13 = { {12{1'b0}}, 2'b00, p13_mag, {72{1'b0}} };
            'd2:        
                pixel_13 = { {24{1'b0}}, 2'b00, p13_mag, {60{1'b0}} };
            'd3:        
                pixel_13 = { {36{1'b0}}, 2'b00, p13_mag, {48{1'b0}} };
            'd4:        
                pixel_13 = { {48{1'b0}}, 2'b00, p13_mag, {36{1'b0}} };
            'd5:        
                pixel_13 = { {60{1'b0}}, 2'b00, p13_mag, {24{1'b0}} };
            'd6:        
                pixel_13 = { {72{1'b0}}, 2'b00, p13_mag, {12{1'b0}} };
            default:    
                pixel_13 = { {84{1'b0}}, 2'b00, p13_mag };
        endcase
    
    end
    
    always @(*) begin //p14_bin
    
        case({pixel_14_temp1[8], pixel_14_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_14_temp1 > pixel_14_temp2)
                    p14_bin = 'd0;
                else
                    p14_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_14_temp1 > abs_pixel_14_temp2)
                    p14_bin = 'd7;
                else
                    p14_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_14_temp1 > pixel_14_temp2)
                    p14_bin = 'd3;
                else
                    p14_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_14_temp1 > abs_pixel_14_temp2)
                    p14_bin = 'd4;
                else
                    p14_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_14
    
        case(p14_bin)
            'd0:
                pixel_14 = { 2'b00, p14_mag, {84{1'b0}} };
            'd1:        
                pixel_14 = { {12{1'b0}}, 2'b00, p14_mag, {72{1'b0}} };
            'd2:        
                pixel_14 = { {24{1'b0}}, 2'b00, p14_mag, {60{1'b0}} };
            'd3:        
                pixel_14 = { {36{1'b0}}, 2'b00, p14_mag, {48{1'b0}} };
            'd4:        
                pixel_14 = { {48{1'b0}}, 2'b00, p14_mag, {36{1'b0}} };
            'd5:        
                pixel_14 = { {60{1'b0}}, 2'b00, p14_mag, {24{1'b0}} };
            'd6:        
                pixel_14 = { {72{1'b0}}, 2'b00, p14_mag, {12{1'b0}} };
            default:    
                pixel_14 = { {84{1'b0}}, 2'b00, p14_mag };
        endcase
    
    end
    
    always @(*) begin //p15_bin
    
        case({pixel_15_temp1[8], pixel_15_temp2[8]})//x, y
            2'b00://1st quadrant
                if(pixel_15_temp1 > pixel_15_temp2)
                    p15_bin = 'd0;
                else
                    p15_bin = 'd1;
            2'b01://4th quadrant
                if(pixel_15_temp1 > abs_pixel_15_temp2)
                    p15_bin = 'd7;
                else
                    p15_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_15_temp1 > pixel_15_temp2)
                    p15_bin = 'd3;
                else
                    p15_bin = 'd2;
            default: //3rd quadrant
                if(abs_pixel_15_temp1 > abs_pixel_15_temp2)
                    p15_bin = 'd4;
                else
                    p15_bin = 'd5;
        endcase
    
    end
    
    always @(*) begin //pixel_15
    
        case(p15_bin)
            'd0:
                pixel_15 = { 2'b00, p15_mag, {84{1'b0}} };
            'd1:        
                pixel_15 = { {12{1'b0}}, 2'b00, p15_mag, {72{1'b0}} };
            'd2:        
                pixel_15 = { {24{1'b0}}, 2'b00, p15_mag, {60{1'b0}} };
            'd3:        
                pixel_15 = { {36{1'b0}}, 2'b00, p15_mag, {48{1'b0}} };
            'd4:        
                pixel_15 = { {48{1'b0}}, 2'b00, p15_mag, {36{1'b0}} };
            'd5:        
                pixel_15 = { {60{1'b0}}, 2'b00, p15_mag, {24{1'b0}} };
            'd6:        
                pixel_15 = { {72{1'b0}}, 2'b00, p15_mag, {12{1'b0}} };
            default:    
                pixel_15 = { {84{1'b0}}, 2'b00, p15_mag };
        endcase
    
    end
    
    always @(*) begin //LB_0_Wanted, LB_1_Wanted, LB_2_Wanted
    
        case(col)
            'd8: begin
                LB_0_Wanted = LB_0[135:0];
                LB_1_Wanted = LB_1[135:0];
                LB_2_Wanted = LB_2[135:0];
            end
            'd9: begin
                LB_0_Wanted = LB_0[143:8];
                LB_1_Wanted = LB_1[143:8];
                LB_2_Wanted = LB_2[143:8];
            end
            'd10: begin
                LB_0_Wanted = LB_0[151:16];
                LB_1_Wanted = LB_1[151:16];
                LB_2_Wanted = LB_2[151:16];
            end
            'd11: begin
                LB_0_Wanted = LB_0[159:24];
                LB_1_Wanted = LB_1[159:24];
                LB_2_Wanted = LB_2[159:24];
            end
            'd12: begin
                LB_0_Wanted = LB_0[167:32];
                LB_1_Wanted = LB_1[167:32];
                LB_2_Wanted = LB_2[167:32];
            end
            'd13: begin
                LB_0_Wanted = LB_0[175:40];
                LB_1_Wanted = LB_1[175:40];
                LB_2_Wanted = LB_2[175:40];
            end
            'd14: begin
                LB_0_Wanted = LB_0[183:48];
                LB_1_Wanted = LB_1[183:48];
                LB_2_Wanted = LB_2[183:48];
            end
            'd15: begin
                LB_0_Wanted = LB_0[191:56];
                LB_1_Wanted = LB_1[191:56];
                LB_2_Wanted = LB_2[191:56];
            end
            'd16: begin
                LB_0_Wanted = LB_0[199:64];
                LB_1_Wanted = LB_1[199:64];
                LB_2_Wanted = LB_2[199:64];
            end
            'd17: begin
                LB_0_Wanted = LB_0[207:72];
                LB_1_Wanted = LB_1[207:72];
                LB_2_Wanted = LB_2[207:72];
            end
            'd18: begin
                LB_0_Wanted = LB_0[215:80];
                LB_1_Wanted = LB_1[215:80];
                LB_2_Wanted = LB_2[215:80];
            end
            'd19: begin
                LB_0_Wanted = LB_0[223:88];
                LB_1_Wanted = LB_1[223:88];
                LB_2_Wanted = LB_2[223:88];
            end
            'd20: begin
                LB_0_Wanted = LB_0[231:96];
                LB_1_Wanted = LB_1[231:96];
                LB_2_Wanted = LB_2[231:96];
            end
            'd21: begin
                LB_0_Wanted = LB_0[239:104];
                LB_1_Wanted = LB_1[239:104];
                LB_2_Wanted = LB_2[239:104];
            end
            'd22: begin
                LB_0_Wanted = LB_0[247:112];
                LB_1_Wanted = LB_1[247:112];
                LB_2_Wanted = LB_2[247:112];
            end
            'd23: begin
                LB_0_Wanted = LB_0[255:120];
                LB_1_Wanted = LB_1[255:120];
                LB_2_Wanted = LB_2[255:120];
            end
            'd24: begin
                LB_0_Wanted = LB_0[263:128];
                LB_1_Wanted = LB_1[263:128];
                LB_2_Wanted = LB_2[263:128];
            end
            'd25: begin
                LB_0_Wanted = LB_0[271:136];
                LB_1_Wanted = LB_1[271:136];
                LB_2_Wanted = LB_2[271:136];
            end
            'd26: begin
                LB_0_Wanted = LB_0[279:144];
                LB_1_Wanted = LB_1[279:144];
                LB_2_Wanted = LB_2[279:144];
            end
            'd27: begin
                LB_0_Wanted = LB_0[287:152];
                LB_1_Wanted = LB_1[287:152];
                LB_2_Wanted = LB_2[287:152];
            end
            'd28: begin
                LB_0_Wanted = LB_0[295:160];
                LB_1_Wanted = LB_1[295:160];
                LB_2_Wanted = LB_2[295:160];
            end
            'd29: begin
                LB_0_Wanted = LB_0[303:168];
                LB_1_Wanted = LB_1[303:168];
                LB_2_Wanted = LB_2[303:168];
            end
            'd30: begin
                LB_0_Wanted = LB_0[311:176];
                LB_1_Wanted = LB_1[311:176];
                LB_2_Wanted = LB_2[311:176];
            end
            'd31: begin
                LB_0_Wanted = LB_0[319:184];
                LB_1_Wanted = LB_1[319:184];
                LB_2_Wanted = LB_2[319:184];
            end
            'd32: begin
                LB_0_Wanted = LB_0[327:192];
                LB_1_Wanted = LB_1[327:192];
                LB_2_Wanted = LB_2[327:192];
            end
            'd33: begin
                LB_0_Wanted = LB_0[335:200];
                LB_1_Wanted = LB_1[335:200];
                LB_2_Wanted = LB_2[335:200];
            end
            'd34: begin
                LB_0_Wanted = LB_0[343:208];
                LB_1_Wanted = LB_1[343:208];
                LB_2_Wanted = LB_2[343:208];
            end
            'd35: begin
                LB_0_Wanted = LB_0[351:216];
                LB_1_Wanted = LB_1[351:216];
                LB_2_Wanted = LB_2[351:216];
            end
            'd36: begin
                LB_0_Wanted = LB_0[359:224];
                LB_1_Wanted = LB_1[359:224];
                LB_2_Wanted = LB_2[359:224];
            end
            'd37: begin
                LB_0_Wanted = LB_0[367:232];
                LB_1_Wanted = LB_1[367:232];
                LB_2_Wanted = LB_2[367:232];
            end
            'd38: begin
                LB_0_Wanted = LB_0[375:240];
                LB_1_Wanted = LB_1[375:240];
                LB_2_Wanted = LB_2[375:240];
            end
            'd39: begin
                LB_0_Wanted = LB_0[383:248];
                LB_1_Wanted = LB_1[383:248];
                LB_2_Wanted = LB_2[383:248];
            end
            'd40: begin
                LB_0_Wanted = LB_0[391:256];
                LB_1_Wanted = LB_1[391:256];
                LB_2_Wanted = LB_2[391:256];
            end
            'd41: begin
                LB_0_Wanted = LB_0[399:264];
                LB_1_Wanted = LB_1[399:264];
                LB_2_Wanted = LB_2[399:264];
            end
            'd42: begin
                LB_0_Wanted = LB_0[407:272];
                LB_1_Wanted = LB_1[407:272];
                LB_2_Wanted = LB_2[407:272];
            end
            'd43: begin
                LB_0_Wanted = LB_0[415:280];
                LB_1_Wanted = LB_1[415:280];
                LB_2_Wanted = LB_2[415:280];
            end
            'd44: begin
                LB_0_Wanted = LB_0[423:288];
                LB_1_Wanted = LB_1[423:288];
                LB_2_Wanted = LB_2[423:288];
            end
            'd45: begin
                LB_0_Wanted = LB_0[431:296];
                LB_1_Wanted = LB_1[431:296];
                LB_2_Wanted = LB_2[431:296];
            end
            'd46: begin
                LB_0_Wanted = LB_0[439:304];
                LB_1_Wanted = LB_1[439:304];
                LB_2_Wanted = LB_2[439:304];
            end
            'd47: begin
                LB_0_Wanted = LB_0[447:312];
                LB_1_Wanted = LB_1[447:312];
                LB_2_Wanted = LB_2[447:312];
            end
            'd48: begin
                LB_0_Wanted = LB_0[455:320];
                LB_1_Wanted = LB_1[455:320];
                LB_2_Wanted = LB_2[455:320];
            end
            'd49: begin
                LB_0_Wanted = LB_0[463:328];
                LB_1_Wanted = LB_1[463:328];
                LB_2_Wanted = LB_2[463:328];
            end
            'd50: begin
                LB_0_Wanted = LB_0[471:336];
                LB_1_Wanted = LB_1[471:336];
                LB_2_Wanted = LB_2[471:336];
            end
            'd51: begin
                LB_0_Wanted = LB_0[479:344];
                LB_1_Wanted = LB_1[479:344];
                LB_2_Wanted = LB_2[479:344];
            end
            'd52: begin
                LB_0_Wanted = LB_0[487:352];
                LB_1_Wanted = LB_1[487:352];
                LB_2_Wanted = LB_2[487:352];
            end
            'd53: begin
                LB_0_Wanted = LB_0[495:360];
                LB_1_Wanted = LB_1[495:360];
                LB_2_Wanted = LB_2[495:360];
            end
            'd54: begin
                LB_0_Wanted = LB_0[503:368];
                LB_1_Wanted = LB_1[503:368];
                LB_2_Wanted = LB_2[503:368];
            end
            'd55: begin
                LB_0_Wanted = LB_0[511:376];
                LB_1_Wanted = LB_1[511:376];
                LB_2_Wanted = LB_2[511:376];
            end
            'd56: begin
                LB_0_Wanted = LB_0[519:384];
                LB_1_Wanted = LB_1[519:384];
                LB_2_Wanted = LB_2[519:384];
            end
            'd57: begin
                LB_0_Wanted = LB_0[527:392];
                LB_1_Wanted = LB_1[527:392];
                LB_2_Wanted = LB_2[527:392];
            end
            'd58: begin
                LB_0_Wanted = LB_0[535:400];
                LB_1_Wanted = LB_1[535:400];
                LB_2_Wanted = LB_2[535:400];
            end
            'd59: begin
                LB_0_Wanted = LB_0[543:408];
                LB_1_Wanted = LB_1[543:408];
                LB_2_Wanted = LB_2[543:408];
            end
            'd60: begin
                LB_0_Wanted = LB_0[551:416];
                LB_1_Wanted = LB_1[551:416];
                LB_2_Wanted = LB_2[551:416];
            end
            'd61: begin
                LB_0_Wanted = LB_0[559:424];
                LB_1_Wanted = LB_1[559:424];
                LB_2_Wanted = LB_2[559:424];
            end
            'd62: begin
                LB_0_Wanted = LB_0[567:432];
                LB_1_Wanted = LB_1[567:432];
                LB_2_Wanted = LB_2[567:432];
            end
            'd63: begin
                LB_0_Wanted = LB_0[575:440];
                LB_1_Wanted = LB_1[575:440];
                LB_2_Wanted = LB_2[575:440];
            end
            'd64: begin
                LB_0_Wanted = LB_0[583:448];
                LB_1_Wanted = LB_1[583:448];
                LB_2_Wanted = LB_2[583:448];
            end
            'd65: begin
                LB_0_Wanted = LB_0[591:456];
                LB_1_Wanted = LB_1[591:456];
                LB_2_Wanted = LB_2[591:456];
            end
            'd66: begin
                LB_0_Wanted = LB_0[599:464];
                LB_1_Wanted = LB_1[599:464];
                LB_2_Wanted = LB_2[599:464];
            end
            'd67: begin
                LB_0_Wanted = LB_0[607:472];
                LB_1_Wanted = LB_1[607:472];
                LB_2_Wanted = LB_2[607:472];
            end
            'd68: begin
                LB_0_Wanted = LB_0[615:480];
                LB_1_Wanted = LB_1[615:480];
                LB_2_Wanted = LB_2[615:480];
            end
            'd69: begin
                LB_0_Wanted = LB_0[623:488];
                LB_1_Wanted = LB_1[623:488];
                LB_2_Wanted = LB_2[623:488];
            end
            'd70: begin
                LB_0_Wanted = LB_0[631:496];
                LB_1_Wanted = LB_1[631:496];
                LB_2_Wanted = LB_2[631:496];
            end
            'd71: begin
                LB_0_Wanted = LB_0[639:504];
                LB_1_Wanted = LB_1[639:504];
                LB_2_Wanted = LB_2[639:504];
            end
            'd72: begin
                LB_0_Wanted = LB_0[647:512];
                LB_1_Wanted = LB_1[647:512];
                LB_2_Wanted = LB_2[647:512];
            end
            'd73: begin
                LB_0_Wanted = LB_0[655:520];
                LB_1_Wanted = LB_1[655:520];
                LB_2_Wanted = LB_2[655:520];
            end
            'd74: begin
                LB_0_Wanted = LB_0[663:528];
                LB_1_Wanted = LB_1[663:528];
                LB_2_Wanted = LB_2[663:528];
            end
            'd75: begin
                LB_0_Wanted = LB_0[671:536];
                LB_1_Wanted = LB_1[671:536];
                LB_2_Wanted = LB_2[671:536];
            end
            'd76: begin
                LB_0_Wanted = LB_0[679:544];
                LB_1_Wanted = LB_1[679:544];
                LB_2_Wanted = LB_2[679:544];
            end
            'd77: begin
                LB_0_Wanted = LB_0[687:552];
                LB_1_Wanted = LB_1[687:552];
                LB_2_Wanted = LB_2[687:552];
            end
            'd78: begin
                LB_0_Wanted = LB_0[695:560];
                LB_1_Wanted = LB_1[695:560];
                LB_2_Wanted = LB_2[695:560];
            end
            'd79: begin
                LB_0_Wanted = LB_0[703:568];
                LB_1_Wanted = LB_1[703:568];
                LB_2_Wanted = LB_2[703:568];
            end
            'd80: begin
                LB_0_Wanted = LB_0[711:576];
                LB_1_Wanted = LB_1[711:576];
                LB_2_Wanted = LB_2[711:576];
            end
            'd81: begin
                LB_0_Wanted = LB_0[719:584];
                LB_1_Wanted = LB_1[719:584];
                LB_2_Wanted = LB_2[719:584];
            end
            'd82: begin
                LB_0_Wanted = LB_0[727:592];
                LB_1_Wanted = LB_1[727:592];
                LB_2_Wanted = LB_2[727:592];
            end
            'd83: begin
                LB_0_Wanted = LB_0[735:600];
                LB_1_Wanted = LB_1[735:600];
                LB_2_Wanted = LB_2[735:600];
            end
            'd84: begin
                LB_0_Wanted = LB_0[743:608];
                LB_1_Wanted = LB_1[743:608];
                LB_2_Wanted = LB_2[743:608];
            end
            'd85: begin
                LB_0_Wanted = LB_0[751:616];
                LB_1_Wanted = LB_1[751:616];
                LB_2_Wanted = LB_2[751:616];
            end
            'd86: begin
                LB_0_Wanted = LB_0[759:624];
                LB_1_Wanted = LB_1[759:624];
                LB_2_Wanted = LB_2[759:624];
            end
            'd87: begin
                LB_0_Wanted = LB_0[767:632];
                LB_1_Wanted = LB_1[767:632];
                LB_2_Wanted = LB_2[767:632];
            end
            'd88: begin
                LB_0_Wanted = LB_0[775:640];
                LB_1_Wanted = LB_1[775:640];
                LB_2_Wanted = LB_2[775:640];
            end
            'd89: begin
                LB_0_Wanted = LB_0[783:648];
                LB_1_Wanted = LB_1[783:648];
                LB_2_Wanted = LB_2[783:648];
            end
            'd90: begin
                LB_0_Wanted = LB_0[791:656];
                LB_1_Wanted = LB_1[791:656];
                LB_2_Wanted = LB_2[791:656];
            end
            'd91: begin
                LB_0_Wanted = LB_0[799:664];
                LB_1_Wanted = LB_1[799:664];
                LB_2_Wanted = LB_2[799:664];
            end
            'd92: begin
                LB_0_Wanted = LB_0[807:672];
                LB_1_Wanted = LB_1[807:672];
                LB_2_Wanted = LB_2[807:672];
            end
            'd93: begin
                LB_0_Wanted = LB_0[815:680];
                LB_1_Wanted = LB_1[815:680];
                LB_2_Wanted = LB_2[815:680];
            end
            'd94: begin
                LB_0_Wanted = LB_0[823:688];
                LB_1_Wanted = LB_1[823:688];
                LB_2_Wanted = LB_2[823:688];
            end
            'd95: begin
                LB_0_Wanted = LB_0[831:696];
                LB_1_Wanted = LB_1[831:696];
                LB_2_Wanted = LB_2[831:696];
            end
            'd96: begin
                LB_0_Wanted = LB_0[839:704];
                LB_1_Wanted = LB_1[839:704];
                LB_2_Wanted = LB_2[839:704];
            end
            'd97: begin
                LB_0_Wanted = LB_0[847:712];
                LB_1_Wanted = LB_1[847:712];
                LB_2_Wanted = LB_2[847:712];
            end
            'd98: begin
                LB_0_Wanted = LB_0[855:720];
                LB_1_Wanted = LB_1[855:720];
                LB_2_Wanted = LB_2[855:720];
            end
            'd99: begin
                LB_0_Wanted = LB_0[863:728];
                LB_1_Wanted = LB_1[863:728];
                LB_2_Wanted = LB_2[863:728];
            end
            'd100: begin
                LB_0_Wanted = LB_0[871:736];
                LB_1_Wanted = LB_1[871:736];
                LB_2_Wanted = LB_2[871:736];
            end
            'd101: begin
                LB_0_Wanted = LB_0[879:744];
                LB_1_Wanted = LB_1[879:744];
                LB_2_Wanted = LB_2[879:744];
            end
            'd102: begin
                LB_0_Wanted = LB_0[887:752];
                LB_1_Wanted = LB_1[887:752];
                LB_2_Wanted = LB_2[887:752];
            end
            'd103: begin
                LB_0_Wanted = LB_0[895:760];
                LB_1_Wanted = LB_1[895:760];
                LB_2_Wanted = LB_2[895:760];
            end
            'd104: begin
                LB_0_Wanted = LB_0[903:768];
                LB_1_Wanted = LB_1[903:768];
                LB_2_Wanted = LB_2[903:768];
            end
            'd105: begin
                LB_0_Wanted = LB_0[911:776];
                LB_1_Wanted = LB_1[911:776];
                LB_2_Wanted = LB_2[911:776];
            end
            'd106: begin
                LB_0_Wanted = LB_0[919:784];
                LB_1_Wanted = LB_1[919:784];
                LB_2_Wanted = LB_2[919:784];
            end
            'd107: begin
                LB_0_Wanted = LB_0[927:792];
                LB_1_Wanted = LB_1[927:792];
                LB_2_Wanted = LB_2[927:792];
            end
            'd108: begin
                LB_0_Wanted = LB_0[935:800];
                LB_1_Wanted = LB_1[935:800];
                LB_2_Wanted = LB_2[935:800];
            end
            'd109: begin
                LB_0_Wanted = LB_0[943:808];
                LB_1_Wanted = LB_1[943:808];
                LB_2_Wanted = LB_2[943:808];
            end
            'd110: begin
                LB_0_Wanted = LB_0[951:816];
                LB_1_Wanted = LB_1[951:816];
                LB_2_Wanted = LB_2[951:816];
            end
            'd111: begin
                LB_0_Wanted = LB_0[959:824];
                LB_1_Wanted = LB_1[959:824];
                LB_2_Wanted = LB_2[959:824];
            end
            'd112: begin
                LB_0_Wanted = LB_0[967:832];
                LB_1_Wanted = LB_1[967:832];
                LB_2_Wanted = LB_2[967:832];
            end
            'd113: begin
                LB_0_Wanted = LB_0[975:840];
                LB_1_Wanted = LB_1[975:840];
                LB_2_Wanted = LB_2[975:840];
            end
            'd114: begin
                LB_0_Wanted = LB_0[983:848];
                LB_1_Wanted = LB_1[983:848];
                LB_2_Wanted = LB_2[983:848];
            end
            'd115: begin
                LB_0_Wanted = LB_0[991:856];
                LB_1_Wanted = LB_1[991:856];
                LB_2_Wanted = LB_2[991:856];
            end
            'd116: begin
                LB_0_Wanted = LB_0[999:864];
                LB_1_Wanted = LB_1[999:864];
                LB_2_Wanted = LB_2[999:864];
            end
            'd117: begin
                LB_0_Wanted = LB_0[1007:872];
                LB_1_Wanted = LB_1[1007:872];
                LB_2_Wanted = LB_2[1007:872];
            end
            'd118: begin
                LB_0_Wanted = LB_0[1015:880];
                LB_1_Wanted = LB_1[1015:880];
                LB_2_Wanted = LB_2[1015:880];
            end
            'd119: begin
                LB_0_Wanted = LB_0[1023:888];
                LB_1_Wanted = LB_1[1023:888];
                LB_2_Wanted = LB_2[1023:888];
            end
            'd120: begin
                LB_0_Wanted = LB_0[1031:896];
                LB_1_Wanted = LB_1[1031:896];
                LB_2_Wanted = LB_2[1031:896];
            end
            'd121: begin
                LB_0_Wanted = LB_0[1039:904];
                LB_1_Wanted = LB_1[1039:904];
                LB_2_Wanted = LB_2[1039:904];
            end
            'd122: begin
                LB_0_Wanted = LB_0[1047:912];
                LB_1_Wanted = LB_1[1047:912];
                LB_2_Wanted = LB_2[1047:912];
            end
            'd123: begin
                LB_0_Wanted = LB_0[1055:920];
                LB_1_Wanted = LB_1[1055:920];
                LB_2_Wanted = LB_2[1055:920];
            end
            'd124: begin
                LB_0_Wanted = LB_0[1063:928];
                LB_1_Wanted = LB_1[1063:928];
                LB_2_Wanted = LB_2[1063:928];
            end
            'd125: begin
                LB_0_Wanted = LB_0[1071:936];
                LB_1_Wanted = LB_1[1071:936];
                LB_2_Wanted = LB_2[1071:936];
            end
            'd126: begin
                LB_0_Wanted = LB_0[1079:944];
                LB_1_Wanted = LB_1[1079:944];
                LB_2_Wanted = LB_2[1079:944];
            end
            'd127: begin
                LB_0_Wanted = LB_0[1087:952];
                LB_1_Wanted = LB_1[1087:952];
                LB_2_Wanted = LB_2[1087:952];
            end
            'd128: begin
                LB_0_Wanted = LB_0[1095:960];
                LB_1_Wanted = LB_1[1095:960];
                LB_2_Wanted = LB_2[1095:960];
            end
            'd129: begin
                LB_0_Wanted = LB_0[1103:968];
                LB_1_Wanted = LB_1[1103:968];
                LB_2_Wanted = LB_2[1103:968];
            end
            'd130: begin
                LB_0_Wanted = LB_0[1111:976];
                LB_1_Wanted = LB_1[1111:976];
                LB_2_Wanted = LB_2[1111:976];
            end
            'd131: begin
                LB_0_Wanted = LB_0[1119:984];
                LB_1_Wanted = LB_1[1119:984];
                LB_2_Wanted = LB_2[1119:984];
            end
            'd132: begin
                LB_0_Wanted = LB_0[1127:992];
                LB_1_Wanted = LB_1[1127:992];
                LB_2_Wanted = LB_2[1127:992];
            end
            'd133: begin
                LB_0_Wanted = LB_0[1135:1000];
                LB_1_Wanted = LB_1[1135:1000];
                LB_2_Wanted = LB_2[1135:1000];
            end
            'd134: begin
                LB_0_Wanted = LB_0[1143:1008];
                LB_1_Wanted = LB_1[1143:1008];
                LB_2_Wanted = LB_2[1143:1008];
            end
            'd135: begin
                LB_0_Wanted = LB_0[1151:1016];
                LB_1_Wanted = LB_1[1151:1016];
                LB_2_Wanted = LB_2[1151:1016];
            end
            'd136: begin
                LB_0_Wanted = LB_0[1159:1024];
                LB_1_Wanted = LB_1[1159:1024];
                LB_2_Wanted = LB_2[1159:1024];
            end
            'd137: begin
                LB_0_Wanted = LB_0[1167:1032];
                LB_1_Wanted = LB_1[1167:1032];
                LB_2_Wanted = LB_2[1167:1032];
            end
            'd138: begin
                LB_0_Wanted = LB_0[1175:1040];
                LB_1_Wanted = LB_1[1175:1040];
                LB_2_Wanted = LB_2[1175:1040];
            end
            'd139: begin
                LB_0_Wanted = LB_0[1183:1048];
                LB_1_Wanted = LB_1[1183:1048];
                LB_2_Wanted = LB_2[1183:1048];
            end
            'd140: begin
                LB_0_Wanted = LB_0[1191:1056];
                LB_1_Wanted = LB_1[1191:1056];
                LB_2_Wanted = LB_2[1191:1056];
            end
            'd141: begin
                LB_0_Wanted = LB_0[1199:1064];
                LB_1_Wanted = LB_1[1199:1064];
                LB_2_Wanted = LB_2[1199:1064];
            end
            'd142: begin
                LB_0_Wanted = LB_0[1207:1072];
                LB_1_Wanted = LB_1[1207:1072];
                LB_2_Wanted = LB_2[1207:1072];
            end
            'd143: begin
                LB_0_Wanted = LB_0[1215:1080];
                LB_1_Wanted = LB_1[1215:1080];
                LB_2_Wanted = LB_2[1215:1080];
            end
            'd144: begin
                LB_0_Wanted = LB_0[1223:1088];
                LB_1_Wanted = LB_1[1223:1088];
                LB_2_Wanted = LB_2[1223:1088];
            end
            'd145: begin
                LB_0_Wanted = LB_0[1231:1096];
                LB_1_Wanted = LB_1[1231:1096];
                LB_2_Wanted = LB_2[1231:1096];
            end
            'd146: begin
                LB_0_Wanted = LB_0[1239:1104];
                LB_1_Wanted = LB_1[1239:1104];
                LB_2_Wanted = LB_2[1239:1104];
            end
            'd147: begin
                LB_0_Wanted = LB_0[1247:1112];
                LB_1_Wanted = LB_1[1247:1112];
                LB_2_Wanted = LB_2[1247:1112];
            end
            'd148: begin
                LB_0_Wanted = LB_0[1255:1120];
                LB_1_Wanted = LB_1[1255:1120];
                LB_2_Wanted = LB_2[1255:1120];
            end
            'd149: begin
                LB_0_Wanted = LB_0[1263:1128];
                LB_1_Wanted = LB_1[1263:1128];
                LB_2_Wanted = LB_2[1263:1128];
            end
            'd150: begin
                LB_0_Wanted = LB_0[1271:1136];
                LB_1_Wanted = LB_1[1271:1136];
                LB_2_Wanted = LB_2[1271:1136];
            end
            'd151: begin
                LB_0_Wanted = LB_0[1279:1144];
                LB_1_Wanted = LB_1[1279:1144];
                LB_2_Wanted = LB_2[1279:1144];
            end
            'd152: begin
                LB_0_Wanted = LB_0[1287:1152];
                LB_1_Wanted = LB_1[1287:1152];
                LB_2_Wanted = LB_2[1287:1152];
            end
            'd153: begin
                LB_0_Wanted = LB_0[1295:1160];
                LB_1_Wanted = LB_1[1295:1160];
                LB_2_Wanted = LB_2[1295:1160];
            end
            'd154: begin
                LB_0_Wanted = LB_0[1303:1168];
                LB_1_Wanted = LB_1[1303:1168];
                LB_2_Wanted = LB_2[1303:1168];
            end
            'd155: begin
                LB_0_Wanted = LB_0[1311:1176];
                LB_1_Wanted = LB_1[1311:1176];
                LB_2_Wanted = LB_2[1311:1176];
            end
            'd156: begin
                LB_0_Wanted = LB_0[1319:1184];
                LB_1_Wanted = LB_1[1319:1184];
                LB_2_Wanted = LB_2[1319:1184];
            end
            'd157: begin
                LB_0_Wanted = LB_0[1327:1192];
                LB_1_Wanted = LB_1[1327:1192];
                LB_2_Wanted = LB_2[1327:1192];
            end
            'd158: begin
                LB_0_Wanted = LB_0[1335:1200];
                LB_1_Wanted = LB_1[1335:1200];
                LB_2_Wanted = LB_2[1335:1200];
            end
            'd159: begin
                LB_0_Wanted = LB_0[1343:1208];
                LB_1_Wanted = LB_1[1343:1208];
                LB_2_Wanted = LB_2[1343:1208];
            end
            'd160: begin
                LB_0_Wanted = LB_0[1351:1216];
                LB_1_Wanted = LB_1[1351:1216];
                LB_2_Wanted = LB_2[1351:1216];
            end
            'd161: begin
                LB_0_Wanted = LB_0[1359:1224];
                LB_1_Wanted = LB_1[1359:1224];
                LB_2_Wanted = LB_2[1359:1224];
            end
            'd162: begin
                LB_0_Wanted = LB_0[1367:1232];
                LB_1_Wanted = LB_1[1367:1232];
                LB_2_Wanted = LB_2[1367:1232];
            end
            'd163: begin
                LB_0_Wanted = LB_0[1375:1240];
                LB_1_Wanted = LB_1[1375:1240];
                LB_2_Wanted = LB_2[1375:1240];
            end
            'd164: begin
                LB_0_Wanted = LB_0[1383:1248];
                LB_1_Wanted = LB_1[1383:1248];
                LB_2_Wanted = LB_2[1383:1248];
            end
            'd165: begin
                LB_0_Wanted = LB_0[1391:1256];
                LB_1_Wanted = LB_1[1391:1256];
                LB_2_Wanted = LB_2[1391:1256];
            end
            'd166: begin
                LB_0_Wanted = LB_0[1399:1264];
                LB_1_Wanted = LB_1[1399:1264];
                LB_2_Wanted = LB_2[1399:1264];
            end
            'd167: begin
                LB_0_Wanted = LB_0[1407:1272];
                LB_1_Wanted = LB_1[1407:1272];
                LB_2_Wanted = LB_2[1407:1272];
            end
            'd168: begin
                LB_0_Wanted = LB_0[1415:1280];
                LB_1_Wanted = LB_1[1415:1280];
                LB_2_Wanted = LB_2[1415:1280];
            end
            'd169: begin
                LB_0_Wanted = LB_0[1423:1288];
                LB_1_Wanted = LB_1[1423:1288];
                LB_2_Wanted = LB_2[1423:1288];
            end
            'd170: begin
                LB_0_Wanted = LB_0[1431:1296];
                LB_1_Wanted = LB_1[1431:1296];
                LB_2_Wanted = LB_2[1431:1296];
            end
            'd171: begin
                LB_0_Wanted = LB_0[1439:1304];
                LB_1_Wanted = LB_1[1439:1304];
                LB_2_Wanted = LB_2[1439:1304];
            end
            'd172: begin
                LB_0_Wanted = LB_0[1447:1312];
                LB_1_Wanted = LB_1[1447:1312];
                LB_2_Wanted = LB_2[1447:1312];
            end
            'd173: begin
                LB_0_Wanted = LB_0[1455:1320];
                LB_1_Wanted = LB_1[1455:1320];
                LB_2_Wanted = LB_2[1455:1320];
            end
            'd174: begin
                LB_0_Wanted = LB_0[1463:1328];
                LB_1_Wanted = LB_1[1463:1328];
                LB_2_Wanted = LB_2[1463:1328];
            end
            'd175: begin
                LB_0_Wanted = LB_0[1471:1336];
                LB_1_Wanted = LB_1[1471:1336];
                LB_2_Wanted = LB_2[1471:1336];
            end
            'd176: begin
                LB_0_Wanted = LB_0[1479:1344];
                LB_1_Wanted = LB_1[1479:1344];
                LB_2_Wanted = LB_2[1479:1344];
            end
            'd177: begin
                LB_0_Wanted = LB_0[1487:1352];
                LB_1_Wanted = LB_1[1487:1352];
                LB_2_Wanted = LB_2[1487:1352];
            end
            'd178: begin
                LB_0_Wanted = LB_0[1495:1360];
                LB_1_Wanted = LB_1[1495:1360];
                LB_2_Wanted = LB_2[1495:1360];
            end
            'd179: begin
                LB_0_Wanted = LB_0[1503:1368];
                LB_1_Wanted = LB_1[1503:1368];
                LB_2_Wanted = LB_2[1503:1368];
            end
            'd180: begin
                LB_0_Wanted = LB_0[1511:1376];
                LB_1_Wanted = LB_1[1511:1376];
                LB_2_Wanted = LB_2[1511:1376];
            end
            'd181: begin
                LB_0_Wanted = LB_0[1519:1384];
                LB_1_Wanted = LB_1[1519:1384];
                LB_2_Wanted = LB_2[1519:1384];
            end
            'd182: begin
                LB_0_Wanted = LB_0[1527:1392];
                LB_1_Wanted = LB_1[1527:1392];
                LB_2_Wanted = LB_2[1527:1392];
            end
            'd183: begin
                LB_0_Wanted = LB_0[1535:1400];
                LB_1_Wanted = LB_1[1535:1400];
                LB_2_Wanted = LB_2[1535:1400];
            end
            'd184: begin
                LB_0_Wanted = LB_0[1543:1408];
                LB_1_Wanted = LB_1[1543:1408];
                LB_2_Wanted = LB_2[1543:1408];
            end
            'd185: begin
                LB_0_Wanted = LB_0[1551:1416];
                LB_1_Wanted = LB_1[1551:1416];
                LB_2_Wanted = LB_2[1551:1416];
            end
            'd186: begin
                LB_0_Wanted = LB_0[1559:1424];
                LB_1_Wanted = LB_1[1559:1424];
                LB_2_Wanted = LB_2[1559:1424];
            end
            'd187: begin
                LB_0_Wanted = LB_0[1567:1432];
                LB_1_Wanted = LB_1[1567:1432];
                LB_2_Wanted = LB_2[1567:1432];
            end
            'd188: begin
                LB_0_Wanted = LB_0[1575:1440];
                LB_1_Wanted = LB_1[1575:1440];
                LB_2_Wanted = LB_2[1575:1440];
            end
            'd189: begin
                LB_0_Wanted = LB_0[1583:1448];
                LB_1_Wanted = LB_1[1583:1448];
                LB_2_Wanted = LB_2[1583:1448];
            end
            'd190: begin
                LB_0_Wanted = LB_0[1591:1456];
                LB_1_Wanted = LB_1[1591:1456];
                LB_2_Wanted = LB_2[1591:1456];
            end
            'd191: begin
                LB_0_Wanted = LB_0[1599:1464];
                LB_1_Wanted = LB_1[1599:1464];
                LB_2_Wanted = LB_2[1599:1464];
            end
            'd192: begin
                LB_0_Wanted = LB_0[1607:1472];
                LB_1_Wanted = LB_1[1607:1472];
                LB_2_Wanted = LB_2[1607:1472];
            end
            'd193: begin
                LB_0_Wanted = LB_0[1615:1480];
                LB_1_Wanted = LB_1[1615:1480];
                LB_2_Wanted = LB_2[1615:1480];
            end
            'd194: begin
                LB_0_Wanted = LB_0[1623:1488];
                LB_1_Wanted = LB_1[1623:1488];
                LB_2_Wanted = LB_2[1623:1488];
            end
            'd195: begin
                LB_0_Wanted = LB_0[1631:1496];
                LB_1_Wanted = LB_1[1631:1496];
                LB_2_Wanted = LB_2[1631:1496];
            end
            'd196: begin
                LB_0_Wanted = LB_0[1639:1504];
                LB_1_Wanted = LB_1[1639:1504];
                LB_2_Wanted = LB_2[1639:1504];
            end
            'd197: begin
                LB_0_Wanted = LB_0[1647:1512];
                LB_1_Wanted = LB_1[1647:1512];
                LB_2_Wanted = LB_2[1647:1512];
            end
            'd198: begin
                LB_0_Wanted = LB_0[1655:1520];
                LB_1_Wanted = LB_1[1655:1520];
                LB_2_Wanted = LB_2[1655:1520];
            end
            'd199: begin
                LB_0_Wanted = LB_0[1663:1528];
                LB_1_Wanted = LB_1[1663:1528];
                LB_2_Wanted = LB_2[1663:1528];
            end
            'd200: begin
                LB_0_Wanted = LB_0[1671:1536];
                LB_1_Wanted = LB_1[1671:1536];
                LB_2_Wanted = LB_2[1671:1536];
            end
            'd201: begin
                LB_0_Wanted = LB_0[1679:1544];
                LB_1_Wanted = LB_1[1679:1544];
                LB_2_Wanted = LB_2[1679:1544];
            end
            'd202: begin
                LB_0_Wanted = LB_0[1687:1552];
                LB_1_Wanted = LB_1[1687:1552];
                LB_2_Wanted = LB_2[1687:1552];
            end
            'd203: begin
                LB_0_Wanted = LB_0[1695:1560];
                LB_1_Wanted = LB_1[1695:1560];
                LB_2_Wanted = LB_2[1695:1560];
            end
            'd204: begin
                LB_0_Wanted = LB_0[1703:1568];
                LB_1_Wanted = LB_1[1703:1568];
                LB_2_Wanted = LB_2[1703:1568];
            end
            'd205: begin
                LB_0_Wanted = LB_0[1711:1576];
                LB_1_Wanted = LB_1[1711:1576];
                LB_2_Wanted = LB_2[1711:1576];
            end
            'd206: begin
                LB_0_Wanted = LB_0[1719:1584];
                LB_1_Wanted = LB_1[1719:1584];
                LB_2_Wanted = LB_2[1719:1584];
            end
            'd207: begin
                LB_0_Wanted = LB_0[1727:1592];
                LB_1_Wanted = LB_1[1727:1592];
                LB_2_Wanted = LB_2[1727:1592];
            end
            'd208: begin
                LB_0_Wanted = LB_0[1735:1600];
                LB_1_Wanted = LB_1[1735:1600];
                LB_2_Wanted = LB_2[1735:1600];
            end
            'd209: begin
                LB_0_Wanted = LB_0[1743:1608];
                LB_1_Wanted = LB_1[1743:1608];
                LB_2_Wanted = LB_2[1743:1608];
            end
            'd210: begin
                LB_0_Wanted = LB_0[1751:1616];
                LB_1_Wanted = LB_1[1751:1616];
                LB_2_Wanted = LB_2[1751:1616];
            end
            'd211: begin
                LB_0_Wanted = LB_0[1759:1624];
                LB_1_Wanted = LB_1[1759:1624];
                LB_2_Wanted = LB_2[1759:1624];
            end
            'd212: begin
                LB_0_Wanted = LB_0[1767:1632];
                LB_1_Wanted = LB_1[1767:1632];
                LB_2_Wanted = LB_2[1767:1632];
            end
            'd213: begin
                LB_0_Wanted = LB_0[1775:1640];
                LB_1_Wanted = LB_1[1775:1640];
                LB_2_Wanted = LB_2[1775:1640];
            end
            'd214: begin
                LB_0_Wanted = LB_0[1783:1648];
                LB_1_Wanted = LB_1[1783:1648];
                LB_2_Wanted = LB_2[1783:1648];
            end
            'd215: begin
                LB_0_Wanted = LB_0[1791:1656];
                LB_1_Wanted = LB_1[1791:1656];
                LB_2_Wanted = LB_2[1791:1656];
            end
            'd216: begin
                LB_0_Wanted = LB_0[1799:1664];
                LB_1_Wanted = LB_1[1799:1664];
                LB_2_Wanted = LB_2[1799:1664];
            end
            'd217: begin
                LB_0_Wanted = LB_0[1807:1672];
                LB_1_Wanted = LB_1[1807:1672];
                LB_2_Wanted = LB_2[1807:1672];
            end
            'd218: begin
                LB_0_Wanted = LB_0[1815:1680];
                LB_1_Wanted = LB_1[1815:1680];
                LB_2_Wanted = LB_2[1815:1680];
            end
            'd219: begin
                LB_0_Wanted = LB_0[1823:1688];
                LB_1_Wanted = LB_1[1823:1688];
                LB_2_Wanted = LB_2[1823:1688];
            end
            'd220: begin
                LB_0_Wanted = LB_0[1831:1696];
                LB_1_Wanted = LB_1[1831:1696];
                LB_2_Wanted = LB_2[1831:1696];
            end
            'd221: begin
                LB_0_Wanted = LB_0[1839:1704];
                LB_1_Wanted = LB_1[1839:1704];
                LB_2_Wanted = LB_2[1839:1704];
            end
            'd222: begin
                LB_0_Wanted = LB_0[1847:1712];
                LB_1_Wanted = LB_1[1847:1712];
                LB_2_Wanted = LB_2[1847:1712];
            end
            'd223: begin
                LB_0_Wanted = LB_0[1855:1720];
                LB_1_Wanted = LB_1[1855:1720];
                LB_2_Wanted = LB_2[1855:1720];
            end
            'd224: begin
                LB_0_Wanted = LB_0[1863:1728];
                LB_1_Wanted = LB_1[1863:1728];
                LB_2_Wanted = LB_2[1863:1728];
            end
            'd225: begin
                LB_0_Wanted = LB_0[1871:1736];
                LB_1_Wanted = LB_1[1871:1736];
                LB_2_Wanted = LB_2[1871:1736];
            end
            'd226: begin
                LB_0_Wanted = LB_0[1879:1744];
                LB_1_Wanted = LB_1[1879:1744];
                LB_2_Wanted = LB_2[1879:1744];
            end
            'd227: begin
                LB_0_Wanted = LB_0[1887:1752];
                LB_1_Wanted = LB_1[1887:1752];
                LB_2_Wanted = LB_2[1887:1752];
            end
            'd228: begin
                LB_0_Wanted = LB_0[1895:1760];
                LB_1_Wanted = LB_1[1895:1760];
                LB_2_Wanted = LB_2[1895:1760];
            end
            'd229: begin
                LB_0_Wanted = LB_0[1903:1768];
                LB_1_Wanted = LB_1[1903:1768];
                LB_2_Wanted = LB_2[1903:1768];
            end
            'd230: begin
                LB_0_Wanted = LB_0[1911:1776];
                LB_1_Wanted = LB_1[1911:1776];
                LB_2_Wanted = LB_2[1911:1776];
            end
            'd231: begin
                LB_0_Wanted = LB_0[1919:1784];
                LB_1_Wanted = LB_1[1919:1784];
                LB_2_Wanted = LB_2[1919:1784];
            end
            'd232: begin
                LB_0_Wanted = LB_0[1927:1792];
                LB_1_Wanted = LB_1[1927:1792];
                LB_2_Wanted = LB_2[1927:1792];
            end
            'd233: begin
                LB_0_Wanted = LB_0[1935:1800];
                LB_1_Wanted = LB_1[1935:1800];
                LB_2_Wanted = LB_2[1935:1800];
            end
            'd234: begin
                LB_0_Wanted = LB_0[1943:1808];
                LB_1_Wanted = LB_1[1943:1808];
                LB_2_Wanted = LB_2[1943:1808];
            end
            'd235: begin
                LB_0_Wanted = LB_0[1951:1816];
                LB_1_Wanted = LB_1[1951:1816];
                LB_2_Wanted = LB_2[1951:1816];
            end
            'd236: begin
                LB_0_Wanted = LB_0[1959:1824];
                LB_1_Wanted = LB_1[1959:1824];
                LB_2_Wanted = LB_2[1959:1824];
            end
            'd237: begin
                LB_0_Wanted = LB_0[1967:1832];
                LB_1_Wanted = LB_1[1967:1832];
                LB_2_Wanted = LB_2[1967:1832];
            end
            'd238: begin
                LB_0_Wanted = LB_0[1975:1840];
                LB_1_Wanted = LB_1[1975:1840];
                LB_2_Wanted = LB_2[1975:1840];
            end
            'd239: begin
                LB_0_Wanted = LB_0[1983:1848];
                LB_1_Wanted = LB_1[1983:1848];
                LB_2_Wanted = LB_2[1983:1848];
            end
            'd240: begin
                LB_0_Wanted = LB_0[1991:1856];
                LB_1_Wanted = LB_1[1991:1856];
                LB_2_Wanted = LB_2[1991:1856];
            end
            'd241: begin
                LB_0_Wanted = LB_0[1999:1864];
                LB_1_Wanted = LB_1[1999:1864];
                LB_2_Wanted = LB_2[1999:1864];
            end
            'd242: begin
                LB_0_Wanted = LB_0[2007:1872];
                LB_1_Wanted = LB_1[2007:1872];
                LB_2_Wanted = LB_2[2007:1872];
            end
            'd243: begin
                LB_0_Wanted = LB_0[2015:1880];
                LB_1_Wanted = LB_1[2015:1880];
                LB_2_Wanted = LB_2[2015:1880];
            end
            'd244: begin
                LB_0_Wanted = LB_0[2023:1888];
                LB_1_Wanted = LB_1[2023:1888];
                LB_2_Wanted = LB_2[2023:1888];
            end
            'd245: begin
                LB_0_Wanted = LB_0[2031:1896];
                LB_1_Wanted = LB_1[2031:1896];
                LB_2_Wanted = LB_2[2031:1896];
            end
            'd246: begin
                LB_0_Wanted = LB_0[2039:1904];
                LB_1_Wanted = LB_1[2039:1904];
                LB_2_Wanted = LB_2[2039:1904];
            end
            'd247: begin
                LB_0_Wanted = LB_0[2047:1912];
                LB_1_Wanted = LB_1[2047:1912];
                LB_2_Wanted = LB_2[2047:1912];
            end
            'd248: begin
                LB_0_Wanted = LB_0[2055:1920];
                LB_1_Wanted = LB_1[2055:1920];
                LB_2_Wanted = LB_2[2055:1920];
            end
            'd249: begin
                LB_0_Wanted = LB_0[2063:1928];
                LB_1_Wanted = LB_1[2063:1928];
                LB_2_Wanted = LB_2[2063:1928];
            end
            'd250: begin
                LB_0_Wanted = LB_0[2071:1936];
                LB_1_Wanted = LB_1[2071:1936];
                LB_2_Wanted = LB_2[2071:1936];
            end
            'd251: begin
                LB_0_Wanted = LB_0[2079:1944];
                LB_1_Wanted = LB_1[2079:1944];
                LB_2_Wanted = LB_2[2079:1944];
            end
            'd252: begin
                LB_0_Wanted = LB_0[2087:1952];
                LB_1_Wanted = LB_1[2087:1952];
                LB_2_Wanted = LB_2[2087:1952];
            end
            'd253: begin
                LB_0_Wanted = LB_0[2095:1960];
                LB_1_Wanted = LB_1[2095:1960];
                LB_2_Wanted = LB_2[2095:1960];
            end
            'd254: begin
                LB_0_Wanted = LB_0[2103:1968];
                LB_1_Wanted = LB_1[2103:1968];
                LB_2_Wanted = LB_2[2103:1968];
            end
            'd255: begin
                LB_0_Wanted = LB_0[2111:1976];
                LB_1_Wanted = LB_1[2111:1976];
                LB_2_Wanted = LB_2[2111:1976];
            end
            'd256: begin
                LB_0_Wanted = LB_0[2119:1984];
                LB_1_Wanted = LB_1[2119:1984];
                LB_2_Wanted = LB_2[2119:1984];
            end
            'd257: begin
                LB_0_Wanted = LB_0[2127:1992];
                LB_1_Wanted = LB_1[2127:1992];
                LB_2_Wanted = LB_2[2127:1992];
            end
            'd258: begin
                LB_0_Wanted = LB_0[2135:2000];
                LB_1_Wanted = LB_1[2135:2000];
                LB_2_Wanted = LB_2[2135:2000];
            end
            'd259: begin
                LB_0_Wanted = LB_0[2143:2008];
                LB_1_Wanted = LB_1[2143:2008];
                LB_2_Wanted = LB_2[2143:2008];
            end
            'd260: begin
                LB_0_Wanted = LB_0[2151:2016];
                LB_1_Wanted = LB_1[2151:2016];
                LB_2_Wanted = LB_2[2151:2016];
            end
            'd261: begin
                LB_0_Wanted = LB_0[2159:2024];
                LB_1_Wanted = LB_1[2159:2024];
                LB_2_Wanted = LB_2[2159:2024];
            end
            'd262: begin
                LB_0_Wanted = LB_0[2167:2032];
                LB_1_Wanted = LB_1[2167:2032];
                LB_2_Wanted = LB_2[2167:2032];
            end
            'd263: begin
                LB_0_Wanted = LB_0[2175:2040];
                LB_1_Wanted = LB_1[2175:2040];
                LB_2_Wanted = LB_2[2175:2040];
            end
            'd264: begin
                LB_0_Wanted = LB_0[2183:2048];
                LB_1_Wanted = LB_1[2183:2048];
                LB_2_Wanted = LB_2[2183:2048];
            end
            'd265: begin
                LB_0_Wanted = LB_0[2191:2056];
                LB_1_Wanted = LB_1[2191:2056];
                LB_2_Wanted = LB_2[2191:2056];
            end
            'd266: begin
                LB_0_Wanted = LB_0[2199:2064];
                LB_1_Wanted = LB_1[2199:2064];
                LB_2_Wanted = LB_2[2199:2064];
            end
            'd267: begin
                LB_0_Wanted = LB_0[2207:2072];
                LB_1_Wanted = LB_1[2207:2072];
                LB_2_Wanted = LB_2[2207:2072];
            end
            'd268: begin
                LB_0_Wanted = LB_0[2215:2080];
                LB_1_Wanted = LB_1[2215:2080];
                LB_2_Wanted = LB_2[2215:2080];
            end
            'd269: begin
                LB_0_Wanted = LB_0[2223:2088];
                LB_1_Wanted = LB_1[2223:2088];
                LB_2_Wanted = LB_2[2223:2088];
            end
            'd270: begin
                LB_0_Wanted = LB_0[2231:2096];
                LB_1_Wanted = LB_1[2231:2096];
                LB_2_Wanted = LB_2[2231:2096];
            end
            'd271: begin
                LB_0_Wanted = LB_0[2239:2104];
                LB_1_Wanted = LB_1[2239:2104];
                LB_2_Wanted = LB_2[2239:2104];
            end
            'd272: begin
                LB_0_Wanted = LB_0[2247:2112];
                LB_1_Wanted = LB_1[2247:2112];
                LB_2_Wanted = LB_2[2247:2112];
            end
            'd273: begin
                LB_0_Wanted = LB_0[2255:2120];
                LB_1_Wanted = LB_1[2255:2120];
                LB_2_Wanted = LB_2[2255:2120];
            end
            'd274: begin
                LB_0_Wanted = LB_0[2263:2128];
                LB_1_Wanted = LB_1[2263:2128];
                LB_2_Wanted = LB_2[2263:2128];
            end
            'd275: begin
                LB_0_Wanted = LB_0[2271:2136];
                LB_1_Wanted = LB_1[2271:2136];
                LB_2_Wanted = LB_2[2271:2136];
            end
            'd276: begin
                LB_0_Wanted = LB_0[2279:2144];
                LB_1_Wanted = LB_1[2279:2144];
                LB_2_Wanted = LB_2[2279:2144];
            end
            'd277: begin
                LB_0_Wanted = LB_0[2287:2152];
                LB_1_Wanted = LB_1[2287:2152];
                LB_2_Wanted = LB_2[2287:2152];
            end
            'd278: begin
                LB_0_Wanted = LB_0[2295:2160];
                LB_1_Wanted = LB_1[2295:2160];
                LB_2_Wanted = LB_2[2295:2160];
            end
            'd279: begin
                LB_0_Wanted = LB_0[2303:2168];
                LB_1_Wanted = LB_1[2303:2168];
                LB_2_Wanted = LB_2[2303:2168];
            end
            'd280: begin
                LB_0_Wanted = LB_0[2311:2176];
                LB_1_Wanted = LB_1[2311:2176];
                LB_2_Wanted = LB_2[2311:2176];
            end
            'd281: begin
                LB_0_Wanted = LB_0[2319:2184];
                LB_1_Wanted = LB_1[2319:2184];
                LB_2_Wanted = LB_2[2319:2184];
            end
            'd282: begin
                LB_0_Wanted = LB_0[2327:2192];
                LB_1_Wanted = LB_1[2327:2192];
                LB_2_Wanted = LB_2[2327:2192];
            end
            'd283: begin
                LB_0_Wanted = LB_0[2335:2200];
                LB_1_Wanted = LB_1[2335:2200];
                LB_2_Wanted = LB_2[2335:2200];
            end
            'd284: begin
                LB_0_Wanted = LB_0[2343:2208];
                LB_1_Wanted = LB_1[2343:2208];
                LB_2_Wanted = LB_2[2343:2208];
            end
            'd285: begin
                LB_0_Wanted = LB_0[2351:2216];
                LB_1_Wanted = LB_1[2351:2216];
                LB_2_Wanted = LB_2[2351:2216];
            end
            'd286: begin
                LB_0_Wanted = LB_0[2359:2224];
                LB_1_Wanted = LB_1[2359:2224];
                LB_2_Wanted = LB_2[2359:2224];
            end
            'd287: begin
                LB_0_Wanted = LB_0[2367:2232];
                LB_1_Wanted = LB_1[2367:2232];
                LB_2_Wanted = LB_2[2367:2232];
            end
            'd288: begin
                LB_0_Wanted = LB_0[2375:2240];
                LB_1_Wanted = LB_1[2375:2240];
                LB_2_Wanted = LB_2[2375:2240];
            end
            'd289: begin
                LB_0_Wanted = LB_0[2383:2248];
                LB_1_Wanted = LB_1[2383:2248];
                LB_2_Wanted = LB_2[2383:2248];
            end
            'd290: begin
                LB_0_Wanted = LB_0[2391:2256];
                LB_1_Wanted = LB_1[2391:2256];
                LB_2_Wanted = LB_2[2391:2256];
            end
            'd291: begin
                LB_0_Wanted = LB_0[2399:2264];
                LB_1_Wanted = LB_1[2399:2264];
                LB_2_Wanted = LB_2[2399:2264];
            end
            'd292: begin
                LB_0_Wanted = LB_0[2407:2272];
                LB_1_Wanted = LB_1[2407:2272];
                LB_2_Wanted = LB_2[2407:2272];
            end
            'd293: begin
                LB_0_Wanted = LB_0[2415:2280];
                LB_1_Wanted = LB_1[2415:2280];
                LB_2_Wanted = LB_2[2415:2280];
            end
            'd294: begin
                LB_0_Wanted = LB_0[2423:2288];
                LB_1_Wanted = LB_1[2423:2288];
                LB_2_Wanted = LB_2[2423:2288];
            end
            'd295: begin
                LB_0_Wanted = LB_0[2431:2296];
                LB_1_Wanted = LB_1[2431:2296];
                LB_2_Wanted = LB_2[2431:2296];
            end
            'd296: begin
                LB_0_Wanted = LB_0[2439:2304];
                LB_1_Wanted = LB_1[2439:2304];
                LB_2_Wanted = LB_2[2439:2304];
            end
            'd297: begin
                LB_0_Wanted = LB_0[2447:2312];
                LB_1_Wanted = LB_1[2447:2312];
                LB_2_Wanted = LB_2[2447:2312];
            end
            'd298: begin
                LB_0_Wanted = LB_0[2455:2320];
                LB_1_Wanted = LB_1[2455:2320];
                LB_2_Wanted = LB_2[2455:2320];
            end
            'd299: begin
                LB_0_Wanted = LB_0[2463:2328];
                LB_1_Wanted = LB_1[2463:2328];
                LB_2_Wanted = LB_2[2463:2328];
            end
            'd300: begin
                LB_0_Wanted = LB_0[2471:2336];
                LB_1_Wanted = LB_1[2471:2336];
                LB_2_Wanted = LB_2[2471:2336];
            end
            'd301: begin
                LB_0_Wanted = LB_0[2479:2344];
                LB_1_Wanted = LB_1[2479:2344];
                LB_2_Wanted = LB_2[2479:2344];
            end
            'd302: begin
                LB_0_Wanted = LB_0[2487:2352];
                LB_1_Wanted = LB_1[2487:2352];
                LB_2_Wanted = LB_2[2487:2352];
            end
            'd303: begin
                LB_0_Wanted = LB_0[2495:2360];
                LB_1_Wanted = LB_1[2495:2360];
                LB_2_Wanted = LB_2[2495:2360];
            end
            'd304: begin
                LB_0_Wanted = LB_0[2503:2368];
                LB_1_Wanted = LB_1[2503:2368];
                LB_2_Wanted = LB_2[2503:2368];
            end
            'd305: begin
                LB_0_Wanted = LB_0[2511:2376];
                LB_1_Wanted = LB_1[2511:2376];
                LB_2_Wanted = LB_2[2511:2376];
            end
            'd306: begin
                LB_0_Wanted = LB_0[2519:2384];
                LB_1_Wanted = LB_1[2519:2384];
                LB_2_Wanted = LB_2[2519:2384];
            end
            'd307: begin
                LB_0_Wanted = LB_0[2527:2392];
                LB_1_Wanted = LB_1[2527:2392];
                LB_2_Wanted = LB_2[2527:2392];
            end
            'd308: begin
                LB_0_Wanted = LB_0[2535:2400];
                LB_1_Wanted = LB_1[2535:2400];
                LB_2_Wanted = LB_2[2535:2400];
            end
            'd309: begin
                LB_0_Wanted = LB_0[2543:2408];
                LB_1_Wanted = LB_1[2543:2408];
                LB_2_Wanted = LB_2[2543:2408];
            end
            'd310: begin
                LB_0_Wanted = LB_0[2551:2416];
                LB_1_Wanted = LB_1[2551:2416];
                LB_2_Wanted = LB_2[2551:2416];
            end
            'd311: begin
                LB_0_Wanted = LB_0[2559:2424];
                LB_1_Wanted = LB_1[2559:2424];
                LB_2_Wanted = LB_2[2559:2424];
            end
            'd312: begin
                LB_0_Wanted = LB_0[2567:2432];
                LB_1_Wanted = LB_1[2567:2432];
                LB_2_Wanted = LB_2[2567:2432];
            end
            'd313: begin
                LB_0_Wanted = LB_0[2575:2440];
                LB_1_Wanted = LB_1[2575:2440];
                LB_2_Wanted = LB_2[2575:2440];
            end
            'd314: begin
                LB_0_Wanted = LB_0[2583:2448];
                LB_1_Wanted = LB_1[2583:2448];
                LB_2_Wanted = LB_2[2583:2448];
            end
            'd315: begin
                LB_0_Wanted = LB_0[2591:2456];
                LB_1_Wanted = LB_1[2591:2456];
                LB_2_Wanted = LB_2[2591:2456];
            end
            'd316: begin
                LB_0_Wanted = LB_0[2599:2464];
                LB_1_Wanted = LB_1[2599:2464];
                LB_2_Wanted = LB_2[2599:2464];
            end
            'd317: begin
                LB_0_Wanted = LB_0[2607:2472];
                LB_1_Wanted = LB_1[2607:2472];
                LB_2_Wanted = LB_2[2607:2472];
            end
            'd318: begin
                LB_0_Wanted = LB_0[2615:2480];
                LB_1_Wanted = LB_1[2615:2480];
                LB_2_Wanted = LB_2[2615:2480];
            end
            'd319: begin
                LB_0_Wanted = LB_0[2623:2488];
                LB_1_Wanted = LB_1[2623:2488];
                LB_2_Wanted = LB_2[2623:2488];
            end
            'd320: begin
                LB_0_Wanted = LB_0[2631:2496];
                LB_1_Wanted = LB_1[2631:2496];
                LB_2_Wanted = LB_2[2631:2496];
            end
            'd321: begin
                LB_0_Wanted = LB_0[2639:2504];
                LB_1_Wanted = LB_1[2639:2504];
                LB_2_Wanted = LB_2[2639:2504];
            end
            'd322: begin
                LB_0_Wanted = LB_0[2647:2512];
                LB_1_Wanted = LB_1[2647:2512];
                LB_2_Wanted = LB_2[2647:2512];
            end
            'd323: begin
                LB_0_Wanted = LB_0[2655:2520];
                LB_1_Wanted = LB_1[2655:2520];
                LB_2_Wanted = LB_2[2655:2520];
            end
            'd324: begin
                LB_0_Wanted = LB_0[2663:2528];
                LB_1_Wanted = LB_1[2663:2528];
                LB_2_Wanted = LB_2[2663:2528];
            end
            'd325: begin
                LB_0_Wanted = LB_0[2671:2536];
                LB_1_Wanted = LB_1[2671:2536];
                LB_2_Wanted = LB_2[2671:2536];
            end
            'd326: begin
                LB_0_Wanted = LB_0[2679:2544];
                LB_1_Wanted = LB_1[2679:2544];
                LB_2_Wanted = LB_2[2679:2544];
            end
            'd327: begin
                LB_0_Wanted = LB_0[2687:2552];
                LB_1_Wanted = LB_1[2687:2552];
                LB_2_Wanted = LB_2[2687:2552];
            end
            'd328: begin
                LB_0_Wanted = LB_0[2695:2560];
                LB_1_Wanted = LB_1[2695:2560];
                LB_2_Wanted = LB_2[2695:2560];
            end
            'd329: begin
                LB_0_Wanted = LB_0[2703:2568];
                LB_1_Wanted = LB_1[2703:2568];
                LB_2_Wanted = LB_2[2703:2568];
            end
            'd330: begin
                LB_0_Wanted = LB_0[2711:2576];
                LB_1_Wanted = LB_1[2711:2576];
                LB_2_Wanted = LB_2[2711:2576];
            end
            'd331: begin
                LB_0_Wanted = LB_0[2719:2584];
                LB_1_Wanted = LB_1[2719:2584];
                LB_2_Wanted = LB_2[2719:2584];
            end
            'd332: begin
                LB_0_Wanted = LB_0[2727:2592];
                LB_1_Wanted = LB_1[2727:2592];
                LB_2_Wanted = LB_2[2727:2592];
            end
            'd333: begin
                LB_0_Wanted = LB_0[2735:2600];
                LB_1_Wanted = LB_1[2735:2600];
                LB_2_Wanted = LB_2[2735:2600];
            end
            'd334: begin
                LB_0_Wanted = LB_0[2743:2608];
                LB_1_Wanted = LB_1[2743:2608];
                LB_2_Wanted = LB_2[2743:2608];
            end
            'd335: begin
                LB_0_Wanted = LB_0[2751:2616];
                LB_1_Wanted = LB_1[2751:2616];
                LB_2_Wanted = LB_2[2751:2616];
            end
            'd336: begin
                LB_0_Wanted = LB_0[2759:2624];
                LB_1_Wanted = LB_1[2759:2624];
                LB_2_Wanted = LB_2[2759:2624];
            end
            'd337: begin
                LB_0_Wanted = LB_0[2767:2632];
                LB_1_Wanted = LB_1[2767:2632];
                LB_2_Wanted = LB_2[2767:2632];
            end
            'd338: begin
                LB_0_Wanted = LB_0[2775:2640];
                LB_1_Wanted = LB_1[2775:2640];
                LB_2_Wanted = LB_2[2775:2640];
            end
            'd339: begin
                LB_0_Wanted = LB_0[2783:2648];
                LB_1_Wanted = LB_1[2783:2648];
                LB_2_Wanted = LB_2[2783:2648];
            end
            'd340: begin
                LB_0_Wanted = LB_0[2791:2656];
                LB_1_Wanted = LB_1[2791:2656];
                LB_2_Wanted = LB_2[2791:2656];
            end
            'd341: begin
                LB_0_Wanted = LB_0[2799:2664];
                LB_1_Wanted = LB_1[2799:2664];
                LB_2_Wanted = LB_2[2799:2664];
            end
            'd342: begin
                LB_0_Wanted = LB_0[2807:2672];
                LB_1_Wanted = LB_1[2807:2672];
                LB_2_Wanted = LB_2[2807:2672];
            end
            'd343: begin
                LB_0_Wanted = LB_0[2815:2680];
                LB_1_Wanted = LB_1[2815:2680];
                LB_2_Wanted = LB_2[2815:2680];
            end
            'd344: begin
                LB_0_Wanted = LB_0[2823:2688];
                LB_1_Wanted = LB_1[2823:2688];
                LB_2_Wanted = LB_2[2823:2688];
            end
            'd345: begin
                LB_0_Wanted = LB_0[2831:2696];
                LB_1_Wanted = LB_1[2831:2696];
                LB_2_Wanted = LB_2[2831:2696];
            end
            'd346: begin
                LB_0_Wanted = LB_0[2839:2704];
                LB_1_Wanted = LB_1[2839:2704];
                LB_2_Wanted = LB_2[2839:2704];
            end
            'd347: begin
                LB_0_Wanted = LB_0[2847:2712];
                LB_1_Wanted = LB_1[2847:2712];
                LB_2_Wanted = LB_2[2847:2712];
            end
            'd348: begin
                LB_0_Wanted = LB_0[2855:2720];
                LB_1_Wanted = LB_1[2855:2720];
                LB_2_Wanted = LB_2[2855:2720];
            end
            'd349: begin
                LB_0_Wanted = LB_0[2863:2728];
                LB_1_Wanted = LB_1[2863:2728];
                LB_2_Wanted = LB_2[2863:2728];
            end
            'd350: begin
                LB_0_Wanted = LB_0[2871:2736];
                LB_1_Wanted = LB_1[2871:2736];
                LB_2_Wanted = LB_2[2871:2736];
            end
            'd351: begin
                LB_0_Wanted = LB_0[2879:2744];
                LB_1_Wanted = LB_1[2879:2744];
                LB_2_Wanted = LB_2[2879:2744];
            end
            'd352: begin
                LB_0_Wanted = LB_0[2887:2752];
                LB_1_Wanted = LB_1[2887:2752];
                LB_2_Wanted = LB_2[2887:2752];
            end
            'd353: begin
                LB_0_Wanted = LB_0[2895:2760];
                LB_1_Wanted = LB_1[2895:2760];
                LB_2_Wanted = LB_2[2895:2760];
            end
            'd354: begin
                LB_0_Wanted = LB_0[2903:2768];
                LB_1_Wanted = LB_1[2903:2768];
                LB_2_Wanted = LB_2[2903:2768];
            end
            'd355: begin
                LB_0_Wanted = LB_0[2911:2776];
                LB_1_Wanted = LB_1[2911:2776];
                LB_2_Wanted = LB_2[2911:2776];
            end
            'd356: begin
                LB_0_Wanted = LB_0[2919:2784];
                LB_1_Wanted = LB_1[2919:2784];
                LB_2_Wanted = LB_2[2919:2784];
            end
            'd357: begin
                LB_0_Wanted = LB_0[2927:2792];
                LB_1_Wanted = LB_1[2927:2792];
                LB_2_Wanted = LB_2[2927:2792];
            end
            'd358: begin
                LB_0_Wanted = LB_0[2935:2800];
                LB_1_Wanted = LB_1[2935:2800];
                LB_2_Wanted = LB_2[2935:2800];
            end
            'd359: begin
                LB_0_Wanted = LB_0[2943:2808];
                LB_1_Wanted = LB_1[2943:2808];
                LB_2_Wanted = LB_2[2943:2808];
            end
            'd360: begin
                LB_0_Wanted = LB_0[2951:2816];
                LB_1_Wanted = LB_1[2951:2816];
                LB_2_Wanted = LB_2[2951:2816];
            end
            'd361: begin
                LB_0_Wanted = LB_0[2959:2824];
                LB_1_Wanted = LB_1[2959:2824];
                LB_2_Wanted = LB_2[2959:2824];
            end
            'd362: begin
                LB_0_Wanted = LB_0[2967:2832];
                LB_1_Wanted = LB_1[2967:2832];
                LB_2_Wanted = LB_2[2967:2832];
            end
            'd363: begin
                LB_0_Wanted = LB_0[2975:2840];
                LB_1_Wanted = LB_1[2975:2840];
                LB_2_Wanted = LB_2[2975:2840];
            end
            'd364: begin
                LB_0_Wanted = LB_0[2983:2848];
                LB_1_Wanted = LB_1[2983:2848];
                LB_2_Wanted = LB_2[2983:2848];
            end
            'd365: begin
                LB_0_Wanted = LB_0[2991:2856];
                LB_1_Wanted = LB_1[2991:2856];
                LB_2_Wanted = LB_2[2991:2856];
            end
            'd366: begin
                LB_0_Wanted = LB_0[2999:2864];
                LB_1_Wanted = LB_1[2999:2864];
                LB_2_Wanted = LB_2[2999:2864];
            end
            'd367: begin
                LB_0_Wanted = LB_0[3007:2872];
                LB_1_Wanted = LB_1[3007:2872];
                LB_2_Wanted = LB_2[3007:2872];
            end
            'd368: begin
                LB_0_Wanted = LB_0[3015:2880];
                LB_1_Wanted = LB_1[3015:2880];
                LB_2_Wanted = LB_2[3015:2880];
            end
            'd369: begin
                LB_0_Wanted = LB_0[3023:2888];
                LB_1_Wanted = LB_1[3023:2888];
                LB_2_Wanted = LB_2[3023:2888];
            end
            'd370: begin
                LB_0_Wanted = LB_0[3031:2896];
                LB_1_Wanted = LB_1[3031:2896];
                LB_2_Wanted = LB_2[3031:2896];
            end
            'd371: begin
                LB_0_Wanted = LB_0[3039:2904];
                LB_1_Wanted = LB_1[3039:2904];
                LB_2_Wanted = LB_2[3039:2904];
            end
            'd372: begin
                LB_0_Wanted = LB_0[3047:2912];
                LB_1_Wanted = LB_1[3047:2912];
                LB_2_Wanted = LB_2[3047:2912];
            end
            'd373: begin
                LB_0_Wanted = LB_0[3055:2920];
                LB_1_Wanted = LB_1[3055:2920];
                LB_2_Wanted = LB_2[3055:2920];
            end
            'd374: begin
                LB_0_Wanted = LB_0[3063:2928];
                LB_1_Wanted = LB_1[3063:2928];
                LB_2_Wanted = LB_2[3063:2928];
            end
            'd375: begin
                LB_0_Wanted = LB_0[3071:2936];
                LB_1_Wanted = LB_1[3071:2936];
                LB_2_Wanted = LB_2[3071:2936];
            end
            'd376: begin
                LB_0_Wanted = LB_0[3079:2944];
                LB_1_Wanted = LB_1[3079:2944];
                LB_2_Wanted = LB_2[3079:2944];
            end
            'd377: begin
                LB_0_Wanted = LB_0[3087:2952];
                LB_1_Wanted = LB_1[3087:2952];
                LB_2_Wanted = LB_2[3087:2952];
            end
            'd378: begin
                LB_0_Wanted = LB_0[3095:2960];
                LB_1_Wanted = LB_1[3095:2960];
                LB_2_Wanted = LB_2[3095:2960];
            end
            'd379: begin
                LB_0_Wanted = LB_0[3103:2968];
                LB_1_Wanted = LB_1[3103:2968];
                LB_2_Wanted = LB_2[3103:2968];
            end
            'd380: begin
                LB_0_Wanted = LB_0[3111:2976];
                LB_1_Wanted = LB_1[3111:2976];
                LB_2_Wanted = LB_2[3111:2976];
            end
            'd381: begin
                LB_0_Wanted = LB_0[3119:2984];
                LB_1_Wanted = LB_1[3119:2984];
                LB_2_Wanted = LB_2[3119:2984];
            end
            'd382: begin
                LB_0_Wanted = LB_0[3127:2992];
                LB_1_Wanted = LB_1[3127:2992];
                LB_2_Wanted = LB_2[3127:2992];
            end
            'd383: begin
                LB_0_Wanted = LB_0[3135:3000];
                LB_1_Wanted = LB_1[3135:3000];
                LB_2_Wanted = LB_2[3135:3000];
            end
            'd384: begin
                LB_0_Wanted = LB_0[3143:3008];
                LB_1_Wanted = LB_1[3143:3008];
                LB_2_Wanted = LB_2[3143:3008];
            end
            'd385: begin
                LB_0_Wanted = LB_0[3151:3016];
                LB_1_Wanted = LB_1[3151:3016];
                LB_2_Wanted = LB_2[3151:3016];
            end
            'd386: begin
                LB_0_Wanted = LB_0[3159:3024];
                LB_1_Wanted = LB_1[3159:3024];
                LB_2_Wanted = LB_2[3159:3024];
            end
            'd387: begin
                LB_0_Wanted = LB_0[3167:3032];
                LB_1_Wanted = LB_1[3167:3032];
                LB_2_Wanted = LB_2[3167:3032];
            end
            'd388: begin
                LB_0_Wanted = LB_0[3175:3040];
                LB_1_Wanted = LB_1[3175:3040];
                LB_2_Wanted = LB_2[3175:3040];
            end
            'd389: begin
                LB_0_Wanted = LB_0[3183:3048];
                LB_1_Wanted = LB_1[3183:3048];
                LB_2_Wanted = LB_2[3183:3048];
            end
            'd390: begin
                LB_0_Wanted = LB_0[3191:3056];
                LB_1_Wanted = LB_1[3191:3056];
                LB_2_Wanted = LB_2[3191:3056];
            end
            'd391: begin
                LB_0_Wanted = LB_0[3199:3064];
                LB_1_Wanted = LB_1[3199:3064];
                LB_2_Wanted = LB_2[3199:3064];
            end
            'd392: begin
                LB_0_Wanted = LB_0[3207:3072];
                LB_1_Wanted = LB_1[3207:3072];
                LB_2_Wanted = LB_2[3207:3072];
            end
            'd393: begin
                LB_0_Wanted = LB_0[3215:3080];
                LB_1_Wanted = LB_1[3215:3080];
                LB_2_Wanted = LB_2[3215:3080];
            end
            'd394: begin
                LB_0_Wanted = LB_0[3223:3088];
                LB_1_Wanted = LB_1[3223:3088];
                LB_2_Wanted = LB_2[3223:3088];
            end
            'd395: begin
                LB_0_Wanted = LB_0[3231:3096];
                LB_1_Wanted = LB_1[3231:3096];
                LB_2_Wanted = LB_2[3231:3096];
            end
            'd396: begin
                LB_0_Wanted = LB_0[3239:3104];
                LB_1_Wanted = LB_1[3239:3104];
                LB_2_Wanted = LB_2[3239:3104];
            end
            'd397: begin
                LB_0_Wanted = LB_0[3247:3112];
                LB_1_Wanted = LB_1[3247:3112];
                LB_2_Wanted = LB_2[3247:3112];
            end
            'd398: begin
                LB_0_Wanted = LB_0[3255:3120];
                LB_1_Wanted = LB_1[3255:3120];
                LB_2_Wanted = LB_2[3255:3120];
            end
            'd399: begin
                LB_0_Wanted = LB_0[3263:3128];
                LB_1_Wanted = LB_1[3263:3128];
                LB_2_Wanted = LB_2[3263:3128];
            end
            'd400: begin
                LB_0_Wanted = LB_0[3271:3136];
                LB_1_Wanted = LB_1[3271:3136];
                LB_2_Wanted = LB_2[3271:3136];
            end
            'd401: begin
                LB_0_Wanted = LB_0[3279:3144];
                LB_1_Wanted = LB_1[3279:3144];
                LB_2_Wanted = LB_2[3279:3144];
            end
            'd402: begin
                LB_0_Wanted = LB_0[3287:3152];
                LB_1_Wanted = LB_1[3287:3152];
                LB_2_Wanted = LB_2[3287:3152];
            end
            'd403: begin
                LB_0_Wanted = LB_0[3295:3160];
                LB_1_Wanted = LB_1[3295:3160];
                LB_2_Wanted = LB_2[3295:3160];
            end
            'd404: begin
                LB_0_Wanted = LB_0[3303:3168];
                LB_1_Wanted = LB_1[3303:3168];
                LB_2_Wanted = LB_2[3303:3168];
            end
            'd405: begin
                LB_0_Wanted = LB_0[3311:3176];
                LB_1_Wanted = LB_1[3311:3176];
                LB_2_Wanted = LB_2[3311:3176];
            end
            'd406: begin
                LB_0_Wanted = LB_0[3319:3184];
                LB_1_Wanted = LB_1[3319:3184];
                LB_2_Wanted = LB_2[3319:3184];
            end
            'd407: begin
                LB_0_Wanted = LB_0[3327:3192];
                LB_1_Wanted = LB_1[3327:3192];
                LB_2_Wanted = LB_2[3327:3192];
            end
            'd408: begin
                LB_0_Wanted = LB_0[3335:3200];
                LB_1_Wanted = LB_1[3335:3200];
                LB_2_Wanted = LB_2[3335:3200];
            end
            'd409: begin
                LB_0_Wanted = LB_0[3343:3208];
                LB_1_Wanted = LB_1[3343:3208];
                LB_2_Wanted = LB_2[3343:3208];
            end
            'd410: begin
                LB_0_Wanted = LB_0[3351:3216];
                LB_1_Wanted = LB_1[3351:3216];
                LB_2_Wanted = LB_2[3351:3216];
            end
            'd411: begin
                LB_0_Wanted = LB_0[3359:3224];
                LB_1_Wanted = LB_1[3359:3224];
                LB_2_Wanted = LB_2[3359:3224];
            end
            'd412: begin
                LB_0_Wanted = LB_0[3367:3232];
                LB_1_Wanted = LB_1[3367:3232];
                LB_2_Wanted = LB_2[3367:3232];
            end
            'd413: begin
                LB_0_Wanted = LB_0[3375:3240];
                LB_1_Wanted = LB_1[3375:3240];
                LB_2_Wanted = LB_2[3375:3240];
            end
            'd414: begin
                LB_0_Wanted = LB_0[3383:3248];
                LB_1_Wanted = LB_1[3383:3248];
                LB_2_Wanted = LB_2[3383:3248];
            end
            'd415: begin
                LB_0_Wanted = LB_0[3391:3256];
                LB_1_Wanted = LB_1[3391:3256];
                LB_2_Wanted = LB_2[3391:3256];
            end
            'd416: begin
                LB_0_Wanted = LB_0[3399:3264];
                LB_1_Wanted = LB_1[3399:3264];
                LB_2_Wanted = LB_2[3399:3264];
            end
            'd417: begin
                LB_0_Wanted = LB_0[3407:3272];
                LB_1_Wanted = LB_1[3407:3272];
                LB_2_Wanted = LB_2[3407:3272];
            end
            'd418: begin
                LB_0_Wanted = LB_0[3415:3280];
                LB_1_Wanted = LB_1[3415:3280];
                LB_2_Wanted = LB_2[3415:3280];
            end
            'd419: begin
                LB_0_Wanted = LB_0[3423:3288];
                LB_1_Wanted = LB_1[3423:3288];
                LB_2_Wanted = LB_2[3423:3288];
            end
            'd420: begin
                LB_0_Wanted = LB_0[3431:3296];
                LB_1_Wanted = LB_1[3431:3296];
                LB_2_Wanted = LB_2[3431:3296];
            end
            'd421: begin
                LB_0_Wanted = LB_0[3439:3304];
                LB_1_Wanted = LB_1[3439:3304];
                LB_2_Wanted = LB_2[3439:3304];
            end
            'd422: begin
                LB_0_Wanted = LB_0[3447:3312];
                LB_1_Wanted = LB_1[3447:3312];
                LB_2_Wanted = LB_2[3447:3312];
            end
            'd423: begin
                LB_0_Wanted = LB_0[3455:3320];
                LB_1_Wanted = LB_1[3455:3320];
                LB_2_Wanted = LB_2[3455:3320];
            end
            'd424: begin
                LB_0_Wanted = LB_0[3463:3328];
                LB_1_Wanted = LB_1[3463:3328];
                LB_2_Wanted = LB_2[3463:3328];
            end
            'd425: begin
                LB_0_Wanted = LB_0[3471:3336];
                LB_1_Wanted = LB_1[3471:3336];
                LB_2_Wanted = LB_2[3471:3336];
            end
            'd426: begin
                LB_0_Wanted = LB_0[3479:3344];
                LB_1_Wanted = LB_1[3479:3344];
                LB_2_Wanted = LB_2[3479:3344];
            end
            'd427: begin
                LB_0_Wanted = LB_0[3487:3352];
                LB_1_Wanted = LB_1[3487:3352];
                LB_2_Wanted = LB_2[3487:3352];
            end
            'd428: begin
                LB_0_Wanted = LB_0[3495:3360];
                LB_1_Wanted = LB_1[3495:3360];
                LB_2_Wanted = LB_2[3495:3360];
            end
            'd429: begin
                LB_0_Wanted = LB_0[3503:3368];
                LB_1_Wanted = LB_1[3503:3368];
                LB_2_Wanted = LB_2[3503:3368];
            end
            'd430: begin
                LB_0_Wanted = LB_0[3511:3376];
                LB_1_Wanted = LB_1[3511:3376];
                LB_2_Wanted = LB_2[3511:3376];
            end
            'd431: begin
                LB_0_Wanted = LB_0[3519:3384];
                LB_1_Wanted = LB_1[3519:3384];
                LB_2_Wanted = LB_2[3519:3384];
            end
            'd432: begin
                LB_0_Wanted = LB_0[3527:3392];
                LB_1_Wanted = LB_1[3527:3392];
                LB_2_Wanted = LB_2[3527:3392];
            end
            'd433: begin
                LB_0_Wanted = LB_0[3535:3400];
                LB_1_Wanted = LB_1[3535:3400];
                LB_2_Wanted = LB_2[3535:3400];
            end
            'd434: begin
                LB_0_Wanted = LB_0[3543:3408];
                LB_1_Wanted = LB_1[3543:3408];
                LB_2_Wanted = LB_2[3543:3408];
            end
            'd435: begin
                LB_0_Wanted = LB_0[3551:3416];
                LB_1_Wanted = LB_1[3551:3416];
                LB_2_Wanted = LB_2[3551:3416];
            end
            'd436: begin
                LB_0_Wanted = LB_0[3559:3424];
                LB_1_Wanted = LB_1[3559:3424];
                LB_2_Wanted = LB_2[3559:3424];
            end
            'd437: begin
                LB_0_Wanted = LB_0[3567:3432];
                LB_1_Wanted = LB_1[3567:3432];
                LB_2_Wanted = LB_2[3567:3432];
            end
            'd438: begin
                LB_0_Wanted = LB_0[3575:3440];
                LB_1_Wanted = LB_1[3575:3440];
                LB_2_Wanted = LB_2[3575:3440];
            end
            'd439: begin
                LB_0_Wanted = LB_0[3583:3448];
                LB_1_Wanted = LB_1[3583:3448];
                LB_2_Wanted = LB_2[3583:3448];
            end
            'd440: begin
                LB_0_Wanted = LB_0[3591:3456];
                LB_1_Wanted = LB_1[3591:3456];
                LB_2_Wanted = LB_2[3591:3456];
            end
            'd441: begin
                LB_0_Wanted = LB_0[3599:3464];
                LB_1_Wanted = LB_1[3599:3464];
                LB_2_Wanted = LB_2[3599:3464];
            end
            'd442: begin
                LB_0_Wanted = LB_0[3607:3472];
                LB_1_Wanted = LB_1[3607:3472];
                LB_2_Wanted = LB_2[3607:3472];
            end
            'd443: begin
                LB_0_Wanted = LB_0[3615:3480];
                LB_1_Wanted = LB_1[3615:3480];
                LB_2_Wanted = LB_2[3615:3480];
            end
            'd444: begin
                LB_0_Wanted = LB_0[3623:3488];
                LB_1_Wanted = LB_1[3623:3488];
                LB_2_Wanted = LB_2[3623:3488];
            end
            'd445: begin
                LB_0_Wanted = LB_0[3631:3496];
                LB_1_Wanted = LB_1[3631:3496];
                LB_2_Wanted = LB_2[3631:3496];
            end
            'd446: begin
                LB_0_Wanted = LB_0[3639:3504];
                LB_1_Wanted = LB_1[3639:3504];
                LB_2_Wanted = LB_2[3639:3504];
            end
            'd447: begin
                LB_0_Wanted = LB_0[3647:3512];
                LB_1_Wanted = LB_1[3647:3512];
                LB_2_Wanted = LB_2[3647:3512];
            end
            'd448: begin
                LB_0_Wanted = LB_0[3655:3520];
                LB_1_Wanted = LB_1[3655:3520];
                LB_2_Wanted = LB_2[3655:3520];
            end
            'd449: begin
                LB_0_Wanted = LB_0[3663:3528];
                LB_1_Wanted = LB_1[3663:3528];
                LB_2_Wanted = LB_2[3663:3528];
            end
            'd450: begin
                LB_0_Wanted = LB_0[3671:3536];
                LB_1_Wanted = LB_1[3671:3536];
                LB_2_Wanted = LB_2[3671:3536];
            end
            'd451: begin
                LB_0_Wanted = LB_0[3679:3544];
                LB_1_Wanted = LB_1[3679:3544];
                LB_2_Wanted = LB_2[3679:3544];
            end
            'd452: begin
                LB_0_Wanted = LB_0[3687:3552];
                LB_1_Wanted = LB_1[3687:3552];
                LB_2_Wanted = LB_2[3687:3552];
            end
            'd453: begin
                LB_0_Wanted = LB_0[3695:3560];
                LB_1_Wanted = LB_1[3695:3560];
                LB_2_Wanted = LB_2[3695:3560];
            end
            'd454: begin
                LB_0_Wanted = LB_0[3703:3568];
                LB_1_Wanted = LB_1[3703:3568];
                LB_2_Wanted = LB_2[3703:3568];
            end
            'd455: begin
                LB_0_Wanted = LB_0[3711:3576];
                LB_1_Wanted = LB_1[3711:3576];
                LB_2_Wanted = LB_2[3711:3576];
            end
            'd456: begin
                LB_0_Wanted = LB_0[3719:3584];
                LB_1_Wanted = LB_1[3719:3584];
                LB_2_Wanted = LB_2[3719:3584];
            end
            'd457: begin
                LB_0_Wanted = LB_0[3727:3592];
                LB_1_Wanted = LB_1[3727:3592];
                LB_2_Wanted = LB_2[3727:3592];
            end
            'd458: begin
                LB_0_Wanted = LB_0[3735:3600];
                LB_1_Wanted = LB_1[3735:3600];
                LB_2_Wanted = LB_2[3735:3600];
            end
            'd459: begin
                LB_0_Wanted = LB_0[3743:3608];
                LB_1_Wanted = LB_1[3743:3608];
                LB_2_Wanted = LB_2[3743:3608];
            end
            'd460: begin
                LB_0_Wanted = LB_0[3751:3616];
                LB_1_Wanted = LB_1[3751:3616];
                LB_2_Wanted = LB_2[3751:3616];
            end
            'd461: begin
                LB_0_Wanted = LB_0[3759:3624];
                LB_1_Wanted = LB_1[3759:3624];
                LB_2_Wanted = LB_2[3759:3624];
            end
            'd462: begin
                LB_0_Wanted = LB_0[3767:3632];
                LB_1_Wanted = LB_1[3767:3632];
                LB_2_Wanted = LB_2[3767:3632];
            end
            'd463: begin
                LB_0_Wanted = LB_0[3775:3640];
                LB_1_Wanted = LB_1[3775:3640];
                LB_2_Wanted = LB_2[3775:3640];
            end
            'd464: begin
                LB_0_Wanted = LB_0[3783:3648];
                LB_1_Wanted = LB_1[3783:3648];
                LB_2_Wanted = LB_2[3783:3648];
            end
            'd465: begin
                LB_0_Wanted = LB_0[3791:3656];
                LB_1_Wanted = LB_1[3791:3656];
                LB_2_Wanted = LB_2[3791:3656];
            end
            'd466: begin
                LB_0_Wanted = LB_0[3799:3664];
                LB_1_Wanted = LB_1[3799:3664];
                LB_2_Wanted = LB_2[3799:3664];
            end
            'd467: begin
                LB_0_Wanted = LB_0[3807:3672];
                LB_1_Wanted = LB_1[3807:3672];
                LB_2_Wanted = LB_2[3807:3672];
            end
            'd468: begin
                LB_0_Wanted = LB_0[3815:3680];
                LB_1_Wanted = LB_1[3815:3680];
                LB_2_Wanted = LB_2[3815:3680];
            end
            'd469: begin
                LB_0_Wanted = LB_0[3823:3688];
                LB_1_Wanted = LB_1[3823:3688];
                LB_2_Wanted = LB_2[3823:3688];
            end
            'd470: begin
                LB_0_Wanted = LB_0[3831:3696];
                LB_1_Wanted = LB_1[3831:3696];
                LB_2_Wanted = LB_2[3831:3696];
            end
            'd471: begin
                LB_0_Wanted = LB_0[3839:3704];
                LB_1_Wanted = LB_1[3839:3704];
                LB_2_Wanted = LB_2[3839:3704];
            end
            'd472: begin
                LB_0_Wanted = LB_0[3847:3712];
                LB_1_Wanted = LB_1[3847:3712];
                LB_2_Wanted = LB_2[3847:3712];
            end
            'd473: begin
                LB_0_Wanted = LB_0[3855:3720];
                LB_1_Wanted = LB_1[3855:3720];
                LB_2_Wanted = LB_2[3855:3720];
            end
            'd474: begin
                LB_0_Wanted = LB_0[3863:3728];
                LB_1_Wanted = LB_1[3863:3728];
                LB_2_Wanted = LB_2[3863:3728];
            end
            'd475: begin
                LB_0_Wanted = LB_0[3871:3736];
                LB_1_Wanted = LB_1[3871:3736];
                LB_2_Wanted = LB_2[3871:3736];
            end
            'd476: begin
                LB_0_Wanted = LB_0[3879:3744];
                LB_1_Wanted = LB_1[3879:3744];
                LB_2_Wanted = LB_2[3879:3744];
            end
            'd477: begin
                LB_0_Wanted = LB_0[3887:3752];
                LB_1_Wanted = LB_1[3887:3752];
                LB_2_Wanted = LB_2[3887:3752];
            end
            'd478: begin
                LB_0_Wanted = LB_0[3895:3760];
                LB_1_Wanted = LB_1[3895:3760];
                LB_2_Wanted = LB_2[3895:3760];
            end
            'd479: begin
                LB_0_Wanted = LB_0[3903:3768];
                LB_1_Wanted = LB_1[3903:3768];
                LB_2_Wanted = LB_2[3903:3768];
            end
            'd480: begin
                LB_0_Wanted = LB_0[3911:3776];
                LB_1_Wanted = LB_1[3911:3776];
                LB_2_Wanted = LB_2[3911:3776];
            end
            'd481: begin
                LB_0_Wanted = LB_0[3919:3784];
                LB_1_Wanted = LB_1[3919:3784];
                LB_2_Wanted = LB_2[3919:3784];
            end
            'd482: begin
                LB_0_Wanted = LB_0[3927:3792];
                LB_1_Wanted = LB_1[3927:3792];
                LB_2_Wanted = LB_2[3927:3792];
            end
            'd483: begin
                LB_0_Wanted = LB_0[3935:3800];
                LB_1_Wanted = LB_1[3935:3800];
                LB_2_Wanted = LB_2[3935:3800];
            end
            'd484: begin
                LB_0_Wanted = LB_0[3943:3808];
                LB_1_Wanted = LB_1[3943:3808];
                LB_2_Wanted = LB_2[3943:3808];
            end
            'd485: begin
                LB_0_Wanted = LB_0[3951:3816];
                LB_1_Wanted = LB_1[3951:3816];
                LB_2_Wanted = LB_2[3951:3816];
            end
            'd486: begin
                LB_0_Wanted = LB_0[3959:3824];
                LB_1_Wanted = LB_1[3959:3824];
                LB_2_Wanted = LB_2[3959:3824];
            end
            'd487: begin
                LB_0_Wanted = LB_0[3967:3832];
                LB_1_Wanted = LB_1[3967:3832];
                LB_2_Wanted = LB_2[3967:3832];
            end
            'd488: begin
                LB_0_Wanted = LB_0[3975:3840];
                LB_1_Wanted = LB_1[3975:3840];
                LB_2_Wanted = LB_2[3975:3840];
            end
            'd489: begin
                LB_0_Wanted = LB_0[3983:3848];
                LB_1_Wanted = LB_1[3983:3848];
                LB_2_Wanted = LB_2[3983:3848];
            end
            'd490: begin
                LB_0_Wanted = LB_0[3991:3856];
                LB_1_Wanted = LB_1[3991:3856];
                LB_2_Wanted = LB_2[3991:3856];
            end
            'd491: begin
                LB_0_Wanted = LB_0[3999:3864];
                LB_1_Wanted = LB_1[3999:3864];
                LB_2_Wanted = LB_2[3999:3864];
            end
            'd492: begin
                LB_0_Wanted = LB_0[4007:3872];
                LB_1_Wanted = LB_1[4007:3872];
                LB_2_Wanted = LB_2[4007:3872];
            end
            'd493: begin
                LB_0_Wanted = LB_0[4015:3880];
                LB_1_Wanted = LB_1[4015:3880];
                LB_2_Wanted = LB_2[4015:3880];
            end
            'd494: begin
                LB_0_Wanted = LB_0[4023:3888];
                LB_1_Wanted = LB_1[4023:3888];
                LB_2_Wanted = LB_2[4023:3888];
            end
            'd495: begin
                LB_0_Wanted = LB_0[4031:3896];
                LB_1_Wanted = LB_1[4031:3896];
                LB_2_Wanted = LB_2[4031:3896];
            end
            'd496: begin
                LB_0_Wanted = LB_0[4039:3904];
                LB_1_Wanted = LB_1[4039:3904];
                LB_2_Wanted = LB_2[4039:3904];
            end
            'd497: begin
                LB_0_Wanted = LB_0[4047:3912];
                LB_1_Wanted = LB_1[4047:3912];
                LB_2_Wanted = LB_2[4047:3912];
            end
            'd498: begin
                LB_0_Wanted = LB_0[4055:3920];
                LB_1_Wanted = LB_1[4055:3920];
                LB_2_Wanted = LB_2[4055:3920];
            end
            'd499: begin
                LB_0_Wanted = LB_0[4063:3928];
                LB_1_Wanted = LB_1[4063:3928];
                LB_2_Wanted = LB_2[4063:3928];
            end
            'd500: begin
                LB_0_Wanted = LB_0[4071:3936];
                LB_1_Wanted = LB_1[4071:3936];
                LB_2_Wanted = LB_2[4071:3936];
            end
            'd501: begin
                LB_0_Wanted = LB_0[4079:3944];
                LB_1_Wanted = LB_1[4079:3944];
                LB_2_Wanted = LB_2[4079:3944];
            end
            'd502: begin
                LB_0_Wanted = LB_0[4087:3952];
                LB_1_Wanted = LB_1[4087:3952];
                LB_2_Wanted = LB_2[4087:3952];
            end
            'd503: begin
                LB_0_Wanted = LB_0[4095:3960];
                LB_1_Wanted = LB_1[4095:3960];
                LB_2_Wanted = LB_2[4095:3960];
            end
            'd504: begin
                LB_0_Wanted = LB_0[4103:3968];
                LB_1_Wanted = LB_1[4103:3968];
                LB_2_Wanted = LB_2[4103:3968];
            end
            'd505: begin
                LB_0_Wanted = LB_0[4111:3976];
                LB_1_Wanted = LB_1[4111:3976];
                LB_2_Wanted = LB_2[4111:3976];
            end
            'd506: begin
                LB_0_Wanted = LB_0[4119:3984];
                LB_1_Wanted = LB_1[4119:3984];
                LB_2_Wanted = LB_2[4119:3984];
            end
            'd507: begin
                LB_0_Wanted = LB_0[4127:3992];
                LB_1_Wanted = LB_1[4127:3992];
                LB_2_Wanted = LB_2[4127:3992];
            end
            'd508: begin
                LB_0_Wanted = LB_0[4135:4000];
                LB_1_Wanted = LB_1[4135:4000];
                LB_2_Wanted = LB_2[4135:4000];
            end
            'd509: begin
                LB_0_Wanted = LB_0[4143:4008];
                LB_1_Wanted = LB_1[4143:4008];
                LB_2_Wanted = LB_2[4143:4008];
            end
            'd510: begin
                LB_0_Wanted = LB_0[4151:4016];
                LB_1_Wanted = LB_1[4151:4016];
                LB_2_Wanted = LB_2[4151:4016];
            end
            'd511: begin
                LB_0_Wanted = LB_0[4159:4024];
                LB_1_Wanted = LB_1[4159:4024];
                LB_2_Wanted = LB_2[4159:4024];
            end
            'd512: begin
                LB_0_Wanted = LB_0[4167:4032];
                LB_1_Wanted = LB_1[4167:4032];
                LB_2_Wanted = LB_2[4167:4032];
            end
            'd513: begin
                LB_0_Wanted = LB_0[4175:4040];
                LB_1_Wanted = LB_1[4175:4040];
                LB_2_Wanted = LB_2[4175:4040];
            end
            'd514: begin
                LB_0_Wanted = LB_0[4183:4048];
                LB_1_Wanted = LB_1[4183:4048];
                LB_2_Wanted = LB_2[4183:4048];
            end
            'd515: begin
                LB_0_Wanted = LB_0[4191:4056];
                LB_1_Wanted = LB_1[4191:4056];
                LB_2_Wanted = LB_2[4191:4056];
            end
            'd516: begin
                LB_0_Wanted = LB_0[4199:4064];
                LB_1_Wanted = LB_1[4199:4064];
                LB_2_Wanted = LB_2[4199:4064];
            end
            'd517: begin
                LB_0_Wanted = LB_0[4207:4072];
                LB_1_Wanted = LB_1[4207:4072];
                LB_2_Wanted = LB_2[4207:4072];
            end
            'd518: begin
                LB_0_Wanted = LB_0[4215:4080];
                LB_1_Wanted = LB_1[4215:4080];
                LB_2_Wanted = LB_2[4215:4080];
            end
            'd519: begin
                LB_0_Wanted = LB_0[4223:4088];
                LB_1_Wanted = LB_1[4223:4088];
                LB_2_Wanted = LB_2[4223:4088];
            end
            'd520: begin
                LB_0_Wanted = LB_0[4231:4096];
                LB_1_Wanted = LB_1[4231:4096];
                LB_2_Wanted = LB_2[4231:4096];
            end
            'd521: begin
                LB_0_Wanted = LB_0[4239:4104];
                LB_1_Wanted = LB_1[4239:4104];
                LB_2_Wanted = LB_2[4239:4104];
            end
            'd522: begin
                LB_0_Wanted = LB_0[4247:4112];
                LB_1_Wanted = LB_1[4247:4112];
                LB_2_Wanted = LB_2[4247:4112];
            end
            'd523: begin
                LB_0_Wanted = LB_0[4255:4120];
                LB_1_Wanted = LB_1[4255:4120];
                LB_2_Wanted = LB_2[4255:4120];
            end
            'd524: begin
                LB_0_Wanted = LB_0[4263:4128];
                LB_1_Wanted = LB_1[4263:4128];
                LB_2_Wanted = LB_2[4263:4128];
            end
            'd525: begin
                LB_0_Wanted = LB_0[4271:4136];
                LB_1_Wanted = LB_1[4271:4136];
                LB_2_Wanted = LB_2[4271:4136];
            end
            'd526: begin
                LB_0_Wanted = LB_0[4279:4144];
                LB_1_Wanted = LB_1[4279:4144];
                LB_2_Wanted = LB_2[4279:4144];
            end
            'd527: begin
                LB_0_Wanted = LB_0[4287:4152];
                LB_1_Wanted = LB_1[4287:4152];
                LB_2_Wanted = LB_2[4287:4152];
            end
            'd528: begin
                LB_0_Wanted = LB_0[4295:4160];
                LB_1_Wanted = LB_1[4295:4160];
                LB_2_Wanted = LB_2[4295:4160];
            end
            'd529: begin
                LB_0_Wanted = LB_0[4303:4168];
                LB_1_Wanted = LB_1[4303:4168];
                LB_2_Wanted = LB_2[4303:4168];
            end
            'd530: begin
                LB_0_Wanted = LB_0[4311:4176];
                LB_1_Wanted = LB_1[4311:4176];
                LB_2_Wanted = LB_2[4311:4176];
            end
            'd531: begin
                LB_0_Wanted = LB_0[4319:4184];
                LB_1_Wanted = LB_1[4319:4184];
                LB_2_Wanted = LB_2[4319:4184];
            end
            'd532: begin
                LB_0_Wanted = LB_0[4327:4192];
                LB_1_Wanted = LB_1[4327:4192];
                LB_2_Wanted = LB_2[4327:4192];
            end
            'd533: begin
                LB_0_Wanted = LB_0[4335:4200];
                LB_1_Wanted = LB_1[4335:4200];
                LB_2_Wanted = LB_2[4335:4200];
            end
            'd534: begin
                LB_0_Wanted = LB_0[4343:4208];
                LB_1_Wanted = LB_1[4343:4208];
                LB_2_Wanted = LB_2[4343:4208];
            end
            'd535: begin
                LB_0_Wanted = LB_0[4351:4216];
                LB_1_Wanted = LB_1[4351:4216];
                LB_2_Wanted = LB_2[4351:4216];
            end
            'd536: begin
                LB_0_Wanted = LB_0[4359:4224];
                LB_1_Wanted = LB_1[4359:4224];
                LB_2_Wanted = LB_2[4359:4224];
            end
            'd537: begin
                LB_0_Wanted = LB_0[4367:4232];
                LB_1_Wanted = LB_1[4367:4232];
                LB_2_Wanted = LB_2[4367:4232];
            end
            'd538: begin
                LB_0_Wanted = LB_0[4375:4240];
                LB_1_Wanted = LB_1[4375:4240];
                LB_2_Wanted = LB_2[4375:4240];
            end
            'd539: begin
                LB_0_Wanted = LB_0[4383:4248];
                LB_1_Wanted = LB_1[4383:4248];
                LB_2_Wanted = LB_2[4383:4248];
            end
            'd540: begin
                LB_0_Wanted = LB_0[4391:4256];
                LB_1_Wanted = LB_1[4391:4256];
                LB_2_Wanted = LB_2[4391:4256];
            end
            'd541: begin
                LB_0_Wanted = LB_0[4399:4264];
                LB_1_Wanted = LB_1[4399:4264];
                LB_2_Wanted = LB_2[4399:4264];
            end
            'd542: begin
                LB_0_Wanted = LB_0[4407:4272];
                LB_1_Wanted = LB_1[4407:4272];
                LB_2_Wanted = LB_2[4407:4272];
            end
            'd543: begin
                LB_0_Wanted = LB_0[4415:4280];
                LB_1_Wanted = LB_1[4415:4280];
                LB_2_Wanted = LB_2[4415:4280];
            end
            'd544: begin
                LB_0_Wanted = LB_0[4423:4288];
                LB_1_Wanted = LB_1[4423:4288];
                LB_2_Wanted = LB_2[4423:4288];
            end
            'd545: begin
                LB_0_Wanted = LB_0[4431:4296];
                LB_1_Wanted = LB_1[4431:4296];
                LB_2_Wanted = LB_2[4431:4296];
            end
            'd546: begin
                LB_0_Wanted = LB_0[4439:4304];
                LB_1_Wanted = LB_1[4439:4304];
                LB_2_Wanted = LB_2[4439:4304];
            end
            'd547: begin
                LB_0_Wanted = LB_0[4447:4312];
                LB_1_Wanted = LB_1[4447:4312];
                LB_2_Wanted = LB_2[4447:4312];
            end
            'd548: begin
                LB_0_Wanted = LB_0[4455:4320];
                LB_1_Wanted = LB_1[4455:4320];
                LB_2_Wanted = LB_2[4455:4320];
            end
            'd549: begin
                LB_0_Wanted = LB_0[4463:4328];
                LB_1_Wanted = LB_1[4463:4328];
                LB_2_Wanted = LB_2[4463:4328];
            end
            'd550: begin
                LB_0_Wanted = LB_0[4471:4336];
                LB_1_Wanted = LB_1[4471:4336];
                LB_2_Wanted = LB_2[4471:4336];
            end
            'd551: begin
                LB_0_Wanted = LB_0[4479:4344];
                LB_1_Wanted = LB_1[4479:4344];
                LB_2_Wanted = LB_2[4479:4344];
            end
            'd552: begin
                LB_0_Wanted = LB_0[4487:4352];
                LB_1_Wanted = LB_1[4487:4352];
                LB_2_Wanted = LB_2[4487:4352];
            end
            'd553: begin
                LB_0_Wanted = LB_0[4495:4360];
                LB_1_Wanted = LB_1[4495:4360];
                LB_2_Wanted = LB_2[4495:4360];
            end
            'd554: begin
                LB_0_Wanted = LB_0[4503:4368];
                LB_1_Wanted = LB_1[4503:4368];
                LB_2_Wanted = LB_2[4503:4368];
            end
            'd555: begin
                LB_0_Wanted = LB_0[4511:4376];
                LB_1_Wanted = LB_1[4511:4376];
                LB_2_Wanted = LB_2[4511:4376];
            end
            'd556: begin
                LB_0_Wanted = LB_0[4519:4384];
                LB_1_Wanted = LB_1[4519:4384];
                LB_2_Wanted = LB_2[4519:4384];
            end
            'd557: begin
                LB_0_Wanted = LB_0[4527:4392];
                LB_1_Wanted = LB_1[4527:4392];
                LB_2_Wanted = LB_2[4527:4392];
            end
            'd558: begin
                LB_0_Wanted = LB_0[4535:4400];
                LB_1_Wanted = LB_1[4535:4400];
                LB_2_Wanted = LB_2[4535:4400];
            end
            'd559: begin
                LB_0_Wanted = LB_0[4543:4408];
                LB_1_Wanted = LB_1[4543:4408];
                LB_2_Wanted = LB_2[4543:4408];
            end
            'd560: begin
                LB_0_Wanted = LB_0[4551:4416];
                LB_1_Wanted = LB_1[4551:4416];
                LB_2_Wanted = LB_2[4551:4416];
            end
            'd561: begin
                LB_0_Wanted = LB_0[4559:4424];
                LB_1_Wanted = LB_1[4559:4424];
                LB_2_Wanted = LB_2[4559:4424];
            end
            'd562: begin
                LB_0_Wanted = LB_0[4567:4432];
                LB_1_Wanted = LB_1[4567:4432];
                LB_2_Wanted = LB_2[4567:4432];
            end
            'd563: begin
                LB_0_Wanted = LB_0[4575:4440];
                LB_1_Wanted = LB_1[4575:4440];
                LB_2_Wanted = LB_2[4575:4440];
            end
            'd564: begin
                LB_0_Wanted = LB_0[4583:4448];
                LB_1_Wanted = LB_1[4583:4448];
                LB_2_Wanted = LB_2[4583:4448];
            end
            'd565: begin
                LB_0_Wanted = LB_0[4591:4456];
                LB_1_Wanted = LB_1[4591:4456];
                LB_2_Wanted = LB_2[4591:4456];
            end
            'd566: begin
                LB_0_Wanted = LB_0[4599:4464];
                LB_1_Wanted = LB_1[4599:4464];
                LB_2_Wanted = LB_2[4599:4464];
            end
            'd567: begin
                LB_0_Wanted = LB_0[4607:4472];
                LB_1_Wanted = LB_1[4607:4472];
                LB_2_Wanted = LB_2[4607:4472];
            end
            'd568: begin
                LB_0_Wanted = LB_0[4615:4480];
                LB_1_Wanted = LB_1[4615:4480];
                LB_2_Wanted = LB_2[4615:4480];
            end
            'd569: begin
                LB_0_Wanted = LB_0[4623:4488];
                LB_1_Wanted = LB_1[4623:4488];
                LB_2_Wanted = LB_2[4623:4488];
            end
            'd570: begin
                LB_0_Wanted = LB_0[4631:4496];
                LB_1_Wanted = LB_1[4631:4496];
                LB_2_Wanted = LB_2[4631:4496];
            end
            'd571: begin
                LB_0_Wanted = LB_0[4639:4504];
                LB_1_Wanted = LB_1[4639:4504];
                LB_2_Wanted = LB_2[4639:4504];
            end
            'd572: begin
                LB_0_Wanted = LB_0[4647:4512];
                LB_1_Wanted = LB_1[4647:4512];
                LB_2_Wanted = LB_2[4647:4512];
            end
            'd573: begin
                LB_0_Wanted = LB_0[4655:4520];
                LB_1_Wanted = LB_1[4655:4520];
                LB_2_Wanted = LB_2[4655:4520];
            end
            'd574: begin
                LB_0_Wanted = LB_0[4663:4528];
                LB_1_Wanted = LB_1[4663:4528];
                LB_2_Wanted = LB_2[4663:4528];
            end
            'd575: begin
                LB_0_Wanted = LB_0[4671:4536];
                LB_1_Wanted = LB_1[4671:4536];
                LB_2_Wanted = LB_2[4671:4536];
            end
            'd576: begin
                LB_0_Wanted = LB_0[4679:4544];
                LB_1_Wanted = LB_1[4679:4544];
                LB_2_Wanted = LB_2[4679:4544];
            end
            'd577: begin
                LB_0_Wanted = LB_0[4687:4552];
                LB_1_Wanted = LB_1[4687:4552];
                LB_2_Wanted = LB_2[4687:4552];
            end
            'd578: begin
                LB_0_Wanted = LB_0[4695:4560];
                LB_1_Wanted = LB_1[4695:4560];
                LB_2_Wanted = LB_2[4695:4560];
            end
            'd579: begin
                LB_0_Wanted = LB_0[4703:4568];
                LB_1_Wanted = LB_1[4703:4568];
                LB_2_Wanted = LB_2[4703:4568];
            end
            'd580: begin
                LB_0_Wanted = LB_0[4711:4576];
                LB_1_Wanted = LB_1[4711:4576];
                LB_2_Wanted = LB_2[4711:4576];
            end
            'd581: begin
                LB_0_Wanted = LB_0[4719:4584];
                LB_1_Wanted = LB_1[4719:4584];
                LB_2_Wanted = LB_2[4719:4584];
            end
            'd582: begin
                LB_0_Wanted = LB_0[4727:4592];
                LB_1_Wanted = LB_1[4727:4592];
                LB_2_Wanted = LB_2[4727:4592];
            end
            'd583: begin
                LB_0_Wanted = LB_0[4735:4600];
                LB_1_Wanted = LB_1[4735:4600];
                LB_2_Wanted = LB_2[4735:4600];
            end
            'd584: begin
                LB_0_Wanted = LB_0[4743:4608];
                LB_1_Wanted = LB_1[4743:4608];
                LB_2_Wanted = LB_2[4743:4608];
            end
            'd585: begin
                LB_0_Wanted = LB_0[4751:4616];
                LB_1_Wanted = LB_1[4751:4616];
                LB_2_Wanted = LB_2[4751:4616];
            end
            'd586: begin
                LB_0_Wanted = LB_0[4759:4624];
                LB_1_Wanted = LB_1[4759:4624];
                LB_2_Wanted = LB_2[4759:4624];
            end
            'd587: begin
                LB_0_Wanted = LB_0[4767:4632];
                LB_1_Wanted = LB_1[4767:4632];
                LB_2_Wanted = LB_2[4767:4632];
            end
            'd588: begin
                LB_0_Wanted = LB_0[4775:4640];
                LB_1_Wanted = LB_1[4775:4640];
                LB_2_Wanted = LB_2[4775:4640];
            end
            'd589: begin
                LB_0_Wanted = LB_0[4783:4648];
                LB_1_Wanted = LB_1[4783:4648];
                LB_2_Wanted = LB_2[4783:4648];
            end
            'd590: begin
                LB_0_Wanted = LB_0[4791:4656];
                LB_1_Wanted = LB_1[4791:4656];
                LB_2_Wanted = LB_2[4791:4656];
            end
            'd591: begin
                LB_0_Wanted = LB_0[4799:4664];
                LB_1_Wanted = LB_1[4799:4664];
                LB_2_Wanted = LB_2[4799:4664];
            end
            'd592: begin
                LB_0_Wanted = LB_0[4807:4672];
                LB_1_Wanted = LB_1[4807:4672];
                LB_2_Wanted = LB_2[4807:4672];
            end
            'd593: begin
                LB_0_Wanted = LB_0[4815:4680];
                LB_1_Wanted = LB_1[4815:4680];
                LB_2_Wanted = LB_2[4815:4680];
            end
            'd594: begin
                LB_0_Wanted = LB_0[4823:4688];
                LB_1_Wanted = LB_1[4823:4688];
                LB_2_Wanted = LB_2[4823:4688];
            end
            'd595: begin
                LB_0_Wanted = LB_0[4831:4696];
                LB_1_Wanted = LB_1[4831:4696];
                LB_2_Wanted = LB_2[4831:4696];
            end
            'd596: begin
                LB_0_Wanted = LB_0[4839:4704];
                LB_1_Wanted = LB_1[4839:4704];
                LB_2_Wanted = LB_2[4839:4704];
            end
            'd597: begin
                LB_0_Wanted = LB_0[4847:4712];
                LB_1_Wanted = LB_1[4847:4712];
                LB_2_Wanted = LB_2[4847:4712];
            end
            'd598: begin
                LB_0_Wanted = LB_0[4855:4720];
                LB_1_Wanted = LB_1[4855:4720];
                LB_2_Wanted = LB_2[4855:4720];
            end
            'd599: begin
                LB_0_Wanted = LB_0[4863:4728];
                LB_1_Wanted = LB_1[4863:4728];
                LB_2_Wanted = LB_2[4863:4728];
            end
            'd600: begin
                LB_0_Wanted = LB_0[4871:4736];
                LB_1_Wanted = LB_1[4871:4736];
                LB_2_Wanted = LB_2[4871:4736];
            end
            'd601: begin
                LB_0_Wanted = LB_0[4879:4744];
                LB_1_Wanted = LB_1[4879:4744];
                LB_2_Wanted = LB_2[4879:4744];
            end
            'd602: begin
                LB_0_Wanted = LB_0[4887:4752];
                LB_1_Wanted = LB_1[4887:4752];
                LB_2_Wanted = LB_2[4887:4752];
            end
            'd603: begin
                LB_0_Wanted = LB_0[4895:4760];
                LB_1_Wanted = LB_1[4895:4760];
                LB_2_Wanted = LB_2[4895:4760];
            end
            'd604: begin
                LB_0_Wanted = LB_0[4903:4768];
                LB_1_Wanted = LB_1[4903:4768];
                LB_2_Wanted = LB_2[4903:4768];
            end
            'd605: begin
                LB_0_Wanted = LB_0[4911:4776];
                LB_1_Wanted = LB_1[4911:4776];
                LB_2_Wanted = LB_2[4911:4776];
            end
            'd606: begin
                LB_0_Wanted = LB_0[4919:4784];
                LB_1_Wanted = LB_1[4919:4784];
                LB_2_Wanted = LB_2[4919:4784];
            end
            'd607: begin
                LB_0_Wanted = LB_0[4927:4792];
                LB_1_Wanted = LB_1[4927:4792];
                LB_2_Wanted = LB_2[4927:4792];
            end
            'd608: begin
                LB_0_Wanted = LB_0[4935:4800];
                LB_1_Wanted = LB_1[4935:4800];
                LB_2_Wanted = LB_2[4935:4800];
            end
            'd609: begin
                LB_0_Wanted = LB_0[4943:4808];
                LB_1_Wanted = LB_1[4943:4808];
                LB_2_Wanted = LB_2[4943:4808];
            end
            'd610: begin
                LB_0_Wanted = LB_0[4951:4816];
                LB_1_Wanted = LB_1[4951:4816];
                LB_2_Wanted = LB_2[4951:4816];
            end
            'd611: begin
                LB_0_Wanted = LB_0[4959:4824];
                LB_1_Wanted = LB_1[4959:4824];
                LB_2_Wanted = LB_2[4959:4824];
            end
            'd612: begin
                LB_0_Wanted = LB_0[4967:4832];
                LB_1_Wanted = LB_1[4967:4832];
                LB_2_Wanted = LB_2[4967:4832];
            end
            'd613: begin
                LB_0_Wanted = LB_0[4975:4840];
                LB_1_Wanted = LB_1[4975:4840];
                LB_2_Wanted = LB_2[4975:4840];
            end
            'd614: begin
                LB_0_Wanted = LB_0[4983:4848];
                LB_1_Wanted = LB_1[4983:4848];
                LB_2_Wanted = LB_2[4983:4848];
            end
            'd615: begin
                LB_0_Wanted = LB_0[4991:4856];
                LB_1_Wanted = LB_1[4991:4856];
                LB_2_Wanted = LB_2[4991:4856];
            end
            'd616: begin
                LB_0_Wanted = LB_0[4999:4864];
                LB_1_Wanted = LB_1[4999:4864];
                LB_2_Wanted = LB_2[4999:4864];
            end
            'd617: begin
                LB_0_Wanted = LB_0[5007:4872];
                LB_1_Wanted = LB_1[5007:4872];
                LB_2_Wanted = LB_2[5007:4872];
            end
            'd618: begin
                LB_0_Wanted = LB_0[5015:4880];
                LB_1_Wanted = LB_1[5015:4880];
                LB_2_Wanted = LB_2[5015:4880];
            end
            'd619: begin
                LB_0_Wanted = LB_0[5023:4888];
                LB_1_Wanted = LB_1[5023:4888];
                LB_2_Wanted = LB_2[5023:4888];
            end
            'd620: begin
                LB_0_Wanted = LB_0[5031:4896];
                LB_1_Wanted = LB_1[5031:4896];
                LB_2_Wanted = LB_2[5031:4896];
            end
            'd621: begin
                LB_0_Wanted = LB_0[5039:4904];
                LB_1_Wanted = LB_1[5039:4904];
                LB_2_Wanted = LB_2[5039:4904];
            end
            'd622: begin
                LB_0_Wanted = LB_0[5047:4912];
                LB_1_Wanted = LB_1[5047:4912];
                LB_2_Wanted = LB_2[5047:4912];
            end
            'd623: begin
                LB_0_Wanted = LB_0[5055:4920];
                LB_1_Wanted = LB_1[5055:4920];
                LB_2_Wanted = LB_2[5055:4920];
            end
            'd624: begin
                LB_0_Wanted = LB_0[5063:4928];
                LB_1_Wanted = LB_1[5063:4928];
                LB_2_Wanted = LB_2[5063:4928];
            end
            'd625: begin
                LB_0_Wanted = LB_0[5071:4936];
                LB_1_Wanted = LB_1[5071:4936];
                LB_2_Wanted = LB_2[5071:4936];
            end
            'd626: begin
                LB_0_Wanted = LB_0[5079:4944];
                LB_1_Wanted = LB_1[5079:4944];
                LB_2_Wanted = LB_2[5079:4944];
            end
            'd627: begin
                LB_0_Wanted = LB_0[5087:4952];
                LB_1_Wanted = LB_1[5087:4952];
                LB_2_Wanted = LB_2[5087:4952];
            end
            'd628: begin
                LB_0_Wanted = LB_0[5095:4960];
                LB_1_Wanted = LB_1[5095:4960];
                LB_2_Wanted = LB_2[5095:4960];
            end
            'd629: begin
                LB_0_Wanted = LB_0[5103:4968];
                LB_1_Wanted = LB_1[5103:4968];
                LB_2_Wanted = LB_2[5103:4968];
            end
            'd630: begin
                LB_0_Wanted = LB_0[5111:4976];
                LB_1_Wanted = LB_1[5111:4976];
                LB_2_Wanted = LB_2[5111:4976];
            end
            'd631: begin
                LB_0_Wanted = LB_0[5119:4984];
                LB_1_Wanted = LB_1[5119:4984];
                LB_2_Wanted = LB_2[5119:4984];
            end
            default: begin
                LB_0_Wanted = {136{1'b0}};
                LB_1_Wanted = {136{1'b0}};
                LB_2_Wanted = {136{1'b0}};
            end
        endcase
    
    end
    
endmodule