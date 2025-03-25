//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_datasync.sv#2 $
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
module DWC_ddr_umctl2_datasync
  #(parameter DW              = 8,
    parameter BCM_F_SYNC_TYPE = 2,
    parameter BCM_VERIF_EN    = 0,
    parameter REG_OUTPUTS     = 0,
    parameter DETECT_CHANGE   = 1)
   (input                s_clk,
    input                s_rst_n,
//spyglass disable_block W240
//SMD: Input 's_send' declared but not read
//SJ: Used in generate statement only in certain conditions
    input                s_send, // only when DETECT_CHANGE==0
//spyglass enable_block W240
    input  [DW-1:0]      s_data,
    //
    input                d_clk,
    input                d_rst_n,                                 
    output [DW-1:0]      d_data,
    output               s_ack
);

   localparam PEND_MODE = (DETECT_CHANGE==1) ? 1 : 0; 


   wire                  send_s;
   wire [DW-1:0]         data_s;
   wire                  s_tx_ack;
   wire                  d_tx_req_unused;
   wire [DW-1:0]         i_d_data;
   reg [DW-1:0]          i_d_data_r;
   wire                  empty_s_unused;
   wire                  full_s_unused;

   generate
      if(DETECT_CHANGE) begin: DetectChange
         reg [DW-1:0]          s_data_r;
         wire                  s_data_change;
         reg                   s_data_change_r;
         wire                  s_data_change_stagger;
         reg                   s_data_change_stagger_r;
         wire                  s_data_change_fed;

         //-----------------------------------------------------------------------------
         // Data change detection
         //-----------------------------------------------------------------------------
         
         // register data
         always @(posedge s_clk or negedge s_rst_n) begin : s_data_r_PROC
            if (!s_rst_n) begin
               s_data_r <= {DW{1'b0}};
            end else begin
               s_data_r <= s_data;
            end
         end
         
         // Compare data to previous cycle's data and generate a pulse if different
         // pulse generated on s_data_change_stagger
         // Ensure pulse like behavior even if s_data is continoulsyl changing

         assign s_data_change = (s_data != s_data_r) ? 1'b1 : 1'b0;

         // register data_change reelated signals
         always @(posedge s_clk or negedge s_rst_n) begin : s_data_change_r_PROC
            if (!s_rst_n) begin
               s_data_change_r         <= 1'b0;
               s_data_change_stagger_r <= 1'b0;
            end else begin
               s_data_change_r         <= s_data_change;
               s_data_change_stagger_r <= s_data_change_stagger;
            end
         end

         assign s_data_change_fed = ~s_data_change & s_data_change_r;
         
         assign s_data_change_stagger = (s_data_change & ~s_data_change_stagger_r) | (s_data_change_fed & ~s_data_change_stagger_r);


         // send data via bcm25
         assign data_s = s_data;
         assign send_s = s_data_change_stagger;

      end else begin: ExternalSend
         assign data_s = s_data;
         assign send_s = s_send;
      end
   endgenerate

   assign s_ack = s_tx_ack;
   
//-----------------------------------------------------------------------------
// Clock cross via a BCM with request and acknowledge
// BCM25 is same as DW_data_async
// It clock crosses a single data word via a request and passes back an
// acknowledge
// The request and acknowledge are used by the stata machine to ensure
// only 1 stable data beat is trnasfered at a time
//-----------------------------------------------------------------------------
DWC_ddr_umctl2_bcm25
 #(
  .WIDTH       (DW), // fifo data width
  .PEND_MODE   (PEND_MODE), // depends on whether DETECT_CHANGE is used or not
  .ACK_DELAY   (1), 
  .F_SYNC_TYPE (BCM_F_SYNC_TYPE),
  .R_SYNC_TYPE (BCM_F_SYNC_TYPE), // use f_sync_type on r_sync_type too
  .VERIF_EN    (BCM_VERIF_EN),
  .SEND_MODE   (0) // clock cross on a pulse request
) U_async_dp_data (
  .clk_s        (s_clk),
  .rst_s_n      (s_rst_n),
  .send_s       (send_s), 
  .data_s       (data_s),
  .empty_s      (empty_s_unused),
  .full_s       (full_s_unused),
  .done_s       (s_tx_ack),
  .clk_d        (d_clk),
  .rst_d_n      (d_rst_n),
  .data_avail_d (d_tx_req_unused),
  .data_d       (i_d_data)
);

//-----------------------------------------------------------------------------
// Data outputted
//-----------------------------------------------------------------------------
// register data
always @(posedge d_clk or negedge d_rst_n) begin : i_d_data_r_PROC
  if (!d_rst_n) begin
    i_d_data_r <= {DW{1'b0}};
  end else begin
    i_d_data_r <= i_d_data;
  end
end

// Drive output
assign d_data = (REG_OUTPUTS) ? i_d_data_r : i_d_data;
//
//
endmodule





