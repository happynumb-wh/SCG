/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys. All rights reserved.                          *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: JTAG PORT Functional Model                                    *
 *              This module provides the translation from cfg read write      *
 *              request to JTAG instructions to PUB/PHY                       *
 *                                                                            *
 *****************************************************************************/

`timescale 1ns/1ps

module jtag_bfm
  (
   // configuration register Interface
   cfg_clk,
   cfg_rst_n,
   jtag_en,
   cfg_rqvld,
   cfg_cmd,
   cfg_a,
   cfg_d,
   cfg_q,
   cfg_qvld,

   // JTAG port interface (tclk is same clock as cfg_clk)
   trst_n,
   tclk,
   tms,
   tdi,
   tdo
  );
  
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter pTAP_DATA_WIDTH     = `DR_FIELD_DATA_WIDTH + `DR_FIELD_ADDR_WIDTH + `DR_FIELD_INSTR_WIDTH;
  parameter pMAX_TAP_FIFO_DEPTH = 8;
  parameter pTAP_FIFO_BITS      = 3;

  parameter pNOP_INSTR           = 2'b00;
  parameter pREAD_INSTR          = 2'b01;
  parameter pWRITE_INSTR         = 2'b10;
  parameter pPOP_READ_DATA_INSTR = 2'b11;
  

  // TAP Controller State Machine
  localparam pTAP_STATE_WIDTH   = 4;
  localparam pTAP_EXIT_2_DR     = 0,
             pTAP_EXIT_1_DR     = 1,
             pTAP_SHIFT_DR      = 2,
             pTAP_PAUSE_DR      = 3,
             pTAP_SEL_IR_SCAN   = 4,
             pTAP_UPDATE_DR     = 5,
             pTAP_CAPTURE_DR    = 6,
             pTAP_SEL_DR_SCAN   = 7,
             pTAP_EXIT_2_IR     = 8,
             pTAP_EXIT_1_IR     = 9,
             pTAP_SHIFT_IR      = 10,
             pTAP_PAUSE_IR      = 11,
             pTAP_RUN_TST_IDLE  = 12,
             pTAP_UPDATE_IR     = 13,
             pTAP_CAPTURE_IR    = 14,
             pTAP_TST_LG_RESET  = 15;

  
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  // configuration register Interface
  input                        cfg_clk;
  input                        cfg_rst_n;
  input                        jtag_en;
  input                        cfg_rqvld;
  input                        cfg_cmd;
  input  [`REG_ADDR_WIDTH-1:0] cfg_a;
  input  [`REG_DATA_WIDTH-1:0] cfg_d;
  output reg [`REG_DATA_WIDTH-1:0] cfg_q;
  output reg                       cfg_qvld;

  // JTAG port interface (tclk is same clock as cfg_clk)
  output wire                  trst_n;
  input  wire                  tclk;
  output reg                   tms;
  input  wire                  tdi;
  output reg                   tdo;
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [`REG_DATA_WIDTH-1:0]    tap_data;
  reg [`REG_ADDR_WIDTH-1:0]    tap_addr;
  reg [1:0]                    tap_instr;

  
//reg [pTAP_DATA_WIDTH-1:0]    tap_reg     [0:pMAX_TAP_FIFO_DEPTH-1];
  reg [pTAP_DATA_WIDTH-1:0]    tap_reg;
  reg [pTAP_DATA_WIDTH-1:0]    tap_data_reg;
  reg [`DW_TAP_IR_WIDTH-1:0]   ir_reg;
  reg [`DW_TAP_IR_WIDTH-1:0]   default_ir_value;

  reg [`REG_DATA_WIDTH-1:0]    read_data;

  reg                          jtag_qvld;
  reg [`REG_DATA_WIDTH-1:0]    jtag_q;
  
  reg [pTAP_FIFO_BITS-1:0]     wrptr, rdptr, wrtmp, rdtmp;
  integer                      bit_i;
  reg                          cmd_in_progress;

  reg [pTAP_STATE_WIDTH-1:0]   tap_state;
  
  
  //---------------------------------------------------------------------------
  // CFG-to-JTAG Transalation
  //---------------------------------------------------------------------------
  // NOTE: it is asumed that the CFG BFM will always put a NOP after an
  //       instruction when APB port is enabled (this is done in the CFG BFM)

  initial
    begin
      // The only instruction we ever need to shift into the IR (of the DW_tap)
      // one that is not any of the standard IEEE ones.  DW_tap uses 'b00 -> 'b11.
      default_ir_value                       = {`DW_TAP_IR_WIDTH{1'b0}};
      default_ir_value[`DW_TAP_IR_WIDTH - 1] = 1'b1;
      ir_reg    = default_ir_value;
      tap_state = pTAP_TST_LG_RESET;
      cmd_in_progress = 1'b0;
      tms = 1'b1;
      tdo = 1'bz;
      bit_i = 0;
    end
  
  assign trst_n = cfg_rst_n;
  
  
  always @(posedge cfg_clk or negedge cfg_rst_n) begin
    if ((cfg_rst_n == 1'b0) || (jtag_en == 1'b0)) begin
      tap_data  <= {`REG_DATA_WIDTH{1'b0}};
      tap_addr  <= {`REG_ADDR_WIDTH{1'b0}};
      tap_instr <= {2{1'b0}};
      tap_reg   <= {pTAP_DATA_WIDTH{1'b0}};
    end 
    else begin
      if ((cfg_rqvld) && ~(cmd_in_progress)) begin
        tap_addr <= cfg_a;
        
        if (cfg_cmd == 1'b1) begin
          tap_data  <= cfg_d;
          tap_instr <= 2'b10;
          tap_reg   <= {cfg_d, cfg_a, pWRITE_INSTR};
          t_write_request;
        end
        else begin
          tap_data  <= {`REG_DATA_WIDTH{1'bz}};
          tap_instr <= 2'b01;
          tap_reg   <= {cfg_d, cfg_a, pREAD_INSTR};
          t_read_request;
        end
      end
    end
  end


  always @(posedge cfg_clk or negedge cfg_rst_n) begin
    if ((cfg_rst_n == 1'b0) || (jtag_en == 1'b0)) begin
      jtag_qvld = 0;
      jtag_q    = {`REG_DATA_WIDTH{1'bz}};
    end
    else begin
      if (jtag_qvld == 1) begin
        cfg_qvld <= 1'b1;
        cfg_q    <= jtag_q;
        jtag_qvld <= 0;
        jtag_q    <= {`REG_DATA_WIDTH{1'bz}};
      end
      else begin
        cfg_qvld <= 1'b0;
        cfg_q    <= {`REG_DATA_WIDTH{1'bz}};
        jtag_qvld <= jtag_qvld;
        jtag_q    <= jtag_q;
      end        
    end
  end

  
  //---------------------------------------------------------------------------
  //  Task for writing the Instruction Register with a non-IEEE defined
  //  instruction value so we can access the DR
  //---------------------------------------------------------------------------
  task t_set_IR_for_DR_access;
    begin
      ir_reg          = default_ir_value;
      cmd_in_progress = 1'b1;

      // check to see if tap_state is in pTAP_TST_LG_RESET
      if (tap_state != pTAP_TST_LG_RESET) begin
        t_clear_tap_controller_state;
      end

      t_reset_to_run_test_idle;
      t_run_test_idle_to_sel_DR;
      t_sel_DR_to_sel_IR;
      t_sel_IR_to_capture_IR;

      t_capture_IR_to_shift_IR;

      // shift out the whole instruction with address and data
      t_shift_IR_whole_instr;

      t_shift_IR_to_exit_1_IR_whole_instr;

      t_exit_1_IR_to_pause_IR;
      t_pause_IR_to_exit_2_IR;
      t_exit_2_IR_to_update_IR;
      t_update_IR_to_run_test_idle;

      cmd_in_progress = 1'b0;
    end
  endtask


  //---------------------------------------------------------------------------
  //  Task for Write Register Request
  //---------------------------------------------------------------------------
  task t_write_request;
    begin
      cmd_in_progress = 1'b1;

      t_run_test_idle_to_sel_DR;
      t_sel_DR_to_capture_DR;

      t_capture_DR_to_shift_DR;

      // shift out the whole instruction with address and data
      for (bit_i=pTAP_DATA_WIDTH-1; bit_i>0; bit_i=bit_i-1)
        t_shift_DR_whole_tap_data;

      t_shift_DR_to_exit_1_DR_whole_tap_data;

      t_exit_1_DR_to_update_DR;
      t_update_DR_to_run_test_idle;

      cmd_in_progress = 1'b0;
    end
  endtask // t_write_request
  

  //---------------------------------------------------------------------------
  //  Task for Read Register Request
  //---------------------------------------------------------------------------
  task t_read_request;
    begin

      cmd_in_progress = 1'b1;

      jtag_qvld = 0;
      jtag_q    = {`REG_DATA_WIDTH{1'bz}};
      t_run_test_idle_to_sel_DR;
      t_sel_DR_to_capture_DR;

      t_capture_DR_to_shift_DR;
      
      // shift out instruction with address + read instr only
      for (bit_i=pTAP_DATA_WIDTH-1; bit_i>0; bit_i=bit_i-1)
        t_shift_DR_whole_tap_data;
      t_shift_DR_to_exit_1_DR_whole_tap_data;

      // go to Update state so that Tap controller on the other side will
      // accept the read request
      t_exit_1_DR_to_update_DR;
      t_update_DR_to_run_test_idle;

      // add extra wait here for the cfg to get the register data back
      if (`CFG_CLK_PRD > `XCLK_PRD)
        repeat (`JTAG_RD_LAT * 10) t_run_test_idle;
      else
        repeat (`JTAG_RD_LAT) t_run_test_idle;
      t_run_test_idle_to_sel_DR;

      // Now rdfifo should have the data ready
      t_sel_DR_to_capture_DR;
      t_capture_DR_to_shift_DR_rdfifo_no_addr_no_instr;
      
      // shift in read data
      for (bit_i=pTAP_DATA_WIDTH-1; bit_i>0; bit_i=bit_i-1)
        t_shift_DR_read_data;

      t_shift_DR_to_exit_1_DR_read_data;
      t_exit_1_DR_to_update_DR_read_data;
      
      t_update_DR_to_run_test_idle;
      cmd_in_progress = 1'b0;
    end
  endtask // t_read_request
  

  //---------------------------------------------------------------------------
  //  Task to put TAP controller back to Test Logic Reset state
  //---------------------------------------------------------------------------
  task t_clear_tap_controller_state;
    integer i;
    begin
      // set tms for 5 consecutive high to bring the tap controller state to pTAP_TST_LG_RESET 
      for (i=0;i<5;i=i+1) begin
        @(negedge tclk);
        tms = 1'b1;
      end
      tap_state = pTAP_TST_LG_RESET;
    end
  endtask // t_clear_tap_controller_state
  

  //---------------------------------------------------------------------------
  //  Task for setting up tms, tdo and reading in from tdi
  //  tap_state indicates the current state
  //     NB: none of the IR states were used here
  //---------------------------------------------------------------------------
  task t_reset_to_run_test_idle;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_RUN_TST_IDLE;
    end
  endtask
    
  task t_run_test_idle;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_RUN_TST_IDLE;
    end
  endtask // t_run_test_idle
 
  task t_run_test_idle_to_sel_DR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_SEL_DR_SCAN;
    end
  endtask // t_run_test_idle_to_sel_DR
  
  task t_sel_DR_to_capture_DR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_CAPTURE_DR;
    end
  endtask // t_sel_DR_to_capture_DR
  
  task t_capture_DR_to_shift_DR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      tap_data_reg = tap_reg[pTAP_DATA_WIDTH-1:0];    // Read in to TDR at negedge
      
      @(posedge tclk);
      tap_state = pTAP_SHIFT_DR;
    end
  endtask // t_capture_DR_to_shift_DR
  
  task t_capture_DR_to_shift_DR_rdfifo_no_addr_no_instr;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      tap_data_reg = {pTAP_DATA_WIDTH{1'b0}};    // Read in to TDR at negedge
      tap_data_reg[1:0] = pNOP_INSTR;            // the addr and instr bits are not sent during read
      read_data = {`REG_DATA_WIDTH{1'bz}};
 
      @(posedge tclk);
      tap_state = pTAP_SHIFT_DR;               
    end
  endtask // t_capture_DR_to_shift_DR_rdfifo_no_addr_no_instr
  
  task t_shift_DR_whole_tap_data;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = tap_data_reg[0];                // Output to tdo whole tap data
      tap_data_reg                    = tap_data_reg >> 1;
      tap_data_reg[pTAP_DATA_WIDTH-1] = tdi;
      
      @(posedge tclk);
      tap_state = pTAP_SHIFT_DR;
    end
  endtask // t_shift_DR
  
  task t_shift_DR_read_data;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'b0;
      
      @(posedge tclk);
      tap_state = pTAP_SHIFT_DR;
      tap_data_reg = tap_data_reg >> 1;
      tap_data_reg[pTAP_DATA_WIDTH - 1] = tdi;
    end
  endtask // t_shift_DR_read_data

  task t_shift_DR_to_exit_1_DR_whole_tap_data;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = tap_data_reg[0];                // Output to tdo last data bit
      tap_data_reg                      = tap_data_reg >> 1;
      tap_data_reg[pTAP_DATA_WIDTH - 1] = tdi;
      
      @(posedge tclk);
      tap_state = pTAP_EXIT_1_DR;
    end
  endtask // t_shift_DR_to_exit_1_DR_whole_tap_data

  task t_shift_DR_to_exit_1_DR_read_data;
    reg [`DR_FIELD_ADDR_WIDTH  - 1 : 0] dummy_addr;
    reg [`DR_FIELD_INSTR_WIDTH - 1 : 0] dummy_instr;

    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'b0;
      
      @(posedge tclk);
      tap_state = pTAP_EXIT_1_DR;
      tap_data_reg                      = tap_data_reg >> 1;
      tap_data_reg[pTAP_DATA_WIDTH - 1] = tdi;
      {read_data, dummy_addr, dummy_instr} = tap_data_reg;
    end
  endtask // t_shift_DR_to_exit_1_DR_read_data
  
  task t_exit_1_DR_to_pause_DR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_PAUSE_DR;
    end
  endtask // t_exit_1_DR_to_pause_DR
  
  task t_exit_1_DR_to_update_DR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_UPDATE_DR;
    end
  endtask // t_exit_1_DR_to_update_DR

  task t_exit_1_DR_to_update_DR_read_data;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;

      jtag_qvld = 1'b1;
      jtag_q    = read_data;
      
      @(posedge tclk);
      tap_state = pTAP_UPDATE_DR;
    end
  endtask // t_exit_1_DR_to_update_DR

  task t_pause_DR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_PAUSE_DR;
    end
  endtask // t_pause_DR
  
  task t_pause_DR_to_exit_2_DR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_EXIT_2_DR;
    end
  endtask // t_pause_DR_to_exit_2_DR

  task t_exit_2_DR_to_shift_DR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_SHIFT_DR;
    end
  endtask // t_exit_2_DR_to_shift_DR

  task t_update_DR_to_run_test_idle;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_RUN_TST_IDLE;
    end
  endtask // t_update_DR_to_run_test_idle

  task t_update_DR_to_sel_DR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_SEL_DR_SCAN;
    end
  endtask // t_update_DR_to_sel_DR
  
  task t_sel_DR_to_sel_IR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_SEL_IR_SCAN;
    end
  endtask // t_sel_DR_to_sel_IR
  
  task t_sel_IR_to_test_lg_reset;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_TST_LG_RESET;
    end
  endtask // t_sel_IR_to_test_lg_reset
  
  task t_sel_DR_to_select_IR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_SEL_IR_SCAN;
    end
  endtask // t_sel_DR_to_select_IR
  
  task t_sel_IR_to_capture_IR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_CAPTURE_IR;
    end
  endtask // t_sel_IR_to_capture_IR

  task t_capture_IR_to_shift_IR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_SHIFT_IR;
    end
  endtask // t_capture_IR_to_shift_IR

  task t_shift_IR_whole_instr;

    integer bit_i;

    begin
      for (bit_i = `DW_TAP_IR_WIDTH - 1; bit_i > 0; bit_i = bit_i - 1) begin
        @(negedge tclk);
        tms       = 1'b0;
        tdo       = ir_reg[0]; // Output to tdo whole IR value
        ir_reg                       = ir_reg >> 1;
        ir_reg[`DW_TAP_IR_WIDTH - 1] = tdi;
      
        @(posedge tclk);
        tap_state = pTAP_SHIFT_IR;
      end
    end
  endtask // t_shift_IR_whole_instr

  task t_shift_IR_to_exit_1_IR_whole_instr;
    begin
      @(negedge tclk);
      tms       = 1'b1;
      tdo       = ir_reg[0];   // Output to tdo last data bit
      ir_reg                       = ir_reg >> 1;
      ir_reg[`DW_TAP_IR_WIDTH - 1] = tdi;
      
      @(posedge tclk);
      tap_state = pTAP_EXIT_1_IR;
    end
  endtask // t_shift_DR_to_exit_1_DR

  task t_exit_1_IR_to_pause_IR;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_PAUSE_IR;
    end
  endtask // t_exit_1_IR_to_pause_IR

  task t_pause_IR_to_exit_2_IR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_EXIT_2_IR;
    end
  endtask // t_pause_IR_to_exit_2_IR

  task t_exit_2_IR_to_update_IR;
    begin
      @(negedge tclk);
      tms = 1'b1;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_UPDATE_IR;
    end
  endtask // t_exit_2_IR_to_update_IR

  task t_update_IR_to_run_test_idle;
    begin
      @(negedge tclk);
      tms = 1'b0;
      tdo = 1'bz;
      @(posedge tclk);
      tap_state = pTAP_RUN_TST_IDLE;
    end
  endtask // t_update_IR_to_run_test_idle

endmodule // jtag_bfm

