/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DFI Monitor                                                   *
 *              Monitors the interface bus between the DDR Memory Controller  *
 *              and the interface from PHY to DDR SDRAMs                      *
 *                                                                            *
 *****************************************************************************/

`ifdef DWC_DDRPHY_EMUL_XILINX
  `define AC_PHY_CLK clk
`else
  `define AC_PHY_CLK `AC.ctl_clk
`endif

module dfi_mnt
  (
   rst_b,     // asynshronous reset
   clk,       // clock

   ck_inv,
   t_byte_wl_odd,
   t_byte_rl_odd,

   wl,
   rl,
   
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
   dfi_phyupd_type,
   dfi_phyupd_ack, 
  
   // DFI Status Interface
   dfi_init_start,
   dfi_data_byte_disable,
   dfi_dram_clk_disable,
   dfi_init_complete,
   dfi_parity_in,
   dfi_alert_n,

   // DFI Training Interface
   dfi_rdlvl_resp,
   dfi_rdlvl_load,
   dfi_rdlvl_cs_n,
  
   dfi_rdlvl_mode,
  
   dfi_rdlvl_req,    
   dfi_rdlvl_en,     
   dfi_rdlvl_edge,   
   dfi_rdlvl_delay_X,
  
   dfi_rdlvl_gate_mode,
  
   dfi_rdlvl_gate_req,    
   dfi_rdlvl_gate_en,     
   dfi_rdlvl_gate_delay_X,
  
   dfi_wrlvl_mode,

   dfi_wrlvl_resp,   
   dfi_wrlvl_load,   
   dfi_wrlvl_cs_n,   
   dfi_wrlvl_strobe, 
   dfi_wrlvl_req,    
   dfi_wrlvl_en,     
   dfi_wrlvl_delay_X,

   // Low Power Control Interface
   dfi_lp_data_req,    
   dfi_lp_ctrl_req,    
   dfi_lp_wakeup, 
   dfi_lp_ack
   );

  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  // configurable design parameters
  parameter pNO_OF_BYTES = 9; 
  parameter pNO_OF_RANKS = 2;
  // Changed how num of channels is calculated for Gen2.
  // parameter pSHARED_AC   = ((`DWC_NO_OF_BYTES > 1) && (`DWC_NO_OF_RANKS > 1));
`ifdef DWC_USE_SHARED_AC_TB
  parameter pSHARED_AC   = 1;
`else
  parameter pSHARED_AC   = 0;
`endif
  parameter pCK_WIDTH    = 3;
  parameter pBANK_WIDTH  = 3;
  parameter pBG_WIDTH    = 2;
  parameter pADDR_WIDTH  = 16;
  parameter pCLK_NX      = `CLK_NX; // PHY clock is 2x or 1x controller clock
  parameter pNO_OF_DX_DQS     = `DWC_DX_NO_OF_DQS; // number of DQS signals per DX macro
  parameter pNUM_LANES        = pNO_OF_DX_DQS * pNO_OF_BYTES;
    
  // if LPDDR3/2 mode support is enabled, the DFI address is 20 bits wide
  parameter pXADDR_WIDTH     = pADDR_WIDTH;

  parameter WL_WIDTH     = 6,
            RL_WIDTH     = 6;

`ifdef DWC_ALERTN_NEG_CLK
  parameter pERR_PIPE_DEPTH = 3 + `DWC_CDC_SYNC_STAGES - 2;
`else
  parameter pERR_PIPE_DEPTH = 2 + `DWC_CDC_SYNC_STAGES - 2;
`endif

  
  // control logic encoding
  // ----------------------
  // SDRAM controller commands
  // command bits [3:0]:
  parameter LOAD_MODE      = 6'b110000, // load mode register
            REFRESH        = 6'b110001, // refresh
            SELF_REFRESH   = 6'b100001, // self refresh entry
            PRECHARGE      = 6'b110010, // precharge
            ACTIVATE       = 6'b110011, // bank activate
            WRITE          = 6'b110100, // write
            READ           = 6'b110101, // read
            ZQCAL          = 6'b110110, // ZQ calibration
            NOP            = 6'b110111, // no operation
            DESELECT       = 6'b111111, // device deselect
            POWER_DOWN     = 6'b100111, // power down entry
            POWER_DWN_EXIT = 6'b010111, // power down exit
            SELF_RFSH_EXIT = 6'b010111, // self refresh exit
            CLOCK_DISABLE  = 6'b00????; // clock disable

  parameter p_t_ctrl_delay     = 2;
  
  parameter MAX_DFI_PTR        = 30;
  parameter MAX_PTR            = 20;

  // DFI PHY Update State Monitor
  localparam pS_DFI_PHYUPD_STATE_IDLE    = 0
  ,          pS_DFI_PHYUPD_STATE_DRIFT   = 1
  ,          pS_DFI_PHYUPD_STATE_UPDATE  = 2
  ;

  // Number of independent channels
  parameter pNUM_CHANNELS      = (pSHARED_AC == 1) ? 2 : 1;
  parameter pCHN_IDX           = 0;
  parameter pCHN0_IDX          = 0;
  parameter pCHN1_IDX          = (pNUM_CHANNELS - 1);
  parameter pCHN0_DX8_NUM      = (pSHARED_AC == 1) ? (`DWC_NO_OF_BYTES/2)                      : `DWC_NO_OF_BYTES;
  parameter pCHN1_DX8_NUM      = (pSHARED_AC == 1) ? (`DWC_NO_OF_BYTES - (`DWC_NO_OF_BYTES/2)) : `DWC_NO_OF_BYTES;
  localparam pCHN0_DX_IDX_LO   = 0
  ,          pCHN0_DX_IDX_HI   = (pSHARED_AC == 1) ? (pCHN0_DX8_NUM - 1) : (pNO_OF_BYTES - 1)
  ,          pCHN1_DX_IDX_LO   = (pSHARED_AC == 1) ? pCHN0_DX8_NUM       : 0
  ,          pCHN1_DX_IDX_HI   = (pSHARED_AC == 1) ? (pNO_OF_BYTES - 1)  : 0
  ;

  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                               rst_b;       // asynchronous reset
  input                               clk;         // input clock
  
  input [pCK_WIDTH              -1:0] ck_inv;
  input [pNO_OF_BYTES           -1:0] t_byte_wl_odd;
  input [pNO_OF_BYTES           -1:0] t_byte_rl_odd;

  input [WL_WIDTH               -1:0] wl;
  input [RL_WIDTH               -1:0] rl;

  // DFI Control Interface
  input                               dfi_reset_n;
  input [`DWC_NO_OF_RANKS*pCLK_NX   -1:0] dfi_cke;
  input [`DWC_NO_OF_RANKS*pCLK_NX   -1:0] dfi_odt;
  input [`DWC_NO_OF_RANKS*pCLK_NX   -1:0] dfi_cs_n;
  input [`DWC_CID_WIDTH*pCLK_NX     -1:0] dfi_cid;
  input [pCLK_NX                -1:0] dfi_ras_n;
  input [pCLK_NX                -1:0] dfi_cas_n;
  input [pCLK_NX                -1:0] dfi_we_n;
  input [pBANK_WIDTH*pCLK_NX    -1:0] dfi_bank;
  input [pXADDR_WIDTH*pCLK_NX   -1:0] dfi_address;
  input [pCLK_NX                -1:0] dfi_act_n;
  input [pBG_WIDTH*pCLK_NX      -1:0] dfi_bg;

  // DFI Write Data Interface
  input [pNUM_LANES*pCLK_NX     -1:0] dfi_wrdata_en;
  input [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_wrdata;
  input [pNUM_LANES*pCLK_NX*2   -1:0] dfi_wrdata_mask;

  // DFI Read Data Interface
  input [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_en;
  input [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_valid;
  input [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_rddata;

  // DFI Update Interface
  input                               dfi_ctrlupd_req;
  input                               dfi_ctrlupd_ack;
  input                               dfi_phyupd_req;
  input [1:0]                         dfi_phyupd_type;
  input                               dfi_phyupd_ack;
                                      
  // DFI Status Interface             
  input                               dfi_init_start;
  input [pNO_OF_BYTES           -1:0] dfi_data_byte_disable;
  input [pCK_WIDTH              -1:0] dfi_dram_clk_disable;
  input                               dfi_init_complete;
  input [pCLK_NX                -1:0] dfi_parity_in;
  input                               dfi_alert_n;
                                      
  input                               dfi_rdlvl_resp;          // *** not connected
  input                               dfi_rdlvl_load;          // *** not connected
  input                               dfi_rdlvl_cs_n;          // *** not connected
                                      
  // DFI Training Interface           
  input [1:0]                         dfi_rdlvl_mode;
                                      
  input                               dfi_rdlvl_req;           // *** not connected
  input                               dfi_rdlvl_en;            // *** not connected
  input                               dfi_rdlvl_edge;          // *** not connected
  input                               dfi_rdlvl_delay_X;       // *** not connected
                                      
  input [1:0]                         dfi_rdlvl_gate_mode;
                                      
  input                               dfi_rdlvl_gate_req;      // *** not connected
  input                               dfi_rdlvl_gate_en;       // *** not connected
  input                               dfi_rdlvl_gate_delay_X;  // *** not connected
                                      
  input [1:0]                         dfi_wrlvl_mode;
                                      
  input                               dfi_wrlvl_resp;          // *** not connected
  input                               dfi_wrlvl_load;          // *** not connected
  input                               dfi_wrlvl_cs_n;          // *** not connected
  input                               dfi_wrlvl_strobe;        // *** not connected
  input                               dfi_wrlvl_req;           // *** not connected
  input                               dfi_wrlvl_en;            // *** not connected
  input                               dfi_wrlvl_delay_X;       // *** not connected
           
  // Low Power Control Interface
  input                               dfi_lp_data_req;     
  input                               dfi_lp_ctrl_req;     
  input  [3                       :0] dfi_lp_wakeup;  
  input                               dfi_lp_ack;      

  // temporary register to sample dfi command and address
  reg  [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cke_reg   [0:MAX_DFI_PTR-1]; // SDRAM clock enable
  reg  [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_ckep_reg  [0:MAX_DFI_PTR-1]; // SDRAM clock enable previous 
  reg  [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_odt_reg   [0:MAX_DFI_PTR-1]; // SDRAM on-die termination
  reg  [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cs_n_reg  [0:MAX_DFI_PTR-1]; // SDRAM chip select
  reg  [`DWC_CID_WIDTH*pCLK_NX -1:0] dfi_cid_reg   [0:MAX_DFI_PTR-1]; // SDRAM chip ID
  reg  [pCLK_NX                -1:0] dfi_ras_n_reg [0:MAX_DFI_PTR-1]; // SDRAM row address select
  reg  [pCLK_NX                -1:0] dfi_cas_n_reg [0:MAX_DFI_PTR-1]; // SDRAM column address select
  reg  [pCLK_NX                -1:0] dfi_we_n_reg  [0:MAX_DFI_PTR-1]; // SDRAM write enable
  reg  [pBANK_WIDTH*pCLK_NX    -1:0] dfi_ba_reg    [0:MAX_DFI_PTR-1]; // SDRAM bank address
  reg  [pADDR_WIDTH*pCLK_NX    -1:0] dfi_a_reg     [0:MAX_DFI_PTR-1]; // SDRAM address
  
  reg  [pNUM_LANES*pCLK_NX     -1:0] dfi_wrdata_en_reg    [0:MAX_DFI_PTR-1];
  reg  [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_wrdata_reg       [0:MAX_DFI_PTR-1];
  reg  [pNUM_LANES*pCLK_NX*2   -1:0] dfi_wrdata_mask_reg  [0:MAX_DFI_PTR-1];
                                                          
  reg  [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_en_reg    [0:MAX_DFI_PTR-1];
  reg  [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_valid_reg [0:MAX_DFI_PTR-1];
  reg  [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_rddata_reg       [0:MAX_DFI_PTR-1];
 
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cke_word0;   // SDRAM clock enable
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_ckep_word0;  // SDRAM clock enable previous 
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_odt_word0;   // SDRAM on-die termination
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cs_n_word0;  // SDRAM chip select
  wire [`DWC_CID_WIDTH*pCLK_NX -1:0] dfi_cid_word0;   // SDRAM chip ID
  wire [pCLK_NX                -1:0] dfi_ras_n_word0; // SDRAM row address select
  wire [pCLK_NX                -1:0] dfi_cas_n_word0; // SDRAM column address select
  wire [pCLK_NX                -1:0] dfi_we_n_word0;  // SDRAM write enable
  wire [pBANK_WIDTH*pCLK_NX    -1:0] dfi_ba_word0;    // SDRAM bank address
  wire [pADDR_WIDTH*pCLK_NX    -1:0] dfi_a_word0;     // SDRAM address
                                                      
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cke_cmp;     // SDRAM clock enable
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_ckep_cmp;    // SDRAM clock enable previous 
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_odt_cmp;     // SDRAM on-die termination
  wire [pNO_OF_RANKS*pCLK_NX   -1:0] dfi_cs_n_cmp;    // SDRAM chip select
  wire [`DWC_CID_WIDTH*pCLK_NX -1:0] dfi_cid_cmp;     // SDRAM chip ID
  wire [pCLK_NX                -1:0] dfi_ras_n_cmp;   // SDRAM row address select
  wire [pCLK_NX                -1:0] dfi_cas_n_cmp;   // SDRAM column address select
  wire [pCLK_NX                -1:0] dfi_we_n_cmp;    // SDRAM write enable
  wire [pBANK_WIDTH*pCLK_NX    -1:0] dfi_ba_cmp;      // SDRAM bank address
  wire [pADDR_WIDTH*pCLK_NX    -1:0] dfi_a_cmp;
                               
  wire [pNUM_LANES*pCLK_NX     -1:0] dfi_wrdata_en_cmp;
  wire [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_wrdata_cmp;
  wire [pNUM_LANES*pCLK_NX*2   -1:0] dfi_wrdata_mask_cmp;
                               
  wire [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_en_cmp;
  wire [pNUM_LANES*pCLK_NX     -1:0] dfi_rddata_valid_cmp;
  wire [pNO_OF_BYTES*pCLK_NX*16-1:0] dfi_rddata_cmp;
  
  integer                      ptr;
  reg                          word;
  reg                          mnt_en;     // dfi command/address monitor
  reg                          mnt_enable;
  reg                          skip_rddata_valid_chk;
  reg                          rpt_err;
  
  reg [31:0]                   op;
  reg [31:0]                   dfi_op, dfi_op_upr;
  reg                          bl4_otf, bl4_otf_upr;

  // DFI Timing parameters
  reg [8:0]                    cnt;
  reg [8:0]                    mnt_cnt;
  integer                      t_ctrl_delay;
  integer                      t_phy_wrlat;
  integer                      t_rddata_en;
  integer                      t_phy_rdlat;
  integer                      t_dram_clk_disable;
  integer                      t_dram_clk_enable; 

  reg [5 - 1 : 0]              max_gdqs_rsl;
  integer                      fixed_rd_lat;

  // DFI PHY Update State Monitor
  integer                      dfi_phyupd_state_mon;

  reg [pERR_PIPE_DEPTH-1:0]    xpctd_err_out_ff;
  reg [2:0]                    err_out_chk_en_ff;
  wire                         xpctd_err_out, xpctd_err_out_1_off;
  wire                         err_out_chk_en;
  integer                      no_of_unsync_err;
  
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------

  integer max_rd_fifo_num_entries        [pNUM_LANES - 1 : 0];
  integer max_gdqs_dly_fifo_num_entries  [pNUM_LANES - 1 : 0];
  integer max_rd_lat_odd_fifo_num_entries[pNUM_LANES - 1 : 0];
  integer max_wr_lat_odd_fifo_num_entries[pNUM_LANES - 1 : 0];
  integer max_wl_dly_sel_fifo_num_entries[pNUM_LANES - 1 : 0];
  integer datx8_idx;
  
  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize
      mnt_enable = 1'b0;

      // set default to skip rddata_valid unless it is fixed latency
      if (`DWC_FIXED_LAT == 1) skip_rddata_valid_chk = 0;
      else                     skip_rddata_valid_chk = 1;
      
      rpt_err    = 1;
      xpctd_err_out_ff  = 0;
      err_out_chk_en_ff = 0;
      no_of_unsync_err  = 0;
    end

  always @(posedge clk or rst_b)
    begin

      if (rst_b == 0)
        cnt <= 0;
      else begin
        cnt <= cnt + 1;
        if (cnt == 10) begin
          // sample the settings
          t_ctrl_delay       <= p_t_ctrl_delay;      
          t_phy_wrlat        <= (wl %2) ? (wl - 3)/2 : (wl - 4)/2;       
          t_rddata_en        <= (rl %2) ? (rl - 3)/2 : (rl - 4)/2;      

          if (`DWC_FIXED_LAT == 0) begin
            `ifdef MSD_HDR_ODD_CMD
              t_phy_rdlat <= (rl %2) ? 9: 9;  
            `else
              t_phy_rdlat <= (rl %2) ? 8: 9;
            `endif
          end
          else
            t_phy_rdlat <= fixed_rd_lat; 
 
          t_dram_clk_disable   <= 0;
          t_dram_clk_enable    <= 0;
        end
      end
    end
  
  
  //---------------------------------------------------------------------------
  // Enable for dfi monitor and dfi mnt report error
  //---------------------------------------------------------------------------
  task dfi_mnt_enable;
    input  en;
    begin
      mnt_enable = en;
    end
  endtask // dfi_mnt_enable

  
  task dfi_mnt_report_err;
    input rpt;
    begin
      rpt_err = rpt;
    end
  endtask // dfi_mnt_report_err
  
  
  always @(posedge clk or rst_b)
    begin
      if (rst_b === 1'b0) begin
        mnt_en <= 1'b0;
        mnt_cnt <= 0;
      end
      else begin
        if ((`SYS.phy_init_done === 1'b1) && (mnt_enable === 1'b1)) begin
          mnt_cnt <= mnt_cnt + 1;

          // wait extra clocks before turning monitor on
          if (mnt_cnt == 100)
            mnt_en <= 1'b1;
        end
        else
          if (mnt_enable === 1'b0)
            mnt_en <= 1'b0;
        
      end
    end
  

`ifndef DWC_DDRPHY_EMUL_XILINX
  //---------------------------------------------------------------------------
  // DFI PHY Update State Monitor
  // Track the expected state of the VT-update sequence in response to the
  // indicated drift.
  //---------------------------------------------------------------------------
  initial
    dfi_phyupd_state_mon = pS_DFI_PHYUPD_STATE_IDLE;

  always @* begin : dfi_phyupd_state_monitor
    case (dfi_phyupd_state_mon)
      pS_DFI_PHYUPD_STATE_IDLE: 
        begin
          if (`PHYDFI.phy_vt_drift | `PHYDFI.ctl_vt_drift) // There is drift; update has not started
            dfi_phyupd_state_mon <= pS_DFI_PHYUPD_STATE_DRIFT;
        end
      pS_DFI_PHYUPD_STATE_DRIFT: 
        begin
          if (`PHYDFI.phy_vt_drift | `PHYDFI.ctl_vt_drift) // Update has begun
            dfi_phyupd_state_mon <= pS_DFI_PHYUPD_STATE_UPDATE;
        end
      pS_DFI_PHYUPD_STATE_UPDATE: 
        begin
          if (!(`PHYDFI.phy_vt_drift | `PHYDFI.ctl_vt_drift)) // Update is done
            dfi_phyupd_state_mon <= pS_DFI_PHYUPD_STATE_IDLE;
        end
    endcase
  end
`endif

  //---------------------------------------------------------------------------
  // DFI PHY Update Request Monitor
  //---------------------------------------------------------------------------
  always @(posedge clk or rst_b)
    begin: phyupd_ack_monitor
      integer   t_phyupd_type;
      integer   cnt;
      reg       ack_rcvd;
      reg       dfi_phyupd_req_p;
      

      if (!rst_b) begin
        cnt       <= 0;
        ack_rcvd  <= 0;
        dfi_phyupd_req_p <= 0;
      end
      else begin
        dfi_phyupd_req_p <= dfi_phyupd_req;
        
        // check for any dfi_phyup_req and dfi_phyupd_ack
        if (dfi_phyupd_req) begin
          cnt <= cnt + 1;

          case (dfi_phyupd_type)
            2'b00: t_phyupd_type = `DFI_PHYUPD_TYPE0;
            2'b01: t_phyupd_type = `DFI_PHYUPD_TYPE1;
            2'b10: t_phyupd_type = `DFI_PHYUPD_TYPE2;
            2'b11: t_phyupd_type = `DFI_PHYUPD_TYPE3;
            default: t_phyupd_type = `DFI_PHYUPD_TYPE0;
          endcase // case(dfi_phyupd_type)

          if (dfi_phyupd_ack == 1'b1) begin
            if (ack_rcvd == 1'b0) begin
              cnt       <= 0;
              ack_rcvd  <= 1;
            end
            else begin
              if (cnt > t_phyupd_type && mnt_en) begin
                `SYS.error;
                $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_phyupd_ack deassert before t_phyupd_type = %0d clock cycles  got %0d", $time, t_phyupd_type, cnt);
              end
            end
          end
          else begin
            // dfi_phyupd_ack = 0
            //ack_rcvd <= 0;
            if ((cnt > `t_phyupd_resp) && (ack_rcvd == 1'b0) && mnt_en) begin
              `SYS.error;
              $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_phyupd_ack assert before t_phyupd_resp = %0d clock cycles  got %0d", $time, `t_phyupd_resp, cnt);
            end
          end
        end

        // reset when not vt_drift and expect ack to be deasserted 1 clock after req is done
        else begin
          cnt       <= 0;
          ack_rcvd  <= 0;
          if ((dfi_phyupd_req_p == 1'b0) && (dfi_phyupd_ack == 1'b1) && mnt_en) begin
            `SYS.error;
            $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_phyupd_ack deassert after req is done", $time);
          end
        end

      end
    end
  

  //---------------------------------------------------------------------------
  // DFI CTRL Update Request and Acknowledge Monitor
  //---------------------------------------------------------------------------
  always @(posedge clk or rst_b)
    begin: ctrlupd_monitor
      integer   cnt;
      reg       ack_rcvd;
      reg       dfi_ctrlupd_req_p;

      if (!rst_b) begin
        cnt       <= 0;
        ack_rcvd  <= 0;
        dfi_ctrlupd_req_p <= 0;
      end
      else begin      
        dfi_ctrlupd_req_p <= dfi_ctrlupd_req;

        // check for any dfi_ctrlupd_req and dfi_ctrlupd_ack
        if (dfi_ctrlupd_req) begin
          cnt     <= cnt + 1;

          // Check for ACK 
          if (dfi_ctrlupd_ack == 1'b1) begin
            if (ack_rcvd == 1'b0) begin
              // first time ack appears, check the response time
              if (cnt > `t_ctrlupd_min && mnt_en) begin
                `SYS.error;
                $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_ctrlupd_ack assert before t_ctrlupd_min = %0d clock cycles   got  %0d", $time, `t_ctrlupd_min, cnt);
              end
              //cnt       <= 0;
              ack_rcvd  <= 1;
            end
            else begin
              // not the first time ack is asserted, just checks for max
              if (cnt > `t_ctrlupd_max && mnt_en) begin
                `SYS.error;
                $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_ctrlupd_ack deassert before t_ctrlupd_max = %0d clock cycles   got  %0d", $time, `t_ctrlupd_max, cnt);
              end
            end
          end
          else begin  // !(dfi_ctrlupd_ack == 1'b1)
            // ack not received or already deasserted
            // PHY might choose to ignore request; do nothing
          end

          // Check for REQ not to exceed max
          if (cnt > `t_ctrlupd_max && mnt_en) begin
            `SYS.error;
            $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_ctrlupd_req deassert before t_ctrlupd_max = %0d clock cycles   got  %0d", $time, `t_ctrlupd_max, cnt);
          end
        end
        // ! (dfi_ctrlupd_req)
        else begin
          cnt <= 0;
          // check for ctrlup req min time        
          if ((dfi_ctrlupd_req == 1'b0) && (dfi_ctrlupd_req_p == 1'b1)) begin
            ack_rcvd <= 1'b0;
            if ((cnt < `t_ctrlupd_min) && (ack_rcvd == 1'b0)) begin
              `SYS.error;
              $display("-> %0t: [DFI_MNT] ERROR: Expecting dfi_ctrlupd_req to stay asserted until after t_ctrlupd_min = %0d clock cycles   got  %0d", $time, `t_ctrlupd_min, cnt);
            end
          end
        end // else: !if(dfi_ctrlupd_req)
        
      end // else: !if(!rst_b)
    end

`ifndef DWC_DDRPHY_EMUL_XILINX
  //---------------------------------------------------------------------------
  // Track the maximum depth used in the read data FIFO
  //---------------------------------------------------------------------------

  initial begin
    for (datx8_idx = 0; datx8_idx < pNUM_LANES; datx8_idx = datx8_idx + 1) begin
      max_rd_fifo_num_entries        [datx8_idx] = 0;
      max_gdqs_dly_fifo_num_entries  [datx8_idx] = 0;
      max_rd_lat_odd_fifo_num_entries[datx8_idx] = 0;
      max_wr_lat_odd_fifo_num_entries[datx8_idx] = 0;
      max_wl_dly_sel_fifo_num_entries[datx8_idx] = 0;
    end
  end

  genvar bl_idx;

  // MIKE, need to update this..
/*  
  generate

    for (bl_idx = 0; bl_idx < (pNUM_LANES); bl_idx = bl_idx + 1) begin : gen_track_fifo_max_entries
      always @(negedge clk) begin
        // Read data FIFO
        if (`PHYDFI.chn[0].dx.dx_ctl.rd.dx[bl_idx].u_dx_rd.u_fifo.num_entries > max_rd_fifo_num_entries[bl_idx])
          max_rd_fifo_num_entries[bl_idx] = `PHYDFI.chn[0].dx.dx_ctl.rd.dx[bl_idx].u_dx_rd.u_fifo.num_entries;
        // Read gdqs_dly FIFO
        if (`PHYDFI.chn[0].dx.dx_ctl.rd.dx[bl_idx].u_dx_rd.u_fifo_gdqs_dly.num_entries > max_gdqs_dly_fifo_num_entries[bl_idx])
          max_gdqs_dly_fifo_num_entries[bl_idx] = `PHYDFI.chn[0].dx.dx_ctl.rd.dx[bl_idx].u_dx_rd.u_fifo_gdqs_dly.num_entries;
//ROB -removed fifo        // Read latency-odd FIFO
//ROB -removed fifo        if (`PHYDFI.chn[0].dx.dx_ctl.rd.dx[bl_idx].u_dx_rd.u_fifo_rd_lat_odd.num_entries > max_rd_lat_odd_fifo_num_entries[bl_idx])
//ROB -removed fifo          max_rd_lat_odd_fifo_num_entries[bl_idx] = `PHYDFI.chn[0].dx.dx_ctl.rd.dx[bl_idx].u_dx_rd.u_fifo_rd_lat_odd.num_entries;
//ROB -removed fifo        // Write wl_dly FIFO
//ROB -removed fifo        if (`PHYDFI.chn[0].dx.dx_ctl.dx_wr[bl_idx].u_dx_wr.u_fifo_wl_dly_sel.num_entries > max_wl_dly_sel_fifo_num_entries[bl_idx])
//ROB -removed fifo          max_wl_dly_sel_fifo_num_entries[bl_idx] = `PHYDFI.chn[0].dx.dx_ctl.dx_wr[bl_idx].u_dx_wr.u_fifo_wl_dly_sel.num_entries;
//ROB -removed fifo        // Write wl_sel FIFO
//ROB -removed fifo        if (`PHYDFI.chn[0].dx.dx_ctl.dx_wr[bl_idx].u_dx_wr.u_fifo_wr_lat_odd.num_entries > max_wr_lat_odd_fifo_num_entries[bl_idx])
//ROB -removed fifo          max_wr_lat_odd_fifo_num_entries[bl_idx] = `PHYDFI.chn[0].dx.dx_ctl.dx_wr[bl_idx].u_dx_wr.u_fifo_wr_lat_odd.num_entries;
      end
    end

  endgenerate 
*/ 
`endif
  
  //---------------------------------------------------------------------------
  // Command Monitor
  //---------------------------------------------------------------------------

  // Sample incoming dfi commands and address
  // Here the phy_clk of AC was used instead of ctl_clk as the phase between
  // the two clocks might not align
  
  always @(posedge `AC_PHY_CLK or negedge rst_b or dfi_reset_n)
    begin: sample_dfi_bus
      integer i;
      
      if ((rst_b === 1'b0) || (dfi_reset_n === 1'b0)) begin
        for (i=0; i<MAX_DFI_PTR; i=i+1) begin
          dfi_cke_reg[i]    <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_ckep_reg[i]   <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_odt_reg[i]    <= {(pNO_OF_RANKS*pCLK_NX){1'b0}};
          dfi_cs_n_reg[i]   <= {(pNO_OF_RANKS*pCLK_NX){1'b1}};
          dfi_cid_reg[i]    <= {(`DWC_CID_WIDTH*pCLK_NX){1'b0}};
          dfi_ras_n_reg[i]  <= {(pNO_OF_RANKS*pCLK_NX){1'b1}};
          dfi_cas_n_reg[i]  <= {(pNO_OF_RANKS*pCLK_NX){1'b1}};   
          dfi_we_n_reg[i]   <= {(pNO_OF_RANKS*pCLK_NX){1'b1}};   
          dfi_ba_reg[i]     <= {(pBANK_WIDTH*pCLK_NX){1'b0}};
          dfi_a_reg[i]      <= {(pADDR_WIDTH*pCLK_NX){1'b0}};

          dfi_wrdata_en_reg[i]     <= {pNUM_LANES*pCLK_NX{1'b0}};
          dfi_wrdata_reg[i]        <= {(pNO_OF_BYTES*pCLK_NX*16){1'b0}};
          dfi_wrdata_mask_reg[i]   <= {(pNUM_LANES*pCLK_NX*2){1'b0}};
          
          dfi_rddata_en_reg[i]     <= {pNUM_LANES*pCLK_NX{1'b0}};
          dfi_rddata_valid_reg[i]  <= {pNUM_LANES*pCLK_NX{1'b0}}; 
          dfi_rddata_reg[i]        <= {(pNO_OF_BYTES*pCLK_NX*16){1'b0}};
        end
      end                 
      else begin
        for (i=1; i<MAX_DFI_PTR; i=i+1) begin
          dfi_cke_reg[i]    <= dfi_cke_reg[i-1];
          dfi_ckep_reg[i]   <= dfi_ckep_reg[i-1];
          dfi_odt_reg[i]    <= dfi_odt_reg[i-1];
          dfi_cs_n_reg[i]   <= dfi_cs_n_reg[i-1];
          dfi_cid_reg[i]    <= dfi_cid_reg[i-1];
          dfi_ras_n_reg[i]  <= dfi_ras_n_reg[i-1];
          dfi_cas_n_reg[i]  <= dfi_cas_n_reg[i-1];
          dfi_we_n_reg[i]   <= dfi_we_n_reg[i-1];
          dfi_ba_reg[i]     <= dfi_ba_reg[i-1];
          dfi_a_reg[i]      <= dfi_a_reg[i-1];

          dfi_wrdata_en_reg[i]     <= dfi_wrdata_en_reg[i-1];
          dfi_wrdata_reg[i]        <= dfi_wrdata_reg[i-1];
          dfi_wrdata_mask_reg[i]   <= dfi_wrdata_mask_reg[i-1];
          
          dfi_rddata_en_reg[i]     <= dfi_rddata_en_reg[i-1];
          dfi_rddata_valid_reg[i]  <= dfi_rddata_valid_reg[i-1];
          dfi_rddata_reg[i]        <= dfi_rddata_reg[i-1];
        end
        
        dfi_cke_reg[0]    <= dfi_cke;
        dfi_ckep_reg[0]   <= dfi_cke_reg[0];
        dfi_odt_reg[0]    <= dfi_odt;
        dfi_cs_n_reg[0]   <= dfi_cs_n;
        dfi_cid_reg[0]    <= dfi_cid;
        dfi_ras_n_reg[0]  <= dfi_ras_n;
        dfi_cas_n_reg[0]  <= dfi_cas_n;
        dfi_we_n_reg[0]   <= dfi_we_n;
        dfi_ba_reg[0]     <= dfi_bank;
        dfi_a_reg[0]      <= dfi_address;

        dfi_wrdata_en_reg[0]     <= dfi_wrdata_en;
        dfi_wrdata_reg[0]        <= dfi_wrdata;
        dfi_wrdata_mask_reg[0]   <= dfi_wrdata_mask;
        
        dfi_rddata_en_reg[0]     <= dfi_rddata_en;
        dfi_rddata_valid_reg[0]  <= dfi_rddata_valid;
        dfi_rddata_reg[0]        <= dfi_rddata;
      end
    end


  // sampled word0; used for comparing the command/address bus to SDRAM in ck domain
  assign dfi_cke_word0    = dfi_cke_reg[1];  
  assign dfi_ckep_word0   = dfi_ckep_reg[1]; 
  assign dfi_odt_word0    = dfi_odt_reg[1];  
  assign dfi_cs_n_word0   = dfi_cs_n_reg[1]; 
  assign dfi_cid_word0    = dfi_cid_reg[1]; 
  assign dfi_ras_n_word0  = dfi_ras_n_reg[1];
  assign dfi_cas_n_word0  = dfi_cas_n_reg[1];
  assign dfi_we_n_word0   = dfi_we_n_reg[1]; 
  assign dfi_ba_word0     = dfi_ba_reg[1];
  assign dfi_a_word0      = dfi_a_reg[1];

  assign dfi_wrdata_en_word0      = dfi_wrdata_en_reg[1];    
  assign dfi_wrdata_word0         = dfi_wrdata_reg[1];       
  assign dfi_wrdata_mask_word0    = dfi_wrdata_mask_reg[1];  

  assign dfi_rddata_en_word0      = dfi_rddata_en_reg[1];    
  assign dfi_rddata_valid_word0   = dfi_rddata_valid_reg[1]; 
  assign dfi_rddata_word0         = dfi_rddata_reg[1];       


  // -----------------------------------------------------------------------------
  //
  // dfi_*_cmp signals are MAX_DFI_PTR-1 phy_clk clocks away in the pipeline.
  //
  // For WRITE command, it is used to look for the number of phy_clk clocks when
  // wrdata_en should occur, and wrdata and wrdta_mask is expected
  //
  // For Read command, it is used to look for the number of phy_clk clocks when
  // rddata_en should occur, and rddata and rddata_valid expected.
  //
  // For Activate command, the row address is stored from the dfi_a_cmp
  //
  // Other op code has yet to be implemented.
  //
  // -----------------------------------------------------------------------------
  assign dfi_cke_cmp    = dfi_cke_reg   [MAX_DFI_PTR-1];  
  assign dfi_ckep_cmp   = dfi_ckep_reg  [MAX_DFI_PTR-1]; 
  assign dfi_odt_cmp    = dfi_odt_reg   [MAX_DFI_PTR-1];  
  assign dfi_cs_n_cmp   = dfi_cs_n_reg  [MAX_DFI_PTR-1]; 
  assign dfi_cid_cmp    = dfi_cid_reg   [MAX_DFI_PTR-1]; 
  assign dfi_ras_n_cmp  = dfi_ras_n_reg [MAX_DFI_PTR-1];
  assign dfi_cas_n_cmp  = dfi_cas_n_reg [MAX_DFI_PTR-1];
  assign dfi_we_n_cmp   = dfi_we_n_reg  [MAX_DFI_PTR-1]; 
  assign dfi_ba_cmp     = dfi_ba_reg    [MAX_DFI_PTR-1];
  assign dfi_a_cmp      = dfi_a_reg     [MAX_DFI_PTR-1];

  assign dfi_wrdata_en_cmp      = dfi_wrdata_en_reg   [MAX_DFI_PTR-1];    
  assign dfi_wrdata_cmp         = dfi_wrdata_reg      [MAX_DFI_PTR-1];       
  assign dfi_wrdata_mask_cmp    = dfi_wrdata_mask_reg [MAX_DFI_PTR-1];  

  assign dfi_rddata_en_cmp      = dfi_rddata_en_reg    [MAX_DFI_PTR-1]; 
  assign dfi_rddata_cmp         = dfi_rddata_reg       [MAX_DFI_PTR-1];   
  assign dfi_rddata_valid_cmp   = dfi_rddata_valid_reg [MAX_DFI_PTR-1];   


  // -----------------------------------------------------------------------------
  // Monitor fixed read latency
  // 
  // -----------------------------------------------------------------------------

  always @* begin : monitor_dfi_fixed_rd_lat
    if (`DWC_FIXED_LAT == 1) begin
      max_gdqs_rsl = get_max_rsl(`PHYDFI.gdqs_rsl);
      // add one additional clock delay for DFI-to-MCTL pipeline stages
      fixed_rd_lat = max_gdqs_rsl[4:2] + 1 + 2 + 2 + 6 + 1 + `DWC_PIPE_DFI2MCTL + `GRM.pgcr2[28];
      // Apply check only when there's at least one byte-lane enabled
      if ((|(`PHYDFI.byte_en)) && (dfi_rddata_valid_reg[0] != dfi_rddata_en_reg[fixed_rd_lat]) && mnt_en) begin
        `SYS.error;
        $display("-> %0t: [DFI_MNT] ERROR: fixed read latency - dfi_rddata_valid does not match dfi_rddata_en %0d cycles prior", $time, fixed_rd_lat);
      end
    end
  end

  // Figure out the maximum gdqs_rsl value of all the rank/byte-lane values
  function integer get_max_rsl;
    input [(pNO_OF_BYTES * 4 * 5) - 1 : 0] all_rsl_fields;  // Assume 4 ranks for some reason...

    integer max_rsl;
    integer i;

    begin
      max_rsl = all_rsl_fields[4:0];
      for (i = 1; i < (pNO_OF_BYTES * 4); i = i + 1) begin
        if (max_rsl < all_rsl_fields[(5 * i) +: 5])
          max_rsl = all_rsl_fields[(5 * i) +: 5];
      end
      get_max_rsl = max_rsl;
    end
  endfunction


`ifdef DWC_NO_BUBBLES  
  // -----------------------------------------------------------------------------
  // Monitor bubble suppression
  // -----------------------------------------------------------------------------
  
  integer         pn_idx;
  integer         dx_idx;
  reg             dfi_rddata_valid_pn [3  - 1 : 0][pNUM_LANES  - 1 : 0];

  // Keep a history of dfi_rddata_valid so we can look for bubbles
  always @* begin
    for (dx_idx = 0; dx_idx < pNO_OF_BYTES; dx_idx = dx_idx + 1)
      dfi_rddata_valid_pn[0][dx_idx] = `PHYDFI.dfi_rddata_valid[dx_idx];
  end

  always @(posedge `PHYDFI.ctl_clk, negedge `PHYDFI.ctl_rst_n) begin
    if (`PHYDFI.ctl_rst_n == 1'b0) begin
      for (pn_idx = 1; pn_idx < 3; pn_idx = pn_idx + 1) begin
        for (dx_idx = 0; dx_idx < `DWC_NO_OF_BYTES; dx_idx = dx_idx + 1)
          dfi_rddata_valid_pn[pn_idx][dx_idx] <= 1'b0;
      end
    end
    else begin
      for (pn_idx = 1; pn_idx < 3; pn_idx = pn_idx + 1) begin
        for (dx_idx = 0; dx_idx < pNO_OF_BYTES; dx_idx = dx_idx + 1)
          dfi_rddata_valid_pn[pn_idx][dx_idx] <= dfi_rddata_valid_pn[pn_idx - 1][dx_idx];
      end
    end
  end

  // If the dfi_rddata_valid is asserted for a single cycle, that's a bubble
  always @* begin
    if (`DWC_NO_BUBBLES == 1) begin
      for (dx_idx = 0; dx_idx < pNO_OF_BYTES; dx_idx = dx_idx + 1) begin
        if (   ((`GRM.dcr[2:0] == 4) && (`GRM.mr0[1:0] == 2'b00 ))  // DDR4 BL8
            || ((`GRM.dcr[2:0] == 3) && (`GRM.mr0[1:0] == 2'b00 ))  // DDR3 BL8
            || ((`GRM.dcr[2:0] == 2) && (`GRM.mr0[2:0] == 3'b011))  // DDR2 BL8
           ) begin
          if (!`PUB.pub_mode && ({dfi_rddata_valid_pn[2][dx_idx], dfi_rddata_valid_pn[1][dx_idx], dfi_rddata_valid_pn[0][dx_idx]} == 3'b010)) begin
            `SYS.error;
            $display("-> %0t: [DFI_MNT] ERROR: Detected bubble in dfi_rddata_valid on lane %0d!", $time, dx_idx);
          end
        end
      end
    end
  end

`endif

  // -----------------------------------------------------------------------------
  // Monitor DFI Command Lower word (even command)
  // 
  // For WRITE command, it is used to look for the number of phy_clk clocks when
  // wrdata_en should occur, and wrdata and wrdta_mask is expected
  //
  // For Read command, it is used to look for the number of phy_clk clocks when
  // rddata_en should occur, and rddata and rddata_valid expected.
  //
  // For Activate command, the row address is stored from the dfi_a_cmp
  //
  // Other op code has yet to be implemented.
  //
  // -----------------------------------------------------------------------------

  always @(posedge `AC_PHY_CLK or negedge rst_b)
    begin: monitor_dfi_command_lwr
      integer                     i,j;
      integer                     wr_en_ptr;
      integer                     rd_en_ptr;
      integer                     rd_data_ptr;
      integer                     wr_bl_loop;
      integer                     rd_bl_loop;

      if (mnt_en === 1'b1) begin

        dfi_op      = 32'hx;
        wr_en_ptr   = 32'hx;
        rd_en_ptr   = 32'hx;
        rd_data_ptr = 32'hx;
        
        // check command coming in and assign event 
        casex ({dfi_ckep_cmp  [0], 
                dfi_cke_cmp   [0], 
                dfi_cs_n_cmp  [0], 
                dfi_ras_n_cmp [0], 
                dfi_cas_n_cmp [0], 
                dfi_we_n_cmp  [0] })

          
          LOAD_MODE:      
            dfi_op = `LOAD_MODE;
          
          REFRESH:
            begin
              dfi_op = `REFRESH;
              // We got a refresh, so set the got_one_refresh flag for all eternity
              //got_one_refresh = 1'b1;
            end
          
          SELF_REFRESH:
            begin
              dfi_op = `SELF_REFRESH;
              //self_rfsh_mode = 1'b1;
            end
          
          PRECHARGE:      
            dfi_op = (dfi_a_cmp[10] === 1'b1) ?`PRECHARGE_ALL : `PRECHARGE;
          
          ACTIVATE:
            begin
              dfi_op = `ACTIVATE;
            end
          
          WRITE:
            begin
              dfi_op = `SDRAM_WRITE;
              wr_en_ptr = MAX_DFI_PTR - 1 - t_phy_wrlat;

              bl4_otf = (`GRM.ddr3_blotf & ~dfi_a_cmp[12]) || (~`GRM.ddr3_blotf && (`GRM.ctrl_burst_len == 1));

              // bl of 4
              if (bl4_otf == 1'b1)
                wr_bl_loop = 1;
              else
                wr_bl_loop = 2;


              for ( i=0;i<wr_bl_loop;i=i+1) begin

                // check for wrdata_en; 
                // wrdata_en should arrive t_phy_wrlat after the command and stay
                // asserted for the length of the data.
                //
                // ie: the wrdata_en is asserted one clock earlier than the wrdata and
                //     deasserted one clock earlier than the wrdata.
                
                if (!(dfi_wrdata_en_reg[wr_en_ptr-i]   == {pNUM_LANES*pCLK_NX{1'b1}} )) begin
                  `SYS.error;
                  $display("-> %0t: [DFI_MNT] ERROR: wrdata_en expected to be set high", $time);
                  $display("-> %0t: [DFI_MNT] ERROR: wrdata_en[%0d] = %0h", $time, wr_en_ptr-i,
                           dfi_wrdata_en_reg[wr_en_ptr-i]);
                end
                else begin
                  if (`SYS.verbose > 7)
                    $display("-> %0t: [DFI_MNT]: wrdata_en[%0d] = %0h", $time, wr_en_ptr-i,
                             dfi_wrdata_en_reg[wr_en_ptr-i]);
                end
              end // for ( i=0;i<bl_loop;i=i+1)
            end // case: WRITE
          
          READ:
            begin
              dfi_op = `SDRAM_READ;
              rd_en_ptr   = MAX_DFI_PTR - 1 - t_rddata_en;
              rd_data_ptr = MAX_DFI_PTR - 1 - t_rddata_en  - t_phy_rdlat;
              
              bl4_otf = (`GRM.ddr3_blotf & ~dfi_a_cmp[12]) || (~`GRM.ddr3_blotf && (`GRM.ctrl_burst_len == 1));

              // bl of 4
              if (bl4_otf == 1'b1)
                rd_bl_loop = 1;
              else
                rd_bl_loop = 2;

              for ( i=0;i<rd_bl_loop;i=i+1) begin

                // check for rddata_en; 
                // rddata_en should arrive t_rddate_en after the command and stay
                // asserted for the length of the data.
                //
                // rddata should arrive t_phy_rdlat after the rddata enable
                //

                if (!(dfi_rddata_en_reg[rd_en_ptr]   == {pNUM_LANES*pCLK_NX{1'b1}} )) begin
                  `SYS.error;
                  $display("-> %0t: [DFI_MNT] ERROR: rddata_en expected to be set high", $time);
                  $display("-> %0t: [DFI_MNT] ERROR: rddata_en[%0d] = %0h", $time, rd_en_ptr,
                           dfi_rddata_en_reg[rd_en_ptr]);
                end
                else begin
                  if (`SYS.verbose > 7)
                    $display("-> %0t: [DFI_MNT] rddata_en[%0d] = %0h", $time, rd_en_ptr,
                             dfi_rddata_en_reg[rd_en_ptr]);
                end

                if ((skip_rddata_valid_chk == 0) &&
                    (dfi_rddata_valid_reg[rd_data_ptr-i]  != {pNUM_LANES*pCLK_NX{1'b1}})) begin
                  `SYS.error;
                  $display("-> %0t: [DFI_MNT] ERROR: rddata valid = %0h  expected = %0h", $time, 
                           dfi_rddata_valid_reg[rd_data_ptr-i], {pNUM_LANES*pCLK_NX{1'b1}});
                  if (`SYS.verbose > 7) begin
                    $display("-> %0t: [DFI_MNT] rd_data_ptr = %0d", $time, rd_data_ptr);
                    for (j=MAX_DFI_PTR-1;j>0;j=j-1) begin
                      $display("-> %0t: [DFI_MNT] dfi_rddata_en_reg[%0d]    = %0h", $time, j, dfi_rddata_en_reg[j]);
                      $display("-> %0t: [DFI_MNT] dfi_rddata_valid_reg[%0d] = %0h", $time, j, dfi_rddata_valid_reg[j]);
                    end
                  end
                end
                else begin
                  if (`SYS.verbose > 7)
                    $display("-> %0t: [DFI_MNT] dfi rddata valid = %0h", $time, dfi_rddata_valid_reg[rd_data_ptr-i]);
                end
              end // for ( i=0;i<rd_bl_loop;i=i+1)
            end // case: READ

          ZQCAL:          
            dfi_op = (dfi_a_cmp[10] === 1'b1) ? `ZQCAL_LONG : `ZQCAL_SHORT;

          NOP,
            CLOCK_DISABLE:  
              dfi_op = `SDRAM_NOP;

          //            DESELECT:       dfi_op = (cs_pb_out == 1'b0) ? `DESELECT : `SDRAM_NOP;

          POWER_DOWN:
            begin
              dfi_op = `POWER_DOWN;
              //power_down_mode = 1'b1;
            end

          /*          
           POWER_DWN_EXIT,
           SELF_RFSH_EXIT:
           begin
           if (self_rfsh_mode === 1'b1)
           begin
           dfi_op = `SELF_RFSH_EXIT;
                  end
           else if (power_down_mode === 1'b1)
           begin
           dfi_op = `POWER_DWN_EXIT;
                  end
           self_rfsh_mode  = 1'b0;
           power_down_mode = 1'b0;
              end
           */ 
        endcase // case({ckep, cke, cs_b, ras_b, cas_b, we_b})

      end
    end

  // -----------------------------------------------------------------------------
  // Monitor DFI Command Upper word (odd command)
  // 
  // For WRITE command, it is used to look for the number of phy_clk clocks when
  // wrdata_en should occur, and wrdata and wrdta_mask is expected
  //
  // For Read command, it is used to look for the number of phy_clk clocks when
  // rddata_en should occur, and rddata and rddata_valid expected.
  //
  // For Activate command, the row address is stored from the dfi_a_cmp
  //
  // Other op code has yet to be implemented.
  //
  // -----------------------------------------------------------------------------
`ifdef DWC_DDRPHY_HDR_MODE
  always @(posedge `AC_PHY_CLK or negedge rst_b)
    begin: monitor_dfi_command_upr
      integer                     i,j;
      integer                     wr_en_ptr_upr;
      integer                     rd_en_ptr_upr;
      integer                     rd_data_ptr_upr;
      integer                     wr_bl_loop_upr;
      integer                     rd_bl_loop_upr;
      
      if (mnt_en === 1'b1) begin

        dfi_op_upr      = 32'hx;
        wr_en_ptr_upr   = 32'hx;
        rd_en_ptr_upr   = 32'hx;
        rd_data_ptr_upr = 32'hx;
        
        // check command coming in and assign event 
        casex ({dfi_ckep_cmp  [1], 
                dfi_cke_cmp   [1], 
                dfi_cs_n_cmp  [1], 
                dfi_ras_n_cmp [1], 
                dfi_cas_n_cmp [1], 
                dfi_we_n_cmp  [1] })

          
          LOAD_MODE:      
            dfi_op_upr = `LOAD_MODE;
          REFRESH:
            begin
              dfi_op_upr = `REFRESH;
            end

          SELF_REFRESH:
            begin
              dfi_op_upr = `SELF_REFRESH;
              //self_rfsh_mode = 1'b1;
            end
          
          PRECHARGE:      
            dfi_op_upr = (dfi_a_cmp[10] === 1'b1) ?`PRECHARGE_ALL : `PRECHARGE;
          
          ACTIVATE:
            begin
              dfi_op_upr = `ACTIVATE;
            end
          
          WRITE:
            begin
              dfi_op_upr = `SDRAM_WRITE;
              wr_en_ptr_upr = MAX_DFI_PTR - 1 - t_phy_wrlat;
              
              bl4_otf_upr = (`GRM.ddr3_blotf & ~dfi_a_cmp[12]) || (~`GRM.ddr3_blotf && (`GRM.ctrl_burst_len == 1));

              // bl of 4
              if (bl4_otf_upr == 1'b1)
                wr_bl_loop_upr = 1;
              else
                wr_bl_loop_upr = 2;


              for ( i=0;i<wr_bl_loop_upr;i=i+1) begin

                // check for wrdata_en; 
                // wrdata_en should arrive t_phy_wrlat after the command and stay
                // asserted for the length of the data.
                //
                // ie: the wrdata_en is asserted one clock earlier than the wrdata and
                //     deasserted one clock earlier than the wrdata.
                if (!(dfi_wrdata_en_reg[wr_en_ptr_upr]   == {pNUM_LANES*pCLK_NX{1'b1}} )) begin
                  `SYS.error;
                  $display("-> %0t: [DFI_MNT] ERROR: wrdata_en expected to be set high", $time);
                  $display("-> %0t: [DFI_MNT] ERROR: wrdata_en[%0d] = %0h", $time,wr_en_ptr_upr,
                           dfi_wrdata_en_reg[wr_en_ptr_upr]);
                end
                else begin
                  if (`SYS.verbose > 7)
                    $display("-> %0t: [DFI_MNT]: wrdata_en[%0d] = %0h", $time, wr_en_ptr_upr,
                             dfi_wrdata_en_reg[wr_en_ptr_upr]);
                end
                
              end // for ( i=0;i<wr_bl_loop_upr;i=i+1)
            end // case: WRITE
          
          READ:
            begin
              dfi_op_upr = `SDRAM_READ;
              rd_en_ptr_upr   = MAX_DFI_PTR - 1 - t_rddata_en;
              rd_data_ptr_upr = MAX_DFI_PTR - 1 - t_rddata_en  - t_phy_rdlat;
              
              bl4_otf_upr = (`GRM.ddr3_blotf & ~dfi_a_cmp[12]) || (~`GRM.ddr3_blotf && (`GRM.ctrl_burst_len == 1));

              // bl of 4
              if (bl4_otf_upr == 1'b1) 
                rd_bl_loop_upr = 1;
              else
                rd_bl_loop_upr = 2;

              for ( i=0;i<rd_bl_loop_upr;i=i+1) begin

                
                // check for rddata_en; 
                // rddata_en should arrive t_rddate_en after the command and stay
                // asserted for the length of the data.
                //
                // rddata should arrive t_phy_rdlat after the rddata enable
                //

                if (!(dfi_rddata_en_reg[rd_en_ptr_upr]   == {pNUM_LANES*pCLK_NX{1'b1}} )) begin
                  `SYS.error;
                  $display("-> %0t: [DFI_MNT] ERROR: rddata_en expected to be set high for bl=4", $time);
                  $display("-> %0t: [DFI_MNT] ERROR: rddata_en[%0d] = %0h", $time, rd_en_ptr_upr,
                           dfi_rddata_en_reg[rd_en_ptr_upr]);
                end
                else begin
                  if (`SYS.verbose > 7)
                    $display("-> %0t: [DFI_MNT] rddata_en[%0d] = %0h", $time, rd_en_ptr_upr,
                             dfi_rddata_en_reg[rd_en_ptr_upr]);
                end

                if ((skip_rddata_valid_chk == 0) &&
                    (dfi_rddata_valid_reg[rd_data_ptr_upr-i]  != {pNUM_LANES*pCLK_NX{1'b1}})) begin
                  `SYS.error;
                  $display("-> %0t: [DFI_MNT] ERROR: rddata valid = %0h  expected = %0h", $time, 
                           dfi_rddata_valid_reg[rd_data_ptr_upr-i], {pNUM_LANES*pCLK_NX{1'b1}});
                  if (`SYS.verbose > 7) begin
                    $display("-> %0t: [DFI_MNT] rd_data_ptr_upr = %0d", $time, rd_data_ptr_upr);
                    for (j=MAX_DFI_PTR-1;j>0;j=j-1) begin
                      $display("-> %0t: [DFI_MNT] dfi_rddata_en_reg[%0d]    = %0h", $time, j, dfi_rddata_en_reg[j]);
                      $display("-> %0t: [DFI_MNT] dfi_rddata_valid_reg[%0d] = %0h", $time, j, dfi_rddata_valid_reg[j]);
                    end
                  end
                end
                else begin
                  if (`SYS.verbose > 7)
                    $display("-> %0t: [DFI_MNT] dfi rddata valid = %0h", $time, dfi_rddata_valid_reg[rd_data_ptr_upr-i]);
                end
              end // for ( i=0;i<rd_bl_loop_upr;i=i+1)
            end // case: READ
          
          ZQCAL:          
            dfi_op_upr = (dfi_a_cmp[10] === 1'b1) ? `ZQCAL_LONG : `ZQCAL_SHORT;
          
          NOP,
            CLOCK_DISABLE:  
              dfi_op_upr = `SDRAM_NOP;

          //            DESELECT:       dfi_op_upr = (cs_pb_out == 1'b0) ? `DESELECT : `SDRAM_NOP;
          
          POWER_DOWN:
            begin
              dfi_op_upr = `POWER_DOWN;
              //power_down_mode = 1'b1;
            end

          /*          
           POWER_DWN_EXIT,
           SELF_RFSH_EXIT:
           begin
           if (self_rfsh_mode === 1'b1)
           begin
           dfi_op_upr = `SELF_RFSH_EXIT;
                  end
           else if (power_down_mode === 1'b1)
           begin
           dfi_op_upr = `POWER_DWN_EXIT;
                  end
           self_rfsh_mode  = 1'b0;
           power_down_mode = 1'b0;
              end
           */ 
        endcase // case({ckep, cke, cs_b, ras_b, cas_b, we_b})
        
      end
    end
`endif

  
  //---------------------------------------------------------------------------
  // DFI Parity Error Monitor
  //---------------------------------------------------------------------------
  // verifies that the DFI parity error signal is correctly synchronized from
  // the buffer chip parity error signal
`ifdef DWC_DDR_RDIMM
  reg                         rdimm_errout_b;
  reg [pERR_PIPE_DEPTH-1:0]   rdimm_errout_b_d;
  generate 
    if (`DWC_RDIMM == 1) begin: perr_checker
      always @(posedge clk) begin: perr_chk
        // generate expected value of DFI parity error output
        xpctd_err_out_ff <= {xpctd_err_out_ff[pERR_PIPE_DEPTH-2:0], rdimm_errout_b};

        // delay starting of parity check until three clocks after reset de-assertion
        err_out_chk_en_ff <= {err_out_chk_en_ff[1:0], `RANK0_MNT.after_rdimm_reset};

        // only report the first unsynchronization error
        if (`SYS.parity_err_chk == 1'b1 && err_out_chk_en === 1'b1) begin
          if (dfi_alert_n !== xpctd_err_out && no_of_unsync_err == 0) begin

  `ifdef DWC_ALERTN_NEG_CLK
            // relax the check for 1 NEG CLK ERROUT as different mode might cause dfi_alert_n to be off by 1
            if (dfi_alert_n !== xpctd_err_out_1_off) begin
              `SYS.error_message(`CTRL_RDIMM, `PARERR, 2);
              no_of_unsync_err = no_of_unsync_err + 1;
            end
  `else
            // for POS CLK ERROUT, there should be no discrepancies
            `SYS.error_message(`CTRL_RDIMM, `PARERR, 2);
            no_of_unsync_err = no_of_unsync_err + 1;
  `endif            
          end
        end
      end

      // xpctd_err_out_1_off is xpctd_err_out off by 1 clk for NEG CLK ERROUT mode
      assign xpctd_err_out        = (`GRM.rdimmgcr0[1]) ? ~`RDIMM_ALERTN : xpctd_err_out_ff[pERR_PIPE_DEPTH-1] & rdimm_errout_b_d[pERR_PIPE_DEPTH-1];
      assign xpctd_err_out_1_off  = (`GRM.rdimmgcr0[1]) ? ~`RDIMM_ALERTN : xpctd_err_out_ff[pERR_PIPE_DEPTH-1] & rdimm_errout_b_d[pERR_PIPE_DEPTH-2];
      assign err_out_chk_en = err_out_chk_en_ff[2];
    end
  endgenerate

  `ifdef DWC_ALERTN_NEG_CLK
    always @(negedge clk) begin: sample_RDIMM_ERROUT_B
      rdimm_errout_b <= `RDIMM_ALERTN;
    end
  `else
  `ifdef DWC_IDT 
    always @(posedge clk) begin: sample_RDIMM_ERROUT_B
      rdimm_errout_b <= `RDIMM_ALERTN;
    end
  `endif
  `endif

  always @(posedge clk) begin: RDIMM_ERROUT_B_PIPE
    rdimm_errout_b_d <= {rdimm_errout_b_d[pERR_PIPE_DEPTH-2:0], rdimm_errout_b};
  end
  
`endif
  
endmodule // dfi_mnt
