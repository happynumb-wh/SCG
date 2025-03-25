//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_wr_en_sync.sv#2 $
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

// ----------------------------------------------------------------------------
// Write enable generation
// ----------------------------------------------------------------------------

`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_wr_en_sync
  #(parameter BCM_VERIF_EN = 0)
   (input  s_rstn,            // active low input reset pin , async assertion, sync de-assertion
    input  s_clk,             //
    input  d_rstn,
    input  d_clk,
    output wr_en);

   localparam WIDTH           = 1'b1;
   localparam BCM_SYNC_TYPE   = 2;

   wire    data_s;
   wire    s_wr_en; // write enable in the source clock domain


   assign data_s           = 1'b1;
   
   DWC_ddr_umctl2_bcm21
   
     #(.WIDTH       (WIDTH),
       .F_SYNC_TYPE (BCM_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN))
   U_source_wr_en
     (.clk_d    (s_clk),
      .rst_d_n  (s_rstn),
      .data_s   (data_s),
      .data_d   (s_wr_en)
      );

   DWC_ddr_umctl2_bcm21
   
     #(.WIDTH       (WIDTH),
       .F_SYNC_TYPE (BCM_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN))
   U_dest_wr_en
     (.clk_d    (d_clk),
      .rst_d_n  (d_rstn),
      .data_s   (s_wr_en),
      .data_d   (wr_en)
      );   

   
endmodule
