/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Module related to the VT compensation trigger and checkers    *
 *              for the TB environment                                        *
 *                                                                            *
 *****************************************************************************/

`timescale 1ns/100fs

module phy_system ();

  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  localparam pLCDL_DLY_WIDTH  = `LCDL_DLY_WIDTH;
  localparam pBDL_DLY_WIDTH   = `BDL_DLY_WIDTH;
  localparam pDEFAULT_DDL_STEP_SIZE = 0.005;

  localparam BDL_MAX       = 6'h3F;
  localparam BDL_MIN       = 6'h00;
  localparam LCDL_MAX      = {pLCDL_DLY_WIDTH{1'b1}};
  localparam LCDL_MIN      = {pLCDL_DLY_WIDTH{1'b0}};
  localparam NXT_LCDL_MAX  = {pLCDL_DLY_WIDTH+1{1'b1}};
  localparam NXT_LCDL_MIN  = {pLCDL_DLY_WIDTH+1{1'b0}}; 
  localparam pNO_OF_DQS    = `DWC_DX_NO_OF_DQS;
   localparam pNUM_LANES    = pNO_OF_DQS*`DWC_NO_OF_BYTES ;
   

  // DXNGSR0
  localparam pWLPRD_FROM_BIT    = 7; 
  localparam pWLPRD_WIDTH       = pLCDL_DLY_WIDTH;
  localparam pWLPRD_TO_BIT      = pWLPRD_WIDTH-1   + pWLPRD_FROM_BIT;
  localparam pGDQSPRD_FROM_BIT  = 17; 
  localparam pGDQSPRD_WIDTH     = pLCDL_DLY_WIDTH;
  localparam pGDQSPRD_TO_BIT    = pGDQSPRD_WIDTH-1 + pGDQSPRD_FROM_BIT;

  // DXnLCDLR0-1
  localparam pWLD_WIDTH          = pLCDL_DLY_WIDTH;
  localparam pX4WLD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pR0WLD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pR1WLD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pWLD_FROM_BIT       = 0; 
  localparam pX4WLD_FROM_BIT     = 16; 
  localparam pR0WLD_FROM_BIT     = 0; 
  localparam pR1WLD_FROM_BIT     = 16; 
  localparam pR0WLD_TO_BIT       = pR0WLD_WIDTH-1   + pR0WLD_FROM_BIT; 
  localparam pR1WLD_TO_BIT       = pR1WLD_WIDTH-1   + pR1WLD_FROM_BIT; 
  localparam pWLD_TO_BIT         = pWLD_WIDTH-1   + pWLD_FROM_BIT; 
  localparam pX4WLD_TO_BIT       = pX4WLD_WIDTH-1   + pX4WLD_FROM_BIT; 
  
  localparam pR2WLD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pR3WLD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pR2WLD_FROM_BIT     = 0; 
  localparam pR3WLD_FROM_BIT     = 16; 
  localparam pR2WLD_TO_BIT       = pR2WLD_WIDTH-1   + pR2WLD_FROM_BIT; 
  localparam pR3WLD_TO_BIT       = pR3WLD_WIDTH-1   + pR3WLD_FROM_BIT; 
    
  // DXnLCDLR2-3
  localparam pGDQSD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pX4GDQSD_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pR0GDQSD_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pR1GDQSD_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pGDQSD_FROM_BIT     = 0; 
  localparam pX4GDQSD_FROM_BIT   = 16; 
  localparam pR0GDQSD_FROM_BIT   = 0; 
  localparam pR1GDQSD_FROM_BIT   = 16; 
  localparam pR0GDQSD_TO_BIT     = pR0GDQSD_WIDTH-1   + pR0GDQSD_FROM_BIT;
  localparam pR1GDQSD_TO_BIT     = pR1GDQSD_WIDTH-1   + pR1GDQSD_FROM_BIT;
  localparam pGDQSD_TO_BIT       = pGDQSD_WIDTH-1   + pGDQSD_FROM_BIT;
  localparam pX4GDQSD_TO_BIT     = pX4GDQSD_WIDTH-1   + pX4GDQSD_FROM_BIT;


  localparam pR2GDQSD_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pR3GDQSD_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pR2GDQSD_FROM_BIT   = 0; 
  localparam pR3GDQSD_FROM_BIT   = 16; 
  localparam pR2GDQSD_TO_BIT     = pR2GDQSD_WIDTH-1   + pR2GDQSD_FROM_BIT;
  localparam pR3GDQSD_TO_BIT     = pR3GDQSD_WIDTH-1   + pR3GDQSD_FROM_BIT;
  
 // DXnLCDLR4-5                       
  localparam pRDQSD_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pRDQSND_WIDTH       = pLCDL_DLY_WIDTH;
  localparam pX4RDQSD_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pX4RDQSND_WIDTH     = pLCDL_DLY_WIDTH;
  localparam pRDQSD_FROM_BIT     = 0; 
  localparam pRDQSND_FROM_BIT    = 0; 
  localparam pX4RDQSD_FROM_BIT   = 16; 
  localparam pX4RDQSND_FROM_BIT  = 16; 
  localparam pRDQSD_TO_BIT       = pRDQSD_WIDTH-1   + pRDQSD_FROM_BIT; 
  localparam pRDQSND_TO_BIT      = pRDQSND_WIDTH-1  + pRDQSND_FROM_BIT; 
  localparam pX4RDQSD_TO_BIT     = pX4RDQSD_WIDTH-1   + pX4RDQSD_FROM_BIT; 
  localparam pX4RDQSND_TO_BIT    = pX4RDQSND_WIDTH-1  + pX4RDQSND_FROM_BIT; 


  localparam pWDQD_WIDTH         = pLCDL_DLY_WIDTH;
  localparam pGSDQS_WIDTH        = pLCDL_DLY_WIDTH;
  localparam pWDQD_FROM_BIT      = 0; 
  localparam pGSDQS_FROM_BIT     = 0; 
  localparam pWDQD_TO_BIT        = pWDQD_WIDTH-1    + pWDQD_FROM_BIT; 
  localparam pGSDQS_TO_BIT       = pGSDQS_WIDTH-1  + pGSDQS_FROM_BIT; 
  localparam pX4WDQD_WIDTH       = pLCDL_DLY_WIDTH;
  localparam pX4GSDQS_WIDTH      = pLCDL_DLY_WIDTH;
  localparam pX4WDQD_FROM_BIT    = 16; 
  localparam pX4GSDQS_FROM_BIT   = 16; 
  localparam pX4WDQD_TO_BIT      = pX4WDQD_WIDTH-1    + pX4WDQD_FROM_BIT; 
  localparam pX4GSDQS_TO_BIT     = pX4GSDQS_WIDTH-1  + pX4GSDQS_FROM_BIT; 
  
 // DXnMDLR0                      
  localparam pDXnMDLR0_IPRD_WIDTH = pLCDL_DLY_WIDTH;
  localparam pDXnMDLR0_TPRD_WIDTH = pLCDL_DLY_WIDTH;
  localparam pDXIPRD_FROM_BIT     = 0;
  localparam pDXTPRD_FROM_BIT     = 16;
  localparam pDXIPRD_TO_BIT       = pDXnMDLR0_IPRD_WIDTH-1   + pDXIPRD_FROM_BIT;
  localparam pDXTPRD_TO_BIT       = pDXnMDLR0_TPRD_WIDTH-1   + pDXTPRD_FROM_BIT;

  // DXnMDLR1                      
  localparam pDXnMDLR1_MDLD_WIDTH = pLCDL_DLY_WIDTH;
  localparam pDXMDLD_FROM_BIT     = 0;
  localparam pDXMDLD_TO_BIT       = pDXnMDLR1_MDLD_WIDTH-1   + pDXMDLD_FROM_BIT;

  // PGCR1
  localparam pPGCR1_DLDLMT_WIDTH = 8;
  localparam pPGCR1_DLDLMT_FROM_BIT = 15;
  localparam pPGCR1_DLDLMT_TO_BIT = pPGCR1_DLDLMT_WIDTH-1 + pPGCR1_DLDLMT_FROM_BIT;

  localparam pNO_OF_LRANKS        = `DWC_NO_OF_LRANKS;   //Number of logical ranks
  localparam pNO_OF_PRANKS        = `DWC_NO_OF_RANKS;    //Number of physical ranks
  localparam pNO_OF_TRANKS        = `DWC_NO_OF_TRANKS;  
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire [`DWC_NO_OF_BYTES-1:0]   dx_vt_drift;
  wire                          ac_vt_drift;

  real                         dx_mdl_vt_drift_diff   [0:`DWC_NO_OF_BYTES-1];
  integer                      dx_mdl_actual_vt_drift_diff   [0:`DWC_NO_OF_BYTES-1];
  

  integer                      verbose;
  integer                      pvt_debug;    initial pvt_debug = 2;
  integer                      pvt_detail_debug; initial pvt_detail_debug = 4;
  integer                      i;


  real                         last_pvt_multiplier;
  real                         pvt_multiplier;
  real                         x_multiplier;
  real                         prev_actual_pvt_multiplier [0:8];
  real                         last_actual_pvt_multiplier [0:8];
  real                         actual_pvt_multiplier      [0:8];
  //  reg  force_pvt_in_progress;
  real                         rounding;

  event                        e_force_initial_pvt;
  event                        e_force_pvt_with_multipler;
  event                        e_force_GDQS_pvt_with_x_multipler;

  real                         ddl_step_size;
  real                         default_ddl_step_size;
  event                        e_set_ddl_step_size;

  genvar                       dwc_byte;
   integer                        x4mode;

   
  
  //---------------------------------------------------------------------------
  // initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize
      integer i;

      verbose               = 10;
      last_pvt_multiplier   = 1.0;
      pvt_multiplier        = 1.0;
      x_multiplier          = 1.0;
      ddl_step_size         = pDEFAULT_DDL_STEP_SIZE; // default is 5 ps.
      default_ddl_step_size = pDEFAULT_DDL_STEP_SIZE; // default is 5 ps.
      
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        prev_actual_pvt_multiplier[i]   = 1.0;
        last_actual_pvt_multiplier[i]   = 1.0;
        actual_pvt_multiplier[i]        = 1.0;
        dx_mdl_vt_drift_diff[i]         = 0.0;
        dx_mdl_actual_vt_drift_diff[i]  = 0;
      end
      
      //      force_pvt_in_progress = 1'b0;

      // OLD
      //rounding          = -0.5; // for pvtscale calculation, rounding off
      // verilog calculation will round up, PHYCTL logic will truncate

      // NEW: RTL code change. Do not add extra rounding.
      rounding          = 0; 
   
`ifdef DWC_DDRPHY_X4MODE
       x4mode = 1;
`else
       x4mode = 0;
`endif
       
     
    end // block: initialize

`ifndef DWC_DDRPHY_EMUL_XILINX
  assign dx_vt_drift = `PUB.dx_vt_drift;
  assign ac_vt_drift = `PUB.ac_vt_drift;
`endif
  
  // This task is to check the lcdl period settings for DXnMDLR1, DXnLCDLR1, DXnGSR0
  // after calibration is properly done and not because of phy init bypass or
  // calibration bypass.
   task check_calibrated_values;
      input set_init_value;
      begin
         check_ACMDLR(set_init_value);
         check_DXnMDLR (set_init_value,`TRUE);
         check_DXnLCDLR4(set_init_value);
         check_DXnLCDLR5(set_init_value);
         check_DXnGSR0(set_init_value);
         check_DXnLCDLR0(set_init_value);
         check_DXnLCDLR1(set_init_value);
         check_DXnLCDLR2(set_init_value);
         check_DXnLCDLR3(set_init_value);
         check_DXnLCDLR4(set_init_value);
         check_DXnLCDLR5(set_init_value);
         `ifdef DWC_DDRPHY_X4MODE
              check_DXnGSR4(set_init_value);
         `endif
         
      end
   endtask // check_calibrated_values

  // check ACBDLR0 and DXnBDLR0-4
   task check_calibrated_bdl_values;
      input set_init_value;
      begin
         check_ACBDLR0(set_init_value);
         check_ACBDLR1(set_init_value);
         check_ACBDLR2(set_init_value);
         check_ACBDLR3(set_init_value);
         check_ACBDLR4(set_init_value);
         check_ACBDLR5(set_init_value);
         check_ACBDLR6(set_init_value);
         check_ACBDLR7(set_init_value);
         check_ACBDLR8(set_init_value);
         check_ACBDLR9(set_init_value);
         check_DXnBDLR0(set_init_value);
         check_DXnBDLR1(set_init_value);
         check_DXnBDLR2(set_init_value);
         check_DXnBDLR3(set_init_value);
         check_DXnBDLR4(set_init_value);
         check_DXnBDLR5(set_init_value);
         check_DXnBDLR6(set_init_value);
 
         `ifdef DWC_DDRPHY_X4MODE
         
         check_DXnBDLR7(set_init_value);
         check_DXnBDLR8(set_init_value);
         check_DXnBDLR9(set_init_value);
         `endif
      end
   endtask // check_calibrated_bdl_values


   task check_lcdl_bdl_reg;
      begin
         $display("-> %0t: [PHYSYS] Call `PHYSYS.check_{DXnLCDLR4-5,DXnGSR0,DXnLCDLR0-1,DXnLCDLR2-3}()",$time);
         `PHYSYS.check_DXnLCDLR4(`FALSE);
         `PHYSYS.check_DXnLCDLR5(`FALSE);
         `PHYSYS.check_DXnGSR0(`FALSE);
         `PHYSYS.check_DXnLCDLR0(`FALSE);
         `PHYSYS.check_DXnLCDLR1(`FALSE);
         `PHYSYS.check_DXnLCDLR2(`FALSE);
         `PHYSYS.check_DXnLCDLR3(`FALSE);

         $display("-> %0t: [PHYSYS] Call `PHYSYS.check_{ACBDLR0-9,DXnBDLR0-6}()",$time);
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
         $display("-> %0t: [PHYSYS] Call `PHYSYS.check_DXnGSR4()",$time);
         `PHYSYS.check_DXnGSR4(`FALSE);
         $display("-> %0t: [PHYSYS] Call `PHYSYS.check_{DXnBDLR7-9}()",$time);
         `PHYSYS.check_DXnBDLR7(`FALSE);
         `PHYSYS.check_DXnBDLR8(`FALSE);
         `PHYSYS.check_DXnBDLR9(`FALSE);
         `endif
      end
   endtask // check_lcdl_bdl_reg_after_vt_comp_upd
  
    
  task check_lcdl_bdl_reg_skip_dxngsr0;
    begin
        $display("-> %0t: [PHYSYS] Call `PHYSYS.check_{DXnLCDLR4-5,DXnLCDLR0-1,DXnLCDLR2-3}()",$time);
        `PHYSYS.check_DXnLCDLR4(`FALSE);
        `PHYSYS.check_DXnLCDLR5(`FALSE);
        //`PHYSYS.check_DXnGSR0(`FALSE);
        `PHYSYS.check_DXnLCDLR0(`FALSE);
        `PHYSYS.check_DXnLCDLR1(`FALSE);
        `PHYSYS.check_DXnLCDLR2(`FALSE);
        `PHYSYS.check_DXnLCDLR3(`FALSE);

        $display("-> %0t: [PHYSYS] Call `PHYSYS.check_{ACBDLR0-9,DXnBDLR0-6}()",$time);
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
       $display("-> %0t: [PHYSYS] Call `PHYSYS.check_{DXnBDLR7-9}()",$time);
       `PHYSYS.check_DXnBDLR7(`FALSE);
       `PHYSYS.check_DXnBDLR8(`FALSE);
       `PHYSYS.check_DXnBDLR9(`FALSE);
         `endif
    end
  
  endtask // check_lcdl_bdl_reg_after_vt_comp_upd
  
    

  task check_ACMDLR;
    input set_init_value;
    reg [31:0] tmp;
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;

      // 1) Check ACMDLR0; if PIR.MDLEN is off ACMDLR0 is not turned on
      //                   reads all zeros
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACMDLR0 <====== ",$time);
      `CFG.read_register_data(`ACMDLR0, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[0 +: `LCDL_DLY_WIDTH]  - `GRM.acmdlr0[0 +: `LCDL_DLY_WIDTH]);
      tmp_1 = `SYS.abs(tmp[16+: `LCDL_DLY_WIDTH]  - `GRM.acmdlr0[16+: `LCDL_DLY_WIDTH]);

      // NB: Allow target ratio to drift within 2, if more than that it should be an error.
      if ((tmp_0 > 2) || (tmp_1 > 2)) begin
        if (set_init_value) begin
          `GRM.acmdlr0[0 +: `LCDL_DLY_WIDTH] = tmp[0 +: `LCDL_DLY_WIDTH];
          `GRM.acmdlr0[16+: `LCDL_DLY_WIDTH] = tmp[16+: `LCDL_DLY_WIDTH];
          if (`GRM.acmdlr_tprd_value < {`LCDL_DLY_WIDTH{1'b1}})  `GRM.acmdlr_tprd_value = tmp[0 +: `LCDL_DLY_WIDTH];
          if (`GRM.acmdlr_iprd_value < {`LCDL_DLY_WIDTH{1'b1}})  `GRM.acmdlr_iprd_value = tmp[16+: `LCDL_DLY_WIDTH];
        end
        else begin
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACMDLR0 bits!!!",$time);
          $display("-> %0t: [SYSTEM] Expected acmdlr0[0 +: %0d] = %0h got %0h", $time, `LCDL_DLY_WIDTH, `GRM.acmdlr0[0 +: `LCDL_DLY_WIDTH], tmp[0 +: `LCDL_DLY_WIDTH]);
          $display("-> %0t: [SYSTEM] Expected acmdlr0[16+: %0d] = %0h got %0h", $time, `LCDL_DLY_WIDTH, `GRM.acmdlr0[16+: `LCDL_DLY_WIDTH], tmp[16+: `LCDL_DLY_WIDTH]);
        end
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acmdlr and acmdlr_iprd and acmdl_tprd) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acmdlr0[0 +: `LCDL_DLY_WIDTH] = tmp[0 +: `LCDL_DLY_WIDTH];
          `GRM.acmdlr0[16+: `LCDL_DLY_WIDTH] = tmp[16+: `LCDL_DLY_WIDTH];
          if (`GRM.acmdlr_tprd_value < {`LCDL_DLY_WIDTH{1'b1}})  `GRM.acmdlr_tprd_value = tmp[0 +: `LCDL_DLY_WIDTH];
          if (`GRM.acmdlr_iprd_value < {`LCDL_DLY_WIDTH{1'b1}})  `GRM.acmdlr_iprd_value = tmp[16+: `LCDL_DLY_WIDTH];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACMDLR

  task check_DXnMDLR;
    input set_init_value;
    input set_actual_pvt_multi_ratio;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;

      // 2) Check DXnMDLR0
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnMDLR0 <====== ",$time);

      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0MDLR0  +(i*`DX_REG_RANGE), tmp);
        // there might be a + or - 1 difference between the calculated
        // values with the PHYCTL register value (which truncates off)
        tmp_0 = `SYS.abs(tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]  - `GRM.dxnmdlr0[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]);
        tmp_1 = `SYS.abs(tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT] - `GRM.dxnmdlr0[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT]);

        // NB: Allow target ratio to drift within 3, if more than that it should be an error.
        if ((tmp_0 > 3) || (tmp_1 > 3)) begin
          if (set_init_value) begin
            `GRM.dxnmdlr0[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT] = tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT];
            `GRM.dxnmdlr0[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]  = tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT];
            if (`GRM.dxnmdlr_tprd_value[i] < LCDL_MAX)  `GRM.dxnmdlr_tprd_value[i] = tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT];
            if (`GRM.dxnmdlr_iprd_value[i] < LCDL_MAX)  `GRM.dxnmdlr_iprd_value[i] = tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT];
          end
          else begin
            `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on Dx%0dMDLR0 bits!!!",$time, i);
            $display("-> %0t: [SYSTEM] Expected dx%0dmdlr[%0d:%0d] = %0h got %0h", $time, i, pDXTPRD_TO_BIT, pDXTPRD_FROM_BIT, `GRM.dxnmdlr0[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT], tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT]);
            $display("-> %0t: [SYSTEM] Expected dx%0dmdlr[%0d:%0d] = %0h got %0h", $time, i, pDXIPRD_TO_BIT, pDXIPRD_FROM_BIT, `GRM.dxnmdlr0[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT], tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]);
            $display("-> %0t: [SYSTEM] dxnmdlr_tprd_value[%0d]  = %0f", $time, i,`GRM.dxnmdlr_tprd_value[i]);
            $display("-> %0t: [SYSTEM] dxnmdlr_iprd_value[%0d]  = %0f", $time, i,`GRM.dxnmdlr_iprd_value[i]);
          end
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnmdlr and dxnmdlr_iprd and dxnmdlr_tprd) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnmdlr0[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT] = tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT];
            `GRM.dxnmdlr0[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]  = tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT];
            if (`GRM.dxnmdlr_tprd_value[i] < LCDL_MAX)  `GRM.dxnmdlr_tprd_value[i] = tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT];
            if (`GRM.dxnmdlr_iprd_value[i] < LCDL_MAX)  `GRM.dxnmdlr_iprd_value[i] = tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT];
          end

          // after compared, the error offset should be within one tap for MDL
          // use this ratio instead of pvt_multiplier that was forced in the
          // testcase. (ie: the read value) 
          if (set_actual_pvt_multi_ratio) begin
            tmp_0 = (tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT] * 1.0);
            tmp_1 = (tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT] * 1.0);

            if (tmp_1 == 0)
              actual_pvt_multiplier[i] = 9999999;
            else
              if (tmp_0 == 0)
                actual_pvt_multiplier[i] = 0.000001;
              else
                actual_pvt_multiplier[i] = tmp_0/tmp_1;
            
            if (verbose > pvt_detail_debug) begin
              $display("-> %0t: [SYSTEM] dx%0dmdlr[%0d:%0d] = %0h", $time, i, pDXTPRD_TO_BIT, pDXTPRD_FROM_BIT, tmp[pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT]);
              $display("-> %0t: [SYSTEM] dx%0dmdlr[%0d:%0d] = %0h", $time, i, pDXIPRD_TO_BIT, pDXIPRD_FROM_BIT, tmp[pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]);
              $display("-> %0t: [SYSTEM] actual_pvt_multiplier[%0d] = %0f", $time, i, actual_pvt_multiplier[i]);
            end
            
          end
        end  // else begin (no error)

      end // for loop
      

      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnMDLR

  

  

  task check_DXnGSR0;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnGSR0 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        //  pll_lock comes in quite late and is independent of the calibration process
        //  use this following to check WLPRD   
        `CFG.read_register_data(`DX0GSR0+(i*`DX_REG_RANGE), tmp);

        tmp_0 = `SYS.abs(tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT]     - `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
        tmp_1 = `SYS.abs(tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT] - `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
        if ((tmp[4:0] != 5'b0000) ||
            (tmp_0 > 3)  ||
            (tmp_1 > 3) ) begin
          
          // allow initial value to be written to GRM at the beginning
          if (set_init_value) begin
            `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT] = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
            `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]     = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
            if (`GRM.gdqsprd_value[i] < LCDL_MAX)  `GRM.gdqsprd_value[i]  = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
            if (`GRM.wlprd_value[i]   < LCDL_MAX)  `GRM.wlprd_value[i]    = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
          end 
          else begin
            `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dGSR0 bits!!!",$time, i);
            $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pGDQSPRD_TO_BIT, pGDQSPRD_FROM_BIT, `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT], tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
            $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pWLPRD_TO_BIT, pWLPRD_FROM_BIT, `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT], tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
            $display("-> %0t: [SYSTEM] Expecting Q[4:0]  = %0h got %0h", $time, 5'b0000, tmp[4:0]);
          end
        end
        else begin
          if (verbose > pvt_detail_debug) begin
            $display("-> %0t: [SYSTEM] Read DX%0dGSR0  Q[%0d:%0d] = %0h",$time, i, pGDQSPRD_TO_BIT, pGDQSPRD_FROM_BIT, tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
            $display("-> %0t: [SYSTEM]                 Q[%0d:%0d] = %0h",$time   , pWLPRD_TO_BIT, pWLPRD_FROM_BIT, tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
            $display("-> %0t: [SYSTEM]                 Q[4:0]   = %0h",$time   , tmp[4:0]);
          end
          //  if no error; 
          //  Write measured value onto GRM (both dxngsr0 and wlprd_value and gdqsprd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT] = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
            `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]  = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
            if (`GRM.gdqsprd_value[i] < LCDL_MAX)  `GRM.gdqsprd_value[i]  = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
            if (`GRM.wlprd_value[i]   < LCDL_MAX)  `GRM.wlprd_value[i]    = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
          end            
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnGSR0
   
   task check_DXnGSR4;
      input set_init_value;
      reg [31:0] tmp;
      
      real       tmp_0;
      real       tmp_1;
      real       tmp_2;
      real       tmp_3;
      begin
         `CFG.disable_read_compare;
         
         if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnGSR4 <====== ",$time);
         for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
            //  pll_lock comes in quite late and is independent of the calibration process
            //  use this following to check WLPRD   
            `CFG.read_register_data(`DX0GSR4+(i*`DX_REG_RANGE), tmp);

            tmp_0 = `SYS.abs(tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT]     - `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
            tmp_1 = `SYS.abs(tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT] - `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
            if ((tmp[4:0] != 5'b0000) ||
                (tmp_0 > 3)  ||
                (tmp_1 > 3) ) begin
               
               // allow initial value to be written to GRM at the beginning
               if (set_init_value) begin
                  `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT] = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
                  `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]     = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
                  if (`GRM.x4gdqsprd_value[i] < LCDL_MAX)  `GRM.x4gdqsprd_value[i]  = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
                  if (`GRM.x4wlprd_value[i]   < LCDL_MAX)  `GRM.x4wlprd_value[i]    = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
               end 
               else begin
                  `SYS.error;
                  $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dGSR4 bits!!!",$time, i);
                  $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pGDQSPRD_TO_BIT, pGDQSPRD_FROM_BIT, `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT], tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
                  $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pWLPRD_TO_BIT, pWLPRD_FROM_BIT, `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT], tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
                  $display("-> %0t: [SYSTEM] Expecting Q[4:0]  = %0h got %0h", $time, 5'b0000, tmp[4:0]);
               end
            end
            else begin
               if (verbose > pvt_detail_debug) begin
                  $display("-> %0t: [SYSTEM] Read DX%0dGSR4  Q[%0d:%0d] = %0h",$time, i, pGDQSPRD_TO_BIT, pGDQSPRD_FROM_BIT, tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
                  $display("-> %0t: [SYSTEM]                 Q[%0d:%0d] = %0h",$time   , pWLPRD_TO_BIT, pWLPRD_FROM_BIT, tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
                  $display("-> %0t: [SYSTEM]                 Q[4:0]   = %0h",$time   , tmp[4:0]);
               end
               //  if no error; 
               //  Write measured value onto GRM (both dxngsr4 and wlprd_value and gdqsprd_value) for future calculation
               //  this is mainly to be used by force pvt multiplier testcases
               if (set_init_value) begin
                  `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT] = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
                  `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]  = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
                  if (`GRM.x4gdqsprd_value[i] < LCDL_MAX)  `GRM.x4gdqsprd_value[i]  = tmp[pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT];
                  if (`GRM.x4wlprd_value[i]   < LCDL_MAX)  `GRM.x4wlprd_value[i]    = tmp[pWLPRD_TO_BIT:pWLPRD_FROM_BIT];
               end            
            end
         end
         
         repeat (10) @(posedge `CFG.clk);
         `CFG.enable_read_compare;
         repeat (10) @(posedge `CFG.clk);

      end
   endtask // check_DXnGSR4
  

  task check_DXnLCDLR4;
    input set_init_value;
    reg [31:0]  tmp;
    integer rank_id; 
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      // 3) Check DXnLCDLR4 registers 
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnLCDLR4 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
            `GRM.rankidr[16 +: 4] = rank_id;
            @(posedge `CFG.clk);
            `CFG.write_register(`RANKIDR, `GRM.rankidr);
             repeat (`DWC_AFIFO_SYNC_STAGES +4) @(posedge `CFG.clk);
            `CFG.read_register_data(`DX0LCDLR4+(i*`DX_REG_RANGE), tmp);
            tmp_1 = `SYS.abs(tmp[pRDQSND_TO_BIT:pRDQSND_FROM_BIT] - `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT]);
            if ((tmp_1 > 1)) begin  
          
            `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on rank %d DX%0dLCDLR4 bits!!!",$time, rank_id, i);
            $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pRDQSND_TO_BIT, pRDQSND_FROM_BIT, `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT], tmp[pRDQSND_TO_BIT:pRDQSND_FROM_BIT]);
            end
            else begin
              //  if no error; 
              //  Write measured value onto GRM (both dxnlcdlr4 and rdqsd_value, rdqsnd_value) for future calculation
              //  this is mainly to be used by force pvt multiplier testcases
              if (set_init_value) begin
                `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT] = tmp[pRDQSND_TO_BIT:pRDQSND_FROM_BIT];
                if (`GRM.rdqsnd_value[rank_id][i] < LCDL_MAX) `GRM.rdqsnd_value[rank_id][i] = (tmp[pRDQSND_TO_BIT:pRDQSND_FROM_BIT] - rounding) * 2.0;  // to compensate for the rounding effect
              end
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
               tmp_1 = `SYS.abs(tmp[pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT] - `GRM.dxnlcdlr4[rank_id][i][pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT]);
               if ((tmp_1 > 1)) begin  
          
               `SYS.error;
               $display("-> %0t: [SYSTEM] ERROR: CHECKING X4 CALIBRATED VALUES FAILED on rank %d DX%0dLCDLR4 bits!!!",$time, rank_id, i);
               $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pX4RDQSND_TO_BIT, pX4RDQSND_FROM_BIT, `GRM.dxnlcdlr4[rank_id][i][pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT], tmp[pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT]);
               end
                else begin
                  //  if no error; 
                  //  Write measured value onto GRM (both dxnlcdlr4 and rdqsd_value, rdqsnd_value) for future calculation
                  //  this is mainly to be used by force pvt multiplier testcases
                  if (set_init_value) begin
                    `GRM.dxnlcdlr4[rank_id][i][pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT] = tmp[pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT];
                    if (`GRM.x4rdqsnd_value[rank_id][i] < LCDL_MAX) `GRM.x4rdqsnd_value[rank_id][i] = (tmp[pX4RDQSND_TO_BIT:pX4RDQSND_FROM_BIT] - rounding) * 2.0;  // to compensate for the rounding effect
                  end
                end
            end
               
         end
      end      
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnLCDLR4

  
  task check_DXnLCDLR5;
    input set_init_value;
    reg [31:0]  tmp;
    integer rank_id;
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      // 3) Check DXnLCDLR5 registers 
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnLCDLR5 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
          `GRM.rankidr[16 +: 4] = rank_id;
          @(posedge `CFG.clk);
          `CFG.write_register(`RANKIDR, `GRM.rankidr);
          repeat (`DWC_AFIFO_SYNC_STAGES +4) @(posedge `CFG.clk);
          `CFG.read_register_data(`DX0LCDLR5+(i*`DX_REG_RANGE), tmp);
          tmp_1 = `SYS.abs(tmp[pGSDQS_TO_BIT:pGSDQS_FROM_BIT] - `GRM.dxnlcdlr5[rank_id][i][pGSDQS_TO_BIT:pGSDQS_FROM_BIT]);
          if ((tmp_1 > 1)) begin  
            
            `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on rank %d DX%0dLCDLR5 bits!!!",$time, rank_id,i);
            $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pGSDQS_TO_BIT, pGSDQS_FROM_BIT, `GRM.dxnlcdlr5[rank_id][i][pGSDQS_TO_BIT:pGSDQS_FROM_BIT], tmp[pGSDQS_TO_BIT:pGSDQS_FROM_BIT]);
            
          end
          else begin
            //  if no error; 
            //  Write measured value onto GRM (both dxnlcdlr5 and wdqd_value, rdqsgs_value) for future calculation
            //  this is mainly to be used by force pvt multiplier testcases
            if (set_init_value) begin
              `GRM.dxnlcdlr5[rank_id][i][pGSDQS_TO_BIT:pGSDQS_FROM_BIT] = tmp[pGSDQS_TO_BIT:pGSDQS_FROM_BIT];
              if (`GRM.rdqsgs_value[rank_id][i] < LCDL_MAX) `GRM.rdqsgs_value[rank_id][i] = (tmp[pGSDQS_TO_BIT:pGSDQS_FROM_BIT] - rounding) * 2.0;  // to compensate for the rounding effect
            end
          end
          if ( `DWC_DX_NO_OF_DQS == 2) begin
            tmp_1 = `SYS.abs(tmp[pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT] - `GRM.dxnlcdlr5[rank_id][i][pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT]);
            if ((tmp_1 > 1)) begin  
              
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: CHECKING X4 CALIBRATED VALUES FAILED on DX%0dLCDLR5 bits!!!",$time, i);
              $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pX4GSDQS_TO_BIT, pX4GSDQS_FROM_BIT, `GRM.dxnlcdlr5[rank_id][i][pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT], tmp[pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT]);
            end
            else begin
              //  if no error; 
              //  Write measured value onto GRM (both dxnlcdlr5 and wdqd_value, rdqsgs_value) for future calculation
              //  this is mainly to be used by force pvt multiplier testcases
              if (set_init_value) begin
                `GRM.dxnlcdlr5[rank_id][i][pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT] = tmp[pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT];
                if (`GRM.x4rdqsgs_value[rank_id][i] < LCDL_MAX) `GRM.x4rdqsgs_value[rank_id][i] = (tmp[pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT] - rounding) * 2.0;  // to compensate for the rounding effect
              end
            end
          end
        end // for (rank_id = 0; rank_id < `DWC_NO_OF_RANKS; rank_id = rank_id + 1)
      end // for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnLCDLR5

  
  task check_DXnLCDLR0;
    input set_init_value;
    reg [31:0]  tmp;
    integer rank_id; 
    real tmp_0;
    real tmp_1;

    begin
      `CFG.disable_read_compare;
      
      // 4) Check LCDL registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnLCDLR0 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
            `GRM.rankidr[16 +: 4] = rank_id;
            @(posedge `CFG.clk);
            `CFG.write_register(`RANKIDR, `GRM.rankidr);
            repeat (`DWC_AFIFO_SYNC_STAGES +4) @(posedge `CFG.clk);
            `CFG.read_register_data(`DX0LCDLR0+(i*`DX_REG_RANGE), tmp);
            tmp_0 = `SYS.abs(tmp[pWLD_TO_BIT:pWLD_FROM_BIT] - `GRM.dxnlcdlr0[rank_id][i][pWLD_TO_BIT:pWLD_FROM_BIT]);
            
            if (tmp_0 > 1) begin
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dLCDLR0 bits for rank %0d!!!",$time, i, rank_id);
              $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pWLD_TO_BIT, pWLD_FROM_BIT, `GRM.dxnlcdlr0[rank_id][i][pWLD_TO_BIT:pWLD_FROM_BIT], tmp[pWLD_TO_BIT:pWLD_FROM_BIT]);
            end
            else begin
              //  if no error; 
              //  Write measured value onto GRM (both dxnlcdlr0 and r(0-3)wld_value) for future calculation
              //  this is mainly to be used by force pvt multiplier testcases
              if (set_init_value) begin
                `GRM.dxnlcdlr0[rank_id][i][pWLD_TO_BIT:pWLD_FROM_BIT]   = tmp[pWLD_TO_BIT:pWLD_FROM_BIT];
                if (`GRM.wld_value[rank_id][i] < LCDL_MAX)  `GRM.wld_value[rank_id][i] = tmp[pWLD_TO_BIT:pWLD_FROM_BIT];
              end
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                tmp_0 = `SYS.abs(tmp[pX4WLD_TO_BIT:pX4WLD_FROM_BIT] - `GRM.dxnlcdlr0[rank_id][i][pX4WLD_TO_BIT:pX4WLD_FROM_BIT]);
                if (tmp_0 > 1) begin
                  `SYS.error;
                  $display("-> %0t: [SYSTEM] ERROR: CHECKING X4 CALIBRATED VALUES FAILED on DX%0dLCDLR0 bits!!!",$time, i);
                  $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pX4WLD_TO_BIT, pX4WLD_FROM_BIT, `GRM.dxnlcdlr0[rank_id][i][pX4WLD_TO_BIT:pX4WLD_FROM_BIT], tmp[pX4WLD_TO_BIT:pX4WLD_FROM_BIT]);
                end
                else begin
                  //  if no error; 
                  //  Write measured value onto GRM (both dxnlcdlr0 and r(0-3)wld_value) for future calculation
                  //  this is mainly to be used by force pvt multiplier testcases
                  if (set_init_value) begin
                    `GRM.dxnlcdlr0[rank_id][i][pX4WLD_TO_BIT:pX4WLD_FROM_BIT]   = tmp[pX4WLD_TO_BIT:pX4WLD_FROM_BIT];
                    if (`GRM.x4wld_value[rank_id][i] < LCDL_MAX)  `GRM.x4wld_value[rank_id][i] = tmp[pX4WLD_TO_BIT:pX4WLD_FROM_BIT];
                  end
                end
            end
        end

      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnLCDLR0
  
  task check_DXnLCDLR1;
    input set_init_value;
    reg [31:0]  tmp;
    integer rank_id; 
    real tmp_0;
    real tmp_1;

    begin
      `CFG.disable_read_compare;
      
      // 4) Check LCDL registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnLCDLR1 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
            `GRM.rankidr[16 +: 4] = rank_id;
            @(posedge `CFG.clk);
            `CFG.write_register(`RANKIDR, `GRM.rankidr);
            repeat (`DWC_AFIFO_SYNC_STAGES +4) @(posedge `CFG.clk);
            `CFG.read_register_data(`DX0LCDLR1+(i*`DX_REG_RANGE), tmp);
            tmp_0 = `SYS.abs(tmp[pWDQD_TO_BIT:pWDQD_FROM_BIT]   - `GRM.dxnlcdlr1[rank_id][i][pWDQD_TO_BIT:pWDQD_FROM_BIT]);
            if (tmp_0 > 1) begin
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dLCDLR1 bits!!!",$time, i);
              $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pWDQD_TO_BIT, pWDQD_FROM_BIT, `GRM.dxnlcdlr1[rank_id][i][pWDQD_TO_BIT:pWDQD_FROM_BIT], tmp[pWDQD_TO_BIT:pWDQD_FROM_BIT]);
            end
            else begin
              //  if no error; 
              //  Write measured value onto GRM (both dxnlcdlr1 and r(0-3)wld_value) for future calculation
              //  this is mainly to be used by force pvt multiplier testcases
              if (set_init_value) begin
                `GRM.dxnlcdlr1[rank_id][i][pWDQD_TO_BIT:pWDQD_FROM_BIT]   = tmp[pWDQD_TO_BIT:pWDQD_FROM_BIT];
                if (`GRM.wdqd_value[rank_id][i] < LCDL_MAX)  `GRM.wdqd_value[rank_id][i]  = (tmp[pWDQD_TO_BIT:pWDQD_FROM_BIT]  - rounding) * 2.0;  // to compensate for the rounding effect
              end
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                tmp_0 = `SYS.abs(tmp[pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]   - `GRM.dxnlcdlr1[rank_id][i][pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]);
                if (tmp_0 > 1) begin
                  `SYS.error;
                  $display("-> %0t: [SYSTEM] ERROR: CHECKING X4 CALIBRATED VALUES FAILED on DX%0dLCDLR1 bits!!!",$time, i);
                  $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pX4WDQD_TO_BIT, pX4WDQD_FROM_BIT, `GRM.dxnlcdlr1[rank_id][i][pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT], tmp[pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]);
                end
                else begin
                  //  if no error; 
                  //  Write measured value onto GRM (both dxnlcdlr1 and r(0-3)wld_value) for future calculation
                  //  this is mainly to be used by force pvt multiplier testcases
                  if (set_init_value) begin
                    `GRM.dxnlcdlr1[rank_id][i][pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]   = tmp[pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT];
                    if (`GRM.x4wdqd_value[rank_id][i] < LCDL_MAX)  `GRM.x4wdqd_value[rank_id][i]  = (tmp[pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]  - rounding) * 2.0;  // to compensate for the rounding effect
                  end
                end
             end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnLCDLR1
  

  task check_DXnLCDLR2;
    input set_init_value;
    reg [31:0] tmp;
    integer rank_id; 
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      // 4) Check LCDL registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnLCDLR2 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
           `GRM.rankidr[16 +: 4] = rank_id;
             @(posedge `CFG.clk);
            `CFG.write_register(`RANKIDR, `GRM.rankidr);
            repeat (`DWC_AFIFO_SYNC_STAGES +4) @(posedge `CFG.clk);
            `CFG.read_register_data(`DX0LCDLR2+(i*`DX_REG_RANGE), tmp);        
            tmp_0 = `SYS.abs(tmp[pGDQSD_TO_BIT:pGDQSD_FROM_BIT] - `GRM.dxnlcdlr2[rank_id][i][pGDQSD_TO_BIT:pGDQSD_FROM_BIT]);
            if (tmp_0 > 1) begin
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: CHECKING X4 CALIBRATED VALUES FAILED on DX%0dLCDLR2 bits for rank %0d!!!",$time, i, rank_id);
              $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pGDQSD_TO_BIT, pGDQSD_FROM_BIT, `GRM.dxnlcdlr2[rank_id][i][pGDQSD_TO_BIT:pGDQSD_FROM_BIT], tmp[pGDQSD_TO_BIT:pGDQSD_FROM_BIT]);
            end
            else begin
              //  if no error; 
              //  Write measured value onto GRM (both dxnlcdlr2 and r(0-3)dqsgd_value) for future calculation
              //  this is mainly to be used by force pvt multiplier testcases
              if (set_init_value) begin
                `GRM.dxnlcdlr2[rank_id][i][pGDQSD_TO_BIT:pGDQSD_FROM_BIT]  = tmp[pGDQSD_TO_BIT:pGDQSD_FROM_BIT];
                if (`GRM.dqsgd_value[rank_id][i] < LCDL_MAX)  `GRM.dqsgd_value[rank_id][i]  = tmp[pGDQSD_TO_BIT:pGDQSD_FROM_BIT];
              end
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                tmp_0 = `SYS.abs(tmp[pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT] - `GRM.dxnlcdlr2[rank_id][i][pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT]);
                if (tmp_0 > 1) begin
                  `SYS.error;
                  $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dLCDLR2 bits for rank %0d!!!",$time, i, rank_id);
                  $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pX4GDQSD_TO_BIT, pX4GDQSD_FROM_BIT, `GRM.dxnlcdlr2[rank_id][i][pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT], tmp[pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT]);
                end
                else begin
                  //  if no error; 
                  //  Write measured value onto GRM (both dxnlcdlr2 and r(0-3)dqsgd_value) for future calculation
                  //  this is mainly to be used by force pvt multiplier testcases
                  if (set_init_value) begin
                    `GRM.dxnlcdlr2[rank_id][i][pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT]  = tmp[pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT];
                    if (`GRM.x4dqsgd_value[rank_id][i] < LCDL_MAX)  `GRM.x4dqsgd_value[rank_id][i]  = tmp[pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT];
                  end
                end
            end
         end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnLCDLR2


  task check_DXnLCDLR3;
    input set_init_value;
    reg [31:0] tmp;
    integer rank_id;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      // 4) Check LCDL registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnLCDLR3 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
            `GRM.rankidr[16 +: 4] = rank_id;
            @(posedge `CFG.clk);
            `CFG.write_register(`RANKIDR, `GRM.rankidr);
            repeat (`DWC_AFIFO_SYNC_STAGES +4) @(posedge `CFG.clk);
            `CFG.read_register_data(`DX0LCDLR3+(i*`DX_REG_RANGE), tmp);        
            tmp_0 = `SYS.abs(tmp[pRDQSD_TO_BIT:pRDQSD_FROM_BIT]   - `GRM.dxnlcdlr3[rank_id][i][pRDQSD_TO_BIT:pRDQSD_FROM_BIT]);
            if (tmp_0 > 1) begin
              `SYS.error;
              $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dLCDLR3 bits for rank %0d!!!",$time, i, rank_id);
              $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pRDQSD_TO_BIT, pRDQSD_FROM_BIT, `GRM.dxnlcdlr3[rank_id][i][pRDQSD_TO_BIT:pRDQSD_FROM_BIT], tmp[pRDQSD_TO_BIT:pRDQSD_FROM_BIT]);
            end
            else begin
              //  if no error; 
              //  Write measured value onto GRM (both dxnlcdlr3 and r(0-3)dqsgd_value) for future calculation
              //  this is mainly to be used by force pvt multiplier testcases
              if (set_init_value) begin
                 `GRM.dxnlcdlr3[rank_id][i][pRDQSD_TO_BIT:pRDQSD_FROM_BIT]   = tmp[pRDQSD_TO_BIT:pRDQSD_FROM_BIT];
                 if (`GRM.rdqsd_value[rank_id][i] < LCDL_MAX)  `GRM.rdqsd_value[rank_id][i]  = (tmp[pRDQSD_TO_BIT:pRDQSD_FROM_BIT]  - rounding) * 2.0;  // to compensate for the rounding effect
              end
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                tmp_0 = `SYS.abs(tmp[pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]   - `GRM.dxnlcdlr3[rank_id][i][pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]);
                if (tmp_0 > 1) begin
                  `SYS.error;
                  $display("-> %0t: [SYSTEM] ERROR: CHECKING X4 CALIBRATED VALUES FAILED on DX%0dLCDLR3 bits for rank %0d!!!",$time, i, rank_id);
                  $display("-> %0t: [SYSTEM] Expecting Q[%0d:%0d] = %0h got %0h", $time, pX4RDQSD_TO_BIT, pX4RDQSD_FROM_BIT, `GRM.dxnlcdlr3[rank_id][i][pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT], tmp[pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]);
                end
                else begin
                  //  if no error; 
                  //  Write measured value onto GRM (both dxnlcdlr3 and r(0-3)dqsgd_value) for future calculation
                  //  this is mainly to be used by force pvt multiplier testcases
                  if (set_init_value) begin
                     `GRM.dxnlcdlr3[rank_id][i][pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]   = tmp[pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT];
                     if (`GRM.x4rdqsd_value[rank_id][i] < LCDL_MAX)  `GRM.x4rdqsd_value[rank_id][i]  = (tmp[pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]  - rounding) * 2.0;  // to compensate for the rounding effect
                  end
                end
            end
         end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnLCDLR3

   
  
  // Check ACBDLR0
  // ACBDLR0[ 5: 0].CK0BD
  // ACBDLR0[13: 8].CK1BD
  // ACBDLR0[21:16].CK2BD
  // ACBDLR0[29:24].CK3BD
  task check_ACBDLR0;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR0
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR0 <====== ",$time);
      `CFG.read_register_data(`ACBDLR0, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr0[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr0[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr0[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr0[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR0 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr0[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr0[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr0[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr0[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-3)bd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr0[29:24] = tmp[29:24];
          `GRM.acbdlr0[21:16] = tmp[21:16];
          `GRM.acbdlr0[13:8]  = tmp[13:8];  
          `GRM.acbdlr0[5:0]   = tmp[5:0];
          if (`GRM.acbdlr0_ck3bd_value < BDL_MAX) `GRM.acbdlr0_ck3bd_value = tmp[29:24];
          if (`GRM.acbdlr0_ck2bd_value < BDL_MAX) `GRM.acbdlr0_ck2bd_value = tmp[21:16];
          if (`GRM.acbdlr0_ck1bd_value < BDL_MAX) `GRM.acbdlr0_ck1bd_value = tmp[13:8];  
          if (`GRM.acbdlr0_ck0bd_value < BDL_MAX) `GRM.acbdlr0_ck0bd_value = tmp[5:0];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR0
  
  // Check ACBDLR1
  // ACBDLR1[ 5: 0].RASBD
  // ACBDLR1[13: 8].CASBD
  // ACBDLR1[21:16].WEBD
  // ACBDLR1[29:24].PARBD
  task check_ACBDLR1;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR1
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR1 <====== ",$time);
      `CFG.read_register_data(`ACBDLR1, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr1[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr1[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr1[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr1[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR1 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr1[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr1[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr1[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr1[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both ras/cas/we delay and parbd delay) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr1[29:24] = tmp[29:24];
          `GRM.acbdlr1[21:16] = tmp[21:16];
          `GRM.acbdlr1[13:8]  = tmp[13:8];  
          `GRM.acbdlr1[5:0]   = tmp[5:0];
          if (`GRM.acbdlr1_actbd_value < BDL_MAX)  `GRM.acbdlr1_actbd_value = tmp[5:0];
          if (`GRM.acbdlr1_a17bd_value < BDL_MAX)  `GRM.acbdlr1_a17bd_value = tmp[13:8];
          if (`GRM.acbdlr1_a16bd_value  < BDL_MAX)  `GRM.acbdlr1_a16bd_value  = tmp[21:16];
          if (`GRM.acbdlr1_parbd_value < BDL_MAX)  `GRM.acbdlr1_parbd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR1

  // Check ACBDLR2
  // ACBDLR2[ 5: 0].BA0BD
  // ACBDLR2[13: 8].BA1BD
  // ACBDLR2[21:16].BA2BD
  // ACBDLR2[29:24].ACPDDBD
  task check_ACBDLR2;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR2
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR2 <====== ",$time);
      `CFG.read_register_data(`ACBDLR2, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr2[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr2[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr2[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr2[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR2 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr2[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr2[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr2[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr2[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr2[29:24] = tmp[29:24];
          `GRM.acbdlr2[21:16] = tmp[21:16];
          `GRM.acbdlr2[13:8]  = tmp[13:8];  
          `GRM.acbdlr2[5:0]   = tmp[5:0];
          if (`GRM.acbdlr2_ba0bd_value < BDL_MAX)  `GRM.acbdlr2_ba0bd_value = tmp[5:0];
          if (`GRM.acbdlr2_ba1bd_value < BDL_MAX)  `GRM.acbdlr2_ba1bd_value = tmp[13:8];
          if (`GRM.acbdlr2_ba2bd_value < BDL_MAX)  `GRM.acbdlr2_ba2bd_value = tmp[21:16];
          if (`GRM.acbdlr2_ba3bd_value < BDL_MAX)  `GRM.acbdlr2_ba3bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR2

  // Check ACBDLR3
  // ACBDLR3[ 5: 0].CS0BD
  // ACBDLR3[13: 8].CS1BD
  // ACBDLR3[21:16].CS2BD
  // ACBDLR3[29:24].CS3BD
  task check_ACBDLR3;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR3
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR3 <====== ",$time);
      `CFG.read_register_data(`ACBDLR3, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr3[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr3[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr3[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr3[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR3 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr3[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr3[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr3[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr3[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr3[29:24] = tmp[29:24];
          `GRM.acbdlr3[21:16] = tmp[21:16];
          `GRM.acbdlr3[13:8]  = tmp[13:8];  
          `GRM.acbdlr3[5:0]   = tmp[5:0];
          if (`GRM.acbdlr3_cs0bd_value < BDL_MAX)  `GRM.acbdlr3_cs0bd_value = tmp[5:0];
          if (`GRM.acbdlr3_cs1bd_value < BDL_MAX)  `GRM.acbdlr3_cs1bd_value = tmp[13:8];
          if (`GRM.acbdlr3_cs2bd_value < BDL_MAX)  `GRM.acbdlr3_cs2bd_value = tmp[21:16];
          if (`GRM.acbdlr3_cs3bd_value < BDL_MAX)  `GRM.acbdlr3_cs3bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR3

  // Check ACBDLR4
  // ACBDLR4[ 5: 0].ODT0BD
  // ACBDLR4[13: 8].ODT1BD
  // ACBDLR4[21:16].ODT2BD
  // ACBDLR4[29:24].ODT3BD
  task check_ACBDLR4;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR4
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR4 <====== ",$time);
      `CFG.read_register_data(`ACBDLR4, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr4[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr4[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr4[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr4[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR4 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr4[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr4[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr4[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr4[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr4[29:24] = tmp[29:24];
          `GRM.acbdlr4[21:16] = tmp[21:16];
          `GRM.acbdlr4[13:8]  = tmp[13:8];  
          `GRM.acbdlr4[5:0]   = tmp[5:0];
          if (`GRM.acbdlr4_odt0bd_value < BDL_MAX)  `GRM.acbdlr4_odt0bd_value = tmp[5:0];
          if (`GRM.acbdlr4_odt1bd_value < BDL_MAX)  `GRM.acbdlr4_odt1bd_value = tmp[13:8];
          if (`GRM.acbdlr4_odt2bd_value < BDL_MAX)  `GRM.acbdlr4_odt2bd_value = tmp[21:16];
          if (`GRM.acbdlr4_odt3bd_value < BDL_MAX)  `GRM.acbdlr4_odt3bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR4

  // Check ACBDLR5
  // ACBDLR5[ 5: 0].CKE0BD
  // ACBDLR5[13: 8].CKE1BD
  // ACBDLR5[21:16].CKE2BD
  // ACBDLR5[29:24].CKE3BD
  task check_ACBDLR5;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR5
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR5 <====== ",$time);
      `CFG.read_register_data(`ACBDLR5, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr5[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr5[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr5[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr5[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR5 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr5[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr5[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr5[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr5[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr5[29:24] = tmp[29:24];
          `GRM.acbdlr5[21:16] = tmp[21:16];
          `GRM.acbdlr5[13:8]  = tmp[13:8];  
          `GRM.acbdlr5[5:0]   = tmp[5:0];
          if (`GRM.acbdlr5_cke0bd_value < BDL_MAX)  `GRM.acbdlr5_cke0bd_value = tmp[5:0];
          if (`GRM.acbdlr5_cke1bd_value < BDL_MAX)  `GRM.acbdlr5_cke1bd_value = tmp[13:8];
          if (`GRM.acbdlr5_cke2bd_value < BDL_MAX)  `GRM.acbdlr5_cke2bd_value = tmp[21:16];
          if (`GRM.acbdlr5_cke3bd_value < BDL_MAX)  `GRM.acbdlr5_cke3bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR5

  // Check ACBDLR6
  // ACBDLR6[ 5: 0].A00BD
  // ACBDLR6[13: 8].A01BD
  // ACBDLR6[21:16].A02BD
  // ACBDLR6[29:24].A03BD
  task check_ACBDLR6;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR6
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR6 <====== ",$time);
      `CFG.read_register_data(`ACBDLR6, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr6[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr6[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr6[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr6[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR6 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr6[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr6[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr6[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr6[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr6[29:24] = tmp[29:24];
          `GRM.acbdlr6[21:16] = tmp[21:16];
          `GRM.acbdlr6[13:8]  = tmp[13:8];  
          `GRM.acbdlr6[5:0]   = tmp[5:0];
          if (`GRM.acbdlr6_a00bd_value < BDL_MAX)  `GRM.acbdlr6_a00bd_value = tmp[5:0];
          if (`GRM.acbdlr6_a01bd_value < BDL_MAX)  `GRM.acbdlr6_a01bd_value = tmp[13:8];
          if (`GRM.acbdlr6_a02bd_value < BDL_MAX)  `GRM.acbdlr6_a02bd_value = tmp[21:16];
          if (`GRM.acbdlr6_a03bd_value < BDL_MAX)  `GRM.acbdlr6_a03bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR6

  // Check ACBDLR7
  // ACBDLR7[ 5: 0].A04BD
  // ACBDLR7[13: 8].A05BD
  // ACBDLR7[21:16].A06BD
  // ACBDLR7[29:24].A07BD
  task check_ACBDLR7;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR7
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR7 <====== ",$time);
      `CFG.read_register_data(`ACBDLR7, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]  - `GRM.acbdlr7[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8] - `GRM.acbdlr7[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr7[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr7[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR7 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr7[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr7[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr7[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr7[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr7[29:24] = tmp[29:24];
          `GRM.acbdlr7[21:16] = tmp[21:16];
          `GRM.acbdlr7[13:8]  = tmp[13:8];  
          `GRM.acbdlr7[5:0]   = tmp[5:0];
          if (`GRM.acbdlr7_a04bd_value < BDL_MAX)  `GRM.acbdlr7_a04bd_value = tmp[5:0];
          if (`GRM.acbdlr7_a05bd_value < BDL_MAX)  `GRM.acbdlr7_a05bd_value = tmp[13:8];
          if (`GRM.acbdlr7_a06bd_value < BDL_MAX)  `GRM.acbdlr7_a06bd_value = tmp[21:16];
          if (`GRM.acbdlr7_a07bd_value < BDL_MAX)  `GRM.acbdlr7_a07bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR7

  // Update ACBDLR8
  // ACBDLR8[ 5: 0].A08BD
  // ACBDLR8[13: 8].A09BD
  // ACBDLR8[21:16].A10BD
  // ACBDLR8[29:24].A11BD
  task check_ACBDLR8;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR8
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR8 <====== ",$time);
      `CFG.read_register_data(`ACBDLR8, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr8[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr8[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr8[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr8[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR8 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr8[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr8[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr8[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr8[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr8[29:24] = tmp[29:24];
          `GRM.acbdlr8[21:16] = tmp[21:16];
          `GRM.acbdlr8[13:8]  = tmp[13:8];  
          `GRM.acbdlr8[5:0]   = tmp[5:0];
          if (`GRM.acbdlr8_a08bd_value < BDL_MAX)  `GRM.acbdlr8_a08bd_value = tmp[5:0];
          if (`GRM.acbdlr8_a09bd_value < BDL_MAX)  `GRM.acbdlr8_a09bd_value = tmp[13:8];
          if (`GRM.acbdlr8_a10bd_value < BDL_MAX)  `GRM.acbdlr8_a10bd_value = tmp[21:16];
          if (`GRM.acbdlr8_a11bd_value < BDL_MAX)  `GRM.acbdlr8_a11bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR8

  // Check ACBDLR9
  // ACBDLR9[ 5: 0].A12BD
  // ACBDLR9[13: 8].A13BD
  // ACBDLR9[21:16].A14BD
  // ACBDLR9[29:24].A15BD
  task check_ACBDLR9;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    begin
      `CFG.disable_read_compare;
      
      //
      // BDL related registers
      //
      // 5) ACBDLR9
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED ACBDLR9 <====== ",$time);
      `CFG.read_register_data(`ACBDLR9, tmp);
      
      // there might be a + or - 1 difference between the calculated
      // values with the PHYCTL register value (which truncates off)
      tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.acbdlr9[5:0]);
      tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.acbdlr9[13:8]);
      tmp_2 = `SYS.abs(tmp[21:16] - `GRM.acbdlr9[21:16]);
      tmp_3 = `SYS.abs(tmp[29:24] - `GRM.acbdlr9[29:24]);
      if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
        `SYS.error;
        $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES mismatch on ACBDLR9 bits!!!",$time);
        $display("-> %0t: [SYSTEM] Expected acbdlr[29:24] = %0h got %0h", $time, `GRM.acbdlr9[29:24], tmp[29:24]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[21:16] = %0h got %0h", $time, `GRM.acbdlr9[21:16], tmp[21:16]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[13:8]  = %0h got %0h", $time, `GRM.acbdlr9[13:8],  tmp[13:8]);
        $display("-> %0t: [SYSTEM] Expected acbdlr[5:0]   = %0h got %0h", $time, `GRM.acbdlr9[5:0],   tmp[5:0]);
      end
      else begin
        //  if no error; 
        //  Write measured value onto GRM (both acbdlr and ck(0-2)bd_value and acbd_value) for future calculation
        //  this is mainly to be used by force pvt multiplier testcases
        if (set_init_value) begin
          `GRM.acbdlr9[29:24] = tmp[29:24];
          `GRM.acbdlr9[21:16] = tmp[21:16];
          `GRM.acbdlr9[13:8]  = tmp[13:8];  
          `GRM.acbdlr9[5:0]   = tmp[5:0];
          if (`GRM.acbdlr9_a12bd_value < BDL_MAX)  `GRM.acbdlr9_a12bd_value = tmp[5:0];
          if (`GRM.acbdlr9_a13bd_value < BDL_MAX)  `GRM.acbdlr9_a13bd_value = tmp[13:8];
          if (`GRM.acbdlr9_a14bd_value < BDL_MAX)  `GRM.acbdlr9_a14bd_value = tmp[21:16];
          if (`GRM.acbdlr9_a15bd_value < BDL_MAX)  `GRM.acbdlr9_a15bd_value = tmp[29:24];
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_ACBDLR9


  task check_DXnBDLR0;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    real tmp_4;
    
    begin
      `CFG.disable_read_compare;
      
      // 6) Check DXnBDLR0 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR0 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR0+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.dxnbdlr0[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.dxnbdlr0[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr0[i][21:16]);
        tmp_3 = `SYS.abs(tmp[29:24] - `GRM.dxnbdlr0[i][29:24]);

        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR0 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[29:24] = %0h got %0h", $time, `GRM.dxnbdlr0[i][29:24], tmp[29:24]);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr0[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr0[i][13:8],  tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr0[i][5:0],   tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr0 and *wbd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr0[i][29:24] = tmp[29:24];
            `GRM.dxnbdlr0[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr0[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr0[i][5:0]   = tmp[5:0];
            if (`GRM.dq3wbd_value[i] < BDL_MAX)  `GRM.dq3wbd_value[i] = tmp[29:24];
            if (`GRM.dq2wbd_value[i] < BDL_MAX)  `GRM.dq2wbd_value[i] = tmp[21:16];
            if (`GRM.dq1wbd_value[i] < BDL_MAX)  `GRM.dq1wbd_value[i] = tmp[13:8];
            if (`GRM.dq0wbd_value[i] < BDL_MAX)  `GRM.dq0wbd_value[i] = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR0
  
  task check_DXnBDLR1;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    real tmp_4;
    
    begin
      `CFG.disable_read_compare;
      
      // 7) Check DXnBDLR1 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR1 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR1+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]  - `GRM.dxnbdlr1[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8] - `GRM.dxnbdlr1[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr1[i][21:16]);
        tmp_3 = `SYS.abs(tmp[29:24] - `GRM.dxnbdlr1[i][29:24]);

        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1) || (tmp_4 > 1)) begin
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR1 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[29:24] = %0h got %0h", $time, `GRM.dxnbdlr1[i][29:24], tmp[29:24]);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr1[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8] = %0h got %0h", $time, `GRM.dxnbdlr1[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]  = %0h got %0h", $time, `GRM.dxnbdlr1[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr1 and *wbd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr1[i][29:24] = tmp[29:24];
            `GRM.dxnbdlr1[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr1[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr1[i][5:0]   = tmp[5:0];
            if (`GRM.dmwbd_value[i]  < BDL_MAX)  `GRM.dmwbd_value[i]  = tmp[29:24];
            if (`GRM.dq7wbd_value[i] < BDL_MAX)  `GRM.dq7wbd_value[i] = tmp[21:16];
            if (`GRM.dq6wbd_value[i] < BDL_MAX)  `GRM.dq6wbd_value[i] = tmp[13:8];
            if (`GRM.dq5wbd_value[i] < BDL_MAX)  `GRM.dq5wbd_value[i] = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR1
  
  task check_DXnBDLR2;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    
    begin
      `CFG.disable_read_compare;
      
      // 8) Check DXnBDLR2 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR2 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR2+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]  - `GRM.dxnbdlr2[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8] - `GRM.dxnbdlr2[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr2[i][21:16]);

        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1)) begin 
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR2 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr2[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr2[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr2[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr2 and dqsoebd_value, dqoebd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr2[i][21:16]  = tmp[21:16];
            `GRM.dxnbdlr2[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr2[i][5:0]   = tmp[5:0];
            if (`GRM.dqsoebd_value[i]   < BDL_MAX) `GRM.dqsoebd_value[i] = tmp[21:16];
            if (`GRM.dswbd_value[i]  < BDL_MAX)    `GRM.dswbd_value[i]   = tmp[13:8];
            if (`GRM.dmwbd_value[i] < BDL_MAX)     `GRM.dmwbd_value[i]   = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR2
  
  task check_DXnBDLR3;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    
    begin
      `CFG.disable_read_compare;
      
      // 9) Check DXnBDLR3 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR3 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR3+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]  - `GRM.dxnbdlr3[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8] - `GRM.dxnbdlr3[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr3[i][21:16]);
        tmp_3 = `SYS.abs(tmp[29:24] - `GRM.dxnbdlr3[i][29:24]);
        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR3 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[29:24] = %0h got %0h", $time, `GRM.dxnbdlr3[i][29:24], tmp[29:24]);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr3[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8] = %0h got %0h", $time, `GRM.dxnbdlr3[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]  = %0h got %0h", $time, `GRM.dxnbdlr3[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr3 and *rbd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr3[i][29:24] = tmp[29:24];
            `GRM.dxnbdlr3[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr3[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr3[i][5:0]   = tmp[5:0];
            if (`GRM.dq3rbd_value[i] < BDL_MAX)  `GRM.dq3rbd_value[i] = tmp[29:24];
            if (`GRM.dq2rbd_value[i] < BDL_MAX)  `GRM.dq2rbd_value[i] = tmp[21:16];
            if (`GRM.dq1rbd_value[i] < BDL_MAX)  `GRM.dq1rbd_value[i] = tmp[13:8];
            if (`GRM.dq0rbd_value[i] < BDL_MAX)  `GRM.dq0rbd_value[i] = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR3
  
  task check_DXnBDLR4;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    real tmp_3;
    
    begin
      `CFG.disable_read_compare;
      
      // 10) Check BDL registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR4 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR4+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.dxnbdlr4[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.dxnbdlr4[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr4[i][21:16]);
        tmp_3 = `SYS.abs(tmp[29:24] - `GRM.dxnbdlr4[i][29:24]);
        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1) || (tmp_3 > 1)) begin
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR4 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[29:24] = %0h got %0h", $time, `GRM.dxnbdlr4[i][29:24], tmp[29:24]);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr4[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr4[i][13:8],  tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr4[i][5:0],   tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr4 and *rbd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr4[i][29:24] = tmp[29:24];
            `GRM.dxnbdlr4[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr4[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr4[i][5:0]   = tmp[5:0];
            if (`GRM.dq7rbd_value[i] < BDL_MAX)  `GRM.dq7rbd_value[i] = tmp[29:24];
            if (`GRM.dq6rbd_value[i] < BDL_MAX)  `GRM.dq6rbd_value[i] = tmp[21:16];
            if (`GRM.dq5rbd_value[i] < BDL_MAX)  `GRM.dq5rbd_value[i] = tmp[13:8];
            if (`GRM.dq4rbd_value[i] < BDL_MAX)  `GRM.dq4rbd_value[i] = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR4

  task check_DXnBDLR5;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    
    begin
      `CFG.disable_read_compare;
      
      // 8) Check DXnBDLR5 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR5 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR5+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.dxnbdlr5[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.dxnbdlr5[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr5[i][21:16]);

        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1)) begin 
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR5 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr5[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr5[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr5[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr5 and dqsoebd_value, dqoebd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr5[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr5[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr5[i][5:0]   = tmp[5:0];
            if (`GRM.dsnrbd_value[i] < BDL_MAX) `GRM.dsnrbd_value[i] = tmp[21:16];
            if (`GRM.dsrbd_value[i]  < BDL_MAX) `GRM.dsrbd_value[i]  = tmp[13:8];
            if (`GRM.dmrbd_value[i]  < BDL_MAX) `GRM.dmrbd_value[i]  = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR5

  task check_DXnBDLR6;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    
    begin
      `CFG.disable_read_compare;
      
      // 8) Check DXnBDLR6 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR6 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR6+(i*`DX_REG_RANGE), tmp);
        tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.dxnbdlr6[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr6[i][21:16]);

        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1)) begin 
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR6 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr6[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr6[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr6[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr6 and dqsoebd_value, dqoebd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr6[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr6[i][13:8]  = tmp[13:8];
            if (`GRM.pdrbd_value[i] < BDL_MAX) `GRM.pdrbd_value[i] = tmp[13:8];
            if (`GRM.terbd_value[i] < BDL_MAX) `GRM.terbd_value[i] = tmp[21:16];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR6
   
  task check_DXnBDLR7;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    
    begin
      `CFG.disable_read_compare;
      
      // 8) Check DXnBDLR7 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR7 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR7+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]  - `GRM.dxnbdlr7[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8] - `GRM.dxnbdlr7[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr7[i][21:16]);

        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1)) begin 
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR7 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr7[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr7[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr7[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr7 and dqsoebd_value, dqoebd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr7[i][21:16]  = tmp[21:16];
            `GRM.dxnbdlr7[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr7[i][5:0]   = tmp[5:0];
            if (`GRM.x4dqsoebd_value[i]   < BDL_MAX) `GRM.x4dqsoebd_value[i] = tmp[21:16];
            if (`GRM.x4dswbd_value[i]  < BDL_MAX)    `GRM.x4dswbd_value[i]   = tmp[13:8];
            if (`GRM.x4dmwbd_value[i] < BDL_MAX)     `GRM.x4dmwbd_value[i]   = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR7
 
  task check_DXnBDLR8;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    
    begin
      `CFG.disable_read_compare;
      
      // 8) Check DXnBDLR8 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR8 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR8+(i*`DX_REG_RANGE), tmp);
        tmp_0 = `SYS.abs(tmp[5:0]   - `GRM.dxnbdlr8[i][5:0]);
        tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.dxnbdlr8[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr8[i][21:16]);

        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1)) begin 
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR8 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr8[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr8[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr8[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr8 and dqsoebd_value, dqoebd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr8[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr8[i][13:8]  = tmp[13:8];
            `GRM.dxnbdlr8[i][5:0]   = tmp[5:0];
            if (`GRM.x4dsnrbd_value[i] < BDL_MAX) `GRM.x4dsnrbd_value[i] = tmp[21:16];
            if (`GRM.x4dsrbd_value[i]  < BDL_MAX) `GRM.x4dsrbd_value[i]  = tmp[13:8];
            if (`GRM.x4dmrbd_value[i]  < BDL_MAX) `GRM.x4dmrbd_value[i]  = tmp[5:0];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR8
   
  task check_DXnBDLR9;
    input set_init_value;
    reg [31:0] tmp;
    
    real tmp_0;
    real tmp_1;
    real tmp_2;
    
    begin
      `CFG.disable_read_compare;
      
      // 8) Check DXnBDLR9 registers
      if (verbose > pvt_debug) $display("-> %0t: [SYSTEM] ======> CHECK CALIBRATED DXnBDLR9 <====== ",$time);
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        `CFG.read_register_data(`DX0BDLR9+(i*`DX_REG_RANGE), tmp);
        tmp_1 = `SYS.abs(tmp[13:8]  - `GRM.dxnbdlr9[i][13:8]);
        tmp_2 = `SYS.abs(tmp[21:16] - `GRM.dxnbdlr9[i][21:16]);

        
        if ((tmp_0 > 1) || (tmp_1 > 1) || (tmp_2 > 1)) begin 
          `SYS.error;
          $display("-> %0t: [SYSTEM] ERROR: CHECKING CALIBRATED VALUES FAILED on DX%0dBDLR9 bits!!!",$time, i);
          $display("-> %0t: [SYSTEM] Expecting Q[21:16] = %0h got %0h", $time, `GRM.dxnbdlr9[i][21:16], tmp[21:16]);
          $display("-> %0t: [SYSTEM] Expecting Q[13:8]  = %0h got %0h", $time, `GRM.dxnbdlr9[i][13:8], tmp[13:8]);
          $display("-> %0t: [SYSTEM] Expecting Q[5:0]   = %0h got %0h", $time, `GRM.dxnbdlr9[i][5:0], tmp[5:0]);
        end
        else begin
          //  if no error; 
          //  Write measured value onto GRM (both dxnbdlr9 and dqsoebd_value, dqoebd_value) for future calculation
          //  this is mainly to be used by force pvt multiplier testcases
          if (set_init_value) begin
            `GRM.dxnbdlr9[i][21:16] = tmp[21:16];
            `GRM.dxnbdlr9[i][13:8]  = tmp[13:8];
            if (`GRM.x4pdrbd_value[i] < BDL_MAX) `GRM.x4pdrbd_value[i] = tmp[13:8];
            if (`GRM.x4terbd_value[i] < BDL_MAX) `GRM.x4terbd_value[i] = tmp[21:16];
          end
        end
      end
      
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
      repeat (10) @(posedge `CFG.clk);

    end
  endtask // check_DXnBDLR9
  
 // TBD G2MPHY - add AC vt drift checks 
  task check_vt_drift;
    integer i;
    reg exp_vt_drift;
    real diff_threshold;
    real threshold;

    begin
      $display("-> %0t: [PHYSYS] ======> CHECK VT DRIFT signal <====== ",$time);
      $display("-> %0t: [PHYSYS] dx_vt_drift  = %0h", $time, dx_vt_drift);
      
      
//TBD G2MPHY - need to update the ac vt drift checks
      if ((ac_vt_drift === 1'bx) || (ac_vt_drift === 1'bz)) begin
        `SYS.error;
        $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT and detected an invalid state",$time, i);
        $display("-> %0t: [PHYSYS] ERROR: ac_vt_drift[%0d]           = %0d", $time, i, ac_vt_drift);
      // special case: flag an error if vt_drift is asserted when the dldlmt setting is zero
      end else if ((ac_vt_drift == 1'b1) && (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] == 8'h0)) begin
        `SYS.error;
        $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT signal should be deasserted for PGCR1.DLDLMT = 0 on byte lane %0d",$time, i);
        $display("-> %0t: [PHYSYS] ERROR: ac_vt_drift[%0d] = %0d", $time, i, ac_vt_drift);
      // check the drift signal...if 0 or 1 check the value and flag a warning instead of an error
      end else if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] == 8'b0) begin
        if (ac_vt_drift == 1'b1) begin
          `SYS.error;
          $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT signal mismatch for byte lane %0d",$time, i);
          $display("-> %0t: [PHYSYS] ERROR: ac_vt_drift[%0d]      = %0d", $time, i, ac_vt_drift);
          $display("-> %0t: [PHYSYS] ERROR: PGCR1[%0d:%0d] (DLDLMT) = %0d", $time, i, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
        end
      end else begin
//TBD G2MPHY        threshold = 1.0*`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT];
//TBD G2MPHY        exp_vt_drift = (dx_mdl_vt_drift_diff >= threshold) ? 1'b1 : 1'b0;
//TBD G2MPHY        diff_threshold = (dx_mdl_vt_drift_diff>threshold) ? dx_mdl_vt_drift_diff - threshold
//TBD G2MPHY                                                             : threshold - dx_mdl_vt_drift_diff;
//TBD G2MPHY        if (diff_threshold < 2.0) begin
//TBD G2MPHY          // Ignore threshold differences less than two
//TBD G2MPHY          if (ac_vt_drift != exp_vt_drift) begin
//TBD G2MPHY            $display("-> %0t: [PHYSYS] CHECKING VT DRIFT: ac_vt_drift[%0d] different than expected but the difference is with the margin of one tap.",i,$time);
//TBD G2MPHY            $display("-> %0t: [PHYSYS]        ac_vt_drift[%0d]           = %0d", $time, i, ac_vt_drift);
//TBD G2MPHY          end
//TBD G2MPHY        end else begin
//TBD G2MPHY          if (ac_vt_drift != exp_vt_drift) begin
//TBD G2MPHY            `SYS.error;
//TBD G2MPHY            $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT signal mismatch for byte lane %0d",$time, i);
//TBD G2MPHY            $display("-> %0t: [PHYSYS] ERROR: ac_vt_drift[%0d]             = %0d", $time, i, ac_vt_drift);
//TBD G2MPHY            $display("-> %0t: [PHYSYS] ERROR: dx_mdl_vt_drift_diff[%0d]    = %0f", $time, i, dx_mdl_vt_drift_diff);
//TBD G2MPHY          end
//TBD G2MPHY        end
      end
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        if ((dx_vt_drift[i] === 1'bx) || (dx_vt_drift[i] === 1'bz)) begin
          `SYS.error;
          $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT and detected an invalid state",$time, i);
          $display("-> %0t: [PHYSYS] ERROR: dx_vt_drift[%0d]           = %0d", $time, i, dx_vt_drift[i]);
        // special case: flag an error if vt_drift is asserted when the dldlmt setting is zero
        end else if ((dx_vt_drift[i] == 1'b1) && (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] == 8'h0)) begin
          `SYS.error;
          $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT signal should be deasserted for PGCR1.DLDLMT = 0 on byte lane %0d",$time, i);
          $display("-> %0t: [PHYSYS] ERROR: dx_vt_drift[%0d] = %0d", $time, i, dx_vt_drift[i]);
        // check the drift signal...if 0 or 1 check the value and flag a warning instead of an error
        end else if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] == 8'b0) begin
          if (dx_vt_drift[i] == 1'b1) begin
            `SYS.error;
            $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT signal mismatch for byte lane %0d",$time, i);
            $display("-> %0t: [PHYSYS] ERROR: dx_vt_drift[%0d]      = %0d", $time, i, dx_vt_drift[i]);
            $display("-> %0t: [PHYSYS] ERROR: PGCR1[%0d:%0d] (DLDLMT) = %0d", $time, i, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
          end
        end else begin
          threshold = 1.0*`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT];
          exp_vt_drift = (dx_mdl_vt_drift_diff[i] >= threshold) ? 1'b1 : 1'b0;
          diff_threshold = (dx_mdl_vt_drift_diff[i]>threshold) ? dx_mdl_vt_drift_diff[i] - threshold
                                                               : threshold - dx_mdl_vt_drift_diff[i];
          if (diff_threshold < 2.0) begin
            // Ignore threshold differences less than two
            if (dx_vt_drift[i] != exp_vt_drift) begin
              $display("-> %0t: [PHYSYS] CHECKING VT DRIFT: dx_vt_drift[%0d] different than expected but the difference is with the margin of one tap.",i,$time);
              $display("-> %0t: [PHYSYS]        dx_vt_drift[%0d]           = %0d", $time, i, dx_vt_drift[i]);
            end
          end else begin
            if (dx_vt_drift[i] != exp_vt_drift) begin
              `SYS.error;
              $display("-> %0t: [PHYSYS] ERROR: CHECKING VT DRIFT signal mismatch for byte lane %0d",$time, i);
              $display("-> %0t: [PHYSYS] ERROR: dx_vt_drift[%0d]             = %0d", $time, i, dx_vt_drift[i]);
              $display("-> %0t: [PHYSYS] ERROR: dx_mdl_vt_drift_diff[%0d]    = %0f", $time, i, dx_mdl_vt_drift_diff[i]);
            end
          end
        end
      end
    end
  endtask // check_vt_drift
  
  
  
  //---------------------------------------------------------------------------
  // PVT manipulation
  //---------------------------------------------------------------------------
  // First Phase VT comp on LCDL models (in progress)
  // The followings defines are used by task force_pvt at the lcdl models at the pvtscale so as to
  // trigger VT compensation
  //---------------------------------------------------------------------------
`define AC_DDR_LCDL_PATH    `AC.ac_clkgen.ddr_ac_lcdl   // AC DDR LCDL
`define AC_CTL_LCDL_PATH    `AC.ac_clkgen.ctl_ac_lcdl   // AC CTL LCDL

`define CTL_WL_LCDL_PATH    `DX_CLKGEN0.ctl_wl_lcdl      // SDR WL LCDL
`define DDR_WL_LCDL_PATH    `DX_CLKGEN0.ddr_wl_lcdl      // WL LCDL
`define DDR_WDQ_LCDL_PATH   `DX_CLKGEN0.ddr_wdq_lcdl     // WDQ LCDL
`define CTL_WDQ_LCDL_PATH   `DX_CLKGEN0.ctl_wdq_lcdl     // ctl WDQ LCDL
`define X4CTL_WL_LCDL_PATH    `DX_CLKGEN1.ctl_wl_lcdl      // SDR WL LCDL
`define X4DDR_WL_LCDL_PATH    `DX_CLKGEN1.ddr_wl_lcdl      // WL LCDL
`define X4DDR_WDQ_LCDL_PATH   `DX_CLKGEN1.ddr_wdq_lcdl     // WDQ LCDL
`define X4CTL_WDQ_LCDL_PATH   `DX_CLKGEN1.ctl_wdq_lcdl     // ctl WDQ LCDL
`define DX_MDL_LCDL_PATH    datx8_ctrl.mdl_lcdl           // Master DL LCDL
  
`define GDQS_LCDL_PATH      `DX_DQS0.ds_gate_lcdl        // Read Gating LCDL
`define RDQS_LCDL_PATH      `DX_DQS0.qs_lcdl             // Read DQS LCDL
`define RDQSN_LCDL_PATH     `DX_DQS0.qs_n_lcdl           // Read DQS# LCDL
`define RDQSGS_LCDL_PATH    `DX_DQS0.qs_gate_lcdl        // Read Gating LCDL
`define X4GDQS_LCDL_PATH      `DX_DQS1.ds_gate_lcdl        // Read Gating LCDL
`define X4RDQS_LCDL_PATH      `DX_DQS1.qs_lcdl             // Read DQS LCDL
`define X4RDQSN_LCDL_PATH     `DX_DQS1.qs_n_lcdl           // Read DQS# LCDL
`define X4RDQSGS_LCDL_PATH    `DX_DQS1.qs_gate_lcdl        // Read Gating LCDL

  //---------------------------------------------------------------------------
  // Next phase VT comp on BDL models (in progress)
  // The followings defines are used by task force_pvt at the bdl models at the pvtscale so as to
  // trigger VT compensation
  //---------------------------------------------------------------------------
`define DQW_BDL_PATH        d_bdl               // Write DQ for each DQx
`define DMW_BDL_PATH        datx8_dq_8.d_bdl    // Write Mask
`define DQR_BDL_PATH        q_bdl               // Read DQ for each DQx
`define DMR_BDL_PATH        datx8_dq_8.q_bdl    // Read Mask
`define DSW_BDL_PATH        `DX_DQS0.ds_bdl   
`define DSOE_BDL_PATH       `DX_DQS0.oe_ioctrl.io_ctrl_bdl // TBD G2MPHY
`define DQOE_BDL_PATH       `DX_DQS0.te_ioctrl.io_ctrl_bdl // TBD G2MPHY
`define DSR_BDL_PATH        `DX_DQS0.qs_bdl
`define DSRN_BDL_PATH       `DX_DQS0.qs_n_bdl
`define PDD_BDL_PATH        `DX_DQS0.pdd_ioctrl.io_ctrl_bdl
`define PDR_BDL_PATH        `DX_DQS0.pdr_ioctrl.io_ctrl_bdl
`define X4DSW_BDL_PATH        `DX_DQS1.ds_bdl   
`define X4DSOE_BDL_PATH       `DX_DQS1.oe_ioctrl.io_ctrl_bdl // TBD G2MPHY
`define X4DQOE_BDL_PATH       `DX_DQS1.te_ioctrl.io_ctrl_bdl // TBD G2MPHY
`define X4DSR_BDL_PATH        `DX_DQS1.qs_bdl
`define X4DSRN_BDL_PATH       `DX_DQS1.qs_n_bdl
`define X4PDD_BDL_PATH        `DX_DQS1.pdd_ioctrl.io_ctrl_bdl
`define X4PDR_BDL_PATH        `DX_DQS1.pdr_ioctrl.io_ctrl_bdl
  
  integer pvt_start_range; initial pvt_start_range = 7;
  integer pvt_stop_range;  initial pvt_stop_range = 13;

  // These following are to store the initial or original values after reset  
  real    pvtscale_ac_mdl;
  real    pvtscale_ctl_wl        [pNUM_LANES-1:0];
  real    pvtscale_ddr_wl        [pNUM_LANES-1:0];
  real    pvtscale_ddr_wdq       [pNUM_LANES-1:0];
  real    pvtscale_dx_mdl        [`DWC_NO_OF_BYTES-1:0];
  real    pvtscale_gdqs          [pNUM_LANES-1:0];
  real    pvtscale_rdqs          [pNUM_LANES-1:0];
  real    pvtscale_rdqsn         [pNUM_LANES-1:0];
  real    pvtscale_rdqsgs        [pNUM_LANES-1:0];
  
  // These are temporary change values to force a VT difference in order to trigger VT compensation  
  real    tmp_pvtscale_ac_mdl;  
  real    tmp_pvtscale_ctl_wl    [pNUM_LANES-1:0];
  real    tmp_pvtscale_ddr_wl    [pNUM_LANES-1:0];
  real    tmp_pvtscale_ddr_wdq   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_mdl    [`DWC_NO_OF_BYTES-1:0];
  real    tmp_pvtscale_gdqs      [pNUM_LANES-1:0];
  real    tmp_pvtscale_rdqs      [pNUM_LANES-1:0];
  real    tmp_pvtscale_rdqsn     [pNUM_LANES-1:0];
  real    tmp_pvtscale_rdqsgs    [pNUM_LANES-1:0];


  // These following are to store BDL initial or original values after reset
  real    pvtscale_ac_cmd_addr_bdl;
  real    pvtscale_ac_ck0_bdl;
  real    pvtscale_ac_ck1_bdl;
  real    pvtscale_ac_ck2_bdl;
  real    pvtscale_ac_ck3_bdl;
  
  real    pvtscale_dx_wdq0_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq1_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq2_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq3_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq4_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq5_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq6_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdq7_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wdqm_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_x4wdqm_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_wds_bdl    [pNUM_LANES-1:0];

  real    pvtscale_dx_rdq0_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_rdq1_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdq2_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdq3_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdq4_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdq5_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdq6_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdq7_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_rdqm_bdl   [pNUM_LANES-1:0]; 
  real    pvtscale_dx_x4rdqm_bdl   [pNUM_LANES-1:0]; 
 real    pvtscale_dx_rds_bdl    [pNUM_LANES-1:0];

  real    pvtscale_dx_dqsoe_bdl  [pNUM_LANES-1:0]; 
  real    pvtscale_dx_dqoe_bdl   [pNUM_LANES-1:0];
  real    pvtscale_dx_pdd_bdl    [pNUM_LANES-1:0];
  real    pvtscale_dx_pdr_bdl    [pNUM_LANES-1:0];

  real    tmp_pvtscale_ac_cmd_addr_bdl;
  real    tmp_pvtscale_ac_ck0_bdl;
  real    tmp_pvtscale_ac_ck1_bdl;
  real    tmp_pvtscale_ac_ck2_bdl;

  real    tmp_pvtscale_dx_wdq0_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq1_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq2_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq3_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq4_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq5_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq6_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdq7_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wdqm_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_x4wdqm_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_wds_bdl    [pNUM_LANES-1:0];

  real    tmp_pvtscale_dx_rdq0_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq1_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq2_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq3_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq4_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq5_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq6_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdq7_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_rdqm_bdl   [pNUM_LANES-1:0]; 
  real    tmp_pvtscale_dx_x4rdqm_bdl   [pNUM_LANES-1:0]; 
 real    tmp_pvtscale_dx_rds_bdl    [pNUM_LANES-1:0];

  real    tmp_pvtscale_dx_dqsoe_bdl [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_dqoe_bdl  [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_pdd_bdl   [pNUM_LANES-1:0];
  real    tmp_pvtscale_dx_pdr_bdl   [pNUM_LANES-1:0];

  real pvtscale_gdqs_datx8_0;
  real tmp_pvtscale_gdqs_datx8_0;
  real tmp_pvtscale_gdqs_datx8_0_wm;

  always @(*) begin
    pvtscale_gdqs_datx8_0        = pvtscale_gdqs[0];
    tmp_pvtscale_gdqs_datx8_0    = tmp_pvtscale_gdqs[0];
    tmp_pvtscale_gdqs_datx8_0_wm = tmp_pvtscale_gdqs[0] * pvt_multiplier;
  end
  
  /*  
   // rand_range_div_10
   task rand_range_div_10;
   input integer     start_num;
   input integer     end_num;
   output real       rnum;
   integer           temp;
   begin
   `SYS.RANDOM_RANGE(`SYS.seed_rr, start_num, end_num, temp);
   rnum = temp / 10.0;
    end
  endtask
   
   // rand_range_div_100
   task rand_range_div_100;
   input integer     start_num;
   input integer     end_num;
   output real       rnum;
   integer           temp;
   begin
   `SYS.RANDOM_RANGE(`SYS.seed_rr, start_num, end_num, temp);
   rnum = temp / 100.0;
    end
  endtask
   */

  // MIKE: DO not Force pvtscale on AC MDLR registers
  //       The DDR models will complain about changes in the CK0-3 and the command and address bus.
  
  // Task to insert RANDOM values within a range (0.7- 1.3) into the initial pvtscale 
  // of each LCDL or BDL. pvtScale at normal is 1.0
  task init_random_pvt;
    integer temp;
    integer i;
    begin
      pvtscale_ac_mdl = 1.0;

      // AC Address/Cmd BDL
      pvtscale_ac_cmd_addr_bdl = 1.0;

      // AC CK0, CK1, CK2 CK3 BDL
      pvtscale_ac_ck0_bdl = 1.0;
      pvtscale_ac_ck1_bdl = 1.0;
      pvtscale_ac_ck2_bdl = 1.0;
      pvtscale_ac_ck3_bdl = 1.0;
      

      $display("-> %0t: [PHYSYS] -------- DX INIT RANDOM PVT --------", $time);
`ifdef DWC_DDRPHY_X4X2  
      // all x4x2, x8only and x4 mode
      for (i=0;i<`DWC_NO_OF_BYTES*2;i=i+2) begin
`else
      // normal x8 mode
      for (i=0;i<pNUM_LANES;i=i+1) begin
`endif
        $display("-> %0t: [PHYSYS] -------- DX Lane = %0d --------", $time, i);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_ctl_wl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_ddr_wl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_ddr_wdq[i]);
`ifdef DWC_DDRPHY_X4X2
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_ctl_wl[i+1]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_ddr_wl[i+1]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_ddr_wdq[i+1]);
`endif

`ifdef DWC_DDRPHY_X4X2
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_mdl[i/2]);
`else
         if (i%pNO_OF_DQS == 0)
          `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_mdl[i/pNO_OF_DQS]);
`endif
        $display("-> %0t: [PHYSYS] pvtscale_ctl_wl[%0d]  = %f", $time, i, pvtscale_ctl_wl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_ddr_wl[%0d]  = %f", $time, i, pvtscale_ddr_wl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_ddr_wdq[%0d] = %f", $time, i, pvtscale_ddr_wdq[i]);
`ifdef DWC_DDRPHY_X4X2
        $display("-> %0t: [PHYSYS] pvtscale_dx_mdl[%0d]  = %f", $time, i/2, pvtscale_dx_mdl[i/2]);
`else
         if (i%pNO_OF_DQS == 0)
        $display("-> %0t: [PHYSYS] pvtscale_dx_mdl[%0d]  = %f", $time, i, pvtscale_dx_mdl[i/pNO_OF_DQS]);
`endif
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_gdqs[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_rdqs[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_rdqsn[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_rdqsgs[i]);
        $display("-> %0t: [PHYSYS] pvtscale_gdqs[%0d] = %f", $time, i, pvtscale_gdqs[i]);
        $display("-> %0t: [PHYSYS] pvtscale_rdqs[%0d] = %f", $time, i, pvtscale_rdqs[i]);
        $display("-> %0t: [PHYSYS] pvtscale_rdqsn[%0d] = %f", $time, i, pvtscale_rdqsn[i]);
        $display("-> %0t: [PHYSYS] pvtscale_rdqsgs[%0d] = %f", $time, i, pvtscale_rdqsgs[i]);
        $display("");

`ifdef DWC_DDRPHY_X4X2
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_gdqs[i+1]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_rdqs[i+1]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_rdqsn[i+1]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_rdqsgs[i+1]);
`endif
        
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq0_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq1_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq2_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq3_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq4_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq5_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq6_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdq7_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wdqm_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_wds_bdl[i]);


        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq0_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq0_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq1_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq1_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq2_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq2_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq3_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq3_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq4_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq4_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq5_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq5_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq6_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq6_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq7_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq7_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdqm_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdqm_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wds_bdl[%0d]   = %f", $time, i, pvtscale_dx_wds_bdl[i]);
        $display("");

        
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq0_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq1_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq2_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq3_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq4_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq5_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq6_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdq7_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rdqm_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_rds_bdl[i]);


        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq0_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq0_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq1_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq1_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq2_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq2_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq3_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq3_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq4_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq4_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq5_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq5_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq6_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq6_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq7_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq7_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdqm_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdqm_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rds_bdl[%0d]   = %f", $time, i, pvtscale_dx_rds_bdl[i]);
        $display("");


        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_dqsoe_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_dqsoe_bdl[%0d]  = %f", $time, i, pvtscale_dx_dqsoe_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_dqoe_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_dqoe_bdl[%0d]  = %f", $time, i, pvtscale_dx_dqoe_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_pdd_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_pdd_bdl[%0d]  = %f", $time, i, pvtscale_dx_pdd_bdl[i]);
        `SYS.rand_range_div_10(pvt_start_range, pvt_stop_range, pvtscale_dx_pdr_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_pdr_bdl[%0d]  = %f", $time, i, pvtscale_dx_pdr_bdl[i]);

        $display("");

      end

    end
  endtask // init_random_pvt
  
  // Task to initialize all pvtscale to 1.0 normal
  task normal_pvtscale;
    input real pvt_value;
    
    integer temp;
    integer i;
    begin
      pvtscale_ac_mdl = pvt_value;
      pvtscale_ac_cmd_addr_bdl = pvt_value;
      pvtscale_ac_ck0_bdl = pvt_value;
      pvtscale_ac_ck1_bdl = pvt_value;
      pvtscale_ac_ck2_bdl = pvt_value;
      pvtscale_ac_ck3_bdl = pvt_value;
      
      $display("-> %0t: [PHYSYS] -------- DX NORMALIZE PVTSCALE --------", $time);
`ifdef DWC_DDRPHY_X4X2  
      // all x4x2, x8only and x4 mode
      for (i=0;i<`DWC_NO_OF_BYTES*2;i=i+2) begin
`else
      // normal x8 mode
      for (i=0;i<pNUM_LANES;i=i+1) begin
`endif
        $display("-> %0t: [PHYSYS] -------- DX Lane = %0d --------", $time, i);
        pvtscale_ctl_wl[i]  = pvt_value;
        pvtscale_ddr_wl[i]  = pvt_value;
        pvtscale_ddr_wdq[i] = pvt_value;
`ifdef DWC_DDRPHY_X4X2
        pvtscale_dx_mdl[i/2]  = pvt_value;
`else
        if (i%pNO_OF_DQS == 0)
          pvtscale_dx_mdl[i]  = pvt_value;
`endif
        $display("-> %0t: [PHYSYS] pvtscale_ctl_wl[%0d]  = %f", $time, i, pvtscale_ctl_wl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_ddr_wl[%0d]  = %f", $time, i, pvtscale_ddr_wl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_ddr_wdq[%0d] = %f", $time, i, pvtscale_ddr_wdq[i]);
`ifdef DWC_DDRPHY_X4X2
        $display("-> %0t: [PHYSYS] pvtscale_dx_mdl[%0d]  = %f", $time, i/2, pvtscale_dx_mdl[i/2]);
`else
        if (i%pNO_OF_DQS == 0)
          $display("-> %0t: [PHYSYS] pvtscale_dx_mdl[%0d]  = %f", $time, i, pvtscale_dx_mdl[i/pNO_OF_DQS]);
`endif
        pvtscale_gdqs[i]  = pvt_value;
        pvtscale_rdqs[i]  = pvt_value;
        pvtscale_rdqsn[i] = pvt_value;
        pvtscale_rdqsgs[i]  = pvt_value;
        $display("-> %0t: [PHYSYS] pvtscale_gdqs[%0d] = %f", $time, i, pvtscale_gdqs[i]);
        $display("-> %0t: [PHYSYS] pvtscale_rdqs[%0d] = %f", $time, i, pvtscale_rdqs[i]);
        $display("-> %0t: [PHYSYS] pvtscale_rdqsn[%0d] = %f", $time, i, pvtscale_rdqsn[i]);
        $display("-> %0t: [PHYSYS] pvtscale_rdqsgs[%0d] = %f", $time, i, pvtscale_rdqsgs[i]);
        $display("");

        pvtscale_dx_wdq0_bdl[i] = pvt_value;
        pvtscale_dx_wdq1_bdl[i] = pvt_value;
        pvtscale_dx_wdq2_bdl[i] = pvt_value;
        pvtscale_dx_wdq3_bdl[i] = pvt_value;
        pvtscale_dx_wdq4_bdl[i] = pvt_value;
        pvtscale_dx_wdq5_bdl[i] = pvt_value;
        pvtscale_dx_wdq6_bdl[i] = pvt_value;
        pvtscale_dx_wdq7_bdl[i] = pvt_value;
        pvtscale_dx_wdqm_bdl[i] = pvt_value;
        pvtscale_dx_wds_bdl[i]  = pvt_value;


        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq0_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq0_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq1_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq1_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq2_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq2_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq3_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq3_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq4_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq4_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq5_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq5_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq6_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq6_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdq7_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdq7_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wdqm_bdl[%0d]  = %f", $time, i, pvtscale_dx_wdqm_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_wds_bdl[%0d]   = %f", $time, i, pvtscale_dx_wds_bdl[i]);
        $display("");

        
        pvtscale_dx_rdq0_bdl[i] = pvt_value;
        pvtscale_dx_rdq1_bdl[i] = pvt_value;
        pvtscale_dx_rdq2_bdl[i] = pvt_value;
        pvtscale_dx_rdq3_bdl[i] = pvt_value;
        pvtscale_dx_rdq4_bdl[i] = pvt_value;
        pvtscale_dx_rdq5_bdl[i] = pvt_value;
        pvtscale_dx_rdq6_bdl[i] = pvt_value;
        pvtscale_dx_rdq7_bdl[i] = pvt_value;
        pvtscale_dx_rdqm_bdl[i] = pvt_value;
        pvtscale_dx_rds_bdl[i]  = pvt_value;


        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq0_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq0_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq1_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq1_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq2_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq2_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq3_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq3_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq4_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq4_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq5_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq5_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq6_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq6_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdq7_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdq7_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rdqm_bdl[%0d]  = %f", $time, i, pvtscale_dx_rdqm_bdl[i]);
        $display("-> %0t: [PHYSYS] pvtscale_dx_rds_bdl[%0d]   = %f", $time, i, pvtscale_dx_rds_bdl[i]);
        $display("");


        pvtscale_dx_dqsoe_bdl[i] = pvt_value;
        $display("-> %0t: [PHYSYS] pvtscale_dx_dqsoe_bdl[%0d]  = %f", $time, i, pvtscale_dx_dqsoe_bdl[i]);
        pvtscale_dx_dqoe_bdl[i]  = pvt_value;
        $display("-> %0t: [PHYSYS] pvtscale_dx_dqoe_bdl[%0d]  = %f", $time, i, pvtscale_dx_dqoe_bdl[i]);
        pvtscale_dx_pdd_bdl[i]  = pvt_value;
        $display("-> %0t: [PHYSYS] pvtscale_dx_pdd_bdl[%0d]  = %f", $time, i, pvtscale_dx_pdd_bdl[i]);
        pvtscale_dx_pdr_bdl[i]  = pvt_value;
        $display("-> %0t: [PHYSYS] pvtscale_dx_pdr_bdl[%0d]  = %f", $time, i, pvtscale_dx_pdr_bdl[i]);
        $display("");

      end

     end
  endtask // normal_pvtscale
  
  // AC LCDL MDL 
  // always block to go bring back the initial pvt settings (ie: values after reset)
  // It would release whatever force that were placed on all PVT scale
  
  // always block to set new PVT scale with multiplier to trigger VT difference

  // AC Address/CMD BDL, AC CK0BD, CK1BD, CK2BD
  // always block to go bring back the initial pvt settings (ie: values after reset)
  // It would release whatever force that were placed on all PVT scale
  // NB: For all AC BDL ADDR/CMD, use ac_a_0 as a reference
  
  // always block to set new PVT scale with multiplier to trigger VT difference
  // use ac_a_0 as a reference
  
// **TBD:G2MPHY
//ROB  always @(e_force_initial_pvt) begin
//ROB    
//ROB    if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING INITIAL AC LCDL PVT VALUES in progress", $time);
//ROB    release `AC_DDR_LCDL_PATH.pvtscale;
//ROB    release `AC_CTL_LCDL_PATH.pvtscale;
//ROB    release `AC_MDL_LCDL_PATH.pvtscale;
//ROB
//ROB    force `AC_DDR_LCDL_PATH.pvtscale  =;
//ROB  end
  // DATX8
`ifndef GATE_LEVEL_SIM
  generate
`ifdef DWC_DDRPHY_X4X2  
    // all x4x2, x8only and x4 mode
    for (dwc_byte=0;dwc_byte<`DWC_NO_OF_BYTES*2;dwc_byte=dwc_byte+2) begin: INIT_PVT
`else
    // normal x8 mode
    for (dwc_byte=0;dwc_byte<pNUM_LANES;dwc_byte=dwc_byte+pNO_OF_DQS) begin: INIT_PVT
`endif
      // DX LCDL pvtscale
      // always block to go bring back the initial pvt settings (ie: values after reset)
      // It would release whatever force that were placed on all PVT scale
`ifdef DWC_DDRPHY_EMUL
`else
       always @(e_force_initial_pvt) begin
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING INITIAL DATX8 LCDL PVT VALUES in progress", $time);
          release `DXn.`CTL_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`CTL_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`DX_MDL_LCDL_PATH.pvtscale;
          
          release `DXn.`GDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQSN_LCDL_PATH.pvtscale;
          release `DXn.`RDQSGS_LCDL_PATH.pvtscale;
          force `DXn.`CTL_WL_LCDL_PATH.pvtscale  = pvtscale_ctl_wl[dwc_byte]; 
          force `DXn.`DDR_WL_LCDL_PATH.pvtscale  = pvtscale_ddr_wl[dwc_byte]; 
          force `DXn.`DDR_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[dwc_byte];
          force `DXn.`CTL_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[dwc_byte];
`ifdef DWC_DDRPHY_X4X2
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = pvtscale_dx_mdl[dwc_byte/2];
`else
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = pvtscale_dx_mdl[dwc_byte/pNO_OF_DQS];
`endif
          force `DXn.`GDQS_LCDL_PATH.pvtscale    = pvtscale_gdqs[dwc_byte];   
          force `DXn.`RDQS_LCDL_PATH.pvtscale    = pvtscale_rdqs[dwc_byte];   
          force `DXn.`RDQSN_LCDL_PATH.pvtscale   = pvtscale_rdqsn[dwc_byte];  
          force `DXn.`RDQSGS_LCDL_PATH.pvtscale  = pvtscale_rdqsgs[dwc_byte]; 
          
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4CTL_WL_LCDL_PATH.pvtscale  = pvtscale_ctl_wl[(dwc_byte)+1]; 
          force `DXn.`X4DDR_WL_LCDL_PATH.pvtscale  = pvtscale_ddr_wl[(dwc_byte)+1]; 
          force `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[(dwc_byte)+1];
          force `DXn.`X4CTL_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[(dwc_byte)+1];
          
          force `DXn.`X4GDQS_LCDL_PATH.pvtscale    = pvtscale_gdqs[(dwc_byte)+1];
          force `DXn.`X4RDQS_LCDL_PATH.pvtscale    = pvtscale_rdqs[(dwc_byte)+1];
          force `DXn.`X4RDQSN_LCDL_PATH.pvtscale   = pvtscale_rdqsn[(dwc_byte)+1];
          force `DXn.`X4RDQSGS_LCDL_PATH.pvtscale  = pvtscale_rdqsgs[(dwc_byte)+1];
          
 `endif //  `ifdef DWC_DDRPHY_X4MODE
          
       end

      // DX BDL pvtscale
      // always block to go bring back the initial pvt settings (ie: values after reset)
      // It would release whatever force that were placed on all PVT scale
       always @(e_force_initial_pvt) begin
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING INITIAL DATX8 BDL PVT VALUES in progress", $time);
          release `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4X2
          release `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale;
 `endif        
          release `DXn.`DSW_BDL_PATH.pvtscale;
          
          release `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4X2
          release `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale;
 `endif        
          release `DXn.`DSR_BDL_PATH.pvtscale;
          release `DXn.`DSOE_BDL_PATH.pvtscale;
          release `DXn.`DQOE_BDL_PATH.pvtscale;
          release `DXn.`PDD_BDL_PATH.pvtscale;
          release `DXn.`PDR_BDL_PATH.pvtscale;
          
 `ifdef DWC_DDRPHY_X4MODE

          release `DXn.`X4DSW_BDL_PATH.pvtscale;
          release `DXn.`X4DSR_BDL_PATH.pvtscale;
          release `DXn.`X4DSOE_BDL_PATH.pvtscale;
          release `DXn.`X4DQOE_BDL_PATH.pvtscale;
          release `DXn.`X4PDD_BDL_PATH.pvtscale;
          release `DXn.`X4PDR_BDL_PATH.pvtscale;
 `endif
          
          force `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq0_bdl[dwc_byte];                          
          force `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq1_bdl[dwc_byte];                          
          force `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq2_bdl[dwc_byte];                          
          force `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq3_bdl[dwc_byte];                          
          force `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq4_bdl[dwc_byte];  
          force `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq5_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq6_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq7_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdqm_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];

 `ifdef DWC_DDRPHY_X4X2
          force `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_x4wdqm_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
 `endif        
          force `DXn.`DSW_BDL_PATH.pvtscale  = pvtscale_dx_wds_bdl[dwc_byte];
          
          force `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq0_bdl[dwc_byte];
          force `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq1_bdl[dwc_byte];
          force `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq2_bdl[dwc_byte];
          force `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq3_bdl[dwc_byte];
          force `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq4_bdl[dwc_byte];
          force `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
 `ifdef DWC_DDRPHY_X4X2
          force `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_x4rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
 `endif        
          force `DXn.`DSR_BDL_PATH.pvtscale  = pvtscale_dx_rds_bdl[dwc_byte];
          
          force `DXn.`DSOE_BDL_PATH.pvtscale  = pvtscale_dx_dqsoe_bdl[dwc_byte];
          force `DXn.`DQOE_BDL_PATH.pvtscale  = pvtscale_dx_dqoe_bdl[dwc_byte];
          force `DXn.`PDD_BDL_PATH.pvtscale   = pvtscale_dx_pdd_bdl[dwc_byte];
          force `DXn.`PDR_BDL_PATH.pvtscale   = pvtscale_dx_pdr_bdl[dwc_byte];
          

 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4DSW_BDL_PATH.pvtscale  = pvtscale_dx_wds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4DSR_BDL_PATH.pvtscale  = pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4DSOE_BDL_PATH.pvtscale  = pvtscale_dx_dqsoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4DQOE_BDL_PATH.pvtscale  = pvtscale_dx_dqoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4PDD_BDL_PATH.pvtscale   = pvtscale_dx_pdd_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4PDR_BDL_PATH.pvtscale   = pvtscale_dx_pdr_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
 `endif        
       end // always @ (e_force_initial_pvt)
       
`endif // !`ifdef DWC_DDRPHY_EMUL
       
  

`ifdef DWC_DDRPHY_EMUL
`else
      // DX LCDL Force new PVT MULTIPLIER
      // always block to set new PVT scale with multiplier to trigger VT difference
       always @(e_force_pvt_with_multipler) begin 
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING DATX8 PVT VALUES in LCDL WITH MULTIPLER in progress", $time);
          
          tmp_pvtscale_ctl_wl[dwc_byte]  = `DXn.`CTL_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wl[dwc_byte]  = `DXn.`DDR_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wdq[dwc_byte] = `DXn.`DDR_WDQ_LCDL_PATH.pvtscale;
`ifdef DWC_DDRPHY_X4X2
          tmp_pvtscale_dx_mdl[dwc_byte/2]           = `DXn.`DX_MDL_LCDL_PATH.pvtscale;
`else
          tmp_pvtscale_dx_mdl[dwc_byte/pNO_OF_DQS]  = `DXn.`DX_MDL_LCDL_PATH.pvtscale;
`endif
          tmp_pvtscale_gdqs[dwc_byte]    = `DXn.`GDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqs[dwc_byte]    = `DXn.`RDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsn[dwc_byte]   = `DXn.`RDQSN_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsgs[dwc_byte]  = `DXn.`RDQSGS_LCDL_PATH.pvtscale;

 `ifdef DWC_DDRPHY_X4MODE
          
          tmp_pvtscale_ctl_wl[(dwc_byte)  + 1]  = `DXn.`X4CTL_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wl[(dwc_byte)  + 1]  = `DXn.`X4DDR_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wdq[(dwc_byte) + 1] = `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale;
          tmp_pvtscale_gdqs[(dwc_byte)    + 1]    = `DXn.`X4GDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqs[(dwc_byte)    + 1]    = `DXn.`X4RDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsn[(dwc_byte)   + 1]   = `DXn.`X4RDQSN_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsgs[(dwc_byte)  + 1]  = `DXn.`X4RDQSGS_LCDL_PATH.pvtscale;
 `endif //  `ifdef DWC_DDRPHY_X4MODE
          
          
          release `DXn.`CTL_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`DX_MDL_LCDL_PATH.pvtscale;
          release `DXn.`GDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQSN_LCDL_PATH.pvtscale;
          release `DXn.`RDQSGS_LCDL_PATH.pvtscale;

 `ifdef DWC_DDRPHY_X4MODE
          release `DXn.`X4CTL_WL_LCDL_PATH.pvtscale;
          release `DXn.`X4DDR_WL_LCDL_PATH.pvtscale;
          release `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`X4GDQS_LCDL_PATH.pvtscale;
          release `DXn.`X4RDQS_LCDL_PATH.pvtscale;
          release `DXn.`X4RDQSN_LCDL_PATH.pvtscale;
          release `DXn.`X4RDQSGS_LCDL_PATH.pvtscale;
 `endif
          

          force `DXn.`CTL_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ctl_wl[dwc_byte]  * pvt_multiplier;
          force `DXn.`DDR_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ddr_wl[dwc_byte]  * pvt_multiplier;
          force `DXn.`DDR_WDQ_LCDL_PATH.pvtscale = tmp_pvtscale_ddr_wdq[dwc_byte] * pvt_multiplier;
`ifdef DWC_DDRPHY_X4X2
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = tmp_pvtscale_dx_mdl[dwc_byte/2]  * pvt_multiplier;
`else
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = tmp_pvtscale_dx_mdl[dwc_byte/pNO_OF_DQS]  * pvt_multiplier;
`endif
          force `DXn.`GDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_gdqs[dwc_byte]    * pvt_multiplier;
          force `DXn.`RDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqs[dwc_byte]    * pvt_multiplier;
          force `DXn.`RDQSN_LCDL_PATH.pvtscale   = tmp_pvtscale_rdqsn[dwc_byte]   * pvt_multiplier;
          force `DXn.`RDQSGS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqsgs[dwc_byte]    * pvt_multiplier;

 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4CTL_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ctl_wl[(dwc_byte)   + 1]  * pvt_multiplier;
          force `DXn.`X4DDR_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ddr_wl[(dwc_byte)   + 1]  * pvt_multiplier;
          force `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale = tmp_pvtscale_ddr_wdq[(dwc_byte)  + 1]  * pvt_multiplier;
          force `DXn.`X4GDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_gdqs[(dwc_byte)     + 1]  * pvt_multiplier;
          force `DXn.`X4RDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqs[(dwc_byte)     + 1]  * pvt_multiplier;
          force `DXn.`X4RDQSN_LCDL_PATH.pvtscale   = tmp_pvtscale_rdqsn[(dwc_byte)    + 1]  * pvt_multiplier;
          force `DXn.`X4RDQSGS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqsgs[(dwc_byte) + 1]  * pvt_multiplier;
 `endif
          
          
       end
    
       always @(e_force_GDQS_pvt_with_x_multipler) begin 
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING DATX8 PVT VALUES in GDQS LCDL WITH 2 TIMES MULTIPLER in progress", $time);
          force `DXn.`GDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_gdqs[dwc_byte]    * pvt_multiplier * x_multiplier  ;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4GDQS_LCDL_PATH.pvtscale  = tmp_pvtscale_gdqs[(dwc_byte) + 1]    * pvt_multiplier * x_multiplier  ;
 `endif
       end
    
      
      // DX BDL Force new PVT MULTIPLIER
      // always block to set new PVT scale with multiplier to trigger VT difference
       always @(e_force_pvt_with_multipler) begin 
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING DATX8 PVT VALUES IN BDL WITH MULTIPLER in progress", $time);
          
          tmp_pvtscale_dx_wdq0_bdl[dwc_byte]  = `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq1_bdl[dwc_byte]  = `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq2_bdl[dwc_byte]  = `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq3_bdl[dwc_byte]  = `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq4_bdl[dwc_byte]  = `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4MODE
          tmp_pvtscale_dx_x4wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale;
 `endif

          
          tmp_pvtscale_dx_wds_bdl[(dwc_byte)]   = `DXn.`DSW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq0_bdl[dwc_byte]  = `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq1_bdl[dwc_byte]  = `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq2_bdl[dwc_byte]  = `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq3_bdl[dwc_byte]  = `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq4_bdl[dwc_byte]  = `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4MODE
          tmp_pvtscale_dx_x4rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale;
 `endif
          tmp_pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`DSR_BDL_PATH.pvtscale;
          
          tmp_pvtscale_dx_dqsoe_bdl[dwc_byte*pNO_OF_DQS]  = `DXn.`DSOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_dqoe_bdl[dwc_byte*pNO_OF_DQS]   = `DXn.`DQOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdd_bdl[dwc_byte*pNO_OF_DQS]    = `DXn.`PDD_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdr_bdl[dwc_byte*pNO_OF_DQS]    = `DXn.`PDR_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4MODE

          tmp_pvtscale_dx_wds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`X4DSW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`X4DSR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_dqsoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.`X4DSOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_dqoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`X4DQOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdd_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]    = `DXn.`X4PDD_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdr_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]    = `DXn.`X4PDR_BDL_PATH.pvtscale;
 `endif    
          release `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale;
          release `DXn.`DMW_BDL_PATH.pvtscale;
          release `DXn.`DSW_BDL_PATH.pvtscale;
          
          release `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale;
          release `DXn.`DMR_BDL_PATH.pvtscale;
          release `DXn.`DSR_BDL_PATH.pvtscale;
          
          release `DXn.`DSOE_BDL_PATH.pvtscale;
          release `DXn.`DQOE_BDL_PATH.pvtscale;
          
 `ifdef DWC_DDRPHY_X4MODE
          release `DXn.`X4DSW_BDL_PATH.pvtscale;
          
          release `DXn.`X4DSR_BDL_PATH.pvtscale;
          
          release `DXn.`X4DSOE_BDL_PATH.pvtscale;
          release `DXn.`X4DQOE_BDL_PATH.pvtscale;


 `endif    
          
          force `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq0_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq1_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq2_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq3_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq4_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_x4wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `endif
          force `DXn.`DSW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wds_bdl[dwc_byte]   * pvt_multiplier;
          
          force `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq0_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq1_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq2_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq3_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq4_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_x4rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `endif
          force `DXn.`DSR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rds_bdl[dwc_byte]   * pvt_multiplier;
          
          force `DXn.`DSOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqsoe_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.`DQOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqoe_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.`PDD_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdd_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.`PDR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdr_bdl[dwc_byte]  * pvt_multiplier;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4DSW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   * pvt_multiplier;
          force `DXn.`X4DSR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   * pvt_multiplier;
          force `DXn.`X4DSOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqsoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.`X4DQOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.`X4PDD_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdd_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.`X4PDR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdr_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          
          
 `endif         
          
       end
`endif
  
    end // block: INIT_PVT
  endgenerate

// if GATE, but BUILD or GATE_SIM_EXCEPTION
`elsif DWC_DDRPHY_GATE_SIM_EXCEPT
  generate
`ifdef DWC_DDRPHY_X4X2  
    // all x4x2, x8only and x4 mode
    for (dwc_byte=0;dwc_byte<`DWC_NO_OF_BYTES*2;dwc_byte=dwc_byte+2) begin: INIT_PVT
`else
    // normal x8 mode
    for (dwc_byte=0;dwc_byte<pNUM_LANES;dwc_byte=dwc_byte+pNO_OF_DQS) begin: INIT_PVT
`endif
      // DX LCDL pvtscale
      // always block to go bring back the initial pvt settings (ie: values after reset)
      // It would release whatever force that were placed on all PVT scale
`ifdef DWC_DDRPHY_EMUL
`else
       always @(e_force_initial_pvt) begin
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING INITIAL DATX8 LCDL PVT VALUES in progress", $time);
          release `DXn.`CTL_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`CTL_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`DX_MDL_LCDL_PATH.pvtscale;
          
          release `DXn.`GDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQSN_LCDL_PATH.pvtscale;
          release `DXn.`RDQSGS_LCDL_PATH.pvtscale;
          force `DXn.`CTL_WL_LCDL_PATH.pvtscale  = pvtscale_ctl_wl[dwc_byte]; 
          force `DXn.`DDR_WL_LCDL_PATH.pvtscale  = pvtscale_ddr_wl[dwc_byte]; 
          force `DXn.`DDR_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[dwc_byte];
          force `DXn.`CTL_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[dwc_byte];
`ifdef DWC_DDRPHY_X4X2
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = pvtscale_dx_mdl[dwc_byte/2];
`else
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = pvtscale_dx_mdl[dwc_byte/pNO_OF_DQS];
`endif
          force `DXn.`GDQS_LCDL_PATH.pvtscale    = pvtscale_gdqs[dwc_byte];   
          force `DXn.`RDQS_LCDL_PATH.pvtscale    = pvtscale_rdqs[dwc_byte];   
          force `DXn.`RDQSN_LCDL_PATH.pvtscale   = pvtscale_rdqsn[dwc_byte];  
          force `DXn.`RDQSGS_LCDL_PATH.pvtscale  = pvtscale_rdqsgs[dwc_byte]; 
          
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4CTL_WL_LCDL_PATH.pvtscale  = pvtscale_ctl_wl[(dwc_byte)+1]; 
          force `DXn.`X4DDR_WL_LCDL_PATH.pvtscale  = pvtscale_ddr_wl[(dwc_byte)+1]; 
          force `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[(dwc_byte)+1];
          force `DXn.`X4CTL_WDQ_LCDL_PATH.pvtscale = pvtscale_ddr_wdq[(dwc_byte)+1];
          
          force `DXn.`X4GDQS_LCDL_PATH.pvtscale    = pvtscale_gdqs[(dwc_byte)+1];
          force `DXn.`X4RDQS_LCDL_PATH.pvtscale    = pvtscale_rdqs[(dwc_byte)+1];
          force `DXn.`X4RDQSN_LCDL_PATH.pvtscale   = pvtscale_rdqsn[(dwc_byte)+1];
          force `DXn.`X4RDQSGS_LCDL_PATH.pvtscale  = pvtscale_rdqsgs[(dwc_byte)+1];
          
 `endif //  `ifdef DWC_DDRPHY_X4MODE
          
       end

      // DX BDL pvtscale
      // always block to go bring back the initial pvt settings (ie: values after reset)
      // It would release whatever force that were placed on all PVT scale
       always @(e_force_initial_pvt) begin
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING INITIAL DATX8 BDL PVT VALUES in progress", $time);
          release `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4X2
          release `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale;
 `endif        
          release `DXn.`DSW_BDL_PATH.pvtscale;
          
          release `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4X2
          release `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale;
 `endif        
          release `DXn.`DSR_BDL_PATH.pvtscale;
          release `DXn.`DSOE_BDL_PATH.pvtscale;
          release `DXn.`DQOE_BDL_PATH.pvtscale;
          release `DXn.`PDD_BDL_PATH.pvtscale;
          release `DXn.`PDR_BDL_PATH.pvtscale;
          
 `ifdef DWC_DDRPHY_X4MODE

          release `DXn.`X4DSW_BDL_PATH.pvtscale;
          release `DXn.`X4DSR_BDL_PATH.pvtscale;
          release `DXn.`X4DSOE_BDL_PATH.pvtscale;
          release `DXn.`X4DQOE_BDL_PATH.pvtscale;
          release `DXn.`X4PDD_BDL_PATH.pvtscale;
          release `DXn.`X4PDR_BDL_PATH.pvtscale;
 `endif
          
          force `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq0_bdl[dwc_byte];                          
          force `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq1_bdl[dwc_byte];                          
          force `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq2_bdl[dwc_byte];                          
          force `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq3_bdl[dwc_byte];                          
          force `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq4_bdl[dwc_byte];  
          force `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq5_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq6_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdq7_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_wdqm_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
 `ifdef DWC_DDRPHY_X4X2
          force `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale  = pvtscale_dx_x4wdqm_bdl[dwc_byte + (dwc_byte%pNO_OF_DQS)];
 `endif        
          force `DXn.`DSW_BDL_PATH.pvtscale  = pvtscale_dx_wds_bdl[dwc_byte];
          
          force `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq0_bdl[dwc_byte];
          force `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq1_bdl[dwc_byte];
          force `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq2_bdl[dwc_byte];
          force `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq3_bdl[dwc_byte];
          force `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq4_bdl[dwc_byte];
          force `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
 `ifdef DWC_DDRPHY_X4X2
          force `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale  = pvtscale_dx_x4rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
 `endif        
          force `DXn.`DSR_BDL_PATH.pvtscale  = pvtscale_dx_rds_bdl[dwc_byte];
          
          force `DXn.`DSOE_BDL_PATH.pvtscale  = pvtscale_dx_dqsoe_bdl[dwc_byte];
          force `DXn.`DQOE_BDL_PATH.pvtscale  = pvtscale_dx_dqoe_bdl[dwc_byte];
          force `DXn.`PDD_BDL_PATH.pvtscale   = pvtscale_dx_pdd_bdl[dwc_byte];
          force `DXn.`PDR_BDL_PATH.pvtscale   = pvtscale_dx_pdr_bdl[dwc_byte];
          

 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4DSW_BDL_PATH.pvtscale  = pvtscale_dx_wds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4DSR_BDL_PATH.pvtscale  = pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4DSOE_BDL_PATH.pvtscale  = pvtscale_dx_dqsoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4DQOE_BDL_PATH.pvtscale  = pvtscale_dx_dqoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4PDD_BDL_PATH.pvtscale   = pvtscale_dx_pdd_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
          force `DXn.`X4PDR_BDL_PATH.pvtscale   = pvtscale_dx_pdr_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)];
 `endif        
       end // always @ (e_force_initial_pvt)
       
`endif // !`ifdef DWC_DDRPHY_EMUL
       
  

`ifdef DWC_DDRPHY_EMUL
`else
      // DX LCDL Force new PVT MULTIPLIER
      // always block to set new PVT scale with multiplier to trigger VT difference
       always @(e_force_pvt_with_multipler) begin 
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING DATX8 PVT VALUES in LCDL WITH MULTIPLER in progress", $time);
          
          tmp_pvtscale_ctl_wl[dwc_byte]  = `DXn.`CTL_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wl[dwc_byte]  = `DXn.`DDR_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wdq[dwc_byte] = `DXn.`DDR_WDQ_LCDL_PATH.pvtscale;
`ifdef DWC_DDRPHY_X4X2
          tmp_pvtscale_dx_mdl[dwc_byte/2]           = `DXn.`DX_MDL_LCDL_PATH.pvtscale;
`else
          tmp_pvtscale_dx_mdl[dwc_byte/pNO_OF_DQS]  = `DXn.`DX_MDL_LCDL_PATH.pvtscale;
`endif
          tmp_pvtscale_gdqs[dwc_byte]    = `DXn.`GDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqs[dwc_byte]    = `DXn.`RDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsn[dwc_byte]   = `DXn.`RDQSN_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsgs[dwc_byte]  = `DXn.`RDQSGS_LCDL_PATH.pvtscale;

 `ifdef DWC_DDRPHY_X4MODE
          
          tmp_pvtscale_ctl_wl[(dwc_byte)  + 1]  = `DXn.`X4CTL_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wl[(dwc_byte)  + 1]  = `DXn.`X4DDR_WL_LCDL_PATH.pvtscale;
          tmp_pvtscale_ddr_wdq[(dwc_byte) + 1]  = `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale;
          tmp_pvtscale_gdqs[(dwc_byte)    + 1]  = `DXn.`X4GDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqs[(dwc_byte)    + 1]  = `DXn.`X4RDQS_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsn[(dwc_byte)   + 1]  = `DXn.`X4RDQSN_LCDL_PATH.pvtscale;
          tmp_pvtscale_rdqsgs[(dwc_byte)  + 1]  = `DXn.`X4RDQSGS_LCDL_PATH.pvtscale;
 `endif //  `ifdef DWC_DDRPHY_X4MODE
          
          
          release `DXn.`CTL_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WL_LCDL_PATH.pvtscale;
          release `DXn.`DDR_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`DX_MDL_LCDL_PATH.pvtscale;
          release `DXn.`GDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQS_LCDL_PATH.pvtscale;
          release `DXn.`RDQSN_LCDL_PATH.pvtscale;
          release `DXn.`RDQSGS_LCDL_PATH.pvtscale;

 `ifdef DWC_DDRPHY_X4MODE
          release `DXn.`X4CTL_WL_LCDL_PATH.pvtscale;
          release `DXn.`X4DDR_WL_LCDL_PATH.pvtscale;
          release `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale;
          release `DXn.`X4GDQS_LCDL_PATH.pvtscale;
          release `DXn.`X4RDQS_LCDL_PATH.pvtscale;
          release `DXn.`X4RDQSN_LCDL_PATH.pvtscale;
          release `DXn.`X4RDQSGS_LCDL_PATH.pvtscale;
 `endif
          

          force `DXn.`CTL_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ctl_wl[dwc_byte]  * pvt_multiplier;
          force `DXn.`DDR_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ddr_wl[dwc_byte]  * pvt_multiplier;
          force `DXn.`DDR_WDQ_LCDL_PATH.pvtscale = tmp_pvtscale_ddr_wdq[dwc_byte] * pvt_multiplier;
`ifdef DWC_DDRPHY_X4X2
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = tmp_pvtscale_dx_mdl[dwc_byte/2]  * pvt_multiplier;
`else
          force `DXn.`DX_MDL_LCDL_PATH.pvtscale  = tmp_pvtscale_dx_mdl[dwc_byte/pNO_OF_DQS]  * pvt_multiplier;
`endif
          force `DXn.`GDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_gdqs[dwc_byte]    * pvt_multiplier;
          force `DXn.`RDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqs[dwc_byte]    * pvt_multiplier;
          force `DXn.`RDQSN_LCDL_PATH.pvtscale   = tmp_pvtscale_rdqsn[dwc_byte]   * pvt_multiplier;
          force `DXn.`RDQSGS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqsgs[dwc_byte]    * pvt_multiplier;

 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4CTL_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ctl_wl[(dwc_byte)   + 1]  * pvt_multiplier;
          force `DXn.`X4DDR_WL_LCDL_PATH.pvtscale  = tmp_pvtscale_ddr_wl[(dwc_byte)   + 1]  * pvt_multiplier;
          force `DXn.`X4DDR_WDQ_LCDL_PATH.pvtscale = tmp_pvtscale_ddr_wdq[(dwc_byte)  + 1]  * pvt_multiplier;
          force `DXn.`X4GDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_gdqs[(dwc_byte)     + 1]  * pvt_multiplier;
          force `DXn.`X4RDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqs[(dwc_byte)     + 1]  * pvt_multiplier;
          force `DXn.`X4RDQSN_LCDL_PATH.pvtscale   = tmp_pvtscale_rdqsn[(dwc_byte)    + 1]  * pvt_multiplier;
          force `DXn.`X4RDQSGS_LCDL_PATH.pvtscale    = tmp_pvtscale_rdqsgs[(dwc_byte) + 1]  * pvt_multiplier;
 `endif
          
          
       end
    
       always @(e_force_GDQS_pvt_with_x_multipler) begin 
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING DATX8 PVT VALUES in GDQS LCDL WITH 2 TIMES MULTIPLER in progress", $time);
          force `DXn.`GDQS_LCDL_PATH.pvtscale    = tmp_pvtscale_gdqs[dwc_byte]    * pvt_multiplier * x_multiplier  ;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4GDQS_LCDL_PATH.pvtscale  = tmp_pvtscale_gdqs[(dwc_byte) + 1]    * pvt_multiplier * x_multiplier  ;
 `endif
       end
    
      
      // DX BDL Force new PVT MULTIPLIER
      // always block to set new PVT scale with multiplier to trigger VT difference
       always @(e_force_pvt_with_multipler) begin 
          if (verbose > pvt_debug) $display("-> %0t: [PHYSYS] FORCING DATX8 PVT VALUES IN BDL WITH MULTIPLER in progress", $time);
          
          tmp_pvtscale_dx_wdq0_bdl[dwc_byte]  = `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq1_bdl[dwc_byte]  = `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq2_bdl[dwc_byte]  = `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq3_bdl[dwc_byte]  = `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq4_bdl[dwc_byte]  = `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4MODE
          tmp_pvtscale_dx_x4wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale;
 `endif

          
          tmp_pvtscale_dx_wds_bdl[(dwc_byte)]   = `DXn.`DSW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq0_bdl[dwc_byte]  = `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq1_bdl[dwc_byte]  = `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq2_bdl[dwc_byte]  = `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq3_bdl[dwc_byte]  = `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq4_bdl[dwc_byte]  = `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4MODE
          tmp_pvtscale_dx_x4rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale;
 `endif
          tmp_pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`DSR_BDL_PATH.pvtscale;
          
          tmp_pvtscale_dx_dqsoe_bdl[dwc_byte*pNO_OF_DQS]  = `DXn.`DSOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_dqoe_bdl[dwc_byte*pNO_OF_DQS]   = `DXn.`DQOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdd_bdl[dwc_byte*pNO_OF_DQS]    = `DXn.`PDD_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdr_bdl[dwc_byte*pNO_OF_DQS]    = `DXn.`PDR_BDL_PATH.pvtscale;
 `ifdef DWC_DDRPHY_X4MODE

          tmp_pvtscale_dx_wds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`X4DSW_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`X4DSR_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_dqsoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  = `DXn.`X4DSOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_dqoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   = `DXn.`X4DQOE_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdd_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]    = `DXn.`X4PDD_BDL_PATH.pvtscale;
          tmp_pvtscale_dx_pdr_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]    = `DXn.`X4PDR_BDL_PATH.pvtscale;
 `endif    
          release `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale;
          release `DXn.`DMW_BDL_PATH.pvtscale;
          release `DXn.`DSW_BDL_PATH.pvtscale;
          
          release `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale;
          release `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale;
          release `DXn.`DMR_BDL_PATH.pvtscale;
          release `DXn.`DSR_BDL_PATH.pvtscale;
          
          release `DXn.`DSOE_BDL_PATH.pvtscale;
          release `DXn.`DQOE_BDL_PATH.pvtscale;
          
 `ifdef DWC_DDRPHY_X4MODE
          release `DXn.`X4DSW_BDL_PATH.pvtscale;
          
          release `DXn.`X4DSR_BDL_PATH.pvtscale;
          
          release `DXn.`X4DSOE_BDL_PATH.pvtscale;
          release `DXn.`X4DQOE_BDL_PATH.pvtscale;


 `endif    
          
          force `DXn.datx8_dq_0.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq0_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_1.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq1_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_2.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq2_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_3.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq3_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_4.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq4_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_5.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_6.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_7.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_8.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.datx8_dq_9.`DQW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_x4wdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `endif
          force `DXn.`DSW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wds_bdl[dwc_byte]   * pvt_multiplier;
          
          force `DXn.datx8_dq_0.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq0_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_1.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq1_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_2.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq2_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_3.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq3_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_4.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq4_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.datx8_dq_5.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq5_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_6.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq6_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_7.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdq7_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.datx8_dq_8.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.datx8_dq_9.`DQR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_x4rdqm_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
 `endif
          force `DXn.`DSR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rds_bdl[dwc_byte]   * pvt_multiplier;
          
          force `DXn.`DSOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqsoe_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.`DQOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqoe_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.`PDD_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdd_bdl[dwc_byte]  * pvt_multiplier;
          force `DXn.`PDR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdr_bdl[dwc_byte]  * pvt_multiplier;
 `ifdef DWC_DDRPHY_X4MODE
          force `DXn.`X4DSW_BDL_PATH.pvtscale  = tmp_pvtscale_dx_wds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   * pvt_multiplier;
          force `DXn.`X4DSR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_rds_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]   * pvt_multiplier;
          force `DXn.`X4DSOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqsoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.`X4DQOE_BDL_PATH.pvtscale = tmp_pvtscale_dx_dqoe_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.`X4PDD_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdd_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          force `DXn.`X4PDR_BDL_PATH.pvtscale  = tmp_pvtscale_dx_pdr_bdl[(dwc_byte) + (dwc_byte%pNO_OF_DQS)]  * pvt_multiplier;
          
          
 `endif         
          
       end
`endif
  
    end // block: INIT_PVT
  endgenerate
  
`endif // ifndef GATE_LEVEL_SIM

  task store_last_pvt_multiplier;
    begin
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        prev_actual_pvt_multiplier[i] = last_actual_pvt_multiplier[i];
        last_actual_pvt_multiplier[i] = actual_pvt_multiplier[i];
      end
    end
  endtask // store_last_pvt_multiplier
  
  
  task update_with_init_force_pvt;
    begin
      // input: setting_init_value, new_multp, new_cal
      update_acmdlr(`TRUE, `FALSE, `TRUE);
      update_dxnmdlr(`TRUE, `FALSE, `TRUE, `FALSE);
      update_dxnlcdlr4(`TRUE, `FALSE, `TRUE, `FALSE, `FALSE);
      update_dxnlcdlr5(`TRUE, `FALSE, `TRUE, `FALSE, `FALSE);
      update_dxngsr0(`TRUE, `FALSE, `TRUE, `FALSE);
      // input: new_ca -> register goes back to LCDL_MIN which is zeros
      update_dxnlcdlr0(`TRUE,`FALSE,`FALSE);
      update_dxnlcdlr1(`TRUE, `FALSE, `TRUE, `FALSE, `FALSE);
      update_dxnlcdlr2(`TRUE,`FALSE,`FALSE);
      update_dxnlcdlr3(`TRUE, `FALSE, `TRUE, `FALSE, `FALSE);
`ifdef DWC_DDRPHY_X4MODE
       update_dxngsr4(`TRUE, `FALSE, `TRUE, `FALSE);
`endif
       
      update_acbdlr0(`TRUE, `FALSE);
      update_acbdlr1(`TRUE, `FALSE);
      update_acbdlr2(`TRUE, `FALSE);
      update_acbdlr3(`TRUE, `FALSE);
      update_acbdlr4(`TRUE, `FALSE);
      update_acbdlr5(`TRUE, `FALSE);
      update_acbdlr6(`TRUE, `FALSE);
      update_acbdlr7(`TRUE, `FALSE);
      update_acbdlr8(`TRUE, `FALSE);
      update_acbdlr9(`TRUE, `FALSE);
      update_dxnbdlr0(`TRUE, `FALSE);
      update_dxnbdlr1(`TRUE, `FALSE);
      update_dxnbdlr2(`TRUE, `FALSE);
      update_dxnbdlr3(`TRUE, `FALSE);
      update_dxnbdlr4(`TRUE, `FALSE);
      update_dxnbdlr5(`TRUE, `FALSE);
      update_dxnbdlr6(`TRUE, `FALSE);
`ifdef DWC_DDRPHY_X4MODE
       
       update_dxnbdlr7(`TRUE, `FALSE);
       update_dxnbdlr8(`TRUE, `FALSE);
       update_dxnbdlr9(`TRUE, `FALSE);
`endif
    end
  endtask // update_with_init_force_pvt

  task update_dx_mdl_after_vt_interrupt;
    begin
      update_acmdlr(`FALSE, `TRUE, `FALSE);
      update_dxnmdlr(`FALSE, `TRUE, `FALSE, `TRUE);
    end
  endtask // update_with_init_force_pvt
    
  task update_mdl_only_new_multp;
    begin
      //  input: setting_init_value, new_multp, new_cal
      update_acmdlr(`FALSE, `TRUE, `FALSE);
      update_dxnmdlr(`FALSE, `TRUE, `FALSE, `FALSE);
    end
  endtask // update_mdl_only_new_multp

  task update_mdl_only_new_multp_new_cal;
    begin
      //  input: setting_init_value, new_multp, new_cal
      update_acmdlr(`FALSE, `TRUE, `TRUE);
      update_dxnmdlr(`FALSE, `TRUE, `TRUE, `FALSE);
    end
  endtask // update_mdl_only_new_multp_new_cal
  

  // This group use the actual mdl values measured (as ratio) instead of the forced 
  // pvt multiplier ratio;
  // Actual measured/ read values might have offsets that would 
  task update_all_lane_new_multp;
    begin
      update_dxnlcdlr4(`FALSE, `TRUE, `FALSE, `FALSE, `FALSE);
      update_dxnlcdlr5(`FALSE, `TRUE, `FALSE, `FALSE, `FALSE);
      update_dxngsr0(`FALSE, `TRUE, `FALSE, `FALSE);
      // input: not new_ca -> no change
      update_dxnlcdlr0(`FALSE,`FALSE,`FALSE);
      update_dxnlcdlr1(`FALSE, `TRUE, `FALSE, `FALSE, `FALSE);
      update_dxnlcdlr2(`FALSE,`FALSE,`FALSE);
      update_dxnlcdlr3(`FALSE, `TRUE, `FALSE, `FALSE, `FALSE);
`ifdef DWC_DDRPHY_X4MODE
       update_dxngsr4(`FALSE, `TRUE, `FALSE, `FALSE);
`endif
       
      update_acbdlr0(`FALSE, `FALSE);
      update_acbdlr1(`FALSE, `FALSE);
      update_acbdlr2(`FALSE, `FALSE);
      update_acbdlr3(`FALSE, `FALSE);
      update_acbdlr4(`FALSE, `FALSE);
      update_acbdlr5(`FALSE, `FALSE);
      update_acbdlr6(`FALSE, `FALSE);
      update_acbdlr7(`FALSE, `FALSE);
      update_acbdlr8(`FALSE, `FALSE);
      update_acbdlr9(`FALSE, `FALSE);
      update_dxnbdlr0(`FALSE,`FALSE);
      update_dxnbdlr1(`FALSE,`FALSE);
      update_dxnbdlr2(`FALSE,`FALSE);
      update_dxnbdlr3(`FALSE,`FALSE);
      update_dxnbdlr4(`FALSE,`FALSE);
      update_dxnbdlr5(`FALSE,`FALSE);
      update_dxnbdlr6(`FALSE,`FALSE);
`ifdef DWC_DDRPHY_X4MODE
       update_dxnbdlr7(`FALSE,`FALSE);
       update_dxnbdlr8(`FALSE,`FALSE);
       update_dxnbdlr9(`FALSE,`FALSE);
`endif
    end
  endtask // update_all_lane_new_multp

  task update_all_lane_new_multp_new_cal;
    begin
      update_dxnlcdlr4(`FALSE, `TRUE, `TRUE, `FALSE, `FALSE);
      update_dxnlcdlr5(`FALSE, `TRUE, `TRUE, `FALSE, `FALSE);
      update_dxngsr0(`FALSE, `TRUE, `TRUE, `FALSE);
      // input: new_ca -> register goes back to LCDL_MIN which is zeros
      update_dxnlcdlr0(`TRUE,`FALSE,`FALSE);
      update_dxnlcdlr1(`FALSE, `TRUE, `TRUE, `FALSE, `FALSE);
      update_dxnlcdlr2(`TRUE,`FALSE,`FALSE);
      update_dxnlcdlr3(`FALSE, `TRUE, `TRUE, `FALSE, `FALSE);
`ifdef DWC_DDRPHY_X4MODE
       update_dxngsr4(`FALSE, `TRUE, `TRUE, `FALSE);
`endif
      update_acbdlr0(`FALSE, `TRUE);
      update_acbdlr1(`FALSE, `TRUE);
      update_acbdlr2(`FALSE, `TRUE);
      update_acbdlr3(`FALSE, `TRUE);
      update_acbdlr4(`FALSE, `TRUE);
      update_acbdlr5(`FALSE, `TRUE);
      update_acbdlr6(`FALSE, `TRUE);
      update_acbdlr7(`FALSE, `TRUE);
      update_acbdlr8(`FALSE, `TRUE);
      update_acbdlr9(`FALSE, `TRUE);
      update_dxnbdlr0(`FALSE,`FALSE);
      update_dxnbdlr1(`FALSE,`FALSE);
      update_dxnbdlr2(`FALSE,`FALSE);
      update_dxnbdlr3(`FALSE,`FALSE);
      update_dxnbdlr4(`FALSE,`FALSE);
      update_dxnbdlr5(`FALSE,`FALSE);
      update_dxnbdlr6(`FALSE,`FALSE);
`ifdef DWC_DDRPHY_X4MODE
       update_dxnbdlr7(`FALSE,`FALSE);
       update_dxnbdlr8(`FALSE,`FALSE);
       update_dxnbdlr9(`FALSE,`FALSE);
`endif
    end
  endtask // update_all_lane_new_multp_new_cal

   task update_all_lane_new_multp_vt_upd;
      begin
         update_dxnlcdlr4(`FALSE, `TRUE, `FALSE, `TRUE, `FALSE); 
         update_dxnlcdlr5(`FALSE, `TRUE, `FALSE, `TRUE, `FALSE); 
         update_dxngsr0(`FALSE, `TRUE, `FALSE, `TRUE); 
         // input: not new_ca -> no change
         update_dxnlcdlr0(`FALSE, `TRUE,`FALSE);
         update_dxnlcdlr1(`FALSE, `TRUE, `FALSE, `TRUE, `FALSE);
         update_dxnlcdlr2(`FALSE, `TRUE,`FALSE);
         update_dxnlcdlr3(`FALSE, `TRUE, `FALSE, `TRUE, `FALSE); 
`ifdef DWC_DDRPHY_X4MODE
         update_dxngsr4(`FALSE, `TRUE, `FALSE, `TRUE); 
`endif
         update_acbdlr0(`FALSE, `TRUE);
         update_acbdlr1(`FALSE, `TRUE);
         update_acbdlr2(`FALSE, `TRUE);
         update_acbdlr3(`FALSE, `TRUE);
         update_acbdlr4(`FALSE, `TRUE);
         update_acbdlr5(`FALSE, `TRUE);
         update_acbdlr6(`FALSE, `TRUE);
         update_acbdlr7(`FALSE, `TRUE);
         update_acbdlr8(`FALSE, `TRUE);
         update_acbdlr9(`FALSE, `TRUE);
         update_dxnbdlr0(`TRUE,`FALSE);
         update_dxnbdlr1(`TRUE,`FALSE);
         update_dxnbdlr2(`TRUE,`FALSE);
         update_dxnbdlr3(`TRUE,`FALSE);
         update_dxnbdlr4(`TRUE,`FALSE);
         update_dxnbdlr5(`TRUE,`FALSE);
         update_dxnbdlr6(`TRUE,`FALSE);
`ifdef DWC_DDRPHY_X4MODE
         update_dxnbdlr7(`TRUE,`FALSE);
         update_dxnbdlr8(`TRUE,`FALSE);
         update_dxnbdlr9(`TRUE,`FALSE);
`endif
      end
   endtask // update_all_lane_new_multp_vt_upd

  task update_acmdlr;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    real       init_prd;
    real       targ_prd;
    real       mdld;
    
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC MDL",$time);

      // writing grm with and initial value when pvtscale is first used.
      // `CAL_DDR_PRD is used to check against the measured value
      if (setting_init_value) begin
        init_prd  = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ac_mdl);
        targ_prd  = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ac_mdl);
        mdld      = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ac_mdl); 

        `GRM.acmdlr_iprd_value = init_prd;
        `GRM.acmdlr_tprd_value = targ_prd;
        `GRM.acmdlr_mdld_value = mdld;

        if (init_prd > LCDL_MAX)
          init_prd = LCDL_MAX;
        if (init_prd <= LCDL_MIN)
          init_prd = LCDL_MIN;

        if (targ_prd > LCDL_MAX)
          targ_prd = LCDL_MAX;
        if (targ_prd <= LCDL_MIN)
          targ_prd = LCDL_MIN;
        
        if (mdld > LCDL_MAX)
          mdld = LCDL_MAX;
        if (mdld <= LCDL_MIN)
          mdld = LCDL_MIN;
        
        // Update ddr_grm with new target and mdlr
        `GRM.acmdlr0[0  +: `LCDL_DLY_WIDTH] = init_prd + rounding;
        `GRM.acmdlr0[16 +: `LCDL_DLY_WIDTH] = targ_prd + rounding;
        `GRM.acmdlr1[0  +: `LCDL_DLY_WIDTH] = mdld + rounding;

        if (verbose > pvt_debug) begin
          $display("-> %0t: [PHYSYS] acmdlr_iprd_value  = %0f('h%0h)",$time, `GRM.acmdlr_iprd_value, `GRM.acmdlr_iprd_value);
          $display("-> %0t: [PHYSYS] acmdlr_tprd_value  = %0f('h%0h)",$time, `GRM.acmdlr_tprd_value, `GRM.acmdlr_tprd_value);
          $display("-> %0t: [PHYSYS] GRM.ACMDLR0[16+:%0d]  = 'h%0h",$time, `LCDL_DLY_WIDTH, `GRM.acmdlr0[16+:`LCDL_DLY_WIDTH]);
          $display("-> %0t: [PHYSYS] GRM.ACMDLR0[0 +:%0d]  = 'h%0h",$time, `LCDL_DLY_WIDTH, `GRM.acmdlr0[0 +:`LCDL_DLY_WIDTH]);
        end
      end

      // Use measured value when pvt_mulitplier is used, or else error will be a factor
      // in subsequent calculation. Existing GRM value is used/
      else begin
        // Only update when a manual calibration is in place for the init_prd

        // Do not assert force pvt on AC MDLR
        init_prd  = `GRM.acmdlr_iprd_value;
        targ_prd  = `GRM.acmdlr_tprd_value;
        mdld      = `GRM.acmdlr_mdld_value;
        
        if (init_prd > LCDL_MAX)
          init_prd = LCDL_MAX;
        if (init_prd <= LCDL_MIN)
          init_prd = LCDL_MIN;

        if (targ_prd > LCDL_MAX)
          targ_prd = LCDL_MAX;
        if (targ_prd <= LCDL_MIN)
          targ_prd = LCDL_MIN;
        
        if (mdld > LCDL_MAX)
          mdld = LCDL_MAX;
        if (mdld <= LCDL_MIN)
          mdld = LCDL_MIN;
        
        // Update ddr_grm with new target and mdlr
        `GRM.acmdlr0[0  +: `LCDL_DLY_WIDTH] = init_prd + rounding;
        `GRM.acmdlr0[16 +: `LCDL_DLY_WIDTH] = targ_prd + rounding;
        `GRM.acmdlr1[0  +: `LCDL_DLY_WIDTH] = mdld + rounding;

        if (verbose > pvt_debug) begin
          $display("-> %0t: [PHYSYS] acmdlr_iprd_value  = %0f('h%0h)",$time, `GRM.acmdlr_iprd_value, `GRM.acmdlr_iprd_value);
          $display("-> %0t: [PHYSYS] acmdlr_tprd_value  = %0f('h%0h)",$time, `GRM.acmdlr_tprd_value, `GRM.acmdlr_tprd_value);
          $display("-> %0t: [PHYSYS] GRM.ACMDLR0[16+:%0d]  = 'h%0h",$time, `LCDL_DLY_WIDTH, `GRM.acmdlr0[16+:`LCDL_DLY_WIDTH]);
          $display("-> %0t: [PHYSYS] GRM.ACMDLR0[0 +:%0d]  = 'h%0h",$time, `LCDL_DLY_WIDTH, `GRM.acmdlr0[0 +:`LCDL_DLY_WIDTH]);
        end
      end
    end

  endtask // update_acmdlr


  task update_dxnmdlr;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      vt_interrupt;
    real       init_prd;
    real       targ_prd;
    real       mdld;
    real       last_pvt_targ_prd;
    reg [`LCDL_DLY_WIDTH:0]  prev_targ_prd;
    real       real_prev_targ_prd;
    real       difference;
    real       real_dldlmt;
    integer    i;
    reg [`REG_DATA_WIDTH-1:0] word;
    begin
      if (verbose > pvt_debug) begin
        $display("-> %0t: [PHYSYS] ------> Updating DXn MDL",$time);
      end

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin

        dx_mdl_vt_drift_diff[i] = 0.0;

        // writing grm with and initial value when pvtscale is first used.
        // `CAL_DDR_PRD is used to check against the measured value
        if (setting_init_value) begin
          init_prd  = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_dx_mdl[i]);
          targ_prd  = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_dx_mdl[i]);
          mdld      = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_dx_mdl[i]);

          `GRM.dxnmdlr_iprd_value[i] = init_prd;
          `GRM.dxnmdlr_tprd_value[i] = targ_prd;
          `GRM.dxnmdlr_mdld_value[i] = mdld;      
          
          if (init_prd > LCDL_MAX)
            init_prd = LCDL_MAX;
          if (init_prd <= LCDL_MIN)
            init_prd = LCDL_MIN;

          if (targ_prd > LCDL_MAX)
            targ_prd = LCDL_MAX;
          if (targ_prd <= LCDL_MIN)
            targ_prd = LCDL_MIN;
          
          if (mdld > LCDL_MAX)
            mdld = LCDL_MAX;
          if (mdld <= LCDL_MIN)
            mdld = LCDL_MIN;
          
          // Update ddr_grm with new target and mdlr
          `GRM.dxnmdlr0[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]   = init_prd + rounding;
          `GRM.dxnmdlr0[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT]  = targ_prd + rounding;
          `GRM.dxnmdlr1[i][pDXMDLD_TO_BIT:pDXMDLD_FROM_BIT] = mdld + rounding;      
        end

        // Use measured value when pvt_mulitplier is used, or else error will be a factor
        // in subsequent calculation. Existing GRM value is used/
        else begin
          // Only update when a manual calibration is in place for the init_prd
          if (new_multp && new_cal) begin
            init_prd = (`GRM.dxnmdlr_iprd_value[i] / pvt_multiplier);
            actual_pvt_multiplier[i] = pvt_multiplier;
          end
          else if (vt_interrupt) begin
             init_prd = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_dx_mdl[i])/last_pvt_multiplier;
          end
          else
            init_prd = `GRM.dxnmdlr_iprd_value[i];
          
          if (new_multp) begin
            targ_prd  = (`GRM.dxnmdlr_iprd_value[i] / pvt_multiplier);
            mdld      = (`GRM.dxnmdlr_iprd_value[i] / pvt_multiplier); 
          end
          else begin
            targ_prd  = `GRM.dxnmdlr_tprd_value[i];
            mdld      = `GRM.dxnmdlr_mdld_value[i]; 
          end
          
          if (init_prd > LCDL_MAX)
            init_prd = LCDL_MAX;
          if (init_prd <= LCDL_MIN)
            init_prd = LCDL_MIN;

          if (targ_prd > LCDL_MAX)
            targ_prd = LCDL_MAX;
          if (targ_prd <= LCDL_MIN)
            targ_prd = LCDL_MIN;
          
          if (mdld > LCDL_MAX)
            mdld = LCDL_MAX;
          if (mdld <= LCDL_MIN)
            mdld = LCDL_MIN;
          
          `GRM.dxnmdlr0[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]   = init_prd + rounding;
          `GRM.dxnmdlr0[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT]  = targ_prd + rounding;
          `GRM.dxnmdlr1[i][pDXMDLD_TO_BIT:pDXMDLD_FROM_BIT] = mdld + rounding;    


          `CFG.disable_read_compare;
          repeat (2) @(posedge `CFG.clk);
          `CFG.read_register_data(`DX0MDLR1 + `DX_REG_RANGE*i, word);
          repeat (5) @(posedge `CFG.clk);
         `CFG.enable_read_compare;


          // generate the expected vt drift flag
          last_pvt_targ_prd  = (`GRM.dxnmdlr_iprd_value[i] / last_pvt_multiplier);

          if (last_pvt_targ_prd > LCDL_MAX)
            last_pvt_targ_prd = LCDL_MAX;
          if (last_pvt_targ_prd <= LCDL_MIN)
            last_pvt_targ_prd = LCDL_MIN;
          prev_targ_prd = last_pvt_targ_prd + rounding;
          real_prev_targ_prd = last_pvt_targ_prd;
          
          // Compute the differences using integers and again using real
          dx_mdl_vt_drift_diff[i] = (targ_prd >= real_prev_targ_prd) ? targ_prd - real_prev_targ_prd 
                                                        : real_prev_targ_prd -targ_prd;

          // update the tprd and current value
          `GRM.dxnmdlr_tprd_value[i] = targ_prd; 
          `GRM.dxnmdlr_mdld_value[i] = mdld;    
          
          if (verbose > pvt_debug) begin
            $display("-> %0t: [PHYSYS] Dx%0dMDLR0 init_prd      = %0f('h%0h)",$time, i, init_prd, init_prd);
            $display("-> %0t: [PHYSYS] Dx%0dMDLR0 targ_prd      = %0f('h%0h)",$time, i, targ_prd, targ_prd);
            $display("-> %0t: [PHYSYS] Dx%0dMDLR0 prev_targ_prd = %0f('h%0h)",$time, i, prev_targ_prd, prev_targ_prd);
            $display("-> %0t: [PHYSYS] Dx%0dMDLR1 mdld          = %0f('h%0h)",$time, i, mdld, mdld);  

            $display("-> %0t: [PHYSYS] GRM.dxnmdlr0_iprd_value[%0d] = %0f('h%0h)",$time, i, `GRM.dxnmdlr_iprd_value[i], `GRM.dxnmdlr_iprd_value[i]);
            $display("-> %0t: [PHYSYS] GRM.dxnmdlr0_tprd_value[%0d] = %0f('h%0h)",$time, i, `GRM.dxnmdlr_tprd_value[i], `GRM.dxnmdlr_tprd_value[i]);
            $display("-> %0t: [PHYSYS] GRM.dxnmdlr1_mdld_value[%0d] = %0f('h%0h)",$time, i, `GRM.dxnmdlr_mdld_value[i], `GRM.dxnmdlr_mdld_value[i]);

            $display("-> %0t: [PHYSYS] GRM.dxnmdlr0[%0d][%0d:%0d] = %0h",$time, i, pDXTPRD_TO_BIT, pDXTPRD_FROM_BIT, `GRM.dxnmdlr1[i][pDXTPRD_TO_BIT:pDXTPRD_FROM_BIT]);
            $display("-> %0t: [PHYSYS] GRM.dxnmdlr0[%0d][%0d:%0d] = %0h" ,$time, i, pDXIPRD_TO_BIT, pDXIPRD_FROM_BIT, `GRM.dxnmdlr1[i][pDXIPRD_TO_BIT:pDXIPRD_FROM_BIT]);
            $display("-> %0t: [PHYSYS] ------> Expect dx_mdl_vt_drift_diff[%0d] = %0f",$time, i, dx_mdl_vt_drift_diff[i]);
            $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);

          end
        end
      end
      
    end
  endtask // update_dxnmdlr

  
  // NB:
  // These groups following will use the ratio that is based on read/measured mdl init vs target
  // register values instead of the pvt_multiplier ration that was forced.
  //
  task update_dxnlcdlr0;
    input      new_cal;
    input      vt_update;
    input      revert_last_pvt_mult;
    
    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    real       tmp_3;

    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR0",$time);

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR0 for rank %0d",$time, rank_id);
            tmp_0 = 0.0;
            tmp_1 = 0.0;
            
            // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
            // the delay values for WL and GDQS are revert back to LCDL_MIN
            // WDQD and RDQSD are recalculated
            if (new_cal)
              `GRM.dxnlcdlr0[rank_id][i][31:0] = 32'h0;
            else begin
              if (vt_update || revert_last_pvt_mult) begin
                if (vt_update) begin
                   $display("-> %0t: vt_update is true for rank %0d", $time, rank_id);
                   
                  // do not apply the multiply factor and rounding if value is zero to start with
                  tmp_0  = (`GRM.wld_value[rank_id][i]/ last_actual_pvt_multiplier[i]);
                  
                  if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
                  end
                end
                if (revert_last_pvt_mult) begin
                  tmp_0  = ((`GRM.wld_value[rank_id][i])* last_actual_pvt_multiplier[i]);
                  `GRM.wld_value[rank_id][i]  = ((`GRM.wld_value[rank_id][i])* last_actual_pvt_multiplier[i]);
                end
                
                if (tmp_0 > LCDL_MAX)
                  tmp_0 = LCDL_MAX;
                if (tmp_0 <= LCDL_MIN)
                  tmp_0 = LCDL_MIN;

                if (`GRM.wld_value[rank_id][i] != 0) `GRM.dxnlcdlr0[rank_id][i] [pWLD_TO_BIT:pWLD_FROM_BIT] = tmp_0 + rounding;
              end
            end // else: !if(new_cal)

            if (verbose > pvt_detail_debug) begin
              $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr0[%d][%0d:%0d]      = %0h",$time, i, rank_id, pWLD_TO_BIT, pWLD_FROM_BIT, `GRM.dxnlcdlr0[rank_id][i][pWLD_TO_BIT:pWLD_FROM_BIT]);
              $display("-> %0t: [PHYSYS] GRM.wld_value[%d][%0d] = %0h",$time, i, rank_id, `GRM.wld_value[rank_id][i]);              
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                  if (vt_update || revert_last_pvt_mult) begin
                    if (vt_update) begin
                      // do not apply the multiply factor and rounding if value is zero to start with
                      tmp_0  = (`GRM.x4wld_value[rank_id][i]/ last_actual_pvt_multiplier[i]);
                      
                      if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
                      end
                    end
                    if (revert_last_pvt_mult) begin
                      tmp_0  = ((`GRM.x4wld_value[rank_id][i])* last_actual_pvt_multiplier[i]);
                      `GRM.x4wld_value[rank_id][i]  = ((`GRM.x4wld_value[rank_id][i])* last_actual_pvt_multiplier[i]);
                    end
                    
                    if (tmp_0 > LCDL_MAX)
                      tmp_0 = LCDL_MAX;
                    if (tmp_0 <= LCDL_MIN)
                      tmp_0 = LCDL_MIN;

                    if (`GRM.x4wld_value[rank_id][i] != 0) `GRM.dxnlcdlr0[rank_id][i] [pX4WLD_TO_BIT:pX4WLD_FROM_BIT] = tmp_0 + rounding;
                  end

                if (verbose > pvt_detail_debug) begin
                  $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr0[%d][%0d:%0d]      = %0h",$time, i, rank_id, pX4WLD_TO_BIT, pX4WLD_FROM_BIT, `GRM.dxnlcdlr0[rank_id][i][pX4WLD_TO_BIT:pX4WLD_FROM_BIT]);
                  $display("-> %0t: [PHYSYS] GRM.x4wld_value[%d][%0d] = %0h",$time, i, rank_id, `GRM.x4wld_value[rank_id][i]);              
                end
               
            end // if (`DWC_DX_NO_OF_DQS == 2)
        end // for (rank_id = 0; rank_id < `DWC_NO_OF_RANKS; rank_id = rank_id + 1)
      end // for (i=0;i<`DWC_NO_OF_BYTES;i=i+1)
       

      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
    end
     
     
  endtask // update_dxnlcdlr0
  
  task update_dxnlcdlr3;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      last_vt_multp;
    input      revert_last_pvt_mult;

    real       rdqs_prd;
    
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug) begin
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR4",$time);
      end

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);
      
      
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
        // writing grm with and initial value when pvtscale is first used.
        // `CAL_DDR_PRD is used to check against the measured value
            if (setting_init_value) begin
              rdqs_prd    = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_rdqs[i*pNO_OF_DQS]);

              `GRM.rdqsd_value[rank_id][i]  = rdqs_prd;

              if (rdqs_prd > LCDL_MAX)
                rdqs_prd = LCDL_MAX;
              if (rdqs_prd <= LCDL_MIN)
                rdqs_prd = LCDL_MIN;

              
              // Update ddr_grm with new value  
              `GRM.dxnlcdlr3[rank_id][i][pRDQSD_TO_BIT:pRDQSD_FROM_BIT]   = rdqs_prd/2.0 + rounding;
            end // if (setting_init_value)
           

            // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
            // the delay values for WL and GDQS are revert back to LCDL_MIN
            // WDQD and RDQSD are recalculated

            // Use measured value when pvt_mulitplier is used, or else error will be a factor
            // in subsequent calculation. Existing GRM value is used
            else begin
              if (last_vt_multp) begin
                rdqs_prd    = (`GRM.rdqsd_value[rank_id][i] / last_actual_pvt_multiplier[i]);
              end
              
              else begin
                if (new_multp && new_cal) begin
                  rdqs_prd    = (`GRM.rdqsd_value[rank_id][i] / actual_pvt_multiplier[i]);
                end
                else begin
                  // Delay value has been written over, hence recalculate the value before the pvt multiplier
                  // by multiplying with the last_actual_pvt_multiplier and store that value back to
                  // wdqd_value and rdqsd_value
                  if (revert_last_pvt_mult) begin
                    rdqs_prd    = (`GRM.rdqsd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                    `GRM.rdqsd_value[rank_id][i] = (`GRM.rdqsd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                  end
                  else begin
                    rdqs_prd    = `GRM.rdqsd_value[rank_id][i];
                  end
                end // else: !if(new_multp && new_cal)
              end // else: !if(last_vt_multp)
               
            end // else: !if(setting_init_value)
           
              if (new_multp && new_cal) begin
                // For delay line calibration, there is a limit to a max
                // of LCDL_MAX/2 
                if (rdqs_prd > LCDL_MAX)
                  rdqs_prd = LCDL_MAX;
                if (rdqs_prd <= LCDL_MIN)
                  rdqs_prd = LCDL_MIN;
              end
              else begin
                // For values that were written to Dxnlcdlr4, it can reach and update beyond
                // LCDL_MAX/2 to a maximium of LCDL_MAX
                if (rdqs_prd > LCDL_MAX * 2.0)
                  rdqs_prd = LCDL_MAX * 2.0;
                if (rdqs_prd <= LCDL_MIN * 2.0)
                  rdqs_prd = LCDL_MIN * 2.0;
              end // else: !if(new_multp && new_cal)
               
              
              if (`GRM.rdqsd_value[rank_id][i] != 0) `GRM.dxnlcdlr3[rank_id][i][pRDQSD_TO_BIT:pRDQSD_FROM_BIT]  = (rdqs_prd/2.0) + rounding;    

              if (verbose > pvt_detail_debug) begin
                 $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
                 $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
                 $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
                 
                 $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr3[%0d][%0d:%0d]  = %0h",$time, i, rank_id, pRDQSD_TO_BIT, pRDQSD_FROM_BIT, `GRM.dxnlcdlr3[rank_id][i][pRDQSD_TO_BIT:pRDQSD_FROM_BIT]);

                 $display("-> %0t: [PHYSYS] GRM.rdqsd_value[%0d][%0d]   = %0h",$time, rank_id, i, `GRM.rdqsd_value[rank_id][i]);        

                 $display("-> %0t: [PHYSYS] rdqs_prd    = %0h",$time, rdqs_prd);        
              end // if (verbose > pvt_detail_debug)
               
              if (`DWC_DX_NO_OF_DQS == 2) begin
                 if (setting_init_value) begin
                    rdqs_prd    = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_rdqs[i*pNO_OF_DQS]);

                    `GRM.x4rdqsd_value[rank_id][i]  = rdqs_prd;

                    if (rdqs_prd > LCDL_MAX)
                      rdqs_prd = LCDL_MAX;
                    if (rdqs_prd <= LCDL_MIN)
                      rdqs_prd = LCDL_MIN;

                    
                    // Update ddr_grm with new value  
                    `GRM.dxnlcdlr3[rank_id][i][pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]   = rdqs_prd/2.0 + rounding;
                 end // if (setting_init_value)
               

                // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
                // the delay values for WL and GDQS are revert back to LCDL_MIN
                // WDQD and RDQSD are recalculated

                // Use measured value when pvt_mulitplier is used, or else error will be a factor
                // in subsequent calculation. Existing GRM value is used
                else begin
                  if (last_vt_multp) begin
                    rdqs_prd    = (`GRM.x4rdqsd_value[rank_id][i] / last_actual_pvt_multiplier[i]);
                  end
                  
                  else begin
                    if (new_multp && new_cal) begin
                      rdqs_prd    = (`GRM.x4rdqsd_value[rank_id][i] / actual_pvt_multiplier[i]);
                    end
                    else begin
                      // Delay value has been written over, hence recalculate the value before the pvt multiplier
                      // by multiplying with the last_actual_pvt_multiplier and store that value back to
                      // wdqd_value and rdqsd_value
                      if (revert_last_pvt_mult) begin
                        rdqs_prd    = (`GRM.x4rdqsd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                        `GRM.x4rdqsd_value[rank_id][i] = (`GRM.x4rdqsd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                      end
                      else begin
                        rdqs_prd    = `GRM.x4rdqsd_value[rank_id][i];
                      end
                    end // else: !if(new_multp && new_cal)
                  end // else: !if(last_vt_multp)
           
                  if (new_multp && new_cal) begin
                    // For delay line calibration, there is a limit to a max
                    // of LCDL_MAX/2 
                    if (rdqs_prd > LCDL_MAX)
                      rdqs_prd = LCDL_MAX;
                    if (rdqs_prd <= LCDL_MIN)
                      rdqs_prd = LCDL_MIN;
                  end
                  else begin
                    // For values that were written to Dxnlcdlr4, it can reach and update beyond
                    // LCDL_MAX/2 to a maximium of LCDL_MAX
                    if (rdqs_prd > LCDL_MAX * 2.0)
                      rdqs_prd = LCDL_MAX * 2.0;
                    if (rdqs_prd <= LCDL_MIN * 2.0)
                      rdqs_prd = LCDL_MIN * 2.0;

                  end // else: !if(new_multp && new_cal)
                   
                  
                  if (`GRM.x4rdqsd_value[rank_id][i] != 0) `GRM.dxnlcdlr3[rank_id][i][pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]  = (rdqs_prd/2.0) + rounding;    
                end // else: !if(setting_init_value)
                 
                  if (verbose > pvt_detail_debug) begin
                  $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
                  
                  $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr3[%0d][%0d:%0d]  = %0h",$time, i, rank_id, pX4RDQSD_TO_BIT, pX4RDQSD_FROM_BIT, `GRM.dxnlcdlr3[rank_id][i][pX4RDQSD_TO_BIT:pX4RDQSD_FROM_BIT]);

                  $display("-> %0t: [PHYSYS] GRM.x4rdqsd_value[%0d][%0d]   = %0h",$time, rank_id, i, `GRM.x4rdqsd_value[rank_id][i]);        

                  $display("-> %0t: [PHYSYS] rdqs_prd    = %0h",$time, rdqs_prd);        
                  end // if (verbose > pvt_detail_debug)
                   
              end // if (`DWC_DX_NO_OF_DQS == 2)
        end // for (rank_id = 0; rank_id < `DWC_NO_OF_RANKS; rank_id = rank_id + 1)
      end // for (i=0;i<`DWC_NO_OF_BYTES;i=i+1)
       
      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;

   end       
    
  endtask // update_dxnlcdlr4
  
  task update_dxnlcdlr4;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      last_vt_multp;
    input      revert_last_pvt_mult;

    real       rdqs_prd;
    real       rdqsn_prd;
    
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug) begin
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR4",$time);
      end

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);
      
      
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS; rank_id = rank_id + 1) begin
 
            // writing grm with and initial value when pvtscale is first used.
            // `CAL_DDR_PRD is used to check against the measured value
            if (setting_init_value) begin
              rdqsn_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_rdqsn[i*pNO_OF_DQS]);

              `GRM.rdqsnd_value[rank_id][i] = rdqsn_prd;

              if (rdqsn_prd > LCDL_MAX)
                rdqsn_prd = LCDL_MAX;
              if (rdqsn_prd <= LCDL_MIN)
                rdqsn_prd = LCDL_MIN;
              
              // Update ddr_grm with new value  
              `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT] = rdqsn_prd/2.0 + rounding;
            end

            // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
            // the delay values for WL and GDQS are revert back to LCDL_MIN
            // WDQD and RDQSD are recalculated

            // Use measured value when pvt_mulitplier is used, or else error will be a factor
            // in subsequent calculation. Existing GRM value is used
            else begin
              if (last_vt_multp) begin
                rdqsn_prd   = (`GRM.rdqsnd_value[rank_id][i] / last_actual_pvt_multiplier[i]);
              end
              
              else begin
                if (new_multp && new_cal) begin
                  rdqsn_prd   = (`GRM.rdqsnd_value[rank_id][i] / actual_pvt_multiplier[i]);
                end
                else begin
                  // Delay value has been written over, hence recalculate the value before the pvt multiplier
                  // by multiplying with the last_actual_pvt_multiplier and store that value back to
                  // wdqd_value and rdqsd_value
                  if (revert_last_pvt_mult) begin
                    rdqsn_prd   = (`GRM.rdqsnd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                    `GRM.rdqsnd_value[rank_id][i] = (`GRM.rdqsnd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                  end
                  else begin
                    rdqsn_prd   = `GRM.rdqsnd_value[rank_id][i];
                  end
                end
              end // else: !if(last_vt_multp)
               

              if (new_multp && new_cal) begin
                // For delay line calibration, there is a limit to a max
                // of LCDL_MAX/2 
                if (rdqsn_prd > LCDL_MAX)
                  rdqsn_prd = LCDL_MAX;
                if (rdqsn_prd <= LCDL_MIN)
                  rdqsn_prd = LCDL_MIN;
              end
              else begin
                // For values that were written to Dxnlcdlr4, it can reach and update beyond
                // LCDL_MAX/2 to a maximium of LCDL_MAX
                if (rdqsn_prd > LCDL_MAX * 2.0)
                  rdqsn_prd = LCDL_MAX * 2.0;
                if (rdqsn_prd <= LCDL_MIN * 2.0)
                  rdqsn_prd = LCDL_MIN * 2.0;
              end
              
              if (`GRM.rdqsnd_value[rank_id][i] != 0) `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT]  = (rdqsn_prd/2.0) + rounding;    
            end // else: !if(setting_init_value)
           

            if (verbose > pvt_detail_debug) begin
              $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
              
              $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr4[%0d][%0d:%0d] = %0h",$time, i, rank_id, pRDQSND_TO_BIT, pRDQSND_FROM_BIT,`GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT]);

              $display("-> %0t: [PHYSYS] GRM.rdqsnd_value[%0d][%0d]  = %0h",$time,rank_id, i, `GRM.rdqsnd_value[rank_id][i]);        

              $display("-> %0t: [PHYSYS] rdqsn_prd   = %0h",$time, rdqsn_prd);        
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                // writing grm with and initial value when pvtscale is first used.
                // `CAL_DDR_PRD is used to check against the measured value
                if (setting_init_value) begin
                  rdqsn_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_rdqsn[i*pNO_OF_DQS]);

                  `GRM.rdqsnd_value[rank_id][i] = rdqsn_prd;

                  if (rdqsn_prd > LCDL_MAX)
                    rdqsn_prd = LCDL_MAX;
                  if (rdqsn_prd <= LCDL_MIN)
                    rdqsn_prd = LCDL_MIN;
                  
                  // Update ddr_grm with new value  
                  `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT] = rdqsn_prd/2.0 + rounding;
                end

                // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
                // the delay values for WL and GDQS are revert back to LCDL_MIN
                // WDQD and RDQSD are recalculated

                // Use measured value when pvt_mulitplier is used, or else error will be a factor
                // in subsequent calculation. Existing GRM value is used
                else begin
                  if (last_vt_multp) begin
                    rdqsn_prd   = (`GRM.rdqsnd_value[rank_id][i] / last_actual_pvt_multiplier[i]);
                  end
                  
                  else begin
                    if (new_multp && new_cal) begin
                      rdqsn_prd   = (`GRM.rdqsnd_value[rank_id][i] / actual_pvt_multiplier[i]);
                    end
                    else begin
                      // Delay value has been written over, hence recalculate the value before the pvt multiplier
                      // by multiplying with the last_actual_pvt_multiplier and store that value back to
                      // wdqd_value and rdqsd_value
                      if (revert_last_pvt_mult) begin
                        rdqsn_prd   = (`GRM.rdqsnd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                        `GRM.rdqsnd_value[rank_id][i] = (`GRM.rdqsnd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                      end
                      else begin
                        rdqsn_prd   = `GRM.rdqsnd_value[rank_id][i];
                      end
                    end
                  end

                  if (new_multp && new_cal) begin
                    // For delay line calibration, there is a limit to a max
                    // of LCDL_MAX/2 
                    if (rdqsn_prd > LCDL_MAX)
                      rdqsn_prd = LCDL_MAX;
                    if (rdqsn_prd <= LCDL_MIN)
                      rdqsn_prd = LCDL_MIN;
                  end
                  else begin
                    // For values that were written to Dxnlcdlr4, it can reach and update beyond
                    // LCDL_MAX/2 to a maximium of LCDL_MAX
                    if (rdqsn_prd > LCDL_MAX * 2.0)
                      rdqsn_prd = LCDL_MAX * 2.0;
                    if (rdqsn_prd <= LCDL_MIN * 2.0)
                      rdqsn_prd = LCDL_MIN * 2.0;
                  end
                  
                  if (`GRM.rdqsnd_value[rank_id][i] != 0) `GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT]  = (rdqsn_prd/2.0) + rounding;    
                end

                if (verbose > pvt_detail_debug) begin
                  $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
                  
                  $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr4[%0d][%0d:%0d] = %0h",$time, i, rank_id, pRDQSND_TO_BIT, pRDQSND_FROM_BIT,`GRM.dxnlcdlr4[rank_id][i][pRDQSND_TO_BIT:pRDQSND_FROM_BIT]);

                  $display("-> %0t: [PHYSYS] GRM.rdqsnd_value[%0d][%0d]  = %0h",$time,rank_id, i, `GRM.rdqsnd_value[rank_id][i]);        

                  $display("-> %0t: [PHYSYS] rdqsn_prd   = %0h",$time, rdqsn_prd);        
                end  
            end // if (`DWC_DX_NO_OF_DQS == 2)
        end // for (rank_id = 0; rank_id < `DWC_NO_OF_RANKS; rank_id = rank_id + 1)
      end // for (i=0;i<`DWC_NO_OF_BYTES;i=i+1)

      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;

    end
    
  endtask // update_dxnlcdlr4


  task update_dxnlcdlr1;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      last_vt_multp;
    input      revert_last_pvt_mult;

    real       wdqd_prd;
    
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug) begin
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR5",$time);
      end

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);
      
      
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS ; rank_id = rank_id + 1) begin
        
            // writing grm with and initial value when pvtscale is first used.
            // `CAL_DDR_PRD is used to check against the measured value
            if (setting_init_value) begin
              wdqd_prd     = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ddr_wdq[i*pNO_OF_DQS]);

              `GRM.wdqd_value[rank_id][i]   = wdqd_prd;

              if (wdqd_prd > LCDL_MAX)
                wdqd_prd = LCDL_MAX;
              if (wdqd_prd <= LCDL_MIN)
                wdqd_prd = LCDL_MIN;

              // Update ddr_grm with new value  
              `GRM.dxnlcdlr1[rank_id][i][pWDQD_TO_BIT:pWDQD_FROM_BIT]     = wdqd_prd/2.0 + rounding;
            end

            // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
            // the delay values for WL and GDQS are revert back to LCDL_MIN
            // WDQD and RDQSGS are recalculated

            // Use measured value when pvt_mulitplier is used, or else error will be a factor
            // in subsequent calculation. Existing GRM value is used
            else begin
              if (last_vt_multp) begin
                wdqd_prd    = (`GRM.wdqd_value[rank_id][i] / last_actual_pvt_multiplier[i]);
              end
              
              else begin
                if (new_multp && new_cal) begin
                  wdqd_prd    = (`GRM.wdqd_value[rank_id][i] / actual_pvt_multiplier[i]);
                end
                else begin
                  // Delay value has been written over, hence recalculate the value before the pvt multiplier
                  // by multiplying with the last_actual_pvt_multiplier and store that value back to
                  // wdqd_value and wdqd_value
                  if (revert_last_pvt_mult) begin
                    wdqd_prd     = (`GRM.wdqd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                    `GRM.wdqd_value[rank_id][i]   = (`GRM.wdqd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                  end
                  else begin
                    wdqd_prd    = `GRM.wdqd_value[rank_id][i];
                  end
                end
              end // else: !if(last_vt_multp)
               

              if (new_multp && new_cal) begin
                // For delay line calibration, there is a limit to a max
                // of LCDL_MAX/2 
                if (wdqd_prd > LCDL_MAX)
                  wdqd_prd = LCDL_MAX;
                if (wdqd_prd <= LCDL_MIN)
                  wdqd_prd = LCDL_MIN;

              end
              else begin
                // For values that were written to Dxnlcdlr1, it can reach and update beyond
                // LCDL_MAX/2 to a maximium of LCDL_MAX
                if (wdqd_prd > LCDL_MAX * 2.0)
                  wdqd_prd = LCDL_MAX * 2.0;
                if (wdqd_prd <= LCDL_MIN * 2.0)
                  wdqd_prd = LCDL_MIN * 2.0;
              end // else: !if(new_multp && new_cal)
               
              if (`GRM.wdqd_value[rank_id][i] != 0)   `GRM.dxnlcdlr1[rank_id][i][pWDQD_TO_BIT:pWDQD_FROM_BIT]      = (wdqd_prd/2.0) + rounding;    
            end

            if (verbose > pvt_detail_debug) begin
              $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
              
              $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr1[%0d][%0d:%0d]  = %0h",$time, i,rank_id, pWDQD_TO_BIT, pWDQD_FROM_BIT, `GRM.dxnlcdlr1[rank_id][i][pWDQD_TO_BIT:pWDQD_FROM_BIT]);

              $display("-> %0t: [PHYSYS] GRM.wdqd_value[%0d][%0d]   = %0h",$time, i, rank_id, `GRM.wdqd_value[rank_id][i]);        

              $display("-> %0t: [PHYSYS] wdqd_prd    = %0h",$time, wdqd_prd);        
            end
            if (`DWC_DX_NO_OF_DQS == 2) begin
                if (setting_init_value) begin
                  wdqd_prd     = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ddr_wdq[i*pNO_OF_DQS]);

                  `GRM.x4wdqd_value[rank_id][i]   = wdqd_prd;

                  if (wdqd_prd > LCDL_MAX)
                    wdqd_prd = LCDL_MAX;
                  if (wdqd_prd <= LCDL_MIN)
                    wdqd_prd = LCDL_MIN;

                  // Update ddr_grm with new value  
                  `GRM.dxnlcdlr1[rank_id][i][pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]     = wdqd_prd/2.0 + rounding;
                end

                // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
                // the delay values for WL and GDQS are revert back to LCDL_MIN
                // WDQD and RDQSGS are recalculated

                // Use measured value when pvt_mulitplier is used, or else error will be a factor
                // in subsequent calculation. Existing GRM value is used
                else begin
                  if (last_vt_multp) begin
                    wdqd_prd    = (`GRM.x4wdqd_value[rank_id][i] / last_actual_pvt_multiplier[i]);
                  end
                  
                  else begin
                    if (new_multp && new_cal) begin
                      wdqd_prd    = (`GRM.x4wdqd_value[rank_id][i] / actual_pvt_multiplier[i]);
                    end
                    else begin
                      // Delay value has been written over, hence recalculate the value before the pvt multiplier
                      // by multiplying with the last_actual_pvt_multiplier and store that value back to
                      // wdqd_value and wdqd_value
                      if (revert_last_pvt_mult) begin
                        wdqd_prd     = (`GRM.x4wdqd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                        `GRM.x4wdqd_value[rank_id][i]   = (`GRM.x4wdqd_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                      end
                      else begin
                        wdqd_prd    = `GRM.x4wdqd_value[rank_id][i];
                      end
                    end
                  end // else: !if(last_vt_multp)
                   

                  if (new_multp && new_cal) begin
                    // For delay line calibration, there is a limit to a max
                    // of LCDL_MAX/2 
                    if (wdqd_prd > LCDL_MAX)
                      wdqd_prd = LCDL_MAX;
                    if (wdqd_prd <= LCDL_MIN)
                      wdqd_prd = LCDL_MIN;

                  end
                  else begin
                    // For values that were written to Dxnlcdlr1, it can reach and update beyond
                    // LCDL_MAX/2 to a maximium of LCDL_MAX
                    if (wdqd_prd > LCDL_MAX * 2.0)
                      wdqd_prd = LCDL_MAX * 2.0;
                    if (wdqd_prd <= LCDL_MIN * 2.0)
                      wdqd_prd = LCDL_MIN * 2.0;
                  end // else: !if(new_multp && new_cal)
                   
                  if (`GRM.x4wdqd_value[rank_id][i] != 0)   `GRM.dxnlcdlr1[rank_id][i][pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]      = (wdqd_prd/2.0) + rounding;    
                end // else: !if(setting_init_value)

                if (verbose > pvt_detail_debug) begin
                  $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
                  $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
                  
                  $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr1[%0d][%0d:%0d]  = %0h",$time, i,rank_id, pX4WDQD_TO_BIT, pX4WDQD_FROM_BIT, `GRM.dxnlcdlr1[rank_id][i][pX4WDQD_TO_BIT:pX4WDQD_FROM_BIT]);

                  $display("-> %0t: [PHYSYS] GRM.x4wdqd_value[%0d][%0d]   = %0h",$time, i, rank_id, `GRM.x4wdqd_value[rank_id][i]);        

                  $display("-> %0t: [PHYSYS] wdqd_prd    = %0h",$time, wdqd_prd);        
                end
            end
            end // else: !if(setting_init_value)
           

        
      end  // for loop

      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;

    end
    
  endtask // update_dxnlcdlr1
  
  task update_dxnlcdlr5;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      last_vt_multp;
    input      revert_last_pvt_mult;

    real       rdqsgs_prd;
    
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug) begin
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR5",$time);
      end

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);
      
      
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS ; rank_id = rank_id + 1) begin
          
          // writing grm with and initial value when pvtscale is first used.
          // `CAL_DDR_PRD is used to check against the measured value
          if (setting_init_value) begin
            rdqsgs_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_rdqsgs[i*pNO_OF_DQS]);

            `GRM.rdqsgs_value[rank_id][i] = rdqsgs_prd;

            if (rdqsgs_prd > LCDL_MAX)
              rdqsgs_prd = LCDL_MAX;
            if (rdqsgs_prd <= LCDL_MIN)
              rdqsgs_prd = LCDL_MIN;
            
            // Update ddr_grm with new value  
            `GRM.dxnlcdlr5[rank_id][i][pGSDQS_TO_BIT:pGSDQS_FROM_BIT] = rdqsgs_prd/2.0 + rounding;
          end

          // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
          // the delay values for WL and GDQS are revert back to LCDL_MIN
          // WDQD and RDQSGS are recalculated

          // Use measured value when pvt_mulitplier is used, or else error will be a factor
          // in subsequent calculation. Existing GRM value is used
          else begin
            if (last_vt_multp) begin
              rdqsgs_prd  = (`GRM.rdqsgs_value[rank_id][i] / last_actual_pvt_multiplier[i]);
            end
            
            else begin
              if (new_multp && new_cal) begin
                rdqsgs_prd  = (`GRM.rdqsgs_value[rank_id][i] / actual_pvt_multiplier[i]);
              end
              else begin
                // Delay value has been written over, hence recalculate the value before the pvt multiplier
                // by multiplying with the last_actual_pvt_multiplier and store that value back to
                // wdqd_value and wdqd_value
                if (revert_last_pvt_mult) begin
                  rdqsgs_prd   = (`GRM.rdqsgs_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                  `GRM.rdqsgs_value[rank_id][i] = (`GRM.rdqsgs_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                end
                //ROB              else if (new_multp) begin
                //ROB                `GRM.wdqd_value[i]  = `GRM.wdqd_value[i]*(last_actual_pvt_multiplier[i]/actual_pvt_multiplier[i]);
                //ROB                `GRM.rdqsgs_value[i] = `GRM.rdqsgs_value[i]*(last_actual_pvt_multiplier[i]/actual_pvt_multiplier[i]);
                //ROB                wdqd_prd    = `GRM.wdqd_value[i];
                //ROB                rdqsgs_prd   = `GRM.rdqsgs_value[i];
                //ROB              end
                else begin
                  rdqsgs_prd  = `GRM.rdqsgs_value[rank_id][i];
                end
              end
            end

            if (new_multp && new_cal) begin
              // For delay line calibration, there is a limit to a max
              // of LCDL_MAX/2 
              if (rdqsgs_prd > LCDL_MAX)
                rdqsgs_prd = LCDL_MAX;
              if (rdqsgs_prd <= LCDL_MIN)
                rdqsgs_prd = LCDL_MIN;
            end
            else begin
              // For values that were written to Dxnlcdlr5, it can reach and update beyond
              // LCDL_MAX/2 to a maximium of LCDL_MAX

              if (rdqsgs_prd > LCDL_MAX * 2.0)
                rdqsgs_prd = LCDL_MAX * 2.0;
              if (rdqsgs_prd <= LCDL_MIN * 2.0)
                rdqsgs_prd = LCDL_MIN * 2.0;
            end
            
            if (`GRM.rdqsgs_value[rank_id][i] != 0) `GRM.dxnlcdlr5[rank_id][i][pGSDQS_TO_BIT:pGSDQS_FROM_BIT]  = (rdqsgs_prd/2.0) + rounding;    
          end

          if (verbose > pvt_detail_debug) begin
            $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
            $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
            $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
            
            $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr5[%0d][%0d:%0d] = %0h",$time, i,rank_id, pGSDQS_TO_BIT, pGSDQS_FROM_BIT,`GRM.dxnlcdlr5[rank_id][i][pGSDQS_TO_BIT:pGSDQS_FROM_BIT]);

            $display("-> %0t: [PHYSYS] GRM.rdqsgs_value[%0d][%0d]  = %0h",$time, i,rank_id, `GRM.rdqsgs_value[rank_id][i]);        

            $display("-> %0t: [PHYSYS] rdqsgs_prd   = %0h",$time, rdqsgs_prd);        
          end
          if (`DWC_DX_NO_OF_DQS == 2) begin
            if (setting_init_value) begin
              rdqsgs_prd     = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_rdqsgs[i*pNO_OF_DQS]);

              `GRM.x4rdqsgs_value[rank_id][i]   = rdqsgs_prd;

              if (rdqsgs_prd > LCDL_MAX)
                rdqsgs_prd = LCDL_MAX;
              if (rdqsgs_prd <= LCDL_MIN)
                rdqsgs_prd = LCDL_MIN;

              // Update ddr_grm with new value  
              `GRM.dxnlcdlr5[rank_id][i][pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT]     = rdqsgs_prd/2.0 + rounding;
            end

            // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
            // the delay values for WL and GDQS are revert back to LCDL_MIN
            // WDQD and RDQSGS are recalculated

            // Use measured value when pvt_mulitplier is used, or else error will be a factor
            // in subsequent calculation. Existing GRM value is used
            else begin
              if (last_vt_multp) begin
                rdqsgs_prd    = (`GRM.x4rdqsgs_value[rank_id][i] / last_actual_pvt_multiplier[i]);
              end
              
              else begin
                if (new_multp && new_cal) begin
                  rdqsgs_prd    = (`GRM.x4rdqsgs_value[rank_id][i] / actual_pvt_multiplier[i]);
                end
                else begin
                  // Delay value has been written over, hence recalculate the value before the pvt multiplier
                  // by multiplying with the last_actual_pvt_multiplier and store that value back to
                  // rdqsgs_value and rdqsgs_value
                  if (revert_last_pvt_mult) begin
                    rdqsgs_prd     = (`GRM.x4rdqsgs_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                    `GRM.x4rdqsgs_value[rank_id][i]   = (`GRM.x4rdqsgs_value[rank_id][i] * last_actual_pvt_multiplier[i]);
                  end
                  else begin
                    rdqsgs_prd    = `GRM.x4rdqsgs_value[rank_id][i];
                  end
                end
              end // else: !if(last_vt_multp)
              

              if (new_multp && new_cal) begin
                // For delay line calibration, there is a limit to a max
                // of LCDL_MAX/2 
                if (rdqsgs_prd > LCDL_MAX)
                  rdqsgs_prd = LCDL_MAX;
                if (rdqsgs_prd <= LCDL_MIN)
                  rdqsgs_prd = LCDL_MIN;

              end
              else begin
                // For values that were written to Dxnlcdlr5, it can reach and update beyond
                // LCDL_MAX/2 to a maximium of LCDL_MAX
                if (rdqsgs_prd > LCDL_MAX * 2.0)
                  rdqsgs_prd = LCDL_MAX * 2.0;
                if (rdqsgs_prd <= LCDL_MIN * 2.0)
                  rdqsgs_prd = LCDL_MIN * 2.0;
              end // else: !if(new_multp && new_cal)
              
              if (`GRM.x4rdqsgs_value[rank_id][i] != 0)   `GRM.dxnlcdlr5[rank_id][i][pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT]      = (rdqsgs_prd/2.0) + rounding;    
            end // else: !if(setting_init_value)

            if (verbose > pvt_detail_debug) begin
              $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d]  = %0f",$time, i, last_actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]      = %0f",$time, i, actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] prev_actual_pvt_multiplier [%0d] = %0f",$time, i, prev_actual_pvt_multiplier[i]);
              
              $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr5[%0d][%0d:%0d]  = %0h",$time, i,rank_id, pX4GSDQS_TO_BIT, pX4GSDQS_FROM_BIT, `GRM.dxnlcdlr5[rank_id][i][pX4GSDQS_TO_BIT:pX4GSDQS_FROM_BIT]);

              $display("-> %0t: [PHYSYS] GRM.x4rdqsgs_value[%0d][%0d]   = %0h",$time, i, rank_id, `GRM.x4rdqsgs_value[rank_id][i]);        

              $display("-> %0t: [PHYSYS] rdqsgs_prd    = %0h",$time, rdqsgs_prd);        
            end
          end
        end // else: !if(setting_init_value)
        
        
      end  // for loop

      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;

    end
    
  endtask // update_dxnlcdlr5
  
  task update_dxnlcdlr2;
    input      new_cal;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    real       tmp_3;

    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn LCDLR2",$time);

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);
      
      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        for (rank_id = 0; rank_id < pNO_OF_TRANKS ; rank_id = rank_id + 1) begin
          tmp_0 = 0.0;
          tmp_1 = 0.0;
          
          // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
          // the delay values for WL and GDQS are revert back to LCDL_MIN
          // WDQD and RDQSD are recalculated
          if (new_cal)
            `GRM.dxnlcdlr2[rank_id][i][31:0] = 32'h0;
          else begin
            if (vt_update || revert_last_pvt_mult) begin
              if (vt_update) begin
                // do not apply the multiply factor and rounding if value is zero to start with
                tmp_0  = (`GRM.dqsgd_value[rank_id][i]/ last_actual_pvt_multiplier[i]);
              end
              if (revert_last_pvt_mult) begin
                // Delay value has been written over, hence recalculate the value before the pvt multiplier
                // by multiplying with the last_actual_pvt_multiplier and store that value back to
                // r(0-3)dqsgd_value
                tmp_0  = ((`GRM.dqsgd_value[rank_id][i])* last_actual_pvt_multiplier[i]);

                `GRM.dqsgd_value[rank_id][i]  = ((`GRM.dqsgd_value[rank_id][i])* last_actual_pvt_multiplier[i]);
                
              end

              if (tmp_0 > LCDL_MAX)
                tmp_0 = LCDL_MAX;
              if (tmp_0 <= LCDL_MIN)
                tmp_0 = LCDL_MIN;

              if (`GRM.dqsgd_value[rank_id][i] != 0) `GRM.dxnlcdlr2[rank_id][i] [pGDQSD_TO_BIT:pGDQSD_FROM_BIT] = tmp_0 + rounding;
            end
          end        

          if (verbose > pvt_detail_debug) begin
            $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
            $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr2[%0d][%0d:%0d]      = %0h",$time, i,rank_id, pGDQSD_TO_BIT, pGDQSD_FROM_BIT, `GRM.dxnlcdlr2[rank_id][i][pGDQSD_TO_BIT:pGDQSD_FROM_BIT]);

            $display("-> %0t: [PHYSYS] GRM.dqsgd_value[%0d][%0d] = %0h",$time, rank_id, i, `GRM.dqsgd_value[rank_id][i]);

            $display("-> %0t: [PHYSYS] ------> tmp_0            = %0h",$time, tmp_0);
          end
          if (`DWC_DX_NO_OF_DQS == 2) begin
            if (vt_update || revert_last_pvt_mult) begin
              if (vt_update) begin
                // do not apply the multiply factor and rounding if value is zero to start with
                tmp_0  = (`GRM.x4dqsgd_value[rank_id][i]/ last_actual_pvt_multiplier[i]);
              end
              if (revert_last_pvt_mult) begin
                // Delay value has been written over, hence recalculate the value before the pvt multiplier
                // by multiplying with the last_actual_pvt_multiplier and store that value back to
                // r(0-3)dqsgd_value
                tmp_0  = ((`GRM.x4dqsgd_value[rank_id][i])* last_actual_pvt_multiplier[i]);

                `GRM.x4dqsgd_value[rank_id][i]  = ((`GRM.x4dqsgd_value[rank_id][i])* last_actual_pvt_multiplier[i]);
                
              end

              if (tmp_0 > LCDL_MAX)
                tmp_0 = LCDL_MAX;
              if (tmp_0 <= LCDL_MIN)
                tmp_0 = LCDL_MIN;

              if (`GRM.x4dqsgd_value[rank_id][i] != 0) `GRM.dxnlcdlr2[rank_id][i] [pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT] = tmp_0 + rounding;
            end

            if (verbose > pvt_detail_debug) begin
              $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
              $display("-> %0t: [PHYSYS] GRM.dx%0dlcdlr2[%0d][%0d:%0d]      = %0h",$time, i,rank_id, pX4GDQSD_TO_BIT, pX4GDQSD_FROM_BIT, `GRM.dxnlcdlr2[rank_id][i][pX4GDQSD_TO_BIT:pX4GDQSD_FROM_BIT]);

              $display("-> %0t: [PHYSYS] GRM.x4dqsgd_value[%0d][%0d] = %0h",$time, rank_id, i, `GRM.x4dqsgd_value[rank_id][i]);

              $display("-> %0t: [PHYSYS] ------> tmp_0            = %0h",$time, tmp_0);
            end
          end
        end // for rank_id loop

      end // for loop
      
      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;

    end
  endtask // update_dxnlcdlr2
  
  

  task update_dxngsr0;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      last_vt_multp;

    real       ddr_wl_prd;
    real       gdqs_prd;

    
    integer    i, rank_id;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXnGSR0",$time);

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        // writing grm with and initial value when pvtscale is first used.
        // `CAL_DDR_PRD is used to check against the measured value
        if (setting_init_value) begin
           
`ifdef DWC_DDRPHY_X4X2  
          ddr_wl_prd = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ddr_wl[i*2]);
          gdqs_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_gdqs[i*2]);
`else
          ddr_wl_prd = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ddr_wl[i*pNO_OF_DQS]);
          gdqs_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_gdqs[i*pNO_OF_DQS]);
`endif      
           
          `GRM.wlprd_value[i]     = ddr_wl_prd;
          `GRM.gdqsprd_value[i]   = gdqs_prd;

          if (ddr_wl_prd > LCDL_MAX)
            ddr_wl_prd = LCDL_MAX;
          if (ddr_wl_prd <= LCDL_MIN)
            ddr_wl_prd = LCDL_MIN;

          if (gdqs_prd > LCDL_MAX)
            gdqs_prd = LCDL_MAX;
          if (gdqs_prd <= LCDL_MIN)
            gdqs_prd = LCDL_MIN;
          
          // Update ddr_grm with new value   
          `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]      = ddr_wl_prd + rounding;
          `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]  = gdqs_prd + rounding;
        end
        
        // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
        // the delay values for WL and GDQS are revert back to LCDL_MIN
        // WDQD and RDQSD are recalculated

        // Use measured value when pvt_mulitplier is used, or else error will be a factor
        // in subsequent calculation. Existing GRM value is used/
        else begin
          if (last_vt_multp) begin
             
            // A max limit is placed if it is from dx_mdl_cal_update and not a new manual calibration
            // as the delay line calculation has a max value of LCDL_MAX.
            if (`GRM.wlprd_value[i] >= LCDL_MAX) 
              ddr_wl_prd = (LCDL_MAX/ last_actual_pvt_multiplier[i]);
            else
              ddr_wl_prd = (`GRM.wlprd_value[i]   / last_actual_pvt_multiplier[i]);

            if (`GRM.gdqsprd_value[i] >= LCDL_MAX)
              gdqs_prd   = (LCDL_MAX / last_actual_pvt_multiplier[i]);
            else        
              gdqs_prd   = (`GRM.gdqsprd_value[i] / last_actual_pvt_multiplier[i]);

          end
          else begin
            // A new manual calibration might start off from a *_value which is above
            // the max, but the mulitplier factor might put it back within the valid
            // range. Hence, check the max limit after the multiplier factor is included.
            if (new_multp && new_cal) begin
              ddr_wl_prd = (`GRM.wlprd_value[i]   / actual_pvt_multiplier[i]);
              gdqs_prd   = (`GRM.gdqsprd_value[i] / actual_pvt_multiplier[i]);
            end
            else begin
              ddr_wl_prd = `GRM.wlprd_value[i];
              gdqs_prd   = `GRM.gdqsprd_value[i];
            end
          end

          if (ddr_wl_prd > LCDL_MAX)
            ddr_wl_prd = LCDL_MAX;
          if (ddr_wl_prd <= LCDL_MIN)
            ddr_wl_prd = LCDL_MIN;

          if (gdqs_prd > LCDL_MAX)
            gdqs_prd = LCDL_MAX;
          if (gdqs_prd <= LCDL_MIN)
            gdqs_prd = LCDL_MIN;
           
          if (`GRM.wlprd_value[i]   != 0)  `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]   = ddr_wl_prd + rounding;
          if (`GRM.gdqsprd_value[i] != 0)  `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]  = gdqs_prd + rounding;  
        end // else: !if(setting_init_value)

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]     = %0f",$time, i, actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] DX%0dGSR0[%0d:%0d]     = %0h",$time, i, pGDQSPRD_TO_BIT, pGDQSPRD_FROM_BIT, `GRM.dxngsr0[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
          $display("-> %0t: [PHYSYS] DX%0dGSR0[%0d:%0d]     = %0h",$time, i, pWLPRD_TO_BIT, pWLPRD_FROM_BIT, `GRM.dxngsr0[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
          
          $display("-> %0t: [PHYSYS] `GRM.gdqsprd_value[%0d] = %0f('h%0h)",$time, i, `GRM.gdqsprd_value[i], `GRM.gdqsprd_value[i]);
          $display("-> %0t: [PHYSYS] `GRM.wlprd_value[%0d]   = %0f('h%0h)",$time, i, `GRM.wlprd_value[i], `GRM.wlprd_value[i]);
        end
        
      end // for loop

      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
    end
  endtask // update_dxngsr0

  task update_dxngsr4;
    input      setting_init_value;
    input      new_multp;
    input      new_cal;
    input      last_vt_multp;

    real       ddr_wl_prd;
    real       gdqs_prd;

    
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXnGSR4",$time);

      `CFG.disable_read_compare;
      repeat (2) @(posedge `CFG.clk);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        
        // writing grm with and initial value when pvtscale is first used.
        // `CAL_DDR_PRD is used to check against the measured value
        if (setting_init_value) begin
`ifdef DWC_DDRPHY_X4X2  
          ddr_wl_prd = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ddr_wl[(i*2)+1]);
          gdqs_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_gdqs  [(i*2)+1]);
`else
          ddr_wl_prd = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_ddr_wl[(i*pNO_OF_DQS)+1]);
          gdqs_prd   = (`CAL_DDR_PRD*(default_ddl_step_size/`PHYSYS.ddl_step_size)/pvtscale_gdqs[(i*pNO_OF_DQS)+1]);
`endif
          
          `GRM.x4wlprd_value[i]     = ddr_wl_prd;
          `GRM.x4gdqsprd_value[i]   = gdqs_prd;

          if (ddr_wl_prd > LCDL_MAX)
            ddr_wl_prd = LCDL_MAX;
          if (ddr_wl_prd <= LCDL_MIN)
            ddr_wl_prd = LCDL_MIN;

          if (gdqs_prd > LCDL_MAX)
            gdqs_prd = LCDL_MAX;
          if (gdqs_prd <= LCDL_MIN)
            gdqs_prd = LCDL_MIN;
          
          // Update ddr_grm with new value    
          `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]      = ddr_wl_prd + rounding;
          `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]  = gdqs_prd + rounding;
        end
        
        // When a dx_cal_update (when dl_calib_state = sCAL_UPDATE),
        // the delay values for WL and GDQS are revert back to LCDL_MIN
        // WDQD and RDQSD are recalculated

        // Use measured value when pvt_mulitplier is used, or else error will be a factor
        // in subsequent calculation. Existing GRM value is used/
        else begin
          if (last_vt_multp) begin
            // A max limit is placed if it is from dx_mdl_cal_update and not a new manual calibration
            // as the delay line calculation has a max value of LCDL_MAX.
            if (`GRM.x4wlprd_value[i] >= LCDL_MAX) 
              ddr_wl_prd = (LCDL_MAX/ last_actual_pvt_multiplier[i]);
            else
              ddr_wl_prd = (`GRM.x4wlprd_value[i]   / last_actual_pvt_multiplier[i]);

            if (`GRM.x4gdqsprd_value[i] >= LCDL_MAX)
              gdqs_prd   = (LCDL_MAX / last_actual_pvt_multiplier[i]);
            else        
              gdqs_prd   = (`GRM.x4gdqsprd_value[i] / last_actual_pvt_multiplier[i]);

          end
          else begin
            // A new manual calibration might start off from a *_value which is above
            // the max, but the mulitplier factor might put it back within the valid
            // range. Hence, check the max limit after the multiplier factor is included.
            if (new_multp && new_cal) begin
              ddr_wl_prd = (`GRM.x4wlprd_value[i]   / actual_pvt_multiplier[i]);
              gdqs_prd   = (`GRM.x4gdqsprd_value[i] / actual_pvt_multiplier[i]);
            end
            else begin
              ddr_wl_prd = `GRM.x4wlprd_value[i];
              gdqs_prd   = `GRM.x4gdqsprd_value[i];
            end
          end

          if (ddr_wl_prd > LCDL_MAX)
            ddr_wl_prd = LCDL_MAX;
          if (ddr_wl_prd <= LCDL_MIN)
            ddr_wl_prd = LCDL_MIN;

          if (gdqs_prd > LCDL_MAX)
            gdqs_prd = LCDL_MAX;
          if (gdqs_prd <= LCDL_MIN)
            gdqs_prd = LCDL_MIN;
          
          if (`GRM.x4wlprd_value[i]   != 0)  `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]   = ddr_wl_prd + rounding;
          if (`GRM.x4gdqsprd_value[i] != 0)  `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]  = gdqs_prd + rounding;  
        end // else: !if(setting_init_value)

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] actual_pvt_multiplier [%0d]     = %0f",$time, i, actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] DX%0dGSR4[%0d:%0d]     = %0h",$time, i, pGDQSPRD_TO_BIT, pGDQSPRD_FROM_BIT, `GRM.dxngsr4[i][pGDQSPRD_TO_BIT:pGDQSPRD_FROM_BIT]);
          $display("-> %0t: [PHYSYS] DX%0dGSR4[%0d:%0d]     = %0h",$time, i, pWLPRD_TO_BIT, pWLPRD_FROM_BIT, `GRM.dxngsr4[i][pWLPRD_TO_BIT:pWLPRD_FROM_BIT]);
          
          $display("-> %0t: [PHYSYS] `GRM.x4gdqsprd_value[%0d] = %0f('h%0h)",$time, i, `GRM.x4gdqsprd_value[i], `GRM.x4gdqsprd_value[i]);
          $display("-> %0t: [PHYSYS] `GRM.x4wlprd_value[%0d]   = %0f('h%0h)",$time, i, `GRM.x4wlprd_value[i], `GRM.x4wlprd_value[i]);
        end
        
      end // for loop

      repeat (5) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
    end
  endtask // update_dxngsr4

  // Update ACBDLR0
  // ACBDLR0[ 5: 0].CK0BD
  // ACBDLR0[13: 8].CK1BD
  // ACBDLR0[21:16].CK2BD
  // ACBDLR0[29:24].CK3BD
  task update_acbdlr0;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR0",$time);

      if (default_val)
        `GRM.acbdlr0[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr0_ck0bd_value != 0) `GRM.acbdlr0  [5:0] = `GRM.acbdlr0_ck0bd_value;
          if (`GRM.acbdlr0_ck1bd_value != 0) `GRM.acbdlr0 [13:8] = `GRM.acbdlr0_ck1bd_value;
          if (`GRM.acbdlr0_ck2bd_value != 0) `GRM.acbdlr0[21:16] = `GRM.acbdlr0_ck2bd_value;
          if (`GRM.acbdlr0_ck3bd_value != 0) `GRM.acbdlr0[29:24] = `GRM.acbdlr0_ck3bd_value;
        end
      end
    end
  endtask // update_acbdlr0

  // Update ACBDLR1
  // ACBDLR1[ 5: 0].RASBD
  // ACBDLR1[13: 8].CASBD
  // ACBDLR1[21:16].WEBD
  // ACBDLR1[29:24].PARBD
  task update_acbdlr1;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR1",$time);

      if (default_val)
        `GRM.acbdlr1[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr1_actbd_value != 0) `GRM.acbdlr1  [5:0] = `GRM.acbdlr1_actbd_value;
          if (`GRM.acbdlr1_a17bd_value != 0) `GRM.acbdlr1 [13:8] = `GRM.acbdlr1_a17bd_value;
          if (`GRM.acbdlr1_a16bd_value  != 0) `GRM.acbdlr1[21:16] = `GRM.acbdlr1_a16bd_value;
          if (`GRM.acbdlr1_parbd_value != 0) `GRM.acbdlr1[29:24] = `GRM.acbdlr1_parbd_value;
        end
      end
    end
  endtask // update_acbdlr1

  // Update ACBDLR2
  // ACBDLR2[ 5: 0].BA0BD
  // ACBDLR2[13: 8].BA1BD
  // ACBDLR2[21:16].BA2BD
  // ACBDLR2[29:24].ACPDDBD
  task update_acbdlr2;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR2",$time);

      if (default_val)
        `GRM.acbdlr2[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr2_ba0bd_value != 0) `GRM.acbdlr2  [5:0] = `GRM.acbdlr2_ba0bd_value;
          if (`GRM.acbdlr2_ba1bd_value != 0) `GRM.acbdlr2 [13:8] = `GRM.acbdlr2_ba1bd_value;
          if (`GRM.acbdlr2_ba2bd_value != 0) `GRM.acbdlr2[21:16] = `GRM.acbdlr2_ba2bd_value;
          if (`GRM.acbdlr2_ba3bd_value != 0) `GRM.acbdlr2[29:24] = `GRM.acbdlr2_ba3bd_value;
        end
      end
    end
  endtask // update_acbdlr2

  // Update ACBDLR3
  // ACBDLR3[ 5: 0].CS0BD
  // ACBDLR3[13: 8].CS1BD
  // ACBDLR3[21:16].CS2BD
  // ACBDLR3[29:24].CS3BD
  task update_acbdlr3;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR3",$time);

      if (default_val)
        `GRM.acbdlr3[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr3_cs0bd_value != 0) `GRM.acbdlr3  [5:0] = `GRM.acbdlr3_cs0bd_value;
          if (`GRM.acbdlr3_cs1bd_value != 0) `GRM.acbdlr3 [13:8] = `GRM.acbdlr3_cs1bd_value;
          if (`GRM.acbdlr3_cs2bd_value != 0) `GRM.acbdlr3[21:16] = `GRM.acbdlr3_cs2bd_value;
          if (`GRM.acbdlr3_cs3bd_value != 0) `GRM.acbdlr3[29:24] = `GRM.acbdlr3_cs3bd_value;
        end
      end
    end
  endtask // update_acbdlr3

  // Update ACBDLR4
  // ACBDLR4[ 5: 0].ODT0BD
  // ACBDLR4[13: 8].ODT1BD
  // ACBDLR4[21:16].ODT2BD
  // ACBDLR4[29:24].ODT3BD
  task update_acbdlr4;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR4",$time);

      if (default_val)
        `GRM.acbdlr4[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr4_odt0bd_value != 0) `GRM.acbdlr4  [5:0] = `GRM.acbdlr4_odt0bd_value;
          if (`GRM.acbdlr4_odt1bd_value != 0) `GRM.acbdlr4 [13:8] = `GRM.acbdlr4_odt1bd_value;
          if (`GRM.acbdlr4_odt2bd_value != 0) `GRM.acbdlr4[21:16] = `GRM.acbdlr4_odt2bd_value;
          if (`GRM.acbdlr4_odt3bd_value != 0) `GRM.acbdlr4[29:24] = `GRM.acbdlr4_odt3bd_value;
        end
      end
    end
  endtask // update_acbdlr4

  // Update ACBDLR5
  // ACBDLR5[ 5: 0].CKE0BD
  // ACBDLR5[13: 8].CKE1BD
  // ACBDLR5[21:16].CKE2BD
  // ACBDLR5[29:24].CKE3BD
  task update_acbdlr5;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR5",$time);

      if (default_val)
        `GRM.acbdlr5[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr5_cke0bd_value != 0) `GRM.acbdlr5  [5:0] = `GRM.acbdlr5_cke0bd_value;
          if (`GRM.acbdlr5_cke1bd_value != 0) `GRM.acbdlr5 [13:8] = `GRM.acbdlr5_cke1bd_value;
          if (`GRM.acbdlr5_cke2bd_value != 0) `GRM.acbdlr5[21:16] = `GRM.acbdlr5_cke2bd_value;
          if (`GRM.acbdlr5_cke3bd_value != 0) `GRM.acbdlr5[29:24] = `GRM.acbdlr5_cke3bd_value;
        end
      end
    end
  endtask // update_acbdlr5

  // Update ACBDLR6
  // ACBDLR6[ 5: 0].A00BD
  // ACBDLR6[13: 8].A01BD
  // ACBDLR6[21:16].A02BD
  // ACBDLR6[29:24].A03BD
  task update_acbdlr6;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR6",$time);

      if (default_val)
        `GRM.acbdlr6[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr6_a00bd_value != 0) `GRM.acbdlr6  [5:0] = `GRM.acbdlr6_a00bd_value;
          if (`GRM.acbdlr6_a01bd_value != 0) `GRM.acbdlr6 [13:8] = `GRM.acbdlr6_a01bd_value;
          if (`GRM.acbdlr6_a02bd_value != 0) `GRM.acbdlr6[21:16] = `GRM.acbdlr6_a02bd_value;
          if (`GRM.acbdlr6_a03bd_value != 0) `GRM.acbdlr6[29:24] = `GRM.acbdlr6_a03bd_value;
        end
      end
    end
  endtask // update_acbdlr6

  // Update ACBDLR7
  // ACBDLR7[ 5: 0].A04BD
  // ACBDLR7[13: 8].A05BD
  // ACBDLR7[21:16].A06BD
  // ACBDLR7[29:24].A07BD
  task update_acbdlr7;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR7",$time);

      if (default_val)
        `GRM.acbdlr7[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr7_a04bd_value != 0) `GRM.acbdlr7  [5:0] = `GRM.acbdlr7_a04bd_value;
          if (`GRM.acbdlr7_a05bd_value != 0) `GRM.acbdlr7 [13:8] = `GRM.acbdlr7_a05bd_value;
          if (`GRM.acbdlr7_a06bd_value != 0) `GRM.acbdlr7[21:16] = `GRM.acbdlr7_a06bd_value;
          if (`GRM.acbdlr7_a07bd_value != 0) `GRM.acbdlr7[29:24] = `GRM.acbdlr7_a07bd_value;
        end
      end
    end
  endtask // update_acbdlr7

  // Update ACBDLR8
  // ACBDLR8[ 5: 0].A08BD
  // ACBDLR8[13: 8].A09BD
  // ACBDLR8[21:16].A10BD
  // ACBDLR8[29:24].A11BD
  task update_acbdlr8;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR8",$time);

      if (default_val)
        `GRM.acbdlr8[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr8_a08bd_value != 0) `GRM.acbdlr8  [5:0] = `GRM.acbdlr8_a08bd_value;
          if (`GRM.acbdlr8_a09bd_value != 0) `GRM.acbdlr8 [13:8] = `GRM.acbdlr8_a09bd_value;
          if (`GRM.acbdlr8_a10bd_value != 0) `GRM.acbdlr8[21:16] = `GRM.acbdlr8_a10bd_value;
          if (`GRM.acbdlr8_a11bd_value != 0) `GRM.acbdlr8[29:24] = `GRM.acbdlr8_a11bd_value;
        end
      end
    end
  endtask // update_acbdlr8

  // Update ACBDLR9
  // ACBDLR9[ 5: 0].A12BD
  // ACBDLR9[13: 8].A13BD
  // ACBDLR9[21:16].A14BD
  // ACBDLR9[29:24].A15BD
  task update_acbdlr9;
    input      default_val;
    input      vt_update;
    begin 
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating AC BDLR9",$time);

      if (default_val)
        `GRM.acbdlr9[31:0] = 32'h0;
      else begin
        if (vt_update) begin
          // NB: These AC BDL are not affected by pvt_multiplier
          // do not apply the multiply factor and rounding if value is zero to start with
          if (`GRM.acbdlr9_a12bd_value != 0) `GRM.acbdlr9  [5:0] = `GRM.acbdlr9_a12bd_value;
          if (`GRM.acbdlr9_a13bd_value != 0) `GRM.acbdlr9 [13:8] = `GRM.acbdlr9_a13bd_value;
          if (`GRM.acbdlr9_a14bd_value != 0) `GRM.acbdlr9[21:16] = `GRM.acbdlr9_a14bd_value;
          if (`GRM.acbdlr9_a15bd_value != 0) `GRM.acbdlr9[29:24] = `GRM.acbdlr9_a15bd_value;
        end
      end
    end
  endtask // update_acbdlr9

  // NB:
  // These groups following will use the ratio that is based on read/measured mdl init vs target
  // register values instead of the pvt_multiplier ration that was forced.
  //
  // Update DXnBDLR1 registers:
  // DXnBDLR0[ 5: 0].DQ0WBD
  // DXnBDLR0[13: 8].DQ1WBD
  // DXnBDLR0[21:16].DQ2WBD
  // DXnBDLR0[29:24].DQ3WBD
  task update_dxnbdlr0;
    input      vt_update;
    input      revert_last_pvt_mult;
    
    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    real       tmp_3;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR0",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        tmp_3 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0  = (`GRM.dq0wbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq1wbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq2wbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq3wbd_value[i]/ last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr0[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr0[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr0[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr0[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr0[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr0[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr0[%0d][29:24] = %0h",$time, i,`GRM.dxnbdlr0[i][29:24]);
              end
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dq(0-4)wbd_value
          if (revert_last_pvt_mult) begin
            tmp_0  = (`GRM.dq0wbd_value[i]* last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq1wbd_value[i]* last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq2wbd_value[i]* last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq3wbd_value[i]* last_actual_pvt_multiplier[i]);

            `GRM.dq0wbd_value[i]  = (`GRM.dq0wbd_value[i]* last_actual_pvt_multiplier[i]);
            `GRM.dq1wbd_value[i]  = (`GRM.dq1wbd_value[i]* last_actual_pvt_multiplier[i]);
            `GRM.dq2wbd_value[i]  = (`GRM.dq2wbd_value[i]* last_actual_pvt_multiplier[i]);
            `GRM.dq3wbd_value[i]  = (`GRM.dq3wbd_value[i]* last_actual_pvt_multiplier[i]);
            
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;

          if (tmp_3 > BDL_MAX)
            tmp_3 = BDL_MAX;
          if (tmp_3 <= BDL_MIN)
            tmp_3 = BDL_MIN;

          if (`GRM.dq0wbd_value[i] != 0) `GRM.dxnbdlr0[i]  [5:0] = tmp_0 + rounding;
          if (`GRM.dq1wbd_value[i] != 0) `GRM.dxnbdlr0[i] [13:8] = tmp_1 + rounding;
          if (`GRM.dq2wbd_value[i] != 0) `GRM.dxnbdlr0[i][21:16] = tmp_2 + rounding;
          if (`GRM.dq3wbd_value[i] != 0) `GRM.dxnbdlr0[i][29:24] = tmp_3 + rounding;

        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr0[29:24]     = %0h",$time, i, `GRM.dxnbdlr0[i][29:24]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr0[21:16]     = %0h",$time, i, `GRM.dxnbdlr0[i][21:16]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr0[13:8]      = %0h",$time, i, `GRM.dxnbdlr0[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr0[5:0]       = %0h",$time, i, `GRM.dxnbdlr0[i][5:0]);
          
          $display("-> %0t: [PHYSYS] GRM.dq0wbd_value[%0d] = %0h",$time, i, `GRM.dq0wbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq1wbd_value[%0d] = %0h",$time, i, `GRM.dq1wbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq2wbd_value[%0d] = %0h",$time, i, `GRM.dq2wbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq3wbd_value[%0d] = %0h",$time, i, `GRM.dq3wbd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr0
  
  // Update DXnBDLR1 registers:
  // DXnBDLR1[ 5: 0].DQ4WBD
  // DXnBDLR1[13: 8].DQ5WBD
  // DXnBDLR1[21:16].DQ6WBD
  // DXnBDLR1[29:24].DQ7WBD
  task update_dxnbdlr1;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    real       tmp_3;

    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR1",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        tmp_3 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0  = (`GRM.dq4wbd_value[i] / last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq5wbd_value[i] / last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq6wbd_value[i] / last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq7wbd_value[i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr1[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr1[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr1[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr1[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr1[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr1[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr1[%0d][29:24] = %0h",$time, i,`GRM.dxnbdlr1[i][29:24]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dq(5-7,dm,ds)wbd_value
          if (revert_last_pvt_mult) begin
            tmp_0  = (`GRM.dq4wbd_value[i]* last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq5wbd_value[i]* last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq6wbd_value[i]* last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq7wbd_value[i]* last_actual_pvt_multiplier[i]);

            `GRM.dq4wbd_value[i]  = (`GRM.dq4wbd_value[i]* last_actual_pvt_multiplier[i]);
            `GRM.dq5wbd_value[i]  = (`GRM.dq5wbd_value[i]* last_actual_pvt_multiplier[i]);
            `GRM.dq6wbd_value[i]  = (`GRM.dq6wbd_value[i]* last_actual_pvt_multiplier[i]);
            `GRM.dq7wbd_value[i]  = (`GRM.dq7wbd_value[i]* last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;

          if (tmp_3 > BDL_MAX)
            tmp_3 = BDL_MAX;
          if (tmp_3 <= BDL_MIN)
            tmp_3 = BDL_MIN;

          if (`GRM.dq4wbd_value[i] != 0) `GRM.dxnbdlr1[i][ 5: 0] = tmp_0 + rounding;
          if (`GRM.dq5wbd_value[i] != 0) `GRM.dxnbdlr1[i][13: 8] = tmp_1 + rounding;
          if (`GRM.dq6wbd_value[i] != 0) `GRM.dxnbdlr1[i][21:16] = tmp_2 + rounding;
          if (`GRM.dq7wbd_value[i] != 0) `GRM.dxnbdlr1[i][29:24] = tmp_3 + rounding;
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr1[29:24]     = %0h",$time, i, `GRM.dxnbdlr1[i][29:24]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr1[21:16]     = %0h",$time, i, `GRM.dxnbdlr1[i][21:16]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr1[13:8]      = %0h",$time, i, `GRM.dxnbdlr1[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr1[5:0]       = %0h",$time, i, `GRM.dxnbdlr1[i][5:0]);

          $display("-> %0t: [PHYSYS] GRM.dq4wbd_value[%0d] = %0h",$time, i, `GRM.dq4wbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq5wbd_value[%0d] = %0h",$time, i, `GRM.dq5wbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq6wbd_value[%0d] = %0h",$time, i, `GRM.dq6wbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq7wbd_value[%0d] = %0h",$time, i, `GRM.dq7wbd_value[i]);

        end

      end // for loop
      
    end
  endtask // update_dxnbdlr1
  
  // Update DXnBDLR2 registers:
  // DXnBDLR2[ 5: 0].DMWBD
  // DXnBDLR2[13: 8].DSWBD
  // DXnBDLR2[21:16].OEBD
  task update_dxnbdlr2;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR2",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0 = (`GRM.dmwbd_value   [i] / last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.dswbd_value   [i] / last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.dqsoebd_value [i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr2[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr2[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr2[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr2[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr2[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr2[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
              
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dqsoebd_value and dqoebd_value
          if (revert_last_pvt_mult) begin
            tmp_0 = (`GRM.dmwbd_value   [i] * last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.dswbd_value   [i] * last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.dqsoebd_value [i] * last_actual_pvt_multiplier[i]);


            `GRM.dmwbd_value  [i] = (`GRM.dmwbd_value  [i] * last_actual_pvt_multiplier[i]);
            `GRM.dswbd_value  [i] = (`GRM.dswbd_value  [i] * last_actual_pvt_multiplier[i]);
            `GRM.dqsoebd_value[i] = (`GRM.dqsoebd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;
  
          if (`GRM.dmwbd_value   [i] != 0)  `GRM.dxnbdlr2[i][ 5: 0] = tmp_0 + rounding;
          if (`GRM.dswbd_value   [i] != 0)  `GRM.dxnbdlr2[i][13: 8] = tmp_1 + rounding;
          if (`GRM.dqsoebd_value [i] != 0)  `GRM.dxnbdlr2[i][21:16] = tmp_2 + rounding;
          
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr2[5:0]       = %0h",$time, i, `GRM.dxnbdlr2[i][5:0]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr2[13:8]      = %0h",$time, i, `GRM.dxnbdlr2[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr2[21:16]     = %0h",$time, i, `GRM.dxnbdlr2[i][21:16]);

          $display("-> %0t: [PHYSYS] GRM.dmwbd_value  [i] = %0h", $time, `GRM.dmwbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.dswbd_value  [i] = %0h", $time, `GRM.dswbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.dqsoebd_value[i] = %0h", $time, `GRM.dqsoebd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr2
  
  // Update DXnBDLR3 registers:
  // DXnBDLR3[ 5: 0].DQ0RBD
  // DXnBDLR3[13: 8].DQ1RBD
  // DXnBDLR3[21:16].DQ2RBD
  // DXnBDLR3[29:24].DQ3RBD
  task update_dxnbdlr3;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    real       tmp_3;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR3",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        tmp_3 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0  = (`GRM.dq0rbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq1rbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq2rbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq3rbd_value[i]/ last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr3[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr3[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr3[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr3[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr3[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr3[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr3[%0d][29:24] = %0h",$time, i,`GRM.dxnbdlr3[i][29:24]);
              end
            end
          end
          // Day value has been written over, hence recalculate the value before the pvt multiplier
          // bmultiplying with the last_actual_pvt_multiplier and store that value back to
          // d0-4)rbd_value
          if (revert_last_pvt_mult) begin
            tmp_0  = (`GRM.dq0rbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq1rbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq2rbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq3rbd_value[i] * last_actual_pvt_multiplier[i]);

            `GRM.dq0rbd_value[i]  = (`GRM.dq0rbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.dq1rbd_value[i]  = (`GRM.dq1rbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.dq2rbd_value[i]  = (`GRM.dq2rbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.dq3rbd_value[i]  = (`GRM.dq3rbd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;

          if (tmp_3 > BDL_MAX)
            tmp_3 = BDL_MAX;
          if (tmp_3 <= BDL_MIN)
            tmp_3 = BDL_MIN;

          if (`GRM.dq0rbd_value[i] != 0) `GRM.dxnbdlr3[i]  [5:0] = tmp_0 + rounding;
          if (`GRM.dq1rbd_value[i] != 0) `GRM.dxnbdlr3[i] [13:8] = tmp_1 + rounding;
          if (`GRM.dq2rbd_value[i] != 0) `GRM.dxnbdlr3[i][21:16] = tmp_2 + rounding;
          if (`GRM.dq3rbd_value[i] != 0) `GRM.dxnbdlr3[i][29:24] = tmp_3 + rounding;

        end
        
        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr3[29:24] = %0h",$time, i, `GRM.dxnbdlr3[i][29:24]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr3[21:16] = %0h",$time, i, `GRM.dxnbdlr3[i][21:16]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr3[13:8]  = %0h",$time, i, `GRM.dxnbdlr3[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr3[5:0]   = %0h",$time, i, `GRM.dxnbdlr3[i][5:0]);

          $display("-> %0t: [PHYSYS] GRM.dq3rbd_value[%0d] = %0h",$time, i, `GRM.dq3rbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq2rbd_value[%0d] = %0h",$time, i, `GRM.dq2rbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq1rbd_value[%0d] = %0h",$time, i, `GRM.dq1rbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq0rbd_value[%0d] = %0h",$time, i, `GRM.dq0rbd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr3
  
  // Update DXnBDLR4 registers:
  // DXnBDLR4[ 5: 0].DQ4RBD
  // DXnBDLR4[13: 8].DQ5RBD
  // DXnBDLR4[21:16].DQ6RBD
  // DXnBDLR4[29:24].DQ7RBD
  task update_dxnbdlr4;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    real       tmp_3;
    
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer   i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR4",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        tmp_3 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // Do not apply the multiply factor and rounding if value is zero to start with
            tmp_0  = (`GRM.dq4rbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq5rbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq6rbd_value[i]/ last_actual_pvt_multiplier[i]);
            tmp_3  = (`GRM.dq7rbd_value[i]/ last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr4[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr4[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr4[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr4[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr4[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr4[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr4[%0d][29:24] = %0h",$time, i,`GRM.dxnbdlr4[i][29:24]);
              end
            end // if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0)
          end // if (vt_update)
          
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dq(4-7)rbd_value
          if (revert_last_pvt_mult) begin
            tmp_0  = (`GRM.dq4rbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_0  = (`GRM.dq5rbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_1  = (`GRM.dq6rbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_2  = (`GRM.dq7rbd_value[i] * last_actual_pvt_multiplier[i]);

            `GRM.dq4rbd_value[i]  = (`GRM.dq4rbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.dq5rbd_value[i]  = (`GRM.dq5rbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.dq6rbd_value[i]  = (`GRM.dq6rbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.dq7rbd_value[i]  = (`GRM.dq7rbd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;

          if (tmp_3 > BDL_MAX)
            tmp_3 = BDL_MAX;
          if (tmp_3 <= BDL_MIN)
            tmp_3 = BDL_MIN;

          if (`GRM.dq4rbd_value[i] != 0) `GRM.dxnbdlr4[i][ 5: 0] = tmp_0 + rounding;
          if (`GRM.dq5rbd_value[i] != 0) `GRM.dxnbdlr4[i][13: 8] = tmp_1 + rounding;
          if (`GRM.dq6rbd_value[i] != 0) `GRM.dxnbdlr4[i][21:16] = tmp_2 + rounding;
          if (`GRM.dq7rbd_value[i] != 0) `GRM.dxnbdlr4[i][29:24] = tmp_3 + rounding;

        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr4[29:24]     = %0h",$time, i, `GRM.dxnbdlr4[i][29:24]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr4[21:16]     = %0h",$time, i, `GRM.dxnbdlr4[i][21:16]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr4[13:8]      = %0h",$time, i, `GRM.dxnbdlr4[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr4[5:0]       = %0h",$time, i, `GRM.dxnbdlr4[i][5:0]);

          $display("-> %0t: [PHYSYS] GRM.dq4rbd_value[%0d] = %0h",$time, i, `GRM.dq4rbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq5rbd_value[%0d] = %0h",$time, i, `GRM.dq5rbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq6rbd_value[%0d] = %0h",$time, i, `GRM.dq6rbd_value[i]);
          $display("-> %0t: [PHYSYS] GRM.dq7rbd_value[%0d] = %0h",$time, i, `GRM.dq7rbd_value[i]);
        end 

      end // for loop
      
    end
  endtask // update_dxnbdlr4
  
  // Update DXnBDLR5 registers:
  // DXnBDLR5[ 5: 0].DMWBD
  // DXnBDLR5[13: 8].DSWBD
  // DXnBDLR5[21:16].OEBD
  task update_dxnbdlr5;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR5",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0 = (`GRM.dmrbd_value [i] / last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.dsrbd_value [i] / last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.dsnrbd_value[i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr5[%0d][29:24] = %0h",$time, i,`GRM.dxnbdlr5[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr5[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr5[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr5[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr5[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
              
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dsnrbd_value and dqoebd_value
          if (revert_last_pvt_mult) begin
            tmp_0 = (`GRM.dmrbd_value [i] * last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.dsrbd_value [i] * last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.dsnrbd_value[i] * last_actual_pvt_multiplier[i]);


            `GRM.dmrbd_value [i] = (`GRM.dmrbd_value [i] * last_actual_pvt_multiplier[i]);
            `GRM.dsrbd_value [i] = (`GRM.dsrbd_value [i] * last_actual_pvt_multiplier[i]);
            `GRM.dsnrbd_value[i] = (`GRM.dsnrbd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;
  
          if (`GRM.dmrbd_value [i] != 0)  `GRM.dxnbdlr5[i][ 5: 0] = tmp_0 + rounding;
          if (`GRM.dsrbd_value [i] != 0)  `GRM.dxnbdlr5[i][13: 8] = tmp_1 + rounding;
          if (`GRM.dsnrbd_value[i] != 0)  `GRM.dxnbdlr5[i][21:16] = tmp_2 + rounding;
          
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr5[5:0]   = %0h",$time, i, `GRM.dxnbdlr5[i][5:0]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr5[13:8]  = %0h",$time, i, `GRM.dxnbdlr5[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr5[21:16] = %0h",$time, i, `GRM.dxnbdlr5[i][21:16]);

          $display("-> %0t: [PHYSYS] GRM.dmrbd_value [i]   = %0h", $time, `GRM.dmrbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.dsrbd_value [i]   = %0h", $time, `GRM.dsrbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.dsnrbd_value[i]   = %0h", $time, `GRM.dsnrbd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr5

  // Update DXnBDLR6 registers:
  // DXnBDLR6[ 5: 0].PDDBD
  // DXnBDLR6[13: 8].PDRBD
  // DXnBDLR6[21:16].TERBD
  task update_dxnbdlr6;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR6",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_1 = (`GRM.pdrbd_value[i] / last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.terbd_value[i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr6[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr6[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr6[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr6[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr6[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr6[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
              
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dqsoebd_value and dqoebd_value
          if (revert_last_pvt_mult) begin
            tmp_1 = (`GRM.pdrbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.terbd_value[i] * last_actual_pvt_multiplier[i]);

            `GRM.pdrbd_value[i] = (`GRM.pdrbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.terbd_value[i] = (`GRM.terbd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;

          if (`GRM.pdrbd_value[i] != 0)  `GRM.dxnbdlr6[i][13: 8] = tmp_1 + rounding;
          if (`GRM.terbd_value[i] != 0)  `GRM.dxnbdlr6[i][21:16] = tmp_2 + rounding;
          
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr6[5:0]       = %0h",$time, i, `GRM.dxnbdlr6[i][5:0]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr6[13:8]      = %0h",$time, i, `GRM.dxnbdlr6[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr6[21:16]     = %0h",$time, i, `GRM.dxnbdlr6[i][21:16]);

          $display("-> %0t: [PHYSYS] GRM.pddbd_value  [i] = %0h", $time, `GRM.pddbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.pdrbd_value  [i] = %0h", $time, `GRM.pdrbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.terbd_value[i] = %0h", $time, `GRM.terbd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr6
 
  // Update DXnBDLR7 registers:
  // DXnBDLR7[ 5: 0].X4DMWBD
  // DXnBDLR7[13: 8].X4DSWBD
  // DXnBDLR7[21:16].X4OEBD
  task update_dxnbdlr7;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR7",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
             
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0 = (`GRM.x4dmwbd_value   [i] / last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.x4dswbd_value   [i] / last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.x4dqsoebd_value [i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr7[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr7[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr7[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr7[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr7[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr7[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
              
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // x4dqsoebd_value and dqoebd_value
          if (revert_last_pvt_mult) begin
            tmp_0 = (`GRM.x4dmwbd_value   [i] * last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.x4dswbd_value   [i] * last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.x4dqsoebd_value [i] * last_actual_pvt_multiplier[i]);


            `GRM.x4dmwbd_value  [i] = (`GRM.x4dmwbd_value  [i] * last_actual_pvt_multiplier[i]);
            `GRM.x4dswbd_value  [i] = (`GRM.x4dswbd_value  [i] * last_actual_pvt_multiplier[i]);
            `GRM.x4dqsoebd_value[i] = (`GRM.x4dqsoebd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;
  
          if (`GRM.x4dmwbd_value   [i] != 0)  `GRM.dxnbdlr7[i][ 5: 0] = tmp_0 + rounding;
          if (`GRM.x4dswbd_value   [i] != 0)  `GRM.dxnbdlr7[i][13: 8] = tmp_1 + rounding;
          if (`GRM.x4dqsoebd_value [i] != 0)  `GRM.dxnbdlr7[i][21:16] = tmp_2 + rounding;
          
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr7[5:0]       = %0h",$time, i, `GRM.dxnbdlr7[i][5:0]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr7[13:8]      = %0h",$time, i, `GRM.dxnbdlr7[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr7[21:16]     = %0h",$time, i, `GRM.dxnbdlr7[i][21:16]);

          $display("-> %0t: [PHYSYS] GRM.x4dmwbd_value  [i] = %0h", $time, `GRM.x4dmwbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.x4dswbd_value  [i] = %0h", $time, `GRM.x4dswbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.x4dqsoebd_value[i] = %0h", $time, `GRM.x4dqsoebd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr7
   
  // Update DXnBDLR8 registers:
  // DXnBDLR8[ 5: 0].X4DMRBD
  // DXnBDLR8[13: 8].X4DSRBD
  // DXnBDLR8[21:16].X4DSNRBD
  task update_dxnbdlr8;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR8",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_0 = (`GRM.x4dmrbd_value [i] / last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.x4dsrbd_value [i] / last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.x4dsnrbd_value[i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr8[%0d][29:24] = %0h",$time, i,`GRM.dxnbdlr8[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr8[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr8[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr8[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr8[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
              
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // x4dsnrbd_value and dqoebd_value
          if (revert_last_pvt_mult) begin
            tmp_0 = (`GRM.x4dmrbd_value [i] * last_actual_pvt_multiplier[i]);
            tmp_1 = (`GRM.x4dsrbd_value [i] * last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.x4dsnrbd_value[i] * last_actual_pvt_multiplier[i]);


            `GRM.x4dmrbd_value [i] = (`GRM.x4dmrbd_value [i] * last_actual_pvt_multiplier[i]);
            `GRM.x4dsrbd_value [i] = (`GRM.x4dsrbd_value [i] * last_actual_pvt_multiplier[i]);
            `GRM.x4dsnrbd_value[i] = (`GRM.x4dsnrbd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;
  
          if (`GRM.x4dmrbd_value [i] != 0)  `GRM.dxnbdlr8[i][ 5: 0] = tmp_0 + rounding;
          if (`GRM.x4dsrbd_value [i] != 0)  `GRM.dxnbdlr8[i][13: 8] = tmp_1 + rounding;
          if (`GRM.x4dsnrbd_value[i] != 0)  `GRM.dxnbdlr8[i][21:16] = tmp_2 + rounding;
          
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr8[5:0]   = %0h",$time, i, `GRM.dxnbdlr8[i][5:0]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr8[13:8]  = %0h",$time, i, `GRM.dxnbdlr8[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr8[21:16] = %0h",$time, i, `GRM.dxnbdlr8[i][21:16]);

          $display("-> %0t: [PHYSYS] GRM.x4dmrbd_value [i]   = %0h", $time, `GRM.x4dmrbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.x4dsrbd_value [i]   = %0h", $time, `GRM.x4dsrbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.x4dsnrbd_value[i]   = %0h", $time, `GRM.x4dsnrbd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr8

  // Update DXnBDLR9 registers:
  // DXnBDLR9[ 5: 0].X4PDDBD
  // DXnBDLR9[13: 8].X4PDRBD
  // DXnBDLR9[21:16].X4TERBD
  task update_dxnbdlr9;
    input      vt_update;
    input      revert_last_pvt_mult;

    real       tmp_0;
    real       tmp_1;
    real       tmp_2;
    
    reg [31:0] reg_data;
    reg [`REG_ADDR_WIDTH-1:0]  reg_addr;
    integer    i;
    begin
      if (verbose > pvt_debug)
        $display("-> %0t: [PHYSYS] ------> Updating DXn BDLR9",$time);

      for (i=0;i<`DWC_NO_OF_BYTES;i=i+1) begin
        tmp_0 = 0.0;
        tmp_1 = 0.0;
        tmp_2 = 0.0;
        
        if (vt_update || revert_last_pvt_mult) begin
          if (vt_update) begin
            // do not apply the multiply factor and rounding if value is zero to start with
            tmp_1 = (`GRM.x4pdrbd_value[i] / last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.x4terbd_value[i] / last_actual_pvt_multiplier[i]);

            if (`GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT] != 8'h0) begin
              if (verbose > pvt_debug) begin
                $display("-> %0t: [PHYSYS] ------> dxnbdlr9[%0d][21:16] = %0h",$time, i,`GRM.dxnbdlr9[i][21:16]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr9[%0d][13:8]  = %0h",$time, i,`GRM.dxnbdlr9[i][13:8]);
                $display("-> %0t: [PHYSYS] ------> dxnbdlr9[%0d][5:0]   = %0h",$time, i,`GRM.dxnbdlr9[i][5:0]);
                $display("-> %0t: [PHYSYS] ------> pgcr1[%0d:%0d]            = %0h",$time, pPGCR1_DLDLMT_TO_BIT, pPGCR1_DLDLMT_FROM_BIT, `GRM.pgcr1[pPGCR1_DLDLMT_TO_BIT:pPGCR1_DLDLMT_FROM_BIT]);
              end
              
            end
          end
          // Delay value has been written over, hence recalculate the value before the pvt multiplier
          // by multiplying with the last_actual_pvt_multiplier and store that value back to
          // dqsoebd_value and dqoebd_value
          if (revert_last_pvt_mult) begin
            tmp_1 = (`GRM.x4pdrbd_value[i] * last_actual_pvt_multiplier[i]);
            tmp_2 = (`GRM.x4terbd_value[i] * last_actual_pvt_multiplier[i]);


            `GRM.x4pddbd_value[i] = (`GRM.x4pddbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.x4pdrbd_value[i] = (`GRM.x4pdrbd_value[i] * last_actual_pvt_multiplier[i]);
            `GRM.x4terbd_value[i] = (`GRM.x4terbd_value[i] * last_actual_pvt_multiplier[i]);
          end
          
          if (tmp_0 > BDL_MAX)
            tmp_0 = BDL_MAX;
          if (tmp_0 <= BDL_MIN)
            tmp_0 = BDL_MIN;

          if (tmp_1 > BDL_MAX)
            tmp_1 = BDL_MAX;
          if (tmp_1 <= BDL_MIN)
            tmp_1 = BDL_MIN;

          if (tmp_2 > BDL_MAX)
            tmp_2 = BDL_MAX;
          if (tmp_2 <= BDL_MIN)
            tmp_2 = BDL_MIN;
          if (`GRM.x4pdrbd_value[i] != 0)  `GRM.dxnbdlr9[i][13: 8] = tmp_1 + rounding;
          if (`GRM.x4terbd_value[i] != 0)  `GRM.dxnbdlr9[i][21:16] = tmp_2 + rounding;
          
        end

        if (verbose > pvt_detail_debug) begin
          $display("-> %0t: [PHYSYS] last_actual_pvt_multiplier[%0d] = %0f",$time, i, last_actual_pvt_multiplier[i]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr9[5:0]       = %0h",$time, i, `GRM.dxnbdlr9[i][5:0]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr9[13:8]      = %0h",$time, i, `GRM.dxnbdlr9[i][13:8]);
          $display("-> %0t: [PHYSYS] GRM.dx%0dbdlr9[21:16]     = %0h",$time, i, `GRM.dxnbdlr9[i][21:16]);

          $display("-> %0t: [PHYSYS] GRM.x4pddbd_value  [i] = %0h", $time, `GRM.x4pddbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.x4pdrbd_value  [i] = %0h", $time, `GRM.x4pdrbd_value  [i]);
          $display("-> %0t: [PHYSYS] GRM.x4terbd_value[i] = %0h", $time, `GRM.x4terbd_value[i]);
        end

      end // for loop
      
    end
  endtask // update_dxnbdlr9
 

  // Event from system.v that calls local task
  always @(`SYS.e_update_with_init_force_pvt) begin
    update_with_init_force_pvt;
  end

  always @ (`SYS.e_check_calibrated_values) begin
    check_calibrated_values(`TRUE);
  end


  // set step size
  // -------------
  // sets the DDL step size other than the default
  task set_ddl_step_size;
    input [31:0] step_size; // in ps
    begin
      ddl_step_size = step_size/1000.0;
      -> e_set_ddl_step_size;
    end
  endtask // set_ddl_step_size
  
`ifndef GATE_LEVEL_SIM
`ifndef DWC_DDRPHY_EMUL    
  generate
`ifdef DWC_DDRPHY_X4X2  
    // all x4x2, x8only and x4 mode
    for (dwc_byte=0;dwc_byte<`DWC_NO_OF_BYTES*2;dwc_byte=dwc_byte+2) begin: INIT_PVT_2
`else
    // normal x8 mode
    for (dwc_byte=0;dwc_byte<pNUM_LANES;dwc_byte=dwc_byte+pNO_OF_DQS) begin: INIT_PVT_2
`endif
      // bytes LCDLs
      always @(e_set_ddl_step_size) begin
        force `AC_DDR_LCDL_PATH.stepsize = ddl_step_size;
        force `AC_CTL_LCDL_PATH.stepsize = ddl_step_size;
        force `AC_MDL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`CTL_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DDR_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DDR_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`CTL_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DX_MDL_LCDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.`GDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`RDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`RDQSN_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`RDQSGS_LCDL_PATH.stepsize = ddl_step_size;

        force `DXn.`X4CTL_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DDR_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DDR_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4CTL_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.`X4GDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4RDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4RDQSN_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4RDQSGS_LCDL_PATH.stepsize = ddl_step_size;
           
      end

      // bytes BDLs
      always @(e_set_ddl_step_size) begin
        force `DXn.datx8_dq_0.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_1.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_2.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_3.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_4.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_5.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_6.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_7.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DMW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DSW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DSOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DQOE_BDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.datx8_dq_0.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_1.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_2.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_3.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_4.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_5.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_6.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_7.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DMR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DSR_BDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.`DSOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DQOE_BDL_PATH.stepsize = ddl_step_size;

        force `DXn.`X4DSW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DSOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DQOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DSR_BDL_PATH.stepsize = ddl_step_size;

      end
      
      // AC BDLs
      always@(e_set_ddl_step_size) begin
	force `AC.ac_0.bdl.stepsize = ddl_step_size ;
	force `AC.ac_1.bdl.stepsize = ddl_step_size ;
	force `AC.ac_2.bdl.stepsize = ddl_step_size ;
	force `AC.ac_3.bdl.stepsize = ddl_step_size ;
	force `AC.ac_4.bdl.stepsize = ddl_step_size ;
	force `AC.ac_5.bdl.stepsize = ddl_step_size ;
	force `AC.ac_6.bdl.stepsize = ddl_step_size ;
	force `AC.ac_7.bdl.stepsize = ddl_step_size ;
	force `AC.ac_8.bdl.stepsize = ddl_step_size ;
	force `AC.ac_9.bdl.stepsize = ddl_step_size ;
	force `AC.ac_10.bdl.stepsize = ddl_step_size ;
	force `AC.ac_11.bdl.stepsize = ddl_step_size ;
	force `AC.ac_12.bdl.stepsize = ddl_step_size ;
	force `AC.ac_13.bdl.stepsize = ddl_step_size ;
	force `AC.ac_14.bdl.stepsize = ddl_step_size ;
	force `AC.ac_15.bdl.stepsize = ddl_step_size ;
	force `AC.ac_16.bdl.stepsize = ddl_step_size ;
	force `AC.ac_17.bdl.stepsize = ddl_step_size ;
	force `AC.ac_18.bdl.stepsize = ddl_step_size ;
	force `AC.ac_19.bdl.stepsize = ddl_step_size ;
	force `AC.ac_20.bdl.stepsize = ddl_step_size ;
	force `AC.ac_21.bdl.stepsize = ddl_step_size ;
	force `AC.ac_22.bdl.stepsize = ddl_step_size ;
	force `AC.ac_23.bdl.stepsize = ddl_step_size ;
	force `AC.ac_24.bdl.stepsize = ddl_step_size ;
	force `AC.ac_25.bdl.stepsize = ddl_step_size ;
	force `AC.ac_26.bdl.stepsize = ddl_step_size ;
	force `AC.ac_27.bdl.stepsize = ddl_step_size ;
	force `AC.ac_28.bdl.stepsize = ddl_step_size ;
	force `AC.ac_29.bdl.stepsize = ddl_step_size ;
	force `AC.ac_30.bdl.stepsize = ddl_step_size ;
	force `AC.ac_31.bdl.stepsize = ddl_step_size ;
	force `AC.ac_32.bdl.stepsize = ddl_step_size ;
	force `AC.ac_33.bdl.stepsize = ddl_step_size ;
	force `AC.ac_34.bdl.stepsize = ddl_step_size ;
       end      
    end // block: INIT_PVT_2
  endgenerate  
`endif //DWC_DDRPHY_EMUL    

// if GATE, but BUILD or GATE_SIM_EXCEPTION
`elsif DWC_DDRPHY_GATE_SIM_EXCEPT
`ifndef DWC_DDRPHY_EMUL    
  generate
`ifdef DWC_DDRPHY_X4X2  
    // all x4x2, x8only and x4 mode
    for (dwc_byte=0;dwc_byte<`DWC_NO_OF_BYTES*2;dwc_byte=dwc_byte+2) begin: INIT_PVT_2
`else
    // normal x8 mode
    for (dwc_byte=0;dwc_byte<pNUM_LANES;dwc_byte=dwc_byte+pNO_OF_DQS) begin: INIT_PVT_2
`endif
      // bytes LCDLs
      always @(e_set_ddl_step_size) begin
        force `AC_DDR_LCDL_PATH.stepsize = ddl_step_size;
        force `AC_CTL_LCDL_PATH.stepsize = ddl_step_size;
        force `AC_MDL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`CTL_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DDR_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DDR_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`CTL_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DX_MDL_LCDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.`GDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`RDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`RDQSN_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`RDQSGS_LCDL_PATH.stepsize = ddl_step_size;

        force `DXn.`X4CTL_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DDR_WL_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DDR_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4CTL_WDQ_LCDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.`X4GDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4RDQS_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4RDQSN_LCDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4RDQSGS_LCDL_PATH.stepsize = ddl_step_size;
           
      end

      // bytes BDLs
      always @(e_set_ddl_step_size) begin
        force `DXn.datx8_dq_0.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_1.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_2.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_3.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_4.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_5.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_6.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_7.`DQW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DMW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DSW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DSOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DQOE_BDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.datx8_dq_0.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_1.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_2.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_3.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_4.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_5.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_6.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.datx8_dq_7.`DQR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DMR_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DSR_BDL_PATH.stepsize = ddl_step_size;
        
        force `DXn.`DSOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`DQOE_BDL_PATH.stepsize = ddl_step_size;

        force `DXn.`X4DSW_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DSOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DQOE_BDL_PATH.stepsize = ddl_step_size;
        force `DXn.`X4DSR_BDL_PATH.stepsize = ddl_step_size;

      end
      
      // AC BDLs
      always@(e_set_ddl_step_size) begin
	force `AC.ac_0.bdl.stepsize = ddl_step_size ;
	force `AC.ac_1.bdl.stepsize = ddl_step_size ;
	force `AC.ac_2.bdl.stepsize = ddl_step_size ;
	force `AC.ac_3.bdl.stepsize = ddl_step_size ;
	force `AC.ac_4.bdl.stepsize = ddl_step_size ;
	force `AC.ac_5.bdl.stepsize = ddl_step_size ;
	force `AC.ac_6.bdl.stepsize = ddl_step_size ;
	force `AC.ac_7.bdl.stepsize = ddl_step_size ;
	force `AC.ac_8.bdl.stepsize = ddl_step_size ;
	force `AC.ac_9.bdl.stepsize = ddl_step_size ;
	force `AC.ac_10.bdl.stepsize = ddl_step_size ;
	force `AC.ac_11.bdl.stepsize = ddl_step_size ;
	force `AC.ac_12.bdl.stepsize = ddl_step_size ;
	force `AC.ac_13.bdl.stepsize = ddl_step_size ;
	force `AC.ac_14.bdl.stepsize = ddl_step_size ;
	force `AC.ac_15.bdl.stepsize = ddl_step_size ;
	force `AC.ac_16.bdl.stepsize = ddl_step_size ;
	force `AC.ac_17.bdl.stepsize = ddl_step_size ;
	force `AC.ac_18.bdl.stepsize = ddl_step_size ;
	force `AC.ac_19.bdl.stepsize = ddl_step_size ;
	force `AC.ac_20.bdl.stepsize = ddl_step_size ;
	force `AC.ac_21.bdl.stepsize = ddl_step_size ;
	force `AC.ac_22.bdl.stepsize = ddl_step_size ;
	force `AC.ac_23.bdl.stepsize = ddl_step_size ;
	force `AC.ac_24.bdl.stepsize = ddl_step_size ;
	force `AC.ac_25.bdl.stepsize = ddl_step_size ;
	force `AC.ac_26.bdl.stepsize = ddl_step_size ;
	force `AC.ac_27.bdl.stepsize = ddl_step_size ;
	force `AC.ac_28.bdl.stepsize = ddl_step_size ;
	force `AC.ac_29.bdl.stepsize = ddl_step_size ;
	force `AC.ac_30.bdl.stepsize = ddl_step_size ;
	force `AC.ac_31.bdl.stepsize = ddl_step_size ;
	force `AC.ac_32.bdl.stepsize = ddl_step_size ;
	force `AC.ac_33.bdl.stepsize = ddl_step_size ;
	force `AC.ac_34.bdl.stepsize = ddl_step_size ;
       end      
    end // block: INIT_PVT_2
  endgenerate  
`endif //DWC_DDRPHY_EMUL    
  
`endif // `ifndef GATE_LEVEL_SIM

  task log_pvtscale_info();
    integer i;
  begin
`ifdef DWC_DDRPHY_X4X2
    // all x4x2, x8only and x4 mode
    for (i=0;i<`DWC_NO_OF_BYTES*2;i=i+2) begin
`else
    // normal x8 mode
    for(i=0; i<pNUM_LANES; i=i+1) begin
`endif
      $display("-> %0t [PHYSYS] ---------- Log pvtscale[i] arrays ---------", $time);
      $display("-> %0t [PHYSYS] pvtscale_ac_mdl = %0f", $time, pvtscale_ac_mdl);
      $display("-> %0t [PHYSYS] pvtscale_ctl_wl[%0d] = %0f", $time, i, pvtscale_ctl_wl[i]);
      $display("-> %0t [PHYSYS] pvtscale_ddr_wl[%0d] = %0f", $time, i, pvtscale_ddr_wl[i]);
      $display("-> %0t [PHYSYS] pvtscale_ddr_wdq[%0d] = %0f", $time, i, pvtscale_ddr_wdq[i]);
`ifdef DWC_DDRPHY_X4X2
      $display("-> %0t [PHYSYS] pvtscale_dx_mdl[%0d] = %0f", $time, i/2, pvtscale_dx_mdl[i/2]);
`else
      $display("-> %0t [PHYSYS] pvtscale_dx_mdl[%0d] = %0f", $time, i, pvtscale_dx_mdl[i/pNO_OF_DQS]);
`endif
      $display("-> %0t [PHYSYS] pvtscale_gdqs[%0d] = %0f", $time, i, pvtscale_gdqs[i]);
      $display("-> %0t [PHYSYS] pvtscale_rdqs[%0d] = %0f", $time, i, pvtscale_rdqs[i]);
      $display("-> %0t [PHYSYS] pvtscale_rdqsn[%0d] = %0f", $time, i, pvtscale_rdqsn[i]);
      $display("-> %0t [PHYSYS] pvtscale_rdqsgs[%0d] = %0f", $time, i, pvtscale_rdqsgs[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq0_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq0_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq1_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq1_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq2_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq2_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq3_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq3_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq4_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq4_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq5_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq5_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq6_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq6_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_wdq7_bdl[%0d] = %0f", $time, i, pvtscale_dx_wdq7_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq0_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq0_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq1_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq1_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq2_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq2_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq3_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq3_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq4_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq4_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq5_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq5_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq6_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq6_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_rdq7_bdl[%0d] = %0f", $time, i, pvtscale_dx_rdq7_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_pdd_bdl[%0d] = %0f", $time, i, pvtscale_dx_pdd_bdl[i]);
      $display("-> %0t [PHYSYS] pvtscale_dx_pdr_bdl[%0d] = %0f", $time, i, pvtscale_dx_pdr_bdl[i]);
      $display("");
      $display("-> %0t [PHYSYS] ---------- Log tmp_pvtscale[i] arrays ---------", $time);
      $display("-> %0t [PHYSYS] tmp_pvtscale_ac_mdl = %0f", $time, tmp_pvtscale_ac_mdl);
      $display("-> %0t [PHYSYS] tmp_pvtscale_ctl_wl[%0d] = %0f", $time, i, tmp_pvtscale_ctl_wl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_ddr_wl[%0d] = %0f", $time, i, tmp_pvtscale_ddr_wl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_ddr_wdq[%0d] = %0f", $time, i, tmp_pvtscale_ddr_wdq[i]);
`ifdef DWC_DDRPHY_X4X2
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_mdl[%0d] = %0f", $time, i/2, tmp_pvtscale_dx_mdl[i/2]);
`else
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_mdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_mdl[i/pNO_OF_DQS]);
`endif
      $display("-> %0t [PHYSYS] tmp_pvtscale_gdqs[%0d] = %0f", $time, i, tmp_pvtscale_gdqs[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_rdqs[%0d] = %0f", $time, i, tmp_pvtscale_rdqs[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_rdqsn[%0d] = %0f", $time, i, tmp_pvtscale_rdqsn[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_rdqsgs[%0d] = %0f", $time, i, tmp_pvtscale_rdqsgs[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq0_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq0_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq1_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq1_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq2_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq2_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq3_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq3_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq4_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq4_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq5_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq5_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq6_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq6_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq7_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_wdq7_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq0_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq0_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq1_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq1_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq2_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq2_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq3_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq3_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq4_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq4_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq5_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq5_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq6_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq6_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq7_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_rdq7_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_pdd_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_pdd_bdl[i]);
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_pdr_bdl[%0d] = %0f", $time, i, tmp_pvtscale_dx_pdr_bdl[i]);
      $display("");
      $display("-> %0t [PHYSYS] ---------- Log tmp_pvtscale[i] * pvt_multiplier arrays ---------", $time);
      $display("-> %0t [PHYSYS] tmp_pvtscale_ac_mdl * pvt_multiplier = %0f", $time, (tmp_pvtscale_ac_mdl*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_ctl_wl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_ctl_wl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_ddr_wl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_ddr_wl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_ddr_wdq[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_ddr_wdq[i]*pvt_multiplier));
`ifdef DWC_DDRPHY_X4X2
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_mdl[%0d] * pvt_multiplier = %0f", $time, i/2, (tmp_pvtscale_dx_mdl[i/2]*pvt_multiplier));
`else
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_mdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_mdl[i/pNO_OF_DQS]*pvt_multiplier));
`endif
      $display("-> %0t [PHYSYS] tmp_pvtscale_gdqs[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_gdqs[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_rdqs[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_rdqs[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_rdqsn[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_rdqsn[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_rdqsgs[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_rdqsgs[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq0_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq0_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq1_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq1_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq2_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq2_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq3_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq3_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq4_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq4_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq5_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq5_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq6_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq6_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_wdq7_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_wdq7_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq0_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq0_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq1_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq1_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq2_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq2_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq3_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq3_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq4_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq4_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq5_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq5_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq6_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq6_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_rdq7_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_rdq7_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_pdd_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_pdd_bdl[i]*pvt_multiplier));
      $display("-> %0t [PHYSYS] tmp_pvtscale_dx_pdr_bdl[%0d] * pvt_multiplier = %0f", $time, i, (tmp_pvtscale_dx_pdr_bdl[i]*pvt_multiplier));
      $display("");
    end
  end
  endtask // log_pvtscale_info

endmodule // phy_system
