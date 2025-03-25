//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_apb_slvif.sv#16 $
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
//SMD: Self determined expression '(16 * 15)' found in module 'DWC_ddr_umctl2_apb_slvif'
//SJ: This coding style is acceptable and there is no plan to change it.
`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_apb_slvif
  #(parameter APB_AW = 16,
    parameter APB_DW = 32,
    parameter RW_REGS = `UMCTL2_REG_RW_REGS,
    parameter REG_WIDTH = 32,
    parameter RWSELWIDTH = RW_REGS
    )
   (input                     pclk
    ,input                     presetn
    ,input [APB_DW-1:0]        pwdata
    ,input [RWSELWIDTH-1:0]    rwselect
    ,input                     write_en
    ,input                     store_rqst
    // static registers write enable
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
    ,input               static_wr_en_aclk_0
    ,input               quasi_dyn_wr_en_aclk_0
//spyglass enable_block W240
    ,input               static_wr_en_core_ddrc_core_clk
    ,input               quasi_dyn_wr_en_core_ddrc_core_clk
//`ifdef UMCTL2_OCECC_EN_1    
//    ,input               quasi_dyn_wr_en_pclk
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1 
    //----------------------------------
   ,output reg [REG_WIDTH -1:0] r0_mstr
   ,output reg [REG_WIDTH -1:0] r4_mrctrl0
   ,input reg_ddrc_mr_wr_ack_pclk
   ,output reg ff_mr_wr_saved
   ,output reg [REG_WIDTH -1:0] r5_mrctrl1
   ,input ddrc_reg_mr_wr_busy_int
   ,output reg [REG_WIDTH -1:0] r7_mrctrl2
   ,output reg [REG_WIDTH -1:0] r12_pwrctl
   ,output reg [REG_WIDTH -1:0] r13_pwrtmg
   ,output reg [REG_WIDTH -1:0] r14_hwlpctl
   ,output reg [REG_WIDTH -1:0] r17_rfshctl0
   ,output reg [REG_WIDTH -1:0] r18_rfshctl1
   ,output reg [REG_WIDTH -1:0] r21_rfshctl3
   ,output reg [REG_WIDTH -1:0] r22_rfshtmg
   ,output reg [REG_WIDTH -1:0] r44_crcparctl0
   ,input reg_ddrc_dfi_alert_err_int_clr_ack_pclk
   ,input reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk
   ,output reg [REG_WIDTH -1:0] r45_crcparctl1
   ,output reg [REG_WIDTH -1:0] r48_init0
   ,output reg [REG_WIDTH -1:0] r49_init1
   ,output reg [REG_WIDTH -1:0] r51_init3
   ,output reg [REG_WIDTH -1:0] r52_init4
   ,output reg [REG_WIDTH -1:0] r53_init5
   ,output reg [REG_WIDTH -1:0] r54_init6
   ,output reg [REG_WIDTH -1:0] r55_init7
   ,output reg [REG_WIDTH -1:0] r56_dimmctl
   ,output reg [REG_WIDTH -1:0] r57_rankctl
   ,output reg [REG_WIDTH -1:0] r59_dramtmg0
   ,output reg [REG_WIDTH -1:0] r60_dramtmg1
   ,output reg [REG_WIDTH -1:0] r61_dramtmg2
   ,output reg [REG_WIDTH -1:0] r62_dramtmg3
   ,output reg [REG_WIDTH -1:0] r63_dramtmg4
   ,output reg [REG_WIDTH -1:0] r64_dramtmg5
   ,output reg [REG_WIDTH -1:0] r67_dramtmg8
   ,output reg [REG_WIDTH -1:0] r68_dramtmg9
   ,output reg [REG_WIDTH -1:0] r69_dramtmg10
   ,output reg [REG_WIDTH -1:0] r70_dramtmg11
   ,output reg [REG_WIDTH -1:0] r71_dramtmg12
   ,output reg [REG_WIDTH -1:0] r74_dramtmg15
   ,output reg [REG_WIDTH -1:0] r82_zqctl0
   ,output reg [REG_WIDTH -1:0] r83_zqctl1
   ,output reg [REG_WIDTH -1:0] r86_dfitmg0
   ,output reg [REG_WIDTH -1:0] r87_dfitmg1
   ,output reg [REG_WIDTH -1:0] r88_dfilpcfg0
   ,output reg [REG_WIDTH -1:0] r89_dfilpcfg1
   ,output reg [REG_WIDTH -1:0] r90_dfiupd0
   ,output reg [REG_WIDTH -1:0] r91_dfiupd1
   ,output reg [REG_WIDTH -1:0] r92_dfiupd2
   ,output reg [REG_WIDTH -1:0] r94_dfimisc
   ,output reg [REG_WIDTH -1:0] r96_dfitmg3
   ,output reg [REG_WIDTH -1:0] r98_dbictl
   ,output reg [REG_WIDTH -1:0] r99_dfiphymstr
   ,output reg [REG_WIDTH -1:0] r100_addrmap0
   ,output reg [REG_WIDTH -1:0] r101_addrmap1
   ,output reg [REG_WIDTH -1:0] r102_addrmap2
   ,output reg [REG_WIDTH -1:0] r103_addrmap3
   ,output reg [REG_WIDTH -1:0] r104_addrmap4
   ,output reg [REG_WIDTH -1:0] r105_addrmap5
   ,output reg [REG_WIDTH -1:0] r106_addrmap6
   ,output reg [REG_WIDTH -1:0] r107_addrmap7
   ,output reg [REG_WIDTH -1:0] r108_addrmap8
   ,output reg [REG_WIDTH -1:0] r109_addrmap9
   ,output reg [REG_WIDTH -1:0] r110_addrmap10
   ,output reg [REG_WIDTH -1:0] r111_addrmap11
   ,output reg [REG_WIDTH -1:0] r113_odtcfg
   ,output reg [REG_WIDTH -1:0] r114_odtmap
   ,output reg [REG_WIDTH -1:0] r115_sched
   ,output reg [REG_WIDTH -1:0] r116_sched1
   ,output reg [REG_WIDTH -1:0] r118_perfhpr1
   ,output reg [REG_WIDTH -1:0] r119_perflpr1
   ,output reg [REG_WIDTH -1:0] r120_perfwr1
   ,output reg [REG_WIDTH -1:0] r145_dbg0
   ,output reg [REG_WIDTH -1:0] r146_dbg1
   ,output reg [REG_WIDTH -1:0] r148_dbgcmd
   ,input reg_ddrc_rank0_refresh_ack_pclk
   ,output reg ff_rank0_refresh_saved
   ,input reg_ddrc_rank1_refresh_ack_pclk
   ,output reg ff_rank1_refresh_saved
   ,input reg_ddrc_zq_calib_short_ack_pclk
   ,output reg ff_zq_calib_short_saved
   ,input reg_ddrc_ctrlupd_ack_pclk
   ,output reg ff_ctrlupd_saved
   ,input ddrc_reg_rank0_refresh_busy_int
   ,input ddrc_reg_rank1_refresh_busy_int
   ,input ddrc_reg_zq_calib_short_busy_int
   ,input ddrc_reg_ctrlupd_busy_int
   ,output reg [REG_WIDTH -1:0] r151_swctl
   ,output reg [REG_WIDTH -1:0] r153_swctlstatic
   ,output reg [REG_WIDTH -1:0] r169_poisoncfg
   ,input reg_ddrc_wr_poison_intr_clr_ack_pclk
   ,input reg_ddrc_rd_poison_intr_clr_ack_pclk
   ,output reg [REG_WIDTH -1:0] r194_pccfg
   ,output reg [REG_WIDTH -1:0] r195_pcfgr_0
   ,output reg [REG_WIDTH -1:0] r196_pcfgw_0
   ,output reg [REG_WIDTH -1:0] r230_pctrl_0
   ,output reg [REG_WIDTH -1:0] r231_pcfgqos0_0
   ,output reg [REG_WIDTH -1:0] r232_pcfgqos1_0
   ,output reg [REG_WIDTH -1:0] r233_pcfgwqos0_0
   ,output reg [REG_WIDTH -1:0] r234_pcfgwqos1_0


    );
  
   reg [APB_DW-1:0]         apb_data_r;
   reg [REG_WIDTH-1:0]      apb_data_expanded;

   wire [REG_WIDTH-1:0] umctl2_regs_mstr_ddr3_mask;
   assign umctl2_regs_mstr_ddr3_mask = `UMCTL2_REG_MSK_MSTR_DDR3;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_ddr4_mask;
   assign umctl2_regs_mstr_ddr4_mask = `UMCTL2_REG_MSK_MSTR_DDR4;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_burstchop_mask;
   assign umctl2_regs_mstr_burstchop_mask = `UMCTL2_REG_MSK_MSTR_BURSTCHOP;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_en_2t_timing_mode_mask;
   assign umctl2_regs_mstr_en_2t_timing_mode_mask = `UMCTL2_REG_MSK_MSTR_EN_2T_TIMING_MODE;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_geardown_mode_mask;
   assign umctl2_regs_mstr_geardown_mode_mask = `UMCTL2_REG_MSK_MSTR_GEARDOWN_MODE;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_data_bus_width_mask;
   assign umctl2_regs_mstr_data_bus_width_mask = `UMCTL2_REG_MSK_MSTR_DATA_BUS_WIDTH;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_dll_off_mode_mask;
   assign umctl2_regs_mstr_dll_off_mode_mask = `UMCTL2_REG_MSK_MSTR_DLL_OFF_MODE;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_burst_rdwr_mask;
   assign umctl2_regs_mstr_burst_rdwr_mask = `UMCTL2_REG_MSK_MSTR_BURST_RDWR;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_active_ranks_mask;
   assign umctl2_regs_mstr_active_ranks_mask = `UMCTL2_REG_MSK_MSTR_ACTIVE_RANKS;
   wire [REG_WIDTH-1:0] umctl2_regs_mstr_device_config_mask;
   assign umctl2_regs_mstr_device_config_mask = `UMCTL2_REG_MSK_MSTR_DEVICE_CONFIG;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_mr_type_mask;
   assign umctl2_regs_mrctrl0_mr_type_mask = `UMCTL2_REG_MSK_MRCTRL0_MR_TYPE;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_mpr_en_mask;
   assign umctl2_regs_mrctrl0_mpr_en_mask = `UMCTL2_REG_MSK_MRCTRL0_MPR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_pda_en_mask;
   assign umctl2_regs_mrctrl0_pda_en_mask = `UMCTL2_REG_MSK_MRCTRL0_PDA_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_sw_init_int_mask;
   assign umctl2_regs_mrctrl0_sw_init_int_mask = `UMCTL2_REG_MSK_MRCTRL0_SW_INIT_INT;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_mr_rank_mask;
   assign umctl2_regs_mrctrl0_mr_rank_mask = `UMCTL2_REG_MSK_MRCTRL0_MR_RANK;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_mr_addr_mask;
   assign umctl2_regs_mrctrl0_mr_addr_mask = `UMCTL2_REG_MSK_MRCTRL0_MR_ADDR;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_pba_mode_mask;
   assign umctl2_regs_mrctrl0_pba_mode_mask = `UMCTL2_REG_MSK_MRCTRL0_PBA_MODE;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl0_mr_wr_mask;
   assign umctl2_regs_mrctrl0_mr_wr_mask = `UMCTL2_REG_MSK_MRCTRL0_MR_WR;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl1_mr_data_mask;
   assign umctl2_regs_mrctrl1_mr_data_mask = `UMCTL2_REG_MSK_MRCTRL1_MR_DATA;
   wire [REG_WIDTH-1:0] umctl2_regs_mrctrl2_mr_device_sel_mask;
   assign umctl2_regs_mrctrl2_mr_device_sel_mask = `UMCTL2_REG_MSK_MRCTRL2_MR_DEVICE_SEL;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrctl_selfref_en_mask;
   assign umctl2_regs_pwrctl_selfref_en_mask = `UMCTL2_REG_MSK_PWRCTL_SELFREF_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrctl_powerdown_en_mask;
   assign umctl2_regs_pwrctl_powerdown_en_mask = `UMCTL2_REG_MSK_PWRCTL_POWERDOWN_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrctl_en_dfi_dram_clk_disable_mask;
   assign umctl2_regs_pwrctl_en_dfi_dram_clk_disable_mask = `UMCTL2_REG_MSK_PWRCTL_EN_DFI_DRAM_CLK_DISABLE;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrctl_mpsm_en_mask;
   assign umctl2_regs_pwrctl_mpsm_en_mask = `UMCTL2_REG_MSK_PWRCTL_MPSM_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrctl_selfref_sw_mask;
   assign umctl2_regs_pwrctl_selfref_sw_mask = `UMCTL2_REG_MSK_PWRCTL_SELFREF_SW;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrctl_dis_cam_drain_selfref_mask;
   assign umctl2_regs_pwrctl_dis_cam_drain_selfref_mask = `UMCTL2_REG_MSK_PWRCTL_DIS_CAM_DRAIN_SELFREF;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrtmg_powerdown_to_x32_mask;
   assign umctl2_regs_pwrtmg_powerdown_to_x32_mask = `UMCTL2_REG_MSK_PWRTMG_POWERDOWN_TO_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_pwrtmg_selfref_to_x32_mask;
   assign umctl2_regs_pwrtmg_selfref_to_x32_mask = `UMCTL2_REG_MSK_PWRTMG_SELFREF_TO_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_hwlpctl_hw_lp_en_mask;
   assign umctl2_regs_hwlpctl_hw_lp_en_mask = `UMCTL2_REG_MSK_HWLPCTL_HW_LP_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_hwlpctl_hw_lp_exit_idle_en_mask;
   assign umctl2_regs_hwlpctl_hw_lp_exit_idle_en_mask = `UMCTL2_REG_MSK_HWLPCTL_HW_LP_EXIT_IDLE_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_hwlpctl_hw_lp_idle_x32_mask;
   assign umctl2_regs_hwlpctl_hw_lp_idle_x32_mask = `UMCTL2_REG_MSK_HWLPCTL_HW_LP_IDLE_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl0_refresh_burst_mask;
   assign umctl2_regs_rfshctl0_refresh_burst_mask = `UMCTL2_REG_MSK_RFSHCTL0_REFRESH_BURST;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl0_refresh_to_x1_x32_mask;
   assign umctl2_regs_rfshctl0_refresh_to_x1_x32_mask = `UMCTL2_REG_MSK_RFSHCTL0_REFRESH_TO_X1_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl0_refresh_margin_mask;
   assign umctl2_regs_rfshctl0_refresh_margin_mask = `UMCTL2_REG_MSK_RFSHCTL0_REFRESH_MARGIN;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl1_refresh_timer0_start_value_x32_mask;
   assign umctl2_regs_rfshctl1_refresh_timer0_start_value_x32_mask = `UMCTL2_REG_MSK_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl1_refresh_timer1_start_value_x32_mask;
   assign umctl2_regs_rfshctl1_refresh_timer1_start_value_x32_mask = `UMCTL2_REG_MSK_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl3_dis_auto_refresh_mask;
   assign umctl2_regs_rfshctl3_dis_auto_refresh_mask = `UMCTL2_REG_MSK_RFSHCTL3_DIS_AUTO_REFRESH;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl3_refresh_update_level_mask;
   assign umctl2_regs_rfshctl3_refresh_update_level_mask = `UMCTL2_REG_MSK_RFSHCTL3_REFRESH_UPDATE_LEVEL;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshctl3_refresh_mode_mask;
   assign umctl2_regs_rfshctl3_refresh_mode_mask = `UMCTL2_REG_MSK_RFSHCTL3_REFRESH_MODE;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshtmg_t_rfc_min_mask;
   assign umctl2_regs_rfshtmg_t_rfc_min_mask = `UMCTL2_REG_MSK_RFSHTMG_T_RFC_MIN;
   wire [REG_WIDTH-1:0] umctl2_regs_rfshtmg_t_rfc_nom_x1_x32_mask;
   assign umctl2_regs_rfshtmg_t_rfc_nom_x1_x32_mask = `UMCTL2_REG_MSK_RFSHTMG_T_RFC_NOM_X1_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl0_dfi_alert_err_int_en_mask;
   assign umctl2_regs_crcparctl0_dfi_alert_err_int_en_mask = `UMCTL2_REG_MSK_CRCPARCTL0_DFI_ALERT_ERR_INT_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl0_dfi_alert_err_int_clr_mask;
   assign umctl2_regs_crcparctl0_dfi_alert_err_int_clr_mask = `UMCTL2_REG_MSK_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl0_dfi_alert_err_cnt_clr_mask;
   assign umctl2_regs_crcparctl0_dfi_alert_err_cnt_clr_mask = `UMCTL2_REG_MSK_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl1_parity_enable_mask;
   assign umctl2_regs_crcparctl1_parity_enable_mask = `UMCTL2_REG_MSK_CRCPARCTL1_PARITY_ENABLE;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl1_crc_enable_mask;
   assign umctl2_regs_crcparctl1_crc_enable_mask = `UMCTL2_REG_MSK_CRCPARCTL1_CRC_ENABLE;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl1_crc_inc_dm_mask;
   assign umctl2_regs_crcparctl1_crc_inc_dm_mask = `UMCTL2_REG_MSK_CRCPARCTL1_CRC_INC_DM;
   wire [REG_WIDTH-1:0] umctl2_regs_crcparctl1_caparity_disable_before_sr_mask;
   assign umctl2_regs_crcparctl1_caparity_disable_before_sr_mask = `UMCTL2_REG_MSK_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR;
   wire [REG_WIDTH-1:0] umctl2_regs_init0_pre_cke_x1024_mask;
   assign umctl2_regs_init0_pre_cke_x1024_mask = `UMCTL2_REG_MSK_INIT0_PRE_CKE_X1024;
   wire [REG_WIDTH-1:0] umctl2_regs_init0_post_cke_x1024_mask;
   assign umctl2_regs_init0_post_cke_x1024_mask = `UMCTL2_REG_MSK_INIT0_POST_CKE_X1024;
   wire [REG_WIDTH-1:0] umctl2_regs_init0_skip_dram_init_mask;
   assign umctl2_regs_init0_skip_dram_init_mask = `UMCTL2_REG_MSK_INIT0_SKIP_DRAM_INIT;
   wire [REG_WIDTH-1:0] umctl2_regs_init1_pre_ocd_x32_mask;
   assign umctl2_regs_init1_pre_ocd_x32_mask = `UMCTL2_REG_MSK_INIT1_PRE_OCD_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_init1_dram_rstn_x1024_mask;
   assign umctl2_regs_init1_dram_rstn_x1024_mask = `UMCTL2_REG_MSK_INIT1_DRAM_RSTN_X1024;
   wire [REG_WIDTH-1:0] umctl2_regs_init3_emr_mask;
   assign umctl2_regs_init3_emr_mask = `UMCTL2_REG_MSK_INIT3_EMR;
   wire [REG_WIDTH-1:0] umctl2_regs_init3_mr_mask;
   assign umctl2_regs_init3_mr_mask = `UMCTL2_REG_MSK_INIT3_MR;
   wire [REG_WIDTH-1:0] umctl2_regs_init4_emr3_mask;
   assign umctl2_regs_init4_emr3_mask = `UMCTL2_REG_MSK_INIT4_EMR3;
   wire [REG_WIDTH-1:0] umctl2_regs_init4_emr2_mask;
   assign umctl2_regs_init4_emr2_mask = `UMCTL2_REG_MSK_INIT4_EMR2;
   wire [REG_WIDTH-1:0] umctl2_regs_init5_dev_zqinit_x32_mask;
   assign umctl2_regs_init5_dev_zqinit_x32_mask = `UMCTL2_REG_MSK_INIT5_DEV_ZQINIT_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_init6_mr5_mask;
   assign umctl2_regs_init6_mr5_mask = `UMCTL2_REG_MSK_INIT6_MR5;
   wire [REG_WIDTH-1:0] umctl2_regs_init6_mr4_mask;
   assign umctl2_regs_init6_mr4_mask = `UMCTL2_REG_MSK_INIT6_MR4;
   wire [REG_WIDTH-1:0] umctl2_regs_init7_mr6_mask;
   assign umctl2_regs_init7_mr6_mask = `UMCTL2_REG_MSK_INIT7_MR6;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_dimm_stagger_cs_en_mask;
   assign umctl2_regs_dimmctl_dimm_stagger_cs_en_mask = `UMCTL2_REG_MSK_DIMMCTL_DIMM_STAGGER_CS_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_dimm_addr_mirr_en_mask;
   assign umctl2_regs_dimmctl_dimm_addr_mirr_en_mask = `UMCTL2_REG_MSK_DIMMCTL_DIMM_ADDR_MIRR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_dimm_output_inv_en_mask;
   assign umctl2_regs_dimmctl_dimm_output_inv_en_mask = `UMCTL2_REG_MSK_DIMMCTL_DIMM_OUTPUT_INV_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_mrs_a17_en_mask;
   assign umctl2_regs_dimmctl_mrs_a17_en_mask = `UMCTL2_REG_MSK_DIMMCTL_MRS_A17_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_mrs_bg1_en_mask;
   assign umctl2_regs_dimmctl_mrs_bg1_en_mask = `UMCTL2_REG_MSK_DIMMCTL_MRS_BG1_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_dimm_dis_bg_mirroring_mask;
   assign umctl2_regs_dimmctl_dimm_dis_bg_mirroring_mask = `UMCTL2_REG_MSK_DIMMCTL_DIMM_DIS_BG_MIRRORING;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_lrdimm_bcom_cmd_prot_mask;
   assign umctl2_regs_dimmctl_lrdimm_bcom_cmd_prot_mask = `UMCTL2_REG_MSK_DIMMCTL_LRDIMM_BCOM_CMD_PROT;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_rcd_weak_drive_mask;
   assign umctl2_regs_dimmctl_rcd_weak_drive_mask = `UMCTL2_REG_MSK_DIMMCTL_RCD_WEAK_DRIVE;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_rcd_a_output_disabled_mask;
   assign umctl2_regs_dimmctl_rcd_a_output_disabled_mask = `UMCTL2_REG_MSK_DIMMCTL_RCD_A_OUTPUT_DISABLED;
   wire [REG_WIDTH-1:0] umctl2_regs_dimmctl_rcd_b_output_disabled_mask;
   assign umctl2_regs_dimmctl_rcd_b_output_disabled_mask = `UMCTL2_REG_MSK_DIMMCTL_RCD_B_OUTPUT_DISABLED;
   wire [REG_WIDTH-1:0] umctl2_regs_rankctl_max_rank_rd_mask;
   assign umctl2_regs_rankctl_max_rank_rd_mask = `UMCTL2_REG_MSK_RANKCTL_MAX_RANK_RD;
   wire [REG_WIDTH-1:0] umctl2_regs_rankctl_diff_rank_rd_gap_mask;
   assign umctl2_regs_rankctl_diff_rank_rd_gap_mask = `UMCTL2_REG_MSK_RANKCTL_DIFF_RANK_RD_GAP;
   wire [REG_WIDTH-1:0] umctl2_regs_rankctl_diff_rank_wr_gap_mask;
   assign umctl2_regs_rankctl_diff_rank_wr_gap_mask = `UMCTL2_REG_MSK_RANKCTL_DIFF_RANK_WR_GAP;
   wire [REG_WIDTH-1:0] umctl2_regs_rankctl_max_rank_wr_mask;
   assign umctl2_regs_rankctl_max_rank_wr_mask = `UMCTL2_REG_MSK_RANKCTL_MAX_RANK_WR;
   wire [REG_WIDTH-1:0] umctl2_regs_rankctl_diff_rank_rd_gap_msb_mask;
   assign umctl2_regs_rankctl_diff_rank_rd_gap_msb_mask = `UMCTL2_REG_MSK_RANKCTL_DIFF_RANK_RD_GAP_MSB;
   wire [REG_WIDTH-1:0] umctl2_regs_rankctl_diff_rank_wr_gap_msb_mask;
   assign umctl2_regs_rankctl_diff_rank_wr_gap_msb_mask = `UMCTL2_REG_MSK_RANKCTL_DIFF_RANK_WR_GAP_MSB;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg0_t_ras_min_mask;
   assign umctl2_regs_dramtmg0_t_ras_min_mask = `UMCTL2_REG_MSK_DRAMTMG0_T_RAS_MIN;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg0_t_ras_max_mask;
   assign umctl2_regs_dramtmg0_t_ras_max_mask = `UMCTL2_REG_MSK_DRAMTMG0_T_RAS_MAX;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg0_t_faw_mask;
   assign umctl2_regs_dramtmg0_t_faw_mask = `UMCTL2_REG_MSK_DRAMTMG0_T_FAW;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg0_wr2pre_mask;
   assign umctl2_regs_dramtmg0_wr2pre_mask = `UMCTL2_REG_MSK_DRAMTMG0_WR2PRE;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg1_t_rc_mask;
   assign umctl2_regs_dramtmg1_t_rc_mask = `UMCTL2_REG_MSK_DRAMTMG1_T_RC;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg1_rd2pre_mask;
   assign umctl2_regs_dramtmg1_rd2pre_mask = `UMCTL2_REG_MSK_DRAMTMG1_RD2PRE;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg1_t_xp_mask;
   assign umctl2_regs_dramtmg1_t_xp_mask = `UMCTL2_REG_MSK_DRAMTMG1_T_XP;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg2_wr2rd_mask;
   assign umctl2_regs_dramtmg2_wr2rd_mask = `UMCTL2_REG_MSK_DRAMTMG2_WR2RD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg2_rd2wr_mask;
   assign umctl2_regs_dramtmg2_rd2wr_mask = `UMCTL2_REG_MSK_DRAMTMG2_RD2WR;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg2_read_latency_mask;
   assign umctl2_regs_dramtmg2_read_latency_mask = `UMCTL2_REG_MSK_DRAMTMG2_READ_LATENCY;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg2_write_latency_mask;
   assign umctl2_regs_dramtmg2_write_latency_mask = `UMCTL2_REG_MSK_DRAMTMG2_WRITE_LATENCY;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg3_t_mod_mask;
   assign umctl2_regs_dramtmg3_t_mod_mask = `UMCTL2_REG_MSK_DRAMTMG3_T_MOD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg3_t_mrd_mask;
   assign umctl2_regs_dramtmg3_t_mrd_mask = `UMCTL2_REG_MSK_DRAMTMG3_T_MRD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg4_t_rp_mask;
   assign umctl2_regs_dramtmg4_t_rp_mask = `UMCTL2_REG_MSK_DRAMTMG4_T_RP;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg4_t_rrd_mask;
   assign umctl2_regs_dramtmg4_t_rrd_mask = `UMCTL2_REG_MSK_DRAMTMG4_T_RRD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg4_t_ccd_mask;
   assign umctl2_regs_dramtmg4_t_ccd_mask = `UMCTL2_REG_MSK_DRAMTMG4_T_CCD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg4_t_rcd_mask;
   assign umctl2_regs_dramtmg4_t_rcd_mask = `UMCTL2_REG_MSK_DRAMTMG4_T_RCD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg5_t_cke_mask;
   assign umctl2_regs_dramtmg5_t_cke_mask = `UMCTL2_REG_MSK_DRAMTMG5_T_CKE;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg5_t_ckesr_mask;
   assign umctl2_regs_dramtmg5_t_ckesr_mask = `UMCTL2_REG_MSK_DRAMTMG5_T_CKESR;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg5_t_cksre_mask;
   assign umctl2_regs_dramtmg5_t_cksre_mask = `UMCTL2_REG_MSK_DRAMTMG5_T_CKSRE;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg5_t_cksrx_mask;
   assign umctl2_regs_dramtmg5_t_cksrx_mask = `UMCTL2_REG_MSK_DRAMTMG5_T_CKSRX;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg8_t_xs_x32_mask;
   assign umctl2_regs_dramtmg8_t_xs_x32_mask = `UMCTL2_REG_MSK_DRAMTMG8_T_XS_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg8_t_xs_dll_x32_mask;
   assign umctl2_regs_dramtmg8_t_xs_dll_x32_mask = `UMCTL2_REG_MSK_DRAMTMG8_T_XS_DLL_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg8_t_xs_abort_x32_mask;
   assign umctl2_regs_dramtmg8_t_xs_abort_x32_mask = `UMCTL2_REG_MSK_DRAMTMG8_T_XS_ABORT_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg8_t_xs_fast_x32_mask;
   assign umctl2_regs_dramtmg8_t_xs_fast_x32_mask = `UMCTL2_REG_MSK_DRAMTMG8_T_XS_FAST_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg9_wr2rd_s_mask;
   assign umctl2_regs_dramtmg9_wr2rd_s_mask = `UMCTL2_REG_MSK_DRAMTMG9_WR2RD_S;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg9_t_rrd_s_mask;
   assign umctl2_regs_dramtmg9_t_rrd_s_mask = `UMCTL2_REG_MSK_DRAMTMG9_T_RRD_S;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg9_t_ccd_s_mask;
   assign umctl2_regs_dramtmg9_t_ccd_s_mask = `UMCTL2_REG_MSK_DRAMTMG9_T_CCD_S;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg9_ddr4_wr_preamble_mask;
   assign umctl2_regs_dramtmg9_ddr4_wr_preamble_mask = `UMCTL2_REG_MSK_DRAMTMG9_DDR4_WR_PREAMBLE;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg10_t_gear_hold_mask;
   assign umctl2_regs_dramtmg10_t_gear_hold_mask = `UMCTL2_REG_MSK_DRAMTMG10_T_GEAR_HOLD;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg10_t_gear_setup_mask;
   assign umctl2_regs_dramtmg10_t_gear_setup_mask = `UMCTL2_REG_MSK_DRAMTMG10_T_GEAR_SETUP;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg10_t_cmd_gear_mask;
   assign umctl2_regs_dramtmg10_t_cmd_gear_mask = `UMCTL2_REG_MSK_DRAMTMG10_T_CMD_GEAR;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg10_t_sync_gear_mask;
   assign umctl2_regs_dramtmg10_t_sync_gear_mask = `UMCTL2_REG_MSK_DRAMTMG10_T_SYNC_GEAR;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg11_t_ckmpe_mask;
   assign umctl2_regs_dramtmg11_t_ckmpe_mask = `UMCTL2_REG_MSK_DRAMTMG11_T_CKMPE;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg11_t_mpx_s_mask;
   assign umctl2_regs_dramtmg11_t_mpx_s_mask = `UMCTL2_REG_MSK_DRAMTMG11_T_MPX_S;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg11_t_mpx_lh_mask;
   assign umctl2_regs_dramtmg11_t_mpx_lh_mask = `UMCTL2_REG_MSK_DRAMTMG11_T_MPX_LH;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg11_post_mpsm_gap_x32_mask;
   assign umctl2_regs_dramtmg11_post_mpsm_gap_x32_mask = `UMCTL2_REG_MSK_DRAMTMG11_POST_MPSM_GAP_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg12_t_mrd_pda_mask;
   assign umctl2_regs_dramtmg12_t_mrd_pda_mask = `UMCTL2_REG_MSK_DRAMTMG12_T_MRD_PDA;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg12_t_wr_mpr_mask;
   assign umctl2_regs_dramtmg12_t_wr_mpr_mask = `UMCTL2_REG_MSK_DRAMTMG12_T_WR_MPR;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg15_t_stab_x32_mask;
   assign umctl2_regs_dramtmg15_t_stab_x32_mask = `UMCTL2_REG_MSK_DRAMTMG15_T_STAB_X32;
   wire [REG_WIDTH-1:0] umctl2_regs_dramtmg15_en_dfi_lp_t_stab_mask;
   assign umctl2_regs_dramtmg15_en_dfi_lp_t_stab_mask = `UMCTL2_REG_MSK_DRAMTMG15_EN_DFI_LP_T_STAB;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl0_t_zq_short_nop_mask;
   assign umctl2_regs_zqctl0_t_zq_short_nop_mask = `UMCTL2_REG_MSK_ZQCTL0_T_ZQ_SHORT_NOP;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl0_t_zq_long_nop_mask;
   assign umctl2_regs_zqctl0_t_zq_long_nop_mask = `UMCTL2_REG_MSK_ZQCTL0_T_ZQ_LONG_NOP;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl0_dis_mpsmx_zqcl_mask;
   assign umctl2_regs_zqctl0_dis_mpsmx_zqcl_mask = `UMCTL2_REG_MSK_ZQCTL0_DIS_MPSMX_ZQCL;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl0_zq_resistor_shared_mask;
   assign umctl2_regs_zqctl0_zq_resistor_shared_mask = `UMCTL2_REG_MSK_ZQCTL0_ZQ_RESISTOR_SHARED;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl0_dis_srx_zqcl_mask;
   assign umctl2_regs_zqctl0_dis_srx_zqcl_mask = `UMCTL2_REG_MSK_ZQCTL0_DIS_SRX_ZQCL;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl0_dis_auto_zq_mask;
   assign umctl2_regs_zqctl0_dis_auto_zq_mask = `UMCTL2_REG_MSK_ZQCTL0_DIS_AUTO_ZQ;
   wire [REG_WIDTH-1:0] umctl2_regs_zqctl1_t_zq_short_interval_x1024_mask;
   assign umctl2_regs_zqctl1_t_zq_short_interval_x1024_mask = `UMCTL2_REG_MSK_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg0_dfi_tphy_wrlat_mask;
   assign umctl2_regs_dfitmg0_dfi_tphy_wrlat_mask = `UMCTL2_REG_MSK_DFITMG0_DFI_TPHY_WRLAT;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg0_dfi_tphy_wrdata_mask;
   assign umctl2_regs_dfitmg0_dfi_tphy_wrdata_mask = `UMCTL2_REG_MSK_DFITMG0_DFI_TPHY_WRDATA;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg0_dfi_wrdata_use_dfi_phy_clk_mask;
   assign umctl2_regs_dfitmg0_dfi_wrdata_use_dfi_phy_clk_mask = `UMCTL2_REG_MSK_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg0_dfi_t_rddata_en_mask;
   assign umctl2_regs_dfitmg0_dfi_t_rddata_en_mask = `UMCTL2_REG_MSK_DFITMG0_DFI_T_RDDATA_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg0_dfi_rddata_use_dfi_phy_clk_mask;
   assign umctl2_regs_dfitmg0_dfi_rddata_use_dfi_phy_clk_mask = `UMCTL2_REG_MSK_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg0_dfi_t_ctrl_delay_mask;
   assign umctl2_regs_dfitmg0_dfi_t_ctrl_delay_mask = `UMCTL2_REG_MSK_DFITMG0_DFI_T_CTRL_DELAY;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg1_dfi_t_dram_clk_enable_mask;
   assign umctl2_regs_dfitmg1_dfi_t_dram_clk_enable_mask = `UMCTL2_REG_MSK_DFITMG1_DFI_T_DRAM_CLK_ENABLE;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg1_dfi_t_dram_clk_disable_mask;
   assign umctl2_regs_dfitmg1_dfi_t_dram_clk_disable_mask = `UMCTL2_REG_MSK_DFITMG1_DFI_T_DRAM_CLK_DISABLE;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg1_dfi_t_wrdata_delay_mask;
   assign umctl2_regs_dfitmg1_dfi_t_wrdata_delay_mask = `UMCTL2_REG_MSK_DFITMG1_DFI_T_WRDATA_DELAY;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg1_dfi_t_parin_lat_mask;
   assign umctl2_regs_dfitmg1_dfi_t_parin_lat_mask = `UMCTL2_REG_MSK_DFITMG1_DFI_T_PARIN_LAT;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg1_dfi_t_cmd_lat_mask;
   assign umctl2_regs_dfitmg1_dfi_t_cmd_lat_mask = `UMCTL2_REG_MSK_DFITMG1_DFI_T_CMD_LAT;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg0_dfi_lp_en_pd_mask;
   assign umctl2_regs_dfilpcfg0_dfi_lp_en_pd_mask = `UMCTL2_REG_MSK_DFILPCFG0_DFI_LP_EN_PD;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg0_dfi_lp_wakeup_pd_mask;
   assign umctl2_regs_dfilpcfg0_dfi_lp_wakeup_pd_mask = `UMCTL2_REG_MSK_DFILPCFG0_DFI_LP_WAKEUP_PD;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg0_dfi_lp_en_sr_mask;
   assign umctl2_regs_dfilpcfg0_dfi_lp_en_sr_mask = `UMCTL2_REG_MSK_DFILPCFG0_DFI_LP_EN_SR;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg0_dfi_lp_wakeup_sr_mask;
   assign umctl2_regs_dfilpcfg0_dfi_lp_wakeup_sr_mask = `UMCTL2_REG_MSK_DFILPCFG0_DFI_LP_WAKEUP_SR;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg0_dfi_tlp_resp_mask;
   assign umctl2_regs_dfilpcfg0_dfi_tlp_resp_mask = `UMCTL2_REG_MSK_DFILPCFG0_DFI_TLP_RESP;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg1_dfi_lp_en_mpsm_mask;
   assign umctl2_regs_dfilpcfg1_dfi_lp_en_mpsm_mask = `UMCTL2_REG_MSK_DFILPCFG1_DFI_LP_EN_MPSM;
   wire [REG_WIDTH-1:0] umctl2_regs_dfilpcfg1_dfi_lp_wakeup_mpsm_mask;
   assign umctl2_regs_dfilpcfg1_dfi_lp_wakeup_mpsm_mask = `UMCTL2_REG_MSK_DFILPCFG1_DFI_LP_WAKEUP_MPSM;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd0_dfi_t_ctrlup_min_mask;
   assign umctl2_regs_dfiupd0_dfi_t_ctrlup_min_mask = `UMCTL2_REG_MSK_DFIUPD0_DFI_T_CTRLUP_MIN;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd0_dfi_t_ctrlup_max_mask;
   assign umctl2_regs_dfiupd0_dfi_t_ctrlup_max_mask = `UMCTL2_REG_MSK_DFIUPD0_DFI_T_CTRLUP_MAX;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd0_ctrlupd_pre_srx_mask;
   assign umctl2_regs_dfiupd0_ctrlupd_pre_srx_mask = `UMCTL2_REG_MSK_DFIUPD0_CTRLUPD_PRE_SRX;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd0_dis_auto_ctrlupd_srx_mask;
   assign umctl2_regs_dfiupd0_dis_auto_ctrlupd_srx_mask = `UMCTL2_REG_MSK_DFIUPD0_DIS_AUTO_CTRLUPD_SRX;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd0_dis_auto_ctrlupd_mask;
   assign umctl2_regs_dfiupd0_dis_auto_ctrlupd_mask = `UMCTL2_REG_MSK_DFIUPD0_DIS_AUTO_CTRLUPD;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd1_dfi_t_ctrlupd_interval_max_x1024_mask;
   assign umctl2_regs_dfiupd1_dfi_t_ctrlupd_interval_max_x1024_mask = `UMCTL2_REG_MSK_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd1_dfi_t_ctrlupd_interval_min_x1024_mask;
   assign umctl2_regs_dfiupd1_dfi_t_ctrlupd_interval_min_x1024_mask = `UMCTL2_REG_MSK_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiupd2_dfi_phyupd_en_mask;
   assign umctl2_regs_dfiupd2_dfi_phyupd_en_mask = `UMCTL2_REG_MSK_DFIUPD2_DFI_PHYUPD_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dfimisc_dfi_init_complete_en_mask;
   assign umctl2_regs_dfimisc_dfi_init_complete_en_mask = `UMCTL2_REG_MSK_DFIMISC_DFI_INIT_COMPLETE_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dfimisc_phy_dbi_mode_mask;
   assign umctl2_regs_dfimisc_phy_dbi_mode_mask = `UMCTL2_REG_MSK_DFIMISC_PHY_DBI_MODE;
   wire [REG_WIDTH-1:0] umctl2_regs_dfimisc_ctl_idle_en_mask;
   assign umctl2_regs_dfimisc_ctl_idle_en_mask = `UMCTL2_REG_MSK_DFIMISC_CTL_IDLE_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dfimisc_dfi_init_start_mask;
   assign umctl2_regs_dfimisc_dfi_init_start_mask = `UMCTL2_REG_MSK_DFIMISC_DFI_INIT_START;
   wire [REG_WIDTH-1:0] umctl2_regs_dfimisc_dis_dyn_adr_tri_mask;
   assign umctl2_regs_dfimisc_dis_dyn_adr_tri_mask = `UMCTL2_REG_MSK_DFIMISC_DIS_DYN_ADR_TRI;
   wire [REG_WIDTH-1:0] umctl2_regs_dfimisc_dfi_frequency_mask;
   assign umctl2_regs_dfimisc_dfi_frequency_mask = `UMCTL2_REG_MSK_DFIMISC_DFI_FREQUENCY;
   wire [REG_WIDTH-1:0] umctl2_regs_dfitmg3_dfi_t_geardown_delay_mask;
   assign umctl2_regs_dfitmg3_dfi_t_geardown_delay_mask = `UMCTL2_REG_MSK_DFITMG3_DFI_T_GEARDOWN_DELAY;
   wire [REG_WIDTH-1:0] umctl2_regs_dbictl_dm_en_mask;
   assign umctl2_regs_dbictl_dm_en_mask = `UMCTL2_REG_MSK_DBICTL_DM_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dbictl_wr_dbi_en_mask;
   assign umctl2_regs_dbictl_wr_dbi_en_mask = `UMCTL2_REG_MSK_DBICTL_WR_DBI_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dbictl_rd_dbi_en_mask;
   assign umctl2_regs_dbictl_rd_dbi_en_mask = `UMCTL2_REG_MSK_DBICTL_RD_DBI_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_dfiphymstr_dfi_phymstr_en_mask;
   assign umctl2_regs_dfiphymstr_dfi_phymstr_en_mask = `UMCTL2_REG_MSK_DFIPHYMSTR_DFI_PHYMSTR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap0_addrmap_cs_bit0_mask;
   assign umctl2_regs_addrmap0_addrmap_cs_bit0_mask = `UMCTL2_REG_MSK_ADDRMAP0_ADDRMAP_CS_BIT0;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap1_addrmap_bank_b0_mask;
   assign umctl2_regs_addrmap1_addrmap_bank_b0_mask = `UMCTL2_REG_MSK_ADDRMAP1_ADDRMAP_BANK_B0;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap1_addrmap_bank_b1_mask;
   assign umctl2_regs_addrmap1_addrmap_bank_b1_mask = `UMCTL2_REG_MSK_ADDRMAP1_ADDRMAP_BANK_B1;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap1_addrmap_bank_b2_mask;
   assign umctl2_regs_addrmap1_addrmap_bank_b2_mask = `UMCTL2_REG_MSK_ADDRMAP1_ADDRMAP_BANK_B2;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap2_addrmap_col_b2_mask;
   assign umctl2_regs_addrmap2_addrmap_col_b2_mask = `UMCTL2_REG_MSK_ADDRMAP2_ADDRMAP_COL_B2;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap2_addrmap_col_b3_mask;
   assign umctl2_regs_addrmap2_addrmap_col_b3_mask = `UMCTL2_REG_MSK_ADDRMAP2_ADDRMAP_COL_B3;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap2_addrmap_col_b4_mask;
   assign umctl2_regs_addrmap2_addrmap_col_b4_mask = `UMCTL2_REG_MSK_ADDRMAP2_ADDRMAP_COL_B4;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap2_addrmap_col_b5_mask;
   assign umctl2_regs_addrmap2_addrmap_col_b5_mask = `UMCTL2_REG_MSK_ADDRMAP2_ADDRMAP_COL_B5;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap3_addrmap_col_b6_mask;
   assign umctl2_regs_addrmap3_addrmap_col_b6_mask = `UMCTL2_REG_MSK_ADDRMAP3_ADDRMAP_COL_B6;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap3_addrmap_col_b7_mask;
   assign umctl2_regs_addrmap3_addrmap_col_b7_mask = `UMCTL2_REG_MSK_ADDRMAP3_ADDRMAP_COL_B7;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap3_addrmap_col_b8_mask;
   assign umctl2_regs_addrmap3_addrmap_col_b8_mask = `UMCTL2_REG_MSK_ADDRMAP3_ADDRMAP_COL_B8;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap3_addrmap_col_b9_mask;
   assign umctl2_regs_addrmap3_addrmap_col_b9_mask = `UMCTL2_REG_MSK_ADDRMAP3_ADDRMAP_COL_B9;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap4_addrmap_col_b10_mask;
   assign umctl2_regs_addrmap4_addrmap_col_b10_mask = `UMCTL2_REG_MSK_ADDRMAP4_ADDRMAP_COL_B10;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap4_addrmap_col_b11_mask;
   assign umctl2_regs_addrmap4_addrmap_col_b11_mask = `UMCTL2_REG_MSK_ADDRMAP4_ADDRMAP_COL_B11;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap5_addrmap_row_b0_mask;
   assign umctl2_regs_addrmap5_addrmap_row_b0_mask = `UMCTL2_REG_MSK_ADDRMAP5_ADDRMAP_ROW_B0;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap5_addrmap_row_b1_mask;
   assign umctl2_regs_addrmap5_addrmap_row_b1_mask = `UMCTL2_REG_MSK_ADDRMAP5_ADDRMAP_ROW_B1;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap5_addrmap_row_b2_10_mask;
   assign umctl2_regs_addrmap5_addrmap_row_b2_10_mask = `UMCTL2_REG_MSK_ADDRMAP5_ADDRMAP_ROW_B2_10;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap5_addrmap_row_b11_mask;
   assign umctl2_regs_addrmap5_addrmap_row_b11_mask = `UMCTL2_REG_MSK_ADDRMAP5_ADDRMAP_ROW_B11;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap6_addrmap_row_b12_mask;
   assign umctl2_regs_addrmap6_addrmap_row_b12_mask = `UMCTL2_REG_MSK_ADDRMAP6_ADDRMAP_ROW_B12;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap6_addrmap_row_b13_mask;
   assign umctl2_regs_addrmap6_addrmap_row_b13_mask = `UMCTL2_REG_MSK_ADDRMAP6_ADDRMAP_ROW_B13;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap6_addrmap_row_b14_mask;
   assign umctl2_regs_addrmap6_addrmap_row_b14_mask = `UMCTL2_REG_MSK_ADDRMAP6_ADDRMAP_ROW_B14;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap6_addrmap_row_b15_mask;
   assign umctl2_regs_addrmap6_addrmap_row_b15_mask = `UMCTL2_REG_MSK_ADDRMAP6_ADDRMAP_ROW_B15;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap7_addrmap_row_b16_mask;
   assign umctl2_regs_addrmap7_addrmap_row_b16_mask = `UMCTL2_REG_MSK_ADDRMAP7_ADDRMAP_ROW_B16;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap7_addrmap_row_b17_mask;
   assign umctl2_regs_addrmap7_addrmap_row_b17_mask = `UMCTL2_REG_MSK_ADDRMAP7_ADDRMAP_ROW_B17;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap8_addrmap_bg_b0_mask;
   assign umctl2_regs_addrmap8_addrmap_bg_b0_mask = `UMCTL2_REG_MSK_ADDRMAP8_ADDRMAP_BG_B0;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap8_addrmap_bg_b1_mask;
   assign umctl2_regs_addrmap8_addrmap_bg_b1_mask = `UMCTL2_REG_MSK_ADDRMAP8_ADDRMAP_BG_B1;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap9_addrmap_row_b2_mask;
   assign umctl2_regs_addrmap9_addrmap_row_b2_mask = `UMCTL2_REG_MSK_ADDRMAP9_ADDRMAP_ROW_B2;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap9_addrmap_row_b3_mask;
   assign umctl2_regs_addrmap9_addrmap_row_b3_mask = `UMCTL2_REG_MSK_ADDRMAP9_ADDRMAP_ROW_B3;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap9_addrmap_row_b4_mask;
   assign umctl2_regs_addrmap9_addrmap_row_b4_mask = `UMCTL2_REG_MSK_ADDRMAP9_ADDRMAP_ROW_B4;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap9_addrmap_row_b5_mask;
   assign umctl2_regs_addrmap9_addrmap_row_b5_mask = `UMCTL2_REG_MSK_ADDRMAP9_ADDRMAP_ROW_B5;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap10_addrmap_row_b6_mask;
   assign umctl2_regs_addrmap10_addrmap_row_b6_mask = `UMCTL2_REG_MSK_ADDRMAP10_ADDRMAP_ROW_B6;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap10_addrmap_row_b7_mask;
   assign umctl2_regs_addrmap10_addrmap_row_b7_mask = `UMCTL2_REG_MSK_ADDRMAP10_ADDRMAP_ROW_B7;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap10_addrmap_row_b8_mask;
   assign umctl2_regs_addrmap10_addrmap_row_b8_mask = `UMCTL2_REG_MSK_ADDRMAP10_ADDRMAP_ROW_B8;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap10_addrmap_row_b9_mask;
   assign umctl2_regs_addrmap10_addrmap_row_b9_mask = `UMCTL2_REG_MSK_ADDRMAP10_ADDRMAP_ROW_B9;
   wire [REG_WIDTH-1:0] umctl2_regs_addrmap11_addrmap_row_b10_mask;
   assign umctl2_regs_addrmap11_addrmap_row_b10_mask = `UMCTL2_REG_MSK_ADDRMAP11_ADDRMAP_ROW_B10;
   wire [REG_WIDTH-1:0] umctl2_regs_odtcfg_rd_odt_delay_mask;
   assign umctl2_regs_odtcfg_rd_odt_delay_mask = `UMCTL2_REG_MSK_ODTCFG_RD_ODT_DELAY;
   wire [REG_WIDTH-1:0] umctl2_regs_odtcfg_rd_odt_hold_mask;
   assign umctl2_regs_odtcfg_rd_odt_hold_mask = `UMCTL2_REG_MSK_ODTCFG_RD_ODT_HOLD;
   wire [REG_WIDTH-1:0] umctl2_regs_odtcfg_wr_odt_delay_mask;
   assign umctl2_regs_odtcfg_wr_odt_delay_mask = `UMCTL2_REG_MSK_ODTCFG_WR_ODT_DELAY;
   wire [REG_WIDTH-1:0] umctl2_regs_odtcfg_wr_odt_hold_mask;
   assign umctl2_regs_odtcfg_wr_odt_hold_mask = `UMCTL2_REG_MSK_ODTCFG_WR_ODT_HOLD;
   wire [REG_WIDTH-1:0] umctl2_regs_odtmap_rank0_wr_odt_mask;
   assign umctl2_regs_odtmap_rank0_wr_odt_mask = `UMCTL2_REG_MSK_ODTMAP_RANK0_WR_ODT;
   wire [REG_WIDTH-1:0] umctl2_regs_odtmap_rank0_rd_odt_mask;
   assign umctl2_regs_odtmap_rank0_rd_odt_mask = `UMCTL2_REG_MSK_ODTMAP_RANK0_RD_ODT;
   wire [REG_WIDTH-1:0] umctl2_regs_odtmap_rank1_wr_odt_mask;
   assign umctl2_regs_odtmap_rank1_wr_odt_mask = `UMCTL2_REG_MSK_ODTMAP_RANK1_WR_ODT;
   wire [REG_WIDTH-1:0] umctl2_regs_odtmap_rank1_rd_odt_mask;
   assign umctl2_regs_odtmap_rank1_rd_odt_mask = `UMCTL2_REG_MSK_ODTMAP_RANK1_RD_ODT;
   wire [REG_WIDTH-1:0] umctl2_regs_sched_prefer_write_mask;
   assign umctl2_regs_sched_prefer_write_mask = `UMCTL2_REG_MSK_SCHED_PREFER_WRITE;
   wire [REG_WIDTH-1:0] umctl2_regs_sched_pageclose_mask;
   assign umctl2_regs_sched_pageclose_mask = `UMCTL2_REG_MSK_SCHED_PAGECLOSE;
   wire [REG_WIDTH-1:0] umctl2_regs_sched_autopre_rmw_mask;
   assign umctl2_regs_sched_autopre_rmw_mask = `UMCTL2_REG_MSK_SCHED_AUTOPRE_RMW;
   wire [REG_WIDTH-1:0] umctl2_regs_sched_lpr_num_entries_mask;
   assign umctl2_regs_sched_lpr_num_entries_mask = `UMCTL2_REG_MSK_SCHED_LPR_NUM_ENTRIES;
   wire [REG_WIDTH-1:0] umctl2_regs_sched_go2critical_hysteresis_mask;
   assign umctl2_regs_sched_go2critical_hysteresis_mask = `UMCTL2_REG_MSK_SCHED_GO2CRITICAL_HYSTERESIS;
   wire [REG_WIDTH-1:0] umctl2_regs_sched_rdwr_idle_gap_mask;
   assign umctl2_regs_sched_rdwr_idle_gap_mask = `UMCTL2_REG_MSK_SCHED_RDWR_IDLE_GAP;
   wire [REG_WIDTH-1:0] umctl2_regs_sched1_pageclose_timer_mask;
   assign umctl2_regs_sched1_pageclose_timer_mask = `UMCTL2_REG_MSK_SCHED1_PAGECLOSE_TIMER;
   wire [REG_WIDTH-1:0] umctl2_regs_perfhpr1_hpr_max_starve_mask;
   assign umctl2_regs_perfhpr1_hpr_max_starve_mask = `UMCTL2_REG_MSK_PERFHPR1_HPR_MAX_STARVE;
   wire [REG_WIDTH-1:0] umctl2_regs_perfhpr1_hpr_xact_run_length_mask;
   assign umctl2_regs_perfhpr1_hpr_xact_run_length_mask = `UMCTL2_REG_MSK_PERFHPR1_HPR_XACT_RUN_LENGTH;
   wire [REG_WIDTH-1:0] umctl2_regs_perflpr1_lpr_max_starve_mask;
   assign umctl2_regs_perflpr1_lpr_max_starve_mask = `UMCTL2_REG_MSK_PERFLPR1_LPR_MAX_STARVE;
   wire [REG_WIDTH-1:0] umctl2_regs_perflpr1_lpr_xact_run_length_mask;
   assign umctl2_regs_perflpr1_lpr_xact_run_length_mask = `UMCTL2_REG_MSK_PERFLPR1_LPR_XACT_RUN_LENGTH;
   wire [REG_WIDTH-1:0] umctl2_regs_perfwr1_w_max_starve_mask;
   assign umctl2_regs_perfwr1_w_max_starve_mask = `UMCTL2_REG_MSK_PERFWR1_W_MAX_STARVE;
   wire [REG_WIDTH-1:0] umctl2_regs_perfwr1_w_xact_run_length_mask;
   assign umctl2_regs_perfwr1_w_xact_run_length_mask = `UMCTL2_REG_MSK_PERFWR1_W_XACT_RUN_LENGTH;
   wire [REG_WIDTH-1:0] umctl2_regs_dbg0_dis_wc_mask;
   assign umctl2_regs_dbg0_dis_wc_mask = `UMCTL2_REG_MSK_DBG0_DIS_WC;
   wire [REG_WIDTH-1:0] umctl2_regs_dbg0_dis_collision_page_opt_mask;
   assign umctl2_regs_dbg0_dis_collision_page_opt_mask = `UMCTL2_REG_MSK_DBG0_DIS_COLLISION_PAGE_OPT;
   wire [REG_WIDTH-1:0] umctl2_regs_dbg0_dis_max_rank_rd_opt_mask;
   assign umctl2_regs_dbg0_dis_max_rank_rd_opt_mask = `UMCTL2_REG_MSK_DBG0_DIS_MAX_RANK_RD_OPT;
   wire [REG_WIDTH-1:0] umctl2_regs_dbg0_dis_max_rank_wr_opt_mask;
   assign umctl2_regs_dbg0_dis_max_rank_wr_opt_mask = `UMCTL2_REG_MSK_DBG0_DIS_MAX_RANK_WR_OPT;
   wire [REG_WIDTH-1:0] umctl2_regs_dbg1_dis_dq_mask;
   assign umctl2_regs_dbg1_dis_dq_mask = `UMCTL2_REG_MSK_DBG1_DIS_DQ;
   wire [REG_WIDTH-1:0] umctl2_regs_dbg1_dis_hif_mask;
   assign umctl2_regs_dbg1_dis_hif_mask = `UMCTL2_REG_MSK_DBG1_DIS_HIF;
   wire [REG_WIDTH-1:0] umctl2_regs_dbgcmd_rank0_refresh_mask;
   assign umctl2_regs_dbgcmd_rank0_refresh_mask = `UMCTL2_REG_MSK_DBGCMD_RANK0_REFRESH;
   wire [REG_WIDTH-1:0] umctl2_regs_dbgcmd_rank1_refresh_mask;
   assign umctl2_regs_dbgcmd_rank1_refresh_mask = `UMCTL2_REG_MSK_DBGCMD_RANK1_REFRESH;
   wire [REG_WIDTH-1:0] umctl2_regs_dbgcmd_zq_calib_short_mask;
   assign umctl2_regs_dbgcmd_zq_calib_short_mask = `UMCTL2_REG_MSK_DBGCMD_ZQ_CALIB_SHORT;
   wire [REG_WIDTH-1:0] umctl2_regs_dbgcmd_ctrlupd_mask;
   assign umctl2_regs_dbgcmd_ctrlupd_mask = `UMCTL2_REG_MSK_DBGCMD_CTRLUPD;
   wire [REG_WIDTH-1:0] umctl2_regs_swctl_sw_done_mask;
   assign umctl2_regs_swctl_sw_done_mask = `UMCTL2_REG_MSK_SWCTL_SW_DONE;
   wire [REG_WIDTH-1:0] umctl2_regs_swctlstatic_sw_static_unlock_mask;
   assign umctl2_regs_swctlstatic_sw_static_unlock_mask = `UMCTL2_REG_MSK_SWCTLSTATIC_SW_STATIC_UNLOCK;
   wire [REG_WIDTH-1:0] umctl2_regs_poisoncfg_wr_poison_slverr_en_mask;
   assign umctl2_regs_poisoncfg_wr_poison_slverr_en_mask = `UMCTL2_REG_MSK_POISONCFG_WR_POISON_SLVERR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_poisoncfg_wr_poison_intr_en_mask;
   assign umctl2_regs_poisoncfg_wr_poison_intr_en_mask = `UMCTL2_REG_MSK_POISONCFG_WR_POISON_INTR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_poisoncfg_wr_poison_intr_clr_mask;
   assign umctl2_regs_poisoncfg_wr_poison_intr_clr_mask = `UMCTL2_REG_MSK_POISONCFG_WR_POISON_INTR_CLR;
   wire [REG_WIDTH-1:0] umctl2_regs_poisoncfg_rd_poison_slverr_en_mask;
   assign umctl2_regs_poisoncfg_rd_poison_slverr_en_mask = `UMCTL2_REG_MSK_POISONCFG_RD_POISON_SLVERR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_poisoncfg_rd_poison_intr_en_mask;
   assign umctl2_regs_poisoncfg_rd_poison_intr_en_mask = `UMCTL2_REG_MSK_POISONCFG_RD_POISON_INTR_EN;
   wire [REG_WIDTH-1:0] umctl2_regs_poisoncfg_rd_poison_intr_clr_mask;
   assign umctl2_regs_poisoncfg_rd_poison_intr_clr_mask = `UMCTL2_REG_MSK_POISONCFG_RD_POISON_INTR_CLR;
   wire [REG_WIDTH-1:0] umctl2_mp_pccfg_go2critical_en_mask;
   assign umctl2_mp_pccfg_go2critical_en_mask = `UMCTL2_REG_MSK_PCCFG_GO2CRITICAL_EN;
   wire [REG_WIDTH-1:0] umctl2_mp_pccfg_pagematch_limit_mask;
   assign umctl2_mp_pccfg_pagematch_limit_mask = `UMCTL2_REG_MSK_PCCFG_PAGEMATCH_LIMIT;
   wire [REG_WIDTH-1:0] umctl2_mp_pccfg_bl_exp_mode_mask;
   assign umctl2_mp_pccfg_bl_exp_mode_mask = `UMCTL2_REG_MSK_PCCFG_BL_EXP_MODE;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgr_0_rd_port_priority_0_mask;
   assign umctl2_mp_pcfgr_0_rd_port_priority_0_mask = `UMCTL2_REG_MSK_PCFGR_0_RD_PORT_PRIORITY_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgr_0_rd_port_aging_en_0_mask;
   assign umctl2_mp_pcfgr_0_rd_port_aging_en_0_mask = `UMCTL2_REG_MSK_PCFGR_0_RD_PORT_AGING_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgr_0_rd_port_urgent_en_0_mask;
   assign umctl2_mp_pcfgr_0_rd_port_urgent_en_0_mask = `UMCTL2_REG_MSK_PCFGR_0_RD_PORT_URGENT_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgr_0_rd_port_pagematch_en_0_mask;
   assign umctl2_mp_pcfgr_0_rd_port_pagematch_en_0_mask = `UMCTL2_REG_MSK_PCFGR_0_RD_PORT_PAGEMATCH_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgw_0_wr_port_priority_0_mask;
   assign umctl2_mp_pcfgw_0_wr_port_priority_0_mask = `UMCTL2_REG_MSK_PCFGW_0_WR_PORT_PRIORITY_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgw_0_wr_port_aging_en_0_mask;
   assign umctl2_mp_pcfgw_0_wr_port_aging_en_0_mask = `UMCTL2_REG_MSK_PCFGW_0_WR_PORT_AGING_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgw_0_wr_port_urgent_en_0_mask;
   assign umctl2_mp_pcfgw_0_wr_port_urgent_en_0_mask = `UMCTL2_REG_MSK_PCFGW_0_WR_PORT_URGENT_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgw_0_wr_port_pagematch_en_0_mask;
   assign umctl2_mp_pcfgw_0_wr_port_pagematch_en_0_mask = `UMCTL2_REG_MSK_PCFGW_0_WR_PORT_PAGEMATCH_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pctrl_0_port_en_0_mask;
   assign umctl2_mp_pctrl_0_port_en_0_mask = `UMCTL2_REG_MSK_PCTRL_0_PORT_EN_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgqos0_0_rqos_map_level1_0_mask;
   assign umctl2_mp_pcfgqos0_0_rqos_map_level1_0_mask = `UMCTL2_REG_MSK_PCFGQOS0_0_RQOS_MAP_LEVEL1_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgqos0_0_rqos_map_region0_0_mask;
   assign umctl2_mp_pcfgqos0_0_rqos_map_region0_0_mask = `UMCTL2_REG_MSK_PCFGQOS0_0_RQOS_MAP_REGION0_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgqos0_0_rqos_map_region1_0_mask;
   assign umctl2_mp_pcfgqos0_0_rqos_map_region1_0_mask = `UMCTL2_REG_MSK_PCFGQOS0_0_RQOS_MAP_REGION1_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgqos1_0_rqos_map_timeoutb_0_mask;
   assign umctl2_mp_pcfgqos1_0_rqos_map_timeoutb_0_mask = `UMCTL2_REG_MSK_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgqos1_0_rqos_map_timeoutr_0_mask;
   assign umctl2_mp_pcfgqos1_0_rqos_map_timeoutr_0_mask = `UMCTL2_REG_MSK_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos0_0_wqos_map_level1_0_mask;
   assign umctl2_mp_pcfgwqos0_0_wqos_map_level1_0_mask = `UMCTL2_REG_MSK_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos0_0_wqos_map_level2_0_mask;
   assign umctl2_mp_pcfgwqos0_0_wqos_map_level2_0_mask = `UMCTL2_REG_MSK_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos0_0_wqos_map_region0_0_mask;
   assign umctl2_mp_pcfgwqos0_0_wqos_map_region0_0_mask = `UMCTL2_REG_MSK_PCFGWQOS0_0_WQOS_MAP_REGION0_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos0_0_wqos_map_region1_0_mask;
   assign umctl2_mp_pcfgwqos0_0_wqos_map_region1_0_mask = `UMCTL2_REG_MSK_PCFGWQOS0_0_WQOS_MAP_REGION1_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos0_0_wqos_map_region2_0_mask;
   assign umctl2_mp_pcfgwqos0_0_wqos_map_region2_0_mask = `UMCTL2_REG_MSK_PCFGWQOS0_0_WQOS_MAP_REGION2_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos1_0_wqos_map_timeout1_0_mask;
   assign umctl2_mp_pcfgwqos1_0_wqos_map_timeout1_0_mask = `UMCTL2_REG_MSK_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0;
   wire [REG_WIDTH-1:0] umctl2_mp_pcfgwqos1_0_wqos_map_timeout2_0_mask;
   assign umctl2_mp_pcfgwqos1_0_wqos_map_timeout2_0_mask = `UMCTL2_REG_MSK_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0;

   reg ff_ddr3;
   reg ff_ddr4;
   reg ff_burstchop;
   reg ff_en_2t_timing_mode;
   reg ff_geardown_mode;
   reg [`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH-1:0] ff_data_bus_width;
   reg ff_dll_off_mode;
   reg [`UMCTL2_REG_SIZE_MSTR_BURST_RDWR-1:0] ff_burst_rdwr;
   reg [`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS-1:0] ff_active_ranks;
   reg [`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG-1:0] ff_device_config;
   reg ff_mr_type;
   reg ff_mpr_en;
   reg ff_pda_en;
   reg ff_sw_init_int;
   reg [`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK-1:0] ff_mr_rank;
   reg [`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR-1:0] ff_mr_addr;
   reg ff_pba_mode;
   reg ff_mr_wr_todo;
   reg ff_mr_wr;
   reg [`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA-1:0] ff_mr_data;
   reg [`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL-1:0] ff_mr_device_sel;
   reg ff_selfref_en;
   reg ff_powerdown_en;
   reg ff_en_dfi_dram_clk_disable;
   reg ff_mpsm_en;
   reg ff_selfref_sw;
   reg ff_dis_cam_drain_selfref;
   reg [`UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32-1:0] cfgs_ff_powerdown_to_x32;
   reg [`UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32-1:0] cfgs_ff_selfref_to_x32;
   reg cfgs_ff_hw_lp_en;
   reg cfgs_ff_hw_lp_exit_idle_en;
   reg [`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32-1:0] cfgs_ff_hw_lp_idle_x32;
   reg [`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST-1:0] ff_refresh_burst;
   reg [`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32-1:0] ff_refresh_to_x1_x32;
   reg [`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN-1:0] ff_refresh_margin;
   reg [`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32-1:0] ff_refresh_timer0_start_value_x32;
   reg [`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32-1:0] ff_refresh_timer1_start_value_x32;
   reg ff_dis_auto_refresh;
   reg ff_refresh_update_level;
   reg [`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE-1:0] ff_refresh_mode;
   reg [`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN-1:0] ff_t_rfc_min;
   reg [`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32-1:0] ff_t_rfc_nom_x1_x32;
   reg ff_dfi_alert_err_int_en;
   reg ff_dfi_alert_err_int_clr;
   reg ff_dfi_alert_err_cnt_clr;
   reg ff_parity_enable;
   reg ff_crc_enable;
   reg ff_crc_inc_dm;
   reg ff_caparity_disable_before_sr;
   reg [`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024-1:0] ff_pre_cke_x1024;
   reg [`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024-1:0] ff_post_cke_x1024;
   reg [`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT-1:0] ff_skip_dram_init;
   reg [`UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32-1:0] cfgs_ff_pre_ocd_x32;
   reg [`UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024-1:0] cfgs_ff_dram_rstn_x1024;
   reg [`UMCTL2_REG_SIZE_INIT3_EMR-1:0] cfgs_ff_emr;
   reg [`UMCTL2_REG_SIZE_INIT3_MR-1:0] cfgs_ff_mr;
   reg [`UMCTL2_REG_SIZE_INIT4_EMR3-1:0] ff_emr3;
   reg [`UMCTL2_REG_SIZE_INIT4_EMR2-1:0] ff_emr2;
   reg [`UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32-1:0] cfgs_ff_dev_zqinit_x32;
   reg [`UMCTL2_REG_SIZE_INIT6_MR5-1:0] cfgs_ff_mr5;
   reg [`UMCTL2_REG_SIZE_INIT6_MR4-1:0] cfgs_ff_mr4;
   reg [`UMCTL2_REG_SIZE_INIT7_MR6-1:0] cfgs_ff_mr6;
   reg ff_dimm_stagger_cs_en;
   reg ff_dimm_addr_mirr_en;
   reg ff_dimm_output_inv_en;
   reg ff_mrs_a17_en;
   reg ff_mrs_bg1_en;
   reg ff_dimm_dis_bg_mirroring;
   reg ff_lrdimm_bcom_cmd_prot;
   reg ff_rcd_weak_drive;
   reg ff_rcd_a_output_disabled;
   reg ff_rcd_b_output_disabled;
   reg [`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD-1:0] cfgs_ff_max_rank_rd;
   reg [`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP-1:0] cfgs_ff_diff_rank_rd_gap;
   reg [`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP-1:0] cfgs_ff_diff_rank_wr_gap;
   reg [`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR-1:0] cfgs_ff_max_rank_wr;
   reg cfgs_ff_diff_rank_rd_gap_msb;
   reg cfgs_ff_diff_rank_wr_gap_msb;
   reg [`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN-1:0] cfgs_ff_t_ras_min;
   reg [`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX-1:0] cfgs_ff_t_ras_max;
   reg [`UMCTL2_REG_SIZE_DRAMTMG0_T_FAW-1:0] cfgs_ff_t_faw;
   reg [`UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE-1:0] cfgs_ff_wr2pre;
   reg [`UMCTL2_REG_SIZE_DRAMTMG1_T_RC-1:0] cfgs_ff_t_rc;
   reg [`UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE-1:0] cfgs_ff_rd2pre;
   reg [`UMCTL2_REG_SIZE_DRAMTMG1_T_XP-1:0] cfgs_ff_t_xp;
   reg [`UMCTL2_REG_SIZE_DRAMTMG2_WR2RD-1:0] cfgs_ff_wr2rd;
   reg [`UMCTL2_REG_SIZE_DRAMTMG2_RD2WR-1:0] cfgs_ff_rd2wr;
   reg [`UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY-1:0] cfgs_ff_read_latency;
   reg [`UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY-1:0] cfgs_ff_write_latency;
   reg [`UMCTL2_REG_SIZE_DRAMTMG3_T_MOD-1:0] cfgs_ff_t_mod;
   reg [`UMCTL2_REG_SIZE_DRAMTMG3_T_MRD-1:0] cfgs_ff_t_mrd;
   reg [`UMCTL2_REG_SIZE_DRAMTMG4_T_RP-1:0] cfgs_ff_t_rp;
   reg [`UMCTL2_REG_SIZE_DRAMTMG4_T_RRD-1:0] cfgs_ff_t_rrd;
   reg [`UMCTL2_REG_SIZE_DRAMTMG4_T_CCD-1:0] cfgs_ff_t_ccd;
   reg [`UMCTL2_REG_SIZE_DRAMTMG4_T_RCD-1:0] cfgs_ff_t_rcd;
   reg [`UMCTL2_REG_SIZE_DRAMTMG5_T_CKE-1:0] cfgs_ff_t_cke;
   reg [`UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR-1:0] cfgs_ff_t_ckesr;
   reg [`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE-1:0] cfgs_ff_t_cksre;
   reg [`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX-1:0] cfgs_ff_t_cksrx;
   reg [`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32-1:0] cfgs_ff_t_xs_x32;
   reg [`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32-1:0] cfgs_ff_t_xs_dll_x32;
   reg [`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32-1:0] cfgs_ff_t_xs_abort_x32;
   reg [`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32-1:0] cfgs_ff_t_xs_fast_x32;
   reg [`UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S-1:0] cfgs_ff_wr2rd_s;
   reg [`UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S-1:0] cfgs_ff_t_rrd_s;
   reg [`UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S-1:0] cfgs_ff_t_ccd_s;
   reg cfgs_ff_ddr4_wr_preamble;
   reg [`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD-1:0] ff_t_gear_hold;
   reg [`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP-1:0] ff_t_gear_setup;
   reg [`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR-1:0] ff_t_cmd_gear;
   reg [`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR-1:0] ff_t_sync_gear;
   reg [`UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE-1:0] cfgs_ff_t_ckmpe;
   reg [`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S-1:0] cfgs_ff_t_mpx_s;
   reg [`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH-1:0] cfgs_ff_t_mpx_lh;
   reg [`UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32-1:0] cfgs_ff_post_mpsm_gap_x32;
   reg [`UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA-1:0] cfgs_ff_t_mrd_pda;
   reg [`UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR-1:0] cfgs_ff_t_wr_mpr;
   reg [`UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32-1:0] cfgs_ff_t_stab_x32;
   reg cfgs_ff_en_dfi_lp_t_stab;
   reg [`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP-1:0] ff_t_zq_short_nop;
   reg [`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP-1:0] ff_t_zq_long_nop;
   reg ff_dis_mpsmx_zqcl;
   reg ff_zq_resistor_shared;
   reg ff_dis_srx_zqcl;
   reg ff_dis_auto_zq;
   reg [`UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024-1:0] cfgs_ff_t_zq_short_interval_x1024;
   reg [`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT-1:0] cfgs_ff_dfi_tphy_wrlat;
   reg [`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA-1:0] cfgs_ff_dfi_tphy_wrdata;
   reg cfgs_ff_dfi_wrdata_use_dfi_phy_clk;
   reg [`UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN-1:0] cfgs_ff_dfi_t_rddata_en;
   reg cfgs_ff_dfi_rddata_use_dfi_phy_clk;
   reg [`UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY-1:0] cfgs_ff_dfi_t_ctrl_delay;
   reg [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE-1:0] ff_dfi_t_dram_clk_enable;
   reg [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE-1:0] ff_dfi_t_dram_clk_disable;
   reg [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY-1:0] ff_dfi_t_wrdata_delay;
   reg [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT-1:0] ff_dfi_t_parin_lat;
   reg [`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT-1:0] ff_dfi_t_cmd_lat;
   reg ff_dfi_lp_en_pd;
   reg [`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD-1:0] ff_dfi_lp_wakeup_pd;
   reg ff_dfi_lp_en_sr;
   reg [`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR-1:0] ff_dfi_lp_wakeup_sr;
   reg [`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP-1:0] ff_dfi_tlp_resp;
   reg cfgs_ff_dfi_lp_en_mpsm;
   reg [`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM-1:0] cfgs_ff_dfi_lp_wakeup_mpsm;
   reg [`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN-1:0] cfgs_ff_dfi_t_ctrlup_min;
   reg [`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX-1:0] cfgs_ff_dfi_t_ctrlup_max;
   reg cfgs_ff_ctrlupd_pre_srx;
   reg cfgs_ff_dis_auto_ctrlupd_srx;
   reg cfgs_ff_dis_auto_ctrlupd;
   reg [`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024-1:0] cfgs_ff_dfi_t_ctrlupd_interval_max_x1024;
   reg [`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024-1:0] cfgs_ff_dfi_t_ctrlupd_interval_min_x1024;
   reg cfgs_ff_dfi_phyupd_en;
   reg ff_dfi_init_complete_en;
   reg ff_phy_dbi_mode;
   reg ff_ctl_idle_en;
   reg ff_dfi_init_start;
   reg ff_dis_dyn_adr_tri;
   reg [`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY-1:0] ff_dfi_frequency;
   reg [`UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY-1:0] cfgs_ff_dfi_t_geardown_delay;
   reg ff_dm_en;
   reg ff_wr_dbi_en;
   reg ff_rd_dbi_en;
   reg ff_dfi_phymstr_en;
   reg [`UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0-1:0] cfgs_ff_addrmap_cs_bit0;
   reg [`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0-1:0] cfgs_ff_addrmap_bank_b0;
   reg [`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1-1:0] cfgs_ff_addrmap_bank_b1;
   reg [`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2-1:0] cfgs_ff_addrmap_bank_b2;
   reg [`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2-1:0] cfgs_ff_addrmap_col_b2;
   reg [`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3-1:0] cfgs_ff_addrmap_col_b3;
   reg [`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4-1:0] cfgs_ff_addrmap_col_b4;
   reg [`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5-1:0] cfgs_ff_addrmap_col_b5;
   reg [`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6-1:0] cfgs_ff_addrmap_col_b6;
   reg [`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7-1:0] cfgs_ff_addrmap_col_b7;
   reg [`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8-1:0] cfgs_ff_addrmap_col_b8;
   reg [`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9-1:0] cfgs_ff_addrmap_col_b9;
   reg [`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10-1:0] cfgs_ff_addrmap_col_b10;
   reg [`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11-1:0] cfgs_ff_addrmap_col_b11;
   reg [`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0-1:0] cfgs_ff_addrmap_row_b0;
   reg [`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1-1:0] cfgs_ff_addrmap_row_b1;
   reg [`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10-1:0] cfgs_ff_addrmap_row_b2_10;
   reg [`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11-1:0] cfgs_ff_addrmap_row_b11;
   reg [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12-1:0] ff_addrmap_row_b12;
   reg [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13-1:0] ff_addrmap_row_b13;
   reg [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14-1:0] ff_addrmap_row_b14;
   reg [`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15-1:0] ff_addrmap_row_b15;
   reg [`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16-1:0] ff_addrmap_row_b16;
   reg [`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17-1:0] ff_addrmap_row_b17;
   reg [`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0-1:0] cfgs_ff_addrmap_bg_b0;
   reg [`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1-1:0] cfgs_ff_addrmap_bg_b1;
   reg [`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2-1:0] cfgs_ff_addrmap_row_b2;
   reg [`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3-1:0] cfgs_ff_addrmap_row_b3;
   reg [`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4-1:0] cfgs_ff_addrmap_row_b4;
   reg [`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5-1:0] cfgs_ff_addrmap_row_b5;
   reg [`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6-1:0] cfgs_ff_addrmap_row_b6;
   reg [`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7-1:0] cfgs_ff_addrmap_row_b7;
   reg [`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8-1:0] cfgs_ff_addrmap_row_b8;
   reg [`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9-1:0] cfgs_ff_addrmap_row_b9;
   reg [`UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10-1:0] cfgs_ff_addrmap_row_b10;
   reg [`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY-1:0] cfgs_ff_rd_odt_delay;
   reg [`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD-1:0] cfgs_ff_rd_odt_hold;
   reg [`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY-1:0] cfgs_ff_wr_odt_delay;
   reg [`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD-1:0] cfgs_ff_wr_odt_hold;
   reg [`UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT-1:0] cfgs_ff_rank0_wr_odt;
   reg [`UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT-1:0] cfgs_ff_rank0_rd_odt;
   reg [`UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT-1:0] cfgs_ff_rank1_wr_odt;
   reg [`UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT-1:0] cfgs_ff_rank1_rd_odt;
   reg cfgs_ff_prefer_write;
   reg cfgs_ff_pageclose;
   reg cfgs_ff_autopre_rmw;
   reg [`UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES-1:0] cfgs_ff_lpr_num_entries;
   reg [`UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS-1:0] cfgs_ff_go2critical_hysteresis;
   reg [`UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP-1:0] cfgs_ff_rdwr_idle_gap;
   reg [`UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER-1:0] cfgs_ff_pageclose_timer;
   reg [`UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE-1:0] cfgs_ff_hpr_max_starve;
   reg [`UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH-1:0] cfgs_ff_hpr_xact_run_length;
   reg [`UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE-1:0] cfgs_ff_lpr_max_starve;
   reg [`UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH-1:0] cfgs_ff_lpr_xact_run_length;
   reg [`UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE-1:0] cfgs_ff_w_max_starve;
   reg [`UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH-1:0] cfgs_ff_w_xact_run_length;
   reg cfgs_ff_dis_wc;
   reg cfgs_ff_dis_collision_page_opt;
   reg cfgs_ff_dis_max_rank_rd_opt;
   reg cfgs_ff_dis_max_rank_wr_opt;
   reg ff_dis_dq;
   reg ff_dis_hif;
   reg ff_rank0_refresh_todo;
   reg ff_rank0_refresh;
   reg ff_rank1_refresh_todo;
   reg ff_rank1_refresh;
   reg ff_zq_calib_short_todo;
   reg ff_zq_calib_short;
   reg ff_ctrlupd_todo;
   reg ff_ctrlupd;
   reg cfgs_ff_sw_done;
   reg cfgs_ff_sw_static_unlock;
   reg ff_wr_poison_slverr_en;
   reg ff_wr_poison_intr_en;
   reg ff_wr_poison_intr_clr;
   reg ff_rd_poison_slverr_en;
   reg ff_rd_poison_intr_en;
   reg ff_rd_poison_intr_clr;
   reg cfgs_ff_go2critical_en;
   reg cfgs_ff_pagematch_limit;
   reg cfgs_ff_bl_exp_mode;
   reg [`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0-1:0] cfgs_ff_rd_port_priority_0;
   reg cfgs_ff_rd_port_aging_en_0;
   reg cfgs_ff_rd_port_urgent_en_0;
   reg cfgs_ff_rd_port_pagematch_en_0;
   reg [`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0-1:0] cfgs_ff_wr_port_priority_0;
   reg cfgs_ff_wr_port_aging_en_0;
   reg cfgs_ff_wr_port_urgent_en_0;
   reg cfgs_ff_wr_port_pagematch_en_0;
   reg ff_port_en_0;
   reg [`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0-1:0] cfgs_ff_rqos_map_level1_0;
   reg [`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0-1:0] cfgs_ff_rqos_map_region0_0;
   reg [`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0-1:0] cfgs_ff_rqos_map_region1_0;
   reg [`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0-1:0] cfgs_ff_rqos_map_timeoutb_0;
   reg [`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0-1:0] cfgs_ff_rqos_map_timeoutr_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0-1:0] cfgs_ff_wqos_map_level1_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0-1:0] cfgs_ff_wqos_map_level2_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0-1:0] cfgs_ff_wqos_map_region0_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0-1:0] cfgs_ff_wqos_map_region1_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0-1:0] cfgs_ff_wqos_map_region2_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0-1:0] cfgs_ff_wqos_map_timeout1_0;
   reg [`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0-1:0] cfgs_ff_wqos_map_timeout2_0;



   //------------------------
   // Register UMCTL2_REGS.MSTR
   //------------------------
   always_comb begin : r0_mstr_combo_PROC
      r0_mstr = {REG_WIDTH {1'b0}};
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR3+:`UMCTL2_REG_SIZE_MSTR_DDR3] = ff_ddr3;
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DDR4+:`UMCTL2_REG_SIZE_MSTR_DDR4] = ff_ddr4;
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURSTCHOP+:`UMCTL2_REG_SIZE_MSTR_BURSTCHOP] = ff_burstchop;
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_EN_2T_TIMING_MODE+:`UMCTL2_REG_SIZE_MSTR_EN_2T_TIMING_MODE] = ff_en_2t_timing_mode;
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_GEARDOWN_MODE+:`UMCTL2_REG_SIZE_MSTR_GEARDOWN_MODE] = ff_geardown_mode;
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DATA_BUS_WIDTH+:`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH] = ff_data_bus_width[(`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH) -1:0];
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DLL_OFF_MODE+:`UMCTL2_REG_SIZE_MSTR_DLL_OFF_MODE] = ff_dll_off_mode;
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_BURST_RDWR+:`UMCTL2_REG_SIZE_MSTR_BURST_RDWR] = ff_burst_rdwr[(`UMCTL2_REG_SIZE_MSTR_BURST_RDWR) -1:0];
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_ACTIVE_RANKS+:`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS] = ff_active_ranks[(`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS) -1:0];
      r0_mstr[`UMCTL2_REG_OFFSET_MSTR_DEVICE_CONFIG+:`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG] = ff_device_config[(`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL0
   //------------------------
   always_comb begin : r4_mrctrl0_combo_PROC
      r4_mrctrl0 = {REG_WIDTH {1'b0}};
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_TYPE+:`UMCTL2_REG_SIZE_MRCTRL0_MR_TYPE] = ff_mr_type;
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MPR_EN+:`UMCTL2_REG_SIZE_MRCTRL0_MPR_EN] = ff_mpr_en;
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PDA_EN+:`UMCTL2_REG_SIZE_MRCTRL0_PDA_EN] = ff_pda_en;
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_SW_INIT_INT+:`UMCTL2_REG_SIZE_MRCTRL0_SW_INIT_INT] = ff_sw_init_int;
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_RANK+:`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK] = ff_mr_rank[(`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK) -1:0];
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_ADDR+:`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR] = ff_mr_addr[(`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR) -1:0];
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_PBA_MODE+:`UMCTL2_REG_SIZE_MRCTRL0_PBA_MODE] = ff_pba_mode;
      r4_mrctrl0[`UMCTL2_REG_OFFSET_MRCTRL0_MR_WR+:`UMCTL2_REG_SIZE_MRCTRL0_MR_WR] = ff_mr_wr;
   end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL1
   //------------------------
   always_comb begin : r5_mrctrl1_combo_PROC
      r5_mrctrl1 = {REG_WIDTH {1'b0}};
      r5_mrctrl1[`UMCTL2_REG_OFFSET_MRCTRL1_MR_DATA+:`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA] = ff_mr_data[(`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL2
   //------------------------
   always_comb begin : r7_mrctrl2_combo_PROC
      r7_mrctrl2 = {REG_WIDTH {1'b0}};
      r7_mrctrl2[`UMCTL2_REG_OFFSET_MRCTRL2_MR_DEVICE_SEL+:`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL] = ff_mr_device_sel[(`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.PWRCTL
   //------------------------
   always_comb begin : r12_pwrctl_combo_PROC
      r12_pwrctl = {REG_WIDTH {1'b0}};
      r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_EN+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_EN] = ff_selfref_en;
      r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_POWERDOWN_EN+:`UMCTL2_REG_SIZE_PWRCTL_POWERDOWN_EN] = ff_powerdown_en;
      r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE] = ff_en_dfi_dram_clk_disable;
      r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_MPSM_EN+:`UMCTL2_REG_SIZE_PWRCTL_MPSM_EN] = ff_mpsm_en;
      r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_SW+:`UMCTL2_REG_SIZE_PWRCTL_SELFREF_SW] = ff_selfref_sw;
      r12_pwrctl[`UMCTL2_REG_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`UMCTL2_REG_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF] = ff_dis_cam_drain_selfref;
   end
   //------------------------
   // Register UMCTL2_REGS.PWRTMG
   //------------------------
   always_comb begin : r13_pwrtmg_combo_PROC
      r13_pwrtmg = {REG_WIDTH {1'b0}};
      r13_pwrtmg[`UMCTL2_REG_OFFSET_PWRTMG_POWERDOWN_TO_X32+:`UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32] = cfgs_ff_powerdown_to_x32[(`UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32) -1:0];
      r13_pwrtmg[`UMCTL2_REG_OFFSET_PWRTMG_SELFREF_TO_X32+:`UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32] = cfgs_ff_selfref_to_x32[(`UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.HWLPCTL
   //------------------------
   always_comb begin : r14_hwlpctl_combo_PROC
      r14_hwlpctl = {REG_WIDTH {1'b0}};
      r14_hwlpctl[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EN+:`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EN] = cfgs_ff_hw_lp_en;
      r14_hwlpctl[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN+:`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN] = cfgs_ff_hw_lp_exit_idle_en;
      r14_hwlpctl[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_IDLE_X32+:`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32] = cfgs_ff_hw_lp_idle_x32[(`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL0
   //------------------------
   always_comb begin : r17_rfshctl0_combo_PROC
      r17_rfshctl0 = {REG_WIDTH {1'b0}};
      r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_BURST+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST] = ff_refresh_burst[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST) -1:0];
      r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_TO_X1_X32+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32] = ff_refresh_to_x1_x32[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32) -1:0];
      r17_rfshctl0[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_MARGIN+:`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN] = ff_refresh_margin[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL1
   //------------------------
   always_comb begin : r18_rfshctl1_combo_PROC
      r18_rfshctl1 = {REG_WIDTH {1'b0}};
      r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32] = ff_refresh_timer0_start_value_x32[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32) -1:0];
      r18_rfshctl1[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32+:`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32] = ff_refresh_timer1_start_value_x32[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL3
   //------------------------
   always_comb begin : r21_rfshctl3_combo_PROC
      r21_rfshctl3 = {REG_WIDTH {1'b0}};
      r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_DIS_AUTO_REFRESH+:`UMCTL2_REG_SIZE_RFSHCTL3_DIS_AUTO_REFRESH] = ff_dis_auto_refresh;
      r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_UPDATE_LEVEL+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_UPDATE_LEVEL] = ff_refresh_update_level;
      r21_rfshctl3[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_MODE+:`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE] = ff_refresh_mode[(`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.RFSHTMG
   //------------------------
   always_comb begin : r22_rfshtmg_combo_PROC
      r22_rfshtmg = {REG_WIDTH {1'b0}};
      r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_MIN+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN] = ff_t_rfc_min[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN) -1:0];
      r22_rfshtmg[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_NOM_X1_X32+:`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32] = ff_t_rfc_nom_x1_x32[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL0
   //------------------------
   always_comb begin : r44_crcparctl0_combo_PROC
      r44_crcparctl0 = {REG_WIDTH {1'b0}};
      r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_EN+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_EN] = ff_dfi_alert_err_int_en;
      r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR] = ff_dfi_alert_err_int_clr;
      r44_crcparctl0[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR+:`UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR] = ff_dfi_alert_err_cnt_clr;
   end
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL1
   //------------------------
   always_comb begin : r45_crcparctl1_combo_PROC
      r45_crcparctl1 = {REG_WIDTH {1'b0}};
      r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_PARITY_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_PARITY_ENABLE] = ff_parity_enable;
      r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_ENABLE+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_ENABLE] = ff_crc_enable;
      r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_INC_DM+:`UMCTL2_REG_SIZE_CRCPARCTL1_CRC_INC_DM] = ff_crc_inc_dm;
      r45_crcparctl1[`UMCTL2_REG_OFFSET_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR+:`UMCTL2_REG_SIZE_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR] = ff_caparity_disable_before_sr;
   end
   //------------------------
   // Register UMCTL2_REGS.INIT0
   //------------------------
   always_comb begin : r48_init0_combo_PROC
      r48_init0 = {REG_WIDTH {1'b0}};
      r48_init0[`UMCTL2_REG_OFFSET_INIT0_PRE_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024] = ff_pre_cke_x1024[(`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024) -1:0];
      r48_init0[`UMCTL2_REG_OFFSET_INIT0_POST_CKE_X1024+:`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024] = ff_post_cke_x1024[(`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024) -1:0];
      r48_init0[`UMCTL2_REG_OFFSET_INIT0_SKIP_DRAM_INIT+:`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT] = ff_skip_dram_init[(`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.INIT1
   //------------------------
   always_comb begin : r49_init1_combo_PROC
      r49_init1 = {REG_WIDTH {1'b0}};
      r49_init1[`UMCTL2_REG_OFFSET_INIT1_PRE_OCD_X32+:`UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32] = cfgs_ff_pre_ocd_x32[(`UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32) -1:0];
      r49_init1[`UMCTL2_REG_OFFSET_INIT1_DRAM_RSTN_X1024+:`UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024] = cfgs_ff_dram_rstn_x1024[(`UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.INIT3
   //------------------------
   always_comb begin : r51_init3_combo_PROC
      r51_init3 = {REG_WIDTH {1'b0}};
      r51_init3[`UMCTL2_REG_OFFSET_INIT3_EMR+:`UMCTL2_REG_SIZE_INIT3_EMR] = cfgs_ff_emr[(`UMCTL2_REG_SIZE_INIT3_EMR) -1:0];
      r51_init3[`UMCTL2_REG_OFFSET_INIT3_MR+:`UMCTL2_REG_SIZE_INIT3_MR] = cfgs_ff_mr[(`UMCTL2_REG_SIZE_INIT3_MR) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.INIT4
   //------------------------
   always_comb begin : r52_init4_combo_PROC
      r52_init4 = {REG_WIDTH {1'b0}};
      r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR3+:`UMCTL2_REG_SIZE_INIT4_EMR3] = ff_emr3[(`UMCTL2_REG_SIZE_INIT4_EMR3) -1:0];
      r52_init4[`UMCTL2_REG_OFFSET_INIT4_EMR2+:`UMCTL2_REG_SIZE_INIT4_EMR2] = ff_emr2[(`UMCTL2_REG_SIZE_INIT4_EMR2) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.INIT5
   //------------------------
   always_comb begin : r53_init5_combo_PROC
      r53_init5 = {REG_WIDTH {1'b0}};
      r53_init5[`UMCTL2_REG_OFFSET_INIT5_DEV_ZQINIT_X32+:`UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32] = cfgs_ff_dev_zqinit_x32[(`UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.INIT6
   //------------------------
   always_comb begin : r54_init6_combo_PROC
      r54_init6 = {REG_WIDTH {1'b0}};
      r54_init6[`UMCTL2_REG_OFFSET_INIT6_MR5+:`UMCTL2_REG_SIZE_INIT6_MR5] = cfgs_ff_mr5[(`UMCTL2_REG_SIZE_INIT6_MR5) -1:0];
      r54_init6[`UMCTL2_REG_OFFSET_INIT6_MR4+:`UMCTL2_REG_SIZE_INIT6_MR4] = cfgs_ff_mr4[(`UMCTL2_REG_SIZE_INIT6_MR4) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.INIT7
   //------------------------
   always_comb begin : r55_init7_combo_PROC
      r55_init7 = {REG_WIDTH {1'b0}};
      r55_init7[`UMCTL2_REG_OFFSET_INIT7_MR6+:`UMCTL2_REG_SIZE_INIT7_MR6] = cfgs_ff_mr6[(`UMCTL2_REG_SIZE_INIT7_MR6) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DIMMCTL
   //------------------------
   always_comb begin : r56_dimmctl_combo_PROC
      r56_dimmctl = {REG_WIDTH {1'b0}};
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_STAGGER_CS_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_STAGGER_CS_EN] = ff_dimm_stagger_cs_en;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_ADDR_MIRR_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_ADDR_MIRR_EN] = ff_dimm_addr_mirr_en;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_OUTPUT_INV_EN+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_OUTPUT_INV_EN] = ff_dimm_output_inv_en;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_A17_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_A17_EN] = ff_mrs_a17_en;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_BG1_EN+:`UMCTL2_REG_SIZE_DIMMCTL_MRS_BG1_EN] = ff_mrs_bg1_en;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_DIS_BG_MIRRORING+:`UMCTL2_REG_SIZE_DIMMCTL_DIMM_DIS_BG_MIRRORING] = ff_dimm_dis_bg_mirroring;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_LRDIMM_BCOM_CMD_PROT+:`UMCTL2_REG_SIZE_DIMMCTL_LRDIMM_BCOM_CMD_PROT] = ff_lrdimm_bcom_cmd_prot;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_WEAK_DRIVE+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_WEAK_DRIVE] = ff_rcd_weak_drive;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_A_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_A_OUTPUT_DISABLED] = ff_rcd_a_output_disabled;
      r56_dimmctl[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_B_OUTPUT_DISABLED+:`UMCTL2_REG_SIZE_DIMMCTL_RCD_B_OUTPUT_DISABLED] = ff_rcd_b_output_disabled;
   end
   //------------------------
   // Register UMCTL2_REGS.RANKCTL
   //------------------------
   always_comb begin : r57_rankctl_combo_PROC
      r57_rankctl = {REG_WIDTH {1'b0}};
      r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_RD+:`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD] = cfgs_ff_max_rank_rd[(`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD) -1:0];
      r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP] = cfgs_ff_diff_rank_rd_gap[(`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP) -1:0];
      r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP] = cfgs_ff_diff_rank_wr_gap[(`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP) -1:0];
      r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_WR+:`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR] = cfgs_ff_max_rank_wr[(`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR) -1:0];
      r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP_MSB+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP_MSB] = cfgs_ff_diff_rank_rd_gap_msb;
      r57_rankctl[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP_MSB+:`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP_MSB] = cfgs_ff_diff_rank_wr_gap_msb;
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG0
   //------------------------
   always_comb begin : r59_dramtmg0_combo_PROC
      r59_dramtmg0 = {REG_WIDTH {1'b0}};
      r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MIN+:`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN] = cfgs_ff_t_ras_min[(`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN) -1:0];
      r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MAX+:`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX] = cfgs_ff_t_ras_max[(`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX) -1:0];
      r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_T_FAW+:`UMCTL2_REG_SIZE_DRAMTMG0_T_FAW] = cfgs_ff_t_faw[(`UMCTL2_REG_SIZE_DRAMTMG0_T_FAW) -1:0];
      r59_dramtmg0[`UMCTL2_REG_OFFSET_DRAMTMG0_WR2PRE+:`UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE] = cfgs_ff_wr2pre[(`UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG1
   //------------------------
   always_comb begin : r60_dramtmg1_combo_PROC
      r60_dramtmg1 = {REG_WIDTH {1'b0}};
      r60_dramtmg1[`UMCTL2_REG_OFFSET_DRAMTMG1_T_RC+:`UMCTL2_REG_SIZE_DRAMTMG1_T_RC] = cfgs_ff_t_rc[(`UMCTL2_REG_SIZE_DRAMTMG1_T_RC) -1:0];
      r60_dramtmg1[`UMCTL2_REG_OFFSET_DRAMTMG1_RD2PRE+:`UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE] = cfgs_ff_rd2pre[(`UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE) -1:0];
      r60_dramtmg1[`UMCTL2_REG_OFFSET_DRAMTMG1_T_XP+:`UMCTL2_REG_SIZE_DRAMTMG1_T_XP] = cfgs_ff_t_xp[(`UMCTL2_REG_SIZE_DRAMTMG1_T_XP) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG2
   //------------------------
   always_comb begin : r61_dramtmg2_combo_PROC
      r61_dramtmg2 = {REG_WIDTH {1'b0}};
      r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_WR2RD+:`UMCTL2_REG_SIZE_DRAMTMG2_WR2RD] = cfgs_ff_wr2rd[(`UMCTL2_REG_SIZE_DRAMTMG2_WR2RD) -1:0];
      r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_RD2WR+:`UMCTL2_REG_SIZE_DRAMTMG2_RD2WR] = cfgs_ff_rd2wr[(`UMCTL2_REG_SIZE_DRAMTMG2_RD2WR) -1:0];
      r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_READ_LATENCY+:`UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY] = cfgs_ff_read_latency[(`UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY) -1:0];
      r61_dramtmg2[`UMCTL2_REG_OFFSET_DRAMTMG2_WRITE_LATENCY+:`UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY] = cfgs_ff_write_latency[(`UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG3
   //------------------------
   always_comb begin : r62_dramtmg3_combo_PROC
      r62_dramtmg3 = {REG_WIDTH {1'b0}};
      r62_dramtmg3[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MOD+:`UMCTL2_REG_SIZE_DRAMTMG3_T_MOD] = cfgs_ff_t_mod[(`UMCTL2_REG_SIZE_DRAMTMG3_T_MOD) -1:0];
      r62_dramtmg3[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MRD+:`UMCTL2_REG_SIZE_DRAMTMG3_T_MRD] = cfgs_ff_t_mrd[(`UMCTL2_REG_SIZE_DRAMTMG3_T_MRD) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG4
   //------------------------
   always_comb begin : r63_dramtmg4_combo_PROC
      r63_dramtmg4 = {REG_WIDTH {1'b0}};
      r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RP+:`UMCTL2_REG_SIZE_DRAMTMG4_T_RP] = cfgs_ff_t_rp[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RP) -1:0];
      r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RRD+:`UMCTL2_REG_SIZE_DRAMTMG4_T_RRD] = cfgs_ff_t_rrd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RRD) -1:0];
      r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_CCD+:`UMCTL2_REG_SIZE_DRAMTMG4_T_CCD] = cfgs_ff_t_ccd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_CCD) -1:0];
      r63_dramtmg4[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RCD+:`UMCTL2_REG_SIZE_DRAMTMG4_T_RCD] = cfgs_ff_t_rcd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RCD) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG5
   //------------------------
   always_comb begin : r64_dramtmg5_combo_PROC
      r64_dramtmg5 = {REG_WIDTH {1'b0}};
      r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKE+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKE] = cfgs_ff_t_cke[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKE) -1:0];
      r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKESR+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR] = cfgs_ff_t_ckesr[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR) -1:0];
      r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRE+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE] = cfgs_ff_t_cksre[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE) -1:0];
      r64_dramtmg5[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRX+:`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX] = cfgs_ff_t_cksrx[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG8
   //------------------------
   always_comb begin : r67_dramtmg8_combo_PROC
      r67_dramtmg8 = {REG_WIDTH {1'b0}};
      r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32] = cfgs_ff_t_xs_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32) -1:0];
      r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_DLL_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32] = cfgs_ff_t_xs_dll_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32) -1:0];
      r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_ABORT_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32] = cfgs_ff_t_xs_abort_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32) -1:0];
      r67_dramtmg8[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_FAST_X32+:`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32] = cfgs_ff_t_xs_fast_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG9
   //------------------------
   always_comb begin : r68_dramtmg9_combo_PROC
      r68_dramtmg9 = {REG_WIDTH {1'b0}};
      r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_WR2RD_S+:`UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S] = cfgs_ff_wr2rd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S) -1:0];
      r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_T_RRD_S+:`UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S] = cfgs_ff_t_rrd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S) -1:0];
      r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_T_CCD_S+:`UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S] = cfgs_ff_t_ccd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S) -1:0];
      r68_dramtmg9[`UMCTL2_REG_OFFSET_DRAMTMG9_DDR4_WR_PREAMBLE+:`UMCTL2_REG_SIZE_DRAMTMG9_DDR4_WR_PREAMBLE] = cfgs_ff_ddr4_wr_preamble;
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG10
   //------------------------
   always_comb begin : r69_dramtmg10_combo_PROC
      r69_dramtmg10 = {REG_WIDTH {1'b0}};
      r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_HOLD+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD] = ff_t_gear_hold[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD) -1:0];
      r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_SETUP+:`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP] = ff_t_gear_setup[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP) -1:0];
      r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_CMD_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR] = ff_t_cmd_gear[(`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR) -1:0];
      r69_dramtmg10[`UMCTL2_REG_OFFSET_DRAMTMG10_T_SYNC_GEAR+:`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR] = ff_t_sync_gear[(`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG11
   //------------------------
   always_comb begin : r70_dramtmg11_combo_PROC
      r70_dramtmg11 = {REG_WIDTH {1'b0}};
      r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_T_CKMPE+:`UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE] = cfgs_ff_t_ckmpe[(`UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE) -1:0];
      r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_S+:`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S] = cfgs_ff_t_mpx_s[(`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S) -1:0];
      r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_LH+:`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH] = cfgs_ff_t_mpx_lh[(`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH) -1:0];
      r70_dramtmg11[`UMCTL2_REG_OFFSET_DRAMTMG11_POST_MPSM_GAP_X32+:`UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32] = cfgs_ff_post_mpsm_gap_x32[(`UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG12
   //------------------------
   always_comb begin : r71_dramtmg12_combo_PROC
      r71_dramtmg12 = {REG_WIDTH {1'b0}};
      r71_dramtmg12[`UMCTL2_REG_OFFSET_DRAMTMG12_T_MRD_PDA+:`UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA] = cfgs_ff_t_mrd_pda[(`UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA) -1:0];
      r71_dramtmg12[`UMCTL2_REG_OFFSET_DRAMTMG12_T_WR_MPR+:`UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR] = cfgs_ff_t_wr_mpr[(`UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG15
   //------------------------
   always_comb begin : r74_dramtmg15_combo_PROC
      r74_dramtmg15 = {REG_WIDTH {1'b0}};
      r74_dramtmg15[`UMCTL2_REG_OFFSET_DRAMTMG15_T_STAB_X32+:`UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32] = cfgs_ff_t_stab_x32[(`UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32) -1:0];
      r74_dramtmg15[`UMCTL2_REG_OFFSET_DRAMTMG15_EN_DFI_LP_T_STAB+:`UMCTL2_REG_SIZE_DRAMTMG15_EN_DFI_LP_T_STAB] = cfgs_ff_en_dfi_lp_t_stab;
   end
   //------------------------
   // Register UMCTL2_REGS.ZQCTL0
   //------------------------
   always_comb begin : r82_zqctl0_combo_PROC
      r82_zqctl0 = {REG_WIDTH {1'b0}};
      r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_SHORT_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP] = ff_t_zq_short_nop[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP) -1:0];
      r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_LONG_NOP+:`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP] = ff_t_zq_long_nop[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP) -1:0];
      r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_MPSMX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_MPSMX_ZQCL] = ff_dis_mpsmx_zqcl;
      r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`UMCTL2_REG_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED] = ff_zq_resistor_shared;
      r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_SRX_ZQCL+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_SRX_ZQCL] = ff_dis_srx_zqcl;
      r82_zqctl0[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`UMCTL2_REG_SIZE_ZQCTL0_DIS_AUTO_ZQ] = ff_dis_auto_zq;
   end
   //------------------------
   // Register UMCTL2_REGS.ZQCTL1
   //------------------------
   always_comb begin : r83_zqctl1_combo_PROC
      r83_zqctl1 = {REG_WIDTH {1'b0}};
      r83_zqctl1[`UMCTL2_REG_OFFSET_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024+:`UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024] = cfgs_ff_t_zq_short_interval_x1024[(`UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFITMG0
   //------------------------
   always_comb begin : r86_dfitmg0_combo_PROC
      r86_dfitmg0 = {REG_WIDTH {1'b0}};
      r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRLAT+:`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT] = cfgs_ff_dfi_tphy_wrlat[(`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT) -1:0];
      r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRDATA+:`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA] = cfgs_ff_dfi_tphy_wrdata[(`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA) -1:0];
      r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK+:`UMCTL2_REG_SIZE_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK] = cfgs_ff_dfi_wrdata_use_dfi_phy_clk;
      r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_RDDATA_EN+:`UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN] = cfgs_ff_dfi_t_rddata_en[(`UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN) -1:0];
      r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK+:`UMCTL2_REG_SIZE_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK] = cfgs_ff_dfi_rddata_use_dfi_phy_clk;
      r86_dfitmg0[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_CTRL_DELAY+:`UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY] = cfgs_ff_dfi_t_ctrl_delay[(`UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFITMG1
   //------------------------
   always_comb begin : r87_dfitmg1_combo_PROC
      r87_dfitmg1 = {REG_WIDTH {1'b0}};
      r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE] = ff_dfi_t_dram_clk_enable[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE) -1:0];
      r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE] = ff_dfi_t_dram_clk_disable[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE) -1:0];
      r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY] = ff_dfi_t_wrdata_delay[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY) -1:0];
      r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_PARIN_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT] = ff_dfi_t_parin_lat[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT) -1:0];
      r87_dfitmg1[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_CMD_LAT+:`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT] = ff_dfi_t_cmd_lat[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG0
   //------------------------
   always_comb begin : r88_dfilpcfg0_combo_PROC
      r88_dfilpcfg0 = {REG_WIDTH {1'b0}};
      r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_PD] = ff_dfi_lp_en_pd;
      r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_PD+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD] = ff_dfi_lp_wakeup_pd[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD) -1:0];
      r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_SR] = ff_dfi_lp_en_sr;
      r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_SR+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR] = ff_dfi_lp_wakeup_sr[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR) -1:0];
      r88_dfilpcfg0[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_TLP_RESP+:`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP] = ff_dfi_tlp_resp[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG1
   //------------------------
   always_comb begin : r89_dfilpcfg1_combo_PROC
      r89_dfilpcfg1 = {REG_WIDTH {1'b0}};
      r89_dfilpcfg1[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_EN_MPSM+:`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_EN_MPSM] = cfgs_ff_dfi_lp_en_mpsm;
      r89_dfilpcfg1[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_WAKEUP_MPSM+:`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM] = cfgs_ff_dfi_lp_wakeup_mpsm[(`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFIUPD0
   //------------------------
   always_comb begin : r90_dfiupd0_combo_PROC
      r90_dfiupd0 = {REG_WIDTH {1'b0}};
      r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MIN+:`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN] = cfgs_ff_dfi_t_ctrlup_min[(`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN) -1:0];
      r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MAX+:`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX] = cfgs_ff_dfi_t_ctrlup_max[(`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX) -1:0];
      r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX+:`UMCTL2_REG_SIZE_DFIUPD0_CTRLUPD_PRE_SRX] = cfgs_ff_ctrlupd_pre_srx;
      r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX+:`UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX] = cfgs_ff_dis_auto_ctrlupd_srx;
      r90_dfiupd0[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD+:`UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD] = cfgs_ff_dis_auto_ctrlupd;
   end
   //------------------------
   // Register UMCTL2_REGS.DFIUPD1
   //------------------------
   always_comb begin : r91_dfiupd1_combo_PROC
      r91_dfiupd1 = {REG_WIDTH {1'b0}};
      r91_dfiupd1[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024+:`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024] = cfgs_ff_dfi_t_ctrlupd_interval_max_x1024[(`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024) -1:0];
      r91_dfiupd1[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024+:`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024] = cfgs_ff_dfi_t_ctrlupd_interval_min_x1024[(`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFIUPD2
   //------------------------
   always_comb begin : r92_dfiupd2_combo_PROC
      r92_dfiupd2 = {REG_WIDTH {1'b0}};
      r92_dfiupd2[`UMCTL2_REG_OFFSET_DFIUPD2_DFI_PHYUPD_EN+:`UMCTL2_REG_SIZE_DFIUPD2_DFI_PHYUPD_EN] = cfgs_ff_dfi_phyupd_en;
   end
   //------------------------
   // Register UMCTL2_REGS.DFIMISC
   //------------------------
   always_comb begin : r94_dfimisc_combo_PROC
      r94_dfimisc = {REG_WIDTH {1'b0}};
      r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN] = ff_dfi_init_complete_en;
      r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_PHY_DBI_MODE+:`UMCTL2_REG_SIZE_DFIMISC_PHY_DBI_MODE] = ff_phy_dbi_mode;
      r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_CTL_IDLE_EN+:`UMCTL2_REG_SIZE_DFIMISC_CTL_IDLE_EN] = ff_ctl_idle_en;
      r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_START+:`UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_START] = ff_dfi_init_start;
      r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DIS_DYN_ADR_TRI+:`UMCTL2_REG_SIZE_DFIMISC_DIS_DYN_ADR_TRI] = ff_dis_dyn_adr_tri;
      r94_dfimisc[`UMCTL2_REG_OFFSET_DFIMISC_DFI_FREQUENCY+:`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY] = ff_dfi_frequency[(`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DFITMG3
   //------------------------
   always_comb begin : r96_dfitmg3_combo_PROC
      r96_dfitmg3 = {REG_WIDTH {1'b0}};
      r96_dfitmg3[`UMCTL2_REG_OFFSET_DFITMG3_DFI_T_GEARDOWN_DELAY+:`UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY] = cfgs_ff_dfi_t_geardown_delay[(`UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DBICTL
   //------------------------
   always_comb begin : r98_dbictl_combo_PROC
      r98_dbictl = {REG_WIDTH {1'b0}};
      r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_DM_EN+:`UMCTL2_REG_SIZE_DBICTL_DM_EN] = ff_dm_en;
      r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_WR_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_WR_DBI_EN] = ff_wr_dbi_en;
      r98_dbictl[`UMCTL2_REG_OFFSET_DBICTL_RD_DBI_EN+:`UMCTL2_REG_SIZE_DBICTL_RD_DBI_EN] = ff_rd_dbi_en;
   end
   //------------------------
   // Register UMCTL2_REGS.DFIPHYMSTR
   //------------------------
   always_comb begin : r99_dfiphymstr_combo_PROC
      r99_dfiphymstr = {REG_WIDTH {1'b0}};
      r99_dfiphymstr[`UMCTL2_REG_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`UMCTL2_REG_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN] = ff_dfi_phymstr_en;
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP0
   //------------------------
   always_comb begin : r100_addrmap0_combo_PROC
      r100_addrmap0 = {REG_WIDTH {1'b0}};
      r100_addrmap0[`UMCTL2_REG_OFFSET_ADDRMAP0_ADDRMAP_CS_BIT0+:`UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0] = cfgs_ff_addrmap_cs_bit0[(`UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP1
   //------------------------
   always_comb begin : r101_addrmap1_combo_PROC
      r101_addrmap1 = {REG_WIDTH {1'b0}};
      r101_addrmap1[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B0+:`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0] = cfgs_ff_addrmap_bank_b0[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0) -1:0];
      r101_addrmap1[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B1+:`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1] = cfgs_ff_addrmap_bank_b1[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1) -1:0];
      r101_addrmap1[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B2+:`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2] = cfgs_ff_addrmap_bank_b2[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP2
   //------------------------
   always_comb begin : r102_addrmap2_combo_PROC
      r102_addrmap2 = {REG_WIDTH {1'b0}};
      r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B2+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2] = cfgs_ff_addrmap_col_b2[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2) -1:0];
      r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B3+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3] = cfgs_ff_addrmap_col_b3[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3) -1:0];
      r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B4+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4] = cfgs_ff_addrmap_col_b4[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4) -1:0];
      r102_addrmap2[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B5+:`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5] = cfgs_ff_addrmap_col_b5[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP3
   //------------------------
   always_comb begin : r103_addrmap3_combo_PROC
      r103_addrmap3 = {REG_WIDTH {1'b0}};
      r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B6+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6] = cfgs_ff_addrmap_col_b6[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6) -1:0];
      r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B7+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7] = cfgs_ff_addrmap_col_b7[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7) -1:0];
      r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B8+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8] = cfgs_ff_addrmap_col_b8[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8) -1:0];
      r103_addrmap3[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B9+:`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9] = cfgs_ff_addrmap_col_b9[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP4
   //------------------------
   always_comb begin : r104_addrmap4_combo_PROC
      r104_addrmap4 = {REG_WIDTH {1'b0}};
      r104_addrmap4[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B10+:`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10] = cfgs_ff_addrmap_col_b10[(`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10) -1:0];
      r104_addrmap4[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B11+:`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11] = cfgs_ff_addrmap_col_b11[(`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP5
   //------------------------
   always_comb begin : r105_addrmap5_combo_PROC
      r105_addrmap5 = {REG_WIDTH {1'b0}};
      r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B0+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0] = cfgs_ff_addrmap_row_b0[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0) -1:0];
      r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B1+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1] = cfgs_ff_addrmap_row_b1[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1) -1:0];
      r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B2_10+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10] = cfgs_ff_addrmap_row_b2_10[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10) -1:0];
      r105_addrmap5[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B11+:`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11] = cfgs_ff_addrmap_row_b11[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP6
   //------------------------
   always_comb begin : r106_addrmap6_combo_PROC
      r106_addrmap6 = {REG_WIDTH {1'b0}};
      r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B12+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12] = ff_addrmap_row_b12[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12) -1:0];
      r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B13+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13] = ff_addrmap_row_b13[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13) -1:0];
      r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B14+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14] = ff_addrmap_row_b14[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14) -1:0];
      r106_addrmap6[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B15+:`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15] = ff_addrmap_row_b15[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP7
   //------------------------
   always_comb begin : r107_addrmap7_combo_PROC
      r107_addrmap7 = {REG_WIDTH {1'b0}};
      r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16] = ff_addrmap_row_b16[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16) -1:0];
      r107_addrmap7[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17+:`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17] = ff_addrmap_row_b17[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP8
   //------------------------
   always_comb begin : r108_addrmap8_combo_PROC
      r108_addrmap8 = {REG_WIDTH {1'b0}};
      r108_addrmap8[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B0+:`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0] = cfgs_ff_addrmap_bg_b0[(`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0) -1:0];
      r108_addrmap8[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B1+:`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1] = cfgs_ff_addrmap_bg_b1[(`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP9
   //------------------------
   always_comb begin : r109_addrmap9_combo_PROC
      r109_addrmap9 = {REG_WIDTH {1'b0}};
      r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B2+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2] = cfgs_ff_addrmap_row_b2[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2) -1:0];
      r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B3+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3] = cfgs_ff_addrmap_row_b3[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3) -1:0];
      r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B4+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4] = cfgs_ff_addrmap_row_b4[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4) -1:0];
      r109_addrmap9[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B5+:`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5] = cfgs_ff_addrmap_row_b5[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP10
   //------------------------
   always_comb begin : r110_addrmap10_combo_PROC
      r110_addrmap10 = {REG_WIDTH {1'b0}};
      r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B6+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6] = cfgs_ff_addrmap_row_b6[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6) -1:0];
      r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B7+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7] = cfgs_ff_addrmap_row_b7[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7) -1:0];
      r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B8+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8] = cfgs_ff_addrmap_row_b8[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8) -1:0];
      r110_addrmap10[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B9+:`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9] = cfgs_ff_addrmap_row_b9[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP11
   //------------------------
   always_comb begin : r111_addrmap11_combo_PROC
      r111_addrmap11 = {REG_WIDTH {1'b0}};
      r111_addrmap11[`UMCTL2_REG_OFFSET_ADDRMAP11_ADDRMAP_ROW_B10+:`UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10] = cfgs_ff_addrmap_row_b10[(`UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ODTCFG
   //------------------------
   always_comb begin : r113_odtcfg_combo_PROC
      r113_odtcfg = {REG_WIDTH {1'b0}};
      r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_DELAY+:`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY] = cfgs_ff_rd_odt_delay[(`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY) -1:0];
      r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_HOLD+:`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD] = cfgs_ff_rd_odt_hold[(`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD) -1:0];
      r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_DELAY+:`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY] = cfgs_ff_wr_odt_delay[(`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY) -1:0];
      r113_odtcfg[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_HOLD+:`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD] = cfgs_ff_wr_odt_hold[(`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.ODTMAP
   //------------------------
   always_comb begin : r114_odtmap_combo_PROC
      r114_odtmap = {REG_WIDTH {1'b0}};
      r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_WR_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT] = cfgs_ff_rank0_wr_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT) -1:0];
      r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_RD_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT] = cfgs_ff_rank0_rd_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT) -1:0];
      r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_WR_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT] = cfgs_ff_rank1_wr_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT) -1:0];
      r114_odtmap[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_RD_ODT+:`UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT] = cfgs_ff_rank1_rd_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.SCHED
   //------------------------
   always_comb begin : r115_sched_combo_PROC
      r115_sched = {REG_WIDTH {1'b0}};
      r115_sched[`UMCTL2_REG_OFFSET_SCHED_PREFER_WRITE+:`UMCTL2_REG_SIZE_SCHED_PREFER_WRITE] = cfgs_ff_prefer_write;
      r115_sched[`UMCTL2_REG_OFFSET_SCHED_PAGECLOSE+:`UMCTL2_REG_SIZE_SCHED_PAGECLOSE] = cfgs_ff_pageclose;
      r115_sched[`UMCTL2_REG_OFFSET_SCHED_AUTOPRE_RMW+:`UMCTL2_REG_SIZE_SCHED_AUTOPRE_RMW] = cfgs_ff_autopre_rmw;
      r115_sched[`UMCTL2_REG_OFFSET_SCHED_LPR_NUM_ENTRIES+:`UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES] = cfgs_ff_lpr_num_entries[(`UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES) -1:0];
      r115_sched[`UMCTL2_REG_OFFSET_SCHED_GO2CRITICAL_HYSTERESIS+:`UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS] = cfgs_ff_go2critical_hysteresis[(`UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS) -1:0];
      r115_sched[`UMCTL2_REG_OFFSET_SCHED_RDWR_IDLE_GAP+:`UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP] = cfgs_ff_rdwr_idle_gap[(`UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.SCHED1
   //------------------------
   always_comb begin : r116_sched1_combo_PROC
      r116_sched1 = {REG_WIDTH {1'b0}};
      r116_sched1[`UMCTL2_REG_OFFSET_SCHED1_PAGECLOSE_TIMER+:`UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER] = cfgs_ff_pageclose_timer[(`UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.PERFHPR1
   //------------------------
   always_comb begin : r118_perfhpr1_combo_PROC
      r118_perfhpr1 = {REG_WIDTH {1'b0}};
      r118_perfhpr1[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_MAX_STARVE+:`UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE] = cfgs_ff_hpr_max_starve[(`UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE) -1:0];
      r118_perfhpr1[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH+:`UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH] = cfgs_ff_hpr_xact_run_length[(`UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.PERFLPR1
   //------------------------
   always_comb begin : r119_perflpr1_combo_PROC
      r119_perflpr1 = {REG_WIDTH {1'b0}};
      r119_perflpr1[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_MAX_STARVE+:`UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE] = cfgs_ff_lpr_max_starve[(`UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE) -1:0];
      r119_perflpr1[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH+:`UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH] = cfgs_ff_lpr_xact_run_length[(`UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.PERFWR1
   //------------------------
   always_comb begin : r120_perfwr1_combo_PROC
      r120_perfwr1 = {REG_WIDTH {1'b0}};
      r120_perfwr1[`UMCTL2_REG_OFFSET_PERFWR1_W_MAX_STARVE+:`UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE] = cfgs_ff_w_max_starve[(`UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE) -1:0];
      r120_perfwr1[`UMCTL2_REG_OFFSET_PERFWR1_W_XACT_RUN_LENGTH+:`UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH] = cfgs_ff_w_xact_run_length[(`UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH) -1:0];
   end
   //------------------------
   // Register UMCTL2_REGS.DBG0
   //------------------------
   always_comb begin : r145_dbg0_combo_PROC
      r145_dbg0 = {REG_WIDTH {1'b0}};
      r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_WC+:`UMCTL2_REG_SIZE_DBG0_DIS_WC] = cfgs_ff_dis_wc;
      r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_COLLISION_PAGE_OPT+:`UMCTL2_REG_SIZE_DBG0_DIS_COLLISION_PAGE_OPT] = cfgs_ff_dis_collision_page_opt;
      r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_RD_OPT+:`UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_RD_OPT] = cfgs_ff_dis_max_rank_rd_opt;
      r145_dbg0[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_WR_OPT+:`UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_WR_OPT] = cfgs_ff_dis_max_rank_wr_opt;
   end
   //------------------------
   // Register UMCTL2_REGS.DBG1
   //------------------------
   always_comb begin : r146_dbg1_combo_PROC
      r146_dbg1 = {REG_WIDTH {1'b0}};
      r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_DQ+:`UMCTL2_REG_SIZE_DBG1_DIS_DQ] = ff_dis_dq;
      r146_dbg1[`UMCTL2_REG_OFFSET_DBG1_DIS_HIF+:`UMCTL2_REG_SIZE_DBG1_DIS_HIF] = ff_dis_hif;
   end
   //------------------------
   // Register UMCTL2_REGS.DBGCMD
   //------------------------
   always_comb begin : r148_dbgcmd_combo_PROC
      r148_dbgcmd = {REG_WIDTH {1'b0}};
      r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_RANK0_REFRESH+:`UMCTL2_REG_SIZE_DBGCMD_RANK0_REFRESH] = ff_rank0_refresh;
      r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_RANK1_REFRESH+:`UMCTL2_REG_SIZE_DBGCMD_RANK1_REFRESH] = ff_rank1_refresh;
      r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_ZQ_CALIB_SHORT+:`UMCTL2_REG_SIZE_DBGCMD_ZQ_CALIB_SHORT] = ff_zq_calib_short;
      r148_dbgcmd[`UMCTL2_REG_OFFSET_DBGCMD_CTRLUPD+:`UMCTL2_REG_SIZE_DBGCMD_CTRLUPD] = ff_ctrlupd;
   end
   //------------------------
   // Register UMCTL2_REGS.SWCTL
   //------------------------
   always_comb begin : r151_swctl_combo_PROC
      r151_swctl = {REG_WIDTH {1'b0}};
      r151_swctl[`UMCTL2_REG_OFFSET_SWCTL_SW_DONE+:`UMCTL2_REG_SIZE_SWCTL_SW_DONE] = cfgs_ff_sw_done;
   end
   //------------------------
   // Register UMCTL2_REGS.SWCTLSTATIC
   //------------------------
   always_comb begin : r153_swctlstatic_combo_PROC
      r153_swctlstatic = {REG_WIDTH {1'b0}};
      r153_swctlstatic[`UMCTL2_REG_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK+:`UMCTL2_REG_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK] = cfgs_ff_sw_static_unlock;
   end
   //------------------------
   // Register UMCTL2_REGS.POISONCFG
   //------------------------
   always_comb begin : r169_poisoncfg_combo_PROC
      r169_poisoncfg = {REG_WIDTH {1'b0}};
      r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_SLVERR_EN] = ff_wr_poison_slverr_en;
      r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_EN] = ff_wr_poison_intr_en;
      r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_CLR+:`UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_CLR] = ff_wr_poison_intr_clr;
      r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_SLVERR_EN] = ff_rd_poison_slverr_en;
      r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_EN] = ff_rd_poison_intr_en;
      r169_poisoncfg[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_CLR+:`UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_CLR] = ff_rd_poison_intr_clr;
   end
   //------------------------
   // Register UMCTL2_MP.PCCFG
   //------------------------
   always_comb begin : r194_pccfg_combo_PROC
      r194_pccfg = {REG_WIDTH {1'b0}};
      r194_pccfg[`UMCTL2_REG_OFFSET_PCCFG_GO2CRITICAL_EN+:`UMCTL2_REG_SIZE_PCCFG_GO2CRITICAL_EN] = cfgs_ff_go2critical_en;
      r194_pccfg[`UMCTL2_REG_OFFSET_PCCFG_PAGEMATCH_LIMIT+:`UMCTL2_REG_SIZE_PCCFG_PAGEMATCH_LIMIT] = cfgs_ff_pagematch_limit;
      r194_pccfg[`UMCTL2_REG_OFFSET_PCCFG_BL_EXP_MODE+:`UMCTL2_REG_SIZE_PCCFG_BL_EXP_MODE] = cfgs_ff_bl_exp_mode;
   end
   //------------------------
   // Register UMCTL2_MP.PCFGR_0
   //------------------------
   always_comb begin : r195_pcfgr_0_combo_PROC
      r195_pcfgr_0 = {REG_WIDTH {1'b0}};
      r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PRIORITY_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0] = cfgs_ff_rd_port_priority_0[(`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0) -1:0];
      r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_AGING_EN_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_AGING_EN_0] = cfgs_ff_rd_port_aging_en_0;
      r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_URGENT_EN_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_URGENT_EN_0] = cfgs_ff_rd_port_urgent_en_0;
      r195_pcfgr_0[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PAGEMATCH_EN_0+:`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PAGEMATCH_EN_0] = cfgs_ff_rd_port_pagematch_en_0;
   end
   //------------------------
   // Register UMCTL2_MP.PCFGW_0
   //------------------------
   always_comb begin : r196_pcfgw_0_combo_PROC
      r196_pcfgw_0 = {REG_WIDTH {1'b0}};
      r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PRIORITY_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0] = cfgs_ff_wr_port_priority_0[(`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0) -1:0];
      r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_AGING_EN_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_AGING_EN_0] = cfgs_ff_wr_port_aging_en_0;
      r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_URGENT_EN_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_URGENT_EN_0] = cfgs_ff_wr_port_urgent_en_0;
      r196_pcfgw_0[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PAGEMATCH_EN_0+:`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PAGEMATCH_EN_0] = cfgs_ff_wr_port_pagematch_en_0;
   end
   //------------------------
   // Register UMCTL2_MP.PCTRL_0
   //------------------------
   always_comb begin : r230_pctrl_0_combo_PROC
      r230_pctrl_0 = {REG_WIDTH {1'b0}};
      r230_pctrl_0[`UMCTL2_REG_OFFSET_PCTRL_0_PORT_EN_0+:`UMCTL2_REG_SIZE_PCTRL_0_PORT_EN_0] = ff_port_en_0;
   end
   //------------------------
   // Register UMCTL2_MP.PCFGQOS0_0
   //------------------------
   always_comb begin : r231_pcfgqos0_0_combo_PROC
      r231_pcfgqos0_0 = {REG_WIDTH {1'b0}};
      r231_pcfgqos0_0[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_LEVEL1_0+:`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0] = cfgs_ff_rqos_map_level1_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0) -1:0];
      r231_pcfgqos0_0[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION0_0+:`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0] = cfgs_ff_rqos_map_region0_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0) -1:0];
      r231_pcfgqos0_0[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION1_0+:`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0] = cfgs_ff_rqos_map_region1_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0) -1:0];
   end
   //------------------------
   // Register UMCTL2_MP.PCFGQOS1_0
   //------------------------
   always_comb begin : r232_pcfgqos1_0_combo_PROC
      r232_pcfgqos1_0 = {REG_WIDTH {1'b0}};
      r232_pcfgqos1_0[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0+:`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0] = cfgs_ff_rqos_map_timeoutb_0[(`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0) -1:0];
      r232_pcfgqos1_0[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0+:`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0] = cfgs_ff_rqos_map_timeoutr_0[(`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0) -1:0];
   end
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS0_0
   //------------------------
   always_comb begin : r233_pcfgwqos0_0_combo_PROC
      r233_pcfgwqos0_0 = {REG_WIDTH {1'b0}};
      r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0] = cfgs_ff_wqos_map_level1_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0) -1:0];
      r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0] = cfgs_ff_wqos_map_level2_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0) -1:0];
      r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION0_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0] = cfgs_ff_wqos_map_region0_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0) -1:0];
      r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION1_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0] = cfgs_ff_wqos_map_region1_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0) -1:0];
      r233_pcfgwqos0_0[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION2_0+:`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0] = cfgs_ff_wqos_map_region2_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0) -1:0];
   end
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS1_0
   //------------------------
   always_comb begin : r234_pcfgwqos1_0_combo_PROC
      r234_pcfgwqos1_0 = {REG_WIDTH {1'b0}};
      r234_pcfgwqos1_0[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0+:`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0] = cfgs_ff_wqos_map_timeout1_0[(`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0) -1:0];
      r234_pcfgwqos1_0[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0+:`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0] = cfgs_ff_wqos_map_timeout2_0[(`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0) -1:0];
   end



   always @ (posedge pclk or negedge presetn) begin : sample_pclk_wdata_PROC
      if (~presetn) begin
         apb_data_r  <= {APB_DW{1'b0}};
      end else begin
         apb_data_r  <= pwdata;
      end
   end

   always_comb begin : expand_data_PROC
      apb_data_expanded={REG_WIDTH{1'b0}};
      apb_data_expanded[REG_WIDTH-1:0]=apb_data_r[REG_WIDTH-1:0];
   end
   

   always @(posedge pclk or negedge presetn) begin : sample_pclk_regfields_PROC
      if (~presetn) begin
         ff_ddr3 <= (`MEMC_DDR3_EN==1) ? 'h1 : 'h0;
         ff_ddr4 <= 'h0;
         ff_burstchop <= 'h0;
         ff_en_2t_timing_mode <= 'h0;
         ff_geardown_mode <= 'h0;
         ff_data_bus_width <= 'h0;
         ff_dll_off_mode <= 'h0;
         ff_burst_rdwr <= 'h4;
         ff_active_ranks <= (`MEMC_NUM_RANKS>=4) ? 'hF :((`MEMC_NUM_RANKS==2) ? 'h3 : 'h1);
         ff_device_config <= 'h0;
         ff_mr_type <= 'h0;
         ff_mpr_en <= 'h0;
         ff_pda_en <= 'h0;
         ff_sw_init_int <= 'h0;
         ff_mr_rank <= (`MEMC_NUM_RANKS==4) ? 'hF :((`MEMC_NUM_RANKS==2) ? 'h3 : 'h1);
         ff_mr_addr <= 'h0;
         ff_pba_mode <= 'h0;
         ff_mr_wr_todo  <= 1'b0;
         ff_mr_wr_saved <= 1'b0;
         ff_mr_wr <= 'h0;
         ff_mr_data <= 'h0;
         ff_mr_device_sel <= 'h0;
         ff_selfref_en <= 'h0;
         ff_powerdown_en <= 'h0;
         ff_en_dfi_dram_clk_disable <= 'h0;
         ff_mpsm_en <= 'h0;
         ff_selfref_sw <= 'h0;
         ff_dis_cam_drain_selfref <= 'h0;
         cfgs_ff_powerdown_to_x32 <= 'h10;
         cfgs_ff_selfref_to_x32 <= 'h40;
         cfgs_ff_hw_lp_en <= 'h1;
         cfgs_ff_hw_lp_exit_idle_en <= 'h1;
         cfgs_ff_hw_lp_idle_x32 <= 'h0;
         ff_refresh_burst <= 'h0;
         ff_refresh_to_x1_x32 <= 'h10;
         ff_refresh_margin <= 'h2;
         ff_refresh_timer0_start_value_x32 <= 'h0;
         ff_refresh_timer1_start_value_x32 <= 'h0;
         ff_dis_auto_refresh <= 'h0;
         ff_refresh_update_level <= 'h0;
         ff_refresh_mode <= 'h0;
         ff_t_rfc_min <= 'h8c;
         ff_t_rfc_nom_x1_x32 <= 'h62;
         ff_dfi_alert_err_int_en <= 'h0;
         ff_dfi_alert_err_int_clr <= 'h0;
         ff_dfi_alert_err_cnt_clr <= 'h0;
         ff_parity_enable <= 'h0;
         ff_crc_enable <= 'h0;
         ff_crc_inc_dm <= 'h0;
         ff_caparity_disable_before_sr <= 'h1;
         ff_pre_cke_x1024 <= 'h4e;
         ff_post_cke_x1024 <= 'h2;
         ff_skip_dram_init <= 'h0;
         cfgs_ff_pre_ocd_x32 <= 'h0;
         cfgs_ff_dram_rstn_x1024 <= 'h0;
         cfgs_ff_emr <= 'h510;
         cfgs_ff_mr <= 'h0;
         ff_emr3 <= 'h0;
         ff_emr2 <= 'h0;
         cfgs_ff_dev_zqinit_x32 <= 'h10;
         cfgs_ff_mr5 <= 'h0;
         cfgs_ff_mr4 <= 'h0;
         cfgs_ff_mr6 <= 'h0;
         ff_dimm_stagger_cs_en <= 'h0;
         ff_dimm_addr_mirr_en <= 'h0;
         ff_dimm_output_inv_en <= 'h0;
         ff_mrs_a17_en <= 'h0;
         ff_mrs_bg1_en <= 'h0;
         ff_dimm_dis_bg_mirroring <= 'h0;
         ff_lrdimm_bcom_cmd_prot <= 'h0;
         ff_rcd_weak_drive <= 'h0;
         ff_rcd_a_output_disabled <= 'h0;
         ff_rcd_b_output_disabled <= 'h0;
         cfgs_ff_max_rank_rd <= (`UPCTL2_EN==1) ? 'h0 : 'hF;
         cfgs_ff_diff_rank_rd_gap <= 'h6;
         cfgs_ff_diff_rank_wr_gap <= 'h6;
         cfgs_ff_max_rank_wr <= 'h0;
         cfgs_ff_diff_rank_rd_gap_msb <= 'h0;
         cfgs_ff_diff_rank_wr_gap_msb <= 'h0;
         cfgs_ff_t_ras_min <= 'hf;
         cfgs_ff_t_ras_max <= 'h1b;
         cfgs_ff_t_faw <= 'h10;
         cfgs_ff_wr2pre <= 'hf;
         cfgs_ff_t_rc <= 'h14;
         cfgs_ff_rd2pre <= 'h4;
         cfgs_ff_t_xp <= 'h8;
         cfgs_ff_wr2rd <= 'hd;
         cfgs_ff_rd2wr <= 'h6;
         cfgs_ff_read_latency <= 'h5;
         cfgs_ff_write_latency <= 'h3;
         cfgs_ff_t_mod <= (`MEMC_DDR3_EN==1 || `MEMC_DDR4_EN==1 ) ? 'hc : 'h0;
         cfgs_ff_t_mrd <= 'h4;
         cfgs_ff_t_rp <= 'h5;
         cfgs_ff_t_rrd <= 'h4;
         cfgs_ff_t_ccd <= 'h4;
         cfgs_ff_t_rcd <= 'h5;
         cfgs_ff_t_cke <= 'h3;
         cfgs_ff_t_ckesr <= 'h4;
         cfgs_ff_t_cksre <= 'h5;
         cfgs_ff_t_cksrx <= 'h5;
         cfgs_ff_t_xs_x32 <= 'h5;
         cfgs_ff_t_xs_dll_x32 <= 'h44;
         cfgs_ff_t_xs_abort_x32 <= 'h3;
         cfgs_ff_t_xs_fast_x32 <= 'h3;
         cfgs_ff_wr2rd_s <= 'hd;
         cfgs_ff_t_rrd_s <= 'h4;
         cfgs_ff_t_ccd_s <= 'h4;
         cfgs_ff_ddr4_wr_preamble <= 'h0;
         ff_t_gear_hold <= 'h2;
         ff_t_gear_setup <= 'h2;
         ff_t_cmd_gear <= 'h18;
         ff_t_sync_gear <= 'h1c;
         cfgs_ff_t_ckmpe <= 'h1c;
         cfgs_ff_t_mpx_s <= 'h2;
         cfgs_ff_t_mpx_lh <= 'hc;
         cfgs_ff_post_mpsm_gap_x32 <= 'h44;
         cfgs_ff_t_mrd_pda <= 'h10;
         cfgs_ff_t_wr_mpr <= 'h1a;
         cfgs_ff_t_stab_x32 <= 'h0;
         cfgs_ff_en_dfi_lp_t_stab <= 'h0;
         ff_t_zq_short_nop <= 'h40;
         ff_t_zq_long_nop <= 'h200;
         ff_dis_mpsmx_zqcl <= 'h0;
         ff_zq_resistor_shared <= 'h0;
         ff_dis_srx_zqcl <= 'h0;
         ff_dis_auto_zq <= 'h0;
         cfgs_ff_t_zq_short_interval_x1024 <= 'h100;
         cfgs_ff_dfi_tphy_wrlat <= 'h2;
         cfgs_ff_dfi_tphy_wrdata <= 'h0;
         cfgs_ff_dfi_wrdata_use_dfi_phy_clk <= 'h0;
         cfgs_ff_dfi_t_rddata_en <= 'h2;
         cfgs_ff_dfi_rddata_use_dfi_phy_clk <= 'h0;
         cfgs_ff_dfi_t_ctrl_delay <= 'h7;
         ff_dfi_t_dram_clk_enable <= 'h4;
         ff_dfi_t_dram_clk_disable <= 'h4;
         ff_dfi_t_wrdata_delay <= 'h0;
         ff_dfi_t_parin_lat <= 'h0;
         ff_dfi_t_cmd_lat <= 'h0;
         ff_dfi_lp_en_pd <= 'h0;
         ff_dfi_lp_wakeup_pd <= 'h0;
         ff_dfi_lp_en_sr <= 'h0;
         ff_dfi_lp_wakeup_sr <= 'h0;
         ff_dfi_tlp_resp <= 'h7;
         cfgs_ff_dfi_lp_en_mpsm <= 'h0;
         cfgs_ff_dfi_lp_wakeup_mpsm <= 'h0;
         cfgs_ff_dfi_t_ctrlup_min <= 'h3;
         cfgs_ff_dfi_t_ctrlup_max <= 'h40;
         cfgs_ff_ctrlupd_pre_srx <= 'h0;
         cfgs_ff_dis_auto_ctrlupd_srx <= 'h0;
         cfgs_ff_dis_auto_ctrlupd <= 'h0;
         cfgs_ff_dfi_t_ctrlupd_interval_max_x1024 <= 'h1;
         cfgs_ff_dfi_t_ctrlupd_interval_min_x1024 <= 'h1;
         cfgs_ff_dfi_phyupd_en <= 'h1;
         ff_dfi_init_complete_en <= 'h1;
         ff_phy_dbi_mode <= 'h0;
         ff_ctl_idle_en <= 'h0;
         ff_dfi_init_start <= 'h0;
         ff_dis_dyn_adr_tri <= 'h1;
         ff_dfi_frequency <= 'h0;
         cfgs_ff_dfi_t_geardown_delay <= 'h0;
         ff_dm_en <= 'h1;
         ff_wr_dbi_en <= 'h0;
         ff_rd_dbi_en <= 'h0;
         ff_dfi_phymstr_en <= 'h1;
         cfgs_ff_addrmap_cs_bit0 <= 'h0;
         cfgs_ff_addrmap_bank_b0 <= 'h0;
         cfgs_ff_addrmap_bank_b1 <= 'h0;
         cfgs_ff_addrmap_bank_b2 <= 'h0;
         cfgs_ff_addrmap_col_b2 <= 'h0;
         cfgs_ff_addrmap_col_b3 <= 'h0;
         cfgs_ff_addrmap_col_b4 <= 'h0;
         cfgs_ff_addrmap_col_b5 <= 'h0;
         cfgs_ff_addrmap_col_b6 <= 'h0;
         cfgs_ff_addrmap_col_b7 <= 'h0;
         cfgs_ff_addrmap_col_b8 <= 'h0;
         cfgs_ff_addrmap_col_b9 <= 'h0;
         cfgs_ff_addrmap_col_b10 <= 'h0;
         cfgs_ff_addrmap_col_b11 <= 'h0;
         cfgs_ff_addrmap_row_b0 <= 'h0;
         cfgs_ff_addrmap_row_b1 <= 'h0;
         cfgs_ff_addrmap_row_b2_10 <= 'h0;
         cfgs_ff_addrmap_row_b11 <= 'h0;
         ff_addrmap_row_b12 <= 'h0;
         ff_addrmap_row_b13 <= 'h0;
         ff_addrmap_row_b14 <= 'h0;
         ff_addrmap_row_b15 <= 'h0;
         ff_addrmap_row_b16 <= 'h0;
         ff_addrmap_row_b17 <= 'h0;
         cfgs_ff_addrmap_bg_b0 <= 'h0;
         cfgs_ff_addrmap_bg_b1 <= 'h0;
         cfgs_ff_addrmap_row_b2 <= 'h0;
         cfgs_ff_addrmap_row_b3 <= 'h0;
         cfgs_ff_addrmap_row_b4 <= 'h0;
         cfgs_ff_addrmap_row_b5 <= 'h0;
         cfgs_ff_addrmap_row_b6 <= 'h0;
         cfgs_ff_addrmap_row_b7 <= 'h0;
         cfgs_ff_addrmap_row_b8 <= 'h0;
         cfgs_ff_addrmap_row_b9 <= 'h0;
         cfgs_ff_addrmap_row_b10 <= 'h0;
         cfgs_ff_rd_odt_delay <= 'h0;
         cfgs_ff_rd_odt_hold <= 'h4;
         cfgs_ff_wr_odt_delay <= 'h0;
         cfgs_ff_wr_odt_hold <= 'h4;
         cfgs_ff_rank0_wr_odt <= 'h1;
         cfgs_ff_rank0_rd_odt <= 'h1;
         cfgs_ff_rank1_wr_odt <= (`MEMC_NUM_RANKS>1) ? 'h2 : 'h0;
         cfgs_ff_rank1_rd_odt <= (`MEMC_NUM_RANKS>1) ? 'h2 : 'h0;
         cfgs_ff_prefer_write <= 'h0;
         cfgs_ff_pageclose <= 'h1;
         cfgs_ff_autopre_rmw <= 'h0;
         cfgs_ff_lpr_num_entries <= $unsigned(`MEMC_NO_OF_ENTRY/2);
         cfgs_ff_go2critical_hysteresis <= 'h0;
         cfgs_ff_rdwr_idle_gap <= 'h0;
         cfgs_ff_pageclose_timer <= 'h0;
         cfgs_ff_hpr_max_starve <= 'h1;
         cfgs_ff_hpr_xact_run_length <= 'hf;
         cfgs_ff_lpr_max_starve <= 'h7f;
         cfgs_ff_lpr_xact_run_length <= 'hf;
         cfgs_ff_w_max_starve <= 'h7f;
         cfgs_ff_w_xact_run_length <= 'hf;
         cfgs_ff_dis_wc <= (`UPCTL2_EN==1) ? 'h1 : 'h0;
         cfgs_ff_dis_collision_page_opt <= 'h0;
         cfgs_ff_dis_max_rank_rd_opt <= 'h0;
         cfgs_ff_dis_max_rank_wr_opt <= 'h0;
         ff_dis_dq <= 'h0;
         ff_dis_hif <= 'h0;
         ff_rank0_refresh_todo  <= 1'b0;
         ff_rank0_refresh_saved <= 1'b0;
         ff_rank0_refresh <= 'h0;
         ff_rank1_refresh_todo  <= 1'b0;
         ff_rank1_refresh_saved <= 1'b0;
         ff_rank1_refresh <= 'h0;
         ff_zq_calib_short_todo  <= 1'b0;
         ff_zq_calib_short_saved <= 1'b0;
         ff_zq_calib_short <= 'h0;
         ff_ctrlupd_todo  <= 1'b0;
         ff_ctrlupd_saved <= 1'b0;
         ff_ctrlupd <= 'h0;
         cfgs_ff_sw_done <= 'h1;
         cfgs_ff_sw_static_unlock <= 'h0;
         ff_wr_poison_slverr_en <= 'h1;
         ff_wr_poison_intr_en <= 'h1;
         ff_wr_poison_intr_clr <= 'h0;
         ff_rd_poison_slverr_en <= 'h1;
         ff_rd_poison_intr_en <= 'h1;
         ff_rd_poison_intr_clr <= 'h0;
         cfgs_ff_go2critical_en <= 'h0;
         cfgs_ff_pagematch_limit <= 'h0;
         cfgs_ff_bl_exp_mode <= 'h0;
         cfgs_ff_rd_port_priority_0 <= 'h0;
         cfgs_ff_rd_port_aging_en_0 <= 'h0;
         cfgs_ff_rd_port_urgent_en_0 <= 'h0;
         cfgs_ff_rd_port_pagematch_en_0 <= (`MEMC_DDR4_EN==1) ? 'h0 : 'h1;
         cfgs_ff_wr_port_priority_0 <= 'h0;
         cfgs_ff_wr_port_aging_en_0 <= 'h0;
         cfgs_ff_wr_port_urgent_en_0 <= 'h0;
         cfgs_ff_wr_port_pagematch_en_0 <= 'h1;
         ff_port_en_0 <= $unsigned(`UMCTL2_PORT_EN_RESET_VALUE);
         cfgs_ff_rqos_map_level1_0 <= 'h0;
         cfgs_ff_rqos_map_region0_0 <= 'h0;
         cfgs_ff_rqos_map_region1_0 <= 'h0;
         cfgs_ff_rqos_map_timeoutb_0 <= 'h0;
         cfgs_ff_rqos_map_timeoutr_0 <= 'h0;
         cfgs_ff_wqos_map_level1_0 <= 'h0;
         cfgs_ff_wqos_map_level2_0 <= 'he;
         cfgs_ff_wqos_map_region0_0 <= 'h0;
         cfgs_ff_wqos_map_region1_0 <= 'h0;
         cfgs_ff_wqos_map_region2_0 <= 'h0;
         cfgs_ff_wqos_map_timeout1_0 <= 'h0;
         cfgs_ff_wqos_map_timeout2_0 <= 'h0;

      end else begin
   //------------------------
   // Register UMCTL2_REGS.MSTR
   //------------------------
         if (rwselect[0] && write_en) begin
            ff_ddr3 <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_DDR3 +: `UMCTL2_REG_SIZE_MSTR_DDR3] & umctl2_regs_mstr_ddr3_mask[`UMCTL2_REG_OFFSET_MSTR_DDR3 +: `UMCTL2_REG_SIZE_MSTR_DDR3];
         end
         if (rwselect[0] && write_en) begin
            ff_ddr4 <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_DDR4 +: `UMCTL2_REG_SIZE_MSTR_DDR4] & umctl2_regs_mstr_ddr4_mask[`UMCTL2_REG_OFFSET_MSTR_DDR4 +: `UMCTL2_REG_SIZE_MSTR_DDR4];
         end
         if (rwselect[0] && write_en) begin
            ff_burstchop <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_BURSTCHOP +: `UMCTL2_REG_SIZE_MSTR_BURSTCHOP] & umctl2_regs_mstr_burstchop_mask[`UMCTL2_REG_OFFSET_MSTR_BURSTCHOP +: `UMCTL2_REG_SIZE_MSTR_BURSTCHOP];
         end
         if (rwselect[0] && write_en) begin
            ff_en_2t_timing_mode <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_EN_2T_TIMING_MODE +: `UMCTL2_REG_SIZE_MSTR_EN_2T_TIMING_MODE] & umctl2_regs_mstr_en_2t_timing_mode_mask[`UMCTL2_REG_OFFSET_MSTR_EN_2T_TIMING_MODE +: `UMCTL2_REG_SIZE_MSTR_EN_2T_TIMING_MODE];
         end
         if (rwselect[0] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_geardown_mode <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_GEARDOWN_MODE +: `UMCTL2_REG_SIZE_MSTR_GEARDOWN_MODE] & umctl2_regs_mstr_geardown_mode_mask[`UMCTL2_REG_OFFSET_MSTR_GEARDOWN_MODE +: `UMCTL2_REG_SIZE_MSTR_GEARDOWN_MODE];
            end
         end
         if (rwselect[0] && write_en) begin
            ff_data_bus_width[(`UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_DATA_BUS_WIDTH +: `UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH] & umctl2_regs_mstr_data_bus_width_mask[`UMCTL2_REG_OFFSET_MSTR_DATA_BUS_WIDTH +: `UMCTL2_REG_SIZE_MSTR_DATA_BUS_WIDTH];
         end
         if (rwselect[0] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dll_off_mode <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_DLL_OFF_MODE +: `UMCTL2_REG_SIZE_MSTR_DLL_OFF_MODE] & umctl2_regs_mstr_dll_off_mode_mask[`UMCTL2_REG_OFFSET_MSTR_DLL_OFF_MODE +: `UMCTL2_REG_SIZE_MSTR_DLL_OFF_MODE];
            end
         end
         if (rwselect[0] && write_en) begin
            ff_burst_rdwr[(`UMCTL2_REG_SIZE_MSTR_BURST_RDWR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_BURST_RDWR +: `UMCTL2_REG_SIZE_MSTR_BURST_RDWR] & umctl2_regs_mstr_burst_rdwr_mask[`UMCTL2_REG_OFFSET_MSTR_BURST_RDWR +: `UMCTL2_REG_SIZE_MSTR_BURST_RDWR];
         end
         if (rwselect[0] && write_en) begin
            ff_active_ranks[(`UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_ACTIVE_RANKS +: `UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS] & umctl2_regs_mstr_active_ranks_mask[`UMCTL2_REG_OFFSET_MSTR_ACTIVE_RANKS +: `UMCTL2_REG_SIZE_MSTR_ACTIVE_RANKS];
         end
         if (rwselect[0] && write_en) begin
            ff_device_config[(`UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MSTR_DEVICE_CONFIG +: `UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG] & umctl2_regs_mstr_device_config_mask[`UMCTL2_REG_OFFSET_MSTR_DEVICE_CONFIG +: `UMCTL2_REG_SIZE_MSTR_DEVICE_CONFIG];
         end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL0
   //------------------------
         if (rwselect[3] && write_en) begin
            ff_mr_type <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_MR_TYPE +: `UMCTL2_REG_SIZE_MRCTRL0_MR_TYPE] & umctl2_regs_mrctrl0_mr_type_mask[`UMCTL2_REG_OFFSET_MRCTRL0_MR_TYPE +: `UMCTL2_REG_SIZE_MRCTRL0_MR_TYPE];
         end
         if (rwselect[3] && write_en) begin
            ff_mpr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_MPR_EN +: `UMCTL2_REG_SIZE_MRCTRL0_MPR_EN] & umctl2_regs_mrctrl0_mpr_en_mask[`UMCTL2_REG_OFFSET_MRCTRL0_MPR_EN +: `UMCTL2_REG_SIZE_MRCTRL0_MPR_EN];
         end
         if (rwselect[3] && write_en) begin
            ff_pda_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_PDA_EN +: `UMCTL2_REG_SIZE_MRCTRL0_PDA_EN] & umctl2_regs_mrctrl0_pda_en_mask[`UMCTL2_REG_OFFSET_MRCTRL0_PDA_EN +: `UMCTL2_REG_SIZE_MRCTRL0_PDA_EN];
         end
         if (rwselect[3] && write_en) begin
            ff_sw_init_int <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_SW_INIT_INT +: `UMCTL2_REG_SIZE_MRCTRL0_SW_INIT_INT] & umctl2_regs_mrctrl0_sw_init_int_mask[`UMCTL2_REG_OFFSET_MRCTRL0_SW_INIT_INT +: `UMCTL2_REG_SIZE_MRCTRL0_SW_INIT_INT];
         end
         if (rwselect[3] && write_en) begin
            ff_mr_rank[(`UMCTL2_REG_SIZE_MRCTRL0_MR_RANK) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_MR_RANK +: `UMCTL2_REG_SIZE_MRCTRL0_MR_RANK] & umctl2_regs_mrctrl0_mr_rank_mask[`UMCTL2_REG_OFFSET_MRCTRL0_MR_RANK +: `UMCTL2_REG_SIZE_MRCTRL0_MR_RANK];
         end
         if (rwselect[3] && write_en) begin
            ff_mr_addr[(`UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_MR_ADDR +: `UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR] & umctl2_regs_mrctrl0_mr_addr_mask[`UMCTL2_REG_OFFSET_MRCTRL0_MR_ADDR +: `UMCTL2_REG_SIZE_MRCTRL0_MR_ADDR];
         end
         if (rwselect[3] && write_en) begin
            ff_pba_mode <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_PBA_MODE +: `UMCTL2_REG_SIZE_MRCTRL0_PBA_MODE] & umctl2_regs_mrctrl0_pba_mode_mask[`UMCTL2_REG_OFFSET_MRCTRL0_PBA_MODE +: `UMCTL2_REG_SIZE_MRCTRL0_PBA_MODE];
         end
         if (reg_ddrc_mr_wr_ack_pclk) begin
            ff_mr_wr <= 1'b0;
            ff_mr_wr_saved <= 1'b0;
         end else begin
            if (ff_mr_wr_todo & (!ddrc_reg_mr_wr_busy_int)) begin
               ff_mr_wr_todo <= 1'b0;
               ff_mr_wr <= ff_mr_wr_saved;
            end else if (rwselect[3] & store_rqst & (apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_MR_WR] & umctl2_regs_mrctrl0_mr_wr_mask[`UMCTL2_REG_OFFSET_MRCTRL0_MR_WR]) ) begin
               if (ddrc_reg_mr_wr_busy_int) begin
                  ff_mr_wr_todo <= 1'b1;
                  ff_mr_wr_saved <= 1'b1;
               end else begin
                  ff_mr_wr <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL0_MR_WR] & umctl2_regs_mrctrl0_mr_wr_mask[`UMCTL2_REG_OFFSET_MRCTRL0_MR_WR];
               end
            end
         end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL1
   //------------------------
         if (rwselect[4] && write_en) begin
            ff_mr_data[(`UMCTL2_REG_SIZE_MRCTRL1_MR_DATA) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL1_MR_DATA +: `UMCTL2_REG_SIZE_MRCTRL1_MR_DATA] & umctl2_regs_mrctrl1_mr_data_mask[`UMCTL2_REG_OFFSET_MRCTRL1_MR_DATA +: `UMCTL2_REG_SIZE_MRCTRL1_MR_DATA];
         end
   //------------------------
   // Register UMCTL2_REGS.MRCTRL2
   //------------------------
         if (rwselect[5] && write_en) begin
            ff_mr_device_sel[(`UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_MRCTRL2_MR_DEVICE_SEL +: `UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL] & umctl2_regs_mrctrl2_mr_device_sel_mask[`UMCTL2_REG_OFFSET_MRCTRL2_MR_DEVICE_SEL +: `UMCTL2_REG_SIZE_MRCTRL2_MR_DEVICE_SEL];
         end
   //------------------------
   // Register UMCTL2_REGS.PWRCTL
   //------------------------
         if (rwselect[10] && write_en) begin
            ff_selfref_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_EN +: `UMCTL2_REG_SIZE_PWRCTL_SELFREF_EN] & umctl2_regs_pwrctl_selfref_en_mask[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_EN +: `UMCTL2_REG_SIZE_PWRCTL_SELFREF_EN];
         end
         if (rwselect[10] && write_en) begin
            ff_powerdown_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRCTL_POWERDOWN_EN +: `UMCTL2_REG_SIZE_PWRCTL_POWERDOWN_EN] & umctl2_regs_pwrctl_powerdown_en_mask[`UMCTL2_REG_OFFSET_PWRCTL_POWERDOWN_EN +: `UMCTL2_REG_SIZE_PWRCTL_POWERDOWN_EN];
         end
         if (rwselect[10] && write_en) begin
            ff_en_dfi_dram_clk_disable <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE +: `UMCTL2_REG_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE] & umctl2_regs_pwrctl_en_dfi_dram_clk_disable_mask[`UMCTL2_REG_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE +: `UMCTL2_REG_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE];
         end
         if (rwselect[10] && write_en) begin
            ff_mpsm_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRCTL_MPSM_EN +: `UMCTL2_REG_SIZE_PWRCTL_MPSM_EN] & umctl2_regs_pwrctl_mpsm_en_mask[`UMCTL2_REG_OFFSET_PWRCTL_MPSM_EN +: `UMCTL2_REG_SIZE_PWRCTL_MPSM_EN];
         end
         if (rwselect[10] && write_en) begin
            ff_selfref_sw <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_SW +: `UMCTL2_REG_SIZE_PWRCTL_SELFREF_SW] & umctl2_regs_pwrctl_selfref_sw_mask[`UMCTL2_REG_OFFSET_PWRCTL_SELFREF_SW +: `UMCTL2_REG_SIZE_PWRCTL_SELFREF_SW];
         end
         if (rwselect[10] && write_en) begin
            ff_dis_cam_drain_selfref <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF +: `UMCTL2_REG_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF] & umctl2_regs_pwrctl_dis_cam_drain_selfref_mask[`UMCTL2_REG_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF +: `UMCTL2_REG_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF];
         end
   //------------------------
   // Register UMCTL2_REGS.PWRTMG
   //------------------------
         if (rwselect[11] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_powerdown_to_x32[(`UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRTMG_POWERDOWN_TO_X32 +: `UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32] & umctl2_regs_pwrtmg_powerdown_to_x32_mask[`UMCTL2_REG_OFFSET_PWRTMG_POWERDOWN_TO_X32 +: `UMCTL2_REG_SIZE_PWRTMG_POWERDOWN_TO_X32];
            end
         end
         if (rwselect[11] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_selfref_to_x32[(`UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PWRTMG_SELFREF_TO_X32 +: `UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32] & umctl2_regs_pwrtmg_selfref_to_x32_mask[`UMCTL2_REG_OFFSET_PWRTMG_SELFREF_TO_X32 +: `UMCTL2_REG_SIZE_PWRTMG_SELFREF_TO_X32];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.HWLPCTL
   //------------------------
         if (rwselect[12] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_hw_lp_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EN +: `UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EN] & umctl2_regs_hwlpctl_hw_lp_en_mask[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EN +: `UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EN];
            end
         end
         if (rwselect[12] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_hw_lp_exit_idle_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN +: `UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN] & umctl2_regs_hwlpctl_hw_lp_exit_idle_en_mask[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN +: `UMCTL2_REG_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN];
            end
         end
         if (rwselect[12] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_hw_lp_idle_x32[(`UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_IDLE_X32 +: `UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32] & umctl2_regs_hwlpctl_hw_lp_idle_x32_mask[`UMCTL2_REG_OFFSET_HWLPCTL_HW_LP_IDLE_X32 +: `UMCTL2_REG_SIZE_HWLPCTL_HW_LP_IDLE_X32];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL0
   //------------------------
         if (rwselect[14] && write_en) begin
            ff_refresh_burst[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_BURST +: `UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST] & umctl2_regs_rfshctl0_refresh_burst_mask[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_BURST +: `UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_BURST];
         end
         if (rwselect[14] && write_en) begin
            ff_refresh_to_x1_x32[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_TO_X1_X32 +: `UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32] & umctl2_regs_rfshctl0_refresh_to_x1_x32_mask[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_TO_X1_X32 +: `UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_TO_X1_X32];
         end
         if (rwselect[14] && write_en) begin
            ff_refresh_margin[(`UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_MARGIN +: `UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN] & umctl2_regs_rfshctl0_refresh_margin_mask[`UMCTL2_REG_OFFSET_RFSHCTL0_REFRESH_MARGIN +: `UMCTL2_REG_SIZE_RFSHCTL0_REFRESH_MARGIN];
         end
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL1
   //------------------------
         if (rwselect[15] && write_en) begin
            ff_refresh_timer0_start_value_x32[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32 +: `UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32] & umctl2_regs_rfshctl1_refresh_timer0_start_value_x32_mask[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32 +: `UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER0_START_VALUE_X32];
         end
         if (rwselect[15] && write_en) begin
            ff_refresh_timer1_start_value_x32[(`UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32 +: `UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32] & umctl2_regs_rfshctl1_refresh_timer1_start_value_x32_mask[`UMCTL2_REG_OFFSET_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32 +: `UMCTL2_REG_SIZE_RFSHCTL1_REFRESH_TIMER1_START_VALUE_X32];
         end
   //------------------------
   // Register UMCTL2_REGS.RFSHCTL3
   //------------------------
         if (rwselect[18] && write_en) begin
            ff_dis_auto_refresh <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL3_DIS_AUTO_REFRESH +: `UMCTL2_REG_SIZE_RFSHCTL3_DIS_AUTO_REFRESH] & umctl2_regs_rfshctl3_dis_auto_refresh_mask[`UMCTL2_REG_OFFSET_RFSHCTL3_DIS_AUTO_REFRESH +: `UMCTL2_REG_SIZE_RFSHCTL3_DIS_AUTO_REFRESH];
         end
         if (rwselect[18] && write_en) begin
            ff_refresh_update_level <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_UPDATE_LEVEL +: `UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_UPDATE_LEVEL] & umctl2_regs_rfshctl3_refresh_update_level_mask[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_UPDATE_LEVEL +: `UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_UPDATE_LEVEL];
         end
         if (rwselect[18] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_refresh_mode[(`UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_MODE +: `UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE] & umctl2_regs_rfshctl3_refresh_mode_mask[`UMCTL2_REG_OFFSET_RFSHCTL3_REFRESH_MODE +: `UMCTL2_REG_SIZE_RFSHCTL3_REFRESH_MODE];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.RFSHTMG
   //------------------------
         if (rwselect[19] && write_en) begin
            ff_t_rfc_min[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_MIN +: `UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN] & umctl2_regs_rfshtmg_t_rfc_min_mask[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_MIN +: `UMCTL2_REG_SIZE_RFSHTMG_T_RFC_MIN];
         end
         if (rwselect[19] && write_en) begin
            ff_t_rfc_nom_x1_x32[(`UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_NOM_X1_X32 +: `UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32] & umctl2_regs_rfshtmg_t_rfc_nom_x1_x32_mask[`UMCTL2_REG_OFFSET_RFSHTMG_T_RFC_NOM_X1_X32 +: `UMCTL2_REG_SIZE_RFSHTMG_T_RFC_NOM_X1_X32];
         end
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL0
   //------------------------
         if (rwselect[26] && write_en) begin
            ff_dfi_alert_err_int_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_EN +: `UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_EN] & umctl2_regs_crcparctl0_dfi_alert_err_int_en_mask[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_EN +: `UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_EN];
         end
         if (reg_ddrc_dfi_alert_err_int_clr_ack_pclk) begin
            ff_dfi_alert_err_int_clr <= 1'b0;
         end else begin
            if (rwselect[26] && write_en) begin
               ff_dfi_alert_err_int_clr <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR +: `UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR] & umctl2_regs_crcparctl0_dfi_alert_err_int_clr_mask[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR +: `UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_INT_CLR];
            end
         end
         if (reg_ddrc_dfi_alert_err_cnt_clr_ack_pclk) begin
            ff_dfi_alert_err_cnt_clr <= 1'b0;
         end else begin
            if (rwselect[26] && write_en) begin
               ff_dfi_alert_err_cnt_clr <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR +: `UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR] & umctl2_regs_crcparctl0_dfi_alert_err_cnt_clr_mask[`UMCTL2_REG_OFFSET_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR +: `UMCTL2_REG_SIZE_CRCPARCTL0_DFI_ALERT_ERR_CNT_CLR];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.CRCPARCTL1
   //------------------------
         if (rwselect[27] && write_en) begin
            ff_parity_enable <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL1_PARITY_ENABLE +: `UMCTL2_REG_SIZE_CRCPARCTL1_PARITY_ENABLE] & umctl2_regs_crcparctl1_parity_enable_mask[`UMCTL2_REG_OFFSET_CRCPARCTL1_PARITY_ENABLE +: `UMCTL2_REG_SIZE_CRCPARCTL1_PARITY_ENABLE];
         end
         if (rwselect[27] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_crc_enable <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_ENABLE +: `UMCTL2_REG_SIZE_CRCPARCTL1_CRC_ENABLE] & umctl2_regs_crcparctl1_crc_enable_mask[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_ENABLE +: `UMCTL2_REG_SIZE_CRCPARCTL1_CRC_ENABLE];
            end
         end
         if (rwselect[27] && write_en) begin
            ff_crc_inc_dm <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_INC_DM +: `UMCTL2_REG_SIZE_CRCPARCTL1_CRC_INC_DM] & umctl2_regs_crcparctl1_crc_inc_dm_mask[`UMCTL2_REG_OFFSET_CRCPARCTL1_CRC_INC_DM +: `UMCTL2_REG_SIZE_CRCPARCTL1_CRC_INC_DM];
         end
         if (rwselect[27] && write_en) begin
            ff_caparity_disable_before_sr <= apb_data_expanded[`UMCTL2_REG_OFFSET_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR +: `UMCTL2_REG_SIZE_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR] & umctl2_regs_crcparctl1_caparity_disable_before_sr_mask[`UMCTL2_REG_OFFSET_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR +: `UMCTL2_REG_SIZE_CRCPARCTL1_CAPARITY_DISABLE_BEFORE_SR];
         end
   //------------------------
   // Register UMCTL2_REGS.INIT0
   //------------------------
         if (rwselect[29] && write_en) begin
            ff_pre_cke_x1024[(`UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT0_PRE_CKE_X1024 +: `UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024] & umctl2_regs_init0_pre_cke_x1024_mask[`UMCTL2_REG_OFFSET_INIT0_PRE_CKE_X1024 +: `UMCTL2_REG_SIZE_INIT0_PRE_CKE_X1024];
         end
         if (rwselect[29] && write_en) begin
            ff_post_cke_x1024[(`UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT0_POST_CKE_X1024 +: `UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024] & umctl2_regs_init0_post_cke_x1024_mask[`UMCTL2_REG_OFFSET_INIT0_POST_CKE_X1024 +: `UMCTL2_REG_SIZE_INIT0_POST_CKE_X1024];
         end
         if (rwselect[29] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_skip_dram_init[(`UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT0_SKIP_DRAM_INIT +: `UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT] & umctl2_regs_init0_skip_dram_init_mask[`UMCTL2_REG_OFFSET_INIT0_SKIP_DRAM_INIT +: `UMCTL2_REG_SIZE_INIT0_SKIP_DRAM_INIT];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.INIT1
   //------------------------
         if (rwselect[30] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_pre_ocd_x32[(`UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT1_PRE_OCD_X32 +: `UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32] & umctl2_regs_init1_pre_ocd_x32_mask[`UMCTL2_REG_OFFSET_INIT1_PRE_OCD_X32 +: `UMCTL2_REG_SIZE_INIT1_PRE_OCD_X32];
            end
         end
         if (rwselect[30] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dram_rstn_x1024[(`UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT1_DRAM_RSTN_X1024 +: `UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024] & umctl2_regs_init1_dram_rstn_x1024_mask[`UMCTL2_REG_OFFSET_INIT1_DRAM_RSTN_X1024 +: `UMCTL2_REG_SIZE_INIT1_DRAM_RSTN_X1024];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.INIT3
   //------------------------
         if (rwselect[32] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_emr[(`UMCTL2_REG_SIZE_INIT3_EMR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT3_EMR +: `UMCTL2_REG_SIZE_INIT3_EMR] & umctl2_regs_init3_emr_mask[`UMCTL2_REG_OFFSET_INIT3_EMR +: `UMCTL2_REG_SIZE_INIT3_EMR];
            end
         end
         if (rwselect[32] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_mr[(`UMCTL2_REG_SIZE_INIT3_MR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT3_MR +: `UMCTL2_REG_SIZE_INIT3_MR] & umctl2_regs_init3_mr_mask[`UMCTL2_REG_OFFSET_INIT3_MR +: `UMCTL2_REG_SIZE_INIT3_MR];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.INIT4
   //------------------------
         if (rwselect[33] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_emr3[(`UMCTL2_REG_SIZE_INIT4_EMR3) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT4_EMR3 +: `UMCTL2_REG_SIZE_INIT4_EMR3] & umctl2_regs_init4_emr3_mask[`UMCTL2_REG_OFFSET_INIT4_EMR3 +: `UMCTL2_REG_SIZE_INIT4_EMR3];
            end
         end
         if (rwselect[33] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_emr2[(`UMCTL2_REG_SIZE_INIT4_EMR2) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT4_EMR2 +: `UMCTL2_REG_SIZE_INIT4_EMR2] & umctl2_regs_init4_emr2_mask[`UMCTL2_REG_OFFSET_INIT4_EMR2 +: `UMCTL2_REG_SIZE_INIT4_EMR2];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.INIT5
   //------------------------
         if (rwselect[34] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dev_zqinit_x32[(`UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT5_DEV_ZQINIT_X32 +: `UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32] & umctl2_regs_init5_dev_zqinit_x32_mask[`UMCTL2_REG_OFFSET_INIT5_DEV_ZQINIT_X32 +: `UMCTL2_REG_SIZE_INIT5_DEV_ZQINIT_X32];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.INIT6
   //------------------------
         if (rwselect[35] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_mr5[(`UMCTL2_REG_SIZE_INIT6_MR5) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT6_MR5 +: `UMCTL2_REG_SIZE_INIT6_MR5] & umctl2_regs_init6_mr5_mask[`UMCTL2_REG_OFFSET_INIT6_MR5 +: `UMCTL2_REG_SIZE_INIT6_MR5];
            end
         end
         if (rwselect[35] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_mr4[(`UMCTL2_REG_SIZE_INIT6_MR4) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT6_MR4 +: `UMCTL2_REG_SIZE_INIT6_MR4] & umctl2_regs_init6_mr4_mask[`UMCTL2_REG_OFFSET_INIT6_MR4 +: `UMCTL2_REG_SIZE_INIT6_MR4];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.INIT7
   //------------------------
         if (rwselect[36] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_mr6[(`UMCTL2_REG_SIZE_INIT7_MR6) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_INIT7_MR6 +: `UMCTL2_REG_SIZE_INIT7_MR6] & umctl2_regs_init7_mr6_mask[`UMCTL2_REG_OFFSET_INIT7_MR6 +: `UMCTL2_REG_SIZE_INIT7_MR6];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DIMMCTL
   //------------------------
         if (rwselect[37] && write_en) begin
            ff_dimm_stagger_cs_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_STAGGER_CS_EN +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_STAGGER_CS_EN] & umctl2_regs_dimmctl_dimm_stagger_cs_en_mask[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_STAGGER_CS_EN +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_STAGGER_CS_EN];
         end
         if (rwselect[37] && write_en) begin
            ff_dimm_addr_mirr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_ADDR_MIRR_EN +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_ADDR_MIRR_EN] & umctl2_regs_dimmctl_dimm_addr_mirr_en_mask[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_ADDR_MIRR_EN +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_ADDR_MIRR_EN];
         end
         if (rwselect[37] && write_en) begin
            ff_dimm_output_inv_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_OUTPUT_INV_EN +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_OUTPUT_INV_EN] & umctl2_regs_dimmctl_dimm_output_inv_en_mask[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_OUTPUT_INV_EN +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_OUTPUT_INV_EN];
         end
         if (rwselect[37] && write_en) begin
            ff_mrs_a17_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_A17_EN +: `UMCTL2_REG_SIZE_DIMMCTL_MRS_A17_EN] & umctl2_regs_dimmctl_mrs_a17_en_mask[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_A17_EN +: `UMCTL2_REG_SIZE_DIMMCTL_MRS_A17_EN];
         end
         if (rwselect[37] && write_en) begin
            ff_mrs_bg1_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_BG1_EN +: `UMCTL2_REG_SIZE_DIMMCTL_MRS_BG1_EN] & umctl2_regs_dimmctl_mrs_bg1_en_mask[`UMCTL2_REG_OFFSET_DIMMCTL_MRS_BG1_EN +: `UMCTL2_REG_SIZE_DIMMCTL_MRS_BG1_EN];
         end
         if (rwselect[37] && write_en) begin
            ff_dimm_dis_bg_mirroring <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_DIS_BG_MIRRORING +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_DIS_BG_MIRRORING] & umctl2_regs_dimmctl_dimm_dis_bg_mirroring_mask[`UMCTL2_REG_OFFSET_DIMMCTL_DIMM_DIS_BG_MIRRORING +: `UMCTL2_REG_SIZE_DIMMCTL_DIMM_DIS_BG_MIRRORING];
         end
         if (rwselect[37] && write_en) begin
            ff_lrdimm_bcom_cmd_prot <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_LRDIMM_BCOM_CMD_PROT +: `UMCTL2_REG_SIZE_DIMMCTL_LRDIMM_BCOM_CMD_PROT] & umctl2_regs_dimmctl_lrdimm_bcom_cmd_prot_mask[`UMCTL2_REG_OFFSET_DIMMCTL_LRDIMM_BCOM_CMD_PROT +: `UMCTL2_REG_SIZE_DIMMCTL_LRDIMM_BCOM_CMD_PROT];
         end
         if (rwselect[37] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_rcd_weak_drive <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_WEAK_DRIVE +: `UMCTL2_REG_SIZE_DIMMCTL_RCD_WEAK_DRIVE] & umctl2_regs_dimmctl_rcd_weak_drive_mask[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_WEAK_DRIVE +: `UMCTL2_REG_SIZE_DIMMCTL_RCD_WEAK_DRIVE];
            end
         end
         if (rwselect[37] && write_en) begin
            ff_rcd_a_output_disabled <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_A_OUTPUT_DISABLED +: `UMCTL2_REG_SIZE_DIMMCTL_RCD_A_OUTPUT_DISABLED] & umctl2_regs_dimmctl_rcd_a_output_disabled_mask[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_A_OUTPUT_DISABLED +: `UMCTL2_REG_SIZE_DIMMCTL_RCD_A_OUTPUT_DISABLED];
         end
         if (rwselect[37] && write_en) begin
            ff_rcd_b_output_disabled <= apb_data_expanded[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_B_OUTPUT_DISABLED +: `UMCTL2_REG_SIZE_DIMMCTL_RCD_B_OUTPUT_DISABLED] & umctl2_regs_dimmctl_rcd_b_output_disabled_mask[`UMCTL2_REG_OFFSET_DIMMCTL_RCD_B_OUTPUT_DISABLED +: `UMCTL2_REG_SIZE_DIMMCTL_RCD_B_OUTPUT_DISABLED];
         end
   //------------------------
   // Register UMCTL2_REGS.RANKCTL
   //------------------------
         if (rwselect[38] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_max_rank_rd[(`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_RD +: `UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD] & umctl2_regs_rankctl_max_rank_rd_mask[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_RD +: `UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_RD];
            end
         end
         if (rwselect[38] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_diff_rank_rd_gap[(`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP] & umctl2_regs_rankctl_diff_rank_rd_gap_mask[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP];
            end
         end
         if (rwselect[38] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_diff_rank_wr_gap[(`UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP] & umctl2_regs_rankctl_diff_rank_wr_gap_mask[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP];
            end
         end
         if (rwselect[38] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_max_rank_wr[(`UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_WR +: `UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR] & umctl2_regs_rankctl_max_rank_wr_mask[`UMCTL2_REG_OFFSET_RANKCTL_MAX_RANK_WR +: `UMCTL2_REG_SIZE_RANKCTL_MAX_RANK_WR];
            end
         end
         if (rwselect[38] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_diff_rank_rd_gap_msb <= apb_data_expanded[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP_MSB +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP_MSB] & umctl2_regs_rankctl_diff_rank_rd_gap_msb_mask[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_RD_GAP_MSB +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_RD_GAP_MSB];
            end
         end
         if (rwselect[38] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_diff_rank_wr_gap_msb <= apb_data_expanded[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP_MSB +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP_MSB] & umctl2_regs_rankctl_diff_rank_wr_gap_msb_mask[`UMCTL2_REG_OFFSET_RANKCTL_DIFF_RANK_WR_GAP_MSB +: `UMCTL2_REG_SIZE_RANKCTL_DIFF_RANK_WR_GAP_MSB];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG0
   //------------------------
         if (rwselect[40] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_ras_min[(`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MIN +: `UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN] & umctl2_regs_dramtmg0_t_ras_min_mask[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MIN +: `UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MIN];
            end
         end
         if (rwselect[40] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_ras_max[(`UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MAX +: `UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX] & umctl2_regs_dramtmg0_t_ras_max_mask[`UMCTL2_REG_OFFSET_DRAMTMG0_T_RAS_MAX +: `UMCTL2_REG_SIZE_DRAMTMG0_T_RAS_MAX];
            end
         end
         if (rwselect[40] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_faw[(`UMCTL2_REG_SIZE_DRAMTMG0_T_FAW) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG0_T_FAW +: `UMCTL2_REG_SIZE_DRAMTMG0_T_FAW] & umctl2_regs_dramtmg0_t_faw_mask[`UMCTL2_REG_OFFSET_DRAMTMG0_T_FAW +: `UMCTL2_REG_SIZE_DRAMTMG0_T_FAW];
            end
         end
         if (rwselect[40] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wr2pre[(`UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG0_WR2PRE +: `UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE] & umctl2_regs_dramtmg0_wr2pre_mask[`UMCTL2_REG_OFFSET_DRAMTMG0_WR2PRE +: `UMCTL2_REG_SIZE_DRAMTMG0_WR2PRE];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG1
   //------------------------
         if (rwselect[41] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_rc[(`UMCTL2_REG_SIZE_DRAMTMG1_T_RC) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG1_T_RC +: `UMCTL2_REG_SIZE_DRAMTMG1_T_RC] & umctl2_regs_dramtmg1_t_rc_mask[`UMCTL2_REG_OFFSET_DRAMTMG1_T_RC +: `UMCTL2_REG_SIZE_DRAMTMG1_T_RC];
            end
         end
         if (rwselect[41] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_rd2pre[(`UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG1_RD2PRE +: `UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE] & umctl2_regs_dramtmg1_rd2pre_mask[`UMCTL2_REG_OFFSET_DRAMTMG1_RD2PRE +: `UMCTL2_REG_SIZE_DRAMTMG1_RD2PRE];
            end
         end
         if (rwselect[41] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_xp[(`UMCTL2_REG_SIZE_DRAMTMG1_T_XP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG1_T_XP +: `UMCTL2_REG_SIZE_DRAMTMG1_T_XP] & umctl2_regs_dramtmg1_t_xp_mask[`UMCTL2_REG_OFFSET_DRAMTMG1_T_XP +: `UMCTL2_REG_SIZE_DRAMTMG1_T_XP];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG2
   //------------------------
         if (rwselect[42] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wr2rd[(`UMCTL2_REG_SIZE_DRAMTMG2_WR2RD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG2_WR2RD +: `UMCTL2_REG_SIZE_DRAMTMG2_WR2RD] & umctl2_regs_dramtmg2_wr2rd_mask[`UMCTL2_REG_OFFSET_DRAMTMG2_WR2RD +: `UMCTL2_REG_SIZE_DRAMTMG2_WR2RD];
            end
         end
         if (rwselect[42] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_rd2wr[(`UMCTL2_REG_SIZE_DRAMTMG2_RD2WR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG2_RD2WR +: `UMCTL2_REG_SIZE_DRAMTMG2_RD2WR] & umctl2_regs_dramtmg2_rd2wr_mask[`UMCTL2_REG_OFFSET_DRAMTMG2_RD2WR +: `UMCTL2_REG_SIZE_DRAMTMG2_RD2WR];
            end
         end
         if (rwselect[42] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_read_latency[(`UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG2_READ_LATENCY +: `UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY] & umctl2_regs_dramtmg2_read_latency_mask[`UMCTL2_REG_OFFSET_DRAMTMG2_READ_LATENCY +: `UMCTL2_REG_SIZE_DRAMTMG2_READ_LATENCY];
            end
         end
         if (rwselect[42] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_write_latency[(`UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG2_WRITE_LATENCY +: `UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY] & umctl2_regs_dramtmg2_write_latency_mask[`UMCTL2_REG_OFFSET_DRAMTMG2_WRITE_LATENCY +: `UMCTL2_REG_SIZE_DRAMTMG2_WRITE_LATENCY];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG3
   //------------------------
         if (rwselect[43] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_mod[(`UMCTL2_REG_SIZE_DRAMTMG3_T_MOD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MOD +: `UMCTL2_REG_SIZE_DRAMTMG3_T_MOD] & umctl2_regs_dramtmg3_t_mod_mask[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MOD +: `UMCTL2_REG_SIZE_DRAMTMG3_T_MOD];
            end
         end
         if (rwselect[43] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_mrd[(`UMCTL2_REG_SIZE_DRAMTMG3_T_MRD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MRD +: `UMCTL2_REG_SIZE_DRAMTMG3_T_MRD] & umctl2_regs_dramtmg3_t_mrd_mask[`UMCTL2_REG_OFFSET_DRAMTMG3_T_MRD +: `UMCTL2_REG_SIZE_DRAMTMG3_T_MRD];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG4
   //------------------------
         if (rwselect[44] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_rp[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RP +: `UMCTL2_REG_SIZE_DRAMTMG4_T_RP] & umctl2_regs_dramtmg4_t_rp_mask[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RP +: `UMCTL2_REG_SIZE_DRAMTMG4_T_RP];
            end
         end
         if (rwselect[44] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_rrd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RRD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RRD +: `UMCTL2_REG_SIZE_DRAMTMG4_T_RRD] & umctl2_regs_dramtmg4_t_rrd_mask[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RRD +: `UMCTL2_REG_SIZE_DRAMTMG4_T_RRD];
            end
         end
         if (rwselect[44] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_ccd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_CCD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG4_T_CCD +: `UMCTL2_REG_SIZE_DRAMTMG4_T_CCD] & umctl2_regs_dramtmg4_t_ccd_mask[`UMCTL2_REG_OFFSET_DRAMTMG4_T_CCD +: `UMCTL2_REG_SIZE_DRAMTMG4_T_CCD];
            end
         end
         if (rwselect[44] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_rcd[(`UMCTL2_REG_SIZE_DRAMTMG4_T_RCD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RCD +: `UMCTL2_REG_SIZE_DRAMTMG4_T_RCD] & umctl2_regs_dramtmg4_t_rcd_mask[`UMCTL2_REG_OFFSET_DRAMTMG4_T_RCD +: `UMCTL2_REG_SIZE_DRAMTMG4_T_RCD];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG5
   //------------------------
         if (rwselect[45] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_cke[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKE +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKE] & umctl2_regs_dramtmg5_t_cke_mask[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKE +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKE];
            end
         end
         if (rwselect[45] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_ckesr[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKESR +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR] & umctl2_regs_dramtmg5_t_ckesr_mask[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKESR +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKESR];
            end
         end
         if (rwselect[45] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_cksre[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRE +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE] & umctl2_regs_dramtmg5_t_cksre_mask[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRE +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRE];
            end
         end
         if (rwselect[45] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_cksrx[(`UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRX +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX] & umctl2_regs_dramtmg5_t_cksrx_mask[`UMCTL2_REG_OFFSET_DRAMTMG5_T_CKSRX +: `UMCTL2_REG_SIZE_DRAMTMG5_T_CKSRX];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG8
   //------------------------
         if (rwselect[48] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_xs_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32] & umctl2_regs_dramtmg8_t_xs_x32_mask[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_X32];
            end
         end
         if (rwselect[48] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_xs_dll_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_DLL_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32] & umctl2_regs_dramtmg8_t_xs_dll_x32_mask[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_DLL_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_DLL_X32];
            end
         end
         if (rwselect[48] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_xs_abort_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_ABORT_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32] & umctl2_regs_dramtmg8_t_xs_abort_x32_mask[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_ABORT_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_ABORT_X32];
            end
         end
         if (rwselect[48] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_xs_fast_x32[(`UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_FAST_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32] & umctl2_regs_dramtmg8_t_xs_fast_x32_mask[`UMCTL2_REG_OFFSET_DRAMTMG8_T_XS_FAST_X32 +: `UMCTL2_REG_SIZE_DRAMTMG8_T_XS_FAST_X32];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG9
   //------------------------
         if (rwselect[49] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wr2rd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG9_WR2RD_S +: `UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S] & umctl2_regs_dramtmg9_wr2rd_s_mask[`UMCTL2_REG_OFFSET_DRAMTMG9_WR2RD_S +: `UMCTL2_REG_SIZE_DRAMTMG9_WR2RD_S];
            end
         end
         if (rwselect[49] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_rrd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG9_T_RRD_S +: `UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S] & umctl2_regs_dramtmg9_t_rrd_s_mask[`UMCTL2_REG_OFFSET_DRAMTMG9_T_RRD_S +: `UMCTL2_REG_SIZE_DRAMTMG9_T_RRD_S];
            end
         end
         if (rwselect[49] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_ccd_s[(`UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG9_T_CCD_S +: `UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S] & umctl2_regs_dramtmg9_t_ccd_s_mask[`UMCTL2_REG_OFFSET_DRAMTMG9_T_CCD_S +: `UMCTL2_REG_SIZE_DRAMTMG9_T_CCD_S];
            end
         end
         if (rwselect[49] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_ddr4_wr_preamble <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG9_DDR4_WR_PREAMBLE +: `UMCTL2_REG_SIZE_DRAMTMG9_DDR4_WR_PREAMBLE] & umctl2_regs_dramtmg9_ddr4_wr_preamble_mask[`UMCTL2_REG_OFFSET_DRAMTMG9_DDR4_WR_PREAMBLE +: `UMCTL2_REG_SIZE_DRAMTMG9_DDR4_WR_PREAMBLE];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG10
   //------------------------
         if (rwselect[50] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_t_gear_hold[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_HOLD +: `UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD] & umctl2_regs_dramtmg10_t_gear_hold_mask[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_HOLD +: `UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_HOLD];
            end
         end
         if (rwselect[50] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_t_gear_setup[(`UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_SETUP +: `UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP] & umctl2_regs_dramtmg10_t_gear_setup_mask[`UMCTL2_REG_OFFSET_DRAMTMG10_T_GEAR_SETUP +: `UMCTL2_REG_SIZE_DRAMTMG10_T_GEAR_SETUP];
            end
         end
         if (rwselect[50] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_t_cmd_gear[(`UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG10_T_CMD_GEAR +: `UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR] & umctl2_regs_dramtmg10_t_cmd_gear_mask[`UMCTL2_REG_OFFSET_DRAMTMG10_T_CMD_GEAR +: `UMCTL2_REG_SIZE_DRAMTMG10_T_CMD_GEAR];
            end
         end
         if (rwselect[50] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_t_sync_gear[(`UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG10_T_SYNC_GEAR +: `UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR] & umctl2_regs_dramtmg10_t_sync_gear_mask[`UMCTL2_REG_OFFSET_DRAMTMG10_T_SYNC_GEAR +: `UMCTL2_REG_SIZE_DRAMTMG10_T_SYNC_GEAR];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG11
   //------------------------
         if (rwselect[51] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_ckmpe[(`UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG11_T_CKMPE +: `UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE] & umctl2_regs_dramtmg11_t_ckmpe_mask[`UMCTL2_REG_OFFSET_DRAMTMG11_T_CKMPE +: `UMCTL2_REG_SIZE_DRAMTMG11_T_CKMPE];
            end
         end
         if (rwselect[51] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_mpx_s[(`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_S +: `UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S] & umctl2_regs_dramtmg11_t_mpx_s_mask[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_S +: `UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_S];
            end
         end
         if (rwselect[51] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_mpx_lh[(`UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_LH +: `UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH] & umctl2_regs_dramtmg11_t_mpx_lh_mask[`UMCTL2_REG_OFFSET_DRAMTMG11_T_MPX_LH +: `UMCTL2_REG_SIZE_DRAMTMG11_T_MPX_LH];
            end
         end
         if (rwselect[51] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_post_mpsm_gap_x32[(`UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG11_POST_MPSM_GAP_X32 +: `UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32] & umctl2_regs_dramtmg11_post_mpsm_gap_x32_mask[`UMCTL2_REG_OFFSET_DRAMTMG11_POST_MPSM_GAP_X32 +: `UMCTL2_REG_SIZE_DRAMTMG11_POST_MPSM_GAP_X32];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG12
   //------------------------
         if (rwselect[52] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_mrd_pda[(`UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG12_T_MRD_PDA +: `UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA] & umctl2_regs_dramtmg12_t_mrd_pda_mask[`UMCTL2_REG_OFFSET_DRAMTMG12_T_MRD_PDA +: `UMCTL2_REG_SIZE_DRAMTMG12_T_MRD_PDA];
            end
         end
         if (rwselect[52] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_wr_mpr[(`UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG12_T_WR_MPR +: `UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR] & umctl2_regs_dramtmg12_t_wr_mpr_mask[`UMCTL2_REG_OFFSET_DRAMTMG12_T_WR_MPR +: `UMCTL2_REG_SIZE_DRAMTMG12_T_WR_MPR];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DRAMTMG15
   //------------------------
         if (rwselect[55] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_t_stab_x32[(`UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG15_T_STAB_X32 +: `UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32] & umctl2_regs_dramtmg15_t_stab_x32_mask[`UMCTL2_REG_OFFSET_DRAMTMG15_T_STAB_X32 +: `UMCTL2_REG_SIZE_DRAMTMG15_T_STAB_X32];
            end
         end
         if (rwselect[55] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_en_dfi_lp_t_stab <= apb_data_expanded[`UMCTL2_REG_OFFSET_DRAMTMG15_EN_DFI_LP_T_STAB +: `UMCTL2_REG_SIZE_DRAMTMG15_EN_DFI_LP_T_STAB] & umctl2_regs_dramtmg15_en_dfi_lp_t_stab_mask[`UMCTL2_REG_OFFSET_DRAMTMG15_EN_DFI_LP_T_STAB +: `UMCTL2_REG_SIZE_DRAMTMG15_EN_DFI_LP_T_STAB];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ZQCTL0
   //------------------------
         if (rwselect[63] && write_en) begin
            ff_t_zq_short_nop[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_SHORT_NOP +: `UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP] & umctl2_regs_zqctl0_t_zq_short_nop_mask[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_SHORT_NOP +: `UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_SHORT_NOP];
         end
         if (rwselect[63] && write_en) begin
            ff_t_zq_long_nop[(`UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_LONG_NOP +: `UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP] & umctl2_regs_zqctl0_t_zq_long_nop_mask[`UMCTL2_REG_OFFSET_ZQCTL0_T_ZQ_LONG_NOP +: `UMCTL2_REG_SIZE_ZQCTL0_T_ZQ_LONG_NOP];
         end
         if (rwselect[63] && write_en) begin
            ff_dis_mpsmx_zqcl <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_MPSMX_ZQCL +: `UMCTL2_REG_SIZE_ZQCTL0_DIS_MPSMX_ZQCL] & umctl2_regs_zqctl0_dis_mpsmx_zqcl_mask[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_MPSMX_ZQCL +: `UMCTL2_REG_SIZE_ZQCTL0_DIS_MPSMX_ZQCL];
         end
         if (rwselect[63] && write_en) begin
            ff_zq_resistor_shared <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED +: `UMCTL2_REG_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED] & umctl2_regs_zqctl0_zq_resistor_shared_mask[`UMCTL2_REG_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED +: `UMCTL2_REG_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED];
         end
         if (rwselect[63] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dis_srx_zqcl <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_SRX_ZQCL +: `UMCTL2_REG_SIZE_ZQCTL0_DIS_SRX_ZQCL] & umctl2_regs_zqctl0_dis_srx_zqcl_mask[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_SRX_ZQCL +: `UMCTL2_REG_SIZE_ZQCTL0_DIS_SRX_ZQCL];
            end
         end
         if (rwselect[63] && write_en) begin
            ff_dis_auto_zq <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_AUTO_ZQ +: `UMCTL2_REG_SIZE_ZQCTL0_DIS_AUTO_ZQ] & umctl2_regs_zqctl0_dis_auto_zq_mask[`UMCTL2_REG_OFFSET_ZQCTL0_DIS_AUTO_ZQ +: `UMCTL2_REG_SIZE_ZQCTL0_DIS_AUTO_ZQ];
         end
   //------------------------
   // Register UMCTL2_REGS.ZQCTL1
   //------------------------
         if (rwselect[64] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_t_zq_short_interval_x1024[(`UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024 +: `UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024] & umctl2_regs_zqctl1_t_zq_short_interval_x1024_mask[`UMCTL2_REG_OFFSET_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024 +: `UMCTL2_REG_SIZE_ZQCTL1_T_ZQ_SHORT_INTERVAL_X1024];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFITMG0
   //------------------------
         if (rwselect[66] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dfi_tphy_wrlat[(`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRLAT +: `UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT] & umctl2_regs_dfitmg0_dfi_tphy_wrlat_mask[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRLAT +: `UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRLAT];
            end
         end
         if (rwselect[66] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dfi_tphy_wrdata[(`UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRDATA +: `UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA] & umctl2_regs_dfitmg0_dfi_tphy_wrdata_mask[`UMCTL2_REG_OFFSET_DFITMG0_DFI_TPHY_WRDATA +: `UMCTL2_REG_SIZE_DFITMG0_DFI_TPHY_WRDATA];
            end
         end
         if (rwselect[66] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_wrdata_use_dfi_phy_clk <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK +: `UMCTL2_REG_SIZE_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK] & umctl2_regs_dfitmg0_dfi_wrdata_use_dfi_phy_clk_mask[`UMCTL2_REG_OFFSET_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK +: `UMCTL2_REG_SIZE_DFITMG0_DFI_WRDATA_USE_DFI_PHY_CLK];
            end
         end
         if (rwselect[66] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_rddata_en[(`UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_RDDATA_EN +: `UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN] & umctl2_regs_dfitmg0_dfi_t_rddata_en_mask[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_RDDATA_EN +: `UMCTL2_REG_SIZE_DFITMG0_DFI_T_RDDATA_EN];
            end
         end
         if (rwselect[66] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_rddata_use_dfi_phy_clk <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK +: `UMCTL2_REG_SIZE_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK] & umctl2_regs_dfitmg0_dfi_rddata_use_dfi_phy_clk_mask[`UMCTL2_REG_OFFSET_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK +: `UMCTL2_REG_SIZE_DFITMG0_DFI_RDDATA_USE_DFI_PHY_CLK];
            end
         end
         if (rwselect[66] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_ctrl_delay[(`UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_CTRL_DELAY +: `UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY] & umctl2_regs_dfitmg0_dfi_t_ctrl_delay_mask[`UMCTL2_REG_OFFSET_DFITMG0_DFI_T_CTRL_DELAY +: `UMCTL2_REG_SIZE_DFITMG0_DFI_T_CTRL_DELAY];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFITMG1
   //------------------------
         if (rwselect[67] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_t_dram_clk_enable[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE] & umctl2_regs_dfitmg1_dfi_t_dram_clk_enable_mask[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE];
            end
         end
         if (rwselect[67] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_t_dram_clk_disable[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE] & umctl2_regs_dfitmg1_dfi_t_dram_clk_disable_mask[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE];
            end
         end
         if (rwselect[67] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_t_wrdata_delay[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY] & umctl2_regs_dfitmg1_dfi_t_wrdata_delay_mask[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_WRDATA_DELAY];
            end
         end
         if (rwselect[67] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_t_parin_lat[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_PARIN_LAT +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT] & umctl2_regs_dfitmg1_dfi_t_parin_lat_mask[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_PARIN_LAT +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_PARIN_LAT];
            end
         end
         if (rwselect[67] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_t_cmd_lat[(`UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_CMD_LAT +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT] & umctl2_regs_dfitmg1_dfi_t_cmd_lat_mask[`UMCTL2_REG_OFFSET_DFITMG1_DFI_T_CMD_LAT +: `UMCTL2_REG_SIZE_DFITMG1_DFI_T_CMD_LAT];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG0
   //------------------------
         if (rwselect[68] && write_en) begin
            ff_dfi_lp_en_pd <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_PD +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_PD] & umctl2_regs_dfilpcfg0_dfi_lp_en_pd_mask[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_PD +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_PD];
         end
         if (rwselect[68] && write_en) begin
            ff_dfi_lp_wakeup_pd[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_PD +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD] & umctl2_regs_dfilpcfg0_dfi_lp_wakeup_pd_mask[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_PD +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_PD];
         end
         if (rwselect[68] && write_en) begin
            ff_dfi_lp_en_sr <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_SR +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_SR] & umctl2_regs_dfilpcfg0_dfi_lp_en_sr_mask[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_EN_SR +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_EN_SR];
         end
         if (rwselect[68] && write_en) begin
            ff_dfi_lp_wakeup_sr[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_SR +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR] & umctl2_regs_dfilpcfg0_dfi_lp_wakeup_sr_mask[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_LP_WAKEUP_SR +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_LP_WAKEUP_SR];
         end
         if (rwselect[68] && write_en) begin
            ff_dfi_tlp_resp[(`UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_TLP_RESP +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP] & umctl2_regs_dfilpcfg0_dfi_tlp_resp_mask[`UMCTL2_REG_OFFSET_DFILPCFG0_DFI_TLP_RESP +: `UMCTL2_REG_SIZE_DFILPCFG0_DFI_TLP_RESP];
         end
   //------------------------
   // Register UMCTL2_REGS.DFILPCFG1
   //------------------------
         if (rwselect[69] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_lp_en_mpsm <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_EN_MPSM +: `UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_EN_MPSM] & umctl2_regs_dfilpcfg1_dfi_lp_en_mpsm_mask[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_EN_MPSM +: `UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_EN_MPSM];
            end
         end
         if (rwselect[69] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_lp_wakeup_mpsm[(`UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_WAKEUP_MPSM +: `UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM] & umctl2_regs_dfilpcfg1_dfi_lp_wakeup_mpsm_mask[`UMCTL2_REG_OFFSET_DFILPCFG1_DFI_LP_WAKEUP_MPSM +: `UMCTL2_REG_SIZE_DFILPCFG1_DFI_LP_WAKEUP_MPSM];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFIUPD0
   //------------------------
         if (rwselect[70] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_ctrlup_min[(`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MIN +: `UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN] & umctl2_regs_dfiupd0_dfi_t_ctrlup_min_mask[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MIN +: `UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MIN];
            end
         end
         if (rwselect[70] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_ctrlup_max[(`UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MAX +: `UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX] & umctl2_regs_dfiupd0_dfi_t_ctrlup_max_mask[`UMCTL2_REG_OFFSET_DFIUPD0_DFI_T_CTRLUP_MAX +: `UMCTL2_REG_SIZE_DFIUPD0_DFI_T_CTRLUP_MAX];
            end
         end
         if (rwselect[70] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_ctrlupd_pre_srx <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX +: `UMCTL2_REG_SIZE_DFIUPD0_CTRLUPD_PRE_SRX] & umctl2_regs_dfiupd0_ctrlupd_pre_srx_mask[`UMCTL2_REG_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX +: `UMCTL2_REG_SIZE_DFIUPD0_CTRLUPD_PRE_SRX];
            end
         end
         if (rwselect[70] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dis_auto_ctrlupd_srx <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX +: `UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX] & umctl2_regs_dfiupd0_dis_auto_ctrlupd_srx_mask[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX +: `UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX];
            end
         end
         if (rwselect[70] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dis_auto_ctrlupd <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD +: `UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD] & umctl2_regs_dfiupd0_dis_auto_ctrlupd_mask[`UMCTL2_REG_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD +: `UMCTL2_REG_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFIUPD1
   //------------------------
         if (rwselect[71] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_ctrlupd_interval_max_x1024[(`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024 +: `UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024] & umctl2_regs_dfiupd1_dfi_t_ctrlupd_interval_max_x1024_mask[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024 +: `UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024];
            end
         end
         if (rwselect[71] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_ctrlupd_interval_min_x1024[(`UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024 +: `UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024] & umctl2_regs_dfiupd1_dfi_t_ctrlupd_interval_min_x1024_mask[`UMCTL2_REG_OFFSET_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024 +: `UMCTL2_REG_SIZE_DFIUPD1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFIUPD2
   //------------------------
         if (rwselect[72] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dfi_phyupd_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIUPD2_DFI_PHYUPD_EN +: `UMCTL2_REG_SIZE_DFIUPD2_DFI_PHYUPD_EN] & umctl2_regs_dfiupd2_dfi_phyupd_en_mask[`UMCTL2_REG_OFFSET_DFIUPD2_DFI_PHYUPD_EN +: `UMCTL2_REG_SIZE_DFIUPD2_DFI_PHYUPD_EN];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFIMISC
   //------------------------
         if (rwselect[74] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_init_complete_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN +: `UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN] & umctl2_regs_dfimisc_dfi_init_complete_en_mask[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN +: `UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN];
            end
         end
         if (rwselect[74] && write_en) begin
            ff_phy_dbi_mode <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIMISC_PHY_DBI_MODE +: `UMCTL2_REG_SIZE_DFIMISC_PHY_DBI_MODE] & umctl2_regs_dfimisc_phy_dbi_mode_mask[`UMCTL2_REG_OFFSET_DFIMISC_PHY_DBI_MODE +: `UMCTL2_REG_SIZE_DFIMISC_PHY_DBI_MODE];
         end
         if (rwselect[74] && write_en) begin
            ff_ctl_idle_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIMISC_CTL_IDLE_EN +: `UMCTL2_REG_SIZE_DFIMISC_CTL_IDLE_EN] & umctl2_regs_dfimisc_ctl_idle_en_mask[`UMCTL2_REG_OFFSET_DFIMISC_CTL_IDLE_EN +: `UMCTL2_REG_SIZE_DFIMISC_CTL_IDLE_EN];
         end
         if (rwselect[74] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_init_start <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_START +: `UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_START] & umctl2_regs_dfimisc_dfi_init_start_mask[`UMCTL2_REG_OFFSET_DFIMISC_DFI_INIT_START +: `UMCTL2_REG_SIZE_DFIMISC_DFI_INIT_START];
            end
         end
         if (rwselect[74] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dis_dyn_adr_tri <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIMISC_DIS_DYN_ADR_TRI +: `UMCTL2_REG_SIZE_DFIMISC_DIS_DYN_ADR_TRI] & umctl2_regs_dfimisc_dis_dyn_adr_tri_mask[`UMCTL2_REG_OFFSET_DFIMISC_DIS_DYN_ADR_TRI +: `UMCTL2_REG_SIZE_DFIMISC_DIS_DYN_ADR_TRI];
            end
         end
         if (rwselect[74] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dfi_frequency[(`UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIMISC_DFI_FREQUENCY +: `UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY] & umctl2_regs_dfimisc_dfi_frequency_mask[`UMCTL2_REG_OFFSET_DFIMISC_DFI_FREQUENCY +: `UMCTL2_REG_SIZE_DFIMISC_DFI_FREQUENCY];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFITMG3
   //------------------------
         if (rwselect[76] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dfi_t_geardown_delay[(`UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFITMG3_DFI_T_GEARDOWN_DELAY +: `UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY] & umctl2_regs_dfitmg3_dfi_t_geardown_delay_mask[`UMCTL2_REG_OFFSET_DFITMG3_DFI_T_GEARDOWN_DELAY +: `UMCTL2_REG_SIZE_DFITMG3_DFI_T_GEARDOWN_DELAY];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DBICTL
   //------------------------
         if (rwselect[77] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_dm_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBICTL_DM_EN +: `UMCTL2_REG_SIZE_DBICTL_DM_EN] & umctl2_regs_dbictl_dm_en_mask[`UMCTL2_REG_OFFSET_DBICTL_DM_EN +: `UMCTL2_REG_SIZE_DBICTL_DM_EN];
            end
         end
         if (rwselect[77] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_wr_dbi_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBICTL_WR_DBI_EN +: `UMCTL2_REG_SIZE_DBICTL_WR_DBI_EN] & umctl2_regs_dbictl_wr_dbi_en_mask[`UMCTL2_REG_OFFSET_DBICTL_WR_DBI_EN +: `UMCTL2_REG_SIZE_DBICTL_WR_DBI_EN];
            end
         end
         if (rwselect[77] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_rd_dbi_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBICTL_RD_DBI_EN +: `UMCTL2_REG_SIZE_DBICTL_RD_DBI_EN] & umctl2_regs_dbictl_rd_dbi_en_mask[`UMCTL2_REG_OFFSET_DBICTL_RD_DBI_EN +: `UMCTL2_REG_SIZE_DBICTL_RD_DBI_EN];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DFIPHYMSTR
   //------------------------
         if (rwselect[78] && write_en) begin
            ff_dfi_phymstr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN +: `UMCTL2_REG_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN] & umctl2_regs_dfiphymstr_dfi_phymstr_en_mask[`UMCTL2_REG_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN +: `UMCTL2_REG_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN];
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP0
   //------------------------
         if (rwselect[79] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_cs_bit0[(`UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP0_ADDRMAP_CS_BIT0 +: `UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0] & umctl2_regs_addrmap0_addrmap_cs_bit0_mask[`UMCTL2_REG_OFFSET_ADDRMAP0_ADDRMAP_CS_BIT0 +: `UMCTL2_REG_SIZE_ADDRMAP0_ADDRMAP_CS_BIT0];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP1
   //------------------------
         if (rwselect[80] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_bank_b0[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B0 +: `UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0] & umctl2_regs_addrmap1_addrmap_bank_b0_mask[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B0 +: `UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B0];
            end
         end
         if (rwselect[80] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_bank_b1[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B1 +: `UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1] & umctl2_regs_addrmap1_addrmap_bank_b1_mask[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B1 +: `UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B1];
            end
         end
         if (rwselect[80] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_bank_b2[(`UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B2 +: `UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2] & umctl2_regs_addrmap1_addrmap_bank_b2_mask[`UMCTL2_REG_OFFSET_ADDRMAP1_ADDRMAP_BANK_B2 +: `UMCTL2_REG_SIZE_ADDRMAP1_ADDRMAP_BANK_B2];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP2
   //------------------------
         if (rwselect[81] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b2[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B2 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2] & umctl2_regs_addrmap2_addrmap_col_b2_mask[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B2 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B2];
            end
         end
         if (rwselect[81] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b3[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B3 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3] & umctl2_regs_addrmap2_addrmap_col_b3_mask[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B3 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B3];
            end
         end
         if (rwselect[81] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b4[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B4 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4] & umctl2_regs_addrmap2_addrmap_col_b4_mask[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B4 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B4];
            end
         end
         if (rwselect[81] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b5[(`UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B5 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5] & umctl2_regs_addrmap2_addrmap_col_b5_mask[`UMCTL2_REG_OFFSET_ADDRMAP2_ADDRMAP_COL_B5 +: `UMCTL2_REG_SIZE_ADDRMAP2_ADDRMAP_COL_B5];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP3
   //------------------------
         if (rwselect[82] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b6[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B6 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6] & umctl2_regs_addrmap3_addrmap_col_b6_mask[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B6 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B6];
            end
         end
         if (rwselect[82] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b7[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B7 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7] & umctl2_regs_addrmap3_addrmap_col_b7_mask[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B7 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B7];
            end
         end
         if (rwselect[82] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b8[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B8 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8] & umctl2_regs_addrmap3_addrmap_col_b8_mask[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B8 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B8];
            end
         end
         if (rwselect[82] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b9[(`UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B9 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9] & umctl2_regs_addrmap3_addrmap_col_b9_mask[`UMCTL2_REG_OFFSET_ADDRMAP3_ADDRMAP_COL_B9 +: `UMCTL2_REG_SIZE_ADDRMAP3_ADDRMAP_COL_B9];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP4
   //------------------------
         if (rwselect[83] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b10[(`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B10 +: `UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10] & umctl2_regs_addrmap4_addrmap_col_b10_mask[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B10 +: `UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B10];
            end
         end
         if (rwselect[83] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_col_b11[(`UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B11 +: `UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11] & umctl2_regs_addrmap4_addrmap_col_b11_mask[`UMCTL2_REG_OFFSET_ADDRMAP4_ADDRMAP_COL_B11 +: `UMCTL2_REG_SIZE_ADDRMAP4_ADDRMAP_COL_B11];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP5
   //------------------------
         if (rwselect[84] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b0[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B0 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0] & umctl2_regs_addrmap5_addrmap_row_b0_mask[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B0 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B0];
            end
         end
         if (rwselect[84] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b1[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B1 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1] & umctl2_regs_addrmap5_addrmap_row_b1_mask[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B1 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B1];
            end
         end
         if (rwselect[84] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b2_10[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B2_10 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10] & umctl2_regs_addrmap5_addrmap_row_b2_10_mask[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B2_10 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B2_10];
            end
         end
         if (rwselect[84] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b11[(`UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B11 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11] & umctl2_regs_addrmap5_addrmap_row_b11_mask[`UMCTL2_REG_OFFSET_ADDRMAP5_ADDRMAP_ROW_B11 +: `UMCTL2_REG_SIZE_ADDRMAP5_ADDRMAP_ROW_B11];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP6
   //------------------------
         if (rwselect[85] && write_en) begin
            ff_addrmap_row_b12[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B12 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12] & umctl2_regs_addrmap6_addrmap_row_b12_mask[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B12 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B12];
         end
         if (rwselect[85] && write_en) begin
            ff_addrmap_row_b13[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B13 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13] & umctl2_regs_addrmap6_addrmap_row_b13_mask[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B13 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B13];
         end
         if (rwselect[85] && write_en) begin
            ff_addrmap_row_b14[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B14 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14] & umctl2_regs_addrmap6_addrmap_row_b14_mask[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B14 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B14];
         end
         if (rwselect[85] && write_en) begin
            ff_addrmap_row_b15[(`UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B15 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15] & umctl2_regs_addrmap6_addrmap_row_b15_mask[`UMCTL2_REG_OFFSET_ADDRMAP6_ADDRMAP_ROW_B15 +: `UMCTL2_REG_SIZE_ADDRMAP6_ADDRMAP_ROW_B15];
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP7
   //------------------------
         if (rwselect[86] && write_en) begin
            ff_addrmap_row_b16[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16 +: `UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16] & umctl2_regs_addrmap7_addrmap_row_b16_mask[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16 +: `UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B16];
         end
         if (rwselect[86] && write_en) begin
            ff_addrmap_row_b17[(`UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17 +: `UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17] & umctl2_regs_addrmap7_addrmap_row_b17_mask[`UMCTL2_REG_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17 +: `UMCTL2_REG_SIZE_ADDRMAP7_ADDRMAP_ROW_B17];
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP8
   //------------------------
         if (rwselect[87] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_bg_b0[(`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B0 +: `UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0] & umctl2_regs_addrmap8_addrmap_bg_b0_mask[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B0 +: `UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B0];
            end
         end
         if (rwselect[87] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_bg_b1[(`UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B1 +: `UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1] & umctl2_regs_addrmap8_addrmap_bg_b1_mask[`UMCTL2_REG_OFFSET_ADDRMAP8_ADDRMAP_BG_B1 +: `UMCTL2_REG_SIZE_ADDRMAP8_ADDRMAP_BG_B1];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP9
   //------------------------
         if (rwselect[88] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b2[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B2 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2] & umctl2_regs_addrmap9_addrmap_row_b2_mask[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B2 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B2];
            end
         end
         if (rwselect[88] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b3[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B3 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3] & umctl2_regs_addrmap9_addrmap_row_b3_mask[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B3 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B3];
            end
         end
         if (rwselect[88] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b4[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B4 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4] & umctl2_regs_addrmap9_addrmap_row_b4_mask[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B4 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B4];
            end
         end
         if (rwselect[88] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b5[(`UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B5 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5] & umctl2_regs_addrmap9_addrmap_row_b5_mask[`UMCTL2_REG_OFFSET_ADDRMAP9_ADDRMAP_ROW_B5 +: `UMCTL2_REG_SIZE_ADDRMAP9_ADDRMAP_ROW_B5];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP10
   //------------------------
         if (rwselect[89] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b6[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B6 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6] & umctl2_regs_addrmap10_addrmap_row_b6_mask[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B6 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B6];
            end
         end
         if (rwselect[89] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b7[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B7 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7] & umctl2_regs_addrmap10_addrmap_row_b7_mask[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B7 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B7];
            end
         end
         if (rwselect[89] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b8[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B8 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8] & umctl2_regs_addrmap10_addrmap_row_b8_mask[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B8 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B8];
            end
         end
         if (rwselect[89] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b9[(`UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B9 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9] & umctl2_regs_addrmap10_addrmap_row_b9_mask[`UMCTL2_REG_OFFSET_ADDRMAP10_ADDRMAP_ROW_B9 +: `UMCTL2_REG_SIZE_ADDRMAP10_ADDRMAP_ROW_B9];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ADDRMAP11
   //------------------------
         if (rwselect[90] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_addrmap_row_b10[(`UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ADDRMAP11_ADDRMAP_ROW_B10 +: `UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10] & umctl2_regs_addrmap11_addrmap_row_b10_mask[`UMCTL2_REG_OFFSET_ADDRMAP11_ADDRMAP_ROW_B10 +: `UMCTL2_REG_SIZE_ADDRMAP11_ADDRMAP_ROW_B10];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ODTCFG
   //------------------------
         if (rwselect[92] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_rd_odt_delay[(`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_DELAY +: `UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY] & umctl2_regs_odtcfg_rd_odt_delay_mask[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_DELAY +: `UMCTL2_REG_SIZE_ODTCFG_RD_ODT_DELAY];
            end
         end
         if (rwselect[92] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_rd_odt_hold[(`UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_HOLD +: `UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD] & umctl2_regs_odtcfg_rd_odt_hold_mask[`UMCTL2_REG_OFFSET_ODTCFG_RD_ODT_HOLD +: `UMCTL2_REG_SIZE_ODTCFG_RD_ODT_HOLD];
            end
         end
         if (rwselect[92] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wr_odt_delay[(`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_DELAY +: `UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY] & umctl2_regs_odtcfg_wr_odt_delay_mask[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_DELAY +: `UMCTL2_REG_SIZE_ODTCFG_WR_ODT_DELAY];
            end
         end
         if (rwselect[92] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wr_odt_hold[(`UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_HOLD +: `UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD] & umctl2_regs_odtcfg_wr_odt_hold_mask[`UMCTL2_REG_OFFSET_ODTCFG_WR_ODT_HOLD +: `UMCTL2_REG_SIZE_ODTCFG_WR_ODT_HOLD];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.ODTMAP
   //------------------------
         if (rwselect[93] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rank0_wr_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_WR_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT] & umctl2_regs_odtmap_rank0_wr_odt_mask[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_WR_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK0_WR_ODT];
            end
         end
         if (rwselect[93] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rank0_rd_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_RD_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT] & umctl2_regs_odtmap_rank0_rd_odt_mask[`UMCTL2_REG_OFFSET_ODTMAP_RANK0_RD_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK0_RD_ODT];
            end
         end
         if (rwselect[93] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rank1_wr_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_WR_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT] & umctl2_regs_odtmap_rank1_wr_odt_mask[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_WR_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK1_WR_ODT];
            end
         end
         if (rwselect[93] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rank1_rd_odt[(`UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_RD_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT] & umctl2_regs_odtmap_rank1_rd_odt_mask[`UMCTL2_REG_OFFSET_ODTMAP_RANK1_RD_ODT +: `UMCTL2_REG_SIZE_ODTMAP_RANK1_RD_ODT];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.SCHED
   //------------------------
         if (rwselect[94] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_prefer_write <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED_PREFER_WRITE +: `UMCTL2_REG_SIZE_SCHED_PREFER_WRITE] & umctl2_regs_sched_prefer_write_mask[`UMCTL2_REG_OFFSET_SCHED_PREFER_WRITE +: `UMCTL2_REG_SIZE_SCHED_PREFER_WRITE];
            end
         end
         if (rwselect[94] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_pageclose <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED_PAGECLOSE +: `UMCTL2_REG_SIZE_SCHED_PAGECLOSE] & umctl2_regs_sched_pageclose_mask[`UMCTL2_REG_OFFSET_SCHED_PAGECLOSE +: `UMCTL2_REG_SIZE_SCHED_PAGECLOSE];
            end
         end
         if (rwselect[94] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_autopre_rmw <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED_AUTOPRE_RMW +: `UMCTL2_REG_SIZE_SCHED_AUTOPRE_RMW] & umctl2_regs_sched_autopre_rmw_mask[`UMCTL2_REG_OFFSET_SCHED_AUTOPRE_RMW +: `UMCTL2_REG_SIZE_SCHED_AUTOPRE_RMW];
            end
         end
         if (rwselect[94] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_lpr_num_entries[(`UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED_LPR_NUM_ENTRIES +: `UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES] & umctl2_regs_sched_lpr_num_entries_mask[`UMCTL2_REG_OFFSET_SCHED_LPR_NUM_ENTRIES +: `UMCTL2_REG_SIZE_SCHED_LPR_NUM_ENTRIES];
            end
         end
         if (rwselect[94] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_go2critical_hysteresis[(`UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED_GO2CRITICAL_HYSTERESIS +: `UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS] & umctl2_regs_sched_go2critical_hysteresis_mask[`UMCTL2_REG_OFFSET_SCHED_GO2CRITICAL_HYSTERESIS +: `UMCTL2_REG_SIZE_SCHED_GO2CRITICAL_HYSTERESIS];
            end
         end
         if (rwselect[94] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rdwr_idle_gap[(`UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED_RDWR_IDLE_GAP +: `UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP] & umctl2_regs_sched_rdwr_idle_gap_mask[`UMCTL2_REG_OFFSET_SCHED_RDWR_IDLE_GAP +: `UMCTL2_REG_SIZE_SCHED_RDWR_IDLE_GAP];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.SCHED1
   //------------------------
         if (rwselect[95] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_pageclose_timer[(`UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_SCHED1_PAGECLOSE_TIMER +: `UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER] & umctl2_regs_sched1_pageclose_timer_mask[`UMCTL2_REG_OFFSET_SCHED1_PAGECLOSE_TIMER +: `UMCTL2_REG_SIZE_SCHED1_PAGECLOSE_TIMER];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.PERFHPR1
   //------------------------
         if (rwselect[97] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_hpr_max_starve[(`UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_MAX_STARVE +: `UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE] & umctl2_regs_perfhpr1_hpr_max_starve_mask[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_MAX_STARVE +: `UMCTL2_REG_SIZE_PERFHPR1_HPR_MAX_STARVE];
            end
         end
         if (rwselect[97] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_hpr_xact_run_length[(`UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH +: `UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH] & umctl2_regs_perfhpr1_hpr_xact_run_length_mask[`UMCTL2_REG_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH +: `UMCTL2_REG_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.PERFLPR1
   //------------------------
         if (rwselect[98] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_lpr_max_starve[(`UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_MAX_STARVE +: `UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE] & umctl2_regs_perflpr1_lpr_max_starve_mask[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_MAX_STARVE +: `UMCTL2_REG_SIZE_PERFLPR1_LPR_MAX_STARVE];
            end
         end
         if (rwselect[98] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_lpr_xact_run_length[(`UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH +: `UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH] & umctl2_regs_perflpr1_lpr_xact_run_length_mask[`UMCTL2_REG_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH +: `UMCTL2_REG_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.PERFWR1
   //------------------------
         if (rwselect[99] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_w_max_starve[(`UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PERFWR1_W_MAX_STARVE +: `UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE] & umctl2_regs_perfwr1_w_max_starve_mask[`UMCTL2_REG_OFFSET_PERFWR1_W_MAX_STARVE +: `UMCTL2_REG_SIZE_PERFWR1_W_MAX_STARVE];
            end
         end
         if (rwselect[99] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_w_xact_run_length[(`UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PERFWR1_W_XACT_RUN_LENGTH +: `UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH] & umctl2_regs_perfwr1_w_xact_run_length_mask[`UMCTL2_REG_OFFSET_PERFWR1_W_XACT_RUN_LENGTH +: `UMCTL2_REG_SIZE_PERFWR1_W_XACT_RUN_LENGTH];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DBG0
   //------------------------
         if (rwselect[124] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dis_wc <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBG0_DIS_WC +: `UMCTL2_REG_SIZE_DBG0_DIS_WC] & umctl2_regs_dbg0_dis_wc_mask[`UMCTL2_REG_OFFSET_DBG0_DIS_WC +: `UMCTL2_REG_SIZE_DBG0_DIS_WC];
            end
         end
         if (rwselect[124] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_dis_collision_page_opt <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBG0_DIS_COLLISION_PAGE_OPT +: `UMCTL2_REG_SIZE_DBG0_DIS_COLLISION_PAGE_OPT] & umctl2_regs_dbg0_dis_collision_page_opt_mask[`UMCTL2_REG_OFFSET_DBG0_DIS_COLLISION_PAGE_OPT +: `UMCTL2_REG_SIZE_DBG0_DIS_COLLISION_PAGE_OPT];
            end
         end
         if (rwselect[124] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dis_max_rank_rd_opt <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_RD_OPT +: `UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_RD_OPT] & umctl2_regs_dbg0_dis_max_rank_rd_opt_mask[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_RD_OPT +: `UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_RD_OPT];
            end
         end
         if (rwselect[124] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_dis_max_rank_wr_opt <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_WR_OPT +: `UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_WR_OPT] & umctl2_regs_dbg0_dis_max_rank_wr_opt_mask[`UMCTL2_REG_OFFSET_DBG0_DIS_MAX_RANK_WR_OPT +: `UMCTL2_REG_SIZE_DBG0_DIS_MAX_RANK_WR_OPT];
            end
         end
   //------------------------
   // Register UMCTL2_REGS.DBG1
   //------------------------
         if (rwselect[125] && write_en) begin
            ff_dis_dq <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBG1_DIS_DQ +: `UMCTL2_REG_SIZE_DBG1_DIS_DQ] & umctl2_regs_dbg1_dis_dq_mask[`UMCTL2_REG_OFFSET_DBG1_DIS_DQ +: `UMCTL2_REG_SIZE_DBG1_DIS_DQ];
         end
         if (rwselect[125] && write_en) begin
            ff_dis_hif <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBG1_DIS_HIF +: `UMCTL2_REG_SIZE_DBG1_DIS_HIF] & umctl2_regs_dbg1_dis_hif_mask[`UMCTL2_REG_OFFSET_DBG1_DIS_HIF +: `UMCTL2_REG_SIZE_DBG1_DIS_HIF];
         end
   //------------------------
   // Register UMCTL2_REGS.DBGCMD
   //------------------------
         if (reg_ddrc_rank0_refresh_ack_pclk) begin
            ff_rank0_refresh <= 1'b0;
            ff_rank0_refresh_saved <= 1'b0;
         end else begin
            if (ff_rank0_refresh_todo & (!ddrc_reg_rank0_refresh_busy_int)) begin
               ff_rank0_refresh_todo <= 1'b0;
               ff_rank0_refresh <= ff_rank0_refresh_saved;
            end else if (rwselect[126] & store_rqst & (apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_RANK0_REFRESH] & umctl2_regs_dbgcmd_rank0_refresh_mask[`UMCTL2_REG_OFFSET_DBGCMD_RANK0_REFRESH]) ) begin
               if (ddrc_reg_rank0_refresh_busy_int) begin
                  ff_rank0_refresh_todo <= 1'b1;
                  ff_rank0_refresh_saved <= 1'b1;
               end else begin
                  ff_rank0_refresh <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_RANK0_REFRESH] & umctl2_regs_dbgcmd_rank0_refresh_mask[`UMCTL2_REG_OFFSET_DBGCMD_RANK0_REFRESH];
               end
            end
         end
         if (reg_ddrc_rank1_refresh_ack_pclk) begin
            ff_rank1_refresh <= 1'b0;
            ff_rank1_refresh_saved <= 1'b0;
         end else begin
            if (ff_rank1_refresh_todo & (!ddrc_reg_rank1_refresh_busy_int)) begin
               ff_rank1_refresh_todo <= 1'b0;
               ff_rank1_refresh <= ff_rank1_refresh_saved;
            end else if (rwselect[126] & store_rqst & (apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_RANK1_REFRESH] & umctl2_regs_dbgcmd_rank1_refresh_mask[`UMCTL2_REG_OFFSET_DBGCMD_RANK1_REFRESH]) ) begin
               if (ddrc_reg_rank1_refresh_busy_int) begin
                  ff_rank1_refresh_todo <= 1'b1;
                  ff_rank1_refresh_saved <= 1'b1;
               end else begin
                  ff_rank1_refresh <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_RANK1_REFRESH] & umctl2_regs_dbgcmd_rank1_refresh_mask[`UMCTL2_REG_OFFSET_DBGCMD_RANK1_REFRESH];
               end
            end
         end
         if (reg_ddrc_zq_calib_short_ack_pclk) begin
            ff_zq_calib_short <= 1'b0;
            ff_zq_calib_short_saved <= 1'b0;
         end else begin
            if (ff_zq_calib_short_todo & (!ddrc_reg_zq_calib_short_busy_int)) begin
               ff_zq_calib_short_todo <= 1'b0;
               ff_zq_calib_short <= ff_zq_calib_short_saved;
            end else if (rwselect[126] & store_rqst & (apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_ZQ_CALIB_SHORT] & umctl2_regs_dbgcmd_zq_calib_short_mask[`UMCTL2_REG_OFFSET_DBGCMD_ZQ_CALIB_SHORT]) ) begin
               if (ddrc_reg_zq_calib_short_busy_int) begin
                  ff_zq_calib_short_todo <= 1'b1;
                  ff_zq_calib_short_saved <= 1'b1;
               end else begin
                  ff_zq_calib_short <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_ZQ_CALIB_SHORT] & umctl2_regs_dbgcmd_zq_calib_short_mask[`UMCTL2_REG_OFFSET_DBGCMD_ZQ_CALIB_SHORT];
               end
            end
         end
         if (reg_ddrc_ctrlupd_ack_pclk) begin
            ff_ctrlupd <= 1'b0;
            ff_ctrlupd_saved <= 1'b0;
         end else begin
            if (ff_ctrlupd_todo & (!ddrc_reg_ctrlupd_busy_int)) begin
               ff_ctrlupd_todo <= 1'b0;
               ff_ctrlupd <= ff_ctrlupd_saved;
            end else if (rwselect[126] & store_rqst & (apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_CTRLUPD] & umctl2_regs_dbgcmd_ctrlupd_mask[`UMCTL2_REG_OFFSET_DBGCMD_CTRLUPD]) ) begin
               if (ddrc_reg_ctrlupd_busy_int) begin
                  ff_ctrlupd_todo <= 1'b1;
                  ff_ctrlupd_saved <= 1'b1;
               end else begin
                  ff_ctrlupd <= apb_data_expanded[`UMCTL2_REG_OFFSET_DBGCMD_CTRLUPD] & umctl2_regs_dbgcmd_ctrlupd_mask[`UMCTL2_REG_OFFSET_DBGCMD_CTRLUPD];
               end
            end
         end
   //------------------------
   // Register UMCTL2_REGS.SWCTL
   //------------------------
         if (rwselect[127] && write_en) begin
            cfgs_ff_sw_done <= apb_data_expanded[`UMCTL2_REG_OFFSET_SWCTL_SW_DONE +: `UMCTL2_REG_SIZE_SWCTL_SW_DONE] & umctl2_regs_swctl_sw_done_mask[`UMCTL2_REG_OFFSET_SWCTL_SW_DONE +: `UMCTL2_REG_SIZE_SWCTL_SW_DONE];
         end
   //------------------------
   // Register UMCTL2_REGS.SWCTLSTATIC
   //------------------------
         if (rwselect[128] && write_en) begin
            cfgs_ff_sw_static_unlock <= apb_data_expanded[`UMCTL2_REG_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK +: `UMCTL2_REG_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK] & umctl2_regs_swctlstatic_sw_static_unlock_mask[`UMCTL2_REG_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK +: `UMCTL2_REG_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK];
         end
   //------------------------
   // Register UMCTL2_REGS.POISONCFG
   //------------------------
         if (rwselect[133] && write_en) begin
            ff_wr_poison_slverr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_SLVERR_EN +: `UMCTL2_REG_SIZE_POISONCFG_WR_POISON_SLVERR_EN] & umctl2_regs_poisoncfg_wr_poison_slverr_en_mask[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_SLVERR_EN +: `UMCTL2_REG_SIZE_POISONCFG_WR_POISON_SLVERR_EN];
         end
         if (rwselect[133] && write_en) begin
            ff_wr_poison_intr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_EN +: `UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_EN] & umctl2_regs_poisoncfg_wr_poison_intr_en_mask[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_EN +: `UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_EN];
         end
         if (reg_ddrc_wr_poison_intr_clr_ack_pclk) begin
            ff_wr_poison_intr_clr <= 1'b0;
         end else begin
            if (rwselect[133] && write_en) begin
               ff_wr_poison_intr_clr <= apb_data_expanded[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_CLR +: `UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_CLR] & umctl2_regs_poisoncfg_wr_poison_intr_clr_mask[`UMCTL2_REG_OFFSET_POISONCFG_WR_POISON_INTR_CLR +: `UMCTL2_REG_SIZE_POISONCFG_WR_POISON_INTR_CLR];
            end
         end
         if (rwselect[133] && write_en) begin
            ff_rd_poison_slverr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_SLVERR_EN +: `UMCTL2_REG_SIZE_POISONCFG_RD_POISON_SLVERR_EN] & umctl2_regs_poisoncfg_rd_poison_slverr_en_mask[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_SLVERR_EN +: `UMCTL2_REG_SIZE_POISONCFG_RD_POISON_SLVERR_EN];
         end
         if (rwselect[133] && write_en) begin
            ff_rd_poison_intr_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_EN +: `UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_EN] & umctl2_regs_poisoncfg_rd_poison_intr_en_mask[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_EN +: `UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_EN];
         end
         if (reg_ddrc_rd_poison_intr_clr_ack_pclk) begin
            ff_rd_poison_intr_clr <= 1'b0;
         end else begin
            if (rwselect[133] && write_en) begin
               ff_rd_poison_intr_clr <= apb_data_expanded[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_CLR +: `UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_CLR] & umctl2_regs_poisoncfg_rd_poison_intr_clr_mask[`UMCTL2_REG_OFFSET_POISONCFG_RD_POISON_INTR_CLR +: `UMCTL2_REG_SIZE_POISONCFG_RD_POISON_INTR_CLR];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCCFG
   //------------------------
         if (rwselect[148] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_go2critical_en <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCCFG_GO2CRITICAL_EN +: `UMCTL2_REG_SIZE_PCCFG_GO2CRITICAL_EN] & umctl2_mp_pccfg_go2critical_en_mask[`UMCTL2_REG_OFFSET_PCCFG_GO2CRITICAL_EN +: `UMCTL2_REG_SIZE_PCCFG_GO2CRITICAL_EN];
            end
         end
         if (rwselect[148] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_pagematch_limit <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCCFG_PAGEMATCH_LIMIT +: `UMCTL2_REG_SIZE_PCCFG_PAGEMATCH_LIMIT] & umctl2_mp_pccfg_pagematch_limit_mask[`UMCTL2_REG_OFFSET_PCCFG_PAGEMATCH_LIMIT +: `UMCTL2_REG_SIZE_PCCFG_PAGEMATCH_LIMIT];
            end
         end
         if (rwselect[148] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_bl_exp_mode <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCCFG_BL_EXP_MODE +: `UMCTL2_REG_SIZE_PCCFG_BL_EXP_MODE] & umctl2_mp_pccfg_bl_exp_mode_mask[`UMCTL2_REG_OFFSET_PCCFG_BL_EXP_MODE +: `UMCTL2_REG_SIZE_PCCFG_BL_EXP_MODE];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCFGR_0
   //------------------------
         if (rwselect[149] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rd_port_priority_0[(`UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PRIORITY_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0] & umctl2_mp_pcfgr_0_rd_port_priority_0_mask[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PRIORITY_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PRIORITY_0];
            end
         end
         if (rwselect[149] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rd_port_aging_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_AGING_EN_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_AGING_EN_0] & umctl2_mp_pcfgr_0_rd_port_aging_en_0_mask[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_AGING_EN_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_AGING_EN_0];
            end
         end
         if (rwselect[149] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rd_port_urgent_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_URGENT_EN_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_URGENT_EN_0] & umctl2_mp_pcfgr_0_rd_port_urgent_en_0_mask[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_URGENT_EN_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_URGENT_EN_0];
            end
         end
         if (rwselect[149] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_rd_port_pagematch_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PAGEMATCH_EN_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PAGEMATCH_EN_0] & umctl2_mp_pcfgr_0_rd_port_pagematch_en_0_mask[`UMCTL2_REG_OFFSET_PCFGR_0_RD_PORT_PAGEMATCH_EN_0 +: `UMCTL2_REG_SIZE_PCFGR_0_RD_PORT_PAGEMATCH_EN_0];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCFGW_0
   //------------------------
         if (rwselect[150] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_wr_port_priority_0[(`UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PRIORITY_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0] & umctl2_mp_pcfgw_0_wr_port_priority_0_mask[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PRIORITY_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PRIORITY_0];
            end
         end
         if (rwselect[150] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_wr_port_aging_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_AGING_EN_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_AGING_EN_0] & umctl2_mp_pcfgw_0_wr_port_aging_en_0_mask[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_AGING_EN_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_AGING_EN_0];
            end
         end
         if (rwselect[150] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_wr_port_urgent_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_URGENT_EN_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_URGENT_EN_0] & umctl2_mp_pcfgw_0_wr_port_urgent_en_0_mask[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_URGENT_EN_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_URGENT_EN_0];
            end
         end
         if (rwselect[150] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_wr_port_pagematch_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PAGEMATCH_EN_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PAGEMATCH_EN_0] & umctl2_mp_pcfgw_0_wr_port_pagematch_en_0_mask[`UMCTL2_REG_OFFSET_PCFGW_0_WR_PORT_PAGEMATCH_EN_0 +: `UMCTL2_REG_SIZE_PCFGW_0_WR_PORT_PAGEMATCH_EN_0];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCTRL_0
   //------------------------
         if (rwselect[184] && write_en) begin
            ff_port_en_0 <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCTRL_0_PORT_EN_0 +: `UMCTL2_REG_SIZE_PCTRL_0_PORT_EN_0] & umctl2_mp_pctrl_0_port_en_0_mask[`UMCTL2_REG_OFFSET_PCTRL_0_PORT_EN_0 +: `UMCTL2_REG_SIZE_PCTRL_0_PORT_EN_0];
         end
   //------------------------
   // Register UMCTL2_MP.PCFGQOS0_0
   //------------------------
         if (rwselect[185] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_rqos_map_level1_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_LEVEL1_0 +: `UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0] & umctl2_mp_pcfgqos0_0_rqos_map_level1_0_mask[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_LEVEL1_0 +: `UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_LEVEL1_0];
            end
         end
         if (rwselect[185] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_rqos_map_region0_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION0_0 +: `UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0] & umctl2_mp_pcfgqos0_0_rqos_map_region0_0_mask[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION0_0 +: `UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION0_0];
            end
         end
         if (rwselect[185] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_rqos_map_region1_0[(`UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION1_0 +: `UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0] & umctl2_mp_pcfgqos0_0_rqos_map_region1_0_mask[`UMCTL2_REG_OFFSET_PCFGQOS0_0_RQOS_MAP_REGION1_0 +: `UMCTL2_REG_SIZE_PCFGQOS0_0_RQOS_MAP_REGION1_0];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCFGQOS1_0
   //------------------------
         if (rwselect[186] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_rqos_map_timeoutb_0[(`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0 +: `UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0] & umctl2_mp_pcfgqos1_0_rqos_map_timeoutb_0_mask[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0 +: `UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTB_0];
            end
         end
         if (rwselect[186] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_rqos_map_timeoutr_0[(`UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0 +: `UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0] & umctl2_mp_pcfgqos1_0_rqos_map_timeoutr_0_mask[`UMCTL2_REG_OFFSET_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0 +: `UMCTL2_REG_SIZE_PCFGQOS1_0_RQOS_MAP_TIMEOUTR_0];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS0_0
   //------------------------
         if (rwselect[187] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_wqos_map_level1_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0] & umctl2_mp_pcfgwqos0_0_wqos_map_level1_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL1_0];
            end
         end
         if (rwselect[187] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_wqos_map_level2_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0] & umctl2_mp_pcfgwqos0_0_wqos_map_level2_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_LEVEL2_0];
            end
         end
         if (rwselect[187] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_wqos_map_region0_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION0_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0] & umctl2_mp_pcfgwqos0_0_wqos_map_region0_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION0_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION0_0];
            end
         end
         if (rwselect[187] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_wqos_map_region1_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION1_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0] & umctl2_mp_pcfgwqos0_0_wqos_map_region1_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION1_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION1_0];
            end
         end
         if (rwselect[187] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_wqos_map_region2_0[(`UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION2_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0] & umctl2_mp_pcfgwqos0_0_wqos_map_region2_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS0_0_WQOS_MAP_REGION2_0 +: `UMCTL2_REG_SIZE_PCFGWQOS0_0_WQOS_MAP_REGION2_0];
            end
         end
   //------------------------
   // Register UMCTL2_MP.PCFGWQOS1_0
   //------------------------
         if (rwselect[188] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wqos_map_timeout1_0[(`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0 +: `UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0] & umctl2_mp_pcfgwqos1_0_wqos_map_timeout1_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0 +: `UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT1_0];
            end
         end
         if (rwselect[188] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_wqos_map_timeout2_0[(`UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0) -1:0] <= apb_data_expanded[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0 +: `UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0] & umctl2_mp_pcfgwqos1_0_wqos_map_timeout2_0_mask[`UMCTL2_REG_OFFSET_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0 +: `UMCTL2_REG_SIZE_PCFGWQOS1_0_WQOS_MAP_TIMEOUT2_0];
            end
         end

      end 
   end



endmodule
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W528
