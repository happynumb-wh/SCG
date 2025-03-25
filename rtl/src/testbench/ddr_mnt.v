/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                                                *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR SDRAM Bus Monitor                                         *
 *              Monitors the interface bus between the DDR controller and the *
 *              DDR SDRAMs                                                    *
 *                                                                            *
 *****************************************************************************/

module ddr_mnt (
                rst_n,     // asynshronous reset
                ram_rst_n, // asynshronous ram reset from chip
                ck,        // SDRAM clock
                ck_n,      // SDRAM clock #
                cke,       // SDRAM clock enable
                odt,       // SDRAM on-die termination
                cs_n,      // SDRAM chip select
                act_n,     // SDRAM activate command input
`ifdef DDR4
                cid,        // SDRAM chip ID
`else                
                ras_n,     // SDRAM command input (row address select)
                cas_n,     // SDRAM command input (column address select)
                we_n,      // SDRAM command input (write enable)
`endif
                ba,        // SDRAM bank address
                a,         // SDRAM address
                dm,        // SDRAM output data mask
                dqs,       // SDRAM input/output data strobe
                dqs_n,     // SDRAM input/output data strobe #
                dq         // SDRAM input/output data
                );
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  // configurable design parameters
  parameter pNO_OF_BYTES = 9; 
  parameter pNO_OF_RANKS = 2;
  parameter pCID_WIDTH   = `DWC_CID_WIDTH;
  parameter pCK_WIDTH    = 3;
  parameter pBANK_WIDTH  = 3;
  parameter pADDR_WIDTH  = 16;
  parameter pNUM_LANES_X2    = 2*pNO_OF_BYTES*`DWC_DX_NO_OF_DQS;  
  parameter pCLK_NX      = `CLK_NX; // PHY clock is 2x or 1x controller clock
  parameter rank_no      = 0; // rank number
  parameter pNO_OF_DX_DQS   = `DWC_DX_NO_OF_DQS; // number of DQS signals per DX macro
  parameter pNUM_LANES      = pNO_OF_DX_DQS * pNO_OF_BYTES;

`ifdef DWC_USE_SHARED_AC_TB
  parameter pDATA_WIDTH  = (rank_no%2)? `CH1_DWC_EDATA_WIDTH : `CH0_DWC_EDATA_WIDTH;
`else
  parameter pDATA_WIDTH  = `DWC_EDATA_WIDTH;
`endif 
`ifdef DWC_NO_OF_3DS_STACKS
  parameter pNO_OF_3DS_STACKS = `DWC_NO_OF_3DS_STACKS;
`else
  parameter pNO_OF_3DS_STACKS = 0;
`endif  

  parameter pRANK_WIDTH  = (`NUM_3DS_STACKS == 0) ? 2 : 2 + `DWC_CID_WIDTH;
  parameter pNO_OF_PRANKS = pNO_OF_RANKS;
  parameter pMAX_RANKS         = 16;
  parameter pMAX_PRANKS        = 12;

  // lengths (clocks) for how long a DDR read or write takes to output or input
  // all its data
  parameter MAX_RW_LEN = 63; // max read latency + max chip burst length 
  
  // command types
  parameter READ_CMD  = 0,
            WRITE_CMD = 1,
            OTHER_CMD = 2,
            ANY_CMD   = 3;

`ifdef DDR4
  // DDR protocol command encodings
  // {ACT#, CKE(prev), CKE, CS#, RAS#, CAS#, WE#}
  parameter LOAD_MODE        = 7'b111_0000, // load mode register
            REFRESH          = 7'b111_0001, // refresh
            SELF_REFRESH     = 7'b110_0001, // self refresh entry
            PRECHARGE        = 7'b111_0010, // precharge
            ACTIVATE         = 7'b011_0???, // bank activate
            WRITE            = 7'b111_0100, // write
            READ             = 7'b111_0101, // read
            ZQCAL            = 7'b111_0110, // ZQ calibration
            NOP              = 7'b111_0111, // no operation
            DESELECT         = 7'b111_1???, // device deselect
            POWER_DOWN       = 7'b?10_1???, // power down entry
            POWER_DWN_EXIT   = 7'b?01_1???, // power down exit
            SELF_RFSH_EXIT   = 7'b101_0111, // self refresh exit
            SELF_RFSH_EXIT_2 = 7'b?01_1???, // self refresh exit
            CLOCK_DISABLE    = 7'b100_????; // clock disable
                             
  parameter TERMINATE        = 7'b111_0110; // Burst terminate
`else  
  // DDR protocol command encodings
  // {CKE(prev), CKE, CS#, RAS#, CAS#, WE#}
  parameter LOAD_MODE        = 6'b11_0000, // load mode register
            REFRESH          = 6'b11_0001, // refresh
            SELF_REFRESH     = 6'b10_0001, // self refresh entry
            PRECHARGE        = 6'b11_0010, // precharge
            ACTIVATE         = 6'b11_0011, // bank activate
            WRITE            = 6'b11_0100, // write
            READ             = 6'b11_0101, // read
            ZQCAL            = 6'b11_0110, // ZQ calibration
            NOP              = 6'b11_0111, // no operation
            DESELECT         = 6'b11_1???, // device deselect
            POWER_DOWN       = 6'b10_0111, // power down entry
            POWER_DOWN_2     = 6'b10_1???, // power down entry
            POWER_DWN_EXIT   = 6'b01_0111, // power down exit
            POWER_DWN_EXIT_2 = 6'b01_1???, // power down exit
            SELF_RFSH_EXIT   = 6'b01_0111, // self refresh exit
            SELF_RFSH_EXIT_2 = 6'b01_1???, // self refresh exit
            CLOCK_DISABLE    = 6'b00_????; // clock disable

  parameter TERMINATE        = 6'b11_0110; // Burst terminate
`endif
  
  parameter SPECIAL_CMD    = 4'b0111; // ODT ON or OFF
  parameter ODT_ON         = 4'd6;    // address decode for ODT ON
  parameter ODT_OFF        = 4'd7;    // address decode for ODT OFF
  
  // initialization timing parameters
  // - wait clocks for master DLL to lock after reset is de-asserted
  // - wait time from when the clocks are stable to when CKE is asserted high,
  //   i.e. the 200us SDRAM wait time
  // - wait time from when CKE is driven high to when the first command is
  //   passed to the SDRAM, i.e the 400ns SDRAM wait time
  parameter MSD_DLL_WAIT   = 1024,             // MDLL wait to lock
            DDR_INIT_WAIT  = 9600;              // SDRAM init 400ns clks

`ifdef FULL_SDRAM_INIT
  `ifdef DDR3
      parameter DDR_CKE_WAIT   = 360/(`CLK_PRD);    // expressed in number of tCLK_PRD
                                                     // In DDR3: tXPR = MAX( tRFC(min)+10ns or 5*tCK) = 360ns  
  `else
    `ifdef LPDDR2
       parameter DDR_CKE_WAIT   = 200000/(`CLK_PRD); // 200us
    `else
      `ifdef LPDDR3
            parameter DDR_CKE_WAIT   = 200000/(`CLK_PRD); //200us
      `else  
         parameter DDR_CKE_WAIT   = 160;              // SDRAM init 400ns clks
      `endif
    `endif
  `endif
`else //!FULL_SDRAM_INIT
  `ifdef DDR3
     parameter DDR_CKE_WAIT   = 160;
  `else
    `ifdef LPDDR2
       parameter DDR_CKE_WAIT   = `tDINIT0_c_ssi;
    `else
       `ifdef LPDDR3
          parameter DDR_CKE_WAIT   = `tDINIT0_c_ssi;
       `else
          parameter DDR_CKE_WAIT   = 160;
       `endif
    `endif
  `endif
`endif


  parameter MSD_ZCTRL_WAIT = 2250;   // 1172 before
   
`ifdef DDR3
  `ifdef FULL_SDRAM_INIT  
    //`define DRAM_RST_TO_CKE_HIGH          500*1000/(`SYS.tCLK_PRD) // 500us expressed in number of tCLK_PRD
    `define DRAM_RST_TO_CKE_HIGH          `tDINIT0_c // 500us expressed in number of tCLK_PRD
    `define DDR3_RESET_PWRUP_ASSERT_WAIT  200000    // 200us for DDR3 DRAM RESET ASSERT LOW WAIT during Power up 
    `define DDR3_RESET_ASSERT_WAIT        100       // 100ns for DDR3 DRAM RESET ASSERT LOW WAIT during reset  
  `else
    `define DRAM_RST_TO_CKE_HIGH          `tDINIT0_c_ssi                       // shortened
    `define DDR3_RESET_PWRUP_ASSERT_WAIT  `tDINIT2_c_ssi*(`SYS.tCLK_PRD)       // 200ns for DDR3 DRAM RESET ASSERT LOW WAIT during Power up 
    `define DDR3_RESET_ASSERT_WAIT        `tDINIT2_c_ssi*(`SYS.tCLK_PRD)       // 100ns for DDR3 DRAM RESET ASSERT LOW WAIT during reset  
  `endif  
`endif

`ifdef DDR2
  `ifdef FULL_SDRAM_INIT  
    `define RST_TO_CKE_HIGH  200*1000/(`SYS.tCLK_PRD) // 200us expressed in number of tCLK_PRD
  `else
    `define RST_TO_CKE_HIGH  `tDINIT0_c_ssi           // shortened
  `endif  
`endif

  // DDR3 ODT high time for burst lenght 4/8
  parameter ODTH4          = 4,
            ODTH8          = 6;

  parameter pADDR_BIT_12 = (`DWC_ADDR_WIDTH == 10) ? 9 : 12;
  

  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                    rst_n;     // asynshronous reset
  input                    ram_rst_n; // DDR3 DRAM reset
  input                    ck;        // SDRAM clock
  input                    ck_n;      // SDRAM clock #
  input                    cke;       // SDRAM clock enable
  input                    odt;       // SDRAM on-die termination
  input                    cs_n;      // SDRAM chip select
  input                    act_n;     // SDRAM activate command
`ifdef DDR4
  input [pCID_WIDTH -1:0]  cid;       // SDRAM chip ID
`else  
  input                    ras_n;     // SDRAM row address select
  input                    cas_n;     // SDRAM column address select
  input                    we_n;      // SDRAM write enable
`endif
  input [pBANK_WIDTH -1:0] ba;        // SDRAM bank address
  input [pADDR_WIDTH -1:0] a;         // SDRAM address
  input [pNUM_LANES-1:0]   dm;        // SDRAM output data mask
  input [pNUM_LANES-1:0]   dqs;       // SDRAM input/output data strobe
  input [pNUM_LANES-1:0]   dqs_n;     // SDRAM input/output data strobe #
  input [pDATA_WIDTH -1:0] dq;        // SDRAM input/output data
  
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [pNO_OF_RANKS-1:0]      odt_wr_vector;
  reg [pNO_OF_RANKS-1:0]      odt_rd_vector;
  reg [31:0]                  op;
  reg                         ckep;
  reg                         cs_np;
  reg                         self_rfsh_mode;
  reg                         power_down_mode;
  reg                         all_banks_closed;
  
  reg                         mnt_en;
  reg                         nop_mnt_en;
  reg [31:0]                  nop_cnt;
  reg                         undf_mnt_en;
  reg                         Debug; initial Debug = 1;
  
  // signal pipelines (for d elayed reporting)
  reg [MAX_RW_LEN-1:0]        ckep_ck;
  reg [MAX_RW_LEN-1:0]        cke_ck;
  reg [MAX_RW_LEN-1:0]        odt_ck;
  reg [MAX_RW_LEN-1:0]        cs_np_ck;
  reg [MAX_RW_LEN-1:0]        cs_n_ck;
`ifdef DDR4
  reg [MAX_RW_LEN-1:0]        act_n_ck;
`endif
  reg [MAX_RW_LEN-1:0]        ras_n_ck;
  reg [MAX_RW_LEN-1:0]        cas_n_ck;
  reg [MAX_RW_LEN-1:0]        we_n_ck;

  reg [pBANK_WIDTH -1:0]      ba_ck [0:MAX_RW_LEN-1];
  reg [pADDR_WIDTH -1:0]      a_ck [0:MAX_RW_LEN-1];
  reg [pADDR_WIDTH -1:0]      a_ck_n [0:MAX_RW_LEN-1];
     
  reg [pNUM_LANES-1:0]        dm_ck [0:MAX_RW_LEN-1];
  reg [pNUM_LANES-1:0]        dqs_ck [0:MAX_RW_LEN-1];
  reg [pNUM_LANES-1:0]        dqs_n_ck [0:MAX_RW_LEN-1];
  reg [pDATA_WIDTH -1:0]      d_ck [0:MAX_RW_LEN-1];
  reg [pDATA_WIDTH -1:0]      q_qs [0:MAX_RW_LEN-1];
     
  reg [pNUM_LANES-1:0]        dm_ck_n [0:MAX_RW_LEN-1];
  reg [pNUM_LANES-1:0]        dqs_ck_n [0:MAX_RW_LEN-1];
  reg [pNUM_LANES-1:0]        dqs_n_ck_n [0:MAX_RW_LEN-1];
  reg [pDATA_WIDTH -1:0]      d_ck_n [0:MAX_RW_LEN-1];
  reg [pDATA_WIDTH -1:0]      q_qsb [0:MAX_RW_LEN-1];
  reg                         odt_mnt_en;
  
  wire                        qs;
  wire                        qsb;
  wire                        wr_cmd,     rd_cmd;
  wire                        wr_cmd_all, rd_cmd_all;

  wire [pNO_OF_RANKS-1:0]     rank_wrcmd;
  wire [pNO_OF_RANKS-1:0]     rank_rdcmd;
  reg                         wl_mode;
  
  reg                         ddr3_xpct_odt_wr_i, ddr3_xpct_odt_rd_i, ddr3_xpct_odt_ff;
  wire                        ddr3_xpct_odt;
  reg  [pNO_OF_RANKS-1:0]     wrodt [0:pNO_OF_RANKS-1];
  reg  [pNO_OF_RANKS-1:0]     rdodt [0:pNO_OF_RANKS-1];
  wire                        a_12;
  integer                     rank_id;
  
  wire [3:0]                  burst_len; // chip logic burst length (max = 8)
  wire [5:0]                  rl;        // read latency (max = 21+5=26)
  wire [5:0]                  wl;        // write latency (max = 18+5=23)
  wire [5:0]                  rwl;       // read/write latency (max = 21+5=26)
  wire [31:0]                 rw_len;    // length of read/write (latency + data)
  wire [31:0]                 rl_diff;   // difference of rl from max rwl
  wire [31:0]                 wl_diff;   // difference of rl from max rwl
  reg  [3:0]                  w_b;       // self write command
  reg  [3:0]                  r_b;       // self read  command
  wire [3:0]                  any_w_b;   // any write command
  wire [3:0]                  any_r_b;   // any read  command  
  reg  [3:0]                  bl8;       // low for either a read or write command
  wire [31:0]                 odta;      // ODT assertion delay in CK cycles from write command
  wire [31:0]                 odtd;      // ODT duration in CK cycles 
  integer                     data_start;
  integer                     data_end;
  reg                         bl4_otf_wr, bl4_otf_rd;

  reg [`SDRAM_ROW_WIDTH-1:0]  bank_row [0:15];

  reg  [pCID_WIDTH -1:0]      rank_cid;
  wire [pRANK_WIDTH-1:0]      rank;

  // initialization sequence and auto-refresh monitors
  reg                         init_mnt_en;
  reg                         rst_cke_mnt_en;
  reg                         init_sw;
  real                        curr_time;
  real                        prev_time;
  real                        prev_cke_time;
  real                        dll_rst_time;
  reg                         dll_rst_wait;
  integer                     xpctd_cmd_spacing;
  integer                     xpctd_init_cke_spacing;
  integer                     no_of_pre_all;
  integer                     no_of_load_mode;
  integer                     no_of_rfsh;
  reg [31:0]                  next_xpctd_cmd;
  reg [`REG_ADDR_WIDTH-1:0]   next_xpctd_reg;
  reg                         rfsh_mnt_en;
  reg                         rfsh_burst;
  real                        rfsh_time;
  integer                     xpctd_rfsh_prd;
  integer                     no_of_cr_wr;
  integer                     xpctd_no_of_cr_wr;
  reg [3:0]                   xpctd_cr_addr [0:15];
  reg [3:0]                   xpctd_cr_data [0:15];
  reg [3:0]                   skpd_cr_after [0:16];
  integer                     prev_cr_addr;
  reg                         rdimm_mnt_en;
  reg                         rdimm_firt_load_mode;
  reg                         after_rdimm_reset;
  integer                     no_of_rdimm_perr;

  wire                        ddr4_mode;
  wire                        ddr3_mode;
  wire                        lpddr3_mode;
  wire                        lpddr2_mode;
  wire                        ddr_8_bank;
  wire                        ddr_16_bank;
  wire [`tMRD_WIDTH-1:0]      t_mrd;
  wire [4:0]                  t_mod;
  wire [`tRP_WIDTH-1:0]       t_rp;
  wire [`tRFC_WIDTH-1:0]      t_rfc;

  event                       sdram_write_event;
  reg                         got_one_refresh;
  reg [3:0]                   rfsh_burst_length;
  wire [`DDR_RANK_WIDTH-1:0]  odt_full;
  reg [`DDR_RANK_WIDTH-1:0]   odt_q[0:5];

  reg [3:0]                   ddr3_odt_on;

  reg                         rtt_mnt_en;
  reg                         rtt_mnt_en_ff;
  wire                        bst_cmd;
  reg  [1:0]                  rd_rank;
  reg  [MAX_RW_LEN-1:0]       rd_cmd_pn;  
  reg  [1:0]                  rd_rank_pn   [0:MAX_RW_LEN-1];  
  reg  [31:0]                 rd_data_lat  [0:pNUM_LANES-1];
  reg  [0:pNO_OF_BYTES-1]     dq_rtt_ctl   ;
  reg  [0:pNUM_LANES-1]       dqs_rtt_ctl  ;
  reg  [0:pNO_OF_BYTES-1]     rtt_on_al    ;
  reg  [1:0]                  rtt_off_hold [0:pNO_OF_BYTES-1];
  reg  [0:pNUM_LANES-1]       dqs_odt      ;
  reg  [0:pNO_OF_BYTES-1]     dq_odt       ;
  reg  [0:pNO_OF_BYTES-1]     rtt_on       ;
  reg  [0:4]                  rtt_on_pn    [0:pNO_OF_BYTES-1];
  reg  [6:0]                  rtt_on_cnt   [0:pNO_OF_BYTES-1];
  reg  [0:pNO_OF_BYTES-1]     rtt_off      ;
  reg  [31:0]                 rtt_off_lat  [0:pNO_OF_BYTES-1];
  reg  [6:0]                  rtt_off_cnt  [0:pNO_OF_BYTES-1];
  reg  [2:0]                  sys_lat      [0:pNUM_LANES-1][0:pNO_OF_RANKS-1];
  reg  [1:0]                  phase_sel    [0:pNUM_LANES-1][0:pNO_OF_RANKS-1];
  reg  [0:pNO_OF_BYTES-1]     dfi_rddata_en_d;
  reg  [0:pNO_OF_BYTES-1]     dfi_rddata_en_d_ff;
 
  reg  [0:pNUM_LANES-1]       dqs_rtt      ;
  reg  [0:pNO_OF_BYTES-1]     dq_rtt       ;
  reg  [0:pNUM_LANES-1]       xpctd_dqs_rtt;
  reg  [0:pNO_OF_BYTES-1]     xpctd_dq_rtt ;
  wire                        cs_n_all;
  wire                        cs_n_rank;

  reg  [3:0]                  rd_burst;
  reg                         rtt_rd_cmd;
  
  realtime                    ddr3_ram_rst_n_deasserted, ddr3_ram_rst_n_asserted;
  reg                         chk_pwrup_cond;
  
  event                       e_dqs_rtt_on_check;
  event                       e_dq_rtt_on_check;

  event                       e_ddr3_odt_err;
  event                       e_ddr2_odt_err;
  event                       e_ddr3_odt_on_good, e_ddr3_odt_off_good;
  event                       e_ddr2_odt_on_good, e_ddr2_odt_off_good;

  event                       e_MPR_mode_commands_error;
  
  reg                         wr_cmd_reg, rd_cmd_reg;
  wire [pNO_OF_RANKS-1:0]     rank_wrcmd_reg, rank_rdcmd_reg;

  reg                         mpr_mode;
  reg                         mpr_mnt_en;
  reg  [2           -1:0]     mpr_page;
  reg  [2           -1:0]     mpr_rd_format;
  reg  [pNO_OF_RANKS-1:0]     ckep_chip;
  wire [pNO_OF_RANKS-1:0]     cke_chip;
  
  reg [3:0] rdimm_cr_addr;
  reg [3:0] rdimm_cr_data;

  
  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize

      // Default refresh period, will be set to proper
      // value when the monitor is turned on.
      xpctd_rfsh_prd    = 28000;
      // Default refresh burst length
      rfsh_burst_length = 4'h8;
      // by default, monitoring is disabled unless forced by a compile
      // directive or enabled through call to enable_monitor task
      mnt_en            = 1'b0;
      got_one_refresh   = 1'b0;

      
      // NOPs are by default enabled to be monitored, so are undefined values
      nop_cnt           = 0;
      nop_mnt_en        = 1'b1;
      undf_mnt_en       = 1'b1;

      self_rfsh_mode    = 1'b0;
      power_down_mode   = 1'b0;
      all_banks_closed  = 1'b1;
      
      init_mnt_en       = 1'b0;
      rst_cke_mnt_en    = 1'b1;
      init_sw           = 1'b0;
      prev_time         = 0.0;
      prev_cke_time     = 0.0;
      dll_rst_wait      = 1'b0;
      xpctd_cmd_spacing = 1;
      xpctd_init_cke_spacing = 1;
      no_of_pre_all     = 0;
      no_of_load_mode   = 0;
      no_of_rfsh        = 0;
`ifdef DDR3
      next_xpctd_cmd    = `LOAD_MODE;
      next_xpctd_reg    = `EMR2;
`else
  `ifdef LPDDR2
      next_xpctd_cmd    = `LOAD_MODE;
      next_xpctd_reg    = 63;
  `else
     `ifdef LPDDR3
      next_xpctd_cmd    = `LOAD_MODE;
      next_xpctd_reg    = 63;
      `else  
      next_xpctd_cmd    = `PRECHARGE_ALL;
      next_xpctd_reg    = `MR;
     `endif
  `endif
`endif
      no_of_cr_wr       = 0;
      xpctd_no_of_cr_wr = 0;
      prev_cr_addr      = -1;
      rdimm_mnt_en      = 0;
      rdimm_firt_load_mode = 0;      
      after_rdimm_reset = 0;      
      no_of_rdimm_perr  = 0;      
      rfsh_mnt_en       = 1'b0;
      rfsh_burst        = 1'b0;

      odt_mnt_en        = 1'b0;
      rtt_mnt_en        = 1'b1;
      ddr3_odt_on       = {4{1'b0}};
      ddr3_xpct_odt_wr_i = 1'b0;
      ddr3_xpct_odt_rd_i = 1'b0;
      ddr3_xpct_odt_ff  = 1'b0;
      wl_mode           = 1'b0;
      rank_cid          = {pCID_WIDTH{1'b0}};
    end

`ifdef DDR4
  always @(posedge ck) begin
    if (cs_n === 1'b0) begin
      rank_cid <= cid;
    end
  end
`endif
  
  assign rank = (`NUM_3DS_STACKS == 0) ? rank_no : rank_no*`NUM_3DS_STACKS + rank_cid;

  // length from when the write/read commands are issued to when the last
  // data of the access is completed
  // NOTE: the WL and RL in GRM already have extra 1 clock latency added for
  //       when using RDIMM - but this should be subtracted when using
  //       monitor because this is at the DRAM level
  // NOTE: LPDDR2 BL16 is trained using BL 8
  assign burst_len = (`PUB.phy_train === 1'b1 && `GRM.lpddr2_mode && `GRM.sdr_burst_len == 8) ? 4 : `GRM.sdr_burst_len;
  //assign rl        = `GRM.rl;
  `ifdef DWC_DDR_RDIMM
    assign  rl        = `GRM.sdram_rl;
  `else
    assign  rl        = `GRM.rl;
  `endif

  assign wl        = `GRM.wl;
  assign rwl       = (rl > wl) ? rl : wl;
  assign rw_len    = rwl + burst_len;
  assign rl_diff   = rwl - rl;
  assign wl_diff   = (`DWC_RDIMM == 1 && ddr4_mode) ? (rwl - wl + `GRM.rdimm_cmd_lat) : (rwl - wl);
  assign odta =`GRM.t_al + `GRM.t_cl - 4;
  assign odtd =`GRM.t_bl / 2 + 1;

  // ODTCR register bits
  always @(*) begin
    for (rank_id =0; rank_id < pNO_OF_PRANKS; rank_id = rank_id + 1) begin 
      wrodt[rank_id] = `GRM.odtcr[rank_id][27:16];
      rdodt[rank_id] = `GRM.odtcr[rank_id][11: 0];
    end
  end
  
  // disable undefined warning during WLA training
  always @(posedge ck) begin
    if ((!`PUB.u_DWC_ddrphy_train.wl_adj_done && `PUB.u_DWC_ddrphy_train.wl_adj_start)||(`GRM.pgcr1[20]==1'b1))
      disable_undefined_warning;
    else
      enable_undefined_warning;
   end


  // monitor enable/disable
  task enable_monitor;
    begin
      mnt_en = 1'b1;
    end
  endtask // enable_monitor

  task disable_monitor;
    begin
      mnt_en = 1'b0;
    end
  endtask // disable_monitor
  

  // odt monitor enable/disable
  task enable_odt_monitor;
    begin
`ifdef LPDDR2
      odt_mnt_en = 1'b0;
`else
      odt_mnt_en = 1'b0;
`endif
    end
  endtask // enable_odt_monitor

  task disable_odt_monitor;
    begin
      odt_mnt_en = 1'b0;
    end
  endtask // disable_odt_monitor

  
  // rtt monitor enable/disable
  task enable_rtt_monitor;
    begin
      rtt_mnt_en = 1'b1;
    end
  endtask // enable_rtt_monitor

  task disable_rtt_monitor;
    begin
      rtt_mnt_en = 1'b0;
    end
  endtask // disable_rtt_monitor


  // NOPs monitor enable/disable
  task enable_nops_monitor;
    begin
      nop_mnt_en = 1'b1;
    end
  endtask // enable_nops_monitor
  
  task disable_nops_monitor;
    begin
      nop_mnt_en = 1'b0;
    end
  endtask // disable_nops_monitor


  // initialization monitor enable/disable
  task enable_init_monitor;
    begin
      init_mnt_en = 1'b1;
    end
  endtask // enable_init_monitor
  
  task disable_init_monitor;
    begin
      init_mnt_en = 1'b0;
    end
  endtask // disable_init_monitor

  task enable_reset_cke_monitor;
    begin
      rst_cke_mnt_en = 1'b1;
    end
  endtask
  
  task disable_reset_cke_monitor;
    begin
      rst_cke_mnt_en = 1'b0;
    end
  endtask
  
  // rdimmialization monitor enable/disable
  task enable_rdimm_monitor;
    begin
      rdimm_mnt_en = 1'b1;
    end
  endtask // enable_rdimm_monitor
  
  task disable_rdimm_monitor;
    begin
      rdimm_mnt_en = 1'b0;
    end
  endtask // disable_rdimm_monitor

  
  // indicates that the initialization being monitored is done by user
  // software and not the hardware initialization done by the controller
  task set_software_initialization;
    begin
      init_sw = 1'b1;
    end
  endtask // set_software_initialization
  

  // undefined value monitor
  // disable/enable the monitoring and resulting warning when data has
  // undefined (X/Z) values
  task enable_undefined_warning;
    begin
      undf_mnt_en = 1'b1;
    end
  endtask // enable_undefined_warning

  task disable_undefined_warning;
    begin
      undf_mnt_en = 1'b0;
    end
  endtask // disable_undefined_warning

  
  // auto-refresh monitor enable/disable
  task enable_rfsh_monitor;
    input [31:0] rfsh_prd;
    input [3:0] rfsh_burst_len;
    begin
      rfsh_burst_length = rfsh_burst_len;
      rfsh_mnt_en    = 1'b1;
      xpctd_rfsh_prd = rfsh_prd;
      rfsh_burst     = 1'b0;
      rfsh_time      = $realtime;
      next_xpctd_cmd = `PRECHARGE_ALL;
      no_of_rfsh     = 0;
      no_of_pre_all  = 0;
      got_one_refresh = 1'b0;
    end
  endtask // enable_rfsh_monitor
  
  task disable_rfsh_monitor;
    begin
      rfsh_mnt_en = 1'b0;
    end
  endtask // disable_rfsh_monitor

  
  task enable_mpr_monitor;
    begin
      mpr_mnt_en = 1'b1;
    end
  endtask // enable_mpr_monitor

  task disable_mpr_monitor;
    begin
      mpr_mnt_en = 1'b0;
    end
  endtask // disable_mpr_monitor

  
  // get number of refreshes scheduled out
  function [31:0] scheduled_refreshes;
    input dummy;
    begin
      scheduled_refreshes = no_of_pre_all;
    end
  endfunction // scheduled_refreshes


  // register parameters
  assign ddr4_mode  = `GRM.ddr4_mode;
  assign ddr3_mode  = `GRM.ddr3_mode;
  assign lpddr3_mode  = `GRM.lpddr3_mode;
  assign lpddr2_mode  = `GRM.lpddr2_mode;
  assign ddr_8_bank = `GRM.ddr_8_bank;
  assign ddr_16_bank = `GRM.ddr_16_bank;
  assign t_mrd      = `GRM.t_mrd;
  assign t_mod      = 12 + `GRM.dtpr1[4:2];
  assign t_rp       = `GRM.t_rp;
  assign t_rfc      = `GRM.t_rfc;


  
  //---------------------------------------------------------------------------
  // Functional coverage sampling block for all the DDR SDRAm signals 
  //---------------------------------------------------------------------------
  // monitors all the signals on the DDR SDRAM interface
  always @(posedge ck)
    begin: fcov_monitor

`ifdef DDR4
      `FCOV.set_cov_ddr_sdram_inf_signals(cke,odt,cs_n,a[16],a[15],a[14],ba,a,dm,dqs,dqs_n,dq);
`else      
      `FCOV.set_cov_ddr_sdram_inf_signals(cke,odt,cs_n,ras_n,cas_n,we_n,ba,a,dm,dqs,dqs_n,dq);
`endif
      
    end //fcov_monitor
  
  
  //---------------------------------------------------------------------------
  // MPR mode monitor - checks that only RD commands are issued during MPR mode
  //---------------------------------------------------------------------------

  initial begin
    mpr_mode = 1'b0;

`ifdef DWC_LOOP_BACK
    mpr_mnt_en = 1'b0;
`else    
    mpr_mnt_en = 1'b1;
`endif
    
  end


  // sample cke at Chip level for ckep
  generate
    genvar rank_idx;
    for (rank_idx=0; rank_idx < `DWC_PHY_CKE_WIDTH; rank_idx=rank_idx+1) begin : gen_ckep

      if (`DWC_PHY_CKE_WIDTH > 1) begin: gen_ckep_ranks
        // for rdimm mode, there are only cke[1:0] 
        assign  cke_chip[rank_idx] = (`PUB.rdimm)? ((rank_idx==2 || rank_idx==0)? `CHIP.cke[0] : `CHIP.cke[1]) :
                                                   `CHIP.cke[rank_idx]; 
      end else begin: gen_ckep_ranks 
        assign  cke_chip[rank_idx] = (`PUB.rdimm)? ((rank_idx==2 || rank_idx==0)? `CHIP.cke[0] : `CHIP.cke[0]) :
                                                   `CHIP.cke[rank_idx]; 
      end
                            
      always @(posedge `CHIP.ck[0]) begin
        ckep_chip[rank_idx] <= cke_chip[rank_idx];
      end

    end
  endgenerate

`ifndef GATE_LEVEL_SIM
`ifndef DWC_DDRPHY_BUILD  
  // When there's an MRS command, check if it is an MR3 write to set MPR mode
`ifdef DWC_AC_CS_USE
`ifdef DWC_AC_BA_USE    
`ifdef DWC_AC_BG_USE    
  always @(posedge `PHY.ck[0]) begin
`ifdef DDR4
    if (`GRM.lpddrx_mode != 1'b1 && ({(`PHY.cs_n[rank_no]), `SYS.dbg_phy_sdram_ddr4_cmd[3:0]} == 5'b01000)) begin
`else
    if (`GRM.lpddrx_mode != 1'b1 && ({(`PHY.cs_n[rank_no]), `SYS.dbg_phy_sdram_cmd[2:0]     } == 4'b0000 )) begin
`endif

      if (   (`PHY.ba[1:0] == 2'b11 && mnt_en==1'b1)
`ifdef DDR4
          && (`PHY.bg[0] == 1'b0)  // Ensure it's MR3, not MR7
`endif
         ) begin
        if      (`PHY.a[2] == 1'b1) mpr_mode <= 1'b1;
        else if (`PHY.a[2] == 1'b0) mpr_mode <= 1'b0;
`ifdef DDR4
        mpr_page      = `PHY.a[1:0];
        mpr_rd_format = `PHY.a[12:11];
`endif
      end
    end
  end
`endif
`endif
`endif

  // In MPR mode, disallow any commands other than READ, NOP and MRS (to clear MPR mode)
  always @(posedge `TB.ck[0]) begin
    if (mpr_mode && mpr_mnt_en) begin
      if (   !(`SYS.dbg_phy_sdram_cmd_RD )      // READ
          && !(`SYS.dbg_phy_sdram_cmd_NOP)      // NOP
          && !(    (`SYS.dbg_phy_sdram_cmd_MRS) // MRS
`ifndef DDR4
`ifdef DWC_AC_BA_USE    
          && (`PHY.ba[1:0] == 2'b11) && (`PHY.a[2] == 1'b0)   // MR3 clear MPR mode
`else          
          && 1'b1
`endif
`endif
              )
`ifdef DWC_AC_CS_USE
          && !({`PHY.cs_n[rank_no], ckep_chip[rank_no], cke_chip[rank_no]} == 3'b111)   
`else
          && !({ckep_chip[rank_no], cke_chip[rank_no]} == 2'b11)   
`endif
             
`ifdef DDR4
          && !(`SYS.dbg_phy_sdram_cmd_WR)                                  // WRITE
          && !(`SYS.dbg_phy_sdram_cmd_REF)                                 // REFRESH
          && !(`SYS.dbg_phy_sdram_cmd_DES)                                 // DESELECT
          && !(   !(`SYS.dbg_phy_sdram_mr0_bl_otf)                         // no BL on-the-fly
               ||  (`SYS.dbg_phy_sdram_mr0_bl_otf && a[12] == 1'b1)  //  OR BL8 only
              )
`endif
         )
      begin
        `SYS.error;
        -> e_MPR_mode_commands_error;

`ifdef DWC_AC_CS_USE
`ifdef DDR4
      $display("-> %0t: ==> ERROR: [RANK %0d] Only RD/RDA/WR/WRA/MRS/DES/REF/Reset commands allowed during MPR mode (got %b instead)", $realtime, rank_no, {(`PHY.cs_n[rank_no]), `SYS.dbg_phy_sdram_ddr4_cmd[2:0]});
`else
      $display("-> %0t: ==> ERROR: [RANK %0d] Only READ/NOP/MR3-clear-MPR commands allowed during MPR mode (got %b instead)", $realtime, rank_no, {(`PHY.cs_n[rank_no]), `SYS.dbg_phy_sdram_cmd[2:0]});
`endif
`endif

      end
`ifdef DDR4
      // Only MPR page 0 supports all read formats; pages 1, 2 & 3 support
      // only serial output format
      if (`SYS.dbg_phy_sdram_cmd_RD && (mpr_rd_format != 2'b00) && (mpr_page != 0)) begin
        `SYS.error;
        $display("-> %0t: ==> ERROR: [RANK %0d] MPR Read Format 'b%b not allowed with MPR page %0d", $realtime, rank, mpr_rd_format, mpr_page);
      end
`endif
    end
  end
`endif // `ifndef DWC_DDRPHY_BUILD
`endif // `ifndef GATE_LEVEL_SIM     

  event read_event;

  //---------------------------------------------------------------------------
  // Command Monitor
  //---------------------------------------------------------------------------
  // monitors the commands being sent to the DDR SDRAMs
  always @(posedge ck)
    begin: monitor_command

      integer cmd_type;
      integer i;
      integer cmd2cmd_clks;
      reg [31:0] rw_op;
      reg [3:0]  cmd_burst_len;

      reg [`ADDR_WIDTH-1:0] addr;
      reg [0:3] ca0_3;

      reg                   ckep;
      reg                   cs_np;
      reg                   cke;
      reg                   odt;
      reg                   cs_n;
      reg                   act_n;
      reg                   ras_n;
      reg                   cas_n;
      reg                   we_n;
`ifdef LPDDR2
      reg [2:0]             ba;
      reg [15:0]            a;
`else
    `ifdef LPDDR3
      reg [2:0]             ba;
      reg [15:0]            a; //DDRG2MPHY: Need to check again as LPDDR3has only 10 address
    `else
      reg [`BANK_WIDTH-1:0] ba;
      reg [`ADDR_WIDTH-1:0] a;
    `endif
`endif

      reg [`SDRAM_BANK_WIDTH-1:0] ba_tmp;
      reg [`HOST_DQS_WIDTH-1:0]   dm_tmp;
      reg [pNUM_LANES_X2-1:0] dm;
      reg [pNUM_LANES_X2-1:0] dqs;
      reg [pNUM_LANES_X2-1:0] dqs_n;
      reg [`DATA_WIDTH-1:0] dq;

      // monitor DDR commands 
      // (don't monitor when random address/command are sent during AC
      // loopback mode only testcases)
      if (mnt_en === 1'b1 && `SYS.tc_ac_lb_only == 1'b0)
        begin
          // decode the selected banks for read/write
          clear_error_flags;

          // decode the command: different commands are decoded at different
          // stages so that all the data for read/write is available
          
          // single data rate signals: valid on first clock of command
          ckep  = ckep_ck[rw_len-1];
          cke   = cke_ck [rw_len-1];
          odt   = odt_ck [rw_len-1];
          cs_np = cs_np_ck[rw_len-1];
          cs_n  = cs_n_ck [rw_len-1];


          if (`GRM.lpddrx_mode) begin
            ras_n = a_ck [rw_len-1][0];
            cas_n = a_ck [rw_len-1][1];
            we_n  = a_ck [rw_len-1][2];
            ba    = a_ck [rw_len-1][9:7];
            a     = {a_ck_n[rw_len-1][9:1], a_ck[rw_len-1][6:5], 1'b0};

            ca0_3[0] = a_ck[rw_len-1][0];
            ca0_3[1] = a_ck[rw_len-1][1];
            ca0_3[2] = a_ck[rw_len-1][2];
            ca0_3[3] = a_ck[rw_len-1][3];
          
            // decode command
            cmd_type = OTHER_CMD;

            casez ({ckep, cke, cs_n, ca0_3})
              7'bx0?_????, 7'b001_????, 7'b000_?111: 
                begin
                  op = `SDRAM_NOP;
                end
              7'b110_000?:
                begin
                  op = (ca0_3[3]) ? `READ_MODE : `LOAD_MODE;
                  a  = {a_ck_n[rw_len-1][9:0], a_ck[rw_len-1][9:4]};
                  ba = a_ck[rw_len-1][6:4]; // mode register 3 LSBs (for init check)
                end
              7'b110_0010, 7'b110_0011:
                begin
                  op = `REFRESH;
                  // We got a refresh, so set the got_one_refresh flag for all eternity
                  got_one_refresh = 1'b1;
                end
              7'b100_001?:
                begin
                  op = `SELF_REFRESH;
                  self_rfsh_mode = 1'b1;
                end
              7'b110_01??: 
                begin
                  op = `ACTIVATE;
                  a = {a_ck_n[rw_len-1][9:8], a_ck[rw_len-1][6:2], a_ck_n[rw_len-1][7:0]};
                end
              7'b110_100?:
                begin

                  op = (a_ck_n[rw_len-1][0] === 1'b1) ? `WRITE_PRECHG : `SDRAM_WRITE;
                  cmd_type = WRITE_CMD;
                  ->sdram_write_event;
                  bl4_otf_wr = `GRM.ddr3_blotf & ~a[12];
                end
              7'b110_101?:
                begin
                  op = (a_ck_n[rw_len-1][0] === 1'b1) ? `READ_PRECHG : `SDRAM_READ;
                  cmd_type = READ_CMD;
                  bl4_otf_rd = `GRM.ddr3_blotf & ~a[12];
                end            
              7'b110_1101: op = (a_ck[rw_len-1][4] === 1'b1) ? `PRECHARGE_ALL : `PRECHARGE;
              7'b110_1100: op = `TERMINATE;
              7'b110_111?: op = `SDRAM_NOP;
              7'b111_????: op = `SDRAM_NOP;
//ROB-need to determine how to identify this code!
//              7'b100_110?:
//                begin
//                  op = `DEEP_POWER_DOWN;
//                  power_down_mode = 1'b1;
//                end
              7'b101_????:
                begin
                  op = `POWER_DOWN;
                  power_down_mode = 1'b1;
                end
              7'b011_????:
                    begin
                      if (self_rfsh_mode === 1'b1)
                        begin
                          op = `SELF_RFSH_EXIT;
                        end
                      else if (power_down_mode === 1'b1)
                        begin
                          op = `POWER_DWN_EXIT;
                        end
                      self_rfsh_mode  = 1'b0;
                      power_down_mode = 1'b0;
                    end
            endcase // case({ckep, cke, cs_n, ras_n, cas_n, we_n})
          end else begin // if (`GRM.lpddrx_mode)
            if (`GRM.ddr4_mode) begin
`ifdef DDR4              
              act_n = act_n_ck[rw_len-1];
              ras_n = (act_n_ck[rw_len-1]==1'b0)? 1'b0 :  a_ck[rw_len-1][16];
              cas_n = (act_n_ck[rw_len-1]==1'b0)? 1'b1 :  a_ck[rw_len-1][15];
              we_n  = (act_n_ck[rw_len-1]==1'b0)? 1'b1 :  a_ck[rw_len-1][14];
              ba    = ba_ck  [rw_len-1];
              //a     = (act_n_ck[rw_len-1]==1'b0)? {a_ck[rw_len-1][17], ras_n_ck[rw_len-1], cas_n_ck[rw_len-1], we_n_ck[rw_len-1], a_ck[rw_len-1][13:0]} : 
              //                                    {1'b0, a_ck[rw_len-1][13:0]}; // a[17] is act_n, a[16:14] is ras_n, cas_n and we_n
              a     = (act_n_ck[rw_len-1]==1'b0)? {a_ck[rw_len-1][17], a_ck[rw_len-1][16:0]} : 
                                                  {1'b0, a_ck[rw_len-1][13:0]}; // a[17] is act_n, a[16:14] is ras_n, cas_n and we_n
`endif
            end
            else begin
              ras_n = ras_n_ck[rw_len-1];
              cas_n = cas_n_ck[rw_len-1];
              we_n  = we_n_ck [rw_len-1];
              ba    = ba_ck  [rw_len-1];
              a     = a_ck   [rw_len-1];
            end
            
            // decode command
            cmd_type = OTHER_CMD;

`ifdef DDR4
            casez ({act_n, ckep, cke, cs_n, ras_n, cas_n, we_n})
`else            
            casez ({ckep, cke, cs_n, ras_n, cas_n, we_n})
`endif
              LOAD_MODE:      op = `LOAD_MODE;
              REFRESH:
                begin
                  op = `REFRESH;
                  // We got a refresh, so set the got_one_refresh flag for all eternity
                  got_one_refresh = 1'b1;
                end
              SELF_REFRESH:
                begin
                  op = `SELF_REFRESH;
                  self_rfsh_mode = 1'b1;
                end
              PRECHARGE:      op = (a[10] === 1'b1) ?
                                   `PRECHARGE_ALL : `PRECHARGE;
              ACTIVATE:       op = `ACTIVATE;
              WRITE:
                begin
                  op = (a[10] === 1'b1) ? `WRITE_PRECHG : `SDRAM_WRITE;
                  cmd_type = WRITE_CMD;
                  ->sdram_write_event;
                  bl4_otf_wr = `GRM.ddr3_blotf & ~a[12];
                end
              READ:
                begin
                  op = (a[10] === 1'b1) ? `READ_PRECHG : `SDRAM_READ;
                  cmd_type = READ_CMD;
                  bl4_otf_rd = `GRM.ddr3_blotf & ~a[12];
                end            
              ZQCAL:          op = (a[10] === 1'b1) ? `ZQCAL_LONG : `ZQCAL_SHORT;
              NOP,
                CLOCK_DISABLE:  op = `SDRAM_NOP;
              DESELECT:       op = (cs_np == 1'b0) ? `DESELECT : `SDRAM_NOP;
`ifndef DDR4
              POWER_DOWN_2,
`endif                
              POWER_DOWN:
                begin
                  op = `POWER_DOWN;
                  power_down_mode = 1'b1;
                end
`ifndef DDR4
              POWER_DWN_EXIT_2,
`endif
              POWER_DWN_EXIT,
              SELF_RFSH_EXIT_2,  
              SELF_RFSH_EXIT:
                begin
                  if (self_rfsh_mode === 1'b1)
                    begin
                      op = `SELF_RFSH_EXIT;
                    end
                  else if (power_down_mode === 1'b1)
                    begin
                      op = `POWER_DWN_EXIT;
                    end
                  self_rfsh_mode  = 1'b0;
                  power_down_mode = 1'b0;
                end
            endcase // case({ckep, cke, cs_n, ras_n, cas_n, we_n})
          end // else: !if(`GRM.lpddrx_mode)
          
          
          // report monitor
          if (op === `SDRAM_NOP)
            begin
              if (nop_mnt_en) nop_cnt = nop_cnt + 1;
            end
          else
            begin
              // report previous NOPs
              if (nop_mnt_en == 1'b1 && nop_cnt > 0)
                begin
                  `SYS.message(`CTRL_SDRAM, `CTRL_NOP, {1'b1, nop_cnt, rank});
                  nop_cnt = 0;
                end
              
              // report current operation
              // transaction monitor: report all info about a transaction in
              // one line; also check and report undefined values
              if (cmd_type != OTHER_CMD)
                begin
                  // read and write commands
                  rw_op = op;
                  if (`GRM.lpddrx_mode) begin
                    cmd_burst_len = get_effective_burst_length(rw_op);
                  end else begin
                    cmd_burst_len = burst_len;
                  end

                  if (op == `SDRAM_WRITE || op == `WRITE_PRECHG) begin
                    if  (`GRM.ddr4_mode || `GRM.ddr3_mode || `GRM.lpddrx_mode) begin
                      data_start = wl_diff;
                      data_end   = cmd_burst_len+data_start-1;
                      data_start = data_start + 2*bl4_otf_wr;
                    end
                    else begin
                      data_start = cmd_type;
                      if (ddr4_mode || ddr3_mode) data_start = data_start + rl_diff;
                      if (bl4_otf_wr) begin
                          data_end   = 2+data_start;
                          data_start = data_start+1;
                      end
                      else begin
                          data_end   = cmd_burst_len+data_start-1;
                          data_start = data_start;
                      end
                    end
                  end    // if (op= ...

                  else begin
                    // bl=4 or otf (and selected 4)
                    if (bl4_otf_rd || `GRM.bl==5'b00100 ) begin 
                      data_end   = 1;
                      data_start = 0;
                    end
                    else begin
                      // bl=16
                      if (`GRM.bl==5'b10000) begin
                        // For LPDDR2 and training, bl=16 is trained at BL=8, so reduce the data_end position
                        if (`PUB.phy_train === 1'b1 && `GRM.lpddr2_mode && `GRM.sdr_burst_len == 8) begin
                          data_end   = 3;
                          data_start = 0;
                        end
                        else begin
                          data_end   = 7;
                          data_start = 0;
                        end
                      end
                      else begin
                        // bl=2
                        if (`GRM.bl==5'b00010) begin
                          data_end   = 0;
                          data_start = 0;
                        end
                        // bl=8
                        else begin
                          data_end   = 3;
                          data_start = 0;
                        end
                      end
                    end
                    
                    ->read_event;
                  end

                  for (i=data_end; i>=data_start; i=i-1)
                    begin
                      dm     = {dm_ck_n[i],   dm_ck[i]};
                      if (bl4_otf_rd && cmd_type == READ_CMD)
                        begin
                          dqs    = {dqs_ck_n[i+2],  dqs_ck[i+2]};
                          dqs_n  = {dqs_n_ck_n[i+2], dqs_n_ck[i+2]};
                        end
                      else
                        begin
                          dqs    = {dqs_ck_n[i],  dqs_ck[i]};
                          dqs_n  = {dqs_n_ck_n[i], dqs_n_ck[i]};
                        end

                      // READ_CMD from q_qs and q_qsb is indexed according to qs_edge, no need to use i+2 for bl4_otf_rd
                      dq     = (cmd_type == WRITE_CMD) ? 
                               {d_ck_n[i],   d_ck[i]} : {q_qsb[i],   q_qs[i]};

                      if (`SYS.verbose > 10) begin
                        if (cmd_type == READ_CMD)
                          $display("-> %0t: [RANK %0d] ==> cmd_type is  READ_CMD",  $realtime, rank_no);
                        if (cmd_type == WRITE_CMD)
                          $display("-> %0t: [RANK %0d] ==> cmd_type is  WRITE_CMD",  $realtime, rank_no);

                        $display("-> %0t: [RANK %0d] ==> bl    = %0d",  $realtime, rank_no, `GRM.bl);
                        $display("-> %0t: [RANK %0d] ==> i     = %0d",  $realtime, rank_no, i);
                        $display("-> %0t: [RANK %0d] ==> dqs   = %0h",  $realtime, rank_no, dqs);
                        $display("-> %0t: [RANK %0d] ==> dqs_n = %0h",  $realtime, rank_no, dqs_n);
                        $display("-> %0t: [RANK %0d] ==> dq    = %0h",  $realtime, rank_no, dq);
                        $display("-> %0t: [RANK %0d] ==> bl4_otf_rd = %0h",  $realtime, rank_no, bl4_otf_rd);

                        if (cmd_type == READ_CMD) begin
                          $display("-> %0t: [RANK %0d] ==> dqs_ck[%0d] = %0h",  $realtime, rank_no, i+5, dqs_ck[i+5]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck[%0d] = %0h",  $realtime, rank_no, i+4, dqs_ck[i+4]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck[%0d] = %0h",  $realtime, rank_no, i+3, dqs_ck[i+3]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck[%0d] = %0h",  $realtime, rank_no, i+2, dqs_ck[i+2]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck[%0d] = %0h",  $realtime, rank_no, i+1, dqs_ck[i+1]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck[%0d] = %0h",  $realtime, rank_no, i+0, dqs_ck[i+0]);
                          $display("-> %0t: [RANK %0d] ---------------------",  $realtime, rank_no);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck_n[%0d] = %0h",  $realtime, rank_no, i+5, dqs_ck_n[i+5]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck_n[%0d] = %0h",  $realtime, rank_no, i+4, dqs_ck_n[i+4]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck_n[%0d] = %0h",  $realtime, rank_no, i+3, dqs_ck_n[i+3]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck_n[%0d] = %0h",  $realtime, rank_no, i+2, dqs_ck_n[i+2]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck_n[%0d] = %0h",  $realtime, rank_no, i+1, dqs_ck_n[i+1]);
                          $display("-> %0t: [RANK %0d] ==> dqs_ck_n[%0d] = %0h",  $realtime, rank_no, i+0, dqs_ck_n[i+0]);
                          $display("-> %0t: [RANK %0d] ---------------------",  $realtime, rank_no);
                          $display("-> %0t: [RANK %0d] ==> q_qs[%0d] = %0h",  $realtime, rank_no, i+5, q_qs[i+5]);
                          $display("-> %0t: [RANK %0d] ==> q_qs[%0d] = %0h",  $realtime, rank_no, i+4, q_qs[i+4]);
                          $display("-> %0t: [RANK %0d] ==> q_qs[%0d] = %0h",  $realtime, rank_no, i+3, q_qs[i+3]);
                          $display("-> %0t: [RANK %0d] ==> q_qs[%0d] = %0h",  $realtime, rank_no, i+2, q_qs[i+2]);
                          $display("-> %0t: [RANK %0d] ==> q_qs[%0d] = %0h",  $realtime, rank_no, i+1, q_qs[i+1]);
                          $display("-> %0t: [RANK %0d] ==> q_qs[%0d] = %0h",  $realtime, rank_no, i+0, q_qs[i+0]);
                          $display("-> %0t: [RANK %0d] ---------------------",  $realtime, rank_no);
                          $display("-> %0t: [RANK %0d] ==> q_qsb[%0d] = %0h",  $realtime, rank_no, i+5, q_qsb[i+5]);
                          $display("-> %0t: [RANK %0d] ==> q_qsb[%0d] = %0h",  $realtime, rank_no, i+4, q_qsb[i+4]);
                          $display("-> %0t: [RANK %0d] ==> q_qsb[%0d] = %0h",  $realtime, rank_no, i+3, q_qsb[i+3]);
                          $display("-> %0t: [RANK %0d] ==> q_qsb[%0d] = %0h",  $realtime, rank_no, i+2, q_qsb[i+2]);
                          $display("-> %0t: [RANK %0d] ==> q_qsb[%0d] = %0h",  $realtime, rank_no, i+1, q_qsb[i+1]);
                          $display("-> %0t: [RANK %0d] ==> q_qsb[%0d] = %0h",  $realtime, rank_no, i+0, q_qsb[i+0]);
                          
                        end
                      end // if (`SYS.verbose > 10)
                      
                      
                      if (`SDRAM_COL_WIDTH <= 10)
                        addr = {bank_row[ba], a[`SDRAM_COL_WIDTH-1:0]};
                      if (`SDRAM_COL_WIDTH == 11)
                        addr = {bank_row[ba], a[`SDRAM_COL_WIDTH], a[9:0]};
                      if (`SDRAM_COL_WIDTH == 12)
                        addr = {bank_row[ba], a[13], a[11], a[9:0]};

                      ba_tmp[`SDRAM_BANK_WIDTH-1:0] = ba;
                      dm_tmp[`HOST_DQS_WIDTH-1:0]   = { {(`HOST_DQS_WIDTH-pNUM_LANES_X2){1'bx}},dm };

                      `SYS.message(`CTRL_SDRAM, rw_op, {dq, dm_tmp, addr, ba_tmp, rank});
                      if (undf_mnt_en == 1'b1)
                        begin
                          check_undefined(op, ba, a, dm, dqs, dqs_n, dq);
                        end

                      // change the operation type to burst type
                      if (i == data_end)
                        begin
                          case (op)
                            `SDRAM_WRITE:  rw_op = `WRITE_BRST;
                            `WRITE_PRECHG: rw_op = `WRITE_PRECHG_BRST;
                            `SDRAM_READ:   rw_op = `READ_BRST;
                            `READ_PRECHG:  rw_op = `READ_PRECHG_BRST;
                          endcase // case(op)
                        end
                      begin
                        case (op)
                          `SDRAM_WRITE:  ->sdram_write_event;
                          `WRITE_PRECHG: ;
                          `SDRAM_READ:   ;
                          `READ_PRECHG:  ;
                        endcase // case(op)
                      end
                    end // for (i=data_end; i>=data_start; i=i-1)
                  all_banks_closed = 1'b0;
                end // if (cmd_type != OTHER_CMD)
              else
                begin
                  // save the open row for each bank
                  if (op == `ACTIVATE)
                    begin
                      bank_row[ba] = a;
                      addr = {bank_row[ba], {`SDRAM_COL_WIDTH{1'b0}}};
                    end
                  else
                    begin
                      addr = a;
                      if (op == `POWER_DOWN) addr[0] = all_banks_closed;
                    end

                  if (op == `PRECHARGE_ALL)
                    begin
                      all_banks_closed = 1'b1;
                    end
                  
                  ba_tmp[`SDRAM_BANK_WIDTH-1:0] = ba;
                  dm_tmp[`HOST_DQS_WIDTH-1:0]   = {{(`HOST_DQS_WIDTH-pNUM_LANES_X2){1'bx}},dm};

                  `SYS.message(`CTRL_SDRAM, op, {dq, dm_tmp, addr, ba_tmp, rank});
                  if (undf_mnt_en == 1'b1)
                    begin
                      check_undefined(op, ba_tmp, a, dm, dqs, dqs_n, dq);
                    end
                end // else: !if(cmd_type != OTHER_CMD)

              // monitor initialization sequence and auto-refresh bursts
              // NOTE: a DESELECT command is also allowed as an alternative to
              //       a NOP during the initialization wait time prior to the 
              //       first command
              if (init_mnt_en === 1'b1)
                begin
                  if (!(op === `DESELECT))
                    begin
                      log_init_command(op, ba, a);
                    end
                end

              if (rfsh_mnt_en === 1'b1 &&
                  (op === `PRECHARGE_ALL || op === `REFRESH ||
                   rfsh_burst == 1'b1 ))
                begin
                  // log in and verify auto-refreshes
                  log_rfsh_command(op);
                end
            end // else: !if(op === `SDRAM_NOP)

          // If refresh monitoring is enabled
          if (rfsh_mnt_en == 1'b1)
            if ( got_one_refresh == 1'b0 )
              begin
                cmd2cmd_clks = ($realtime - rfsh_time)/(`SYS.tCLK_PRD);
                if (cmd2cmd_clks > (xpctd_rfsh_prd + `RFSH_PRD_TOL))
                  begin
                    `SYS.error_message(`CTRL_SDRAM, `RFSHNEVER, xpctd_rfsh_prd + `RFSH_PRD_TOL);
                    // We only need one error, really
                    // The periodic monitor will take care of the rest
                    got_one_refresh = 1'b1;
                  end
              end

          // report errors
          report_errors;
        end // if (mnt_en === 1'b1)

      
    end // block: monitor_command
  
  
  // effective burst length
  // ----------------------
  // get the effctive burst length of the read or write is terminated
  function [3:0] get_effective_burst_length;
    input [31:0] rw_op;
    
    integer i, j;
    reg [3:0] rw_burst_len;
    begin
      // search if there is a burst terminate command within the burst
      // length time slot
      rw_burst_len = burst_len;
      for (i=1; i<burst_len; i=i+1) begin
        j = rw_len-1 - i;
        if (`GRM.lpddrx_mode) begin
          casez ({ckep_ck[j], cke_ck[j], cs_n_ck[j], a_ck[j][0], a_ck[j][1], a_ck[j][2], a_ck[j][3]})
            7'b110_100?, // write
            7'b110_101?, // read
            7'b110_1101, // precharge
            7'b110_1100: // burst terminate
              begin
                rw_burst_len = i;
                i = burst_len; // halt search
              end
          endcase // casez ({ckep_ck[j], cke_ck[j], 
        end else begin
`ifdef DDR4          
          casez ({act_n_ck[j], ckep_ck[j], cke_ck[j], cs_n_ck[j], ras_n_ck[j], cas_n_ck[j], we_n_ck[j]})
`else
          casez ({ckep_ck[j], cke_ck[j], cs_n_ck[j], ras_n_ck[j], cas_n_ck[j], we_n_ck[j]})
`endif
            WRITE,     // write
            READ,      // read
            PRECHARGE, // precharge
            TERMINATE: // burst terminate
              begin
                rw_burst_len = i;
                i = burst_len; // halt search
              end
          endcase // casez ({ckep_ck[j], cke_ck[j],
        end
      end
      get_effective_burst_length = rw_burst_len;
    end
  endfunction // get_effective_burst_length


  //---------------------------------------------------------------------------
  // Data Monitor
  //---------------------------------------------------------------------------

  // signal pipeline
  // ---------------
  // used for delayed reporting so that all data is available for a transaction
  // before it is reported
  // CK pipeline
  always @(posedge ck or negedge rst_n)
    begin: ck_pipeline
      integer i;
      
      if (rst_n == 1'b0)
        begin
          for(i=0; i<MAX_RW_LEN; i=i+1)
            begin
              ckep_ck[i]   <= 1'b0;
              cke_ck[i]    <= 1'b0;
              odt_ck[i]    <= 1'b0;
              cs_np_ck[i]  <= 1'b1;
              cs_n_ck[i]   <= 1'b1;
`ifdef DDR4
              act_n_ck[i]  <= 1'b1;
`endif
              ras_n_ck[i]  <= 1'b1;
              cas_n_ck[i]  <= 1'b1;
              we_n_ck[i]   <= 1'b1;           
              ba_ck[i]     <= {pBANK_WIDTH{1'b0}};
              a_ck[i]      <= {pADDR_WIDTH{1'b0}};
              
              dm_ck[i]     <= {pNUM_LANES{1'b0}};
              dqs_ck[i]    <= {pNUM_LANES{1'b0}};
              dqs_n_ck[i]  <= {pNUM_LANES{1'b1}};
              d_ck[i]      <= {pDATA_WIDTH{1'b0}};
            end

          ckep <= 1'b0;
        end
      else
        begin
          // update pipeline
          for(i=1; i<MAX_RW_LEN; i=i+1)
            begin
              ckep_ck[i]   <= ckep_ck[i-1];
              cke_ck[i]    <= cke_ck[i-1];
              odt_ck[i]    <= odt_ck[i-1];
              cs_np_ck[i]  <= cs_np_ck[i-1];
              cs_n_ck[i]   <= cs_n_ck[i-1];
`ifdef DDR4
              act_n_ck[i]  <= act_n_ck[i-1];
`endif
              ras_n_ck[i]  <= ras_n_ck[i-1];
              cas_n_ck[i]  <= cas_n_ck[i-1];
              we_n_ck[i]   <= we_n_ck[i-1];
              ba_ck[i]     <= ba_ck[i-1];
              a_ck[i]      <= a_ck[i-1];
              
              dm_ck[i]     <= dm_ck[i-1];
              dqs_ck[i]    <= dqs_ck[i-1];
              dqs_n_ck[i]  <= dqs_n_ck[i-1];
              d_ck[i]      <= d_ck[i-1];
            end

          ckep_ck[0]   <= ckep;
          cke_ck[0]    <= cke;
          odt_ck[0]    <= odt;
          cs_np_ck[0]  <= cs_np;
          cs_n_ck[0]   <= cs_n;
`ifdef DDR4
          act_n_ck[0]  <= act_n;
          ras_n_ck[0]  <= a[16];
          cas_n_ck[0]  <= a[15];
          we_n_ck[0]   <= a[14];
`else
          ras_n_ck[0]  <= ras_n;
          cas_n_ck[0]  <= cas_n;
          we_n_ck[0]   <= we_n;
`endif
          ba_ck[0]     <= ba;
          a_ck[0]      <= a;
          
          dm_ck[0]     <= dm;
          dqs_ck[0]    <= dqs;
          dqs_n_ck[0]  <= dqs_n;
          d_ck[0]      <= dq;

          // register previous value of CKE ans CS#
          ckep  <= cke;
          cs_np <= cs_n;
        end // else: !if(rst_n == 1'b0)
    end // block: ck_pipeline

  // CK# pipeline
  always @(posedge ck_n or negedge rst_n)
    begin: ck_n_pipeline
      integer i;
      
      if (rst_n == 1'b0)
        begin
          for(i=0; i<MAX_RW_LEN; i=i+1)
            begin
              if (`GRM.lpddrx_mode) begin
                a_ck_n[i]    <= {pADDR_WIDTH{1'b0}};
              end
              dm_ck_n[i]     <= {pNUM_LANES{1'b0}};
              dqs_ck_n[i]    <= {pNUM_LANES{1'b0}};
              dqs_n_ck_n[i]  <= {pNUM_LANES{1'b1}};
              d_ck_n[i]      <= {pDATA_WIDTH{1'b0}};
            end
        end
      else
        begin
          // update pipeline
          for(i=1; i<MAX_RW_LEN; i=i+1)
            begin
              if (`GRM.lpddrx_mode) begin
                a_ck_n[i]    <= a_ck_n[i-1];
              end
              dm_ck_n[i]     <= dm_ck_n[i-1];
              dqs_ck_n[i]    <= dqs_ck_n[i-1];
              dqs_n_ck_n[i]  <= dqs_n_ck_n[i-1];
              d_ck_n[i]      <= d_ck_n[i-1];
            end

          if (`GRM.lpddrx_mode) begin
            a_ck_n[0]    <= a;
          end
          
          dm_ck_n[0]     <= dm;
          dqs_ck_n[0]    <= dqs;
          dqs_n_ck_n[0]  <= dqs_n;
          d_ck_n[0]      <= dq;
        end
    end

    // additional read enable to allow for a read command to sample dq only
    // when rl count has been reached and for the duration of the burst length (4 or 8)
    // This is needed for DDR4 mode to screen off the preamble when sampling
    // dq into q_qs
`ifdef DDR4  
  wire rd_enable;
  reg [MAX_RW_LEN-1:0] rd_p;  initial rd_p = {MAX_RW_LEN{1'b0}};
  
  assign rd_cmd = (act_n==1)? (({cs_n,a[16:14]} == 4'b0101)? 1'b1: 1'b0) : 1'b0;

  always @(posedge ck) begin: rd_enable_a
    integer i;
    
    if (rst_n == 1'b0) begin
      for (i=MAX_RW_LEN-1; i>=0; i=i-1) begin
        rd_p[i] <= 0;
      end
    end
    else begin
      for (i=MAX_RW_LEN-1; i>0; i=i-1) begin
        rd_p[i-1] <= rd_p[i];
      end

      if (rd_cmd) begin
        rd_p[rl] <= 1'b1;
        rd_p[rl+1] <= 1'b1;
        if (a_12 || (burst_len==4'b0100)) begin
          rd_p[rl+2] <= 1'b1;
          rd_p[rl+3] <= 1'b1;
        end
      end
    end
  end

  assign rd_enable = rd_p[0];
          
`endif
  
    event qs_edge;
    reg qs_old;
  
    initial qs_old = 1'bz;

    always @(qs)
    begin
      if ((qs_old === 1'b0) && (qs === 1'b1)) begin
        ->qs_edge;
      end  
      qs_old <= qs;
    end  

  // QS pipeline (for read data)
  always @(qs_edge or negedge rst_n)
    begin: qs_pipeline
      integer i;
      
      if (rst_n == 1'b0)
        begin
          for(i=0; i<MAX_RW_LEN; i=i+1)
            begin
              q_qs[i]  <= {pDATA_WIDTH{1'b0}};
            end
        end
      else if (qs === 1'b1)
        begin
          // update pipeline
          for(i=1; i<MAX_RW_LEN; i=i+1)
            begin
              q_qs[i]  <= q_qs[i-1];
            end
`ifdef DDR4
          if (rd_enable)
            q_qs[0]  <= dq;
`else          
          q_qs[0]  <= dq;
`endif
        end
    end

    reg qsb_old;
    initial qsb_old = 1'bz;

    event qsb_edge;

    always @(qsb)
    begin
      if ((qsb_old === 1'b0) && (qsb === 1'b1)) begin
        ->qsb_edge;
      end  
      qsb_old <= qsb;
    end  


  // QS# pipeline (for read data)
//  always @(posedge qsb or negedge rst_n or (qsb !== 1'bz) )
  always @(qsb_edge or negedge rst_n)
    begin: qsb_pipeline
      integer i;
      
      if (rst_n == 1'b0)
        begin
          for(i=0; i<MAX_RW_LEN; i=i+1)
            begin
              q_qsb[i]  <= {pDATA_WIDTH{1'b0}};
            end
        end
      else if (qsb === 1'b1)
        begin
          // update pipeline
          for(i=1; i<MAX_RW_LEN; i=i+1)
            begin
              q_qsb[i]  <= q_qsb[i-1];
            end

`ifdef DDR4
          if (rd_enable)
            q_qsb[0]  <= dq;
`else          
          q_qsb[0]  <= dq;
`endif
        end
    end

  // data strobes used to latch the data is delay by 90 degrees since data 
  // comes out aligned with the strobes


  assign #(`SYS.tCLK_PRD/4.0) qs  = dqs;
  assign #(`SYS.tCLK_PRD/4.0) qsb = dqs_n;

  
  //---------------------------------------------------------------------------
  // Initialization Monitor
  //---------------------------------------------------------------------------
  // monitors and verifies that the controller/SDRAM initialization sequence
  // is correct
  task log_init_command;
    input [31:0]                op;
`ifdef LPDDR2
    input [2:0]             ba;
    input [15:0]            a;
`else
   `ifdef LPDDR3
      input [2:0]             ba;
      input [15:0]            a; //DDRG2MPHY: Need to check again as LPDDR3has only 10 address
   `else
      input [pBANK_WIDTH-1:0] ba;
      input [pADDR_WIDTH-1:0] a;
   `endif
`endif

    reg [3 :0] xpctd_ba;
    reg [17:0] xpctd_a [`DWC_NO_OF_RANKS-1:0];
    integer                     cmd2cmd_clks;
    integer                     cke2cmd_clks;
    integer extra_clk;
    integer rnk_idx;
    
    begin
      // check the command sequence
      if (op !== next_xpctd_cmd)
        begin
          `SYS.error_message(`CTRL_SDRAM, `INITCMDERR, {next_xpctd_reg, 
                                                        next_xpctd_cmd});
        end

      // check the command-to-command timing
      // NOTE: DDR transactions are reported delayed - use actual time
      // NOTE: initialization done by user software may incur one extra
      //       clock on command-to-command timing
      curr_time    = $realtime - rw_len*(`SYS.tCLK_PRD);
      cmd2cmd_clks = (curr_time - prev_time)/(`SYS.tCLK_PRD);
      cke2cmd_clks = (curr_time - prev_cke_time)/(`SYS.tCLK_PRD);

      //extra_clk    = (init_sw === 1'b1) ? 1 : 0;
      if (`GRM.lpddrx_mode && (no_of_load_mode == 1 || no_of_load_mode == 2)) begin
        extra_clk = 1;
      end else if ((xpctd_cmd_spacing%2)==1'b1) begin
        extra_clk    = 1; //for odd values add an extra clock (HDR)
      end
      
      
      if (( ddr3_mode && op == `LOAD_MODE && no_of_load_mode == 0) || 
          ( `GRM.lpddrx_mode && op == `LOAD_MODE && no_of_load_mode == 0) || 
          (!ddr3_mode && op == `PRECHARGE_ALL && no_of_pre_all == 0))
        begin
          // the 400ns wait is violated
          if ( `GRM.lpddrx_mode && `DWC_NO_SRA == 1) begin
            if (cmd2cmd_clks < xpctd_cmd_spacing ||
                cmd2cmd_clks > (xpctd_cmd_spacing + (100*pNO_OF_RANKS)))
              begin
                `SYS.error_message(`CTRL_SDRAM, `INITWAITERR, 1);
              end
          end else begin
            // first initialization command; the 400ns wait is violated
            if (cke2cmd_clks < xpctd_init_cke_spacing ||
                cke2cmd_clks > (xpctd_init_cke_spacing + 400))
              begin
                `SYS.error_message(`CTRL_SDRAM, `INITWAITERR, 1);
              end
          end
        end
      else if (dll_rst_wait)
        begin
          // next command should wait for DLL lock time (tDLLK)
          cmd2cmd_clks = (curr_time - dll_rst_time)/(`SYS.tCLK_PRD);

          if (cmd2cmd_clks < `tDLLK || cmd2cmd_clks > (`tDLLK+25))
            begin
              if (`DWC_NO_SRA == 0)
                `SYS.error_message(`CTRL_SDRAM, `INITWAITERR, 2);
              else begin
                // DWC_NO_SRA, might be a bit longer
                if (cmd2cmd_clks < `tDLLK)
                  `SYS.error_message(`CTRL_SDRAM, `INITWAITERR, 2);
                //else
                  // nothing to report on if larger
              end
            end
        end
      else if ((cmd2cmd_clks !== xpctd_cmd_spacing) &&
               (cmd2cmd_clks !== (xpctd_cmd_spacing+extra_clk)))
        begin
          if (`DWC_NO_SRA == 0)
            // general command-to-command timing violation
            `SYS.error_message(`CTRL_SDRAM, `CMDTIMEERR, xpctd_cmd_spacing);
          else begin
            if (`DWC_NO_SRA == 1 && cmd2cmd_clks < (xpctd_cmd_spacing/pNO_OF_RANKS) +extra_clk)
              // for NO_SRA, the bare minimium is xpctd_cmd_spacing without the rank multiplier,
              // if this is violated, flagged it as an error.
              `SYS.error_message(`CTRL_SDRAM, `CMDTIMEERR, xpctd_cmd_spacing/pNO_OF_RANKS);
            else begin
              if (`DWC_NO_SRA == 1 && cmd2cmd_clks >= xpctd_cmd_spacing+extra_clk) begin
                // nothing to report on
              end
              else begin
                $display("-> %0t: [RANK %0d] ==> Command to command spacing meeting the bare minimium spacing without mulitplying no of ranks", $realtime, rank_no);
                $display("-> %0t: [RANK %0d] ==> xpctd_cmd_spacing without rank = %0d",  $realtime, rank_no, xpctd_cmd_spacing/pNO_OF_RANKS);
                $display("-> %0t: [RANK %0d] ==> cmd2cmd_clks                   = %0d",  $realtime, rank_no, cmd2cmd_clks);
              end
            end
          end
        end

      // check initialization data/address
      xpctd_ba = next_xpctd_reg - `MR0_REG;
      
      if (op === `LOAD_MODE)
        begin
`ifdef LPDDR2
          // for LPDDR2 the ba is set to the mode register address
          case (no_of_load_mode)
            0: begin
              xpctd_ba = 3'b111; // MR63: but only lower there bits here
              xpctd_a[0]  = {8'h00, 8'h3F};
            end
            1: begin
              xpctd_ba = 3'b010; // MR10: but only lower there bits here
              xpctd_a[0]  = {8'hFF, 8'h0A};
            end
            2: begin
              xpctd_ba = 1; // MR1
              xpctd_a[0]  = {`GRM.mr1[0][7:0], 8'h01};
            end
            3: begin
              xpctd_ba = 2; // MR2
              xpctd_a[0]  = {`GRM.mr2[0][7:0], 8'h02};
            end
            4: begin
              xpctd_ba = 3; // MR3
              for(rnk_idx=0;rnk_idx<`DWC_NO_OF_RANKS;rnk_idx=rnk_idx+1)
                xpctd_a[rnk_idx]  = {`GRM.mr3[rnk_idx][7:0], 8'h03};
            end
          endcase // case(no_of_load_mode)
`else  
`ifdef LPDDR3
 
         // for LPDDR3 the ba is set to the mode register address
          case (no_of_load_mode)
            0: begin
              xpctd_ba = 3'b111; // MR63: but only lower there bits here
              xpctd_a[0]  = {8'h00, 8'h3F};
            end
            1: begin
              xpctd_ba = 3'b010; // MR10: but only lower there bits here
              xpctd_a[0]  = {8'hFF, 8'h0A};
            end
            2: begin
              xpctd_ba = 1; // MR1
              xpctd_a[0]  = {`GRM.mr1[0][7:0], 8'h01};
            end
            3: begin
              xpctd_ba = 2; // MR2
              xpctd_a[0]  = {`GRM.mr2[0][7:0], 8'h02};
            end
            4: begin
              xpctd_ba = 3; // MR3
              for(rnk_idx=0;rnk_idx<`DWC_NO_OF_RANKS;rnk_idx=rnk_idx+1)
                xpctd_a[rnk_idx]  = {`GRM.mr3[rnk_idx][7:0], 8'h03};
            end
          endcase // case(no_of_load_mode)
`else
      
          case (no_of_load_mode)
            0, 1, 2, 6:
              begin
                // load mode EMR2, EMR3, and EMR for DLL enable and OCD exit
                case (no_of_load_mode)
                  0: begin
                       for(rnk_idx=0;rnk_idx<`DWC_NO_OF_RANKS;rnk_idx=rnk_idx+1)
                         xpctd_a[rnk_idx] = `GRM.emr2[rnk_idx];
                     end
                  1: begin
                       for(rnk_idx=0;rnk_idx<`DWC_NO_OF_RANKS;rnk_idx=rnk_idx+1)
                         xpctd_a[rnk_idx] = `GRM.emr3[rnk_idx];
                     end
                  default: begin
                             for(rnk_idx=0;rnk_idx<`DWC_NO_OF_RANKS;rnk_idx=rnk_idx+1)
                               xpctd_a[rnk_idx] = `GRM.emr[rnk_idx];
                           end
                endcase // case(no_of_load_mode)
              end
            3, 4:
              begin
                // load mode MR to reset DLL and then load normal parameters
                xpctd_a[0] = `GRM.mr;
                if (no_of_load_mode == 3) xpctd_a[0][8] = 1'b1; // DLL reset
              end
            5:
              begin
                // load mode EMR for OCD default
                for(rnk_idx=0;rnk_idx<`DWC_NO_OF_RANKS;rnk_idx=rnk_idx+1)
                  xpctd_a[rnk_idx] = `GRM.emr[rnk_idx];
                xpctd_a[0][9:7] = 3'b111;
              end
          endcase // case(no_of_load_mode)
`endif
`endif
        end
      else
        begin
          xpctd_a[0] = {pADDR_WIDTH{1'b0}};
          if (op === `PRECHARGE_ALL || op === `ZQCAL_LONG) xpctd_a[0][10] = 1'b1;
        end

      if (ba !== xpctd_ba || a !== xpctd_a[0])
        begin
          // For udimm, and no of ranks more than 1, bank and addr on rank 1 is scrambled
          if (`DWC_UDIMM == 1 && ((rank_no == 1)||(rank_no == 3))) begin
            if ((ba != {xpctd_ba[pBANK_WIDTH-1], xpctd_ba[0], xpctd_ba[1]}) ||
                (a  != {xpctd_a[0][pADDR_WIDTH-1:9], 
                        xpctd_a[0][7], xpctd_a[0][8], xpctd_a[0][5], 
                        xpctd_a[0][6], xpctd_a[0][3], xpctd_a[0][4], 
                        xpctd_a[0][2:0]}))
            `SYS.error_message(`CTRL_SDRAM, `INITDATAERR, {xpctd_a[0], xpctd_ba});
          end
          else begin
            `SYS.error_message(`CTRL_SDRAM, `INITDATAERR, {xpctd_a[0], xpctd_ba});
          end
        end

      // next command in sequence
      dll_rst_wait = 1'b0;
      if (( ddr3_mode && op === `ZQCAL_LONG) ||
          ( `GRM.lpddrx_mode && op === `LOAD_MODE && no_of_load_mode == 4) ||
          ( `GRM.ddr2_mode && op === `LOAD_MODE && no_of_load_mode == 6))
        begin
          // end of initialization; disable monitoring
          init_mnt_en = 1'b0;
        end
      else
        begin      
          // generate the next expected command/address and command-to-command 
          // spacing
          case (op)
            `PRECHARGE_ALL:
              begin
                // DDR2 only
                case (no_of_pre_all)
                  0: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `EMR2};
                  1: {next_xpctd_cmd, next_xpctd_reg} = {`REFRESH, `MR};
                endcase // case(no_of_pre_all)
                
                xpctd_cmd_spacing = t_rp + (ddr_8_bank | ddr_16_bank);
                xpctd_cmd_spacing = (`DWC_NO_SRA == 1) ? xpctd_cmd_spacing * pNO_OF_RANKS : xpctd_cmd_spacing;
                no_of_pre_all     = no_of_pre_all + 1;
              end
            
            `LOAD_MODE:
              begin
`ifdef LPDDR2
                case (no_of_load_mode)
                  0: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, 9'd10};
                  1: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR1_REG};
                  2: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR2_REG};
                  3: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR3_REG};
                endcase // case(no_of_load_mode)
                
                case (no_of_load_mode)
  `ifdef FULL_SDRAM_INIT  
              
                  0: xpctd_cmd_spacing = 11000/(`SYS.tCLK_PRD); // 10us
                  1: xpctd_cmd_spacing = 1000/(`SYS.tCLK_PRD);  // 1us;
  `else
                  0: xpctd_cmd_spacing = `tDINIT2_c_ssi;
                  1: xpctd_cmd_spacing = `tDINIT3_c_ssi;
  `endif
                  default: xpctd_cmd_spacing = {1'b1, t_mrd};
                endcase // case(no_of_load_mode)
                if (Debug) begin
                  $display ("%0t [DDR_MNT%0d] no_of_load_mode   = %0d", $realtime, rank_no, no_of_load_mode);
                  $display ("%0t [DDR_MNT%0d] xpctd_cmd_spacing = %0d", $realtime, rank_no, xpctd_cmd_spacing);
                  $display ("%0t [DDR_MNT%0d] pNO_OF_RANKS      = %0d", $realtime, rank_no, pNO_OF_RANKS);
                end          
                no_of_load_mode = no_of_load_mode + 1;

`else
  `ifdef LPDDR3

                case (no_of_load_mode)
                  0: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, 9'd10};
                  1: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR1_REG};
                  2: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR2_REG};
                  3: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR3_REG};
                endcase // case(no_of_load_mode)
                
                case (no_of_load_mode)
    `ifdef FULL_SDRAM_INIT  
                  0: xpctd_cmd_spacing = 11000/(`SYS.tCLK_PRD); //9998 (10us) & 11000 (10us)
                  1: xpctd_cmd_spacing = 1000/(`SYS.tCLK_PRD);  // 1us;
    `else
                  0: xpctd_cmd_spacing = `tDINIT2_c_ssi;
                  1: xpctd_cmd_spacing = `tDINIT3_c_ssi;
    `endif
                  default: xpctd_cmd_spacing = {2'b10, t_mrd};
                endcase // case(no_of_load_mode)
                if (Debug) begin
                  $display ("%0t [DDR_MNT%0d] no_of_load_mode   = %0d", $realtime, rank_no, no_of_load_mode);
                  $display ("%0t [DDR_MNT%0d] xpctd_cmd_spacing = %0d", $realtime, rank_no, xpctd_cmd_spacing);
                  $display ("%0t [DDR_MNT%0d] pNO_OF_RANKS      = %0d", $realtime, rank_no, pNO_OF_RANKS);
                end          
                no_of_load_mode = no_of_load_mode + 1;

  `else
                case (no_of_load_mode)
                  0: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `EMR3};
                  1: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `EMR1};
                  2: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR};
                  3: {next_xpctd_cmd, next_xpctd_reg} = (ddr3_mode) ?
                                                        {`ZQCAL_LONG, `MR} :
                                                        {`PRECHARGE_ALL, `MR};
                  4: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `EMR1};
                  5: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `EMR1};
                endcase // case(no_of_load_mode)
                
                xpctd_cmd_spacing = (ddr3_mode && no_of_load_mode == 3) ? 
                                    t_mod + `DWC_RDIMM : {ddr3_mode, t_mrd};
                xpctd_cmd_spacing = (`DWC_NO_SRA == 1) ? xpctd_cmd_spacing * pNO_OF_RANKS : xpctd_cmd_spacing;
                no_of_load_mode   = no_of_load_mode + 1;

                // log the time when DLL reset occurs
                if (no_of_load_mode == 4)
                  begin
                    dll_rst_time = curr_time;
                  end

                // in DDR2, the command OCD load mode register must wait for
                // DLL to lock
                if (no_of_load_mode == 5) dll_rst_wait = 1'b1;
  `endif
`endif
              end
            
            `REFRESH:
              begin
                // DDR2 only
                case (no_of_rfsh)
                  0: {next_xpctd_cmd, next_xpctd_reg} = {`REFRESH, `MR};
                  1: {next_xpctd_cmd, next_xpctd_reg} = {`LOAD_MODE, `MR};
                endcase // case(no_of_rfsh)
                
                xpctd_cmd_spacing = t_rfc;
                xpctd_cmd_spacing = (`DWC_NO_SRA == 1) ? xpctd_cmd_spacing * pNO_OF_RANKS : xpctd_cmd_spacing;
                no_of_rfsh        = no_of_rfsh + 1;
              end
          endcase // case(op)
          
          // save current command time
          prev_time = curr_time;
        end // else: !if(op === `LOAD_MODE && no_of_load_mode == 6)

    end
  endtask // log_init_command


  // initial wait times
  // ------------------
  // verifies the initiali wait times for the controller command DLL to lock,
  // the initial wait from clock stable to CKE going high (200us), and the
  // time from CKE going high to the first SDRAM command
  initial
    begin: init_mnt
      integer init_wait_clks;
      integer cke_wait_clks;
      integer wait_clks;
      integer rst2cke_clks;
      
`ifdef DDR3
      #0.001
      wait (ram_rst_n == 1'b0);
      @(posedge ram_rst_n);
      prev_time = $realtime;
`else
      wait (rst_n == 1'b0);
      @(posedge rst_n);
      prev_time = $realtime;
`endif

      if (init_mnt_en === 1'b1)
        begin
      
      $display("%0t init_mnt_en HIGH HERE", $time);
          // the wait times are simulated shortened if not running full SDRAM
          // initialization; the non-shortened wait times are based on the
          // fastest speed supported (400MHz)
`ifdef FULL_SDRAM_INIT
          // full wait times
          init_wait_clks = DDR_INIT_WAIT;  // 200us
`else
          // shortened wait times
          init_wait_clks = 16;
`endif    
          cke_wait_clks   = DDR_CKE_WAIT;   // 400ns
          $display("%0t cke_wait cycles", $time);
`ifdef DDR3
          rst2cke_clks    = `DRAM_RST_TO_CKE_HIGH;
`endif    
          
          // measure the time from reset de-assertion to when CKE goes high:
          // it should be more than the wait time for the command-lane DLL to 
          // lock plus the 200us wait time
          @(posedge `CHIP.cke);
          curr_time = $realtime;
          
          wait_clks = (curr_time - prev_time)/(`SYS.tCLK_PRD);

`ifdef DWC_AC_RST_USE
          // check reset timing only if the reset pin is compiled in - otherwise
          // it is driven by the user
          if (rst_cke_mnt_en) begin
            if (wait_clks < (rst2cke_clks) ||
                wait_clks > (rst2cke_clks+20))
              begin
                `SYS.error_message(`CTRL_SDRAM, `INITWAITERR, 0);
              end
          end
`endif
          
          // measure the time from CKE going high to the first command
          // should be atleast 400ns; actual comparison is done when the next
          // command (precharg-all/load-mode is logged in the log_init_command
          // task)
          prev_time         = curr_time;
          xpctd_cmd_spacing = cke_wait_clks;

          // store cke expected spacing and timestamp for log_init_command separately
          prev_cke_time          = curr_time;
          xpctd_init_cke_spacing = cke_wait_clks;

          // check the time from DLL reset to when initialization in progress
          // flag (init) is de-asserted - should be at least 200 clocks plus
          // minor bit
          @(negedge `SYS.init);
          curr_time = $realtime;

          wait_clks = (curr_time - dll_rst_time)/(`SYS.tCLK_PRD);
          
`ifdef DWC_BUBBLES
`else
          if (wait_clks < `tDLLK || wait_clks > (`tDLLK+35))
            begin
              `SYS.error_message(`CTRL_SDRAM, `INITWAITERR, 3);
            end
`endif
        end // if (init_mnt_en === 1'b1)
    end // block: init_mnt
  
  
  //---------------------------------------------------------------------------
  // Refresh Monitor
  //---------------------------------------------------------------------------
  // monitors and verifies that refreshes are scheduled correctly, i.e. at the
  // correct refresh period, correct refresh bursts, and correct refresh burst
  // command-to-command timing
  task log_rfsh_command;
    input [31:0] op;

    integer cmd2cmd_clks;
    integer deselect_spacing;
    
    begin
      // check the command sequence
      if (op !== next_xpctd_cmd)
        begin
          `SYS.error_message(`CTRL_SDRAM, `RFSHCMDERR, next_xpctd_cmd);
        end

      // check the command-to-command timing
      // NOTE: DDR transactions are reported delayed - use actual time
      curr_time = $realtime - rw_len*(`SYS.tCLK_PRD);

      if (op == `PRECHARGE_ALL)
        begin
          // first command in the refresh burst; should be almost about
          // the refresh period from the previous start of the burst
          cmd2cmd_clks = (curr_time - rfsh_time)/(`SYS.tCLK_PRD);
          if (cmd2cmd_clks < (xpctd_rfsh_prd - `RFSH_PRD_TOL) ||
              cmd2cmd_clks > (xpctd_rfsh_prd + `RFSH_PRD_TOL))
            begin
              `SYS.error_message(`CTRL_SDRAM, `RFSHPRDERR, xpctd_rfsh_prd);
            end
          rfsh_time  = curr_time;
          rfsh_burst = 1'b1;

          // NOTE: initial expected refresh period is slightly shorter becasue 
          //       of where we start from
          //if (no_of_pre_all == 0)
          //  begin
          //    xpctd_rfsh_prd = xpctd_rfsh_prd + 100;
          //  end
        end
      else
        begin
          // refresh commands: check exact timing between commands
          // NOTE: 2x clock mode timing could be 1 clock greater
          cmd2cmd_clks = (curr_time - prev_time)/(`SYS.tCLK_PRD);
          if ((cmd2cmd_clks !== xpctd_cmd_spacing) &&
              (cmd2cmd_clks !== (xpctd_cmd_spacing+`GRM.hdr_mode)))
            begin
              // general command-to-command timing violation
              `SYS.error_message(`CTRL_SDRAM, `CMDTIMEERR, xpctd_cmd_spacing);
            end
        end

      // next command in sequence
      deselect_spacing = (`GRM.hdr_mode) ? 2 : 1;
      if (op === `REFRESH && no_of_rfsh == (rfsh_burst_length))
        begin
          // end of refresh burst: set up for the next burst
          rfsh_burst     = 1'b0;
          no_of_rfsh     = 0;
          next_xpctd_cmd = `PRECHARGE_ALL;
        end
      else
        begin      
          // generate the next expected command and command-to-command spacing
          case (op)
            `PRECHARGE_ALL:
              begin
                if (rank > 2'b00)
                  begin
                    next_xpctd_cmd    = `DESELECT;                
                    xpctd_cmd_spacing = deselect_spacing;
                  end
                else
                  begin
                    next_xpctd_cmd    = `REFRESH;                
                    xpctd_cmd_spacing = t_rp + (ddr_8_bank | ddr_16_bank);
                  end
                no_of_pre_all = no_of_pre_all + 1;
              end

            `DESELECT:
              begin
                if (no_of_rfsh == 0)
                  begin
                    xpctd_cmd_spacing = t_rp + (ddr_8_bank | ddr_16_bank) - deselect_spacing;
                    next_xpctd_cmd    = `REFRESH;                
                  end
                else
                  begin
                    next_xpctd_cmd    = `REFRESH;                
                    // the "-1" is because DESELECT counts as one of the 
                    // 50 nops total
                    xpctd_cmd_spacing = t_rfc - deselect_spacing;
                  end
              end

            `REFRESH:
              begin
                if (rank > 2'b00)
                  begin
                    next_xpctd_cmd    = `DESELECT;                
                    xpctd_cmd_spacing = deselect_spacing;
                  end
                else
                  begin
                    next_xpctd_cmd    = `REFRESH;
                    xpctd_cmd_spacing = t_rfc;
                  end
                no_of_rfsh        = no_of_rfsh + 1;
              end
            
          endcase // case(op)
          
          // save current command time
          prev_time = curr_time;
        end


    end
  endtask // log_rfsh_command
  
  
  //---------------------------------------------------------------------------
  // Errors and Warnings
  //---------------------------------------------------------------------------
  // reports errors and warnings
  task report_errors;
    begin
    end
  endtask // report_errors


  // check undefined values
  // ----------------------
  // checks and reports undefined values on buses
  task check_undefined;
    input [31:0]                op;
    input [pBANK_WIDTH-1:0]     ba;
    input [pADDR_WIDTH-1:0]     a;
    input [pNUM_LANES_X2 -1:0]     dm;
    input [pNUM_LANES_X2 -1:0]     dqs;
    input [pNUM_LANES_X2 -1:0]     dqs_n;
    input [pDATA_WIDTH-1:0]     dq;
    begin
      if (op === `SDRAM_WRITE || op === `WRITE_PRECHG)
          begin
            if (!valid_bus(ba))     `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `BA_PIN);
            if (!valid_bus(a))      `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `A_PIN);
`ifdef DWC_DDRPHY_X4X2
  `ifdef DWC_DDRPHY_X4MODE  
    `ifndef DDR4
            // DDR4 mode does not support dm in x4; only check dm bus for other ddr modes
      `ifdef DWC_DX_DM_USE            
            if (!valid_bus(dm))     `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
      `endif
            if (!valid_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
    `endif
  `elsif DWC_DDRPHY_X8_ONLY
      `ifdef DWC_DX_DM_USE            
            if (!valid_lower_nibble_bus(dm)) begin `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
              $display("-> %0t: [RANK %0d] ==> dm    = %b",  $realtime, rank_no, dm);
            end
      `endif
            if (!valid_lower_nibble_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_lower_nibble_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
            
  `else
    `ifdef DWC_DDRPHY_DMDQS_MUX
            // only the lower nibble has the muxed dm value.
      `ifdef DWC_DX_DM_USE            
            if (!valid_lower_nibble_bus(dm)) begin `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
              $display("-> %0t: [RANK %0d] ==> dm    = %b",  $realtime, rank_no, dm);
            end
      `endif
            // both upper and lower nibble of dqs should be ok, the upper nibble is actually the dm 
            if (!valid_lower_nibble_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_lower_nibble_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
    `else            
      `ifdef DWC_DX_DM_USE 
            if (!valid_bus(dm)) begin `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
              $display("-> %0t: [RANK %0d] ==> dm    = %b",  $realtime, rank_no, dm);
            end
      `endif
            if (!valid_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
    `endif
  `endif
`else
      `ifdef DWC_DX_DM_USE            
            if (!valid_bus(dm))     `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
      `endif
            if (!valid_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
`endif
            if (!valid_bus(dq))     `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQ_PIN);
          end
      
      if (op === `SDRAM_READ || op === `READ_PRECHG)
          begin
            if (!valid_bus(ba))   `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `BA_PIN);
            if (!valid_bus(a))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `A_PIN);
            if (!valid_bus(dq))   `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQ_PIN);

`ifdef DWC_DDRPHY_X4X2
  `ifdef DWC_DDRPHY_X4MODE  
    `ifndef DDR4
            // DDR4 mode does not support dm in x4; only check dm bus for other ddr modes
            if (!valid_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
    `endif
  `elsif DWC_DDRPHY_X8_ONLY
            // only lower nibbles are driven, higher nibble are Z's (for both READ/WRITE)
            if (!valid_lower_nibble_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_lower_nibble_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
  `else
    `ifdef DWC_DDRPHY_DMDQS_MUX
            // only the lower nibble has the muxed dm value; check for x only
            if (!valid_lower_nibble_bus_or_check_x_only(dm)) begin `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
              $display("-> %0t: [RANK %0d] ==> dm    = %b",  $realtime, rank_no, dm);
            end
            // both upper and lower nibble of dqs should be ok, the upper nibble is actually the dm 
            if (!valid_lower_nibble_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_lower_nibble_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
    `else            
            // all high and lower nibbles are driven...
            // For READs, there are no dqs clocks on READ on higher nibble they are driven with 0's. 
            //                         dqs exist on READ on lower nibble.
            // For WRITEs, both higher and lower nibble dqs are driven with clocks.
            if (`GRM.dxccr[8] == 1'b1 || `GRM.dxccr[7:5] == 3'b000) begin
              if (!valid_lower_nibble_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            end
            else begin
              if (!valid_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            end
            
            if (`GRM.dxccr[12] == 1'b0 || `GRM.dxccr[11:9] == 3'b000) begin
              if (!valid_lower_nibble_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
            end
            else begin
              if (!valid_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
            end

            // check X only for dm
            if (!valid_lower_nibble_bus_or_check_x_only(dm)) begin `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DM_PIN);
              $display("-> %0t: [RANK %0d] ==> dm    = %b",  $realtime, rank_no, dm);
            end
    `endif
  `endif
`else
            if (!valid_bus(dqs))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQS_PIN);
            if (!valid_bus(dqs_n))  `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `DQSb_PIN);
`endif
          end          
      
      if (op === `PRECHARGE)
        begin
          if (!valid_bus(ba))   `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `BA_PIN);
          if (!valid_bus(a))    `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `A_PIN);
        end
      
      if (op === `ACTIVATE || op === `LOAD_MODE)
        begin
          if (!valid_bus(ba))   `SYS.error_message(`CTRL_SDRAM, `DATAXWARN, `BA_PIN);
        end
    end
  endtask // check_undefined


  // clear error flags
  // -----------------
  // resets error and warning flags
  task clear_error_flags;
    begin
    end
  endtask // clear_error_flags

  
  // valid bus
  // ---------
  // check if bus has x's or z's and flag as invalid
  function valid_bus;
    input [`DATA_WIDTH-1:0] bus;
    begin
      valid_bus = (^(bus) !== 1'bx);
    end
  endfunction // valid_bus

  
  // check only the lower nibble of the bus (dm) has x's or z's and flag as invalid
  function valid_lower_nibble_bus;
    input [pNUM_LANES_X2-1:0] bus;
    reg   [pNUM_LANES   -1:0] lower_nibble_bus;
    integer i;
    begin
      lower_nibble_bus = {pNUM_LANES{1'b0}};

      if (pNO_OF_DX_DQS == 2) begin
        for (i=0; i<pNUM_LANES/2; i=i+1) begin
          lower_nibble_bus[i] = bus[i*2];
          //$display("-> %0t: [RANK %0d] ==> bus [%0d]               = %b",  $realtime, rank_no, i*2, bus[i*2]);
        end
        
        valid_lower_nibble_bus = (^(lower_nibble_bus) !== 1'bx);
      end
      else begin
        for (i=0; i<pNUM_LANES; i=i+1) begin
          lower_nibble_bus[i] = bus[i];
          //$display("-> %0t: [RANK %0d] ==> bus [%0d]               = %b",  $realtime, rank_no, i, bus[i]);
        end        
        valid_lower_nibble_bus = (^(lower_nibble_bus) !== 1'bx);
      end
    end
  endfunction // valid_bus

  // This is to screen for X's only. DM can be in Z's during read
  function valid_lower_nibble_bus_or_check_x_only;
    input [pNUM_LANES_X2-1:0] bus;
    reg   [pNUM_LANES   -1:0] lower_nibble_bus;
    integer i;
    begin
      lower_nibble_bus = {pNUM_LANES{1'b0}};
      valid_lower_nibble_bus_or_check_x_only = 1'b1;
      
      if (pNO_OF_DX_DQS == 2) begin
        for (i=0; i<pNUM_LANES/2; i=i+1) begin
          lower_nibble_bus[i] = bus[i*2];
          //$display("-> %0t: [RANK %0d] ==> bus [%0d]               = %b",  $realtime, rank_no, i*2, bus[i*2]);
          if (bus[i*2] === 1'bx) 
            valid_lower_nibble_bus_or_check_x_only = 1'b0;
        end
      end
      else begin
        for (i=0; i<pNUM_LANES; i=i+1) begin
          //$display("-> %0t: [RANK %0d] ==> bus [%0d]               = %b",  $realtime, rank_no, i, bus[i]);
          if (bus[i] === 1'bx);
            valid_lower_nibble_bus_or_check_x_only = 1'b0;
        end
      end
    end
  endfunction // valid_bus
        
  //---------------------------------------------------------------------------
  // ODT Monitor
  //---------------------------------------------------------------------------
  reg [`DDR_RANK_WIDTH-1:0]           odt_p[0:25];
  integer                             i;
  wire [`DDR_RANK_WIDTH-1:0]          odt_check;

  assign odt_check = (ddr4_mode || ddr3_mode || lpddr3_mode) ? odt_wr_vector : odt_p[odta+7];

  initial
    for (i=0;i<21;i=i+1)
      odt_p[i] = {`DDR_RANK_WIDTH{1'h0}};

  // Top level of the ODT monitor
  // Check what each rank should be generating as ODT.
  // (refer to generate statement)

  // Monitor ODT on every clock cycle.
  always @(posedge ck)
    begin
`ifdef DDR4
      // Self Write
      w_b     <= a[15] | !a[16] | cs_n | a[14] ? 4'b0000 : 4'b1111;
      // Other Read
      r_b     <= a[15] | !a[16] | cs_n | !a[14] ? 4'b0000: 4'b1111;
`else      
      // Self Write
      w_b     <= cas_n | !ras_n | cs_n | we_n ? 4'b0000 : 4'b1111;
      // Other Read
      r_b     <= cas_n | !ras_n | cs_n | !we_n ? 4'b0000: 4'b1111;
`endif
      bl8 <= burst_len == 4 ? 4'b1111 : 4'b0000;

`ifdef DWC_DDRPHY_EMUL_XILINX
      if (`GRM.ddr2_mode && odt_mnt_en == 1'b1 ) begin
`else
      if (`GRM.ddr2_mode && odt_mnt_en == 1'b1 &&`PUB.dram_init_done) begin
`endif        
        // if DCR.RDIMM is asserted, extra WL/RL is set, ODT will also be 1 later..    
        if (`DWC_RDIMM === 1'b1) begin
          if (odt_full !== odt_q[1]) begin
            `SYS.error_message(`CTRL_SDRAM,`ODTERR,0);
            -> e_ddr2_odt_err;
            $display ("%0t [DDR_MNT%0d] odt_full = %0h", $realtime, rank_no, odt_full);
            $display ("%0t [DDR_MNT%0d] odt_q[1] = %0h", $realtime, rank_no, odt_q[1]);
          end
          else begin
            if (odt_full)
              -> e_ddr2_odt_on_good;
            else
              -> e_ddr2_odt_off_good;     
          end
        end
        else begin
          if (odt_full !== odt_q[2])begin
            `SYS.error_message(`CTRL_SDRAM,`ODTERR,0);
            -> e_ddr2_odt_err;
            $display ("%0t [DDR_MNT%0d] odt_full = %0h", $realtime, rank_no, odt_full);
            $display ("%0t [DDR_MNT%0d] odt_q[2] = %0h", $realtime, rank_no, odt_q[2]);
          end
          else begin
            if (odt_full)
              -> e_ddr2_odt_on_good;
            else
              -> e_ddr2_odt_off_good;      
          end
        end
      end
    end
  
  
  always @(posedge ck)
    begin
      wr_cmd_reg = wr_cmd;
      rd_cmd_reg = rd_cmd;
    end
  
  always @(rank_wrcmd_reg)
    begin: check_expected_odt_wr_ddr2
      integer j;

      odt_wr_vector = {pNO_OF_RANKS{1'b0}};

      // xpct odt wr should include write to curr rank OR write to any rank but with wrodt set
      // when from data train or dcu
      for (j=0;j<pNO_OF_RANKS;j=j+1) begin
        if (rank_wrcmd_reg[j] === 1'b1) begin
          odt_wr_vector = wrodt[j];
        end
      end
    end  

  always @(rank_rdcmd_reg)
    begin: check_expected_odt_rd_ddr2
      integer j;

      odt_rd_vector = {pNO_OF_RANKS{1'b0}};

      // xpct odt rd should include read to curr rank OR read to any rank but with rdodt set
      // when from data train or dcu
      for (j=0;j<pNO_OF_RANKS;j=j+1) begin
        if (rank_rdcmd_reg[j] === 1'b1) begin
          odt_rd_vector = rdodt[j];
        end
      end
    end  

  generate 
    genvar dwc_dim;
    genvar dwc_rnk;
    for (dwc_dim=0; dwc_dim<`DWC_NO_OF_DIMMS; dwc_dim=dwc_dim+1) begin: dwc_ddr_dimm
      for (dwc_rnk=0; dwc_rnk<`DWC_RANKS_PER_DIMM; dwc_rnk=dwc_rnk+1) begin: dwc_ddr_rank
        assign rank_wrcmd    [dwc_dim*`DWC_MAX_RANKS_PER_DIMM+dwc_rnk] = `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.wr_cmd;
        assign rank_rdcmd    [dwc_dim*`DWC_MAX_RANKS_PER_DIMM+dwc_rnk] = `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.rd_cmd;
        assign rank_wrcmd_reg[dwc_dim*`DWC_MAX_RANKS_PER_DIMM+dwc_rnk] = `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.wr_cmd_reg;
        assign rank_rdcmd_reg[dwc_dim*`DWC_MAX_RANKS_PER_DIMM+dwc_rnk] = `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.rd_cmd_reg;

        assign odt_full = odt_full | `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.odt_check;
        assign any_w_b  = any_w_b  | `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.w_b;
        assign any_r_b  = any_r_b  | `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt.r_b;
      end
    end
  endgenerate
  

  // DDR2 ODT monitor
  // ----------------
  // Read and write command pipeline
  // for ODT monitoring.
  always @(posedge ck)
    begin

      odt_q[0] <= `TB.odt;
      odt_q[1] <= odt_q[0];
      odt_q[2] <= odt_q[1];

      // odt_p[0] is a spare so you don't have to renumber
      // everything if odt timing changes.
      odt_p[0] <= (any_r_b & odt_rd_vector & bl8);
      odt_p[1] <= (any_r_b & odt_rd_vector & bl8) | odt_p[0];
      odt_p[2] <= (any_w_b & odt_wr_vector & bl8) | (any_r_b & odt_rd_vector) | odt_p[1];
      odt_p[3] <= (any_w_b & odt_wr_vector & bl8) | (any_r_b & odt_rd_vector) | odt_p[2];
      odt_p[4] <= (any_w_b & odt_wr_vector) | (any_r_b & odt_rd_vector)       | odt_p[3];
      odt_p[5] <= (any_w_b & odt_wr_vector)                                   | odt_p[4];
      odt_p[6] <= (any_w_b & odt_wr_vector)                                   | odt_p[5];
      odt_p[7] <= odt_p[6];
      odt_p[8] <= odt_p[7];
      odt_p[9] <= odt_p[8];
      odt_p[10] <= odt_p[9];
      odt_p[11] <= odt_p[10];
      odt_p[12] <= odt_p[11];
      odt_p[13] <= odt_p[12];
      odt_p[14] <= odt_p[13];
      odt_p[15] <= odt_p[14];
      odt_p[16] <= odt_p[15];
      odt_p[17] <= odt_p[16];
      odt_p[18] <= odt_p[17];
      odt_p[19] <= odt_p[18];
      odt_p[20] <= odt_p[19];
      odt_p[21] <= odt_p[20];
      odt_p[22] <= odt_p[21];
      odt_p[23] <= odt_p[22];
      odt_p[24] <= odt_p[23];
      odt_p[25] <= odt_p[24];

      // Whatever is in stage odta+7 reflects the state of
      // what odt should be.  There are a lot of stages because
      // gDDR2 mode uses large, non-JEDEC values of CL and AL.
    end    

  
  // DDR3 ODT monitor
  // ----------------
  // monitors ODT when the DRAM is not in write leveling mode
`ifndef LPDDR2
  always @(posedge ck)
    begin: monitor_ddr3_odt
      if ((ddr4_mode || ddr3_mode || lpddr3_mode) && odt_mnt_en && !wl_mode)
        begin
          // duration when ODT is high
          if (ddr3_xpct_odt_wr_i || ddr3_xpct_odt_rd_i)
            begin
              // ODT should remain high for ODTH4 or ODTH8 clocks
              // NB: if data training is on, burst length of 4 is not supported, instead
              //     a burst length of 8 is used during training and thus is reflected on ddr3_odt_on count
              ddr3_odt_on <= (( !`SYS.dqs_gate_training && !`SYS.data_eye_training && 
                                !`SYS.write_levelling_2 && !`SYS.static_read_training) &&
                              ((ddr4_mode || ddr3_mode || lpddr3_mode) && burst_len == 2 || `GRM.ddr3_blotf && !a_12) ) ?
                              ODTH4-1 : ODTH8-1;
            end
          else
            begin
              if (|ddr3_odt_on) ddr3_odt_on <= ddr3_odt_on - 1;
            end

//          // For rdimm odt is only in odt[1:0] bits
//          if ((`DWC_RDIMM == 1 && rank_no < 2) ||
//              (`DWC_RDIMM == 0)) begin

          // check for ODT timing errors
          if (ddr3_xpct_odt_wr_i || ddr3_xpct_odt_rd_i || (|ddr3_odt_on)) begin
            if (ddr3_xpct_odt != 1'b1 || odt !== 1'b1) begin
              `SYS.error_message(`CTRL_SDRAM, `ODTERR, 0);
              -> e_ddr3_odt_err;
              if (Debug) begin
                $display ("%0t [DDR_MNT%0d] ddr3_xpct_odt = %0h", $realtime, rank_no, ddr3_xpct_odt);
                $display ("%0t [DDR_MNT%0d] odt           = %0h", $realtime, rank_no, odt);
              end
            end
            else begin
              -> e_ddr3_odt_on_good;
            end
          end
          else begin
            // odt shouldnt be on if not write command or ddr3_odt_on
            if (odt != 1'b0 || ddr3_xpct_odt != 1'b0) begin
              `SYS.error_message(`CTRL_SDRAM, `ODTERR, 0);
              -> e_ddr3_odt_err;
              if (Debug) begin
                $display ("%0t [DDR_MNT%0d] ddr3_odt_on   = %0h", $realtime, rank_no, ddr3_odt_on);
                $display ("%0t [DDR_MNT%0d] ddr3_xpct_odt = %0h", $realtime, rank_no, ddr3_xpct_odt);
                $display ("%0t [DDR_MNT%0d] odt           = %0h", $realtime, rank_no, odt);
              end
            end
            else begin
              -> e_ddr3_odt_off_good;
            end
          end

          if (ddr3_xpct_odt_wr_i || ddr3_xpct_odt_rd_i)
            begin
              ddr3_xpct_odt_ff <= 1'b1;
            end
          else if (ddr3_odt_on == 3'b001)
            begin
              ddr3_xpct_odt_ff <= 1'b0;
            end
        end
    end
`endif

`ifdef DWC_AC_CS_USE
  assign cs_n_all = &(`CHIP.cs_n);
  assign cs_n_rank = `CHIP.cs_n[rank_no];
`else  
  assign cs_n_all = 1'b1;
  assign cs_n_rank = 1'b1;
`endif  

`ifdef LPDDRX
  assign wr_cmd_all  = ({ckep, cke, cs_n_all, a[0], a[1], a[2]} === WRITE) ? 1'b1 : 1'b0;
  assign wr_cmd      = ({ckep, cke, cs_n,     a[0], a[1], a[2]} === WRITE) ? 1'b1 : 1'b0;
  assign rd_cmd_all  = ({ckep, cke, cs_n_all, a[0], a[1], a[2]} === READ)  ? 1'b1 : 1'b0;
  assign rd_cmd      = ({ckep, cke, cs_n,     a[0], a[1], a[2]} === READ)  ? 1'b1 : 1'b0;
`elsif DDR4
  assign wr_cmd_all  = ({act_n, ckep, cke, cs_n_all, a[16:14]} === WRITE)  ? 1'b1 : 1'b0;
  assign wr_cmd      = ({act_n, ckep, cke, cs_n,     a[16:14]} === WRITE)  ? 1'b1 : 1'b0;
  assign rd_cmd_all  = ({act_n, ckep, cke, cs_n_all, a[16:14]} === READ)   ? 1'b1 : 1'b0;
  assign rd_cmd      = ({act_n, ckep, cke, cs_n,     a[16:14]} === READ)   ? 1'b1 : 1'b0;
`else 
  assign wr_cmd_all  = ({ckep, cke, cs_n_all, ras_n, cas_n, we_n} === WRITE) ? 1'b1 : 1'b0;
  assign wr_cmd      = ({ckep, cke, cs_n,     ras_n, cas_n, we_n} === WRITE) ? 1'b1 : 1'b0;
  assign rd_cmd_all  = ({ckep, cke, cs_n_all, ras_n, cas_n, we_n} === READ)  ? 1'b1 : 1'b0;
  assign rd_cmd      = ({ckep, cke, cs_n,     ras_n, cas_n, we_n} === READ)  ? 1'b1 : 1'b0;
`endif
  
  // ODT expected to be on when programmed to do so for writes to this rank or
  // writes from other ranks
  always @(rank_wrcmd)
    begin: check_expected_odt_wr
      integer j;

      ddr3_xpct_odt_wr_i  = 1'b0;

      // xpct odt wr should include write to curr rank OR write to any rank but with wrodt set
      // when from data train or dcu
      for (j=0;j<pNO_OF_RANKS;j=j+1) begin
        ddr3_xpct_odt_wr_i = ddr3_xpct_odt_wr_i || (rank_wrcmd[j] & wrodt[j][rank_no]);
      end
    end

  // ODT expected to be on when programmed to do so for writes to this rank or
  // writes from other ranks
  always @(rank_rdcmd)
    begin: check_expected_odt_rd
      integer j;

      ddr3_xpct_odt_rd_i  = 1'b0;

      // xpct odt rd should include read to curr rank OR read to any rank but with wrodt set
      // when from data train or dcu
      for (j=0;j<pNO_OF_RANKS;j=j+1) begin
        ddr3_xpct_odt_rd_i = ddr3_xpct_odt_rd_i || (rank_rdcmd[j] & rdodt[j][rank_no]);
      end
    end
  
  // For DDR3 mode only write command of special ODT on or off command will trigger ODT
  assign  ddr3_xpct_odt = ddr3_xpct_odt_wr_i | ddr3_xpct_odt_rd_i | ddr3_xpct_odt_ff;

`ifndef LPDDRX  
  generate
    if (`DWC_ADDR_WIDTH < 13) begin
      assign a_12 = 1'b0;
    end else begin
      assign a_12 = a[12];
    end
  endgenerate
`endif
  
  // DDR3 write leveling ODT monitor
  // -------------------------------
  // monitors ODT when the DRAM is in write leveling mode
  always @(posedge dqs[0]) begin: monitor_ddr3_wl_odt
    if ((ddr4_mode || ddr3_mode || lpddr3_mode) && odt_mnt_en && wl_mode) begin
      // check that the ODT is high when DQS is being pulsed
      if (dqs[0] === 1'b1 && odt !== 1'b1) begin
        `SYS.error_message(`CTRL_SDRAM, `ODTERR, 0);
        if (Debug) begin
          $display ("%0t [DDR_MNT%0d] ddr3_xpct_odt = %0h", $realtime, rank_no, ddr3_xpct_odt);
          $display ("%0t [DDR_MNT%0d] odt           = %0h", $realtime, rank_no, odt);
        end
      end
    end
  end

`ifdef DWC_AC_CS_USE  
`ifndef LPDDRX  
  always @ (posedge `CHIP.ck[0]) begin
    if (!`SYS.rank_disconnected) begin
  `ifdef DDR4
      if (({`CHIP.cs_n[rank_no], a[16:14]} == 4'b0000) && // load mode
          (ddr4_mode && act_n==1'b1) && // Not activate command
          (ba[pBANK_WIDTH-1:0] == 'b1) && // MR1
          (a[7]    == 1'b1 && a[pADDR_BIT_12] == 1'b0)) begin // write level on, Q buffer on
        // this rank is enabled for write-leveling and the rank output buffers are turned on
        wl_mode = 1'b1;
      end
      else if (({`CHIP.cs_n[rank_no], a[16:14]} == 4'b0000) && // load mode
               (ddr4_mode && act_n==1'b1) && // Not activate command
               (ba[pBANK_WIDTH-1:0] == 'b1) && // MR1
               (a[pADDR_BIT_12] == 1'b1)) begin // Q buffer off
        // the rank output buffer has been turned off - so it is not being write leveled
        wl_mode = 1'b0;
      end
  `else      
      if (({`CHIP.cs_n[rank_no], ras_n, cas_n, we_n} == 4'b0000) && // load mode
          (ddr3_mode) && // Not activate command
          (ba[1:0] == 2'b01) && // MR1
          (a[7]    == 1'b1 && a[pADDR_BIT_12] == 1'b0)) begin // write level on, Q buffer on
        // this rank is enabled for write-leveling and the rank output buffers are turned on
        wl_mode = 1'b1;
      end
      else if (({`CHIP.cs_n[rank_no], ras_n, cas_n, we_n} == 4'b0000) && // load mode
               (ddr3_mode) && // Not activate command
               (ba[1:0] == 2'b01) && // MR1
               (a[pADDR_BIT_12] == 1'b1)) begin // Q buffer off
        // the rank output buffer has been turned off - so it is not being write leveled
        wl_mode = 1'b0;
      end
  `endif
    end
  end
`endif
`endif    
    
  //---------------------------------------------------------------------------
  // RDIMM Buffer Chip Monitor
  //---------------------------------------------------------------------------
  // monitors buffer chip register writes and parity errors
  // NOTE: the RDIMM monitor actually sits between the host and buffer chip, but
  //       the code is put inside this DDR monitor and only in rank 0 monitor
`ifdef DWC_DDR_RDIMM
`ifdef DWC_IDT
`ifdef DDR3
  generate
    if (`DWC_RDIMM == 1 && rank_no == 0) begin: rdimm_monitor
      // RDIMM reset monitor
      // -------------------
      // monitors the reset and generate the expected RDIMM initialization sequence
      always @(negedge `RDIMM.RESET_B) begin: rdimm_reset_mnt
        integer   i, j, k;

        // wait for reset assertion and de-assertion
        // (no need to check reset because it is the  same reset connect to DRAM
        //  and is checked in the DRAM monitor)
        #0.001
        // wait (`RDIMM.RESET_B === 1'b0);
        @(posedge `RDIMM.RESET_B);
        after_rdimm_reset = 1;
        no_of_rdimm_perr  = 0;

        // generate the expected RDIMM register address and data; only the registers
        // that are configured to be initialized through RDIMMGCR1 are initiaized
        // expected values are generated at the beginning of the first command
        j = 0;
        skpd_cr_after[0] = 0;
        for (i=0; i<16; i=i+1) begin
          if (`GRM.rdimmgcr2[i] == 1'b1) begin
            xpctd_cr_addr[j] = i;
            for(k=0; k<`DWC_NO_OF_DIMMS ; k=k+1)
              xpctd_cr_data[j] = (i<8) ? `GRM.rdimmcr0[k][i*4 +: 4] : `GRM.rdimmcr1[k][(i-8)*4 +: 4];
            j = j + 1;
            skpd_cr_after[j] = 0;
          end else begin
            // log skipped RCs after each RC to determine correct command spacing
            // (skipped RC result in extra spacing only for PUB initiated initialization)
            if (`SYS.dram_init_type == `PUB_DRAM_INIT) begin
              skpd_cr_after[j] = skpd_cr_after[j] + 1;
            end
          end
        end
        xpctd_no_of_cr_wr = j;
        no_of_cr_wr = 0;
      end


      // RDIMM command monitor
      // ---------------------
      // monitors the commands to the RDIMM buffer chip, especially register writes
      always @(posedge `RDIMM.CK) begin: rdimm_cmd_mnt
        rdimm_cr_addr = {`RDIMM.DBA[2],   `RDIMM.DA[2:0]}; // control register address
        rdimm_cr_data = {`RDIMM.DBA[1:0], `RDIMM.DA[4:3]}; // control register data
        
        // RDIMM buffer chip register write accesses
        // (al least one CKE bit must be high and A[15:5] must all be zeros)
        if ((|`RDIMM.DCKE[1:0] == 1'b1) && `RDIMM.DA[15:5] == {11{1'b0}} && !`GRM.bistrr[15]) begin
          case (`RDIMM.DCS_B)
            4'b0000, 4'b1100, 4'b0011: begin
              // valid RDIMM register write
              `SYS.message(`CTRL_RDIMM, `RDIMM_REG_WRITE, {rdimm_cr_data, rdimm_cr_addr});
              log_rdimm_init_command(rdimm_cr_addr, rdimm_cr_data);
            end
            4'b1000, 4'b0100, 4'b0010, 4'b0001: begin
              // invalid register write: 3 chip-selects low not allowed
              if (rdimm_mnt_en) 
                `SYS.error_message(`CTRL_RDIMM, `RDIMM3CS, 0);
            end
          endcase // case (`RDIMM.DCS_B)
        end

        // check the expected RDIMM initialization was done before the first
        // load mode register is executed
        if (rdimm_firt_load_mode && (|`RDIMM.DCKE[1:0] == 1'b1) && 
            `RDIMM.DRAS_B == 1'b0 &&`RDIMM.DCAS_B == 1'b0 && `RDIMM.DWE_B == 1'b0) begin
          if (no_of_cr_wr != xpctd_no_of_cr_wr) begin
            `SYS.error_message(`CTRL_RDIMM, `RFSHNEVER, {no_of_cr_wr, xpctd_no_of_cr_wr});
          end
          rdimm_firt_load_mode = 0;
        end
      end

      // parity error: only reported if it is not expected
      always @(`RDIMM.ERROUT_B) begin: rdimm_perr_mnt
        if (after_rdimm_reset && `RDIMM.ERROUT_B !== 1'b1) begin
          no_of_rdimm_perr = no_of_rdimm_perr + 1;

          // report the first parity error if parity errors are not expected
          if (`SYS.parity_err_chk == 1'b1 && !`SYS.parity_err_xpctd && no_of_rdimm_perr == 1) begin
            `SYS.error_message(`CTRL_RDIMM, `PARERR, 1);
          end
        end
      end
    end
  endgenerate
`endif //  `ifdef DDR3
`endif

  // RDIMM initialization monitor
  //-----------------------------
  // monitors and verifies that the controller/RDIMM initialization sequence
  // is correct
  task log_rdimm_init_command;
    input [3:0] cr_addr;
    input [3:0] cr_data;

    integer   cmd2cmd_clks;
    begin
      if (rdimm_mnt_en) begin
        // generate expected command-to-command timing
        if (no_of_cr_wr == 0) begin
          // no timing check for first command
          xpctd_cmd_spacing = 0;
          prev_time = $realtime;
        end else if (prev_cr_addr == 2 || prev_cr_addr == 10) begin
          // spacing from RC2 and RC10 is tBCSTAB
          xpctd_cmd_spacing = `GRM.t_bcstab + 2*skpd_cr_after[no_of_cr_wr];
        end else begin
          // spacing from other RCn is tBCMRD
          xpctd_cmd_spacing = `GRM.t_bcmrd  + 2*skpd_cr_after[no_of_cr_wr];
        end
        
        // check the command sequence
        if ((cr_addr !== xpctd_cr_addr[no_of_cr_wr]) ||
            (cr_data !== xpctd_cr_data[no_of_cr_wr])) begin
          `SYS.error_message(`CTRL_RDIMM, `INITCMDERR, {xpctd_cr_data[no_of_cr_wr], 
                                                        xpctd_cr_addr[no_of_cr_wr]});
        end
        
        // check the command-to-command timing
        curr_time    = $realtime;
        cmd2cmd_clks = (curr_time - prev_time)/(`SYS.tCLK_PRD);

        if (`SYS.dram_init_type == `CFG_DRAM_INIT && ((no_of_cr_wr + 4) % `CCACHE_DEPTH == 0)) begin
          // the first command of a DCU initialization that has multiple loads may
          // result in bigger time than normal
          if (cmd2cmd_clks < xpctd_cmd_spacing) begin
            `SYS.error_message(`CTRL_RDIMM, `CMDTIMEERR, xpctd_cmd_spacing);
          end
        end else begin
          if (cmd2cmd_clks !== xpctd_cmd_spacing) begin
            `SYS.error_message(`CTRL_RDIMM, `CMDTIMEERR, xpctd_cmd_spacing);
          end
        end
        
        // save current command time and address and increment number of register write count
        prev_time    = curr_time;
        prev_cr_addr = cr_addr;
        no_of_cr_wr  = no_of_cr_wr + 1;
      end // if (rdimm_mnt_en)
    end
    
  endtask // log_rdimm_init_command
  
`endif //  `ifdef DWC_DDR_RDIMM

endmodule // ddr_mnt
