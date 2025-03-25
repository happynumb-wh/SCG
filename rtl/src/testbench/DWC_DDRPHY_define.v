/******************************************************************************
 *                                                                            *
 * Copyright (c) 2012 Synopsys Inc. All rights reserved.                      *
 *                                                                            *
 * Synopsys Proprietary and Confidential. This file contains confidential     *
 * information and the trade secrets of Synopsys Inc. Use, disclosure, or     *
 * reproduction is prohibited without the prior express written permission    *
 * of Synopsys, Inc.                                                          *
 *                                                                            *
 * Synopsys, Inc.                                                             *
 * 700 East Middlefield Road                                                  *
 * Mountain View, California 94043                                            *
 * (800) 541-7737                                                             *
 *                                                                            *
 ******************************************************************************
 *
 * DWC_DDRPHY_define.v
 *  Module that defines the parameters for the DDRPHY
 *  Some configurations in this file can be overriden from verification
 *  environment by setting the DWC_DDRPHY_TB_OVERRIDE macro
 *
 *****************************************************************************/

`ifdef DWC_DDRPHY_TB_OVERRIDE
`else
  //-----------------------------------------------------------------------------
  // DDR System General Configurations
  //-----------------------------------------------------------------------------
  // Macros that define general configuration of the DDR system
  `define DWC_NO_OF_BYTES         8      // number of DATX8's
  `define DWC_NO_OF_RANKS         2      // number of ranks
  //`define DWC_NO_OF_3DS_STACKS    2      // number of 3DS stacks; valid values are 2, 4, 8.
  `define DWC_NO_OF_ZQ_SEG        2      // number of ZQ segments per ZQ calibration controller
                                         // IMPORTANT: DWC_NO_OF_ZQ_SEG should be set to a value 
                                         // of 2 or higher (maximum is 4)
                                         // AC is defined in segment 0 and DX lanes are defined in segment 1
  `define DWC_CK_WIDTH            1      // number of CK pairs
  `define DWC_BANK_WIDTH          3      // DFI bank width
  `define DWC_BG_WIDTH            2      // DFI bank group width
  `define DWC_ADDR_WIDTH          18     // DFI address width
  `define DWC_PHY_ADDR_WIDTH      18     // PHY address width
  `define DWC_RST_WIDTH           1      // DRAM reset width
  
  `define DWC_PHY_BG_WIDTH        2      // DRAM bank group width
  `define DWC_PHY_BA_WIDTH        2      // DRAM bank width
  
  
  //-----------------------------------------------------------------------------
  // PHY Utility Block (PUB) Configurations
  //-----------------------------------------------------------------------------
  // Macros that define PUB-specific configurations
  `define DWC_RST_DFLT            1'b0   // DRAM reset value during PUBL reset
  `define DWC_RDIMMCR0_DFLT       32'd0  // RDIMMCR0 default value
  `define DWC_RDIMMCR1_DFLT       32'd0  // RDIMMCR1 default value
  `define DWC_FRQSEL_DFLT         2'b00  // PLL frequency select default
  `define DWC_WRRMODE_DFLT        1'b0   // write path rise-to-rise mode default (rise-to-fall)
  `define DWC_RRRMODE_DFLT        1'b0   // read path rise-to-rise mode default (rise-to-fall)
  `define DWC_SDRMODE_DFLT        2'b00  // single data rate mode default
  
  // The following pipelining options add pipeline stages on various paths as 
  // described below.  Valid values for all pipelining macros are 0 - 3. A value 
  // of 0 implies no pipeline stage insertion.  A value of 1 implies 1 stage, 
  // 2 implies 2 stages and 3 implies 3 stages. 
  `define DWC_PIPE_PHY2DFI        1      // Number of pipeline stages on DFI inputs from PHY (read data/valid/mask)
  `define DWC_PIPE_DFI2PHY        1      // Number of pipeline stages on DFI outputs to PHY
  `define DWC_PIPE_DFI2MCTL       1      // Number of pipeline stages on DFI outputs (read data/valid/mask) to MCTL
  `define DWC_PIPE_DFI2PUB        1      // Number of pipeline stages on DFI inputs/outputs from/to PUB blocks (BIST, DCU, Training, Scheduler)
  `define DWC_PIPE_MCTL2DFI       1      // Number of pipeline stages on DFI inputs
  
  // Configuration Interface Type
  // ----------------------------
  // Uncomment one or many of the following to specify the configuration register
  // interface. Default is generic configuration register interface (CFG).
  // JTAG is a secondary interface that can co-exist with APB or CFG.
  `define DWC_DDRPHY_APB              // APB interface (otherwise CFG is used)
  //`define DWC_DDRPHY_JTAG             // JTAG as a secondary register interface
  
  `ifdef DWC_DDRPHY_APB      
    `define DWC_CFG_OUT_PIPE      0      // number of pipelines on configuration output
  `else      
    `define DWC_CFG_OUT_PIPE      1      // number of pipelines on configuration output
  `endif      
  
  // Controller/PHY Data Rate
  // ------------------------
  // By default, the design is compiled to support running the controller in either
  // HDR or SDR mode, and running the PHY in HDR mode, all run options
  // are selectable by software;
  // To restrict the data rates for which the design is compiled for, uncomment one
  // of the following macros:
  //   - CSDR_ONLY: Controller SDR mode. Compile the design for controller to run in
  //                SDR mode only, and the PHY to run in HDR mode
  //                (software selectable); once compiled, such  a design will not 
  //                support running controller in HDR mode
  //   - HDR_ONLY:  HDR mode only. Compile the design for controller and PHY to
  //                always run HDR mode; once compiled, such a design will not
  //                support running in SDR mode for the controller
  //`define DWC_DDRPHY_CSDR_ONLY
  //`define DWC_DDRPHY_HDR_ONLY
  
  // General Purpose Registers
  // -------------------------
  // Implements 2 32-bit general purpose registers in the PUB address
  // space. These register outputs are visible at the DWC_DDRPHY_top and can be
  // used by chip logic for general purpose controls
  `define DWC_GPR0_DFLT         32'h00000000 // GPR0 default value
  `define DWC_GPR1_DFLT         32'h00000000 // GPR1 default value
  
  
  // Revision Identification
  // -----------------------
  // Specifies the PUB, PHY, and user-defined revision numbers. These will be
  // values returned by the PUB Revision Identification Register (RIDR) when it
  // is read. The three fields of the RIDR are as follows:
  //   - PUB_RID : PUB revision ID. Consists of three 4-bit digits for major,
  //               moderate and minor revision numbers; e.g for PUB revision
  //               2.10, set the PUBRID to 12'h210
  //   - PHY_RID : PHY revision ID. Consists of three 4-bit digits for major,
  //               moderate and minor revision numbers; e.g for PHY revision
  //               1.01, set the PHYRID to 12'h101
  //   - GP_RID:   General-purpose revision ID. 8-bit general-purpose ID 
  //               defined by the user
  // NOTE: PUB_RID and PHY_RID should not normally be edited since it is
  //       already pre-set to the correct value. However there are cases where
  //       it may be necessary for the user to change edit these, such as when
  //       a hot-fix that does not include this file was used
  `define DWC_PUB_RID             12'h320
  `define DWC_PHY_RID             12'h260
  `define DWC_GP_RID               8'h00
  
  
  // RDIMM support
  // -------------
  // Uncomment to inlcude logic for RDIMM support
  //`define DWC_DDR_RDIMM_EN
  
  // Uncomment to include logic for LRDIMM support
  //`define DWC_DDR_LRDIMM_EN
  //
  // Uncomment to include logic for UDIMM support
  `define DWC_DDR_UDIMM_EN
  
  
  
  // Uncomment to synchronize the SDRAM alert_n signal on the
  // negative edge of the DFI clock before passing it to the DFI positive edge
  // synchronizer
  //`define DWC_ALERTN_NEG_CLK
  
  
  // RCD mode
  // --------
  // specifies the RDIMM Registering Clock Driver (RCD) or Memory Buffer (MB) mode used
  // Valid values are:
  //   0 = No RCD chip used
  //   1 = Direct DualCS mode
  //   2 = Direct QuadCS mode
  //   3 = Encoded Quad CS mode
  `define DWC_RCD_MODE            0
  
  
  // PHY Special Modes
  // -----------------
  // uncomment to include pins for PHY special modes. This includes an
  // input control bus (phy_smode) and an output status bus (phy_status)
  //`define DWC_DDRPHY_SMODE
  
  
  // Reset Synchronization
  // ---------------------
  // uncomment to include synchronizers on all primary (external) reset pins
  // (ctl_rst_n, ctl_sdr_rst_n, cfg_rst_n, presetn, trsts_n) so that resets are
  // asynchronously asserted but synchronously de-asserted
  //`define DWC_DDRPHY_SYNC_RST
  
  
  // Multi-stage Synchronizer Depth
  // ------------------------------
  // Specifies the number of stages used for multi-stage CDC synchronizers. 
  // Valid values are 2, 3, or 4.
  `define DWC_CDC_SYNC_STAGES     2
  
  // Multi-stage Synchronizer Depth in the Asynchronous FIFO
  // -------------------------------------------------------
  // Specifies the number of stages used for multi-stage CDC synchronizers in DWC_ddrphy_afifo.v 
  // Valid values are 2, 3, or 4.
  `define DWC_AFIFO_SYNC_STAGES   2
  
  // Shadow Registers
  // ----------------
  // Used to create additional set of registers for fast frequency change.
  // if defined, two sets of training registers are generated, one set for frequency A 
  // and a second set for frequency B, also referred to as the shadow registers
  // if not defined,  only one set of training registers are generated (e.g. no shadow registers) 
  `define DWC_SHADOW_REGISTERS
  
  // Area optimization
  // -----------------
  // Serial VT compensation and serial DDL calibration
  // uncomment if VT compensation and DDL calibration has to be run in parallel; parallel VT
  // compensation and DDL calibration reduces the time for these procedures but increases the
  // area of the PUB
  `define DWC_SERIAL_VT_COMP      
  `define DWC_SERIAL_DDL_CAL
  
  // uncomment any of these to reduce the area of the PUB if the feature is not required.
  //`define DWC_DDRPHY_NO_LPDDRX
  //`define DWC_NO_CA_TRAIN
  //`define DWC_NO_CA_VT_COMP
  //`define DWC_NO_VREF_TRAIN
  
  // Clock Gating
  // ------------
  // Uncomment to enable support for PUB clock gating.  If set, compiles in
  // additional ports and registers to control PUB block-level clock gating features.
  //`define DWC_PUB_CLOCK_GATING 
  
  // To use the target cell library's clock gating cell in simulation or synthesis, 
  // the following define lines must be edited with the correct info and uncommented.
  //  DWC_PUB_USE_CLOCK_GATING_LIB_CELL      : uncomment with following define lines
  //  DWC_PUB_CLK_GATE                       : name of target technology library clock gating cell
  //  DWC_PUB_CLK_GATE_CKOUT                 : dot prefixed (".") output clock port name from target library>
  //  DWC_PUB_CLK_GATE_CKIN                  : dot prefixed (".") input clock port name from target library>
  //  DWC_PUB_CLK_GATE_EN                    : dot prefixed (".") input en port name from target library>
  //  DWC_PUB_CLK_GATE_SE                    : dot prefixed (".") input scan enable port name from target library>
`ifndef SRAM_SIM
  `define DWC_PUB_USE_CLOCK_GATING_LIB_CELL
  `define DWC_PUB_CLK_GATE         STD_CLKGT
  `define DWC_PUB_CLK_GATE_CKOUT  .Q
  `define DWC_PUB_CLK_GATE_CKIN   .CK
  `define DWC_PUB_CLK_GATE_EN     .E     
  `define DWC_PUB_CLK_GATE_SE     .TE     
`endif
  //-----------------------------------------------------------------------------
  // PHY General Configurations
  //-----------------------------------------------------------------------------
  // Macros that define general configuration of the DDR PHY
  
  // Specifies if defined (if uncommented) that the DDRPHY PLL will be 
  // instantiated with the AC and DATX8 macros. 
  // Specifies if not defined (if commented) that the PLL will not be instantiated
  // and this case the input clocks to the AC and DATX8 macros must be sourced
  // from the user logic
  `define DWC_DDRPHY_PLL_USE
  
  
  // Uncomment if there are no ZQ pins in the whole PHY. If this is uncommented
  // it means DWC_NO_OF_ZQ only refers to the number of ZQ calibration register
  // sets in the PUB. There is no automatic impedance calibration but the I/O 
  // impedance can be controlled using the PUB registers (ZQnCR)
  //`define DWC_DDRPHY_NO_PZQ
  
  
  // Specifies if defined (if uncommented) that power/ground (PG) pins such as 
  // VDD, VSS, VDDQ, VSSQ, and PLL_VDD be included in the PHY netlists.
  // Comment out the define to exclude power/ground (PG) pins from the PHY 
  // netlists. It is recommended to include PG pins in the netlist so that PG pins,
  // especially VDDQ/VSSQ, are correctly connected for retention. Otherwise
  // if PG pins are excluded it is the user's responsibilty that all power pins
  // are correctly connected.
  `define DWC_DDRPHY_PG_PINS
  
  
  // Internal SSTL I/O Buses
  // -----------------------
  // Uncomment to have internal SSTL I/O ring buses to be visible at the
  // DWC_DDRPHY_top module. These buses include VREFI, ZIOH, LENH, and POCH.
  // This may be useful if there are SSTL I/Os that are defined outside the 
  // DWC_DDRPHY_top module but still need to be connected to the internal I/O 
  // ring buses of the DDRPHY. Otherwise these signals are not visible at the
  // DWC_DDRPHY_top module.
  // `define DWC_DDRPHY_INT_IO_BUS
  
  // PHY_top ATPG pins
  // ---------------------------
  // The default uses the PHY_top directly connected core level ATPG pins 
  // (ac_atpg_s*, dx_atpg_s*) for each individual scan chain in the AC and DX macro,
  // The define is commented by default.
  // The following options are used to concatenate the PHY AC/DX scan chains 
  // per lane using DFT compiler.
  // The following  define has been added to remove the ac_atpg_s* and dx_atpg_s*
  // hierarchy pins from the DWC_DDRPHY_top.v and below.
  //
  // `define DWC_DDRPHY_NO_HIER_ATPG_PINS
  //
  // The following can ONLY be used with the above DWC_DDRPHY_NO_HIER_ATPG_PINS 
  // define.
  // The following selects between using existing PHY IO ports (uncommented) or 
  // adding core pins (commented)  during the DFT Compiler process of 
  // concatenation 
  // of the AC and DX scan chains.
  //
  // `define DWC_DDRPHY_ATPG_USE_PHY_PORTS
  
  // Snap Cap and Bond Pad Cells
  // ---------------------------
  // Set to a non-zero value to instantiate n rows of snap cap cells on each I/O
  `define DWC_PSCAP_ROWS          0
  
  // set to 1 to instantiate bond pad cells on each I/O
  `define DWC_PPAD_USE            0
  
  
  //-----------------------------------------------------------------------------
  // Process-Specific Definitions
  //-----------------------------------------------------------------------------
  // Macros that define process-specific features
  
  // Emulation PLL parameters for 800 mbps Freq 200/400MHz VCO = 200*6 = 1200MHz
  // ----------------
  
  `ifdef DWC_DDRPHY_EMUL_XILINX
  // PLL Parameters
  // For DDR4/3/2        define DDRn
  //     LPDDR3/2 don't  define DDRn
    `ifdef LPDDRX 
      `undef  DWC_DDRPHY_DDRn
    `else
      `define DWC_DDRPHY_DDRn
    `endif
    `define DWC_PLL_DIV_F         8
    `define DWC_PLL_MF            16
    `define DWC_PLL_DIV_CKIN      1
    `define DWC_DQ_SH_DLY         5'd00
  `endif
  
  
  // PHY Type
  // --------
  // default is type B - uncomment if using type A PHY
  `define DWC_DDRPHY_TYPEB
  //`define DWC_DDRPHY_TYPEA
  
  // uncomment if using ACX48 macro - only valid for type B PHY; 
  // otherwise AC macros are used
  // `define DWC_DDRPHY_ACX48
  
  // uncomment if using DATX4X2 macros - only valid for type B PHY; 
  // otherwise DATX8 macros are used
  // `define DWC_DDRPHY_X4X2
  
  // uncomment if using DATX4X2 macros only in x8 mode
  // otherwise DATX4X2 macros are software-programmable to be used in both x8 and x4 
  //`define DWC_DDRPHY_X8_ONLY
  
  // uncomment, if when using DATX4X2, DM of x8 mode is to be multiplexed onto DQS[1] 
  // of x4 mode. In this configuration, there is no dedicated I/O for DM in x8 mode, 
  // instead DQS[1] of x4 mode uses  PDIFFT/PDIFFC I/O cell instead of PDIFF cell, 
  // thus allowing DM to be multiplexed on this I/O.
  //`define DWC_DDRPHY_DMDQS_MUX
  
  // uncomment if using CK macro to drive SDRAM CK
  // otherwise AC macros is used
  // `define DWC_DDRPHY_CK
  
  // PLL Type
  // --------
  // PLL type used for the process
  // default is type A - uncomment if using type B PLL
  `define DWC_DDRPHY_PLL_TYPEA
  //`define DWC_DDRPHY_PLL_TYPEB
  
  
  // I/O Type
  // --------
  // I/O type used for the process
  // default is D4MV - uncomment the one used
  // NOTE: D4MV2V5 IO has restricted availability and should not normally be selected
  `define DWC_DDRPHY_D4MV_IO
  //`define DWC_DDRPHY_D4MU_IO
 // `define DWC_DDRPHY_D4MV2V5_IO

`endif // !`ifdef DWC_DDRPHY_TB_OVERRIDE

`define DWC_NO_OF_PLL_VDD       1   // 1 contiguous pll_vdd for entire ring


//-----------------------------------------------------------------------------
// Address/Command Lane Configuration
//-----------------------------------------------------------------------------
// Macros that define address/command configuration


`ifdef DWC_DDRPHY_TB_OVERRIDE
`else
  // Retention Cell Type
  // -------------------
  // I/O cell type used for retention
  // 0 = core-side retention I/O (e.g. PRETLEC or PRETPOCC) 
  // 1 = pad-side retention I/O (e.g. PRETLEX or PRETPOCX) 
  `define DWC_RET_CELL_TYPE               0
  
  
  // Optional Pins
  // -------------
  // specifies, if defined, that the following pins must be included on the
  // address command lane 
  // comment out the define if the pin is to be excluded from the address/command
  // lane
  `define DWC_AC_RST_USE      // SDRAM reset (RST#)
  `define DWC_AC_ODT_USE      // SDRAM on-die termination (ODT)
  `define DWC_AC_CS_USE       // SDRAM chip select
  `define DWC_AC_ACT_USE      // SDRAM activate (ACT#)
  `define DWC_AC_BG_USE       // SDRAM bank group (BG)
  `define DWC_AC_BA_USE       // SDRAM bank address (BA)
  //`define DWC_AC_ALERTN_USE   // SDRAM alert output (ALERT_N)
  //`define DWC_AC_PARITY_USE   // SDRAM parity input (PARITY)
  // following two macros are used only by DDR3 RDIMMs
  //`define DWC_AC_QCSEN_USE   // RDIMM quad CS enable (QCSEN_N)
  //`define DWC_AC_MIRROR_USE  // RDIMM mirror (MIRROR)
  
  
  // The following must be defined to include I/Os for ato and dto pins in 
  // DDRPHYAC_io
  
  //`define DWC_AC_DTO_USE      // DDR PHY digital test output (DTO)
  //`define DWC_AC_ATO_USE      // DDR PHY analog test output (ATO)
  
  // to use east-west orientation of library cells on address/command lane,
  // uncomment the define
  `define DWC_AC_EW_USE
  
  // comment out if the PCKE I/O should NOT be used on the CKE signals;
  // if this define is commented out, then PDDRIO I/O will be used for CKE signals
  `define DWC_AC_PCKE_USE
  
  // include PRETPOC in AC
  `define DWC_AC_PRETPOC_USE

`endif // !`ifdef DWC_DDRPHY_TB_OVERRIDE


// I/O Island Usage
// ----------------
// number of VDDQ and ZIOH islands in the address/command lane
// e.g. 1. If using retention and the retention island is in the middle of the
//         address/command lane, then set DWC_AC_NO_OF_VDDQI to 3 and
//         DWC_AC_NO_OF_ZIOHI to 1, 2 or 3 depending on number of VREFs
//         (refer to documentation)
//      2. If using retention and the retention island is at one end of the lane, 
//         then set DWC_AC_NO_OF_VDDQI to 2 and DWC_AC_NO_OF_ZIOHI to 1 or 2
//      3. If not using retention (or no-island retention) then set
//         set DWC_AC_NO_OF_VDDQI to 1 and DWC_AC_NO_OF_ZIOHI to 1, 2 or 3
`define DWC_AC_NO_OF_VDDQI              2
`define DWC_AC_NO_OF_ZIOHI              2
// Number of VREF islands in AC - if not using D4MU IO, always leave this at 2
`define DWC_AC_NO_OF_VREFI              2
// Number of POCH islands in AC - always leave this at 1
`define DWC_AC_NO_OF_POCHI              1
// Number of VSSQ islands in AC - always leave this at 1
`define DWC_AC_NO_OF_VSSQI              1
// Number of PDRH18 islands in AC 
// if retention island is bounded by ZB_ZQ cell then set this to 3 if
// retention island is in middle of AC. Set this to 2 if retention island
// is at one end of AC.
// If there is no ZB_ZQ cell used then leave this at 1
`define DWC_AC_NO_OF_PDRH18I            2


// I/O Island Assignment
// ---------------------
// specifies which I/O island each of the address/command signal is in:

// SDRAM reset (RST#)
`define DWC_AC_RAM_RST_N0_INUM          0
`define DWC_AC_RAM_RST_N1_INUM          1
`define DWC_AC_RAM_RST_N2_INUM          1
`define DWC_AC_RAM_RST_N3_INUM          1
    
// output clock pairs (CK/CK#[2:0])
`define DWC_AC_CK0_INUM                 1
`define DWC_AC_CK1_INUM                 1
`define DWC_AC_CK2_INUM                 1
`define DWC_AC_CK3_INUM                 1

// clock enable (CKE[3:0])
`define DWC_AC_CKE0_INUM                0
`define DWC_AC_CKE1_INUM                0
`define DWC_AC_CKE2_INUM                1
`define DWC_AC_CKE3_INUM                1
`define DWC_AC_CKE4_INUM                1
`define DWC_AC_CKE5_INUM                1
`define DWC_AC_CKE6_INUM                1
`define DWC_AC_CKE7_INUM                1

// on-die termination (ODT[3:0])
`define DWC_AC_ODT0_INUM                1
`define DWC_AC_ODT1_INUM                1
`define DWC_AC_ODT2_INUM                1
`define DWC_AC_ODT3_INUM                1
`define DWC_AC_ODT4_INUM                1
`define DWC_AC_ODT5_INUM                1
`define DWC_AC_ODT6_INUM                1
`define DWC_AC_ODT7_INUM                1

// chip select (CS#[3:0])
`define DWC_AC_CS_N0_INUM               1
`define DWC_AC_CS_N1_INUM               1
`define DWC_AC_CS_N2_INUM               1
`define DWC_AC_CS_N3_INUM               1
`define DWC_AC_CS_N4_INUM               1
`define DWC_AC_CS_N5_INUM               1
`define DWC_AC_CS_N6_INUM               1
`define DWC_AC_CS_N7_INUM               1
`define DWC_AC_CS_N8_INUM               1
`define DWC_AC_CS_N9_INUM               1
`define DWC_AC_CS_N10_INUM              1
`define DWC_AC_CS_N11_INUM              1

// chip ID (CID[2:0])
`define DWC_AC_CID0_INUM                1
`define DWC_AC_CID1_INUM                1
`define DWC_AC_CID2_INUM                1

// command (ACT#)
`define DWC_AC_ACT_N_INUM               1

// bank address (BG[1:0]) 
`define DWC_AC_BG0_INUM                 1
`define DWC_AC_BG1_INUM                 1

// bank address (BA[1:0]) 
`define DWC_AC_BA0_INUM                 1
`define DWC_AC_BA1_INUM                 1

// address (A[2:0]) 
`define DWC_AC_A0_INUM                  1
`define DWC_AC_A1_INUM                  1
`define DWC_AC_A2_INUM                  1
`define DWC_AC_A3_INUM                  1
`define DWC_AC_A4_INUM                  1
`define DWC_AC_A5_INUM                  1
`define DWC_AC_A6_INUM                  1
`define DWC_AC_A7_INUM                  1
`define DWC_AC_A8_INUM                  1
`define DWC_AC_A9_INUM                  1
`define DWC_AC_A10_INUM                 1
`define DWC_AC_A11_INUM                 1
`define DWC_AC_A12_INUM                 1
`define DWC_AC_A13_INUM                 1
`define DWC_AC_A14_INUM                 1
`define DWC_AC_A15_INUM                 1
`define DWC_AC_A16_INUM                 1
`define DWC_AC_A17_INUM                 1

// Other AC pins
`define DWC_AC_PARITY_INUM              1
`define DWC_AC_ALERTN_INUM              1
`define DWC_AC_QCSEN_N_INUM             1
`define DWC_AC_MIRROR_INUM              1
`define DWC_AC_DTO0_INUM                1
`define DWC_AC_DTO1_INUM                1
`define DWC_AC_ATO_INUM                 1

// retention enable/disable I/O
`define DWC_AC_RET_INUM                 0


// Power and I/O Filler Cells
// --------------------------
// Number of power and filler I/O cells in each of the the up to 3 islands in
// address/command lane VDDQ, ZIOH, and VREF buses
// *_NO_OF_ZQ     : Number of ZQ  // Only one PZQ cell is allowed in either the AC lane or one of the DX lanes.
// *_NO_OF_V*     : Number of VREF, VDD, VSS, VDDQ, VSSQ, ZB, and ZB_ZQ
// *_NO_OF_F*     : Number of of fill cells
// *_NO_OF_F*_ISO : Number of of fill cells with VDDQ isolation
// *_NO_OF_CORNER : Number of of corner cells
// *_NO_OF_END    : Number of of end cells
// *_NO_OF_PLL_VDD: Number of PLL VDD/VSS pair cells (only 1 pair is allowed in
//                  the whole AC)

// AC VREF Island number
// Parameter to control VREF bus index since VREF is cut by IO calibration
// section.  Allowable values are 0 and 1
// Choose unique values for IOs on either side of IO calibration cells
`define DWC_AC_VREF_INUM                0 

// AC POCH Island number
`define DWC_AC_POCH_INUM                0 

// AC VSSQ Island number
`define DWC_AC_VSSQ_INUM                0 

// I/O island 0
`define DWC_AC_I0_NO_OF_ZQ              0
`define DWC_AC_I0_NO_OF_VREF            1
`define DWC_AC_I0_NO_OF_VREFE           0
`define DWC_AC_I0_NO_OF_VDD_ESD         4
`define DWC_AC_I0_NO_OF_VDD_CAP         0
`define DWC_AC_I0_NO_OF_VSH_ESD         1
`define DWC_AC_I0_NO_OF_VSH_CAP         0
`define DWC_AC_I0_NO_OF_VSS_ESD         4
`define DWC_AC_I0_NO_OF_VSS_CAP         1
`define DWC_AC_I0_NO_OF_VDDQ_ESD        12
`define DWC_AC_I0_NO_OF_VDDQ_CAP        0
`define DWC_AC_I0_NO_OF_VSSQ            16
`define DWC_AC_I0_NO_OF_ZB              0
`define DWC_AC_I0_NO_OF_ZB_ZQ           0
`define DWC_AC_I0_NO_OF_FILLT1          0
`define DWC_AC_I0_NO_OF_FILLT2          0
`define DWC_AC_I0_NO_OF_FILLT3          0
`define DWC_AC_I0_NO_OF_FILLT4          0
`define DWC_AC_I0_NO_OF_FILLISOT1       2
`define DWC_AC_I0_NO_OF_FILLISOT2       0
`define DWC_AC_I0_NO_OF_CORNER          1
`define DWC_AC_I0_NO_OF_END             0
`define DWC_AC_I0_NO_OF_PLL_VDD         4

// I/O island 1
`define DWC_AC_I1_NO_OF_ZQ              1
`define DWC_AC_I1_NO_OF_VREF            1
`define DWC_AC_I1_NO_OF_VREFE           0
`define DWC_AC_I1_NO_OF_VDD_ESD         0
`define DWC_AC_I1_NO_OF_VDD_CAP         0
`define DWC_AC_I1_NO_OF_VSH_ESD         0
`define DWC_AC_I1_NO_OF_VSH_CAP         0
`define DWC_AC_I1_NO_OF_VSS_ESD         0
`define DWC_AC_I1_NO_OF_VSS_CAP         0
`define DWC_AC_I1_NO_OF_VDDQ_ESD        0
`define DWC_AC_I1_NO_OF_VDDQ_CAP        0
`define DWC_AC_I1_NO_OF_VSSQ            0
`define DWC_AC_I1_NO_OF_ZB              0
`define DWC_AC_I1_NO_OF_ZB_ZQ           1
`define DWC_AC_I1_NO_OF_FILLT1          0
`define DWC_AC_I1_NO_OF_FILLT2          0
`define DWC_AC_I1_NO_OF_FILLT3          0
`define DWC_AC_I1_NO_OF_FILLT4          0
`define DWC_AC_I1_NO_OF_FILLISOT1       0
`define DWC_AC_I1_NO_OF_FILLISOT2       0
`define DWC_AC_I1_NO_OF_CORNER          0
`define DWC_AC_I1_NO_OF_END             0
`define DWC_AC_I1_NO_OF_PLL_VDD         0

// I/O island 2
`define DWC_AC_I2_NO_OF_ZQ              0
`define DWC_AC_I2_NO_OF_VREF            0
`define DWC_AC_I2_NO_OF_VREFE           0
`define DWC_AC_I2_NO_OF_VDD_ESD         0
`define DWC_AC_I2_NO_OF_VDD_CAP         0
`define DWC_AC_I2_NO_OF_VSH_ESD         0
`define DWC_AC_I2_NO_OF_VSH_CAP         0
`define DWC_AC_I2_NO_OF_VSS_ESD         0
`define DWC_AC_I2_NO_OF_VSS_CAP         0
`define DWC_AC_I2_NO_OF_VDDQ_ESD        0
`define DWC_AC_I2_NO_OF_VDDQ_CAP        0
`define DWC_AC_I2_NO_OF_VSSQ            0
`define DWC_AC_I2_NO_OF_ZB              0
`define DWC_AC_I2_NO_OF_ZB_ZQ           0
`define DWC_AC_I2_NO_OF_FILLT1          0
`define DWC_AC_I2_NO_OF_FILLT2          0
`define DWC_AC_I2_NO_OF_FILLT3          0
`define DWC_AC_I2_NO_OF_FILLT4          0
`define DWC_AC_I2_NO_OF_FILLISOT1       0
`define DWC_AC_I2_NO_OF_FILLISOT2       0
`define DWC_AC_I2_NO_OF_CORNER          0
`define DWC_AC_I2_NO_OF_END             0
`define DWC_AC_I2_NO_OF_PLL_VDD         0

// I/O island 3
`define DWC_AC_I3_NO_OF_ZQ              0
`define DWC_AC_I3_NO_OF_VREF            0
`define DWC_AC_I3_NO_OF_VREFE           0
`define DWC_AC_I3_NO_OF_VDD_ESD         0
`define DWC_AC_I3_NO_OF_VDD_CAP         0
`define DWC_AC_I3_NO_OF_VSH_ESD         0
`define DWC_AC_I3_NO_OF_VSH_CAP         0
`define DWC_AC_I3_NO_OF_VSS_ESD         0
`define DWC_AC_I3_NO_OF_VSS_CAP         0
`define DWC_AC_I3_NO_OF_VDDQ_ESD        0
`define DWC_AC_I3_NO_OF_VDDQ_CAP        0
`define DWC_AC_I3_NO_OF_VSSQ            0
`define DWC_AC_I3_NO_OF_ZB              0
`define DWC_AC_I3_NO_OF_ZB_ZQ           0
`define DWC_AC_I3_NO_OF_FILLT1          0
`define DWC_AC_I3_NO_OF_FILLT2          0
`define DWC_AC_I3_NO_OF_FILLT3          0
`define DWC_AC_I3_NO_OF_FILLT4          0
`define DWC_AC_I3_NO_OF_FILLISOT1       0
`define DWC_AC_I3_NO_OF_FILLISOT2       0
`define DWC_AC_I3_NO_OF_CORNER          0
`define DWC_AC_I3_NO_OF_END             0
`define DWC_AC_I3_NO_OF_PLL_VDD         0

// there can be up to 3 ZQ pins in, or associated with, the AC; specify the 
// number of VREFs used for each of the up to 3 ZQ pins/ZQ calibrartion controller
// NOTE: the total number specified here must equal the total number
//       specified by the DWC_AC_I*_NO_OF_VREF macros
`define DWC_AC_Z0_NO_OF_VREF            1
`define DWC_AC_Z1_NO_OF_VREF            0
`define DWC_AC_Z2_NO_OF_VREF            0

// Following values specify the PDRH18 island for VREF cells of each AC island. 
// This can help placing the VREF cell of adjacent AC islands to share the PDRH18 bus. 
// eg: set DWC_AC_I0_VREF_PDRH18_INUM = 0 and DWC_AC_I1_VREF_PDRH18_INUM = 0 
//     VEREF cells of AC IO and I1 are belong to PDRH18 island 0,
//     and share the PDRH18 bus.
//     set DWC_AC_I1_VREF_PDRH18_INUM = 1 and DWC_AC_I2_VREF_PDRH18_INUM = 1 
//     VEREF cells of AC I1 and I2 are belong to PDRH18 island 1,
//     and share the PDRH18 bus.
// NOTE: the max island number specified here must not exceed the total PDRH18 
//       island number specified by the DWC_AC_NO_OF_PDRH18I macro.
//       For the AC island not used, keep its value as 0
`define DWC_AC_I0_VREF_PDRH18_INUM        0
`define DWC_AC_I1_VREF_PDRH18_INUM        1
`define DWC_AC_I2_VREF_PDRH18_INUM        0
`define DWC_AC_I3_VREF_PDRH18_INUM        0


// Bond Pad Type
// -------------
// these settings are valid only if DWC_PPAD_USE is set to 1 (i.e. bond pads 
// are to be instantiated): specifies whether an outer or inner bond pad cell
// is used for the I/O, a value of 1 means outer bond pad and value of 0 means
// inner bond band; for multi-bit signals, each bit controls the bond pad type
// for the corresponding signal bit; default for signal I/Os is inner bond pad
// NOTE: ZZB_PPADO specifies which of the two ZB cells used for
//       breaking the PZQ ZIOH bus should use an outer or innner bond pad
`define DWC_AC_RAM_RST_N_PPADO          4'b0000
`define DWC_AC_CK_PPADO                 4'b0000
`define DWC_AC_CK_N_PPADO               4'b0000
`define DWC_AC_CKE_PPADO                8'b00000000
`define DWC_AC_ODT_PPADO                8'b00000000
`define DWC_AC_CS_N_PPADO               12'b000000000000 
`define DWC_AC_CID_PPADO                3'b000
`define DWC_AC_ACT_N_PPADO              1'b0
`define DWC_AC_BG_PPADO                 2'b00
`define DWC_AC_BA_PPADO                 2'b00
`define DWC_AC_A_PPADO                  16'h0000
`define DWC_AC_PARITY_PPADO             1'b0
`define DWC_AC_ALERTN_PPADO             1'b0
`define DWC_AC_QCSEN_N_PPADO            1'b0
`define DWC_AC_MIRROR_PPADO             1'b0
`define DWC_AC_DTO_PPADO                2'b00
`define DWC_AC_ATO_PPADO                1'b0
`define DWC_AC_RET_PPADO                1'b0   
`define DWC_AC_ZZB_PPADO                2'b00   

// these settings are valid only if DWC_PPAD_USE is set to 1 (i.e. bond pads 
// are to be instantiated): specifies how many non-signal (power, etc) I/Os
// use outer or inner bond pad cells in each of the up to 3 islands in
// address/command; a value of 1 means inner bond pad, and value of 0 means 
// outer bond band; default for non-signal I/O is outer bond pad
`define DWC_AC_I0_NO_OF_ZQ_PPADI        0
`define DWC_AC_I0_NO_OF_ZCTRL_PPADI     0
`define DWC_AC_I0_NO_OF_VREF_PPADI      0
`define DWC_AC_I0_NO_OF_VREFE_PPADI     0
`define DWC_AC_I0_NO_OF_VDD_ESD_PPADI   0
`define DWC_AC_I0_NO_OF_VDD_CAP_PPADI   0
`define DWC_AC_I0_NO_OF_VSS_PPADI       0
`define DWC_AC_I0_NO_OF_VDDQ_ESD_PPADI  0
`define DWC_AC_I0_NO_OF_VDDQ_CAP_PPADI  0
`define DWC_AC_I0_NO_OF_VSSQ_PPADI      0
`define DWC_AC_I0_NO_OF_ZB_PPADI        0
`define DWC_AC_I0_NO_OF_ZB_ZQ_PPADI     0
`define DWC_AC_I0_NO_OF_PLL_VDD_PPADI   0

// I/O island 1
`define DWC_AC_I1_NO_OF_ZQ_PPADI        0
`define DWC_AC_I1_NO_OF_ZCTRL_PPADI     0
`define DWC_AC_I1_NO_OF_VREF_PPADI      0
`define DWC_AC_I1_NO_OF_VREFE_PPADI     0
`define DWC_AC_I1_NO_OF_VDD_ESD_PPADI   0
`define DWC_AC_I1_NO_OF_VDD_CAP_PPADI   0
`define DWC_AC_I1_NO_OF_VSS_PPADI       0
`define DWC_AC_I1_NO_OF_VDDQ_ESD_PPADI  0
`define DWC_AC_I1_NO_OF_VDDQ_CAP_PPADI  0
`define DWC_AC_I1_NO_OF_VSSQ_PPADI      0
`define DWC_AC_I1_NO_OF_ZB_PPADI        0
`define DWC_AC_I1_NO_OF_ZB_ZQ_PPADI     0
`define DWC_AC_I1_NO_OF_PLL_VDD_PPADI   0

// I/O island 2
`define DWC_AC_I2_NO_OF_ZQ_PPADI        0
`define DWC_AC_I2_NO_OF_ZCTRL_PPADI     0
`define DWC_AC_I2_NO_OF_VREF_PPADI      0
`define DWC_AC_I2_NO_OF_VREFE_PPADI     0
`define DWC_AC_I2_NO_OF_VDD_ESD_PPADI   0
`define DWC_AC_I2_NO_OF_VDD_CAP_PPADI   0
`define DWC_AC_I2_NO_OF_VSS_PPADI       0
`define DWC_AC_I2_NO_OF_VDDQ_ESD_PPADI  0
`define DWC_AC_I2_NO_OF_VDDQ_CAP_PPADI  0
`define DWC_AC_I2_NO_OF_VSSQ_PPADI      0
`define DWC_AC_I2_NO_OF_ZB_PPADI        0
`define DWC_AC_I2_NO_OF_ZB_ZQ_PPADI     0
`define DWC_AC_I2_NO_OF_PLL_VDD_PPADI   0

// I/O island 3
`define DWC_AC_I3_NO_OF_ZQ_PPADI        0
`define DWC_AC_I3_NO_OF_ZCTRL_PPADI     0
`define DWC_AC_I3_NO_OF_VREF_PPADI      0
`define DWC_AC_I3_NO_OF_VREFE_PPADI     0
`define DWC_AC_I3_NO_OF_VDD_ESD_PPADI   0
`define DWC_AC_I3_NO_OF_VDD_CAP_PPADI   0
`define DWC_AC_I3_NO_OF_VSS_PPADI       0
`define DWC_AC_I3_NO_OF_VDDQ_ESD_PPADI  0
`define DWC_AC_I3_NO_OF_VDDQ_CAP_PPADI  0
`define DWC_AC_I3_NO_OF_VSSQ_PPADI      0
`define DWC_AC_I3_NO_OF_ZB_PPADI        0
`define DWC_AC_I3_NO_OF_ZB_ZQ_PPADI     0
`define DWC_AC_I3_NO_OF_PLL_VDD_PPADI   0

// these spcifies whether the VREF cell for the PZQ should

// number assigned to PLL VDD/VSS pair used by address/command lane; this is the
// PLL VDD/VSS pair that the address/command lane PLL is connected to. It also
// specifies the PLL VDD/VSS pair that the PLL VSS/VDD I/Os in the address/
// command lane are connected to if the PLL VDD/VSS I/Os are configured to be 
// included in the address/commands lane using DWC_AC_I*_NO_OF_PLL_VDD
`define DWC_AC_PLL_VDD_NUM              0


// Address/Command Pin Mapping
// ---------------------------
// Specifies the mapping of the address/command pins to the AC slices in
// the AC macro and the CK pins to the CK slices in the AC macro
// NOTE: if LPDDR2/3 is part of the design, then CKE, CS#, and ODT can only
//       be assigned slices 24 to 35
// NOTE: Rank (CS_N, ODT, CKE) and 3DS (CID) signals can only be assigned
//       24 to 47 - any unused rank/3DS signals must be assigned to 0 if all
//       slices are already assigned

// output clock pairs (CK/CK#[2:0])
`define DWC_AC_CK0_PNUM                0
`define DWC_AC_CK1_PNUM                1
`define DWC_AC_CK2_PNUM                2
`define DWC_AC_CK3_PNUM                3

// address (A[17:0]) and command (ACT#, RAS#, CAS#, WE#)
//   - DDR4  : A[17]    = A[17]
//             A[16]    = A[16]/RAS#
//             A[15]    = A[15]/CAS#
//             A[14]    = A[14]/WE#
//             A[13:0]  = A[13:0] 
//             ACT#     = ACT# 
//   - DDR3  : A[17]    = CAS#
//             A[16]    = WE#
//             A[15:0]  = A[15:0] 
//             RAS#     = ACT#
//   - LPDDRn: A[17:10] = Not used
//             A[9:0]   = A[9:0] 
`define DWC_AC_A0_PNUM                 0
`define DWC_AC_A1_PNUM                 1
`define DWC_AC_A2_PNUM                 2
`define DWC_AC_A3_PNUM                 3
`define DWC_AC_A4_PNUM                 4
`define DWC_AC_A5_PNUM                 5
`define DWC_AC_A6_PNUM                 6
`define DWC_AC_A7_PNUM                 7
`define DWC_AC_A8_PNUM                 8
`define DWC_AC_A9_PNUM                 9
`define DWC_AC_A10_PNUM                10
`define DWC_AC_A11_PNUM                11
`define DWC_AC_A12_PNUM                12
`define DWC_AC_A13_PNUM                13
`define DWC_AC_A14_PNUM                14
`define DWC_AC_A15_PNUM                15
`define DWC_AC_A16_PNUM                16
`define DWC_AC_A17_PNUM                17

// command (ACT#)
`define DWC_AC_ACT_N_PNUM              18

// bank address (BG[1:0]) 
//   - DDR4  : BG[1:0] = BG[1:0]
//   - DDR3  : BG[1]   = Not used
//             BG[0]   = BA[2]
//   - LPDDRn: BG[1:0] = Not used
`define DWC_AC_BG0_PNUM                21
`define DWC_AC_BG1_PNUM                22
  
// bank address (BA[1:0]) 
//   - DDR4  : BA[1:0] = BA[1:0]
//   - DDR3  : BA[1:0] = BA[1:0]
//   - LPDDRn: B[3:0]  = Not used
`define DWC_AC_BA0_PNUM                19
`define DWC_AC_BA1_PNUM                20
  
// parity input
`define DWC_AC_PARITY_PNUM             23

// ACx48 Address/Command Pin Mapping
`ifdef DWC_DDRPHY_ACX48

  // chip select (CS#[3:0])
  `define DWC_AC_CS_N0_PNUM              24
  `define DWC_AC_CS_N1_PNUM              ((`DWC_RCD_MODE == 0) ? 27 : 25)
  `define DWC_AC_CS_N2_PNUM              ((`DWC_RCD_MODE == 0 || `DWC_RCD_MODE == 1) ? 30 : 26)
  `define DWC_AC_CS_N3_PNUM              ((`DWC_RCD_MODE == 0) ? 33 : (`DWC_RCD_MODE == 1 || `DWC_RCD_MODE == 3) ? 31 : 27)
  `define DWC_AC_CS_N4_PNUM              ((`DWC_RCD_MODE == 2) ? 32 : (`DWC_RCD_MODE == 3) ? 32 : 36)
  `define DWC_AC_CS_N5_PNUM              ((`DWC_RCD_MODE == 0) ? 39 : (`DWC_RCD_MODE == 1) ? 37 : 33)
  `define DWC_AC_CS_N6_PNUM              ((`DWC_RCD_MODE == 2) ? 34 : (`DWC_RCD_MODE == 3) ? 38 : 42)
  `define DWC_AC_CS_N7_PNUM              ((`DWC_RCD_MODE == 0) ? 0 : (`DWC_RCD_MODE == 1) ? 43 : (`DWC_RCD_MODE == 2) ? 35 : 39)
  `define DWC_AC_CS_N8_PNUM              ((`DWC_RCD_MODE == 2 || `DWC_RCD_MODE == 3) ? 40 : 0)
  `define DWC_AC_CS_N9_PNUM              ((`DWC_RCD_MODE == 2) ? 41 : 0)
  `define DWC_AC_CS_N10_PNUM             ((`DWC_RCD_MODE == 2) ? 42 : 0)
  `define DWC_AC_CS_N11_PNUM             ((`DWC_RCD_MODE == 2) ? 43 : 0)

  // on-die termination (ODT[3:0])
  `define DWC_AC_ODT0_PNUM               ((`DWC_RCD_MODE == 0) ? 25 : (`DWC_RCD_MODE == 1) ? 26 : (`DWC_RCD_MODE == 2) ? 28 : 27)
  `define DWC_AC_ODT1_PNUM               ((`DWC_RCD_MODE == 1) ? 27 : (`DWC_RCD_MODE == 2) ? 29 : 28)
  `define DWC_AC_ODT2_PNUM               ((`DWC_RCD_MODE == 0) ? 31 : (`DWC_RCD_MODE == 1) ? 32 : (`DWC_RCD_MODE == 2) ? 36 : 34)
  `define DWC_AC_ODT3_PNUM               ((`DWC_RCD_MODE == 0) ? 34 : (`DWC_RCD_MODE == 1) ? 33 : (`DWC_RCD_MODE == 2) ? 37 : 35)
  `define DWC_AC_ODT4_PNUM               ((`DWC_RCD_MODE == 0) ? 37 : (`DWC_RCD_MODE == 1) ? 38 : (`DWC_RCD_MODE == 2) ? 44 : 41)
  `define DWC_AC_ODT5_PNUM               ((`DWC_RCD_MODE == 0) ? 40 : (`DWC_RCD_MODE == 1) ? 39 : (`DWC_RCD_MODE == 2 && `DWC_NO_OF_RANKS == 12) ? 45 : (`DWC_RCD_MODE == 3) ? 42 : 0)
  `define DWC_AC_ODT6_PNUM               ((`DWC_RCD_MODE == 0) ? 43 : (`DWC_RCD_MODE == 1) ? 44 : 0)
  `define DWC_AC_ODT7_PNUM               ((`DWC_RCD_MODE == 1 && `DWC_NO_OF_RANKS == 8) ? 45 : 0)

  // clock enable (CKE[3:0])
  `define DWC_AC_CKE0_PNUM               ((`DWC_RCD_MODE == 0) ? 26 : (`DWC_RCD_MODE == 1) ? 28 : (`DWC_RCD_MODE == 2) ? 30 : 29)
  `define DWC_AC_CKE1_PNUM               ((`DWC_RCD_MODE == 2) ? 31 : (`DWC_RCD_MODE == 3) ? 30 : 29)
  `define DWC_AC_CKE2_PNUM               ((`DWC_RCD_MODE == 0) ? 32 : (`DWC_RCD_MODE == 1) ? 34 : (`DWC_RCD_MODE == 2) ? 38 : 36)
  `define DWC_AC_CKE3_PNUM               ((`DWC_RCD_MODE == 2) ? 39 : (`DWC_RCD_MODE == 3) ? 37 : 35)
  `define DWC_AC_CKE4_PNUM               ((`DWC_RCD_MODE == 0) ? 38 : (`DWC_RCD_MODE == 1) ? 40 : (`DWC_RCD_MODE == 2 && `DWC_NO_OF_RANKS == 12) ? 46 : (`DWC_RCD_MODE == 3) ? 43 : 0)
  `define DWC_AC_CKE5_PNUM               ((`DWC_RCD_MODE == 1) ? 41 : (`DWC_RCD_MODE == 2 && `DWC_NO_OF_RANKS == 12) ? 47 : (`DWC_RCD_MODE == 3) ? 44 : 0)
  `define DWC_AC_CKE6_PNUM               ((`DWC_RCD_MODE == 0) ? 44 : (`DWC_RCD_MODE == 1 && `DWC_NO_OF_RANKS == 8) ? 46 : 0)
  `define DWC_AC_CKE7_PNUM               ((`DWC_RCD_MODE == 1 && `DWC_NO_OF_RANKS == 8) ? 47 : 0)

  // chip ID (CID[2:0])
  `ifdef DWC_NO_OF_3DS_STACKS 
    `define DWC_AC_CID0_PNUM               ((`DWC_NO_OF_3DS_STACKS == 0) ? 0 : 45)
    `define DWC_AC_CID1_PNUM               ((`DWC_NO_OF_3DS_STACKS == 0 || `DWC_NO_OF_3DS_STACKS == 2) ? 0 : 46)
    `define DWC_AC_CID2_PNUM               ((`DWC_NO_OF_3DS_STACKS == 8) ? 47 : 0)
  `else
    `define DWC_AC_CID0_PNUM               0
    `define DWC_AC_CID1_PNUM               0
    `define DWC_AC_CID2_PNUM               0
  `endif

// ACPHY Address/Command Pin Mapping
`else  //DDRPHY_ACPHY

  // chip select (CS#[3:0])
  `define DWC_AC_CS_N0_PNUM              24
  `define DWC_AC_CS_N1_PNUM              ((`DWC_RCD_MODE == 0) ? 27 : 25)
  `define DWC_AC_CS_N2_PNUM              ((`DWC_RCD_MODE == 0 || `DWC_RCD_MODE == 1) ? 30 : 26)
  `define DWC_AC_CS_N3_PNUM              ((`DWC_RCD_MODE == 0 && `DWC_NO_OF_RANKS == 4) ? 33 : (`DWC_RCD_MODE == 1) ? 31 : (`DWC_RCD_MODE == 2) ? 27 : 0)
  `define DWC_AC_CS_N4_PNUM              0
  `define DWC_AC_CS_N5_PNUM              0
  `define DWC_AC_CS_N6_PNUM              0
  `define DWC_AC_CS_N7_PNUM              0
  `define DWC_AC_CS_N8_PNUM              0 
  `define DWC_AC_CS_N9_PNUM              0 
  `define DWC_AC_CS_N10_PNUM             0 
  `define DWC_AC_CS_N11_PNUM             0 

  // on-die termination (ODT[3:0])
  `define DWC_AC_ODT0_PNUM               ((`DWC_RCD_MODE == 0) ? 25 : (`DWC_RCD_MODE == 1) ? 26 : (`DWC_RCD_MODE == 2) ? 28 : 27)
  `define DWC_AC_ODT1_PNUM               ((`DWC_RCD_MODE == 1) ? 27 : (`DWC_RCD_MODE == 2) ? 29 : 28)
  `define DWC_AC_ODT2_PNUM               ((`DWC_RCD_MODE == 0) ? 31 : 32)
  `define DWC_AC_ODT3_PNUM               ((`DWC_RCD_MODE == 0 && `DWC_NO_OF_RANKS == 4) ? 34 : (`DWC_RCD_MODE == 1 && `DWC_NO_OF_RANKS == 4) ? 33 : 0)
  `define DWC_AC_ODT4_PNUM               0
  `define DWC_AC_ODT5_PNUM               0
  `define DWC_AC_ODT6_PNUM               0
  `define DWC_AC_ODT7_PNUM               0

  // clock enable (CKE[3:0])
  `define DWC_AC_CKE0_PNUM               ((`DWC_RCD_MODE == 0) ? 26 : (`DWC_RCD_MODE == 1) ? 28 : (`DWC_RCD_MODE == 2) ? 30 : 29)
  `define DWC_AC_CKE1_PNUM               ((`DWC_RCD_MODE == 2) ? 31 : (`DWC_RCD_MODE == 3) ? 30 : 29)
  `define DWC_AC_CKE2_PNUM               ((`DWC_RCD_MODE == 0) ? 32 : (`DWC_RCD_MODE == 1 && `DWC_NO_OF_RANKS == 4) ? 34 : 0)
  `define DWC_AC_CKE3_PNUM               (((`DWC_RCD_MODE == 0 || `DWC_RCD_MODE == 1) && `DWC_NO_OF_RANKS == 4) ? 35 : 0)
  `define DWC_AC_CKE4_PNUM               0
  `define DWC_AC_CKE5_PNUM               0
  `define DWC_AC_CKE6_PNUM               0
  `define DWC_AC_CKE7_PNUM               0

  // chip ID (CID[2:0])
  `ifdef DWC_NO_OF_3DS_STACKS 
    `define DWC_AC_CID0_PNUM               ((`DWC_NO_OF_3DS_STACKS == 0) ? 0 : 33)
    `define DWC_AC_CID1_PNUM               ((`DWC_NO_OF_3DS_STACKS == 0 || `DWC_NO_OF_3DS_STACKS == 2) ? 0 : 34)
    `define DWC_AC_CID2_PNUM               ((`DWC_NO_OF_3DS_STACKS == 8) ? 35 : 0)
  `else
    `define DWC_AC_CID0_PNUM               0
    `define DWC_AC_CID1_PNUM               0
    `define DWC_AC_CID2_PNUM               0

  `endif

`endif //!`ifdef DWC_DDRPHY_ACX48


//-----------------------------------------------------------------------------
// Byte Lanes Configuration
//-----------------------------------------------------------------------------
// Macros that define byte lanes configuration


`ifdef DWC_DDRPHY_TB_OVERRIDE
`else
  // Use of VREFO port on DDRPHY_TOP
  // -------------
  // indicates the instance the VREFO port on DDRPHY_TOP;
  // comment out the define if there is no VREFE cell in DX and AC.
  // uncomment and set it as 1 if only DX or AC have VREFE cell,
  // uncomment and set it as 2 if both DX and AC have VREFE cell.
  //  - e.g. comment it 
  //         when (`DWC_AC_I0_NO_OF_VREFE + `DWC_AC_I1_NO_OF_VREFE + `DWC_AC_I2_NO_OF_VREFE) == 0)
  //         && `DWC_DX_VREFE_USE == 9'h000
  //  - e.g. uncomment it, and set it as 1
  //         when (`DWC_AC_I0_NO_OF_VREFE + `DWC_AC_I1_NO_OF_VREFE + `DWC_AC_I2_NO_OF_VREFE) != 0) 
  //         && `DWC_DX_VREFE_USE == 9'h000
  //         or (`DWC_AC_I0_NO_OF_VREFE + `DWC_AC_I1_NO_OF_VREFE + `DWC_AC_I2_NO_OF_VREFE) == 0) 
  //         && `DWC_DX_VREFE_USE != 9'h000
  //  - e.g. uncomment it, and set it as 2
  //         when (`DWC_AC_I0_NO_OF_VREFE + `DWC_AC_I1_NO_OF_VREFE + `DWC_AC_I2_NO_OF_VREFE) != 0) 
  //         && `DWC_DX_VREFE_USE != 9'h000
  //  Note:  we can't uncomment it and set it as 0
  //`define DWC_VREFO_USE                  2


  // Optional Pins
  // -------------
  // indicates if the specified type of I/O should be included in the byte;
  // a '1' on a bit position specifies if the I/O is included in the
  // correspondingly numbered byte
  //  - e.g. to put a VREF cell in bytes 0 and 5, set DWC_DX_VREF_USE to 9'h021
  //  - e.g. to use east-west orientation of library cells on bytes 1 and 8, set
  //         DWC_DX_EW_USE to 9'h102
  `define DWC_DX_ZQ_USE                   9'h000 // include ZQ 
  //  Only one PZQ cell allowed in either the AC lane or in one of the DX lanes.
  `define DWC_DX_VREF_USE                 9'h000 | {`DWC_NO_OF_BYTES{1'b1}} // include VREF
  `define DWC_DX_VREFE_USE                9'h000 // include VREFE
  `define DWC_DX_CORNER_USE               9'h000 // include CORNER
  `define DWC_DX_END_USE                  9'h081 // include END
  // include EXTRA PEND cell if supporting segmented/discrete byte arrangements. 
  // by default DWC_DX_END_USE allows only one PEND cell to be inserted per
  // byte. With this macro, the same byte can have an additional PEND cell
  // instantiated
  `define DWC_DX_EXTRA_END_USE            9'h000 
  `define DWC_DX_PRETPOC_USE              9'h000 // include PRETPOC
  `define DWC_DX_EW_USE                   9'h00F // use EW cells (only for Type B1 PHYs)
  `define DWC_DX_PLL_VDD_USE              9'h1FF // include PLL VDD/VSS pair
  `define DWC_DX_VREF_DAC_USE             9'h000 | {`DWC_NO_OF_BYTES{1'b1}} // include PVREF_DAC
  // following is used only in X4 mode and applies to byte lanes in PLL share hierarchies
  // This macro controls how the PVAA_PLL cell is placed
  // the macro controls which nibble the PVAA_PLL is placed in, so that
  // alignment is better under PLL
  // if a bit is set to '0' then that byte is oriented in clockwise direction
  // and PVAA_PLL is placed in nibble 0
  // if a bit is set to '1' then that byte is oriented in counter clockwise direction
  // and PVAA_PLL is placed in nibble 1
  // NOTE: If DWC_DDRPHY_X4X2 macro is not enabled, set to 9'h000
  `define DWC_DX_ORIENT_USE               9'h000 
  
  // following are used only in X4 mode and applies to byte lanes in PLL share hierarchies
  // These macros control how the CORNER/VREFE/PRETPOCX/PRETPOCC cell is placed
  // the macro controls which nibble the CORNER/VREFE/PRETPOCX/PRETPOCC is placed in
  // if a bit is set to '0' then that byte is oriented in clockwise direction
  // and CORNER/VREFE/PRETPOCX/PRETPOCC is placed in nibble 0
  // if a bit is set to '1' then that byte is oriented in counter clockwise direction
  // and CORNER/VREFE/PRETPOCX/PRETPOCC is placed in nibble 1
  // NOTE: If DWC_DDRPHY_X4X2 macro is not enabled, set to 9'h000
  `define DWC_DX_CORNER_ORIENT_USE               9'h000
  `define DWC_DX_VREFE_ORIENT_USE                9'h000
  `define DWC_DX_PRETPOC_ORIENT_USE              9'h000

  // indicates if the digital or analog test output pins is located in the byte
  // byte lane; since only one set of DTO and one set of ATO pins is currently
  // currently supported, only one bit of these macros can be set and only if
  // DWC_AC_DTO_USE and DWC_AC_ATO_USE, respectively, are not defined
  // DWC_PHY_DTO_USE and DWC_PHY_ATO_USE have to be defined in order to have dto 
  // and ato pins at the phy_top level
  
  //`define DWC_DX_DTO_USE                  9'h000 // include DTO
  //`define DWC_DX_ATO_USE                  9'h000 // include ATO
  
  // specifies, if defined, that the following pins must be included on the
  // byte lanes
  // uncomment the define if the pin is to be excluded from the byte lane
  `define DWC_DX_DM_USE                     // SDRAM data mask (DM)
  
  // Specifies the number of DQs that are not available (no I/Os instatiated) on
  // the most significant byte. No I/Os will be instantiated for these DQs and
  // these DQ bits will be ignored in the PUB for training and other operations.
  // Only DQ bits [8-DWC_MSB_NQD-1:0] on the most significant byte will have I/Os 
  // and will be used in the PUB. All the other bytes are not affected by this
  // parameter
  `define DWC_MSBYTE_NDQ                  3'd0
  
  // indicates if this byte shares one PLL with another byte;
  // a '1' on a bit position specifies if PLL sharing is used by the correspondingly numbered
  // byte; Only the least numbered byte of the two bytes sharing the PLL should be specified
  // with a '1' setting - the other byte should still have a '0' at its position
  //  - e.g. to share a PLL between bytes 0 and 1, set DWC_DX_PLL_SHARE to 9'h001 (9'b0000000_01)
  //  - e.g. to share a PLL between  bytes 1 and 2, 3 and 4, 5 and 6, 
  //         set DWC_DX_PLL_SHARE to 9'h072A(9'b00_01_01_01_0)
  // NOTE: This is valid only if DWC_DDRPHY_PLL_USE is set, otherwise should be left at the
  //       default setting of 9'h000 for all other PHYs
  `define DWC_DX_PLL_SHARE                9'h000 // share PLL between bytes
  
  // Following macro controls ZIOH/VREF/VREFSE/PDRH18 connectivity for a PLL share hierarchy
  // This macro informs the IP whether the two bytes in a PLL share hierarchy
  // share ZIOH/VREF/VREFSE/PDRH18 or not. If this macro is uncommented, then
  // it indicates that there are no ZIOH/VREF/VREFSE/PDRH18 cuts anywhere
  // between the bytes the DATX8
  // keep this macro commented out, if DWC_DDRPHY_X4X2 macro is enabled
  // keep this macro commented out, if ZB_ZQ cells are used in PLL shared DATX8 hierarchy
  // `define DWC_DX_PLL_SHARE_CONTIGUOUS
  
  // indicates if a byte shares one PLL with address/command lane;
  // only one bit of this macros may be set
  `define DWC_DX_AC_PLL_SHARE             9'h000 // share PLL between byte and address/command

`endif // !`ifdef DWC_DDRPHY_TB_OVERRIDE

// indicates if this byte uses a dedicated PRETPOCC cell
// a '1' on a bit position specifies if PRETPOC cell is used by the correspondingly numbered byte;
// NOTE: This should be set to non-zero only if segmented DATX8 bytes are used
// otherwise, for contiguous IOs, leave at default value of 9'h000
`define DWC_DX_USE_PRETPOC              9'h000 // use a dedicate PRETPOC 

// number of ZIOH islands in the byte lanes: these are unique ZIOH islands
// that are totally isolated from the ZIOH islands in the address/command lane;
// do not count in ZIOH islands that simply extend (connect) from the 
// address/command lane to the byte lanes
  `define DWC_DX_NO_OF_ZIOHI            `DWC_NO_OF_BYTES * `DWC_DX_NO_OF_VREF 

// Number of VREF islands in DATX8
// If all DATX8 and AC IOs are on the same side of calibration island,
// change this to 0  
  `define DWC_DX_NO_OF_VREFI            `DWC_NO_OF_BYTES * `DWC_DX_NO_OF_VREF 

// Number of PDRH18 islands in DATX8
// default value is 0
// change this depending on ZB_ZQ cell usage in DATX8
// if ZB_ZQ cell is not used in DATX8, set this to 0
// otherwise set this parameter to number of ZB_ZQ cells
  `define DWC_DX_NO_OF_PDRH18I          `DWC_NO_OF_BYTES * `DWC_DX_NO_OF_VREF 

// Number of POCH islands in DATX8
// default value is 1
// If all DATX8 and AC IOs are on the same side of calibration island,
// change this to 0  
`define DWC_DX_NO_OF_POCHI              0  

// Number of VSSQ Islands in DATX8
// default value is 1
// If all DATX8 and AC IOs are on the same side of calibration island,
// change this to 0  
`define DWC_DX_NO_OF_VSSQI              0  

// Number of VDDQ islands in DATX8
`define DWC_DX_NO_OF_VDDQI              0  

// number assigned to ZQ of the byte if the byte is configured to include ZQ
// i.e. if byte bit of DWC_DX_ZQ_USE is set; if the byte is not configured to
// include ZQ, then this number specifies the ZQ associated with this byte
// this number determines the ZQ controller and impedance calibration registers
// (ZQnCR and ZQnSR) that are used for this byte
// NOTE: Only one PZQ in either the AC or in one of the DX lanes. 
// NOTE: The recommendation is to separate the DX and AC calibrartion contols. 
// NOTE: The default ZQ is in the AC lane, if configured to be included, and is automatically assigned
//       sequential numbers starting at 0 and therefore in this case DATX8 ZQ numbers must
//       start after AC ZQ numbers  
//       The AC is defined in segment 0 and DX lanes are defined in segment 1
`define DWC_DX0_ZQ_NUM                  1
`define DWC_DX1_ZQ_NUM                  1
`define DWC_DX2_ZQ_NUM                  1
`define DWC_DX3_ZQ_NUM                  1
`define DWC_DX4_ZQ_NUM                  1
`define DWC_DX5_ZQ_NUM                  1
`define DWC_DX6_ZQ_NUM                  1
`define DWC_DX7_ZQ_NUM                  1
`define DWC_DX8_ZQ_NUM                  1

// number assigned to PLL VDD/VSS pair used by data byte lane; this is the
// PLL VDD/VSS pair that the data byte lane PLL is connected to. It also
// specifies the PLL VDD/VSS pair that the PLL VSS/VDD I/Os in the data
// byte lane are connected to if the PLL VDD/VSS I/Os are configured to be 
// included in the lane using DWC_DX_PLL_VDD_USE
// If there are no segments used, then leave these defines
// as 0
`define DWC_DX0_PLL_VDD_NUM             0
`define DWC_DX1_PLL_VDD_NUM             0
`define DWC_DX2_PLL_VDD_NUM             0
`define DWC_DX3_PLL_VDD_NUM             0
`define DWC_DX4_PLL_VDD_NUM             0
`define DWC_DX5_PLL_VDD_NUM             0
`define DWC_DX6_PLL_VDD_NUM             0
`define DWC_DX7_PLL_VDD_NUM             0
`define DWC_DX8_PLL_VDD_NUM             0

// VDDQ island to which the byte VDDQ is connected; 
// Islands in AC are numbered first. For segmented IO rings, unique island
// numbers must be used depending on PEND cell insertion and number of bytes used.
// Note that there maybe multiple VDDQ island numbers
`define DWC_DX0_VDDQ_INUM               1
`define DWC_DX1_VDDQ_INUM               1
`define DWC_DX2_VDDQ_INUM               1
`define DWC_DX3_VDDQ_INUM               1
`define DWC_DX4_VDDQ_INUM               1
`define DWC_DX5_VDDQ_INUM               1
`define DWC_DX6_VDDQ_INUM               1
`define DWC_DX7_VDDQ_INUM               1
`define DWC_DX8_VDDQ_INUM               1

  // ZIOH island to which the byte ZIOH is connected; 
  // Islands in AC are numbered first. For segmented IO rings, unique island
  // numbers must be used depending on PEND cell insertion and number of bytes used.
  `define DWC_DX0_ZIOH_INUM             `DWC_AC_NO_OF_ZIOHI
  `define DWC_DX1_ZIOH_INUM             `DWC_DX0_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX2_ZIOH_INUM             `DWC_DX1_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX3_ZIOH_INUM             `DWC_DX2_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX4_ZIOH_INUM             `DWC_DX3_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX5_ZIOH_INUM             `DWC_DX4_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX6_ZIOH_INUM             `DWC_DX5_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX7_ZIOH_INUM             `DWC_DX6_ZIOH_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX8_ZIOH_INUM             `DWC_DX7_ZIOH_INUM + `DWC_DX_NO_OF_VREF


  // VREF Island number
  // Parameter to control VREF bus index since VREF is cut by IO calibration
  // section.  Choose unique values for IOs on either side of IO calibration cells.
  // Islands in AC are numbered first. For segmented IO rings, unique island
  // numbers must be used depending on PEND cell insertion and number of bytes used.
  `define DWC_DX0_VREF_INUM             `DWC_AC_NO_OF_VREFI
  `define DWC_DX1_VREF_INUM             `DWC_DX0_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX2_VREF_INUM             `DWC_DX1_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX3_VREF_INUM             `DWC_DX2_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX4_VREF_INUM             `DWC_DX3_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX5_VREF_INUM             `DWC_DX4_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX6_VREF_INUM             `DWC_DX5_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX7_VREF_INUM             `DWC_DX6_VREF_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX8_VREF_INUM             `DWC_DX7_VREF_INUM + `DWC_DX_NO_OF_VREF

// Share PDRH18 bus with AC
// Following macro is defined per byte lane
// Low four bits indicate the island of AC which 
// share the PDRH18 bus with the byte lane,
// and in X4 mode, it used for nibble 0.
// High four bits will only enable in x4 mode,
// indicate the island of AC which 
// share the PDRH18 bus with nibble 1.
// Note: high four bits need keep it as 4'b0 in X8 mode.
// eg. In X8 mode, 8'b0000_0001 means DX0 share PDRH18 with AC island 0
//                 8'b0000_0010 means DX0 share PDRH18 with AC island 1
//     In X4 mode, 8'b0000_0001 means nibble 0 of DX0 share PDRH18 with AC island 0
//                 8'b0000_0010 means nibble 0 of DX0 share PDRH18 with AC island 1
//                 8'b0001_0000 means nibble 1 of DX0 share PDRH18 with AC island 0
//                 8'b0010_0000 means nibble 1 of DX0 share PDRH18 with AC island 1
`define DWC_DX0_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX1_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX2_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX3_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX4_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX5_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX6_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX7_AC_PDRH18_SHARE   8'b00000000
`define DWC_DX8_AC_PDRH18_SHARE   8'b00000000

  // PDRH18 Island number
  // Parameter to control PDRH18 bus index since PDRH18 is cut by ZB_ZQ
  // cell. Choose unique values for IOs on either side of ZB_ZQ cell or ZQ/ZCTRL pair,
  // even it is shared the PDRH18 bus with AC.
  // Islands in AC are numbered first. For segmented IO rings, unique island
  // numbers must be used depending on PEND cell insertion, ZB_ZQ inserrtion
  // and number of bytes used.
  `define DWC_DX0_PDRH18_INUM           `DWC_AC_NO_OF_PDRH18I
  `define DWC_DX1_PDRH18_INUM           `DWC_DX0_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX2_PDRH18_INUM           `DWC_DX1_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX3_PDRH18_INUM           `DWC_DX2_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX4_PDRH18_INUM           `DWC_DX3_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX5_PDRH18_INUM           `DWC_DX4_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX6_PDRH18_INUM           `DWC_DX5_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX7_PDRH18_INUM           `DWC_DX6_PDRH18_INUM + `DWC_DX_NO_OF_VREF
  `define DWC_DX8_PDRH18_INUM           `DWC_DX7_PDRH18_INUM + `DWC_DX_NO_OF_VREF

// POCH Island number
// Islands in AC are numbered first. For segmented IO rings, unique island
// numbers must be used depending on PEND cell insertion and number of bytes used.
`define DWC_DX0_POCH_INUM               0
`define DWC_DX1_POCH_INUM               0
`define DWC_DX2_POCH_INUM               0
`define DWC_DX3_POCH_INUM               0
`define DWC_DX4_POCH_INUM               0
`define DWC_DX5_POCH_INUM               0
`define DWC_DX6_POCH_INUM               0
`define DWC_DX7_POCH_INUM               0
`define DWC_DX8_POCH_INUM               0

// VSSQ Island number
// Islands in AC are numbered first. For segmented IO rings, unique island
// numbers must be used depending on PEND cell insertion and number of bytes used.
`define DWC_DX0_VSSQ_INUM               0
`define DWC_DX1_VSSQ_INUM               0
`define DWC_DX2_VSSQ_INUM               0
`define DWC_DX3_VSSQ_INUM               0
`define DWC_DX4_VSSQ_INUM               0
`define DWC_DX5_VSSQ_INUM               0
`define DWC_DX6_VSSQ_INUM               0
`define DWC_DX7_VSSQ_INUM               0
`define DWC_DX8_VSSQ_INUM               0


// Power and I/O Filler Cells
// --------------------------
// Number of power and filler I/O cells for each byte
//  - DWC_NO_OF_V*   : Number of VDD, VSS, VDDQ, VSSQ, ZB, and ZB_ZQ
//  - DWC_NO_OF_F*   : Number of of fill cells

// byte 0
`define DWC_DX0_NO_OF_VSS_CAP           2
`define DWC_DX0_NO_OF_VSS_ESD           1
`define DWC_DX0_NO_OF_VSH_ESD           2
`define DWC_DX0_NO_OF_VSH_CAP           0
`define DWC_DX0_NO_OF_VDD_ESD           2
`define DWC_DX0_NO_OF_VDD_CAP           0
`define DWC_DX0_NO_OF_VDDQ_ESD          5
`define DWC_DX0_NO_OF_VDDQ_CAP          0
`define DWC_DX0_NO_OF_VSSQ              5
`define DWC_DX0_NO_OF_ZB                0
`define DWC_DX0_NO_OF_ZB_ZQ             1
`define DWC_DX0_NO_OF_FILLT1            0
`define DWC_DX0_NO_OF_FILLT2            0
`define DWC_DX0_NO_OF_FILLT3            0
`define DWC_DX0_NO_OF_FILLT4            0
`define DWC_DX0_NO_OF_FILLISOT1         0
`define DWC_DX0_NO_OF_FILLISOT2         0
// following macros are defined per byte lane
// this will enable, in x4 mode,
// specify the number of FILLISOT1/2 placed in nibble 0, 
// the number of FILLISOT1/2 placed in nibble 1 is 
// (DWC_DXn_NO_OF_FILLT1/2 - DWC_DXn_NIB0_NO_OF_FILLISOT1/2).
// This is to help placing the FILLISOT1/2 cell in which nibble,
// in x4 mode when there is only one FILLISOT1/2 cell.
`define DWC_DX0_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX0_NIB0_NO_OF_FILLISOT2    0
// following macros are defined per byte lane
// this will enable, when set to non-zero, in x4 mode
// for more filler/power cells to be added 
// to either nibble 0 or nibble 1. This is to help avoid
// PLL/macro overlap with other bytes
`define DWC_DX0_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX0_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX0_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 1  
`define DWC_DX1_NO_OF_VSS_CAP           2
`define DWC_DX1_NO_OF_VSS_ESD           1
`define DWC_DX1_NO_OF_VSH_ESD           2
`define DWC_DX1_NO_OF_VSH_CAP           0
`define DWC_DX1_NO_OF_VDD_ESD           2
`define DWC_DX1_NO_OF_VDD_CAP           0
`define DWC_DX1_NO_OF_VDDQ_ESD          5
`define DWC_DX1_NO_OF_VDDQ_CAP          0
`define DWC_DX1_NO_OF_VSSQ              5
`define DWC_DX1_NO_OF_ZB                0
`define DWC_DX1_NO_OF_ZB_ZQ             1
`define DWC_DX1_NO_OF_FILLT1            0
`define DWC_DX1_NO_OF_FILLT2            0
`define DWC_DX1_NO_OF_FILLT3            0
`define DWC_DX1_NO_OF_FILLT4            0
`define DWC_DX1_NO_OF_FILLISOT1         0
`define DWC_DX1_NO_OF_FILLISOT2         0
`define DWC_DX1_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX1_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX1_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX1_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX1_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 2  
`define DWC_DX2_NO_OF_VSS_CAP           2
`define DWC_DX2_NO_OF_VSS_ESD           1
`define DWC_DX2_NO_OF_VSH_ESD           2
`define DWC_DX2_NO_OF_VSH_CAP           0
`define DWC_DX2_NO_OF_VDD_ESD           2
`define DWC_DX2_NO_OF_VDD_CAP           0
`define DWC_DX2_NO_OF_VDDQ_ESD          5
`define DWC_DX2_NO_OF_VDDQ_CAP          0
`define DWC_DX2_NO_OF_VSSQ              5
`define DWC_DX2_NO_OF_ZB                0
`define DWC_DX2_NO_OF_ZB_ZQ             1
`define DWC_DX2_NO_OF_FILLT1            0
`define DWC_DX2_NO_OF_FILLT2            0
`define DWC_DX2_NO_OF_FILLT3            0
`define DWC_DX2_NO_OF_FILLT4            0
`define DWC_DX2_NO_OF_FILLISOT1         0
`define DWC_DX2_NO_OF_FILLISOT2         0
`define DWC_DX2_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX2_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX2_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX2_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX2_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 3  
`define DWC_DX3_NO_OF_VSS_CAP           2
`define DWC_DX3_NO_OF_VSS_ESD           1
`define DWC_DX3_NO_OF_VSH_ESD           2
`define DWC_DX3_NO_OF_VSH_CAP           0
`define DWC_DX3_NO_OF_VDD_ESD           2
`define DWC_DX3_NO_OF_VDD_CAP           0
`define DWC_DX3_NO_OF_VDDQ_ESD          5
`define DWC_DX3_NO_OF_VDDQ_CAP          0
`define DWC_DX3_NO_OF_VSSQ              5
`define DWC_DX3_NO_OF_ZB                0
`define DWC_DX3_NO_OF_ZB_ZQ             1
`define DWC_DX3_NO_OF_FILLT1            0
`define DWC_DX3_NO_OF_FILLT2            0
`define DWC_DX3_NO_OF_FILLT3            0
`define DWC_DX3_NO_OF_FILLT4            0
`define DWC_DX3_NO_OF_FILLISOT1         0
`define DWC_DX3_NO_OF_FILLISOT2         0
`define DWC_DX3_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX3_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX3_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX3_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX3_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 4  
`define DWC_DX4_NO_OF_VSS_CAP           2
`define DWC_DX4_NO_OF_VSS_ESD           1
`define DWC_DX4_NO_OF_VSH_ESD           2
`define DWC_DX4_NO_OF_VSH_CAP           0
`define DWC_DX4_NO_OF_VDD_ESD           2
`define DWC_DX4_NO_OF_VDD_CAP           0
`define DWC_DX4_NO_OF_VDDQ_ESD          5
`define DWC_DX4_NO_OF_VDDQ_CAP          0
`define DWC_DX4_NO_OF_VSSQ              5
`define DWC_DX4_NO_OF_ZB                0
`define DWC_DX4_NO_OF_ZB_ZQ             1
`define DWC_DX4_NO_OF_FILLT1            0
`define DWC_DX4_NO_OF_FILLT2            0
`define DWC_DX4_NO_OF_FILLT3            0
`define DWC_DX4_NO_OF_FILLT4            0
`define DWC_DX4_NO_OF_FILLISOT1         0
`define DWC_DX4_NO_OF_FILLISOT2         0
`define DWC_DX4_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX4_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX4_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX4_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX4_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 5  
`define DWC_DX5_NO_OF_VSS_CAP           2
`define DWC_DX5_NO_OF_VSS_ESD           1
`define DWC_DX5_NO_OF_VSH_ESD           2
`define DWC_DX5_NO_OF_VSH_CAP           0
`define DWC_DX5_NO_OF_VDD_ESD           2
`define DWC_DX5_NO_OF_VDD_CAP           0
`define DWC_DX5_NO_OF_VDDQ_ESD          5
`define DWC_DX5_NO_OF_VDDQ_CAP          0
`define DWC_DX5_NO_OF_VSSQ              5
`define DWC_DX5_NO_OF_ZB                0
`define DWC_DX5_NO_OF_ZB_ZQ             1
`define DWC_DX5_NO_OF_FILLT1            0
`define DWC_DX5_NO_OF_FILLT2            0
`define DWC_DX5_NO_OF_FILLT3            0
`define DWC_DX5_NO_OF_FILLT4            0
`define DWC_DX5_NO_OF_FILLISOT1         0
`define DWC_DX5_NO_OF_FILLISOT2         0
`define DWC_DX5_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX5_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX5_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX5_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX5_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 6  
`define DWC_DX6_NO_OF_VSS_CAP           2
`define DWC_DX6_NO_OF_VSS_ESD           1
`define DWC_DX6_NO_OF_VSH_ESD           2
`define DWC_DX6_NO_OF_VSH_CAP           0
`define DWC_DX6_NO_OF_VDD_ESD           2
`define DWC_DX6_NO_OF_VDD_CAP           0
`define DWC_DX6_NO_OF_VDDQ_ESD          5
`define DWC_DX6_NO_OF_VDDQ_CAP          0
`define DWC_DX6_NO_OF_VSSQ              5
`define DWC_DX6_NO_OF_ZB                0
`define DWC_DX6_NO_OF_ZB_ZQ             1
`define DWC_DX6_NO_OF_FILLT1            0
`define DWC_DX6_NO_OF_FILLT2            0
`define DWC_DX6_NO_OF_FILLT3            0
`define DWC_DX6_NO_OF_FILLT4            0
`define DWC_DX6_NO_OF_FILLISOT1         0
`define DWC_DX6_NO_OF_FILLISOT2         0
`define DWC_DX6_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX6_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX6_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX6_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX6_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 7  
`define DWC_DX7_NO_OF_VSS_CAP           2
`define DWC_DX7_NO_OF_VSS_ESD           1
`define DWC_DX7_NO_OF_VSH_ESD           2
`define DWC_DX7_NO_OF_VSH_CAP           0
`define DWC_DX7_NO_OF_VDD_ESD           2
`define DWC_DX7_NO_OF_VDD_CAP           0
`define DWC_DX7_NO_OF_VDDQ_ESD          5
`define DWC_DX7_NO_OF_VDDQ_CAP          0
`define DWC_DX7_NO_OF_VSSQ              5
`define DWC_DX7_NO_OF_ZB                0
`define DWC_DX7_NO_OF_ZB_ZQ             1
`define DWC_DX7_NO_OF_FILLT1            0
`define DWC_DX7_NO_OF_FILLT2            0
`define DWC_DX7_NO_OF_FILLT3            0
`define DWC_DX7_NO_OF_FILLT4            0
`define DWC_DX7_NO_OF_FILLISOT1         0
`define DWC_DX7_NO_OF_FILLISOT2         0
`define DWC_DX7_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX7_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX7_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX7_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX7_NIB1_NO_OF_EXTRA_VSS_CAP 0
  
// byte 8  
`define DWC_DX8_NO_OF_VSS_CAP           2
`define DWC_DX8_NO_OF_VSS_ESD           1
`define DWC_DX8_NO_OF_VSH_ESD           2
`define DWC_DX8_NO_OF_VSH_CAP           0
`define DWC_DX8_NO_OF_VDD_ESD           2
`define DWC_DX8_NO_OF_VDD_CAP           0
`define DWC_DX8_NO_OF_VDDQ_ESD          5
`define DWC_DX8_NO_OF_VDDQ_CAP          0
`define DWC_DX8_NO_OF_VSSQ              5
`define DWC_DX8_NO_OF_ZB                0
`define DWC_DX8_NO_OF_ZB_ZQ             1
`define DWC_DX8_NO_OF_FILLT1            0
`define DWC_DX8_NO_OF_FILLT2            0
`define DWC_DX8_NO_OF_FILLT3            0
`define DWC_DX8_NO_OF_FILLT4            0
`define DWC_DX8_NO_OF_FILLISOT1         0
`define DWC_DX8_NO_OF_FILLISOT2         0
`define DWC_DX8_NIB0_NO_OF_FILLISOT1    0
`define DWC_DX8_NIB0_NO_OF_FILLISOT2    0
`define DWC_DX8_NIB0_NO_OF_EXTRA_FILLT1 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_FILLT1 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_FILLT2 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_FILLT2 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_FILLT3 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_FILLT3 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_FILLT4 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_FILLT4 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VDDQ_ESD 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VDDQ_CAP 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VSSQ 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VSSQ 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VDD_ESD 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VDD_CAP 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VSH_ESD 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VSH_CAP 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VSS_ESD 0
`define DWC_DX8_NIB0_NO_OF_EXTRA_VSS_CAP 0
`define DWC_DX8_NIB1_NO_OF_EXTRA_VSS_CAP 0


// Bond Pad Type
// -------------
// these settings are valid only if DWC_PPAD_USE is set to 1 (i.e. bond pads 
// are to be instantiated): specifies whether an outer or inner bond pad cell
// is used for the I/O, a value of 1 means outer bond pad and value of 0 means
// inner bond band; for multi-bit signals, each bit controls the bond pad type
// for the corresponding signal bit; default for signal I/Os is inner bond pad
// NOTE: ZZB_PPADO specifies which of the two ZB cells used for
//       breaking the PZQ ZIOH bus should use an outer or innner bond pad
// byte 0
`define DWC_DX0_DQS_PPADO               2'b00
`define DWC_DX0_DQS_N_PPADO             2'b00
`define DWC_DX0_DM_PPADO                2'b00
`define DWC_DX0_DQ_PPADO                8'h00
`define DWC_DX0_DQSG_PPADO              2'b00
`define DWC_DX0_DQSR_PPADO              2'b00
`define DWC_DX0_DTO_PPADO               2'b00
`define DWC_DX0_ATO_PPADO               1'b0
`define DWC_DX0_RET_PPADO               1'b0   
`define DWC_DX0_ZZB_PPADO               2'b00   

// byte 1
`define DWC_DX1_DQS_PPADO               2'b00
`define DWC_DX1_DQS_N_PPADO             2'b00
`define DWC_DX1_DM_PPADO                2'b00
`define DWC_DX1_DQ_PPADO                8'h00
`define DWC_DX1_DQSG_PPADO              2'b00
`define DWC_DX1_DQSR_PPADO              2'b00
`define DWC_DX1_DTO_PPADO               2'b00
`define DWC_DX1_ATO_PPADO               1'b0
`define DWC_DX1_RET_PPADO               1'b0   
`define DWC_DX1_ZZB_PPADO               2'b00   

// byte 2
`define DWC_DX2_DQS_PPADO               2'b00
`define DWC_DX2_DQS_N_PPADO             2'b00
`define DWC_DX2_DM_PPADO                2'b00
`define DWC_DX2_DQ_PPADO                8'h00
`define DWC_DX2_DQSG_PPADO              2'b00
`define DWC_DX2_DQSR_PPADO              2'b00
`define DWC_DX2_DTO_PPADO               2'b00
`define DWC_DX2_ATO_PPADO               1'b0
`define DWC_DX2_RET_PPADO               1'b0   
`define DWC_DX2_ZZB_PPADO               2'b00   

// byte 3
`define DWC_DX3_DQS_PPADO               2'b00
`define DWC_DX3_DQS_N_PPADO             2'b00
`define DWC_DX3_DM_PPADO                2'b00
`define DWC_DX3_DQ_PPADO                8'h00
`define DWC_DX3_DQSG_PPADO              2'b00
`define DWC_DX3_DQSR_PPADO              2'b00
`define DWC_DX3_DTO_PPADO               2'b00
`define DWC_DX3_ATO_PPADO               1'b0
`define DWC_DX3_RET_PPADO               1'b0   
`define DWC_DX3_ZZB_PPADO               2'b00   

// byte 4
`define DWC_DX4_DQS_PPADO               2'b00
`define DWC_DX4_DQS_N_PPADO             2'b00
`define DWC_DX4_DM_PPADO                2'b00
`define DWC_DX4_DQ_PPADO                8'h00
`define DWC_DX4_DQSG_PPADO              2'b00
`define DWC_DX4_DQSR_PPADO              2'b00
`define DWC_DX4_DTO_PPADO               2'b00
`define DWC_DX4_ATO_PPADO               1'b0
`define DWC_DX4_RET_PPADO               1'b0   
`define DWC_DX4_ZZB_PPADO               2'b00   

// byte 5
`define DWC_DX5_DQS_PPADO               2'b00
`define DWC_DX5_DQS_N_PPADO             2'b00
`define DWC_DX5_DM_PPADO                2'b00
`define DWC_DX5_DQ_PPADO                8'h00
`define DWC_DX5_DQSG_PPADO              2'b00
`define DWC_DX5_DQSR_PPADO              2'b00
`define DWC_DX5_DTO_PPADO               2'b00
`define DWC_DX5_ATO_PPADO               1'b0
`define DWC_DX5_RET_PPADO               1'b0   
`define DWC_DX5_ZZB_PPADO               2'b00   

// byte 6
`define DWC_DX6_DQS_PPADO               2'b00
`define DWC_DX6_DQS_N_PPADO             2'b00
`define DWC_DX6_DM_PPADO                2'b00
`define DWC_DX6_DQ_PPADO                8'h00
`define DWC_DX6_DQSG_PPADO              2'b00
`define DWC_DX6_DQSR_PPADO              2'b00
`define DWC_DX6_DTO_PPADO               2'b00
`define DWC_DX6_ATO_PPADO               1'b0
`define DWC_DX6_RET_PPADO               1'b0   
`define DWC_DX6_ZZB_PPADO               2'b00   

// byte 7
`define DWC_DX7_DQS_PPADO               2'b00
`define DWC_DX7_DQS_N_PPADO             2'b00
`define DWC_DX7_DM_PPADO                2'b00
`define DWC_DX7_DQ_PPADO                8'h00
`define DWC_DX7_DQSG_PPADO              2'b00
`define DWC_DX7_DQSR_PPADO              2'b00
`define DWC_DX7_DTO_PPADO               2'b00
`define DWC_DX7_ATO_PPADO               1'b0
`define DWC_DX7_RET_PPADO               1'b0   
`define DWC_DX7_ZZB_PPADO               2'b00   

// byte 8
`define DWC_DX8_DQS_PPADO               2'b00
`define DWC_DX8_DQS_N_PPADO             2'b00
`define DWC_DX8_DM_PPADO                2'b00
`define DWC_DX8_DQ_PPADO                8'h00
`define DWC_DX8_DQSG_PPADO              2'b00
`define DWC_DX8_DQSR_PPADO              2'b00
`define DWC_DX8_DTO_PPADO               2'b00
`define DWC_DX8_ATO_PPADO               1'b0
`define DWC_DX8_RET_PPADO               1'b0   
`define DWC_DX8_ZZB_PPADO               2'b00   

// these settings are valid only if DWC_PPAD_USE is set to 1 (i.e. bond pads 
// are to be instantiated): specifies how many non-signal (power, etc) I/Os
// use outer or inner bond pad cells, a value of 1 means inner bond pad and value 
// of 0 means outer bond band; default for non-signal I/O is outer bond pad
// byte 0
`define DWC_DX0_NO_OF_ZQ_PPADI          0
`define DWC_DX0_NO_OF_ZCTRL_PPADI       0
`define DWC_DX0_NO_OF_VREF_PPADI        0
`define DWC_DX0_NO_OF_VREFE_PPADI       0
`define DWC_DX0_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX0_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX0_NO_OF_VSS_PPADI         0
`define DWC_DX0_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX0_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX0_NO_OF_VSSQ_PPADI        0
`define DWC_DX0_NO_OF_ZB_PPADI          0
`define DWC_DX0_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX0_NO_OF_PLL_VDD_PPADI     0

// byte 1
`define DWC_DX1_NO_OF_ZQ_PPADI          0
`define DWC_DX1_NO_OF_ZCTRL_PPADI       0
`define DWC_DX1_NO_OF_VREF_PPADI        0
`define DWC_DX1_NO_OF_VREFE_PPADI       0
`define DWC_DX1_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX1_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX1_NO_OF_VSS_PPADI         0
`define DWC_DX1_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX1_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX1_NO_OF_VSSQ_PPADI        0
`define DWC_DX1_NO_OF_ZB_PPADI          0
`define DWC_DX1_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX1_NO_OF_PLL_VDD_PPADI     0

// byte 2
`define DWC_DX2_NO_OF_ZQ_PPADI          0
`define DWC_DX2_NO_OF_ZCTRL_PPADI       0
`define DWC_DX2_NO_OF_VREF_PPADI        0
`define DWC_DX2_NO_OF_VREFE_PPADI       0
`define DWC_DX2_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX2_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX2_NO_OF_VSS_PPADI         0
`define DWC_DX2_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX2_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX2_NO_OF_VSSQ_PPADI        0
`define DWC_DX2_NO_OF_ZB_PPADI          0
`define DWC_DX2_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX2_NO_OF_PLL_VDD_PPADI     0

// byte 3
`define DWC_DX3_NO_OF_ZQ_PPADI          0
`define DWC_DX3_NO_OF_ZCTRL_PPADI       0
`define DWC_DX3_NO_OF_VREF_PPADI        0
`define DWC_DX3_NO_OF_VREFE_PPADI       0
`define DWC_DX3_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX3_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX3_NO_OF_VSS_PPADI         0
`define DWC_DX3_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX3_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX3_NO_OF_VSSQ_PPADI        0
`define DWC_DX3_NO_OF_ZB_PPADI          0
`define DWC_DX3_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX3_NO_OF_PLL_VDD_PPADI     0

// byte 4
`define DWC_DX4_NO_OF_ZQ_PPADI          0
`define DWC_DX4_NO_OF_ZCTRL_PPADI       0
`define DWC_DX4_NO_OF_VREF_PPADI        0
`define DWC_DX4_NO_OF_VREFE_PPADI       0
`define DWC_DX4_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX4_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX4_NO_OF_VSS_PPADI         0
`define DWC_DX4_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX4_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX4_NO_OF_VSSQ_PPADI        0
`define DWC_DX4_NO_OF_ZB_PPADI          0
`define DWC_DX4_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX4_NO_OF_PLL_VDD_PPADI     0

// byte 5
`define DWC_DX5_NO_OF_ZQ_PPADI          0
`define DWC_DX5_NO_OF_ZCTRL_PPADI       0
`define DWC_DX5_NO_OF_VREF_PPADI        0
`define DWC_DX5_NO_OF_VREFE_PPADI       0
`define DWC_DX5_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX5_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX5_NO_OF_VSS_PPADI         0
`define DWC_DX5_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX5_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX5_NO_OF_VSSQ_PPADI        0
`define DWC_DX5_NO_OF_ZB_PPADI          0
`define DWC_DX5_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX5_NO_OF_PLL_VDD_PPADI     0

// byte 6
`define DWC_DX6_NO_OF_ZQ_PPADI          0
`define DWC_DX6_NO_OF_ZCTRL_PPADI       0
`define DWC_DX6_NO_OF_VREF_PPADI        0
`define DWC_DX6_NO_OF_VREFE_PPADI       0
`define DWC_DX6_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX6_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX6_NO_OF_VSS_PPADI         0
`define DWC_DX6_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX6_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX6_NO_OF_VSSQ_PPADI        0
`define DWC_DX6_NO_OF_ZB_PPADI          0
`define DWC_DX6_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX6_NO_OF_PLL_VDD_PPADI     0

// byte 7
`define DWC_DX7_NO_OF_ZQ_PPADI          0
`define DWC_DX7_NO_OF_ZCTRL_PPADI       0
`define DWC_DX7_NO_OF_VREF_PPADI        0
`define DWC_DX7_NO_OF_VREFE_PPADI       0
`define DWC_DX7_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX7_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX7_NO_OF_VSS_PPADI         0
`define DWC_DX7_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX7_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX7_NO_OF_VSSQ_PPADI        0
`define DWC_DX7_NO_OF_ZB_PPADI          0
`define DWC_DX7_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX7_NO_OF_PLL_VDD_PPADI     0

// byte 8
`define DWC_DX8_NO_OF_ZQ_PPADI          0
`define DWC_DX8_NO_OF_ZCTRL_PPADI       0
`define DWC_DX8_NO_OF_VREF_PPADI        0
`define DWC_DX8_NO_OF_VREFE_PPADI       0
`define DWC_DX8_NO_OF_VDD_ESD_PPADI     0
`define DWC_DX8_NO_OF_VDD_CAP_PPADI     0
`define DWC_DX8_NO_OF_VSS_PPADI         0
`define DWC_DX8_NO_OF_VDDQ_ESD_PPADI    0
`define DWC_DX8_NO_OF_VDDQ_CAP_PPADI    0
`define DWC_DX8_NO_OF_VSSQ_PPADI        0
`define DWC_DX8_NO_OF_ZB_PPADI          0
`define DWC_DX8_NO_OF_ZB_ZQ_PPADI       0
`define DWC_DX8_NO_OF_PLL_VDD_PPADI     0


// Byte Lane Pin Maping
// --------------------
// Specifies the mapping of the byte lane DQ/DM pins to the DQ slices in
// the DATX8 macro
// NOTE: DM1 is valid only when using DATX4X2 macro
// byte 0
`define DWC_DX0_DQ0_PNUM                0
`define DWC_DX0_DQ1_PNUM                1
`define DWC_DX0_DQ2_PNUM                2
`define DWC_DX0_DQ3_PNUM                3
`define DWC_DX0_DQ4_PNUM                4
`define DWC_DX0_DQ5_PNUM                5
`define DWC_DX0_DQ6_PNUM                6
`define DWC_DX0_DQ7_PNUM                7
`define DWC_DX0_DM0_PNUM                8
`define DWC_DX0_DM1_PNUM                9

// byte 1
`define DWC_DX1_DQ0_PNUM                0
`define DWC_DX1_DQ1_PNUM                1
`define DWC_DX1_DQ2_PNUM                2
`define DWC_DX1_DQ3_PNUM                3
`define DWC_DX1_DQ4_PNUM                4
`define DWC_DX1_DQ5_PNUM                5
`define DWC_DX1_DQ6_PNUM                6
`define DWC_DX1_DQ7_PNUM                7
`define DWC_DX1_DM0_PNUM                8
`define DWC_DX1_DM1_PNUM                9

// byte 2
`define DWC_DX2_DQ0_PNUM                0
`define DWC_DX2_DQ1_PNUM                1
`define DWC_DX2_DQ2_PNUM                2
`define DWC_DX2_DQ3_PNUM                3
`define DWC_DX2_DQ4_PNUM                4
`define DWC_DX2_DQ5_PNUM                5
`define DWC_DX2_DQ6_PNUM                6
`define DWC_DX2_DQ7_PNUM                7
`define DWC_DX2_DM0_PNUM                8
`define DWC_DX2_DM1_PNUM                9

// byte 3
`define DWC_DX3_DQ0_PNUM                0
`define DWC_DX3_DQ1_PNUM                1
`define DWC_DX3_DQ2_PNUM                2
`define DWC_DX3_DQ3_PNUM                3
`define DWC_DX3_DQ4_PNUM                4
`define DWC_DX3_DQ5_PNUM                5
`define DWC_DX3_DQ6_PNUM                6
`define DWC_DX3_DQ7_PNUM                7
`define DWC_DX3_DM0_PNUM                8
`define DWC_DX3_DM1_PNUM                9

// byte 4
`define DWC_DX4_DQ0_PNUM                0
`define DWC_DX4_DQ1_PNUM                1
`define DWC_DX4_DQ2_PNUM                2
`define DWC_DX4_DQ3_PNUM                3
`define DWC_DX4_DQ4_PNUM                4
`define DWC_DX4_DQ5_PNUM                5
`define DWC_DX4_DQ6_PNUM                6
`define DWC_DX4_DQ7_PNUM                7
`define DWC_DX4_DM0_PNUM                8
`define DWC_DX4_DM1_PNUM                9

// byte 5
`define DWC_DX5_DQ0_PNUM                0
`define DWC_DX5_DQ1_PNUM                1
`define DWC_DX5_DQ2_PNUM                2
`define DWC_DX5_DQ3_PNUM                3
`define DWC_DX5_DQ4_PNUM                4
`define DWC_DX5_DQ5_PNUM                5
`define DWC_DX5_DQ6_PNUM                6
`define DWC_DX5_DQ7_PNUM                7
`define DWC_DX5_DM0_PNUM                8
`define DWC_DX5_DM1_PNUM                9

// byte 6
`define DWC_DX6_DQ0_PNUM                0
`define DWC_DX6_DQ1_PNUM                1
`define DWC_DX6_DQ2_PNUM                2
`define DWC_DX6_DQ3_PNUM                3
`define DWC_DX6_DQ4_PNUM                4
`define DWC_DX6_DQ5_PNUM                5
`define DWC_DX6_DQ6_PNUM                6
`define DWC_DX6_DQ7_PNUM                7
`define DWC_DX6_DM0_PNUM                8
`define DWC_DX6_DM1_PNUM                9

// byte 7
`define DWC_DX7_DQ0_PNUM                0
`define DWC_DX7_DQ1_PNUM                1
`define DWC_DX7_DQ2_PNUM                2
`define DWC_DX7_DQ3_PNUM                3
`define DWC_DX7_DQ4_PNUM                4
`define DWC_DX7_DQ5_PNUM                5
`define DWC_DX7_DQ6_PNUM                6
`define DWC_DX7_DQ7_PNUM                7
`define DWC_DX7_DM0_PNUM                8
`define DWC_DX7_DM1_PNUM                9

// byte 8
`define DWC_DX8_DQ0_PNUM                0
`define DWC_DX8_DQ1_PNUM                1
`define DWC_DX8_DQ2_PNUM                2
`define DWC_DX8_DQ3_PNUM                3
`define DWC_DX8_DQ4_PNUM                4
`define DWC_DX8_DQ5_PNUM                5
`define DWC_DX8_DQ6_PNUM                6
`define DWC_DX8_DQ7_PNUM                7
`define DWC_DX8_DM0_PNUM                8
`define DWC_DX8_DM1_PNUM                9


// *** DO NOT EDIT THE INFORMATION BELOW THIS LINE ***

//-----------------------------------------------------------------------------
// DDR System General Configurations
//-----------------------------------------------------------------------------
`define DWC_NO_OF_ZQ            1      // number of ZQ pins and/or ZQ calibration controllers 
                                       // must be 1 always
                                       
// specifies if DQS Gate cell should be used 
`define DWC_DX_PDQSG_USE                  // use DQS gate I/O cell

// widths of special mode signals
`define DWC_SMODE_WIDTH         16
`define DWC_STATUS_WIDTH        16

//-----------------------------------------------------------------------------
// SDR MODE HOLD DELAY
//-----------------------------------------------------------------------------
// In SDR mode the file DWC_ddrphy_ctlcfg.v the clock crossings between the 
// synchronous clocks ctl_sdr_clk and pub_ctl_clk have a 2:1 frequency ratio.
// To workaround RTL simulation timing at the clock crossings a hold delay is
// defined and set to a default value of 10ps.
`define DWC_SDR_HOLD_DLY 0.010

// define number of cells of each type needed in ZQ calibration island
// these cells will connect to the VREF_ZQ and ZIOH_ZQ buses of the
// calibration island 
`ifndef DWC_DDRPHY_NO_PZQ 
  `define DWC_NO_OF_FILLT1_ZQ           0
  `define DWC_NO_OF_FILLT2_ZQ           0
  `define DWC_NO_OF_FILLT3_ZQ           0
  `define DWC_NO_OF_FILLT4_ZQ           0
  `define DWC_NO_OF_FILLISOT1_ZQ        0
  `define DWC_NO_OF_FILLISOT2_ZQ        0
  `define DWC_NO_OF_VDDQ_ESD_ZQ         0
  `define DWC_NO_OF_VDDQ_CAP_ZQ         0
  `define DWC_NO_OF_VSSQ_ZQ             0
  `define DWC_NO_OF_VDD_CAP_ZQ          0
  `define DWC_NO_OF_VDD_ESD_ZQ          0
  `define DWC_NO_OF_VSS_ZQ              0
`endif

//-----------------------------------------------------------------------------
// Cell Library Details
//-----------------------------------------------------------------------------
// Details of different cell libraries

// D4MV2V5 is a special version of D4MV IO and has restricted availability and
// has the following characteristics
//   - Has _EW IO versions only
//   - Does not have PCKE cell
//   - Does not haveMVAA_PLL and PDRH18 pins on IOs
//   - Has MVSH pin
`ifdef  DWC_DDRPHY_D4MV2V5_IO
  `ifndef DWC_DDRPHY_D4MV_IO
    `define DWC_DDRPHY_D4MV_IO
  `endif

   // use EW cells
  `ifndef DWC_AC_EW_USE
    `define DWC_AC_EW_USE
  `endif

  `undef DWC_DX_EW_USE
  `define DWC_DX_EW_USE   9'h1FF // use EW cells

   // don't use PCKE cell
  `ifdef DWC_AC_PCKE_USE
    `undef DWC_AC_PCKE_USE
  `endif
`endif

// Special library functionality
// -----------------------------
// some cells or functionality is only available in some libraries
// DWC_DDRPHY_* : Defined if this cell is avalibale
// *_CONNECT     : Defines how the cell pin is connected (if not
//                 available the define is blank)

// D4M
`ifdef  DWC_DDRPHY_D4M_IO
  `define DWC_VREF_WIDTH               1
  `define DWC_ZCTRL_WIDTH              28
  `define DWC_ZIOH_WIDTH               72

  `define DWC_VAA_PLL_CONNECT          `DWC_PLL_VDD_VAA_PLL_CONNECT
  `define DWC_VREFISEL_CONNECT         .REFSEL   ( io_vrefi_sel[5:0]  ),
  `define DWC_RK_CONNECT               
  `define DWC_VRMON_CONNECT            
  `define DWC_VREFIEN_CONNECT_DAC      
  `define DWC_VREFISEL_CONNECT_DAC     
  `define DWC_ZVREFSE_VREF_ZQ_CONNECT  
  `define DWC_DnX_VSSQ_CONNECT         .MVSSQ    ( VSSQ    ),
  `define DWC_DnX_VAA_PLL_CONNECT      .MVAA_PLL ( pll_vdd ),

  `define DWC_DQS_PDRH18_CONNECT       , .PDRH18 ( PDRH18[dwc_gdqs]  )
  `define DWC_DQ_PDRH18_CONNECT        , .PDRH18 ( PDRH18[`DWC_DX_DQ_VREF_INUM ]  )
  `define DWC_DTO_PDRH18_CONNECT       , .PDRH18 ( PDRH18[0]  )
  `define DWC_DAC_PDRH18_CONNECT       , .PDRH18 ( PDRH18[dwc_gvref_dac]  )
  `define DWC_PVREF_PDRH18_CONNECT     , .PDRH18 ( PDRH18[dwc_gvref]  )
  `define DWC_PDRH18_CONNECT           , .PDRH18 ( PDRH18[0]         )
  `define DWC_VDD_ESD_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VDD_ESD_VREF_INUM] )
  `define DWC_VDD_CAP_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VDD_CAP_VREF_INUM] )
  `define DWC_VSS_CAP_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VSS_CAP_VREF_INUM] )
  `define DWC_VSS_ESD_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VSS_ESD_VREF_INUM] )
  `define DWC_VDDQ_ESD_PDRH18_CONNECT  , .PDRH18 ( PDRH18 [`DWC_DX_VDDQ_ESD_VREF_INUM] )
  `define DWC_VDDQ_CAP_PDRH18_CONNECT  , .PDRH18 ( PDRH18 [`DWC_DX_VDDQ_CAP_VREF_INUM] )
  `define DWC_VSSQ_PDRH18_CONNECT      , .PDRH18 ( PDRH18 [`DWC_DX_VSSQ_VREF_INUM] )
  `define DWC_ZB_PDRH18_CONNECT        , .PDRH18 ( PDRH18 [`DWC_DX_ZB_VREF_INUM] )
  `define DWC_FILLT1_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT1_VREF_INUM] )
  `define DWC_FILLT2_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT2_VREF_INUM] )
  `define DWC_FILLT3_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT3_VREF_INUM] )
  `define DWC_FILLT4_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT4_VREF_INUM] )
  `define DWC_FILLISOT1_PDRH18_CONNECT , .PDRH18 ( PDRH18 [`DWC_DX_FILLISOT1_VREF_INUM] )
  `define DWC_FILLISOT2_PDRH18_CONNECT , .PDRH18 ( PDRH18 [`DWC_DX_FILLISOT2_VREF_INUM] )

  `define DWC_RK_CONNECT              
  `define DWC_DQS_DID_CONNECT    
  `define DWC_DQSN_DID_CONNECT
  `define DWC_DQS_RK_CONNECT

  // these defines are not valid for this library; they may have been
  // set to a valid value for the defaults above - reset them to 0
  `undef  DWC_DX_VREF_DAC_USE

  `define DWC_DX_VREF_DAC_USE          9'h000
`endif

// D4MV
`ifdef  DWC_DDRPHY_D4MV_IO
  `define DWC_VREF_WIDTH               4
  `define DWC_ZCTRL_WIDTH              28
  `define DWC_ZIOH_WIDTH               72

  `ifdef  DWC_DDRPHY_D4MV2V5_IO
    `define DWC_VAA_PLL_CONNECT         
  `else
    `define DWC_VAA_PLL_CONNECT        `DWC_PLL_VDD_VAA_PLL_CONNECT
  `endif
  `define DWC_VREFISEL_CONNECT         .REFSEL   ( io_vrefi_sel[24*dwc_gvref+5:24*dwc_gvref]  ),
  `define DWC_RK_CONNECT               .RK       ( io_vrefi_rnk  ),
  `define DWC_VRMON_CONNECT            .VRMON    ( io_vrefi_mon  ),
  `define DWC_VREFIEN_CONNECT_DAC      .REFEN    ( io_vrefi_en[3:1]   ),
  `define DWC_VREFISEL_CONNECT_DAC     .REFSEL   ( io_vrefi_sel[24*(dwc_gvref_dac+1)-1:24*dwc_gvref_dac+6] ),
  `define DWC_ZVREFSE_VREF_ZQ_CONNECT  .MVREFSE_ZQ ( VREFSE_ZQ  ),
  `define DWC_DnX_VAA_PLL_CONNECT      .MVAA_PLL ( pll_vdd ),

  `ifdef  DWC_DDRPHY_D4MV2V5_IO
    `define DWC_DnX_VSSQ_CONNECT
    `define DWC_DQS_PDRH18_CONNECT       
    `define DWC_DQ_PDRH18_CONNECT        
    `define DWC_DTO_PDRH18_CONNECT       
    `define DWC_DAC_PDRH18_CONNECT       
    `define DWC_PVREF_PDRH18_CONNECT     
    `define DWC_PDRH18_CONNECT           
    `define DWC_VDD_ESD_PDRH18_CONNECT   
    `define DWC_VDD_CAP_PDRH18_CONNECT   
    `define DWC_VSH_ESD_PDRH18_CONNECT   
    `define DWC_VSH_CAP_PDRH18_CONNECT   
    `define DWC_VSS_CAP_PDRH18_CONNECT   
    `define DWC_VSS_ESD_PDRH18_CONNECT   
    `define DWC_VDDQ_ESD_PDRH18_CONNECT  
    `define DWC_VDDQ_CAP_PDRH18_CONNECT  
    `define DWC_VSSQ_PDRH18_CONNECT      
    `define DWC_ZB_PDRH18_CONNECT     
    `define DWC_FILLT1_PDRH18_CONNECT    
    `define DWC_FILLT2_PDRH18_CONNECT    
    `define DWC_FILLT3_PDRH18_CONNECT     
    `define DWC_FILLT4_PDRH18_CONNECT     
    `define DWC_FILLISOT1_PDRH18_CONNECT 
    `define DWC_FILLISOT2_PDRH18_CONNECT 

    // these defines are not valid for this library; they may have been
    // set to a valid value for the defaults above - reset them to 0
    `undef  DWC_AC_I0_NO_OF_VSSQ
    `undef  DWC_DX0_NO_OF_VSSQ
    `undef  DWC_DX1_NO_OF_VSSQ
    `undef  DWC_DX2_NO_OF_VSSQ
    `undef  DWC_DX3_NO_OF_VSSQ
    `undef  DWC_DX4_NO_OF_VSSQ
    `undef  DWC_DX5_NO_OF_VSSQ
    `undef  DWC_DX6_NO_OF_VSSQ
    `undef  DWC_DX7_NO_OF_VSSQ
    `undef  DWC_DX8_NO_OF_VSSQ

    `define DWC_AC_I0_NO_OF_VSSQ         0
    `define DWC_DX0_NO_OF_VSSQ           0
    `define DWC_DX1_NO_OF_VSSQ           0
    `define DWC_DX2_NO_OF_VSSQ           0
    `define DWC_DX3_NO_OF_VSSQ           0
    `define DWC_DX4_NO_OF_VSSQ           0
    `define DWC_DX5_NO_OF_VSSQ           0
    `define DWC_DX6_NO_OF_VSSQ           0
    `define DWC_DX7_NO_OF_VSSQ           0
    `define DWC_DX8_NO_OF_VSSQ           0
  `else
    `define DWC_DnX_VSSQ_CONNECT         .MVSSQ    ( VSSQ    ),
    `define DWC_DQS_PDRH18_CONNECT       , .PDRH18 ( PDRH18[dwc_gdqs]  )
    `define DWC_DQ_PDRH18_CONNECT        , .PDRH18 ( PDRH18[`DWC_DX_DQ_VREF_INUM ]  )
    `define DWC_DTO_PDRH18_CONNECT       , .PDRH18 ( PDRH18[0]  )
    `define DWC_DAC_PDRH18_CONNECT       , .PDRH18 ( PDRH18[dwc_gvref_dac]  )
    `define DWC_PVREF_PDRH18_CONNECT     , .PDRH18 ( PDRH18[dwc_gvref]  )
    `define DWC_PDRH18_CONNECT           , .PDRH18 ( PDRH18[0]         )
    `define DWC_VDD_ESD_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VDD_ESD_VREF_INUM] )
    `define DWC_VDD_CAP_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VDD_CAP_VREF_INUM] )
    `define DWC_VSS_CAP_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VSS_CAP_VREF_INUM] )
    `define DWC_VSS_ESD_PDRH18_CONNECT   , .PDRH18 ( PDRH18 [`DWC_DX_VSS_ESD_VREF_INUM] )
    `define DWC_VDDQ_ESD_PDRH18_CONNECT  , .PDRH18 ( PDRH18 [`DWC_DX_VDDQ_ESD_VREF_INUM] )
    `define DWC_VDDQ_CAP_PDRH18_CONNECT  , .PDRH18 ( PDRH18 [`DWC_DX_VDDQ_CAP_VREF_INUM] )
    `define DWC_VSSQ_PDRH18_CONNECT      , .PDRH18 ( PDRH18 [`DWC_DX_VSSQ_VREF_INUM] )
    `define DWC_ZB_PDRH18_CONNECT        , .PDRH18 ( PDRH18 [`DWC_DX_ZB_VREF_INUM] )
    `define DWC_FILLT1_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT1_VREF_INUM] )
    `define DWC_FILLT2_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT2_VREF_INUM] )
    `define DWC_FILLT3_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT3_VREF_INUM] )
    `define DWC_FILLT4_PDRH18_CONNECT    , .PDRH18 ( PDRH18 [`DWC_DX_FILLT4_VREF_INUM] )
    `define DWC_FILLISOT1_PDRH18_CONNECT , .PDRH18 ( PDRH18 [`DWC_DX_FILLISOT1_VREF_INUM] )
    `define DWC_FILLISOT2_PDRH18_CONNECT , .PDRH18 ( PDRH18 [`DWC_DX_FILLISOT2_VREF_INUM] )
  `endif

  `ifdef DWC_DDRPHY_DMDQS_MUX
    `define DWC_DQS_DID_CONNECT        .DID      ( dqs_did_i[dwc_gdqs] ),
    `define DWC_DQSN_DID_CONNECT       .DID      (                     ),
    `define DWC_DQS_RK_CONNECT         .RK       ( io_vrefi_rnk        ),
  `else
    `define DWC_DQS_DID_CONNECT    
    `define DWC_DQSN_DID_CONNECT
    `define DWC_DQS_RK_CONNECT
  `endif
`endif

// D4MU
`ifdef  DWC_DDRPHY_D4MU_IO
  `define DWC_VREF_WIDTH               4
  `define DWC_ZCTRL_WIDTH              32
  `define DWC_ZIOH_WIDTH               76

  `define DWC_VAA_PLL_CONNECT         
  `define DWC_VREFISEL_CONNECT         .REFSEL   ( io_vrefi_sel[24*dwc_gvref+5:24*dwc_gvref]  ),
  `define DWC_RK_CONNECT               .RK       ( io_vrefi_rnk  ),
  `define DWC_VRMON_CONNECT            .VRMON    ( io_vrefi_mon  ),
  `define DWC_VREFIEN_CONNECT_DAC      .REFEN    ( io_vrefi_en[3:1]   ),
  `define DWC_VREFISEL_CONNECT_DAC     .REFSEL   ( io_vrefi_sel[24*(dwc_gvref_dac+1)-1:24*dwc_gvref_dac+6] ),
  `define DWC_ZVREFSE_VREF_ZQ_CONNECT  .MVREFSE_ZQ ( VREFSE_ZQ  ),
  `define DWC_DnX_VSSQ_CONNECT        
  `define DWC_DnX_VAA_PLL_CONNECT      .MVAA_PLL ( pll_vdd ),

  `define DWC_DQS_PDRH18_CONNECT       
  `define DWC_DQ_PDRH18_CONNECT        
  `define DWC_DTO_PDRH18_CONNECT       
  `define DWC_DAC_PDRH18_CONNECT       
  `define DWC_PVREF_PDRH18_CONNECT     
  `define DWC_PDRH18_CONNECT           
  `define DWC_VDD_ESD_PDRH18_CONNECT   
  `define DWC_VDD_CAP_PDRH18_CONNECT   
  `define DWC_VSS_CAP_PDRH18_CONNECT   
  `define DWC_VSS_ESD_PDRH18_CONNECT   
  `define DWC_VDDQ_ESD_PDRH18_CONNECT  
  `define DWC_VDDQ_CAP_PDRH18_CONNECT  
  `define DWC_VSSQ_PDRH18_CONNECT      
  `define DWC_ZB_PDRH18_CONNECT     
  `define DWC_FILLT1_PDRH18_CONNECT    
  `define DWC_FILLT2_PDRH18_CONNECT    
  `define DWC_FILLT3_PDRH18_CONNECT     
  `define DWC_FILLT4_PDRH18_CONNECT     
  `define DWC_FILLISOT1_PDRH18_CONNECT 
  `define DWC_FILLISOT2_PDRH18_CONNECT 

  `ifdef DWC_DDRPHY_DMDQS_MUX
    `define DWC_DQS_DID_CONNECT        .DID      ( dqs_did_i[dwc_gdqs] ),
    `define DWC_DQSN_DID_CONNECT       .DID      (                     ),
    `define DWC_DQS_RK_CONNECT         .RK       ( io_vrefi_rnk        ),
  `else
    `define DWC_DQS_DID_CONNECT    
    `define DWC_DQSN_DID_CONNECT
    `define DWC_DQS_RK_CONNECT
  `endif

  // these defines are not valid for this library; they may have been
  // set to a valid value for the defaults above - reset them to 0
  `undef  DWC_AC_I0_NO_OF_VSSQ
  `undef  DWC_DX0_NO_OF_VSSQ
  `undef  DWC_DX1_NO_OF_VSSQ
  `undef  DWC_DX2_NO_OF_VSSQ
  `undef  DWC_DX3_NO_OF_VSSQ
  `undef  DWC_DX4_NO_OF_VSSQ
  `undef  DWC_DX5_NO_OF_VSSQ
  `undef  DWC_DX6_NO_OF_VSSQ
  `undef  DWC_DX7_NO_OF_VSSQ
  `undef  DWC_DX8_NO_OF_VSSQ

  `define DWC_AC_I0_NO_OF_VSSQ         0
  `define DWC_DX0_NO_OF_VSSQ           0
  `define DWC_DX1_NO_OF_VSSQ           0
  `define DWC_DX2_NO_OF_VSSQ           0
  `define DWC_DX3_NO_OF_VSSQ           0
  `define DWC_DX4_NO_OF_VSSQ           0
  `define DWC_DX5_NO_OF_VSSQ           0
  `define DWC_DX6_NO_OF_VSSQ           0
  `define DWC_DX7_NO_OF_VSSQ           0
  `define DWC_DX8_NO_OF_VSSQ           0
`endif

// connectivity common to all libraries
`define DWC_DQS_DQSR_CONNECT           .DQSR     ( dqs_rsel      ),
`define DWC_DQSN_DQSR_CONNECT          .DQSR     ( dqs_n_rsel    ),
`define DWC_DQSG_PAD_CONNECT
`define DWC_ZQ_VREF_CONNECT            .MVREF_ZQ ( VREF_ZQ  )
`define DWC_ZIOH_ZQ_CONNECT            .ZIOH_ZQ  ( ZIOH_ZQ       ),
`define DWC_PG_ZIOH_ZQ_CONNECT         .ZIOH     ( ZIOH_ZQ       ),
`define DWC_VREFIEN_CONNECT_4AC        .REFEN    ( io_vrefi_en   ),
`define DWC_VREFIEN_CONNECT            .REFEN    ( io_vrefi_en[0]   ),
`define DWC_AC_VREFISEL_CONNECT        .REFSEL   ( io_vrefi_sel[5:0]  ),
`define DWC_VREFSEN_CONNECT            .REFENSE  ( io_vrefs_en   ),
`define DWC_VREFSSEL_CONNECT           .REFSELSE ( io_vrefs_sel  ),
`define DWC_VREFEEN_CONNECT            .REFEN    ( io_vrefe_en   ),
`define DWC_VREFESEL_CONNECT           .REFSEL   ( io_vrefe_sel  ),
`define DWC_VREFPEN_CONNECT            .ENPAD    ( io_vrefp_en   ),
`ifdef  DWC_DDRPHY_D4MU_IO
  `define DWC_VREFIOM_CONNECT          .IOM      ( io_vref_iom   ),
`else
  `define DWC_VREFIOM_CONNECT            
`endif    
`define DWC_VREFZEN_CONNECT            .REFEN    ( zq_vrefi_en   ),
`define DWC_VREFZSEL_CONNECT           .REFSEL   ( zq_vrefi_sel  ),
`define DWC_VREFZPEN_CONNECT           .ENPAD    ( zq_vrefp_en   ),
`define DWC_VREF_VREF_ZQ_CONNECT       .MVREF    ( VREF_ZQ  )
`define DWC_VREFSE_VREF_ZQ_CONNECT     .MVREFSE  ( VREFSE_ZQ  ),

`define DWC_VREF_CONNECT               .MVREF ( VREF [4*0+:`DWC_VREF_WIDTH]          ),
`define DWC_DQS_VREF_CONNECT           .MVREF ( VREF [dwc_gdqs*4+:`DWC_VREF_WIDTH ]  ),
`define DWC_DQ_VREF_CONNECT            .MVREF ( VREF [`DWC_DX_DQ_VREF_INUM*4+:`DWC_VREF_WIDTH ]  ),
`define DWC_DTO_VREF_CONNECT           .MVREF ( VREF [0*4+:`DWC_VREF_WIDTH ]  ),
`define DWC_DAC_VREF_CONNECT           .MVREF ( VREF [dwc_gvref_dac*4+:`DWC_VREF_WIDTH ]  ),
`define DWC_PVREF_VREF_CONNECT         .MVREF ( VREF [dwc_gvref*4+:`DWC_VREF_WIDTH ]  ),
`define DWC_VDD_ESD_VREF_CONNECT       .MVREF ( VREF [`DWC_DX_VDD_ESD_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VDD_CAP_VREF_CONNECT       .MVREF ( VREF [`DWC_DX_VDD_CAP_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VSH_ESD_VREF_CONNECT       .MVREF ( VREF [`DWC_DX_VSH_ESD_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VSH_CAP_VREF_CONNECT       .MVREF ( VREF [`DWC_DX_VSH_CAP_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VSS_CAP_VREF_CONNECT       .MVREF ( VREF [`DWC_DX_VSS_CAP_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VSS_ESD_VREF_CONNECT       .MVREF ( VREF [`DWC_DX_VSS_ESD_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VDDQ_ESD_VREF_CONNECT      .MVREF ( VREF [`DWC_DX_VDDQ_ESD_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VDDQ_CAP_VREF_CONNECT      .MVREF ( VREF [`DWC_DX_VDDQ_CAP_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_VSSQ_VREF_CONNECT          .MVREF ( VREF [`DWC_DX_VSSQ_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_ZB_VREF_CONNECT            .MVREF ( VREF [`DWC_DX_ZB_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_FILLT1_VREF_CONNECT        .MVREF ( VREF [`DWC_DX_FILLT1_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_FILLT2_VREF_CONNECT        .MVREF ( VREF [`DWC_DX_FILLT2_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_FILLT3_VREF_CONNECT        .MVREF ( VREF [`DWC_DX_FILLT3_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_FILLT4_VREF_CONNECT        .MVREF ( VREF [`DWC_DX_FILLT4_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_FILLISOT1_VREF_CONNECT     .MVREF ( VREF [`DWC_DX_FILLISOT1_VREF_INUM*4+:`DWC_VREF_WIDTH] ),
`define DWC_FILLISOT2_VREF_CONNECT     .MVREF ( VREF [`DWC_DX_FILLISOT2_VREF_INUM*4+:`DWC_VREF_WIDTH] ),

`define DWC_VREFSE_CONNECT             .MVREFSE ( VREFSE[0]         )
`define DWC_DQS_VREFSE_CONNECT         .MVREFSE ( VREFSE[dwc_gdqs]  )
`define DWC_DQ_VREFSE_CONNECT          .MVREFSE ( VREFSE[`DWC_DX_DQ_VREF_INUM]  )
`define DWC_DTO_VREFSE_CONNECT         .MVREFSE ( VREFSE[0]  )
`define DWC_DAC_VREFSE_CONNECT         .MVREFSE ( VREFSE[dwc_gvref_dac]  )
`define DWC_PVREF_VREFSE_CONNECT       .MVREFSE ( VREFSE[dwc_gvref]  )
`define DWC_VDD_ESD_VREFSE_CONNECT     .MVREFSE ( VREFSE [`DWC_DX_VDD_ESD_VREF_INUM] )
`define DWC_VDD_CAP_VREFSE_CONNECT     .MVREFSE ( VREFSE [`DWC_DX_VDD_CAP_VREF_INUM] )
`define DWC_VSH_ESD_VREFSE_CONNECT     .MVREFSE ( VREFSE [`DWC_DX_VSH_ESD_VREF_INUM] )
`define DWC_VSH_CAP_VREFSE_CONNECT     .MVREFSE ( VREFSE [`DWC_DX_VSH_CAP_VREF_INUM] )
`define DWC_VSS_CAP_VREFSE_CONNECT     .MVREFSE ( VREFSE [`DWC_DX_VSS_CAP_VREF_INUM] )
`define DWC_VSS_ESD_VREFSE_CONNECT     .MVREFSE ( VREFSE [`DWC_DX_VSS_ESD_VREF_INUM] )
`define DWC_VDDQ_ESD_VREFSE_CONNECT    .MVREFSE ( VREFSE [`DWC_DX_VDDQ_ESD_VREF_INUM] )
`define DWC_VDDQ_CAP_VREFSE_CONNECT    .MVREFSE ( VREFSE [`DWC_DX_VDDQ_CAP_VREF_INUM] )
`define DWC_VSSQ_VREFSE_CONNECT        .MVREFSE ( VREFSE [`DWC_DX_VSSQ_VREF_INUM] )
`define DWC_ZB_VREFSE_CONNECT          .MVREFSE ( VREFSE [`DWC_DX_ZB_VREF_INUM] )
`define DWC_FILLT1_VREFSE_CONNECT      .MVREFSE ( VREFSE [`DWC_DX_FILLT1_VREF_INUM] )
`define DWC_FILLT2_VREFSE_CONNECT      .MVREFSE ( VREFSE [`DWC_DX_FILLT2_VREF_INUM] )
`define DWC_FILLT3_VREFSE_CONNECT      .MVREFSE ( VREFSE [`DWC_DX_FILLT3_VREF_INUM] )
`define DWC_FILLT4_VREFSE_CONNECT      .MVREFSE ( VREFSE [`DWC_DX_FILLT4_VREF_INUM] )
`define DWC_FILLISOT1_VREFSE_CONNECT   .MVREFSE ( VREFSE [`DWC_DX_FILLISOT1_VREF_INUM] )
`define DWC_FILLISOT2_VREFSE_CONNECT   .MVREFSE ( VREFSE [`DWC_DX_FILLISOT2_VREF_INUM] )

// macros to define the connectivity of power/ground (PG) pins
// - PG pins connected only if enabled
`ifdef  DWC_DDRPHY_PG_PINS
  `define DWC_VDDQ_CONNECT             .MVDDQ    ( VDDQ     ),
  `define DWC_VSSQ_CONNECT             `DWC_DnX_VSSQ_CONNECT
  `ifdef  DWC_DDRPHY_D4MV2V5_IO
    `define DWC_VSH_CONNECT            .MVSH     ( VSH      ),
  `else
    `define DWC_VSH_CONNECT
  `endif
  `define DWC_VDD_CONNECT              .MVDD     ( VDD      ),
  `define DWC_VSS_CONNECT              .MVSS     ( VSS      )
  `define DWC_VDDQ_CONNECTX            .MVDDQ    ( VDDQ     )
  `define DWC_NEXT_CONNECT ,
  `define DWC_PLL_VDD_VAA_PLL_CONNECT  `DWC_DnX_VAA_PLL_CONNECT
  `define DWC_PLL_VDD_PPAD_PAD_CONNECT .PAD      ( pll_vdd  ),
  `define DWC_VDD_PPAD_PAD_CONNECT     .PAD      ( VDD      ),
  `define DWC_VSS_PPAD_PAD_CONNECT     .PAD      ( VSS      ),
`else
  `define DWC_VDDQ_CONNECT
  `define DWC_VSSQ_CONNECT
  `define DWC_VSH_CONNECT
  `define DWC_VDD_CONNECT
  `define DWC_VSS_CONNECT
  `define DWC_VDDQ_CONNECTX
  `define DWC_NEXT_CONNECT
  `define DWC_PLL_VDD_VAA_PLL_CONNECT
  `define DWC_PLL_VDD_PPAD_PAD_CONNECT
  `define DWC_VDD_PPAD_PAD_CONNECT
  `define DWC_VSS_PPAD_PAD_CONNECT
`endif


// I/O library cell names
// ----------------------
// cell names for each library
// D4M I/O cell names
`ifdef  DWC_DDRPHY_D4M_IO
  `define SNPS_D3X_PDDRIO_NS             DWC_D4M_PDDRIO_NS
  `define SNPS_D3X_PCKE_NS               DWC_D4M_PCKE_NS
  `define SNPS_D3X_PDIFF_NS              DWC_D4M_PDIFF_NS
  `define SNPS_D3X_PDQSG_VSSQ_NS         DWC_D4M_PDQSG_VSSQ_NS
  `define SNPS_D3X_PAIO_NS               DWC_D4M_PAIO_NS
  `define SNPS_D3X_PZQ_NS                DWC_D4M_PZQ_NS
  `define SNPS_D3X_PZCTRL_NS             DWC_D4M_PZCTRL_NS
  `define SNPS_D3X_PVREF_NS              DWC_D4M_PVREF_NS
  `define SNPS_D3X_PVREFE_NS             DWC_D4M_PVREFE_NS
  `define SNPS_D3X_PVDD_ESD_NS           DWC_D4M_PVDD_ESD_NS
  
  `define SNPS_D3X_PDDRIO_EW             DWC_D4M_PDDRIO_EW
  `define SNPS_D3X_PCKE_EW               DWC_D4M_PCKE_EW
  `define SNPS_D3X_PDQSG_VSSQ_EW         DWC_D4M_PDQSG_VSSQ_EW
  `define SNPS_D3X_PDIFF_EW              DWC_D4M_PDIFF_EW
  `define SNPS_D3X_PAIO_EW               DWC_D4M_PAIO_EW
  `define SNPS_D3X_PZQ_EW                DWC_D4M_PZQ_EW
  `define SNPS_D3X_PZCTRL_EW             DWC_D4M_PZCTRL_EW
  `define SNPS_D3X_PVREF_EW              DWC_D4M_PVREF_EW
  `define SNPS_D3X_PVREFE_EW             DWC_D4M_PVREFE_EW
  `define SNPS_D3X_PVDD_ESD_EW           DWC_D4M_PVDD_ESD_EW

  `define SNPS_D3X_PRETPOCX_NS           DWC_D4M_PRETPOCX
  `define SNPS_D3X_PRETPOCC_NS           DWC_D4M_PRETPOCC
  `define SNPS_D3X_PVAA_PLL_NS           DWC_D4M_PVAA_PLL
  `define SNPS_D3X_PVSS_PLL_NS           DWC_D4M_PVSS_PLL
  `define SNPS_D3X_PVAA_NS               DWC_D4M_PVAA    
  `define SNPS_D3X_PVSS_ESD_NS           DWC_D4M_PVSS
  `define SNPS_D3X_PVSS_CAP_NS           DWC_D4M_PVSS
  `define SNPS_D3X_PVDD_CAP_NS           DWC_D4M_PVDD_CAP
  `define SNPS_D3X_PVDDQ_ESD_NS          DWC_D4M_PVDDQ_ESD
  `define SNPS_D3X_PVDDQ_CAP_NS          DWC_D4M_PVDDQ_CAP
  `define SNPS_D3X_PVSSQ_NS              DWC_D4M_PVSSQ
  `define SNPS_D3X_PZB_NS                DWC_D4M_PVSSQZB
  `define SNPS_D3X_PZB_ZQ_NS             DWC_D4M_PVSSQZB_ZQ

  `define SNPS_D3X_PFILLT1_NS            DWC_D4M_PFILL_1
  `define SNPS_D3X_PFILLT2_NS            DWC_D4M_PFILL_5
  `define SNPS_D3X_PFILLT3_NS            DWC_D4M_PFILL1
  `define SNPS_D3X_PFILLT4_NS            DWC_D4M_PFILL5
  `define SNPS_D3X_PFILLISOT1_NS         DWC_D4M_PFILL5_ISO
  `define SNPS_D3X_PFILLISOT2_NS         DWC_D4M_PFILL5_ISO_VDDQVSSQ
  `define SNPS_D3X_PCORNER_NS            DWC_D4M_PCORNER
  `define SNPS_D3X_PEND_NS               DWC_D4M_PEND

  `define SNPS_D3X_PSCAP_GEN_NS          DWC_D4M_PSCAP_GEN
  `define SNPS_D3X_PSCAP_PDIFF_NS        DWC_D4M_PSCAP_GEN
  `define SNPS_D3X_PSCAP_VDDQ_NS         DWC_D4M_PSCAP_VDDQ
  `define SNPS_D3X_PSCAP_VSSQ_NS         DWC_D4M_PSCAP_VSSQ
  `define SNPS_D3X_PSCAP_FILLT1_NS       DWC_D4M_PSCAP_FILL_1
  `define SNPS_D3X_PSCAP_FILLT2_NS       DWC_D4M_PSCAP_FILL_5
  `define SNPS_D3X_PSCAP_FILLT3_NS       DWC_D4M_PSCAP_FILL1
  `define SNPS_D3X_PSCAP_FILLT4_NS       DWC_D4M_PSCAP_FILL5
  `define SNPS_D3X_PSCAP_FILLISOT1_NS    DWC_D4M_PSCAP_FILL5_ISO
  `define SNPS_D3X_PSCAP_FILLISOT2_NS    DWC_D4M_PSCAP_FILL5_ISO_VDDQVSSQ
  `define SNPS_D3X_PSCAP_END_NS          DWC_D4M_PSCAP_END

  `define SNPS_D3X_PPADCWO_GEN_NS        DWC_D4M_PPADCWO_GEN
  `define SNPS_D3X_PPADCWI_GEN_NS        DWC_D4M_PPADCWI_GEN
  `define SNPS_D3X_PPADCWO_VDDQ_NS       DWC_D4M_PPADCWO_VDDQ
  `define SNPS_D3X_PPADCWI_VDDQ_NS       DWC_D4M_PPADCWI_VDDQ
  `define SNPS_D3X_PPADCWO_VSSQ_NS       DWC_D4M_PPADCWO_VSSQ
  `define SNPS_D3X_PPADCWI_VSSQ_NS       DWC_D4M_PPADCWI_VSSQ
  `define SNPS_D3X_PPADCW_FILLT1_NS      DWC_D4M_PPADCW_FILL_1
  `define SNPS_D3X_PPADCW_FILLT2_NS      DWC_D4M_PPADCW_FILL_5
  `define SNPS_D3X_PPADCW_FILLT3_NS      DWC_D4M_PPADCW_FILL1
  `define SNPS_D3X_PPADCW_FILLT4_NS      DWC_D4M_PPADCW_FILL5
  `define SNPS_D3X_PPADCW_FILLISOT1_NS   DWC_D4M_PPADCW_FILL5_ISO
  `define SNPS_D3X_PPADCW_FILLISOT2_NS   DWC_D4M_PPADCW_FILL5_ISO_VDDQVSSQ
  `define SNPS_D3X_PPADCW_END_NS         DWC_D4M_PPADCW_END

  `define SNPS_D3X_PRETPOCX_EW           DWC_D4M_PRETPOCX
  `define SNPS_D3X_PRETPOCC_EW           DWC_D4M_PRETPOCC
  `define SNPS_D3X_PVAA_PLL_EW           DWC_D4M_PVAA_PLL
  `define SNPS_D3X_PVSS_PLL_EW           DWC_D4M_PVSS_PLL
  `define SNPS_D3X_PVAA_EW               DWC_D4M_PVAA    
  `define SNPS_D3X_PVSS_ESD_EW           DWC_D4M_PVSS
  `define SNPS_D3X_PVSS_CAP_EW           DWC_D4M_PVSS
  `define SNPS_D3X_PVDD_CAP_EW           DWC_D4M_PVDD_CAP
  `define SNPS_D3X_PVDDQ_ESD_EW          DWC_D4M_PVDDQ_ESD
  `define SNPS_D3X_PVDDQ_CAP_EW          DWC_D4M_PVDDQ_CAP
  `define SNPS_D3X_PVSSQ_EW              DWC_D4M_PVSSQ
  `define SNPS_D3X_PZB_EW                DWC_D4M_PVSSQZB
  `define SNPS_D3X_PZB_ZQ_EW             DWC_D4M_PVSSQZB_ZQ

  `define SNPS_D3X_PFILLT1_EW            DWC_D4M_PFILL_1
  `define SNPS_D3X_PFILLT2_EW            DWC_D4M_PFILL_5
  `define SNPS_D3X_PFILLT3_EW            DWC_D4M_PFILL1
  `define SNPS_D3X_PFILLT4_EW            DWC_D4M_PFILL5
  `define SNPS_D3X_PFILLISOT1_EW         DWC_D4M_PFILL5_ISO
  `define SNPS_D3X_PFILLISOT2_EW         DWC_D4M_PFILL5_ISO_VDDQVSSQ
  `define SNPS_D3X_PCORNER_EW            DWC_D4M_PCORNER
  `define SNPS_D3X_PEND_EW               DWC_D4M_PEND

  `define SNPS_D3X_PSCAP_GEN_EW          DWC_D4M_PSCAP_GEN
  `define SNPS_D3X_PSCAP_PDIFF_EW        DWC_D4M_PSCAP_GEN
  `define SNPS_D3X_PSCAP_VDDQ_EW         DWC_D4M_PSCAP_VDDQ
  `define SNPS_D3X_PSCAP_VSSQ_EW         DWC_D4M_PSCAP_VSSQ
  `define SNPS_D3X_PSCAP_FILLT1_EW       DWC_D4M_PSCAP_FILL_1
  `define SNPS_D3X_PSCAP_FILLT2_EW       DWC_D4M_PSCAP_FILL_5
  `define SNPS_D3X_PSCAP_FILLT3_EW       DWC_D4M_PSCAP_FILL1
  `define SNPS_D3X_PSCAP_FILLT4_EW       DWC_D4M_PSCAP_FILL5
  `define SNPS_D3X_PSCAP_FILLISOT1_EW    DWC_D4M_PSCAP_FILL5_ISO
  `define SNPS_D3X_PSCAP_FILLISOT2_EW    DWC_D4M_PSCAP_FILL5_ISO_VDDQVSSQ
  `define SNPS_D3X_PSCAP_END_EW          DWC_D4M_PSCAP_END

  `define SNPS_D3X_PPADCWO_GEN_EW        DWC_D4M_PPADCWO_GEN
  `define SNPS_D3X_PPADCWI_GEN_EW        DWC_D4M_PPADCWI_GEN
  `define SNPS_D3X_PPADCWO_VDDQ_EW       DWC_D4M_PPADCWO_VDDQ
  `define SNPS_D3X_PPADCWI_VDDQ_EW       DWC_D4M_PPADCWI_VDDQ
  `define SNPS_D3X_PPADCWO_VSSQ_EW       DWC_D4M_PPADCWO_VSSQ
  `define SNPS_D3X_PPADCWI_VSSQ_EW       DWC_D4M_PPADCWI_VSSQ
  `define SNPS_D3X_PPADCW_FILLT1_EW      DWC_D4M_PPADCW_FILL_1
  `define SNPS_D3X_PPADCW_FILLT2_EW      DWC_D4M_PPADCW_FILL_5
  `define SNPS_D3X_PPADCW_FILLT3_EW      DWC_D4M_PPADCW_FILL1
  `define SNPS_D3X_PPADCW_FILLT4_EW      DWC_D4M_PPADCW_FILL5
  `define SNPS_D3X_PPADCW_FILLISOT1_EW   DWC_D4M_PPADCW_FILL5_ISO
  `define SNPS_D3X_PPADCW_FILLISOT2_EW   DWC_D4M_PPADCW_FILL5_ISO_VDDQVSSQ
  `define SNPS_D3X_PPADCW_END_EW         DWC_D4M_PPADCW_END

  // these cells are not present or named differently in this I/O library
  // and need definitions to minimize number of ifdefs in the code;
  `define SNPS_D3X_PDIFFT_NS             DWC_D4M_PDIFF_NS
  `define SNPS_D3X_PDIFFC_NS             DWC_D4M_PDIFF_NS
  `define SNPS_D3X_PVREF_DAC_NS          DWC_D4M_PVREF_DAC

  `define SNPS_D3X_PDIFFT_EW             DWC_D4M_PDIFF_EW
  `define SNPS_D3X_PDIFFC_EW             DWC_D4M_PDIFF_EW
  `define SNPS_D3X_PVREF_DAC_EW          DWC_D4M_PVREF_DAC
`endif

// D4MV I/O cell names
`ifdef  DWC_DDRPHY_D4MV_IO
  `define SNPS_D3X_PVREF_DAC_NS          DWC_D4MV_PVREF_DAC_NS
  `define SNPS_D3X_PDDRIO_NS             DWC_D4MV_PDDRIO_NS
  `define SNPS_D3X_PCKE_NS               DWC_D4MV_PCKE_NS
  `define SNPS_D3X_PDIFF_NS              DWC_D4MV_PDIFF_NS
  `define SNPS_D3X_PDIFFT_NS             DWC_D4MV_PDIFFT_NS
  `define SNPS_D3X_PDIFFC_NS             DWC_D4MV_PDIFFC_NS
  `define SNPS_D3X_PDQSG_VSSQ_NS         DWC_D4MV_PDQSG_VSSQ_NS
  `define SNPS_D3X_PAIO_NS               DWC_D4MV_PAIO_NS
  `define SNPS_D3X_PZQ_NS                DWC_D4MV_PZQ_NS
  `define SNPS_D3X_PZCTRL_NS             DWC_D4MV_PZCTRL_NS
  `define SNPS_D3X_PVREF_NS              DWC_D4MV_PVREF_NS
  `define SNPS_D3X_PVREFE_NS             DWC_D4MV_PVREFE_NS
  `define SNPS_D3X_PVDD_ESD_NS           DWC_D4MV_PVDD_ESD_NS
  
  `define SNPS_D3X_PVREF_DAC_EW          DWC_D4MV_PVREF_DAC_EW
  `define SNPS_D3X_PDDRIO_EW             DWC_D4MV_PDDRIO_EW
  `define SNPS_D3X_PCKE_EW               DWC_D4MV_PCKE_EW
  `ifdef  DWC_DDRPHY_D4MV2V5_IO
    `define SNPS_D3X_PDQSG_VSSQ_EW       DWC_D4MV_PDQSG_VSS_EW
  `else
    `define SNPS_D3X_PDQSG_VSSQ_EW       DWC_D4MV_PDQSG_VSSQ_EW
  `endif
  `define SNPS_D3X_PDIFF_EW              DWC_D4MV_PDIFF_EW
  `define SNPS_D3X_PDIFFT_EW             DWC_D4MV_PDIFFT_EW
  `define SNPS_D3X_PDIFFC_EW             DWC_D4MV_PDIFFC_EW
  `define SNPS_D3X_PAIO_EW               DWC_D4MV_PAIO_EW
  `define SNPS_D3X_PZQ_EW                DWC_D4MV_PZQ_EW
  `define SNPS_D3X_PZCTRL_EW             DWC_D4MV_PZCTRL_EW
  `define SNPS_D3X_PVREF_EW              DWC_D4MV_PVREF_EW
  `define SNPS_D3X_PVREFE_EW             DWC_D4MV_PVREFE_EW
  `define SNPS_D3X_PVDD_ESD_EW           DWC_D4MV_PVDD_ESD_EW
  `define SNPS_D3X_PVSH_ESD_EW           DWC_D4MV_PVSH_ESD_EW

  `define SNPS_D3X_PRETPOCX_NS           DWC_D4MV_PRETPOCX_NS
  `define SNPS_D3X_PRETPOCC_NS           DWC_D4MV_PRETPOCC_NS
  `define SNPS_D3X_PVAA_PLL_NS           DWC_D4MV_PVAA_PLL_NS
  `define SNPS_D3X_PVSS_PLL_NS           DWC_D4MV_PVSS_PLL_NS
  `define SNPS_D3X_PVAA_NS               DWC_D4MV_PVAA_NS    
  `define SNPS_D3X_PVSS_CAP_NS           DWC_D4MV_PVSS_CAP_NS
  `define SNPS_D3X_PVSS_ESD_NS           DWC_D4MV_PVSS_ESD_NS
  `define SNPS_D3X_PVDD_CAP_NS           DWC_D4MV_PVDD_CAP_NS
  `define SNPS_D3X_PVDDQ_ESD_NS          DWC_D4MV_PVDDQ_ESD_NS
  `define SNPS_D3X_PVDDQ_CAP_NS          DWC_D4MV_PVDDQ_CAP_NS
  `define SNPS_D3X_PVSSQ_NS              DWC_D4MV_PVSSQ_NS
  `define SNPS_D3X_PZB_NS                DWC_D4MV_PVSSZB_NS
  `define SNPS_D3X_PZB_ZQ_NS             DWC_D4MV_PVSSZB_ZQ_NS

  `define SNPS_D3X_PFILLT1_NS            DWC_D4MV_PFILL_1_NS
  `define SNPS_D3X_PFILLT2_NS            DWC_D4MV_PFILL_5_NS
  `define SNPS_D3X_PFILLT3_NS            DWC_D4MV_PFILL1_NS
  `define SNPS_D3X_PFILLT4_NS            DWC_D4MV_PFILL5_NS
  `define SNPS_D3X_PFILLISOT1_NS         DWC_D4MV_PFILL5_ISO_NS
  `define SNPS_D3X_PFILLISOT2_NS         DWC_D4MV_PFILL5_ISO_VDDQVSSQ_NS
  `define SNPS_D3X_PCORNER_NS            DWC_D4MV_PCORNER
  `define SNPS_D3X_PEND_NS               DWC_D4MV_PEND_NS

  `define SNPS_D3X_PSCAP_GEN_NS          DWC_D4MV_PSCAP_NS
  `define SNPS_D3X_PSCAP_PDIFF_NS        DWC_D4MV_PSCAP_NS
  `define SNPS_D3X_PSCAP_VDDQ_NS         DWC_D4MV_PSCAP_NS
  `define SNPS_D3X_PSCAP_VSSQ_NS         DWC_D4MV_PSCAP_NS
  `define SNPS_D3X_PSCAP_FILLT1_NS       DWC_D4MV_PSCAP_FILL_1_NS
  `define SNPS_D3X_PSCAP_FILLT2_NS       DWC_D4MV_PSCAP_FILL_5_NS
  `define SNPS_D3X_PSCAP_FILLT3_NS       DWC_D4MV_PSCAP_FILL1_NS
  `define SNPS_D3X_PSCAP_FILLT4_NS       DWC_D4MV_PSCAP_FILL5_NS
  `define SNPS_D3X_PSCAP_FILLISOT1_NS    DWC_D4MV_PSCAP_FILL5_ISO_NS
  `define SNPS_D3X_PSCAP_FILLISOT2_NS    DWC_D4MV_PSCAP_FILL5_ISO_VDDQVSSQ_NS
  `define SNPS_D3X_PSCAP_END_NS          DWC_D4MV_PSCAP_END_NS

  `define SNPS_D3X_PPADCWO_GEN_NS        DWC_D4MV_PPADCWO_NS
  `define SNPS_D3X_PPADCWI_GEN_NS        DWC_D4MV_PPADCWI_NS
  `define SNPS_D3X_PPADCWO_VDDQ_NS       DWC_D4MV_PPADCWO_NS
  `define SNPS_D3X_PPADCWI_VDDQ_NS       DWC_D4MV_PPADCWI_NS
  `define SNPS_D3X_PPADCWO_VSSQ_NS       DWC_D4MV_PPADCWO_NS
  `define SNPS_D3X_PPADCWI_VSSQ_NS       DWC_D4MV_PPADCWI_NS
  `define SNPS_D3X_PPADCW_FILLT1_NS      DWC_D4MV_PPADCW_FILL_1_NS
  `define SNPS_D3X_PPADCW_FILLT2_NS      DWC_D4MV_PPADCW_FILL_5_NS
  `define SNPS_D3X_PPADCW_FILLT3_NS      DWC_D4MV_PPADCW_FILL1_NS
  `define SNPS_D3X_PPADCW_FILLT4_NS      DWC_D4MV_PPADCW_FILL5_NS
  `define SNPS_D3X_PPADCW_FILLISOT1_NS   DWC_D4MV_PPADCW_FILL5_ISO_NS
  `define SNPS_D3X_PPADCW_FILLISOT2_NS   DWC_D4MV_PPADCW_FILL5_ISO_VDDQVSSQ_NS
  `define SNPS_D3X_PPADCW_END_NS         DWC_D4MV_PPADCW_END_NS

  `define SNPS_D3X_PRETPOCX_EW           DWC_D4MV_PRETPOCX_EW
  `define SNPS_D3X_PRETPOCC_EW           DWC_D4MV_PRETPOCC_EW
  `define SNPS_D3X_PVAA_PLL_EW           DWC_D4MV_PVAA_PLL_EW
  `define SNPS_D3X_PVSS_PLL_EW           DWC_D4MV_PVSS_PLL_EW
  `define SNPS_D3X_PVAA_EW               DWC_D4MV_PVAA_EW    
  `define SNPS_D3X_PVSS_CAP_EW           DWC_D4MV_PVSS_CAP_EW
  `define SNPS_D3X_PVSS_ESD_EW           DWC_D4MV_PVSS_ESD_EW
  `define SNPS_D3X_PVDD_CAP_EW           DWC_D4MV_PVDD_CAP_EW
  `define SNPS_D3X_PVSH_CAP_EW           DWC_D4MV_PVSH_CAP_EW
  `define SNPS_D3X_PVDDQ_ESD_EW          DWC_D4MV_PVDDQ_ESD_EW
  `define SNPS_D3X_PVDDQ_CAP_EW          DWC_D4MV_PVDDQ_CAP_EW
  `define SNPS_D3X_PVSSQ_EW              DWC_D4MV_PVSSQ_EW
  `define SNPS_D3X_PZB_EW                DWC_D4MV_PVSSZB_EW
  `define SNPS_D3X_PZB_ZQ_EW             DWC_D4MV_PVSSZB_ZQ_EW

  `define SNPS_D3X_PFILLT1_EW            DWC_D4MV_PFILL_1_EW
  `define SNPS_D3X_PFILLT2_EW            DWC_D4MV_PFILL_5_EW
  `define SNPS_D3X_PFILLT3_EW            DWC_D4MV_PFILL1_EW
  `define SNPS_D3X_PFILLT4_EW            DWC_D4MV_PFILL5_EW
  `define SNPS_D3X_PFILLISOT1_EW         DWC_D4MV_PFILL5_ISO_EW
  `define SNPS_D3X_PFILLISOT2_EW         DWC_D4MV_PFILL5_ISO_VDDQVSSQ_EW
  `define SNPS_D3X_PCORNER_EW            DWC_D4MV_PCORNER
  `define SNPS_D3X_PEND_EW               DWC_D4MV_PEND_EW

  `define SNPS_D3X_PSCAP_GEN_EW          DWC_D4MV_PSCAP_EW
  `define SNPS_D3X_PSCAP_VSH_EW          DWC_D4MV_PSCAP_VSH_EW
  `define SNPS_D3X_PSCAP_PDIFF_EW        DWC_D4MV_PSCAP_EW
  `define SNPS_D3X_PSCAP_VDDQ_EW         DWC_D4MV_PSCAP_EW
  `define SNPS_D3X_PSCAP_VSSQ_EW         DWC_D4MV_PSCAP_EW
  `define SNPS_D3X_PSCAP_FILLT1_EW       DWC_D4MV_PSCAP_FILL_1_EW
  `define SNPS_D3X_PSCAP_FILLT2_EW       DWC_D4MV_PSCAP_FILL_5_EW
  `define SNPS_D3X_PSCAP_FILLT3_EW       DWC_D4MV_PSCAP_FILL1_EW
  `define SNPS_D3X_PSCAP_FILLT4_EW       DWC_D4MV_PSCAP_FILL5_EW
  `define SNPS_D3X_PSCAP_FILLISOT1_EW    DWC_D4MV_PSCAP_FILL5_ISO_EW
  `define SNPS_D3X_PSCAP_FILLISOT2_EW    DWC_D4MV_PSCAP_FILL5_ISO_VDDQVSSQ_EW
  `define SNPS_D3X_PSCAP_END_EW          DWC_D4MV_PSCAP_END_EW

  `define SNPS_D3X_PPADCWO_GEN_EW        DWC_D4MV_PPADCWO_EW
  `define SNPS_D3X_PPADCWI_GEN_EW        DWC_D4MV_PPADCWI_EW
  `define SNPS_D3X_PPADCWO_VDDQ_EW       DWC_D4MV_PPADCWO_EW
  `define SNPS_D3X_PPADCWI_VDDQ_EW       DWC_D4MV_PPADCWI_EW
  `define SNPS_D3X_PPADCWO_VSSQ_EW       DWC_D4MV_PPADCWO_EW
  `define SNPS_D3X_PPADCWI_VSSQ_EW       DWC_D4MV_PPADCWI_EW
  `define SNPS_D3X_PPADCW_FILLT1_EW      DWC_D4MV_PPADCW_FILL_1_EW
  `define SNPS_D3X_PPADCW_FILLT2_EW      DWC_D4MV_PPADCW_FILL_5_EW
  `define SNPS_D3X_PPADCW_FILLT3_EW      DWC_D4MV_PPADCW_FILL1_EW
  `define SNPS_D3X_PPADCW_FILLT4_EW      DWC_D4MV_PPADCW_FILL5_EW
  `define SNPS_D3X_PPADCW_FILLISOT1_EW   DWC_D4MV_PPADCW_FILL5_ISO_EW
  `define SNPS_D3X_PPADCW_FILLISOT2_EW   DWC_D4MV_PPADCW_FILL5_ISO_VDDQVSSQ_EW
  `define SNPS_D3X_PPADCW_END_EW         DWC_D4MV_PPADCW_END_EW

  // these cells are not present or named differently in this I/O library
  // and need definitions to minimize number of ifdefs in the code;
`endif

// D4MU I/O cell names
`ifdef  DWC_DDRPHY_D4MU_IO
  `define SNPS_D3X_PVREF_DAC_NS          DWC_D4MU_PVREF_DAC_PADVSS_NS
  `define SNPS_D3X_PDDRIO_NS             DWC_D4MU_PDDRIO_NS
  `define SNPS_D3X_PCKE_NS               DWC_D4MU_PCKE_NS
  `define SNPS_D3X_PDIFF_NS              DWC_D4MU_PDIFF_NS
  `define SNPS_D3X_PDIFFT_NS             DWC_D4MU_PDIFFT_NS
  `define SNPS_D3X_PDIFFC_NS             DWC_D4MU_PDIFFC_NS
  `define SNPS_D3X_PDQSG_VSSQ_NS         DWC_D4MU_PDQSG_PADVSS_NS
  `define SNPS_D3X_PAIO_NS               DWC_D4MU_PAIO_NS
  `define SNPS_D3X_PZQ_NS                DWC_D4MU_PZQ_ISO_ZIOHMVREF_NS
  `define SNPS_D3X_PZCTRL_NS             DWC_D4MU_PZCTRL_ISO_ZIOHMVREF_NS
  `define SNPS_D3X_PVREF_NS              DWC_D4MU_PVREF_NS
  `define SNPS_D3X_PVREFE_NS             DWC_D4MU_PVREFE_NS
  `define SNPS_D3X_PVDD_ESD_NS           DWC_D4MU_PVDD_ESD_NS
  
  `define SNPS_D3X_PVREF_DAC_EW          DWC_D4MU_PVREF_DAC_PADVSS_EW
  `define SNPS_D3X_PDDRIO_EW             DWC_D4MU_PDDRIO_EW
  `define SNPS_D3X_PCKE_EW               DWC_D4MU_PCKE_EW
  `define SNPS_D3X_PDQSG_VSSQ_EW         DWC_D4MU_PDQSG_PADVSS_EW
  `define SNPS_D3X_PDIFF_EW              DWC_D4MU_PDIFF_EW
  `define SNPS_D3X_PDIFFT_EW             DWC_D4MU_PDIFFT_EW
  `define SNPS_D3X_PDIFFC_EW             DWC_D4MU_PDIFFC_EW
  `define SNPS_D3X_PAIO_EW               DWC_D4MU_PAIO_EW
  `define SNPS_D3X_PZQ_EW                DWC_D4MU_PZQ_ISO_ZIOHMVREF_EW
  `define SNPS_D3X_PZCTRL_EW             DWC_D4MU_PZCTRL_ISO_ZIOHMVREF_EW
  `define SNPS_D3X_PVREF_EW              DWC_D4MU_PVREF_EW
  `define SNPS_D3X_PVREFE_EW             DWC_D4MU_PVREFE_EW
  `define SNPS_D3X_PVDD_ESD_EW           DWC_D4MU_PVDD_ESD_EW

  `define SNPS_D3X_PRETPOCX_NS           DWC_D4MU_PRETPOCX_NS
  `define SNPS_D3X_PRETPOCC_NS           DWC_D4MU_PRETPOCC_PADVSS_NS
  `define SNPS_D3X_PVAA_PLL_NS           DWC_D4MU_PVAA_PLL_NS
  `define SNPS_D3X_PVSS_PLL_NS           DWC_D4MU_PVSS_PLL_NS
  `define SNPS_D3X_PVAA_NS               DWC_D4MU_PVAA_NS    
  `define SNPS_D3X_PVSS_CAP_NS           DWC_D4MU_PVSS_CAP_NS
  `define SNPS_D3X_PVSS_ESD_NS           DWC_D4MU_PVSS_ESD_NS
  `define SNPS_D3X_PVDD_CAP_NS           DWC_D4MU_PVDD_CAP_NS
  `define SNPS_D3X_PVDDQ_ESD_NS          DWC_D4MU_PVDDQ_ESD_NS
  `define SNPS_D3X_PVDDQ_CAP_NS          DWC_D4MU_PVDDQ_CAP_NS
  `define SNPS_D3X_PVSSQ_NS              DWC_D4MU_PVSSQ_NS
  `define SNPS_D3X_PZB_NS                DWC_D4MU_PVSS_ESD_ISO_ZIOH_NS
  `define SNPS_D3X_PZB_ZQ_NS             DWC_D4MU_PVSS_ESD_ISO_ZIOHMVREF_NS

  `define SNPS_D3X_PFILLT1_NS            DWC_D4MU_PFILL1_NS
  `define SNPS_D3X_PFILLT2_NS            DWC_D4MU_PFILL5_NS
  `define SNPS_D3X_PFILLT3_NS            DWC_D4MU_PFILL20_NS
  `define SNPS_D3X_PFILLT4_NS            DWC_D4MU_PFILL20_NS
  `define SNPS_D3X_PFILLISOT1_NS         DWC_D4MU_PFILL20_ISO_MVDDQLENH_NS
  `define SNPS_D3X_PFILLISOT2_NS         DWC_D4MU_PFILL20_ISO_MVDDQ_NS
  `define SNPS_D3X_PCORNER_NS            DWC_D4MU_PCORNER
  `define SNPS_D3X_PEND_NS               DWC_D4MU_PEND_NS

  `define SNPS_D3X_PSCAP_GEN_NS          DWC_D4MU_PSNAPCAP_NS
  `define SNPS_D3X_PSCAP_PDIFF_NS        DWC_D4MU_PSNAPCAP_PDIFF_NS
  `define SNPS_D3X_PSCAP_VDDQ_NS         DWC_D4MU_PSNAPCAP_NS
  `define SNPS_D3X_PSCAP_VSSQ_NS         DWC_D4MU_PSNAPCAP_NS
  `define SNPS_D3X_PSCAP_FILLT1_NS       DWC_D4MU_PSNAPCAP_FILL1_NS
  `define SNPS_D3X_PSCAP_FILLT2_NS       DWC_D4MU_PSNAPCAP_FILL5_NS
  `define SNPS_D3X_PSCAP_FILLT3_NS       DWC_D4MU_PSNAPCAP_FILL20_NS
  `define SNPS_D3X_PSCAP_FILLT4_NS       DWC_D4MU_PSNAPCAP_FILL20_NS
  `define SNPS_D3X_PSCAP_FILLISOT1_NS    DWC_D4MU_PSNAPCAP_FILL20_ISO_MVDDQ_NS
  `define SNPS_D3X_PSCAP_FILLISOT2_NS    DWC_D4MU_PSNAPCAP_FILL20_ISO_MVDDQ_NS
  `define SNPS_D3X_PSCAP_END_NS          DWC_D4MU_PSNAPCAP_END_NS

  `define SNPS_D3X_PPADCWO_GEN_NS        DWC_D4MU_PPADCUPWCAPOUT_NS
  `define SNPS_D3X_PPADCWI_GEN_NS        DWC_D4MU_PPADCUPWCAPIN_NS
  `define SNPS_D3X_PPADCWO_VDDQ_NS       DWC_D4MU_PPADCUPWCAPOUT_NS
  `define SNPS_D3X_PPADCWI_VDDQ_NS       DWC_D4MU_PPADCUPWCAPIN_NS
  `define SNPS_D3X_PPADCWO_VSSQ_NS       DWC_D4MU_PPADCUPWCAPOUT_NS
  `define SNPS_D3X_PPADCWI_VSSQ_NS       DWC_D4MU_PPADCUPWCAPIN_NS
  `define SNPS_D3X_PPADCW_FILLT1_NS      DWC_D4MU_PPADCUPWCAP_FILL1_NS
  `define SNPS_D3X_PPADCW_FILLT2_NS      DWC_D4MU_PPADCUPWCAP_FILL5_NS
  `define SNPS_D3X_PPADCW_FILLT3_NS      DWC_D4MU_PPADCUPWCAP_FILL20_NS
  `define SNPS_D3X_PPADCW_FILLT4_NS      DWC_D4MU_PPADCUPWCAP_FILL20_NS
  `define SNPS_D3X_PPADCW_FILLISOT1_NS   DWC_D4MU_PPADCUPWCAP_FILL20_ISO_MVDDQ_NS
  `define SNPS_D3X_PPADCW_FILLISOT2_NS   DWC_D4MU_PPADCUPWCAP_FILL20_ISO_MVDDQ_NS
  `define SNPS_D3X_PPADCW_END_NS         DWC_D4MU_PPADCUPWCAP_END_NS

  `define SNPS_D3X_PRETPOCX_EW           DWC_D4MU_PRETPOCX_EW
  `define SNPS_D3X_PRETPOCC_EW           DWC_D4MU_PRETPOCC_PADVSS_EW
  `define SNPS_D3X_PVAA_PLL_EW           DWC_D4MU_PVAA_PLL_EW
  `define SNPS_D3X_PVSS_PLL_EW           DWC_D4MU_PVSS_PLL_EW
  `define SNPS_D3X_PVAA_EW               DWC_D4MU_PVAA_EW    
  `define SNPS_D3X_PVSS_CAP_EW           DWC_D4MU_PVSS_CAP_EW
  `define SNPS_D3X_PVSS_ESD_EW           DWC_D4MU_PVSS_ESD_EW
  `define SNPS_D3X_PVDD_CAP_EW           DWC_D4MU_PVDD_CAP_EW
  `define SNPS_D3X_PVDDQ_ESD_EW          DWC_D4MU_PVDDQ_ESD_EW
  `define SNPS_D3X_PVDDQ_CAP_EW          DWC_D4MU_PVDDQ_CAP_EW
  `define SNPS_D3X_PVSSQ_EW              DWC_D4MU_PVSSQ_EW
  `define SNPS_D3X_PZB_EW                DWC_D4MU_PVSS_ESD_ISO_ZIOH_EW
  `define SNPS_D3X_PZB_ZQ_EW             DWC_D4MU_PVSS_ESD_ISO_ZIOHMVREF_EW

  `define SNPS_D3X_PFILLT1_EW            DWC_D4MU_PFILL1_EW
  `define SNPS_D3X_PFILLT2_EW            DWC_D4MU_PFILL5_EW
  `define SNPS_D3X_PFILLT3_EW            DWC_D4MU_PFILL20_EW
  `define SNPS_D3X_PFILLT4_EW            DWC_D4MU_PFILL20_EW
  `define SNPS_D3X_PFILLISOT1_EW         DWC_D4MU_PFILL20_ISO_MVDDQLENH_EW
  `define SNPS_D3X_PFILLISOT2_EW         DWC_D4MU_PFILL20_ISO_MVDDQ_EW
  `define SNPS_D3X_PCORNER_EW            DWC_D4MU_PCORNER
  `define SNPS_D3X_PEND_EW               DWC_D4MU_PEND_EW

  `define SNPS_D3X_PSCAP_GEN_EW          DWC_D4MU_PSNAPCAP_EW
  `define SNPS_D3X_PSCAP_PDIFF_EW        DWC_D4MU_PSNAPCAP_PDIFF_EW
  `define SNPS_D3X_PSCAP_VDDQ_EW         DWC_D4MU_PSNAPCAP_EW
  `define SNPS_D3X_PSCAP_VSSQ_EW         DWC_D4MU_PSNAPCAP_EW
  `define SNPS_D3X_PSCAP_FILLT1_EW       DWC_D4MU_PSNAPCAP_FILL1_EW
  `define SNPS_D3X_PSCAP_FILLT2_EW       DWC_D4MU_PSNAPCAP_FILL5_EW
  `define SNPS_D3X_PSCAP_FILLT3_EW       DWC_D4MU_PSNAPCAP_FILL20_EW
  `define SNPS_D3X_PSCAP_FILLT4_EW       DWC_D4MU_PSNAPCAP_FILL20_EW
  `define SNPS_D3X_PSCAP_FILLISOT1_EW    DWC_D4MU_PSNAPCAP_FILL20_ISO_MVDDQ_EW
  `define SNPS_D3X_PSCAP_FILLISOT2_EW    DWC_D4MU_PSNAPCAP_FILL20_ISO_MVDDQ_EW
  `define SNPS_D3X_PSCAP_END_EW          DWC_D4MU_PSNAPCAP_END_EW

  `define SNPS_D3X_PPADCWO_GEN_EW        DWC_D4MU_PPADCUPWCAPOUT_EW
  `define SNPS_D3X_PPADCWI_GEN_EW        DWC_D4MU_PPADCUPWCAPIN_EW
  `define SNPS_D3X_PPADCWO_VDDQ_EW       DWC_D4MU_PPADCUPWCAPOUT_EW
  `define SNPS_D3X_PPADCWI_VDDQ_EW       DWC_D4MU_PPADCUPWCAPIN_EW
  `define SNPS_D3X_PPADCWO_VSSQ_EW       DWC_D4MU_PPADCUPWCAPOUT_EW
  `define SNPS_D3X_PPADCWI_VSSQ_EW       DWC_D4MU_PPADCUPWCAPIN_EW
  `define SNPS_D3X_PPADCW_FILLT1_EW      DWC_D4MU_PPADCUPWCAP_FILL1_EW
  `define SNPS_D3X_PPADCW_FILLT2_EW      DWC_D4MU_PPADCUPWCAP_FILL5_EW
  `define SNPS_D3X_PPADCW_FILLT3_EW      DWC_D4MU_PPADCUPWCAP_FILL20_EW
  `define SNPS_D3X_PPADCW_FILLT4_EW      DWC_D4MU_PPADCUPWCAP_FILL20_EW
  `define SNPS_D3X_PPADCW_FILLISOT1_EW   DWC_D4MU_PPADCUPWCAP_FILL20_ISO_MVDDQ_EW
  `define SNPS_D3X_PPADCW_FILLISOT2_EW   DWC_D4MU_PPADCUPWCAP_FILL20_ISO_MVDDQ_EW
  `define SNPS_D3X_PPADCW_END_EW         DWC_D4MU_PPADCUPWCAP_END_EW

  // these cells are not present or named differently in this I/O library
  // and need definitions to minimize number of ifdefs in the code;
`endif


//-----------------------------------------------------------------------------
// Miscellaneous Global Definitions
//-----------------------------------------------------------------------------
// Global definitions

// BDL delay select width
`define DWC_BDL_DLY_WIDTH 5

// macros to define the controller data rate for the CTL-PUB DFI interface
`ifdef DWC_DDRPHY_CSDR_ONLY
  `define DWC_DDRPHY_CSDR_EN
  `define DWC_DDRPHY_SDR_ONLY
  `define DWC_DDRPHY_PHDR_EN 1
  `define DWC_DDRPHY_CHDR_EN 0
  `define DWC_DDRPHY_CDR_EN  1
`elsif DWC_DDRPHY_HDR_ONLY
  `define DWC_DDRPHY_PHDR_EN 1
  `define DWC_DDRPHY_CHDR_EN 1
  `define DWC_DDRPHY_CDR_EN  2
`else
  `define DWC_DDRPHY_CSDR_EN
  `define DWC_DDRPHY_PHDR_EN 1
  `define DWC_DDRPHY_CHDR_EN 1
  `define DWC_DDRPHY_CDR_EN  3
`endif

  
// Module Names and Derived Parameters
// -----------------------------------
`ifdef DWC_DDRPHY_ACX48
  `define DWC_DDRPHYAC DWC_DDRPHYACX48
  `define DWC_MAX_CKE_WIDTH   8
  `define DWC_MAX_ODT_WIDTH   8
  `define DWC_MAX_CS_N_WIDTH  12
`else
  `define DWC_DDRPHYAC DWC_DDRPHYAC
  `define DWC_MAX_CKE_WIDTH   4
  `define DWC_MAX_ODT_WIDTH   4
  `define DWC_MAX_CS_N_WIDTH  4
`endif

`ifdef DWC_DDRPHY_TYPEB
  `ifdef DWC_DDRPHY_X8_ONLY
    `define DWC_DDRPHYDATX8 DWC_DDRPHYDATX4X2
    `define DWC_DX_NO_OF_DQS 1
    `define DWC_DX_NO_OF_VREF 1
  `elsif DWC_DDRPHY_X4X2
    `define DWC_DDRPHYDATX8 DWC_DDRPHYDATX4X2
    `define DWC_DX_NO_OF_DQS 2
    `define DWC_DX_NO_OF_VREF 2
  `else
    `define DWC_DDRPHYDATX8 DWC_DDRPHYDATX8
    `define DWC_DX_NO_OF_DQS 1
    `define DWC_DX_NO_OF_VREF 1
  `endif
`else
  `define DWC_DDRPHYDATX8 DWC_DDRPHYDATX8
  `define DWC_DX_NO_OF_DQS 1
  `define DWC_DX_NO_OF_VREF 1
`endif
`define DWC_DDRPHYPLL_EW DWC_DDRPHYPLL_EW
`define DWC_DDRPHYPLL_NS DWC_DDRPHYPLL_NS

`define DWC_DDRPHYCK     DWC_DDRPHYCK
`define DWC_DDRPHYCKVREG DWC_DDRPHYCKVREG_EW
    
// for X4X2 && DMDQS MUX && NOT X8_ONLY, a mix of PDIFFC/PDIFFT cells are used  
// (if available) otherwise, everything else uses PDIFF pad cells        
`ifdef DWC_DDRPHY_X4X2    
  `ifdef DWC_DDRPHY_DMDQS_MUX
    `ifndef DWC_DDRPHY_X8_ONLY 
      `define SNPS_D3X_PDQSIO_NS   `SNPS_D3X_PDIFFT_NS
      `define SNPS_D3X_PDQSNIO_NS  `SNPS_D3X_PDIFFC_NS
      `define SNPS_D3X_PDQSIO_EW   `SNPS_D3X_PDIFFT_EW
      `define SNPS_D3X_PDQSNIO_EW  `SNPS_D3X_PDIFFC_EW
    `else 
      `define SNPS_D3X_PDQSIO_NS   `SNPS_D3X_PDIFF_NS
      `define SNPS_D3X_PDQSNIO_NS  `SNPS_D3X_PDIFF_NS
      `define SNPS_D3X_PDQSIO_EW   `SNPS_D3X_PDIFF_EW
      `define SNPS_D3X_PDQSNIO_EW  `SNPS_D3X_PDIFF_EW
    `endif
  `else
    `define SNPS_D3X_PDQSIO_NS   `SNPS_D3X_PDIFF_NS
    `define SNPS_D3X_PDQSNIO_NS  `SNPS_D3X_PDIFF_NS
    `define SNPS_D3X_PDQSIO_EW   `SNPS_D3X_PDIFF_EW
    `define SNPS_D3X_PDQSNIO_EW  `SNPS_D3X_PDIFF_EW
  `endif
`else
  `define SNPS_D3X_PDQSIO_NS   `SNPS_D3X_PDIFF_NS
  `define SNPS_D3X_PDQSNIO_NS  `SNPS_D3X_PDIFF_NS
  `define SNPS_D3X_PDQSIO_EW   `SNPS_D3X_PDIFF_EW
  `define SNPS_D3X_PDQSNIO_EW  `SNPS_D3X_PDIFF_EW
`endif

// Test Output Pins
// The following two macros are defined to include the ato and dto pins at
// PHY_top if either the AC or DATX8 ATO/DTO pins are included
// Only AC or DATX8 can be included at a time not both

`ifdef DWC_AC_DTO_USE
  `define DWC_PHY_DTO_USE
`elsif DWC_DX_DTO_USE
  `define DWC_PHY_DTO_USE
`endif

`ifdef DWC_AC_ATO_USE
  `define DWC_PHY_ATO_USE
`elsif DWC_DX_ATO_USE
  `define DWC_PHY_ATO_USE
`endif  

// emulation specific configurations
`ifdef DWC_DDRPHY_EMUL_XILINX
  // no impedance calibration in emulation
  `ifdef DWC_DDRPHY_NO_PZQ
  `else 
    `define DWC_DDRPHY_NO_PZQ
  `endif
`endif


// Rank Siganl Widths
// ------------------
// width of CKE, ODT and CS_N pins on each RCD chip    
`define DWC_RCD_CKE_WIDTH    ((`DWC_RCD_MODE == 0) ? 0 : 2)
`define DWC_RCD_ODT_WIDTH    ((`DWC_RCD_MODE == 0) ? 0 : 2)
`define DWC_RCD_CS_N_WIDTH   ((`DWC_RCD_MODE == 0) ? 0 : \
                              (`DWC_RCD_MODE == 1) ? 2 : \
                              (`DWC_RCD_MODE == 2) ? 4 : \
                              (`DWC_RCD_MODE == 3) ? 3 : 0)

// number of RCD chips used
`define DWC_NO_OF_RCD        ((`DWC_RCD_MODE == 0) ? 0                    : \
                              (`DWC_RCD_MODE == 1) ? `DWC_NO_OF_RANKS / 2 : \
                              (`DWC_RCD_MODE == 2) ? `DWC_NO_OF_RANKS / 4 : \
                              (`DWC_RCD_MODE == 3) ? `DWC_NO_OF_RANKS / 4 : \
                                                        0)

// width of CKE, ODT, and CS_N signal on the PHY (going to the DRAM system)
`define DWC_PHY_CKE_WIDTH    ((`DWC_RCD_MODE == 0) ? `DWC_NO_OF_RANKS : (`DWC_RCD_CKE_WIDTH  * `DWC_NO_OF_RCD))
`define DWC_PHY_ODT_WIDTH    ((`DWC_RCD_MODE == 0) ? `DWC_NO_OF_RANKS : (`DWC_RCD_ODT_WIDTH  * `DWC_NO_OF_RCD))
`define DWC_PHY_CS_N_WIDTH   ((`DWC_RCD_MODE == 0) ? `DWC_NO_OF_RANKS : (`DWC_RCD_CS_N_WIDTH * `DWC_NO_OF_RCD))

// width of CID signals
`ifdef DWC_NO_OF_3DS_STACKS 
  `define DWC_CID_WIDTH        ((`DWC_NO_OF_3DS_STACKS == 8) ? 3 : \
                                (`DWC_NO_OF_3DS_STACKS == 4) ? 2 : \
                                (`DWC_NO_OF_3DS_STACKS == 2) ? 1 : 1)

// number of logical ranks
  `define DWC_NO_OF_LRANKS     ((`DWC_NO_OF_3DS_STACKS == 0) ? `DWC_NO_OF_RANKS : (`DWC_NO_OF_RANKS * `DWC_NO_OF_3DS_STACKS))
`else
  `define DWC_CID_WIDTH        1
  `define DWC_NO_OF_LRANKS     `DWC_NO_OF_RANKS
`endif

//-----------------------------------------------------------------------------
// Version Definitions
//-----------------------------------------------------------------------------
`define DWC_DDRPHY_PUB_VER_0_00


//-----------------------------------------------------------------------------
// Custom pin mapping
//-----------------------------------------------------------------------------

//`define DWC_CUSTOM_PIN_MAP

`define  DWC_A17_INDX        1
`define  DWC_A16_INDX        2
`define  DWC_A15_INDX        3
`define  DWC_A14_INDX        4
`define  DWC_ACTN_INDX       5
`define  DWC_BG1_INDX        6

//default mapping as follows; change this section to customize the mapping.
//Make sure all DDR32 macros are assigned to different DDR4 indexes!
//`define  DWC_DDR32_CAS_MAP   `DWC_A17_INDX
//`define  DWC_DDR32_WE_MAP    `DWC_A16_INDX
//`define  DWC_DDR32_A15_MAP   `DWC_A15_INDX
//`define  DWC_DDR32_A14_MAP   `DWC_A14_INDX
//`define  DWC_DDR32_RAS_MAP   `DWC_ACTN_INDX

`define  DWC_DDR32_CAS_MAP   `DWC_A15_INDX
`define  DWC_DDR32_WE_MAP    `DWC_A14_INDX
`define  DWC_DDR32_A15_MAP   `DWC_ACTN_INDX
`define  DWC_DDR32_A14_MAP   `DWC_BG1_INDX
`define  DWC_DDR32_RAS_MAP   `DWC_A16_INDX
