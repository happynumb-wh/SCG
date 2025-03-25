
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

//
// Filename    : DWC_ddr_umctl2_bcm23.v
// Revision    : $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_bcm23.v#22 $
// Author      : Bruce Dean      June 24, 2004
// Description : DWC_ddr_umctl2_bcm23.v Verilog module for DWC_ddr_umctl2
//
// DesignWare IP ID: 0744583b
//
////////////////////////////////////////////////////////////////////////////////
module DWC_ddr_umctl2_bcm23 (
             clk_s, 
             rst_s_n, 
             event_s, 
             ack_s,
             busy_s,

             clk_d, 
             rst_d_n, 
             event_d
             );

 parameter REG_EVENT    = 1;    // RANGE 0 to 1
 parameter REG_ACK      = 1;    // RANGE 0 to 1
 parameter ACK_DELAY    = 1;    // RANGE 0 to 1
 parameter F_SYNC_TYPE  = 2;    // RANGE 0 to 4
 parameter R_SYNC_TYPE  = 2;    // RANGE 0 to 4
 parameter VERIF_EN     = 1;    // RANGE 0 to 4
 parameter PULSE_MODE   = 0;    // RANGE 0 to 3
 parameter SVA_TYPE     = 0;

 localparam F_SYNC_TYPE_P8 = F_SYNC_TYPE + 8;
 localparam R_SYNC_TYPE_P8 = R_SYNC_TYPE + 8;
 
input  clk_s;                   // clock input for source domain
input  rst_s_n;                 // active low async. reset in clk_s domain
input  event_s;                 // event pulseack input (active high event)
output ack_s;                   // event pulseack output (active high event)
output busy_s;                  // event pulseack output (active high event)

input  clk_d;                   // clock input for destination domain
input  rst_d_n;                 // active low async. reset in clk_d domain
output event_d;                 // event pulseack output (active high event)

wire   tgl_s_event_cc;
wire   tgl_d_event_cc;
reg    tgl_s_event_q;
reg    tgl_s_evnt_nfb_cdc;
wire   tgl_s_ack_x;
reg    event_s_cap;

wire   tgl_s_event_x;
wire   tgl_d_event_d;
wire   tgl_d_event_a;

wire   tgl_s_ack_d;
reg    srcdom_ack;
reg    tgl_s_ack_q;
wire   nxt_busy_state;
reg    busy_state;
wire   tgl_d_event_dx;    // event seen via edge detect (before registered)
reg    tgl_d_event_q;     // registered version of event seen
reg    tgl_d_event_qx;    // xor of dest dom data and registered version

`ifndef SYNTHESIS
`ifndef DWC_DISABLE_CDC_METHOD_REPORTING
  initial begin
    if ((F_SYNC_TYPE > 0)&&(F_SYNC_TYPE < 8))
       $display("Information: *** Instance %m module is using the <Toggle Type Event Sychronizer with busy and acknowledge (3)> Clock Domain Crossing Method ***");
  end

`endif
`endif

  
  always @ (posedge clk_s or negedge rst_s_n) begin : event_lauch_reg_PROC
    if (rst_s_n == 1'b0) begin
      tgl_s_event_q    <= 1'b0;
      tgl_s_evnt_nfb_cdc<= 1'b0;
      busy_state       <= 1'b0;
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
      srcdom_ack       <= 1'b0;
// spyglass enable_block W528
      tgl_s_ack_q      <= 1'b0;
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
      event_s_cap      <= 1'b0;
// spyglass enable_block W528
    end else begin
      tgl_s_event_q    <= tgl_s_event_x;
      tgl_s_evnt_nfb_cdc<= tgl_s_event_x;
      busy_state       <= nxt_busy_state;
      srcdom_ack       <= tgl_s_ack_x;
      tgl_s_ack_q      <= tgl_s_ack_d;
      event_s_cap      <= event_s;
    end 
  end // always : event_lauch_reg_PROC



  assign tgl_s_event_cc = tgl_s_evnt_nfb_cdc;

  DWC_ddr_umctl2_bcm21
   #(1, F_SYNC_TYPE_P8, VERIF_EN, 1) U_DW_SYNC_F(
        .clk_d(clk_d),
        .rst_d_n(rst_d_n),
        .data_s(tgl_s_event_cc),
        .data_d(tgl_d_event_d) );


  assign tgl_d_event_cc = tgl_d_event_a;

  DWC_ddr_umctl2_bcm21
   #(1, R_SYNC_TYPE_P8, VERIF_EN, 1) U_DW_SYNC_R(
        .clk_d(clk_s),
        .rst_d_n(rst_s_n),
        .data_s(tgl_d_event_cc),
        .data_d(tgl_s_ack_d) );

  always @ (posedge clk_d or negedge rst_d_n) begin : second_sync_PROC
    if (rst_d_n == 1'b0) begin
      tgl_d_event_q      <= 1'b0;
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
      tgl_d_event_qx     <= 1'b0;
// spyglass enable_block W528
    end else begin
      tgl_d_event_q      <= tgl_d_event_d;
      tgl_d_event_qx     <= tgl_d_event_dx;
    end
  end // always


generate
    
    if (PULSE_MODE <= 0) begin : GEN_PLSMD0
      assign tgl_s_event_x = tgl_s_event_q   ^ (event_s && (! busy_state));
    end
    
    if (PULSE_MODE == 1) begin : GEN_PLSMD1
      assign tgl_s_event_x = tgl_s_event_q   ^ (! busy_state &(event_s & (! event_s_cap)));
    end
    
    if (PULSE_MODE == 2) begin : GEN_PLSMD2
      assign tgl_s_event_x = tgl_s_event_q  ^ (! busy_state &(event_s_cap & (!event_s)));
    end
    
    if (PULSE_MODE >= 3) begin : GEN_PLSMD3
      assign tgl_s_event_x = tgl_s_event_q ^ (! busy_state & (event_s ^ event_s_cap));
    end

endgenerate
  assign tgl_d_event_dx = tgl_d_event_d ^ tgl_d_event_q;
  //assign tgl_s_event_x  = tgl_s_event_q ^ (event_s & ! busy_s);
  assign tgl_s_ack_x    = tgl_s_ack_d   ^ tgl_s_ack_q;
  assign nxt_busy_state = tgl_s_event_x ^ tgl_s_ack_d;

  generate
    if (REG_EVENT == 0) begin : GEN_RGEVT0
      assign event_d       = tgl_d_event_dx;
    end

    else begin : GEN_RGRVT1
      assign event_d       = tgl_d_event_qx;
    end
  endgenerate

  generate
    if (REG_ACK == 0) begin : GEN_RGACK0
      assign ack_s         = tgl_s_ack_x;
    end

    else begin : GEN_RGACK1
      assign ack_s         = srcdom_ack;
    end
  endgenerate

  generate
    if (ACK_DELAY == 0) begin : GEN_AKDLY0
      assign tgl_d_event_a = tgl_d_event_d;
    end

    else begin : GEN_AKDLY1
      reg tgl_d_event_nfb_cdc;

      always @ (posedge clk_d or negedge rst_d_n) begin : third_sync_PROC
        if (rst_d_n == 1'b0) begin
          tgl_d_event_nfb_cdc <= 1'b0;
        end else begin
          tgl_d_event_nfb_cdc <= tgl_d_event_d;
        end
      end // always

      assign tgl_d_event_a = tgl_d_event_nfb_cdc;
    end
  endgenerate


  assign busy_s = busy_state;

`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS

  DWC_ddr_umctl2_sva03 #(F_SYNC_TYPE&7,  PULSE_MODE) P_PULSEACK_SYNC_HS (.*);

  generate if (SVA_TYPE == 1) begin : GEN_SVATP_EQ_1
    DWC_ddr_umctl2_sva02 #(
      .F_SYNC_TYPE    (F_SYNC_TYPE&7),
      .PULSE_MODE     (PULSE_MODE   )
    ) P_PULSE_SYNC_HS (
        .clk_s        (clk_s        )
      , .rst_s_n      (rst_s_n      )
      , .event_s      (event_s      )
      , .event_d      (event_d      )
    );
  end endgenerate

  generate if ((F_SYNC_TYPE==0) || (R_SYNC_TYPE==0)) begin : GEN_SINGLE_CLOCK_CANDIDATE
    DWC_ddr_umctl2_sva07 #(F_SYNC_TYPE, R_SYNC_TYPE) P_CDC_CLKCOH (.*);
  end endgenerate

`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON

endmodule
