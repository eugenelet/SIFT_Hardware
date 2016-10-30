module compareDist(//combinational
    tar,
    img0,
    img1,
    img2,
    img3,
    matched_MEM,
    WE,
    matched_MEM_din,
    firstImgGrp
);

    input       [383:0] tar;
    input       [402:0] img0,
                        img1,
                        img2,
                        img3;
    input       [48:0]  matched_MEM;
    input               firstImgGrp;
    output              WE;
    output  reg [48:0]  matched_MEM_din;//min's row, min's col, min, min2
    
    //////////////////////////////
    
    wire        [14:0]  dist0,
                        dist1,
                        dist2,
                        dist3;
                        
    wire        [14:0]  mem_min,
                        mem_min2;
    
    wire                comp_result_01,
                        comp_result_23,
                        comp_result_min,
                        comp_result_min2;
                                            
    wire        [14:0]  min_01,//smaller of 01
                        max_01,//greater of 01
                        min_23,//smaller of 23
                        max_23;//greater of 23
    
    wire        [14:0]  min,
                        min2,
                        new_min,
                        new_min2;
                        
    wire                minHasChanged,
                        min_less_Mmin2,
                        min2_less_Mmin;
    
    reg [1:0]           whoIsMin;
    
    //////////////////////////////
    
    assign mem_min                  = matched_MEM[29:15];//min of MEM now
    assign mem_min2                 = matched_MEM[14:0];//min2 of MEM now
            
    assign comp_result_01           = dist0 < dist1;
    assign min_01                   = (comp_result_01)? dist0 : dist1;
    assign max_01                   = (comp_result_01)? dist1 : dist0;
            
    assign comp_result_23           = dist2 < dist3;
    assign min_23                   = (comp_result_23)? dist2 : dist3;
    assign max_23                   = (comp_result_23)? dist3 : dist2;
            
    assign comp_result_min          = min_01 < min_23;
    assign min                      = (comp_result_min)? min_01 : min_23;
    assign comp_result_min2         = (comp_result_min)? min_23 < max_01 : min_01 < max_23;//第二層輸的，有沒有比第一層輸的還小
    assign min2                     = (comp_result_min2)? ((comp_result_min)? min_23 : min_01) : ((comp_result_min)? max_01 : max_23);
    
    assign minHasChanged            = min < mem_min;
    assign new_min                  = (minHasChanged)? min : mem_min;
    assign min_less_Mmin2           = min < mem_min2;
    assign min2_less_Mmin           = min2 < mem_min;
    assign new_min2                 = (minHasChanged)? ((min2_less_Mmin)? min2 : mem_min) : ((min_less_Mmin2)? min : mem_min2);
    
    assign WE                       = minHasChanged || min_less_Mmin2;//其實如果WE=0, matched_MEM_din會是原本的讀出來的，所以WE也可以是1
    
    //////////////////////////////
    
    computeDistance u_computeDistance_0( //dist0
        .A          (tar),
        .B          (img0[383:0]),
        .distance   (dist0)
    );
    
    computeDistance u_computeDistance_1( //dist1
        .A          (tar),
        .B          (img1[383:0]),
        .distance   (dist1)
    );
    
    computeDistance u_computeDistance_2( //dist2
        .A          (tar),
        .B          (img2[383:0]),
        .distance   (dist2)
    );
    
    computeDistance u_computeDistance_3( //dist3
        .A          (tar),
        .B          (img3[383:0]),
        .distance   (dist3)
    );

    //////////////////////////////
    
    always @(*) begin //matched_MEM_din
    
        case(whoIsMin)
            2'b00://0 is smallest
                matched_MEM_din = (firstImgGrp)? { img0[402:384], min, min2 } : { ((minHasChanged)? img0[402:384] : matched_MEM[48:30]), new_min, new_min2 };//min, min2, mem_min, mem_min2 => new_min, new_min2
            2'b01:                                                                                         
                matched_MEM_din = (firstImgGrp)? { img1[402:384], min, min2 } : { ((minHasChanged)? img1[402:384] : matched_MEM[48:30]), new_min, new_min2 };
            2'b10:                                                                                         
                matched_MEM_din = (firstImgGrp)? { img2[402:384], min, min2 } : { ((minHasChanged)? img2[402:384] : matched_MEM[48:30]), new_min, new_min2 };
            2'b11:                                                                                  
                matched_MEM_din = (firstImgGrp)? { img3[402:384], min, min2 } : { ((minHasChanged)? img3[402:384] : matched_MEM[48:30]), new_min, new_min2 };
            default:
                matched_MEM_din = 'd0;
        endcase
    
    end
    
    always @(*) begin //whoIsMin
    
        case({comp_result_min, comp_result_01, comp_result_23})
            3'b000:
                whoIsMin = 2'b11;//dist3 is min
            3'b001:
                whoIsMin = 2'b10;
            3'b010:
                whoIsMin = 2'b11;
            3'b011:
                whoIsMin = 2'b10;
            3'b100:
                whoIsMin = 2'b01;
            3'b101:
                whoIsMin = 2'b01;
            3'b110:
                whoIsMin = 2'b00;
            3'b111:
                whoIsMin = 2'b00;
            default:
                whoIsMin = 4'b0000;
        endcase
    
    end
    
endmodule