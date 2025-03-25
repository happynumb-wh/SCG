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

module ddr_sdram (
                  rst_n,     // SDRAM reset
                  ck,        // SDRAM clock
                  ck_n,      // SDRAM clock #
                  cke,       // SDRAM clock enable
                  odt,       // SDRAM on-die termination
                  cs_n,      // SDRAM chip select
                  ras_n,     // SDRAM command input (row address select)
                  cas_n,     // SDRAM command input (column address select)
                  we_n,      // SDRAM command input (write enable)
`ifdef DWC_DDRPHY_GEN3
                  act_n,     // SDRAM command input (row address select)
                  par_in,
`endif
                  ba,        // SDRAM bank address
                  a,         // SDRAM address
                  dm,        // SDRAM output data mask
                  dqs,       // SDRAM input/output data strobe
                  dqs_n,     // SDRAM input/output data strobe #
                  dq         // SDRAM input/output data
                  );

  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  // board delay type
  parameter CMD_DELAY   = 3'd0,    // command path board dealy 
            WRITE_DELAY = 3'd1,    // write data path board delay
            READ_DELAY  = 3'd2,    // read data path board delay
            CK_DELAY    = 3'd3,    // CK/CK# extra delay (on top of write delay)
            QS_DELAY    = 3'd4,    // DQS/DQS# extra delay (on top of read delay)
            DQS_DELAY   = 3'd5,    // DQS extra delay (on top of DQS/DQS# delay)
            DQSb_DELAY  = 3'd6,  // DQS# extra delay (on top of DQS/DQS# delay)
            FLYBY_DELAY = 3'd7;  // command fly-by delay

  // DQS pin type
  parameter DQS_STROBE  = 1'b0,    // DQS pin
            DQSb_STROBE = 1'b1;    // DQS# pin


  parameter pSDRAM_BANK_WIDTH	= `SDRAM_BANK_WIDTH;
  parameter pBANK_WIDTH	= `BANK_WIDTH;    
  parameter pCHIP_NO    = 0;


  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input     rst_n;   // SDRAM reset
  input     ck;      // SDRAM clock
  input     ck_n;    // SDRAM clock #
  input     cke;     // SDRAM clock enable
  input     odt;     // SDRAM on-die termination
  input     cs_n;    // SDRAM chip select
  input     ras_n;   // SDRAM row address select
  input     cas_n;   // SDRAM column address select
  input     we_n;    // SDRAM write enable
`ifdef DWC_DDRPHY_GEN3
  input     act_n;   // SDRAM activate
  input     par_in;
`endif
  input [`SDRAM_BANK_WIDTH-1:0] ba;      // SDRAM bank address
  input [`SDRAM_ADDR_WIDTH-1:0] a;       // SDRAM address
`ifdef DDR4
  inout [`SDRAM_BYTE_WIDTH-1:0] dm;      // SDRAM output data mask
`else
  input [`SDRAM_BYTE_WIDTH-1:0] dm;      // SDRAM output data mask
`endif
  inout [`SDRAM_BYTE_WIDTH-1:0] dqs;     // SDRAM input/output data strobe
  inout [`SDRAM_BYTE_WIDTH-1:0] dqs_n;   // SDRAM input/output data strobe #
  inout [`SDRAM_DATA_WIDTH-1:0] dq;      // SDRAM input/output data

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                           ck_i;
  reg                           ck_n_i;
  reg                           cke_i;
  reg                           odt_i;
  reg                           cs_n_i;
  reg                           ras_n_i;
  reg                           cas_n_i;
  reg                           we_n_i;
`ifdef DWC_DDRPHY_GEN3
  reg                           act_n_i;
`endif
  reg [`SDRAM_BANK_WIDTH-1:0]   ba_i;
  reg [`SDRAM_ADDR_WIDTH-1:0]   a_i;

  // board delays                                                            
  //real                          cmd_dly;    // command board delay
  //real                          wr_dly;     // write data board delay
  //real                          rd_dly;     // read data board delay
  //real                          ck_dly;     // extra write delay on CK/CK#
  //real                          qs_dly;     // extra read delay on strobes
  //real                          dqs_dly;    // extra read delay on DQS strobe
  //real                          dqs_n_dly;  // extra read delay on DQS# strobe
  real                          fly_by_dly; // fly-by delay

  integer                       TRFC_MAX;   // default TRFC_MAX of the SDRAM
  
  integer      addr_sdram_dly  [`SDRAM_ADDR_WIDTH-1:0];
  integer      ck_sdram_dly    ;
  integer      cmd_sdram_dly   [`SDRAM_BANK_WIDTH+6-1:0];
  
  integer      dq_do_sdram_dly  [`SDRAM_DATA_WIDTH-1:0];
  integer      dq_di_sdram_dly  [`SDRAM_DATA_WIDTH-1:0];
  integer      dm_di_sdram_dly  [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_do_sdram_dly [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqs_di_sdram_dly [`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_do_sdram_dly[`SDRAM_BYTE_WIDTH-1:0];
  integer      dqsn_di_sdram_dly[`SDRAM_BYTE_WIDTH-1:0];
  
  integer     bit_idx  ;
  
genvar dx_bit, ac_bit, byte_bit;
  
`ifdef DWC_DDRPHY_BOARD_DELAYS
`ifdef BIDIRECTIONAL_SDRAM_DELAYS
    
  
  wire [`SDRAM_BYTE_WIDTH-1:0] dm_i;      // SDRAM output data mask
  wire [`SDRAM_BYTE_WIDTH-1:0] dqs_i;     // SDRAM input/output data strobe
  wire [`SDRAM_BYTE_WIDTH-1:0] dqs_n_i;   // SDRAM input/output data strobe #
  wire [`SDRAM_DATA_WIDTH-1:0] dq_i;      // SDRAM input/output data
  
  wire [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_i1 ;
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_wr_i1 ;  
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_i1 ;
  wire [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_i1 ;
  wire [`SDRAM_DATA_WIDTH-1:0]  dq_rd_i1 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dm_wr_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_wr_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_wr_i2 ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_wr_i2 ;  
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_rd_i2 ;
  reg [`SDRAM_BYTE_WIDTH-1:0]  dqs_n_rd_i2 ;
  reg [`SDRAM_DATA_WIDTH-1:0]  dq_rd_i2 ;
  
  //Write path : from dq to dq*_i
  rnmos DM_WR1_TRAN[`SDRAM_BYTE_WIDTH-1:0]   (dm_wr_i1, dm, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQ_WR1_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_wr_i1, dq, {`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQS_WR1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_wr_i1, dqs, {`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_WR1_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_i1, dqs_n, {`SDRAM_BYTE_WIDTH{1'b1}});
  buf (weak0,weak1) DM_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_wr_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQ_DUMMY_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_wr_i1,{`SDRAM_DATA_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQS_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_wr_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQSN_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_wr_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  //need transport delays to be able to go above 1 bit period
generate
for(dx_bit=0;dx_bit<`SDRAM_DATA_WIDTH;dx_bit=dx_bit+1) begin :  u_wrdq_delays  
  always@(dq_wr_i1[dx_bit])    dq_wr_i2[dx_bit]    <= #(dq_di_sdram_dly[dx_bit])  dq_wr_i1[dx_bit] ;
end
for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin :  u_wrdqsdm_delays  
  always@(dm_wr_i1[byte_bit])    dm_wr_i2[byte_bit]    <= #(dm_di_sdram_dly[byte_bit])  dm_wr_i1[byte_bit] ;
  always@(dqs_wr_i1[byte_bit])   dqs_wr_i2[byte_bit]   <= #(dqs_di_sdram_dly[byte_bit])  dqs_wr_i1[byte_bit] ;
  always@(dqs_n_wr_i1[byte_bit]) dqs_n_wr_i2[byte_bit] <= #(dqsn_di_sdram_dly[byte_bit])  dqs_n_wr_i1[byte_bit] ;
end
endgenerate  
    
  bufif1 (pull0,pull1) DM_WR1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dm_i,dm_wr_i2,dm_wr_i2 !== {`SDRAM_BYTE_WIDTH{1'bx}}) ;
  bufif1 (pull0,pull1) DQ_WR1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_i,dq_wr_i2,dq_wr_i2 !== {`SDRAM_DATA_WIDTH{1'bx}}) ;
  bufif1 (pull0,pull1) DQS_WR1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_i,dqs_wr_i2,dqs_wr_i2 !== {`SDRAM_BYTE_WIDTH{1'bx}}) ;
  bufif1 (pull0,pull1) DQSN_WR1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_i,dqs_n_wr_i2,dqs_n_wr_i2 !== {`SDRAM_BYTE_WIDTH{1'bx}}) ;
  
  //Read path : from dq*_i to dq*
  rnmos DQ_RD1_TRAN[`SDRAM_DATA_WIDTH-1:0]   (dq_rd_i1, dq_i,{`SDRAM_DATA_WIDTH{1'b1}});
  rnmos DQS_RD1_TRAN[`SDRAM_BYTE_WIDTH-1:0]  (dqs_rd_i1, dqs_i,{`SDRAM_BYTE_WIDTH{1'b1}});
  rnmos DQSN_RD1_TRAN[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_i1, dqs_n_i,{`SDRAM_BYTE_WIDTH{1'b1}});
  buf (weak0,weak1) DQ_RDUMMY_BUF[`SDRAM_DATA_WIDTH-1:0] (dq_rd_i1,{`SDRAM_DATA_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQS_RDUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_rd_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  buf (weak0,weak1) DQSN_RDUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_rd_i1,{`SDRAM_BYTE_WIDTH{1'bx}}) ;
  //need transport delays to be able to go above 1 bit period
generate
for(dx_bit=0;dx_bit<`SDRAM_DATA_WIDTH;dx_bit=dx_bit+1) begin :  u_rddq_delays  
  always@(dq_rd_i1[dx_bit])    dq_rd_i2[dx_bit]    <= #(dq_do_sdram_dly[dx_bit])  dq_rd_i1[dx_bit] ;
end
for(byte_bit=0;byte_bit<`SDRAM_BYTE_WIDTH;byte_bit=byte_bit+1) begin :  u_rddqs_delays  
  always@(dqs_rd_i1[byte_bit])   dqs_rd_i2[byte_bit]   <= #(dqs_do_sdram_dly[byte_bit])  dqs_rd_i1[byte_bit] ;
  always@(dqs_n_rd_i1[byte_bit]) dqs_n_rd_i2[byte_bit] <= #(dqsn_do_sdram_dly[byte_bit])  dqs_n_rd_i1[byte_bit] ;
end
endgenerate 
  
  bufif1 (pull0,pull1) DQ_RD1_BUF[`SDRAM_DATA_WIDTH-1:0] (dq,dq_rd_i2,dq_rd_i2 !== {`SDRAM_DATA_WIDTH{1'bx}}) ;
  bufif1 (pull0,pull1) DQS_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs,dqs_rd_i2,dqs_rd_i2 !== {`SDRAM_BYTE_WIDTH{1'bx}}) ;
  bufif1 (pull0,pull1) DQSN_RD1_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n,dqs_n_rd_i2,dqs_n_rd_i2 !== {`SDRAM_BYTE_WIDTH{1'bx}}) ;
  
  //recreate the pulldown on DQS/DQS_N as connected to the SDRAM
  buf (weak0,weak1) DQSI_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_i,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  buf (weak0,weak1) DQSNI_DUMMY_BUF[`SDRAM_BYTE_WIDTH-1:0] (dqs_n_i,{`SDRAM_BYTE_WIDTH{1'b0}}) ;
  
  
  reg dqs_bus_conflict ;
  reg dqsn_bus_conflict ;
  reg dq_bus_conflict ;
  
  
  integer bc_loop_var ;
  
  initial begin
    dqs_bus_conflict = 1'b0 ;
    dqsn_bus_conflict = 1'b0 ;
    dq_bus_conflict = 1'b0 ;
  end
  
  always@(dqs_rd_i1 or dqs_wr_i1) begin
    dqs_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dqs_rd_i1[bc_loop_var]!==1'bx) && (dqs_wr_i1[bc_loop_var]!==1'bx) ) dqs_bus_conflict = 1'b1 ;
    if (dqs_bus_conflict == 1'b1)  $display("[ERROR]: Unexpected bus conflict on DQS signal at %0t",$time);
    end
  always@(dqs_n_rd_i1 or dqs_n_wr_i1) begin
    dqsn_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_BYTE_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dqs_n_rd_i1[bc_loop_var]!==1'bx) && (dqs_n_wr_i1[bc_loop_var]!==1'bx) ) dqsn_bus_conflict = 1'b1 ;
    if (dqsn_bus_conflict == 1'b1)  $display("[ERROR]: Unexpected bus conflict on DQS_N signal at %0t",$time);
    end
  always@(dq_rd_i1 or dq_wr_i1) begin
    dq_bus_conflict = 1'b0 ;
    for (bc_loop_var=0;bc_loop_var<`SDRAM_DATA_WIDTH;bc_loop_var=bc_loop_var + 1) 
      if ( (dq_rd_i1[bc_loop_var]!==1'bx) && (dq_wr_i1[bc_loop_var]!==1'bx) ) dq_bus_conflict = 1'b1 ;
    if (dq_bus_conflict == 1'b1)  $display("[ERROR]: Unexpected bus conflict on DQ signal at %0t",$time);
    end  
`endif
`endif

initial begin

  for (bit_idx=0;bit_idx<`SDRAM_ADDR_WIDTH;bit_idx=bit_idx+1)
      addr_sdram_dly  [bit_idx] = 0;
      
  //ck_sdram_dly    = 0;
  for (bit_idx=0;bit_idx<`SDRAM_BANK_WIDTH+6;bit_idx=bit_idx+1)
      cmd_sdram_dly   [bit_idx] = 0;
  
  for (bit_idx=0;bit_idx<`SDRAM_DATA_WIDTH;bit_idx=bit_idx+1) begin 
      dq_do_sdram_dly  [bit_idx] = 0;
      dq_di_sdram_dly  [bit_idx] = 0;
  end
  
  for (bit_idx=0;bit_idx<`SDRAM_BYTE_WIDTH;bit_idx=bit_idx+1) 
      dm_di_sdram_dly  [bit_idx] = 0;

  for (bit_idx=0;bit_idx<`SDRAM_BYTE_WIDTH;bit_idx=bit_idx+1) begin 
      dqs_do_sdram_dly  [bit_idx] = 0;
      dqs_di_sdram_dly  [bit_idx] = 0;
      dqsn_do_sdram_dly  [bit_idx] = 0;
      dqsn_di_sdram_dly  [bit_idx] = 0;
  end    
end  


  //---------------------------------------------------------------------------
  // ELPIDA SDRAM chip
  //---------------------------------------------------------------------------
`ifdef ELPIDA_DDR
  `ifdef DDR4

  // ELPIDA DDR4 SDRAM chip
  // ----------------------
  elpida_ddr4_sdram_4g_x16 sdram

    (
     //.reset_n       (rst_n),
     .reset_n       (1'b1),
     .act_n         (act_n_i),
     .ck_c          (ck_n_i),
     .ck_t          (ck_i),
     .cke           (cke_i),
     .odt           (odt_i),
     .cs_n          (cs_n_i),
     .ten           (1'b0),
     .ba            (ba_i[`SDRAM_BANK_WIDTH - 2:0]),
     .bg            (ba_i[`SDRAM_BANK_WIDTH - 1]),
     .a             (a_i[16:0]),
     .parity        (par_in),
     .alert_n       (),
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
`ifdef BIDIRECTIONAL_SDRAM_DELAYS
`ifdef SDRAMx16
     .dml_n         (dm_i[0]),
     .dmu_n         (dm_i[1]),
     .dqsl_c        (dqs_n_i[0]),
     .dqsl_t        (dqs_i[0]),
     .dqsu_c        (dqs_n_i[1]),
     .dqsu_t        (dqs_i[1]),
`else
     .dml_n         (dm_i),
     .dmu_n         (),
     .dqsl_c        (dqs_n_i),
     .dqsl_t        (dqs_i),
     .dqsu_c        (),
     .dqsu_t        (),
`endif     
     .dq            (dq_i),
     .zq            () 
`else
`ifdef SDRAMx16
     .dml_n         (dm[0]),
     .dmu_n         (dm[1]),
     .dqsl_c        (dqs_n[0]),
     .dqsl_t        (dqs[0]),
     .dqsu_c        (dqs_n[1]),
     .dqsu_t        (dqs[1]),
`else
     .dml_n         (dm),
     .dmu_n         (),
     .dqsl_c        (dqs_n),
     .dqsl_t        (dqs),
     .dqsu_c        (),
     .dqsu_t        (),
`endif     
     .dq            (dq),
     .zq            ()  
`endif      
`else      
`ifdef SDRAMx16     
     .dml_n         (dm[0]),
     .dmu_n         (dm[1]),
     .dqsl_c        (dqs_n[0]),
     .dqsl_t        (dqs[0]),
     .dqsu_c        (dqs_n[1]),
     .dqsu_t        (dqs[1]),
`else
     .dml_n         (dm),
     .dmu_n         (),
     .dqsl_c        (dqs_n),
     .dqsl_t        (dqs),
     .dqsu_c        (),
     .dqsu_t        (),
`endif     
     .dq            (dq),
     .zq            ()
`endif      
     );
`endif //  `ifdef DDR4
`endif
  
  //---------------------------------------------------------------------------
  // Micron DDR2/DDR3/LPDDR2 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2, DDR3 or LPDDR2 SDRAM chip from Micron
`ifdef MICRON_DDR
  `ifdef DDR2
  // Micron DDR2 SDRAM chip
  // ----------------------
  ddr2 sdram
    (
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .odt           (odt_i),
     .cs_n          (cs_n_i),
     .ras_n         (ras_n_i),
     .cas_n         (cas_n_i),
     .we_n          (we_n_i),
     .ba            (ba_i),
     .addr          (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
`ifdef BIDIRECTIONAL_SDRAM_DELAYS
     .dm_rdqs       (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i)
`else     
     .dm_rdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq)
`endif   
`else     
     .dm_rdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq) 
`endif
     );
  `endif
  
  `ifdef DDR3
  // Micron DDR3 SDRAM chip
  // ----------------------
  ddr3 sdram

    (
     .rst_n         (rst_n),
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .odt           (odt_i),
     .cs_n          (cs_n_i),
     .ras_n         (ras_n_i),
     .cas_n         (cas_n_i),
     .we_n          (we_n_i),
     .ba            (ba_i),
    `ifdef SDRAM_ADDR_LT_14
     .addr          ({{(14-`SDRAM_ADDR_WIDTH){1'b0}}, a_i}),
     `else
     .addr          (a_i),
     `endif
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
`ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm_tdqs       (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i),
`else     
     .dm_tdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
`endif    
`else     
     .dm_tdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
`endif
     .tdqs_n        ()
     );
  `endif

  `ifdef DDR4
  // Micron DDR4 SDRAM chip
  // ----------------------
  ddr4  sdram
    (
     .rst_n         (rst_n),
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .cs_n          (cs_n_i),
     //.ras_n         (ras_n_i),
     //.cas_n         (cas_n_i),
     //.we_n          (we_n_i),
     .ras_n         (a_i[16]),
     .cas_n         (a_i[15]),
     .we_n          (a_i[14]),
     .ba            (ba_i[1:0]),
     .addr          ({4'b0000,a_i[13:0]}),
//     .addr          (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
`ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm_tdqs       (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i),
`else     
     .dm_tdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
`endif    
`else     
     .dm_tdqs       (dm),
     .dqs           (dqs),
     .dqs_n         (dqs_n),
     .dq            (dq),
`endif
     .odt           (odt_i),
     // new for ddr4
     .act           (act_n_i),
     .alert_n       (),
     .parity        (par_in),
     .ten           (1'b0),
     .bg            (ba_i[3:2])              
    );    
  
  `endif
  
  `ifdef LPDDR2
  // Micron LPDDR2 SDRAM chip
  // ------------------------
  mobile_ddr2 sdram
    (
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .cs_n          (cs_n_i),
     .ca            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
`ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i)
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
  `endif

  // DRAM parameters
  // ---------------
  // override SDRAM parameters for the selected chip
  // NOTE: *** TBD the current Micro model has addr[13] always there even if
  //       fewer address bits are

`ifndef DDR4  
  // DDR2/DDR3/
  defparam                      sdram.DQS_BITS  = `SDRAM_DS_WIDTH;
  defparam                      sdram.DM_BITS   = `SDRAM_DM_WIDTH;
  defparam                      sdram.DQ_BITS   = `SDRAM_DATA_WIDTH;

  `ifdef LPDDR2
  // TODO - Not sure how changing this here may affect the rest of the environment.  For now
  //        since 13 bits is working and the LPDDR2 model only looks at the both 10, leaving as 
  //        SDRAM_ROW_WIDTH.
  // For LPDDR2, CA bus at the DRAM is 10 bits wide
  // defparam                      sdram.CA_BITS   = 10;
  defparam                      sdram.CA_BITS   = `SDRAM_ADDR_WIDTH;
  defparam                      sdram.ROW_BITS  = `SDRAM_ROW_WIDTH;
  defparam                      sdram.SX        = `LPDDR2_SX;
  `else
    `ifdef SDRAM_ADDR_LT_14     
  defparam                      sdram.ADDR_BITS = 14;
  defparam                      sdram.ROW_BITS  = 14;
    `else                       
  defparam                      sdram.ADDR_BITS = `SDRAM_ADDR_WIDTH;
  defparam                      sdram.ROW_BITS  = `SDRAM_ROW_WIDTH;
    `endif
  `endif
  defparam                      sdram.COL_BITS  = `SDRAM_COL_WIDTH;

  defparam                      sdram.BA_BITS   = `SDRAM_BANK_WIDTH;
  defparam                      sdram.MEM_BITS  = `SDRAM_MEM_BITS;

  // debug messages
  // --------------
  // disables the debug messages that are output from the vendor memory model 
  // (these messages are on by default)
  `ifdef MEMORY_DEBUG
  `else
    `ifdef LPDDR2
  initial #0.001                sdram.mcd_info = 0;
    `else
  defparam                      sdram.DEBUG = 0;
    `endif
  `endif
`else // !`ifndef DDR4
  defparam                      sdram.BA_BITS    = 2;
  defparam                      sdram.DM_BITS    = 2;
  defparam                      sdram.ADDR_BITS  = 18;
  defparam                      sdram.DQ_BITS    = 16;
  defparam                      sdram.DQS_BITS   = 2;
  defparam                      sdram.BG_BITS    = 2;
  defparam                      sdram.pCHIP_NO   = pCHIP_NO;
`endif
  
  // SDRAM array initialization
  // --------------------------
  // direct initialization of memory array with a background pattern; this is
  // especially used for testcases that do random reads and avoid returning
  // undefined data (and warnings) if access is to uninitialized locations
`ifndef DDR4
  always @(posedge `SYS.init_sdram_array)
    begin: array_init
      integer i;
      integer mem_depth;
      reg [3:0] nibble;      

      if (`SYS.init_sdram_array === 1'b1)
        begin
          mem_depth = (1 << `SDRAM_MEM_BITS);
          nibble    = `SYS.sdram_init_nibble;
          
          for (i=0; i<mem_depth; i=i+1)
            begin
              sdram.memory[i]    = {(8*`SDRAM_DATA_WIDTH/4){nibble}};
            end
        end
    end
`endif
`endif // ifdef MICRON_DDR

`ifdef ELPIDA_DDR
 `ifdef LPDDR3
elpida_lpddr3_32 sdram
    (
     .ck            (ck_i),
     .ck_n          (ck_n_i),
     .cke           (cke_i),
     .cs_n          (cs_n_i),
     .odt           (odt_i),
     .ca            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS  
`ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqs_n         (dqs_n_i),
     .dq            (dq_i)
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

//DDRG2MPHY: Boot Error. Valid only when the PHY is run at tCK of 10-55 MHz.
//Overriding the memory parameter since we are not running at this frequency

defparam sdram.tISCKEbmin = 0;
defparam sdram.tIHCKEbmin = 0;
defparam sdram.tISbmin    = 0; 
defparam sdram.tIHbmin    = 0; 


 `endif 


 `endif //ifdef ELPIDA_DDR
 
  //---------------------------------------------------------------------------
  // Samsung DDR/DDR2 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2 or DDR3 SDRAM chip from Samsung
`ifdef SAMSUNG_DDR
  `ifdef DDR2
  // Samsung DDR2 SDRAM chip
  // -----------------------
  DDRII sdram
    (
     .clk           (ck_i),
     .clkb          (ck_n_i),
     .cke           (cke_i),
     .otc           (odt_i),
     .csb           (cs_n_i),
     .rasb          (ras_n_i),
     .casb          (cas_n_i),
     .web           (we_n_i),
     .ba            (ba_i),
     .ad            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS   
`ifdef BIDIRECTIONAL_SDRAM_DELAYS   
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqsb          (dqs_n_i),
     .dqi           (dq_i),
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq),
`endif    
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq),
`endif
     .rdsb          ()
     );
  `endif

  `ifdef DDR3
  // Samsung DDR3 SDRAM chip
  // -----------------------
  DDRIII sdram
    (
     .rstb          (rst_n),
     .clk           (ck_i),
     .clkb          (ck_n_i),
     .cke           (cke_i),
     .otc           (odt_i),
     .csb           (cs_n_i),
     .rasb          (ras_n_i),
     .casb          (cas_n_i),
     .web           (we_n_i),
     .ba            (ba_i),
     .ad            (a_i),
`ifdef  DWC_DDRPHY_BOARD_DELAYS    
`ifdef BIDIRECTIONAL_SDRAM_DELAYS  
     .dm            (dm_i),
     .dqs           (dqs_i),
     .dqsb          (dqs_n_i),
     .dqi           (dq_i)
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq)
`endif   
`else     
     .dm            (dm),
     .dqs           (dqs),
     .dqsb          (dqs_n),
     .dqi           (dq)
`endif
     );
  `endif
`endif // ifdef SAMSUNG_DDR

  
  //---------------------------------------------------------------------------
  // Qimonda DDR2/DDR3 SRAM Chip
  //---------------------------------------------------------------------------
  // a single DDR2 or DDR3 SDRAM chip from Qimonda
`ifdef QIMONDA_DDR
  `ifdef DDR2
  // Qimonda DDR2 SDRAM chip
  // -----------------------
  // TBD: not currently used
  `endif
  
  `ifdef DDR3
  // Qimonda DDR3 SDRAM chip
  // -----------------------
    `ifdef SDRAMx4
  IDSH5102A1F1C #(`QSPEED_BIN) sdram
    `else `ifdef SDRAMx8
    IDSH5103A1F1C #(`QSPEED_BIN) sdram  
      `else
      IDSH5104A1F1C #(`QSPEED_BIN) sdram
      `endif `endif
        (
         .bRESET        (rst_n),
         .CK            (ck_i),
         .bCK           (ck_n_i),
         .CKE           (cke_i),
         .ODT           (odt_i),
         .bCS           (cs_n_i),
         .bRAS          (ras_n_i),
         .bCAS          (cas_n_i),
         .bWE           (we_n_i),
         .BA            (ba_i),
         .Addr          (a_i),
         `ifdef SDRAMx16
         .DML           (dm[0]),
         .DMU           (dm[1]),
         .DQSL          (dqs[0]),
         .DQSU          (dqs[1]),
         .bDQSL         (dqs_n[0]),
         .bDQSU         (dqs_n[1]),
         `else
         .DM            (dm),
         .DQS           (dqs),
         .bDQS          (dqs_n),
         `endif
         .DQ            (dq),
         .RTT           ()
         );
  
       `endif
     `endif
     
 //---------------------------------------------------------------------------
  // Board Delays
  //---------------------------------------------------------------------------
  // New framework
  

 
  // set a specific board delay
  task set_dx_signal_sdram_delay;
    input integer dx_signal;
    input         direction;
    input integer dly;

    integer   auxvar ;
`ifdef BIDIRECTIONAL_SDRAM_DELAYS    
    begin
      if (direction == `OUT)
        case (dx_signal)
        `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15 : 
            dq_do_sdram_dly[dx_signal] = dly;
        `DQS  :     for (auxvar=0;auxvar<`SDRAM_BYTE_WIDTH;auxvar=auxvar+1) dqs_do_sdram_dly[auxvar]  = dly;
        `DQSN :     for (auxvar=0;auxvar<`SDRAM_BYTE_WIDTH;auxvar=auxvar+1) dqsn_do_sdram_dly[auxvar] = dly;
        `DM   :     $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
        //  {`IN,  `DM}  :         for (auxvar=0;auxvar<`SDRAM_BYTE_WIDTH;auxvar=auxvar+1) dm_di_sdram_dly[auxvar]   = dly;
	default   : 
          $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
        endcase // case ({direction, dx_signal})
      else if (direction == `IN)  
        case (dx_signal)
        `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7, `DQ_8, `DQ_9, `DQ_10, `DQ_11, `DQ_12, `DQ_13, `DQ_14, `DQ_15 : 
            dq_di_sdram_dly[dx_signal] = dly;
        `DQS  :     for (auxvar=0;auxvar<`SDRAM_BYTE_WIDTH;auxvar=auxvar+1) dqs_di_sdram_dly[auxvar]  = dly;
        `DQSN :     for (auxvar=0;auxvar<`SDRAM_BYTE_WIDTH;auxvar=auxvar+1) dqsn_di_sdram_dly[auxvar] = dly;
        `DM   :     for (auxvar=0;auxvar<`SDRAM_BYTE_WIDTH;auxvar=auxvar+1) dm_di_sdram_dly[auxvar]   = dly;
	default   : 
          $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
        endcase // case ({direction, dx_signal})
    end
`else
  $display("-> %0t: ==> WARNING: [set_dx_signal_sdram_delay] DQ/DQS/DM delay constructs can only be applied if BIDIRECTIONAL_SDRAM_DELAYS are defined!",$time);   
`endif
  endtask // set_dx_signal_sdram_delay


  
  task set_ac_signal_sdram_delay;
    input integer ac_signal;
    input integer dly;
    
    begin
      case (ac_signal)
          `ADDR_0, `ADDR_1, `ADDR_2, `ADDR_3, `ADDR_4, `ADDR_5, `ADDR_6, `ADDR_7, `ADDR_8, `ADDR_9, `ADDR_10, `ADDR_11, `ADDR_12, `ADDR_13, `ADDR_14, `ADDR_15, `ADDR_16, `ADDR_17 :
            addr_sdram_dly[ac_signal] = dly;            
          `CMD_BA0, `CMD_BA1, `CMD_BA2, `CMD_BA3 :     cmd_sdram_dly [ac_signal - `CMD_BA0] = dly;
          `CMD_ACT   :         cmd_sdram_dly [`SDRAM_BANK_WIDTH] = dly;
          `CMD_PARIN :         cmd_sdram_dly [`SDRAM_BANK_WIDTH + 1] = dly;
          `CMD_ODT   :         cmd_sdram_dly [`SDRAM_BANK_WIDTH + 2] = dly;
          `CMD_CKE   :         cmd_sdram_dly [`SDRAM_BANK_WIDTH + 3] = dly;
          `CMD_CSN   :         cmd_sdram_dly [`SDRAM_BANK_WIDTH + 4] = dly;
          `AC_CK0, `AC_CK1, `AC_CK2, `AC_CK3  :   //we only have 1 clock bit at this level, but keep naming macros consistent
            ck_sdram_dly  = dly;
	  default   : 
            $display("-> %0t: ==> WARNING: [set_ac_signal_sdram_delay] incorrect or missing direction/signal specification on task call.", $time);
        endcase // case ({direction, ac_signal})
    end
  endtask // set_dx_signal_sdram_delay
  
  // Legacy framework     
  
  // board delays are zeros by default
  initial
    begin
//      cmd_dly    = 0.0;
//      wr_dly     = 0.0;
//      rd_dly     = 0.0;
//      ck_dly     = 0.0;
//      qs_dly     = 0.0;
//      dqs_dly    = 0.0;
//      dqs_n_dly  = 0.0;
      fly_by_dly = 0.0;

//      #0.0;
//      update_board_delays;
    end

  
  // set a specific board delay
  task set_board_delay;
    input [2:0]  dly_type;  // type of delay
    input [31:0] dly_ps;    // delay in picoseconds

    reg [31:0] dly;
    begin
 //     #1.0;
      case (dly_type)
//        CMD_DELAY:   set_command_board_delay(dly_ps);
//        WRITE_DELAY: set_write_board_delay(dly_ps);
//        READ_DELAY:  set_read_board_delay(dly_ps);
//        CK_DELAY:    delay_output_clocks(dly_ps);
//        QS_DELAY:    delay_data_strobes(dly_ps);
//        DQS_DELAY:   delay_data_strobe(DQS_STROBE, dly_ps);
//        DQSb_DELAY:  delay_data_strobe(DQSb_STROBE, dly_ps);
        FLYBY_DELAY: set_fly_by_delay(dly_ps);
      endcase // case(dly_type)
    end
  endtask // set_board_delay
  
/*  
  // set board delay values
  task set_command_board_delay;
    input [31:0] dly;
    begin
      cmd_dly = dly/1000.0;
      update_board_delays;
    end
  endtask // set_command_board_delay

  // set board delay values
  task set_write_board_delay;
    input [31:0] dly;
    begin
      wr_dly = dly/1000.0;
      update_board_delays;
    end
  endtask // set_write_board_delay
  
  task set_read_board_delay;
    input [31:0] dly;
    begin
      rd_dly = dly/1000.0;
      update_board_delays;
    end
  endtask // set_read_board_delay
  
  
  // delay the output clocks
  task delay_output_clocks;
    input [31:0] dly;
    begin
      ck_dly = dly/1000.0;
      update_board_delays;
    end
  endtask // delay_output_clocks
  
  // delay the read data strobes
  task delay_data_strobes;
    input [31:0] dly;
    begin
      qs_dly = dly/1000.0;
      update_board_delays;
    end
  endtask // delay_data_strobes

  // delay one data strobe (delay added on top of the other two delays)
  task delay_data_strobe;
    input        strobe_name;
    input [31:0] dly;
    begin
      case (strobe_name)
        DQS_STROBE:  dqs_dly   = dly/1000.0;
        DQSb_STROBE: dqs_n_dly = dly/1000.0;
      endcase // case(strobe_name)
      update_board_delays;
    end
  endtask // delay_data_strobe
*/
  task set_fly_by_delay;
    input [31:0] dly;
    begin
      fly_by_dly = dly/1000.0;
    end
  endtask // set_fly_by_delay

  
  // Only micron models have been enhanced to include board delays and other
  // features to enable/disable certain checks
`ifdef MICRON_DDR
  `ifdef DDR2
    `define DWC_ENHANCED_DDR_MODEL
  `endif
  `ifdef DDR3
    `define DWC_ENHANCED_DDR_MODEL
  `endif
  `ifdef LPDDR1
    `define DWC_ENHANCED_DDR_MODEL
  `endif
  `ifdef LPDDR2
    `define DWC_ENHANCED_DDR_MODEL
  `endif
`elsif ELPIDA_DDR
  `ifdef LPDDR3
    `define DWC_ENHANCED_ELPIDA_DDR_MODEL
  `endif
`endif

/*  
  // update board delays
  // -------------------
  // update board delays in the SDRAM models
  // NOTE: currently only implemented in the Micron DDR2 SDRAM model
  task update_board_delays;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      // delay in the model is in ps
      sdram.cmd_dly   = 1000*cmd_dly;
      sdram.wr_dly    = 1000*wr_dly;
      sdram.rd_dly    = 1000*rd_dly;
      sdram.ck_dly    = 1000*ck_dly;
      sdram.qs_dly    = 1000*qs_dly;
      sdram.dqs_dly   = 1000*dqs_dly;
      sdram.dqs_b_dly = 1000*dqs_n_dly;
     `endif
    end
  endtask // update_board_delays
*/

  // delayed signals
  // ---------------
  // signals after board delays
  always @(ck)    ck_i    <= #(ck_sdram_dly+fly_by_dly) ck;
  always @(ck_n)  ck_n_i  <= #(ck_sdram_dly+fly_by_dly) ck_n;
  always @(cke)   cke_i   <= #(cmd_sdram_dly[`SDRAM_BANK_WIDTH+3] + fly_by_dly) cke;
  always @(odt)   odt_i   <= #(cmd_sdram_dly[`SDRAM_BANK_WIDTH+2] + fly_by_dly) odt;
  always @(cs_n)  cs_n_i  <= #(cmd_sdram_dly[`SDRAM_BANK_WIDTH+4] + fly_by_dly) cs_n;
  
generate
for(ac_bit=0; ac_bit<`SDRAM_ADDR_WIDTH; ac_bit=ac_bit+1) begin :  u_addr_dly_gen
  always @(a[ac_bit])     a_i[ac_bit]     <= #(addr_sdram_dly[ac_bit] + fly_by_dly) a[ac_bit];
end    
for(ac_bit=0; ac_bit<`SDRAM_BANK_WIDTH; ac_bit=ac_bit+1) begin :  u_ba_dly_gen
  always @(ba[ac_bit])     ba_i[ac_bit]     <= #(cmd_sdram_dly[ac_bit] + fly_by_dly) ba[ac_bit];
end
endgenerate  

`ifdef DDR4  
  always @(act_n) act_n_i    <= #(cmd_sdram_dly[`SDRAM_BANK_WIDTH] + fly_by_dly) act_n;
`else  
  always @(ras_n) ras_n_i <= #(cmd_sdram_dly[`SDRAM_BANK_WIDTH] + fly_by_dly) ras_n;
  always @(cas_n) cas_n_i <= #(addr_sdram_dly[17] + fly_by_dly) cas_n;
  always @(we_n)  we_n_i  <= #(addr_sdram_dly[16] + fly_by_dly) we_n;
`endif
  
  // SDRAM clock checks
  // ------------------
  // enable/diasble clock violation checks on the SDRAMs
  task set_clock_checks;
    input clock_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_clocks = clock_check;
     `elsif DWC_ENHANCED_ELPIDA_DDR_MODEL
      sdram.check_clocks = clock_check;
     `endif
    end
  endtask // enable_clock_checks
  
  
  // SDRAM DQ setup/hold checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_dq_setup_hold_checks;
    input dq_setup_hold_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dq_setup_hold = dq_setup_hold_check;
     `elsif DWC_ENHANCED_ELPIDA_DDR_MODEL
      sdram.check_dq_setup_hold = dq_setup_hold_check;
     `endif
    end
  endtask // enable_dq_setup_hold_checks
  
  
  // SDRAM DQ/DM/DQS pulse width checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_dq_pulse_width_checks;
    input dq_pulse_width_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dq_pulse_width = dq_pulse_width_check;
     `elsif DWC_ENHANCED_ELPIDA_DDR_MODEL
      sdram.check_dq_pulse_width = dq_pulse_width_check;
     `endif
    end
  endtask // enable_dq_pulse_width_checks
  
  
  `ifdef LPDDR2
  `else // DDR2 or DDR3
  // SDRAM DQS-toCK setup/hold checks
  // --------------------------------
  // enable/diasble DQS-to-CK setup/hold violation checks on the SDRAMs
  task set_dqs_ck_setup_hold_checks;
    input dqs_ck_setup_hold_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_dqs_ck_setup_hold = dqs_ck_setup_hold_check;
     `endif
    end
  endtask // enable_dqs_ck_setup_hold_checks
  
 
  // SDRAM Command and Address setup/hold timing checks
  // --------------------------------
  // enable/diasble Command and Address setup/hold violation checks on the SDRAMs
  task set_cmd_addr_timing_checks;
    input cmd_addr_timing_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_cmd_addr_timing = cmd_addr_timing_check;
     `endif
    end
  endtask // enable_cmd_addr_timing_checks
  
  
  // SDRAM Ctrl and Address pulse width checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task set_ctrl_addr_pulse_width_checks;
    input ctrl_addr_pulse_width_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_ctrl_addr_pulse_width = ctrl_addr_pulse_width_check;
     `elsif DWC_ENHANCED_ELPIDA_DDR_MODEL
      sdram.check_ctrl_addr_pulse_width = ctrl_addr_pulse_width_check;
     `endif
    end
  endtask // enable_ctrl_addr_pulse_width_checks

  `ifdef DDR3
  // SDRM ODTH{4,8} timing checks
  // --------------------------
  task set_odth_timing_checks;
    input odt_timing_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_odth = odt_timing_check;
     `endif
    end
  endtask // set_odth_timing_checks 
  `endif // ifdef DDR3

  `endif // ifdef LPDDR2
 
  // SDRAM refresh check
  // -------------------
  // enable/diasble refresh violation checks on the SDRAMs
  task set_refresh_check;
    input rfsh_check;
    begin
     `ifdef DWC_ENHANCED_DDR_MODEL
      sdram.check_rfc_max = rfsh_check;
     `endif
    end
  endtask // set_refresh_check

     `ifdef DWC_ENHANCED_DDR_MODEL
       `ifdef DDR2
  initial TRFC_MAX = sdram.TRFC_MAX; // default tRFCmax of the SDRAM
       `endif
     `endif
 
   
   // initialization sequence is normally very long - so change it to reduced
   // value unless it the testcase specially checks initialization, in which
   // case it has to define the FULL_SDRAM_INIT compile define
 `ifdef FULL_SDRAM_INIT
 `else
   `ifdef LPDDR2
   defparam sdram.TINIT3  = (`tDINIT0_c_ssi*`CLK_PRD*1000);
   defparam sdram.TINIT4  = ((1.0/11.0) *`tDINIT2_c_ssi*`CLK_PRD*1000);
   defparam sdram.TINIT5  = ((10.0/11.0)*`tDINIT2_c_ssi*`CLK_PRD*1000);
   defparam sdram.TZQINIT = ((`tDINIT3_c_ssi-1)*`CLK_PRD*1000);
   `endif
 `endif
   
endmodule // ddr_sdram

