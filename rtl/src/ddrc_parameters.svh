//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/ddrc_parameters.svh#2 $
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

// ----------------------------------------------------------------------------
//                              Description
// This file provides all of the parameters required to configure the
// legacy Intelli DDR Memory Controller and PHY.
// ----------------------------------------------------------------------------
// This part prevents this file from being loaded multiple times
//  (which is necessary, since it will be included in most RTL files.)

`ifndef __GUARD__DDRC_PARAMETERS__SVH__
`define __GUARD__DDRC_PARAMETERS__SVH__


//------------------------------------------------------------------------------
// ECC related defines
//------------------------------------------------------------------------------

`define MEMC_SECDED_ECC_WIDTH_BITS  8   // Width of the secded ECC lane
   `define MEMC_ECC_SYNDROME_WIDTH    `MEMC_DRAM_DATA_WIDTH + `MEMC_SECDED_ECC_WIDTH_BITS

// Advanced ECC poison register width, = DRAM DATA WIDTH * Number of beats of one ECC code
//  Number of beats is 2 in FR1:1; Number of beats is 4 in FR1:2
`define ECC_POISON_REG_WIDTH   `MEMC_DRAM_TOTAL_DATA_WIDTH*(2*`MEMC_FREQ_RATIO)

// define InlineECC command type
// as used in ddrc_ctrl.v for always there outputs
   `define  IE_RD_TYPE_BITS   1
   `define  IE_WR_TYPE_BITS   1


`define  IE_RD_TYPE_RD_N   2'b00
`define  IE_RD_TYPE_RD_E   2'b01
`define  IE_RD_TYPE_RE_B   2'b10

`define  IE_WR_TYPE_WD_N   2'b00
`define  IE_WR_TYPE_WD_E   2'b01
`define  IE_WR_TYPE_WE_BW  2'b10

//------------------------------------------------------------------------------
// Derived parameters: calculated from above
//------------------------------------------------------------------------------

//-------
// Timing Optimization parameters
//-------
  `define MEMC_SPECIAL_IH_FIFO      1  // replicates IH flops to internal modules to reduce loading

`define MEMC_DCERRFIELD           (`MEMC_DCERRBITS-1):0
`define MEMC_WRCMD_ENTRIES_ADDR   (`MEMC_WRCMD_ENTRY_BITS-1):0     // addressing NUM_WRCMD_ENTRIES
                                                                   //  doubled for the 1X clock domain
// Defines For IH ADDRESS MAP

// The following are the address map base offsets
`define UMCTL2_AM_RANK_BASE 6
`define UMCTL2_AM_BANKGROUP_BASE 2
`define UMCTL2_AM_BANK_BASE 2
`define UMCTL2_AM_COLUMN_BASE 0
`define UMCTL2_AM_ROW_BASE 6
`define UMCTL2_AM_DATACHANNEL_BASE 2
`define UMCTL2_AM_CID_BASE 4

 // This prevents multiply-defined compile warnings due to loading this
 //  file repeatedly
 `define MEMC_INCLUDE_DDRC_PARAMETERS 1

`endif // __GUARD__DDRC_PARAMETERS__SVH__
