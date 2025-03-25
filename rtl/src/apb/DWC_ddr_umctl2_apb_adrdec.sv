//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_apb_adrdec.sv#9 $
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
module DWC_ddr_umctl2_apb_adrdec
  #(parameter APB_AW       = 16,
    parameter APB_DW       = 32,
    parameter REG_WIDTH    = 32,    
    parameter N_REGS       = `UMCTL2_REG_N_REGS,
    parameter RW_REGS      = `UMCTL2_REG_RW_REGS,
    parameter MAX_ADDR     = `UMCTL2_REG_UMCTL2_MAX_ADDR/4,
    parameter RWSELWIDTH   = RW_REGS,
    parameter N_APBFSMSTAT =
                            8
    )
   (input                       presetn,
    input                       pclk,
    input [APB_AW-1:2]          paddr,
    input                       pwrite,
    input                       psel,
    input [N_APBFSMSTAT-1:0]    apb_slv_ns,
    output reg [RWSELWIDTH-1:0] rwselect,
    output     [APB_DW-1:0]     prdata,
    output reg                  pslverr
   ,input [REG_WIDTH -1:0] r0_mstr
   ,input [REG_WIDTH -1:0] r1_stat
   ,input [REG_WIDTH -1:0] r4_mrctrl0
   ,input [REG_WIDTH -1:0] r5_mrctrl1
   ,input [REG_WIDTH -1:0] r6_mrstat
   ,input [REG_WIDTH -1:0] r7_mrctrl2
   ,input [REG_WIDTH -1:0] r12_pwrctl
   ,input [REG_WIDTH -1:0] r13_pwrtmg
   ,input [REG_WIDTH -1:0] r14_hwlpctl
   ,input [REG_WIDTH -1:0] r17_rfshctl0
   ,input [REG_WIDTH -1:0] r18_rfshctl1
   ,input [REG_WIDTH -1:0] r21_rfshctl3
   ,input [REG_WIDTH -1:0] r22_rfshtmg
   ,input [REG_WIDTH -1:0] r44_crcparctl0
   ,input [REG_WIDTH -1:0] r45_crcparctl1
   ,input [REG_WIDTH -1:0] r47_crcparstat
   ,input [REG_WIDTH -1:0] r48_init0
   ,input [REG_WIDTH -1:0] r49_init1
   ,input [REG_WIDTH -1:0] r51_init3
   ,input [REG_WIDTH -1:0] r52_init4
   ,input [REG_WIDTH -1:0] r53_init5
   ,input [REG_WIDTH -1:0] r54_init6
   ,input [REG_WIDTH -1:0] r55_init7
   ,input [REG_WIDTH -1:0] r56_dimmctl
   ,input [REG_WIDTH -1:0] r57_rankctl
   ,input [REG_WIDTH -1:0] r59_dramtmg0
   ,input [REG_WIDTH -1:0] r60_dramtmg1
   ,input [REG_WIDTH -1:0] r61_dramtmg2
   ,input [REG_WIDTH -1:0] r62_dramtmg3
   ,input [REG_WIDTH -1:0] r63_dramtmg4
   ,input [REG_WIDTH -1:0] r64_dramtmg5
   ,input [REG_WIDTH -1:0] r67_dramtmg8
   ,input [REG_WIDTH -1:0] r68_dramtmg9
   ,input [REG_WIDTH -1:0] r69_dramtmg10
   ,input [REG_WIDTH -1:0] r70_dramtmg11
   ,input [REG_WIDTH -1:0] r71_dramtmg12
   ,input [REG_WIDTH -1:0] r74_dramtmg15
   ,input [REG_WIDTH -1:0] r82_zqctl0
   ,input [REG_WIDTH -1:0] r83_zqctl1
   ,input [REG_WIDTH -1:0] r86_dfitmg0
   ,input [REG_WIDTH -1:0] r87_dfitmg1
   ,input [REG_WIDTH -1:0] r88_dfilpcfg0
   ,input [REG_WIDTH -1:0] r89_dfilpcfg1
   ,input [REG_WIDTH -1:0] r90_dfiupd0
   ,input [REG_WIDTH -1:0] r91_dfiupd1
   ,input [REG_WIDTH -1:0] r92_dfiupd2
   ,input [REG_WIDTH -1:0] r94_dfimisc
   ,input [REG_WIDTH -1:0] r96_dfitmg3
   ,input [REG_WIDTH -1:0] r97_dfistat
   ,input [REG_WIDTH -1:0] r98_dbictl
   ,input [REG_WIDTH -1:0] r99_dfiphymstr
   ,input [REG_WIDTH -1:0] r100_addrmap0
   ,input [REG_WIDTH -1:0] r101_addrmap1
   ,input [REG_WIDTH -1:0] r102_addrmap2
   ,input [REG_WIDTH -1:0] r103_addrmap3
   ,input [REG_WIDTH -1:0] r104_addrmap4
   ,input [REG_WIDTH -1:0] r105_addrmap5
   ,input [REG_WIDTH -1:0] r106_addrmap6
   ,input [REG_WIDTH -1:0] r107_addrmap7
   ,input [REG_WIDTH -1:0] r108_addrmap8
   ,input [REG_WIDTH -1:0] r109_addrmap9
   ,input [REG_WIDTH -1:0] r110_addrmap10
   ,input [REG_WIDTH -1:0] r111_addrmap11
   ,input [REG_WIDTH -1:0] r113_odtcfg
   ,input [REG_WIDTH -1:0] r114_odtmap
   ,input [REG_WIDTH -1:0] r115_sched
   ,input [REG_WIDTH -1:0] r116_sched1
   ,input [REG_WIDTH -1:0] r118_perfhpr1
   ,input [REG_WIDTH -1:0] r119_perflpr1
   ,input [REG_WIDTH -1:0] r120_perfwr1
   ,input [REG_WIDTH -1:0] r145_dbg0
   ,input [REG_WIDTH -1:0] r146_dbg1
   ,input [REG_WIDTH -1:0] r147_dbgcam
   ,input [REG_WIDTH -1:0] r148_dbgcmd
   ,input [REG_WIDTH -1:0] r149_dbgstat
   ,input [REG_WIDTH -1:0] r151_swctl
   ,input [REG_WIDTH -1:0] r152_swstat
   ,input [REG_WIDTH -1:0] r153_swctlstatic
   ,input [REG_WIDTH -1:0] r169_poisoncfg
   ,input [REG_WIDTH -1:0] r170_poisonstat
   ,input [REG_WIDTH -1:0] r193_pstat
   ,input [REG_WIDTH -1:0] r194_pccfg
   ,input [REG_WIDTH -1:0] r195_pcfgr_0
   ,input [REG_WIDTH -1:0] r196_pcfgw_0
   ,input [REG_WIDTH -1:0] r230_pctrl_0
   ,input [REG_WIDTH -1:0] r231_pcfgqos0_0
   ,input [REG_WIDTH -1:0] r232_pcfgqos1_0
   ,input [REG_WIDTH -1:0] r233_pcfgwqos0_0
   ,input [REG_WIDTH -1:0] r234_pcfgwqos1_0
   ,input [REG_WIDTH -1:0] r856_umctl2_ver_number
   ,input [REG_WIDTH -1:0] r857_umctl2_ver_type

    );   

   localparam IDLE       = 8'b00000001;
   localparam ADDRDECODE = 8'b00000010;
   localparam SAMPLERDY  = 8'b00001000;
   localparam SELWIDTH   = N_REGS;

   localparam REG_AW = APB_AW - 2;
   localparam UMCTL2_REGS_MSTR_ADDR = `UMCTL2_REG_MSTR_ADDR;
   localparam UMCTL2_REGS_STAT_ADDR = `UMCTL2_REG_STAT_ADDR;
   localparam UMCTL2_REGS_MRCTRL0_ADDR = `UMCTL2_REG_MRCTRL0_ADDR;
   localparam UMCTL2_REGS_MRCTRL1_ADDR = `UMCTL2_REG_MRCTRL1_ADDR;
   localparam UMCTL2_REGS_MRSTAT_ADDR = `UMCTL2_REG_MRSTAT_ADDR;
   localparam UMCTL2_REGS_MRCTRL2_ADDR = `UMCTL2_REG_MRCTRL2_ADDR;
   localparam UMCTL2_REGS_PWRCTL_ADDR = `UMCTL2_REG_PWRCTL_ADDR;
   localparam UMCTL2_REGS_PWRTMG_ADDR = `UMCTL2_REG_PWRTMG_ADDR;
   localparam UMCTL2_REGS_HWLPCTL_ADDR = `UMCTL2_REG_HWLPCTL_ADDR;
   localparam UMCTL2_REGS_RFSHCTL0_ADDR = `UMCTL2_REG_RFSHCTL0_ADDR;
   localparam UMCTL2_REGS_RFSHCTL1_ADDR = `UMCTL2_REG_RFSHCTL1_ADDR;
   localparam UMCTL2_REGS_RFSHCTL3_ADDR = `UMCTL2_REG_RFSHCTL3_ADDR;
   localparam UMCTL2_REGS_RFSHTMG_ADDR = `UMCTL2_REG_RFSHTMG_ADDR;
   localparam UMCTL2_REGS_CRCPARCTL0_ADDR = `UMCTL2_REG_CRCPARCTL0_ADDR;
   localparam UMCTL2_REGS_CRCPARCTL1_ADDR = `UMCTL2_REG_CRCPARCTL1_ADDR;
   localparam UMCTL2_REGS_CRCPARSTAT_ADDR = `UMCTL2_REG_CRCPARSTAT_ADDR;
   localparam UMCTL2_REGS_INIT0_ADDR = `UMCTL2_REG_INIT0_ADDR;
   localparam UMCTL2_REGS_INIT1_ADDR = `UMCTL2_REG_INIT1_ADDR;
   localparam UMCTL2_REGS_INIT3_ADDR = `UMCTL2_REG_INIT3_ADDR;
   localparam UMCTL2_REGS_INIT4_ADDR = `UMCTL2_REG_INIT4_ADDR;
   localparam UMCTL2_REGS_INIT5_ADDR = `UMCTL2_REG_INIT5_ADDR;
   localparam UMCTL2_REGS_INIT6_ADDR = `UMCTL2_REG_INIT6_ADDR;
   localparam UMCTL2_REGS_INIT7_ADDR = `UMCTL2_REG_INIT7_ADDR;
   localparam UMCTL2_REGS_DIMMCTL_ADDR = `UMCTL2_REG_DIMMCTL_ADDR;
   localparam UMCTL2_REGS_RANKCTL_ADDR = `UMCTL2_REG_RANKCTL_ADDR;
   localparam UMCTL2_REGS_DRAMTMG0_ADDR = `UMCTL2_REG_DRAMTMG0_ADDR;
   localparam UMCTL2_REGS_DRAMTMG1_ADDR = `UMCTL2_REG_DRAMTMG1_ADDR;
   localparam UMCTL2_REGS_DRAMTMG2_ADDR = `UMCTL2_REG_DRAMTMG2_ADDR;
   localparam UMCTL2_REGS_DRAMTMG3_ADDR = `UMCTL2_REG_DRAMTMG3_ADDR;
   localparam UMCTL2_REGS_DRAMTMG4_ADDR = `UMCTL2_REG_DRAMTMG4_ADDR;
   localparam UMCTL2_REGS_DRAMTMG5_ADDR = `UMCTL2_REG_DRAMTMG5_ADDR;
   localparam UMCTL2_REGS_DRAMTMG8_ADDR = `UMCTL2_REG_DRAMTMG8_ADDR;
   localparam UMCTL2_REGS_DRAMTMG9_ADDR = `UMCTL2_REG_DRAMTMG9_ADDR;
   localparam UMCTL2_REGS_DRAMTMG10_ADDR = `UMCTL2_REG_DRAMTMG10_ADDR;
   localparam UMCTL2_REGS_DRAMTMG11_ADDR = `UMCTL2_REG_DRAMTMG11_ADDR;
   localparam UMCTL2_REGS_DRAMTMG12_ADDR = `UMCTL2_REG_DRAMTMG12_ADDR;
   localparam UMCTL2_REGS_DRAMTMG15_ADDR = `UMCTL2_REG_DRAMTMG15_ADDR;
   localparam UMCTL2_REGS_ZQCTL0_ADDR = `UMCTL2_REG_ZQCTL0_ADDR;
   localparam UMCTL2_REGS_ZQCTL1_ADDR = `UMCTL2_REG_ZQCTL1_ADDR;
   localparam UMCTL2_REGS_DFITMG0_ADDR = `UMCTL2_REG_DFITMG0_ADDR;
   localparam UMCTL2_REGS_DFITMG1_ADDR = `UMCTL2_REG_DFITMG1_ADDR;
   localparam UMCTL2_REGS_DFILPCFG0_ADDR = `UMCTL2_REG_DFILPCFG0_ADDR;
   localparam UMCTL2_REGS_DFILPCFG1_ADDR = `UMCTL2_REG_DFILPCFG1_ADDR;
   localparam UMCTL2_REGS_DFIUPD0_ADDR = `UMCTL2_REG_DFIUPD0_ADDR;
   localparam UMCTL2_REGS_DFIUPD1_ADDR = `UMCTL2_REG_DFIUPD1_ADDR;
   localparam UMCTL2_REGS_DFIUPD2_ADDR = `UMCTL2_REG_DFIUPD2_ADDR;
   localparam UMCTL2_REGS_DFIMISC_ADDR = `UMCTL2_REG_DFIMISC_ADDR;
   localparam UMCTL2_REGS_DFITMG3_ADDR = `UMCTL2_REG_DFITMG3_ADDR;
   localparam UMCTL2_REGS_DFISTAT_ADDR = `UMCTL2_REG_DFISTAT_ADDR;
   localparam UMCTL2_REGS_DBICTL_ADDR = `UMCTL2_REG_DBICTL_ADDR;
   localparam UMCTL2_REGS_DFIPHYMSTR_ADDR = `UMCTL2_REG_DFIPHYMSTR_ADDR;
   localparam UMCTL2_REGS_ADDRMAP0_ADDR = `UMCTL2_REG_ADDRMAP0_ADDR;
   localparam UMCTL2_REGS_ADDRMAP1_ADDR = `UMCTL2_REG_ADDRMAP1_ADDR;
   localparam UMCTL2_REGS_ADDRMAP2_ADDR = `UMCTL2_REG_ADDRMAP2_ADDR;
   localparam UMCTL2_REGS_ADDRMAP3_ADDR = `UMCTL2_REG_ADDRMAP3_ADDR;
   localparam UMCTL2_REGS_ADDRMAP4_ADDR = `UMCTL2_REG_ADDRMAP4_ADDR;
   localparam UMCTL2_REGS_ADDRMAP5_ADDR = `UMCTL2_REG_ADDRMAP5_ADDR;
   localparam UMCTL2_REGS_ADDRMAP6_ADDR = `UMCTL2_REG_ADDRMAP6_ADDR;
   localparam UMCTL2_REGS_ADDRMAP7_ADDR = `UMCTL2_REG_ADDRMAP7_ADDR;
   localparam UMCTL2_REGS_ADDRMAP8_ADDR = `UMCTL2_REG_ADDRMAP8_ADDR;
   localparam UMCTL2_REGS_ADDRMAP9_ADDR = `UMCTL2_REG_ADDRMAP9_ADDR;
   localparam UMCTL2_REGS_ADDRMAP10_ADDR = `UMCTL2_REG_ADDRMAP10_ADDR;
   localparam UMCTL2_REGS_ADDRMAP11_ADDR = `UMCTL2_REG_ADDRMAP11_ADDR;
   localparam UMCTL2_REGS_ODTCFG_ADDR = `UMCTL2_REG_ODTCFG_ADDR;
   localparam UMCTL2_REGS_ODTMAP_ADDR = `UMCTL2_REG_ODTMAP_ADDR;
   localparam UMCTL2_REGS_SCHED_ADDR = `UMCTL2_REG_SCHED_ADDR;
   localparam UMCTL2_REGS_SCHED1_ADDR = `UMCTL2_REG_SCHED1_ADDR;
   localparam UMCTL2_REGS_PERFHPR1_ADDR = `UMCTL2_REG_PERFHPR1_ADDR;
   localparam UMCTL2_REGS_PERFLPR1_ADDR = `UMCTL2_REG_PERFLPR1_ADDR;
   localparam UMCTL2_REGS_PERFWR1_ADDR = `UMCTL2_REG_PERFWR1_ADDR;
   localparam UMCTL2_REGS_DBG0_ADDR = `UMCTL2_REG_DBG0_ADDR;
   localparam UMCTL2_REGS_DBG1_ADDR = `UMCTL2_REG_DBG1_ADDR;
   localparam UMCTL2_REGS_DBGCAM_ADDR = `UMCTL2_REG_DBGCAM_ADDR;
   localparam UMCTL2_REGS_DBGCMD_ADDR = `UMCTL2_REG_DBGCMD_ADDR;
   localparam UMCTL2_REGS_DBGSTAT_ADDR = `UMCTL2_REG_DBGSTAT_ADDR;
   localparam UMCTL2_REGS_SWCTL_ADDR = `UMCTL2_REG_SWCTL_ADDR;
   localparam UMCTL2_REGS_SWSTAT_ADDR = `UMCTL2_REG_SWSTAT_ADDR;
   localparam UMCTL2_REGS_SWCTLSTATIC_ADDR = `UMCTL2_REG_SWCTLSTATIC_ADDR;
   localparam UMCTL2_REGS_POISONCFG_ADDR = `UMCTL2_REG_POISONCFG_ADDR;
   localparam UMCTL2_REGS_POISONSTAT_ADDR = `UMCTL2_REG_POISONSTAT_ADDR;
   localparam UMCTL2_MP_PSTAT_ADDR = `UMCTL2_REG_PSTAT_ADDR;
   localparam UMCTL2_MP_PCCFG_ADDR = `UMCTL2_REG_PCCFG_ADDR;
   localparam UMCTL2_MP_PCFGR_0_ADDR = `UMCTL2_REG_PCFGR_0_ADDR;
   localparam UMCTL2_MP_PCFGW_0_ADDR = `UMCTL2_REG_PCFGW_0_ADDR;
   localparam UMCTL2_MP_PCTRL_0_ADDR = `UMCTL2_REG_PCTRL_0_ADDR;
   localparam UMCTL2_MP_PCFGQOS0_0_ADDR = `UMCTL2_REG_PCFGQOS0_0_ADDR;
   localparam UMCTL2_MP_PCFGQOS1_0_ADDR = `UMCTL2_REG_PCFGQOS1_0_ADDR;
   localparam UMCTL2_MP_PCFGWQOS0_0_ADDR = `UMCTL2_REG_PCFGWQOS0_0_ADDR;
   localparam UMCTL2_MP_PCFGWQOS1_0_ADDR = `UMCTL2_REG_PCFGWQOS1_0_ADDR;
   localparam UMCTL2_MP_UMCTL2_VER_NUMBER_ADDR = `UMCTL2_REG_UMCTL2_VER_NUMBER_ADDR;
   localparam UMCTL2_MP_UMCTL2_VER_TYPE_ADDR = `UMCTL2_REG_UMCTL2_VER_TYPE_ADDR;


   reg [SELWIDTH-1:0]               onehotsel;
   reg [REG_AW-1:0]                 reg_addr;
   reg [REG_WIDTH
                  -1:0]  rfm_data_decoded;
   reg [REG_WIDTH
                  -1:0]  rfm_data_decoded_next;
   reg                              addr_out_of_range;
   wire [SELWIDTH-1:0]              onehotsel_regpar;
   
   always @(posedge pclk or negedge presetn) begin : sample_pclk_paddr_PROC
      if (~presetn) begin
         reg_addr <= {REG_AW{1'b0}};
      end else begin
         if(psel) begin
            // -- Register address
            // -- Strip off bits [1:0] which are embedded into byte enables
            reg_addr <= paddr[APB_AW-1:2];
         end
      end
   end


   // -- Write Address Decoding ----
   always_comb begin : rwselect_combo_PROC
      rwselect = {RWSELWIDTH{1'b0}};
      if(reg_addr==UMCTL2_REGS_MSTR_ADDR[REG_AW-1:0]) begin
         rwselect[0] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_MRCTRL0_ADDR[REG_AW-1:0]) begin
         rwselect[3] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_MRCTRL1_ADDR[REG_AW-1:0]) begin
         rwselect[4] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_MRCTRL2_ADDR[REG_AW-1:0]) begin
         rwselect[5] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_PWRCTL_ADDR[REG_AW-1:0]) begin
         rwselect[10] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_PWRTMG_ADDR[REG_AW-1:0]) begin
         rwselect[11] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_HWLPCTL_ADDR[REG_AW-1:0]) begin
         rwselect[12] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_RFSHCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[14] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_RFSHCTL1_ADDR[REG_AW-1:0]) begin
         rwselect[15] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_RFSHCTL3_ADDR[REG_AW-1:0]) begin
         rwselect[18] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_RFSHTMG_ADDR[REG_AW-1:0]) begin
         rwselect[19] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_CRCPARCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[26] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_CRCPARCTL1_ADDR[REG_AW-1:0]) begin
         rwselect[27] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT0_ADDR[REG_AW-1:0]) begin
         rwselect[29] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT1_ADDR[REG_AW-1:0]) begin
         rwselect[30] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT3_ADDR[REG_AW-1:0]) begin
         rwselect[32] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT4_ADDR[REG_AW-1:0]) begin
         rwselect[33] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT5_ADDR[REG_AW-1:0]) begin
         rwselect[34] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT6_ADDR[REG_AW-1:0]) begin
         rwselect[35] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_INIT7_ADDR[REG_AW-1:0]) begin
         rwselect[36] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DIMMCTL_ADDR[REG_AW-1:0]) begin
         rwselect[37] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_RANKCTL_ADDR[REG_AW-1:0]) begin
         rwselect[38] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[40] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG1_ADDR[REG_AW-1:0]) begin
         rwselect[41] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG2_ADDR[REG_AW-1:0]) begin
         rwselect[42] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG3_ADDR[REG_AW-1:0]) begin
         rwselect[43] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG4_ADDR[REG_AW-1:0]) begin
         rwselect[44] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG5_ADDR[REG_AW-1:0]) begin
         rwselect[45] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG8_ADDR[REG_AW-1:0]) begin
         rwselect[48] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG9_ADDR[REG_AW-1:0]) begin
         rwselect[49] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG10_ADDR[REG_AW-1:0]) begin
         rwselect[50] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG11_ADDR[REG_AW-1:0]) begin
         rwselect[51] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG12_ADDR[REG_AW-1:0]) begin
         rwselect[52] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DRAMTMG15_ADDR[REG_AW-1:0]) begin
         rwselect[55] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ZQCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[63] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ZQCTL1_ADDR[REG_AW-1:0]) begin
         rwselect[64] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFITMG0_ADDR[REG_AW-1:0]) begin
         rwselect[66] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFITMG1_ADDR[REG_AW-1:0]) begin
         rwselect[67] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFILPCFG0_ADDR[REG_AW-1:0]) begin
         rwselect[68] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFILPCFG1_ADDR[REG_AW-1:0]) begin
         rwselect[69] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFIUPD0_ADDR[REG_AW-1:0]) begin
         rwselect[70] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFIUPD1_ADDR[REG_AW-1:0]) begin
         rwselect[71] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFIUPD2_ADDR[REG_AW-1:0]) begin
         rwselect[72] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFIMISC_ADDR[REG_AW-1:0]) begin
         rwselect[74] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFITMG3_ADDR[REG_AW-1:0]) begin
         rwselect[76] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DBICTL_ADDR[REG_AW-1:0]) begin
         rwselect[77] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DFIPHYMSTR_ADDR[REG_AW-1:0]) begin
         rwselect[78] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP0_ADDR[REG_AW-1:0]) begin
         rwselect[79] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP1_ADDR[REG_AW-1:0]) begin
         rwselect[80] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP2_ADDR[REG_AW-1:0]) begin
         rwselect[81] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP3_ADDR[REG_AW-1:0]) begin
         rwselect[82] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP4_ADDR[REG_AW-1:0]) begin
         rwselect[83] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP5_ADDR[REG_AW-1:0]) begin
         rwselect[84] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP6_ADDR[REG_AW-1:0]) begin
         rwselect[85] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP7_ADDR[REG_AW-1:0]) begin
         rwselect[86] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP8_ADDR[REG_AW-1:0]) begin
         rwselect[87] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP9_ADDR[REG_AW-1:0]) begin
         rwselect[88] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP10_ADDR[REG_AW-1:0]) begin
         rwselect[89] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ADDRMAP11_ADDR[REG_AW-1:0]) begin
         rwselect[90] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ODTCFG_ADDR[REG_AW-1:0]) begin
         rwselect[92] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_ODTMAP_ADDR[REG_AW-1:0]) begin
         rwselect[93] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_SCHED_ADDR[REG_AW-1:0]) begin
         rwselect[94] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_SCHED1_ADDR[REG_AW-1:0]) begin
         rwselect[95] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_PERFHPR1_ADDR[REG_AW-1:0]) begin
         rwselect[97] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_PERFLPR1_ADDR[REG_AW-1:0]) begin
         rwselect[98] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_PERFWR1_ADDR[REG_AW-1:0]) begin
         rwselect[99] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DBG0_ADDR[REG_AW-1:0]) begin
         rwselect[124] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DBG1_ADDR[REG_AW-1:0]) begin
         rwselect[125] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_DBGCMD_ADDR[REG_AW-1:0]) begin
         rwselect[126] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_SWCTL_ADDR[REG_AW-1:0]) begin
         rwselect[127] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_SWCTLSTATIC_ADDR[REG_AW-1:0]) begin
         rwselect[128] = 1'b1;
      end
      if(reg_addr==UMCTL2_REGS_POISONCFG_ADDR[REG_AW-1:0]) begin
         rwselect[133] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCCFG_ADDR[REG_AW-1:0]) begin
         rwselect[148] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCFGR_0_ADDR[REG_AW-1:0]) begin
         rwselect[149] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCFGW_0_ADDR[REG_AW-1:0]) begin
         rwselect[150] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCTRL_0_ADDR[REG_AW-1:0]) begin
         rwselect[184] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCFGQOS0_0_ADDR[REG_AW-1:0]) begin
         rwselect[185] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCFGQOS1_0_ADDR[REG_AW-1:0]) begin
         rwselect[186] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCFGWQOS0_0_ADDR[REG_AW-1:0]) begin
         rwselect[187] = 1'b1;
      end
      if(reg_addr==UMCTL2_MP_PCFGWQOS1_0_ADDR[REG_AW-1:0]) begin
         rwselect[188] = 1'b1;
      end

   end

   // -- Read Address Decoding ----
   // The incoming binary address is decoded to onehot.
   // Individual bits of the one hot address are used
   // to select the respective register in the map
   always_comb begin : onehotsel_combo_PROC
      onehotsel = {SELWIDTH{1'b0}};
         if(reg_addr==UMCTL2_REGS_MSTR_ADDR[REG_AW-1:0]) begin
            onehotsel[0] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_STAT_ADDR[REG_AW-1:0]) begin
            onehotsel[1] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_MRCTRL0_ADDR[REG_AW-1:0]) begin
            onehotsel[4] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_MRCTRL1_ADDR[REG_AW-1:0]) begin
            onehotsel[5] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_MRSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[6] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_MRCTRL2_ADDR[REG_AW-1:0]) begin
            onehotsel[7] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_PWRCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[12] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_PWRTMG_ADDR[REG_AW-1:0]) begin
            onehotsel[13] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_HWLPCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[14] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_RFSHCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[17] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_RFSHCTL1_ADDR[REG_AW-1:0]) begin
            onehotsel[18] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_RFSHCTL3_ADDR[REG_AW-1:0]) begin
            onehotsel[21] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_RFSHTMG_ADDR[REG_AW-1:0]) begin
            onehotsel[22] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_CRCPARCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[44] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_CRCPARCTL1_ADDR[REG_AW-1:0]) begin
            onehotsel[45] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_CRCPARSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[47] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT0_ADDR[REG_AW-1:0]) begin
            onehotsel[48] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT1_ADDR[REG_AW-1:0]) begin
            onehotsel[49] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT3_ADDR[REG_AW-1:0]) begin
            onehotsel[51] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT4_ADDR[REG_AW-1:0]) begin
            onehotsel[52] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT5_ADDR[REG_AW-1:0]) begin
            onehotsel[53] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT6_ADDR[REG_AW-1:0]) begin
            onehotsel[54] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_INIT7_ADDR[REG_AW-1:0]) begin
            onehotsel[55] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DIMMCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[56] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_RANKCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[57] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[59] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[60] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG2_ADDR[REG_AW-1:0]) begin
            onehotsel[61] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG3_ADDR[REG_AW-1:0]) begin
            onehotsel[62] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG4_ADDR[REG_AW-1:0]) begin
            onehotsel[63] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG5_ADDR[REG_AW-1:0]) begin
            onehotsel[64] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG8_ADDR[REG_AW-1:0]) begin
            onehotsel[67] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG9_ADDR[REG_AW-1:0]) begin
            onehotsel[68] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG10_ADDR[REG_AW-1:0]) begin
            onehotsel[69] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG11_ADDR[REG_AW-1:0]) begin
            onehotsel[70] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG12_ADDR[REG_AW-1:0]) begin
            onehotsel[71] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DRAMTMG15_ADDR[REG_AW-1:0]) begin
            onehotsel[74] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ZQCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[82] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ZQCTL1_ADDR[REG_AW-1:0]) begin
            onehotsel[83] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFITMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[86] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFITMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[87] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFILPCFG0_ADDR[REG_AW-1:0]) begin
            onehotsel[88] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFILPCFG1_ADDR[REG_AW-1:0]) begin
            onehotsel[89] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFIUPD0_ADDR[REG_AW-1:0]) begin
            onehotsel[90] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFIUPD1_ADDR[REG_AW-1:0]) begin
            onehotsel[91] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFIUPD2_ADDR[REG_AW-1:0]) begin
            onehotsel[92] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFIMISC_ADDR[REG_AW-1:0]) begin
            onehotsel[94] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFITMG3_ADDR[REG_AW-1:0]) begin
            onehotsel[96] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFISTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[97] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DBICTL_ADDR[REG_AW-1:0]) begin
            onehotsel[98] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DFIPHYMSTR_ADDR[REG_AW-1:0]) begin
            onehotsel[99] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP0_ADDR[REG_AW-1:0]) begin
            onehotsel[100] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP1_ADDR[REG_AW-1:0]) begin
            onehotsel[101] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP2_ADDR[REG_AW-1:0]) begin
            onehotsel[102] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP3_ADDR[REG_AW-1:0]) begin
            onehotsel[103] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP4_ADDR[REG_AW-1:0]) begin
            onehotsel[104] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP5_ADDR[REG_AW-1:0]) begin
            onehotsel[105] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP6_ADDR[REG_AW-1:0]) begin
            onehotsel[106] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP7_ADDR[REG_AW-1:0]) begin
            onehotsel[107] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP8_ADDR[REG_AW-1:0]) begin
            onehotsel[108] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP9_ADDR[REG_AW-1:0]) begin
            onehotsel[109] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP10_ADDR[REG_AW-1:0]) begin
            onehotsel[110] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ADDRMAP11_ADDR[REG_AW-1:0]) begin
            onehotsel[111] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ODTCFG_ADDR[REG_AW-1:0]) begin
            onehotsel[113] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_ODTMAP_ADDR[REG_AW-1:0]) begin
            onehotsel[114] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_SCHED_ADDR[REG_AW-1:0]) begin
            onehotsel[115] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_SCHED1_ADDR[REG_AW-1:0]) begin
            onehotsel[116] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_PERFHPR1_ADDR[REG_AW-1:0]) begin
            onehotsel[118] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_PERFLPR1_ADDR[REG_AW-1:0]) begin
            onehotsel[119] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_PERFWR1_ADDR[REG_AW-1:0]) begin
            onehotsel[120] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DBG0_ADDR[REG_AW-1:0]) begin
            onehotsel[145] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DBG1_ADDR[REG_AW-1:0]) begin
            onehotsel[146] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DBGCAM_ADDR[REG_AW-1:0]) begin
            onehotsel[147] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DBGCMD_ADDR[REG_AW-1:0]) begin
            onehotsel[148] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_DBGSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[149] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_SWCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[151] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_SWSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[152] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_SWCTLSTATIC_ADDR[REG_AW-1:0]) begin
            onehotsel[153] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_POISONCFG_ADDR[REG_AW-1:0]) begin
            onehotsel[169] = 1'b1;
         end
         if(reg_addr==UMCTL2_REGS_POISONSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[170] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[193] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCCFG_ADDR[REG_AW-1:0]) begin
            onehotsel[194] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCFGR_0_ADDR[REG_AW-1:0]) begin
            onehotsel[195] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCFGW_0_ADDR[REG_AW-1:0]) begin
            onehotsel[196] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCTRL_0_ADDR[REG_AW-1:0]) begin
            onehotsel[230] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCFGQOS0_0_ADDR[REG_AW-1:0]) begin
            onehotsel[231] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCFGQOS1_0_ADDR[REG_AW-1:0]) begin
            onehotsel[232] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCFGWQOS0_0_ADDR[REG_AW-1:0]) begin
            onehotsel[233] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_PCFGWQOS1_0_ADDR[REG_AW-1:0]) begin
            onehotsel[234] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_UMCTL2_VER_NUMBER_ADDR[REG_AW-1:0]) begin
            onehotsel[856] = 1'b1;
         end
         if(reg_addr==UMCTL2_MP_UMCTL2_VER_TYPE_ADDR[REG_AW-1:0]) begin
            onehotsel[857] = 1'b1;
         end

   end
   
   assign onehotsel_regpar = onehotsel;



   always @(posedge pclk or negedge presetn) begin : sample_pclk_rdata_PROC
      if (~presetn) begin
         rfm_data_decoded <= {(REG_WIDTH
                                          ){1'b0}};
      end else begin
         if(apb_slv_ns==ADDRDECODE && (~pwrite)) begin
            rfm_data_decoded <= rfm_data_decoded_next;
         end
      end
   end

   // --- Multiplex the output data based on selects ---   
   always_comb begin : select_data_combo_PROC
      case (onehotsel_regpar)
         {1067'b0,1'b1} : rfm_data_decoded_next = r0_mstr; // 0 
         {1066'b0,1'b1,1'b0} : rfm_data_decoded_next = r1_stat; // 1 
         {1063'b0,1'b1,4'b0} : rfm_data_decoded_next = r4_mrctrl0; // 4 
         {1062'b0,1'b1,5'b0} : rfm_data_decoded_next = r5_mrctrl1; // 5 
         {1061'b0,1'b1,6'b0} : rfm_data_decoded_next = r6_mrstat ; // 6 
         {1060'b0,1'b1,7'b0} : rfm_data_decoded_next = r7_mrctrl2; // 7 
         {1055'b0,1'b1,12'b0} : rfm_data_decoded_next = r12_pwrctl; // 12 
         {1054'b0,1'b1,13'b0} : rfm_data_decoded_next = r13_pwrtmg; // 13 
         {1053'b0,1'b1,14'b0} : rfm_data_decoded_next = r14_hwlpctl; // 14 
         {1050'b0,1'b1,17'b0} : rfm_data_decoded_next = r17_rfshctl0; // 17 
         {1049'b0,1'b1,18'b0} : rfm_data_decoded_next = r18_rfshctl1; // 18 
         {1046'b0,1'b1,21'b0} : rfm_data_decoded_next = r21_rfshctl3; // 21 
         {1045'b0,1'b1,22'b0} : rfm_data_decoded_next = r22_rfshtmg; // 22 
         {1023'b0,1'b1,44'b0} : rfm_data_decoded_next = r44_crcparctl0; // 44 
         {1022'b0,1'b1,45'b0} : rfm_data_decoded_next = r45_crcparctl1; // 45 
         {1020'b0,1'b1,47'b0} : rfm_data_decoded_next = r47_crcparstat; // 47 
         {1019'b0,1'b1,48'b0} : rfm_data_decoded_next = r48_init0; // 48 
         {1018'b0,1'b1,49'b0} : rfm_data_decoded_next = r49_init1; // 49 
         {1016'b0,1'b1,51'b0} : rfm_data_decoded_next = r51_init3; // 51 
         {1015'b0,1'b1,52'b0} : rfm_data_decoded_next = r52_init4; // 52 
         {1014'b0,1'b1,53'b0} : rfm_data_decoded_next = r53_init5; // 53 
         {1013'b0,1'b1,54'b0} : rfm_data_decoded_next = r54_init6; // 54 
         {1012'b0,1'b1,55'b0} : rfm_data_decoded_next = r55_init7; // 55 
         {1011'b0,1'b1,56'b0} : rfm_data_decoded_next = r56_dimmctl; // 56 
         {1010'b0,1'b1,57'b0} : rfm_data_decoded_next = r57_rankctl; // 57 
         {1008'b0,1'b1,59'b0} : rfm_data_decoded_next = r59_dramtmg0; // 59 
         {1007'b0,1'b1,60'b0} : rfm_data_decoded_next = r60_dramtmg1; // 60 
         {1006'b0,1'b1,61'b0} : rfm_data_decoded_next = r61_dramtmg2; // 61 
         {1005'b0,1'b1,62'b0} : rfm_data_decoded_next = r62_dramtmg3; // 62 
         {1004'b0,1'b1,63'b0} : rfm_data_decoded_next = r63_dramtmg4; // 63 
         {1003'b0,1'b1,64'b0} : rfm_data_decoded_next = r64_dramtmg5; // 64 
         {1000'b0,1'b1,67'b0} : rfm_data_decoded_next = r67_dramtmg8; // 67 
         {999'b0,1'b1,68'b0} : rfm_data_decoded_next = r68_dramtmg9; // 68 
         {998'b0,1'b1,69'b0} : rfm_data_decoded_next = r69_dramtmg10; // 69 
         {997'b0,1'b1,70'b0} : rfm_data_decoded_next = r70_dramtmg11; // 70 
         {996'b0,1'b1,71'b0} : rfm_data_decoded_next = r71_dramtmg12; // 71 
         {993'b0,1'b1,74'b0} : rfm_data_decoded_next = r74_dramtmg15; // 74 
         {985'b0,1'b1,82'b0} : rfm_data_decoded_next = r82_zqctl0; // 82 
         {984'b0,1'b1,83'b0} : rfm_data_decoded_next = r83_zqctl1; // 83 
         {981'b0,1'b1,86'b0} : rfm_data_decoded_next = r86_dfitmg0; // 86 
         {980'b0,1'b1,87'b0} : rfm_data_decoded_next = r87_dfitmg1; // 87 
         {979'b0,1'b1,88'b0} : rfm_data_decoded_next = r88_dfilpcfg0; // 88 
         {978'b0,1'b1,89'b0} : rfm_data_decoded_next = r89_dfilpcfg1; // 89 
         {977'b0,1'b1,90'b0} : rfm_data_decoded_next = r90_dfiupd0; // 90 
         {976'b0,1'b1,91'b0} : rfm_data_decoded_next = r91_dfiupd1; // 91 
         {975'b0,1'b1,92'b0} : rfm_data_decoded_next = r92_dfiupd2; // 92 
         {973'b0,1'b1,94'b0} : rfm_data_decoded_next = r94_dfimisc; // 94 
         {971'b0,1'b1,96'b0} : rfm_data_decoded_next = r96_dfitmg3; // 96 
         {970'b0,1'b1,97'b0} : rfm_data_decoded_next = r97_dfistat ; // 97 
         {969'b0,1'b1,98'b0} : rfm_data_decoded_next = r98_dbictl; // 98 
         {968'b0,1'b1,99'b0} : rfm_data_decoded_next = r99_dfiphymstr; // 99 
         {967'b0,1'b1,100'b0} : rfm_data_decoded_next = r100_addrmap0; // 100 
         {966'b0,1'b1,101'b0} : rfm_data_decoded_next = r101_addrmap1; // 101 
         {965'b0,1'b1,102'b0} : rfm_data_decoded_next = r102_addrmap2; // 102 
         {964'b0,1'b1,103'b0} : rfm_data_decoded_next = r103_addrmap3; // 103 
         {963'b0,1'b1,104'b0} : rfm_data_decoded_next = r104_addrmap4; // 104 
         {962'b0,1'b1,105'b0} : rfm_data_decoded_next = r105_addrmap5; // 105 
         {961'b0,1'b1,106'b0} : rfm_data_decoded_next = r106_addrmap6; // 106 
         {960'b0,1'b1,107'b0} : rfm_data_decoded_next = r107_addrmap7; // 107 
         {959'b0,1'b1,108'b0} : rfm_data_decoded_next = r108_addrmap8; // 108 
         {958'b0,1'b1,109'b0} : rfm_data_decoded_next = r109_addrmap9; // 109 
         {957'b0,1'b1,110'b0} : rfm_data_decoded_next = r110_addrmap10; // 110 
         {956'b0,1'b1,111'b0} : rfm_data_decoded_next = r111_addrmap11; // 111 
         {954'b0,1'b1,113'b0} : rfm_data_decoded_next = r113_odtcfg; // 113 
         {953'b0,1'b1,114'b0} : rfm_data_decoded_next = r114_odtmap; // 114 
         {952'b0,1'b1,115'b0} : rfm_data_decoded_next = r115_sched; // 115 
         {951'b0,1'b1,116'b0} : rfm_data_decoded_next = r116_sched1; // 116 
         {949'b0,1'b1,118'b0} : rfm_data_decoded_next = r118_perfhpr1; // 118 
         {948'b0,1'b1,119'b0} : rfm_data_decoded_next = r119_perflpr1; // 119 
         {947'b0,1'b1,120'b0} : rfm_data_decoded_next = r120_perfwr1; // 120 
         {922'b0,1'b1,145'b0} : rfm_data_decoded_next = r145_dbg0; // 145 
         {921'b0,1'b1,146'b0} : rfm_data_decoded_next = r146_dbg1; // 146 
         {920'b0,1'b1,147'b0} : rfm_data_decoded_next = r147_dbgcam ; // 147 
         {919'b0,1'b1,148'b0} : rfm_data_decoded_next = r148_dbgcmd; // 148 
         {918'b0,1'b1,149'b0} : rfm_data_decoded_next = r149_dbgstat ; // 149 
         {916'b0,1'b1,151'b0} : rfm_data_decoded_next = r151_swctl; // 151 
         {915'b0,1'b1,152'b0} : rfm_data_decoded_next = r152_swstat ; // 152 
         {914'b0,1'b1,153'b0} : rfm_data_decoded_next = r153_swctlstatic; // 153 
         {898'b0,1'b1,169'b0} : rfm_data_decoded_next = r169_poisoncfg; // 169 
         {897'b0,1'b1,170'b0} : rfm_data_decoded_next = r170_poisonstat ; // 170 
         {874'b0,1'b1,193'b0} : rfm_data_decoded_next = r193_pstat ; // 193 
         {873'b0,1'b1,194'b0} : rfm_data_decoded_next = r194_pccfg; // 194 
         {872'b0,1'b1,195'b0} : rfm_data_decoded_next = r195_pcfgr_0; // 195 
         {871'b0,1'b1,196'b0} : rfm_data_decoded_next = r196_pcfgw_0; // 196 
         {837'b0,1'b1,230'b0} : rfm_data_decoded_next = r230_pctrl_0; // 230 
         {836'b0,1'b1,231'b0} : rfm_data_decoded_next = r231_pcfgqos0_0; // 231 
         {835'b0,1'b1,232'b0} : rfm_data_decoded_next = r232_pcfgqos1_0; // 232 
         {834'b0,1'b1,233'b0} : rfm_data_decoded_next = r233_pcfgwqos0_0; // 233 
         {833'b0,1'b1,234'b0} : rfm_data_decoded_next = r234_pcfgwqos1_0; // 234 
         {211'b0,1'b1,856'b0} : rfm_data_decoded_next = r856_umctl2_ver_number ; // 856 
         {210'b0,1'b1,857'b0} : rfm_data_decoded_next = r857_umctl2_ver_type ; // 857 

        default : rfm_data_decoded_next = rfm_data_decoded;
      endcase 
   end

   assign prdata[APB_DW-1:0] = rfm_data_decoded[REG_WIDTH-1:0];
    

   // pslverr set when address out of range in sync with pready
   always @ (posedge pclk or negedge presetn) begin : sample_pclk_err_PROC
      if (~presetn) begin
         addr_out_of_range <= 1'b0;
         pslverr   <= 1'b0;
      end else begin
         if(apb_slv_ns==IDLE) begin
            addr_out_of_range <= 1'b0;
         end else if(apb_slv_ns==ADDRDECODE) begin
            if(~(|onehotsel)) begin
               addr_out_of_range <= 1'b1;
            end
         end         
         pslverr <= (addr_out_of_range && apb_slv_ns==SAMPLERDY) ? 1'b1 : 1'b0;
      end 
   end

endmodule
