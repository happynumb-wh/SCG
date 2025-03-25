//-----------------------------------------------------------------------------
//
// Copyright (c) 2011 Synopsys Incorporated.				   
// 									   
// This file contains confidential, proprietary information and trade	   
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written	   
// permission of Synopsys Incorporated. 				   
// 
// DESCRIPTION: DDR PHY shared AC configuration command interleaver
//-----------------------------------------------------------------------------
// This testbench module will map the dual MCTL channel DFI interfaces into the
// single DFI interface going into the shared-AC configured PUB.
// In shared AC mode, a 2- or 4-rank system will be split in two logical channels
// each comprising half of the ranks (i.e. cs_n  bits) and approximately half of
// the byte lanes. The interleaver aggregates the DFI interface signals from the
// 2 MCTLs according to the pINTERLEAVER_TYPE parameter:
//
// pINTERLEAVER_TYPE = 0 -> this will merely aggregate the byte-lane-dependent 
//   signals from the two channels, and AND/OR the main DFI control signals 
//   (e.g. reset_n). Signals such as bank, address, and ras/cas are taken exclusively
//   from channel 0. The use case of this approach is to emulate a single-channel
//   (non shared AC) topology with a shared-AC configured PUB
//
// pINTERLEAVER_TYPE = 1 -> this will take advantage of the odd/even command slots 
//   in a HDR configuration to aggregate the ODD slot control interface from one
//   channel (0) with the EVEN slot from the other channel (1). The two MCTLs must
//   be restricted to HDR mode and assigned to their respective command slot.
//   Data interfaces and byte-lane-dependent signals are still aggregated as in
//   pINTERLEAVER_TYPE = 0. The use case of this approach is an HDR system where
//   such an ODD/EVEN channel restriction is enforceable
//
// pINTERLEAVER_TYPE = 2 -> this will use a conflict arbiter to allow both channels
//   to be in SDR mode or use the ODD/EVEN commmand slots at will. *Not yet fully
//   verified*
//
//-----------------------------------------------------------------------------

module shrd_ac_intlvr (
    dfi_clk,
/********************* CHANNEL 0 ***************************/
    // DFI Control Interface
    ch0_dfi_reset_n,
    ch0_dfi_cke,
    ch0_dfi_odt,
    ch0_dfi_cs_n,
    ch0_dfi_cid,
    ch0_dfi_ras_n,
    ch0_dfi_cas_n,
    ch0_dfi_we_n,
    ch0_dfi_bank,
    ch0_dfi_address,
    ch0_dfi_act_n,
    ch0_dfi_bg,                       
    // DFI Write Data Interface   
    ch0_dfi_wrdata_en,
    ch0_dfi_wrdata,
    ch0_dfi_wrdata_mask,
    // DFI Read Data Interface           
    ch0_dfi_rddata_en,
    ch0_dfi_rddata_valid,
    ch0_dfi_rddata,
    // DFI Update Interface               
    ch0_dfi_ctrlupd_req,
    ch0_dfi_ctrlupd_ack,
    ch0_dfi_phyupd_req,
    ch0_dfi_phyupd_ack,
    ch0_dfi_phyupd_type,
    // DFI Status Interface                  
    ch0_dfi_init_start,
    ch0_dfi_data_byte_disable,   //Attention!
    ch0_dfi_dram_clk_disable,
    ch0_dfi_init_complete,
    ch0_dfi_parity_in, 
    ch0_dfi_alert_n, 
    // DFI Training Interface   
    ch0_dfi_phylvl_req_cs_n,
    ch0_dfi_phylvl_ack_cs_n,
    ch0_dfi_rdlvl_mode,
    ch0_dfi_rdlvl_gate_mode,
    ch0_dfi_wrlvl_mode,
    // Low Power Control Interface 
    ch0_dfi_lp_data_req,     
    ch0_dfi_lp_ctrl_req,
    ch0_dfi_lp_wakeup,  
    ch0_dfi_lp_ack,
/********************* CHANNEL 1 ***************************/
    // DFI Control Interface
    ch1_dfi_reset_n,
    ch1_dfi_cke,
    ch1_dfi_odt,
    ch1_dfi_cs_n,
    ch1_dfi_cid,
    ch1_dfi_ras_n,
    ch1_dfi_cas_n,
    ch1_dfi_we_n,
    ch1_dfi_bank,
    ch1_dfi_address,
    ch1_dfi_act_n,
    ch1_dfi_bg,                       
    // DFI Write Data Interface   
    ch1_dfi_wrdata_en,
    ch1_dfi_wrdata,
    ch1_dfi_wrdata_mask,
    // DFI Read Data Interface           
    ch1_dfi_rddata_en,
    ch1_dfi_rddata_valid,
    ch1_dfi_rddata,
    // DFI Update Interface               
    ch1_dfi_ctrlupd_req,
    ch1_dfi_ctrlupd_ack,
    ch1_dfi_phyupd_req,
    ch1_dfi_phyupd_ack,
    ch1_dfi_phyupd_type,
    // DFI Status Interface                  
    ch1_dfi_init_start,
    ch1_dfi_data_byte_disable,   //Attention!
    ch1_dfi_dram_clk_disable,
    ch1_dfi_init_complete,
    ch1_dfi_parity_in, 
    ch1_dfi_alert_n, 
    // DFI Training Interface   
    ch1_dfi_phylvl_req_cs_n,
    ch1_dfi_phylvl_ack_cs_n,
    ch1_dfi_rdlvl_mode,
    ch1_dfi_rdlvl_gate_mode,
    ch1_dfi_wrlvl_mode,
    // Low Power Control Interface 
    ch1_dfi_lp_data_req,     
    ch1_dfi_lp_ctrl_req,     
    ch1_dfi_lp_wakeup,  
    ch1_dfi_lp_ack,
/********************* INTO PUB ***************************/
    // DFI Control Interface
    dfi_reset_n,
    dfi_cke,
    dfi_odt,
    dfi_cs_n,
    dfi_cid,
    dfi_ras_n,
    dfi_cas_n,
    dfi_we_n,
    dfi_bank,
    dfi_address,
    dfi_act_n,
    dfi_bg,
    // DFI Write Data Interface   
    dfi_wrdata_en,
    dfi_wrdata,
    dfi_wrdata_mask,
    // DFI Read Data Interface           
    dfi_rddata_en,
    dfi_rddata_valid,
    dfi_rddata,
    // DFI Update Interface               
    dfi_ctrlupd_req,
    dfi_ctrlupd_ack,
    dfi_phyupd_req,
    dfi_phyupd_ack,
    dfi_phyupd_type,
    // DFI Status Interface                  
    dfi_init_start,
    dfi_data_byte_disable,   //Attention!
    dfi_dram_clk_disable,
    dfi_init_complete,
    dfi_parity_in, 
    dfi_alert_n, 
    // DFI Training Interface   
    dfi_phylvl_req_cs_n,
    dfi_phylvl_ack_cs_n,
    dfi_rdlvl_mode,
    dfi_rdlvl_gate_mode,
    dfi_wrlvl_mode,
    // Low Power Control Interface         
    dfi_lp_data_req,     
    dfi_lp_ctrl_req,     
    dfi_lp_wakeup,  
    dfi_lp_ack
);

    // PUB-DFI Interface Configuration
    parameter pNO_OF_BYTES       = 2;     // numner of DATX8's
    parameter pNO_OF_RANKS       = 4;     // number of ranks
    parameter pCID_WIDTH         = `DWC_CID_WIDTH;     // width of CID pins
    parameter pCK_WIDTH          = 3;     // number of CK pairs
    parameter pBANK_WIDTH        = 3;     // DRAM bank width
    parameter pADDR_WIDTH        = 16;    // DRAM address width
    parameter pACT_N_WIDTH       = 1;    // DRAM address width
    parameter pBG_WIDTH          = 2;    // DRAM address width
    parameter pRST_WIDTH         = 1;     // DRAM reset width
    parameter pHDR_MODE_EN       = 1;     // 2:1, 4:1, or both (SDR/HDR) modes on CTL-DFI
    parameter pNO_OF_BEATS       = 4;  // Num data beats per cycle
    parameter pNO_OF_DX_DQS      = `DWC_DX_NO_OF_DQS; // number of DQS signals per DX macro
    parameter pNUM_LANES         = pNO_OF_DX_DQS * pNO_OF_BYTES;
   // Memory Controller-DFI Interface Configuration
    parameter pMEMCTL_NO_OF_BEATS      = (pHDR_MODE_EN == 0) ? 2 : pNO_OF_BEATS ;  // Num data beats per cycle
    parameter pMEMCTL_NO_OF_CMDS       = (pHDR_MODE_EN == 0) ? 1 : 2 ;  // Num commands per cycle
    parameter pMEMCTL_RESET_WIDTH      = (pMEMCTL_NO_OF_CMDS * pRST_WIDTH);
    parameter pMEMCTL_CKE_WIDTH        = (pMEMCTL_NO_OF_CMDS * pNO_OF_RANKS);
    parameter pMEMCTL_ODT_WIDTH        = (pMEMCTL_NO_OF_CMDS * pNO_OF_RANKS);
    parameter pMEMCTL_CS_N_WIDTH       = (pMEMCTL_NO_OF_CMDS * pNO_OF_RANKS);
    parameter pMEMCTL_CID_WIDTH        = (pMEMCTL_NO_OF_CMDS * pCID_WIDTH);
    parameter pMEMCTL_RAS_N_WIDTH      = (pMEMCTL_NO_OF_CMDS * 1);
    parameter pMEMCTL_CAS_N_WIDTH      = (pMEMCTL_NO_OF_CMDS * 1);
    parameter pMEMCTL_WE_N_WIDTH       = (pMEMCTL_NO_OF_CMDS * 1);
    parameter pMEMCTL_ADDR_WIDTH       = (pMEMCTL_NO_OF_CMDS * pADDR_WIDTH);
    parameter pMEMCTL_BANK_WIDTH       = (pMEMCTL_NO_OF_CMDS * pBANK_WIDTH);
    parameter pMEMCTL_ACT_N_WIDTH      = (pMEMCTL_NO_OF_CMDS * pACT_N_WIDTH);
    parameter pMEMCTL_BG_WIDTH         = (pMEMCTL_NO_OF_CMDS * pBG_WIDTH);
    parameter pMEMCTL_MASK_WIDTH       = (pNUM_LANES * pMEMCTL_NO_OF_BEATS);
    parameter pMEMCTL_DATA_WIDTH       = (pNO_OF_BYTES * pMEMCTL_NO_OF_BEATS * 8);
    parameter pMEMCTL_WRDATA_EN_WIDTH  = (pMEMCTL_NO_OF_CMDS * pNUM_LANES);
    parameter pMEMCTL_RDDATA_EN_WIDTH  = (pMEMCTL_NO_OF_CMDS * pNUM_LANES);
    parameter pMEMCTL_PARITY_IN_WIDTH  = (pMEMCTL_NO_OF_CMDS * 1);
    parameter pMEMCTL_ALERT_N_WIDTH    = (pMEMCTL_NO_OF_CMDS * 1);
    
    localparam  pCHN0_DX8_NUM         = pNO_OF_BYTES/2  - (pNO_OF_BYTES % 2)/2 
             ,  pCHN1_DX8_NUM         = (pNO_OF_BYTES - pCHN0_DX8_NUM)
             ,  pCHN0_NUM_LANES       = (pCHN0_DX8_NUM * pNO_OF_DX_DQS) 
             ,  pCHN1_NUM_LANES       = (pCHN1_DX8_NUM * pNO_OF_DX_DQS) 
             ,  pCH0_MASK_WIDTH       = (pCHN0_NUM_LANES * pMEMCTL_NO_OF_BEATS)
             ,  pCH0_DATA_WIDTH       = (pCHN0_DX8_NUM * pMEMCTL_NO_OF_BEATS * 8)
             ,  pCH0_WRDATA_EN_WIDTH  = (pMEMCTL_NO_OF_CMDS * pCHN0_NUM_LANES)
             ,  pCH0_RDDATA_EN_WIDTH  = (pMEMCTL_NO_OF_CMDS * pCHN0_NUM_LANES)
             ,  pCH1_MASK_WIDTH       = (pCHN1_NUM_LANES * pMEMCTL_NO_OF_BEATS)
             ,  pCH1_DATA_WIDTH       = (pCHN1_DX8_NUM * pMEMCTL_NO_OF_BEATS * 8)
             ,  pCH1_WRDATA_EN_WIDTH  = (pMEMCTL_NO_OF_CMDS * pCHN1_NUM_LANES)
             ,  pCH1_RDDATA_EN_WIDTH  = (pMEMCTL_NO_OF_CMDS * pCHN1_NUM_LANES)  ;

    parameter     pINTERLEAVER_TYPE          =           1    ;
    //  Interleave modes are as follows:
    // 0 -> no interleaving (channel 0 for A/C bus, aggregated read and write data). Use this for a shared AC topology connected to emulate a single logical channel.
    // 1 -> [default] interleaving ODD slot from ch0 with EVEN slot from ch1. Use this if ODD/EVEN commands can be restricted to different logical channels.
    // 2 -> full interleaving with conflict arbitration and command/data stacks

    parameter     pCOMM_STACK_DEPTH         =           10   ;
    parameter     pDATA_STACK_DEPTH         =           100  ;
    parameter     tPHY_WRLAT                =           4    ;  //???
    parameter     tPHY_RDLAT                =           4    ;  //???
    parameter     pCLK_WAIT_WINDOW          =           0.5  ;  // ns -> TRIAL
    
    parameter     pODD   = 0 ;
    parameter     pEVEN  = 1 ;
    parameter     pBOTH  = 2 ;

    input wire                                  dfi_clk ;
/********************* CHANNEL 0 ***************************/
    // DFI Control Interface
    input  wire [pMEMCTL_RESET_WIDTH      -1:0] ch0_dfi_reset_n;
    input  wire [pMEMCTL_CKE_WIDTH        -1:0] ch0_dfi_cke;
    input  wire [pMEMCTL_ODT_WIDTH        -1:0] ch0_dfi_odt;
    input  wire [pMEMCTL_CS_N_WIDTH       -1:0] ch0_dfi_cs_n;
    input  wire [pMEMCTL_CID_WIDTH        -1:0] ch0_dfi_cid;
    input  wire [pMEMCTL_RAS_N_WIDTH      -1:0] ch0_dfi_ras_n;
    input  wire [pMEMCTL_CAS_N_WIDTH      -1:0] ch0_dfi_cas_n;
    input  wire [pMEMCTL_WE_N_WIDTH       -1:0] ch0_dfi_we_n;
    input  wire [pMEMCTL_BANK_WIDTH       -1:0] ch0_dfi_bank;
    input  wire [pMEMCTL_ADDR_WIDTH       -1:0] ch0_dfi_address;
    input  wire [pMEMCTL_ACT_N_WIDTH      -1:0] ch0_dfi_act_n;
    input  wire [pMEMCTL_BG_WIDTH         -1:0] ch0_dfi_bg;
    // DFI Write Data Interface   
    input  wire [pCH0_WRDATA_EN_WIDTH  -1:0] ch0_dfi_wrdata_en;
    input  wire [pCH0_DATA_WIDTH       -1:0] ch0_dfi_wrdata;
    input  wire [pCH0_MASK_WIDTH       -1:0] ch0_dfi_wrdata_mask;
                                       
    // DFI Read Data Interface           
    input  wire [pCH0_RDDATA_EN_WIDTH  -1:0] ch0_dfi_rddata_en;
    output reg  [pCH0_RDDATA_EN_WIDTH  -1:0] ch0_dfi_rddata_valid;
    output reg  [pCH0_DATA_WIDTH       -1:0] ch0_dfi_rddata;

    // DFI Update Interface               
    input  wire                                 ch0_dfi_ctrlupd_req;
    output wire                                 ch0_dfi_ctrlupd_ack;
    output wire                                 ch0_dfi_phyupd_req;
    input  wire                                 ch0_dfi_phyupd_ack;
    output wire [1:0]                           ch0_dfi_phyupd_type;
                                             
    // DFI Status Interface                  
    input  wire                                 ch0_dfi_init_start;
    input  wire [pCHN0_DX8_NUM            -1:0] ch0_dfi_data_byte_disable;   //Attention!
    input  wire [pCK_WIDTH                -1:0] ch0_dfi_dram_clk_disable;
    output wire                                 ch0_dfi_init_complete;
    input  wire [pMEMCTL_PARITY_IN_WIDTH  -1:0] ch0_dfi_parity_in; 
    output wire [pMEMCTL_ALERT_N_WIDTH    -1:0] ch0_dfi_alert_n; 
                                
    // DFI Training Interface   
    `ifdef DWC_USE_SHARED_AC_TB  
      output wire [`CLK_NX*pNO_OF_RANKS/2    -1:0] ch0_dfi_phylvl_req_cs_n;
      input  wire [`CLK_NX*pNO_OF_RANKS/2    -1:0] ch0_dfi_phylvl_ack_cs_n;
    `else
      output wire [`CLK_NX*pNO_OF_RANKS      -1:0] ch0_dfi_phylvl_req_cs_n;
      input  wire [`CLK_NX*pNO_OF_RANKS      -1:0] ch0_dfi_phylvl_ack_cs_n;
    `endif
    output wire [1                   :0] ch0_dfi_rdlvl_mode;
    output wire [1                   :0] ch0_dfi_rdlvl_gate_mode;
    output wire [1                   :0] ch0_dfi_wrlvl_mode;
                                 
    // Low Power Control Interface 
    input  wire                           ch0_dfi_lp_data_req;     
    input  wire                           ch0_dfi_lp_ctrl_req;     
    input  wire [3                    :0] ch0_dfi_lp_wakeup;  
    output wire                           ch0_dfi_lp_ack;


/********************* CHANNEL 1 ***************************/
    // DFI Control Interface
    input  wire [pMEMCTL_RESET_WIDTH      -1:0] ch1_dfi_reset_n;
    input  wire [pMEMCTL_CKE_WIDTH        -1:0] ch1_dfi_cke;
    input  wire [pMEMCTL_ODT_WIDTH        -1:0] ch1_dfi_odt;
    input  wire [pMEMCTL_CS_N_WIDTH       -1:0] ch1_dfi_cs_n;
    input  wire [pMEMCTL_CID_WIDTH        -1:0] ch1_dfi_cid;
    input  wire [pMEMCTL_RAS_N_WIDTH      -1:0] ch1_dfi_ras_n;
    input  wire [pMEMCTL_CAS_N_WIDTH      -1:0] ch1_dfi_cas_n;
    input  wire [pMEMCTL_WE_N_WIDTH       -1:0] ch1_dfi_we_n;
    input  wire [pMEMCTL_BANK_WIDTH       -1:0] ch1_dfi_bank;
    input  wire [pMEMCTL_ADDR_WIDTH       -1:0] ch1_dfi_address;
    input  wire [pMEMCTL_ACT_N_WIDTH      -1:0] ch1_dfi_act_n;
    input  wire [pMEMCTL_BG_WIDTH         -1:0] ch1_dfi_bg;
   
    // DFI Write Data Interface   
    input  wire [pCH1_WRDATA_EN_WIDTH   -1:0] ch1_dfi_wrdata_en;
    input  wire [pCH1_DATA_WIDTH       -1:0] ch1_dfi_wrdata;
    input  wire [pCH1_MASK_WIDTH       -1:0] ch1_dfi_wrdata_mask;
                                       
    // DFI Read Data Interface           
    input  wire [pCH1_RDDATA_EN_WIDTH   -1:0] ch1_dfi_rddata_en;
    output reg  [pCH1_RDDATA_EN_WIDTH  -1:0] ch1_dfi_rddata_valid;
    output reg  [pCH1_DATA_WIDTH      -1:0] ch1_dfi_rddata;

    // DFI Update Interface               
    input  wire                                 ch1_dfi_ctrlupd_req;
    output wire                                 ch1_dfi_ctrlupd_ack;
    output wire                                 ch1_dfi_phyupd_req;
    input  wire                                 ch1_dfi_phyupd_ack;
    output wire [1:0]                           ch1_dfi_phyupd_type;
                                             
    // DFI Status Interface                  
    input  wire                                 ch1_dfi_init_start;
    input  wire [pCHN1_DX8_NUM            -1:0] ch1_dfi_data_byte_disable;   //Attention!
    input  wire [pCK_WIDTH                -1:0] ch1_dfi_dram_clk_disable;
    output wire                                 ch1_dfi_init_complete;
    input  wire [pMEMCTL_PARITY_IN_WIDTH  -1:0] ch1_dfi_parity_in; 
    output wire [pMEMCTL_ALERT_N_WIDTH    -1:0] ch1_dfi_alert_n; 
                                
    // DFI Training Interface 
    `ifdef DWC_USE_SHARED_AC_TB  
      output wire [`CLK_NX*pNO_OF_RANKS/2    -1:0] ch1_dfi_phylvl_req_cs_n;
      input  wire [`CLK_NX*pNO_OF_RANKS/2    -1:0] ch1_dfi_phylvl_ack_cs_n;
    `else
      output wire [`CLK_NX*pNO_OF_RANKS      -1:0] ch1_dfi_phylvl_req_cs_n;
      input  wire [`CLK_NX*pNO_OF_RANKS      -1:0] ch1_dfi_phylvl_ack_cs_n;
    `endif
    output wire [1                   :0] ch1_dfi_rdlvl_mode;
    output wire [1                   :0] ch1_dfi_rdlvl_gate_mode;
    output wire [1                   :0] ch1_dfi_wrlvl_mode;
                                 
    // Low Power Control Interface 
    input  wire                           ch1_dfi_lp_data_req;     
    input  wire                           ch1_dfi_lp_ctrl_req;     
    input  wire [3                    :0] ch1_dfi_lp_wakeup;  
    output wire                           ch1_dfi_lp_ack;


/********************* INTO PUB ***************************/
    // DFI Control Interface
    output  reg  [pMEMCTL_RESET_WIDTH      -1:0] dfi_reset_n;
    output  reg  [pMEMCTL_CKE_WIDTH        -1:0] dfi_cke;
    output  reg  [pMEMCTL_ODT_WIDTH        -1:0] dfi_odt;
    output  reg  [pMEMCTL_CS_N_WIDTH       -1:0] dfi_cs_n;
    output  reg  [pMEMCTL_CID_WIDTH        -1:0] dfi_cid;
    output  reg  [pMEMCTL_RAS_N_WIDTH      -1:0] dfi_ras_n;
    output  reg  [pMEMCTL_CAS_N_WIDTH      -1:0] dfi_cas_n;
    output  reg  [pMEMCTL_WE_N_WIDTH       -1:0] dfi_we_n;
    output  reg  [pMEMCTL_BANK_WIDTH       -1:0] dfi_bank;
    output  reg  [pMEMCTL_ADDR_WIDTH       -1:0] dfi_address;
    output  reg  [pMEMCTL_ACT_N_WIDTH      -1:0] dfi_act_n;
    output  reg  [pMEMCTL_BG_WIDTH         -1:0] dfi_bg;
    
    // DFI Write Data Interface   
    output  reg [pMEMCTL_WRDATA_EN_WIDTH  -1:0] dfi_wrdata_en;
    output  reg [pMEMCTL_DATA_WIDTH       -1:0] dfi_wrdata;
    output  reg [pMEMCTL_MASK_WIDTH       -1:0] dfi_wrdata_mask;
                                       
    // DFI Read Data Interface           
    output  reg [pMEMCTL_RDDATA_EN_WIDTH  -1:0] dfi_rddata_en;
    input  wire [pMEMCTL_RDDATA_EN_WIDTH  -1:0] dfi_rddata_valid;
    input  wire [pMEMCTL_DATA_WIDTH       -1:0] dfi_rddata;

    // DFI Update Interface               
    output wire [1:0]                           dfi_ctrlupd_req;
    input  wire [1:0]                           dfi_ctrlupd_ack;
    input  wire [1:0]                           dfi_phyupd_req;
    output wire [1:0]                           dfi_phyupd_ack;
    input  wire [3:0]                           dfi_phyupd_type;
                                             
    // DFI Status Interface                  
    output  wire                                 dfi_init_start;
    output  wire [pNO_OF_BYTES             -1:0] dfi_data_byte_disable;   //Attention!
    output  wire [pCK_WIDTH                -1:0] dfi_dram_clk_disable;
    input   wire                                 dfi_init_complete;
    output  reg  [pMEMCTL_PARITY_IN_WIDTH  -1:0] dfi_parity_in; 
    input   wire [pMEMCTL_ALERT_N_WIDTH    -1:0] dfi_alert_n; 
                                
    // DFI Training Interface   
    `ifdef DWC_USE_SHARED_AC_TB  
      output wire [`CLK_NX*pNO_OF_RANKS/2    -1:0] dfi_phylvl_req_cs_n;
      input  wire [`CLK_NX*pNO_OF_RANKS/2    -1:0] dfi_phylvl_ack_cs_n;
    `else
      output wire [`CLK_NX*pNO_OF_RANKS    -1:0] dfi_phylvl_req_cs_n;
      input  wire [`CLK_NX*pNO_OF_RANKS    -1:0] dfi_phylvl_ack_cs_n;
    `endif
    input wire [1                   :0] dfi_rdlvl_mode;
    input wire [1                   :0] dfi_rdlvl_gate_mode;
    input wire [1                   :0] dfi_wrlvl_mode;
                                 
    // Low Power Control Interface 
    output wire [1                  :0]  dfi_lp_data_req;     
    output wire [1                  :0]  dfi_lp_ctrl_req;     
    output wire [7                  :0]  dfi_lp_wakeup;  
    input  wire [1                  :0]  dfi_lp_ack ;

// variables    
    reg  [pMEMCTL_CKE_WIDTH        -1:0] mx_dfi_reset_n;
    reg  [pMEMCTL_CKE_WIDTH        -1:0] mx_dfi_cke;
    reg  [pMEMCTL_ODT_WIDTH        -1:0] mx_dfi_odt;
    reg  [pMEMCTL_CS_N_WIDTH       -1:0] mx_dfi_cs_n;
    reg  [pMEMCTL_CID_WIDTH        -1:0] mx_dfi_cid;
    reg  [pMEMCTL_RAS_N_WIDTH      -1:0] mx_dfi_ras_n;
    reg  [pMEMCTL_CAS_N_WIDTH      -1:0] mx_dfi_cas_n;
    reg  [pMEMCTL_WE_N_WIDTH       -1:0] mx_dfi_we_n;
    reg  [pMEMCTL_BANK_WIDTH       -1:0] mx_dfi_bank;
    reg  [pMEMCTL_ADDR_WIDTH       -1:0] mx_dfi_address;
    reg  [pMEMCTL_ACT_N_WIDTH      -1:0] mx_dfi_act_n;
    reg  [pMEMCTL_BG_WIDTH         -1:0] mx_dfi_bg;

    reg  [pMEMCTL_CS_N_WIDTH       -1:0] cs_n_ch0_mask;
    reg  [pMEMCTL_CS_N_WIDTH       -1:0] cs_n_ch1_mask;
    reg  [4                        -1:0] cs_n_even_r4_mask;
    reg  [4                        -1:0] cs_n_odd_r4_mask;

    integer   wrbeat, rdbeat ;
    reg  r_wrdata_stackisempty, r_readen_stackisempty  ;
    initial  r_wrdata_stackisempty  = 1'b1 ;  //stack starts empty / unused
    initial  r_readen_stackisempty  = 1'b1 ;
    
    wire  ch0_active_command_odd, ch1_active_command_odd ;
    wire  ch0_active_command_even, ch1_active_command_even ;
    wire  specialcase_odd, specialcase_even  ;
    wire  check_collision_odd, check_collision_even  ;
    //reg    ch0_active_command_latch, ch1_active_command_latch ;
                             
    reg     priority_toggle   ;
    initial priority_toggle = 1'b0 ;
    
    wire [pMEMCTL_CKE_WIDTH /*+ pMEMCTL_ODT_WIDTH */+ pMEMCTL_CS_N_WIDTH + pMEMCTL_CID_WIDTH + 
          pMEMCTL_RAS_N_WIDTH + pMEMCTL_CAS_N_WIDTH + pMEMCTL_WE_N_WIDTH +
          pMEMCTL_BANK_WIDTH + pMEMCTL_ADDR_WIDTH +
          pMEMCTL_ACT_N_WIDTH + pMEMCTL_BG_WIDTH -1:0]  command_stack_in_0, command_stack_in_1 ;
    reg  [pMEMCTL_CKE_WIDTH /*+ pMEMCTL_ODT_WIDTH */+ pMEMCTL_CS_N_WIDTH + pMEMCTL_CID_WIDTH + 
          pMEMCTL_RAS_N_WIDTH + pMEMCTL_CAS_N_WIDTH + pMEMCTL_WE_N_WIDTH +
          pMEMCTL_BANK_WIDTH + pMEMCTL_ADDR_WIDTH +
          pMEMCTL_ACT_N_WIDTH + pMEMCTL_BG_WIDTH -1 :0]  command_stack_out ;
    reg  [pMEMCTL_CKE_WIDTH /*+ pMEMCTL_ODT_WIDTH */+ pMEMCTL_CS_N_WIDTH + pMEMCTL_CID_WIDTH + 
          pMEMCTL_RAS_N_WIDTH + pMEMCTL_CAS_N_WIDTH + pMEMCTL_WE_N_WIDTH +
          pMEMCTL_BANK_WIDTH + pMEMCTL_ADDR_WIDTH +
          pMEMCTL_ACT_N_WIDTH + pMEMCTL_BG_WIDTH -1 :0]  command_stack [pCOMM_STACK_DEPTH-1:0] ;
    integer  cmd_stack_wrptr = 0;
    integer  cmd_stack_rdptr = 0;
    reg  stackisempty ;
    
    reg  [pMEMCTL_DATA_WIDTH -1:0]  dfi_data_stack_in ;
    reg  [pMEMCTL_MASK_WIDTH -1:0]  dfi_mask_stack_in ;
    reg  [pMEMCTL_WRDATA_EN_WIDTH -1:0]  dfi_en_stack_in ;
    reg  [pMEMCTL_ODT_WIDTH -1:0]   dfi_odt_stack_in  ;
    reg  [pMEMCTL_ODT_WIDTH + pMEMCTL_WRDATA_EN_WIDTH + pMEMCTL_DATA_WIDTH + pMEMCTL_MASK_WIDTH -1:0]  wrdata_stack_out ;
    reg  [pMEMCTL_ODT_WIDTH + pMEMCTL_WRDATA_EN_WIDTH + pMEMCTL_DATA_WIDTH + pMEMCTL_MASK_WIDTH -1:0]  wrdata_stack [pDATA_STACK_DEPTH-1:0] ;
    reg  [pMEMCTL_RDDATA_EN_WIDTH -1:0]  readen_stack_out ;
    reg  [pMEMCTL_RDDATA_EN_WIDTH -1:0]  readen_stack [pDATA_STACK_DEPTH-1:0] ;
    integer  wrd_stack_wrptr = 0;
    integer  wrd_stack_rdptr = 0;
    integer  rde_stack_wrptr = 0;
    integer  rde_stack_rdptr = 0;
    
    wire  ch0_read, ch0_write, ch1_read, ch1_write ;
    
    event  delayed_push_wrdata_stack_0, delayed_push_rdenable_stack_0 ;
    event  delayed_pop_wrdata_stack, delayed_pop_rdenable_stack ;
    event  delayed_push_wrdata_stack_1, delayed_push_rdenable_stack_1 ;
    //event  delayed_pop_wrdata_stack_1, delayed_pop_rdenable_stack_1 ; 
    
    integer   wrburstlength [pCOMM_STACK_DEPTH : 0] ;
    integer   wrburstptr = -1   ;

  
    integer   wrburstptr_out = -1   ;
    integer   readdatacntr   ;
    
    integer   rdburstlength [pCOMM_STACK_DEPTH : 0] ;
    integer   rdburstptr = -1   ;
    integer   rdburstptr_out = -1   ;
    integer   readencntr   ;
    
    reg     enable_ch0_wrdata_routing, enable_ch0_wren_routing ;
    reg     enable_ch1_wrdata_routing, enable_ch1_wren_routing ;
    reg     enable_ch0_readen_routing, enable_ch1_readen_routing ;
    initial begin
      enable_ch0_readen_routing  = 1'b0 ;
      enable_ch1_readen_routing  = 1'b0 ;
    end  
    
    reg  comm_stack_oddmask, comm_stack_evenmask  ;
    reg [pMEMCTL_CKE_WIDTH        -1:0] mch1_dfi_cke;
    //reg [pMEMCTL_ODT_WIDTH        -1:0] mch1_dfi_odt;
    reg [pMEMCTL_CID_WIDTH        -1:0] mch1_dfi_cid;
    reg [pMEMCTL_RAS_N_WIDTH      -1:0] mch1_dfi_ras_n;
    reg [pMEMCTL_CAS_N_WIDTH      -1:0] mch1_dfi_cas_n;
    reg [pMEMCTL_WE_N_WIDTH       -1:0] mch1_dfi_we_n;
    reg [pMEMCTL_CKE_WIDTH        -1:0] mch0_dfi_cke;
    //reg [pMEMCTL_ODT_WIDTH        -1:0] mch0_dfi_odt;
    reg [pMEMCTL_CID_WIDTH        -1:0] mch0_dfi_cid;
    reg [pMEMCTL_RAS_N_WIDTH      -1:0] mch0_dfi_ras_n;
    reg [pMEMCTL_CAS_N_WIDTH      -1:0] mch0_dfi_cas_n;
    reg [pMEMCTL_WE_N_WIDTH       -1:0] mch0_dfi_we_n;
    
    wire    specialcase_type1  ;
        
//*****************************        
// assigns
//*****************************
    assign  dfi_lp_data_req        = {ch1_dfi_lp_data_req, ch0_dfi_lp_data_req} ;
    assign  dfi_lp_ctrl_req        = {ch1_dfi_lp_ctrl_req, ch0_dfi_lp_ctrl_req} ;
    assign  dfi_lp_wakeup     = {ch1_dfi_lp_wakeup, ch0_dfi_lp_wakeup} ;
    assign  ch0_dfi_lp_ack    = dfi_lp_ack[0] ;   
    assign  ch1_dfi_lp_ack    = dfi_lp_ack[1] ;
    
    assign  ch0_dfi_phylvl_req_cs_n     = dfi_phylvl_req_cs_n ;
    assign  dfi_phylvl_ack_cs_n         = ch0_dfi_phylvl_ack_cs_n | ch1_dfi_phylvl_ack_cs_n ;
    assign  ch0_dfi_rdlvl_mode          = dfi_rdlvl_mode      ;
    assign  ch0_dfi_rdlvl_gate_mode     = dfi_rdlvl_gate_mode ;
    assign  ch0_dfi_wrlvl_mode          = dfi_wrlvl_mode      ;
    assign  ch1_dfi_phylvl_req_cs_n     = dfi_phylvl_req_cs_n ;
    assign  ch1_dfi_rdlvl_mode          = dfi_rdlvl_mode      ;
    assign  ch1_dfi_rdlvl_gate_mode     = dfi_rdlvl_gate_mode ;
    assign  ch1_dfi_wrlvl_mode          = dfi_wrlvl_mode      ;
    
    assign dfi_init_start               = ch0_dfi_init_start | ch1_dfi_init_start ;
    assign dfi_data_byte_disable        = {ch1_dfi_data_byte_disable, ch0_dfi_data_byte_disable};
    assign dfi_dram_clk_disable         = ch0_dfi_dram_clk_disable | ch1_dfi_dram_clk_disable ;
    assign ch0_dfi_init_complete        = dfi_init_complete   ;
    assign ch1_dfi_init_complete        = dfi_init_complete   ;
    assign ch0_dfi_alert_n              = dfi_alert_n    ;
    assign ch1_dfi_alert_n              = dfi_alert_n    ;
    
    assign dfi_ctrlupd_req              = {ch1_dfi_ctrlupd_req, ch0_dfi_ctrlupd_req} ;
    assign ch0_dfi_ctrlupd_ack          = dfi_ctrlupd_ack[0] ;
    assign ch0_dfi_phyupd_req           = dfi_phyupd_req[0]  ;
    assign ch1_dfi_ctrlupd_ack          = dfi_ctrlupd_ack[1] ;
    assign ch1_dfi_phyupd_req           = dfi_phyupd_req[1]  ;    
    assign dfi_phyupd_ack               = {ch1_dfi_phyupd_ack, ch0_dfi_phyupd_ack} ;
    assign ch0_dfi_phyupd_type          = dfi_phyupd_type[1:0] ; 
    assign ch1_dfi_phyupd_type          = dfi_phyupd_type[3:2] ;
    
    /*assign dfi_reset_n                  = ch0_dfi_reset_n & ch1_dfi_reset_n ;
    assign dfi_cke                      = ch0_dfi_cke | ch1_dfi_cke ;
    assign dfi_odt                      = ch0_dfi_odt | ch1_dfi_odt ;
    assign dfi_cs_n                     = ch0_dfi_cs_n & ch1_dfi_cs_n  ;
    assign dfi_ras_n                    = ch0_dfi_ras_n & ch1_dfi_ras_n ;
    assign dfi_cas_n                    = ch0_dfi_cas_n & ch1_dfi_cas_n ;
    assign dfi_we_n                     = ch0_dfi_we_n & ch1_dfi_we_n ;
    assign dfi_bank                     = ch0_dfi_bank & ch1_dfi_bank ; //doesn't matter and/or
    assign dfi_address                  = ch0_dfi_address | ch1_dfi_address ; //doesn't matter and/or*/ 
    
    //assign   stackisempty = (cmd_stack_wrptr == cmd_stack_rdptr) ? 1'b1 : 1'b0 ;
    initial stackisempty = 1'b1 ;
   
    // Set the mch1 buses, both odd and even, integrating the comm_stack_{odd,even}mask's.
    // Setting following buses:
    //   - mch1_dfi_{cke,ras_n,cas_n,we_n} | oddmask
    //   - mch0_dfi_{cke,ras_n,cas_n,we_n} | oddmask
    //   - mch1_dfi_{cke,ras_n,cas_n,we_n} | evenmask
    //   - mch0_dfi_{cke,ras_n,cas_n,we_n} | evenmask
    always@(*) begin
      // Set the MCTL1 (mch1) lower bit control signals, applying the ODD mask.
      mch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      // mch1_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] & {pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS{!comm_stack_oddmask}};
      mch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      mch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      mch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};

      // Set the MCTL0 (mch0) lower bit control signals, applying the ODD mask.
      mch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      // mch0_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] & {pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS{!comm_stack_oddmask}};
      mch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      mch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      mch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_oddmask}};
      

      // Set the MCTL1 (mch1) upper bit control signals, applying the EVEN mask
      mch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
      // mch1_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] & {pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS{!comm_stack_evenmask}};
      mch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
      mch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
      mch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};

      // Set the MCTL1 (mch1) upper bit control signals, applying the EVEN mask
      mch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
      // mch0_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] & {pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS{!comm_stack_evenmask}};
      mch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
      mch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
      mch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] = ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] | {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{comm_stack_evenmask}};
    end
      
    assign   command_stack_in_1  =  {mch1_dfi_cke, /*mch1_dfi_odt, */ch1_dfi_cs_n, ch1_dfi_cid, 
                                     mch1_dfi_ras_n, mch1_dfi_cas_n, mch1_dfi_we_n,
                                     ch1_dfi_bank, ch1_dfi_address } ;
    assign   command_stack_in_0  =  {mch0_dfi_cke, /*mch0_dfi_odt, */ch0_dfi_cs_n, mch0_dfi_cid,
                                     mch0_dfi_ras_n, mch0_dfi_cas_n, mch0_dfi_we_n,
                                     ch0_dfi_bank, ch0_dfi_address } ;                                   
                                     
    always@(*)
      command_stack_out = command_stack[cmd_stack_rdptr] ;
    
    assign ch0_active_command_odd  = ( (ch0_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
                                     ( (ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) ||
                                       (ch0_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) ) )
                                  || ( (ch0_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  === {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
                                       (ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) )   ; 
                                       //exclude NOP and deselect
                                       
    assign ch1_active_command_odd  = ( (ch1_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
                                     ( (ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch1_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
                                       (ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) ) )
                                  || ( (ch1_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  === {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
                                       (ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) )   ; 
                                       //exclude NOP and deselect
    
    assign ch0_active_command_even = 
        ( (ch0_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1 -: pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
        ( (ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1 -: pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1 -: pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1 -: pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch0_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1 -: pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1 -: pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) ) )
     || ( (ch0_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1 -: pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  === {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
          (ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1 -: pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) )   ;
                                       
    assign ch1_active_command_even =
        ( (ch1_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1 -: pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
        ( (ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1 -: pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1 -: pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] !== {pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1 -: pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch1_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1 -: pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]  !== {pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) || 
          (ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1 -: pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) ) )
     || ( (ch1_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1 -: pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]  === {pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) &&
          (ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1 -: pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   !== {pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS{1'b1}}) )   ;
                                    
    //special situation where both channels request same op to same address at same time (can be served)                                
    assign specialcase_odd  = ((ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] === ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) && 
                               (ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] === ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) && 
                               (ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]   === ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]  ) && 
                               (ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]     === ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]    ) && 
                               (ch1_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     === ch0_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]    ) && 
                               (ch1_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]   === ch0_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]  ) && 
                               (ch1_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]=== ch0_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]));
                                                               
    assign specialcase_even = ((ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] === ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) && 
                               (ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] === ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) && 
                               (ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]   === ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]  ) && 
                               (ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]     === ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]    ) && 
                               (ch1_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     === ch0_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]    ) && 
                               (ch1_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]   === ch0_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]  ) && 
                               (ch1_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]=== ch0_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]));
/*                          
`ifdef DWC_DDRPHY_HDR_MODE
  `ifdef MSD_HDR_ODD_CMD    
    assign specialcase_type1 = (&ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2]) && (&ch1_dfi_ras_n[0 +:pMEMCTL_RAS_N_WIDTH/2]) &&
                               (&ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2]) && (&ch1_dfi_cas_n[0 +:pMEMCTL_CAS_N_WIDTH/2]) &&
                               (&ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2]) && (&ch1_dfi_we_n[0 +:pMEMCTL_WE_N_WIDTH/2]) &&
                               (&ch0_dfi_cke) && (&ch1_dfi_cke) ;
  `else                                                        
    assign specialcase_type1 = (&ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2]) && (&ch0_dfi_ras_n[0 +:pMEMCTL_RAS_N_WIDTH/2]) &&
                               (&ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2]) && (&ch0_dfi_cas_n[0 +:pMEMCTL_CAS_N_WIDTH/2]) &&
                               (&ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2]) && (&ch0_dfi_we_n[0 +:pMEMCTL_WE_N_WIDTH/2]) &&
                               (&ch0_dfi_cke) && (&ch1_dfi_cke) ;
  `endif
`else*/
    assign specialcase_type1 = 1'b0 ;
//`endif
                             
    assign check_collision_odd  = ch0_active_command_odd  && ch1_active_command_odd  && (!specialcase_odd)  ;
    assign check_collision_even = ch0_active_command_even && ch1_active_command_even && (!specialcase_even) ;                         
                             
    assign ch0_read_odd   = ch0_active_command_odd && |( ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] ) ;
    assign ch0_write_odd  = ch0_active_command_odd && |( ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & (~ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]) ) ;
    assign ch1_read_odd   = ch1_active_command_odd && |( ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] ) ;
    assign ch1_write_odd  = ch1_active_command_odd && |( ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & (~ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]) ) ;
    
    assign ch0_read_even  = ch0_active_command_even && |( ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] ) ;
    assign ch0_write_even = ch0_active_command_even && |( ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & (~ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]) ) ;
    assign ch1_read_even  = ch1_active_command_even && |( ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS] ) ;
    assign ch1_write_even = ch1_active_command_even && |( ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & (~ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]) & (~ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]) ) ;
    
                                             
//*******************************
// muxed DFI interface    
//*******************************
    always@(*) begin
       for (wrbeat=0;wrbeat < pMEMCTL_NO_OF_BEATS;wrbeat = wrbeat + 1) begin
         if (!enable_ch0_wrdata_routing)
           dfi_data_stack_in[pNO_OF_BYTES*8*wrbeat +: pCHN0_DX8_NUM*8] = ch0_dfi_wrdata[pCHN0_DX8_NUM*8*wrbeat +:pCHN0_DX8_NUM*8] ;
         else dfi_data_stack_in[pNO_OF_BYTES*8*wrbeat +: pCHN0_DX8_NUM*8] = {pCHN0_DX8_NUM*8{1'b0}} ;
         if (!enable_ch1_wrdata_routing)
           dfi_data_stack_in[pNO_OF_BYTES*8*wrbeat + pCHN0_DX8_NUM*8 +: pCHN1_DX8_NUM*8] = ch1_dfi_wrdata[pCHN1_DX8_NUM*8*wrbeat +:pCHN1_DX8_NUM*8] ;
         else  dfi_data_stack_in[pNO_OF_BYTES*8*wrbeat + pCHN0_DX8_NUM*8 +: pCHN1_DX8_NUM*8] = {pCHN1_DX8_NUM*8{1'b0}} ;
         
         if (!enable_ch0_wrdata_routing)
           dfi_mask_stack_in[pNUM_LANES*wrbeat +: pCHN0_NUM_LANES] = ch0_dfi_wrdata_mask[pCHN0_NUM_LANES*wrbeat +:pCHN0_NUM_LANES] ;
         else  dfi_mask_stack_in[pNUM_LANES*wrbeat +: pCHN0_NUM_LANES] = {pCHN0_NUM_LANES{1'b0}} ;
         if (!enable_ch1_wrdata_routing)
           dfi_mask_stack_in[pNUM_LANES*wrbeat + pCHN0_NUM_LANES +: pCHN1_NUM_LANES] = ch1_dfi_wrdata_mask[pCHN1_NUM_LANES*wrbeat +:pCHN1_NUM_LANES] ; 
         else  dfi_mask_stack_in[pNUM_LANES*wrbeat + pCHN0_NUM_LANES +: pCHN1_NUM_LANES] = {pCHN1_NUM_LANES{1'b0}} ;         
       end
       dfi_en_stack_in = {ch1_dfi_wrdata_en[pCH1_WRDATA_EN_WIDTH-1:pCH1_WRDATA_EN_WIDTH/2] & {pCH1_WRDATA_EN_WIDTH/2{enable_ch1_wren_routing}},
                          ch0_dfi_wrdata_en[pCH0_WRDATA_EN_WIDTH-1:pCH0_WRDATA_EN_WIDTH/2] & {pCH0_WRDATA_EN_WIDTH/2{enable_ch0_wren_routing}},
                          ch1_dfi_wrdata_en[pCH1_WRDATA_EN_WIDTH/2-1:0] & {pCH1_WRDATA_EN_WIDTH/2{enable_ch1_wren_routing}},
                          ch0_dfi_wrdata_en[pCH0_WRDATA_EN_WIDTH/2-1:0] & {pCH0_WRDATA_EN_WIDTH/2{enable_ch0_wren_routing}} } ;
       dfi_odt_stack_in = (ch1_dfi_odt & {pMEMCTL_ODT_WIDTH/2{enable_ch1_wren_routing,1'b0}} ) |
                          (ch0_dfi_odt & {pMEMCTL_ODT_WIDTH/2{1'b0,enable_ch0_wren_routing}} )  ;                   
    end
    always@(*)   
      wrdata_stack[wrd_stack_wrptr] = {dfi_odt_stack_in, dfi_en_stack_in, dfi_data_stack_in, dfi_mask_stack_in} ;
    always@(*) 
      wrdata_stack_out = wrdata_stack[wrd_stack_rdptr] ;
      
    //read enable
    always@(*)
      readen_stack[rde_stack_wrptr] = {ch1_dfi_rddata_en[pCH1_RDDATA_EN_WIDTH-1:pCH1_RDDATA_EN_WIDTH/2] & {pCH1_RDDATA_EN_WIDTH/2{enable_ch1_readen_routing}},
                                       ch0_dfi_rddata_en[pCH0_RDDATA_EN_WIDTH-1:pCH0_RDDATA_EN_WIDTH/2] & {pCH0_RDDATA_EN_WIDTH/2{enable_ch0_readen_routing}},
                                       ch1_dfi_rddata_en[pCH1_RDDATA_EN_WIDTH/2-1:0] & {pCH1_RDDATA_EN_WIDTH/2{enable_ch1_readen_routing}},
                                       ch0_dfi_rddata_en[pCH0_RDDATA_EN_WIDTH/2-1:0] & {pCH0_RDDATA_EN_WIDTH/2{enable_ch0_readen_routing}} } ; 
      
// the final DFI mux into PUB            
always@(*) begin
  if (pINTERLEAVER_TYPE == 2) begin 
    if (!r_wrdata_stackisempty) begin
      dfi_odt = wrdata_stack_out[pMEMCTL_DATA_WIDTH + pMEMCTL_MASK_WIDTH + pMEMCTL_WRDATA_EN_WIDTH +: pMEMCTL_ODT_WIDTH] ;
      dfi_wrdata_en = wrdata_stack_out[pMEMCTL_DATA_WIDTH + pMEMCTL_MASK_WIDTH +: pMEMCTL_WRDATA_EN_WIDTH] ;
      dfi_wrdata = wrdata_stack_out[pMEMCTL_MASK_WIDTH +: pMEMCTL_DATA_WIDTH] ;
      dfi_wrdata_mask = wrdata_stack_out[pMEMCTL_DATA_WIDTH -1:0] ;
    end  
    else begin
       for (wrbeat=0;wrbeat < pMEMCTL_NO_OF_BEATS;wrbeat = wrbeat + 1) begin
         dfi_wrdata[pNO_OF_BYTES*8*wrbeat +: pCHN0_DX8_NUM*8] = ch0_dfi_wrdata[pCHN0_DX8_NUM*8*wrbeat +:pCHN0_DX8_NUM*8] ;
         dfi_wrdata[pNO_OF_BYTES*8*wrbeat + pCHN0_DX8_NUM*8 +: pCHN1_DX8_NUM*8] = ch1_dfi_wrdata[pCHN1_DX8_NUM*8*wrbeat +:pCHN1_DX8_NUM*8] ;
         dfi_wrdata_mask[pNUM_LANES*wrbeat +: pCHN0_NUM_LANES] = ch0_dfi_wrdata_mask[pCHN0_NUM_LANES*wrbeat +:pCHN0_NUM_LANES] ;
         dfi_wrdata_mask[pNUM_LANES*wrbeat + pCHN0_NUM_LANES +: pCHN1_NUM_LANES] = ch1_dfi_wrdata_mask[pCHN1_NUM_LANES*wrbeat +:pCHN1_NUM_LANES] ;
       end
       dfi_wrdata_en = {ch1_dfi_wrdata_en[pCH1_WRDATA_EN_WIDTH-1:pCH1_WRDATA_EN_WIDTH/2], 
                        ch0_dfi_wrdata_en[pCH0_WRDATA_EN_WIDTH-1:pCH0_WRDATA_EN_WIDTH/2],
                        ch1_dfi_wrdata_en[pCH1_WRDATA_EN_WIDTH/2-1:0], 
                        ch0_dfi_wrdata_en[pCH0_WRDATA_EN_WIDTH/2-1:0] } ;
       dfi_odt  = (ch1_dfi_odt & {pMEMCTL_ODT_WIDTH/2{2'b10}}) | (ch0_dfi_odt & {pMEMCTL_ODT_WIDTH/2{2'b01}})  ;    
    end
  end else begin
    for (wrbeat=0;wrbeat < pMEMCTL_NO_OF_BEATS;wrbeat = wrbeat + 1) begin
      dfi_wrdata[pNO_OF_BYTES*8*wrbeat +: pCHN0_DX8_NUM*8] = ch0_dfi_wrdata[pCHN0_DX8_NUM*8*wrbeat +:pCHN0_DX8_NUM*8] ;
      dfi_wrdata[pNO_OF_BYTES*8*wrbeat + pCHN0_DX8_NUM*8 +: pCHN1_DX8_NUM*8] = ch1_dfi_wrdata[pCHN1_DX8_NUM*8*wrbeat +:pCHN1_DX8_NUM*8] ;
      dfi_wrdata_mask[pNUM_LANES*wrbeat +: pCHN0_NUM_LANES] = ch0_dfi_wrdata_mask[pCHN0_NUM_LANES*wrbeat +:pCHN0_NUM_LANES] ;
      dfi_wrdata_mask[pNUM_LANES*wrbeat + pCHN0_NUM_LANES +: pCHN1_NUM_LANES] = ch1_dfi_wrdata_mask[pCHN1_NUM_LANES*wrbeat +:pCHN1_NUM_LANES] ;
    end
    dfi_wrdata_en = {ch1_dfi_wrdata_en[pCH1_WRDATA_EN_WIDTH-1:pCH1_WRDATA_EN_WIDTH/2], 
                     ch0_dfi_wrdata_en[pCH0_WRDATA_EN_WIDTH-1:pCH0_WRDATA_EN_WIDTH/2],      
                     ch1_dfi_wrdata_en[pCH1_WRDATA_EN_WIDTH/2-1:0], 
                     ch0_dfi_wrdata_en[pCH0_WRDATA_EN_WIDTH/2-1:0] } ;
    dfi_odt  = (ch1_dfi_odt & {pMEMCTL_ODT_WIDTH/2{2'b10}}) | (ch0_dfi_odt & {pMEMCTL_ODT_WIDTH/2{2'b01}})  ;   
  end
end
         
always@(*) begin
  for (rdbeat=0;rdbeat < pMEMCTL_NO_OF_BEATS;rdbeat = rdbeat + 1) begin
   ch0_dfi_rddata[pCHN0_DX8_NUM*8*rdbeat +:pCHN0_DX8_NUM*8] = dfi_rddata[pNO_OF_BYTES*8*rdbeat +: pCHN0_DX8_NUM*8] ;
   ch1_dfi_rddata[pCHN1_DX8_NUM*8*rdbeat +:pCHN1_DX8_NUM*8] = dfi_rddata[pNO_OF_BYTES*8*rdbeat + pCHN0_DX8_NUM*8 +: pCHN1_DX8_NUM*8] ;       
  end
  ch0_dfi_rddata_valid = dfi_rddata_valid[0 +: pCHN0_NUM_LANES] ;
  ch1_dfi_rddata_valid = dfi_rddata_valid[pCHN0_NUM_LANES +: pCHN1_NUM_LANES] ; 
  if (pINTERLEAVER_TYPE == 2) begin 
    if (!r_readen_stackisempty)  dfi_rddata_en = readen_stack[rde_stack_rdptr] ;
    else  dfi_rddata_en = {ch1_dfi_rddata_en[pCH1_RDDATA_EN_WIDTH-1:pCH1_RDDATA_EN_WIDTH/2] & {pCH1_RDDATA_EN_WIDTH/2{!enable_ch1_readen_routing}},
                           ch0_dfi_rddata_en[pCH0_RDDATA_EN_WIDTH-1:pCH0_RDDATA_EN_WIDTH/2] & {pCH0_RDDATA_EN_WIDTH/2{!enable_ch0_readen_routing}},
                           ch1_dfi_rddata_en[pCH1_RDDATA_EN_WIDTH/2-1:0] & {pCH1_RDDATA_EN_WIDTH/2{!enable_ch1_readen_routing}},
                           ch0_dfi_rddata_en[pCH0_RDDATA_EN_WIDTH/2-1:0] & {pCH0_RDDATA_EN_WIDTH/2{!enable_ch0_readen_routing}} } ;
//    else  dfi_rddata_en = {ch1_dfi_rddata_en, ch0_dfi_rddata_en} ;                   
  end
  else dfi_rddata_en = {ch1_dfi_rddata_en[pCH1_RDDATA_EN_WIDTH-1:pCH1_RDDATA_EN_WIDTH/2],
                        ch0_dfi_rddata_en[pCH0_RDDATA_EN_WIDTH-1:pCH0_RDDATA_EN_WIDTH/2],
                        ch1_dfi_rddata_en[pCH1_RDDATA_EN_WIDTH/2-1:0], 
                        ch0_dfi_rddata_en[pCH0_RDDATA_EN_WIDTH/2-1:0] } ;
end

// Generate mask for chip-select in shared-AC configuration
initial begin
  cs_n_even_r4_mask = 4'b1010;
  cs_n_odd_r4_mask  = 4'b0101;
  cs_n_ch0_mask     = {(pNO_OF_RANKS * 2){1'b1}};
  cs_n_ch1_mask     = {(pNO_OF_RANKS * 2){1'b1}};
  `ifdef DWC_DDRPHY_HDR_MODE
    // In HOC mode, ch0 odd command and ch1 even command are aggregrated
    // together with even ranks for ch0 and odd ranks for ch1
    `ifdef MSD_HDR_ODD_CMD
      cs_n_ch0_mask[(pNO_OF_RANKS * 2) - 1 : pNO_OF_RANKS] = cs_n_even_r4_mask[pNO_OF_RANKS - 1 : 0];
      cs_n_ch1_mask[pNO_OF_RANKS       - 1 :            0] = cs_n_odd_r4_mask [pNO_OF_RANKS - 1 : 0];
    // In HEC mode, ch0 even command and ch1 odd command are aggregrated
    // together with even ranks for ch0 and odd ranks for ch1
    `else
      cs_n_ch0_mask[pNO_OF_RANKS       - 1 :            0] = cs_n_even_r4_mask[pNO_OF_RANKS - 1 : 0];
      cs_n_ch1_mask[(pNO_OF_RANKS * 2) - 1 : pNO_OF_RANKS] = cs_n_odd_r4_mask [pNO_OF_RANKS - 1 : 0];
    `endif
  `endif
end
         
always@(*) begin
  case(pINTERLEAVER_TYPE)
  0 : begin
        dfi_reset_n       = ch0_dfi_reset_n & ch1_dfi_reset_n  ;
        dfi_cke           = (ch0_dfi_cke & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) |
                            (ch1_dfi_cke & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) ;
        //dfi_odt           = {ch1_dfi_odt[pMEMCTL_ODT_WIDTH/2 +:pMEMCTL_ODT_WIDTH/2], ch1_dfi_odt[0 +:pMEMCTL_ODT_WIDTH/2]}      ;
//        dfi_odt           = (ch0_dfi_odt & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) |
//                            (ch1_dfi_odt & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) ;  
        dfi_cs_n          = (ch0_dfi_cs_n | {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) &
                            (ch1_dfi_cs_n | {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) ;
        dfi_cid           = ch0_dfi_cid     ;
        dfi_ras_n         = ch0_dfi_ras_n   ;  //in special case we don't care
        dfi_cas_n         = ch0_dfi_cas_n   ;
        dfi_we_n          = ch0_dfi_we_n    ;
        dfi_bank          = ch0_dfi_bank    ;
        dfi_address       = ch0_dfi_address ;
        dfi_act_n         = ch0_dfi_act_n   ;
        dfi_bg            = ch0_dfi_bg      ;
        dfi_parity_in     = ch0_dfi_parity_in;
      end
  1 : begin
`ifdef DWC_DDRPHY_HDR_MODE
  `ifdef MSD_RND_HDR_ODD_CMD
        // HEOC mode??
        dfi_reset_n       = mx_dfi_reset_n  ;
        dfi_cke           = mx_dfi_cke      ;
//        dfi_odt           = mx_dfi_odt      ;
        dfi_cs_n          = mx_dfi_cs_n     ;
        dfi_cid           = mx_dfi_cid      ;
        dfi_ras_n         = mx_dfi_ras_n    ;  //in special case we don't care
        dfi_cas_n         = mx_dfi_cas_n    ;
        dfi_we_n          = mx_dfi_we_n     ;
        dfi_bank          = mx_dfi_bank     ;
        dfi_address       = mx_dfi_address  ;
        dfi_act_n         = mx_dfi_act_n    ;
        dfi_bg            = mx_dfi_bg       ;
        dfi_parity_in     = ch0_dfi_parity_in;
  `else
    `ifdef MSD_HDR_ODD_CMD
        // HOC mode
        dfi_reset_n       = {ch0_dfi_reset_n[pMEMCTL_RESET_WIDTH/2 +:pMEMCTL_RESET_WIDTH/2], ch1_dfi_reset_n[0 +:pMEMCTL_RESET_WIDTH/2]}  ;
        dfi_cke           = (ch0_dfi_cke & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) |
                            (ch1_dfi_cke & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) ;
        //dfi_odt           = {ch1_dfi_odt[pMEMCTL_ODT_WIDTH/2 +:pMEMCTL_ODT_WIDTH/2], ch1_dfi_odt[0 +:pMEMCTL_ODT_WIDTH/2]}      ;
//        dfi_odt           = (ch0_dfi_odt & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) |
//                            (ch1_dfi_odt & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) ;  
        dfi_cs_n          = (ch0_dfi_cs_n | cs_n_ch0_mask) & (ch1_dfi_cs_n | cs_n_ch1_mask);
        dfi_cid           = specialcase_type1 ?
                            ch0_dfi_cid :   //TBC -> should be the same as the last transmitted CMD from prev cycle... 
                            {ch0_dfi_cid[pMEMCTL_CID_WIDTH/2 +:pMEMCTL_CID_WIDTH/2], ch1_dfi_cid[0 +:pMEMCTL_CID_WIDTH/2]}   ;
        dfi_ras_n         = {ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2], ch1_dfi_ras_n[0 +:pMEMCTL_RAS_N_WIDTH/2]}   ;
        dfi_cas_n         = {ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2], ch1_dfi_cas_n[0 +:pMEMCTL_CAS_N_WIDTH/2]}   ;
        dfi_we_n          = {ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2], ch1_dfi_we_n[0 +:pMEMCTL_WE_N_WIDTH/2]}   ;
        dfi_bank          = specialcase_type1 ?
                            ch0_dfi_bank :   //TBC -> should be the same as the last transmitted CMD from prev cycle... 
                            {ch0_dfi_bank[pMEMCTL_BANK_WIDTH/2 +:pMEMCTL_BANK_WIDTH/2], ch1_dfi_bank[0 +:pMEMCTL_BANK_WIDTH/2]}   ;
        dfi_address       = specialcase_type1 ?
                            ch0_dfi_address :   
                            {ch0_dfi_address[pMEMCTL_ADDR_WIDTH/2 +:pMEMCTL_ADDR_WIDTH/2], ch1_dfi_address[0 +:pMEMCTL_ADDR_WIDTH/2]}  ;
        dfi_act_n         = {ch0_dfi_act_n[pMEMCTL_ACT_N_WIDTH/2 +:pMEMCTL_ACT_N_WIDTH/2], ch1_dfi_act_n[0 +:pMEMCTL_ACT_N_WIDTH/2]}   ;
        dfi_bg            = specialcase_type1 ?
                            ch0_dfi_bg :   //TBC -> should be the same as the last transmitted CMD from prev cycle... 
                            {ch0_dfi_bg[pMEMCTL_BG_WIDTH/2 +:pMEMCTL_BG_WIDTH/2], ch1_dfi_bg[0 +:pMEMCTL_BG_WIDTH/2]}   ;
        dfi_parity_in     = specialcase_type1 ?
                            {(^{ch0_dfi_address[pMEMCTL_ADDR_WIDTH/2 +:pMEMCTL_ADDR_WIDTH/2],
                                ch0_dfi_bank   [pMEMCTL_BANK_WIDTH/2 +:pMEMCTL_BANK_WIDTH/2],
                                ch0_dfi_ras_n  [pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch0_dfi_cas_n  [pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch0_dfi_we_n   [pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2]}),
                             (^{ch0_dfi_address[0 +:pMEMCTL_ADDR_WIDTH/2],
                                ch0_dfi_bank   [0 +:pMEMCTL_BANK_WIDTH/2],
                                ch0_dfi_ras_n  [0 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch0_dfi_cas_n  [0 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch0_dfi_we_n   [0 +:pMEMCTL_WE_N_WIDTH/2]})}
                            :
                            {(^{ch0_dfi_address[pMEMCTL_ADDR_WIDTH/2 +:pMEMCTL_ADDR_WIDTH/2],
                                ch0_dfi_bank   [pMEMCTL_BANK_WIDTH/2 +:pMEMCTL_BANK_WIDTH/2],
                                ch0_dfi_ras_n  [pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch0_dfi_cas_n  [pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch0_dfi_we_n   [pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2]}),
                             (^{ch1_dfi_address[0 +:pMEMCTL_ADDR_WIDTH/2],
                                ch1_dfi_bank   [0 +:pMEMCTL_BANK_WIDTH/2],
                                ch1_dfi_ras_n  [0 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch1_dfi_cas_n  [0 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch1_dfi_we_n   [0 +:pMEMCTL_WE_N_WIDTH/2]})};
    `else 
        // HEC mode
        dfi_reset_n       = {ch1_dfi_reset_n[pMEMCTL_RESET_WIDTH/2 +:pMEMCTL_RESET_WIDTH/2], ch0_dfi_reset_n[0 +:pMEMCTL_RESET_WIDTH/2]}  ;
        dfi_cke           = (ch0_dfi_cke & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) |
                            (ch1_dfi_cke & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) ;
        //dfi_odt           = {ch1_dfi_odt[pMEMCTL_ODT_WIDTH/2 +:pMEMCTL_ODT_WIDTH/2], ch1_dfi_odt[0 +:pMEMCTL_ODT_WIDTH/2]}      ;
//        dfi_odt           = (ch0_dfi_odt & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b01}}}}) |
//                            (ch1_dfi_odt & {pMEMCTL_NO_OF_CMDS{{pNO_OF_RANKS/2{2'b10}}}}) ;  
        dfi_cs_n          = (ch0_dfi_cs_n | cs_n_ch0_mask) & (ch1_dfi_cs_n | cs_n_ch1_mask);
        dfi_cid           = specialcase_type1 ?
                            ch1_dfi_cid :   
                            {ch1_dfi_cid[pMEMCTL_CID_WIDTH/2 +:pMEMCTL_CID_WIDTH/2], ch0_dfi_cid[0 +:pMEMCTL_CID_WIDTH/2]}   ;
        dfi_ras_n         = {ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2], ch0_dfi_ras_n[0 +:pMEMCTL_RAS_N_WIDTH/2]}   ;
        dfi_cas_n         = {ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2], ch0_dfi_cas_n[0 +:pMEMCTL_CAS_N_WIDTH/2]}   ;
        dfi_we_n          = {ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2], ch0_dfi_we_n[0 +:pMEMCTL_WE_N_WIDTH/2]}   ;
        dfi_bank          = specialcase_type1 ?
                            ch1_dfi_bank :   
                            {ch1_dfi_bank[pMEMCTL_BANK_WIDTH/2 +:pMEMCTL_BANK_WIDTH/2], ch0_dfi_bank[0 +:pMEMCTL_BANK_WIDTH/2]}   ;
        dfi_address       = specialcase_type1 ?
                            ch1_dfi_address :   
                            {ch1_dfi_address[pMEMCTL_ADDR_WIDTH/2 +:pMEMCTL_ADDR_WIDTH/2], ch0_dfi_address[0 +:pMEMCTL_ADDR_WIDTH/2]}  ;
        dfi_act_n         = {ch1_dfi_act_n[pMEMCTL_ACT_N_WIDTH/2 +:pMEMCTL_ACT_N_WIDTH/2], ch0_dfi_act_n[0 +:pMEMCTL_ACT_N_WIDTH/2]}   ;
        dfi_bg            = specialcase_type1 ?
                            ch1_dfi_bg :   
                            {ch1_dfi_bg[pMEMCTL_BG_WIDTH/2 +:pMEMCTL_BG_WIDTH/2], ch0_dfi_bg[0 +:pMEMCTL_BG_WIDTH/2]}   ;
        dfi_parity_in     = specialcase_type1 ?
                            {(^{ch1_dfi_address[pMEMCTL_ADDR_WIDTH/2 +:pMEMCTL_ADDR_WIDTH/2],
                                ch1_dfi_bank   [pMEMCTL_BANK_WIDTH/2 +:pMEMCTL_BANK_WIDTH/2],
                                ch1_dfi_ras_n  [pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch1_dfi_cas_n  [pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch1_dfi_we_n   [pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2]}),
                             (^{ch1_dfi_address[0 +:pMEMCTL_ADDR_WIDTH/2],
                                ch1_dfi_bank   [0 +:pMEMCTL_BANK_WIDTH/2],
                                ch1_dfi_ras_n  [0 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch1_dfi_cas_n  [0 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch1_dfi_we_n   [0 +:pMEMCTL_WE_N_WIDTH/2]})}
                            :
                            {(^{ch1_dfi_address[pMEMCTL_ADDR_WIDTH/2 +:pMEMCTL_ADDR_WIDTH/2],
                                ch1_dfi_bank   [pMEMCTL_BANK_WIDTH/2 +:pMEMCTL_BANK_WIDTH/2],
                                ch1_dfi_ras_n  [pMEMCTL_RAS_N_WIDTH/2 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch1_dfi_cas_n  [pMEMCTL_CAS_N_WIDTH/2 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch1_dfi_we_n   [pMEMCTL_WE_N_WIDTH/2 +:pMEMCTL_WE_N_WIDTH/2]}),
                             (^{ch0_dfi_address[0 +:pMEMCTL_ADDR_WIDTH/2],
                                ch0_dfi_bank   [0 +:pMEMCTL_BANK_WIDTH/2],
                                ch0_dfi_ras_n  [0 +:pMEMCTL_RAS_N_WIDTH/2],
                                ch0_dfi_cas_n  [0 +:pMEMCTL_CAS_N_WIDTH/2],
                                ch0_dfi_we_n   [0 +:pMEMCTL_WE_N_WIDTH/2]})};
    `endif
  `endif
`else
        // SDR mode
        dfi_reset_n       = mx_dfi_reset_n  ;
        dfi_cke           = mx_dfi_cke      ;
//        dfi_odt           = mx_dfi_odt      ;
        dfi_cs_n          = mx_dfi_cs_n     ;
        dfi_cid           = mx_dfi_cid      ;
        dfi_ras_n         = mx_dfi_ras_n    ;  //in special case we don't care
        dfi_cas_n         = mx_dfi_cas_n    ;
        dfi_we_n          = mx_dfi_we_n     ;
        dfi_bank          = mx_dfi_bank     ;
        dfi_address       = mx_dfi_address  ;
        dfi_act_n         = mx_dfi_act_n    ;
        dfi_bg            = mx_dfi_bg       ;
        dfi_parity_in     = ch0_dfi_parity_in;
`endif
      end
  2 : begin
        dfi_reset_n       = mx_dfi_reset_n  ;
        dfi_cke           = mx_dfi_cke      ;
//        dfi_odt           = mx_dfi_odt      ;
        dfi_cs_n          = mx_dfi_cs_n     ;
        dfi_cid           = mx_dfi_cid      ;
        dfi_ras_n         = mx_dfi_ras_n    ;  //in special case we don't care
        dfi_cas_n         = mx_dfi_cas_n    ;
        dfi_we_n          = mx_dfi_we_n     ;
        dfi_bank          = mx_dfi_bank     ;
        dfi_address       = mx_dfi_address  ;
        dfi_act_n         = mx_dfi_act_n    ;
        dfi_bg            = mx_dfi_bg       ;
        dfi_parity_in     = ch0_dfi_parity_in;
      end
  default : begin
      end
  endcase
end                  

//***************************
// arbiter for type 2 interleaver
//***************************
                                    
//     parameter pMEMCTL_RESET_WIDTH      = (pMEMCTL_NO_OF_CMDS * pRST_WIDTH);
//     parameter pMEMCTL_CKE_WIDTH        = (pMEMCTL_NO_OF_CMDS * pNO_OF_RANKS);
//     parameter pMEMCTL_ODT_WIDTH        = (pMEMCTL_NO_OF_CMDS * pNO_OF_RANKS);
//     parameter pMEMCTL_CS_N_WIDTH       = (pMEMCTL_NO_OF_CMDS * pNO_OF_RANKS);
//     parameter pMEMCTL_RAS_N_WIDTH      = (pMEMCTL_NO_OF_CMDS * 1);
//     parameter pMEMCTL_CAS_N_WIDTH      = (pMEMCTL_NO_OF_CMDS * 1);
//     parameter pMEMCTL_WE_N_WIDTH       = (pMEMCTL_NO_OF_CMDS * 1);
//     parameter pMEMCTL_ADDR_WIDTH       = (pMEMCTL_NO_OF_CMDS * pADDR_WIDTH);
//     parameter pMEMCTL_BANK_WIDTH       = (pMEMCTL_NO_OF_CMDS * pBANK_WIDTH);
                                    
    always@(posedge dfi_clk) begin
       //wait for next-cycle DFI interface data to stabilize
       #(pCLK_WAIT_WINDOW) ;
       if (stackisempty && (!ch0_active_command_odd) && (!ch1_active_command_odd) && (!ch0_active_command_even) && (!ch1_active_command_even) ) begin
         mx_dfi_reset_n       <= ch0_dfi_reset_n & ch1_dfi_reset_n   ;  //special case for reset as it doesn't affect *_active_command flags
         mx_dfi_cke           <= ch0_dfi_cke | ch1_dfi_cke     ;
         mx_dfi_odt           <= ch0_dfi_odt | ch1_dfi_odt     ;
         mx_dfi_cs_n          <= ch0_dfi_cs_n & ch1_dfi_cs_n   ;   //distinguishes NOP from deselect?
         mx_dfi_cid           <= mx_dfi_cid    ;
         mx_dfi_ras_n         <= {pMEMCTL_RAS_N_WIDTH{1'b1}}   ;
         mx_dfi_cas_n         <= {pMEMCTL_CAS_N_WIDTH{1'b1}}   ;
         mx_dfi_we_n          <= {pMEMCTL_WE_N_WIDTH{1'b1}}    ;
         mx_dfi_bank          <= mx_dfi_bank    ;
         mx_dfi_address       <= mx_dfi_address ;
         mx_dfi_act_n         <= {pMEMCTL_ACT_N_WIDTH{1'b1}}    ;
         mx_dfi_bg            <= mx_dfi_bg    ;
       end
       else if (stackisempty) begin
         if (check_collision_odd === 1'b0) begin // no collision -> pass through the combined ch0/ch1 control signals
           if (ch0_active_command_odd) begin
             mx_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] <= specialcase_odd ? ch0_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS]  :  ch0_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ; 
             mx_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]       <= specialcase_odd ? ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] : ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             //mx_dfi_odt           <= /*specialcase ? */ch0_dfi_odt | ch1_dfi_odt /*: ch0_dfi_odt*/     ;
             mx_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]     <= specialcase_odd ? ch0_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] : ch0_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     <= ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     <= ch0_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  <= ch0_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch0_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]         ;
           end else if (ch1_active_command_odd) begin   
             mx_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] <= specialcase_odd ? ch0_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS]  :  ch1_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ; 
             mx_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]       <= specialcase_odd ? ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] : ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             //mx_dfi_odt           <= /*specialcase ? */ch0_dfi_odt | ch1_dfi_odt /*: ch0_dfi_odt*/     ;
             mx_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]     <= specialcase_odd ? ch0_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] : ch1_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch1_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     <= ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     <= ch1_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  <= ch1_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch1_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]         ;
           end  
         end else begin  // we have a collision but the stack is empty
           case(priority_toggle)
           1'b0:  begin   //ch0 has priority
             mx_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch0_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ;
             mx_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch0_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch0_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch0_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch0_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]        <= ch0_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]        <= ch0_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch0_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch0_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS] ;
             mx_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]        <= ch0_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]              <= ch0_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             if (check_collision_even) push_command_stack(1,pBOTH);
             else push_command_stack(1,pODD);
           end  
           1'b1:  begin   //ch1 has priority
             mx_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch1_dfi_reset_n[0+:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ;
             mx_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch1_dfi_cke[0+:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch1_dfi_odt[0+:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch1_dfi_cs_n[0+:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch1_dfi_cid[0+:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]        <= ch1_dfi_ras_n[0+:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]        <= ch1_dfi_cas_n[0+:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch1_dfi_we_n[0+:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch1_dfi_bank[0+:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch1_dfi_address[0+:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS] ;
             mx_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]        <= ch1_dfi_act_n[0+:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             mx_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]              <= ch1_dfi_bg[0+:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]    ;
             if (check_collision_even) push_command_stack(0,pBOTH);  //pBOTH must be redundant in SDR mode
             else push_command_stack(0,pODD);
           end 
           endcase            
           priority_toggle <= !priority_toggle ;  //MUST be non-blocking to prevent EVEN side re-toggle
         end
         if (pHDR_MODE_EN == 1) begin if (check_collision_even === 1'b0) begin  //in SDR mode only the ODD-side collision will be considered (they are the same)
           if (ch0_active_command_even) begin
             mx_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] <= specialcase_even ? ch0_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS]  :  ch0_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ; 
             mx_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]         <= specialcase_even ? ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] : ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             //mx_dfi_odt           <= /*specialcase ? */ch0_dfi_odt | ch1_dfi_odt /*: ch0_dfi_odt*/     ;
             mx_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]    <= specialcase_even ? ch0_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] : ch0_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]    <= ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]    <= ch0_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch0_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch0_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch0_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
           end else if (ch1_active_command_even) begin  
             mx_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] <= specialcase_even ? ch0_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS]  :  ch1_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ; 
             mx_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]         <= specialcase_even ? ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS] : ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             //mx_dfi_odt           <= /*specialcase ? */ch0_dfi_odt | ch1_dfi_odt /*: ch0_dfi_odt*/     ;
             mx_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch0_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS] | ch1_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]    <= specialcase_even ? ch0_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] & ch1_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS] : ch1_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]       <= ch1_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]    <= ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]    <= ch1_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch1_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch1_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]          <= ch1_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
           end  
         end else begin  // we have a collision but the stack is empty
           case(priority_toggle)
           1'b0:  begin   //ch0 has priority
             mx_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch0_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ; 
             mx_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch0_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch0_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch0_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch0_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch0_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch0_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch0_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch0_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             if (!check_collision_odd) push_command_stack(1,pEVEN);
           end  
           1'b1:  begin   //ch1 has priority
             mx_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] <= ch1_dfi_reset_n[pMEMCTL_RESET_WIDTH-1-:pMEMCTL_RESET_WIDTH/pMEMCTL_NO_OF_CMDS] ; 
             mx_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch1_dfi_cke[pMEMCTL_CKE_WIDTH-1-:pMEMCTL_CKE_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch1_dfi_odt[pMEMCTL_ODT_WIDTH-1-:pMEMCTL_ODT_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch1_dfi_cs_n[pMEMCTL_CS_N_WIDTH-1-:pMEMCTL_CS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]         <= ch1_dfi_cid[pMEMCTL_CID_WIDTH-1-:pMEMCTL_CID_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_ras_n[pMEMCTL_RAS_N_WIDTH-1-:pMEMCTL_RAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_cas_n[pMEMCTL_CAS_N_WIDTH-1-:pMEMCTL_CAS_N_WIDTH/pMEMCTL_NO_OF_CMDS]   ;
             mx_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch1_dfi_we_n[pMEMCTL_WE_N_WIDTH-1-:pMEMCTL_WE_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]      <= ch1_dfi_bank[pMEMCTL_BANK_WIDTH-1-:pMEMCTL_BANK_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_address[pMEMCTL_ADDR_WIDTH-1-:pMEMCTL_ADDR_WIDTH/pMEMCTL_NO_OF_CMDS]  ;
             mx_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]   <= ch1_dfi_act_n[pMEMCTL_ACT_N_WIDTH-1-:pMEMCTL_ACT_N_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             mx_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]            <= ch1_dfi_bg[pMEMCTL_BG_WIDTH-1-:pMEMCTL_BG_WIDTH/pMEMCTL_NO_OF_CMDS]     ;
             if (!check_collision_odd) push_command_stack(0,pEVEN);
           end 
           endcase            
           if (!check_collision_odd) priority_toggle <= !priority_toggle ;
         end end 
       end  
       else begin  // stack not empty -> must have priority to respect order of execution
         //$display("AUX : popping command stack at %t", $time);
         pop_command_stack  ;
         case(priority_toggle)
         1'b0   :  begin
            case({ch0_active_command_odd,ch0_active_command_even})
            2'b00 : begin end   //nop
            2'b01 : push_command_stack(0,pEVEN);
            2'b10 : push_command_stack(0,pODD);
            2'b11 : push_command_stack(0,pBOTH);
            endcase
            case({ch1_active_command_odd,ch1_active_command_even})
            2'b00 : begin end   //nop
            2'b01 : push_command_stack(1,pEVEN);
            2'b10 : push_command_stack(1,pODD);
            2'b11 : push_command_stack(1,pBOTH);
            endcase
         end   
         1'b1   :  begin
            case({ch1_active_command_odd,ch1_active_command_even})
            2'b00 : begin end   //nop
            2'b01 : push_command_stack(1,pEVEN);
            2'b10 : push_command_stack(1,pODD);
            2'b11 : push_command_stack(1,pBOTH);
            endcase
            case({ch0_active_command_odd,ch0_active_command_even})
            2'b00 : begin end   //nop
            2'b01 : push_command_stack(0,pEVEN);
            2'b10 : push_command_stack(0,pODD);
            2'b11 : push_command_stack(0,pBOTH);
            endcase
         end
         endcase
         if ((ch1_active_command_odd || ch1_active_command_even) ^ (ch0_active_command_odd || ch0_active_command_even))
            priority_toggle <= !priority_toggle ;  //if 0 or 2 stack pushes, don't update priority
       end  
     end      
    
//***********************************
// Command stack control
//***********************************            
event  inc_cmd_stack_wrptr ;         
always@(inc_cmd_stack_wrptr) begin
  @(posedge dfi_clk)  cmd_stack_wrptr = (cmd_stack_wrptr + 1) % pCOMM_STACK_DEPTH ;
end                     
event  inc_cmd_stack_rdptr ;         
always@(inc_cmd_stack_rdptr) begin
  @(posedge dfi_clk)  cmd_stack_rdptr = (cmd_stack_rdptr + 1) % pCOMM_STACK_DEPTH ;
  if (cmd_stack_rdptr == cmd_stack_wrptr) stackisempty = 1'b1 ;
end         
         
initial begin
  comm_stack_oddmask  = 1'b0 ;
  comm_stack_evenmask  = 1'b0 ;
end  
         

// ---------------------------------------------------------------------------------
// Task   : push_command_stack()
// Inputs : channelid, pushtype.
// ---------------------------------------------------------------------------------
task push_command_stack;
  input integer channelid;
  input integer pushtype;
begin
   //grep command onto FIFO and update FIFO pointer
   comm_stack_oddmask  = (pushtype==pEVEN) ;
   comm_stack_evenmask = (pushtype==pODD ) ;
   case(channelid) 
   0:  command_stack[cmd_stack_wrptr] = {1'b0, command_stack_in_0} ;
   1:  command_stack[cmd_stack_wrptr] = {1'b1, command_stack_in_1} ;
   default:  $display("[Interleaver] ERROR -> invalid channel ID");
   endcase
   -> inc_cmd_stack_wrptr ;
   stackisempty = 1'b0 ;
   comm_stack_oddmask  = 1'b0 ;
   comm_stack_evenmask = 1'b0 ;
   
   //if write -> delayed_push_wrdata_stack
   case(channelid)
   0:  begin if (ch0_write_odd && ((pushtype==pODD) || (pushtype==pBOTH)) )   //it's a write?
         -> delayed_push_wrdata_stack_0 ;
       if (ch0_read_odd && ((pushtype==pODD) || (pushtype==pBOTH)) )    //can be *also* a read?
         -> delayed_push_rdenable_stack_0 ;
       if (ch0_write_even && ((pushtype==pEVEN) || (pushtype==pBOTH)) && (pHDR_MODE_EN==1))   //it's a write?
         -> delayed_push_wrdata_stack_0 ;
       if (ch0_read_even && ((pushtype==pEVEN) || (pushtype==pBOTH)) && (pHDR_MODE_EN==1))      //can be *also* a read?
         -> delayed_push_rdenable_stack_0 ;  
       // what about non-writes non-reads (??)  -> no data stack effect (just push/pop command)
       end
   1:  begin if (ch1_write_odd && ((pushtype==pODD) || (pushtype==pBOTH)) )   //it's a write?
         -> delayed_push_wrdata_stack_1 ;
       if (ch1_read_odd && ((pushtype==pODD) || (pushtype==pBOTH)) )    //can be *also* a read?
         -> delayed_push_rdenable_stack_1 ;
       if (ch1_write_even && ((pushtype==pEVEN) || (pushtype==pBOTH)) && (pHDR_MODE_EN==1))   //it's a write?
         -> delayed_push_wrdata_stack_1 ;
       if (ch1_read_even && ((pushtype==pEVEN) || (pushtype==pBOTH)) && (pHDR_MODE_EN==1))      //can be *also* a read?
         -> delayed_push_rdenable_stack_1 ;  
       // what about non-writes non-reads (??)  -> no data stack effect (just push/pop command)
       end  
   default:  $display("[Interleaver] ERROR -> invalid channel ID");
   endcase 
end
endtask // task push_command_stack;


// ---------------------------------------------------------------------------------
// Task   : pop_command_stack()
// Inputs : channelid, pushtype.
// ---------------------------------------------------------------------------------
task pop_command_stack;
  reg   channel_popped;
begin
   //set DFI from FIFO and update read pointer
   mx_dfi_reset_n <= {pMEMCTL_RESET_WIDTH{1'b1}};
   {channel_popped, mx_dfi_cke/*, mx_dfi_odt*/, mx_dfi_cs_n, mx_dfi_ras_n, mx_dfi_cas_n, mx_dfi_we_n, mx_dfi_bank, mx_dfi_address} <= command_stack_out;
   //mx_dfi_cke  = command_stack_out[pMEMCTL_ODT_WIDTH+pMEMCTL_CS_N_WIDTH+pMEMCTL_RAS_N_WIDTH+pMEMCTL_CAS_N_WIDTH+pMEMCTL_WE_N_WIDTH+pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH +:pMEMCTL_CKE_WIDTH];
   //mx_dfi_odt  = command_stack_out[pMEMCTL_CS_N_WIDTH+pMEMCTL_RAS_N_WIDTH+pMEMCTL_CAS_N_WIDTH+pMEMCTL_WE_N_WIDTH+pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH +:pMEMCTL_ODT_WIDTH];          
   //mx_dfi_cs_n = command_stack_out[pMEMCTL_RAS_N_WIDTH+pMEMCTL_CAS_N_WIDTH+pMEMCTL_WE_N_WIDTH+pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH +:pMEMCTL_CS_N_WIDTH];          
   //mx_dfi_ras_n = command_stack_out[pMEMCTL_CAS_N_WIDTH+pMEMCTL_WE_N_WIDTH+pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH +:pMEMCTL_RAS_N_WIDTH];          
   //mx_dfi_cas_n = command_stack_out[pMEMCTL_WE_N_WIDTH+pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH +:pMEMCTL_CAS_N_WIDTH];         
   //mx_dfi_we_n  = command_stack_out[pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH +:pMEMCTL_WE_N_WIDTH];
   //mx_dfi_bank  = command_stack_out[pMEMCTL_ADDR_WIDTH +:pMEMCTL_BANK_WIDTH];
   //mx_dfi_address = command_stack_out[0 +:pMEMCTL_ADDR_WIDTH] ;   
   //if write -> delayed_pop_wrdata_stack
   #(0.01);  //event sequencing
   if ( |( mx_dfi_ras_n & (~mx_dfi_cas_n) & (~mx_dfi_we_n) ) )
     //if (command_stack_out[pMEMCTL_ODT_WIDTH+pMEMCTL_CS_N_WIDTH+pMEMCTL_RAS_N_WIDTH+pMEMCTL_CAS_N_WIDTH+pMEMCTL_WE_N_WIDTH+pMEMCTL_BANK_WIDTH+pMEMCTL_ADDR_WIDTH+pMEMCTL_CKE_WIDTH]==1'b1)
     -> delayed_pop_wrdata_stack ;
   //if read -> delayed_pop_readenable_stack   
   if ( |( mx_dfi_ras_n & (~mx_dfi_cas_n) & mx_dfi_we_n ) )   -> delayed_pop_rdenable_stack ;
   
   -> inc_cmd_stack_rdptr ;
   //cmd_stack_rdptr = (cmd_stack_rdptr + 1) % pCOMM_STACK_DEPTH ; 
end
endtask // task pop_command_stack


//*****************************
// WR data stack control
//*****************************
always@(delayed_push_wrdata_stack_0) begin
  if (`GRM.hdr_mode) begin
    case(`GRM.wl[0])
    1'b0 :   repeat ((`GRM.wl - 4)/2)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat ((`GRM.wl - 3)/2)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_wrdata_en into the stack
    enable_ch0_wren_routing = 1'b1 ;
    wrburstptr = (wrburstptr + 1) % pCOMM_STACK_DEPTH ;
    wrburstlength[wrburstptr] = 0 ;  //clear burst length counter
    fork 
      //now the actual wrdata / wrdatamask signals will appear one cycle later
      @(posedge dfi_clk)  enable_ch0_wrdata_routing = 1'b1 ;
      //and time for the end of the write
      begin
        while (ch0_dfi_wrdata_en !== {pCH0_WRDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) wrburstlength[wrburstptr] = wrburstlength[wrburstptr] + 1 ;
        enable_ch0_wren_routing = 1'b0 ; 
        @(posedge dfi_clk)  enable_ch0_wrdata_routing = 1'b0 ;
        wrburstlength[wrburstptr] = wrburstlength[wrburstptr] + 1 ;
      end
    join  
  end
  else begin //SDR
    case(`GRM.wl[0])
    1'b0 :   repeat (`GRM.wl - 4)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat (`GRM.wl - 3)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_wrdata_en and data/mask into the stack
    enable_ch0_wren_routing = 1'b1 ;
    enable_ch0_wrdata_routing = 1'b1 ;
    wrburstptr = (wrburstptr + 1) % pCOMM_STACK_DEPTH ;
    wrburstlength[wrburstptr] = 0 ;  //clear burst length counter
    while (ch0_dfi_wrdata_en !== {pCH0_WRDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) wrburstlength[wrburstptr] = wrburstlength[wrburstptr] + 1;
    enable_ch0_wren_routing = 1'b0 ; 
    enable_ch0_wrdata_routing = 1'b0 ;
  end
end

always@(delayed_push_wrdata_stack_1) begin
  if (`GRM.hdr_mode) begin
    case(`GRM.wl[0])
    1'b0 :   repeat ((`GRM.wl - 4)/2)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat ((`GRM.wl - 3)/2)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_wrdata_en into the stack
    enable_ch1_wren_routing = 1'b1 ;
    wrburstptr = (wrburstptr + 1) % pCOMM_STACK_DEPTH ;
    wrburstlength[wrburstptr] = 0 ;  //clear burst length counter
    fork 
      //now the actual wrdata / wrdatamask signals will appear one cycle later
      @(posedge dfi_clk)  enable_ch1_wrdata_routing = 1'b1 ;
      //and time for the end of the write
      begin
        while (ch1_dfi_wrdata_en !== {pCH1_WRDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) wrburstlength[wrburstptr] = wrburstlength[wrburstptr] + 1 ;
        enable_ch1_wren_routing = 1'b0 ; 
        @(posedge dfi_clk)  enable_ch1_wrdata_routing = 1'b0 ;
        wrburstlength[wrburstptr] = wrburstlength[wrburstptr] + 1 ;
      end
    join  
  end
  else begin //SDR
    case(`GRM.wl[0])
    1'b0 :   repeat (`GRM.wl - 4)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat (`GRM.wl - 3)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_wrdata_en and data/mask into the stack
    enable_ch1_wren_routing = 1'b1 ;
    enable_ch1_wrdata_routing = 1'b1 ;
    wrburstptr = (wrburstptr + 1) % pCOMM_STACK_DEPTH ;
    wrburstlength[wrburstptr] = 0 ;  //clear burst length counter
    while (ch1_dfi_wrdata_en !== {pCH1_WRDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) wrburstlength[wrburstptr] = wrburstlength[wrburstptr] + 1;
    enable_ch1_wren_routing = 1'b0 ; 
    enable_ch1_wrdata_routing = 1'b0 ;
  end
end

always@(delayed_pop_wrdata_stack) begin 
  if (`GRM.hdr_mode)
    case(`GRM.wl[0])
    1'b0 :   repeat ((`GRM.wl - 4)/2)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat ((`GRM.wl - 3)/2)    @(posedge dfi_clk);  //odd WL
    endcase
  else  //SDR
    case(`GRM.wl[0])
    1'b0 :   repeat (`GRM.wl - 4)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat (`GRM.wl - 3)    @(posedge dfi_clk);  //odd WL
    endcase  
  wrburstptr_out = (wrburstptr_out + 1) % pCOMM_STACK_DEPTH ;
  readdatacntr = 0 ;  
  while (readdatacntr < wrburstlength[wrburstptr_out]) @(posedge dfi_clk) begin
     readdatacntr = readdatacntr + 1 ;
     wrd_stack_rdptr = (wrd_stack_rdptr + 1) % pDATA_STACK_DEPTH ;
  end
end     

always@(posedge dfi_clk) begin
  if (enable_ch1_wren_routing || enable_ch0_wren_routing || enable_ch1_wrdata_routing || enable_ch0_wrdata_routing)
    wrd_stack_wrptr = (wrd_stack_wrptr + 1) % pDATA_STACK_DEPTH ;
  if (!r_wrdata_stackisempty) r_wrdata_stackisempty  <= (wrd_stack_rdptr===wrd_stack_wrptr) ;
end      


//*****************************
// RD enable stack control
//*****************************
always@(delayed_push_rdenable_stack_0) begin
  if (`GRM.hdr_mode) begin
    case(`GRM.rl[0])
    1'b0 :   repeat ((`GRM.rl - 4)/2)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat ((`GRM.rl - 3)/2)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_rddata_en into the stack
    enable_ch0_readen_routing = 1'b1 ;
    rdburstptr = (rdburstptr + 1) % pCOMM_STACK_DEPTH ;
    rdburstlength[rdburstptr] = 0 ;  //clear burst length counter
    @(posedge dfi_clk) rdburstlength[rdburstptr] = rdburstlength[rdburstptr] + 1 ;  //min burst of 1 cycle
    while (ch0_dfi_rddata_en !== {pCH0_RDDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) rdburstlength[rdburstptr] = rdburstlength[rdburstptr] + 1 ;
    enable_ch0_readen_routing = 1'b0 ;   
  end
  else begin //SDR
    case(`GRM.rl[0])
    1'b0 :   repeat (`GRM.rl - 4)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat (`GRM.rl - 3)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_wrdata_en and data/mask into the stack
    enable_ch0_readen_routing = 1'b1 ;
    rdburstptr = (rdburstptr + 1) % pCOMM_STACK_DEPTH ;
    rdburstlength[rdburstptr] = 0 ;  //clear burst length counter
    @(posedge dfi_clk) rdburstlength[rdburstptr] = rdburstlength[rdburstptr] + 1 ;  //min burst of 1 cycle
    //$display("AUX :  rdburstlength[rdburstptr] = %d",rdburstlength[rdburstptr]);
    while (ch0_dfi_rddata_en !== {pCH0_RDDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) rdburstlength[rdburstptr] = rdburstlength[rdburstptr] + 1 ;
    enable_ch0_readen_routing = 1'b0 ;
    //$display("[%t] AUX : rdburstptr = %d / rdburstlength[rdburstptr] = %d",$time,rdburstptr,rdburstlength[rdburstptr]);
  end
end

always@(delayed_push_rdenable_stack_1) begin
  if (`GRM.hdr_mode) begin
    case(`GRM.rl[0])
    1'b0 :   repeat ((`GRM.rl - 4)/2)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat ((`GRM.rl - 3)/2)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_rddata_en into the stack
    enable_ch1_readen_routing = 1'b1 ;
    rdburstptr = (rdburstptr + 1) % pCOMM_STACK_DEPTH ;
    rdburstlength[rdburstptr] = 0 ;  //clear burst length counter
    while (ch1_dfi_rddata_en !== {pCH1_RDDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) rdburstlength[rdburstptr] = rdburstlength[rdburstptr] + 1 ;
    enable_ch1_readen_routing = 1'b0 ;   
  end
  else begin //SDR
    case(`GRM.rl[0])
    1'b0 :   repeat (`GRM.rl - 4)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat (`GRM.rl - 3)    @(posedge dfi_clk);  //odd WL
    endcase
    //at this point, route ch0 dfi_wrdata_en and data/mask into the stack
    enable_ch1_readen_routing = 1'b1 ;
    rdburstptr = (rdburstptr + 1) % pCOMM_STACK_DEPTH ;
    rdburstlength[rdburstptr] = 0 ;  //clear burst length counter
    while (ch1_dfi_rddata_en !== {pCH1_RDDATA_EN_WIDTH{1'b0}}) @(posedge dfi_clk) rdburstlength[rdburstptr] = rdburstlength[rdburstptr] + 1 ;
    enable_ch1_readen_routing = 1'b0 ;
  end
end

always@(delayed_pop_rdenable_stack) begin 
  if (`GRM.hdr_mode)
    case(`GRM.rl[0])
    1'b0 :   repeat ((`GRM.rl - 4)/2)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat ((`GRM.rl - 3)/2)    @(posedge dfi_clk);  //odd WL
    endcase
  else  //SDR
    case(`GRM.rl[0])
    1'b0 :   repeat (`GRM.rl - 4)    @(posedge dfi_clk);  //even WL
    1'b1 :   repeat (`GRM.rl - 3)    @(posedge dfi_clk);  //odd WL
    endcase  
  rdburstptr_out = (rdburstptr_out + 1) % pCOMM_STACK_DEPTH ;
  readencntr = 0 ;  
  r_readen_stackisempty = 1'b0 ;
  //$display("[%t] AUX : rdburstptr_out = %d / rdburstlength[rdburstptr_out] = %d",$time,rdburstptr_out,rdburstlength[rdburstptr_out]);
  //$display("[%t] AUX : rdburstptr = %d / rdburstlength[rdburstptr] = %d",$time,rdburstptr,rdburstlength[rdburstptr]);
  if (!enable_ch0_readen_routing) begin // burst already completed
    while (readencntr < rdburstlength[rdburstptr_out]) @(posedge dfi_clk) begin
      readencntr = readencntr + 1 ;
      rde_stack_rdptr = (rde_stack_rdptr + 1) % pDATA_STACK_DEPTH ;
    end
  end
  else begin
    while (enable_ch0_readen_routing) @(posedge dfi_clk) begin
      readencntr = readencntr + 1 ;
      rde_stack_rdptr = (rde_stack_rdptr + 1) % pDATA_STACK_DEPTH ;
    end
    while (readencntr < rdburstlength[rdburstptr_out]) @(posedge dfi_clk) begin
      readencntr = readencntr + 1 ;
      rde_stack_rdptr = (rde_stack_rdptr + 1) % pDATA_STACK_DEPTH ;
    end
  end  
end     

always@(posedge dfi_clk) begin
  if (enable_ch1_readen_routing || enable_ch0_readen_routing)
    rde_stack_wrptr = (rde_stack_wrptr + 1) % pDATA_STACK_DEPTH ;
  if (!r_readen_stackisempty) r_readen_stackisempty  = (rde_stack_rdptr===rde_stack_wrptr) ;
end  
          
endmodule
