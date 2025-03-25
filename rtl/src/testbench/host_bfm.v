/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR Host Bus Functional Model                                 *
 *              Model for the interface between DDR host and DDR controller   *
 *              (interface to one host port - instantiate multiple BFMs for   *
 *              multiple ports)                                               *
 *                                                                            *
 *****************************************************************************/

`timescale 1ns/100fs

module host_bfm
 #(
   // configurable design parameters
   parameter pDATA_WIDTH  = `DATA_WIDTH,
   parameter pBYTE_WIDTH  = `BYTE_WIDTH,
   parameter pNUM_BYTES   = `DWC_NO_OF_BYTES,
   parameter pCHANNEL_NO  = 0
  )
   (
   // interface to DDR Controller global signals
   rst_b,             // asynshronous reset
   clk,               // clock

   // interface to DDR controller host port generic interface
   rqvld,             // request valid
   cmd,               // command bus
   a,                 // address
   dm,                // data mask
   d,                 // data input
   cmd_flag,          // command flag
   rdy,               // ready
   qvld,              // read output valid
   q,                 // read data output
   hdr_odd_cmd   
   );
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------


  localparam pHOST_ADDR_RANK_BIT_LO =   `SDRAM_BANK_WIDTH 
                                      + `SDRAM_ROW_WIDTH 
                                      + `SDRAM_COL_WIDTH
  ,          pHOST_ADDR_RANK_BIT_HI =   `SDRAM_RANK_WIDTH 
                                      + pHOST_ADDR_RANK_BIT_LO - 1
  ,          pEDATA_WIDTH           = (pCHANNEL_NO == 0)?     `CH0_EDATA_WIDTH : `CH1_EDATA_WIDTH
  ,          pDWC_EDATA_WIDTH       = (pCHANNEL_NO == 0)? `CH0_DWC_EDATA_WIDTH : `CH1_DWC_EDATA_WIDTH      
  ,          pDWC_DATA_WIDTH        = (pCHANNEL_NO == 0)?      `CH0_DATA_WIDTH : `CH1_DATA_WIDTH
  ,          pRANK_WIDTH            = `SDRAM_RANK_WIDTH // SDRAM rank (CS# + CID) address width   
  ,          pALL_RANK_WIDTH         = 5     // For tasks taking a rank number input that may also include value=16 to support all ranks (`ALL_RANKS).  
  ;
  
  // Tmining Parameters
  // ------------------
  // Interface timing parameters (nanoseconds unless otherwise stated)
  parameter tAS  = 0.0,   // address setup time
            tAH  = 0.2,   // address hold time
            tCMS = 0.0,   // command setup time
            tCMH = 0.2,   // command hold time
            tDIS = 0.0,   // data in setup time
            tDIH = 0.2;   // data in hold time

  // clock low-level width
  parameter tCKL = (1.0 - `CLK_DCYC) * `CLK_PRD * `CLK_NX;

  
  // Default Values
  // --------------
  // Default values driven on certain bus signals when not valid
  parameter pHOST_CH_DQS_WIDTH  = pBYTE_WIDTH*`DWC_DX_NO_OF_DQS;

  parameter DATA_DEFAULT   = {(pDATA_WIDTH/8){8'h4d}},
            ADDR_DEFAULT   = {`HOST_ADDR_WIDTH{1'b0}},
            DM_DEFAULT     = {pHOST_CH_DQS_WIDTH{1'b0}},
            FLAG_DEFAULT   = {`CMD_FLAG_WIDTH{1'b0}};

`ifdef BL_2
  parameter pBURST_DATA_WIDTH = 1 * pDATA_WIDTH;
  parameter pBURST_BYTE_WIDTH = 1 * pBYTE_WIDTH;
`elsif BL_4
  parameter pBURST_DATA_WIDTH = 2 * pDATA_WIDTH;
  parameter pBURST_BYTE_WIDTH = 2 * pBYTE_WIDTH;
`elsif BL_8
  parameter pBURST_DATA_WIDTH = 4 * pDATA_WIDTH;
  parameter pBURST_BYTE_WIDTH = 4 * pBYTE_WIDTH;
`elsif BL_16
  parameter pBURST_DATA_WIDTH = 8 * pDATA_WIDTH;
  parameter pBURST_BYTE_WIDTH = 8 * pBYTE_WIDTH;
`elsif BL_V
  parameter pBURST_DATA_WIDTH = 4 * pDATA_WIDTH;
  parameter pBURST_BYTE_WIDTH = 4 * pBYTE_WIDTH;
`endif
  
  // miscellaneous
  // -------------
  // maximum number of variable-burst-length writes - to be used to store the
  // burst length used for writes so that corresponging reads will use either
  // this burst length or less;
`ifdef MSD_RANDOM_BL
  parameter MAX_RND_BL     = 4000;
`endif

  // address conversion type
  parameter pNO_ADDR_CONV    = 0;
  parameter pONLY_EVEN_RANKS = 1;    

  

  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                            rst_b;       // asynchronous reset
  input                            clk;         // clock

  // interface to DDR controller host port
  output                           rqvld;       // request valid
  output [`CMD_WIDTH-1:0]          cmd;         // command bus
  output [`HOST_ADDR_WIDTH-1:0]    a;           // read/write address
  output [pHOST_CH_DQS_WIDTH-1:0]  dm;          // data mask
  output [pDATA_WIDTH-1:0]         d;           // data input
  output [`CMD_FLAG_WIDTH-1:0]     cmd_flag;    // command flag
  input                            rdy;         // ready
  input                            qvld;        // read output valid
  input  [pDATA_WIDTH-1:0]         q;           // read data output
  output                           hdr_odd_cmd;
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                           rqvld;
  reg [`CMD_WIDTH-1:0]          cmd;
  reg [`HOST_ADDR_WIDTH-1:0]    a;
  reg [pHOST_CH_DQS_WIDTH-1:0]  dm;
  reg [pDATA_WIDTH-1:0]         d;
  reg                           ddr3_bl4;
  reg                           bl4_otf;
  reg                           gp_flag;
  reg [5:0]                     ck_en;
  reg                           rfsh_inh;
  reg                           hdr_odd_cmd;
  
  reg                           rqvld_i;
  reg [`CMD_WIDTH-1:0]          cmd_i;
  reg [`HOST_ADDR_WIDTH-1:0]    a_i;
  reg [pHOST_CH_DQS_WIDTH-1:0]  dm_i;
  reg [pDATA_WIDTH-1:0]         d_i;
  
  reg [pDATA_WIDTH-1:0]         grm_q;
  reg                           grm_ddr3_bl4;
  
  reg                           auto_nops_en;
  integer                       auto_nops;
  reg                           rnd_nops;      initial rnd_nops = 1'b0;  // 0->(nops_range-1) nops per command execute
  integer                       weighted_nops; initial weighted_nops = 9;
  integer                       nops_range;    initial nops_range    = 10;

  integer                       max_rnd_loop;  initial max_rnd_loop = 5;
  integer                       sdram_wgt_nops; initial sdram_wgt_nops       = 9;
  integer                       sdram_nops_range; initial sdram_nops_range   = 10;
  
  reg                           auto_precharge;

  reg [2:0]                     burst_no;
  reg                           temp;
  integer                       count;
  
  // array to contain write data
  reg [pDATA_WIDTH-1:0]         wrdata [0:`MAX_RWDATA_DEPTH-1];
  //reg [`PUB_BYTE_WIDTH-1:0]     wrdata_mask [0:`MAX_RWDATA_DEPTH-1];
  reg [pHOST_CH_DQS_WIDTH-1:0]  wrdata_mask [0:`MAX_RWDATA_DEPTH-1];

  integer                       wrdata_ptr;
  reg [`PAT_WIDTH-1:0]          pattern;

  reg                           burst_size_preset; initial burst_size_preset = 1'b0;
  reg                           cmd_in_progress; initial cmd_in_progress = 1'b0;
  reg                           read_cnt_en; initial read_cnt_en = 1'b1;

`ifdef MSD_RANDOM_BL
  // random burst length info includes the host address and burst length flag
  reg [`HOST_ADDR_WIDTH:0]      rnd_bl_info [0:MAX_RND_BL-1];
  integer                       rnd_bl_no;
`endif

  event                         lb_write;
  reg [`HOST_ADDR_WIDTH-1:0]    lb_addr;
  reg [3:0]                     lb_burst_len; 
  reg                           lb_ddr3_bl4;

  // SRDRESP workaround
  reg issue_srdresp;

  reg [2:0] addr_conv_type;
  
  
  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize
      integer i;
      integer j;
      rqvld       = 1'b0;
      cmd         = `CTRL_NOP;
      a           = ADDR_DEFAULT;
      dm          = DM_DEFAULT;
      d           = DATA_DEFAULT;
      ddr3_bl4    = 1'b0;
      bl4_otf     = 1'b0;
      gp_flag     = 1'b0;
      ck_en       = {3{2'b10}};
      rfsh_inh    = 1'b0;
      count       = 0;
      
      rqvld_i     = 1'b0;
      cmd_i       = `CTRL_NOP;
      a_i         = ADDR_DEFAULT;
      dm_i        = DM_DEFAULT;
      d_i         = DATA_DEFAULT;
  
`ifdef DWC_DDRPHY_HDR_MODE      
  `ifdef  MSD_HDR_ODD_CMD
      // For channel 0, default is using hoc mode
      // For channel 1, default is using hec mode
      if (pCHANNEL_NO == 0)
        hdr_odd_cmd = 1'b1;
      else
        hdr_odd_cmd = 1'b0;
  `else
      // For channel 0, default is using hec mode
      // For channel 1, default is using hoc mode
      if (pCHANNEL_NO == 0)
        hdr_odd_cmd = 1'b0;
      else
        hdr_odd_cmd = 1'b1;
  `endif
`else
      hdr_odd_cmd = 1'b0;
`endif              
      
      auto_nops_en   = 1'b0;

`ifdef MSD_REPLACE_AUTOPRE
      auto_precharge = 1'b1;
`else
      auto_precharge = 1'b0;
`endif

`ifdef MSD_RANDOM_BL
      rnd_bl_no = 0;
`endif

`ifdef RDIMM_SINGLE_RANK
      addr_conv_type = pONLY_EVEN_RANKS;
`else
      addr_conv_type = pNO_ADDR_CONV;
`endif
      
      #0.0;
      wrdata_ptr = 0;
      wrdata[0] = 288'h159D048C258BE147AD0369CF013579BDF2468ACE6789F5E4D3C2B1A0FEDCBA9876543210;
      wrdata[1] = 288'hCC996633009977553311FFDDBB8866442200EECCAAFFEEDDCCBBAA998877665544332211;
      wrdata[2] = 288'h353513130000FFFFEEEEDDDDCCCCBBBBAAAA999988887777666655554444333322221111;
      wrdata[3] = 288'h7979575711110000FFFFEEEEDDDDCCCCBBBBAAAA99998888777766665555444433332222;
      wrdata[4] = 288'hBDBD9B9B222211110000FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666555544443333;
      wrdata[5] = 288'hF2F2DFDF3333222211110000FFFFEEEEDDDDCCCCBBBBAAAA999988887777666655554444;
      wrdata[6] = 288'h2424F2F244443333222211110000FFFFEEEEDDDDCCCCBBBBAAAA99998888777766665555;
      wrdata[7] = 288'h46462424555544443333222211110000FFFFEEEEDDDDCCCCBBBBAAAA9999888877776666;

      for (i=0; i<8; i=i+1) wrdata_mask[i] = 0;

      for (i=4; i<`MAX_RWDATA_DEPTH; i=i+1)
        begin
          wrdata[i] = {{$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random},
                       {$random}, {$random}};
          wrdata_mask[i] = 0;
        end

        // SRDRESP workaround - set flag to issue static read response change
        issue_srdresp = 1'b1;
    end

  // command flag includes on-the-fly burst length of 4 and AC loopback enable
  assign cmd_flag = {rfsh_inh, ck_en, gp_flag, ddr3_bl4};

  
  //---------------------------------------------------------------------------
  // DDR SDRAM Access Commands
  //---------------------------------------------------------------------------
  // commands to access the DDR SDRAMs
  
  // write
  // -----
  // writes to a selected DDR SDRAM address (data comes from the array)
  task write;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    
    reg [pDATA_WIDTH-1:0]        data;
    reg [pHOST_CH_DQS_WIDTH-1:0] mask;
    reg [`CMD_WIDTH-1:0]         op;
    reg [3:0]                    burst_len;
    reg [pRANK_WIDTH-1:0]    rank;
    reg [`SDRAM_BANK_WIDTH-1:0]  bank;
    reg [`SDRAM_ROW_WIDTH-1:0]   row;
    reg [`SDRAM_COL_WIDTH-1:0]   col;   
    
    integer i;

    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

      // check if the bytes needs to be re-trained
      if (`SYS.need_data_train) begin
        $display("-> %0t: [HOST %0d] call system.data_train_and_check_status before write request", $time, pCHANNEL_NO);
        `SYS.data_train_and_check_status;
      end

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write(addr);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      
      if (burst_size_preset == 1'b0) 
        begin
`ifdef MSD_RANDOM_BL
          // randomly set burst length on-the-fly (only for DDR3) and save
          // the random burst lenght information
          if ({$random} % 2)
            begin
              bl4_otf = (`SYS.initializing_sdram_array) ? 1'b0 : 1'b1;
            end

          save_random_burst_length(addr, bl4_otf);
`endif
        end
      burst_len = (bl4_otf) ? 2/`CLK_NX : `GRM.ctrl_burst_len;

      
`ifdef RND_SDRAM_NOP_BEFORE_WR
      insert_rnd_sdram_nop;
`endif   

`ifdef MSD_RND_HDR_ODD_CMD
      hdr_odd_cmd = {$random} % 2;
`endif

`ifndef DWC_USE_SHARED_AC_TB
      // Issue 2T cmd on even slot (first half started on ODD slot).
      if (`DWC_2T_MODE == 1)
        hdr_odd_cmd = 1'b0;
`endif

      ddr3_bl4 = `GRM.ddr3_bl4fxd | bl4_otf;
      
      for (i=0; i<burst_len; i=i+1)
        begin
          burst_no = i;
          
          data = wrdata[wrdata_ptr];
          mask = wrdata_mask[wrdata_ptr];
          
          d_i  = data;
          dm_i = mask;
          a_i  = addr;
          op   = (auto_precharge) ? `WRITE_PRECHG : `SDRAM_WRITE;

          {rank, bank, row, col} = addr;  
          //Functional coverage
          `FCOV.set_cov_address_param(rank, bank, row, col);   

          // execute command on the host port
          execute_command(op);
          
          // also execute command in GRM
          // but not if comparison with GRM is enabled in the host monitor
          if (`HOST_MNT.grm_cmp_en == 1'b0)
            begin
              `GRM.write(addr, mask, data, i);

              if (`GRM.lb_mode && i == 0)
                begin
                  // a write in loopback also results in read data - execute an
                  // equivalent read in GRM
                  -> lb_write;
                  lb_addr      = addr;
                  lb_burst_len = burst_len;
                  lb_ddr3_bl4  = ddr3_bl4;
                end
            end
          wrdata_ptr = (wrdata_ptr == (`MAX_RWDATA_DEPTH-1)) ?
                       0 : wrdata_ptr + 1;
        end

`ifdef MSD_RANDOM_BL
      bl4_otf  = 1'b0;
`endif
      ddr3_bl4 = 1'b0;

`ifdef MSD_RND_HDR_ODD_CMD
      // For channel 0, default is using hec mode
      // For channel 1, default is using hoc mode
      if (pCHANNEL_NO == 0)
        hdr_odd_cmd = 1'b0;
      else
        hdr_odd_cmd = 1'b1;
`endif
`ifdef DWC_USE_SHARED_AC_TB        
        end
      end // else: !if(addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)
`endif      

    end
  endtask // write


  
  // writes to a selected DDR SDRAM address (data is passed but not masked)
  task write_data;
    input [`HOST_ADDR_WIDTH-1:0]  addr;    
    input [pBURST_DATA_WIDTH-1:0] wrdata;
    reg [pRANK_WIDTH-1:0]   rank;
    reg [`SDRAM_BANK_WIDTH-1:0] bank;
    reg [`SDRAM_ROW_WIDTH-1:0]  row;
    reg [`SDRAM_COL_WIDTH-1:0]  col;
    
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_data(addr, wrdata);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
          write_masked_data(addr, wrdata, {pBURST_BYTE_WIDTH{1'b0}});
          if (`SYS.load_mode_pda_en == 1'b0) begin
            {rank, bank, row, col} = addr;  
            // Functional coverage     
            `FCOV.set_cov_address_param(rank, bank, row, col); 
          end
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_data
  
  // writes to a selected DDR SDRAM address (data is passed and masked)
  task write_masked_data;
    input [`HOST_ADDR_WIDTH-1:0]  addr;    
    input [pBURST_DATA_WIDTH-1:0] wrdata;
    input [pBURST_BYTE_WIDTH-1:0] wrmask;
    
    reg [pDATA_WIDTH-1:0] data;
    reg [pHOST_CH_DQS_WIDTH-1:0] mask;
    reg [`CMD_WIDTH-1:0]  op;
    reg [3:0]             burst_len;
    
    integer i;
    
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_masked_data(addr, wrdata, wrmask);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif

      // check if the bytes needs to be re-trained
      if (`SYS.need_data_train) begin
        `SYS.data_train_and_check_status;
      end

      if (burst_size_preset == 1'b0) 
        begin
`ifdef MSD_RANDOM_BL
          // randomly set burst length on-the-fly (only for DDR3) and save
          // the random burst lenght information
          if ({$random} % 2)
            begin
              bl4_otf = (`SYS.initializing_sdram_array) ? 1'b0 : 1'b1;
            end

          save_random_burst_length(addr, bl4_otf);
`endif
        end

      burst_len = (bl4_otf) ? 2/`CLK_NX : `GRM.ctrl_burst_len;

`ifdef RND_SDRAM_NOP_BEFORE_WR
      insert_rnd_sdram_nop;
`endif 

`ifdef MSD_RND_HDR_ODD_CMD
      hdr_odd_cmd = {$random} % 2;
`endif

`ifndef DWC_USE_SHARED_AC_TB
      // Issue 2T cmd on even slot (first half started on ODD slot).
      if (`DWC_2T_MODE == 1)
        hdr_odd_cmd = 1'b0;
`endif

      ddr3_bl4 = `GRM.ddr3_bl4fxd | bl4_otf;
      
      for (i=0; i<burst_len; i=i+1)
        begin
          burst_no = i;
          
          data = wrdata[pDATA_WIDTH-1:0];
          mask = wrmask[pHOST_CH_DQS_WIDTH-1:0];
          
          d_i  = data;
          dm_i = mask;
          if (`SYS.load_mode_pda_en == 1'b1)
            op   = `LOAD_MODE;
          else begin
            a_i  = addr;
            op   = (auto_precharge) ? `WRITE_PRECHG : `SDRAM_WRITE;
          end
          execute_command(op);

          // also execute command in GRM
          // if comparison with GRM is not enabled in the monitor
          if (`HOST_MNT.grm_cmp_en == 1'b0)
            begin
              `GRM.write(addr, mask, data, i);

              if (`GRM.lb_mode && i == 0)
                begin
                  // a write in loopback also results in read data - execute an
                  // equivalent read in GRM
                  -> lb_write;
                  lb_addr      = addr;
                  lb_burst_len = burst_len;
                  lb_ddr3_bl4  = ddr3_bl4;
                end
            end
          // if comparison with GRM is enabled in the host monitor, writes
          // must be made to the GRM.
          if (`HOST_MNT.grm_cmp_en == 1'b1)
            begin
              `GRM.write(addr, mask, data, i);

              if (`GRM.lb_mode && i == 0)
                begin
                  // a write in loopback also results in read data - execute an
                  // equivalent read in GRM
                  -> lb_write;
                  lb_addr      = addr;
                  lb_burst_len = burst_len;
                  lb_ddr3_bl4  = ddr3_bl4;
                end
            end
          wrdata = wrdata >> pDATA_WIDTH;
          wrmask = wrmask >> pHOST_CH_DQS_WIDTH;
        end
`ifdef MSD_RANDOM_BL
      bl4_otf  = 1'b0;
`endif
      ddr3_bl4 = 1'b0;

`ifdef MSD_RND_HDR_ODD_CMD
      // For channel 0, default is using hec mode
      // For channel 1, default is using hoc mode
      if (pCHANNEL_NO == 0)
        hdr_odd_cmd = 1'b0;
      else
        hdr_odd_cmd = 1'b1;
`endif

`ifdef DWC_USE_SHARED_AC_TB
        end
      end // else: !if((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1))
`endif

    end
  endtask // write_masked_data

  
  // read
  // ----
  // reads from a selected DDR SDRAM address
  // NOTE: if doing loopback, reads are not executed - this is to allow
  //       existing testcases to be run in loopback while executing writes only
  task read;
    input [`HOST_ADDR_WIDTH-1:0] addr;

    reg [`CMD_WIDTH-1:0] op;
    reg [3:0]            burst_len;
    integer i;

    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_LOOP_BACK
      // don't execute reads when PHY is in loopback
`else
  `ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this read
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.read(addr);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
  `endif

      if (burst_size_preset == 1'b0) 
        begin
  `ifdef MSD_RANDOM_BL
          // randomly set burst length on-the-fly (only for DDR3)
          bl4_otf = get_random_burst_length(addr);
  `endif
        end
      burst_len = (bl4_otf) ? 2/`CLK_NX : `GRM.ctrl_burst_len;

  `ifdef RND_SDRAM_NOP_BEFORE_RD
      insert_rnd_sdram_nop;
  `endif 

  `ifdef MSD_RND_HDR_ODD_CMD
      hdr_odd_cmd = {$random} % 2;
  `endif

`ifndef DWC_USE_SHARED_AC_TB
      // Issue 2T cmd on even slot (first half started on ODD slot).
      if (`DWC_2T_MODE == 1)
        hdr_odd_cmd = 1'b0;
`endif
     ddr3_bl4 = `GRM.ddr3_bl4fxd | bl4_otf;
      
      burst_no = 0;
      a_i = addr;
      op  = (auto_precharge) ? `READ_PRECHG : `SDRAM_READ;
      
      // also execute command in GRM comparison with GRM in the host monitor
      // is not enabled
      if (`HOST_MNT.grm_cmp_en == 1'b0)
        begin
  `ifdef DWC_USE_SHARED_AC_TB
          `GRM.read(addr, burst_len, ddr3_bl4, pCHANNEL_NO, `SDRAM_READ);
  `else
          `GRM.read(addr, burst_len, ddr3_bl4, `NON_SHARED_AC, `SDRAM_READ);
  `endif
        end

      execute_command(op);

      // read has same timing as write - hold read command and address for the 
      // remaining beats of a burst
      if (burst_len > 1)
        begin
          for (i=1; i<burst_len; i=i+1)
            begin
              burst_no = i;
              a_i = addr;
              execute_command(op);
            end
        end

  `ifdef MSD_RANDOM_BL
      bl4_otf  = 1'b0;
  `endif
      ddr3_bl4 = 1'b0;

  `ifdef MSD_RND_HDR_ODD_CMD
      // For channel 0, default is using hec mode
      // For channel 1, default is using hoc mode
      if (pCHANNEL_NO == 0)
        hdr_odd_cmd = 1'b0;
      else
        hdr_odd_cmd = 1'b1;
  `endif

  `ifdef DWC_USE_SHARED_AC_TB        
        end
      end // else: !if((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1))
  `endif      

`endif // !`ifdef DWC_LOOP_BACK
    end
  endtask // read


  // loopback read data
  always @(lb_write)
    begin
      // a write in loopback also results in read data - execute an
      // equivalent read in GRM (wait a few clocks for the write data to be
      // written to the GRM) 
      nops(lb_burst_len);
`ifdef DWC_USE_SHARED_AC_TB
      `GRM.read(lb_addr, lb_burst_len, lb_ddr3_bl4, pCHANNEL_NO, `SDRAM_READ);
`else
      `GRM.read(lb_addr, lb_burst_len, lb_ddr3_bl4, `NON_SHARED_AC, `SDRAM_READ);
`endif

    end
  
  
  // write/read with precharge
  // -------------------------
  // writes/reads a selected DDR SDRAM address and automatically performs 
  // precharge after the write/read
  task write_precharge;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_precharge(addr);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif

      auto_precharge = 1'b1;
      write(addr);
`ifdef MSD_REPLACE_AUTOPRE
      // all accesses are replaced with their auto-precharge variants
`else
      auto_precharge = 1'b0;
`endif
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_precharge

  task write_precharge_w_mask;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    input [pBURST_DATA_WIDTH-1:0] data;
    input [pBURST_BYTE_WIDTH-1:0] mask;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_precharge_w_mask(addr,data, mask);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      auto_precharge = 1'b1;
      write_masked_data(addr,data,mask);
`ifdef MSD_REPLACE_AUTOPRE
      // all accesses are replaced with their auto-precharge variants
`else
      auto_precharge = 1'b0;
`endif
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_precharge_w_mask
  
  task read_precharge;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this read 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.read_precharge(addr);
      end
      else begin
        // task is in right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif

      auto_precharge = 1'b1;
      read(addr);
`ifdef MSD_REPLACE_AUTOPRE
`else
      // all accesses are replaced with their auto-precharge variants
      auto_precharge = 1'b0;
`endif
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // read_precharge

  
  // on-the-fly BL4 write/read
  // -------------------------
  // performs on-the-fly write/read when DDR3 is configured with the on-the-fly
  // burst length
  task write_bl4;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_bl4(addr);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      bl4_otf = 1'b1;
      write(addr);
      bl4_otf = 1'b0;
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_bl4

  task write_bl4_w_mask;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    input [pBURST_DATA_WIDTH-1:0] data;
    input [pBURST_BYTE_WIDTH-1:0] mask;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_bl4_w_mask(addr, data, mask);
      end
      else begin
        // task is in the right HOST 
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif

      bl4_otf = 1'b1;
      write_masked_data(addr,data,mask);
      bl4_otf = 1'b0;
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_bl4_w_mask

  task write_precharge_bl4;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_precharge_bl4(addr);
      end
      else begin
        // task is in right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif

      bl4_otf = 1'b1;
      write_precharge(addr);
      bl4_otf = 1'b0;
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_precharge_bl4

  task write_precharge_bl4_w_mask;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    input [pBURST_DATA_WIDTH-1:0] data;
    input [pBURST_BYTE_WIDTH-1:0] mask;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.write_precharge_bl4_w_mask(addr,data, mask);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      bl4_otf = 1'b1;
      write_precharge_w_mask(addr,data,mask);
      bl4_otf = 1'b0;
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // write_precharge_bl4_w_mask
  
  task read_bl4;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif

`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this read
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.read_bl4(addr);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      bl4_otf = 1'b1;
      read(addr);
      bl4_otf = 1'b0;
`ifdef  DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // read_bl4
  
  task read_precharge_bl4;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef STATIC_AFTER_INIT
      enable_static_read_mode;
`endif
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this read
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.read_precharge_bl4(addr);
      end
      else begin
        // task is in the right HOST 
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      bl4_otf = 1'b1;
      read_precharge(addr);
      bl4_otf = 1'b0;
`ifdef  DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // read_precharge_bl4
  
  
  // activate
  // --------
  // opens (activates) a selected DDR SDRAM row
  task activate;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    begin
      addr = convert_host_address(addr);
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this activate
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.activate(addr);
      end
      else begin
        // task is in the right HOST
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      a_i = addr;
      execute_command(`ACTIVATE);
`ifdef  DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // activate

  
  // precharge
  // ---------
  // closes (deactivates) an open row in one or all  DDR SDRAM bank
  task precharge;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    
    begin
      addr = convert_host_address(addr);
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this precharge
      if ((addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == 1)  && (pCHANNEL_NO != 1)) begin
        `HOST1.precharge(addr);
      end
      else begin
        // task is in the right HOST  
        if (addr[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO]%2 == pCHANNEL_NO) begin
`endif
      a_i = addr;
      execute_command(`PRECHARGE);
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end
  endtask // precharge
  
  
  task precharge_all;
    input [pALL_RANK_WIDTH-1:0] rank;

    integer                         rank_idx;
    reg [pRANK_WIDTH - 1 : 0] rank_idx_field;

    begin
      // check to see if a specific rank is intended, if so, set gp_flag to tell
      // ddr_mctl that only a specific rank will be executed for this command
      if (rank != `ALL_RANKS)
        gp_flag = 1'b1;
        
`ifdef DWC_USE_SHARED_AC_TB      
      // call HOST 1 as well for this precharge all
      if (rank==`ALL_RANKS && pCHANNEL_NO != 1) begin
         `HOST1.precharge_all(rank);
      end
      else begin // not ALL_RANKS and not in channel 1
        if (rank%2 ==1 && pCHANNEL_NO != 1) begin
         `HOST1.precharge_all(rank);
        end
      end
`endif
        
      if (`DWC_NO_SRA == 1 && rank==`ALL_RANKS) begin
        for (rank_idx = 0; rank_idx < `DWC_NO_OF_RANKS; rank_idx = rank_idx + 1) begin

`ifdef DWC_USE_SHARED_AC_TB      
          if (rank_idx%2 == pCHANNEL_NO) begin
            a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
            execute_command(`PRECHARGE_ALL);
          end
`else
          a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`PRECHARGE_ALL);
`endif
        end
      end
      else begin // Not DWC_NO_SRA or not ALL RANKS

        if (rank==`ALL_RANKS) begin
          a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`PRECHARGE_ALL);
        end
        else begin  
          // Not ALL_RANKS
`ifdef DWC_USE_SHARED_AC_TB
          if (rank%2 == pCHANNEL_NO) begin
            a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
            execute_command(`PRECHARGE_ALL);
          end
`else
          a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`PRECHARGE_ALL);
`endif
        end
      end

      // set gp_flag back to 0
      gp_flag = 1'b0;
    end
  endtask // precharge_all
  
  
  // refresh
  // -------
  // executes a refresh command
  task refresh;

    integer                         rank_idx;
    reg [pRANK_WIDTH - 1 : 0] rank_idx_field;

    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // call HOST 1 as well for this refresh 
      if (pCHANNEL_NO != 1) begin
        `HOST1.refresh;
      end
`endif

      if (`DWC_NO_SRA == 1) begin
        for (rank_idx = 0; rank_idx < `DWC_NO_OF_RANKS; rank_idx = rank_idx + 1) begin
`ifdef DWC_USE_SHARED_AC_TB      
          if (rank_idx%2 == pCHANNEL_NO) begin
            a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
            execute_command(`REFRESH);
          end
`else
          a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`REFRESH);
`endif          
        end
      end
      else begin
        // For Not DWC_NO_SRA, all ranks will be applied by ddr_mctl for both shared AC and non-Shared AC
        execute_command(`REFRESH);
      end
    nops(10);
    precharge_all(`ALL_RANKS);
    nops(10);
    end
  endtask // refresh
  

  // refresh_rank
  // ------------
  // executes a refresh command (for all ranks)
  task refresh_rank;
    input [pRANK_WIDTH-1:0]   rank;    

    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // call HOST 1 as well for this refresh 
      if (rank%2 ==1 && pCHANNEL_NO != 1) begin
        `HOST1.refresh_rank(rank);
      end
      else begin
        if (pCHANNEL_NO == rank) begin
          gp_flag = 1'b1; // load mode to one rank only
          a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}} ,
               {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`REFRESH);
          gp_flag = 1'b0;
        end
      end
`else
      gp_flag = 1'b1; // load mode to one rank only
      a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}} ,
           {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
      execute_command(`REFRESH);
      gp_flag = 1'b0;
`endif        
    end
  endtask // refresh_rank

  
  // self refresh
  // ------------
  // executes a command to enter self refresh mode
  task self_refresh;
    input [pALL_RANK_WIDTH-1:0] rank;
    integer                         rank_idx;
    begin
      set_cmd_mode;
      // check to see if a specific rank is intended, if so, set gp_flag to tell
      // ddr_mctl that only a specific rank will be executed for this command
      if (rank != `ALL_RANKS)
        gp_flag = 1'b1;
       
`ifdef DWC_USE_SHARED_AC_TB      
      // call HOST 1 as well for this precharge all
      if (rank==`ALL_RANKS && pCHANNEL_NO != 1) begin
         `HOST1.self_refresh(rank);
      end
      else begin // not ALL_RANKS and not in channel 1
        if (rank%2 ==1 && pCHANNEL_NO != 1) begin
         `HOST1.self_refresh(rank);
        end
      end
`endif
        
      if (`DWC_NO_SRA == 1 && rank==`ALL_RANKS) begin
        for (rank_idx = 0; rank_idx < `DWC_NO_OF_LRANKS; rank_idx = rank_idx + 1) begin

`ifdef DWC_USE_SHARED_AC_TB      
          if (rank_idx%2 == pCHANNEL_NO) begin
            a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
            execute_command(`SELF_REFRESH);
          end
`else
          a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`SELF_REFRESH);
`endif
        end
      end
      else begin // Not DWC_NO_SRA or not ALL_RANKS

        if (rank==`ALL_RANKS) begin
          a_i = {rank_idx, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`SELF_REFRESH);
        end
        else begin  
          // Not ALL_RANKS
`ifdef DWC_USE_SHARED_AC_TB
          if (rank%2 == pCHANNEL_NO) begin
            a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
            execute_command(`SELF_REFRESH);
          end
`else
          a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`SELF_REFRESH);
`endif
        end
      end

      // set gp_flag back to 0
      gp_flag = 1'b0;
     end
  endtask // self_refresh

  // exits self-refresh mode
  task exit_self_refresh;
    input [pALL_RANK_WIDTH-1:0] rank;
    integer                         rank_idx;
    
    begin
      // check to see if a specific rank is intended, if so, set gp_flag to tell
      // ddr_mctl that only a specific rank will be executed for this command
      if (rank != `ALL_RANKS)
        gp_flag = 1'b1;

      set_cmd_mode;
      // MODE_EXIT command applies to all ranks unless specified
      if (rank==`ALL_RANKS) begin
        special_command(rank, `MODE_EXIT);
      end
      else begin // not ALL RANKS, specified to which rank then for special command

`ifdef DWC_USE_SHARED_AC_TB      
        if (rank%2 == 1 && pCHANNEL_NO != 1)
          `HOST1.exit_self_refresh(rank);
        else begin
          // task is in the right HOST
          $display("-> %0t: [HOST %0d] special command MODE_EXIT for rank=%0d...",$time, pCHANNEL_NO, rank);
          if (pCHANNEL_NO == rank%2) begin 
            gp_flag = 1'b1;
            special_command(rank, `MODE_EXIT);
            gp_flag = 1'b0;
          end
        end
`else
        special_command(rank, `MODE_EXIT);
`endif        
      end
       
      // set gp_flag back to 0
      gp_flag = 1'b0;
    end
  endtask // exit_self_refresh
  
  
  
  // power down
  // ----------
  // executes a command to enter power down mode
  task power_down;
    input [pRANK_WIDTH-1:0] rank;
    begin
      // check to see if a specific rank is intended, if so, set gp_flag to tell
      // ddr_mctl that only a specific rank will be executed for this command
      if (rank != `ALL_RANKS)
        gp_flag = 1'b1;

      set_cmd_mode;
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this power_down
      if (rank%2 == 1 && pCHANNEL_NO != 1) begin
        `HOST1.power_down(rank);
      end
      else begin
        // task is in the right HOST 
        if (pCHANNEL_NO == rank%2) begin 
          a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}},
                 {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`POWER_DOWN);
        end
      end
`else
      a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}},
             {`SDRAM_COL_WIDTH{1'b0}}};
      execute_command(`POWER_DOWN);
`endif        

      // set gp_flag back to 0
      gp_flag = 1'b0;
    end
  endtask // power_down
  
  // exits power down mode
  task exit_power_down;
    input [pALL_RANK_WIDTH-1:0] rank;
    begin
      // check to see if a specific rank is intended, if so, set gp_flag to tell
      // ddr_mctl that only a specific rank will be executed for this command
      if (rank != `ALL_RANKS)
        gp_flag = 1'b1;

      set_cmd_mode;
      // MODE_EXIT command applies to all ranks unless specified
      if (rank==`ALL_RANKS) begin
        special_command(rank, `MODE_EXIT);
      end
      else begin // not ALL RANKS

`ifdef DWC_USE_SHARED_AC_TB      
        if (rank%2 == 1 && pCHANNEL_NO != 1)
          `HOST1.exit_self_refresh(rank);
        else begin
          // task is in the right HOST
          $display("-> %0t: [HOST %0d] special command MODE_EXIT for rank=%0d...",$time, pCHANNEL_NO, rank);
          if (pCHANNEL_NO == rank%2) begin 
            gp_flag = 1'b1;
            special_command(rank, `MODE_EXIT);
            gp_flag = 1'b0;
          end
        end
`else
        special_command(rank, `MODE_EXIT);
`endif            
      end

      // set gp_flag back to 0
      gp_flag = 1'b0;
    end
  endtask // exit_power_down

task deep_power_down; //[DEEP POWER DOWN] 
input [pRANK_WIDTH-1:0] rank;
  begin
    set_cmd_mode;
      `ifdef LPDDRX
        `ifdef DWC_USE_SHARED_AC_TB      
          // check rank no to see if HOST 1 should be called for this deep power_down
          if (rank%2 == 1 && pCHANNEL_NO != 1) begin
          `HOST1.deep_power_down(rank);
          end
          else begin
          // task is in the right HOST 
          if (pCHANNEL_NO == rank%2) begin 
            special_command(rank,`DEEP_POWER_DOWN);
          end
          end
        `else
          special_command(rank,`DEEP_POWER_DOWN);
        `endif  
      `else
          `SYS.error;
          $display("-> %0t: ==> ERROR: Specified ddr mode does not support DEEP POWER DOWN ", $time);
          
      `endif 
  end
endtask // [DEEP POWER DOWN] 
  

 // exits power down mode
  task exit_deep_power_down;  //[EXIT DEEP POWER DOWN] 
    input [pALL_RANK_WIDTH-1:0] rank;
    begin
      set_cmd_mode;
      // MODE_EXIT command applies to all ranks unless specified
      if (rank==`ALL_RANKS) begin
        special_command(rank, `MODE_EXIT);
      end
      else begin // not ALL RANKS
`ifdef DWC_USE_SHARED_AC_TB      
        if (rank%2 == 1 && pCHANNEL_NO != 1)
          `HOST1.exit_self_refresh(rank);
        else begin
          // task is in the right HOST
          $display("-> %0t: [HOST %0d] special command MODE_EXIT for rank=%0d...",$time, pCHANNEL_NO, rank);
          if (pCHANNEL_NO == rank%2) begin 
            gp_flag = 1'b1;
            special_command(rank, `MODE_EXIT);
            gp_flag = 1'b0;
          end
        end
`else
        special_command(rank, `MODE_EXIT);
`endif            
      end
    end
  endtask //[EXIT DEEP POWER DOWN] 
    
  // load mode register
  // ------------------
  // load mode register (reserved for internal use but can still be run from
  // external - the loaded values are not reflected in the mirror register on
  // the controller; normally use the configuration port)
  task load_mode;
    input [`REG_ADDR_WIDTH-1:0] addr;
    input [`MR_DATA_WIDTH-1:0]  data;

      reg [`SDRAM_RANK_WIDTH - 1 : 0] rank;
      reg [`SDRAM_BANK_WIDTH - 1 : 0] bank;
      reg [`SDRAM_ROW_WIDTH  - 1 : 0] row;
      reg [`SDRAM_COL_WIDTH  - 1 : 0] col;
      integer                         rank_idx, beat_idx, lane_idx;
      reg [`HOST_ADDR_WIDTH  - 1 : 0] load_mode_pda_addr;    
      reg [pBURST_DATA_WIDTH - 1 : 0] load_mode_pda_wrdata;

    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // call HOST 1 as well for this load_mode 
      if (pCHANNEL_NO != 1) begin
        `HOST1.load_mode(addr,data);
      end
`endif

      //Functional coverage
      `FCOV.set_cov_address_param(0, 0, 0, data[1:0]);  
      row  = {`SDRAM_ROW_WIDTH{1'b0}};

      // PDA mode
      if (`SYS.load_mode_pda_en) begin
        // Address should be driven by the load_mode task (not the WR task)
        load_mode_pda_addr = {`HOST_ADDR_WIDTH{1'bx}};
        // Build wrdata for PDA load mode access to individual DRAM chips
        for (beat_idx = 0; beat_idx < 4; beat_idx = beat_idx + 1) begin
          // x4 mode
          if (`GRM.dxccr[31]) begin
            for (lane_idx = 0; lane_idx < (`DWC_DX_NO_OF_DQS * `DWC_NO_OF_BYTES); lane_idx = lane_idx + 1)
              load_mode_pda_wrdata[(beat_idx * `DWC_NO_OF_BYTES * 8) + (lane_idx * 4) +: 4] = {4{~`SYS.load_mode_pda_lane[lane_idx]}};
          end
          // x8 mode
          else begin
            for (lane_idx = 0; lane_idx < `DWC_NO_OF_BYTES; lane_idx = lane_idx + 1)
              load_mode_pda_wrdata[(beat_idx * `DWC_NO_OF_BYTES * 8) + (lane_idx * 8) +: 8] = {8{~`SYS.load_mode_pda_lane[lane_idx]}};
          end
        end
      end

      // SRA NOT allowed - cycle through 1 rank at a time
      if ((`DWC_NO_SRA == 1) || `SYS.load_mode_pda_en) begin
        for (rank_idx = 0; rank_idx < `DWC_NO_OF_RANKS; rank_idx = rank_idx + 1) begin
          bank = addr - `MR0_REG;
          row[`SDRAM_ROW_WIDTH-1:0] = data[`MR_DATA_WIDTH-1:0];
          if ((`DWC_UDIMM == 1) && (rank_idx == 1 || rank_idx == 3))  begin
            bank = {bank[2], bank[0], bank[1]};
            row[8:3]= {row[7], row[8], row[5], row[6], row[3], row[4]};
          end
`ifdef DWC_USE_SHARED_AC_TB
  `ifdef LPDDR3
          if (rank_idx%2 == pCHANNEL_NO) begin
            a_i = {  rank_idx
                   , bank[`SDRAM_BANK_WIDTH-1:0]
                   , row[`SDRAM_ROW_WIDTH-1:0]
                   , 11'h9
                  };
            execute_command(`LOAD_MODE);
          end
  `else // !LPDDR3
          if (rank_idx%2 == pCHANNEL_NO) begin
            a_i = {  rank_idx
                   , bank[`SDRAM_BANK_WIDTH-1:0]
                   , row[`SDRAM_ROW_WIDTH-1:0]
                   , {`SDRAM_COL_WIDTH{1'b0}}
                  };
            execute_command(`LOAD_MODE);
          end
  `endif
`else // !DWC_USE_SHARED_AC_TB
  `ifdef LPDDR3
          a_i = {  rank_idx
                 , bank[`SDRAM_BANK_WIDTH-1:0]
                 , row[`SDRAM_ROW_WIDTH-1:0]
                 , 11'h9
                };
          execute_command(`LOAD_MODE);
  `else // !LPDDR3
          a_i = {  rank_idx
                 , bank[`SDRAM_BANK_WIDTH-1:0]
                 , row[`SDRAM_ROW_WIDTH-1:0]
                 , {`SDRAM_COL_WIDTH{1'b0}}
                };
        if (`SYS.load_mode_pda_en) begin
          write_data(load_mode_pda_addr, load_mode_pda_wrdata);
          `SYS.nops(12);
        end
        else
          execute_command(`LOAD_MODE);
  `endif
`endif
        end 
      end
      // SRA allowed
      else begin
        bank = addr - `MR0_REG;
        row[`SDRAM_ROW_WIDTH-1:0] = data[`MR_DATA_WIDTH-1:0];
        // For Not DQC_NO_SRA, all ranks will be applied by ddr_mctl for both shared AC and non-Shared AC.
      `ifdef LPDDR3
        a_i = {{pRANK_WIDTH{1'b0}}, bank[`SDRAM_BANK_WIDTH-1:0],
               row[`SDRAM_ROW_WIDTH-1:0], 11'h9};
      `else
        a_i = {{pRANK_WIDTH{1'b0}}, bank[`SDRAM_BANK_WIDTH-1:0],
               row[`SDRAM_ROW_WIDTH-1:0], {`SDRAM_COL_WIDTH{1'b0}}};
      `endif
        if (`SYS.load_mode_pda_en) begin
          write_data(load_mode_pda_addr, load_mode_pda_wrdata);
        end
        else
          execute_command(`LOAD_MODE);
      end

      // Extract PDA mode set/unset
      if ((addr - `MR0_REG) == `MR3_REG)
        `SYS.load_mode_pda_en = data[4];

    end
  endtask // load_mode

  // Load mode command in PDA mode
  task load_mode_pda;
    input [`REG_ADDR_WIDTH                        - 1 : 0] mr_addr;
    input [`MR_DATA_WIDTH                         - 1 : 0] mr_data;
    input [(`DWC_DX_NO_OF_DQS * `DWC_NO_OF_BYTES) - 1 : 0] pda_lane;

      reg   [`SDRAM_BANK_WIDTH - 1 : 0] bank;
      reg   [`SDRAM_ROW_WIDTH  - 1 : 0] row;
      integer                           rank_idx;

    begin
      `SYS.load_mode_pda_en   = 1'b1;
      `SYS.load_mode_pda_lane = pda_lane;
      load_mode(mr_addr, mr_data);
      `SYS.load_mode_pda_lane = {(`DWC_DX_NO_OF_DQS * `DWC_NO_OF_BYTES){1'b0}};
    end
  endtask

  // TODO -> DDR32UPD -> THIS NEEDS UPDATED FOR GEN2!!!!
  task load_mode_lpddrx;
    input [7:0] addr;
    input [7:0]  data;
    reg [`SDRAM_BANK_WIDTH-1:0]  bank;
    reg [`SDRAM_ROW_WIDTH-1:0] row;
    integer                         rank_idx;
    reg [pRANK_WIDTH - 1 : 0] rank_idx_field;

    begin
      if (`DWC_NO_SRA == 1) begin
        for (rank_idx = 0; rank_idx < `DWC_NO_OF_LRANKS; rank_idx = rank_idx + 1) begin
  
      rank_idx_field = rank_idx;
      a_i = {16'h0000,data,addr};
      a_i[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO] = rank_idx_field;
      execute_command(`LOAD_MODE);
        end
     end
     else begin
        //Functional coverage
        a_i = {16'h0000,data,addr};
        execute_command(`LOAD_MODE);
     end
    end
endtask
   
  task read_mode_lpddrx;
    input   [7:0]                       addr;
    reg     [`SDRAM_BANK_WIDTH-1:0]     bank;
    reg     [`SDRAM_ROW_WIDTH-1:0]      row;
    reg     [pRANK_WIDTH - 1 : 0] rank_idx_field;
    reg     [`HOST_ADDR_WIDTH-1:0]      grm_a;   
    integer                             i;
    integer                             rank_idx;
    reg     [(pNUM_BYTES*8)-1:0]        dq0;
    reg     [(pNUM_BYTES*8)-1:0]        dq1;
    reg     [(pNUM_BYTES*8)-1:0]        dq2;
    reg     [(pNUM_BYTES*8)-1:0]        dq3;
    reg     [3:0]                       burst_len;
    reg     [pDATA_WIDTH-1:0]           data;
    reg     [pBYTE_WIDTH-1:0]           mask;

    begin
     `ifdef MSD_RND_HDR_ODD_CMD
      hdr_odd_cmd = {$random} % 2;
     `endif

     `ifndef DWC_USE_SHARED_AC_TB
      // Issue 2T cmd on even slot (first half started on ODD slot).
      if (`DWC_2T_MODE == 1)
        hdr_odd_cmd = 1'b0;
     `endif

     `ifdef MSD_RND_HDR_ODD_CMD
      // For channel 0, default is using hec mode
      // For channel 1, default is using hoc mode
      if (pCHANNEL_NO == 0)
        hdr_odd_cmd = 1'b0;
      else
        hdr_odd_cmd = 1'b1;
     `endif


      // For MRR: mimic a WR with MR?? so the GRM can store the data.
      burst_len = (bl4_otf) ? 2/`CLK_NX : `GRM.ctrl_burst_len;

      // Build special grm_a to make it unique from other RD addresses to make it unique
      // to avoid memory collision.
      grm_a = {8'h00,8'hxx,8'h00,addr};

      //for (i=0; i<burst_len; i=i+1) begin //Miguel
        // Functional coverage
        a_i = {16'h0000,8'h00,addr};
        execute_command(`READ_MODE);

        // Set the HOST burst number for the GRM write
        burst_no = i;

        // Set the WR data/mask
        case (addr)
          8'h20   : begin
            // Build data pattern for MR32
            dq0 = {(pNUM_BYTES){8'hFF}};
            dq1 = {(pNUM_BYTES){8'h00}};
            dq2 = {(pNUM_BYTES){8'hFF}};
            dq3 = {(pNUM_BYTES){8'h00}};

           `ifdef DWC_DDRPHY_HDR_MODE
            data = {dq3,dq2,dq1,dq0};
           `else
            data = (i%2 == 0) ? {dq1,dq0} : {dq3,dq2};
           `endif
            mask = 'h0;
          end

          8'h28   : begin
            // Build data patter for MR40
            dq0 = {(pNUM_BYTES){8'h00}};
            dq1 = {(pNUM_BYTES){8'h00}};
            dq2 = {(pNUM_BYTES){8'hFF}};
            dq3 = {(pNUM_BYTES){8'hFF}};

           `ifdef DWC_DDRPHY_HDR_MODE
            data = {dq3,dq2,dq1,dq0};
           `else
            data = (i%2 == 0) ? {dq1,dq0} : {dq3,dq2};
           `endif
            mask = 'h0;
          end

          default : begin
            `SYS.error;
            $display("-> %0t: ==> ERROR: MRR to addr = 'h%0h, only suppor MR32/MR40 MRR access", $time, addr);
          end
        endcase

        // Execute command in GRM but not if comparison with GRM is enabled in the host monitor
        if (`HOST_MNT.grm_cmp_en == 1'b0) begin
          `GRM.write(grm_a, mask, data, i);
        end
      //end // for (i=0; i<burst_len; i=i+1) //Miguel

      // For MRR: call the GRM's read task to get the read data prepared for checking
      ddr3_bl4 = `GRM.ddr3_bl4fxd | bl4_otf;

    end
  endtask // read_mode_lpddrx

  task load_mode_rank;
    input [`REG_ADDR_WIDTH-1:0]   addr;
    input [`MR_DATA_WIDTH-1:0]    data;
    input [pRANK_WIDTH-1:0] rank;
    reg [`SDRAM_BANK_WIDTH-1:0]  bank;
    reg [`SDRAM_ROW_WIDTH-1:0] row;

    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this load_mode_rank 
      if (rank%2 == 1 && pCHANNEL_NO != 1) begin
        `HOST1.load_mode_rank(addr,data,rank);
      end
      else begin
        //gp_flag = 1'b1; // load mode to one rank only
        
        //Functional coverage
        `FCOV.set_cov_address_param(0, 0, 0, data[1:0]);  
        bank = addr - `MR0_REG;
        row  = {`SDRAM_ROW_WIDTH{1'b0}};
        row[`SDRAM_ROW_WIDTH-1:0] = data[`MR_DATA_WIDTH-1:0];
        if (rank%2 == pCHANNEL_NO) begin
          gp_flag = 1'b1; // load mode to one rank only
          a_i = {rank, bank[`SDRAM_BANK_WIDTH-1:0],
                 row[`SDRAM_ROW_WIDTH-1:0], {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`LOAD_MODE);
          gp_flag = 1'b0;
        end
      end
`else
      //gp_flag = 1'b1; // load mode to one rank only
      
      //Functional coverage
      `FCOV.set_cov_address_param(0, 0, 0, data[1:0]);  
      bank = addr - `MR0_REG;
      row  = {`SDRAM_ROW_WIDTH{1'b0}};
      row[`SDRAM_ROW_WIDTH-1:0] = data[`MR_DATA_WIDTH-1:0];
      gp_flag = 1'b1; // load mode to one rank only
      a_i = {rank, bank[`SDRAM_BANK_WIDTH-1:0],
             row[`SDRAM_ROW_WIDTH-1:0], {`SDRAM_COL_WIDTH{1'b0}}};
      execute_command(`LOAD_MODE);
      gp_flag = 1'b0;
`endif      
    end
  endtask // load_mode_rank


  
  // write RDIMM register
  // --------------------
  // writes to the RDIMM control register (RCn)
  task write_rdimm_register;
    input [3:0] addr;
    input [3:0] data;

    reg [`SDRAM_ROW_WIDTH-1:0] row;
    reg [`SDRAM_COL_WIDTH-1:0] col;
    begin
      row        = {`SDRAM_ROW_WIDTH{1'b0}};
      col        = {`SDRAM_COL_WIDTH{1'b0}};
      {row, col} = {{(`SDRAM_ROW_WIDTH+`SDRAM_COL_WIDTH-12){1'b0}},
                    data,      // RCn data
                    addr,      // RCn address
                    `RDIMMCRW  // RDIMM RCn register write command
                   };

      a_i = {{pRANK_WIDTH{1'b0}}, {`SDRAM_BANK_WIDTH{1'b0}},
             row[`SDRAM_ROW_WIDTH-1:0], col[`SDRAM_COL_WIDTH-1:0]};
      execute_command(`SPECIAL_CMD);
    end
  endtask // write_rdimm_register

  
  // Write Level trigger
  // ------------------
  // load mode register (reserved for internal use but can still be run from
  // external - the loaded vaues are not reflected in the mirror register on
  // the controller; normally use the configuration port)
  task write_level_emr;
    input [`REG_ADDR_WIDTH-1:0] addr;
    input [`MR_DATA_WIDTH-1:0]  data;
    input [pRANK_WIDTH-1:0] rank;
    reg [`SDRAM_BANK_WIDTH-1:0]  bank;
    reg [`SDRAM_ROW_WIDTH-1:0] row;
    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if (pCHANNEL_NO != 1 && rank%2 == 1) begin
        `HOST1.write_level_emr(addr,data,rank);
      end
      else begin
        bank = addr - `MR0_REG;
        row  = {`SDRAM_ROW_WIDTH{1'b0}};
        row[`SDRAM_ROW_WIDTH-1:0] = data[`MR_DATA_WIDTH-1:0];
        if (rank%2 == pCHANNEL_NO) begin
          a_i = {rank, bank[`SDRAM_BANK_WIDTH-1:0],
                 row[`SDRAM_ROW_WIDTH-1:0], {`SDRAM_COL_WIDTH{1'b0}}};
          execute_command(`LOAD_MODE);
        end
      end
`else        
      bank = addr - `MR0_REG;
      row  = {`SDRAM_ROW_WIDTH{1'b0}};
      row[`SDRAM_ROW_WIDTH-1:0] = data[`MR_DATA_WIDTH-1:0];
      a_i = {rank, bank[`SDRAM_BANK_WIDTH-1:0],
             row[`SDRAM_ROW_WIDTH-1:0], {`SDRAM_COL_WIDTH{1'b0}}};
      execute_command(`LOAD_MODE);
`endif
    end
  endtask // write_level_emr

  
  
  // ZQ calibration
  // --------------
  // executes a ZQ calibration command
  task zq_calibration;
    input [3:0] zq_cmd;

    integer                         rank_idx;

    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // call HOST 1 
      if (pCHANNEL_NO != 1) begin
        `HOST1.zq_calibration(zq_cmd);
      end
`endif

`ifdef LPDDRX
      if (zq_cmd == `ZQCAL_LONG) begin
        load_mode_lpddrx(8'h0A, 8'hAB);
      end else if (zq_cmd == `ZQCAL_SHORT) begin
        load_mode_lpddrx(8'h0A, 8'h56);
      end else begin
        load_mode_lpddrx(8'h0A, 8'hFF);
      end
`else
      if (`DWC_NO_SRA == 1) begin
        for (rank_idx = 0; rank_idx < `DWC_NO_OF_LRANKS; rank_idx = rank_idx + 1) begin
  `ifdef DWC_USE_SHARED_AC_TB      
          if (rank_idx%2 == pCHANNEL_NO) begin
  `endif
            a_i[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO] = rank_idx;
            execute_command(zq_cmd);
            sdram_nops(`GRM.tdinitzq);
  `ifdef DWC_USE_SHARED_AC_TB      
          end
  `endif
        end
      end
      else begin
        // For Not DWC_NO_SRA, all ranks will be applied by ddr_mctl for both shared AC and non-Shared AC
        execute_command(zq_cmd);
      end
`endif
    end
  endtask // zq_calibration

  
  
  // SDRAM NOP
  // ---------
  // (to rank 0)
  task sdram_nops;
    input [31:0] no_of_nops;
    integer i;
    begin
      for (i=0; i<no_of_nops; i=i+1)
        begin
          execute_command(`SDRAM_NOP);
        end
    end
  endtask // sdram_nops

  task sdram_nop;
    begin
      sdram_nops(1);
    end
  endtask // sdram_nop

  
  // SDRAM NOPs directed towards a specific rank
  task rank_nops;
    input [pRANK_WIDTH-1:0] rank;
    input [31:0] no_of_nops;
    integer i;
    begin
      for (i=0; i<no_of_nops; i=i+1) begin
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this task
        if (rank%2 ==1 && pCHANNEL_NO != 1) begin
          `HOST1.rank_nops(rank,no_of_nops);
        end
        else begin
          // task is in the right HOST 
            if (pCHANNEL_NO == rank%2) begin 
              a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}} ,
               {`SDRAM_ROW_WIDTH{1'b0}}, {`SDRAM_COL_WIDTH{1'b0}}};
              execute_command(`SDRAM_NOP);
            end
        end
`else
        a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}},
               {`SDRAM_COL_WIDTH{1'b0}}};

        execute_command(`SDRAM_NOP);
`endif        
      end
    end
  endtask // rank_nops


  task rank_nop;
    input [pRANK_WIDTH-1:0] rank;
    begin
      rank_nops(rank, 1);
    end
  endtask // rank_nop


  // NOP
  // ---
  task nops;
    input [31:0] no_of_nops;
    integer i;
    begin
      for (i=0; i<no_of_nops; i=i+1)
        begin
          @(posedge clk);
        end
    end
  endtask // nops

  task nop;
    begin
      nops(1);
    end
  endtask // nop


  // In the following tasks, NOPs are actually executed as a command instead 
  // of doing nothing
  task execute_nops;
    input [31:0] no_of_nops;
    integer i;
    begin
      for (i=0; i<no_of_nops; i=i+1)
        begin
          execute_command(`CTRL_NOP);
        end
    end
  endtask // execute_nops

  task execute_nop;
    begin
      execute_nops(1);
    end
  endtask // execute_nop

  
  // special commands
  // ----------------
  // special controller and SDRAM commands
  task special_command;
    input [pALL_RANK_WIDTH-1:0] rank;
    input [3:0] cmd_type;
    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write
      if (rank==`ALL_RANKS && pCHANNEL_NO != 1) begin
        `HOST1.special_command(rank, cmd_type);
      end

      // individual ranks or ALL_RANKS
      if (rank%2 ==1 && pCHANNEL_NO != 1) begin
        `HOST1.special_command(rank, cmd_type);
      end
      else begin
        // task is in the right HOST
        if (rank%2 == pCHANNEL_NO || rank ==`ALL_RANKS) begin
          a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}},
                 {(`SDRAM_COL_WIDTH-4){1'b0}}, cmd_type};
          execute_command(`SPECIAL_CMD);
        end
      end
`else
      a_i = {rank, {`SDRAM_BANK_WIDTH{1'b0}}, {`SDRAM_ROW_WIDTH{1'b0}},
             {(`SDRAM_COL_WIDTH-4){1'b0}}, cmd_type};
      execute_command(`SPECIAL_CMD);
`endif
    end
  endtask // special_command
  
  
  //---------------------------------------------------------------------------
  // Controller Input/Output
  //---------------------------------------------------------------------------
  // drives and sinks controller inputs and outputs, respectively
  
  // execute command
  // ---------------
  // low-level task that executes the command for (drive pins of) the
  // controller; command is initiated by one of the above high-level tasks
  // NOTE: testcases or other modules should not call this task directly!
  task execute_command;
    input [`CMD_WIDTH-1:0] op;
    integer no_of_nops;
    integer i;
    
    reg [pRANK_WIDTH-1:0]   rank;
    reg [`SDRAM_BANK_WIDTH-1:0] bank;
    reg [`SDRAM_ROW_WIDTH-1:0]  row;
    reg [`SDRAM_COL_WIDTH-1:0]  col;

    reg [`DWC_BANK_WIDTH-1:0]   mapped_bank;
    reg [`DDR_ROW_WIDTH-1:0]    mapped_row;
    reg [`DDR_COL_WIDTH-1:0]    mapped_col;    
    
    begin
      // insert required NOPs if this feature is enabled
      if (auto_nops_en === 1'b1 && op !== `CTRL_NOP &&
          !((op == `SDRAM_WRITE || op == `WRITE_PRECHG ||
             op == `SDRAM_READ  || op == `READ_PRECHG) && burst_no != 3'b000))
        begin
          if (rnd_nops)
            begin
              // send 0->(nops_range -1) nops if  >= weighted_nops;
              // else skip nops
              no_of_nops = {$random} % nops_range;
              if ((no_of_nops < weighted_nops) && (weighted_nops!=0)) no_of_nops = 0;
              else no_of_nops = {$random} % nops_range; 
            end
          else
            no_of_nops = auto_nops;

          nops(no_of_nops);
        end

      // execute current operation:
      // drive the inputs; provide minimum setup time for each signal
      @(negedge clk);
      fork
        begin
          rqvld = 1'b1;
          
          cmd = op;
          dm  = dm_i;
        end

        begin
          a = a_i;
        end

        begin
          d  = d_i;
        end
      join

      // deassert the inputs; provide minimum hold time for each signal
      // (wait until the controller acknowledges the request)
      @(posedge clk);
      while (rdy === 1'b0) @(posedge clk);
      #(tCKL - 0.008);
      fork
        begin
          rqvld = 1'b0;
          
          cmd = `CTRL_NOP;
          dm  = DM_DEFAULT;
        end

        begin
          a = ADDR_DEFAULT;
        end

        begin
          d  = DATA_DEFAULT;
        end
      join

      // reset internal signals
      dm_i = DM_DEFAULT;
      a_i  = ADDR_DEFAULT;
      d_i  = DATA_DEFAULT;
    end
  endtask // execute_command

  
  // result compare
  // --------------
  // compares the results (read data and tag or write tag) with the data in 
  // the GRM
  always @(posedge clk or negedge rst_b)
    begin: grm_compare
      // if the most significant byte has fewer DQ bits, ignore the unused bits
      // when comparing read data, i.e. the effective data width is reduced
      integer j, i;
      reg [pEDATA_WIDTH-1:0] rd_q;
      reg [pEDATA_WIDTH-1:0] rd_grm_q;
      reg [pDATA_WIDTH -1:0] mask;

      // compare the read data and write tag with the values in GRM
      // (only if comparison in the monitor is disabled)
      // NOTE: ignore in ATPG scan mode
      if (`HOST_MNT.grm_cmp_en == 1'b0)
        begin
          if (qvld === 1'b1 && `SYS.scan_ms === 1'b0 && read_cnt_en === 1'b1)
            begin
`ifdef DWC_USE_SHARED_AC_TB
              `GRM.get_read_data(pCHANNEL_NO, grm_q, grm_ddr3_bl4);
`else
              `GRM.get_read_data(`NON_SHARED_AC, grm_q, grm_ddr3_bl4);
`endif

              // in case the most significant byte don't have all the DQs used,
              // ignore the unused DQ bits when comparing read data
              for (j=0; j<`HOST_NX; j=j+1) begin
                for (i=0; i<pDWC_EDATA_WIDTH; i=i+1) begin
                  rd_q    [j*pDWC_EDATA_WIDTH + i] = q    [j*pDWC_DATA_WIDTH + i];
                  rd_grm_q[j*pDWC_EDATA_WIDTH + i] = grm_q[j*pDWC_DATA_WIDTH + i];
                end
              end
              
              // Get the byte enable mask
`ifdef DWC_USE_SHARED_AC_TB
              `GRM.get_channel_byte_enable_mask(pCHANNEL_NO, mask);
`else
              `GRM.get_channel_byte_enable_mask(`NON_SHARED_AC, mask);
`endif

              // compare read data output with expected value
              if (rd_q !== rd_grm_q)
                begin
                    `ifdef SOFT_Q_ERRORS   //added by Jose for jitter testing
		      `ifdef PROBE_DATA_EYES
                      `EYE_MNT.jitter_error_counter = `EYE_MNT.jitter_error_counter + 1 ;
		      `endif
                    `else  
                      if (pCHANNEL_NO == 0) begin
                        #0;
                        `SYS.error_message(`CHIP_CTRL, `QERR, rd_grm_q);
                      end else begin
                        #0;
                        `SYS.error_message(`CHIP_CTRL_1, `QERR, rd_grm_q);
                      end
                    `endif  
                end

              // keep track of how many read data have been received
              `GRM.log_host_read_output;

              // log the on-the-fly burst length used
              // (for use by the monitor)
              `GRM.log_burst_length(grm_ddr3_bl4, `MSD_READ);
            end
        end // if (`HOST_MNT.grm_cmp_en == 1'b0)
    end // block: grm_compare


  // converst address
  // ----------------
  // this is used to convert address if necessary;
  // example is for single rank RDIMM, any accesses to rank 1 goes to rank 0, and
  // any accesses to rank 3 goes to rank 2
  function [`HOST_ADDR_WIDTH-1:0] convert_host_address;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    
    reg [pRANK_WIDTH-1:0]    rank;
    reg [`SDRAM_BANK_WIDTH-1:0]  bank;
    reg [`SDRAM_ROW_WIDTH-1:0]   row;
    reg [`SDRAM_COL_WIDTH-1:0]   col;   
    begin
      {rank, bank, row, col} = addr;

      case (addr_conv_type)
        pONLY_EVEN_RANKS: begin
          if ((rank % 2) == 1) begin
            rank = rank - 1;
          end
        end
      endcase // case addr_conv_type

      convert_host_address = {rank, bank, row, col};
    end
  endfunction // convert_host_address

  
  //---------------------------------------------------------------------------
  // DDR Controller Miscellaneous Tasks
  //---------------------------------------------------------------------------
  // miscellaneous tasks for the DDR controller

  // DDR accesses
  // ------------
  // executes a few DDR accesses - used especially when some configurations
  // have changed and a few accesses need to be executed to check that the
  // configuration is successful
  task execute_ddr_accesses;
    input [31:0]                  accesses;    
    input [pRANK_WIDTH-1:0]   rank;
    input [`SDRAM_BANK_WIDTH-1:0] bank;
    input [`SDRAM_ROW_WIDTH-1:0]  row;
    input [`SDRAM_COL_WIDTH-1:0]  col;

    reg   [`SDRAM_COL_WIDTH       - 1 : 0]  init_col;
    reg   [`SDRAM_COL_WIDTH - 1 : 0]  col_incr;
    integer                                   i;

    begin
      // Get the BL and set the col_inc depending on BL
      case (`GRM.ddr_burst_len)
        5'b00010: col_incr = 2;
        5'b00100: col_incr = 4;
        5'b01000: col_incr = 8;
        5'b10000: col_incr = 16;
      endcase  
`ifdef DWC_USE_SHARED_AC_TB      
      // check rank no to see if HOST 1 should be called for this write 
      if (rank%2 ==1 && pCHANNEL_NO != 1) begin
        `HOST1.execute_ddr_accesses(accesses,rank,bank,row,col);
      end
      else begin
        // task is in the right HOST 
        if (rank%2 == pCHANNEL_NO) begin
`endif
      init_col = col;


      // back-to-back writes/reads
      col = init_col;
      for (i=0; i<accesses; i=i+1)
        begin
          if (`MCTL.rfsh_prd_cntr_en && `MCTL.rfsh_prd_cntr <= `tRFC_min) begin
            wait (`MCTL.rfsh_cmd);
            repeat (`tRFC_min+10) @(posedge `SYS.clk);
            `HOST.precharge_all(rank); 
            `HOST.nops(10);
          end
          write({rank, bank, row, col});
          col = col + 8;
        end

     
      
      col = init_col;
      for (i=0; i<accesses; i=i+1)
        begin
          if (`MCTL.rfsh_prd_cntr_en && `MCTL.rfsh_prd_cntr <= `tRFC_min) begin
            wait (`MCTL.rfsh_cmd);
            repeat (`tRFC_min+10) @(posedge `SYS.clk);
            `HOST.precharge_all(rank); 
            `HOST.nops(10);
          end
          read({rank, bank, row, col});
          col = col + 8;
        end
   
    
     
      // mixed writes/reads
      col = init_col;
      for (i=0; i<accesses; i=i+1)
        begin
          if (`MCTL.rfsh_prd_cntr_en && `MCTL.rfsh_prd_cntr <= `tRFC_min) begin
            wait (`MCTL.rfsh_cmd);
            repeat (`tRFC_min+10) @(posedge `SYS.clk);
         `HOST.precharge_all(rank); 
         `HOST.nops(10); 
          end
          write({rank, bank, row, col});
          if (`MCTL.rfsh_prd_cntr_en && `MCTL.rfsh_prd_cntr <= `tRFC_min) begin
            wait (`MCTL.rfsh_cmd);
            repeat (`tRFC_min+10) @(posedge `SYS.clk);
         `HOST.precharge_all(rank); 
         `HOST.nops(10); 
          end
          read({rank, bank, row, col});
          col = col + 8;
        end

 
`ifdef DWC_USE_SHARED_AC_TB      
        end
      end
`endif
    end

  endtask // execute_ddr_accesses

  task enable_rfsh_inhibit;
    begin
      rfsh_inh = 1'b1;
    end
  endtask

  task disable_rfsh_inhibit;
    begin
      rfsh_inh = 1'b0;
    end
  endtask

  
  // Automatic NOPs
  //---------------
  // enables/disables the automatic insertion of NOPs before executing any 
  // command
  task enable_auto_nops;
    input [31:0] nop_type;
    input [31:0] num;
    begin
      auto_nops_en = 1'b1;
      
      case (nop_type)
        `SAME_DATA: auto_nops = num;
        `PREDFND_DATA:
          begin
            // predefined data for back-to-back testcases
            case (num)
              0: auto_nops = 0;
              1: auto_nops = 1;
              2: auto_nops = 2;
              default:
                begin
                  auto_nops = {$random} % 20 + 3; // random between 3 and 20
                end
            endcase // case(num)
          end
        default: auto_nops = num;
      endcase // case(nop_type)
    end
  endtask // enable_auto_nops

  // disable insertion of auto NOPs
  task disable_auto_nops;
    begin
      auto_nops_en = 1'b0;
    end
  endtask // disable_auto_nops


  // random auto nops per execute_command
  task enable_rnd_nops;
    input [31:0] wgt_nops;
    input [31:0] nops_rng;
    begin
      auto_nops_en = 1'b1;
      rnd_nops = 1'b1;
      weighted_nops = wgt_nops;
      nops_range    = nops_rng;
    end
  endtask // enable_rnd_nops
  

  task disable_rnd_nops;
    begin
      auto_nops_en = 1'b0;
      rnd_nops = 1'b0;
      weighted_nops = 0;
      nops_range    = 0;
    end
  endtask // disable_rnd_nops
  

  // This task is to allow user to change the default parameters of
  // randomly inserted SDRAM NOPS    
  task enable_rnd_sdram_nops;
    input [31:0] max_loop;
    input [31:0] wgt_nops;
    input [31:0] nops_rng;
    begin
      max_rnd_loop = max_loop;
      sdram_wgt_nops = wgt_nops;
      sdram_nops_range = nops_rng;
    end
  endtask // enable_rnd_sdram_nops
  

  task disable_rnd_sdram_nops;
    begin
      max_rnd_loop = 1;
      sdram_wgt_nops = 10;
      sdram_nops_range = 10;
    end
  endtask // disable_rnd_sdram_nops


  // Task for inserting random number of SDRAM NOPs before Write or Read cmd
  task insert_rnd_sdram_nop;
    integer no_of_nops;
    begin
      // send 0->(nops_range -1) nops if  >= sdram_wgt_nops;
      // else skip nops
      no_of_nops = {$random} % sdram_nops_range;
      if ((no_of_nops < sdram_wgt_nops) && (sdram_wgt_nops!=0))  no_of_nops = 0;
      else 
        begin
          no_of_nops = {$random}% max_rnd_loop;
        end            
      
      sdram_nops(no_of_nops);

    end
  endtask // insert_rnd_sdram_nop

  
`ifdef MSD_RANDOM_BL
  // random burst length
  // -------------------
  // save the address and burst length used during random burst length write
  task save_random_burst_length;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    input                        bl4;
    reg  [`HOST_ADDR_WIDTH-1:0]  waddr;
    reg                          wbl4;
    reg                          addr_found;
    integer                      i;
    begin
      if (rnd_bl_no == MAX_RND_BL)
        begin
          $write("    *** ERROR: Random burst length memory overflow: ");
          $write("Increase size of MAX_RND_BL parameter in host_bfm.v\n");
          `SYS.log_error;
          `END_SIMULATION;
        end
      else
        begin
          // save the address and BL used
          // first check to see if the address has already been used
          // if so, update the original data
          addr_found = 0;
          if (rnd_bl_no > 0) begin
            for (i=0; i<rnd_bl_no; i=i+1)
              begin
                {wbl4, waddr} = rnd_bl_info[i];
                if (waddr === addr)
                  begin
                    addr_found = 1'b1;
                    rnd_bl_info[i] = {bl4, addr};
                    i = MAX_RND_BL; // force end of search
                  end
              end
          end
          
          if (!addr_found) begin
            rnd_bl_info[rnd_bl_no] = {bl4, addr};
            rnd_bl_no = rnd_bl_no + 1;
          end
        end
    end
  endtask // save_random_burst_length

  // get the random burst length to be used for this access
  function get_random_burst_length;
    input [`HOST_ADDR_WIDTH-1:0] addr;
    
    reg                         bl4;
    reg  [`HOST_ADDR_WIDTH-1:0] waddr;
    reg                         addr_found;
    integer                     i;
    begin
      // use the same burst length or less to the one used for write to the
      // same address
      addr_found = 0;
      for (i=0; i<MAX_RND_BL; i=i+1)
        begin
          {bl4, waddr} = rnd_bl_info[i];
          if (waddr === addr)
            begin
              addr_found = 1'b1;
              i = MAX_RND_BL; // force end of search

              // if BL4 was use for write, also use BL4 for read, otherwise if
              // BL8 was used for write, use either BL4 or BL8 for read
              get_random_burst_length = (bl4) ? bl4 :
                                        ({$random} % 2);
            end
        end

      // check if the address was never written to
      if (!addr_found)
        begin
          $write("    *** WARNING: Reading an address that was never");
          $write("written to\n");
          `SYS.log_warning;
          get_random_burst_length = {$random} % 2;
        end
    end
  endfunction // get_random_burst_length
`endif //  `ifdef MSD_RANDOM_BL
  
  
  //---------------------------------------------------------------------------
  // Write Data Array
  //---------------------------------------------------------------------------

  // fill_wrdata_array
  // -----------------
  // fill wrdata array from 0 to entry specified
  task fill_wrdata_array;
    input [31:0] num_entries;
    input [1:0] pattern_name;
    input [3:0] pattern_type;
    input [pDATA_WIDTH-1:0] pattern_init_val; // initial val of pattern

    integer i;
    
    for (i=0; i<num_entries; i=i+1)
      begin
        generate_pattern(i, pattern_name, pattern_type, pattern_init_val);
      end
    
  endtask //fill_wrdata_array


  // generate pattern data
  // ---------------------
  // generates pattern data
  task generate_pattern;
    input [31:0] pattern_no;    // nth pattern
    input [1:0] pattern_name;
    input [3:0] pattern_type;
    input [`PAT_WIDTH-1:0] pattern_init_val; // initial val of pattern

    integer max_bits;
    integer MSB;
    reg [`PAT_WIDTH-1:0] max_val;
    reg [`PAT_WIDTH-1:0] prev_pattern;
    begin
      // find maximum allowable pattern parameters
      case (pattern_name)
        `DATA_PATTERN: max_bits = pDATA_WIDTH;
        `ADDR_PATTERN: max_bits = `DWC_ADDR_WIDTH;
        `BANK_WIDTH:   max_bits = `BANK_WIDTH;
        default:       max_bits = `PAT_WIDTH;
      endcase // case(pattern_name)
      
      max_val = (1 << max_bits) - 1;
      MSB = max_bits - 1;

      if (pattern_no == 0)
        begin
          // initial value of pattern
          case (pattern_type)
            `SAME_DATA,
            `TOGGLE_DATA,
            `INCR_BY_2_DATA,
            `SEQUENTIAL_DATA : pattern = pattern_init_val;
            `ALL_ZEROS,              
              `ZEROS_ONES      : pattern = {`PAT_WIDTH{1'b0}};
            `ALL_ONES        : pattern = {`PAT_WIDTH{1'b1}};
            `WALKING_ONES    : pattern = {{`PAT_WIDTH-1{1'b0}}, 1'b1};
            `WALKING_ZEROS   : pattern = {{`PAT_WIDTH-1{1'b1}}, 1'b0};
            `ALL_AAAA_DATA   : pattern = {`MAX_PAT_NIBBLES{4'hA}};
            `ALL_5555_DATA   : pattern = {`MAX_PAT_NIBBLES{4'h5}};
            `SEQUENTIAL_BYTES: pattern = {`MAX_PAT_NIBBLES{4'h1}};
            `RANDOM_DATA     : pattern = {{$random}, {$random}, 
                                          {$random}, {$random}};
            default          : pattern = {`PAT_WIDTH{1'bx}};
          endcase // case(pattern)
        end
      else
        begin
          prev_pattern = pattern;
          case (pattern_type)
            `ALL_AAAA_DATA,
            `ALL_5555_DATA,
            `SAME_DATA,
            `ALL_ONES,
            `ALL_ZEROS      :  pattern = prev_pattern;
            `SEQUENTIAL_DATA:  pattern = (prev_pattern == max_val) ?
                                         {`PAT_WIDTH{1'b0}} : 
                                         prev_pattern+1;
            `SEQUENTIAL_BYTES: pattern = (pattern_no == 15) ?
                                         {`MAX_PAT_BYTES{8'h01}} :
                                         (pattern_no < 15) ?
                                         prev_pattern+{`MAX_PAT_NIBBLES{4'h1}} :
                                         prev_pattern+{`MAX_PAT_BYTES{8'h01}};
            `INCR_BY_2_DATA :  pattern = (prev_pattern >= (max_val-1)) ?
                                         prev_pattern-(max_val-1) : 
                                         prev_pattern+2;
            `TOGGLE_DATA, 
              `ZEROS_ONES     :  pattern = ~prev_pattern;
            `WALKING_ONES   :  pattern = (prev_pattern[MSB] == 1'b1) ?
                                         {{(`PAT_WIDTH-1){1'b0}}, 1'b1} :
                                         (prev_pattern << 1);
            `WALKING_ZEROS  :  pattern = (prev_pattern[MSB] == 1'b0) ?
                                         {{(`PAT_WIDTH-1){1'b1}}, 1'b0} :
                                         ~((~prev_pattern) << 1);
            `RANDOM_DATA    :  pattern = {{$random}, {$random}, 
                                          {$random}, {$random}};
            default         :  pattern = {`PAT_WIDTH{1'bx}};
          endcase // case(pattern_type)
        end // else: !if(pattern_no == 0)

      wrdata[pattern_no] = pattern;

    end
  endtask // generate_pattern


  // insert write data
  // -----------------
  // inserts write data and write data mask into the write data array
  task insert_write_data;
    input [31:0]            data_no;
    input [pDATA_WIDTH-1:0] data;
    input [pHOST_CH_DQS_WIDTH-1:0] mask;
    begin
      wrdata[data_no]      = data;
  `ifdef DWC_DX_DM_USE
      wrdata_mask[data_no] = mask;
  `endif
    end
  endtask // insert_write_data
  
  // set_wrdata_mask_val
  // -------------------
  // sets the wrdata mask value for a specific entry in the array
  task set_wrdata_mask_val;
    input [31:0] wrdata_ptr;
    input [31:0] mask_val;

    begin
  `ifdef DWC_DX_DM_USE
      wrdata_mask[wrdata_ptr] = mask_val;
  `endif
    end
    
  endtask //set_wrdata_mask_val

  // set_wrdata_ptr
  // --------------
  // Sets the wrdata mask value for a specific entry in the array
  task set_wrdata_ptr;
    input [31:0] new_wrdata_ptr;

    begin
      wrdata_ptr = new_wrdata_ptr;
    end
    
  endtask //set_wrdata_mask_val

  
  //---------------------------------------------------------------------------
  // SDRAM Initialization
  //---------------------------------------------------------------------------
  // executes the SDRAM initialization sequence when initiated through the host
  // or the controller
  task initialize_sdram;
    begin
      case (`GRM.ddr_mode)
        `DDR4_MODE  :   initialize_ddr4_sdram;
        `DDR3_MODE  :   initialize_ddr3_sdram;
        `DDR2_MODE  :   initialize_ddr2_sdram;
        `LPDDR2_MODE:   initialize_lpddrx_sdram;
        `LPDDR3_MODE:   initialize_lpddrx_sdram;
      endcase // case (`GRM.ddr_mode)
    end
  endtask // initialize_sdram


  // Controller SDRAM initialization
  // -------------------------------

  // DDR4 DRAM initialization
  task initialize_ddr4_sdram;
  integer i;
  reg [31:0] word;
    begin
      fork
        begin: RAM_RESET_CHANNEL_0
          if (pCHANNEL_NO == 0) begin
            `DFI.drive_reset(1'b0);
            nops(`GRM.tdinitrst/`CLK_NX);
            `DFI.drive_reset(1'b1);
            nops(`GRM.tdinitckelo/`CLK_NX);
            `DFI.drive_reset(1'b1);
            sdram_nops(`GRM.tdinitckehi/`CLK_NX); // CKE high to first instruction
          end
        end

        begin: RAM_RESET_CHANNEL_1
          // Host bfm 0 will also drive Host bfm 1, system will only call HOST 0
`ifdef DWC_USE_SHARED_AC_TB
          if (pCHANNEL_NO == 0) begin
            `DFI1.drive_reset(1'b0);
            `HOST1.nops(`GRM.tdinitrst/`CLK_NX);
            `DFI1.drive_reset(1'b1);
            `HOST1.nops(`GRM.tdinitckelo/`CLK_NX);
            `DFI1.drive_reset(1'b1);
            `HOST1.sdram_nops(`GRM.tdinitckehi/`CLK_NX); // CKE high to first instruction
          end
`endif
        end
      join

      if (pCHANNEL_NO == 0) begin
        for(i=0; i<1 ; i=i+1)
        begin
          load_mode(`MR3_REG, `GRM.mr3[0]);
          load_mode(`MR6_REG, `GRM.mr6[i]);
          load_mode(`MR5_REG, `GRM.mr5[i]);
          load_mode(`MR4_REG, `GRM.mr4[i]);
          load_mode(`MR2_REG, `GRM.mr2[i]);
          load_mode(`MR1_REG, `GRM.mr1[i]);
        end
        word = `GRM.mr0;
        word[8] = 1'b1;
        load_mode(`MR0_REG, word);    // reset DLL
        zq_calibration(`ZQCAL_LONG);  // ZQ long calibration
        sdram_nops(`tDLLK/`CLK_NX);         // wait DLL lock to first instruction
      end
    end
    
  endtask // initialize_ddr4_sdram

  // DDR3 DRAM initialization
  task initialize_ddr3_sdram;
    integer i,j;
    reg [31:0] word;
`ifdef DWC_DDR_RDIMM
    reg [3:0] cr_addr;
    reg [3:0] cr_data;
`endif
    begin
      fork
        begin: RAM_RESET_CHANNEL_0
          if (pCHANNEL_NO == 0) begin
            `DFI.drive_reset(1'b0);
            nops(`GRM.tdinitrst/`CLK_NX);
            `DFI.drive_reset(1'b1);
            nops(`GRM.tdinitckelo/`CLK_NX);
            `DFI.drive_reset(1'b1);
            sdram_nops(`GRM.tdinitckehi/`CLK_NX); // CKE high to first instruction
          end
        end

        begin: RAM_RESET_CHANNEL_1
          // Host bfm 0 will also drive Host bfm 1, system will only call HOST 0
`ifdef DWC_USE_SHARED_AC_TB
          if (pCHANNEL_NO == 0) begin
            `DFI1.drive_reset(1'b0);
            `HOST1.nops(`GRM.tdinitrst/`CLK_NX);
            `DFI1.drive_reset(1'b1);
            `HOST1.nops(`GRM.tdinitckelo/`CLK_NX);
            `DFI1.drive_reset(1'b1);
            `HOST1.sdram_nops(`GRM.tdinitckehi/`CLK_NX); // CKE high to first instruction
          end
`endif
        end
      join

`ifdef DWC_DDR_RDIMM
      if (pCHANNEL_NO == 0) begin
        // execute RDIMM initialization as part of DRAM initiialization
        // driven by HOST 0 only
        for (i=0; i<16; i=i+1) begin
          if (`GRM.rdimmgcr1[16+i] == 1'b1) begin
            cr_addr = i;
            for (j=0; j<`DWC_NO_OF_DIMMS; j=j+1)
              cr_data = (i<8) ? `GRM.rdimmcr0[j][i*4 +: 4] : `GRM.rdimmcr1[j][(i-8)*4 +: 4];
            write_rdimm_register(cr_addr, cr_data);
          end
        end
      end
`endif

      if (pCHANNEL_NO == 0) begin
        for(i=0; i<1 ; i=i+1)
        begin
          load_mode(`MR2_REG, `GRM.mr2[i]);
          load_mode(`MR3_REG, `GRM.mr3[0]);
          load_mode(`MR1_REG, `GRM.mr1[i]);    // enable DLL
        end
        word = `GRM.mr0;
        word[8] = 1'b1;
        load_mode(`MR0_REG, word);    // reset DLL
        zq_calibration(`ZQCAL_LONG);  // ZQ long calibration
        sdram_nops(`tDLLK/`CLK_NX);   // wait DLL lock to first instruction
      end
    end
  endtask // initialize_ddr3_sdram

  // DDR2 DRAM initialization
  task initialize_ddr2_sdram;
  integer i;
    begin
      sdram_nops(`GRM.tdinitckehi/`CLK_NX); // CKE high to first instruction
      precharge_all(`ALL_RANKS);
      sdram_nops(`GRM.t_rp);        // wait tRP
      for(i=0; i<1 ; i=i+1)
      begin
        load_mode(`MR2_REG, `GRM.mr2[i]);
        load_mode(`MR3_REG, `GRM.mr3[0]);
        load_mode(`MR1_REG, `GRM.mr1[i]);    // enable DLL
      end
      `GRM.mr0[8] = 1'b1;
      load_mode(`MR0_REG, `GRM.mr0);    // reset DLL
      precharge_all(`ALL_RANKS);
      refresh;
      refresh;
      `GRM.mr0[8] = 1'b0;
      load_mode(`MR0_REG, `GRM.mr0);    // MR0 parameters (DLL reset removed)
      sdram_nops(`tDLLK);           // wait DLL lock to first instruction
        `GRM.mr1[0][9:7] = 3'b111;
        load_mode(`MR1_REG, `GRM.mr1[0]);    // OCD default
        `GRM.mr1[0][9:7] = 3'b000;
        load_mode(`MR1_REG, `GRM.mr1[0]);    // OCD exit
    end
  endtask // initialize_ddr2_sdram

  // LPDDR2/3 DRAM initialization
  task initialize_lpddrx_sdram;
  integer i;
    begin
      if (pCHANNEL_NO == 0) begin
`ifdef FULL_SDRAM_INIT
     sdram_nops(`tDINIT0_c/`CLK_NX); // tDINIT0 high to first instruction
     load_mode_lpddrx(8'h3F, 8'h00);
     nops(`tDINIT2_c/`CLK_NX); //tINIT5
     load_mode_lpddrx(8'h0A, 8'hFF);
     nops(`tDINIT3_c/`CLK_NX); //tZQINIT
     load_mode_lpddrx(8'h01, `GRM.mr1[0]);

   //For LPDDR3 the tMRW value is 10... So adding 4 more cycles to meet the protocol
   `ifdef LPDDR3
     nops(4);
   `endif 
     load_mode_lpddrx(8'h02, `GRM.mr2[0]);    

   //For LPDDR3 the tMRW value is 10... So adding 4 more cycles to meet the protocol
   `ifdef LPDDR3
     nops(4);
   `endif 
     for(i=0; i<1 ; i=i+1)
     begin 
       load_mode_lpddrx(8'h03, `GRM.mr3[i]);
     end
`else
     sdram_nops(`GRM.tdinitckehi/`CLK_NX); // tDINIT0 high to first instruction
     load_mode_lpddrx(8'h3F, 8'h00);
     nops(`GRM.tdinitrst/`CLK_NX); //tINIT5
     load_mode_lpddrx(8'h0A, 8'hFF);
     nops(`GRM.tdinitzq/`CLK_NX); //tZQINIT 
     load_mode_lpddrx(8'h01, `GRM.mr1[0]);

    //For LPDDR3 the tMRW value is 10... So adding 4 more cycles to meet the protocol
    `ifdef LPDDR3
       nops(4);
    `endif
    load_mode_lpddrx(8'h02, `GRM.mr2[0]);  
 
    //For LPDDR3 the tMRW value is 10... So adding 4 more cycles to meet the protocol 
    `ifdef LPDDR3
       nops(4);
    `endif
     for(i=0; i<1 ; i=i+1)
     begin 
       load_mode_lpddrx(8'h03, `GRM.mr3[i]);
     end 

`endif
    end
    end
  endtask // initialize_lpddrx_sdram

`ifdef STATIC_AFTER_INIT
  task enable_static_read_mode;
  begin
    // SRDRESP workaround
    if (issue_srdresp == 1'b1) begin
      // clear the flag
      issue_srdresp = 1'b0;

`ifdef FIFO_BYP_AFTER_INIT
      // issue CFG write to set PRFBYP mode
      `GRM.pgcr3[24] = 1'b1;
`endif

      `SYS.static_read_train(2'b01);
      
    end
  end
  endtask // enable_static_read_mode
`endif

  // [RESET SDRAM] Used to re-initialize sdram
  task reset_sdram;
 
  input [pRANK_WIDTH - 1:0]  rank; 
  integer i;
  begin
  sdram_nops(100 * `GRM.tdinitckehi/`CLK_NX ); // tDINIT0 high to first instruction
  load_mode_lpddrx_rankx(rank,8'h3F, 8'h00);
  sdram_nops(`GRM.tdinitrst/`CLK_NX ); //tINIT5
  load_mode_lpddrx_rankx(rank,8'h0A, 8'hFF);
  sdram_nops(`GRM.tdinitzq/`CLK_NX); //tZQINIT
  nops(`GRM.tdinitzq/`CLK_NX); //tZQINIT
  for(i=0; i<`DWC_NO_OF_RANKS ; i=i+1)
    load_mode_lpddrx_rankx(rank,8'h01, `GRM.mr1[i]);
  sdram_nops(12); //tZQINIT
  
`ifdef LPDDR3
  nops(12);
`endif 
  for(i=0; i<`DWC_NO_OF_RANKS ; i=i+1)
    load_mode_lpddrx_rankx(rank,8'h02, `GRM.mr2[i]);  
  
`ifdef LPDDR3
  nops(12);
`endif
  for(i=0; i<`DWC_NO_OF_RANKS ; i=i+1)
    load_mode_lpddrx_rankx(rank,8'h03, `GRM.mr3[i]);
  sdram_nops(12);
  end
  endtask //[RESET SDRAM]
  
 // [ MRW] # Load mode to a specific rank
 task load_mode_lpddrx_rankx; // load_mode_lpddrx_rankx
  input [pRANK_WIDTH - 1:0]  rankx;
  input [7:0] addr;
  input [7:0]  data;
  begin
      if (`DWC_NO_SRA == 1) begin
        a_i = {16'h0000,data,addr};
        a_i[pHOST_ADDR_RANK_BIT_HI:pHOST_ADDR_RANK_BIT_LO] = rankx;
        execute_command(`LOAD_MODE);
     end
     else begin
      //Functional coverage
      a_i = {16'h0000,data,addr};
      execute_command(`LOAD_MODE);
  end
  end
endtask //[ MRW]

  task set_cmd_mode;
    begin
        `ifdef DWC_DDRPHY_HDR_MODE  
          `ifdef MSD_RND_HDR_ODD_CMD
                hdr_odd_cmd = {$random} % 2;
          `elsif MSD_HDR_ODD_CMD
              // For channel 0, default is using hoc mode
              // For channel 1, default is using hec mode
              if (pCHANNEL_NO == 0)
                hdr_odd_cmd = 1'b1;
              else
                hdr_odd_cmd = 1'b0;
          `else
              // For channel 0, default is using hec mode
              // For channel 1, default is using hoc mode
              if (pCHANNEL_NO == 0)
                hdr_odd_cmd = 1'b0;
              else
                hdr_odd_cmd = 1'b1;
          `endif
        `else
              hdr_odd_cmd = 1'b0;
        `endif  
        
        `ifdef MSD_RND_HDR_ODD_CMD
              hdr_odd_cmd = {$random} % 2;
        `endif
        
        `ifndef DWC_USE_SHARED_AC_TB
              // Issue 2T cmd on even slot (first half started on ODD slot).
              if (`DWC_2T_MODE == 1)
                hdr_odd_cmd = 1'b0;
        `endif      
    end
 endtask  
endmodule // host_bfm
