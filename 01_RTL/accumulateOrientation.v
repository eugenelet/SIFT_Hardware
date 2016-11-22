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
                        
    output      [95:0]  row_accu_result1, //MSB~LSB : bin_0~bin_7
                        row_accu_result2;
                        
    //////////////////////////////
        
    //reg         [95:0]  pixel_1, pixel_2, pixel_3, pixel_4, pixel_5, pixel_6, pixel_7, pixel_8,
    //                    pixel_9, pixel_10, pixel_11, pixel_12, pixel_13, pixel_14, pixel_15;
    
    wire         [11:0] pixel_01_bin_0, pixel_01_bin_1, pixel_01_bin_2, pixel_01_bin_3, pixel_01_bin_4, pixel_01_bin_5, pixel_01_bin_6, pixel_01_bin_7,
                        pixel_02_bin_0, pixel_02_bin_1, pixel_02_bin_2, pixel_02_bin_3, pixel_02_bin_4, pixel_02_bin_5, pixel_02_bin_6, pixel_02_bin_7,
                        pixel_03_bin_0, pixel_03_bin_1, pixel_03_bin_2, pixel_03_bin_3, pixel_03_bin_4, pixel_03_bin_5, pixel_03_bin_6, pixel_03_bin_7,
                        pixel_04_bin_0, pixel_04_bin_1, pixel_04_bin_2, pixel_04_bin_3, pixel_04_bin_4, pixel_04_bin_5, pixel_04_bin_6, pixel_04_bin_7,
                        pixel_05_bin_0, pixel_05_bin_1, pixel_05_bin_2, pixel_05_bin_3, pixel_05_bin_4, pixel_05_bin_5, pixel_05_bin_6, pixel_05_bin_7,
                        pixel_06_bin_0, pixel_06_bin_1, pixel_06_bin_2, pixel_06_bin_3, pixel_06_bin_4, pixel_06_bin_5, pixel_06_bin_6, pixel_06_bin_7,
                        pixel_07_bin_0, pixel_07_bin_1, pixel_07_bin_2, pixel_07_bin_3, pixel_07_bin_4, pixel_07_bin_5, pixel_07_bin_6, pixel_07_bin_7,
                        pixel_08_bin_0, pixel_08_bin_1, pixel_08_bin_2, pixel_08_bin_3, pixel_08_bin_4, pixel_08_bin_5, pixel_08_bin_6, pixel_08_bin_7,
                        pixel_09_bin_0, pixel_09_bin_1, pixel_09_bin_2, pixel_09_bin_3, pixel_09_bin_4, pixel_09_bin_5, pixel_09_bin_6, pixel_09_bin_7,
                        pixel_10_bin_0, pixel_10_bin_1, pixel_10_bin_2, pixel_10_bin_3, pixel_10_bin_4, pixel_10_bin_5, pixel_10_bin_6, pixel_10_bin_7,
                        pixel_11_bin_0, pixel_11_bin_1, pixel_11_bin_2, pixel_11_bin_3, pixel_11_bin_4, pixel_11_bin_5, pixel_11_bin_6, pixel_11_bin_7,
                        pixel_12_bin_0, pixel_12_bin_1, pixel_12_bin_2, pixel_12_bin_3, pixel_12_bin_4, pixel_12_bin_5, pixel_12_bin_6, pixel_12_bin_7,
                        pixel_13_bin_0, pixel_13_bin_1, pixel_13_bin_2, pixel_13_bin_3, pixel_13_bin_4, pixel_13_bin_5, pixel_13_bin_6, pixel_13_bin_7,
                        pixel_14_bin_0, pixel_14_bin_1, pixel_14_bin_2, pixel_14_bin_3, pixel_14_bin_4, pixel_14_bin_5, pixel_14_bin_6, pixel_14_bin_7,
                        pixel_15_bin_0, pixel_15_bin_1, pixel_15_bin_2, pixel_15_bin_3, pixel_15_bin_4, pixel_15_bin_5, pixel_15_bin_6, pixel_15_bin_7;
                        
    
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
    
    //will not carry over to next orientation. But Dude, EDA tools don't bird you.
    //assign row_accu_result1     = pixel_1 + pixel_2 + pixel_3 + pixel_4 + pixel_5 + pixel_6 + pixel_7 + pixel_8;
    //assign row_accu_result2     = pixel_8 + pixel_9 + pixel_10 + pixel_11 + pixel_12 + pixel_13 + pixel_14 + pixel_15;
    
    assign row_accu_result1[95:84]  = pixel_01_bin_0 + pixel_02_bin_0 + pixel_03_bin_0 + pixel_04_bin_0 + pixel_05_bin_0 + pixel_06_bin_0 + pixel_07_bin_0 + pixel_08_bin_0;
    assign row_accu_result1[83:72]  = pixel_01_bin_1 + pixel_02_bin_1 + pixel_03_bin_1 + pixel_04_bin_1 + pixel_05_bin_1 + pixel_06_bin_1 + pixel_07_bin_1 + pixel_08_bin_1;
    assign row_accu_result1[71:60]  = pixel_01_bin_2 + pixel_02_bin_2 + pixel_03_bin_2 + pixel_04_bin_2 + pixel_05_bin_2 + pixel_06_bin_2 + pixel_07_bin_2 + pixel_08_bin_2;
    assign row_accu_result1[59:48]  = pixel_01_bin_3 + pixel_02_bin_3 + pixel_03_bin_3 + pixel_04_bin_3 + pixel_05_bin_3 + pixel_06_bin_3 + pixel_07_bin_3 + pixel_08_bin_3;
    assign row_accu_result1[47:36]  = pixel_01_bin_4 + pixel_02_bin_4 + pixel_03_bin_4 + pixel_04_bin_4 + pixel_05_bin_4 + pixel_06_bin_4 + pixel_07_bin_4 + pixel_08_bin_4;
    assign row_accu_result1[35:24]  = pixel_01_bin_5 + pixel_02_bin_5 + pixel_03_bin_5 + pixel_04_bin_5 + pixel_05_bin_5 + pixel_06_bin_5 + pixel_07_bin_5 + pixel_08_bin_5;
    assign row_accu_result1[23:12]  = pixel_01_bin_6 + pixel_02_bin_6 + pixel_03_bin_6 + pixel_04_bin_6 + pixel_05_bin_6 + pixel_06_bin_6 + pixel_07_bin_6 + pixel_08_bin_6;
    assign row_accu_result1[11:0 ]  = pixel_01_bin_7 + pixel_02_bin_7 + pixel_03_bin_7 + pixel_04_bin_7 + pixel_05_bin_7 + pixel_06_bin_7 + pixel_07_bin_7 + pixel_08_bin_7;
    
    assign row_accu_result2[95:84]  = pixel_08_bin_0 + pixel_09_bin_0 + pixel_10_bin_0 + pixel_11_bin_0 + pixel_12_bin_0 + pixel_13_bin_0 + pixel_14_bin_0 + pixel_15_bin_0;
    assign row_accu_result2[83:72]  = pixel_08_bin_1 + pixel_09_bin_1 + pixel_10_bin_1 + pixel_11_bin_1 + pixel_12_bin_1 + pixel_13_bin_1 + pixel_14_bin_1 + pixel_15_bin_1;
    assign row_accu_result2[71:60]  = pixel_08_bin_2 + pixel_09_bin_2 + pixel_10_bin_2 + pixel_11_bin_2 + pixel_12_bin_2 + pixel_13_bin_2 + pixel_14_bin_2 + pixel_15_bin_2;
    assign row_accu_result2[59:48]  = pixel_08_bin_3 + pixel_09_bin_3 + pixel_10_bin_3 + pixel_11_bin_3 + pixel_12_bin_3 + pixel_13_bin_3 + pixel_14_bin_3 + pixel_15_bin_3;
    assign row_accu_result2[47:36]  = pixel_08_bin_4 + pixel_09_bin_4 + pixel_10_bin_4 + pixel_11_bin_4 + pixel_12_bin_4 + pixel_13_bin_4 + pixel_14_bin_4 + pixel_15_bin_4;
    assign row_accu_result2[35:24]  = pixel_08_bin_5 + pixel_09_bin_5 + pixel_10_bin_5 + pixel_11_bin_5 + pixel_12_bin_5 + pixel_13_bin_5 + pixel_14_bin_5 + pixel_15_bin_5;
    assign row_accu_result2[23:12]  = pixel_08_bin_6 + pixel_09_bin_6 + pixel_10_bin_6 + pixel_11_bin_6 + pixel_12_bin_6 + pixel_13_bin_6 + pixel_14_bin_6 + pixel_15_bin_6;
    assign row_accu_result2[11:0 ]  = pixel_08_bin_7 + pixel_09_bin_7 + pixel_10_bin_7 + pixel_11_bin_7 + pixel_12_bin_7 + pixel_13_bin_7 + pixel_14_bin_7 + pixel_15_bin_7;
    
    assign pixel_01_bin_0           = (p1_bin == 'd0)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_1           = (p1_bin == 'd1)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_2           = (p1_bin == 'd2)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_3           = (p1_bin == 'd3)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_4           = (p1_bin == 'd4)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_5           = (p1_bin == 'd5)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_6           = (p1_bin == 'd6)? {2'b00, p1_mag} : 'd0;
    assign pixel_01_bin_7           = (p1_bin == 'd7)? {2'b00, p1_mag} : 'd0;
        
    assign pixel_02_bin_0           = (p2_bin == 'd0)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_1           = (p2_bin == 'd1)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_2           = (p2_bin == 'd2)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_3           = (p2_bin == 'd3)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_4           = (p2_bin == 'd4)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_5           = (p2_bin == 'd5)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_6           = (p2_bin == 'd6)? {2'b00, p2_mag} : 'd0;
    assign pixel_02_bin_7           = (p2_bin == 'd7)? {2'b00, p2_mag} : 'd0;
        
    assign pixel_03_bin_0           = (p2_bin == 'd0)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_1           = (p2_bin == 'd1)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_2           = (p2_bin == 'd2)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_3           = (p2_bin == 'd3)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_4           = (p2_bin == 'd4)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_5           = (p2_bin == 'd5)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_6           = (p2_bin == 'd6)? {2'b00, p3_mag} : 'd0;
    assign pixel_03_bin_7           = (p2_bin == 'd7)? {2'b00, p3_mag} : 'd0;
        
    assign pixel_04_bin_0           = (p4_bin == 'd0)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_1           = (p4_bin == 'd1)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_2           = (p4_bin == 'd2)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_3           = (p4_bin == 'd3)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_4           = (p4_bin == 'd4)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_5           = (p4_bin == 'd5)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_6           = (p4_bin == 'd6)? {2'b00, p4_mag} : 'd0;
    assign pixel_04_bin_7           = (p4_bin == 'd7)? {2'b00, p4_mag} : 'd0;
        
    assign pixel_05_bin_0           = (p5_bin == 'd0)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_1           = (p5_bin == 'd1)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_2           = (p5_bin == 'd2)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_3           = (p5_bin == 'd3)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_4           = (p5_bin == 'd4)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_5           = (p5_bin == 'd5)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_6           = (p5_bin == 'd6)? {2'b00, p5_mag} : 'd0;
    assign pixel_05_bin_7           = (p5_bin == 'd7)? {2'b00, p5_mag} : 'd0;
        
    assign pixel_06_bin_0           = (p6_bin == 'd0)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_1           = (p6_bin == 'd1)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_2           = (p6_bin == 'd2)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_3           = (p6_bin == 'd3)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_4           = (p6_bin == 'd4)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_5           = (p6_bin == 'd5)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_6           = (p6_bin == 'd6)? {2'b00, p6_mag} : 'd0;
    assign pixel_06_bin_7           = (p6_bin == 'd7)? {2'b00, p6_mag} : 'd0;
        
    assign pixel_07_bin_0           = (p7_bin == 'd0)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_1           = (p7_bin == 'd1)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_2           = (p7_bin == 'd2)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_3           = (p7_bin == 'd3)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_4           = (p7_bin == 'd4)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_5           = (p7_bin == 'd5)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_6           = (p7_bin == 'd6)? {2'b00, p7_mag} : 'd0;
    assign pixel_07_bin_7           = (p7_bin == 'd7)? {2'b00, p7_mag} : 'd0;
        
    assign pixel_08_bin_0           = (p8_bin == 'd0)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_1           = (p8_bin == 'd1)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_2           = (p8_bin == 'd2)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_3           = (p8_bin == 'd3)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_4           = (p8_bin == 'd4)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_5           = (p8_bin == 'd5)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_6           = (p8_bin == 'd6)? {2'b00, p8_mag} : 'd0;
    assign pixel_08_bin_7           = (p8_bin == 'd7)? {2'b00, p8_mag} : 'd0;
        
    assign pixel_09_bin_0           = (p9_bin == 'd0)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_1           = (p9_bin == 'd1)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_2           = (p9_bin == 'd2)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_3           = (p9_bin == 'd3)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_4           = (p9_bin == 'd4)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_5           = (p9_bin == 'd5)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_6           = (p9_bin == 'd6)? {2'b00, p9_mag} : 'd0;
    assign pixel_09_bin_7           = (p9_bin == 'd7)? {2'b00, p9_mag} : 'd0;
        
    assign pixel_10_bin_0           = (p10_bin == 'd0)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_1           = (p10_bin == 'd1)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_2           = (p10_bin == 'd2)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_3           = (p10_bin == 'd3)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_4           = (p10_bin == 'd4)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_5           = (p10_bin == 'd5)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_6           = (p10_bin == 'd6)? {2'b00, p10_mag} : 'd0;
    assign pixel_10_bin_7           = (p10_bin == 'd7)? {2'b00, p10_mag} : 'd0;
        
    assign pixel_11_bin_0           = (p11_bin == 'd0)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_1           = (p11_bin == 'd1)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_2           = (p11_bin == 'd2)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_3           = (p11_bin == 'd3)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_4           = (p11_bin == 'd4)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_5           = (p11_bin == 'd5)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_6           = (p11_bin == 'd6)? {2'b00, p11_mag} : 'd0;
    assign pixel_11_bin_7           = (p11_bin == 'd7)? {2'b00, p11_mag} : 'd0;
        
    assign pixel_12_bin_0           = (p12_bin == 'd0)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_1           = (p12_bin == 'd1)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_2           = (p12_bin == 'd2)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_3           = (p12_bin == 'd3)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_4           = (p12_bin == 'd4)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_5           = (p12_bin == 'd5)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_6           = (p12_bin == 'd6)? {2'b00, p12_mag} : 'd0;
    assign pixel_12_bin_7           = (p12_bin == 'd7)? {2'b00, p12_mag} : 'd0;
        
    assign pixel_13_bin_0           = (p13_bin == 'd0)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_1           = (p13_bin == 'd1)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_2           = (p13_bin == 'd2)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_3           = (p13_bin == 'd3)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_4           = (p13_bin == 'd4)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_5           = (p13_bin == 'd5)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_6           = (p13_bin == 'd6)? {2'b00, p13_mag} : 'd0;
    assign pixel_13_bin_7           = (p13_bin == 'd7)? {2'b00, p13_mag} : 'd0;
        
    assign pixel_14_bin_0           = (p14_bin == 'd0)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_1           = (p14_bin == 'd1)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_2           = (p14_bin == 'd2)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_3           = (p14_bin == 'd3)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_4           = (p14_bin == 'd4)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_5           = (p14_bin == 'd5)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_6           = (p14_bin == 'd6)? {2'b00, p14_mag} : 'd0;
    assign pixel_14_bin_7           = (p14_bin == 'd7)? {2'b00, p14_mag} : 'd0;
        
    assign pixel_15_bin_0           = (p15_bin == 'd0)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_1           = (p15_bin == 'd1)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_2           = (p15_bin == 'd2)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_3           = (p15_bin == 'd3)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_4           = (p15_bin == 'd4)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_5           = (p15_bin == 'd5)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_6           = (p15_bin == 'd6)? {2'b00, p15_mag} : 'd0;
    assign pixel_15_bin_7           = (p15_bin == 'd7)? {2'b00, p15_mag} : 'd0;
    
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
    
endmodule