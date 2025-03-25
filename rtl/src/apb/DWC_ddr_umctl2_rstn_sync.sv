//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_rstn_sync.sv#2 $
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2018 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Component Name   : DWC_ddr_umctl2
// Component Version: 3.60a
// Release Type     : GA
//  ------------------------------------------------------------------------

// This line will be replaced by copyright header
// ----------------------------------------------------------------------------
// This module synchronises the active low reset signal with respect to the given 
// clock and outputs the N flop synchronized reset signal.
// This module also contains the MUX to bypass the generated reset in Test mode.
// In test mode, reset input pin will be connected to reset net.
// ----------------------------------------------------------------------------

`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_rstn_sync
  #(parameter BCM_VERIF_EN = 0)
   (input  rstn,            // active low input reset pin , async assertion, sync de-assertion
    input  clk,             // 
    input  rstn_pin,        // external reset pin
    input  scanmode,        // Scan test mode select
    output rstn_sync);

   localparam WIDTH         = 1'b1;
   localparam BCM_SYNC_TYPE = 4;//4-stage synchronization with all stages positive-edge capturing

   wire    data_s;
   wire               rstn_clk_sync;


   assign data_s=1'b1;
   
   DWC_ddr_umctl2_bcm21
   
     #(.WIDTH       (WIDTH),
       .F_SYNC_TYPE (BCM_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN))
   U_bcm21
     (.clk_d    (clk),
      .rst_d_n  (rstn),
      .data_s   (data_s),
      .data_d   (rstn_clk_sync)
      );   

   //spyglass disable_block TA_09
   //SMD: Net 'DWC_ddr_umctl2.U_aclk0_rstn_sync.rstn_clk_sync' [in 'DWC_ddr_umctl2_rstn_sync'] is not observable[affected by other input(s)]. Adding a test-point [Obs = y]  will make 2 nets observable
   //SJ: Flip-flops inside the DWC_ddr_umctl2_rstn_sync module are unused when scanmode is enabled. This is expected.
   assign rstn_sync = (scanmode) ? rstn_pin : rstn_clk_sync;   
   //spyglass enable_block TA_09
   
endmodule
