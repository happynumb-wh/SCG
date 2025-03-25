/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: APB Bus Functional Model                                      *
 *                                                                            *
 *****************************************************************************/

`timescale 1ns/1ps

module apb_bfm
  (
   // configuration register Interface
   cfg_clk,
   cfg_rst_n,
   cfg_rqvld,
   cfg_cmd,
   cfg_a,
   cfg_d,
   cfg_q,
   cfg_qvld,

   // APB interface (pclk is same clock as cfg_clk)
   psel,
   penable,
   pwrite,
   paddr,
   pwdata,
   prdata
  );
  
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter DWC_APB_MASTER = 0;


  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  // configuration register Interface
  input                        cfg_clk;
  input                        cfg_rst_n;
  input                        cfg_rqvld;
  input                        cfg_cmd;
  input  [`REG_ADDR_WIDTH-1:0] cfg_a;
  input  [`REG_DATA_WIDTH-1:0] cfg_d;
  output [`REG_DATA_WIDTH-1:0] cfg_q;
  output                       cfg_qvld;

  // APB interface (pclk is same clock as cfg_clk)
  output                       psel;
  output                       penable;
  output                       pwrite;
  output [`REG_ADDR_WIDTH-1:0] paddr;
  output [`REG_DATA_WIDTH-1:0] pwdata;
  input  [`REG_DATA_WIDTH-1:0] prdata;
  
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                        apb_setup;
  reg                        psel;
  reg                        penable;
  reg                        pwrite;
  reg  [`REG_ADDR_WIDTH-1:0] paddr;
  reg  [`REG_DATA_WIDTH-1:0] pwdata;

  
  //---------------------------------------------------------------------------
  // CFG-to-APB Transalation
  //---------------------------------------------------------------------------
  // NOTE: it is asumed that the CFG BFM will always put a NOP after an
  //       instruction when APB port is enabled (this is done in the CFG BFM)
  always @(posedge cfg_clk or negedge cfg_rst_n) begin
    if (cfg_rst_n == 1'b0) begin
      psel   <= 1'b0;
      pwrite <= 1'b0;
      paddr  <= {`REG_ADDR_WIDTH{1'b0}};
      pwdata <= {`REG_DATA_WIDTH{1'b0}};
    end else begin
      if (cfg_rqvld) begin
        psel   <= 1'b1;
        pwrite <= cfg_cmd;
        paddr  <= cfg_a;
        pwdata <= cfg_d;
      end else if (penable) begin
        psel   <= 1'b0;
        pwrite <= 1'b0;
        paddr  <= {`REG_ADDR_WIDTH{1'b0}};
        pwdata <= {`REG_DATA_WIDTH{1'b0}};
      end
      apb_setup <= cfg_rqvld;
      penable   <= apb_setup;  
    end
  end

  // read path
  assign cfg_qvld = penable & !pwrite;
  assign cfg_q    = prdata;
  
endmodule // apb_bfm

