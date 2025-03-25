//Revision: $Id: //dwh/ddr_iip/ictl/dev/DWC_ddr_umctl2/src/DWC_ddr_umctl2_cc_constants.svh#43 $
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


`ifndef __GUARD__DWC_DDR_UMCTL2_CC_CONSTANTS__SVH__
`define __GUARD__DWC_DDR_UMCTL2_CC_CONSTANTS__SVH__


//--------------------------------------------------------------------------
//  !!!!!!!!!!!!!
//  !  WARNING  !
//  !!!!!!!!!!!!!
// This file is auto-generated and MUST NOT be manually modified.
//--------------------------------------------------------------------------


// Name:         UCTL_DDR_PRODUCT
// Default:      DDR Enhanced Memory Controller (uMCTL2) 
//               (<DWC-UNIVERSAL-DDR-MCTL2-MP feature authorize> ? 0 : ( <DWC-UNIVERSAL-DDR-PCTL2 feature 
//               authorize> ? 1 : ( <DWC-AP-UNIVERSAL-DDR-MCTL2 feature authorize> ? 2 : 0 ) 
//               ))
// Values:       DDR Enhanced Memory Controller (uMCTL2) (0), DDR Enhanced Protocol 
//               Controller (uPCTL2) (1), Automotive DDR Enhanced Memory Controller 
//               (AP_uMCTL2) (2), DDR Enhanced Performance Memory Controller (uMCTL2P) 
//               (3)
// Enabled:      (<DWC-UNIVERSAL-DDR-MCTL2-MP feature authorize> || 
//               <DWC-UNIVERSAL-DDR-PCTL2 feature authorize> || <DWC-AP-UNIVERSAL-DDR-MCTL2 feature 
//               authorize> || <DWC-UNIVERSAL-DDR-MCTL2-P feature authorize>) == 1
// 
// Specifies the product chosen. 
// For each product a license is requires as specified: 
//  - DDR Enhanced Memory Controller (uMCTL2) requires DWC-UNIVERSAL-DDR-MCTL2-MP license. 
//  - DDR Enhanced Protocol Controller (uPCTL2) requires DWC-UNIVERSAL-DDR-PCTL2 license. 
//  - Automotive DDR Enhanced Memory Controller (AP_uMCTL2) requires DWC-AP-UNIVERSAL-DDR-MCTL2 license.
`define UCTL_DDR_PRODUCT 0


// Name:         ADV_FEATURE_PKG_EN
// Default:      1 (<DWC-ADV-FEATURE-PKG-FOR-UMCTL2 feature authorize> ? 1 : 0)
// Values:       0 1
// Enabled:      0
// 
// Specifies if the advanced feature package is enabled.
`define ADV_FEATURE_PKG_EN 1


// Name:         MEMC_DRAM_DATA_WIDTH
// Default:      16
// Values:       8 16 24 32 40 48 56 64 72
// 
// Specifies the memory data width of the DQ signal to SDRAM in bits. For HIF configurations, this can be any multiple of 
// 8, with a maximum of 72. For AXI/AHB configurations, it must be a power of 2 (8, 16, 32, 64). 
//  - If ECC is enabled, this parameter must be set to 16, 32 or 64, and the ECC byte is additional to the width specified 
//  here. 
//  - If ECC is disabled, a non-power-of-2 configuration allows the user to inject their own ECC at the HIF interface if 
//  required.
`define MEMC_DRAM_DATA_WIDTH 64


// Name:         UMCTL2_INCL_ARB
// Default:      1 (MEMC_DRAM_DATA_WIDTH == 8 || MEMC_DRAM_DATA_WIDTH == 16 || 
//               MEMC_DRAM_DATA_WIDTH == 32 || MEMC_DRAM_DATA_WIDTH == 64)
// Values:       0, 1
// Enabled:      MEMC_DRAM_DATA_WIDTH == 8 || MEMC_DRAM_DATA_WIDTH == 16 || 
//               MEMC_DRAM_DATA_WIDTH == 32 || MEMC_DRAM_DATA_WIDTH == 64
// 
// Adds multiport support to DWC_ddr_umctl2. You can select this option only if the DRAM data width (MEMC_DRAM_DATA_WIDTH) 
// is a power of 2 (8, 16, 32, or 64).
`define UMCTL2_INCL_ARB


// Name:         UPCTL2_EN
// Default:      0 ((UCTL_DDR_PRODUCT == 0 || UCTL_DDR_PRODUCT > 1) ? 0 : 1)
// Values:       0, 1
// Enabled:      0
// 
// Enables in-order controller. In this mode reads and writes are scheduled in order.
`define UPCTL2_EN 0


// `define UPCTL2_EN_1


// Name:         UMCTL_A_HIF
// Default:      0 ((UMCTL2_INCL_ARB == 0) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// In single port mode if the multiport is not enabled 
// the application port reduces to HIF interface.
`define UMCTL_A_HIF 0


// `define UMCTL_A_HIF_1



// Name:         UMCTL2_DUAL_HIF
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_OPT_TIMING == 1 && UPCTL2_EN==0
// 
// Enables the support for Dual HIF command feature. 
//  - This feature converts HIF single command channel into separate HIF command channels for Read and Write commands.  
// RMW commands are performed on the Write HIF command channel. 
//  - Read/Write arbitration performed by the PA does not occur as there are  
// separate Read and Write channels for the PA to drive. 
// This feature can only be enabled if the logic to optimize timing over scheduling efficiency is enabled 
// (MEMC_OPT_TIMING==1). 
// Enabling this logic improves the SDRAM utilization, depending on your traffic profile. 
// However, it increases the overall area due to additional logic.
`define UMCTL2_DUAL_HIF 1


`define UMCTL2_DUAL_HIF_1


// Name:         UMCTL2_A_NPORTS
// Default:      1
// Values:       1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
// Enabled:       UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Includes logic to implement 1 to 16 host  
// ports. Host port 0 is always included.
`define UMCTL2_A_NPORTS 1


// Name:         UMCTL2_A_NPORTS_0
// Default:      1 ((UMCTL2_A_NPORTS == (0+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
`define UMCTL2_A_NPORTS_0

// Name:         UMCTL2_A_NPORTS_1
// Default:      0 ((UMCTL2_A_NPORTS == (1+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_1

// Name:         UMCTL2_A_NPORTS_2
// Default:      0 ((UMCTL2_A_NPORTS == (2+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_2

// Name:         UMCTL2_A_NPORTS_3
// Default:      0 ((UMCTL2_A_NPORTS == (3+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_3

// Name:         UMCTL2_A_NPORTS_4
// Default:      0 ((UMCTL2_A_NPORTS == (4+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_4

// Name:         UMCTL2_A_NPORTS_5
// Default:      0 ((UMCTL2_A_NPORTS == (5+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_5

// Name:         UMCTL2_A_NPORTS_6
// Default:      0 ((UMCTL2_A_NPORTS == (6+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_6

// Name:         UMCTL2_A_NPORTS_7
// Default:      0 ((UMCTL2_A_NPORTS == (7+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_7

// Name:         UMCTL2_A_NPORTS_8
// Default:      0 ((UMCTL2_A_NPORTS == (8+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_8

// Name:         UMCTL2_A_NPORTS_9
// Default:      0 ((UMCTL2_A_NPORTS == (9+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_9

// Name:         UMCTL2_A_NPORTS_10
// Default:      0 ((UMCTL2_A_NPORTS == (10+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_10

// Name:         UMCTL2_A_NPORTS_11
// Default:      0 ((UMCTL2_A_NPORTS == (11+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_11

// Name:         UMCTL2_A_NPORTS_12
// Default:      0 ((UMCTL2_A_NPORTS == (12+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_12

// Name:         UMCTL2_A_NPORTS_13
// Default:      0 ((UMCTL2_A_NPORTS == (13+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_13

// Name:         UMCTL2_A_NPORTS_14
// Default:      0 ((UMCTL2_A_NPORTS == (14+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_14

// Name:         UMCTL2_A_NPORTS_15
// Default:      0 ((UMCTL2_A_NPORTS == (15+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_15


// Name:         UMCTL2_PORT_0
// Default:      1 ((UMCTL2_A_NPORTS >= (0+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
`define UMCTL2_PORT_0

// Name:         UMCTL2_PORT_1
// Default:      0 ((UMCTL2_A_NPORTS >= (1+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_1

// Name:         UMCTL2_PORT_2
// Default:      0 ((UMCTL2_A_NPORTS >= (2+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_2

// Name:         UMCTL2_PORT_3
// Default:      0 ((UMCTL2_A_NPORTS >= (3+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_3

// Name:         UMCTL2_PORT_4
// Default:      0 ((UMCTL2_A_NPORTS >= (4+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_4

// Name:         UMCTL2_PORT_5
// Default:      0 ((UMCTL2_A_NPORTS >= (5+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_5

// Name:         UMCTL2_PORT_6
// Default:      0 ((UMCTL2_A_NPORTS >= (6+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_6

// Name:         UMCTL2_PORT_7
// Default:      0 ((UMCTL2_A_NPORTS >= (7+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_7

// Name:         UMCTL2_PORT_8
// Default:      0 ((UMCTL2_A_NPORTS >= (8+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_8

// Name:         UMCTL2_PORT_9
// Default:      0 ((UMCTL2_A_NPORTS >= (9+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_9

// Name:         UMCTL2_PORT_10
// Default:      0 ((UMCTL2_A_NPORTS >= (10+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_10

// Name:         UMCTL2_PORT_11
// Default:      0 ((UMCTL2_A_NPORTS >= (11+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_11

// Name:         UMCTL2_PORT_12
// Default:      0 ((UMCTL2_A_NPORTS >= (12+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_12

// Name:         UMCTL2_PORT_13
// Default:      0 ((UMCTL2_A_NPORTS >= (13+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_13

// Name:         UMCTL2_PORT_14
// Default:      0 ((UMCTL2_A_NPORTS >= (14+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_14

// Name:         UMCTL2_PORT_15
// Default:      0 ((UMCTL2_A_NPORTS >= (15+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_15

 
// Name:         UMCTL2_A_TYPE_0
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_0 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_0 3
 
// Name:         UMCTL2_A_TYPE_1
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_1 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_1 1
 
// Name:         UMCTL2_A_TYPE_2
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_2 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_2 1
 
// Name:         UMCTL2_A_TYPE_3
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_3 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_3 1
 
// Name:         UMCTL2_A_TYPE_4
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_4 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_4 1
 
// Name:         UMCTL2_A_TYPE_5
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_5 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_5 1
 
// Name:         UMCTL2_A_TYPE_6
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_6 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_6 1
 
// Name:         UMCTL2_A_TYPE_7
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_7 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_7 1
 
// Name:         UMCTL2_A_TYPE_8
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_8 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_8 1
 
// Name:         UMCTL2_A_TYPE_9
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_9 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_9 1
 
// Name:         UMCTL2_A_TYPE_10
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_10 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_10 1
 
// Name:         UMCTL2_A_TYPE_11
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_11 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_11 1
 
// Name:         UMCTL2_A_TYPE_12
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_12 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_12 1
 
// Name:         UMCTL2_A_TYPE_13
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_13 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_13 1
 
// Name:         UMCTL2_A_TYPE_14
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_14 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_14 1
 
// Name:         UMCTL2_A_TYPE_15
// Default:      AXI3
// Values:       AXI3 (1), AHB - uMCTL2 only (2), AXI4 (3)
// Enabled:      UMCTL2_PORT_15 == 1 && UMCTL2_INCL_ARB == 1
// 
// Defines the interface type for the controller. 
// application port n.
`define UMCTL2_A_TYPE_15 1


`define THEREIS_AXI_PORT 1


`define THEREIS_AXI4_PORT 1


`define THEREIS_AHB_PORT 0


// Name:         MEMC_NUM_RANKS_GT4_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// 
// Enables support for MEMC_NUM_RANKS greater than 4. 
// Includes supporting UMCTL2_NUM_LRANKS_TOTAL=16 support as well. 
// Only for Internal Testing within Synopsys.
`define MEMC_NUM_RANKS_GT4_INTERNAL_TESTING 0


// Name:         MEMC_NUM_RANKS
// Default:      1
// Values:       1 (1), 2 (2), 4 (4), 8 - Reserved (8), 16 - Reserved (16)
// 
// Specifies the maximum number of ranks supported by DWC_ddr_umctl2 (that is, the maximum number of 
// independently-controllable chip selects).
`define MEMC_NUM_RANKS 2


// Name:         MEMC_DDR2
// Default:      1
// Values:       0, 1
// Enabled:      0
// 
// Enables DDR2 mode. 
// The value of this parameter is set to 1 for all configurations, and is shown here for completeness.
`define MEMC_DDR2


// Name:         MEMC_DDR3
// Default:      1
// Values:       0, 1
// 
// Enables DDR3 mode.
`define MEMC_DDR3


`define MEMC_DDR3_EN 1


// Name:         MEMC_DDR4
// Default:      0
// Values:       0, 1
// Enabled:      (MEMC_DDR3 == 1) && (MEMC_MOBILE == 0) && 
//               (<DWC-DDR4-ADD-ON-FOR-UMCTL2-MP feature authorize> == 1)
// 
// Enables DDR4 mode. An additional license is required to enable this feature. In addition, the hardware parameter 
// MEMC_DDR3 must also be selected if DDR4 is required. mDDR and DDR4 cannot be enabled together.
`define MEMC_DDR4


`define MEMC_DDR4_EN 1


// Name:         MEMC_MOBILE
// Default:      0
// Values:       0, 1
// 
// Enables mobile DDR (mDDR, LPDDR) mode.
// `define MEMC_MOBILE


`define MEMC_MOBILE_EN 0


// Name:         MEMC_LPDDR2
// Default:      0
// Values:       0, 1
// 
// Enables LPDDR2 mode.
// `define MEMC_LPDDR2


`define MEMC_LPDDR2_EN 0


// Name:         MEMC_LPDDR3
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_LPDDR2==1 && MEMC_DRAM_DATA_WIDTH%16 == 0
// 
// Enables LPDDR3 mode.
// `define MEMC_LPDDR3


`define MEMC_LPDDR3_EN 0


// Name:         MEMC_LPDDR4
// Default:      0
// Values:       0, 1
// Enabled:      (MEMC_LPDDR2 == 1 && MEMC_LPDDR3 == 1 && MEMC_MOBILE == 0 && 
//               MEMC_DRAM_DATA_WIDTH%16 == 0 && (<DWC-LPDDR4-ADD-ON-FOR-UMCTL2 feature 
//               authorize> == 1))
// 
// Enables LPDDR4 mode.
// `define MEMC_LPDDR4


`define MEMC_LPDDR4_EN 0




// Name:         MEMC_BURST_LENGTH
// Default:      BL8 - HIF transaction size corresponds to SDRAM burst length 8 
//               (MEMC_LPDDR4 == 1 ? 16 : 8)
// Values:       BL4 - uMCTL2 only - HIF transaction size corresponds to SDRAM burst 
//               length 4 (4), BL8 - HIF transaction size corresponds to SDRAM burst 
//               length 8 (8), BL16 - HIF transaction size corresponds to SDRAM burst 
//               length 16 (16)
// 
// Defines the supported burst length. This parameter specifies the size of a transaction on the host interface (HIF).  
// This can be equivalent to a SDRAM burst length of either 4 or 8 or 16.  
// The actual SDRAM burst length to be used can be set separately, using the register MSTR.burst_rdwr. 
// Note the following restrictions: 
//  - BL4 controller is not supported in MEMC_FREQ_RATIO=2 (1:2). 
//  - BL4 controller does not support DDR3/DDR4 in full bus width (as SDRAM BL=8 only), so requires 
//  MEMC_DRAM_DATA_WIDTH%16=0 to support half bus width. 
//  - BL4 controller does not support LPDDR3 in full bus width (as SDRAM BL=8 only), so requires MEMC_DRAM_DATA_WIDTH%32=0 
//  to support half bus width. 
//  - BL4 controller does not support LPDDR4 (as SDRAM BL=16 only). 
//  - BL16 controller is required only for full bus width and mDDR, LPDDR2 or LPDDR4 (as these support SDRAM BL=16).
`define MEMC_BURST_LENGTH 8



// Name:         MEMC_ECC_SUPPORT
// Default:      No ECC
// Values:       No ECC (0), SECDED ECC (1), Advanced ECC (2)
// Enabled:      MEMC_DRAM_DATA_WIDTH == 16 || MEMC_DRAM_DATA_WIDTH == 32 || 
//               MEMC_DRAM_DATA_WIDTH == 64
// 
// Enables the ECC support. 
//  
// This feature is available only when the DRAM bus width is 16, 32, or 64 bits. The following are the supported ECC 
// types: 
//  - Single-beat SECDED ECC 
//  - Advanced ECC 
// ECC is available in the following modes: 
//  - Full Bus Width (FBW) 
//  - Half Bus Width (HBW) 
//  - Quarter Bus Width (QBW) 
// The following ECC codes apply for Single-beat SECDED ECC: 
//  - For a 64-bit SDRAM data width, the SDRAM data + ECC width is 64+8 (FBW), 32+7 (HBW) and 16+6 (QBW). 
//  - For a 32-bit SDRAM data width, the SDRAM data + ECC width is 32+7 (FBW), 16+6 (HBW) and 8+5 (QBW). 
//  - For a 16-bit SDRAM data width, the SDRAM data + ECC width is 16+6 (FBW) and 8+5 (HBW). 
// For Advanced ECC:  
//  - The ECC code always is 128+16. 
//  - When the SDRAM data width is less than 64, unused bytes in the data word are padded with 0 so that ECC is calculated 
//  over 128 data bits.
`define MEMC_ECC_SUPPORT 0


// Name:         MEMC_SIDEBAND_ECC
// Default:      0 (MEMC_ECC_SUPPORT>0)
// Values:       0, 1
// Enabled:      MEMC_ECC_SUPPORT>0
// 
// Enables Sideband ECC. 
//  
// When enabled an additional data bus for ECC is used, so the actual DRAM data width is greater than MEMC_DRAM_DATA_WIDTH.
// `define MEMC_SIDEBAND_ECC


`define MEMC_SIDEBAND_ECC_EN 0



// Name:         UMCTL2_HIF_INLINE_ECC_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// 
// Enables the support for Inline ECC feature in non-Arbiter configurations. 
// Only for Internal Testing within Synopsys.
`define UMCTL2_HIF_INLINE_ECC_INTERNAL_TESTING 0


// Name:         MEMC_INLINE_ECC
// Default:      0
// Values:       0, 1
// Enabled:      (MEMC_ECC_SUPPORT==1 && MEMC_FREQ_RATIO!=1 && UPCTL2_EN==0 && 
//               (MEMC_DDR3 || MEMC_DDR4 || MEMC_LPDDR2 || MEMC_LPDDR3 || MEMC_LPDDR4) &&  
//               UMCTL2_PARTIAL_WR==1 && UMCTL2_DUAL_HIF==0 && MEMC_BYPASS==0 && 
//               UMCTL2_DDR4_MRAM_EN==0 && MEMC_OPT_TIMING==1)
// 
// Enables Inline ECC. 
//  
// When enabled does not requires an additional data bus for ECC so  the actual DRAM data width is equal to 
// MEMC_DRAM_DATA_WIDTH. 
// ECC parity is stored with the data without using a dedicated sideband memory device. 
// UMCTL2_HIF_INLINE_ECC_INTERNAL_TESTING=0 always. 
// UMCTL2_HIF_INLINE_ECC_INTERNAL_TESTING=1 only for internal testing within Synopsys.
// `define MEMC_INLINE_ECC


`define MEMC_INLINE_ECC_EN 0


// Name:         MEMC_IH_TE_PIPELINE
// Default:      0 (MEMC_INLINE_ECC+0)
// Values:       0, 1
// Enabled:      MEMC_INLINE_ECC==1
// 
// Adds pipeline between IH and TE to optimizate timing, it can be enabled when Inline ECC is enabled.
// `define MEMC_IH_TE_PIPELINE


// Name:         MEMC_ECCAP
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_INLINE_ECC==1
// 
// Enables address parity checking within Inline ECC.
// `define MEMC_ECCAP


`define MEMC_ECCAP_EN 0


// Name:         MEMC_QBUS_SUPPORT
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DRAM_DATA_WIDTH%32 == 0
// 
// Enables support for quarter-bus mode. 
// You can select this option only when the memory data width is a multiple of 32 bits.
// `define MEMC_QBUS_SUPPORT


// Name:         MEMC_USE_RMW
// Default:      1 (((MEMC_ECC_SUPPORT>0 || MEMC_DDR4==1 || MEMC_LPDDR4==1) && 
//               UPCTL2_EN==0) ? 1 : 0)
// Values:       0, 1
// Enabled:      ( (MEMC_ECC_SUPPORT>0 || MEMC_DDR4==1 || MEMC_LPDDR4==1) && 
//               THEREIS_AHB_PORT==0 && UPCTL2_EN==0)
// 
// Enables read-modify-write commands. 
// By default, this is set for ECC configurations, and unset for non-ECC configurations. 
// If read-modify-write commands are disabled, sub-sized write accesses of size less than the full memory width are not 
// allowed. 
//  - For DDR4 HIF configurations, if MEMC_USE_RMW is disabled, only full BL8/BC4 bursts are allowed if using write DBI 
//  (DBICTL.wr_dbi_en = 1), X4 devices or data masks disable (DBICTL.dm_en = 0). 
//  - For DDR4 AXI/AHB configurations, MEMC_USE_RMW must be enabled if using write DBI (DBICTL.wr_dbi_en = 1), X4 devices 
//  or data masks disable (DBICTL.dm_en = 0). 
//  - For LPDDR4 HIF configurations, if MEMC_USE_RMW is disabled, only full BL16/BL8/BC4 bursts are allowed if data masks 
//  disable (DBICTL.dm_en = 0). 
//  - For LPDDR4 AXI/AHB configurations, MEMC_USE_RMW must be enabled if data masks disable (DBICTL.dm_en = 0). 
//  - For ECC/DDR4/LPDDR4 AXI/AHB configurations, if there is an AHB port, MEMC_USE_RMW is enabled by default (RMW 
//  commands are required due to AHB EBT support).
`define MEMC_USE_RMW


`define MEMC_USE_RMW_EN 1


`define MEMC_USE_RMW_OR_MEMC_INLINE_ECC


// Name:         UMCTL2_SBR_EN
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB==1 && MEMC_ECC_SUPPORT>0 && MEMC_USE_RMW==1
// 
// Enables the ECC scrubber block. 
// Instantiates the ECC scrubber block (SBR) that executes periodic background read commands to the DDRC. If enabled, 
// SBR consumes one of the ports of the Port Arbiter (PA). Internally SBR is always the last port. ECC support must be 
// enabled to use this feature.
`define UMCTL2_SBR_EN 0


// `define UMCTL2_SBR_EN_1


// Name:         UMCTL2_REG_SCRUB_INTERVALW
// Default:      13
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the width of the SBRCTL.scrub_interval register
`define UMCTL2_REG_SCRUB_INTERVALW 13


// Name:         MEMC_PROG_FREQ_RATIO
// Default:      Hardware Configurable Frequency Ratio Only
// Values:       Hardware Configurable Frequency Ratio Only (0), Software 
//               Programmable Frequency Ratio (1)
// 
// Defines whether the frequency ratio is programmable through software. 
//  - If Hardware Configurable Frequency Ratio Only option is selected, you can select the frequency ratio only through 
//  hardware, by using the MEMC_FREQ_RATIO parameter. 
//  - If Software Programmable Frequency Ratio option is selected, you can  select the frequency ratio only through 
//  software, by using the MSTR.frequency_ratio register.
`define MEMC_PROG_FREQ_RATIO 0


// Name:         MEMC_FREQ_RATIO
// Default:      1:1 frequency ratio (MEMC_PROG_FREQ_RATIO == 0 ? 1 : 2)
// Values:       1:1 frequency ratio (1), 1:2 frequency ratio (2)
// Enabled:      MEMC_PROG_FREQ_RATIO==0
// 
// Defines the frequency ratio between the controller clock and the SDRAM clock. 
//  - If 1:1 mode is chosen, the controller runs at the same speed as the SDRAM clock. 
//  - If 1:2 mode is chosen, the controller runs at half the speed of the SDRAM clock.
`define MEMC_FREQ_RATIO 2


// Name:         MEMC_NUM_CLKS
// Default:      1
// Values:       1 2 3 4
// 
// Specifies the maximum number of clocks supported by DWC_ddr_umctl2.
`define MEMC_NUM_CLKS 1


// Name:         UMCTL2_DFI_RDDATA_PER_BYTE
// Default:      1
// Values:       0, 1
// 
// Enables support for dfi_rddata/dfi_rddata_valid data slice independence 
// per byte lane. 
// This is a new feature introduced in DFI 3.0, which also applies to DFI 3.1. 
//  
// Enable this feature only if your PHY supports it.
`define UMCTL2_DFI_RDDATA_PER_BYTE


// Name:         UMCTL2_DFI_DATAEN_PER_NIBBLE
// Default:      0
// Values:       0, 1
// 
// Specifies the width of dfi_wrdata_en, dfi_rddata_en, and dfi_rddata_valid per nibble. 
// By default, the width of these signals are one bit per byte of SDRAM data. However, for PHYs supporting x4 devices, it 
// may be necessary to have a bit per nibble of SDRAM data. 
// Note: If this parameter is set, the controller does not support unaligned read data from the PHY, and the PHY must 
// drive all bits of dfi_rddata_valid together.
// `define UMCTL2_DFI_DATAEN_PER_NIBBLE


// Name:         UMCTL2_DFI_MASK_PER_NIBBLE
// Default:      0
// Values:       0, 1
// 
// Specifies the width of dfi_wrdata_mask per nibble 
// By default, the width of this signal is one bit per byte of DFI data. However, for PHYs supporting x4 devices, it may 
// be necessary to have a bit per nibble of DFI data.
// `define UMCTL2_DFI_MASK_PER_NIBBLE


// Name:         UMCTL2_RESET_WIDTH
// Default:      2 (MEMC_NUM_RANKS+0)
// Values:       1 2 4 8 16
// Enabled:      (MEMC_LPDDR4 == 1) ? 0 : 1
// 
// Specifies the width of dfi_reset_n required for LPDDR4, DDR3, and DDR4. 
// dfi_reset_n width = (UMCTL2_RESET_WIDTH * MEMC_FREQ_RATIO * (UMCTL2_SHARED_AC+1)). 
// According to DFI, this must be equal to the chip select width.
`define UMCTL2_RESET_WIDTH 2


// Name:         UMCTL2_DFI_DATA_CS_EN
// Default:      0 ((MEMC_LPDDR4 == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      (MEMC_LPDDR4 == 1) ? 0 : 1
// 
// Enables support for dfi_wrdata_cs/dfi_rddata_cs signals. 
// This is a new feature introduced in DFI 3.0, which also applies to DFI 3.1. 
//  
// Enable this feature only if your PHY supports it.
// `define UMCTL2_DFI_DATA_CS_EN



// Name:         UMCTL2_PARTIAL_WR
// Default:      1
// Values:       0, 1
// Enabled:      (UMCTL2_INCL_ARB==1 && MEMC_BURST_LENGTH==16 && MEMC_DDR4==1) ? 0 : 
//               1
// 
// Enables support for partial writes. 
// A partial write is where the number of HIF write data beats is less than the number 
// required for a normal (full) write for the MEMC_BURST_LENGTH. 
//  - When UMCTL2_PARTIAL_WR = 0, the DDRC issues the number of SDRAM bursts on the DDR interface that it would for a 
//  normal (full) write, but masks the unused data phases. 
//  - When UMCTL2_PARTIAL_WR = 1, the DDRC issues the minimum number of SDRAM bursts on the DDR interface required, 
//  dependent on the number of HIF write data beats and the HIF address alignment with respect to the SDRAM Column address - as 
//  SDRAM Writes must be sent BL-aligned.  
// This additional logic impacts the achievable synthesis timing, and increases the area.
`define UMCTL2_PARTIAL_WR


`define UMCTL2_PARTIAL_WR_EN 1



// Name:         UPCTL2_POSTED_WRITE_EN
// Default:      0
// Values:       0, 1
// Enabled:      UPCTL2_EN == 1 && UMCTL2_PARTIAL_WR == 1 && UMCTL2_INCL_ARB == 0
// 
// Enables posted writes support. 
//  
// In this mode write commands are scheduled without waiting for the HIF write data to be received. 
// Data beats must be presented at the HIF before the maximum allowed delay to ensure that DDR latencies are respected. 
// The Controller is always going to assert output hif_wdata_required one clock cycle before the maximum allowed delay. 
//  
// Feature requires partial write to be enabled (UMCTL2_PARTIAL_WR = 1). 
//  
// Feature is available only in designs where arbiter is not used (UMCTL2_INCL_ARB = 0).
`define UPCTL2_POSTED_WRITE_EN 0


// `define UPCTL2_POSTED_WRITE_EN_1


// Name:         MEMC_NO_OF_ENTRY
// Default:      32
// Values:       16 32 64
// 
// Specifies the depth (number of entries) of each CAM (read CAM and write CAM).
`define MEMC_NO_OF_ENTRY 64


// Name:         MEMC_NO_OF_BLK_CHANNEL
// Default:      4
// Values:       4 8 16
// Enabled:      (MEMC_INLINE_ECC_EN == 1) ? 1 : 0
// 
// Indicates the number of blocks that can be interleaved at DDRC input (HIF).  
// Enabled in Inline ECC mode.
`define MEMC_NO_OF_BLK_CHANNEL 4


`define MEMC_NO_OF_BLK_TOKEN 68


`define MEMC_BLK_TOKEN_BITS 7


`define MEMC_NO_OF_BRT 36


`define MEMC_NO_OF_BWT 36


// Name:         MEMC_BYPASS
// Default:      0
// Values:       0, 1
// Enabled:      UPCTL2_EN==0
// 
// Enables bypass for activate and read commands.
// `define MEMC_BYPASS


// Name:         UMCTL2_VPRW_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((((UMCTL2_INCL_ARB==1) && (THEREIS_AXI_PORT==1)) || 
//               (UMCTL2_INCL_ARB==0)) && (UPCTL2_EN==0))
// 
// Enables Variable Priority Read (VPR) and Variable Priority Write (VPW) features. 
//  
// On the read side, this feature allows the use of VPR in addition to Low Priority Read (LPR) and High Priority Read 
// (HPR) priority classes. 
// These three priority classes are intended to be mapped to three traffic classes as follows:  
//  - HPR (High Priority Read) - Low Latency 
//  - VPR (Variable Priority Read) - High Bandwidth 
//  - LPR (Low Priority Read) - Best Effort 
// The VPR commands start out behaving like LPR traffic. But, VPR commands have down-counting latency timers 
// associated with them. When the timer reaches 0, the commands marked with VPR are given higher priority over HPR and LPR 
// traffic. 
// On the write side, this feature allows the use of two priority classes in the controller:  
//  - VPW 
//  - NPW  
// These two priority classes are intended to be mapped to two traffic classes as follows: 
//  - VPW (Variable Priority Write) - High Bandwidth 
//  - NPW (Normal Priority Write) - Best Effort 
// The VPW traffic class commands start out behaving like NPW traffic. But, VPW commands have down-counting latency timers 
// 
// associated with them. When the timer reaches 0, the commands marked with VPW are given higher priority over NPW traffic.
`define UMCTL2_VPRW_EN


// Name:         UMCTL2_VPR_EN
// Default:      1 (UMCTL2_VPRW_EN == 1 ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_VPR_EN 
// Enables Variable Priority Read (VPR) 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1). 
// This feature allows the use of VPR in addition to Low Priority Read (LPR) and High Priority Read (HPR) priority 
// classes. 
// These 3 priority classes are intended to be mapped to three traffic classes as follows: 
//  - HPR (High Priority Read) - Low Latency 
//  - VPR (Variable Priority Read) - High Bandwidth 
//  - LPR (Low Priority Read) - Best Effort 
// The VPR commands start out behaving like LPR traffic. But VPR commands have down-counting latency timers 
// associated with them. When the timer reaches 0, the commands marked with VPR are given higher priority over HPR and LPR 
// traffic.
`define UMCTL2_VPR_EN


`define UMCTL2_VPR_EN_VAL 1


// Name:         UMCTL2_VPW_EN
// Default:      1 (UMCTL2_VPRW_EN == 1 ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_VPW_EN 
// Enables Variable Priority Write (VPW). 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1). 
// This feature allows the use of two write priority classes in Controller: VPW and NPW. 
// These 2 priority classes are intended to be mapped to two traffic classes as follows: 
//  - VPW (Variable Priority Write) - High Bandwidth 
//  - NPW (Normal Priority Write) - Best Effort 
// The VPW traffic class commands start out behaving like NPW traffic. But VPW commands have down-counting latency timers 
// associated with them. When the timer reaches 0, the commands marked with VPW are given higher priority over NPW traffic.
`define UMCTL2_VPW_EN


`define UMCTL2_VPW_EN_VAL 1




// Name:         UMCTL2_PROGCHN
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_REG_DFI_OUT_VAL==1
// 
// UMCTL2_PROGCHN_EN: 
// Enables the programmable single channel/dual channel support. 
//  
// Only available in shared-AC dual data channel configurations.
// `define UMCTL2_PROGCHN


`define UMCTL2_PROGCHN_EN 0




// Name:         UMCTL2_SHAREDAC_LP4DUAL_COMB
// Default:      0
// Values:       0, 1
// Enabled:      ( ((MEMC_FREQ_RATIO==2) && (MEMC_CMD_RTN2IDLE==0) && 
//               (MEMC_ECC_SUPPORT==0) && (MEMC_DRAM_DATA_WIDTH <= 32) && (MEMC_NUM_RANKS < 4) && 
//               MEMC_MOBILE==0 && MEMC_DDR4==1 && UMCTL2_DFI_DATAEN_PER_NIBBLE==0 && 
//               UMCTL2_DFI_MASK_PER_NIBBLE==0 && UMCTL2_SBR_EN==0 && 
//               UMCTL2_FAST_FREQUENCY_CHANGE==0 && UMCTL2_DUAL_HIF==0 && MEMC_USE_RMW==0 && 
//               MEMC_PROG_FREQ_RATIO==0 && UMCTL2_NUM_LRANKS_TOTAL<8 && 
//               UMCTL2_CRC_PARITY_RETRY==0)     &&   (((MEMC_DDR4==1) || ((MEMC_LPDDR4==1) && 
//               (MEMC_ECC_SUPPORT==0) && (UMCTL2_SBR_EN==0) && (UMCTL2_DUAL_HIF==0) && 
//               (UMCTL2_NUM_LRANKS_TOTAL<8)))) )
// 
// Enables DDR4 Shared-AC and LPDDR4 Dual Channel combination.
// `define UMCTL2_SHAREDAC_LP4DUAL_COMB


`define UMCTL2_SHAREDAC_LP4DUAL_COMB_EN 0



// Name:         UMCTL2_DUAL_CHANNEL
// Default:      0 (UMCTL2_SHAREDAC_LP4DUAL_COMB)
// Values:       0, 1
// Enabled:      (UMCTL2_SHAREDAC_LP4DUAL_COMB==0 && (((MEMC_DDR4==1) && 
//               (MEMC_LPDDR2==0) && (MEMC_MOBILE==0) && (UMCTL2_PROGCHN==0) && 
//               (UMCTL2_DYN_BSM==0) && (MEMC_INLINE_ECC==0) && (UMCTL2_REGPAR_EN==0) && 
//               (UMCTL2_EXCL_ACCESS==0)) || ((MEMC_LPDDR4==1) && MEMC_DDR3==0 && 
//               (MEMC_ECC_SUPPORT==0) && (UMCTL2_SBR_EN==0) && (UMCTL2_DUAL_HIF==0) && 
//               (UMCTL2_NUM_LRANKS_TOTAL<8))))
// 
// Enables Dual Channel support.
// `define UMCTL2_DUAL_CHANNEL


`define UMCTL2_DUAL_CHANNEL_EN 0


// Name:         UMCTL2_SHARED_AC
// Default:      0 (UMCTL2_SHAREDAC_LP4DUAL_COMB)
// Values:       0, 1
// Enabled:      (UMCTL2_SHAREDAC_LP4DUAL_COMB==0 && 
//               (<DWC-SHARE-AC-ADD-ON-FOR-UMCTL2 feature authorize> == 1) && (THEREIS_AHB_PORT==0) && 
//               (UMCTL2_DDR4_MRAM_EN==0) && (MEMC_FREQ_RATIO==2) && (MEMC_CMD_RTN2IDLE==0) && 
//               (MEMC_ECC_SUPPORT==0) && (MEMC_DRAM_DATA_WIDTH <= 32) && (MEMC_NUM_RANKS < 
//               4) && (((MEMC_LPDDR2==0 && MEMC_LPDDR3==0) || 
//               (UMCTL2_PROGCHN_EN==1)) && (MEMC_LPDDR4==0)) && MEMC_MOBILE==0 && MEMC_DDR4==1 && 
//               UMCTL2_DFI_DATAEN_PER_NIBBLE==0 && UMCTL2_DFI_MASK_PER_NIBBLE==0 && 
//               UMCTL2_SBR_EN==0 && UMCTL2_FAST_FREQUENCY_CHANGE==0 && UMCTL2_DUAL_HIF==0 && 
//               MEMC_USE_RMW==0 && MEMC_PROG_FREQ_RATIO==0 && 
//               UMCTL2_CRC_PARITY_RETRY==0 && UMCTL2_DUAL_CHANNEL==0 && UMCTL2_OCPAR_EN==0 && (MEMC_NUM_CLKS < 
//               3) && UMCTL2_CID_WIDTH==0)
// 
// Enables the Dual Data Channel support with Shared-AC. 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1).
// `define UMCTL2_SHARED_AC


`define UMCTL2_SHARED_AC_EN 0


`define UMCTL2_NUM_DATA_CHANNEL 1



// `define UMCTL2_DUAL_DATA_CHANNEL


`define UMCTL2_NUM_DFI 1


`define UMCTL2_DFI_0

// `define UMCTL2_DFI_1


// `define UMCTL2_DUAL_DFI


`define UMCTL2_PHY_0


// `define UMCTL2_PHY_1


// `define UMCTL2_DDR4_DUAL_CHANNEL


// `define UMCTL2_LPDDR4_DUAL_CHANNEL



`define UMCTL2_NUM_CHNS_PER_DFI 1


// Name:         UMCTL2_DATA_CHANNEL_INTERLEAVE_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_NUM_DATA_CHANNEL==2) && (UMCTL2_INCL_ARB == 1))
// 
// Enables the Data Channel interleaving in XPI: 
//  - When enabled, each port drives dynamically both data channels based on the address. 
//  - When disabled, each port statically drives only one data channel based on software settings. 
// This feature is available only in designs where Shared-AC, DDR4 or LPDDR4 Dual Channel is used.
`define UMCTL2_DATA_CHANNEL_INTERLEAVE_EN 0


// `define UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1


// Name:         UMCTL2_OCPAR_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_INCL_ARB==1) && (THEREIS_AHB_PORT==0) && 
//               (UMCTL2_WDATA_EXTRAM==1))
// 
// Enables the On-Chip Parity feature. 
// Instantiates necessary logic to enable on-chip parity protection: address and data paths. 
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1) and external WDATA RAM is used 
// (UMCTL2_WDATA_EXTRAM=1). 
//  
// This feature is not supported if AHB is enabled.
`define UMCTL2_OCPAR_EN 0


// `define UMCTL2_OCPAR_EN_1






// Name:         UMCTL2_OCECC_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_INCL_ARB==1) && (THEREIS_AHB_PORT==0) && 
//               (THEREIS_PORT_DSIZE==0) && (THEREIS_PORT_USIZE==0) && (UMCTL2_DUAL_DATA_CHANNEL==0) && 
//               (UCTL_DDR_PRODUCT==2) && (UMCTL2_OCPAR_EN==0) && 
//               (MEMC_INLINE_ECC==1) && (UMCTL2_WDATA_EXTRAM==1))
// 
// Enables the On-Chip ECC feature. 
//  
// Instantiates necessary logic to enable on-chip ECC protection. 
// This feature is available only in designs where the Arbiter is used (UMCTL2_INCL_ARB=1), there are no upsized/downsized 
// ports, Inline-ECC is used (MEMC_INLINE_ECC=1), and external WDATA RAM is used (UMCTL2_WDATA_EXTRAM=1). 
// This feature is not supported if:. 
//  - AHB is enabled 
//  - OCPAR is enabled 
//  - Dual Channel is enabled
`define UMCTL2_OCECC_EN 0


// `define UMCTL2_OCECC_EN_1


// `define UMCTL2_OCECC_FEC_EN


// `define UMCTL2_OCPAR_OR_OCECC_EN_1



// Name:         UMCTL2_REGPAR_EN
// Default:      0
// Values:       0, 1
// Enabled:      ( ((MEMC_DDR3==1) || (MEMC_DDR4==1) || (MEMC_LPDDR3==1) || 
//               (MEMC_LPDDR4==1)) && (UCTL_DDR_PRODUCT==2))
// 
// //Enables Register Parity feature. 
//  
// Instantiates necessary logic to enable register parity protection.
`define UMCTL2_REGPAR_EN 0


// `define UMCTL2_REGPAR_EN_1


// Name:         UMCTL2_REGPAR_TYPE
// Default:      1 bit parity, calculated for all 32 bits
// Values:       1 bit parity, calculated for all 32 bits (0), 4 bit parity, one 
//               parity bit for each byte (1)
// Enabled:      UMCTL2_REGPAR_EN==1
// 
// Register Parity type: 
//  - 0: 1 bit parity, calculated for all 32 bits. 
//  - 1: 4 bit parity, one parity bit for each byte.
`define UMCTL2_REGPAR_TYPE 0


`define UMCTL2_REGPAR_TYPE_0


// Name:         UMCTL2_OCCAP_DDRC_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// 
// UMCTL2_DDRC_OCCAP_INTERNAL_TESTING: 
// Enables the support for OCCAP in non-Arbiter configs. 
// Only for Internal Testing within Synopsys.
`define UMCTL2_OCCAP_DDRC_INTERNAL_TESTING 0





// Name:         UMCTL2_OCCAP_EN
// Default:      0
// Values:       0, 1
// Enabled:      (((UMCTL2_INCL_ARB==1 && UMCTL2_DUAL_DATA_CHANNEL==0) || 
//               UMCTL2_OCCAP_DDRC_INTERNAL_TESTING==1) && (UCTL_DDR_PRODUCT==2) && 
//               (THEREIS_AHB_PORT==0))
// 
// Enables On-Chip Command/Address Path Protection feature. 
//  
// Instantiates necessary logic to enable on-chip command and address protection.
`define UMCTL2_OCCAP_EN 0


// `define UMCTL2_OCCAP_EN_1



// Name:         MEMC_CMD_RTN2IDLE
// Default:      0
// Values:       0, 1
// 
// Set this parameter to return all DFI signals to their idle state after the execution of each command. 
//  
// If you use a Synopsys DWC DDR3/2 PHY, DWC 2/3-Lite/mDDR PHY, DWC DDR multiPHY, DWC Gen2 DDR multiPHY or DWC DDR4 
// multiPHY, and the PHY parameter DWC_AC_CS_USE is not enabled, then the parameter DFI commands return to idle is required. In 
// this mode, CS_N of the SDRAM is tied to zero. 
//  
// Setting this parameter ensures that NOPs are sent on the DFI bus for all cycles where no other valid command is being 
// sent. 
//  
// In other cases it is recommended to disable this parameter, to avoid unnecessary toggling of pads and therefore reduce 
// power. 
//  
// Note: If this parameter is enabled, 2T mode is not supported.
// `define MEMC_CMD_RTN2IDLE


`define MEMC_CMD_RTN2IDLE_EN 0


// Name:         MEMC_OPT_TIMING
// Default:      1
// Values:       0, 1
// 
// Instantiates logic to optimize timing over scheduling efficiency. 
//  
// When enabled, this parameter has the following effects on the design: 
//    - Write enable signals are flopped in the Write Unit (WU), adding one cycle of latency from write data arriving to 
//    the write being eligible for service. 
//    - The Input Handler (IH) FIFO has flopped outputs, with the address mapping logic located before the FIFO, directly 
//    on the HIF address input (hif_cmd_addr). This has the effect of easing the internal timing paths, but increases the 
//    combinational logic on the HIF address bus input (for HIF configurations) or between the XPI/PA and the HIF address bus (for 
//    AXI/AHB configurations). 
//    - The address registers at the output of the IH FIFO are duplicated to reduce the loading.
`define MEMC_OPT_TIMING


`define MEMC_OPT_TIMING_EN 1


// Name:         MEMC_REG_DFI_OUT
// Default:      1
// Values:       0, 1
// Enabled:      MEMC_ECC_SUPPORT == 0
// 
// Enables registering of all DFI output signals. 
//  
// By default, all the DFI output signals are registered, to ensure that timing on the DFI interface is easily met. 
// However, by setting this parameter to 0, it is possible 
// to remove this registering stage, which improves the latency through the controller by one cycle. Set this to 0 only if 
// it can be guaranteed that the synthesis timing 
// of the DFI output signals between controller and PHY can be met in single cycle. 
//  
// If ECC support is desired (MEMC_ECC_SUPPORT > 0), then DFI outputs are required to be registered (MEMC_REG_DFI_OUT = 
// 1). 
//  
// It is possible to exclude DFI Write data signals from the registering stage by setting MEMC_REG_DFI_OUT_WR_DATA to 0. 
// For more information, see the  
// "Latency Analysis" section in the databook.
`define MEMC_REG_DFI_OUT


// Name:         MEMC_REG_DFI_OUT_WR_DATA
// Default:      1 (MEMC_REG_DFI_OUT==1 ? 1 : 0)
// Values:       0, 1
// Enabled:      MEMC_REG_DFI_OUT == 1 && UMCTL2_PROGCHN == 0
// 
// Enables registering of DFI write data outputs. 
//  
// By default, all the DFI outputs are registered, to ensure that timing on the DFI interface is easily met. However, by 
// setting this parameter to 0, it is possible 
// to remove the registering stage of the DFI Write data signals (dfi_wrdata_en, dfi_wrdata and dfi_wrdata_mask), while 
// maintaining the registering stage of all the other DFI 
// output signals. This should be set to 0 only if DFI Write Data signals can meet the single cycle synthesis timing 
// requirement between controller and PHY. This macro has a meaning  
// only when MEMC_REG_DFI_OUT is set to 1. 
//  
// Refer to the section titled "DFI Interface Registering Options and Associated Latency Impact" in the databook for more 
// details.
`define MEMC_REG_DFI_OUT_WR_DATA


`define MEMC_REG_DFI_OUT_VAL 1


`define MEMC_REG_DFI_OUT_WR_DATA_VAL 1


`define MEMC_REG_DFI_OUT_WR_DATA_VAL_EQ_1


`define UMCTL2_MAX_CMD_DELAY 3


`define UMCTL2_CMD_DELAY_BITS 2


// `define MEMC_DRAM_DATA_WIDTH_72_OR_MEMC_SIDEBAND_ECC


// Name:         UMCTL2_DQ_MAPPING
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR4 == 1 && MEMC_FREQ_RATIO==2
// 
// Enables DQ mapping for CRC.
// `define UMCTL2_DQ_MAPPING


// Name:         UMCTL2_CRC_PARITY_RETRY
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR4 == 1 && MEMC_INLINE_ECC == 0 && UPCTL2_EN == 0
// 
// Enables Retry for CRC/Parity error.
// `define UMCTL2_CRC_PARITY_RETRY


// Name:         UMCTL2_RETRY_CMD_FIFO_DEPTH
// Default:      16
// Values:       16 24 32 40 48
// Enabled:      MEMC_DDR4==1 && UMCTL2_CRC_PARITY_RETRY==1
// 
// Specifies the Retry Command FIFO depth (number of entries).
`define UMCTL2_RETRY_CMD_FIFO_DEPTH 16


// Name:         UMCTL2_RETRY_MAX_ADD_RD_LAT
// Default:      0 ((UMCTL2_CRC_PARITY_RETRY==1) ? 8 : 0)
// Values:       0 4 6 8 10 12 14 16
// Enabled:      UMCTL2_CRC_PARITY_RETRY==1
// 
// Specifies the maximum additional latency on dfi_rddata path for retry logic. 
// Defines a maximum number of pipeline stages to dfi_rddata_valid/dfi_rddata/dfi_rddata_dbi  
// before rest of internal uMCTL2 logic observes it. 
//  
// This parameter is required to compensate a potential longer delay in the PHY/PCB for the dfi_alert_n 
// signal compared to the read data signal. 
// Refer to your PHY/PCB behavior for calculating the recommended settings (in terms of core_ddrc_core_clk):  
// (Maximum Alert delay through PHY/PCB) - (Minimum Read data delay through PHY/PCB) + (PHY's max granularity of 
// dfi_rddata beats that can be corrupted before erroneous Read).
`define UMCTL2_RETRY_MAX_ADD_RD_LAT 0


// `define UMCTL2_RETRY_MAX_ADD_RD_LAT_EN


`define UMCTL2_RETRY_MAX_ADD_RD_LAT_LG2 0


`define UMCTL2_DFI_RDDATA_PER_BYTE_OR_RETRY_MAX_ADD_RD_LAT_EN


// Name:         UMCTL2_WDATA_EXTRAM
// Default:      1
// Values:       0, 1
// 
// Specifies the controller to use external or internal SRAM for write data.
`define UMCTL2_WDATA_EXTRAM


// Name:         UMCTL2_RETRY_WDATA_EXTERNAL_SRAM
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_CRC_PARITY_RETRY==1
// 
// Specifies whether the CRC_PARITY_RETRY functionality uses an internal FIFO or an external SRAM for write data.
// `define UMCTL2_RETRY_WDATA_EXTERNAL_SRAM


// Name:         UMCTL2_RETRY_WDATA_EXTRAM_DEPTH
// Default:      32 (UMCTL2_RETRY_CMD_FIFO_DEPTH * 2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the depth of retry write data RAM. It is an internal parameter provided in the GUI for information purpose, 
// and is derived from Retry Command FIFO depth (@UMCTL2_RETRY_CMD_FIFO_DEPTH).
`define UMCTL2_RETRY_WDATA_EXTRAM_DEPTH 32


// Name:         UMCTL2_RETRY_WDATA_EXTRAM_AW
// Default:      5 ([ <functionof> UMCTL2_RETRY_WDATA_EXTRAM_DEPTH ])
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the address width of retry write data RAM. It is an internal parameter provided in the GUI for information 
// purpose, and is derived from depth of retry write data RAM (@UMCTL2_RETRY_WDATA_EXTRAM_DEPTH).
`define UMCTL2_RETRY_WDATA_EXTRAM_AW 5



// Name:         UMCTL2_DDR4_MRAM_EN
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR4 == 1 && UPCTL2_EN == 0 && MEMC_NUM_RANKS<=4
// 
// Enables DDR4 support for Spin Torque MRAM (ST-MRAM). 
// This feature is under access control. For more information, contact Synopsys.
// `define UMCTL2_DDR4_MRAM_EN


// Name:         UMCTL2_HET_RANK
// Default:      0 ((UMCTL2_DDR4_MRAM_EN && (MEMC_NUM_RANKS == 2 || MEMC_NUM_RANKS 
//               == 4)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Provides heterogeneous density ranks support for MRAM.
// `define UMCTL2_HET_RANK


`define UMCTL2_HET_RANK_EN 0



// Name:         UMCTL2_HET_RANK_DDR34
// Default:      0
// Values:       0, 1
// Enabled:      (UMCTL2_SHARED_AC==0 && UMCTL2_DUAL_CHANNEL==0 && MEMC_DDR3==1 && 
//               UMCTL2_DDR4_MRAM_EN==0 && UMCTL2_CID_WIDTH==0 && (MEMC_NUM_RANKS>1)  
//               && (MEMC_NUM_RANKS<8) && MEMC_INLINE_ECC==0)
// 
// Provides heterogeneous density ranks support for DDR3/DDR4 protocls in limited usage case.
// `define UMCTL2_HET_RANK_DDR34




// `define UMCTL2_HET_RANK_RFC


// `define UMCTL2_DDR4_MRAM_EN_OR_HET_RANK_RFC




// Name:         UMCTL2_CID_WIDTH
// Default:      [CID width=0] No DDR4 3DS support
// Values:       [CID width=0] No DDR4 3DS support (0), [CID width=1] - DDR4 3DS 
//               support up to 2H (1), [CID width=2] - DDR4 3DS support up to 4H (2)
// Enabled:      MEMC_DDR4==1
// 
// Specifies the width of Chip ID (dfi_cid) for DDR4 3DS support. Set this to 0 if DDR4 3DS is not used.  
// This feature is under access control. For more information, contact Synopsys.
`define UMCTL2_CID_WIDTH 0


// `define UMCTL2_CID_EN


`define UMCTL2_MAX_NUM_STACKS 1


// Name:         UMCTL2_NUM_LRANKS_TOTAL
// Default:      2 ((MEMC_NUM_RANKS < UMCTL2_MAX_NUM_STACKS) ? UMCTL2_MAX_NUM_STACKS 
//               : MEMC_NUM_RANKS)
// Values:       1 2 4 8 16
// Enabled:      UMCTL2_CID_WIDTH>0
// 
// Specifies the maximum number of logical ranks supported by the controller. The minimum value is equal to MEMC_NUM_RANKS.
`define UMCTL2_NUM_LRANKS_TOTAL 2


`define UMCTL2_NUM_PR_CONSTRAINTS 0


// Name:         UMCTL2_CG_EN
// Default:      0
// Values:       0, 1
// 
// Enables clock gating. 
//  
// Set this parameter to 1 if clock gating is enabled during synthesis. It increases the proportion of registers that  
// have clock gating implemented. When set to 1, some gates are added in front of some registers in the design as data 
// enables. 
// These data enables are added to facilitate the insertion of clock gating by the synthesis tool. 
// Set this to 0 if clock gating  
// is not enabled during synthesis. Setting this parameter to 1 and not enabling clock gating during synthesis causes a  
// small negative impact on timing and area.
`define UMCTL2_CG_EN 0


// `define UMCTL2_CG_EN_1


// Name:         UMCTL2_RTL_ASSERTIONS_ALL_EN
// Default:      1
// Values:       0, 1
// 
// Enables all user executable RTL SystemVerilog assertions. This 
// parameter is enabled by default and it is recommended to keep it, especially in your testbenches. 
// These assertions are helpful to identify unexpected input stimulus, wrong register values and bad 
// programming sequences that can commonly occur in your environments. 
// You can disable this parameter, if the RTL fails when running gate level simulations or when using  
// unsupported simulators.
`define UMCTL2_RTL_ASSERTIONS_ALL_EN


// Name:         UMCTL2_FAST_FREQUENCY_CHANGE
// Default:      0
// Values:       0, 1
// 
// Provides optional hardware to enable fast frequency change.
// `define UMCTL2_FAST_FREQUENCY_CHANGE


`define UMCTL2_FAST_FREQUENCY_CHANGE_EN 0


// Name:         UMCTL2_FREQUENCY_NUM
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_FAST_FREQUENCY_CHANGE == 1
// 
// Specifies the number of operational frequencies. When operation frequency number is: 
//  - 2: FREQ1 registers exist and you can switch the operation frequency between two frequencies with the fast frequency 
//  change. 
//  - 3: FREQ1/2 registers exist and you can switch the operation frequency among three frequencies with the fast 
//  frequency change. 
//  - 4: FREQ1/2/3 registers exist and you can switch the operation frequency among four frequencies with the fast 
//  frequency change.
`define UMCTL2_FREQUENCY_NUM 2



// Name:         UMCTL2_HWFFC_EN
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR4_OR_LPDDR4 == 1 && UMCTL2_FAST_FREQUENCY_CHANGE == 1 && 
//               UMCTL2_FREQUENCY_NUM > 1
// 
// Provides an optional hardware to enable Hardware Fast Frequency Change. 
// This is not supported for uPCTL2 HIF configurations.
// `define UMCTL2_HWFFC_EN


`define UMCTL2_HWFFC_EN_VAL 0


`define UMCTL2_AUTO_LOAD_MR


// Name:         UMCTL2_DFI_PHYUPD_WAIT_IDLE
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_LPDDR2 == 0 && MEMC_MOBILE == 0 && UMCTL2_SHARED_AC == 0 && 
//               UMCTL2_DUAL_CHANNEL == 0 && UPCTL2_EN == 0 && MEMC_DDR4 == 1 && 
//               UMCTL2_HWFFC_EN == 0 && UMCTL2_DDR4_MRAM_EN==0 && UMCTL2_CRC_PARITY_RETRY==0
// 
// When selected, provides optional hardware to wait for all banks of all ranks to be Idle prior to handshaking of 
// dfi_phyupd_req/dfi_phyupd_ack.
// `define UMCTL2_DFI_PHYUPD_WAIT_IDLE

`ifndef SYNTHESIS
 `define ASSERT_MSG_LABELED(label) `"ERROR: Assertion 'label' failed`" 
// Assertion with message reporting, to be used inside a module. 
// Add trailing ; where the macro is used

 `ifdef UMCTL2_RTL_ASSERTIONS_ALL_EN

  // Concurrent assertion synchronous to core clock:
  `define assert_coreclk(label,when) \
          label : assert property (@(core_ddrc_core_clk) disable iff (!core_ddrc_rstn || (core_ddrc_rstn === 1'bx)) when) else \
          $display(`ASSERT_MSG_LABELED(label))

  `define assert_yyclk(label,when) \
          label : assert property (@(co_yy_clk) disable iff (!core_ddrc_rstn || (core_ddrc_rstn === 1'bx)) when) else \
          $display(`ASSERT_MSG_LABELED(label))

  `define assert_rise_coreclk(label,when) \
          label : assert property (@(posedge core_ddrc_core_clk) disable iff (!core_ddrc_rstn) when) else \
          $display(`ASSERT_MSG_LABELED(label))
         
   // Concurrent assertion to check Xs:
  `define assert_x_value(label,data_valid,data) \
          label : assert property ( @(posedge clk) disable iff (!rst_n || (rst_n === 1'bx)) ((data_valid==1'b1) |-> (^data !== 1'bx)) ) else \
          $display(`ASSERT_MSG_LABELED(label))
 `else 
  `define assert_coreclk(label,when) \
          localparam _unused_ok_assert_``label = 1'b0
  `define assert_yyclk(label,when) \
          localparam _unused_ok_assert_``label = 1'b0
  `define assert_rise_coreclk(label,when) \
          localparam _unused_ok_assert_``label = 1'b0
  `define assert_x_value(label,data_valid,data) \
          localparam _unused_ok_assert_x_value_``label = 1'b0           
 `endif 

  // more templates can be added here
`endif //  `ifndef SYNTHESIS

    
// ----------------------------------------------------------------------------
// HIDDEN MACROS:


// Name:         MEMC_DEBUG_PINS
// Default:      0
// Values:       0, 1
// 
// MEMC_DEBUG_PINS 
// Include debug pins
// `define MEMC_DEBUG_PINS


// Name:         MEMC_PERF_LOG_ON
// Default:      0
// Values:       0, 1
// 
// Enables performance logging interface. 
//  
// When enabled, the performance logging signals are added to the list of output ports of the IIP.
// `define MEMC_PERF_LOG_ON


// Name:         MEMC_USE_XVP
// Default:      0
// Values:       0, 1
// 
// Use eXecutable Verification Plan flow
`define MEMC_USE_XVP 0


// Name:         MEMC_A2X_HW_LP_PINS
// Default:      0
// Values:       0, 1
// 
// MEMC_A2X_HW_LP_PINS 
// Include debug pins
// `define MEMC_A2X_HW_LP_PINS


// Name:         UMCTL2_REF_RDWR_SWITCH
// Default:      1 ((MEMC_NUM_RANKS > 1) ? 1 : 0)
// Values:       0, 1
// 
// UMCTL2_REF_RDWR_SWITCH_EN: 
// Enables switch to change RD/WR direction if there are no valid commands to a rank different from the one being 
// refreshed.
`define UMCTL2_REF_RDWR_SWITCH


// Name:         UMCTL2_REF_RDWR_SWITCH_EN
// Default:      1 ((UMCTL2_REF_RDWR_SWITCH==1) ? 1 : 0)
// Values:       0 1
// 
// UMCTL2_REF_RDWR_SWITCH: 
// Enables switch to change RD/WR direction if there are no valid commands to a rank different from the one being 
// refreshed.
`define UMCTL2_REF_RDWR_SWITCH_EN 1


// Name:         PIPELINE_REF_RDWR_SWITCH
// Default:      1
// Values:       0, 1
// 
// Enables pipelining of the path related to UMCTL2_REF_RDWR_SWITCH.
`define PIPELINE_REF_RDWR_SWITCH


// Name:         PIPELINE_REF_RDWR_SWITCH_EN
// Default:      1 ((PIPELINE_REF_RDWR_SWITCH==1) ? 1 : 0)
// Values:       0 1
// 
// Enables pipelining of the path related to UMCTL2_REF_RDWR_SWITCH.
`define PIPELINE_REF_RDWR_SWITCH_EN 1

// ----------------------------------------------------------------------------
// DERIVED MACROS:
// ----------------------------------------------------------------------------


// `define MEMC_DRAM_DATA_WIDTH_72


`define MEMC_DRAM_DATA_WIDTH_64


`define MEMC_DRAM_DATA_WIDTH_GT_63


`define MEMC_DRAM_DATA_WIDTH_GT_55


`define MEMC_DRAM_DATA_WIDTH_GT_47


`define MEMC_DRAM_DATA_WIDTH_GT_39


`define MEMC_DRAM_DATA_WIDTH_GT_31


`define MEMC_DRAM_DATA_WIDTH_GT_23


`define MEMC_DRAM_DATA_WIDTH_GT_15


`define MEMC_DDR3_OR_4


`define MEMC_DDR3_OR_4_OR_LPDDR2


`define MEMC_LPDDR2_OR_DDR4


`define MEMC_MOBILE_OR_LPDDR2_EN 0


// `define MEMC_MOBILE_OR_LPDDR2


`define MEMC_MOBILE_OR_LPDDR2_OR_DDR4_EN 1


`define MEMC_MOBILE_OR_LPDDR2_OR_DDR4


`define MEMC_DDR4_OR_LPDDR4


`define MEMC_DDR3_OR_4_OR_LPDDR4


// `define MEMC_LPDDR2_OR_UMCTL2_CID_EN


// `define MEMC_LPDDR4_OR_UMCTL2_CID_EN


`define MEMC_LPDDR4_OR_UMCTL2_PARTIAL_WR




// `define UPCTL2_POSTED_WRITE_EN_OR_MEMC_INLINE_ECC


`define MEMC_DFI_ADDR_WIDTH 18


`define MEMC_HBUS_SUPPORT


`define MEMC_HBUS_SUPPORT_OR_MEMC_BURST_LENGTH_16


// Name:         MEMC_BG_BITS
// Default:      2 (MEMC_DDR4 == 1 ? 2 : 0)
// Values:       0 2
// Enabled:      MEMC_DDR4==1 ? 1 : 0
// 
// Specifies the number of bits required to address all bank groups in each rank.  
// Must be set to 2 in DDR4 systems and 0 if DDR4 is not present.
`define MEMC_BG_BITS 2


// Name:         MEMC_BG_BANK_BITS
// Default:      4 (MEMC_DDR4 == 1 ? 4 : 3)
// Values:       4 3
// 
// Specifies the maximum number of bits required to address all banks and bank groups in each rank.  
//  - For DDR4, this should be set to 4 and for all other protocols to 3 
//  - For DDR4, this carries 2-bits for bank group address and 2-bits for bank address 
//  - For non-DDR4, all 3-bits are for bank address
`define MEMC_BG_BANK_BITS 4


// Name:         MEMC_BANK_BITS
// Default:      3
// Values:       3
// 
// Specifies the maximum number of bits required to address all banks in each rank.  
// Must be set to 3.
`define MEMC_BANK_BITS 3

/****************************/
/* Begin ECC Related Macros */
/****************************/


`define MEMC_DRAM_ECC_WIDTH 0


// `define MEMC_ECC


// `define MEMC_ECC_SUPPORT_GT_0


// `define MEMC_ECC_SUPPORT_2


`define MEMC_DCERRBITS 4


`define MEMC_ECC_BITS_ON_DQ_BUS 0

//TODO the below three invisible HW paramameter should be change to MEMC_ECC_SUPPORT==1
//TODO current is a workaround to avoid lots of testbench issue ifndef them


// `define UMCTL2_ECC_MODE_64P8


// `define UMCTL2_ECC_MODE_32P7


// `define UMCTL2_ECC_MODE_16P6


`define MEMC_NO_ECC


// `define MEMC_SECDED_ECC


// `define MEMC_ADV_ECC


// `define MEMC_SECDED_SIDEBAND_ECC


// `define MEMC_ADV_SIDEBAND_ECC


// `define MEMC_SECDED_INLINE_ECC


// `define MEMC_ADV_INLINE_ECC
/****************************/
/*  End ECC Related Macros  */
/****************************/

/***********************************/
/* Begin Data width derived macros */
/***********************************/


// Name:         MEMC_DRAM_TOTAL_DATA_WIDTH
// Default:      64 (MEMC_DRAM_DATA_WIDTH + MEMC_DRAM_ECC_WIDTH+0)
// Values:       8 16 24 32 40 48 56 64 72
// Enabled:      0
// 
// Memory data width with ECC (bits).
`define MEMC_DRAM_TOTAL_DATA_WIDTH 64


`define MEMC_DRAM_TOTAL_MASK_WIDTH 8


`define MEMC_DFI_DATA_WIDTH 256


`define MEMC_DFI_MASK_WIDTH 32


`define MEMC_DFI_ECC_WIDTH 0


// Name:         MEMC_DFI_TOTAL_DATA_WIDTH
// Default:      256 (MEMC_FREQ_RATIO * (MEMC_DRAM_DATA_WIDTH + MEMC_DRAM_ECC_WIDTH) 
//               * 2)
// Values:       16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 192, 224, 256, 288
// Enabled:      0
// 
// Specifies the width of DFI data bus including ECC (if any). It is an internal parameter, provided in the GUI for 
// information purposes.
`define MEMC_DFI_TOTAL_DATA_WIDTH 256


`define PHY_DFI_TOTAL_DATA_WIDTH 256


// Name:         RETRY_RAM_WIDTH_COMPLETION
// Default:      0 (((UMCTL2_RETRY_WDATA_EXTERNAL_SRAM == 1) ? 
//               ((MEMC_PROG_FREQ_RATIO==1) ? (MEMC_DFI_TOTAL_DATA_WIDTH/8)%16 == 0 ? 0 : 16 - 
//               (MEMC_DFI_TOTAL_DATA_WIDTH/8)%16 : (MEMC_DFI_TOTAL_DATA_WIDTH/8)%8 == 0 ? 0 : 8 - 
//               (MEMC_DFI_TOTAL_DATA_WIDTH/8)%8) : 0)+0)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// (Internal parameter, provided in GUI for information purposes). RAM width of external SRAM used in 
// crc_parity_retry_wdata_fifo must be a multiple of 8 in case (@MEMC_FREQ_RATIO == 2 && @MEMC_PROG_FREQ_RATIO==0) and a multiple of 16 otherwise, 
// therefore this RETRY_RAM_WIDTH_COMPLETION is necessary
`define RETRY_RAM_WIDTH_COMPLETION 0
 

// Name:         UMCTL2_RETRY_WDATA_EXTRAM_DW
// Default:      288 ((MEMC_DFI_TOTAL_DATA_WIDTH + MEMC_DFI_TOTAL_DATA_WIDTH/8 + 
//               RETRY_RAM_WIDTH_COMPLETION) * 2 / MEMC_FREQ_RATIO)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the data width of retry write data RAM. It is an internal parameter provided in the GUI for information 
// purpose, and is derived from MEMC_FREQ_RATIO, RETRY_RAM_WIDTH_COMPLETION and MEMC_DFI_TOTAL_DATA_WIDTH.
`define UMCTL2_RETRY_WDATA_EXTRAM_DW 288


// Name:         MEMC_DFI_TOTAL_DATAEN_WIDTH
// Default:      16 (UMCTL2_DFI_DATAEN_PER_NIBBLE == 1 ? MEMC_DFI_TOTAL_DATA_WIDTH / 
//               8 : MEMC_DFI_TOTAL_DATA_WIDTH / 16)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the width of dfi_wrdata_en, dfi_rddata_en, and dfi_rddata_valid. 
// It is an internal parameter provided in the GUI for information purpose.
`define MEMC_DFI_TOTAL_DATAEN_WIDTH 16


`define PHY_DFI_TOTAL_DATAEN_WIDTH 16


// Name:         MEMC_DFI_TOTAL_MASK_WIDTH
// Default:      32 (UMCTL2_DFI_MASK_PER_NIBBLE ? (MEMC_DFI_DATA_WIDTH + 
//               MEMC_DFI_ECC_WIDTH)/4 : (MEMC_DFI_DATA_WIDTH + MEMC_DFI_ECC_WIDTH)/8)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the width of dfi_wrdata_mask. 
// It is an internal parameter provided in the GUI for information purpose.
`define MEMC_DFI_TOTAL_MASK_WIDTH 32


`define PHY_DFI_TOTAL_MASK_WIDTH 32


`define MEMC_CORE_DATA_WIDTH_GTEQ_64


`define MEMC_CORE_DATA_WIDTH_GTEQ_128


// `define MEMC_CORE_DATA_WIDTH_LT_64


`define MEMC_CORE_DATA_WIDTH_EQ_256


// Name:         MEMC_RT_FIFO_DEPTH
// Default:      32 ((UMCTL2_RETRY_MAX_ADD_RD_LAT>0) ? 40 : 32)
// Values:       32 36 40 44 48
// 
// Specifies the Response Tracker FIFO depth, which needs to contain entries for all read commands which are currently in 
// progress (command has been sent, but data has not all been received). 
//  
// Maximum required FIFO depth can be calculated by looking at round-trip read latency 
//  - pi_rt_rd_vld -> dfi_rd command =           1 cycle 
//  - dfi_rd command -> DFI read data =          trddata_en + tphy_rdlat cycles (please see PHY PUB databook for their 
//  values) 
//  - DFI read data -> load_ptr =                1 cycle  
//  - RDIMM/LRDIMM delay =                       3 cycles 
//  - Up to 16 more cycles of latency are required in case of unaligned read data  
//  - Up to MEMC_FREQ_RATIO*UMCTL2_RETRY_ADD_RD_LAT more cycles of latency are required if UMCTL2_RETRY_ADD_RD_LAT>0  
// Example 1:LPDDR2 
//  
// Considering LPDDR2 connected to a DDRgen2 mPHY in DFI 1:1 mode, we have: 
//  - trddata_en = RL-4 cycles (RL means Read Latency) 
//  - tphy_rdlat = 29.5 cycles 
//  - RL = 8 (value taken from LPDDR2 JEDEC specifications) 
// Therefore, the maximum round-trip read latency = trddata_en + tphy_rdlat + 2 cycles (pi_rt_rd_vld -> dfi_rd command + 
// DFI read data -> load_ptr) = 35.5 cycles. 
//  
// For LPDDR2,we have BL4, which is one command every 2 cycles, which mean that we need a FIFO depth greater than 18 (we 
// divide the maximum round trip latency by 2 and round up). 
//  
// Up to 16 more cycles of latency are required in case of unaligned read data (in this case the FIFO depth also needs to 
// be increased). 
//  
//  
// Example 2:DDR4 
//  
// Considering DDR4 connected to a DDR4 mPHY in DFI 1:1 mode, we have: 
//  - trddata_en = RL-4 cycles (RL means Read Latency) 
//  - tphy_rdlat = 42 cycles (maximum value according to PUB databook) 
//  - RL = 40 (value taken from DDR4 JEDEC specifications for DDR4-2400) 
// Therefore, the maximum round-trip read latency = trddata_en + tphy_rdlat + 2 cycles (pi_rt_rd_vld -> dfi_rd command + 
// DFI read data -> load_ptr) + 3 cycles (RDIMM/LRDIMM delay) = 83 cycles 
//  
// For DDR4,we have BL8, which is one command every 4 cycles, which mean that we need a FIFO depth greater than 21 (we 
// divide the maximum round trip latency by 4 and round up). 
//  
// Up to 16 more cycles of latency are required in case of unaligned read data (in this case the FIFO depth also needs to 
// be increased). 
//  
//  Up to MEMC_FREQ_RATIO*UMCTL2_RETRY_ADD_RD_LAT more cycles of latency are required if UMCTL2_RETRY_ADD_RD_LAT>0 (in 
//  this case the FIFO depth also needs to be increased). 
//  
// Note: the above calculation example is for Synopsys PHYs. If any other PHY type is used, please check the corresponding 
// databook.
`define MEMC_RT_FIFO_DEPTH 32


`define MEMC_BYTE1


`define MEMC_BYTE2


`define MEMC_BYTE3


`define MEMC_BYTE4


`define MEMC_BYTE5


`define MEMC_BYTE6


`define MEMC_BYTE7


// `define MEMC_BYTE8


// `define MEMC_BYTE9


// `define MEMC_BYTE10


// `define MEMC_BYTE11


// `define MEMC_BYTE12


// `define MEMC_BYTE13


// `define MEMC_BYTE14


// `define MEMC_BYTE15


`define MEMC_MRR_DATA_TOTAL_DATA_WIDTH 256

/***********************************/
/*  End Data width derived macros  */
/***********************************/


`define UMCTL2_TOTAL_RANKS 2


`define MEMC_NUM_RANKS_1_OR_2_OR_4


`define MEMC_NUM_RANKS_1_OR_2



// `define MEMC_NUM_RANKS_1


`define MEMC_NUM_RANKS_2


// `define MEMC_NUM_RANKS_4


// `define MEMC_NUM_RANKS_8


// `define MEMC_NUM_RANKS_16


`define MEMC_NUM_RANKS_GT_1


// `define MEMC_NUM_RANKS_GT_2


// `define MEMC_NUM_RANKS_GT_4



// `define MEMC_NUM_RANKS_GT_8


// `define MEMC_NUM_RANKS_GT_4_OR_UMCTL2_CID_EN


// `define UMCTL2_TOTAL_RANKS_1


`define UMCTL2_TOTAL_RANKS_2


// `define UMCTL2_TOTAL_RANKS_4


// `define UMCTL2_TOTAL_RANKS_8


// `define UMCTL2_TOTAL_RANKS_16



`define UMCTL2_TOTAL_RANKS_GT_1


`define UMCTL2_RANKS_GT_1_OR_DCH_INTL_1


`define UMCTL2_NUM_LRANKS_TOTAL_GT_1


// `define UMCTL2_NUM_LRANKS_TOTAL_GT_2


// `define UMCTL2_NUM_LRANKS_TOTAL_GT_4


// `define UMCTL2_NUM_LRANKS_TOTAL_GT_8


// `define UMCTL2_NUM_LRANKS_TOTAL_1


`define UMCTL2_NUM_LRANKS_TOTAL_2


// `define UMCTL2_NUM_LRANKS_TOTAL_4


// `define UMCTL2_NUM_LRANKS_TOTAL_8


// `define UMCTL2_NUM_LRANKS_TOTAL_16


// `define UMCTL2_CID_WIDTH_GT_0


// `define UMCTL2_CID_WIDTH_GT_1


// `define UMCTL2_CID_WIDTH_GT_2


`define UMCTL2_CID_WIDTH_0


// `define UMCTL2_CID_WIDTH_1


// `define UMCTL2_CID_WIDTH_2


// `define UMCTL2_CID_WIDTH_3


`define MEMC_NUM_RANKS_GT_1_OR_UMCTL2_CID_WIDTH_GT_0



// `define UMCTL2_NUM_PR_CONSTRAINTS_GT_1

`define log2(n) (((n)>512) ? 10 : (((n)>256) ? 9 : (((n)>128) ? 8 : (((n)>64) ? 7 : (((n)>32) ? 6 : (((n)>16) ? 5 : (((n)>8) ? 4 : (((n)>4) ? 3 : (((n)>2) ? 2 : (((n)>1) ? 1 : 0))))))))))


`define MEMC_RANK_BITS 1


`define UMCTL2_LRANK_BITS 1


`define UMCTL2_RANK_BITS 1


`define UMCTL2_TOTAL_CLKS 1


`define PHY_NUM_CLKS 2


`define MEMC_RANKBANK_BITS 5


// Name:         MEMC_NUM_TOTAL_BANKS
// Default:      32 (1<<MEMC_RANKBANK_BITS)
// Values:       8 16 32 64 128 256
// Enabled:      0
// 
// Specifies the maximum number of banks supported with given hardware configuration.
`define MEMC_NUM_TOTAL_BANKS 32


`define MEMC_HIF_MIN_ADDR_WIDTH 29


`define MEMC_HIF_ADDR_WIDTH_MAX 36


`define MEMC_HIF_ADDR_WIDTH_MAX_TB 36


// Name:         MEMC_HIF_ADDR_WIDTH
// Default:      33 (UMCTL2_LRANK_BITS + UMCTL2_DATA_CHANNEL_INTERLEAVE_EN + 
//               (MEMC_DDR4 == 1 ? 32 : (MEMC_DDR3 == 1 || MEMC_LPDDR4 == 1) ? 31 : 
//               MEMC_LPDDR2 == 1 ? 30 : MEMC_HIF_MIN_ADDR_WIDTH) )
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// MEMC_HIF_ADDR_WIDTH 
// Maximum number of HIF address bits supported. For any device, the number of HIF address bits depends on 
// RAW+CAW+BAW+BGW. 
// This is a maximum of 29 for DDR2, 32 for DDR4, 31 FOR DDR3 or LPDDR4, 27 for mDDR and 30 for LPDDR2. Since DDR2 is 
// always supported, we must always support at least 29. 
// The number of rank bits is then added to this.
`define MEMC_HIF_ADDR_WIDTH 33


`define MEMC_HIF_ADDR_WIDTH_GT_28


`define MEMC_HIF_ADDR_WIDTH_GT_29


`define MEMC_HIF_ADDR_WIDTH_GT_30


`define MEMC_HIF_ADDR_WIDTH_GT_31


`define MEMC_HIF_ADDR_WIDTH_GT_32


// `define MEMC_HIF_ADDR_WIDTH_GT_33


// `define MEMC_HIF_ADDR_WIDTH_GT_34


// `define MEMC_HIF_ADDR_WIDTH_GT_35


// `define MEMC_NUM_TOTAL_BANKS_4


// `define MEMC_NUM_TOTAL_BANKS_8


// `define MEMC_NUM_TOTAL_BANKS_16


`define MEMC_NUM_TOTAL_BANKS_32


// `define MEMC_NUM_TOTAL_BANKS_64


// `define MEMC_NUM_TOTAL_BANKS_128


// `define MEMC_NUM_TOTAL_BANKS_256


`define MEMC_FREQ_RATIO_2


// `define MEMC_PROG_FREQ_RATIO_EN


// `define MEMC_BURST_LENGTH_4


`define MEMC_BURST_LENGTH_8


// `define MEMC_BURST_LENGTH_16


`define MEMC_BURST_LENGTH_8_OR_16


`define MEMC_WRDATA_CYCLES 2


// `define MEMC_WRDATA_4_CYCLES


// `define MEMC_WRDATA_8_CYCLES


// `define MEMC_BURST_LENGTH_4_OR_ARB_0


`define MEMC_BURST_LENGTH_4_OR_8_OR_ARB_0


`define UMCTL2_SDRAM_BL16_SUPPORTED


`define UMCTL2_CMD_LEN_BITS 1


// `define MEMC_BURST_LENGTH_16_AND_ARB_1


`define UMCTL2_PARTIAL_WR_BITS 2




// `define MEMC_NO_OF_ENTRY_16


`define MEMC_NO_OF_ENTRY_GT16


// `define MEMC_NO_OF_ENTRY_32


`define MEMC_NO_OF_ENTRY_GT32


`define MEMC_NO_OF_ENTRY_64


`define UMCTL2_RETRY_CMD_FIFO_DEPTH_16


// `define UMCTL2_RETRY_CMD_FIFO_DEPTH_24


// `define UMCTL2_RETRY_CMD_FIFO_DEPTH_32


// `define UMCTL2_RETRY_CMD_FIFO_DEPTH_40


// `define UMCTL2_RETRY_CMD_FIFO_DEPTH_48


// `define UMCTL2_RETRY_CMD_FIFO_DEPTH_40_48


`define MEMC_WRCMD_ENTRY_BITS 6


`define MEMC_RDCMD_ENTRY_BITS 6


// `define MEMC_ACT_BYPASS


// `define MEMC_RD_BYPASS


// `define MEMC_ANY_BYPASS


`define UMCTL2_FATL_BITS 3

/**********************************************/
/* Begin Fast Frequency Change derived macros */
/**********************************************/

// `define UMCTL2_FREQUENCY_NUM_GT_1


// `define UMCTL2_FREQUENCY_NUM_GT_2


// `define UMCTL2_FREQUENCY_NUM_GT_3
/********************************************/
/* End Fast Frequency Change derived macros */
/********************************************/

/********************************************/
/* Begin INLINE ECC derived macros */
/********************************************/

`define MEMC_ECC_RAM_DEPTH 72


`define MEMC_DRAM_DATA_WIDTH_64_OR_MEMC_INLINE_ECC



`define MEMC_INLINE_ECC_OR_UMCTL2_VPR_EN


`define UMCTL2_OCPAR_WDATA_OUT_ERR_WIDTH 1


`define MEMC_HIF_CREDIT_BITS 1


// `define MEMC_HIF_CMD_WDATA_MASK_FULL_EN


// `define MEMC_ADDR_ERR_EN


`define MEMC_MAX_INLINE_ECC_PER_BURST 8



`define MEMC_MAX_INLINE_ECC_PER_BURST_BITS 3

/********************************************/
/* End INLINE ECC derived macros */
/********************************************/

// ----------------------------------------------------------------------------
// Shared-AC and LPDDR4 Dual channel combo derived macro
// ----------------------------------------------------------------------------

// `define UMCTL2_PROGCHN_OR_UMCTL2_SHAREDAC_LP4DUAL_COMB

// ----------------------------------------------------------------------------
// Dynamic BSM parameters
// ----------------------------------------------------------------------------



// Name:         UMCTL2_DYN_BSM
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_NUM_TOTAL_BANKS>16) && (UPCTL2_EN==0) && 
//               (MEMC_OPT_TIMING==1) && (MEMC_BYPASS==0) && (UMCTL2_HWFFC_EN==0) && 
//               (MEMC_INLINE_ECC==0))
// 
// Enables Dynamic BSM feature. 
// This feature is under access control. For more information, contact Synopsys.
// `define UMCTL2_DYN_BSM


`define UMCTL2_DYN_BSM_EN 0


// Name:         UMCTL2_NUM_BSM
// Default:      32 (UMCTL2_DYN_BSM == 0) ? MEMC_NUM_TOTAL_BANKS : 
//               (MEMC_NUM_TOTAL_BANKS / 2 > 64) ? 64 : (MEMC_NUM_TOTAL_BANKS / 2)
// Values:       8 16 32 64 128 256
// Enabled:      UMCTL2_DYN_BSM == 1
// 
// Specifies the number of BSM modules required.
`define UMCTL2_NUM_BSM 32


`define UMCTL2_BSM_BITS 5

// ----------------------------------------------------------------------------
// MACROS used during the development of APB interface and memory map
// ----------------------------------------------------------------------------



// Name:         UMCTL2_APB_DW
// Default:      32
// Values:       8 16 32
// Enabled:      0
// 
// Defines the width of the APB Data Bus.  
// This must be set to 32.
`define UMCTL2_APB_DW 32


// Name:         UMCTL2_APB_AW
// Default:      12 ((UMCTL2_FREQUENCY_NUM == 4) ? 15 : 
//               ((UMCTL2_FAST_FREQUENCY_CHANGE == 1 || UMCTL2_HET_RANK == 1) ? 14 : ((UMCTL2_SHARED_AC == 1 || 
//               UMCTL2_DUAL_CHANNEL == 1)? 13 : 12)))
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// APB Address Width.
`define UMCTL2_APB_AW 12


// Name:         UMCTL2_RSTN_SYNC_AND_ASYNC
// Default:      0
// Values:       0, 1
// 
// UMCTL2_RSTN_SYNC_AND_ASYNC 
// Reset synchronisers are used to drive reset networks of FFs belonging 
// to programming interface but clocked by clocks different from APB clock. 
// When the parameter is set to 1 the reset signals (one for each clock 
// domain asynchronous to APB clock domain) are gated with APB reset signal: 
//  - Generated reset signals are set high synchronously, set low asynchronously. 
//  - FFs whose reset pin is driven by such reset signal are reset independenty on APB clock. 
// When the parameter is set to 0 the and gate is not instantiated. 
// Default value is 0.
// `define UMCTL2_RSTN_SYNC_AND_ASYNC


// Name:         UMCTL2_P_ASYNC_EN
// Default:      Asynchronous
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      Always
// 
// Defines the pclk clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. 
// When enabled (asynchronous), the area of the controller is increased for additional  
// instantiation of CDC components. 
//  
// Note: The core_ddrc_core_clk frequency has to be  
// greater or equal to pclk frequency.
`define UMCTL2_P_ASYNC_EN 1


`define UMCTL2_P_ASYNC


// Name:         UMCTL2_P_SYNC_RATIO
// Default:      1:1
// Values:       1:1 (1), 2:1 (2), 3:1 (3), 4:1 (4)
// Enabled:      UMCTL2_P_ASYNC_EN == 0
// 
// Ratio between core_ddrc_core_clk and pclk frequency when the two clock domains are in phase. 
// This parameter has no effect on the RTL or verification but only on synthesis. 
// The parameter is enabled within the synthesis constraint when UMCTL2_P_ASYNC_EN=0.
`define UMCTL2_P_SYNC_RATIO 1


`define UMCTL2_BCM_REG_OUTPUTS_C2P 1


`define UMCTL2_BCM_REG_OUTPUTS_P2C 1


// Name:         DWC_BCM_SV
// Default:      1
// Values:       0, 1
// 
// Supports the use of $urandom in the BCM blocks (for missample modeling).
`define DWC_BCM_SV


`define UMCTL2_DUAL_PA 1


`define UMCTL2_DUAL_PA_1

// ----------------------------------------------------------------------------
// Exclusive Access Monitor Parameters
// ----------------------------------------------------------------------------

// Name:         UMCTL2_EXCL_ACCESS
// Default:      0
// Values:       0, ..., 16
// Enabled:      ((UMCTL2_INCL_ARB==1) && (THEREIS_AXI_PORT==1))
// 
// Specifies the number of AXI Exclusive Access Monitors. 
//  - 0: Exclusive Access Monitoring is not supported. 
//  - 1-16: Exclusive Access Monitoring is supported with the selected number of monitors.
`define UMCTL2_EXCL_ACCESS 0


`define UMCTL2_EXCL_ACCESS_0

// ----------------------------------------------------------------------------
// External Port Priorities
// ----------------------------------------------------------------------------

// Name:         UMCTL2_EXT_PORTPRIO
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB==1 && UMCTL2_A_NPORTS > 1
// 
// Enables dynamic setting of port priorities externally through the AXI QoS signals (awqos_n 
// and arqos_n).
`define UMCTL2_EXT_PORTPRIO 0


// ----------------------------------------------------------------------------
//                                Multiport
// ----------------------------------------------------------------------------


`define UMCTL2_A_AXI_0

// `define UMCTL2_A_AXI_1

// `define UMCTL2_A_AXI_2

// `define UMCTL2_A_AXI_3

// `define UMCTL2_A_AXI_4

// `define UMCTL2_A_AXI_5

// `define UMCTL2_A_AXI_6

// `define UMCTL2_A_AXI_7

// `define UMCTL2_A_AXI_8

// `define UMCTL2_A_AXI_9

// `define UMCTL2_A_AXI_10

// `define UMCTL2_A_AXI_11

// `define UMCTL2_A_AXI_12

// `define UMCTL2_A_AXI_13

// `define UMCTL2_A_AXI_14

// `define UMCTL2_A_AXI_15


`define UMCTL2_A_AXI4_0

// `define UMCTL2_A_AXI4_1

// `define UMCTL2_A_AXI4_2

// `define UMCTL2_A_AXI4_3

// `define UMCTL2_A_AXI4_4

// `define UMCTL2_A_AXI4_5

// `define UMCTL2_A_AXI4_6

// `define UMCTL2_A_AXI4_7

// `define UMCTL2_A_AXI4_8

// `define UMCTL2_A_AXI4_9

// `define UMCTL2_A_AXI4_10

// `define UMCTL2_A_AXI4_11

// `define UMCTL2_A_AXI4_12

// `define UMCTL2_A_AXI4_13

// `define UMCTL2_A_AXI4_14

// `define UMCTL2_A_AXI4_15


// `define UMCTL2_A_AHB_0

// `define UMCTL2_A_AHB_1

// `define UMCTL2_A_AHB_2

// `define UMCTL2_A_AHB_3

// `define UMCTL2_A_AHB_4

// `define UMCTL2_A_AHB_5

// `define UMCTL2_A_AHB_6

// `define UMCTL2_A_AHB_7

// `define UMCTL2_A_AHB_8

// `define UMCTL2_A_AHB_9

// `define UMCTL2_A_AHB_10

// `define UMCTL2_A_AHB_11

// `define UMCTL2_A_AHB_12

// `define UMCTL2_A_AHB_13

// `define UMCTL2_A_AHB_14

// `define UMCTL2_A_AHB_15


`define UMCTL2_A_AXI_OR_AHB_0

// `define UMCTL2_A_AXI_OR_AHB_1

// `define UMCTL2_A_AXI_OR_AHB_2

// `define UMCTL2_A_AXI_OR_AHB_3

// `define UMCTL2_A_AXI_OR_AHB_4

// `define UMCTL2_A_AXI_OR_AHB_5

// `define UMCTL2_A_AXI_OR_AHB_6

// `define UMCTL2_A_AXI_OR_AHB_7

// `define UMCTL2_A_AXI_OR_AHB_8

// `define UMCTL2_A_AXI_OR_AHB_9

// `define UMCTL2_A_AXI_OR_AHB_10

// `define UMCTL2_A_AXI_OR_AHB_11

// `define UMCTL2_A_AXI_OR_AHB_12

// `define UMCTL2_A_AXI_OR_AHB_13

// `define UMCTL2_A_AXI_OR_AHB_14

// `define UMCTL2_A_AXI_OR_AHB_15


// Name:         UMCTL2_A_DW
// Default:      256 (MEMC_FREQ_RATIO==2) ? (4*MEMC_DRAM_DATA_WIDTH) : 
//               (2*MEMC_DRAM_DATA_WIDTH)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Application Data Width
`define UMCTL2_A_DW 256


// Name:         UMCTL2_PORT_DW_0
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_0!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_0 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0 0


`define UMCTL2_A_DW_INT_0 256


// Name:         UMCTL2_XPI_USE2RAQ_0
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_0 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_0 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_0 0


// `define UMCTL2_A_USE2RAQ_0


`define UMCTL2_PORT_DSIZE_0 0


`define UMCTL2_PORT_USIZE_0 0


// Name:         UMCTL2_PORT_DW_1
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_1!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_1 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1 0


`define UMCTL2_A_DW_INT_1 256


// Name:         UMCTL2_XPI_USE2RAQ_1
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_1 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_1 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_1 0


// `define UMCTL2_A_USE2RAQ_1


`define UMCTL2_PORT_DSIZE_1 0


`define UMCTL2_PORT_USIZE_1 0


// Name:         UMCTL2_PORT_DW_2
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_2!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_2 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2 0


`define UMCTL2_A_DW_INT_2 256


// Name:         UMCTL2_XPI_USE2RAQ_2
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_2 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_2 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_2 0


// `define UMCTL2_A_USE2RAQ_2


`define UMCTL2_PORT_DSIZE_2 0


`define UMCTL2_PORT_USIZE_2 0


// Name:         UMCTL2_PORT_DW_3
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_3!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_3 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3 0


`define UMCTL2_A_DW_INT_3 256


// Name:         UMCTL2_XPI_USE2RAQ_3
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_3 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_3 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_3 0


// `define UMCTL2_A_USE2RAQ_3


`define UMCTL2_PORT_DSIZE_3 0


`define UMCTL2_PORT_USIZE_3 0


// Name:         UMCTL2_PORT_DW_4
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_4!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_4 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4 0


`define UMCTL2_A_DW_INT_4 256


// Name:         UMCTL2_XPI_USE2RAQ_4
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_4 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_4 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_4 0


// `define UMCTL2_A_USE2RAQ_4


`define UMCTL2_PORT_DSIZE_4 0


`define UMCTL2_PORT_USIZE_4 0


// Name:         UMCTL2_PORT_DW_5
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_5!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_5 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5 0


`define UMCTL2_A_DW_INT_5 256


// Name:         UMCTL2_XPI_USE2RAQ_5
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_5 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_5 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_5 0


// `define UMCTL2_A_USE2RAQ_5


`define UMCTL2_PORT_DSIZE_5 0


`define UMCTL2_PORT_USIZE_5 0


// Name:         UMCTL2_PORT_DW_6
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_6!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_6 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6 0


`define UMCTL2_A_DW_INT_6 256


// Name:         UMCTL2_XPI_USE2RAQ_6
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_6 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_6 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_6 0


// `define UMCTL2_A_USE2RAQ_6


`define UMCTL2_PORT_DSIZE_6 0


`define UMCTL2_PORT_USIZE_6 0


// Name:         UMCTL2_PORT_DW_7
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_7!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_7 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7 0


`define UMCTL2_A_DW_INT_7 256


// Name:         UMCTL2_XPI_USE2RAQ_7
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_7 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_7 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_7 0


// `define UMCTL2_A_USE2RAQ_7


`define UMCTL2_PORT_DSIZE_7 0


`define UMCTL2_PORT_USIZE_7 0


// Name:         UMCTL2_PORT_DW_8
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_8!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_8 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8 0


`define UMCTL2_A_DW_INT_8 256


// Name:         UMCTL2_XPI_USE2RAQ_8
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_8 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_8 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_8 0


// `define UMCTL2_A_USE2RAQ_8


`define UMCTL2_PORT_DSIZE_8 0


`define UMCTL2_PORT_USIZE_8 0


// Name:         UMCTL2_PORT_DW_9
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_9!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 
//               != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_9 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9 0


`define UMCTL2_A_DW_INT_9 256


// Name:         UMCTL2_XPI_USE2RAQ_9
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_9 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_9 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_9 0


// `define UMCTL2_A_USE2RAQ_9


`define UMCTL2_PORT_DSIZE_9 0


`define UMCTL2_PORT_USIZE_9 0


// Name:         UMCTL2_PORT_DW_10
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_10!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (10+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_10 != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_10 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10 0


`define UMCTL2_A_DW_INT_10 256


// Name:         UMCTL2_XPI_USE2RAQ_10
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_10 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_10 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_10 0


// `define UMCTL2_A_USE2RAQ_10


`define UMCTL2_PORT_DSIZE_10 0


`define UMCTL2_PORT_USIZE_10 0


// Name:         UMCTL2_PORT_DW_11
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_11!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (11+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_11 != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_11 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11 0


`define UMCTL2_A_DW_INT_11 256


// Name:         UMCTL2_XPI_USE2RAQ_11
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_11 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_11 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_11 0


// `define UMCTL2_A_USE2RAQ_11


`define UMCTL2_PORT_DSIZE_11 0


`define UMCTL2_PORT_USIZE_11 0


// Name:         UMCTL2_PORT_DW_12
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_12!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (12+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_12 != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_12 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12 0


`define UMCTL2_A_DW_INT_12 256


// Name:         UMCTL2_XPI_USE2RAQ_12
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_12 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_12 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_12 0


// `define UMCTL2_A_USE2RAQ_12


`define UMCTL2_PORT_DSIZE_12 0


`define UMCTL2_PORT_USIZE_12 0


// Name:         UMCTL2_PORT_DW_13
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_13!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (13+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_13 != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_13 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13 0


`define UMCTL2_A_DW_INT_13 256


// Name:         UMCTL2_XPI_USE2RAQ_13
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_13 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_13 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_13 0


// `define UMCTL2_A_USE2RAQ_13


`define UMCTL2_PORT_DSIZE_13 0


`define UMCTL2_PORT_USIZE_13 0


// Name:         UMCTL2_PORT_DW_14
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_14!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (14+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_14 != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_14 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14 0


`define UMCTL2_A_DW_INT_14 256


// Name:         UMCTL2_XPI_USE2RAQ_14
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_14 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_14 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_14 0


// `define UMCTL2_A_USE2RAQ_14


`define UMCTL2_PORT_DSIZE_14 0


`define UMCTL2_PORT_USIZE_14 0


// Name:         UMCTL2_PORT_DW_15
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_15!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (15+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_15 != 0
// 
// Defines the datawidth of the controller application port n. 
// Valid ranges are: 
//  - AXI3: 8  to 512 
//  - AXI4: 32 to 512 
//  - AHB : 8  to 512
`define UMCTL2_PORT_DW_15 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15 0


`define UMCTL2_A_DW_INT_15 256


// Name:         UMCTL2_XPI_USE2RAQ_15
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_15 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0 && 
//               (UMCTL2_PORT_DW_15 <= UMCTL2_A_DW) && (UPCTL2_EN == 0)
// 
// Enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_15 0


// `define UMCTL2_A_USE2RAQ_15


`define UMCTL2_PORT_DSIZE_15 0


`define UMCTL2_PORT_USIZE_15 0



`define UMCTL2_TOT_INTERLEAVE_NS 0


`define THEREIS_INTLV_NS 0


`define UMCTL2_TOT_USE2RAQ 0


// `define THEREIS_USE2RAQ

`define UMCTL2_RAQ_TABLE_0 0
`define UMCTL2_RAQ_TABLE_1 `UMCTL2_RAQ_TABLE_0 + `UMCTL2_XPI_USE2RAQ_0
`define UMCTL2_RAQ_TABLE_2 `UMCTL2_RAQ_TABLE_1 + `UMCTL2_XPI_USE2RAQ_1
`define UMCTL2_RAQ_TABLE_3 `UMCTL2_RAQ_TABLE_2 + `UMCTL2_XPI_USE2RAQ_2
`define UMCTL2_RAQ_TABLE_4 `UMCTL2_RAQ_TABLE_3 + `UMCTL2_XPI_USE2RAQ_3
`define UMCTL2_RAQ_TABLE_5 `UMCTL2_RAQ_TABLE_4 + `UMCTL2_XPI_USE2RAQ_4
`define UMCTL2_RAQ_TABLE_6 `UMCTL2_RAQ_TABLE_5 + `UMCTL2_XPI_USE2RAQ_5
`define UMCTL2_RAQ_TABLE_7 `UMCTL2_RAQ_TABLE_6 + `UMCTL2_XPI_USE2RAQ_6
`define UMCTL2_RAQ_TABLE_8 `UMCTL2_RAQ_TABLE_7 + `UMCTL2_XPI_USE2RAQ_7
`define UMCTL2_RAQ_TABLE_9 `UMCTL2_RAQ_TABLE_8 + `UMCTL2_XPI_USE2RAQ_8
`define UMCTL2_RAQ_TABLE_10 `UMCTL2_RAQ_TABLE_9 + `UMCTL2_XPI_USE2RAQ_9
`define UMCTL2_RAQ_TABLE_11 `UMCTL2_RAQ_TABLE_10 + `UMCTL2_XPI_USE2RAQ_10
`define UMCTL2_RAQ_TABLE_12 `UMCTL2_RAQ_TABLE_11 + `UMCTL2_XPI_USE2RAQ_11
`define UMCTL2_RAQ_TABLE_13 `UMCTL2_RAQ_TABLE_12 + `UMCTL2_XPI_USE2RAQ_12
`define UMCTL2_RAQ_TABLE_14 `UMCTL2_RAQ_TABLE_13 + `UMCTL2_XPI_USE2RAQ_13
`define UMCTL2_RAQ_TABLE_15 `UMCTL2_RAQ_TABLE_14 + `UMCTL2_XPI_USE2RAQ_14


// Name:         UMCTL2_RAQ_TABLE
// Default:      0 ((UMCTL2_XPI_USE2RAQ_15<<15) + (UMCTL2_XPI_USE2RAQ_14<<14) + 
//               (UMCTL2_XPI_USE2RAQ_13<<13) + (UMCTL2_XPI_USE2RAQ_12<<12) + 
//               (UMCTL2_XPI_USE2RAQ_11<<11) + (UMCTL2_XPI_USE2RAQ_10<<10) + 
//               (UMCTL2_XPI_USE2RAQ_9<<9) + (UMCTL2_XPI_USE2RAQ_8<<8) + (UMCTL2_XPI_USE2RAQ_7<<7) + 
//               (UMCTL2_XPI_USE2RAQ_6<<6) + (UMCTL2_XPI_USE2RAQ_5<<5) + 
//               (UMCTL2_XPI_USE2RAQ_4<<4) + (UMCTL2_XPI_USE2RAQ_3<<3) + (UMCTL2_XPI_USE2RAQ_2<<2) + 
//               (UMCTL2_XPI_USE2RAQ_1<<1) + UMCTL2_XPI_USE2RAQ_0)
// Values:       -2147483648, ..., 65535
// 
// Table built from the list of UMCTL2_XPI_USE2RAQ_<n>
`define UMCTL2_RAQ_TABLE 0


`define UMCTL2_XPI_RQOS_MLW 4


`define UMCTL2_XPI_RQOS_RW 2


`define UMCTL2_XPI_VPR_EN 1


`define UMCTL2_XPI_VPW_EN 1


`define UMCTL2_XPI_VPT_EN 1


`define UMCTL2_XPI_WQOS_MLW 4


`define UMCTL2_XPI_WQOS_RW 2


`define UMCTL2_XPI_RQOS_TW 11


`define UMCTL2_XPI_WQOS_TW 11


`define UMCTL2_XPI_VPR_EN_0 1


`define UMCTL2_XPI_VPR_0

`define UMCTL2_XPI_VPR_EN_1 0


// `define UMCTL2_XPI_VPR_1

`define UMCTL2_XPI_VPR_EN_2 0


// `define UMCTL2_XPI_VPR_2

`define UMCTL2_XPI_VPR_EN_3 0


// `define UMCTL2_XPI_VPR_3

`define UMCTL2_XPI_VPR_EN_4 0


// `define UMCTL2_XPI_VPR_4

`define UMCTL2_XPI_VPR_EN_5 0


// `define UMCTL2_XPI_VPR_5

`define UMCTL2_XPI_VPR_EN_6 0


// `define UMCTL2_XPI_VPR_6

`define UMCTL2_XPI_VPR_EN_7 0


// `define UMCTL2_XPI_VPR_7

`define UMCTL2_XPI_VPR_EN_8 0


// `define UMCTL2_XPI_VPR_8

`define UMCTL2_XPI_VPR_EN_9 0


// `define UMCTL2_XPI_VPR_9

`define UMCTL2_XPI_VPR_EN_10 0


// `define UMCTL2_XPI_VPR_10

`define UMCTL2_XPI_VPR_EN_11 0


// `define UMCTL2_XPI_VPR_11

`define UMCTL2_XPI_VPR_EN_12 0


// `define UMCTL2_XPI_VPR_12

`define UMCTL2_XPI_VPR_EN_13 0


// `define UMCTL2_XPI_VPR_13

`define UMCTL2_XPI_VPR_EN_14 0


// `define UMCTL2_XPI_VPR_14

`define UMCTL2_XPI_VPR_EN_15 0


// `define UMCTL2_XPI_VPR_15


`define UMCTL2_XPI_VPW_EN_0 1


`define UMCTL2_XPI_VPW_0

`define UMCTL2_XPI_VPW_EN_1 0


// `define UMCTL2_XPI_VPW_1

`define UMCTL2_XPI_VPW_EN_2 0


// `define UMCTL2_XPI_VPW_2

`define UMCTL2_XPI_VPW_EN_3 0


// `define UMCTL2_XPI_VPW_3

`define UMCTL2_XPI_VPW_EN_4 0


// `define UMCTL2_XPI_VPW_4

`define UMCTL2_XPI_VPW_EN_5 0


// `define UMCTL2_XPI_VPW_5

`define UMCTL2_XPI_VPW_EN_6 0


// `define UMCTL2_XPI_VPW_6

`define UMCTL2_XPI_VPW_EN_7 0


// `define UMCTL2_XPI_VPW_7

`define UMCTL2_XPI_VPW_EN_8 0


// `define UMCTL2_XPI_VPW_8

`define UMCTL2_XPI_VPW_EN_9 0


// `define UMCTL2_XPI_VPW_9

`define UMCTL2_XPI_VPW_EN_10 0


// `define UMCTL2_XPI_VPW_10

`define UMCTL2_XPI_VPW_EN_11 0


// `define UMCTL2_XPI_VPW_11

`define UMCTL2_XPI_VPW_EN_12 0


// `define UMCTL2_XPI_VPW_12

`define UMCTL2_XPI_VPW_EN_13 0


// `define UMCTL2_XPI_VPW_13

`define UMCTL2_XPI_VPW_EN_14 0


// `define UMCTL2_XPI_VPW_14

`define UMCTL2_XPI_VPW_EN_15 0


// `define UMCTL2_XPI_VPW_15


// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_0
// Default:      Yes (((UMCTL2_PORT_DW_0>UMCTL2_A_DW_INT_0) || (UMCTL2_A_AXI_0==0)) 
//               ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_0==0) || (UMCTL2_XPI_USE2RAQ_0==1) || 
//               (UMCTL2_PORT_DW_0>UMCTL2_A_DW_INT_0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_0 1

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_1
// Default:      No (((UMCTL2_PORT_DW_1>UMCTL2_A_DW_INT_1) || (UMCTL2_A_AXI_1==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_1==0) || (UMCTL2_XPI_USE2RAQ_1==1) || 
//               (UMCTL2_PORT_DW_1>UMCTL2_A_DW_INT_1) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_1 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_2
// Default:      No (((UMCTL2_PORT_DW_2>UMCTL2_A_DW_INT_2) || (UMCTL2_A_AXI_2==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_2==0) || (UMCTL2_XPI_USE2RAQ_2==1) || 
//               (UMCTL2_PORT_DW_2>UMCTL2_A_DW_INT_2) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_2 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_3
// Default:      No (((UMCTL2_PORT_DW_3>UMCTL2_A_DW_INT_3) || (UMCTL2_A_AXI_3==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_3==0) || (UMCTL2_XPI_USE2RAQ_3==1) || 
//               (UMCTL2_PORT_DW_3>UMCTL2_A_DW_INT_3) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_3 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_4
// Default:      No (((UMCTL2_PORT_DW_4>UMCTL2_A_DW_INT_4) || (UMCTL2_A_AXI_4==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_4==0) || (UMCTL2_XPI_USE2RAQ_4==1) || 
//               (UMCTL2_PORT_DW_4>UMCTL2_A_DW_INT_4) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_4 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_5
// Default:      No (((UMCTL2_PORT_DW_5>UMCTL2_A_DW_INT_5) || (UMCTL2_A_AXI_5==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_5==0) || (UMCTL2_XPI_USE2RAQ_5==1) || 
//               (UMCTL2_PORT_DW_5>UMCTL2_A_DW_INT_5) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_5 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_6
// Default:      No (((UMCTL2_PORT_DW_6>UMCTL2_A_DW_INT_6) || (UMCTL2_A_AXI_6==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_6==0) || (UMCTL2_XPI_USE2RAQ_6==1) || 
//               (UMCTL2_PORT_DW_6>UMCTL2_A_DW_INT_6) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_6 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_7
// Default:      No (((UMCTL2_PORT_DW_7>UMCTL2_A_DW_INT_7) || (UMCTL2_A_AXI_7==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_7==0) || (UMCTL2_XPI_USE2RAQ_7==1) || 
//               (UMCTL2_PORT_DW_7>UMCTL2_A_DW_INT_7) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_7 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_8
// Default:      No (((UMCTL2_PORT_DW_8>UMCTL2_A_DW_INT_8) || (UMCTL2_A_AXI_8==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_8==0) || (UMCTL2_XPI_USE2RAQ_8==1) || 
//               (UMCTL2_PORT_DW_8>UMCTL2_A_DW_INT_8) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_8 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_9
// Default:      No (((UMCTL2_PORT_DW_9>UMCTL2_A_DW_INT_9) || (UMCTL2_A_AXI_9==0)) ? 
//               0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_9==0) || (UMCTL2_XPI_USE2RAQ_9==1) || 
//               (UMCTL2_PORT_DW_9>UMCTL2_A_DW_INT_9) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_9 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_10
// Default:      No (((UMCTL2_PORT_DW_10>UMCTL2_A_DW_INT_10) || 
//               (UMCTL2_A_AXI_10==0)) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_10==0) || (UMCTL2_XPI_USE2RAQ_10==1) || 
//               (UMCTL2_PORT_DW_10>UMCTL2_A_DW_INT_10) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) 
//               ? 0 : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_10 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_11
// Default:      No (((UMCTL2_PORT_DW_11>UMCTL2_A_DW_INT_11) || 
//               (UMCTL2_A_AXI_11==0)) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_11==0) || (UMCTL2_XPI_USE2RAQ_11==1) || 
//               (UMCTL2_PORT_DW_11>UMCTL2_A_DW_INT_11) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) 
//               ? 0 : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_11 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_12
// Default:      No (((UMCTL2_PORT_DW_12>UMCTL2_A_DW_INT_12) || 
//               (UMCTL2_A_AXI_12==0)) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_12==0) || (UMCTL2_XPI_USE2RAQ_12==1) || 
//               (UMCTL2_PORT_DW_12>UMCTL2_A_DW_INT_12) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) 
//               ? 0 : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_12 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_13
// Default:      No (((UMCTL2_PORT_DW_13>UMCTL2_A_DW_INT_13) || 
//               (UMCTL2_A_AXI_13==0)) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_13==0) || (UMCTL2_XPI_USE2RAQ_13==1) || 
//               (UMCTL2_PORT_DW_13>UMCTL2_A_DW_INT_13) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) 
//               ? 0 : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_13 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_14
// Default:      No (((UMCTL2_PORT_DW_14>UMCTL2_A_DW_INT_14) || 
//               (UMCTL2_A_AXI_14==0)) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_14==0) || (UMCTL2_XPI_USE2RAQ_14==1) || 
//               (UMCTL2_PORT_DW_14>UMCTL2_A_DW_INT_14) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) 
//               ? 0 : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_14 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_15
// Default:      No (((UMCTL2_PORT_DW_15>UMCTL2_A_DW_INT_15) || 
//               (UMCTL2_A_AXI_15==0)) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_15==0) || (UMCTL2_XPI_USE2RAQ_15==1) || 
//               (UMCTL2_PORT_DW_15>UMCTL2_A_DW_INT_15) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) 
//               ? 0 : 1
// 
// Enables the interleaving of the read data of transactions with different ARID fields. 
// Read data interleaving may occur at memory burst boundaries.  
// Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in RRB buffer and not interrupt a longer burst that has started earlier. 
// It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_15 0


// Name:         UMCTL2_INT_NPORTS
// Default:      1 (UMCTL2_A_NPORTS + UMCTL2_TOT_USE2RAQ + UMCTL2_SBR_EN)
// Values:       0, ..., 16
// Enabled:      0
// 
// Specifies the total number of ports as seen internally by the PA. It is an internal parameter provided in the GUI for 
// information purpose. A port is seen internally 
// as two ports if UMCTL2_XPI_USE2RAQ_n is set for that port. The ECC scrubber ,  
// if enabled, is also seen as a port. 
// Thus, 
// UMCTL2_INT_NPORTS = UMCTL2_A_NPORTS + UMCTL2_TOT_USE2RAQ + UMCTL2_SBR_EN 
// where UMCTL2_TOT_USE2RAQ is sum of UMCTL2_XPI_USE2RAQ_n for all configured 
// ports.
`define UMCTL2_INT_NPORTS 1


// Name:         UMCTL2_INT_NPORTS_DATA
// Default:      1 (UMCTL2_A_NPORTS + UMCTL2_SBR_EN)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Total number of ports (Internal ports seen by the PA - data path)
`define UMCTL2_INT_NPORTS_DATA 1



`define UMCTL2_INT_NPORTS_0

// `define UMCTL2_INT_NPORTS_1

// `define UMCTL2_INT_NPORTS_2

// `define UMCTL2_INT_NPORTS_3

// `define UMCTL2_INT_NPORTS_4

// `define UMCTL2_INT_NPORTS_5

// `define UMCTL2_INT_NPORTS_6

// `define UMCTL2_INT_NPORTS_7

// `define UMCTL2_INT_NPORTS_8

// `define UMCTL2_INT_NPORTS_9

// `define UMCTL2_INT_NPORTS_10

// `define UMCTL2_INT_NPORTS_11

// `define UMCTL2_INT_NPORTS_12

// `define UMCTL2_INT_NPORTS_13

// `define UMCTL2_INT_NPORTS_14

// `define UMCTL2_INT_NPORTS_15


`define UMCTL2_XPI_USE_RMW 1


// Name:         UMCTL2_MAX_XPI_PORT_DW
// Default:      256 ([<functionof> UMCTL2_A_NPORTS])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determine maximum UMCTL2_A_PORT_DW_$ width of all ports.
`define UMCTL2_MAX_XPI_PORT_DW 256


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_16


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_32


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_64


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_128


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_256


// `define UMCTL2_MAX_XPI_PORT_DW_GTEQ_512
                                                 

// Name:         UMCTL2_PORT_NBYTES_0
// Default:      32 (UMCTL2_PORT_DW_0/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_0 32

// Name:         UMCTL2_PORT_NBYTES_1
// Default:      32 (UMCTL2_PORT_DW_1/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_1 32

// Name:         UMCTL2_PORT_NBYTES_2
// Default:      32 (UMCTL2_PORT_DW_2/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_2 32

// Name:         UMCTL2_PORT_NBYTES_3
// Default:      32 (UMCTL2_PORT_DW_3/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_3 32

// Name:         UMCTL2_PORT_NBYTES_4
// Default:      32 (UMCTL2_PORT_DW_4/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_4 32

// Name:         UMCTL2_PORT_NBYTES_5
// Default:      32 (UMCTL2_PORT_DW_5/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_5 32

// Name:         UMCTL2_PORT_NBYTES_6
// Default:      32 (UMCTL2_PORT_DW_6/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_6 32

// Name:         UMCTL2_PORT_NBYTES_7
// Default:      32 (UMCTL2_PORT_DW_7/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_7 32

// Name:         UMCTL2_PORT_NBYTES_8
// Default:      32 (UMCTL2_PORT_DW_8/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_8 32

// Name:         UMCTL2_PORT_NBYTES_9
// Default:      32 (UMCTL2_PORT_DW_9/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_9 32

// Name:         UMCTL2_PORT_NBYTES_10
// Default:      32 (UMCTL2_PORT_DW_10/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_10 32

// Name:         UMCTL2_PORT_NBYTES_11
// Default:      32 (UMCTL2_PORT_DW_11/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_11 32

// Name:         UMCTL2_PORT_NBYTES_12
// Default:      32 (UMCTL2_PORT_DW_12/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_12 32

// Name:         UMCTL2_PORT_NBYTES_13
// Default:      32 (UMCTL2_PORT_DW_13/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_13 32

// Name:         UMCTL2_PORT_NBYTES_14
// Default:      32 (UMCTL2_PORT_DW_14/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_14 32

// Name:         UMCTL2_PORT_NBYTES_15
// Default:      32 (UMCTL2_PORT_DW_15/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the uMCTL application port n.
`define UMCTL2_PORT_NBYTES_15 32


`define UMCTL2_PORT_NBYTES_MAX 64


`define UMCTL2_A_AXI


`define UMCTL2_A_AXI4


// `define UMCTL2_A_AHB


`define UMCTL2_A_AXI_OR_AHB


`define THEREIS_PORT_DSIZE 0


`define THEREIS_PORT_USIZE 0



// Name:         UMCTL2_M_BLW
// Default:      4
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the Memory burst length support. 
// (3 -> BL8; 4 -> BL16)
`define UMCTL2_M_BLW 4


// Name:         UMCTL2_A_LENW
// Default:      8 ((THEREIS_AXI4_PORT == 1) ? 8 : 4)
// Values:       4 5 6 7 8
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application burst length.
`define UMCTL2_A_LENW 8


`define UMCTL2_AXI_LOCK_WIDTH_0 1

`define UMCTL2_AXI_LOCK_WIDTH_1 2

`define UMCTL2_AXI_LOCK_WIDTH_2 2

`define UMCTL2_AXI_LOCK_WIDTH_3 2

`define UMCTL2_AXI_LOCK_WIDTH_4 2

`define UMCTL2_AXI_LOCK_WIDTH_5 2

`define UMCTL2_AXI_LOCK_WIDTH_6 2

`define UMCTL2_AXI_LOCK_WIDTH_7 2

`define UMCTL2_AXI_LOCK_WIDTH_8 2

`define UMCTL2_AXI_LOCK_WIDTH_9 2

`define UMCTL2_AXI_LOCK_WIDTH_10 2

`define UMCTL2_AXI_LOCK_WIDTH_11 2

`define UMCTL2_AXI_LOCK_WIDTH_12 2

`define UMCTL2_AXI_LOCK_WIDTH_13 2

`define UMCTL2_AXI_LOCK_WIDTH_14 2

`define UMCTL2_AXI_LOCK_WIDTH_15 2


// Name:         UMCTL2_AXI_USER_WIDTH
// Default:      0
// Values:       0, ..., 8
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application user signals.
`define UMCTL2_AXI_USER_WIDTH 8


`define UMCTL2_AXI_USER_WIDTH_GT0


`define UMCTL2_AXI_USER_WIDTH_INT 8


`define UMCTL2_AXI_LOCK_WIDTH 2


`define UMCTL2_AXI_REGION_WIDTH 4


`define UMCTL2_XPI_NBEATS 2


`define UMCTL2_XPI_NBEATS_LG2 1
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_0
// Default:      17 ([<functionof> UMCTL2_PORT_DW_0 UMCTL2_A_DW_INT_0 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_0 17


`define UMCTL2_XPI_RP_HINFOW_0 21



`define UMCTL2_XPI_RD_INFOW_NSA_0 17


// Name:         UMCTL2_XPI_RD_INFOW_0
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_0 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0 UMCTL2_PORT_DW_0])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 0
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_0 17


// Name:         UMCTL2_XPI_WR_INFOW_0
// Default:      22 (UMCTL2_XPI_RP_HINFOW_0+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 0
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_0 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_1
// Default:      17 ([<functionof> UMCTL2_PORT_DW_1 UMCTL2_A_DW_INT_1 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_1 17


`define UMCTL2_XPI_RP_HINFOW_1 21



`define UMCTL2_XPI_RD_INFOW_NSA_1 17


// Name:         UMCTL2_XPI_RD_INFOW_1
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_1 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1 UMCTL2_PORT_DW_1])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 1
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_1 17


// Name:         UMCTL2_XPI_WR_INFOW_1
// Default:      22 (UMCTL2_XPI_RP_HINFOW_1+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 1
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_1 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_2
// Default:      17 ([<functionof> UMCTL2_PORT_DW_2 UMCTL2_A_DW_INT_2 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_2 17


`define UMCTL2_XPI_RP_HINFOW_2 21



`define UMCTL2_XPI_RD_INFOW_NSA_2 17


// Name:         UMCTL2_XPI_RD_INFOW_2
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_2 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2 UMCTL2_PORT_DW_2])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 2
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_2 17


// Name:         UMCTL2_XPI_WR_INFOW_2
// Default:      22 (UMCTL2_XPI_RP_HINFOW_2+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 2
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_2 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_3
// Default:      17 ([<functionof> UMCTL2_PORT_DW_3 UMCTL2_A_DW_INT_3 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_3 17


`define UMCTL2_XPI_RP_HINFOW_3 21



`define UMCTL2_XPI_RD_INFOW_NSA_3 17


// Name:         UMCTL2_XPI_RD_INFOW_3
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_3 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3 UMCTL2_PORT_DW_3])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 3
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_3 17


// Name:         UMCTL2_XPI_WR_INFOW_3
// Default:      22 (UMCTL2_XPI_RP_HINFOW_3+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 3
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_3 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_4
// Default:      17 ([<functionof> UMCTL2_PORT_DW_4 UMCTL2_A_DW_INT_4 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_4 17


`define UMCTL2_XPI_RP_HINFOW_4 21



`define UMCTL2_XPI_RD_INFOW_NSA_4 17


// Name:         UMCTL2_XPI_RD_INFOW_4
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_4 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4 UMCTL2_PORT_DW_4])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 4
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_4 17


// Name:         UMCTL2_XPI_WR_INFOW_4
// Default:      22 (UMCTL2_XPI_RP_HINFOW_4+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 4
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_4 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_5
// Default:      17 ([<functionof> UMCTL2_PORT_DW_5 UMCTL2_A_DW_INT_5 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_5 17


`define UMCTL2_XPI_RP_HINFOW_5 21



`define UMCTL2_XPI_RD_INFOW_NSA_5 17


// Name:         UMCTL2_XPI_RD_INFOW_5
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_5 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5 UMCTL2_PORT_DW_5])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 5
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_5 17


// Name:         UMCTL2_XPI_WR_INFOW_5
// Default:      22 (UMCTL2_XPI_RP_HINFOW_5+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 5
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_5 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_6
// Default:      17 ([<functionof> UMCTL2_PORT_DW_6 UMCTL2_A_DW_INT_6 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_6 17


`define UMCTL2_XPI_RP_HINFOW_6 21



`define UMCTL2_XPI_RD_INFOW_NSA_6 17


// Name:         UMCTL2_XPI_RD_INFOW_6
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_6 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6 UMCTL2_PORT_DW_6])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 6
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_6 17


// Name:         UMCTL2_XPI_WR_INFOW_6
// Default:      22 (UMCTL2_XPI_RP_HINFOW_6+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 6
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_6 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_7
// Default:      17 ([<functionof> UMCTL2_PORT_DW_7 UMCTL2_A_DW_INT_7 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_7 17


`define UMCTL2_XPI_RP_HINFOW_7 21



`define UMCTL2_XPI_RD_INFOW_NSA_7 17


// Name:         UMCTL2_XPI_RD_INFOW_7
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_7 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7 UMCTL2_PORT_DW_7])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 7
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_7 17


// Name:         UMCTL2_XPI_WR_INFOW_7
// Default:      22 (UMCTL2_XPI_RP_HINFOW_7+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 7
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_7 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_8
// Default:      17 ([<functionof> UMCTL2_PORT_DW_8 UMCTL2_A_DW_INT_8 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_8 17


`define UMCTL2_XPI_RP_HINFOW_8 21



`define UMCTL2_XPI_RD_INFOW_NSA_8 17


// Name:         UMCTL2_XPI_RD_INFOW_8
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_8 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8 UMCTL2_PORT_DW_8])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 8
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_8 17


// Name:         UMCTL2_XPI_WR_INFOW_8
// Default:      22 (UMCTL2_XPI_RP_HINFOW_8+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 8
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_8 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_9
// Default:      17 ([<functionof> UMCTL2_PORT_DW_9 UMCTL2_A_DW_INT_9 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_9 17


`define UMCTL2_XPI_RP_HINFOW_9 21



`define UMCTL2_XPI_RD_INFOW_NSA_9 17


// Name:         UMCTL2_XPI_RD_INFOW_9
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_9 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9 UMCTL2_PORT_DW_9])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 9
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_9 17


// Name:         UMCTL2_XPI_WR_INFOW_9
// Default:      22 (UMCTL2_XPI_RP_HINFOW_9+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 9
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_9 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_10
// Default:      17 ([<functionof> UMCTL2_PORT_DW_10 UMCTL2_A_DW_INT_10 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_10 17


`define UMCTL2_XPI_RP_HINFOW_10 21



`define UMCTL2_XPI_RD_INFOW_NSA_10 17


// Name:         UMCTL2_XPI_RD_INFOW_10
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_10 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10 UMCTL2_PORT_DW_10])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 10
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_10 17


// Name:         UMCTL2_XPI_WR_INFOW_10
// Default:      22 (UMCTL2_XPI_RP_HINFOW_10+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 10
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_10 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_11
// Default:      17 ([<functionof> UMCTL2_PORT_DW_11 UMCTL2_A_DW_INT_11 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_11 17


`define UMCTL2_XPI_RP_HINFOW_11 21



`define UMCTL2_XPI_RD_INFOW_NSA_11 17


// Name:         UMCTL2_XPI_RD_INFOW_11
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_11 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11 UMCTL2_PORT_DW_11])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 11
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_11 17


// Name:         UMCTL2_XPI_WR_INFOW_11
// Default:      22 (UMCTL2_XPI_RP_HINFOW_11+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 11
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_11 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_12
// Default:      17 ([<functionof> UMCTL2_PORT_DW_12 UMCTL2_A_DW_INT_12 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_12 17


`define UMCTL2_XPI_RP_HINFOW_12 21



`define UMCTL2_XPI_RD_INFOW_NSA_12 17


// Name:         UMCTL2_XPI_RD_INFOW_12
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_12 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12 UMCTL2_PORT_DW_12])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 12
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_12 17


// Name:         UMCTL2_XPI_WR_INFOW_12
// Default:      22 (UMCTL2_XPI_RP_HINFOW_12+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 12
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_12 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_13
// Default:      17 ([<functionof> UMCTL2_PORT_DW_13 UMCTL2_A_DW_INT_13 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_13 17


`define UMCTL2_XPI_RP_HINFOW_13 21



`define UMCTL2_XPI_RD_INFOW_NSA_13 17


// Name:         UMCTL2_XPI_RD_INFOW_13
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_13 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13 UMCTL2_PORT_DW_13])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 13
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_13 17


// Name:         UMCTL2_XPI_WR_INFOW_13
// Default:      22 (UMCTL2_XPI_RP_HINFOW_13+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 13
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_13 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_14
// Default:      17 ([<functionof> UMCTL2_PORT_DW_14 UMCTL2_A_DW_INT_14 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_14 17


`define UMCTL2_XPI_RP_HINFOW_14 21



`define UMCTL2_XPI_RD_INFOW_NSA_14 17


// Name:         UMCTL2_XPI_RD_INFOW_14
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_14 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14 UMCTL2_PORT_DW_14])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 14
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_14 17


// Name:         UMCTL2_XPI_WR_INFOW_14
// Default:      22 (UMCTL2_XPI_RP_HINFOW_14+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 14
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_14 22
                                                 

// Name:         UMCTL2_XPI_RP_INFOW_15
// Default:      17 ([<functionof> UMCTL2_PORT_DW_15 UMCTL2_A_DW_INT_15 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_15 17


`define UMCTL2_XPI_RP_HINFOW_15 21



`define UMCTL2_XPI_RD_INFOW_NSA_15 17


// Name:         UMCTL2_XPI_RD_INFOW_15
// Default:      17 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_15 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15 UMCTL2_PORT_DW_15])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 15
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_15 17


// Name:         UMCTL2_XPI_WR_INFOW_15
// Default:      22 (UMCTL2_XPI_RP_HINFOW_15+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 15
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_15 22
                                                 



`define UMCTL2_TOKENW 6


// Name:         UMCTL2_AXI_ADDR_BOUNDARY
// Default:      12
// Values:       12, ..., 32
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the AXI address boundary restriction. 
// AXI transactions must not cross 2**AXI_ADDR_BOUNDARY bytes. 
// The default value of 12 matches the AXI specification of 4K boundary.
`define UMCTL2_AXI_ADDR_BOUNDARY 12


// Name:         UMCTL2_A_IDW
// Default:      8
// Values:       1, ..., 32
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application ID.
`define UMCTL2_A_IDW 16


`define UMCTL2_A_ID_MAPW 16

//This is the log2 of (UMCTL2_INT_NPORTS_DATA)

`define UMCTL2_A_NPORTS_LG2 1


`define UMCTL2_EXCL_ACC_FLAG 1

//This is beat info used in rrb to identify start,end beats number and interleave mode  

`define UMCTL2_XPI_RD_BEAT_INFOW 4
                                                 
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_0 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_1 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_2 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_3 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_4 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_5 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_6 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_7 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_8 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_9 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_10 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_11 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_12 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_13 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_14 61
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number 

`define UMCTL2_AXI_TAGBITS_15 61


// Name:         UMCTL2_MAX_AXI_TAGBITS
// Default:      61 ([<functionof> UMCTL2_A_NPORTS])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determines the maximum UMCTL2_AXI_TAGBITS_$ width of all the ports.
`define UMCTL2_MAX_AXI_TAGBITS 61



// Name:         MEMC_HIF_TAGBITS
// Default:      6 (MEMC_NO_OF_ENTRY == 16 ? 4 : (MEMC_NO_OF_ENTRY == 32 ? 5 : 6))
// Values:       UMCTL2_TOKENW, ..., 31
// Enabled:      UMCTL2_INCL_ARB == 0
// 
// Specifies the width of token bus. 
// By default, the CAM depth determines the width of the token bus. If an arbiter is present, you can increase the width 
// of the token bus to accommodate port and AXI IDs.
`define MEMC_HIF_TAGBITS 6


// Name:         MEMC_TAGBITS
// Default:      61 ((UMCTL2_INCL_ARB == 0) ? MEMC_HIF_TAGBITS : 
//               UMCTL2_MAX_AXI_TAGBITS)
// Values:       UMCTL2_TOKENW, ..., 128
// 
// Tag width at ddrc interface
`define MEMC_TAGBITS 61


`define UMCTL2_AXI_WDATA_PTR_BITS 33


`define UMCTL2_SEQ_BURST_MODE 1


// Name:         MEMC_HIF_WDATA_PTR_BITS
// Default:      1
// Values:       1, ..., 31
// Enabled:      UMCTL2_INCL_ARB == 0
// 
// Specifies the number of bits provided for write pointers (sent to the controller with write commands, and later returned 
// to the interface to enable data fetches). 
// If an arbiter is present, you can override the width of the write pointer to accommodate port and AXI IDs.
`define MEMC_HIF_WDATA_PTR_BITS 1


`define MEMC_WDATA_PTR_BITS 33


// Name:         UMCTL2_AXI_LOWPWR_NOPX_CNT
// Default:      0
// Values:       0, ..., 1048576
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the number of cycles after the   
// last active transaction to de-assertion of the cactive signal.
`define UMCTL2_AXI_LOWPWR_NOPX_CNT 0

//UMCTL2_A_QOSW:
//Specifies the width of the Application QOS.
`define UMCTL2_A_QOSW 4


// Name:         UMCTL2_PORT_DW_TABLE
// Default:      0x20040080100200400801002004008010020040080100 
//               ((UMCTL2_PORT_DW_15<<165) + (UMCTL2_PORT_DW_14<<154) + (UMCTL2_PORT_DW_13<<143) + 
//               (UMCTL2_PORT_DW_12<<132) + (UMCTL2_PORT_DW_11<<121) + 
//               (UMCTL2_PORT_DW_10<<110) + (UMCTL2_PORT_DW_9<<99) + (UMCTL2_PORT_DW_8<<88) + 
//               (UMCTL2_PORT_DW_7<<77) + (UMCTL2_PORT_DW_6<<66) + (UMCTL2_PORT_DW_5<<55) + 
//               (UMCTL2_PORT_DW_4<<44) + (UMCTL2_PORT_DW_3<<33) + (UMCTL2_PORT_DW_2<<22) + 
//               (UMCTL2_PORT_DW_1<<11) + UMCTL2_PORT_DW_0)
// Values:       0x0, ..., 0xffffffffffffffffffffffffffffffffffffffffffff
// 
// Datawidth table built from each hosts datawidth
`define UMCTL2_PORT_DW_TABLE 176'h20040080100200400801002004008010020040080100


// Name:         UMCTL2_A_SYNC_0
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>0 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_0 0

// Name:         UMCTL2_A_SYNC_1
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>1 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_1 0

// Name:         UMCTL2_A_SYNC_2
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>2 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_2 0

// Name:         UMCTL2_A_SYNC_3
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>3 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_3 0

// Name:         UMCTL2_A_SYNC_4
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>4 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_4 0

// Name:         UMCTL2_A_SYNC_5
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>5 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_5 0

// Name:         UMCTL2_A_SYNC_6
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>6 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_6 0

// Name:         UMCTL2_A_SYNC_7
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>7 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_7 0

// Name:         UMCTL2_A_SYNC_8
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>8 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_8 0

// Name:         UMCTL2_A_SYNC_9
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>9 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_9 0

// Name:         UMCTL2_A_SYNC_10
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>10 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_10 0

// Name:         UMCTL2_A_SYNC_11
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>11 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_11 0

// Name:         UMCTL2_A_SYNC_12
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>12 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_12 0

// Name:         UMCTL2_A_SYNC_13
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>13 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_13 0

// Name:         UMCTL2_A_SYNC_14
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>14 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_14 0

// Name:         UMCTL2_A_SYNC_15
// Default:      Asynchronous
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>15 && UMCTL2_INCL_ARB ==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_15 0


// Name:         UMCTL2_AP_ASYNC_0
// Default:      Asynchronous (((UMCTL2_A_SYNC_0==0 && UMCTL2_A_AXI_OR_AHB_0!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_0 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_0


`define UMCTL2_AP_ASYNC_A_0 1

// Name:         UMCTL2_AP_ASYNC_1
// Default:      Asynchronous (((UMCTL2_A_SYNC_1==0 && UMCTL2_A_AXI_OR_AHB_1!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_1 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_1


`define UMCTL2_AP_ASYNC_A_1 1

// Name:         UMCTL2_AP_ASYNC_2
// Default:      Asynchronous (((UMCTL2_A_SYNC_2==0 && UMCTL2_A_AXI_OR_AHB_2!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_2 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_2


`define UMCTL2_AP_ASYNC_A_2 1

// Name:         UMCTL2_AP_ASYNC_3
// Default:      Asynchronous (((UMCTL2_A_SYNC_3==0 && UMCTL2_A_AXI_OR_AHB_3!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_3 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_3


`define UMCTL2_AP_ASYNC_A_3 1

// Name:         UMCTL2_AP_ASYNC_4
// Default:      Asynchronous (((UMCTL2_A_SYNC_4==0 && UMCTL2_A_AXI_OR_AHB_4!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_4 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_4


`define UMCTL2_AP_ASYNC_A_4 1

// Name:         UMCTL2_AP_ASYNC_5
// Default:      Asynchronous (((UMCTL2_A_SYNC_5==0 && UMCTL2_A_AXI_OR_AHB_5!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_5 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_5


`define UMCTL2_AP_ASYNC_A_5 1

// Name:         UMCTL2_AP_ASYNC_6
// Default:      Asynchronous (((UMCTL2_A_SYNC_6==0 && UMCTL2_A_AXI_OR_AHB_6!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_6 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_6


`define UMCTL2_AP_ASYNC_A_6 1

// Name:         UMCTL2_AP_ASYNC_7
// Default:      Asynchronous (((UMCTL2_A_SYNC_7==0 && UMCTL2_A_AXI_OR_AHB_7!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_7 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_7


`define UMCTL2_AP_ASYNC_A_7 1

// Name:         UMCTL2_AP_ASYNC_8
// Default:      Asynchronous (((UMCTL2_A_SYNC_8==0 && UMCTL2_A_AXI_OR_AHB_8!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_8 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_8


`define UMCTL2_AP_ASYNC_A_8 1

// Name:         UMCTL2_AP_ASYNC_9
// Default:      Asynchronous (((UMCTL2_A_SYNC_9==0 && UMCTL2_A_AXI_OR_AHB_9!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_9 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_9


`define UMCTL2_AP_ASYNC_A_9 1

// Name:         UMCTL2_AP_ASYNC_10
// Default:      Asynchronous (((UMCTL2_A_SYNC_10==0 && UMCTL2_A_AXI_OR_AHB_10!=0) 
//               || UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_10 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_10


`define UMCTL2_AP_ASYNC_A_10 1

// Name:         UMCTL2_AP_ASYNC_11
// Default:      Asynchronous (((UMCTL2_A_SYNC_11==0 && UMCTL2_A_AXI_OR_AHB_11!=0) 
//               || UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_11 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_11


`define UMCTL2_AP_ASYNC_A_11 1

// Name:         UMCTL2_AP_ASYNC_12
// Default:      Asynchronous (((UMCTL2_A_SYNC_12==0 && UMCTL2_A_AXI_OR_AHB_12!=0) 
//               || UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_12 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_12


`define UMCTL2_AP_ASYNC_A_12 1

// Name:         UMCTL2_AP_ASYNC_13
// Default:      Asynchronous (((UMCTL2_A_SYNC_13==0 && UMCTL2_A_AXI_OR_AHB_13!=0) 
//               || UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_13 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_13


`define UMCTL2_AP_ASYNC_A_13 1

// Name:         UMCTL2_AP_ASYNC_14
// Default:      Asynchronous (((UMCTL2_A_SYNC_14==0 && UMCTL2_A_AXI_OR_AHB_14!=0) 
//               || UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_14 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_14


`define UMCTL2_AP_ASYNC_A_14 1

// Name:         UMCTL2_AP_ASYNC_15
// Default:      Asynchronous (((UMCTL2_A_SYNC_15==0 && UMCTL2_A_AXI_OR_AHB_15!=0) 
//               || UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_OR_AHB_15 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock  
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_15


`define UMCTL2_AP_ASYNC_A_15 1


// Name:         UMCTL2_USE_SCANMODE
// Default:      1 ([<functionof> UMCTL2_A_NPORTS UMCTL2_P_ASYNC_EN])
// Values:       0, 1
// 
// Scan mode port is used when any AXI clock is asynchronous to core clock  
// or APB clock is asynchronous to core clock.
`define UMCTL2_USE_SCANMODE


`define UMCTL2_AP_ANY_ASYNC 1


// Name:         UMCTL2_ASYNC_REG_N_SYNC
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_AP_ANY_ASYNC == 1
// 
// Defines the number of synchronization stages for APB synchronizers. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_REG_N_SYNC 3


// Name:         UMCTL2_ASYNC_DDRC_N_SYNC
// Default:      2
// Values:       2 3 4
// Enabled:      Always
// 
// Specifies the number of synchronization stages for DDRC synchronizers, for asynchronous inputs directly to DDRC. 
//  - 2: Double synchronized, 
//  - 3: Triple synchronized, 
//  - 4: Quadruple synchronized.
`define UMCTL2_ASYNC_DDRC_N_SYNC 3


// Name:         UMCTL2_ASYNC_LP4DCI_N_SYNC
// Default:      2
// Values:       2 3 4
// Enabled:      MEMC_LPDDR4==1 && UMCTL2_LPDDR4_DUAL_CHANNEL==0
// 
// Specifies the number of synchronization stages for LPDDR4 Initialization Handshake Interface synchronizers. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_LP4DCI_N_SYNC 2


`define RM_BCM25 0


`define RM_BCM23 0


// Name:         DWC_NO_TST_MODE
// Default:      1
// Values:       0, 1
// 
// Spcifies that test input for bcms is not required.
`define DWC_NO_TST_MODE


// Name:         DWC_NO_CDC_INIT
// Default:      1 (((UMCTL2_CRC_PARITY_RETRY==1) || (THEREIS_AHB_PORT == 1)) ? 0 : 
//               1)
// Values:       0, 1
// 
// Spcifies that synchronous reset input for bcms related to CDC  is not required.
`define DWC_NO_CDC_INIT



// Name:         UMCTL2_A_SYNC_TABLE
// Default:      0x0 ( (UMCTL2_A_SYNC_15<<15) + (UMCTL2_A_SYNC_14<<14) + 
//               (UMCTL2_A_SYNC_13<<13) + (UMCTL2_A_SYNC_12<<12) + (UMCTL2_A_SYNC_11<<11) + 
//               (UMCTL2_A_SYNC_10<<10) + (UMCTL2_A_SYNC_9<<9) + (UMCTL2_A_SYNC_8<<8) + 
//               (UMCTL2_A_SYNC_7<<7) + (UMCTL2_A_SYNC_6<<6) + (UMCTL2_A_SYNC_5<<5) + 
//               (UMCTL2_A_SYNC_4<<4) + (UMCTL2_A_SYNC_3<<3) + (UMCTL2_A_SYNC_2<<2) + 
//               (UMCTL2_A_SYNC_1<<1) + UMCTL2_A_SYNC_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_A_SYNC_<n>
`define UMCTL2_A_SYNC_TABLE 16'h0


// Name:         UMCTL2_AP_ASYNC_TABLE
// Default:      0xffff ( (UMCTL2_AP_ASYNC_A_15<<15) + (UMCTL2_AP_ASYNC_A_14<<14) + 
//               (UMCTL2_AP_ASYNC_A_13<<13) + (UMCTL2_AP_ASYNC_A_12<<12) + 
//               (UMCTL2_AP_ASYNC_A_11<<11) + (UMCTL2_AP_ASYNC_A_10<<10) + 
//               (UMCTL2_AP_ASYNC_A_9<<9) + (UMCTL2_AP_ASYNC_A_8<<8) + (UMCTL2_AP_ASYNC_A_7<<7) + 
//               (UMCTL2_AP_ASYNC_A_6<<6) + (UMCTL2_AP_ASYNC_A_5<<5) + (UMCTL2_AP_ASYNC_A_4<<4) 
//               + (UMCTL2_AP_ASYNC_A_3<<3) + (UMCTL2_AP_ASYNC_A_2<<2) + 
//               (UMCTL2_AP_ASYNC_A_1<<1) + UMCTL2_AP_ASYNC_A_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_AP_ASYNC_A_<n>
`define UMCTL2_AP_ASYNC_TABLE 16'hffff


// Name:         UMCTL2_A_DIR_0
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_0 0

// Name:         UMCTL2_A_DIR_1
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_1 0

// Name:         UMCTL2_A_DIR_2
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_2 0

// Name:         UMCTL2_A_DIR_3
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_3 0

// Name:         UMCTL2_A_DIR_4
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_4 0

// Name:         UMCTL2_A_DIR_5
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_5 0

// Name:         UMCTL2_A_DIR_6
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_6 0

// Name:         UMCTL2_A_DIR_7
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_7 0

// Name:         UMCTL2_A_DIR_8
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_8 0

// Name:         UMCTL2_A_DIR_9
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_9 0

// Name:         UMCTL2_A_DIR_10
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_10 0

// Name:         UMCTL2_A_DIR_11
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_11 0

// Name:         UMCTL2_A_DIR_12
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_12 0

// Name:         UMCTL2_A_DIR_13
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_13 0

// Name:         UMCTL2_A_DIR_14
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_14 0

// Name:         UMCTL2_A_DIR_15
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the uMCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_15 0


// Name:         UMCTL2_STATIC_VIR_CH_0
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>0 && (UMCTL2_A_TYPE_0 == 1 || UMCTL2_A_TYPE_0 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_0 0

// Name:         UMCTL2_STATIC_VIR_CH_1
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>1 && (UMCTL2_A_TYPE_1 == 1 || UMCTL2_A_TYPE_1 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_1 0

// Name:         UMCTL2_STATIC_VIR_CH_2
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>2 && (UMCTL2_A_TYPE_2 == 1 || UMCTL2_A_TYPE_2 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_2 0

// Name:         UMCTL2_STATIC_VIR_CH_3
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>3 && (UMCTL2_A_TYPE_3 == 1 || UMCTL2_A_TYPE_3 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_3 0

// Name:         UMCTL2_STATIC_VIR_CH_4
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>4 && (UMCTL2_A_TYPE_4 == 1 || UMCTL2_A_TYPE_4 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_4 0

// Name:         UMCTL2_STATIC_VIR_CH_5
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>5 && (UMCTL2_A_TYPE_5 == 1 || UMCTL2_A_TYPE_5 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_5 0

// Name:         UMCTL2_STATIC_VIR_CH_6
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>6 && (UMCTL2_A_TYPE_6 == 1 || UMCTL2_A_TYPE_6 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_6 0

// Name:         UMCTL2_STATIC_VIR_CH_7
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>7 && (UMCTL2_A_TYPE_7 == 1 || UMCTL2_A_TYPE_7 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_7 0

// Name:         UMCTL2_STATIC_VIR_CH_8
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>8 && (UMCTL2_A_TYPE_8 == 1 || UMCTL2_A_TYPE_8 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_8 0

// Name:         UMCTL2_STATIC_VIR_CH_9
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>9 && (UMCTL2_A_TYPE_9 == 1 || UMCTL2_A_TYPE_9 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_9 0

// Name:         UMCTL2_STATIC_VIR_CH_10
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>10 && (UMCTL2_A_TYPE_10 == 1 || UMCTL2_A_TYPE_10 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_10 0

// Name:         UMCTL2_STATIC_VIR_CH_11
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>11 && (UMCTL2_A_TYPE_11 == 1 || UMCTL2_A_TYPE_11 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_11 0

// Name:         UMCTL2_STATIC_VIR_CH_12
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>12 && (UMCTL2_A_TYPE_12 == 1 || UMCTL2_A_TYPE_12 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_12 0

// Name:         UMCTL2_STATIC_VIR_CH_13
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>13 && (UMCTL2_A_TYPE_13 == 1 || UMCTL2_A_TYPE_13 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_13 0

// Name:         UMCTL2_STATIC_VIR_CH_14
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>14 && (UMCTL2_A_TYPE_14 == 1 || UMCTL2_A_TYPE_14 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_14 0

// Name:         UMCTL2_STATIC_VIR_CH_15
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>15 && (UMCTL2_A_TYPE_15 == 1 || UMCTL2_A_TYPE_15 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_15 0


// Name:         UMCTL2_STATIC_VIR_CH_TABLE
// Default:      0x0 ((UMCTL2_STATIC_VIR_CH_15<<15) + (UMCTL2_STATIC_VIR_CH_14<<14) 
//               + (UMCTL2_STATIC_VIR_CH_13<<13) + (UMCTL2_STATIC_VIR_CH_12<<12) + 
//               (UMCTL2_STATIC_VIR_CH_11<<11) + (UMCTL2_STATIC_VIR_CH_10<<10) + 
//               (UMCTL2_STATIC_VIR_CH_9<<9) + (UMCTL2_STATIC_VIR_CH_8<<8) + 
//               (UMCTL2_STATIC_VIR_CH_7<<7) + (UMCTL2_STATIC_VIR_CH_6<<6) + 
//               (UMCTL2_STATIC_VIR_CH_5<<5) + (UMCTL2_STATIC_VIR_CH_4<<4) + (UMCTL2_STATIC_VIR_CH_3<<3) + 
//               (UMCTL2_STATIC_VIR_CH_2<<2) + (UMCTL2_STATIC_VIR_CH_1<<1) + 
//               UMCTL2_STATIC_VIR_CH_0)
// Values:       0x0, ..., 0xffff
// 
// Table built from static virtual channels mapping for port $
`define UMCTL2_STATIC_VIR_CH_TABLE 16'h0


// Name:         UMCTL2_NUM_VIR_CH_0
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>0 && (UMCTL2_A_TYPE_0 == 1 || UMCTL2_A_TYPE_0 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_0 32

// Name:         UMCTL2_NUM_VIR_CH_1
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>1 && (UMCTL2_A_TYPE_1 == 1 || UMCTL2_A_TYPE_1 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_1 1

// Name:         UMCTL2_NUM_VIR_CH_2
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>2 && (UMCTL2_A_TYPE_2 == 1 || UMCTL2_A_TYPE_2 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_2 1

// Name:         UMCTL2_NUM_VIR_CH_3
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>3 && (UMCTL2_A_TYPE_3 == 1 || UMCTL2_A_TYPE_3 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_3 1

// Name:         UMCTL2_NUM_VIR_CH_4
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>4 && (UMCTL2_A_TYPE_4 == 1 || UMCTL2_A_TYPE_4 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_4 1

// Name:         UMCTL2_NUM_VIR_CH_5
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>5 && (UMCTL2_A_TYPE_5 == 1 || UMCTL2_A_TYPE_5 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_5 1

// Name:         UMCTL2_NUM_VIR_CH_6
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>6 && (UMCTL2_A_TYPE_6 == 1 || UMCTL2_A_TYPE_6 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_6 1

// Name:         UMCTL2_NUM_VIR_CH_7
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>7 && (UMCTL2_A_TYPE_7 == 1 || UMCTL2_A_TYPE_7 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_7 1

// Name:         UMCTL2_NUM_VIR_CH_8
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>8 && (UMCTL2_A_TYPE_8 == 1 || UMCTL2_A_TYPE_8 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_8 1

// Name:         UMCTL2_NUM_VIR_CH_9
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>9 && (UMCTL2_A_TYPE_9 == 1 || UMCTL2_A_TYPE_9 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_9 1

// Name:         UMCTL2_NUM_VIR_CH_10
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>10 && (UMCTL2_A_TYPE_10 == 1 || UMCTL2_A_TYPE_10 == 
//               3) && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_10 1

// Name:         UMCTL2_NUM_VIR_CH_11
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>11 && (UMCTL2_A_TYPE_11 == 1 || UMCTL2_A_TYPE_11 == 
//               3) && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_11 1

// Name:         UMCTL2_NUM_VIR_CH_12
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>12 && (UMCTL2_A_TYPE_12 == 1 || UMCTL2_A_TYPE_12 == 
//               3) && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_12 1

// Name:         UMCTL2_NUM_VIR_CH_13
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>13 && (UMCTL2_A_TYPE_13 == 1 || UMCTL2_A_TYPE_13 == 
//               3) && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_13 1

// Name:         UMCTL2_NUM_VIR_CH_14
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>14 && (UMCTL2_A_TYPE_14 == 1 || UMCTL2_A_TYPE_14 == 
//               3) && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_14 1

// Name:         UMCTL2_NUM_VIR_CH_15
// Default:      1
// Values:       1, ..., 32
// Enabled:      UMCTL2_A_NPORTS>15 && (UMCTL2_A_TYPE_15 == 1 || UMCTL2_A_TYPE_15 == 
//               3) && UMCTL2_INCL_ARB == 1 && UPCTL2_EN == 0
// 
// Defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_15 1


// Name:         UMCTL2_NUM_VIR_CH_TABLE
// Default:      0x41041041041041041041060 ((UMCTL2_NUM_VIR_CH_15<<90) + 
//               (UMCTL2_NUM_VIR_CH_14<<84) + (UMCTL2_NUM_VIR_CH_13<<78) + 
//               (UMCTL2_NUM_VIR_CH_12<<72) + (UMCTL2_NUM_VIR_CH_11<<66) + (UMCTL2_NUM_VIR_CH_10<<60) + 
//               (UMCTL2_NUM_VIR_CH_9<<54) + (UMCTL2_NUM_VIR_CH_8<<48) + 
//               (UMCTL2_NUM_VIR_CH_7<<42) + (UMCTL2_NUM_VIR_CH_6<<36) + (UMCTL2_NUM_VIR_CH_5<<30) + 
//               (UMCTL2_NUM_VIR_CH_4<<24) + (UMCTL2_NUM_VIR_CH_3<<18) + 
//               (UMCTL2_NUM_VIR_CH_2<<12) + (UMCTL2_NUM_VIR_CH_1<<6) + UMCTL2_NUM_VIR_CH_0)
// Values:       0x0, ..., 0xffffffffffffffffffffffff
// 
// UMCTL2_PORT_DW_TABLE: 
// Datawidth table built from each hosts datawidth
`define UMCTL2_NUM_VIR_CH_TABLE 96'h41041041041041041041060


// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_0
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>0 && UMCTL2_A_SYNC_0==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_0 3

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_1
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>1 && UMCTL2_A_SYNC_1==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_1 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_2
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>2 && UMCTL2_A_SYNC_2==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_2 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_3
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>3 && UMCTL2_A_SYNC_3==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_3 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_4
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>4 && UMCTL2_A_SYNC_4==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_4 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_5
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>5 && UMCTL2_A_SYNC_5==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_5 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_6
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>6 && UMCTL2_A_SYNC_6==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_6 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_7
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>7 && UMCTL2_A_SYNC_7==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_7 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_8
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>8 && UMCTL2_A_SYNC_8==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_8 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_9
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>9 && UMCTL2_A_SYNC_9==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_9 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_10
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>10 && UMCTL2_A_SYNC_10==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_10 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_11
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>11 && UMCTL2_A_SYNC_11==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_11 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_12
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>12 && UMCTL2_A_SYNC_12==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_12 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_13
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>13 && UMCTL2_A_SYNC_13==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_13 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_14
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>14 && UMCTL2_A_SYNC_14==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_14 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_15
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>15 && UMCTL2_A_SYNC_15==0 && UMCTL2_INCL_ARB == 1
// 
// Defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side, 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_15 2


// Name:         UMCTL2_RRB_EXTRAM_0
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_0 1


`define UMCTL2_RRB_EXTRAM_ENABLED_0

// Name:         UMCTL2_RRB_EXTRAM_1
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_1 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_1

// Name:         UMCTL2_RRB_EXTRAM_2
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_2 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_2

// Name:         UMCTL2_RRB_EXTRAM_3
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_3 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_3

// Name:         UMCTL2_RRB_EXTRAM_4
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_4 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_4

// Name:         UMCTL2_RRB_EXTRAM_5
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_5 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_5

// Name:         UMCTL2_RRB_EXTRAM_6
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_6 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_6

// Name:         UMCTL2_RRB_EXTRAM_7
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_7 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_7

// Name:         UMCTL2_RRB_EXTRAM_8
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_8 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_8

// Name:         UMCTL2_RRB_EXTRAM_9
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_9 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_9

// Name:         UMCTL2_RRB_EXTRAM_10
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (10+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_10 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (10+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_10 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_10 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_10

// Name:         UMCTL2_RRB_EXTRAM_11
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (11+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_11 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (11+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_11 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_11 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_11

// Name:         UMCTL2_RRB_EXTRAM_12
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (12+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_12 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (12+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_12 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_12 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_12

// Name:         UMCTL2_RRB_EXTRAM_13
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (13+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_13 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (13+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_13 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_13 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_13

// Name:         UMCTL2_RRB_EXTRAM_14
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (14+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_14 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (14+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_14 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_14 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_14

// Name:         UMCTL2_RRB_EXTRAM_15
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (15+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_15 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (15+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_15 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_15 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_15


// Name:         UMCTL2_RRB_EXTRAM_REG_0
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_0 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_0 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_0

// Name:         UMCTL2_RRB_EXTRAM_REG_1
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_1 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_1 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_1

// Name:         UMCTL2_RRB_EXTRAM_REG_2
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_2 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_2 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_2

// Name:         UMCTL2_RRB_EXTRAM_REG_3
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_3 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_3 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_3

// Name:         UMCTL2_RRB_EXTRAM_REG_4
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_4 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_4 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_4

// Name:         UMCTL2_RRB_EXTRAM_REG_5
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_5 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_5 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_5

// Name:         UMCTL2_RRB_EXTRAM_REG_6
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_6 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_6 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_6

// Name:         UMCTL2_RRB_EXTRAM_REG_7
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_7 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_7 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_7

// Name:         UMCTL2_RRB_EXTRAM_REG_8
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_8 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_8 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_8

// Name:         UMCTL2_RRB_EXTRAM_REG_9
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_9 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_9 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_9

// Name:         UMCTL2_RRB_EXTRAM_REG_10
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_10 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_10 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_10

// Name:         UMCTL2_RRB_EXTRAM_REG_11
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_11 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_11 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_11

// Name:         UMCTL2_RRB_EXTRAM_REG_12
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_12 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_12 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_12

// Name:         UMCTL2_RRB_EXTRAM_REG_13
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_13 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_13 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_13

// Name:         UMCTL2_RRB_EXTRAM_REG_14
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_14 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_14 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_14

// Name:         UMCTL2_RRB_EXTRAM_REG_15
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_15 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_15 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_15



// Name:         UMCTL2_RRB_EXTRAM_RETIME_0
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_0 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_0 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_1
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_1 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_1 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_2
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_2 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_2 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_3
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_3 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_3 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_4
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_4 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_4 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_5
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_5 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_5 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_6
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_6 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_6 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_7
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_7 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_7 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_8
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_8 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_8 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_9
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_9 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_9 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_10
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_10 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_10 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_11
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_11 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_11 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_12
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_12 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_12 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_13
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_13 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_13 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_14
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_14 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_14 0
                                                                                                                                         

// Name:         UMCTL2_RRB_EXTRAM_RETIME_15
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_15 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_15 0
                                                                                                                                         



// Name:         UMCTL2_RRB_EXTRAM_TABLE
// Default:      1 ((UMCTL2_RRB_EXTRAM_15<<15) + (UMCTL2_RRB_EXTRAM_14<<14) + 
//               (UMCTL2_RRB_EXTRAM_13<<13) + (UMCTL2_RRB_EXTRAM_12<<12) + 
//               (UMCTL2_RRB_EXTRAM_11<<11) + (UMCTL2_RRB_EXTRAM_10<<10) + (UMCTL2_RRB_EXTRAM_9<<9) + 
//               (UMCTL2_RRB_EXTRAM_8<<8) + (UMCTL2_RRB_EXTRAM_7<<7) + 
//               (UMCTL2_RRB_EXTRAM_6<<6) + (UMCTL2_RRB_EXTRAM_5<<5) + (UMCTL2_RRB_EXTRAM_4<<4) + 
//               (UMCTL2_RRB_EXTRAM_3<<3) + (UMCTL2_RRB_EXTRAM_2<<2) + 
//               (UMCTL2_RRB_EXTRAM_1<<1) + UMCTL2_RRB_EXTRAM_0)
// Values:       -2147483648, ..., 65535
// 
// Table built from the list of UMCTL2_RRB_EXTRAM_<n>
`define UMCTL2_RRB_EXTRAM_TABLE 1


// Name:         UMCTL2_RRB_EXTRAM_REG_TABLE
// Default:      65535 ((UMCTL2_RRB_EXTRAM_REG_15<<15) + 
//               (UMCTL2_RRB_EXTRAM_REG_14<<14) + (UMCTL2_RRB_EXTRAM_REG_13<<13) + (UMCTL2_RRB_EXTRAM_REG_12<<12) 
//               + (UMCTL2_RRB_EXTRAM_REG_11<<11) + (UMCTL2_RRB_EXTRAM_REG_10<<10) + 
//               (UMCTL2_RRB_EXTRAM_REG_9<<9) + (UMCTL2_RRB_EXTRAM_REG_8<<8) + 
//               (UMCTL2_RRB_EXTRAM_REG_7<<7) + (UMCTL2_RRB_EXTRAM_REG_6<<6) + 
//               (UMCTL2_RRB_EXTRAM_REG_5<<5) + (UMCTL2_RRB_EXTRAM_REG_4<<4) + 
//               (UMCTL2_RRB_EXTRAM_REG_3<<3) + (UMCTL2_RRB_EXTRAM_REG_2<<2) + (UMCTL2_RRB_EXTRAM_REG_1<<1) 
//               + UMCTL2_RRB_EXTRAM_REG_0)
// Values:       -2147483648, ..., 65535
// 
// Table built from the list of UMCTL2_RRB_EXTRAM_REG_<n>
`define UMCTL2_RRB_EXTRAM_REG_TABLE 65535


// Name:         UMCTL2_A_NSAR
// Default:      0
// Values:       0, ..., 4
// Enabled:      UMCTL2_INCL_ARB == 1 && THEREIS_AHB_PORT == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Specifies the number of System Address Regions. 
//  
// Specifies how many distinct address regions to be decoded in the application system address space.  
//  - Minimum value 0 
//  - Maximum value 4 
//  - Default value 0 
// If set to 0, no regions are specified and addresses are assumed from the address 0.
`define UMCTL2_A_NSAR 0


`define THEREIS_SAR 0


// Name:         UMCTL2_SARMINSIZE
// Default:      256MB
// Values:       256MB (1), 512MB (2), 1GB (3), 2GB (4), 4GB (5), 8GB (6), 16GB (7), 
//               32GB (8)
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_A_NSAR > 0
// 
// Specifies the minimum block size for system address regions, ranging from 256 MB to 32GB.  
// Determines the number of most significant system addresss bits that are used to decode address regions. Base addresses 
// for each region must be aligned to this minimum block size.
`define UMCTL2_SARMINSIZE 1


// `define UMCTL2_A_SAR_0

// `define UMCTL2_A_SAR_1

// `define UMCTL2_A_SAR_2

// `define UMCTL2_A_SAR_3


// Maximum number of blocks that can be set to SAR region
`define UMCTL2_SAR_MAXNBLOCKS ((32'b1 << (`UMCTL2_A_ADDRW-27-`UMCTL2_SARMINSIZE)) - 1)

// Minimum SAR block size in bytes (2^27 shifted by the parameter)
`define UMCTL2_SAR_MINBLOCKSIZEBYTES ((128*1024*1024) << `UMCTL2_SARMINSIZE)
                                                 
// ----------------------------------------------------------------------------
// XPI parameters
// ----------------------------------------------------------------------------


// Name:         UMCTL2_XPI_USE_WAR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_XPI_USE_RMW == 0
// 
// Enables the XPI write address retime (that is, pipelines XPI write address output to PA). 
// This parameter introduces extra cycle of latency on the write address channel. 
// It can be used for multi-port configurations to improve timing. 
// A retime is automatically instantiated in the xpi RMW generator. Therefore, when RMW is used, this parameter is 
// disabled.
`define UMCTL2_XPI_USE_WAR 0


// Name:         UMCTL2_XPI_USE_RAR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1 && THEREIS_USE2RAQ == 0
// 
// Enables the XPI read address output retime (that is, pipelines XPI write address output to PA). 
// This parameter introduces extra cycle of latency on the read address channel. 
// It can be used for multi-port configurations to improve timing.
`define UMCTL2_XPI_USE_RAR 0


// Name:         UMCTL2_XPI_USE_INPUT_RAR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Enables the XPI read address input retime (that is, pipelines XPI write address input before the QoS mapper). 
// This parameter introduces extra cycle of latency on the read address channel. 
// It can be used to improve timing.
`define UMCTL2_XPI_USE_INPUT_RAR 0


// Name:         UMCTL2_XPI_USE_RDR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1
// 
// Enables the XPI RRB data retime (that is, pipelines XPI at the output of RRB). 
// This parameter introduces extra cycle of latency on the read data channel. 
// It can be used in dual data channel configurations to improve timing.
`define UMCTL2_XPI_USE_RDR 0


// Name:         UMCTL2_XPI_USE_RPR
// Default:      0
// Values:       0, 1
// Enabled:      (UMCTL2_INCL_ARB == 1 && (UMCTL2_OCPAR_EN == 1 || UMCTL2_OCECC_EN 
//               == 1))
// 
// Enables the XPI read data/parity retime (that is, pipelines XPI data and parity at the AXI interface). 
// This parameter introduces extra cycle of latency on the read data channel. 
// It can be used in on-chip parity configurations to improve timing.
`define UMCTL2_XPI_USE_RPR 0


//-----------------------------------------------
// Read-only but visible GUI derived parameters for interface signals
//-----------------------------------------------


// Name:         UMCTL2_WDATARAM_DW
// Default:      256 (UMCTL2_INCL_ARB == 0 && MEMC_SIDEBAND_ECC_EN==1) ? 
//               (MEMC_DRAM_DATA_WIDTH*MEMC_FREQ_RATIO*2+MEMC_DFI_ECC_WIDTH) : 
//               (MEMC_DRAM_DATA_WIDTH*MEMC_FREQ_RATIO*2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the data width of the external write data SRAM. It is an internal parameter provided in the GUI for 
// information purpose, and is derived from MEMC_DRAM_DATA_WIDTH, MEMC_FREQ_RATIO and MEMC_ECC_SUPPORT.
`define UMCTL2_WDATARAM_DW 256


// Name:         UMCTL2_WDATARAM_AW
// Default:      7 ((MEMC_WRDATA_8_CYCLES == 1) ? (MEMC_WRCMD_ENTRY_BITS + 3) : 
//               (MEMC_WRDATA_4_CYCLES == 1) ? (MEMC_WRCMD_ENTRY_BITS + 2) : 
//               (MEMC_WRCMD_ENTRY_BITS + 1))
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// specifies the address width of the external write data SRAM. It is an internal parameter provided in the GUI for 
// information purpose, and is derived from the CAM size (MEMC_NO_OF_ENTRY), MEMC_BURST_LENGTH and MEMC_FREQ_RATIO.
`define UMCTL2_WDATARAM_AW 7


// Name:         UMCTL2_WDATARAM_DEPTH
// Default:      128 (1<< UMCTL2_WDATARAM_AW)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the depth of the external write data SRAM. It is an internal parameter provided in the GUI for information 
// purpose, and is derived from the address width of the external write data SRAM (UMCTL2_WDATARAM_AW).
`define UMCTL2_WDATARAM_DEPTH 128


// Name:         UMCTL2_RDATARAM_DW
// Default:      257 ((MEMC_DRAM_DATA_WIDTH * MEMC_FREQ_RATIO * 2) + 1)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the Read Reorder Buffer (RRB) External Data RAM Interface Data Width.  
// It is an internal parameter provided in the GUI for information purpose.
`define UMCTL2_RDATARAM_DW 257


// Name:         UMCTL2_RDATARAM_DEPTH
// Default:      128 (MEMC_NO_OF_ENTRY * (MEMC_BURST_LENGTH/(MEMC_FREQ_RATIO*2)))
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the Read Reorder Buffer (RRB) External Data RAM Interface Depth. 
// It is an internal parameter provided in the GUI for information purpose.
`define UMCTL2_RDATARAM_DEPTH 128


// Name:         UMCTL2_RDATARAM_AW
// Default:      7 ([<functionof> MEMC_NO_OF_ENTRY MEMC_BURST_LENGTH 
//               MEMC_FREQ_RATIO])
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the Read Reorder Buffer (RRB) External Data RAM Interface Address Width. 
// It is an internal parameter provided in the GUI for information purpose.
`define UMCTL2_RDATARAM_AW 7


`define UMCTL2_DATARAM_PAR_DW 32


`define UMCTL2_WDATARAM_PAR_DW 32


`define UMCTL2_DATARAM_PAR_DW_LG2 5

//-----------------------------------------------
// DDRC Static Parameters
//-----------------------------------------------


`define MEMC_PAGE_BITS 18


`define MEMC_BLK_BITS 9

`define MEMC_WORD_BITS 3

// 2-bit command type encodings
`define MEMC_CMD_TYPE_BLK_WR        2'b00  // block write command
`define MEMC_CMD_TYPE_BLK_RD        2'b01  // read command
`define MEMC_CMD_TYPE_RMW           2'b10  // read-modify-write command
`define MEMC_CMD_TYPE_RESERVED      2'b11  // reserved

// 2-bit read priority encoding
`define MEMC_CMD_PRI_LPR            2'b00  // LP Read
`define MEMC_CMD_PRI_VPR            2'b01  // VP Read
`define MEMC_CMD_PRI_HPR            2'b10  // HP Read
`define MEMC_CMD_PRI_XVPR           2'b11  // Exp-VP Read - this value is reserved on the HIF bus, but used inside DDRC

// 2-bit write priority encoding
`define MEMC_CMD_PRI_NPW            2'b00  // NP Write - Normal Priority Write
`define MEMC_CMD_PRI_VPW            2'b01  // VP Write
`define MEMC_CMD_PRI_RSVD           2'b10  // Reserved
`define MEMC_CMD_PRI_XVPW           2'b11  // Exp-VP Write - this value is reserved on the HIF bus, but used inside DDRC
    
// 2-bit RMW type encodings
`define MEMC_RMW_TYPE_PARTIAL_NBW   2'b00  // indicates partial write
`define MEMC_RMW_TYPE_RMW_CMD       2'b01  // indicates a AIR (auto-increment)
`define MEMC_RMW_TYPE_SCRUB         2'b10  // indicates a scrub
`define MEMC_RMW_TYPE_NO_RMW        2'b11  //no RMW

// LPDDR4 write data pattern for DM/DBI
`define UMCTL2_LPDDR4_DQ_WHEN_MASKED 8'hF8  // To save power consumption this is used instead of 8'hFF when LPDDR4 write DQ is masked with enabling DBI

// DDR43 PHY/LPDDR4multiPHY V2 needs a specially encoded "IDLE" command over the DFI bus to make the Command/Address Hi-Z
// In 2T mode (or geardown), the PHY tristates the relevant pins when:
// DDR4 : All ranks DESelected (all CS_L==1) AND {ACT_n,RAS_n,CAS_n,WE_n,BA0} = {1,1,1,1,0} 
`define UMCTL2_PHY_SPECIAL_IDLE     5'b11110


// Name:         MEMC_ADDR_WIDTH_BITS
// Default:      18 ((MEMC_DDR4_EN == 1) ? 18 : (MEMC_LPDDR4_EN == 1) ? 17 : 16)
// Values:       -2147483648, ..., 2147483647
// 
// Used in Testbench only - not in RTL
`define MEMC_ADDR_WIDTH_BITS 18

//-----------------------------------------------
// AXI Static Parameters
//-----------------------------------------------

`define UMCTL2_AXI_BURST_WIDTH  2
`define UMCTL2_AXI_SIZE_WIDTH   3  
`define UMCTL2_AXI_CACHE_WIDTH  4
`define UMCTL2_AXI_PROT_WIDTH   3
`define UMCTL2_AXI_RESP_WIDTH   2


`define UMCTL2_XPI_RARD 2


`define UMCTL2_XPI_WARD 2


`define MEMC_DRAM_NBYTES 8


`define MEMC_DRAM_NBYTES_LG2 3


`define UMCTL2_OCPAR_ADDR_LOG_LOW_WIDTH 32


`define UMCTL2_OCPAR_SLICE_WIDTH 8


`define UMCTL2_OCPAR_POISON_DW 32

//-----------------------------------------------------------------------------
// AXI Dynamic Parameters
//-----------------------------------------------------------------------------


`define UMCTL2_MIN_ADDRW 36


// Name:         UMCTL2_A_ADDRW
// Default:      36 (UMCTL2_MIN_ADDRW)
// Values:       MEMC_HIF_MIN_ADDR_WIDTH, ..., 60
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application address. 
// A minimum value equal to UMCTL2_MIN_ADDRW is required to be able to address the maximum supported memory size. 
// If a value higher than UMCTL2_MIN_ADDRW is set and system address regions are not enabled, the exceeding MSBs are 
// ignored.
`define UMCTL2_A_ADDRW 36


`define UMCTL2_AXI_ADDRW 36


// Name:         UMCTL2_OCPAR_ADDR_PARITY_WIDTH
// Default:      Single bit
// Values:       Single bit (0), One bit per byte (1)
// Enabled:      UMCTL2_OCPAR_OR_OCECC_EN_1==1
// 
// Specifies the address parity width at AXI. 
// The options are: 
//  - Single parity bit 
//  - One bit per byte of address
`define UMCTL2_OCPAR_ADDR_PARITY_WIDTH 0


// Name:         UMCTL2_OCPAR_ADDR_PARITY_W
// Default:      1 ((UMCTL2_OCPAR_ADDR_PARITY_WIDTH == 0) ? 1 : [<functionof>])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_OCPAR_OR_OCECC_EN_1==1
// 
// On-Chip Parity Address Width Internal. 
// The value of this parameter depends on the value of UMCTL2_OCPAR_ADDR_PARITY_WIDTH and UMCTL2_A_ADDRW
`define UMCTL2_OCPAR_ADDR_PARITY_W 1



// Name:         UMCTL2_MAX_PL
// Default:      8 ((MEMC_FREQ_RATIO==2) ?  8 : 4)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Maximum packet lenght. 
// In x2 mode maximum burst supported BL16 => atomic packet len is 8 
// In x4 mode maximum burst supported BL16 => atomic packet len is 4
`define UMCTL2_MAX_PL 8



// Name:         UMCTL2_AXI_RAQD_0
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_0 32


// Name:         UMCTL2_AXI_WAQD_0
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_0 32


// Name:         UMCTL2_AXI_RDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_0 128


// Name:         UMCTL2_AXI_WDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_0 128


// Name:         UMCTL2_AXI_WRQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_0 64



// Name:         UMCTL2_AXI_RAQD_1
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_1 4


// Name:         UMCTL2_AXI_WAQD_1
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_1 4


// Name:         UMCTL2_AXI_RDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_1 10


// Name:         UMCTL2_AXI_WDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_1 10


// Name:         UMCTL2_AXI_WRQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_1 10



// Name:         UMCTL2_AXI_RAQD_2
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_2 4


// Name:         UMCTL2_AXI_WAQD_2
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_2 4


// Name:         UMCTL2_AXI_RDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_2 10


// Name:         UMCTL2_AXI_WDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_2 10


// Name:         UMCTL2_AXI_WRQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_2 10



// Name:         UMCTL2_AXI_RAQD_3
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_3 4


// Name:         UMCTL2_AXI_WAQD_3
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_3 4


// Name:         UMCTL2_AXI_RDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_3 10


// Name:         UMCTL2_AXI_WDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_3 10


// Name:         UMCTL2_AXI_WRQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_3 10



// Name:         UMCTL2_AXI_RAQD_4
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_4 4


// Name:         UMCTL2_AXI_WAQD_4
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_4 4


// Name:         UMCTL2_AXI_RDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_4 10


// Name:         UMCTL2_AXI_WDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_4 10


// Name:         UMCTL2_AXI_WRQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_4 10



// Name:         UMCTL2_AXI_RAQD_5
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_5 4


// Name:         UMCTL2_AXI_WAQD_5
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_5 4


// Name:         UMCTL2_AXI_RDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_5 10


// Name:         UMCTL2_AXI_WDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_5 10


// Name:         UMCTL2_AXI_WRQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_5 10



// Name:         UMCTL2_AXI_RAQD_6
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_6 4


// Name:         UMCTL2_AXI_WAQD_6
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_6 4


// Name:         UMCTL2_AXI_RDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_6 10


// Name:         UMCTL2_AXI_WDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_6 10


// Name:         UMCTL2_AXI_WRQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_6 10



// Name:         UMCTL2_AXI_RAQD_7
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_7 4


// Name:         UMCTL2_AXI_WAQD_7
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_7 4


// Name:         UMCTL2_AXI_RDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_7 10


// Name:         UMCTL2_AXI_WDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_7 10


// Name:         UMCTL2_AXI_WRQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_7 10



// Name:         UMCTL2_AXI_RAQD_8
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_8 4


// Name:         UMCTL2_AXI_WAQD_8
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_8 4


// Name:         UMCTL2_AXI_RDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_8 10


// Name:         UMCTL2_AXI_WDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_8 10


// Name:         UMCTL2_AXI_WRQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_8 10



// Name:         UMCTL2_AXI_RAQD_9
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_9 4


// Name:         UMCTL2_AXI_WAQD_9
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_9 4


// Name:         UMCTL2_AXI_RDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_9 10


// Name:         UMCTL2_AXI_WDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_9 10


// Name:         UMCTL2_AXI_WRQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_9 10



// Name:         UMCTL2_AXI_RAQD_10
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_10 4


// Name:         UMCTL2_AXI_WAQD_10
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_10 4


// Name:         UMCTL2_AXI_RDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_10 10


// Name:         UMCTL2_AXI_WDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_10 10


// Name:         UMCTL2_AXI_WRQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_10 10



// Name:         UMCTL2_AXI_RAQD_11
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_11 4


// Name:         UMCTL2_AXI_WAQD_11
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_11 4


// Name:         UMCTL2_AXI_RDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_11 10


// Name:         UMCTL2_AXI_WDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_11 10


// Name:         UMCTL2_AXI_WRQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_11 10



// Name:         UMCTL2_AXI_RAQD_12
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_12 4


// Name:         UMCTL2_AXI_WAQD_12
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_12 4


// Name:         UMCTL2_AXI_RDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_12 10


// Name:         UMCTL2_AXI_WDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_12 10


// Name:         UMCTL2_AXI_WRQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_12 10



// Name:         UMCTL2_AXI_RAQD_13
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_13 4


// Name:         UMCTL2_AXI_WAQD_13
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_13 4


// Name:         UMCTL2_AXI_RDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_13 10


// Name:         UMCTL2_AXI_WDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_13 10


// Name:         UMCTL2_AXI_WRQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_13 10



// Name:         UMCTL2_AXI_RAQD_14
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_14 4


// Name:         UMCTL2_AXI_WAQD_14
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_14 4


// Name:         UMCTL2_AXI_RDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_14 10


// Name:         UMCTL2_AXI_WDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_14 10


// Name:         UMCTL2_AXI_WRQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_14 10



// Name:         UMCTL2_AXI_RAQD_15
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_15 4


// Name:         UMCTL2_AXI_WAQD_15
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_15 4


// Name:         UMCTL2_AXI_RDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands.  
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_15 10


// Name:         UMCTL2_AXI_WDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application.  
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_15 10


// Name:         UMCTL2_AXI_WRQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1.  
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller  
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage  
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_15 10



// Name:         UMCTL2_XPI_SQD
// Default:      34
// Values:       4, ..., 64
// Enabled:      Always
// 
// Determines how many transactions can be stored in the size queue in xpi write.
`define UMCTL2_XPI_SQD 34


// Name:         UMCTL2_XPI_OUTS_WRW
// Default:      10
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determines how many outstanding write transactions can be accepted by xpi.
`define UMCTL2_XPI_OUTS_WRW 10


// Name:         UMCTL2_XPI_OUTS_RDW
// Default:      12
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determines how many outstanding read transactions can be accepted by xpi.
`define UMCTL2_XPI_OUTS_RDW 12


// Name:         UMCTL2_XPI_WDATA_PTR_QD
// Default:      64 (MEMC_NO_OF_ENTRY)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Determines how many write data pointer can be stored in the write data pointer queue in xpi write.
`define UMCTL2_XPI_WDATA_PTR_QD 64


// Name:         UMCTL2_PA_OPT_TYPE
// Default:      Combinatorial ((UMCTL2_INT_NPORTS == 1) ? 2 : 1)
// Values:       Two cycle (1), Combinatorial (2)
// Enabled:      Always
// 
// Specifies the type of optimization required for the Port Arbiter block 
// The options are: 
//  1) two-cycle arbitration (1 cycle of idle latency) 
//  2) combinatorial (0 cycle of idle latency)
`define UMCTL2_PA_OPT_TYPE 2


// `define UMCTL2_PA_OPT_TYPE_TWOCYCLE


`define UMCTL2_PA_OPT_TYPE_COMB


// Name:         UMCTL2_PAGEMATCH_EN
// Default:      1 ((UPCTL2_EN == 0) ? 1 : 0)
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB==1 && UPCTL2_EN==0
// 
// Enables Port Arbiter (PA) pagematch feature in the hardware.  
// This feature is not recommended if there is a timing closure challenge due to PA.  
// For instance, when there are many ports, the pagematch feature can be disabled to improve 
// synthesis timing.
`define UMCTL2_PAGEMATCH_EN 1
                                                         

// Name:         UMCTL2_XPI_RMW_WDQD
// Default:      6 (MEMC_FREQ_RATIO==1) ? ((UMCTL2_PA_OPT_TYPE==1) ? 
//               (MEMC_BURST_LENGTH+2) : MEMC_BURST_LENGTH) : ((UMCTL2_PA_OPT_TYPE==1) ? 
//               MEMC_BURST_LENGTH : ((MEMC_BURST_LENGTH/MEMC_FREQ_RATIO)+2))
// Values:       2, ..., 18
// Enabled:      0
// 
// Determines the depth of the store and forward queue in xpi RMW generator.
`define UMCTL2_XPI_RMW_WDQD 6


// Name:         UMCTL2_XPI_RMW_WARD
// Default:      2 (MEMC_FREQ_RATIO == 1) ? 2 : ((UMCTL2_PA_OPT_TYPE==1) ? 4 : 2)
// Values:       2, ..., 4
// Enabled:      0
// 
// Determines the depth of the retime in xpi RMW generator.
`define UMCTL2_XPI_RMW_WARD 2

//----------------------------------------
// Derived parameters
//----------------------------------------

`define UMCTL2_SINGLE_PORT_1


`define UMCTL2_SINGLE_PORT 1


`define UMCTL2_OCPAR_ADDR_LOG_USE_MSB


`define UMCTL2_OCPAR_ADDR_LOG_HIGH_WIDTH 4


//UMCTL2_PORT_CH0_0:

// `define UMCTL2_PORT_CH0_0

//UMCTL2_PORT_CH1_0:

// `define UMCTL2_PORT_CH1_0

//UMCTL2_PORT_CH2_0:

// `define UMCTL2_PORT_CH2_0

//UMCTL2_PORT_CH3_0:

// `define UMCTL2_PORT_CH3_0

//UMCTL2_PORT_CH4_0:

// `define UMCTL2_PORT_CH4_0

//UMCTL2_PORT_CH5_0:

// `define UMCTL2_PORT_CH5_0

//UMCTL2_PORT_CH6_0:

// `define UMCTL2_PORT_CH6_0

//UMCTL2_PORT_CH7_0:

// `define UMCTL2_PORT_CH7_0

//UMCTL2_PORT_CH8_0:

// `define UMCTL2_PORT_CH8_0

//UMCTL2_PORT_CH9_0:

// `define UMCTL2_PORT_CH9_0

//UMCTL2_PORT_CH10_0:

// `define UMCTL2_PORT_CH10_0

//UMCTL2_PORT_CH11_0:

// `define UMCTL2_PORT_CH11_0

//UMCTL2_PORT_CH12_0:

// `define UMCTL2_PORT_CH12_0

//UMCTL2_PORT_CH13_0:

// `define UMCTL2_PORT_CH13_0

//UMCTL2_PORT_CH14_0:

// `define UMCTL2_PORT_CH14_0

//UMCTL2_PORT_CH15_0:

// `define UMCTL2_PORT_CH15_0


//UMCTL2_PORT_CH0_1:

// `define UMCTL2_PORT_CH0_1

//UMCTL2_PORT_CH1_1:

// `define UMCTL2_PORT_CH1_1

//UMCTL2_PORT_CH2_1:

// `define UMCTL2_PORT_CH2_1

//UMCTL2_PORT_CH3_1:

// `define UMCTL2_PORT_CH3_1

//UMCTL2_PORT_CH4_1:

// `define UMCTL2_PORT_CH4_1

//UMCTL2_PORT_CH5_1:

// `define UMCTL2_PORT_CH5_1

//UMCTL2_PORT_CH6_1:

// `define UMCTL2_PORT_CH6_1

//UMCTL2_PORT_CH7_1:

// `define UMCTL2_PORT_CH7_1

//UMCTL2_PORT_CH8_1:

// `define UMCTL2_PORT_CH8_1

//UMCTL2_PORT_CH9_1:

// `define UMCTL2_PORT_CH9_1

//UMCTL2_PORT_CH10_1:

// `define UMCTL2_PORT_CH10_1

//UMCTL2_PORT_CH11_1:

// `define UMCTL2_PORT_CH11_1

//UMCTL2_PORT_CH12_1:

// `define UMCTL2_PORT_CH12_1

//UMCTL2_PORT_CH13_1:

// `define UMCTL2_PORT_CH13_1

//UMCTL2_PORT_CH14_1:

// `define UMCTL2_PORT_CH14_1

//UMCTL2_PORT_CH15_1:

// `define UMCTL2_PORT_CH15_1


//UMCTL2_PORT_CH0_2:

// `define UMCTL2_PORT_CH0_2

//UMCTL2_PORT_CH1_2:

// `define UMCTL2_PORT_CH1_2

//UMCTL2_PORT_CH2_2:

// `define UMCTL2_PORT_CH2_2

//UMCTL2_PORT_CH3_2:

// `define UMCTL2_PORT_CH3_2

//UMCTL2_PORT_CH4_2:

// `define UMCTL2_PORT_CH4_2

//UMCTL2_PORT_CH5_2:

// `define UMCTL2_PORT_CH5_2

//UMCTL2_PORT_CH6_2:

// `define UMCTL2_PORT_CH6_2

//UMCTL2_PORT_CH7_2:

// `define UMCTL2_PORT_CH7_2

//UMCTL2_PORT_CH8_2:

// `define UMCTL2_PORT_CH8_2

//UMCTL2_PORT_CH9_2:

// `define UMCTL2_PORT_CH9_2

//UMCTL2_PORT_CH10_2:

// `define UMCTL2_PORT_CH10_2

//UMCTL2_PORT_CH11_2:

// `define UMCTL2_PORT_CH11_2

//UMCTL2_PORT_CH12_2:

// `define UMCTL2_PORT_CH12_2

//UMCTL2_PORT_CH13_2:

// `define UMCTL2_PORT_CH13_2

//UMCTL2_PORT_CH14_2:

// `define UMCTL2_PORT_CH14_2

//UMCTL2_PORT_CH15_2:

// `define UMCTL2_PORT_CH15_2


//UMCTL2_PORT_CH0_3:

// `define UMCTL2_PORT_CH0_3

//UMCTL2_PORT_CH1_3:

// `define UMCTL2_PORT_CH1_3

//UMCTL2_PORT_CH2_3:

// `define UMCTL2_PORT_CH2_3

//UMCTL2_PORT_CH3_3:

// `define UMCTL2_PORT_CH3_3

//UMCTL2_PORT_CH4_3:

// `define UMCTL2_PORT_CH4_3

//UMCTL2_PORT_CH5_3:

// `define UMCTL2_PORT_CH5_3

//UMCTL2_PORT_CH6_3:

// `define UMCTL2_PORT_CH6_3

//UMCTL2_PORT_CH7_3:

// `define UMCTL2_PORT_CH7_3

//UMCTL2_PORT_CH8_3:

// `define UMCTL2_PORT_CH8_3

//UMCTL2_PORT_CH9_3:

// `define UMCTL2_PORT_CH9_3

//UMCTL2_PORT_CH10_3:

// `define UMCTL2_PORT_CH10_3

//UMCTL2_PORT_CH11_3:

// `define UMCTL2_PORT_CH11_3

//UMCTL2_PORT_CH12_3:

// `define UMCTL2_PORT_CH12_3

//UMCTL2_PORT_CH13_3:

// `define UMCTL2_PORT_CH13_3

//UMCTL2_PORT_CH14_3:

// `define UMCTL2_PORT_CH14_3

//UMCTL2_PORT_CH15_3:

// `define UMCTL2_PORT_CH15_3


//UMCTL2_PORT_CH0_4:

// `define UMCTL2_PORT_CH0_4

//UMCTL2_PORT_CH1_4:

// `define UMCTL2_PORT_CH1_4

//UMCTL2_PORT_CH2_4:

// `define UMCTL2_PORT_CH2_4

//UMCTL2_PORT_CH3_4:

// `define UMCTL2_PORT_CH3_4

//UMCTL2_PORT_CH4_4:

// `define UMCTL2_PORT_CH4_4

//UMCTL2_PORT_CH5_4:

// `define UMCTL2_PORT_CH5_4

//UMCTL2_PORT_CH6_4:

// `define UMCTL2_PORT_CH6_4

//UMCTL2_PORT_CH7_4:

// `define UMCTL2_PORT_CH7_4

//UMCTL2_PORT_CH8_4:

// `define UMCTL2_PORT_CH8_4

//UMCTL2_PORT_CH9_4:

// `define UMCTL2_PORT_CH9_4

//UMCTL2_PORT_CH10_4:

// `define UMCTL2_PORT_CH10_4

//UMCTL2_PORT_CH11_4:

// `define UMCTL2_PORT_CH11_4

//UMCTL2_PORT_CH12_4:

// `define UMCTL2_PORT_CH12_4

//UMCTL2_PORT_CH13_4:

// `define UMCTL2_PORT_CH13_4

//UMCTL2_PORT_CH14_4:

// `define UMCTL2_PORT_CH14_4

//UMCTL2_PORT_CH15_4:

// `define UMCTL2_PORT_CH15_4


//UMCTL2_PORT_CH0_5:

// `define UMCTL2_PORT_CH0_5

//UMCTL2_PORT_CH1_5:

// `define UMCTL2_PORT_CH1_5

//UMCTL2_PORT_CH2_5:

// `define UMCTL2_PORT_CH2_5

//UMCTL2_PORT_CH3_5:

// `define UMCTL2_PORT_CH3_5

//UMCTL2_PORT_CH4_5:

// `define UMCTL2_PORT_CH4_5

//UMCTL2_PORT_CH5_5:

// `define UMCTL2_PORT_CH5_5

//UMCTL2_PORT_CH6_5:

// `define UMCTL2_PORT_CH6_5

//UMCTL2_PORT_CH7_5:

// `define UMCTL2_PORT_CH7_5

//UMCTL2_PORT_CH8_5:

// `define UMCTL2_PORT_CH8_5

//UMCTL2_PORT_CH9_5:

// `define UMCTL2_PORT_CH9_5

//UMCTL2_PORT_CH10_5:

// `define UMCTL2_PORT_CH10_5

//UMCTL2_PORT_CH11_5:

// `define UMCTL2_PORT_CH11_5

//UMCTL2_PORT_CH12_5:

// `define UMCTL2_PORT_CH12_5

//UMCTL2_PORT_CH13_5:

// `define UMCTL2_PORT_CH13_5

//UMCTL2_PORT_CH14_5:

// `define UMCTL2_PORT_CH14_5

//UMCTL2_PORT_CH15_5:

// `define UMCTL2_PORT_CH15_5


//UMCTL2_PORT_CH0_6:

// `define UMCTL2_PORT_CH0_6

//UMCTL2_PORT_CH1_6:

// `define UMCTL2_PORT_CH1_6

//UMCTL2_PORT_CH2_6:

// `define UMCTL2_PORT_CH2_6

//UMCTL2_PORT_CH3_6:

// `define UMCTL2_PORT_CH3_6

//UMCTL2_PORT_CH4_6:

// `define UMCTL2_PORT_CH4_6

//UMCTL2_PORT_CH5_6:

// `define UMCTL2_PORT_CH5_6

//UMCTL2_PORT_CH6_6:

// `define UMCTL2_PORT_CH6_6

//UMCTL2_PORT_CH7_6:

// `define UMCTL2_PORT_CH7_6

//UMCTL2_PORT_CH8_6:

// `define UMCTL2_PORT_CH8_6

//UMCTL2_PORT_CH9_6:

// `define UMCTL2_PORT_CH9_6

//UMCTL2_PORT_CH10_6:

// `define UMCTL2_PORT_CH10_6

//UMCTL2_PORT_CH11_6:

// `define UMCTL2_PORT_CH11_6

//UMCTL2_PORT_CH12_6:

// `define UMCTL2_PORT_CH12_6

//UMCTL2_PORT_CH13_6:

// `define UMCTL2_PORT_CH13_6

//UMCTL2_PORT_CH14_6:

// `define UMCTL2_PORT_CH14_6

//UMCTL2_PORT_CH15_6:

// `define UMCTL2_PORT_CH15_6


//UMCTL2_PORT_CH0_7:

// `define UMCTL2_PORT_CH0_7

//UMCTL2_PORT_CH1_7:

// `define UMCTL2_PORT_CH1_7

//UMCTL2_PORT_CH2_7:

// `define UMCTL2_PORT_CH2_7

//UMCTL2_PORT_CH3_7:

// `define UMCTL2_PORT_CH3_7

//UMCTL2_PORT_CH4_7:

// `define UMCTL2_PORT_CH4_7

//UMCTL2_PORT_CH5_7:

// `define UMCTL2_PORT_CH5_7

//UMCTL2_PORT_CH6_7:

// `define UMCTL2_PORT_CH6_7

//UMCTL2_PORT_CH7_7:

// `define UMCTL2_PORT_CH7_7

//UMCTL2_PORT_CH8_7:

// `define UMCTL2_PORT_CH8_7

//UMCTL2_PORT_CH9_7:

// `define UMCTL2_PORT_CH9_7

//UMCTL2_PORT_CH10_7:

// `define UMCTL2_PORT_CH10_7

//UMCTL2_PORT_CH11_7:

// `define UMCTL2_PORT_CH11_7

//UMCTL2_PORT_CH12_7:

// `define UMCTL2_PORT_CH12_7

//UMCTL2_PORT_CH13_7:

// `define UMCTL2_PORT_CH13_7

//UMCTL2_PORT_CH14_7:

// `define UMCTL2_PORT_CH14_7

//UMCTL2_PORT_CH15_7:

// `define UMCTL2_PORT_CH15_7


//UMCTL2_PORT_CH0_8:

// `define UMCTL2_PORT_CH0_8

//UMCTL2_PORT_CH1_8:

// `define UMCTL2_PORT_CH1_8

//UMCTL2_PORT_CH2_8:

// `define UMCTL2_PORT_CH2_8

//UMCTL2_PORT_CH3_8:

// `define UMCTL2_PORT_CH3_8

//UMCTL2_PORT_CH4_8:

// `define UMCTL2_PORT_CH4_8

//UMCTL2_PORT_CH5_8:

// `define UMCTL2_PORT_CH5_8

//UMCTL2_PORT_CH6_8:

// `define UMCTL2_PORT_CH6_8

//UMCTL2_PORT_CH7_8:

// `define UMCTL2_PORT_CH7_8

//UMCTL2_PORT_CH8_8:

// `define UMCTL2_PORT_CH8_8

//UMCTL2_PORT_CH9_8:

// `define UMCTL2_PORT_CH9_8

//UMCTL2_PORT_CH10_8:

// `define UMCTL2_PORT_CH10_8

//UMCTL2_PORT_CH11_8:

// `define UMCTL2_PORT_CH11_8

//UMCTL2_PORT_CH12_8:

// `define UMCTL2_PORT_CH12_8

//UMCTL2_PORT_CH13_8:

// `define UMCTL2_PORT_CH13_8

//UMCTL2_PORT_CH14_8:

// `define UMCTL2_PORT_CH14_8

//UMCTL2_PORT_CH15_8:

// `define UMCTL2_PORT_CH15_8


//UMCTL2_PORT_CH0_9:

// `define UMCTL2_PORT_CH0_9

//UMCTL2_PORT_CH1_9:

// `define UMCTL2_PORT_CH1_9

//UMCTL2_PORT_CH2_9:

// `define UMCTL2_PORT_CH2_9

//UMCTL2_PORT_CH3_9:

// `define UMCTL2_PORT_CH3_9

//UMCTL2_PORT_CH4_9:

// `define UMCTL2_PORT_CH4_9

//UMCTL2_PORT_CH5_9:

// `define UMCTL2_PORT_CH5_9

//UMCTL2_PORT_CH6_9:

// `define UMCTL2_PORT_CH6_9

//UMCTL2_PORT_CH7_9:

// `define UMCTL2_PORT_CH7_9

//UMCTL2_PORT_CH8_9:

// `define UMCTL2_PORT_CH8_9

//UMCTL2_PORT_CH9_9:

// `define UMCTL2_PORT_CH9_9

//UMCTL2_PORT_CH10_9:

// `define UMCTL2_PORT_CH10_9

//UMCTL2_PORT_CH11_9:

// `define UMCTL2_PORT_CH11_9

//UMCTL2_PORT_CH12_9:

// `define UMCTL2_PORT_CH12_9

//UMCTL2_PORT_CH13_9:

// `define UMCTL2_PORT_CH13_9

//UMCTL2_PORT_CH14_9:

// `define UMCTL2_PORT_CH14_9

//UMCTL2_PORT_CH15_9:

// `define UMCTL2_PORT_CH15_9


//UMCTL2_PORT_CH0_10:

// `define UMCTL2_PORT_CH0_10

//UMCTL2_PORT_CH1_10:

// `define UMCTL2_PORT_CH1_10

//UMCTL2_PORT_CH2_10:

// `define UMCTL2_PORT_CH2_10

//UMCTL2_PORT_CH3_10:

// `define UMCTL2_PORT_CH3_10

//UMCTL2_PORT_CH4_10:

// `define UMCTL2_PORT_CH4_10

//UMCTL2_PORT_CH5_10:

// `define UMCTL2_PORT_CH5_10

//UMCTL2_PORT_CH6_10:

// `define UMCTL2_PORT_CH6_10

//UMCTL2_PORT_CH7_10:

// `define UMCTL2_PORT_CH7_10

//UMCTL2_PORT_CH8_10:

// `define UMCTL2_PORT_CH8_10

//UMCTL2_PORT_CH9_10:

// `define UMCTL2_PORT_CH9_10

//UMCTL2_PORT_CH10_10:

// `define UMCTL2_PORT_CH10_10

//UMCTL2_PORT_CH11_10:

// `define UMCTL2_PORT_CH11_10

//UMCTL2_PORT_CH12_10:

// `define UMCTL2_PORT_CH12_10

//UMCTL2_PORT_CH13_10:

// `define UMCTL2_PORT_CH13_10

//UMCTL2_PORT_CH14_10:

// `define UMCTL2_PORT_CH14_10

//UMCTL2_PORT_CH15_10:

// `define UMCTL2_PORT_CH15_10


//UMCTL2_PORT_CH0_11:

// `define UMCTL2_PORT_CH0_11

//UMCTL2_PORT_CH1_11:

// `define UMCTL2_PORT_CH1_11

//UMCTL2_PORT_CH2_11:

// `define UMCTL2_PORT_CH2_11

//UMCTL2_PORT_CH3_11:

// `define UMCTL2_PORT_CH3_11

//UMCTL2_PORT_CH4_11:

// `define UMCTL2_PORT_CH4_11

//UMCTL2_PORT_CH5_11:

// `define UMCTL2_PORT_CH5_11

//UMCTL2_PORT_CH6_11:

// `define UMCTL2_PORT_CH6_11

//UMCTL2_PORT_CH7_11:

// `define UMCTL2_PORT_CH7_11

//UMCTL2_PORT_CH8_11:

// `define UMCTL2_PORT_CH8_11

//UMCTL2_PORT_CH9_11:

// `define UMCTL2_PORT_CH9_11

//UMCTL2_PORT_CH10_11:

// `define UMCTL2_PORT_CH10_11

//UMCTL2_PORT_CH11_11:

// `define UMCTL2_PORT_CH11_11

//UMCTL2_PORT_CH12_11:

// `define UMCTL2_PORT_CH12_11

//UMCTL2_PORT_CH13_11:

// `define UMCTL2_PORT_CH13_11

//UMCTL2_PORT_CH14_11:

// `define UMCTL2_PORT_CH14_11

//UMCTL2_PORT_CH15_11:

// `define UMCTL2_PORT_CH15_11


//UMCTL2_PORT_CH0_12:

// `define UMCTL2_PORT_CH0_12

//UMCTL2_PORT_CH1_12:

// `define UMCTL2_PORT_CH1_12

//UMCTL2_PORT_CH2_12:

// `define UMCTL2_PORT_CH2_12

//UMCTL2_PORT_CH3_12:

// `define UMCTL2_PORT_CH3_12

//UMCTL2_PORT_CH4_12:

// `define UMCTL2_PORT_CH4_12

//UMCTL2_PORT_CH5_12:

// `define UMCTL2_PORT_CH5_12

//UMCTL2_PORT_CH6_12:

// `define UMCTL2_PORT_CH6_12

//UMCTL2_PORT_CH7_12:

// `define UMCTL2_PORT_CH7_12

//UMCTL2_PORT_CH8_12:

// `define UMCTL2_PORT_CH8_12

//UMCTL2_PORT_CH9_12:

// `define UMCTL2_PORT_CH9_12

//UMCTL2_PORT_CH10_12:

// `define UMCTL2_PORT_CH10_12

//UMCTL2_PORT_CH11_12:

// `define UMCTL2_PORT_CH11_12

//UMCTL2_PORT_CH12_12:

// `define UMCTL2_PORT_CH12_12

//UMCTL2_PORT_CH13_12:

// `define UMCTL2_PORT_CH13_12

//UMCTL2_PORT_CH14_12:

// `define UMCTL2_PORT_CH14_12

//UMCTL2_PORT_CH15_12:

// `define UMCTL2_PORT_CH15_12


//UMCTL2_PORT_CH0_13:

// `define UMCTL2_PORT_CH0_13

//UMCTL2_PORT_CH1_13:

// `define UMCTL2_PORT_CH1_13

//UMCTL2_PORT_CH2_13:

// `define UMCTL2_PORT_CH2_13

//UMCTL2_PORT_CH3_13:

// `define UMCTL2_PORT_CH3_13

//UMCTL2_PORT_CH4_13:

// `define UMCTL2_PORT_CH4_13

//UMCTL2_PORT_CH5_13:

// `define UMCTL2_PORT_CH5_13

//UMCTL2_PORT_CH6_13:

// `define UMCTL2_PORT_CH6_13

//UMCTL2_PORT_CH7_13:

// `define UMCTL2_PORT_CH7_13

//UMCTL2_PORT_CH8_13:

// `define UMCTL2_PORT_CH8_13

//UMCTL2_PORT_CH9_13:

// `define UMCTL2_PORT_CH9_13

//UMCTL2_PORT_CH10_13:

// `define UMCTL2_PORT_CH10_13

//UMCTL2_PORT_CH11_13:

// `define UMCTL2_PORT_CH11_13

//UMCTL2_PORT_CH12_13:

// `define UMCTL2_PORT_CH12_13

//UMCTL2_PORT_CH13_13:

// `define UMCTL2_PORT_CH13_13

//UMCTL2_PORT_CH14_13:

// `define UMCTL2_PORT_CH14_13

//UMCTL2_PORT_CH15_13:

// `define UMCTL2_PORT_CH15_13


//UMCTL2_PORT_CH0_14:

// `define UMCTL2_PORT_CH0_14

//UMCTL2_PORT_CH1_14:

// `define UMCTL2_PORT_CH1_14

//UMCTL2_PORT_CH2_14:

// `define UMCTL2_PORT_CH2_14

//UMCTL2_PORT_CH3_14:

// `define UMCTL2_PORT_CH3_14

//UMCTL2_PORT_CH4_14:

// `define UMCTL2_PORT_CH4_14

//UMCTL2_PORT_CH5_14:

// `define UMCTL2_PORT_CH5_14

//UMCTL2_PORT_CH6_14:

// `define UMCTL2_PORT_CH6_14

//UMCTL2_PORT_CH7_14:

// `define UMCTL2_PORT_CH7_14

//UMCTL2_PORT_CH8_14:

// `define UMCTL2_PORT_CH8_14

//UMCTL2_PORT_CH9_14:

// `define UMCTL2_PORT_CH9_14

//UMCTL2_PORT_CH10_14:

// `define UMCTL2_PORT_CH10_14

//UMCTL2_PORT_CH11_14:

// `define UMCTL2_PORT_CH11_14

//UMCTL2_PORT_CH12_14:

// `define UMCTL2_PORT_CH12_14

//UMCTL2_PORT_CH13_14:

// `define UMCTL2_PORT_CH13_14

//UMCTL2_PORT_CH14_14:

// `define UMCTL2_PORT_CH14_14

//UMCTL2_PORT_CH15_14:

// `define UMCTL2_PORT_CH15_14


//UMCTL2_PORT_CH0_15:

// `define UMCTL2_PORT_CH0_15

//UMCTL2_PORT_CH1_15:

// `define UMCTL2_PORT_CH1_15

//UMCTL2_PORT_CH2_15:

// `define UMCTL2_PORT_CH2_15

//UMCTL2_PORT_CH3_15:

// `define UMCTL2_PORT_CH3_15

//UMCTL2_PORT_CH4_15:

// `define UMCTL2_PORT_CH4_15

//UMCTL2_PORT_CH5_15:

// `define UMCTL2_PORT_CH5_15

//UMCTL2_PORT_CH6_15:

// `define UMCTL2_PORT_CH6_15

//UMCTL2_PORT_CH7_15:

// `define UMCTL2_PORT_CH7_15

//UMCTL2_PORT_CH8_15:

// `define UMCTL2_PORT_CH8_15

//UMCTL2_PORT_CH9_15:

// `define UMCTL2_PORT_CH9_15

//UMCTL2_PORT_CH10_15:

// `define UMCTL2_PORT_CH10_15

//UMCTL2_PORT_CH11_15:

// `define UMCTL2_PORT_CH11_15

//UMCTL2_PORT_CH12_15:

// `define UMCTL2_PORT_CH12_15

//UMCTL2_PORT_CH13_15:

// `define UMCTL2_PORT_CH13_15

//UMCTL2_PORT_CH14_15:

// `define UMCTL2_PORT_CH14_15

//UMCTL2_PORT_CH15_15:

// `define UMCTL2_PORT_CH15_15



`define UMCTL2_SAR_MIN_ADDRW 28


`define UMCTL2_AXI_SAR_BW 1


`define UMCTL2_AXI_SAR_REG_BW 2


`define UMCTL2_AXI_SAR_SW 1


// Name:         UMCTL2_ECC_TEST_MODE_EN
// Default:      0 ((UMCTL2_INCL_ARB == 0 && MEMC_SIDEBAND_ECC_EN==1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_ECC_TEST_MODE_EN 
// Enables the ECC test_mode. Only enabled for HIF ECC configurations
// `define UMCTL2_ECC_TEST_MODE_EN


//-----------------------------------------------------------------------------
// AHB PORT
//-----------------------------------------------------------------------------


// Name:         UMCTL2_AHB_LITE_MODE_0
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_0==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_0 0

// Name:         UMCTL2_AHB_LITE_MODE_1
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_1==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_1 0

// Name:         UMCTL2_AHB_LITE_MODE_2
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_2==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_2 0

// Name:         UMCTL2_AHB_LITE_MODE_3
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_3==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_3 0

// Name:         UMCTL2_AHB_LITE_MODE_4
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_4==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_4 0

// Name:         UMCTL2_AHB_LITE_MODE_5
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_5==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_5 0

// Name:         UMCTL2_AHB_LITE_MODE_6
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_6==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_6 0

// Name:         UMCTL2_AHB_LITE_MODE_7
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_7==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_7 0

// Name:         UMCTL2_AHB_LITE_MODE_8
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_8==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_8 0

// Name:         UMCTL2_AHB_LITE_MODE_9
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_9==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_9 0

// Name:         UMCTL2_AHB_LITE_MODE_10
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_10==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_10 0

// Name:         UMCTL2_AHB_LITE_MODE_11
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_11==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_11 0

// Name:         UMCTL2_AHB_LITE_MODE_12
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_12==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_12 0

// Name:         UMCTL2_AHB_LITE_MODE_13
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_13==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_13 0

// Name:         UMCTL2_AHB_LITE_MODE_14
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_14==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_14 0

// Name:         UMCTL2_AHB_LITE_MODE_15
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_AHB_15==1
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode.  
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_15 0


// Name:         UMCTL2_AHB_LITE_MODE_TABLE
// Default:      0x0 ( (UMCTL2_AHB_LITE_MODE_15<<15) + (UMCTL2_AHB_LITE_MODE_14<<14) 
//               + (UMCTL2_AHB_LITE_MODE_13<<13) + (UMCTL2_AHB_LITE_MODE_12<<12) + 
//               (UMCTL2_AHB_LITE_MODE_11<<11) + (UMCTL2_AHB_LITE_MODE_10<<10) + 
//               (UMCTL2_AHB_LITE_MODE_9<<9) + (UMCTL2_AHB_LITE_MODE_8<<8) + 
//               (UMCTL2_AHB_LITE_MODE_7<<7) + (UMCTL2_AHB_LITE_MODE_6<<6) + 
//               (UMCTL2_AHB_LITE_MODE_5<<5) + (UMCTL2_AHB_LITE_MODE_4<<4) + (UMCTL2_AHB_LITE_MODE_3<<3) + 
//               (UMCTL2_AHB_LITE_MODE_2<<2) + (UMCTL2_AHB_LITE_MODE_1<<1) + 
//               UMCTL2_AHB_LITE_MODE_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_AHB_LITE_MODE_<n>
`define UMCTL2_AHB_LITE_MODE_TABLE 16'h0


// Name:         UMCTL2_AHB_SPLIT_MODE_0
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_0==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_0==1) && (UMCTL2_AHB_LITE_MODE_0==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_0 1

// Name:         UMCTL2_AHB_SPLIT_MODE_1
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_1==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_1==1) && (UMCTL2_AHB_LITE_MODE_1==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_1 1

// Name:         UMCTL2_AHB_SPLIT_MODE_2
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_2==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_2==1) && (UMCTL2_AHB_LITE_MODE_2==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_2 1

// Name:         UMCTL2_AHB_SPLIT_MODE_3
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_3==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_3==1) && (UMCTL2_AHB_LITE_MODE_3==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_3 1

// Name:         UMCTL2_AHB_SPLIT_MODE_4
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_4==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_4==1) && (UMCTL2_AHB_LITE_MODE_4==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_4 1

// Name:         UMCTL2_AHB_SPLIT_MODE_5
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_5==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_5==1) && (UMCTL2_AHB_LITE_MODE_5==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_5 1

// Name:         UMCTL2_AHB_SPLIT_MODE_6
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_6==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_6==1) && (UMCTL2_AHB_LITE_MODE_6==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_6 1

// Name:         UMCTL2_AHB_SPLIT_MODE_7
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_7==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_7==1) && (UMCTL2_AHB_LITE_MODE_7==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_7 1

// Name:         UMCTL2_AHB_SPLIT_MODE_8
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_8==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_8==1) && (UMCTL2_AHB_LITE_MODE_8==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_8 1

// Name:         UMCTL2_AHB_SPLIT_MODE_9
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_9==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_9==1) && (UMCTL2_AHB_LITE_MODE_9==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_9 1

// Name:         UMCTL2_AHB_SPLIT_MODE_10
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_10==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_10==1) && (UMCTL2_AHB_LITE_MODE_10==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_10 1

// Name:         UMCTL2_AHB_SPLIT_MODE_11
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_11==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_11==1) && (UMCTL2_AHB_LITE_MODE_11==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_11 1

// Name:         UMCTL2_AHB_SPLIT_MODE_12
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_12==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_12==1) && (UMCTL2_AHB_LITE_MODE_12==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_12 1

// Name:         UMCTL2_AHB_SPLIT_MODE_13
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_13==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_13==1) && (UMCTL2_AHB_LITE_MODE_13==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_13 1

// Name:         UMCTL2_AHB_SPLIT_MODE_14
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_14==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_14==1) && (UMCTL2_AHB_LITE_MODE_14==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_14 1

// Name:         UMCTL2_AHB_SPLIT_MODE_15
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_15==0 && UPCTL2_EN==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      (UMCTL2_A_AHB_15==1) && (UMCTL2_AHB_LITE_MODE_15==0)
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_15 1


// Name:         UMCTL2_AHB_SPLIT_MODE_TABLE
// Default:      0xffff ( (UMCTL2_AHB_SPLIT_MODE_15<<15) + 
//               (UMCTL2_AHB_SPLIT_MODE_14<<14) + (UMCTL2_AHB_SPLIT_MODE_13<<13) + 
//               (UMCTL2_AHB_SPLIT_MODE_12<<12) + (UMCTL2_AHB_SPLIT_MODE_11<<11) + (UMCTL2_AHB_SPLIT_MODE_10<<10) 
//               + (UMCTL2_AHB_SPLIT_MODE_9<<9) + (UMCTL2_AHB_SPLIT_MODE_8<<8) + 
//               (UMCTL2_AHB_SPLIT_MODE_7<<7) + (UMCTL2_AHB_SPLIT_MODE_6<<6) + 
//               (UMCTL2_AHB_SPLIT_MODE_5<<5) + (UMCTL2_AHB_SPLIT_MODE_4<<4) + 
//               (UMCTL2_AHB_SPLIT_MODE_3<<3) + (UMCTL2_AHB_SPLIT_MODE_2<<2) + 
//               (UMCTL2_AHB_SPLIT_MODE_1<<1) + UMCTL2_AHB_SPLIT_MODE_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_AHB_SPLIT_MODE_<n>
`define UMCTL2_AHB_SPLIT_MODE_TABLE 16'hffff


// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_0
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_0==1) && (UMCTL2_AHB_SPLIT_MODE_0==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_0 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_1
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_1==1) && (UMCTL2_AHB_SPLIT_MODE_1==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_1 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_2
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_2==1) && (UMCTL2_AHB_SPLIT_MODE_2==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_2 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_3
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_3==1) && (UMCTL2_AHB_SPLIT_MODE_3==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_3 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_4
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_4==1) && (UMCTL2_AHB_SPLIT_MODE_4==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_4 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_5
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_5==1) && (UMCTL2_AHB_SPLIT_MODE_5==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_5 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_6
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_6==1) && (UMCTL2_AHB_SPLIT_MODE_6==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_6 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_7
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_7==1) && (UMCTL2_AHB_SPLIT_MODE_7==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_7 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_8
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_8==1) && (UMCTL2_AHB_SPLIT_MODE_8==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_8 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_9
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_9==1) && (UMCTL2_AHB_SPLIT_MODE_9==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_9 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_10
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_10==1) && (UMCTL2_AHB_SPLIT_MODE_10==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_10 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_11
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_11==1) && (UMCTL2_AHB_SPLIT_MODE_11==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_11 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_12
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_12==1) && (UMCTL2_AHB_SPLIT_MODE_12==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_12 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_13
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_13==1) && (UMCTL2_AHB_SPLIT_MODE_13==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_13 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_14
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_14==1) && (UMCTL2_AHB_SPLIT_MODE_14==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_14 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_15
// Default:      100
// Values:       10, ..., 200
// Enabled:      (UMCTL2_A_AHB_15==1) && (UMCTL2_AHB_SPLIT_MODE_15==1)
// 
// Defines the number of clock cycles for which the controller drives hready low  
// before issuing a split response to a write transaction. The controller drives  
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_15 100


// Name:         UMCTL2_AHB_NUM_MST_0
// Default:      8 ((UMCTL2_AHB_LITE_MODE_0==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_0==1) && (UMCTL2_AHB_LITE_MODE_0==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_0 8

// Name:         UMCTL2_AHB_NUM_MST_1
// Default:      8 ((UMCTL2_AHB_LITE_MODE_1==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_1==1) && (UMCTL2_AHB_LITE_MODE_1==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_1 8

// Name:         UMCTL2_AHB_NUM_MST_2
// Default:      8 ((UMCTL2_AHB_LITE_MODE_2==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_2==1) && (UMCTL2_AHB_LITE_MODE_2==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_2 8

// Name:         UMCTL2_AHB_NUM_MST_3
// Default:      8 ((UMCTL2_AHB_LITE_MODE_3==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_3==1) && (UMCTL2_AHB_LITE_MODE_3==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_3 8

// Name:         UMCTL2_AHB_NUM_MST_4
// Default:      8 ((UMCTL2_AHB_LITE_MODE_4==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_4==1) && (UMCTL2_AHB_LITE_MODE_4==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_4 8

// Name:         UMCTL2_AHB_NUM_MST_5
// Default:      8 ((UMCTL2_AHB_LITE_MODE_5==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_5==1) && (UMCTL2_AHB_LITE_MODE_5==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_5 8

// Name:         UMCTL2_AHB_NUM_MST_6
// Default:      8 ((UMCTL2_AHB_LITE_MODE_6==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_6==1) && (UMCTL2_AHB_LITE_MODE_6==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_6 8

// Name:         UMCTL2_AHB_NUM_MST_7
// Default:      8 ((UMCTL2_AHB_LITE_MODE_7==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_7==1) && (UMCTL2_AHB_LITE_MODE_7==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_7 8

// Name:         UMCTL2_AHB_NUM_MST_8
// Default:      8 ((UMCTL2_AHB_LITE_MODE_8==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_8==1) && (UMCTL2_AHB_LITE_MODE_8==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_8 8

// Name:         UMCTL2_AHB_NUM_MST_9
// Default:      8 ((UMCTL2_AHB_LITE_MODE_9==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_9==1) && (UMCTL2_AHB_LITE_MODE_9==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_9 8

// Name:         UMCTL2_AHB_NUM_MST_10
// Default:      8 ((UMCTL2_AHB_LITE_MODE_10==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_10==1) && (UMCTL2_AHB_LITE_MODE_10==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_10 8

// Name:         UMCTL2_AHB_NUM_MST_11
// Default:      8 ((UMCTL2_AHB_LITE_MODE_11==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_11==1) && (UMCTL2_AHB_LITE_MODE_11==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_11 8

// Name:         UMCTL2_AHB_NUM_MST_12
// Default:      8 ((UMCTL2_AHB_LITE_MODE_12==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_12==1) && (UMCTL2_AHB_LITE_MODE_12==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_12 8

// Name:         UMCTL2_AHB_NUM_MST_13
// Default:      8 ((UMCTL2_AHB_LITE_MODE_13==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_13==1) && (UMCTL2_AHB_LITE_MODE_13==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_13 8

// Name:         UMCTL2_AHB_NUM_MST_14
// Default:      8 ((UMCTL2_AHB_LITE_MODE_14==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_14==1) && (UMCTL2_AHB_LITE_MODE_14==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_14 8

// Name:         UMCTL2_AHB_NUM_MST_15
// Default:      8 ((UMCTL2_AHB_LITE_MODE_15==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      (UMCTL2_A_AHB_15==1) && (UMCTL2_AHB_LITE_MODE_15==0)
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_15 8


// Name:         UMCTL2_AHB_WRITE_RESP_MODE_0
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_0==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_0 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_1
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_1==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_1 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_2
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_2==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_2 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_3
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_3==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_3 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_4
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_4==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_4 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_5
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_5==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_5 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_6
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_6==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_6 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_7
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_7==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_7 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_8
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_8==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_8 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_9
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_9==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_9 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_10
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_10==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_10 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_11
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_11==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_11 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_12
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_12==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_12 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_13
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_13==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_13 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_14
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_14==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_14 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_15
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      (UMCTL2_A_AHB_15==1 && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15==0))
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_15 0


// Name:         UMCTL2_AHB_WAQD_0
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_0==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_0 2

// Name:         UMCTL2_AHB_WAQD_1
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_1==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_1 2

// Name:         UMCTL2_AHB_WAQD_2
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_2==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_2 2

// Name:         UMCTL2_AHB_WAQD_3
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_3==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_3 2

// Name:         UMCTL2_AHB_WAQD_4
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_4==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_4 2

// Name:         UMCTL2_AHB_WAQD_5
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_5==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_5 2

// Name:         UMCTL2_AHB_WAQD_6
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_6==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_6 2

// Name:         UMCTL2_AHB_WAQD_7
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_7==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_7 2

// Name:         UMCTL2_AHB_WAQD_8
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_8==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_8 2

// Name:         UMCTL2_AHB_WAQD_9
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_9==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_9 2

// Name:         UMCTL2_AHB_WAQD_10
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_10==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_10 2

// Name:         UMCTL2_AHB_WAQD_11
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_11==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_11 2

// Name:         UMCTL2_AHB_WAQD_12
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_12==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_12 2

// Name:         UMCTL2_AHB_WAQD_13
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_13==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_13 2

// Name:         UMCTL2_AHB_WAQD_14
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_14==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_14 2

// Name:         UMCTL2_AHB_WAQD_15
// Default:      2
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_15==1
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_15 2


// Name:         UMCTL2_AHB_WDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_0 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_0 10

// Name:         UMCTL2_AHB_WDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_1 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_1 10

// Name:         UMCTL2_AHB_WDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_2 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_2 10

// Name:         UMCTL2_AHB_WDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_3 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_3 10

// Name:         UMCTL2_AHB_WDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_4 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_4 10

// Name:         UMCTL2_AHB_WDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_5 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_5 10

// Name:         UMCTL2_AHB_WDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_6 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_6 10

// Name:         UMCTL2_AHB_WDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_7 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_7 10

// Name:         UMCTL2_AHB_WDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_8 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_8 10

// Name:         UMCTL2_AHB_WDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_9 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_9 10

// Name:         UMCTL2_AHB_WDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_10 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_10 10

// Name:         UMCTL2_AHB_WDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_11 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_11 10

// Name:         UMCTL2_AHB_WDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_12 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_12 10

// Name:         UMCTL2_AHB_WDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_13 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_13 10

// Name:         UMCTL2_AHB_WDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_14 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_14 10

// Name:         UMCTL2_AHB_WDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_15 == 1
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_15 10


// Name:         UMCTL2_AHB_RAQD_0
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_0 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_0 4

// Name:         UMCTL2_AHB_RAQD_1
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_1 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_1 4

// Name:         UMCTL2_AHB_RAQD_2
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_2 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_2 4

// Name:         UMCTL2_AHB_RAQD_3
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_3 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_3 4

// Name:         UMCTL2_AHB_RAQD_4
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_4 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_4 4

// Name:         UMCTL2_AHB_RAQD_5
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_5 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_5 4

// Name:         UMCTL2_AHB_RAQD_6
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_6 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_6 4

// Name:         UMCTL2_AHB_RAQD_7
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_7 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_7 4

// Name:         UMCTL2_AHB_RAQD_8
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_8 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_8 4

// Name:         UMCTL2_AHB_RAQD_9
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_9 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_9 4

// Name:         UMCTL2_AHB_RAQD_10
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_10 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_10 4

// Name:         UMCTL2_AHB_RAQD_11
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_11 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_11 4

// Name:         UMCTL2_AHB_RAQD_12
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_12 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_12 4

// Name:         UMCTL2_AHB_RAQD_13
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_13 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_13 4

// Name:         UMCTL2_AHB_RAQD_14
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_14 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_14 4

// Name:         UMCTL2_AHB_RAQD_15
// Default:      4
// Values:       2, ..., 16
// Enabled:      UMCTL2_A_AHB_15 == 1
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n.  
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_15 4


// Name:         UMCTL2_AHB_RDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_0 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_0 10

// Name:         UMCTL2_AHB_RDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_1 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_1 10

// Name:         UMCTL2_AHB_RDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_2 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_2 10

// Name:         UMCTL2_AHB_RDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_3 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_3 10

// Name:         UMCTL2_AHB_RDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_4 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_4 10

// Name:         UMCTL2_AHB_RDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_5 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_5 10

// Name:         UMCTL2_AHB_RDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_6 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_6 10

// Name:         UMCTL2_AHB_RDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_7 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_7 10

// Name:         UMCTL2_AHB_RDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_8 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_8 10

// Name:         UMCTL2_AHB_RDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_9 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_9 10

// Name:         UMCTL2_AHB_RDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_10 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_10 10

// Name:         UMCTL2_AHB_RDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_11 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_11 10

// Name:         UMCTL2_AHB_RDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_12 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_12 10

// Name:         UMCTL2_AHB_RDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_13 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_13 10

// Name:         UMCTL2_AHB_RDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_14 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_14 10

// Name:         UMCTL2_AHB_RDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AHB_15 == 1
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_15 10

//-----------------------------------------------
// AHB Static Parameters
//-----------------------------------------------

`define A2X_IDW        4
`define A2X_SP_IDW     4
`define A2X_PP_AW  32
`define A2X_SP_AW  32
`define A2X_AW  32
`define A2X_BLW 4
`define A2X_SP_BLW 4
`define A2X_PP_BLW 4

//-----------------------------------------------
// XPI parameter (need to be set depending on some AHB ones)
//-----------------------------------------------


// Name:         UMCTL2_RDWR_ORDERED_0
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_0 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_0 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>0 && (UMCTL2_A_TYPE_0 == 1 || UMCTL2_A_TYPE_0 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_0 0


// `define UMCTL2_A_RDWR_ORDERED_0

// Name:         UMCTL2_RDWR_ORDERED_1
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_1 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_1 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>1 && (UMCTL2_A_TYPE_1 == 1 || UMCTL2_A_TYPE_1 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_1 0


// `define UMCTL2_A_RDWR_ORDERED_1

// Name:         UMCTL2_RDWR_ORDERED_2
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_2 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_2 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>2 && (UMCTL2_A_TYPE_2 == 1 || UMCTL2_A_TYPE_2 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_2 0


// `define UMCTL2_A_RDWR_ORDERED_2

// Name:         UMCTL2_RDWR_ORDERED_3
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_3 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_3 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>3 && (UMCTL2_A_TYPE_3 == 1 || UMCTL2_A_TYPE_3 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_3 0


// `define UMCTL2_A_RDWR_ORDERED_3

// Name:         UMCTL2_RDWR_ORDERED_4
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_4 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_4 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>4 && (UMCTL2_A_TYPE_4 == 1 || UMCTL2_A_TYPE_4 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_4 0


// `define UMCTL2_A_RDWR_ORDERED_4

// Name:         UMCTL2_RDWR_ORDERED_5
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_5 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_5 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>5 && (UMCTL2_A_TYPE_5 == 1 || UMCTL2_A_TYPE_5 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_5 0


// `define UMCTL2_A_RDWR_ORDERED_5

// Name:         UMCTL2_RDWR_ORDERED_6
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_6 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_6 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>6 && (UMCTL2_A_TYPE_6 == 1 || UMCTL2_A_TYPE_6 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_6 0


// `define UMCTL2_A_RDWR_ORDERED_6

// Name:         UMCTL2_RDWR_ORDERED_7
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_7 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_7 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>7 && (UMCTL2_A_TYPE_7 == 1 || UMCTL2_A_TYPE_7 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_7 0


// `define UMCTL2_A_RDWR_ORDERED_7

// Name:         UMCTL2_RDWR_ORDERED_8
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_8 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_8 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>8 && (UMCTL2_A_TYPE_8 == 1 || UMCTL2_A_TYPE_8 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_8 0


// `define UMCTL2_A_RDWR_ORDERED_8

// Name:         UMCTL2_RDWR_ORDERED_9
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_9 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_9 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>9 && (UMCTL2_A_TYPE_9 == 1 || UMCTL2_A_TYPE_9 == 
//               3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_9 0


// `define UMCTL2_A_RDWR_ORDERED_9

// Name:         UMCTL2_RDWR_ORDERED_10
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_10 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_10 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>10 && (UMCTL2_A_TYPE_10 == 1 || UMCTL2_A_TYPE_10 
//               == 3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_10 0


// `define UMCTL2_A_RDWR_ORDERED_10

// Name:         UMCTL2_RDWR_ORDERED_11
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_11 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_11 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>11 && (UMCTL2_A_TYPE_11 == 1 || UMCTL2_A_TYPE_11 
//               == 3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_11 0


// `define UMCTL2_A_RDWR_ORDERED_11

// Name:         UMCTL2_RDWR_ORDERED_12
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_12 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_12 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>12 && (UMCTL2_A_TYPE_12 == 1 || UMCTL2_A_TYPE_12 
//               == 3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_12 0


// `define UMCTL2_A_RDWR_ORDERED_12

// Name:         UMCTL2_RDWR_ORDERED_13
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_13 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_13 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>13 && (UMCTL2_A_TYPE_13 == 1 || UMCTL2_A_TYPE_13 
//               == 3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_13 0


// `define UMCTL2_A_RDWR_ORDERED_13

// Name:         UMCTL2_RDWR_ORDERED_14
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_14 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_14 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>14 && (UMCTL2_A_TYPE_14 == 1 || UMCTL2_A_TYPE_14 
//               == 3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_14 0


// `define UMCTL2_A_RDWR_ORDERED_14

// Name:         UMCTL2_RDWR_ORDERED_15
// Default:      0 ((UPCTL2_EN == 1) ? 1 : ((UMCTL2_A_TYPE_15 == 2) ? 
//               ((UMCTL2_AHB_WRITE_RESP_MODE_15 == 1) ? 0 : 1) : 0))
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>15 && (UMCTL2_A_TYPE_15 == 1 || UMCTL2_A_TYPE_15 
//               == 3) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15==0) && UPCTL2_EN == 0)
// 
// Preserves the ordering between read transaction and write transaction on Port n, if set. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_15 0


// `define UMCTL2_A_RDWR_ORDERED_15


// Name:         UMCTL2_RDWR_ORDERED_TABLE
// Default:      0x0 ( (UMCTL2_RDWR_ORDERED_15<<15) + (UMCTL2_RDWR_ORDERED_14<<14) + 
//               (UMCTL2_RDWR_ORDERED_13<<13) + (UMCTL2_RDWR_ORDERED_12<<12) + 
//               (UMCTL2_RDWR_ORDERED_11<<11) + (UMCTL2_RDWR_ORDERED_10<<10) + 
//               (UMCTL2_RDWR_ORDERED_9<<9) + (UMCTL2_RDWR_ORDERED_8<<8) + 
//               (UMCTL2_RDWR_ORDERED_7<<7) + (UMCTL2_RDWR_ORDERED_6<<6) + (UMCTL2_RDWR_ORDERED_5<<5) + 
//               (UMCTL2_RDWR_ORDERED_4<<4) + (UMCTL2_RDWR_ORDERED_3<<3) + 
//               (UMCTL2_RDWR_ORDERED_2<<2) + (UMCTL2_RDWR_ORDERED_1<<1) + UMCTL2_RDWR_ORDERED_0)
// Values:       0x0, ..., 0xffff
// 
// Table of UMCTL2_RDWR_ORDERED_<n>
`define UMCTL2_RDWR_ORDERED_TABLE 16'h0

//----------------------------------------
// Required to include BCMs
//----------------------------------------


`define RM_BCM02 0


`define RM_BCM05 0


`define RM_BCM05_ATV 1




`define RM_BCM06 0


`define RM_BCM06_ATV 1


`define RM_BCM07 0


`define RM_BCM07_ATV 1



`define RM_BCM21 0


`define RM_SVA01 0


`define RM_SVA02 0


`define RM_SVA03 0


`define RM_SVA04 0


`define RM_SVA05 0


`define RM_SVA06 0


`define RM_SVA07 0


`define RM_SVA99 0


`define RM_BVM02 0



`define RM_BCM21_ATV 1


`define RM_BCM50 0


`define RM_BCM56 0


`define RM_BCM57 0


`define RM_BCM65 0


`define RM_BCM65_ATV 1


`define RM_BCM95_I 0

//UMCTL_LOG2(x) calculates ceiling(log2(x)), 0<=x<=1048576 
`define UMCTL_LOG2(x) ((x<=1)?0:(x<=2)?1:(x<=4)?2:(x<=8)?3:(x<=16)?4:(x<=32)?5:(x<=64)?6:(x<=128)?7:(x<=256)?8:(x<=512)?9:(x<=1024)?10:(x<=2048)?11:(x<=4096)?12:(x<=1024*8)?13:(x<=1024*16)?14:(x<=1024*32)?15:(x<=1024*64)?16:(x<=1024*128)?17:(x<=1024*256)?18:(x<=1024*512)?19:(x<=1024*1024)?20:21)

//----------------------------------------
// testbench
//----------------------------------------

// Name:         UMCTL2_MAX_AXI_DATAW
// Default:      512
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// UMCTL2_MAX_DATAW: AXI maximum r/w datawidth. The value 
// corresponds to the maximum value of UMCTL2_PORT_DW_x
`define UMCTL2_MAX_AXI_DATAW 512


// Name:         UMCTL2_MAX_AXI_ADDRW
// Default:      64
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Maximum width of AXI address
`define UMCTL2_MAX_AXI_ADDRW 64


// Name:         SVA_XPI
// Default:      0
// Values:       0 1
// 
// Internal regression only. Enables the SVA on XPI.
// `define SVA_XPI


// Name:         SVA_APB
// Default:      0
// Values:       0 1
// 
// Internal regression only. Enables the SVA on APB.
// `define SVA_APB


// Name:         SVA_HIF
// Default:      0
// Values:       0 1
// 
// Internal regression only. Enables the SVA on HIF.
// `define SVA_HIF


// Name:         SVA_PA
// Default:      0
// Values:       0 1
// 
// Internal regression only. Enables the SVA on PA.
// `define SVA_PA


// Name:         SVA_FIFO_CHECKER
// Default:      0
// Values:       0 1
// 
// Internal regression only. Enables the SVA on GFIFO.
// `define SVA_FIFO_CHECKER


// Name:         UMCTL2_USE_SPLIT
// Default:      0 ([<functionof> UMCTL2_A_NPORTS])
// Values:       0, 1
// 
// Check if any AHB port is split capable.
// `define UMCTL2_USE_SPLIT


// Name:         UMCTL2_A2X_COH_BUFMODE
// Default:      1
// Values:       0 1
// Enabled:      0
// 
// Internal regression only. Enables AHB A2X cohenercy in case of  Write Resp equal to Bufferable mode.
`define UMCTL2_A2X_COH_BUFMODE


// Name:         UMCTL2_PORT_EN_RESET_VALUE
// Default:      0
// Values:       0 1
// 
// Internal core Assembler regression only. Currently there is no mean to write a register for the ping test. 
// port_en reset value is 0. This paramter is set to 1 in the core Assembler to changes the reset value of port_en to 1 
// and allow the ping test complete.
`define UMCTL2_PORT_EN_RESET_VALUE 0


// Name:         UMCTL2_REF_ZQ_IO
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_NUM_LRANKS_TOTAL<8
// 
// Provide optional hardware access to trigger refresh and ZQCS commands, instead of APB access.
// `define UMCTL2_REF_ZQ_IO


// Name:         MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW
// Default:      0 (((MEMC_SIDEBAND_ECC==1) && (MEMC_USE_RMW==1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// (DDRC Scrub functionality Enabled)
// `define MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW


// Name:         MEMC_ENH_CAM_PTR_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// 
// Enables the support for Enhanced CAM pointer mechanism feature with Inline ECC or Dynamic BSM. 
// Only for Internal Testing within Synopsys.
`define MEMC_ENH_CAM_PTR_INTERNAL_TESTING 0


// Name:         MEMC_ENH_RDWR_SWITCH_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// 
// Enables the support for Enhanced Read/Write Switching feature with Inline ECC or Dynamic BSM. 
// Only for Internal Testing within Synopsys.
`define MEMC_ENH_RDWR_SWITCH_INTERNAL_TESTING 0


// Name:         MEMC_ENH_CAM_PTR
// Default:      0
// Values:       0, 1
// Enabled:      (UCTL_DDR_PRODUCT > 2 && ((MEMC_INLINE_ECC == 0 && UMCTL2_DYN_BSM 
//               == 0) || MEMC_ENH_CAM_PTR_INTERNAL_TESTING == 1) && 
//               <DWC-UNIVERSAL-DDR-MCTL2-P feature authorize> == 1)
// 
// Available in DWC_ddr_umctl2P product only. 
// Enables enhanced CAM pointer mechanism. 
//  - When enabled, the CAM supports out-of-order pushing and out-of-order popping (scheduling). 
//  - When disabled, the CAM supports out-of-order popping (scheduling), but CAM does not support out-of-order pushing 
//  (in-order pushing only) 
// This feature requires more area and might impact on synthesis timing depending process and so on. The size of extra 
// area depends on hardware configurations, such as number of CAM entries, number of BSMs, VPRW feature, and so on. 
// This feature is under access control. For more information, contact Synopsys.  
// MEMC_ENH_CAM_PTR_INTERNAL_TESTING=0 always. 
// MEMC_ENH_CAM_PTR_INTERNAL_TESTING=1 only for internal testing within Synopsys.
// `define MEMC_ENH_CAM_PTR


// Name:         MEMC_NTT_UPD_ACT
// Default:      0 ((MEMC_ENH_CAM_PTR == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Enables to update NTT by ACT for the other direction.
// `define MEMC_NTT_UPD_ACT


// Name:         MEMC_NTT_UPD_PRE
// Default:      0 ((MEMC_ENH_CAM_PTR == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Enables to update NTT by PRE.
// `define MEMC_NTT_UPD_PRE


// Name:         MEMC_ADD_REPLACE_PRE
// Default:      0 ((MEMC_NTT_UPD_PRE == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// MEMC_ADD_REPLACE_PRE 
// Add dedicated replace logic for PRE
// `define MEMC_ADD_REPLACE_PRE


// `define UMCTL2_DYN_BSM_OR_MEMC_ENH_CAM_PTR


// `define MEMC_INLINE_ECC_OR_UMCTL2_DYN_BSM


// Name:         MEMC_ENH_RDWR_SWITCH
// Default:      0 (MEMC_ENH_CAM_PTR+0)
// Values:       0, 1
// Enabled:      (UCTL_DDR_PRODUCT > 2 && MEMC_ENH_CAM_PTR == 1 && ((MEMC_INLINE_ECC 
//               == 0 && UMCTL2_DYN_BSM == 0) || 
//               MEMC_ENH_RDWR_SWITCH_INTERNAL_TESTING == 1) && <DWC-UNIVERSAL-DDR-MCTL2-P feature authorize> == 1)
// 
// Available in DWC_ddr_umctl2P product only. 
// Enables enhanced Read/Write switching mechanism. 
// This contains the following features: 
//   - Issues ACT command for the other direction command in advance as preparation. 
//   - RD/WR switching based on page status. 
//   - Schedule write commands if WR CAM is certain fill level. 
// MEMC_ENH_RDWR_SWITCH_INTERNAL_TESTING=0 always. 
// MEMC_ENH_RDWR_SWITCH_INTERNAL_TESTING=1 only for internal testing within Synopsys. 
// This feature is under access control. For more information, contact Synopsys.
// `define MEMC_ENH_RDWR_SWITCH


// Name:         MEMC_RDWR_SWITCH_POL_SEL
// Default:      0 ((MEMC_ENH_RDWR_SWITCH == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      MEMC_ENH_RDWR_SWITCH==1
// 
// Enables read write switching policy selectable. 
//  - 1: Implement two read write switching policy in the configuraiton, using a register to select which policy is used.  
//  - 0: Read write switching policy decided by MEMC_ENH_RDWR_SWITCH.
// `define MEMC_RDWR_SWITCH_POL_SEL


`define MEMC_ORIG_RDWR_SWITCH_EXIST



// Name:         DDRCTL_HET_INTERLEAVE
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_SHARED_AC == 1) && (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1) 
//               && (UMCTL2_SBR_EN == 0) && (UMCTL2_EXCL_ACCESS ==0) && (MEMC_DDR4 == 
//               1 || MEMC_DDR3 == 1))
// 
// Enables Heterogenous Data Channel Interleaving Support. 
//   
// In DDR3/4 Dual Channel shared-AC configurations, this parameter enables Data Channel Interleaving support for 
// heterogenous DRAM densities on either channel. 
//   
// When enabled, the controller supports interleaving between the two data channels  while they are connected to two 
// different density DRAM memories. The ratio of the densities is defined through register programming. 
// When disabled, the DRAM memory densities should be equal.  
// This feature is under access control. Contact Synopsys for more information.
`define DDRCTL_HET_INTERLEAVE 0


// `define DDRCTL_HET_INTERLEAVE_EN_1


// Name:         UMCTL2_VER_NUMBER_VAL
// Default:      0x3336302a
// Values:       0x0, ..., 0xffffffff
// Enabled:      0
// 
// UMCTL2_VER_NUMBER_VAL 
// Specifies the UMCTL2_VER_NUMBER read-only register value
`define UMCTL2_VER_NUMBER_VAL 32'h3336302a


// Name:         UMCTL2_VER_TYPE_VAL
// Default:      0x67612a2a
// Values:       0x0, ..., 0xffffffff
// Enabled:      0
// 
// UMCTL2_VER_TYPE_VAL 
// Specifies the UMCTL2_VER_TYPE read-only register value
`define UMCTL2_VER_TYPE_VAL 32'h67612a2a


// Name:         MAX_UMCTL2_A_ID_MAPW
// Default:      32
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_A_ID_MAPW 
// (Maximum Value of UMCTL2_A_ID_MAPW)
`define MAX_UMCTL2_A_ID_MAPW 32


// Name:         MAX_UMCTL2_NUM_VIR_CH
// Default:      32
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_NUM_VIR_CH 
// (Maximum Value of Virture Channel)
`define MAX_UMCTL2_NUM_VIR_CH 32


// Name:         MAX_UMCTL2_A_NPORTS
// Default:      16
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_A_NPORTS 
// (Maximum Value of Host Port)
`define MAX_UMCTL2_A_NPORTS 16
    

// Name:         MAX_A_DW_INT_NB
// Default:      11
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A_DW_INT_NB 
// (Maximum number of bits for UMCTL2_A_DW_INT_n)
`define MAX_A_DW_INT_NB 11


// Name:         MAX_AXI_WAQD_NB
// Default:      6
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_WAQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_WAQD_n)
`define MAX_AXI_WAQD_NB 6


// Name:         MAX_AXI_WDQD_NB
// Default:      8
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_WDQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_WDQD_n)
`define MAX_AXI_WDQD_NB 8


// Name:         MAX_AXI_RAQD_NB
// Default:      6
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_RAQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_RAQD_n)
`define MAX_AXI_RAQD_NB 6


// Name:         MAX_AXI_RDQD_NB
// Default:      8
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_RDQD_NB 
// (Maximum number of bits for Maximum UMCTL2_AXI_RDQD_n)
`define MAX_AXI_RDQD_NB 8


// Name:         MAX_AXI_WRQD_NB
// Default:      7
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_WRQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_WRQD_n)
`define MAX_AXI_WRQD_NB 7


// Name:         MAX_AXI_SYNC_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_SYNC_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_SYNC_n)
`define MAX_AXI_SYNC_NB 1


// Name:         MAX_ASYNC_FIFO_N_SYNC_NB
// Default:      3
// Values:       -2147483648, ..., 2147483647
// 
// MAX_DATA_CHANNEL_INTERLEAVE_NS_NB 
// (Maximum number of Bits for Maximum UMCTL2_ASYNC_FIFO_N_SYNC_SYNC_n)
`define MAX_ASYNC_FIFO_N_SYNC_NB 3


// Name:         MAX_DATA_CHANNEL_INTERLEAVE_NS_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_DATA_CHANNEL_INTERLEAVE_NS_NB 
// (Maximum number of Bits for Maximum UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_n)
`define MAX_DATA_CHANNEL_INTERLEAVE_NS_NB 1


// Name:         MAX_VPR_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_VPR_EN_NB 
// (Maximum number of Bits for Maximum UMCTL_MAX_VPR_EN)
`define MAX_VPR_EN_NB 1


// Name:         MAX_VPW_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_VPW_EN_NB 
// (Maximum number of Bits for Maximum UMCTL2_MAX_VPW_EN)
`define MAX_VPW_EN_NB 1


// Name:         MAX_USE2RAQ_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_USE2RAQ_NB 
// (Maximum number of Bits for Maximum UMCTL2_XPI_USE2RAQ_n)
`define MAX_USE2RAQ_NB 1


// Name:         MAX_NUM_VIR_CH_NB
// Default:      6
// Values:       -2147483648, ..., 2147483647
// 
// MAX_NUM_VIR_CH_NB 
// (Maximum number of Bits for Maximum UMCTL2_NUM_VIR_CH_n)
`define MAX_NUM_VIR_CH_NB 6


// Name:         MAX_STATIC_VIR_CH_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// MAX_STATIC_VIR_CH_NB 
// (Maximum number of Bits for Maximum UMCTL2_STATIC_VIR_CH_n)
`define MAX_STATIC_VIR_CH_NB 1


// Name:         MAX_RRB_EXTRAM_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RRB_RXTRAM_NB 
// (Maximum number of Bits for Maximum UMCTL2_RRB_EXTRAM_n)
`define MAX_RRB_EXTRAM_NB 1


// Name:         MAX_RRB_EXTRAM_REG_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RRB_RXTRAM_REG_NB 
// (Maximum number of Bits for Maximum UMCTL2_RRB_EXTRAM_REG_n)
`define MAX_RRB_EXTRAM_REG_NB 1


// Name:         MAX_RDWR_ORDERED_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RDWR_ORDERED_NB 
// (Maximum number of Bits for Maximum UMCTL2_RDWR_ORDERED_n)
`define MAX_RDWR_ORDERED_NB 1


// Name:         MAX_READ_DATA_INTERLEAVE_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_READ_DATA_INTERLEAVE_EN_NB 
// (Maximum number of Bits for Maximum UMCTL2_READ_DATA_INTERLEAVE_EN_n)
`define MAX_READ_DATA_INTERLEAVE_EN_NB 1


// Name:         MAX_AXI_LOCKW
// Default:      2
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_LOCKW 
// (Maximum Value of UMCTL2_AXI_LOCK_WIDTH_n)
`define MAX_AXI_LOCKW 2


// Name:         MAX_AP_ASYNC_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AP_ASYNC_NB 
// (Maximum number of Bit for UMCTL2_AP_ASYNC_A_n)
`define MAX_AP_ASYNC_NB 1


// Name:         MAX_A2X_NUM_AHBM_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_NUM_AHBM_NB 
// (Maximum Number of Bit for UMCTL2_AHB_NUM_MST_n)
`define MAX_A2X_NUM_AHBM_NB 5


// Name:         MAX_A2X_BRESP_MODE_NB
// Default:      2
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_BRESP_MODE_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_WRITE_RESP_MODE_n)
`define MAX_A2X_BRESP_MODE_NB 2


// Name:         MAX_A2X_AHB_LITE_MODE_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_AHB_LITE_MODE_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_LITE_MODE_n)
`define MAX_A2X_AHB_LITE_MODE_NB 1


// Name:         MAX_A2X_SPLIT_MODE_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_SPLIT_MODE_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_SPLIT_MODE_n)
`define MAX_A2X_SPLIT_MODE_NB 1


// Name:         MAX_A2X_HREADY_LOW_PERIOD_NB
// Default:      8
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_HREADY_LOW_PERIOD_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_HREADY_LOW_PERIOD_n)
`define MAX_A2X_HREADY_LOW_PERIOD_NB 8


// Name:         MAX_AHB_NUM_MST_NB
// Default:      4
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AHB_NUM_MST_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_NUM_MST_n)
`define MAX_AHB_NUM_MST_NB 4


// Name:         MAX_PORT_NBYTES
// Default:      64
// Values:       -2147483648, ..., 2147483647
// 
// MAX_PORT_NBYTES 
// (Maximum Number of Bytes for UMCTL2_PORT_NBYTES_n)
`define MAX_PORT_NBYTES 64


// Name:         MAX_RINFOW_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RINFOW_NB 
// (Maximum Number of bits for UMCTL2_RD_INFOW_n)
`define MAX_RINFOW_NB 5


// Name:         MAX_RINFOW_NSA_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RINFOW_NSA_NB 
// (Maximum Number of bits for UMCTL2_RD_INFOW_NSA_n)
`define MAX_RINFOW_NSA_NB 5


// Name:         MAX_WINFOW_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_WINFOW_NB 
// (Maximum Number of bits for UMCTL2_WR_INFOW_n)
`define MAX_WINFOW_NB 5


// Name:         MAX_RPINFOW_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RPINFOW_NB 
// (Maximum Number of bits for UMCTL2_RP_INFOW_n)
`define MAX_RPINFOW_NB 5


// Name:         MAX_UMCTL2_AXI_TAGBITS
// Default:      128
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_AXI_TAGBITS 
// (Maximum Value of UMCTL2_AXI_TAGBITS_n)
`define MAX_UMCTL2_AXI_TAGBITS 128


// Name:         MAX_MEMC_TAGBITS_NB
// Default:      7
// Values:       -2147483648, ..., 2147483647
// 
// MAX_MEMC_TAGBITS_NB 
// (Maximum Num of bits for MEMC_TAGBITS_n)
`define MAX_MEMC_TAGBITS_NB 7


// Name:         MAX_RAQ_TABLE_TABLE_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RAQ_TABLE_TABLE_NB 
// (Maximum Num of bits for RAQ_TABLE_n)
`define MAX_RAQ_TABLE_TABLE_NB 5



`define UMCTL2_P_AP_ASYNC_ANY

`endif // __GUARD__DWC_DDR_UMCTL2_CC_CONSTANTS__SVH__
