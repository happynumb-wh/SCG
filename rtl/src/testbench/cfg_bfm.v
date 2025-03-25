/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys. All rights reserved.                          *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Configuration Bus Functional Model                            *
 *                                                                            *
 *****************************************************************************/

`timescale 1ns/1ps

module cfg_bfm (
                rst_b,             // asynshronous reset
                clk,               // clock
                rqvld,             // request valid
                cmd,               // command bus
                a,                 // address
                d,                 // data input
                qvld,              // data output valid
                q,                 // data output
                jtag_en,           // JTAG enable
                jtag_rqvld,        // JTAG request valid
                jtag_cmd,          // JTAG command bus
                jtag_a,            // JTAG address
                jtag_d,            // JTAG data input
                jtag_qvld,         // JTAG data output valid
                jtag_q             // JTAG data output
                );
  
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter port_no = 0;

  // Tmining Parameters
  // ------------------
  // Interface timing parameters (nanoseconds unless otherwise stated)
  parameter tCKL = (1.0 - `CLK_DCYC) * `TCLK_PRD*`CLK_NX;  // Clock Low Level Width
`ifdef DDR2
  parameter tAS  = 1.0,                               // address setup time
            tAH  = 0.2 + (`TCLK_PRD*`CLK_NX - tCKL),   // address hold time
            tCMS = 1.0,                               // command setup time
            tCMH = 0.2 + (`TCLK_PRD*`CLK_NX - tCKL),   // command hold time
            tDIS = 1.0,                               // data in setup time
            tDIH = 0.2 + (`TCLK_PRD*`CLK_NX - tCKL);   // data in hold time
`else
  parameter tAS  = 0.5,                               // address setup time
            tAH  = 0.1 + (`TCLK_PRD*`CLK_NX - tCKL),   // address hold time
            tCMS = 0.5,                               // command setup time
            tCMH = 0.1 + (`TCLK_PRD*`CLK_NX - tCKL),   // command hold time
            tDIS = 0.5,                               // data in setup time
            tDIH = 0.1 + (`TCLK_PRD*`CLK_NX - tCKL);   // data in hold time
`endif

  // Default Values
  // --------------
  // Default values driven on certain bus signals when not valid
  parameter DATA_DEFAULT   = {`REG_DATA_WIDTH{1'b0}},
            ADDR_DEFAULT   = {`REG_ADDR_WIDTH{1'b0}};

  // mode registers
  parameter MR0 = 3'b000;
  parameter MR1 = 3'b001;
  parameter MR2 = 3'b010;
  parameter MR3 = 3'b011;
  parameter MR4 = 3'b100;
  parameter MR5 = 3'b101;
  parameter MR6 = 3'b110;
  parameter MR7 = 3'b111;

  // DRAM initialization DCU data and mask width
  parameter DINIT_DATA_WIDTH = 32;
  parameter DINIT_BYTE_WIDTH = 4*`DWC_DX_NO_OF_DQS;
    
  parameter pNO_OF_DX_DQS     = `DWC_DX_NO_OF_DQS; // number of DQS signals per DX macro
  parameter pNUM_LANES        = pNO_OF_DX_DQS * `DWC_NO_OF_BYTES;

  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                        rst_b;      // asynshronous reset
  input                        clk;        // clock    

  output                       rqvld;      // request valid
  output [`REG_CMD_WIDTH -1:0] cmd;        // command bus
  output [`REG_ADDR_WIDTH-1:0] a;          // read/write address
  output [`REG_DATA_WIDTH-1:0] d;          // data input
  input                        qvld;       // data output valid
  input [`REG_DATA_WIDTH-1:0]  q;          // data output

  input                        jtag_en;    // JTAG enable
  output                       jtag_rqvld; // JTAG request valid
  output [`REG_CMD_WIDTH -1:0] jtag_cmd;   // JTAG command bus
  output [`REG_ADDR_WIDTH-1:0] jtag_a;     // JTAG read/write address
  output [`REG_DATA_WIDTH-1:0] jtag_d;     // JTAG data input
  input                        jtag_qvld;  // JTAG data output valid
  input  [`REG_DATA_WIDTH-1:0] jtag_q;     // JTAG data output
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                          temp;
  
  wire                         rqvld;
  wire [`REG_CMD_WIDTH -1:0]   cmd;
  wire [`REG_ADDR_WIDTH-1:0]   a;
  wire [`REG_DATA_WIDTH-1:0]   d;
  
  reg                          rqvld_i;
  reg [`REG_CMD_WIDTH-1:0]     cmd_i;
  reg [`REG_ADDR_WIDTH-1:0]    a_i;
  reg [`REG_DATA_WIDTH-1:0]    d_i;
  wire                         qvld_i;
  wire[`REG_DATA_WIDTH-1:0]    q_i; 

  reg                          rqvld_o;
  reg [`REG_CMD_WIDTH-1:0]     cmd_o;
  reg [`REG_ADDR_WIDTH-1:0]    a_o;
  reg [`REG_DATA_WIDTH-1:0]    d_o;

  reg [`REG_DATA_WIDTH-1:0]    grm_q;
  reg [`REG_ADDR_WIDTH-1:0]    grm_addr;
  reg                          grm_cmp;
  reg                          auto_nops_en;
  integer                      auto_nops;

  // DCU
  reg                          ccache_loaded;
  reg [`CACHE_ADDR_WIDTH-1:0]  ccache_end_addr;
  reg [`CACHE_ADDR_WIDTH-1:0]  ccache_addr;
  reg [`CACHE_ADDR_WIDTH-1:0]  ecache_addr;

  reg                          reg_rnd_write_test;

  integer poll_init_wait;
  integer poll_post_wait;

  
  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize
      integer i;
      integer j;
      
      grm_cmp      = 1'b1; // compare read data by default
      
      rqvld_i      = 1'b0;
      cmd_i        = `REG_READ;
      a_i          = ADDR_DEFAULT;
      d_i          = DATA_DEFAULT;

      rqvld_o      = 1'b0;
      cmd_o        = `REG_READ;
      a_o          = ADDR_DEFAULT;
      d_o          = DATA_DEFAULT;

      auto_nops_en = 1'b0;
      reg_rnd_write_test = 1'b0;
      
      // DCU
      ccache_loaded   = 0;
      ccache_end_addr = 0;
      ccache_addr     = 0;
      ecache_addr     = 0;

      // values to use for waiting at the beginning and end of register polling
      poll_init_wait = 25;
      poll_post_wait = 5;
    end

  // if JTAG interface is enabled, quiet down the cfg bus and only enable the jtag bus
  assign rqvld      = (jtag_en) ? 1'b0                    : rqvld_o;
  assign cmd        = (jtag_en) ? {`REG_CMD_WIDTH{1'b0}}  : cmd_o;
  assign a          = (jtag_en) ? {`REG_ADDR_WIDTH{1'b0}} : a_o;
  assign d          = (jtag_en) ? {`REG_DATA_WIDTH{1'b0}} : d_o;

  assign jtag_rqvld = (jtag_en) ? rqvld_o   : 'b0;
  assign jtag_cmd   = (jtag_en) ? cmd_o     : {`REG_CMD_WIDTH{1'b0}};
  assign jtag_a     = (jtag_en) ? a_o       : {`REG_ADDR_WIDTH{1'b0}};
  assign jtag_d     = (jtag_en) ? d_o       : {`REG_DATA_WIDTH{1'b0}};

  assign qvld_i     = (jtag_en) ? jtag_qvld : qvld;
  assign q_i        = (jtag_en) ? jtag_q    : q; 
  
  //---------------------------------------------------------------------------
  // DDR Controller Register Access Commands
  //---------------------------------------------------------------------------
  // commands to access the DDR controller registers
  
  // register write
  // --------------
  // writes to a selected DDR controller register
  task write_register;
    input [`REG_ADDR_WIDTH-1:0] addr;
    input [`REG_DATA_WIDTH-1:0] data;

    integer no_of_nops;
    reg [2:0] rank;
    begin

`ifdef DWC_DDRPHY_JTAG
      // If using JTAG register interface, check that no other command is in 
      // progress before issuing a new one
      if (jtag_en && (`JTAG.cmd_in_progress == 1'b1)) begin
        wait (`JTAG.cmd_in_progress == 1'b0);
        nops(10);
      end
`endif

      a_i = addr;
      d_i = data;

      execute_command(`REG_WRITE);
      `FCOV_REG.set_cov_registers_write(addr,data,`TOGGLE_REGISTER_DATA); 
      //`FCOV_REG.set_cov_registers_write(addr,data,`VALUE_REGISTER_DATA);           
      // also execute command in GRM if comparison with GRM is not enabled 
      // in the monitor
      if (`HOST_MNT.grm_cmp_en == 1'b0)
        begin
          `GRM.write_register(addr, data);
        end

`ifdef DWC_DDRPHY_APB
      // if using APB register interface, insert a NOP after each access
      nops(1);
`endif

`ifdef DWC_DDRPHY_JTAG
      // if using JTAG register interface, insert enough NOPs after each access
      // to allow the access to finish
      if (jtag_en) begin
        nops(53);
      end
`endif

    end
  endtask // write_register
  

  // register read
  // -------------
  // reads from a selected DDR controller register
  task read_register;
    input [`REG_ADDR_WIDTH-1:0] addr;
    begin

`ifdef DWC_DDRPHY_TB
      // also execute command in GRM if comparison with GRM is not enabled 
      // in the monitor
      if (`HOST_MNT.grm_cmp_en == 1'b0)
        begin
          `GRM.read_register(addr);
        end
`endif

`ifdef DWC_DDRPHY_JTAG
      // If using JTAG register interface, check that no other command is in 
      // progress before issuing a new one
      if (jtag_en && (`JTAG.cmd_in_progress == 1'b1)) begin
        wait (`JTAG.cmd_in_progress == 1'b0);
        nops(10);
      end
`endif

      a_i  = addr;
      execute_command(`REG_READ);
      `FCOV_REG.set_cov_registers_read(addr);

`ifdef DWC_DDRPHY_APB
      // if using APB register interface, insert a NOP after each access
      nop;
`endif
`ifdef DWC_DDRPHY_JTAG
      // if using JTAG register interface, wait for the data to be returned
      if (jtag_en) begin
        @(posedge jtag_qvld);
        @(negedge clk);
      end
`endif

    end
  endtask // read_register

  
  // register read data
  // ------------------
  // reads from a selected DDR controller register and waits for register data
  // to come back(and returns)
  task read_register_data;
    input  [`REG_ADDR_WIDTH-1:0] addr;
    output [`REG_DATA_WIDTH-1:0] data;
    begin
      @(posedge clk);
      fork
        begin
          read_register(addr);
          if (jtag_en === 1'b1)
            data = jtag_q;
        end
        begin
          @(posedge qvld_i); // Wait for the data valid signal
          @(posedge clk);    // Sample data on rising edge of clock
          data = q_i;
        end
      join
    end
  endtask // read_register_data


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
    input [`REG_CMD_WIDTH-1:0] op;
    reg [`REG_DATA_WIDTH-1:0] tmp_d;
    begin
      // insert required NOPs if this feature is enabled
      if (auto_nops_en === 1'b1)
        begin
          nops(auto_nops);
        end

      // execute current operation:
      // (for chip testbench call a task in the chip BFM to use the info
      //  depending on chip implementation: for the testchip, the instructions
      //  are executed)
      // drive the inputs; provide minimum setup time for each signal
      @(negedge clk);
      fork
        begin
          #(tCKL - tCMS);
          rqvld_o = 1'b1;          
          cmd_o   = op;
        end

        begin
          #(tCKL - tAS);
          a_o = a_i;
        end

        begin
          #(tCKL - tDIS);
          d_o = d_i;
        end
      join

      // deassert the inputs; provide minimum hold time for each signal
      @(posedge clk);
      
      fork
        begin
          #tCMH;
          rqvld_o = 1'b0;          
          cmd_o   = `REG_READ;
        end

        begin
          #tAH;
          a_o = ADDR_DEFAULT;
        end

        begin
          #tDIH;
          d_o  = DATA_DEFAULT;
        end
      join

      // reset internal signals
      a_i = ADDR_DEFAULT;
      d_i = DATA_DEFAULT;
    end
  endtask // execute_command

  
  // read compare
  // ------------
  // compares the data read with the data in the GRM
  // (if using chip tesbench, data comparison happens in the chip BFM)
  reg [7:0] dxngsr0_wlprd;
  reg [7:0] dxngsr0_gdqsprd;
  real      tmp_0;
  real      tmp_1;
  real      tmp_2;
  integer   index_i;
 
  always @(posedge clk or negedge rst_b)
    begin: read_compare
      // compare the read data (only if comparison in the monitor is disabled)
      if (qvld === 1'b1 && jtag_en === 1'b0  && `HOST_MNT.grm_cmp_en == 1'b0)
        begin
          `GRM.get_register_data(grm_q, grm_addr);
          //Functional coverage
          `FCOV_REG.set_cov_registers_read_clear(grm_addr, q,`VALUE_REGISTER_DATA);

          // compare output with expected value for DXnGSR0 regs.  if there's a mismatch
          // this is because the WLPRD and GDQSPRD can be +/- 1 tap off from the predicted value.
          if( (grm_cmp === 1'b1 && (q[15:7]!==grm_q[15:7] || q[25:17]!==grm_q[25:17]) &&
              (grm_addr === `DX0GSR0 || 
               grm_addr === `DX1GSR0 ||
               grm_addr === `DX2GSR0 ||
               grm_addr === `DX3GSR0 ||
               grm_addr === `DX4GSR0 ||
               grm_addr === `DX5GSR0 ||
               grm_addr === `DX6GSR0 ||
               grm_addr === `DX7GSR0 ||
               grm_addr === `DX8GSR0))
            )
            begin
              case(grm_addr)
                `DX0GSR0 : index_i = 0;
                `DX1GSR0 : index_i = 1;
                `DX2GSR0 : index_i = 2;
                `DX3GSR0 : index_i = 3;
                `DX4GSR0 : index_i = 4;
                `DX5GSR0 : index_i = 5;
                `DX6GSR0 : index_i = 6;
                `DX7GSR0 : index_i = 7;
                `DX8GSR0 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 WL/GDQS PRD measurement.
              tmp_0 = `SYS.abs(q[15:7] - grm_q[15:7]);
              tmp_1 = `SYS.abs(q[25:17] - grm_q[25:17]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR0, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR0.WLPRD[15:7] = 'h%0h got 'h%0h", $time, index_i, grm_q[15:7], q[15:7]);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR0.GDQSPRD[25:17] = 'h%0h got 'h%0h", $time, index_i, grm_q[25:17], q[25:17]);
              end	  
            end

          // compare output with expected value for DXnGSR2 regs.  if there's a mismatch
          // this is because the GSDQSPRD can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && q[31:23]!==grm_q[31:23]  &&
              (grm_addr === `DX0GSR2 || 
               grm_addr === `DX1GSR2 ||
               grm_addr === `DX2GSR2 ||
               grm_addr === `DX3GSR2 ||
               grm_addr === `DX4GSR2 ||
               grm_addr === `DX5GSR2 ||
               grm_addr === `DX6GSR2 ||
               grm_addr === `DX7GSR2 ||
               grm_addr === `DX8GSR2))
            )
            begin
              case(grm_addr)
                `DX0GSR2 : index_i = 0;
                `DX1GSR2 : index_i = 1;
                `DX2GSR2 : index_i = 2;
                `DX3GSR2 : index_i = 3;
                `DX4GSR2 : index_i = 4;
                `DX5GSR2 : index_i = 5;
                `DX6GSR2 : index_i = 6;
                `DX7GSR2 : index_i = 7;
                `DX8GSR2 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 GSDQSPRD measurement.
              tmp_0 = `SYS.abs(q[31:23] - grm_q[31:23]);

              // check to see if the tmp_0/tmp_1 is > 1
              if(tmp_0 > 1) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR2, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR2.GSDQSPRD[31:23] = 'h%0h got 'h%0h", $time, index_i, grm_q[31:23], q[31:23]);
              end
	    end	  
          // compare output with expected value for DXnGSR4 regs.  if there's a mismatch
          // this is because the X4GSDQSPRD can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && (q[15:7]!==grm_q[15:7] || q[25:17]!==grm_q[25:17]) &&
              (grm_addr === `DX0GSR4 || 
               grm_addr === `DX1GSR4 ||
               grm_addr === `DX2GSR4 ||
               grm_addr === `DX3GSR4 ||
               grm_addr === `DX4GSR4 ||
               grm_addr === `DX5GSR4 ||
               grm_addr === `DX6GSR4 ||
               grm_addr === `DX7GSR4 ||
               grm_addr === `DX8GSR4))
            )
            begin
              case(grm_addr)
                `DX0GSR4 : index_i = 0;
                `DX1GSR4 : index_i = 1;
                `DX2GSR4 : index_i = 2;
                `DX3GSR4 : index_i = 3;
                `DX4GSR4 : index_i = 4;
                `DX5GSR4 : index_i = 5;
                `DX6GSR4 : index_i = 6;
                `DX7GSR4 : index_i = 7;
                `DX8GSR4 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 WL/GDQS PRD measurement.
              tmp_0 = `SYS.abs(q[15:7] - grm_q[15:7]);
              tmp_1 = `SYS.abs(q[25:17] - grm_q[25:17]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR4, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR4.X4WLPRD[15:7] = 'h%0h got 'h%0h", $time, index_i, grm_q[15:7], q[15:7]);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR4.X4GDQSPRD[25:17] = 'h%0h got 'h%0h", $time, index_i, grm_q[25:17], q[25:17]);
              end	  
	    end	  
          // compare output with expected value for DXnGSR5 regs.  if there's a mismatch
          // this is because the GSDQSPRD can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && q[31:23]!==grm_q[31:23]  &&
              (grm_addr === `DX0GSR5 || 
               grm_addr === `DX1GSR5 ||
               grm_addr === `DX2GSR5 ||
               grm_addr === `DX3GSR5 ||
               grm_addr === `DX4GSR5 ||
               grm_addr === `DX5GSR5 ||
               grm_addr === `DX6GSR5 ||
               grm_addr === `DX7GSR5 ||
               grm_addr === `DX8GSR5))
            )
            begin
              case(grm_addr)
                `DX0GSR5 : index_i = 0;
                `DX1GSR5 : index_i = 1;
                `DX2GSR5 : index_i = 2;
                `DX3GSR5 : index_i = 3;
                `DX4GSR5 : index_i = 4;
                `DX5GSR5 : index_i = 5;
                `DX6GSR5 : index_i = 6;
                `DX7GSR5 : index_i = 7;
                `DX8GSR5 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 GSDQSPRD measurement.
              tmp_0 = `SYS.abs(q[31:23] - grm_q[31:23]);

              // check to see if the tmp_0/tmp_1 is > 1
              if(tmp_0 > 1) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR5, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR5.X4GSDQSPRD[31:23] = 'h%0h got 'h%0h", $time, index_i, grm_q[31:23], q[31:23]);
              end
            end	  

          // compare output with expected value for DXnLCDLR0-5 regs.  if there's a mismatch
          // this is because the delays can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1) && (q[8:0]!==grm_q[8:0] || q[24:16]!==grm_q[24:16]) &&
                   (grm_addr >= `DX0LCDLR0) &&
                   (((grm_addr - `DX0LCDLR0 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR1 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR2 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR3 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR4 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR5 )% `DX_REG_RANGE == 0))
                 )
            begin
              case(grm_addr)
                `DX0LCDLR0,`DX0LCDLR1,`DX0LCDLR2,`DX0LCDLR3,`DX0LCDLR4,`DX0LCDLR5 : index_i = 0;
                `DX1LCDLR0,`DX1LCDLR1,`DX1LCDLR2,`DX1LCDLR3,`DX1LCDLR4,`DX1LCDLR5 : index_i = 1;
                `DX2LCDLR0,`DX2LCDLR1,`DX2LCDLR2,`DX2LCDLR3,`DX2LCDLR4,`DX2LCDLR5 : index_i = 2;
                `DX3LCDLR0,`DX3LCDLR1,`DX3LCDLR2,`DX3LCDLR3,`DX3LCDLR4,`DX3LCDLR5 : index_i = 3;
                `DX4LCDLR0,`DX4LCDLR1,`DX4LCDLR2,`DX4LCDLR3,`DX4LCDLR4,`DX4LCDLR5 : index_i = 4;
                `DX5LCDLR0,`DX5LCDLR1,`DX5LCDLR2,`DX5LCDLR3,`DX5LCDLR4,`DX5LCDLR5 : index_i = 5;
                `DX6LCDLR0,`DX6LCDLR1,`DX6LCDLR2,`DX6LCDLR3,`DX6LCDLR4,`DX6LCDLR5 : index_i = 6;
                `DX7LCDLR0,`DX7LCDLR1,`DX7LCDLR2,`DX7LCDLR3,`DX7LCDLR4,`DX7LCDLR5 : index_i = 7;
                `DX8LCDLR0,`DX8LCDLR1,`DX8LCDLR2,`DX8LCDLR3,`DX8LCDLR4,`DX8LCDLR5 : index_i = 8;
                default    : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnLCDLR0-5 delays
              tmp_0 = `SYS.abs(q[8:0]   - grm_q[8:0]);
              tmp_1 = `SYS.abs(q[24:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                case (grm_addr)
                  `DX0LCDLR0, `DX1LCDLR0, `DX2LCDLR0, `DX3LCDLR0, `DX4LCDLR0, `DX5LCDLR0, `DX6LCDLR0, `DX7LCDLR0, `DX8LCDLR0: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR0 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR0.WLD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR0.X4WLD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
                  end

                  `DX0LCDLR1, `DX1LCDLR1, `DX2LCDLR1, `DX3LCDLR1, `DX4LCDLR1, `DX5LCDLR1, `DX6LCDLR1, `DX7LCDLR1, `DX8LCDLR1: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR1 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR1.WDQD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR1.X4WDQD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
                  end

                  `DX0LCDLR2, `DX1LCDLR2, `DX2LCDLR2, `DX3LCDLR2, `DX4LCDLR2, `DX5LCDLR2, `DX6LCDLR2, `DX7LCDLR2, `DX8LCDLR2: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR2 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR2.DQSGD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR2.X4DQSGD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
                  end

                  `DX0LCDLR3, `DX1LCDLR3, `DX2LCDLR3, `DX3LCDLR3, `DX4LCDLR3, `DX5LCDLR3, `DX6LCDLR3, `DX7LCDLR3, `DX8LCDLR3: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR3 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR3.RDQSD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR3.X4RDQSD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
                  end

                  `DX0LCDLR4, `DX1LCDLR4, `DX2LCDLR4, `DX3LCDLR4, `DX4LCDLR4, `DX5LCDLR4, `DX6LCDLR4, `DX7LCDLR4, `DX8LCDLR4: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR4 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR4.RDQSND  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR4.X4RDQSND[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
                  end

                  `DX0LCDLR5, `DX1LCDLR5, `DX2LCDLR5, `DX3LCDLR5, `DX4LCDLR5, `DX5LCDLR5, `DX6LCDLR5, `DX7LCDLR5, `DX8LCDLR5: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR5 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR5.DQSGSD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR5.X4DQSGSD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
                  end

                  default    : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
                endcase // case(grm_addr)
                
              end
            end

          // compare output with expected value for DXnMDLR0 regs.  if there's a mismatch
          // this is because the delays can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && (q[8:0]!==grm_q[8:0] || q[24:16]!==grm_q[24:16]) &&
                   (grm_addr === `DX0MDLR0 || 
                    grm_addr === `DX1MDLR0 || 
                    grm_addr === `DX2MDLR0 || 
                    grm_addr === `DX3MDLR0 || 
                    grm_addr === `DX4MDLR0 || 
                    grm_addr === `DX5MDLR0 || 
                    grm_addr === `DX6MDLR0 || 
                    grm_addr === `DX7MDLR0 || 
                    grm_addr === `DX8MDLR0))
                 )
            begin
              case(grm_addr)
                `DX0MDLR0 : index_i = 0;
                `DX1MDLR0 : index_i = 1;
                `DX2MDLR0 : index_i = 2;
                `DX3MDLR0 : index_i = 3;
                `DX4MDLR0 : index_i = 4;
                `DX5MDLR0 : index_i = 5;
                `DX6MDLR0 : index_i = 6;
                `DX7MDLR0 : index_i = 7;
                `DX8MDLR0 : index_i = 8;
                default    : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnMDLR0 delays
              tmp_0 = `SYS.abs(q[7:0] - grm_q[8:0]);
              tmp_1 = `SYS.abs(q[24:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]MDLR0 delays", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]MDLR0.IPRD[8:0]     = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0], q[8:0]);
                $display("-> %0t: [CFG] Expecting DX[%0d]MDLR0.TPRD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], q[24:16]);
              end
            end		    	    
          // compare output with expected value for ACLCDLR regs.  if there's a mismatch
          // this is because the delays can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && (q[8:0]!==grm_q[8:0] || q[24:16]!==grm_q[24:16]) && grm_addr === `ACLCDLR ) )
            begin

              // there might be a + or - 1 difference between the calculated values with the
              // DXnMDLR0 delays
              tmp_0 = `SYS.abs(q[7:0] - grm_q[8:0]);
              tmp_1 = `SYS.abs(q[24:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: ACLCDLR delays", $time);
                $display("-> %0t: [CFG] Expecting ACLCDLR.ACD[8:0]     = 'h%0h got 'h%0h", $time, grm_q[8:0], q[8:0]);
              end
            end		    	
//`endif
         else if((grm_cmp === 1'b1 && (q[8:0]!==grm_q[8:0] || q[24:16]!==grm_q[24:16]) && grm_addr === `ACMDLR0 ))
           begin
              // there might be a + or - 1 difference between the calculated values with the
              // ACMDLR0 delays
              tmp_0 = `SYS.abs(q[8:0] - grm_q[8:0]);
              tmp_1 = `SYS.abs(q[23:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: ACMDLR0 delays", $time);
                $display("-> %0t: [CFG] Expecting ACMDLR0.IPRD[8:0]   = 'h%0h got 'h%0h", $time, grm_q[8:0], q[8:0]);
                $display("-> %0t: [CFG] Expecting ACMDLR0.TPRD[24:16] = 'h%0h got 'h%0h", $time, grm_q[24:16], q[24:16]);
              end
            end	    	    
          // compare output with expected value for ZQnSR regs.
          else if ( (grm_cmp === 1'b1 && (q[7:0] !== grm_q[7:0]) &&
                    (grm_addr === `ZQ0SR ||
                     grm_addr === `ZQ1SR ||
                     grm_addr === `ZQ2SR ||
                     grm_addr === `ZQ3SR ))
                  )
            begin
              // for ZQnSR registers, per bug 4090, the ZQ FSM is always running and can be a safe value of 2'b11 or 2'b00,
              // so TB needs to ignore these vaules.
              if((q[7:6]!=2'b11 && q[7:6]!=2'b00) && (q[7:6] != grm_q[7:6])) begin
                `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
              end

              if((q[5:4]!=2'b11 && q[5:4]!=2'b00) && (q[5:4] != grm_q[5:4])) begin
                `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
              end

              if((q[3:2]!=2'b11 && q[3:2]!=2'b00) && (q[3:2] != grm_q[3:2])) begin
                `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
              end

              if((q[1:0]!=2'b11 && q[1:0]!=2'b00) && (q[1:0] != grm_q[1:0])) begin
                `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
              end
            end
          // Compare output with expected value for PGSR0 and if the CAWARN bit doesn't match the expected,
          // ignore it.  This is allowed because the design can't predict when there will be a warning or not.
          // Ohm requested that the TB ignore the CAWARN bit in PGSR0.
          else if ((grm_cmp === 1'b1) && (q !== grm_q) &&
                   (grm_addr === `PGSR0)
                  )
            begin
              // check the rest of the register value; skip bit 29 CAWARN
              if((q[31:30] != grm_q[31:30]) || (q[28:0] != grm_q[28:0])) begin
                `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
              end
            end
          // Compare output with expected value for PGSR1 and if the PARERR bit doesn't match the expected,
          // ignore it.  
          else if ((grm_cmp === 1'b1) && (q !== grm_q) &&
                   (grm_addr === `PGSR1)
                  )
            begin
              // check the whole register if not reg_rnd_write_test, otherwise skip PARERR (bit 31)
              if((q[30:0] != grm_q[30:0] && reg_rnd_write_test)  || 
                 (q!== grm_q             && (reg_rnd_write_test==1'b0))) begin
                `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
              end
            end
          // compare output with expected value
          // DCUSR1[31:24] - loop count could be 1 less than the value in design
          // DCUSR1[15: 0] - num words captured could be 4 less than the value in design when a stop is issued
          else if (   (grm_cmp === 1'b1 && grm_addr !== `DCUSR1 && q !== grm_q)
                   || (grm_cmp === 1'b1 && grm_addr === `DCUSR1 && 
                       (   (q[23:16] !== grm_q[23:16])
                        || (q[31:24] !== grm_q[31:24] && q[31:24] != (grm_q[31:24]+1))
                        || (q[15: 0] !== grm_q[15: 0] && q[15: 0] != (grm_q[15: 0]+(`BURST_ADDR_INC/2)))
                      ))
                  )
            begin
              `SYS.error_message(`CHIP_CFG, `QERR, {grm_addr, grm_q});
            end

          // keep track of how many read data have been received
          `GRM.log_register_read_output;
        end
    end // block: read_compare

  always @(posedge clk or negedge rst_b)
    begin: read_compare_jtag
      // compare the read data (only if comparison in the monitor is disabled)
      if (jtag_qvld === 1'b1 && jtag_en === 1'b1  && `HOST_MNT.grm_cmp_en == 1'b0)
        begin
          `GRM.get_register_data(grm_q, grm_addr);
          //Functional coverage
          `FCOV_REG.set_cov_registers_read_clear(grm_addr, jtag_q,`VALUE_REGISTER_DATA);

          // compare output with expected value for DXnGSR0 regs.  if there's a mismatch
          // this is because the WLPRD and GDQSPRD can be +/- 1 tap off from the predicted value.
          if( (grm_cmp === 1'b1 && (jtag_q[15:7]!==grm_q[15:7] || jtag_q[25:17]!==grm_q[25:17]) &&
              (grm_addr === `DX0GSR0 || 
               grm_addr === `DX1GSR0 ||
               grm_addr === `DX2GSR0 ||
               grm_addr === `DX3GSR0 ||
               grm_addr === `DX4GSR0 ||
               grm_addr === `DX5GSR0 ||
               grm_addr === `DX6GSR0 ||
               grm_addr === `DX7GSR0 ||
               grm_addr === `DX8GSR0))
            )
            begin
              case(grm_addr)
                `DX0GSR0 : index_i = 0;
                `DX1GSR0 : index_i = 1;
                `DX2GSR0 : index_i = 2;
                `DX3GSR0 : index_i = 3;
                `DX4GSR0 : index_i = 4;
                `DX5GSR0 : index_i = 5;
                `DX6GSR0 : index_i = 6;
                `DX7GSR0 : index_i = 7;
                `DX8GSR0 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 WL/GDQS PRD measurement.
              tmp_0 = `SYS.abs(jtag_q[15:7]  - grm_q[15:7]);
              tmp_1 = `SYS.abs(jtag_q[25:17] - grm_q[25:17]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR0, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR0.WLPRD[15:7] = 'h%0h got 'h%0h", $time, index_i, grm_q[15:7], jtag_q[15:7]);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR0.GDQSPRD[25:17] = 'h%0h got 'h%0h", $time, index_i, grm_q[25:17], jtag_q[25:17]);
              end	  
            end

          // compare output with expected value for DXnGSR2 regs.  if there's a mismatch
          // this is because the GSDQSPRD can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && jtag_q[31:23]!==grm_q[31:23]  &&
              (grm_addr === `DX0GSR2 || 
               grm_addr === `DX1GSR2 ||
               grm_addr === `DX2GSR2 ||
               grm_addr === `DX3GSR2 ||
               grm_addr === `DX4GSR2 ||
               grm_addr === `DX5GSR2 ||
               grm_addr === `DX6GSR2 ||
               grm_addr === `DX7GSR2 ||
               grm_addr === `DX8GSR2))
            )
            begin
              case(grm_addr)
                `DX0GSR2 : index_i = 0;
                `DX1GSR2 : index_i = 1;
                `DX2GSR2 : index_i = 2;
                `DX3GSR2 : index_i = 3;
                `DX4GSR2 : index_i = 4;
                `DX5GSR2 : index_i = 5;
                `DX6GSR2 : index_i = 6;
                `DX7GSR2 : index_i = 7;
                `DX8GSR2 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 GSDQSPRD measurement.
              tmp_0 = `SYS.abs(jtag_q[31:23] - grm_q[31:23]);

              // check to see if the tmp_0/tmp_1 is > 1
              if(tmp_0 > 1) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR2, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR2.GSDQSPRD[31:23] = 'h%0h got 'h%0h", $time, index_i, grm_q[31:23], jtag_q[31:23]);
              end
	    end	  
          // compare output with expected value for DXnGSR4 regs.  if there's a mismatch
          // this is because the X4GSDQSPRD can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && (jtag_q[15:7]!==grm_q[15:7] || jtag_q[25:17]!==grm_q[25:17]) &&
              (grm_addr === `DX0GSR4 || 
               grm_addr === `DX1GSR4 ||
               grm_addr === `DX2GSR4 ||
               grm_addr === `DX3GSR4 ||
               grm_addr === `DX4GSR4 ||
               grm_addr === `DX5GSR4 ||
               grm_addr === `DX6GSR4 ||
               grm_addr === `DX7GSR4 ||
               grm_addr === `DX8GSR4))
            )
            begin
              case(grm_addr)
                `DX0GSR4 : index_i = 0;
                `DX1GSR4 : index_i = 1;
                `DX2GSR4 : index_i = 2;
                `DX3GSR4 : index_i = 3;
                `DX4GSR4 : index_i = 4;
                `DX5GSR4 : index_i = 5;
                `DX6GSR4 : index_i = 6;
                `DX7GSR4 : index_i = 7;
                `DX8GSR4 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 WL/GDQS PRD measurement.
              tmp_0 = `SYS.abs(jtag_q[15:7]  - grm_q[15:7]);
              tmp_1 = `SYS.abs(jtag_q[25:17] - grm_q[25:17]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR4, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR4.X4WLPRD[15:7] = 'h%0h got 'h%0h", $time, index_i, grm_q[15:7], jtag_q[15:7]);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR4.X4GDQSPRD[25:17] = 'h%0h got 'h%0h", $time, index_i, grm_q[25:17], jtag_q[25:17]);
              end	  
	    end	  
          // compare output with expected value for DXnGSR5 regs.  if there's a mismatch
          // this is because the GSDQSPRD can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && jtag_q[31:23]!==grm_q[31:23]  &&
              (grm_addr === `DX0GSR5 || 
               grm_addr === `DX1GSR5 ||
               grm_addr === `DX2GSR5 ||
               grm_addr === `DX3GSR5 ||
               grm_addr === `DX4GSR5 ||
               grm_addr === `DX5GSR5 ||
               grm_addr === `DX6GSR5 ||
               grm_addr === `DX7GSR5 ||
               grm_addr === `DX8GSR5))
            )
            begin
              case(grm_addr)
                `DX0GSR5 : index_i = 0;
                `DX1GSR5 : index_i = 1;
                `DX2GSR5 : index_i = 2;
                `DX3GSR5 : index_i = 3;
                `DX4GSR5 : index_i = 4;
                `DX5GSR5 : index_i = 5;
                `DX6GSR5 : index_i = 6;
                `DX7GSR5 : index_i = 7;
                `DX8GSR5 : index_i = 8;
                default  : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnGSR0 GSDQSPRD measurement.
              tmp_0 = `SYS.abs(jtag_q[31:23] - grm_q[31:23]);

              // check to see if the tmp_0/tmp_1 is > 1
              if(tmp_0 > 1) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]GSR5, period measurement incorrect", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]GSR5.X4GSDQSPRD[31:23] = 'h%0h got 'h%0h", $time, index_i, grm_q[31:23], jtag_q[31:23]);
              end
      	    end	  

          // compare output with expected value for DXnLCDLR0-5 regs.  if there's a mismatch
          // this is because the delays can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1) && (jtag_q[8:0]!==grm_q[8:0] || jtag_q[24:16]!==grm_q[24:16]) &&
                   (grm_addr >= `DX0LCDLR0) &&
                   (((grm_addr - `DX0LCDLR0 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR1 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR2 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR3 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR4 )% `DX_REG_RANGE == 0) ||
                    ((grm_addr - `DX0LCDLR5 )% `DX_REG_RANGE == 0))
                 )
            begin
              case(grm_addr)
                `DX0LCDLR0,`DX0LCDLR1,`DX0LCDLR2,`DX0LCDLR3,`DX0LCDLR4,`DX0LCDLR5 : index_i = 0;
                `DX1LCDLR0,`DX1LCDLR1,`DX1LCDLR2,`DX1LCDLR3,`DX1LCDLR4,`DX1LCDLR5 : index_i = 1;
                `DX2LCDLR0,`DX2LCDLR1,`DX2LCDLR2,`DX2LCDLR3,`DX2LCDLR4,`DX2LCDLR5 : index_i = 2;
                `DX3LCDLR0,`DX3LCDLR1,`DX3LCDLR2,`DX3LCDLR3,`DX3LCDLR4,`DX3LCDLR5 : index_i = 3;
                `DX4LCDLR0,`DX4LCDLR1,`DX4LCDLR2,`DX4LCDLR3,`DX4LCDLR4,`DX4LCDLR5 : index_i = 4;
                `DX5LCDLR0,`DX5LCDLR1,`DX5LCDLR2,`DX5LCDLR3,`DX5LCDLR4,`DX5LCDLR5 : index_i = 5;
                `DX6LCDLR0,`DX6LCDLR1,`DX6LCDLR2,`DX6LCDLR3,`DX6LCDLR4,`DX6LCDLR5 : index_i = 6;
                `DX7LCDLR0,`DX7LCDLR1,`DX7LCDLR2,`DX7LCDLR3,`DX7LCDLR4,`DX7LCDLR5 : index_i = 7;
                `DX8LCDLR0,`DX8LCDLR1,`DX8LCDLR2,`DX8LCDLR3,`DX8LCDLR4,`DX8LCDLR5 : index_i = 8;
                default    : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnLCDLR0-5 delays
              tmp_0 = `SYS.abs(jtag_q[8:0]   - grm_q[8:0]);
              tmp_1 = `SYS.abs(jtag_q[24:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                case (grm_addr)
                  `DX0LCDLR0, `DX1LCDLR0, `DX2LCDLR0, `DX3LCDLR0, `DX4LCDLR0, `DX5LCDLR0, `DX6LCDLR0, `DX7LCDLR0, `DX8LCDLR0: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR0 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR0.WLD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   jtag_q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR0.X4WLD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
                  end

                  `DX0LCDLR1, `DX1LCDLR1, `DX2LCDLR1, `DX3LCDLR1, `DX4LCDLR1, `DX5LCDLR1, `DX6LCDLR1, `DX7LCDLR1, `DX8LCDLR1: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR1 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR1.WDQD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   jtag_q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR1.X4WDQD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
                  end

                  `DX0LCDLR2, `DX1LCDLR2, `DX2LCDLR2, `DX3LCDLR2, `DX4LCDLR2, `DX5LCDLR2, `DX6LCDLR2, `DX7LCDLR2, `DX8LCDLR2: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR2 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR2.DQSGD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   jtag_q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR2.X4DQSGD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
                  end

                  `DX0LCDLR3, `DX1LCDLR3, `DX2LCDLR3, `DX3LCDLR3, `DX4LCDLR3, `DX5LCDLR3, `DX6LCDLR3, `DX7LCDLR3, `DX8LCDLR3: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR3 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR3.RDQSD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   jtag_q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR3.X4RDQSD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
                  end

                  `DX0LCDLR4, `DX1LCDLR4, `DX2LCDLR4, `DX3LCDLR4, `DX4LCDLR4, `DX5LCDLR4, `DX6LCDLR4, `DX7LCDLR4, `DX8LCDLR4: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR4 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR4.RDQSND  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   jtag_q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR4.X4RDQSND[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
                  end

                  `DX0LCDLR5, `DX1LCDLR5, `DX2LCDLR5, `DX3LCDLR5, `DX4LCDLR5, `DX5LCDLR5, `DX6LCDLR5, `DX7LCDLR5, `DX8LCDLR5: begin
                    $display("-> %0t: [CFG] ERROR:    DX[%0d]LCDLR5 delays", $time, index_i);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR5.DQSGSD  [8:0]   = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0],   jtag_q[8:0]);
                    $display("-> %0t: [CFG] Expecting DX[%0d]LCDLR5.X4DQSGSD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
                  end

                  default    : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
                endcase
              end
            end

          // compare output with expected value for DXnMDLR0 regs.  if there's a mismatch
          // this is because the delays can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && (jtag_q[8:0]!==grm_q[8:0] || jtag_q[24:16]!==grm_q[24:16]) &&
                   (grm_addr === `DX0MDLR0 || 
                    grm_addr === `DX1MDLR0 || 
                    grm_addr === `DX2MDLR0 || 
                    grm_addr === `DX3MDLR0 || 
                    grm_addr === `DX4MDLR0 || 
                    grm_addr === `DX5MDLR0 || 
                    grm_addr === `DX6MDLR0 || 
                    grm_addr === `DX7MDLR0 || 
                    grm_addr === `DX8MDLR0))
                 )
            begin
              case(grm_addr)
                `DX0MDLR0 : index_i = 0;
                `DX1MDLR0 : index_i = 1;
                `DX2MDLR0 : index_i = 2;
                `DX3MDLR0 : index_i = 3;
                `DX4MDLR0 : index_i = 4;
                `DX5MDLR0 : index_i = 5;
                `DX6MDLR0 : index_i = 6;
                `DX7MDLR0 : index_i = 7;
                `DX8MDLR0 : index_i = 8;
                default    : `SYS.error_message(`SYS_OP, `UNKNOWN_REG, "");
              endcase

              // there might be a + or - 1 difference between the calculated values with the
              // DXnMDLR0 delays
              tmp_0 = `SYS.abs(jtag_q[7:0] - grm_q[8:0]);
              tmp_1 = `SYS.abs(jtag_q[24:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: DX[%0d]MDLR0 delays", $time, index_i);
                $display("-> %0t: [CFG] Expecting DX[%0d]MDLR0.IPRD[8:0]     = 'h%0h got 'h%0h", $time, index_i, grm_q[8:0], jtag_q[8:0]);
                $display("-> %0t: [CFG] Expecting DX[%0d]MDLR0.TPRD[24:16] = 'h%0h got 'h%0h", $time, index_i, grm_q[24:16], jtag_q[24:16]);
              end
            end		    	    
          // compare output with expected value for ACLCDLR regs.  if there's a mismatch
          // this is because the delays can be +/- 1 tap off from the predicted value.
          else if( (grm_cmp === 1'b1 && (jtag_q[8:0]!==grm_q[8:0] || jtag_q[24:16]!==grm_q[24:16]) && grm_addr === `ACLCDLR ) )
            begin

              // there might be a + or - 1 difference between the calculated values with the
              // DXnMDLR0 delays
              tmp_0 = `SYS.abs(jtag_q[7:0] - grm_q[8:0]);
              tmp_1 = `SYS.abs(jtag_q[24:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: ACLCDLR delays", $time);
                $display("-> %0t: [CFG] Expecting ACLCDLR.ACD[8:0]     = 'h%0h got 'h%0h", $time, grm_q[8:0], jtag_q[8:0]);
              end
            end		    	

         else if((grm_cmp === 1'b1 && (jtag_q[8:0]!==grm_q[8:0] || jtag_q[24:16]!==grm_q[24:16]) && grm_addr === `ACMDLR0 ))
           begin
              // there might be a + or - 1 difference between the calculated values with the
              // ACMDLR0 delays
              tmp_0 = `SYS.abs(jtag_q[8:0] - grm_q[8:0]);
              tmp_1 = `SYS.abs(jtag_q[23:16] - grm_q[24:16]);

              // check to see if the tmp_0/tmp_1 is > 1
              if((tmp_0 > 1) || (tmp_1 > 1)) begin
                `SYS.error;
                $display("-> %0t: [CFG] ERROR: ACMDLR0 delays", $time);
                $display("-> %0t: [CFG] Expecting ACMDLR0.IPRD[8:0]   = 'h%0h got 'h%0h", $time, grm_q[8:0], jtag_q[8:0]);
                $display("-> %0t: [CFG] Expecting ACMDLR0.TPRD[24:16] = 'h%0h got 'h%0h", $time, grm_q[24:16], jtag_q[24:16]);
              end
            end	    	    
          // compare output with expected value for ZQnSR regs.
          else if ( (grm_cmp === 1'b1 && (jtag_q[7:0] !== grm_q[7:0]) &&
                    (grm_addr === `ZQ0SR ||
                     grm_addr === `ZQ1SR ||
                     grm_addr === `ZQ2SR ||
                     grm_addr === `ZQ3SR ))
                  )
            begin
              // for ZQnSR registers, per bug 4090, the ZQ FSM is always running and can be a safe value of 2'b11 or 2'b00,
              // so TB needs to ignore these vaules.
              if((jtag_q[7:6]!=2'b11 && jtag_q[7:6]!=2'b00) && (jtag_q[7:6] != grm_q[7:6])) begin
                `SYS.error_message(`JTAG_CFG, `QERR, {grm_addr, grm_q});
              end

              if((jtag_q[5:4]!=2'b11 && jtag_q[5:4]!=2'b00) && (jtag_q[5:4] != grm_q[5:4])) begin
                `SYS.error_message(`JTAG_CFG, `QERR, {grm_addr, grm_q});
              end

              if((jtag_q[3:2]!=2'b11 && jtag_q[3:2]!=2'b00) && (jtag_q[3:2] != grm_q[3:2])) begin
                `SYS.error_message(`JTAG_CFG, `QERR, {grm_addr, grm_q});
              end

              if((jtag_q[1:0]!=2'b11 && jtag_q[1:0]!=2'b00) && (jtag_q[1:0] != grm_q[1:0])) begin
                `SYS.error_message(`JTAG_CFG, `QERR, {grm_addr, grm_q});
              end
            end
          // Compare output with expected value for PGSR0 and if the CAWARN bit doesn't match the expected,
          // ignore it.  This is allowed because the design can't predict when there will be a warning or not.
          // Ohm requested that the TB ignore the CAWARN bit in PGSR0.
          else if ((grm_cmp === 1'b1) && (jtag_q[29] !== grm_q[29]) &&
                   (grm_addr === `PGSR0)
                  )
            begin
              // check the rest of the register value
              if((jtag_q[31:30] != grm_q[31:30]) || (jtag_q[28:0] != grm_q[28:0])) begin
                `SYS.error_message(`JTAG_CFG, `QERR, {grm_addr, grm_q});
              end
            end
          // compare output with expected value
          // DCUSR1[31:24] - loop count could be 1 less than the value in design
          // DCUSR1[15: 0] - num words captured could be 4 less than the value in design when a stop is issued
          else if (   (grm_cmp === 1'b1 && grm_addr !== `DCUSR1 && jtag_q !== grm_q)
                   || (grm_cmp === 1'b1 && grm_addr === `DCUSR1 && 
                       (   (jtag_q[23:16] !== grm_q[23:16])
                        || (jtag_q[31:24] !== grm_q[31:24] && jtag_q[31:24] != (grm_q[31:24]+1))
                        || (jtag_q[15: 0] !== grm_q[15: 0] && jtag_q[15: 0] != (grm_q[15: 0]+(`BURST_ADDR_INC/2)))
                      ))
                  )
            begin
              `SYS.error_message(`JTAG_CFG, `QERR, {grm_addr, grm_q});
            end

          // keep track of how many read data have been received
          `GRM.log_register_read_output;
        end
    end // block: read_compare_JTAG



  // enable/disable comparison of read with GRM data
  task enable_read_compare;
    begin
      grm_cmp = 1'b1;
    end
  endtask // enable_read_compare
  
  task disable_read_compare;
    begin
      grm_cmp = 1'b0;
    end
  endtask // disable_read_compare
  
  
  //---------------------------------------------------------------------------
  // Automatic NOPs
  //---------------------------------------------------------------------------
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
  
  
  //---------------------------------------------------------------------------
  // DRAM Command Unit (DCU)
  //---------------------------------------------------------------------------
  // execution of commands through the DCU

  // load/read caches
  // ----------------
  // sets up DCU cache accesses
  task set_dcu_cache_access;
    input [1:0]                   cache_sel;
    input                         inc_addr;
    input                         acc_type;
    input [`CACHE_ADDR_WIDTH-1:0] word_addr;
    input [`CACHE_ADDR_WIDTH-1:0] slice_addr;
    begin
      `GRM.dcuar[3:0] = word_addr;
      `GRM.dcuar[7:4] = slice_addr;
      `GRM.dcuar[9:8] = cache_sel;
      `GRM.dcuar[10]  = inc_addr;
      `GRM.dcuar[11]  = acc_type;
      write_register(`DCUAR, `GRM.dcuar);
      `FCOV_REG.set_cov_registers_write(`DCUAR,`GRM.dcuar,`VALUE_REGISTER_DATA);                 
`ifdef DWC_DDRPHY_APB
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
    end
  endtask // set_dcu_cache_access
      
  // loads commands into the DCU command cache
  task load_dcu_command;
    input [`DCU_RPT_WIDTH   -1:0] rpt;
    input [`DCU_DTP_WIDTH   -1:0] dtp;
    input [`DCU_TAG_WIDTH   -1:0] tag;
    input [`CMD_WIDTH       -1:0] cmd;
    input [`SDRAM_RANK_WIDTH-1:0] rank;
    input [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH  -1:0] bank;
    input [`DWC_PHY_ADDR_WIDTH  -1:0] addr;
    input [`PUB_DQS_WIDTH   -1:0] mask;
    input [`DCU_DATA_WIDTH  -1:0] data;

    reg [511:0] cache_word;
    integer     slice_addr;
    begin
      // setup the DCU address register for expected data cache access
      // (if not already set)
      if (`GRM.dcuar[9:8] != `DCU_CCACHE) begin
        `GRM.dcuar[3:0] = 0;
        `GRM.dcuar[7:4] = 0;
        `GRM.dcuar[9:8] = `DCU_CCACHE;
        write_register(`DCUAR, `GRM.dcuar);
        `FCOV_REG.set_cov_registers_write(`DCUAR,`GRM.dcuar,`VALUE_REGISTER_DATA);                         
`ifdef DWC_DDRPHY_APB
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
      end
      
      cache_word = {512{1'b0}};
      if (`DWC_NO_OF_LRANKS > 1) begin
        cache_word[`CCACHE_DATA_WIDTH-1:0] = {rpt, dtp, tag, cmd, rank, bank, addr, 
                                              mask[(pNUM_LANES * 3) +: 1*`DWC_DX_NO_OF_DQS], 
                                              mask[(pNUM_LANES * 2) +: 1*`DWC_DX_NO_OF_DQS], 
                                              mask[(pNUM_LANES * 1) +: 1*`DWC_DX_NO_OF_DQS], 
                                              mask[(pNUM_LANES * 0) +: 1*`DWC_DX_NO_OF_DQS], 
                                              data[`DCU_DATA_WIDTH-1:0]};
      end else begin
        cache_word[`CCACHE_DATA_WIDTH-1:0] = {rpt, dtp, tag, cmd,       bank, addr, 
                                              mask[(pNUM_LANES * 3) +: 1*`DWC_DX_NO_OF_DQS], 
                                              mask[(pNUM_LANES * 2) +: 1*`DWC_DX_NO_OF_DQS], 
                                              mask[(pNUM_LANES * 1) +: 1*`DWC_DX_NO_OF_DQS], 
                                              mask[(pNUM_LANES * 0) +: 1*`DWC_DX_NO_OF_DQS], 
                                              data[`DCU_DATA_WIDTH-1:0]};
      end

      for (slice_addr=0; slice_addr<`CCACHE_SLICES; slice_addr=slice_addr+1) begin
        write_register(`DCUDR, cache_word[`CFG_DATA_WIDTH-1:0]);
        `FCOV_REG.set_cov_registers_write(`DCUDR,cache_word[`CFG_DATA_WIDTH-1:0],`VALUE_REGISTER_DATA);
`ifdef DWC_DDRPHY_APB
        repeat (2*`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (2*`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
        cache_word = cache_word >> `CFG_DATA_WIDTH;
      end

      // keep track of the last loaded command cache address
      if (!ccache_loaded) begin
        ccache_loaded = 1'b1;
        ccache_end_addr = 0;
      end else begin
        ccache_end_addr = ccache_end_addr + 1;
      end
    end
  endtask // load_dcu_command

  // load expected data
  task load_expected_data;
    input [`PUB_DATA_WIDTH-1:0] data;

    reg [511:0] cache_word;
    integer     slice_addr;
    begin
      // setup the DCU address register for expected data cache access
      // (if not already set)
      if (`GRM.dcuar[9:8] != `DCU_ECACHE) begin
        `GRM.dcuar[3:0] = 0;
        `GRM.dcuar[7:4] = 0;
        `GRM.dcuar[9:8] = `DCU_ECACHE;
        write_register(`DCUAR, `GRM.dcuar);
        `FCOV_REG.set_cov_registers_write(`DCUAR,`GRM.dcuar,`VALUE_REGISTER_DATA);                         
`ifdef DWC_DDRPHY_APB
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
      end

      // write data into cache slices
      cache_word = {512{1'b0}};
      cache_word[`ECACHE_DATA_WIDTH-1:0] = {data[(`DWC_DATA_WIDTH * 3) +: 8], 
                                            data[(`DWC_DATA_WIDTH * 2) +: 8], 
                                            data[(`DWC_DATA_WIDTH * 1) +: 8], 
                                            data[(`DWC_DATA_WIDTH * 0) +: 8]};
      for (slice_addr=0; slice_addr<`ECACHE_SLICES; slice_addr=slice_addr+1) begin
        write_register(`DCUDR, cache_word[`CFG_DATA_WIDTH-1:0]);
        `FCOV_REG.set_cov_registers_write(`DCUDR,cache_word[`CFG_DATA_WIDTH-1:0],`VALUE_REGISTER_DATA);
`ifdef DWC_DDRPHY_APB
        repeat (2*`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (2*`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
        cache_word = cache_word >> `CFG_DATA_WIDTH;
      end
    end
  endtask // load_expected_data
  

  // load encoded expected data
  task load_encoded_expected_data;
    input [`ECACHE_DATA_WIDTH-1:0] data;

    reg [511:0] cache_word;
    integer     slice_addr;
    begin
      // setup the DCU address register for expected data cache access
      // (if not already set)
      if (`GRM.dcuar[9:8] != `DCU_ECACHE) begin
        `GRM.dcuar[3:0] = 0;
        `GRM.dcuar[7:4] = 0;
        `GRM.dcuar[9:8] = `DCU_ECACHE;
        write_register(`DCUAR, `GRM.dcuar);
        `FCOV_REG.set_cov_registers_write(`DCUAR,`GRM.dcuar,`VALUE_REGISTER_DATA);                         
`ifdef DWC_DDRPHY_APB
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
      end

      // write data into cache slices
      cache_word = {512{1'b0}};
      cache_word[`ECACHE_DATA_WIDTH-1:0] = data;

      for (slice_addr=0; slice_addr<`ECACHE_SLICES; slice_addr=slice_addr+1) begin
        write_register(`DCUDR, cache_word[`CFG_DATA_WIDTH-1:0]);
        `FCOV_REG.set_cov_registers_write(`DCUDR,cache_word[`CFG_DATA_WIDTH-1:0],`VALUE_REGISTER_DATA);
`ifdef DWC_DDRPHY_APB
        repeat (2*`DWC_CDC_SYNC_STAGES) @(posedge `PUB.pclk);
`else                      
        repeat (2*`DWC_CDC_SYNC_STAGES) @(posedge `PUB.cfg_clk);
`endif
        cache_word = cache_word >> `CFG_DATA_WIDTH;
      end
    end
  endtask // load_encoded_expected_data

  
  // run DCU command
  // ---------------
  // setus up command looping
  task set_dcu_looping;
    input [`CACHE_ADDR_WIDTH-1:0] loop_start_addr;
    input [`CACHE_ADDR_WIDTH-1:0] loop_end_addr;
    input [`CACHE_LOOP_WIDTH-1:0] loop_cnt;
    input                         loop_infinite;
    input                         dcu_inc_dram_addr;
    input [`CACHE_ADDR_WIDTH-1:0] xpctd_loop_end_addr;
    begin
      `GRM.dculr[3:0]   = loop_start_addr;
      `GRM.dculr[7:4]   = loop_end_addr;
      `GRM.dculr[15:8]  = loop_cnt;
      `GRM.dculr[16]    = loop_infinite;
      `GRM.dculr[17]    = dcu_inc_dram_addr;
      `GRM.dculr[31:28] = xpctd_loop_end_addr;
      write_register(`DCULR, `GRM.dculr);
      `FCOV_REG.set_cov_registers_write(`DCULR,`GRM.dculr,`VALUE_REGISTER_DATA);                         
    end
  endtask // set_dcu_looping

  // runs commands in the DCU (uses most commonly used parameter settings)
  task dcu_run;
    begin
      // run from the beginning to the last loaded instruction
      // with both the capture and compare enabled
      // (no stop on something)
      dcu_run_special(0, ccache_end_addr, 0, 0, 0, 1, 1);
    end
  endtask // dcu_run

  // runs commands in the DCU (uses most commonly used parameter settings but
  // with specified start and end addresses)
  task dcu_run_from;
    input [`CACHE_ADDR_WIDTH  -1:0] start_addr;
    input [`CACHE_ADDR_WIDTH  -1:0] end_addr;
    begin
      // run between the specified cache addresses
      // with both the capture and compare enabled
      // (no stop on something)
      dcu_run_special(start_addr, end_addr, 0, 0, 0, 1, 1);
    end
  endtask // dcu_run_from

  // runs commands in the DCU (all parameters are specied)
  task dcu_run_special;
    input [`CACHE_ADDR_WIDTH  -1:0] start_addr;
    input [`CACHE_ADDR_WIDTH  -1:0] end_addr;
    input [`DCU_FAIL_CNT_WIDTH-1:0] stop_fail_cnt;
    input                           stop_on_nfail;
    input                           stop_cap_on_full;
    input                           read_cap_en;
    input                           compare_en;
    begin
      `GRM.dcurr[3:0]   = `DCU_RUN;
      `GRM.dcurr[7:4]   = start_addr;
      `GRM.dcurr[11:8]  = end_addr;
      `GRM.dcurr[19:12] = stop_fail_cnt;
      `GRM.dcurr[20]    = stop_on_nfail;
      `GRM.dcurr[21]    = stop_cap_on_full;
      `GRM.dcurr[22]    = read_cap_en;
      `GRM.dcurr[23]    = compare_en;
      write_register(`DCURR, `GRM.dcurr);
      `FCOV_REG.set_cov_registers_write(`DCURR,`GRM.dcurr,`VALUE_REGISTER_DATA);                         
    end
  endtask // dcu_run_special

  // stops the running of commands in the DCU
  task dcu_stop;
    begin
      `GRM.dcurr[3:0] = `DCU_STOP;
      write_register(`DCURR, `GRM.dcurr);
      `FCOV_REG.set_cov_registers_write(`DCURR,`GRM.dcurr,`VALUE_REGISTER_DATA);                         
    end
  endtask // dcu_stop
  
  task dcu_stop_loop;
    begin
      `GRM.dcurr[3:0] = `DCU_STOP_LOOP;
      write_register(`DCURR, `GRM.dcurr);
      `FCOV_REG.set_cov_registers_write(`DCURR,`GRM.dcurr,`VALUE_REGISTER_DATA);                         
      //`SYS.dcu_skip_dcusr1_chk = 1;
    end
  endtask // dcu_stop_loop
  
  task dcu_reset;
    begin
      `GRM.dcurr[3:0] = `DCU_RESET;
      write_register(`DCURR, `GRM.dcurr);
      `FCOV_REG.set_cov_registers_write(`DCURR,`GRM.dcurr,`VALUE_REGISTER_DATA);                         
    end
  endtask // dcu_reset

  task polling_dcusr0_rdone;
    reg [31:0]   tmp;
    begin
      // polling status...
      `CFG.disable_read_compare;
      tmp = 32'd0;
      while(tmp[0] == 1'b0) begin
        repeat (50) @(posedge `CFG.clk);
`ifdef FUNCOV        
        read_register_data(`DCUSR1, tmp);
`endif        
        read_register_data(`DCUSR0, tmp);
      end
      
      $display("-> %0t: [BENCH] DCUSR0.RDONE asserted...",$time);
      repeat (10) @(posedge `CFG.clk);      
      `GRM.dcusr0 = tmp;
      `CFG.enable_read_compare;
    end
  endtask  

  //---------------------------------------------------------------------------
  // Generic register polling - matches given value on a contiguous set of bits
  //---------------------------------------------------------------------------
  task poll_register;
    input integer                 reg_addr;            // Register address to poll on
    input integer                 poll_reg_bit_lo;     // Lower bit pos of field of interest
    input integer                 poll_reg_bit_hi;     // Upper bit address of field of interest
    input integer                 poll_reg_bits_value; // Value we're looking for
    input integer                 poll_interval;       // Register query interval (cfg_clk cycles)
    input integer                 poll_timeout;        // Cycles before timeout
    input reg [(100 * 8) - 1 : 0] msg_string;          // Message string to print at the end

      integer                        pidx;
      integer                        bit_idx;
      reg  [`REG_DATA_WIDTH - 1 : 0] reg_read_data;
      reg  [`REG_DATA_WIDTH - 1 : 0] reg_poll_bits;
      reg  [`REG_DATA_WIDTH - 1 : 0] reg_poll_bits_mask;
  
    begin
      $write("-> %0t: [BENCH] Polling register ", $time);
      `SYS.print_register(reg_addr);
      $display(" on bits [%0d:%0d] for value %0d ...", poll_reg_bit_hi, poll_reg_bit_lo, poll_reg_bits_value);

      // We're interested only in those bits we're polling on so mask out the rest
      reg_poll_bits_mask = {`REG_DATA_WIDTH{1'b0}};
      for (bit_idx = 0; bit_idx < `REG_DATA_WIDTH; bit_idx = bit_idx + 1) begin
        if (bit_idx < (poll_reg_bit_hi - poll_reg_bit_lo + 1))
          reg_poll_bits_mask[bit_idx] = 1'b1;
      end

      fork

        // Poll register
        begin : fork_polling
          // Wait a few cycles prior to first read
          repeat (poll_init_wait) @(posedge `CFG.clk);
          `CFG.disable_read_compare;
          // Initial register read
          @(posedge `CFG.clk);
          `CFG.read_register_data(reg_addr, reg_read_data);
          // Extract field of interest from register read data
          pidx = 0;
          for (bit_idx = 0; bit_idx < `REG_DATA_WIDTH; bit_idx = bit_idx + 1) begin
            if ((bit_idx <= poll_reg_bit_hi) && (bit_idx >= poll_reg_bit_lo)) begin
              reg_poll_bits[pidx] = reg_read_data[bit_idx];
              pidx = pidx + 1;
            end
          end
 
          while ((reg_poll_bits & reg_poll_bits_mask) != poll_reg_bits_value) begin
            // Keep reading register at intervals
            repeat (poll_interval) @(posedge `CFG.clk);
            `CFG.read_register_data(reg_addr, reg_read_data);
            // Extract field of interest from register read data
            pidx = 0;
            for (bit_idx = 0; bit_idx < `REG_DATA_WIDTH; bit_idx = bit_idx + 1) begin
              if ((bit_idx <= poll_reg_bit_hi) && (bit_idx >= poll_reg_bit_lo)) begin
                reg_poll_bits[pidx] = reg_read_data[bit_idx];
                pidx = pidx + 1;
              end
            end
          end
          // We got what we were looking for
          disable fork_timeout;
          $display("-> %0t: [BENCH] %0s", $time, msg_string);
          repeat (poll_post_wait) @(posedge `CFG.clk);
          `CFG.enable_read_compare;
        end

        // Timeout
        begin : fork_timeout
`ifdef DWC_DDRPHY_JTAG          
          repeat (poll_timeout*10) @(posedge `CFG.clk);
`else          
          repeat (poll_timeout) @(posedge `CFG.clk);
`endif          
          `SYS.error;
          $display("-> %0t: [BENCH] ERROR: Register polling at address 0x%0h on bits [%0d:%0d] for value %0d timed out after %0d cfg_clk cycles!", $time, reg_addr, poll_reg_bit_hi, poll_reg_bit_lo, poll_reg_bits_value, poll_timeout);
          disable fork_polling;
        end

      join

    end
  endtask

  //---------------------------------------------------------------------------
  // Set the DCU to capture read data after the Nth word
  //---------------------------------------------------------------------------
  task set_dcugcr_read_capt_start;
    input reg [15:0]  tmp;
    begin
      `GRM.dcugcr[15:0] = tmp;
      write_register(`DCUGCR, `GRM.dcugcr);
      `FCOV_REG.set_cov_registers_write(`DCUGCR,`GRM.dcugcr,`VALUE_REGISTER_DATA);                         
    end
  endtask // set_dcugcr_read_capt_start
  
  //---------------------------------------------------------------------------
  // SDRAM Initialization
  //---------------------------------------------------------------------------
  // executes the SDRAM initialization sequence when initiated through the 
  // configuration port (DCU)
  task initialize_sdram;
    integer i;
    integer cc_segs;
    begin
      $display("-> %0t: [CFG] INFO: initialize_sdram from CFG for ddr_mode= %0d", $time, `GRM.ddr_mode);
      
      // determine how many times the DCU needs to be loaded and executed, especially
      // for smaller depths
      case (`GRM.ddr_mode)
        `DDR3_MODE, `DDR4_MODE: begin
          cc_segs = (`CCACHE_DEPTH == 16) ? 1 :
                    (`CCACHE_DEPTH == 8 ) ? 2 : 3;
        end
        
        `DDR2_MODE: begin
          cc_segs = (`CCACHE_DEPTH == 16) ? 1 :
                    (`CCACHE_DEPTH == 8 ) ? 2 : 4;
        end

        `LPDDR2_MODE: begin
          cc_segs = (`CCACHE_DEPTH == 16) ? 1 :
                    (`CCACHE_DEPTH == 8 ) ? 2 : 3;
        end
        
        `LPDDR3_MODE: begin
          cc_segs = (`CCACHE_DEPTH == 16) ? 1 :
                    (`CCACHE_DEPTH == 8 ) ? 2 : 3;
        end
        
      endcase // case (`GRM.ddr_mode)
   
      for (i=0; i<cc_segs; i=i+1) begin
        // setup for loading DCU caches (with auto address increment)
        ccache_loaded   = 0;
        ccache_end_addr = 0;
        set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);

        case (`GRM.ddr_mode)
          `DDR4_MODE:   initialize_ddr4_sdram(cc_segs, i);
          `DDR3_MODE:   initialize_ddr3_sdram(cc_segs, i);
          `DDR2_MODE:   initialize_ddr2_sdram(cc_segs, i);
          `LPDDR2_MODE: initialize_lpddrx_sdram(cc_segs, i);
          `LPDDR3_MODE: initialize_lpddrx_sdram(cc_segs, i);
        endcase // case (`GRM.ddr_mode)

         // run the commands starting at address 0 to end loaded address
        dcu_run;

         // wait for the DCU commands run to be finished
        `ifdef SDF_ANNOTATE
          polling_dcusr0_rdone();
        `elsif GATE_LEVEL_SIM
          polling_dcusr0_rdone();
        `else
          @(posedge `PUB.dcu_done);
        `endif

          // turn off dcu report dcu status, as there are no expected return/read data
          // just from the init sequence.
          `GRM.dcu_was_run = 1'b0;
         
          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
       end   
    end
  endtask // initialize_sdram


  // Controller SDRAM initialization
  // -------------------------------
  // DDR4 DRAM initialization
  // Note: for ZCAL_LONG command, the DTP value can be either tDLLK or tDINITZQ, whichever is bigger
  task initialize_ddr4_sdram;
    input [31:0] cc_segs;
    input [31:0] cc_seg_no;
`ifdef DWC_DDR_RDIMM
    reg [4:0] cr_addr;
    reg [3:0] cr_data_l4;
    reg [7:0] cr_data_l8;
    reg [`DCU_DTP_WIDTH-1:0] cr_dtp;
`endif
    reg [`DCU_RPT_WIDTH    -1:0] rpt;
    reg [`DCU_DTP_WIDTH    -1:0] dtp;
    reg [`DCU_TAG_WIDTH    -1:0] tag;
    reg [`CMD_WIDTH        -1:0] cmd;
    reg [`SDRAM_RANK_WIDTH -1:0] rank;
    reg [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH   -1:0] bank;
    reg [`PUB_ADDR_WIDTH   -1:0] addr;
    reg [`DCU_BYTE_WIDTH  -1:0]  mask;
    reg [`DCU_DATA_WIDTH  -1:0] data;
    reg [3+5+2+4+`SDRAM_RANK_WIDTH+4+18+`DCU_BYTE_WIDTH+5] cache_word [0:111];
    integer                     dimm_idx;
    integer                     cc_idx;      // Index into command cache (limited to cache size)
    integer                     cc_prog_idx; // Index complete command cache program (can be larger than cache depth)
    integer                     cc_num_prog_wrds; // Number of words in complete command cache program (can be larger than cache depth)
    integer                     cc_per_dimm;   // Index used for RDIMMCR* Per DIMM access
    integer                     cc_per_rank;  //Index for MR* Per Rank
    reg [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH  -2:0] mr0_addr, mr1_addr, mr2_addr, mr3_addr;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] mr0_data;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] mr1_data [`DWC_NO_OF_RANKS-1:0], mr2_data [`DWC_NO_OF_RANKS-1:0], mr3_data [`DWC_NO_OF_RANKS-1:0];
    reg [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH  -2:0] mr4_addr, mr5_addr, mr6_addr, mr7_addr;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] mr4_data, mr7_data;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] mr5_data [`DWC_NO_OF_RANKS-1:0], mr6_data [`DWC_NO_OF_RANKS-1:0];
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] RESET_LO, RESET_HI, CKE_LO, CKE_HI;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] rdimm_cmd_word;
    begin
      $display("-> %0t: [CFG] INFO: initialize_ddr4_sdram from CFG.... ", $time);
      // pad the mode register addresses and data to width of DCU command widths
      mr0_addr = MR0;
      mr1_addr = MR1;
      mr2_addr = MR2;
      mr3_addr = MR3;
      mr4_addr = MR4;
      mr5_addr = MR5;
      mr6_addr = MR6;
      mr7_addr = MR7;
      mr0_data = `GRM.mr0;
      for(cc_per_rank=0; cc_per_rank<`DWC_NO_OF_RANKS ; cc_per_rank=cc_per_rank+1)
      begin
        mr1_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr1[cc_per_rank][31:0];
        mr2_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr2[cc_per_rank][31:0];
        mr3_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr3[          0][31:0];
      end
      mr4_data = `GRM.mr4;
      for(cc_per_rank=0; cc_per_rank<`DWC_NO_OF_RANKS ; cc_per_rank=cc_per_rank+1)
      begin
        mr5_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr5[cc_per_rank][31:0];
        mr6_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr6[cc_per_rank][31:0];
      end
      mr7_data = `GRM.mr7;
      RESET_LO = `RESET_LO;
      RESET_HI = `RESET_HI;
      CKE_LO   = `CKE_LO;
      CKE_HI   = `CKE_HI;
      
      // assemble all the DCU commands: there can be up to 26 DCU commands to initialize the
      // DDR3 depending on whether RDIMM is enable, i.e. 10 generic SDRAM inialization commands and
      // up to 16 RDIMM buffer chip register write commands
     $display("-> %0t: [CFG] INFO: initialize_ddr4_cke using DCU.... ", $time);
      cache_word[0] = {`DCU_NORPT, `DTP_tDINITRST,   `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, RESET_LO,  {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[1] = {`DCU_NORPT, `DTP_tNODTP,      `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, RESET_HI,  {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[2] = {`DCU_NORPT, `DTP_tDINITCKELO, `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, CKE_LO,    {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[3] = {`DCU_NORPT, `DTP_tDINITCKEHI, `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, CKE_HI,    {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cc_prog_idx = 4;

    cc_num_prog_wrds = cc_prog_idx; 
  // load and execute the instructions into the DCU - may need multiple loads/executions if the program is larger than the cache
      for (cc_idx = 0; cc_idx < cc_num_prog_wrds; cc_idx = cc_idx + 1) begin
        if ((cc_idx % `CCACHE_DEPTH) == 0) begin
          // at the beginning of a new load: 
          // setup for loading DCU caches (with auto address increment)
          ccache_loaded   = 0;
          ccache_end_addr = 0;
          set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);
        end

        // load the command into the cache
        {rpt, dtp, tag, cmd, rank, bank, addr, mask, data} = cache_word[cc_idx];
        if (`SYS.verbose >= 9) begin
          $display("-> %0t: [CFG] INFO: --------------- cc_idx  = %0h ------------", $time, cc_idx);
          
          $display("-> %0t: [CFG] INFO: rpt   = %b ", $time, rpt);
          $display("-> %0t: [CFG] INFO: dtp   = %b ", $time, dtp);
          $display("-> %0t: [CFG] INFO: tag   = %b ", $time, tag);
          $display("-> %0t: [CFG] INFO: cmd   = %b ", $time, cmd);
          $display("-> %0t: [CFG] INFO: rank  = %b ", $time, rank);
          $display("-> %0t: [CFG] INFO: bank  = %b ", $time, bank);
          $display("-> %0t: [CFG] INFO: addr  = %b ", $time, addr);
          $display("-> %0t: [CFG] INFO: mask  = %b ", $time, mask);
          $display("-> %0t: [CFG] INFO: data  = %b ", $time, data);
        end
        
        load_dcu_command(rpt, dtp, tag, cmd, rank, bank, addr, mask, data);
        
        // Once the cache fills up, execute the program; may need to repeat
        // if there are more instructions left
       if (   ((cc_idx % `CCACHE_DEPTH) == (`CCACHE_DEPTH - 1)) // cache is full
            && (cc_num_prog_wrds - (cc_idx + 1) > 0)                     //  and there are more instructions still to be run
           ) 
        begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif
        end
      end


         // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif

  
    $display("-> %0t: [CFG] INFO: initialize_ddr4_rdimm using DCU.... ", $time);
       cc_prog_idx = 0;
`ifdef DWC_DDR_RDIMM
      // execute RDIMM initialization as part of DRAM initiialization in DCU
   `ifdef DWC_DDR_LRDIMM      
    /*  for (dimm_idx = 0; dimm_idx < `DWC_NO_OF_DIMMS; dimm_idx = dimm_idx+1) begin 
      `GRM.rdimmcr0[dimm_idx][10]=1'b1;       //LRDIMM Transparent Mode enable
     // `CFG.write_register(`RDIMMCR0+dimm_idx*`DX_REG_RANGE, `GRM.rdimmcr0[dimm_idx]); 
     // `CFG.write_register(`RDIMMCR0, `GRM.rdimmcr0[0]); 
      end 
     `GRM.rdimmgcr2 = 32'hffffffff; */
     // DIMM type is LRDIMM ,configure it to RC0D.
     `GRM.rdimmgcr2[13] = 1'b1; 
     `GRM.rdimmcr1[0][22]=1'b0;
     `CFG.write_register(`RDIMMCR1, `GRM.rdimmcr1[0]); 
   `endif

      for (cc_idx = 0; cc_idx < 27; cc_idx = cc_idx + 1) begin
        if (`GRM.rdimmgcr2[cc_idx] == 1'b1) begin
          cr_addr = cc_idx ;
          //for(cc_per_dimm=0; cc_per_dimm<`DWC_NO_OF_DIMMS ; cc_per_dimm=cc_per_dimm+1)begin
            if(cc_idx <16) begin
              cr_data_l4 = (cc_idx <8) ? `GRM.rdimmcr0[0][cc_idx *4 +: 4] : `GRM.rdimmcr1[0][(cc_idx -8)*4 +: 4];  
              rdimm_cmd_word = {{(`DWC_PHY_ADDR_WIDTH-13){1'b0}}, cr_data_l4, cr_addr, `RDIMMCRW};
            end
            else begin
              cr_data_l8 = (cc_idx <20) ? `GRM.rdimmcr2[0][(cc_idx-16) *8 +: 8] : ((cc_idx <24) ? `GRM.rdimmcr3[0][(cc_idx -20)*8 +: 8] :`GRM.rdimmcr4[0][(cc_idx -24)*8 +: 8]);
              rdimm_cmd_word = {{(`DWC_PHY_ADDR_WIDTH-17){1'b0}}, cr_data_l8, cr_addr, `RDIMMCRW};
            end
            if (cr_addr == 2 || cr_addr == 10) begin
            // spacing from RC2 and RC10 is tBCSTAB
              cr_dtp = `DTP_tBCSTAB;
            end else begin
            // spacing from other RCn is tBCMRD
              cr_dtp = `DTP_tBCMRD;
            end
            cache_word[cc_prog_idx] = {`DCU_NORPT, cr_dtp, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, rdimm_cmd_word, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
            cc_prog_idx = cc_prog_idx + 1;
         // end
        end
      end

      cc_num_prog_wrds = cc_prog_idx; 
 $display("cc_num_prog_wrds=%d,cc_idx=%d,cc_prog_idx=%d ",cc_num_prog_wrds,cc_idx,cc_prog_idx);
  // load and execute the instructions into the DCU - may need multiple loads/executions if the program is larger than the cache
      for (cc_idx = 0; cc_idx < cc_num_prog_wrds; cc_idx = cc_idx + 1) begin
        if ((cc_idx % `CCACHE_DEPTH) == 0) begin
          // at the beginning of a new load: 
          // setup for loading DCU caches (with auto address increment)
          ccache_loaded   = 0;
          ccache_end_addr = 0;
          set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);
        end

        // load the command into the cache
        {rpt, dtp, tag, cmd, rank, bank, addr, mask, data} = cache_word[cc_idx];
        if (`SYS.verbose >= 9) begin
          $display("-> %0t: [CFG] INFO: --------------- cc_idx  = %0h ------------", $time, cc_idx);
          
          $display("-> %0t: [CFG] INFO: rpt   = %b ", $time, rpt);
          $display("-> %0t: [CFG] INFO: dtp   = %b ", $time, dtp);
          $display("-> %0t: [CFG] INFO: tag   = %b ", $time, tag);
          $display("-> %0t: [CFG] INFO: cmd   = %b ", $time, cmd);
          $display("-> %0t: [CFG] INFO: rank  = %b ", $time, rank);
          $display("-> %0t: [CFG] INFO: bank  = %b ", $time, bank);
          $display("-> %0t: [CFG] INFO: addr  = %b ", $time, addr);
          $display("-> %0t: [CFG] INFO: mask  = %b ", $time, mask);
          $display("-> %0t: [CFG] INFO: data  = %b ", $time, data);
        end
        
        load_dcu_command(rpt, dtp, tag, cmd, rank, bank, addr, mask, data);
        
        // Once the cache fills up, execute the program; may need to repeat
        // if there are more instructions left
        if (   ((cc_idx % `CCACHE_DEPTH) == (`CCACHE_DEPTH - 1)) // cache is full
            && (cc_num_prog_wrds - (cc_idx + 1) > 0)                     //  and there are more instructions still to be run
           ) 
        begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif
        end
      end

          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done)
           `endif
          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
`endif


  $display("-> %0t: [CFG] INFO: initialize_ddr4_lrdimm using DCU.... ", $time);
    cc_prog_idx = 0;
`ifdef DWC_DDR_LRDIMM
      //execute LRDIMM initialization as part of DRAM initiialization in DCU 
      //DATA Buffer Programming 
          cache_word[cc_prog_idx+0] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h00, 4'h1, {2'b0,mr6_addr}, `RDIMMCRW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};  // send reset to DB
         cache_word[cc_prog_idx+1] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h00, 4'h5, {2'b0,mr6_addr}, `RDIMMCRW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};  // CW Write Operation
        
          cache_word[cc_prog_idx+2] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h00, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};  // function space 0
          cache_word[cc_prog_idx+3] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, {1'b0,`GRM.mr1[0][10:8]}, 5'h00, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}}; // BCW C00 
	  cache_word[cc_prog_idx+4] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, {2'b00,`GRM.mr2[0][10:9]}, 5'h01, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}}; // BCW C01 
          cache_word[cc_prog_idx+5] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}},  4'h7, {5'h10, {1'b0,`GRM.mr5[0][8:6]}, 5'h02, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}}; // BCW C02
          cache_word[cc_prog_idx+6] = {`DCU_NORPT, `DTP_tBCSTAB, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h2, 5'h03, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}}; // BCW C03
          cache_word[cc_prog_idx+7] = {`DCU_NORPT, `DTP_tBCSTAB, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h6, 5'h04, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}}; // BCW C04
          cache_word[cc_prog_idx+8] = {`DCU_NORPT, `DTP_tBCSTAB, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h5, 5'h05, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+9] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h07, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+10] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h08, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+11] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h09, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
       for(cc_per_dimm=0; cc_per_dimm<`DWC_NO_OF_DIMMS ; cc_per_dimm=cc_per_dimm+1)begin 
          cc_prog_idx = cc_per_dimm;
          cache_word[cc_prog_idx+12] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, {1'b0,`GRM.rdimmcr1[cc_per_dimm][10:8]}, 5'h0a, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
       end
          cache_word[cc_prog_idx+13] = {`DCU_NORPT, `DTP_tBCSTAB, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h0b, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+14] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h0c, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+15] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h0d, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+16] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h0e, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+17] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h0, 5'h0f, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+18] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h06, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+19] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h00, 5'h13, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+20] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h05, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+21] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h19, 5'h15, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+22] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h00, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+23] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h06, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+24] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h00, 5'h13, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+25] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h05, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+26] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h14, 5'h14, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cache_word[cc_prog_idx+27] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h00, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
         
     cc_num_prog_wrds = cc_prog_idx + 28 ; 
    // load and execute the instructions into the DCU - may need multiple loads/executions if the program is larger than the cache
      for (cc_idx = 0; cc_idx < cc_num_prog_wrds; cc_idx = cc_idx + 1) begin
        if ((cc_idx % `CCACHE_DEPTH) == 0) begin
          // at the beginning of a new load: 
          // setup for loading DCU caches (with auto address increment)
          ccache_loaded   = 0;
          ccache_end_addr = 0;
          set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);
        end

        // load the command into the cache
        {rpt, dtp, tag, cmd, rank, bank, addr, mask, data} = cache_word[cc_idx];
        if (`SYS.verbose >= 9) begin
          $display("-> %0t: [CFG] INFO: --------------- cc_idx  = %0h ------------", $time, cc_idx);
          
          $display("-> %0t: [CFG] INFO: rpt   = %b ", $time, rpt);
          $display("-> %0t: [CFG] INFO: dtp   = %b ", $time, dtp);
          $display("-> %0t: [CFG] INFO: tag   = %b ", $time, tag);
          $display("-> %0t: [CFG] INFO: cmd   = %b ", $time, cmd);
          $display("-> %0t: [CFG] INFO: rank  = %b ", $time, rank);
          $display("-> %0t: [CFG] INFO: bank  = %b ", $time, bank);
          $display("-> %0t: [CFG] INFO: addr  = %b ", $time, addr);
          $display("-> %0t: [CFG] INFO: mask  = %b ", $time, mask);
          $display("-> %0t: [CFG] INFO: data  = %b ", $time, data);
        end
        
        load_dcu_command(rpt, dtp, tag, cmd, rank, bank, addr, mask, data);
        
        // Once the cache fills up, execute the program; may need to repeat
        // if there are more instructions left
        if (   ((cc_idx % `CCACHE_DEPTH) == (`CCACHE_DEPTH - 1)) // cache is full
            && (cc_num_prog_wrds - (cc_idx + 1) > 0)                     //  and there are more instructions still to be run
           ) 
        begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif

          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
        end
      end  // for (cc_idx ...
     
      if (cc_num_prog_wrds != 16) begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif 
          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
      end
`endif

   $display("-> %0t: [CFG] INFO: initialize_ddr4_dram by DCU.... ", $time);
      cc_prog_idx = 0;
      //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
      for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
      begin
      $display("mr3_addr=%b,mr6_addr=%b,mr5_addr=%b,mr4_addr=%b,mr2_addr=%b,mr1_addr=%b,mr0_addr=%b",{1'b0,mr3_addr},{1'b1,mr6_addr},mr5_addr,mr4_addr,mr2_addr,mr1_addr,mr0_addr);
        cache_word[cc_prog_idx+0] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr3_addr},                mr3_data[0],                          {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+1] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr3_addr},                mr3_data[0],                          {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+2] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr6_addr},                mr6_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+3] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr6_addr},                mr6_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};

        `SYS.disable_clock_checks;
        cache_word[cc_prog_idx+4] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr5_addr},                mr5_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+5] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr5_addr},                mr5_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        `SYS.enable_clock_checks;
      end
        cache_word[cc_prog_idx+6] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr4_addr},                mr4_data,                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+7] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr4_addr},                mr4_data,                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};

      //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
      for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
      begin
        cache_word[cc_prog_idx+8] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr2_addr},                mr2_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+9] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr2_addr},                mr2_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+10] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr1_addr},                mr1_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+11] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr1_addr},                mr1_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      end
      
      mr0_data[8] = 1'b1;                                                       

      cache_word[cc_prog_idx+12] = {`DCU_NORPT, `DTP_tMOD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b0,mr0_addr},                mr0_data,                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[cc_prog_idx+13] = {`DCU_NORPT, `DTP_tMOD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, {1'b1,mr0_addr},                mr0_data,                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};


      // send ZQCAL command 
      cache_word[cc_prog_idx+14] = {`DCU_NORPT, `DTP_tDINITZQ,  `DCU_ALL_RANKS, `ZQCAL_LONG, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, {`PUB_ADDR_WIDTH{1'b0}}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[cc_prog_idx+15] = {`DCU_RPT1X, `DTP_tNODTP, `DCU_ALL_RANKS, `SDRAM_NOP,  {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, {`PUB_ADDR_WIDTH{1'b0}}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[cc_prog_idx+16] = {`DCU_NORPT, `DTP_tBCMRD, `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {1'h1, 8'h00, 5'h16, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};  // function space 0
      cache_word[cc_prog_idx+17] = {`DCU_NORPT, `DTP_tDINITZQ, `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, 4'h7, {5'h10, 4'h1, 5'h06, `RDIMMBCW}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};  // BCW c06
      
      
      cc_num_prog_wrds = cc_prog_idx +  18 ; // total commands to be loaded

      // load and execute the instructions into the DCU - may need multiple loads/executions if the program is larger than the cache
      for (cc_idx = 0; cc_idx < cc_num_prog_wrds; cc_idx = cc_idx + 1) begin
        if ((cc_idx % `CCACHE_DEPTH) == 0) begin
          // at the beginning of a new load: 
          // setup for loading DCU caches (with auto address increment)
          ccache_loaded   = 0;
          ccache_end_addr = 0;
          set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);
        end

        // load the command into the cache
        {rpt, dtp, tag, cmd, rank, bank, addr, mask, data} = cache_word[cc_idx];
        if (`SYS.verbose >= 9) begin
          $display("-> %0t: [CFG] INFO: --------------- cc_idx  = %0h ------------", $time, cc_idx);
          
          $display("-> %0t: [CFG] INFO: rpt   = %b ", $time, rpt);
          $display("-> %0t: [CFG] INFO: dtp   = %b ", $time, dtp);
          $display("-> %0t: [CFG] INFO: tag   = %b ", $time, tag);
          $display("-> %0t: [CFG] INFO: cmd   = %b ", $time, cmd);
          $display("-> %0t: [CFG] INFO: rank  = %b ", $time, rank);
          $display("-> %0t: [CFG] INFO: bank  = %b ", $time, bank);
          $display("-> %0t: [CFG] INFO: addr  = %b ", $time, addr);
          $display("-> %0t: [CFG] INFO: mask  = %b ", $time, mask);
          $display("-> %0t: [CFG] INFO: data  = %b ", $time, data);
        end
        
        load_dcu_command(rpt, dtp, tag, cmd, rank, bank, addr, mask, data);
        
        // Once the cache fills up, execute the program; may need to repeat
        // if there are more instructions left
        if (   ((cc_idx % `CCACHE_DEPTH) == (`CCACHE_DEPTH - 1)) // cache is full
            && (cc_num_prog_wrds - (cc_idx + 1) > 0)                     //  and there are more instructions still to be run
           ) 
        begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif

          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
        end
      end  // for (cc_idx ...
     
      if (cc_num_prog_wrds != 16) begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
          `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
          `elsif GATE_LEVEL_SIM
            polling_dcusr0_rdone();
          `else
            @(posedge `PUB.dcu_done);
          `endif 
          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
      end
    end                                                                                 
  endtask // initialize_ddr4_sdram                                                      
                                                                                        
  // DDR3 DRAM initialization
  // Note: for ZCAL_LONG command, the DTP value can be either tDLLK or tDINITZQ, whichever is bigger
  task initialize_ddr3_sdram;
    input [31:0] cc_segs;
    input [31:0] cc_seg_no;
`ifdef DWC_DDR_RDIMM
    reg [3:0] cr_addr;
    reg [3:0] cr_data;
    reg [`DCU_DTP_WIDTH-1:0] cr_dtp;
`endif
    reg [`DCU_RPT_WIDTH    -1:0] rpt;
    reg [`DCU_DTP_WIDTH    -1:0] dtp;
    reg [`DCU_TAG_WIDTH    -1:0] tag;
    reg [`CMD_WIDTH        -1:0] cmd;
    reg [`SDRAM_RANK_WIDTH -1:0] rank;
    reg [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH   -1:0] bank;
    reg [`PUB_ADDR_WIDTH   -1:0] addr;
    reg [`DCU_BYTE_WIDTH  -1:0]  mask;
    reg [`DCU_DATA_WIDTH  -1:0] data;
    reg [`CCACHE_DATA_WIDTH-1:0] cache_word [0:25];
    integer                     cc_idx;      // Index into command cache (limited to cache size)
    integer                     cc_prog_idx; // Index complete command cache program (can be larger than cache depth)
    integer                     cc_num_prog_wrds; // Number of words in complete command cache program (can be larger than cache depth)
    integer                     cc_per_dimm;   // Index used for RDIMMCR* Per DIMM access
    integer                     cc_per_rank;  //Index for MR* Per Rank
    reg [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH  -1:0] mr0_addr, mr1_addr, mr2_addr, mr3_addr;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] mr0_data;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] mr1_data [`DWC_NO_OF_RANKS-1:0], mr2_data [`DWC_NO_OF_RANKS-1:0], mr3_data [`DWC_NO_OF_RANKS-1:0];
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] RESET_LO, RESET_HI, CKE_LO, CKE_HI;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] rdimm_cmd_word;
    begin
      $display("-> %0t: [CFG] INFO: initialize_ddr3_sdram from CFG.... ", $time);
      // pad the mode register addresses and data to width of DCU command widths
      mr0_addr = MR0;
      mr1_addr = MR1;
      mr2_addr = MR2;
      mr3_addr = MR3;
      mr0_data = `GRM.mr0;
      for(cc_per_rank=0; cc_per_rank<`DWC_NO_OF_RANKS ; cc_per_rank=cc_per_rank+1)
      begin
        mr1_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr1[cc_per_rank][31:0];
        mr2_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr2[cc_per_rank][31:0];
        mr3_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0] = `GRM.mr3[          0][31:0];
        if (`SYS.verbose >= 9) begin
          $display("-> %0t: [CFG] INFO: initialize_ddr3_sdram   mr1_data[%0d] = %0h.... ", $time, cc_per_rank, mr1_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0]);
          $display("-> %0t: [CFG] INFO: initialize_ddr3_sdram   mr2_data[%0d] = %0h.... ", $time, cc_per_rank, mr2_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0]);
          $display("-> %0t: [CFG] INFO: initialize_ddr3_sdram   mr3_data[%0d] = %0h.... ", $time, cc_per_rank, mr3_data[cc_per_rank][`DWC_PHY_ADDR_WIDTH  -1:0]);
        end
      end
      RESET_LO = `RESET_LO;
      RESET_HI = `RESET_HI;
      CKE_LO   = `CKE_LO;
      CKE_HI   = `CKE_HI;
      
      // assemble all the DCU commands: there can be up to 26 DCU commands to initialize the
      // DDR3 depending on whether RDIMM is enable, i.e. 10 generic SDRAM inialization commands and
      // up to 16 RDIMM buffer chip register write commands
      cache_word[0] = {`DCU_NORPT, `DTP_tDINITRST,   `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, RESET_LO,  {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[1] = {`DCU_NORPT, `DTP_tNODTP,      `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, RESET_HI,  {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[2] = {`DCU_NORPT, `DTP_tDINITCKELO, `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, CKE_LO,    {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[3] = {`DCU_NORPT, `DTP_tDINITCKEHI, `DCU_ALL_RANKS, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, CKE_HI,    {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cc_prog_idx = 4;


      
`ifdef DWC_DDR_RDIMM
      // execute RDIMM initialization as part of DRAM initiialization in DCU
      for (cc_idx = 0; cc_idx < 16; cc_idx = cc_idx + 1) begin
        if (`GRM.rdimmgcr1[16+cc_idx ] == 1'b1) begin
          cr_addr = cc_idx ;
          for(cc_per_dimm=0; cc_per_dimm<`DWC_NO_OF_DIMMS ; cc_per_dimm=cc_per_dimm+1)
            cr_data = (cc_idx <8) ? `GRM.rdimmcr0[cc_per_dimm][cc_idx *4 +: 4] : `GRM.rdimmcr1[cc_per_dimm][(cc_idx -8)*4 +: 4];
          if (cr_addr == 2 || cr_addr == 10) begin
            // spacing from RC2 and RC10 is tBCSTAB
            cr_dtp = `DTP_tBCSTAB;
          end else begin
            // spacing from other RCn is tBCMRD
            cr_dtp = `DTP_tBCMRD;
          end
          rdimm_cmd_word = {4'h0, cr_data, cr_addr, `RDIMMCRW};
          cache_word[cc_prog_idx] = {`DCU_NORPT, cr_dtp, `DCU_NOTAG, `SPECIAL_CMD, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, rdimm_cmd_word, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
          cc_prog_idx = cc_prog_idx + 1;
        end
      end
`endif

      //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
      for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
      begin
        cache_word[cc_prog_idx+0] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, mr2_addr,                mr2_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+1] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, mr3_addr,                mr3_data[0],                          {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
        cache_word[cc_prog_idx+2] = {`DCU_NORPT, `DTP_tMRD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, mr1_addr,                mr1_data[cc_per_rank],                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      end
      mr0_data[8] = 1'b1;                                                       
      cache_word[cc_prog_idx+3] = {`DCU_NORPT, `DTP_tMOD,   `DCU_ALL_RANKS, `LOAD_MODE,  {`SDRAM_RANK_WIDTH{1'b0}}, mr0_addr,                mr0_data,                {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[cc_prog_idx+4] = {`DCU_NORPT, `DTP_tDLLK,  `DCU_ALL_RANKS, `ZQCAL_LONG, {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, {`PUB_ADDR_WIDTH{1'b0}}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cache_word[cc_prog_idx+5] = {`DCU_RPT1X, `DTP_tNODTP, `DCU_ALL_RANKS, `SDRAM_NOP,  {`SDRAM_RANK_WIDTH{1'b0}}, {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}}, {`PUB_ADDR_WIDTH{1'b0}}, {`DCU_BYTE_WIDTH{1'b0}}, {`DCU_DATA_WIDTH{1'b0}}};
      cc_num_prog_wrds = cc_prog_idx + 6; // total commands to be loaded
      
      // load and execute the instructions into the DCU - may need multiple loads/executions if the program is larger than the cache
      for (cc_idx = 0; cc_idx < cc_num_prog_wrds; cc_idx = cc_idx + 1) begin
        if ((cc_idx % `CCACHE_DEPTH) == 0) begin
          // at the beginning of a new load: 
          // setup for loading DCU caches (with auto address increment)
          ccache_loaded   = 0;
          ccache_end_addr = 0;
          set_dcu_cache_access(`DCU_CCACHE, 1, 0, 0, 0);
        end

        // load the command into the cache
        {rpt, dtp, tag, cmd, rank, bank, addr, mask, data} = cache_word[cc_idx];
        if (`SYS.verbose >= 9) begin
          $display("-> %0t: [CFG] INFO: --------------- cc_idx  = %0h ------------", $time, cc_idx);
          
          $display("-> %0t: [CFG] INFO: rpt   = %b ", $time, rpt);
          $display("-> %0t: [CFG] INFO: dtp   = %b ", $time, dtp);
          $display("-> %0t: [CFG] INFO: tag   = %b ", $time, tag);
          $display("-> %0t: [CFG] INFO: cmd   = %b ", $time, cmd);
          $display("-> %0t: [CFG] INFO: rank  = %b ", $time, rank);
          $display("-> %0t: [CFG] INFO: bank  = %b ", $time, bank);
          $display("-> %0t: [CFG] INFO: addr  = %b ", $time, addr);
          $display("-> %0t: [CFG] INFO: mask  = %b ", $time, mask);
          $display("-> %0t: [CFG] INFO: data  = %b ", $time, data);
        end
        
        load_dcu_command(rpt, dtp, tag, cmd, rank, bank, addr, mask, data);
        
        // Once the cache fills up, execute the program; may need to repeat
        // if there are more instructions left
        if (   ((cc_idx % `CCACHE_DEPTH) == (`CCACHE_DEPTH - 1)) // cache is full
            && (cc_num_prog_wrds - (cc_idx + 1) > 0)                     //  and there are more instructions still to be run
           ) 
        begin
          // run the commands starting at address 0 to end loaded address
          dcu_run;

          // wait for the DCU commands run to be finished
         `ifdef SDF_ANNOTATE
            polling_dcusr0_rdone();
         `elsif GATE_LEVEL_SIM
           polling_dcusr0_rdone();
         `else
           @(posedge `PUB.dcu_done);
         `endif

          // wait a few clocks before starting to run
          repeat (32) @(posedge clk);
        end
      end  // for (cc_idx ...
    end                                                                                 
  endtask // initialize_ddr3_sdram                                                      
                                                                                        
  // DDR2 DRAM initialization                                                           
  task initialize_ddr2_sdram;                                                           
    input [31:0] cc_segs;
    input [31:0] cc_seg_no;
    integer      cc_per_rank;  //Index for MR* Per Rank
    begin                                                                               
      $display("-> %0t: [CFG] INFO: initialize_ddr2_sdram from CFG.... ", $time);

      // Initialize for all RANKs with `DCU_ALL_RANKS   
      cc_per_rank=0;

      if (cc_segs == 1 || cc_seg_no == 0) begin
        load_dcu_command(`DCU_NORPT, `DTP_tDINITCKELO, `DCU_ALL_RANKS, `SPECIAL_CMD,   0,   0,  `CKE_LO,   0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tDINITCKEHI, `DCU_ALL_RANKS, `SPECIAL_CMD,   0,   0,  `CKE_HI,   0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tRPA,        `DCU_ALL_RANKS, `PRECHARGE_ALL, 0,   0,        0,   0, {`DCU_DATA_WIDTH{1'b0}});
        //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
        for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
        begin
          load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR2, `GRM.mr2[cc_per_rank],   0, {`DCU_DATA_WIDTH{1'b0}});
        end
      end

      if (cc_segs == 1 || (cc_seg_no == 0 && cc_segs == 2) || (cc_seg_no == 1 && cc_segs == 4)) begin
        //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
        for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
        begin
          load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR3, `GRM.mr3[cc_per_rank],   0, {`DCU_DATA_WIDTH{1'b0}});
          load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR1, `GRM.mr1[cc_per_rank],   0, {`DCU_DATA_WIDTH{1'b0}});
        end
        `GRM.mr0[8] = 1'b1;                                                               
        load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR0, `GRM.mr0,   0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tRPA,        `DCU_ALL_RANKS, `PRECHARGE_ALL, 0,   0,        0,   0, {`DCU_DATA_WIDTH{1'b0}});
      end

      if (cc_segs == 1 || (cc_seg_no == 1 && cc_segs == 2) || (cc_seg_no == 2 && cc_segs == 4)) begin
        load_dcu_command(`DCU_RPT1X, `DTP_tRFC,        `DCU_ALL_RANKS, `REFRESH,       0,   0,        0,   0, {`DCU_DATA_WIDTH{1'b0}});

        `GRM.mr0[8] = 1'b0;                                                               
        load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR0, `GRM.mr0,   0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tDLLK,       `DCU_ALL_RANKS, `SDRAM_NOP,     0,   0,        0,   0, {`DCU_DATA_WIDTH{1'b0}});
        //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
        for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
        begin
          `GRM.mr1[cc_per_rank][9:7] = 3'b111;                                                           
          load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR1, `GRM.mr1[cc_per_rank],   0, {`DCU_DATA_WIDTH{1'b0}});
        end
      end

      for(cc_per_rank=0; cc_per_rank<`DWC_NO_OF_RANKS ; cc_per_rank=cc_per_rank+1)
      begin
       `GRM.mr1[cc_per_rank][9:7] = 3'b000;
      end
        
      if (cc_segs == 1 || (cc_seg_no == 1 && cc_segs == 2) || (cc_seg_no == 3 && cc_segs == 4)) begin
        for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
        begin
          load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,     0, MR1, `GRM.mr1[cc_per_rank],   0, {`DCU_DATA_WIDTH{1'b0}});
        end
        load_dcu_command(`DCU_NORPT, `DTP_tNODTP,      `DCU_ALL_RANKS, `SDRAM_NOP,     0,   0,        0,   0, {`DCU_DATA_WIDTH{1'b0}});
      end
    end  
  endtask // initialize_ddr2_sdram  

  // LPDDR2 DRAM initialization
  task initialize_lpddrx_sdram;
    input [31:0]                                  cc_segs;
    input [31:0]                                  cc_seg_no;
    reg [`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH-1:0] bank;
    reg [`DWC_PHY_ADDR_WIDTH-1:0]                 addr;
    integer                                       cc_per_rank;  //Index for MR* Per Rank
    begin
      $display("-> %0t: [CFG] INFO: initialize_lpddrx_sdram from CFG.... ", $time);

      if (cc_segs == 1 || cc_seg_no == 0) begin
        bank = {`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH{1'b0}};
        load_dcu_command(`DCU_NORPT, `DTP_tDINITCKEHI, `DCU_ALL_RANKS, `SPECIAL_CMD, 0, bank, `CKE_LO,           0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tDINITCKELO, `DCU_ALL_RANKS, `SPECIAL_CMD, 0, bank, `CKE_HI,           0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,   0, bank, {8'h00,    8'h3F}, 0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tDINITRST,   `DCU_ALL_RANKS, `SDRAM_NOP,   0, bank,                 0, 0, {`DCU_DATA_WIDTH{1'b0}});
      end
      if (cc_segs == 1 || (cc_seg_no == 0 && cc_segs == 2) || (cc_seg_no == 1 && cc_segs == 3)) begin
        {bank, addr} = {{(`DWC_PHY_ADDR_WIDTH+`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH-16){1'b0}},  8'hFF,    8'h0A};
        load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,   0, bank, {8'hFF,    8'h0A}, 0, {`DCU_DATA_WIDTH{1'b0}});
        load_dcu_command(`DCU_NORPT, `DTP_tDINITZQ,    `DCU_ALL_RANKS, `SDRAM_NOP,   0, bank,                 0, 0, {`DCU_DATA_WIDTH{1'b0}});
        {bank, addr} = {{(`DWC_PHY_ADDR_WIDTH+`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH-16){1'b0}},`GRM.mr1[0], 8'H01};
        load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,   0, bank, {`GRM.mr1[0], 8'H01}, 0, {`DCU_DATA_WIDTH{1'b0}});
        {bank, addr} = {{(`DWC_PHY_ADDR_WIDTH+`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH-16){1'b0}},`GRM.mr2[0], 8'h02};
        load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,   0, bank, {`GRM.mr2[0], 8'h02}, 0, {`DCU_DATA_WIDTH{1'b0}});
      end
      if (cc_segs == 1 || (cc_seg_no == 1 && cc_segs == 2) || (cc_seg_no == 2 && cc_segs == 3)) begin
        //  Initialize for all RANKs with `DCU_ALL_RANKS; ie: cc_per_rank == 0
        for(cc_per_rank=0; cc_per_rank<1 ; cc_per_rank=cc_per_rank+1)
        begin
          {bank, addr} = {{(`DWC_PHY_ADDR_WIDTH+`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH-16){1'b0}},  `GRM.mr3[cc_per_rank], 8'h03};
          load_dcu_command(`DCU_NORPT, `DTP_tMRD,        `DCU_ALL_RANKS, `LOAD_MODE,   0, bank, {`GRM.mr3[cc_per_rank], 8'h03}, 0, {`DCU_DATA_WIDTH{1'b0}});
        end
      end
    end
  endtask // initialize_lpddr2_sdram

  
endmodule // cfg_bfm
