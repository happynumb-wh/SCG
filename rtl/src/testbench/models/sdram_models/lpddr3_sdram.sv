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
    vmm_log log = new("lpddr3_sdram", "lpddr3_sdram");
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

`ifdef  DWC_DDRPHY_BOARD_DELAYS
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
`else
  assign ck_i       =   ck;
  assign ck_n_i     =   ck_n;
  assign cke_i      =   cke;
  assign odt_i      =   odt;
  assign cs_n_i     =   cs_n;
  assign a_i        =   a;
  assign dm_i       =   dm;
  assign dqs_i      =   dqs;
  assign dqs_n_i    =   dqs_n;
  assign dq_i       =   dq;
  assign ras_n_i    =   ras_n;
  assign cas_n_i    =   cas_n;
  assign we_n_i     =   we_n;
  assign act_n_i    =   1'b0;
  assign parity_i   =   1'b0;
  assign bg_i       =   {`DWC_PHY_BG_WIDTH{1'b0}};
  assign ba_i       =   ba;
`endif
   

`ifdef ELPIDA_DDR
 `ifdef LPDDR3
elpida_lpddr3_32 sdram
    (
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .cs_n          (cs_n_i),
     .odt           (odt_i),
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
     );

//DDRG2MPHY: Boot Error. Valid only when the PHY is run at tCK of 10-55 MHz.
//Overriding the memory parameter since we are not running at this frequency

defparam sdram.tISCKEbmin = 0;
defparam sdram.tIHCKEbmin = 0;
defparam sdram.tISbmin    = 0; 
defparam sdram.tIHbmin    = 0; 


 `endif 


 `endif //ifdef ELPIDA_DDR

`ifdef MICRON_DDR
mobile_ddr3 sdram
    (
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .cs_n          (cs_n_i),
     .odt           (odt_i),
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
`ifdef VMM_VERIF
     ,  
     speed_grade    (speed_grade) // SDRAM speed grade
`endif                  
`endif
     );
`endif
 

  // SDRAM clock checks
  // ------------------
  // enable/diasble clock violation checks on the SDRAMs
  task set_clock_checks;
    input clock_check;
    begin
     //`ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_clocks = clock_check;
     //`endif
    end
  endtask // enable_clock_checks
  
  
  // SDRAM DQ setup/hold checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_dq_setup_hold_checks;
    input dq_setup_hold_check;
    begin
     //`ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dq_setup_hold = dq_setup_hold_check;
     //`endif
    end
  endtask // enable_dq_setup_hold_checks
 
  task set_dq_drain_err;
    input dram_dq_force;
      if (dram_dq_force == 1) begin
        `ifdef  DWC_DDRPHY_BOARD_DELAYS
          board_delay_model.training_err = 1;
        `endif
        if($urandom%2)
          force dq = 1;
        else
          force dq = 0;
//        sdram.check_dqs_ck_setup_hold = 0; 
      end
      else begin
        release dq;
        `ifdef  DWC_DDRPHY_BOARD_DELAYS
          board_delay_model.training_err = 0;
        `endif
      end
  endtask
  
  // SDRAM DQ/DM/DQS pulse width checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_dq_pulse_width_checks;
    input dq_pulse_width_check;
    begin
     //`ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dq_pulse_width = dq_pulse_width_check;
     //`endif
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
    begin
     `ifdef ELPIDA_DDR
      sdram.check_ctrl_addr_pulse_width = ctrl_addr_pulse_width_check;
     `endif
    end
  endtask // enable_ctrl_addr_pulse_width_checks
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
/*   
   // initialization sequence is normally very long - so change it to reduced
   // value unless it the testcase specially checks initialization, in which
   // case it has to define the FULL_SDRAM_INIT compile define
 `ifdef FULL_SDRAM_INIT
 `else
   `ifdef LPDDR2
   defparam sdram.TINIT3  = (`tDINIT0_c_ssi*tb_cfg.clk_prd*1000);
   defparam sdram.TINIT4  = ((1.0/11.0) *`tDINIT2_c_ssi*tb_cfg.clk_prd*1000);
   defparam sdram.TINIT5  = ((10.0/11.0)*`tDINIT2_c_ssi*tb_cfg.clk_prd*1000);
   defparam sdram.TZQINIT = ((`tDINIT3_c_ssi-1)*tb_cfg.clk_prd*1000);
   `endif
 `endif
*/     

`ifdef MICRON_DDR
  `ifdef OVRD_TDQSCK
    task get_tdqsck;
      output real val_A;
      begin 
        val_A = sdram.rnd_tdqsck;
      end
    endtask
  `endif  
`endif

  //task set_tdqsck;
`ifdef MICRON_DDR
 `ifdef LPDDR4
  task set_tdqsck;
    input int val_A;
    input int val_B;
    begin 
      sdram.ch_A.tdqsck = val_A;
      sdram.ch_B.tdqsck = val_B;
    end
  endtask
`endif
`endif

`ifdef ELPIDA_DDR
 `ifdef LPDDR3
  task set_tdqsck;
    input int val_A;
    begin
      sdram.flag_tdqsck_rnd =1;
      sdram.rnd_tdqsck = val_A;
    end
  endtask
`endif
`endif
endmodule // ddr_sdram

