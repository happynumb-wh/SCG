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
// DCU SDRAM Write and Read Demo (demo_dcu_wr.v)
//-----------------------------------------------------------------------------
// This testcase demonstrates DDR SDRAM write and read accesses when issued
// through the PUB DRAM Command Unit (DCU). The testcase also demonstrates 
// triggering of DQS gate training before starting DCU operations.

`timescale 1ns/1fs

`default_nettype none  // turn off implicit data types

module tc();

  //--------------------------------------------------------------------------//
  //   L o c a l    P a r a m e t e r s
  //--------------------------------------------------------------------------//

  localparam pNO_OF_ACCESSES  = 1
  ,          pINIT_RANK       = 0
  ,          pINIT_BANK       = 0
  ,          pINIT_ROW        = 0
  ,          pINIT_COL        = 0
  ;
  //DCU caches depth default values: CCACHE_DEPTH = 16, ECACHE_DEPTH = 1, RCACHE_DEPTH = 4
  localparam pNO_OF_DATA     = 8
  ;
`ifdef BL_4
  `ifdef LPDDRX
    localparam pWR_RPT         = `DCU_tBL // computed by PUB to create full DDR burst 
    ,          pRD_RPT         = 8        // no special BL8 timing by PUB in LPDDR mode
  `else
    localparam pWR_RPT         = `DCU_tBL // computed by PUB to create full DDR burst 
    ,          pRD_RPT         = 16       // this will allow read of 8 times 
  `endif
`else  
  localparam pWR_RPT         = 0
  ,          pRD_RPT         = 2
`endif
  ;
  
  localparam pDCU_ALL_RANKS  = 1'b1
  ,          pDCU_NOTAG      = 1'b0  ;

  //--------------------------------------------------------------------------//
  //   R e g i s t e r    a n d    W i r e    D e c l a r a t i o n s
  //--------------------------------------------------------------------------//

  reg [`DCU_DATA_WIDTH   - 1 : 0] data;
  reg [`PUB_DQS_WIDTH    - 1 : 0] mask;
  reg [`DWC_ADDR_WIDTH   - 1 : 0] addr;
  reg [`DWC_BANK_WIDTH   - 1 : 0] bank;
  reg [`SDRAM_RANK_WIDTH - 1 : 0] rank;
  reg [`CMD_WIDTH        - 1 : 0] cmd;

  reg [`DCU_DATA_WIDTH   - 1 : 0] no_data;
  reg [`PUB_DQS_WIDTH    - 1 : 0] no_mask;
  reg [`DCU_DATA_WIDTH   - 1 : 0] data_entry [`CCACHE_DEPTH - 1 : 0];
  reg [8                 - 1 : 0] data_byte;
  reg [8                 - 1 : 0] data_beats [`CCACHE_DEPTH - 1 : 0]  // Number of writes
                                             [`DWC_NO_OF_BYTES  - 1 : 0]  // Number of byte-lanes
                                             [4                 - 1 : 0]; // 4 beats per word
  reg [`DCU_DATA_WIDTH    -1  :0] pub_data [0:pNO_OF_DATA-1];

  reg [`SDRAM_ROW_WIDTH  - 1 : 0] row;
  reg [`SDRAM_COL_WIDTH  - 1 : 0] col;

  reg [`CACHE_LOOP_WIDTH - 1 : 0] loop_cnt;
  integer                         idx;
  integer                         bl;
  integer                         beat_idx;
  integer                         num_rd_rpt;
  integer                         num_refreshes;
  integer                         loop_start_addr;
  integer                         loop_end_addr;
  integer                         loop_infinite;
  integer                         dcu_inc_dram_addr;
  integer                         last_xptd_data_addr;
  integer                         i;
  reg [`ECACHE_DATA_WIDTH -1 : 0] encoded_ec_word;
  integer                         base;
  reg [15:0]                      udp_dq_odd;
  reg [15:0]                      udp_dq_even;
  reg [`REG_DATA_WIDTH-1 : 0]     tmp;
  reg                             use_mpr;
  reg                             upd_dtcr;
  reg                             dcu_eo_cmd;
  
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

      // Initialization
      `SYS.disable_signal_probing = 1;

      //Disabling refresh checks since dcu does not support automatic rereshes. tRFC_max errors were present and no need to check them
      `SYS.disable_refresh_check;

      // Turn off some memory checks since we'l be moving the DQS and DQs
      `SYS.disable_dq_setup_hold_checks;

      // this testcase will set its own training
      `SYS.rdimm_auto_train_en    = 1'b0;

      `SYS.phy_power_up;

      // Setup PUB Initialization Register (PIR)
      `SYS.dram_init_type = `PUB_DRAM_INIT;  // We'll use the built-in routine 
      `SYS.skip_phy_power_up = 1'b1;  // since the phy was initialized in phy_power_up skip it for the power_up task
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
`elsif LPDDR3
      `GRM.pir[10] = 1'b1;   // Read DQS gate training for LPDDR3
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

      // Write out the DTCR register, iff it has been updated
      if (upd_dtcr) begin
        `CFG.write_register(`DTCR0, `GRM.dtcr0);
      end

      if (use_mpr && `GRM.lpddrx_mode) begin
        $display("-> %0t: [BENCH] disable read-leveling as gate training can only run with gate extended only ", $time);
        `GRM.dtcr1[1] = 1'b0;
        `CFG.write_register(`DTCR1, `GRM.dtcr1);
      end  
`endif //DWC_DDRPHY_EMUL_XILINX
    
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
      // Program DCU with simple write/read transactions

      rank    = pINIT_RANK;
      bank    = pINIT_BANK;
      row     = pINIT_ROW;
      col     = pINIT_COL;
      mask    = {`PUB_DQS_WIDTH{`DDR_MASK_OFF}};
      no_mask = {`PUB_DQS_WIDTH{`DDR_MASK_OFF}};

      data    = `PUB_DATA_0000_0000;
      no_data = `PUB_DATA_0000_0000;
      encoded_ec_word = {`ECACHE_DATA_WIDTH{1'b0}};

      `SYS.random_bistlsr;
      base = 0;
      udp_dq_odd  = `SYS.random_16b(0);
      udp_dq_even = `SYS.random_16b(0);
      `SYS.set_bistudpr(udp_dq_even, udp_dq_odd); // User Data pattern 

      for (i=0; i<pNO_OF_DATA; i=i+1) begin
        //pub_data[i] = i;
`ifdef DWC_DDRPHY_EMUL_XILINX
        pub_data[i] = {$random(`SYS.seed)}%25; // random our of 16 pattern
`else
        pub_data[i] = {$random(`SYS.seed)}%24; // random our of 16 pattern
`endif
      end
      
      if(`GRM.lpddrx_mode)begin
        dcu_eo_cmd  = 0; // even command only for LPDDRx
      end else begin
           if (`DWC_2T_MODE) 
             dcu_eo_cmd  = 0; // even command only for 2T mode
           else
             dcu_eo_cmd  = {$random(`SYS.seed)}%2; // random the even/odd dcu command for DDR3/4
      end
      

      // Populate data array
      for (idx = 0; idx < pNO_OF_DATA; idx = idx + 1) begin
        for (bl = 0; bl < `DWC_NO_OF_BYTES; bl = bl + 1) begin
          data_byte = idx;
          // For the MSBYTE, check if there is any unused bits;
          // if so, set 0 for those unused data bits
          if (bl == `DWC_NO_OF_BYTES-1 && `DWC_MSBYTE_NUDQ != 0) begin
            data_beats[idx][bl][3] = {(8'ha0+data_byte) + bl} & {8'b1111_1111 >> `DWC_MSBYTE_NUDQ};;  // beat 3;
            data_beats[idx][bl][2] = {(8'h80+data_byte) + bl} & {8'b1111_1111 >> `DWC_MSBYTE_NUDQ};;  // beat 2;
            data_beats[idx][bl][1] = {(8'h40+data_byte) + bl} & {8'b1111_1111 >> `DWC_MSBYTE_NUDQ};;  // beat 1;
            data_beats[idx][bl][0] = {(8'h00+data_byte) + bl} & {8'b1111_1111 >> `DWC_MSBYTE_NUDQ};;  // beat 0;
          end
          else begin 
            data_beats[idx][bl][3] = (8'ha0+data_byte) + bl;  // beat 3;
            data_beats[idx][bl][2] = (8'h80+data_byte) + bl;  // beat 2;
            data_beats[idx][bl][1] = (8'h40+data_byte) + bl;  // beat 1;
            data_beats[idx][bl][0] = (8'h00+data_byte) + bl;  // beat 0;
          end
        end
      end
 
      // Load the DCUTPR register to have a parameter for repeat of 12/24 (for BL16)
      `CFG.write_register(`DCUTPR, pRD_RPT - 1);

      $display("-> %0t: [BENCH] Setting up the command cache", $time);
      // Setup for loading DCU caches (with auto address increment)
      `CFG.set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);

      $display("-> %0t: [BENCH] Start calling load_dcu_command() to load in writes/reads", $time);
      // Load the following instructions in the DCU
      // 1. Activate
      // 2. Write(s)
      // 3. Read(s)
      `CFG.load_dcu_command(`DCU_NORPT, `DTP_tRPA    , {dcu_eo_cmd , pDCU_ALL_RANKS} , `PRECHARGE,  rank, bank, col, no_mask, no_data);
      `CFG.load_dcu_command(`DCU_NORPT, `DTP_tACT2RW , {dcu_eo_cmd , pDCU_NOTAG}     , `ACTIVATE,   rank, bank, row, no_mask, no_data);
      load_dcu_wr(pNO_OF_DATA);
`ifdef BL_4
      `CFG.load_dcu_command(`DCU_tDCUT0, `DTP_tRD2PRE , {dcu_eo_cmd , pDCU_NOTAG}     , `SDRAM_READ, rank, bank, col, no_mask, no_data);
`else
      `CFG.load_dcu_command(`DCU_RPT7X, `DTP_tRD2PRE , {dcu_eo_cmd , pDCU_NOTAG}     , `SDRAM_READ, rank, bank, col, no_mask, no_data);
`endif
      `CFG.load_dcu_command(`DCU_NORPT, `DTP_tRPA    , {dcu_eo_cmd , pDCU_ALL_RANKS} , `PRECHARGE,  rank, bank, col, no_mask, no_data);

    
      //------------------------------------------------------------------------
      // Configure DCU run

      loop_start_addr        = 1; // don't include the activate command as part of the loop
      loop_end_addr          = 13; //  CCACHE_DEPTH = 16
      loop_cnt               = 0; // don't loop - we just want a few writes + reads
      loop_infinite          = 0; // terminate run once program ends
      dcu_inc_dram_addr      = 1; // increment write/read address
      last_xptd_data_addr    = pNO_OF_DATA-1%`ECACHE_DEPTH;
      `CFG.set_dcu_looping(loop_start_addr, 
                           loop_end_addr, 
                           loop_cnt, 
                           loop_infinite, 
                           dcu_inc_dram_addr, 
                           last_xptd_data_addr
                          );

      //------------------------------------------------------------------------
      // Load expected data to match write data

      for (idx = 0; idx < pNO_OF_DATA; idx = idx + 1) begin
        encoded_ec_word[idx*`PUB_DATA_TYPE_WIDTH +: `PUB_DATA_TYPE_WIDTH] = pub_data[idx];
      end   
      
      `CFG.load_encoded_expected_data(encoded_ec_word);

      //------------------------------------------------------------------------
      // Turn off controller-initiated refreshes.
      `GRM.drr[31] = 1'b0;
      `GRM.write_controller_register(`DRR,`GRM.drr);

      // Wait a bit before triggering the DCU
      `SYS.nops(50);

`ifndef DWC_LOOP_BACK
      // Issue HOST BFM refresh, then wait for tRFC(min) before staring DCU
      `HOST.refresh();
      repeat (`tRFC_min) @(posedge `RANK0.ck);
`endif
     
      //------------------------------------------------------------------------
      // Run DCU - commands starting at address 0 to end loaded address

      `CFG.dcu_run_special(0, ((pNO_OF_DATA + 4) - 1), 0, 0, 0, 1, 1);

      `CFG.polling_dcusr0_rdone;


      `END_SIMULATION;
      
  end // initial begin

  //--------------------------------------------------------------------------//
  //                                T A S K S
  //--------------------------------------------------------------------------//

  //----------------------------------------------------------------------------
  // Task to load DCU command cache with a few write instructions
  task load_dcu_wr;
    input integer num_entries;

      integer                       idx;
      integer                       byte_pos;

    begin
      for (idx = 0; idx < num_entries; idx = idx + 1) begin
        byte_pos = 0;
        for (beat_idx = 0; beat_idx < 4; beat_idx = beat_idx + 1) begin
          for (bl = 0; bl < `DWC_NO_OF_BYTES; bl = bl + 1) begin
            data_entry[idx][byte_pos +: 8] = data_beats[idx][bl][beat_idx];
            byte_pos = byte_pos + 8;
          end
        end
        $display("-> %0t: [BENCH] call load_dcu_command()", $time);

        `CFG.load_dcu_command(pWR_RPT, `DTP_tWR2RD, {dcu_eo_cmd , pDCU_NOTAG}, `SDRAM_WRITE, rank, bank, col, no_mask, pub_data[idx]);
      end 
    end
  endtask

endmodule // tc

`default_nettype wire  // restore implicit data types
