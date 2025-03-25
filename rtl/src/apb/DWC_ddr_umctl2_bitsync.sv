//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_bitsync.sv#2 $
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
`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_bitsync
  #(parameter BCM_SYNC_TYPE = 2,
    parameter BCM_VERIF_EN  = 0)
   (input          clk_d,
    input          rst_d_n,
    input          data_s,
    output         data_d);

   localparam WIDTH=1'b1;


      
         DWC_ddr_umctl2_bcm21
         
           #(.WIDTH       (WIDTH),
             .F_SYNC_TYPE (BCM_SYNC_TYPE),
             .VERIF_EN    (BCM_VERIF_EN))
         U_bcm21
           (.clk_d    (clk_d),
            .rst_d_n  (rst_d_n),
            .data_s   (data_s),
            .data_d   (data_d)
            );
            
   
endmodule
