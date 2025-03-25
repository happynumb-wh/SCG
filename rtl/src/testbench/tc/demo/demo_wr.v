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
// SDRAM Write and Read Demo (demo_wr.v)
//-----------------------------------------------------------------------------
// This testcase demonstrates DDR SDRAM write and read accesses (including
// write/read with auto-precharge). A few locations are written to with 
// predefined data and then the same locations are read. The testcase also
// demonstrates triggering of PHY initialization, SDRAM initialization and all 
// PHY training routines.

`timescale 1ns/1fs

`default_nettype none  // turn off implicit data types

module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//
  
  // Access parameters
  localparam pNO_OF_ACCESSES  = 3
  ,          pINIT_ADDR       = 0
  ;

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

  integer                     i, j;
  integer                     bank_no;
  integer                     b2b_accesses;

  reg [4             - 1 : 0] num_rd_rpt;
  reg [4             - 1 : 0] num_refreshes;
  reg [`REG_DATA_WIDTH-1 : 0] tmp;
  reg                         use_mpr;
  reg                         upd_dtcr;

  //--------------------------------------------------------------------------//
  //   T e s t b e n c h    I n s t a n t i a t i o n
  //--------------------------------------------------------------------------//
  ddr_tb ddr_tb();

  //--------------------------------------------------------------------------//
  //   T e s t    S t i m u l u s
  //--------------------------------------------------------------------------//

  initial begin
       // Workaround race condition with initial block from system.v
      #2;

`ifndef NO_DLSTEP_OVERRIDE
      // for speed less than 800Mbps, change the DDL step size from the default of 10ps to 20ps
      if (`CLK_PRD >= 2.5)  `PHYSYS.set_ddl_step_size(20);
`endif
    
      //------------------------------------------------------------------------
      // Initialization

      `SYS.disable_signal_probing = 1;
      // Turn off some memory checks since we'l be moving the DQS and DQs
      `SYS.disable_dq_setup_hold_checks;

      // this testcase will set its own training
      `SYS.rdimm_auto_train_en    = 1'b0;

      `SYS.phy_power_up;

      // Setup PUB Initialization Register (PIR)
      `SYS.dram_init_type = `PUB_DRAM_INIT;  // We'll use the built-in routine 
      `SYS.skip_phy_power_up = 1'b1;  // since the phy was initialized in phy_power_up skip it for the power_up task

      // if loop back in place, do the training later
`ifndef DWC_LOOP_BACK

    `GRM.pir[0] = 1'b1;    // Trigger initialization

  `ifndef DWC_DDRPHY_EMUL_XILINX

    `ifdef LPDDR3
      `ifndef DWC_NO_CA_TRAIN
        `ifdef DWC_AC_CS_USE
          `GRM.pir[2] = 1'b1;    // Do CA Training (LPDDR3)
        `endif
      `endif
    `endif    
    `ifdef DDR3
    `GRM.pir[9] = 1'b1;    // Do write-leveling (DDR3)
    `elsif DDR4
      `GRM.pir[9] = 1'b1;    // Do write-leveling (DDR4)
    `elsif LPDDR3
      `GRM.pir[9] = 1'b1;    // Do write-leveling (LPDDR3)
    `else
    `GRM.pir[9] = 1'b0;
    `endif    

    `ifndef LPDDRX
    `GRM.pir[10] = 1'b1;   // Read DQS gate training for non LPDDR mode
    `else
      `ifdef LPDDR3
    // random case for gate training.
    `SYS.lpddr3_term_type = {$random(`SYS.seed)} % 3;
    
    case(`SYS.lpddr3_term_type)
      2: // VDD term wihtout PU/PD
        begin
          `SYS.lpddr3_term_type = `LPDDR3_TERM;
          `GRM.pir[10] = 1'b1;   // Perform Read DQS gate training for LPDDR3 mode
          $display("-> %0t: [BENCH]  gate training for LPDDR3 TERM type without PU/PD ", $time);
        end
      default: begin
        `GRM.pir[10] = 1'b1;   // Read DQS gate training for LPDDR3 mode; default to NO TERM type
        `SYS.lpddr3_term_type = `LPDDR3_NO_TERM;
      end
      
    endcase // case(lpddr3_term_type)

      `else
    // Do not turn on gate train for LPDDR2 mode...  
      `endif
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

    `GRM.pir[12] = 1'b1;   // Read data bit deskew
    `GRM.pir[13] = 1'b1;   // Write data bit deskew
    `GRM.pir[14] = 1'b1;   // Read data eye training
    `GRM.pir[15] = 1'b1;   // Write data eye training


    `ifdef DDR4
      `ifndef DWC_NO_VREF_TRAIN    
    `GRM.pir[17] = 1'b1;   // VREF training
      `endif
    `endif
    // for DDR4/3, pick WL, DQS gating train using MPR, and Wl adjustment
    `ifdef DDR4
    use_mpr = 1'b1;
    `else
      `ifdef DDR3
    use_mpr = 1'b1;
      `else
        `ifdef LPDDR3
    use_mpr = 1'b1; // In LPDDR3 use the MRR pattern A (from register address 32)
        `else
    use_mpr = 1'b0; // DDR2 doesn't have MPR
        `endif
      `endif
    `endif  

    // configure DQS gate training
    if (`GRM.dtcr0[6] != use_mpr) begin
      `GRM.dtcr0[6] = use_mpr;
      upd_dtcr = 1;
    end
    
    // Enables refreshes by default through setting refresh repeat value
    if (`GRM.dtcr0[31:28] == 0) begin
      `GRM.dtcr0[31:28] = 1;  // Ensure it's never 0 to avoid tRFC timing violations
      upd_dtcr = 1;
    end
    

    `ifdef DWC_BUBBLES
    // When jitter is enabled, multiple reads are required for stable results
    if (`GRM.dtcr0[3:0] < 6) begin  // Pick 6 reads - this should work in all cases...
      `GRM.dtcr0[3:0] = 6;
      upd_dtcr = 1;
    end
    `endif

    // Write out the DTCR0 register, iff it has been updated
    if (upd_dtcr) begin
      `CFG.write_register(`DTCR0, `GRM.dtcr0);
    end

    if (use_mpr && `GRM.lpddrx_mode) begin
      $display("-> %0t: [BENCH] disable read-leveling as gate training can only run with gate extended only ", $time);
      `GRM.dtcr1[1] = 1'b0;
      `CFG.write_register(`DTCR1, `GRM.dtcr1);
    end  
  `endif //DWC_DDRPHY_EMUL_XILINX
`endif //  `ifndef DWC_LOOP_BACK
    
    
`ifdef DWC_DDRPHY_EMUL_XILINX
  `ifdef RDIMM_DUAL_RANK
    `SYS.add_2ck_wl_sys_lat_emul;
  `endif
  `ifdef RDIMM_QUAD_RANK
    `SYS.add_2ck_wl_sys_lat_emul;
  `endif
`endif
    
    
      `SYS.power_up;

      // Wait a bit before starting operations
      `SYS.nops(50);

      // check to make sure no training error is captured
      `CFG.disable_read_compare;
      `CFG.read_register_data(`PGSR0, tmp);
      if (|(tmp[28:21])) begin
        `SYS.error;
        $display("-> %0t: ERROR: Expecting no training error but PGSR0[28:21] = %b", $time, tmp[28:21]);
      end
`ifdef LPDDR3
      if (tmp[30]) begin
        `SYS.error;
        $display("-> %0t: ERROR: Expecting no training error but PGSR0[30] = %b", $time, tmp[30]);
      end
`endif
      repeat (2) @(posedge `CFG.clk);      
      `CFG.enable_read_compare;

      //------------------------------------------------------------------------
      // Write/read transactions
      rank = 2'b00;
      rank1 = 1% `DWC_NO_OF_RANKS;
      
      addr = pINIT_ADDR;
      $display("\n=> Normal read/write accesses ...\n");
      for (bank_no=0; bank_no<2; bank_no=bank_no+1) begin
        bank = bank_no;
        
        // perform write
        init_waddr = addr;
        for (i=0; i<pNO_OF_ACCESSES; i=i+1) begin
          {row, col} = addr;
          row = i % 2;
          //          row = 0;
          `HOST.write({rank, bank, row, col});
          addr = addr + 16;
        end
        
        // perform read
        addr = init_waddr;
        for (i=0; i<pNO_OF_ACCESSES; i=i+1) begin
          {row, col} = addr;
          row = i % 2;
          //          row = 0;
          `HOST.read({rank, bank, row, col});
          addr = addr + 16;
        end
      end

      row = 0;
      col = 0;
      row_inc = {`DDR_COL_WIDTH{1'b1}} + 1;
`ifdef DDR2
      init_bank = 3; // 3 to 6
`else
      init_bank = 0; // 0 to 3 (only 4 banks for DDR)
`endif

      for (i=0; i<4; i=i+1) begin
        bank = init_bank + i;
        addr = {rank, bank, row, col};
        `HOST.write(addr);
      end
      addr1 = {rank1, bank, row, col};

      `HOST.write(addr1);
      `HOST.nops(20);
      `HOST.read(addr);
      `HOST.read(addr1);
      
      
      `HOST.nops(200);
      `HOST.read(addr);
      `HOST.sdram_nops(3);
      `HOST.read(addr);
      `HOST.sdram_nops(16);

      // back-to-back writes
      `HOST.write(addr);
      `HOST.write(addr+16);
      `HOST.write(addr+32);
      `HOST.sdram_nops(3);
      `HOST.write(addr+48);
      `HOST.sdram_nop;
      `HOST.write(addr+64);
      `HOST.nop;
      `HOST.write(addr+16);

      // back-to-back reads
      `HOST.read(addr);
      `HOST.read(addr+16);
      `HOST.read(addr+32);
      `HOST.sdram_nops(3);
      `HOST.read(addr+48);
      `HOST.sdram_nop;
      `HOST.read(addr+64);
      `HOST.nop;
      `HOST.read(addr+16);
      `HOST.sdram_nops(3);

      // read followed by a write
      `HOST.read(addr+48);
      `HOST.write(addr);
      `HOST.sdram_nops(3);

      // write followed by a read
      `HOST.write(addr+16);
      `HOST.read(addr+48);
      `HOST.sdram_nops(20);

      // back-to-back reads to different ranks but same bank
      `HOST.read(addr);
      `HOST.read(addr1);
      `HOST.read(addr);
      `HOST.read(addr1);

      // execute a string of back-to-back writes/reads, with the last access
      // being a write/read with auto-precharge
      `HOST.nops(50);
      $display("\n=> Read/write with auto-precharge ...\n");
      addr = pINIT_ADDR;
      for (j=0; j<5; j=j+1) begin
        case (j)
          0: b2b_accesses = 1;
          default: b2b_accesses = 1 + {$random(`SYS.seed)} % 6;
        endcase // case(j)
        
        // back-to-back writes
        init_waddr = addr;
        for (i=0; i<b2b_accesses; i=i+1) begin
          `HOST.write(addr);
          addr = addr + 16;
        end
        `HOST.write_precharge(addr);
        
        // back-to-back reads
        addr = init_waddr;
        for (i=0; i<b2b_accesses; i=i+1) begin
          `HOST.read(addr);
          addr = addr + 16;
        end
        `HOST.read_precharge(addr);
      end
      `END_SIMULATION;
      
    end // initial begin
  
endmodule // tc

`default_nettype wire  // restore implicit data types
