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
// VT Drift With Update Demo (demo_vt_upd.v)
//-----------------------------------------------------------------------------
// The testcase demonstrates VT compensation by changing the delay characteristics 
// (PVT scale) of the delay lines.  The delay lines are initially set with 
// random PVT scales and then calibrated during PHY initialization.  The PVT 
// scales are then changed, VT update is issued, and it is verified that the VT
// compensation correctly adjusts the settings of the delay lines.
//
module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//
  localparam                  NO_OF_ACCESSES = 3,
                              INIT_ADDR      = 0;
  
  //--------------------------------------------------------------------------//
  //   R e g i s t e r    a n d    W i r e    D e c l a r a t i o n s
  //--------------------------------------------------------------------------//

  reg [`ADDR_WIDTH-1:0]       addr, addr1;
  reg [`ADDR_WIDTH-1:0]       init_waddr;
  reg [`ADDR_WIDTH-1:0]       row_inc;
  reg [`BANK_WIDTH-1:0]       init_bank;

  reg [1:0]                   rank, rank1;
  reg [`SDRAM_BANK_WIDTH-1:0] bank;
  reg [`SDRAM_ROW_WIDTH-1:0]  row;
  reg [`SDRAM_COL_WIDTH-1:0]  col;
  reg [31:0]                  tmp;

  integer                     i, j;
  integer                     bank_no;
  integer                     b2b_accesses;

  real                        temp;
  reg                         trig_vt_upd;
  real                        last_pick_pvt_multiplier;
  
  //--------------------------------------------------------------------------//
  //   T e s t b e n c h    I n s t a n t i a t i o n
  //--------------------------------------------------------------------------//
  ddr_tb ddr_tb();

  //--------------------------------------------------------------------------//
  //   T e s t    S t i m u l u s
  //--------------------------------------------------------------------------//
  initial
    begin
      // This testcase verifies vt compensation by forcing on AC and DX LCDL and BDL models
      // all the pvtscale.
      // 1. The testcase begins with a random setting of pvtscale from a range of 0.7 to 1.3
      //    which is forced into all the LCDL and BDL models. The default pvtscale is 1.0
      // 2. Then allow the system to power up and finished the Initialization sequence
      // 3. The random pvtscale values is now calibrated.
      // 4. Then enter the main vt drift loop which will
      //       - force a new pvt_multiplier that is multiplied onto the pvtscale
      //         (use 0.8 or 1.2).
      //       - update the following GRM registers: ACMDLR, DXnMDLR, DXnLCDLR0, DXnLCDLR1, 
      //         DXnLCDLR2, DXnGSR0, ACBDLR0-9, DXnBDLR0-6 with the expected new multiplier factor being
      //         incorporated into the initial as well as the targert periods.
      //       - wait for 20 dx_mdl_cal_update (VT compensation is on by default)
      //       - Check the mdl calibrated results by reading the above registers which will
      //         be compared with the GRM internal data. When reading the registers,
      //         skip the irrelevent bits, focusing only on the initial and target bits.
      //       - issue dx_vt_update_req from system. This would cause vt compensated results
      //         or written delay registers to be loaded onto the LCDL and BDL Delay registers.
      //
      
      last_pick_pvt_multiplier = 1.0;
      #1;

      `SYS.enable_mdlen = 1'b1;
      `SYS.disable_clock_checks;
      `SYS.disable_dq_setup_hold_checks;
      `SYS.disable_dqs_ck_setup_hold_checks;
      `SYS.disable_cmd_addr_timing_checks;
      `SYS.disable_refresh_check;
      // when tc does PIR[0] init again to calibrate the DDL's, the CK will become erratic. this will
      // make tck_avg in the DDR2 model become a small value and cause tIPW checks on subsequent refreshes
      // to fail.
      `SYS.disable_ctrl_addr_pulse_width_checks;

      // this testcase will set its own training
      `SYS.rdimm_auto_train_en    = 1'b0;
      
`ifdef DWC_PLL_BYPASS
          // Don't run the testcase in PLL bypass because the frequency is very low and VT drift is
          // not allowed because DDLs won't calibrate
`else
      fork
        begin
          // initialization
          `SYS.power_up;
          
          // override the rfsh generation from ddr_mctl by disabling DRR register in ddr_grm
          `GRM.drr[31] = 1'b0;
          `GRM.write_controller_register(`DRR, `GRM.drr);
          
// Removing this.  There is no need to retrigger DDL calibration after power_up() since power_up() does DDL calibration.
/*
          // re-trigger initial calibration
          `GRM.pir[31:0] = 32'b0;
          `GRM.pir[0] = 1'b1;
          `GRM.pir[5] = 1'b1;
          @(posedge `CFG.clk);
          `CFG.write_register(`PIR, `GRM.pir);
          `CFG.nops(100);
          `CFG.poll_register(`PGSR0, 0, 0, 1'b1, 100, 10000, "PHY initialization done...");
*/
          `SYS.train_dx_lcdl_wl(`TRUE,8'hxx);              // set random DL value for DXnLCDLR0.RWLD/X4WLD

          `SYS.disable_clock_checks;                       // don't check during change the ACBDL value, there are 'X' for some time when wating phy reaction 
         `ifdef LPDDR3
          // for LPDDR3, need to check if we're running 1.6Gpbs (800MHz), if so then, we need to cap
          // the max BDL's to be ~< 170ps because the 1/4 shift from ACLCDLR (312.5ps) + > 170ps BDL values
          // can cause tIH or tIS violations in the LPDDR3 memory model.
          if(`CLK_PRD == 1.25)
            `SYS.train_ac_bdl_reg(`TRUE,5'hxx,5'h0F);       // set random DL value for ACBDLR(0-9) (but max value of 'hf)
          else
            // for non-1.6Gbps speed bins, randomize the BDL values
            `SYS.train_ac_bdl_reg(`TRUE,5'hxx,5'h1F);            // set random DL value for ACBDLR(0-9) and DXnBDLR(0-6) 
         `else
          // for DDR3/2, LPDDR2, randomize the BDL values
            `SYS.train_ac_bdl_reg(`TRUE,5'hxx,5'h1F);              // set random DL value for ACBDLR(0-9) and DXnBDLR(0-6) 
         `endif
          `SYS.enable_clock_checks;

          `SYS.train_dx_bdl_reg(`TRUE,5'hxx);              // set random DL value for ACBDLR(0-9) and DXnBDLR(0-6) 
          `SYS.train_dx_lcdl_rdqs_wdqs(`TRUE,8'hxx,8'hxx); // set random DL value for DXnLCDLR1/4/5.WDQD and RDQSD
          `SYS.train_dqs_gate(`TRUE);                      // set random DL value for DXnLCDLR2.R(0-3)DQSGD
        end

        // setup for initial pvt values to be forced into all LCDL
        begin
          @(`SYS.e_sys_reset_done);

          `PHYSYS.init_random_pvt;
          -> `PHYSYS.e_force_initial_pvt;
          
          // this is to update ddr_grm that new pvt values are used.
          `SYS.force_pvt_in_progress = 1'b1;
          
        end
      join


      // Set PTR calibration tCALON, tCALS, tCALH longer to try and catch the calibrated values.
      `SYS.RANDOM_RANGE(`SYS.seed, 4'h8, 4'hA, tmp);
      `GRM.ptr2[4:0]  = tmp;
      `GRM.ptr2[9:5]  = tmp;
      `GRM.ptr2[14:10] = tmp;
      @(posedge `CFG.clk);
      `CFG.write_register(`PTR2, `GRM.ptr2);
      `CFG.nops(4);
      
      repeat (10) @ (posedge `SYS.clk);

      // Setup the DFI block updates
      // PUREN bit 0 to disable PHY update request, this bit will be turn on later
      // in order to control when PHY sent out the request. The testcase will check
      // lcdl values before and after the update.        
      tmp    = `GRM.dsgcr;
      tmp[2] = $random(`SYS.seed) % 2;
      tmp[5] = $random(`SYS.seed) % 2;
      tmp[0] = 1'b0;
      `CFG.write_register(`DSGCR, tmp);
      repeat (500) @(posedge `CFG.clk);

      // randomly pick a multiplier to be either greater or less than 1
      if ($random(`SYS.seed)%2)
        `PHYSYS.pvt_multiplier = 0.8;
      else
        `PHYSYS.pvt_multiplier = 1.2;
 
      $display("-> %0t: [BENCH] ------------ Check GSR0 and GSR4 here first  ------------",$time);
       
  //          `PHYSYS.check_DXnGSR0(`FALSE);
  //          `PHYSYS.check_DXnGSR4(`FALSE);
      last_pick_pvt_multiplier = `PHYSYS.pvt_multiplier;
      
      $display("-> %0t: [BENCH] ------------ Drift pvtscale on all lcdl  ------------",$time);
      $display("-> %0t: [BENCH] ------------ PVT MULTIPLIER = %0f       ------------",$time, `PHYSYS.pvt_multiplier);

      -> `PHYSYS.e_force_pvt_with_multipler;
      repeat (10) @ (posedge `SYS.clk);

      
      `PHYSYS.update_mdl_only_new_multp;
      repeat (10) @ (posedge `SYS.clk);

      $display("-> %0t: [BENCH] ------------ Wait for VT COMP ----------",$time);
      fork
        begin: WAIT_VT_DRIFT_LOOP
          wait ( (|`PHYSYS.ac_vt_drift) | (|`PHYSYS.dx_vt_drift));
          $display("-> %0t: [BENCH] vt drift detected...", $time);          
        end

        begin: WAIT_FOR_MDL_CAL_UPDATE  
          // probe into the rtl code to get check for several loops of mdl calibration
          $display("-> %0t: [BENCH] WAIT for MDL CAL UPDATE...", $time);
          repeat (20) @(posedge (|(`PUB.dx_mdl_cal_update)));
          $display("-> %0t: [BENCH] MDL CAL UPDATE DONE!!", $time);
          disable TIMEOUT_VT_DRIFT_WAIT;
          disable WAIT_VT_DRIFT_LOOP;
        end

        begin: TIMEOUT_VT_DRIFT_WAIT
          repeat (400000) @ (posedge `SYS.clk);
          disable WAIT_VT_DRIFT_LOOP;
          disable WAIT_FOR_MDL_CAL_UPDATE;            
          `SYS.error;
          $display("-> %0t: [BENCH] ERROR: TIMEOUT on WAIT FOR VT_DRIFT", $time);
        end
      join
      
      // Check after forcing pvtscale with multiplier the register contents
      // first time around, all calibrated values will be from calibration, then
      // after the first iteration, the previous written random data will be read
      repeat (10) @ (posedge `CFG.clk);
      $display("-> %0t: [BENCH] ------------ Check LCDL BDL reg after VT COMP ----------",$time);

      `PHYSYS.check_ACMDLR(`FALSE);

      // for DXnMDLR, after checking with the expected value, if descrepancy is
      // less than 1, then use the read value as the actual_pvt_multiplier ratio 
      `PHYSYS.check_DXnMDLR(`FALSE, `TRUE);    // set_init_values, set_actual_multi_ratio

      `PHYSYS.update_all_lane_new_multp_vt_upd;

      `PHYSYS.check_DXnGSR0(`FALSE);
      `PHYSYS.check_DXnLCDLR0(`FALSE);
      `PHYSYS.check_DXnLCDLR2(`FALSE);

      `PHYSYS.check_ACBDLR0(`FALSE);
      `PHYSYS.check_ACBDLR1(`FALSE);
      `PHYSYS.check_ACBDLR2(`FALSE);
      `PHYSYS.check_ACBDLR3(`FALSE);
      `PHYSYS.check_ACBDLR4(`FALSE);
      `PHYSYS.check_ACBDLR5(`FALSE);
      `PHYSYS.check_ACBDLR6(`FALSE);
      `PHYSYS.check_ACBDLR7(`FALSE);
      `PHYSYS.check_ACBDLR8(`FALSE);
      `PHYSYS.check_ACBDLR9(`FALSE);
 
      `PHYSYS.check_DXnBDLR0(`FALSE);
      `PHYSYS.check_DXnBDLR1(`FALSE);
      `PHYSYS.check_DXnBDLR2(`FALSE);
      `PHYSYS.check_DXnBDLR3(`FALSE);
      `PHYSYS.check_DXnBDLR4(`FALSE);
      `PHYSYS.check_DXnBDLR5(`FALSE);
      `PHYSYS.check_DXnBDLR6(`FALSE);

 
          `ifdef DWC_DDRPHY_X4MODE
       
            `PHYSYS.check_DXnGSR4(`FALSE);
            `PHYSYS.check_DXnBDLR7(`FALSE);
            `PHYSYS.check_DXnBDLR8(`FALSE);
            `PHYSYS.check_DXnBDLR9(`FALSE);
          `endif //  `ifdef DWC_DDRPHY_X4MODE
       
       

      $display("-> %0t: [BENCH] ------------ Send VT Update Request  ----------",$time);

      fork
        begin: SEND_VT_UPD_REQUEST
          // PHY initiate vt update request...
          `GRM.dsgcr[0] = 1'b1;    // PUREN bit 0
          `CFG.write_register(`DSGCR, `GRM.dsgcr);
          repeat (500) @(posedge `CFG.clk);        
        end
        
        begin: CHECK_PHY_UPD_REQ_VT_DRIFT_DEASSERT
          // vt_drift would trigger dfi phy ctl to send out request
          `ifdef DWC_USE_SHARED_AC_TB     
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_req[1:0] == %b",$time,2'b11); 
          wait (`TB.dfi_phyupd_req[1:0] == 2'b11);
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_ack[1:0] == %b",$time,2'b11); 
          wait (`TB.dfi_phyupd_ack[1:0] == 2'b11);
          `else         
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_req == 1",$time); 
          wait (`TB.dfi_phyupd_req[0] == 1'b1);
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_ack == 1",$time);          
          wait (`TB.dfi_phyupd_ack[0] == 1'b1);
          `endif
          
          $display("-> %0t: [BENCH] waiting for vt update == 1", $time);

         `ifdef DWC_USE_SHARED_AC_TB
          wait (`PHYDFI.vt_update == 2'b11);
          wait (`PUB.dx_vt_update_req === {{`TB.pCHN1_DX8_NUM{1'b1}},{`TB.pCHN0_DX8_NUM{1'b1}}});
         `else
          wait (`PHYDFI.vt_update[0] == 1'b1); 
          wait (`PUB.dx_vt_update_req === {`DWC_NO_OF_BYTES{1'b1}});
          `endif

          // Wait for phy upd request to be deasserted
          `ifdef DWC_USE_SHARED_AC_TB
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_req[1:0] == 2'b00",$time);          
          wait (`TB.dfi_phyupd_req[1:0] == 2'b00);
 
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_ack == 0",$time);          
          wait (`TB.dfi_phyupd_ack[1:0] == 2'b00);
          `else
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_req == 0",$time);          
          wait (`TB.dfi_phyupd_req[0] == 1'b0);
 
          $display("-> %0t: [BENCH] waiting for dfi_phyupd_ack == 0",$time);          
          wait (`TB.dfi_phyupd_ack[0] == 1'b0);
          `endif

          $display("-> %0t: [BENCH] waiting for vt update == 0",$time);
          `ifdef DWC_USE_SHARED_AC_TB
          wait (`PHYDFI.vt_update == 2'b00);
         `else
          wait (`PHYDFI.vt_update == 1'b0);
          `endif

          // vt drift should be deasserted
          //wait (`PHYSYS.vt_drift == {`DWC_NO_OF_BYTES{1'b0}});
          wait ({`PHYSYS.ac_vt_drift,`PHYSYS.dx_vt_drift} == {`DWC_NO_OF_BYTES{1'b0}}); 
         
          // remove vt_update request
          repeat (10) @ (posedge `CFG.clk);
          
          // PHY turn off vt update request...
          `GRM.dsgcr[0] = 1'b0;    // PUREN bit 0
          `GRM.dsgcr[5] = 1'b0;
          `CFG.write_register(`DSGCR, `GRM.dsgcr);
          repeat (500) @(posedge `CFG.clk);                
        end
      join      
      
      `PHYSYS.store_last_pvt_multiplier;
      `PHYSYS.update_all_lane_new_multp_vt_upd;
      repeat (20) @ (posedge `CFG.clk);
      $display("-> %0t: [BENCH] ------------ Check LCDL BDL reg after VT COMP and VT UPDATE ----------",$time);

      `PHYSYS.check_ACMDLR(`FALSE);
      `PHYSYS.check_ACBDLR1(`FALSE);
      `PHYSYS.check_ACBDLR2(`FALSE);
      `PHYSYS.check_ACBDLR3(`FALSE);
      `PHYSYS.check_ACBDLR4(`FALSE);
      `PHYSYS.check_ACBDLR5(`FALSE);
      `PHYSYS.check_ACBDLR6(`FALSE);
      `PHYSYS.check_ACBDLR7(`FALSE);
      `PHYSYS.check_ACBDLR8(`FALSE);
      `PHYSYS.check_ACBDLR9(`FALSE);

      // no need to assert set_actual_pvt_multi_ratio again
      `PHYSYS.check_DXnMDLR(`FALSE,`FALSE);
      
      `PHYSYS.check_DXnGSR0(`FALSE);
      `PHYSYS.check_DXnLCDLR0(`FALSE);
      `PHYSYS.check_DXnLCDLR2(`FALSE);
      
      `PHYSYS.check_ACBDLR0(`FALSE);
      `PHYSYS.check_DXnBDLR0(`FALSE);
      `PHYSYS.check_DXnBDLR1(`FALSE);
      `PHYSYS.check_DXnBDLR2(`FALSE);
      `PHYSYS.check_DXnBDLR3(`FALSE);
      `PHYSYS.check_DXnBDLR4(`FALSE);
      `PHYSYS.check_DXnBDLR5(`FALSE);
      `PHYSYS.check_DXnBDLR6(`FALSE);
          `ifdef DWC_DDRPHY_X4MODE
            `PHYSYS.check_DXnGSR4(`FALSE);
            
            `PHYSYS.check_DXnBDLR7(`FALSE);
            `PHYSYS.check_DXnBDLR8(`FALSE);
            `PHYSYS.check_DXnBDLR9(`FALSE);

         `endif
         
      `GRM.read_register_for_vt_drift_fcov(); 
`endif // !`ifdef DWC_PLL_BYPASS
      
      `END_SIMULATION;
    end // initial begin

endmodule // tc
