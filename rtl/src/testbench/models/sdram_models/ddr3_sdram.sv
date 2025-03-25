/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
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
`ifdef SNPS_VIP
    `include "snps_ddr3_sdram.sv"
`endif


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
    vmm_log log = new("ddr3_sdram", "ddr3_sdram");
  `endif


  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input     rst_n;                           // SDRAM reset
  input     ck;                              // SDRAM clock
  input     ck_n;                            // SDRAM clock #
  input     cke;                             // SDRAM clock enable
  input     odt;                             // SDRAM on-die termination
  input     cs_n;                            // SDRAM chip select
  input     ras_n;                           // SDRAM row address select
  input     cas_n;                           // SDRAM column address select
  input     we_n;                            // SDRAM write enable
  input [`SDRAM_BANK_WIDTH-1:0] ba;          // SDRAM bank address
  input [`SDRAM_ADDR_WIDTH-1:0] a;           // SDRAM address
  input [`SDRAM_BYTE_WIDTH-1:0] dm;          // SDRAM output data mask
  inout [`SDRAM_BYTE_WIDTH-1:0] dqs;         // SDRAM input/output data strobe
  inout [`SDRAM_BYTE_WIDTH-1:0] dqs_n;       // SDRAM input/output data strobe #
  inout [`SDRAM_DATA_WIDTH-1:0] dq;          // SDRAM input/output data
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
					  .parity(1'b0), .bg({`DWC_PHY_BG_WIDTH{1'b0}}), 
					  .ba(ba),.ck_i(ck_i), .ck_n_i(ck_n_i), .cke_i(cke_i),
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
  
   
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter pSDRAM_BANK_WIDTH	= `SDRAM_BANK_WIDTH;
  parameter pBANK_WIDTH	= `BANK_WIDTH;    
  parameter pCHIP_NO    = 0;
  parameter pDIMM_NO    = 0;
  parameter pRANK_NO    = 0;

 
  //---------------------------------------------------------------------------
  // others
  //---------------------------------------------------------------------------
  integer   TRFC_MAX;
  
  //---------------------------------------------------------------------------
  // Micron DDR2/DDR3 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2 or DDR3 SDRAM chip from Micron
`ifdef MICRON_DDR
  `ifdef DDR2
  // Micron DDR2 SDRAM chip
  // ----------------------
  ddr2 sdram
    (
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .odt           (odt_i),
     .cs_n          (cs_n_i),
     .ras_n         (ras_n_i),
     .cas_n         (cas_n_i),
     .we_n          (we_n_i),
     .ba            (ba_i),
    `ifdef SDRAM_ADDR_LT_14
       .addr        ({{(14-`SDRAM_ADDR_WIDTH){1'b0}}, a_i}),
     `else
       .addr        (a_i),
     `endif
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS
     .dm_rdqs       (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i),
  `else     
     .dm_rdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
  `endif   
`else     
     .dm_rdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq), 
`endif
     .rdqs_n        ()
`ifdef VMM_VERIF
     ,
     .speed_grade   (speed_grade)       
`endif
     ); 
  `endif
  
  `ifdef DDR3
  // Micron DDR3 SDRAM chip
  // ----------------------
  ddr3 sdram

    (
     .rst_n         (rst_n),
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .odt           (odt_i),
     .cs_n          (cs_n_i),
     .ras_n         (ras_n_i),
     .cas_n         (cas_n_i),
     .we_n          (we_n_i),
     .ba            (ba_i),
    `ifdef SDRAM_ADDR_LT_14
       .addr        ({{(14-`SDRAM_ADDR_WIDTH){1'b0}}, a_i}),
     `else
       .addr        (a_i),
     `endif
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm_tdqs       (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i),
  `else     
     .dm_tdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
  `endif    
`else     
     .dm_tdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
`endif
     .tdqs_n        ()
`ifdef VMM_VERIF
     ,
     .speed_grade   (speed_grade)       
`endif
     );
  `endif


  // DRAM parameters
  // ---------------
  // override SDRAM parameters for the selected chip
  // NOTE: *** TBD the current Micro model has addr[13] always there even if
  //       fewer address bits are
  defparam                      sdram.DM_BITS   = `SDRAM_DM_WIDTH;
  `ifdef SDRAM_ADDR_LT_14
  defparam                      sdram.ADDR_BITS = 14;
  defparam                      sdram.ROW_BITS  = 14;
  `else
  defparam                      sdram.ADDR_BITS = `SDRAM_ADDR_WIDTH;

  defparam                      sdram.ROW_BITS  = `SDRAM_ROW_WIDTH;
  `endif
  defparam                      sdram.COL_BITS  = `SDRAM_COL_WIDTH;
  defparam                      sdram.DQ_BITS   = `SDRAM_DATA_WIDTH;
  defparam                      sdram.DQS_BITS  = `SDRAM_DS_WIDTH;

  defparam                      sdram.BA_BITS   = `SDRAM_BANK_WIDTH;
  defparam                      sdram.MEM_BITS  = `SDRAM_MEM_BITS;
  

  // debug messages
  // --------------
  // disables the debug messages that are output from the vendor memory model 
  // (these messages are on by default)
  `ifdef MEMORY_DEBUG
  `else
  defparam                      sdram.DEBUG = 0;
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

   
  //---------------------------------------------------------------------------
  // DDR3 SYNOP  VIP SDRAM 
  //---------------------------------------------------------------------------
  
`ifdef SNPS_VIP  //SNPS_VIP
  snps_ddr3_sdram sdram
    (
     .rst_n         (rst_n),
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .otc           (odt_i),
     .cs_n          (cs_n_i),
     .ras_n         (ras_n_i),
     .cas_n         (cas_n_i),
     .we_n          (we_n_i),
     .ba            (ba_i),
     .ad            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i)
  `else     
     .dm            (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq)
  `endif   
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq)
`endif   
     );
  
// Turning OFF/ON  VIP errors at time=0ns
initial begin
#1
    $display ("Turning OFF/ON VIP errors Time=%0dns ", $time);
    sdram.ddr_env.mem_group.checks.ref_2srm_self_refresh_check.set_is_enabled(0);
    sdram.ddr_env.mem_group.checks.reset_pulse_width_in_pu_init_check.set_is_enabled(0);
    sdram.ddr_env.mem_group.checks.missing_rd_postamble_read_write_check.set_is_enabled(0);
end 

// Turning OFF/ON  VIP errors at an event using misc signals.
always @(ddr4mphy_system.misc_if.training_complete) begin
    sdram.ddr_env.mem_group.checks.missing_rd_postamble_read_write_check.set_is_enabled(0);
end

`endif //SNPS_VIP 


  //---------------------------------------------------------------------------
  // Samsung DDR/DDR2 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2 or DDR3 SDRAM chip from Samsung
`ifdef SAMSUNG_DDR
  `ifdef DDR2
  // Samsung DDR2 SDRAM chip
  // -----------------------
  DDRII sdram
    (
     .clk           (ck_i),
     .clkb          (ck_n_i),
     .cke           (cke_i),
     .otc           (odt_i),
     .csb           (cs_n_i),
     .rasb          (ras_n_i),
     .casb          (cas_n_i),
     .web           (we_n_i),
     .ba            (ba_i),
     .ad            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS   
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS   
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqsb          (dqs_n_i),
     .dqi           (dq_i),
  `else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq),
  `endif    
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq),
`endif    
     .rdsb          ()
     );
  `endif

  `ifdef DDR3
  // Samsung DDR3 SDRAM chip
  // -----------------------
  DDRIII sdram
    (
     .rstb          (rst_n),
     .clk           (ck_i),
     .clkb          (ck_n_i),
     .cke           (cke_i),
     .otc           (odt_i),
     .csb           (cs_n_i),
     .rasb          (ras_n_i),
     .casb          (cas_n_i),
     .web           (we_n_i),
     .ba            (ba_i),
     .ad            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqsb          (dqs_n_i),
     .dqi           (dq_i)
  `else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq)
  `endif   
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq)
`endif   
     );
  `endif
`endif // ifdef SAMSUNG_DDR

  
  //---------------------------------------------------------------------------
  // Qimonda DDR2/DDR3 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2 or DDR3 SDRAM chip from Qimonda
`ifdef QIMONDA_DDR
  `ifdef DDR2
  // Qimonda DDR2 SDRAM chip
  // -----------------------
  // TBD: not currently used
  `endif
  
  `ifdef DDR3
  // Qimonda DDR3 SDRAM chip
  // -----------------------
    `ifdef SDRAMx4
  IDSH5102A1F1C #(`QSPEED_BIN) sdram
    `else `ifdef SDRAMx8
    IDSH5103A1F1C #(`QSPEED_BIN) sdram  
      `else
      IDSH5104A1F1C #(`QSPEED_BIN) sdram
      `endif `endif
        (
         .bRESET        (rst_n),
         .CK            (ck_i),
         .bCK           (ck_n_i),
         .CKE           (cke_i),
         .ODT           (odt_i),
         .bCS           (cs_n_i),
         .bRAS          (ras_n_i),
         .bCAS          (cas_n_i),
         .bWE           (we_n_i),
         .BA            (ba_i),
         .Addr          (a_i),
         `ifdef SDRAMx16
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
         .DML           (dm_i[0]),
         .DMU           (dm_i[1]),
         .DQSL          (dqs_i[0]),
         .DQSU          (dqs_i[1]),
         .bDQSL         (dqs_n_i[0]),
         .bDQSU         (dqs_n_i[1]),
  `else
         .DML           (dm[0]),
         .DMU           (dm[1]),
         .DQSL          (dqs[0]),
         .DQSU          (dqs[1]),
         .bDQSL         (dqs_n[0]),
         .bDQSU         (dqs_n[1]),
  `endif
`endif   
         `else
         .DM            (dm),
         .DQS           (dqs),
         .bDQS          (dqs_n),
         `endif
         .DQ            (dq),
         .RTT           ()
         );
  
       `endif
     `endif

   
  // Only micron models have been enhanced to include board delays and other
  // features to enable/disable certain checks
`ifdef MICRON_DDR
  `ifdef DDR2
    `define DWC_ENHANCED_DDR_MODEL
  `endif
  `ifdef DDR3
    `define DWC_ENHANCED_DDR_MODEL
  `endif
  `ifdef LPDDR1
    `define DWC_ENHANCED_DDR_MODEL
  `endif
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
        `ifdef  DWC_DDRPHY_BOARD_DELAYS    
          board_delay_model.training_err = 1;
        `endif
        if($urandom%2)
          force dq = 1;
        else
          force dq = 0;
        `ifndef SNPS_VIP  //SNPS_VIP
          sdram.check_dqs_ck_setup_hold = 0; 
        `endif
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
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dqs_ck_setup_hold = dqs_ck_setup_hold_check;
     `endif
    end
  endtask // enable_dqs_ck_setup_hold_checks
  
 
  // SDRAM Command and Address setup/hold timing checks
  // --------------------------------
  // enable/diasble Command and Address setup/hold violation checks on the SDRAMs
  task set_cmd_addr_timing_checks;
    input cmd_addr_timing_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_cmd_addr_timing = cmd_addr_timing_check;
     `endif
    end
  endtask // enable_cmd_addr_timing_checks
  
  
  // SDRAM Ctrl and Address pulse width checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_ctrl_addr_pulse_width_checks;
    input ctrl_addr_pulse_width_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_ctrl_addr_pulse_width = ctrl_addr_pulse_width_check;
     `endif
    end
  endtask // enable_ctrl_addr_pulse_width_checks
  
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
     `ifdef DWC_DDRPHY_EMUL_XILINX
       // DLL off mode in emulation
         `ifndef  VMM_VERIF
            sdram.check_odth = odt_timing_check;
	  `endif  
     `endif
    end
  endtask // set_odth_timing_checks
  // SDRAM DQS Latch timing checks
  // -----------------------------
  `ifndef VMM_VERIF
     task set_dqs_latch_timing_checks;
       input dqs_latch_timing_check;
       begin
         sdram.check_dqs_latch = dqs_latch_timing_check;
       end
     endtask // set_dqs_latch_timing_checks
  `endif // VMM_VERIF
  `endif // ifdef DDR3
  
  
  
 
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

`ifndef VMM_VERIF
  `ifndef DDR2
  task set_tpdmax_check;
    input tpdmax_check;
    begin
        sdram.check_pd_max = tpdmax_check;
    end
  endtask // set_tpdmax_check
  `endif
`endif

     `ifdef DWC_ENHANCED_DDR_MODEL
       `ifdef DDR2
  initial TRFC_MAX = sdram.TRFC_MAX; // default tRFCmax of the SDRAM
       `endif
     `endif

  task set_mpr_bytemask;
    input [7:0] bytemask;
    `ifdef VMM_VERIF
      `ifdef DDR3
        `ifndef SNPS_VIP  //SNPS_VIP
          sdram.mpr_bytemask = bytemask;
        `endif
      `endif
    `endif
  endtask
  
endmodule // ddr_sdram
