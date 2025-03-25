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

module ddr_dimm
  #(
    // configurable design parameters
    parameter pDIMM_NO         = 0,
    parameter pNO_OF_BYTES     = 4,  // SDRAM number of bytes
    parameter pBANK_WIDTH      = 3,  // SDRAM bank address width
    parameter pBK_WIDTH        = 2,  // SDRAM bank address width (DDR4)
    parameter pBG_WIDTH        = 2,  // SDRAM bank address width (DDR4)
    parameter pADDR_WIDTH      = 16, // SDRAM address width
    parameter pDRAM_BANK_WIDTH = 3,  // SDRAM chip bank address width
    parameter pDRAM_ADDR_WIDTH = 16, // SDRAM chip address width
    parameter pDRAM_IO_WIDTH   = 8,  // SDRAM chip I/O width
    parameter pUDIMM_MIRROR    = 0,  // Unbuffered DIMM address mirroring
    parameter pRDIMM_MIRROR    = 0,  // 0=no mirroring, 1=mirroring on for odd ranks
    parameter pCID_WIDTH       = `DWC_CID_WIDTH,  // SDRAM chip ID width

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
    parameter pNO_OF_RANKS     = 1,                 //Multirank support

    parameter pRDIMM_CS_WIDTH  = 0,

    // x4 SDRAM have separate DQS/DM per 4 bits
    parameter pDRAM_DS_WIDTH   = (pDRAM_IO_WIDTH == 4) ? 1 : (pDRAM_IO_WIDTH/8)
   )
   (
    input                      rst_n,   // SDRAM reset
    input                      ck,      // SDRAM clock
    input                      ck_n,    // SDRAM clock #
    input [pNO_OF_RANKS-1:0]   cke,     // SDRAM clock enable
    input [pNO_OF_RANKS-1:0]   odt,     // SDRAM on-die termination
    input [pNO_OF_RANKS-1:0]   cs_n,    // SDRAM chip select
`ifdef DDR4
    input [pCID_WIDTH -1:0]    c,       // SDRAM chip ID
    input                      act_n,   // SDRAM activate
    input                      parity,  // SDRAM Parity In
    output                     alert_n, // SDRAM Parity Error
    input [pBK_WIDTH -1:0]     ba,      // SDRAM bank address
    input [pBG_WIDTH -1:0]     bg,      // SDRAM bank group 
`else
    `ifndef LPDDR4MPHY
    input                      mirror,  // RDIMM mirror
    input                      qcsen_n, // RDIMM quadcs enable    
    `endif 
    input                      ras_n,   // SDRAM row address select
    input                      cas_n,   // SDRAM column address select
    input                      we_n,    // SDRAM write enable
    input [pBANK_WIDTH -1:0]   ba,      // SDRAM bank address
    output                     alert_n, // SDRAM Parity Error
`endif
`ifdef DDR3
    input                      parity,  // SDRAM Parity In
`endif
`ifdef LPDDR2
    input                      parity,  // SDRAM Parity In
`endif
`ifdef LPDDRX
  `ifndef LPDDR4
    input [pADDR_WIDTH+6*`DWC_ADDR_COPY-1:0] a,
  `else
    input [pADDR_WIDTH+6*`DWC_ADDR_COPY-1:0] a,
   // input [pADDR_WIDTH   -1:0] a,
  `endif
`else
    input [pADDR_WIDTH   -1:0] a,       // SDRAM address
`endif

    input [pNO_OF_BYTES*pNO_OF_DX_DQS-1:0] dm,    // SDRAM output data mask
    inout [pNO_OF_BYTES*pNO_OF_DX_DQS-1:0] dqs,   // SDRAM input/output data strobe
    inout [pNO_OF_BYTES*pNO_OF_DX_DQS-1:0] dqs_n, // SDRAM input/output data strobe #
`ifdef LPDDR4MPHY
    input                                  address_copy,
`endif    
    inout [pDATA_WIDTH               -1:0] dq     // SDRAM input/output data
`ifdef VMM_VERIF
  `ifndef DDR4
    ,
    input [3:0] speed_grade
  `endif 
`endif
   );

  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
`ifdef VMM_VERIF
  vmm_log log = new("ddr_nodimm", "ddr_nodimm");
`endif

`ifndef DWC_ADDR_COPY
  `define DWC_ADDR_COPY 0
`endif 

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                     rst_n_r;  
  reg                     ck_r;  
  reg                     ck_n_r;  
  reg [pNO_OF_RANKS-1:0]  cke_r; // remove??
  reg [pNO_OF_RANKS-1:0]  odt_r;
  reg [pNO_OF_RANKS-1:0]  cs_n_r;
  reg                     ras_n_r;
  reg                     cas_n_r;
  reg                     we_n_r;
  reg                     act_n_r;
  reg                     parity_r;
`ifdef DDR4
  reg  [pBK_WIDTH -1:0]   ba_r;
  reg  [pCID_WIDTH -1:0]  c_r;
`else
  reg  [pDRAM_BANK_WIDTH-1:0] ba_r;
`endif
  reg  [pBG_WIDTH   -1:0] bg_r;
`ifdef LPDDRX
  `ifndef LPDDR4
  reg  [pADDR_WIDTH+6*`DWC_ADDR_COPY-1:0] a_r;
  `else
  reg  [pADDR_WIDTH+6*`DWC_ADDR_COPY-1:0] a_r;
  //reg  [pADDR_WIDTH -1:0] a_r;
  `endif
`else
  reg  [pADDR_WIDTH -1:0] a_r;
`endif

  wire [pNO_OF_RANKS-1:0] alert_n_r;
  

  //---------------------------------------------------------------------------
  // SDRAM Rank
  //---------------------------------------------------------------------------
  generate 
    genvar dwc_rnk;
    for (dwc_rnk = 0; dwc_rnk < pNO_OF_RANKS; dwc_rnk++) begin : dwc_rank
      ddr_rank 
        #(
          .pRANK_NO         ( dwc_rnk          ), 
          .pNO_OF_BYTES     ( pNO_OF_BYTES     ), 
`ifdef DDR4
  	      .pBANK_WIDTH      ( pBK_WIDTH        ),
`else
  	      .pBANK_WIDTH      ( pDRAM_BANK_WIDTH ),
`endif
  	      .pBG_WIDTH        ( pBG_WIDTH        ),
  	      .pADDR_WIDTH      ( pADDR_WIDTH      ),
         .pDRAM_BANK_WIDTH ( pDRAM_BANK_WIDTH ),
  	      .pDRAM_ADDR_WIDTH ( pDRAM_ADDR_WIDTH ),
         .pDRAM_IO_WIDTH   ( pDRAM_IO_WIDTH   ),
  	      .pDATA_WIDTH      ( pDATA_WIDTH      ),
         .pPARTIAL_BYTES   ( pPARTIAL_BYTES   ),
  	      .pUNUSED_BYTES    ( pUNUSED_BYTES    ),
         .pNO_OF_CHIPS     ( pNO_OF_CHIPS     ),
  	      .pNO_OF_DX_DQS    ( pNO_OF_DX_DQS    ),
         .pDRAM_DS_WIDTH   ( pDRAM_DS_WIDTH   ),
         .pDIMM_NO         ( pDIMM_NO         )
         
         )
      sdram_rank
         (
          .rst_n            ( rst_n            ), 
          .ck               ( ck_r             ), 
          .ck_n             ( ck_n_r           ), 
          .cke              ( cke_r [dwc_rnk]  ), 
  	       .odt              ( odt_r [dwc_rnk]  ),
          .cs_n             ( cs_n_r[dwc_rnk]  ),
          .ba               ( ba_r             ),
  	       .a                ( a_r              ),
          .dm               ( dm               ), 
          .dqs              ( dqs              ), 
          .dqs_n            ( dqs_n            ), 
`ifdef LPDDR4MPHY
          .address_copy     (address_copy      ),
`endif    
          .dq               ( dq               )
`ifndef DDR4
          , 
          .ras_n            ( ras_n_r          ), 
          .cas_n            ( cas_n_r          ), 
          .we_n             ( we_n_r           )
  `ifdef VMM_VERIF
  	      ,
  	      .speed_grade      ( speed_grade      )
  `endif
  `ifdef DDR3
          ,
          .parity           ( parity_r          ),
          .alert_n          ( alert_n_r[dwc_rnk])
  `endif
  `ifdef LPDDR2
          ,
          .parity           ( parity_r          ),
          .alert_n          ( alert_n_r[dwc_rnk])
  `endif
`ifdef LPDDR3
          ,
          .parity           ( parity_r          ),
          .alert_n          ( alert_n_r[dwc_rnk])
  `endif
  `ifdef LPDDR4
          ,
          .parity           ( parity_r          ),
          .alert_n          ( alert_n_r[dwc_rnk])
  `endif
`else
  	      , 
          .c                ( c_r               ),
          .act_n            ( act_n_r           ),
          .parity           ( parity_r          ),
          .alert_n          ( alert_n_r[dwc_rnk]),
  	       .bg               ( bg_r              )
`endif
  	     );
       
      //---------------------------------------------------------------------------
      // registered DIMM and UDIMM address mirroring
      // Note: UDIMM address mirroring only happens on rank 1
      //--------------------------------------------------------------------------- 
      always @(*) begin
    	  rst_n_r  = rst_n;
    	  ck_r     = ck;
    	  ck_n_r   = ck_n;
    	  cke_r    = cke;
    	  odt_r    = odt;
    	  cs_n_r   = cs_n;
`ifndef DDR4
        ras_n_r  = ras_n;
        cas_n_r  = cas_n;
        we_n_r   = we_n;
`else
        c_r      = c;
        act_n_r  = act_n;
        parity_r = parity;
`endif
          
`ifdef DDR4
        // check pBG_WIDTH if 2 bits, udimm mirror mode and odd dimm; then bg from PUB is flipped.
`ifdef SDRAMx16
        bg_r     = bg;
`else        
        bg_r     = (pUDIMM_MIRROR == 1 && (pBG_WIDTH == 2) && ((pDIMM_NO % 2) == 1)) ?
                   {bg[0], bg[pBG_WIDTH-1]} : bg;   
`endif
        ba_r     = (pUDIMM_MIRROR == 1 && ((pDIMM_NO % 2) == 1)) ?
                   {ba[0], ba[1]} : ba;
        a_r      = (pUDIMM_MIRROR == 1 && ((pDIMM_NO % 2) == 1)) ?
                   {a[pADDR_WIDTH-1:14], a[11], a[12], a[13], a[10:9], a[7], a[8], a[5], a[6], a[3], a[4], a[2:0]} :
                   a;
`else
       ba_r      = (pUDIMM_MIRROR == 1 && ((pDIMM_NO % 2) == 1)) ?
                   {ba[pDRAM_BANK_WIDTH-1], ba[0], ba[1]} : ba;
  `ifdef LPDDR4MPHY
     `ifdef DWC_DDR_UDIMM_EN 
        a_r       = (pUDIMM_MIRROR == 1 && ((pDIMM_NO % 2) == 1)) ?
                    {a[pADDR_WIDTH-1:9], a[7], a[8], a[5], a[6], a[3], a[4], a[2:0]} :
                    a;
     `else
        a_r       = a;
     `endif
  `else
     a_r       = (pUDIMM_MIRROR == 1 && ((pDIMM_NO % 2) == 1)) ?
                 {a[pADDR_WIDTH-1:9], a[7], a[8], a[5], a[6], a[3], a[4], a[2:0]} :
                 a;
  `endif
`endif 
      end
    end // block: dwc_rank
endgenerate
   
      
  //---------------------------------------------------------------------------
  // alert_n is returned from RDIMM or from DRAM based on configuration
  //---------------------------------------------------------------------------
  assign alert_n = (&alert_n_r);
  
endmodule // ddr_dimm

