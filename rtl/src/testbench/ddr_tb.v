/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys. All rights reserved.                          *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Testbench for DDR PHY                                         *
 *                                                                            *
 *****************************************************************************/

`include "dictionary.v"
 
`ifdef SVA
  `include "sva_io.v"
  `include "sva_misc.v"
  `include "sva_clockgating.v"
  //`include "sva_ddrphy_lcdl_byp.v"
`endif

`define DX_PLL_GEN_PATH(DWC_BYTE) `PHY.dx[DWC_BYTE].dx_top.u_DWC_DDRPHYDATX8_top.dx.u_DWC_DDRPHYDATX8.datx8_pll.MIN_REF_PRD

  
module ddr_tb();
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  // width of PHY data signals
  parameter pNO_OF_BYTES    = `DWC_NO_OF_BYTES;    // number of DATX8's
  parameter pNO_OF_RANKS    = `DWC_NO_OF_RANKS;
  parameter pZCTRL_NUM      = `DWC_NO_OF_ZQ;       // number of ZQ calibration controllers
  parameter pCK_WIDTH       = `DWC_CK_WIDTH;
  parameter pBANK_WIDTH     = `DWC_BANK_WIDTH;
  parameter pBG_WIDTH       = `DWC_BG_WIDTH;
  parameter pADDR_WIDTH     = `DWC_ADDR_WIDTH;
  parameter pPHY_ADDR_WIDTH = `DWC_PHY_ADDR_WIDTH;
  parameter pRST_WIDTH      = `DWC_RST_WIDTH;
  parameter pPHY_CID_WIDTH  = `DWC_CID_WIDTH;
  parameter pPHY_BG_WIDTH   = `DWC_PHY_BG_WIDTH;   // DRAM bank group width
  parameter pPHY_BA_WIDTH   = `DWC_PHY_BA_WIDTH;   // DRAM bank width
  parameter pNO_OF_VDDQI    = `DWC_AC_NO_OF_VDDQI +
                              `DWC_DX_NO_OF_VDDQI; // number of VDDQ islands
  parameter pNO_OF_VSSQI    = `DWC_AC_NO_OF_VSSQI +
                              `DWC_DX_NO_OF_VSSQI; // number of VSSQ islands
  parameter pDX_NO_OF_PVREF = ((((`DWC_DX_VREF_USE & 9'h001) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h002) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h004) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h008) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h010) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h020) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h040) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h080) != 9'd0) ? 1 : 0) +
                              (((`DWC_DX_VREF_USE & 9'h100) != 9'd0) ? 1 : 0));
  parameter pAC_NO_OF_PVREF = `DWC_AC_I0_NO_OF_VREF +
                              `DWC_AC_I1_NO_OF_VREF +
                              `DWC_AC_I2_NO_OF_VREF;

`ifdef DDR4
  parameter pBANK_ADDR_WIDTH = pPHY_BG_WIDTH + pPHY_BA_WIDTH;
`else
  parameter pBANK_ADDR_WIDTH = pBANK_WIDTH;
`endif

  parameter pNO_OF_PLL_VDD  = `DWC_NO_OF_PLL_VDD;  // number of PLL VDD/VSS pairs
  parameter pCLK_NX         = `CLK_NX;             // PHY clock is 2x or 1x controller clock
  //parameter pLPDDRX_EN      = `DWC_LPDDRX_EN;
`ifdef LPDDRX
  parameter pLPDDRX_EN      = 1;
`else
  parameter pLPDDRX_EN      = 0;
`endif  

  parameter pDATA_WIDTH     = pNO_OF_BYTES*8;

  parameter pCTL_HDR_MODE_EN    = `DWC_DDRPHY_CHDR_EN ;// 2:1 or 4:1 (SDR/HDR) modes on CTL-DFI
  parameter pMEMCTL_NO_OF_CMDS  = (pCTL_HDR_MODE_EN == 0) ? 1 : 2;  // Num commands per cycle
  parameter pMEMCTL_RESET_WIDTH = (pMEMCTL_NO_OF_CMDS * pRST_WIDTH);

`ifdef DWC_AC_RST_USE
  parameter pRST_USE        = 1;
`else
  parameter pRST_USE        = 0;
`endif
  parameter pNO_OF_DX_DQS   = `DWC_DX_NO_OF_DQS; // number of DQS signals per DX macro
  parameter pNUM_LANES      = pNO_OF_DX_DQS * pNO_OF_BYTES;

  // If LPDDR3/2 mode support is desired, set DWC_ADDR_WIDTH to 20 - DFI address bus is then 20 bits wide
  // For LPDDR2/3 modes only (no DDRn support), set DWC_PHY_ADDR_WIDTH to 10 as well to have the PHY adddress bus (PHY.a) 10 bits wide
  parameter pXADDR_WIDTH    = pADDR_WIDTH;

  // registered DIMM (address/command are pipelined)
  parameter pRDIMM          = `DWC_RDIMM;

  // unbuffered DIMM address mirroring on rank 1
  //parameter pUDIMM          = `DWC_UDIMM;
`ifdef DWC_DDRPHY_TYPEB
  `ifdef DWC_DDRPHY_ACX48
  parameter AC_ATPG_CHAINS            = 13;
  `else
    parameter AC_ATPG_CHAINS          = 12;
  `endif
  `ifdef DWC_DDRPHY_X4X2
    parameter DX_ATPG_CHAINS          = 16*`NO_OF_BYTES;
  `else
    parameter DX_ATPG_CHAINS          = 13*`NO_OF_BYTES;
  `endif
`else
    parameter AC_ATPG_CHAINS          = 13;
    parameter DX_ATPG_CHAINS          = 12*`NO_OF_BYTES;
`endif
`ifdef DWC_DDRPHY_CK
    parameter CK_ATPG_CHAINS          = 4;
`endif
  
`ifdef DWC_DDRPHY_SMODE
  parameter pPHY_SMODE_WIDTH  = `DWC_SMODE_WIDTH;    // PHY special mode width
  parameter pPHY_STATUS_WIDTH = `DWC_STATUS_WIDTH;   // PHY status width
`endif

`ifdef DWC_USE_SHARED_AC_TB
  parameter pNUM_CHANNELS      = 2;
`elsif DWC_SINGLE_CHANNEL
  parameter pNUM_CHANNELS      = 2;
`else
  parameter pNUM_CHANNELS      = ((`DWC_NO_OF_BYTES > 1) && (`DWC_NO_OF_RANKS > 1))? 2 : 1;
`endif


`ifdef DWC_USE_SHARED_AC_TB
  localparam pCHN0_DX8_NUM        = (pNO_OF_BYTES/2  - (pNO_OF_BYTES % 2)/2) 
  ,          pCHN1_DX8_NUM        = (pNO_OF_BYTES    - pCHN0_DX8_NUM)
  ,          pCHN0_DX8_NUM_DXDQS  = pCHN0_DX8_NUM *`DWC_DX_NO_OF_DQS 
  ,          pCHN1_DX8_NUM_DXDQS  = pCHN1_DX8_NUM *`DWC_DX_NO_OF_DQS 
  ,          pCHN0_NO_OF_RANKS    = (pNO_OF_RANKS/2)
  ,          pCHN1_NO_OF_RANKS    = (pNO_OF_RANKS - pCHN0_NO_OF_RANKS)
  ,          pCHN0_DATA_WIDTH     = (pCHN0_DX8_NUM)*8  
  ,          pCHN1_DATA_WIDTH     = (pCHN1_DX8_NUM)*8  
  ,          pCHN0_DX_IDX_LO      = 0
  ,          pCHN0_DX_IDX_HI      = (pCHN0_DX8_NUM_DXDQS - 1)
  ,          pCHN1_DX_IDX_LO      = pCHN0_DX8_NUM_DXDQS     
  ,          pCHN1_DX_IDX_HI      = (pNO_OF_BYTES*`DWC_DX_NO_OF_DQS - 1)
  ;
`else
  localparam pCHN0_DX8_NUM        = pNO_OF_BYTES 
  ,          pCHN0_DX8_NUM_DXDQS  = pNO_OF_BYTES*`DWC_DX_NO_OF_DQS 
  ,          pCHN0_NO_OF_RANKS    = pNO_OF_RANKS
  ,          pCHN0_DATA_WIDTH     = pCHN0_DX8_NUM*8  
  ,          pCHN0_DX_IDX_LO      = 0
  ,          pCHN0_DX_IDX_HI      = (pCHN0_DX8_NUM_DXDQS - 1)
  ,          pCHN1_DX_IDX_LO      = pCHN0_DX_IDX_LO
  ,          pCHN1_DX_IDX_HI      = pCHN0_DX_IDX_HI
  ;
`endif
  
  // data rates for which design is compiled for
  parameter pCDR_EN           = `DWC_DDRPHY_CDR_EN;
  parameter pPSDR_ONLY        = 0; // PHY SDR mode only
  parameter pCSDR_ONLY        = 1; // controller SDR mode only
  parameter pHDR_ONLY         = 2; // HDR mode only
  parameter pHDR_SDR          = 3; // HDR or SDR mode

  parameter pPUB_NO_OF_CMDS   = (pCDR_EN == pPSDR_ONLY || 
                                 pCDR_EN == pCSDR_ONLY) ? 1 : 2;

  parameter pNO_OF_VREFI             = `DWC_AC_NO_OF_VREFI + 
                                         `DWC_DX_NO_OF_VREFI;  // number of VREF islands

  // DIMM parameters
  // ---------------
  // number of CS#/CKE/ODT pins per DIMM
  // NOTE: some of these values may change when we add encode or Quad rank definitions 
  parameter pCSN_PER_DIMM       = `DWC_CS_N_PER_DIMM;
  parameter pCKE_PER_DIMM       = `DWC_CKE_PER_DIMM;
  parameter pODT_PER_DIMM       = `DWC_ODT_PER_DIMM;

  // number of bytes per rank - in sharedAC, half the bytes are on even rank and half on odd ranks
  // others all ranks contain all bytes
  // NOTE: SharedAC iis not valid for RDIMMs
`ifdef DWC_USE_SHARED_AC_TB
  `define DWC_BYTES_PER_RANK    (pCHN0_DX8_NUM + (pNO_OF_BYTES % 2)*(dwc_dim % 2))
`else
  `define DWC_BYTES_PER_RANK    pNO_OF_BYTES
`endif

`ifdef DWC_RDIMM_MIRROR
  parameter pRDIMM_MIRROR       = 1;
`else
  parameter pRDIMM_MIRROR       = 0;
`endif            


parameter pUDIMM_MIRROR       = `DWC_UDIMM;

  
  // indicates RDIMM ranks
`ifdef RDIMM_QUAD_RANK
  `define DWC_RDIMM_RANK
`endif  
`ifdef RDIMM_DUAL_RANK
  `define DWC_RDIMM_RANK
`endif  

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  // supplies
  supply1                      VDD;          // VDD for ITMs, etc.
`ifdef DWC_DDRPHY_D4MV2V5_IO
  supply1                      VSH;
`endif
  supply0                      VSS;          // VSS (common)
  supply1 [pNO_OF_VDDQI-1:0]   VDDQ;         // VDDQ for SSTL
  supply0 [pNO_OF_VSSQI-1:0]   VSSQ;         // VSSQ for SSTL
  supply1 [pAC_NO_OF_PVREF + pDX_NO_OF_PVREF*`DWC_DX_NO_OF_VREF - 1:0] VREFI;        // VREF for SSTL
  supply1                      VREFI_ZQ;     // VREF for SSTL
`ifdef DWC_VREFO_USE
  wire [`DWC_VREFO_USE -1:0]   VREFO;        // VREF output
`endif
  supply1 [pNO_OF_PLL_VDD-1:0] pll_vdd;      // PLL supply
    
  // interface to global signals
  wire                         rst_n;       // asynshronous reset
  wire [`DWC_RST_WIDTH-1:0]    ram_rst_n;      
  wire                         xrst_n;      // extrnal bus asynshronous reset
  wire                         clk;         // input clock
  wire                         xclk;        // input external bus clock
  reg                          ctl_clk;
  wire                         dfi_clk;
  wire                         dfi_phy_clk;
  wire                         ddr_clk;
  wire                         scan_ms;     // scan mode select
  wire [1:0]                   test_mode;   // test mode
  wire                         err;         // general error flag
  wire                         pll_bypass;  // global PLL bypass
  wire [1:0]                   pll_dto;     // PLL digital test output
  wire                         pll_ato;     // PLL analog test output
  
  wire                         hdr_odd_cmd;
  wire                         atpg_mode;          // ATPG Mode
  wire                         atpg_clk;           // ATPG Clock
  wire [1:0]                   dto;
  wire                         ato;
  wire                         phy_init_done;
  wire                         cal_done;
  wire                         pll_init_done;
    
  wire [`DWC_NO_OF_ZQ-1:0]     zq;           // ZQ for SSTL
  wire [`DWC_NO_OF_ZQ-1:0]     zcal_done;    // ZQ calibration done
  
  wire [3             -1:0]    ac_atpg_lu_ctrl;
  wire [pNO_OF_BYTES*3-1:0]    dx_atpg_lu_ctrl;

// Chain are concatenated within each AC and DX  
  wire     cfg_atpg_se;
  wire     cfg_atpg_si;
  wire     cfg_atpg_so;
  wire     ctl_atpg_se;
  wire     ctl_atpg_si;
  wire     ctl_atpg_so; 
  wire     ctl_sdr_atpg_se;
  wire     ctl_sd_ratpg_si;
  wire     ctl_sdr_atpg_so;
  wire     jtag_atpg_se;
  wire     jtag_atpg_si; 
  wire     jtag_atpg_so;

// ONLY FOR GATE level simulation otherwise no pins exist //
`ifdef DWC_DDRPHY_NO_HIER_ATPG_PINS
  `ifdef GATE_LEVEL_SIM
    `ifndef DWC_DDRPHY_ATPG_USE_PHY_PORTS
      `ifdef DWC_DDRPHY_CK
      wire                       ck_atpg_se;
      wire                       ck_atpg_si;
      wire                       ck_atpg_so;
      `endif
      wire                       ac_atpg_se;
      wire                       ac_atpg_si;
      wire                       ac_atpg_so;
      wire [pNO_OF_BYTES-1:0]    dx_atpg_se;
      wire [pNO_OF_BYTES-1:0]    dx_atpg_si;
      wire [pNO_OF_BYTES-1:0]    dx_atpg_so;
    `else
      // no ac_atpg_s* or dx_atpg_s* pins
    `endif
  `else 
    // RTL also no ac_atpg_s* or dx_atpg_s* pins
  `endif
`else
// not DWC_DDRPHY_NO_HIER_ATPG_PINS; both GATE and RTL sim
  `ifdef DWC_DDRPHY_CK
    wire [CK_ATPG_CHAINS-1:0]    ck_atpg_se;
    wire [CK_ATPG_CHAINS-1:0]    ck_atpg_si;
    wire [CK_ATPG_CHAINS-1:0]    ck_atpg_so;
  `endif
    wire [AC_ATPG_CHAINS-1:0]    ac_atpg_se;
    wire [AC_ATPG_CHAINS-1:0]    ac_atpg_si;
    wire [AC_ATPG_CHAINS-1:0]    ac_atpg_so;
    wire [DX_ATPG_CHAINS-1:0]    dx_atpg_se;
    wire [DX_ATPG_CHAINS-1:0]    dx_atpg_si;
    wire [DX_ATPG_CHAINS-1:0]    dx_atpg_so;
`endif

  // interface to configuration port
  wire                         cfg_rst_n;   // configuration asynshronous reset
  wire                         cfg_clk;     // configuration input clock
  wire                         cfg_rqvld;   // configuration request valid
  wire [`REG_CMD_WIDTH-1:0]    cfg_cmd;     // configuration command
  wire [`REG_ADDR_WIDTH-1:0]   cfg_a;       // configuration address
  wire [`REG_DATA_WIDTH-1:0]   cfg_d;       // configuration data input
  wire                         cfg_qvld;    // configuration data output valid
  wire [`REG_DATA_WIDTH-1:0]   cfg_q;       // configuration data output

  // interface with jtag port
  wire                         jtag_en;      // JTAG enable
  wire                         jtag_rqvld;   // JTAG request valid
  wire [`REG_CMD_WIDTH-1:0]    jtag_cmd;     // JTAG command
  wire [`REG_ADDR_WIDTH-1:0]   jtag_a;       // JTAG address
  wire [`REG_DATA_WIDTH-1:0]   jtag_d;       // JTAG data input
  wire                         jtag_qvld;    // JTAG data output valid
  wire [`REG_DATA_WIDTH-1:0]   jtag_q;       // JTAG data output

`ifdef DWC_DDRPHY_SMODE
  reg  [pPHY_SMODE_WIDTH -1:0] phy_smode;
  wire [pPHY_STATUS_WIDTH-1:0] phy_status;
`endif
 
`ifdef DWC_DDRPHY_APB 
  wire                         psel;
  wire                         penable;
  wire                         pwrite;
  wire [`REG_ADDR_WIDTH-1:0]   paddr;
  wire [`REG_DATA_WIDTH-1:0]   pwdata;
  wire [`REG_DATA_WIDTH-1:0]   prdata;
`endif

`ifdef DWC_DDRPHY_JTAG
  wire                         trst_n;
  wire                         tms;
  wire                         tdi;
  wire                         tdo;
`endif

  // interface to host 0 ports (n ports)
  wire                                    host_rqvld_0;    // host ports request valid
  wire [`CMD_WIDTH             -1:0]      host_cmd_0;      // host ports command bus
  wire [`HOST_ADDR_WIDTH       -1:0]      host_a_0;        // host ports address
  wire [pCHN0_DX8_NUM_DXDQS*pCLK_NX*2 -1:0] host_dm_0;       // host ports data mask
  wire [pCHN0_DATA_WIDTH*pCLK_NX*2  -1:0] host_d_0;        // host ports data input
  wire [pCHN0_DATA_WIDTH*pCLK_NX*2  -1:0] host_q_0;        // host ports read data output  
  wire [`CMD_FLAG_WIDTH        -1:0]      host_cmd_flag_0; // host ports command flag
  wire                                    host_rdy_0;      // host ports ready
  wire                                    host_qvld_0;     // host ports read output valid

  // interface to host 0 ports (n ports)
`ifdef DWC_USE_SHARED_AC_TB
  wire                                    host_rqvld_1;    // host ports request valid
  wire [`CMD_WIDTH             -1:0]      host_cmd_1;      // host ports command bus
  wire [`HOST_ADDR_WIDTH       -1:0]      host_a_1;        // host ports address
  wire [pCHN1_DX8_NUM_DXDQS*pCLK_NX*2 -1:0] host_dm_1;       // host ports data mask
  wire [pCHN1_DATA_WIDTH*pCLK_NX*2  -1:0] host_d_1;        // host ports data input
  wire [pCHN1_DATA_WIDTH*pCLK_NX*2  -1:0] host_q_1;        // host ports read data output  
  wire [`CMD_FLAG_WIDTH        -1:0]      host_cmd_flag_1; // host ports command flag
  wire                                    host_rdy_1;      // host ports ready
  wire                                    host_qvld_1;     // host ports read output valid
`endif
  
  // interface to external DDR SDRAMs  
  wire [pCK_WIDTH              -1:0] ck;            // SDRAM clock
  wire [pCK_WIDTH              -1:0] ck_n;          // SDRAM clock #
  wire [`DWC_PHY_CKE_WIDTH     -1:0] cke;           // SDRAM clock enable
  wire [`DWC_PHY_ODT_WIDTH     -1:0] odt;           // SDRAM on-die termination
  wire [`DWC_PHY_CS_N_WIDTH    -1:0] cs_n;          // SDRAM chip select
  wire [`DWC_CID_WIDTH         -1:0] cid;           // SDRAM chip ID
  wire [pPHY_BG_WIDTH          -1:0] bg;            // SDRAM bank group
  wire [pPHY_BA_WIDTH          -1:0] ba;            // SDRAM bank address
  wire [pPHY_ADDR_WIDTH        -1:0] a;             // SDRAM address
  wire                               parity;        // SDRAM parity
  wire                               alert_n;       // SDRAM alert
  wire                               qcsen_n;       // RDIMM quad chip select enable
  wire                               mirror;        // RDIMM mirror
  wire [pNUM_LANES-1:0]              dm;            // SDRAM output data mask
  wire [pNUM_LANES-1:0]              dqs;           // SDRAM input/output data strobe
  wire [pNUM_LANES-1:0]              dqs_n;         // SDRAM input/output data strobe #
  wire [pDATA_WIDTH               -1:0] dq;         // SDRAM input/output data

  wire [pDATA_WIDTH               -1:0] dq_sw;      // SDRAM data switch bus - disconnected when required for bist
  wire [pCK_WIDTH                 -1:0] ck_sw;         // SDRAM clock switch bus - disconnected for oscillator tests and bist
  wire [pCK_WIDTH                 -1:0] ck_n_sw;       // SDRAM clock switch bus - disconnected for oscillator tests and bist

  // DFI global signals
  wire [pCK_WIDTH              -1:0]      ck_inv;
  wire [pCHN0_DX8_NUM          -1:0]      ch0_t_wl_odd;
  wire [pCHN0_DX8_NUM          -1:0]      ch0_t_rl_odd;
`ifdef DWC_USE_SHARED_AC_TB
  wire [pCHN1_DX8_NUM          -1:0]      ch1_t_wl_odd;
  wire [pCHN1_DX8_NUM          -1:0]      ch1_t_rl_odd;
`endif



// dq disconnect
// This is a facility for completely disconnecting the SDRAM/RANK data buses
// when the system task disconnect_sdrams is called.  

  reg data_disc;
  reg ck_disc;
  initial data_disc = 0;
  initial ck_disc = 0;


  generate
    genvar ckw;
    for (ckw=0;ckw<pCK_WIDTH;ckw=ckw+1) begin
      assign ck[ckw] = ck_disc ? 1'b0 : ck_sw[ckw];
      assign ck_n[ckw] = ck_disc ? 1'b1 : ck_n_sw[ckw];
    end  
  endgenerate

  generate
    genvar bb;
    for (bb=0;bb<pDATA_WIDTH;bb=bb+1) begin
      tranif0 (dq_sw[bb],dq[bb],data_disc);
    end 
  endgenerate
  
  // DFI Control Interface 
  wire                                    ch0_dfi_reset_n;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0]      ch0_dfi_cke;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0]      ch0_dfi_odt;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0]      ch0_dfi_cs_n;
  wire [`DWC_CID_WIDTH*pCLK_NX -1:0]      ch0_dfi_cid;
  wire [pCLK_NX                -1:0]      ch0_dfi_act_n;
  wire [pBG_WIDTH*pCLK_NX      -1:0]      ch0_dfi_bg;
  wire [pCLK_NX                -1:0]      ch0_dfi_ras_n;
  wire [pCLK_NX                -1:0]      ch0_dfi_cas_n;
  wire [pCLK_NX                -1:0]      ch0_dfi_we_n;
  wire [pBANK_WIDTH*pCLK_NX    -1:0]      ch0_dfi_bank;
  wire [pXADDR_WIDTH*pCLK_NX   -1:0]      ch0_dfi_address;

  // DFI Write Data Interface
  wire [pCHN0_DX8_NUM_DXDQS*pCLK_NX   -1:0]     ch0_dfi_wrdata_en;
  wire [pCHN0_DX8_NUM      *pCLK_NX*16-1:0]     ch0_dfi_wrdata;
  wire [pCHN0_DX8_NUM_DXDQS*pCLK_NX*2 -1:0]     ch0_dfi_wrdata_mask;

  // DFI Read Data Interface
  wire [pCHN0_DX8_NUM_DXDQS*pCLK_NX   -1:0]     ch0_dfi_rddata_en;
  wire [pCHN0_DX8_NUM_DXDQS*pCLK_NX   -1:0]     ch0_dfi_rddata_valid;
  wire [pCHN0_DX8_NUM      *pCLK_NX*16-1:0]     ch0_dfi_rddata;

  // DFI Update Interface
  wire                                    ch0_dfi_ctrlupd_req;
  wire                                    ch0_dfi_ctrlupd_ack;
  wire                                    ch0_dfi_phyupd_req;
  wire                                    ch0_dfi_phyupd_ack;
  wire [1:0]                              ch0_dfi_phyupd_type;
      
  // DFI Status Interface      
  wire                                    ch0_dfi_init_start;
  wire [pCHN0_DX8_NUM          -1:0]      ch0_dfi_data_byte_disable;
  wire [pCK_WIDTH              -1:0]      ch0_dfi_dram_clk_disable;
  wire                                    ch0_dfi_init_complete;
  wire [pCLK_NX                -1:0]      ch0_dfi_parity_in;
  wire [pCLK_NX                -1:0]      ch0_dfi_alert_n;

  // DFI Training Interface
  wire [1:0]                              ch0_dfi_rdlvl_mode;
  wire [1:0]                              ch0_dfi_rdlvl_gate_mode;
  wire [1:0]                              ch0_dfi_wrlvl_mode;
                                    
  // Low Power Control Interface
  wire                                    ch0_dfi_lp_data_req;     
  wire                                    ch0_dfi_lp_ctrl_req;     
  wire [3:0]                              ch0_dfi_lp_wakeup;  
  wire                                    ch0_dfi_lp_ack;          

`ifdef DWC_USE_SHARED_AC_TB  
  wire                                    ch1_dfi_reset_n;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0]      ch1_dfi_cke;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0]      ch1_dfi_odt;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0]      ch1_dfi_cs_n;
  wire [`DWC_CID_WIDTH*pCLK_NX -1:0]      ch1_dfi_cid;
  wire [pCLK_NX                -1:0]      ch1_dfi_act_n;
  wire [pBG_WIDTH*pCLK_NX      -1:0]      ch1_dfi_bg;
  wire [pCLK_NX                  -1:0]    ch1_dfi_ras_n;
  wire [pCLK_NX                  -1:0]    ch1_dfi_cas_n;
  wire [pCLK_NX                  -1:0]    ch1_dfi_we_n;
  wire [pBANK_WIDTH*pCLK_NX      -1:0]    ch1_dfi_bank;
  wire [pXADDR_WIDTH*pCLK_NX     -1:0]    ch1_dfi_address;

  // DFI Write Data Interface
  wire [pCHN1_DX8_NUM_DXDQS*pCLK_NX   -1:0]     ch1_dfi_wrdata_en;
  wire [pCHN1_DX8_NUM      *pCLK_NX*16-1:0]     ch1_dfi_wrdata;
  wire [pCHN1_DX8_NUM_DXDQS*pCLK_NX*2 -1:0]     ch1_dfi_wrdata_mask;

  // DFI Read Data Interface
  wire [pCHN1_DX8_NUM_DXDQS*pCLK_NX   -1:0]     ch1_dfi_rddata_en;
  wire [pCHN1_DX8_NUM_DXDQS*pCLK_NX   -1:0]     ch1_dfi_rddata_valid;
  wire [pCHN1_DX8_NUM      *pCLK_NX*16-1:0]     ch1_dfi_rddata;

  wire                                    ch1_dfi_ctrlupd_req;
  wire                                    ch1_dfi_ctrlupd_ack;
  wire                                    ch1_dfi_phyupd_req;
  wire                                    ch1_dfi_phyupd_ack;
  wire [1:0]                              ch1_dfi_phyupd_type;

  // DFI Status Interface      
  wire                                    ch1_dfi_init_start;
  wire [pCHN1_DX8_NUM          -1:0]      ch1_dfi_data_byte_disable;
  wire [pCK_WIDTH              -1:0]      ch1_dfi_dram_clk_disable;
  wire                                    ch1_dfi_init_complete;
  wire [pCLK_NX                -1:0]      ch1_dfi_parity_in;
  wire [pCLK_NX                -1:0]      ch1_dfi_alert_n;

  // DFI Training Interface
  wire [1:0]                              ch1_dfi_rdlvl_mode;
  wire [1:0]                              ch1_dfi_rdlvl_gate_mode;
  wire [1:0]                              ch1_dfi_wrlvl_mode;

  // Low Power Control Interface
  wire                                    ch1_dfi_lp_data_req;     
  wire                                    ch1_dfi_lp_ctrl_req;     
  wire [3:0]                              ch1_dfi_lp_wakeup;  
  wire                                    ch1_dfi_lp_ack;          
`endif

  // From Command Interleaver to Chip
  // DFI Control Interface 
`ifdef DWC_USE_SHARED_AC_TB
  wire [pMEMCTL_RESET_WIDTH    -1:0] 	dfi_reset_n;
`else
  wire                               	dfi_reset_n;
`endif
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] 	dfi_cke;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] 	dfi_odt;
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] 	dfi_cs_n;
  wire [`DWC_CID_WIDTH*pCLK_NX -1:0]  dfi_cid;
  wire [pCLK_NX                -1:0]  dfi_act_n;
  wire [pBG_WIDTH*pCLK_NX      -1:0]  dfi_bg;
  wire [pCLK_NX                -1:0] 	dfi_ras_n;
  wire [pCLK_NX                -1:0] 	dfi_cas_n;
  wire [pCLK_NX                -1:0] 	dfi_we_n;
  wire [pBANK_WIDTH*pCLK_NX    -1:0] 	dfi_bank;
  wire [pXADDR_WIDTH*pCLK_NX    -1:0] dfi_address;
                                     			
  // DFI Write Data Interface        			
  wire [(pNUM_LANES*pCLK_NX)   -1:0]  dfi_wrdata_en;
  wire [pNO_OF_BYTES*pCLK_NX*16-1:0]  dfi_wrdata;
  wire [pNUM_LANES*pCLK_NX*2   -1:0]  dfi_wrdata_mask;

  // DFI Read Data Interface
  wire [(pNUM_LANES*pCLK_NX) -1:0]    dfi_rddata_en;
  wire [(pNUM_LANES*pCLK_NX) -1:0]    dfi_rddata_valid;
  wire [pNO_OF_BYTES*pCLK_NX*16-1:0]  dfi_rddata;

  // DFI Update Interface            			
  wire [pNUM_CHANNELS          -1:0]  dfi_ctrlupd_req;
  wire [pNUM_CHANNELS          -1:0]  dfi_ctrlupd_ack;
  wire [pNUM_CHANNELS          -1:0]  dfi_phyupd_req;
  wire [pNUM_CHANNELS          -1:0]  dfi_phyupd_ack;
  wire [(pNUM_CHANNELS * 2)    -1:0]  dfi_phyupd_type;
  
  // DFI Status Interface            			
  wire                               	dfi_init_start;
  wire [pNO_OF_BYTES           -1:0] 	dfi_data_byte_disable;
  wire [pCK_WIDTH              -1:0] 	dfi_dram_clk_disable;
  wire                               	dfi_init_complete;
  wire [pCLK_NX                -1:0] 	dfi_parity_in;
  wire [pCLK_NX                -1:0]  dfi_alert_n;
                                     			
  // DFI Training Interface          			
  wire [1:0]                            dfi_rdlvl_mode;
  wire [1:0]                            dfi_rdlvl_gate_mode;
  wire [1:0]                            dfi_wrlvl_mode;
                                     			
  // Low Power Control Interface     			
  wire [pNUM_CHANNELS              -1:0]  dfi_lp_data_req;
  wire [pNUM_CHANNELS              -1:0]  dfi_lp_ctrl_req;     
  wire [(pNUM_CHANNELS*4)          -1:0]  dfi_lp_wakeup;
  wire [pNUM_CHANNELS              -1:0]  dfi_lp_ack;

`ifdef DWC_IDT
  wire [3:0]                         ck_i;
  wire [3:0]                         ck_n_i;
`else
  wire [pCK_WIDTH              -1:0] ck_i;
  wire [pCK_WIDTH              -1:0] ck_n_i;
`endif
  wire [(`DWC_PHY_CKE_WIDTH+1) -1:0] cke_i;
  wire [(`DWC_PHY_ODT_WIDTH+1) -1:0] odt_i;
  wire [(`DWC_PHY_CS_N_WIDTH+1)-1:0] cs_n_i;
  wire [`DWC_CID_WIDTH         -1:0] cid_i;
  wire                               ras_n_i;
  wire                               cas_n_i;
  wire                               we_n_i;
  wire                               act_n_i;
  wire [pBANK_ADDR_WIDTH       -1:0] ba_i;
  wire [pPHY_ADDR_WIDTH        -1:0] a_i;
  wire [pNUM_LANES  -1:0]            dm_i;
  wire [pNUM_LANES  -1:0]            dmdqs;
  
  wand                               alert_n_i;
  wire                               parity_err;
  wire                               parity_i;
  wire                               mirror_i;
  wire                               qcsen_n_i;

  wire [pPUB_NO_OF_CMDS*pRST_WIDTH     -1:0] pub_dfi_reset_n;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] pub_dfi_cke;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] pub_dfi_odt;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] pub_dfi_cs_n;
  wire [pPUB_NO_OF_CMDS*`DWC_CID_WIDTH -1:0] pub_dfi_cid;
  wire [pPUB_NO_OF_CMDS                -1:0] pub_dfi_act_n;
  wire [pPUB_NO_OF_CMDS*pBG_WIDTH      -1:0] pub_dfi_bg;
  wire [pPUB_NO_OF_CMDS                -1:0] pub_dfi_ras_n;
  wire [pPUB_NO_OF_CMDS                -1:0] pub_dfi_cas_n;
  wire [pPUB_NO_OF_CMDS                -1:0] pub_dfi_we_n;
  wire [pPUB_NO_OF_CMDS*pBANK_WIDTH    -1:0] pub_dfi_bank;
  wire [pPUB_NO_OF_CMDS*pXADDR_WIDTH   -1:0] pub_dfi_address;
  wire [pPUB_NO_OF_CMDS                -1:0] pub_dfi_parity_in;
  wire [pPUB_NO_OF_CMDS*pNUM_LANES     -1:0] pub_dfi_wrdata_en;
  wire [pPUB_NO_OF_CMDS*pNO_OF_BYTES*16-1:0] pub_dfi_wrdata;
  wire [pPUB_NO_OF_CMDS*pNUM_LANES*2   -1:0] pub_dfi_wrdata_mask;
  wire [pPUB_NO_OF_CMDS*pNUM_LANES     -1:0] pub_dfi_rddata_en;
  wire [pPUB_NO_OF_CMDS*pNUM_LANES     -1:0] pub_dfi_rddata_valid;
  wire [pPUB_NO_OF_CMDS*pNO_OF_BYTES*16-1:0] pub_dfi_rddata;
  wire [pNO_OF_BYTES*4                 -1:0] pub_dfi_rddata_dbi_n;
`ifdef DWC_USE_SHARED_AC_TB
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS/2   -1:0] dfi_phylvl_req_cs_n = {(pPUB_NO_OF_CMDS*pNO_OF_RANKS/2){1'b0}};
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS/2   -1:0] dfi_phylvl_ack_cs_n;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS/2   -1:0] ch0_dfi_phylvl_req_cs_n = {(pPUB_NO_OF_CMDS*pNO_OF_RANKS/2){1'b0}};
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS/2   -1:0] ch1_dfi_phylvl_req_cs_n = {(pPUB_NO_OF_CMDS*pNO_OF_RANKS/2){1'b0}};
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS/2   -1:0] ch0_dfi_phylvl_ack_cs_n;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS/2   -1:0] ch1_dfi_phylvl_ack_cs_n;
`else
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] dfi_phylvl_req_cs_n = {(pPUB_NO_OF_CMDS*pNO_OF_RANKS){1'b0}};
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] dfi_phylvl_ack_cs_n;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] ch0_dfi_phylvl_req_cs_n = {(pPUB_NO_OF_CMDS*pNO_OF_RANKS){1'b0}};
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] ch1_dfi_phylvl_req_cs_n = {(pPUB_NO_OF_CMDS*pNO_OF_RANKS){1'b0}};
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] ch0_dfi_phylvl_ack_cs_n;
  wire [pPUB_NO_OF_CMDS*pNO_OF_RANKS   -1:0] ch1_dfi_phylvl_ack_cs_n;
`endif  

  // PHY clock gating pins
  reg                                   phy_ac_ctlclk_gen ; 
  reg                                   phy_ac_ddrclk_gen ; 
  reg                                   phy_ac_rdclk_gen  ; 
  reg [pNO_OF_BYTES               -1:0] phy_dx_ctlclk_gen ; 
  reg [pNO_OF_BYTES               -1:0] phy_dx_ddrclk_gen ; 
  reg [pNO_OF_BYTES               -1:0] phy_dx_rdclk_gen  ; 

  
  
  // ctl_idle added as reg for now. Move inside MCTL later on
  reg                                        ctl_idle;
  wire                                       act_n;
  wire                                       clk_emul;
  wire                                       ctl_sdr_atpg_si;

`ifdef  DWC_DDRPHY_EMUL_XILINX   
  wire                                       refclk_emul;
`endif    

  initial begin
    ctl_idle = 1'b0 ;

    // tie clock gating input pins to 0
    phy_ac_ctlclk_gen = 1'b0;
    phy_ac_ddrclk_gen = 1'b0;
    phy_ac_rdclk_gen  = 1'b0;
    phy_dx_ctlclk_gen = {pNO_OF_BYTES{1'b0}};
    phy_dx_ddrclk_gen = {pNO_OF_BYTES{1'b0}};
    phy_dx_rdclk_gen  = {pNO_OF_BYTES{1'b0}};
  end



  //---------------------------------------------------------------------------
  // DDR Device Under Test (DUT)
  //---------------------------------------------------------------------------
  // includes the DDR Controller and the SSTL I/O Bank; may also optionally
  // include the Memory management Unit (MMU) and the eXternal Bus Interface
  // (XBI)
  // NOTE: controller addresses may be wider than the DDR SDRAM selected
  DWC_DDRPHY_chip ddr_chip
        (
         // interface to global signals
         .rst_n                   (rst_n),
// DDRGEN2MPHY added as per mail from Ohm
// Wed Jan 11 16:00:29 PST 2012
// driven to zero, later will be driven to some logic?
	 
`ifdef  DWC_DDRPHY_EMUL_XILINX   
         .clk_p                   (  dfi_phy_clk  ),
         .clk_n                   ( ~dfi_phy_clk  ),
         .refclk_200MHz_p         (  refclk_emul  ),
         .refclk_200MHz_n         ( ~refclk_emul  ),
`else	 
         .clk                     (dfi_phy_clk),
         .io_ovrd                 (1'b0),
`endif    
 `ifndef  DWC_DDRPHY_EMUL_XILINX   
         .ctl_sdr_clk             ( ctl_clk ),
 `endif
         .ctl_sdr_rst_n           ( rst_n ),
 `ifndef  DWC_DDRPHY_EMUL_XILINX   
         .ddr_clk                 (ddr_clk),
 `endif
 //`ifndef  DWC_DDRPHY_TEST   
         .atpg_mode               (atpg_mode),
         .atpg_clk                (atpg_clk), 

`ifndef  DWC_DDRPHY_TEST   
`ifdef DWC_DDRPHY_SMODE
         .phy_smode               (phy_smode),
         .phy_status              (phy_status),
`endif
 `endif

 `ifndef  DWC_DDRPHY_TEST   
`ifdef DWC_DDRPHY_APB    
         // interface to APB configuration port
         .presetn                 (cfg_rst_n),
         .pclk                    (cfg_clk),
         .psel                    (psel),
         .pwrite                  (pwrite),
         .penable                 (penable),
         .paddr                   (paddr),
         .pwdata                  (pwdata),
         .prdata                  (prdata),
`else    
         // interface to generic configuration port
         .cfg_rst_n               (cfg_rst_n),
         .cfg_clk                 (cfg_clk),
         .cfg_rqvld               (cfg_rqvld),
         .cfg_cmd                 (cfg_cmd),
         .cfg_a                   (cfg_a),
         .cfg_d                   (cfg_d),
         .cfg_qvld                (cfg_qvld),
         .cfg_q                   (cfg_q),
`endif    
`endif    
    
`ifdef DWC_DDRPHY_JTAG    
         // interface to JTAG port
         .trst_n                  (trst_n),
         .tclk                    (xclk),
         .tms                     (tms),
         .tdi                     (tdi),
         .tdo                     (tdo),
`endif

`ifdef DWC_PUB_CLOCK_GATING
         .global_icg_en           ( global_icg_en   ),
         .cfg_icg_en              ( cfg_icg_en      ),
         .init_icg_en             ( init_icg_en     ),
         .train_icg_en            ( train_icg_en    ),
         .bist_icg_en             ( bist_icg_en     ),
         .dcu_icg_en              ( dcu_icg_en      ),
         .sch_icg_en              ( sch_icg_en      ),
         .dfi_icg_en              ( dfi_icg_en      ),
`endif
        
 `ifndef  DWC_DDRPHY_TEST   
         // DFI Control Interface
         .dfi_reset_n             (pub_dfi_reset_n),
         .dfi_cke                 (pub_dfi_cke),
         .dfi_odt                 (pub_dfi_odt),
         .dfi_cs_n                (pub_dfi_cs_n),
`ifdef DWC_NO_OF_3DS_STACKS                                         
         .dfi_cid                 (pub_dfi_cid),
`endif    
         .dfi_act_n               (pub_dfi_act_n),
         .dfi_bg                  (pub_dfi_bg),
         .dfi_ras_n               (pub_dfi_ras_n),
         .dfi_cas_n               (pub_dfi_cas_n),
         .dfi_we_n                (pub_dfi_we_n),
         .dfi_bank                (pub_dfi_bank),
         .dfi_address             (pub_dfi_address),
        
         // DFI Write Data Interface
         .dfi_wrdata_en           (pub_dfi_wrdata_en),
         .dfi_wrdata              (pub_dfi_wrdata),
         
         // temporary widen input to chip as the internals are still double as wide in x4 mode
`ifdef DDR4
  `ifndef DWC_WDBI_DDR4
         .dfi_wrdata_mask         (~pub_dfi_wrdata_mask),  // DDR4 data mask is active low, (LP)DDR3/2 data mask is active high
  `else
         .dfi_wrdata_mask         (pub_dfi_wrdata_mask),   // DDR4 Write DBI enabled; pin used as DBI_n
  `endif
`else
         .dfi_wrdata_mask         (pub_dfi_wrdata_mask),
`endif
         // DFI Read Data Interface
         .dfi_rddata_en           (pub_dfi_rddata_en),
         .dfi_rddata_valid        (pub_dfi_rddata_valid),
         .dfi_rddata              (pub_dfi_rddata ),
         .dfi_rddata_dbi_n        (pub_dfi_rddata_dbi_n),
        
         // DFI Update Interface
         .dfi_ctrlupd_req         (dfi_ctrlupd_req),
         .dfi_ctrlupd_ack         (dfi_ctrlupd_ack),
         .dfi_phyupd_req          (dfi_phyupd_req),
         .dfi_phyupd_ack          (dfi_phyupd_ack),
         .dfi_phyupd_type         (dfi_phyupd_type),
        
         // DFI Status Interface
         .dfi_init_start          (dfi_init_start),
         .dfi_data_byte_disable   (dfi_data_byte_disable),
         .dfi_dram_clk_disable    (dfi_dram_clk_disable),
         .dfi_init_complete       (dfi_init_complete),
         .dfi_parity_in           (pub_dfi_parity_in),
         .dfi_alert_n             (dfi_alert_n),

         // DFI Low Power Control Interface
         .dfi_lp_data_req         (dfi_lp_data_req),
         .dfi_lp_ctrl_req         (dfi_lp_ctrl_req),
         .dfi_lp_wakeup           (dfi_lp_wakeup),
         .dfi_lp_ack              (dfi_lp_ack),
	 
         .ctl_idle              ( ctl_idle              ),
`endif

         // interface to external DDR SDRAMs
`ifdef DWC_AC_RST_USE
         .ram_rst_n               (ram_rst_n),
`endif
         .ck                      (ck_sw),
         .ck_n                    (ck_n_sw),
         .cke                     (cke),
`ifdef DWC_AC_ODT_USE         
         .odt                     (odt),
`endif             
`ifdef DWC_AC_CS_USE         
         .cs_n                    (cs_n),
`endif             
`ifdef DWC_AC_ACT_USE         
         .act_n                   (act_n),
`endif             
`ifdef DWC_NO_OF_3DS_STACKS                                         
         .cid                     (cid),
`endif    
`ifdef DWC_AC_BG_USE         
         .bg                      (bg),
`endif             
`ifdef DWC_AC_BA_USE         
         .ba                      (ba),
`endif             
         .a                       (a),
 `ifdef  DWC_AC_PARITY_USE 
         .parity                  (parity),
 `endif
 `ifdef  DWC_AC_ALERTN_USE 
         .alert_n                 (alert_n),
 `endif
 `ifndef  DWC_DDRPHY_TEST   
`ifdef DWC_AC_QCSEN_USE         
         .qcsen_n                 (qcsen_n),
`endif             
`ifdef DWC_AC_MIRROR_USE         
         .mirror                  (mirror),
`endif             
`endif
         .dm                      (dm_i),    
         .dqs                     (dqs),
         .dqs_n                   (dqs_n),

         .dq                      (dq_sw),

 //`ifndef  DWC_DDRPHY_TEST   
         // interface to ZQ and test signals
         .zq                      (zq),          
`ifdef DWC_PHY_DTO_USE
         .dto                     (dto),
`endif
`ifdef DWC_PHY_ATO_USE    
         .ato                     (ato),
`endif
    
         // interface to AC ATPG mode
         .ac_atpg_lu_ctrl         (ac_atpg_lu_ctrl),
`ifdef DWC_DDRPHY_CK
         .ck_atpg_se              (ck_atpg_se),       
         .ck_atpg_si              (ck_atpg_si),       
         .ck_atpg_so              (ck_atpg_so),
`endif
         .ac_atpg_se              (ac_atpg_se),       
         .ac_atpg_si              (ac_atpg_si),       
         .ac_atpg_so              (ac_atpg_so),
    
         // interface to DATX8 ATPG mode  
         .dx_atpg_lu_ctrl         (dx_atpg_lu_ctrl),       
         .dx_atpg_se              (dx_atpg_se),       
         .dx_atpg_si              (dx_atpg_si),       
         .dx_atpg_so              (dx_atpg_so),
         .phy_ac_ctlclk_gen       ( phy_ac_ctlclk_gen     ), 
         .phy_ac_ddrclk_gen       ( phy_ac_ddrclk_gen     ),
         .phy_ac_rdclk_gen        ( phy_ac_rdclk_gen      ),
         .phy_dx_ctlclk_gen       ( phy_dx_ctlclk_gen     ),
         .phy_dx_ddrclk_gen       ( phy_dx_ddrclk_gen     ),
         .phy_dx_rdclk_gen        ( phy_dx_rdclk_gen      ),

 `ifdef DWC_DDRPHY_TEST 
	     .ctl_atpg_se       (ctl_atpg_se),
	     .ctl_atpg_si       (ctl_atpg_si),
	     .ctl_atpg_so       (ctl_atpg_so),
	     .jtag_atpg_se       (jtag_atpg_se),
	     .jtag_atpg_si       (jtag_atpg_si),
	     .jtag_atpg_so       (jtag_atpg_so),
	     .cfg_atpg_se       (cfg_atpg_se),
	     .cfg_atpg_si       (cfg_atpg_si),
	     .cfg_atpg_so       (cfg_atpg_so),
	     .ctl_sdr_atpg_se       (ctl_sdr_atpg_se),
	     .ctl_sdr_atpg_si       (ctl_sdr_atpg_si),
	     .ctl_sdr_atpg_so       (ctl_sdr_atpg_so),
 `else   
`ifndef DWC_DDRPHY_EMUL_HAPS 
        // Retention signals
        .ret_en                   (1'b1),  // pad-side retention enable (active-low)
        .ret_en_i                 (1'b0),  // core-side retention enable (active-high)
        .ret_en_n_i               (1'b1),  // core-side retention enable (active low)
`endif
`endif

      
	 // supplies    
         .VREFI_ZQ                (VREFI_ZQ),        
         .VREFI                   (VREFI)        
`ifdef DWC_VREFO_USE
         ,
         .VREFO                   (VREFO)        
`endif
`ifdef DWC_DDRPHY_PG_PINS
         ,                                           
         .pll_vdd                 (pll_vdd),
         .VDD                     (VDD),         
  `ifdef DWC_DDRPHY_D4MV2V5_IO
         .VSH                     (VSH),
  `endif
         .VSS                     (VSS),         
         .VDDQ                    (VDDQ),        
         .VSSQ                    (VSSQ)
`endif
         );

  generate
    if (pCDR_EN == pHDR_SDR && `DWC_DDRPHY_SDR_MODE != 2'b00) begin : pub_dfi_buses
      // compiled for HDR/SDR, but running SDR mode - drive upper bits to 0's
      assign pub_dfi_reset_n      = {{(pCLK_NX*pRST_WIDTH     ){1'b1}}, {(pCLK_NX*pRST_WIDTH){dfi_reset_n}}};
      assign pub_dfi_cke          = {{(pCLK_NX*pNO_OF_RANKS   ){1'b0}}, dfi_cke        };
      assign pub_dfi_odt          = {{(pCLK_NX*pNO_OF_RANKS   ){1'b0}}, dfi_odt        };
      assign pub_dfi_cs_n         = {{(pCLK_NX*pNO_OF_RANKS   ){1'b1}}, dfi_cs_n       };
      assign pub_dfi_cid          = {{(pCLK_NX*`DWC_CID_WIDTH ){1'b0}}, dfi_cid        };
      assign pub_dfi_act_n        = {{(pCLK_NX                ){1'b1}}, dfi_act_n      };
      assign pub_dfi_bg           = {{(pCLK_NX*pBG_WIDTH      ){1'b0}}, dfi_bg         };
      assign pub_dfi_ras_n        = {{(pCLK_NX                ){1'b1}}, dfi_ras_n      };
      assign pub_dfi_cas_n        = {{(pCLK_NX                ){1'b1}}, dfi_cas_n      };
      assign pub_dfi_we_n         = {{(pCLK_NX                ){1'b1}}, dfi_we_n       };
      assign pub_dfi_bank         = {{(pCLK_NX*2              ){1'b0}}, dfi_bank       };
      assign pub_dfi_address      = {{(pCLK_NX*pXADDR_WIDTH   ){1'b0}}, dfi_address    };
      assign pub_dfi_parity_in    = {{(pCLK_NX                ){1'b0}}, dfi_parity_in  };
      assign pub_dfi_wrdata_en    = dfi_wrdata_en;
      assign pub_dfi_wrdata       = {{(pCLK_NX*pNO_OF_BYTES*16){1'b0}}, dfi_wrdata     };
      assign pub_dfi_wrdata_mask  = {{(pCLK_NX*pNO_OF_BYTES*2 ){1'b0}}, dfi_wrdata_mask};
      assign pub_dfi_rddata_en    = dfi_rddata_en;

      assign dfi_rddata_valid     = pub_dfi_rddata_valid[pNUM_LANES  -1:0];
      assign dfi_rddata           = data_dbi(pub_dfi_rddata[pPUB_NO_OF_CMDS*pNO_OF_BYTES*16-1:0], pub_dfi_rddata_dbi_n);
    end else begin : pub_dfi_buses
      assign pub_dfi_reset_n      = {(pPUB_NO_OF_CMDS*pRST_WIDTH){dfi_reset_n}};
      assign pub_dfi_cke          = dfi_cke        ;
      assign pub_dfi_odt          = dfi_odt        ;
      assign pub_dfi_cs_n         = dfi_cs_n       ;
      assign pub_dfi_cid          = dfi_cid        ;
      assign pub_dfi_act_n        = dfi_act_n      ;
      assign pub_dfi_bg           = dfi_bg         ;
      assign pub_dfi_ras_n        = dfi_ras_n      ;
      assign pub_dfi_cas_n        = dfi_cas_n      ;
      assign pub_dfi_we_n         = dfi_we_n       ;
      assign pub_dfi_bank         = dfi_bank       ;
      assign pub_dfi_address      = dfi_address    ;
      assign pub_dfi_parity_in    = dfi_parity_in  ;
      assign pub_dfi_wrdata_en    = dfi_wrdata_en  ;
      assign pub_dfi_wrdata       = dfi_wrdata     ;
      assign pub_dfi_wrdata_mask  = dfi_wrdata_mask;
      assign pub_dfi_rddata_en    = dfi_rddata_en  ;

      assign dfi_rddata_valid     = pub_dfi_rddata_valid;
      assign dfi_rddata           = data_dbi(pub_dfi_rddata, pub_dfi_rddata_dbi_n);
    end
  endgenerate


  // temporary assign these values
  assign atpg_clk = (atpg_mode) ? clk : 1'b0; // ATPG clock disabled during mission mode

  // If there is no reset pin then we'll just use the system reset to drive the
  // SDRAM reset
  generate
    if (pRST_USE == 0) begin : dram_rst
      initial begin
        force ram_rst_n = {pRST_WIDTH{1'b0}};
        #200;
        release ram_rst_n;
      end

      assign ram_rst_n = {pRST_WIDTH{rst_n}};
    end
  endgenerate

`ifdef DWC_DDRPHY_SMODE
  initial begin: phy_smode_init
    phy_smode = {pPHY_SMODE_WIDTH{1'b0}};
  end
`endif

`ifdef DWC_PUB_CLOCK_GATING

  assign global_icg_en = 1'b0;
  assign cfg_icg_en = 1'b0;
  assign init_icg_en = 1'b0;
  assign train_icg_en = 1'b0;
  assign bist_icg_en = 1'b0;
  assign dcu_icg_en = 1'b0;
  assign sch_icg_en = 1'b0;
  assign dfi_icg_en = 1'b0;
`endif



   //---------------------------------------------------------------------------
   // board delays and jitter configuration
   //---------------------------------------------------------------------------    
`ifdef DWC_DDRPHY_BOARD_DELAYS
   ddr_board_cfg 
     #(// Parameters
       .pRANK_WIDTH   ( pNO_OF_RANKS ),   // number of ranks
       .pBANK_WIDTH   ( pBANK_WIDTH  ), 
       .pADDR_WIDTH   ( pPHY_ADDR_WIDTH  ),
       .pNO_OF_BYTES  ( pNO_OF_BYTES )
      )
    u_ddr_board_cfg ();
`endif  
  
  
  //---------------------------------------------------------------------------
  // memory Controller
  //---------------------------------------------------------------------------
  // model of the DDR Controller that translates higher-level instructions
  // into low level instructions to the PHY
  // MCTL 0
  ddr_mctl
    #(
      // configurable design parameters
      .pNO_OF_BYTES      ( pCHN0_DX8_NUM     ),
      .pNO_OF_RANKS_CHNL ( pCHN0_NO_OF_RANKS ), 
      .pNO_OF_RANKS      ( pNO_OF_RANKS      ), 
      .pCK_WIDTH         ( pCK_WIDTH         ), 
      .pBANK_WIDTH       ( pBANK_WIDTH       ), 
      .pADDR_WIDTH       ( pADDR_WIDTH       ),
      .pLPDDRX_EN        ( pLPDDRX_EN        ),
      .pCHANNEL_NO       ( 0                 )
      //
      //.pNO_OF_BYTES  ( pNO_OF_BYTES ),
      //.pNO_OF_RANKS  ( pNO_OF_RANKS ), 
      //.pCK_WIDTH     ( pCK_WIDTH    ), 
      //.pBANK_WIDTH   ( pBANK_WIDTH  ), 
      //.pADDR_WIDTH   ( pADDR_WIDTH  )
      )
      ddr_mctl_0
        (
         // interface to global signals
         .rst_b                   (rst_n),
         .clk                     (dfi_clk),
         .hdr_mode                (`GRM.hdr_mode),
         .hdr_odd_cmd             (hdr_odd_cmd_0),
         .ctl_sdram_init          (`SYS.ctl_sdram_init),
            
         // interface to configuration signals
         .burst_len               (`GRM.burst_len),
         .ddr4_mode               (`GRM.ddr4_mode),
         .ddr3_mode               (`GRM.ddr3_mode),
         .ddr2_mode               (`GRM.ddr2_mode),
         .lpddr3_mode             (`GRM.lpddr3_mode),
         .lpddr2_mode             (`GRM.lpddr2_mode),
         .sdram_chip              (`GRM.sdram_chip),
         .ddr3_blotf              (`GRM.ddr3_blotf),
         .ddr_2t                  (`GRM.ddr_2t),
         .t_wl                    (`GRM.t_wl),
         .t_rl                    (`GRM.t_rl),
         .t_ol                    (`GRM.t_ol),
         .t_orwl_odd              (`GRM.t_orwl_odd),
         .t_rl_eq_3               (`GRM.t_rl_eq_3),
         .t_mrd                   (`GRM.t_mrd),
         .t_mod                   (`GRM.t_mod),
         .t_rp                    (`GRM.t_rp),
         .t_rpa                   (`GRM.t_rpa),
         .t_ras                   (`GRM.t_ras),
         .t_rrd                   (`GRM.t_rrd),
         .t_rc                    (`GRM.t_rc),
         .t_faw                   (`GRM.t_faw),
         .t_rfc                   (`GRM.t_rfc),
         .t_bcstab                (`GRM.t_bcstab),
         .t_bcmrd                 (`GRM.t_bcmrd),
         .t_pre2act               (`GRM.t_pre2act),
         .t_act2rw                (`GRM.t_act2rw),
         .t_rd2pre                (`GRM.t_rd2pre),
         .t_wr2pre                (`GRM.t_wr2pre),
         .t_rd2wr                 (`GRM.t_rd2wr),
         .t_wr2rd                 (`GRM.t_wr2rd),
         .t_rdap2act              (`GRM.t_rdap2act),
         .t_wrap2act              (`GRM.t_wrap2act),
         .t_ccd_l                 (`GRM.t_ccd_l),
         .t_ccd_s                 (`GRM.t_ccd_s),
         .rfsh_prd                (`GRM.ctrl_rfsh_prd),
         .rfsh_burst              (`GRM.ctrl_rfsh_burst),
         .rfsh_en                 (`GRM.ctrl_rfsh_en),
            
         // interface to generic host ports (`GRM.n ports)
         .host_rqvld              (host_rqvld_0),
         .host_cmd                (host_cmd_0),
         .host_a                  (host_a_0),
         .host_dm                 (host_dm_0),
         .host_d                  (host_d_0),
         .host_cmd_flag           (host_cmd_flag_0),
         .host_rdy                (host_rdy_0),
         .host_qvld               (host_qvld_0),
         .host_q                  (host_q_0),

         // interface to global signals
         .ck_inv                  (ck_inv),
         .t_byte_wl_odd           (ch0_t_wl_odd),
         .t_byte_rl_odd           (ch0_t_rl_odd),
        
         // DFI Control Interface
         .dfi_reset_n             (ch0_dfi_reset_n),
         .dfi_cke                 (ch0_dfi_cke),
         .dfi_odt                 (ch0_dfi_odt),
         .dfi_cs_n                (ch0_dfi_cs_n),
         .dfi_cid                 (ch0_dfi_cid),
         .dfi_ras_n               (ch0_dfi_ras_n),
         .dfi_cas_n               (ch0_dfi_cas_n),
         .dfi_we_n                (ch0_dfi_we_n),
         .dfi_bank                (ch0_dfi_bank),
         .dfi_address             (ch0_dfi_address),
         .dfi_act_n               (ch0_dfi_act_n),
         .dfi_bg                  (ch0_dfi_bg),
        
         // DFI Write Data Interface
         .dfi_wrdata_en           (ch0_dfi_wrdata_en),
         .dfi_wrdata              (ch0_dfi_wrdata),
         .dfi_wrdata_mask         (ch0_dfi_wrdata_mask),
        
         // DFI Read Data Interface
         .dfi_rddata_en           (ch0_dfi_rddata_en),
         .dfi_rddata_valid        (ch0_dfi_rddata_valid),
         .dfi_rddata              (ch0_dfi_rddata ),
        
         // DFI Update Interface
         .dfi_ctrlupd_req         (ch0_dfi_ctrlupd_req),
         .dfi_ctrlupd_ack         (ch0_dfi_ctrlupd_ack),
         .dfi_phyupd_req          (ch0_dfi_phyupd_req),
         .dfi_phyupd_ack          (ch0_dfi_phyupd_ack),
         .dfi_phyupd_type         (ch0_dfi_phyupd_type),
        
         // DFI Status Interface
         .dfi_init_start          (ch0_dfi_init_start),
         .dfi_data_byte_disable   (ch0_dfi_data_byte_disable),
         .dfi_dram_clk_disable    (ch0_dfi_dram_clk_disable),
         .dfi_init_complete       (ch0_dfi_init_complete),
         .dfi_parity_in           (ch0_dfi_parity_in),
         .dfi_alert_n             (ch0_dfi_alert_n),

         // DFI Training Interface
         .dfi_phylvl_req_cs_n     (ch0_dfi_phylvl_req_cs_n),  /* Not supported */
         .dfi_phylvl_ack_cs_n     (ch0_dfi_phylvl_ack_cs_n),  /*  by the PUB   */

         .dfi_rdlvl_mode          (ch0_dfi_rdlvl_mode),
         .dfi_rdlvl_gate_mode     (ch0_dfi_rdlvl_gate_mode),
         .dfi_wrlvl_mode          (ch0_dfi_wrlvl_mode),
                                                       
         // DFI Low Power Interface
         .dfi_lp_data_req         (ch0_dfi_lp_data_req),
         .dfi_lp_ctrl_req         (ch0_dfi_lp_ctrl_req),
         .dfi_lp_wakeup           (ch0_dfi_lp_wakeup),
         .dfi_lp_ack              (ch0_dfi_lp_ack)
         );

`ifdef DWC_USE_SHARED_AC_TB
  // MCTL 1
  ddr_mctl
    #(
      // configurable design parameters
      .pNO_OF_BYTES      ( pCHN1_DX8_NUM     ),
      .pNO_OF_RANKS_CHNL ( pCHN1_NO_OF_RANKS ), 
      .pNO_OF_RANKS      ( pNO_OF_RANKS      ), 
      .pCK_WIDTH         ( pCK_WIDTH         ), 
      .pBANK_WIDTH       ( pBANK_WIDTH       ), 
      .pADDR_WIDTH       ( pADDR_WIDTH       ),
      .pLPDDRX_EN        ( pLPDDRX_EN        ),
      .pCHANNEL_NO       ( 1                 )
      //
      //.pNO_OF_BYTES  ( pNO_OF_BYTES ),
      //.pNO_OF_RANKS  ( pNO_OF_RANKS ), 
      //.pCK_WIDTH     ( pCK_WIDTH    ), 
      //.pBANK_WIDTH   ( pBANK_WIDTH  ), 
      //.pADDR_WIDTH   ( pADDR_WIDTH  )
      )
      ddr_mctl_1
        (
          // interface to global signals
         .rst_b                   (rst_n),
         .clk                     (dfi_clk),
         .hdr_mode                (`GRM.hdr_mode),
         .hdr_odd_cmd             (hdr_odd_cmd_1),
         .ctl_sdram_init          (`SYS.ctl_sdram_init),
            
         // interface to configuration signals
         .burst_len               (`GRM.burst_len),
         .ddr4_mode               (`GRM.ddr4_mode),
         .ddr3_mode               (`GRM.ddr3_mode),
         .ddr2_mode               (`GRM.ddr2_mode),
         .lpddr3_mode             (`GRM.lpddr3_mode),
         .lpddr2_mode             (`GRM.lpddr2_mode),
         .sdram_chip              (`GRM.sdram_chip),
         .ddr3_blotf              (`GRM.ddr3_blotf),
         .ddr_2t                  (`GRM.ddr_2t),
         .t_wl                    (`GRM.t_wl),
         .t_rl                    (`GRM.t_rl),
         .t_ol                    (`GRM.t_ol),
         .t_orwl_odd              (`GRM.t_orwl_odd),
         .t_rl_eq_3               (`GRM.t_rl_eq_3),
         .t_mrd                   (`GRM.t_mrd),
         .t_mod                   (`GRM.t_mod),
         .t_rp                    (`GRM.t_rp),
         .t_rpa                   (`GRM.t_rpa),
         .t_ras                   (`GRM.t_ras),
         .t_rrd                   (`GRM.t_rrd),
         .t_rc                    (`GRM.t_rc),
         .t_faw                   (`GRM.t_faw),
         .t_rfc                   (`GRM.t_rfc),
         .t_bcstab                (`GRM.t_bcstab),
         .t_bcmrd                 (`GRM.t_bcmrd),
         .t_pre2act               (`GRM.t_pre2act),
         .t_act2rw                (`GRM.t_act2rw),
         .t_rd2pre                (`GRM.t_rd2pre),
         .t_wr2pre                (`GRM.t_wr2pre),
         .t_rd2wr                 (`GRM.t_rd2wr),
         .t_wr2rd                 (`GRM.t_wr2rd),
         .t_rdap2act              (`GRM.t_rdap2act),
         .t_wrap2act              (`GRM.t_wrap2act),
         .t_ccd_l                 (`GRM.t_ccd_l),
         .t_ccd_s                 (`GRM.t_ccd_s),
         .rfsh_prd                (`GRM.ctrl_rfsh_prd),
         .rfsh_burst              (`GRM.ctrl_rfsh_burst),
         .rfsh_en                 (`GRM.ctrl_rfsh_en),
            
         // interface to generic host ports (`GRM.n ports)
         .host_rqvld              (host_rqvld_1),
         .host_cmd                (host_cmd_1),
         .host_a                  (host_a_1),
         .host_dm                 (host_dm_1),
         .host_d                  (host_d_1),
         .host_cmd_flag           (host_cmd_flag_1),
         .host_rdy                (host_rdy_1),
         .host_qvld               (host_qvld_1),
         .host_q                  (host_q_1),

         // interface to global signals
         .ck_inv                  (ck_inv),
         .t_byte_wl_odd           (ch1_t_wl_odd),
         .t_byte_rl_odd           (ch1_t_rl_odd),
        
         // DFI Control Interface
         .dfi_reset_n             (ch1_dfi_reset_n),
         .dfi_cke                 (ch1_dfi_cke),
         .dfi_odt                 (ch1_dfi_odt),
         .dfi_cs_n                (ch1_dfi_cs_n),
         .dfi_cid                 (ch1_dfi_cid),
         .dfi_ras_n               (ch1_dfi_ras_n),
         .dfi_cas_n               (ch1_dfi_cas_n),
         .dfi_we_n                (ch1_dfi_we_n),
         .dfi_bank                (ch1_dfi_bank),
         .dfi_address             (ch1_dfi_address),
         .dfi_act_n               (ch1_dfi_act_n),
         .dfi_bg                  (ch1_dfi_bg),
        
         // DFI Write Data Interface
         .dfi_wrdata_en           (ch1_dfi_wrdata_en),
         .dfi_wrdata              (ch1_dfi_wrdata),
         .dfi_wrdata_mask         (ch1_dfi_wrdata_mask),
        
         // DFI Read Data Interface
         .dfi_rddata_en           (ch1_dfi_rddata_en),
         .dfi_rddata_valid        (ch1_dfi_rddata_valid),
         .dfi_rddata              (ch1_dfi_rddata ),
        
         // DFI Update Interface
         .dfi_ctrlupd_req         (ch1_dfi_ctrlupd_req),
         .dfi_ctrlupd_ack         (ch1_dfi_ctrlupd_ack),
         .dfi_phyupd_req          (ch1_dfi_phyupd_req),
         .dfi_phyupd_ack          (ch1_dfi_phyupd_ack),
         .dfi_phyupd_type         (ch1_dfi_phyupd_type),
        
         // DFI Status Interface
         .dfi_init_start          (ch1_dfi_init_start),
         .dfi_data_byte_disable   (ch1_dfi_data_byte_disable),
         .dfi_dram_clk_disable    (ch1_dfi_dram_clk_disable),
         .dfi_init_complete       (ch1_dfi_init_complete),
         .dfi_parity_in           (ch1_dfi_parity_in),
         .dfi_alert_n             (ch1_dfi_alert_n),

         // DFI Training Interface
         .dfi_phylvl_req_cs_n     (ch1_dfi_phylvl_req_cs_n),  /* Not supported */
         .dfi_phylvl_ack_cs_n     (ch1_dfi_phylvl_ack_cs_n),  /*  by the PUB   */

         .dfi_rdlvl_mode          (ch1_dfi_rdlvl_mode),
         .dfi_rdlvl_gate_mode     (ch1_dfi_rdlvl_gate_mode),
         .dfi_wrlvl_mode          (ch1_dfi_wrlvl_mode),
                                                       
         // DFI Low Power Interface
         .dfi_lp_data_req         (ch1_dfi_lp_data_req),
         .dfi_lp_ctrl_req         (ch1_dfi_lp_ctrl_req),
         .dfi_lp_wakeup           (ch1_dfi_lp_wakeup),
         .dfi_lp_ack              (ch1_dfi_lp_ack)
         );
`endif //  `ifdef DWC_USE_SHARED_AC_TB
  
  //---------------------------------------------------------------------------
  // Command Interleaver
  //---------------------------------------------------------------------------
`ifdef DWC_USE_SHARED_AC_TB
  shrd_ac_intlvr 
    #(
      .pNO_OF_BYTES               ( pNO_OF_BYTES ),      
      .pNO_OF_RANKS               ( pNO_OF_RANKS ),
      .pCK_WIDTH                  ( pCK_WIDTH    ),
      .pBANK_WIDTH                ( pBANK_WIDTH  ),
      .pADDR_WIDTH                ( pADDR_WIDTH  ), 
      .pRST_WIDTH                 ( pRST_WIDTH   ),
      //.pHDR_MODE_EN               ( pHDR_MODE_EN ),
`ifdef DWC_DDRPHY_HDR_MODE      
      .pINTERLEAVER_TYPE          ( 1            )
`else
      // for sdr mode temporary
      .pINTERLEAVER_TYPE          ( 2            )
`endif      
    )
    shrd_ac_intlvr 
      (
        .dfi_clk                         (dfi_clk                    ),
		    // DFI Control Interface
		    .ch0_dfi_reset_n                 ({pMEMCTL_RESET_WIDTH{ch0_dfi_reset_n}}),     
		    .ch0_dfi_cke                     (ch0_dfi_cke 						 	 ),     
		    .ch0_dfi_odt                     (ch0_dfi_odt 							 ),     
		    .ch0_dfi_cs_n                    (ch0_dfi_cs_n							 ),     
		    .ch0_dfi_cid                     (ch0_dfi_cid 						 	 ),     
		    .ch0_dfi_ras_n                   (ch0_dfi_ras_n              ),     
		    .ch0_dfi_cas_n                   (ch0_dfi_cas_n              ),     
		    .ch0_dfi_we_n                    (ch0_dfi_we_n               ),     
		    .ch0_dfi_bank                    (ch0_dfi_bank               ),     
		    .ch0_dfi_address                 (ch0_dfi_address            ),     
        .ch0_dfi_act_n                   (ch0_dfi_act_n),
        .ch0_dfi_bg                      (ch0_dfi_bg),
		    // DFI Write Data Interface
		    .ch0_dfi_wrdata_en               (ch0_dfi_wrdata_en          ),     
		    .ch0_dfi_wrdata                  (ch0_dfi_wrdata             ),     
		    .ch0_dfi_wrdata_mask             (ch0_dfi_wrdata_mask        ),     
		    // DFI Read Data Interface
		    .ch0_dfi_rddata_en               (ch0_dfi_rddata_en          ),     
		    .ch0_dfi_rddata_valid            (ch0_dfi_rddata_valid       ),     
		    .ch0_dfi_rddata                  (ch0_dfi_rddata             ),     
		    // DFI Update Interface
		    .ch0_dfi_ctrlupd_req             (ch0_dfi_ctrlupd_req        ),     
		    .ch0_dfi_ctrlupd_ack             (ch0_dfi_ctrlupd_ack        ),     
		    .ch0_dfi_phyupd_req              (ch0_dfi_phyupd_req         ),     
		    .ch0_dfi_phyupd_ack              (ch0_dfi_phyupd_ack         ),     
		    .ch0_dfi_phyupd_type             (ch0_dfi_phyupd_type        ),     
		    // DFI Status Interface
		    .ch0_dfi_init_start              (ch0_dfi_init_start         ),     
		    .ch0_dfi_data_byte_disable       (ch0_dfi_data_byte_disable  ),
		    .ch0_dfi_dram_clk_disable        (ch0_dfi_dram_clk_disable   ),     
		    .ch0_dfi_init_complete           (ch0_dfi_init_complete      ),     
		    .ch0_dfi_parity_in               (ch0_dfi_parity_in          ),     
        .ch0_dfi_alert_n                 (ch0_dfi_alert_n            ),
		    // DFI Training Interface
        .ch0_dfi_phylvl_req_cs_n         (ch0_dfi_phylvl_req_cs_n    ),  /* Not supported */
        .ch0_dfi_phylvl_ack_cs_n         (ch0_dfi_phylvl_ack_cs_n    ),  /*  by the PUB   */

		    .ch0_dfi_rdlvl_mode              (ch0_dfi_rdlvl_mode         ),     
		    .ch0_dfi_rdlvl_gate_mode         (ch0_dfi_rdlvl_gate_mode    ),     
		    .ch0_dfi_wrlvl_mode              (ch0_dfi_wrlvl_mode         ),     
		    // Low Power Control Interface
		    .ch0_dfi_lp_data_req             (ch0_dfi_lp_data_req        ),     
        .ch0_dfi_lp_ctrl_req             (ch0_dfi_lp_ctrl_req        ),
		    .ch0_dfi_lp_wakeup               (ch0_dfi_lp_wakeup          ),     
		    .ch0_dfi_lp_ack                  (ch0_dfi_lp_ack             ),     

		    // DFI Control Interface
		    .ch1_dfi_reset_n                 ({pMEMCTL_RESET_WIDTH{ch1_dfi_reset_n}}),     
		    .ch1_dfi_cke                     (ch1_dfi_cke  						   ),     
		    .ch1_dfi_odt                     (ch1_dfi_odt  							 ),     
		    .ch1_dfi_cs_n                    (ch1_dfi_cs_n 							 ),     
		    .ch1_dfi_cid                     (ch1_dfi_cid  						   ),     
		    .ch1_dfi_ras_n                   (ch1_dfi_ras_n              ),     
		    .ch1_dfi_cas_n                   (ch1_dfi_cas_n              ),     
		    .ch1_dfi_we_n                    (ch1_dfi_we_n               ),     
		    .ch1_dfi_bank                    (ch1_dfi_bank               ),     
		    .ch1_dfi_address                 (ch1_dfi_address            ),     
        .ch1_dfi_act_n                   (ch1_dfi_act_n),
        .ch1_dfi_bg                      (ch1_dfi_bg),
		    // DFI Write Data Interface
		    .ch1_dfi_wrdata_en               (ch1_dfi_wrdata_en          ),     
		    .ch1_dfi_wrdata                  (ch1_dfi_wrdata             ),     
		    .ch1_dfi_wrdata_mask             (ch1_dfi_wrdata_mask        ),     
		    // DFI Read Data Interface
		    .ch1_dfi_rddata_en               (ch1_dfi_rddata_en          ),     
		    .ch1_dfi_rddata_valid            (ch1_dfi_rddata_valid       ),     
		    .ch1_dfi_rddata                  (ch1_dfi_rddata             ),     
		    // DFI Update Interface
		    .ch1_dfi_ctrlupd_req             (ch1_dfi_ctrlupd_req        ),     
		    .ch1_dfi_ctrlupd_ack             (ch1_dfi_ctrlupd_ack        ),     
		    .ch1_dfi_phyupd_req              (ch1_dfi_phyupd_req         ),     
		    .ch1_dfi_phyupd_ack              (ch1_dfi_phyupd_ack         ),     
		    .ch1_dfi_phyupd_type             (ch1_dfi_phyupd_type        ),     
		    // DFI Status Interface
		    .ch1_dfi_init_start              (ch1_dfi_init_start         ),     
		    .ch1_dfi_data_byte_disable       (ch1_dfi_data_byte_disable  ),
		    .ch1_dfi_dram_clk_disable        (ch1_dfi_dram_clk_disable   ),     
		    .ch1_dfi_init_complete           (ch1_dfi_init_complete      ),     
		    .ch1_dfi_parity_in               (ch1_dfi_parity_in          ),     
        .ch1_dfi_alert_n                 (ch1_dfi_alert_n            ),
		    // DFI Training Interface
        .ch1_dfi_phylvl_req_cs_n         (ch1_dfi_phylvl_req_cs_n    ),  /* Not supported */
        .ch1_dfi_phylvl_ack_cs_n         (ch1_dfi_phylvl_ack_cs_n    ),  /*  by the PUB   */
           
		    .ch1_dfi_rdlvl_mode              (ch1_dfi_rdlvl_mode         ),     
		    .ch1_dfi_rdlvl_gate_mode         (ch1_dfi_rdlvl_gate_mode    ),     
		    .ch1_dfi_wrlvl_mode              (ch1_dfi_wrlvl_mode         ),     
		    // Low Power Control Interface
		    .ch1_dfi_lp_data_req             (ch1_dfi_lp_data_req        ),     
        .ch1_dfi_lp_ctrl_req             (ch1_dfi_lp_ctrl_req        ),
		    .ch1_dfi_lp_wakeup               (ch1_dfi_lp_wakeup          ),     
		    .ch1_dfi_lp_ack                  (ch1_dfi_lp_ack             ),     
       
    		/********************* INTO PUB ******************************/
		    // DFI Control Interface
		    .dfi_reset_n                     (dfi_reset_n                ),     
		    .dfi_cke                         (dfi_cke                    ),     
		    .dfi_odt                         (dfi_odt                    ),     
		    .dfi_cs_n                        (dfi_cs_n                   ),     
		    .dfi_cid                         (dfi_cid                    ),     
		    .dfi_ras_n                       (dfi_ras_n                  ),     
		    .dfi_cas_n                       (dfi_cas_n                  ),     
		    .dfi_we_n                        (dfi_we_n                   ),     
		    .dfi_bank                        (dfi_bank                   ),     
		    .dfi_address                     (dfi_address                ),     
        .dfi_act_n                       (dfi_act_n),
        .dfi_bg                          (dfi_bg),
		    // DFI Write Data Interface
		    .dfi_wrdata_en                   (dfi_wrdata_en              ),     
		    .dfi_wrdata                      (dfi_wrdata                 ),     
		    .dfi_wrdata_mask                 (dfi_wrdata_mask            ),     
		    // DFI Read Data Interface
		    .dfi_rddata_en                   (dfi_rddata_en              ),     
		    .dfi_rddata_valid                (dfi_rddata_valid           ),     
		    .dfi_rddata                      (dfi_rddata                 ),     
		    // DFI Update Interface
		    .dfi_ctrlupd_req                 (dfi_ctrlupd_req            ),     
		    .dfi_ctrlupd_ack                 (dfi_ctrlupd_ack            ),     
		    .dfi_phyupd_req                  (dfi_phyupd_req             ),     
		    .dfi_phyupd_ack                  (dfi_phyupd_ack             ),     
		    .dfi_phyupd_type                 (dfi_phyupd_type            ),     
		    // DFI Status Interface
		    .dfi_init_start                  (dfi_init_start             ),     
		    .dfi_data_byte_disable           (dfi_data_byte_disable      ),
		    .dfi_dram_clk_disable            (dfi_dram_clk_disable       ),     
		    .dfi_init_complete               (dfi_init_complete          ),     
		    .dfi_parity_in                   (dfi_parity_in              ),     
        .dfi_alert_n                     (dfi_alert_n                ),
		    // DFI Training Interface
        .dfi_phylvl_req_cs_n             (dfi_phylvl_req_cs_n        ),  /* Not supported */
        .dfi_phylvl_ack_cs_n             (dfi_phylvl_ack_cs_n        ),  /*  by the PUB   */
		    .dfi_rdlvl_mode                  (dfi_rdlvl_mode             ),     
		    .dfi_rdlvl_gate_mode             (dfi_rdlvl_gate_mode        ),     
		    .dfi_wrlvl_mode                  (dfi_wrlvl_mode             ),     
		    // Low Power Control Interface
		    .dfi_lp_data_req                 (dfi_lp_data_req            ),     
        .dfi_lp_ctrl_req                 (dfi_lp_ctrl_req            ),
		    .dfi_lp_wakeup                   (dfi_lp_wakeup              ),     
		    .dfi_lp_ack                      (dfi_lp_ack                 )         
     );
`else
        assign dfi_reset_n               = ch0_dfi_reset_n           ;     
        assign dfi_cke                   = ch0_dfi_cke               ;
        assign dfi_odt                   = ch0_dfi_odt               ;
        assign dfi_cs_n                  = ch0_dfi_cs_n              ;
        assign dfi_cid                   = ch0_dfi_cid               ;
        assign dfi_ras_n                 = ch0_dfi_ras_n             ;
        assign dfi_cas_n                 = ch0_dfi_cas_n             ;
        assign dfi_we_n                  = ch0_dfi_we_n              ;
        assign dfi_bank                  = ch0_dfi_bank              ;
        assign dfi_address               = ch0_dfi_address           ;
        assign dfi_act_n                 = ch0_dfi_act_n             ;
        assign dfi_bg                    = ch0_dfi_bg                ;

        assign dfi_wrdata_en             = ch0_dfi_wrdata_en         ;
        assign dfi_wrdata                = ch0_dfi_wrdata            ;
        assign dfi_wrdata_mask           = ch0_dfi_wrdata_mask       ;

        assign dfi_rddata_en             = ch0_dfi_rddata_en         ;
        assign ch0_dfi_rddata_valid      = dfi_rddata_valid          ;
        assign ch0_dfi_rddata            = dfi_rddata                ;

        assign dfi_ctrlupd_req           = (pNUM_CHANNELS==2)? {2{ch0_dfi_ctrlupd_req}} : ch0_dfi_ctrlupd_req;
        assign ch0_dfi_ctrlupd_ack       = dfi_ctrlupd_ack[0]        ;
        assign ch0_dfi_phyupd_req        = dfi_phyupd_req[0]         ;
        assign dfi_phyupd_ack            = (pNUM_CHANNELS==2)? {2{ch0_dfi_phyupd_ack}} : ch0_dfi_phyupd_ack;
        assign ch0_dfi_phyupd_type       = dfi_phyupd_type[1:0]      ;

        assign dfi_init_start            = ch0_dfi_init_start        ;
        assign dfi_data_byte_disable     = ch0_dfi_data_byte_disable ;
        assign dfi_dram_clk_disable      = ch0_dfi_dram_clk_disable  ;
        assign ch0_dfi_init_complete     = dfi_init_complete         ;
        assign dfi_parity_in             = ch0_dfi_parity_in         ;
        assign ch0_dfi_alert_n           = dfi_alert_n               ;

        assign dfi_phylvl_req_cs_n       = ch0_dfi_phylvl_req_cs_n   ;  /* Not supported */
        assign dfi_phylvl_ack_cs_n       = ch0_dfi_phylvl_ack_cs_n   ;  /*  by the PUB   */
        assign ch0_dfi_rdlvl_mode        = dfi_rdlvl_mode            ;
        assign ch0_dfi_rdlvl_gate_mode   = dfi_rdlvl_gate_mode       ;
        assign ch0_dfi_wrlvl_mode        = dfi_wrlvl_mode            ;

        assign dfi_lp_data_req           = ch0_dfi_lp_data_req       ;
        assign dfi_lp_ctrl_req           = ch0_dfi_lp_ctrl_req       ;
        assign dfi_lp_wakeup             = ch0_dfi_lp_wakeup         ;
        assign ch0_dfi_lp_ack            = dfi_lp_ack                ;
`endif


  //===========================================================================
  // SDRAM Ranks
  //===========================================================================
  generate 
    genvar dwc_dim;
    genvar dwc_rnk;
    genvar dwc_idx;
    for (dwc_dim=0; dwc_dim<`DWC_NO_OF_DIMMS; dwc_dim=dwc_dim+1) begin:dwc_dimm
      // DIMM/rank instantiation
      ddr_dimm
        #(
          .pDIMM_NO         ( dwc_dim                                           ),          
          .pNO_OF_BYTES     ( `DWC_BYTES_PER_RANK                               ),
`ifdef DDR4
          .pBK_WIDTH        ( pPHY_BA_WIDTH                                     ),
          .pBG_WIDTH        ( pPHY_BG_WIDTH                                     ),
`else
          .pBANK_WIDTH      ( pBANK_ADDR_WIDTH                                  ),
          .pDRAM_BANK_WIDTH ( `SDRAM_BANK_WIDTH                                 ), 
`endif
          .pRDIMM_MIRROR    ( pRDIMM_MIRROR                                     ),
          .pUDIMM_MIRROR    ( pUDIMM_MIRROR                                     ),
`ifdef LPDDRX
          .pADDR_WIDTH      ( `SDRAM_ADDR_WIDTH+6*`DWC_ADDR_COPY                ),
`else
          .pADDR_WIDTH      ( `SDRAM_ADDR_WIDTH                                 ),
`endif
          .pDRAM_ADDR_WIDTH ( `SDRAM_ADDR_WIDTH                                 ),
          .pDRAM_IO_WIDTH   ( `SDRAM_DATA_WIDTH                                 ),
      	  .pNO_OF_RANKS     ( `DWC_RANKS_PER_DIMM                               ),
	        .pRDIMM_CS_WIDTH  ( pCSN_PER_DIMM                                                 )
         )

       u_ddr_rank   
         (
          .rst_n             ( ram_rst_n       [0]                               ),
          .ck                ( ck_i            [0]                               ),
          .ck_n              ( ck_n_i          [0]                               ),
          .cs_n              ( cs_n_i[(dwc_dim*pCSN_PER_DIMM) +: pCSN_PER_DIMM]  ),
          .cke               ( cke_i [(dwc_dim*pCKE_PER_DIMM) +: pCKE_PER_DIMM]  ),
`ifndef LPDDR3_2RANK_1ODT 
          .odt               ( odt_i [(dwc_dim*pODT_PER_DIMM) +: pODT_PER_DIMM]  ),
`else           
          .odt               ( odt_i [dwc_dim - dwc_dim%2]                       ),   
`endif 

`ifdef DDR3    
  `ifdef DWC_IDT
          .mirror            ( mirror_i                                          ),   
          .qcsen_n           ( qcsen_n_i                                         ),
  `endif    

`endif

`ifdef DWC_RDIMM_RANK
          .parity            ( parity_i                                          ),
`endif  

`ifdef DDR4          
          .alert_n           ( alert_n_i                                         ),          
          .act_n             ( act_n_i                                           ),
          .bg                ( ba_i[pPHY_BG_WIDTH+1:2]                           ),
          .ba                ( ba_i[pPHY_BA_WIDTH-1:0]                           ),
          .c                 ( cid_i                                             ),
`else
 `ifdef  DWC_AC_ALERTN_USE 
          .alert_n           (alert_n_i),
 `endif
          .ras_n             ( ras_n_i                                           ),
          .cas_n             ( cas_n_i                                           ),
          .we_n              ( we_n_i                                            ),
          .ba                ( ba_i                                              ),
`endif

          .a                 ( a_i[`SDRAM_ADDR_WIDTH+6*`DWC_ADDR_COPY-1:0]       ),
          
  // Shared AC added on...  need to figure out how to merge these to pNUM_LANES      
  `ifdef DWC_USE_SHARED_AC_TB     
    `ifdef DWC_DDRPHY_DMDQS_MUX
      `ifdef SDRAMx4
        `ifdef DDR4
          .dm                ( {pNUM_LANES{1'bx}} ), // DM not available
        `else  
          .dm                ( {pNUM_LANES{1'b0}} ),
        `endif
      `else
        `ifdef DWC_DDRPHY_EMUL_XILINX 
          .dm                ( dm_i [(dwc_dim % 2)*pCHN1_DX8_NUM_DXDQS + pCHN0_DX8_NUM_DXDQS-1:(dwc_dim % 2)*pCHN0_DX8_NUM_DXDQS] ), // Feature not supported by emulation models
        `else
          .dm                ( dmdqs              ), // DM muxed onto DQS for x8 and x16
        `endif
      `endif
    `else // !`ifdef DWC_DDRPHY_DMDQS_MUX
      `ifdef SDRAMx4
        `ifdef DDR4
          .dm                ( {pNUM_LANES{1'bx}} ), // DM not available
        `else  
          .dm                ( dm_i [(dwc_dim % 2)*pCHN1_DX8_NUM_DXDQS + pCHN0_DX8_NUM_DXDQS-1:(dwc_dim % 2)*pCHN0_DX8_NUM_DXDQS]  ),
        `endif
      `else
          .dm                ( dm_i [(dwc_dim % 2)*pCHN1_DX8_NUM_DXDQS + pCHN0_DX8_NUM_DXDQS-1:(dwc_dim % 2)*pCHN0_DX8_NUM_DXDQS]  ),
      `endif      
    `endif // !`ifdef DWC_DDRPHY_DMDQS_MUX
          .dqs               ( dqs   [(dwc_dim % 2)*pCHN1_DX8_NUM_DXDQS + pCHN0_DX8_NUM_DXDQS-1:(dwc_dim % 2)*pCHN0_DX8_NUM_DXDQS] ),
          .dqs_n             ( dqs_n [(dwc_dim % 2)*pCHN1_DX8_NUM_DXDQS + pCHN0_DX8_NUM_DXDQS-1:(dwc_dim % 2)*pCHN0_DX8_NUM_DXDQS] ),
          .dq                ( dq    [(dwc_dim % 2)*pCHN1_DATA_WIDTH    + pCHN0_DATA_WIDTH   -1:(dwc_dim % 2)*pCHN0_DATA_WIDTH   ] )
  `else
    // non SharedAC mode
    `ifdef DWC_DDRPHY_DMDQS_MUX
      `ifdef SDRAMx4
        `ifdef DDR4
          .dm                ( {pNUM_LANES{1'bx}} ), // DM not available
        `else  
          .dm                ( {pNUM_LANES{1'b0}} ),
        `endif
      `else
        `ifdef DWC_DDRPHY_EMUL_XILINX 
          .dm                ( dm_i               ), // Feature not supported by emulation models
        `else
          .dm                ( dmdqs              ), // DM muxed onto DQS for x8 and x16
        `endif
      `endif
    `else // !`ifdef DWC_DDRPHY_DMDQS_MUX
      `ifdef SDRAMx4
        `ifdef DDR4
          .dm                ( {pNUM_LANES{1'bx}} ), // DM not available
        `else  
          .dm                ( dm_i               ),
        `endif
      `else
          .dm                ( dm_i               ),
      `endif      
    `endif // !`ifdef DWC_DDRPHY_DMDQS_MUX
          
          .dqs               ( dqs                ),
          .dqs_n             ( dqs_n              ),
          .dq                ( dq                 )
  `endif // DWC_USE_SHARED_AC_TB
         );

      // rank monitors
      for (dwc_rnk=0; dwc_rnk<`DWC_RANKS_PER_DIMM; dwc_rnk=dwc_rnk+1) begin:dwc_rank_mnt
        ddr_mnt 
          #(
            .pNO_OF_BYTES  ( `DWC_BYTES_PER_RANK ), 
            .pNO_OF_RANKS  ( pNO_OF_RANKS        ), 
            .pCK_WIDTH     ( pCK_WIDTH           ), 
            .pBANK_WIDTH   ( pBANK_ADDR_WIDTH    ), 
            .pADDR_WIDTH   ( `SDRAM_ADDR_WIDTH   ),
            .rank_no       ( (dwc_dim*`DWC_MAX_RANKS_PER_DIMM) + dwc_rnk )
           )  
        u_ddr_mnt 
           (
            .rst_n        ( rst_n                ),
            .ram_rst_n    ( ram_rst_n[0]         ),
           
            .ck           ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.ck                       ),
            .ck_n         ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.ck_n                     ),   
            .cke          ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.cke[0]                   ),
            .odt          ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.odt[0]                   ),
            .cs_n         ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.cs_n[0]                  ),
`ifdef DDR4    
            .act_n        ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.act_n[0]                 ),
            .ba           ({`TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.bg[pPHY_BG_WIDTH -1:0],
                            `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.ba[pPHY_BA_WIDTH -1:0]}  ),
            .cid          ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.c[`DWC_CID_WIDTH -1:0]   ),
`else
            .act_n        ( 1'b1                                    ),
            .ras_n        ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.ras_n[0]                 ),
            .cas_n        ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.cas_n[0]                 ),
            .we_n         ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.we_n[0]                  ),
            .ba           ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.ba[pBANK_ADDR_WIDTH-1:0] ),
`endif
            .a            ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.a[`SDRAM_ADDR_WIDTH-1:0] ),     
            .dm           ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.dm                       ),
            .dqs          ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.dqs                      ),
            .dqs_n        ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.dqs_n                    ),    
`ifdef DWC_USE_SHARED_AC_TB 
            .dq           ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.dq[`CH1_DWC_EDATA_WIDTH*(dwc_dim % 2) + `CH0_DWC_EDATA_WIDTH*((dwc_dim+1) % 2 )-1:0] )
`else
            .dq           ( `TB.dwc_dimm[dwc_dim].u_ddr_rank.dwc_rank[dwc_rnk].sdram_rank.dq /*[dwc_rnk*`DWC_EDATA_WIDTH +: `DWC_EDATA_WIDTH]*/ )
`endif
           );
      end // block: dwc_rank_mnt
    end // block: dwc_dimm
       
  `ifdef DWC_DDRPHY_DMDQS_MUX
    // extract the DMs for x8/x16 from DQS[1]
    for(dwc_idx = 0; dwc_idx < pNO_OF_BYTES; dwc_idx = dwc_idx + 1) begin
    `ifdef DWC_DDRPHY_EMUL_XILINX // Feature not supported by emulation models
      assign dmdqs[2*dwc_idx + 0] = dm_i[2*dwc_idx + 0];
      assign dmdqs[2*dwc_idx + 1] = dm_i[2*dwc_idx + 1];
    `else
      assign dmdqs[2*dwc_idx + 0] = dqs[2*dwc_idx + 1];
      assign dmdqs[2*dwc_idx + 1] = 1'bx; // ** TBD drive this to X for real effect
    `endif
    end
  `endif
  endgenerate
    
  
  // in some rank configurations, such as certain RDIMMs, simulatneous access
  // to all ranks is not allowed, i.e. chip selects of multiple ranks cannot
  // be asserted at the same time, otherwise the resulting chip selects are
  // de-asserted
  assign ck_i     = ck;
  assign ck_n_i   = ck_n;
  assign cke_i    = {1'b0, cke};
  assign odt_i    = {1'b0, odt};
`ifdef DWC_AC_CS_USE
  assign cs_n_i   = {1'b1, cs_n};
`else
  assign cs_n_i   = {1'b1, 1'b0};
`endif
`ifndef DWC_AC_ALERTN_USE
   `ifndef DDR4
     assign alert_n_i = 1'b0;
   `endif
`endif 
  assign parity_i = (parity_err)          ? `SYS.parity_err_val : parity;
  assign alert_n  = (`SYS.parity_err_chk) ? alert_n_i           : 1'b1;

//  generate
//    if (`DWC_NO_OF_3DS_STACKS == 0) begin: gblk_cid
`ifndef DWC_NO_OF_3DS_STACKS
      assign cid_i = 1'b0; // IP does not drive CID pin if statcks are not supported
//    end else begin: gblk_cid
`else
      assign cid_i = {1'b0, cid};
`endif      
//    end
//  endgenerate
      

`ifdef DDR3
  // for DDR3 drive the mirror pin from the chip if it was included or tie it off or on
  // depending on address mirroring requirement
  `ifdef DWC_AC_MIRROR_USE
  assign mirror_i = mirror;
  `else
    `ifdef DWC_RDIMM_MIRROR
  assign mirror_i = 1'b1;
    `else
  assign mirror_i = 1'b0;
    `endif
  `endif

  `ifdef DWC_AC_QCSEN_USE
  assign qcsen_n_i = qcsen_n;
  `else
    `ifdef RDIMM_DUAL_RANK
  assign qcsen_n_i = 1'b1;
    `else
  assign qcsen_n_i = 1'b0;
    `endif
  `endif
`endif


  // if no I/O cell for DM, drive the SDRAM DM input to 0
  // mapping of PHY address/command signals to SDRAM chip signa;s
  `ifdef DDR4
    assign act_n_i = act_n;
  `else
    assign act_n_i = 1'b1;
  `endif

  `ifdef DDR4
    assign ras_n_i = a[16];
    assign cas_n_i = a[15];
    assign we_n_i  = a[14];
    assign ba_i    = {bg, ba};
    assign a_i     = a;
  `else
    `ifdef DWC_CUSTOM_PIN_MAP  
       reg  [pPHY_ADDR_WIDTH        -1:0]  a_reg  ;
       assign ras_n_i = (`DWC_DDR32_RAS_MAP == `DWC_ACTN_INDX) ? act_n  : ( 
                        (`DWC_DDR32_RAS_MAP == `DWC_BG1_INDX ) ? bg[1]  : ( 
                        (`DWC_DDR32_RAS_MAP == `DWC_A17_INDX ) ? a[17]  : ( 
                        (`DWC_DDR32_RAS_MAP == `DWC_A16_INDX ) ? a[16]  : ( 
                        (`DWC_DDR32_RAS_MAP == `DWC_A15_INDX ) ? a[15]  : ( 
                        (`DWC_DDR32_RAS_MAP == `DWC_A14_INDX ) ? a[14]  : 1'b1 )))));
       assign cas_n_i = (`DWC_DDR32_CAS_MAP == `DWC_ACTN_INDX) ? act_n  : ( 
                        (`DWC_DDR32_CAS_MAP == `DWC_BG1_INDX ) ? bg[1]  : ( 
                        (`DWC_DDR32_CAS_MAP == `DWC_A17_INDX ) ? a[17]  : ( 
                        (`DWC_DDR32_CAS_MAP == `DWC_A16_INDX ) ? a[16]  : ( 
                        (`DWC_DDR32_CAS_MAP == `DWC_A15_INDX ) ? a[15]  : ( 
                        (`DWC_DDR32_CAS_MAP == `DWC_A14_INDX ) ? a[14]  : 1'b1 )))));
       assign we_n_i  = (`DWC_DDR32_WE_MAP == `DWC_ACTN_INDX) ? act_n  : ( 
                        (`DWC_DDR32_WE_MAP == `DWC_BG1_INDX ) ? bg[1]  : ( 
                        (`DWC_DDR32_WE_MAP == `DWC_A17_INDX ) ? a[17]  : ( 
                        (`DWC_DDR32_WE_MAP == `DWC_A16_INDX ) ? a[16]  : ( 
                        (`DWC_DDR32_WE_MAP == `DWC_A15_INDX ) ? a[15]  : ( 
                        (`DWC_DDR32_WE_MAP == `DWC_A14_INDX ) ? a[14]  : 1'b1 )))));
       assign ba_i    = {bg, ba};  
       always@(*) begin
         a_reg = a;
         if (pPHY_ADDR_WIDTH > 14)
           case(`DWC_DDR32_A14_MAP)
             `DWC_ACTN_INDX   :  a_reg[14] = act_n ;
             `DWC_BG1_INDX    :  a_reg[14] = bg[1] ;
             `DWC_A17_INDX    :  a_reg[14] = a[17] ;
             `DWC_A16_INDX    :  a_reg[14] = a[16] ;
             `DWC_A15_INDX    :  a_reg[14] = a[15] ;
             `DWC_A14_INDX    :  a_reg[14] = a[14] ;
             default          :  a_reg[14] = a[14] ;
           endcase
         if (pPHY_ADDR_WIDTH > 15)
           case(`DWC_DDR32_A15_MAP)
             `DWC_ACTN_INDX   :  a_reg[15] = act_n ;
             `DWC_BG1_INDX    :  a_reg[15] = bg[1] ;
             `DWC_A17_INDX    :  a_reg[15] = a[17] ;
             `DWC_A16_INDX    :  a_reg[15] = a[16] ;
             `DWC_A15_INDX    :  a_reg[15] = a[15] ;
             `DWC_A14_INDX    :  a_reg[15] = a[14] ;
             default         :  a_reg[15] = a[15] ;
           endcase
       end
                    
       assign a_i     = a_reg;
    `else
      assign ras_n_i = act_n;
      assign cas_n_i = a[17];
      assign we_n_i  = a[16];
      assign ba_i    = {bg, ba};
      assign a_i     = a;
    `endif
  `endif

  
  //---------------------------------------------------------------------------
  // Bus Functional Models (BFMs)
  //---------------------------------------------------------------------------
  // BFMs for configuration port and host port interfaces
  
  // configuration port
  // ------------------
  // generic configuration port
  cfg_bfm cfg_bfm
    (
     .rst_b         (cfg_rst_n),
     .clk           (cfg_clk),
     .rqvld         (cfg_rqvld),
     .cmd           (cfg_cmd),
     .a             (cfg_a),
     .d             (cfg_d),
     .qvld          (cfg_qvld),
     .q             (cfg_q),
     .jtag_en       (jtag_en),
     .jtag_rqvld    (jtag_rqvld),
     .jtag_cmd      (jtag_cmd),
     .jtag_a        (jtag_a),
     .jtag_d        (jtag_d),
     .jtag_qvld     (jtag_qvld),
     .jtag_q        (jtag_q)
     );

  // APB configuration port: translates generic port protocol to APB
`ifdef DWC_DDRPHY_APB
  apb_bfm apb_bfm
    (
     // interface to generic configuration port
     .cfg_rst_n     (cfg_rst_n),
     .cfg_clk       (cfg_clk),
     .cfg_rqvld     (cfg_rqvld),
     .cfg_cmd       (cfg_cmd),
     .cfg_a         (cfg_a),
     .cfg_d         (cfg_d),
     .cfg_qvld      (cfg_qvld),
     .cfg_q         (cfg_q),
     
     // interface to APB configuration port (pclk is same clock as cfg_clk)
     .paddr         (paddr),
     .psel          (psel),
     .penable       (penable),
     .pwrite        (pwrite),
     .pwdata        (pwdata),
     .prdata        (prdata)
     );
`endif

  // JTAG port
`ifdef DWC_DDRPHY_JTAG
  jtag_bfm  jtag_bfm
    (
     // interface to generic configuration port
     .cfg_rst_n     (cfg_rst_n),
     .cfg_clk       (cfg_clk),
     .jtag_en       (jtag_en),
     .cfg_rqvld     (jtag_rqvld),
     .cfg_cmd       (jtag_cmd),
     .cfg_a         (jtag_a),
     .cfg_d         (jtag_d),
     .cfg_qvld      (jtag_qvld),
     .cfg_q         (jtag_q),
     
     // interface to JTAG port
     .trst_n        (trst_n),
     .tclk          (xclk),
     .tms           (tms),
     .tdi           (tdo),
     .tdo           (tdi)
     );
`endif
  
  // host port BFM
  // -------------
//  host_bfm host_bfm 
//    (
//     .rst_b         (rst_n),
//     .clk           (dfi_clk),
//     .rqvld         (host_rqvld),
//     .cmd           (host_cmd),
//     .a             (host_a),
//     .dm            (host_dm),
//     .d             (host_d),
//     .cmd_flag      (host_cmd_flag),
//     .rdy           (host_rdy),
//     .qvld          (host_qvld),
//     .q             (host_q),
//     .hdr_odd_cmd   (hdr_odd_cmd)
//     );

  // HOST 0
  host_bfm 
`ifdef DWC_SHARED_AC
    #(
      .pDATA_WIDTH  (`HOST_NX*pCHN0_DATA_WIDTH),
      .pBYTE_WIDTH  (`HOST_NX*pCHN0_DX8_NUM   ),
      .pNUM_BYTES   (pCHN0_DX8_NUM            ),
      .pCHANNEL_NO  (0)
    )
`endif      
    host_bfm_0
    (
     .rst_b         (rst_n),
     .clk           (dfi_clk),
     .rqvld         (host_rqvld_0),
     .cmd           (host_cmd_0),
     .a             (host_a_0),
     .dm            (host_dm_0),
     .d             (host_d_0),
     .cmd_flag      (host_cmd_flag_0),
     .rdy           (host_rdy_0),
     .qvld          (host_qvld_0),
     .q             (host_q_0),
     .hdr_odd_cmd   (hdr_odd_cmd_0)
     );

`ifdef DWC_USE_SHARED_AC_TB
  // HOST 1
  host_bfm
    #(
      .pDATA_WIDTH  (`HOST_NX*pCHN1_DATA_WIDTH),
      .pBYTE_WIDTH  (`HOST_NX*pCHN1_DX8_NUM  ),
      .pNUM_BYTES   (pCHN1_DX8_NUM            ),
      .pCHANNEL_NO  (1)
    )
    host_bfm_1
    (
     .rst_b         (rst_n),
     .clk           (dfi_clk),
     .rqvld         (host_rqvld_1),
     .cmd           (host_cmd_1),
     .a             (host_a_1),
     .dm            (host_dm_1),
     .d             (host_d_1),
     .cmd_flag      (host_cmd_flag_1),
     .rdy           (host_rdy_1),
     .qvld          (host_qvld_1),
     .q             (host_q_1),
     .hdr_odd_cmd   (hdr_odd_cmd_1)
     );
`endif  

  
  
  //---------------------------------------------------------------------------
  // System Utilities (clocks, resets, errors, etc.)
  //---------------------------------------------------------------------------
  system 
 `ifdef DWC_DDRPHY_BOARD_DELAYS
     #(
 `ifdef DWC_BOARD_TOPOLOGY    
       .pBOARD_CONFIG_TYPE  ( `DWC_BOARD_TOPOLOGY )
 `else          
       .pBOARD_CONFIG_TYPE  ( 0 )
 `endif      
     )
 `endif
     system
    (.rst_b            (rst_n),
     .trst_b           (cfg_rst_n),
     .xrst_b           (xrst_n),
     .clk_emul         (clk_emul),
     .clk              (clk),
     .refclk_200MHz    (refclk_emul),
     .tclk             (cfg_clk),
     .xclk             (xclk),
     .dfi_clk          (dfi_clk),
     .dfi_phy_clk      (dfi_phy_clk),
     .ddr_clk          (ddr_clk),
     .scan_ms          (atpg_mode),
     .ac_atpg_lu_ctrl  (ac_atpg_lu_ctrl),
`ifdef DWC_DDRPHY_CK
     .ck_atpg_se       (ck_atpg_se),
     .ck_atpg_si       (ck_atpg_si),
     .ck_atpg_so       (ck_atpg_so),
`endif       
     .ac_atpg_se       (ac_atpg_se),
     .ac_atpg_si       (ac_atpg_si),
     .ac_atpg_so       (ac_atpg_so),
     .dx_atpg_lu_ctrl  (dx_atpg_lu_ctrl),       
     .dx_atpg_se       (dx_atpg_se),
     .dx_atpg_si       (dx_atpg_si),
     .dx_atpg_so       (dx_atpg_so),
     .ctl_atpg_se       (ctl_atpg_se),
     .ctl_atpg_si       (ctl_atpg_si),
     .ctl_atpg_so       (ctl_atpg_so),
     .jtag_atpg_se       (jtag_atpg_se),
     .jtag_atpg_si       (jtag_atpg_si),
     .jtag_atpg_so       (jtag_atpg_so),
     .cfg_atpg_se       (cfg_atpg_se),
     .cfg_atpg_si       (cfg_atpg_si),
     .cfg_atpg_so       (cfg_atpg_so),
     .ctl_sdr_atpg_se       (ctl_sdr_atpg_se),
     .ctl_sdr_atpg_si       (ctl_sdr_atpg_si),
     .ctl_sdr_atpg_so       (ctl_sdr_atpg_so),
      .test_mode        (test_mode),
     .jtag_en          (jtag_en),
     .parity_err       (parity_err),
     .hdr_odd_cmd      (hdr_odd_cmd)
     );

  // when in PLL bypass mode, the clock used by the controller is the PLL 
  // bypass clock output
  always @(*) begin
`ifdef DWC_DDRPHY_EMUL_XILINX // no bypass mode PLL generates the clocks
    ctl_clk <=  clk;
`else
    ctl_clk <= clk;
`endif
  end


  phy_system   phy_system();

  
  //---------------------------------------------------------------------------
  // DDR Controller Golden Reference Model (GRM)
  //---------------------------------------------------------------------------
  ddr_grm ddr_grm
    (.rst_b          (rst_n),
     .clk            (dfi_clk)
     );

  //---------------------------------------------------------------------------
  // DDR Controller Functional coverage (FCOV)
  //---------------------------------------------------------------------------
  ddr_fcov ddr_fcov();
  ddr_reg_fcov ddr_reg_fcov();   
  
  
  //---------------------------------------------------------------------------
  // Bus Monitors and Checkers
  //---------------------------------------------------------------------------
  // DDR bus monitor: monitors the bus between the controller and DDR SDRAMs
  // host ports bus monitor: monitors the bus between host ports and the
  // controller host ports
  // configuration monitor: monitors the bus between host configuration port 
  // and the controller configuration port

`ifdef READ_CHECKER

  read_path_checker #(
     .pFIFO_RD_PTR_GAP  ( `RD_CHK_PTR_GAP   ),
     .pFIFO_WR_SETUP    ( `RD_CHK_WR_SETUP  ),
     .pFIFO_WR_HOLD     ( `RD_CHK_WR_HOLD   ),
     .pVERBOSITY        ( `RD_CHK_VERBOSE   )
  ) read_path_checker()  ;

`endif 
 
`ifndef DWC_NO_VREF_TRAIN
  `ifdef VREF_PDA_CHECKER

   vref_pda_checker #(
    .pNO_OF_DX_DQS (`DWC_DX_NO_OF_DQS),
    .pNUM_LANES    (`DWC_DX_NO_OF_DQS * `DWC_NO_OF_BYTES)
   ) vref_pda_checker()  ;

`endif
`endif



always @ (*) begin
  if(`PUB.u_DWC_ddrphy_init.u_DWC_ddrphy_init_dram.init_state == 6'h19) begin // wait for RDIMM initialization
    if (`CHIP.cke !==0) begin
      `SYS.error;
      $display("-> %0t: [assertion] ERROR: cke should be deassert during whole RCD initialization", $time);
    end
  end
end

`ifdef PROBE_DATA_EYES
  //eye monitor is independent of ranks; rank selection will affect the signals 
  // observed by the monitor
  integer   last_bank  = 0 ;
  eye_mnt eye_mnt();/*
  // added by Jose ensure DLs have correct step programmed if we are to check the centering
  initial  begin
     #1;
     if (`CLK_PRD >= 2.5)  `EYE_MNT.ensure_dl_step_scaled ;
  end*/
  // for speed less than 800Mbps, change the DDL step size from the default of 15ps to 20ps
  integer    dl_step_rnd  ;
  initial  begin
     #1;
     `ifdef RANDOMIZED_DL_STEP 
       // Write leveling for 800MHz and below would have problem, hence limit step size to be above 10ps.
       if (`GRM.ddr3_mode && `CLK_PRD >= 2.5)
         `SYS.RANDOM_RANGE(`SYS.seed,5,13,dl_step_rnd);
       else       
         `SYS.RANDOM_RANGE(`SYS.seed,4,13,dl_step_rnd);

       `PHYSYS.set_ddl_step_size(2*dl_step_rnd);
     `else 
       `ifdef CTL_CAL_CLK_USE
         // when slower CTL CLK is used in calibration, we should still keep the relationship
         // between number of step (9bit -> 511 steps) * step_size > CTL_CLK_PRD
         // to get the wlprd and gdqsprd sampled correctly. 
         `PHYSYS.set_ddl_step_size(10);
       `endif

       `ifndef NO_DLSTEP_OVERRIDE    
         if (`CLK_PRD >= 2.5)  `PHYSYS.set_ddl_step_size(20);
       `endif

     `endif
  end
`else
  initial  begin
     #1;
     `ifdef CTL_CAL_CLK_USE
       // when slower CTL CLK is used in calibration, we should still keep the relationship
       // between number of step (9bit -> 511 steps) * step_size > CTL_CLK_PRD
       // to get the wlprd and gdqsprd sampled correctly. 
       `PHYSYS.set_ddl_step_size(10);
     `endif
     `ifndef NO_DLSTEP_OVERRIDE    
       if (`CLK_PRD >= 2.5)  `PHYSYS.set_ddl_step_size(20);
     `endif   
  end  
`endif

  
  // configuration port monitor
  // --------------------------
  // monitor on the DDR controller configuration port
  cfg_mnt cfg_mnt
    (
     .rst_b        (cfg_rst_n),
     .clk          (cfg_clk),
     .rqvld        (cfg_rqvld),
     .cmd          (cfg_cmd),
     .a            (cfg_a),
     .d            (cfg_d),
     .qvld         (cfg_qvld),
     .q            (cfg_q),
     .jtag_en      (jtag_en),
     .jtag_rqvld   (jtag_rqvld),
     .jtag_cmd     (jtag_cmd),
     .jtag_a       (jtag_a),
     .jtag_d       (jtag_d),
     .jtag_qvld    (jtag_qvld),
     .jtag_q       (jtag_q)
     );
  

  // Host monitor
  // ------------
  // monitor on the host port of the DDR memory controller
//  host_mnt host_mnt
//    (
//     .rst_b        (rst_n),
//     .clk          (dfi_clk),
//     .rqvld        (host_rqvld),
//     .cmd          (host_cmd),
//     .a            (host_a),
//     .dm           (host_dm),
//     .d            (host_d),
//     .cmd_flag     (host_cmd_flag[0]),
//     .rdy          (host_rdy),
//     .qvld         (host_qvld),
//     .q            (host_q)
//     );
//
  host_mnt 
`ifdef DWC_USE_SHARED_AC_TB
    #(
      .pDATA_WIDTH  (`HOST_NX*pCHN0_DATA_WIDTH),
      .pBYTE_WIDTH  (`HOST_NX*pCHN0_DX8_NUM),
      .pCHANNEL_NO  (0)
    )
`endif
  host_mnt_0
    (
     .rst_b        (rst_n),
     .clk          (dfi_clk),
     .rqvld        (host_rqvld_0),
     .cmd          (host_cmd_0),
     .a            (host_a_0),
     .dm           (host_dm_0),
     .d            (host_d_0),
     .cmd_flag     (host_cmd_flag_0[0]),
     .rdy          (host_rdy_0),
     .qvld         (host_qvld_0),
     .q            (host_q_0)
     );

`ifdef DWC_USE_SHARED_AC_TB  
  host_mnt
    #(
      .pDATA_WIDTH  (`HOST_NX*pCHN1_DATA_WIDTH),
      .pBYTE_WIDTH  (`HOST_NX*pCHN1_DX8_NUM),
      .pCHANNEL_NO  (1)
    )
    host_mnt_1
    (
     .rst_b        (rst_n),
     .clk          (dfi_clk),
     .rqvld        (host_rqvld_1),
     .cmd          (host_cmd_1),
     .a            (host_a_1),
     .dm           (host_dm_1),
     .d            (host_d_1),
     .cmd_flag     (host_cmd_flag_1[0]),
     .rdy          (host_rdy_1),
     .qvld         (host_qvld_1),
     .q            (host_q_1)
     );
`endif
    
  // DFI interface monitor
  // ---------------------
  // monitor on the DFI output of DDR memory controller and the PHY to SDRAM interface
  dfi_mnt 
    #(
`ifdef DWC_USE_SHARED_AC_TB
      .pNO_OF_BYTES  ( pCHN0_DX8_NUM     ),
      .pNO_OF_RANKS  ( pCHN0_NO_OF_RANKS ), 
`else  
      .pNO_OF_BYTES  ( pNO_OF_BYTES ),
      .pNO_OF_RANKS  ( pNO_OF_RANKS ), 
`endif
      .pCHN_IDX      ( 0                 ), 
`ifdef DWC_SHARED_AC
      .pSHARED_AC    ( `DWC_SHARED_AC    ),
`else       
      .pSHARED_AC    ( 0    ),
`endif      
      .pCK_WIDTH     ( pCK_WIDTH    ), 
      .pBANK_WIDTH   ( pBANK_WIDTH  ), 
      .pADDR_WIDTH   ( pADDR_WIDTH  )
      //.pLPDDRX_EN    ( pLPDDRX_EN   )
     )
  dfi_mnt_0
     (
      .rst_b                   (rst_n),
      .clk                     (dfi_clk),
      .ck_inv                  (ck_inv),
      .t_byte_wl_odd           (ch0_t_wl_odd),
      .t_byte_rl_odd           (ch0_t_rl_odd),
     
      .wl                      (`GRM.wl),
      .rl                      (`GRM.rl),
      
      // DFI Control Interface
      .dfi_reset_n             (ch0_dfi_reset_n),
      .dfi_cke                 (ch0_dfi_cke),
      .dfi_odt                 (ch0_dfi_odt),
      .dfi_cs_n                (ch0_dfi_cs_n),
      .dfi_cid                 (ch0_dfi_cid),
      .dfi_ras_n               (ch0_dfi_ras_n),
      .dfi_cas_n               (ch0_dfi_cas_n),
      .dfi_we_n                (ch0_dfi_we_n),
      .dfi_bank                (ch0_dfi_bank),
      .dfi_address             (ch0_dfi_address),
      .dfi_act_n               (ch0_dfi_act_n),
      .dfi_bg                  (ch0_dfi_bg),
     
      // DFI Write Data Interface
      .dfi_wrdata_en           (ch0_dfi_wrdata_en),
      .dfi_wrdata              (ch0_dfi_wrdata),
      .dfi_wrdata_mask         (ch0_dfi_wrdata_mask),
     
      // DFI Read Data Interface
      .dfi_rddata_en           (ch0_dfi_rddata_en),
      .dfi_rddata_valid        (ch0_dfi_rddata_valid),
      .dfi_rddata              (ch0_dfi_rddata ),
     
      // DFI Update Interface
      .dfi_ctrlupd_req         (ch0_dfi_ctrlupd_req),
      .dfi_ctrlupd_ack         (ch0_dfi_ctrlupd_ack),
      .dfi_phyupd_req          (ch0_dfi_phyupd_req),
      .dfi_phyupd_ack          (ch0_dfi_phyupd_ack),
      .dfi_phyupd_type         (ch0_dfi_phyupd_type),
     
      // DFI Status Interface
      .dfi_init_start          (ch0_dfi_init_start),
      .dfi_data_byte_disable   (ch0_dfi_data_byte_disable),
      .dfi_dram_clk_disable    (ch0_dfi_dram_clk_disable),
      .dfi_init_complete       (ch0_dfi_init_complete),
      .dfi_parity_in           (ch0_dfi_parity_in),  //ch0?
      .dfi_alert_n             (ch0_dfi_alert_n[0]),
     
      // DFI Training Interface
      .dfi_rdlvl_resp          (),
      .dfi_rdlvl_load          (),
      .dfi_rdlvl_cs_n          (),
     
      .dfi_rdlvl_mode          (ch0_dfi_rdlvl_mode),
      .dfi_rdlvl_req           (),
      .dfi_rdlvl_en            (),
      .dfi_rdlvl_edge          (),
      .dfi_rdlvl_delay_X       (),
     
      .dfi_rdlvl_gate_mode     (ch0_dfi_rdlvl_gate_mode),
      .dfi_rdlvl_gate_req      (),
      .dfi_rdlvl_gate_en       (),
      .dfi_rdlvl_gate_delay_X  (),
     
      .dfi_wrlvl_mode          (ch0_dfi_wrlvl_mode),
      .dfi_wrlvl_resp          (),
      .dfi_wrlvl_load          (),
      .dfi_wrlvl_cs_n          (),
      .dfi_wrlvl_strobe        (),
      .dfi_wrlvl_req           (),
      .dfi_wrlvl_en            (),
      .dfi_wrlvl_delay_X       (),
     
      // DFI low power interface
      .dfi_lp_data_req         (ch0_dfi_lp_data_req),
      .dfi_lp_ctrl_req         (ch0_dfi_lp_ctrl_req),
      .dfi_lp_wakeup           (ch0_dfi_lp_wakeup),
      .dfi_lp_ack              (ch0_dfi_lp_ack)
      );  

`ifdef DWC_USE_SHARED_AC_TB  
  dfi_mnt 
    #(
      .pNO_OF_BYTES  ( pCHN1_DX8_NUM     ),
      .pNO_OF_RANKS  ( pCHN1_NO_OF_RANKS ), 
      .pCHN_IDX      ( 1                 ), 
      .pSHARED_AC    ( `DWC_SHARED_AC    ), 
      .pCK_WIDTH     ( pCK_WIDTH    ), 
      .pBANK_WIDTH   ( pBANK_WIDTH  ), 
      .pADDR_WIDTH   ( pADDR_WIDTH  )
     )
  dfi_mnt_1    
     (
      .rst_b                   (rst_n),
      .clk                     (dfi_clk),
      .ck_inv                  (ck_inv),
      .t_byte_wl_odd           (ch1_t_wl_odd),
      .t_byte_rl_odd           (ch1_t_rl_odd),
     
      .wl                      (`GRM.wl),
      .rl                      (`GRM.rl),
      
      // DFI Control Interface
      .dfi_reset_n             (ch1_dfi_reset_n),
      .dfi_cke                 (ch1_dfi_cke),
      .dfi_odt                 (ch1_dfi_odt),
      .dfi_cs_n                (ch1_dfi_cs_n),
      .dfi_cid                 (ch1_dfi_cid),
      .dfi_ras_n               (ch1_dfi_ras_n),
      .dfi_cas_n               (ch1_dfi_cas_n),
      .dfi_we_n                (ch1_dfi_we_n),
      .dfi_bank                (ch1_dfi_bank),
      .dfi_address             (ch1_dfi_address),
      .dfi_act_n               (ch1_dfi_act_n),
      .dfi_bg                  (ch1_dfi_bg),
     
      // DFI Write Data Interface
      .dfi_wrdata_en           (ch1_dfi_wrdata_en),
      .dfi_wrdata              (ch1_dfi_wrdata),
      .dfi_wrdata_mask         (ch1_dfi_wrdata_mask),
     
      // DFI Read Data Interface
      .dfi_rddata_en           (ch1_dfi_rddata_en),
      .dfi_rddata_valid        (ch1_dfi_rddata_valid),
      .dfi_rddata              (ch1_dfi_rddata),
     
      // DFI Update Interface
      .dfi_ctrlupd_req         (ch1_dfi_ctrlupd_req),
      .dfi_ctrlupd_ack         (ch1_dfi_ctrlupd_ack),
      .dfi_phyupd_req          (ch1_dfi_phyupd_req),
      .dfi_phyupd_ack          (ch1_dfi_phyupd_ack),
      .dfi_phyupd_type         (ch1_dfi_phyupd_type),
      // .pub_vt_update           (`PUB.vt_update[pCHN1_DX_IDX_HI:pCHN1_DX_IDX_LO]),
     
      // DFI Status Interface
      .dfi_init_start          (ch1_dfi_init_start),
      .dfi_data_byte_disable   (ch1_dfi_data_byte_disable),
      .dfi_dram_clk_disable    (ch1_dfi_dram_clk_disable),
      .dfi_init_complete       (ch1_dfi_init_complete),
      .dfi_parity_in           (ch1_dfi_parity_in), //ch1
      .dfi_alert_n             (ch1_dfi_alert_n[0]),
     
      // DFI Training Interface
      .dfi_rdlvl_resp          (),
      .dfi_rdlvl_load          (),
      .dfi_rdlvl_cs_n          (),
     
      .dfi_rdlvl_mode          (ch1_dfi_rdlvl_mode),
      .dfi_rdlvl_req           (),
      .dfi_rdlvl_en            (),
      .dfi_rdlvl_edge          (),
      .dfi_rdlvl_delay_X       (),
     
      .dfi_rdlvl_gate_mode     (ch1_dfi_rdlvl_gate_mode),
      .dfi_rdlvl_gate_req      (),
      .dfi_rdlvl_gate_en       (),
      .dfi_rdlvl_gate_delay_X  (),
     
      .dfi_wrlvl_mode          (ch1_dfi_wrlvl_mode),
      .dfi_wrlvl_resp          (),
      .dfi_wrlvl_load          (),
      .dfi_wrlvl_cs_n          (),
      .dfi_wrlvl_strobe        (),
      .dfi_wrlvl_req           (),
      .dfi_wrlvl_en            (),
      .dfi_wrlvl_delay_X       (),
     
      // DFI low power interface
      .dfi_lp_data_req         (ch1_dfi_lp_data_req),
      .dfi_lp_ctrl_req         (ch1_dfi_lp_ctrl_req),
      .dfi_lp_wakeup           (ch1_dfi_lp_wakeup),
      .dfi_lp_ack              (ch1_dfi_lp_ack)
      );  
`endif

  
  // Emulation - for Xilinx target only
`ifdef DWC_DDRPHY_EMUL
  glbl glbl();
`endif
  


  // Instantiate and bind SVA LCDL Bypass module to the DUT modules
`ifdef SVA
`ifdef SVA_DDRPHY_LCDL_BYP
  generate
    genvar dwc_byte;

    // Bind to GDQS
    for(dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) begin : g_bind_ds_gate_lcdl
      bind `DXn.datx8_dqs.ds_gate_lcdl sva_ddrphy_lcdl_byp u_sva_ddrphy_lcdl_byp (
        byp_mode,
        dly_sel,
        dly_so,
        dly_in,
        dly_out,
        dly_n_out,
        ndly_out,
        ndly_n_out,
        cal_clk,
        cal_mode,
        cal_clk_en,
        cal_en,
        cal_en_out,
        cal_out,
        test_mode,
        dti,
        dto
      );
    end

  endgenerate
`endif
`endif

/*
  //---------------------------------------------------------------------------
  // DFI Verification IP
  //---------------------------------------------------------------------------
  //
`ifdef DWC_DDRPHY_USE_DFIVIP  
  dfi_vip u_dfi_vip_0(
         .clk                     (clk),
         .reset_n                 (rst_n),
         .dfi_address             (dfi_address[15:0]),
         .dfi_bank                (dfi_bank[2:0]),
         .dfi_cas_n               (dfi_cas_n[0]),
         .dfi_cke                 (dfi_cke[3:0]),
         .dfi_cs_n                (dfi_cs_n[3:0]),
         .dfi_odt                 (dfi_odt[3:0]),
         .dfi_ras_n               (dfi_ras_n[0]),
         .dfi_we_n                (dfi_we_n[0]),
         .dfi_reset_n             ({4{dfi_reset_n}}),
         .dfi_wrdata_en           (dfi_wrdata_en),
         .dfi_wrdata              (dfi_wrdata[63:0]),
         .dfi_wrdata_mask         (dfi_wrdata_mask[7:0]),
         .dfi_rddata_en           (dfi_rddata_en),
         .dfi_rddata              (dfi_rddata[63:0]),
         .dfi_rddata_valid        (|dfi_rddata_valid),
         .dfi_ctrlupd_ack         (dfi_ctrlupd_ack),
         .dfi_ctrlupd_req         (dfi_ctrlupd_req),
         .dfi_phyupd_ack          (dfi_phyupd_ack),
         .dfi_phyupd_req          (dfi_phyupd_req),
         .dfi_phyupd_type         (dfi_phyupd_type),
         .dfi_dram_clk_disable    (dfi_dram_clk_disable),
         .dfi_init_complete       (dfi_init_complete),
         //.dfi_rdlvl_en            (dfi_rdlvl_en),
         //.dfi_rdlvl_gate_en       (dfi_rdlvl_gate_en),
         //.dfi_rdlvl_req           (dfi_rdlvl_req),
         //.dfi_rdlvl_gate_req      (dfi_rdlvl_gate_req),
         //.dfi_rdlvl_load          (dfi_rdlvl_load),
         //.dfi_rdlvl_resp          (dfi_rdlvl_resp),
         //.dfi_rdlvl_cs_n          (dfi_rdlvl_cs_n),
         //.dfi_rdlvl_edge          (dfi_rdlvl_edge),
         //.dfi_rdlvl_delay_0       (dfi_rdlvl_delay_0),
         //.dfi_rdlvl_delay_1       (dfi_rdlvl_delay_1),
         //.dfi_rdlvl_delay_2       (dfi_rdlvl_delay_2),
         //.dfi_rdlvl_delay_3       (dfi_rdlvl_delay_3),
         //.dfi_rdlvl_gate_delay_0  (dfi_rdlvl_gate_delay_0),
         //.dfi_rdlvl_gate_delay_1  (dfi_rdlvl_gate_delay_1),
         //.dfi_rdlvl_gate_delay_2  (dfi_rdlvl_gate_delay_2),
         //.dfi_rdlvl_gate_delay_3  (dfi_rdlvl_gate_delay_3),
         //.dfi_rdlvl_mode          (dfi_rdlvl_mode),
         //.dfi_rdlvl_gate_mode     (dfi_rdlvl_gate_mode),
         //.dfi_wrlvl_en            (dfi_wrlvl_en),
         //.dfi_wrlvl_req           (dfi_wrlvl_req),
         //.dfi_wrlvl_load          (dfi_wrlvl_load),
         //.dfi_wrlvl_resp          (dfi_wrlvl_resp),
         //.dfi_wrlvl_cs_n          (dfi_wrlvl_cs_n),
         //.dfi_wrlvl_delay_0       (dfi_wrlvl_delay_0),
         //.dfi_wrlvl_delay_1       (dfi_wrlvl_delay_1),
         //.dfi_wrlvl_delay_2       (dfi_wrlvl_delay_2),
         //.dfi_wrlvl_delay_3       (dfi_wrlvl_delay_3),
         //.dfi_wrlvl_mode          (dfi_wrlvl_mode),
         //.dfi_wrlvl_strobe        (dfi_wrlvl_strobe)  
         .dfi_rdlvl_en            (0),             
         .dfi_rdlvl_gate_en       (0),
         .dfi_rdlvl_req           (0),
         .dfi_rdlvl_gate_req      (0),
         .dfi_rdlvl_load          (0),
         .dfi_rdlvl_resp          (0),
         .dfi_rdlvl_cs_n          (0),
         .dfi_rdlvl_edge          (0),
         .dfi_rdlvl_delay_0       (0),
         .dfi_rdlvl_delay_1       (0),
         .dfi_rdlvl_delay_2       (0),
         .dfi_rdlvl_delay_3       (0),
         .dfi_rdlvl_gate_delay_0  (0),
         .dfi_rdlvl_gate_delay_1  (0),
         .dfi_rdlvl_gate_delay_2  (0),
         .dfi_rdlvl_gate_delay_3  (0),
         .dfi_rdlvl_mode          (2'b00),
         .dfi_rdlvl_gate_mode     (0),
         .dfi_wrlvl_en            (0),
         .dfi_wrlvl_req           (0),
         .dfi_wrlvl_load          (0),
         .dfi_wrlvl_resp          (0),
         .dfi_wrlvl_cs_n          (0),
         .dfi_wrlvl_delay_0       (0),
         .dfi_wrlvl_delay_1       (0),
         .dfi_wrlvl_delay_2       (0),
         .dfi_wrlvl_delay_3       (0),
         .dfi_wrlvl_mode          (2'b00),
         .dfi_wrlvl_strobe        (0)
  );                    
`endif
*/

  // ---------------------------------------------------------------------------
  // DBI support function
  // ---------------------------------------------------------------------------

  function [pPUB_NO_OF_CMDS*pNO_OF_BYTES*16 -1:0] data_dbi;
    input reg [pPUB_NO_OF_CMDS*pNO_OF_BYTES*16 -1:0] in_word;
    input reg [pNO_OF_BYTES*4                  -1:0] in_dbi_n;

      integer                                        byte_idx;
      integer                                        dx_idx;
      reg     [pPUB_NO_OF_CMDS*pNO_OF_BYTES*16 -1:0] word_dbi;

    begin
      for (byte_idx = 0; byte_idx < pNO_OF_BYTES*4; byte_idx = byte_idx + 1) begin
        if (in_dbi_n[byte_idx] == 1'b0) word_dbi[(byte_idx * 8) +: 8] = ~in_word[(byte_idx * 8) +: 8];
        else                            word_dbi[(byte_idx * 8) +: 8] =  in_word[(byte_idx * 8) +: 8];
      end
      data_dbi = word_dbi;
    end
  endfunction

endmodule // ddr_tb
