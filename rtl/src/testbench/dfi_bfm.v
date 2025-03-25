/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys.                                               *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DFI Configuraiton Bus Functional Model                        *
 *                                                                            *
 *****************************************************************************/

module dfi_bfm
  #(
    // configurable design parameters
    parameter pNO_OF_BYTES     = 9, 
    parameter pNO_OF_RANKS     = 2,
    parameter pCK_WIDTH        = 3,
    parameter pBANK_WIDTH      = 3,
    parameter pBG_WIDTH        = 2,
    parameter pADDR_WIDTH      = 16,
    parameter pCHANNEL_NO  = 0,
    parameter pLPDDRX_EN   = 0,       // LPDDR3/2 support

    parameter pCLK_NX          = `CLK_NX, // PHY clock is 2x or 1x controller clock
    parameter pNO_OF_DX_DQS    = `DWC_DX_NO_OF_DQS, // number of DQS signals per DX macro
    parameter pNUM_LANES       = pNO_OF_DX_DQS * pNO_OF_BYTES,

    // if LPDDR2 mode support is enabled, the DFI address is 20 bits wide
    parameter pXADDR_WIDTH     = pADDR_WIDTH,

    // DDR4: address bits used in C/A parity calculation
    parameter pDDR4_ROW_ADDR_WIDTH = (pADDR_WIDTH < 18) : pADDR_WIDTH : 18,

    parameter pUPPER_RANK_FROM = (pCLK_NX == 1) ? 0 : pNO_OF_RANKS,
    parameter pUPPER_BANK_FROM = (pCLK_NX == 1) ? 0 : pBANK_WIDTH,
    parameter pUPPER_BG_FROM   = (pCLK_NX == 1) ? 0 : pBG_WIDTH,
    parameter pUPPER_ADDR_FROM = (pCLK_NX == 1) ? 0 : pXADDR_WIDTH,
    parameter pUPPER_CMD_BIT   = (pCLK_NX == 1) ? 0 : 1,
    parameter pUPPER_CID_FROM  = (pCLK_NX == 1) ? 0 : `DWC_CID_WIDTH,

    parameter pLOWER_RANK_FROM = 0,
    parameter pLOWER_BANK_FROM = 0,
    parameter pLOWER_BG_FROM   = 0,
    parameter pLOWER_ADDR_FROM = 0,
    parameter pLOWER_CMD_BIT   = 0,
    parameter pLOWER_CID_FROM  = 0,

    // extend MCTL address to avoid index errora
    parameter pMCTL_BANK_WIDTH = 3,
    parameter pMCTL_ADDR_WIDTH = (pADDR_WIDTH > 13) ? pADDR_WIDTH : 14,
    parameter pMCTL_XADDR_WIDTH = pMCTL_ADDR_WIDTH,
    parameter pUPPER_MCTL_BANK_FROM = (pCLK_NX == 1) ? 0 : pMCTL_BANK_WIDTH,
    parameter pUPPER_MCTL_ADDR_FROM = (pCLK_NX == 1) ? 0 : pMCTL_XADDR_WIDTH,

    // random values of outputs
    parameter pDFI_DFLT_VAL    = 0, // no random values - use normal DFI outputs
    parameter pDFI_X_VAL       = 1, // drive X's on DFI outputs
    parameter pDFI_INV_VAL     = 2, // drive inverse of default values
    parameter pDFI_RND_VAL     = 3  // drive random values on DFI outputs
   )
   (
    // interface to global signals
    input  wire                                 rst_b,       // asynchronous reset
    input  wire                                 clk,         // input clock
    input  wire                                 hdr_mode,
    input  wire                                 hdr_odd_cmd,
    input  wire                                 lpddrx_mode,
    output reg  [pCK_WIDTH                -1:0] ck_inv,
    input  wire                                 ddr_2t,      // DDR 2T timing
    input  wire                                 rddata_pending,
                                      
    // CTL Control Interface          
    input  wire                                 ctl_reset_n,
    input  wire [pNO_OF_RANKS*pCLK_NX     -1:0] ctl_cke,
    input  wire [pNO_OF_RANKS*pCLK_NX     -1:0] ctl_odt,
    input  wire [pNO_OF_RANKS*pCLK_NX     -1:0] ctl_cs_n,
    input  wire [`DWC_CID_WIDTH*pCLK_NX   -1:0] ctl_cid,
    input  wire [pCLK_NX                  -1:0] ctl_ras_n,
    input  wire [pCLK_NX                  -1:0] ctl_cas_n,
    input  wire [pCLK_NX                  -1:0] ctl_we_n,
    input  wire [pBANK_WIDTH*pCLK_NX      -1:0] ctl_bank,
    input  wire [pCLK_NX                  -1:0] ctl_act_n,    
    input  wire [pBG_WIDTH*pCLK_NX        -1:0] ctl_bg,
    input  wire [pMCTL_XADDR_WIDTH*pCLK_NX-1:0] ctl_address,
    input  wire [pNO_OF_RANKS             -1:0] ctl_odt_ff,
   
    // CTL Write Data Interface 
    input  wire [pNUM_LANES*pCLK_NX       -1:0] ctl_wrdata_en,
    input  wire [pNO_OF_BYTES*pCLK_NX*16  -1:0] ctl_wrdata,
    input  wire [pNUM_LANES*pCLK_NX*2     -1:0] ctl_wrdata_mask,
                                         
    // CTL Read Data Interface           
    input  wire [pNUM_LANES*pCLK_NX       -1:0] ctl_rddata_en,
    output wire [pNO_OF_BYTES             -1:0] ctl_rddata_valid,
    output wire [pNO_OF_BYTES*pCLK_NX*16  -1:0] ctl_rddata,
                                         
    // CTL Status Interface              
    input  wire                                 ctl_init_complete,
                                         
    // DFI Control Interface             
    output reg                                  dfi_reset_n,
    output reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_cke,
    output reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_odt,
    output reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_cs_n,
    output reg  [`DWC_CID_WIDTH*pCLK_NX   -1:0] dfi_cid,
    output reg  [pCLK_NX                  -1:0] dfi_ras_n,
    output reg  [pCLK_NX                  -1:0] dfi_cas_n,
    output reg  [pCLK_NX                  -1:0] dfi_we_n,
    output reg  [pBANK_WIDTH*pCLK_NX      -1:0] dfi_bank,
    output reg  [pCLK_NX                  -1:0] dfi_act_n,
    output reg  [pBG_WIDTH*pCLK_NX        -1:0] dfi_bg,
    output reg  [pXADDR_WIDTH*pCLK_NX     -1:0] dfi_address,
                                         
    // DFI Write Data Interface          
    output reg  [pNUM_LANES*pCLK_NX       -1:0] dfi_wrdata_en,
    output reg  [pNO_OF_BYTES*pCLK_NX*16  -1:0] dfi_wrdata,
    output reg  [pNUM_LANES*pCLK_NX*2     -1:0] dfi_wrdata_mask,
                                         
    // DFI Read Data Interface           
    output reg  [pNUM_LANES*pCLK_NX       -1:0] dfi_rddata_en,
    input  wire [pNUM_LANES*pCLK_NX       -1:0] dfi_rddata_valid,
    input  wire [pNO_OF_BYTES*pCLK_NX*16  -1:0] dfi_rddata,
  
    // DFI Update Interface
    output reg                                  dfi_ctrlupd_req,
    input  wire                                 dfi_ctrlupd_ack,
    input  wire                                 dfi_phyupd_req,
    output reg                                  dfi_phyupd_ack,
    input  wire [1:0]                           dfi_phyupd_type,
    output reg                                  bdrift_err_rcv,
                                       
    // DFI Status Interface            
    output reg                                  dfi_init_start,
    output reg  [pNO_OF_BYTES             -1:0] dfi_data_byte_disable,
    output reg  [pCK_WIDTH                -1:0] dfi_dram_clk_disable,
    input  wire                                 dfi_init_complete,
    output reg  [pCLK_NX                  -1:0] dfi_parity_in,
    input  wire [pCLK_NX                  -1:0] dfi_alert_n,
                                       
    // DFI Training Interface
    `ifdef DWC_USE_SHARED_AC_TB          
      input  wire [pCLK_NX*pNO_OF_RANKS/2     -1:0] dfi_phylvl_req_cs_n,
      output reg  [pCLK_NX*pNO_OF_RANKS/2     -1:0] dfi_phylvl_ack_cs_n,
    `else          
      input  wire [pCLK_NX*pNO_OF_RANKS       -1:0] dfi_phylvl_req_cs_n,
      output reg  [pCLK_NX*pNO_OF_RANKS       -1:0] dfi_phylvl_ack_cs_n,
    `endif

    input  wire [1:0]                           dfi_rdlvl_mode,
    input  wire [1:0]                           dfi_rdlvl_gate_mode,
    input  wire [1:0]                           dfi_wrlvl_mode,
                                       
    // Low Power Control Interface     
    output reg                                  dfi_lp_data_req,     
    output reg                                  dfi_lp_ctrl_req,     
    output reg  [3                          :0] dfi_lp_wakeup,  
    input  wire                                 dfi_lp_ack
   );

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                                  dfi_reset_n_p0;
  reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_cke_p0;
  reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_odt_p0;
  reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_cs_n_p0;
  reg  [`DWC_CID_WIDTH*pCLK_NX   -1:0] dfi_cid_p0;
  reg  [pCLK_NX                  -1:0] dfi_ras_n_p0;
  reg  [pCLK_NX                  -1:0] dfi_cas_n_p0;
  reg  [pCLK_NX                  -1:0] dfi_we_n_p0;
  reg  [pBANK_WIDTH*pCLK_NX      -1:0] dfi_bank_p0;
  reg  [pCLK_NX                  -1:0] dfi_act_n_p0;
  reg  [pBG_WIDTH*pCLK_NX        -1:0] dfi_bg_p0;
  reg  [pMCTL_XADDR_WIDTH*pCLK_NX-1:0] dfi_address_p0;
  reg  [pNUM_LANES*pCLK_NX       -1:0] dfi_wrdata_en_p0;
  reg  [pNO_OF_BYTES*pCLK_NX*16  -1:0] dfi_wrdata_p0;
  reg  [pNUM_LANES*pCLK_NX*2     -1:0] dfi_wrdata_mask_p0;
  reg  [pNUM_LANES*pCLK_NX       -1:0] dfi_rddata_en_p0;
  reg  [pCK_WIDTH                -1:0] dfi_dram_clk_disable_p0;
                                
  reg                                  dfi_reset_n_p1;
  reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_cke_p1;
  reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_odt_p1;
  reg  [pNO_OF_RANKS*pCLK_NX     -1:0] dfi_cs_n_p1;
  reg  [`DWC_CID_WIDTH*pCLK_NX   -1:0] dfi_cid_p1;
  reg  [pCLK_NX                  -1:0] dfi_ras_n_p1;
  reg  [pCLK_NX                  -1:0] dfi_cas_n_p1;
  reg  [pCLK_NX                  -1:0] dfi_we_n_p1;
  reg  [pBANK_WIDTH*pCLK_NX      -1:0] dfi_bank_p1;
  reg  [pCLK_NX                  -1:0] dfi_act_n_p1;
  reg  [pBG_WIDTH*pCLK_NX        -1:0] dfi_bg_p1;
  reg  [pMCTL_XADDR_WIDTH*pCLK_NX-1:0] dfi_address_p1;
  reg  [pNUM_LANES*pCLK_NX       -1:0] dfi_wrdata_en_p1;
  reg  [pNO_OF_BYTES*pCLK_NX*16  -1:0] dfi_wrdata_p1;
  reg  [pNUM_LANES*pCLK_NX*2     -1:0] dfi_wrdata_mask_p1;
  reg  [pNUM_LANES*pCLK_NX       -1:0] dfi_rddata_en_p1;
  reg  [pCK_WIDTH                -1:0] dfi_dram_clk_disable_p1;
                                
  reg  [pCK_WIDTH                -1:0] dram_clk_disable;
  reg  [pCK_WIDTH                -1:0] dram_clk_invert;
        
  integer                             wait_ctrl_upd_req;
  integer                             ctrl_cnt;
  integer                             ctrl_ack_rcvd;
  integer                             resp_clk;
  integer                             resp_cnt;
  integer                             t_phyupd_type;
  reg                                 req_respd;
  reg                                 dfi_ctrlupd_deassert_nodly;
       
  reg                                 dfi_reset_n_i;  
  wire                                ddr_2t_invalid_cmd;

  reg                                 parity_err;
  reg  [pXADDR_WIDTH*pCLK_NX    -1:0] dfi_address_upper_x_b16t14;
  reg  [pXADDR_WIDTH*pCLK_NX    -1:0] dfi_address_lower_x_b16t14;

  // randomized DFI outputs (for testing independence of test modes from the status
  // of DFI inputs)
  reg                                 dfi_reset_n_rnd;
  reg  [pNO_OF_RANKS*pCLK_NX    -1:0] dfi_cke_rnd;
  reg  [pNO_OF_RANKS*pCLK_NX    -1:0] dfi_odt_rnd;
  reg  [pNO_OF_RANKS*pCLK_NX    -1:0] dfi_cs_n_rnd;
  reg  [`DWC_CID_WIDTH*pCLK_NX  -1:0] dfi_cid_rnd;
  reg  [pCLK_NX                 -1:0] dfi_ras_n_rnd;
  reg  [pCLK_NX                 -1:0] dfi_cas_n_rnd;
  reg  [pCLK_NX                 -1:0] dfi_we_n_rnd;
  reg  [pBANK_WIDTH*pCLK_NX     -1:0] dfi_bank_rnd;
  reg  [pCLK_NX                  -1:0] dfi_act_n_rnd;
  reg  [pBG_WIDTH*pCLK_NX        -1:0] dfi_bg_rnd;
  reg  [pADDR_WIDTH*pCLK_NX     -1:0] dfi_address_rnd;
  reg  [pNUM_LANES*pCLK_NX      -1:0] dfi_wrdata_en_rnd;
  reg  [pNO_OF_BYTES*pCLK_NX*16 -1:0] dfi_wrdata_rnd;
  reg  [pNUM_LANES*pCLK_NX*2    -1:0] dfi_wrdata_mask_rnd;
  reg  [pNUM_LANES*pCLK_NX      -1:0] dfi_rddata_en_rnd;
  reg                                 dfi_ctrlupd_req_rnd;
  reg                                 dfi_phyupd_ack_rnd;
  reg                                 dfi_init_start_rnd;
  reg  [pNO_OF_BYTES            -1:0] dfi_data_byte_disable_rnd;
  reg  [pCK_WIDTH               -1:0] dfi_dram_clk_disable_rnd;
  reg  [pCLK_NX                 -1:0] dfi_parity_in_rnd;
  reg                                 dfi_lp_data_req_rnd;     
  reg                                 dfi_lp_ctrl_req_rnd;     
  reg  [3                         :0] dfi_lp_wakeup_rnd;

  integer                             dfi_rnd_val;
  integer                             t_phyupd_ack_resp;
  real                                cfg2dfi_clk_ratio = `TCLK_PRD/(`CLK_PRD * (2/`CLK_NX));

  integer                             rand_mctl_resp_dly;
  
  wire parity_err_real;
  reg  [pCLK_NX                  -1:0] dfi_parity_in_corr;
  
  //---------------------------------------------------------------------------
  // DFI Control and Write Data Pipeline
  //---------------------------------------------------------------------------
  // since the wrdata_en has to be driven one clock cycle earlier than wrdata,
  // because of how the controller is driving the enable, all other signals
  // have to be pipelined except the wrdata_en
  always @(posedge clk or negedge rst_b)
    begin
      if (rst_b == 1'b0)
        begin
          dfi_cke_p0              <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_odt_p0              <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_cs_n_p0             <= {(pNO_OF_RANKS*pCLK_NX){1'b1}};
          dfi_cid_p0              <= {(`DWC_CID_WIDTH*pCLK_NX){1'b0}};
          dfi_ras_n_p0            <= {pCLK_NX{1'b1}};
          dfi_cas_n_p0            <= {pCLK_NX{1'b1}};
          dfi_we_n_p0             <= {pCLK_NX{1'b1}};
          dfi_bank_p0             <= {(pBANK_WIDTH*pCLK_NX){1'b0}};
          dfi_act_n_p0            <= {pCLK_NX{1'b1}};
          dfi_bg_p0               <= {(pBG_WIDTH*pCLK_NX){1'b0}};
          dfi_address_p0          <= {(pMCTL_XADDR_WIDTH*pCLK_NX){1'b0}};
          dfi_wrdata_p0           <= {(pNO_OF_BYTES*pCLK_NX*16){1'b0}};
          dfi_wrdata_mask_p0      <= {(pNUM_LANES*pCLK_NX*2){1'b0}};
          dfi_dram_clk_disable_p0 <= {pCK_WIDTH{1'b0}};

          dfi_reset_n_p1          <= 1'b1;
          dfi_cke_p1              <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_odt_p1              <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_cs_n_p1             <= {(pNO_OF_RANKS*pCLK_NX){1'b1}};
          dfi_cid_p1              <= {(`DWC_CID_WIDTH*pCLK_NX){1'b0}};
          dfi_ras_n_p1            <= {pCLK_NX{1'b1}};
          dfi_cas_n_p1            <= {pCLK_NX{1'b1}};
          dfi_we_n_p1             <= {pCLK_NX{1'b1}};
          dfi_bank_p1             <= {(pBANK_WIDTH*pCLK_NX){1'b0}};
          dfi_act_n_p1            <= {pCLK_NX{1'b1}};
          dfi_bg_p1               <= {(pBG_WIDTH*pCLK_NX){1'b0}};
          dfi_address_p1          <= {(pMCTL_XADDR_WIDTH*pCLK_NX){1'b0}};
          dfi_wrdata_en_p1        <= {(pNUM_LANES*pCLK_NX){1'b0}};
          dfi_wrdata_p1           <= {(pNO_OF_BYTES*pCLK_NX*16){1'b0}};
          dfi_wrdata_mask_p1      <= {(pNUM_LANES*pCLK_NX*2){1'b0}};
          dfi_rddata_en_p1        <= {(pNUM_LANES*pCLK_NX){1'b0}};
          dfi_dram_clk_disable_p1 <= {pCK_WIDTH{1'b0}};

          ck_inv                  <= {pCK_WIDTH{1'b0}};
        end
      else
        begin
          if (hdr_mode) begin
            dfi_cke_p0              <= ctl_cke;
            dfi_odt_p0              <= ctl_odt;
            dfi_cs_n_p0             <= ctl_cs_n;
            dfi_cid_p0              <= ctl_cid;
            dfi_ras_n_p0            <= ctl_ras_n;
            dfi_cas_n_p0            <= ctl_cas_n;
            dfi_we_n_p0             <= ctl_we_n;
            dfi_bank_p0             <= ctl_bank;
            dfi_act_n_p0            <= ctl_act_n;
            dfi_bg_p0               <= ctl_bg;
            dfi_address_p0          <= ctl_address;
            dfi_wrdata_p0           <= ctl_wrdata;
            dfi_wrdata_mask_p0      <= ctl_wrdata_mask;
            dfi_dram_clk_disable_p0 <= dram_clk_disable;
  
            dfi_reset_n_p1          <= dfi_reset_n_p0;
            dfi_cke_p1              <= dfi_cke_p0;
            dfi_odt_p1              <= dfi_odt_p0;
            dfi_cs_n_p1             <= dfi_cs_n_p0;
            dfi_cid_p1              <= dfi_cid_p0;
            dfi_ras_n_p1            <= dfi_ras_n_p0;
            dfi_cas_n_p1            <= dfi_cas_n_p0;
            dfi_we_n_p1             <= dfi_we_n_p0;
            dfi_bank_p1             <= dfi_bank_p0;
            dfi_act_n_p1            <= dfi_act_n_p0;
            dfi_bg_p1               <= dfi_bg_p0;
            dfi_address_p1          <= dfi_address_p0;
            dfi_wrdata_en_p1        <= dfi_wrdata_en_p0;
            dfi_wrdata_p1           <= dfi_wrdata_p0;
            dfi_wrdata_mask_p1      <= dfi_wrdata_mask_p0;
            dfi_rddata_en_p1        <= dfi_rddata_en_p0;
            dfi_dram_clk_disable_p1 <= dfi_dram_clk_disable_p0;
          end else begin
            dfi_cke_p1              <= ctl_cke;
            dfi_odt_p1              <= (lpddrx_mode) ? {(pNO_OF_RANKS*pCLK_NX){1'b0}} : ctl_odt;
            dfi_cs_n_p1             <= ctl_cs_n;
            dfi_cid_p1              <= ctl_cid;
            dfi_ras_n_p1            <= (lpddrx_mode) ? {pCLK_NX{1'b1}} : ctl_ras_n;
            dfi_cas_n_p1            <= (lpddrx_mode) ? {pCLK_NX{1'b1}} : ctl_cas_n;
            dfi_we_n_p1             <= (lpddrx_mode) ? {pCLK_NX{1'b1}} : ctl_we_n;
            dfi_bank_p1             <= (lpddrx_mode) ? {(pBANK_WIDTH*pCLK_NX){1'b0}} : ctl_bank;
            dfi_act_n_p1            <= (lpddrx_mode) ? {pCLK_NX{1'b1}} : ctl_act_n;
            dfi_bg_p1               <= (lpddrx_mode) ? {(pBG_WIDTH*pCLK_NX){1'b0}} : ctl_bg;
            dfi_address_p1          <= ctl_address;

            dfi_wrdata_p1           <= ctl_wrdata;
            dfi_wrdata_mask_p1      <= ctl_wrdata_mask;
  
            dfi_dram_clk_disable_p1 <= dram_clk_disable;
          end

          ck_inv                    <= dram_clk_invert;
         end
    end
  
  // no pipeline
  always @(*) begin
    if (hdr_mode) begin
      dfi_reset_n_p0       = dfi_reset_n_i;
      dfi_wrdata_en_p0     = `SYS.tc_ac_lb_only ? {(pNUM_LANES*pCLK_NX){1'b0}} : ctl_wrdata_en;
      dfi_rddata_en_p0     = `SYS.tc_ac_lb_only ? {(pNUM_LANES*pCLK_NX){1'b0}} : ctl_rddata_en;
    end else begin
      dfi_reset_n_p0       = dfi_reset_n_i;
      dfi_wrdata_en_p0     = ctl_wrdata_en;
      dfi_rddata_en_p0     = ctl_rddata_en;
      dfi_cke_p0           = ctl_cke;
      dfi_odt_p0           = (lpddrx_mode) ? {(pNO_OF_RANKS*pCLK_NX){1'b0}} : ctl_odt;
      dfi_ras_n_p0         = (lpddrx_mode) ? 1'b1 : ctl_ras_n;
      dfi_cas_n_p0         = (lpddrx_mode) ? 1'b1 : ctl_cas_n;
      dfi_we_n_p0          = (lpddrx_mode) ? 1'b1 : ctl_we_n;
      dfi_bank_p0          = (lpddrx_mode) ? {(pBANK_WIDTH*pCLK_NX){1'b0}} : ctl_bank;
      dfi_act_n_p0         = (lpddrx_mode) ? 1'b1 : ctl_act_n;
      dfi_bg_p0           = (lpddrx_mode) ? {(pBG_WIDTH*pCLK_NX){1'b0}} : ctl_bg;
      dfi_address_p0       = ctl_address;
    end
  end

  // output
  always @(*) begin
    if (dfi_rnd_val) begin
      dfi_reset_n          = 1'b1; //dfi_reset_n_rnd;
      dfi_cke              = dfi_cke_rnd;
      dfi_odt              = dfi_odt_rnd;
      dfi_cs_n             = dfi_cs_n_rnd;
      dfi_cid              = dfi_cid_rnd;
      dfi_ras_n            = dfi_ras_n_rnd;
      dfi_cas_n            = dfi_cas_n_rnd;
      dfi_we_n             = dfi_we_n_rnd;
      dfi_bank             = dfi_bank_rnd;
      dfi_act_n            = dfi_act_n_rnd;
      dfi_bg               = dfi_bg_rnd;
      dfi_address          = dfi_address_rnd;
      dfi_wrdata_en        = dfi_wrdata_en_rnd;
      dfi_wrdata           = dfi_wrdata_rnd;
      dfi_wrdata_mask      = dfi_wrdata_mask_rnd;
      dfi_rddata_en        = dfi_rddata_en_rnd;
      dfi_dram_clk_disable = dfi_dram_clk_disable_rnd;
    end else begin
      // HDR mode
      if (hdr_mode) begin
        dfi_reset_n          = dfi_reset_n_p1;
        dfi_cke              = dfi_cke_p1;
        if (hdr_odd_cmd) begin
          dfi_odt              = (ddr_2t) ? {dfi_odt_p0    [pNO_OF_RANKS-1:0], dfi_odt_p1 [pUPPER_RANK_FROM +: pNO_OF_RANKS]} : dfi_odt_p1;
          dfi_cs_n             = (ddr_2t_invalid_cmd) ? {{pNO_OF_RANKS{1'b1}}, dfi_cs_n_p1[pUPPER_RANK_FROM +: pNO_OF_RANKS]} : dfi_cs_n_p1;
          dfi_cid              = (ddr_2t) ? {dfi_cid_p0    [`DWC_CID_WIDTH-1:0], dfi_cid_p1 [pUPPER_CID_FROM +: `DWC_CID_WIDTH]} : dfi_cid_p1;
          dfi_ras_n            = (ddr_2t) ? {dfi_ras_n_p0  [pUPPER_CMD_BIT],   dfi_ras_n_p1  [pUPPER_CMD_BIT]}                : dfi_ras_n_p1;
          dfi_cas_n            = (ddr_2t) ? {dfi_cas_n_p0  [pUPPER_CMD_BIT],   dfi_cas_n_p1  [pUPPER_CMD_BIT]}                : dfi_cas_n_p1;
          dfi_we_n             = (ddr_2t) ? {dfi_we_n_p0   [pUPPER_CMD_BIT],   dfi_we_n_p1   [pUPPER_CMD_BIT]}                : dfi_we_n_p1;
          dfi_bank             = (ddr_2t) ? {dfi_bank_p0   [pUPPER_BANK_FROM +: pBANK_WIDTH], dfi_bank_p1   [pUPPER_BANK_FROM +: pBANK_WIDTH]} : dfi_bank_p1;
          dfi_address          = (ddr_2t) ? {dfi_address_p0[pUPPER_MCTL_ADDR_FROM +: pXADDR_WIDTH], dfi_address_p1[pUPPER_MCTL_ADDR_FROM +: pXADDR_WIDTH]} : 
                                            {dfi_address_p1[pUPPER_MCTL_ADDR_FROM +: pXADDR_WIDTH], dfi_address_p1[0                     +: pXADDR_WIDTH]};
          dfi_act_n            = (ddr_2t) ? {dfi_act_n_p0  [pUPPER_CMD_BIT],   dfi_act_n_p1  [pUPPER_CMD_BIT]}                : dfi_act_n_p1;
          dfi_bg               = (ddr_2t) ? {dfi_bg_p0     [pUPPER_BG_FROM +: pBG_WIDTH], dfi_bg_p1   [pUPPER_BG_FROM +: pBG_WIDTH]} : dfi_bg_p1;
        end else begin
          dfi_odt              = dfi_odt_p1;
          dfi_cs_n             = (ddr_2t_invalid_cmd) ? {{pNO_OF_RANKS{1'b1}}, dfi_cs_n_p1[pNO_OF_RANKS-1:0]} : dfi_cs_n_p1;
          dfi_cid              = (ddr_2t) ? {dfi_cid_p0    [`DWC_CID_WIDTH-1:0], dfi_cid_p1     [`DWC_CID_WIDTH-1:0]}   : dfi_cid_p1;
          dfi_ras_n            = (ddr_2t) ? {dfi_ras_n_p0  [0],                dfi_ras_n_p1  [0]}               : dfi_ras_n_p1;
          dfi_cas_n            = (ddr_2t) ? {dfi_cas_n_p0  [0],                dfi_cas_n_p1  [0]}               : dfi_cas_n_p1;
          dfi_we_n             = (ddr_2t) ? {dfi_we_n_p0   [0],                dfi_we_n_p1   [0]}               : dfi_we_n_p1;
          dfi_bank             = (ddr_2t) ? {dfi_bank_p0   [pBANK_WIDTH-1:0],  dfi_bank_p1   [pBANK_WIDTH-1:0]} : dfi_bank_p1;
          dfi_address          = (ddr_2t) ? {dfi_address_p0[pXADDR_WIDTH-1:0], dfi_address_p1[pXADDR_WIDTH-1:0]} : 
                                            {dfi_address_p1[pUPPER_MCTL_ADDR_FROM +: pXADDR_WIDTH], dfi_address_p1[0                     +: pXADDR_WIDTH]};
          dfi_act_n            = (ddr_2t) ? {dfi_act_n_p0  [0],                dfi_act_n_p1  [0]}               : dfi_act_n_p1;
          dfi_bg               = (ddr_2t) ? {dfi_bg_p0     [pBG_WIDTH-1:0],    dfi_bg_p1     [pBG_WIDTH-1:0]}   : dfi_bg_p1;
        end
                       
        dfi_wrdata_en        = dfi_wrdata_en_p1;
        dfi_wrdata           = dfi_wrdata_p1;
        dfi_wrdata_mask      = dfi_wrdata_mask_p1;
                     
        dfi_rddata_en        = dfi_rddata_en_p1;
        dfi_dram_clk_disable = dfi_dram_clk_disable_p1;
      end else begin
        // SDR mode
        dfi_reset_n          = dfi_reset_n_p0;
        dfi_cke              = dfi_cke_p1;
        dfi_odt              = dfi_odt_p1;
        dfi_cs_n             = (ddr_2t_invalid_cmd) ? {(pNO_OF_RANKS*pCLK_NX){1'b1}} : dfi_cs_n_p1;
        dfi_cid              = (ddr_2t) ? (dfi_cid_p0     | dfi_cid_p1    ) : dfi_cid_p1;
        dfi_ras_n            = (ddr_2t) ? (dfi_ras_n_p0   & dfi_ras_n_p1  ) : dfi_ras_n_p1;
        dfi_cas_n            = (ddr_2t) ? (dfi_cas_n_p0   & dfi_cas_n_p1  ) : dfi_cas_n_p1;
        dfi_we_n             = (ddr_2t) ? (dfi_we_n_p0    & dfi_we_n_p1   ) : dfi_we_n_p1;
        dfi_bank             = (ddr_2t) ? (dfi_bank_p0    | dfi_bank_p1   ) : dfi_bank_p1;
        dfi_address          = (ddr_2t) ? (dfi_address_p0 | dfi_address_p1) : dfi_address_p1;
        dfi_act_n            = (ddr_2t) ? (dfi_act_n_p0   & dfi_act_n_p1  ) : dfi_act_n_p1;
        dfi_bg               = (ddr_2t) ? (dfi_bg_p0      | dfi_bg_p1     ) : dfi_bg_p1;
        dfi_wrdata_en        = ctl_wrdata_en;
        dfi_wrdata           = ctl_wrdata;
        dfi_wrdata_mask      = ctl_wrdata_mask;
        
        dfi_rddata_en        = dfi_rddata_en_p0;
        dfi_dram_clk_disable = dfi_dram_clk_disable_p1;
      end // else: !if(hdr_mode)
    end // else: !if(dfi_rnd_val)
  end // always @ (*)

   // parity input - Added to calculate tphy_paritylat parameter
  always @(*) begin
    if (parity_err) begin
      if (hdr_mode) begin
        if (`GRM.ddr4_mode) begin
          // In DFI 3.1, bits 16:14 of the address bus are not used in DDR4 mode
          // so they shouldn't be used in the parity calculation either
          dfi_address_upper_x_b16t14        =   dfi_address[pUPPER_ADDR_FROM +: pDDR4_ROW_ADDR_WIDTH];
          dfi_address_upper_x_b16t14[16:14] = 3'd0;
          dfi_address_lower_x_b16t14        =   dfi_address[pLOWER_ADDR_FROM +: pDDR4_ROW_ADDR_WIDTH];
          dfi_address_lower_x_b16t14[16:14] = 3'd0;
          dfi_parity_in_corr = {  (^{  dfi_cid    [pUPPER_CID_FROM  +: `DWC_CID_WIDTH]
                                , dfi_address_upper_x_b16t14
                                , dfi_bg     [pUPPER_BG_FROM   +: pBG_WIDTH]
                                , dfi_bank   [pUPPER_BANK_FROM +: 2]
                                , dfi_act_n  [pUPPER_CMD_BIT]
                                , dfi_ras_n  [pUPPER_CMD_BIT]
                                , dfi_cas_n  [pUPPER_CMD_BIT]
                                , dfi_we_n   [pUPPER_CMD_BIT]
                               }
                             )
                           , (^{  dfi_cid    [pLOWER_CID_FROM  +: `DWC_CID_WIDTH]
                                , dfi_address_lower_x_b16t14
                                , dfi_bg     [pLOWER_BG_FROM   +: pBG_WIDTH]
                                , dfi_bank   [pLOWER_BANK_FROM +: 2]
                                , dfi_act_n  [pLOWER_CMD_BIT]
                                , dfi_ras_n  [pLOWER_CMD_BIT]
                                , dfi_cas_n  [pLOWER_CMD_BIT]
                                , dfi_we_n   [pLOWER_CMD_BIT]
                               }
                             )
                          };
        end
        else begin
          dfi_parity_in_corr = {(^{  dfi_address[pUPPER_ADDR_FROM +: pADDR_WIDTH]
                              , dfi_bg     [pUPPER_BG_FROM   +: pBG_WIDTH]
                              , dfi_bank   [pUPPER_BANK_FROM +: pBANK_WIDTH]
                              , dfi_ras_n  [pUPPER_CMD_BIT]
                              , dfi_cas_n  [pUPPER_CMD_BIT]
                              , dfi_we_n   [pUPPER_CMD_BIT]
                             }
                           )
                           ,
                           (^{  dfi_address[pLOWER_ADDR_FROM +: pADDR_WIDTH]
                              , dfi_bg     [pLOWER_BG_FROM   +: pBG_WIDTH]
                              , dfi_bank   [pLOWER_BANK_FROM +: pBANK_WIDTH]
                              , dfi_ras_n  [pLOWER_CMD_BIT]
                              , dfi_cas_n  [pLOWER_CMD_BIT]
                              , dfi_we_n   [pLOWER_CMD_BIT]
                             }
                           )
                          };
        end
      end else begin
        if (`GRM.ddr4_mode) begin
          dfi_parity_in_corr = ^{dfi_cid, dfi_address[0 +: pDDR4_ROW_ADDR_WIDTH], dfi_bg, dfi_bank[0 +: 2], dfi_act_n, dfi_ras_n, dfi_cas_n,  dfi_we_n};
        end
        else begin
          dfi_parity_in_corr = ^{dfi_address, dfi_bank, dfi_ras_n, dfi_cas_n,  dfi_we_n};
        end
      end
    end
  end
  
  //Detect when a wrong parity bit is sent on dfi_parity_in. This signal is only used for debug
`ifdef MSD_HDR_ODD_CMD
  assign parity_err_real = (!(&dfi_cs_n)) ? ((dfi_parity_in_corr[pUPPER_CMD_BIT] != dfi_parity_in[pUPPER_CMD_BIT]) ? 1'b1 : 1'b0) : 1'bz;
`else
  assign parity_err_real = (!(&dfi_cs_n)) ? ((dfi_parity_in_corr[pLOWER_CMD_BIT] != dfi_parity_in[pLOWER_CMD_BIT]) ? 1'b1 : 1'b0) : 1'bz;
`endif

  // parity input
  always @(*) begin
    if (parity_err) begin
      dfi_parity_in = {pCLK_NX{1'b0}};
    end else begin
      if (hdr_mode) begin
        if (`GRM.ddr4_mode) begin
          // In DFI 3.1, bits 16:14 of the address bus are not used in DDR4 mode
          // so they shouldn't be used in the parity calculation either
          dfi_address_upper_x_b16t14        =   dfi_address[pUPPER_ADDR_FROM +: pDDR4_ROW_ADDR_WIDTH];
          dfi_address_upper_x_b16t14[16:14] = 3'd0;
          dfi_address_lower_x_b16t14        =   dfi_address[pLOWER_ADDR_FROM +: pDDR4_ROW_ADDR_WIDTH];
          dfi_address_lower_x_b16t14[16:14] = 3'd0;
          dfi_parity_in = {  (^{  dfi_cid    [pUPPER_CID_FROM  +: `DWC_CID_WIDTH]
                                , dfi_address_upper_x_b16t14
                                , dfi_bg     [pUPPER_BG_FROM   +: pBG_WIDTH]
                                , dfi_bank   [pUPPER_BANK_FROM +: 2]
                                , dfi_act_n  [pUPPER_CMD_BIT]
                                , dfi_ras_n  [pUPPER_CMD_BIT]
                                , dfi_cas_n  [pUPPER_CMD_BIT]
                                , dfi_we_n   [pUPPER_CMD_BIT]
                               }
                             )
                           , (^{  dfi_cid    [pLOWER_CID_FROM  +: `DWC_CID_WIDTH]
                                , dfi_address_lower_x_b16t14
                                , dfi_bg     [pLOWER_BG_FROM   +: pBG_WIDTH]
                                , dfi_bank   [pLOWER_BANK_FROM +: 2]
                                , dfi_act_n  [pLOWER_CMD_BIT]
                                , dfi_ras_n  [pLOWER_CMD_BIT]
                                , dfi_cas_n  [pLOWER_CMD_BIT]
                                , dfi_we_n   [pLOWER_CMD_BIT]
                               }
                             )
                          };
        end
        else begin
          dfi_parity_in = {(^{  dfi_address[pUPPER_ADDR_FROM +: pADDR_WIDTH]
                              , dfi_bank   [pUPPER_BANK_FROM +: pBANK_WIDTH]
                              , dfi_ras_n  [pUPPER_CMD_BIT]
                              , dfi_cas_n  [pUPPER_CMD_BIT]
                              , dfi_we_n   [pUPPER_CMD_BIT]
                             }
                           )
                           ,
                           (^{  dfi_address[pLOWER_ADDR_FROM +: pADDR_WIDTH]
                              , dfi_bank   [pLOWER_BANK_FROM +: pBANK_WIDTH]
                              , dfi_ras_n  [pLOWER_CMD_BIT]
                              , dfi_cas_n  [pLOWER_CMD_BIT]
                              , dfi_we_n   [pLOWER_CMD_BIT]
                             }
                           )
                          };
        end
      end else begin
        if (`GRM.ddr4_mode) begin
          dfi_parity_in = ^{dfi_cid, dfi_address[0 +: pDDR4_ROW_ADDR_WIDTH], dfi_bg, dfi_bank[0 +: 2], dfi_act_n, dfi_ras_n, dfi_cas_n,  dfi_we_n};
        end
        else begin
          dfi_parity_in = ^{dfi_address, dfi_bank, dfi_ras_n, dfi_cas_n,  dfi_we_n};
        end
      end
    end
  end
  
  // in 2T, only the second clock cycle has a valid command
  assign ddr_2t_invalid_cmd = (lpddrx_mode)  ? 
                              // for LPDDR2/3, look at ca0/ca1/ca2 to determine valid cmd to DRAM
                              ((hdr_odd_cmd) ? 
                                ddr_2t && (~dfi_address_p0[pUPPER_CMD_BIT*pXADDR_WIDTH+0] | ~dfi_address_p0[pUPPER_CMD_BIT*pXADDR_WIDTH+2] | ~dfi_address_p0[pUPPER_CMD_BIT*pXADDR_WIDTH+2]) :
                                ddr_2t && (~dfi_address_p0[0]                             | ~dfi_address_p0[1]                             | ~dfi_address_p0[2])
                              ) :
                              // for DDR3/2, look at ras/cas/we to determine valid cmd to DRAM
                              ((hdr_odd_cmd) ? 
                                ddr_2t && (~dfi_ras_n_p0[pUPPER_CMD_BIT] | ~dfi_cas_n_p0[pUPPER_CMD_BIT] | ~dfi_we_n_p0[pUPPER_CMD_BIT]) :
                                ddr_2t && (~dfi_ras_n_p0[0]              | ~dfi_cas_n_p0[0]              | ~dfi_we_n_p0[0])
                              );


  // initialize defaults
  initial
    begin
      dfi_rnd_val           = pDFI_DFLT_VAL;
      dram_clk_disable      = {pCK_WIDTH{1'b0}};
      dram_clk_invert       = {pCK_WIDTH{1'b0}};
      dfi_ctrlupd_req       = 1'b0;
      wait_ctrl_upd_req     = `t_ctrlupd_min;
      dfi_lp_data_req       = 1'b0;
      dfi_lp_ctrl_req       = 1'b0;
      dfi_lp_wakeup         = {4{1'b0}};
      dfi_init_start        = 1'b1;
      dfi_data_byte_disable = {pNO_OF_BYTES{1'b0}};
      dfi_parity_in         = {pCLK_NX{1'b0}};
      parity_err            = 1'b0;

      // wait for the de-assrtion of dfi_init_complete
      @(posedge dfi_init_complete);
      dfi_init_start        = 1'b0;
    end

  // Request is automatically turn off after wait_ctrl_upd_req cycles
  task ctrl_upd_req;
    begin
      // randomly pick ctrlupd request
      @(posedge clk);
      dfi_ctrlupd_req <= 1'b1;
      `FCOV_REG.set_cov_vt_upd_req_scenario(`CTRL_REQ_VT_UPD);
      dfi_ctrlupd_deassert_nodly = $random;
      if (dfi_ctrlupd_deassert_nodly)
        wait_ctrl_upd_req = 0;
      else
        `SYS.RANDOM_RANGE(`SYS.seed_rr, `t_ctrlupd_min, `t_ctrlupd_max, wait_ctrl_upd_req);
    end
  endtask // mctl_upd_req


  //---------------------------------------------------------------------------
  // DFI CTRL UPD Request
  //---------------------------------------------------------------------------
  always @(posedge clk or rst_b)
    begin
      
      if (!rst_b) begin
        if (dfi_rnd_val == pDFI_DFLT_VAL) dfi_ctrlupd_req <= 1'b0;
        ctrl_cnt       <= 0;
        ctrl_ack_rcvd  <= 0;
      end
      else begin
        if (dfi_ctrlupd_req == 1'b1) begin
          ctrl_cnt  <= ctrl_cnt + 1;

          //  dfi_ctrlupd_ack is deasserted 
          if (dfi_ctrlupd_ack == 1'b0) begin
            
            if (ctrl_ack_rcvd == 1'b0) begin
              // check to see if min time expires
              if (ctrl_cnt > ((`t_ctrlupd_min + `GRM.dsgcr[11:8]) * (2/`CLK_NX))) begin
                // no ack after min time, wait for randomly selected wait to deassert upd_req
                if (ctrl_cnt >= wait_ctrl_upd_req) begin
                  if (dfi_rnd_val == pDFI_DFLT_VAL) dfi_ctrlupd_req <= 1'b0;
                  `FCOV_REG.set_cov_vt_upd_req_scenario(`NO_REQ_VT_UPD);
                  ctrl_cnt        <= 1'b0;
                end
              end
              
              else begin
                // continue to wait for ack when less than or equal to min
              end
            end
            else begin
              // already received ack, ack is now deasserted,
              // turn off dfi_ctrlupd_req when wait is wait_ctrl_upd_req
              if (dfi_ctrlupd_deassert_nodly) begin
                if (dfi_rnd_val == pDFI_DFLT_VAL) dfi_ctrlupd_req <= 1'b0;
                `FCOV_REG.set_cov_vt_upd_req_scenario(`NO_REQ_VT_UPD);
                ctrl_ack_rcvd   <= 1'b0;
                ctrl_cnt        <= 0;
              end
              else if (ctrl_cnt >= wait_ctrl_upd_req) begin
                if (dfi_rnd_val == pDFI_DFLT_VAL) dfi_ctrlupd_req <= 1'b0;
                `FCOV_REG.set_cov_vt_upd_req_scenario(`NO_REQ_VT_UPD);
                ctrl_ack_rcvd   <= 1'b0;
                ctrl_cnt        <= 0;
              end
            end
          end
          
          // dfi_ctrlupd_ack is asserted 
          else begin
            ctrl_ack_rcvd <= 1'b1;
            if (ctrl_cnt >= `t_ctrlupd_max) begin
              if (dfi_rnd_val == pDFI_DFLT_VAL) dfi_ctrlupd_req <= 1'b0;
              `FCOV_REG.set_cov_vt_upd_req_scenario(`NO_REQ_VT_UPD);
              ctrl_ack_rcvd   <= 1'b0;
              ctrl_cnt        <= 0;
            end
          end
        end // if (dfi_ctrlupd_req == 1'b1)
        
        else begin
          // dfi_ctrlupd_req already deasserted, do nothing.. wait for task to assert dfi_ctrlupd_req
          ctrl_cnt        <= 0; 
          ctrl_ack_rcvd   <= 1'b0;
        end // else: !if(dfi_ctrlupd_ack == 1'b0)
        

      end // else: !if(!rst_b)
    end // always @ (posedge clk or rst_b)


  //---------------------------------------------------------------------------
  // DFI PHY UPD Response
  //---------------------------------------------------------------------------

  // Compute how long a PHY update might take (in dfi_clk cycles)
  always @* begin
    t_phyupd_ack_resp = (   t_phyupd_type 
                         + `GRM.dsgcr[11:8] 
                         + `DWC_CDC_SYNC_STAGES + 2
                        );
    // In SDR mode, the PUB is running off dfi_phy_clk, which is 1/2 the speed of ctl_clk
    if (!hdr_mode)
      t_phyupd_ack_resp = t_phyupd_ack_resp * 2;
    // PHYUPD_TYPE1 updates (I/O) occur in the cfg_clk domain
    if (t_phyupd_type == `DFI_PHYUPD_TYPE1)
      t_phyupd_ack_resp = t_phyupd_ack_resp * cfg2dfi_clk_ratio;
  end

  always @(posedge clk or rst_b)
    begin
      if (!rst_b) begin
        if (dfi_rnd_val == pDFI_DFLT_VAL) dfi_phyupd_ack <= 1'b0;
        resp_clk       <= 0;
        resp_cnt       <= 0;
        req_respd      <= 0;
        bdrift_err_rcv <= 1'b0;
      end
      else begin

        if ((dfi_phyupd_req == 1'b1) && (dfi_phyupd_ack == 1'b0) && (req_respd == 1'b0)) begin
          // check for t_phyupd_typeX
          case (dfi_phyupd_type)
            2'b00: t_phyupd_type = `DFI_PHYUPD_TYPE0;
            2'b01: t_phyupd_type = `DFI_PHYUPD_TYPE1;
            2'b10: t_phyupd_type = `DFI_PHYUPD_TYPE2;
            2'b11: t_phyupd_type = `DFI_PHYUPD_TYPE3;
            default: t_phyupd_type = `DFI_PHYUPD_TYPE0;
          endcase // case(dfi_phyupd_type)
          
          `SYS.RANDOM_RANGE(`SYS.seed_rr, 0, `t_phyupd_resp-1, resp_clk);
          repeat (resp_clk) @ (posedge clk);
          
          req_respd       <= 1'b1;
          resp_cnt        <= t_phyupd_ack_resp;
          bdrift_err_rcv  <= 1'b1;
        end
        else if ((dfi_phyupd_req == 1'b1) && (dfi_phyupd_ack == 1'b0) && (req_respd == 1'b1)) begin
          // make sure the controller has received pending reads before asserting ack: 
          // may need to add more condition for this to always happen (TBD)
          dfi_phyupd_ack <= (dfi_rddata_valid == {pNUM_LANES*pCLK_NX{1'b0}} && !rddata_pending) ? 1'b1 : 1'b0;
        end
        else begin
          bdrift_err_rcv  <= dfi_phyupd_req; // make bus idle unti request is de-asserted
          // request stopped, reset both ack and cnt
          if (dfi_phyupd_req == 1'b0) begin
            if (dfi_rnd_val == pDFI_DFLT_VAL)
              dfi_phyupd_ack <= 1'b0;
            req_respd <= 1'b0;
            resp_cnt  <= 0;
          end
          else begin
            // req is asserted and keep track of the ack clocks and
            // reset
            if (resp_cnt == 0) begin
              //if (dfi_rnd_val == pDFI_DFLT_VAL) 
              //  dfi_phyupd_ack <= 1'b0;
              resp_cnt <= resp_cnt;
            end
            else begin
              resp_cnt <= resp_cnt - 1;
            end
          end
        end
        
      end
    end
 
//`ifdef DWC_USE_SHARED_AC_TB
//  // Check for UPDMSTRC0 configuration, and if set,
//  // from the DFI0, force the dfi_phyupd_req in DFI1.
//  always @(posedge dfi_phyupd_req) begin
//    // Only look at channel 0
//    if (pCHANNEL_NO == 0) begin
//      // If UPDMSTRC0 is set, force DFI1.dfi_phyupd_req to be the 
//      // same as channel 0's.
//      if (`GRM.pgcr2[31] == 1'b1) begin
//        force `DFI1.dfi_phyupd_req = dfi_phyupd_req;
//      end
//    end
//  end
//
//  always @(negedge dfi_phyupd_req) begin
//    // Only look at channel 0
//    if (pCHANNEL_NO == 0) begin
//      // If UPDMSTRC0 is set, release DFI1.dfi_phyupd_req from being
//      // same as channel 0's.
//      if (`GRM.pgcr2[31] == 1'b1) begin
//        release `DFI1.dfi_phyupd_req;
//      end
//    end
//  end
//`endif
  
  //---------------------------------------------------------------------------
  // DFI Training in NON-DFI Mode
  //---------------------------------------------------------------------------

  initial begin
    dfi_phylvl_ack_cs_n = {(pNO_OF_RANKS*pCLK_NX){1'b0}};

    // Check protocol is being adhered to when enabled
    `ifdef DWC_DFI_TRAINREQ
      while (1) begin
        wait (|dfi_phylvl_req_cs_n);
        if (!(&dfi_phylvl_req_cs_n)) begin
          `SYS.error;
          $display("-> %0t: [DFI_BFM] ERROR: Expecting all bits of dfi_phylvl_req_cs_n to be asserted but got 0b%b", $time, dfi_phylvl_req_cs_n);
        end
        rand_mctl_resp_dly = {$random} % 256;
        repeat (rand_mctl_resp_dly) @(posedge clk);
        dfi_phylvl_ack_cs_n = {(pNO_OF_RANKS*pCLK_NX){1'b1}};

        wait (!(&dfi_phylvl_req_cs_n));
        if (|dfi_phylvl_req_cs_n) begin
          `SYS.error;
          $display("-> %0t: [DFI_BFM] ERROR: Expecting all bits of dfi_phylvl_req_cs_n to be deasserted but got 0b%b", $time, dfi_phylvl_req_cs_n);
        end
        rand_mctl_resp_dly = {$random} % 16;
        repeat (rand_mctl_resp_dly) @(posedge clk);
        dfi_phylvl_ack_cs_n = {(pNO_OF_RANKS*pCLK_NX){1'b0}};
        repeat (1) @(posedge clk);
      end
    `else
      // Check protocol is not used when it is not meant to be
      wait (|dfi_phylvl_req_cs_n);
      `SYS.error;
      $display("-> %0t: [DFI_BFM] ERROR: PGCR3.TRAINREQ is off but got dfi_phylvl_req_cs_n = 0b%b", $time, dfi_phylvl_req_cs_n);
    `endif
  end

  //---------------------------------------------------------------------------
  // DFI Low Power Control
  //---------------------------------------------------------------------------
  // issues an MC low power opportunity request
  // ***TBD: simple model: put checks for timeouts etc
  task low_power_request;
    input [3:0] lp_wakeup;
    input [31:0] lp_time;
    begin

      // Put DRAM in Self-refresh mode before entering power-down
      `HOST.precharge_all(`ALL_RANKS);
      `HOST.self_refresh(`ALL_RANKS);
      `SYS.nops(`GRM.t_rfc);
      
      @(posedge clk);

      // drive MC request
      dfi_lp_data_req    = 1'b1;
      dfi_lp_ctrl_req    = 1'b1;
      dfi_lp_wakeup = lp_wakeup;

      // wait for PHY acknowledge of the request
      @(posedge dfi_lp_ack);

      // wait the number of clock cycles in power down
      repeat (lp_time) @(posedge clk);

      // de-assert MC request to exit low power
      dfi_lp_data_req    = 1'b0;
      dfi_lp_ctrl_req    = 1'b0;
      dfi_lp_wakeup = {4{1'b0}};

      // wait for PHY to de-assert the acknowledge
      @(negedge dfi_lp_ack);

      // Get DRAM out of Self-refresh mode after exiting power-down
      `HOST.exit_self_refresh(`ALL_RANKS);
      repeat (50) @(posedge clk);

    end
  endtask // low_power_request
// MIKE
//  From Gen2... 
//  task low_power_request;
//    input [3:0] lp_wakeup;
//    input [31:0] lp_time;
//    integer rank_idx;
//    integer i;
//    reg [31:0] pgcr3_tmp;
//    reg [3:0]  pgcr3_lpwakeup_thrsh;
//    begin
//
//      // Read the PGCR3 register and extract the LPWAKEUP_THRSH
//      //`CFG.read_register_data(`PGCR3, pgcr3_tmp);
//      //pgcr3_lpwakeup_thrsh = pgcr3_tmp[31:28];
//
//      // Put DRAM in Self-refresh mode before entering power-down
//      `HOST.precharge_all(`ALL_RANKS);
//
//`ifdef DWC_USE_SHARED_AC_TB
//      // When running with DWC_NO_SRA==1, need to do self_refresh to all banks.
//      // First check to see if this is Ch0 and being the low Power master.
//      // If it is Chn1 but with Ch0 being the master, do not request low power
//      // from Chn1 as the design will ignore low request from Ch 1.
//      if (`GRM.pgcr2[30] == 1'b1 && pCHANNEL_NO == 0) begin
//        if(`DWC_NO_SRA == 0) begin
//          `HOST.self_refresh(`ALL_RANKS);
//        end else begin
//          for(i=0; i<`DWC_NO_OF_RANKS; i=i+1) begin
//            `HOST.self_refresh(i);
//            `HOST.nops(10);
//          end
//        end
//      end else begin
//        for (rank_idx = 0; rank_idx < `DWC_NO_OF_RANKS; rank_idx = rank_idx + 1) begin
//          if (rank_idx%2 == pCHANNEL_NO && pCHANNEL_NO == 0) begin
//            `HOST.precharge_all(rank_idx);
//            `HOST.self_refresh (rank_idx);
//            `HOST.nops(10);
//          end
//          if (rank_idx%2 == pCHANNEL_NO && pCHANNEL_NO == 1) begin
//            `HOST1.precharge_all(rank_idx);
//            `HOST1.self_refresh (rank_idx);
//            `HOST1.nops(10);
//          end
//        end
//      end
//`else
//      if(`DWC_NO_SRA == 0) begin
//        `HOST.self_refresh(`ALL_RANKS);
//      end else begin
//        for(i=0; i<`DWC_NO_OF_RANKS; i=i+1) begin
//          `HOST.self_refresh(i);
//          `HOST.nops(10);
//        end
//      end
//`endif
//
//      `HOST.nops(50);
//
//      @(posedge clk);
//
//      // drive MC request
//      dfi_lp_req    = 1'b1;
//      dfi_lp_wakeup = lp_wakeup;
//
//      // wait for PHY acknowledge of the request only if lpiopd is enabled
//      if (`GRM.dsgcr[3] || `GRM.dsgcr[4]) begin
//        $display("-> %0t: [DFI_BFM%0d] Waiting for dfi_lp_ack to assert", $time, pCHANNEL_NO); 
//        wait (dfi_lp_ack == 1'b1);
//      end
//        // after lifting the low power request, check to see if pll is in powerdown as well
//      if ((`GRM.dsgcr[4] == 1'b1) && (dfi_lp_wakeup > pgcr3_lpwakeup_thrsh)) begin
//          $display("-> %0t: [DFI_BFM%0d] Waiting for `PUB.dfi_pll_pd[%0d] to assert", $time, pCHANNEL_NO, pCHANNEL_NO);
//`ifdef DWC_USE_SHARED_AC_TB
//          wait (`PUB.dfi_pll_pd[pCHANNEL_NO] == 1'b1);
//`elsif DWC_SINGLE_CHANNEL
//          wait (`PUB.dfi_pll_pd[pCHANNEL_NO] == 1'b1);
//`else
//          wait (`PUB.dfi_pll_pd              == 1'b1);
//`endif
//      end
//
//      // wait the number of clock cycles in power down
//      $display("-> %0t: [DFI_BFM%0d] Waiting for lp_time = %0d", $time, pCHANNEL_NO, lp_time);
//      repeat (lp_time) @(posedge clk);
//
//      // de-assert MC request to exit low power
//      $display("-> %0t: [DFI_BFM%0d] Deassert dfi_lp_req to channel ", $time, pCHANNEL_NO);
//      dfi_lp_req    = 1'b0;
//      dfi_lp_wakeup = {4{1'b0}};
//
//      // Wait for PLL LOCK DONE if pll is in powerdown
//      if ((`GRM.dsgcr[4] == 1'b1) && (dfi_lp_wakeup > pgcr3_lpwakeup_thrsh)) begin
//        // For Gen2, there is only 1 PLL lock done bit (`PUB.pll_lock_done), unlike DDR3/2 that has 1 per channel
//        $display("-> %0t: [DFI_BFM%0d] Waiting for `PUB.pll_lock_done[%0d] to assert",$time, pCHANNEL_NO, pCHANNEL_NO);
//        wait (`PUB.pll_lock_done == 1'b1);
//
//        $display("-> %0t: [DFI_BFM%0d] Waiting for `PUB.dfi_pll_pd[%0d] to be deassert",$time, pCHANNEL_NO, pCHANNEL_NO);
//`ifdef DWC_USE_SHARED_AC_TB
//        wait (`PUB.dfi_pll_pd[pCHANNEL_NO] == 1'b0);
//`else
//        wait (`PUB.dfi_pll_pd              == 1'b0);
//`endif
//      end
//
//      // wait for PHY to de-assert the acknowledge
//      $display("-> %0t: [DFI_BFM%0d] Waiting for dfi_lp_ack to deassert... ",$time, pCHANNEL_NO);
//      wait (dfi_lp_ack == 1'b0);
//      $display("-> %0t: [DFI_BFM%0d]             dfi_lp_ack    deasserted  ",$time, pCHANNEL_NO);
//
//      // Get DRAM out of Self-refresh mode after exiting power-down
//`ifdef DWC_USE_SHARED_AC_TB
//      if (`GRM.pgcr2[30] == 1'b1 && pCHANNEL_NO == 0)
//        `HOST.exit_self_refresh(`ALL_RANKS);
//      else begin  
//        for (rank_idx = 0; rank_idx < `DWC_NO_OF_RANKS; rank_idx = rank_idx + 1) begin
//          if (rank_idx%2 == pCHANNEL_NO && pCHANNEL_NO == 0) begin
//            `HOST.exit_self_refresh(rank_idx);
//          end
//          if (rank_idx%2 == pCHANNEL_NO && pCHANNEL_NO == 1) begin
//            `HOST1.exit_self_refresh(rank_idx);
//          end
//        end
//      end
//`else
//      `HOST.exit_self_refresh(`ALL_RANKS);
//`endif
//      repeat (50) @(posedge clk);
//
//    end
//  endtask // low_power_request
//  
  //---------------------------------------------------------------------------
  // DFI Byte Disable
  //---------------------------------------------------------------------------
  // disable/enable CK clocks
  task disable_byte;
    input [3:0] byte_no;
    reg   [pNO_OF_BYTES-1:0] byte_en;
    begin
      byte_en = {pNO_OF_BYTES{1'b1}};
      byte_en[byte_no] = 1'b0;
      enable_bytes(byte_en);
    end
  endtask // disable_byte
  
  task enable_byte;
    input [3:0] byte_no;
    reg   [pNO_OF_BYTES-1:0] byte_en;
    begin
      byte_en = {pNO_OF_BYTES{1'b1}};
      byte_en[byte_no] = 1'b1;
      enable_bytes(byte_en);
    end
  endtask // disable_byte

  task disable_all_bytes;
    begin
      enable_bytes({pNO_OF_BYTES{1'b0}});
    end
  endtask // disable_all_bytes

  task enable_all_bytes;
    begin
      enable_bytes({pNO_OF_BYTES{1'b1}});
    end
  endtask // enable_all_bytes

  task enable_bytes;
    input [pNO_OF_BYTES-1:0] byte_en;
    begin

      // drive the DFI signals
      dfi_data_byte_disable = ~byte_en;

      // enable/disable the bytes in the system so that chips are correctly
      // disconnected and warnigns not issued
      // mike.. have to check this
      `ifndef DWC_USE_SHARED_AC
        `SYS.enable_bytes_ddr_rank_and_grm_mask(byte_en);
      `endif
    end
  endtask // enable_bytes

  
  //---------------------------------------------------------------------------
  // DFI Clock Disable
  //---------------------------------------------------------------------------
  // disable/enable CK clocks
  task disable_dram_clock;
    input [1:0] ck_no;
    begin
      dram_clk_disable[ck_no] = 1'b1;
    end
  endtask // disable_dram_clock

  task enable_dram_clock;
    input [1:0] ck_no;
    begin
      dram_clk_disable[ck_no] = 1'b0;
    end
  endtask // enable_dram_clock

  
  // set/reset whether CK should be inverted or no
  task set_dram_clock_inversion;
    input [1:0] ck_no;
    begin
      dram_clk_invert[ck_no] = 1'b1;
    end
  endtask // set_dram_clock_inversion

  task reset_dram_clock_inversion;
    input [1:0] ck_no;
    begin
      dram_clk_invert[ck_no] = 1'b0;
    end
  endtask // reset_dram_clock_inversion

  
  //---------------------------------------------------------------------------
  // DFI Parity Status
  //---------------------------------------------------------------------------
  // drive parity in
  task drive_parity_in;
    input [pCLK_NX-1:0] par;
    begin
      dfi_parity_in = par;
    end
  endtask // drive_parity_in

  
  //---------------------------------------------------------------------------
  // DFI Reset Pin
  //---------------------------------------------------------------------------
  initial dfi_reset_n_i = 1'b1;
  
  // drive reset pin low
  task drive_reset;
    input rst_val;
    begin
      dfi_reset_n_i = rst_val;
    end
  endtask // drive_reset

  
  //---------------------------------------------------------------------------
  // Random DFI Outputs
  //---------------------------------------------------------------------------
  // generates random values (including X's) on DFI outputs goinf to the PUB
  // to verify that in test modes (BIST, DDL oscillator mode, etc), the values
  // on these signals have no effect on the PUB
  always @(*) begin
    case (dfi_rnd_val)
      pDFI_X_VAL: begin
        // all X's on DFI outputs
        dfi_reset_n_rnd           = {1{1'bx}};
        dfi_cke_rnd               = {(pNO_OF_RANKS*pCLK_NX){1'bx}};
        dfi_odt_rnd               = {(pNO_OF_RANKS*pCLK_NX){1'bx}};
        dfi_cs_n_rnd              = {(pNO_OF_RANKS*pCLK_NX){1'bx}};
        dfi_cid_rnd               = {(`DWC_CID_WIDTH*pCLK_NX){1'bx}};
        dfi_ras_n_rnd             = {pCLK_NX{1'bx}};
        dfi_cas_n_rnd             = {pCLK_NX{1'bx}};
        dfi_we_n_rnd              = {pCLK_NX{1'bx}};
        dfi_bank_rnd              = {(pBANK_WIDTH*pCLK_NX){1'bx}};
        dfi_act_n_rnd             = {pCLK_NX{1'bx}};
        dfi_bg_rnd                = {(pBG_WIDTH*pCLK_NX){1'bx}};
        dfi_address_rnd           = {(pADDR_WIDTH*pCLK_NX){1'bx}};
        dfi_wrdata_en_rnd         = {(pNUM_LANES*pCLK_NX){1'bx}};
        dfi_wrdata_rnd            = {(pNO_OF_BYTES*pCLK_NX*16){1'bx}};
        dfi_wrdata_mask_rnd       = {(pNUM_LANES*pCLK_NX*2){1'bx}};
        dfi_rddata_en_rnd         = {(pNUM_LANES*pCLK_NX){1'bx}};
        dfi_ctrlupd_req_rnd       = {1{1'bx}};
        dfi_phyupd_ack_rnd        = {1{1'bx}};
        dfi_init_start_rnd        = {1{1'bx}};
        dfi_data_byte_disable_rnd = {pNO_OF_BYTES{1'bx}};
        dfi_dram_clk_disable_rnd  = {pCK_WIDTH{1'bx}};
        dfi_parity_in_rnd         = {pCLK_NX{1'bx}};
        dfi_lp_data_req_rnd       = {1{1'bx}};     
        dfi_lp_ctrl_req_rnd       = {1{1'bx}};     
        dfi_lp_wakeup_rnd         = {4{1'bx}};
      end
      pDFI_INV_VAL: begin
        // inverse of the default values on DFI outputs
        dfi_reset_n_rnd           = {1{1'b0}};
        dfi_cke_rnd               = {(pNO_OF_RANKS*pCLK_NX){1'b1}};
        dfi_odt_rnd               = {(pNO_OF_RANKS*pCLK_NX){1'b1}};
        dfi_cs_n_rnd              = {(pNO_OF_RANKS*pCLK_NX){1'b0}};
        dfi_cid_rnd               = {(`DWC_CID_WIDTH*pCLK_NX){1'b1}};
        dfi_ras_n_rnd             = {pCLK_NX{1'b0}};
        dfi_cas_n_rnd             = {pCLK_NX{1'b0}};
        dfi_we_n_rnd              = {pCLK_NX{1'b0}};
        dfi_bank_rnd              = {(pBANK_WIDTH*pCLK_NX){1'b1}};
        dfi_act_n_rnd             = {pCLK_NX{1'b0}};
        dfi_bg_rnd                = {(pBG_WIDTH*pCLK_NX){1'b1}};
        dfi_address_rnd           = {(pADDR_WIDTH*pCLK_NX){1'b1}};
        dfi_wrdata_en_rnd         = {(pNUM_LANES*pCLK_NX){1'b1}};
        dfi_wrdata_rnd            = {(pNO_OF_BYTES*pCLK_NX*16){1'b1}};
        dfi_wrdata_mask_rnd       = {(pNUM_LANES*pCLK_NX*2){1'b1}};
        dfi_rddata_en_rnd         = {(pNUM_LANES*pCLK_NX){1'b1}};
        dfi_ctrlupd_req_rnd       = {1{1'b1}};
        dfi_phyupd_ack_rnd        = {1{1'b1}};
        dfi_init_start_rnd        = {1{1'b0}};
        dfi_data_byte_disable_rnd = {pNO_OF_BYTES{1'b1}};
        dfi_dram_clk_disable_rnd  = {pCK_WIDTH{1'b1}};
        dfi_parity_in_rnd         = {pCLK_NX{1'b1}};
        dfi_lp_data_req_rnd       = {1{1'b1}};     
        dfi_lp_ctrl_req_rnd       = {1{1'b1}};     
        dfi_lp_wakeup_rnd         = {4{1'b1}};
      end
      pDFI_RND_VAL: begin
        // random values on DFI outputs
        dfi_reset_n_rnd           = {$random} % (1 << 1);
        dfi_cke_rnd               = {$random} % (1 << pNO_OF_RANKS*pCLK_NX);
        dfi_odt_rnd               = {$random} % (1 << pNO_OF_RANKS*pCLK_NX);
        dfi_cs_n_rnd              = {$random} % (1 << pNO_OF_RANKS*pCLK_NX);
        dfi_cid_rnd               = {$random} % (1 << `DWC_CID_WIDTH*pCLK_NX);
        dfi_ras_n_rnd             = {$random} % (1 << 1);
        dfi_cas_n_rnd             = {$random} % (1 << 1);
        dfi_we_n_rnd              = {$random} % (1 << 1);
        dfi_bank_rnd              = {$random} % (1 << pBANK_WIDTH*pCLK_NX);
        dfi_act_n_rnd             = {$random} % (1 << 1);
        dfi_bg_rnd                = {$random} % (1 << pBG_WIDTH*pCLK_NX);
        dfi_address_rnd           = {$random} % (1 << pADDR_WIDTH*pCLK_NX);
        dfi_wrdata_en_rnd         = {$random} % (1 << pNUM_LANES*pCLK_NX);
        dfi_wrdata_rnd            = {$random} % (1 << pNO_OF_BYTES*pCLK_NX*16);
        dfi_wrdata_mask_rnd       = {$random} % (1 << pNUM_LANES**pCLK_NX*2);
        dfi_rddata_en_rnd         = {$random} % (1 << pNUM_LANES*pCLK_NX);
        dfi_ctrlupd_req_rnd       = {$random} % (1 << 1);
        dfi_phyupd_ack_rnd        = {$random} % (1 << 1);
        dfi_init_start_rnd        = {$random} % (1 << 1);
        dfi_data_byte_disable_rnd = {$random} % (1 << pNO_OF_BYTES);
        dfi_dram_clk_disable_rnd  = {$random} % (1 << pCK_WIDTH);
        dfi_parity_in_rnd         = {$random} % (1 << pCLK_NX);
        dfi_lp_data_req_rnd       = {$random} % (1 << 1);     
        dfi_lp_ctrl_req_rnd       = {$random} % (1 << 1);     
        dfi_lp_wakeup_rnd         = {$random} % (1 << 4);
      end
    endcase // case (dfi_rnd_type)
  end // always @ (*)


  // set fixed outputs on DFI outpts
  task randomize_dfi_outputs;
    integer dfi_out_type;
    begin
      dfi_out_type = {$random} % 4;
      set_dfi_outputs(dfi_out_type);
    end
  endtask // randomize_dfi_outputs
  
      
  task set_dfi_outputs;
    input [31:0] dfi_out_type;
    begin

      dfi_rnd_val = dfi_out_type;

      // disable DFI monitor if driving fixed/random values
      //if (dfi_rnd_val !== pDFI_DFLT_VAL) begin
      //  `DFI_MNT.dfi_mnt_enable(0);
      //end

      // set the outputs that are not set in the normal always block
      #0.01;
      if (dfi_rnd_val) begin
//        dfi_ctrlupd_req       = dfi_ctrlupd_req_rnd;
//        dfi_phyupd_ack        = dfi_phyupd_ack_rnd;
//        dfi_init_start        = dfi_init_start_rnd;
//        dfi_data_byte_disable = dfi_data_byte_disable_rnd;
//        dfi_parity_in         = dfi_parity_in_rnd;
//        dfi_lp_data_req       = dfi_lp_data_req_rnd;     
//        dfi_lp_ctrl_req       = dfi_lp_ctrl_req_rnd;     
//        dfi_lp_wakeup         = dfi_lp_wakeup_rnd;
      end
      else begin
//        dfi_ctrlupd_req       = 1'b0;
//        dfi_phyupd_ack        = 1'b0;
//        dfi_init_start        = 1'b1;
//        dfi_data_byte_disable = {pNO_OF_BYTES{1'b0}};
//        dfi_parity_in         = {pCLK_NX{1'b0}};
//        dfi_lp_data_req       = 1'b0;     
//        dfi_lp_ctrl_req       = 1'b0;     
//        dfi_lp_wakeup         = {4{1'b0}};
      end
    end
  endtask // set_dfi_outputs
      

endmodule // dfi_bfm

