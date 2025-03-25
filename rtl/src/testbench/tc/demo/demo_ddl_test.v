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
// Digital Delay Line Oscillator Test Mode Demo (demo_ddl_test.v)
//-----------------------------------------------------------------------------
// This testcase demonstrates a methodology for testing the digital delay lines.
// The delays lines are put into oscillator test mode and the delays values (tap
// selects) for the fine delay element are swept through the entire range.  This
// is repeated for the coarse delay element.  The delay value code (DLTCODE) is
// read after each change in tap select.  
// Delay line testing is demonstrated for an LCDL and a BDL.  For further 
// discussion of this methodology see the "Design For Test" section of the PHY 
// Databook.

`timescale 1ns/1fs

`default_nettype none  // turn off implicit data types

module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//
  
  localparam pCOARSE_LCDL_DELAY_WIDTH   = 5
  ,          pFINE_LCDL_DELAY_WIDTH     = 4
  ,          pCOARSE_BDL_DELAY_WIDTH    = 2
  ,          pFINE_BDL_DELAY_WIDTH      = 4
  ;

  // AC
`ifdef DWC_DDRPHY_ACX48
  localparam pNO_OF_DDL_BDL_AC   = 53; //41+12
`else
  localparam pNO_OF_DDL_BDL_AC   = 41;
`endif
  localparam pNO_OF_DDL_LCDL_AC  = 3;
  localparam pNO_OF_DDL_NDL_AC   = 2;
  // DATX8
`ifdef DWC_DDRPHY_X4X2
  localparam pNO_OF_DDL_BDL_DX   = 34; // 25+9;
  localparam pNO_OF_DDL_LCDL_DX  = 17; // 9+8
  localparam pNO_OF_DDL_NDL_DX   = 16; // 12+4
`else
  localparam pNO_OF_DDL_BDL_DX   = 25;
  localparam pNO_OF_DDL_LCDL_DX  = 9;
  localparam pNO_OF_DDL_NDL_DX   = 12;
`endif
    
  localparam pREF_PRD            = `CLK_NX * `CLK_PRD; // reference clock

`ifdef SDF_ANNOTATE
  `ifdef FAST_SDF
  localparam pDDL_STEP_SIZE      = 0.106;  // both bdl and lcdl
  localparam pINIT_DLY_BDL       = 0.159;  // default (overhead)delays in BDL
  localparam pINIT_DLY_LCDL      = 0.137;  //                "            LCDL
  `else
    `ifdef TYPICAL_SDF
  localparam pDDL_STEP_SIZE      = 0.161;  // both bdl and lcdl
  localparam pINIT_DLY_BDL       = 0.239;  // default (overhead)delays in BDL
  localparam pINIT_DLY_LCDL      = 0.204;  //                "            LCDL
    `else
  localparam pDDL_STEP_SIZE      = 0.261;  // both bdl and lcdl
  localparam pINIT_DLY_BDL       = 0.380;  // default (overhead)delays in BDL
  localparam pINIT_DLY_LCDL      = 0.323;  //                "            LCDL
    `endif
  `endif
`else  
  //localparam pDDL_STEP_SIZE      = 0.010;  // both bdl and lcdl
  localparam pDDL_STEP_SIZE      = 0.005;  // both bdl and lcdl
  localparam pINIT_DLY_BDL       = 0.200;  // default (overhead)delays in BDL
  localparam pINIT_DLY_LCDL      = 0.200;  //                "            LCDL
`endif

  localparam pAC                 = 0;
  localparam pDX                 = 1;
  localparam pMNT_CLKS           = 55; // monitor over 55 clocks
  localparam pARRAY_SIZE         = 5*pMNT_CLKS; // chosen larger of two

  localparam tERR                = 0.0001;
  localparam pNO_OF_LRANKS       = `DWC_NO_OF_LRANKS ;
  //--------------------------------------------------------------------------//
  //   R e g i s t e r    a n d    W i r e    D e c l a r a t i o n s
  //--------------------------------------------------------------------------//

  integer                      datx8_idx;
  integer                      ddl_reg_addr;
  integer                      coarse_delay;
  integer                      fine_delay;
  integer                      step_size;
  integer                      pgsr1_dltcode;
  reg     [32         - 1 : 0] reg_read_data;

  integer                      test_pin_no;
  integer                      tap_sel;
  integer                      mnt_clks;
  reg                          mnt_en;
  reg [128*8:0] message;     
     
  wire                         ac_dl_dto;  
  reg [0:pARRAY_SIZE-1]        ac_dl_dto_data;
  reg [31:0]                   ac_dl_dto_time [0:pARRAY_SIZE-1];
  integer                      ac_dl_dto_changes;
     
  wire                         dx_dl_dto;  
  reg [0:pARRAY_SIZE-1]        dx_dl_dto_data;
  reg [31:0]                   dx_dl_dto_time [0:pARRAY_SIZE-1];
  integer                      dx_dl_dto_changes;
  integer                      byte_no;
  reg [`REG_ADDR_WIDTH:0]      reg_addr;

  real                         ddl_step_size;
  reg                          dfiout_rnd_en;
  wire                         pub_mode_exit_sdr;  
  event                        e_err_xpctd_HI, e_err_xpctd_LO;
  event                        e_force_dq;
  
  integer                      rank_idx, chip_idx, dqs_per_sdram_idx, dq_sdram_idx;
  
  //--------------------------------------------------------------------------//
  //   T e s t b e n c h    I n s t a n t i a t i o n
  //--------------------------------------------------------------------------//
  ddr_tb ddr_tb();

  //--------------------------------------------------------------------------//
  //   T e s t    S t i m u l u s
  //--------------------------------------------------------------------------//

  initial begin

      // Workaround race condition with initial block from system.v
      #0;

      
      // test output monitoring is off
      mnt_en = 1'b0;

      // Randomize DFI signals at start-up
      dfiout_rnd_en   = 0;
      `DFI.randomize_dfi_outputs;
      dfiout_rnd_en   = 1;      
      
      // this testcase will set its own training
      `SYS.rdimm_auto_train_en    = 1'b0;

      // Initialization
      `SYS.phy_power_up;

      // Delay line test mode will toggle outputs to the SDRAM because of the
      // BDL are connected in oscillator mode; disconnect the SDRAMs
      `SYS.disable_all_mpr_monitors;      
 
      // Disable the DDR monitors
      `SYS.disable_all_rank_monitors;
      `SYS.disable_all_odt_monitors;
      `SYS.disable_all_rdimm_monitors;
      `SYS.disable_all_mpr_monitors;

      // don't compare reads on host interface
      `HOST.read_cnt_en = 1'b0;

      
      `SYS.disconnect_all_sdrams; 


      //------------------------------------------------------------------------
      // disable dm only for dmmux option
      //------------------------------------------------------------------------
`ifdef DWC_DDRPHY_DMDQS_MUX
  `ifndef DWC_DDRPHY_EMUL_XILINX

    `ifdef BIDIRECTIONAL_SDRAM_DELAYS
      for(rank_idx=0;rank_idx<pNO_OF_LRANKS;rank_idx=rank_idx+1) begin
    `else 
      begin //without BiDir SDRAM delays, only rank 0 delays will be used
        rank_idx=0;
    `endif
        for(chip_idx=0;chip_idx<(`DWC_NO_OF_BYTES*8/`SDRAM_DATA_WIDTH); chip_idx=chip_idx+1) begin
            if (`SYS.verbose > 9) $display ("-> %0t: [BENCH] chip_idx = %0d", $time, chip_idx);
            if (`SYS.verbose > 9) $display ("-> %0t: [BENCH] rank_idx  = %0d", $time, rank_idx );

`ifdef SDRAMx4            
          for(dqs_per_sdram_idx=0;dqs_per_sdram_idx<1; dqs_per_sdram_idx=dqs_per_sdram_idx+1) begin
`else
          for(dqs_per_sdram_idx=0;dqs_per_sdram_idx<(`SDRAM_DATA_WIDTH/8); dqs_per_sdram_idx=dqs_per_sdram_idx+1) begin
`endif
            if (`SYS.verbose > 9) $display ("-> %0t: [BENCH] dqs_per_sdram_idx = %0d", $time, dqs_per_sdram_idx);
            `TB.u_ddr_board_cfg.config_delay("dqs" ,0, rank_idx, chip_idx, dqs_per_sdram_idx, 0);
            `TB.u_ddr_board_cfg.config_delay("dqsn",0, rank_idx, chip_idx, dqs_per_sdram_idx, 0);
            `TB.u_ddr_board_cfg.config_delay("dm"  ,0, rank_idx, chip_idx, dqs_per_sdram_idx, 0);
          end
          
          for(dq_sdram_idx=0;dq_sdram_idx<`SDRAM_DATA_WIDTH;dq_sdram_idx=dq_sdram_idx+1) begin
            if (`SYS.verbose > 9) $display ("-> %0t: [BENCH] dq_sdram_idx = %0d", $time, dq_sdram_idx);
            `TB.u_ddr_board_cfg.config_delay("dq",0, rank_idx, chip_idx, dq_sdram_idx, 0);
          end

        end
      end

        -> e_force_dq;
  `endif    
`endif
        
      #10;
      //------------------------------------------------------------------------
      // Setup PUB + PHY for DDL test
      `SYS.ddl_test_setup_pub_phy;

      //------------------------------------------------------------------------
      // Wait minimum of 100ns
      #100;
    
      //------------------------------------------------------------------------
      // Set delay line step size
     
       ddl_step_size = pDDL_STEP_SIZE; // default 5 ps
`ifdef SDF_ANNOTATE
      ddl_step_size = pDDL_STEP_SIZE;
`else
      ddl_step_size = `PHYSYS.ddl_step_size;
`endif
    
    //------------------------------------------------------------------------
      // Set all DDL delay code to minimum values (0x0)

      // Set all shadow registers to the value we're about to write
      // ACDMDLR
      `GRM.acmdlr0[31:0] = 0;
      `GRM.acmdlr1[31:0] = 0;
      // ACLCDLR
      `GRM.aclcdlr[31:0]  = 0;
      // ACBDLR    
      `GRM.acbdlr0[31:0]  = 0;
      `GRM.acbdlr1[31:0]  = 0;
      `GRM.acbdlr2[31:0]  = 0;
      `GRM.acbdlr3[31:0]  = 0;
      `GRM.acbdlr4[31:0]  = 0;
      `GRM.acbdlr5[31:0]  = 0;
      `GRM.acbdlr6[31:0]  = 0;
      `GRM.acbdlr7[31:0]  = 0;
      `GRM.acbdlr8[31:0]  = 0;
      `GRM.acbdlr9[31:0]  = 0;
      `GRM.acbdlr10[31:0] = 0;      

      for (datx8_idx = 0; datx8_idx < `DWC_NO_OF_BYTES; datx8_idx = datx8_idx + 1) begin
        // DXnMDLR
        `GRM.dxnmdlr0 [datx8_idx][31:0] = 0; 
        `GRM.dxnmdlr1 [datx8_idx][31:0] = 0; 
        // DXnLCDLR
        `GRM.dxnlcdlr0[0][datx8_idx][31:0] = 0; 
        `GRM.dxnlcdlr1[0][datx8_idx][31:0] = 0; 
        `GRM.dxnlcdlr2[0][datx8_idx][31:0] = 0; 
        `GRM.dxnlcdlr3[0][datx8_idx][31:0] = 0; 
        `GRM.dxnlcdlr4[0][datx8_idx][31:0] = 0; 
        `GRM.dxnlcdlr5[0][datx8_idx][31:0] = 0; 
        // DXnBDLR
        `GRM.dxnbdlr0 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr1 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr2 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr3 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr4 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr5 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr6 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr7 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr8 [datx8_idx][31:0] = 0; 
        `GRM.dxnbdlr9 [datx8_idx][31:0] = 0; 
      end

      // Write all the registers with the shadow register values
      // ACMDLR
      `CFG.write_register(`ACMDLR0, `GRM.acmdlr0);
      `CFG.write_register(`ACMDLR1, `GRM.acmdlr1);
      // ACLCDLR    
      `CFG.write_register(`ACLCDLR, `GRM.aclcdlr);
      // ACBDLR
      `CFG.write_register(`ACBDLR0,  `GRM.acbdlr0);
      `CFG.write_register(`ACBDLR1,  `GRM.acbdlr1);
      `CFG.write_register(`ACBDLR2,  `GRM.acbdlr2);
      `CFG.write_register(`ACBDLR3,  `GRM.acbdlr3);
      `CFG.write_register(`ACBDLR4,  `GRM.acbdlr4);
      `CFG.write_register(`ACBDLR5,  `GRM.acbdlr5);
      `CFG.write_register(`ACBDLR6,  `GRM.acbdlr6);
      `CFG.write_register(`ACBDLR7,  `GRM.acbdlr7);
      `CFG.write_register(`ACBDLR8,  `GRM.acbdlr8);
      `CFG.write_register(`ACBDLR9,  `GRM.acbdlr9);
      `CFG.write_register(`ACBDLR10, `GRM.acbdlr10);      
      // Registers for each byte-lane are offset by 0x20
      for (datx8_idx = 0; datx8_idx < `DWC_NO_OF_BYTES; datx8_idx = datx8_idx + 1) begin
        // DXnMDLR
        `CFG.write_register((`DX0MDLR0   + (datx8_idx * 'h40)), `GRM.dxnmdlr0 [datx8_idx]);
        `CFG.write_register((`DX0MDLR1   + (datx8_idx * 'h40)), `GRM.dxnmdlr1 [datx8_idx]);
        // DXnLCDLR                      
        `CFG.write_register((`DX0LCDLR0  + (datx8_idx * 'h40)), `GRM.dxnlcdlr0[0][datx8_idx]);
        `CFG.write_register((`DX0LCDLR1  + (datx8_idx * 'h40)), `GRM.dxnlcdlr1[0][datx8_idx]);
        `CFG.write_register((`DX0LCDLR2  + (datx8_idx * 'h40)), `GRM.dxnlcdlr2[0][datx8_idx]);
        `CFG.write_register((`DX0LCDLR3  + (datx8_idx * 'h40)), `GRM.dxnlcdlr3[0][datx8_idx]);
        `CFG.write_register((`DX0LCDLR4  + (datx8_idx * 'h40)), `GRM.dxnlcdlr4[0][datx8_idx]);
        `CFG.write_register((`DX0LCDLR5  + (datx8_idx * 'h40)), `GRM.dxnlcdlr5[0][datx8_idx]);
        // DXnBDLR       
        `CFG.write_register((`DX0BDLR0   + (datx8_idx * 'h40)), `GRM.dxnbdlr0[datx8_idx]);
        `CFG.write_register((`DX0BDLR1   + (datx8_idx * 'h40)), `GRM.dxnbdlr1[datx8_idx]);
        `CFG.write_register((`DX0BDLR2   + (datx8_idx * 'h40)), `GRM.dxnbdlr2[datx8_idx]);
        `CFG.write_register((`DX0BDLR3   + (datx8_idx * 'h40)), `GRM.dxnbdlr3[datx8_idx]);
        `CFG.write_register((`DX0BDLR4   + (datx8_idx * 'h40)), `GRM.dxnbdlr4[datx8_idx]);
        `CFG.write_register((`DX0BDLR5   + (datx8_idx * 'h40)), `GRM.dxnbdlr5[datx8_idx]);
        `CFG.write_register((`DX0BDLR6   + (datx8_idx * 'h40)), `GRM.dxnbdlr6[datx8_idx]);
        `CFG.write_register((`DX0BDLR7   + (datx8_idx * 'h40)), `GRM.dxnbdlr7[datx8_idx]);
        `CFG.write_register((`DX0BDLR8   + (datx8_idx * 'h40)), `GRM.dxnbdlr8[datx8_idx]);
        `CFG.write_register((`DX0BDLR9   + (datx8_idx * 'h40)), `GRM.dxnbdlr9[datx8_idx]);
      end

      //------------------------------------------------------------------------
      // Choose one DDL: we'll use DX0LCDLR3.RDQSD as an example

      ddl_reg_addr     = `DX0LCDLR3;
      fine_delay       = 0;
      coarse_delay     = 0;
      datx8_idx        = 0;
      // To speed up simulations we won't test every single tap-select of DDLs
      step_size        = 2;

      `SYS.disconnect_all_sdrams; 
      `TB.ck_disc = 1;

      //------------------------------------------------------------------------
      // Loop through all the DDL's fine delay tap selects, from the smallest
      // delay value through to the largest value

      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] Starting fine delay sweep of DX0LCDLR3 at address 0x%0h ----------------------", $time, ddl_reg_addr);
      $display("-> %0t: [BENCH] ", $time);

      for (fine_delay = 0; fine_delay <= {pFINE_LCDL_DELAY_WIDTH{1'b1}}; fine_delay = fine_delay + step_size) begin

        $display("-> %0t: [BENCH] Set fine delay %0d", $time, fine_delay);

        //----------------------------------------------------------------------
        // Increase fine delay by 1 step

        `GRM.dxnlcdlr3[0][datx8_idx][3:0]  = fine_delay;
        `GRM.dxnlcdlr3[0][datx8_idx][8:4] = coarse_delay;
        `CFG.write_register((`DX0LCDLR3 + (datx8_idx * 'h40)), `GRM.dxnlcdlr3[0][datx8_idx]);
        `SYS.nops(10);

        run_ddl_test;

        $display("-> %0t: [BENCH] ", $time);

      end

      //----------------------------------------------------------------------
      // Set fine delay to minimum at the end of fine-delay testing

      fine_delay       = 0;
      coarse_delay     = 0;
      `GRM.dxnlcdlr3[0][datx8_idx][3:0]  = fine_delay;
      `GRM.dxnlcdlr3[0][datx8_idx][8:4] = coarse_delay;
      `CFG.write_register((`DX0LCDLR3 + (datx8_idx * 'h40)), `GRM.dxnlcdlr3[0][datx8_idx]);
      `SYS.nops(10);

      //------------------------------------------------------------------------
      // Loop through all the DDL's coarse delay tap selects, from the smallest
      // delay value through to the largest value

      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] Starting coarse delay sweep of DX0LCDLR3 at address 0x%0h ----------------------", $time, ddl_reg_addr);
      $display("-> %0t: [BENCH] ", $time);
      // To speed up simulations we won't test every single tap-select of DDLs
      step_size        = 3;

      for (coarse_delay = 0; coarse_delay <= {pCOARSE_LCDL_DELAY_WIDTH{1'b1}}; coarse_delay = coarse_delay + step_size) begin

        $display("-> %0t: [BENCH] Set coarse_delay %0d", $time, coarse_delay);

        //----------------------------------------------------------------------
        // Increase fine delay by 1 step

        `GRM.dxnlcdlr3[0][datx8_idx][3:0]  = fine_delay;
        `GRM.dxnlcdlr3[0][datx8_idx][8:4] = coarse_delay;
        `CFG.write_register((`DX0LCDLR3 + (datx8_idx * 'h40)), `GRM.dxnlcdlr3[0][datx8_idx]);
        `SYS.nops(10);

        run_ddl_test;

        $display("-> %0t: [BENCH] ", $time);

      end

      //----------------------------------------------------------------------
      // Set DDL back to minimum value

      $display("-> %0t: [BENCH] Set DDL to minimum value at end of test", $time);
      fine_delay       = 0;
      coarse_delay     = 0;
      `GRM.dxnlcdlr3[0][datx8_idx][3:0]  = fine_delay;
      `GRM.dxnlcdlr3[0][datx8_idx][8:4] = coarse_delay;
      `CFG.write_register((`DX0LCDLR3 + (datx8_idx * 'h40)), `GRM.dxnlcdlr3[0][datx8_idx]);



      //------------------------------------------------------------------------
      // Choose one BDL: we'll use DX0BDLR0.DQ0WBD as an example

      ddl_reg_addr     = `DX0BDLR0;
      fine_delay       = 0;
      coarse_delay     = 0;
      datx8_idx        = 0;
      // To speed up simulations we won't test every single tap-select of DDLs
      step_size        = 2;

      //------------------------------------------------------------------------
      // Loop through all the DDL's fine delay tap selects, from the smallest
      // delay value through to the largest value

      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] Starting fine delay sweep of DX0BDLR0 at address 0x%0h ----------------------", $time, ddl_reg_addr);
      $display("-> %0t: [BENCH] ", $time);

      for (fine_delay = 0; fine_delay <= {pFINE_BDL_DELAY_WIDTH{1'b1}}; fine_delay = fine_delay + step_size) begin

        $display("-> %0t: [BENCH] Set fine delay %0d", $time, fine_delay);

        //----------------------------------------------------------------------
        // Increase fine delay by 1 step

        `GRM.dxnbdlr0[datx8_idx][3:0] = fine_delay;
        `GRM.dxnbdlr0[datx8_idx][5:4] = coarse_delay;
        `CFG.write_register((`DX0BDLR0 + (datx8_idx * 'h40)), `GRM.dxnbdlr0[datx8_idx]);
        `SYS.nops(10);

        run_ddl_test;

        $display("-> %0t: [BENCH] ", $time);

      end

      //----------------------------------------------------------------------
      // Set fine delay to minimum at the end of fine-delay testing

      fine_delay       = 0;
      coarse_delay     = 0;
      `GRM.dxnbdlr0[datx8_idx][3:0] = fine_delay;
      `GRM.dxnbdlr0[datx8_idx][5:4] = coarse_delay;
      `CFG.write_register((`DX0BDLR0 + (datx8_idx * 'h40)), `GRM.dxnbdlr0[datx8_idx]);
      `SYS.nops(10);


      //------------------------------------------------------------------------
      // Loop through all the DDL's coarse delay tap selects, from the smallest
      // delay value through to the largest value

      $display("-> %0t: [BENCH] ", $time);
      $display("-> %0t: [BENCH] Starting coarse delay sweep of DX0BDLR0 at address 0x%0h ----------------------", $time, ddl_reg_addr);
      $display("-> %0t: [BENCH] ", $time);

      for (coarse_delay = 0; coarse_delay <= {pCOARSE_BDL_DELAY_WIDTH{1'b1}}; coarse_delay = coarse_delay + step_size) begin

        $display("-> %0t: [BENCH] Set coarse_delay %0d", $time, coarse_delay);

        //----------------------------------------------------------------------
        // Increase fine delay by 1 step

        `GRM.dxnbdlr0[datx8_idx][3:0] = fine_delay;
        `GRM.dxnbdlr0[datx8_idx][5:4] = coarse_delay;
        `CFG.write_register((`DX0BDLR0 + (datx8_idx * 'h40)), `GRM.dxnbdlr0[datx8_idx]);
        `SYS.nops(10);

        run_ddl_test;

        $display("-> %0t: [BENCH] ", $time);

      end

      //----------------------------------------------------------------------
      // Set DDL back to minimum value

      $display("-> %0t: [BENCH] Set DDL to minimum value at end of test", $time);
      fine_delay       = 0;
      coarse_delay     = 0;
      `GRM.dxnbdlr0[datx8_idx][3:0] = fine_delay;
      `GRM.dxnbdlr0[datx8_idx][5:4] = coarse_delay;
      `CFG.write_register((`DX0BDLR0 + (datx8_idx * 'h40)), `GRM.dxnbdlr0[datx8_idx]);


      `END_SIMULATION;

  end
  
  // Whenever we're in pub_mode, drive the DFI to random
  always @(posedge `PUB.pub_mode) begin
    if (dfiout_rnd_en) begin
      @(negedge `PUB.ctl_clk);
      `DFI.randomize_dfi_outputs;
    end
  end

  // As soon as we exit pub_mode or pub_init mode, drive DFI to something reasonable
  `ifdef DWC_DDRPHY_HDR_MODE
  always @(negedge `PUB.u_DWC_ddrphy_scheduler.pub_mode or
           negedge `PUB.u_DWC_ddrphy_scheduler.pub_init) begin
    if (dfiout_rnd_en) begin
      @(negedge `PUB.ctl_clk);
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

  task run_ddl_test;

      reg  [3 : 0] oscdiv;

    begin
      
      `SYS.disconnect_all_sdrams; 

      // To speed up the simulation limit the divide down ratio to 1 - in a
      // realistic test, this would be high, e.g. divide by 64k
      oscdiv = 4'b000;

      //----------------------------------------------------------------------
      // Direct the DDL digital test output to the PHY top-level dto pin
      
      `GRM.pgcr0[18:14] = 5'b10000 + datx8_idx;
      `CFG.write_register(`PGCR0, `GRM.pgcr0);
      
      //----------------------------------------------------------------------
      // Set OSCWDL and OSCWDDL
      
      $display("-> %0t: [BENCH] Set OSCWDL and OSCWDDL to 2'b01", $time);
      `GRM.pgcr0[20:19] = 2'b01;
      `GRM.pgcr0[23:22] = 2'b01;
      `CFG.write_register(`PGCR0, `GRM.pgcr0);      

      //----------------------------------------------------------------------
      // Enable oscillations
      
      $display("-> %0t: [BENCH] Enable oscillations", $time);
      `GRM.pgcr0    [8] = 1'b1;
      `GRM.pgcr0[12: 9] = oscdiv;
      `GRM.pgcr0[13] = 1'b0;
      `CFG.write_register(`PGCR0, `GRM.pgcr0);

      //----------------------------------------------------------------------
      // Trigger test measurements
      
      $display("-> %0t: [BENCH] Trigger test measurements", $time);
      `GRM.pgcr0[7] = 1'b1;
      `CFG.write_register(`PGCR0, `GRM.pgcr0);
      // Allow some time for the test to complete
      `SYS.nops(20);

      // Monitor test outputs
      monitor_test_outputs;

      // Poll for test complete status of the internal period measurement
      `CFG.poll_register(`PGSR1, 0, 0, 1'b1, 100, 1000, "PGSR1.DLTDONE asserted...");

      //----------------------------------------------------------------------
      // Disable oscillations and measurements

      $display("-> %0t: [BENCH] Disable oscillations and measurements", $time);
      `GRM.pgcr0[7] = 1'b0;
      `GRM.pgcr0[8] = 1'b0;
      `CFG.write_register(`PGCR0, `GRM.pgcr0);

      //----------------------------------------------------------------------
      // Read Delay Line Test Code (DLTCODE) and verify outputs
      for (test_pin_no=0; test_pin_no<2; test_pin_no=test_pin_no+1) begin
        if (test_pin_no==0) message = "AC";
        else                message = "DATX8";
        verify_test_output;
      end

    end

  endtask


  // ddl monitor
  // -----------
  // monitors the status of the dll test outputs
  task monitor_test_outputs;
    begin
      ac_dl_dto_changes = 0;
      dx_dl_dto_changes = 0;
      `CFG.nops(5);
      
      mnt_clks = pMNT_CLKS;
      // enable monitor
      @(posedge `AC_TOP.ctl_clk); // This was AC.ctl_clk
      mnt_en = 1'b1;
      repeat (mnt_clks) @(posedge `AC_TOP.ctl_clk); //This was AC.ctl_clk
      mnt_en = 1'b0;
    end
  endtask // monitor_test_outputs

  // probe AC/DATX8 DDL test outputs
  assign ac_dl_dto = `AC.dl_dto;
  assign dx_dl_dto = `DX0.dl_dto;

  // delay line test outputs 
  always @(ac_dl_dto) begin
    if (mnt_en === 1'b1) begin
      ac_dl_dto_data[ac_dl_dto_changes] = ac_dl_dto;
      ac_dl_dto_time[ac_dl_dto_changes] = 1000*($realtime); // ps
      ac_dl_dto_changes = ac_dl_dto_changes + 1;
    end
  end

  always @(dx_dl_dto) begin
    if (mnt_en === 1'b1) begin
      dx_dl_dto_data[dx_dl_dto_changes] = dx_dl_dto;
      dx_dl_dto_time[dx_dl_dto_changes] = 1000*($realtime); // ps
      dx_dl_dto_changes = dx_dl_dto_changes + 1;
    end
  end

  generate
    genvar dwc_byte;
    genvar dqs_bits;

      for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS; dwc_byte = dwc_byte + 1) begin
        always @(e_force_dq) begin
            force `DXn_IO.dq             = {8{1'b0}};
            force `DXn_top.dq            = {8{1'b0}};
        end
    end
  endgenerate
 
  // verify monitor outputs
  // ----------------------
  // verifies that the changes on the DDL test outputs are correct
  task verify_test_output;
    reg [8*15-1:0] test_pin;
    reg            test_out;
    reg            test_data;
    integer        changes;
    integer        xpctd_changes;
    integer        j;
    real           xpctd_pw; // expected pulse width
    real           xpctd_prd;
    real           xpctd_tHI;
    real           xpctd_tLO;
    real           test_time;
    real           prev_test_time;
    real           pulse_width;
    real           tHI;
    real           tLO;
    integer        xpctd_dltcode;
    reg            dltdone;
    integer        dltcode;

    begin
      case (test_pin_no)
        pAC: begin
          // ac dl_dto
          tap_sel   = 0; 
          test_pin  = "dl_dto";
          test_out  = ac_dl_dto;
          changes   = ac_dl_dto_changes;
          xpctd_pw  = (pNO_OF_DDL_BDL_AC  * pINIT_DLY_BDL)  +
                      (pNO_OF_DDL_LCDL_AC * pINIT_DLY_LCDL) +
                      (pNO_OF_DDL_NDL_AC  * pINIT_DLY_LCDL);
          xpctd_prd = 2*(xpctd_pw+ddl_step_size*tap_sel);
          xpctd_tHI = xpctd_prd/2.0;
          xpctd_tLO = xpctd_prd/2.0;
          xpctd_changes = pREF_PRD*mnt_clks/xpctd_prd*2.0;
        end

        pDX: begin
  `ifdef DWC_DDRPHY_X8_ONLY
          // in X8-only mode, the LCDL values from one register field are tied to both LCDLs - so a single setting
          // sets two LCDLs
          tap_sel   = (ddl_reg_addr == `DX0LCDLR3) ? 
                      2*(16*coarse_delay + fine_delay) :
                         16*coarse_delay + fine_delay;
  `else
          tap_sel   = 16*coarse_delay + fine_delay;
  `endif
          test_pin  = "dl_dto";
          test_out  = dx_dl_dto;
          changes   = dx_dl_dto_changes;
          xpctd_pw  = (pNO_OF_DDL_BDL_DX  * pINIT_DLY_BDL)  +
                      (pNO_OF_DDL_LCDL_DX * pINIT_DLY_LCDL) +
                      (pNO_OF_DDL_NDL_DX  * pINIT_DLY_LCDL);
          xpctd_prd = 2*(xpctd_pw+ddl_step_size*tap_sel);
          xpctd_tHI = xpctd_prd/2.0;
          xpctd_tLO = xpctd_prd/2.0;
          xpctd_changes = pREF_PRD*mnt_clks/xpctd_prd*2.0;
        end  
      endcase // case(test_pin_no)
      
/* -----\/----- EXCLUDED -----\/-----
      if (test_pin_no==pDX) begin
        $display("\nDEBUG pNO_OF_DDL_BDL_DX=%0d",pNO_OF_DDL_BDL_DX);
        $display("DEBUG pINIT_DLY_BDL=%0f",pINIT_DLY_BDL);
        $display("DEBUG pNO_OF_DDL_LCDL_DX=%0d",pNO_OF_DDL_LCDL_DX);
        $display("DEBUG pINIT_DLY_LCDL=%0f",pINIT_DLY_LCDL);
        $display("DEBUG pNO_OF_DDL_NDL_DX=%0d",pNO_OF_DDL_NDL_DX);
        $display("DEBUG xpctd_pw=%0f",xpctd_pw);
        $display("DEBUG coarse_delay=%0f,fine_delay=%0f",coarse_delay,fine_delay);
        $display("DEBUG ddl_step_size=%0f,tap_sel=%0d",ddl_step_size,tap_sel);
        $display("DEBUG xpctd_prd=%0f",xpctd_prd);
        $display("DEBUG xpctd_tHI=%0f,xpctd_tLO=%0f\n",xpctd_tHI, xpctd_tLO);
      end
 -----/\----- EXCLUDED -----/\----- */
          
      // sdr mode
      if (`GRM.hdr_mode==1'b0 && (`TCLK_PRD >= `CLK_PRD))
        xpctd_changes = xpctd_changes * 2.0;

      // verify changes on delay line test output
      $write("\n-> %0t: Verifying test pin %0s ", $realtime, test_pin);
      if (test_pin_no==pDX) $write("on Byte Lane 0 ");
      else $write("on AC ");
      $write("...\n\n");
      if (changes == 0 && xpctd_changes != 0) begin
        `SYS.log_error;
        $display("    *** ERROR: No change on test output");
      end else if (changes == 0) begin
        $display("    - No change on test output (output = %b)", test_out);
      end else begin
        // print and verify changes
        for (j=0; j<changes; j=j+1) begin
          case (test_pin_no)
            pAC:  begin
              test_data = ac_dl_dto_data[j];
              test_time = ac_dl_dto_time[j]/1000.0;
            end
            pDX:  begin
              test_data = dx_dl_dto_data[j];
              test_time = dx_dl_dto_time[j]/1000.0;
            end
          endcase 
          
          $display("    - %0s changed to %b at %0t", test_pin, test_data,
                   test_time);
          // check correct signal by pulse widths
          if (j != 0) begin
            pulse_width = test_time - prev_test_time;
            if (test_data === 1'b0) tHI = pulse_width;
            if (test_data === 1'b1) tLO = pulse_width;
            
            if ((test_data === 1'b0) &&
                ((pulse_width < (xpctd_tHI - tERR)) || 
                 (pulse_width > (xpctd_tHI + tERR)))) begin
              `SYS.log_error;
              $write("    *** ERROR: Wrong high time (%0t);",
                     pulse_width);
              $display(" expected %0t", xpctd_tHI);
              ->e_err_xpctd_HI;
              
            end
            
            if ((test_data === 1'b1) &&
                ((pulse_width < (xpctd_tLO - tERR)) ||
                 (pulse_width>(xpctd_tLO + tERR)))) begin
              `SYS.log_error;
              $write("    *** ERROR: Wrong low time (%0t);",
                     pulse_width);
              $display(" expected %0t", xpctd_tLO);
              ->e_err_xpctd_LO;
            end
          end
          prev_test_time = test_time;
        end // for (j=0; j<changes; j=j+1)
        
        // check if enough signal changes
        if ((changes > 0) && 
            ((changes < (xpctd_changes - 2)) ||
             (changes > (xpctd_changes + 2)))) begin
            `SYS.log_error;
          $write("    *** ERROR: Test output changed ");
          $display("%0d times; expected %0d", changes, xpctd_changes);
        end else begin
          $display("\n    - Test output changed %0d times", changes);
        end
        
        $display("    - Test output high pulse width = %0t", tHI);
        $display("    - Test output low pulse width  = %0t\n", tLO);
        
        // also verify that the period measurement is done correctly
        $display("\n-> %0t: Verifying test output automatic period mesurement ... ", 
                 $realtime);
        xpctd_dltcode = xpctd_prd / (2*`CLK_PRD);
        `CFG.disable_read_compare;
        @(posedge `CFG.clk);
        fork
          begin
            if (test_pin_no == pAC)
              `CFG.read_register(`PGSR1);
            else
              `CFG.read_register(`DX0GSR1);
          end
        
          begin
`ifdef DWC_DDRPHY_JTAG
      if (`SYS.jtag_en) begin 
            @(posedge `CFG.jtag_qvld);
            $display(" %0t getting cfg.jtag_qvld... check q", $time);
            @(negedge `CFG.clk);
            dltdone = `CFG.jtag_q[0];
            dltcode = `CFG.jtag_q[24:1];
        end
      else begin
           @(posedge `CFG.qvld);
            $display(" %0t getting cfg.qvld... check q", $time);
            @(negedge `CFG.clk);
            dltdone = `CFG.q[0];
            dltcode = `CFG.q[24:1];
        end
`else           
            @(posedge `CFG.qvld);
            $display(" %0t getting cfg.qvld... check q", $time);
            @(negedge `CFG.clk);
            dltdone = `CFG.q[0];
            dltcode = `CFG.q[24:1];
`endif
          end
        join
        
        // to complete the period measurement
        if (`CFG_CLK_PRD == 10)
          `CFG.nops(40); 
        else
          `CFG.nops(2);
        `CFG.enable_read_compare;
        
        //Functional Coverage 
        if (dltdone == 1'b0) begin
`ifdef DWC_PLL_BYPASS
          // default run for bypass mode is very slow frequency of configuration clock
          // corresponding to oscillation frequency - therefore measurements may not finish
`else
          `SYS.log_error;
          $display(" %0t   *** ERROR: Period measurement has not finished", $time);
`endif
        end else begin
          if ((dltcode < (xpctd_dltcode - 1)) ||
              (dltcode > (xpctd_dltcode + 1))) begin
            `SYS.log_error;
            $write("    *** ERROR: Wrong period code (DTLCODE) of ");
            $display("%0d; expected %0d", dltcode, xpctd_dltcode);
          end else begin
            $write("\n    - Test output measured period code (DLTCODE)");
            $display(" = %0d (%0t/%0t = %0d+/-1) \n", dltcode, xpctd_prd, 
                     2*`CLK_PRD, xpctd_dltcode);
          end
        end
      end // else: !if(changes == 0)
    end
  endtask // verify_test_output

endmodule // tc

`default_nettype wire  // restore implicit data types

