//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_onetoset.sv#3 $
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
module DWC_ddr_umctl2_onetoset
  #(parameter BCM_F_SYNC_TYPE = 2,
    parameter BCM_R_SYNC_TYPE = 2,
    parameter BCM_VERIF_EN    = 0,
    parameter REG_OUTPUTS     = 1)
   (input           clk_s,
    input           rst_s_n,
    input           event_s,
    output          ack_s,
    input           clk_d, 
    input           rst_d_n,
    output          event_d 
    );

   localparam PULSE_MODE=1;  //toggle transition in produces single clock cycle pulse out
   localparam REG_ACK=1;     //ack_s will be retimed, event is delayed 1 cycle
   localparam ACK_DELAY=0;   //acknowledge from dest to src will be sent before the dest domain hashad time to detect the event,

   wire             busy_s_unused;
   

   DWC_ddr_umctl2_bcm23
    
     #(.REG_EVENT   (REG_OUTPUTS),
       .REG_ACK     (REG_ACK),
       .ACK_DELAY   (ACK_DELAY),
       .F_SYNC_TYPE (BCM_F_SYNC_TYPE),
       .R_SYNC_TYPE (BCM_R_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN), 
       .PULSE_MODE  (PULSE_MODE))
   DW_pulse_sync
     (
      .clk_s        (clk_s), 
      .rst_s_n      (rst_s_n), 
      .event_s      (event_s), 
      .ack_s        (ack_s),
      .busy_s       (busy_s_unused),
      .clk_d        (clk_d), 
      .rst_d_n      (rst_d_n), 
      .event_d      (event_d)
      );

endmodule 
