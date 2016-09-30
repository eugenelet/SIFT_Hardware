module computeDescriptor(
    clk,
    rst_n,
    start,//same as the one into match
    kptRowCol,
    line_buffer_0,
    line_buffer_1,
    line_buffer_2,
    kpt_num,//can't change
    kpt_addr,
    blurred_addr,
    row_col_descpt1,//FF，send into match using wire
    row_col_descpt2,
    row_col_descpt3,
    row_col_descpt4,
    descriptor_request,//match is requesting
    descriptor_valid,//tell match, 4 descpts are ready
    readFrom,
    LB_WE
);

    input               clk,
                        rst_n,
                        start;
                         
    input               descriptor_request;
    
    input       [19:0]  kptRowCol;//kptMEM output wire
                    
    input       [5119:0]line_buffer_0,//drag 3 output of LB in
                        line_buffer_1,
                        line_buffer_2;
    
    output              LB_WE;
    
    output  reg [10:0]  kpt_addr;
    input       [10:0]  kpt_num;
    
    output      [8:0]   blurred_addr;
    
    output  reg [402:0] row_col_descpt1,
                        row_col_descpt2,
                        row_col_descpt3,
                        row_col_descpt4;
                    
    output              descriptor_valid;
    
    output  reg         readFrom;//readFrom layer 1 or layer 2 
    
    //////////////////////////////
    
    parameter   ST_IDLE             = 'd0,
                ST_WAITING_KPT      = 'd1,
                ST_GET_KPT          = 'd2,
                ST_GET_BLUR_ADDR    = 'd3,
                ST_WAITING_BLUR     = 'd4,
                ST_LB_GET           = 'd5,//line buffer
                ST_FINISH_ONE       = 'd6,
                ST_DESCPT_VALID     = 'd7;
                
    reg[2:0]    cs,
                ns;
    
    //////////////////////////////
    
    wire[10:0]  new_kpt_num;
    wire[95:0]  row_accu_result1,//from combination(8 x 12 = 96)
                row_accu_result2;
    
    reg [8:0]   blurred_addr;
    reg [8:0]   pre_modified_blurred_addr;
    
    reg [402:0] inner_row_col_descpt1,
                inner_row_col_descpt2,
                inner_row_col_descpt3,
                inner_row_col_descpt4;
    
    reg [18:0]  kptRowCol_FF;//catch from memory out

    reg [4:0]   cycle_count;//cycle_count of ST_LB_GET
    
    reg [2:0]   descpt_ready_num;//how many descpts are ready in inner_FF
    
    reg [95:0]  accu_8_dim_1,//8 int x 12 = 96
                accu_8_dim_2;
                
    //////////////////////////////
    
    assign new_kpt_num              = kpt_num - kpt_num[1:0];
    assign descriptor_valid         = (cs == ST_DESCPT_VALID)? 1'b1 : 1'b0;
    assign LB_WE                    = (ns == ST_LB_GET)? 1'b1 : 1'b0;
    
    //////////////////////////////
    
    accumulateOrientation u_accumulateOrientation(
        .LB_0               (line_buffer_0),
        .LB_1               (line_buffer_1),
        .LB_2               (line_buffer_2),
        .row                (kptRowCol_FF[18:10]),
        .col                (kptRowCol_FF[9:0]),
        .row_accu_result1   (row_accu_result1),
        .row_accu_result2   (row_accu_result2)
    );
    
    //////////////////////////////
    
    always @(posedge clk) begin //inner_row_col_descpt1
    
        if(!rst_n)
            inner_row_col_descpt1 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d0)
            inner_row_col_descpt1 <= { kptRowCol_FF, {384{1'b0}} };//write row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d0 && cycle_count=='d10)
            inner_row_col_descpt1 <= { inner_row_col_descpt1[402:384], accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2, {192{1'b0}} };//write first 16 dims
        else if(cs==ST_LB_GET && descpt_ready_num=='d0 && cycle_count=='d17)
            inner_row_col_descpt1 <= { inner_row_col_descpt1[402:192],  accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2};//write last 16 dims
        else
            inner_row_col_descpt1 <= inner_row_col_descpt1;
    
    end
    
    always @(posedge clk) begin //inner_row_col_descpt2
    
        if(!rst_n)
            inner_row_col_descpt2 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d1)
            inner_row_col_descpt2 <= { kptRowCol_FF, {384{1'b0}} };//write row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d1 && cycle_count=='d10)
            inner_row_col_descpt2 <= { inner_row_col_descpt2[402:384], accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2, {192{1'b0}} };//write first row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d1 && cycle_count=='d17)
            inner_row_col_descpt2 <= { inner_row_col_descpt2[402:192],  accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2};//write last row col
        else
            inner_row_col_descpt2 <= inner_row_col_descpt2;
    
    end
    
    always @(posedge clk) begin //inner_row_col_descpt3
    
        if(!rst_n)
            inner_row_col_descpt3 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d2)
            inner_row_col_descpt3 <= { kptRowCol_FF, {384{1'b0}} };//wirte row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d2 && cycle_count=='d10)
            inner_row_col_descpt3 <= { inner_row_col_descpt3[402:384], accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2, {192{1'b0}} };//write first 16 dims
        else if(cs==ST_LB_GET && descpt_ready_num=='d2 && cycle_count=='d17)
            inner_row_col_descpt3 <= { inner_row_col_descpt3[402:192],  accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2};//write last 16 dims
        else
            inner_row_col_descpt3 <= inner_row_col_descpt3;
    
    end
    
    always @(posedge clk) begin //inner_row_col_descpt4
    
        if(!rst_n)
            inner_row_col_descpt4 <= 'd0;
        else if(cs==ST_GET_KPT && descpt_ready_num=='d3)
            inner_row_col_descpt4 <= { kptRowCol_FF, {384{1'b0}} };//write row col
        else if(cs==ST_LB_GET && descpt_ready_num=='d3 && cycle_count=='d10)
            inner_row_col_descpt4 <= { inner_row_col_descpt4[402:384], accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2, {192{1'b0}} };//write first 16 dims
        else if(cs==ST_LB_GET && descpt_ready_num=='d3 && cycle_count=='d17)
            inner_row_col_descpt4 <= { inner_row_col_descpt4[402:192],  accu_8_dim_1 + row_accu_result1, accu_8_dim_2 + row_accu_result2};//write last 16 dims
        else
            inner_row_col_descpt4 <= inner_row_col_descpt4;
    
    end
    
    always @(posedge clk) begin //accu_8_dim_1, accu_8_dim_2
    
        if(!rst_n) begin
            accu_8_dim_1 <= 'd0;
            accu_8_dim_2 <= 'd0;
        end
        else if(cs == ST_WAITING_BLUR) begin
            accu_8_dim_1 <= 'd0;
            accu_8_dim_2 <= 'd0;
        end
        else if(cycle_count == 'd10) begin
            accu_8_dim_1 <= row_accu_result1;
            accu_8_dim_2 <= row_accu_result2;
        end
        else if(cycle_count>='d3 && cycle_count<='d17) begin
            accu_8_dim_1 <= accu_8_dim_1 + row_accu_result1;
            accu_8_dim_2 <= accu_8_dim_2 + row_accu_result2;
        end
        else begin
            accu_8_dim_1 <= accu_8_dim_1;
            accu_8_dim_2 <= accu_8_dim_2;
        end
        
    end
    
    always @(posedge clk) begin //cycle_count
    
        if(!rst_n)
            cycle_count <= 'd0;
        else if(cs == ST_WAITING_BLUR)
            cycle_count <= 'd1;
        else if(cs == ST_LB_GET)
            cycle_count <= cycle_count + 1'b1;
        else
            cycle_count <= cycle_count;
    
    end
    
    always @(posedge clk) begin //descpt_ready_num
    
        if(!rst_n)
            descpt_ready_num <= 'd0;
        else if(cs == ST_IDLE)
            descpt_ready_num <= 'd0;
        else if(cs == ST_DESCPT_VALID)//送出去了，歸0
            descpt_ready_num <= 'd0;
        else if(cs==ST_LB_GET && ns==ST_FINISH_ONE)//擺好一個
            descpt_ready_num <= descpt_ready_num + 1'b1;
        else
            descpt_ready_num <= descpt_ready_num;
            
    end
    
    always @(posedge clk) begin //readFrom
    
        if(!rst_n)
            readFrom <= 1'b0;
        else if(cs == ST_WAITING_KPT)
            readFrom <= kptRowCol[19];
        else
            readFrom <= readFrom;
    
    end

    always @(posedge clk) begin //kpt_addr
    
        if(!rst_n)
            kpt_addr <= 'd0;
        else if(cs == ST_IDLE)
            kpt_addr <= 'd0;
        else if(cs==ST_LB_GET && ns==ST_FINISH_ONE)
            kpt_addr <= kpt_addr + 1'b1;
        else
            kpt_addr <= kpt_addr;
            
    end
    
    always @(posedge clk) begin //kptRowCol_FF
    
        if(!rst_n)
            kptRowCol_FF <= 'd0;
        else if(cs == ST_WAITING_KPT)
            kptRowCol_FF <= kptRowCol[18:0];
        else
            kptRowCol_FF <= kptRowCol_FF;
            
    end
    
    always @(posedge clk) begin //blurred_addr
    
        if(!rst_n)
            blurred_addr <= 'd0;
        else if(cs == ST_GET_KPT)
            blurred_addr <= kptRowCol_FF[18:10] - 4'b1000;//從kptRow - 8那列開始讀
        else
            blurred_addr <= blurred_addr + 1'b1;
    
    end
    
    always @(posedge clk) begin //row_col_descpt1, row_col_descpt2, row_col_descpt3, row_col_descpt4
    
        if(!rst_n) begin
            row_col_descpt1 <= 'd0;
            row_col_descpt2 <= 'd0;
            row_col_descpt3 <= 'd0;
            row_col_descpt4 <= 'd0;
        end
        else if(ns == ST_DESCPT_VALID) begin
            row_col_descpt1 <= inner_row_col_descpt1;
            row_col_descpt2 <= inner_row_col_descpt2;
            row_col_descpt3 <= inner_row_col_descpt3;
            row_col_descpt4 <= inner_row_col_descpt4;
        end
        else begin
            row_col_descpt1 <= row_col_descpt1;
            row_col_descpt2 <= row_col_descpt2;
            row_col_descpt3 <= row_col_descpt3;
            row_col_descpt4 <= row_col_descpt4;
        end
    
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
                    ns = ST_WAITING_KPT;
                else
                    ns = ST_IDLE;
            ST_WAITING_KPT:
                ns = ST_GET_KPT;
            ST_GET_KPT:
                ns = ST_GET_BLUR_ADDR;
            ST_GET_BLUR_ADDR:
                ns = ST_WAITING_BLUR;
            ST_WAITING_BLUR:
                ns = ST_LB_GET;
            ST_LB_GET:
                if(cycle_count == 'd17)
                    ns = ST_FINISH_ONE;
                else
                    ns = ST_LB_GET;
            ST_FINISH_ONE:
                if(descpt_ready_num != 3'b100)//not finish 4 yet
                    ns = ST_WAITING_KPT;
                else if(descriptor_request == 1'b1)
                    ns = ST_DESCPT_VALID;
                else
                    ns = ST_FINISH_ONE;
            ST_DESCPT_VALID:
                if(readFrom==1'b1 && kpt_addr==new_kpt_num)
                    ns = ST_IDLE;
                else
                    ns = ST_WAITING_KPT;
        endcase
    
    end
    
endmodule