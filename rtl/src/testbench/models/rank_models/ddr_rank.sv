/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR SDRAM Rank                                                *
 *              DDR SDRAM rank composed of multiple x4, x8 or x16 SDRAMs      *
 *                                                                            *
 *****************************************************************************/
`timescale 1ns / 1ps

module ddr_rank
  #(
    // configurable design parameters
    parameter pRANK_NO         = 0,  // SDRAM rank number
    parameter pNO_OF_BYTES     = 4,  // SDRAM number of bytes
    parameter pCID_WIDTH       = `DWC_CID_WIDTH,  // SDRAM chip ID width
    parameter pBANK_WIDTH      = 3,  // SDRAM bank address width
    parameter pBG_WIDTH        = 2,  // SDRAM bank address width (DDR4)
    parameter pADDR_WIDTH      = 16, // SDRAM address width	
    parameter pDRAM_BANK_WIDTH = 3,  // SDRAM chip bank address width
    parameter pDRAM_ADDR_WIDTH = 16, // SDRAM chip address width
    parameter pDRAM_IO_WIDTH   = 8,  // SDRAM chip I/O width
    parameter pUDIMM_MIRROR    = 0,  // Unbuffered DIMM address mirroring
    parameter pRDIMM           = 0,  // RDIMM chip present
    
    // data width and number of chips; partial bytes are bytes less than the
    // bytes supported in each SDRAM module
    parameter pDATA_WIDTH      = (pNO_OF_BYTES*8),
`ifdef SDRAMx4
    parameter pPARTIAL_BYTES   = 0, // ***TBD-X4X2: compute correctly this parameter
    parameter pUNUSED_BYTES    = 0, // ***TBD-X4X2: compute correctly this parameter
    parameter pNO_OF_CHIPS     = (pPARTIAL_BYTES == 0) ? 
                                 (pNO_OF_BYTES*2) :
                                 (pNO_OF_BYTES*2),
`else
    parameter pBYTES_PER_DRAM  = (pDRAM_IO_WIDTH/8),
    parameter pPARTIAL_BYTES   = (pNO_OF_BYTES%pBYTES_PER_DRAM),
    parameter pUNUSED_BYTES    = (pPARTIAL_BYTES) ? 
                                 (pBYTES_PER_DRAM-pPARTIAL_BYTES) : 1,
    parameter pNO_OF_CHIPS     = (pPARTIAL_BYTES == 0) ? 
                                 (pDATA_WIDTH/pDRAM_IO_WIDTH) :
                                 (pDATA_WIDTH/pDRAM_IO_WIDTH + 1),
`endif

    parameter pNO_OF_DX_DQS    = `DWC_DX_NO_OF_DQS, // number of DQS signals per DX macro

    // x4 SDRAM have separate DQS/DM per 4 bits
    parameter pDRAM_DS_WIDTH   = (pDRAM_IO_WIDTH == 4) ? 1 : (pDRAM_IO_WIDTH/8),

    parameter pRDIMM_RB_OFFSET = (pRDIMM == 1) ? 1 : 0 ,
    parameter pDIMM_NO = 0 
   )
   (
    input                                     rst_n,   // SDRAM reset
    input                                     ck,      // SDRAM clock
    input                                     ck_n,    // SDRAM clock #
    input  [pRDIMM                        :0] cke,     // SDRAM clock enable
    input  [pRDIMM                        :0] odt,     // SDRAM on-die termination
    input  [pRDIMM                        :0] cs_n,    // SDRAM chip select
`ifndef DDR4
    input  [pRDIMM                        :0] ras_n,   // SDRAM row address select
    input  [pRDIMM                        :0] cas_n,   // SDRAM column address select
    input  [pRDIMM                        :0] we_n,    // SDRAM write enable
`else
    input  [pRDIMM                        :0] act_n,   // SDRAM activate
    input  [(pBG_WIDTH*(pRDIMM+1))      -1:0] bg,      // SDRAM bank group
    input  [(pCID_WIDTH*(pRDIMM+1))     -1:0] c,       // SDRAM chip ID
`endif
    input  [pRDIMM                        :0] parity,  // SDRAM Parity In
    output                                    alert_n, // SDRAM Parity Error    
    input  [(pBANK_WIDTH*(pRDIMM+1))    -1:0] ba,      // SDRAM bank address
`ifdef LPDDRX
  `ifndef LPDDR4
    input  [pADDR_WIDTH+`DWC_ADDR_COPY*6-1:0] a,       // SDRAM address (LPDDRX address copy)  
  `else
    input  [pADDR_WIDTH+`DWC_ADDR_COPY*6-1:0] a,
  //  input  [(pADDR_WIDTH*(pRDIMM+1))    -1:0] a,       // SDRAM address (LPDDR4 address copy)  
  `endif  
`else
    input  [(pADDR_WIDTH*(pRDIMM+1))    -1:0] a,       // SDRAM address
`endif
    input  [pNO_OF_BYTES*pNO_OF_DX_DQS  -1:0] dm,      // SDRAM output data mask
    inout  [pNO_OF_BYTES*pNO_OF_DX_DQS  -1:0] dqs,     // SDRAM input/output data strobe
    inout  [pNO_OF_BYTES*pNO_OF_DX_DQS  -1:0] dqs_n,   // SDRAM input/output data strobe #
`ifdef LPDDR4MPHY
    input                                     address_copy,
`endif
    inout  [pDATA_WIDTH                 -1:0] dq       // SDRAM input/output data
`ifdef LRDIMM_MULTI_RANK
    ,
    input                                     mwd_train // indicates if the dimm is in MWD training.
  
`endif  

`ifdef VMM_VERIF
  `ifndef DDR4
    ,
    input  [3:0] speed_grade
  `endif
`endif
   );

   typedef enum bit[4:0] 
       {DQBIT0  = 0,  DQBIT1  = 1,  DQBIT2  = 2,  DQBIT3  = 3,  DQBIT4  = 4,
			  DQBIT5  = 5,  DQBIT6  = 6,  DQBIT7  = 7,  DQBIT8  = 8,  DQBIT9  = 9,
			  DQBIT10 = 10, DQBIT11 = 11, DQBIT12 = 12, DQBIT13 = 13, DQBIT14 = 14,
			  DQBIT15 = 15, DQBIT16 = 16, DQBIT17 = 17, DQBIT18 = 18, DQBIT19 = 19,
			  DQBIT20 = 20, DQBIT21 = 21, DQBIT22 = 22, DQBIT23 = 23, DQBIT24 = 24,
			  DQBIT25 = 25, DQBIT26 = 26, DQBIT27 = 27, DQBIT28 = 28, DQBIT29 = 29,
			  DQBIT30 = 30, DQBIT31 = 31} dq_bits_e;
   
`ifdef VMM_VERIF
    vmm_log log = new("ddr_rank", "ddr_rank");
`endif

   
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire [pDRAM_ADDR_WIDTH*pNO_OF_CHIPS-1:0] lpa;

  reg  [pNO_OF_CHIPS-1:0] chip_dis; // chip disconnection
  reg  [pNO_OF_CHIPS-1:0] chip_dis_mask; // mask to let cke to go thru even when chip_dis is asserted
  
  reg  [31:0]             dram_chip_no;
  reg  [2:0]              dram_dly_type;
  reg  [31:0]             dram_dly_ps;
  reg                     dram_clock_check;
  reg                     dram_reset_check;
  reg                     dram_dq_setup_hold_check;
  reg                     dram_dq_pulse_width_check;
  reg                     dram_dqs_ck_setup_hold_check;
  reg                     dram_cmd_addr_timing_check;
  reg                     dram_ctrl_addr_pulse_width_check;
  reg                     dram_odth_timing_check;
  reg                     dram_dqs_latch_timing_check;
  reg                     dram_rfsh_check;
  reg                     dram_tpdmax_check;
  reg                     dram_all_bits;
  reg  [31:0]             dram_bit_no;
  reg  [7:0]              dram_mpr_bytemask;
  reg  [31:0]             dram_dq_force;
  reg                     dram_ca_valid_window_check;
  reg                     dram_write_2_dqs_t_check;
  reg                     dram_ca_in_check;
    reg                   dram_tsrx_check;
  wire [31:0]             dummy_reg;
  wire [31:0]             dummy_reg_dm;
  wire [31:0]             dummy_reg_dqs;

  event                   e_set_board_delay;
  event                   e_set_wl_feedback_bits;
  event                   e_set_clock_checks;
  event                   e_set_reset_checks;
  event                   e_set_dq_setup_hold_checks;
  event                   e_set_dq_train_err;
  event                   e_set_dqs_train_err;
  event                   e_set_dq_pulse_width_checks;
  event                   e_set_dqs_ck_setup_hold_checks;
  event                   e_set_cmd_addr_timing_checks;
  event                   e_set_ctrl_addr_pulse_width_checks;
  event                   e_set_refresh_check;
  event                   e_set_odth_timing_checks;
  event                   e_set_dqs_latch_timing_checks;
  event                   e_set_mpr_bytemask;
  event                   e_set_tpdmax_checks;
  event                   e_get_tdqs2dq;
  event                   e_get_tdqsck_lpddr3;
  event                   e_get_tdqsck_lpddr4;
  event                   e_set_tdqsck;
  event                   e_set_ca_valid_window_check;
  event                   e_set_write_2_dqs_t_check;
  event                   e_set_ca_in_check;
  event                   e_set_tsrx_check;

  real                    tdqs2dq_ch_A [1:0];
  real                    tdqs2dq_ch_B [1:0];
  real                    tdqsck_lpddr3[8:0];
  int                     tdqsck_ch_A[1:0];
  int                     tdqsck_ch_B[1:0];

  // DDR4 only
  reg  [31:0]             dram_ck_check;
  event                   e_set_ck_checks;

  wire [pNO_OF_CHIPS-1:0] ddr4rA_cs_n_chip_dis;   // internal chip selects for chips 15 down to 0
  wire [pNO_OF_CHIPS-1:0] ddr4rB_cs_n_chip_dis;   // B output from RDIMM 
  reg  [pNO_OF_CHIPS-1:0] ddr4rA_cs_n_chip_dis_r; // internal chip selects for chips 15 down to 0
  reg  [pNO_OF_CHIPS-1:0] ddr4rB_cs_n_chip_dis_r; // B output from RDIMM 
                         
  wire [pNO_OF_CHIPS-1:0] ddr4rA_odt_chip_dis;    // internal ODT enables for chips 15 down to 0
  wire [pNO_OF_CHIPS-1:0] ddr4rB_odt_chip_dis;    // B output from RDIMM 
  reg  [pNO_OF_CHIPS-1:0] ddr4rA_odt_chip_dis_r;  // internal ODT enables for chips 15 down to 0
  reg  [pNO_OF_CHIPS-1:0] ddr4rB_odt_chip_dis_r;  // B output from RDIMM 
                       
  wire [pNO_OF_CHIPS-1:0] ddr4rA_cke_chip_dis;    // internal CKE enables for chips 15 down to 0
  wire [pNO_OF_CHIPS-1:0] ddr4rB_cke_chip_dis;    // B output from RDIMM 
  reg  [pNO_OF_CHIPS-1:0] ddr4rA_cke_chip_dis_r;  // internal CKE enables for chips 15 down to 0
  reg  [pNO_OF_CHIPS-1:0] ddr4rB_cke_chip_dis_r;  // B output from RDIMM

  wire [pDRAM_ADDR_WIDTH*pNO_OF_CHIPS-1:0] lpa_chip_dis;
  reg  [pDRAM_ADDR_WIDTH*pNO_OF_CHIPS-1:0] lpa_chip_dis_r;

  wire [pNO_OF_CHIPS-1:0] alert_n_r;
  `ifdef DDR4
    assign alert_n = (&alert_n_r);
  `else
    pullup (weak1) u0 (alert_n);
  `endif

  integer chip_no;
  always @(*) begin
    for (chip_no=0; chip_no<pNO_OF_CHIPS; chip_no=chip_no+1) begin

      if (pRDIMM) begin
        // RDIMM

        if (chip_dis[chip_no] == 1'b1) begin
          // For disabled chips, disable the input ports
          ddr4rA_cs_n_chip_dis_r[chip_no] = 1'b1;
          ddr4rA_odt_chip_dis_r [chip_no] = 1'b0;
          ddr4rA_cke_chip_dis_r [chip_no] = 1'b0;

          ddr4rB_cs_n_chip_dis_r[chip_no] = 1'b1;
          ddr4rB_odt_chip_dis_r [chip_no] = 1'b0;
          ddr4rB_cke_chip_dis_r [chip_no] = 1'b0;
        end
        else begin
          // For chips enabled, connect input ports
          ddr4rA_cs_n_chip_dis_r[chip_no] = cs_n[0];
          ddr4rA_odt_chip_dis_r [chip_no] = odt [0];
          ddr4rA_cke_chip_dis_r [chip_no] = cke [0];

          // Have to use a parameter for the offset to avoid compilation warnings if
          // not running in RDIMM, then there will be no cs_n[1]/odt[1]/cke[1].
          ddr4rB_cs_n_chip_dis_r[chip_no] = cs_n[pRDIMM_RB_OFFSET];
          ddr4rB_odt_chip_dis_r [chip_no] = odt [pRDIMM_RB_OFFSET];
          ddr4rB_cke_chip_dis_r [chip_no] = cke [pRDIMM_RB_OFFSET];
        end
      end
      else begin
        // Non-RDIMM

        if (chip_dis[chip_no] == 1'b1) begin
          // For disabled chips, disable the input ports
          ddr4rA_cs_n_chip_dis_r[chip_no] = 1'b1;
          ddr4rA_odt_chip_dis_r [chip_no] = 1'b0;
          ddr4rA_cke_chip_dis_r [chip_no] = 1'b0;
          lpa_chip_dis_r = 0;
        end
        else begin
          // For chips enabled, connect input ports
          ddr4rA_cs_n_chip_dis_r[chip_no] = cs_n[0];
          ddr4rA_odt_chip_dis_r [chip_no] = odt [0];
          ddr4rA_cke_chip_dis_r [chip_no] = cke [0];
          lpa_chip_dis_r = lpa;
        end

        // For non-RDIMM, set the *rB pins to 0
        ddr4rB_cs_n_chip_dis_r[chip_no] = 1'b0;
        ddr4rB_odt_chip_dis_r [chip_no] = 1'b0;
        ddr4rB_cke_chip_dis_r [chip_no] = 1'b0;
      end
    end
  end

  // Assign the registered values to the wires to connect to sub modules
  assign ddr4rA_cs_n_chip_dis = ddr4rA_cs_n_chip_dis_r;
  assign ddr4rB_cs_n_chip_dis = ddr4rB_cs_n_chip_dis_r;

  assign ddr4rA_odt_chip_dis  = ddr4rA_odt_chip_dis_r;
  assign ddr4rB_odt_chip_dis  = ddr4rB_odt_chip_dis_r;

  assign ddr4rA_cke_chip_dis  = ddr4rA_cke_chip_dis_r;
  assign ddr4rB_cke_chip_dis  = ddr4rB_cke_chip_dis_r;

  assign lpa_chip_dis = lpa_chip_dis_r;


  //---------------------------------------------------------------------------
  // SDRAM Rank
  //---------------------------------------------------------------------------
  // SDRAM rank using 32-bit, 16-bit, 8-bit or 4-bit SDRAM chips
  generate 
    genvar dwc_dram;
    for (dwc_dram=0; dwc_dram<pNO_OF_CHIPS; dwc_dram=dwc_dram+1) begin:dwc_sdram
      if (pDRAM_IO_WIDTH == 4) begin: xn_dram
        // x4: one controller DQS connects to 2 chips
        ddr_sdram 
	       #(
           .pCHIP_NO    ( dwc_dram                                                            ), 
           .pRANK_NO    ( pRANK_NO                                                            ),
           .pDIMM_NO    ( pDIMM_NO                                                            )
          )
	      u_sdram
          (
           .rst_n       ( rst_n                                                               ),
           .ck          ( ck                                                                  ),
           .ck_n        ( ck_n                                                                ),
           .cke         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cke_chip_dis [dwc_dram])
                                                           : (ddr4rB_cke_chip_dis [dwc_dram]) ),
           .odt         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_odt_chip_dis [dwc_dram])
                                                           : (ddr4rB_odt_chip_dis [dwc_dram]) ), 
           .cs_n        ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cs_n_chip_dis[dwc_dram])
                                                           : (ddr4rB_cs_n_chip_dis[dwc_dram]) ),
`ifdef DDR4
           .act_n       ( act_n  [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .parity      ( parity [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
           .c           ( c    [(pRDIMM*(dwc_dram%2)*pCID_WIDTH)  +: pCID_WIDTH]              ),
           .ba          ( ba   [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]             ),
           .bg          ( bg   [(pRDIMM*(dwc_dram%2)*pBG_WIDTH)   +: pBG_WIDTH]               ),
`else
           .ras_n       ( ras_n[((pRDIMM == 1) ? dwc_dram%2 : 0)]                             ),
           .cas_n       ( cas_n[((pRDIMM == 1) ? dwc_dram%2 : 0)]                             ),
           .we_n        ( we_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                             ),
           .ba          ( ba   [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]             ),
`endif
`ifdef DDR3
 `ifdef  DWC_AC_ALERTN_USE 
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
 `endif
`endif
           .a           ( a    [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]   ),
           .dm          ( dm   [dwc_dram]                                                     ),
           .dqs         ( dqs  [dwc_dram]                                                     ),
           .dqs_n       ( dqs_n[dwc_dram]                                                     ),
           .dq          ( {dq  [dwc_dram*pDRAM_IO_WIDTH+DQBIT3],
                           dq  [dwc_dram*pDRAM_IO_WIDTH+DQBIT2],
                           dq  [dwc_dram*pDRAM_IO_WIDTH+DQBIT1],
                           dq  [dwc_dram*pDRAM_IO_WIDTH+DQBIT0]}                              )
`ifdef VMM_VERIF
 `ifndef DDR4
           ,
           .speed_grade ( speed_grade )
 `endif
`endif
`ifdef LPDDR4MPHY
 `ifdef LPDDR4
	          ,
	          .address_copy ( address_copy )
 `endif
`endif
`ifdef LRDIMM_MULTI_RANK   
           ,
           .mwd_train   (mwd_train)
`endif           
          );
      end else if (dwc_dram == (pNO_OF_CHIPS-1) && (pPARTIAL_BYTES==3)) begin: xn_dram
        // x32 only
        ddr_sdram 
	       #(
           .pCHIP_NO    ( dwc_dram                                                            ),
           .pRANK_NO    ( pRANK_NO                                                            ),
           .pDIMM_NO    ( pDIMM_NO                                                            )

          )
        u_sdram
          (
           .rst_n       ( rst_n                                                               ),
           .ck          ( ck                                                                  ),
           .ck_n        ( ck_n                                                                ),
           .cke         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cke_chip_dis [dwc_dram])
                                                           : (ddr4rB_cke_chip_dis [dwc_dram]) ),
           .odt         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_odt_chip_dis [dwc_dram])
                                                           : (ddr4rB_odt_chip_dis [dwc_dram]) ), 
           .cs_n        ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cs_n_chip_dis[dwc_dram])
                                                           : (ddr4rB_cs_n_chip_dis[dwc_dram]) ),
`ifdef DDR4
           .act_n       ( act_n  [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .parity      ( parity [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
           .c           ( c     [(pRDIMM*(dwc_dram%2)*pCID_WIDTH)  +: pCID_WIDTH]             ),
           .ba          ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
           .bg          ( bg    [(pRDIMM*(dwc_dram%2)*pBG_WIDTH)   +: pBG_WIDTH]              ),
`else
           .ras_n        ( ras_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .cas_n        ( cas_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .we_n         ( we_n  [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .ba           ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
`endif

`ifdef DDR3
 `ifdef  DWC_AC_ALERTN_USE 
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
 `endif
`endif

`ifdef LPDDR4MPHY
 `ifdef LPDDRX
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `elsif LPDDR4
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif
`else
  `ifdef LPDDRX
           .a           ( lpa   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
  `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
  `endif
`endif

`ifdef LPDDR4
           .dmi         ( {dummy_reg_dm   [pUNUSED_BYTES  -1:0], dm   [(dwc_dram*pDRAM_DS_WIDTH) +: pPARTIAL_BYTES]} ),
`else
           .dm          ( {dummy_reg_dm   [pUNUSED_BYTES  -1:0], dm   [(dwc_dram*pDRAM_DS_WIDTH) +: pPARTIAL_BYTES]} ),
`endif

`ifdef SDRAMx32
 `ifdef LPDDR4MPHY
           .dqs         ( {dqs  [(4*dwc_dram+2)*pNO_OF_DX_DQS], dqs  [(4*dwc_dram+2)*pNO_OF_DX_DQS],   
                                                                dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                                dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
           .dqs_n       ( {dqs_n[(4*dwc_dram+2)*pNO_OF_DX_DQS], dqs_n[(4*dwc_dram+2)*pNO_OF_DX_DQS],   
                                                                dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                                dqs_n[(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
 `else
           .dqs         ( {dummy_reg_dqs  [0:0], dqs  [(4*dwc_dram+2)*pNO_OF_DX_DQS],   
                                                 dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                 dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
           .dqs_n       ( {dummy_reg_dqs  [0:0], dqs_n[(4*dwc_dram+2)*pNO_OF_DX_DQS],   
                                                 dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                 dqs_n[(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
 `endif 
`endif
           .dq          ( {dummy_reg[pUNUSED_BYTES*8-1:0], dq[(dwc_dram*pDRAM_IO_WIDTH) +: pPARTIAL_BYTES*8]} )

`ifdef VMM_VERIF
 `ifndef DDR4
           ,
           .speed_grade ( speed_grade )
 `endif
`endif
`ifdef LPDDR4MPHY
 `ifdef LPDDR4
	          ,
	          .address_copy ( address_copy )
 `endif
`endif

`ifdef LRDIMM_MULTI_RANK   
           ,
           .mwd_train   (mwd_train)
`endif 
          );
      end else if (dwc_dram == (pNO_OF_CHIPS-1) && (pPARTIAL_BYTES==2)) begin: xn_dram
        // x32 only
        ddr_sdram 
	       #(
           .pCHIP_NO    ( dwc_dram                                                            ),
           .pRANK_NO    ( pRANK_NO                                                            ),
           .pDIMM_NO    ( pDIMM_NO                                                            )

          )
        u_sdram
          (
           .rst_n       ( rst_n                                                               ),
           .ck          ( ck                                                                  ),
           .ck_n        ( ck_n                                                                ),
           .cke         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cke_chip_dis [dwc_dram])
                                                           : (ddr4rB_cke_chip_dis [dwc_dram]) ),
           .odt         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_odt_chip_dis [dwc_dram])
                                                           : (ddr4rB_odt_chip_dis [dwc_dram]) ), 
           .cs_n        ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cs_n_chip_dis[dwc_dram])
                                                           : (ddr4rB_cs_n_chip_dis[dwc_dram]) ),
`ifdef DDR4
           .act_n       ( act_n  [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .parity      ( parity [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
           .c           ( c     [(pRDIMM*(dwc_dram%2)*pCID_WIDTH)  +: pCID_WIDTH]             ),
           .ba          ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
           .bg          ( bg    [(pRDIMM*(dwc_dram%2)*pBG_WIDTH)   +: pBG_WIDTH]              ),
`else
           .ras_n        ( ras_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .cas_n        ( cas_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .we_n         ( we_n  [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
	          .ba           ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
`endif

`ifdef DDR3
 `ifdef  DWC_AC_ALERTN_USE 
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
 `endif
`endif

`ifdef LPDDR4MPHY
 `ifdef LPDDRX
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `elsif LPDDR4
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif
`else
 `ifdef LPDDRX
           .a           ( lpa   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif
`endif

`ifdef LPDDR4
           .dmi         ( {dummy_reg_dm   [pUNUSED_BYTES  -1:0], dm   [(dwc_dram*pDRAM_DS_WIDTH) +: pPARTIAL_BYTES]} ),
`else
           .dm          ( {dummy_reg_dm   [pUNUSED_BYTES  -1:0], dm   [(dwc_dram*pDRAM_DS_WIDTH) +: pPARTIAL_BYTES]} ),
`endif

`ifdef SDRAMx32
 `ifdef LPDDR4MPHY
           .dqs         ( {dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS], 
                           dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS], 
                                                                dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                                dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
           .dqs_n       ( {dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],
                           dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],
                                                                dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                                dqs_n[(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
 `else
           .dqs         ( {dummy_reg_dqs  [1:0], dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                 dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
           .dqs_n       ( {dummy_reg_dqs  [1:0], dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],   
                                                 dqs_n[(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
 `endif
`endif
           .dq          ( {dummy_reg[pUNUSED_BYTES*8-1:0], dq[(dwc_dram*pDRAM_IO_WIDTH) +: pPARTIAL_BYTES*8]} )

`ifdef VMM_VERIF
 `ifndef DDR4
           ,
           .speed_grade ( speed_grade )
 `endif
`endif
`ifdef LPDDR4MPHY
 `ifdef LPDDR4
           ,
           .address_copy ( address_copy )
 `endif
`endif
`ifdef LRDIMM_MULTI_RANK   
           ,
           .mwd_train   (mwd_train)
`endif 
          );
      end else if (dwc_dram == (pNO_OF_CHIPS-1) && (pPARTIAL_BYTES==1)) begin: xn_dram
        // x16, x32 only
        ddr_sdram 
	       #(
           .pCHIP_NO    ( dwc_dram                                                            ),
           .pRANK_NO    ( pRANK_NO                                                            ),
           .pDIMM_NO    ( pDIMM_NO                                                            )

          )
        u_sdram
          (
           .rst_n       ( rst_n                                                               ),
           .ck          ( ck                                                                  ),
           .ck_n        ( ck_n                                                                ),
           .cke         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cke_chip_dis [dwc_dram])
                                                           : (ddr4rB_cke_chip_dis [dwc_dram]) ),
           .odt         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_odt_chip_dis [dwc_dram])
                                                           : (ddr4rB_odt_chip_dis [dwc_dram]) ), 
           .cs_n        ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cs_n_chip_dis[dwc_dram])
                                                           : (ddr4rB_cs_n_chip_dis[dwc_dram]) ),
`ifdef DDR4
           .act_n       ( act_n  [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .parity      ( parity [((pRDIMM == 1) ? dwc_dram%2 : 0) ]                     ),
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
           .c           ( c     [(pRDIMM*(dwc_dram%2)*pCID_WIDTH)  +: pCID_WIDTH]             ),
           .ba          ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
           .bg          ( bg    [(pRDIMM*(dwc_dram%2)*pBG_WIDTH)   +: pBG_WIDTH]              ),
`else
           .ras_n        ( ras_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .cas_n        ( cas_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .we_n         ( we_n  [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
	          .ba           ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
`endif

`ifdef DDR3
 `ifdef  DWC_AC_ALERTN_USE 
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
 `endif
`endif

`ifdef LPDDR4MPHY
 `ifdef LPDDRX
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `elsif LPDDR4
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif
`else
 `ifdef LPDDRX
           .a           ( lpa   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
  `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif
`endif

`ifdef LPDDR4
           .dmi         ( {dummy_reg_dm   [pUNUSED_BYTES  -1:0], dm   [(dwc_dram*pDRAM_DS_WIDTH) +: pPARTIAL_BYTES]} ),
`else
           .dm          ( {dummy_reg_dm   [pUNUSED_BYTES  -1:0], dm   [(dwc_dram*pDRAM_DS_WIDTH) +: pPARTIAL_BYTES]} ),
`endif

`ifdef SDRAMx32
 `ifdef LPDDR4MPHY
           .dqs         ( {dqs [(4*dwc_dram+0)*pNO_OF_DX_DQS],
                           dqs [(4*dwc_dram+0)*pNO_OF_DX_DQS],
                           dqs [(4*dwc_dram+0)*pNO_OF_DX_DQS],   dqs   [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
           .dqs_n       ( {dqs_n [(4*dwc_dram+0)*pNO_OF_DX_DQS],
                           dqs_n [(4*dwc_dram+0)*pNO_OF_DX_DQS],
                           dqs_n [(4*dwc_dram+0)*pNO_OF_DX_DQS], dqs_n [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
 `else
           .dqs         ( {dummy_reg_dqs  [2:0], dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
           .dqs_n       ( {dummy_reg_dqs  [2:0], dqs_n[(4*dwc_dram+0)*pNO_OF_DX_DQS]}),
 `endif 
`endif
`ifdef SDRAMx16
 `ifdef LPDDR4MPHY
           .dqs         ( {dqs   [((2*dwc_dram+0)*pNO_OF_DX_DQS)],  dqs   [((2*dwc_dram+0)*pNO_OF_DX_DQS)]}),
           .dqs_n       ( {dqs_n [((2*dwc_dram+0)*pNO_OF_DX_DQS)],  dqs_n [((2*dwc_dram+0)*pNO_OF_DX_DQS)]}),
 `else 
           .dqs         ( {dummy_reg_dqs  [pUNUSED_BYTES  -1:0], dqs   [((2*dwc_dram+0)*pNO_OF_DX_DQS)]} ),
           .dqs_n       ( {dummy_reg_dqs  [pUNUSED_BYTES  -1:0], dqs_n [((2*dwc_dram+0)*pNO_OF_DX_DQS)]} ),
 `endif
`endif
           
           .dq          ( {dummy_reg[pUNUSED_BYTES*8-1:0], dq[(dwc_dram*pDRAM_IO_WIDTH) +: pPARTIAL_BYTES*8]} )

`ifdef VMM_VERIF
 `ifndef DDR4
           ,
           .speed_grade ( speed_grade )
 `endif
`endif
`ifdef LPDDR4MPHY
 `ifdef LPDDR4
           ,
           .address_copy ( address_copy )
 `endif
`endif
`ifdef LRDIMM_MULTI_RANK   
           ,
           .mwd_train   (mwd_train)
`endif 
          );
      end else begin: xn_dram
        // x8, x16, x32
        ddr_sdram
	       #(
           .pCHIP_NO    ( dwc_dram                                                            ),
           .pRANK_NO    ( pRANK_NO                                                            ),
           .pDIMM_NO    ( pDIMM_NO                                                            )
           )
	      u_sdram
            (
           .rst_n       ( rst_n                                                               ),
           .ck          ( ck                                                                  ),
           .ck_n        ( ck_n                                                                ),
           .cke         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cke_chip_dis [dwc_dram])
                                                           : (ddr4rB_cke_chip_dis [dwc_dram]) ),
           .odt         ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_odt_chip_dis [dwc_dram])
                                                           : (ddr4rB_odt_chip_dis [dwc_dram]) ), 
           .cs_n        ( (dwc_dram%2 == 0 || pRDIMM == 0) ? (ddr4rA_cs_n_chip_dis[dwc_dram])
                                                           : (ddr4rB_cs_n_chip_dis[dwc_dram]) ),
`ifdef DDR4
           .act_n       ( act_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .parity      ( parity[((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
           .c           ( c     [(pRDIMM*(dwc_dram%2)*pCID_WIDTH)  +: pCID_WIDTH]             ),
           .ba          ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]            ),
           .bg          ( bg    [(pRDIMM*(dwc_dram%2)*pBG_WIDTH)   +: pBG_WIDTH]              ),
`else
           .ras_n       ( ras_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .cas_n       ( cas_n [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .we_n        ( we_n  [((pRDIMM == 1) ? dwc_dram%2 : 0)]                            ),
           .ba          ( ba    [(pRDIMM*(dwc_dram%2)*pBANK_WIDTH) +: pBANK_WIDTH]),
`endif

`ifdef DDR3
 `ifdef DWC_AC_ALERTN_USE 
           .alert_n     ( alert_n_r[dwc_dram]                                                 ),
 `endif
`endif

`ifdef LPDDR4MPHY
 `ifdef LPDDRX
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `elsif LPDDR4
           .a           ( lpa_chip_dis   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
 `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif                  
`else
 `ifdef LPDDRX
           .a           ( lpa   [dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH]               ),
  `else
           .a           ( a     [(pRDIMM*(dwc_dram%2)*pDRAM_ADDR_WIDTH) +: pDRAM_ADDR_WIDTH]  ),
 `endif 
`endif

`ifdef SDRAMx32
 `ifdef LPDDR4
//need to update the dmi connection
  `ifdef DWC_DDRPHY_DMDQS_MUX
           .dmi          ( {dqs  [(4*dwc_dram+3)*pNO_OF_DX_DQS+1], dqs  [(4*dwc_dram+2)*pNO_OF_DX_DQS+1], dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS+1], dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS+1]} ),
  `else
           .dmi          ( {dm   [(4*dwc_dram+3)*pNO_OF_DX_DQS],   dm   [(4*dwc_dram+2)*pNO_OF_DX_DQS],   dm   [(4*dwc_dram+1)*pNO_OF_DX_DQS],   dm   [(4*dwc_dram+0)*pNO_OF_DX_DQS]} ),
  `endif
 `else
  `ifdef DWC_DDRPHY_DMDQS_MUX
           .dm          ( {dqs  [(4*dwc_dram+3)*pNO_OF_DX_DQS+1], dqs  [(4*dwc_dram+2)*pNO_OF_DX_DQS+1], dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS+1], dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS+1]} ),
  `else
           .dm          ( {dm   [(4*dwc_dram+3)*pNO_OF_DX_DQS],   dm   [(4*dwc_dram+2)*pNO_OF_DX_DQS],   dm   [(4*dwc_dram+1)*pNO_OF_DX_DQS],   dm   [(4*dwc_dram+0)*pNO_OF_DX_DQS]} ),
  `endif
 `endif
           .dqs         ( {dqs  [(4*dwc_dram+3)*pNO_OF_DX_DQS],   dqs  [(4*dwc_dram+2)*pNO_OF_DX_DQS],   dqs  [(4*dwc_dram+1)*pNO_OF_DX_DQS],   dqs  [(4*dwc_dram+0)*pNO_OF_DX_DQS]} ),
           .dqs_n       ( {dqs_n[(4*dwc_dram+3)*pNO_OF_DX_DQS],   dqs_n[(4*dwc_dram+2)*pNO_OF_DX_DQS],   dqs_n[(4*dwc_dram+1)*pNO_OF_DX_DQS],   dqs_n[(4*dwc_dram+0)*pNO_OF_DX_DQS]} ),
`endif                  
`ifdef SDRAMx16
 `ifdef LPDDR4
  `ifdef DWC_DDRPHY_DMDQS_MUX
           .dmi         ( {dqs  [(2*dwc_dram+1)*pNO_OF_DX_DQS+1], dqs [(2*dwc_dram+0)*pNO_OF_DX_DQS+1]} ),
  `else
           .dmi         ( {dm   [(2*dwc_dram+1)*pNO_OF_DX_DQS],   dm    [(2*dwc_dram+0)*pNO_OF_DX_DQS]} ),
  `endif
 `else
  `ifdef DWC_DDRPHY_DMDQS_MUX
           .dm          ( {dqs  [(2*dwc_dram+1)*pNO_OF_DX_DQS+1], dqs [(2*dwc_dram+0)*pNO_OF_DX_DQS+1]} ),
  `else
           .dm          ( {dm   [(2*dwc_dram+1)*pNO_OF_DX_DQS],   dm    [(2*dwc_dram+0)*pNO_OF_DX_DQS]} ),
  `endif
 `endif
           .dqs         ( {dqs  [(2*dwc_dram+1)*pNO_OF_DX_DQS],   dqs   [(2*dwc_dram+0)*pNO_OF_DX_DQS]} ),
           .dqs_n       ( {dqs_n[(2*dwc_dram+1)*pNO_OF_DX_DQS],   dqs_n [(2*dwc_dram+0)*pNO_OF_DX_DQS]} ),
`endif                  
`ifdef SDRAMx8
  `ifdef DWC_DDRPHY_DMDQS_MUX
           .dm          ( dqs   [(1*dwc_dram+0)*pNO_OF_DX_DQS + 1] ),
  `else
           .dm          ( dm    [(1*dwc_dram+0)*pNO_OF_DX_DQS]     ),
  `endif
           .dqs         ( dqs   [(1*dwc_dram+0)*pNO_OF_DX_DQS]     ),
           .dqs_n       ( dqs_n [(1*dwc_dram+0)*pNO_OF_DX_DQS]     ),
`endif                     
           .dq          ( {
`ifdef SDRAMx32
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT31],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT30],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT29],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT28],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT27],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT26],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT25],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT24],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT23],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT22],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT21],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT20],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT19],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT18],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT17],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT16],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT15],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT14],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT13],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT12],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT11],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT10],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT9],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT8],                                                
`endif
`ifdef SDRAMx16
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT15],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT14],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT13],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT12],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT11],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT10],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT9],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT8],                        
`endif                     
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT7],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT6],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT5],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT4],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT3],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT2],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT1],
                           dq[dwc_dram*pDRAM_IO_WIDTH+DQBIT0]} )
`ifdef VMM_VERIF
	`ifndef DDR4
           ,
           .speed_grade ( speed_grade )
	`endif
`endif
`ifdef LPDDR4MPHY
`ifdef LPDDR4
           ,
           .address_copy ( address_copy )
`endif
`endif
`ifdef LRDIMM_MULTI_RANK   
           ,
           .mwd_train   (mwd_train)
`endif           
          );
      end

`ifdef LPDDRX
`ifndef LPDDR4MPHY
      // when using address copy, the address of odd-numbered LPDDRX chips are connected to 
      // {RAS#, BA[2:0], CA[15:9]}, otherwise address of LPDDRX chips are connected to CA[9:0]
      if (`DWC_ADDR_COPY == 1 && (dwc_dram % 2) == 1) begin : gen_addr_copy
        assign lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = {{(pDRAM_ADDR_WIDTH-10){1'b0}}, ras_n, ba[2:0], a[15:10]};
      end else begin
        assign lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = {{(pDRAM_ADDR_WIDTH-10){1'b0}}, a[9:0]};
      end
`else
      // use lpddr4mphy specific input 
      `ifdef LPDDR3
        if (dwc_dram % 2 == 1)
          assign  lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = address_copy ? {{(pDRAM_ADDR_WIDTH-10){1'b0}}, ras_n, ba[2:0], a[15:10]} : {{(pDRAM_ADDR_WIDTH-10){1'b0}}, a[9:0]};
        else
      `endif
      `ifdef LPDDR4
          //assign  lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = {{(pDRAM_ADDR_WIDTH-10){1'b0}}, a[9:0]};
          if(pDIMM_NO == 0)
            assign  lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = address_copy?  a[13:0] : a[5:0];
          else if(pDIMM_NO == 1)
            assign  lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = address_copy?  a[15:0] : a[5:0];
          else
      `endif
            assign  lpa[dwc_dram*pDRAM_ADDR_WIDTH +: pDRAM_ADDR_WIDTH] = {{(pDRAM_ADDR_WIDTH-10){1'b0}}, a[9:0]};
`endif
`endif

    end // block: dwc_sdram
  endgenerate

  //---------------------------------------------------------------------------
  // SDRAM Rank Tasks
  //---------------------------------------------------------------------------
  // Tasks to specify system configuration of a rank, such as board delays
  
  // board delays
  // ------------
  // write path and read path main board delay
  task set_command_board_delay;
    input [31:0] chip_no; // chip number
    input [31:0] dly_ps;  // delay in ps
    begin
      set_chip_board_delay(chip_no, CMD_DELAY, dly_ps);
    end
  endtask // set_command_board_delay
  
  task set_write_board_delay;
    input [31:0] chip_no; // chip number
    input [31:0] dly_ps;  // delay in ps
    begin
      set_chip_board_delay(chip_no, WRITE_DELAY, dly_ps);
    end
  endtask // set_write_board_delay
  
  task set_read_board_delay;
    input [31:0] chip_no; // chip number
    input [31:0] dly_ps;  // delay in ps
    begin
       set_chip_board_delay(chip_no, READ_DELAY, dly_ps);
    end
  endtask // set_read_board_delay
  
  task delay_output_clocks;
    input [31:0] chip_no; // chip number
    input [31:0] dly_ps;  // delay in ps
    begin
      set_chip_board_delay(chip_no, CK_DELAY, dly_ps);
    end
  endtask // delay_output_clocks
  
  task delay_data_strobes;
    input [31:0] chip_no; // chip number
    input [31:0] dly_ps;  // delay in ps
    begin
      set_chip_board_delay(chip_no, QS_DELAY, dly_ps);
    end
  endtask // delay_data_strobes
  
  task delay_data_strobe;
    input        strobe_name;
    input [31:0] chip_no; // chip number
    input [31:0] dly_ps;  // delay in ps
    begin
      case (strobe_name)
        DQS_STROBE:  set_chip_board_delay(chip_no, DQS_DELAY, dly_ps);
        DQSb_STROBE: set_chip_board_delay(chip_no, DQSb_DELAY, dly_ps);
      endcase // case(strobe_name)
    end
  endtask // delay_data_strobe
  
  // update the board delays of the chip used in the rank
  task set_chip_board_delay;
    input [31:0] chip_no;   // chip number
    input [2:0]  dly_type;  // type of delay
    input [31:0] dly_ps;    // delay in picoseconds
    begin
      dram_chip_no  = chip_no;
      dram_dly_type = dly_type;
      dram_dly_ps   = dly_ps;
       -> e_set_board_delay;
      #0.001;
   end
  endtask // set_chip_board_delay
  

  // This following task is only for DDR3    
  // Specified the bit for Writing Leveling feedback 
  // For default:
  // wl_feedback_on_all_bits should be set to 0
  // wl_feedback_on_bit      should be set to bit 0
  task set_wl_feedback_bits;
  input reg [31:0] chip_no;   // chip number
  input reg        all_bits;  // fb on all bits or just one bit
  input integer    bit_no;    // bit no
    begin
`ifdef DDR3
      dram_chip_no  = chip_no;
      dram_all_bits = all_bits;
      dram_bit_no   = bit_no;
       -> e_set_wl_feedback_bits;
      #0.001;
`endif
    end
  endtask // set_wl_feedback_bits
      
  task get_tdqs2dq_val;
    input reg [31:0] chip_no;
    output real tdqs2dq_A;
    output real tdqs2dq_B;
    begin
     dram_chip_no  = chip_no;
     -> e_get_tdqs2dq; 
     #1;
     tdqs2dq_A = tdqs2dq_ch_A[dram_chip_no];
     tdqs2dq_B = tdqs2dq_ch_B[dram_chip_no];
    end 
  endtask  // get_tdqs2dq_val

  task get_tdqsck_lpddr3;
    input  reg [31:0] chip_no;
    output real       tdqsck;
    begin
     dram_chip_no  = chip_no;
     -> e_get_tdqsck_lpddr3; 
     #1;
     tdqsck = tdqsck_lpddr3[dram_chip_no];
    end 
  endtask  // get_tdqsck_lpddr3

  // Randomized tdqsck
  // Elpida model for LPDDR3
  // Micron model for LPDDR4
  task set_tdqsck;
    input reg [31:0] chip_no;
    input int tdqsck_A;
`ifdef LPDDR4
    input int tdqsck_B;
`endif
    begin
     dram_chip_no  = chip_no;
     -> e_set_tdqsck; 
     #1;
     tdqsck_ch_A[dram_chip_no] = tdqsck_A;
`ifdef LPDDR4
     tdqsck_ch_B[dram_chip_no] = tdqsck_B;
`endif
    end 
  endtask  // set_tdqsck


  // connect chips (bytes)
  // ---------------------
  // connects certain chips (bytes) only to the SDRAM system (controller); 
  // this is used to simulate byte enable functionality on the controller;
  // for x16, the number of bytes connected is always a multiple of 2
  // NOTE: disconnection of chips is modelled by driving the chip select to
  //       high (i.e. disconnected chips are simply deselected)
  initial
    begin
    // all chips are connected by default
      chip_dis      = {pNO_OF_CHIPS{1'b0}};
      chip_dis_mask = {pNO_OF_CHIPS{1'b0}};
   end
  
  // connect/disconnect data byte chips
  task connect_chips;
    input [31:0] no_of_bytes; // valid values 0 to 8
    
    integer active_chips;
    integer i;
    begin
      case (pDRAM_IO_WIDTH)
         4: active_chips = 2*no_of_bytes;
         8: active_chips = no_of_bytes;
        16: active_chips = (no_of_bytes/2) + (no_of_bytes % 2);
        32: active_chips = (no_of_bytes % 4) ? (no_of_bytes/4) + 1 : (no_of_bytes/4);
      endcase // case (pDRAM_IO_WIDTH)
      
      // connect only the active chips
      chip_dis     = {pNO_OF_CHIPS{1'b1}};
      for (i=0; i<active_chips; i=i+1) begin
        chip_dis[i] = 1'b0;
      end
      
      // enable the bytes in the GRM
`ifndef VMM_VERIF
//      `GRM.enable_bytes(no_of_bytes);
`endif
    end
  endtask // connect_chips

  task set_byte_enables;
    input [pNO_OF_BYTES-1:0] byte_en;
    integer byte_no;
    integer chip_no;
    begin
      // wait for negedge of ck before setting the chip_dis[] variable else
      // this will create tISCKE errors in the model since it's not timed to the ck
      @(negedge ck);

`ifdef SDRAMx8
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no] = ~byte_en[byte_no];
      end

`elsif SDRAMx16
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+2) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no] = ~(byte_en[byte_no] | byte_en[byte_no+1]);
      end

`elsif SDRAMx32
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+4) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no] = ~(byte_en[byte_no]   | byte_en[byte_no+1] |
                              byte_en[byte_no+2] | byte_en[byte_no+3]);
      end

`elsif SDRAMx4
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no*2;
        chip_dis[chip_no]   = ~byte_en[byte_no];
        chip_dis[chip_no+1] = ~byte_en[byte_no];
      end
`endif  

`ifndef VMM_VERIF
`ifdef DWC_VERILOG2005
  `ifdef DWC_USE_SHARED_AC
        if (pRANK_NO%2 == 0)
          `GRM.set_channel_byte_enable_mask(pRANK_NO%2,
            {{(`DWC_NO_OF_BYTES-(`DWC_NO_OF_BYTES/2)){1'b1}}, byte_en});
        if (pRANK_NO%2 == 1)
          `GRM.set_channel_byte_enable_mask(pRANK_NO%2,
            {byte_en, {(`DWC_NO_OF_BYTES/2){1'b1}}});
  `else  
    `ifndef VMM_VERIF       
        `GRM.set_byte_enables(byte_en);
    `endif 	
  `endif      
 `endif //  `ifdef DWC_VERILOG2005
 `endif
    end
  endtask // set_byte_enables
  
  task set_byte_enables_disable_ref;
    input [pNO_OF_BYTES-1:0] byte_en;
    integer byte_no;
    integer chip_no;
    begin
`ifdef SDRAMx8
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no] = ~byte_en[byte_no];
        set_refresh_check(chip_no, byte_en[byte_no]);
      end

`elsif SDRAMx16
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+2) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no] = ~(byte_en[byte_no] | byte_en[byte_no+1]);
        set_refresh_check(chip_no, ~chip_dis[chip_no]);
      end

`elsif SDRAMx32
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+4) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no] = ~(byte_en[byte_no]   | byte_en[byte_no+1] |
                              byte_en[byte_no+2] | byte_en[byte_no+3]);
        set_refresh_check(chip_no, ~chip_dis[chip_no]);
      end

`elsif SDRAMx4
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis[chip_no]   = ~byte_en[byte_no];
        chip_dis[chip_no+1] = ~byte_en[byte_no];
        set_refresh_check(chip_no,   byte_en[byte_no]);
        set_refresh_check(chip_no+1, byte_en[byte_no]);
      end
`endif  

`ifndef VMM_VERIF
`ifdef DWC_VERILOG2005
  `ifdef DWC_USE_SHARED_AC
        if (pRANK_NO%2 == 0)
          `GRM.set_channel_byte_enable_mask(pRANK_NO%2,
            {{(`DWC_NO_OF_BYTES-(`DWC_NO_OF_BYTES/2)){1'b1}}, byte_en});
        if (pRANK_NO%2 == 1)
          `GRM.set_channel_byte_enable_mask(pRANK_NO%2,
            {byte_en, {(`DWC_NO_OF_BYTES/2){1'b1}}});
  `else 
`ifndef VMM_VERIF       
        `GRM.set_byte_enables(byte_en);
`endif 	
  `endif      
 `endif //  `ifdef DWC_VERILOG2005
`endif
    end
  endtask // set_byte_enables  
  
  task set_chip_dis_mask;
    input [pNO_OF_BYTES-1:0]  mask;
    integer byte_no;
    integer chip_no;
    begin
`ifdef SDRAMx8
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no                = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis_mask[chip_no] = mask[byte_no];
      end

`elsif SDRAMx16
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+2) begin
        chip_no                = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis_mask[chip_no] = (mask[byte_no] | mask[byte_no+1]);
      end

`elsif SDRAMx32
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+4) begin
        chip_no                = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis_mask[chip_no] = (mask[byte_no]   | mask[byte_no+1] |
                                  mask[byte_no+2] | mask[byte_no+3] );
      end

`elsif SDRAMx4
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no                  = byte_no/(pDRAM_IO_WIDTH/8);
        chip_dis_mask[chip_no]   = mask[byte_no];
        chip_dis_mask[chip_no+1] = mask[byte_no];
      end
`endif  
    end
  endtask // set_chip_dis_mask
  
  // connects/diconnects the whole rank
  task connect_rank;
    begin
      @(negedge ck);
      chip_dis = {pNO_OF_CHIPS{1'b0}};
      `ifdef MICRON_DDR_V2
      enable_ca_in_check;
      `endif
    end
  endtask // connecte_rank
  
  task connect_rank_async;
    begin
      chip_dis = {pNO_OF_CHIPS{1'b0}};
      #0.001;
    end
  endtask // connect_rank_async
  
  task disconnect_rank;
    begin
      // disable clocks checks and refresh checks when rank is disconnected 
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Disconnecting rank %0d...", pRANK_NO));
      `endif
      disable_clock_checks;
      disable_refresh_check;
      disable_cmd_addr_timing_checks;
      `ifdef MICRON_DDR_V2
      disable_ca_in_check;
      `endif
      @(negedge ck);
      chip_dis = {pNO_OF_CHIPS{1'b1}};
    end
  endtask // connecte_rank

  task disconnect_rank_async;
    begin
      // disable clocks checks and refresh checks when rank is disconnected asyncronously (no ck required)
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Disconnecting rank async %0d...", pRANK_NO));
      `endif
      disable_clock_checks;
      disable_refresh_check;
      disable_cmd_addr_timing_checks;

      chip_dis = {pNO_OF_CHIPS{1'b1}};
      #0.001;
    end
  endtask // disconnect_rank_async

    // returns the number of chips used in the system
  function [31:0] get_number_of_chips;
    input [31:0] no_of_bytes;
    begin
      case (pDRAM_IO_WIDTH)
         4: get_number_of_chips = 2*no_of_bytes;
         8: get_number_of_chips = no_of_bytes;
        16: get_number_of_chips = (no_of_bytes/2) + (no_of_bytes % 2);
        32: get_number_of_chips = (no_of_bytes % 4) ? (no_of_bytes/4) + 1 : (no_of_bytes/4);
      endcase // case (pDRAM_IO_WIDTH)
    end     
  endfunction
  
  
  // SDRAM clock checks
  // ------------------
  // enable/disable clock violation checks on the SDRAMs
  task enable_clock_checks;
    integer i;
    begin
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Enabling memory timing checks for rank %0d...", pRANK_NO));
      `endif
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_clock_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_clock_checks

  task enable_ck_checks;
     enable_clock_checks();
  endtask // enable_ck_checks
   
  task disable_clock_checks;
    integer i;
    begin
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Disabling memory timing checks for rank %0d...", pRANK_NO));
      `endif
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_clock_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_clock_checks
  
  // SDRAM RESET checks
  // ------------------
  // enable/disable reset violation checks on the SDRAMs (DDR4 MICRON)
  task enable_reset_checks;
    integer i;
    begin
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Enabling memory reset checks for rank %0d...", pRANK_NO));
      `endif
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_reset_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_reset_checks

  task disable_reset_checks;
    integer i;
    begin
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Disabling memory reset checks for rank %0d...", pRANK_NO));
      `endif
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_reset_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_reset_checks


  // ELPIDA tPDmax check disable
  // ---------------------------
  task enable_tpdmax_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_tpdmax_checks(i, 1);
      end
    end
  endtask // enable_tpdmax_check

  task disable_tpdmax_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_tpdmax_checks(i, 0);
      end
    end
  endtask

  task set_clock_checks;
    input [31:0] chip_no;   // chip number
    input clock_check;
    begin
      dram_chip_no = chip_no;
      dram_clock_check = clock_check;
      -> e_set_clock_checks;
      #0.001;
    end
  endtask

  task set_reset_checks;
    input [31:0] chip_no;   // chip number
    input reset_check;
    begin
      dram_chip_no = chip_no;
      dram_reset_check = reset_check;
      -> e_set_reset_checks;
      #0.001;
    end
  endtask

  task set_tpdmax_checks;
    input [31:0] chip_no;   // chip number
    input tdpmax_check;
    begin
      dram_chip_no = chip_no;
      dram_tpdmax_check = tdpmax_check;
      -> e_set_tpdmax_checks;
      #0.001;
    end
  endtask // set_tpdmax_checks
 
   
  // SDRAM DQ setup/hold checks
  // --------------------------
  // enable/diasble DQ setup/hold violation checks on the SDRAMs
  task enable_dq_setup_hold_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dq_setup_hold_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_dq_setup_hold_checks
  
  task disable_dq_setup_hold_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dq_setup_hold_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_dq_setup_hold_checks
  
  task set_dq_setup_byte_enables;
    input[pNO_OF_BYTES-1:0] byte_enable;
    integer byte_no;
    integer chip_no;
    begin
`ifdef SDRAMx8
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
`elsif SDRAMx16
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+2) begin
`elsif SDRAMx32
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+4) begin
`endif
`ifdef SDRAMx4
      for (byte_no=0; byte_no<2*pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no;
        set_dq_setup_hold_checks(chip_no, byte_enable[byte_no/2]);
`else
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        set_dq_setup_hold_checks(chip_no, byte_enable[byte_no]);
`endif
	     #0.1;
      end
    end
  endtask // disable_dq_setup_hold_checks
  
  task set_dq_setup_hold_checks;
    input [31:0] chip_no;   // chip number
    input dq_setup_hold_check;
    begin
      dram_chip_no = chip_no;
      dram_dq_setup_hold_check = dq_setup_hold_check;
      -> e_set_dq_setup_hold_checks;
      #0.1;
    end
  endtask // set_dq_setup_hold_checks

  task set_train_err;
    input [31:0] chip_no;
    begin
      dram_chip_no  = chip_no;
      dram_dq_force = 1;
      -> e_set_dq_train_err;
      #0.1;
    end
  endtask
  
  task exit_train_err;
    input [31:0] chip_no;
    begin
      dram_chip_no  = chip_no;
      dram_dq_force = 0;
      -> e_set_dq_train_err;
      #0.1;
    end
  endtask

  task set_train_err_dqs;
    input [31:0] chip_no;
    begin
      dram_chip_no  = chip_no;
      dram_dq_force = 1;
      -> e_set_dqs_train_err;
      #0.1;
    end
  endtask
  
  task exit_train_err_dqs;
    input [31:0] chip_no;
    begin
      dram_chip_no  = chip_no;
      dram_dq_force = 0;
      -> e_set_dqs_train_err;
      #0.1;
    end
  endtask
// SDRAM DQ/DM/DQS pulse width checks
  // --------------------------
  // enable/diasble DQ/DM/DQS pulse width violation checks on the SDRAMs
  task enable_dq_pulse_width_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dq_pulse_width_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_dq_pulse_width_checks
  
  task disable_dq_pulse_width_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dq_pulse_width_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_dq_pulse_width_checks
  
  task set_dq_pulse_width_byte_enables;
    input[pNO_OF_BYTES-1:0] byte_enable;
    integer byte_no;
    integer chip_no;
    begin
`ifdef SDRAMx8
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
`elsif SDRAMx16
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+2) begin
`elsif SDRAMx32
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+4) begin
`endif
`ifdef SDRAMx4
      for (byte_no=0; byte_no<2*pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no;
        set_dq_pulse_width_checks(chip_no, byte_enable[byte_no/2]);
`else
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        set_dq_pulse_width_checks(chip_no, byte_enable[byte_no]);
`endif
	     #0.1;
      end
    end
  endtask // disable_dq_setup_hold_checks
  
  task set_dq_pulse_width_checks;
    input [31:0] chip_no;   // chip number
    input dq_pulse_width_check;
    begin
      dram_chip_no = chip_no;
      dram_dq_pulse_width_check = dq_pulse_width_check;
      -> e_set_dq_pulse_width_checks;
      #0.001;
    end
  endtask // set_dq_pulse_width_checks
  
  
  // SDRAM DQS to CK setup/hold checks
  // ---------------------------------
  // enable/diasble DQS to CK setup/hold violation checks on the SDRAMs
  task enable_dqs_ck_setup_hold_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dqs_ck_setup_hold_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_dqs_ck_setup_hold_checks
  
  task disable_dqs_ck_setup_hold_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dqs_ck_setup_hold_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_dqs_ck_setup_hold_checks

  task set_dqs_ck_setup_byte_enables;
    input[pNO_OF_BYTES-1:0] byte_enable;
    integer byte_no;
    integer chip_no;
    begin
`ifdef SDRAMx8
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+1) begin
`elsif SDRAMx16
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+2) begin
`elsif SDRAMx32
      for (byte_no=0; byte_no<pNO_OF_BYTES; byte_no=byte_no+4) begin
`endif
`ifdef SDRAMx4
      for (byte_no=0; byte_no<2*pNO_OF_BYTES; byte_no=byte_no+1) begin
        chip_no = byte_no;
        set_dqs_ck_setup_hold_checks(chip_no, byte_enable[byte_no/2]);
`else
        chip_no = byte_no/(pDRAM_IO_WIDTH/8);
        set_dqs_ck_setup_hold_checks(chip_no, byte_enable[byte_no]);
`endif
	     #0.1;
      end
    end
  endtask // disable_dq_setup_hold_checks
  
  task set_dqs_ck_setup_hold_checks;
    input [31:0] chip_no;   // chip number
    input dqs_ck_setup_hold_check;
    begin
      dram_chip_no = chip_no;
      dram_dqs_ck_setup_hold_check = dqs_ck_setup_hold_check;
      -> e_set_dqs_ck_setup_hold_checks;
      #0.1;
    end
  endtask // set_dqs_ck_setup_hold_checks
  
  
  // SDRAM DQS to CK setup/hold checks
  // ---------------------------------
  // enable/diasble DQS to CK setup/hold violation checks on the SDRAMs
  task enable_cmd_addr_timing_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_cmd_addr_timing_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_cmd_addr_timing_checks
  
  task disable_cmd_addr_timing_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_cmd_addr_timing_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_cmd_addr_timing_checks
  
  task set_cmd_addr_timing_checks;
    input [31:0] chip_no;   // chip number
    input cmd_addr_timing_check;
    begin
      dram_chip_no = chip_no;
      dram_cmd_addr_timing_check = cmd_addr_timing_check;
      -> e_set_cmd_addr_timing_checks;
      #0.001;
    end
  endtask // set_cmd_addr_timing_checks
  
  
  // SDRAM DQ/DM/DQS pulse width checks
  // --------------------------
  // enable/diasble DQ/DM/DQS pulse width violation checks on the SDRAMs
  task enable_ctrl_addr_pulse_width_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_ctrl_addr_pulse_width_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_ctrl_addr_pulse_width_checks
  
  task disable_ctrl_addr_pulse_width_checks;
    integer i;
    begin
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_ctrl_addr_pulse_width_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_ctrl_addr_pulse_width_checks
  
  task set_ctrl_addr_pulse_width_checks;
    input [31:0] chip_no;   // chip number
    input ctrl_addr_pulse_width_check;
    begin
      dram_chip_no = chip_no;
      dram_ctrl_addr_pulse_width_check = ctrl_addr_pulse_width_check;
      -> e_set_ctrl_addr_pulse_width_checks;
      #0.001;
    end
  endtask // set_ctrl_addr_pulse_width_checks

`ifdef DDR3
  // SDRAM ODTH{4,8} Timing checks
  // --------------------------
  // enable/diasble ODTH{4,8} timing checks on the SDRAM
  task enable_odth_timing_checks;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_odth_timing_checks(i, 1);
	#0.1;
      end
    end
  endtask // enable_odth_timing_checks

  task disable_odth_timing_checks;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_odth_timing_checks(i, 0);
	#0.1;
      end
    end
  endtask // disable_odth_timing_checks

  task set_odth_timing_checks;
    input [31:0] chip_no;   // chip number
    input odth_timing_check;
    begin
      dram_chip_no = chip_no;
      dram_odth_timing_check = odth_timing_check;
      -> e_set_odth_timing_checks;
      #0.001;
    end
  endtask // set_odth_timing_checks
  
  // SDRAM DQS Latch Timing checks
  // -----------------------------
  // enable/disable DQS Latch timing checks on the SDRAM
  task enable_dqs_latch_timing_checks;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dqs_latch_timing_checks(i, 1);
      end
    end
  endtask // enable_dqs_latch_timing_checks

  task disable_dqs_latch_timing_checks;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_dqs_latch_timing_checks(i, 0);
      end
    end
  endtask // disable_dqs_latch_timing_checks

  task set_dqs_latch_timing_checks;
    input [31:0] chip_no;   // chip number
    input dqs_latch_timing_check;
    begin
      dram_chip_no = chip_no;
      dram_dqs_latch_timing_check = dqs_latch_timing_check;
      -> e_set_dqs_latch_timing_checks;
      #0.0;
    end
  endtask // set_dqs_latch_timing_checks
`endif
  
  
  // SDRAM refresh checks
  // --------------------
  // enable/diasble refresh violation checks on the SDRAMs
  task enable_refresh_check;
    integer i;
    begin
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Enabling refresh timing checks for rank %0d...", pRANK_NO));
      `endif
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_refresh_check(i, 1);
	#0.1;
      end
    end
  endtask // enable_refresh_check
  
  task disable_refresh_check;
    integer i;
    begin
      `ifdef VMM_VERIF
        `vmm_note(log, $psprintf("Disabling refresh timing checks for rank %0d...", pRANK_NO));
      `endif
      for (i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_refresh_check(i, 0);
	#0.1;
      end
    end
  endtask // disable_refresh_check
  
  task set_refresh_check;
    input [31:0] chip_no;   // chip number
    input rfsh_check;
    begin
      dram_chip_no = chip_no;
      dram_rfsh_check = rfsh_check;
      -> e_set_refresh_check;
      #0.001;
    end
  endtask // set_refresh_check

  // SDRAM tICVW check
  // --------------------
  // diasble tICVW timing parameter check on the SDRAMs
  task disable_ca_valid_window_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_ca_valid_window_check(i, 0);
      end
    end
  endtask // disable_ca_valid_window_check

  // enable tICVW timing parameter check on the SDRAMs
  task enable_ca_valid_window_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_ca_valid_window_check(i, 1);
      end
    end
  endtask // enable_ca_valid_window_check
  
  task set_ca_valid_window_check;
    input [31:0] chip_no;   // chip number
    input ca_valid_window_check;
    begin
      dram_chip_no = chip_no;
      dram_ca_valid_window_check = ca_valid_window_check;
      -> e_set_ca_valid_window_check;
      #0.0;
    end
  endtask // set_ca_valid_window_check

 // SDRAM tDQSS check
  // --------------------
  // diasble tDQSS timing parameter check on the SDRAMs
  task disable_write_2_dqs_t_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_write_2_dqs_t_check(i, 0);
      end
    end
  endtask // disable_write_2_dqs_t_check

  // enable tDQSS timing parameter check on the SDRAMs
  task enable_write_2_dqs_t_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_write_2_dqs_t_check(i, 1);
      end
    end
  endtask // enable_write_2_dqs_t_check
  
  task set_write_2_dqs_t_check;
    input [31:0] chip_no;   // chip number
    input write_2_dqs_t_check;
    begin
      dram_chip_no = chip_no;
      dram_write_2_dqs_t_check = write_2_dqs_t_check;
      -> e_set_write_2_dqs_t_check;
      #0.0;
    end
  endtask // set_write_2_dqs_t_check

   // SDRAM CA input check
  // --------------------
  // diasble CA input  check on the SDRAMs
  task disable_ca_in_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_ca_in_check(i, 0);
      end
    end
  endtask // disable_ca_in_check

  // enable CA input check on the SDRAMs
  task enable_ca_in_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_ca_in_check(i, 1);
      end
    end
  endtask // enable_ca_in_check
  
  task set_ca_in_check;
    input [31:0] chip_no;   // chip number
    input ca_in_check;
    begin
      dram_chip_no = chip_no;
      dram_ca_in_check = ca_in_check;
      -> e_set_ca_in_check;
      #0.0;
    end
  endtask // set_ca_in_check

     // SDRAM tSRX check
  // --------------------
  // diasble tSRX  check on the SDRAMs
  task disable_tsrx_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_tsrx_check(i, 0);
      end
    end
  endtask // disable_tsrx_check

  // enable tSRX check on the SDRAMs
  task enable_tsrx_check;
    integer i;
    begin
      for(i=0; i<pNO_OF_CHIPS; i=i+1) begin
        set_tsrx_check(i, 1);
      end
    end
  endtask // enable_tsrx_check
  
  task set_tsrx_check;
    input [31:0] chip_no;   // chip number
    input tsrx_check;
    begin
      dram_chip_no = chip_no;
      dram_tsrx_check = tsrx_check;
      -> e_set_tsrx_check;
      #0.0;
    end
  endtask // set_tsrx_check
 
  // DRAM chip update
  // ----------------
  // tasks to update DRAM chip delays and variables
  generate 
    genvar dwc_udram;
    for (dwc_udram=0; dwc_udram<pNO_OF_CHIPS; dwc_udram=dwc_udram+1) begin:ddr_udram
      
`ifdef DDR3
      always @(e_set_wl_feedback_bits) begin: dram_wl_feedback
        if (dram_chip_no == dwc_udram) begin
        `ifndef SNPS_VIP
          dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.wl_feedback_on_all_bits = dram_all_bits;
          dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.wl_feedback_on_bit      = dram_bit_no;
        `endif
        end
      end
`endif

`ifdef LPDDR3
  `ifdef ELPIDA_DDR
    always @(e_set_tdqsck) begin: dram_set_tdqsck_lpddr3
      if (dram_chip_no == dwc_udram) begin
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_tdqsck(tdqsck_ch_A[dwc_udram]);
      end
    end
  `endif
`endif

`ifdef LPDDR3
  `ifdef MICRON_DDR
    `ifdef OVRD_TDQSCK
      always @(e_get_tdqsck_lpddr3) begin: dram_get_tdqsck_lpddr3
        if (dram_chip_no == dwc_udram) begin
          dwc_sdram[dwc_udram].xn_dram.u_sdram.get_tdqsck(tdqsck_lpddr3[dwc_udram]);
        end
      end
    `else      
      always @(e_get_tdqsck_lpddr3) begin: dram_get_tdqsck_lpddr3
        tdqsck_lpddr3[dwc_udram] = 2500;
      end
    `endif
  `endif
`else
  always @(e_get_tdqsck_lpddr3) begin : dram_get_tdqsck_lpddr3
    // Elpida doesn't support randomized tDQSCK, make it max
    tdqsck_lpddr3[dwc_udram] = 5500;
  end
`endif

`ifdef LPDDR4
      always @(e_get_tdqs2dq) begin: dram_get_tdqs2dq
        if (dram_chip_no == dwc_udram) begin
          `ifdef MICRON_DDR_V2
            // dwc_sdram[dwc_udram].xn_dram.u_sdram.get_tdqs2dq(tdqs2dq_ch_A[dwc_udram], tdqs2dq_ch_B[dwc_udram] );
          `else
            dwc_sdram[dwc_udram].xn_dram.u_sdram.get_tdqs2dq(tdqs2dq_ch_A[dwc_udram], tdqs2dq_ch_B[dwc_udram] );
          `endif
        end
      end
`endif


`ifdef VMM_VERIF
 `ifdef MICRON_DDR
  `ifndef LPDDR2
       `ifndef DDR4
        //GEN4MPHY_TBD   
       `ifndef LPDDR4
      always @(e_set_mpr_bytemask) begin: dram_set_mpr_bytemask
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_mpr_bytemask(dram_mpr_bytemask);
      end
       `endif
       `endif
   `endif
  `endif      
`endif

`ifdef DDR4
      always @(e_set_reset_checks) begin: dram_reset_checks
        if (dram_chip_no == dwc_udram) begin
            dwc_sdram[dwc_udram].xn_dram.u_sdram.set_reset_checks(dram_reset_check);
        end
      end
`endif

    always @(e_set_dq_train_err) begin: dram_dq_training_err
      if (dram_chip_no == dwc_udram) begin
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dq_drain_err(dram_dq_force);
      end
    end
`ifdef LPDDR4   
    always @(e_set_dqs_train_err) begin: dram_dqs_training_err
      if (dram_chip_no == dwc_udram) begin
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dqs_drain_err(dram_dq_force);
      end
    end
`endif

  always @(e_set_clock_checks) begin: dram_clock_checks
    if (dram_chip_no == dwc_udram) begin
      `ifdef DDR4
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_ck_checks(dram_ck_check);
      `else
        `ifdef MICRON_DDR_V2
           dwc_sdram[dwc_udram].xn_dram.u_sdram.set_clock_checks(dram_clock_check);
        `else
          dwc_sdram[dwc_udram].xn_dram.u_sdram.set_clock_checks(dram_clock_check);
        `endif
      `endif
    end
  end


`ifndef LPDDR4 
    `ifndef DDR4   
      always @(e_set_dq_setup_hold_checks) begin: dram_dq_setup_hold_checks
        if (dram_chip_no == dwc_udram) begin
          dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dq_setup_hold_checks(dram_dq_setup_hold_check);
        end
      end
    
      always @(e_set_dq_pulse_width_checks) begin: dram_dq_pulse_width_checks
        if (dram_chip_no == dwc_udram) begin
          dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dq_pulse_width_checks(dram_dq_pulse_width_check);
        end
      end
    `endif
   
    `ifdef LPDDR2
    `else
      `ifdef LPDDR3
          always @(e_set_ctrl_addr_pulse_width_checks) begin: dram_ctrl_addr_pulse_width_checks
            if (dram_chip_no == dwc_udram) begin
              dwc_sdram[dwc_udram].xn_dram.u_sdram.set_ctrl_addr_pulse_width_checks(dram_ctrl_addr_pulse_width_check);
            end
          end
      `else // DDR2 or DDR3
        `ifndef DDR4
          always @(e_set_dqs_ck_setup_hold_checks) begin: dram_dqs_ck_setup_hold_checks
            if (dram_chip_no == dwc_udram) begin
              dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dqs_ck_setup_hold_checks(dram_dqs_ck_setup_hold_check);
            end
          end
    
          always @(e_set_cmd_addr_timing_checks) begin: dram_cmd_addr_timing_checks
            if (dram_chip_no == dwc_udram) begin
              dwc_sdram[dwc_udram].xn_dram.u_sdram.set_cmd_addr_timing_checks(dram_cmd_addr_timing_check);
            end
          end
    
          always @(e_set_ctrl_addr_pulse_width_checks) begin: dram_ctrl_addr_pulse_width_checks
            if (dram_chip_no == dwc_udram) begin
              dwc_sdram[dwc_udram].xn_dram.u_sdram.set_ctrl_addr_pulse_width_checks(dram_ctrl_addr_pulse_width_check);
            end
          end
        `endif
        `ifdef DDR3
          always @(e_set_odth_timing_checks) begin : dram_odth_timing_checks
            if (dram_chip_no == dwc_udram) begin
              dwc_sdram[dwc_udram].xn_dram.u_sdram.set_odth_timing_checks(dram_odth_timing_check);
            end
          end
        `endif
      `endif
    `endif

    `ifndef VMM_VERIF
       `ifdef DDR3
             always @(e_set_dqs_latch_timing_checks) begin : dram_dqs_latch_timing_checks
               if (dram_chip_no == dwc_udram) begin
                 dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dqs_latch_timing_checks(dram_dqs_latch_timing_check);
               end
             end
       `endif // ! `ifdef DDR3
    `endif // 
    always @(e_set_refresh_check) begin: dram_refresh_check
      if (dram_chip_no == dwc_udram) begin
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_refresh_check(dram_rfsh_check);
      end
    end
`endif

`ifdef DDR4
  always @(e_set_tpdmax_checks) begin : dram_tpdmax_checks
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_tpdmax_check(dram_tpdmax_check);
    end
  end
`endif
`ifdef DDR3
  `ifndef VMM_VERIF
    always @(e_set_tpdmax_checks) begin : dram_tpdmax_checks
      if (dram_chip_no == dwc_udram) begin
        dwc_sdram[dwc_udram].xn_dram.u_sdram.set_tpdmax_check(dram_tpdmax_check);
      end
    end
  `endif
`endif

`ifdef MICRON_DDR_V2
  always @(e_set_ca_valid_window_check) begin : ca_valid_window_check
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_ca_valid_window_check(dram_ca_valid_window_check);
    end
  end
  
  always @(e_set_dqs_ck_setup_hold_checks) begin: dram_dqs_ck_setup_hold_checks
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dqs_ck_setup_hold_checks(dram_dqs_ck_setup_hold_check);
    end
  end

  always @(e_set_dq_pulse_width_checks) begin: dram_dq_pulse_width_checks
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dq_pulse_width_checks(dram_dq_pulse_width_check);
    end
  end
  
  always @(e_set_write_2_dqs_t_check) begin : write_2_dqs_t_check
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_write_2_dqs_t_check(dram_write_2_dqs_t_check);
    end
  end
  
  always @(e_set_ca_in_check) begin : ca_in_check
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_ca_in_check(dram_ca_in_check);
    end
  end
  always @(e_set_tsrx_check) begin : tsrx_check
    if (dram_chip_no == dwc_udram) begin
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_tsrx_check(dram_tsrx_check);
    end
  end
`endif

`ifdef MICRON_DDR_V2
 // disable checks on unsed bytes
  initial begin : disable_unused_dqs_dmi_dq_chk
    #0.0;
    if (dwc_udram == (pNO_OF_CHIPS-1) && (pPARTIAL_BYTES==3)) begin
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DQS_v_chk_enable[3:0]   = 4'b0111;
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DMI_v_chk_enable[3:0]   = 4'b0111;
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DQ_v_chk_enable[3:0]    = 4'b0111;  
    end else if(dwc_udram == (pNO_OF_CHIPS-1) && (pPARTIAL_BYTES==2)) begin
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DQS_v_chk_enable[3:0]   = 4'b0011;
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DMI_v_chk_enable[3:0]   = 4'b0011;
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DQ_v_chk_enable[3:0]    = 4'b0011;  
    end else if(dwc_udram == (pNO_OF_CHIPS-1) && (pPARTIAL_BYTES==1)) begin
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DQS_v_chk_enable[3:0]   = 4'b0001;
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DMI_v_chk_enable[3:0]   = 4'b0001;
      force dwc_sdram[dwc_udram].xn_dram.u_sdram.sdram.DQ_v_chk_enable[3:0]    = 4'b0001;  
    end
  end
`endif

`ifdef MICRON_DDR_V2  
  `ifndef BYPASS_MANTIS_10496
  `else
   // disable DQ/DMI/DQS oulse width checks
    initial begin : disable_dq_pulse_width_chk
      #0.0;
      dwc_sdram[dwc_udram].xn_dram.u_sdram.set_dq_pulse_width_checks(1'b0);
    end
  `endif
`endif

    end
  endgenerate

  // SDRAM Array Initialization
  //---------------------------
  // initializes address locations of SDRAM chips with either all zeros, all
  // ones or random data using the designes `ALL_ZEROS, `ALL_ONES, `RANDOM_DATA
  // initialization can be done by directly accessing the SDRAM memory array 
  // (using verilog hierarchy), or by using normal memory bus cycles
  
  // initializes the whole SDRAM array
  task initialize_sdram;
    input        access_type; // access type: `DIRECT_ACCESS vs `MEM_ACCESS
    input [31:0] data_type;   // data type: `ALL_ZEROS, `ALL_ONES, `RANDOM_DATA
    
    integer bank;
    integer no_of_banks;
    begin
      no_of_banks = 8; // *** will depend on SDRAM chip(s) used TBD
      for (bank=0; bank<no_of_banks; bank=bank+1) begin
        initialize_sdram_bank(access_type, data_type, bank);
      end
    end
  endtask // initialize_sdram
  
  
  // initializes all address locations of an SDRAM bank
  task initialize_sdram_bank;
    input                         access_type;
    input [31:0]                  data_type;
    input [`SDRAM_BANK_WIDTH-1:0] bank;
    
    integer row;
    integer no_of_rows;
    begin
      no_of_rows = 1024; // *** will depend on SDRAM chip(s) used TBD
      for (row=0; row<no_of_rows; row=row+1) begin
        initialize_sdram_row(access_type, data_type, bank, row);
      end
    end
  endtask // initialize_sdram_bank
  
  
  // initializes all address locations of an SDRAM row
  task initialize_sdram_row;
    input                         access_type;
    input [31:0]                  data_type;
    input [`SDRAM_BANK_WIDTH-1:0] bank;
    input [`SDRAM_BANK_WIDTH-1:0] row;
    
    integer col;
    integer no_of_columns;
    begin
      no_of_columns = 1024; // *** will depend on SDRAM chip(s) used TBD
      for (col=0; col<no_of_columns; col=col+1) begin
        initialize_sdram_address(access_type, data_type, bank, row, col);
      end
    end
  endtask // initialize_sdram_row
    
    
  // initializes an SDRAM address location
  task initialize_sdram_address;
    input                         access_type;
    input [31:0]                  data_type;
    input [`SDRAM_BANK_WIDTH-1:0] bank;
    input [`SDRAM_ROW_WIDTH-1:0]  row;
    input [`SDRAM_COL_WIDTH-1:0]  col;
    begin
      // *** TBD: call task in ddr_sdram
      //     (may need to generate data here or in ddr_sdram)
    end
  endtask // initialize_sdram_address
  
  
  // initializes a selected address range
  task initialize_sdram_addresses;
    input                         access_type;
    input [31:0]                  data_type;
    input [`SDRAM_BANK_WIDTH-1:0] from_bank;
    input [`SDRAM_BANK_WIDTH-1:0] to_bank;
    input [`SDRAM_ROW_WIDTH-1:0]  from_row;
    input [`SDRAM_ROW_WIDTH-1:0]  to_row;
    input [`SDRAM_COL_WIDTH-1:0]  from_col;
    input [`SDRAM_COL_WIDTH-1:0]  to_col;
    
    integer bank, row, col;
    begin
      for (bank=from_bank; bank<=to_bank; bank=bank+1) begin
        for (row=from_row; row<=to_row; row=row+1) begin
          for (col=from_col; col<=to_col; col=col+1) begin
            initialize_sdram_address(access_type, data_type, bank, row, col);
          end
        end
      end
    end
  endtask // initialize_sdram_addresses

  task set_mpr_bytemask;
    input [7:0] bytemask;
    `ifdef VMM_VERIF
      `ifdef MICRON_DDR
        dram_mpr_bytemask = bytemask;
        ->e_set_mpr_bytemask;
      `endif
    `endif
  endtask
   
endmodule // ddr_rank

  
