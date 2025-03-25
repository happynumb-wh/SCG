/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys.                                               *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR SDRAM Chip                                                *
 *              Individual SDRAM chip from different vendor and either DDR or *
 *              DDR2                                                          *
 *                                                                            *
 *****************************************************************************/
`ifdef SNPS_VIP
    `include "snps_ddr4_sdram.sv"
`endif
`timescale 1ps/1ps  // Set the timescale for board delays

module ddr_sdram (
                  rst_n,     // SDRAM reset
                  ck,        // SDRAM clock
                  ck_n,      // SDRAM clock #
                  cke,       // SDRAM clock enable
                  odt,       // SDRAM on-die termination
                  cs_n,      // SDRAM chip select
                  act_n,     // SDRAM command input (row address select)
                  parity,    // SDRAM Parity input
                  alert_n,   // SDRAM Parity Error output
                  c,         // SDRAM chip ID
                  ba,        // SDRAM bank address
                  bg,        // SDRAM bank address
                  a,         // SDRAM address
                  dm,        // SDRAM output data mask
                  dqs,       // SDRAM input/output data strobe
                  dqs_n,     // SDRAM input/output data strobe #
                  dq         // SDRAM input/output data
                  
`ifdef LRDIMM_MULTI_RANK 
                  ,
                  mwd_train
`endif                  
                  );

  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  
  parameter pSDRAM_BANK_WIDTH	= `SDRAM_BANK_WIDTH;
  parameter pBANK_WIDTH	= `BANK_WIDTH;     
  parameter pCHIP_NO    = 0;
  parameter pDIMM_NO    = 0;
  parameter pRANK_NO    = 0;
  
  `ifdef VMM_VERIF
    vmm_log log = new("ddr4_sdram", "ddr4_sdram");
  `endif  


  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                          rst_n;   // SDRAM reset
  input                          ck;      // SDRAM clock
  input                          ck_n;    // SDRAM clock #
  input                          cke;     // SDRAM clock enable
  input                          odt;     // SDRAM on-die termination
  input                          cs_n;    // SDRAM chip select
  input                          act_n;   // SDRAM activate
  input                          parity;  // SDRAM parity input
  output                         alert_n; // SDRAM Parity Error output
  input [`DWC_CID_WIDTH-1:0]     c;       // SDRAM chip ID
  input [`DWC_PHY_BA_WIDTH-1:0]  ba;      // SDRAM bank address
  input [`DWC_PHY_BG_WIDTH-1:0]  bg;      // SDRAM bank address
  input [`SDRAM_ADDR_WIDTH-1:0]  a;       // SDRAM address
  inout [`SDRAM_BYTE_WIDTH-1:0]  dm;      // SDRAM output data mask
  inout [`SDRAM_BYTE_WIDTH-1:0]  dqs;     // SDRAM input/output data strobe
  inout [`SDRAM_BYTE_WIDTH-1:0]  dqs_n;   // SDRAM input/output data strobe #
  inout [`SDRAM_DATA_WIDTH-1:0]  dq;      // SDRAM input/output data
`ifdef LRDIMM_MULTI_RANK   
  input                          mwd_train; //indicates if in MWD training
`endif  
  wire 			         ck_i;
  wire                           ck_n_i;
  wire                           cke_i;
  wire                           odt_i;
  wire                           cs_n_i;
  wire [`SDRAM_ADDR_WIDTH-1:0]   a_i;
  wire [`SDRAM_BYTE_WIDTH-1:0]   dm_i;      // SDRAM output data mask
  wire [`SDRAM_BYTE_WIDTH-1:0]   dqs_i;     // SDRAM input/output data strobe
  wire [`SDRAM_BYTE_WIDTH-1:0]   dqs_n_i;   // SDRAM input/output data strobe #
  wire [`SDRAM_DATA_WIDTH-1:0]   dq_i;      // SDRAM input/output data

  // DDR4
  wire                           act_n_i;
  wire                           parity_i;
  wire [`DWC_PHY_BG_WIDTH-1:0]   bg_i;
  wire [`DWC_PHY_BA_WIDTH-1:0]   ba_i;        // SDRAM bank address
  wire [`DWC_CID_WIDTH-1:0]      c_i;         // SDRAM chip ID
  
  wire 			         alert_n_i;
//  assign alert_n = alert_n_i;
  
  // added for compatiblity to ddr4_sdram model
  wire 				 model_enable;

 /* always @(*) begin
    casez (dqs) 
     {`SDRAM_BYTE_WIDTH{1'bx}},
     {`SDRAM_BYTE_WIDTH{1'bx}} : write_en = {`SDRAM_BYTE_WIDTH{1'b0}}; 
     default                   : write_en = {`SDRAM_BYTE_WIDTH{1'b1}};
    endcase
  end
 */ 

`ifdef  DWC_DDRPHY_BOARD_DELAYS    
    // Board Delay Modelling
    ddr_board_delay_model board_delay_model(.ck(ck), .ck_n(ck_n), .cke(cke),
  					  .odt(odt), .cs_n(cs_n), .a(a),
  					  .dm(dm),  
                      .dqs(dqs),
                      .dqs_n(dqs_n), 
  					  .dq(dq), .ras_n(1'b0), .cas_n(1'b0), 
  					  .we_n(1'b0), .act_n(act_n),
  					  .parity(parity), .alert_n (alert_n_i), .cid(c),
                      .bg(bg), .ba(ba), .ck_i(ck_i), .ck_n_i(ck_n_i), 
                      .cke_i(cke_i),.odt_i(odt_i), .cs_n_i(cs_n_i), .a_i(a_i),
  					  .dm_i(dm_i), .dqs_i(dqs_i), .dqs_n_i(dqs_n_i),
  					  .dq_i(dq_i), .ras_n_i(ras_n_i), .cas_n_i(cas_n_i), 
  					  .we_n_i(we_n_i), .act_n_i(act_n_i),
  					  .parity_i(parity_i), .alert_n_i(alert_n), .cid_i(c_i),
                      .bg_i(bg_i), .ba_i(ba_i)
                      `ifdef LRDIMM_MULTI_RANK
                      , .rst_n(rst_n)
                      , .mwd_train(mwd_train)
                      `endif
                      );
    
    // ***TBD: add c (chip ID) this to the board delay
    //assign c_i = c;
`else
  assign ck_i       =   ck;
  assign ck_n_i     =   ck_n;
  assign cke_i      =   cke;
  assign odt_i      =   odt;
  assign cs_n_i     =   cs_n;
  assign a_i        =   a;
  assign dm_i       =   dm;
  assign dqs_i      =   dqs;
  assign dqs_n_i    =   dqs_n;
  assign dq_i       =   dq;
  assign ras_n_i    =   1'b0;
  assign cas_n_i    =   1'b0;
  assign we_n_i     =   1'b0;
  assign act_n_i    =   act_n;
  assign parity_i   =   parity;
  assign alert_n_i  =   alert_n;
  assign c_i        =   c;
  assign bg_i       =   bg;
  assign ba_i       =   ba;
`endif
   
  
  //---------------------------------------------------------------------------
  // ELPIDA SDRAM chip
  //---------------------------------------------------------------------------
`ifdef ELPIDA_DDR

  // ELPIDA DDR4 SDRAM chip
  // ----------------------
  elpida_ddr4_sdram_4g_x16 sdram

    (
     //.reset_n       (reset_n),
     .reset_n       (1'b1),
     .act_n         (act_n_i),
     .ck_c          (ck_n_i),
     .ck_t          (ck_i),
     .cke           (cke_i),
     .odt           (odt_i),
     .cs_n          (cs_n_i),
     .ten           (1'b0),
     .ba            (ba_i[`DWC_PHY_BA_WIDTH-1:0]),
     .bg            (bg_i[`DWC_PHY_BG_WIDTH-1:0]),
     .a             (a_i),
     .parity        (parity_i),
     .alert_n       (alert_n_i),
`ifdef SDRAMx16     
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS
     .dml_n         (dm_i[0]),
     .dmu_n         (dm_i[1]),
     .dqsl_c        (dqs_n_i[0]),
     .dqsl_t        (dqs_i[0]),
     .dqsu_c        (dqs_n_i[1]),
     .dqsu_t        (dqs_i[1]),
    `ifdef DDR4_v0_02   
     .dqu           (dq_i[`SDRAM_DATA_WIDTH-1:`SDRAM_DATA_WIDTH/2]),
     .dql           (dq_i[`SDRAM_DATA_WIDTH/2-1:0]),
    `else
     .dq            (dq_i),
    `endif
  `else     
     .dml_n         (dm[0]),
     .dmu_n         (dm[1]),
     .dqsl_c        (dqs_n[0]),
     .dqsl_t        (dqs[0]),
     .dqsu_c        (dqs_n[1]),
     .dqsu_t        (dqs[1]),
    `ifdef DDR4_v0_02   
     .dqu           (dq[`SDRAM_DATA_WIDTH-1:`SDRAM_DATA_WIDTH/2]),
     .dql           (dq[`SDRAM_DATA_WIDTH/2-1:0]),
    `else
     .dq            (dq),
    `endif
  `endif   
`else      
     .dml_n         (dm[0]),
     .dmu_n         (dm[1]),
     .dqsl_c        (dqs_n[0]),
     .dqsl_t        (dqs[0]),
     .dqsu_c        (dqs_n[1]),
     .dqsu_t        (dqs[1]),
  `ifdef DDR4_v0_02   
     .dqu           (dq[`SDRAM_DATA_WIDTH-1:`SDRAM_DATA_WIDTH/2]),
     .dql           (dq[`SDRAM_DATA_WIDTH/2-1:0]),
  `else
     .dq            (dq),
  `endif
`endif
`else  // Not SDRAMx16 
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS
     .dml_n         (dm_i),
     .dmu_n         (),
     .dqsl_c        (dqs_n_i),
     .dqsl_t        (dqs_i),
     .dqsu_c        (),
     .dqsu_t        (),
    `ifdef DDR4_v0_02   
     .dqu           (),
     .dql           (dq_i[`SDRAM_DATA_WIDTH-1:0]),
    `else
     .dq            (dq_i),
    `endif
  `else     
     .dml_n         (dm),
     .dmu_n         (),
     .dqsl_c        (dqs_n),
     .dqsl_t        (dqs),
     .dqsu_c        (),
     .dqsu_t        (),
    `ifdef DDR4_v0_02   
     .dqu           (),
     .dql           (dq[`SDRAM_DATA_WIDTH-1:0]),
    `else
     .dq            (dq),
    `endif
  `endif   
`else      
     .dml_n         (dm),
     .dmu_n         (),
     .dqsl_c        (dqs_n),
     .dqsl_t        (dqs),
     .dqsu_c        (),
     .dqsu_t        (),
    `ifdef DDR4_v0_02   
     .dqu           (),
     .dql           (dq[`SDRAM_DATA_WIDTH-1:0]),
    `else
     .dq            (dq),
    `endif
  `endif
`endif     
     .zq            ()
//   
//`ifdef  DWC_DDRPHY_BOARD_DELAYS  
//`ifdef BIDIRECTIONAL_SDRAM_DELAYS  
//     .dm_tdqs       (dm_i),
//     .dqs           (dqs_i),
//     .dqs_n         (dqs_n_i),
//     .dq            (dq_i),
//`else     
//     .dm_tdqs       (dm),
//     .dqs           (dqs),
//     .dqs_n         (dqs_n),
//     .dq            (dq),
//`endif    
//`else     
//     .dm_tdqs       (dm),
//     .dqs           (dqs),
//     .dqs_n         (dqs_n),
//     .dq            (dq),
//`endif
//     .tdqs_n        ()
     );
`endif
  
  //---------------------------------------------------------------------------
  // Micron DDR4
  //---------------------------------------------------------------------------
`ifdef MICRON_DDR
  assign sdram.model_enable = model_enable;


  ddr4   
    #(
      `ifdef CSNCIDMUX
        .pC_BITS      (1),
      `else
        .pC_BITS      (`DWC_CID_WIDTH),
      `endif
      .pCHIP_NO     (pCHIP_NO) 
    )
    sdram
    (
     .rst_n         (rst_n),
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .cs_n          (cs_n_i),
     .ras_n         (a_i[16]),
     .cas_n         (a_i[15]),
     .we_n          (a_i[14]),
     .c             (c_i),
     .ba            (ba_i),
     .addr          (a_i[13:0]),
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
    `ifdef DWC_DX_DM_USE
      .dm_tdqs       (dm_i),
    `else
      .dm_tdqs       (1'b1),
    `endif
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i),
  `else     
    `ifdef DWC_DX_DM_USE
      .dm_tdqs       (dm),
    `else
      .dm_tdqs       (1'b1),
    `endif
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
  `endif    
`else     
    `ifdef DWC_DX_DM_USE
      .dm_tdqs       (dm),
    `else
      .dm_tdqs       (1'b1),
    `endif
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
`endif
     .odt           (odt_i),
     .act           (act_n_i),
     .alert_n       (alert_n_i),
     .parity        (parity_i),
     .ten           (1'b0),
     .bg            (bg_i)              
    );    
  
`endif
  

  //---------------------------------------------------------------------------
  // DDR4 SYNOP  VIP SDRAM 
  //---------------------------------------------------------------------------
  
`ifdef SNPS_VIP  //SNPS_VIP
  snps_ddr4_sdram sdram
    (
     .rst_n         (rst_n),
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .otc           (odt_i),
     .cs_n          (cs_n_i),
     .c             (c_i),
     .act_n         (act_n_i),
     .alert_n       (alert_n_i),
     .parity        (parity_i),
     .bg            (bg_i),
     .ba            (ba_i),
     .ad            (a_i),
     .ten           (1'b0),
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm            (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq)
  `else     
     .dm            (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq)
  `endif   
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq)
`endif   
     );
  
// Turning OFF/ON  VIP errors at time=0ns
initial begin
#1
    $display ("Turning OFF/ON VIP errors Time=%0dns ", $time);
    sdram.ddr_env.mem_group.checks.ref_2srm_self_refresh_check.set_is_enabled(0);
    sdram.ddr_env.mem_group.checks.reset_pulse_width_in_pu_init_check.set_is_enabled(0);
    sdram.ddr_env.mem_group.checks.missing_rd_postamble_read_write_check.set_is_enabled(0);

// Intialize the Memserver
    //Initialize the memory with various patterns and display them
    `vmm_note(log, $sformatf("run_phase Initialize the memory with CONSTANT Pattern"));
    sdram.ddr_env.mem_core.initialize (svt_mem_core::INIT_CONST ,'h11, 0 , sdram.ddr_env.max_addr) ;
    `vmm_note(log, $sformatf("ALL MEMSERVERS initialized\n"));

end 

// Turning OFF/ON  VIP errors at an event using misc signals.
always @(ddr4mphy_system.misc_if.training_complete) begin
    sdram.ddr_env.mem_group.checks.missing_rd_postamble_read_write_check.set_is_enabled(0);
end

`endif //SNPS_VIP// 


    
  
     

  task set_dq_drain_err;
    input dram_dq_force;
      if (dram_dq_force == 1) begin
        `ifdef  DWC_DDRPHY_BOARD_DELAYS    
          board_delay_model.training_err = 1;
        `endif
        if($urandom%2)
          force dq = 1;
        else
          force dq = 0;
      end
      else begin
        release dq;
        `ifdef  DWC_DDRPHY_BOARD_DELAYS    
          board_delay_model.training_err = 0;
        `endif
      end
  endtask
  
  task set_reset_checks;
    input reset_check;
    begin
      `ifdef MICRON_DDR
        sdram.golden_model.reset_check = reset_check;
      `endif
    end
  endtask

  task set_ck_checks;
    input ck_check;
    begin
      `ifdef ELPIDA_DDR
        sdram.ck_check = ck_check;
      `endif
    end
  endtask
  
  task set_refresh_check;
    input refresh_check;
    begin
      `ifdef ELPIDA_DDR
        sdram.refresh_check = refresh_check;
      `endif
    end
  endtask

  task set_tpdmax_check;
    input tpdmax_check;
    begin
      `ifdef ELPIDA_DDR
        sdram.tpdmax_check = tpdmax_check;
      `endif
    end
  endtask // set_tpdmax_check
  

endmodule // ddr_sdram

