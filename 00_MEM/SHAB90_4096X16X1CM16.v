/*******************************************************************************

    (C) Copyright 2006-2010 Faraday Technology Corp. All Rights Reserved.
    This source code is an unpublished work belongs to Faraday Technology
    Corp.  It is considered a trade secret and is not to be divulged or
    used by parties who have not received written authorization from
    Faraday Technology Corp.

    Faraday's home page can be found at:
    http:/www.faraday-tech.com
    
 |-----------------------------------------------------------------------------|
                Verilog Behavior Simulation Model

                   Synchronous 1 Port SRAM 

                Module Name      : SHAB90_4096X16X1CM16
                Words            : 4096
                Bits             : 16
                Byte-Write       : 1
                Aspect Ratio     : 16
                Output Loading   : 0.01  (pf)
                Data Slew        : 0.008   (ns)
                CK Slew          : 0.008   (ns)
                Power Ring Width : 2  (um)
                
 |-----------------------------------------------------------------------------|

   Notice on usage: Fixed delay or timing data are given in this model.
                    It supports SDF back-annotation, please generate SDF file
                    by EDA tools to get the accurate timing.

 |-----------------------------------------------------------------------------|

   Warning : If customer's design viloate the set-up time or hold time criteria 
   of FTC's synchronous SRAM, it's possible to hit the meta-stable point of 
   latch circuit in the decoder and cause the data loss in the memory bitcell.
   So please follow the FTC memory IP's spec to design your product.

 |-----------------------------------------------------------------------------|

                Library          : FSD0A_B
                Memaker          : 200901.1.1
                Date             : 2016/07/18 22:49:06

 *******************************************************************************/

`resetall
`timescale 10ps/1ps


module SHAB90_4096X16X1CM16 (A, DO, DI,WEB, CK, OE, CS);

  `define    TRUE                 (1'b1)              
  `define    FALSE                (1'b0)              

  parameter  SYN_CS               = `TRUE;            
  parameter  NO_SER_TOH           = `TRUE;            
  parameter  AddressSize          = 12;               
  parameter  Bits                 = 16;               
  parameter  Words                = 4096;             
  parameter  Bytes                = 1;                
  parameter  AspectRatio          = 16;               
  parameter  TOH                  = (34:53:95);       

  output     [Bytes*Bits-1:0]     DO;                 
  input      [Bytes*Bits-1:0]     DI;                 
  input      [AddressSize-1:0]    A;                  
  input      WEB;                                     
  input      CK;                                      
  input      CS;                                      
  input      OE;                                      

`protect
  reg        [Bits-1:0]           Memory [Words-1:0];           


  wire       [Bytes*Bits-1:0]     DO_;                
  wire       [AddressSize-1:0]    A_;                 
  wire                            OE_;                
  wire       [Bits-1:0]           DI_;                
  wire                            WEB_;               
  wire                            CK_;                
  wire                            CS_;                


  wire                            con_A;              
  wire                            con_DI;             
  wire                            con_CK;             
  wire                            con_WEB;            

  reg        [AddressSize-1:0]    Latch_A;            
  reg        [Bits-1:0]           Latch_DI;           
  reg                             Latch_WEB;          
  reg                             Latch_CS;           


  reg        [AddressSize-1:0]    A_i;                
  reg        [Bits-1:0]           DI_i;               
  reg                             WEB_i;              
  reg                             CS_i;               

  reg                             n_flag_A0;          
  reg                             n_flag_A1;          
  reg                             n_flag_A2;          
  reg                             n_flag_A3;          
  reg                             n_flag_A4;          
  reg                             n_flag_A5;          
  reg                             n_flag_A6;          
  reg                             n_flag_A7;          
  reg                             n_flag_A8;          
  reg                             n_flag_A9;          
  reg                             n_flag_A10;         
  reg                             n_flag_A11;         
  reg                             n_flag_DI0;         
  reg                             n_flag_DI1;         
  reg                             n_flag_DI2;         
  reg                             n_flag_DI3;         
  reg                             n_flag_DI4;         
  reg                             n_flag_DI5;         
  reg                             n_flag_DI6;         
  reg                             n_flag_DI7;         
  reg                             n_flag_DI8;         
  reg                             n_flag_DI9;         
  reg                             n_flag_DI10;        
  reg                             n_flag_DI11;        
  reg                             n_flag_DI12;        
  reg                             n_flag_DI13;        
  reg                             n_flag_DI14;        
  reg                             n_flag_DI15;        
  reg                             n_flag_WEB;         
  reg                             n_flag_CS;          
  reg                             n_flag_CK_PER;      
  reg                             n_flag_CK_MINH;     
  reg                             n_flag_CK_MINL;     
  reg                             LAST_n_flag_WEB;    
  reg                             LAST_n_flag_CS;     
  reg                             LAST_n_flag_CK_PER; 
  reg                             LAST_n_flag_CK_MINH;
  reg                             LAST_n_flag_CK_MINL;
  reg        [AddressSize-1:0]    NOT_BUS_A;          
  reg        [AddressSize-1:0]    LAST_NOT_BUS_A;     
  reg        [Bits-1:0]           NOT_BUS_DI;         
  reg        [Bits-1:0]           LAST_NOT_BUS_DI;    

  reg        [AddressSize-1:0]    last_A;             
  reg        [AddressSize-1:0]    latch_last_A;       

  reg        [Bits-1:0]           DO_i;               

  reg                             LastClkEdge;        

  reg                             flag_A_x;           
  reg                             flag_CS_x;          

  reg                             NODELAY;            
  reg        [Bits-1:0]           DO_tmp;             
  event                           EventTOHDO;         
  event                           EventNegCS;         

  assign     DO_                  = {DO_i};
  assign     con_A                = CS_;
  assign     con_DI               = CS_ & (!WEB_);
  assign     con_WEB              = CS_;
  assign     con_CK               = CS_;

  bufif1     ido0            (DO[0], DO_[0], OE_);         
  bufif1     ido1            (DO[1], DO_[1], OE_);         
  bufif1     ido2            (DO[2], DO_[2], OE_);         
  bufif1     ido3            (DO[3], DO_[3], OE_);         
  bufif1     ido4            (DO[4], DO_[4], OE_);         
  bufif1     ido5            (DO[5], DO_[5], OE_);         
  bufif1     ido6            (DO[6], DO_[6], OE_);         
  bufif1     ido7            (DO[7], DO_[7], OE_);         
  bufif1     ido8            (DO[8], DO_[8], OE_);         
  bufif1     ido9            (DO[9], DO_[9], OE_);         
  bufif1     ido10           (DO[10], DO_[10], OE_);       
  bufif1     ido11           (DO[11], DO_[11], OE_);       
  bufif1     ido12           (DO[12], DO_[12], OE_);       
  bufif1     ido13           (DO[13], DO_[13], OE_);       
  bufif1     ido14           (DO[14], DO_[14], OE_);       
  bufif1     ido15           (DO[15], DO_[15], OE_);       
  buf        ick0            (CK_, CK);                    
  buf        ia0             (A_[0], A[0]);                
  buf        ia1             (A_[1], A[1]);                
  buf        ia2             (A_[2], A[2]);                
  buf        ia3             (A_[3], A[3]);                
  buf        ia4             (A_[4], A[4]);                
  buf        ia5             (A_[5], A[5]);                
  buf        ia6             (A_[6], A[6]);                
  buf        ia7             (A_[7], A[7]);                
  buf        ia8             (A_[8], A[8]);                
  buf        ia9             (A_[9], A[9]);                
  buf        ia10            (A_[10], A[10]);              
  buf        ia11            (A_[11], A[11]);              
  buf        idi_0           (DI_[0], DI[0]);              
  buf        idi_1           (DI_[1], DI[1]);              
  buf        idi_2           (DI_[2], DI[2]);              
  buf        idi_3           (DI_[3], DI[3]);              
  buf        idi_4           (DI_[4], DI[4]);              
  buf        idi_5           (DI_[5], DI[5]);              
  buf        idi_6           (DI_[6], DI[6]);              
  buf        idi_7           (DI_[7], DI[7]);              
  buf        idi_8           (DI_[8], DI[8]);              
  buf        idi_9           (DI_[9], DI[9]);              
  buf        idi_10          (DI_[10], DI[10]);            
  buf        idi_11          (DI_[11], DI[11]);            
  buf        idi_12          (DI_[12], DI[12]);            
  buf        idi_13          (DI_[13], DI[13]);            
  buf        idi_14          (DI_[14], DI[14]);            
  buf        idi_15          (DI_[15], DI[15]);            
  buf        ics0            (CS_, CS);                    
  buf        ioe0            (OE_, OE);                    
  buf        iweb            (WEB_, WEB);                  

  initial begin
    $timeformat (-12, 0, " ps", 20);
    flag_A_x = `FALSE;
    NODELAY = 1'b0;
  end

  always @(negedge CS_) begin
    if (SYN_CS == `FALSE) begin
       ->EventNegCS;
    end
  end
  always @(posedge CS_) begin
    if (SYN_CS == `FALSE) begin
       disable NegCS;
    end
  end

  always @(CK_) begin
    casez ({LastClkEdge,CK_})
      2'b01:
         begin
           last_A = latch_last_A;
           CS_monitor;
           pre_latch_data;
           memory_function;
           latch_last_A = A_;
         end
      2'b?x:
         begin
           ErrorMessage(0);
           if (CS_ !== 0) begin
              if (WEB_ !== 1'b1) begin
                 all_core_x(9999,1);
              end else begin
                 #0 disable TOHDO;
                 NODELAY = 1'b1;
                 DO_i = {Bits{1'bX}};
              end
           end
         end
    endcase
    LastClkEdge = CK_;
  end

  always @(
           n_flag_A0 or
           n_flag_A1 or
           n_flag_A2 or
           n_flag_A3 or
           n_flag_A4 or
           n_flag_A5 or
           n_flag_A6 or
           n_flag_A7 or
           n_flag_A8 or
           n_flag_A9 or
           n_flag_A10 or
           n_flag_A11 or
           n_flag_DI0 or
           n_flag_DI1 or
           n_flag_DI2 or
           n_flag_DI3 or
           n_flag_DI4 or
           n_flag_DI5 or
           n_flag_DI6 or
           n_flag_DI7 or
           n_flag_DI8 or
           n_flag_DI9 or
           n_flag_DI10 or
           n_flag_DI11 or
           n_flag_DI12 or
           n_flag_DI13 or
           n_flag_DI14 or
           n_flag_DI15 or
           n_flag_WEB or
           n_flag_CS or
           n_flag_CK_PER or
           n_flag_CK_MINH or
           n_flag_CK_MINL 
          )
     begin
       timingcheck_violation;
     end


  always @(EventTOHDO) 
    begin:TOHDO 
      #TOH 
      NODELAY <= 1'b0; 
      DO_i              =  {Bits{1'bX}}; 
      DO_i              <= DO_tmp; 
  end 

  always @(EventNegCS) 
    begin:NegCS
      #TOH 
      disable TOHDO;
      NODELAY = 1'b0; 
      DO_i              =  {Bits{1'bX}}; 
  end 

  task timingcheck_violation;
    integer i;
    begin
      if ((n_flag_CK_PER  !== LAST_n_flag_CK_PER)  ||
          (n_flag_CK_MINH !== LAST_n_flag_CK_MINH) ||
          (n_flag_CK_MINL !== LAST_n_flag_CK_MINL)) begin
          if (CS_ !== 1'b0) begin
             if (WEB_ !== 1'b1) begin
                all_core_x(9999,1);
             end
             else begin
                #0 disable TOHDO;
                NODELAY = 1'b1;
                DO_i = {Bits{1'bX}};
             end
          end
      end
      else begin
          NOT_BUS_A  = {
                         n_flag_A11,
                         n_flag_A10,
                         n_flag_A9,
                         n_flag_A8,
                         n_flag_A7,
                         n_flag_A6,
                         n_flag_A5,
                         n_flag_A4,
                         n_flag_A3,
                         n_flag_A2,
                         n_flag_A1,
                         n_flag_A0};

          NOT_BUS_DI  = {
                         n_flag_DI15,
                         n_flag_DI14,
                         n_flag_DI13,
                         n_flag_DI12,
                         n_flag_DI11,
                         n_flag_DI10,
                         n_flag_DI9,
                         n_flag_DI8,
                         n_flag_DI7,
                         n_flag_DI6,
                         n_flag_DI5,
                         n_flag_DI4,
                         n_flag_DI3,
                         n_flag_DI2,
                         n_flag_DI1,
                         n_flag_DI0};

          for (i=0; i<AddressSize; i=i+1) begin
             Latch_A[i] = (NOT_BUS_A[i] !== LAST_NOT_BUS_A[i]) ? 1'bx : Latch_A[i];
          end
          for (i=0; i<Bits; i=i+1) begin
             Latch_DI[i] = (NOT_BUS_DI[i] !== LAST_NOT_BUS_DI[i]) ? 1'bx : Latch_DI[i];
          end
          Latch_CS  =  (n_flag_CS  !== LAST_n_flag_CS)  ? 1'bx : Latch_CS;
          Latch_WEB = (n_flag_WEB !== LAST_n_flag_WEB)  ? 1'bx : Latch_WEB;
          memory_function;
      end

      LAST_NOT_BUS_A                 = NOT_BUS_A;
      LAST_NOT_BUS_DI                = NOT_BUS_DI;
      LAST_n_flag_WEB                = n_flag_WEB;
      LAST_n_flag_CS                 = n_flag_CS;
      LAST_n_flag_CK_PER             = n_flag_CK_PER;
      LAST_n_flag_CK_MINH            = n_flag_CK_MINH;
      LAST_n_flag_CK_MINL            = n_flag_CK_MINL;
    end
  endtask // end timingcheck_violation;

  task pre_latch_data;
    begin
      Latch_A                        = A_;
      Latch_DI                       = DI_;
      Latch_WEB                      = WEB_;
      Latch_CS                       = CS_;
    end
  endtask //end pre_latch_data
  task memory_function;
    begin
      A_i                            = Latch_A;
      DI_i                           = Latch_DI;
      WEB_i                          = Latch_WEB;
      CS_i                           = Latch_CS;

      if (CS_ == 1'b1) A_monitor;

      casez({WEB_i,CS_i})
        2'b11: begin
           if (AddressRangeCheck(A_i)) begin
              if (NO_SER_TOH == `TRUE) begin
                if (A_i !== last_A) begin
                   NODELAY = 1'b1;
                   DO_tmp = Memory[A_i];
                   ->EventTOHDO;
                end else begin
                   NODELAY = 1'b0;
                   DO_tmp  = Memory[A_i];
                   DO_i    = DO_tmp;
                end
              end else begin
                NODELAY = 1'b1;
                DO_tmp = Memory[A_i];
                ->EventTOHDO;
              end
           end
           else begin
                #0 disable TOHDO;
                NODELAY = 1'b1;
                DO_i = {Bits{1'bX}};
           end
        end
        2'b01: begin
           if (AddressRangeCheck(A_i)) begin
                Memory[A_i] = DI_i;
                NODELAY = 1'b1;
                DO_tmp = Memory[A_i];
                ->EventTOHDO;
                
           end else begin
                all_core_x(9999,1);
           end
        end
        2'b1x: begin
           #0 disable TOHDO;
           NODELAY = 1'b1;
           DO_i = {Bits{1'bX}};
        end
        2'b0x,
        2'bx1,
        2'bxx: begin
           if (AddressRangeCheck(A_i)) begin
                Memory[A_i] = {Bits{1'bX}};
                #0 disable TOHDO;
                NODELAY = 1'b1;
                DO_i = {Bits{1'bX}};
           end else begin
                all_core_x(9999,1);
           end
        end
      endcase
  end
  endtask //memory_function;

  task all_core_x;
     input byte_num;
     input do_x;

     integer byte_num;
     integer do_x;
     integer LoopCount_Address;
     begin
       if (do_x == 1) begin
          #0 disable TOHDO;
          NODELAY = 1'b1;
          DO_i = {Bits{1'bX}};
       end
       LoopCount_Address=Words-1;
       while(LoopCount_Address >=0) begin
         Memory[LoopCount_Address]={Bits{1'bX}};
         LoopCount_Address=LoopCount_Address-1;
      end
    end
  endtask //end all_core_x;

  task A_monitor;
     begin
       if (^(A_) !== 1'bX) begin
          flag_A_x = `FALSE;
       end
       else begin
          if (flag_A_x == `FALSE) begin
              flag_A_x = `TRUE;
              ErrorMessage(2);
          end
       end
     end
  endtask //end A_monitor;

  task CS_monitor;
     begin
       if (^(CS_) !== 1'bX) begin
          flag_CS_x = `FALSE;
       end
       else begin
          if (flag_CS_x == `FALSE) begin
              flag_CS_x = `TRUE;
              ErrorMessage(3);
          end
       end
     end
  endtask //end CS_monitor;

  task ErrorMessage;
     input error_type;
     integer error_type;

     begin
       case (error_type)
         0: $display("** MEM_Error: Abnormal transition occurred (%t) in Clock of %m",$time);
         1: $display("** MEM_Error: Read and Write the same Address, DO is unknown (%t) in clock of %m",$time);
         2: $display("** MEM_Error: Unknown value occurred (%t) in Address of %m",$time);
         3: $display("** MEM_Error: Unknown value occurred (%t) in ChipSelect of %m",$time);
         4: $display("** MEM_Error: Port A and B write the same Address, core is unknown (%t) in clock of %m",$time);
         5: $display("** MEM_Error: Clear all memory core to unknown (%t) in clock of %m",$time);
       endcase
     end
  endtask

  function AddressRangeCheck;
      input  [AddressSize-1:0] AddressItem;
      reg    UnaryResult;
      begin
        UnaryResult = ^AddressItem;
        if(UnaryResult!==1'bX) begin
           if (AddressItem >= Words) begin
              $display("** MEM_Error: Out of range occurred (%t) in Address of %m",$time);
           end
           AddressRangeCheck = `TRUE;
        end
        else begin
           AddressRangeCheck = `FALSE;
        end
      end
  endfunction //end AddressRangeCheck;

   specify
      specparam TAA  = (72:112:201);
      specparam TWDV = (72:112:201);
      specparam TRC  = (123:186:320);
      specparam THPW = (2:3:5);
      specparam TLPW = (14:20:33);
      specparam TAS  = (17:25:42);
      specparam TAH  = (0:0:0);
      specparam TWS  = (6:9:18);
      specparam TWH  = (4:6:8);
      specparam TDS  = (9:15:28);
      specparam TDH  = (3:4:5);
      specparam TCSS = (15:23:38);
      specparam TCSH = (4:5:8);
      specparam TOE      = (13:19:32);
      specparam TOZ      = (11:16:26);

      $setuphold ( posedge CK &&& con_A,          posedge A[0], TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          negedge A[0], TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          posedge A[1], TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          negedge A[1], TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          posedge A[2], TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          negedge A[2], TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          posedge A[3], TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          negedge A[3], TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          posedge A[4], TAS,     TAH,     n_flag_A4      );
      $setuphold ( posedge CK &&& con_A,          negedge A[4], TAS,     TAH,     n_flag_A4      );
      $setuphold ( posedge CK &&& con_A,          posedge A[5], TAS,     TAH,     n_flag_A5      );
      $setuphold ( posedge CK &&& con_A,          negedge A[5], TAS,     TAH,     n_flag_A5      );
      $setuphold ( posedge CK &&& con_A,          posedge A[6], TAS,     TAH,     n_flag_A6      );
      $setuphold ( posedge CK &&& con_A,          negedge A[6], TAS,     TAH,     n_flag_A6      );
      $setuphold ( posedge CK &&& con_A,          posedge A[7], TAS,     TAH,     n_flag_A7      );
      $setuphold ( posedge CK &&& con_A,          negedge A[7], TAS,     TAH,     n_flag_A7      );
      $setuphold ( posedge CK &&& con_A,          posedge A[8], TAS,     TAH,     n_flag_A8      );
      $setuphold ( posedge CK &&& con_A,          negedge A[8], TAS,     TAH,     n_flag_A8      );
      $setuphold ( posedge CK &&& con_A,          posedge A[9], TAS,     TAH,     n_flag_A9      );
      $setuphold ( posedge CK &&& con_A,          negedge A[9], TAS,     TAH,     n_flag_A9      );
      $setuphold ( posedge CK &&& con_A,          posedge A[10], TAS,     TAH,     n_flag_A10     );
      $setuphold ( posedge CK &&& con_A,          negedge A[10], TAS,     TAH,     n_flag_A10     );
      $setuphold ( posedge CK &&& con_A,          posedge A[11], TAS,     TAH,     n_flag_A11     );
      $setuphold ( posedge CK &&& con_A,          negedge A[11], TAS,     TAH,     n_flag_A11     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[0], TDS,     TDH,     n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[0], TDS,     TDH,     n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[1], TDS,     TDH,     n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[1], TDS,     TDH,     n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[2], TDS,     TDH,     n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[2], TDS,     TDH,     n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[3], TDS,     TDH,     n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[3], TDS,     TDH,     n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[4], TDS,     TDH,     n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[4], TDS,     TDH,     n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[5], TDS,     TDH,     n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[5], TDS,     TDH,     n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[6], TDS,     TDH,     n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[6], TDS,     TDH,     n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[7], TDS,     TDH,     n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[7], TDS,     TDH,     n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[8], TDS,     TDH,     n_flag_DI8     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[8], TDS,     TDH,     n_flag_DI8     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[9], TDS,     TDH,     n_flag_DI9     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[9], TDS,     TDH,     n_flag_DI9     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[10], TDS,     TDH,     n_flag_DI10    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[10], TDS,     TDH,     n_flag_DI10    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[11], TDS,     TDH,     n_flag_DI11    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[11], TDS,     TDH,     n_flag_DI11    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[12], TDS,     TDH,     n_flag_DI12    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[12], TDS,     TDH,     n_flag_DI12    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[13], TDS,     TDH,     n_flag_DI13    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[13], TDS,     TDH,     n_flag_DI13    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[14], TDS,     TDH,     n_flag_DI14    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[14], TDS,     TDH,     n_flag_DI14    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI[15], TDS,     TDH,     n_flag_DI15    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI[15], TDS,     TDH,     n_flag_DI15    );
      $setuphold ( posedge CK &&& con_WEB,        posedge WEB, TWS,     TWH,     n_flag_WEB     );
      $setuphold ( posedge CK &&& con_WEB,        negedge WEB, TWS,     TWH,     n_flag_WEB     );
      $setuphold ( posedge CK,                    posedge CS, TCSS,    TCSH,    n_flag_CS      );
      $setuphold ( posedge CK,                    negedge CS, TCSS,    TCSH,    n_flag_CS      );
      $period    ( posedge CK &&& con_CK,         TRC,                       n_flag_CK_PER  );
      $width     ( posedge CK &&& con_CK,         THPW,    0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK,         TLPW,    0,                n_flag_CK_MINL );
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[0] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[1] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[2] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[3] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[4] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[5] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[6] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[7] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[8] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[9] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[10] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[11] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[12] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[13] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[14] :1'bx)) = TAA  ;
      if ((WEB == 1)&&(NODELAY == 0))  (posedge CK => (DO[15] :1'bx)) = TAA  ;

      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[0] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[1] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[2] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[3] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[4] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[5] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[6] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[7] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[8] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[9] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[10] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[11] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[12] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[13] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[14] :1'bx)) =  TWDV ;
      if ((WEB == 0)&&(NODELAY == 0))  (posedge CK => (DO[15] :1'bx)) =  TWDV ;

      (OE => DO[0]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[1]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[2]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[3]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[4]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[5]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[6]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[7]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[8]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[9]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[10]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[11]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[12]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[13]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[14]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO[15]) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
   endspecify

`endprotect
endmodule

