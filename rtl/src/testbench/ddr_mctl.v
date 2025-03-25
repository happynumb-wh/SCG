/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys Incorporated.                                  *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR Memory Controller Bus Functional Model                    *
 *                                                                            *
 *****************************************************************************/

module ddr_mctl
  #(
    // configurable design parameters
    parameter pNO_OF_BYTES      = 9, 
    parameter pNO_OF_RANKS_CHNL = 2,
    parameter pNO_OF_RANKS      = 2,
    parameter pCK_WIDTH         = 3,
    parameter pBANK_WIDTH       = 3,
    parameter pBG_WIDTH         = `DWC_BG_WIDTH,
    parameter pADDR_WIDTH       = 16,
    parameter pCLK_NX           = `CLK_NX, // PHY clock is 2x or 1x controller clock
    parameter pNO_OF_DX_DQS     = `DWC_DX_NO_OF_DQS, // number of DQS signals per DX macro
    parameter pNUM_LANES        = pNO_OF_DX_DQS * pNO_OF_BYTES,
    parameter pLPDDRX_EN        = 0,       // LPDDR3/2 support
    parameter pCHANNEL_NO       = 0,
    
    // if LPDDR2 mode support is enabled, the DFI address is 20 bits wide
    parameter pLPDDR_ADDR_WIDTH = 20,
    parameter pXADDR_WIDTH      = pADDR_WIDTH,

    parameter pFRQ_RATIO        = (`CLK_NX == 1) ? 2 : 1,

    // extend MCTL address to avoid index errora
    parameter pMCTL_BANK_WIDTH  = pBANK_WIDTH,
    parameter pMCTL_BG_WIDTH    = pBG_WIDTH,
    parameter pMCTL_ADDR_WIDTH  = (pADDR_WIDTH > 13) ? pADDR_WIDTH : 14,
    parameter pMCTL_XADDR_WIDTH = pMCTL_ADDR_WIDTH,
    
    // SDRAM bus sizes
    parameter pROW_WIDTH        = pMCTL_ADDR_WIDTH, // SDRAM row address width
    parameter pCOL_WIDTH        = 12,               // SDRAM col address width                // SDRAM chip select width (***TBD change this to 4 later)
    parameter pRANK_WIDTH       = `SDRAM_RANK_WIDTH, // SDRAM rank (CS# + CID) address width     

    // bus sizes for chip logic interface
    parameter pCMD_WIDTH        = 4,                // command bus width
    parameter pCMD_FLAG_WIDTH   = 9,                // command flag width

    parameter pHOST_ADDR_WIDTH  = `HOST_ADDR_WIDTH,
    
    // data width for the controller: includes data and data masks
    parameter pCTRL_DATA_WIDTH  = pNO_OF_BYTES*pCLK_NX*16 + pNUM_LANES*pCLK_NX*2,
  
    // write latency data pipeline: includes write flag + data mask + and data
    // ODT pipeline: includes: HOC flag + write flag + ODT flag for each rank
    parameter pWL_DPIPE_WIDTH   = 1 + pCTRL_DATA_WIDTH,
    parameter pWL_DPIPE_DEPTH   = 32,
    parameter pWL_OPIPE_WIDTH   = 2 + pNO_OF_RANKS,
    parameter pWL_OPIPE_MAX     = 32,
    parameter pWL_OPIPE_MIN     = 3,
  
    // read latency control pipeline: includes read flag
    parameter pRL_CPIPE_WIDTH   = 1,
    parameter pRL_CPIPE_DEPTH   = 32,

    parameter pBURST_WIDTH      = 3, // width of burst variables
    parameter pRFSH_BURST_WIDTH = 4,
  
    // timing parameters width
    parameter tMRD_WIDTH        = 5,
    parameter tMOD_WIDTH        = 5,
    parameter tRTP_WIDTH        = 4,
    parameter tRP_WIDTH         = 7,
    parameter tRFC_WIDTH        = 10,
    parameter tWTR_WIDTH        = 5,
    parameter tRCD_WIDTH        = 7,
    parameter tRC_WIDTH         = 8,

   `ifndef LPDDRX
    // DDR3/2 tRPA_WIDTH
    parameter tRPA_WIDTH        = tRP_WIDTH,
   `else
    // LPDDR2/3 tRPA_WIDTH
    parameter tRPA_WIDTH        = (tRP_WIDTH+1),
   `endif
    parameter tRRD_WIDTH        = 6,
    parameter tFAW_WIDTH        = 8,
    parameter tRAS_WIDTH        = 6,
    parameter tRFPRD_WIDTH      = 17,
    parameter tBCSTAB_WIDTH     = 14,
    parameter tBCMRD_WIDTH      = 4,
    parameter tREFPRD_WIDTH     = 18,
    
    // derived timing parameters width
    parameter CL_WIDTH          = 6,
    parameter tWR_WIDTH         = 5,
    parameter WL_WIDTH          = 6,
    parameter RL_WIDTH          = 6,
    parameter tACT2RW_WIDTH     = 5,
    parameter tWR2PRE_WIDTH     = 7,
    parameter tWRL_WIDTH        = 6,
    parameter tOL_WIDTH         = 4,
    parameter tRD2PRE_WIDTH     = 7,
    parameter tRD2WR_WIDTH      = 5,
    parameter tWR2RD_WIDTH      = 6,
    parameter tCCD_WIDTH        = 4
   )
   (
    // interface to global signals
    input  wire                               rst_b,       // asynchronous reset
    input  wire                               clk,         // input clock
    input  wire                               ctl_sdram_init, // SDRAM init by controller
    input  wire                               hdr_mode,    // HDR mode
    input  wire                               hdr_odd_cmd, // HDR command is on odd slot
           
    // interface to configuration unit       
    input  wire [pBURST_WIDTH-1:0]            burst_len,   // burst length
    input  wire                               ddr4_mode,   // DDR4 mode
    input  wire                               ddr3_mode,   // DDR3 mode
    input  wire                               ddr2_mode,   // DDR2 mode
    input  wire                               lpddr3_mode, // LPDDR3 mode
    input  wire                               lpddr2_mode, // LPDDR2 mode
    input  wire [4:0]                         sdram_chip,  // DDR SDRAM chip configuration
    input  wire                               ddr3_blotf,  // DDR3 BL 4/8 on-the-fly
    input  wire                               ddr_2t,      // DDR 2T timing
    input  wire [tWRL_WIDTH-1:0]              t_wl,        // write latency (minus 1)
    input  wire [tWRL_WIDTH-1:0]              t_rl,        // read latency (minus 2)
    input  wire [tOL_WIDTH-1:0]               t_ol,        // ODT latency
    input  wire [2:0]                         t_orwl_odd,  // latency is odd number
    input  wire                               t_rl_eq_3,   // special case RL = 3
    input  wire [tMRD_WIDTH-1:0]              t_mrd,       // load mode to load mode
    input  wire [tMOD_WIDTH-1:0]              t_mod,       // load mode to other instructions
    input  wire [tRP_WIDTH-1:0]               t_rp,        // precharge to activate (-2)
    input  wire [tRPA_WIDTH-1:0]              t_rpa,       // precharge all to any (-2)
    input  wire [tRAS_WIDTH-1:0]              t_ras,       // activate to precharge
    input  wire [tRRD_WIDTH-1:0]              t_rrd,       // activate to activate
    input  wire [tRC_WIDTH-1:0]               t_rc,        // activate to activate
    input  wire [tFAW_WIDTH-1:0]              t_faw,       // 4-bank active window
    input  wire [tRFC_WIDTH-1:0]              t_rfc,       // refresh to refresh (min)
    input  wire [tBCSTAB_WIDTH-1:0]           t_bcstab,    // RDIMM stabilization
    input  wire [tBCMRD_WIDTH-1:0]            t_bcmrd,     // RDIMM load mode to load mode
    input  wire [tRP_WIDTH-1:0]               t_pre2act,   // precharge to activate (-1)
    input  wire [tACT2RW_WIDTH-1:0]           t_act2rw,    // activate to read/write
    input  wire [tRD2PRE_WIDTH-1:0]           t_rd2pre,    // read to precharge
    input  wire [tWR2PRE_WIDTH-1:0]           t_wr2pre,    // write to precharge
    input  wire [tRD2WR_WIDTH-1:0]            t_rd2wr,     // read to write
    input  wire [tWR2RD_WIDTH-1:0]            t_wr2rd,     // write to read
    input  wire [tRD2PRE_WIDTH-1:0]           t_rdap2act,  // read w/ precharge to activate
    input  wire [tWR2PRE_WIDTH-1:0]           t_wrap2act,  // write w/ precharge to activate
    input  wire [tCCD_WIDTH-1:0]              t_ccd_l,     // cas to cas command delay for the same bank group
    input  wire [tCCD_WIDTH-1:0]              t_ccd_s,     // cas to cas command delay for the diff bank group

    input  wire [tREFPRD_WIDTH-1:0]           rfsh_prd,    // refresh period
    input  wire [pRFSH_BURST_WIDTH-1:0]       rfsh_burst,  // refresh burst
    input  wire                               rfsh_en,     // refresh enable
    
    // interface to host port    
    input  wire                               host_rqvld,  // host port request valid
    input  wire [pCMD_WIDTH             -1:0] host_cmd,    // host port command bus
    input  wire [pHOST_ADDR_WIDTH       -1:0] host_a,      // host port address
    input  wire [pNUM_LANES*pCLK_NX*2   -1:0] host_dm,     // host port data mask
    input  wire [pNO_OF_BYTES*pCLK_NX*16-1:0] host_d,      // host port data input
    input  wire [pCMD_FLAG_WIDTH        -1:0] host_cmd_flag,  // host port command flag
    output wire                               host_rdy,    // host port ready
    output wire                               host_qvld,   // host port read output valid
    output wire [pNO_OF_BYTES*pCLK_NX*16-1:0] host_q,      // host port read data output
  
    // interface to global signals
    output wire [pCK_WIDTH              -1:0] ck_inv,
    output wire [pNO_OF_BYTES           -1:0] t_byte_wl_odd,
    output wire [pNO_OF_BYTES           -1:0] t_byte_rl_odd,
                                 
    // DFI Control Interface     
    output wire                               dfi_reset_n,
    output wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cke,
    output wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_odt,
    output wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cs_n,
    output wire [`DWC_CID_WIDTH*pCLK_NX -1:0] dfi_cid,
    output wire [pCLK_NX                -1:0] dfi_ras_n,
    output wire [pCLK_NX                -1:0] dfi_cas_n,
    output wire [pCLK_NX                -1:0] dfi_we_n,
    output wire [pBANK_WIDTH*pCLK_NX    -1:0] dfi_bank,
    output wire [pXADDR_WIDTH*pCLK_NX   -1:0] dfi_address,
    output wire [pCLK_NX                -1:0] dfi_act_n,
    output wire [pBG_WIDTH*pCLK_NX      -1:0] dfi_bg,
                                 
    // DFI Write Data Interface  
    output wire [pNUM_LANES*pCLK_NX     -1:0] dfi_wrdata_en,
    output wire [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_wrdata,
    output wire [pNUM_LANES*pCLK_NX*2   -1:0] dfi_wrdata_mask,
                                 
    // DFI Read Data Interface   
    output wire [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_en,
    input  wire [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_valid,
    input  wire [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_rddata,
                                 
    // DFI Update Interface      
    output wire                               dfi_ctrlupd_req,
    input  wire                               dfi_ctrlupd_ack,
    input  wire                               dfi_phyupd_req,
    output wire                               dfi_phyupd_ack,
    input  wire  [1:0]                        dfi_phyupd_type,
                                 
    // DFI Status Interface      
    output wire                               dfi_init_start,
    output wire [pNO_OF_BYTES           -1:0] dfi_data_byte_disable,
    output wire [pCK_WIDTH-1:0]               dfi_dram_clk_disable,
    input  wire                               dfi_init_complete,
    output wire [pCLK_NX                -1:0] dfi_parity_in,
    input  wire [pCLK_NX                -1:0] dfi_alert_n,
                                 
    // DFI Training Interface
    `ifdef DWC_USE_SHARED_AC_TB    
      input  wire [pCLK_NX*pNO_OF_RANKS/2   -1:0] dfi_phylvl_req_cs_n,
      output wire [pCLK_NX*pNO_OF_RANKS/2   -1:0] dfi_phylvl_ack_cs_n,
    `else   
      input  wire [pCLK_NX*pNO_OF_RANKS     -1:0] dfi_phylvl_req_cs_n,
      output wire [pCLK_NX*pNO_OF_RANKS     -1:0] dfi_phylvl_ack_cs_n,
    `endif

    input  wire  [1                       :0] dfi_rdlvl_mode,
    input  wire  [1                       :0] dfi_rdlvl_gate_mode,
    input  wire  [1                       :0] dfi_wrlvl_mode,
  
    // Low Power Control Interface
    output wire                               dfi_lp_data_req,
    output wire                               dfi_lp_ctrl_req,
    output wire [3                        :0] dfi_lp_wakeup,  
    input  wire                               dfi_lp_ack 
   );
  
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  
  // control logic encoding
  // ----------------------
  // SDRAM controller commands
  // command bits [3:0]:
  parameter NOP               = 4'b0000, // no operation
            LOAD_MODE         = 4'b0001, // SDRAM load mode register
            SELF_REFRESH      = 4'b0010, // SDRAM self refresh entry
            REFRESH           = 4'b0011, // SDRAM refresh
            PRECHARGE         = 4'b0100, // SDRAM single bank precharge
            PRECHARGE_ALL     = 4'b0101, // SDRAM all banks precharge
            ACTIVATE          = 4'b0110, // SDRAM bank activate
            SPECIAL_CMD       = 4'b0111, // SDRAM/controller special commands
            WRITE             = 4'b1000, // SDRAM write
            WRITE_PRECHG      = 4'b1001, // SDRAM write with auto-precharge
            READ              = 4'b1010, // SDRAM read
            READ_PRECHG       = 4'b1011, // SDRAM read with auto-precharge

            ZQCAL_SHORT       = 4'b1100, // SDRAM ZQ calibration short
            READ_MODE         = 4'b1100, // LPDDRX read mode register

            ZQCAL_LONG        = 4'b1101, // SDRAM ZQ calibration long
            TERMINATE         = 4'b1101, // LPDDRX Burst terminate

            POWER_DOWN        = 4'b1110, // SDRAM power down entry
            SDRAM_NOP         = 4'b1111; // SDRAM NOP
            
  
  // command bits [3:1]: 
  parameter ANY_PRECHARGE     = 3'b010,
            ANY_WRITE         = 3'b100,
            ANY_READ          = 3'b101,
            ANY_ZQCAL         = 3'b110;
  
  // command bits [3:2]:   
  parameter READ_WRITE        = 2'b10; 
  parameter ACTIVATE_CMD      = 3'b011;

  // DDR SDRAM chip configuration
  // ----------------------------
  // bit positions = {density, I/O width}
  parameter DDR_256Mbx4       = 5'b000_00,  // 256Mb (x4, x8, x16, x32)
            DDR_256Mbx8       = 5'b000_01,
            DDR_256Mbx16      = 5'b000_10,
            DDR_256Mbx32      = 5'b000_11,
                                   
            DDR_512Mbx4       = 5'b001_00,  // 512Mb (x4, x8, x16, x32)
            DDR_512Mbx8       = 5'b001_01,
            DDR_512Mbx16      = 5'b001_10,
            DDR_512Mbx32      = 5'b001_11,
                                   
            DDR_1Gbx4         = 5'b010_00,  // 1Gb (x4, x8, x16, x32)
            DDR_1Gbx8         = 5'b010_01,
            DDR_1Gbx16        = 5'b010_10,
            DDR_1Gbx32        = 5'b010_11,
                                   
            DDR_2Gbx4         = 5'b011_00,  // 2Gb (x4, x8, x16, x32)
            DDR_2Gbx8         = 5'b011_01,
            DDR_2Gbx16        = 5'b011_10,
            DDR_2Gbx32        = 5'b011_11,
                                   
            DDR_4Gbx4         = 5'b100_00,  // 4Gb (x4, x8, x16, x32)
            DDR_4Gbx8         = 5'b100_01,
            DDR_4Gbx16        = 5'b100_10,
            DDR_4Gbx32        = 5'b100_11,
                                   
            DDR_8Gbx4         = 5'b101_00,  // 8Gb (x4, x8, x16, x32)
            DDR_8Gbx8         = 5'b101_01,
            DDR_8Gbx16        = 5'b101_10,
            DDR_8Gbx32        = 5'b101_11,

            DDR_16Gbx4        = 5'b110_00,  // 16Gb (x4, x8, x16, x32)
            DDR_16Gbx8        = 5'b110_01,
            DDR_16Gbx16       = 5'b110_10,
            DDR_16Gbx32       = 5'b110_11;
  
  
  parameter MAX_RANKS         = 16;
  parameter MAX_PRANKS        = 12;
  parameter pNO_OF_PRANKS     = `DWC_NO_OF_RANKS;  
  parameter MAX_BANKS         = 8;
  parameter MAX_BANK_GROUPS   = 4;
  parameter MAX_PAGES         = MAX_RANKS * MAX_BANKS* MAX_BANK_GROUPS; // maximum number of pages
  parameter MAX_BG_PAGES      = MAX_RANKS * MAX_BANK_GROUPS; // maximum number of bg pages
  parameter MAX_ROWS          = (1<<pROW_WIDTH);
  parameter BANK_CLOSED       = MAX_ROWS;

`ifdef DWC_DDRPHY_EMUL_XILINX
  parameter tRD_RNK2RNK       = 8; // rank-to-rank timing for reads
  parameter tEO_RD2RRD        = 7 ; // read-to-read on -heoc
`else
  parameter tRD_RNK2RNK       = 2; // rank-to-rank timing for reads
`endif
  parameter tWR_RNK2RNK       = 6; // rank-to-rank timing for write

  parameter pRFSH_CNTR_WIDTH  = tREFPRD_WIDTH;
  parameter pRFSH_STATE_WIDTH = 3;
  parameter RFSH_IDLE         = 3'b000;
  parameter RFSH_PREALL       = 3'b001;
  parameter RFSH_REFRESH      = 3'b010;
  parameter RFSH_POST         = 3'b011;

  // total delay from a host read command to read data valid coming back
  // (this is without the extra latency due CL+AL+RSL
  parameter tHOST2DFI_CMDLAT  = 4;
  parameter tPUB_CMDLAT       = 0;
  parameter tPHY_CMDLAT       = 0.5;
  parameter tPHY_RDLAT        = 3.5;
  parameter tPUB_RDLAT        = 1;
  parameter tHOST2DFI_RDLAT   = tHOST2DFI_CMDLAT + tPUB_CMDLAT + 
                                tPHY_CMDLAT + tPHY_RDLAT + tPUB_RDLAT;
  
`ifdef DWC_NO_OF_3DS_STACKS
  parameter pNO_OF_3DS_STACKS = `DWC_NO_OF_3DS_STACKS;
`else
  parameter pNO_OF_3DS_STACKS = 0;
`endif  
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  // host input request and address mapped request
  wire                               host_cmd_vld;
  wire                               host_cmd_ack;
  wire [pHOST_ADDR_WIDTH       -1:0] host_addr;
  reg  [pRANK_WIDTH            -1:0] host_rank;
  reg  [pBANK_WIDTH            -1:0] host_bank;
  reg  [pBG_WIDTH              -1:0] host_bg;
  reg  [pROW_WIDTH             -1:0] host_row;
  reg  [pCOL_WIDTH             -1:0] host_col;
  wire [pCTRL_DATA_WIDTH       -1:0] host_data;
  wire                               host_ddr3_bl4;
  wire                               host_gp_flag;
  wire [5:0]                         host_ck_en;
  wire                               host_rfsh_inh;
  reg  [pBURST_WIDTH           -1:0] host_burst_cnt;
  reg                                host_last_data;
  reg                                host_first_data;
  reg  [pCMD_WIDTH             -1:0] host_bl4_cmd;
  reg  [pHOST_ADDR_WIDTH       -1:0] host_bl4_addr;
  wire [pCMD_WIDTH             -1:0] host_cmd_mx;
  wire [pHOST_ADDR_WIDTH       -1:0] host_addr_mx;
  wire                               host_rd_cmd;
  wire                               host_wr_cmd;
  wire                               host_rw_cmd;
  wire                               host_bst_cmd;
  reg                                host_bl4_rdnop;
  reg                                host_bl4_nop;
  reg                                host_bl4_nop_hoc;
  reg                                host_bl4_last_nop;
  wire                               host_bl4_last_data;
  wire                               host_wr_hoc;
  wire                               host_rd_hoc;
  reg  [18                     -1:0] hmap_row;
                                     
  reg                                init_cke;
  reg                                first_init_cke;
  reg                                refresh_pending;
  reg                                activate_pending;
  reg                                activate_pending_ff;
  reg                                precharge_pending;
  reg                                command_pending;
  reg                                no_command;
  reg                                timing_met;

  reg                                rdrnk_xcheck;
  wire [3:0]                         rdrnk_all_xspace;
  reg  [3:0]                         rdrnk_all_xspace_p0;
  reg  [3:0]                         rdrnk_all_xspace_p1;
  reg  [3:0]                         rdrnk_all_xspace_p2;
  wire                               rdrnk_any_xspace;
  wire                               rdrnk_rsl_xspace;
  wire                               rdrnk_xt_xspace_0;
  wire                               rdrnk_xt_xspace_1;
  wire                               rdrnk_xt_xspace_2;
  reg                                wrrnk_xcheck;
  wire [3:0]                         wrrnk_all_xspace;
  reg  [3:0]                         wrrnk_all_xspace_p0;
  reg  [3:0]                         wrrnk_all_xspace_p1;
  reg  [3:0]                         wrrnk_all_xspace_p2;
  wire                               wrrnk_any_xspace;
  wire                               wrrnk_wsl_xspace;
  wire                               wrrnk_xt_xspace_0;
  wire                               wrrnk_xt_xspace_1;
  wire                               wrrnk_xt_xspace_2;

  // timing parameters and counters
  reg  [tMRD_WIDTH-1:0]              tx_mrd;       // load mode to load mode
  reg  [tMOD_WIDTH-1:0]              tx_mod;       // load mode to other instructions
  reg  [tRP_WIDTH-1:0]               tx_rp;        // precharge to activate (-2)
  reg  [tRPA_WIDTH-1:0]              tx_rpa;       // precharge all to any (-2)
  reg  [tRAS_WIDTH-1:0]              tx_ras;       // activate to precharge
  reg  [tRRD_WIDTH-1:0]              tx_rrd;       // activate to activate
  reg  [tRC_WIDTH-1:0]               tx_rc;        // activate to activate
  reg  [tFAW_WIDTH-1:0]              tx_faw;       // 4-bank active window
  reg  [tRFC_WIDTH-1:0]              tx_rfc;       // refresh to refresh (min)
  reg  [tBCSTAB_WIDTH-1:0]           tx_bcstab;    // RDIMM stabilization
  reg  [tBCMRD_WIDTH-1:0]            tx_bcmrd;     // RDIMM load mode to load mode
  reg  [tRP_WIDTH-1:0]               tx_pre2act;   // precharge to activate (-1)
  reg  [tACT2RW_WIDTH-1:0]           tx_act2rw;    // activate to read/write
  reg  [tRD2PRE_WIDTH-1:0]           tx_rd2pre;    // read to precharge
  reg  [tWR2PRE_WIDTH-1:0]           tx_wr2pre;    // write to precharge
  reg  [tRD2WR_WIDTH-1:0]            tx_rd2wr;     // read to write
  reg  [tWR2RD_WIDTH-1:0]            tx_wr2rd;     // write to read
  reg  [tRD2PRE_WIDTH-1:0]           tx_rdap2act;  // read w/ precharge to activate
  reg  [tWR2PRE_WIDTH-1:0]           tx_wrap2act;  // write w/ precharge to activate
  reg  [tCCD_WIDTH   -1:0]           tx_ccd_l;     // cas to cas command delay for the same bank group
  reg  [tCCD_WIDTH   -1:0]           tx_ccd_s;     // cas to cas command delay for the diff bank group
     
  wire [3:0]                         t_rdrnk;
  wire [3:0]                         t_wrrnk;
  reg  [3:0]                         tx_rdrnk;
  reg  [3:0]                         tx_wrrnk;
     
  reg  [tRPA_WIDTH-1:0]              t_rp_cntr   [0:MAX_PAGES-1]; // precharge to activate (tRPA_WIDTH is correct)
  reg  [tRC_WIDTH-1:0]               t_rc_cntr   [0:MAX_PAGES-1]; // activate to activate
  reg  [tRAS_WIDTH-1:0]              t_ras_cntr  [0:MAX_PAGES-1]; // activate to precharge
  reg  [tACT2RW_WIDTH-1:0]           t_rcd_cntr  [0:MAX_PAGES-1]; // activate to read/write
  reg  [tWR2PRE_WIDTH-1:0]           t_wtp_cntr  [0:MAX_PAGES-1]; // write to precharge
  reg  [tRD2PRE_WIDTH-1:0]           t_rtp_cntr  [0:MAX_PAGES-1]; // read to precharge
  reg  [tWR2PRE_WIDTH-1:0]           t_wtp       [0:MAX_PAGES-1]; // write to precharge
  reg  [tRD2PRE_WIDTH-1:0]           t_rtp       [0:MAX_PAGES-1]; // read to precharge
  reg  [tCCD_WIDTH   -1:0]           t_ccd_l_cntr[0:MAX_BG_PAGES-1]; // cas to cas command delay for the same bank group
  reg  [tCCD_WIDTH   -1:0]           t_ccd_s_cntr[0:MAX_PAGES-1]; // cas to cas command delay for the diff bank group

reg  [tCCD_WIDTH   -1:0]           rob_host_t_ccd_l_cntr; // cas to cas command delay for the same bank group
reg  [tCCD_WIDTH   -1:0]           rob_host_t_ccd_s_cntr; // cas to cas command delay for the diff bank group
     
  reg  [tFAW_WIDTH-1:0]              t_faw_cntr [0:3]; // 4-bank active window
  reg  [tWR2RD_WIDTH-1:0]            t_wtr_cntr;       // write to read
  reg  [tRD2WR_WIDTH-1:0]            t_rtw_cntr;       // read to write
  reg  [tRRD_WIDTH-1:0]              t_rrd_cntr;       // activate to activate (different banks)
  reg  [tMRD_WIDTH-1:0]              t_mrd_cntr;       // load mode to load mode
  reg  [tMOD_WIDTH-1:0]              t_mod_cntr;       // load mode to other instructions
  reg  [tRFC_WIDTH-1:0]              t_rfc_cntr;       // refresh to refresh (min)
  reg  [tRPA_WIDTH-1:0]              t_rpa_cntr;       // precharge all to any command
  reg  [tBCSTAB_WIDTH-1:0]           t_bcstab_cntr;    // RDIMM stabilization
  reg  [tBCMRD_WIDTH-1:0]            t_bcmrd_cntr;     // RDIMM load mode to load mode
     
  reg  [3:0]                         t_rdrnk_cntr;     // read-to-read rank timing
  reg  [3:0]                         t_wrrnk_cntr;     // write-to-write rank timing

  reg  [MAX_PAGES-1:0]               t_rp_hoc_ff;
  reg  [MAX_PAGES-1:0]               t_rc_hoc_ff;
  reg  [MAX_PAGES-1:0]               t_wtp_hoc_ff;
  reg  [MAX_PAGES-1:0]               t_rtp_hoc_ff;
  reg  [MAX_PAGES-1:0]               t_ccd_s_hoc_ff;
  reg  [MAX_BG_PAGES-1:0]            t_ccd_l_hoc_ff;
  
  reg                                t_faw_hoc_ff;
  reg                                t_rpa_hoc_ff;
  reg                                t_rrd_hoc_ff;
  reg                                t_wtr_hoc_ff;
  reg                                t_rtw_hoc_ff;
  reg                                t_mrd_hoc_ff;
  reg                                t_rfc_hoc_ff;
  reg                                t_bcstab_hoc_ff;
  reg                                t_bcmrd_hoc_ff;

  reg  [MAX_PAGES-1:0]               rp_hoc_to_hec;  // write/read odd command followed ...
  reg  [MAX_PAGES-1:0]               rc_hoc_to_hec;  // by even command
  reg  [MAX_PAGES-1:0]               ras_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               rcd_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               wtp_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               rtp_hoc_to_hec;
  reg  [MAX_BG_PAGES-1:0]            ccd_l_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               ccd_s_hoc_to_hec;
  
  reg                                faw_hoc_to_hec;
  reg                                rpa_hoc_to_hec;
  reg                                rrd_hoc_to_hec;
  reg                                wtr_hoc_to_hec;
  reg                                rtw_hoc_to_hec;
  reg                                mrd_hoc_to_hec;
  reg                                mod_hoc_to_hec;
  reg                                rfc_hoc_to_hec;
  reg                                bcstab_hoc_to_hec;
  reg                                bcmrd_hoc_to_hec;

  reg  [MAX_PAGES-1:0]               t_rp_hoc_to_hec;  // write/read odd command followed ...
  reg  [MAX_PAGES-1:0]               t_rc_hoc_to_hec;  // by even command
  reg  [MAX_PAGES-1:0]               t_ras_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               t_rcd_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               t_wtp_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               t_rtp_hoc_to_hec;
  reg  [MAX_BG_PAGES-1:0]            t_ccd_l_hoc_to_hec;
  reg  [MAX_PAGES-1:0]               t_ccd_s_hoc_to_hec;
  
  reg                                t_faw_hoc_to_hec;
  reg                                t_rpa_hoc_to_hec;
  reg                                t_rrd_hoc_to_hec;
  reg                                t_wtr_hoc_to_hec;
  reg                                t_rtw_hoc_to_hec;
  reg                                t_mrd_hoc_to_hec;
  reg                                t_mod_hoc_to_hec;
  reg                                t_rfc_hoc_to_hec;
  reg                                t_bcstab_hoc_to_hec;
  reg                                t_bcmrd_hoc_to_hec;
 
  reg                                t_wr_last_hoc;
  reg                                t_rd_last_hoc;
  
  reg                                hdr_odd_cmd_ff;
  reg                                odt_hdr_odd_cmd;
  reg                                odt_hdr_odd_cmd_ff;
  reg                                hdr_odd_cmd_array [3:0];  // array to store odd and even cmd
  reg                                hdr_odd_cmd_valid [3:0];  // array to store odd and even cmd
  reg                                hdr_odd_cmd_bl4   [3:0];  // array to store odd and even cmd
  reg [1:0]                          wr_odd_even_ptr;
  reg [1:0]                          wr_odd_even_ptr_d0;
  reg [1:0]                          wr_odd_even_ptr_d1;
  reg [1:0]                          wr_odd_even_ptr_d2;
  reg [1:0]                          wr_odd_even_ptr_d3;
  reg [1:0]                          rd_odd_even_ptr;
  reg [1:0]                          rd_odd_even_ptr_reg;
  reg                                last_cmd_odd;
  reg                                rw_bl4;
  reg                                rw_bl4_reg;

  reg                                inc_cnt;
  reg                                inc_cnt_ff;
                              
  reg                                hdr_odd_cmd_reg;
  reg                                hdr_odd_cmd_d0;
  reg                                hdr_odd_cmd_d1;
  reg                                hdr_odd_cmd_d2;

  reg                                sys_hdr_odd_cmd_d0;
  wire                               hdr_odd_cmd_stable;
  reg                                use_rnd_even_odd_timing;

  reg  [7:0]                         rl_cntr;
  wire                               rddata_pending;
  
  reg  [pCMD_WIDTH             -1:0] cmd_ff;
  reg  [pRANK_WIDTH            -1:0] rank_ff;
  reg  [pRANK_WIDTH            -1:0] rdwr_rank_ff;
  reg  [pMCTL_BANK_WIDTH       -1:0] bank_ff;
  reg  [pMCTL_BG_WIDTH         -1:0] bg_ff;
  wire [pMCTL_ADDR_WIDTH       -1:0] addr_ff;
  reg  [pROW_WIDTH             -1:0] row_ff;
  reg  [pCOL_WIDTH             -1:0] col_ff;
  reg  [pCTRL_DATA_WIDTH       -1:0] data_ff;
  wire [31:0]                        host_page;
  wire [31:0]                        host_bg_page;
  reg  [pROW_WIDTH               :0] bank_open [0:MAX_PAGES-1];
  reg  [pRANK_WIDTH            -1:0] rd_rank_ff;
  reg                                gp_flag_ff;
  reg  [5:0]                         ck_en_ff;
  reg                                bdrift_err_q;
  reg  [pHOST_ADDR_WIDTH       -1:0] caddr_ff, caddr_ff_1;
 
  reg  [pBURST_WIDTH           -1:0] cmd_ff_rdburst_cnt;
  wire                               cmd_ff_rd_burst;
  wire                               cmd_ff_rd_cmd;
  wire                               cmd_ff_last_rd;
     
  reg  [pCK_WIDTH*2            -1:0] sdr_ck_en;
  wire [pNO_OF_RANKS           -1:0] sdr_cke;
  reg  [pNO_OF_RANKS           -1:0] sdr_cke_1;
  reg  [pNO_OF_RANKS           -1:0] sdr_cke_1_reg;
  reg  [pNO_OF_RANKS           -1:0] sdr_odt,     sdr_odt_1, sdr_odt_ff, sdr_odt_ff_reg, sdr_odt_1_ff;
  reg  [pNO_OF_RANKS           -1:0] sdr_cs_b,    sdr_cs_b_1;
  reg                                sdr_ras_b,   sdr_ras_b_1;
  reg                                sdr_cas_b,   sdr_cas_b_1;
  reg                                sdr_we_b,    sdr_we_b_1;
  reg  [pMCTL_BANK_WIDTH       -1:0] sdr_ba,      sdr_ba_1;
  reg  [pMCTL_XADDR_WIDTH      -1:0] sdr_a,       sdr_a_1;
  reg                                sdr_act_b,   sdr_act_b_1;
  reg  [pMCTL_BG_WIDTH         -1:0] sdr_bg,      sdr_bg_1;
  reg  [`DWC_CID_WIDTH         -1:0] sdr_cid,     sdr_cid_1;
  reg  [pNO_OF_RANKS           -1:0] sdr_odt_mxd, sdr_odt_1_mxd;
  reg  [pNO_OF_RANKS           -1:0] cs_b,        cs_b_1;
  reg  [pNO_OF_RANKS           -1:0] cs_lines;
  reg  [`DWC_CID_WIDTH         -1:0] cid,         cid_1;
  
  // read tag pipeline
  wire                               ddr_rd_cmd;
  wire [pRL_CPIPE_WIDTH        -1:0] rdtag;
  reg  [pRL_CPIPE_WIDTH        -1:0] rdtag_p [0:pRL_CPIPE_DEPTH-1];
  wire                               rd_cmd;
  reg                                rd_cmd_ff;
       
  wire [pCMD_WIDTH             -1:0] cmd,  cmd_1;
  wire [pRANK_WIDTH            -1:0] rank, rank_1;
  reg  [pRANK_WIDTH            -1:0] rank_3ds, rank_3ds_1;
  wire [pMCTL_BANK_WIDTH       -1:0] bank, bank_1;
  wire [pMCTL_BG_WIDTH         -1:0] bg, bg_1;
  wire [pROW_WIDTH             -1:0] row;
  wire [pCOL_WIDTH             -1:0] col;
  wire [pMCTL_ADDR_WIDTH       -1:0] addr, addr_1;
  wire [pCTRL_DATA_WIDTH       -1:0] data;
  wire                               gp_flag;
  wire [5:0]                         ck_en;
  reg                                ddr3_bl4;
  reg                                ddr3_bl4_nop;
  reg                                last_ddr3_bl4;

  reg  [pLPDDR_ADDR_WIDTH      -1:0] lpddr2_addr, lpddr2_addr_1;

  reg  [pLPDDR_ADDR_WIDTH      -1:0] lpddr3_addr, lpddr3_addr_1;


  wire [pWL_DPIPE_WIDTH        -1:0] ddr_d_in;
  wire [pWL_OPIPE_WIDTH        -1:0] odt_in;
  reg  [pWL_DPIPE_WIDTH        -1:0] ddr_d_p [0:pWL_DPIPE_DEPTH-1];
  reg  [pWL_OPIPE_WIDTH        -1:0] odt_p   [pWL_OPIPE_MIN:pWL_OPIPE_MAX];
  reg                                ddr_wr, ddr_wr_m1, ddr_wr_m2;
  reg  [pNO_OF_BYTES*pCLK_NX*16-1:0] ddr_do, ddr_do_m1, ddr_do_m2;
  reg  [pNUM_LANES*pCLK_NX*2   -1:0] ddr_dm, ddr_dm_m1, ddr_dm_m2;
  reg                                ddr_wr_ff;
  reg                                ddr_wr_ff_2;
  reg  [pNO_OF_BYTES*pCLK_NX*16-1:0] ddr_do_ff;
  reg  [pNO_OF_BYTES*pCLK_NX*16-1:0] ddr_do_ff_2;
  reg  [pNUM_LANES*pCLK_NX*2   -1:0] ddr_dm_ff;
  reg  [pNUM_LANES*pCLK_NX*2   -1:0] ddr_dm_ff_2;
  reg  [pNO_OF_BYTES*pCLK_NX*16-1:0] ddr_do_mxd;
  reg  [pNUM_LANES*pCLK_NX*2   -1:0] ddr_dm_mxd;
  
  reg  [pNO_OF_BYTES*pCLK_NX*8-1:0]  ddr_lwr_wrd_do, ddr_lwr_wrd_do_m1, ddr_lwr_wrd_do_m2;
  reg  [pNO_OF_BYTES*pCLK_NX*8-1:0]  ddr_upr_wrd_do, ddr_upr_wrd_do_m1, ddr_upr_wrd_do_m2;
  reg  [pNO_OF_BYTES*pCLK_NX*8-1:0]  ddr_lwr_wrd_do_ff;
  reg  [pNO_OF_BYTES*pCLK_NX*8-1:0]  ddr_upr_wrd_do_ff;
  reg  [pNO_OF_BYTES*pCLK_NX*8-1:0]  ddr_lwr_wrd_do_ff_2;
  reg  [pNO_OF_BYTES*pCLK_NX*8-1:0]  ddr_upr_wrd_do_ff_2;

  reg  [pNUM_LANES*pCLK_NX     -1:0] ddr_lwr_wrd_dm, ddr_lwr_wrd_dm_m1, ddr_lwr_wrd_dm_m2;
  reg  [pNUM_LANES*pCLK_NX     -1:0] ddr_upr_wrd_dm, ddr_upr_wrd_dm_m1, ddr_upr_wrd_dm_m2;
  reg  [pNUM_LANES*pCLK_NX     -1:0] ddr_lwr_wrd_dm_ff;
  reg  [pNUM_LANES*pCLK_NX     -1:0] ddr_upr_wrd_dm_ff;
  reg  [pNUM_LANES*pCLK_NX     -1:0] ddr_lwr_wrd_dm_ff_2;
  reg  [pNUM_LANES*pCLK_NX     -1:0] ddr_upr_wrd_dm_ff_2;
                                     
  reg  [pWL_OPIPE_WIDTH        -1:0] next_odt;
  wire [pWL_OPIPE_WIDTH        -1:0] next_odt_i;
  reg  [pNO_OF_RANKS           -1:0] next_odt_ff;
  reg  [pNO_OF_RANKS           -1:0] next_odt_ff2;
  wire [pNO_OF_RANKS           -1:0] odt_start;
  wire [pNO_OF_RANKS           -1:0] odt_end;
  reg  [pNO_OF_RANKS           -1:0] odt_end_ff, odt_end_ff_reg;
  wire [pNO_OF_RANKS           -1:0] odt_blast;
  reg  [pNO_OF_RANKS           -1:0] odt_start_ff;
  wire [pNO_OF_RANKS           -1:0] odt_burst;
  reg  [pBURST_WIDTH           -1:0] odtburst_cnt [0:pNO_OF_RANKS-1];
  wire [pNO_OF_RANKS           -1:0] ddr3_odt_start;
  reg  [pNO_OF_RANKS           -1:0] ddr3_odt_end;
  reg  [2                        :0] ddr3_odt_cnt [0:pNO_OF_RANKS-1];
  wire [2                        :0] ddr3_odt_len;
  wire [pNO_OF_RANKS           -1:0] odt_hec_to_hoc_end;

  // ODT enable/disbale when reading/writing different ranks
  reg  [pNO_OF_PRANKS          -1:0] rd_odt [pNO_OF_PRANKS-1:0];  
  reg  [pNO_OF_PRANKS          -1:0] wr_odt [pNO_OF_PRANKS-1:0];
  reg  [pNO_OF_PRANKS          -1:0] rdodt; 
  reg  [pNO_OF_PRANKS          -1:0] wrodt;  
  
  reg  [pNO_OF_RANKS           -1:0] odt;
     
  wire                               no_cmd;
  wire                               any_zqcal, any_zqcal_1;
  wire                               any_pre, any_pre_1;
  wire                               any_rd;
  wire                               any_wr;
  wire                               rw_cmd;
  wire                               rw_cmd_blfxd;
  wire                               rw_cmd_blotf;
  wire                               ldmr_cmd;
  wire                               rfsh_cmd;
  wire                               pwrdn_cmd;
  wire                               deep_pwrdn_cmd;
  wire                               sfrfsh_cmd;
  wire                               bst_cmd;
  wire                               ctrl_cmd;
  wire                               init_cmd;
  reg                                reset_lo;
  wire                               reset_hi;
  reg                                cke_lo;
  wire                               cke_hi;
  reg                                ck_stop;
  wire                               ck_start;
  reg                                odt_on;
  wire                               odt_off;
  wire                               mode_exit;
  wire                               rdimm_wr;
  reg                                low_power;
  
  wire [pNUM_LANES             -1:0] byte_en;
  wire                               ddr_wr_cmd;  
  wire [pNUM_LANES             -1:0] byte_wr_p6;
  wire [pNUM_LANES             -1:0] byte_wr_p7;
  wire [pNUM_LANES             -1:0] byte_wr_p8;
  wire [pNUM_LANES             -1:0] byte_wr_p9;
  wire [pNUM_LANES             -1:0] byte_wr_p10;
  reg  [(pNUM_LANES*pCLK_NX)   -1:0] byte_wr_mxd;

  reg  [pBURST_WIDTH           -1:0] wrburst_cnt;
  wire                               wr_burst;
  reg  [pBURST_WIDTH           -1:0] rdburst_cnt;
  wire                               rd_burst;
  wire [pNUM_LANES             -1:0] byte_rd_pn, byte_rd_m1, byte_rd_m2, byte_rd_m3;
  reg  [pNUM_LANES             -1:0] byte_rd_ff;
  reg  [(pNUM_LANES*pCLK_NX)   -1:0] byte_rd_mxd;

  wire                               t_ol_odd, t_rl_odd, t_wl_odd;

  reg                                rfsh_prd_cntr_init;
  reg  [pRFSH_CNTR_WIDTH       -1:0] rfsh_prd_cntr;
  reg                                rfsh_prd_cntr_load;
  reg                                rfsh_prd_cntr_en;
  reg                                rfsh_rqst_vld;
  wire                               rfsh_rqst_ack;
  reg  [pRFSH_BURST_WIDTH      -1:0] rfsh_burst_cntr;
  reg                                rfsh_last_burst;
  reg  [pRFSH_STATE_WIDTH-1:0]       rfsh_state;
  wire [pCMD_WIDTH             -1:0] rfsh_rqst_cmd;
  reg  [pRANK_WIDTH            -1:0] rfsh_rqst_rank;
  wire                               rfsh_last_rank;
  wire                               rfsh_mode_start;
  wire                               rfsh_mode;
  wire                               phy_init_done;
  reg  [1:0]                         phy_init_done_ff;

  reg                                lpddr2_mrr;
  reg                                lpddr2_mrr_nop;

  reg                                lpddr3_mrr;
  reg                                lpddr3_mrr_nop;


  wire                               lpddrx_mode;

  wire                               bdrift_err_rcv;
  integer                            addr_idx;
  
  wire [pBANK_WIDTH*pCLK_NX    -1:0] dfi_bank_i;
  wire                               dfi_upd_busy;
  integer                            rank_id, rank_i;
  
  //---------------------------------------------------------------------------
  // Host Input Request
  //---------------------------------------------------------------------------
  // multiplexes and pipelines the request from either the host interface, 
  // initialization module or refresh scheduler
  assign lpddrx_mode= lpddr2_mode | lpddr3_mode;

  initial use_rnd_even_odd_timing = 0;
  

  // host request
  // ------------
  // host request components
  assign host_addr     = host_a;
  assign host_data     = {host_dm, host_d};
  assign host_ddr3_bl4 = host_cmd_flag[0];
  assign host_gp_flag  = host_cmd_flag[1];
  assign host_ck_en    = host_cmd_flag[7:2];
  assign host_rfsh_inh = host_cmd_flag[8];
  assign host_cmd_vld  = host_rqvld | host_bl4_nop;

  assign {host_cmd_mx, host_addr_mx} = (host_bl4_nop) ?
         {host_bl4_cmd, host_bl4_addr} :
         {host_cmd, host_addr};

  assign host_rd_cmd = (host_cmd[3:1] == ANY_READ)   ? 1'b1 : 1'b0;
  assign host_wr_cmd = (   (host_cmd[3:1] == ANY_WRITE) 
                        || ((host_cmd == LOAD_MODE) && `SYS.load_mode_pda_en)) ? 1'b1 : 1'b0;
  assign host_rw_cmd = (   (host_cmd[3:2] == READ_WRITE)  
                        || ((host_cmd == LOAD_MODE) && `SYS.load_mode_pda_en))? 1'b1 : 1'b0;

  assign host_bst_cmd = (host_cmd == TERMINATE && (lpddrx_mode==1'b1)) ? 1'b1 : 1'b0;

  assign host_wr_hoc  = (hdr_odd_cmd & ~host_bl4_nop) | (host_bl4_nop_hoc & host_bl4_nop & ~host_bl4_rdnop);
  assign host_rd_hoc  = (hdr_odd_cmd & ~host_bl4_nop) | (host_bl4_nop_hoc & host_bl4_nop &  host_bl4_rdnop);
  
  // host request control and flags
  always @(posedge clk or negedge rst_b)
    begin
      if (rst_b == 1'b0)
        begin
          host_burst_cnt    <= {pBURST_WIDTH{1'b0}};
          host_bl4_rdnop    <= 1'b0;
          host_bl4_nop      <= 1'b0;
          host_bl4_nop_hoc  <= 1'b0;
          host_bl4_last_nop <= 1'b0;
          host_bl4_cmd      <= {pCMD_WIDTH{1'b0}};
          host_bl4_addr     <= {pHOST_ADDR_WIDTH{1'b0}};
        end
      else
        begin
          // host data burst indicators and read count
          if (host_cmd_ack)
            begin
              // data burst indicators
              if (host_rqvld || host_bl4_nop)
                begin
                  if ((host_burst_cnt == burst_len) || (host_bst_cmd==1'b1))
                    begin
                      host_burst_cnt <= {pBURST_WIDTH{1'b0}};
                    end
                  else if (host_rw_cmd || host_bl4_nop)
                    begin
                      host_burst_cnt <= host_burst_cnt + 1;
                    end
                end

              // NOPs after DDR3 BL4 read/write
              if (host_rqvld && host_rw_cmd && host_ddr3_bl4 && 
                  host_bl4_last_data && !host_bl4_nop)
                begin
                  host_bl4_rdnop    <=  host_cmd[1];
                  host_bl4_nop      <= 1'b1;
                  host_bl4_nop_hoc  <= hdr_odd_cmd;
                  host_bl4_last_nop <= (hdr_mode) ? 1'b1 : 1'b0;
                end
              else
                begin
                  if (host_bl4_last_nop)
                    begin
                      host_bl4_rdnop <= 1'b0;
                      host_bl4_nop   <= 1'b0;
                      host_bl4_nop_hoc <= 1'b0;
                    end
                  host_bl4_last_nop <= 1'b1;
                end

              if (host_rqvld && host_ddr3_bl4 && !host_bl4_nop)
                begin
                  host_bl4_cmd  <= host_cmd;
                  host_bl4_addr <= host_addr;
                end
            end // if (host_cmd_ack)
          else
            begin
              host_bl4_nop_hoc <= 1'b0;
            end // else: !if(host_cmd_ack)
        end
    end

  always @(host_rw_cmd or host_bl4_nop or host_burst_cnt or burst_len)
    begin
      if (host_rw_cmd || host_bl4_nop)
        begin
          host_first_data = (host_burst_cnt == {pBURST_WIDTH{1'b0}}) ? 1'b1 : 1'b0;
          host_last_data  = (host_burst_cnt == burst_len) ? 1'b1 : 1'b0;
        end
      else
        begin
          host_first_data = 1'b1;
          host_last_data  = 1'b1;
        end
    end
  assign host_bl4_last_data = (hdr_mode) ? 1'b1 : 
                              (host_burst_cnt == {{(pBURST_WIDTH-1){1'b0}}, 1'b1}) ? 1'b1 : 1'b0;
//  assign host_page = (MAX_BANKS+MAX_BANK_GROUPS)*host_rank
//                     + (MAX_BANKS*host_bg)
//                     + host_bank;
  assign host_page    = 8*4*host_rank + 8*host_bg + host_bank;
  assign host_bg_page = 4*host_rank + host_bg;

  // TBD: come back
  assign host_cmd_ack = ~(refresh_pending | activate_pending | precharge_pending) & timing_met && (!ddr_2t || hdr_odd_cmd_stable);
  assign host_rdy = host_cmd_ack & ~host_bl4_nop;
  
  
  // command execution
  // -----------------
  always @(*)
    begin
      if (rfsh_mode)
        begin
          no_command        = 1'b0;
          refresh_pending   = 1'b1;
        end
      else if (host_rqvld)
        begin
          // For ddr_2t mode, if there is a switch between hdr odd and even mode,
          // allow the previous command to extend for 1 more clk. Do not change the pending
          // state.
          if (!ddr_2t || hdr_odd_cmd_stable)
            begin
              if (host_cmd_mx[3:2] == READ_WRITE && host_first_data &&
                  bank_open[host_page] == BANK_CLOSED)
                begin
                  // bank is closed, open (activate) the bank
                  no_command        = 1'b0;
                  refresh_pending   = 1'b0;
                  activate_pending  = 1'b1;
                  precharge_pending = 1'b0;
                  command_pending   = 1'b0;
                end
              else if (host_cmd_mx[3:2] == READ_WRITE && host_first_data &&
                       bank_open[host_page] != host_row)
                begin
                  // a different row is open in the bank - close
                  // (precharge) bank
                  no_command        = 1'b0;
                  refresh_pending   = 1'b0;
                  activate_pending  = 1'b0;
                  precharge_pending = 1'b1;
                  command_pending   = 1'b0;
                end
              else
                begin
                  // everything is ready, execute the command
                  no_command        = 1'b0;
                  refresh_pending   = 1'b0;
                  activate_pending  = 1'b0;
                  precharge_pending = 1'b0;
                  command_pending   = 1'b1;
                end
            end
          else begin 
            // no change in the pending state
          end // else: !if(!ddr_2t)
        end // if (host_rqvld)
      else
        begin
          // no command on the host port
          no_command        = 1'b1;
          refresh_pending   = 1'b0;
          activate_pending  = 1'b0;
          precharge_pending = 1'b0;
          command_pending   = 1'b0;
        end
    end // always @ (*)

  // command pipeline 
  always @(posedge clk or negedge rst_b)
    begin: command_pipeline
      integer i,j;
      integer dw_idx;

      if (rst_b == 1'b0)
        begin
          hdr_odd_cmd_ff <= 1'b0;
          cmd_ff         <= SDRAM_NOP;
          rank_ff        <= {pRANK_WIDTH{1'b0}};
          rdwr_rank_ff   <= {pRANK_WIDTH{1'b0}};
          bank_ff        <= {pMCTL_BANK_WIDTH{1'b0}};
          bg_ff          <= {pMCTL_BG_WIDTH{1'b0}};
          row_ff         <= {pROW_WIDTH{1'b0}};
          col_ff         <= {pCOL_WIDTH{1'b0}};
          data_ff        <= {pCTRL_DATA_WIDTH{1'b0}};
          rd_rank_ff     <= {pRANK_WIDTH{1'b0}};
          ddr3_bl4       <= 1'b0;
          ddr3_bl4_nop   <= 1'b0;
          init_cke       <= 1'b0;
          first_init_cke <= 1'b0;
          gp_flag_ff     <= 1'b0;
          ck_en_ff       <= {pCK_WIDTH{2'b10}};
          bdrift_err_q   <= 1'b0;
          caddr_ff       <= {pHOST_ADDR_WIDTH{1'b0}};
          caddr_ff_1     <= {pHOST_ADDR_WIDTH{1'b0}};
          last_ddr3_bl4  <= 1'b0;
          activate_pending_ff <= 1'b0;
          
          // all banks are closed
          for (i=0; i<MAX_PAGES; i=i+1) bank_open[i] <= BANK_CLOSED;
          for (j=0; j<=3; j=j+1) begin
            hdr_odd_cmd_array[j] <= 1'bx;
            hdr_odd_cmd_valid[j] <= 1'b0;
            hdr_odd_cmd_bl4[j]   <= 1'bx;
          end
        end
      else
        begin
          wr_odd_even_ptr_d0 <= wr_odd_even_ptr;
          wr_odd_even_ptr_d1 <= wr_odd_even_ptr_d0;
          wr_odd_even_ptr_d2 <= wr_odd_even_ptr_d1;
          wr_odd_even_ptr_d3 <= wr_odd_even_ptr_d2;

          rw_bl4_reg         <= rw_bl4;
          
          // delay the valid for 3 clks; wr or rd command takes time
          // to go thru the pipe, so do not turn the valid on until
          // they are ready to be read.
          // This is neccessary for heoc mode
          if (wr_odd_even_ptr_d2 !== wr_odd_even_ptr_d1) begin
              hdr_odd_cmd_valid[wr_odd_even_ptr_d2] = 1'b1;
          end
          
          if (cmd_ff[3:2] == READ_WRITE) begin
            hdr_odd_cmd_array[wr_odd_even_ptr] = hdr_odd_cmd_ff;
            hdr_odd_cmd_bl4  [wr_odd_even_ptr] = ddr3_bl4;
            rw_bl4                             <= ddr3_bl4;
            wr_odd_even_ptr                    <= wr_odd_even_ptr + 1;
          end

          activate_pending_ff <= timing_met && activate_pending;
          if (no_command)
            begin
              cmd_ff  <= SDRAM_NOP;
              rank_ff <= {pRANK_WIDTH{1'b0}};
              bank_ff <= {pMCTL_BANK_WIDTH{1'b0}};
              bg_ff   <= {pMCTL_BG_WIDTH{1'b0}};
              row_ff  <= {pROW_WIDTH{1'b0}};
              col_ff  <= {pCOL_WIDTH{1'b0}};
              for (dw_idx = 0; dw_idx < pNO_OF_BYTES; dw_idx = dw_idx + 1)
                data_ff[dw_idx * 32 +: 32] <= 32'h9933_eeaa; // 32'hXXXX_XXXX; // {$random};
              for (dw_idx = (pNO_OF_BYTES * 32); dw_idx < pCTRL_DATA_WIDTH; dw_idx = dw_idx + 1)
                data_ff[dw_idx] <= 1'b0;
            end
          else if (timing_met)
            begin
              if (refresh_pending)
                begin
                  // issue a refresh
                  cmd_ff  <= rfsh_rqst_cmd;
                  rank_ff <= rfsh_rqst_rank;
                  bank_ff <= {pMCTL_BANK_WIDTH{1'b0}};
                  bg_ff   <= {pMCTL_BG_WIDTH{1'b0}};
                  row_ff  <= {pROW_WIDTH{1'b0}};
                  col_ff  <= {pCOL_WIDTH{1'b0}};
                  data_ff <= {pCTRL_DATA_WIDTH{1'b0}};

                  if (rfsh_rqst_cmd == PRECHARGE_ALL)
                    begin
                      for (i=0; i<MAX_PAGES; i=i+1) bank_open[i] <= BANK_CLOSED;
                    end
                end
              else if (precharge_pending)
                begin
                  // close (precharge) previous bank row
                  cmd_ff  <= PRECHARGE;
                  rank_ff <= host_rank;
                  bank_ff <= host_bank;
                  bg_ff   <= host_bg;
                  row_ff  <= bank_open[8*4*rank+8*bg+bank];
                  col_ff  <= {pCOL_WIDTH{1'b0}};
                  data_ff <= host_data;
                  bank_open[8*4*host_rank+8*host_bg+host_bank] <= BANK_CLOSED;
                end
              else if (activate_pending)
                begin
                  // open (activate) the bank row
                  cmd_ff  <= ACTIVATE;
                  rank_ff <= host_rank;
                  bank_ff <= host_bank;
                  bg_ff   <= host_bg;
                  row_ff  <= host_row;
                  col_ff  <= host_col;
                  data_ff <= host_data;
                  bank_open[8*4*host_rank+8*host_bg+host_bank] <= host_row;
                end
              else if (command_pending)
                begin
                  cmd_ff  <= (host_cmd[3:2] == READ_WRITE && 
                              !host_first_data) ?
                             SDRAM_NOP : host_cmd;
                  if (host_first_data) begin
                    rank_ff <= host_rank;
                    rdwr_rank_ff <= (host_cmd[3:2] == READ_WRITE)? host_rank: rdwr_rank_ff;
                    
                    bank_ff <= host_bank;
                    bg_ff <= host_bg;
                    row_ff  <= host_row;
                    col_ff  <= (host_cmd == SPECIAL_CMD && host_addr[3:0] == `RDIMMCRW) ? 
                                host_addr[pCOL_WIDTH-1:0] : host_col;
                  end
                  data_ff <= host_data;
                  caddr_ff <= (hdr_odd_cmd) ? {pHOST_ADDR_WIDTH{1'b0}} : host_addr;

                  if (lpddrx_mode==1'b1) begin
                    caddr_ff_1 <= (hdr_odd_cmd) ? host_addr : {{7{1'b0}}, 3'b111, {7{1'b0}}, 3'b111};
                  end else begin
                    caddr_ff_1 <= (hdr_odd_cmd) ? host_addr : {pHOST_ADDR_WIDTH{1'b0}};
                  end

                  if (host_cmd == ACTIVATE)
                    begin
                      // open bank
                      bank_open[8*4*host_rank+8*host_bg+host_bank] <= host_row;
                    end

                  if (((host_cmd == WRITE_PRECHG || host_cmd == READ_PRECHG) &&
                       host_first_data) ||
                      (host_cmd == PRECHARGE))
                    begin
                      // close bank
                      bank_open[8*4*host_rank+8*host_bg+host_bank] <= BANK_CLOSED;
                    end

                  if (host_cmd == PRECHARGE_ALL)
                    begin
                      for (i=0; i<MAX_PAGES; i=i+1) bank_open[i] <= BANK_CLOSED;
                    end
                end

              if (command_pending || precharge_pending || activate_pending || refresh_pending)
                begin
                  hdr_odd_cmd_ff <= hdr_odd_cmd;
                end
            end
          else
            begin
              cmd_ff <= SDRAM_NOP;
            end // else: !if(timing_met)

          // the very first NOP command from the host port signifies that CKE has to
          // go high for initialization
          if (host_rqvld && host_rdy && host_cmd == SDRAM_NOP)
            begin
              init_cke <= 1'b1;
            end

          if (init_cke && !first_init_cke)
            first_init_cke <= 1'b1;
          
          ddr3_bl4     <= host_ddr3_bl4;
          ddr3_bl4_nop <= host_bl4_nop;
          gp_flag_ff   <= host_gp_flag;
          ck_en_ff     <= host_ck_en;

          if (timing_met) begin
            last_ddr3_bl4 <= host_ddr3_bl4;
          end

          // burst drift error flag: indicates drift error during a continous 
          // read burst in any of the up to 9 bytes;
          if (bdrift_err_rcv) 
            begin
              bdrift_err_q <= 1'b1;
            end
          else if (cmd_ff_last_rd || !cmd_ff_rd_cmd)
            begin
              bdrift_err_q <= 1'b0;
            end
        end // else: !if(rst_b == 1'b0)
    end // block: command_pipeline

  assign addr_ff    = ((lpddrx_mode==1'b1) && cmd_ff == LOAD_MODE) ? (hdr_odd_cmd_ff ? caddr_ff_1 : caddr_ff) :
                       (cmd_ff == ACTIVATE ||
                        cmd_ff == PRECHARGE ||
                        cmd_ff == LOAD_MODE)                       ? row_ff 
                                                                   : col_ff;
  
  // read burst count at _ff pipline level846
  always @(posedge clk or negedge rst_b)
    begin
      if (rst_b == 1'b0)
        begin
          cmd_ff_rdburst_cnt <= {pBURST_WIDTH{1'b0}};
        end
      else
        begin
          if (cmd_ff[3:1] == ANY_READ)
            begin
              cmd_ff_rdburst_cnt <= burst_len;
            end
          else if (cmd_ff_rd_burst == 1'b1)
            begin
              cmd_ff_rdburst_cnt <= cmd_ff_rdburst_cnt - 1;
            end
        end
    end

  assign cmd_ff_rd_burst = (cmd_ff_rdburst_cnt == {pBURST_WIDTH{1'b0}}) ? 1'b0 : 1'b1;
  assign cmd_ff_rd_cmd   = (cmd_ff[3:1] == ANY_READ || cmd_ff_rd_burst) ? 1'b1 : 1'b0;
  assign cmd_ff_last_rd  = ((cmd_ff_rdburst_cnt == {{(pBURST_WIDTH-1){1'b0}}, 1'b1}) ||
                            (cmd_ff[3:1] == ANY_READ && burst_len == {pBURST_WIDTH{1'b0}})) ? 1'b1 : 1'b0;


  // command timing
  // --------------
  // rank-to-rank spacing
  // NOTE: DDR3 always executes as BL8 even when BL4 is selected - it just
  //       puts NOPs in the other slots
  // All clock numbers are in the SDRAM clock cycles (and not in controller cycles) that is why
  // for BL8, 4 is used which transaltes to 2, i.e. 2 required for normal BL8 write-to-write spacing
  // The special case of mixed even odd requires one extra clock spacing
`ifdef MSD_RND_HDR_ODD_CMD
  assign t_rdrnk = (ddr3_mode|ddr4_mode) ? 4 + tRD_RNK2RNK : `GRM.sdr_burst_len + tRD_RNK2RNK + 1;
  assign t_wrrnk = (ddr3_mode|ddr4_mode) ? 4 + tWR_RNK2RNK : `GRM.sdr_burst_len + tWR_RNK2RNK + 1;
`else
  assign t_rdrnk = (ddr3_mode|ddr4_mode) ? 4 + tRD_RNK2RNK : `GRM.sdr_burst_len + tRD_RNK2RNK;
  assign t_wrrnk = (ddr3_mode|ddr4_mode) ? 4 + tWR_RNK2RNK : `GRM.sdr_burst_len + tWR_RNK2RNK;
`endif
  
  // timing counters
  always @(posedge clk or negedge rst_b)
    begin: command_timing
      integer i;
      integer tmp_word_0,tmp_word_1,tmp_word_2,tmp_word_3;
      
      if (rst_b == 1'b0)
        begin
          for (i=0; i<MAX_PAGES; i=i+1)
            begin
              t_rp_cntr[i]     <= {tRPA_WIDTH{1'b0}};
              t_ras_cntr[i]    <= {tRAS_WIDTH{1'b0}};
              t_rc_cntr[i]     <= {tRC_WIDTH{1'b0}};
              t_rcd_cntr[i]    <= {tACT2RW_WIDTH{1'b0}};
              t_rtp_cntr[i]    <= {tRD2PRE_WIDTH{1'b0}};
              t_wtp_cntr[i]    <= {tWR2PRE_WIDTH{1'b0}};
              t_rtp[i]         <= {tRD2PRE_WIDTH{1'b0}};
              t_wtp[i]         <= {tWR2PRE_WIDTH{1'b0}};
              t_ccd_s_cntr[i]  <= {tCCD_WIDTH{1'b0}};
            end
          for (i=0; i<MAX_BG_PAGES; i=i+1)
            begin
              t_ccd_l_cntr[i]  <= {tCCD_WIDTH{1'b0}};
            end

          for (i=0; i<4; i=i+1)
            begin
              t_faw_cntr[i] <= {tFAW_WIDTH{1'b0}};
            end

          t_rtw_cntr    <= {tRD2WR_WIDTH{1'b0}};
          t_wtr_cntr    <= {tWR2RD_WIDTH{1'b0}};
          t_rrd_cntr    <= {tRRD_WIDTH{1'b0}};
          t_mrd_cntr    <= {tMRD_WIDTH{1'b0}};
          t_mod_cntr    <= {tMOD_WIDTH{1'b0}};
          t_rfc_cntr    <= {tRFC_WIDTH{1'b0}};
          t_rpa_cntr    <= {tRPA_WIDTH{1'b0}};
          t_bcstab_cntr <= {tBCSTAB_WIDTH{1'b0}};
          t_bcmrd_cntr  <= {tBCMRD_WIDTH{1'b0}};

          t_rdrnk_cntr  <= {4{1'b0}};
          t_wrrnk_cntr  <= {4{1'b0}};
          rdrnk_xcheck  <= 1'b0;
          wrrnk_xcheck  <= 1'b0;
          rdrnk_all_xspace_p0 <= 4'b0000;
          rdrnk_all_xspace_p1 <= 4'b0000;
          rdrnk_all_xspace_p2 <= 4'b0000;
          wrrnk_all_xspace_p0 <= 4'b0000;
          wrrnk_all_xspace_p1 <= 4'b0000;
          wrrnk_all_xspace_p2 <= 4'b0000;

          t_rp_hoc_ff         <= {MAX_PAGES{1'b0}};
          t_rc_hoc_ff         <= {MAX_PAGES{1'b0}};
          t_wtp_hoc_ff        <= {MAX_PAGES{1'b0}};
          t_rtp_hoc_ff        <= {MAX_PAGES{1'b0}};
          t_ccd_l_hoc_ff      <= {MAX_BG_PAGES{1'b0}};
          t_ccd_s_hoc_ff      <= {MAX_PAGES{1'b0}};
          
          t_faw_hoc_ff        <= 1'b0;
          t_rpa_hoc_ff        <= 1'b0;
          t_rrd_hoc_ff        <= 1'b0;
          t_wtr_hoc_ff        <= 1'b0;
          t_rtw_hoc_ff        <= 1'b0;
          t_mrd_hoc_ff        <= 1'b0;
          t_rfc_hoc_ff        <= 1'b0;
          t_bcstab_hoc_ff     <= 1'b0;
          t_bcmrd_hoc_ff      <= 1'b0;
          
          rp_hoc_to_hec       <= {MAX_PAGES{1'b0}};
          rc_hoc_to_hec       <= {MAX_PAGES{1'b0}};
          ras_hoc_to_hec      <= {MAX_PAGES{1'b0}};
          rcd_hoc_to_hec      <= {MAX_PAGES{1'b0}};
          wtp_hoc_to_hec      <= {MAX_PAGES{1'b0}};
          rtp_hoc_to_hec      <= {MAX_PAGES{1'b0}};
          ccd_l_hoc_to_hec    <= {MAX_BG_PAGES{1'b0}};
          ccd_s_hoc_to_hec    <= {MAX_PAGES{1'b0}};
          
          faw_hoc_to_hec      <= 1'b0;
          rpa_hoc_to_hec      <= 1'b0;
          rrd_hoc_to_hec      <= 1'b0;
          wtr_hoc_to_hec      <= 1'b0;
          rtw_hoc_to_hec      <= 1'b0;
          mrd_hoc_to_hec      <= 1'b0;
          mod_hoc_to_hec      <= 1'b0;
          rfc_hoc_to_hec      <= 1'b0;
          bcstab_hoc_to_hec   <= 1'b0;
          bcmrd_hoc_to_hec    <= 1'b0;

          t_wr_last_hoc       <= 1'b0;
          t_rd_last_hoc       <= 1'b0;

          rl_cntr             <= {8{1'b0}};
        end
      else
        begin
          // load the timing counters when a new command is issued out
          if (timing_met)
            begin
              // intra bank timing (timing for commands to same bank)
              for (i=0; i<MAX_PAGES; i=i+1)
                begin
                  // precharge to activate
                  if ((refresh_pending && rfsh_rqst_cmd == PRECHARGE_ALL) ||
                      ((precharge_pending ||
                        (command_pending && host_cmd == PRECHARGE)) &&
                       (host_page == i)) ||
                      (command_pending && host_cmd == PRECHARGE_ALL))
                    begin
                     `ifndef LPDDRX
                      // for DDR3/2, tx_rp and t_rp are same size, just choose between tx_rpa/tx_rp
                      t_rp_cntr[i] <= (!precharge_pending && host_cmd[0]) ?
                                      tx_rpa : tx_rp;
                     `else
                      // for LPDDR2/3, tx_rp and t_rp_cntr[i] are 1 bit off in size, so prepend a 1'b0
                      // to t_rp so there is not size mismatch
                      t_rp_cntr[i] <= (!precharge_pending && host_cmd[0]) ?
                                      tx_rpa : {1'b0,tx_rp};
                     `endif
                      t_rp_hoc_ff[i] <= hdr_odd_cmd;
                    end
                  else
                    begin
                      if (t_rp_cntr[i]) t_rp_cntr[i] <= t_rp_cntr[i] - 1;
                    end

                  // activate to activate
                  // activate to precharge
                  // activate to read/write
                  if ((activate_pending ||
                       (command_pending && host_cmd == ACTIVATE)) &&
                      (host_page == i))
                    begin
                      t_rc_cntr[i]  <= tx_rc;
                      t_ras_cntr[i] <= tx_ras;
                      t_rcd_cntr[i] <= tx_act2rw;
                      t_rc_hoc_ff[i] <= hdr_odd_cmd;
                    end
                  else
                    begin
                      if (t_rc_cntr[i])  t_rc_cntr[i]  <= t_rc_cntr[i]  - 1;
                      if (t_ras_cntr[i]) t_ras_cntr[i] <= t_ras_cntr[i] - 1;
                      if (t_rcd_cntr[i]) t_rcd_cntr[i] <= t_rcd_cntr[i] - 1;
                    end

                  // write to precharge
                  if (command_pending && host_cmd[3:1] == ANY_WRITE && 
                      host_first_data && host_page == i)
                    begin
                      t_wtp_cntr[i] <= (host_cmd[0]) ? tx_wrap2act : tx_wr2pre;
                      t_wtp_hoc_ff[i] <= hdr_odd_cmd;
                      t_wtp[i] <= (host_cmd[0]) ? t_wrap2act : t_wr2pre;
                    end
                  else
                    begin
                      if (t_wtp_cntr[i]) t_wtp_cntr[i] <= t_wtp_cntr[i] - 1;
                    end

                  // read to precharge
                  if (command_pending && host_cmd[3:1] == ANY_READ && 
                      host_first_data && host_page == i)
                    begin
                      t_rtp_cntr[i] <= (host_cmd[0]) ? tx_rdap2act : tx_rd2pre;
                      t_rtp_hoc_ff[i] <= hdr_odd_cmd;
                      t_rtp[i] <= (host_cmd[0]) ? t_rdap2act : t_rd2pre;
                    end
                  else
                    begin
                      if (t_rtp_cntr[i]) t_rtp_cntr[i] <= t_rtp_cntr[i] - 1;
                    end

                end // for (i=0; i<MAX_PAGES; i=i+1)

              // bank group timing (timing for commands to same bank group or differnt bank group)
              for (i=0; i<MAX_BG_PAGES; i=i+1)
                begin
                  // cas to cas timing  
                  if (command_pending && host_cmd[3:2] == READ_WRITE && 
                      host_first_data && host_bg_page == i)
                    begin
                      t_ccd_l_hoc_ff[i] <= hdr_odd_cmd;
                      t_ccd_l_cntr[i]   <= tx_ccd_l;
                    end
                  else
                    begin
                      if (t_ccd_l_cntr[i]) t_ccd_l_cntr[i] <= t_ccd_l_cntr[i] - 1;
                    end
                end
              for (i=0; i<MAX_PAGES; i=i+1)
                begin
                  // cas to cas timing  
                  if (command_pending && host_cmd[3:2] == READ_WRITE && 
                      host_first_data && host_page == i)
                    begin
                      t_ccd_s_hoc_ff[i] <= hdr_odd_cmd;
                      t_ccd_s_cntr[i]   <= tx_ccd_s;
                    end
                  else
                    begin
                      if (t_ccd_s_cntr[i]) t_ccd_s_cntr[i] <= t_ccd_s_cntr[i] - 1;
                    end
                end // for (i=0; i<MAX_PAGES; i=i+1)

              
              // inter-bank timing (timing for commands across banks)

              // 4-bank activate window
              //if (command_pending && host_cmd == ACTIVATE)
              if ((activate_pending && !activate_pending_ff) ||( host_cmd == ACTIVATE && !activate_pending_ff))
                begin
                  t_faw_cntr[0] <= tx_faw;
                  t_faw_cntr[1] <= t_faw_cntr[0];
                  t_faw_cntr[2] <= t_faw_cntr[1];
                  t_faw_cntr[3] <= t_faw_cntr[2];
                  t_faw_hoc_ff  <= hdr_odd_cmd;
                end
              else
                begin
                  if (t_faw_cntr[0]) t_faw_cntr[0] <= t_faw_cntr[0] - 1;
                  if (t_faw_cntr[1]) t_faw_cntr[1] <= t_faw_cntr[1] - 1;
                  if (t_faw_cntr[2]) t_faw_cntr[2] <= t_faw_cntr[2] - 1;
                  if (t_faw_cntr[3]) t_faw_cntr[3] <= t_faw_cntr[3] - 1;
                end

              tmp_word_0 <= t_faw_cntr[0];
              tmp_word_1 <= t_faw_cntr[1];
              tmp_word_2 <= t_faw_cntr[2];
              tmp_word_3 <= t_faw_cntr[3];


              // write to read
              if (command_pending && host_cmd[3:1] == ANY_WRITE && 
                  host_first_data)
                begin
                  t_wtr_cntr <= tx_wr2rd;
                  t_wtr_hoc_ff  <= hdr_odd_cmd;
                end
              else
                begin
                  if (t_wtr_cntr) t_wtr_cntr <= t_wtr_cntr - 1;
                end

              // read to write
              if (command_pending && host_cmd[3:1] == ANY_READ && 
                  host_first_data)
                begin
                  t_rtw_cntr <= (hdr_mode) ? 
                                tx_rd2wr + (`GRM.max_rsl/2) + (`GRM.max_rsl%2) :
                                tx_rd2wr + `GRM.max_rsl;
                  t_rtw_hoc_ff  <= hdr_odd_cmd;

                  // also load the counter that tracks the latency from when the read is
                  // issued to roughly when the read data is expected to come back; this is
                  // used to make sure the controller has received all its reads before
                  // say acknowledging PHY updates
                  rl_cntr <= (hdr_mode) ? tHOST2DFI_RDLAT + (`GRM.rl + `GRM.max_rsl)/2 :
                                          tHOST2DFI_RDLAT +  `GRM.rl + `GRM.max_rsl;
                end
              else
                begin
                  if (t_rtw_cntr) t_rtw_cntr <= t_rtw_cntr - 1;
                  if (rl_cntr)    rl_cntr    <= rl_cntr    - 1;
                end

              // activate to activate (different banks)
              if (activate_pending || command_pending && host_cmd == ACTIVATE)
                begin
                  t_rrd_cntr <= tx_rrd;
                  t_rrd_hoc_ff <= hdr_odd_cmd;
                end
              else
                begin
                  if (t_rrd_cntr) t_rrd_cntr <= t_rrd_cntr - 1;
                end

              // load mode to load mode
              // load mode to other instructions
              if (command_pending && host_cmd == LOAD_MODE)
                begin
                  t_mrd_cntr  <= tx_mrd;
                  t_mod_cntr  <= (ddr3_mode|ddr4_mode) ? tx_mod : tx_mrd;
                  t_mrd_hoc_ff <= hdr_odd_cmd;
                end
              else
                begin
                  if (t_mrd_cntr) t_mrd_cntr <= t_mrd_cntr - 1;
                  if (t_mod_cntr) t_mod_cntr <= t_mod_cntr - 1;
                end
              
              // refresh to refresh or other command
              if ((refresh_pending && rfsh_rqst_cmd == REFRESH) ||
                  (command_pending && host_cmd == REFRESH))
                begin
                  t_rfc_cntr  <= tx_rfc;
                  t_rfc_hoc_ff <= hdr_odd_cmd;
                end
              else
                begin
                  if (t_rfc_cntr) t_rfc_cntr <= t_rfc_cntr - 1;
                end

              // RDIMM register write to register write
              if (command_pending && host_cmd == SPECIAL_CMD && host_addr[3:0] == `RDIMMCRW)
                begin
                  if (host_addr[7:4] == 2 || host_addr[7:4] == 10) begin
                    // spacing from RC2 and RC10 is tBCSTAB
                    t_bcstab_cntr   <= tx_bcstab;
                    t_bcstab_hoc_ff <= hdr_odd_cmd;
                  end else begin
                    // spacing from other RCn is tBCMRD
                    t_bcmrd_cntr   <= tx_bcmrd;
                    t_bcmrd_hoc_ff <= hdr_odd_cmd;
                  end
                end
              else
                begin
                  if (t_bcstab_cntr) t_bcstab_cntr <= t_bcstab_cntr - 1;
                  if (t_bcmrd_cntr)  t_bcmrd_cntr  <= t_bcmrd_cntr - 1;
                end
              
              // precharge-all to other command
              if ((refresh_pending && rfsh_rqst_cmd == PRECHARGE_ALL) ||
                  (command_pending && host_cmd == PRECHARGE_ALL))
                begin
                  t_rpa_cntr <= tx_rpa;
                  t_rpa_hoc_ff <= hdr_odd_cmd;
                end
              else
                begin
                  if (t_rpa_cntr) t_rpa_cntr <= t_rpa_cntr - 1;
                end


              // read to read of different rank
              //  - DDR3 BL4 already has 2 NOPs inserted (remove the extra
              //    controller cycle NOP)
              if (command_pending && host_cmd[3:1] == ANY_READ && 
                  host_first_data)
                begin
                 `ifdef DWC_DDRPHY_EMUL_XILINX
                    `ifdef MSD_RND_HDR_ODD_CMD // Separate the Rd-Rd on the same rank but with differnt command (even/odd)
                       t_rdrnk_cntr <= tEO_RD2RRD;
                    `else
                       t_rdrnk_cntr <= tx_rdrnk - host_ddr3_bl4;
                    `endif
                  `else
                     t_rdrnk_cntr <= tx_rdrnk - host_ddr3_bl4;
                  `endif
                  rd_rank_ff   <= host_rank;
                end
              else
                begin
                  if (t_rdrnk_cntr) t_rdrnk_cntr <= t_rdrnk_cntr - 1;
                end

              // write to write of different rank
              //  - DDR3 BL4 already has 2 NOPs inserted (remove the extra
              //    controller cycle NOP)
              if (command_pending && host_cmd[3:1] == ANY_WRITE && 
                  host_first_data)
                begin
                  t_wrrnk_cntr <= tx_wrrnk;
                end
              else
                begin
                  if (t_wrrnk_cntr) t_wrrnk_cntr <= t_wrrnk_cntr - 1;
                end
            end // if (timing_met)
          else
            begin
              for (i=0; i<MAX_PAGES; i=i+1)
                begin
                  if (t_rp_cntr[i])    t_rp_cntr[i]    <= t_rp_cntr[i] - 1;
                  if (t_rc_cntr[i])    t_rc_cntr[i]    <= t_rc_cntr[i]  - 1;
                  if (t_ras_cntr[i])   t_ras_cntr[i]   <= t_ras_cntr[i] - 1;
                  if (t_rcd_cntr[i])   t_rcd_cntr[i]   <= t_rcd_cntr[i] - 1;
                  if (t_wtp_cntr[i])   t_wtp_cntr[i]   <= t_wtp_cntr[i] - 1;
                  if (t_rtp_cntr[i])   t_rtp_cntr[i]   <= t_rtp_cntr[i] - 1;
                  if (t_ccd_s_cntr[i]) t_ccd_s_cntr[i] <= t_ccd_s_cntr[i] - 1;
                end
              for (i=0; i<MAX_BG_PAGES; i=i+1)
                begin
                  if (t_ccd_l_cntr[i]) t_ccd_l_cntr[i] <= t_ccd_l_cntr[i] - 1;
                end
              if (t_faw_cntr[0]) t_faw_cntr[0] <= t_faw_cntr[0] - 1;
              if (t_faw_cntr[1]) t_faw_cntr[1] <= t_faw_cntr[1] - 1;
              if (t_faw_cntr[2]) t_faw_cntr[2] <= t_faw_cntr[2] - 1;
              if (t_faw_cntr[3]) t_faw_cntr[3] <= t_faw_cntr[3] - 1;
              if (t_wtr_cntr) t_wtr_cntr <= t_wtr_cntr - 1;
              if (t_rtw_cntr) t_rtw_cntr <= t_rtw_cntr - 1;
              if (t_rrd_cntr) t_rrd_cntr <= t_rrd_cntr - 1;
              if (t_mrd_cntr) t_mrd_cntr <= t_mrd_cntr - 1;
              if (t_mod_cntr) t_mod_cntr <= t_mod_cntr - 1;
              if (t_rfc_cntr) t_rfc_cntr <= t_rfc_cntr - 1;
              if (t_bcstab_cntr) t_bcstab_cntr <= t_bcstab_cntr - 1;
              if (t_bcmrd_cntr)  t_bcmrd_cntr  <= t_bcmrd_cntr - 1;
              if (t_rpa_cntr) t_rpa_cntr <= t_rpa_cntr - 1;
              if (t_rdrnk_cntr) t_rdrnk_cntr <= t_rdrnk_cntr - 1;
              if (t_wrrnk_cntr) t_wrrnk_cntr <= t_wrrnk_cntr - 1;
              if (rl_cntr) rl_cntr <= rl_cntr - 1;
            end // else: !if(timing_met)

          // rank-to-rank spacing
          rdrnk_xcheck <= (t_rdrnk_cntr == 3'b001) ? 1'b1 : 1'b0;
          wrrnk_xcheck <= (t_wrrnk_cntr == 3'b001) ? 1'b1 : 1'b0;
          rdrnk_all_xspace_p0 <= rdrnk_all_xspace;
          rdrnk_all_xspace_p1 <= rdrnk_all_xspace_p0;
          rdrnk_all_xspace_p2 <= rdrnk_all_xspace_p1;
          wrrnk_all_xspace_p0 <= wrrnk_all_xspace;
          wrrnk_all_xspace_p1 <= wrrnk_all_xspace_p0;
          wrrnk_all_xspace_p2 <= wrrnk_all_xspace_p1;

          // if the previous command was an odd command and the next one is an even command
          // increase the spacing by one extra clock cycle
          // NOTE: if the spacing is an odd number, then it was already increased by one
          //       clock
          for (i=0; i<MAX_PAGES; i=i+1) begin
            rp_hoc_to_hec[i]    <= (t_rp_hoc_ff[i]    && !t_rp      [0] && t_rp_cntr[i]    == 1) ? 1'b1 : 1'b0;
            rc_hoc_to_hec[i]    <= (t_rc_hoc_ff[i]    && !t_rc      [0] && t_rc_cntr[i]    == 1) ? 1'b1 : 1'b0;
            ras_hoc_to_hec[i]   <= (t_rc_hoc_ff[i]    && !t_ras     [0] && t_ras_cntr[i]   == 1) ? 1'b1 : 1'b0;
            rcd_hoc_to_hec[i]   <= (t_rc_hoc_ff[i]    && !t_act2rw  [0] && t_rcd_cntr[i]   == 1) ? 1'b1 : 1'b0;
            wtp_hoc_to_hec[i]   <= (t_wtp_hoc_ff[i]   && !t_wtp  [i][0] && t_wtp_cntr[i]   == 1) ? 1'b1 : 1'b0;
            rtp_hoc_to_hec[i]   <= (t_rtp_hoc_ff[i]   && !t_rtp  [i][0] && t_rtp_cntr[i]   == 1) ? 1'b1 : 1'b0;
            ccd_s_hoc_to_hec[i] <= (t_ccd_s_hoc_ff[i] && !t_ccd_s   [0] && t_ccd_s_cntr[i] == 1) ? 1'b1 : 1'b0;
          end
          for (i=0; i<MAX_BG_PAGES; i=i+1) begin
            ccd_l_hoc_to_hec[i] <= (t_ccd_l_hoc_ff[i] && !t_ccd_l   [0] && t_ccd_l_cntr[i] == 1) ? 1'b1 : 1'b0;
          end
          
          faw_hoc_to_hec    <= (t_faw_hoc_ff && !t_faw  [0] && t_faw_cntr[3] == 1) ? 1'b1 : 1'b0;
          rpa_hoc_to_hec    <= (t_rpa_hoc_ff && !t_rpa  [0] && t_rpa_cntr == 1) ? 1'b1 : 1'b0;
          rrd_hoc_to_hec    <= (t_rrd_hoc_ff && !t_rrd  [0] && t_rrd_cntr == 1) ? 1'b1 : 1'b0;
          wtr_hoc_to_hec    <= (t_wtr_hoc_ff && !t_wr2rd[0] && t_wtr_cntr == 1) ? 1'b1 : 1'b0;
          rtw_hoc_to_hec    <= (t_rtw_hoc_ff && !t_rd2wr[0] && t_rtw_cntr == 1) ? 1'b1 : 1'b0;
          mrd_hoc_to_hec    <= (t_mrd_hoc_ff && !t_mrd  [0] && t_mrd_cntr == 1) ? 1'b1 : 1'b0;
          mod_hoc_to_hec    <= (t_mrd_hoc_ff && !t_mod  [0] && t_mod_cntr == 1) ? 1'b1 : 1'b0;
          rfc_hoc_to_hec    <= (t_rfc_hoc_ff && !t_rfc  [0] && t_rfc_cntr == 1) ? 1'b1 : 1'b0;
          bcstab_hoc_to_hec <= (t_bcstab_hoc_ff && !t_bcstab[0] && t_bcstab_cntr == 1) ? 1'b1 : 1'b0;
          bcmrd_hoc_to_hec  <= (t_bcmrd_hoc_ff  && !t_bcmrd [0] && t_bcmrd_cntr  == 1) ? 1'b1 : 1'b0;

          t_wr_last_hoc    <= (host_wr_hoc && host_last_data) ? 1'b1 : 1'b0;
          t_rd_last_hoc    <= (host_rd_hoc && host_last_data) ? 1'b1 : 1'b0;
        end // else: !if(rst_b == 1'b0)
    end // block: command_timing

  assign rddata_pending = (rl_cntr) ? 1'b1 : 1'b0;

  always @(*) begin: hoc_to_hec_proc
    integer i;
    
    // if the previous command was an odd command and the next one is an even command
    // increase the spacing by one extra clock cycle
    // NOTE: if the spacing is an odd number, then it was already increased by one
    //       clock
    for (i=0; i<MAX_PAGES; i=i+1) begin
      t_rp_hoc_to_hec[i]    = rp_hoc_to_hec[i]    & ~hdr_odd_cmd;
      t_rc_hoc_to_hec[i]    = rc_hoc_to_hec[i]    & ~hdr_odd_cmd;
      t_ras_hoc_to_hec[i]   = ras_hoc_to_hec[i]   & ~hdr_odd_cmd;
      t_rcd_hoc_to_hec[i]   = rcd_hoc_to_hec[i]   & ~hdr_odd_cmd;
      t_wtp_hoc_to_hec[i]   = wtp_hoc_to_hec[i]   & ~hdr_odd_cmd;
      t_rtp_hoc_to_hec[i]   = rtp_hoc_to_hec[i]   & ~hdr_odd_cmd;
      t_ccd_s_hoc_to_hec[i] = ccd_s_hoc_to_hec[i] & ~hdr_odd_cmd;
    end
    for (i=0; i<MAX_BG_PAGES; i=i+1) begin
      t_ccd_l_hoc_to_hec[i] = ccd_l_hoc_to_hec[i] & ~hdr_odd_cmd;
    end
    
    t_faw_hoc_to_hec    = faw_hoc_to_hec    & ~hdr_odd_cmd;
    t_rpa_hoc_to_hec    = rpa_hoc_to_hec    & ~hdr_odd_cmd;
    t_rrd_hoc_to_hec    = rrd_hoc_to_hec    & ~hdr_odd_cmd;
    t_wtr_hoc_to_hec    = wtr_hoc_to_hec    & ~hdr_odd_cmd;
    t_rtw_hoc_to_hec    = rtw_hoc_to_hec    & ~hdr_odd_cmd;
    t_mrd_hoc_to_hec    = mrd_hoc_to_hec    & ~hdr_odd_cmd;
    t_mod_hoc_to_hec    = mod_hoc_to_hec    & ~hdr_odd_cmd;
    t_rfc_hoc_to_hec    = rfc_hoc_to_hec    & ~hdr_odd_cmd;
    t_bcstab_hoc_to_hec = bcstab_hoc_to_hec & ~hdr_odd_cmd;
    t_bcmrd_hoc_to_hec  = bcmrd_hoc_to_hec  & ~hdr_odd_cmd;
  end

always@(*) begin
  rob_host_t_ccd_l_cntr       = t_ccd_l_cntr[host_bg_page];
  rob_host_t_ccd_s_cntr       = t_ccd_s_cntr[host_page];
end

  always @(*)
    begin: check_timing
      integer i;

      if (dfi_phyupd_ack === 1'b1) 
        begin
          timing_met = 1'b0;
        end
      else if ((refresh_pending && rfsh_rqst_cmd == PRECHARGE_ALL) || 
          (command_pending && host_cmd == PRECHARGE_ALL))
        begin
          // timing to precharge-all command
          timing_met = 1'b1;
          for (i=0; i<MAX_PAGES; i=i+1)
            begin
              if (t_ras_cntr[i] || t_wtp_cntr[i] || t_rtp_cntr[i] ||
                  t_ras_hoc_to_hec[i] || t_wtp_hoc_to_hec[i] || t_rtp_hoc_to_hec[i])
                begin
                  timing_met = 1'b0;
                end
            end

          timing_met = (~timing_met || t_mod_cntr || t_rfc_cntr || t_rpa_cntr ||
                                       t_mod_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec) ? 1'b0 : 1'b1;
        end
      else if (precharge_pending ||
               (command_pending && host_cmd == PRECHARGE))
        begin
          // timing to a precharge command
          timing_met = (t_ras_cntr[host_page] ||
                        t_wtp_cntr[host_page] ||
                        t_rtp_cntr[host_page] ||
                        t_mod_cntr || t_rfc_cntr || t_rpa_cntr ||
                        t_ras_hoc_to_hec[host_page] ||
                        t_wtp_hoc_to_hec[host_page] ||
                        t_rtp_hoc_to_hec[host_page] ||
                        t_mod_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec) ? 1'b0 : 1'b1;
        end
      else if (activate_pending || 
               (command_pending && host_cmd == ACTIVATE))
        begin
          // timing to a activate command
          timing_met = (t_rp_cntr[host_page] ||
                        t_rc_cntr[host_page] ||
                        t_wtp_cntr[host_page] ||
                        t_rtp_cntr[host_page] ||
                        t_faw_cntr[3] ||
                        t_rrd_cntr ||
                        t_mod_cntr || t_rfc_cntr || t_rpa_cntr ||
                        t_rp_hoc_to_hec[host_page] ||
                        t_rc_hoc_to_hec[host_page] ||
                        t_wtp_hoc_to_hec[host_page] ||
                        t_rtp_hoc_to_hec[host_page] ||
                        t_faw_hoc_to_hec ||
                        t_rrd_hoc_to_hec ||
                        t_mod_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec) ? 1'b0 : 1'b1;
        end
      else if (command_pending && host_cmd[3:1] == ANY_WRITE)
        begin
          // timing to a write command
          timing_met = ((t_rcd_cntr[host_page] || t_rcd_hoc_to_hec[host_page]) ||
                        (t_rtw_cntr || t_rtw_hoc_to_hec) ||
                        (t_wr_last_hoc && !hdr_odd_cmd) || 
                        (t_wrrnk_cntr && (host_rank != rdwr_rank_ff)) ||
                        (((t_ras_cntr[host_page] > 0) && ((t_ras_cntr[host_page]) > 0) && host_cmd == WRITE_PRECHG) ? 1'b1 : 1'b0) ||
                        wrrnk_any_xspace ||
                        t_mod_cntr || t_rfc_cntr || t_rpa_cntr ||
                        t_mod_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec ||
                        (host_first_data && (t_ccd_l_cntr[host_bg_page]|| t_ccd_l_hoc_to_hec[host_bg_page])) ||
                        (host_first_data && (t_ccd_s_cntr[host_page]   || t_ccd_s_hoc_to_hec[host_page]   ))
 ) ? 1'b0 : 1'b1;
        end
      else if (command_pending && host_cmd[3:1] == ANY_READ)
        begin
          // timing to a read command
          timing_met = ((t_rcd_cntr[host_page] || t_rcd_hoc_to_hec[host_page]) ||
                        (t_wtr_cntr || t_wtr_hoc_to_hec) ||
                        (t_rd_last_hoc && !hdr_odd_cmd) || 
                        (t_rdrnk_cntr && (host_rank != rd_rank_ff && !hdr_mode)) ||
                        (t_rdrnk_cntr && (host_rank != rdwr_rank_ff)) ||
                        (((t_ras_cntr[host_page] > 0) && ((t_ras_cntr[host_page]) > 0) && host_cmd == READ_PRECHG) ? 1'b1 : 1'b0) ||
`ifdef DWC_DDRPHY_EMUL_XILINX
  `ifdef MSD_RND_HDR_ODD_CMD // Separate the Rd-Rd on the same rank but with differnt command (even/odd)
                        (t_rdrnk_cntr ) ||
  `endif
`endif
                        rdrnk_any_xspace ||
                        t_mod_cntr || t_rfc_cntr || t_rpa_cntr ||
                        t_mod_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec ||
//                        (cmd_ff_last_rd && bdrift_err_q) ||
                        (host_first_data && bdrift_err_q) ||
                        (host_first_data && (t_ccd_l_cntr[host_bg_page]|| t_ccd_l_hoc_to_hec[host_bg_page])) ||
                        (host_first_data && (t_ccd_s_cntr[host_page]   || t_ccd_s_hoc_to_hec[host_page]   ))
 ) ? 1'b0 : 1'b1;
        end
      else if ((refresh_pending && rfsh_rqst_cmd == REFRESH) ||
               (command_pending && 
                (host_cmd == REFRESH || host_cmd[3:1] == ANY_ZQCAL ||
                 host_cmd == SELF_REFRESH || host_cmd == POWER_DOWN))) 
        begin
          timing_met = (t_mod_cntr || t_rfc_cntr || t_rpa_cntr ||
                        t_mod_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec) ? 1'b0 : 1'b1;
        end
      else if (command_pending && host_cmd == LOAD_MODE)
        begin
          timing_met = (t_mrd_cntr || t_rfc_cntr || t_rpa_cntr ||
                        t_mrd_hoc_to_hec || t_rfc_hoc_to_hec || t_rpa_hoc_to_hec) ? 1'b0 : 1'b1;
        end
      else if (command_pending && host_cmd == SPECIAL_CMD && host_addr[3:0] == `RDIMMCRW)
        begin
          timing_met = (t_bcstab_cntr || t_bcmrd_cntr ||
                        t_bcstab_hoc_to_hec || t_bcmrd_hoc_to_hec) ? 1'b0 : 1'b1;
        end
      else
        begin
          timing_met = 1'b1;
        end
    end // block: check_timing

  // extra spacing because of rank-to-rank timing with different delays
  assign rdrnk_all_xspace  = (rdrnk_xcheck && (rdwr_rank_ff != host_rank)) ?
                             rdrnk_xspace(rdwr_rank_ff, host_rank) :
                             4'b0000;
  assign rdrnk_rsl_xspace  = rdrnk_all_xspace[0];
  assign rdrnk_xt_xspace_0 = rdrnk_all_xspace_p0[1];
  assign rdrnk_xt_xspace_1 = rdrnk_all_xspace_p1[2];
  assign rdrnk_xt_xspace_2 = rdrnk_all_xspace_p2[3];
  assign rdrnk_any_xspace  = rdrnk_rsl_xspace | rdrnk_xt_xspace_0 | rdrnk_xt_xspace_1 | rdrnk_xt_xspace_2;

//  assign wrrnk_all_xspace  = (wrrnk_xcheck && (rdwr_rank_ff != host_rank)) ?
//                             wrrnk_xspace(rdwr_rank_ff, host_rank) :
//                             4'b0000;

  assign wrrnk_all_xspace  = 4'b0000; // always a fixed 1 CTL_CLK spacing between writes to different ranks
  assign wrrnk_wsl_xspace  = wrrnk_all_xspace[0];
  assign wrrnk_xt_xspace_0 = wrrnk_all_xspace_p0[1];
  assign wrrnk_xt_xspace_1 = wrrnk_all_xspace_p1[2];
  assign wrrnk_xt_xspace_2 = wrrnk_all_xspace_p2[3];
  assign wrrnk_any_xspace  = wrrnk_wsl_xspace | wrrnk_xt_xspace_0 | wrrnk_xt_xspace_1 | wrrnk_xt_xspace_2;
 

  // adjust timing parameters for HDR mode because the clock is twice the CK
  // period (i.e. divide timing parameters by 2 - if odd number divide by 2
  // and add 1: TBD)
  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      tx_mrd      <= {tMRD_WIDTH{1'b0}};
      tx_mod      <= {tMOD_WIDTH{1'b0}};
      tx_rp       <= {tRP_WIDTH{1'b0}};
      tx_rpa      <= {tRPA_WIDTH{1'b0}};
      tx_ras      <= {tRAS_WIDTH{1'b0}};
      tx_rrd      <= {tRRD_WIDTH{1'b0}};
      tx_rc       <= {tRC_WIDTH{1'b0}};
      tx_faw      <= {tFAW_WIDTH{1'b0}};
      tx_rfc      <= {tRFC_WIDTH{1'b0}};
      tx_bcstab   <= {tBCSTAB_WIDTH{1'b0}};
      tx_bcmrd    <= {tBCMRD_WIDTH{1'b0}};
      tx_pre2act  <= {tRP_WIDTH{1'b0}};
      tx_act2rw   <= {tACT2RW_WIDTH{1'b0}};
      tx_rd2pre   <= {tRD2PRE_WIDTH{1'b0}};
      tx_wr2pre   <= {tWR2PRE_WIDTH{1'b0}};
      tx_rd2wr    <= {tRD2WR_WIDTH{1'b0}};
      tx_wr2rd    <= {tWR2RD_WIDTH{1'b0}};
      tx_rdap2act <= {tRD2PRE_WIDTH{1'b0}};
      tx_wrap2act <= {tWR2PRE_WIDTH{1'b0}};
      tx_rdrnk    <= {3{1'b0}};
      tx_wrrnk    <= {3{1'b0}};
      tx_ccd_l    <= {tCCD_WIDTH{1'b0}};
      tx_ccd_s    <= {tCCD_WIDTH{1'b0}};
    end else begin
      if (hdr_mode) begin
        // divide by 2 and subtract 1 (if even)
        tx_mrd      <= (t_mrd     [0]) ? t_mrd/2      : t_mrd/2-1;
        tx_mod      <= (t_mod     [0]) ? t_mod/2      : t_mod/2-1;
        tx_rp       <= (t_rp      [0]) ? t_rp/2       : t_rp/2-1;
        tx_rpa      <= (t_rpa     [0]) ? t_rpa/2      : t_rpa/2-1;
        tx_ras      <= (t_ras     [0]) ? t_ras/2      : t_ras/2-1;
        tx_rrd      <= (t_rrd     [0]) ? t_rrd/2      : t_rrd/2-1;
        tx_rc       <= (t_rc      [0]) ? t_rc/2       : t_rc/2-1;
        tx_faw      <= (t_faw     [0]) ? t_faw/2      : t_faw/2-1;
        tx_rfc      <= (t_rfc     [0]) ? t_rfc/2      : t_rfc/2-1;
        tx_bcstab   <= (t_bcstab  [0]) ? t_bcstab/2   : t_bcstab/2-1;
        tx_bcmrd    <= (t_bcmrd   [0]) ? t_bcmrd/2    : t_bcmrd/2-1;
        tx_pre2act  <= (t_pre2act [0]) ? t_rp/2       : t_rp/2-1;
        tx_act2rw   <= (t_act2rw  [0]) ? t_act2rw/2   : t_act2rw/2-1;
        tx_rd2pre   <= (t_rd2pre  [0]) ? t_rd2pre/2   : t_rd2pre/2-1;
        tx_wr2pre   <= (t_wr2pre  [0]) ? t_wr2pre/2   : t_wr2pre/2-1;
        tx_rd2wr    <= (t_rd2wr   [0]) ? t_rd2wr/2    : t_rd2wr/2-1;
        tx_wr2rd    <= (t_wr2rd   [0]) ? t_wr2rd/2    : t_wr2rd/2-1;
        tx_rdap2act <= (t_rdap2act[0]) ? t_rdap2act/2 : t_rdap2act/2-1;
        tx_wrap2act <= (t_wrap2act[0]) ? t_wrap2act/2 : t_wrap2act/2-1;
        tx_rdrnk    <= (t_rdrnk   [0]) ? t_rdrnk/2    : t_rdrnk/2-1;
        tx_wrrnk    <= (t_wrrnk   [0]) ? t_wrrnk/2    : t_wrrnk/2-1;
        tx_ccd_l    <= (t_ccd_l   [0]) ? t_ccd_l/2    : t_ccd_l/2-1;
        tx_ccd_s    <= (t_ccd_s   [0]) ? t_ccd_s/2    : t_ccd_s/2-1;
      end else begin
        tx_mrd      <= t_mrd-1;
        tx_mod      <= t_mod-1;
        tx_rp       <= t_rp-1;
        tx_rpa      <= t_rpa-1;
        tx_ras      <= t_ras-1;
        tx_rrd      <= t_rrd-1;
        tx_rc       <= t_rc-1;
        tx_faw      <= t_faw-1;
        tx_rfc      <= t_rfc-1;
        tx_bcstab   <= t_bcstab-1;
        tx_bcmrd    <= t_bcmrd-1;
        tx_pre2act  <= t_rp-1;
        tx_act2rw   <= t_act2rw-1;
        tx_rd2pre   <= t_rd2pre-1;
        tx_wr2pre   <= t_wr2pre-1;
        tx_rd2wr    <= t_rd2wr-1;
        tx_wr2rd    <= t_wr2rd-1;
        tx_rdap2act <= t_rdap2act-1;
        tx_wrap2act <= t_wrap2act-1;
        tx_rdrnk    <= t_rdrnk-1;
        tx_wrrnk    <= t_wrrnk-1;
        tx_ccd_l    <= t_ccd_l-1;
        tx_ccd_s    <= t_ccd_s-1;
      end
    end // else: !if(rst_b == 1'b0)
  end // always @ (posedge clk or negedge rst_b)

  // check if a byte needs extra spacing because the byte is delayed for one rank
  // and is early for the next rank to avoid them corriding
  function [3:0] rdrnk_xspace;
    input [1:0] rank1;
    input [1:0] rank2;
    
    reg [2:0] gdqs_pipe1, gdqs_pipe2;
    reg [7:0] gdqs_lcdl1, gdqs_lcdl2;
    integer dly1, dly2;
    integer lane_no;
    integer step_size;
    
    begin
      rdrnk_xspace = 4'b0000;
      step_size = 10;
      for (lane_no=0; lane_no<pNUM_LANES; lane_no=lane_no+1) begin
        gdqs_pipe1 = `GRM.get_dqs_gate_pipeline(rank1, lane_no);
        gdqs_pipe2 = `GRM.get_dqs_gate_pipeline(rank2, lane_no);
        gdqs_lcdl1 = `GRM.get_dqs_gate_lcdl_dly(rank1, lane_no);
        gdqs_lcdl2 = `GRM.get_dqs_gate_lcdl_dly(rank2, lane_no);
        dly1       = gdqs_pipe1 * `CLK_PRD*1000 + step_size * gdqs_lcdl1;
        dly2       = gdqs_pipe2 * `CLK_PRD*1000 + step_size * gdqs_lcdl2;

        // NOTE: rank-to-rank spacing is no longer variable - it is fixed at extra 2
        //       clock cycles using the tRD_RNK2RNK parameter 
        // add extra clock separation only if DQS gate is extended
        if (`GRM.dqs_gatex) begin
          rdrnk_xspace[0*pFRQ_RATIO +: pFRQ_RATIO] = {pFRQ_RATIO{1'b1}};
        end
      end 
   end
  endfunction // rdrnk_xspace
    

  function [3:0] wrrnk_xspace;
    input [1:0] rank1;
    input [1:0] rank2;
    
    reg [1:0] wl_pipe1, wl_pipe2;
    reg [7:0] wl_lcdl1, wl_lcdl2;
    reg wl_pipe1_late, wl_pipe1_early;
    reg wl_pipe2_late, wl_pipe2_early;
    integer lane_no;
    begin
      wrrnk_xspace = 4'b0000;
      for (lane_no=0; lane_no<pNUM_LANES; lane_no=lane_no+1) begin
        wl_pipe1 = `GRM.get_wl_pipeline(rank1, lane_no);
        wl_pipe2 = `GRM.get_wl_pipeline(rank2, lane_no);
        wl_lcdl1 = `GRM.get_wl_lcdl_dly(rank1, lane_no);
        wl_lcdl2 = `GRM.get_wl_lcdl_dly(rank2, lane_no);

        {wl_pipe1_late, wl_pipe1_early} = wl_pipe1;
        {wl_pipe2_late, wl_pipe2_early} = wl_pipe2;

        // NOTE: rank-to-rank spacing is no longer variable - it is fixed at extra 4
        //       clock cycles using the tWR_RNK2RNK parameter 
      end
    end
  endfunction // wrrnk_xspace


  // address mapping
  // ---------------
  // maps host address into SDRAM rank, bank, row and column address
  always @(*)
    begin: address_mapping
      // defaults
      host_rank = {pRANK_WIDTH{1'b0}};
      host_bank = {pBANK_WIDTH{1'b0}};
      host_bg   = {pBG_WIDTH {1'b0}};
      hmap_row  = {pROW_WIDTH{1'b0}};
      host_col  = {pCOL_WIDTH{1'b0}};

      case (sdram_chip)
        // 256Mb SDRAMs
        DDR_256Mbx4: 
          begin 
            host_rank       = host_addr[26 +: pRANK_WIDTH];
            host_bank[1:0]  = host_addr[25:24];
            hmap_row[12:0]  = host_addr[23:11];
            host_col[10:0]  = host_addr[10:0];
          end 
        DDR_256Mbx8: 
          begin 
            host_rank       = host_addr[25 +: pRANK_WIDTH];
            host_bank[1:0]  = host_addr[24:23];
            hmap_row[12:0]  = host_addr[22:10];
            host_col[9:0]   = host_addr[9:0];
          end 
        DDR_256Mbx16: 
          begin 
            host_rank       = host_addr[24 +: pRANK_WIDTH];
            host_bank[1:0]  = host_addr[23:22];
            hmap_row[12:0]  = host_addr[21:9];
            host_col[8:0]   = host_addr[8:0];
          end 

        // 512 Mb SDRAMs
        DDR_512Mbx4: 
          begin 
            if (ddr3_mode)
              begin
                host_rank       = host_addr[27 +: pRANK_WIDTH];
                host_bank       = host_addr[26:24];
                hmap_row[12:0]  = host_addr[23:11];
                host_col[10:0]  = host_addr[10:0];
              end
            else
              begin
                host_rank       = host_addr[27 +: pRANK_WIDTH];
                host_bank[1:0]  = host_addr[26:25];
                hmap_row[13:0]  = host_addr[24:11];
                host_col[10:0]  = host_addr[10:0];
              end
          end 
        DDR_512Mbx8: 
          begin 
            if (ddr3_mode)
              begin
                host_rank       = host_addr[26 +: pRANK_WIDTH];
                host_bank       = host_addr[25:23];
                hmap_row[12:0]  = host_addr[22:10];
                host_col[9:0]   = host_addr[9:0];
              end
            else
              begin
                host_rank       = host_addr[26 +: pRANK_WIDTH];
                host_bank[1:0]  = host_addr[25:24];
                hmap_row[13:0]  = host_addr[23:10];
                host_col[9:0]   = host_addr[9:0];
              end
          end 
        DDR_512Mbx16: 
          begin 
            if (ddr3_mode)
              begin
                host_rank       = host_addr[25 +: pRANK_WIDTH];
                host_bank       = host_addr[24:22];
                hmap_row[11:0]  = host_addr[21:10];
                host_col[9:0]   = host_addr[9:0];
              end
            else
              begin
                host_rank       = host_addr[25 +: pRANK_WIDTH];
                host_bank[1:0]  = host_addr[24:23];
                hmap_row[12:0]  = host_addr[22:10];
                host_col[9:0]   = host_addr[9:0];
              end
          end

        // 1Gb SDRAMs        
        DDR_1Gbx4:
          begin
            host_rank       = host_addr[28 +: pRANK_WIDTH];
            host_bank       = host_addr[27:25];
            hmap_row [13:0] = host_addr[24:11];
            host_col[10:0]  = host_addr[10:0];
          end
        DDR_1Gbx8:
          begin
            if (lpddrx_mode) begin
              host_rank      = host_addr[27 +: pRANK_WIDTH];
              host_bank      = host_addr[26:24];
              hmap_row[12:0] = host_addr[23:11];
              host_col[10:0] = host_addr[10:0];
            end else begin
              host_rank      = host_addr[27 +: pRANK_WIDTH];
              host_bank      = host_addr[26:24];
              hmap_row[13:0] = host_addr[23:10];
              host_col[9:0]  = host_addr[9:0];
            end
          end
        DDR_1Gbx16:
          begin
            host_rank      = host_addr[26 +: pRANK_WIDTH];
            host_bank      = host_addr[25:23];
            hmap_row[12:0] = host_addr[22:10];
            host_col[9:0]  = host_addr[9:0];
          end
          DDR_1Gbx32:
            begin
              host_rank      = host_addr[25 +: pRANK_WIDTH];
              host_bank      = host_addr[24:22];
              hmap_row[12:0] = host_addr[21:9];
              host_col[8:0]  = host_addr[8:0];
            end

        // 2Gb SDRAMs        
        DDR_2Gbx4:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              //host_bank      = host_addr[31:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[31:30];
              hmap_row[14:0] = host_addr[24:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[29 +: pRANK_WIDTH];
              host_bank      = host_addr[28:26];
              hmap_row[14:0] = host_addr[25:11];
              host_col[10:0] = host_addr[10:0];
            end
          end
        DDR_2Gbx8:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              //host_bank      = host_addr[31:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[31:30];
              hmap_row[13:0] = host_addr[23:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[28 +: pRANK_WIDTH];
              host_bank      = host_addr[27:25];
              hmap_row[14:0] = host_addr[24:10];
              host_col[9:0]  = host_addr[9:0];
            end
          end
        DDR_2Gbx16:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[31 +: pRANK_WIDTH];
              //host_bank      = host_addr[30:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[30];
              hmap_row[13:0] = host_addr[23:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[27 +: pRANK_WIDTH];
              host_bank      = host_addr[26:24];
              hmap_row[13:0] = host_addr[23:10];
              host_col[9:0]  = host_addr[9:0];
            end
          end

        // 4Gb SDRAMs        
        DDR_4Gbx4:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              //host_bank      = host_addr[31:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[31:30];
              hmap_row[15:0] = host_addr[25:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[30 +: pRANK_WIDTH];
              host_bank      = host_addr[29:27];
              hmap_row[15:0] = host_addr[26:11];
              host_col[10:0] = host_addr[10:0];
            end
          end
        DDR_4Gbx8:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              //host_bank      = host_addr[31:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[31:30];
              hmap_row[14:0] = host_addr[24:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              if (lpddr2_mode) begin
                host_rank      = host_addr[29 +: pRANK_WIDTH];
                host_bank      = host_addr[28:26];
                hmap_row[13:0] = host_addr[25:12];
                host_col[11:0] = host_addr[11:0];
              end else begin                
                host_rank      = host_addr[29 +: pRANK_WIDTH];
                host_bank      = host_addr[28:26];
                hmap_row[15:0] = host_addr[25:10];
                host_col[9:0]  = host_addr[9:0];
              end
            end
          end
        DDR_4Gbx16:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[31 +: pRANK_WIDTH];
              //host_bank      = host_addr[30:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[30];
              hmap_row[14:0] = host_addr[24:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              if (lpddr2_mode) begin
                host_rank      = host_addr[28 +: pRANK_WIDTH];
                host_bank      = host_addr[27:25];
                hmap_row[13:0] = host_addr[24:11];
                host_col[10:0] = host_addr[10:0];
              end else begin                
                host_rank      = host_addr[28 +: pRANK_WIDTH];
                host_bank      = host_addr[27:25];
                hmap_row[14:0] = host_addr[24:10];
                host_col[9:0]  = host_addr[9:0];
              end
            end
          end
        DDR_4Gbx32:
          begin
              //lpddr3/2
              host_rank      = host_addr[27 +: pRANK_WIDTH];
              host_bank      = host_addr[26:24];
              hmap_row[13:0] = host_addr[23:10];
              host_col[9:0]  = host_addr[9:0];
            end


        // 8Gb SDRAMs        
        DDR_8Gbx4:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              //host_bank      = host_addr[31:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[31:30];
              hmap_row[16:0] = host_addr[26:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[31 +: pRANK_WIDTH];
              host_bank      = host_addr[30:28];
              hmap_row[15:0] = host_addr[27:12];
              host_col[11:0] = host_addr[11:0];
            end
          end
        DDR_8Gbx8:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              //host_bank      = host_addr[31:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[31:30];
              hmap_row[15:0] = host_addr[25:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[30 +: pRANK_WIDTH];
              host_bank      = host_addr[29:27];
              hmap_row[15:0] = host_addr[26:11];
              host_col[10:0] = host_addr[10:0];
            end
          end
        DDR_8Gbx16:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[31 +: pRANK_WIDTH];
              //host_bank      = host_addr[30:28];
              host_bank      = host_addr[29:28];
              host_bg        = host_addr[30];
              hmap_row[15:0] = host_addr[25:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end else begin
              host_rank      = host_addr[29 +: pRANK_WIDTH];
              host_bank      = host_addr[28:26];
              hmap_row[15:0] = host_addr[25:10];
              host_col[9:0]  = host_addr[9:0];
            end
          end
        
        // 16Gb SDRAMs        
        DDR_16Gbx4:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              host_bg        = host_addr[31:30];
              host_bank      = host_addr[29:28];
              hmap_row[17:0] = host_addr[27:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end 
          end
        DDR_16Gbx8:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[32 +: pRANK_WIDTH];
              host_bg        = host_addr[31:30];
              host_bank      = host_addr[29:28];
              hmap_row[16:0] = host_addr[26:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end 
          end
        DDR_16Gbx16:
          begin
            if (ddr4_mode) begin
              host_rank      = host_addr[31 +: pRANK_WIDTH];
              host_bg        = host_addr[30];
              host_bank      = host_addr[29:28];
              hmap_row[16:0] = host_addr[26:10]; // SDRAM_ROW_WIDTH is 18
              host_col[9:0]  = host_addr[9:0];
            end
          end
        
        default: // DDR_8Gbx16; not ddr4_mode
          begin
            host_rank      = host_addr[29 +: pRANK_WIDTH];
            host_bank      = host_addr[28:26];
            hmap_row[15:0] = host_addr[25:10];
            host_col[9:0]  = host_addr[9:0];
          end
      endcase // case(sdram_chip)
    end // block: address_mapping

  integer i;
  
  always@(*) begin
    for (i=0;i<pROW_WIDTH;i=i+1) begin
      if (i>16) begin
        host_row[i] = 1'b0;
      end
      else begin
        host_row[i] = hmap_row[i];
      end
    end
  end

  
  //---------------------------------------------------------------------------
  // Command Translation
  //---------------------------------------------------------------------------
  // translates the high-level command from application to low-level PHY
  // signals
  assign cmd     = (hdr_odd_cmd_ff) ? SDRAM_NOP                : cmd_ff;
  assign rank    = (hdr_odd_cmd_ff) ? {pRANK_WIDTH{1'b0}}      : rank_ff;
  assign bank    = (hdr_odd_cmd_ff) ? {pMCTL_BANK_WIDTH{1'b0}} : bank_ff;
  assign bg      = (hdr_odd_cmd_ff) ? {pMCTL_BG_WIDTH{1'b0}}   : bg_ff;
  assign addr    = (hdr_odd_cmd_ff) ? {pMCTL_ADDR_WIDTH{1'b0}} : addr_ff;
  assign data    = data_ff;
  assign gp_flag = gp_flag_ff;
  assign ck_en   = ck_en_ff;

  assign cmd_1   = (hdr_odd_cmd_ff) ? cmd_ff  : SDRAM_NOP;
  assign rank_1  = (hdr_odd_cmd_ff) ? rank_ff : {pRANK_WIDTH{1'b0}};
  assign bank_1  = (hdr_odd_cmd_ff) ? bank_ff : {pMCTL_BANK_WIDTH{1'b0}};
  assign bg_1    = (hdr_odd_cmd_ff) ? bg_ff   : {pMCTL_BG_WIDTH{1'b0}};
  assign addr_1  = (hdr_odd_cmd_ff) ? addr_ff : {pMCTL_ADDR_WIDTH{1'b0}};

  // The following is to time the hdr odd or even commands for dfi_bfm
  always @(*) begin
    if (rst_b == 1'b0)
      hdr_odd_cmd_reg <= 1'b0;
    else begin
      if (cmd_1 != SDRAM_NOP)
        hdr_odd_cmd_reg <= 1'b1;
      else 
        if (cmd != SDRAM_NOP)
          hdr_odd_cmd_reg <= 1'b0;
        else
          hdr_odd_cmd_reg <= hdr_odd_cmd_reg;
    end
  end

  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      hdr_odd_cmd_d0 <= 1'b0;
      hdr_odd_cmd_d1 <= 1'b0;
      hdr_odd_cmd_d2 <= 1'b0;
    end
    else begin
      hdr_odd_cmd_d0 <= hdr_odd_cmd_reg;
      hdr_odd_cmd_d1 <= hdr_odd_cmd_d0;
      hdr_odd_cmd_d2 <= hdr_odd_cmd_d1;
    end
  end

  // This is just the delay version of `SYS.hdr_odd_cmd, used for comparing hdr odd/even
  // mode in order to avoid packing reads writes to close especially in heoc and 2t mode
  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0)
      sys_hdr_odd_cmd_d0 <= 1'b0;
    else
      sys_hdr_odd_cmd_d0 <= hdr_odd_cmd;
  end
  
  assign hdr_odd_cmd_stable = (hdr_odd_cmd ^ sys_hdr_odd_cmd_d0) ? 1'b0: 1'b1;
           
  // command decode
  assign no_cmd       = (cmd_ff        == SDRAM_NOP)     ? 1'b1 : 1'b0;
  assign any_zqcal    = (cmd    [3:1]  == ANY_ZQCAL)     ? 1'b1 : 1'b0;
  assign any_zqcal_1  = (cmd_1  [3:1]  == ANY_ZQCAL)     ? 1'b1 : 1'b0;
  assign any_pre      = (cmd    [3:1]  == ANY_PRECHARGE) ? 1'b1 : 1'b0;
  assign any_pre_1    = (cmd_1  [3:1]  == ANY_PRECHARGE) ? 1'b1 : 1'b0;
  assign any_rd       = ((cmd_ff[3:1]  == ANY_READ) ||
                         (cmd_ff == READ_MODE && lpddrx_mode)) ? 1'b1 : 1'b0;
  assign any_wr       =    (cmd_ff [3:1]  == ANY_WRITE) 
                        || (ldmr_cmd && `SYS.load_mode_pda_en)    ? 1'b1 : 1'b0;
  assign rw_cmd       = (cmd_ff [3:2]  == READ_WRITE)    ? 1'b1 : 1'b0;
  assign rw_cmd_blfxd = ((cmd_ff[3:2]  == READ_WRITE) && !ddr3_blotf) ?
         1'b1 : 1'b0;
  assign rw_cmd_blotf = ((cmd_ff[3:2]  == READ_WRITE) &&  ddr3_blotf) ?
         1'b1 : 1'b0;
  assign ldmr_cmd     = (cmd_ff == LOAD_MODE)    ? 1'b1 : 1'b0;
  assign rfsh_cmd     = (cmd_ff == REFRESH)      ? 1'b1 : 1'b0;
  assign pwrdn_cmd    = (cmd_ff == POWER_DOWN)   ? 1'b1 : 1'b0;
  assign sfrfsh_cmd   = (cmd_ff == SELF_REFRESH) ? 1'b1 : 1'b0;
  assign init_cmd     = (cmd_ff == PRECHARGE_ALL || cmd_ff == LOAD_MODE ||
                         cmd_ff == REFRESH || cmd_ff == ZQCAL_LONG) ? 1'b1 : 1'b0;
  assign reset_hi     = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `RESET_HI)  ? 1'b1 : 1'b0;
  assign cke_hi       = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `CKE_HI)    ? 1'b1 : 1'b0;
  assign ck_start     = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `CK_START)  ? 1'b1 : 1'b0;
  assign odt_off      = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `ODT_OFF)   ? 1'b1 : 1'b0;
  assign mode_exit    = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `MODE_EXIT) ? 1'b1 : 1'b0;
  assign rdimm_wr     = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `RDIMMCRW)  ? 1'b1 : 1'b0;
  assign ctrl_cmd     = (cmd_ff == SPECIAL_CMD) ? 1'b1 : 1'b0;
  assign bst_cmd      = (cmd_ff == TERMINATE && (lpddrx_mode==1'b1)) ? 1'b1 : 1'b0;

 `ifdef LPDDRX   // [DEEP POWER DOWN] #Comand detention
    assign deep_pwrdn_cmd    = (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `DEEP_POWER_DOWN) ? 1'b1 : 1'b0;
`else
    assign deep_pwrdn_cmd    = 1'b0;
`endif  // [DEEP POWER DOWN]

  always @(*) begin
    if (rst_b == 1'b0) begin
      reset_lo = 1'b0;
      cke_lo   = 1'b0;
      ck_stop  = 1'b0;
      odt_on   = 1'b0;
    end else begin
      if (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `RESET_LO) begin
        reset_lo = 1'b1;
      end else if (reset_hi) begin
        reset_lo = 1'b0;
      end
      
      if (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `CKE_LO) begin
        cke_lo   = 1'b1;
      end else if (cke_hi) begin
        cke_lo   = 1'b0;
      end

      if (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `CK_STOP) begin
        ck_stop  = 1'b1;
      end else if (ck_start) begin
        ck_stop  = 1'b0;
      end

      if (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `ODT_ON) begin
        odt_on   = 1'b1;
      end else if (odt_off) begin
        odt_on   = 1'b0;
      end
    end
  end

  // predecode chip selects
  // all ranks are activated during initialization, 
  // load-mode register writes, refresh, and precharge-all
  // and power-down/self-refresh
  always @(*)begin: chip_select
    integer i;
    if (cmd_ff == SPECIAL_CMD && addr_ff[3:0] == `RDIMMCRW) begin
      // RDIMM register writes drives all (or two) chips selects low, but driving 
      // 3 chips selects low is not allowed
      if (pNO_OF_RANKS == 3) begin
        cs_b   = 3'b100;
        cs_b_1 = 3'b100;
      end else begin
        cs_b   = {pNO_OF_RANKS{1'b0}};
        cs_b_1 = {pNO_OF_RANKS{1'b0}};
      end

      // *** TBD: 3DS for this mode to be added later
      cid   = {`DWC_CID_WIDTH{1'b0}};
      cid_1 = {`DWC_CID_WIDTH{1'b0}};
      //1-ddrx  //[CS_N] # Chip select pins assignment changed according to JEDEC
      // # For lpddr modes, deep power down flag added and load mode flag added 
    end else if ((`GRM.ddr4_mode||`GRM.ddr3_mode||`GRM.ddr2_mode) && (`DWC_NO_SRA && (sfrfsh_cmd || pwrdn_cmd || mode_exit))) begin
      if(pNO_OF_RANKS == 2) begin
        if(rank_ff==2'h0) cs_lines = 2'b10;
        else cs_lines    =2'b01;
      end else if(pNO_OF_RANKS == 3) begin
        case(rank_ff)
          2'h0: cs_lines = 3'b110;
          2'h1: cs_lines = 3'b101;
          2'h2: cs_lines = 3'b011;
        endcase
      end else if(pNO_OF_RANKS == 4) begin
        case(rank_ff)
         2'h0: cs_lines = 4'b1110;
         2'h1: cs_lines = 4'b1101;
         2'h2: cs_lines = 4'b1011;
         2'h3: cs_lines = 4'b0111;
        endcase
      end else begin
        cs_lines = {pNO_OF_RANKS{1'b0}};
      end if(hdr_odd_cmd)begin
        cs_b   = (~ddr_2t) ? {pNO_OF_RANKS{1'b1}} : cs_lines ;
        cs_b_1 = (~ddr_2t) ? cs_lines : {pNO_OF_RANKS{1'b1}};
      end else begin
        cs_b   = cs_lines;
        cs_b_1 = {pNO_OF_RANKS{1'b1}};
      end // TODO -> Removed Gen2 equation and updated with equation from DDR3/2 PHY.
      // else if ((!`DWC_NO_SRA  && init_cmd && !gp_flag) || sfrfsh_cmd || pwrdn_cmd || mode_exit) begin

      // *** TBD: 3DS for this mode to be added later
      cid   = {`DWC_CID_WIDTH{1'b0}};
      cid_1 = {`DWC_CID_WIDTH{1'b0}};
    end else if ((`GRM.ddr4_mode||`GRM.ddr3_mode||`GRM.ddr2_mode) && (((init_cmd  && `DWC_NO_SRA == 0)|| sfrfsh_cmd  || pwrdn_cmd || mode_exit) && gp_flag == 1'b0)) begin   
      `ifdef DWC_USE_SHARED_AC_TB
      if (pCHANNEL_NO == 0) begin
        cs_b   = 4'b1010;
        cs_b_1 = 4'b1010;
      end else begin
        cs_b   = 4'b0101;
        cs_b_1 = 4'b0101;
      end
      `else
      cs_lines    = {pNO_OF_RANKS{1'b0}};
      if(hdr_odd_cmd) begin
        cs_b   = (~ddr_2t) ? {pNO_OF_RANKS{1'b1}} : cs_lines;
        cs_b_1 = (~ddr_2t) ? cs_lines : {pNO_OF_RANKS{1'b1}};
      end else begin
        cs_b   = cs_lines;
        cs_b_1 = {pNO_OF_RANKS{1'b1}};
      end
      `endif

      // *** TBD: 3DS for this mode to be added later
      cid   = {`DWC_CID_WIDTH{1'b0}};
      cid_1 = {`DWC_CID_WIDTH{1'b0}};
    //2-lpddrx 
    end else if ((`GRM.lpddr3_mode||`GRM.lpddr2_mode) && (`DWC_NO_SRA && (sfrfsh_cmd || pwrdn_cmd ||deep_pwrdn_cmd ||mode_exit))) begin   
      if(pNO_OF_RANKS == 2) begin
        if(rank_ff==2'h0) cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 2'b10 : 2'b01;
        else cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 2'b01 : 2'b10;
      end
      else if(pNO_OF_RANKS == 3) begin
        case(rank_ff)
         2'h0: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 3'b110 : 3'b001;
         2'h1: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 3'b101 : 3'b010;
         2'h2: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 3'b011 : 3'b100;
        endcase
      end else if(pNO_OF_RANKS == 4) begin
        case(rank_ff)
         2'h0: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd ) ? 4'b1110 : 4'b0001;
         2'h1: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 4'b1101 : 4'b0010;
         2'h2: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 4'b1011 : 4'b0100;
         2'h3: cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? 4'b0111 : 4'b1000;
        endcase
      end else begin
        cs_lines = (sfrfsh_cmd || deep_pwrdn_cmd) ? {pNO_OF_RANKS{1'b0}} : {pNO_OF_RANKS{1'b1}};
      end
      
      if(hdr_odd_cmd) begin
        cs_b   = {pNO_OF_RANKS{1'b1}};
        cs_b_1 = cs_lines;
      end else begin
        cs_b   = cs_lines;
        cs_b_1 = {pNO_OF_RANKS{1'b1}};
      end

      // *** TBD: 3DS for this mode to be added later
      cid   = {`DWC_CID_WIDTH{1'b0}};
      cid_1 = {`DWC_CID_WIDTH{1'b0}};
    end else if ((`GRM.lpddr3_mode||`GRM.lpddr2_mode) && (((init_cmd  && `DWC_NO_SRA == 0) || sfrfsh_cmd  || pwrdn_cmd ||deep_pwrdn_cmd||mode_exit) && gp_flag == 1'b0)) begin       
      `ifdef DWC_USE_SHARED_AC_TB
      if (pCHANNEL_NO == 0) begin
        cs_b   = (init_cmd || sfrfsh_cmd || deep_pwrdn_cmd  ) ? 4'b1010 : 4'b0101;
        cs_b_1 = (init_cmd || sfrfsh_cmd || deep_pwrdn_cmd ) ? 4'b1010 : 4'b0101;;
      end else begin
        cs_b   = (init_cmd || sfrfsh_cmd || deep_pwrdn_cmd) ? 4'b0101 : 4'b1010;
        cs_b_1 = (init_cmd || sfrfsh_cmd || deep_pwrdn_cmd) ? 4'b0101 : 4'b1010;
      end
      `else
      cs_b   = (init_cmd || sfrfsh_cmd ||deep_pwrdn_cmd ||pwrdn_cmd) ? {pNO_OF_RANKS{1'b0}} : {pNO_OF_RANKS{1'b1}};
      cs_b_1 = (init_cmd || sfrfsh_cmd ||deep_pwrdn_cmd ||pwrdn_cmd) ? (~ddr_2t) ? {pNO_OF_RANKS{1'b0}} : {pNO_OF_RANKS{1'b1}} : (~ddr_2t) ? {pNO_OF_RANKS{1'b1}} : {pNO_OF_RANKS{1'b0}};
      `endif

      // *** TBD: 3DS for this mode to be added later
      cid   = {`DWC_CID_WIDTH{1'b0}};
      cid_1 = {`DWC_CID_WIDTH{1'b0}};
    //[CS_N]
    end else begin 
      cs_b   = {pNO_OF_RANKS{1'b1}};
      cs_b_1 = {pNO_OF_RANKS{1'b1}};
      cid    = {`DWC_CID_WIDTH{1'b0}};
      cid_1  = {`DWC_CID_WIDTH{1'b0}};

      if (cmd_ff != SDRAM_NOP && `NUM_3DS_STACKS == 0) begin
        if (hdr_odd_cmd_ff) begin
          // ODD Command
          if (~ddr_2t) begin
            // Normal, non-2t mode
            cs_b  [rank_1] = 1'b1;
            cs_b_1[rank_1] = 1'b0;
          end else begin
            // 2t mode
            cs_b  [rank_1] = 1'b0;
            cs_b_1[rank_1] = 1'b1;
          end
        end else begin
          // Even Command
          if (~ddr_2t) begin
            // Normal, non-2t mode
            cs_b  [rank  ] = 1'b0;
            cs_b_1[rank  ] = 1'b1;
          end else begin
            // 2t mode
            cs_b  [rank  ] = 1'b0;
            cs_b_1[rank  ] = 1'b1;
          end
        end
      end

      if (cmd_ff != SDRAM_NOP && `NUM_3DS_STACKS > 0) begin
        // extract the physical rank number and the chip ID
        rank_3ds   = rank   / `NUM_3DS_STACKS;
        rank_3ds_1 = rank_1 / `NUM_3DS_STACKS;
        cid        = rank   % `NUM_3DS_STACKS;
        cid_1      = rank_1 % `NUM_3DS_STACKS;
 
        if (hdr_odd_cmd_ff) begin
          // ODD Command
          if (~ddr_2t) begin
            // Normal, non-2t mode
            cs_b  [rank_3ds_1] = 1'b1;
            cs_b_1[rank_3ds_1] = 1'b0;
          end else begin
            // 2t mode
            cs_b  [rank_3ds_1] = 1'b0;
            cs_b_1[rank_3ds_1] = 1'b1;
          end
        end else begin
          // Even Command
          if (~ddr_2t) begin
            // Normal, non-2t mode
            cs_b  [rank_3ds  ] = 1'b0;
            cs_b_1[rank_3ds  ] = 1'b1;
          end else begin
            // 2t mode
            cs_b  [rank_3ds  ] = 1'b0;
            cs_b_1[rank_3ds  ] = 1'b1;
          end
        end
      end
      
    end // else: !if((`GRM.lpddr3_mode||`GRM.lpddr2_mode) && (((init_cmd  && `DWC_NO_SRA == 0) || sfrfsh_cmd  || pwrdn_cmd ||deep_pwrdn_cmd||mode_exit) && gp_flag == 1'b0))
    
    // ODT enable
    if      (any_rd) odt <= rdodt;
    else if (any_wr) odt <= wrodt;
    else             odt <= {pNO_OF_RANKS{1'b0}};
  end

  // ODT configuration selection
  always @(*) begin
    for (rank_id =0; rank_id < pNO_OF_PRANKS; rank_id = rank_id + 1) begin 
      // for odd hdr 
      if (`NUM_3DS_STACKS > 0) begin
        if (hdr_odd_cmd_ff) begin
          if (rank_3ds_1 == rank_id) begin
            {wrodt, rdodt} = {wr_odt[rank_3ds_1], rd_odt[rank_3ds_1]};
          end
        end
        else begin
          if (rank_3ds == rank_id) begin
            {wrodt, rdodt} = {wr_odt[rank_3ds], rd_odt[rank_3ds]};
          end
        end
      end
      else begin
        if (hdr_odd_cmd_ff) begin
          if (rank_1 == rank_id) begin
            {wrodt, rdodt} = {wr_odt[rank_1], rd_odt[rank_1]};
          end
        end
        else begin
          if (rank == rank_id) begin
            {wrodt, rdodt} = {wr_odt[rank], rd_odt[rank]};
          end
        end
      end // else (`NUM_3DS_STACKS > 0)
    end
  end

  // ODTCR register bits
  always @(*) begin
    for (rank_i =0; rank_i < pNO_OF_PRANKS; rank_i = rank_i + 1) begin 
      wr_odt[rank_i] = `GRM.odtcr[rank_i][27:16]; 
      rd_odt[rank_i] = `GRM.odtcr[rank_i][11: 0];
    end
  end

  //---------------------------------------------------------------------------
  // SDRAM Write Control and Data Path
  //---------------------------------------------------------------------------
  // write path control and pipelines
  assign ddr_wr_cmd = (any_wr || (wr_burst && !ddr3_bl4_nop)) ? 1'b1 : 1'b0;
  assign ddr_d_in   = {ddr_wr_cmd, data};
  assign odt_in     = {hdr_odd_cmd_ff,  (any_wr || any_rd), odt[pNO_OF_RANKS-1:0]} & 
                      {pWL_OPIPE_WIDTH{~ddr3_mode}}; // for DDR2

  // pipeline for write latency, i.e. from when the write command is issued
  // to the SDRAM to when write data is driven onto the DQ/DQs bus
  always @(posedge clk or negedge rst_b) begin: write_pipeline
    integer i;
    
    if (rst_b == 1'b0) begin
      for (i=(pWL_DPIPE_DEPTH-1); i>=0; i=i-1) begin
        ddr_d_p[i] <= {pWL_DPIPE_WIDTH{1'b0}};
      end
      for (i=pWL_OPIPE_MAX; i>=pWL_OPIPE_MIN; i=i-1) begin
        odt_p[i] <= {pWL_OPIPE_WIDTH{1'b0}};
      end
      ddr_wr_ff   <= 1'b0;
      ddr_wr_ff_2 <= 1'b0;
      ddr_dm_ff   <= {(pNUM_LANES*pCLK_NX*2 ){1'b0}};
      ddr_dm_ff_2 <= {(pNUM_LANES*pCLK_NX*2 ){1'b0}};
      ddr_do_ff   <= {(pNO_OF_BYTES*pCLK_NX*16){1'b0}};
      ddr_do_ff_2 <= {(pNO_OF_BYTES*pCLK_NX*16){1'b0}};
      ddr_lwr_wrd_do_ff   <= {(pNO_OF_BYTES*pCLK_NX*8){1'b0}};
      ddr_upr_wrd_do_ff   <= {(pNO_OF_BYTES*pCLK_NX*8){1'b0}};
      ddr_lwr_wrd_do_ff_2 <= {(pNO_OF_BYTES*pCLK_NX*8){1'b0}};
      ddr_upr_wrd_do_ff_2 <= {(pNO_OF_BYTES*pCLK_NX*8){1'b0}};

      ddr_lwr_wrd_dm_ff   <= {(pNUM_LANES*pCLK_NX){1'b0}};
      ddr_upr_wrd_dm_ff   <= {(pNUM_LANES*pCLK_NX){1'b0}};
      ddr_lwr_wrd_dm_ff_2 <= {(pNUM_LANES*pCLK_NX){1'b0}};
      ddr_upr_wrd_dm_ff_2 <= {(pNUM_LANES*pCLK_NX){1'b0}};
      
      end
    else begin
      // write tag and data
      // write data valid (delayed one clock later because it uses a
      // 90 degrees clock in the DDRO)
      ddr_d_p[pWL_DPIPE_DEPTH-1] <= ddr_d_in;
      for (i=(pWL_DPIPE_DEPTH-2); i>=0; i=i-1) begin
        ddr_d_p[i] <= (t_wl == i) ? ddr_d_in : ddr_d_p[i+1];
      end
      ddr_wr_ff   <= ddr_wr;
      ddr_wr_ff_2 <= ddr_wr_ff;
      ddr_dm_ff   <= ddr_dm;
      ddr_dm_ff_2 <= ddr_dm_ff;
      ddr_do_ff   <= ddr_do;
      ddr_do_ff_2 <= ddr_do_ff;
      
      ddr_lwr_wrd_do_ff <= ddr_lwr_wrd_do;
      ddr_upr_wrd_do_ff <= ddr_upr_wrd_do;
      ddr_lwr_wrd_do_ff_2 <= ddr_lwr_wrd_do_ff;
      ddr_upr_wrd_do_ff_2 <= ddr_upr_wrd_do_ff;

      ddr_lwr_wrd_dm_ff <= ddr_lwr_wrd_dm;
      ddr_upr_wrd_dm_ff <= ddr_upr_wrd_dm;
      ddr_lwr_wrd_dm_ff_2 <= ddr_lwr_wrd_dm_ff;
      ddr_upr_wrd_dm_ff_2 <= ddr_upr_wrd_dm_ff;

      // ODT: The odd/even flag always propagates
      odt_p[pWL_OPIPE_MAX] <= (t_ol == pWL_OPIPE_MAX) ? 
                              odt_in : {odt_in[pWL_OPIPE_WIDTH-1], {(pWL_OPIPE_WIDTH-1){1'b0}}};
      for (i=(pWL_OPIPE_MAX-1); i>=pWL_OPIPE_MIN; i=i-1) begin
        odt_p[i] <= (t_ol == i) ? odt_in : odt_p[i+1];
      end
    end
  end

  // Prepare data pipe for Even cmd + odd wl    OR   Odd cmd + even wl
  always @(*) begin
    if (hdr_mode) begin
      {ddr_wr,    ddr_upr_wrd_dm   , ddr_lwr_wrd_dm   , ddr_upr_wrd_do   , ddr_lwr_wrd_do   } = ddr_d_p[0];
      {ddr_wr_m1, ddr_upr_wrd_dm_m1, ddr_lwr_wrd_dm_m1, ddr_upr_wrd_do_m1, ddr_lwr_wrd_do_m1} = (t_wl == 0) ? ddr_d_in : ddr_d_p[1];
      {ddr_wr_m2, ddr_upr_wrd_dm_m2, ddr_lwr_wrd_dm_m2, ddr_upr_wrd_do_m2, ddr_lwr_wrd_do_m2} = (t_wl == 1) ? ddr_d_in : ddr_d_p[2];

      ddr_do    = {ddr_upr_wrd_do   , ddr_lwr_wrd_do};
      ddr_wr_m1 = {ddr_upr_wrd_do_m1, ddr_lwr_wrd_do_m1};
      ddr_wr_m2 = {ddr_upr_wrd_do_m2, ddr_lwr_wrd_do_m2};
    end else begin
      {ddr_wr,    ddr_dm,    ddr_do}    = ddr_d_p[0];
      {ddr_wr_m1, ddr_dm_m1, ddr_do_m1} = (t_wl == 0) ? ddr_d_in : ddr_d_p[1];
      {ddr_wr_m2, ddr_dm_m2, ddr_do_m2} = (t_wl == 1) ? ddr_d_in : ddr_d_p[2];
    end
  end

  // read/write burst count
  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      wrburst_cnt <= {pBURST_WIDTH{1'b0}};
    end else begin
      if (any_wr) begin
        wrburst_cnt <= burst_len;
      end else if (wr_burst == 1'b1) begin
        wrburst_cnt <= wrburst_cnt - 1;
      end
    end
  end
  
  assign wr_burst = (wrburst_cnt  == {pBURST_WIDTH{1'b0}}) ? 1'b0 : 1'b1;


  // DDR2 On-Die Termination Control
  // -------------------------------
  // timing for ODT going to the DDR2 SDRAM
  assign cmd_ack_next = timing_met & ~precharge_pending & ~activate_pending & command_pending;
  assign rw_cmd_next  = (host_cmd[3:2] == READ_WRITE) ? 1'b1 : 1'b0;
  assign any_wr_next  = (host_cmd[3:1] == ANY_WRITE)  ? 1'b1 : 1'b0;
  
  // next value of ODT
  always @(*) begin
    if (cmd_ack_next == 1'b1 && rw_cmd_next && t_ol == 4'b0001) begin
      // drive ODT for WL=3 (needs to be driven before write command)
      next_odt = (any_wr_next) ? 
                 {hdr_odd_cmd, 1'b1, wrodt[pNO_OF_RANKS-1:0]} :
                 {hdr_odd_cmd, 1'b0, rdodt[pNO_OF_RANKS-1:0]};
    end else if (rw_cmd && t_ol == 4'b0010) begin
      // drive ODT for WL=4 (needs to driven with write command)
      next_odt = {hdr_odd_cmd_ff, any_wr, odt[pNO_OF_RANKS-1:0]};
    end else begin
      // drive ODT for other CAS latencies (driven after write command)
      next_odt = odt_p[3];
    end
  end

  assign next_odt_i = next_odt;
      
  always @(posedge clk or negedge rst_b) begin: dwc_ddr2_odt
    integer i;

    if (rst_b == 1'b0) begin
      next_odt_ff  <= {pNO_OF_RANKS{1'b0}};
      next_odt_ff2 <= {pNO_OF_RANKS{1'b0}};
      odt_start_ff <= {pNO_OF_RANKS{1'b0}};
      odt_end_ff   <= {pNO_OF_RANKS{1'b0}};
      odt_end_ff_reg <= {pNO_OF_RANKS{1'b0}};
      
      for (i=0; i<pNO_OF_RANKS; i=i+1) begin
        odtburst_cnt[i] <= 3'b000;
      end
    end else begin
      // delay start for read by 1 clock
      next_odt_ff <= (next_odt_i[pNO_OF_RANKS] == 1'b0) ?
                     next_odt_i[pNO_OF_RANKS-1:0] :
                     {pNO_OF_RANKS{1'b0}};
      next_odt_ff2 <= next_odt_ff;
      
      odt_start_ff <= odt_start;
      odt_end_ff   <= odt_end;
      odt_end_ff_reg <= odt_end_ff;
      
      for (i=0; i<pNO_OF_RANKS; i=i+1) begin
        if (odt_start_ff[i]) begin
          odtburst_cnt[i] <= burst_len;
        end else if (odt_burst[i] == 1'b1) begin
          odtburst_cnt[i] <= odtburst_cnt[i] - 1;
        end
      end
    end
  end

  generate
    genvar dwc_grnk;
    for (dwc_grnk=0; dwc_grnk<pNO_OF_RANKS; dwc_grnk=dwc_grnk+1) begin:dwc_odt_burst
      assign odt_burst[dwc_grnk] = (odtburst_cnt[dwc_grnk] == {pBURST_WIDTH{1'b0}}) ? 1'b0 : 1'b1;
      assign odt_blast[dwc_grnk] = (odtburst_cnt[dwc_grnk] == {{(pBURST_WIDTH-1){1'b0}}, 1'b1} || 
                                    burst_len == {pBURST_WIDTH{1'b0}}) ? 1'b1 : 1'b0;
    end
  endgenerate
  
  assign odt_start = (next_odt_i[pNO_OF_RANKS] == 1'b1) ? 
                     next_odt_i[pNO_OF_RANKS-1:0] : (hdr_mode) ? next_odt_ff : next_odt_ff2;
  assign odt_end   = ~(odt_start_ff | odt_burst);

  
  // DDR3 on-die termination control
  // -------------------------------
  // timing for ODT going to the DDR3 SDRAM is asserted at the same time as
  // write command and is extended two clock cycles
  assign ddr3_odt_start = {pNO_OF_RANKS{((ddr3_mode|ddr4_mode|lpddr3_mode) & (any_wr || any_rd))}} & 
                                       odt[pNO_OF_RANKS-1:0];
  assign ddr3_odt_len   = (hdr_mode) ? 
                          ((ddr3_bl4) ? 3'b001 : 3'b010) :
                          ((ddr3_bl4) ? 3'b011 : 3'b101);
  
  always @(posedge clk or negedge rst_b) begin: dwc_ddr3_odt
    integer i;
    
    if (rst_b == 1'b0) begin
      ddr3_odt_end   <= {pNO_OF_RANKS{1'b1}};
      
      for (i=0; i<pNO_OF_RANKS; i=i+1) begin
        ddr3_odt_cnt[i] <= 3'b000;
      end
    end else begin
      for (i=0; i<pNO_OF_RANKS; i=i+1) begin
        if (ddr3_odt_start[i]) begin
          ddr3_odt_end[i] <= 1'b0;
          ddr3_odt_cnt[i]  <= ddr3_odt_len;
        end else begin
          if (ddr3_odt_cnt[i] == 3'b001 || 
              ddr3_odt_len    == 3'b001) ddr3_odt_end[i] <= 1'b1;
          if (!ddr3_odt_end[i]) ddr3_odt_cnt[i] <= ddr3_odt_cnt[i] - 1;
        end
      end
    end
  end

  
  //---------------------------------------------------------------------------
  // DDR Control, Address and Data
  //---------------------------------------------------------------------------
  // signals going to the PHYAC and PHYDATX8 cells
  
  // command and control
  always @(posedge clk or negedge rst_b) begin: ddr_command_registers
    integer i;
    
    if (rst_b == 1'b0) begin
      sdr_ck_en   <= {pCK_WIDTH{2'b10}};
      sdr_cke_1     <= {pNO_OF_RANKS{1'b0}};
      sdr_cke_1_reg <= {pNO_OF_RANKS{1'b0}};
      sdr_cs_b    <= {pNO_OF_RANKS{1'b1}};
      sdr_cs_b_1  <= {pNO_OF_RANKS{1'b1}};
      sdr_cid     <= {`DWC_CID_WIDTH{1'b0}};
      sdr_cid_1   <= {`DWC_CID_WIDTH{1'b0}};
      sdr_ras_b   <= 1'b1;
      sdr_ras_b_1 <= 1'b1;
      sdr_cas_b   <= 1'b1;
      sdr_cas_b_1 <= 1'b1;
      sdr_we_b    <= 1'b1;
      sdr_we_b_1  <= 1'b1;
      sdr_odt     <= {pNO_OF_RANKS{1'b0}};
      sdr_odt_1   <= {pNO_OF_RANKS{1'b0}};
      sdr_odt_ff  <= {pNO_OF_RANKS{1'b0}};
      sdr_odt_ff_reg  <= {pNO_OF_RANKS{1'b0}};
      sdr_odt_1_ff    <= {pNO_OF_RANKS{1'b0}};
      low_power   <= 1'b0;
      odt_hdr_odd_cmd <= 1'b0;
      odt_hdr_odd_cmd_ff <= 1'b0;
    end else begin
      sdr_ck_en <= ck_en;
      
      // clock enable: clock disabled only on self-refresh or 
      // power-down entry
      for (i=0; i<pNO_OF_RANKS; i=i+1) begin
        if (init_cke && !first_init_cke) begin
          sdr_cke_1[i]   <= 1'b1;
        end else if (cke_lo || sfrfsh_cmd || pwrdn_cmd || deep_pwrdn_cmd) begin
          // clock disabled only on self-refresh or power-down entry
          // (both are per rank basis)
          if (cs_b[i] == 1'b0 || cs_b_1[i] == 1'b0) sdr_cke_1[i] <= 1'b0;
          low_power <= 1'b1;
        end else if (cke_hi || mode_exit) begin
          // clock enabled again on self-refresh or power-down exit
          // (both exits are by mode exit command to the selected
          //  rank)
          if (cs_b[i] == 1'b0 || cs_b_1[i] == 1'b0) sdr_cke_1[i] <= 1'b1;
          low_power <= 1'b0;
        end else if (!ctl_sdram_init && !low_power) begin
          sdr_cke_1[i] <= 1'b1;
        end
      end

      sdr_cke_1_reg <= sdr_cke_1;
      
      // chip select: chip deselected on per-rank basis
      // for RDIMM, chip select must be asserted for one clock only
      if (`GRM.rdimm) begin
        if (no_cmd || ((mode_exit || pwrdn_cmd) && ddr4_mode)) begin
          sdr_cs_b   <= {pNO_OF_RANKS{1'b1}};
          sdr_cs_b_1 <= {pNO_OF_RANKS{1'b1}};
        end else begin
          sdr_cs_b   <= (hdr_odd_cmd) ? {pNO_OF_RANKS{1'b1}} : cs_b;
          sdr_cs_b_1 <= (hdr_odd_cmd) ? cs_b_1 : {pNO_OF_RANKS{1'b1}};
        end
      end else begin
        if (((cmd == SDRAM_NOP || cmd == SPECIAL_CMD || cmd == NOP) && ddr4_mode) || pwrdn_cmd)
            sdr_cs_b   <= {pNO_OF_RANKS{1'b1}};
        else
          sdr_cs_b   <= cs_b  [pNO_OF_RANKS-1:0];

        if (((cmd_1 == SDRAM_NOP || cmd_1 == SPECIAL_CMD || cmd_1 == NOP) && ddr4_mode) || pwrdn_cmd)
          sdr_cs_b_1 <= {pNO_OF_RANKS{1'b1}};
        else
          sdr_cs_b_1 <= cs_b_1[pNO_OF_RANKS-1:0];
      end

      sdr_cid   <= cid;
      sdr_cid_1 <= cid_1;
      
      // DDR command {RAS#, CAS#, WE#}
      if (ctrl_cmd) begin
        {sdr_ras_b, sdr_cas_b, sdr_we_b}       <= 3'b111; // NOP
        {sdr_ras_b_1, sdr_cas_b_1, sdr_we_b_1} <= 3'b111;
      end else if (lpddrx_mode==1'b1) begin
        {sdr_ras_b, sdr_cas_b, sdr_we_b}       <= $random;
        {sdr_ras_b_1, sdr_cas_b_1, sdr_we_b_1} <= $random;
      end else begin
        if (cmd[3:1] == ACTIVATE_CMD && ddr4_mode)
          {sdr_ras_b, sdr_cas_b, sdr_we_b}     <= addr[16:14];
        else
          {sdr_ras_b, sdr_cas_b, sdr_we_b}     <= cmd[3:1];

        if (cmd_1[3:1] == ACTIVATE_CMD && ddr4_mode)
          {sdr_ras_b_1, sdr_cas_b_1, sdr_we_b_1} <= addr_1[16:14];
        else
          {sdr_ras_b_1, sdr_cas_b_1, sdr_we_b_1} <= cmd_1[3:1];
      end
      
      // on-die termination (ODT)
      if (odt_on) begin
        for (i=0; i<pNO_OF_RANKS; i=i+1) begin
          if (cs_b[i] == 1'b0) begin
            sdr_odt  [i] <= 1'b1;
            sdr_odt_1[i] <= 1'b1;
          end
        end
      end else if (odt_off) begin
        for (i=0; i<pNO_OF_RANKS; i=i+1) begin
          if (cs_b[i] == 1'b0) begin
            sdr_odt  [i] <= 1'b0;
            sdr_odt_1[i] <= 1'b0;
          end
        end
      end else begin
        for (i=0; i<pNO_OF_RANKS; i=i+1) begin
          if (ddr3_mode|ddr4_mode|lpddr3_mode) begin
            if (ddr3_odt_start[i]) begin
              sdr_odt  [i] <= 1'b1;
              sdr_odt_1[i] <= 1'b1;
            end else if (ddr3_odt_end[i]) begin
              sdr_odt  [i] <= 1'b0;
              sdr_odt_1[i] <= 1'b0;
            end
          end else if (ddr2_mode) begin
            if (odt_start[i]) begin
              sdr_odt  [i] <= 1'b1;
              sdr_odt_1[i] <= 1'b1;
            end else if (odt_end[i]) begin
              sdr_odt  [i] <= 1'b0;
              sdr_odt_1[i] <= 1'b0;
            end
          end
        end
      end
      
      sdr_odt_ff <= sdr_odt;
      sdr_odt_ff_reg <= sdr_odt_ff;
      sdr_odt_1_ff   <= sdr_odt_1;

      if ((ddr3_mode|ddr4_mode) && ddr3_odt_start) begin
        odt_hdr_odd_cmd <= hdr_odd_cmd_ff;
      end else if (ddr2_mode && odt_start) begin
        odt_hdr_odd_cmd <= next_odt_i[pNO_OF_RANKS+1];
      end
      odt_hdr_odd_cmd_ff <= odt_hdr_odd_cmd;
      
    end // else: !if(rst_b == 1'b0)
  end // block: ddr_command_registers

`ifdef DWC_DDRPHY_HDR_MODE
  assign sdr_cke = hdr_odd_cmd ? sdr_cke_1_reg : sdr_cke_1;
`else
  assign sdr_cke = sdr_cke_1;
`endif
 
  // Build the address bus for LPDDR2 mode
  always @* begin
    lpddr2_addr   = {pLPDDR_ADDR_WIDTH{1'b0}};
    lpddr2_addr_1 = {pLPDDR_ADDR_WIDTH{1'b0}};
    for (addr_idx = 0; addr_idx < pMCTL_ADDR_WIDTH; addr_idx = addr_idx + 1) begin
      lpddr2_addr  [addr_idx] = addr  [addr_idx];
      lpddr2_addr_1[addr_idx] = addr_1[addr_idx];
    end
    for (addr_idx = pMCTL_ADDR_WIDTH; addr_idx < pLPDDR_ADDR_WIDTH; addr_idx = addr_idx + 1) begin
      lpddr2_addr  [addr_idx] = caddr_ff  [addr_idx];
      lpddr2_addr_1[addr_idx] = caddr_ff_1[addr_idx];
    end
  end
 
//DDRG2MPHY: For LPDDR3

  // Build the address bus for LPDDR3 mode
  always @* begin
    lpddr3_addr   = {pLPDDR_ADDR_WIDTH{1'b0}};
    lpddr3_addr_1 = {pLPDDR_ADDR_WIDTH{1'b0}};
    for (addr_idx = 0; addr_idx < pMCTL_ADDR_WIDTH; addr_idx = addr_idx + 1) begin
      lpddr3_addr  [addr_idx] = addr  [addr_idx];
      lpddr3_addr_1[addr_idx] = addr_1[addr_idx];
    end
    for (addr_idx = pMCTL_ADDR_WIDTH; addr_idx < pLPDDR_ADDR_WIDTH; addr_idx = addr_idx + 1) begin
      lpddr3_addr  [addr_idx] = caddr_ff  [addr_idx];
      lpddr3_addr_1[addr_idx] = caddr_ff_1[addr_idx];
    end
  end
 
  // address (bank, row and column address)
  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      sdr_ba     <= {pMCTL_BANK_WIDTH{1'b0}};
      sdr_ba_1   <= {pMCTL_BANK_WIDTH{1'b0}};
      sdr_a      <= {pMCTL_XADDR_WIDTH{1'b0}};
      sdr_a_1    <= {pMCTL_XADDR_WIDTH{1'b0}};
      sdr_act_b   <= 1'b1;
      sdr_act_b_1 <= 1'b1;
      sdr_bg     <= {pMCTL_BG_WIDTH{1'b0}};
      sdr_bg_1   <= {pMCTL_BG_WIDTH{1'b0}};
    end else begin
       sdr_act_b   <= 1'b1;
       sdr_act_b_1 <= 1'b1;
       if (!no_cmd) begin
        if (rdimm_wr) begin
          // RDIMM register write
          //  - address of the RDIMM register is driven on {BA[  2], A[2:0]}
          //  -    data of the RDIMM register is driven on {BA[1:0], A[4:3]}
          sdr_ba   <= {addr[7], addr[11:10]};
          sdr_ba_1 <= {addr[7], addr[11:10]};
        end else begin
          sdr_ba   <= bank;
          sdr_ba_1 <= bank_1;
          sdr_bg   <= bg;
          sdr_bg_1 <= bg_1;        
        end
        
        if (rdimm_wr) begin
          // RDIMM register write
          //  - address of the RDIMM register is driven on {BA[  2], A[2:0]}
          //  -    data of the RDIMM register is driven on {BA[1:0], A[4:3]}
          sdr_a  [2:0] <= addr[6:4];
          sdr_a_1[2:0] <= addr[6:4];
          sdr_a  [4:3] <= addr[9:8];
          sdr_a_1[4:3] <= addr[9:8];
          sdr_a  [pADDR_WIDTH-1:5] <= {(pADDR_WIDTH-5){1'b0}};
          sdr_a_1[pADDR_WIDTH-1:5] <= {(pADDR_WIDTH-5){1'b0}};
        end 
        else begin
          if (lpddrx_mode==1'b1) begin
            // pack all bank, address, and flags onto the command/address bus
            // ***TBD: add all commands
`ifdef LPDDR2
            case (cmd)
              SDRAM_NOP    : sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd[1], cmd[2], cmd[3]};
              LOAD_MODE    : sdr_a <= {lpddr2_addr[15:0], 1'b0, cmd[1], cmd[2], cmd[3]};
              READ_MODE    : sdr_a <= {lpddr2_addr[15:0], 1'b1,   1'b0,   1'b0,   1'b0};
              REFRESH,
              SELF_REFRESH : sdr_a <= {lpddr2_addr[15:0], 1'b1, cmd[1], cmd[2], cmd[3]}; // Here we are doing refresh All
              ACTIVATE     : sdr_a <= {lpddr2_addr[14:13], lpddr2_addr[7:0], bank[2:0], lpddr2_addr[12:8], cmd[2], cmd[3]};
              WRITE,
                WRITE_PRECHG,
                READ,
                READ_PRECHG  : sdr_a <= {lpddr2_addr[11:3], cmd[0], bank[2:0], lpddr2_addr[2:1], 2'b00, cmd[1], cmd[2], cmd[3]};
              PRECHARGE,
                PRECHARGE_ALL: sdr_a <= {{10{1'b0}}, bank[2:0], 2'b00, cmd[0], 4'b1011};
              TERMINATE    : sdr_a <= {{16{1'b0}}, 1'b0, cmd[1], cmd[2], cmd[3]};
              SPECIAL_CMD    : begin 
                if (addr[3:0] == `DEEP_POWER_DOWN) begin 
                  sdr_a <= {{16{1'b0}}, 1'b0, 3'b011};
                end
              end
              // SPN_DEBUG->fixing LPDDR2 SPECIAL_CMD bug
              // default      : sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd[1], cmd[2], cmd[3]}; // NOP
              default      : sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, {3{1'b1}}}; // NOP
            endcase // case (cmd)

            case (cmd_1)
              SDRAM_NOP    : sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd_1[1], cmd_1[2], cmd_1[3]};
              LOAD_MODE    : sdr_a_1 <= {lpddr2_addr_1[15:0], 1'b0, cmd_1[1], cmd_1[2], cmd_1[3]};
              READ_MODE    : sdr_a_1 <= {lpddr2_addr_1[15:0], 1'b1,     1'b0,     1'b0,     1'b0};
              REFRESH,
              SELF_REFRESH : sdr_a_1 <= {lpddr2_addr_1[15:0], 1'b0, cmd_1[1], cmd_1[2], cmd_1[3]};
              ACTIVATE     : sdr_a_1 <= {lpddr2_addr_1[14:13], lpddr2_addr_1[7:0], bank_1[2:0], lpddr2_addr_1[12:8], cmd_1[2], cmd_1[3]};
              WRITE,
                WRITE_PRECHG,
                READ,
                READ_PRECHG  : sdr_a_1 <= {lpddr2_addr_1[11:3], cmd_1[0], bank_1[2:0], lpddr2_addr_1[2:1], 2'b00, cmd_1[1], cmd_1[2], cmd_1[3]};
              PRECHARGE,
                PRECHARGE_ALL: sdr_a_1 <= {{10{1'b0}}, bank_1[2:0], 2'b00, cmd_1[0], 4'b1011};
              TERMINATE    : sdr_a_1 <= {{16{1'b0}}, 1'b0, cmd_1[1], cmd_1[2], cmd_1[3]};
              SPECIAL_CMD    : begin 
                if (addr_1[3:0] == `DEEP_POWER_DOWN) begin 
                  sdr_a_1 <= {{16{1'b0}}, 1'b0, 3'b011};
                end
              end
              // SPN_DEBUG->fixing LPDDR2 SPECIAL_CMD bug
              // default      : sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd_1[1], cmd_1[2], cmd_1[3]}; // NOP
              default      : sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, {3{1'b1}}}; // NOP
            endcase // case (cmd_1)
`else
  `ifdef LPDDR3
            case (cmd)
              SDRAM_NOP    : sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd[1], cmd[2], cmd[3]};
              LOAD_MODE    : sdr_a <= {lpddr3_addr[15:0], 1'b0, cmd[1], cmd[2], cmd[3]};
              READ_MODE    : sdr_a <= {lpddr3_addr[15:0], 1'b1,   1'b0,   1'b0,   1'b0};
              REFRESH,
              SELF_REFRESH : sdr_a <= {lpddr3_addr[15:0], 1'b1, cmd[1], cmd[2], cmd[3]}; // Here we are doing refresh All
              ACTIVATE     : sdr_a <= {lpddr3_addr[14:13], lpddr3_addr[7:0], bank[2:0], lpddr3_addr[12:8], cmd[2], cmd[3]};
              WRITE,
                WRITE_PRECHG,
                READ,
                READ_PRECHG  : sdr_a <= {lpddr3_addr[11:3], cmd[0], bank[2:0], lpddr3_addr[2:1], 2'b00, cmd[1], cmd[2], cmd[3]};
              PRECHARGE,
                PRECHARGE_ALL: sdr_a <= {{10{1'b0}}, bank[2:0], 2'b00, cmd[0], 4'b1011};
              TERMINATE    : sdr_a <= {{16{1'b0}}, 1'b0, cmd[1], cmd[2], cmd[3]};
              SPECIAL_CMD    : begin 
                if (addr[3:0] == `DEEP_POWER_DOWN) begin 
                  sdr_a <= {{16{1'b0}}, 1'b0, 3'b011};
                end
              end
              // SPN_DEBUG->fixing LPDDR2 SPECIAL_CMD bug
              // default      : sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd[1], cmd[2], cmd[3]}; // NOP
              default      : sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, {3{1'b1}}}; // NOP
            endcase // case (cmd)

            case (cmd_1)
              SDRAM_NOP    : sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd_1[1], cmd_1[2], cmd_1[3]};
              LOAD_MODE    : sdr_a_1 <= {lpddr3_addr_1[15:0], 1'b0, cmd_1[1], cmd_1[2], cmd_1[3]};
              READ_MODE    : sdr_a_1 <= {lpddr2_addr_1[15:0], 1'b1,     1'b0,     1'b0,     1'b0};
              REFRESH,
              SELF_REFRESH : sdr_a_1 <= {lpddr3_addr_1[15:0], 1'b0, cmd_1[1], cmd_1[2], cmd_1[3]};
              ACTIVATE     : sdr_a_1 <= {lpddr3_addr_1[14:13], lpddr3_addr_1[7:0], bank_1[2:0], lpddr3_addr_1[12:8], cmd_1[2], cmd_1[3]};
              WRITE,
                WRITE_PRECHG,
                READ,
                READ_PRECHG  : sdr_a_1 <= {lpddr3_addr_1[11:3], cmd_1[0], bank_1[2:0], lpddr3_addr_1[2:1], 2'b00, cmd_1[1], cmd_1[2], cmd_1[3]};
              PRECHARGE,
                PRECHARGE_ALL: sdr_a_1 <= {{10{1'b0}}, bank_1[2:0], 2'b00, cmd_1[0], 4'b1011};
              TERMINATE    : sdr_a_1 <= {{16{1'b0}}, 1'b0, cmd_1[1], cmd_1[2], cmd_1[3]};
              SPECIAL_CMD    : begin 
                if (addr_1[3:0] == `DEEP_POWER_DOWN) begin 
                  sdr_a_1 <= {{16{1'b0}}, 1'b0, 3'b011};
                end
              end
              // SPN_DEBUG->fixing LPDDR2 SPECIAL_CMD bug
              // SPN_DEBUG->fixing LPDDR2 SPECIAL_CMD bug
              // default      : sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, cmd_1[1], cmd_1[2], cmd_1[3]}; // NOP
              default      : sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, {3{1'b1}}}; // NOP
            endcase // case (cmd_1)
            
  `endif
`endif // !`ifdef LPDDR2
          end // if (lpddrx_mode==1'b1)
          else begin

            if (ddr4_mode) begin
              // Only during activate when row address is presented in address, the other times
              // a[16]=ras_n, a[15]=cas_n, a[14]=we_n
              case (cmd)
                ACTIVATE: sdr_act_b   <= 1'b0;
                default:  sdr_act_b   <= 1'b1;
              endcase // case(cmd)
              
              case (cmd_1)
                ACTIVATE: sdr_act_b_1 <= 1'b0;
                default:  sdr_act_b_1 <= 1'b1;
              endcase // case(cmd)
            end else begin
              if (ctrl_cmd) begin
                sdr_act_b   <= 1'b1; // NOP
                sdr_act_b_1 <= 1'b1;
              end else if (lpddrx_mode==1'b1) begin
                sdr_act_b   <= $random;
                sdr_act_b_1 <= $random;
              end else begin
                //sdr_act_b   <= cmd  [3];
                //sdr_act_b_1 <= cmd_1[3];
                sdr_act_b   <= 1'b1;
                sdr_act_b_1 <= 1'b1;
              end
              
            end
            // a[16:14]
            if (ddr4_mode) begin
              // Only during activate when row address is presented in address, the other times
              // a[16]=ras_n, a[15]=cas_n, a[14]=we_n
              sdr_a  [16:14] <= $random;
              sdr_a_1[16:14] <= $random;
              //sdr_a  [16:14] <= addr  [16:14];
              //sdr_a_1[16:14] <= addr_1[16:14];
            end
            else begin
              if (ldmr_cmd) begin
                // load mode register
                sdr_a  [16:14] <= addr  [16:14];
                sdr_a_1[16:14] <= addr_1[16:14];
              end
              else begin
                if (rw_cmd_blfxd || any_pre || any_zqcal) begin
                  sdr_a  [16:14] <= addr  [15:13];
                  sdr_a_1[16:14] <= addr_1[15:13];
                end else if (rw_cmd_blotf) begin
                  sdr_a  [16:14] <= addr  [14:12];
                  sdr_a_1[16:14] <= addr_1[14:12];
                end else begin
                  sdr_a  [16:14] <= addr  [16:14];
                  sdr_a_1[16:14] <= addr_1[16:14];
                end                  
              end
              //sdr_a  [16] <= cmd  [1];
              //sdr_a_1[16] <= cmd_1[1];
            end
              
            // a[17], a[13:0]
            if (ldmr_cmd) begin
              // load mode register
              sdr_a  [13:0] <= addr  [13:0];
              sdr_a_1[13:0] <= addr_1[13:0];
              sdr_a  [17]   <= addr  [17];
              sdr_a_1[17]   <= addr_1[17];
            end
            else begin
              sdr_a  [9:0] <= addr  [9:0];
              sdr_a_1[9:0] <= addr_1[9:0];
              
              if (rw_cmd_blfxd || any_pre || any_zqcal || any_pre_1 || any_zqcal_1) begin
                sdr_a  [10]    <= ((cmd  [3:2] == READ_WRITE) || any_pre   || any_zqcal  )? cmd  [0]: 1'b0; // auto-precharge/precharge-all bit
                sdr_a_1[10]    <= ((cmd_1[3:2] == READ_WRITE) || any_pre_1 || any_zqcal_1)? cmd_1[0]: 1'b0; // auto-precharge/precharge-all bit
                sdr_a  [13:11] <= addr  [12:10];
                sdr_a_1[13:11] <= addr_1[12:10];
                sdr_a  [17]    <= addr  [16];
                sdr_a_1[17]    <= addr_1[16];
              end else if (rw_cmd_blotf) begin
                sdr_a  [10]    <= ((cmd  [3:2] == READ_WRITE) || any_pre   || any_zqcal  )? cmd  [0]: 1'b0; // auto-precharge/precharge-all bit
                sdr_a_1[10]    <= ((cmd_1[3:2] == READ_WRITE) || any_pre_1 || any_zqcal_1)? cmd_1[0]: 1'b0; // auto-precharge/precharge-all bit
                sdr_a  [11]    <= addr  [10];
                sdr_a_1[11]    <= addr_1[10];
                sdr_a  [12]    <= ~ddr3_bl4;
                sdr_a_1[12]    <= ~ddr3_bl4;
                sdr_a  [13]    <= addr  [11];
                sdr_a_1[13]    <= addr_1[11];
                sdr_a  [17]    <= addr  [15];
                sdr_a_1[17]    <= addr_1[15];
              end else begin
                sdr_a  [13:10] <= addr  [13:10];
                sdr_a_1[13:10] <= addr_1[13:10];
                sdr_a  [17]    <= addr  [17];
                sdr_a_1[17]    <= addr_1[17];
              end                  
            end

            //if (!ddr4_mode) begin
            //  sdr_a  [17] <= cmd  [2];
            //  sdr_a_1[17] <= cmd_1[2];
            //end
            
          end // else: !if(lpddrx_mode==1'b1)
        end // else: !if(rdimm_wr)
      end else begin // if (!no_cmd)
        if (hdr_mode) begin
          // no command: drive the previous values driven on these buses
          if (lpddrx_mode==1'b1) begin
            sdr_a   <= {{7{1'b0}}, 3'b111, {7{1'b0}}, 3'b111}; // LPDDR2/3 NOP
            sdr_a_1 <= {{7{1'b0}}, 3'b111, {7{1'b0}}, 3'b111}; // LPDDR2/3 NOP
          end else begin
            sdr_ba <= sdr_ba_1;
            sdr_bg <= sdr_bg_1;
            sdr_a  <= sdr_a_1;
            if (ddr4_mode) begin
              sdr_a  [13:0]  <= addr  [13:0];
              sdr_a_1[13:0]  <= addr_1[13:0];
              sdr_a  [16:14] <= $random;
              sdr_a_1[16:14] <= $random;
              //sdr_a  [16:14] <= addr  [16:14];
              //sdr_a_1[16:14] <= addr_1[16:14];
              sdr_a[17]      <= addr[17];
              sdr_a_1[17]    <= addr_1[17];
            end
            else begin
              // ddr3 
              sdr_a  [15:0]  <= addr  [15:0];
              sdr_a_1[15:0]  <= addr_1[15:0];
              sdr_act_b      <= 1'b1;  // ras_n 
              sdr_act_b_1    <= 1'b1;
              sdr_a  [17:16] <= addr  [17:16];
              sdr_a_1[17:16] <= addr_1[17:16];
             end
          end
        end else begin
          if (lpddrx_mode==1'b1) begin 
            sdr_a <= {{7{1'b0}}, 3'b111, {7{1'b0}}, 3'b111}; // LPDDR2/3 NOP
          end 
          else begin
            if (ddr_2t) begin
              // set bank/address to zero in 2T so that OR logic can work properly
              sdr_bg <= {pMCTL_BG_WIDTH{1'b0}};
              sdr_ba <= {pMCTL_BANK_WIDTH{1'b0}};
              sdr_a  <= {pMCTL_XADDR_WIDTH{1'b0}};
            end
            else begin
              if (ddr4_mode) begin
                sdr_a[13:0]    <= addr[13:0];
                sdr_a[16:14]   <= $random;
                //sdr_a[16:14]   <= addr[16:14];
                sdr_a[17]      <= addr[17];
              end
              else begin
                // ddr3
                sdr_act_b      <= 1'b1;  // ras_n 
                sdr_a[15:0]    <= addr[15:0];
                sdr_a[17:16]   <= addr[17:16];
              end
            end
          end
        end
      end // else: !if(!no_cmd)
    end // else: !if(rst_b == 1'b0)
  end // always @ (posedge clk or negedge rst_b)

  
  assign byte_en = {pNUM_LANES{1'b1}};    // do not disable byte lane here,
                                          // let PUB and DFI handle the byte_en
  
  assign byte_wr_p6  = {pNUM_LANES{ddr_wr_m2}} & 
         byte_en[pNUM_LANES-1:0];
  assign byte_wr_p7  = {pNUM_LANES{ddr_wr_m1}} & 
         byte_en[pNUM_LANES-1:0];
  assign byte_wr_p8  = {pNUM_LANES{ddr_wr}} & 
         byte_en[pNUM_LANES-1:0];
  assign byte_wr_p9  = {pNUM_LANES{ddr_wr_ff}} & 
         byte_en[pNUM_LANES-1:0];
  assign byte_wr_p10 = {pNUM_LANES{ddr_wr_ff_2}} & 
         byte_en[pNUM_LANES-1:0];

  assign {t_ol_odd, t_rl_odd, t_wl_odd} = t_orwl_odd;

  
  //---------------------------------------------------------------------------
  // SDRAM Read Control Path
  //---------------------------------------------------------------------------
  // read path control and pipelines
  assign ddr_rd_cmd  = (any_rd || (rd_burst && !ddr3_bl4_nop)) ? 1'b1 : 1'b0;
  assign rdtag       = ddr_rd_cmd;

  // pipeline for read latency, i.e. from when the read command is issued
  // to the SDRAM to when data and strobes are expected on DQ/DQs buses
  // NOTE: The extra pipeline stage in the read command path due to DDRO 
  //       register is not compensated for in the read tag pipeline because 
  //       both the read tag and the DQS reference signal are required one 
  //       clock before the read data and data strobes are valid.
  always @(posedge clk or negedge rst_b) begin: read_pipeline
    integer i;
    
    if (rst_b == 1'b0) begin
      for (i=(pRL_CPIPE_DEPTH-1); i>=0; i=i-1) begin
        rdtag_p[i] <= {pRL_CPIPE_WIDTH{1'b0}};
      end
      
      rd_cmd_ff  <= 1'b0;
      byte_rd_ff <= {pNUM_LANES{1'b0}};
    end else begin
      // SDRAM latency (AL + CL): last stage is after board-level latency
      rdtag_p[pRL_CPIPE_DEPTH-1] <= (t_rl == (pRL_CPIPE_DEPTH-1)) ? 
                                    rdtag : {pRL_CPIPE_WIDTH{1'b0}};
      for (i=(pRL_CPIPE_DEPTH-2); i>=0; i=i-1) begin
        rdtag_p[i] <= (t_rl == i) ? rdtag : rdtag_p[i+1];
      end
    
      rd_cmd_ff  <= rd_cmd;
      byte_rd_ff <= byte_rd_pn;
    end // else: !if(rst_b == 1'b0)
  end // block: read_pipeline
  
  // input to system latency compensation read pipeline
  assign rd_cmd  = rdtag_p[0];

  assign byte_rd_pn = (hdr_mode && t_rl_eq_3) ? 
                      {pNUM_LANES{rd_cmd}} : 
                      {pNUM_LANES{rd_cmd_ff}};
  assign byte_rd_m1 = (t_rl == 0) ? 
                      {pNUM_LANES{rdtag}} : 
                      {pNUM_LANES{rdtag_p[0]}};
  assign byte_rd_m2 = (t_rl == 1) ? 
                      {pNUM_LANES{rdtag}} : 
                      {pNUM_LANES{rdtag_p[1]}};
  assign byte_rd_m3 = (t_rl == 1 || t_rl == 2) ? 
                      {pNUM_LANES{rdtag}} : 
                      {pNUM_LANES{rdtag_p[2]}};
  
  // read burst count
  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      rdburst_cnt <= {pBURST_WIDTH{1'b0}};
      lpddr2_mrr     <= 1'b0;
      lpddr2_mrr_nop <= 1'b0;
    end else begin
      if (bst_cmd) begin
        rdburst_cnt <= {pBURST_WIDTH{1'b0}};
      end else if (any_rd) begin
        rdburst_cnt <= burst_len;
      end else if (rd_burst == 1'b1) begin
        rdburst_cnt <= rdburst_cnt - 1;
      end

      // assert LPDDR2 MRR flag for one clock after the MRR command to
      // assert the rm_cmd flag for only two clocks since MRR is always
      // fixed to BL2
      if ((lpddrx_mode==1'b1) && cmd_ff == READ_MODE) begin
        lpddr2_mrr <= 1'b1;
      end else begin
        lpddr2_mrr <= 1'b0;
      end

      if (lpddr2_mrr && burst_len != {{(pBURST_WIDTH-1){1'b0}}, 1'b1} || (hdr_mode && (lpddrx_mode==1'b1) && cmd_ff == READ_MODE)) begin
        lpddr2_mrr_nop <= 1'b1;
      end else if (rdburst_cnt == {{(pBURST_WIDTH-1){1'b0}}, 1'b1} || any_rd) begin
        lpddr2_mrr_nop <= 1'b0;
      end
    end
  end

//DDRG2MPHY: For LPDDR3

  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      rdburst_cnt <= {pBURST_WIDTH{1'b0}};
      lpddr3_mrr     <= 1'b0;
      lpddr3_mrr_nop <= 1'b0;
    end else begin
      if (bst_cmd) begin
        rdburst_cnt <= {pBURST_WIDTH{1'b0}};
      end else if (any_rd) begin
        rdburst_cnt <= burst_len;
      end else if (rd_burst == 1'b1) begin
        rdburst_cnt <= rdburst_cnt - 1;
      end

      // assert LPDDR3 MRR flag for one clock after the MRR command to
      // assert the rm_cmd flag for only two clocks since MRR is always
      // fixed to BL2
      if ((lpddrx_mode==1'b1) && cmd_ff == READ_MODE) begin
        lpddr3_mrr <= 1'b1;
      end else begin
        lpddr3_mrr <= 1'b0;
      end

      if (lpddr3_mrr && burst_len != {{(pBURST_WIDTH-1){1'b0}}, 1'b1} || (hdr_mode && (lpddrx_mode==1'b1) && cmd_ff == READ_MODE)) begin
        lpddr3_mrr_nop <= 1'b1;
      end else if (rdburst_cnt == {{(pBURST_WIDTH-1){1'b0}}, 1'b1} || any_rd) begin
        lpddr3_mrr_nop <= 1'b0;
      end
    end
  end



  assign rd_burst = (rdburst_cnt == {pBURST_WIDTH{1'b0}}) ? 1'b0 : 1'b1;

  
  // read data output
  // ----------------
  // read data output to host ports
  assign host_qvld = |dfi_rddata_valid;
  assign host_q    = dfi_rddata;



  //---------------------------------------------------------------------------
  // DFI Bus Functional Model
  //---------------------------------------------------------------------------
  // DFI BFM drives the controller pipeline output to create DFI compliant
  // transactions
  dfi_bfm 
    #(
      .pNO_OF_BYTES           ( pNO_OF_BYTES ),
      .pNO_OF_RANKS           ( pNO_OF_RANKS ),
      .pCK_WIDTH              ( pCK_WIDTH    ),
      .pBANK_WIDTH            ( pBANK_WIDTH  ),
      .pBG_WIDTH              ( pBG_WIDTH  ),
      .pADDR_WIDTH            ( pADDR_WIDTH  ),
      .pLPDDRX_EN             ( pLPDDRX_EN   ), // mike
      .pCHANNEL_NO            ( pCHANNEL_NO  )
      )
  dfi_bfm
    (
     // interface to global signals
     .rst_b                   (rst_b),
     .clk                     (clk),
     .hdr_mode                (hdr_mode),
     .hdr_odd_cmd             (hdr_odd_cmd_d1),
     .lpddrx_mode             (lpddrx_mode),
     .ck_inv                  (ck_inv),
     .ddr_2t                  (ddr_2t),
     .rddata_pending          (rddata_pending),
     
     // CTL Control Interface
     .ctl_reset_n             (rst_b),
`ifdef DWC_DDRPHY_HDR_MODE
     .ctl_cke                 ({sdr_cke_1, sdr_cke}),
     .ctl_odt                 ({sdr_odt_1_mxd, sdr_odt_mxd}),
     .ctl_cs_n                ({sdr_cs_b_1,    sdr_cs_b}),
     .ctl_cid                 ({sdr_cid_1,     sdr_cid}),
     .ctl_ras_n               ({sdr_ras_b_1,   sdr_ras_b}),
     .ctl_cas_n               ({sdr_cas_b_1,   sdr_cas_b}),
     .ctl_we_n                ({sdr_we_b_1,    sdr_we_b}),
     .ctl_bank                ({sdr_ba_1[pBANK_WIDTH-1:0],      
                                sdr_ba  [pBANK_WIDTH-1:0]}),
     .ctl_address             ({sdr_a_1 [pMCTL_XADDR_WIDTH-1:0],
                                sdr_a  [ pMCTL_XADDR_WIDTH-1:0]}),
     .ctl_act_n               ({sdr_act_b_1,   sdr_act_b}),
     .ctl_bg                  ({sdr_bg_1[pBG_WIDTH-1:0],      
                                sdr_bg  [pBG_WIDTH-1:0]}),
`else
     .ctl_cke                 (sdr_cke),
     .ctl_odt                 (sdr_odt),
     .ctl_cs_n                (sdr_cs_b),
     .ctl_cid                 (sdr_cid),
     .ctl_ras_n               (sdr_ras_b),
     .ctl_cas_n               (sdr_cas_b),
     .ctl_we_n                (sdr_we_b),
     .ctl_bank                (sdr_ba[pBANK_WIDTH-1:0]),
     .ctl_act_n               (sdr_act_b),
     .ctl_bg                  (sdr_bg[pBG_WIDTH-1:0]),
     .ctl_address             (sdr_a [pMCTL_XADDR_WIDTH-1:0]),
`endif
     .ctl_odt_ff              (sdr_odt_ff),
   
     // CTL Write Data Interface
     .ctl_wrdata_en           (byte_wr_mxd),
     .ctl_wrdata              (ddr_do_mxd),
     .ctl_wrdata_mask         (ddr_dm_mxd),
   
     // CTL Read Data Interface
     .ctl_rddata_en           (byte_rd_mxd),
     .ctl_rddata_valid        (),
     .ctl_rddata              (),
   
     // CTL Status Interface
     .ctl_init_complete       (),

     // DFI Control Interface
     .dfi_reset_n             (dfi_reset_n),
     .dfi_cke                 (dfi_cke),
     .dfi_odt                 (dfi_odt),
     .dfi_cs_n                (dfi_cs_n),
     .dfi_cid                 (dfi_cid),
     .dfi_ras_n               (dfi_ras_n),
     .dfi_cas_n               (dfi_cas_n),
     .dfi_we_n                (dfi_we_n),
     .dfi_bank                (dfi_bank_i),
     .dfi_address             (dfi_address),
     .dfi_act_n               (dfi_act_n),
     .dfi_bg                  (dfi_bg),
     // DFI Write Data Interface
     .dfi_wrdata_en           (dfi_wrdata_en),
     .dfi_wrdata              (dfi_wrdata),
     .dfi_wrdata_mask         (dfi_wrdata_mask),
   
     // DFI Read Data Interface
     .dfi_rddata_en           (dfi_rddata_en),
     .dfi_rddata_valid        (dfi_rddata_valid),
     .dfi_rddata              (dfi_rddata ),
   
     // DFI Update Interface
     .dfi_ctrlupd_req         (dfi_ctrlupd_req),
     .dfi_ctrlupd_ack         (dfi_ctrlupd_ack),
     .dfi_phyupd_req          (dfi_phyupd_req),
     .dfi_phyupd_ack          (dfi_phyupd_ack),
     .dfi_phyupd_type         (dfi_phyupd_type),
     .bdrift_err_rcv          (bdrift_err_rcv),
   
     // DFI Status Interface
     .dfi_init_start          (dfi_init_start),
     .dfi_data_byte_disable   (dfi_data_byte_disable),
     .dfi_dram_clk_disable    (dfi_dram_clk_disable),
     .dfi_init_complete       (dfi_init_complete),
     .dfi_parity_in           (dfi_parity_in),
     .dfi_alert_n             (dfi_alert_n),

     // DFI Training Interface
     .dfi_phylvl_req_cs_n     (dfi_phylvl_req_cs_n),
     .dfi_phylvl_ack_cs_n     (dfi_phylvl_ack_cs_n),

     .dfi_rdlvl_mode          (dfi_rdlvl_mode),
     .dfi_rdlvl_gate_mode     (dfi_rdlvl_gate_mode),
     .dfi_wrlvl_mode          (dfi_wrlvl_mode),

     .dfi_lp_data_req         (dfi_lp_data_req),
     .dfi_lp_ctrl_req         (dfi_lp_ctrl_req),
     .dfi_lp_wakeup           (dfi_lp_wakeup),
     .dfi_lp_ack              (dfi_lp_ack)
     );

  // flag to indicate that the DFI update interface is idle
  assign dfi_upd_busy = |({dfi_ctrlupd_req, dfi_ctrlupd_ack, dfi_phyupd_req, dfi_phyupd_ack});

  // for DDR4, the valid bank width is 2 bits - therefore convert the bank bits to be driven on these bits
  // and drive the upper bits for each phase to be zero
`ifdef DDR4
  generate
    genvar wrd_no;
    genvar bnk_bit;
    for (wrd_no=0; wrd_no<pCLK_NX; wrd_no=wrd_no+1) begin: g_bank_wrd
      for (bnk_bit=0; bnk_bit<2; bnk_bit=bnk_bit+1) begin: g_bank_bitl
        assign dfi_bank[wrd_no*pBANK_WIDTH + bnk_bit] = dfi_bank_i[wrd_no*pBANK_WIDTH + bnk_bit];
      end

      // zero the upper unused bits
      for (bnk_bit=2; bnk_bit<pBANK_WIDTH; bnk_bit=bnk_bit+1) begin: g_bank_bitu
        assign dfi_bank[wrd_no*pBANK_WIDTH + bnk_bit] = 1'b0;
      end
    end
  endgenerate  
`else
    assign dfi_bank = dfi_bank_i;
`endif

  event    e_bl4, e_bl4_byte_74_F, e_bl4_byte_not_74_F;
  event    e_bl8_CMD_ODD,  e_bl8_byte_FF,     e_bl8_byte_not_FF;
  event    e_bl8_CMD_EVEN, e_bl8_CMD_EVEN_FF, e_bl8_CMD_EVEN_non_FF;
  
  always @(posedge clk) begin
    if (rst_b == 1'b0) begin
      rd_odd_even_ptr     <= 0;
      rd_odd_even_ptr_reg <= 0;
      wr_odd_even_ptr     <= 0;
      wr_odd_even_ptr_d0  <= 0;
      wr_odd_even_ptr_d1  <= 0;
      wr_odd_even_ptr_d2  <= 0;
      inc_cnt             <= 0;
      inc_cnt_ff          <= 0;
      last_cmd_odd        <= 0;
    end
    else begin
      inc_cnt_ff          <= inc_cnt;
      rd_odd_even_ptr_reg <= rd_odd_even_ptr;
      
      // For odd mode, try to increment the rd ptr eariler
      if (inc_cnt === 1'b1) begin
        // store last_cmd_odd for previous rd ptr
        if (hdr_odd_cmd_array[rd_odd_even_ptr])
          last_cmd_odd = 1'b1;
        else
          last_cmd_odd = 1'b0;
        
        // clear location with x before incrementing ptr
        hdr_odd_cmd_array[rd_odd_even_ptr] = 1'bx;
        hdr_odd_cmd_valid[rd_odd_even_ptr] = 1'b0;
        hdr_odd_cmd_bl4  [rd_odd_even_ptr] = 1'bx;
        rd_odd_even_ptr                    <= rd_odd_even_ptr + 1;
      end


      // For bl4, trigger inc_cnt everytime
      if (hdr_odd_cmd_bl4[rd_odd_even_ptr] === 1'b1 && hdr_odd_cmd_valid[rd_odd_even_ptr] === 1'b1) begin
        -> e_bl4;
        
        if (&byte_wr_mxd[pNUM_LANES +:pNUM_LANES]== 1'b1 || &byte_rd_mxd[pNUM_LANES +:pNUM_LANES]== 1'b1) begin
          inc_cnt <= 1'b1;
          -> e_bl4_byte_74_F;
        end  
        else begin
          inc_cnt <= 1'b0;
          -> e_bl4_byte_not_74_F;
        end  
      end
      else begin // bl8
        // For odd cnt, trigger inc_cnt everytime on 8'hFF
        if (hdr_odd_cmd_array[rd_odd_even_ptr] === 1'b1 && hdr_odd_cmd_valid[rd_odd_even_ptr] === 1'b1) begin
          -> e_bl8_CMD_ODD;

          if (byte_wr_mxd == {(pNUM_LANES*pCLK_NX){1'b1}} || byte_rd_mxd == {(pNUM_LANES*pCLK_NX){1'b1}}) begin
            inc_cnt <= 1'b1;
            -> e_bl8_byte_FF;
          end
          else begin
            inc_cnt <= 1'b0;
            -> e_bl8_byte_not_FF;
          end
        end
        else begin
          
          // for even count, trigger inc_cnt every other time
          if (hdr_odd_cmd_array[rd_odd_even_ptr] === 1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr] === 1'b1) begin
            -> e_bl8_CMD_EVEN;
            
            if (byte_wr_mxd == {(pNUM_LANES*pCLK_NX){1'b1}} || byte_rd_mxd == {(pNUM_LANES*pCLK_NX){1'b1}}) begin
              inc_cnt <= ~inc_cnt;
              -> e_bl8_CMD_EVEN_FF;
            end
            else begin
              inc_cnt <= 1'b0;
              -> e_bl8_CMD_EVEN_non_FF;
            end
          end
          else begin
            inc_cnt <= 1'b0; 
          end
        end
        
      end // else: !if(hdr_odd_cmd_bl4[rd_odd_even_ptr] == 1'b1)
    end // else: !if(rst_b == 1'b0)
  end // always @ (posedge clk)
  
  
  // In external loopback mode, DFI wrdata_en need to be driven one
  // clock earlier than in mission mode so that the PUB can correctly
  // use this signal as the rddata_en to generate gating
  always @(*) begin
    if (hdr_mode) begin
      
`ifdef MSD_RND_HDR_ODD_CMD
      // heoc mode use hdr_odd_cmd_array to store the odd/even mode information as well as when the cmd is valid to pipe the byte wr or byte rd into their corresponding mxd
      byte_wr_mxd = (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p9,  byte_wr_p10} :  //  ODD wl + EVEN cmd
                    (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p9,  ((inc_cnt_ff && last_cmd_odd ===1'b0)? 4'h0: byte_wr_p10)} :  // EVEN wl +  ODD cmd (extra condition to zero out the byte_wr_p10 while rd ptr switching from even to odd)
                    (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p10, byte_wr_p10} :  //  ODD wl +  ODD cmd
                    (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p9,  byte_wr_p9}  :  // EVEN wl + EVEN cmd
                                                                                                                         {8'h00};
      
      ddr_do_mxd  = (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_do_ff  , ddr_upr_wrd_do_ff_2} : //  ODD wl + EVEN cmd
                    (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_do_ff  , ddr_upr_wrd_do_ff_2} : // EVEN wl +  ODD cmd   
                    (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_do_ff_2, ddr_lwr_wrd_do_ff_2} : //  ODD wl +  ODD cmd
                    (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_do_ff  , ddr_lwr_wrd_do_ff }  : // EVEN wl + EVEN cmd
                                                                                                                         {pNO_OF_BYTES*pCLK_NX*16{1'bx}};             // not valid state
      
      ddr_dm_mxd  = (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_dm_ff  , ddr_upr_wrd_dm_ff_2} : //  ODD wl + EVEN cmd
                    (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_dm_ff  , ddr_upr_wrd_dm_ff_2} : // EVEN wl +  ODD cmd   
                    (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_dm_ff_2, ddr_lwr_wrd_dm_ff_2} : //  ODD wl +  ODD cmd
                    (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_dm_ff  , ddr_lwr_wrd_dm_ff }  : // EVEN wl + EVEN cmd
                                                                                                                         {pNUM_LANES*pCLK_NX*2{1'bx}};                // not valid state
 
      //byte_rd_mxd = (t_rl_odd) ? byte_rd_ff : byte_rd_pn;
      byte_rd_mxd = (t_rl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_pn, byte_rd_ff} :  //  ODD rl + EVEN cmd
                    (t_rl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_pn, ((inc_cnt_ff && last_cmd_odd ===1'b0)? 4'h0: byte_rd_ff)} :  // EVEN rl +  ODD cmd  (extra condition to zero out the byte_wr_p10 while rd ptr switching from even to odd)
                    (t_rl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_ff, byte_rd_ff} :  //  ODD rl +  ODD cmd
                    (t_rl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_pn, byte_rd_pn} :  // EVEN rl + EVEN cmd
                                                                                                                         {8'h00};
`else
      if (use_rnd_even_odd_timing) begin
        // heoc mode use hdr_odd_cmd_array to store the odd/even mode information as well as when the cmd is valid to pipe the byte wr or byte rd into their corresponding mxd
        byte_wr_mxd = (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p9,  byte_wr_p10} :  //  ODD wl + EVEN cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p9,  ((inc_cnt_ff && last_cmd_odd ===1'b0)? 4'h0: byte_wr_p10)} :  // EVEN wl +  ODD cmd (extra condition to zero out the byte_wr_p10 while rd ptr switching from even to odd)
                      (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p10, byte_wr_p10} :  //  ODD wl +  ODD cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_wr_p9,  byte_wr_p9}  :  // EVEN wl + EVEN cmd
                                                                                                                           {8'h00};
      
        ddr_do_mxd  = (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_do_ff  , ddr_upr_wrd_do_ff_2} : //  ODD wl + EVEN cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_do_ff  , ddr_upr_wrd_do_ff_2} : // EVEN wl +  ODD cmd   
                      (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_do_ff_2, ddr_lwr_wrd_do_ff_2} : //  ODD wl +  ODD cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_do_ff  , ddr_lwr_wrd_do_ff }  : // EVEN wl + EVEN cmd
                                                                                                                           {pNO_OF_BYTES*pCLK_NX*16{1'bx}};             // not valid state
      
        ddr_dm_mxd  = (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_dm_ff  , ddr_upr_wrd_dm_ff_2} : //  ODD wl + EVEN cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_lwr_wrd_dm_ff  , ddr_upr_wrd_dm_ff_2} : // EVEN wl +  ODD cmd   
                      (t_wl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_dm_ff_2, ddr_lwr_wrd_dm_ff_2} : //  ODD wl +  ODD cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {ddr_upr_wrd_dm_ff  , ddr_lwr_wrd_dm_ff }  : // EVEN wl + EVEN cmd
                                                                                                                           {pNUM_LANES*pCLK_NX*2{1'bx}};                // not valid state
 
        //byte_rd_mxd = (t_rl_odd) ? byte_rd_ff : byte_rd_pn;
        byte_rd_mxd = (t_rl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_pn, byte_rd_ff} :  //  ODD rl + EVEN cmd
                      (t_rl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_pn, ((inc_cnt_ff && last_cmd_odd ===1'b0)? 4'h0: byte_rd_ff)} :  // EVEN rl +  ODD cmd  (extra condition to zero out the byte_wr_p10 while rd ptr switching from even to odd)
                      (t_rl_odd       && hdr_odd_cmd_array[rd_odd_even_ptr]       && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_ff, byte_rd_ff} :  //  ODD rl +  ODD cmd
                      (t_rl_odd==1'b0 && hdr_odd_cmd_array[rd_odd_even_ptr]==1'b0 && hdr_odd_cmd_valid[rd_odd_even_ptr]) ? {byte_rd_pn, byte_rd_pn} :  // EVEN rl + EVEN cmd
                                                                                                                           {8'h00};
      end else begin
        byte_wr_mxd = (t_wl_odd       && hdr_odd_cmd_d1==1'b0) ? {byte_wr_p9,  byte_wr_p10} :  //  ODD wl + EVEN cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_d1      ) ? {byte_wr_p9,  byte_wr_p10} :  // EVEN wl +  ODD cmd
                      (t_wl_odd       && hdr_odd_cmd_d1      ) ? {byte_wr_p10, byte_wr_p10} :  //  ODD wl +  ODD cmd
                                                                 {byte_wr_p9,  byte_wr_p9}  ;  // EVEN wl + EVEN cmd
      
        ddr_do_mxd  = (t_wl_odd       && hdr_odd_cmd_d1==1'b0) ? {ddr_lwr_wrd_do_ff  , ddr_upr_wrd_do_ff_2} : //  ODD wl + EVEN cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_d1      ) ? {ddr_lwr_wrd_do_ff  , ddr_upr_wrd_do_ff_2} : // EVEN wl +  ODD cmd   
                      (t_wl_odd       && hdr_odd_cmd_d1      ) ? {ddr_upr_wrd_do_ff_2, ddr_lwr_wrd_do_ff_2} : //  ODD wl +  ODD cmd
                                                                 {ddr_upr_wrd_do_ff  , ddr_lwr_wrd_do_ff }  ; // EVEN wl + EVEN cmd
      
        ddr_dm_mxd  = (t_wl_odd       && hdr_odd_cmd_d1==1'b0) ? {ddr_lwr_wrd_dm_ff  , ddr_upr_wrd_dm_ff_2} : //  ODD wl + EVEN cmd
                      (t_wl_odd==1'b0 && hdr_odd_cmd_d1      ) ? {ddr_lwr_wrd_dm_ff  , ddr_upr_wrd_dm_ff_2} : // EVEN wl +  ODD cmd   
                      (t_wl_odd       && hdr_odd_cmd_d1      ) ? {ddr_upr_wrd_dm_ff_2, ddr_lwr_wrd_dm_ff_2} : //  ODD wl +  ODD cmd
                                                                 {ddr_upr_wrd_dm_ff  , ddr_lwr_wrd_dm_ff }  ; // EVEN wl + EVEN cmd
 
        //byte_rd_mxd = (t_rl_odd) ? byte_rd_ff : byte_rd_pn;
        byte_rd_mxd = (t_rl_odd       && hdr_odd_cmd_d1==1'b0) ? {byte_rd_pn, byte_rd_ff} :  //  ODD rl + EVEN cmd
                      (t_rl_odd==1'b0 && hdr_odd_cmd_d1      ) ? {byte_rd_pn, byte_rd_ff} :  // EVEN rl +  ODD cmd
                      (t_rl_odd       && hdr_odd_cmd_d1      ) ? {byte_rd_ff, byte_rd_ff} :  //  ODD rl +  ODD cmd
                                                                 {byte_rd_pn, byte_rd_pn} ;  // EVEN rl + EVEN cmd
      end
`endif
      if (odt_hdr_odd_cmd) begin
        {sdr_odt_1_mxd, sdr_odt_mxd} = (ddr3_mode|ddr4_mode|lpddr3_mode) ? {sdr_odt_1,                    sdr_odt_ff} :
                                       (t_ol_odd)  ?                       {sdr_odt_1_ff & ~odt_end_ff,   sdr_odt_ff} :
                                                                           {sdr_odt_1,                    sdr_odt & sdr_odt_ff & ~odt_end_ff};
      end
      else begin
       {sdr_odt_1_mxd, sdr_odt_mxd} = (ddr3_mode|ddr4_mode|lpddr3_mode) ? {sdr_odt_1,                     sdr_odt} :
                                      (t_ol_odd)  ?                       {sdr_odt_1,                     sdr_odt & sdr_odt_ff & ~odt_end_ff} :
                                                                          {sdr_odt_1 & ~odt_end,          sdr_odt};
      end
    end else begin
      if (`DWC_DDRPHY_SDR_MODE == 2'b10) begin
        // PHY running in SDR mode
        byte_wr_mxd = byte_wr_p9;
        ddr_do_mxd  = ddr_do_ff_2;
        ddr_dm_mxd  = ddr_dm_ff_2;
        byte_rd_mxd = byte_rd_ff;
      end else begin
        // only controller running in SDR mode
        byte_wr_mxd = {byte_wr_p8, byte_wr_p8};
        ddr_do_mxd  = ddr_do;
        ddr_dm_mxd  = ddr_dm;
        byte_rd_mxd = byte_rd_m2;
      end
    end
  end
  
  // write and read latency odd/even indicator
  // ***TBD: for now all bytes have same indicator - later include the byte
  //         specific differences
  assign t_byte_wl_odd = {pNO_OF_BYTES{t_wl_odd}};
  assign t_byte_rl_odd = {pNO_OF_BYTES{t_rl_odd}};
  
                                                                
  //---------------------------------------------------------------------------
  // Auto-Refresh Scheduler
  //---------------------------------------------------------------------------
  // Schedules auto refreshes to the SDRAM; this is only for internal PUB
  // blocks that have the option of issuing auot-refreshes
  always @(posedge clk or negedge rst_b) begin
    if (rst_b == 1'b0) begin
      rfsh_prd_cntr_init <= 1'b0;
      rfsh_prd_cntr      <= {pRFSH_CNTR_WIDTH{1'b0}};
      rfsh_prd_cntr_load <= 1'b0;
      rfsh_prd_cntr_en   <= 1'b0;
      rfsh_rqst_vld      <= 1'b0;
      rfsh_burst_cntr    <= {pRFSH_BURST_WIDTH{1'b0}};
      rfsh_last_burst    <= 1'b0;
      rfsh_state         <= RFSH_IDLE;
      rfsh_rqst_rank     <= {pRANK_WIDTH{1'b0}};

      phy_init_done_ff   <= 2'b00;
    end else begin
      // start refresh period counter when PHY has finished initialization or when PUB internal blocks are done
      phy_init_done_ff   <= {phy_init_done_ff[0], phy_init_done};
      rfsh_prd_cntr_init <= rfsh_en && (phy_init_done_ff[0] && ~phy_init_done_ff[1]);
      // refresh period counter
      if (rfsh_prd_cntr_load) begin
        rfsh_prd_cntr <= rfsh_prd/pCLK_NX; // divide by 2 in HDR
      end else if (rfsh_prd_cntr_en && !rfsh_rqst_vld) begin
        rfsh_prd_cntr <= rfsh_prd_cntr - 1;
      end
      
`ifndef GATE_LEVEL_SIM
      // refresh period counter is loaded at the beginning of controller; not applicable for Emulation gates!
      // operations or when the last refresh of a refresh burst is received
      if (   (rfsh_prd_cntr_init || (rfsh_rqst_ack && rfsh_last_burst))
          || (`PUB.u_DWC_ddrphy_scheduler.pub_mode && (`PUB.u_DWC_ddrphy_scheduler.rfsh_rqst_ack && `PUB.u_DWC_ddrphy_scheduler.rfsh_last_burst))
         ) begin
        rfsh_prd_cntr_load <= 1'b1;
      end else begin
        rfsh_prd_cntr_load <= 1'b0;
      end
      // refresh period counter enabled only when refreshes are programmed to be enabled
      rfsh_prd_cntr_en <= rfsh_en & phy_init_done;

      // refresh period counter generates a request valid to the PUB blocks when
      // the refresh counter times out; note that the next count immediately
      // starts even when the request is not acknowledge to make sure that the
      // average time between refreshes remain as programmed
      if (rfsh_prd_cntr == {{(pRFSH_CNTR_WIDTH-1){1'b0}}, 1'b1}) begin
        rfsh_rqst_vld   <= 1'b1;
      end else if (   (rfsh_rqst_ack && rfsh_last_burst) 
                   || (`PUB.u_DWC_ddrphy_scheduler.pub_mode && (`PUB.u_DWC_ddrphy_scheduler.rfsh_rqst_ack && `PUB.u_DWC_ddrphy_scheduler.rfsh_last_burst))
                  ) begin
        rfsh_rqst_vld   <= 1'b0;
      end
`elsif DWC_DDRPHY_BUILD 
      // refresh period counter is loaded at the beginning of controller; not applicable for Emulation gates!
      // operations or when the last refresh of a refresh burst is received
      if (   (rfsh_prd_cntr_init || (rfsh_rqst_ack && rfsh_last_burst))
          || (`PUB.u_DWC_ddrphy_scheduler.pub_mode && (`PUB.u_DWC_ddrphy_scheduler.rfsh_rqst_ack && `PUB.u_DWC_ddrphy_scheduler.rfsh_last_burst))
         ) begin
        rfsh_prd_cntr_load <= 1'b1;
      end else begin
        rfsh_prd_cntr_load <= 1'b0;
      end
      // refresh period counter enabled only when refreshes are programmed to be enabled
      rfsh_prd_cntr_en <= rfsh_en & phy_init_done;

      // refresh period counter generates a request valid to the PUB blocks when
      // the refresh counter times out; note that the next count immediately
      // starts even when the request is not acknowledge to make sure that the
      // average time between refreshes remain as programmed
      if (rfsh_prd_cntr == {{(pRFSH_CNTR_WIDTH-1){1'b0}}, 1'b1}) begin
        rfsh_rqst_vld   <= 1'b1;
      end else if (   (rfsh_rqst_ack && rfsh_last_burst) 
                   || (`PUB.u_DWC_ddrphy_scheduler.pub_mode && (`PUB.u_DWC_ddrphy_scheduler.rfsh_rqst_ack && `PUB.u_DWC_ddrphy_scheduler.rfsh_last_burst))
                  ) begin
        rfsh_rqst_vld   <= 1'b0;
      end
`endif

      // track the nth numbere of refresh bursts: burst counter loaded at the beginning of
      // PUB internal operations if refreshes are enabled or when when the last refresh of 
      // a refresh burst is received
      if (rfsh_prd_cntr_load) begin
        rfsh_burst_cntr <= rfsh_burst/pCLK_NX;
      end else if (rfsh_rqst_ack && (|rfsh_burst_cntr)) begin
        rfsh_burst_cntr <= rfsh_burst_cntr - 1;
      end
      
      if ((rfsh_burst      == {{(pRFSH_BURST_WIDTH-1){1'b0}}, 1'b1}) ||
          (rfsh_burst_cntr == {{(pRFSH_BURST_WIDTH-1){1'b0}}, 1'b1} && rfsh_rqst_ack)) begin
        rfsh_last_burst <= 1'b1;
      end else if (rfsh_rqst_ack) begin
        rfsh_last_burst <= 1'b0;
      end

      // refresh command state machine
      case (rfsh_state)
        RFSH_IDLE: begin
          if (rfsh_mode_start) begin
            rfsh_state <= RFSH_PREALL;
          end
        end
        RFSH_PREALL: begin
          if (timing_met) begin  
            rfsh_state <= (rfsh_last_rank) ? RFSH_REFRESH : RFSH_PREALL;
          end
        end
        RFSH_REFRESH: begin
          if (timing_met) begin
            rfsh_state <= (rfsh_last_burst && rfsh_last_rank) ? RFSH_POST : RFSH_REFRESH;
          end
        end
        RFSH_POST: begin
          // wait fir refresh command to go through
          if (rfsh_rqst_ack) begin
            rfsh_state <= RFSH_IDLE;
          end
        end
      endcase // case (rfsh_state)

      // for no-silmultaeneous rank access, issue the PRECHARGE ALL and REFRESH commands
      // one rank at a time
      if ((`DWC_NO_SRA == 1) && 
          ((rfsh_state == RFSH_PREALL  && timing_met) || 
           (rfsh_state == RFSH_REFRESH && timing_met && rfsh_last_burst))) begin
        rfsh_rqst_rank <= (rfsh_last_rank) ? 0 : rfsh_rqst_rank + 1;
      end
      
        
          
    end
  end // always @ (posedge clk or negedge rst_b)

  // refresh request is acknowledged when the refresh command has been
  // sent by the PUB block
  assign rfsh_rqst_ack   = rfsh_cmd;
  assign rfsh_rqst_cmd   = (rfsh_state == RFSH_PREALL)  ? PRECHARGE_ALL :
                           (rfsh_state == RFSH_REFRESH) ? REFRESH : SDRAM_NOP;
  assign rfsh_mode_start = rfsh_rqst_vld & ~host_rfsh_inh & (host_first_data | ~host_rqvld) & ~dfi_upd_busy;
  assign rfsh_mode       = ((rfsh_state == RFSH_IDLE && rfsh_mode_start) ||
                            (rfsh_state != RFSH_IDLE && rfsh_state != RFSH_POST)) ? 1'b1 : 1'b0;
  assign rfsh_last_rank  = ((`DWC_NO_SRA == 0) || 
                            (`DWC_NO_SRA == 1 && rfsh_rqst_rank == (pNO_OF_RANKS-1))) ? 1'b1 : 1'b0;
  assign phy_init_done   = `SYS.init_done;

endmodule // ddr_mctl
