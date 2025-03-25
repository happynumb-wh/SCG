//-----------------------------------------------------------------------------
//
// Copyright (c) 2010 Synopsys Incorporated.				   
// 									   
// This file contains confidential, proprietary information and trade	   
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written	   
// permission of Synopsys Incorporated. 				   
// 
// DESCRIPTION: DDR PHY demonstration testcase
//-----------------------------------------------------------------------------
// PUB BIST Demo (demo_bist.v)
//-----------------------------------------------------------------------------
// This testcase demonstrates address/command (AC) BIST, data byte (DATX8) BIST
// loopback and DATX8 BIST DRAM operations.  Automatic triggering of read DQS 
// gate training is demonstrated for DATX8 BIST loopback mode.

`timescale 1ns/1fs

`default_nettype none  // turn off implicit data types

module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//
  localparam MIN_WCNT       = 2
  ,          MAX_WCNT       = 200
  ,          MIN_WAIT_CLK   = 100
  ,          MAX_WAIT_CLK   = 200
  ,          TOTAL_AC_PATTERN_WIDTH =   `PUB_ADDR_WIDTH          // LSB   a
                                      + `PUB_BANK_WIDTH          //       ba
                                      + (`DWC_NO_OF_RANKS * 2)   //       cs_b, cke
                                      + 1 + 1 + 1                //       we, cas, ras
                                      + `DWC_NO_OF_RANKS         //       odt
                                      + 1                        //       tpd
                                      + 1                        // MSB   par_in
  ;

  //--------------------------------------------------------------------------//
  //   R e g i s t e r    a n d    W i r e    D e c l a r a t i o n s
  //--------------------------------------------------------------------------//

  reg                           check_ac_lp;
  reg                           check_dx_lp;
  reg [`DWC_DATA_WIDTH*2  -1:0] exp_dq;
  reg [`DWC_NO_OF_BYTES*2 -1:0] exp_dm;
  integer                       output_pos;
  integer                       byte_idx;
  integer                       rnk;

  reg [4:0]                   pattern;         
  integer                     position;
  reg                         odd_last_pos;   // this is use to calculate the wrap around position if
                                              // TOTAL_AC_PATTERN_WIDTH is odd
  reg                         skip;           // skip check for word count

  reg [8                -1:0] msbyte_udq_bytemask = 8'hff;

  reg [`PUB_ADDR_WIDTH-1:0]   exp_a;
  reg [`PUB_BANK_WIDTH-1:0]   exp_ba;
  reg                         exp_we_b;
  reg                         exp_cas_b;
  reg                         exp_ras_b;
  reg [`DWC_NO_OF_RANKS-1:0]  exp_cs_b;
  reg [`DWC_NO_OF_RANKS-1:0]  exp_odt;
  reg [`DWC_NO_OF_RANKS-1:0]  exp_cke;
  reg                         exp_tpd;
  reg                         exp_par_in;

  integer                     iolb;
  reg                         tst_ck;
  reg                         gen_mask;
  reg [15:0]                  udp_dq_odd;
  reg [15:0]                  udp_dq_even;

  reg [TOTAL_AC_PATTERN_WIDTH-1:0]  exp_ac_bist;
  reg [TOTAL_AC_PATTERN_WIDTH-1:0]  prev_raw_ac;

  reg                               dfiout_rnd_en;
  wire                              pub_mode_exit_sdr;



  //--------------------------------------------------------------------------//
  //   I n c l u d e    C o m m o n    F u n c t i o n s / T a s k s
  //--------------------------------------------------------------------------//
  `include "bist_common.v"

  //--------------------------------------------------------------------------//
  //   T e s t b e n c h    I n s t a n t i a t i o n
  //--------------------------------------------------------------------------//
  ddr_tb ddr_tb();

  //--------------------------------------------------------------------------//
  //   T e s t    S t i m u l u s
  //--------------------------------------------------------------------------//

  initial begin
     // Workaround race condition with initial block from system.v
    #1;

    // Randomize DFI signals at start-up
    dfiout_rnd_en   = 0;
    `DFI.randomize_dfi_outputs;
    dfiout_rnd_en   = 1;
    
   // Initialization
    `SYS.disable_signal_probing = 1;
    `SYS.disable_ctrl_addr_pulse_width_checks;
    `SYS.disable_tpdmax_checks;

    // this testcase will set its own training
    `SYS.rdimm_auto_train_en    = 1'b0;

`ifdef DWC_SERIAL_DDL_CAL         
    // this shorten the pgcr1.fdepth = 2'b00
    `SYS.shorten_ddl_cal = 1'b1;
`endif
    
    `SYS.power_up;

    // BIST AC mode
    $display("%0t [DEBUG] start ac_loopback_test()", $time);

    ac_loopback_test;

    // BIST DX Loopback mode
    $display("%0t [DEBUG] start dx_test(1)", $time);


    dx_test(1);

    `ifdef DWC_LOOP_BACK
      $display("-> %0t: [BENCH] Skipping DX DRAM tests since loopback mode is enabled...", $time);
    `else
      // Power Down for RDIMM and no RDIMM runs
      // before doing PHY reset, enter SRE mode for DRAM.
      for(rnk = 0; rnk < `DWC_NO_OF_RANKS; rnk = rnk + 1) begin
        `HOST.nops(10);
        `HOST.power_down(rnk);
      end

      repeat (10) @(posedge `PUB.ctl_clk);

      // Another powerup to reset 
      `SYS.power_up;

      // BIST DX DRAM mode
      $display("%0t [DEBUG] start dx_test(0)", $time);
      dx_test(0);
    `endif
 
    `END_SIMULATION;
      
  end

  // Whenever we're in pub_mode, drive the DFI to random
  always @(posedge `PUB.pub_mode) begin
    if (dfiout_rnd_en) begin
      `HOST.nops(10);
      @(negedge `PUB.ctl_clk);
      `DFI.randomize_dfi_outputs;
    end
  end

  // As soon as we exit pub_mode, drive DFI to something reasonable
  `ifdef DWC_DDRPHY_HDR_MODE
    always @(negedge `PUB.u_DWC_ddrphy_scheduler.pub_mode) begin
      if (dfiout_rnd_en) begin
//         @(negedge `PUB.ctl_clk);
        `DFI.set_dfi_outputs(`DFI.pDFI_DFLT_VAL);
      end
    end
  `else
    // In SDR mode, we have to drive commands 1 cycle earlier because
    // the last two commands will get sent out on the next HDR cycle
    assign pub_mode_exit_sdr =   `PUB.u_DWC_ddrphy_scheduler.pub_init 
                               | `PUB.u_DWC_ddrphy_scheduler.dram_init 
                               | `PUB.u_DWC_ddrphy_scheduler.phy_train 
                               | `PUB.u_DWC_ddrphy_scheduler.bist_mode 
                               | `PUB.u_DWC_ddrphy_scheduler.dcu_mode 
                               | `PUB.u_DWC_ddrphy_scheduler.stop_on_perr 
                               | `PUB.u_DWC_ddrphy_scheduler.dl_osc_mode 
                               | `PUB.u_DWC_ddrphy_scheduler.wl_sw_mode;

    always @(negedge pub_mode_exit_sdr) begin
      if (dfiout_rnd_en) begin
        @(negedge `PUB.ctl_sdr_clk);
        `DFI.set_dfi_outputs(`DFI.pDFI_DFLT_VAL);
      end
    end
  `endif

  //--------------------------------------------------------------------------//
  //                                T A S K S
  //--------------------------------------------------------------------------//

  //--------------------------------------------------------------------------
  // Basic AC BIST (loopback)
  //--------------------------------------------------------------------------
  task ac_loopback_test();

      reg  [5        - 1 : 0] pattern;
      reg  [16       - 1 : 0] ac_wcnt;
      reg  [16       - 1 : 0] dx_wcnt;
      integer                 total_pattern_width;
      integer                 count;
      integer                 tmp_count;
      reg                     iolb;
      reg                     lbdqss;
      reg  [2        - 1 : 0] lbgdqs;
      integer                 pattern_idx;
      reg  [5        - 1 : 0] ac_pattern [0 : 9];

    begin
      // AC Patterns
      ac_pattern[0] = 5'd0;
      ac_pattern[1] = 5'd1;
      ac_pattern[2] = 5'd2;
      ac_pattern[3] = 5'd3;
      ac_pattern[4] = 5'd12;
      ac_pattern[5] = 5'd13;
      ac_pattern[6] = 5'd14;
      ac_pattern[7] = 5'd15;
      ac_pattern[8] = 5'd17;
      ac_pattern[9] = 5'd21;

      // Power Down for RDIMM and no RDIMM runs
      // before doing PHY reset, enter SRE mode for DRAM.
      for(rnk = 0; rnk < `DWC_NO_OF_RANKS; rnk = rnk + 1) begin
        `HOST.nops(10);
        `HOST.power_down(rnk);
      end
      
      repeat (10) @(posedge `PUB.ctl_clk);

      // To prevent SDRAM from complaining with a DDR2-type preamble used in 
      // DDR3 during loopback, disconnect the SDRAMs
      $display("-> %0t: [BENCH] ac_loopback_test(), disconnect all SDRAMS", $time);
      `SYS.disconnect_all_sdrams;

      //------------------------------------------------------------------------
      // Configure loopback

      iolb   = 1'b1;          // Loopback is before output buffer
      lbdqss = `LB_DQSS_AUTO; // Read DQS shift is automatically done by PUB (shift is cleared)
      lbgdqs = `LB_GDQS_ON;   // Don't need to train the gate for AC BIST
      $display ("-> %0t: [BENCH]", $time);
      $display ("-> %0t: [BENCH] -------------------- AC LOOPBACK CONFIGURATION ----------------------", $time);
      $display ("-> %0t: [BENCH] IOLB = %0d (%0s)   LBDQSS = %0d (%0s)   LBGDQS = %0d (%0s)", $time, iolb, string_iolb(iolb), lbdqss, string_lbdqss(lbdqss), lbgdqs, string_lbgdqs(lbgdqs));
      $display ("-> %0t: [BENCH]", $time);
      `SYS.configure_loopback(iolb, lbdqss, lbgdqs);

      // Do not power down receiver for par_in if loopback is from after the output buffer
      if (iolb == 1'b0) begin
        `GRM.rdimmgcr0[16] = 1'b0;
        @(posedge `CFG.clk);
        `CFG.write_register(`RDIMMGCR0,`GRM.rdimmgcr0);      
      end
      
      //------------------------------------------------------------------------
      // Random AC pattern
    
      pattern_idx = {$random(`SYS.seed)} % 10;
      pattern     = ac_pattern[pattern_idx];
      $display ("-> %0t: [BENCH] BISTRR in AC LOOPBACK Mode with pattern  %0d on AC", $time, pattern);
      // When running with pseudo random pattern, there might be warnings all over the place..
      // Temporarily disable ddr_mnt.mnt_en
      if (pattern == `PUB_DATA_LFSR) begin
        `SYS.random_bistlsr;
        `SYS.disable_all_rank_monitors;
        `SYS.disable_undefined_warning;
      end

      //------------------------------------------------------------------------
      // Set up number of word to generate

      ac_wcnt    = 128;
      ac_wcnt[0] = 0;  // Ensure word count is an even number of words
      dx_wcnt    = 0;
      `SYS.set_bist_wc(ac_wcnt);
      set_default_mask;

      //------------------------------------------------------------------------
      // Trigger BIST engine

      `SYS.set_bist_run(`BIST_RUN,           // Start BIST engine
                        `BIST_LPBK_MODE,     // Loopback mode
                        0,                   // Don't run infinitely
                        0,                   // Stop on first failure
                        1,                   // Enable stop on nth failure
                        0,                   // Don't run DX BIST
                        1,                   // Do run AC BIST
                        0,                   // Don't compare DM field (it's AC BIST)
                        pattern,             // BIST data pattern
                        0,                   // DX Byte-lane selected for DX BIST
                        `DWC_AC_CK0_PNUM,    // CK[] bit used to latch AC loopback signals
                        0                    // Data beat to capture/compare
                       );

      // Poll BIST Status register
      `CFG.poll_register(`BISTGSR, 0, 0, 1'b1, 100, 1000, "BIST done...");

      
      //------------------------------------------------------------------------
      // Check Status: BISTGSR, BISTWCSR, BISTWER, BISTBER0-2, BISTFWR0-1

      `GRM.bistgsr[2:0] = 3'b001;          // No BDXERR, NO BACERR, BDONE asserted
      `GRM.bistwcsr = {dx_wcnt, ac_wcnt};
      `GRM.bistwer0 = 32'b0;
      `GRM.bistwer1 = 32'b0;
      `GRM.bistber0 = 32'b0;
      `GRM.bistber1 = 32'b0;
      `GRM.bistber2 = 32'b0;
      `GRM.bistber3 = 32'b0;
      `GRM.bistber5 = 32'b0;
      `GRM.bistfwr0 = 32'b0;
      `GRM.bistfwr1 = 32'b0;
      `GRM.bistfwr2 = 32'b0;

      `CFG.read_register(`BISTGSR);
      `CFG.read_register(`BISTWCSR);
      `CFG.read_register(`BISTWER0);
      `CFG.read_register(`BISTWER1);
      `CFG.read_register(`BISTBER0);
      `CFG.read_register(`BISTBER1);
      `CFG.read_register(`BISTBER2);
      `CFG.read_register(`BISTBER3);
      `CFG.read_register(`BISTBER5);
      `CFG.read_register(`BISTFWR0);
      `CFG.read_register(`BISTFWR1);
      `CFG.read_register(`BISTFWR2);

      //------------------------------------------------------------------------
      // Reset BIST

      $display ("\n-> %0t: [BENCH] BISTRR in RESET Mode", $time);
      `SYS.set_bist_run(`BIST_RESET, `BIST_LPBK_MODE, 0, 0, 0, 0, 0, 0, 0, 0, `DWC_AC_CK0_PNUM, 0);
      repeat (10) @(posedge `PUB.ctl_clk);

      //------------------------------------------------------------------------
      // Reset AC

      `SYS.phy_fifo_reset;
      repeat (10) @(posedge `PUB.ctl_clk);

      //------------------------------------------------------------------------
      // Clean-up

      // Reconnect back the sdram if disconnected before
      if (pattern == `PUB_DATA_LFSR) begin
        `SYS.enable_all_rank_monitors;
        `SYS.enable_undefined_warning;
      end
        
      repeat (10) @(posedge `PUB.ctl_clk);

      // Reconnect all sdram
      $display("-> %0t: [BENCH] ac_loopback_test(), connect all SDRAMS", $time);
      `SYS.connect_all_sdrams;

      repeat (10) @(posedge `PUB.ctl_clk);

      // Power Down for RDIMM and no RDIMM runs
      // before doing PHY reset, enter SRE mode for DRAM.
      for(rnk = 0; rnk < `DWC_NO_OF_RANKS; rnk = rnk + 1) begin
        `HOST.nops(10); 
        `HOST.exit_power_down(rnk);
      end

      repeat (200) @(posedge `PUB.ctl_clk);
    end
  endtask

  //--------------------------------------------------------------------------
  // Basic DX BIST
  //--------------------------------------------------------------------------
  task dx_test;
    input  reg  loopback_en;

           reg [4             :0 ] pattern;
           integer                 lane_i;
           reg [16        - 1 : 0] ac_wcnt;
           reg [16        - 1 : 0] dx_wcnt;
           reg                     dx_mode;
           reg                     iolb;
           reg                     lbdqss;
           reg [2         - 1 : 0] lbgdqs;
           reg                     lb_gdqs_trn;
           reg [32        - 1 : 0] tmp;
    
    begin
      
      //------------------------------------------------------------------------
      // To prevent SDRAM from complaining with a DDR2-type preamble used in 
      // DDR3 during loopback, disconnect the SDRAMs

      if (loopback_en) begin
        $display("-> %0t: [BENCH] dx_test(%0d), disconnect all SDRAMS", $time, loopback_en);
        `SYS.disconnect_all_sdrams;
      end

      //------------------------------------------------------------------------
      // Turn off read leveling (run after basic gate training) to speed up
      // simulation.  Also read leveling should not be run when training
      // with an extended gate (e.g. in LPDDRX modes).

      $display("-> %0t: [BENCH] dx_test(%0d), disable read-leveling to speed up gate training ", $time, loopback_en);
      `GRM.dtcr1[1] = 1'b0;
      `CFG.write_register(`DTCR1, `GRM.dtcr1);

      //------------------------------------------------------------------------
      // Setup DX loopback mode

      if (loopback_en) begin
        // Randomly select pad-side or core-side loopback
        iolb   = {$random(`SYS.seed)} % 2;
        // Read DQS shift is automatically done by PUB (shift is cleared)
        lbdqss = `LB_DQSS_AUTO;
        // Randomly select either always-on gate or gate training (triggered by BIST)
        lb_gdqs_trn = {$random(`SYS.seed)} % 2;
        lbgdqs      = {1'b0, lb_gdqs_trn};

        // Required when the gate is always-on
        if (lbgdqs == `LB_GDQS_ON) begin
          // Switch to dynamic loading for DDLs to ensure we have the 90 degree
          // shift on DQS even when we don't have true RD transactions
          `GRM.pgcr4[20:16] = 5'b1_1111;
          @(posedge `CFG.clk);
          $display ("-> %0t: [BENCH] Switching to dynamic loading for DDLs", $time);
          `CFG.write_register(`PGCR4,`GRM.pgcr4);

          // Required for DDR4
          for (byte_idx = 0; byte_idx < `DWC_NO_OF_BYTES; byte_idx = byte_idx + 1) begin
            // DXPDRMODE 00==PDR dynamic, 01==PDR always on, 10==PDR always off
            `GRM.dxngcr1[byte_idx][31:16] = {8{2'b00}};
            $display ("-> %0t: [BENCH] Setting DXnGCR1.DXPDRMODE for byte-lane %0d", $time, byte_idx);
            `CFG.write_register(`DX0GCR1 + (`DX_REG_RANGE * byte_idx), `GRM.dxngcr1[byte_idx]);
            // x4 mode
            `ifdef DWC_DDRPHY_X4MODE
              `GRM.dxngcr7[byte_idx][11:10] = 2'b00;
              $display ("-> %0t: [BENCH] Setting DXnGCR7.X4DXPDRMODE for byte-lane %0d", $time, byte_idx);
              `CFG.write_register((`DX0GCR7 + (`DX_REG_RANGE * byte_idx)), `GRM.dxngcr7[byte_idx]);
            `endif

            `GRM.dxngcr3[byte_idx][ 3: 2] = 2'b10;  // DSPDRMODE 00==PDR dynamic, 01==PDR always on, 10==PDR always off
            `GRM.dxngcr3[byte_idx][ 5: 4] = 2'b10;  // DSTEMODE  00==TE  dynamic, 01==TE  always on, 10==TE  always off
            `GRM.dxngcr3[byte_idx][ 7: 6] = 2'b01;  // DSOEMODE  00==OE  dynamic, 01==OE  always on, 10==OE  always off
            $display ("-> %0t: [BENCH] Setting DXnGCR3.DSPDRMODE/DSTEMODE/DSOEMODE for byte-lane %0d", $time, byte_idx);
            `CFG.write_register((`DX0GCR3 + (`DX_REG_RANGE * byte_idx)), `GRM.dxngcr3[byte_idx]);
            // x4 mode
            `ifdef DWC_DDRPHY_X4MODE
              `GRM.dxngcr7[byte_idx][ 3: 2] = 2'b10;  // DSPDRMODE 00==PDR dynamic, 01==PDR always on, 10==PDR always off
              `GRM.dxngcr7[byte_idx][ 5: 4] = 2'b10;  // DSTEMODE  00==TE  dynamic, 01==TE  always on, 10==TE  always off
              `GRM.dxngcr7[byte_idx][ 7: 6] = 2'b01;  // DSOEMODE  00==OE  dynamic, 01==OE  always on, 10==OE  always off
              $display ("-> %0t: [BENCH] Setting DXnGCR7.X4DSPDRMODE/X4DSTEMODE/X4DSOEMODE for byte-lane %0d", $time, byte_idx);
              `CFG.write_register((`DX0GCR7 + (`DX_REG_RANGE * byte_idx)), `GRM.dxngcr7[byte_idx]);
            `endif
          end
          // Allow time for the register updates to take place (cross clock domains)
          repeat (5) @(posedge `CFG.clk);
        end

        `SYS.configure_loopback(iolb, lbdqss, lbgdqs);
        $display ("-> %0t: [BENCH]", $time);
        $display ("-> %0t: [BENCH] -------------------- DX LOOPBACK CONFIGURATION ----------------------", $time);
      end

      //------------------------------------------------------------------------
      // Setup DX DRAM mode

      else begin
        iolb   = 1'b0;
        `GRM.pgcr1[31] = 1'b0;
        `CFG.write_register(`PGCR1, `GRM.pgcr1);
        $display ("-> %0t: [BENCH]", $time);
        $display ("-> %0t: [BENCH] ---------------------- DX DRAM CONFIGURATION ------------------------", $time);
      end

      $display ("-> %0t: [BENCH] IOLB = %0d (%0s)   LBDQSS = %0d (%0s)   LBGDQS = %0d (%0s)", $time, iolb, string_iolb(iolb), lbdqss, string_lbdqss(lbdqss), lbgdqs, string_lbgdqs(lbgdqs));
      $display ("-> %0t: [BENCH]", $time);

      //------------------------------------------------------------------------
      // Setup for DX DRAM mode
      `ifndef DWC_STATIC_RD_RESPP
        if (!loopback_en) begin
          `GRM.dtcr0[6] = 1'b1; // use mpr
          `CFG.write_register(`DTCR0, `GRM.dtcr0);
          repeat (5) @(posedge `CFG.clk); 
       
          // configure DQS gate extension for lpddr2/3
          `ifdef LPDDR2
            `GRM.dsgcr[7:6] = 2'b10;
            `CFG.write_register(`DSGCR, `GRM.dsgcr);
            repeat (5) @(posedge `CFG.clk); 
          `elsif LPDDR3
            `GRM.dsgcr[7:6] = 2'b11;
            `CFG.write_register(`DSGCR, `GRM.dsgcr);
            repeat (5) @(posedge `CFG.clk); 
          `endif
  
          `ifdef DDR3
            `GRM.pir[9]  = 1'b1;    // Do write-leveling (DDR3)
            `GRM.pir[10] = 1'b1;    // Read DQS gate training
          `elsif DDR4
            `GRM.pir[9]  = 1'b1;    // Do write-leveling (DDR4)
            `GRM.pir[10] = 1'b1;    // Read DQS gate training
          `elsif LPDDR3
            `GRM.pir[9]  = 1'b1;    // Do write-leveling (LPDDR3)
            `GRM.pir[10] = 1'b1;    // Read DQS gate training for LPDDR3
          `else
            `GRM.pir[9]  = 1'b0;
            `GRM.pir[10] = 1'b0;    // No Read DQS gate training for LPDDR2
          `endif    
  
          `ifdef DDR3
            `GRM.pir[11] = 1'b1; // Write-leveling adjustment (DDR3 only)
          `elsif DDR4
            `GRM.pir[11] = 1'b1; // Write-leveling adjustment (DDR4 only)
          `elsif LPDDR3
            `GRM.pir[11] = 1'b1; // Write-leveling adjustment (LPDDR3 only)
          `else
            `GRM.pir[11] = 1'b0;
          `endif
          `GRM.pir[0] = 1'b1;
          `CFG.write_register(`PIR, `GRM.pir);
           repeat (5) @(posedge `CFG.clk);
  
          // setting expected state in GRM
          `GRM.pgsr0[4] = 1'b1;
          `ifndef LPDDR2
            `GRM.pgsr0[23:21] = 3'b000;
            `GRM.pgsr0[7:5]   = 3'b111;
          `endif
  
          `CFG.poll_register(`PGSR0, 0, 0, 1'b1,  100, 1000000, "init done...");
  
          `CFG.disable_read_compare;
          `CFG.read_register_data(`PGSR0, tmp);
          
          `ifdef LPDDR2
            // no training for LPDDR2; just for dram init done
            if (!tmp[4]) begin
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: Expect PGSR0 [4] = %0h got %0h", $time, `TRUE, tmp[4]);
            end
          `else 
            // WL, RDQS Gate and WLA train for all other modes done with no errors
            if (tmp[23:21] != 3'b000 || tmp[7:5] != 3'b111) begin
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: Expect PGSR0 [23:21] = %0h got %0h", $time, 3'b000, tmp[23:21]);
              $display("-> %0t: [SYSTEM] ERROR: Expect PGSR0 [7:5]   = %0h got %0h", $time, 3'b111, tmp[7:5]);
            end
          `endif 

          repeat (10) @(posedge `CFG.clk);
          `CFG.enable_read_compare;
          repeat (10) @(posedge `CFG.clk);

        end
      `endif 

      //------------------------------------------------------------------------
      // Set up a walking 1 pattern on byte-lane 0
      pattern =  {$random(`SYS.seed)} % 24;
      lane_i  = 0;
      if (loopback_en)
        $display ("-> %0t: [BENCH] DX LOOPBACK mode on lane %0d with pattern %0d", $time, lane_i, pattern);
      else
        $display ("-> %0t: [BENCH] DX DRAM mode on lane %0d with pattern %0d", $time, lane_i, pattern);
      if (pattern == `PUB_DATA_LFSR)
        `SYS.random_bistlsr;

      //------------------------------------------------------------------------
      // Set up number of word to generate

      dx_wcnt = 128;
      ac_wcnt = 0;
      `SYS.set_bist_wc(dx_wcnt);
      
      //------------------------------------------------------------------------
      // Setup addresses for DRAM mode

      if (!loopback_en) begin
        `SYS.set_bistar0(3'b001, 16'h0100, 12'h010); // bbank, brow, bcol
`ifdef RDIMM_SINGLE_RANK
   `ifdef BL_4
        `SYS.set_bistar1(12'h008, 2'b01, 2'b00);     // bainc, bmrank, brank 
   `else
        `SYS.set_bistar1(12'h010, 2'b01, 2'b00);     // bainc, bmrank, brank
   `endif 
`else
        `SYS.set_bistar1(12'h008, 2'b01, 2'b01);     // bainc, bmrank, brank 
`endif
        `SYS.set_bistar2(3'b001, 16'h00FF, 12'hFFF); // bmbank, bmrow, bmcol
        //`SYS.set_bistudpr(random_16b(0), random_16b(0)); // User Data pattern 
      end

      //------------------------------------------------------------------------
      // Mask off DM if DWC_DDRPHY_DMDQS_MUX and X4 mode where DM is not available
      if (`GRM.dxccr[31:30] === 2'b10)
        `SYS.set_bistmskr1(4'b1111, 4'd0, 8'd0, 8'd0, 3'd0, 1'b0, 4'b1111);

      //------------------------------------------------------------------------
      // Issue refresh for SDRAM mode, this is to organize when to do refresh
      // between MCTL and HOST in order to avoid getting tRFC_min violation
      if (!loopback_en) begin
        if (`MCTL.rfsh_prd_cntr_en && `MCTL.rfsh_prd_cntr > `tRFC_min) begin
          `HOST.refresh;
          repeat (`tRFC_min) @(posedge `SYS.clk);
        end
        else begin
          // wait for refresh to be triggered by mctl first, then wait for
          // tRFC_min before starting BIST
          if (`MCTL.rfsh_prd_cntr_en && `MCTL.rfsh_prd_cntr <= `tRFC_min) begin
            wait (`MCTL.rfsh_cmd);
            repeat (`tRFC_min+10) @(posedge `SYS.clk);
          end
        end
      end
        
      //------------------------------------------------------------------------
      // Trigger BIST engine

      dx_mode = loopback_en ? `BIST_LPBK_MODE : `BIST_DRAM_MODE;
      `SYS.set_bist_run(`BIST_RUN,           // Start BIST engine
                        dx_mode,             // Loopback or DRAM mode
                        0,                   // Don't run infinitely
                        0,                   // Stop on first failure
                        1,                   // Enable stop on nth failure
                        1,                   // Do run DX BIST
                        0,                   // Don't run AC BIST
                        0,                   // Don't compare DM field (it's AC BIST)
                        pattern,             // BIST data pattern
                        lane_i,              // DX Byte-lane selected for DX BIST
                        0,                   // CK[] bit used to latch AC loopback signals
                        0                    // Data beat to capture/compare
                       );

      // Poll BIST Status register
`ifdef LPDDR3

      `CFG.poll_register(`BISTGSR, 0, 0, 1'b1, 100, 100000, "BIST done...");
`else

      `CFG.poll_register(`BISTGSR, 0, 0, 1'b1, 100, 50000, "BIST done...");
`endif

`ifdef DWC_DDRPHY_USE_JTAG
      // move the exit power down eariler, read register might take too long...
      clean_up(loopback_en);
`endif
      //------------------------------------------------------------------------
      // Check Status: BISTGSR, BISTWCSR, BISTWER, BISTBER0-2, BISTFWR0-1

      `GRM.bistgsr[2:0] = 3'b001;         // No BDXERR, NO BACERR, BDONE asserted
      `GRM.bistwcsr = {dx_wcnt, ac_wcnt};
      `GRM.bistwer0 = 32'b0;
      `GRM.bistwer1 = 32'b0;
      `GRM.bistber0 = 32'b0;
      `GRM.bistber1 = 32'b0;
      `GRM.bistber2 = 32'b0;
      `GRM.bistfwr0 = 32'b0;
      `GRM.bistfwr1 = 32'b0;

      `CFG.read_register(`BISTGSR);
      `CFG.read_register(`BISTWCSR);
      `CFG.read_register(`BISTWER0);
      `CFG.read_register(`BISTWER1);
      `CFG.read_register(`BISTBER0);
      `CFG.read_register(`BISTBER1);
      `CFG.read_register(`BISTBER2);
      `CFG.read_register(`BISTBER3);
      `CFG.read_register(`BISTBER5);
      `CFG.read_register(`BISTFWR0);
      `CFG.read_register(`BISTFWR1);
      `CFG.read_register(`BISTFWR2);

      //------------------------------------------------------------------------
      // Reset BIST

      $display ("\n-> %0t: [BENCH] BISTRR in RESET Mode", $time);
      `SYS.set_bist_run(`BIST_RESET, `BIST_LPBK_MODE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      repeat (10) @(posedge `PUB.ctl_clk);

      //------------------------------------------------------------------------
      // Reset AC

      `SYS.phy_fifo_reset;
`ifndef DWC_DDRPHY_USE_JTAG
      repeat (10) @(posedge `PUB.ctl_clk);
`else 
      repeat (100) @(posedge `PUB.ctl_clk);
`endif
      
      //------------------------------------------------------------------------
      // Clean-up
`ifndef DWC_DDRPHY_USE_JTAG
      clean_up(loopback_en);
`else
      // wait for any writes to finish
      repeat (60) @(posedge `SYS.xclk);      
`endif
      
    end
  endtask

  //--------------------------------------------------------------------------
  // Clean up
  //--------------------------------------------------------------------------
  task clean_up;
    input reg loopback_en;

    begin
      // Disable loopback mode
      if (loopback_en) begin
        `GRM.pgcr1[31] = 1'b0;
        `CFG.write_register(`PGCR1, `GRM.pgcr1);

        // waiting refresh command to be finished before reconected sdram 
        // to aviod violation issue becuase of having recieved refresh command when the SDRAM is reconnected  
        if (`MCTL.rfsh_cmd);
        repeat (`tRFC_min+15) @(posedge `SYS.clk);

        // Reconnect all sdrams
        $display("-> %0t: [BENCH] dx_test(%0d), connect all SDRAMS", $time, loopback_en);
        `SYS.connect_all_sdrams;
      end

      repeat (200) @(posedge `PUB.ctl_clk);
    end
  endtask // clean_up

  //--------------------------------------------------------------------------
  //                          F U N C T I O N S
  //--------------------------------------------------------------------------

  function [(10 * 8) - 1 : 0] string_iolb;
    input reg     iolb_value;

          reg [(10 * 8)    - 1 : 0] str_desc;

    begin
      casez (iolb_value)
        1'b0 : str_desc   = "Pad-side";
        1'b1 : str_desc   = "Core-side";
        default: str_desc = "UNKNOWN";
      endcase
      string_iolb = str_desc;
    end
  endfunction

  function [(15 * 8) - 1 : 0] string_lbdqss;
    input reg     lbdqss_value;

          reg [(15 * 8)    - 1 : 0] str_desc;

    begin
      casez (lbdqss_value)
        1'b0 : str_desc   = "PUB RDQS delay";
        1'b1 : str_desc   = "S/w RDQS delay";
        default: str_desc = "UNKNOWN";
      endcase
      string_lbdqss = str_desc;
    end
  endfunction

  function [(15 * 8) - 1 : 0] string_lbgdqs;
    input reg [2   - 1 : 0] lbgdqs_value;

          reg [(15 * 8)    - 1 : 0] str_desc;

    begin
      casez (lbgdqs_value)
        2'd0 : str_desc   = "Gate always on";
        2'd1 : str_desc   = "Gate training";
        2'd2 : str_desc   = "S/w set gate";
        2'd3 : str_desc   = "RESERVED";
        default: str_desc = "UNKNOWN";
      endcase
      string_lbgdqs = str_desc;
    end
  endfunction

endmodule

`default_nettype wire  // restore implicit data types

