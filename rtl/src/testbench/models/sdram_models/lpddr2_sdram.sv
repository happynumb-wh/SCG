/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys.                                               *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR SDRAM Chip                                                *
 *              Individual SDRAM chip from different vendor and either DDR or *
 *              DDR2                                                          *
 *                                                                            *
 *****************************************************************************/

`timescale 1ps/1ps  // Set the timescale for board delays

module ddr_sdram (
                  rst_n,     // SDRAM reset
                  ck,        // SDRAM clock
                  ck_n,      // SDRAM clock #
                  cke,       // SDRAM clock enable
                  odt,       // SDRAM on-die termination
                  cs_n,      // SDRAM chip select
                  ras_n,     // SDRAM command input (row address select)
                  cas_n,     // SDRAM command input (column address select)
                  we_n,      // SDRAM command input (write enable)
                  ba,        // SDRAM bank address
                  a,         // SDRAM address
                  dm,        // SDRAM output data mask
                  dqs,       // SDRAM input/output data strobe
                  dqs_n,     // SDRAM input/output data strobe #
                  dq,        // SDRAM input/output data
                  alert_n    // SDRAM parity error alert
                `ifdef VMM_VERIF
                  ,  
                  speed_grade // SDRAM speed grade
                `endif                  
                  );

  `ifdef VMM_VERIF
    vmm_log log = new("lpddr2_sdram", "lpddr2_sdram");
  `endif 

  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter pSDRAM_BANK_WIDTH	= `SDRAM_BANK_WIDTH;
  parameter pBANK_WIDTH	= `BANK_WIDTH;    
  parameter pCHIP_NO    = 0;
  parameter pDIMM_NO    = 0;
  parameter pRANK_NO    = 0;

  

  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input     rst_n;   // SDRAM reset
  input     ck;      // SDRAM clock
  input     ck_n;    // SDRAM clock #
  input     cke;     // SDRAM clock enable
  input     odt;     // SDRAM on-die termination
  input     cs_n;    // SDRAM chip select
  input     ras_n;   // SDRAM row address select
  input     cas_n;   // SDRAM column address select
  input     we_n;    // SDRAM write enable
  input [`SDRAM_BANK_WIDTH-1:0] ba;      // SDRAM bank address
  input [`SDRAM_ADDR_WIDTH-1:0] a;       // SDRAM address
  input [`SDRAM_BYTE_WIDTH-1:0] dm;      // SDRAM output data mask
  inout [`SDRAM_BYTE_WIDTH-1:0] dqs;     // SDRAM input/output data strobe
  inout [`SDRAM_BYTE_WIDTH-1:0] dqs_n;   // SDRAM input/output data strobe #
  inout [`SDRAM_DATA_WIDTH-1:0] dq;      // SDRAM input/output data
  output alert_n;                            // SDRAM parity error alert
`ifdef VMM_VERIF
  input [3:0]                   speed_grade; // SDRAM speed grade
`endif
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire                           ck_i;
  wire                           ck_n_i;
  wire                           cke_i;
  wire                           odt_i;
  wire                           cs_n_i;
  wire                           ras_n_i;
  wire                           cas_n_i;
  wire                           we_n_i;
  wire [`SDRAM_BANK_WIDTH-1:0]   ba_i;
  wire [`SDRAM_ADDR_WIDTH-1:0]   a_i;
  wire [`SDRAM_BYTE_WIDTH-1:0]   dm_i;
  wire [`SDRAM_BYTE_WIDTH-1:0]   dqs_i;
  wire [`SDRAM_BYTE_WIDTH-1:0]   dqs_n_i;
  wire [`SDRAM_DATA_WIDTH-1:0]   dq_i;   
  wire [`DWC_PHY_BG_WIDTH-1:0]   bg_i;  
  wire                           alert_n;

  // added for compatiblity to ddr4_sdram model
  wire 				 model_enable;


  pullup (weak1) u0 (alert_n);

  // Board Delay Modelling
  ddr_board_delay_model board_delay_model(.ck(ck), .ck_n(ck_n), .cke(cke),
					  .odt(odt), .cs_n(cs_n), .a(a),
					  .dm(dm), .dqs(dqs), .dqs_n(dqs_n),
					  .dq(dq), .ras_n(ras_n), .cas_n(cas_n), 
					  .we_n(we_n), .act_n(1'b0),
					  .parity(1'b0), .bg({`DWC_PHY_BG_WIDTH{1'b0}}), .ba(ba),
					  .ck_i(ck_i), .ck_n_i(ck_n_i), .cke_i(cke_i),
					  .odt_i(odt_i), .cs_n_i(cs_n_i), .a_i(a_i),
					  .dm_i(dm_i), .dqs_i(dqs_i), .dqs_n_i(dqs_n_i),
					  .dq_i(dq_i), .ras_n_i(ras_n_i), .cas_n_i(cas_n_i), 
					  .we_n_i(we_n_i), .act_n_i(act_n_i),
					  .parity_i(parity_i), .bg_i(bg_i), .ba_i(ba_i));
   

  //---------------------------------------------------------------------------
  // Micron DDR2/DDR3/LPDDR2 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2, DDR3 or LPDDR2 SDRAM chip from Micron
`ifdef MICRON_DDR
  `ifdef LPDDR2
    // Micron LPDDR2 SDRAM chip
    // ------------------------
    mobile_ddr2 sdram
    (
      .ck            (ck_i),
      .ck_n          (ck_n_i),
      .cke           (cke_i),
      .cs_n          (cs_n_i),
      .ca            (a_i),
      `ifdef  DWC_DDRPHY_BOARD_DELAYS  
        `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
          `ifdef DWC_DX_DM_USE
            .dm          (dm_i),
          `else
            .dm          ({`SDRAM_BYTE_WIDTH{1'b0}}),
          `endif
          .dqs           (dqs_i),
          .dqs_n         (dqs_n_i),
          .dq            (dq_i)
        `else     
          `ifdef DWC_DX_DM_USE
            .dm          (dm),
          `else
            .dm          ({`SDRAM_BYTE_WIDTH{1'b0}}),
          `endif
          .dqs           (dqs),
          .dqs_n         (dqs_n),
          .dq            (dq)
        `endif    
      `else     
        `ifdef DWC_DX_DM_USE
          .dm          (dm),
        `else
          .dm          ({`SDRAM_BYTE_WIDTH{1'b0}}),
        `endif
        .dqs           (dqs),
        .dqs_n         (dqs_n),
        .dq            (dq)
      `endif     
      `ifdef VMM_VERIF
        ,
        .speed_grade   (speed_grade)       
      `endif
     );
  `endif // LPDDR2

  // DRAM parameters
  // ---------------
  // override SDRAM parameters for the selected chip
  // NOTE: *** TBD the current Micro model has addr[13] always there even if
  //       fewer address bits are

  defparam                      sdram.DQS_BITS  = `SDRAM_DS_WIDTH;
  defparam                      sdram.DM_BITS   = `SDRAM_DM_WIDTH;
  defparam                      sdram.DQ_BITS   = `SDRAM_DATA_WIDTH;


  // TODO - Not sure how changing this here may affect the rest of the environment.  For now
  //        since 13 bits is working and the LPDDR2 model only looks at the both 10, leaving as 
  //        SDRAM_ROW_WIDTH.
  // For LPDDR2, CA bus at the DRAM is 10 bits wide
  // defparam                      sdram.CA_BITS   = 10;
  defparam                      sdram.CA_BITS   = `SDRAM_ADDR_WIDTH;
  defparam                      sdram.ROW_BITS  = `SDRAM_ROW_WIDTH;
  defparam                      sdram.SX        = `LPDDR2_SX;
  defparam                      sdram.COL_BITS  = `SDRAM_COL_WIDTH;
  defparam                      sdram.BA_BITS   = `SDRAM_BANK_WIDTH;
  defparam                      sdram.MEM_BITS  = `SDRAM_MEM_BITS;

  // debug messages
  // --------------
  // disables the debug messages that are output from the vendor memory model 
  // (these messages are on by default)
  `ifdef MEMORY_DEBUG
  `else
  initial #0.001                sdram.mcd_info = 0;
  `endif
  // SDRAM array initialization
  // --------------------------
  // direct initialization of memory array with a background pattern; this is
  // especially used for testcases that do random reads and avoid returning
  // undefined data (and warnings) if access is to uninitialized locations
`ifndef VMM_VERIF
  always @(posedge `SYS.init_sdram_array)
    begin: array_init
      integer i;
      integer mem_depth;
      reg [3:0] nibble;      

      if (`SYS.init_sdram_array === 1'b1)
        begin
          mem_depth = (1 << `SDRAM_MEM_BITS);
          nibble    = `SYS.sdram_init_nibble;
          
          for (i=0; i<mem_depth; i=i+1)
            begin
              sdram.memory[i]    = {(8*`SDRAM_DATA_WIDTH/4){nibble}};
            end
        end
    end
`endif // VMM_VERIF

`endif // ifdef MICRON_DDR
    

  
  // Only micron models have been enhanced to include board delays and other
  // features to enable/disable certain checks
`ifdef MICRON_DDR
  `ifdef LPDDR2
    `define DWC_ENHANCED_DDR_MODEL
  `endif
`endif

  // SDRAM clock checks
  // ------------------
  // enable/diasble clock violation checks on the SDRAMs
  task set_clock_checks;
    input clock_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_clocks = clock_check;
     `endif
    end
  endtask // enable_clock_checks
  
  
  // SDRAM DQ setup/hold checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_dq_setup_hold_checks;
    input dq_setup_hold_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dq_setup_hold = dq_setup_hold_check;
     `endif
    end
  endtask // enable_dq_setup_hold_checks
 
  task set_dq_drain_err;
    input dram_dq_force;
      if (dram_dq_force == 1) begin
        board_delay_model.training_err = 1;
        if($urandom%2)
          force dq = 1;
        else
          force dq = 0;
//        sdram.check_dqs_ck_setup_hold = 0; 
      end
      else begin
        release dq;
        board_delay_model.training_err = 0;
      end
  endtask
  
  // SDRAM DQ/DM/DQS pulse width checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_dq_pulse_width_checks;
    input dq_pulse_width_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dq_pulse_width = dq_pulse_width_check;
     `endif
    end
  endtask // enable_dq_pulse_width_checks
  
  
  // SDRAM DQS-toCK setup/hold checks
  // --------------------------------
  // enable/diasble DQS-to-CK setup/hold violation checks on the SDRAMs
  task set_dqs_ck_setup_hold_checks;
    input dqs_ck_setup_hold_check;
/*    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dqs_ck_setup_hold = dqs_ck_setup_hold_check;
     `endif
    end
*/  endtask // enable_dqs_ck_setup_hold_checks
  

  // SDRAM Command and Address setup/hold timing checks
  // --------------------------------
  // enable/diasble Command and Address setup/hold violation checks on the SDRAMs
  task set_cmd_addr_timing_checks;
    input cmd_addr_timing_check;
/*    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_cmd_addr_timing = cmd_addr_timing_check;
     `endif
    end
*/  endtask // enable_cmd_addr_timing_checks
  
  
  // SDRAM Ctrl and Address pulse width checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_ctrl_addr_pulse_width_checks;
    input ctrl_addr_pulse_width_check;
/*    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_ctrl_addr_pulse_width = ctrl_addr_pulse_width_check;
     `endif
    end
*/  endtask // enable_ctrl_addr_pulse_width_checks
/*  
  `ifdef DDR3
  // SDRM ODTH{4,8} timing checks
  // --------------------------
  task set_odth_timing_checks;
    input odt_timing_check;
    begin
     `ifndef MICRON_DDR
       `ifdef DWC_ENHANCED_DDR_MODEL
        sdram.check_odth = odt_timing_check;
       `endif
     `endif
    end
  endtask // set_odth_timing_checks 
  `endif // ifdef DDR3
*/ 
  // SDRAM refresh check
  // -------------------
  // enable/diasble refresh violation checks on the SDRAMs
  task set_refresh_check;
    input rfsh_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_rfc_max = rfsh_check;
     `endif
    end
  endtask // set_refresh_check
/*
     `ifdef DWC_ENHANCED_DDR_MODEL
       `ifdef DDR2
  initial TRFC_MAX = sdram.TRFC_MAX; // default tRFCmax of the SDRAM
       `endif
     `endif
*/
/*
  task set_mpr_bytemask;
    input [7:0] bytemask;
    `ifdef VMM_VERIF
      `ifdef DDR3
        sdram.mpr_bytemask = bytemask;
      `endif
    `endif
  endtask
*/ 


`ifndef VMM_VERIF 
   // initialization sequence is normally very long - so change it to reduced
   // value unless it the testcase specially checks initialization, in which
   // case it has to define the FULL_SDRAM_INIT compile define
 `ifdef FULL_SDRAM_INIT
 `else
  `ifdef MICRON_DDR
   `ifdef LPDDR2
   defparam sdram.TINIT3  = (`tDINIT0_c_ssi*`CLK_PRD*1000);
   defparam sdram.TINIT4  = ((1.0/11.0) *`tDINIT2_c_ssi*`CLK_PRD*1000);
   defparam sdram.TINIT5  = ((10.0/11.0)*`tDINIT2_c_ssi*`CLK_PRD*1000);
   defparam sdram.TZQINIT = ((`tDINIT3_c_ssi-1)*`CLK_PRD*1000);
   `endif
  `endif
 `endif
`endif   

endmodule // ddr_sdram

