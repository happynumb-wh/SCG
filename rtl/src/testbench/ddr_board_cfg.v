/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Board Delay configuration                                     *
 *                                                                            *
 *****************************************************************************/

`timescale 1ps/1fs  // Set the timescale for board delays

`ifdef RAM_PROBE
`else
  `define RAM_PROBE(RANK_NO,RANK_NO_2,BYTE_NO) `TB.dwc_dim[RANK_NO].u_ddr_rank.dwc_rank[RANK_NO_2].sdram_rank.dwc_sdram[BYTE_NO].xn_dram.u_sdram
`endif
  
module ddr_board_cfg
  #(
    // Parameters
    parameter pRANK_WIDTH          = 4,   // number of ranks
    parameter pCID_WIDTH           = 3,
    parameter pCK_WIDTH            = 1,
    parameter pNO_OF_ODTS          = 1, 
    parameter pNO_OF_CKES          = 1, 
    parameter pNO_OF_CSNS          = 1,                
    parameter pBANK_WIDTH          = 3,   // width of bank address
    parameter pADDR_WIDTH          = 16,  // width of address
    parameter pNO_OF_BYTES         = 4,   // number of bytes
    // data width and number of chips; partial bytes are bytes less than the
    // bytes supported in each SDRAM module
    parameter pDRAM_IO_WIDTH       = `SDRAM_DATA_WIDTH,
    parameter pDATA_WIDTH          = (pNO_OF_BYTES*8),
    parameter pBYTES_PER_DRAM      = (pDRAM_IO_WIDTH/8),
    parameter pPARTIAL_BYTES       = (pNO_OF_BYTES%pBYTES_PER_DRAM),
`ifdef SDRAMx4
    parameter pNO_OF_CHIPS         = (pNO_OF_BYTES*2),
    parameter pNO_OF_DQS_PER_SDRAM = 1,    
`else
    parameter pNO_OF_CHIPS         = (pPARTIAL_BYTES == 0) ? 
                                     (pDATA_WIDTH/pDRAM_IO_WIDTH) :
                                     (pDATA_WIDTH/pDRAM_IO_WIDTH + 1),
    parameter pNO_OF_DQS_PER_SDRAM = pBYTES_PER_DRAM,                                     
`endif
`ifdef DWC_DDRPHY_X4X2
    parameter pNO_OF_DQS_DM_DATX = 2    
`else
    parameter pNO_OF_DQS_DM_DATX = 1                                    
`endif

                                     
   )
   (
   );

  localparam MAX_CHAR_NO = 20;
  
`ifdef DWC_USE_SHARED_AC
  localparam SHARED_AC = 1;
`else
  localparam SHARED_AC = 0;
`endif   

  integer ck_delay          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer ckn_delay         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];  
  integer addr_delay        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pADDR_WIDTH-1]; 
  integer ba_delay          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pBANK_WIDTH-1];  
  integer csn_delay         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cid_delay         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pCID_WIDTH-1];  
  integer cke_delay         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];  
  integer odt_delay         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];  
  integer actn_delay        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1]; 
  integer parin_delay       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];   
  integer alertn_delay      [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];    
  integer dqs_delay         [`IN:`OUT][0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pNO_OF_DQS_PER_SDRAM-1];
  integer dqsn_delay        [`IN:`OUT][0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pNO_OF_DQS_PER_SDRAM-1]; 
  integer dm_delay          [`IN:`OUT][0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pNO_OF_DQS_PER_SDRAM-1];   
  integer dq_delay          [`IN:`OUT][0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1][0:pDRAM_IO_WIDTH-1];    

  integer tdqsck            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  
  integer ck_io_delay       [`IN:`OUT][0:pCK_WIDTH-1];
  integer ckn_io_delay      [`IN:`OUT][0:pCK_WIDTH-1];  
  integer addr_io_delay     [`IN:`OUT][0:pADDR_WIDTH-1]; 
  integer ba_io_delay       [`IN:`OUT][0:pBANK_WIDTH-1];  
  integer csn_io_delay      [`IN:`OUT][0:pNO_OF_CSNS-1];
  integer cid_io_delay      [`IN:`OUT][0:pCID_WIDTH-1];  
  integer cke_io_delay      [`IN:`OUT][0:pNO_OF_CKES-1];  
  integer odt_io_delay      [`IN:`OUT][0:pNO_OF_ODTS-1];  
  integer actn_io_delay     [`IN:`OUT]; 
  integer parin_io_delay    [`IN:`OUT];   
  integer alertn_io_delay   [`IN:`OUT];    
  integer dqs_io_delay      [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];
  integer dqsn_io_delay     [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1]; 
  integer dqsg_io_delay     [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];  
  integer dqs_pdd_io_delay  [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];
  integer dqs_pdr_io_delay  [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1]; 
  integer dqs_te_io_delay   [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];    
  integer dqsn_pdd_io_delay [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];
  integer dqsn_pdr_io_delay [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1]; 
  integer dqsn_te_io_delay  [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];  
  integer dqsg_pdd_io_delay [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];
  integer dqsg_pdr_io_delay [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1]; 
  integer dqsg_te_io_delay  [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];      
  integer dm_io_delay       [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1]; 
  integer dm_pdd_io_delay   [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];
  integer dm_pdr_io_delay   [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1]; 
  integer dm_te_io_delay    [`IN:`OUT][0:pNO_OF_BYTES-1][0:pNO_OF_DQS_DM_DATX-1];      
  integer dq_io_delay       [`IN:`OUT][0:pNO_OF_BYTES-1][0:8-1];  
  integer dq_pdr_io_delay   [`IN:`OUT][0:pNO_OF_BYTES-1][0:8-1];  
  integer dq_pdd_io_delay   [`IN:`OUT][0:pNO_OF_BYTES-1][0:8-1];  
  integer dq_te_io_delay    [`IN:`OUT][0:pNO_OF_BYTES-1][0:8-1];         

  integer addr_rj_cap       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer addr_rj_sig       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer addr_sj_amp       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    addr_sj_frq       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer addr_sj_phs       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer addr_dcd          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer addr_isi          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  
  integer ba_rj_cap         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer ba_rj_sig         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer ba_sj_amp         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    ba_sj_frq         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer ba_sj_phs         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer ba_dcd            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer ba_isi            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  
  integer csn_rj_cap        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer csn_rj_sig        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer csn_sj_amp        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    csn_sj_frq        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer csn_sj_phs        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer csn_dcd           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];  
  integer csn_isi           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];

  integer cid_rj_cap        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cid_rj_sig        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cid_sj_amp        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    cid_sj_frq        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cid_sj_phs        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cid_dcd           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1]; 
  integer cid_isi           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  
  integer cke_rj_cap        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cke_rj_sig        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cke_sj_amp        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    cke_sj_frq        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cke_sj_phs        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cke_dcd           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer cke_isi           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];

  integer odt_rj_cap        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer odt_rj_sig        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer odt_sj_amp        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    odt_sj_frq        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer odt_sj_phs        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer odt_dcd           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer odt_isi           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
     
  integer actn_rj_cap       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer actn_rj_sig       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer actn_sj_amp       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    actn_sj_frq       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer actn_sj_phs       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer actn_dcd          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer actn_isi          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
      
  integer parin_rj_cap      [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer parin_rj_sig      [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer parin_sj_amp      [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    parin_sj_frq      [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer parin_sj_phs      [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer parin_dcd         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer parin_isi         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
      
  integer alertn_rj_cap     [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer alertn_rj_sig     [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer alertn_sj_amp     [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    alertn_sj_frq     [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer alertn_sj_phs     [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer alertn_dcd        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer alertn_isi        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
      
  integer dqs_rj_cap        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqs_rj_sig        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqs_sj_amp        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    dqs_sj_frq        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqs_sj_phs        [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqs_dcd           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqs_isi           [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
   
  integer dqsn_rj_cap       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqsn_rj_sig       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqsn_sj_amp       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    dqsn_sj_frq       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqsn_sj_phs       [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqsn_dcd          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dqsn_isi          [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  
  integer dm_rj_cap         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dm_rj_sig         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dm_sj_amp         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    dm_sj_frq         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dm_sj_phs         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dm_dcd            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dm_isi            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  
  integer dq_rj_cap         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dq_rj_sig         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dq_sj_amp         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  real    dq_sj_frq         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dq_sj_phs         [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dq_dcd            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
  integer dq_isi            [0:pRANK_WIDTH-1][0:pNO_OF_CHIPS-1];
    
  event e_setup_board_cfg;
  event e_setup_jitter_cfg;
  
  integer i, j, k, l;
  integer addr_no, bank_no, ck_no, bit_no, direction, cid, ac_bit;
  
  genvar dwc_dim, dwc_rnk, dwc_chip, dwc_byte;

  
initial begin
  for(k=0; k < pRANK_WIDTH; k = k+1) begin
    for(j=0; j<pNO_OF_CHIPS; j = j+1) begin
      ck_delay[k][j]     = 0;      
      ckn_delay[k][j]    = 0;

      for(i=0; i<pADDR_WIDTH; i = i+1)
        addr_delay[k][j][i]    = 0; 

      for(i=0; i<pBANK_WIDTH; i = i+1)
        ba_delay[k][j][i]    = 0;  

      for(i=0; i<pCID_WIDTH; i = i+1)
        cid_delay[k][j][i]    = 0;

      csn_delay[k][j]       = 0;
      cke_delay[k][j]       = 0; 
      odt_delay[k][j]       = 0;
      actn_delay[k][j]      = 0; 
      parin_delay[k][j]     = 0;
      alertn_delay[k][j]    = 0;
               
      for(i=0; i<pNO_OF_DQS_PER_SDRAM; i = i+1)
        for(direction=0;direction<2;direction=direction+1) begin     
          dqs_delay[direction][k][j][i]     = 0;
          dqsn_delay[direction][k][j][i]    = 0;
          dm_delay[direction][k][j][i]      = 0;  
        end
      for(i=0; i<pDRAM_IO_WIDTH; i = i+1)
        for(direction=0;direction<2;direction=direction+1)      
          dq_delay[direction][k][j][i]    = 0;

      addr_rj_cap   [k][j] = 0;
      addr_rj_sig   [k][j] = 0;
      addr_sj_amp   [k][j] = 0;
      addr_sj_frq   [k][j] = 1;
      addr_sj_phs   [k][j] = 0;
      addr_dcd      [k][j] = 0;
      addr_isi      [k][j] = 0;

      ba_rj_cap     [k][j] = 0;
      ba_rj_sig     [k][j] = 0;
      ba_sj_amp     [k][j] = 0;
      ba_sj_frq     [k][j] = 1;
      ba_sj_phs     [k][j] = 0;
      ba_dcd        [k][j] = 0;
      ba_isi        [k][j] = 0;

      csn_rj_cap    [k][j] = 0;
      csn_rj_sig    [k][j] = 0;
      csn_sj_amp    [k][j] = 0;
      csn_sj_frq    [k][j] = 1;
      csn_sj_phs    [k][j] = 0;
      csn_dcd       [k][j] = 0;
      csn_isi       [k][j] = 0;

      cid_rj_cap    [k][j] = 0;
      cid_rj_sig    [k][j] = 0;
      cid_sj_amp    [k][j] = 0;
      cid_sj_frq    [k][j] = 1;
      cid_sj_phs    [k][j] = 0;
      cid_dcd       [k][j] = 0;
      cid_isi       [k][j] = 0;

      cke_rj_cap    [k][j] = 0;
      cke_rj_sig    [k][j] = 0;
      cke_sj_amp    [k][j] = 0;
      cke_sj_frq    [k][j] = 1;
      cke_sj_phs    [k][j] = 0;
      cke_dcd       [k][j] = 0;
      cke_isi       [k][j] = 0; 

      odt_rj_cap    [k][j] = 0;
      odt_rj_sig    [k][j] = 0;
      odt_sj_amp    [k][j] = 0;
      odt_sj_frq    [k][j] = 1;
      odt_sj_phs    [k][j] = 0;
      odt_dcd       [k][j] = 0;
      odt_isi       [k][j] = 0;

      actn_rj_cap   [k][j] = 0;
      actn_rj_sig   [k][j] = 0;
      actn_sj_amp   [k][j] = 0;
      actn_sj_frq   [k][j] = 1;
      actn_sj_phs   [k][j] = 0;
      actn_dcd      [k][j] = 0;
      actn_isi      [k][j] = 0;  

      parin_rj_cap  [k][j] = 0;
      parin_rj_sig  [k][j] = 0;
      parin_sj_amp  [k][j] = 0;
      parin_sj_frq  [k][j] = 1;
      parin_sj_phs  [k][j] = 0;
      parin_dcd     [k][j] = 0;
      parin_isi     [k][j] = 0;  

      alertn_rj_cap [k][j] = 0;
      alertn_rj_sig [k][j] = 0;
      alertn_sj_amp [k][j] = 0;
      alertn_sj_frq [k][j] = 1;
      alertn_sj_phs [k][j] = 0;
      alertn_dcd    [k][j] = 0;
      alertn_isi    [k][j] = 0;  

      dqs_rj_cap    [k][j] = 0;
      dqs_rj_sig    [k][j] = 0;
      dqs_sj_amp    [k][j] = 0;
      dqs_sj_frq    [k][j] = 1;
      dqs_sj_phs    [k][j] = 0;
      dqs_dcd       [k][j] = 0;
      dqs_isi       [k][j] = 0;
      
      dqsn_rj_cap   [k][j] = 0;
      dqsn_rj_sig   [k][j] = 0;
      dqsn_sj_amp   [k][j] = 0;
      dqsn_sj_frq   [k][j] = 1;
      dqsn_sj_phs   [k][j] = 0;
      dqsn_isi      [k][j] = 0;
      
      dm_rj_cap     [k][j] = 0;
      dm_rj_sig     [k][j] = 0;
      dm_sj_amp     [k][j] = 0;
      dm_sj_frq     [k][j] = 1;
      dm_sj_phs     [k][j] = 0;
      dm_isi        [k][j] = 0;
      
      dq_rj_cap     [k][j] = 0;
      dq_rj_sig     [k][j] = 0;
      dq_sj_amp     [k][j] = 0;
      dq_sj_frq     [k][j] = 1;
      dq_sj_phs     [k][j] = 0;
      dq_isi        [k][j] = 0;
    end
  end
  for(direction=0;direction<2;direction=direction+1) begin 
    for(i=0; i<pCK_WIDTH; i = i+1) begin
      ck_io_delay[direction][i]  = 0;
      ckn_io_delay[direction][i] = 0; 
    end 

    for(i=0; i<pADDR_WIDTH; i = i+1)
      addr_io_delay[direction][i]   = 0; 

    for(i=0; i<pBANK_WIDTH; i = i+1)
      ba_io_delay[direction][i]     = 0;  

    for(i=0; i<pCID_WIDTH; i = i+1)
      cid_io_delay[direction][i]    = 0;
    
    for(i=0; i<pNO_OF_CSNS; i = i+1)
      csn_io_delay[direction][i]    = 0;
    
    for(i=0; i<pNO_OF_CKES; i = i+1)  
      cke_io_delay[direction][i]    = 0; 
    
    for(i=0; i<pNO_OF_ODTS; i = i+1)  
      odt_io_delay[direction][i]    = 0;
      
    actn_io_delay[direction]      = 0; 
    parin_io_delay[direction]     = 0;
    alertn_io_delay[direction]    = 0; 
  end
  
  for(j=0; j<pNO_OF_BYTES; j = j+1) begin  
    for(i=0; i<pNO_OF_DQS_DM_DATX; i = i+1)
      for(direction=0;direction<2;direction=direction+1) begin     
        dqs_io_delay[direction][j][i]      = 0;
        dqs_pdr_io_delay[direction][j][i]  = 0;    
        dqs_pdd_io_delay[direction][j][i]  = 0;
        dqs_te_io_delay[direction][j][i]   = 0;                          
        dqsn_io_delay[direction][j][i]     = 0;
        dqsn_pdr_io_delay[direction][j][i] = 0;    
        dqsn_pdd_io_delay[direction][j][i] = 0;
        dqsn_te_io_delay[direction][j][i]  = 0; 
        dqsg_io_delay[direction][j][i]     = 0;
        dqsg_pdr_io_delay[direction][j][i] = 0;    
        dqsg_pdd_io_delay[direction][j][i] = 0;
        dqsg_te_io_delay[direction][j][i]  = 0;                   
        dm_io_delay[direction][j][i]       = 0;
        dm_pdr_io_delay[direction][j][i]   = 0;    
        dm_pdd_io_delay[direction][j][i]   = 0;
        dm_te_io_delay[direction][j][i]    = 0;           
      end

    for(i=0; i<8; i = i+1)
      for(direction=0;direction<2;direction=direction+1) begin      
        dq_io_delay[direction][j][i]     = 0; 
        dq_pdr_io_delay[direction][j][i] = 0;    
        dq_pdd_io_delay[direction][j][i] = 0;
        dq_te_io_delay[direction][j][i]  = 0;         
      end
  end    
end

task config_delay;
  
  input reg     [MAX_CHAR_NO * 8 : 0] signal;
  input reg                           direction; 
  input integer                       rank_index;
  input integer                       chip_index;
  input integer                       index;
  input integer                       value;
  
  begin
    //$display("Delay: %0d - %0s, rank = %0d, chip = %0d, index = %0d, value = %0d", direction, signal, rank_index, chip_index, index, value);
    case(signal)
      "ck": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          ck_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal ck.", $time);
      end
      "ck_io": begin
        if((direction == `IN || direction == `OUT) && (index >= 0 && index < pCK_WIDTH))
          ck_io_delay[direction][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal ck_io.", $time); 
      end
      "ckn": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          ckn_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal ckn.", $time);
      end
      "ckn_io": begin
        if((direction == `IN || direction == `OUT)  && (index >= 0 && index < pCK_WIDTH))
          ckn_io_delay[direction][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal ckn_io.", $time); 
      end
      "addr": begin
	    if((index >= 0 && index < pADDR_WIDTH) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
	      addr_delay[rank_index][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal addr.", $time);
      end
      "addr_io": begin
	    if((index >= 0 && index < pADDR_WIDTH) && (direction == `IN || direction == `OUT))
	      addr_io_delay[direction][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal addr_io.", $time);
      end 
      "ba": begin
	    if((index >= 0 && index < pBANK_WIDTH) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          ba_delay[rank_index][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal ba.", $time);
      end
      "ba_io": begin
	    if((index >= 0 && index < pBANK_WIDTH) && (direction == `IN || direction == `OUT))
          ba_io_delay[direction][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal ba_io.", $time);
      end
      "csn": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          csn_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal csn.", $time);
      end
      "csn_io": begin
        if((direction == `IN || direction == `OUT)  && (index >= 0 && index < pNO_OF_CSNS))
          csn_io_delay[direction][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal csn_io.", $time); 
      end
      "cid": begin
	    if((index >= 0 && index < pCID_WIDTH) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          cid_delay[rank_index][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal cid.", $time);
      end   
      "cid_io": begin
	    if((index >= 0 && index < pCID_WIDTH) && (direction == `IN || direction == `OUT))
          cid_io_delay[direction][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal cid_io.", $time);
      end           
      "cke": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          cke_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal cke.", $time);
      end
      "cke_io": begin
        if((direction == `IN || direction == `OUT) && (index >= 0 && index < pNO_OF_CKES))
          cke_io_delay[direction][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal cke_io.", $time); 
      end
      "odt": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          odt_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal odt.", $time);
      end
      "odt_io": begin
        if((direction == `IN || direction == `OUT) && (index >= 0 && index < pNO_OF_ODTS))
          odt_io_delay[direction][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal odt_io.", $time); 
      end
      "actn": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          actn_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal actn.", $time);
      end
      "actn_io": begin
        if(direction == `IN || direction == `OUT)
          actn_io_delay[direction] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal actn_io.", $time); 
      end
      "parin": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          parin_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal parin.", $time);
      end
      "parin_io": begin
        if(direction == `IN || direction == `OUT)
          parin_io_delay[direction] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal parin_io.", $time); 
      end
      "alertn": begin
	    if((rank_index >= 0 && rank_index < pRANK_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS))
          alertn_delay[rank_index][chip_index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal alertn.", $time);
      end   
      "alertn_io": begin
        if(direction == `IN || direction == `OUT)
          alertn_io_delay[direction] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal alertn_io.", $time); 
      end
      "dqs": begin
	    if((index >= 0 && index < pNO_OF_DQS_PER_SDRAM) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (direction == `IN || direction == `OUT))
          dqs_delay[direction][rank_index][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqs.", $time);
      end
      "dqs_io": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqs_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqs_io.", $time);
      end 
      "dqs_pdr": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqs_pdr_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqs_pdr.", $time);
      end 
      "dqs_pdd": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqs_pdd_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqs_pdd.", $time);
      end
      "dqs_te": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqs_te_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqs_te.", $time);
      end                           
      "dqsn": begin
	    if((index >= 0 && index < pNO_OF_DQS_PER_SDRAM) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (direction == `IN || direction == `OUT))
          dqsn_delay[direction][rank_index][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsn.", $time);
      end    
      "dqsn_io": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsn_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsn_io.", $time);
      end   
      "dqsn_pdr": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsn_pdr_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsn_pdr.", $time);
      end 
      "dqsn_pdd": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsn_pdd_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsn_pdd.", $time);
      end
      "dqsn_te": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsn_te_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsn_te.", $time);
      end   
      "dqsg_io": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsg_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsg_io.", $time);
      end 
      "dqsg_pdr": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsg_pdr_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsg_pdr.", $time);
      end 
      "dqsg_pdd": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsg_pdd_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsg_pdd.", $time);
      end
      "dqsg_te": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dqsg_te_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dqsg_te.", $time);
      end                    
      "dq": begin
	    if((index >= 0 && index < pDRAM_IO_WIDTH) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (direction == `IN || direction == `OUT))
          dq_delay[direction][rank_index][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dq.", $time);
      end
      "dq_io": begin
	    if((index >= 0 && index < 8) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dq_io_delay[direction][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dq_io.", $time);
      end   
      "dq_pdd": begin
	    if((index >= 0 && index < 8) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dq_pdd_io_delay[direction][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dq_pdd.", $time);
      end   
      "dq_pdr": begin
	    if((index >= 0 && index < 8) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dq_pdr_io_delay[direction][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dq_pdr.", $time);
      end   
      "dq_te": begin
	    if((index >= 0 && index < 8) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dq_te_io_delay[direction][chip_index][index] = value;
	    else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dq_te.", $time);
      end                        
      "dm": begin
	    if((index >= 0 && index < pNO_OF_DQS_PER_SDRAM) && (chip_index >= 0 && chip_index < pNO_OF_CHIPS) && (rank_index >= 0 && rank_index < pRANK_WIDTH) && (direction == `IN || direction == `OUT))
          dm_delay[direction][rank_index][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dm.", $time);
      end
      "dm_io": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dm_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dm_io.", $time);  
      end 
      "dm_pdr": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dm_pdr_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dm_pdr.", $time);
      end 
      "dm_pdd": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dm_pdd_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dm_pdd.", $time);
      end
      "dm_te": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES) && (direction == `IN || direction == `OUT))
          dm_te_io_delay[direction][chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal dm_te.", $time);
      end          
      "tdqsck": begin
	    if((index >= 0 && index < pNO_OF_DQS_DM_DATX) && (chip_index >= 0 && chip_index < pNO_OF_BYTES))
          tdqsck[chip_index][index] = value;
        else
          $display("-> %0t: ==> WARNING: [config_delay] incorrect or missing index specification on task call for signal tdqsck.", $time);
      end          
    endcase //signal    
  end
endtask //config_delay


task config_jitter;
  
  input reg     [MAX_CHAR_NO * 8 : 0] jitter_comp;
  input reg     [MAX_CHAR_NO * 8 : 0] signal;
  input integer                       rank_index;
  input integer                       chip_index;
  input integer                       value;

  begin
    if((rank_index >= 0 && rank_index < pRANK_WIDTH) || (chip_index >= 0 && chip_index < pNO_OF_CHIPS)) begin
      case(signal)
        "addr": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   addr_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   addr_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   addr_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) addr_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   addr_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   addr_dcd[rank_index][chip_index]    = value;
            "isi"      :   addr_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end
        "ba": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   ba_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   ba_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   ba_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) ba_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   ba_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   ba_dcd[rank_index][chip_index]    = value;
            "isi"      :   ba_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end
        "csn": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   csn_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   csn_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   csn_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) csn_sj_frq[rank_index][chip_index]  = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   csn_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   csn_dcd[rank_index][chip_index]    = value;
            "isi"      :   csn_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end  
        "cid": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   cid_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   cid_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   cid_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) cid_sj_frq[rank_index][chip_index]  = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   cid_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   cid_dcd[rank_index][chip_index]    = value;
            "isi"      :   cid_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end        
        "cke": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   cke_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   cke_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   cke_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) cke_sj_frq[rank_index][chip_index]  = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   cke_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   cke_dcd[rank_index][chip_index]    = value;
            "isi"      :   cke_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end  
        "odt": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   odt_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   odt_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   odt_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) odt_sj_frq[rank_index][chip_index]  = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   odt_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   odt_dcd[rank_index][chip_index]    = value;
            "isi"      :   odt_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end 
        "actn": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   actn_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   actn_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   actn_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) actn_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   actn_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   actn_dcd[rank_index][chip_index]    = value;
            "isi"      :   actn_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end   
        "parin": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   parin_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   parin_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   parin_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) parin_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   parin_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   parin_dcd[rank_index][chip_index]    = value;
            "isi"      :   parin_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end  
        "alertn": begin   //jitter only available in AC bus (cmd or addr, not CK)
	      case(jitter_comp)
            "rj_peak"  :   alertn_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   alertn_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   alertn_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) alertn_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   alertn_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   alertn_dcd[rank_index][chip_index]    = value;
            "isi"      :   alertn_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp	
        end                                     
        "dqs": begin
          case(jitter_comp)
            "rj_peak"  :   dqs_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   dqs_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   dqs_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) dqs_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   dqs_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   dqs_dcd[rank_index][chip_index]    = value;
            "isi"      :   dqs_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp
        end
        "dqsn": begin
          case(jitter_comp)
            "rj_peak"  :   dqsn_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   dqsn_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   dqsn_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) dqsn_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   dqsn_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   dqsn_dcd[rank_index][chip_index]    = value;            
            "isi"      :   dqsn_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp
        end
        "dm": begin
          case(jitter_comp)
            "rj_peak"  :   dm_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   dm_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   dm_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) dm_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   dm_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   dm_dcd[rank_index][chip_index]    = value;
            "isi"      :   dm_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp
        end
        "dq": begin
          case(jitter_comp)
            "rj_peak"  :   dq_rj_cap[rank_index][chip_index] = value;
            "rj_sigma" :   dq_rj_sig[rank_index][chip_index] = value;
            "sj_peak"  :   dq_sj_amp[rank_index][chip_index] = value;
            "sj_freq"  :   if (value > 0) dq_sj_frq[rank_index][chip_index] = $itor(value);
                           else $display("-> %0t: ==> WARNING: [config_jitter] Attempt to specify negative frequency for SJ", $time);
            "sj_phase" :   dq_sj_phs[rank_index][chip_index] = value;
            "dcd"      :   dq_dcd[rank_index][chip_index]    = value;
            "isi"      :   dq_isi[rank_index][chip_index]    = value;
	        default: $display("-> %0t: ==> WARNING: [config_jitter] incorrect or missing jitter_comp specification on task call.", $time);
	      endcase //jitter_comp
        end
      endcase  
    end else
      $display("-> %0t: ==> WARNING: [config_jitter] incorrect chip/rank index specification on task call.", $time); 
  end 
endtask  // config_jitter


task set_board_cfg;

begin
   -> e_setup_board_cfg;
end

endtask   


task set_board_jitter_cfg;

begin
  -> e_setup_jitter_cfg;
end

endtask //set_board_jitter_cfg

generate
for(dwc_dim=0;dwc_dim<`DWC_NO_OF_DIMMS;dwc_dim=dwc_dim+1) begin : u_rank_board_cfg_gen
  for(dwc_rnk=0;dwc_rnk<`DWC_RANKS_PER_DIMM;dwc_rnk=dwc_rnk+1) begin : u_rank_2_board_cfg_gen
`ifdef DWC_USE_SHARED_AC
  `ifdef SDRAMx4
    for(dwc_chip=0;dwc_chip<( `CH0_DX8_BYTE_WIDTH + (`DWC_NO_OF_BYTES % 2)*(dwc_dim % 2) )*2;dwc_chip=dwc_chip+1) begin : u_chip_sdram_cfg  
  `else
    for(dwc_chip=0;dwc_chip<( `CH0_DX8_BYTE_WIDTH + (`DWC_NO_OF_BYTES % 2)*(dwc_dim % 2) )/(`SDRAM_DATA_WIDTH/8);dwc_chip=dwc_chip+1) begin : u_chip_sdram_cfg
  `endif 
`else
  `ifdef SDRAMx4
    for(dwc_chip=0;dwc_chip<`DWC_NO_OF_BYTES*2;dwc_chip=dwc_chip+1) begin : u_chip_sdram_cfg
  `else
    for(dwc_chip=0;dwc_chip<`DWC_NO_OF_BYTES/(`SDRAM_DATA_WIDTH/8);dwc_chip=dwc_chip+1) begin : u_chip_sdram_cfg
  `endif
`endif
    always @(e_setup_board_cfg) begin
      for(direction=0;direction <2; direction=direction+1) begin
        if (`SDRAM_DATA_WIDTH == 4) begin
          bit_no = 0 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_0,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][bit_no]);
          bit_no = 1 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_1,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][bit_no]);
          bit_no = 2 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_2,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][bit_no]);
          bit_no = 3 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_3,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][bit_no]);
        end
        else begin
          bit_no = 0 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_0,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 1 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_1,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 2 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_2,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 3 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_3,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 4 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_4,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 5 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_5,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 6 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_6,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 7 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_7,  direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
        end
        if ((`SDRAM_DATA_WIDTH == 16)||(`SDRAM_DATA_WIDTH == 32)) begin
          bit_no = 8  ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_8, direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 9  ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_9, direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 10 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_10,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 11 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_11,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 12 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_12,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 13 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_13,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 14 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_14,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 15 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_15,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
        end  
        if (`SDRAM_DATA_WIDTH == 32) begin
          bit_no = 16 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_16,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 17 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_17,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 18 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_18,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 19 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_19,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 20 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_20,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 21 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_21,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 22 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_22,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 23 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_23,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 24 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_24,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 25 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_25,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 26 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_26,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 27 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_27,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 28 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_28,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 29 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_29,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 30 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_30,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
          bit_no = 31 ;  `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQ_31,direction,dq_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bit_no]);
        end  
        `ifdef DWC_DDRPHY_X4MODE
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQS,   direction,dqs_delay [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][0]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQSN,  direction,dqsn_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][0]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DM,    direction,dm_delay  [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][0]);
        `else
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQS,   direction,dqs_delay [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][0]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQSN,  direction,dqsn_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][0]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DM,    direction,dm_delay  [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][0]);
        `endif
        if ((`SDRAM_DATA_WIDTH == 16)||(`SDRAM_DATA_WIDTH == 32)) begin    
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQS_1, direction,dqs_delay [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][1]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQSN_1,direction,dqsn_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][1]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DM_1,  direction,dm_delay  [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][1]);
        end
        if (`SDRAM_DATA_WIDTH == 32) begin  
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQS_2, direction,dqs_delay [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][2]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQSN_2,direction,dqsn_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][2]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DM_2,  direction,dm_delay  [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][2]); 
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQS_3, direction,dqs_delay [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][3]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DQSN_3,direction,dqsn_delay[direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][3]);
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sdram_delay(`DM_3,  direction,dm_delay  [direction][(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][3]);
        end
      end
      `ifdef DWC_DDRPHY_X4MODE    
        for (addr_no = 0; addr_no < pADDR_WIDTH; addr_no = addr_no + 1)
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay(`ADDR_0  + addr_no,addr_delay   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][addr_no]);
        for (bank_no = 0; bank_no < pBANK_WIDTH; bank_no = bank_no + 1)
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay(`CMD_BA0 + bank_no,ba_delay     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][bank_no]);
        for (cid = 0; cid < pCID_WIDTH; cid = cid + 1)
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay(`CMD_CID0 + cid,cid_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip][cid]);          
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_ACT       ,actn_delay   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_PARIN     ,parin_delay  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_ALERTN    ,alertn_delay [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);      
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_ODT       ,odt_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_CKE       ,cke_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_CSN       ,csn_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`AC_CK         ,ck_delay     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`AC_CKN        ,ckn_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);        
      `else
        for (addr_no = 0; addr_no < pADDR_WIDTH; addr_no = addr_no + 1)
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay(`ADDR_0  + addr_no,addr_delay   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][addr_no]);
        for (bank_no = 0; bank_no < pBANK_WIDTH; bank_no = bank_no + 1)
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay(`CMD_BA0 + bank_no,ba_delay     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][bank_no]);
        for (cid = 0; cid < pCID_WIDTH; cid = cid + 1)
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay(`CMD_CID0 + cid,cid_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip][cid]);            
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_ACT       ,actn_delay   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_PARIN     ,parin_delay  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_ALERTN    ,alertn_delay [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);      
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_ODT       ,odt_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_CKE       ,cke_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`CMD_CSN       ,csn_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`AC_CK         ,ck_delay     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sdram_delay  (`AC_CKN        ,ckn_delay    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);        
      `endif
      end     
    end  //dwc_chip
  end // dwc_rnk
end  // dwc_dim  
endgenerate 


generate
`ifdef DWC_DDRPHY_X4X2
for(dwc_byte=0;dwc_byte<pNO_OF_BYTES*2;dwc_byte=dwc_byte+2) begin : u_byte_io_cfg
  always @(e_setup_board_cfg) begin
    for(direction=0;direction <2; direction=direction+1) begin
      for(bit_no=0;bit_no <8; bit_no=bit_no+1)
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0 + bit_no,direction,0,dq_io_delay[direction][dwc_byte/2][bit_no]);
      for(bit_no=0;bit_no <pNO_OF_DQS_DM_DATX; bit_no=bit_no+1) begin  
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS, direction, bit_no, dqs_io_delay[direction][dwc_byte/2][bit_no]);
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN,direction, bit_no, dqsn_io_delay[direction][dwc_byte/2][bit_no]);
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG,direction, bit_no, dqsg_io_delay[direction][dwc_byte/2][bit_no]);    
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM,  direction, bit_no, dm_io_delay[direction][dwc_byte/2][bit_no]);
      end
    end  
    for(bit_no=0;bit_no <pNO_OF_DQS_DM_DATX; bit_no=bit_no+1) begin     
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS_PDD, `OUT,bit_no, dqs_pdd_io_delay[`OUT][dwc_byte/2][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS_PDR, `OUT,bit_no, dqs_pdr_io_delay[`OUT][dwc_byte/2][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS_TE,  `OUT,bit_no, dqs_te_io_delay[`OUT][dwc_byte/2][bit_no]);         
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN_PDD,`OUT,bit_no, dqsn_pdd_io_delay[`OUT][dwc_byte/2][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN_PDR,`OUT,bit_no, dqsn_pdr_io_delay[`OUT][dwc_byte/2][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN_TE, `OUT,bit_no, dqsn_te_io_delay[`OUT][dwc_byte/2][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG_PDD,`OUT,bit_no, dqsg_pdd_io_delay[`OUT][dwc_byte/2][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG_PDR,`OUT,bit_no, dqsg_pdr_io_delay[`OUT][dwc_byte/2][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG_TE, `OUT,bit_no, dqsg_te_io_delay[`OUT][dwc_byte/2][bit_no]);       
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM_PDD,  `OUT,bit_no, dm_pdd_io_delay[`OUT][dwc_byte/2][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM_PDR,  `OUT,bit_no, dm_pdr_io_delay[`OUT][dwc_byte/2][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM_TE,   `OUT,bit_no, dm_te_io_delay[`OUT][dwc_byte/2][bit_no]); 
    end
    for(bit_no=0;bit_no <8; bit_no=bit_no+1) begin
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0_PDD + bit_no,`OUT,bit_no,dq_pdd_io_delay[`OUT][dwc_byte/2][bit_no]);      
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0_PDR + bit_no,`OUT,bit_no,dq_pdr_io_delay[`OUT][dwc_byte/2][bit_no]);      
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0_TE  + bit_no,`OUT,bit_no,dq_te_io_delay[`OUT][dwc_byte/2][bit_no]);
    end
  end
end  //dwc_byte
`else
for(dwc_byte=0;dwc_byte<pNO_OF_BYTES;dwc_byte=dwc_byte+1) begin : u_byte_io_cfg
  always @(e_setup_board_cfg) begin
    for(direction=0;direction <2; direction=direction+1) begin
      for(bit_no=0;bit_no <8; bit_no=bit_no+1)
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0 + bit_no,direction,0,dq_io_delay[direction][dwc_byte][bit_no]);
      for(bit_no=0;bit_no <pNO_OF_DQS_DM_DATX; bit_no=bit_no+1) begin  
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS, direction, bit_no, dqs_io_delay[direction][dwc_byte][bit_no]);
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN,direction, bit_no, dqsn_io_delay[direction][dwc_byte][bit_no]);
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG,direction, bit_no, dqsg_io_delay[direction][dwc_byte][bit_no]);    
        `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM,  direction, bit_no, dm_io_delay[direction][dwc_byte][bit_no]);
      end
    end  
    for(bit_no=0;bit_no <pNO_OF_DQS_DM_DATX; bit_no=bit_no+1) begin     
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS_PDD, `OUT,bit_no, dqs_pdd_io_delay[`OUT][dwc_byte][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS_PDR, `OUT,bit_no, dqs_pdr_io_delay[`OUT][dwc_byte][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQS_TE,  `OUT,bit_no, dqs_te_io_delay[`OUT][dwc_byte][bit_no]);         
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN_PDD,`OUT,bit_no, dqsn_pdd_io_delay[`OUT][dwc_byte][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN_PDR,`OUT,bit_no, dqsn_pdr_io_delay[`OUT][dwc_byte][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSN_TE, `OUT,bit_no, dqsn_te_io_delay[`OUT][dwc_byte][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG_PDD,`OUT,bit_no, dqsg_pdd_io_delay[`OUT][dwc_byte][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG_PDR,`OUT,bit_no, dqsg_pdr_io_delay[`OUT][dwc_byte][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQSG_TE, `OUT,bit_no, dqsg_te_io_delay[`OUT][dwc_byte][bit_no]);       
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM_PDD,  `OUT,bit_no, dm_pdd_io_delay[`OUT][dwc_byte][bit_no]);  
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM_PDR,  `OUT,bit_no, dm_pdr_io_delay[`OUT][dwc_byte][bit_no]);   
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DM_TE,   `OUT,bit_no, dm_te_io_delay[`OUT][dwc_byte][bit_no]); 
    end
    for(bit_no=0;bit_no <8; bit_no=bit_no+1) begin
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0_PDD + bit_no,`OUT,bit_no,dq_pdd_io_delay[`OUT][dwc_byte][bit_no]);      
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0_PDR + bit_no,`OUT,bit_no,dq_pdr_io_delay[`OUT][dwc_byte][bit_no]);      
      `DATX8_BRD_DLY(dwc_byte).set_dx_signal_board_delay(`DQ_0_TE  + bit_no,`OUT,bit_no,dq_te_io_delay[`OUT][dwc_byte][bit_no]);
    end
  end
end  //dwc_byte
`endif
endgenerate

always @(e_setup_board_cfg) begin   : u_ac_board_cfg
  for(direction = 0; direction < 2; direction = direction + 1) begin
    for(addr_no = 0; addr_no < pADDR_WIDTH; addr_no = addr_no + 1)
      `AC_BRD_DLY.set_ac_signal_board_delay(`ADDR_0 + addr_no, direction,addr_no,addr_io_delay[direction][addr_no]);
      
    for (bank_no = 0; bank_no < pBANK_WIDTH; bank_no = bank_no + 1)
      `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_BA0 + bank_no, direction,bank_no,ba_io_delay[direction][bank_no]);

    `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_ACT,   direction,0,actn_io_delay[direction]);
    
    `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_PARIN, direction,0,parin_io_delay[direction]);
    
    `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_ALERTN,direction,0,alertn_io_delay[direction]); 
       
    for (ac_bit = 0; ac_bit < pNO_OF_ODTS; ac_bit = ac_bit + 1)
      `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_ODT,   direction,ac_bit,odt_io_delay[direction][ac_bit]);

    for (ac_bit = 0; ac_bit < pNO_OF_CKES; ac_bit = ac_bit + 1)
      `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_CKE,   direction,ac_bit,cke_io_delay[direction][ac_bit]);
      
    for (ac_bit = 0; ac_bit < pNO_OF_CSNS; ac_bit = ac_bit + 1)
      `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_CSN,   direction,ac_bit,csn_io_delay[direction][ac_bit]);
    
    for (ac_bit = 0; ac_bit < pCID_WIDTH; ac_bit = ac_bit + 1) 
      `AC_BRD_DLY.set_ac_signal_board_delay(`CMD_CID0 + ac_bit, direction,ac_bit,cid_io_delay[direction][ac_bit]);    
    
    for(ck_no = 0 ; ck_no < pCK_WIDTH ; ck_no = ck_no + 1)
      `AC_BRD_DLY.set_ac_signal_board_delay(`AC_CK0+ck_no,direction,ck_no,ck_io_delay[direction][ck_no]);
  end
end



generate
for(dwc_dim=0;dwc_dim<`DWC_NO_OF_DIMMS;dwc_dim=dwc_dim+1) begin : u_rank_jitter_cfg_gen
  for(dwc_rnk=0;dwc_rnk<`DWC_RANKS_PER_DIMM;dwc_rnk=dwc_rnk+1) begin : u_rank2_jitter_cfg_gen
`ifdef DWC_USE_SHARED_AC
  `ifdef SDRAMx4
    for(dwc_chip=0;dwc_chip<( `CH0_DX8_BYTE_WIDTH + (`DWC_NO_OF_BYTES % 2)*(dwc_dim % 2) )*2;dwc_chip=dwc_chip+1) begin : u_sdram_jitter_cfg  
  `else
    for(dwc_chip=0;dwc_chip<( `CH0_DX8_BYTE_WIDTH + (`DWC_NO_OF_BYTES % 2)*(dwc_dim % 2) )/(`SDRAM_DATA_WIDTH/8);dwc_chip=dwc_chip+1) begin : u_sdram_jitter_cfg
  `endif 
`else
  `ifdef SDRAMx4
    for(dwc_chip=0;dwc_chip<`DWC_NO_OF_BYTES*2;dwc_chip=dwc_chip+1) begin : u_sdram_jitter_cfg
  `else
    for(dwc_chip=0;dwc_chip<`DWC_NO_OF_BYTES/(`SDRAM_DATA_WIDTH/8);dwc_chip=dwc_chip+1) begin : u_sdram_jitter_cfg
  `endif
`endif
      always@(e_setup_jitter_cfg) begin
        for(direction=0;direction<2;direction=direction+1) begin
          if (`SDRAM_DATA_WIDTH == 4) begin
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_0,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_1,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_2,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_3,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_0,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_phs   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_1,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_phs   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_2,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_phs   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_3,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dq_sj_phs   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_0,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_1,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_2,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_3,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_0,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_1,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_2,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_3,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQS ,  direction,dqs_rj_cap [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dqs_rj_sig [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQSN,  direction,dqsn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dqsn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DM,    direction,dm_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dm_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQS ,  direction,dqs_sj_amp [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dqs_sj_frq [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dqs_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQSN,  direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dqsn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dqsn_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DM,    direction,dm_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dm_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip], dm_sj_phs   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQS ,  direction,dqs_dcd    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQSN,  direction,dqsn_dcd   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DM,    direction,dm_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQS ,  direction,dqs_isi    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQSN,  direction,dqsn_isi   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DM,    direction,dm_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*(2*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/4) - `DWC_NO_OF_BYTES%2)) + dwc_chip]);            
          end  
          else begin  
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_0,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_1,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_2,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_3,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_4,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_5,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_6,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_7,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_0,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_1,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_2,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_3,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_4,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_5,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_6,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_7,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_0,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_1,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_2,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_3,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_4,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_5,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_6,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_7,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_0,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_1,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_2,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_3,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_4,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_5,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_6,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_7,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQS ,  direction,dqs_rj_cap [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dqs_rj_sig [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQSN,  direction,dqsn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dqsn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DM,    direction,dm_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dm_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQS ,  direction,dqs_sj_amp [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dqs_sj_frq [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dqs_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQSN,  direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dqsn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dqsn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DM,    direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dm_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)],  dm_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQS ,  direction,dqs_dcd    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQSN,  direction,dqsn_dcd   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DM,    direction,dm_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQS ,  direction,dqs_isi    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQSN,  direction,dqsn_isi   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DM,    direction,dm_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)]);            
          end  
          if ((`SDRAM_DATA_WIDTH == 16)||(`SDRAM_DATA_WIDTH == 32)) begin
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_8,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_9,  direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_10, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_11, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_12, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_13, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_14, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_15, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]); 

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_8,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_9,  direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_10, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_11, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_12, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_13, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_14, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_15, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dq_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_8,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_9,  direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_10, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_11, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_12, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_13, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_14, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_15, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_8,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_9,  direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_10, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_11, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_12, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_13, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_14, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_15, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQS_1 ,direction,dqs_rj_cap [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dqs_rj_sig [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQSN_1,direction,dqsn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dqsn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DM_1,  direction,dqsn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dm_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQS_1 ,direction,dqs_sj_amp [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dqs_sj_frq [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dqs_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQSN_1,direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dqsn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dqsn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DM_1,  direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dm_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1],dm_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQS_1 ,direction,dqs_dcd    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQSN_1,direction,dqsn_dcd   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DM_1,  direction,dm_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQS_1 ,direction,dqs_isi    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQSN_1,direction,dqsn_isi   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DM_1,  direction,dm_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+1]);            
          end   
          if (`SDRAM_DATA_WIDTH == 32) begin
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_16, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_17, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_18, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_19, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_20, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_21, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_22, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_23, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_24, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_25, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_26, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_27, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_28, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_29, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_30, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQ_31, direction,dq_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_16, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_17, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_18, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_19, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_20, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_21, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_22, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_23, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_24, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_25, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_26, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_27, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_28, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_29, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_30, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQ_31, direction,dq_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dq_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_16, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_17, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_18, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_19, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_20, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_21, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_22, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_23, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_24, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_25, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_26, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_27, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_28, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_29, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_30, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQ_31, direction,dq_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_16, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_17, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_18, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_19, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_20, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_21, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_22, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_23, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_24, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_25, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_26, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_27, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);      
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_28, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_29, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_30, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQ_31, direction,dq_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);

            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQS_2 ,direction,dqs_rj_cap [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dqs_rj_sig [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQSN_2,direction,dqsn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dqsn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DM_2,  direction,dm_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dm_rj_sig  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQS_2 ,direction,dqs_sj_amp [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dqs_sj_frq [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dqs_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQSN_2,direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dqsn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dqsn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DM_2,  direction,dm_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dm_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2],dm_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQS_2 ,direction,dqs_dcd    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQSN_2,direction,dqsn_dcd   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DM_2,  direction,dm_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQS_2 ,direction,dqs_isi    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQSN_2,direction,dqsn_isi   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DM_2,  direction,dm_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+2]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQS_3 ,direction,dqs_rj_cap [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dqs_rj_sig [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DQSN_3,direction,dqsn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dqsn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_rj_delay (`DM_3,  direction,dm_rj_cap  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dm_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQS_3 ,direction,dqs_sj_amp [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dqs_sj_frq [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dqs_sj_phs [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DQSN_3,direction,dqsn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dqsn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dqsn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_sj_delay (`DM_3,  direction,dm_sj_amp  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dm_sj_frq  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3],dm_sj_phs  [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQS_3 ,direction,dqs_dcd    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DQSN_3,direction,dqsn_dcd   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_dcd_delay(`DM_3,  direction,dm_dcd     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);            
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQS_3 ,direction,dqs_isi    [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DQSN_3,direction,dqsn_isi   [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);
            `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_dx_signal_isi_delay(`DM_3,  direction,dm_isi     [(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip*(`SDRAM_DATA_WIDTH/8)+3]);            
          end
        end
        for (addr_no = 0; addr_no < pADDR_WIDTH; addr_no = addr_no + 1) begin
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay (`ADDR_0  + addr_no,addr_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  ,addr_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay (`ADDR_0  + addr_no,addr_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  ,addr_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  ,addr_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay(`ADDR_0  + addr_no,addr_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]     );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay(`ADDR_0  + addr_no,addr_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]     );
        end   
        for (bank_no = 0; bank_no < pBANK_WIDTH; bank_no = bank_no + 1) begin
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay (`CMD_BA0 + bank_no,ba_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    ,ba_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay (`CMD_BA0 + bank_no,ba_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    ,ba_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    ,ba_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay(`CMD_BA0 + bank_no,ba_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]       );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay(`CMD_BA0 + bank_no,ba_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]       );
        end  
        for (cid = 0; cid < pCID_WIDTH; cid = cid + 1) begin
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay (`CMD_CID0 + cid,cid_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,cid_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay (`CMD_CID0 + cid,cid_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,cid_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,cid_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay(`CMD_CID0 + cid,cid_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      );
          `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay(`CMD_CID0 + cid,cid_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      );
        end            
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay   (`CMD_ACT,       actn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  ,actn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay   (`CMD_ACT,       actn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  ,actn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  ,actn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]  );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay  (`CMD_ACT,       actn_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]     );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay  (`CMD_ACT,       actn_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]     );
        
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay   (`CMD_PARIN,     parin_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip] ,parin_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip] );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay   (`CMD_PARIN,     parin_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip] ,parin_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip] ,parin_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip] );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay  (`CMD_PARIN,     parin_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    );        
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay  (`CMD_PARIN,     parin_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]    );        
                  
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay   (`CMD_ALERTN,    alertn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip],alertn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay   (`CMD_ALERTN,    alertn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip],alertn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip],alertn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]);
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay  (`CMD_ALERTN,    alertn_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ); 
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay  (`CMD_ALERTN,    alertn_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ); 
           
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay   (`CMD_ODT,       odt_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,odt_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay   (`CMD_ODT,       odt_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,odt_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,odt_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay  (`CMD_ODT,       odt_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      ); 
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay  (`CMD_ODT,       odt_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      ); 

        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay   (`CMD_CKE,       cke_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,cke_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay   (`CMD_CKE,       cke_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,cke_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,cke_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay  (`CMD_CKE,       cke_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      ); 
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay  (`CMD_CKE,       cke_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      ); 

        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_rj_delay   (`CMD_CSN,       csn_rj_cap[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,csn_rj_sig[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_sj_delay   (`CMD_CSN,       csn_sj_amp[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,csn_sj_frq[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   ,csn_sj_phs[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]   );
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_dcd_delay  (`CMD_CSN,       csn_dcd[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      );                            
        `RAM_PROBE(dwc_dim,dwc_rnk,dwc_chip).board_delay_model.set_ac_signal_isi_delay  (`CMD_CSN,       csn_isi[(dwc_dim*`DWC_RANKS_PER_DIMM)+dwc_rnk][(SHARED_AC*(dwc_dim%2)*`DWC_NO_OF_BYTES/(2*`SDRAM_DATA_WIDTH/8)) + dwc_chip]      );                                  
      end  
    end     //dwc_chip
  end    //dwc_dim2
end    //dwc_dim
endgenerate


task reset_all_delays;

begin
  for(k=0; k < pRANK_WIDTH; k = k+1) begin
    for(j=0; j<pNO_OF_CHIPS; j = j+1) begin
      ck_delay[k][j]  = 0;
      ckn_delay[k][j] = 0;

      for(i=0; i<pADDR_WIDTH; i = i+1)
        addr_delay[k][j][i] = 0;      

      for(i=0; i<pBANK_WIDTH; i = i+1)
        ba_delay[k][j][i] = 0;  

      for(i=0; i<pCID_WIDTH; i = i+1)
        cid_delay[k][j][i] = 0;                     

      csn_delay[k][j]    = 0;
      cke_delay[k][j]    = 0; 
      odt_delay[k][j]    = 0;
      actn_delay[k][j]   = 0;   
      parin_delay[k][j]  = 0;
      alertn_delay[k][j] = 0;
              
      for(i=0; i<pNO_OF_DQS_PER_SDRAM; i = i+1)
        for(direction=0;direction<2;direction=direction+1) begin     
          dqs_delay[direction][k][j][i]   = 0;
          dqsn_delay[direction][k][j][i]  = 0;
          dm_delay[direction][k][j][i]    = 0;    
        end
      for(i=0; i<pDRAM_IO_WIDTH; i = i+1)
        for(direction=0;direction<2;direction=direction+1)      
          dq_delay[direction][k][j][i]  = 0;
    end
  end
  for(direction=0;direction<2;direction=direction+1) begin 
    for(i=0; i<pCK_WIDTH; i = i+1) begin
      ck_io_delay[direction][i]  = 0;
      ckn_io_delay[direction][i] = 0; 
    end 

    for(i=0; i<pADDR_WIDTH; i = i+1)
      addr_io_delay[direction][i]   = 0; 

    for(i=0; i<pBANK_WIDTH; i = i+1)
      ba_io_delay[direction][i]     = 0;  

    for(i=0; i<pCID_WIDTH; i = i+1)
      cid_io_delay[direction][i]    = 0;
    
    for(i=0; i<pNO_OF_CSNS; i = i+1)
      csn_io_delay[direction][i]    = 0;
    
    for(i=0; i<pNO_OF_CKES; i = i+1)  
      cke_io_delay[direction][i]    = 0; 
    
    for(i=0; i<pNO_OF_ODTS; i = i+1)  
      odt_io_delay[direction][i]    = 0;
      
    actn_io_delay[direction]      = 0; 
    parin_io_delay[direction]     = 0;
    alertn_io_delay[direction]    = 0; 
  end
  
  for(j=0; j<pNO_OF_BYTES; j = j+1) begin  
    for(i=0; i<pNO_OF_DQS_DM_DATX; i = i+1)
      for(direction=0;direction<2;direction=direction+1) begin     
        dqs_io_delay[direction][j][i]      = 0;
        dqs_pdr_io_delay[direction][j][i]  = 0;    
        dqs_pdd_io_delay[direction][j][i]  = 0;
        dqs_te_io_delay[direction][j][i]   = 0;                          
        dqsn_io_delay[direction][j][i]     = 0;
        dqsn_pdr_io_delay[direction][j][i] = 0;    
        dqsn_pdd_io_delay[direction][j][i] = 0;
        dqsn_te_io_delay[direction][j][i]  = 0; 
        dqsg_io_delay[direction][j][i]     = 0;
        dqsg_pdr_io_delay[direction][j][i] = 0;    
        dqsg_pdd_io_delay[direction][j][i] = 0;
        dqsg_te_io_delay[direction][j][i]  = 0;                   
        dm_io_delay[direction][j][i]       = 0;
        dm_pdr_io_delay[direction][j][i]   = 0;    
        dm_pdd_io_delay[direction][j][i]   = 0;
        dm_te_io_delay[direction][j][i]    = 0;    
      end

    for(i=0; i<8; i = i+1)
      for(direction=0;direction<2;direction=direction+1) begin      
        dq_io_delay[direction][j][i]     = 0; 
        dq_pdr_io_delay[direction][j][i] = 0;    
        dq_pdd_io_delay[direction][j][i] = 0;
        dq_te_io_delay[direction][j][i]  = 0;       
      end
  end  
end

endtask


task   reset_all_jitter  ;

begin
  for(k=0; k < pRANK_WIDTH; k = k+1) begin
    for(j=0; j<pNO_OF_CHIPS; j = j+1) begin
      addr_rj_cap   [k][j] = 0;
      addr_rj_sig   [k][j] = 0;
      addr_sj_amp   [k][j] = 0;
      addr_sj_frq   [k][j] = 1;
      addr_sj_phs   [k][j] = 0;
      addr_dcd      [k][j] = 0;
      addr_isi      [k][j] = 0;

      ba_rj_cap     [k][j] = 0;
      ba_rj_sig     [k][j] = 0;
      ba_sj_amp     [k][j] = 0;
      ba_sj_frq     [k][j] = 1;
      ba_sj_phs     [k][j] = 0;
      ba_dcd        [k][j] = 0;
      ba_isi        [k][j] = 0;

      csn_rj_cap    [k][j] = 0;
      csn_rj_sig    [k][j] = 0;
      csn_sj_amp    [k][j] = 0;
      csn_sj_frq    [k][j] = 1;
      csn_sj_phs    [k][j] = 0;
      csn_dcd       [k][j] = 0;
      csn_isi       [k][j] = 0;

      cid_rj_cap    [k][j] = 0;
      cid_rj_sig    [k][j] = 0;
      cid_sj_amp    [k][j] = 0;
      cid_sj_frq    [k][j] = 1;
      cid_sj_phs    [k][j] = 0;
      cid_dcd       [k][j] = 0;
      cid_isi       [k][j] = 0;

      cke_rj_cap    [k][j] = 0;
      cke_rj_sig    [k][j] = 0;
      cke_sj_amp    [k][j] = 0;
      cke_sj_frq    [k][j] = 1;
      cke_sj_phs    [k][j] = 0;
      cke_dcd       [k][j] = 0;
      cke_isi       [k][j] = 0; 

      odt_rj_cap    [k][j] = 0;
      odt_rj_sig    [k][j] = 0;
      odt_sj_amp    [k][j] = 0;
      odt_sj_frq    [k][j] = 1;
      odt_sj_phs    [k][j] = 0;
      odt_dcd       [k][j] = 0;
      odt_isi       [k][j] = 0;

      actn_rj_cap   [k][j] = 0;
      actn_rj_sig   [k][j] = 0;
      actn_sj_amp   [k][j] = 0;
      actn_sj_frq   [k][j] = 1;
      actn_sj_phs   [k][j] = 0;
      actn_dcd      [k][j] = 0;
      actn_isi      [k][j] = 0;  

      parin_rj_cap  [k][j] = 0;
      parin_rj_sig  [k][j] = 0;
      parin_sj_amp  [k][j] = 0;
      parin_sj_frq  [k][j] = 1;
      parin_sj_phs  [k][j] = 0;
      parin_dcd     [k][j] = 0;
      parin_isi     [k][j] = 0;  

      alertn_rj_cap [k][j] = 0;
      alertn_rj_sig [k][j] = 0;
      alertn_sj_amp [k][j] = 0;
      alertn_sj_frq [k][j] = 1;
      alertn_sj_phs [k][j] = 0;
      alertn_dcd    [k][j] = 0;
      alertn_isi    [k][j] = 0;  

      dqs_rj_cap    [k][j] = 0;
      dqs_rj_sig    [k][j] = 0;
      dqs_sj_amp    [k][j] = 0;
      dqs_sj_frq    [k][j] = 1;
      dqs_sj_phs    [k][j] = 0;
      dqs_dcd       [k][j] = 0;
      dqs_isi       [k][j] = 0;
      
      dqsn_rj_cap   [k][j] = 0;
      dqsn_rj_sig   [k][j] = 0;
      dqsn_sj_amp   [k][j] = 0;
      dqsn_sj_frq   [k][j] = 1;
      dqsn_sj_phs   [k][j] = 0;
      dqsn_isi      [k][j] = 0;
      
      dm_rj_cap     [k][j] = 0;
      dm_rj_sig     [k][j] = 0;
      dm_sj_amp     [k][j] = 0;
      dm_sj_frq     [k][j] = 1;
      dm_sj_phs     [k][j] = 0;
      dm_dcd        [k][j] = 0;
      dm_isi        [k][j] = 0;
      
      dq_rj_cap     [k][j] = 0;
      dq_rj_sig     [k][j] = 0;
      dq_sj_amp     [k][j] = 0;
      dq_sj_frq     [k][j] = 1;
      dq_sj_phs     [k][j] = 0;
      dq_dcd        [k][j] = 0;
      dq_isi        [k][j] = 0;    
    end
  end
end

endtask

endmodule

