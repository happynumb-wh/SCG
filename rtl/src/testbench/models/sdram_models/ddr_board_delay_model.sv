/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR SDRAM Chip                                                *
 *              Individual SDRAM chip from different vendor and either DDR or *
 *              DDR2                                                          *
 *                                                                            *
 *****************************************************************************/

`timescale 1ps/10fs  // Set the timescale for board delays

module ddr_board_delay_model(input logic ck, ck_n, cke, odt, cs_n,
		       	     input [`SDRAM_ADDR_WIDTH-1:0] a,
		       	     inout [`SDRAM_BYTE_WIDTH-1:0] dm,
		       	     inout [`SDRAM_BYTE_WIDTH-1:0] dqs,
                 output [`SDRAM_BYTE_WIDTH-1:0] mydqs,
			     inout [`SDRAM_BYTE_WIDTH-1:0] dqs_n,
			     inout [`SDRAM_DATA_WIDTH-1:0] dq,
			     input logic ras_n, cas_n, we_n,
			     input logic act_n, parity,
                             `ifdef DDR4
                             input logic alert_n,
                             input [`DWC_CID_WIDTH-1:0] cid,
                             `endif
			     input [`DWC_PHY_BG_WIDTH-1:0] bg,
                             `ifdef DDR4
			     input [`DWC_PHY_BA_WIDTH-1:0] ba,
                             `else
			     input [`SDRAM_BANK_WIDTH-1:0] ba,
                             `endif
			     output reg ck_i, ck_n_i, cke_i, odt_i, cs_n_i,
			     output reg [`SDRAM_ADDR_WIDTH-1:0] a_i,
			     output [`SDRAM_BYTE_WIDTH-1:0] dm_i,
			     output [`SDRAM_BYTE_WIDTH-1:0] dqs_i,
			     output [`SDRAM_BYTE_WIDTH-1:0] dqs_n_i,
			     output [`SDRAM_DATA_WIDTH-1:0] dq_i,
			     output reg ras_n_i, cas_n_i, we_n_i,
			     output reg act_n_i, parity_i,
                             `ifdef DDR4
                             output reg alert_n_i,
                             output reg [`DWC_CID_WIDTH-1:0] cid_i,
                             `endif
			     output reg [`DWC_PHY_BG_WIDTH-1:0] bg_i,
                             `ifdef DDR4
			     output reg [`DWC_PHY_BA_WIDTH-1:0] ba_i
                             `else
			     output reg [`SDRAM_BANK_WIDTH-1:0] ba_i
                             `endif
                             `ifdef LRDIMM_MULTI_RANK
          , input  rst_n
          , input  mwd_train
                             `endif          
			                 );

   // define PI to use in $sin function
   parameter        pPI             = 3.14159265;
   
   //define "fake" very large CLK period for VMM sims -> this will lead to optimistic ISI
`ifdef VMM_VERIF
   `define CLK_PRD    3.0
`endif
                                                              
`ifdef DDR4MPHY
  parameter pADDR_WIDTH  = `DWC_PHY_ADDR_WIDTH;
`else
  parameter pADDR_WIDTH  = `SDRAM_ADDR_WIDTH;
`endif

  // board delays   
  `ifdef DDR4MPHY
  integer addr_sdram_dly   [`DWC_PHY_ADDR_WIDTH-1:0];
  `else
  integer addr_sdram_dly   [17:0];
  `endif
  integer ck_sdram_dly;
  integer ckn_sdram_dly;  
  
  `ifdef DDR4
  integer babg_sdram_dly     [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
  `else
  integer babg_sdram_dly     [`SDRAM_BANK_WIDTH-1:0];
  `endif  

  integer csn_sdram_dly;
  integer cid_sdram_dly    [`DWC_CID_WIDTH-1:0]; 
  integer cke_sdram_dly;  
  integer odt_sdram_dly;  
  integer actn_sdram_dly; 
  integer parin_sdram_dly;   
  integer alertn_sdram_dly; 
    
  integer dq_do_sdram_dly  [31:0];
  integer dq_di_sdram_dly  [31:0];
  integer dm_di_sdram_dly  [3:0];
  integer dm_do_sdram_dly  [3:0];  
  integer dqs_do_sdram_dly [3:0];
  integer dqs_di_sdram_dly [3:0];
  integer dqsn_do_sdram_dly[3:0];
  integer dqsn_di_sdram_dly[3:0];

  integer ras_n_sdram_dly;
  integer cas_n_sdram_dly;
  integer we_n_sdram_dly;
  localparam pWL_WIDTH = 50;
  localparam pRL_WIDTH = 50;
  
  `ifdef DDR3
    `ifdef DWC_CUSTOM_PIN_MAP
      assign ras_n_sdram_dly = (`DWC_DDR32_RAS_MAP == `DWC_ACTN_INDX) ? actn_sdram_dly : (
                               (`DWC_DDR32_RAS_MAP == `DWC_BG1_INDX ) ? babg_sdram_dly[`DWC_BG_WIDTH - 1] : (  
                               (`DWC_DDR32_RAS_MAP == `DWC_A17_INDX ) ? addr_sdram_dly[17] : (
                               (`DWC_DDR32_RAS_MAP == `DWC_A16_INDX ) ? addr_sdram_dly[16] : (
                               (`DWC_DDR32_RAS_MAP == `DWC_A15_INDX ) ? addr_sdram_dly[15] : (
                               (`DWC_DDR32_RAS_MAP == `DWC_A14_INDX ) ? addr_sdram_dly[14] : 0)))));
      assign cas_n_sdram_dly = (`DWC_DDR32_CAS_MAP == `DWC_ACTN_INDX) ? actn_sdram_dly : (
                               (`DWC_DDR32_CAS_MAP == `DWC_BG1_INDX ) ? babg_sdram_dly[`DWC_BG_WIDTH - 1] : (  
                               (`DWC_DDR32_CAS_MAP == `DWC_A17_INDX ) ? addr_sdram_dly[17] : (
                               (`DWC_DDR32_CAS_MAP == `DWC_A16_INDX ) ? addr_sdram_dly[16] : (
                               (`DWC_DDR32_CAS_MAP == `DWC_A15_INDX ) ? addr_sdram_dly[15] : (
                               (`DWC_DDR32_CAS_MAP == `DWC_A14_INDX ) ? addr_sdram_dly[14] : 0)))));
      assign we_n_sdram_dly  = (`DWC_DDR32_WE_MAP  == `DWC_ACTN_INDX) ? actn_sdram_dly : (
                               (`DWC_DDR32_WE_MAP  == `DWC_BG1_INDX ) ? babg_sdram_dly[`DWC_BG_WIDTH - 1] : (  
                               (`DWC_DDR32_WE_MAP  == `DWC_A17_INDX ) ? addr_sdram_dly[17] : (
                               (`DWC_DDR32_WE_MAP  == `DWC_A16_INDX ) ? addr_sdram_dly[16] : (
                               (`DWC_DDR32_WE_MAP  == `DWC_A15_INDX ) ? addr_sdram_dly[15] : (
                               (`DWC_DDR32_WE_MAP  == `DWC_A14_INDX ) ? addr_sdram_dly[14] : 0)))));
    `else
      assign ras_n_sdram_dly = actn_sdram_dly;
      assign cas_n_sdram_dly = addr_sdram_dly[17];
      assign we_n_sdram_dly  = addr_sdram_dly[16];
    `endif
  `else
    assign ras_n_sdram_dly = actn_sdram_dly;
    assign cas_n_sdram_dly = addr_sdram_dly[17];
    assign we_n_sdram_dly  = addr_sdram_dly[16];
  `endif
  
  integer bit_idx, ac_idx;
  reg     training_err;
  
  genvar dx_bit, ac_bit, byte_bit;
  
//`ifdef DWC_DDRPHY_BOARD_DELAYS
// `ifdef BIDIRECTIONAL_SDRAM_DELAYS

  //wire [`SDRAM_BYTE_WIDTH-1:0] dm_i;      // SDRAM output data mask
  //wire [`SDRAM_BYTE_WIDTH-1:0] dqs_i;     // SDRAM input/output data strobe
  //wire [`SDRAM_BYTE_WIDTH-1:0] dqs_n_i;   // SDRAM input/output data strobe #
  //wire [`SDRAM_DATA_WIDTH-1:0] dq_i;      // SDRAM input/output data
 
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_x1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_x2 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_x1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_x2 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_x1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_x2 ;
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_wr_i1 ;  
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_wr_x1 ;  
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_wr_x2;
//`ifdef DDR4MPHY
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_rd_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_rd_x1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_rd_x2 ;
//`endif
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_x1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_x2 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_x1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_x2 ;
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_rd_i1 ;
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_rd_x1 ;
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_rd_x2 ;
  
  
  
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_x3 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_x3 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_x3 ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_wr_i2 ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_wr_x3 ; 
//`ifdef DDR4MPHY 
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_rd_i2 ; 
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_rd_x3 ;
//`endif
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_i2 ; 
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_x3 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_x3 ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_rd_i2 ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_rd_x3 ;
    
  reg [`SDRAM_BYTE_WIDTH-1:0] dqs_rd_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_rdx1_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rdx1_enable ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_rd_enable ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_rdx1_enable ;
//`ifdef DDR4MPHY
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_rd_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_rdx1_enable ;
//`endif    
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_wrx1_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_wrx1_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_enable ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wrx1_enable ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_wr_enable ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_wrx1_enable ;

 `ifdef LRDIMM_MULTI_RANK

   // detect reads
   wire                        read_cmd;
   wire                        mrs_cmd;
   reg [5                 :0]  cl;                 // CAS latency
   reg [1                 :0]  al_i;               // Additive Latency encoding
   reg [4                 :0]  al;                 // Additive Latency
   reg [3                 :0]  pl;                 // Parity Latency
   wire [6                :0]  read_latency;
   reg                         read_path_on;
   wire                        read_detect;
   reg [pRL_WIDTH       -1:0]  read_en;
   
   reg [3                 :0]  bl;
   reg                         rd_prmbl_train_on;
   reg                         rd_prmbl_train_off;
   reg                         mpr_on;
   reg                         mpr_off;
   reg                         pda_on;
   reg                         pda_off;
   reg                         pda_off_reg;
   reg                         mrep_train;
   reg                         dwl_train; 
   reg                         hwl_train; 
   reg                         mrd_train; 


   // detect writes 
   wire                        write_cmd;
   reg [4                 :0]  cwl;                 // CAS Write latency
   wire [6                :0]  write_latency;
   wire [2                :0]  rdimm_cmd_latency;
   reg                         write_path_on;
   wire                        write_detect;
   wire                        write_detect_dq;
   reg [pWL_WIDTH       -1:0]  write_en;
   reg [pWL_WIDTH       -1:0]  write_en_dq;
   reg                         wl_on;
   reg                         wl_off;
   reg                         write_detect_wl;
   wire [6                :0]  pub_wl;
   wire                        pub_wl_en;
   wire [6                :0]  pub_rl;
   wire                        pub_rl_en;
   wire [3                :0]  write_cycle_prefix;
   wire [3                :0]  write_cycle_suffix;
   `ifndef VMM_VERIF  
   wire [31               :0]  tmp_data;
   `endif
 `endif

   // Random Jitter
  real         addr_rj_dly [17:0];
`ifdef DDR4
  real         babg_rj_dly [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  real         babg_rj_dly [`SDRAM_BANK_WIDTH-1:0];
`endif
  real         csn_rj_dly;
  real         cke_rj_dly;
  real         odt_rj_dly;
  real         cid_rj_dly [`DWC_CID_WIDTH-1:0];
  real         parin_rj_dly;
  real         alertn_rj_dly;  
  real         actn_rj_dly;
  real         dq_do_rj_dly  [`SDRAM_DATA_WIDTH-1:0];
  real         dq_di_rj_dly  [`SDRAM_DATA_WIDTH-1:0];
  real         dm_do_rj_dly  [`SDRAM_BYTE_WIDTH-1:0];
  real         dm_di_rj_dly  [`SDRAM_BYTE_WIDTH-1:0];
  real         dqs_do_rj_dly [`SDRAM_BYTE_WIDTH-1:0];
  real         dqs_di_rj_dly [`SDRAM_BYTE_WIDTH-1:0];
  real         dqsn_do_rj_dly[`SDRAM_BYTE_WIDTH-1:0];
  real         dqsn_di_rj_dly[`SDRAM_BYTE_WIDTH-1:0];
  integer      addr_rj_dly_tmp [17:0];   //temp values (before caps & scaling)
`ifdef DDR4
  integer      babg_rj_dly_tmp [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_rj_dly_tmp [`SDRAM_BANK_WIDTH-1:0];
`endif  
  integer      csn_rj_dly_tmp  ;
  integer      cke_rj_dly_tmp  ;
  integer      odt_rj_dly_tmp ;
  integer      cid_rj_dly_tmp [`DWC_CID_WIDTH-1:0];
  integer      parin_rj_dly_tmp;
  integer      alertn_rj_dly_tmp; 
  integer      actn_rj_dly_tmp;    
  integer      dq_do_rj_dly_tmp  [`SDRAM_DATA_WIDTH-1:0];
  integer      dq_di_rj_dly_tmp  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_rj_dly_tmp  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_rj_dly_tmp  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_rj_dly_tmp [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_rj_dly_tmp [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_rj_dly_tmp[`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_di_rj_dly_tmp[`SDRAM_BYTE_WIDTH-1:0];
  integer      addr_rj_cap [17:0];       //pk-pk values (ps)
`ifdef DDR4
  integer      babg_rj_cap [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_rj_cap [`SDRAM_BANK_WIDTH-1:0];
`endif    
  integer      csn_rj_cap  ;
  integer      cke_rj_cap  ;
  integer      odt_rj_cap ;
  integer      cid_rj_cap [`DWC_CID_WIDTH-1:0];
  integer      parin_rj_cap;
  integer      alertn_rj_cap;
  integer      actn_rj_cap  ;    
  integer      dq_do_rj_cap  [`SDRAM_DATA_WIDTH-1:0];
  integer      dq_di_rj_cap  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_rj_cap  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_rj_cap  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_rj_cap [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_rj_cap [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_rj_cap[3:0];
  integer      dqsn_di_rj_cap[`SDRAM_BYTE_WIDTH-1:0];
  integer      addr_rj_sig [17:0];       //sigma multiple that is equal to pk-pk cap
`ifdef DDR4
  integer      babg_rj_sig [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_rj_sig [`SDRAM_BANK_WIDTH-1:0];
`endif    
  integer      csn_rj_sig  ;
  integer      cke_rj_sig  ;
  integer      odt_rj_sig ;
  integer      cid_rj_sig [`DWC_CID_WIDTH-1:0];
  integer      parin_rj_sig;
  integer      alertn_rj_sig; 
  integer      actn_rj_sig  ;   
  integer      dq_do_rj_sig  [`SDRAM_DATA_WIDTH-1:0]; 
  integer      dq_di_rj_sig  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_rj_sig  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_rj_sig  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_rj_sig [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_rj_sig [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_rj_sig[3:0];
  integer      dqsn_di_rj_sig[`SDRAM_BYTE_WIDTH-1:0];
  // Sinusoidal Jitter
  real         addr_sj_dly [17:0];
`ifdef DDR4
  integer      babg_sj_dly [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_sj_dly [`SDRAM_BANK_WIDTH-1:0];
`endif   
  real         csn_sj_dly  ;
  real         cke_sj_dly  ;
  real         odt_sj_dly ;
  real         cid_sj_dly [`DWC_CID_WIDTH-1:0];
  real         parin_sj_dly;
  real         alertn_sj_dly; 
  real         actn_sj_dly  ;   
  real         dq_do_sj_dly  [`SDRAM_DATA_WIDTH-1:0];
  real         dq_di_sj_dly  [`SDRAM_DATA_WIDTH-1:0];
  real         dm_do_sj_dly  [`SDRAM_BYTE_WIDTH-1:0];
  real         dm_di_sj_dly  [`SDRAM_BYTE_WIDTH-1:0];
  real         dqs_do_sj_dly [`SDRAM_BYTE_WIDTH-1:0];
  real         dqs_di_sj_dly [`SDRAM_BYTE_WIDTH-1:0];
  real         dqsn_do_sj_dly[`SDRAM_BYTE_WIDTH-1:0];
  real         dqsn_di_sj_dly[`SDRAM_BYTE_WIDTH-1:0];
  integer      addr_sj_amp [`DWC_PHY_ADDR_WIDTH-1:0];       //pk-pk jitter values (ps)
`ifdef DDR4
  integer      babg_sj_amp [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_sj_amp [`SDRAM_BANK_WIDTH-1:0];
`endif     
  integer      csn_sj_amp  ;
  integer      cke_sj_amp  ;
  integer      odt_sj_amp ;
  integer      cid_sj_amp [`DWC_CID_WIDTH-1:0];
  integer      parin_sj_amp;
  integer      alertn_sj_amp;  
  integer      actn_sj_amp  ;   
  integer      dq_do_sj_amp  [`SDRAM_DATA_WIDTH-1:0];
  integer      dq_di_sj_amp  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_sj_amp  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_sj_amp  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_sj_amp [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_sj_amp [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_sj_amp[`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_di_sj_amp[`SDRAM_BYTE_WIDTH-1:0];
  real         addr_sj_frq  [17:0];       //sin jitter frequency (Hz)
`ifdef DDR4
  integer      babg_sj_frq [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_sj_frq [`SDRAM_BANK_WIDTH-1:0];
`endif    
  real         csn_sj_frq  ;
  real         cke_sj_frq  ;
  real         odt_sj_frq ;
  real         cid_sj_frq [`DWC_CID_WIDTH-1:0];
  real         parin_sj_frq;
  real         alertn_sj_frq;  
  real         actn_sj_frq  ;  
  real         dq_do_sj_frq  [`SDRAM_DATA_WIDTH-1:0]; 
  real         dq_di_sj_frq  [`SDRAM_DATA_WIDTH-1:0];
  real         dm_do_sj_frq  [`SDRAM_BYTE_WIDTH-1:0];
  real         dm_di_sj_frq  [`SDRAM_BYTE_WIDTH-1:0];
  real         dqs_do_sj_frq [`SDRAM_BYTE_WIDTH-1:0];
  real         dqs_di_sj_frq [`SDRAM_BYTE_WIDTH-1:0];
  real         dqsn_do_sj_frq[`SDRAM_BYTE_WIDTH-1:0];
  real         dqsn_di_sj_frq[`SDRAM_BYTE_WIDTH-1:0];
  integer      addr_sj_phs  [`DWC_PHY_ADDR_WIDTH-1:0];       //sin jitter phase (degrees)
`ifdef DDR4
  integer      babg_sj_phs [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_sj_phs [`SDRAM_BANK_WIDTH-1:0];
`endif     
  integer      csn_sj_phs  ;
  integer      cke_sj_phs  ;
  integer      odt_sj_phs ;
  integer      cid_sj_phs [`DWC_CID_WIDTH-1:0];
  integer      parin_sj_phs;
  integer      alertn_sj_phs; 
  integer      actn_sj_phs  ;    
  integer      dq_do_sj_phs  [`SDRAM_DATA_WIDTH-1:0];  
  integer      dq_di_sj_phs  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_sj_phs  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_sj_phs  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_sj_phs [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_sj_phs [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_sj_phs[`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_di_sj_phs[`SDRAM_BYTE_WIDTH-1:0];
  // DCD
  integer      addr_dcd_dly  [17:0];
`ifdef DDR4
  integer      babg_dcd_dly [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_dcd_dly [`SDRAM_BANK_WIDTH-1:0];
`endif     
  integer      csn_dcd_dly  ;
  integer      cke_dcd_dly  ;
  integer      odt_dcd_dly ;
  integer      cid_dcd_dly [`DWC_CID_WIDTH-1:0];
  integer      parin_dcd_dly;
  integer      alertn_dcd_dly;  
  integer      actn_dcd_dly  ;  
  integer      dq_do_dcd_dly  [`SDRAM_DATA_WIDTH-1:0];
  integer      dq_di_dcd_dly  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_dcd_dly  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_dcd_dly  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_dcd_dly [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_dcd_dly [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_dcd_dly[`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_di_dcd_dly[`SDRAM_BYTE_WIDTH-1:0];
  
  // ISI
  integer      addr_isi_dly  [17:0];
`ifdef DDR4
  integer      babg_isi_dly [`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH -1:0];
`else
  integer      babg_isi_dly [`SDRAM_BANK_WIDTH-1:0];
`endif     
  integer      csn_isi_dly  ;
  integer      cke_isi_dly  ;
  integer      odt_isi_dly ;
  integer      cid_isi_dly [`DWC_CID_WIDTH-1:0];
  integer      parin_isi_dly;
  integer      alertn_isi_dly;  
  integer      actn_isi_dly  ;  
  integer      dq_do_isi_dly  [`SDRAM_DATA_WIDTH-1:0];
  integer      dq_di_isi_dly  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_do_isi_dly  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dm_di_isi_dly  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_isi_dly [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_isi_dly [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_isi_dly[`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_di_isi_dly[`SDRAM_BYTE_WIDTH-1:0];
  
  real    t_act_n           = 0.0 ;
  real    t_parity          = 0.0 ;
  real    t_alert_n         = 0.0 ;
  real    t_odt             = 0.0 ;
  real    t_cke             = 0.0 ;
  real    t_cs_n            = 0.0 ;
  real    t_we_n            = 0.0 ;
  real    t_cas_n           = 0.0 ;
  real    t_ras_n           = 0.0 ;
  
  real   t_a   [`SDRAM_ADDR_WIDTH-1:0]  ;
  real   t_cid [`DWC_CID_WIDTH-1:0]     ;
  real   t_bg  [`DWC_PHY_BG_WIDTH-1:0]  ;
  
  `ifdef DDR4
  real   t_ba  [`DWC_PHY_BA_WIDTH-1:0]  ;
  `else       
  real   t_ba  [`SDRAM_BANK_WIDTH-1:0]  ;
  `endif
    
  integer    nbits_act_n          = 1  ;
  integer    nbits_parity         = 1  ;
  integer    nbits_alert_n        = 1  ;
  integer    nbits_odt            = 1  ;
  integer    nbits_cke            = 1  ;
  integer    nbits_cs_n           = 1  ;
  integer    nbits_we_n           = 1  ;
  integer    nbits_cas_n          = 1  ;
  integer    nbits_ras_n          = 1  ;
  
  integer   nbits_a    [`SDRAM_ADDR_WIDTH-1:0] ;
  integer   nbits_cid  [`DWC_CID_WIDTH-1:0]    ;
  integer   nbits_bg   [`DWC_PHY_BG_WIDTH-1:0] ;
                       
  `ifdef DDR4           
  integer   nbits_ba   [`DWC_PHY_BA_WIDTH-1:0] ;
  `else                
  integer   nbits_ba   [`SDRAM_BANK_WIDTH-1:0] ;
  `endif
  
  real      t_dq_do   [`SDRAM_DATA_WIDTH-1:0];
  real      t_dq_do_probe [`SDRAM_DATA_WIDTH-1:0];
  real      t_dq_di   [`SDRAM_DATA_WIDTH-1:0];
  real      t_dm_do   [`SDRAM_BYTE_WIDTH-1:0];
  real      t_dm_di   [`SDRAM_BYTE_WIDTH-1:0];
  real      t_dqs_do  [`SDRAM_BYTE_WIDTH-1:0];
  real      t_dqs_di  [`SDRAM_BYTE_WIDTH-1:0];
  real      t_dqsn_do [`SDRAM_BYTE_WIDTH-1:0];
  real      t_dqsn_di [`SDRAM_BYTE_WIDTH-1:0];
  
  integer      nbits_dq_do   [`SDRAM_DATA_WIDTH-1:0];
  integer      nbits_dq_di   [`SDRAM_DATA_WIDTH-1:0];
  integer      nbits_dm_do   [`SDRAM_BYTE_WIDTH-1:0];
  integer      nbits_dm_di   [`SDRAM_BYTE_WIDTH-1:0];
  integer      nbits_dqs_do  [`SDRAM_BYTE_WIDTH-1:0];
  integer      nbits_dqs_di  [`SDRAM_BYTE_WIDTH-1:0];
  integer      nbits_dqsn_do [`SDRAM_BYTE_WIDTH-1:0];
  integer      nbits_dqsn_di [`SDRAM_BYTE_WIDTH-1:0];
 
  initial begin
    for(ac_idx=0;ac_idx<`SDRAM_ADDR_WIDTH;ac_idx=ac_idx+1) begin
      addr_rj_dly[ac_idx]     = 0 ;
      addr_rj_dly_tmp[ac_idx] = 0 ;
      addr_rj_cap[ac_idx]     = 0 ;
      addr_rj_cap[ac_idx]     = 0 ;  
      addr_rj_sig[ac_idx]     = 0 ;	
      addr_sj_dly[ac_idx]     = 0 ;  
      addr_sj_amp[ac_idx]     = 0 ; 
      addr_sj_frq[ac_idx]     = 1 ; 
      addr_sj_phs[ac_idx]     = 0 ; 
      addr_dcd_dly[ac_idx]    = 0 ; 
      addr_isi_dly[ac_idx]    = 0 ; 
      nbits_a[ac_idx]   = 1 ;
      t_a[ac_idx]       = 0.0 ;
    end
`ifdef DDR4              
    for(ac_idx=0;ac_idx<`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH;ac_idx=ac_idx+1) begin  
`else   
    for(ac_idx=0;ac_idx<`SDRAM_BANK_WIDTH;ac_idx=ac_idx+1) begin
`endif 
      babg_rj_dly[ac_idx]     = 0 ;
      babg_rj_dly_tmp[ac_idx] = 0 ; 
      babg_rj_cap[ac_idx]     = 0 ;  
      babg_rj_sig[ac_idx]     = 0 ;  
      babg_sj_dly[ac_idx]     = 0 ;  
      babg_sj_amp[ac_idx]     = 0 ;  
      babg_sj_frq[ac_idx]     = 1 ; 
      babg_sj_phs[ac_idx]     = 0 ; 
      babg_dcd_dly[ac_idx]    = 0 ; 
      babg_isi_dly[ac_idx]    = 0 ;  
      nbits_ba[ac_idx % `DWC_PHY_BA_WIDTH]   = 1 ;
      t_ba[ac_idx % `DWC_PHY_BA_WIDTH]       = 0.0 ;
      nbits_bg[ac_idx % `DWC_PHY_BG_WIDTH]   = 1 ;
      t_bg[ac_idx % `DWC_PHY_BG_WIDTH]       = 0.0 ;
    end
    csn_rj_dly     = 0 ;
    csn_rj_dly_tmp = 0 ;    
    csn_rj_cap     = 0 ;
    csn_rj_sig     = 0 ;
    csn_sj_dly     = 0 ;  
    csn_sj_amp     = 0 ; 
    csn_sj_frq     = 1 ;   
    csn_sj_phs     = 0 ;  
    csn_dcd_dly    = 0 ;  
    csn_isi_dly    = 0 ;            
    
    cke_rj_dly     = 0 ;
    cke_rj_dly_tmp = 0 ;
    cke_rj_cap     = 0 ;
    cke_rj_sig     = 0 ;        
    cke_sj_dly     = 0 ;
    cke_sj_amp     = 0 ;  
    cke_sj_frq     = 1 ;  
    cke_sj_phs     = 0 ;  
    cke_dcd_dly    = 0 ;  
    cke_isi_dly    = 0 ;          

    odt_rj_dly     = 0 ;
    odt_rj_dly_tmp = 0 ;    
    odt_rj_cap     = 0 ;
    odt_rj_sig     = 0 ; 
    odt_sj_dly     = 0 ;  
    odt_sj_amp     = 0 ;  
    odt_sj_frq     = 1 ; 
    odt_sj_phs     = 0 ; 
    odt_dcd_dly    = 0 ; 
    odt_isi_dly    = 0 ;                 

    for(ac_idx=0;ac_idx<`DWC_CID_WIDTH;ac_idx=ac_idx+1) begin    
      cid_rj_dly[ac_idx]     = 0 ;
      cid_rj_dly_tmp[ac_idx] = 0 ;
      cid_rj_cap[ac_idx]     = 0 ;
      cid_rj_sig[ac_idx]     = 0 ; 
      cid_sj_dly[ac_idx]     = 0 ;       
      cid_sj_amp[ac_idx]     = 0 ;
      cid_sj_frq[ac_idx]     = 1 ;  
      cid_sj_phs[ac_idx]     = 0 ; 
      cid_dcd_dly[ac_idx]    = 0 ; 
      cid_isi_dly[ac_idx]    = 0 ; 
      nbits_cid[ac_idx]   = 1 ;
      t_cid[ac_idx]       = 0.0 ;
    end        

    parin_rj_dly     = 0 ;
    parin_rj_dly_tmp = 0 ;  
    parin_rj_cap     = 0 ; 
    parin_rj_sig     = 0 ; 
    parin_sj_dly     = 0 ;   
    parin_sj_amp     = 0 ;  
    parin_sj_frq     = 1 ;  
    parin_sj_phs     = 0 ;  
    parin_dcd_dly    = 0 ;  
    parin_isi_dly    = 0 ;  
    
    alertn_rj_dly     = 0 ;
    alertn_rj_dly_tmp = 0 ;  
    alertn_rj_cap     = 0 ;
    alertn_rj_sig     = 0 ; 
    alertn_sj_dly     = 0 ; 
    alertn_sj_amp     = 0 ; 
    alertn_sj_frq     = 1 ; 
    alertn_sj_phs     = 0 ; 
    alertn_dcd_dly    = 0 ; 
    alertn_isi_dly    = 0 ;                      
    
    actn_rj_dly     = 0 ;      
    actn_rj_dly_tmp = 0 ;  
    actn_rj_cap     = 0 ; 
    actn_rj_sig     = 0 ;  
    actn_sj_dly     = 0 ; 
    actn_sj_amp     = 0 ;  
    actn_sj_frq     = 1 ;  
    actn_sj_phs     = 0 ; 
    actn_dcd_dly    = 0 ;  
    actn_isi_dly    = 0 ;                            
    
    for (bit_idx=0; bit_idx < `SDRAM_DATA_WIDTH; bit_idx=bit_idx+1) begin
      dq_do_rj_dly      [bit_idx] = 0 ;
      dq_di_rj_dly      [bit_idx] = 0 ;
      dq_do_rj_dly_tmp  [bit_idx] = 0 ;   //temp values (before caps & scaling)
      dq_di_rj_dly_tmp  [bit_idx] = 0 ;
      dq_do_rj_cap      [bit_idx] = 0 ;	   //pk-pk values (ps)
      dq_di_rj_cap      [bit_idx] = 0 ;
      dq_do_rj_sig      [bit_idx] = 0 ;	   //sigma multiple that is equal to pk-pk cap
      dq_di_rj_sig      [bit_idx] = 0 ;
      dq_do_sj_dly      [bit_idx] = 0 ;
      dq_di_sj_dly      [bit_idx] = 0 ;
      dq_do_sj_amp      [bit_idx] = 0 ;	   //pk-pk jitter values (ps)
      dq_di_sj_amp      [bit_idx] = 0 ;
      dq_do_sj_frq      [bit_idx] = 1 ;	   //sin jitter frequency (Hz)
      dq_di_sj_frq      [bit_idx] = 1 ;
      dq_do_sj_phs      [bit_idx] = 0 ;	   //sin jitter phase (degrees)
      dq_di_sj_phs      [bit_idx] = 0 ;
      dq_do_dcd_dly     [bit_idx] = 0 ;
      dq_di_dcd_dly     [bit_idx] = 0 ;
      dq_do_isi_dly     [bit_idx] = 0 ;
      dq_di_isi_dly     [bit_idx] = 0 ;
      nbits_dq_do[bit_idx]   = 1 ;
      t_dq_do[bit_idx]       = 0.0 ;
      nbits_dq_di[bit_idx]   = 1 ;
      t_dq_di[bit_idx]       = 0.0 ;
    end  
    for (bit_idx=0; bit_idx < `SDRAM_BYTE_WIDTH; bit_idx=bit_idx+1) begin
      dm_do_rj_dly  [bit_idx] = 0 ;
      dm_di_rj_dly  [bit_idx] = 0 ;
      dqs_do_rj_dly [bit_idx] = 0 ;
      dqs_di_rj_dly [bit_idx] = 0 ;
      dqsn_do_rj_dly[bit_idx] = 0 ;
      dqsn_di_rj_dly[bit_idx] = 0 ;
      dm_do_rj_dly_tmp  [bit_idx] = 0 ;
      dm_di_rj_dly_tmp  [bit_idx] = 0 ;
      dqs_do_rj_dly_tmp [bit_idx] = 0 ;
      dqs_di_rj_dly_tmp [bit_idx] = 0 ;
      dqsn_do_rj_dly_tmp[bit_idx] = 0 ;
      dqsn_di_rj_dly_tmp[bit_idx] = 0 ;
      dm_do_rj_cap  [bit_idx] = 0 ;
      dm_di_rj_cap  [bit_idx] = 0 ;
      dqs_do_rj_cap [bit_idx] = 0 ;
      dqs_di_rj_cap [bit_idx] = 0 ;
      dqsn_do_rj_cap[bit_idx] = 0 ;
      dqsn_di_rj_cap[bit_idx] = 0 ;
      dm_do_rj_sig  [bit_idx] = 0 ;
      dm_di_rj_sig  [bit_idx] = 0 ;
      dqs_do_rj_sig [bit_idx] = 0 ;
      dqs_di_rj_sig [bit_idx] = 0 ;
      dqsn_do_rj_sig[bit_idx] = 0 ;
      dqsn_di_rj_sig[bit_idx] = 0 ;
      dm_do_sj_dly  [bit_idx] = 0 ;
      dm_di_sj_dly  [bit_idx] = 0 ;
      dqs_do_sj_dly [bit_idx] = 0 ;
      dqs_di_sj_dly [bit_idx] = 0 ;
      dqsn_do_sj_dly[bit_idx] = 0 ;
      dqsn_di_sj_dly[bit_idx] = 0 ;
      dm_do_sj_amp  [bit_idx] = 0 ;
      dm_di_sj_amp  [bit_idx] = 0 ;
      dqs_do_sj_amp [bit_idx] = 0 ;
      dqs_di_sj_amp [bit_idx] = 0 ;
      dqsn_do_sj_amp[bit_idx] = 0 ;
      dqsn_di_sj_amp[bit_idx] = 0 ;
      dm_do_sj_frq  [bit_idx] = 1 ;
      dm_di_sj_frq  [bit_idx] = 1 ;
      dqs_do_sj_frq [bit_idx] = 1 ;
      dqs_di_sj_frq [bit_idx] = 1 ;
      dqsn_do_sj_frq[bit_idx] = 0 ;
      dqsn_di_sj_frq[bit_idx] = 0 ;
      dm_do_sj_phs  [bit_idx] = 0 ;
      dm_di_sj_phs  [bit_idx] = 0 ;
      dqs_do_sj_phs [bit_idx] = 0 ;
      dqs_di_sj_phs [bit_idx] = 0 ;
      dqsn_do_sj_phs[bit_idx] = 0 ;
      dqsn_di_sj_phs[bit_idx] = 0 ;
      dm_do_dcd_dly  [bit_idx] = 0 ;
      dm_di_dcd_dly  [bit_idx] = 0 ;
      dqs_do_dcd_dly [bit_idx] = 0 ;
      dqs_di_dcd_dly [bit_idx] = 0 ;
      dqsn_do_dcd_dly[bit_idx] = 0 ;
      dqsn_di_dcd_dly[bit_idx] = 0 ;
      dm_do_isi_dly  [bit_idx] = 0 ;
      dm_di_isi_dly  [bit_idx] = 0 ;
      dqs_do_isi_dly [bit_idx] = 0 ;
      dqs_di_isi_dly [bit_idx] = 0 ;
      dqsn_do_isi_dly[bit_idx] = 0 ;
      dqsn_di_isi_dly[bit_idx] = 0 ;
      
      nbits_dm_do[bit_idx]   = 1 ;
      t_dm_do[bit_idx]       = 0.0 ;
      nbits_dm_di[bit_idx]   = 1 ;
      t_dm_di[bit_idx]       = 0.0 ;
      nbits_dqs_do[bit_idx]   = 1 ;
      t_dqs_do[bit_idx]       = 0.0 ;
      nbits_dqs_di[bit_idx]   = 1 ;
      t_dqs_di[bit_idx]       = 0.0 ;
      nbits_dqsn_do[bit_idx]   = 1 ;
      t_dqsn_do[bit_idx]       = 0.0 ;
      nbits_dqsn_di[bit_idx]   = 1 ;
      t_dqsn_di[bit_idx]       = 0.0 ;
    end    
  end   


  // DX Signal Random Jitter
  // --------------
  // sets RJ delays on DQS, DQS#, DM and DQn output and input signals
  task set_dx_signal_rj_delay;
    input integer   dx_signal;      //Signal name to add RJ to. Valid inputs: 99=ALL,
                                    //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
    input           direction;      //Signal dir. to add RJ value to. Valid inputs: 1="in" or 0="out"
    input integer   rj_pk2pk;       //Pk-pk value (in ps) for Random Jitter
    input integer   rj_sigma;       //Range of values (precision) for normal distribution.
                                    //  Distribution's sigma will be rj_pk2pk/(2.0*rj_sigma)
                                    //  Results will be capped to: rj_pk2pk = 2*rj_sigma.
                                    //  Valid inputs: any integer >=1, or 0. Higher values = more
                                    //  accurate results; Lower values = faster (less events) to 
                                    //  obtain pk-pk. If 0 is input, jitter will be a random choice
                                    //  between the {-pk, +pk} value pair (either one or the other).
    integer i;



    begin
      
      case (dx_signal)
        `DQS :
	    case (direction)
              `IN       : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqs_di_rj_cap [i] <= rj_pk2pk;
                  dqs_di_rj_sig [i] <= rj_sigma;
                end
              end
              `OUT     : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqs_do_rj_cap [i] <= rj_pk2pk;
                  dqs_do_rj_sig [i] <= rj_sigma;
                end
              end
            endcase // case(direction)
        `DQSN  :
	    case (direction)
              `IN       : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqsn_di_rj_cap [i] <= rj_pk2pk;
                  dqsn_di_rj_sig [i] <= rj_sigma;
                end
              end
              `OUT     : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqsn_do_rj_cap [i] <= rj_pk2pk;
                  dqsn_do_rj_sig [i] <= rj_sigma;
                end
              end
            endcase // case(direction)
        `DM  :
	    case (direction)
              `IN       : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dm_di_rj_cap [i] <= rj_pk2pk;
                  dm_di_rj_sig [i] <= rj_sigma;
                end
              end
              `OUT     : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dm_do_rj_cap [i] <= rj_pk2pk;
                  dm_do_rj_sig [i] <= rj_sigma;
                end
              end
            endcase // case(direction)
            
        `DQS_1 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqs_di_rj_cap [1] <= rj_pk2pk;
                  dqs_di_rj_sig [1] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqs_do_rj_cap [1] <= rj_pk2pk;
                  dqs_do_rj_sig [1] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqsn_di_rj_cap [1] <= rj_pk2pk;
                  dqsn_di_rj_sig [1] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqsn_do_rj_cap [1] <= rj_pk2pk;
                  dqsn_do_rj_sig [1] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
            endcase // case(direction)
        `DM_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dm_di_rj_cap [1] <= rj_pk2pk;
                  dm_di_rj_sig [1] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dm_do_rj_cap [1] <= rj_pk2pk;
                  dm_do_rj_sig [1] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_2 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqs_di_rj_cap [2] <= rj_pk2pk;
                  dqs_di_rj_sig [2] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqs_do_rj_cap [2] <= rj_pk2pk;
                  dqs_do_rj_sig [2] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_2  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqsn_di_rj_cap [2] <= rj_pk2pk;
                  dqsn_di_rj_sig [2] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqsn_do_rj_cap [2] <= rj_pk2pk;
                  dqsn_do_rj_sig [2] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
            endcase // case(direction)
        `DM_2  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dm_di_rj_cap [2] <= rj_pk2pk;
                  dm_di_rj_sig [2] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dm_do_rj_cap [2] <= rj_pk2pk;
                  dm_do_rj_sig [2] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_3 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 3) begin
                  dqs_di_rj_cap [3] <= rj_pk2pk;
                  dqs_di_rj_sig [3] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 3) begin
                  dqs_do_rj_cap [3] <= rj_pk2pk;
                  dqs_do_rj_sig [3] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
            endcase // case(direction)
        `DQSN_3  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 3) begin
                  dqsn_di_rj_cap [3] <= rj_pk2pk;
                  dqsn_di_rj_sig [3] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqsn_do_rj_cap [3] <= rj_pk2pk;
                  dqsn_do_rj_sig [3] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
            endcase // case(direction)
        `DM_3  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 3) begin
                  dm_di_rj_cap [3] <= rj_pk2pk;
                  dm_di_rj_sig [3] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 3) begin
                  dm_do_rj_cap [3] <= rj_pk2pk;
                  dm_do_rj_sig [3] <= rj_sigma;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
            endcase // case(direction)

        `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15, `DQ_16, `DQ_17, `DQ_18, `DQ_19, `DQ_20, `DQ_21, `DQ_22, `DQ_23, `DQ_24, `DQ_25, `DQ_26, `DQ_27, `DQ_28, `DQ_29, `DQ_30, `DQ_31 : begin
            case (direction)
              `IN      : begin
                  dq_di_rj_cap[dx_signal]   <= rj_pk2pk;
                  dq_di_rj_sig[dx_signal]   <= rj_sigma;
              end
              `OUT       : begin
                  dq_do_rj_cap[dx_signal]   <= rj_pk2pk;
                  dq_do_rj_sig[dx_signal]   <= rj_sigma;
              end
            endcase // case(direction)
        end

        default : $display("-> %0t: ==> WARNING: [ddr_sdram] incorrect or missing signal name specification on task call.", $time);
      endcase // case(dx_signal)
    end
   endtask // set_dx_signal_rj_delay

  function[31:0] convert64to32;
    input int from64;
    begin
      convert64to32 = from64;
    end
  endfunction
  
  generate
    for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin : dqs_dm_rj_dly

      always @( dm_i[byte_bit] ) if (dm_i[byte_bit] !== 1'bx)
      begin
        if (dm_do_rj_cap[byte_bit]==0)
          dm_do_rj_dly_tmp[byte_bit]   <= 0;
        else if (dm_do_rj_sig[byte_bit]==0)    //randomize between {0, PK} value pair
          dm_do_rj_dly_tmp[byte_bit]   <= ( {$random}%2 ) * dm_do_rj_cap[byte_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dm_do_rj_dly_tmp[byte_bit]   <= {$random} % (dm_do_rj_cap[byte_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dm_do_rj_dly_tmp[byte_bit]   <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dm_do_rj_cap[byte_bit]*1000/2.0)), convert64to32($rtoi(dm_do_rj_cap[byte_bit]*1000/(2.0*dm_do_rj_sig[byte_bit]))));
            `else
              dm_do_rj_dly_tmp[byte_bit]   <= {$random} % (dm_do_rj_cap[byte_bit]*1000 + 1);
            `endif
          `endif
        if (dm_do_rj_dly_tmp[byte_bit]>=0 && dm_do_rj_dly_tmp[byte_bit]<=dm_do_rj_cap[byte_bit]*1000)
          dm_do_rj_dly[byte_bit]     <= $itor(dm_do_rj_dly_tmp[byte_bit])/1000.0 - $itor(dm_do_rj_cap[byte_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dm_do_rj_dly[byte_bit]     <= ( {$random}%2 ) ? -( dm_do_rj_dly[byte_bit] ) : dm_do_rj_dly[byte_bit];
      end    

      always @( dqs_i[byte_bit] ) if (dqs_i[byte_bit] !== 1'bx)
      begin
        if (dqs_do_rj_cap[byte_bit]==0)
          dqs_do_rj_dly_tmp[byte_bit]  <= 0;
        if (dqs_do_rj_sig[byte_bit]==0)   //randomize between {0, PK} value pair
          dqs_do_rj_dly_tmp[byte_bit]  <= ( {$random}%2 ) * dqs_do_rj_cap[byte_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dqs_do_rj_dly_tmp[byte_bit]  <= {$random} % (dqs_do_rj_cap[byte_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dqs_do_rj_dly_tmp[byte_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dqs_do_rj_cap[byte_bit]*1000/2.0)), convert64to32($rtoi(dqs_do_rj_cap[byte_bit]*1000/(2.0*dqs_do_rj_sig[byte_bit]))));
            `else
              dqs_do_rj_dly_tmp[byte_bit]  <= {$random} % (dqs_do_rj_cap[byte_bit]*1000 + 1);
            `endif
          `endif
        if (dqs_do_rj_dly_tmp[byte_bit]>=0 && dqs_do_rj_dly_tmp[byte_bit]<=dqs_do_rj_cap[byte_bit]*1000)
          dqs_do_rj_dly[byte_bit]    <= $itor(dqs_do_rj_dly_tmp[byte_bit])/1000.0 - $itor(dqs_do_rj_cap[byte_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dqs_do_rj_dly[byte_bit]     <= ( {$random}%2 ) ? -( dqs_do_rj_dly[byte_bit] ) : dqs_do_rj_dly[byte_bit];
      end

      always @( dqs_n_i[byte_bit] ) if (dqs_n_i[byte_bit] !== 1'bx)
      begin
        if (dqsn_do_rj_cap[byte_bit]==0)
          dqsn_do_rj_dly_tmp[byte_bit] <= 0;
        else if (dqsn_do_rj_sig[byte_bit]==0)  //randomize between {0, PK} value pair
          dqsn_do_rj_dly_tmp[byte_bit] <= ( {$random}%2 ) * dqsn_do_rj_cap[byte_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dqsn_do_rj_dly_tmp[byte_bit] <= {$random} % (dqsn_do_rj_cap[byte_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dqsn_do_rj_dly_tmp[byte_bit] <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dqsn_do_rj_cap[byte_bit]*1000/2.0)), convert64to32($rtoi(dqsn_do_rj_cap[byte_bit]*1000/(2.0*dqsn_do_rj_sig[byte_bit]))));
            `else
              dqsn_do_rj_dly_tmp[byte_bit] <= {$random} % (dqsn_do_rj_cap[byte_bit]*1000 + 1);
            `endif
          `endif
        if (dqsn_do_rj_dly_tmp[byte_bit]>=0 && dqsn_do_rj_dly_tmp[byte_bit]<=dqsn_do_rj_cap[byte_bit]*1000)
          dqsn_do_rj_dly[byte_bit]   <= $itor(dqsn_do_rj_dly_tmp[byte_bit])/1000.0 - $itor(dqsn_do_rj_cap[byte_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dqsn_do_rj_dly[byte_bit]     <= ( {$random}%2 ) ? -( dqsn_do_rj_dly[byte_bit] ) : dqsn_do_rj_dly[byte_bit];
      end

      always @( dm[byte_bit] ) if (dm[byte_bit] !== 1'bx)
      begin
        if (dm_di_rj_cap[byte_bit]==0)
          dm_di_rj_dly_tmp[byte_bit]   <= 0;
        else if (dm_di_rj_sig[byte_bit]==0)    //randomize between {0, PK} value pair
          dm_di_rj_dly_tmp[byte_bit]   <= ( {$random}%2 ) * dm_di_rj_cap[byte_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dm_di_rj_dly_tmp[byte_bit]   <= {$random} % (dm_di_rj_cap[byte_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dm_di_rj_dly_tmp[byte_bit]   <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dm_di_rj_cap[byte_bit]*1000/2.0)), convert64to32($rtoi(dm_di_rj_cap[byte_bit]*1000/(2.0*dm_di_rj_sig[byte_bit]))));
            `else
              dm_di_rj_dly_tmp[byte_bit]   <= {$random} % (dm_di_rj_cap[byte_bit]*1000 + 1);
            `endif
          `endif
        if (dm_di_rj_dly_tmp[byte_bit]>=0 && dm_di_rj_dly_tmp[byte_bit]<=dm_di_rj_cap[byte_bit]*1000)
          dm_di_rj_dly[byte_bit]     <= $itor(dm_di_rj_dly_tmp[byte_bit])/1000.0 - $itor(dm_di_rj_cap[byte_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dm_di_rj_dly[byte_bit]     <= ( {$random}%2 ) ? -( dm_di_rj_dly[byte_bit] ) : dm_di_rj_dly[byte_bit];
      end

      always @( dqs[byte_bit] ) if (dqs[byte_bit] !== 1'bx)
      begin
        if (dqs_di_rj_cap[byte_bit]==0)
          dqs_di_rj_dly_tmp[byte_bit]  <= 0;
        else if (dqs_di_rj_sig[byte_bit]==0)   //randomize between {0, PK} value pair
          dqs_di_rj_dly_tmp[byte_bit]  <= ( {$random}%2 ) * dqs_di_rj_cap[byte_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dqs_di_rj_dly_tmp[byte_bit]  <= {$random} % (dqs_di_rj_cap[byte_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dqs_di_rj_dly_tmp[byte_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dqs_di_rj_cap[byte_bit]*1000/2.0)), convert64to32($rtoi(dqs_di_rj_cap[byte_bit]*1000/(2.0*dqs_di_rj_sig[byte_bit]))));
            `else
              dqs_di_rj_dly_tmp[byte_bit]  <= {$random} % (dqs_di_rj_cap[byte_bit]*1000 + 1);
            `endif
          `endif
        if (dqs_di_rj_dly_tmp[byte_bit]>=0 && dqs_di_rj_dly_tmp[byte_bit]<=dqs_di_rj_cap[byte_bit]*1000)
          dqs_di_rj_dly[byte_bit]    <= $itor(dqs_di_rj_dly_tmp[byte_bit])/1000.0 - $itor(dqs_di_rj_cap[byte_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dqs_di_rj_dly[byte_bit]     <= ( {$random}%2 ) ? -( dqs_di_rj_dly[byte_bit] ) : dqs_di_rj_dly[byte_bit];
      end

      always @( dqs_n[byte_bit] ) if (dqs_n[byte_bit] !== 1'bx)
      begin
        if (dqsn_di_rj_cap[byte_bit]==0)
          dqsn_di_rj_dly_tmp[byte_bit] <= 0;
        else if (dqsn_di_rj_sig[byte_bit]==0)  //randomize between {0, PK} value pair
          dqsn_di_rj_dly_tmp[byte_bit] <= ( {$random}%2 ) * dqsn_di_rj_cap[byte_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dqsn_di_rj_dly_tmp[byte_bit] <= {$random} % (dqsn_di_rj_cap[byte_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dqsn_di_rj_dly_tmp[byte_bit] <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dqsn_di_rj_cap[byte_bit]*1000/2.0)), convert64to32($rtoi(dqsn_di_rj_cap[byte_bit]*1000/(2.0*dqsn_di_rj_sig[byte_bit]))));
          `else
              dqsn_di_rj_dly_tmp[byte_bit] <= {$random} % (dqsn_di_rj_cap[byte_bit]*1000 + 1);
          `endif
        `endif
        if (dqsn_di_rj_dly_tmp[byte_bit]>=0 && dqsn_di_rj_dly_tmp[byte_bit]<=dqsn_di_rj_cap[byte_bit]*1000)
          dqsn_di_rj_dly[byte_bit]   <= $itor(dqsn_di_rj_dly_tmp[byte_bit])/1000.0 - $itor(dqsn_di_rj_cap[byte_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dqsn_di_rj_dly[byte_bit]   <= ( {$random}%2 ) ? -( dqsn_di_rj_dly[byte_bit] ) : dqsn_di_rj_dly[byte_bit];
      end
    end
  endgenerate

  generate
    for(dx_bit=0; dx_bit<`SDRAM_DATA_WIDTH; dx_bit=dx_bit+1) begin : dq_do_rj_dly_gen
      always @( dq_i[dx_bit] ) if (dq_i[dx_bit] !== 1'bx) begin
        if (dq_do_rj_cap[dx_bit]==0)
          dq_do_rj_dly_tmp[dx_bit]  <= 0;
        else if (dq_do_rj_sig[dx_bit]==0)   //randomize between {0, PK} value pair
          dq_do_rj_dly_tmp[dx_bit]  <= ( {$random}%2 ) * dq_do_rj_cap[dx_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dq_do_rj_dly_tmp[dx_bit]  <= {$random} % (dq_do_rj_cap[dx_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dq_do_rj_dly_tmp[dx_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dq_do_rj_cap[dx_bit]*1000/2.0)), convert64to32($rtoi(dq_do_rj_cap[dx_bit]*1000/(2.0*dq_do_rj_sig[dx_bit]))));
            `else
              dq_do_rj_dly_tmp[dx_bit]  <= {$random} % (dq_do_rj_cap[dx_bit]*1000 + 1);
            `endif
          `endif
        if (dq_do_rj_dly_tmp[dx_bit]>=0 && dq_do_rj_dly_tmp[dx_bit]<=dq_do_rj_cap[dx_bit]*1000)
          dq_do_rj_dly[dx_bit]      <= $itor(dq_do_rj_dly_tmp[dx_bit])/1000.0 - $itor(dq_do_rj_cap[dx_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dq_do_rj_dly[dx_bit]      <= ( {$random}%2 ) ? -( dq_do_rj_dly[dx_bit] ) :  dq_do_rj_dly[dx_bit];
      end
    end
    endgenerate


  generate
    for(dx_bit=0; dx_bit<`SDRAM_DATA_WIDTH; dx_bit=dx_bit+1) begin : dq_di_rj_dly_gen
      always @( dq[dx_bit] ) if (dq[dx_bit] !== 1'bx)  begin
        if (dq_di_rj_cap[dx_bit]==0)
          dq_di_rj_dly_tmp[dx_bit]  <= 0;
        else if (dq_di_rj_sig[dx_bit] == 0)   //randomize between {0, PK} value pair
          dq_di_rj_dly_tmp[dx_bit]  <= ( {$random}%2 ) * dq_di_rj_cap[dx_bit]*1000;
        else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
          `ifdef VMM_VERIF
            dq_di_rj_dly_tmp[dx_bit]  <= {$random} % (dq_di_rj_cap[dx_bit]*1000 + 1);
          `else
            `ifdef DWC_VERILOG2005
              dq_di_rj_dly_tmp[dx_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(dq_di_rj_cap[dx_bit]*1000/2.0)), convert64to32($rtoi(dq_di_rj_cap[dx_bit]*1000/(2.0*dq_di_rj_sig[dx_bit]))));
            `else
              dq_di_rj_dly_tmp[dx_bit]  <= {$random} % (dq_di_rj_cap[dx_bit]*1000 + 1);
            `endif
         `endif
        if (dq_di_rj_dly_tmp[dx_bit]>=0 && dq_di_rj_dly_tmp[dx_bit]<=dq_di_rj_cap[dx_bit]*1000)
          dq_di_rj_dly[dx_bit]      <= $itor(dq_di_rj_dly_tmp[dx_bit])/1000.0 - $itor(dq_di_rj_cap[dx_bit])/2.0;
        else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
          dq_di_rj_dly[dx_bit]      <= ( {$random}%2 ) ? -( dq_di_rj_dly[dx_bit] ) :  dq_di_rj_dly[dx_bit];
      end
    end
  endgenerate


  // DX signal Sinusoidal Jitter
  // -------------
  // sets SJ delays on DQS, DQS#, DM and DQ output and input signals
  task set_dx_signal_sj_delay;
    input integer   dx_signal;      //Signal name to add SJ to. Valid inputs: 99=ALL,
                                    //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
    input           direction;      //Signal dir. to add RJ value to. Valid inputs: 1="in" or 0="out"
    input integer   sj_pk2pk;       //Pk-pk value (in ps) for Sinusoidal Jitter
    input real      sj_freq;        //Frequency for sinusoidal jitter, in Hz.
    input integer   sj_phase_sep;   //Absolute phase for dx_signal defined.
    
    integer i;

    begin
      
      case (dx_signal)
        `DQS       :
            case (direction)
              `IN     : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqs_di_sj_amp [i] <= sj_pk2pk;
                  dqs_di_sj_frq [i] <= sj_freq;
                  dqs_di_sj_phs [i] <= sj_phase_sep;
                end
              end
              `OUT    : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqs_do_sj_amp [i] <= sj_pk2pk;
                  dqs_do_sj_frq [i] <= sj_freq;
                  dqs_do_sj_phs [i] <= sj_phase_sep;
                end
              end
            endcase // case(direction)
        `DQSN      :
            case (direction)
              `IN     : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqsn_di_sj_amp [i] <= sj_pk2pk;
                  dqsn_di_sj_frq [i] <= sj_freq;
                  dqsn_di_sj_phs [i] <= sj_phase_sep;
                end
              end
              `OUT    : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dqsn_do_sj_amp [i] <= sj_pk2pk;
                  dqsn_do_sj_frq [i] <= sj_freq;
                  dqsn_do_sj_phs [i] <= sj_phase_sep;
                end
              end
            endcase // case(direction)
        `DM     :
            case (direction)
              `IN     : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dm_di_sj_amp [i] <= sj_pk2pk;
                  dm_di_sj_frq [i] <= sj_freq;
                  dm_di_sj_phs [i] <= sj_phase_sep;
                end
              end
              `OUT    : begin
                for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) begin
                  dm_do_sj_amp [i] <= sj_pk2pk;
                  dm_do_sj_frq [i] <= sj_freq;
                  dm_do_sj_phs [i] <= sj_phase_sep;
                end
              end
            endcase // case(direction)     
            
        `DQS_1 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqs_di_sj_amp [1] <= sj_pk2pk;
                  dqs_di_sj_frq [1] <= sj_freq;
                  dqs_di_sj_phs [1] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqs_do_sj_amp [1] <= sj_pk2pk;
                  dqs_do_sj_frq [1] <= sj_freq;
                  dqs_do_sj_phs [1] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqsn_di_sj_amp [1] <= sj_pk2pk;
                  dqsn_di_sj_frq [1] <= sj_freq;
                  dqsn_di_sj_phs [1] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dqsn_do_sj_amp [1] <= sj_pk2pk;
                  dqsn_do_sj_frq [1] <= sj_freq;
                  dqsn_do_sj_phs [1] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
            endcase // case(direction)
        `DM_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dm_di_sj_amp [1] <= sj_pk2pk;
                  dm_di_sj_frq [1] <= sj_freq;
                  dm_di_sj_phs [1] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) begin
                  dm_do_sj_amp [1] <= sj_pk2pk;
                  dm_do_sj_frq [1] <= sj_freq;
                  dm_do_sj_phs [1] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_2 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqs_di_sj_amp [2] <= sj_pk2pk;    
                  dqs_di_sj_frq [2] <= sj_freq;     
                  dqs_di_sj_phs [2] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqs_do_sj_amp [2] <= sj_pk2pk;    
                  dqs_do_sj_frq [2] <= sj_freq;     
                  dqs_do_sj_phs [2] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_2  :                  
	    case (direction)              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqsn_di_sj_amp [2] <= sj_pk2pk;    
                  dqsn_di_sj_frq [2] <= sj_freq;     
                  dqsn_di_sj_phs [2] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqsn_do_sj_amp [2] <= sj_pk2pk;    
                  dqsn_do_sj_frq [2] <= sj_freq;     
                  dqsn_do_sj_phs [2] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
            endcase // case(direction)
        `DM_2  :                    
	    case (direction)              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dm_di_sj_amp [2] <= sj_pk2pk;    
                  dm_di_sj_frq [2] <= sj_freq;     
                  dm_di_sj_phs [2] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dm_do_sj_amp [2] <= sj_pk2pk;    
                  dm_do_sj_frq [2] <= sj_freq;     
                  dm_do_sj_phs [2] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_3 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 3) begin
                  dqs_di_sj_amp [3] <= sj_pk2pk;     
                  dqs_di_sj_frq [3] <= sj_freq;      
                  dqs_di_sj_phs [3] <= sj_phase_sep; 
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqs_do_sj_amp [3] <= sj_pk2pk;     
                  dqs_do_sj_frq [3] <= sj_freq;      
                  dqs_do_sj_phs [3] <= sj_phase_sep; 
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
            endcase // case(direction)               
        `DQSN_3  :                                   
	    case (direction)                              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqsn_di_sj_amp [3] <= sj_pk2pk;    
                  dqsn_di_sj_frq [3] <= sj_freq;     
                  dqsn_di_sj_phs [3] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dqsn_do_sj_amp [3] <= sj_pk2pk;    
                  dqsn_do_sj_frq [3] <= sj_freq;     
                  dqsn_do_sj_phs [3] <= sj_phase_sep;
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
            endcase // case(direction)               
        `DM_3  :                                     
	    case (direction)                              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dm_di_sj_amp [3] <= sj_pk2pk;      
                  dm_di_sj_frq [3] <= sj_freq;       
                  dm_di_sj_phs [3] <= sj_phase_sep;  
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) begin
                  dm_do_sj_amp [3] <= sj_pk2pk;      
                  dm_do_sj_frq [3] <= sj_freq;       
                  dm_do_sj_phs [3] <= sj_phase_sep;  
              end else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
            endcase // case(direction)       

        `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15, `DQ_16, `DQ_17, `DQ_18, `DQ_19, `DQ_20, `DQ_21, `DQ_22, `DQ_23, `DQ_24, `DQ_25, `DQ_26, `DQ_27, `DQ_28, `DQ_29, `DQ_30, `DQ_31 : begin
            case (direction)
              `IN      :
                begin
                  dq_di_sj_amp[dx_signal]   <= sj_pk2pk;
                  dq_di_sj_frq[dx_signal]   <= sj_freq;
                  dq_di_sj_phs[dx_signal]   <= sj_phase_sep;
                end
              `OUT     :
                begin
                  dq_do_sj_amp[dx_signal]   <= sj_pk2pk;
                  dq_do_sj_frq[dx_signal]   <= sj_freq;
                  dq_do_sj_phs[dx_signal]   <= sj_phase_sep;
                end
            endcase // case(direction)
        end // case: endcase...
        default : $display("-> %0t: ==> WARNING: [set_dx_signal_sj_delay] incorrect or missing signal name specification (%d) on task call.", $time, dx_signal);
      endcase
    end
  endtask // set_dx_signal_sj_delay
        

  generate
    for(byte_bit=0; byte_bit<`SDRAM_BYTE_WIDTH; byte_bit=byte_bit+1) begin : dqs_dm_sj_dly
    
      always @( dm_i[byte_bit] ) if (dm_i[byte_bit] !== 1'bx)  begin
        dm_do_sj_dly[byte_bit] <= (dm_do_sj_amp[byte_bit]==0 || dm_do_sj_frq[byte_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dm_do_sj_amp[byte_bit])/2 * $sin(2.0*pPI*dm_do_sj_frq[byte_bit]*$realtime/1e15 + 2.0*pPI*$itor(dm_do_sj_phs[byte_bit])/360) );
        `else
          ( $itor( {$random} % (dm_do_sj_amp[byte_bit]*1000 + 1) ) / 1000 - $itor(dm_do_sj_amp[byte_bit])/2 );
        `endif
      end //NOTES: amp * $sin(2.0*PI*freq*time+phase) + amp/2; freq is in Hz and time in ps, so time/1e12 to adjust; phase is in Deg, so 2*pi*phase/360 to convert to Rad.    

      always @( dqs_i[byte_bit] ) if (dqs_i[byte_bit] !== 1'bx)  begin
        dqs_do_sj_dly[byte_bit] <= (dqs_do_sj_amp[byte_bit]==0 || dqs_do_sj_frq[byte_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dqs_do_sj_amp[byte_bit])/2 * $sin(2.0*pPI*dqs_do_sj_frq[byte_bit]*$realtime/1e15 + 2.0*pPI*$itor(dqs_do_sj_phs[byte_bit])/360) );
        `else
          ( $itor( {$random} % (dqs_do_sj_amp[byte_bit]*1000 + 1) ) / 1000 - $itor(dqs_do_sj_amp[byte_bit])/2 );
        `endif
      end

      always @( dqs_n_i[byte_bit] ) if (dqs_n_i[byte_bit] !== 1'bx)  begin
        dqsn_do_sj_dly[byte_bit] <= (dqsn_do_sj_amp[byte_bit]==0 || dqsn_do_sj_frq[byte_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dqsn_do_sj_amp[byte_bit])/2 * $sin(2.0*pPI*dqsn_do_sj_frq[byte_bit]*$realtime/1e15 + 2.0*pPI*$itor(dqsn_do_sj_phs[byte_bit])/360) );
        `else
          ( $itor( {$random} % (dqsn_do_sj_amp[byte_bit]*1000 + 1) ) / 1000 - $itor(dqsn_do_sj_amp[byte_bit])/2 );
        `endif
      end //NOTES: amp * $sin(2.0*PI*freq*time+phase) + amp/2; freq is in Hz and time in ps, so time/1e12 to adjust; phase is in Deg, so 2*pi*phase/360 to convert to Rad.

      always @( dm[byte_bit] ) if (dm[byte_bit] !== 1'bx)  begin
        dm_di_sj_dly[byte_bit] <= (dm_di_sj_amp[byte_bit]==0 || dm_di_sj_frq[byte_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dm_di_sj_amp[byte_bit])/2 * $sin(2.0*pPI*dm_di_sj_frq[byte_bit]*$realtime/1e15 + 2.0*pPI*$itor(dm_di_sj_phs[byte_bit])/360) );
        `else
          ( $itor( {$random} % (dm_di_sj_amp[byte_bit]*1000 + 1) ) / 1000 - $itor(dm_di_sj_amp[byte_bit])/2 );
        `endif
      end //NOTES: amp * $sin(2.0*PI*freq*time+phase) + amp/2; freq is in Hz and time in ps, so time/1e12 to adjust; phase is in Deg, so 2*pi*phase/360 to convert to Rad.

      always @( dqs[byte_bit] ) if (dqs[byte_bit] !== 1'bx) 
      begin
        dqs_di_sj_dly[byte_bit] <= (dqs_di_sj_amp[byte_bit]==0 || dqs_di_sj_frq[byte_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dqs_di_sj_amp[byte_bit])/2 * $sin(2.0*pPI*dqs_di_sj_frq[byte_bit]*$realtime/1e15 + 2.0*pPI*$itor(dqs_di_sj_phs[byte_bit])/360) );
        `else
          ( $itor( {$random} % (dqs_di_sj_amp[byte_bit]*1000 + 1) ) / 1000 - $itor(dqs_di_sj_amp[byte_bit])/2 );
        `endif
      end //NOTES: amp * $sin(2.0*PI*freq*time+phase) + amp/2; freq is in Hz and time in ps, so time/1e12 to adjust; phase is in Deg, so 2*pi*phase/360 to convert to Rad.

      always @( dqs_n[byte_bit] ) if (dqs_n[byte_bit] !== 1'bx) 
      begin
        dqsn_di_sj_dly[byte_bit] <= (dqsn_di_sj_amp[byte_bit]==0 || dqsn_di_sj_frq[byte_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dqsn_di_sj_amp[byte_bit])/2 * $sin(2.0*pPI*dqsn_di_sj_frq[byte_bit]*$realtime/1e15 + 2.0*pPI*$itor(dqsn_di_sj_phs[byte_bit])/360) );
        `else
          ( $itor( {$random} % (dqsn_di_sj_amp[byte_bit]*1000 + 1) ) / 1000 - $itor(dqsn_di_sj_amp[byte_bit])/2 );
        `endif
      end //NOTES: amp * $sin(2.0*PI*freq*time+phase) + amp/2; freq is in Hz and time in ps, so time/1e12 to adjust; phase is in Deg, so 2*pi*phase/360 to convert to Rad.
    end
  endgenerate


  generate
    for(dx_bit=0; dx_bit<`SDRAM_DATA_WIDTH; dx_bit=dx_bit+1) begin : dq_do_sj_dly_gen
      always @( dq_i[dx_bit] ) if (dq_i[dx_bit] !== 1'bx) begin
        dq_do_sj_dly[dx_bit]    <= (dq_do_sj_amp[dx_bit]==0 || dq_do_sj_frq[dx_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dq_do_sj_amp[dx_bit])/2 * $sin(2.0*pPI*dq_do_sj_frq[dx_bit]*$realtime/1e15 
            + 2.0*pPI*$itor(dq_do_sj_phs[dx_bit])/360) );
        `else
          ( $itor( {$random} % (dq_do_sj_amp[dx_bit]*1000 + 1) ) / 1000 - $itor(dq_do_sj_amp[dx_bit])/2 );
        `endif
      end
    end
  endgenerate

  generate
    for(dx_bit=0; dx_bit<`SDRAM_DATA_WIDTH; dx_bit=dx_bit+1) begin : dq_di_sj_dly_gen
      always @( dq[dx_bit] ) if (dq[dx_bit] !== 1'bx) begin
        dq_di_sj_dly[dx_bit]    <= (dq_di_sj_amp[dx_bit]==0 || dq_di_sj_frq[dx_bit]==0.0) ? 0.0 :
        `ifdef DWC_VERILOG2005
          ( $itor(dq_di_sj_amp[dx_bit])/2 * $sin(2.0*pPI*dq_di_sj_frq[dx_bit]*$realtime/1e15 + 2.0*pPI*$itor(dq_di_sj_phs[dx_bit])/360) );
        `else
          ( $itor( {$random} % (dq_di_sj_amp[dx_bit]*1000 + 1) ) / 1000 - $itor(dq_di_sj_amp[dx_bit])/2 );
        `endif
      end
    end
  endgenerate


  // DX signal DCD
  // -------------
  // sets DCD delays on DQS, DQS#, DM and DQ output and input signals
  task set_dx_signal_dcd_delay;
    input integer   dx_signal;      //Signal name to add RJ to. Valid inputs: 99=ALL,
                                    //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
    input           direction;      //Signal dir. to add RJ value to. Valid inputs: 1="in" or 0="out"
    input integer   dcd_value;    //(Max) Distortion value (in ps) for selected edge(s); positive values extend "1"s, negative values extend "0"s
    
    integer i, j, k;

    begin
          
      case (dx_signal)
        `DQS       :
            case (direction)
            `IN  :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) 
                        dqs_di_dcd_dly [i]    <= dcd_value;
            `OUT :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dqs_do_dcd_dly [i]    <= dcd_value;
            endcase // case(direction)            
        `DQSN      :
            case (direction)
            `IN  :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dqsn_di_dcd_dly [i]    <= dcd_value;
            `OUT :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dqsn_do_dcd_dly [i]    <= dcd_value;
            endcase // case(direction)
        `DM      :
            case (direction)
            `IN  :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dm_di_dcd_dly [i]    <= dcd_value;
            `OUT :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dm_do_dcd_dly [i]    <= dcd_value;
            endcase // case(direction)   
            
        `DQS_1 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) dqs_di_dcd_dly [1]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) dqs_do_dcd_dly [i]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) dqsn_di_dcd_dly [1]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) dqsn_do_dcd_dly [1]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
            endcase // case(direction)
        `DM_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) dm_di_dcd_dly [1]    <= dcd_value;
                    else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
              `OUT      : if (`SDRAM_BYTE_WIDTH > 1) dm_do_dcd_dly [1]    <= dcd_value;
                    else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_2 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dqs_di_dcd_dly [2]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqs_do_dcd_dly [2]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_2  :                  
	    case (direction)              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dqsn_di_dcd_dly [2]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqsn_do_dcd_dly [2]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
            endcase // case(direction)
        `DM_2  :                    
	    case (direction)              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dm_di_dcd_dly [2]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
              `OUT      : if (`SDRAM_BYTE_WIDTH > 2) dm_do_dcd_dly [2]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_3 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 3) dqs_di_dcd_dly [3]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqs_do_dcd_dly [3]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
            endcase // case(direction)               
        `DQSN_3  :                                   
	    case (direction)                              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dqsn_di_dcd_dly [3]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqsn_do_dcd_dly [3]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
            endcase // case(direction)               
        `DM_3  :                                     
	    case (direction)                              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dm_di_dcd_dly [3]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
              `OUT      : if (`SDRAM_BYTE_WIDTH > 2) dm_do_dcd_dly [3]    <= dcd_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
            endcase // case(direction)       
            
            
        `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15, `DQ_16, `DQ_17, `DQ_18, `DQ_19, `DQ_20, `DQ_21, `DQ_22, `DQ_23, `DQ_24, `DQ_25, `DQ_26, `DQ_27, `DQ_28, `DQ_29, `DQ_30, `DQ_31 :
            case (direction)
            `IN  :  dq_di_dcd_dly[dx_signal]	<= dcd_value;
            `OUT :  dq_do_dcd_dly[dx_signal]	<= dcd_value;
            endcase // case(direction)
	    
         default : $display("-> %0t: ==> WARNING: [set_dx_signal_dcd_delay] incorrect or missing signal name specification on task call.", $time); 
      endcase // case(dx_signal)
      
    end
  endtask // set_dx_signal_dcd_delay 
  


  // DX signal ISI
  // -------------
  // sets ISI (max) delays on DQS, DQS#, DM and DQ output and input signals
  task set_dx_signal_isi_delay;
    input integer   dx_signal;      //Signal name to add RJ to. Valid inputs: 99=ALL,
                                    //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
    input           direction;      //Signal dir. to add RJ value to. Valid inputs: 1="in" or 0="out"
    input integer   isi_value;    //(Max) Distortion value (in ps) for selected edge(s); positive values extend "1"s, negative values extend "0"s
    
    integer i, j, k;

    begin
          
      case (dx_signal)
        `DQS       :
            case (direction)
            `IN  :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1) 
                        dqs_di_isi_dly [i]    <= isi_value;
            `OUT :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dqs_do_isi_dly [i]    <= isi_value;
            endcase // case(direction)            
        `DQSN      :
            case (direction)
            `IN  :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dqsn_di_isi_dly [i]    <= isi_value;
            `OUT :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dqsn_do_isi_dly [i]    <= isi_value;
            endcase // case(direction)
        `DM      :
            case (direction)
            `IN  :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dm_di_isi_dly [i]    <= isi_value;
            `OUT :  for (i=0; i<`SDRAM_BYTE_WIDTH; i=i+1)
                        dm_do_isi_dly [i]    <= isi_value;
            endcase // case(direction)   
            
        `DQS_1 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) dqs_di_isi_dly [1]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) dqs_do_isi_dly [i]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_1 signal but mem has just 1-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) dqsn_di_isi_dly [1]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 1) dqsn_do_isi_dly [1]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_1 signal but mem has just 1-bit DQSN...", $time);
            endcase // case(direction)
        `DM_1  :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 1) dm_di_isi_dly [1]    <= isi_value;
                    else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
              `OUT      : if (`SDRAM_BYTE_WIDTH > 1) dm_do_isi_dly [1]    <= isi_value;
                    else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_1 signal but mem has just 1-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_2 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dqs_di_isi_dly [2]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqs_do_isi_dly [2]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_2 signal but mem has just 1- or 2-bit DQS...", $time);
            endcase // case(direction)
        `DQSN_2  :                  
	    case (direction)              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dqsn_di_isi_dly [2]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqsn_do_isi_dly [2]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_2 signal but mem has just 1- or 2-bit DQSN...", $time);
            endcase // case(direction)
        `DM_2  :                    
	    case (direction)              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dm_di_isi_dly [2]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
              `OUT      : if (`SDRAM_BYTE_WIDTH > 2) dm_do_isi_dly [2]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_2 signal but mem has just 1- or 2-bit DM...", $time);
            endcase // case(direction)
            
        `DQS_3 :
	    case (direction)
              `IN       : if (`SDRAM_BYTE_WIDTH > 3) dqs_di_isi_dly [3]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqs_do_isi_dly [3]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQS_3 signal but mem has less than 4-bits DQS...", $time);
            endcase // case(direction)               
        `DQSN_3  :                                   
	    case (direction)                              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dqsn_di_isi_dly [3]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
              `OUT     : if (`SDRAM_BYTE_WIDTH > 2) dqsn_do_isi_dly [3]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DQSN_3 signal but mem has less than 4-bits DQSN...", $time);
            endcase // case(direction)               
        `DM_3  :                                     
	    case (direction)                              
              `IN       : if (`SDRAM_BYTE_WIDTH > 2) dm_di_isi_dly [3]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
              `OUT      : if (`SDRAM_BYTE_WIDTH > 2) dm_do_isi_dly [3]    <= isi_value;
                   else $display("-> %0t: ==> WARNING: [ddr_sdram] attempt to set jitter on DM_3 signal but mem has less than 4-bits DM...", $time);
            endcase // case(direction)       
            
            
        `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15, `DQ_16, `DQ_17, `DQ_18, `DQ_19, `DQ_20, `DQ_21, `DQ_22, `DQ_23, `DQ_24, `DQ_25, `DQ_26, `DQ_27, `DQ_28, `DQ_29, `DQ_30, `DQ_31 :
            case (direction)
            `IN  :  dq_di_isi_dly[dx_signal]	<= isi_value;
            `OUT :  dq_do_isi_dly[dx_signal]	<= isi_value;
            endcase // case(direction)
	    
         default : $display("-> %0t: ==> WARNING: [set_dx_signal_isi_delay] incorrect or missing signal name specification on task call.", $time); 
      endcase // case(dx_signal)
      
    end
  endtask // set_dx_signal_isi_delay 
  
   
  initial  dqs_rd_enable   ={`SDRAM_BYTE_WIDTH{1'b0}};
  initial  dqs_rdx1_enable   ={`SDRAM_BYTE_WIDTH{1'b0}};  
  initial  dqs_n_rd_enable ={`SDRAM_BYTE_WIDTH{1'b0}};  
  initial  dqs_n_rdx1_enable ={`SDRAM_BYTE_WIDTH{1'b0}};
  initial  dq_rd_enable    ={`SDRAM_DATA_WIDTH{1'b0}};
  initial  dq_rdx1_enable    ={`SDRAM_DATA_WIDTH{1'b0}};
//`ifdef DDR4MPHY
  initial  dm_rd_enable    ={`SDRAM_BYTE_WIDTH{1'b0}};
  initial  dm_rdx1_enable    ={`SDRAM_BYTE_WIDTH{1'b0}};
//`endif
  initial  dm_wr_enable    ={`SDRAM_BYTE_WIDTH{1'b0}};
  initial  dm_wrx1_enable    ={`SDRAM_BYTE_WIDTH{1'b0}};      
  initial  dqs_wr_enable   ={`SDRAM_BYTE_WIDTH{1'b0}};      
  initial  dqs_wrx1_enable   ={`SDRAM_BYTE_WIDTH{1'b0}}; 
  initial  dqs_n_wr_enable ={`SDRAM_BYTE_WIDTH{1'b0}};
  initial  dqs_n_wrx1_enable ={`SDRAM_BYTE_WIDTH{1'b0}};
  initial  dq_wr_enable    ={`SDRAM_DATA_WIDTH{1'b0}};
  initial  dq_wrx1_enable    ={`SDRAM_DATA_WIDTH{1'b0}};
  
  

  //Write path : from dq to dq*_i
  rnmos DM_WR1_TRAN[`SDRAM_BYTE_WIDTH-1:0]   (dm_wr_i1, dm, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQ_WR1_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_wr_i1, dq, {`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQS_WR1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_wr_i1, dqs, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_WR1_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_i1, dqs_n, {`SDRAM_BYTE_WIDTH{1'b1}});
  buf (weak0,weak1) DM_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_wr_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQ_DUMMY_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_wr_i1,{`SDRAM_DATA_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQS_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_wr_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQSN_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  //need transport delays to be able to go above 1 bit period
generate
for(dx_bit=0;dx_bit<`SDRAM_DATA_WIDTH;dx_bit=dx_bit+1) begin :  u_wrdq_delays  
  //ISI constructs
  always@(dq_wr_i1[dx_bit])  nbits_dq_do[dx_bit] = ($realtime - t_dq_do[dx_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dq_do[dx_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dq_wr_i1[dx_bit])  t_dq_do[dx_bit] <= $realtime  ;

`ifndef LRDIMM_MULTI_RANK
  always@(posedge dq_wr_i1[dx_bit])    dq_wr_i2[dx_bit]    <= #(dq_do_sdram_dly[dx_bit] + dq_do_rj_dly[dx_bit] + dq_do_sj_dly[dx_bit] + dq_do_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_do[dx_bit])) - dq_do_dcd_dly[dx_bit]/2.0)  dq_wr_i1[dx_bit] ;
  always@(negedge dq_wr_i1[dx_bit])    dq_wr_i2[dx_bit]    <= #(dq_do_sdram_dly[dx_bit] + dq_do_rj_dly[dx_bit] + dq_do_sj_dly[dx_bit] + dq_do_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_do[dx_bit])) + dq_do_dcd_dly[dx_bit]/2.0)  dq_wr_i1[dx_bit] ;
`else
  always@(posedge dq[dx_bit])    dq_wr_i2[dx_bit]    <= #(dq_do_sdram_dly[dx_bit] + dq_do_rj_dly[dx_bit] + dq_do_sj_dly[dx_bit] + dq_do_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_do[dx_bit])) - dq_do_dcd_dly[dx_bit]/2.0)  dq[dx_bit] ;
  always@(negedge dq[dx_bit])    dq_wr_i2[dx_bit]    <= #(dq_do_sdram_dly[dx_bit] + dq_do_rj_dly[dx_bit] + dq_do_sj_dly[dx_bit] + dq_do_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_do[dx_bit])) + dq_do_dcd_dly[dx_bit]/2.0)  dq[dx_bit] ;
`endif
`ifndef LRDIMM_MULTI_RANK
  always@(dq_wr_i2[dx_bit])    dq_wr_enable[dx_bit] = (dq_wr_i2[dx_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
`else  
// if using LRDIMM use the write_detect signal to enable the write path
  always @(*) dq_wr_enable[dx_bit] = #(dq_do_sdram_dly[dx_bit] + dq_do_rj_dly[dx_bit] + dq_do_sj_dly[dx_bit] + dq_do_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_do[dx_bit])) - dq_do_dcd_dly[dx_bit]/2.0) write_detect_dq;
`endif  
end
for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin :  u_wrdqsdm_delays   
  //ISI constructs
  always@(dm_wr_i1[byte_bit])  nbits_dm_do[byte_bit] = ($realtime - t_dm_do[byte_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dm_do[byte_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dm_wr_i1[byte_bit])  t_dm_do[byte_bit] <= $realtime  ;
  always@(dqs_wr_i1[byte_bit])  nbits_dqs_do[byte_bit] = ($realtime - t_dqs_do[byte_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dqs_do[byte_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dqs_wr_i1[byte_bit])  t_dqs_do[byte_bit] <= $realtime  ;
  always@(dqs_n_wr_i1[byte_bit])  nbits_dqsn_do[byte_bit] = ($realtime - t_dqsn_do[byte_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dqsn_do[byte_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dqs_n_wr_i1[byte_bit])  t_dqsn_do[byte_bit] <= $realtime  ;

`ifndef LRDIMM_MULTI_RANK
  always@(posedge dm_wr_i1[byte_bit])    dm_wr_i2[byte_bit]    <= #(dm_do_sdram_dly[byte_bit] + dm_do_rj_dly[byte_bit] + dm_do_sj_dly[byte_bit] + dm_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_do[byte_bit])) - dm_do_dcd_dly[byte_bit]/2.0)  dm_wr_i1[byte_bit] ;
  always@(negedge dm_wr_i1[byte_bit])    dm_wr_i2[byte_bit]    <= #(dm_do_sdram_dly[byte_bit] + dm_do_rj_dly[byte_bit] + dm_do_sj_dly[byte_bit] + dm_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_do[byte_bit])) + dm_do_dcd_dly[byte_bit]/2.0)  dm_wr_i1[byte_bit] ;
  always@(posedge dqs_wr_i1[byte_bit])   dqs_wr_i2[byte_bit]   <= #(dqs_do_sdram_dly[byte_bit] + dqs_do_rj_dly[byte_bit] + dqs_do_sj_dly[byte_bit] + dqs_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_do[byte_bit])) - dqs_do_dcd_dly[byte_bit]/2.0)  dqs_wr_i1[byte_bit] ;
  always@(posedge dqs_n_wr_i1[byte_bit]) dqs_n_wr_i2[byte_bit] <= #(dqsn_do_sdram_dly[byte_bit] + dqsn_do_rj_dly[byte_bit] + dqsn_do_sj_dly[byte_bit] + dqsn_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_do[byte_bit])) - dqsn_do_dcd_dly[byte_bit]/2.0)  dqs_n_wr_i1[byte_bit] ;
  always@(negedge dqs_wr_i1[byte_bit])   dqs_wr_i2[byte_bit]   <= #(dqs_do_sdram_dly[byte_bit] + dqs_do_rj_dly[byte_bit] + dqs_do_sj_dly[byte_bit] + dqs_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_do[byte_bit])) + dqs_do_dcd_dly[byte_bit]/2.0)  dqs_wr_i1[byte_bit] ;
  always@(negedge dqs_n_wr_i1[byte_bit]) dqs_n_wr_i2[byte_bit] <= #(dqsn_do_sdram_dly[byte_bit] + dqsn_do_rj_dly[byte_bit] + dqsn_do_sj_dly[byte_bit] + dqsn_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_do[byte_bit])) + dqsn_do_dcd_dly[byte_bit]/2.0)  dqs_n_wr_i1[byte_bit] ;
`else  
// if using LRDIMM take the write signals directly from the data uffer
// instead of using the stepped down strength signal.
  always@(posedge dm[byte_bit])    dm_wr_i2[byte_bit]    <= #(dm_do_sdram_dly[byte_bit] + dm_do_rj_dly[byte_bit] + dm_do_sj_dly[byte_bit] + dm_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_do[byte_bit])) - dm_do_dcd_dly[byte_bit]/2.0)  dm[byte_bit] ;
  always@(negedge dm[byte_bit])    dm_wr_i2[byte_bit]    <= #(dm_do_sdram_dly[byte_bit] + dm_do_rj_dly[byte_bit] + dm_do_sj_dly[byte_bit] + dm_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_do[byte_bit])) + dm_do_dcd_dly[byte_bit]/2.0)  dm[byte_bit] ;
   always@(posedge dqs[byte_bit])   dqs_wr_i2[byte_bit]   <= #(dqs_do_sdram_dly[byte_bit] + dqs_do_rj_dly[byte_bit] + dqs_do_sj_dly[byte_bit] + dqs_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_do[byte_bit])) - dqs_do_dcd_dly[byte_bit]/2.0)  dqs[byte_bit] ;
  always@(posedge dqs_n[byte_bit]) dqs_n_wr_i2[byte_bit] <= #(dqsn_do_sdram_dly[byte_bit] + dqsn_do_rj_dly[byte_bit] + dqsn_do_sj_dly[byte_bit] + dqsn_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_do[byte_bit])) - dqsn_do_dcd_dly[byte_bit]/2.0)  dqs_n[byte_bit] ;
  always@(negedge dqs[byte_bit])   dqs_wr_i2[byte_bit]   <= #(dqs_do_sdram_dly[byte_bit] + dqs_do_rj_dly[byte_bit] + dqs_do_sj_dly[byte_bit] + dqs_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_do[byte_bit])) + dqs_do_dcd_dly[byte_bit]/2.0)  dqs[byte_bit] ;
  always@(negedge dqs_n[byte_bit]) dqs_n_wr_i2[byte_bit] <= #(dqsn_do_sdram_dly[byte_bit] + dqsn_do_rj_dly[byte_bit] + dqsn_do_sj_dly[byte_bit] + dqsn_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_do[byte_bit])) + dqsn_do_dcd_dly[byte_bit]/2.0)  dqs_n[byte_bit] ;
`endif 


`ifndef LRDIMM_MULTI_RANK
  `ifdef MICRON_DDR_V2
    always@(dm_wr_i2[byte_bit] or dm[byte_bit])    dm_wr_enable[byte_bit] = (dm[byte_bit] === 1'bz) ?  1'b0  :  ( (dm_wr_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0  );
  `else
    always@(dm_wr_i2[byte_bit])    dm_wr_enable[byte_bit] = (dm_wr_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
  `endif    
`else  
// if using LRDIMM use the write_detect signal to enable the write path
  always @(*) dm_wr_enable[byte_bit] = #(dm_do_sdram_dly[byte_bit] + dm_do_rj_dly[byte_bit] + dm_do_sj_dly[byte_bit] + dm_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_do[byte_bit])) - dm_do_dcd_dly[byte_bit]/2.0) write_detect;
`endif  
`ifndef LRDIMM_MULTI_RANK
  `ifdef MICRON_DDR_V2
    always@(dqs_wr_i2[byte_bit] or dqs[byte_bit])   dqs_wr_enable[byte_bit] = (dqs[byte_bit] === 1'bz) ?  1'b0 : ( (dqs_wr_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0  );
  `else 
    always@(dqs_wr_i2[byte_bit])   dqs_wr_enable[byte_bit] = (dqs_wr_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
  `endif  
`else  
// if using LRDIMM use the write_detect signal to enable the write path
  always @(*) dqs_wr_enable[byte_bit] = #(dqs_do_sdram_dly[byte_bit] + dqs_do_rj_dly[byte_bit] + dqs_do_sj_dly[byte_bit] + dqs_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_do[byte_bit])) - dqs_do_dcd_dly[byte_bit]/2.0) write_detect;

`endif  
`ifndef LRDIMM_MULTI_RANK
  `ifdef MICRON_DDR_V2
    always@(dqs_n_wr_i2[byte_bit] or dqs_n[byte_bit])   dqs_n_wr_enable[byte_bit] = (dqs_n[byte_bit] === 1'bz) ?  1'b0 : ( (dqs_n_wr_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0  );
  `else 
    always@(dqs_n_wr_i2[byte_bit]) dqs_n_wr_enable[byte_bit] = (dqs_n_wr_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
  `endif  
`else  
// if using LRDIMM use the write_detect signal to enable the write path
  always @(*) dqs_n_wr_enable[byte_bit] = #(dqsn_do_sdram_dly[byte_bit] + dqsn_do_rj_dly[byte_bit] + dqsn_do_sj_dly[byte_bit] + dqsn_do_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_do[byte_bit])) + dqsn_do_dcd_dly[byte_bit]/2.0) write_detect;
 
`endif  
end  
endgenerate

  bufif1 (pull0,pull1) #(1,1,0) DM_WR1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_i,dm_wr_i2,dm_wr_enable) ;
  bufif1 (pull0,pull1) #(1,1,0) DQ_WR1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_i,dq_wr_i2,dq_wr_enable) ;
  bufif1 (pull0,pull1) #(1,1,0) DQS_WR1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_i,dqs_wr_i2,dqs_wr_enable) ;
  bufif1 (pull0,pull1) #(1,1,0) DQSN_WR1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_i,dqs_n_wr_i2,dqs_n_wr_enable) ;
    //Read path : from dq*_i to dq*
//`ifdef DDR4MPHY  
   rnmos DM_RD1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dm_rd_i1, dm_i,{`SDRAM_BYTE_WIDTH{1'b1}});
//`endif
  rnmos DQ_RD1_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_rd_i1, dq_i,{`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQS_RD1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_rd_i1, dqs_i,{`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_RD1_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_i1, dqs_n_i,{`SDRAM_BYTE_WIDTH{1'b1}});
//`ifdef DDR4MPHY
  buf (weak0,weak1) DM_RDUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_rd_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
//`endif  
  buf (weak0,weak1) DQ_RDUMMY_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_rd_i1,{`SDRAM_DATA_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQS_RDUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_rd_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQSN_RDUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  //need transport delays to be able to go above 1 bit period
generate
for(dx_bit=0;dx_bit<`SDRAM_DATA_WIDTH;dx_bit=dx_bit+1) begin :  u_rddq_delays 
  //ISI constructs
  always@(dq_rd_i1[dx_bit])  nbits_dq_di[dx_bit] = ($realtime - t_dq_di[dx_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dq_di[dx_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;  
  always@(dq_rd_i1[dx_bit])  t_dq_di[dx_bit] <= $realtime  ;
  
  always@(posedge dq_rd_i1[dx_bit])    dq_rd_i2[dx_bit]    <= #(dq_di_sdram_dly[dx_bit] + dq_di_rj_dly[dx_bit] + dq_di_sj_dly[dx_bit] + dq_di_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_di[dx_bit])) - dq_di_dcd_dly[dx_bit]/2.0)  dq_rd_i1[dx_bit] ;
  always@(negedge dq_rd_i1[dx_bit])    dq_rd_i2[dx_bit]    <= #(dq_di_sdram_dly[dx_bit] + dq_di_rj_dly[dx_bit] + dq_di_sj_dly[dx_bit] + dq_di_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_di[dx_bit])) + dq_di_dcd_dly[dx_bit]/2.0)  dq_rd_i1[dx_bit] ; 

`ifndef LRDIMM_MULTI_RANK
  always@(dq_rd_i2[dx_bit])    dq_rd_enable[dx_bit] = (dq_rd_i2[dx_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
`else  
// if using LRDIMM use the read_detect signal to enable the read path
  always @(*)  dq_rd_enable[dx_bit] = #(dq_di_sdram_dly[dx_bit] + dq_di_rj_dly[dx_bit] + dq_di_sj_dly[dx_bit] + dq_di_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_di[dx_bit])) - dq_di_dcd_dly[dx_bit]/2.0) ((read_detect | write_detect_wl) & rst_n); 
`endif  
  always@(dq_rd_i2[dx_bit])    t_dq_do_probe[dx_bit] = dq_do_isi_dly[dx_bit]*(1.0 - 1.0/(1.0*nbits_dq_do[dx_bit])) ;
end
for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin :  u_rddqs_delays 

//`ifdef DDR4MPHY  
  always@(dm_rd_i1[byte_bit])  nbits_dm_di[byte_bit] = ($realtime - t_dm_di[byte_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dm_di[byte_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dm_rd_i1[byte_bit])  t_dm_di[byte_bit] <= $realtime  ;
  
  always@(posedge dm_rd_i1[byte_bit])    dm_rd_i2[byte_bit]    <= #(dm_di_sdram_dly[byte_bit] + dm_di_rj_dly[byte_bit] + dm_di_sj_dly[byte_bit] + dm_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_di[byte_bit])) - dm_di_dcd_dly[byte_bit]/2.0)  dm_rd_i1[byte_bit] ;
  always@(negedge dm_rd_i1[byte_bit])    dm_rd_i2[byte_bit]    <= #(dm_di_sdram_dly[byte_bit] + dm_di_rj_dly[byte_bit] + dm_di_sj_dly[byte_bit] + dm_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_di[byte_bit])) + dm_di_dcd_dly[byte_bit]/2.0)  dm_rd_i1[byte_bit] ;  
//`endif  
  //ISI constructs
  always@(dqs_rd_i1[byte_bit])  nbits_dqs_di[byte_bit] = ($realtime - t_dqs_di[byte_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dqs_di[byte_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dqs_rd_i1[byte_bit])  t_dqs_di[byte_bit] <= $realtime  ;
  always@(dqs_n_rd_i1[byte_bit])  nbits_dqsn_di[byte_bit] = ($realtime - t_dqsn_di[byte_bit] < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_dqsn_di[byte_bit] + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(dqs_n_rd_i1[byte_bit])  t_dqsn_di[byte_bit] <= $realtime  ;
  
  always@(posedge dqs_rd_i1[byte_bit])   dqs_rd_i2[byte_bit]   <= #(dqs_di_sdram_dly[byte_bit] + dqs_di_rj_dly[byte_bit] + dqs_di_sj_dly[byte_bit] + dqs_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_di[byte_bit])) - dqs_di_dcd_dly[byte_bit]/2.0)  dqs_rd_i1[byte_bit] ;
  always@(posedge dqs_n_rd_i1[byte_bit]) dqs_n_rd_i2[byte_bit] <= #(dqsn_di_sdram_dly[byte_bit] + dqsn_di_rj_dly[byte_bit] + dqsn_di_sj_dly[byte_bit] + dqsn_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_di[byte_bit])) - dqsn_di_dcd_dly[byte_bit]/2.0)  dqs_n_rd_i1[byte_bit] ;
  always@(negedge dqs_rd_i1[byte_bit])   dqs_rd_i2[byte_bit]   <= #(dqs_di_sdram_dly[byte_bit] + dqs_di_rj_dly[byte_bit] + dqs_di_sj_dly[byte_bit] + dqs_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_di[byte_bit])) + dqs_di_dcd_dly[byte_bit]/2.0)  dqs_rd_i1[byte_bit] ;
  always@(negedge dqs_n_rd_i1[byte_bit]) dqs_n_rd_i2[byte_bit] <= #(dqsn_di_sdram_dly[byte_bit] + dqsn_di_rj_dly[byte_bit] + dqsn_di_sj_dly[byte_bit] + dqsn_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_di[byte_bit])) + dqsn_di_dcd_dly[byte_bit]/2.0)  dqs_n_rd_i1[byte_bit] ;

`ifndef LRDIMM_MULTI_RANK
  always@(dqs_rd_i2[byte_bit])   dqs_rd_enable[byte_bit] = (dqs_rd_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
`else  
// if using LRDIMM use the read_detect signal to enable the read path
  always @(*) dqs_rd_enable[byte_bit] = #(dqs_di_sdram_dly[byte_bit] + dqs_di_rj_dly[byte_bit] + dqs_di_sj_dly[byte_bit] + dqs_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqs_di[byte_bit])) - dqs_di_dcd_dly[byte_bit]/2.0) read_detect;
`endif  
//`ifdef DDR4MPHY  
`ifndef LRDIMM_MULTI_RANK
  always@(dm_rd_i2[byte_bit])    dm_rd_enable[byte_bit] = (dm_rd_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
`else  
// if using LRDIMM use the read_detect signal to enable the read path
  always @(*) dm_rd_enable[byte_bit] = #(dm_di_sdram_dly[byte_bit] + dm_di_rj_dly[byte_bit] + dm_di_sj_dly[byte_bit] + dm_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dm_di[byte_bit])) - dm_di_dcd_dly[byte_bit]/2.0) read_detect;   
`endif  
//`endif
`ifndef LRDIMM_MULTI_RANK
  always@(dqs_n_rd_i2[byte_bit]) dqs_n_rd_enable[byte_bit] = (dqs_n_rd_i2[byte_bit]  !== 1'bx) ? 1'b1 : 1'b0 ;
`else  
// if using LRDIMM use the read_detect signal to enable the read path
  always @(*) dqs_n_rd_enable[byte_bit] = #(dqsn_di_sdram_dly[byte_bit] + dqsn_di_rj_dly[byte_bit] + dqsn_di_sj_dly[byte_bit] + dqsn_di_isi_dly[byte_bit]*(1.0 - 1.0/(1.0*nbits_dqsn_di[byte_bit])) + dqsn_di_dcd_dly[byte_bit]/2.0) read_detect;
`endif  
end
endgenerate 
  
//`ifdef DDR4MPHY  
  `ifndef LRDIMM_MULTI_RANK
   bufif1 (pull0,pull1) DM_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm,dm_rd_i2,dm_rd_enable) ;
  `else
   bufif1 DM_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm,dm_rd_i2,dm_rd_enable) ;
  `endif
//`endif
  `ifndef LRDIMM_MULTI_RANK
  bufif1 (pull0,pull1) DQ_RD1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq,dq_rd_i2,dq_rd_enable) ;
  `else
  bufif1 DQ_RD1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq,dq_rd_i2,dq_rd_enable) ;
  `endif
  `ifndef LRDIMM_MULTI_RANK
  bufif1 (pull0,pull1) DQS_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs,dqs_rd_i2,dqs_rd_enable) ;
  `else
  bufif1 DQS_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs,dqs_rd_i2,dqs_rd_enable) ;
  `endif
  `ifndef LRDIMM_MULTI_RANK
  bufif1 (pull0,pull1) DQSN_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n,dqs_n_rd_i2,dqs_n_rd_enable) ;
  `else
  bufif1 DQSN_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n,dqs_n_rd_i2,dqs_n_rd_enable) ;
  `endif
    //x value - for WRITE PATH - X value add on ----------------------------------------------------
  rnmos DM_WRx1_TRAN[`SDRAM_BYTE_WIDTH-1:0]   (dm_wr_x1, dm, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DM_WRx2_TRAN[`SDRAM_BYTE_WIDTH-1:0]   (dm_wr_x2, dm_wr_x1, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQ_WRx1_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_wr_x1, dq, {`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQ_WRx2_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_wr_x2, dq_wr_x1, {`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQS_WRx1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_wr_x1, dqs, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQS_WRx2_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_wr_x2, dqs_wr_x1, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_WRx1_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_x1, dqs_n, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_WRx2_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_x2, dqs_n_wr_x1, {`SDRAM_BYTE_WIDTH{1'b1}});

  buf (weak0,weak1) DM_DUMMYx_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_wr_x2,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  buf (weak0,weak1) DQ_DUMMYx_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_wr_x2,{`SDRAM_DATA_WIDTH{1'b0}}) ;
  buf (weak0,weak1) DQS_DUMMYx_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_wr_x2,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  buf (weak0,weak1) DQSN_DUMMYx_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_x2,{`SDRAM_BYTE_WIDTH{1'b1}}) ; 
  
generate
for(dx_bit=0;dx_bit<`SDRAM_DATA_WIDTH;dx_bit=dx_bit+1) begin :  u_wrdq_delays_x  
  always@(dq_wr_x1[dx_bit] or dq_wr_x2[dx_bit])    dq_wr_x3[dx_bit]    <= #(dq_do_sdram_dly[dx_bit])  dq_wr_x2[dx_bit] ;
  always@(*) dq_wrx1_enable[dx_bit] = (dq_wr_x3[dx_bit]  === 1'bx && dq_wr_enable[dx_bit] != 1'b1) ? 1'b1 : 1'b0 ;
end
for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin :  u_wrdqsdm_delays_x  
  always@(dm_wr_x1[byte_bit] or dm_wr_x2[byte_bit])    dm_wr_x3[byte_bit]    <= #(dm_do_sdram_dly[byte_bit])  dm_wr_x2[byte_bit] ;
  always@(dqs_wr_x1[byte_bit] or dqs_wr_x2[byte_bit])   dqs_wr_x3[byte_bit]   <= #(dqs_do_sdram_dly[byte_bit])  dqs_wr_x2[byte_bit] ;
  always@(dqs_n_wr_x1[byte_bit] or dqs_n_wr_x2[byte_bit]) dqs_n_wr_x3[byte_bit] <= #(dqsn_do_sdram_dly[byte_bit])  dqs_n_wr_x2[byte_bit] ;
  always@(*) dm_wrx1_enable[byte_bit] = (dm_wr_x3[byte_bit]  === 1'bx && dm_wr_enable[byte_bit] != 1'b1) ? 1'b1 : 1'b0 ;
  always@(*) dqs_wrx1_enable[byte_bit] = (dqs_wr_x3[byte_bit]  === 1'bx && dqs_wr_enable[byte_bit] != 1'b1) ? 1'b1 : 1'b0 ;
  always@(*) dqs_n_wrx1_enable[byte_bit] = (dqs_n_wr_x3[byte_bit]  === 1'bx && dqs_n_wr_enable[byte_bit] != 1'b1) ? 1'b1 : 1'b0 ;
end
endgenerate

  bufif1 (pull0,pull1) #(1,1,0) DM_WRx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_i,dm_wr_x3,dm_wrx1_enable) ;
  bufif1 (pull0,pull1) #(1,1,0) Q_WRx1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_i,dq_wr_x3,dq_wrx1_enable) ;
  bufif1 (pull0,pull1) #(1,1,0) DQS_WRx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_i,dqs_wr_x3,dqs_wrx1_enable) ;
  bufif1 (pull0,pull1) #(1,1,0) DQSN_WRx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_i,dqs_n_wr_x3,dqs_n_wrx1_enable) ;

//----------------------------------------------

   //x value logic - for READ PATH - X value add on ----------------------------------------------------
  rnmos DQ_RDx1_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_rd_x1, dq_i,{`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQ_RDx2_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_rd_x2, dq_rd_x1,{`SDRAM_DATA_WIDTH{1'b1}});
//`ifdef DDR4MPHY  
   rnmos DM_RDx1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dm_rd_x1, dm_i,{`SDRAM_BYTE_WIDTH{1'b1}});
   rnmos DM_RDx2_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dm_rd_x2, dm_rd_x1,{`SDRAM_BYTE_WIDTH{1'b1}});
//`endif
  rnmos DQS_RDx1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_rd_x1, dqs_i,{`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQS_RDx2_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_rd_x2, dqs_rd_x1,{`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_RDx1_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_x1, dqs_n_i,{`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_RDx2_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_x2, dqs_n_rd_x1,{`SDRAM_BYTE_WIDTH{1'b1}});

//`ifdef DDR4MPHY
  buf (weak0,weak1) DM_RDUMMYx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_rd_x2,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
//`endif
  buf (weak0,weak1) DQ_RDUMMYx1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_rd_x2,{`SDRAM_DATA_WIDTH{1'b0}}) ;
  buf (weak0,weak1) DQS_RDUMMYx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_rd_x2,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  buf (weak0,weak1) DQSN_RDUMMYx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_x2,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  
  //need transport delays to be able to go above 1 bit period
generate
for(dx_bit=0;dx_bit<`SDRAM_DATA_WIDTH;dx_bit=dx_bit+1) begin :  u_rddq_delays_x
  always@(dq_rd_x1[dx_bit] or dq_rd_x2[dx_bit])  dq_rd_x3[dx_bit]    <= #(dq_di_sdram_dly[dx_bit])  dq_rd_x2[dx_bit] ;
  always@(*) dq_rdx1_enable[dx_bit] = (dq_rd_x3[dx_bit]  === 1'bx && dq_rd_enable[dx_bit] != 1'b1) ? 1'b1 : 1'b0 ;
end
for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin :  u_rddqs_delays_x  
//`ifdef DDR4MPHY  
   always@(dm_rd_x1[byte_bit] or dm_rd_x2[byte_bit])    dm_rd_x3[byte_bit]   <= #(dm_di_sdram_dly[byte_bit]) dm_rd_x2[byte_bit] ;
//`endif
  always@(dqs_rd_x1[byte_bit] or dqs_rd_x2[byte_bit])   dqs_rd_x3[byte_bit]   <= #(dqs_di_sdram_dly[byte_bit]) dqs_rd_x2[byte_bit] ;
  always@(dqs_n_rd_x1[byte_bit] or dqs_n_rd_x2[byte_bit]) dqs_n_rd_x3[byte_bit] <= #(dqsn_di_sdram_dly[byte_bit]) dqs_n_rd_x2[byte_bit] ;
//`ifdef DDR4MPHY
  always@(*) dm_rdx1_enable[byte_bit] = (dm_rd_x3[byte_bit]  === 1'bx && dm_rd_enable[byte_bit] != 1'b1) ? 1'b1 : 1'b0 ;
//`endif
  always@(*) dqs_rdx1_enable[byte_bit] = (dqs_rd_x3[byte_bit]  === 1'bx && dqs_rd_enable[byte_bit] != 1'b1) ? 1'b1 : 1'b0 ;
  always@(*) dqs_n_rdx1_enable[byte_bit] = (dqs_n_rd_x3[byte_bit]  === 1'bx && dqs_n_rd_enable[byte_bit] != 1'b1) ? 1'b1 : 1'b0 ;
end
endgenerate 
  
//`ifdef DDR4MPHY
  bufif1 (pull0,pull1) DM_RDx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm,dm_rd_x3,dm_rdx1_enable) ;
//`endif
  bufif1 (pull0,pull1) DQ_RDx1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq,dq_rd_x3,dq_rdx1_enable) ;
  bufif1 (pull0,pull1) DQS_RDx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs,dqs_rd_x3,dqs_rdx1_enable) ;
  bufif1 (pull0,pull1) DQSN_RDx1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n,dqs_n_rd_x3,dqs_n_rdx1_enable) ;

//----------------------------------------------------

//recreate the pulldown on DQS/DQS_N as connected to the SDRAM
  `ifndef MICRON_DDR_V2
   buf (weak0,weak1) DQSI_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_i,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
   buf (weak0,weak1) DQSNI_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_i,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  `endif 
  
  
  reg dqs_bus_conflict ;
  reg dqsn_bus_conflict ;
  reg dq_bus_conflict ;
  reg dm_bus_conflict ;
  
  
  integer bc_loop_var ;
 
`ifdef VMM_VERIF
    vmm_log log = new("ddr_board_dly_model", "ddr_board_dly_model");
`endif
//**********************************************************************
//    Essaying LPDDR4MPHY bus conflict warnings enabling
//    Uncomment this ifdef - endif if false warnings are still observed 
//**********************************************************************
//`ifndef LPDDR4MPHY  
  initial begin
    dqs_bus_conflict  = 1'b0 ;
    dqsn_bus_conflict = 1'b0 ;
    dq_bus_conflict   = 1'b0 ;
//`ifdef DDR4MPHY
    dm_bus_conflict   = 1'b0 ;
//`endif
  end
   always@(dqs_rd_i1) begin
    #1;
    @(dqs_wr_i1);
    dqs_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dqs_rd_i1[bc_loop_var]!==1'bx) && (dqs_wr_i1[bc_loop_var]!==1'bx) ) dqs_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK
      if (dqs_bus_conflict == 1'b1)
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DQS signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DQS signal at %0t",$time);
        `endif
    `endif        
  end  
  always@(dqs_n_rd_i1) begin
     #1;
     @(dqs_n_wr_i1);
    dqsn_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dqs_n_rd_i1[bc_loop_var]!==1'bx) && (dqs_n_wr_i1[bc_loop_var]!==1'bx) ) dqsn_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK      
      if (dqsn_bus_conflict == 1'b1) 
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DQS_N signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DQS_N signal at %0t",$time);
        `endif
    `endif 
  end          
  always@(dq_rd_i1) begin
     #1;
     @(dq_wr_i1);
    dq_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_DATA_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dq_rd_i1[bc_loop_var]!==1'bx) && (dq_wr_i1[bc_loop_var]!==1'bx) ) dq_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK      
      if (dq_bus_conflict == 1'b1 && training_err == 0) 
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DQ signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DQ signal at %0t",$time);
        `endif
    `endif         
    end       
  `ifdef DWC_DX_DM_USE 
// `ifdef DDR4MPHY 
   `ifdef LPDDR4MPHY
     if (`DWC_DX_DM_USE != 9'h000)
   `endif
   always@(dm_rd_i1) begin
      #1;
      @(dm_wr_i1);
    dm_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dm_rd_i1[bc_loop_var]!==1'bx) && (dm_wr_i1[bc_loop_var]!==1'bx) ) dm_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK       
      if (dm_bus_conflict == 1'b1 && training_err == 0) 
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DM signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DM signal at %0t",$time);
        `endif
    `endif        
   end // always@ (dm_rd_i1 or dm_wr_i1)       
  `endif
  
   always@(dqs_wr_i1) begin
      #1;
      @(dqs_rd_i1); 
    dqs_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dqs_rd_i1[bc_loop_var]!==1'bx) && (dqs_wr_i1[bc_loop_var]!==1'bx) ) dqs_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK       
      if (dqs_bus_conflict == 1'b1)
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DQS signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DQS signal at %0t",$time);
        `endif
    `endif          
  end
    
  always@(dqs_n_wr_i1) begin
     #1;
     @(dqs_n_rd_i1); 
    dqsn_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dqs_n_rd_i1[bc_loop_var]!==1'bx) && (dqs_n_wr_i1[bc_loop_var]!==1'bx) ) dqsn_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK      
      if (dqsn_bus_conflict == 1'b1) 
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DQS_N signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DQS_N signal at %0t",$time);
        `endif
    `endif    
  end       
  always@(dq_wr_i1) begin
     #1;
     @(dq_rd_i1); 
    dq_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_DATA_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dq_rd_i1[bc_loop_var]!==1'bx) && (dq_wr_i1[bc_loop_var]!==1'bx) ) dq_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK        
      if (dq_bus_conflict == 1'b1 && training_err == 0) 
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DQ signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DQ signal at %0t",$time);
        `endif
    `endif         
  end 
      
  `ifdef DWC_DX_DM_USE
   `ifdef LPDDR4MPHY
     if (`DWC_DX_DM_USE != 9'h000)
   `endif
// `ifdef DDR4MPHY  
   always@(dm_wr_i1) begin
      #1;
      @(dm_rd_i1);
    dm_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dm_rd_i1[bc_loop_var]!==1'bx) && (dm_wr_i1[bc_loop_var]!==1'bx) ) dm_bus_conflict = 1'b1 ;
    `ifndef LRDIMM_MULTI_RANK       
      if (dm_bus_conflict == 1'b1 && training_err == 0) 
        `ifdef VMM_VERIF
          `vmm_warning(log, "Unexpected bus conflict on DM signal");
        `else
          $display("[ERROR]: Unexpected bus conflict on DM signal at %0t",$time);
        `endif
    `endif         
   end // always@ (dm_rd_i1 or dm_wr_i1)     
  `endif
 // `endif //  `ifdef DDR4MPHY
// `endif //  `ifdef BIDIRECTIONAL_SDRAM_DELAYS
//`endif //  `ifdef DWC_DDRPHY_BOARD_DELAYS

//**********************************************************************
//    Essaying LPDDR4MPHY bus conflict warnings enabling
//    Uncomment this ifdef - endif if false warnings are still observed 
//**********************************************************************
//`endif
   
initial begin
 integer bit_idx_l; //local version of bit_idx, to prevent race with another initial block
  
 training_err = 0;

 for (bit_idx_l=0;bit_idx_l<`SDRAM_ADDR_WIDTH;bit_idx_l=bit_idx_l+1)
   addr_sdram_dly  [bit_idx_l] = 0;

  ck_sdram_dly    = 0;
  ckn_sdram_dly    = 0;
  
`ifdef DDR4
  for (bit_idx_l=0;bit_idx_l<`DWC_PHY_BA_WIDTH + `DWC_PHY_BG_WIDTH;bit_idx_l=bit_idx_l+1)
    babg_sdram_dly [bit_idx_l] = 0;
`else
  for (bit_idx_l=0;bit_idx_l<`SDRAM_BANK_WIDTH;bit_idx_l=bit_idx_l+1)
    babg_sdram_dly [bit_idx_l] = 0;  
`endif  

  csn_sdram_dly = 0;
  for (bit_idx_l=0;bit_idx_l<`DWC_CID_WIDTH;bit_idx_l=bit_idx_l+1)
    cid_sdram_dly [bit_idx_l] = 0;  

  cke_sdram_dly = 0;  
  odt_sdram_dly = 0;  
  actn_sdram_dly = 0; 
  parin_sdram_dly = 0;   
  alertn_sdram_dly = 0;   
  
  for (bit_idx_l=0;bit_idx_l<`SDRAM_DATA_WIDTH;bit_idx_l=bit_idx_l+1) begin 
    dq_do_sdram_dly  [bit_idx_l] = 0;
    dq_di_sdram_dly  [bit_idx_l] = 0;
  end

  for (bit_idx_l=0;bit_idx_l<`SDRAM_BYTE_WIDTH;bit_idx_l=bit_idx_l+1) begin 
    dm_di_sdram_dly   [bit_idx_l] = 0;  
    dm_do_sdram_dly   [bit_idx_l] = 0;     
    dqs_do_sdram_dly  [bit_idx_l] = 0;
    dqs_di_sdram_dly  [bit_idx_l] = 0;
    dqsn_do_sdram_dly [bit_idx_l] = 0;
    dqsn_di_sdram_dly [bit_idx_l] = 0;
  end    
end  

   // From ddr3_sdram.v
`ifndef DWC_DX_DM_USE
  assign dm_i = 0;
   assign dm   = 0;
  `endif

  `ifdef DWC_DDRPHY_DMDQS_MUX
    `ifdef SDRAMx4
      assign dm_i = 0;
      assign dm   = 0;
    `endif
  `endif
 //---------------------------------------------------------------------------
 // Board Delays
 //---------------------------------------------------------------------------
 // New framework

 
  // set a specific board delay
  task set_dx_signal_sdram_delay;
    input integer dx_signal;
    input         direction;
    input integer dly;
`ifdef BIDIRECTIONAL_SDRAM_DELAYS    
    begin
      if (direction == `OUT)
        case (dx_signal)
          `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15, `DQ_16, `DQ_17, `DQ_18, `DQ_19, `DQ_20, `DQ_21, `DQ_22, `DQ_23, `DQ_24, `DQ_25, `DQ_26, `DQ_27, `DQ_28, `DQ_29, `DQ_30, `DQ_31 : 
                     dq_do_sdram_dly[dx_signal] = dly;
          `DQS    :  dqs_do_sdram_dly[0]  = dly;
          `DQS_1  :  dqs_do_sdram_dly[1]  = dly;
          `DQS_2  :  dqs_do_sdram_dly[2]  = dly;
          `DQS_3  :  dqs_do_sdram_dly[3]  = dly;
          `DQSN   :  dqsn_do_sdram_dly[0] = dly;
          `DQSN_1 :  dqsn_do_sdram_dly[1] = dly;
          `DQSN_2 :  dqsn_do_sdram_dly[2] = dly;
          `DQSN_3 :  dqsn_do_sdram_dly[3] = dly;
          `DM     :  dm_do_sdram_dly[0]  = dly;
          `DM_1   :  dm_do_sdram_dly[1]  = dly;
          `DM_2   :  dm_do_sdram_dly[2]  = dly;
          `DM_3   :  dm_do_sdram_dly[3]  = dly;
    	  default :  $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
        endcase // case ({direction, dx_signal})
      else if (direction == `IN)  
        case (dx_signal)
          `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15, `DQ_16, `DQ_17, `DQ_18, `DQ_19, `DQ_20, `DQ_21, `DQ_22, `DQ_23, `DQ_24, `DQ_25, `DQ_26, `DQ_27, `DQ_28, `DQ_29, `DQ_30, `DQ_31 :
                     dq_di_sdram_dly[dx_signal] = dly;
          `DQS    :  dqs_di_sdram_dly[0]  = dly;
          `DQS_1  :  dqs_di_sdram_dly[1]  = dly;
          `DQS_2  :  dqs_di_sdram_dly[2]  = dly;
          `DQS_3  :  dqs_di_sdram_dly[3]  = dly;
          `DQSN   :  dqsn_di_sdram_dly[0]  = dly;
          `DQSN_1 :  dqsn_di_sdram_dly[1]  = dly;
          `DQSN_2 :  dqsn_di_sdram_dly[2]  = dly;
          `DQSN_3 :  dqsn_di_sdram_dly[3]  = dly;
          `DM     :  dm_di_sdram_dly[0]  = dly;
          `DM_1   :  dm_di_sdram_dly[1]  = dly;
          `DM_2   :  dm_di_sdram_dly[2]  = dly;
          `DM_3   :  dm_di_sdram_dly[3]  = dly;
	      default :  $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
        endcase // case ({direction, dx_signal})
    end
`else
  $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] DQ/DQS/DM delay constructs can only be applied if BIDIRECTIONAL_SDRAM_DELAYS are defined!",$time);   
`endif
  endtask // set_dx_signal_sdram_delay
   
task set_ac_signal_sdram_delay;
  input integer ac_signal;
  input integer dly;
    
  begin
    case (ac_signal)
//`ifdef DDR4MPHY      
      `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8, `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17 :
        addr_sdram_dly[ac_signal] = dly;            
      `CMD_BA0,  `CMD_BA1, `CMD_BA2 , `CMD_BA3 :     babg_sdram_dly [ac_signal - `CMD_BA0] = dly;
      `CMD_ACT    :  actn_sdram_dly    = dly;
      `CMD_PARIN  :  parin_sdram_dly   = dly;
      `CMD_ALERTN :  alertn_sdram_dly  = dly;          
      `CMD_ODT    :  odt_sdram_dly     = dly;
      `CMD_CKE    :  cke_sdram_dly     = dly;
      `CMD_CSN    :  csn_sdram_dly     = dly;	  	  
      `AC_CK      :  ck_sdram_dly      = dly;
      `AC_CKN     :  ckn_sdram_dly     = dly; 
      `CMD_CID0, `CMD_CID1, `CMD_CID2: cid_sdram_dly [ac_signal - `CMD_CID0] = dly;     
//`endif	    	    
	  default   : $display("-> %0t: ==> WARNING: [set_ac_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
    endcase // case ({direction, ac_signal})
  end
endtask // set_ac_signal_sdram_delay
  
// AC Signal Random Jitter
// --------------
// sets RJ delays on AC signals
task set_ac_signal_rj_delay;
  input integer   ac_signal;      //Signal name to add RJ to.
  input integer   rj_pk2pk;       //Pk-pk value (in ps) for Random Jitter
  input integer   rj_sigma;       //Range of values (precision) for normal distribution.
                                  //  Distribution's sigma will be rj_pk2pk/(2.0*rj_sigma)
                                  //  Results will be capped to: rj_pk2pk = 2*rj_sigma.
                                  //  Valid inputs: any integer >=1, or 0. Higher values = more
                                  //  accurate results; Lower values = faster (less events) to 
                                  //  obtain pk-pk. If 0 is input, jitter will be a random choice
                                  //  between the {-pk, +pk} value pair (either one or the other).
  integer i;

  begin
    case (ac_signal)
      `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8, 
      `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17 : begin
         addr_rj_cap [ac_signal - `ADDR_0] <= rj_pk2pk;
         addr_rj_sig [ac_signal - `ADDR_0] <= rj_sigma;
      end
      `CMD_BA0, `CMD_BA1, `CMD_BA2, `CMD_BA3 : begin
        babg_rj_cap [ac_signal - `CMD_BA0] <= rj_pk2pk;
        babg_rj_sig [ac_signal - `CMD_BA0] <= rj_sigma;
      end
      `CMD_ACT : begin
        actn_rj_cap  <= rj_pk2pk;
        actn_rj_sig  <= rj_sigma;
      end
      `CMD_PARIN : begin
        parin_rj_cap  <= rj_pk2pk;
        parin_rj_sig  <= rj_sigma;
      end
      `CMD_ALERTN : begin
        alertn_rj_cap  <= rj_pk2pk;
        alertn_rj_sig  <= rj_sigma;
      end      
      `CMD_ODT   : begin
        odt_rj_cap  <= rj_pk2pk;
        odt_rj_sig  <= rj_sigma;
      end
      `CMD_CKE   : begin
        cke_rj_cap  <= rj_pk2pk;
        cke_rj_sig  <= rj_sigma;
      end
      `CMD_CSN   : begin
        csn_rj_cap  <= rj_pk2pk;
        csn_rj_sig  <= rj_sigma;
      end
      `CMD_CID0, `CMD_CID1, `CMD_CID2: begin
        cid_rj_cap [ac_signal - `CMD_CID0] <= rj_pk2pk;
        cid_rj_sig [ac_signal - `CMD_CID0] <= rj_sigma;
      end    
      default : $display("-> %0t: ==> WARNING: [set_ac_signal_rj_delay] incorrect or missing signal name specification on task call.", $time);        
    endcase // case(ac_signal)
  end
 endtask // set_ac_signal_rj_delay

  
generate
`ifdef DDR4
  for(ac_bit=0; ac_bit<pADDR_WIDTH; ac_bit=ac_bit+1) begin : addr_rj_dly_gen
`else 
  for(ac_bit=0; ac_bit<`SDRAM_ADDR_WIDTH; ac_bit=ac_bit+1) begin : addr_rj_dly_gen
`endif 
    always @( a[ac_bit] ) begin
      if (addr_rj_cap[ac_bit]==0)
        addr_rj_dly_tmp[ac_bit]  <= 0;
      else if (addr_rj_sig[ac_bit]==0)   //randomize between {0, PK} value pair
        addr_rj_dly_tmp[ac_bit]  <= ( {$random}%2 ) * addr_rj_cap[ac_bit]*1000;
      else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
        addr_rj_dly_tmp[ac_bit]  <= {$random} % (addr_rj_cap[ac_bit]*1000 + 1);
`else
`ifdef DWC_VERILOG2005
        addr_rj_dly_tmp[ac_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(addr_rj_cap[ac_bit]*1000/2.0)), convert64to32($rtoi(addr_rj_cap[ac_bit]*1000/(2.0*addr_rj_sig[ac_bit]))));
`else
        addr_rj_dly_tmp[ac_bit]  <= {$random} % (addr_rj_cap[ac_bit]*1000 + 1);
`endif
`endif
      if (addr_rj_dly_tmp[ac_bit]>=0 && addr_rj_dly_tmp[ac_bit]<=addr_rj_cap[ac_bit]*1000)
        addr_rj_dly[ac_bit]      <= $itor(addr_rj_dly_tmp[ac_bit])/1000.0 - $itor(addr_rj_cap[ac_bit])/2.0;
      else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
        addr_rj_dly[ac_bit]      <= ( {$random}%2 ) ? -( addr_rj_dly[ac_bit] ) :  addr_rj_dly[ac_bit];
    end
  end
  
`ifdef DDR4
  for(ac_bit=0; ac_bit<`DWC_PHY_BA_WIDTH; ac_bit=ac_bit+1) begin : ba_rj_dly_gen 
`else
  for(ac_bit=0; ac_bit<`SDRAM_BANK_WIDTH; ac_bit=ac_bit+1) begin : ba_rj_dly_gen
`endif  
    always @( ba[ac_bit] ) begin
      if (babg_rj_cap[ac_bit]==0)
          babg_rj_dly_tmp[ac_bit]  <= 0;
      else if (babg_rj_sig[ac_bit]==0)   //randomize between {0, PK} value pair
        babg_rj_dly_tmp[ac_bit]  <= ( {$random}%2 ) * babg_rj_cap[ac_bit]*1000;
      else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
        babg_rj_dly_tmp[ac_bit]  <= {$random} % (babg_rj_cap[ac_bit]*1000 + 1);
`else
`ifdef DWC_VERILOG2005
        babg_rj_dly_tmp[ac_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(babg_rj_cap[ac_bit]*1000/2.0)), convert64to32($rtoi(babg_rj_cap[ac_bit]*1000/(2.0*babg_rj_sig[ac_bit]))));
`else
        babg_rj_dly_tmp[ac_bit]  <= {$random} % (babg_rj_cap[ac_bit]*1000 + 1);
`endif
`endif
      if (babg_rj_dly_tmp[ac_bit]>=0 && babg_rj_dly_tmp[ac_bit]<=babg_rj_cap[ac_bit]*1000)
        babg_rj_dly[ac_bit]      <= $itor(babg_rj_dly_tmp[ac_bit])/1000.0 - $itor(babg_rj_cap[ac_bit])/2.0;
      else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
        babg_rj_dly[ac_bit]      <= ( {$random}%2 ) ? -( babg_rj_dly[ac_bit] ) :  babg_rj_dly[ac_bit];
    end
  end   
  
`ifdef DDR4
  for(ac_bit=0; ac_bit<`DWC_PHY_BG_WIDTH; ac_bit=ac_bit+1) begin : bg_rj_dly_gen 
    always @( bg[ac_bit] ) begin
      if (babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]==0)
        babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]  <= 0;
      else if (babg_rj_sig[`DWC_PHY_BA_WIDTH + ac_bit]==0)   //randomize between {0, PK} value pair
        babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]  <= ( {$random}%2 ) * babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]*1000;
      else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
        babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]  <= {$random} % (babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]*1000 + 1);
`else
`ifdef DWC_VERILOG2005
        babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]*1000/2.0)), convert64to32($rtoi(babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]*1000/(2.0*babg_rj_sig[`DWC_PHY_BA_WIDTH + ac_bit]))));
`else
        babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]  <= {$random} % (babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]*1000 + 1);
`endif
`endif
      if (babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]>=0 && babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit]<= babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit]*1000)
        babg_rj_dly[`DWC_PHY_BA_WIDTH + ac_bit]      <= $itor(babg_rj_dly_tmp[`DWC_PHY_BA_WIDTH + ac_bit])/1000.0 - $itor(babg_rj_cap[`DWC_PHY_BA_WIDTH + ac_bit])/2.0;
      else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
        babg_rj_dly[`DWC_PHY_BA_WIDTH + ac_bit]      <= ( {$random}%2 ) ? -( babg_rj_dly[`DWC_PHY_BA_WIDTH + ac_bit] ) :  babg_rj_dly[`DWC_PHY_BA_WIDTH + ac_bit];
    end
  end  
`endif 

  always @( act_n ) begin
    if (actn_rj_cap==0)
      actn_rj_dly_tmp  <= 0;
    else if (actn_rj_sig==0)   //randomize between {0, PK} value pair
      actn_rj_dly_tmp  <= ( {$random}%2 ) * actn_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      actn_rj_dly_tmp  <= {$random} % (actn_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      actn_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(actn_rj_cap*1000/2.0)), convert64to32($rtoi(actn_rj_cap*1000/(2.0*actn_rj_sig))));
`else
      actn_rj_dly_tmp  <= {$random} % (actn_rj_cap*1000 + 1);
`endif
`endif
    if (actn_rj_dly_tmp>=0 && actn_rj_dly_tmp<=actn_rj_cap*1000)
      actn_rj_dly      <= $itor(actn_rj_dly_tmp)/1000.0 - $itor(actn_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      actn_rj_dly      <= ( {$random}%2 ) ? -( actn_rj_dly ) :  actn_rj_dly;
  end
  
  always @( parity ) begin
    if (parin_rj_cap==0)
      parin_rj_dly_tmp  <= 0;
    else if (parin_rj_sig==0)   //randomize between {0, PK} value pair
      parin_rj_dly_tmp  <= ( {$random}%2 ) * parin_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      parin_rj_dly_tmp  <= {$random} % (parin_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      parin_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(parin_rj_cap*1000/2.0)), convert64to32($rtoi(parin_rj_cap*1000/(2.0*parin_rj_sig))));
`else
      parin_rj_dly_tmp  <= {$random} % (parin_rj_cap*1000 + 1);
`endif
`endif
    if (parin_rj_dly_tmp>=0 && parin_rj_dly_tmp<=parin_rj_cap*1000)
      parin_rj_dly      <= $itor(parin_rj_dly_tmp)/1000.0 - $itor(parin_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      parin_rj_dly      <= ( {$random}%2 ) ? -( parin_rj_dly ) :  parin_rj_dly;
  end  

`ifdef DDR4  
  always @( alert_n ) begin
    if (alertn_rj_cap==0)
      alertn_rj_dly_tmp  <= 0;
    else if (alertn_rj_sig==0)   //randomize between {0, PK} value pair
      alertn_rj_dly_tmp  <= ( {$random}%2 ) * alertn_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      alertn_rj_dly_tmp  <= {$random} % (alertn_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      alertn_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(alertn_rj_cap*1000/2.0)), convert64to32($rtoi(alertn_rj_cap*1000/(2.0*alertn_rj_sig))));
`else
      alertn_rj_dly_tmp  <= {$random} % (alertn_rj_cap*1000 + 1);
`endif
`endif
    if (alertn_rj_dly_tmp>=0 && alertn_rj_dly_tmp<=alertn_rj_cap*1000)
      alertn_rj_dly      <= $itor(alertn_rj_dly_tmp)/1000.0 - $itor(alertn_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      alertn_rj_dly      <= ( {$random}%2 ) ? -( alertn_rj_dly ) :  alertn_rj_dly;
  end 
`endif 
  
  always @( odt ) begin
    if (odt_rj_cap==0)
      odt_rj_dly_tmp  <= 0;
    else if (odt_rj_sig==0)   //randomize between {0, PK} value pair
      odt_rj_dly_tmp  <= ( {$random}%2 ) * odt_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      odt_rj_dly_tmp  <= {$random} % (odt_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      odt_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(odt_rj_cap*1000/2.0)), convert64to32($rtoi(odt_rj_cap*1000/(2.0*odt_rj_sig))));
`else
      odt_rj_dly_tmp  <= {$random} % (odt_rj_cap*1000 + 1);
`endif
`endif
    if (odt_rj_dly_tmp>=0 && odt_rj_dly_tmp<=odt_rj_cap*1000)
      odt_rj_dly      <= $itor(odt_rj_dly_tmp)/1000.0 - $itor(odt_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      odt_rj_dly      <= ( {$random}%2 ) ? -( odt_rj_dly ) :  odt_rj_dly;
  end   
  
  always @( cke ) begin
    if (cke_rj_cap==0)
      cke_rj_dly_tmp  <= 0;
    else if (cke_rj_sig==0)   //randomize between {0, PK} value pair
      cke_rj_dly_tmp  <= ( {$random}%2 ) * cke_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      cke_rj_dly_tmp  <= {$random} % (cke_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      cke_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(cke_rj_cap*1000/2.0)), convert64to32($rtoi(cke_rj_cap*1000/(2.0*cke_rj_sig))));
`else
      cke_rj_dly_tmp  <= {$random} % (cke_rj_cap*1000 + 1);
`endif
`endif
    if (cke_rj_dly_tmp>=0 && cke_rj_dly_tmp<=cke_rj_cap*1000)
      cke_rj_dly      <= $itor(cke_rj_dly_tmp)/1000.0 - $itor(cke_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      cke_rj_dly      <= ( {$random}%2 ) ? -( cke_rj_dly ) :  cke_rj_dly;
  end   
  
  always @( cs_n ) begin
    if (csn_rj_cap==0)
      csn_rj_dly_tmp  <= 0;
    else if (csn_rj_sig==0)   //randomize between {0, PK} value pair
      csn_rj_dly_tmp  <= ( {$random}%2 ) * csn_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      csn_rj_dly_tmp  <= {$random} % (csn_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      csn_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(csn_rj_cap*1000/2.0)), convert64to32($rtoi(csn_rj_cap*1000/(2.0*csn_rj_sig))));
`else
      csn_rj_dly_tmp  <= {$random} % (csn_rj_cap*1000 + 1);
`endif
`endif
    if (csn_rj_dly_tmp>=0 && csn_rj_dly_tmp<=csn_rj_cap*1000)
      csn_rj_dly      <= $itor(csn_rj_dly_tmp)/1000.0 - $itor(csn_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      csn_rj_dly      <= ( {$random}%2 ) ? -( csn_rj_dly ) :  csn_rj_dly;
  end 

`ifdef DDR4   
  for(ac_bit=0; ac_bit<`DWC_CID_WIDTH; ac_bit=ac_bit+1) begin : cid_rj_dly_gen
    always @( cid[ac_bit] ) begin
      if (cid_rj_cap[ac_bit]==0)
        cid_rj_dly_tmp[ac_bit]  <= 0;
      else if (cid_rj_sig[ac_bit]==0)   //randomize between {0, PK} value pair
        cid_rj_dly_tmp[ac_bit]  <= ( {$random}%2 ) * cid_rj_cap[ac_bit]*1000;
      else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
        cid_rj_dly_tmp[ac_bit]  <= {$random} % (cid_rj_cap[ac_bit]*1000 + 1);
`else
`ifdef DWC_VERILOG2005
        cid_rj_dly_tmp[ac_bit]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(cid_rj_cap[ac_bit]*1000/2.0)), convert64to32($rtoi(cid_rj_cap[ac_bit]*1000/(2.0*cid_rj_sig[ac_bit]))));
`else
        cid_rj_dly_tmp[ac_bit]  <= {$random} % (cid_rj_cap[ac_bit]*1000 + 1);
`endif
`endif
      if (cid_rj_dly_tmp[ac_bit]>=0 && cid_rj_dly_tmp[ac_bit]<=cid_rj_cap[ac_bit]*1000)
        cid_rj_dly[ac_bit]      <= $itor(cid_rj_dly_tmp[ac_bit])/1000.0 - $itor(cid_rj_cap[ac_bit])/2.0;
      else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
        cid_rj_dly[ac_bit]      <= ( {$random}%2 ) ? -( cid_rj_dly[ac_bit] ) :  cid_rj_dly[ac_bit];
    end
  end 
`endif
  
  always @( ras_n ) begin
    if (actn_rj_cap==0)
      actn_rj_dly_tmp  <= 0;
    else if (actn_rj_sig==0)   //randomize between {0, PK} value pair
      actn_rj_dly_tmp  <= ( {$random}%2 ) * actn_rj_cap*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      actn_rj_dly_tmp  <= {$random} % (actn_rj_cap*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      actn_rj_dly_tmp  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(actn_rj_cap*1000/2.0)), convert64to32($rtoi(actn_rj_cap*1000/(2.0*actn_rj_sig))));
`else
      actn_rj_dly_tmp  <= {$random} % (actn_rj_cap*1000 + 1);
`endif
`endif
    if (actn_rj_dly_tmp>=0 && actn_rj_dly_tmp<=actn_rj_cap*1000)
      actn_rj_dly      <= $itor(actn_rj_dly_tmp)/1000.0 - $itor(actn_rj_cap)/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      actn_rj_dly      <= ( {$random}%2 ) ? -( actn_rj_dly ) :  actn_rj_dly;
  end  
  
  always @( we_n ) begin
    if (addr_rj_cap[16]==0)
      addr_rj_dly_tmp[16]  <= 0;
    else if (addr_rj_sig[16]==0)   //randomize between {0, PK} value pair
      addr_rj_dly_tmp[16]  <= ( {$random}%2 ) * addr_rj_cap[16]*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      addr_rj_dly_tmp[16]  <= {$random} % (addr_rj_cap[16]*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      addr_rj_dly_tmp[16]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(addr_rj_cap[16]*1000/2.0)), convert64to32($rtoi(addr_rj_cap[16]*1000/(2.0*addr_rj_sig[16]))));
`else
      addr_rj_dly_tmp[16]  <= {$random} % (addr_rj_cap[16]*1000 + 1);
`endif
`endif
    if (addr_rj_dly_tmp[16]>=0 && addr_rj_dly_tmp[16]<=addr_rj_cap[16]*1000)
      addr_rj_dly[16]      <= $itor(addr_rj_dly_tmp[16])/1000.0 - $itor(addr_rj_cap[16])/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      addr_rj_dly[16]      <= ( {$random}%2 ) ? -( addr_rj_dly[16] ) :  addr_rj_dly[16];
  end
  
  always @( cas_n ) begin
    if (addr_rj_cap[17]==0)
      addr_rj_dly_tmp[17]  <= 0;
    else if (addr_rj_sig[17]==0)   //randomize between {0, PK} value pair
      addr_rj_dly_tmp[17]  <= ( {$random}%2 ) * addr_rj_cap[17]*1000;
    else                                  //normal distribution, centered at PK/2, spread by PK/2/sigma
`ifdef VMM_VERIF
      addr_rj_dly_tmp[17]  <= {$random} % (addr_rj_cap[17]*1000 + 1);
`else
`ifdef DWC_VERILOG2005
      addr_rj_dly_tmp[17]  <= $dist_normal(`SYS.seed_rr, convert64to32($rtoi(addr_rj_cap[17]*1000/2.0)), convert64to32($rtoi(addr_rj_cap[17]*1000/(2.0*addr_rj_sig[17]))));
`else
      addr_rj_dly_tmp[17]  <= {$random} % (addr_rj_cap[17]*1000 + 1);
`endif
`endif
    if (addr_rj_dly_tmp[17]>=0 && addr_rj_dly_tmp[17]<=addr_rj_cap[17]*1000)
      addr_rj_dly[17]      <= $itor(addr_rj_dly_tmp[17])/1000.0 - $itor(addr_rj_cap[17])/2.0;
    else      // if randomized value is out of bounds (defined sigma range), randomly mirror or keep previous value
      addr_rj_dly[17]      <= ( {$random}%2 ) ? -( addr_rj_dly[17] ) :  addr_rj_dly[17];
  end
  
        

endgenerate
  
  
  
  
// AC signal Sinusoidal Jitter
// -------------
// sets SJ delays on AC signals
task set_ac_signal_sj_delay;
  input integer   ac_signal;      //Signal name to add SJ to. Valid inputs: 99=ALL,
                                  //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
  input integer   sj_pk2pk;       //Pk-pk value (in ps) for Sinusoidal Jitter
  input real      sj_freq;        //Frequency for sinusoidal jitter, in Hz.
  input integer   sj_phase_sep;   //Absolute phase for dx_signal defined.

  begin
`ifndef DWC_VERILOG2005
//       `SYS.warning;
   if (`SYS.verbose > 3)  $display("-> %0t: ==> INFO: [ac_board_delays] DWC_VERILOG2005 not defined.", $time);
`endif
    case (ac_signal)
      `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8, 
      `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17 : begin
        addr_sj_amp [ac_signal - `ADDR_0] <= sj_pk2pk;     
        addr_sj_frq [ac_signal - `ADDR_0] <= sj_freq;      
        addr_sj_phs [ac_signal - `ADDR_0] <= sj_phase_sep; 
      end
      `CMD_BA0, `CMD_BA1, `CMD_BA2, `CMD_BA3 : begin
        babg_sj_amp [ac_signal - `CMD_BA0] <= sj_pk2pk;     
        babg_sj_frq [ac_signal - `CMD_BA0] <= sj_freq;      
        babg_sj_phs [ac_signal - `CMD_BA0] <= sj_phase_sep; 
      end
      `CMD_ACT : begin
        actn_sj_amp <= sj_pk2pk;     
        actn_sj_frq <= sj_freq;      
        actn_sj_phs <= sj_phase_sep; 
      end
      `CMD_PARIN     : begin
        parin_sj_amp <= sj_pk2pk;     
        parin_sj_frq <= sj_freq;      
        parin_sj_phs <= sj_phase_sep; 
      end
      `CMD_ALERTN    : begin
        alertn_sj_amp <= sj_pk2pk;     
        alertn_sj_frq <= sj_freq;      
        alertn_sj_phs <= sj_phase_sep; 
      end      
      `CMD_ODT       : begin
        odt_sj_amp <= sj_pk2pk;     
        odt_sj_frq <= sj_freq;      
        odt_sj_phs <= sj_phase_sep; 
      end
      `CMD_CKE     : begin
        cke_sj_amp <= sj_pk2pk;     
        cke_sj_frq <= sj_freq;      
        cke_sj_phs <= sj_phase_sep; 
      end
      `CMD_CSN     : begin
        csn_sj_amp <= sj_pk2pk;     
        csn_sj_frq <= sj_freq;      
        csn_sj_phs <= sj_phase_sep; 
      end
      `CMD_CID0, `CMD_CID1, `CMD_CID2: begin
        cid_sj_amp [ac_signal - `CMD_CID0] <= sj_pk2pk;     
        cid_sj_frq [ac_signal - `CMD_CID0] <= sj_freq;      
        cid_sj_phs [ac_signal - `CMD_CID0] <= sj_phase_sep;       
      end          
      default : $display("-> %0t: ==> WARNING: [set_ac_signal_sj_delay] incorrect or missing signal name specification on task call.", $time);
    endcase // case(dx_signal)
  end
endtask // set_dx_signal_sj_delay
        

generate
`ifdef DDR4
  for(ac_bit=0; ac_bit<pADDR_WIDTH; ac_bit=ac_bit+1) begin : addr_sj_dly_gen
`else 
  for(ac_bit=0; ac_bit<`SDRAM_ADDR_WIDTH; ac_bit=ac_bit+1) begin : addr_sj_dly_gen
`endif
    always @( a[ac_bit] ) begin
        addr_sj_dly[ac_bit]    <= (addr_sj_amp[ac_bit]==0 || addr_sj_frq[ac_bit]==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
          ( $itor(addr_sj_amp[ac_bit])/2 * $sin(2.0*pPI*addr_sj_frq[ac_bit]*$realtime/1e12 
          + 2.0*pPI*$itor(addr_sj_phs[ac_bit])/360) );
`else
          ( $itor( {$random} % (addr_sj_amp[ac_bit]*1000 + 1) ) / 1000 - $itor(addr_sj_amp[ac_bit])/2 );
`endif
    end
  end
  
`ifdef DDR4
  for(ac_bit=0; ac_bit<`DWC_PHY_BA_WIDTH; ac_bit=ac_bit+1) begin : ba_sj_dly_gen 
`else
  for(ac_bit=0; ac_bit<`SDRAM_BANK_WIDTH; ac_bit=ac_bit+1) begin : ba_sj_dly_gen
`endif  
    always @( ba[ac_bit] ) begin
        babg_sj_dly[ac_bit]    <= (babg_sj_amp[ac_bit]==0 || babg_sj_frq[ac_bit]==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
          ( $itor(babg_sj_amp[ac_bit])/2 * $sin(2.0*pPI*babg_sj_frq[ac_bit]*$realtime/1e12 
          + 2.0*pPI*$itor(babg_sj_phs[ac_bit])/360) );
`else
          ( $itor( {$random} % (babg_sj_amp[ac_bit]*1000 + 1) ) / 1000 - $itor(babg_sj_amp[ac_bit])/2 );
`endif
    end
  end

`ifdef DDR4
  for(ac_bit=0; ac_bit<`DWC_PHY_BG_WIDTH; ac_bit=ac_bit+1) begin : bg_sj_dly_gen 
    always @( bg[ac_bit] ) begin
        babg_sj_dly[ac_bit + `DWC_PHY_BG_WIDTH]    <= (babg_sj_amp[ac_bit+`DWC_PHY_BG_WIDTH]==0 || babg_sj_frq[ac_bit+`DWC_PHY_BG_WIDTH]==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
          ( $itor(babg_sj_amp[ac_bit+`DWC_PHY_BG_WIDTH])/2 * $sin(2.0*pPI*babg_sj_frq[ac_bit+`DWC_PHY_BG_WIDTH]*$realtime/1e12 
          + 2.0*pPI*$itor(babg_sj_phs[ac_bit])/360) );
`else
          ( $itor( {$random} % (babg_sj_amp[ac_bit+`DWC_PHY_BG_WIDTH]*1000 + 1) ) / 1000 - $itor(babg_sj_amp[ac_bit+`DWC_PHY_BG_WIDTH])/2 );
`endif
    end
  end  
`endif 

  always @( act_n ) begin
    actn_sj_dly    <= (actn_sj_amp==0 || actn_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(actn_sj_amp)/2 * $sin(2.0*pPI*actn_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(actn_sj_phs)/360) );
`else
        ( $itor( {$random} % (actn_sj_amp*1000 + 1) ) / 1000 - $itor(actn_sj_amp)/2 );
`endif
  end
  
  always @( parity ) begin
    parin_sj_dly    <= (parin_sj_amp==0 || parin_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(parin_sj_amp)/2 * $sin(2.0*pPI*parin_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(parin_sj_phs)/360) );
`else
        ( $itor( {$random} % (parin_sj_amp*1000 + 1) ) / 1000 - $itor(parin_sj_amp)/2 );
`endif
  end 
 
`ifdef DDR4   
  always @( alert_n ) begin
    alertn_sj_dly    <= (alertn_sj_amp==0 || alertn_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(alertn_sj_amp)/2 * $sin(2.0*pPI*alertn_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(alertn_sj_phs)/360) );
`else
        ( $itor( {$random} % (alertn_sj_amp*1000 + 1) ) / 1000 - $itor(alertn_sj_amp)/2 );
`endif
  end 
`endif  
  
  always @( odt ) begin
    odt_sj_dly    <= (odt_sj_amp==0 || odt_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(odt_sj_amp)/2 * $sin(2.0*pPI*odt_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(odt_sj_phs)/360) );
`else
        ( $itor( {$random} % (odt_sj_amp*1000 + 1) ) / 1000 - $itor(odt_sj_amp)/2 );
`endif
  end  
  
  always @( cke ) begin
    cke_sj_dly    <= (cke_sj_amp==0 || cke_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(cke_sj_amp)/2 * $sin(2.0*pPI*cke_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(cke_sj_phs)/360) );
`else
        ( $itor( {$random} % (cke_sj_amp*1000 + 1) ) / 1000 - $itor(cke_sj_amp)/2 );
`endif
  end  
  
  always @( cs_n ) begin
    csn_sj_dly    <= (csn_sj_amp==0 || csn_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(csn_sj_amp)/2 * $sin(2.0*pPI*csn_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(csn_sj_phs)/360) );
`else
        ( $itor( {$random} % (csn_sj_amp*1000 + 1) ) / 1000 - $itor(csn_sj_amp)/2 );
`endif
  end 
 
`ifdef DDR4   
  for(ac_bit=0; ac_bit<`DWC_CID_WIDTH; ac_bit=ac_bit+1) begin : cid_sj_dly_gen
    always @( cid[ac_bit] ) begin
        cid_sj_dly[ac_bit]    <= (cid_sj_amp[ac_bit]==0 || cid_sj_frq[ac_bit]==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
          ( $itor(cid_sj_amp[ac_bit])/2 * $sin(2.0*pPI*cid_sj_frq[ac_bit]*$realtime/1e12 
          + 2.0*pPI*$itor(cid_sj_phs[ac_bit])/360) );
`else
          ( $itor( {$random} % (cid_sj_amp[ac_bit]*1000 + 1) ) / 1000 - $itor(cid_sj_amp[ac_bit])/2 );
`endif
    end
  end
`endif
  
  always @( ras_n ) begin
    actn_sj_dly    <= (actn_sj_amp==0 || actn_sj_frq==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(actn_sj_amp)/2 * $sin(2.0*pPI*actn_sj_frq*$realtime/1e12 
        + 2.0*pPI*$itor(actn_sj_phs)/360) );
`else
        ( $itor( {$random} % (actn_sj_amp*1000 + 1) ) / 1000 - $itor(actn_sj_amp)/2 );
`endif
  end 
  
  always @( we_n ) begin
      addr_sj_dly[16]    <= (addr_sj_amp[16]==0 || addr_sj_frq[16]==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(addr_sj_amp[16])/2 * $sin(2.0*pPI*addr_sj_frq[16]*$realtime/1e12 
        + 2.0*pPI*$itor(addr_sj_phs[16])/360) );
`else
        ( $itor( {$random} % (addr_sj_amp[16]*1000 + 1) ) / 1000 - $itor(addr_sj_amp[16])/2 );
`endif
  end

  always @( cas_n ) begin
      addr_sj_dly[17]    <= (addr_sj_amp[17]==0 || addr_sj_frq[17]==0.0) ? 0.0 :
`ifdef DWC_VERILOG2005
        ( $itor(addr_sj_amp[17])/2 * $sin(2.0*pPI*addr_sj_frq[17]*$realtime/1e12 
        + 2.0*pPI*$itor(addr_sj_phs[17])/360) );
`else
        ( $itor( {$random} % (addr_sj_amp[17]*1000 + 1) ) / 1000 - $itor(addr_sj_amp[17])/2 );
`endif
  end
       

endgenerate


  // AC signal DCD
  // -------------
  // sets DCD delays on DQS, DQS#, DM and DQ output and input signals
  task set_ac_signal_dcd_delay;
    input integer   ac_signal;      //Signal name to add RJ to. Valid inputs: 99=ALL,
                                    //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
    input integer   dcd_value;      //(Max) Distortion value (in ps) for selected edge(s); positive values extend "1"s, negative values extend "0"s
        
    begin
`ifndef DWC_VERILOG2005
//       `SYS.warning;
     if (`SYS.verbose > 3)  $display("-> %0t: ==> INFO: [ac_board_delays] DWC_VERILOG2005 not defined.", $time);
`endif
      
      case (ac_signal)
        `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8, 
        `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17 :
          addr_dcd_dly [ac_signal - `ADDR_0] <= dcd_value;
        `CMD_BA0, `CMD_BA1, `CMD_BA2, `CMD_BA3      :
          babg_dcd_dly [ac_signal - `CMD_BA0] <= dcd_value ;     
        `CMD_ACT     : 
          actn_dcd_dly <= dcd_value;   
        `CMD_PARIN     :
          parin_dcd_dly <= dcd_value;  
        `CMD_ALERTN    :
          alertn_dcd_dly <= dcd_value;           
        `CMD_ODT     :
          odt_dcd_dly  <= dcd_value;  
        `CMD_CKE     :
          cke_dcd_dly  <= dcd_value;  
        `CMD_CSN     :
          csn_dcd_dly <= dcd_value;  
        `CMD_CID0, `CMD_CID1, `CMD_CID2 :
          cid_dcd_dly [ac_signal - `CMD_CID0] <= dcd_value ;           
        default : $display("-> %0t: ==> WARNING: [set_ac_signal_dcd_delay] incorrect or missing signal name specification on task call.", $time);
      endcase // case(dx_signal)
    end
    
  endtask // set_ac_signal_dcd_delay


  // AC signal ISI
  // -------------
  // sets ISI (max) delays on AC signals
  task set_ac_signal_isi_delay;
    input integer   ac_signal;      //Signal name to add RJ to. Valid inputs: 99=ALL,
                                    //  [0..7]=DQ[0..7], 8=DQS, 9=DQSN, and 10=DM
    input integer   isi_value;      //(Max) Distortion value (in ps) for selected edge(s); positive values extend "1"s, negative values extend "0"s
        
    begin
`ifndef DWC_VERILOG2005
//       `SYS.warning;
     if (`SYS.verbose > 3)  $display("-> %0t: ==> INFO: [ac_board_delays] DWC_VERILOG2005 not defined.", $time);
`endif
      
      case (ac_signal)
        `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8, 
        `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17 :
          addr_isi_dly [ac_signal - `ADDR_0] <= isi_value;
        `CMD_BA0, `CMD_BA1, `CMD_BA2, `CMD_BA3      :
          babg_isi_dly [ac_signal - `CMD_BA0] <= isi_value ;     
        `CMD_ACT     : 
          actn_isi_dly <= isi_value;   
        `CMD_PARIN     :
          parin_isi_dly <= isi_value;  
        `CMD_ALERTN    :
          alertn_isi_dly <= isi_value;           
        `CMD_ODT     :
          odt_isi_dly  <= isi_value;  
        `CMD_CKE     :
          cke_isi_dly  <= isi_value;  
        `CMD_CSN     :
          csn_isi_dly <= isi_value;  
        `CMD_CID0, `CMD_CID1, `CMD_CID2 :
          cid_isi_dly [ac_signal - `CMD_CID0] <= isi_value ;           
        default : $display("-> %0t: ==> WARNING: [set_ac_signal_isi_delay] incorrect or missing signal name specification on task call.", $time);
      endcase // case(dx_signal)
    end
    
  endtask // set_ac_signal_isi_delay
    
    
  // delayed signals
  // ---------------
  // signals after board delays

  always@(act_n)    nbits_act_n    = ($realtime - t_act_n   < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_act_n   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(parity)   nbits_parity   = ($realtime - t_parity  < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_parity  + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
`ifdef DDR4   
  always@(alert_n)  nbits_alert_n  = ($realtime - t_alert_n < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_alert_n + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
`endif  
  always@(odt)      nbits_odt      = ($realtime - t_odt     < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_odt     + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(cke)      nbits_cke      = ($realtime - t_cke     < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_cke     + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(cs_n)     nbits_cs_n     = ($realtime - t_cs_n    < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_cs_n    + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(we_n)     nbits_we_n     = ($realtime - t_we_n    < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_we_n    + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(cas_n)    nbits_cas_n    = ($realtime - t_cas_n   < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_cas_n   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  always@(ras_n)    nbits_ras_n    = ($realtime - t_ras_n   < 0.75*(`CLK_PRD*1e3)) ?  1 : ($realtime - t_ras_n   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;
  
  always@(act_n)    t_act_n    <= $realtime  ;
  always@(parity)   t_parity   <= $realtime  ;
`ifdef DDR4 
  always@(alert_n)  t_alert_n  <= $realtime  ;
`endif
  always@(odt)      t_odt      <= $realtime  ;
  always@(cke)      t_cke      <= $realtime  ;
  always@(cs_n)     t_cs_n     <= $realtime  ;
  always@(we_n)     t_we_n     <= $realtime  ;
  always@(cas_n)    t_cas_n    <= $realtime  ;
  always@(ras_n)    t_ras_n    <= $realtime  ;
    
  
  
  always @(ck)     ck_i     <= #(ck_sdram_dly) ck;
  always @(ck_n)   ck_n_i   <= #(ckn_sdram_dly) ck_n;  
  always @(posedge act_n)  act_n_i  <= #(actn_sdram_dly + actn_rj_dly + actn_sj_dly + actn_isi_dly*(1.0 - 1.0/(1.0*nbits_act_n)) - actn_dcd_dly/2.0)  act_n; 
  always @(negedge act_n)  act_n_i  <= #(actn_sdram_dly + actn_rj_dly + actn_sj_dly + actn_isi_dly*(1.0 - 1.0/(1.0*nbits_act_n)) + actn_dcd_dly/2.0)  act_n;  
  always @(posedge parity)  parity_i  <= #(parin_sdram_dly + parin_rj_dly + parin_sj_dly + parin_isi_dly*(1.0 - 1.0/(1.0*nbits_parity)) - parin_dcd_dly/2.0)  parity; 
  always @(negedge parity)  parity_i  <= #(parin_sdram_dly + parin_rj_dly + parin_sj_dly + parin_isi_dly*(1.0 - 1.0/(1.0*nbits_parity)) + parin_dcd_dly/2.0)  parity;   
  `ifdef DDR4   
  always @(posedge alert_n)  alert_n_i  <= #(alertn_sdram_dly + alertn_rj_dly + alertn_sj_dly + alertn_isi_dly*(1.0 - 1.0/(1.0*nbits_alert_n)) - alertn_dcd_dly/2.0)  alert_n; 
  always @(negedge alert_n)  alert_n_i  <= #(alertn_sdram_dly + alertn_rj_dly + alertn_sj_dly + alertn_isi_dly*(1.0 - 1.0/(1.0*nbits_alert_n)) + alertn_dcd_dly/2.0)  alert_n;    
  `endif  
  always @(posedge odt)  odt_i  <= #(odt_sdram_dly + odt_rj_dly + odt_sj_dly + odt_isi_dly*(1.0 - 1.0/(1.0*nbits_odt)) - odt_dcd_dly/2.0)  odt; 
  always @(negedge odt)  odt_i  <= #(odt_sdram_dly + odt_rj_dly + odt_sj_dly + odt_isi_dly*(1.0 - 1.0/(1.0*nbits_odt)) + odt_dcd_dly/2.0)  odt;     
  always @(posedge cke)  cke_i  <= #(cke_sdram_dly + cke_rj_dly + cke_sj_dly + cke_isi_dly*(1.0 - 1.0/(1.0*nbits_cke)) - cke_dcd_dly/2.0)  cke; 
  always @(negedge cke)  cke_i  <= #(cke_sdram_dly + cke_rj_dly + cke_sj_dly + cke_isi_dly*(1.0 - 1.0/(1.0*nbits_cke)) + cke_dcd_dly/2.0)  cke;  
  always @(posedge cs_n)  cs_n_i  <= #(csn_sdram_dly + csn_rj_dly + csn_sj_dly + csn_isi_dly*(1.0 - 1.0/(1.0*nbits_cs_n)) - csn_dcd_dly/2.0)  cs_n; 
  always @(negedge cs_n)  cs_n_i  <= #(csn_sdram_dly + csn_rj_dly + csn_sj_dly + csn_isi_dly*(1.0 - 1.0/(1.0*nbits_cs_n)) + csn_dcd_dly/2.0)  cs_n;  
  //always @(posedge we_n)  we_n_i  <= #(addr_sdram_dly[16] + addr_rj_dly[16] + addr_sj_dly[16] + addr_isi_dly[16]*(1.0 - 1.0/(1.0*nbits_we_n)) - addr_dcd_dly[16]/2.0)  we_n; 
  //always @(negedge we_n)  we_n_i  <= #(addr_sdram_dly[16] + addr_rj_dly[16] + addr_sj_dly[16] + addr_isi_dly[16]*(1.0 - 1.0/(1.0*nbits_we_n)) + addr_dcd_dly[16]/2.0)  we_n;  
  //always @(posedge cas_n)  cas_n_i  <= #(addr_sdram_dly[17] + addr_rj_dly[17] + addr_sj_dly[17] + addr_isi_dly[17]*(1.0 - 1.0/(1.0*nbits_cas_n)) - addr_dcd_dly[17]/2.0)  cas_n; 
  //always @(negedge cas_n)  cas_n_i  <= #(addr_sdram_dly[17] + addr_rj_dly[17] + addr_sj_dly[17] + addr_isi_dly[17]*(1.0 - 1.0/(1.0*nbits_cas_n)) + addr_dcd_dly[17]/2.0)  cas_n; 
  //always @(posedge ras_n)  ras_n_i  <= #(actn_sdram_dly + actn_rj_dly + actn_sj_dly + actn_isi_dly*(1.0 - 1.0/(1.0*nbits_ras_n)) - actn_dcd_dly/2.0)  ras_n; 
  //always @(negedge ras_n)  ras_n_i  <= #(actn_sdram_dly + actn_rj_dly + actn_sj_dly + actn_isi_dly*(1.0 - 1.0/(1.0*nbits_ras_n)) + actn_dcd_dly/2.0)  ras_n;     
  always @(posedge we_n)  we_n_i  <= #(we_n_sdram_dly + addr_rj_dly[16] + addr_sj_dly[16] + addr_isi_dly[16]*(1.0 - 1.0/(1.0*nbits_we_n)) - addr_dcd_dly[16]/2.0)  we_n; 
  always @(negedge we_n)  we_n_i  <= #(we_n_sdram_dly + addr_rj_dly[16] + addr_sj_dly[16] + addr_isi_dly[16]*(1.0 - 1.0/(1.0*nbits_we_n)) + addr_dcd_dly[16]/2.0)  we_n;  
  always @(posedge cas_n)  cas_n_i  <= #(cas_n_sdram_dly + addr_rj_dly[17] + addr_sj_dly[17] + addr_isi_dly[17]*(1.0 - 1.0/(1.0*nbits_cas_n)) - addr_dcd_dly[17]/2.0)  cas_n; 
  always @(negedge cas_n)  cas_n_i  <= #(cas_n_sdram_dly + addr_rj_dly[17] + addr_sj_dly[17] + addr_isi_dly[17]*(1.0 - 1.0/(1.0*nbits_cas_n)) + addr_dcd_dly[17]/2.0)  cas_n; 
  always @(posedge ras_n)  ras_n_i  <= #(ras_n_sdram_dly + actn_rj_dly + actn_sj_dly + actn_isi_dly*(1.0 - 1.0/(1.0*nbits_ras_n)) - actn_dcd_dly/2.0)  ras_n; 
  always @(negedge ras_n)  ras_n_i  <= #(ras_n_sdram_dly + actn_rj_dly + actn_sj_dly + actn_isi_dly*(1.0 - 1.0/(1.0*nbits_ras_n)) + actn_dcd_dly/2.0)  ras_n;     
 
  
generate
for(ac_bit=0; ac_bit<`SDRAM_ADDR_WIDTH; ac_bit=ac_bit+1) begin :  u_addr_dly_gen
  always@(a[ac_bit])    nbits_a[ac_bit]   =  ($realtime - t_a[ac_bit]  < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_a[ac_bit]   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;    
  always@(a[ac_bit])    t_a[ac_bit]       <= $realtime  ;   
  always @(posedge a[ac_bit])  a_i[ac_bit]  <= #(addr_sdram_dly[ac_bit] + addr_rj_dly[ac_bit] + addr_sj_dly[ac_bit] + addr_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_a[ac_bit])) - addr_dcd_dly[ac_bit]/2.0)  a[ac_bit]; 
  always @(negedge a[ac_bit])  a_i[ac_bit]  <= #(addr_sdram_dly[ac_bit] + addr_rj_dly[ac_bit] + addr_sj_dly[ac_bit] + addr_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_a[ac_bit])) + addr_dcd_dly[ac_bit]/2.0)  a[ac_bit]; 
end
`ifdef DDR4
for(ac_bit=0; ac_bit<`DWC_PHY_BA_WIDTH; ac_bit=ac_bit+1) begin :  u_ba_dly_gen
  always@(ba[ac_bit])    nbits_ba[ac_bit]   =  ($realtime - t_ba[ac_bit]  < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_ba[ac_bit]   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;    
  always@(ba[ac_bit])    t_ba[ac_bit]       <= $realtime  ;   
  always @(posedge ba[ac_bit])  ba_i[ac_bit]  <= #(babg_sdram_dly[ac_bit] + babg_rj_dly[ac_bit] + babg_sj_dly[ac_bit] + babg_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_ba[ac_bit])) - babg_dcd_dly[ac_bit]/2.0)  ba[ac_bit]; 
  always @(negedge ba[ac_bit])  ba_i[ac_bit]  <= #(babg_sdram_dly[ac_bit] + babg_rj_dly[ac_bit] + babg_sj_dly[ac_bit] + babg_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_ba[ac_bit])) + babg_dcd_dly[ac_bit]/2.0)  ba[ac_bit];   
end

`ifdef SDRAMx16
for(ac_bit=0; ac_bit<`DWC_PHY_BG_WIDTH; ac_bit=ac_bit+1) begin :  u_bg_dly_gen
  if(ac_bit<1) begin
    always@(bg[ac_bit])    nbits_bg[ac_bit]   =  ($realtime - t_bg[ac_bit]  < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_bg[ac_bit]   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;    
    always@(bg[ac_bit])    t_bg[ac_bit]       <= $realtime  ;   
    always @(posedge bg[ac_bit])  bg_i[ac_bit]  <= #(babg_sdram_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_rj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_sj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_isi_dly[ac_bit+`DWC_PHY_BA_WIDTH]*(1.0 - 1.0/(1.0*nbits_bg[ac_bit])) - babg_dcd_dly[ac_bit+`DWC_PHY_BA_WIDTH]/2.0)  bg[ac_bit]; 
    always @(negedge bg[ac_bit])  bg_i[ac_bit]  <= #(babg_sdram_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_rj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_sj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_isi_dly[ac_bit+`DWC_PHY_BA_WIDTH]*(1.0 - 1.0/(1.0*nbits_bg[ac_bit])) + babg_dcd_dly[ac_bit+`DWC_PHY_BA_WIDTH]/2.0)  bg[ac_bit];
  end else
    always @(bg[ac_bit])  bg_i[ac_bit] <=  1'b0;  
end
`else
for(ac_bit=0; ac_bit<`DWC_PHY_BG_WIDTH; ac_bit=ac_bit+1) begin :  u_bg_dly_gen
  always@(bg[ac_bit])    nbits_bg[ac_bit]   =  ($realtime - t_bg[ac_bit]  < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_bg[ac_bit]   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;    
  always@(bg[ac_bit])    t_bg[ac_bit]       <= $realtime  ;   
  always @(posedge bg[ac_bit])  bg_i[ac_bit]  <= #(babg_sdram_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_rj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_sj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_isi_dly[ac_bit+`DWC_PHY_BA_WIDTH]*(1.0 - 1.0/(1.0*nbits_bg[ac_bit])) - babg_dcd_dly[ac_bit+`DWC_PHY_BA_WIDTH]/2.0)  bg[ac_bit]; 
  always @(negedge bg[ac_bit])  bg_i[ac_bit]  <= #(babg_sdram_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_rj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_sj_dly[ac_bit+`DWC_PHY_BA_WIDTH] + babg_isi_dly[ac_bit+`DWC_PHY_BA_WIDTH]*(1.0 - 1.0/(1.0*nbits_bg[ac_bit])) + babg_dcd_dly[ac_bit+`DWC_PHY_BA_WIDTH]/2.0)  bg[ac_bit];   
end
`endif
`else
  for(ac_bit=0; ac_bit<`SDRAM_BANK_WIDTH; ac_bit=ac_bit+1) begin :  u_ba_dly_gen
  always@(ba[ac_bit])    nbits_ba[ac_bit]   =  ($realtime - t_ba[ac_bit]  < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_ba[ac_bit]   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;    
  always@(ba[ac_bit])    t_ba[ac_bit]       <= $realtime  ;   
  always @(posedge ba[ac_bit])  ba_i[ac_bit]  <= #(babg_sdram_dly[ac_bit] + babg_rj_dly[ac_bit] + babg_sj_dly[ac_bit] + babg_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_ba[ac_bit])) - babg_dcd_dly[ac_bit]/2.0)  ba[ac_bit]; 
  always @(negedge ba[ac_bit])  ba_i[ac_bit]  <= #(babg_sdram_dly[ac_bit] + babg_rj_dly[ac_bit] + babg_sj_dly[ac_bit] + babg_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_ba[ac_bit])) + babg_dcd_dly[ac_bit]/2.0)  ba[ac_bit]; 
end
`endif
`ifdef DDR4 
for(ac_bit=0; ac_bit<`DWC_CID_WIDTH; ac_bit=ac_bit+1) begin :  u_cid_dly_gen
  always@(cid[ac_bit])    nbits_cid[ac_bit]   =  ($realtime - t_cid[ac_bit]  < 0.75*(`CLK_PRD*1e3)) ? 1 : ($realtime - t_cid[ac_bit]   + 0.2*(`CLK_PRD*1e3)) / (`CLK_PRD*0.5e3) ;    
  always@(cid[ac_bit])    t_cid[ac_bit]       <= $realtime  ;   
  always @(posedge cid[ac_bit])  cid_i[ac_bit]  <= #(cid_sdram_dly[ac_bit] + cid_rj_dly[ac_bit] + cid_sj_dly[ac_bit] + cid_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_cid[ac_bit])) - cid_dcd_dly[ac_bit]/2.0)  cid[ac_bit]; 
  always @(negedge cid[ac_bit])  cid_i[ac_bit]  <= #(cid_sdram_dly[ac_bit] + cid_rj_dly[ac_bit] + cid_sj_dly[ac_bit] + cid_isi_dly[ac_bit]*(1.0 - 1.0/(1.0*nbits_cid[ac_bit])) + cid_dcd_dly[ac_bit]/2.0)  cid[ac_bit]; 
end
`endif
endgenerate
`ifdef LRDIMM_MULTI_RANK
    // detect a read command
    assign read_cmd = !cs_n & act_n & a[16] & !a[15] & a[14];
    // detect a write command
    assign write_cmd = !cs_n & act_n & a[16] & !a[15] & !a[14];
     
    // set read_path_on signal high for duration of read
    // read_path_on is asserted for the following
    // read preamble training
    // mpr mode
    always @(posedge ck or negedge rst_n) begin
      if (!rst_n) begin
        read_path_on <= 1'b0;
      end
      else begin
        if (rd_prmbl_train_on) begin
          read_path_on <= 1'b1;
        end
        else if (rd_prmbl_train_off) begin
          read_path_on <= 1'b0;
        end
        else if (mpr_on) begin
          read_path_on <= 1'b1;
        end
        else if (mpr_off) begin
          read_path_on <= 1'b0;
        end
      end  
    end

    
    // set read_en from WL-2 to WL+1 when a read command is detected

   always @(posedge ck or negedge rst_n) begin: read_en_PROC
     integer rd_idx;
      if (!rst_n) begin
        for (rd_idx = 0; rd_idx < pRL_WIDTH ; rd_idx = rd_idx + 1) begin
          read_en[rd_idx] <= 1'b0;
        end
      end  
      else begin
        for (rd_idx = pRL_WIDTH-2; rd_idx >= 0; rd_idx = rd_idx - 1) begin
          if (read_cmd) begin
            if ((rd_idx > (read_latency -2)) && rd_idx < (read_latency + bl/2 + 1 + write_cycle_suffix)) begin
              read_en[rd_idx] <= 1'b1;
            end
            else begin
              read_en[rd_idx] <= read_en[rd_idx + 1];
            end
          end
          else begin
            read_en[rd_idx] <= read_en[rd_idx + 1];
          end
        end
      end
    end  

    // combine read_path_on and read_en to create read_detect for all read
    // conditions

    assign read_detect = read_path_on | read_en[0];
    
    // if in MWD training or WLA Training write data may be a few cycles
    // earlier than WL so enable write path earlier
    `ifndef VMM_VERIF
      assign write_cycle_prefix = (mwd_train)? 4'h2: (`PUB.wl2_mode)? 4'h4:4'h1;
    `else
      assign write_cycle_prefix = (mwd_train)? 4'h2: (`PHY_PUB.wl2_mode)? 4'h4:4'h1;
    `endif
    assign write_cycle_suffix = (mwd_train)? 4'h2: 4'h0;
    // set write_en from WL-2 to WL+1

   // set write_en when a write command is detected
   // write_en is asserted a few cycles early when in MWD or WLA training
   always @(posedge ck or negedge rst_n) begin: write_en_PROC
     integer wr_idx;
      if (!rst_n) begin
        for (wr_idx = 0; wr_idx < pWL_WIDTH ; wr_idx = wr_idx + 1) begin
          write_en[wr_idx]    <= 1'b0;
          write_en_dq[wr_idx] <= 1'b0;
        end
      end  
      else begin
        for (wr_idx = pWL_WIDTH-2; wr_idx >= 0; wr_idx = wr_idx - 1) begin
          if (write_cmd) begin
            if ((wr_idx > (write_latency -(write_cycle_prefix + 1))) && wr_idx < (write_latency + (bl/2) +1 + write_cycle_suffix)) begin
              write_en[wr_idx]    <= 1'b1;
              write_en_dq[wr_idx] <= 1'b1;
            end
            else if ((wr_idx > (write_latency -(write_cycle_prefix+1))) && wr_idx < (write_latency + (bl/2) +1 + write_cycle_suffix)) begin
              write_en[wr_idx]    <= 1'b1;
              write_en_dq[wr_idx] <= 1'b0;
            end
            else begin
              write_en[wr_idx] <= write_en[wr_idx + 1];
              write_en_dq[wr_idx] <= write_en_dq[wr_idx + 1];
            end
          end
          else if (pda_off && ~pda_off_reg) begin
            if ((wr_idx > (write_latency)) && (wr_idx < (write_latency + (bl/2) +1))) begin
              write_en[wr_idx] <= 1'b1;
              write_en_dq[wr_idx] <= 1'b1;
            end
            else if ((wr_idx > (write_latency -2)) && (wr_idx < (write_latency + (bl/2) +1))) begin
              write_en[wr_idx] <= 1'b1;
              write_en_dq[wr_idx] <= 1'b0;
            end
            else begin
              write_en[wr_idx] <= write_en[wr_idx + 1];
              write_en_dq[wr_idx] <= write_en_dq[wr_idx + 1];
            end
          end
          else begin
            write_en[wr_idx] <= write_en[wr_idx + 1];
            write_en_dq[wr_idx] <= write_en_dq[wr_idx + 1];
          end
        end
      end
    end  
             
    
    // set write_path_on signal high for duration of write
    // write_path_on is asserted for the following
    // write leveling
    always @(posedge ck or negedge rst_n) begin
      if (!rst_n) begin
        write_path_on <= 1'b0;
        write_detect_wl <= 1'b0;
      end
      else begin
        if (wl_on) begin
          write_path_on <= 1'b1;
          write_detect_wl <= 1'b1;
        end
        else if (wl_off) begin
          write_path_on <= 1'b0;
          write_detect_wl <= 1'b0;
        end          
      end  
    end
     // combine write_path_on and write_en to create write_detect for all write
    // conditions

    assign write_detect = write_path_on | write_en[0];

    // for dq path, write_detect is not enabled during Write leveling
    assign write_detect_dq = (write_path_on | write_en_dq[0]) & ~write_detect_wl;
   
    // detect MRS command
    assign mrs_cmd  = !cs_n_i & act_n_i & !a_i[16] & !a_i[15] & !a_i[14];

    always @(posedge ck_i or negedge rst_n) begin
      if (!rst_n) begin
        bl <= 4'd8;
        cl <= 9;
        al_i <= 0;
        pl <= 0;
        wl_on <= 1'b0;
        wl_off <= 1'b0;
        rd_prmbl_train_on  <= 1'b0; 
        rd_prmbl_train_off <= 1'b0;  
        mpr_on <= 1'b0;
        mpr_off <= 1'b0;
        mrep_train <=1'b0; 
        dwl_train  <=1'b0; 
        hwl_train  <=1'b0; 
        mrd_train  <=1'b0; 
     end
      else begin
        if (mrs_cmd) begin
          if (bg_i[0] == 1'b0 && ba_i == 2'b00) begin  // MR0 set
            if (a_i[1:0] == 2'b00) begin // Read BL setting.
              bl <= 4'd8;
            end
            else if(a_i[1:0] == 2'b01) begin // tbd BL on the fly needs special care
              bl <= 4'd8;
            end
            else begin
              bl <= 4'd4;
            end  
            case ({a_i[12],a_i[6:4],a_i[2]} ) // Read CL setting
              5'd0: cl <= 9;
              5'd1: cl <= 10;
              5'd2: cl <= 11;
              5'd3: cl <= 12;
              5'd4: cl <= 13;
              5'd5: cl <= 14;
              5'd6: cl <= 15;
              5'd7: cl <= 16;
              5'd8: cl <= 18;
              5'd9: cl <= 20;
              5'd10: cl <= 22;
              5'd11: cl <= 24;
              5'd12: cl <= 23;
              5'd13: cl <= 17;
              5'd14: cl <= 19;
              5'd15: cl <= 21;
              5'd16: cl <= 25;
              5'd17: cl <= 26;
              5'd18: cl <= 27;
              5'd19: cl <= 28;
              5'd20: cl <= 29;
              5'd21: cl <= 30;
              5'd22: cl <= 31;
              5'd23: cl <= 32;
              default : cl <= 9;
            endcase
          end
          else if (bg_i[0] == 1'b0 && ba_i == 2'b01) begin  // MR1 set
            al_i <= a_i[4:3]; // read AL setting
            wl_on <= a_i[7];  // turn on write leveling
            wl_off <= ~a_i[7]; // turn off write leveling
          end
          else if (bg_i[0] == 1'b0 && ba_i == 2'b10) begin  // MR2 set
            case (a_i[5:3])
              3'b000: cwl <= 9;
              3'b001: cwl <= 10;
              3'b010: cwl <= 11;
              3'b011: cwl <= 12;
              3'b100: cwl <= 14;
              3'b101: cwl <= 16;
              3'b110: cwl <= 18;
              3'b111: cwl <= 20;
            endcase
          end
          else if (bg_i[0] == 1'b0 && ba_i == 2'b11) begin  // M3 set
            mpr_on  <= a_i[2];  // turn on mpr mode
            mpr_off <= ~a_i[2];  // turn off mpr_mode
            pda_on  <= a_i[4];   // turn on pda mode
            pda_off <= ~a_i[4];  // pda mode off
          end
          else if (bg_i[0] == 1'b1 && ba_i == 2'b00) begin  // M4 set
            rd_prmbl_train_on  <= a_i[10];  // turn on read preamble training
            rd_prmbl_train_off <= ~a_i[10];  // turn off read preamble training
          end
          else if (bg_i[0] == 1'b1 && ba_i == 2'b01) begin  // MR5 set
            case (a_i[2:0])
              3'b000: pl <= 0;
              3'b001: pl <= 4;
              3'b010: pl <= 5;
              3'b011: pl <= 6;
              3'b100: pl <= 8;
              3'b101: pl <= 0;
              3'b110: pl <= 0;
              3'b111: pl <= 0;
            endcase
          end
          else if (bg_i[0] == 1'b1 && ba_i == 2'b11) begin  // MR7 set
            if (a_i[12] == 1'b1) begin // BCW write
              if (a_i[11:4] == 8'h0C) begin // BC0C Training control word
                mrep_train <= (a_i[3:0] == 4'b0001)? 1'b1: 1'b0;
                dwl_train  <= (a_i[3:0] == 4'b0100)? 1'b1: 1'b0;
                hwl_train  <= (a_i[3:0] == 4'b0101)? 1'b1: 1'b0;
                mrd_train  <= (a_i[3:0] == 4'b0110)? 1'b1: 1'b0;
              end
            end
          end  
          else begin
            wl_on <= 1'b0;
            wl_off <= 1'b0;
            rd_prmbl_train_on  <= 1'b0; 
            rd_prmbl_train_off <= 1'b0;  
            mpr_on <= 1'b0;
            mpr_off <= 1'b0;
          end
        end
        else begin
          wl_on <= 1'b0;
          wl_off <= 1'b0;
          rd_prmbl_train_on  <= 1'b0; 
          rd_prmbl_train_off <= 1'b0;  
          mpr_on <= 1'b0;
          mpr_off <= 1'b0;
        end
      end  
    end  
    always@(*) begin
      case (al_i) // read AL setting
        2'b00: al <= 0;
        2'b01: al <= cl -1;
        2'b10: al <= cl-2;
        2'b11: al <= 0;
      endcase
    end  
    
    assign read_latency    = cl + al + pl ; //- rdimm_cmd_latency;
    assign write_latency   = (pub_wl_en)? pub_wl : cwl + al + pl; // - rdimm_cmd_latency;
    
    always @(posedge ck_i or negedge rst_n) begin
      if (!rst_n) begin
        pda_off_reg <= 1'b0;
      end
      else begin
        pda_off_reg <= pda_off;
      end
    end  
    
    `ifndef VMM_VERIF
      assign pub_wl_en = `PUB.u_DWC_ddrphy_init.pub_wl_en;
      assign pub_wl    = `PUB.u_DWC_ddrphy_init.pub_wl;
      assign pub_rl_en = `PUB.u_DWC_ddrphy_init.pub_rl_en;
      assign pub_rl    = `PUB.u_DWC_ddrphy_init.pub_rl;
      assign rdimm_cmd_latency = `PUB.u_DWC_ddrphy_init.rdimm_cmd_lat;
    `else
      assign pub_wl_en = `PHY_PUB.u_DWC_ddrphy_init.pub_wl_en;
      assign pub_wl    = `PHY_PUB.u_DWC_ddrphy_init.pub_wl; 
      assign pub_rl_en = `PHY_PUB.u_DWC_ddrphy_init.pub_rl_en;
      assign pub_rl    = `PHY_PUB.u_DWC_ddrphy_init.pub_rl;
      assign rdimm_cmd_latency = `PHY_PUB.u_DWC_ddrphy_init.rdimm_cmd_lat;
    `endif
    
  `endif
endmodule : ddr_board_delay_model
  
