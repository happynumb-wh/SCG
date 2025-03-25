//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_apb_coreif.sv#18 $
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DWC_ddr_umctl2
// Component Version: 3.60a
// Release Type     : GA
//  ------------------------------------------------------------------------


//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Unused signals are in fact used under different `ifdefs. Decided to keep current implementation.
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(7 + 1)' found in module 'DWC_ddr_umctl2_apb_coreif'
//SJ: This coding style is acceptable and there is no plan to change it.
`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_apb_coreif
  #(parameter APB_AW          = 16,
    parameter REG_WIDTH       = 32,
    parameter BCM_F_SYNC_TYPE_C2P = 2,
    parameter BCM_F_SYNC_TYPE_P2C = 2,
    parameter BCM_R_SYNC_TYPE_C2P = 2,
    parameter BCM_R_SYNC_TYPE_P2C = 2,
    parameter REG_OUTPUTS_C2P = 1,
    parameter REG_OUTPUTS_P2C = 1,
    parameter BCM_VERIF_EN    = 1,
    parameter RW_REGS         = `UMCTL2_REG_RW_REGS,
    parameter RWSELWIDTH      = RW_REGS
    ) 
  (
    input                apb_clk
    ,input               apb_rst
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input               core_ddrc_core_clk
    ,input               sync_core_ddrc_rstn
    ,input               core_ddrc_rstn
    ,input [RWSELWIDTH-1:0] rwselect
    ,input               write_en
//spyglass enable_block W240
    ,input               fwd_reset_val
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current implementation.
    ,input               aclk_0
    ,input               sync_aresetn_0
//spyglass enable_block W240

   //------------------------
   // Register UMCTL2_REGS.MSTR
   //------------------------
   ,input  [REG_WIDTH -1:0] r0_mstr
   ,output r0_mstr_ack_pclk
   ,output reg_ddrc_ddr3 // @core_ddrc_core_clk
   ,output reg_ddrc_ddr4 // @core_ddrc_core_clk
   ,output reg_ddrc_burstchop // @core_ddrc_core_clk
   ,output reg_ddrc_en_2t_timing_mode // @core_ddrc_core_clk
   ,output reg_ddrc_geardown_mode // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_data_bus_width // @core_ddrc_core_clk
   ,output reg_ddrc_dll_off_mode // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_burst_rdwr // @core_ddrc_core_clk
   ,output [((`MEMC_NUM_RANKS==2) ? 2 : 4)-1:0] reg_ddrc_active_ranks // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_device_config // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.STAT
   //------------------------
   ,output  [REG_WIDTH -1:0] r1_stat
   ,input [((`MEMC_MOBILE_OR_LPDDR2_OR_DDR4_EN==1) ? 3 : 2)-1:0] ddrc_reg_operating_mode // @core_ddrc_core_clk
   ,input [1:0] ddrc_reg_selfref_type // @core_ddrc_core_clk
   ,input ddrc_reg_selfref_cam_not_empty // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.MRCTRL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r4_mrctrl0
   ,output r4_mrctrl0_ack_pclk
   ,output reg_ddrc_mr_type // @core_ddrc_core_clk
   ,output reg_ddrc_mpr_en // @core_ddrc_core_clk
   ,output reg_ddrc_pda_en // @core_ddrc_core_clk
   ,output reg_ddrc_sw_init_int // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_mr_rank // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_mr_addr // @core_ddrc_core_clk
   ,output reg_ddrc_pba_mode // @core_ddrc_core_clk
   ,output reg_ddrc_mr_wr_ack_pclk
   ,input ff_mr_wr_saved
   ,output reg_ddrc_mr_wr // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.MRCTRL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r5_mrctrl1
   ,output r5_mrctrl1_ack_pclk
   ,output [(`MEMC_PAGE_BITS)-1:0] reg_ddrc_mr_data // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.MRSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r6_mrstat
   ,output ddrc_reg_mr_wr_busy_int
   ,input ddrc_reg_mr_wr_busy // @core_ddrc_core_clk
   ,input ddrc_reg_pda_done // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.MRCTRL2
   //------------------------
   ,input  [REG_WIDTH -1:0] r7_mrctrl2
   ,output r7_mrctrl2_ack_pclk
   ,output [31:0] reg_ddrc_mr_device_sel // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.PWRCTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r12_pwrctl
   ,output r12_pwrctl_ack_pclk
   ,output reg_ddrc_selfref_en // @core_ddrc_core_clk
   ,output reg_ddrc_powerdown_en // @core_ddrc_core_clk
   ,output reg_ddrc_en_dfi_dram_clk_disable // @core_ddrc_core_clk
   ,output reg_ddrc_mpsm_en // @core_ddrc_core_clk
   ,output reg_ddrc_selfref_sw // @core_ddrc_core_clk
   ,output reg_ddrc_dis_cam_drain_selfref // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.PWRTMG
   //------------------------
   ,input  [REG_WIDTH-1:0] r13_pwrtmg
   ,output [4:0] reg_ddrc_powerdown_to_x32 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_selfref_to_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.HWLPCTL
   //------------------------
   ,input  [REG_WIDTH-1:0] r14_hwlpctl
   ,output reg_ddrc_hw_lp_en // @core_ddrc_core_clk
   ,output reg_ddrc_hw_lp_exit_idle_en // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_hw_lp_idle_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r17_rfshctl0
   ,output r17_rfshctl0_ack_pclk
   ,output [5:0] reg_ddrc_refresh_burst // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_refresh_to_x1_x32 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_refresh_margin // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r18_rfshctl1
   ,output r18_rfshctl1_ack_pclk
   ,output [11:0] reg_ddrc_refresh_timer0_start_value_x32 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_refresh_timer1_start_value_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL3
   //------------------------
   ,input  [REG_WIDTH -1:0] r21_rfshctl3
   ,output r21_rfshctl3_ack_pclk
   ,output reg_ddrc_dis_auto_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_refresh_update_level // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_refresh_mode // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.RFSHTMG
   //------------------------
   ,input  [REG_WIDTH -1:0] r22_rfshtmg
   ,output r22_rfshtmg_ack_pclk
   ,output [9:0] reg_ddrc_t_rfc_min // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_rfc_nom_x1_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r44_crcparctl0
   ,output r44_crcparctl0_ack_pclk
   ,output reg_ddrc_dfi_alert_err_int_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_alert_err_int_clr_ack_pclk
   ,output reg_ddrc_dfi_alert_err_int_clr // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk
   ,output reg_ddrc_dfi_alert_err_cnt_clr // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r45_crcparctl1
   ,output r45_crcparctl1_ack_pclk
   ,output reg_ddrc_parity_enable // @core_ddrc_core_clk
   ,output reg_ddrc_crc_enable // @core_ddrc_core_clk
   ,output reg_ddrc_crc_inc_dm // @core_ddrc_core_clk
   ,output reg_ddrc_caparity_disable_before_sr // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.CRCPARSTAT
   //------------------------
   ,output  [REG_WIDTH -1:0] r47_crcparstat
   ,input [15:0] ddrc_reg_dfi_alert_err_cnt // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_alert_err_int // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT0
   //------------------------
   ,input  [REG_WIDTH -1:0] r48_init0
   ,output r48_init0_ack_pclk
   ,output [11:0] reg_ddrc_pre_cke_x1024 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_post_cke_x1024 // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_skip_dram_init // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT1
   //------------------------
   ,input  [REG_WIDTH-1:0] r49_init1
   ,output [3:0] reg_ddrc_pre_ocd_x32 // @core_ddrc_core_clk
   ,output [8:0] reg_ddrc_dram_rstn_x1024 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT3
   //------------------------
   ,input  [REG_WIDTH-1:0] r51_init3
   ,output [15:0] reg_ddrc_emr // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT4
   //------------------------
   ,input  [REG_WIDTH -1:0] r52_init4
   ,output r52_init4_ack_pclk
   ,output [15:0] reg_ddrc_emr3 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr2 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT5
   //------------------------
   ,input  [REG_WIDTH-1:0] r53_init5
   ,output [7:0] reg_ddrc_dev_zqinit_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT6
   //------------------------
   ,input  [REG_WIDTH-1:0] r54_init6
   ,output [15:0] reg_ddrc_mr5 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr4 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.INIT7
   //------------------------
   ,input  [REG_WIDTH-1:0] r55_init7
   ,output [15:0] reg_ddrc_mr6 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DIMMCTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r56_dimmctl
   ,output r56_dimmctl_ack_pclk
   ,output reg_ddrc_dimm_stagger_cs_en // @core_ddrc_core_clk
   ,output reg_ddrc_dimm_addr_mirr_en // @core_ddrc_core_clk
   ,output reg_ddrc_dimm_output_inv_en // @core_ddrc_core_clk
   ,output reg_ddrc_mrs_a17_en // @core_ddrc_core_clk
   ,output reg_ddrc_mrs_bg1_en // @core_ddrc_core_clk
   ,output reg_ddrc_dimm_dis_bg_mirroring // @core_ddrc_core_clk
   ,output reg_ddrc_lrdimm_bcom_cmd_prot // @core_ddrc_core_clk
   ,output reg_ddrc_rcd_weak_drive // @core_ddrc_core_clk
   ,output reg_ddrc_rcd_a_output_disabled // @core_ddrc_core_clk
   ,output reg_ddrc_rcd_b_output_disabled // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.RANKCTL
   //------------------------
   ,input  [REG_WIDTH-1:0] r57_rankctl
   ,output [3:0] reg_ddrc_max_rank_rd // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_diff_rank_rd_gap // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_diff_rank_wr_gap // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_max_rank_wr // @core_ddrc_core_clk
   ,output reg_ddrc_diff_rank_rd_gap_msb // @core_ddrc_core_clk
   ,output reg_ddrc_diff_rank_wr_gap_msb // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r59_dramtmg0
   ,output [5:0] reg_ddrc_t_ras_min // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_ras_max // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_faw // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_wr2pre // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG1
   //------------------------
   ,input  [REG_WIDTH-1:0] r60_dramtmg1
   ,output [6:0] reg_ddrc_t_rc // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_rd2pre // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_xp // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG2
   //------------------------
   ,input  [REG_WIDTH-1:0] r61_dramtmg2
   ,output [5:0] reg_ddrc_wr2rd // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_rd2wr // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_read_latency // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_write_latency // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG3
   //------------------------
   ,input  [REG_WIDTH-1:0] r62_dramtmg3
   ,output [9:0] reg_ddrc_t_mod // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_mrd // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG4
   //------------------------
   ,input  [REG_WIDTH-1:0] r63_dramtmg4
   ,output [4:0] reg_ddrc_t_rp // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_rrd // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_ccd // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_rcd // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG5
   //------------------------
   ,input  [REG_WIDTH-1:0] r64_dramtmg5
   ,output [4:0] reg_ddrc_t_cke // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_ckesr // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_cksre // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_cksrx // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG8
   //------------------------
   ,input  [REG_WIDTH-1:0] r67_dramtmg8
   ,output [6:0] reg_ddrc_t_xs_x32 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_dll_x32 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_abort_x32 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_fast_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG9
   //------------------------
   ,input  [REG_WIDTH-1:0] r68_dramtmg9
   ,output [5:0] reg_ddrc_wr2rd_s // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_rrd_s // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_t_ccd_s // @core_ddrc_core_clk
   ,output reg_ddrc_ddr4_wr_preamble // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG10
   //------------------------
   ,input  [REG_WIDTH -1:0] r69_dramtmg10
   ,output r69_dramtmg10_ack_pclk
   ,output [1:0] reg_ddrc_t_gear_hold // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_t_gear_setup // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_cmd_gear // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_sync_gear // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG11
   //------------------------
   ,input  [REG_WIDTH-1:0] r70_dramtmg11
   ,output [4:0] reg_ddrc_t_ckmpe // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_t_mpx_s // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_mpx_lh // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_post_mpsm_gap_x32 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG12
   //------------------------
   ,input  [REG_WIDTH-1:0] r71_dramtmg12
   ,output [4:0] reg_ddrc_t_mrd_pda // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_wr_mpr // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG15
   //------------------------
   ,input  [REG_WIDTH-1:0] r74_dramtmg15
   ,output [7:0] reg_ddrc_t_stab_x32 // @core_ddrc_core_clk
   ,output reg_ddrc_en_dfi_lp_t_stab // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ZQCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r82_zqctl0
   ,output r82_zqctl0_ack_pclk
   ,output [9:0] reg_ddrc_t_zq_short_nop // @core_ddrc_core_clk
   ,output [10:0] reg_ddrc_t_zq_long_nop // @core_ddrc_core_clk
   ,output reg_ddrc_dis_mpsmx_zqcl // @core_ddrc_core_clk
   ,output reg_ddrc_zq_resistor_shared // @core_ddrc_core_clk
   ,output reg_ddrc_dis_srx_zqcl // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_zq // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ZQCTL1
   //------------------------
   ,input  [REG_WIDTH-1:0] r83_zqctl1
   ,output [19:0] reg_ddrc_t_zq_short_interval_x1024 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFITMG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r86_dfitmg0
   ,output [5:0] reg_ddrc_dfi_tphy_wrlat // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_tphy_wrdata // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_wrdata_use_dfi_phy_clk // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_dfi_t_rddata_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_rddata_use_dfi_phy_clk // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_ctrl_delay // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFITMG1
   //------------------------
   ,input  [REG_WIDTH -1:0] r87_dfitmg1
   ,output r87_dfitmg1_ack_pclk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_enable // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_disable // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_wrdata_delay // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dfi_t_parin_lat // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_t_cmd_lat // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r88_dfilpcfg0
   ,output r88_dfilpcfg0_ack_pclk
   ,output reg_ddrc_dfi_lp_en_pd // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_lp_wakeup_pd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_sr // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_lp_wakeup_sr // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_tlp_resp // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG1
   //------------------------
   ,input  [REG_WIDTH-1:0] r89_dfilpcfg1
   ,output reg_ddrc_dfi_lp_en_mpsm // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_lp_wakeup_mpsm // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFIUPD0
   //------------------------
   ,input  [REG_WIDTH-1:0] r90_dfiupd0
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_min // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_max // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd_pre_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFIUPD1
   //------------------------
   ,input  [REG_WIDTH-1:0] r91_dfiupd1
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_max_x1024 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_min_x1024 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFIUPD2
   //------------------------
   ,input  [REG_WIDTH-1:0] r92_dfiupd2
   ,output reg_ddrc_dfi_phyupd_en // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFIMISC
   //------------------------
   ,input  [REG_WIDTH -1:0] r94_dfimisc
   ,output r94_dfimisc_ack_pclk
   ,output reg_ddrc_dfi_init_complete_en // @core_ddrc_core_clk
   ,output reg_ddrc_phy_dbi_mode // @core_ddrc_core_clk
   ,output reg_ddrc_ctl_idle_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_init_start // @core_ddrc_core_clk
   ,output reg_ddrc_dis_dyn_adr_tri // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_frequency // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFITMG3
   //------------------------
   ,input  [REG_WIDTH-1:0] r96_dfitmg3
   ,output [4:0] reg_ddrc_dfi_t_geardown_delay // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFISTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r97_dfistat
   ,input ddrc_reg_dfi_init_complete // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_lp_ack // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DBICTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r98_dbictl
   ,output r98_dbictl_ack_pclk
   ,output reg_ddrc_dm_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_dbi_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_dbi_en // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DFIPHYMSTR
   //------------------------
   ,input  [REG_WIDTH -1:0] r99_dfiphymstr
   ,output r99_dfiphymstr_ack_pclk
   ,output reg_ddrc_dfi_phymstr_en // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP0
   //------------------------
   ,input  [REG_WIDTH-1:0] r100_addrmap0
   ,output [4:0] reg_ddrc_addrmap_cs_bit0 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP1
   //------------------------
   ,input  [REG_WIDTH-1:0] r101_addrmap1
   ,output [5:0] reg_ddrc_addrmap_bank_b0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b1 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b2 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP2
   //------------------------
   ,input  [REG_WIDTH-1:0] r102_addrmap2
   ,output [3:0] reg_ddrc_addrmap_col_b2 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b3 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b4 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b5 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP3
   //------------------------
   ,input  [REG_WIDTH-1:0] r103_addrmap3
   ,output [4:0] reg_ddrc_addrmap_col_b6 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b7 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b8 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b9 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP4
   //------------------------
   ,input  [REG_WIDTH-1:0] r104_addrmap4
   ,output [4:0] reg_ddrc_addrmap_col_b10 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b11 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP5
   //------------------------
   ,input  [REG_WIDTH-1:0] r105_addrmap5
   ,output [3:0] reg_ddrc_addrmap_row_b0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b1 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b2_10 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b11 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP6
   //------------------------
   ,input  [REG_WIDTH -1:0] r106_addrmap6
   ,output r106_addrmap6_ack_pclk
   ,output [3:0] reg_ddrc_addrmap_row_b12 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b13 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b14 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b15 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP7
   //------------------------
   ,input  [REG_WIDTH -1:0] r107_addrmap7
   ,output r107_addrmap7_ack_pclk
   ,output [3:0] reg_ddrc_addrmap_row_b16 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b17 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP8
   //------------------------
   ,input  [REG_WIDTH-1:0] r108_addrmap8
   ,output [5:0] reg_ddrc_addrmap_bg_b0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bg_b1 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP9
   //------------------------
   ,input  [REG_WIDTH-1:0] r109_addrmap9
   ,output [3:0] reg_ddrc_addrmap_row_b2 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b3 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b4 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b5 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP10
   //------------------------
   ,input  [REG_WIDTH-1:0] r110_addrmap10
   ,output [3:0] reg_ddrc_addrmap_row_b6 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b7 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b8 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b9 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP11
   //------------------------
   ,input  [REG_WIDTH-1:0] r111_addrmap11
   ,output [3:0] reg_ddrc_addrmap_row_b10 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ODTCFG
   //------------------------
   ,input  [REG_WIDTH-1:0] r113_odtcfg
   ,output [4:0] reg_ddrc_rd_odt_delay // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_rd_odt_hold // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_wr_odt_delay // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_wr_odt_hold // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.ODTMAP
   //------------------------
   ,input  [REG_WIDTH-1:0] r114_odtmap
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_wr_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_rd_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank1_wr_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank1_rd_odt // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.SCHED
   //------------------------
   ,input  [REG_WIDTH-1:0] r115_sched
   ,output reg_ddrc_prefer_write // @core_ddrc_core_clk
   ,output reg_ddrc_pageclose // @core_ddrc_core_clk
   ,output reg_ddrc_autopre_rmw // @core_ddrc_core_clk
   ,output [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_lpr_num_entries // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_go2critical_hysteresis // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_rdwr_idle_gap // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.SCHED1
   //------------------------
   ,input  [REG_WIDTH-1:0] r116_sched1
   ,output [7:0] reg_ddrc_pageclose_timer // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.PERFHPR1
   //------------------------
   ,input  [REG_WIDTH-1:0] r118_perfhpr1
   ,output [15:0] reg_ddrc_hpr_max_starve // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_hpr_xact_run_length // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.PERFLPR1
   //------------------------
   ,input  [REG_WIDTH-1:0] r119_perflpr1
   ,output [15:0] reg_ddrc_lpr_max_starve // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_lpr_xact_run_length // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.PERFWR1
   //------------------------
   ,input  [REG_WIDTH-1:0] r120_perfwr1
   ,output [15:0] reg_ddrc_w_max_starve // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_w_xact_run_length // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DBG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r145_dbg0
   ,output reg_ddrc_dis_wc // @core_ddrc_core_clk
   ,output reg_ddrc_dis_collision_page_opt // @core_ddrc_core_clk
   ,output reg_ddrc_dis_max_rank_rd_opt // @core_ddrc_core_clk
   ,output reg_ddrc_dis_max_rank_wr_opt // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DBG1
   //------------------------
   ,input  [REG_WIDTH -1:0] r146_dbg1
   ,output r146_dbg1_ack_pclk
   ,output reg_ddrc_dis_dq // @core_ddrc_core_clk
   ,output reg_ddrc_dis_hif // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DBGCAM
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r147_dbgcam
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_hpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_lpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_WRCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_w_q_depth // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_rd_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_wr_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_rd_data_pipeline_empty // @core_ddrc_core_clk
   ,input ddrc_reg_wr_data_pipeline_empty // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_stall_wr // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_stall_rd // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DBGCMD
   //------------------------
   ,input  [REG_WIDTH -1:0] r148_dbgcmd
   ,output r148_dbgcmd_ack_pclk
   ,output reg_ddrc_rank0_refresh_ack_pclk
   ,input ff_rank0_refresh_saved
   ,output reg_ddrc_rank0_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_rank1_refresh_ack_pclk
   ,input ff_rank1_refresh_saved
   ,output reg_ddrc_rank1_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_zq_calib_short_ack_pclk
   ,input ff_zq_calib_short_saved
   ,output reg_ddrc_zq_calib_short // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd_ack_pclk
   ,input ff_ctrlupd_saved
   ,output reg_ddrc_ctrlupd // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.DBGSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r149_dbgstat
   ,output ddrc_reg_rank0_refresh_busy_int
   ,input ddrc_reg_rank0_refresh_busy // @core_ddrc_core_clk
   ,output ddrc_reg_rank1_refresh_busy_int
   ,input ddrc_reg_rank1_refresh_busy // @core_ddrc_core_clk
   ,output ddrc_reg_zq_calib_short_busy_int
   ,input ddrc_reg_zq_calib_short_busy // @core_ddrc_core_clk
   ,output ddrc_reg_ctrlupd_busy_int
   ,input ddrc_reg_ctrlupd_busy // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.SWCTL
   //------------------------
   ,input  [REG_WIDTH-1:0] r151_swctl
   ,output reg_ddrc_sw_done // @pclk
   //------------------------
   // Register UMCTL2_REGS.SWSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r152_swstat
   ,input ddrc_reg_sw_done_ack // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.SWCTLSTATIC
   //------------------------
   ,input  [REG_WIDTH-1:0] r153_swctlstatic
   ,output reg_ddrc_sw_static_unlock // @pclk
   //------------------------
   // Register UMCTL2_REGS.POISONCFG
   //------------------------
   ,input  [REG_WIDTH -1:0] r169_poisoncfg
   ,output r169_poisoncfg_ack_pclk
   ,output reg_ddrc_wr_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_clr_ack_pclk
   ,output reg_ddrc_wr_poison_intr_clr // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_clr_ack_pclk
   ,output reg_ddrc_rd_poison_intr_clr // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_REGS.POISONSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r170_poisonstat
   ,input ddrc_reg_wr_poison_intr_0 // @core_ddrc_core_clk
   ,input ddrc_reg_rd_poison_intr_0 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_MP.PSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r193_pstat
   ,input arb_reg_rd_port_busy_0 // @aclk_0
   ,input arb_reg_wr_port_busy_0 // @aclk_0
   //------------------------
   // Register UMCTL2_MP.PCCFG
   //------------------------
   ,input  [REG_WIDTH-1:0] r194_pccfg
   ,output reg_arb_go2critical_en // @core_ddrc_core_clk
   ,output reg_arb_pagematch_limit // @core_ddrc_core_clk
   ,output reg_arb_bl_exp_mode // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_MP.PCFGR_0
   //------------------------
   ,input  [REG_WIDTH-1:0] r195_pcfgr_0
   ,output [9:0] reg_arb_rd_port_priority_0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_aging_en_0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_urgent_en_0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_pagematch_en_0 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_MP.PCFGW_0
   //------------------------
   ,input  [REG_WIDTH-1:0] r196_pcfgw_0
   ,output [9:0] reg_arb_wr_port_priority_0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_aging_en_0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_urgent_en_0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_pagematch_en_0 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_MP.PCTRL_0
   //------------------------
   ,input  [REG_WIDTH -1:0] r230_pctrl_0
   ,output r230_pctrl_0_ack_pclk
   ,output reg_arba0_port_en_0 // @aclk_0
   //------------------------
   // Register UMCTL2_MP.PCFGQOS0_0
   //------------------------
   ,input  [REG_WIDTH-1:0] r231_pcfgqos0_0
   ,output [(`UMCTL2_XPI_RQOS_MLW)-1:0] reg_arba0_rqos_map_level1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region0_0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region1_0 // @aclk_0
   //------------------------
   // Register UMCTL2_MP.PCFGQOS1_0
   //------------------------
   ,input  [REG_WIDTH-1:0] r232_pcfgqos1_0
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutb_0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutr_0 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS0_0
   //------------------------
   ,input  [REG_WIDTH-1:0] r233_pcfgwqos0_0
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level2_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region0_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region2_0 // @aclk_0
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS1_0
   //------------------------
   ,input  [REG_WIDTH-1:0] r234_pcfgwqos1_0
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout1_0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout2_0 // @core_ddrc_core_clk
   //------------------------
   // Register UMCTL2_MP.UMCTL2_VER_NUMBER
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r856_umctl2_ver_number
   ,input [31:0] arb_reg_ver_number // @pclk
   //------------------------
   // Register UMCTL2_MP.UMCTL2_VER_TYPE
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r857_umctl2_ver_type
   ,input [31:0] arb_reg_ver_type // @pclk

    ,output              dfi_alert_err_intr
   );
   
   localparam TMR_EN = 0; //`UMCTL2_REGPAR_EN;
 

   reg  [REG_WIDTH -1:0] s_data_r0_mstr;
   wire [REG_WIDTH -1:0] d_data_r0_mstr;
   wire reg_ddrc_ddr3_pclk;
   wire reg_ddrc_ddr4_pclk;
   wire reg_ddrc_burstchop_pclk;
   wire reg_ddrc_en_2t_timing_mode_pclk;
   wire reg_ddrc_geardown_mode_pclk;
   wire [`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH-1:0] reg_ddrc_data_bus_width_pclk;
   wire reg_ddrc_dll_off_mode_pclk;
   wire [`UMCTL2_REG_SIZE_MSTR_BURST_RDWR-1:0] reg_ddrc_burst_rdwr_pclk;
   wire [`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS-1:0] reg_ddrc_active_ranks_pclk;
   wire [`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG-1:0] reg_ddrc_device_config_pclk;
   reg  [REG_WIDTH -1:0] s_data_r4_mrctrl0;
   wire [REG_WIDTH -1:0] d_data_r4_mrctrl0;
   wire reg_ddrc_mr_type_pclk;
   wire reg_ddrc_mpr_en_pclk;
   wire reg_ddrc_pda_en_pclk;
   wire reg_ddrc_sw_init_int_pclk;
   wire [`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK-1:0] reg_ddrc_mr_rank_pclk;
   wire [`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR-1:0] reg_ddrc_mr_addr_pclk;
   wire reg_ddrc_pba_mode_pclk;
   wire reg_ddrc_mr_wr_pclk;
   reg  [REG_WIDTH -1:0] s_data_r5_mrctrl1;
   wire [REG_WIDTH -1:0] d_data_r5_mrctrl1;
   wire [`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA-1:0] reg_ddrc_mr_data_pclk;
   wire ddrc_reg_mr_wr_busy_pclk;
   wire ddrc_reg_pda_done_pclk;
   reg  [REG_WIDTH -1:0] s_data_r7_mrctrl2;
   wire [REG_WIDTH -1:0] d_data_r7_mrctrl2;
   wire [`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL-1:0] reg_ddrc_mr_device_sel_pclk;
   reg  [REG_WIDTH -1:0] s_data_r12_pwrctl;
   wire [REG_WIDTH -1:0] d_data_r12_pwrctl;
   wire reg_ddrc_selfref_en_pclk;
   wire reg_ddrc_powerdown_en_pclk;
   wire reg_ddrc_en_dfi_dram_clk_disable_pclk;
   wire reg_ddrc_mpsm_en_pclk;
   wire reg_ddrc_selfref_sw_pclk;
   wire reg_ddrc_dis_cam_drain_selfref_pclk;
   reg  [REG_WIDTH -1:0] s_data_r17_rfshctl0;
   wire [REG_WIDTH -1:0] d_data_r17_rfshctl0;
   wire [`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST-1:0] reg_ddrc_refresh_burst_pclk;
   wire [`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32-1:0] reg_ddrc_refresh_to_x1_x32_pclk;
   wire [`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN-1:0] reg_ddrc_refresh_margin_pclk;
   reg  [REG_WIDTH -1:0] s_data_r18_rfshctl1;
   wire [REG_WIDTH -1:0] d_data_r18_rfshctl1;
   wire [`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32-1:0] reg_ddrc_refresh_timer0_start_value_x32_pclk;
   wire [`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32-1:0] reg_ddrc_refresh_timer1_start_value_x32_pclk;
   reg  [REG_WIDTH -1:0] s_data_r21_rfshctl3;
   wire [REG_WIDTH -1:0] d_data_r21_rfshctl3;
   wire reg_ddrc_dis_auto_refresh_pclk;
   wire reg_ddrc_refresh_update_level_pclk;
   wire [`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE-1:0] reg_ddrc_refresh_mode_pclk;
   reg  [REG_WIDTH -1:0] s_data_r22_rfshtmg;
   wire [REG_WIDTH -1:0] d_data_r22_rfshtmg;
   wire [`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN-1:0] reg_ddrc_t_rfc_min_pclk;
   wire [`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32-1:0] reg_ddrc_t_rfc_nom_x1_x32_pclk;
   reg  [REG_WIDTH -1:0] s_data_r44_crcparctl0;
   wire [REG_WIDTH -1:0] d_data_r44_crcparctl0;
   wire reg_ddrc_dfi_alert_err_int_en_pclk;
   wire reg_ddrc_dfi_alert_err_int_clr_pclk;
   wire reg_ddrc_dfi_alert_err_cnt_clr_pclk;
   reg  [REG_WIDTH -1:0] s_data_r45_crcparctl1;
   wire [REG_WIDTH -1:0] d_data_r45_crcparctl1;
   wire reg_ddrc_parity_enable_pclk;
   wire reg_ddrc_crc_enable_pclk;
   wire reg_ddrc_crc_inc_dm_pclk;
   wire reg_ddrc_caparity_disable_before_sr_pclk;
   reg  [REG_WIDTH -1:0] s_data_r48_init0;
   wire [REG_WIDTH -1:0] d_data_r48_init0;
   wire [`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024-1:0] reg_ddrc_pre_cke_x1024_pclk;
   wire [`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024-1:0] reg_ddrc_post_cke_x1024_pclk;
   wire [`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT-1:0] reg_ddrc_skip_dram_init_pclk;
   reg  [REG_WIDTH -1:0] s_data_r52_init4;
   wire [REG_WIDTH -1:0] d_data_r52_init4;
   wire [`UMCTL2_REG_SIZE_INIT4_EMR3-1:0] reg_ddrc_emr3_pclk;
   wire [`UMCTL2_REG_SIZE_INIT4_EMR2-1:0] reg_ddrc_emr2_pclk;
   reg  [REG_WIDTH -1:0] s_data_r56_dimmctl;
   wire [REG_WIDTH -1:0] d_data_r56_dimmctl;
   wire reg_ddrc_dimm_stagger_cs_en_pclk;
   wire reg_ddrc_dimm_addr_mirr_en_pclk;
   wire reg_ddrc_dimm_output_inv_en_pclk;
   wire reg_ddrc_mrs_a17_en_pclk;
   wire reg_ddrc_mrs_bg1_en_pclk;
   wire reg_ddrc_dimm_dis_bg_mirroring_pclk;
   wire reg_ddrc_lrdimm_bcom_cmd_prot_pclk;
   wire reg_ddrc_rcd_weak_drive_pclk;
   wire reg_ddrc_rcd_a_output_disabled_pclk;
   wire reg_ddrc_rcd_b_output_disabled_pclk;
   reg  [REG_WIDTH -1:0] s_data_r69_dramtmg10;
   wire [REG_WIDTH -1:0] d_data_r69_dramtmg10;
   wire [`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD-1:0] reg_ddrc_t_gear_hold_pclk;
   wire [`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP-1:0] reg_ddrc_t_gear_setup_pclk;
   wire [`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR-1:0] reg_ddrc_t_cmd_gear_pclk;
   wire [`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR-1:0] reg_ddrc_t_sync_gear_pclk;
   reg  [REG_WIDTH -1:0] s_data_r82_zqctl0;
   wire [REG_WIDTH -1:0] d_data_r82_zqctl0;
   wire [`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP-1:0] reg_ddrc_t_zq_short_nop_pclk;
   wire [`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP-1:0] reg_ddrc_t_zq_long_nop_pclk;
   wire reg_ddrc_dis_mpsmx_zqcl_pclk;
   wire reg_ddrc_zq_resistor_shared_pclk;
   wire reg_ddrc_dis_srx_zqcl_pclk;
   wire reg_ddrc_dis_auto_zq_pclk;
   reg  [REG_WIDTH -1:0] s_data_r87_dfitmg1;
   wire [REG_WIDTH -1:0] d_data_r87_dfitmg1;
   wire [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE-1:0] reg_ddrc_dfi_t_dram_clk_enable_pclk;
   wire [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE-1:0] reg_ddrc_dfi_t_dram_clk_disable_pclk;
   wire [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY-1:0] reg_ddrc_dfi_t_wrdata_delay_pclk;
   wire [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT-1:0] reg_ddrc_dfi_t_parin_lat_pclk;
   wire [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT-1:0] reg_ddrc_dfi_t_cmd_lat_pclk;
   reg  [REG_WIDTH -1:0] s_data_r88_dfilpcfg0;
   wire [REG_WIDTH -1:0] d_data_r88_dfilpcfg0;
   wire reg_ddrc_dfi_lp_en_pd_pclk;
   wire [`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD-1:0] reg_ddrc_dfi_lp_wakeup_pd_pclk;
   wire reg_ddrc_dfi_lp_en_sr_pclk;
   wire [`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR-1:0] reg_ddrc_dfi_lp_wakeup_sr_pclk;
   wire [`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP-1:0] reg_ddrc_dfi_tlp_resp_pclk;
   reg  [REG_WIDTH -1:0] s_data_r94_dfimisc;
   wire [REG_WIDTH -1:0] d_data_r94_dfimisc;
   wire reg_ddrc_dfi_init_complete_en_pclk;
   wire reg_ddrc_phy_dbi_mode_pclk;
   wire reg_ddrc_ctl_idle_en_pclk;
   wire reg_ddrc_dfi_init_start_pclk;
   wire reg_ddrc_dis_dyn_adr_tri_pclk;
   wire [`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY-1:0] reg_ddrc_dfi_frequency_pclk;
   wire ddrc_reg_dfi_init_complete_pclk;
   wire ddrc_reg_dfi_lp_ack_pclk;
   reg  [REG_WIDTH -1:0] s_data_r98_dbictl;
   wire [REG_WIDTH -1:0] d_data_r98_dbictl;
   wire reg_ddrc_dm_en_pclk;
   wire reg_ddrc_wr_dbi_en_pclk;
   wire reg_ddrc_rd_dbi_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r99_dfiphymstr;
   wire [REG_WIDTH -1:0] d_data_r99_dfiphymstr;
   wire reg_ddrc_dfi_phymstr_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r106_addrmap6;
   wire [REG_WIDTH -1:0] d_data_r106_addrmap6;
   wire [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12-1:0] reg_ddrc_addrmap_row_b12_pclk;
   wire [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13-1:0] reg_ddrc_addrmap_row_b13_pclk;
   wire [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14-1:0] reg_ddrc_addrmap_row_b14_pclk;
   wire [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15-1:0] reg_ddrc_addrmap_row_b15_pclk;
   reg  [REG_WIDTH -1:0] s_data_r107_addrmap7;
   wire [REG_WIDTH -1:0] d_data_r107_addrmap7;
   wire [`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16-1:0] reg_ddrc_addrmap_row_b16_pclk;
   wire [`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17-1:0] reg_ddrc_addrmap_row_b17_pclk;
   reg  [REG_WIDTH -1:0] s_data_r146_dbg1;
   wire [REG_WIDTH -1:0] d_data_r146_dbg1;
   wire reg_ddrc_dis_dq_pclk;
   wire reg_ddrc_dis_hif_pclk;
   wire [`UMCTL2_REG_SIZE_DBGCAM_DBG_HPR_Q_DEPTH -1:0] ddrc_reg_dbg_hpr_q_depth_pclk;
   wire [`UMCTL2_REG_SIZE_DBGCAM_DBG_LPR_Q_DEPTH -1:0] ddrc_reg_dbg_lpr_q_depth_pclk;
   wire [`UMCTL2_REG_SIZE_DBGCAM_DBG_W_Q_DEPTH -1:0] ddrc_reg_dbg_w_q_depth_pclk;
   wire ddrc_reg_dbg_rd_q_empty_pclk;
   wire ddrc_reg_dbg_wr_q_empty_pclk;
   wire ddrc_reg_rd_data_pipeline_empty_pclk;
   wire ddrc_reg_wr_data_pipeline_empty_pclk;
   wire ddrc_reg_dbg_stall_wr_pclk;
   wire ddrc_reg_dbg_stall_rd_pclk;
   reg  [REG_WIDTH -1:0] s_data_r148_dbgcmd;
   wire [REG_WIDTH -1:0] d_data_r148_dbgcmd;
   wire reg_ddrc_rank0_refresh_pclk;
   wire reg_ddrc_rank1_refresh_pclk;
   wire reg_ddrc_zq_calib_short_pclk;
   wire reg_ddrc_ctrlupd_pclk;
   wire ddrc_reg_rank0_refresh_busy_pclk;
   wire ddrc_reg_rank1_refresh_busy_pclk;
   wire ddrc_reg_zq_calib_short_busy_pclk;
   wire ddrc_reg_ctrlupd_busy_pclk;
   reg  [REG_WIDTH -1:0] s_data_r169_poisoncfg;
   wire [REG_WIDTH -1:0] d_data_r169_poisoncfg;
   wire reg_ddrc_wr_poison_slverr_en_pclk;
   wire reg_ddrc_wr_poison_intr_en_pclk;
   wire reg_ddrc_wr_poison_intr_clr_pclk;
   wire reg_ddrc_rd_poison_slverr_en_pclk;
   wire reg_ddrc_rd_poison_intr_en_pclk;
   wire reg_ddrc_rd_poison_intr_clr_pclk;
   wire ddrc_reg_wr_poison_intr_0_pclk;
   wire ddrc_reg_rd_poison_intr_0_pclk;
   wire arb_reg_rd_port_busy_0_pclk;
   wire arb_reg_wr_port_busy_0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r230_pctrl_0;
   wire [REG_WIDTH -1:0] d_data_r230_pctrl_0;
   wire reg_arb_port_en_0_pclk;

   reg [`UMCTL2_REG_SIZE_STAT_SELFREF_TYPE -1:0] ddrc_reg_selfref_type_cclk;
   reg ddrc_reg_selfref_cam_not_empty_cclk;
   reg ddrc_reg_mr_wr_busy_cclk;
   reg ddrc_reg_pda_done_cclk;
   reg ddrc_reg_dfi_init_complete_cclk;
   reg ddrc_reg_dfi_lp_ack_cclk;
   reg ddrc_reg_dbg_rd_q_empty_cclk;
   reg ddrc_reg_dbg_wr_q_empty_cclk;
   reg ddrc_reg_rd_data_pipeline_empty_cclk;
   reg ddrc_reg_wr_data_pipeline_empty_cclk;
   reg ddrc_reg_dbg_stall_wr_cclk;
   reg ddrc_reg_dbg_stall_rd_cclk;

   //------------------------
   // Register UMCTL2_REGS.MSTR
   //------------------------
   assign reg_ddrc_ddr3_pclk = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR3+:`UMCTL2_REG_SIZE_MSTR_DDR3];
   assign reg_ddrc_ddr4_pclk = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR4+:`UMCTL2_REG_SIZE_MSTR_DDR4];
   assign reg_ddrc_burstchop_pclk = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURSTCHOP+:`UMCTL2_REG_SIZE_MSTR_BURSTCHOP];
   assign reg_ddrc_en_2t_timing_mode_pclk = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_EN_2T_TIMING_MODE+:`UMCTL2_REG_SIZE_MSTR_EN_2T_TIMING_MODE];
   assign reg_ddrc_geardown_mode_pclk = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_GEARDOWN_MODE+:`UMCTL2_REG_SIZE_MSTR_GEARDOWN_MODE];
   assign reg_ddrc_data_bus_width_pclk[(`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH) -1:0] = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DATA_BUS_WIDTH+:`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH];
   assign reg_ddrc_dll_off_mode_pclk = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DLL_OFF_MODE+:`UMCTL2_REG_SIZE_MSTR_DLL_OFF_MODE];
   assign reg_ddrc_burst_rdwr_pclk[(`UMCTL2_REG_SIZE_MSTR_BURST_RDWR) -1:0] = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURST_RDWR+:`UMCTL2_REG_SIZE_MSTR_BURST_RDWR];
   assign reg_ddrc_active_ranks_pclk[(`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS) -1:0] = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_ACTIVE_RANKS+:`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS];
   assign reg_ddrc_device_config_pclk[(`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG) -1:0] = r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DEVICE_CONFIG+:`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG];
   always_comb begin : s_data_r0_mstr_combo_PROC
      s_data_r0_mstr = {REG_WIDTH {1'b0}};
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR3+:`UMCTL2_REG_SIZE_MSTR_DDR3] = reg_ddrc_ddr3_pclk;
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR4+:`UMCTL2_REG_SIZE_MSTR_DDR4] = reg_ddrc_ddr4_pclk;
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURSTCHOP+:`UMCTL2_REG_SIZE_MSTR_BURSTCHOP] = reg_ddrc_burstchop_pclk;
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_EN_2T_TIMING_MODE+:`UMCTL2_REG_SIZE_MSTR_EN_2T_TIMING_MODE] = reg_ddrc_en_2t_timing_mode_pclk;
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_GEARDOWN_MODE+:`UMCTL2_REG_SIZE_MSTR_GEARDOWN_MODE] = reg_ddrc_geardown_mode_pclk;
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DATA_BUS_WIDTH+:`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH] = reg_ddrc_data_bus_width_pclk[(`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH)-1:0];
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DLL_OFF_MODE+:`UMCTL2_REG_SIZE_MSTR_DLL_OFF_MODE] = reg_ddrc_dll_off_mode_pclk;
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURST_RDWR+:`UMCTL2_REG_SIZE_MSTR_BURST_RDWR] = reg_ddrc_burst_rdwr_pclk[(`UMCTL2_REG_SIZE_MSTR_BURST_RDWR)-1:0];
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_ACTIVE_RANKS+:`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS] = reg_ddrc_active_ranks_pclk[(`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS)-1:0];
      s_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DEVICE_CONFIG+:`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG] = reg_ddrc_device_config_pclk[(`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG)-1:0];
   end
      assign reg_ddrc_ddr3 = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR3+:`UMCTL2_REG_SIZE_MSTR_DDR3];
      assign reg_ddrc_ddr4 = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR4+:`UMCTL2_REG_SIZE_MSTR_DDR4];
      assign reg_ddrc_burstchop = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURSTCHOP+:`UMCTL2_REG_SIZE_MSTR_BURSTCHOP];
      assign reg_ddrc_en_2t_timing_mode = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_EN_2T_TIMING_MODE+:`UMCTL2_REG_SIZE_MSTR_EN_2T_TIMING_MODE];
      assign reg_ddrc_geardown_mode = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_GEARDOWN_MODE+:`UMCTL2_REG_SIZE_MSTR_GEARDOWN_MODE];
      assign reg_ddrc_data_bus_width[(`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH)-1:0] = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DATA_BUS_WIDTH+:`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH];
      assign reg_ddrc_dll_off_mode = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DLL_OFF_MODE+:`UMCTL2_REG_SIZE_MSTR_DLL_OFF_MODE];
      assign reg_ddrc_burst_rdwr[(`UMCTL2_REG_SIZE_MSTR_BURST_RDWR)-1:0] = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURST_RDWR+:`UMCTL2_REG_SIZE_MSTR_BURST_RDWR];
      assign reg_ddrc_active_ranks[(`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS)-1:0] = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_ACTIVE_RANKS+:`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS];
      assign reg_ddrc_device_config[(`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG)-1:0] = d_data_r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DEVICE_CONFIG+:`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG];
   //------------------------
   // Register UMCTL2_REGS.STAT
   //------------------------
   reg  [REG_WIDTH-1:0] r1_stat_cclk;
   always_comb begin : r1_stat_cclk_combo_PROC
      r1_stat_cclk = {REG_WIDTH{1'b0}};
      r1_stat_cclk[`UMCTL2_REG_OFFSET_STAT_OPERATING_MODE+:`UMCTL2_REG_SIZE_STAT_OPERATING_MODE] = ddrc_reg_operating_mode[(`UMCTL2_REG_SIZE_STAT_OPERATING_MODE) -1:0];
      r1_stat_cclk[`UMCTL2_REG_OFFSET_STAT_SELFREF_TYPE+:`UMCTL2_REG_SIZE_STAT_SELFREF_TYPE] = ddrc_reg_selfref_type[(`UMCTL2_REG_SIZE_STAT_SELFREF_TYPE) -1:0];
      r1_stat_cclk[`UMCTL2_REG_OFFSET_STAT_SELFREF_CAM_NOT_EMPTY+:`UMCTL2_REG_SIZE_STAT_SELFREF_CAM_NOT_EMPTY] = ddrc_reg_selfref_cam_not_empty;
   end
   // For interrupt
   wire [(`UMCTL2_REG_SIZE_STAT_OPERATING_MODE) -1:0] ddrc_reg_operating_mode_pclk;
   assign ddrc_reg_operating_mode_pclk = r1_stat[`UMCTL2_REG_OFFSET_STAT_OPERATING_MODE +: `UMCTL2_REG_SIZE_STAT_OPERATING_MODE];
   wire [(`UMCTL2_REG_SIZE_STAT_SELFREF_TYPE) -1:0] ddrc_reg_selfref_type_pclk;
   assign ddrc_reg_selfref_type_pclk = r1_stat[`UMCTL2_REG_OFFSET_STAT_SELFREF_TYPE +: `UMCTL2_REG_SIZE_STAT_SELFREF_TYPE];
   wire ddrc_reg_selfref_cam_not_empty_pclk;
   assign ddrc_reg_selfref_cam_not_empty_pclk = r1_stat[`UMCTL2_REG_OFFSET_STAT_SELFREF_CAM_NOT_EMPTY +: `UMCTL2_REG_SIZE_STAT_SELFREF_CAM_NOT_EMPTY];

   //------------------------
   // Register UMCTL2_REGS.MRCTRL0
   //------------------------
   assign reg_ddrc_mr_type_pclk = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_TYPE+:`UMCTL2_REG_SIZE_MRCTRL0_MR_TYPE];
   assign reg_ddrc_mpr_en_pclk = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MPR_EN+:`UMCTL2_REG_SIZE_MRCTRL0_MPR_EN];
   assign reg_ddrc_pda_en_pclk = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PDA_EN+:`UMCTL2_REG_SIZE_MRCTRL0_PDA_EN];
   assign reg_ddrc_sw_init_int_pclk = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_SW_INIT_INT+:`UMCTL2_REG_SIZE_MRCTRL0_SW_INIT_INT];
   assign reg_ddrc_mr_rank_pclk[(`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK) -1:0] = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_RANK+:`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK];
   assign reg_ddrc_mr_addr_pclk[(`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR) -1:0] = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_ADDR+:`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR];
   assign reg_ddrc_pba_mode_pclk = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PBA_MODE+:`UMCTL2_REG_SIZE_MRCTRL0_PBA_MODE];
   assign reg_ddrc_mr_wr_pclk = r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_WR+:`UMCTL2_REG_SIZE_MRCTRL0_MR_WR];
   assign ddrc_reg_mr_wr_busy_int = ddrc_reg_mr_wr_busy_pclk;
   always_comb begin : s_data_r4_mrctrl0_combo_PROC
      s_data_r4_mrctrl0 = {REG_WIDTH {1'b0}};
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_TYPE+:`UMCTL2_REG_SIZE_MRCTRL0_MR_TYPE] = reg_ddrc_mr_type_pclk;
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MPR_EN+:`UMCTL2_REG_SIZE_MRCTRL0_MPR_EN] = reg_ddrc_mpr_en_pclk;
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PDA_EN+:`UMCTL2_REG_SIZE_MRCTRL0_PDA_EN] = reg_ddrc_pda_en_pclk;
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_SW_INIT_INT+:`UMCTL2_REG_SIZE_MRCTRL0_SW_INIT_INT] = reg_ddrc_sw_init_int_pclk;
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_RANK+:`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK] = reg_ddrc_mr_rank_pclk[(`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK)-1:0];
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_ADDR+:`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR] = reg_ddrc_mr_addr_pclk[(`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR)-1:0];
      s_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PBA_MODE+:`UMCTL2_REG_SIZE_MRCTRL0_PBA_MODE] = reg_ddrc_pba_mode_pclk;
   end
      assign reg_ddrc_mr_type = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_TYPE+:`UMCTL2_REG_SIZE_MRCTRL0_MR_TYPE];
      assign reg_ddrc_mpr_en = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MPR_EN+:`UMCTL2_REG_SIZE_MRCTRL0_MPR_EN];
      assign reg_ddrc_pda_en = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PDA_EN+:`UMCTL2_REG_SIZE_MRCTRL0_PDA_EN];
      assign reg_ddrc_sw_init_int = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_SW_INIT_INT+:`UMCTL2_REG_SIZE_MRCTRL0_SW_INIT_INT];
      assign reg_ddrc_mr_rank[(`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK)-1:0] = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_RANK+:`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK];
      assign reg_ddrc_mr_addr[(`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR)-1:0] = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_ADDR+:`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR];
      assign reg_ddrc_pba_mode = d_data_r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PBA_MODE+:`UMCTL2_REG_SIZE_MRCTRL0_PBA_MODE];
   //------------------------
   // Register UMCTL2_REGS.MRCTRL1
   //------------------------
   assign reg_ddrc_mr_data_pclk[(`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA) -1:0] = r5_mrctrl1[`UMCTL2_REG_OFFSET_MRCTRL1_MR_DATA+:`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA];
   always_comb begin : s_data_r5_mrctrl1_combo_PROC
      s_data_r5_mrctrl1 = {REG_WIDTH {1'b0}};
      s_data_r5_mrctrl1[`UMCTL2_REG_OFFSET_MRCTRL1_MR_DATA+:`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA] = reg_ddrc_mr_data_pclk[(`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA)-1:0];
   end
      assign reg_ddrc_mr_data[(`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA)-1:0] = d_data_r5_mrctrl1[`UMCTL2_REG_OFFSET_MRCTRL1_MR_DATA+:`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA];
   //------------------------
   // Register UMCTL2_REGS.MRSTAT
   //------------------------
   wire ddrc_reg_mr_wr_busy_pulse_pclk;
   
   reg  ddrc_reg_mr_wr_busy_ahead;
   reg  reg_ddrc_mr_wr_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_mr_wr_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_mr_wr_busy_ahead <= 1'b0; 
         reg_ddrc_mr_wr_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_mr_wr_pclk_s0 <= reg_ddrc_mr_wr_pclk; 
         if (ddrc_reg_mr_wr_busy_pulse_pclk || ddrc_reg_mr_wr_busy_pclk) begin 
            ddrc_reg_mr_wr_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_mr_wr_pclk & (!reg_ddrc_mr_wr_pclk_s0)) begin 
            ddrc_reg_mr_wr_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   always_comb begin : r6_mrstat_combo_PROC
      r6_mrstat = {REG_WIDTH{1'b0}};
      r6_mrstat[`UMCTL2_REG_OFFSET_MRSTAT_MR_WR_BUSY+:`UMCTL2_REG_SIZE_MRSTAT_MR_WR_BUSY] = ddrc_reg_mr_wr_busy_pclk          | ddrc_reg_mr_wr_busy_ahead
          | ff_mr_wr_saved
;
      r6_mrstat[`UMCTL2_REG_OFFSET_MRSTAT_PDA_DONE+:`UMCTL2_REG_SIZE_MRSTAT_PDA_DONE] = ddrc_reg_pda_done_pclk;
   end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL2
   //------------------------
   assign reg_ddrc_mr_device_sel_pclk[(`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL) -1:0] = r7_mrctrl2[`UMCTL2_REG_OFFSET_MRCTRL2_MR_DEVICE_SEL+:`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL];
   always_comb begin : s_data_r7_mrctrl2_combo_PROC
      s_data_r7_mrctrl2 = {REG_WIDTH {1'b0}};
      s_data_r7_mrctrl2[`UMCTL2_REG_OFFSET_MRCTRL2_MR_DEVICE_SEL+:`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL] = reg_ddrc_mr_device_sel_pclk[(`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL)-1:0];
   end
      assign reg_ddrc_mr_device_sel[(`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL)-1:0] = d_data_r7_mrctrl2[`UMCTL2_REG_OFFSET_MRCTRL2_MR_DEVICE_SEL+:`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL];
   //------------------------
   // Register UMCTL2_REGS.PWRCTL
   //------------------------
   assign reg_ddrc_selfref_en_pclk = r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_EN+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_EN];
   assign reg_ddrc_powerdown_en_pclk = r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_POWERDOWN_EN+:`UMCTL2_REG_SIZE_PWRCTL_POWERDOWN_EN];
   assign reg_ddrc_en_dfi_dram_clk_disable_pclk = r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE];
   assign reg_ddrc_mpsm_en_pclk = r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_MPSM_EN+:`UMCTL2_REG_SIZE_PWRCTL_MPSM_EN];
   assign reg_ddrc_selfref_sw_pclk = r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_SW+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_SW];
   assign reg_ddrc_dis_cam_drain_selfref_pclk = r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`UMCTL2_REG_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF];
   always_comb begin : s_data_r12_pwrctl_combo_PROC
      s_data_r12_pwrctl = {REG_WIDTH {1'b0}};
      s_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_EN+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_EN] = reg_ddrc_selfref_en_pclk;
      s_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_POWERDOWN_EN+:`UMCTL2_REG_SIZE_PWRCTL_POWERDOWN_EN] = reg_ddrc_powerdown_en_pclk;
      s_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE] = reg_ddrc_en_dfi_dram_clk_disable_pclk;
      s_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_MPSM_EN+:`UMCTL2_REG_SIZE_PWRCTL_MPSM_EN] = reg_ddrc_mpsm_en_pclk;
      s_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_SW+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_SW] = reg_ddrc_selfref_sw_pclk;
      s_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`UMCTL2_REG_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF] = reg_ddrc_dis_cam_drain_selfref_pclk;
   end
      assign reg_ddrc_selfref_en = d_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_EN+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_EN];
      assign reg_ddrc_powerdown_en = d_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_POWERDOWN_EN+:`UMCTL2_REG_SIZE_PWRCTL_POWERDOWN_EN];
      assign reg_ddrc_en_dfi_dram_clk_disable = d_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE];
      assign reg_ddrc_mpsm_en = d_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_MPSM_EN+:`UMCTL2_REG_SIZE_PWRCTL_MPSM_EN];
      assign reg_ddrc_selfref_sw = d_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_SW+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_SW];
      assign reg_ddrc_dis_cam_drain_selfref = d_data_r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`UMCTL2_REG_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF];
   //------------------------
   // Register UMCTL2_REGS.PWRTMG
   //------------------------
   assign reg_ddrc_powerdown_to_x32[(`UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32) -1:0] = r13_pwrtmg[`UMCTL2_REG_OFFSET_PWRTMG_POWERDOWN_TO_X32+:`UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32];
   assign reg_ddrc_selfref_to_x32[(`UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32) -1:0] = r13_pwrtmg[`UMCTL2_REG_OFFSET_PWRTMG_SELFREF_TO_X32+:`UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32];
   //------------------------
   // Register UMCTL2_REGS.HWLPCTL
   //------------------------
   assign reg_ddrc_hw_lp_en = r14_hwlpctl[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EN+:`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EN];
   assign reg_ddrc_hw_lp_exit_idle_en = r14_hwlpctl[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN+:`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN];
   assign reg_ddrc_hw_lp_idle_x32[(`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32) -1:0] = r14_hwlpctl[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_IDLE_X32+:`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32];
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL0
   //------------------------
   assign reg_ddrc_refresh_burst_pclk[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST) -1:0] = r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_BURST+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST];
   assign reg_ddrc_refresh_to_x1_x32_pclk[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32) -1:0] = r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_TO_X1_X32+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32];
   assign reg_ddrc_refresh_margin_pclk[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN) -1:0] = r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_MARGIN+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN];
   always_comb begin : s_data_r17_rfshctl0_combo_PROC
      s_data_r17_rfshctl0 = {REG_WIDTH {1'b0}};
      s_data_r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_BURST+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST] = reg_ddrc_refresh_burst_pclk[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST)-1:0];
      s_data_r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_TO_X1_X32+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32] = reg_ddrc_refresh_to_x1_x32_pclk[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32)-1:0];
      s_data_r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_MARGIN+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN] = reg_ddrc_refresh_margin_pclk[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN)-1:0];
   end
      assign reg_ddrc_refresh_burst[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST)-1:0] = d_data_r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_BURST+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST];
      assign reg_ddrc_refresh_to_x1_x32[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32)-1:0] = d_data_r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_TO_X1_X32+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32];
      assign reg_ddrc_refresh_margin[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN)-1:0] = d_data_r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_MARGIN+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN];
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL1
   //------------------------
   assign reg_ddrc_refresh_timer0_start_value_x32_pclk[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32) -1:0] = r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32];
   assign reg_ddrc_refresh_timer1_start_value_x32_pclk[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32) -1:0] = r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32];
   always_comb begin : s_data_r18_rfshctl1_combo_PROC
      s_data_r18_rfshctl1 = {REG_WIDTH {1'b0}};
      s_data_r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32] = reg_ddrc_refresh_timer0_start_value_x32_pclk[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32)-1:0];
      s_data_r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32] = reg_ddrc_refresh_timer1_start_value_x32_pclk[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32)-1:0];
   end
      assign reg_ddrc_refresh_timer0_start_value_x32[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32)-1:0] = d_data_r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32];
      assign reg_ddrc_refresh_timer1_start_value_x32[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32)-1:0] = d_data_r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32];
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL3
   //------------------------
   assign reg_ddrc_dis_auto_refresh_pclk = r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_DIS_AUTO_REFRESH+:`UMCTL2_REG_SIZE_RFSHCTL3_DIS_AUTO_REFRESH];
   assign reg_ddrc_refresh_update_level_pclk = r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_UPDATE_LEVEL+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_UPDATE_LEVEL];
   assign reg_ddrc_refresh_mode_pclk[(`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE) -1:0] = r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_MODE+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE];
   always_comb begin : s_data_r21_rfshctl3_combo_PROC
      s_data_r21_rfshctl3 = {REG_WIDTH {1'b0}};
      s_data_r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_DIS_AUTO_REFRESH+:`UMCTL2_REG_SIZE_RFSHCTL3_DIS_AUTO_REFRESH] = reg_ddrc_dis_auto_refresh_pclk;
      s_data_r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_UPDATE_LEVEL+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_UPDATE_LEVEL] = reg_ddrc_refresh_update_level_pclk;
      s_data_r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_MODE+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE] = reg_ddrc_refresh_mode_pclk[(`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE)-1:0];
   end
      assign reg_ddrc_dis_auto_refresh = d_data_r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_DIS_AUTO_REFRESH+:`UMCTL2_REG_SIZE_RFSHCTL3_DIS_AUTO_REFRESH];
      assign reg_ddrc_refresh_update_level = d_data_r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_UPDATE_LEVEL+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_UPDATE_LEVEL];
      assign reg_ddrc_refresh_mode[(`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE)-1:0] = d_data_r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_MODE+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE];
   //------------------------
   // Register UMCTL2_REGS.RFSHTMG
   //------------------------
   assign reg_ddrc_t_rfc_min_pclk[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN) -1:0] = r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_MIN+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN];
   assign reg_ddrc_t_rfc_nom_x1_x32_pclk[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32) -1:0] = r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_NOM_X1_X32+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32];
   always_comb begin : s_data_r22_rfshtmg_combo_PROC
      s_data_r22_rfshtmg = {REG_WIDTH {1'b0}};
      s_data_r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_MIN+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN] = reg_ddrc_t_rfc_min_pclk[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN)-1:0];
      s_data_r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_NOM_X1_X32+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32] = reg_ddrc_t_rfc_nom_x1_x32_pclk[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32)-1:0];
   end
      assign reg_ddrc_t_rfc_min[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN)-1:0] = d_data_r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_MIN+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN];
      assign reg_ddrc_t_rfc_nom_x1_x32[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32)-1:0] = d_data_r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_NOM_X1_X32+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32];
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL0
   //------------------------
   assign reg_ddrc_dfi_alert_err_int_en_pclk = r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_EN+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_EN];
   assign reg_ddrc_dfi_alert_err_int_clr_pclk = r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR];
   assign reg_ddrc_dfi_alert_err_cnt_clr_pclk = r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR];
   always_comb begin : s_data_r44_crcparctl0_combo_PROC
      s_data_r44_crcparctl0 = {REG_WIDTH {1'b0}};
      s_data_r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_EN+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_EN] = reg_ddrc_dfi_alert_err_int_en_pclk;
   end
      assign reg_ddrc_dfi_alert_err_int_en = d_data_r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_EN+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_EN];
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL1
   //------------------------
   assign reg_ddrc_parity_enable_pclk = r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_PARITY_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_PARITY_ENABLE];
   assign reg_ddrc_crc_enable_pclk = r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_ENABLE];
   assign reg_ddrc_crc_inc_dm_pclk = r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_INC_DM+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_INC_DM];
   assign reg_ddrc_caparity_disable_before_sr_pclk = r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR+:`UMCTL2_REG_SIZE_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR];
   always_comb begin : s_data_r45_crcparctl1_combo_PROC
      s_data_r45_crcparctl1 = {REG_WIDTH {1'b0}};
      s_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_PARITY_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_PARITY_ENABLE] = reg_ddrc_parity_enable_pclk;
      s_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_ENABLE] = reg_ddrc_crc_enable_pclk;
      s_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_INC_DM+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_INC_DM] = reg_ddrc_crc_inc_dm_pclk;
      s_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR+:`UMCTL2_REG_SIZE_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR] = reg_ddrc_caparity_disable_before_sr_pclk;
   end
      assign reg_ddrc_parity_enable = d_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_PARITY_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_PARITY_ENABLE];
      assign reg_ddrc_crc_enable = d_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_ENABLE];
      assign reg_ddrc_crc_inc_dm = d_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_INC_DM+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_INC_DM];
      assign reg_ddrc_caparity_disable_before_sr = d_data_r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR+:`UMCTL2_REG_SIZE_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR];
   //------------------------
   // Register UMCTL2_REGS.CRCPARSTAT
   //------------------------
   reg  [REG_WIDTH-1:0] r47_crcparstat_cclk;
   always_comb begin : r47_crcparstat_cclk_combo_PROC
      r47_crcparstat_cclk = {REG_WIDTH{1'b0}};
      r47_crcparstat_cclk[`UMCTL2_REG_OFFSET_CRCPARSTAT_DFI_ALERT_ERR_CNT+:`UMCTL2_REG_SIZE_CRCPARSTAT_DFI_ALERT_ERR_CNT] = ddrc_reg_dfi_alert_err_cnt[(`UMCTL2_REG_SIZE_CRCPARSTAT_DFI_ALERT_ERR_CNT) -1:0];
      r47_crcparstat_cclk[`UMCTL2_REG_OFFSET_CRCPARSTAT_DFI_ALERT_ERR_INT+:`UMCTL2_REG_SIZE_CRCPARSTAT_DFI_ALERT_ERR_INT] = ddrc_reg_dfi_alert_err_int;
   end
   // For interrupt
   wire [(`UMCTL2_REG_SIZE_CRCPARSTAT_DFI_ALERT_ERR_CNT) -1:0] ddrc_reg_dfi_alert_err_cnt_pclk;
   assign ddrc_reg_dfi_alert_err_cnt_pclk = r47_crcparstat[`UMCTL2_REG_OFFSET_CRCPARSTAT_DFI_ALERT_ERR_CNT +: `UMCTL2_REG_SIZE_CRCPARSTAT_DFI_ALERT_ERR_CNT];
   wire ddrc_reg_dfi_alert_err_int_pclk;
   assign ddrc_reg_dfi_alert_err_int_pclk = r47_crcparstat[`UMCTL2_REG_OFFSET_CRCPARSTAT_DFI_ALERT_ERR_INT +: `UMCTL2_REG_SIZE_CRCPARSTAT_DFI_ALERT_ERR_INT];

   //------------------------
   // Register UMCTL2_REGS.INIT0
   //------------------------
   assign reg_ddrc_pre_cke_x1024_pclk[(`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024) -1:0] = r48_init0[`UMCTL2_REG_OFFSET_INIT0_PRE_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024];
   assign reg_ddrc_post_cke_x1024_pclk[(`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024) -1:0] = r48_init0[`UMCTL2_REG_OFFSET_INIT0_POST_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024];
   assign reg_ddrc_skip_dram_init_pclk[(`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT) -1:0] = r48_init0[`UMCTL2_REG_OFFSET_INIT0_SKIP_DRAM_INIT+:`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT];
   always_comb begin : s_data_r48_init0_combo_PROC
      s_data_r48_init0 = {REG_WIDTH {1'b0}};
      s_data_r48_init0[`UMCTL2_REG_OFFSET_INIT0_PRE_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024] = reg_ddrc_pre_cke_x1024_pclk[(`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024)-1:0];
      s_data_r48_init0[`UMCTL2_REG_OFFSET_INIT0_POST_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024] = reg_ddrc_post_cke_x1024_pclk[(`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024)-1:0];
      s_data_r48_init0[`UMCTL2_REG_OFFSET_INIT0_SKIP_DRAM_INIT+:`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT] = reg_ddrc_skip_dram_init_pclk[(`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT)-1:0];
   end
      assign reg_ddrc_pre_cke_x1024[(`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024)-1:0] = d_data_r48_init0[`UMCTL2_REG_OFFSET_INIT0_PRE_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024];
      assign reg_ddrc_post_cke_x1024[(`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024)-1:0] = d_data_r48_init0[`UMCTL2_REG_OFFSET_INIT0_POST_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024];
      assign reg_ddrc_skip_dram_init[(`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT)-1:0] = d_data_r48_init0[`UMCTL2_REG_OFFSET_INIT0_SKIP_DRAM_INIT+:`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT];
   //------------------------
   // Register UMCTL2_REGS.INIT1
   //------------------------
   assign reg_ddrc_pre_ocd_x32[(`UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32) -1:0] = r49_init1[`UMCTL2_REG_OFFSET_INIT1_PRE_OCD_X32+:`UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32];
   assign reg_ddrc_dram_rstn_x1024[(`UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024) -1:0] = r49_init1[`UMCTL2_REG_OFFSET_INIT1_DRAM_RSTN_X1024+:`UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024];
   //------------------------
   // Register UMCTL2_REGS.INIT3
   //------------------------
   assign reg_ddrc_emr[(`UMCTL2_REG_SIZE_INIT3_EMR) -1:0] = r51_init3[`UMCTL2_REG_OFFSET_INIT3_EMR+:`UMCTL2_REG_SIZE_INIT3_EMR];
   assign reg_ddrc_mr[(`UMCTL2_REG_SIZE_INIT3_MR) -1:0] = r51_init3[`UMCTL2_REG_OFFSET_INIT3_MR+:`UMCTL2_REG_SIZE_INIT3_MR];
   //------------------------
   // Register UMCTL2_REGS.INIT4
   //------------------------
   assign reg_ddrc_emr3_pclk[(`UMCTL2_REG_SIZE_INIT4_EMR3) -1:0] = r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR3+:`UMCTL2_REG_SIZE_INIT4_EMR3];
   assign reg_ddrc_emr2_pclk[(`UMCTL2_REG_SIZE_INIT4_EMR2) -1:0] = r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR2+:`UMCTL2_REG_SIZE_INIT4_EMR2];
   always_comb begin : s_data_r52_init4_combo_PROC
      s_data_r52_init4 = {REG_WIDTH {1'b0}};
      s_data_r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR3+:`UMCTL2_REG_SIZE_INIT4_EMR3] = reg_ddrc_emr3_pclk[(`UMCTL2_REG_SIZE_INIT4_EMR3)-1:0];
      s_data_r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR2+:`UMCTL2_REG_SIZE_INIT4_EMR2] = reg_ddrc_emr2_pclk[(`UMCTL2_REG_SIZE_INIT4_EMR2)-1:0];
   end
      assign reg_ddrc_emr3[(`UMCTL2_REG_SIZE_INIT4_EMR3)-1:0] = d_data_r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR3+:`UMCTL2_REG_SIZE_INIT4_EMR3];
      assign reg_ddrc_emr2[(`UMCTL2_REG_SIZE_INIT4_EMR2)-1:0] = d_data_r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR2+:`UMCTL2_REG_SIZE_INIT4_EMR2];
   //------------------------
   // Register UMCTL2_REGS.INIT5
   //------------------------
   assign reg_ddrc_dev_zqinit_x32[(`UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32) -1:0] = r53_init5[`UMCTL2_REG_OFFSET_INIT5_DEV_ZQINIT_X32+:`UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32];
   //------------------------
   // Register UMCTL2_REGS.INIT6
   //------------------------
   assign reg_ddrc_mr5[(`UMCTL2_REG_SIZE_INIT6_MR5) -1:0] = r54_init6[`UMCTL2_REG_OFFSET_INIT6_MR5+:`UMCTL2_REG_SIZE_INIT6_MR5];
   assign reg_ddrc_mr4[(`UMCTL2_REG_SIZE_INIT6_MR4) -1:0] = r54_init6[`UMCTL2_REG_OFFSET_INIT6_MR4+:`UMCTL2_REG_SIZE_INIT6_MR4];
   //------------------------
   // Register UMCTL2_REGS.INIT7
   //------------------------
   assign reg_ddrc_mr6[(`UMCTL2_REG_SIZE_INIT7_MR6) -1:0] = r55_init7[`UMCTL2_REG_OFFSET_INIT7_MR6+:`UMCTL2_REG_SIZE_INIT7_MR6];
   //------------------------
   // Register UMCTL2_REGS.DIMMCTL
   //------------------------
   assign reg_ddrc_dimm_stagger_cs_en_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_STAGGER_CS_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_STAGGER_CS_EN];
   assign reg_ddrc_dimm_addr_mirr_en_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_ADDR_MIRR_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_ADDR_MIRR_EN];
   assign reg_ddrc_dimm_output_inv_en_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_OUTPUT_INV_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_OUTPUT_INV_EN];
   assign reg_ddrc_mrs_a17_en_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_A17_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_A17_EN];
   assign reg_ddrc_mrs_bg1_en_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_BG1_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_BG1_EN];
   assign reg_ddrc_dimm_dis_bg_mirroring_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_DIS_BG_MIRRORING+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_DIS_BG_MIRRORING];
   assign reg_ddrc_lrdimm_bcom_cmd_prot_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_LRDIMM_BCOM_CMD_PROT+:`UMCTL2_REG_SIZE_DIMMCTL_LRDIMM_BCOM_CMD_PROT];
   assign reg_ddrc_rcd_weak_drive_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_WEAK_DRIVE+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_WEAK_DRIVE];
   assign reg_ddrc_rcd_a_output_disabled_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_A_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_A_OUTPUT_DISABLED];
   assign reg_ddrc_rcd_b_output_disabled_pclk = r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_B_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_B_OUTPUT_DISABLED];
   always_comb begin : s_data_r56_dimmctl_combo_PROC
      s_data_r56_dimmctl = {REG_WIDTH {1'b0}};
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_STAGGER_CS_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_STAGGER_CS_EN] = reg_ddrc_dimm_stagger_cs_en_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_ADDR_MIRR_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_ADDR_MIRR_EN] = reg_ddrc_dimm_addr_mirr_en_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_OUTPUT_INV_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_OUTPUT_INV_EN] = reg_ddrc_dimm_output_inv_en_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_A17_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_A17_EN] = reg_ddrc_mrs_a17_en_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_BG1_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_BG1_EN] = reg_ddrc_mrs_bg1_en_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_DIS_BG_MIRRORING+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_DIS_BG_MIRRORING] = reg_ddrc_dimm_dis_bg_mirroring_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_LRDIMM_BCOM_CMD_PROT+:`UMCTL2_REG_SIZE_DIMMCTL_LRDIMM_BCOM_CMD_PROT] = reg_ddrc_lrdimm_bcom_cmd_prot_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_WEAK_DRIVE+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_WEAK_DRIVE] = reg_ddrc_rcd_weak_drive_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_A_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_A_OUTPUT_DISABLED] = reg_ddrc_rcd_a_output_disabled_pclk;
      s_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_B_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_B_OUTPUT_DISABLED] = reg_ddrc_rcd_b_output_disabled_pclk;
   end
      assign reg_ddrc_dimm_stagger_cs_en = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_STAGGER_CS_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_STAGGER_CS_EN];
      assign reg_ddrc_dimm_addr_mirr_en = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_ADDR_MIRR_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_ADDR_MIRR_EN];
      assign reg_ddrc_dimm_output_inv_en = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_OUTPUT_INV_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_OUTPUT_INV_EN];
      assign reg_ddrc_mrs_a17_en = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_A17_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_A17_EN];
      assign reg_ddrc_mrs_bg1_en = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_BG1_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_BG1_EN];
      assign reg_ddrc_dimm_dis_bg_mirroring = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_DIS_BG_MIRRORING+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_DIS_BG_MIRRORING];
      assign reg_ddrc_lrdimm_bcom_cmd_prot = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_LRDIMM_BCOM_CMD_PROT+:`UMCTL2_REG_SIZE_DIMMCTL_LRDIMM_BCOM_CMD_PROT];
      assign reg_ddrc_rcd_weak_drive = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_WEAK_DRIVE+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_WEAK_DRIVE];
      assign reg_ddrc_rcd_a_output_disabled = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_A_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_A_OUTPUT_DISABLED];
      assign reg_ddrc_rcd_b_output_disabled = d_data_r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_B_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_B_OUTPUT_DISABLED];
   //------------------------
   // Register UMCTL2_REGS.RANKCTL
   //------------------------
   assign reg_ddrc_max_rank_rd[(`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD) -1:0] = r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_RD+:`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD];
   assign reg_ddrc_diff_rank_rd_gap[(`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP) -1:0] = r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP];
   assign reg_ddrc_diff_rank_wr_gap[(`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP) -1:0] = r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP];
   assign reg_ddrc_max_rank_wr[(`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR) -1:0] = r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_WR+:`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR];
   assign reg_ddrc_diff_rank_rd_gap_msb = r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP_MSB+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP_MSB];
   assign reg_ddrc_diff_rank_wr_gap_msb = r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP_MSB+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP_MSB];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG0
   //------------------------
   assign reg_ddrc_t_ras_min[(`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN) -1:0] = r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MIN+:`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN];
   assign reg_ddrc_t_ras_max[(`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX) -1:0] = r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MAX+:`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX];
   assign reg_ddrc_t_faw[(`UMCTL2_REG_SIZE_DRAMTMG0_T_FAW) -1:0] = r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_T_FAW+:`UMCTL2_REG_SIZE_DRAMTMG0_T_FAW];
   assign reg_ddrc_wr2pre[(`UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE) -1:0] = r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_WR2PRE+:`UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG1
   //------------------------
   assign reg_ddrc_t_rc[(`UMCTL2_REG_SIZE_DRAMTMG1_T_RC) -1:0] = r60_dramtmg1[`UMCTL2_REG_OFFSET_DRAMTMG1_T_RC+:`UMCTL2_REG_SIZE_DRAMTMG1_T_RC];
   assign reg_ddrc_rd2pre[(`UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE) -1:0] = r60_dramtmg1[`UMCTL2_REG_OFFSET_DRAMTMG1_RD2PRE+:`UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE];
   assign reg_ddrc_t_xp[(`UMCTL2_REG_SIZE_DRAMTMG1_T_XP) -1:0] = r60_dramtmg1[`UMCTL2_REG_OFFSET_DRAMTMG1_T_XP+:`UMCTL2_REG_SIZE_DRAMTMG1_T_XP];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG2
   //------------------------
   assign reg_ddrc_wr2rd[(`UMCTL2_REG_SIZE_DRAMTMG2_WR2RD) -1:0] = r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_WR2RD+:`UMCTL2_REG_SIZE_DRAMTMG2_WR2RD];
   assign reg_ddrc_rd2wr[(`UMCTL2_REG_SIZE_DRAMTMG2_RD2WR) -1:0] = r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_RD2WR+:`UMCTL2_REG_SIZE_DRAMTMG2_RD2WR];
   assign reg_ddrc_read_latency[(`UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY) -1:0] = r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_READ_LATENCY+:`UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY];
   assign reg_ddrc_write_latency[(`UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY) -1:0] = r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_WRITE_LATENCY+:`UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG3
   //------------------------
   assign reg_ddrc_t_mod[(`UMCTL2_REG_SIZE_DRAMTMG3_T_MOD) -1:0] = r62_dramtmg3[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MOD+:`UMCTL2_REG_SIZE_DRAMTMG3_T_MOD];
   assign reg_ddrc_t_mrd[(`UMCTL2_REG_SIZE_DRAMTMG3_T_MRD) -1:0] = r62_dramtmg3[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MRD+:`UMCTL2_REG_SIZE_DRAMTMG3_T_MRD];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG4
   //------------------------
   assign reg_ddrc_t_rp[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RP) -1:0] = r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RP+:`UMCTL2_REG_SIZE_DRAMTMG4_T_RP];
   assign reg_ddrc_t_rrd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RRD) -1:0] = r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RRD+:`UMCTL2_REG_SIZE_DRAMTMG4_T_RRD];
   assign reg_ddrc_t_ccd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_CCD) -1:0] = r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_CCD+:`UMCTL2_REG_SIZE_DRAMTMG4_T_CCD];
   assign reg_ddrc_t_rcd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RCD) -1:0] = r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RCD+:`UMCTL2_REG_SIZE_DRAMTMG4_T_RCD];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG5
   //------------------------
   assign reg_ddrc_t_cke[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKE) -1:0] = r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKE+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKE];
   assign reg_ddrc_t_ckesr[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR) -1:0] = r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKESR+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR];
   assign reg_ddrc_t_cksre[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE) -1:0] = r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRE+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE];
   assign reg_ddrc_t_cksrx[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX) -1:0] = r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRX+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG8
   //------------------------
   assign reg_ddrc_t_xs_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32) -1:0] = r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32];
   assign reg_ddrc_t_xs_dll_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32) -1:0] = r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_DLL_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32];
   assign reg_ddrc_t_xs_abort_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32) -1:0] = r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_ABORT_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32];
   assign reg_ddrc_t_xs_fast_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32) -1:0] = r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_FAST_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG9
   //------------------------
   assign reg_ddrc_wr2rd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S) -1:0] = r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_WR2RD_S+:`UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S];
   assign reg_ddrc_t_rrd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S) -1:0] = r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_T_RRD_S+:`UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S];
   assign reg_ddrc_t_ccd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S) -1:0] = r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_T_CCD_S+:`UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S];
   assign reg_ddrc_ddr4_wr_preamble = r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_DDR4_WR_PREAMBLE+:`UMCTL2_REG_SIZE_DRAMTMG9_DDR4_WR_PREAMBLE];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG10
   //------------------------
   assign reg_ddrc_t_gear_hold_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD) -1:0] = r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_HOLD+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD];
   assign reg_ddrc_t_gear_setup_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP) -1:0] = r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_SETUP+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP];
   assign reg_ddrc_t_cmd_gear_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR) -1:0] = r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_CMD_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR];
   assign reg_ddrc_t_sync_gear_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR) -1:0] = r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_SYNC_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR];
   always_comb begin : s_data_r69_dramtmg10_combo_PROC
      s_data_r69_dramtmg10 = {REG_WIDTH {1'b0}};
      s_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_HOLD+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD] = reg_ddrc_t_gear_hold_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD)-1:0];
      s_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_SETUP+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP] = reg_ddrc_t_gear_setup_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP)-1:0];
      s_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_CMD_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR] = reg_ddrc_t_cmd_gear_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR)-1:0];
      s_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_SYNC_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR] = reg_ddrc_t_sync_gear_pclk[(`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR)-1:0];
   end
      assign reg_ddrc_t_gear_hold[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD)-1:0] = d_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_HOLD+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD];
      assign reg_ddrc_t_gear_setup[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP)-1:0] = d_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_SETUP+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP];
      assign reg_ddrc_t_cmd_gear[(`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR)-1:0] = d_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_CMD_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR];
      assign reg_ddrc_t_sync_gear[(`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR)-1:0] = d_data_r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_SYNC_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG11
   //------------------------
   assign reg_ddrc_t_ckmpe[(`UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE) -1:0] = r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_T_CKMPE+:`UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE];
   assign reg_ddrc_t_mpx_s[(`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S) -1:0] = r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_S+:`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S];
   assign reg_ddrc_t_mpx_lh[(`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH) -1:0] = r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_LH+:`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH];
   assign reg_ddrc_post_mpsm_gap_x32[(`UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32) -1:0] = r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_POST_MPSM_GAP_X32+:`UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG12
   //------------------------
   assign reg_ddrc_t_mrd_pda[(`UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA) -1:0] = r71_dramtmg12[`UMCTL2_REG_OFFSET_DRAMTMG12_T_MRD_PDA+:`UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA];
   assign reg_ddrc_t_wr_mpr[(`UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR) -1:0] = r71_dramtmg12[`UMCTL2_REG_OFFSET_DRAMTMG12_T_WR_MPR+:`UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR];
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG15
   //------------------------
   assign reg_ddrc_t_stab_x32[(`UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32) -1:0] = r74_dramtmg15[`UMCTL2_REG_OFFSET_DRAMTMG15_T_STAB_X32+:`UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32];
   assign reg_ddrc_en_dfi_lp_t_stab = r74_dramtmg15[`UMCTL2_REG_OFFSET_DRAMTMG15_EN_DFI_LP_T_STAB+:`UMCTL2_REG_SIZE_DRAMTMG15_EN_DFI_LP_T_STAB];
   //------------------------
   // Register UMCTL2_REGS.ZQCTL0
   //------------------------
   assign reg_ddrc_t_zq_short_nop_pclk[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP) -1:0] = r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_SHORT_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP];
   assign reg_ddrc_t_zq_long_nop_pclk[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP) -1:0] = r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_LONG_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP];
   assign reg_ddrc_dis_mpsmx_zqcl_pclk = r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_MPSMX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_MPSMX_ZQCL];
   assign reg_ddrc_zq_resistor_shared_pclk = r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`UMCTL2_REG_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED];
   assign reg_ddrc_dis_srx_zqcl_pclk = r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_SRX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_SRX_ZQCL];
   assign reg_ddrc_dis_auto_zq_pclk = r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_AUTO_ZQ];
   always_comb begin : s_data_r82_zqctl0_combo_PROC
      s_data_r82_zqctl0 = {REG_WIDTH {1'b0}};
      s_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_SHORT_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP] = reg_ddrc_t_zq_short_nop_pclk[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP)-1:0];
      s_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_LONG_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP] = reg_ddrc_t_zq_long_nop_pclk[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP)-1:0];
      s_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_MPSMX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_MPSMX_ZQCL] = reg_ddrc_dis_mpsmx_zqcl_pclk;
      s_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`UMCTL2_REG_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED] = reg_ddrc_zq_resistor_shared_pclk;
      s_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_SRX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_SRX_ZQCL] = reg_ddrc_dis_srx_zqcl_pclk;
      s_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_AUTO_ZQ] = reg_ddrc_dis_auto_zq_pclk;
   end
      assign reg_ddrc_t_zq_short_nop[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP)-1:0] = d_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_SHORT_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP];
      assign reg_ddrc_t_zq_long_nop[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP)-1:0] = d_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_LONG_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP];
      assign reg_ddrc_dis_mpsmx_zqcl = d_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_MPSMX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_MPSMX_ZQCL];
      assign reg_ddrc_zq_resistor_shared = d_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`UMCTL2_REG_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED];
      assign reg_ddrc_dis_srx_zqcl = d_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_SRX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_SRX_ZQCL];
      assign reg_ddrc_dis_auto_zq = d_data_r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_AUTO_ZQ];
   //------------------------
   // Register UMCTL2_REGS.ZQCTL1
   //------------------------
   assign reg_ddrc_t_zq_short_interval_x1024[(`UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024) -1:0] = r83_zqctl1[`UMCTL2_REG_OFFSET_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024+:`UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024];
   //------------------------
   // Register UMCTL2_REGS.DFITMG0
   //------------------------
   assign reg_ddrc_dfi_tphy_wrlat[(`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT) -1:0] = r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRLAT+:`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT];
   assign reg_ddrc_dfi_tphy_wrdata[(`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA) -1:0] = r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRDATA+:`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA];
   assign reg_ddrc_dfi_wrdata_use_dfi_phy_clk = r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK+:`UMCTL2_REG_SIZE_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK];
   assign reg_ddrc_dfi_t_rddata_en[(`UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN) -1:0] = r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_RDDATA_EN+:`UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN];
   assign reg_ddrc_dfi_rddata_use_dfi_phy_clk = r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK+:`UMCTL2_REG_SIZE_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK];
   assign reg_ddrc_dfi_t_ctrl_delay[(`UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY) -1:0] = r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_CTRL_DELAY+:`UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY];
   //------------------------
   // Register UMCTL2_REGS.DFITMG1
   //------------------------
   assign reg_ddrc_dfi_t_dram_clk_enable_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE) -1:0] = r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE];
   assign reg_ddrc_dfi_t_dram_clk_disable_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE) -1:0] = r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE];
   assign reg_ddrc_dfi_t_wrdata_delay_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY) -1:0] = r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY];
   assign reg_ddrc_dfi_t_parin_lat_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT) -1:0] = r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_PARIN_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT];
   assign reg_ddrc_dfi_t_cmd_lat_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT) -1:0] = r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_CMD_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT];
   always_comb begin : s_data_r87_dfitmg1_combo_PROC
      s_data_r87_dfitmg1 = {REG_WIDTH {1'b0}};
      s_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE] = reg_ddrc_dfi_t_dram_clk_enable_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE)-1:0];
      s_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE] = reg_ddrc_dfi_t_dram_clk_disable_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE)-1:0];
      s_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY] = reg_ddrc_dfi_t_wrdata_delay_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY)-1:0];
      s_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_PARIN_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT] = reg_ddrc_dfi_t_parin_lat_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT)-1:0];
      s_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_CMD_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT] = reg_ddrc_dfi_t_cmd_lat_pclk[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT)-1:0];
   end
      assign reg_ddrc_dfi_t_dram_clk_enable[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE)-1:0] = d_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE];
      assign reg_ddrc_dfi_t_dram_clk_disable[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE)-1:0] = d_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE];
      assign reg_ddrc_dfi_t_wrdata_delay[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY)-1:0] = d_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY];
      assign reg_ddrc_dfi_t_parin_lat[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT)-1:0] = d_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_PARIN_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT];
      assign reg_ddrc_dfi_t_cmd_lat[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT)-1:0] = d_data_r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_CMD_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT];
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG0
   //------------------------
   assign reg_ddrc_dfi_lp_en_pd_pclk = r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_PD];
   assign reg_ddrc_dfi_lp_wakeup_pd_pclk[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD) -1:0] = r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD];
   assign reg_ddrc_dfi_lp_en_sr_pclk = r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_SR];
   assign reg_ddrc_dfi_lp_wakeup_sr_pclk[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR) -1:0] = r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR];
   assign reg_ddrc_dfi_tlp_resp_pclk[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP) -1:0] = r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_TLP_RESP+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP];
   always_comb begin : s_data_r88_dfilpcfg0_combo_PROC
      s_data_r88_dfilpcfg0 = {REG_WIDTH {1'b0}};
      s_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_PD] = reg_ddrc_dfi_lp_en_pd_pclk;
      s_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD] = reg_ddrc_dfi_lp_wakeup_pd_pclk[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD)-1:0];
      s_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_SR] = reg_ddrc_dfi_lp_en_sr_pclk;
      s_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR] = reg_ddrc_dfi_lp_wakeup_sr_pclk[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR)-1:0];
      s_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_TLP_RESP+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP] = reg_ddrc_dfi_tlp_resp_pclk[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP)-1:0];
   end
      assign reg_ddrc_dfi_lp_en_pd = d_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_PD];
      assign reg_ddrc_dfi_lp_wakeup_pd[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD)-1:0] = d_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD];
      assign reg_ddrc_dfi_lp_en_sr = d_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_SR];
      assign reg_ddrc_dfi_lp_wakeup_sr[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR)-1:0] = d_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR];
      assign reg_ddrc_dfi_tlp_resp[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP)-1:0] = d_data_r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_TLP_RESP+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP];
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG1
   //------------------------
   assign reg_ddrc_dfi_lp_en_mpsm = r89_dfilpcfg1[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_EN_MPSM+:`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_EN_MPSM];
   assign reg_ddrc_dfi_lp_wakeup_mpsm[(`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM) -1:0] = r89_dfilpcfg1[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_WAKEUP_MPSM+:`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM];
   //------------------------
   // Register UMCTL2_REGS.DFIUPD0
   //------------------------
   assign reg_ddrc_dfi_t_ctrlup_min[(`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN) -1:0] = r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MIN+:`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN];
   assign reg_ddrc_dfi_t_ctrlup_max[(`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX) -1:0] = r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MAX+:`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX];
   assign reg_ddrc_ctrlupd_pre_srx = r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX+:`UMCTL2_REG_SIZE_DFIUPD0_CTRLUPD_PRE_SRX];
   assign reg_ddrc_dis_auto_ctrlupd_srx = r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX+:`UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX];
   assign reg_ddrc_dis_auto_ctrlupd = r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD+:`UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD];
   //------------------------
   // Register UMCTL2_REGS.DFIUPD1
   //------------------------
   assign reg_ddrc_dfi_t_ctrlupd_interval_max_x1024[(`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024) -1:0] = r91_dfiupd1[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024+:`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024];
   assign reg_ddrc_dfi_t_ctrlupd_interval_min_x1024[(`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024) -1:0] = r91_dfiupd1[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024+:`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024];
   //------------------------
   // Register UMCTL2_REGS.DFIUPD2
   //------------------------
   assign reg_ddrc_dfi_phyupd_en = r92_dfiupd2[`UMCTL2_REG_OFFSET_DFIUPD2_DFI_PHYUPD_EN+:`UMCTL2_REG_SIZE_DFIUPD2_DFI_PHYUPD_EN];
   //------------------------
   // Register UMCTL2_REGS.DFIMISC
   //------------------------
   assign reg_ddrc_dfi_init_complete_en_pclk = r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN];
   assign reg_ddrc_phy_dbi_mode_pclk = r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_PHY_DBI_MODE+:`UMCTL2_REG_SIZE_DFIMISC_PHY_DBI_MODE];
   assign reg_ddrc_ctl_idle_en_pclk = r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_CTL_IDLE_EN+:`UMCTL2_REG_SIZE_DFIMISC_CTL_IDLE_EN];
   assign reg_ddrc_dfi_init_start_pclk = r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_START+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_START];
   assign reg_ddrc_dis_dyn_adr_tri_pclk = r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DIS_DYN_ADR_TRI+:`UMCTL2_REG_SIZE_DFIMISC_DIS_DYN_ADR_TRI];
   assign reg_ddrc_dfi_frequency_pclk[(`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY) -1:0] = r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_FREQUENCY+:`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY];
   always_comb begin : s_data_r94_dfimisc_combo_PROC
      s_data_r94_dfimisc = {REG_WIDTH {1'b0}};
      s_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN] = reg_ddrc_dfi_init_complete_en_pclk;
      s_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_PHY_DBI_MODE+:`UMCTL2_REG_SIZE_DFIMISC_PHY_DBI_MODE] = reg_ddrc_phy_dbi_mode_pclk;
      s_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_CTL_IDLE_EN+:`UMCTL2_REG_SIZE_DFIMISC_CTL_IDLE_EN] = reg_ddrc_ctl_idle_en_pclk;
      s_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_START+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_START] = reg_ddrc_dfi_init_start_pclk;
      s_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DIS_DYN_ADR_TRI+:`UMCTL2_REG_SIZE_DFIMISC_DIS_DYN_ADR_TRI] = reg_ddrc_dis_dyn_adr_tri_pclk;
      s_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_FREQUENCY+:`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY] = reg_ddrc_dfi_frequency_pclk[(`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY)-1:0];
   end
      assign reg_ddrc_dfi_init_complete_en = d_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN];
      assign reg_ddrc_phy_dbi_mode = d_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_PHY_DBI_MODE+:`UMCTL2_REG_SIZE_DFIMISC_PHY_DBI_MODE];
      assign reg_ddrc_ctl_idle_en = d_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_CTL_IDLE_EN+:`UMCTL2_REG_SIZE_DFIMISC_CTL_IDLE_EN];
      assign reg_ddrc_dfi_init_start = d_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_START+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_START];
      assign reg_ddrc_dis_dyn_adr_tri = d_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DIS_DYN_ADR_TRI+:`UMCTL2_REG_SIZE_DFIMISC_DIS_DYN_ADR_TRI];
      assign reg_ddrc_dfi_frequency[(`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY)-1:0] = d_data_r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_FREQUENCY+:`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY];
   //------------------------
   // Register UMCTL2_REGS.DFITMG3
   //------------------------
   assign reg_ddrc_dfi_t_geardown_delay[(`UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY) -1:0] = r96_dfitmg3[`UMCTL2_REG_OFFSET_DFITMG3_DFI_T_GEARDOWN_DELAY+:`UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY];
   //------------------------
   // Register UMCTL2_REGS.DFISTAT
   //------------------------
   always_comb begin : r97_dfistat_combo_PROC
      r97_dfistat = {REG_WIDTH{1'b0}};
      r97_dfistat[`UMCTL2_REG_OFFSET_DFISTAT_DFI_INIT_COMPLETE+:`UMCTL2_REG_SIZE_DFISTAT_DFI_INIT_COMPLETE] = ddrc_reg_dfi_init_complete_pclk;
      r97_dfistat[`UMCTL2_REG_OFFSET_DFISTAT_DFI_LP_ACK+:`UMCTL2_REG_SIZE_DFISTAT_DFI_LP_ACK] = ddrc_reg_dfi_lp_ack_pclk;
   end
   //------------------------
   // Register UMCTL2_REGS.DBICTL
   //------------------------
   assign reg_ddrc_dm_en_pclk = r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_DM_EN+:`UMCTL2_REG_SIZE_DBICTL_DM_EN];
   assign reg_ddrc_wr_dbi_en_pclk = r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_WR_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_WR_DBI_EN];
   assign reg_ddrc_rd_dbi_en_pclk = r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_RD_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_RD_DBI_EN];
   always_comb begin : s_data_r98_dbictl_combo_PROC
      s_data_r98_dbictl = {REG_WIDTH {1'b0}};
      s_data_r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_DM_EN+:`UMCTL2_REG_SIZE_DBICTL_DM_EN] = reg_ddrc_dm_en_pclk;
      s_data_r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_WR_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_WR_DBI_EN] = reg_ddrc_wr_dbi_en_pclk;
      s_data_r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_RD_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_RD_DBI_EN] = reg_ddrc_rd_dbi_en_pclk;
   end
      assign reg_ddrc_dm_en = d_data_r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_DM_EN+:`UMCTL2_REG_SIZE_DBICTL_DM_EN];
      assign reg_ddrc_wr_dbi_en = d_data_r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_WR_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_WR_DBI_EN];
      assign reg_ddrc_rd_dbi_en = d_data_r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_RD_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_RD_DBI_EN];
   //------------------------
   // Register UMCTL2_REGS.DFIPHYMSTR
   //------------------------
   assign reg_ddrc_dfi_phymstr_en_pclk = r99_dfiphymstr[`UMCTL2_REG_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`UMCTL2_REG_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN];
   always_comb begin : s_data_r99_dfiphymstr_combo_PROC
      s_data_r99_dfiphymstr = {REG_WIDTH {1'b0}};
      s_data_r99_dfiphymstr[`UMCTL2_REG_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`UMCTL2_REG_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN] = reg_ddrc_dfi_phymstr_en_pclk;
   end
      assign reg_ddrc_dfi_phymstr_en = d_data_r99_dfiphymstr[`UMCTL2_REG_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`UMCTL2_REG_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP0
   //------------------------
   assign reg_ddrc_addrmap_cs_bit0[(`UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0) -1:0] = r100_addrmap0[`UMCTL2_REG_OFFSET_ADDRMAP0_ADDRMAP_CS_BIT0+:`UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP1
   //------------------------
   assign reg_ddrc_addrmap_bank_b0[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0) -1:0] = r101_addrmap1[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B0+:`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0];
   assign reg_ddrc_addrmap_bank_b1[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1) -1:0] = r101_addrmap1[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B1+:`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1];
   assign reg_ddrc_addrmap_bank_b2[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2) -1:0] = r101_addrmap1[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B2+:`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP2
   //------------------------
   assign reg_ddrc_addrmap_col_b2[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2) -1:0] = r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B2+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2];
   assign reg_ddrc_addrmap_col_b3[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3) -1:0] = r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B3+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3];
   assign reg_ddrc_addrmap_col_b4[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4) -1:0] = r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B4+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4];
   assign reg_ddrc_addrmap_col_b5[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5) -1:0] = r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B5+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP3
   //------------------------
   assign reg_ddrc_addrmap_col_b6[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6) -1:0] = r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B6+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6];
   assign reg_ddrc_addrmap_col_b7[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7) -1:0] = r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B7+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7];
   assign reg_ddrc_addrmap_col_b8[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8) -1:0] = r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B8+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8];
   assign reg_ddrc_addrmap_col_b9[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9) -1:0] = r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B9+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP4
   //------------------------
   assign reg_ddrc_addrmap_col_b10[(`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10) -1:0] = r104_addrmap4[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B10+:`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10];
   assign reg_ddrc_addrmap_col_b11[(`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11) -1:0] = r104_addrmap4[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B11+:`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP5
   //------------------------
   assign reg_ddrc_addrmap_row_b0[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0) -1:0] = r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B0+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0];
   assign reg_ddrc_addrmap_row_b1[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1) -1:0] = r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B1+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1];
   assign reg_ddrc_addrmap_row_b2_10[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10) -1:0] = r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B2_10+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10];
   assign reg_ddrc_addrmap_row_b11[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11) -1:0] = r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B11+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP6
   //------------------------
   assign reg_ddrc_addrmap_row_b12_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12) -1:0] = r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B12+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12];
   assign reg_ddrc_addrmap_row_b13_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13) -1:0] = r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B13+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13];
   assign reg_ddrc_addrmap_row_b14_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14) -1:0] = r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B14+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14];
   assign reg_ddrc_addrmap_row_b15_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15) -1:0] = r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B15+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15];
   always_comb begin : s_data_r106_addrmap6_combo_PROC
      s_data_r106_addrmap6 = {REG_WIDTH {1'b0}};
      s_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B12+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12] = reg_ddrc_addrmap_row_b12_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12)-1:0];
      s_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B13+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13] = reg_ddrc_addrmap_row_b13_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13)-1:0];
      s_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B14+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14] = reg_ddrc_addrmap_row_b14_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14)-1:0];
      s_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B15+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15] = reg_ddrc_addrmap_row_b15_pclk[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15)-1:0];
   end
      assign reg_ddrc_addrmap_row_b12[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12)-1:0] = d_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B12+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12];
      assign reg_ddrc_addrmap_row_b13[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13)-1:0] = d_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B13+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13];
      assign reg_ddrc_addrmap_row_b14[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14)-1:0] = d_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B14+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14];
      assign reg_ddrc_addrmap_row_b15[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15)-1:0] = d_data_r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B15+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP7
   //------------------------
   assign reg_ddrc_addrmap_row_b16_pclk[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16) -1:0] = r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16];
   assign reg_ddrc_addrmap_row_b17_pclk[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17) -1:0] = r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17];
   always_comb begin : s_data_r107_addrmap7_combo_PROC
      s_data_r107_addrmap7 = {REG_WIDTH {1'b0}};
      s_data_r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16] = reg_ddrc_addrmap_row_b16_pclk[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16)-1:0];
      s_data_r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17] = reg_ddrc_addrmap_row_b17_pclk[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17)-1:0];
   end
      assign reg_ddrc_addrmap_row_b16[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16)-1:0] = d_data_r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16];
      assign reg_ddrc_addrmap_row_b17[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17)-1:0] = d_data_r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP8
   //------------------------
   assign reg_ddrc_addrmap_bg_b0[(`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0) -1:0] = r108_addrmap8[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B0+:`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0];
   assign reg_ddrc_addrmap_bg_b1[(`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1) -1:0] = r108_addrmap8[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B1+:`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP9
   //------------------------
   assign reg_ddrc_addrmap_row_b2[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2) -1:0] = r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B2+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2];
   assign reg_ddrc_addrmap_row_b3[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3) -1:0] = r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B3+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3];
   assign reg_ddrc_addrmap_row_b4[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4) -1:0] = r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B4+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4];
   assign reg_ddrc_addrmap_row_b5[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5) -1:0] = r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B5+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP10
   //------------------------
   assign reg_ddrc_addrmap_row_b6[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6) -1:0] = r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B6+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6];
   assign reg_ddrc_addrmap_row_b7[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7) -1:0] = r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B7+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7];
   assign reg_ddrc_addrmap_row_b8[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8) -1:0] = r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B8+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8];
   assign reg_ddrc_addrmap_row_b9[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9) -1:0] = r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B9+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9];
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP11
   //------------------------
   assign reg_ddrc_addrmap_row_b10[(`UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10) -1:0] = r111_addrmap11[`UMCTL2_REG_OFFSET_ADDRMAP11_ADDRMAP_ROW_B10+:`UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10];
   //------------------------
   // Register UMCTL2_REGS.ODTCFG
   //------------------------
   assign reg_ddrc_rd_odt_delay[(`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY) -1:0] = r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_DELAY+:`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY];
   assign reg_ddrc_rd_odt_hold[(`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD) -1:0] = r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_HOLD+:`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD];
   assign reg_ddrc_wr_odt_delay[(`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY) -1:0] = r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_DELAY+:`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY];
   assign reg_ddrc_wr_odt_hold[(`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD) -1:0] = r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_HOLD+:`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD];
   //------------------------
   // Register UMCTL2_REGS.ODTMAP
   //------------------------
   assign reg_ddrc_rank0_wr_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT) -1:0] = r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_WR_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT];
   assign reg_ddrc_rank0_rd_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT) -1:0] = r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_RD_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT];
   assign reg_ddrc_rank1_wr_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT) -1:0] = r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_WR_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT];
   assign reg_ddrc_rank1_rd_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT) -1:0] = r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_RD_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT];
   //------------------------
   // Register UMCTL2_REGS.SCHED
   //------------------------
   assign reg_ddrc_prefer_write = r115_sched[`UMCTL2_REG_OFFSET_SCHED_PREFER_WRITE+:`UMCTL2_REG_SIZE_SCHED_PREFER_WRITE];
   assign reg_ddrc_pageclose = r115_sched[`UMCTL2_REG_OFFSET_SCHED_PAGECLOSE+:`UMCTL2_REG_SIZE_SCHED_PAGECLOSE];
   assign reg_ddrc_autopre_rmw = r115_sched[`UMCTL2_REG_OFFSET_SCHED_AUTOPRE_RMW+:`UMCTL2_REG_SIZE_SCHED_AUTOPRE_RMW];
   assign reg_ddrc_lpr_num_entries[(`UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES) -1:0] = r115_sched[`UMCTL2_REG_OFFSET_SCHED_LPR_NUM_ENTRIES+:`UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES];
   assign reg_ddrc_go2critical_hysteresis[(`UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS) -1:0] = r115_sched[`UMCTL2_REG_OFFSET_SCHED_GO2CRITICAL_HYSTERESIS+:`UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS];
   assign reg_ddrc_rdwr_idle_gap[(`UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP) -1:0] = r115_sched[`UMCTL2_REG_OFFSET_SCHED_RDWR_IDLE_GAP+:`UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP];
   //------------------------
   // Register UMCTL2_REGS.SCHED1
   //------------------------
   assign reg_ddrc_pageclose_timer[(`UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER) -1:0] = r116_sched1[`UMCTL2_REG_OFFSET_SCHED1_PAGECLOSE_TIMER+:`UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER];
   //------------------------
   // Register UMCTL2_REGS.PERFHPR1
   //------------------------
   assign reg_ddrc_hpr_max_starve[(`UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE) -1:0] = r118_perfhpr1[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_MAX_STARVE+:`UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE];
   assign reg_ddrc_hpr_xact_run_length[(`UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH) -1:0] = r118_perfhpr1[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH+:`UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH];
   //------------------------
   // Register UMCTL2_REGS.PERFLPR1
   //------------------------
   assign reg_ddrc_lpr_max_starve[(`UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE) -1:0] = r119_perflpr1[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_MAX_STARVE+:`UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE];
   assign reg_ddrc_lpr_xact_run_length[(`UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH) -1:0] = r119_perflpr1[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH+:`UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH];
   //------------------------
   // Register UMCTL2_REGS.PERFWR1
   //------------------------
   assign reg_ddrc_w_max_starve[(`UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE) -1:0] = r120_perfwr1[`UMCTL2_REG_OFFSET_PERFWR1_W_MAX_STARVE+:`UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE];
   assign reg_ddrc_w_xact_run_length[(`UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH) -1:0] = r120_perfwr1[`UMCTL2_REG_OFFSET_PERFWR1_W_XACT_RUN_LENGTH+:`UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH];
   //------------------------
   // Register UMCTL2_REGS.DBG0
   //------------------------
   assign reg_ddrc_dis_wc = r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_WC+:`UMCTL2_REG_SIZE_DBG0_DIS_WC];
   assign reg_ddrc_dis_collision_page_opt = r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_COLLISION_PAGE_OPT+:`UMCTL2_REG_SIZE_DBG0_DIS_COLLISION_PAGE_OPT];
   assign reg_ddrc_dis_max_rank_rd_opt = r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_RD_OPT+:`UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_RD_OPT];
   assign reg_ddrc_dis_max_rank_wr_opt = r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_WR_OPT+:`UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_WR_OPT];
   //------------------------
   // Register UMCTL2_REGS.DBG1
   //------------------------
   assign reg_ddrc_dis_dq_pclk = r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_DQ+:`UMCTL2_REG_SIZE_DBG1_DIS_DQ];
   assign reg_ddrc_dis_hif_pclk = r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_HIF+:`UMCTL2_REG_SIZE_DBG1_DIS_HIF];
   always_comb begin : s_data_r146_dbg1_combo_PROC
      s_data_r146_dbg1 = {REG_WIDTH {1'b0}};
      s_data_r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_DQ+:`UMCTL2_REG_SIZE_DBG1_DIS_DQ] = reg_ddrc_dis_dq_pclk;
      s_data_r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_HIF+:`UMCTL2_REG_SIZE_DBG1_DIS_HIF] = reg_ddrc_dis_hif_pclk;
   end
      assign reg_ddrc_dis_dq = d_data_r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_DQ+:`UMCTL2_REG_SIZE_DBG1_DIS_DQ];
      assign reg_ddrc_dis_hif = d_data_r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_HIF+:`UMCTL2_REG_SIZE_DBG1_DIS_HIF];
   //------------------------
   // Register UMCTL2_REGS.DBGCAM
   //------------------------
   always_comb begin : r147_dbgcam_combo_PROC
      r147_dbgcam = {REG_WIDTH{1'b0}};
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_HPR_Q_DEPTH+:`UMCTL2_REG_SIZE_DBGCAM_DBG_HPR_Q_DEPTH] = ddrc_reg_dbg_hpr_q_depth_pclk[(`UMCTL2_REG_SIZE_DBGCAM_DBG_HPR_Q_DEPTH) -1:0];
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_LPR_Q_DEPTH+:`UMCTL2_REG_SIZE_DBGCAM_DBG_LPR_Q_DEPTH] = ddrc_reg_dbg_lpr_q_depth_pclk[(`UMCTL2_REG_SIZE_DBGCAM_DBG_LPR_Q_DEPTH) -1:0];
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_W_Q_DEPTH+:`UMCTL2_REG_SIZE_DBGCAM_DBG_W_Q_DEPTH] = ddrc_reg_dbg_w_q_depth_pclk[(`UMCTL2_REG_SIZE_DBGCAM_DBG_W_Q_DEPTH) -1:0];
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_RD_Q_EMPTY+:`UMCTL2_REG_SIZE_DBGCAM_DBG_RD_Q_EMPTY] = ddrc_reg_dbg_rd_q_empty_pclk;
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_WR_Q_EMPTY+:`UMCTL2_REG_SIZE_DBGCAM_DBG_WR_Q_EMPTY] = ddrc_reg_dbg_wr_q_empty_pclk;
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_RD_DATA_PIPELINE_EMPTY+:`UMCTL2_REG_SIZE_DBGCAM_RD_DATA_PIPELINE_EMPTY] = ddrc_reg_rd_data_pipeline_empty_pclk;
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_WR_DATA_PIPELINE_EMPTY+:`UMCTL2_REG_SIZE_DBGCAM_WR_DATA_PIPELINE_EMPTY] = ddrc_reg_wr_data_pipeline_empty_pclk;
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_STALL_WR+:`UMCTL2_REG_SIZE_DBGCAM_DBG_STALL_WR] = ddrc_reg_dbg_stall_wr_pclk;
      r147_dbgcam[`UMCTL2_REG_OFFSET_DBGCAM_DBG_STALL_RD+:`UMCTL2_REG_SIZE_DBGCAM_DBG_STALL_RD] = ddrc_reg_dbg_stall_rd_pclk;
   end
   //------------------------
   // Register UMCTL2_REGS.DBGCMD
   //------------------------
   assign reg_ddrc_rank0_refresh_pclk = r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_RANK0_REFRESH+:`UMCTL2_REG_SIZE_DBGCMD_RANK0_REFRESH];
   assign ddrc_reg_rank0_refresh_busy_int = ddrc_reg_rank0_refresh_busy_pclk;
   assign reg_ddrc_rank1_refresh_pclk = r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_RANK1_REFRESH+:`UMCTL2_REG_SIZE_DBGCMD_RANK1_REFRESH];
   assign ddrc_reg_rank1_refresh_busy_int = ddrc_reg_rank1_refresh_busy_pclk;
   assign reg_ddrc_zq_calib_short_pclk = r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_ZQ_CALIB_SHORT+:`UMCTL2_REG_SIZE_DBGCMD_ZQ_CALIB_SHORT];
   assign ddrc_reg_zq_calib_short_busy_int = ddrc_reg_zq_calib_short_busy_pclk;
   assign reg_ddrc_ctrlupd_pclk = r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_CTRLUPD+:`UMCTL2_REG_SIZE_DBGCMD_CTRLUPD];
   assign ddrc_reg_ctrlupd_busy_int = ddrc_reg_ctrlupd_busy_pclk;
   always_comb begin : s_data_r148_dbgcmd_combo_PROC
      s_data_r148_dbgcmd = {REG_WIDTH {1'b0}};
   end
   //------------------------
   // Register UMCTL2_REGS.DBGSTAT
   //------------------------
   wire ddrc_reg_rank0_refresh_busy_pulse_pclk;
   
   reg  ddrc_reg_rank0_refresh_busy_ahead;
   reg  reg_ddrc_rank0_refresh_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_rank0_refresh_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_rank0_refresh_busy_ahead <= 1'b0; 
         reg_ddrc_rank0_refresh_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_rank0_refresh_pclk_s0 <= reg_ddrc_rank0_refresh_pclk; 
         if (ddrc_reg_rank0_refresh_busy_pulse_pclk || ddrc_reg_rank0_refresh_busy_pclk) begin 
            ddrc_reg_rank0_refresh_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_rank0_refresh_pclk & (!reg_ddrc_rank0_refresh_pclk_s0)) begin 
            ddrc_reg_rank0_refresh_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   wire ddrc_reg_rank1_refresh_busy_pulse_pclk;
   
   reg  ddrc_reg_rank1_refresh_busy_ahead;
   reg  reg_ddrc_rank1_refresh_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_rank1_refresh_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_rank1_refresh_busy_ahead <= 1'b0; 
         reg_ddrc_rank1_refresh_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_rank1_refresh_pclk_s0 <= reg_ddrc_rank1_refresh_pclk; 
         if (ddrc_reg_rank1_refresh_busy_pulse_pclk || ddrc_reg_rank1_refresh_busy_pclk) begin 
            ddrc_reg_rank1_refresh_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_rank1_refresh_pclk & (!reg_ddrc_rank1_refresh_pclk_s0)) begin 
            ddrc_reg_rank1_refresh_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   wire ddrc_reg_zq_calib_short_busy_pulse_pclk;
   
   reg  ddrc_reg_zq_calib_short_busy_ahead;
   reg  reg_ddrc_zq_calib_short_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_zq_calib_short_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_zq_calib_short_busy_ahead <= 1'b0; 
         reg_ddrc_zq_calib_short_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_zq_calib_short_pclk_s0 <= reg_ddrc_zq_calib_short_pclk; 
         if (ddrc_reg_zq_calib_short_busy_pulse_pclk || ddrc_reg_zq_calib_short_busy_pclk) begin 
            ddrc_reg_zq_calib_short_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_zq_calib_short_pclk & (!reg_ddrc_zq_calib_short_pclk_s0)) begin 
            ddrc_reg_zq_calib_short_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   wire ddrc_reg_ctrlupd_busy_pulse_pclk;
   
   reg  ddrc_reg_ctrlupd_busy_ahead;
   reg  reg_ddrc_ctrlupd_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_ctrlupd_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_ctrlupd_busy_ahead <= 1'b0; 
         reg_ddrc_ctrlupd_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_ctrlupd_pclk_s0 <= reg_ddrc_ctrlupd_pclk; 
         if (ddrc_reg_ctrlupd_busy_pulse_pclk || ddrc_reg_ctrlupd_busy_pclk) begin 
            ddrc_reg_ctrlupd_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_ctrlupd_pclk & (!reg_ddrc_ctrlupd_pclk_s0)) begin 
            ddrc_reg_ctrlupd_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   always_comb begin : r149_dbgstat_combo_PROC
      r149_dbgstat = {REG_WIDTH{1'b0}};
      r149_dbgstat[`UMCTL2_REG_OFFSET_DBGSTAT_RANK0_REFRESH_BUSY+:`UMCTL2_REG_SIZE_DBGSTAT_RANK0_REFRESH_BUSY] = ddrc_reg_rank0_refresh_busy_pclk          | ddrc_reg_rank0_refresh_busy_ahead
          | ff_rank0_refresh_saved
;
      r149_dbgstat[`UMCTL2_REG_OFFSET_DBGSTAT_RANK1_REFRESH_BUSY+:`UMCTL2_REG_SIZE_DBGSTAT_RANK1_REFRESH_BUSY] = ddrc_reg_rank1_refresh_busy_pclk          | ddrc_reg_rank1_refresh_busy_ahead
          | ff_rank1_refresh_saved
;
      r149_dbgstat[`UMCTL2_REG_OFFSET_DBGSTAT_ZQ_CALIB_SHORT_BUSY+:`UMCTL2_REG_SIZE_DBGSTAT_ZQ_CALIB_SHORT_BUSY] = ddrc_reg_zq_calib_short_busy_pclk          | ddrc_reg_zq_calib_short_busy_ahead
          | ff_zq_calib_short_saved
;
      r149_dbgstat[`UMCTL2_REG_OFFSET_DBGSTAT_CTRLUPD_BUSY+:`UMCTL2_REG_SIZE_DBGSTAT_CTRLUPD_BUSY] = ddrc_reg_ctrlupd_busy_pclk          | ddrc_reg_ctrlupd_busy_ahead
          | ff_ctrlupd_saved
;
   end
   //------------------------
   // Register UMCTL2_REGS.SWCTL
   //------------------------
   assign reg_ddrc_sw_done = r151_swctl[`UMCTL2_REG_OFFSET_SWCTL_SW_DONE+:`UMCTL2_REG_SIZE_SWCTL_SW_DONE];
   //------------------------
   // Register UMCTL2_REGS.SWSTAT
   //------------------------
   always_comb begin : r152_swstat_combo_PROC
      r152_swstat = {REG_WIDTH{1'b0}};
      r152_swstat[`UMCTL2_REG_OFFSET_SWSTAT_SW_DONE_ACK+:`UMCTL2_REG_SIZE_SWSTAT_SW_DONE_ACK] = ddrc_reg_sw_done_ack;
   end
   //------------------------
   // Register UMCTL2_REGS.SWCTLSTATIC
   //------------------------
   assign reg_ddrc_sw_static_unlock = r153_swctlstatic[`UMCTL2_REG_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK+:`UMCTL2_REG_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK];
   //------------------------
   // Register UMCTL2_REGS.POISONCFG
   //------------------------
   assign reg_ddrc_wr_poison_slverr_en_pclk = r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_SLVERR_EN];
   assign reg_ddrc_wr_poison_intr_en_pclk = r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_EN];
   assign reg_ddrc_wr_poison_intr_clr_pclk = r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_CLR+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_CLR];
   assign reg_ddrc_rd_poison_slverr_en_pclk = r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_SLVERR_EN];
   assign reg_ddrc_rd_poison_intr_en_pclk = r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_EN];
   assign reg_ddrc_rd_poison_intr_clr_pclk = r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_CLR+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_CLR];
   always_comb begin : s_data_r169_poisoncfg_combo_PROC
      s_data_r169_poisoncfg = {REG_WIDTH {1'b0}};
      s_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_SLVERR_EN] = reg_ddrc_wr_poison_slverr_en_pclk;
      s_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_EN] = reg_ddrc_wr_poison_intr_en_pclk;
      s_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_SLVERR_EN] = reg_ddrc_rd_poison_slverr_en_pclk;
      s_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_EN] = reg_ddrc_rd_poison_intr_en_pclk;
   end
      assign reg_ddrc_wr_poison_slverr_en = d_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_SLVERR_EN];
      assign reg_ddrc_wr_poison_intr_en = d_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_EN];
      assign reg_ddrc_rd_poison_slverr_en = d_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_SLVERR_EN];
      assign reg_ddrc_rd_poison_intr_en = d_data_r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_EN];
   //------------------------
   // Register UMCTL2_REGS.POISONSTAT
   //------------------------
   always_comb begin : r170_poisonstat_combo_PROC
      r170_poisonstat = {REG_WIDTH{1'b0}};
      r170_poisonstat[`UMCTL2_REG_OFFSET_POISONSTAT_WR_POISON_INTR_0+:`UMCTL2_REG_SIZE_POISONSTAT_WR_POISON_INTR_0] = ddrc_reg_wr_poison_intr_0_pclk;
      r170_poisonstat[`UMCTL2_REG_OFFSET_POISONSTAT_RD_POISON_INTR_0+:`UMCTL2_REG_SIZE_POISONSTAT_RD_POISON_INTR_0] = ddrc_reg_rd_poison_intr_0_pclk;
   end
   //------------------------
   // Register UMCTL2_MP.PSTAT
   //------------------------
   always_comb begin : r193_pstat_combo_PROC
      r193_pstat = {REG_WIDTH{1'b0}};
      r193_pstat[`UMCTL2_REG_OFFSET_PSTAT_RD_PORT_BUSY_0+:`UMCTL2_REG_SIZE_PSTAT_RD_PORT_BUSY_0] = arb_reg_rd_port_busy_0_pclk;
      r193_pstat[`UMCTL2_REG_OFFSET_PSTAT_WR_PORT_BUSY_0+:`UMCTL2_REG_SIZE_PSTAT_WR_PORT_BUSY_0] = arb_reg_wr_port_busy_0_pclk;
   end
   //------------------------
   // Register UMCTL2_MP.PCCFG
   //------------------------
   assign reg_arb_go2critical_en = r194_pccfg[`UMCTL2_REG_OFFSET_PCCFG_GO2CRITICAL_EN+:`UMCTL2_REG_SIZE_PCCFG_GO2CRITICAL_EN];
   assign reg_arb_pagematch_limit = r194_pccfg[`UMCTL2_REG_OFFSET_PCCFG_PAGEMATCH_LIMIT+:`UMCTL2_REG_SIZE_PCCFG_PAGEMATCH_LIMIT];
   assign reg_arb_bl_exp_mode = r194_pccfg[`UMCTL2_REG_OFFSET_PCCFG_BL_EXP_MODE+:`UMCTL2_REG_SIZE_PCCFG_BL_EXP_MODE];
   //------------------------
   // Register UMCTL2_MP.PCFGR_0
   //------------------------
   assign reg_arb_rd_port_priority_0[(`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0) -1:0] = r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PRIORITY_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0];
   assign reg_arb_rd_port_aging_en_0 = r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_AGING_EN_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_AGING_EN_0];
   assign reg_arb_rd_port_urgent_en_0 = r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_URGENT_EN_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_URGENT_EN_0];
   assign reg_arb_rd_port_pagematch_en_0 = r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PAGEMATCH_EN_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PAGEMATCH_EN_0];
   //------------------------
   // Register UMCTL2_MP.PCFGW_0
   //------------------------
   assign reg_arb_wr_port_priority_0[(`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0) -1:0] = r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PRIORITY_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0];
   assign reg_arb_wr_port_aging_en_0 = r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_AGING_EN_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_AGING_EN_0];
   assign reg_arb_wr_port_urgent_en_0 = r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_URGENT_EN_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_URGENT_EN_0];
   assign reg_arb_wr_port_pagematch_en_0 = r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PAGEMATCH_EN_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PAGEMATCH_EN_0];
   //------------------------
   // Register UMCTL2_MP.PCTRL_0
   //------------------------
   assign reg_arb_port_en_0_pclk = r230_pctrl_0[`UMCTL2_REG_OFFSET_PCTRL_0_PORT_EN_0+:`UMCTL2_REG_SIZE_PCTRL_0_PORT_EN_0];
   always_comb begin : s_data_r230_pctrl_0_combo_PROC
      s_data_r230_pctrl_0 = {REG_WIDTH {1'b0}};
      s_data_r230_pctrl_0[`UMCTL2_REG_OFFSET_PCTRL_0_PORT_EN_0+:`UMCTL2_REG_SIZE_PCTRL_0_PORT_EN_0] = reg_arb_port_en_0_pclk;
   end
      assign reg_arba0_port_en_0 = d_data_r230_pctrl_0[`UMCTL2_REG_OFFSET_PCTRL_0_PORT_EN_0+:`UMCTL2_REG_SIZE_PCTRL_0_PORT_EN_0];
   //------------------------
   // Register UMCTL2_MP.PCFGQOS0_0
   //------------------------
   assign reg_arba0_rqos_map_level1_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0) -1:0] = r231_pcfgqos0_0[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_LEVEL1_0+:`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0];
   assign reg_arba0_rqos_map_region0_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0) -1:0] = r231_pcfgqos0_0[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION0_0+:`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0];
   assign reg_arba0_rqos_map_region1_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0) -1:0] = r231_pcfgqos0_0[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION1_0+:`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0];
   //------------------------
   // Register UMCTL2_MP.PCFGQOS1_0
   //------------------------
   assign reg_arb_rqos_map_timeoutb_0[(`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0) -1:0] = r232_pcfgqos1_0[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0+:`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0];
   assign reg_arb_rqos_map_timeoutr_0[(`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0) -1:0] = r232_pcfgqos1_0[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0+:`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0];
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS0_0
   //------------------------
   assign reg_arba0_wqos_map_level1_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0) -1:0] = r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0];
   assign reg_arba0_wqos_map_level2_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0) -1:0] = r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0];
   assign reg_arba0_wqos_map_region0_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0) -1:0] = r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION0_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0];
   assign reg_arba0_wqos_map_region1_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0) -1:0] = r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION1_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0];
   assign reg_arba0_wqos_map_region2_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0) -1:0] = r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION2_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0];
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS1_0
   //------------------------
   assign reg_arb_wqos_map_timeout1_0[(`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0) -1:0] = r234_pcfgwqos1_0[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0+:`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0];
   assign reg_arb_wqos_map_timeout2_0[(`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0) -1:0] = r234_pcfgwqos1_0[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0+:`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0];
   //------------------------
   // Register UMCTL2_MP.UMCTL2_VER_NUMBER
   //------------------------
   always_comb begin : r856_umctl2_ver_number_combo_PROC
      r856_umctl2_ver_number = {REG_WIDTH{1'b0}};
      r856_umctl2_ver_number[`UMCTL2_REG_OFFSET_UMCTL2_VER_NUMBER_VER_NUMBER+:`UMCTL2_REG_SIZE_UMCTL2_VER_NUMBER_VER_NUMBER] = arb_reg_ver_number[(`UMCTL2_REG_SIZE_UMCTL2_VER_NUMBER_VER_NUMBER) -1:0];
   end
   //------------------------
   // Register UMCTL2_MP.UMCTL2_VER_TYPE
   //------------------------
   always_comb begin : r857_umctl2_ver_type_combo_PROC
      r857_umctl2_ver_type = {REG_WIDTH{1'b0}};
      r857_umctl2_ver_type[`UMCTL2_REG_OFFSET_UMCTL2_VER_TYPE_VER_TYPE+:`UMCTL2_REG_SIZE_UMCTL2_VER_TYPE_VER_TYPE] = arb_reg_ver_type[(`UMCTL2_REG_SIZE_UMCTL2_VER_TYPE_VER_TYPE) -1:0];
   end




   assign dfi_alert_err_intr                  = ddrc_reg_dfi_alert_err_int_pclk & reg_ddrc_dfi_alert_err_int_en_pclk;   




   //----------------------------------------------
   // Clock domain crossing: STATIC RO registers
   // Resample combo before sampling in pclk
   //----------------------------------------------
   always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin: sample_cclk_ro_static_PROC
      if (!core_ddrc_rstn) begin
         ddrc_reg_selfref_type_cclk <= 'h0;
         ddrc_reg_selfref_cam_not_empty_cclk <= 'h0;
         ddrc_reg_mr_wr_busy_cclk <= 'h0;
         ddrc_reg_pda_done_cclk <= 'h0;
         ddrc_reg_dfi_init_complete_cclk <= 'h0;
         ddrc_reg_dfi_lp_ack_cclk <= 'h0;
         ddrc_reg_dbg_rd_q_empty_cclk <= 'h0;
         ddrc_reg_dbg_wr_q_empty_cclk <= 'h0;
         ddrc_reg_rd_data_pipeline_empty_cclk <= 'h0;
         ddrc_reg_wr_data_pipeline_empty_cclk <= 'h0;
         ddrc_reg_dbg_stall_wr_cclk <= 'h0;
         ddrc_reg_dbg_stall_rd_cclk <= 'h0;

      end else begin
         ddrc_reg_selfref_type_cclk <= ddrc_reg_selfref_type;
         ddrc_reg_selfref_cam_not_empty_cclk <= ddrc_reg_selfref_cam_not_empty;
         ddrc_reg_mr_wr_busy_cclk <= ddrc_reg_mr_wr_busy;
         ddrc_reg_pda_done_cclk <= ddrc_reg_pda_done;
         ddrc_reg_dfi_init_complete_cclk <= ddrc_reg_dfi_init_complete;
         ddrc_reg_dfi_lp_ack_cclk <= ddrc_reg_dfi_lp_ack;
         ddrc_reg_dbg_rd_q_empty_cclk <= ddrc_reg_dbg_rd_q_empty;
         ddrc_reg_dbg_wr_q_empty_cclk <= ddrc_reg_dbg_wr_q_empty;
         ddrc_reg_rd_data_pipeline_empty_cclk <= ddrc_reg_rd_data_pipeline_empty;
         ddrc_reg_wr_data_pipeline_empty_cclk <= ddrc_reg_wr_data_pipeline_empty;
         ddrc_reg_dbg_stall_wr_cclk <= ddrc_reg_dbg_stall_wr;
         ddrc_reg_dbg_stall_rd_cclk <= ddrc_reg_dbg_stall_rd;

      end   
   end

   //-------------------------------------------------
   // Clock domain crossing: DYNAMIC registers
   //-------------------------------------------------   
   // Datasync CDC for register UMCTL2_REGS mstr
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_mstr_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[0] & write_en) | fwd_reset_val),
       .s_data          (s_data_r0_mstr),
       .d_data          (d_data_r0_mstr),
       .s_ack           (r0_mstr_ack_pclk));
   wire s_ack_umctl2_regs_stat_unconnected;
   // Datasync CDC for register UMCTL2_REGS stat
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_umctl2_regs_stat_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (r1_stat_cclk),
       .s_send          (1'b0),
       .d_data          (r1_stat),
       .s_ack           (s_ack_umctl2_regs_stat_unconnected));

   // Pulse synch for field reg_ddrc_mr_wr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_mr_wr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_mr_wr_pclk),
       .ack_s           (reg_ddrc_mr_wr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_mr_wr));
   // Datasync CDC for register UMCTL2_REGS mrctrl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_mrctrl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[3] & write_en) | fwd_reset_val),
       .s_data          (s_data_r4_mrctrl0),
       .d_data          (d_data_r4_mrctrl0),
       .s_ack           (r4_mrctrl0_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS mrctrl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_mrctrl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[4] & write_en) | fwd_reset_val),
       .s_data          (s_data_r5_mrctrl1),
       .d_data          (d_data_r5_mrctrl1),
       .s_ack           (r5_mrctrl1_ack_pclk));

   // Single bit CDC for field ddrc_reg_mr_wr_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_mr_wr_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_mr_wr_busy_cclk),
       .data_d          (ddrc_reg_mr_wr_busy_pclk));

   wire ack_s_ddrc_reg_mr_wr_busy_unconnected;
   // Pulse synch for field ddrc_reg_mr_wr_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_mr_wr_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_mr_wr_busy_cclk),
       .ack_s           (ack_s_ddrc_reg_mr_wr_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_mr_wr_busy_pulse_pclk));

   // Single bit CDC for field ddrc_reg_pda_done
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_pda_done_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_pda_done_cclk),
       .data_d          (ddrc_reg_pda_done_pclk));
   // Datasync CDC for register UMCTL2_REGS mrctrl2
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_mrctrl2_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[5] & write_en) | fwd_reset_val),
       .s_data          (s_data_r7_mrctrl2),
       .d_data          (d_data_r7_mrctrl2),
       .s_ack           (r7_mrctrl2_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS pwrctl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_pwrctl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[10] & write_en) | fwd_reset_val),
       .s_data          (s_data_r12_pwrctl),
       .d_data          (d_data_r12_pwrctl),
       .s_ack           (r12_pwrctl_ack_pclk));





   // Datasync CDC for register UMCTL2_REGS rfshctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_rfshctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[14] & write_en) | fwd_reset_val),
       .s_data          (s_data_r17_rfshctl0),
       .d_data          (d_data_r17_rfshctl0),
       .s_ack           (r17_rfshctl0_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS rfshctl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_rfshctl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[15] & write_en) | fwd_reset_val),
       .s_data          (s_data_r18_rfshctl1),
       .d_data          (d_data_r18_rfshctl1),
       .s_ack           (r18_rfshctl1_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS rfshctl3
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_rfshctl3_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[18] & write_en) | fwd_reset_val),
       .s_data          (s_data_r21_rfshctl3),
       .d_data          (d_data_r21_rfshctl3),
       .s_ack           (r21_rfshctl3_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS rfshtmg
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_rfshtmg_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[19] & write_en) | fwd_reset_val),
       .s_data          (s_data_r22_rfshtmg),
       .d_data          (d_data_r22_rfshtmg),
       .s_ack           (r22_rfshtmg_ack_pclk));



































   // Pulse synch for field reg_ddrc_dfi_alert_err_int_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_dfi_alert_err_int_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_dfi_alert_err_int_clr_pclk),
       .ack_s           (reg_ddrc_dfi_alert_err_int_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_dfi_alert_err_int_clr));

   // Pulse synch for field reg_ddrc_dfi_alert_err_cnt_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_dfi_alert_err_cnt_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_dfi_alert_err_cnt_clr_pclk),
       .ack_s           (reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_dfi_alert_err_cnt_clr));


   // Datasync CDC for register UMCTL2_REGS crcparctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_crcparctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[26] & write_en) | fwd_reset_val),
       .s_data          (s_data_r44_crcparctl0),
       .d_data          (d_data_r44_crcparctl0),
       .s_ack           (r44_crcparctl0_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS crcparctl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_crcparctl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[27] & write_en) | fwd_reset_val),
       .s_data          (s_data_r45_crcparctl1),
       .d_data          (d_data_r45_crcparctl1),
       .s_ack           (r45_crcparctl1_ack_pclk));
   wire s_ack_umctl2_regs_crcparstat_unconnected;
   // Datasync CDC for register UMCTL2_REGS crcparstat
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_umctl2_regs_crcparstat_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (r47_crcparstat_cclk),
       .s_send          (1'b0),
       .d_data          (r47_crcparstat),
       .s_ack           (s_ack_umctl2_regs_crcparstat_unconnected));
   // Datasync CDC for register UMCTL2_REGS init0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_init0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[29] & write_en) | fwd_reset_val),
       .s_data          (s_data_r48_init0),
       .d_data          (d_data_r48_init0),
       .s_ack           (r48_init0_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS init4
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_init4_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[33] & write_en) | fwd_reset_val),
       .s_data          (s_data_r52_init4),
       .d_data          (d_data_r52_init4),
       .s_ack           (r52_init4_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dimmctl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dimmctl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[37] & write_en) | fwd_reset_val),
       .s_data          (s_data_r56_dimmctl),
       .d_data          (d_data_r56_dimmctl),
       .s_ack           (r56_dimmctl_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dramtmg10
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dramtmg10_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[50] & write_en) | fwd_reset_val),
       .s_data          (s_data_r69_dramtmg10),
       .d_data          (d_data_r69_dramtmg10),
       .s_ack           (r69_dramtmg10_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS zqctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_zqctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[63] & write_en) | fwd_reset_val),
       .s_data          (s_data_r82_zqctl0),
       .d_data          (d_data_r82_zqctl0),
       .s_ack           (r82_zqctl0_ack_pclk));


   // Datasync CDC for register UMCTL2_REGS dfitmg1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dfitmg1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[67] & write_en) | fwd_reset_val),
       .s_data          (s_data_r87_dfitmg1),
       .d_data          (d_data_r87_dfitmg1),
       .s_ack           (r87_dfitmg1_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dfilpcfg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dfilpcfg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[68] & write_en) | fwd_reset_val),
       .s_data          (s_data_r88_dfilpcfg0),
       .d_data          (d_data_r88_dfilpcfg0),
       .s_ack           (r88_dfilpcfg0_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dfimisc
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dfimisc_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[74] & write_en) | fwd_reset_val),
       .s_data          (s_data_r94_dfimisc),
       .d_data          (d_data_r94_dfimisc),
       .s_ack           (r94_dfimisc_ack_pclk));

   // Single bit CDC for field ddrc_reg_dfi_init_complete
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi_init_complete_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi_init_complete_cclk),
       .data_d          (ddrc_reg_dfi_init_complete_pclk));

   // Single bit CDC for field ddrc_reg_dfi_lp_ack
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi_lp_ack_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi_lp_ack_cclk),
       .data_d          (ddrc_reg_dfi_lp_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dbictl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dbictl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[77] & write_en) | fwd_reset_val),
       .s_data          (s_data_r98_dbictl),
       .d_data          (d_data_r98_dbictl),
       .s_ack           (r98_dbictl_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dfiphymstr
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dfiphymstr_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[78] & write_en) | fwd_reset_val),
       .s_data          (s_data_r99_dfiphymstr),
       .d_data          (d_data_r99_dfiphymstr),
       .s_ack           (r99_dfiphymstr_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS addrmap6
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_addrmap6_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[85] & write_en) | fwd_reset_val),
       .s_data          (s_data_r106_addrmap6),
       .d_data          (d_data_r106_addrmap6),
       .s_ack           (r106_addrmap6_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS addrmap7
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_addrmap7_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[86] & write_en) | fwd_reset_val),
       .s_data          (s_data_r107_addrmap7),
       .d_data          (d_data_r107_addrmap7),
       .s_ack           (r107_addrmap7_ack_pclk));
   // Datasync CDC for register UMCTL2_REGS dbg1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dbg1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[125] & write_en) | fwd_reset_val),
       .s_data          (s_data_r146_dbg1),
       .d_data          (d_data_r146_dbg1),
       .s_ack           (r146_dbg1_ack_pclk));

   wire s_ack_ddrc_reg_dbg_hpr_q_depth_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_hpr_q_depth
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`UMCTL2_REG_SIZE_DBGCAM_DBG_HPR_Q_DEPTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_hpr_q_depth_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_hpr_q_depth),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_hpr_q_depth_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_hpr_q_depth_unconnected));

   wire s_ack_ddrc_reg_dbg_lpr_q_depth_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_lpr_q_depth
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`UMCTL2_REG_SIZE_DBGCAM_DBG_LPR_Q_DEPTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_lpr_q_depth_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_lpr_q_depth),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_lpr_q_depth_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_lpr_q_depth_unconnected));

   wire s_ack_ddrc_reg_dbg_w_q_depth_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_w_q_depth
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`UMCTL2_REG_SIZE_DBGCAM_DBG_W_Q_DEPTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_w_q_depth_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_w_q_depth),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_w_q_depth_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_w_q_depth_unconnected));


   // Single bit CDC for field ddrc_reg_dbg_rd_q_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_rd_q_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_rd_q_empty_cclk),
       .data_d          (ddrc_reg_dbg_rd_q_empty_pclk));

   // Single bit CDC for field ddrc_reg_dbg_wr_q_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_wr_q_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_wr_q_empty_cclk),
       .data_d          (ddrc_reg_dbg_wr_q_empty_pclk));

   // Single bit CDC for field ddrc_reg_rd_data_pipeline_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rd_data_pipeline_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rd_data_pipeline_empty_cclk),
       .data_d          (ddrc_reg_rd_data_pipeline_empty_pclk));

   // Single bit CDC for field ddrc_reg_wr_data_pipeline_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_wr_data_pipeline_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_wr_data_pipeline_empty_cclk),
       .data_d          (ddrc_reg_wr_data_pipeline_empty_pclk));

   // Single bit CDC for field ddrc_reg_dbg_stall_wr
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_stall_wr_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_stall_wr_cclk),
       .data_d          (ddrc_reg_dbg_stall_wr_pclk));

   // Single bit CDC for field ddrc_reg_dbg_stall_rd
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_stall_rd_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_stall_rd_cclk),
       .data_d          (ddrc_reg_dbg_stall_rd_pclk));

   // Pulse synch for field reg_ddrc_rank0_refresh
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_rank0_refresh_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_rank0_refresh_pclk),
       .ack_s           (reg_ddrc_rank0_refresh_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_rank0_refresh));

   // Pulse synch for field reg_ddrc_rank1_refresh
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_rank1_refresh_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_rank1_refresh_pclk),
       .ack_s           (reg_ddrc_rank1_refresh_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_rank1_refresh));



   // Pulse synch for field reg_ddrc_zq_calib_short
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_zq_calib_short_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_zq_calib_short_pclk),
       .ack_s           (reg_ddrc_zq_calib_short_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_zq_calib_short));

   // Pulse synch for field reg_ddrc_ctrlupd
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_ctrlupd_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_ctrlupd_pclk),
       .ack_s           (reg_ddrc_ctrlupd_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_ctrlupd));












   // Datasync CDC for register UMCTL2_REGS dbgcmd
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_dbgcmd_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[126] & write_en) | fwd_reset_val),
       .s_data          (s_data_r148_dbgcmd),
       .d_data          (d_data_r148_dbgcmd),
       .s_ack           (r148_dbgcmd_ack_pclk));

   // Single bit CDC for field ddrc_reg_rank0_refresh_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rank0_refresh_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rank0_refresh_busy),
       .data_d          (ddrc_reg_rank0_refresh_busy_pclk));

   wire ack_s_ddrc_reg_rank0_refresh_busy_unconnected;
   // Pulse synch for field ddrc_reg_rank0_refresh_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_rank0_refresh_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_rank0_refresh_busy),
       .ack_s           (ack_s_ddrc_reg_rank0_refresh_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_rank0_refresh_busy_pulse_pclk));

   // Single bit CDC for field ddrc_reg_rank1_refresh_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rank1_refresh_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rank1_refresh_busy),
       .data_d          (ddrc_reg_rank1_refresh_busy_pclk));

   wire ack_s_ddrc_reg_rank1_refresh_busy_unconnected;
   // Pulse synch for field ddrc_reg_rank1_refresh_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_rank1_refresh_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_rank1_refresh_busy),
       .ack_s           (ack_s_ddrc_reg_rank1_refresh_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_rank1_refresh_busy_pulse_pclk));



   // Single bit CDC for field ddrc_reg_zq_calib_short_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_zq_calib_short_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_zq_calib_short_busy),
       .data_d          (ddrc_reg_zq_calib_short_busy_pclk));

   wire ack_s_ddrc_reg_zq_calib_short_busy_unconnected;
   // Pulse synch for field ddrc_reg_zq_calib_short_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_zq_calib_short_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_zq_calib_short_busy),
       .ack_s           (ack_s_ddrc_reg_zq_calib_short_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_zq_calib_short_busy_pulse_pclk));

   // Single bit CDC for field ddrc_reg_ctrlupd_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_ctrlupd_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_ctrlupd_busy),
       .data_d          (ddrc_reg_ctrlupd_busy_pclk));

   wire ack_s_ddrc_reg_ctrlupd_busy_unconnected;
   // Pulse synch for field ddrc_reg_ctrlupd_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_ctrlupd_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_ctrlupd_busy),
       .ack_s           (ack_s_ddrc_reg_ctrlupd_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_ctrlupd_busy_pulse_pclk));


























   // Pulse synch for field reg_ddrc_wr_poison_intr_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_wr_poison_intr_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_wr_poison_intr_clr_pclk),
       .ack_s           (reg_ddrc_wr_poison_intr_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_wr_poison_intr_clr));

   // Pulse synch for field reg_ddrc_rd_poison_intr_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_rd_poison_intr_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_rd_poison_intr_clr_pclk),
       .ack_s           (reg_ddrc_rd_poison_intr_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_rd_poison_intr_clr));
   // Datasync CDC for register UMCTL2_REGS poisoncfg
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_regs_poisoncfg_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[133] & write_en) | fwd_reset_val),
       .s_data          (s_data_r169_poisoncfg),
       .d_data          (d_data_r169_poisoncfg),
       .s_ack           (r169_poisoncfg_ack_pclk));

   // Single bit CDC for field ddrc_reg_wr_poison_intr_0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_wr_poison_intr_0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_wr_poison_intr_0),
       .data_d          (ddrc_reg_wr_poison_intr_0_pclk));
















   // Single bit CDC for field ddrc_reg_rd_poison_intr_0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rd_poison_intr_0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rd_poison_intr_0),
       .data_d          (ddrc_reg_rd_poison_intr_0_pclk));






































   // Single bit CDC for field arb_reg_rd_port_busy_0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_arb_reg_rd_port_busy_0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (arb_reg_rd_port_busy_0),
       .data_d          (arb_reg_rd_port_busy_0_pclk));
















   // Single bit CDC for field arb_reg_wr_port_busy_0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_arb_reg_wr_port_busy_0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (arb_reg_wr_port_busy_0),
       .data_d          (arb_reg_wr_port_busy_0_pclk));















   // Datasync CDC for register UMCTL2_MP pctrl_0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_umctl2_mp_pctrl_0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (aclk_0),
       .d_rst_n         (sync_aresetn_0),
       .s_send          ((rwselect[184] & write_en) | fwd_reset_val),
       .s_data          (s_data_r230_pctrl_0),
       .d_data          (d_data_r230_pctrl_0),
       .s_ack           (r230_pctrl_0_ack_pclk));




























































































































   //------------------------------------------------
   // instantiate ecc_poison_reg (indirect write registers)
   //------------------------------------------------


   //-----------------------------------------
   // Register Parity checking of *_busy logic
   //-----------------------------------------


endmodule
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W528
