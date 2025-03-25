//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_apb_slvtop.sv#16 $
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

`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_apb_slvtop
  #(parameter APB_AW  = `UMCTL2_APB_AW,
    parameter APB_DW  = `UMCTL2_APB_DW,
    parameter BCM_F_SYNC_TYPE_C2P = 2,
    parameter BCM_F_SYNC_TYPE_P2C = 2,
    parameter BCM_R_SYNC_TYPE_C2P = 2,
    parameter BCM_R_SYNC_TYPE_P2C = 2,
    parameter REG_OUTPUTS_C2P = 1,
    parameter REG_OUTPUTS_P2C = 1,
    parameter BCM_VERIF_EN    = 1,
    parameter N_REGS  = `UMCTL2_REG_N_REGS,
    parameter RW_REGS = `UMCTL2_REG_RW_REGS,
    parameter MAX_ADDR = `UMCTL2_REG_UMCTL2_MAX_ADDR/4
    )
   (
    //---APB MASTER INTERFACE---//
    input               pclk,    
    input               presetn,
    input [APB_AW-1:2]  paddr,
    input [APB_DW-1:0]  pwdata,
    input               pwrite,
    input               psel,
    input               penable,
    output              pready,
    output [APB_DW-1:0] prdata,
    output              pslverr   
    //--- uMCTL2 INTERFACE ---//
    ,input              core_ddrc_core_clk
    ,input              sync_core_ddrc_rstn
    ,input              core_ddrc_rstn
    ,input               aclk_0
    ,input               sync_aresetn_0
//     ,input               aresetn_0
    ,input               static_wr_en_core_ddrc_core_clk
    ,input               quasi_dyn_wr_en_core_ddrc_core_clk
//`ifdef UMCTL2_OCECC_EN_1    
//    ,input               quasi_dyn_wr_en_pclk
//`endif //UMCTL2_OCPAR_OR_OCECC_EN_1
    ,input               static_wr_en_aclk_0
    ,input               quasi_dyn_wr_en_aclk_0


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
   ,input [((`MEMC_MOBILE_OR_LPDDR2_OR_DDR4_EN==1) ? 3 : 2)-1:0] ddrc_reg_operating_mode // @core_ddrc_core_clk
   ,input [1:0] ddrc_reg_selfref_type // @core_ddrc_core_clk
   ,input ddrc_reg_selfref_cam_not_empty // @core_ddrc_core_clk
   ,output reg_ddrc_mr_type // @core_ddrc_core_clk
   ,output reg_ddrc_mpr_en // @core_ddrc_core_clk
   ,output reg_ddrc_pda_en // @core_ddrc_core_clk
   ,output reg_ddrc_sw_init_int // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_mr_rank // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_mr_addr // @core_ddrc_core_clk
   ,output reg_ddrc_pba_mode // @core_ddrc_core_clk
   ,output reg_ddrc_mr_wr // @core_ddrc_core_clk
   ,output [(`MEMC_PAGE_BITS)-1:0] reg_ddrc_mr_data // @core_ddrc_core_clk
   ,input ddrc_reg_mr_wr_busy // @core_ddrc_core_clk
   ,input ddrc_reg_pda_done // @core_ddrc_core_clk
   ,output [31:0] reg_ddrc_mr_device_sel // @core_ddrc_core_clk
   ,output reg_ddrc_selfref_en // @core_ddrc_core_clk
   ,output reg_ddrc_powerdown_en // @core_ddrc_core_clk
   ,output reg_ddrc_en_dfi_dram_clk_disable // @core_ddrc_core_clk
   ,output reg_ddrc_mpsm_en // @core_ddrc_core_clk
   ,output reg_ddrc_selfref_sw // @core_ddrc_core_clk
   ,output reg_ddrc_dis_cam_drain_selfref // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_powerdown_to_x32 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_selfref_to_x32 // @core_ddrc_core_clk
   ,output reg_ddrc_hw_lp_en // @core_ddrc_core_clk
   ,output reg_ddrc_hw_lp_exit_idle_en // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_hw_lp_idle_x32 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_refresh_burst // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_refresh_to_x1_x32 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_refresh_margin // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_refresh_timer0_start_value_x32 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_refresh_timer1_start_value_x32 // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_refresh_update_level // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_refresh_mode // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_rfc_min // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_rfc_nom_x1_x32 // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_alert_err_int_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_alert_err_int_clr // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_alert_err_cnt_clr // @core_ddrc_core_clk
   ,output reg_ddrc_parity_enable // @core_ddrc_core_clk
   ,output reg_ddrc_crc_enable // @core_ddrc_core_clk
   ,output reg_ddrc_crc_inc_dm // @core_ddrc_core_clk
   ,output reg_ddrc_caparity_disable_before_sr // @core_ddrc_core_clk
   ,input [15:0] ddrc_reg_dfi_alert_err_cnt // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_alert_err_int // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_pre_cke_x1024 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_post_cke_x1024 // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_skip_dram_init // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_pre_ocd_x32 // @core_ddrc_core_clk
   ,output [8:0] reg_ddrc_dram_rstn_x1024 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr3 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr2 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dev_zqinit_x32 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr5 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr4 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr6 // @core_ddrc_core_clk
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
   ,output [3:0] reg_ddrc_max_rank_rd // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_diff_rank_rd_gap // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_diff_rank_wr_gap // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_max_rank_wr // @core_ddrc_core_clk
   ,output reg_ddrc_diff_rank_rd_gap_msb // @core_ddrc_core_clk
   ,output reg_ddrc_diff_rank_wr_gap_msb // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_ras_min // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_ras_max // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_faw // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_wr2pre // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_rc // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_rd2pre // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_xp // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_wr2rd // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_rd2wr // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_read_latency // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_write_latency // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_mod // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_mrd // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_rp // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_rrd // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_ccd // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_rcd // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_cke // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_ckesr // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_cksre // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_cksrx // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_x32 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_dll_x32 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_abort_x32 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_xs_fast_x32 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_wr2rd_s // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_rrd_s // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_t_ccd_s // @core_ddrc_core_clk
   ,output reg_ddrc_ddr4_wr_preamble // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_t_gear_hold // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_t_gear_setup // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_cmd_gear // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_sync_gear // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_ckmpe // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_t_mpx_s // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_mpx_lh // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_post_mpsm_gap_x32 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_mrd_pda // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_wr_mpr // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_stab_x32 // @core_ddrc_core_clk
   ,output reg_ddrc_en_dfi_lp_t_stab // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_zq_short_nop // @core_ddrc_core_clk
   ,output [10:0] reg_ddrc_t_zq_long_nop // @core_ddrc_core_clk
   ,output reg_ddrc_dis_mpsmx_zqcl // @core_ddrc_core_clk
   ,output reg_ddrc_zq_resistor_shared // @core_ddrc_core_clk
   ,output reg_ddrc_dis_srx_zqcl // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_zq // @core_ddrc_core_clk
   ,output [19:0] reg_ddrc_t_zq_short_interval_x1024 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_tphy_wrlat // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_tphy_wrdata // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_wrdata_use_dfi_phy_clk // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_dfi_t_rddata_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_rddata_use_dfi_phy_clk // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_ctrl_delay // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_enable // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_disable // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_wrdata_delay // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dfi_t_parin_lat // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_t_cmd_lat // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_pd // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_lp_wakeup_pd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_sr // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_lp_wakeup_sr // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_tlp_resp // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_mpsm // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_dfi_lp_wakeup_mpsm // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_min // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_max // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd_pre_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_max_x1024 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_min_x1024 // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_phyupd_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_init_complete_en // @core_ddrc_core_clk
   ,output reg_ddrc_phy_dbi_mode // @core_ddrc_core_clk
   ,output reg_ddrc_ctl_idle_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_init_start // @core_ddrc_core_clk
   ,output reg_ddrc_dis_dyn_adr_tri // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_frequency // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_geardown_delay // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_init_complete // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_lp_ack // @core_ddrc_core_clk
   ,output reg_ddrc_dm_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_dbi_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_dbi_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_phymstr_en // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_cs_bit0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b1 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b2 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b2 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b3 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b4 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b5 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b6 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b7 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b8 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b9 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b10 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b11 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b1 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b2_10 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b11 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b12 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b13 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b14 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b15 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b16 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b17 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bg_b0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bg_b1 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b2 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b3 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b4 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b5 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b6 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b7 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b8 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b9 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_row_b10 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_rd_odt_delay // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_rd_odt_hold // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_wr_odt_delay // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_wr_odt_hold // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_wr_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_rd_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank1_wr_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank1_rd_odt // @core_ddrc_core_clk
   ,output reg_ddrc_prefer_write // @core_ddrc_core_clk
   ,output reg_ddrc_pageclose // @core_ddrc_core_clk
   ,output reg_ddrc_autopre_rmw // @core_ddrc_core_clk
   ,output [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_lpr_num_entries // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_go2critical_hysteresis // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_rdwr_idle_gap // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_pageclose_timer // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_hpr_max_starve // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_hpr_xact_run_length // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_lpr_max_starve // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_lpr_xact_run_length // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_w_max_starve // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_w_xact_run_length // @core_ddrc_core_clk
   ,output reg_ddrc_dis_wc // @core_ddrc_core_clk
   ,output reg_ddrc_dis_collision_page_opt // @core_ddrc_core_clk
   ,output reg_ddrc_dis_max_rank_rd_opt // @core_ddrc_core_clk
   ,output reg_ddrc_dis_max_rank_wr_opt // @core_ddrc_core_clk
   ,output reg_ddrc_dis_dq // @core_ddrc_core_clk
   ,output reg_ddrc_dis_hif // @core_ddrc_core_clk
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_hpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_lpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_WRCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_w_q_depth // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_rd_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_wr_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_rd_data_pipeline_empty // @core_ddrc_core_clk
   ,input ddrc_reg_wr_data_pipeline_empty // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_stall_wr // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_stall_rd // @core_ddrc_core_clk
   ,output reg_ddrc_rank0_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_rank1_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_zq_calib_short // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd // @core_ddrc_core_clk
   ,input ddrc_reg_rank0_refresh_busy // @core_ddrc_core_clk
   ,input ddrc_reg_rank1_refresh_busy // @core_ddrc_core_clk
   ,input ddrc_reg_zq_calib_short_busy // @core_ddrc_core_clk
   ,input ddrc_reg_ctrlupd_busy // @core_ddrc_core_clk
   ,output reg_ddrc_sw_done // @pclk
   ,input ddrc_reg_sw_done_ack // @core_ddrc_core_clk
   ,output reg_ddrc_sw_static_unlock // @pclk
   ,output reg_ddrc_wr_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_clr // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_clr // @core_ddrc_core_clk
   ,input ddrc_reg_wr_poison_intr_0 // @core_ddrc_core_clk
   ,input ddrc_reg_rd_poison_intr_0 // @core_ddrc_core_clk
   ,input arb_reg_rd_port_busy_0 // @aclk_0
   ,input arb_reg_wr_port_busy_0 // @aclk_0
   ,output reg_arb_go2critical_en // @core_ddrc_core_clk
   ,output reg_arb_pagematch_limit // @core_ddrc_core_clk
   ,output reg_arb_bl_exp_mode // @core_ddrc_core_clk
   ,output [9:0] reg_arb_rd_port_priority_0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_aging_en_0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_urgent_en_0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_pagematch_en_0 // @core_ddrc_core_clk
   ,output [9:0] reg_arb_wr_port_priority_0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_aging_en_0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_urgent_en_0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_pagematch_en_0 // @core_ddrc_core_clk
   ,output reg_arba0_port_en_0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_MLW)-1:0] reg_arba0_rqos_map_level1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region0_0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutb_0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutr_0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level2_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region0_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region1_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region2_0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout1_0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout2_0 // @core_ddrc_core_clk
   ,input [31:0] arb_reg_ver_number // @pclk
   ,input [31:0] arb_reg_ver_type // @pclk


    ,output              dfi_alert_err_intr
    );

   localparam REG_WIDTH = `UMCTL2_REG_REG_WIDTH;

   localparam N_APBFSMSTAT=
                           8;

   // No of bits in the one-hot addr
   localparam RWSELWIDTH = RW_REGS;
      
   wire [N_APBFSMSTAT-1:0] apb_slv_cs_unused;
   wire [N_APBFSMSTAT-1:0] apb_slv_ns;
   wire                    write_en_s0;
   wire                    recalc_parity;
   wire [RWSELWIDTH-1:0]   rwselect;
   wire                    fwd_reset_val;
   wire                    write_en_pulse;
   wire                    write_en;
   wire                    store_rqst;
   wire                    set_async_reg;
   wire                    ack_async_reg;
   
   wire [REG_WIDTH -1:0] r0_mstr;
   wire r0_mstr_ack_pclk;
   wire [REG_WIDTH -1:0] r1_stat;
   wire [REG_WIDTH -1:0] r4_mrctrl0;
   wire r4_mrctrl0_ack_pclk;
   wire reg_ddrc_mr_wr_ack_pclk;
   wire ff_mr_wr_saved;
   wire [REG_WIDTH -1:0] r5_mrctrl1;
   wire r5_mrctrl1_ack_pclk;
   wire [REG_WIDTH -1:0] r6_mrstat;
   wire ddrc_reg_mr_wr_busy_int;
   wire [REG_WIDTH -1:0] r7_mrctrl2;
   wire r7_mrctrl2_ack_pclk;
   wire [REG_WIDTH -1:0] r12_pwrctl;
   wire r12_pwrctl_ack_pclk;
   wire [REG_WIDTH -1:0] r13_pwrtmg;
   wire [REG_WIDTH -1:0] r14_hwlpctl;
   wire [REG_WIDTH -1:0] r17_rfshctl0;
   wire r17_rfshctl0_ack_pclk;
   wire [REG_WIDTH -1:0] r18_rfshctl1;
   wire r18_rfshctl1_ack_pclk;
   wire [REG_WIDTH -1:0] r21_rfshctl3;
   wire r21_rfshctl3_ack_pclk;
   wire [REG_WIDTH -1:0] r22_rfshtmg;
   wire r22_rfshtmg_ack_pclk;
   wire [REG_WIDTH -1:0] r44_crcparctl0;
   wire r44_crcparctl0_ack_pclk;
   wire reg_ddrc_dfi_alert_err_int_clr_ack_pclk;
   wire reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk;
   wire [REG_WIDTH -1:0] r45_crcparctl1;
   wire r45_crcparctl1_ack_pclk;
   wire [REG_WIDTH -1:0] r47_crcparstat;
   wire [REG_WIDTH -1:0] r48_init0;
   wire r48_init0_ack_pclk;
   wire [REG_WIDTH -1:0] r49_init1;
   wire [REG_WIDTH -1:0] r51_init3;
   wire [REG_WIDTH -1:0] r52_init4;
   wire r52_init4_ack_pclk;
   wire [REG_WIDTH -1:0] r53_init5;
   wire [REG_WIDTH -1:0] r54_init6;
   wire [REG_WIDTH -1:0] r55_init7;
   wire [REG_WIDTH -1:0] r56_dimmctl;
   wire r56_dimmctl_ack_pclk;
   wire [REG_WIDTH -1:0] r57_rankctl;
   wire [REG_WIDTH -1:0] r59_dramtmg0;
   wire [REG_WIDTH -1:0] r60_dramtmg1;
   wire [REG_WIDTH -1:0] r61_dramtmg2;
   wire [REG_WIDTH -1:0] r62_dramtmg3;
   wire [REG_WIDTH -1:0] r63_dramtmg4;
   wire [REG_WIDTH -1:0] r64_dramtmg5;
   wire [REG_WIDTH -1:0] r67_dramtmg8;
   wire [REG_WIDTH -1:0] r68_dramtmg9;
   wire [REG_WIDTH -1:0] r69_dramtmg10;
   wire r69_dramtmg10_ack_pclk;
   wire [REG_WIDTH -1:0] r70_dramtmg11;
   wire [REG_WIDTH -1:0] r71_dramtmg12;
   wire [REG_WIDTH -1:0] r74_dramtmg15;
   wire [REG_WIDTH -1:0] r82_zqctl0;
   wire r82_zqctl0_ack_pclk;
   wire [REG_WIDTH -1:0] r83_zqctl1;
   wire [REG_WIDTH -1:0] r86_dfitmg0;
   wire [REG_WIDTH -1:0] r87_dfitmg1;
   wire r87_dfitmg1_ack_pclk;
   wire [REG_WIDTH -1:0] r88_dfilpcfg0;
   wire r88_dfilpcfg0_ack_pclk;
   wire [REG_WIDTH -1:0] r89_dfilpcfg1;
   wire [REG_WIDTH -1:0] r90_dfiupd0;
   wire [REG_WIDTH -1:0] r91_dfiupd1;
   wire [REG_WIDTH -1:0] r92_dfiupd2;
   wire [REG_WIDTH -1:0] r94_dfimisc;
   wire r94_dfimisc_ack_pclk;
   wire [REG_WIDTH -1:0] r96_dfitmg3;
   wire [REG_WIDTH -1:0] r97_dfistat;
   wire [REG_WIDTH -1:0] r98_dbictl;
   wire r98_dbictl_ack_pclk;
   wire [REG_WIDTH -1:0] r99_dfiphymstr;
   wire r99_dfiphymstr_ack_pclk;
   wire [REG_WIDTH -1:0] r100_addrmap0;
   wire [REG_WIDTH -1:0] r101_addrmap1;
   wire [REG_WIDTH -1:0] r102_addrmap2;
   wire [REG_WIDTH -1:0] r103_addrmap3;
   wire [REG_WIDTH -1:0] r104_addrmap4;
   wire [REG_WIDTH -1:0] r105_addrmap5;
   wire [REG_WIDTH -1:0] r106_addrmap6;
   wire r106_addrmap6_ack_pclk;
   wire [REG_WIDTH -1:0] r107_addrmap7;
   wire r107_addrmap7_ack_pclk;
   wire [REG_WIDTH -1:0] r108_addrmap8;
   wire [REG_WIDTH -1:0] r109_addrmap9;
   wire [REG_WIDTH -1:0] r110_addrmap10;
   wire [REG_WIDTH -1:0] r111_addrmap11;
   wire [REG_WIDTH -1:0] r113_odtcfg;
   wire [REG_WIDTH -1:0] r114_odtmap;
   wire [REG_WIDTH -1:0] r115_sched;
   wire [REG_WIDTH -1:0] r116_sched1;
   wire [REG_WIDTH -1:0] r118_perfhpr1;
   wire [REG_WIDTH -1:0] r119_perflpr1;
   wire [REG_WIDTH -1:0] r120_perfwr1;
   wire [REG_WIDTH -1:0] r145_dbg0;
   wire [REG_WIDTH -1:0] r146_dbg1;
   wire r146_dbg1_ack_pclk;
   wire [REG_WIDTH -1:0] r147_dbgcam;
   wire [REG_WIDTH -1:0] r148_dbgcmd;
   wire r148_dbgcmd_ack_pclk;
   wire reg_ddrc_rank0_refresh_ack_pclk;
   wire ff_rank0_refresh_saved;
   wire reg_ddrc_rank1_refresh_ack_pclk;
   wire ff_rank1_refresh_saved;
   wire reg_ddrc_zq_calib_short_ack_pclk;
   wire ff_zq_calib_short_saved;
   wire reg_ddrc_ctrlupd_ack_pclk;
   wire ff_ctrlupd_saved;
   wire [REG_WIDTH -1:0] r149_dbgstat;
   wire ddrc_reg_rank0_refresh_busy_int;
   wire ddrc_reg_rank1_refresh_busy_int;
   wire ddrc_reg_zq_calib_short_busy_int;
   wire ddrc_reg_ctrlupd_busy_int;
   wire [REG_WIDTH -1:0] r151_swctl;
   wire [REG_WIDTH -1:0] r152_swstat;
   wire [REG_WIDTH -1:0] r153_swctlstatic;
   wire [REG_WIDTH -1:0] r169_poisoncfg;
   wire r169_poisoncfg_ack_pclk;
   wire reg_ddrc_wr_poison_intr_clr_ack_pclk;
   wire reg_ddrc_rd_poison_intr_clr_ack_pclk;
   wire [REG_WIDTH -1:0] r170_poisonstat;
   wire [REG_WIDTH -1:0] r193_pstat;
   wire [REG_WIDTH -1:0] r194_pccfg;
   wire [REG_WIDTH -1:0] r195_pcfgr_0;
   wire [REG_WIDTH -1:0] r196_pcfgw_0;
   wire [REG_WIDTH -1:0] r230_pctrl_0;
   wire r230_pctrl_0_ack_pclk;
   wire [REG_WIDTH -1:0] r231_pcfgqos0_0;
   wire [REG_WIDTH -1:0] r232_pcfgqos1_0;
   wire [REG_WIDTH -1:0] r233_pcfgwqos0_0;
   wire [REG_WIDTH -1:0] r234_pcfgwqos1_0;
   wire [REG_WIDTH -1:0] r856_umctl2_ver_number;
   wire [REG_WIDTH -1:0] r857_umctl2_ver_type;



//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation.
   assign set_async_reg = (1'b0
                        | rwselect[0] // UMCTL2_REGS MSTR
                        | rwselect[3] // UMCTL2_REGS MRCTRL0
                        | rwselect[4] // UMCTL2_REGS MRCTRL1
                        | rwselect[5] // UMCTL2_REGS MRCTRL2
                        | rwselect[10] // UMCTL2_REGS PWRCTL
                        | rwselect[14] // UMCTL2_REGS RFSHCTL0
                        | rwselect[15] // UMCTL2_REGS RFSHCTL1
                        | rwselect[18] // UMCTL2_REGS RFSHCTL3
                        | rwselect[19] // UMCTL2_REGS RFSHTMG
                        | rwselect[26] // UMCTL2_REGS CRCPARCTL0
                        | rwselect[27] // UMCTL2_REGS CRCPARCTL1
                        | rwselect[29] // UMCTL2_REGS INIT0
                        | rwselect[33] // UMCTL2_REGS INIT4
                        | rwselect[37] // UMCTL2_REGS DIMMCTL
                        | rwselect[50] // UMCTL2_REGS DRAMTMG10
                        | rwselect[63] // UMCTL2_REGS ZQCTL0
                        | rwselect[67] // UMCTL2_REGS DFITMG1
                        | rwselect[68] // UMCTL2_REGS DFILPCFG0
                        | rwselect[74] // UMCTL2_REGS DFIMISC
                        | rwselect[77] // UMCTL2_REGS DBICTL
                        | rwselect[78] // UMCTL2_REGS DFIPHYMSTR
                        | rwselect[85] // UMCTL2_REGS ADDRMAP6
                        | rwselect[86] // UMCTL2_REGS ADDRMAP7
                        | rwselect[125] // UMCTL2_REGS DBG1
                        | rwselect[126] // UMCTL2_REGS DBGCMD
                        | rwselect[133] // UMCTL2_REGS POISONCFG
                        | rwselect[184] // UMCTL2_MP PCTRL_0

                           ) & write_en;

   assign ack_async_reg =
                        ( r0_mstr_ack_pclk) |
                        ( r4_mrctrl0_ack_pclk) |
                        reg_ddrc_mr_wr_ack_pclk |
                        ( r5_mrctrl1_ack_pclk) |
                        ( r7_mrctrl2_ack_pclk) |
                        ( r12_pwrctl_ack_pclk) |
                        ( r17_rfshctl0_ack_pclk) |
                        ( r18_rfshctl1_ack_pclk) |
                        ( r21_rfshctl3_ack_pclk) |
                        ( r22_rfshtmg_ack_pclk) |
                        ( r44_crcparctl0_ack_pclk) |
                        reg_ddrc_dfi_alert_err_int_clr_ack_pclk |
                        reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk |
                        ( r45_crcparctl1_ack_pclk) |
                        ( r48_init0_ack_pclk) |
                        ( r52_init4_ack_pclk) |
                        ( r56_dimmctl_ack_pclk) |
                        ( r69_dramtmg10_ack_pclk) |
                        ( r82_zqctl0_ack_pclk) |
                        ( r87_dfitmg1_ack_pclk) |
                        ( r88_dfilpcfg0_ack_pclk) |
                        ( r94_dfimisc_ack_pclk) |
                        ( r98_dbictl_ack_pclk) |
                        ( r99_dfiphymstr_ack_pclk) |
                        ( r106_addrmap6_ack_pclk) |
                        ( r107_addrmap7_ack_pclk) |
                        ( r146_dbg1_ack_pclk) |
                        ( r148_dbgcmd_ack_pclk) |
                        reg_ddrc_rank0_refresh_ack_pclk |
                        reg_ddrc_rank1_refresh_ack_pclk |
                        reg_ddrc_zq_calib_short_ack_pclk |
                        reg_ddrc_ctrlupd_ack_pclk |
                        ( r169_poisoncfg_ack_pclk) |
                        reg_ddrc_wr_poison_intr_clr_ack_pclk |
                        reg_ddrc_rd_poison_intr_clr_ack_pclk |
                        ( r230_pctrl_0_ack_pclk) |

                           1'b0;
//spyglass enable_block W528

   // ----------------------------------------------------------------------------
   // The block performs the address decoding and data multiplexing for the local
   // interface and the configuration registers. The input address is decoded to
   // give a one-hot address that selects the respective register from the bank
   // ----------------------------------------------------------------------------
   DWC_ddr_umctl2_apb_adrdec
   
     #(.APB_AW       (APB_AW),
       .APB_DW       (APB_DW),
       .REG_WIDTH    (REG_WIDTH),
       .N_REGS       (N_REGS),
       .RW_REGS      (RW_REGS),
       .MAX_ADDR     (MAX_ADDR),
       .RWSELWIDTH   (RWSELWIDTH),
       .N_APBFSMSTAT (N_APBFSMSTAT)
       )
   adrdec
     (.presetn           (presetn),
      .pclk              (pclk),
      .paddr             (paddr),
      .pwrite            (pwrite),
      .psel              (psel),
      .apb_slv_ns        (apb_slv_ns),
      //----------------------------  
      .rwselect          (rwselect),
      .prdata            (prdata),
      .pslverr           (pslverr)

      ,.r0_mstr (r0_mstr)
      ,.r1_stat (r1_stat)
      ,.r4_mrctrl0 (r4_mrctrl0)
      ,.r5_mrctrl1 (r5_mrctrl1)
      ,.r6_mrstat (r6_mrstat)
      ,.r7_mrctrl2 (r7_mrctrl2)
      ,.r12_pwrctl (r12_pwrctl)
      ,.r13_pwrtmg (r13_pwrtmg)
      ,.r14_hwlpctl (r14_hwlpctl)
      ,.r17_rfshctl0 (r17_rfshctl0)
      ,.r18_rfshctl1 (r18_rfshctl1)
      ,.r21_rfshctl3 (r21_rfshctl3)
      ,.r22_rfshtmg (r22_rfshtmg)
      ,.r44_crcparctl0 (r44_crcparctl0)
      ,.r45_crcparctl1 (r45_crcparctl1)
      ,.r47_crcparstat (r47_crcparstat)
      ,.r48_init0 (r48_init0)
      ,.r49_init1 (r49_init1)
      ,.r51_init3 (r51_init3)
      ,.r52_init4 (r52_init4)
      ,.r53_init5 (r53_init5)
      ,.r54_init6 (r54_init6)
      ,.r55_init7 (r55_init7)
      ,.r56_dimmctl (r56_dimmctl)
      ,.r57_rankctl (r57_rankctl)
      ,.r59_dramtmg0 (r59_dramtmg0)
      ,.r60_dramtmg1 (r60_dramtmg1)
      ,.r61_dramtmg2 (r61_dramtmg2)
      ,.r62_dramtmg3 (r62_dramtmg3)
      ,.r63_dramtmg4 (r63_dramtmg4)
      ,.r64_dramtmg5 (r64_dramtmg5)
      ,.r67_dramtmg8 (r67_dramtmg8)
      ,.r68_dramtmg9 (r68_dramtmg9)
      ,.r69_dramtmg10 (r69_dramtmg10)
      ,.r70_dramtmg11 (r70_dramtmg11)
      ,.r71_dramtmg12 (r71_dramtmg12)
      ,.r74_dramtmg15 (r74_dramtmg15)
      ,.r82_zqctl0 (r82_zqctl0)
      ,.r83_zqctl1 (r83_zqctl1)
      ,.r86_dfitmg0 (r86_dfitmg0)
      ,.r87_dfitmg1 (r87_dfitmg1)
      ,.r88_dfilpcfg0 (r88_dfilpcfg0)
      ,.r89_dfilpcfg1 (r89_dfilpcfg1)
      ,.r90_dfiupd0 (r90_dfiupd0)
      ,.r91_dfiupd1 (r91_dfiupd1)
      ,.r92_dfiupd2 (r92_dfiupd2)
      ,.r94_dfimisc (r94_dfimisc)
      ,.r96_dfitmg3 (r96_dfitmg3)
      ,.r97_dfistat (r97_dfistat)
      ,.r98_dbictl (r98_dbictl)
      ,.r99_dfiphymstr (r99_dfiphymstr)
      ,.r100_addrmap0 (r100_addrmap0)
      ,.r101_addrmap1 (r101_addrmap1)
      ,.r102_addrmap2 (r102_addrmap2)
      ,.r103_addrmap3 (r103_addrmap3)
      ,.r104_addrmap4 (r104_addrmap4)
      ,.r105_addrmap5 (r105_addrmap5)
      ,.r106_addrmap6 (r106_addrmap6)
      ,.r107_addrmap7 (r107_addrmap7)
      ,.r108_addrmap8 (r108_addrmap8)
      ,.r109_addrmap9 (r109_addrmap9)
      ,.r110_addrmap10 (r110_addrmap10)
      ,.r111_addrmap11 (r111_addrmap11)
      ,.r113_odtcfg (r113_odtcfg)
      ,.r114_odtmap (r114_odtmap)
      ,.r115_sched (r115_sched)
      ,.r116_sched1 (r116_sched1)
      ,.r118_perfhpr1 (r118_perfhpr1)
      ,.r119_perflpr1 (r119_perflpr1)
      ,.r120_perfwr1 (r120_perfwr1)
      ,.r145_dbg0 (r145_dbg0)
      ,.r146_dbg1 (r146_dbg1)
      ,.r147_dbgcam (r147_dbgcam)
      ,.r148_dbgcmd (r148_dbgcmd)
      ,.r149_dbgstat (r149_dbgstat)
      ,.r151_swctl (r151_swctl)
      ,.r152_swstat (r152_swstat)
      ,.r153_swctlstatic (r153_swctlstatic)
      ,.r169_poisoncfg (r169_poisoncfg)
      ,.r170_poisonstat (r170_poisonstat)
      ,.r193_pstat (r193_pstat)
      ,.r194_pccfg (r194_pccfg)
      ,.r195_pcfgr_0 (r195_pcfgr_0)
      ,.r196_pcfgw_0 (r196_pcfgw_0)
      ,.r230_pctrl_0 (r230_pctrl_0)
      ,.r231_pcfgqos0_0 (r231_pcfgqos0_0)
      ,.r232_pcfgqos1_0 (r232_pcfgqos1_0)
      ,.r233_pcfgwqos0_0 (r233_pcfgwqos0_0)
      ,.r234_pcfgwqos1_0 (r234_pcfgwqos1_0)
      ,.r856_umctl2_ver_number (r856_umctl2_ver_number)
      ,.r857_umctl2_ver_type (r857_umctl2_ver_type)

      );    

   // ----------------------------------------------------------------------------
   // Module apbslvif (APB Slave Interface)
   // This module drives all the outputs for the APB module. It receives the
   // decoded address and depending on the SM state latches the data for a
   // write operation. This module also asserts pslverr in case the timer expires
   // or the address is out of bounds
   // The data is latched on the last clock of address decode (should we do it here
   // or move it to the address decoder-the latter seems to be easier)
   // pready is asserted and the data is put on the bus. This is on the same clk
   // when the SM is in the dataxfer state
   // The slave interfaces with the actual register file and retrieves the read
   // data from the register file (should the reg_file module be instantiated here?)
   // ----------------------------------------------------------------------------
      
   DWC_ddr_umctl2_apb_slvif
   
     #(.APB_AW        (APB_AW),
       .APB_DW        (APB_DW),
       .RW_REGS       (RW_REGS),
       .REG_WIDTH     (REG_WIDTH),
       .RWSELWIDTH    (RWSELWIDTH)
       ) 
   slvif
     (.pclk               (pclk)
      ,.presetn            (presetn)
      ,.pwdata             (pwdata)
      ,.rwselect           (rwselect)
      ,.write_en           (write_en_pulse)
      ,.store_rqst         (store_rqst)
      // static registers write enable
      ,.static_wr_en_aclk_0             (static_wr_en_aclk_0)
      ,.quasi_dyn_wr_en_aclk_0          (quasi_dyn_wr_en_aclk_0)
      ,.static_wr_en_core_ddrc_core_clk    (static_wr_en_core_ddrc_core_clk)
      ,.quasi_dyn_wr_en_core_ddrc_core_clk (quasi_dyn_wr_en_core_ddrc_core_clk)
//`ifdef UMCTL2_OCECC_EN_1      
//      ,.quasi_dyn_wr_en_pclk               (quasi_dyn_wr_en_pclk)
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1
      //------------------------------
      ,.r0_mstr (r0_mstr)
      ,.r4_mrctrl0 (r4_mrctrl0)
      ,.reg_ddrc_mr_wr_ack_pclk (reg_ddrc_mr_wr_ack_pclk)
      ,.ff_mr_wr_saved (ff_mr_wr_saved)
      ,.r5_mrctrl1 (r5_mrctrl1)
      ,.ddrc_reg_mr_wr_busy_int (ddrc_reg_mr_wr_busy_int)
      ,.r7_mrctrl2 (r7_mrctrl2)
      ,.r12_pwrctl (r12_pwrctl)
      ,.r13_pwrtmg (r13_pwrtmg)
      ,.r14_hwlpctl (r14_hwlpctl)
      ,.r17_rfshctl0 (r17_rfshctl0)
      ,.r18_rfshctl1 (r18_rfshctl1)
      ,.r21_rfshctl3 (r21_rfshctl3)
      ,.r22_rfshtmg (r22_rfshtmg)
      ,.r44_crcparctl0 (r44_crcparctl0)
      ,.reg_ddrc_dfi_alert_err_int_clr_ack_pclk (reg_ddrc_dfi_alert_err_int_clr_ack_pclk)
      ,.reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk (reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk)
      ,.r45_crcparctl1 (r45_crcparctl1)
      ,.r48_init0 (r48_init0)
      ,.r49_init1 (r49_init1)
      ,.r51_init3 (r51_init3)
      ,.r52_init4 (r52_init4)
      ,.r53_init5 (r53_init5)
      ,.r54_init6 (r54_init6)
      ,.r55_init7 (r55_init7)
      ,.r56_dimmctl (r56_dimmctl)
      ,.r57_rankctl (r57_rankctl)
      ,.r59_dramtmg0 (r59_dramtmg0)
      ,.r60_dramtmg1 (r60_dramtmg1)
      ,.r61_dramtmg2 (r61_dramtmg2)
      ,.r62_dramtmg3 (r62_dramtmg3)
      ,.r63_dramtmg4 (r63_dramtmg4)
      ,.r64_dramtmg5 (r64_dramtmg5)
      ,.r67_dramtmg8 (r67_dramtmg8)
      ,.r68_dramtmg9 (r68_dramtmg9)
      ,.r69_dramtmg10 (r69_dramtmg10)
      ,.r70_dramtmg11 (r70_dramtmg11)
      ,.r71_dramtmg12 (r71_dramtmg12)
      ,.r74_dramtmg15 (r74_dramtmg15)
      ,.r82_zqctl0 (r82_zqctl0)
      ,.r83_zqctl1 (r83_zqctl1)
      ,.r86_dfitmg0 (r86_dfitmg0)
      ,.r87_dfitmg1 (r87_dfitmg1)
      ,.r88_dfilpcfg0 (r88_dfilpcfg0)
      ,.r89_dfilpcfg1 (r89_dfilpcfg1)
      ,.r90_dfiupd0 (r90_dfiupd0)
      ,.r91_dfiupd1 (r91_dfiupd1)
      ,.r92_dfiupd2 (r92_dfiupd2)
      ,.r94_dfimisc (r94_dfimisc)
      ,.r96_dfitmg3 (r96_dfitmg3)
      ,.r98_dbictl (r98_dbictl)
      ,.r99_dfiphymstr (r99_dfiphymstr)
      ,.r100_addrmap0 (r100_addrmap0)
      ,.r101_addrmap1 (r101_addrmap1)
      ,.r102_addrmap2 (r102_addrmap2)
      ,.r103_addrmap3 (r103_addrmap3)
      ,.r104_addrmap4 (r104_addrmap4)
      ,.r105_addrmap5 (r105_addrmap5)
      ,.r106_addrmap6 (r106_addrmap6)
      ,.r107_addrmap7 (r107_addrmap7)
      ,.r108_addrmap8 (r108_addrmap8)
      ,.r109_addrmap9 (r109_addrmap9)
      ,.r110_addrmap10 (r110_addrmap10)
      ,.r111_addrmap11 (r111_addrmap11)
      ,.r113_odtcfg (r113_odtcfg)
      ,.r114_odtmap (r114_odtmap)
      ,.r115_sched (r115_sched)
      ,.r116_sched1 (r116_sched1)
      ,.r118_perfhpr1 (r118_perfhpr1)
      ,.r119_perflpr1 (r119_perflpr1)
      ,.r120_perfwr1 (r120_perfwr1)
      ,.r145_dbg0 (r145_dbg0)
      ,.r146_dbg1 (r146_dbg1)
      ,.r148_dbgcmd (r148_dbgcmd)
      ,.reg_ddrc_rank0_refresh_ack_pclk (reg_ddrc_rank0_refresh_ack_pclk)
      ,.ff_rank0_refresh_saved (ff_rank0_refresh_saved)
      ,.reg_ddrc_rank1_refresh_ack_pclk (reg_ddrc_rank1_refresh_ack_pclk)
      ,.ff_rank1_refresh_saved (ff_rank1_refresh_saved)
      ,.reg_ddrc_zq_calib_short_ack_pclk (reg_ddrc_zq_calib_short_ack_pclk)
      ,.ff_zq_calib_short_saved (ff_zq_calib_short_saved)
      ,.reg_ddrc_ctrlupd_ack_pclk (reg_ddrc_ctrlupd_ack_pclk)
      ,.ff_ctrlupd_saved (ff_ctrlupd_saved)
      ,.ddrc_reg_rank0_refresh_busy_int (ddrc_reg_rank0_refresh_busy_int)
      ,.ddrc_reg_rank1_refresh_busy_int (ddrc_reg_rank1_refresh_busy_int)
      ,.ddrc_reg_zq_calib_short_busy_int (ddrc_reg_zq_calib_short_busy_int)
      ,.ddrc_reg_ctrlupd_busy_int (ddrc_reg_ctrlupd_busy_int)
      ,.r151_swctl (r151_swctl)
      ,.r153_swctlstatic (r153_swctlstatic)
      ,.r169_poisoncfg (r169_poisoncfg)
      ,.reg_ddrc_wr_poison_intr_clr_ack_pclk (reg_ddrc_wr_poison_intr_clr_ack_pclk)
      ,.reg_ddrc_rd_poison_intr_clr_ack_pclk (reg_ddrc_rd_poison_intr_clr_ack_pclk)
      ,.r194_pccfg (r194_pccfg)
      ,.r195_pcfgr_0 (r195_pcfgr_0)
      ,.r196_pcfgw_0 (r196_pcfgw_0)
      ,.r230_pctrl_0 (r230_pctrl_0)
      ,.r231_pcfgqos0_0 (r231_pcfgqos0_0)
      ,.r232_pcfgqos1_0 (r232_pcfgqos1_0)
      ,.r233_pcfgwqos0_0 (r233_pcfgwqos0_0)
      ,.r234_pcfgwqos1_0 (r234_pcfgwqos1_0)

      );

   // ----------------------------------------------------------------------------
   // APB Slave State Machine
   // The APB Slave machine has the following states:
   // Idle : This is the default state. During Idle, if psel & penable
   // are asserted, apb_addr is latched.
   //
   // Address Decode: The SM enters Address Decode on psel & penable.
   // The  address is decoded in 4 clock cycles. During the last cycle the data
   // is latched (in case of a write). If there is an error during address
   // decode, pslverr is asserted with pready and the SM moves back to Idle
   //
   // Data Transfer: For a read operation the data is put on the bus and
   // pready is asserted for one clock cycle. In case of an error,
   // pslverr is asserted with pready
   // ----------------------------------------------------------------------------
   DWC_ddr_umctl2_apb_slvfsm
   
     #(.N_APBFSMSTAT(N_APBFSMSTAT))
   slvfsm
     (.pclk           (pclk),
      .presetn        (presetn),
      .psel           (psel),
      .penable        (penable),
      .pwrite         (pwrite),
      //------------------------------
      .set_async_reg  (set_async_reg),
      .ack_async_reg  (ack_async_reg),
      //------------------------------
      .apb_slv_cs     (apb_slv_cs_unused),
      .apb_slv_ns     (apb_slv_ns),
      .pready         (pready),
      .write_en       (write_en),
      .write_en_pulse (write_en_pulse),
      .write_en_s0    (write_en_s0),
      .fwd_reset_val  (fwd_reset_val),
      .store_rqst     (store_rqst)
      );

   // ----------------------------------------------------------------------------
   // output to the core is given from here. Each
   // register value is assigned to the corresponding core signal
   // ----------------------------------------------------------------------------     
   DWC_ddr_umctl2_apb_coreif
   
     #(.APB_AW              (APB_AW),
       .REG_WIDTH           (REG_WIDTH),
       .BCM_F_SYNC_TYPE_C2P (BCM_F_SYNC_TYPE_C2P),
       .BCM_F_SYNC_TYPE_P2C (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE_C2P (BCM_R_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE_P2C (BCM_R_SYNC_TYPE_P2C),
       .REG_OUTPUTS_C2P     (REG_OUTPUTS_C2P),
       .REG_OUTPUTS_P2C     (REG_OUTPUTS_P2C),
       .BCM_VERIF_EN        (BCM_VERIF_EN),
       .RW_REGS             (RW_REGS),
       .RWSELWIDTH          (RWSELWIDTH)
       )
     coreif
     (
      .apb_clk            (pclk),
      .apb_rst            (presetn),
      .core_ddrc_core_clk (core_ddrc_core_clk),
      .sync_core_ddrc_rstn(sync_core_ddrc_rstn),
      .core_ddrc_rstn     (core_ddrc_rstn),
      .rwselect           (rwselect),// should be rwselect s0 but address is latched
      .fwd_reset_val      (fwd_reset_val),
      .write_en           (write_en_s0)
      ,.aclk_0             (aclk_0)
      ,.sync_aresetn_0     (sync_aresetn_0)

   //------------------------
   // Register UMCTL2_REGS.MSTR
   //------------------------
      ,.r0_mstr (r0_mstr)
      ,.r0_mstr_ack_pclk (r0_mstr_ack_pclk)
      ,.reg_ddrc_ddr3 (reg_ddrc_ddr3)
      ,.reg_ddrc_ddr4 (reg_ddrc_ddr4)
      ,.reg_ddrc_burstchop (reg_ddrc_burstchop)
      ,.reg_ddrc_en_2t_timing_mode (reg_ddrc_en_2t_timing_mode)
      ,.reg_ddrc_geardown_mode (reg_ddrc_geardown_mode)
      ,.reg_ddrc_data_bus_width (reg_ddrc_data_bus_width)
      ,.reg_ddrc_dll_off_mode (reg_ddrc_dll_off_mode)
      ,.reg_ddrc_burst_rdwr (reg_ddrc_burst_rdwr)
      ,.reg_ddrc_active_ranks (reg_ddrc_active_ranks)
      ,.reg_ddrc_device_config (reg_ddrc_device_config)
   //------------------------
   // Register UMCTL2_REGS.STAT
   //------------------------
      ,.r1_stat (r1_stat)
      ,.ddrc_reg_operating_mode (ddrc_reg_operating_mode)
      ,.ddrc_reg_selfref_type (ddrc_reg_selfref_type)
      ,.ddrc_reg_selfref_cam_not_empty (ddrc_reg_selfref_cam_not_empty)
   //------------------------
   // Register UMCTL2_REGS.MRCTRL0
   //------------------------
      ,.r4_mrctrl0 (r4_mrctrl0)
      ,.r4_mrctrl0_ack_pclk (r4_mrctrl0_ack_pclk)
      ,.reg_ddrc_mr_type (reg_ddrc_mr_type)
      ,.reg_ddrc_mpr_en (reg_ddrc_mpr_en)
      ,.reg_ddrc_pda_en (reg_ddrc_pda_en)
      ,.reg_ddrc_sw_init_int (reg_ddrc_sw_init_int)
      ,.reg_ddrc_mr_rank (reg_ddrc_mr_rank)
      ,.reg_ddrc_mr_addr (reg_ddrc_mr_addr)
      ,.reg_ddrc_pba_mode (reg_ddrc_pba_mode)
      ,.reg_ddrc_mr_wr_ack_pclk (reg_ddrc_mr_wr_ack_pclk)
      ,.ff_mr_wr_saved (ff_mr_wr_saved)
      ,.reg_ddrc_mr_wr (reg_ddrc_mr_wr)
   //------------------------
   // Register UMCTL2_REGS.MRCTRL1
   //------------------------
      ,.r5_mrctrl1 (r5_mrctrl1)
      ,.r5_mrctrl1_ack_pclk (r5_mrctrl1_ack_pclk)
      ,.reg_ddrc_mr_data (reg_ddrc_mr_data)
   //------------------------
   // Register UMCTL2_REGS.MRSTAT
   //------------------------
      ,.r6_mrstat (r6_mrstat)
      ,.ddrc_reg_mr_wr_busy_int (ddrc_reg_mr_wr_busy_int)
      ,.ddrc_reg_mr_wr_busy (ddrc_reg_mr_wr_busy)
      ,.ddrc_reg_pda_done (ddrc_reg_pda_done)
   //------------------------
   // Register UMCTL2_REGS.MRCTRL2
   //------------------------
      ,.r7_mrctrl2 (r7_mrctrl2)
      ,.r7_mrctrl2_ack_pclk (r7_mrctrl2_ack_pclk)
      ,.reg_ddrc_mr_device_sel (reg_ddrc_mr_device_sel)
   //------------------------
   // Register UMCTL2_REGS.PWRCTL
   //------------------------
      ,.r12_pwrctl (r12_pwrctl)
      ,.r12_pwrctl_ack_pclk (r12_pwrctl_ack_pclk)
      ,.reg_ddrc_selfref_en (reg_ddrc_selfref_en)
      ,.reg_ddrc_powerdown_en (reg_ddrc_powerdown_en)
      ,.reg_ddrc_en_dfi_dram_clk_disable (reg_ddrc_en_dfi_dram_clk_disable)
      ,.reg_ddrc_mpsm_en (reg_ddrc_mpsm_en)
      ,.reg_ddrc_selfref_sw (reg_ddrc_selfref_sw)
      ,.reg_ddrc_dis_cam_drain_selfref (reg_ddrc_dis_cam_drain_selfref)
   //------------------------
   // Register UMCTL2_REGS.PWRTMG
   //------------------------
      ,.r13_pwrtmg (r13_pwrtmg[REG_WIDTH-1:0])
      ,.reg_ddrc_powerdown_to_x32 (reg_ddrc_powerdown_to_x32)
      ,.reg_ddrc_selfref_to_x32 (reg_ddrc_selfref_to_x32)
   //------------------------
   // Register UMCTL2_REGS.HWLPCTL
   //------------------------
      ,.r14_hwlpctl (r14_hwlpctl[REG_WIDTH-1:0])
      ,.reg_ddrc_hw_lp_en (reg_ddrc_hw_lp_en)
      ,.reg_ddrc_hw_lp_exit_idle_en (reg_ddrc_hw_lp_exit_idle_en)
      ,.reg_ddrc_hw_lp_idle_x32 (reg_ddrc_hw_lp_idle_x32)
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL0
   //------------------------
      ,.r17_rfshctl0 (r17_rfshctl0)
      ,.r17_rfshctl0_ack_pclk (r17_rfshctl0_ack_pclk)
      ,.reg_ddrc_refresh_burst (reg_ddrc_refresh_burst)
      ,.reg_ddrc_refresh_to_x1_x32 (reg_ddrc_refresh_to_x1_x32)
      ,.reg_ddrc_refresh_margin (reg_ddrc_refresh_margin)
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL1
   //------------------------
      ,.r18_rfshctl1 (r18_rfshctl1)
      ,.r18_rfshctl1_ack_pclk (r18_rfshctl1_ack_pclk)
      ,.reg_ddrc_refresh_timer0_start_value_x32 (reg_ddrc_refresh_timer0_start_value_x32)
      ,.reg_ddrc_refresh_timer1_start_value_x32 (reg_ddrc_refresh_timer1_start_value_x32)
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL3
   //------------------------
      ,.r21_rfshctl3 (r21_rfshctl3)
      ,.r21_rfshctl3_ack_pclk (r21_rfshctl3_ack_pclk)
      ,.reg_ddrc_dis_auto_refresh (reg_ddrc_dis_auto_refresh)
      ,.reg_ddrc_refresh_update_level (reg_ddrc_refresh_update_level)
      ,.reg_ddrc_refresh_mode (reg_ddrc_refresh_mode)
   //------------------------
   // Register UMCTL2_REGS.RFSHTMG
   //------------------------
      ,.r22_rfshtmg (r22_rfshtmg)
      ,.r22_rfshtmg_ack_pclk (r22_rfshtmg_ack_pclk)
      ,.reg_ddrc_t_rfc_min (reg_ddrc_t_rfc_min)
      ,.reg_ddrc_t_rfc_nom_x1_x32 (reg_ddrc_t_rfc_nom_x1_x32)
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL0
   //------------------------
      ,.r44_crcparctl0 (r44_crcparctl0)
      ,.r44_crcparctl0_ack_pclk (r44_crcparctl0_ack_pclk)
      ,.reg_ddrc_dfi_alert_err_int_en (reg_ddrc_dfi_alert_err_int_en)
      ,.reg_ddrc_dfi_alert_err_int_clr_ack_pclk (reg_ddrc_dfi_alert_err_int_clr_ack_pclk)
      ,.reg_ddrc_dfi_alert_err_int_clr (reg_ddrc_dfi_alert_err_int_clr)
      ,.reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk (reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk)
      ,.reg_ddrc_dfi_alert_err_cnt_clr (reg_ddrc_dfi_alert_err_cnt_clr)
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL1
   //------------------------
      ,.r45_crcparctl1 (r45_crcparctl1)
      ,.r45_crcparctl1_ack_pclk (r45_crcparctl1_ack_pclk)
      ,.reg_ddrc_parity_enable (reg_ddrc_parity_enable)
      ,.reg_ddrc_crc_enable (reg_ddrc_crc_enable)
      ,.reg_ddrc_crc_inc_dm (reg_ddrc_crc_inc_dm)
      ,.reg_ddrc_caparity_disable_before_sr (reg_ddrc_caparity_disable_before_sr)
   //------------------------
   // Register UMCTL2_REGS.CRCPARSTAT
   //------------------------
      ,.r47_crcparstat (r47_crcparstat)
      ,.ddrc_reg_dfi_alert_err_cnt (ddrc_reg_dfi_alert_err_cnt)
      ,.ddrc_reg_dfi_alert_err_int (ddrc_reg_dfi_alert_err_int)
   //------------------------
   // Register UMCTL2_REGS.INIT0
   //------------------------
      ,.r48_init0 (r48_init0)
      ,.r48_init0_ack_pclk (r48_init0_ack_pclk)
      ,.reg_ddrc_pre_cke_x1024 (reg_ddrc_pre_cke_x1024)
      ,.reg_ddrc_post_cke_x1024 (reg_ddrc_post_cke_x1024)
      ,.reg_ddrc_skip_dram_init (reg_ddrc_skip_dram_init)
   //------------------------
   // Register UMCTL2_REGS.INIT1
   //------------------------
      ,.r49_init1 (r49_init1[REG_WIDTH-1:0])
      ,.reg_ddrc_pre_ocd_x32 (reg_ddrc_pre_ocd_x32)
      ,.reg_ddrc_dram_rstn_x1024 (reg_ddrc_dram_rstn_x1024)
   //------------------------
   // Register UMCTL2_REGS.INIT3
   //------------------------
      ,.r51_init3 (r51_init3[REG_WIDTH-1:0])
      ,.reg_ddrc_emr (reg_ddrc_emr)
      ,.reg_ddrc_mr (reg_ddrc_mr)
   //------------------------
   // Register UMCTL2_REGS.INIT4
   //------------------------
      ,.r52_init4 (r52_init4)
      ,.r52_init4_ack_pclk (r52_init4_ack_pclk)
      ,.reg_ddrc_emr3 (reg_ddrc_emr3)
      ,.reg_ddrc_emr2 (reg_ddrc_emr2)
   //------------------------
   // Register UMCTL2_REGS.INIT5
   //------------------------
      ,.r53_init5 (r53_init5[REG_WIDTH-1:0])
      ,.reg_ddrc_dev_zqinit_x32 (reg_ddrc_dev_zqinit_x32)
   //------------------------
   // Register UMCTL2_REGS.INIT6
   //------------------------
      ,.r54_init6 (r54_init6[REG_WIDTH-1:0])
      ,.reg_ddrc_mr5 (reg_ddrc_mr5)
      ,.reg_ddrc_mr4 (reg_ddrc_mr4)
   //------------------------
   // Register UMCTL2_REGS.INIT7
   //------------------------
      ,.r55_init7 (r55_init7[REG_WIDTH-1:0])
      ,.reg_ddrc_mr6 (reg_ddrc_mr6)
   //------------------------
   // Register UMCTL2_REGS.DIMMCTL
   //------------------------
      ,.r56_dimmctl (r56_dimmctl)
      ,.r56_dimmctl_ack_pclk (r56_dimmctl_ack_pclk)
      ,.reg_ddrc_dimm_stagger_cs_en (reg_ddrc_dimm_stagger_cs_en)
      ,.reg_ddrc_dimm_addr_mirr_en (reg_ddrc_dimm_addr_mirr_en)
      ,.reg_ddrc_dimm_output_inv_en (reg_ddrc_dimm_output_inv_en)
      ,.reg_ddrc_mrs_a17_en (reg_ddrc_mrs_a17_en)
      ,.reg_ddrc_mrs_bg1_en (reg_ddrc_mrs_bg1_en)
      ,.reg_ddrc_dimm_dis_bg_mirroring (reg_ddrc_dimm_dis_bg_mirroring)
      ,.reg_ddrc_lrdimm_bcom_cmd_prot (reg_ddrc_lrdimm_bcom_cmd_prot)
      ,.reg_ddrc_rcd_weak_drive (reg_ddrc_rcd_weak_drive)
      ,.reg_ddrc_rcd_a_output_disabled (reg_ddrc_rcd_a_output_disabled)
      ,.reg_ddrc_rcd_b_output_disabled (reg_ddrc_rcd_b_output_disabled)
   //------------------------
   // Register UMCTL2_REGS.RANKCTL
   //------------------------
      ,.r57_rankctl (r57_rankctl[REG_WIDTH-1:0])
      ,.reg_ddrc_max_rank_rd (reg_ddrc_max_rank_rd)
      ,.reg_ddrc_diff_rank_rd_gap (reg_ddrc_diff_rank_rd_gap)
      ,.reg_ddrc_diff_rank_wr_gap (reg_ddrc_diff_rank_wr_gap)
      ,.reg_ddrc_max_rank_wr (reg_ddrc_max_rank_wr)
      ,.reg_ddrc_diff_rank_rd_gap_msb (reg_ddrc_diff_rank_rd_gap_msb)
      ,.reg_ddrc_diff_rank_wr_gap_msb (reg_ddrc_diff_rank_wr_gap_msb)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG0
   //------------------------
      ,.r59_dramtmg0 (r59_dramtmg0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_ras_min (reg_ddrc_t_ras_min)
      ,.reg_ddrc_t_ras_max (reg_ddrc_t_ras_max)
      ,.reg_ddrc_t_faw (reg_ddrc_t_faw)
      ,.reg_ddrc_wr2pre (reg_ddrc_wr2pre)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG1
   //------------------------
      ,.r60_dramtmg1 (r60_dramtmg1[REG_WIDTH-1:0])
      ,.reg_ddrc_t_rc (reg_ddrc_t_rc)
      ,.reg_ddrc_rd2pre (reg_ddrc_rd2pre)
      ,.reg_ddrc_t_xp (reg_ddrc_t_xp)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG2
   //------------------------
      ,.r61_dramtmg2 (r61_dramtmg2[REG_WIDTH-1:0])
      ,.reg_ddrc_wr2rd (reg_ddrc_wr2rd)
      ,.reg_ddrc_rd2wr (reg_ddrc_rd2wr)
      ,.reg_ddrc_read_latency (reg_ddrc_read_latency)
      ,.reg_ddrc_write_latency (reg_ddrc_write_latency)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG3
   //------------------------
      ,.r62_dramtmg3 (r62_dramtmg3[REG_WIDTH-1:0])
      ,.reg_ddrc_t_mod (reg_ddrc_t_mod)
      ,.reg_ddrc_t_mrd (reg_ddrc_t_mrd)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG4
   //------------------------
      ,.r63_dramtmg4 (r63_dramtmg4[REG_WIDTH-1:0])
      ,.reg_ddrc_t_rp (reg_ddrc_t_rp)
      ,.reg_ddrc_t_rrd (reg_ddrc_t_rrd)
      ,.reg_ddrc_t_ccd (reg_ddrc_t_ccd)
      ,.reg_ddrc_t_rcd (reg_ddrc_t_rcd)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG5
   //------------------------
      ,.r64_dramtmg5 (r64_dramtmg5[REG_WIDTH-1:0])
      ,.reg_ddrc_t_cke (reg_ddrc_t_cke)
      ,.reg_ddrc_t_ckesr (reg_ddrc_t_ckesr)
      ,.reg_ddrc_t_cksre (reg_ddrc_t_cksre)
      ,.reg_ddrc_t_cksrx (reg_ddrc_t_cksrx)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG8
   //------------------------
      ,.r67_dramtmg8 (r67_dramtmg8[REG_WIDTH-1:0])
      ,.reg_ddrc_t_xs_x32 (reg_ddrc_t_xs_x32)
      ,.reg_ddrc_t_xs_dll_x32 (reg_ddrc_t_xs_dll_x32)
      ,.reg_ddrc_t_xs_abort_x32 (reg_ddrc_t_xs_abort_x32)
      ,.reg_ddrc_t_xs_fast_x32 (reg_ddrc_t_xs_fast_x32)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG9
   //------------------------
      ,.r68_dramtmg9 (r68_dramtmg9[REG_WIDTH-1:0])
      ,.reg_ddrc_wr2rd_s (reg_ddrc_wr2rd_s)
      ,.reg_ddrc_t_rrd_s (reg_ddrc_t_rrd_s)
      ,.reg_ddrc_t_ccd_s (reg_ddrc_t_ccd_s)
      ,.reg_ddrc_ddr4_wr_preamble (reg_ddrc_ddr4_wr_preamble)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG10
   //------------------------
      ,.r69_dramtmg10 (r69_dramtmg10)
      ,.r69_dramtmg10_ack_pclk (r69_dramtmg10_ack_pclk)
      ,.reg_ddrc_t_gear_hold (reg_ddrc_t_gear_hold)
      ,.reg_ddrc_t_gear_setup (reg_ddrc_t_gear_setup)
      ,.reg_ddrc_t_cmd_gear (reg_ddrc_t_cmd_gear)
      ,.reg_ddrc_t_sync_gear (reg_ddrc_t_sync_gear)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG11
   //------------------------
      ,.r70_dramtmg11 (r70_dramtmg11[REG_WIDTH-1:0])
      ,.reg_ddrc_t_ckmpe (reg_ddrc_t_ckmpe)
      ,.reg_ddrc_t_mpx_s (reg_ddrc_t_mpx_s)
      ,.reg_ddrc_t_mpx_lh (reg_ddrc_t_mpx_lh)
      ,.reg_ddrc_post_mpsm_gap_x32 (reg_ddrc_post_mpsm_gap_x32)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG12
   //------------------------
      ,.r71_dramtmg12 (r71_dramtmg12[REG_WIDTH-1:0])
      ,.reg_ddrc_t_mrd_pda (reg_ddrc_t_mrd_pda)
      ,.reg_ddrc_t_wr_mpr (reg_ddrc_t_wr_mpr)
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG15
   //------------------------
      ,.r74_dramtmg15 (r74_dramtmg15[REG_WIDTH-1:0])
      ,.reg_ddrc_t_stab_x32 (reg_ddrc_t_stab_x32)
      ,.reg_ddrc_en_dfi_lp_t_stab (reg_ddrc_en_dfi_lp_t_stab)
   //------------------------
   // Register UMCTL2_REGS.ZQCTL0
   //------------------------
      ,.r82_zqctl0 (r82_zqctl0)
      ,.r82_zqctl0_ack_pclk (r82_zqctl0_ack_pclk)
      ,.reg_ddrc_t_zq_short_nop (reg_ddrc_t_zq_short_nop)
      ,.reg_ddrc_t_zq_long_nop (reg_ddrc_t_zq_long_nop)
      ,.reg_ddrc_dis_mpsmx_zqcl (reg_ddrc_dis_mpsmx_zqcl)
      ,.reg_ddrc_zq_resistor_shared (reg_ddrc_zq_resistor_shared)
      ,.reg_ddrc_dis_srx_zqcl (reg_ddrc_dis_srx_zqcl)
      ,.reg_ddrc_dis_auto_zq (reg_ddrc_dis_auto_zq)
   //------------------------
   // Register UMCTL2_REGS.ZQCTL1
   //------------------------
      ,.r83_zqctl1 (r83_zqctl1[REG_WIDTH-1:0])
      ,.reg_ddrc_t_zq_short_interval_x1024 (reg_ddrc_t_zq_short_interval_x1024)
   //------------------------
   // Register UMCTL2_REGS.DFITMG0
   //------------------------
      ,.r86_dfitmg0 (r86_dfitmg0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_tphy_wrlat (reg_ddrc_dfi_tphy_wrlat)
      ,.reg_ddrc_dfi_tphy_wrdata (reg_ddrc_dfi_tphy_wrdata)
      ,.reg_ddrc_dfi_wrdata_use_dfi_phy_clk (reg_ddrc_dfi_wrdata_use_dfi_phy_clk)
      ,.reg_ddrc_dfi_t_rddata_en (reg_ddrc_dfi_t_rddata_en)
      ,.reg_ddrc_dfi_rddata_use_dfi_phy_clk (reg_ddrc_dfi_rddata_use_dfi_phy_clk)
      ,.reg_ddrc_dfi_t_ctrl_delay (reg_ddrc_dfi_t_ctrl_delay)
   //------------------------
   // Register UMCTL2_REGS.DFITMG1
   //------------------------
      ,.r87_dfitmg1 (r87_dfitmg1)
      ,.r87_dfitmg1_ack_pclk (r87_dfitmg1_ack_pclk)
      ,.reg_ddrc_dfi_t_dram_clk_enable (reg_ddrc_dfi_t_dram_clk_enable)
      ,.reg_ddrc_dfi_t_dram_clk_disable (reg_ddrc_dfi_t_dram_clk_disable)
      ,.reg_ddrc_dfi_t_wrdata_delay (reg_ddrc_dfi_t_wrdata_delay)
      ,.reg_ddrc_dfi_t_parin_lat (reg_ddrc_dfi_t_parin_lat)
      ,.reg_ddrc_dfi_t_cmd_lat (reg_ddrc_dfi_t_cmd_lat)
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG0
   //------------------------
      ,.r88_dfilpcfg0 (r88_dfilpcfg0)
      ,.r88_dfilpcfg0_ack_pclk (r88_dfilpcfg0_ack_pclk)
      ,.reg_ddrc_dfi_lp_en_pd (reg_ddrc_dfi_lp_en_pd)
      ,.reg_ddrc_dfi_lp_wakeup_pd (reg_ddrc_dfi_lp_wakeup_pd)
      ,.reg_ddrc_dfi_lp_en_sr (reg_ddrc_dfi_lp_en_sr)
      ,.reg_ddrc_dfi_lp_wakeup_sr (reg_ddrc_dfi_lp_wakeup_sr)
      ,.reg_ddrc_dfi_tlp_resp (reg_ddrc_dfi_tlp_resp)
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG1
   //------------------------
      ,.r89_dfilpcfg1 (r89_dfilpcfg1[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_lp_en_mpsm (reg_ddrc_dfi_lp_en_mpsm)
      ,.reg_ddrc_dfi_lp_wakeup_mpsm (reg_ddrc_dfi_lp_wakeup_mpsm)
   //------------------------
   // Register UMCTL2_REGS.DFIUPD0
   //------------------------
      ,.r90_dfiupd0 (r90_dfiupd0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_t_ctrlup_min (reg_ddrc_dfi_t_ctrlup_min)
      ,.reg_ddrc_dfi_t_ctrlup_max (reg_ddrc_dfi_t_ctrlup_max)
      ,.reg_ddrc_ctrlupd_pre_srx (reg_ddrc_ctrlupd_pre_srx)
      ,.reg_ddrc_dis_auto_ctrlupd_srx (reg_ddrc_dis_auto_ctrlupd_srx)
      ,.reg_ddrc_dis_auto_ctrlupd (reg_ddrc_dis_auto_ctrlupd)
   //------------------------
   // Register UMCTL2_REGS.DFIUPD1
   //------------------------
      ,.r91_dfiupd1 (r91_dfiupd1[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_t_ctrlupd_interval_max_x1024 (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024)
      ,.reg_ddrc_dfi_t_ctrlupd_interval_min_x1024 (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024)
   //------------------------
   // Register UMCTL2_REGS.DFIUPD2
   //------------------------
      ,.r92_dfiupd2 (r92_dfiupd2[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_phyupd_en (reg_ddrc_dfi_phyupd_en)
   //------------------------
   // Register UMCTL2_REGS.DFIMISC
   //------------------------
      ,.r94_dfimisc (r94_dfimisc)
      ,.r94_dfimisc_ack_pclk (r94_dfimisc_ack_pclk)
      ,.reg_ddrc_dfi_init_complete_en (reg_ddrc_dfi_init_complete_en)
      ,.reg_ddrc_phy_dbi_mode (reg_ddrc_phy_dbi_mode)
      ,.reg_ddrc_ctl_idle_en (reg_ddrc_ctl_idle_en)
      ,.reg_ddrc_dfi_init_start (reg_ddrc_dfi_init_start)
      ,.reg_ddrc_dis_dyn_adr_tri (reg_ddrc_dis_dyn_adr_tri)
      ,.reg_ddrc_dfi_frequency (reg_ddrc_dfi_frequency)
   //------------------------
   // Register UMCTL2_REGS.DFITMG3
   //------------------------
      ,.r96_dfitmg3 (r96_dfitmg3[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_t_geardown_delay (reg_ddrc_dfi_t_geardown_delay)
   //------------------------
   // Register UMCTL2_REGS.DFISTAT
   //------------------------
      ,.r97_dfistat (r97_dfistat)
      ,.ddrc_reg_dfi_init_complete (ddrc_reg_dfi_init_complete)
      ,.ddrc_reg_dfi_lp_ack (ddrc_reg_dfi_lp_ack)
   //------------------------
   // Register UMCTL2_REGS.DBICTL
   //------------------------
      ,.r98_dbictl (r98_dbictl)
      ,.r98_dbictl_ack_pclk (r98_dbictl_ack_pclk)
      ,.reg_ddrc_dm_en (reg_ddrc_dm_en)
      ,.reg_ddrc_wr_dbi_en (reg_ddrc_wr_dbi_en)
      ,.reg_ddrc_rd_dbi_en (reg_ddrc_rd_dbi_en)
   //------------------------
   // Register UMCTL2_REGS.DFIPHYMSTR
   //------------------------
      ,.r99_dfiphymstr (r99_dfiphymstr)
      ,.r99_dfiphymstr_ack_pclk (r99_dfiphymstr_ack_pclk)
      ,.reg_ddrc_dfi_phymstr_en (reg_ddrc_dfi_phymstr_en)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP0
   //------------------------
      ,.r100_addrmap0 (r100_addrmap0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_cs_bit0 (reg_ddrc_addrmap_cs_bit0)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP1
   //------------------------
      ,.r101_addrmap1 (r101_addrmap1[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_bank_b0 (reg_ddrc_addrmap_bank_b0)
      ,.reg_ddrc_addrmap_bank_b1 (reg_ddrc_addrmap_bank_b1)
      ,.reg_ddrc_addrmap_bank_b2 (reg_ddrc_addrmap_bank_b2)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP2
   //------------------------
      ,.r102_addrmap2 (r102_addrmap2[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_col_b2 (reg_ddrc_addrmap_col_b2)
      ,.reg_ddrc_addrmap_col_b3 (reg_ddrc_addrmap_col_b3)
      ,.reg_ddrc_addrmap_col_b4 (reg_ddrc_addrmap_col_b4)
      ,.reg_ddrc_addrmap_col_b5 (reg_ddrc_addrmap_col_b5)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP3
   //------------------------
      ,.r103_addrmap3 (r103_addrmap3[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_col_b6 (reg_ddrc_addrmap_col_b6)
      ,.reg_ddrc_addrmap_col_b7 (reg_ddrc_addrmap_col_b7)
      ,.reg_ddrc_addrmap_col_b8 (reg_ddrc_addrmap_col_b8)
      ,.reg_ddrc_addrmap_col_b9 (reg_ddrc_addrmap_col_b9)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP4
   //------------------------
      ,.r104_addrmap4 (r104_addrmap4[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_col_b10 (reg_ddrc_addrmap_col_b10)
      ,.reg_ddrc_addrmap_col_b11 (reg_ddrc_addrmap_col_b11)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP5
   //------------------------
      ,.r105_addrmap5 (r105_addrmap5[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b0 (reg_ddrc_addrmap_row_b0)
      ,.reg_ddrc_addrmap_row_b1 (reg_ddrc_addrmap_row_b1)
      ,.reg_ddrc_addrmap_row_b2_10 (reg_ddrc_addrmap_row_b2_10)
      ,.reg_ddrc_addrmap_row_b11 (reg_ddrc_addrmap_row_b11)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP6
   //------------------------
      ,.r106_addrmap6 (r106_addrmap6)
      ,.r106_addrmap6_ack_pclk (r106_addrmap6_ack_pclk)
      ,.reg_ddrc_addrmap_row_b12 (reg_ddrc_addrmap_row_b12)
      ,.reg_ddrc_addrmap_row_b13 (reg_ddrc_addrmap_row_b13)
      ,.reg_ddrc_addrmap_row_b14 (reg_ddrc_addrmap_row_b14)
      ,.reg_ddrc_addrmap_row_b15 (reg_ddrc_addrmap_row_b15)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP7
   //------------------------
      ,.r107_addrmap7 (r107_addrmap7)
      ,.r107_addrmap7_ack_pclk (r107_addrmap7_ack_pclk)
      ,.reg_ddrc_addrmap_row_b16 (reg_ddrc_addrmap_row_b16)
      ,.reg_ddrc_addrmap_row_b17 (reg_ddrc_addrmap_row_b17)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP8
   //------------------------
      ,.r108_addrmap8 (r108_addrmap8[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_bg_b0 (reg_ddrc_addrmap_bg_b0)
      ,.reg_ddrc_addrmap_bg_b1 (reg_ddrc_addrmap_bg_b1)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP9
   //------------------------
      ,.r109_addrmap9 (r109_addrmap9[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b2 (reg_ddrc_addrmap_row_b2)
      ,.reg_ddrc_addrmap_row_b3 (reg_ddrc_addrmap_row_b3)
      ,.reg_ddrc_addrmap_row_b4 (reg_ddrc_addrmap_row_b4)
      ,.reg_ddrc_addrmap_row_b5 (reg_ddrc_addrmap_row_b5)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP10
   //------------------------
      ,.r110_addrmap10 (r110_addrmap10[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b6 (reg_ddrc_addrmap_row_b6)
      ,.reg_ddrc_addrmap_row_b7 (reg_ddrc_addrmap_row_b7)
      ,.reg_ddrc_addrmap_row_b8 (reg_ddrc_addrmap_row_b8)
      ,.reg_ddrc_addrmap_row_b9 (reg_ddrc_addrmap_row_b9)
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP11
   //------------------------
      ,.r111_addrmap11 (r111_addrmap11[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b10 (reg_ddrc_addrmap_row_b10)
   //------------------------
   // Register UMCTL2_REGS.ODTCFG
   //------------------------
      ,.r113_odtcfg (r113_odtcfg[REG_WIDTH-1:0])
      ,.reg_ddrc_rd_odt_delay (reg_ddrc_rd_odt_delay)
      ,.reg_ddrc_rd_odt_hold (reg_ddrc_rd_odt_hold)
      ,.reg_ddrc_wr_odt_delay (reg_ddrc_wr_odt_delay)
      ,.reg_ddrc_wr_odt_hold (reg_ddrc_wr_odt_hold)
   //------------------------
   // Register UMCTL2_REGS.ODTMAP
   //------------------------
      ,.r114_odtmap (r114_odtmap[REG_WIDTH-1:0])
      ,.reg_ddrc_rank0_wr_odt (reg_ddrc_rank0_wr_odt)
      ,.reg_ddrc_rank0_rd_odt (reg_ddrc_rank0_rd_odt)
      ,.reg_ddrc_rank1_wr_odt (reg_ddrc_rank1_wr_odt)
      ,.reg_ddrc_rank1_rd_odt (reg_ddrc_rank1_rd_odt)
   //------------------------
   // Register UMCTL2_REGS.SCHED
   //------------------------
      ,.r115_sched (r115_sched[REG_WIDTH-1:0])
      ,.reg_ddrc_prefer_write (reg_ddrc_prefer_write)
      ,.reg_ddrc_pageclose (reg_ddrc_pageclose)
      ,.reg_ddrc_autopre_rmw (reg_ddrc_autopre_rmw)
      ,.reg_ddrc_lpr_num_entries (reg_ddrc_lpr_num_entries)
      ,.reg_ddrc_go2critical_hysteresis (reg_ddrc_go2critical_hysteresis)
      ,.reg_ddrc_rdwr_idle_gap (reg_ddrc_rdwr_idle_gap)
   //------------------------
   // Register UMCTL2_REGS.SCHED1
   //------------------------
      ,.r116_sched1 (r116_sched1[REG_WIDTH-1:0])
      ,.reg_ddrc_pageclose_timer (reg_ddrc_pageclose_timer)
   //------------------------
   // Register UMCTL2_REGS.PERFHPR1
   //------------------------
      ,.r118_perfhpr1 (r118_perfhpr1[REG_WIDTH-1:0])
      ,.reg_ddrc_hpr_max_starve (reg_ddrc_hpr_max_starve)
      ,.reg_ddrc_hpr_xact_run_length (reg_ddrc_hpr_xact_run_length)
   //------------------------
   // Register UMCTL2_REGS.PERFLPR1
   //------------------------
      ,.r119_perflpr1 (r119_perflpr1[REG_WIDTH-1:0])
      ,.reg_ddrc_lpr_max_starve (reg_ddrc_lpr_max_starve)
      ,.reg_ddrc_lpr_xact_run_length (reg_ddrc_lpr_xact_run_length)
   //------------------------
   // Register UMCTL2_REGS.PERFWR1
   //------------------------
      ,.r120_perfwr1 (r120_perfwr1[REG_WIDTH-1:0])
      ,.reg_ddrc_w_max_starve (reg_ddrc_w_max_starve)
      ,.reg_ddrc_w_xact_run_length (reg_ddrc_w_xact_run_length)
   //------------------------
   // Register UMCTL2_REGS.DBG0
   //------------------------
      ,.r145_dbg0 (r145_dbg0[REG_WIDTH-1:0])
      ,.reg_ddrc_dis_wc (reg_ddrc_dis_wc)
      ,.reg_ddrc_dis_collision_page_opt (reg_ddrc_dis_collision_page_opt)
      ,.reg_ddrc_dis_max_rank_rd_opt (reg_ddrc_dis_max_rank_rd_opt)
      ,.reg_ddrc_dis_max_rank_wr_opt (reg_ddrc_dis_max_rank_wr_opt)
   //------------------------
   // Register UMCTL2_REGS.DBG1
   //------------------------
      ,.r146_dbg1 (r146_dbg1)
      ,.r146_dbg1_ack_pclk (r146_dbg1_ack_pclk)
      ,.reg_ddrc_dis_dq (reg_ddrc_dis_dq)
      ,.reg_ddrc_dis_hif (reg_ddrc_dis_hif)
   //------------------------
   // Register UMCTL2_REGS.DBGCAM
   //------------------------
      ,.r147_dbgcam (r147_dbgcam)
      ,.ddrc_reg_dbg_hpr_q_depth (ddrc_reg_dbg_hpr_q_depth)
      ,.ddrc_reg_dbg_lpr_q_depth (ddrc_reg_dbg_lpr_q_depth)
      ,.ddrc_reg_dbg_w_q_depth (ddrc_reg_dbg_w_q_depth)
      ,.ddrc_reg_dbg_rd_q_empty (ddrc_reg_dbg_rd_q_empty)
      ,.ddrc_reg_dbg_wr_q_empty (ddrc_reg_dbg_wr_q_empty)
      ,.ddrc_reg_rd_data_pipeline_empty (ddrc_reg_rd_data_pipeline_empty)
      ,.ddrc_reg_wr_data_pipeline_empty (ddrc_reg_wr_data_pipeline_empty)
      ,.ddrc_reg_dbg_stall_wr (ddrc_reg_dbg_stall_wr)
      ,.ddrc_reg_dbg_stall_rd (ddrc_reg_dbg_stall_rd)
   //------------------------
   // Register UMCTL2_REGS.DBGCMD
   //------------------------
      ,.r148_dbgcmd (r148_dbgcmd)
      ,.r148_dbgcmd_ack_pclk (r148_dbgcmd_ack_pclk)
      ,.reg_ddrc_rank0_refresh_ack_pclk (reg_ddrc_rank0_refresh_ack_pclk)
      ,.ff_rank0_refresh_saved (ff_rank0_refresh_saved)
      ,.reg_ddrc_rank0_refresh (reg_ddrc_rank0_refresh)
      ,.reg_ddrc_rank1_refresh_ack_pclk (reg_ddrc_rank1_refresh_ack_pclk)
      ,.ff_rank1_refresh_saved (ff_rank1_refresh_saved)
      ,.reg_ddrc_rank1_refresh (reg_ddrc_rank1_refresh)
      ,.reg_ddrc_zq_calib_short_ack_pclk (reg_ddrc_zq_calib_short_ack_pclk)
      ,.ff_zq_calib_short_saved (ff_zq_calib_short_saved)
      ,.reg_ddrc_zq_calib_short (reg_ddrc_zq_calib_short)
      ,.reg_ddrc_ctrlupd_ack_pclk (reg_ddrc_ctrlupd_ack_pclk)
      ,.ff_ctrlupd_saved (ff_ctrlupd_saved)
      ,.reg_ddrc_ctrlupd (reg_ddrc_ctrlupd)
   //------------------------
   // Register UMCTL2_REGS.DBGSTAT
   //------------------------
      ,.r149_dbgstat (r149_dbgstat)
      ,.ddrc_reg_rank0_refresh_busy_int (ddrc_reg_rank0_refresh_busy_int)
      ,.ddrc_reg_rank0_refresh_busy (ddrc_reg_rank0_refresh_busy)
      ,.ddrc_reg_rank1_refresh_busy_int (ddrc_reg_rank1_refresh_busy_int)
      ,.ddrc_reg_rank1_refresh_busy (ddrc_reg_rank1_refresh_busy)
      ,.ddrc_reg_zq_calib_short_busy_int (ddrc_reg_zq_calib_short_busy_int)
      ,.ddrc_reg_zq_calib_short_busy (ddrc_reg_zq_calib_short_busy)
      ,.ddrc_reg_ctrlupd_busy_int (ddrc_reg_ctrlupd_busy_int)
      ,.ddrc_reg_ctrlupd_busy (ddrc_reg_ctrlupd_busy)
   //------------------------
   // Register UMCTL2_REGS.SWCTL
   //------------------------
      ,.r151_swctl (r151_swctl[REG_WIDTH-1:0])
      ,.reg_ddrc_sw_done (reg_ddrc_sw_done)
   //------------------------
   // Register UMCTL2_REGS.SWSTAT
   //------------------------
      ,.r152_swstat (r152_swstat)
      ,.ddrc_reg_sw_done_ack (ddrc_reg_sw_done_ack)
   //------------------------
   // Register UMCTL2_REGS.SWCTLSTATIC
   //------------------------
      ,.r153_swctlstatic (r153_swctlstatic[REG_WIDTH-1:0])
      ,.reg_ddrc_sw_static_unlock (reg_ddrc_sw_static_unlock)
   //------------------------
   // Register UMCTL2_REGS.POISONCFG
   //------------------------
      ,.r169_poisoncfg (r169_poisoncfg)
      ,.r169_poisoncfg_ack_pclk (r169_poisoncfg_ack_pclk)
      ,.reg_ddrc_wr_poison_slverr_en (reg_ddrc_wr_poison_slverr_en)
      ,.reg_ddrc_wr_poison_intr_en (reg_ddrc_wr_poison_intr_en)
      ,.reg_ddrc_wr_poison_intr_clr_ack_pclk (reg_ddrc_wr_poison_intr_clr_ack_pclk)
      ,.reg_ddrc_wr_poison_intr_clr (reg_ddrc_wr_poison_intr_clr)
      ,.reg_ddrc_rd_poison_slverr_en (reg_ddrc_rd_poison_slverr_en)
      ,.reg_ddrc_rd_poison_intr_en (reg_ddrc_rd_poison_intr_en)
      ,.reg_ddrc_rd_poison_intr_clr_ack_pclk (reg_ddrc_rd_poison_intr_clr_ack_pclk)
      ,.reg_ddrc_rd_poison_intr_clr (reg_ddrc_rd_poison_intr_clr)
   //------------------------
   // Register UMCTL2_REGS.POISONSTAT
   //------------------------
      ,.r170_poisonstat (r170_poisonstat)
      ,.ddrc_reg_wr_poison_intr_0 (ddrc_reg_wr_poison_intr_0)
      ,.ddrc_reg_rd_poison_intr_0 (ddrc_reg_rd_poison_intr_0)
   //------------------------
   // Register UMCTL2_MP.PSTAT
   //------------------------
      ,.r193_pstat (r193_pstat)
      ,.arb_reg_rd_port_busy_0 (arb_reg_rd_port_busy_0)
      ,.arb_reg_wr_port_busy_0 (arb_reg_wr_port_busy_0)
   //------------------------
   // Register UMCTL2_MP.PCCFG
   //------------------------
      ,.r194_pccfg (r194_pccfg[REG_WIDTH-1:0])
      ,.reg_arb_go2critical_en (reg_arb_go2critical_en)
      ,.reg_arb_pagematch_limit (reg_arb_pagematch_limit)
      ,.reg_arb_bl_exp_mode (reg_arb_bl_exp_mode)
   //------------------------
   // Register UMCTL2_MP.PCFGR_0
   //------------------------
      ,.r195_pcfgr_0 (r195_pcfgr_0[REG_WIDTH-1:0])
      ,.reg_arb_rd_port_priority_0 (reg_arb_rd_port_priority_0)
      ,.reg_arb_rd_port_aging_en_0 (reg_arb_rd_port_aging_en_0)
      ,.reg_arb_rd_port_urgent_en_0 (reg_arb_rd_port_urgent_en_0)
      ,.reg_arb_rd_port_pagematch_en_0 (reg_arb_rd_port_pagematch_en_0)
   //------------------------
   // Register UMCTL2_MP.PCFGW_0
   //------------------------
      ,.r196_pcfgw_0 (r196_pcfgw_0[REG_WIDTH-1:0])
      ,.reg_arb_wr_port_priority_0 (reg_arb_wr_port_priority_0)
      ,.reg_arb_wr_port_aging_en_0 (reg_arb_wr_port_aging_en_0)
      ,.reg_arb_wr_port_urgent_en_0 (reg_arb_wr_port_urgent_en_0)
      ,.reg_arb_wr_port_pagematch_en_0 (reg_arb_wr_port_pagematch_en_0)
   //------------------------
   // Register UMCTL2_MP.PCTRL_0
   //------------------------
      ,.r230_pctrl_0 (r230_pctrl_0)
      ,.r230_pctrl_0_ack_pclk (r230_pctrl_0_ack_pclk)
      ,.reg_arba0_port_en_0 (reg_arba0_port_en_0)
   //------------------------
   // Register UMCTL2_MP.PCFGQOS0_0
   //------------------------
      ,.r231_pcfgqos0_0 (r231_pcfgqos0_0[REG_WIDTH-1:0])
      ,.reg_arba0_rqos_map_level1_0 (reg_arba0_rqos_map_level1_0)
      ,.reg_arba0_rqos_map_region0_0 (reg_arba0_rqos_map_region0_0)
      ,.reg_arba0_rqos_map_region1_0 (reg_arba0_rqos_map_region1_0)
   //------------------------
   // Register UMCTL2_MP.PCFGQOS1_0
   //------------------------
      ,.r232_pcfgqos1_0 (r232_pcfgqos1_0[REG_WIDTH-1:0])
      ,.reg_arb_rqos_map_timeoutb_0 (reg_arb_rqos_map_timeoutb_0)
      ,.reg_arb_rqos_map_timeoutr_0 (reg_arb_rqos_map_timeoutr_0)
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS0_0
   //------------------------
      ,.r233_pcfgwqos0_0 (r233_pcfgwqos0_0[REG_WIDTH-1:0])
      ,.reg_arba0_wqos_map_level1_0 (reg_arba0_wqos_map_level1_0)
      ,.reg_arba0_wqos_map_level2_0 (reg_arba0_wqos_map_level2_0)
      ,.reg_arba0_wqos_map_region0_0 (reg_arba0_wqos_map_region0_0)
      ,.reg_arba0_wqos_map_region1_0 (reg_arba0_wqos_map_region1_0)
      ,.reg_arba0_wqos_map_region2_0 (reg_arba0_wqos_map_region2_0)
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS1_0
   //------------------------
      ,.r234_pcfgwqos1_0 (r234_pcfgwqos1_0[REG_WIDTH-1:0])
      ,.reg_arb_wqos_map_timeout1_0 (reg_arb_wqos_map_timeout1_0)
      ,.reg_arb_wqos_map_timeout2_0 (reg_arb_wqos_map_timeout2_0)
   //------------------------
   // Register UMCTL2_MP.UMCTL2_VER_NUMBER
   //------------------------
      ,.r856_umctl2_ver_number (r856_umctl2_ver_number)
      ,.arb_reg_ver_number (arb_reg_ver_number)
   //------------------------
   // Register UMCTL2_MP.UMCTL2_VER_TYPE
   //------------------------
      ,.r857_umctl2_ver_type (r857_umctl2_ver_type)
      ,.arb_reg_ver_type (arb_reg_ver_type)



      ,.dfi_alert_err_intr       (dfi_alert_err_intr)
);



endmodule // DWC_ddr_umctl2_apb_slvtop
