/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys. All rights reserved.                          *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Configuration Bus Monitor                                     *
 *              Monitors the interface bus between the chip logic and the     *
 *              DDR controller configuration port Board Delay                 *
 *                                                                            *
 *****************************************************************************/

module cfg_mnt (
                rst_b,     // configuration reset
                clk,       // configuration clock
                rqvld,     // configuration request valid
                cmd,       // configuration command bus
                a,         // configuration address
                d,         // configuration data input
                qvld,      // configuration data output valid
                q,         // configuration data output
                jtag_en,   // configuration request valid
                jtag_rqvld, // configuration request valid
                jtag_cmd,   // configuration command bus
                jtag_a,     // configuration address
                jtag_d,     // configuration data input
                jtag_qvld,  // configuration data output valid
                jtag_q      // configuration data output
                );

  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  

  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                       rst_b;     // configuration asynshronous reset
  input                       clk;       // configuration clock
  input                       rqvld;     // configuration request valid
  input [`REG_CMD_WIDTH-1:0]  cmd;       // configuration command bus
  input [`REG_ADDR_WIDTH-1:0] a;         // configuration address
  input [`REG_DATA_WIDTH-1:0] d;         // configuration data input
  input                       qvld;      // configuration data output valid
  input [`REG_DATA_WIDTH-1:0] q;         // configuration data output

  input                       jtag_en;    // configuration request valid
  input                       jtag_rqvld; // configuration request valid
  input [`REG_CMD_WIDTH-1:0]  jtag_cmd;   // configuration command bus
  input [`REG_ADDR_WIDTH-1:0] jtag_a;     // configuration address
  input [`REG_DATA_WIDTH-1:0] jtag_d;     // configuration data input
  input                       jtag_qvld;  // configuration data output valid
  input [`REG_DATA_WIDTH-1:0] jtag_q;     // configuration data output

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [31:0]                  op;
  reg                         mnt_en;
  reg                         nop_mnt_en;
  reg [31:0]                  nop_cnt;
  reg                         grm_cmp_en;
  reg                         undf_mnt_en;


  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  initial
    begin: initialize

      // by default, monitoring is disabled unless forced by a compile
      // directive or enabled through call to enable_monitor task
      mnt_en      = 1'b0;
      grm_cmp_en  = 1'b0;
      undf_mnt_en = 1'b1;

      // NOPs are by default enabled to be monitored
      nop_mnt_en = 1'b1;
      nop_cnt = 0;
    end

  // monitor enable/disable
  task enable_monitor;
    begin
      mnt_en = 1'b1;
    end
  endtask // enable_monitor

  task disable_monitor;
    begin
      mnt_en = 1'b0;
    end
  endtask // disable_monitor


  // monitor NOPs enable/disable
  task enable_nops_monitor;
    begin
      nop_mnt_en = 1'b1;
    end
  endtask // enable_nops_monitor
  
  task disable_nops_monitor;
    begin
      nop_mnt_en = 1'b0;
    end
  endtask // disable_nops_monitor

  task enable_grm_comparison;
    begin
      grm_cmp_en = 1'b1;
    end
  endtask // enable_grm_comparison
  
  task disable_grm_comparison;
    begin
      grm_cmp_en = 1'b0;
    end
  endtask // disable_grm_comparison

  // undefined value monitor
  // disable/enable the monitoring and resulting warning when data has
  // undefined (X/Z) values
  task enable_undefined_warning;
    begin
      undf_mnt_en = 1'b1;
    end
  endtask // enable_undefined_warning

  task disable_undefined_warning;
    begin
      undf_mnt_en = 1'b0;
    end
  endtask // disable_undefined_warning

  
  //---------------------------------------------------------------------------
  // Command Monitor
  //---------------------------------------------------------------------------
  // monitors the commands being sent to the DDR SDRAMs
  always @(posedge clk)
    begin: monitor_command
      if (mnt_en === 1'b1)
        begin
          // decode command from CFG
          // all bits are fully populated - so no need for exact decoding
          if ((valid_bus(cmd)) && (jtag_en === 1'b0)) 
            begin
              case (cmd)
                `REG_READ:  op = `CFG_REG_READ;
                `REG_WRITE: op = `CFG_REG_WRITE;
                default:    op = `BAD_MEM_OP;
              endcase // case(cmd)
            end
          else
            begin
              if (jtag_en === 1'b0)
                op = `BAD_MEM_OP;
            end

          if ((rqvld === 1'b1) && (jtag_en === 1'b0))
            begin
              // command requested: report operation
              `SYS.message(`CHIP_CFG, op, {d, a});
              if (undf_mnt_en == 1'b1) begin
                check_undefined_values(op);
              end
              // if comparison with GRM is enabled in the monitor, write to
              // the GRM.
              if (grm_cmp_en == 1'b1)
                case (op)
                  `CFG_REG_WRITE: `GRM.write_register(a, d);
                  `CFG_REG_READ:  `GRM.read_register(a);
                endcase // case(op)
            end // if (rqvld === 1'b1)


          // decode command from JTAG
          // all bits are fully populated - so no need for exact decoding
          if ((valid_bus(jtag_cmd)) && (jtag_en === 1'b1))
            begin
              case (jtag_cmd)
                `REG_READ:  op = `JTAG_REG_READ;
                `REG_WRITE: op = `JTAG_REG_WRITE;
                default:    op = `BAD_MEM_OP;
              endcase // case(cmd)
            end
          else
            begin
              if (jtag_en === 1'b1)
                op = `BAD_MEM_OP;
            end
         
          if ((jtag_rqvld === 1'b1) && (jtag_en === 1'b1))
            begin
              // command requested: report operation
              `SYS.message(`JTAG_CFG, op, {jtag_d, jtag_a});
              if (undf_mnt_en == 1'b1) begin
                check_undefined_values(op);
              end
              // if comparison with GRM is enabled in the monitor, write to
              // the GRM.
              if (grm_cmp_en == 1'b1)
                case (op)
                  `JTAG_REG_WRITE: `GRM.write_register(jtag_a, jtag_d);
                  `JTAG_REG_READ:  `GRM.read_register(jtag_a);
                endcase // case(op)
            end

          // report errors and warnings
          report_errors;
        end // if (mnt_en === 1'b1)
      
    end // block: monitor_command
  
  
  //---------------------------------------------------------------------------
  // Read Data Output Monitor
  //---------------------------------------------------------------------------
  always @(posedge clk or negedge rst_b)
    begin: read_pipeline

      reg                       grm_access_type;
      reg [`REG_ADDR_WIDTH-1:0] grm_raddr;
      reg [`DATA_WIDTH-1:0]     grm_q;

      // report monitor: comparison is done in BFM; also check undefined
      // values
      if (mnt_en === 1'b1 && qvld === 1'b1 && jtag_en === 1'b0) 
        begin
          `SYS.message(`CHIP_CFG, `DATA_OUT, q);
          if (undf_mnt_en == 1'b1) begin
            check_undefined_values(`DATA_OUT);
          end
          
          // if comparison with GRM is enabled in the monitor then check 
          // the data against the GRM.
          if (grm_cmp_en == 1'b1)
            begin
              `GRM.get_register_data(grm_q, grm_raddr);
              if (q !== grm_q)
                begin
                  `SYS.error_message(`CHIP_CFG, `QERR, grm_q);
                end

              // keep track of how many read data have been received
              `GRM.log_register_read_output;
            end
        end

      if (mnt_en === 1'b1 && jtag_qvld === 1'b1 && jtag_en === 1'b1) 
        begin
          `SYS.message(`JTAG_CFG, `DATA_OUT, jtag_q);
          if (undf_mnt_en == 1'b1) begin
            check_undefined_values(`DATA_OUT);
          end
          
          // if comparison with GRM is enabled in the monitor then check 
          // the data against the GRM.
          if (grm_cmp_en == 1'b1)
            begin
              `GRM.get_register_data(grm_q, grm_raddr);
              if (jtag_q !== grm_q)
                begin
                  `SYS.error_message(`JTAG_CFG, `QERR, grm_q);
                end

              // keep track of how many read data have been received
              `GRM.log_register_read_output;
            end
        end

      
    end // block: read_pipeline  


  //---------------------------------------------------------------------------
  // Errors and Warnings
  //---------------------------------------------------------------------------
  // reports errors and warnings
  task report_errors;
    begin
      
      // TBD
    end
  endtask // report_errors


  // check undefined values
  // ----------------------
  // checks and reports undefined values on buses
  task check_undefined_values;
    input [31:0] op;
    begin
      if (!valid_bus(cmd) && jtag_en === 1'b0) `SYS.error_message(`CHIP_CFG, `DATAXWARN, `CMD_PIN);
      
      if (op === `CFG_REG_WRITE && jtag_en === 1'b0)
        begin
          if (!valid_bus(d)) `SYS.error_message(`CHIP_CFG, `DATAXWARN, `D_PIN);
          if (!valid_bus(a)) `SYS.error_message(`CHIP_CFG, `DATAXWARN, `A_PIN);
        end
      
      if (op === `CFG_REG_READ && jtag_en === 1'b0)
        begin
          if (!valid_bus(a)) `SYS.error_message(`CHIP_CFG, `DATAXWARN, `A_PIN);
        end

      if (op === `DATA_OUT && jtag_en === 1'b0)
        begin
          if (!valid_bus(q)) `SYS.error_message(`CHIP_CFG, `DATAXWARN, `Q_PIN);
        end

      if (!valid_bus(jtag_cmd) && jtag_en === 1'b1) `SYS.error_message(`JTAG_CFG, `DATAXWARN, `JTAG_CMD_PIN);
      
      if (op === `JTAG_REG_WRITE && jtag_en === 1'b1)
        begin
          if (!valid_bus(jtag_d)) `SYS.error_message(`JTAG_CFG, `DATAXWARN, `JTAG_D_PIN);
          if (!valid_bus(jtag_a)) `SYS.error_message(`JTAG_CFG, `DATAXWARN, `JTAG_A_PIN);
        end
      
      if (op === `JTAG_REG_READ && jtag_en === 1'b1)
        begin
          if (!valid_bus(jtag_a)) `SYS.error_message(`JTAG_CFG, `DATAXWARN, `JTAG_A_PIN);
        end

      if (op === `DATA_OUT && jtag_en === 1'b1)
        begin
          if (!valid_bus(jtag_q)) `SYS.error_message(`JTAG_CFG, `DATAXWARN, `JTAG_Q_PIN);
        end


    end
  endtask // check_undefined_values
  
  
  // valid bus/bit
  // -------------
  // checks if a variable or signal bus/bit has x's or z's
  function valid_bus;
    input [`DATA_WIDTH-1:0] the_bus;
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
  
endmodule // cfg_mnt
