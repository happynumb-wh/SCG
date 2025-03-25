/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Host Bus Monitor                                              *
 *              Monitors the interface bus between the DDR host and the       *
 *              DDR controller host port                                      *
 *                                                                            *
 *****************************************************************************/

module host_mnt
 #(
   // configurable design parameters
   parameter pDATA_WIDTH  = `DATA_WIDTH,
   parameter pBYTE_WIDTH  = `BYTE_WIDTH,
   parameter integer        pCHANNEL_NO  = 0
  )
  (
   rst_b,     // asynshronous reset
   clk,       // clock
   rqvld,     // host port request valid
   cmd,       // host port command bus
   a,         // host port read/write address
   dm,        // host port data mask
   d,         // host port data input
   cmd_flag,  // host port command flag
   rdy,       // host port ready
   qvld,      // host port read output valid
   q          // host port read data output
   );

  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  // loopback FIFO widths and depths
  parameter LB_FIFO_DEPTH = 256;
  parameter LB_DATA_WIDTH = 34;
  parameter LB_FIFO_WIDTH = LB_DATA_WIDTH;

  
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input     rst_b;     // asynshronous reset
  input     clk;       // clock
  input     rqvld;     // host port request valid
  input [`CMD_WIDTH-1:0] cmd;       // host port command bus
  input [`HOST_ADDR_WIDTH-1:0] a;         // host port read/write address
  input [pBYTE_WIDTH*`DWC_DX_NO_OF_DQS-1:0]      dm;        // host port data mask
  input [pDATA_WIDTH-1:0]      d;         // host port data input
  input                        cmd_flag;  // host port command flag
  input                        rdy;       // host port ready
  input                        qvld;      // host port read output valid
  input [pDATA_WIDTH-1:0]      q;         // host port read data output
  
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [31:0]                   op;
  reg [31:0]                   wr_op;
  reg [31:0]                   dout_op;
  
  wire [3:0]                   burst_len;    // chip logic burst length (max = 4)
  reg [3:0]                    rw_burst_len;
  
  reg                          all_banks_closed;
  
  reg                          mnt_en;
  reg                          nop_mnt_en;
  reg                          undf_mnt_en;
  reg                          lb_mnt_en;
  reg                          grm_cmp_en;

  reg [31:0]                   nop_cnt;
  integer                      rw_burst_cnt;
  integer                      rd_burst_cnt;  
  reg                          bl4_otf;
  reg                          grm_cmd_flag;

  reg [LB_FIFO_WIDTH-1:0]      lb_fifo [0: LB_FIFO_DEPTH-1];
  reg [8:0]                    lb_fifo_wrptr;
  reg [8:0]                    lb_fifo_rdptr;
  reg [LB_DATA_WIDTH-1:0]      lb_data;
  reg [LB_DATA_WIDTH-1:0]      xpctd_lb_data;
  reg [15:0]                   prev_ctl_ck;
  
  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize
      mnt_en           = 0;
      nop_mnt_en       = 0;
      undf_mnt_en      = 0;
      lb_mnt_en        = 1;
      grm_cmp_en       = 0;
      nop_cnt          = 0;
      rw_burst_cnt     = 0;
      rd_burst_cnt     = 0;
      all_banks_closed = 1'b1;
      lb_fifo_wrptr    = 0;
      lb_fifo_rdptr    = 0;
      prev_ctl_ck      = 16'h0000;
    end

  assign burst_len = `GRM.ctrl_burst_len;
  
  
  //---------------------------------------------------------------------------
  // Command Monitor
  //---------------------------------------------------------------------------
  // monitors the commands being sent to the DDR controller
  always @(posedge clk)
    begin: command_monitor
      reg [`HOST_ADDR_WIDTH-1:0] addr;

      if (mnt_en === 1'b1)
        begin
          // decode command
          // all 4 bits are fully populated - so no need for exact decoding
          op = (valid_bus(cmd)) ? cmd : `BAD_MEM_OP;

          if (rqvld === 1'b1 && rdy === 1'b1)
            begin
              // command requested and accepted
              if (op === `CTRL_NOP || op === `SDRAM_NOP)
                begin
                  if (nop_mnt_en) nop_cnt = nop_cnt + 1;
                end
              else
                begin
                  // report previous NOPs
                  if (nop_mnt_en == 1'b1 && nop_cnt > 0)
                    begin
                      if (pCHANNEL_NO == 0)
                        `SYS.message(`CHIP_CTRL, `CTRL_NOP, {1'b1, nop_cnt});
                      else
                        `SYS.message(`CHIP_CTRL_1, `CTRL_NOP, {1'b1, nop_cnt});
                      nop_cnt = 0;
                    end
                  
                  // report current operation
                  if (rw_burst_cnt > 0)
                    begin
                      case (op)
                        `SDRAM_WRITE:  wr_op = `WRITE_BRST;
                        `WRITE_PRECHG: wr_op = `WRITE_PRECHG_BRST;
                        `SDRAM_READ:   wr_op = (`FULL_RDTIMING) ?
                                               `READ_BRST : op;
                        `READ_PRECHG:  wr_op = (`FULL_RDTIMING) ?
                                               `READ_PRECHG_BRST : op;
                        default:       wr_op = op;
                      endcase // case(op)
                    end
                  else
                    begin
                      wr_op = op;
                    end
                  
                  // check whether all banks are closed so that power-down can
                  // be reported correctly
                  case (op)
                    `SDRAM_WRITE,
                    `WRITE_PRECHG,
                    `SDRAM_READ,
                    `READ_PRECHG:   all_banks_closed = 1'b0;
                    `PRECHARGE_ALL: all_banks_closed = 1'b1;
                  endcase // case(op)

                  addr = a;
                  if (op == `POWER_DOWN) addr[0] = all_banks_closed;
`ifdef DWC_USE_SHARED_AC_TB
                    if (pCHANNEL_NO == 0)
                      `SYS.message(`CHIP_CTRL,   wr_op, {d, {`HOST_DQS_WIDTH-(pBYTE_WIDTH*`DWC_DX_NO_OF_DQS){1'b0}}, dm, addr});
                    else
                      `SYS.message(`CHIP_CTRL_1, wr_op, {d, {`HOST_DQS_WIDTH-(pBYTE_WIDTH*`DWC_DX_NO_OF_DQS){1'b0}}, dm, addr});
`else
                  `SYS.message(`CHIP_CTRL, wr_op, {d, dm, addr});
`endif
                  bl4_otf = cmd_flag;
                  rw_burst_len = (bl4_otf) ? 2/`CLK_NX : burst_len;
                  if (undf_mnt_en == 1'b1) check_undefined_values(op);

                  // if comparison with GRM is enabled in the monitor, 
                  // write to the GRM.
                  if (grm_cmp_en == 1'b1)
                    begin
                      case (op)
                        `SDRAM_WRITE,
                        `WRITE_PRECHG: `GRM.write(addr, dm, d, rw_burst_cnt);
                        `SDRAM_READ,
                        `READ_PRECHG:  `GRM.read(addr, rw_burst_cnt, cmd_flag, pCHANNEL_NO, `SDRAM_READ);
                      endcase // case(op)
                    end
                  
                  // increment write burst count
                  if ((op === `SDRAM_WRITE || op === `WRITE_PRECHG) ||
                      ((op === `SDRAM_READ || op === `READ_PRECHG) &&
                       `FULL_RDTIMING))
                    begin
                      rw_burst_cnt = (rw_burst_cnt == (rw_burst_len-1)) ?
                                     0 : rw_burst_cnt + 1;
                    end
                end // else: !if(op === `CTRL_NOP)
            end // if (rqvld === 1'b1 && rdy === 1'b1)

          // report errors and warnings
          report_errors;
        end // if (mnt_en === 1'b1)
      
    end // block: command_monitor
  
  
  //---------------------------------------------------------------------------
  // Output Monitor
  //---------------------------------------------------------------------------
  // monitors the data being output by the controller, including read data and
  // write tags; also check undefined values
  // comparison with GRM is normally done in BFM, unless specifically 
  // configured to do the comparison in the monitor; 
  always @(posedge clk or negedge rst_b)
    begin: output_monitor
      reg [pDATA_WIDTH-1:0] grm_q;
      reg [3:0]             grm_burst_len;
      
      if (mnt_en === 1'b1)
        begin
          // read output monitor
          if (qvld === 1'b1 && `SYS.scan_ms === 1'b0)
            begin
              // DEBUG NOTE: this line used to be a tertiary operator (see below), but was giving
              // x's on the 2nd clock of qvld.  dout_op can never get x's since DATA_OUT and DATA_OUT_BRST
              // are defines in the dictionary.v.  Changed to if()/else structure and I'm not seeing the x's.
              if(rd_burst_cnt == 0) begin
                dout_op = `DATA_OUT;
              end else begin
                dout_op = `DATA_OUT_BRST;
              end
              // dout_op = (rd_burst_cnt == 0) ? `DATA_OUT : `DATA_OUT_BRST;

              if (pCHANNEL_NO == 0)
                `SYS.message(`CHIP_CTRL, dout_op, q);
              else
                `SYS.message(`CHIP_CTRL_1, dout_op, q);

              if (undf_mnt_en == 1'b1) check_undefined_values(`DATA_OUT);

              // comparison with GRM is done in the monitor
              if (grm_cmp_en == 1'b1)
                begin
`ifdef DWC_USE_SHARED_AC_TB
                  `GRM.get_read_data(pCHANNEL_NO, grm_q, grm_cmd_flag);
`else
                  `GRM.get_read_data(`NON_SHARED_AC, grm_q, grm_cmd_flag);
`endif

                  grm_burst_len = (grm_cmd_flag) ? 2/`CLK_NX : burst_len;
                  if (q !== grm_q)
                    begin
                    `ifdef SOFT_Q_ERRORS   //added by Jose for jitter testing
		      `ifdef PROBE_DATA_EYES
                      `EYE_MNT.jitter_error_counter = `EYE_MNT.jitter_error_counter + 1 ;
		      `endif
                    `else  
                      if (pCHANNEL_NO == 0)
                        `SYS.error_message(`CHIP_CTRL, `QERR, grm_q);
                      else
                        `SYS.error_message(`CHIP_CTRL_1, `QERR, grm_q);
                    `endif  
                    end

                  // keep track of how many read data have been received
                  `GRM.log_host_read_output;
                end
              else
                begin
                  // expected data is popped using the BFM
                  #0.01;
                  grm_burst_len = `GRM.get_burst_length(`MSD_READ);
                end

              // increment read burst count
              rd_burst_cnt = (rd_burst_cnt == (grm_burst_len-1)) ?
                             0 : rd_burst_cnt + 1;
            end // if (qvld === 1'b1)
          else
            begin
              // reste rd_burst_cnt if qvld is finished
              rd_burst_cnt = 0;
            end // else: !if(qvld === 1'b1)
        end // if (mnt_en === 1'b1)
    end // block: output_monitor

  
  //---------------------------------------------------------------------------
  // AC Loopback Monitor
  //---------------------------------------------------------------------------
  // monitors the loopback interface between the controller and the PHY and
  // checks if the returning data for the loopback is correct
  
`ifndef DWC_DDRPHY_EMUL_XILINX //Disable loopback monitor for XILINX emulation; Gate_Level doesn't have these signals

  always @(posedge clk)
    begin: ac_lb_monitor
      reg  [8:0] lb_fifo_rdptr_rvsd;
      
      if (`GRM.lb_mode && lb_mnt_en)
        begin
          // log in the commands going to the PHY
          if ((`AC.rst_n == 1) &&
              (`PHY.ctl_lb_en[0] || `PHY.ctl_lb_en[1]) && 
              (`PHY.ctl_ck == 16'hAAAA || `PHY.ctl_ck == 16'h5555))
            begin
              lb_fifo[lb_fifo_wrptr+0] = {`PHY.ctl_cke[`DWC_NO_OF_RANKS-1:0],
                                          `PHY.ctl_odt[`DWC_NO_OF_RANKS-1:0],
                                          `PHY.ctl_cs_n[`DWC_NO_OF_RANKS-1:0],
                                          `PHY.ctl_ba[`DWC_BANK_WIDTH-1:0],
                                          `PHY.ctl_a[`DWC_ADDR_WIDTH-1:0]
                                          };
              lb_fifo[lb_fifo_wrptr+1] = {`PHY.ctl_cke[`DWC_NO_OF_RANKS*2-1:`DWC_NO_OF_RANKS],
                                          `PHY.ctl_odt[`DWC_NO_OF_RANKS*2-1:`DWC_NO_OF_RANKS],
                                          `PHY.ctl_cs_n[`DWC_NO_OF_RANKS*2-1:`DWC_NO_OF_RANKS],
                                          `PHY.ctl_ba[`DWC_BANK_WIDTH*2-1:`DWC_BANK_WIDTH],
                                          `PHY.ctl_a[`DWC_ADDR_WIDTH*2-1:`DWC_ADDR_WIDTH]
                                          };

              lb_fifo_wrptr = (lb_fifo_wrptr < (LB_FIFO_DEPTH-2)) ? 
                              lb_fifo_wrptr + 2 : 0;
            end
          else
            begin
              lb_fifo_wrptr = 0;
            end

          // log in the loopback data coming back to the PHY and compare with expected
          // data
          if (`PHY.ac_phy_qvld)
            begin
              lb_data  = {`PHY.phy_cke,
                          `PHY.phy_odt,
                          `PHY.phy_cs_n,
                          `PHY.phy_ba,
                          `PHY.phy_a};

              lb_fifo_rdptr_rvsd = (lb_fifo_rdptr + `GRM.lb_sel + 2) % LB_FIFO_DEPTH;
              xpctd_lb_data = lb_fifo[lb_fifo_rdptr_rvsd];
              lb_fifo_rdptr = (lb_fifo_rdptr < (LB_FIFO_DEPTH-4)) ? 
                              lb_fifo_rdptr + 4 : 0;

              $display ("-> %0t: [ACLB] Data out = %h", $realtime, lb_data);

              // check data
              if (lb_data !== xpctd_lb_data)
                begin
                  `SYS.error_message(`CTRL_ACLB, `ACLBERR, xpctd_lb_data);
                end
            end
        end // if (`GRM.lb_mode && lb_mnt_en)
    end // block: ac_lb_monitor

  // AC read fifo pointer reset at the beginning of loopback mode test
  always @(posedge `PHY.ctl_clk)
    begin: ac_lb_rdfifo_reset
      if (lb_mnt_en)
        begin
          // log the previous value of ctl_ck to use for detecting start of
          // loopback testing
          prev_ctl_ck <= `PHY.ctl_ck;

          // reset read pointer at the start of loopback testing
          if ((prev_ctl_ck == 16'h0000) &&
              (`PHY.ctl_ck == 16'hAAAA || `PHY.ctl_ck == 16'h5555))
            begin
              lb_fifo_rdptr = 0;
            end
        end
    end
`endif

  
  //---------------------------------------------------------------------------
  // Errors and Warnings
  //---------------------------------------------------------------------------
  // reports errors and warnings
  task report_errors;
    begin
      
      // check that command write command is constant during burst
      // TBD
    end
  endtask // report_errors


  // check undefined values
  // ----------------------
  // checks and reports undefined values on buses
  task check_undefined_values;
    input [31:0] op;
    begin
      if (pCHANNEL_NO == 0) begin
        if (!valid_bus(cmd)) `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `CMD_PIN);

        if (op === `SDRAM_WRITE || op === `WRITE_PRECHG)
          begin
            if (!valid_bus(dm))  `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `DM_PIN);
            if (!valid_bus(d))   `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `D_PIN);
            if (!valid_bus(a))   `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `A_PIN);
          end
      
        if (op === `SDRAM_READ || op === `READ_PRECHG || op == `ACTIVATE)
          begin
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `A_PIN);
          end          
      
        if (op === `PRECHARGE)
          begin
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `A_PIN);
          end
      
        if (op === `LOAD_MODE || op === `READ_MODE)
          begin
            if (!valid_bus(d)) `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `D_PIN);
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `A_PIN);
          end
      
        if (op === `POWER_DOWN)
          begin
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `A_PIN);
          end

        if (op === `DATA_OUT)
          begin
            if (!valid_bus(q))    `SYS.error_message(`CHIP_CTRL, `DATAXWARN, `Q_PIN);
          end
      end

      // CHANNEL NO 1
      else begin
        if (!valid_bus(cmd)) `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `CMD_PIN);

        if (op === `SDRAM_WRITE || op === `WRITE_PRECHG)
          begin
            if (!valid_bus(dm))  `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `DM_PIN);
            if (!valid_bus(d))   `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `D_PIN);
            if (!valid_bus(a))   `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `A_PIN);
          end
        
        if (op === `SDRAM_READ || op === `READ_PRECHG || op == `ACTIVATE)
          begin
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `A_PIN);
          end          
        
        if (op === `PRECHARGE)
          begin
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `A_PIN);
          end
        
        if (op === `LOAD_MODE)
          begin
            if (!valid_bus(d)) `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `D_PIN);
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `A_PIN);
          end
        
        if (op === `POWER_DOWN)
          begin
            if (!valid_bus(a)) `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `A_PIN);
          end

        if (op === `DATA_OUT)
          begin
            if (!valid_bus(q))    `SYS.error_message(`CHIP_CTRL_1, `DATAXWARN, `Q_PIN);
          end
      end
    end
  endtask // check_undefined_values
  
  
  // valid bus/bit
  // -------------
  // checks if a variable or signal bus/bit has x's or z's
  function valid_bus;
    input [pDATA_WIDTH-1:0] the_bus;
    begin
      valid_bus = (^(the_bus) !== 1'bx);
    end
  endfunction // valid_bus

  function valid_bit;
    input the_bit;
    begin
      valid_bit = (the_bit !== 1'bx && the_bit !== 1'bz);
    end
  endfunction // valid_bit
  
endmodule // host_mnt
