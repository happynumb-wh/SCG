/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Assertion file for DDR3 Write Leveling Command and FSM state  *
 *              checker                                                       *
 *                                                                            *
 *****************************************************************************/
/******************************************************************************
 *
 * DESCRIPTION: There are several external binding of modules within this file.
 *              - to invoke, compile with -sva switch on runtc  (+define+SVA)
 * 
 * 
 *              Module                 
 *              - sva_wl_ctl.v            sva module for top level Write Leveling control
 *              - sva_dx_lcdl_ctl_wl.v    sva module for DATX8 Level Write Leveling control
 * 
 *              These above modules are binded externally in order to allow the 
 *              separation of the verification IP with the DUT.
 *  
 * Module:  sva_wl_ctl.v
 *          -----------------------
 *              This module is a sva assertion module for DWC_ddrphyctl_wl_ctl.v
 * 
 *              Within DWC_ddrphyctl_wl_ctl.v  contains the following FSMs.
 *              - wl_cmd_state     is the FSM that send out Command thru the CMD/Address control
 *                                 bus to the SDRAMs.
 *
 *              - wl_fsm_state     is the Main FSM which controls the flow of write leveling by 
 *                                 issuing the command, setting the DX ready and pace the
 *                                 corresponding wait time.
 *
 * Module:  sva_dx_lcdl_ctl_wl.v  (not implemented yet)
 *          --------------------------------------------
 *              This module is a sva assertion module for DWC_ddrphyctl_dx_lcdl_ctl_wl.v 
 *              (per lane basis for each DATX8)
 * 
 *             Within each DATX8, DWC_ddrphyctl_dx_lcdl_ctl_wl.v contains the following FSMs.
 *             - wl_fsm_state      is the FSM which sets the timing for Sending DQS HIGH and then
 *                                 wait for the feedback results from SDRAMs' DQ bit(s)
 * 
 *             - wl_chk_state      is the FSM to set the wait time in between each compare
 *                                 
 * Limitations: 
 *
 *****************************************************************************/
`timescale 1 ps / 1 ps
`ifdef SVA

  `define PHYCTL_WL_CTL   `PHYCTL.u_DWC_ddrphyctl_wl_ctl


  `define BYTE_0_CTL_WL   `PHYCTL.dx_ctl[0].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `ifdef BYTE_LANE_1
    `define BYTE_1_CTL_WL   `PHYCTL.dx_ctl[1].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_2
    `define BYTE_2_CTL_WL   `PHYCTL.dx_ctl[2].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_3
    `define BYTE_3_CTL_WL   `PHYCTL.dx_ctl[3].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_4
    `define BYTE_4_CTL_WL   `PHYCTL.dx_ctl[4].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_5
    `define BYTE_5_CTL_WL   `PHYCTL.dx_ctl[5].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_6
    `define BYTE_6_CTL_WL   `PHYCTL.dx_ctl[6].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_7
    `define BYTE_7_CTL_WL   `PHYCTL.dx_ctl[7].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif
  `ifdef BYTE_LANE_8
    `define BYTE_8_CTL_WL   `PHYCTL.dx_ctl[8].u_DWC_ddrphyctl_dx_ctl.u_DWC_ddrphyctl_dx_lcdl_ctl_wl
  `endif


// VERBOSE level 
parameter  BASIC_MSG               = 3;
parameter  DETAIL_MSG              = 2;
parameter  DEBUG_MSG               = 1;
parameter  SHOW_ALL_MSG            = 0;


// Parameters from DWC_ddrphyctl
parameter  pDX8_NUM                = `DDR_BYTE_WIDTH;
parameter  pPGCR1_WLRANK_WIDTH     = 2;
parameter  pPTR2_TWLDLYS_WIDTH     = 5;
parameter  pMR1_WIDTH              = 16;
parameter  pTMRD_WIDTH             = 3;
parameter  pTMOD_WIDTH             = 4;
parameter  pTWLMRD_WIDTH           = 6;

parameter  pCFG_DATA_WIDTH         = 32;
parameter  pPIR_FDEPTH_WIDTH       = 2;
parameter  pPIR_DLDLMT_WIDTH       = 8;
parameter  pPTR2_TCALON_WIDTH      = 4;
parameter  pPTR2_TCALS_WIDTH       = 4;
parameter  pPTR2_TCALH_WIDTH       = 4;
parameter  pPTR2_TWLO_WIDTH        = 4;  
parameter  pPGCR1_WLEN_WIDTH       = 1;
parameter  pPGCR1_WLSTEP_WIDTH     = 1;
parameter  pPGCR1_WLSELT_WIDTH     = 1;
parameter  pWLRKEN_WIDTH           = 4;
parameter  pLCDL_DLY_WIDTH         = 8;
parameter  pWL_Q_WIDTH             = 8;

// From DWC_ddrphyctl_wl_ctl.v
// Write Leveling Main FSM
parameter  pWL_FSM_WIDTH       = 4;
parameter  sWL_FSM_IDLE        = 4'b0000;
parameter  sWL_FSM_INIT        = 4'b0001;
parameter  sWL_FSM_CMD_ENTRY   = 4'b0010;
parameter  sWL_FSM_MODE        = 4'b0011;
parameter  sWL_FSM_DX_START    = 4'b0100;
parameter  sWL_FSM_ODT_OFF     = 4'b0101;
parameter  sWL_FSM_WAIT_1      = 4'b0110;
parameter  sWL_FSM_CMD_EXIT    = 4'b0111;
parameter  sWL_FSM_NEXT_RANK   = 4'b1000;
parameter  sWL_FSM_WAIT_2      = 4'b1001;
parameter  sWL_FSM_CLR_WLEN    = 4'b1010;
parameter  sWL_FSM_DONE        = 4'b1011;

// From DWC_ddrphyctl_wl_ctl.v
// Write Leveling Command FSM
parameter  pWL_CMD_FSM_WIDTH    = 4;
parameter  sWL_CMD_IDLE         = 4'b0000; 
parameter  sWL_CMD_MRS_WL_ON    = 4'b0001; 
parameter  sWL_CMD_MRS_RANK_EN  = 4'b0010; 
parameter  sWL_CMD_ODT_ON       = 4'b0011; 
parameter  sWL_CMD_ODT_OFF      = 4'b0100; 
parameter  sWL_CMD_MRS_RANK_DIS = 4'b0101; 
parameter  sWL_CMD_MRS_WL_OFF   = 4'b0110; 
parameter  sWL_CMD_MRS_Q_OFF    = 4'b0111; 
parameter  sWL_CMD_DONE         = 4'b1000; 

// From DWC_ddrphyctl_dx_lcdl_ctl_wl.v
// Write Leveling FSM parameters 
parameter  sDX_WL_IDLE          = 4'b0000;
parameter  sDX_WL_FSM_DQS_HIGH  = 4'b0001;
parameter  sDX_WL_FSM_WAIT_RSLT = 4'b0010;
parameter  sDX_WL_FSM_CHK_RSLT  = 4'b0100;
parameter  sDX_WL_DONE          = 4'b1000;
parameter  pDX_WL_DQS_BIT  = 0;
parameter  pDX_WL_WAIT_BIT = 1;
parameter  pDX_WL_CHK_BIT  = 2;
parameter  pDX_WL_DONE_BIT = 3;

// From DWC_ddrphyctl_dx_lcdl_ctl_wl.v
// Write Leveling Check result FSM
parameter  pWL_CHK_STATE_WIDTH = 3;
parameter  sWL_CHK_IDLE        = 3'b000;
parameter  sWL_CHK_NEXT_DLY    = 3'b001;
parameter  sWL_CHK_WAIT0       = 3'b010;
parameter  sWL_CHK_WAIT1       = 3'b011;
parameter  sWL_CHK_DONE        = 3'b100;  

parameter  p_sva_tMRD          = 4;    // MAX value estimate for tMRD (from speed grade)
parameter  p_sva_tMOD          = 20;   // MAX value estimate for tMOD
parameter  p_sva_tWLMRD        = 40;   // MAX value estimate for tWLMRD
parameter  p_sva_tMAX          = 100;   // MAX value estimate for most states


// SVA module
module  sva_wl_ctl (
                    input                               ctl_clk,
                    input                               i_ctl_rst_n,
                    input                               cfg_clk,
                    input                               i_init_rst_n,
                    input                               i_cfg_wlen,
                    input                               i_cfg_wlfull,
                    input  [pPGCR1_WLRANK_WIDTH   -1:0] i_cfg_wlrank,
                    input  [pDX8_NUM              -1:0] i_cfg_dxngcr_dx8en,
                    input  [pPTR2_TWLDLYS_WIDTH   -1:0] i_cfg_twldlys,
                    input                               o_cfg_wldone,
                    input                               o_clr_cfg_pgcr1_wlen,
                    input                               o_wl_mode,
                    input                               o_wl_init,
                    input  [pPGCR1_WLRANK_WIDTH   -1:0] o_wl_rank,
                    input  [pDX8_NUM              -1:0] o_wl_dx_start,
                    input  [pDX8_NUM              -1:0] i_wl_dx_done,
                    input  [pMR1_WIDTH            -1:0] i_mr1,
                    input                               i_sdr_mode,
                    input  [pTMRD_WIDTH           -1:0] i_t_mrd,
                    input  [pTMOD_WIDTH           -1:0] i_t_mod,
                    input  [pTWLMRD_WIDTH         -1:0] i_t_wlmrd,
                    input  [3:0]                        o_ctl_odt,
                    input  [3:0]                        o_ctl_cs_n,
                    input                               o_ctl_ras_n,
                    input                               o_ctl_cas_n,
                    input                               o_ctl_we_n,
                    input  [2:0]                        o_ctl_ba,
                    input  [15:0]                       o_ctl_a
                    );

  integer                                               verbose; initial verbose = 1;
  reg                                                   wl_in_progress;
  
  //
  // property definitions
  //

  // All Available state in wl_fsm_state
  //
  sequence s_WL_CTL_FSM_IDLE;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_IDLE);
  endsequence

    sequence s_WL_CTL_FSM_INIT;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_INIT);
  endsequence

    sequence s_WL_CTL_FSM_CMD_ENTRY;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_CMD_ENTRY);
  endsequence

    sequence s_WL_CTL_FSM_MODE;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_MODE);
  endsequence

    sequence s_WL_CTL_FSM_DX_START;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_DX_START);
  endsequence

    sequence s_WL_CTL_FSM_ODT_OFF;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_ODT_OFF);
  endsequence

    sequence s_WL_CTL_FSM_WAIT_1;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_WAIT_1);
  endsequence

    sequence s_WL_CTL_FSM_CMD_EXIT;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_CMD_EXIT);
  endsequence

    sequence s_WL_CTL_FSM_NEXT_RANK;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_NEXT_RANK);
  endsequence

    sequence s_WL_CTL_FSM_WAIT_2;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_WAIT_2);
  endsequence

    sequence s_WL_CTL_FSM_CLR_WLEN;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_CLR_WLEN);
  endsequence

    sequence s_WL_CTL_FSM_DONE;
  (`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_DONE);
  endsequence

    sequence s_WL_CTL_FSM_UNDEFINED_STATE;
  ((`PHYCTL_WL_CTL.wl_fsm_state == 4'b1100) || (`PHYCTL_WL_CTL.wl_fsm_state == 4'b1101) ||
   (`PHYCTL_WL_CTL.wl_fsm_state == 4'b1110) || (`PHYCTL_WL_CTL.wl_fsm_state == 4'b1111)   );
  endsequence

    // All available state in wl_cmd_state
    //
    sequence s_WL_CTL_CMD_IDLE;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_IDLE);
  endsequence

    sequence s_WL_CTL_CMD_MRS_WL_ON;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_WL_ON);
  endsequence
    
    sequence s_WL_CTL_CMD_MRS_RANK_EN;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_EN);
  endsequence

    sequence s_WL_CTL_CMD_ODT_ON;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_ODT_ON);
  endsequence
    
    sequence s_WL_CTL_CMD_ODT_OFF;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_ODT_OFF);
  endsequence

    sequence s_WL_CTL_CMD_MRS_RANK_DIS;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_DIS);
  endsequence
    
    sequence s_WL_CTL_CMD_MRS_WL_OFF;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_WL_OFF);
  endsequence

    sequence s_WL_CTL_CMD_MRS_Q_OFF;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_Q_OFF);
  endsequence
    
    sequence s_WL_CTL_CMD_DONE;
  (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_DONE);
  endsequence

    sequence s_WL_CTL_CMD_UNDEFINED_STATE;
  ((`PHYCTL_WL_CTL.wl_cmd_state == 4'b1001) || (`PHYCTL_WL_CTL.wl_cmd_state == 4'b1010) ||
   (`PHYCTL_WL_CTL.wl_cmd_state == 4'b1011) || (`PHYCTL_WL_CTL.wl_cmd_state == 4'b1100) ||
   (`PHYCTL_WL_CTL.wl_cmd_state == 4'b1101) || (`PHYCTL_WL_CTL.wl_cmd_state == 4'b1110) ||
   (`PHYCTL_WL_CTL.wl_cmd_state == 4'b1111) );
  endsequence
    
    //
    // Property for wl_fsm_state
    //
    // When Reset is asserted, wl_fsm_state should go back to IDLE state   
    property p_RESET_WL_FSM_IDLE;
  @(posedge `PHYCTL_WL_CTL.cfg_clk)  (`PHYCTL_WL_CTL.i_init_rst_n == 1'b0) |=>  s_WL_CTL_FSM_IDLE;
  endproperty

    // When Reset is deasserted, wl_fsm_state should not be in UNDEFINED states
    property p_WL_FSM_NOT_UNDEFINED_STATE;
  @(posedge `PHYCTL_WL_CTL.cfg_clk)  disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (`PHYCTL_WL_CTL.i_init_rst_n == 1'b1) |=>  not s_WL_CTL_FSM_UNDEFINED_STATE;
  endproperty
    
    // WL FSM: wl_start_trigger takes IDLE to INIT
    property p_WL_FSM_IDLE_TO_INIT;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(i_cfg_wlen) and s_WL_CTL_FSM_IDLE) |=> ##[1:2] s_WL_CTL_FSM_INIT ##1 (o_wl_init == 1'b1);
  endproperty

    // WL FSM: full option takes INIT to CMD_ENTRY and then wl_cmd_fsm should go to MRS_WL_ON state
    property p_WL_FSM_INIT_TO_CMD_ENTRY;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ((`PHYCTL_WL_CTL.cfg_wlfull == 1'b1) and s_WL_CTL_FSM_INIT) |=> s_WL_CTL_FSM_CMD_ENTRY
                                 ##1     @(posedge ctl_clk) s_WL_CTL_CMD_IDLE
                                 ##2     @(posedge ctl_clk) (`PHYCTL_WL_CTL.trigger_wl_cmd_fsm == 1'b1)
                                   ##1     @(posedge ctl_clk) s_WL_CTL_CMD_MRS_WL_ON;
  endproperty

    // WL FSM: NOT full option takes INIT to MODE and then wl_mode to DWC_DDRPHY
    property p_WL_FSM_INIT_TO_MODE;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ((`PHYCTL_WL_CTL.cfg_wlfull == 1'b0) and s_WL_CTL_FSM_INIT) |=> s_WL_CTL_FSM_MODE ##1 (o_wl_mode == 1'b1);
  endproperty
    
    // WL FSM: when in CMD_ENTRY, ctl_wl_cmd_en should be enable and
    // WL CMD: should go thru sWL_CMD_MRS_WL_ON, sWL_CMD_MRS_RANK_EN, sWL_CMD_ODT_ON then sWL_CMD_DONE states
    property p_WL_FSM_CMD_ENTRY;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ((`PHYCTL_WL_CTL.cfg_wlfull == 1'b1) and $rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_CMD_ENTRY)) |=> 
                                 @(posedge ctl_clk) s_WL_CTL_CMD_IDLE       // 2 clock to sync + 1 clock to change from IDLE
                                 ##3                @(posedge ctl_clk) s_WL_CTL_CMD_MRS_WL_ON  // 1 to 4 max tMRD value
                                 ##[1:p_sva_tMRD]   @(posedge ctl_clk) s_WL_CTL_CMD_MRS_RANK_EN  // 1 to 20 (temporary set max tMOD) 
                                 ##[1:p_sva_tMOD]   @(posedge ctl_clk) s_WL_CTL_CMD_ODT_ON    // 1 to 40 (temporary set max tWLMRD)
                                 ##[1:p_sva_tWLMRD] @(posedge ctl_clk) s_WL_CTL_CMD_DONE;
  endproperty

    // WL FSM: when in CMD_EXIT, ctl_wl_cmd_en should be enable and
    // WL CMD: should go thru sWL_CMD_MRS_WL_ON, sWL_CMD_MRS_RANK_EN, sWL_CMD_ODT_ON then sWL_CMD_DONE states
    property p_WL_FSM_CMD_EXIT;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ((`PHYCTL_WL_CTL.cfg_wlfull == 1'b1) and $rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_CMD_EXIT)) |=> 
                                 @(posedge ctl_clk) s_WL_CTL_CMD_IDLE       // 2 clock to sync + 1 clock to change from IDLE
                                 ##3              @(posedge ctl_clk) s_WL_CTL_CMD_ODT_OFF    // 1 to RANK DIS
                                 ##1              @(posedge ctl_clk) s_WL_CTL_CMD_MRS_RANK_DIS    // 1 to 4 max tMRD value
                                 ##[1:p_sva_tMRD] @(posedge ctl_clk) s_WL_CTL_CMD_MRS_WL_OFF // 1 to 4 max tMRD value
                                 ##[1:p_sva_tMRD] @(posedge ctl_clk) s_WL_CTL_CMD_MRS_Q_OFF  // 1 to 4 max tMRD value
                                 ##[1:p_sva_tMRD] @(posedge ctl_clk) s_WL_CTL_CMD_DONE;
  
  endproperty

    // WL FSM: When in ODT_OFF (only when cfg_wlfull), should send wl_cmd_state to trigger from IDLE to ODT_OFF and then DONE
    property p_WL_FSM_ODT_OFF;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_ODT_OFF)) |-> (`PHYCTL_WL_CTL.cfg_wlfull == 1'b1)
      ##1              @(posedge ctl_clk) s_WL_CTL_CMD_IDLE       // 2 clock to sync + 1 clock to change from IDLE
                                        ##3              @(posedge ctl_clk) s_WL_CTL_CMD_ODT_OFF    // 1 to 3 RANK DIS
                                        ##1              @(posedge ctl_clk) s_WL_CTL_CMD_DONE;      // 1 clock to DONE
  
  endproperty

    
    // When wl_init is triggered, wl_rank will start from 0, and followed by asserting of wl_mode and then wl_dx_start
    // dx will carry on the WL procedure, and when received feedback from
    // the SDRAM will signal wl_dx_done. This signal is "ORED" with ~cfg_dxngcr_dx8en
    // to form the wl_all_dx_done signal. wl_fsm_state will eventaully go to the NEXT_RANK and wl_rank
    // will increment if last_rank has not been reached. wl_start and wl_mode will be setup again for WL for the
    // next rank until wl_rank = cfg_wlrank. wl_done will be set when sWL_FSM_DONE is reached.
    always @(posedge cfg_clk) begin
      if (`PHYCTL_WL_CTL.i_init_rst_n) begin
        // Start of WL process
        a_WL_START_FROM_RANK_0:
          assert property ((`PHYCTL_WL_CTL.wl_init == 1'b1) |=> ##1 (o_wl_rank == 2'b00))
            else `SVA_ERR("PHYCTL WL RANK did not start from RANK 0");
        wl_in_progress = 1'b1;
      end
    end
  
  always @(posedge cfg_clk) begin
    if (`PHYCTL_WL_CTL.i_init_rst_n) begin
      if (`PHYCTL_WL_CTL.wl_done == 1'b1) begin
        wl_in_progress = 1'b0;
      end
    end
  end
  
  // Wait for sWL_FSM_MODE, wl_mode should be set
  property p_WL_MODE_AT_RANK_0;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_MODE) and wl_in_progress) ##1 (o_wl_rank==2'b00))     |=> (o_wl_mode == 1'b1) and (o_wl_rank==2'b00);
  endproperty

    // wait for sWL_FSM_DX_START, wl_dx_start should be set 
    property p_WL_DX_START_FROM_RANK_0;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_DX_START) and (o_wl_rank==2'b00) 
     and wl_in_progress and (|(`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)))   |=> (o_wl_dx_start == (`PHYCTL_WL_CTL.cfg_dxngcr_dx8en & {(`NO_OF_BYTES){1'b1}}) );
  endproperty

    // wait for feedback from SDRAM RANK 0, wl_mode and wl_dx_start should be deassserted                           
    property p_WL_DX_DONE_FOR_RANK_0;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (s_WL_CTL_FSM_DX_START and (&(`PHYCTL_WL_CTL.wl_dx_done | ~`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)) and (o_wl_rank==2'b00) and wl_in_progress) |=> 
                                                                                                                ##1 (( o_wl_mode == 1'b0) and (o_wl_dx_start == {(`NO_OF_BYTES){1'b0}}));
  endproperty

  `ifdef MSD_RANK_1                           
    // if rank 1 exist, then wl_fsm_state will go to sWL_FSM_NEXT_RANK where wl_rank will be increment
    property p_WL_NEXT_RANK_1;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_NEXT_RANK) and (o_wl_rank==2'b00) and wl_in_progress) |=> (o_wl_rank == 2'b01);
  endproperty

    property p_WL_MODE_AT_RANK_1;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_MODE) and wl_in_progress) ##1 (o_wl_rank==2'b01))     |=> (o_wl_mode == 1'b1) and (o_wl_rank==2'b01);
  endproperty

    // wait for sWL_FSM_DX_START, wl_dx_start should be set 
    property p_WL_DX_START_FROM_RANK_1;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_DX_START) and (o_wl_rank==2'b01) 
     and wl_in_progress and (|(`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)))   |=> (o_wl_dx_start == (`PHYCTL_WL_CTL.cfg_dxngcr_dx8en & {(`NO_OF_BYTES){1'b1}}) );
  endproperty

    // wait for feedback from SDRAM RANK 0, wl_mode and wl_dx_start should be deassserted                           
    property p_WL_DX_DONE_FOR_RANK_1;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (s_WL_CTL_FSM_DX_START and (&(`PHYCTL_WL_CTL.wl_dx_done | ~`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)) and (o_wl_rank==2'b01) and wl_in_progress) |=> 
                                                                                                                ##1 (( o_wl_mode == 1'b0) and (o_wl_dx_start == {(`NO_OF_BYTES){1'b0}}));
  endproperty
  `endif

  `ifdef MSD_RANK_2                           
    // if rank 1 exist, then wl_fsm_state will go to sWL_FSM_NEXT_RANK where wl_rank will be increment
    property p_WL_NEXT_RANK_2;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_NEXT_RANK) and (o_wl_rank==2'b01) and wl_in_progress) |=> (o_wl_rank == 2'b10);
  endproperty

    property p_WL_MODE_AT_RANK_2;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_MODE) and wl_in_progress) ##1 (o_wl_rank==2'b10))     |=> (o_wl_mode == 1'b1) and (o_wl_rank==2'b10);
  endproperty

    // wait for sWL_FSM_DX_START, wl_dx_start should be set 
    property p_WL_DX_START_FROM_RANK_2;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_DX_START) and (o_wl_rank==2'b10)
     and wl_in_progress and (|(`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)))   |=> (o_wl_dx_start == (`PHYCTL_WL_CTL.cfg_dxngcr_dx8en & {(`NO_OF_BYTES){1'b1}}) );
  endproperty

    // wait for feedback from SDRAM RANK 0, wl_mode and wl_dx_start should be deassserted                           
    property p_WL_DX_DONE_FOR_RANK_2;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (s_WL_CTL_FSM_DX_START and (&(`PHYCTL_WL_CTL.wl_dx_done | ~`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)) and (o_wl_rank==2'b10) and wl_in_progress) |=> 
                                                                                                                ##1 (( o_wl_mode == 1'b0) and (o_wl_dx_start == {(`NO_OF_BYTES){1'b0}}));
  endproperty
  `endif

  `ifdef MSD_RANK_3                           
    // if rank 1 exist, then wl_fsm_state will go to sWL_FSM_NEXT_RANK where wl_rank will be increment
    property p_WL_NEXT_RANK_3;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_NEXT_RANK) and (o_wl_rank==2'b10) and wl_in_progress) |=> (o_wl_rank == 2'b11);
  endproperty

    property p_WL_MODE_AT_RANK_3;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_MODE) and wl_in_progress) ##1 (o_wl_rank==2'b11))     |=> (o_wl_mode == 1'b1) and (o_wl_rank==2'b11);
  endproperty

    // wait for sWL_FSM_DX_START, wl_dx_start should be set 
    property p_WL_DX_START_FROM_RANK_3;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_DX_START) and (o_wl_rank==2'b11)
     and wl_in_progress and (|(`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)))   |=> (o_wl_dx_start == (`PHYCTL_WL_CTL.cfg_dxngcr_dx8en & {(`NO_OF_BYTES){1'b1}}) );
  endproperty

    // wait for feedback from SDRAM RANK 0, wl_mode and wl_dx_start should be deassserted                           
    property p_WL_DX_DONE_FOR_RANK_3;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    (s_WL_CTL_FSM_DX_START and (&(`PHYCTL_WL_CTL.wl_dx_done | ~`PHYCTL_WL_CTL.cfg_dxngcr_dx8en)) and (o_wl_rank==2'b11) and wl_in_progress) |=> 
                                                                                                                ##1 (( o_wl_mode == 1'b0) and (o_wl_dx_start == {(`NO_OF_BYTES){1'b0}}));
  endproperty
  `endif

    // wl_fsm_state will get to CLR_WLEN and DONE state and will assert clr_cfg_pgcr1_wlen and o_cfg_wldone signal respectively 
    property p_WL_DONE_ALL_RANKS;
  @(posedge `PHYCTL_WL_CTL.cfg_clk) disable iff (! `PHYCTL_WL_CTL.i_init_rst_n)
    ($rose(`PHYCTL_WL_CTL.wl_fsm_state == sWL_FSM_CLR_WLEN) and wl_in_progress) |-> (o_clr_cfg_pgcr1_wlen == 1'b1)
      ##1 s_WL_CTL_FSM_DONE
                                        ##1 (o_cfg_wldone == 1'b1);
  endproperty


    //
    // Property for wl_cmd_state
    //
    // When Reset is asserted or ctl_wlen is disabled, wl_cmd_state should go back to IDLE state   
    property p_RESET_WL_CMD_IDLE;
  @(posedge `PHYCTL_WL_CTL.ctl_clk)  (`PHYCTL_WL_CTL.ctl_rst_n == 1'b0) |=>  s_WL_CTL_CMD_IDLE;
  endproperty

    property p_CTL_WLEN_DISABLED_WL_CMD_IDLE;
  @(posedge `PHYCTL_WL_CTL.ctl_clk)  disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    (`PHYCTL_WL_CTL.ctl_wlen == 1'b0)  |=>  s_WL_CTL_CMD_IDLE;
  endproperty
    
    // When Reset is deasserted, wl_fsm_state should not be in UNDEFINED states
    property p_WL_CMD_NOT_UNDEFINED_STATE;
  @(posedge `PHYCTL_WL_CTL.ctl_clk)  disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    (`PHYCTL_WL_CTL.ctl_rst_n == 1'b1) |=>  not s_WL_CTL_CMD_UNDEFINED_STATE;
  endproperty

    // WL_ENABLE state in the WL flow  
    // WL CMD: When in MRS_ON state load MR1[12]==1  MR1[7]==1
    property p_WL_CMD_MRS_ON;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_WL_ON)   |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b0000) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b1) and (`TB.a[7] == 1'b1) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    // WL RANK ENABLE state in the WL flow
    // WL CMD: When in MRS_RANK_EN state  load MR1[12]==0  MR1[7]==1
    property p_WL_CMD_MRS_RANK_0_EN;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_EN) and (o_wl_rank==2'b00)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b1110) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b0) and (`TB.a[7] == 1'b1) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    property p_WL_CMD_MRS_RANK_1_EN;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_EN) and (o_wl_rank==2'b01)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b1101) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b0) and (`TB.a[7] == 1'b1) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    property p_WL_CMD_MRS_RANK_2_EN;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_EN) and (o_wl_rank==2'b10)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b1011) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b0) and (`TB.a[7] == 1'b1) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    
    
    property p_WL_CMD_MRS_RANK_3_EN;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_EN) and (o_wl_rank==2'b11)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b0111) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b0) and (`TB.a[7] == 1'b1) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    // ODT_HIGH and ODT_LOW state  
    property  p_WL_CMD_ODT_ON;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_ODT_ON)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) (`TB.odt ==  4'b1111);
  endproperty  
    
    property  p_WL_CMD_ODT_OFF;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_ODT_OFF)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) (`TB.odt ==  4'b0000);
  endproperty                               
    
    // WL RANK DISABLE state in the WL flow 
    // WL CMD: When in MRS_RANK_DIS state  load MR1[12]==1  MR1[7]==1 for all RANKS
    property p_WL_CMD_MRS_RANK_DIS;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_RANK_DIS)  |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b0000) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b1) and (`TB.a[7] == 1'b1) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    // WL DISABLE state in the WL flow
    // WL CMD: when in MRS_WL_OFF state load MR1[12]==1  MR1[7]==0 for all RANKS 
    property p_WL_CMD_MRS_WL_OFF;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_WL_OFF)   |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b0000) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b1) and (`TB.a[7] == 1'b0) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    // WL RANK DISABLE state in the WL flow
    // WL CMD: when in MRS_Q_OFF state load MR1[12]==0  MR1[7]==0 for all RANKS 
    property p_WL_CMD_MRS_Q_OFF;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_MRS_Q_OFF)   |=>  
                                        @(posedge `TB.ck[0]) `TRUE
                                        ##[1:10] @(posedge `TB.ck[0]) ((`TB.cs_n == 4'b0000) and (`TB.ras_n == 1'b0) and
                                                                       (`TB.cas_n == 1'b0) and (`TB.we_n == 1'b0) and
                                                                       (`TB.a[12] == 1'b0) and (`TB.a[7] == 1'b0) and 
                                                                       (`TB.ba == 3'b001)  and (`TB.odt ==  4'b0000) );
  endproperty    

    
    
    
    // WL CMD: when in CMD_DONE state and from wl_entry, it will take 2 clocks to sync back to cfg_clk for cfg_wl_cmd_fsm_done to be
    //         asserted
    property p_WL_CMD_DONE_WL_ENTRY;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_DONE) and (`PHYCTL_WL_CTL.cfg_wl_entry) |->  (`PHYCTL_WL_CTL.wl_cmd_fsm_done == 1'b1)
      ##1     @(posedge cfg_clk) `TRUE
                                        ##[1:2] @(posedge cfg_clk) (`PHYCTL_WL_CTL.cfg_wl_cmd_fsm_done == 1'b1)
                                          ##[0:1] @(posedge cfg_clk) s_WL_CTL_FSM_MODE;
  endproperty    
    
    // WL CMD: when in CMD_DONE state and from ODT OFF, it will take 2 clocks to sync back to cfg_clk for cfg_wl_cmd_fsm_done to be
    //         asserted
    property p_WL_CMD_DONE_WL_ODT_OFF;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_DONE) and (!`PHYCTL_WL_CTL.cfg_wl_entry) and (!`PHYCTL_WL_CTL.cfg_wl_exit) and 
                                        (`PHYCTL_WL_CTL.cfg_wl_odt_off)
      |->  (`PHYCTL_WL_CTL.wl_cmd_fsm_done == 1'b1)
        ##1     @(posedge cfg_clk) `TRUE
                                        ##[1:2] @(posedge cfg_clk) (`PHYCTL_WL_CTL.cfg_wl_cmd_fsm_done == 1'b1)
                                          ##[0:1] @(posedge cfg_clk) s_WL_CTL_FSM_WAIT_1; 
  endproperty    


    // WL CMD: when in CMD_DONE state and from wl_exit, it will take 2 clocks to sync back to cfg_clk for cfg_wl_cmd_fsm_done to be
    //         asserted
    property p_WL_CMD_DONE_WL_EXIT;
  @(posedge `PHYCTL_WL_CTL.ctl_clk) disable iff (! `PHYCTL_WL_CTL.i_ctl_rst_n)
    $rose (`PHYCTL_WL_CTL.wl_cmd_state == sWL_CMD_DONE) and (`PHYCTL_WL_CTL.cfg_wl_exit) |->  (`PHYCTL_WL_CTL.wl_cmd_fsm_done == 1'b1)
      ##1     @(posedge cfg_clk) `TRUE
                                        ##[1:2] @(posedge cfg_clk) (`PHYCTL_WL_CTL.cfg_wl_cmd_fsm_done == 1'b1)
                                          ##[0:1] @(posedge cfg_clk) s_WL_CTL_FSM_CLR_WLEN;
  endproperty    
    
    //     
    // assert statements  for wl_fsm_state
    //
    a_RESET_WL_FSM_IDLE:           assert property (p_RESET_WL_FSM_IDLE)
      else `SVA_ERR("PHYCTL WL FSM not IDLE when Reset active");

  a_WL_FSM_NOT_UNDEFINED_STATE:  assert property (p_WL_FSM_NOT_UNDEFINED_STATE)
    else `SVA_ERR("PHYCTL WL FSM in UNDEFINED STATE after Reset Deasserted");

  a_WL_FSM_IDLE_TO_INIT:         assert property (p_WL_FSM_IDLE_TO_INIT)
    else `SVA_ERR("PHYCTL WL FSM not going to INIT state after wl_start_trigger and IDLE state");
  
  a_WL_FSM_INIT_TO_CMD_ENTRY:    assert property (p_WL_FSM_INIT_TO_CMD_ENTRY)
    else `SVA_ERR("PHYCTL WL FSM not going to CMD ENTRY state when cfg_wlfull and INIT state");

  a_WL_FSM_INIT_TO_MODE:         assert property (p_WL_FSM_INIT_TO_MODE)
    else `SVA_ERR("PHYCTL WL FSM not going to MODE state when not cfg_wlfull and INIT state");

  a_WL_FSM_CMD_ENTRY:            assert property (p_WL_FSM_CMD_ENTRY)
    else `SVA_ERR("PHYCTL WL FSM and CMD not going thru all the CMD_ENTRY states expected");

  a_WL_FSM_CMD_EXIT:             assert property (p_WL_FSM_CMD_EXIT)
    else `SVA_ERR("PHYCTL WL FSM and CMD not going thru all the CMD_EXIT states expected");

  a_WL_FSM_ODT_OFF:              assert property (p_WL_FSM_ODT_OFF)
    else `SVA_ERR("PHYCTL WL FSM and CMD not going thru ODT_OFF state expected");
  
  a_WL_MODE_AT_RANK_0:           assert property (p_WL_MODE_AT_RANK_0)
    else `SVA_ERR("PHYCTL WL RANK 0 did not set wl_mode");

  a_WL_DX_START_FROM_RANK_0:     assert property (p_WL_DX_START_FROM_RANK_0)
    else `SVA_ERR("PHYCTL WL RANK 0 did not set wl_dx_start");

  a_WL_DX_DONE_FOR_RANK_0:       assert property (p_WL_DX_DONE_FOR_RANK_0)
    else `SVA_ERR("PHYCTL WL RANK 0 did not deassert wl_mode or wl_dx_start");

  `ifdef MSD_RANK_1                           
  a_WL_NEXT_RANK_1:              assert property (p_WL_NEXT_RANK_1)
    else `SVA_ERR("PHYCTL WL RANK did not increment to RANK 1");

  a_WL_MODE_AT_RANK_1:           assert property (p_WL_MODE_AT_RANK_1)
    else `SVA_ERR("PHYCTL WL RANK 1 did not set wl_mode");

  a_WL_DX_START_FROM_RANK_1:     assert property (p_WL_DX_START_FROM_RANK_1)
    else `SVA_ERR("PHYCTL WL RANK 1 did not set wl_dx_start");

  a_WL_DX_DONE_FOR_RANK_1:       assert property (p_WL_DX_DONE_FOR_RANK_1)
    else `SVA_ERR("PHYCTL WL RANK 1 did not deassert wl_mode or wl_dx_start");

  `endif
  

  `ifdef MSD_RANK_2                           
  a_WL_NEXT_RANK_2:              assert property (p_WL_NEXT_RANK_2)
    else `SVA_ERR("PHYCTL WL RANK did not increment to RANK 2");

  a_WL_MODE_AT_RANK_2:           assert property (p_WL_MODE_AT_RANK_2)
    else `SVA_ERR("PHYCTL WL RANK 2 did not set wl_mode");

  a_WL_DX_START_FROM_RANK_2:     assert property (p_WL_DX_START_FROM_RANK_2)
    else `SVA_ERR("PHYCTL WL RANK 2 did not set wl_dx_start");

  a_WL_DX_DONE_FOR_RANK_2:       assert property (p_WL_DX_DONE_FOR_RANK_2)
    else `SVA_ERR("PHYCTL WL RANK 2 did not deassert wl_mode or wl_dx_start");

  `endif
  
  `ifdef MSD_RANK_3                           
  a_WL_NEXT_RANK_3:              assert property (p_WL_NEXT_RANK_3)
    else `SVA_ERR("PHYCTL WL RANK did not increment to RANK 3");

  a_WL_MODE_AT_RANK_3:           assert property (p_WL_MODE_AT_RANK_3)
    else `SVA_ERR("PHYCTL WL RANK 3 did not set wl_mode");

  a_WL_DX_START_FROM_RANK_3:     assert property (p_WL_DX_START_FROM_RANK_3)
    else `SVA_ERR("PHYCTL WL RANK 3 did not set wl_dx_start");

  a_WL_DX_DONE_FOR_RANK_3:       assert property (p_WL_DX_DONE_FOR_RANK_3)
    else `SVA_ERR("PHYCTL WL RANK 3 did not deassert wl_mode or wl_dx_start");

  `endif
  
  a_WL_DONE_ALL_RANKS:           assert property (p_WL_DONE_ALL_RANKS)
    else `SVA_ERR("PHYCTL WL RANK did not clear cfg pgcr1 wlen and cfg wldone");




  //     
  // assert statements  for wl_cmd_state
  //
  a_RESET_WL_CMD_IDLE:           assert property (p_RESET_WL_CMD_IDLE)
    else `SVA_ERR("PHYCTL WL CMD not IDLE when Reset active");

  a_CTL_WLEN_DISABLED_WL_CMD_IDLE:  assert property (p_CTL_WLEN_DISABLED_WL_CMD_IDLE)
    else `SVA_ERR("PHYCTL WL CMD not IDLE when CTL WLEN disabled");

  a_WL_CMD_NOT_UNDEFINED_STATE:  assert property (p_WL_CMD_NOT_UNDEFINED_STATE)
    else `SVA_ERR("PHYCTL WL CMD in UNDEFINED STATE after Reset Deasserted");

  a_WL_CMD_MRS_ON:               assert property (p_WL_CMD_MRS_ON)
    else `SVA_ERR("PHYCTL WL CMD in MRS ON STATE but mismatch LOAD MODE Command ");

  a_WL_CMD_MRS_RANK_0_EN:        assert property (p_WL_CMD_MRS_RANK_0_EN)
    else `SVA_ERR("PHYCTL WL CMD in MRS RANK 0 ENABLE STATE but mismatch LOAD MODE Command ");
  
  a_WL_CMD_MRS_RANK_1_EN:        assert property (p_WL_CMD_MRS_RANK_1_EN)
    else `SVA_ERR("PHYCTL WL CMD in MRS RANK 1 ENABLE STATE but mismatch LOAD MODE Command ");
  
  a_WL_CMD_MRS_RANK_2_EN:        assert property (p_WL_CMD_MRS_RANK_2_EN)
    else `SVA_ERR("PHYCTL WL CMD in MRS RANK 2 ENABLE STATE but mismatch LOAD MODE Command ");
  
  a_WL_CMD_MRS_RANK_3_EN:        assert property (p_WL_CMD_MRS_RANK_3_EN)
    else `SVA_ERR("PHYCTL WL CMD in MRS RANK 3 ENABLE STATE but mismatch LOAD MODE Command ");

  a_WL_CMD_ODT_ON:               assert property (p_WL_CMD_ODT_ON)
    else `SVA_ERR("PHYCTL WL CMD in ODT ON STATE but mismatch ODT state ");

  a_WL_CMD_ODT_OFF:              assert property (p_WL_CMD_ODT_OFF)
    else `SVA_ERR("PHYCTL WL CMD in ODT OFF STATE but mismatch ODT state ");

  a_WL_CMD_MRS_RANK_DIS:         assert property (p_WL_CMD_MRS_RANK_DIS)
    else `SVA_ERR("PHYCTL WL CMD in MRS RANK DIS STATE but mismatch LOAD MODE Command ");

  a_WL_CMD_MRS_WL_OFF:           assert property (p_WL_CMD_MRS_WL_OFF)
    else `SVA_ERR("PHYCTL WL CMD in MRS WL OFF STATE but mismatch LOAD MODE Command ");

  a_WL_CMD_MRS_Q_OFF:            assert property (p_WL_CMD_MRS_Q_OFF)
    else `SVA_ERR("PHYCTL WL CMD in MRS Q OFF STATE but mismatch LOAD MODE Command ");
  
  
  a_WL_CMD_DONE_WL_ENTRY:        assert property (p_WL_CMD_DONE_WL_ENTRY)
    else `SVA_ERR("PHYCTL WL CMD DONE from WL ENTRY not triggering WL FSM MODE ");
  
  a_WL_CMD_DONE_WL_ODT_OFF:      assert property (p_WL_CMD_DONE_WL_ODT_OFF)
    else `SVA_ERR("PHYCTL WL CMD DONE from WL ODT OFF not triggering WL FSM WAIT 1 STATE ");
  
  a_WL_CMD_DONE_WL_EXIT:         assert property (p_WL_CMD_DONE_WL_EXIT)
    else `SVA_ERR("PHYCTL WL CMD DONE from WL ENTRY not triggering WL FSM CLR WLEN");
  
  //     
  // cover statements for wl_fsm_state
  //
  c_RESET_WL_FSM_IDLE:           cover property (p_RESET_WL_FSM_IDLE);

  c_WL_FSM_NOT_UNDEFINED_STATE:  cover property (p_WL_FSM_NOT_UNDEFINED_STATE);
  
  c_WL_FSM_IDLE_TO_INIT:         cover property (p_WL_FSM_IDLE_TO_INIT);

  c_WL_FSM_INIT_TO_CMD_ENTRY:    cover property (p_WL_FSM_INIT_TO_CMD_ENTRY);

  c_WL_FSM_INIT_TO_MODE:         cover property (p_WL_FSM_INIT_TO_MODE);
  
  c_WL_FSM_CMD_ENTRY:            cover property (p_WL_FSM_CMD_ENTRY);

  c_WL_FSM_CMD_EXIT:             cover property (p_WL_FSM_CMD_EXIT);
  
  c_WL_FSM_ODT_OFF:              cover property (p_WL_FSM_ODT_OFF);

  c_WL_MODE_AT_RANK_0:           cover property (p_WL_MODE_AT_RANK_0);

  c_WL_DX_START_FROM_RANK_0:     cover property (p_WL_DX_START_FROM_RANK_0);

  c_WL_DX_DONE_FOR_RANK_0:       cover property (p_WL_DX_DONE_FOR_RANK_0);

  `ifdef MSD_RANK_1                           
  c_WL_NEXT_RANK_1:              cover property (p_WL_NEXT_RANK_1);

  c_WL_MODE_AT_RANK_1:           cover property (p_WL_MODE_AT_RANK_1);

  c_WL_DX_START_FROM_RANK_1:     cover property (p_WL_DX_START_FROM_RANK_1);

  c_WL_DX_DONE_FOR_RANK_1:       cover property (p_WL_DX_DONE_FOR_RANK_1);

  `endif
  

  `ifdef MSD_RANK_2                           
  c_WL_NEXT_RANK_2:              cover property (p_WL_NEXT_RANK_2);

  c_WL_MODE_AT_RANK_2:           cover property (p_WL_MODE_AT_RANK_2);

  c_WL_DX_START_FROM_RANK_2:     cover property (p_WL_DX_START_FROM_RANK_2);

  c_WL_DX_DONE_FOR_RANK_2:       cover property (p_WL_DX_DONE_FOR_RANK_2);

  `endif
  
  `ifdef MSD_RANK_3                           
  c_WL_NEXT_RANK_3:              cover property (p_WL_NEXT_RANK_3);

  c_WL_MODE_AT_RANK_3:           cover property (p_WL_MODE_AT_RANK_3);

  c_WL_DX_START_FROM_RANK_3:     cover property (p_WL_DX_START_FROM_RANK_3);

  c_WL_DX_DONE_FOR_RANK_3:       cover property (p_WL_DX_DONE_FOR_RANK_3);

  `endif
  
  c_WL_DONE_ALL_RANKS:           cover property (p_WL_DONE_ALL_RANKS);

  
  //     
  // cover statements for wl_cmd_state
  //
  c_RESET_WL_CMD_IDLE:           cover property (p_RESET_WL_CMD_IDLE);
  
  c_CTL_WLEN_DISABLED_WL_CMD_IDLE: cover property (p_CTL_WLEN_DISABLED_WL_CMD_IDLE);

  c_WL_CMD_NOT_UNDEFINED_STATE:  cover property (p_WL_CMD_NOT_UNDEFINED_STATE);

  c_WL_CMD_MRS_ON:               cover property (p_WL_CMD_MRS_ON);

  c_WL_CMD_MRS_RANK_0_EN:        cover property (p_WL_CMD_MRS_RANK_0_EN);
  
  c_WL_CMD_MRS_RANK_1_EN:        cover property (p_WL_CMD_MRS_RANK_1_EN);
  
  c_WL_CMD_MRS_RANK_2_EN:        cover property (p_WL_CMD_MRS_RANK_2_EN);
  
  c_WL_CMD_MRS_RANK_3_EN:        cover property (p_WL_CMD_MRS_RANK_3_EN);

  c_WL_CMD_ODT_ON:               cover property (p_WL_CMD_ODT_ON);
  
  c_WL_CMD_ODT_OFF:              cover property (p_WL_CMD_ODT_OFF);

  c_WL_CMD_MRS_RANK_DIS:         cover property (p_WL_CMD_MRS_RANK_DIS);

  c_WL_CMD_MRS_WL_OFF:           cover property (p_WL_CMD_MRS_WL_OFF);
  
  c_WL_CMD_MRS_Q_OFF:            cover property (p_WL_CMD_MRS_Q_OFF);

  c_WL_CMD_DONE_WL_ENTRY:        cover property (p_WL_CMD_DONE_WL_ENTRY);

  c_WL_CMD_DONE_WL_ODT_OFF:      cover property (p_WL_CMD_DONE_WL_ODT_OFF);

  c_WL_CMD_DONE_WL_EXIT:         cover property (p_WL_CMD_DONE_WL_EXIT);

  
  

endmodule // sva_wl_ctl



module sva_dx_lcdl_ctl_wl (
                           input                               cfg_clk,
                           input                               i_phyctl_rst_n,
                           input  [pCFG_DATA_WIDTH       -1:0] i_reg_wdata,
                           input  [pPIR_FDEPTH_WIDTH     -1:0] i_cfg_fdepth,
                           input  [pPIR_DLDLMT_WIDTH     -1:0] i_cfg_dldlmt,
                           input                               i_cfg_vtinh,
                           input  [pPTR2_TCALON_WIDTH    -1:0] i_cfg_tcalon,
                           input  [pPTR2_TCALS_WIDTH     -1:0] i_cfg_tcals,
                           input  [pPTR2_TCALH_WIDTH     -1:0] i_cfg_tcalh,
                           input  [pPTR2_TWLO_WIDTH      -1:0] i_cfg_twlo,
                           input                               i_cfg_init,
                           input                               i_cfg_wllvt,
                           input  [pPGCR1_WLEN_WIDTH     -1:0] i_cfg_wlen,
                           input  [pPGCR1_WLSTEP_WIDTH   -1:0] i_cfg_wlstep,
                           input  [pPGCR1_WLSELT_WIDTH   -1:0] i_cfg_wlselt,
                           input  [pWLRKEN_WIDTH         -1:0] i_cfg_dxngcr_wlrken,
                           input                               o_cfg_wlerr,
                           input                               o_cfg_wldone,
                           input  [pLCDL_DLY_WIDTH       -1:0] i_cfg_tprd,
                           input                               i_iprd_vtupdate,
                           input  [pLCDL_DLY_WIDTH       -1:0] o_cfg_dxngsr0_wlprd,
                           input                               i_cfg_dxnlcdlr0_wr,
                           input  [pLCDL_DLY_WIDTH       -1:0] o_cfg_dxnlcdlr0_r0wld_rdata,
                           input  [pLCDL_DLY_WIDTH       -1:0] o_cfg_dxnlcdlr0_r1wld_rdata,
                           input  [pLCDL_DLY_WIDTH       -1:0] o_cfg_dxnlcdlr0_r2wld_rdata,
                           input  [pLCDL_DLY_WIDTH       -1:0] o_cfg_dxnlcdlr0_r3wld_rdata,
                           input                               i_dx_vt_update_req,
                           input                               i_cal_init,
                           input                               i_cal_measure,
                           input                               i_cal_average,
                           input                               i_dx_cal_update,
                           input                               o_vt_drift,
                           input                               o_measure_done,
                           input                               i_cal_en_out,
                           input                               i_cal_out,
                           input                               o_cal_en,
                           input                               o_cal_clk_en,
                           input                               i_wl_dx_start,
                           input                               i_wl_init,
                           input  [pPGCR1_WLRANK_WIDTH   -1:0] i_wl_rank,
                           input  [pWL_Q_WIDTH           -1:0] i_wl_q,
                           input                               o_wl_ds,
                           input                               o_wl_dx_done,
                           input  [1:0]                        o_r0_wl_sel,
                           input  [1:0]                        o_r1_wl_sel,
                           input  [1:0]                        o_r2_wl_sel,
                           input  [1:0]                        o_r3_wl_sel
                           );


  //
  // property definitions
  //
  sequence s_DX_WL_FSM_IDLE;
  (`BYTE_0_CTL_WL.wl_fsm_state == sDX_WL_IDLE);
  endsequence
    
    sequence s_DX_WL_FSM_DQS_HIGH;
  (`BYTE_0_CTL_WL.wl_fsm_state == sDX_WL_FSM_DQS_HIGH);
  endsequence

    sequence s_DX_WL_FSM_WAIT_RSLT;
  (`BYTE_0_CTL_WL.wl_fsm_state == sDX_WL_FSM_WAIT_RSLT);
  endsequence

    sequence s_DX_WL_FSM_CHK_RSLT;
  (`BYTE_0_CTL_WL.wl_fsm_state == sDX_WL_FSM_CHK_RSLT);
  endsequence

    sequence s_DX_WL_FSM_DONE;
  (`BYTE_0_CTL_WL.wl_fsm_state == sDX_WL_DONE);
  endsequence

    sequence s_DX_WL_FSM_UNDEFINED_STATE;
  ((`BYTE_0_CTL_WL.wl_fsm_state == 4'b0011) || (`BYTE_0_CTL_WL.wl_fsm_state == 4'b0101) ||
   (`BYTE_0_CTL_WL.wl_fsm_state == 4'b0110) || (`BYTE_0_CTL_WL.wl_fsm_state == 4'b0111) ||
   (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1001) || (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1010) ||
   (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1011) || (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1100) ||
   (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1101) || (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1110) ||
   (`BYTE_0_CTL_WL.wl_fsm_state == 4'b1111) );
  endsequence
    
    
    // Reset is asserted, wl_fsm_state should go back to IDLE state   
    property p_DX_RESET_WL_FSM_IDLE;
  @(posedge `BYTE_0_CTL_WL.cfg_clk)  (`BYTE_0_CTL_WL.i_phyctl_rst_n == 1'b0) or (`BYTE_0_CTL_WL.wl_dx_start==1'b0) |=>  s_DX_WL_FSM_IDLE;
  endproperty

    // When Reset is deasserted, wl_fsm_state should not be in UNDEFINED states
    property p_DX_WL_FSM_NOT_UNDEFINED_STATE;
  @(posedge `BYTE_0_CTL_WL.cfg_clk)  disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    (`BYTE_0_CTL_WL.i_phyctl_rst_n == 1'b1) |=>  not s_DX_WL_FSM_UNDEFINED_STATE;
  endproperty
    
    // WL FSM: wl_start_trigger takes IDLE to DQS_HIGH
    property p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_0;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b00) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[0]==1'b1)) |=> ##[1:2] s_DX_WL_FSM_DQS_HIGH
                                                                                        ##[1:10] (`TB.dqs[0]==1'b1);
  endproperty

    property p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_1;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b01) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[1]==1'b1)) |=> ##[1:2] s_DX_WL_FSM_DQS_HIGH
                                                                                        ##[1:10] (`TB.dqs[0]==1'b1);
  endproperty

    property p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_2;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b10) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[2]==1'b1)) |=> ##[1:2] s_DX_WL_FSM_DQS_HIGH
                                                                                        ##[1:10] (`TB.dqs[0]==1'b1);
  endproperty

    property p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_3;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b11) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[3]==1'b1)) |=> ##[1:2] s_DX_WL_FSM_DQS_HIGH
                                                                                        ##[1:10] (`TB.dqs[0]==1'b1);
  endproperty

    // Check to see if rank is not enable, the wl_fsm_state will skip to DONE
    property p_DX_WL_FSM_IDLE_TO_DONE_RANK_0;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b00) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[0]==1'b0)) |=> ##[1:2] s_DX_WL_FSM_DONE;
  endproperty

    property p_DX_WL_FSM_IDLE_TO_DONE_RANK_1;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b01) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[1]==1'b0)) |=> ##[1:2] s_DX_WL_FSM_DONE;
  endproperty

    property p_DX_WL_FSM_IDLE_TO_DONE_RANK_2;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b10) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[2]==1'b0)) |=> ##[1:2] s_DX_WL_FSM_DONE;
  endproperty

    property p_DX_WL_FSM_IDLE_TO_DONE_RANK_3;
  @(posedge `BYTE_0_CTL_WL.cfg_clk) disable iff (! `BYTE_0_CTL_WL.i_phyctl_rst_n)
    ($rose(`BYTE_0_CTL_WL.wl_dx_start) and s_DX_WL_FSM_IDLE and (`BYTE_0_CTL_WL.wl_rank== 2'b11) and (`BYTE_0_CTL_WL.cfg_dxngcr_wlrken[3]==1'b0)) |=> ##[1:2] s_DX_WL_FSM_DONE;
  endproperty

    
    
    //     
    // assert statements
    //
    a_DX_RESET_WL_FSM_IDLE:                assert property (p_DX_RESET_WL_FSM_IDLE)
      else `SVA_ERR("PHYCTL DX WL FSM not IDLE when Reset active");

  a_DX_WL_FSM_NOT_UNDEFINED_STATE:       assert property (p_DX_WL_FSM_NOT_UNDEFINED_STATE)
    else `SVA_ERR("PHYCTL DX WL FSM IN UNDEFINED STATE when not in RESET");
  
  
  a_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_0:   assert property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_0)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE not triggering WL FSM DQS HIGH for RANK 0");

  a_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_1:   assert property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_1)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE not triggering WL FSM DQS HIGH for RANK 1");

  a_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_2:   assert property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_2)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE not triggering WL FSM DQS HIGH for RANK 2");

  a_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_3:   assert property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_3)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE not triggering WL FSM DQS HIGH for RANK 3");

  a_DX_WL_FSM_IDLE_TO_DONE_RANK_0:       assert property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_0)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE for disable RANK 0 did not go directly to DONE state");

  a_DX_WL_FSM_IDLE_TO_DONE_RANK_1:       assert property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_1)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE for disable RANK 1 did not go directly to DONE state");

  a_DX_WL_FSM_IDLE_TO_DONE_RANK_2:       assert property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_2)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE for disable RANK 2 did not go directly to DONE state");

  a_DX_WL_FSM_IDLE_TO_DONE_RANK_3:       assert property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_3)
    else `SVA_ERR("PHYCTL DX WL FSM IDLE for disable RANK 3 did not go directly to DONE state");


  //     
  // cover statements
  //
  c_DX_RESET_WL_FSM_IDLE:                cover property (p_DX_RESET_WL_FSM_IDLE);
  
  c_DX_WL_FSM_NOT_UNDEFINED_STATE:       cover property (p_DX_WL_FSM_NOT_UNDEFINED_STATE);
  
  c_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_0:   cover property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_0);
  
  c_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_1:   cover property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_1);
  
  c_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_2:   cover property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_2);
  
  c_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_3:   cover property (p_DX_WL_FSM_IDLE_TO_DQS_HIGH_RANK_3);
  
  c_DX_WL_FSM_IDLE_TO_DONE_RANK_0:       cover property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_0);

  c_DX_WL_FSM_IDLE_TO_DONE_RANK_1:       cover property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_1);

  c_DX_WL_FSM_IDLE_TO_DONE_RANK_2:       cover property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_2);

  c_DX_WL_FSM_IDLE_TO_DONE_RANK_3:       cover property (p_DX_WL_FSM_IDLE_TO_DONE_RANK_3);

  
endmodule // sva_dx_lcdl_ctl_wl


//---------------------------------------------------------------------------------------------------
//                  
// SVA binding      
//                  
//---------------------------------------------------------------------------------------------------
bind `PHYCTL_WL_CTL  sva_wl_ctl  sva_wl_ctl
  (
   ctl_clk,                
   i_ctl_rst_n,            
   cfg_clk,                
   i_init_rst_n,           
   i_cfg_wlen,             
   i_cfg_wlfull,           
   i_cfg_wlrank,           
   i_cfg_dxngcr_dx8en,     
   i_cfg_twldlys,          
   o_cfg_wldone,           
   o_clr_cfg_pgcr1_wlen,   
   o_wl_mode,              
   o_wl_init,              
   o_wl_rank,              
   o_wl_dx_start,          
   i_wl_dx_done,           
   i_mr1,                  
   i_sdr_mode,             
   i_t_mrd,                
   i_t_mod,                
   i_t_wlmrd,              
   o_ctl_odt,              
   o_ctl_cs_n,             
   o_ctl_ras_n,            
   o_ctl_cas_n,            
   o_ctl_we_n,             
   o_ctl_ba,               
   o_ctl_a                 
   );


bind `BYTE_0_CTL_WL  sva_dx_lcdl_ctl_wl  sva_dx_lcdl_ctl_wl_0 
  (
   cfg_clk,
   i_phyctl_rst_n,
   i_reg_wdata,
   i_cfg_fdepth,
   i_cfg_dldlmt,
   i_cfg_vtinh,
   i_cfg_tcalon,
   i_cfg_tcals,
   i_cfg_tcalh,
   i_cfg_twlo,
   i_cfg_init,
   i_cfg_wllvt,
   i_cfg_wlen,
   i_cfg_wlstep,
   i_cfg_wlselt,
   i_cfg_dxngcr_wlrken,
   o_cfg_wlerr,
   o_cfg_wldone,
   i_cfg_tprd,
   i_iprd_vtupdate,
   o_cfg_dxngsr0_wlprd,
   i_cfg_dxnlcdlr0_wr,
   o_cfg_dxnlcdlr0_r0wld_rdata,
   o_cfg_dxnlcdlr0_r1wld_rdata,
   o_cfg_dxnlcdlr0_r2wld_rdata,
   o_cfg_dxnlcdlr0_r3wld_rdata,
   i_dx_vt_update_req,
   i_cal_init,
   i_cal_measure,
   i_cal_average,
   i_dx_cal_update,
   o_vt_drift,
   o_measure_done,
   i_cal_en_out,
   i_cal_out,
   o_cal_en,
   o_cal_clk_en,
   i_wl_dx_start,
   i_wl_init,
   i_wl_rank,
   i_wl_q,
   o_wl_ds,
   o_wl_dx_done,
   o_r0_wl_sel,
   o_r1_wl_sel,
   o_r2_wl_sel,
   o_r3_wl_sel   
   );
`endif
