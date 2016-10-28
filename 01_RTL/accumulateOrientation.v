module accumulateOrientation( //combinational
    buffer_0,//newest
    buffer_1,
    buffer_2,
    row,//kpt's row
    col,//kpt's col
    row_accu_result1,
    row_accu_result2
);

    input       [8:0]   row;
    input       [9:0]   col;
    
    input       [135:0] buffer_0,
                        buffer_1,
                        buffer_2;
                        
    output      [95:0]  row_accu_result1,
                        row_accu_result2;
                        
    //////////////////////////////
    
    //wire                not_garbageRow;//contain garbageRow，output of this cycle = 0 (row's valid)
    
    //wire                p1_valid,//pixel 1 valid or not(col's valid)
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
                        
    //reg         [135:0] buffer_0,//newest[col大~col小] (17 x 8 = 136)
    //                    buffer_1,
    //                    buffer_2;
                    
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
        
    assign pixel_1_temp1        = buffer_1[23:16] - buffer_1[7:0];//pixel(col+1) - pixel(col-1)
    assign pixel_2_temp1        = buffer_1[31:24] - buffer_1[15:8];
    assign pixel_3_temp1        = buffer_1[39:32] - buffer_1[23:16];
    assign pixel_4_temp1        = buffer_1[47:40] - buffer_1[31:24];
    assign pixel_5_temp1        = buffer_1[55:48] - buffer_1[39:32];
    assign pixel_6_temp1        = buffer_1[63:56] - buffer_1[47:40];
    assign pixel_7_temp1        = buffer_1[71:64] - buffer_1[55:48];
    assign pixel_8_temp1        = buffer_1[79:72] - buffer_1[63:56];
    assign pixel_9_temp1        = buffer_1[87:80] - buffer_1[71:64];
    assign pixel_10_temp1       = buffer_1[95:88] - buffer_1[79:72];
    assign pixel_11_temp1       = buffer_1[103:96] - buffer_1[87:80];
    assign pixel_12_temp1       = buffer_1[111:104] - buffer_1[95:88];
    assign pixel_13_temp1       = buffer_1[119:112] - buffer_1[103:96];
    assign pixel_14_temp1       = buffer_1[127:120] - buffer_1[111:104];
    assign pixel_15_temp1       = buffer_1[135:128] - buffer_1[119:112];
        
    assign pixel_1_temp2        = buffer_0[15:8] - buffer_2[15:8];//pixel(row+1) - pixel(row-1)
    assign pixel_2_temp2        = buffer_0[23:16] - buffer_2[23:16];
    assign pixel_3_temp2        = buffer_0[31:24] - buffer_2[31:24];
    assign pixel_4_temp2        = buffer_0[39:32] - buffer_2[39:32];
    assign pixel_5_temp2        = buffer_0[47:40] - buffer_2[47:40];
    assign pixel_6_temp2        = buffer_0[55:48] - buffer_2[55:48];
    assign pixel_7_temp2        = buffer_0[63:56] - buffer_2[63:56];
    assign pixel_8_temp2        = buffer_0[71:64] - buffer_2[71:64];
    assign pixel_9_temp2        = buffer_0[79:72] - buffer_2[79:72];
    assign pixel_10_temp2       = buffer_0[87:80] - buffer_2[87:80];
    assign pixel_11_temp2       = buffer_0[95:88] - buffer_2[95:88];
    assign pixel_12_temp2       = buffer_0[103:96] - buffer_2[103:96];
    assign pixel_13_temp2       = buffer_0[111:104] - buffer_2[111:104];
    assign pixel_14_temp2       = buffer_0[119:112] - buffer_2[119:112];
    assign pixel_15_temp2       = buffer_0[127:120] - buffer_2[127:120];
        
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
                if(pixel_1_temp1 >= abs_pixel_1_temp2)
                    p1_bin = 'd7;
                else
                    p1_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_1_temp1 >= pixel_1_temp2)
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
                if(pixel_2_temp1 >= abs_pixel_2_temp2)
                    p2_bin = 'd7;
                else
                    p2_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_2_temp1 >= pixel_2_temp2)
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
                if(pixel_3_temp1 >= abs_pixel_3_temp2)
                    p3_bin = 'd7;
                else
                    p3_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_3_temp1 >= pixel_3_temp2)
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
                if(pixel_4_temp1 >= abs_pixel_4_temp2)
                    p4_bin = 'd7;
                else
                    p4_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_4_temp1 >= pixel_4_temp2)
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
                if(pixel_5_temp1 >= abs_pixel_5_temp2)
                    p5_bin = 'd7;
                else
                    p5_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_5_temp1 >= pixel_5_temp2)
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
                if(pixel_6_temp1 >= abs_pixel_6_temp2)
                    p6_bin = 'd7;
                else
                    p6_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_6_temp1 >= pixel_6_temp2)
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
                if(pixel_7_temp1 >= abs_pixel_7_temp2)
                    p7_bin = 'd7;
                else
                    p7_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_7_temp1 >= pixel_7_temp2)
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
                if(pixel_8_temp1 >= abs_pixel_8_temp2)
                    p8_bin = 'd7;
                else
                    p8_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_8_temp1 >= pixel_8_temp2)
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
                if(pixel_9_temp1 >= abs_pixel_9_temp2)
                    p9_bin = 'd7;
                else
                    p9_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_9_temp1 >= pixel_9_temp2)
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
                if(pixel_10_temp1 >= abs_pixel_10_temp2)
                    p10_bin = 'd7;
                else
                    p10_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_10_temp1 >= pixel_10_temp2)
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
                if(pixel_11_temp1 >= abs_pixel_11_temp2)
                    p11_bin = 'd7;
                else
                    p11_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_11_temp1 >= pixel_11_temp2)
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
                if(pixel_12_temp1 >= abs_pixel_12_temp2)
                    p12_bin = 'd7;
                else
                    p12_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_12_temp1 >= pixel_12_temp2)
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
                if(pixel_13_temp1 >= abs_pixel_13_temp2)
                    p13_bin = 'd7;
                else
                    p13_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_13_temp1 >= pixel_13_temp2)
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
                if(pixel_14_temp1 >= abs_pixel_14_temp2)
                    p14_bin = 'd7;
                else
                    p14_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_14_temp1 >= pixel_14_temp2)
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
                if(pixel_15_temp1 >= abs_pixel_15_temp2)
                    p15_bin = 'd7;
                else
                    p15_bin = 'd6;
            2'b10://2nd quadrant
                if(abs_pixel_15_temp1 >= pixel_15_temp2)
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
    
endmodule