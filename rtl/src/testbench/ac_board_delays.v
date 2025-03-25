/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Board Delay for Address/Command Lane                          *
 *                                                                            *
 *****************************************************************************/

`timescale 1ps/1ps  // Set the timescale for board delays

module ac_board_dly
  #(
    // Parameters
    parameter pNO_OF_RANKS = 4,  // number of ranks
    parameter pNO_OF_CSNS  = `DWC_PHY_CS_N_WIDTH,
    parameter pNO_OF_CKES  = `DWC_PHY_CKE_WIDTH,
    parameter pNO_OF_ODTS  = `DWC_PHY_ODT_WIDTH,
    parameter pCK_WIDTH    = 3,  // number of CK pairs
    parameter pBANK_WIDTH  = 4,  // width of bank address
    parameter pADDR_WIDTH  = 18,  // width of address
    parameter pCID_WIDTH   = 1  // width of address    
   )
   (
    output reg  [pCK_WIDTH   -1:0] phyio_ck_do_dly,
    output reg  [pCK_WIDTH   -1:0] phyio_ck_n_do_dly,
    output reg  [pNO_OF_CKES-1:0]  phyio_cke_do_dly,
    output reg  [pNO_OF_ODTS-1:0]  phyio_odt_do_dly,
    output reg  [pNO_OF_CSNS-1:0]  phyio_cs_n_do_dly,
    output reg                     phyio_act_n_do_dly,
    output reg                     phyio_parity_do_dly,
    output reg  [pBANK_WIDTH -1:0] phyio_ba_do_dly,
    output reg  [pADDR_WIDTH -1:0] phyio_a_do_dly,
    output reg                     phyio_alertn_do_dly,  
    output reg  [pCID_WIDTH -1:0]  phyio_cid_do_dly, 
                                  
    output reg  [pCK_WIDTH   -1:0] phyio_ck_di_dly,
    output reg  [pCK_WIDTH   -1:0] phyio_ck_n_di_dly,
    output reg  [pNO_OF_CKES-1:0]  phyio_cke_di_dly,
    output reg  [pNO_OF_ODTS-1:0]  phyio_odt_di_dly,
    output reg  [pNO_OF_CSNS-1:0]  phyio_cs_n_di_dly,
    output reg                     phyio_act_n_di_dly,
    output reg                     phyio_parity_di_dly,
    output reg  [pBANK_WIDTH -1:0] phyio_ba_di_dly,
    output reg  [pADDR_WIDTH -1:0] phyio_a_di_dly,
    output reg                     phyio_alertn_di_dly, 
    output reg  [pCID_WIDTH -1:0]  phyio_cid_di_dly,       
                                   
    input  wire [pCK_WIDTH   -1:0] phyio_ck_do,
    input  wire [pCK_WIDTH   -1:0] phyio_ck_n_do,
    input  wire [pNO_OF_CKES-1:0]  phyio_cke_do,
    input  wire [pNO_OF_ODTS-1:0]  phyio_odt_do,
    input  wire [pNO_OF_CSNS-1:0]  phyio_cs_n_do,
    input  wire                    phyio_act_n_do,
    input  wire                    phyio_parity_do,
    input  wire [pBANK_WIDTH -1:0] phyio_ba_do,
    input  wire [pADDR_WIDTH -1:0] phyio_a_do,
    input  wire                    phyio_alertn_do,  
    input  wire [pCID_WIDTH -1:0]  phyio_cid_do,       
                                 
    input  wire [pCK_WIDTH   -1:0] phyio_ck_di,
    input  wire [pCK_WIDTH   -1:0] phyio_ck_n_di,
    input  wire [pNO_OF_CKES-1:0]  phyio_cke_di,
    input  wire [pNO_OF_ODTS-1:0]  phyio_odt_di,
    input  wire [pNO_OF_CSNS-1:0]  phyio_cs_n_di,
    input  wire                    phyio_act_n_di,
    input  wire                    phyio_parity_di,
    input  wire [pBANK_WIDTH-1:0]  phyio_ba_di,
    input  wire [pADDR_WIDTH-1:0]  phyio_a_di,
    input  wire                    phyio_alertn_di,  
    input  wire [pCID_WIDTH -1:0]  phyio_cid_di   
   );


    
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------

  // Fixed (board) delays
  integer      addr_do_board_dly   [0:pADDR_WIDTH-1];
  integer      addr_di_board_dly   [0:pADDR_WIDTH-1];
  integer      ck_do_board_dly     [0:pCK_WIDTH-1];
  integer      ck_di_board_dly     [0:pCK_WIDTH-1];
  integer      cke_do_board_dly    [0:pNO_OF_CKES-1];
  integer      cke_di_board_dly    [0:pNO_OF_CKES-1]; 
  integer      odt_do_board_dly    [0:pNO_OF_ODTS-1];
  integer      odt_di_board_dly    [0:pNO_OF_ODTS-1];  
  integer      csn_do_board_dly    [0:pNO_OF_CSNS-1];
  integer      csn_di_board_dly    [0:pNO_OF_CSNS-1]; 
  integer      bank_do_board_dly   [0:pBANK_WIDTH-1];
  integer      bank_di_board_dly   [0:pBANK_WIDTH-1];  
  integer      actn_do_board_dly   ;
  integer      actn_di_board_dly   ; 
  integer      alertn_do_board_dly ;
  integer      alertn_di_board_dly ;
  integer      parity_do_board_dly ;
  integer      parity_di_board_dly ; 
  integer      cid_do_board_dly    [0:pCID_WIDTH-1];
  integer      cid_di_board_dly    [0:pCID_WIDTH-1];   
  
  genvar ac_bit, ck_bit;        



  //---------------------------------------------------------------------------
  // Internal Delay Setting Tasks
  //---------------------------------------------------------------------------
  // task to set delays on AC - these delays are set internal to this module
  // delay initialization
  // --------------------
  // all delays are by default initialized to zero
  initial
    begin: initialize_delays
      integer addr_cmd_bit_no;

      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pADDR_WIDTH; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        addr_do_board_dly[addr_cmd_bit_no]    = 0;
        addr_di_board_dly[addr_cmd_bit_no]    = 0;
      end  
      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pCK_WIDTH; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        ck_do_board_dly[addr_cmd_bit_no]    = 0;
        ck_di_board_dly[addr_cmd_bit_no]    = 0;
      end 
      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pNO_OF_CKES; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        cke_do_board_dly[addr_cmd_bit_no]    = 0;
        cke_di_board_dly[addr_cmd_bit_no]    = 0;
      end  
      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pNO_OF_ODTS; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        odt_do_board_dly[addr_cmd_bit_no]    = 0;
        odt_di_board_dly[addr_cmd_bit_no]    = 0;
      end  
      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pNO_OF_CSNS; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        csn_do_board_dly[addr_cmd_bit_no]    = 0;
        csn_di_board_dly[addr_cmd_bit_no]    = 0;
      end  
      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pBANK_WIDTH; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        bank_do_board_dly[addr_cmd_bit_no]    = 0;
        bank_di_board_dly[addr_cmd_bit_no]    = 0;
      end
      for (addr_cmd_bit_no=0; addr_cmd_bit_no<pCID_WIDTH; addr_cmd_bit_no=addr_cmd_bit_no+1) begin
        cid_do_board_dly[addr_cmd_bit_no]    = 0;
        cid_di_board_dly[addr_cmd_bit_no]    = 0;
      end      
      actn_do_board_dly    = 0;
      actn_di_board_dly    = 0;
      alertn_do_board_dly  = 0;
      alertn_di_board_dly  = 0;        
      parity_do_board_dly  = 0;
      parity_di_board_dly  = 0;  
    end
 

  task set_ac_signal_board_delay;
    input integer ac_signal;
    input         direction;
    input integer index;
    input integer dly;
    
    begin
      // NOTE: per rank delays are not implemented yet
      case (direction)
      `OUT: begin
        case(ac_signal)
          `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8,  
          `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17  : begin
            addr_do_board_dly[ac_signal - `ADDR_0] = dly;
          end
          `CMD_BA0,  `CMD_BA1,  `CMD_BA2,  `CMD_BA3 : begin
            bank_do_board_dly [ac_signal - `CMD_BA0] = dly;
          end
          `CMD_ACT: begin
            actn_do_board_dly = dly;
          end
          `CMD_PARIN: begin
            parity_do_board_dly = dly;
          end
          `CMD_ALERTN: begin
            alertn_do_board_dly = dly;
          end          
          `CMD_ODT: begin
            odt_do_board_dly[index] = dly;
          end
          `CMD_CKE: begin
            cke_do_board_dly[index] = dly;
          end
          `CMD_CSN: begin
            csn_do_board_dly[index] = dly;
          end
          `CMD_CID0, `CMD_CID1, `CMD_CID2: begin
            cid_do_board_dly [ac_signal - `CMD_CID0] = dly;
          end          
          `AC_CK0,  `AC_CK1,  `AC_CK2,  `AC_CK3  : begin
            ck_do_board_dly  [ac_signal - `AC_CK0] = dly;
          end
	      default   : begin
            $display("-> %0t: ==> WARNING: [set_ac_signal_board_delay] incorrect or missing direction/signal specification on task call.", $time);
          end
        endcase
      end  
      `IN: begin
        case(ac_signal)
          `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8,  
          `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17  : begin
            addr_di_board_dly[ac_signal - `ADDR_0] = dly;
          end
          `CMD_BA0,  `CMD_BA1,  `CMD_BA2,  `CMD_BA3 : begin
            bank_di_board_dly [ac_signal - `CMD_BA0] = dly;
          end
          `CMD_ACT: begin
            actn_di_board_dly = dly;
          end
          `CMD_PARIN: begin
            parity_di_board_dly = dly;
          end
          `CMD_ALERTN: begin
            alertn_di_board_dly = dly;
          end            
          `CMD_ODT: begin
            odt_di_board_dly[index] = dly;
          end
          `CMD_CKE: begin
            cke_di_board_dly[index] = dly;
          end
          `CMD_CSN: begin
            csn_di_board_dly[index] = dly;
          end
          `CMD_CID0, `CMD_CID1, `CMD_CID2: begin
            cid_di_board_dly [ac_signal - `CMD_CID0] = dly;
          end            
          `AC_CK0,  `AC_CK1,  `AC_CK2,  `AC_CK3  : begin
            ck_di_board_dly  [ac_signal - `AC_CK0] = dly;
          end
	      default   : begin
            $display("-> %0t: ==> WARNING: [set_ac_signal_board_delay] incorrect or missing direction/signal specification on task call.", $time);
          end
        endcase
      end  
      endcase // case ({direction, ac_signal})
    end
  endtask // set_ac_signal_board_delay
  
  generate
     
    for(ac_bit=0; ac_bit<pADDR_WIDTH; ac_bit=ac_bit+1) begin : gaddr_dly
      initial   phyio_a_do_dly[ac_bit] <= phyio_a_do[ac_bit];
      initial   phyio_a_di_dly[ac_bit] <= phyio_a_di[ac_bit];

      always@(phyio_a_do[ac_bit])  phyio_a_do_dly[ac_bit]     <= #(addr_do_board_dly[ac_bit]) phyio_a_do[ac_bit];                                                
      always@(phyio_a_di[ac_bit])  phyio_a_di_dly[ac_bit]     <= #(addr_di_board_dly[ac_bit]) phyio_a_di[ac_bit];
    end

    for(ac_bit=0; ac_bit<pBANK_WIDTH; ac_bit=ac_bit+1) begin : gba_dly
      initial   phyio_ba_do_dly[ac_bit] <= phyio_ba_do[ac_bit];
      initial   phyio_ba_di_dly[ac_bit] <= phyio_ba_di[ac_bit];

      always@(phyio_ba_do[ac_bit])  phyio_ba_do_dly[ac_bit]   <= #(bank_do_board_dly[ac_bit]) phyio_ba_do[ac_bit];
      always@(phyio_ba_di[ac_bit])  phyio_ba_di_dly[ac_bit]   <= #(bank_di_board_dly[ac_bit]) phyio_ba_di[ac_bit];      
    end
    
    initial   phyio_act_n_do_dly <=  phyio_act_n_do ;
    initial   phyio_act_n_di_dly <=  phyio_act_n_di ;
    
    initial   phyio_parity_do_dly <=  phyio_parity_do ;
    initial   phyio_parity_di_dly <=  phyio_parity_di ;
    
    initial   phyio_alertn_do_dly <=  phyio_alertn_do ;    
    initial   phyio_alertn_di_dly <=  phyio_alertn_di ;
    
    always@(phyio_act_n_do)   phyio_act_n_do_dly   <= #(actn_do_board_dly) phyio_act_n_do ;
    always@(phyio_act_n_di)   phyio_act_n_di_dly   <= #(actn_di_board_dly) phyio_act_n_di ;

    always@(phyio_parity_do)  phyio_parity_do_dly  <= #(parity_do_board_dly) phyio_parity_do ;
    always@(phyio_parity_di)  phyio_parity_di_dly  <= #(parity_di_board_dly) phyio_parity_di ;
    
    always@(phyio_alertn_do)  phyio_alertn_do_dly  <= #(alertn_do_board_dly) phyio_alertn_do ;
    always@(phyio_alertn_di)  phyio_alertn_di_dly  <= #(alertn_di_board_dly) phyio_alertn_di ;    

    for(ac_bit=0; ac_bit<pNO_OF_CSNS; ac_bit=ac_bit+1) begin : g_csn_dlys
      initial  phyio_cs_n_do_dly[ac_bit]  <=  phyio_cs_n_do[ac_bit] ;
      initial  phyio_cs_n_di_dly[ac_bit]  <=  phyio_cs_n_di[ac_bit] ;

      always@(phyio_cs_n_do[ac_bit])  phyio_cs_n_do_dly[ac_bit]     <= #(csn_do_board_dly[ac_bit]) phyio_cs_n_do[ac_bit] ;
      always@(phyio_cs_n_di[ac_bit])  phyio_cs_n_di_dly[ac_bit]     <= #(csn_di_board_dly[ac_bit]) phyio_cs_n_di[ac_bit] ;
    end

    for(ac_bit=0; ac_bit<pNO_OF_CKES; ac_bit=ac_bit+1) begin : g_cke_dlys
      initial  phyio_cke_do_dly[ac_bit]  <=  phyio_cke_do[ac_bit] ;
      initial  phyio_cke_di_dly[ac_bit]  <=  phyio_cke_di[ac_bit] ;

      always@(phyio_cke_do[ac_bit])  phyio_cke_do_dly[ac_bit]     <= #(cke_do_board_dly[ac_bit]) phyio_cke_do[ac_bit] ;
      always@(phyio_cke_di[ac_bit])  phyio_cke_di_dly[ac_bit]     <= #(cke_di_board_dly[ac_bit]) phyio_cke_di[ac_bit] ;
    end

    for(ac_bit=0;ac_bit<pNO_OF_ODTS;ac_bit=ac_bit+1) begin : g_odt_dlys
      initial  phyio_odt_do_dly[ac_bit]  <=  phyio_odt_do[ac_bit] ;
      initial  phyio_odt_di_dly[ac_bit]  <=  phyio_odt_di[ac_bit] ;

      always@(phyio_odt_do[ac_bit])  phyio_odt_do_dly[ac_bit]     <= #(odt_do_board_dly[ac_bit]) phyio_odt_do[ac_bit] ;
      always@(phyio_odt_di[ac_bit])  phyio_odt_di_dly[ac_bit]     <= #(odt_di_board_dly[ac_bit]) phyio_odt_di[ac_bit] ;
    end
    
    for(ac_bit=0;ac_bit<pCID_WIDTH;ac_bit=ac_bit+1) begin : g_cid_dlys
      initial  phyio_cid_do_dly[ac_bit]  <=  phyio_cid_do[ac_bit] ;
      initial  phyio_cid_di_dly[ac_bit]  <=  phyio_cid_di[ac_bit] ;

      always@(phyio_cid_do[ac_bit])  phyio_cid_do_dly[ac_bit]     <= #(cid_do_board_dly[ac_bit]) phyio_cid_do[ac_bit] ;
      always@(phyio_cid_di[ac_bit])  phyio_cid_di_dly[ac_bit]     <= #(cid_di_board_dly[ac_bit]) phyio_cid_di[ac_bit] ;
    end    

    for(ck_bit=0;ck_bit<pCK_WIDTH;ck_bit=ck_bit+1) begin : g_ck_dlys
      initial phyio_ck_do_dly[ck_bit]   <= phyio_ck_do[ck_bit] ;
      initial phyio_ck_n_do_dly[ck_bit] <= phyio_ck_n_do[ck_bit] ;
      initial phyio_ck_di_dly[ck_bit]   <= phyio_ck_di[ck_bit] ;
      initial phyio_ck_n_di_dly[ck_bit] <= phyio_ck_n_di[ck_bit] ;

      always@(phyio_ck_do[ck_bit])    phyio_ck_do_dly[ck_bit]   <= #(ck_do_board_dly[ck_bit]) phyio_ck_do[ck_bit] ;
      always@(phyio_ck_n_do[ck_bit])  phyio_ck_n_do_dly[ck_bit] <= #(ck_do_board_dly[ck_bit]) phyio_ck_n_do[ck_bit] ;
      always@(phyio_ck_di[ck_bit])    phyio_ck_di_dly[ck_bit]   <= #(ck_di_board_dly[ck_bit]) phyio_ck_di[ck_bit] ;
      always@(phyio_ck_n_di[ck_bit])  phyio_ck_n_di_dly[ck_bit] <= #(ck_di_board_dly[ck_bit]) phyio_ck_n_di[ck_bit] ;
    end

  endgenerate
  
endmodule // ac_board_dly

