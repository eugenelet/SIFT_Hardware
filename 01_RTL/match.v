module match(
    clk,
    rst_n,
    start,
    done,
    descriptor_request,
    descriptor_valid,
    img_descpt_group_num,
    tar_descpt_group_num,
    //
    image_R_C_D_0,//image's row col descriptor
    image_R_C_D_1,
    image_R_C_D_2,
    image_R_C_D_3,
    //
    tar_addr,//讀target mem的addr(4個共用)
    tar_R_C_D_0,
    tar_R_C_D_1,
    tar_R_C_D_2,
    tar_R_C_D_3,
    //
    matched_addr_1,//4個共用
    matched_WE,//4 bit
    matched_din_0,//接給matched的din
    matched_din_1,
    matched_din_2,
    matched_din_3,
    //
    matched_addr_2,//4個共用
    matched_dout2_0,
    matched_dout2_1,
    matched_dout2_2,
    matched_dout2_3,
    //
    layer1_num,
    layer2_num
);

    input               clk,
                        rst_n;
    input               start,
                        descriptor_valid;
    input       [10:0]  layer1_num,
                        layer2_num;
    input       [8:0]   tar_descpt_group_num;
    
    input       [402:0] image_R_C_D_0,
                        image_R_C_D_1,
                        image_R_C_D_2,
                        image_R_C_D_3;
    input       [402:0] tar_R_C_D_0,
                        tar_R_C_D_1,
                        tar_R_C_D_2,
                        tar_R_C_D_3;
    input       [46:0]  matched_dout2_0,
                        matched_dout2_1,
                        matched_dout2_2,
                        matched_dout2_3;
    
    output              done;
    output              descriptor_request;
    output      [8:0]   tar_addr;
    output      [8:0]   matched_addr_1;//這
    output      [8:0]   matched_addr_2;
    output      [3:0]   matched_WE;
    output      [46:0]  matched_din_0,
                        matched_din_1,
                        matched_din_2,
                        matched_din_3;
    
    //////////////////////////////
    
    parameter   ST_IDLE         = 'd0,
                ST_SEND_REQUEST = 'd1,
                ST_READING_ONLY = 'd2,
                ST_READ_COMPUTE = 'd3,
                ST_DONE         = 'd4;
                
    reg[2:0]    cs;
    reg[2:0]    ns;
                
    //////////////////////////////
    
    wire[3:0]   matched_WE_fake;
    wire        debug;
    wire[8:0]   img_descpt_group_num;
    
    reg[8:0]    img_group_num,
                img_group_counter,
                tar_group_num,
                tar_group_counter;
                
    reg[402:0]  tar_RCD_FF_0,
                tar_RCD_FF_1,
                tar_RCD_FF_2,
                tar_RCD_FF_3;
                
    reg[46:0]   matched_dout2_FF_0,
                matched_dout2_FF_1,
                matched_dout2_FF_2,
                matched_dout2_FF_3;
    
    //////////////////////////////
    
    assign done                 = (cs == ST_DONE)? 1'b1 : 1'b0;
    assign descriptor_request   = (cs == ST_SEND_REQUEST)? 1'b1 : 1'b0;
    assign tar_addr             = tar_group_counter;
    assign matched_addr_2       = tar_group_counter;
    assign matched_WE           = (cs == ST_READ_COMPUTE)? matched_WE_fake : 4'b0000;
    assign matched_addr_1       = tar_group_counter - 2'b10;
    assign debug                = (cs == ST_READ_COMPUTE)? 1'b1 : 1'b0;
    assign img_descpt_group_num = (layer1_num + layer2_num) / 4;
    
    //////////////////////////////
    
    compareDist u_compareDist_0(//(combinational) matched_WE_fake[0], matched_din_0
        .tar            (tar_RCD_FF_0[383:0]),
        .img0           (image_R_C_D_0),
        .img1           (image_R_C_D_1),
        .img2           (image_R_C_D_2),
        .img3           (image_R_C_D_3),
        .matched_MEM    (matched_dout2_FF_0),
        .WE             (matched_WE_fake[0]),
        .matched_MEM_din(matched_din_0)
    );
    
    compareDist u_compareDist_1(//(combinational) matched_WE_fake[1], matched_din_1
        .tar            (tar_RCD_FF_1[383:0]),
        .img0           (image_R_C_D_0),
        .img1           (image_R_C_D_1),
        .img2           (image_R_C_D_2),
        .img3           (image_R_C_D_3),
        .matched_MEM    (matched_dout2_FF_1),
        .WE             (matched_WE_fake[1]),
        .matched_MEM_din(matched_din_1)
    );
    
    compareDist u_compareDist_2(//(combinational) matched_WE_fake[2], matched_din_2
        .tar            (tar_RCD_FF_2[383:0]),
        .img0           (image_R_C_D_0),
        .img1           (image_R_C_D_1),
        .img2           (image_R_C_D_2),
        .img3           (image_R_C_D_3),
        .matched_MEM    (matched_dout2_FF_2),
        .WE             (matched_WE_fake[2]),
        .matched_MEM_din(matched_din_2)
    );
    
    compareDist u_compareDist_3(//(combinational) matched_WE_fake[3], matched_din_3
        .tar            (tar_RCD_FF_3[383:0]),
        .img0           (image_R_C_D_0),
        .img1           (image_R_C_D_1),
        .img2           (image_R_C_D_2),
        .img3           (image_R_C_D_3),
        .matched_MEM    (matched_dout2_FF_3),
        .WE             (matched_WE_fake[3]),
        .matched_MEM_din(matched_din_3)
    );
    
    //////////////////////////////
    
    always @(posedge clk) begin //matched_dout2_FF_0, matched_dout2_FF_1, matched_dout2_FF_2, matched_dout2_FF_3
        //接matched_MEM讀出來的
        if(!rst_n) begin
            matched_dout2_FF_0 <= 'd0;
            matched_dout2_FF_1 <= 'd0;
            matched_dout2_FF_2 <= 'd0;
            matched_dout2_FF_3 <= 'd0;
        end
        else if(cs==ST_READING_ONLY || cs==ST_READ_COMPUTE) begin
            matched_dout2_FF_0 <= matched_dout2_0;
            matched_dout2_FF_1 <= matched_dout2_1;
            matched_dout2_FF_2 <= matched_dout2_2;
            matched_dout2_FF_3 <= matched_dout2_3;
        end
        else begin
            matched_dout2_FF_0 <= matched_dout2_FF_0;
            matched_dout2_FF_1 <= matched_dout2_FF_1;
            matched_dout2_FF_2 <= matched_dout2_FF_2;
            matched_dout2_FF_3 <= matched_dout2_FF_3;
        end
    
    end
    
    always @(posedge clk) begin //tar_RCD_FF_0, tar_RCD_FF_1, tar_RCD_FF_2, tar_RCD_FF_3
    
        if(!rst_n) begin
            tar_RCD_FF_0 <= 'd0;
            tar_RCD_FF_1 <= 'd0;
            tar_RCD_FF_2 <= 'd0;
            tar_RCD_FF_3 <= 'd0;
        end
        else if(cs==ST_READING_ONLY || cs==ST_READ_COMPUTE) begin
            tar_RCD_FF_0 <= tar_R_C_D_0;
            tar_RCD_FF_1 <= tar_R_C_D_1;
            tar_RCD_FF_2 <= tar_R_C_D_2;
            tar_RCD_FF_3 <= tar_R_C_D_3;
        end
        else begin
            tar_RCD_FF_0 <= tar_RCD_FF_0;
            tar_RCD_FF_1 <= tar_RCD_FF_1;
            tar_RCD_FF_2 <= tar_RCD_FF_2;
            tar_RCD_FF_3 <= tar_RCD_FF_3;
        end
    
    end
    
    always @(posedge clk) begin //tar_group_counter
        //(tar_group_counter)其實也是讀targetMEM的address
        if(!rst_n)
            tar_group_counter <= 'd0;
        else if(ns==ST_SEND_REQUEST)
            tar_group_counter <= 'd0;
        else if(ns==ST_READING_ONLY || ns==ST_READ_COMPUTE)
            tar_group_counter <= tar_group_counter + 1'b1;
        else
            tar_group_counter <= tar_group_counter;
            
    end
    
    always @(posedge clk) begin //img_group_counter
    
        if(!rst_n)
            img_group_counter <= 'd0;
        else if(cs==ST_IDLE && start)
            img_group_counter <= 'd1;
        else if(cs==ST_READ_COMPUTE && ns==ST_SEND_REQUEST)//所有T掃過一遍了
            img_group_counter <= img_group_counter + 1'b1;
        else
            img_group_counter <= img_group_counter;
        
    end
    
    always @(posedge clk) begin //tar_group_num
    
        if(!rst_n)
            tar_group_num <= 'd0;
        else if(cs==ST_IDLE && start)
            tar_group_num <= tar_descpt_group_num;
        else
            tar_group_num <= tar_group_num;
            
    end
    
    always @(posedge clk) begin //img_group_num
    
        if(!rst_n)
            img_group_num <= 'd0;
        else if(cs==ST_IDLE && start)
            img_group_num <= img_descpt_group_num;
        else
            img_group_num <= img_group_num;
            
    end
    
    always @(posedge clk) begin //cs
    
        if(!rst_n)
            cs <= ST_IDLE;
        else
            cs <= ns;
    
    end
    
    always @(*) begin //ns
    
        case(cs)
            ST_IDLE:
                if(start)
                    ns = ST_SEND_REQUEST;
                else
                    ns = ST_IDLE;
            ST_SEND_REQUEST:
                if(descriptor_valid)
                    ns = ST_READING_ONLY;
                else
                    ns = ST_SEND_REQUEST;
            ST_READING_ONLY:
                ns = ST_READ_COMPUTE;
            ST_READ_COMPUTE:
                if((tar_group_counter-1'b1 == tar_group_num) && (img_group_counter!=img_group_num))//全部target掃過且image還有
                    ns = ST_SEND_REQUEST;
                else if((tar_group_counter-1'b1 == tar_group_num) && (img_group_counter==img_group_num))//全部target掃過且image沒了
                    ns = ST_DONE;
                else//target還沒掃完
                    ns = ST_READ_COMPUTE;
            ST_DONE:
                ns = ST_IDLE;
        endcase
    
    end

endmodule