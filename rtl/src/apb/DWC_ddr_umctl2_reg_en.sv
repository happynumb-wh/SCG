//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/apb/DWC_ddr_umctl2_reg_en.sv#3 $
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


`include "DWC_ddr_umctl2_all_includes.svh"
module DWC_ddr_umctl2_reg_en
   #(
      parameter HIF_ONLY            = 1,
      parameter NPORTS              = 1,
      parameter CP_ASYNC            = 0,
      parameter AP_ASYNC            = 0,
      parameter BCM_F_SYNC_TYPE_C2P = 2,
      parameter BCM_F_SYNC_TYPE_P2C = 2,
      parameter BCM_VERIF_EN        = 1,
      parameter CAM_ADDRW           = 4)
   (
      //clocks and resets
      input                pclk,
      input                presetn,
      input                core_ddrc_core_clk,
      input                core_ddrc_rstn,
//spyglass disable_block W240
//SMD: Input 'aclk[0]'/'aresetn[0]' declared but not read
//SJ: Used in RTL assertions     
      input [NPORTS-1:0]   aclk,
      input [NPORTS-1:0]   aresetn,
//spyglass enable_block W240      
      // software programming enable bit
      input                reg_ddrc_sw_done,
      // static registers unlock (write enable outside reset)
      input                reg_ddrc_sw_static_unlock,
      // lpr_num_entries register
      input [CAM_ADDRW-1:0]reg_ddrc_lpr_num_entries,
      // software programming acknowledge
      output               ddrc_reg_sw_done,
      // lpr_num_entries changed flag
      output               lpr_num_entries_changed,
      // apb regs write enable
      output [NPORTS+2-1:0]apb_static_regs_wr_en,
      output [NPORTS+2-1:0]apb_quasi_dyn_wr_en);


   //---------------------------------------------------------------------------
   // Local Parameters 
   //---------------------------------------------------------------------------

   localparam ANY_ASYNC    = (CP_ASYNC==1) || (HIF_ONLY==0 && AP_ASYNC==1);
   localparam MAX_TIMEOUT  = 10;
   localparam TIMEOUTW     = `UMCTL_LOG2(MAX_TIMEOUT);
   //localparam STATEW       = 2;
   //localparam ACK_1        = 2'b00;
   //localparam WAIT_0       = 2'b01;
   //localparam ACK_0        = 2'b11;
   //localparam WAIT_1       = 2'b10;
   localparam ACK_SD       = 1'b0;
   localparam WAIT_SD      = 1'b1;

   //---------------------------------------------------------------------------
   // Internal Signals
   //---------------------------------------------------------------------------

   genvar n;
   wire [NPORTS-1:0]    sw_done_aclk;
   reg                  sw_done_core;   
   wire                 core_wr_en;
   wire                 pc_wr_en;
   wire [NPORTS-1:0]    aclk_wr_en;
   wire [NPORTS+2-1:0]  wr_en;
   wire [NPORTS-1:0]    aclk_qd_wr_en;
   wire                 core_qd_wr_en;
   wire                 pc_qd_wr_en;
   wire [NPORTS+2-1:0]  qd_wr_en;
   reg [CAM_ADDRW-1:0]  reg_ddrc_lpr_num_entries_past; 

   //---------------------------------------------------------------------------
   // Main Module
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   // Inputs assign
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   // Output assign
   //---------------------------------------------------------------------------

   assign apb_static_regs_wr_en     = wr_en;
   assign apb_quasi_dyn_wr_en       = qd_wr_en;
   assign lpr_num_entries_changed   = |(reg_ddrc_lpr_num_entries_past ^ reg_ddrc_lpr_num_entries);   

   //---------------------------------------------------------------------------
   // Main processes
   //---------------------------------------------------------------------------

   assign wr_en      = {(NPORTS+2){~reg_ddrc_sw_static_unlock}} & {aclk_wr_en,pc_wr_en,core_wr_en}; // static regs write enable
   assign qd_wr_en      = {aclk_qd_wr_en,pc_qd_wr_en,core_qd_wr_en}; // quasi dynamic regs write enable

   assign core_qd_wr_en = core_wr_en & reg_ddrc_sw_done; // quasi dynamic write enable -> enable when reset low or sw_done is low
   assign pc_qd_wr_en   = pc_wr_en & reg_ddrc_sw_done;

   assign pc_wr_en      = |aclk_wr_en | core_wr_en;
   

   generate
   if (ANY_ASYNC==1) begin: ASYNC_en

      reg current_state, next_state;
      reg [TIMEOUTW-1:0] cdc_timeout;
      reg  reg_ddrc_sw_done_r;
      reg  sw_done_out_r;
      wire sw_done_posedge, sw_done_negedge, sw_done_trn;
      wire timeout;
      reg count_down;

      assign sw_done_posedge  = reg_ddrc_sw_done & ~reg_ddrc_sw_done_r;
      assign sw_done_negedge  = ~reg_ddrc_sw_done & reg_ddrc_sw_done_r;

      assign sw_done_trn   = sw_done_posedge | sw_done_negedge;
      assign timeout       = ~|cdc_timeout;

      always @(posedge pclk or negedge presetn) begin
         if (~presetn) begin
            cdc_timeout <= MAX_TIMEOUT;
            reg_ddrc_sw_done_r   <= 1'b1;
         end
         else begin
            reg_ddrc_sw_done_r <= reg_ddrc_sw_done;
            if (sw_done_trn | ~count_down)   cdc_timeout <= MAX_TIMEOUT;
            else if (count_down & ~timeout)  cdc_timeout <= cdc_timeout - 1;
         end
      end

      always @(posedge pclk or negedge presetn) begin: FSM_seq
         if (~presetn) begin
            current_state <= ACK_SD;
         end
         else begin
            current_state <= next_state;
         end
      end

      always_comb begin: FSM_comb
         next_state     = current_state;
         count_down     = 1'b0;
         sw_done_out_r  = reg_ddrc_sw_done;
         case (current_state)
            ACK_SD: begin
                     if (sw_done_trn) begin
                        next_state     = WAIT_SD;
                        sw_done_out_r  = ~reg_ddrc_sw_done;
                     end
                  end
            default: begin
                     count_down = 1'b1;
                     sw_done_out_r  = ~reg_ddrc_sw_done;
                     if (timeout) next_state = ACK_SD;
                  end
         endcase
      end

      assign ddrc_reg_sw_done = sw_done_out_r;

`ifdef SYSTEM_VERILOG_ASSERT
`ifndef SYNTHESIS
// VCS coverage off
         reg [NPORTS-1:0] sw_done_a;
         reg              sw_done_c;

         wire [NPORTS+1-1:0]  sw_done_ac;
         wire                 sw_done_ac_all1, sw_done_ac_all0;

         wire timeout_when_0, timeout_when_1;

         assign sw_done_ac = {sw_done_a,sw_done_c};

         assign sw_done_ac_all1  = &sw_done_ac;
         assign sw_done_ac_all0  = ~|sw_done_ac;

         assign timeout_when_0 = timeout && current_state==WAIT_SD && !reg_ddrc_sw_done && sw_done_ac_all0;
         assign timeout_when_1 = timeout && current_state==WAIT_SD && reg_ddrc_sw_done && sw_done_ac_all1;

         always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin: SW_done_c_assign
            if (~core_ddrc_rstn) begin
               sw_done_c <= 1'b1;
            end
            else begin
               sw_done_c <= reg_ddrc_sw_done;
            end
         end

         if (HIF_ONLY==0) begin: HIF_only_0
            for (n=0; n<NPORTS; n=n+1) begin: ARB_nports_loop
               always @(posedge aclk[n] or negedge aresetn[n]) begin: SW_done_a_assign
                  if (~aresetn[n]) begin
                     sw_done_a[n] <= 1'b1;
                  end
                  else begin
                     sw_done_a[n] <= reg_ddrc_sw_done;
                  end
               end
            end
         end
         else begin: HIF_only_1
            always @(posedge pclk or negedge presetn) begin: SW_done_a_assign
               if (~presetn) begin
                  sw_done_a[0] <= 1'b1;
               end
               else begin
                  sw_done_a[0] <= reg_ddrc_sw_done;
               end
            end
         end
// VCS coverage on
         cp_timeout_when_sw_1 : cover property (@(posedge pclk) disable iff(!presetn) timeout_when_1==1'b1);
         cp_timeout_when_sw_0 : cover property (@(posedge pclk) disable iff(!presetn) timeout_when_0==1'b1);

`endif
`endif

   end
   else begin: ASYNC_nen
      
      wire [NPORTS+1-1:0]  sw_done;

      assign sw_done          = {sw_done_aclk,sw_done_core}; // programming done acknowledge
      assign ddrc_reg_sw_done = &sw_done;
      
   end
   endgenerate

   // core clock write enable generation, generated from ddrc_rstn

   DWC_ddr_umctl2_wr_en_sync
   
   #(.BCM_VERIF_EN (BCM_VERIF_EN))
   U_cclk_wr_en
   (.s_clk     (core_ddrc_core_clk),
    .s_rstn    (core_ddrc_rstn),
    .d_clk     (pclk),
    .d_rstn    (presetn),
    .wr_en     (core_wr_en));

   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read
   //SJ: Used in generate statement
   always @(posedge pclk or negedge presetn) begin
      if (~presetn) sw_done_core  <= 1'b1;
      else sw_done_core  <= reg_ddrc_sw_done;
   end
   //spyglass enable_block W528

//spyglass disable_block W528
//SMD: A signal or variable is set but never read - sw_done_aclk
//SJ: Signal assigned and used in different generate statements
   generate
   if (HIF_ONLY==0) begin: ARB_en
      wire [NPORTS-1:0] aclk_sw_done;
      for (n=0; n<NPORTS; n=n+1) begin: SW_done_assign

         reg sw_done_aclk_r;
         // aclk write enable generation, generated from aresetn

         DWC_ddr_umctl2_wr_en_sync
         
         #(.BCM_VERIF_EN (BCM_VERIF_EN))
         U_aclk_wr_en
         (.s_clk     (aclk[n]),
          .s_rstn    (aresetn[n]),
          .d_clk     (pclk),
          .d_rstn    (presetn),
          .wr_en     (aclk_wr_en[n]));

         always @(posedge pclk or negedge presetn) begin
            if (~presetn) sw_done_aclk_r  <= 1'b1;
            else sw_done_aclk_r  <= reg_ddrc_sw_done;
         end

         assign sw_done_aclk[n]  = sw_done_aclk_r;
         assign aclk_qd_wr_en[n] = aclk_wr_en[n] & reg_ddrc_sw_done; // quasi dynamic write enable -> enable when reset low or sw_done is low

`ifdef SYSTEM_VERILOG_ASSERT
`ifndef SYNTHESIS



`endif
`endif

      end

   end
   else begin: ARB_nen

      for (n=0; n<NPORTS; n=n+1) begin:NPORTS_pad
         // no arbiter, assign to default
         assign sw_done_aclk[n]  = 1'b1; // assign to 1 to have sw_done high when sw_done_core is high
         assign aclk_wr_en[n]    = 1'b0;
         assign aclk_qd_wr_en[n] = 1'b0;
      end

   end
   endgenerate
//spyglass enable_block W528

   // lpr_num_entries logic

   always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) reg_ddrc_lpr_num_entries_past <= {CAM_ADDRW{1'b0}};
      else                 reg_ddrc_lpr_num_entries_past <= reg_ddrc_lpr_num_entries;
   end



endmodule // DWC_ddr_umctl2_reg_en
