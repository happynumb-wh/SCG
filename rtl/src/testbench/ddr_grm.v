/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys Inc. All rights reserved.                      *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR Controller Golden Reference Model                         *
 *              Generates expected data for DDR controller                    *
 *                                                                            *
 *****************************************************************************/

module ddr_grm (
                rst_b,    // asynchronous reset
                clk       // clock
                );
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
`ifdef CTL_CAL_CLK_USE
  localparam pACCTLCALCLK_FACTOR    = 4;
  localparam pDXCTLCALCLK_FACTOR    = 4;
`else  
  localparam pACCTLCALCLK_FACTOR    = 1;
  localparam pDXCTLCALCLK_FACTOR    = 1;
`endif

  // Width of the ACIOCR register fields.  Set according to `DWC_ADDR_WIDTH,
  // but with a floor of 14 to match the RTL's implementation of the ACIOCR register widths.
  parameter ACIOCR_ADDR_WIDTH = (`DWC_ADDR_WIDTH < 16) ? 16 : `DWC_ADDR_WIDTH;

  // width of the read data FIFO: includes data + BLOTF flag
  // depth of command queue depends on commands that may be pre-issued plus the
  // latency of execution times chip-logic maximum burst length (little bit
  // overdesign!)
  parameter FIFO_WIDTH          = `DATA_WIDTH + 1;
  parameter FIFO_DEPTH          = 2048;
  parameter FIFO_ADDR_WIDTH     = 16;

  // width of the register data FIFO: includes data, register address
  // depth of command queue depends on the latency of execution
  // (+ little bit overdesign!)
  parameter REG_FIFO_WIDTH      = `REG_ADDR_WIDTH+`REG_DATA_WIDTH,
            REG_FIFO_DEPTH      = 64,
            REG_FIFO_ADDR_WIDTH = 6;

  // maximum accesses per host (used for out-of-order results)
  parameter MAX_ACCESSES        = 256;
  parameter MAX_HOST_BURSTS     = 4*MAX_ACCESSES; // max is BL of 8

  // width to cater for actual address width components (rank, bank, row, col)
  parameter ADDR_WIDTH          = `SDRAM_RANK_WIDTH +
            `SDRAM_BANK_WIDTH +
            `SDRAM_ROW_WIDTH +
            `SDRAM_COL_WIDTH;

  parameter pNO_OF_DX_DQS     = `DWC_DX_NO_OF_DQS; // number of DQS signals per DX macro
  parameter pNUM_LANES        = pNO_OF_DX_DQS * `DWC_NO_OF_BYTES;
    
  // width of memory word to cater for all componets of the controller data
  // word
  parameter MEM_WORD_WIDTH      = `HOST_NX*`MEM_WIDTH;
  parameter VLD_DATA_WIDTH      = 2*`CLK_NX*`DWC_DATA_WIDTH;
  parameter PUB_MEM_WORD_WIDTH  = `PUB_HOST_NX*`MEM_WIDTH;
  parameter PUB_VLD_DATA_WIDTH  = 2*`PUB_CLK_NX*`DWC_DATA_WIDTH;

  // timing parameters width
  parameter tMRD_WIDTH       = 5,
            tMOD_WIDTH       = 5,
            tRP_WIDTH        = 7,
            tRFC_WIDTH       = 10,
            tWTR_WIDTH       = 5,
            tRCD_WIDTH       = 7,
            tRC_WIDTH        = 8,
            tRTP_WIDTH       = 5,
           `ifdef LPDDR3
            tRPA_WIDTH       = tRP_WIDTH+1,
           `elsif LPDDR2
            tRPA_WIDTH       = tRP_WIDTH+1,
           `else
            tRPA_WIDTH       = tRP_WIDTH,
           `endif
            tRRD_WIDTH       = 6,
            tFAW_WIDTH       = 8,
            tRAS_WIDTH       = 7,
            tBCSTAB_WIDTH    = 14,
            tBCMRD_WIDTH     = 4,
            tRFPRD_WIDTH     = 17;
  
  // derived timing parameters width
  parameter CL_WIDTH         = 6,
            tWR_WIDTH        = 5,
            WL_WIDTH         = 6,
            RL_WIDTH         = 6,
            tACT2RW_WIDTH    = 5,
            tWR2PRE_WIDTH    = 7,
            tWRL_WIDTH       = 6,
            tOL_WIDTH        = 4,
            tRD2PRE_WIDTH    = 7,
            tRD2WR_WIDTH     = 5,
            tWR2RD_WIDTH     = 6,
            tCCD_WIDTH       = 4;


  parameter TOTAL_LANES      = `DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS*`DWC_NO_OF_LRANKS;

  // ZQ calibration types
  parameter ZOUT_PD  = 2'b00; // output impedance pull down
  parameter ZOUT_PU  = 2'b01; // output impedance pull up
  parameter ODT_PD   = 2'b10; // on-die termination pull down
  parameter ODT_PU   = 2'b11; // on-die termination pull up

  parameter ZOUT_CAL = 1'b0;  // output impedance calibration
  parameter ODT_CAL  = 1'b1;  // on-die termination calibration

  
  // DCU widths
  // ----------
  // cache word addresses
  parameter CCACHE_ADDR_WIDTH = (`CCACHE_DEPTH == 16) ? 4 :
                                (`CCACHE_DEPTH == 8)  ? 3 :
                                                        2;
  parameter RCACHE_ADDR_WIDTH = (`RCACHE_DEPTH == 16) ? 4 :
                                (`RCACHE_DEPTH == 8)  ? 3 :
                                                        2;
  parameter ECACHE_ADDR_WIDTH = (`ECACHE_DEPTH == 16) ? 4 :
                                (`ECACHE_DEPTH == 8)  ? 3 :
                                                        2;

  // cache slice addresses
  parameter CCACHE_SLICE_ADDR_WIDTH = (`CCACHE_SLICES > 8) ? 4 :
                                      (`CCACHE_DEPTH  > 4) ? 3 :
                                      (`CCACHE_DEPTH  > 2) ? 2 :
                                                             1;
  parameter RCACHE_SLICE_ADDR_WIDTH = (`RCACHE_SLICES > 8) ? 4 :
                                      (`RCACHE_DEPTH  > 4) ? 3 :
                                      (`RCACHE_DEPTH  > 2) ? 2 :
                                                             1;
  parameter ECACHE_SLICE_ADDR_WIDTH = (`ECACHE_SLICES > 8) ? 4 :
                                      (`ECACHE_DEPTH  > 4) ? 3 :
                                      (`ECACHE_DEPTH  > 2) ? 2 :
                                                             1;

  
  // DCU timing
  // ----------
  // slow clock latency of: 
  //   - run/stop command issue to the command being recognized
  // internally (CFCLK clocks), and latency from this point to when the command
  // executes on the crossed (fast) clock domain
  parameter tDCU_CMD_TO_RUN   = 5,
            tDCU_CMD_TO_STOP  = 3,
            tDCU_CMD_TO_CFG   = 4;
  
  // fast clock latency of: 
  //   - when run/stop command internally recognized (on slow clock) to when 
  //     the command executes on the crossed (fast) clock domain
`ifdef SDF_ANNOTATE
  `ifdef SLOW_SDF
  parameter tDCU_RUN_TO_EXEC  = 3,
            tDCU_STOP_TO_EXEC = 2,
            tDCU_CFG_TO_EXE   = 3;
  `else // FAST_SDF           
  parameter tDCU_RUN_TO_EXEC  = 3,
            tDCU_STOP_TO_EXEC = 2,
            tDCU_CFG_TO_EXE   = 3;
  `endif                      
`else                         
  parameter tDCU_RUN_TO_EXEC  = 2,
            tDCU_STOP_TO_EXEC = 1,
            tDCU_CFG_TO_EXE   = 2;
`endif

  // fail flag latency
  parameter FAIL_FLAG_LAT   = 5;
// Emulation parameters
`ifdef DWC_DDRPHY_EMUL_XILINX
    // Parameters for calibration and status
  parameter      pDQ_DELAY_WIDTH  = 5 ;
  parameter      pQ_WINDOW_WIDTH  = 4 ;
`endif        



// command lane share PLL with a byte lane
  parameter pAC_PLL_SHARE      = (`DWC_DX_AC_PLL_SHARE) ? 1 : 0;


  // Changed how num of channels is calculated for Gen2.
  // parameter      pSHARED_AC        = ((`DWC_NO_OF_BYTES > 1) && (`DWC_NO_OF_RANKS > 1));
`ifdef DWC_USE_SHARED_AC_TB
  parameter      pSHARED_AC        = 1;
`else
  parameter      pSHARED_AC        = 0;
`endif
  parameter      pNO_OF_BYTES      = `DWC_NO_OF_BYTES;
  parameter      pCHN0_DX8_NUM     = `DWC_NO_OF_BYTES/2  - (`DWC_NO_OF_BYTES % 2)/2;
  parameter      pCHN1_DX8_NUM     = (`DWC_NO_OF_BYTES - pCHN0_DX8_NUM);   
  parameter      pNO_OF_PRANKS     = `DWC_NO_OF_RANKS;     //Number of physical ranks
  parameter      pNO_OF_LRANKS     = `DWC_NO_OF_LRANKS;    //Number of logical ranks
  parameter      pLFSR_POLY        = 32'h80000CEC;
  parameter      pMAX_NO_OF_DIMMS     = 4;   
  
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input     rst_b;           // asynshronous reset
  input     clk;             // clock    

  
  //---------------------------------------------------------------------------
  // Local Parameters
  //---------------------------------------------------------------------------
  localparam pDGSL_WIDTH = 5;
  localparam pWLSL_WIDTH = 4;

  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------

  // DDR SDRAM arrays: associative arrays to reduce number of static memory
  // required (set the maximum number of unique locations expected to be used
  // when the GRM is to be turned on
  reg [`MEM_WIDTH-1:0] ddr_sdram [0:`MAX_MEM_LOCATIONS-1];
  reg [ADDR_WIDTH-1:0] ddr_addr  [0:`MAX_MEM_LOCATIONS-1];

  integer              mem_index;
  integer              mem_used;
  integer              i;
  reg                  mem_found;
  integer              active_bytes;
  reg [`DWC_DATA_WIDTH-1:0] data_mask;
  
  // read data FIFOs
  //reg [FIFO_WIDTH-1:0]      fifo [0:FIFO_DEPTH-1];
  //reg [FIFO_ADDR_WIDTH-1:0] fifo_wrptr;
  //reg [FIFO_ADDR_WIDTH-1:0] fifo_rdptr;
  // read data FIFOs
  reg [FIFO_WIDTH-1:0]      ch0_fifo [0:FIFO_DEPTH-1];
  reg [FIFO_ADDR_WIDTH-1:0] ch0_fifo_wrptr;
  reg [FIFO_ADDR_WIDTH-1:0] ch0_fifo_rdptr;
  
  reg [FIFO_WIDTH-1:0]      ch1_fifo [0:FIFO_DEPTH-1];
  reg [FIFO_ADDR_WIDTH-1:0] ch1_fifo_wrptr;
  reg [FIFO_ADDR_WIDTH-1:0] ch1_fifo_rdptr;
  reg                       read_pending;
  
  // register data FIFOs
  reg [REG_FIFO_WIDTH-1:0]  reg_fifo [0:REG_FIFO_DEPTH-1];
  reg [REG_FIFO_ADDR_WIDTH-1:0] reg_fifo_wrptr;
  reg [REG_FIFO_ADDR_WIDTH-1:0] reg_fifo_rdptr;

  // PHY registers
  reg [`REG_DATA_WIDTH-1:0]     ridr;      // revision ID register
  reg [`REG_DATA_WIDTH-1:0]     pir;       // PHY initialization register
  reg [`REG_DATA_WIDTH-1:0]     cgcr;      // revision ID register
  reg [`REG_DATA_WIDTH-1:0]     cgcr1;     // Clock Gating Configuration Register 1
  reg [`REG_DATA_WIDTH-1:0]     pgcr0;     // PHY control general register 0
  reg [`REG_DATA_WIDTH-1:0]     pgcr1;     // PHY control general register 1
  reg [`REG_DATA_WIDTH-1:0]     pgcr2;     // PHY control general register 2
  reg [`REG_DATA_WIDTH-1:0]     pgcr3;     // PHY control general register 3
  reg [`REG_DATA_WIDTH-1:0]     pgcr4;     // PHY control general register 4
  reg [`REG_DATA_WIDTH-1:0]     pgcr5;     // PHY control general register 5
  reg [`REG_DATA_WIDTH-1:0]     pgcr6;     // PHY control general register 6
  reg [`REG_DATA_WIDTH-1:0]     pgcr7;     // PHY control general register 7
  reg [`REG_DATA_WIDTH-1:0]     pgcr8;     // PHY control general register 8
  reg [`REG_DATA_WIDTH-1:0]     pgsr0;     // PHY status register 0
  reg [`REG_DATA_WIDTH-1:0]     pgsr1;     // PHY status register 1
`ifdef DWC_DDRPHY_PLL_TYPEB
  reg [`REG_DATA_WIDTH-1:0]     pllcr;     // PLL control register (same as pllcr0)
  reg [`REG_DATA_WIDTH-1:0]     pllcr0;    // PLL control register 0
  reg [`REG_DATA_WIDTH-1:0]     pllcr1;    // PLL control register 1
  reg [`REG_DATA_WIDTH-1:0]     pllcr2;    // PLL control register 2
  reg [`REG_DATA_WIDTH-1:0]     pllcr3;    // PLL control register 3
  reg [`REG_DATA_WIDTH-1:0]     pllcr4;    // PLL control register 4
  reg [`REG_DATA_WIDTH-1:0]     pllcr5;    // PLL control register 5
`else
  reg [`REG_DATA_WIDTH-1:0]     pllcr;     // PLL control register
`endif
  reg [`REG_DATA_WIDTH-1:0]     ptr0;      // PHY timing register 0
  reg [`REG_DATA_WIDTH-1:0]     ptr1;      // PHY timing register 1
  reg [`REG_DATA_WIDTH-1:0]     ptr2;      // PHY timing register 2
  reg [`REG_DATA_WIDTH-1:0]     ptr3;      // PHY timing register 3
  reg [`REG_DATA_WIDTH-1:0]     ptr4;      // PHY timing register 4
  reg [`REG_DATA_WIDTH-1:0]     ptr5;      // PHY timing register 5
  reg [`REG_DATA_WIDTH-1:0]     ptr6;      // PHY timing register 6
  reg [`REG_DATA_WIDTH-1:0]     acmdlr0;   // AC master delay line register 0
  reg [`REG_DATA_WIDTH-1:0]     acmdlr1;   // AC master delay line register 1
  reg [`REG_DATA_WIDTH-1:0]     aclcdlr;   // AC LCDL register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr0;   // AC BDL0 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr1;   // AC BDL1 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr2;   // AC BDL2 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr3;   // AC BDL3 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr4;   // AC BDL4 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr5;   // AC BDL5 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr6;   // AC BDL6 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr7;   // AC BDL7 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr8;   // AC BDL8 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr9;   // AC BDL9 register
  reg [`REG_DATA_WIDTH-1:0]     acbdlr10;  // AC BDL10 register  
  reg [`REG_DATA_WIDTH-1:0]     acbdlr11;  // AC BDL11 register  
  reg [`REG_DATA_WIDTH-1:0]     acbdlr12;  // AC BDL12 register  
  reg [`REG_DATA_WIDTH-1:0]     acbdlr13;  // AC BDL13 register  
  reg [`REG_DATA_WIDTH-1:0]     acbdlr14;  // AC BDL14 register  
  reg [`REG_DATA_WIDTH-1:0]     rankidr;   // Rank ID register
  reg [`REG_DATA_WIDTH-1:0]     riocr0;    // Rank I/O0 configuration register
  reg [`REG_DATA_WIDTH-1:0]     riocr1;    // Rank I/O1 configuration register
  reg [`REG_DATA_WIDTH-1:0]     riocr2;    // Rank I/O2 configuration register
  reg [`REG_DATA_WIDTH-1:0]     riocr3;    // Rank I/O3 configuration register
  reg [`REG_DATA_WIDTH-1:0]     riocr4;    // Rank I/O4 configuration register
  reg [`REG_DATA_WIDTH-1:0]     riocr5;    // Rank I/O5 configuration register
  reg [`REG_DATA_WIDTH-1:0]     aciocr0;   // AC I/O0 configuration register
  reg [`REG_DATA_WIDTH-1:0]     aciocr1;   // AC I/O1 configuration register
  reg [`REG_DATA_WIDTH-1:0]     aciocr2;   // AC I/O2 configuration register
  reg [`REG_DATA_WIDTH-1:0]     aciocr3;   // AC I/O3 configuration register
  reg [`REG_DATA_WIDTH-1:0]     aciocr4;   // AC I/O4 configuration register
  reg [`REG_DATA_WIDTH-1:0]     aciocr5;   // AC I/O5 configuration register
  reg [`REG_DATA_WIDTH-1:0]     dxccr;     // DX Common configuration register
  reg [`REG_DATA_WIDTH-1:0]     dsgcr;     // DDR System genaral configuration register
  reg [`REG_DATA_WIDTH-1:0]     dcr;       // DRAM config register
  reg [`REG_DATA_WIDTH-1:0]     dtpr0;     // DRAM timing parameters register 0
  reg [`REG_DATA_WIDTH-1:0]     dtpr1;     // DRAM timing parameters register 1
  reg [`REG_DATA_WIDTH-1:0]     dtpr2;     // DRAM timing parameters register 2
  reg [`REG_DATA_WIDTH-1:0]     dtpr3;     // DRAM timing parameters register 3
  reg [`REG_DATA_WIDTH-1:0]     dtpr4;     // DRAM timing parameters register 4
  reg [`REG_DATA_WIDTH-1:0]     dtpr5;     // DRAM timing parameters register 5
  reg [`REG_DATA_WIDTH-1:0]     dtpr6;     // DRAM timing parameters register 6
  reg [`REG_DATA_WIDTH-1:0]     schcr0;    // scheduler command register 0
  reg [`REG_DATA_WIDTH-1:0]     schcr1;    // scheduler command register 1
  reg [`REG_DATA_WIDTH-1:0]     mr0;       // mode register 0
  reg [`REG_DATA_WIDTH-1:0]     mr1     [pNO_OF_PRANKS-1:0]; // mode register 1
  reg [`REG_DATA_WIDTH-1:0]     mr2     [pNO_OF_PRANKS-1:0]; // mode register 2
  reg [`REG_DATA_WIDTH-1:0]     mr3     [pNO_OF_PRANKS-1:0]; // mode register 3
  reg [`REG_DATA_WIDTH-1:0]     mr4;       // mode register 4
  reg [`REG_DATA_WIDTH-1:0]     mr5     [pNO_OF_PRANKS-1:0]; // mode register 5
  reg [`REG_DATA_WIDTH-1:0]     mr6     [pNO_OF_PRANKS-1:0]; // mode register 6
  reg [`REG_DATA_WIDTH-1:0]     mr7;       // mode register 7
  reg [`REG_DATA_WIDTH-1:0]     mr11    [pNO_OF_PRANKS-1:0]; // mode register 7
  reg [`REG_DATA_WIDTH-1:0]     odtcr   [pNO_OF_PRANKS-1:0];     // ODT configuration register
  reg [`REG_DATA_WIDTH-1:0]     aacr;      // anti-aging configuration register
  reg [`REG_DATA_WIDTH-1:0]     dtcr0;     // data training configuration register
  reg [`REG_DATA_WIDTH-1:0]     dtcr1;     // data training configuration register 1
  reg [`REG_DATA_WIDTH-1:0]     dtar0;     // data training address register 0
  reg [`REG_DATA_WIDTH-1:0]     dtar1;     // data training address register 1
  reg [`REG_DATA_WIDTH-1:0]     dtar2;     // data training address register 2
  reg [`REG_DATA_WIDTH-1:0]     dtar3;     // data training address register 3
  reg [`REG_DATA_WIDTH-1:0]     dtdr0;     // data training data register 0
  reg [`REG_DATA_WIDTH-1:0]     dtdr1;     // data training data register 1
  reg [`REG_DATA_WIDTH-1:0]     uddr0;     // user defined data register 0
  reg [`REG_DATA_WIDTH-1:0]     uddr1;     // user defined data register 1
  reg [`REG_DATA_WIDTH-1:0]     dtedr0;    // data training eye data register 0
  reg [`REG_DATA_WIDTH-1:0]     dtedr1;    // data training eye data register 1
  reg [`REG_DATA_WIDTH-1:0]     vtdr;      // VREF training data register

  // RDIMM Registers
  reg [`REG_DATA_WIDTH-1:0]     rdimmgcr0;
  reg [`REG_DATA_WIDTH-1:0]     rdimmgcr1;
  reg [`REG_DATA_WIDTH-1:0]     rdimmgcr2;
  reg [`REG_DATA_WIDTH-1:0]     rdimmcr0   [pMAX_NO_OF_DIMMS - 1:0];
  reg [`REG_DATA_WIDTH-1:0]     rdimmcr1   [pMAX_NO_OF_DIMMS - 1:0];
  reg [`REG_DATA_WIDTH-1:0]     rdimmcr2   [pMAX_NO_OF_DIMMS - 1:0];
  reg [`REG_DATA_WIDTH-1:0]     rdimmcr3   [pMAX_NO_OF_DIMMS - 1:0];
  reg [`REG_DATA_WIDTH-1:0]     rdimmcr4   [pMAX_NO_OF_DIMMS - 1:0];

  // DCU Registers
  reg [`REG_DATA_WIDTH-1:0]     dcuar;
  reg [`REG_DATA_WIDTH-1:0]     dcudr;
  reg [`REG_DATA_WIDTH-1:0]     dcurr;
  reg [`REG_DATA_WIDTH-1:0]     dculr;
  reg [`REG_DATA_WIDTH-1:0]     dcugcr;
  reg [`REG_DATA_WIDTH-1:0]     dcutpr;
  reg [`REG_DATA_WIDTH-1:0]     dcusr0;
  reg [`REG_DATA_WIDTH-1:0]     dcusr1;
                                
  // BIST Registers             
  reg [`REG_DATA_WIDTH-1:0]     bistrr;
  reg [`REG_DATA_WIDTH-1:0]     bistmskr0;
  reg [`REG_DATA_WIDTH-1:0]     bistmskr1;
  reg [`REG_DATA_WIDTH-1:0]     bistmskr2;
  reg [`REG_DATA_WIDTH-1:0]     bistlsr;
  reg [`REG_DATA_WIDTH-1:0]     bistwcr;
  reg [`REG_DATA_WIDTH-1:0]     bistar0;
  reg [`REG_DATA_WIDTH-1:0]     bistar1;
  reg [`REG_DATA_WIDTH-1:0]     bistar2;
  reg [`REG_DATA_WIDTH-1:0]     bistar3;
  reg [`REG_DATA_WIDTH-1:0]     bistar4;
  reg [`REG_DATA_WIDTH-1:0]     bistudpr;
  reg [`REG_DATA_WIDTH-1:0]     bistgsr;
  reg [`REG_DATA_WIDTH-1:0]     bistwer0;
  reg [`REG_DATA_WIDTH-1:0]     bistwer1;
  reg [`REG_DATA_WIDTH-1:0]     bistber0;
  reg [`REG_DATA_WIDTH-1:0]     bistber1;
  reg [`REG_DATA_WIDTH-1:0]     bistber2;
  reg [`REG_DATA_WIDTH-1:0]     bistber3;
  reg [`REG_DATA_WIDTH-1:0]     bistber4;
  reg [`REG_DATA_WIDTH-1:0]     bistber5;
  reg [`REG_DATA_WIDTH-1:0]     bistwcsr;
  reg [`REG_DATA_WIDTH-1:0]     bistfwr0;
  reg [`REG_DATA_WIDTH-1:0]     bistfwr1;
  reg [`REG_DATA_WIDTH-1:0]     bistfwr2;
  reg [`REG_DATA_WIDTH-1:0]     iovcr0; 
  reg [`REG_DATA_WIDTH-1:0]     iovcr1;
  reg [`REG_DATA_WIDTH-1:0]     vtcr0; 
  reg [`REG_DATA_WIDTH-1:0]     vtcr1; 

  reg [`REG_DATA_WIDTH-1:0]     gpr0;      // general purpose register 0
  reg [`REG_DATA_WIDTH-1:0]     gpr1;      // general purpose register 1

 //CA Training Registers

  reg [`REG_DATA_WIDTH-1:0]    catr0;
  reg [`REG_DATA_WIDTH-1:0]    catr1;  
  reg [`REG_DATA_WIDTH-1:0]    dqsdr0;  
  reg [`REG_DATA_WIDTH-1:0]    dqsdr1;  
  reg [`REG_DATA_WIDTH-1:0]    dqsdr2;  

  reg [`REG_DATA_WIDTH-1:0]     zqcr           ; // Impedance Control Register 
  reg [`REG_DATA_WIDTH-1:0]     zqnpr     [0:3]; // Impedance Controller Program Register
  reg [`REG_DATA_WIDTH-1:0]     zqndr     [0:3]; // Impedance Controller Data Register
  reg [`REG_DATA_WIDTH-1:0]     zqnsr     [0:3]; // Impedance Control Status Register // CHECK
  reg [`REG_DATA_WIDTH-1:0]     dxngcr0   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr1   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr2   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr3   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr4   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr5   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr6   [0:8]; // DATX8 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr7   [0:8]; // DATX4X2 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr8   [0:8]; // DATX4X2 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngcr9   [0:8]; // DATX4X2 general config register
  reg [`REG_DATA_WIDTH-1:0]     dxngsr0   [0:8]; // DATX8 general status register 0
  reg [`REG_DATA_WIDTH-1:0]     dxngsr1   [0:8]; // DATX8 general status register 1
  reg [`REG_DATA_WIDTH-1:0]     dxngsr2   [0:8]; // DATX8 general status register 2
  reg [`REG_DATA_WIDTH-1:0]     dxngsr3   [0:8]; // DATX8 general status register 3
  reg [`REG_DATA_WIDTH-1:0]     dxngsr4   [0:8]; // DATX4X2 general status register 4
  reg [`REG_DATA_WIDTH-1:0]     dxngsr5   [0:8]; // DATX4X2 general status register 5
  reg [`REG_DATA_WIDTH-1:0]     dxngsr6   [0:8]; // DATX4X2 general status register 6
  reg [`REG_DATA_WIDTH-1:0]     dxnrsr0   [0:8]; // DATX8 rank status register 0
  reg [`REG_DATA_WIDTH-1:0]     dxnrsr1   [0:8]; // DATX8 rank status register 1
  reg [`REG_DATA_WIDTH-1:0]     dxnrsr2   [0:8]; // DATX8 rank status register 2
  reg [`REG_DATA_WIDTH-1:0]     dxnrsr3   [0:8]; // DATX8 rank status register 3
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr0  [0:8]; // DATX8 BDL register 0
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr1  [0:8]; // DATX8 BDL register 1
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr2  [0:8]; // DATX8 BDL register 2
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr3  [0:8]; // DATX8 BDL register 3
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr4  [0:8]; // DATX8 BDL register 4
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr5  [0:8]; // DATX8 BDL register 5
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr6  [0:8]; // DATX8 BDL register 6
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr7  [0:8]; // DATX4X2 BDL register 7
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr8  [0:8]; // DATX4X2 BDL register 8
  reg [`REG_DATA_WIDTH-1:0]     dxnbdlr9  [0:8]; // DATX4X2 BDL register 9
  reg [`REG_DATA_WIDTH-1:0]     dxnlcdlr0 [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 0 LCDL register 0
  reg [`REG_DATA_WIDTH-1:0]     dxnlcdlr1 [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 0 LCDL register 1
  reg [`REG_DATA_WIDTH-1:0]     dxnlcdlr2 [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 0 LCDL register 2
  reg [`REG_DATA_WIDTH-1:0]     dxnlcdlr3 [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 0 LCDL register 3
  reg [`REG_DATA_WIDTH-1:0]     dxnlcdlr4 [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 0 LCDL register 4
  reg [`REG_DATA_WIDTH-1:0]     dxnlcdlr5 [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 0 LCDL register 5
  reg [`REG_DATA_WIDTH-1:0]     dxnmdlr0  [0:8]; // DATX8 MDL register 0
  reg [`REG_DATA_WIDTH-1:0]     dxnmdlr1  [0:8]; // DATX8 MDL register 1
  reg [`REG_DATA_WIDTH-1:0]     dxngtr0   [pNO_OF_LRANKS-1:0] [0:8]; // DATX8 general timing register

  reg                           hdr_mode;
  reg                           rr_mode;

  real                          acmdlr_iprd_value;
  real                          acmdlr_tprd_value;
  real                          acmdlr_mdld_value;
  
  real                          acbdlr0_ck0bd_value;
  real                          acbdlr0_ck1bd_value;
  real                          acbdlr0_ck2bd_value;
  real                          acbdlr0_ck3bd_value;

  real                          acbdlr1_actbd_value;
  real                          acbdlr1_a17bd_value;
  real                          acbdlr1_a16bd_value;
  real                          acbdlr1_parbd_value;

  real                          acbdlr2_ba0bd_value;
  real                          acbdlr2_ba1bd_value;
  real                          acbdlr2_ba2bd_value;
  real                          acbdlr2_ba3bd_value;

  real                          acbdlr3_cs0bd_value;
  real                          acbdlr3_cs1bd_value;
  real                          acbdlr3_cs2bd_value;
  real                          acbdlr3_cs3bd_value;

  real                          acbdlr4_odt0bd_value;
  real                          acbdlr4_odt1bd_value;
  real                          acbdlr4_odt2bd_value;
  real                          acbdlr4_odt3bd_value;

  real                          acbdlr5_cke0bd_value;
  real                          acbdlr5_cke1bd_value;
  real                          acbdlr5_cke2bd_value;
  real                          acbdlr5_cke3bd_value;

  real                          acbdlr6_a00bd_value;
  real                          acbdlr6_a01bd_value;
  real                          acbdlr6_a02bd_value;
  real                          acbdlr6_a03bd_value;

  real                          acbdlr7_a04bd_value;
  real                          acbdlr7_a05bd_value;
  real                          acbdlr7_a06bd_value;
  real                          acbdlr7_a07bd_value;

  real                          acbdlr8_a08bd_value;
  real                          acbdlr8_a09bd_value;
  real                          acbdlr8_a10bd_value;
  real                          acbdlr8_a11bd_value;

  real                          acbdlr9_a12bd_value;
  real                          acbdlr9_a13bd_value;
  real                          acbdlr9_a14bd_value;
  real                          acbdlr9_a15bd_value;
  
  real                          acbdlr10_acpddbd_value;    
  real                          acbdlr10_cid0bd_value;   
  real                          acbdlr10_cid1bd_value;   
  real                          acbdlr10_cid2bd_value;  
  
  real                          acbdlr11_cs4bd_value;    
  real                          acbdlr11_cs5bd_value;   
  real                          acbdlr11_cs6bd_value;   
  real                          acbdlr11_cs7bd_value;   
  
  real                          acbdlr12_cs8bd_value;    
  real                          acbdlr12_cs9bd_value;   
  real                          acbdlr12_cs10bd_value;   
  real                          acbdlr12_cs11bd_value; 
  
  real                          acbdlr13_odt4bd_value;    
  real                          acbdlr13_odt5bd_value;   
  real                          acbdlr13_odt6bd_value;   
  real                          acbdlr13_odt7bd_value; 
  
  real                          acbdlr14_cke4bd_value;    
  real                          acbdlr14_cke5bd_value;   
  real                          acbdlr14_cke6bd_value;   
  real                          acbdlr14_cke7bd_value; 

  real                          dxnmdlr_iprd_value  [0:8];
  real                          dxnmdlr_tprd_value  [0:8];
  real                          dxnmdlr_mdld_value  [0:8];
  
  real                          gdqsprd_value [0:8];
  real                          wlprd_value   [0:8];
  real                          x4gdqsprd_value [0:8];
  real                          x4wlprd_value   [0:8];
  
  real                          dq0wbd_value  [0:8];
  real                          dq1wbd_value  [0:8];
  real                          dq2wbd_value  [0:8];
  real                          dq3wbd_value  [0:8];
  real                          dq4wbd_value  [0:8];
  real                          dq5wbd_value  [0:8];
  real                          dq6wbd_value  [0:8];
  real                          dq7wbd_value  [0:8];
  real                          dmwbd_value   [0:8];
  real                          dswbd_value   [0:8];
 
  real                          dq0rbd_value  [0:8];
  real                          dq1rbd_value  [0:8];
  real                          dq2rbd_value  [0:8];
  real                          dq3rbd_value  [0:8];
  real                          dq4rbd_value  [0:8];
  real                          dq5rbd_value  [0:8];
  real                          dq6rbd_value  [0:8];
  real                          dq7rbd_value  [0:8];
  real                          dmrbd_value   [0:8];
  
  real                          dqsoebd_value [0:8];
  real                          dqoebd_value  [0:8];
  real                          dsrbd_value   [0:8];
  real                          dsnrbd_value  [0:8];
  real                          pddbd_value   [0:8]; //DDRG2MPHY: Added these declarations fro Gen2Mphy
  real                          pdrbd_value   [0:8]; //DDRG2MPHY: Added these declarations fro Gen2Mphy   
  real                          terbd_value   [0:8]; //DDRG2MPHY: Added these declarations fro Gen2Mphy
  real                          x4dmwbd_value   [0:8]; // Added these for nibble1 when using X4 config
  real                          x4dswbd_value   [0:8]; // Added these for nibble1 when using X4 config
  real                          x4dqsoebd_value [0:8]; // Added these for nibble1 when using X4 config
  real                          x4dqoebd_value  [0:8]; // Added these for nibble1 when using X4 config
  real                          x4dmrbd_value   [0:8]; // Added these for nibble1 when using X4 config
  real                          x4dsrbd_value   [0:8]; // Added these for nibble1 when using X4 config
  real                          x4dsnrbd_value  [0:8]; // Added these for nibble1 when using X4 config
  real                          x4pddbd_value   [0:8];  // Added these for nibble1 when using X4 config
  real                          x4pdrbd_value   [0:8];  // Added these for nibble1 when using X4 config
  real                          x4terbd_value   [0:8];  // Added these for nibble1 when using X4 config

  real                          wld_value     [pNO_OF_LRANKS-1:0][0:8];
  real                          x4wld_value   [pNO_OF_LRANKS-1:0][0:8]; // Added these for nibble1 when using X4 config
  real                          rdqsd_value   [pNO_OF_LRANKS-1:0][0:8]; 
  real                          rdqsnd_value  [pNO_OF_LRANKS-1:0][0:8]; 
  real                          wdqd_value    [pNO_OF_LRANKS-1:0][0:8]; 
  real                          rdqsgs_value  [pNO_OF_LRANKS-1:0][0:8]; 
  real                          x4rdqsd_value [pNO_OF_LRANKS-1:0][0:8]; // Added these for nibble1 when using X4 config
  real                          x4rdqsnd_value[pNO_OF_LRANKS-1:0][0:8]; // Added these for nibble1 when using X4 config
  real                          x4wdqd_value  [pNO_OF_LRANKS-1:0][0:8]; // Added these for nibble1 when using X4 config
  real                          x4rdqsgs_value[pNO_OF_LRANKS-1:0][0:8]; // Added these for nibble1 when using X4 config
  real                          dqsgd_value   [pNO_OF_LRANKS-1:0][0:8];  
  real                          x4dqsgd_value [pNO_OF_LRANKS-1:0][0:8];  // Added these for nibble1 when using X4 config      

  // controller registers
  reg [`REG_DATA_WIDTH-1:0]     cdcr;    // Controller DRAM config register
  reg [`REG_DATA_WIDTH-1:0]     drr;     // Controller DRAM refresh register

  wire [`tRFPRD_WIDTH-1:0]      ctrl_rfsh_prd;   // controller refresh period
  wire [3:0]                    ctrl_rfsh_burst; // controller refresh burst
  wire                          ctrl_rfsh_en;    // controller refresh enable

  // PHY registers
  wire                          pll_bypass;
  reg                           pll_in_bypass;
  reg [`DWC_NO_OF_ZQ_SEG-1:0]                    odt_zden;
  reg [`DWC_NO_OF_ZQ_SEG-1:0]                    drv_zden;
  wire                          dll_off_mode;

  // host reads issued and received
  reg [31:0]                    host_reads_txd;
  reg [31:0]                    bl4_reads_txd;
  reg [31:0]                    cfg_reads_txd;
  reg [31:0]                    host_reads_rxd;
  reg [31:0]                    cfg_reads_rxd;
  reg                           read_cnt_en;

  reg                           wr_bl4_otf;
  reg                           rd_bl4_otf;
  
  // DRAM configuration register bits
  wire [2:0]                    ddr_mode;
  wire                          ddr4_mode;    // DDR4 mode
  wire                          ddr3_mode;    // DDR3 mode
  wire                          ddr2_mode;    // DDR2 mode
  wire                          lpddr2_mode;  // LPDDR2 (MDDR2)mode
  wire                          lpddr3_mode;  // LPDDR1 (MDDR) mode
  wire                          lpddrx_mode;  // LPDDR2 or LPDDR3 mode
  wire                          lpddr2_s4;    // LPDDR2-S4
  wire                          lpddr2_s2;    // LPDDR2-S2
  wire                          ddr_2t;       // DDR 2T timing

  wire [1:0]                    ddr_iowidth;  // I/O width of each DDR SDRAM chip
  wire [2:0]                    ddr_density;  // density of each DDR SDRAM chip
  wire [2:0]                    ddr_bytes;    // number of bytes enabled
  wire [1:0]                    ddr_ranks;    // DDR ranks
  
  wire                          ddr_8_bank;   // 8-bank DDR devices
  wire [4:0]                    sdram_chip;   // DDR SDRAM chip configuration
  wire [31:0]                   max_banks;    // maximum number of banks

  // memory manager configuration bits
  wire                          uhpp_en;      // ultra-high priority port (UHPP) enable
  wire                          uhpp_rsvd;    // UHPP reserved bit
  wire [1:0]                    addr_map;     // address mapping

  reg [`DATA_WIDTH-1:0]         error_mask;

  // miscellaneous controller register bits
  wire                          dl_tmode;
  wire                          io_lb_sel;
  wire [1:0]                    lb_sel;
  wire [1:0]                    lb_ck_sel;
  wire                          lb_mode;
  wire [7:0]                    cken;
  wire [1:0]                    dqs_gatex;
  wire                          rdimm;
  wire [2:0]                    msbyte_udq;
  wire                          udq_iom;

  // extended mode register bits
  wire  [pNO_OF_PRANKS-1:0]     mpr_en;       // DDR3 MPR enable
  
  // derived timing parameters                        
  wire [5:0]                    t_cl;         // CL: cas latency (max = 11)
  wire [5:0]                    t_al;         // AL: additive latency (max = 10)
  wire [4:0]                    t_bl;         // BL: burst length (max = 16)
  reg  [4:0]                    t_wr;         // WR: write recovery (max = 16)
  wire [5:0]                    t_cwl;        // CWL: cas write latency (max = 8)
  wire                          ddr3_blotf;
  wire                          ddr3_bl4fxd;
  wire [3:0]                    ctrl_burst_len; // burst length inside controller (max = 4)
  wire [4:0]                    ddr_burst_len;  // burst length at DDR interface (max = 16)
  wire [3:0]                    sdr_burst_len;  // SDR burst length at DDR interface (max = 8)
  wire [3:0]                    pub_burst_len;  // burst length inside PUB (max = 4)

  reg [4:0]                     bl;       // BL: burst length (max = 16)
  reg [CL_WIDTH-1:0]            cl;       // CL: cas latency (max = 11)
  reg [tWR_WIDTH-1:0]           twr;      // WR: write recovery (max = 12)
  reg [CL_WIDTH-1:0]            al;       // AL: additive latency (max = 10)
  wire [3:0]                    bl2;      // BL/2
  wire [WL_WIDTH-1:0]           wl;       // write latency (max = 18)
  wire [WL_WIDTH-1:0]           ca_par_lat;// DDR4 CA Parity Latency
  wire [RL_WIDTH-1:0]           rl;       // read latency (max = 21)
  wire [RL_WIDTH-1:0]           sdram_rl;       // read latency (max = 21)
  reg  [WL_WIDTH-1:0]           cwl;      // CAS write latency (DDR3)
  wire                          ddr3_odt_en;
  wire [tOL_WIDTH-1:0]          ol;       // ODT latency
  wire [tOL_WIDTH-1:0]          olp2;     // ODT latency + 2 // ***TBD: width?

  wire [tMRD_WIDTH-1:0]         t_mrd;      // load mode to load mode
  reg  [`tRTP_WIDTH-1:0]        t_rtp;      // internal read to precharge
  wire [`tWTR_WIDTH-1:0]        t_wtr;      // internal write to read
  wire [`tRP_WIDTH-1:0]         t_rp;       // precharge to activate
  wire [`tRCD_WIDTH-1:0]        t_rcd;      // activate to read/write
  wire [`tRAS_WIDTH-1:0]        t_ras;      // activate to precharge
  wire [`tRRD_WIDTH-1:0]        t_rrd;      // activate to activate (diff banks)
  wire [`tRC_WIDTH-1:0]         t_rc;       // activate to activate
  wire [`tFAW_WIDTH-1:0]        t_faw;      // 4-bank active window
  wire [`tRFC_WIDTH-1:0]        t_rfc;      // refresh to refresh (min)
  wire [tBCSTAB_WIDTH-1:0]      t_bcstab;   // RDIMM stabilization
  wire [tBCMRD_WIDTH-1:0]       t_bcmrd;    // RDIMM load mode to load mode
  wire [`tWLMRD_WIDTH-1:0]      t_wlmrd;
  wire [`tWLO_WIDTH-1:0]        t_wlo;
  wire [`tDQSCK_WIDTH-1:0]      t_dqsck;    // CK to DQS
  wire [`tDQSCK_WIDTH-1:0]      t_dqsckmax; // CK to DQS (max)
  wire [4:0]                    t_mod;      // load mode to other instruction

  wire [`tXS_WIDTH        -1:0] t_xs;
  wire [`tXP_WIDTH        -1:0] t_xp;
  wire [`tCKE_WIDTH       -1:0] t_cke;
  wire [`tDLLK_WIDTH      -1:0] t_dllk;
  wire                          t_rtodt;
  wire                          t_rtw;
                             
  wire [`tDINIT0_WIDTH    -1:0] tdinit0;
  wire [`tDINIT1_WIDTH    -1:0] tdinit1;
  wire [`tDINIT2_WIDTH    -1:0] tdinit2;
  wire [`tDINIT3_WIDTH    -1:0] tdinit3;

  reg  [`tDINITRST_WIDTH  -1:0] tdinitrst;
  reg  [`tDINITCKELO_WIDTH-1:0] tdinitckelo;
  reg  [`tDINITCKEHI_WIDTH-1:0] tdinitckehi;
  reg  [`tDINITZQ_WIDTH   -1:0] tdinitzq;
  
  reg [1:0]                     pdr_burst_len;
  reg [2:0]                     burst_len;
  reg                           ddr2_bl4;
  reg [tWRL_WIDTH-1:0]          t_wl;
  reg [tWRL_WIDTH-1:0]          t_rl;
  reg [tOL_WIDTH-1:0]           t_ol;
  reg [2:0]                     t_orwl_odd;
  reg                           t_wl_eq_1;
  reg                           t_rl_eq_3;
  wire [tRPA_WIDTH-1:0]         t_rpa;
  wire [tRP_WIDTH-1:0]          t_pre2act;
  wire [tACT2RW_WIDTH-1:0]      t_act2rw;
  wire [tRD2PRE_WIDTH-1:0]      t_rd2pre;
  wire [tWR2PRE_WIDTH-1:0]      t_wr2pre;
  wire [tRD2WR_WIDTH-1:0]       trd2wr;
  reg  [tRD2WR_WIDTH-1:0]       t_rd2wr;
  wire [tWR2RD_WIDTH-1:0]       t_wr2rd;
  wire [tRD2PRE_WIDTH-1:0]      t_rdap2act;
  wire [tWR2PRE_WIDTH-1:0]      t_wrap2act;
  reg  [tCCD_WIDTH-1:0]         t_ccd_l;
  reg  [tCCD_WIDTH-1:0]         t_ccd_s;
  reg  [pWLSL_WIDTH-1:0]        wl_pipe   [pNO_OF_LRANKS-1:0][pNUM_LANES-1:0];
  reg  [pDGSL_WIDTH-1:0]        gdqs_pipe [pNO_OF_LRANKS-1:0][pNUM_LANES-1:0];
  reg  [pDGSL_WIDTH-1:0]        max_rsl;
  
  reg  [pDGSL_WIDTH-1:0]        gdqs_rsl [pNO_OF_LRANKS-1:0][pNUM_LANES-1:0];    // read system latency
  reg  [pWLSL_WIDTH-1:0]        wl_wsl   [pNO_OF_LRANKS-1:0][pNUM_LANES-1:0];    // write system latency
  wire [7:0]                    t_dcut0;
  wire [7:0]                    t_dcut1;
  wire [7:0]                    t_dcut2;
  wire [7:0]                    t_dcut3;
  reg  [7:0]                    walking_0_write;
  reg  [7:0]                    walking_0_read;
  reg  [7:0]                    walking_1_write;
  reg  [7:0]                    walking_1_read;
  reg                           rd_cmd;
  integer                       pos_write;
  integer                       pos_read;
  reg                           first_access_lfsr_write;
  reg                           first_access_lfsr_read;
  reg [`REG_DATA_WIDTH-1:0]     lfsr_reg_write;
  reg [`REG_DATA_WIDTH-1:0]     lfsr_reg_read;
  reg [`REG_DATA_WIDTH-1:0]     lfsr;
  
  wire [`LCDL_DLY_WIDTH-1:0]    cal_ddr_prd;
  wire [`LCDL_DLY_WIDTH-1:0]    cal_90deg_val;
  integer                       cal_ddr_prd_int;

  // DCU caches and register bits
  reg  [`CCACHE_DATA_WIDTH -1:0] ccache [0:`CCACHE_DEPTH-1];
  reg  [`ECACHE_DATA_WIDTH -1:0] ecache [0:`ECACHE_DEPTH-1];
  reg  [`RCACHE_DATA_WIDTH -1:0] rcache [0:`RCACHE_DEPTH-1];
  
  wire [`CACHE_ADDR_WIDTH  -1:0] cache_word_addr;
  wire [3                    :0] cache_slice_addr;
  wire [1                    :0] cache_sel;
  wire                           cache_inc_addr;
  wire                           cache_access_type;
  wire [`CACHE_ADDR_WIDTH  -1:0] cache_word_addr_r;
  wire [3                    :0] cache_slice_addr_r;
  
  wire [3:0]                     dcu_inst;
  wire [`CACHE_ADDR_WIDTH  -1:0] ccache_start_addr;
  wire [`CACHE_ADDR_WIDTH  -1:0] ccache_end_addr;
  wire [`DCU_FAIL_CNT_WIDTH-1:0] dcu_stop_fail_cnt;
  wire                           dcu_stop_on_nfail;
  wire                           dcu_stop_cap_on_full;
  wire                           dcu_read_cap_en;
  wire                           dcu_compare_en;
  
  wire [`CACHE_ADDR_WIDTH  -1:0] loop_start_addr;
  wire [`CACHE_ADDR_WIDTH  -1:0] loop_end_addr;
  wire [`CACHE_LOOP_WIDTH  -1:0] loop_cnt;
  wire                           loop_infinite;
  wire                           dcu_inc_dram_addr;
  wire [`CACHE_ADDR_WIDTH  -1:0] xpctd_loop_end_addr;

  wire [`DCU_READ_CNT_WIDTH-1:0] dcu_cap_start_word;

  reg  [`CACHE_ADDR_WIDTH  -1:0] ctl_ccache_addr;
  reg  [`CACHE_ADDR_WIDTH  -1:0] ctl_ecache_addr;
  reg  [`CACHE_ADDR_WIDTH  -1:0] ctl_rcache_addr;

  reg                            dcu_done;
  reg                            dcu_cap_fail;
  reg                            dcu_cap_full;
  reg  [`DCU_READ_CNT_WIDTH-1:0] dcu_read_cnt;
  reg  [`DCU_FAIL_CNT_WIDTH-1:0] dcu_fail_cnt;
  reg  [`CACHE_LOOP_WIDTH  -1:0] dcu_loop_cnt;
  
`ifdef DWC_DDRPHY_EMUL_XILINX
  reg  [31                    :0] dcu_emul_pattern=0;
  reg  [31                    :0] dcu_emul_pattern_x4=0;
  reg  [2                     :0] wr_cnt=0;
`endif

  integer                        read_cnt, zden_cnt, zdone_cnt;
  reg [2:0]                      rdimm_cmd_lat;
  
  
  // DCU command excution
  event dcu_start_run;
  event dcu_stop_run;
  event dcu_stop_loop_run;
  event dcu_start_reset;
  event e_get_encoded_pub_data;
  event e_get_encoded_lfsr_data_write;
  event e_get_encoded_lfsr_data_read;
  reg   dcu_run;
  reg   dcu_stop;
  reg   dcu_stop_loop;
  reg   dcu_fail_stop;
  reg   dcu_reset;
  reg   dcu_was_run;
  reg   check_read;
  reg   dcu_bst_test;

  wire [15:0] i_user_pat_odd_write;
  wire [15:0] i_user_pat_even_write;
  wire [15:0] i_user_pat_odd_read;
  wire [15:0] i_user_pat_even_read;
  

  wire       cmpr_all_bytes;
  wire [3:0] cmpr_byte_sel;
  
  reg  [`REG_DATA_WIDTH-1:0]     zqcr_reg ;
  reg  [`REG_DATA_WIDTH-1:0]     zqnsr_reg [0:3];
  reg  [`REG_DATA_WIDTH-1:0]     zqnpr_reg [0:3];
  reg  [`REG_DATA_WIDTH-1:0]     zqndr_reg [0:3];
  reg  [`REG_DATA_WIDTH-1:0]     mr  ;
  reg  [`REG_DATA_WIDTH-1:0]     emr   [pNO_OF_PRANKS-1:0];
  reg  [`REG_DATA_WIDTH-1:0]     emr2  [pNO_OF_PRANKS-1:0];
  reg  [`REG_DATA_WIDTH-1:0]     emr3  [pNO_OF_PRANKS-1:0];


//To take care of the pll share option
  reg [8:0] acpll_share = `ac_pll_share;
  reg [8:0] dxpll_share = `dx_pll_share;
  wire [8:0] dxpll_share_tmp;
  wire [8:0] dx_pll_share;

  assign     dxpll_share_tmp= {dxpll_share[7:0],1'b0};

  assign     dx_pll_share = ((~dxpll_share_tmp) | dxpll_share); 

  always @(*) begin: tmp_zqreg
    integer i,j;
    zqcr_reg = zqcr;
    for (i=0; i<4; i=i+1) begin
      zqnpr_reg[i] = zqnpr[i];
      zqndr_reg[i] = zqndr[i];
      zqnsr_reg[i] = zqnsr[i];
    end

    mr   = mr0;
    for(j=0; j<pNO_OF_PRANKS;j=j+1)
    begin
      emr[j]  = mr1[j];
      emr2[j] = mr2[j];
      emr3[j] = mr3[j];
    end
  end
  // *** TBD end temporary
  
  //---------------------------------------------------------------------------
  // Initialization
  //---------------------------------------------------------------------------
  integer rank_no, lane_no;
   
  initial
    begin: initialize
      //fifo_wrptr     = 0;
      //fifo_rdptr     = 0;
      ch0_fifo_wrptr = 0;
      ch0_fifo_rdptr = 0;
      ch1_fifo_wrptr = 0;
      ch1_fifo_rdptr = 0;
      read_pending   = 1'b0;
      host_reads_txd = 0;
      host_reads_rxd = 0;
      bl4_reads_txd  = 0;
      cfg_reads_txd  = 0;
      cfg_reads_rxd  = 0;
      reg_fifo_wrptr = 0;
      reg_fifo_rdptr = 0;
      read_cnt_en    = 1;

      mem_used = 0;

      // all bytes are enabled
      active_bytes = `DWC_NO_OF_BYTES;
      data_mask    = {`DWC_DATA_WIDTH{1'b1}};

      error_mask    = {`DATA_WIDTH{1'b0}};
      pll_in_bypass = 1'b0;

      for (rank_no = 0; rank_no < pNO_OF_LRANKS; rank_no = rank_no + 1) begin
        for (lane_no = 0; lane_no <pNUM_LANES; lane_no = lane_no +1) begin
          wl_pipe   [rank_no][lane_no] = {(pWLSL_WIDTH){1'b0}};
          gdqs_pipe [rank_no][lane_no] = {(pDGSL_WIDTH){1'b0}};
        end
      end
      
      max_rsl     = 0;

      check_read   = 1;
      dcu_bst_test = 0;
      
`ifdef DWC_DDRPHY_HDR_MODE
      hdr_mode  = 1'b1;
`else
      hdr_mode  = 1'b0;
`endif

`ifdef DWC_DDRPHY_RR_MODE
      rr_mode   = 1'b1;
`else
      rr_mode   = 1'b0;
`endif
      // position marker for Bistudp
      pos_write = 0;
      pos_read = 0;
      first_access_lfsr_write = 1'b1;
      first_access_lfsr_read  = 1'b1;
      lfsr_reg_write    = {`REG_DATA_WIDTH{1'b0}};
      lfsr_reg_read     = {`REG_DATA_WIDTH{1'b0}};
      
      walking_1_write   = `PUB_WALKING_1_8BIT_PAT;
      walking_0_write   = `PUB_WALKING_0_8BIT_PAT;
      walking_1_read    = `PUB_WALKING_1_8BIT_PAT;
      walking_0_read    = `PUB_WALKING_0_8BIT_PAT;
    end

  reg [31:0] temp;
  
  // reset of registers
  always @(negedge rst_b)
    begin: register_reset
      integer i, rank_id;

      // PHY registers
      ridr      = {`DWC_GP_RID, `DWC_PHY_RID, `DWC_PUB_RID};
      pir       = `PIR_DEFAULT;
`ifdef DWC_PUB_CLOCK_GATING
      cgcr      = `CGCR_DEFAULT;
`endif
      cgcr1     = `CGCR1_DEFAULT;
      pgcr0     = `PGCR0_DEFAULT;
      pgcr1     = `PGCR1_DEFAULT;
      pgcr2     = `PGCR2_DEFAULT;
      pgcr3     = `PGCR3_DEFAULT;
      pgcr4     = `PGCR4_DEFAULT;
      pgcr5     = `PGCR5_DEFAULT;
      pgcr6     = `PGCR6_DEFAULT;
      pgcr7     = `PGCR7_DEFAULT;
      pgcr8     = `PGCR8_DEFAULT;
      pgsr0     = `PGSR0_DEFAULT;
      pgsr1     = `PGSR1_DEFAULT;
`ifdef DWC_DDRPHY_PLL_TYPEB
      pllcr0    = `PLLCR0_DEFAULT;
      pllcr1    = `PLLCR1_DEFAULT;
      pllcr2    = `PLLCR2_DEFAULT;
      pllcr3    = `PLLCR3_DEFAULT;
      pllcr4    = `PLLCR4_DEFAULT;
      pllcr5    = `PLLCR5_DEFAULT;
`else
      pllcr     = `PLLCR_DEFAULT;
`endif
      ptr0      = `PTR0_DEFAULT;
      ptr1      = `PTR1_DEFAULT;
      ptr2      = `PTR2_DEFAULT;
`ifdef FULL_SDRAM_INIT
      ptr3      = `PTR3_DEFAULT;
      ptr4      = `PTR4_DEFAULT;
      ptr5      = `PTR5_DEFAULT;
      ptr6      = `PTR6_DEFAULT;
`else
      ptr3      = {{2{1'b0}}, `tDINIT1_c_ssi, `tDINIT0_c_ssi};
      ptr4      = {{3{1'b0}}, `tDINIT3_c_ssi, `tDINIT2_c_ssi};
      ptr5      = {`pTPLLFRQSEL, {2{1'b0}}, `pTPLLFFCRGS, {2{1'b0}}, `pTPLLFFCGS};
      ptr6      = {{18{1'b0}}, `pTPLLRLCK};
`endif
      acmdlr0   = `ACMDLR0_DEFAULT;
      acmdlr1   = `ACMDLR1_DEFAULT;
      aclcdlr   = `ACLCDLR_DEFAULT;
`ifndef DWC_DDRPHY_EMUL_XILINX
     `ifdef LPDDR2
      // for LPDDR2, the LCDLR will default to 1/4 cycle
      aclcdlr[8:0] = cal_90deg_val;
     `elsif LPDDR3
      // for LPDDR3, the LCDLR will default to 1/4 cycle
      aclcdlr[8:0] = cal_90deg_val;
     `endif
`endif
      acbdlr0   = `ACBDLR0_DEFAULT;
      acbdlr1   = `ACBDLR1_DEFAULT;
      acbdlr2   = `ACBDLR2_DEFAULT;
      acbdlr3   = `ACBDLR3_DEFAULT;
      acbdlr4   = `ACBDLR4_DEFAULT;
      acbdlr5   = `ACBDLR5_DEFAULT;
      acbdlr6   = `ACBDLR6_DEFAULT;
      acbdlr7   = `ACBDLR7_DEFAULT;
      acbdlr8   = `ACBDLR8_DEFAULT;
      acbdlr9   = `ACBDLR9_DEFAULT;
      acbdlr10  = `ACBDLR10_DEFAULT;      
      acbdlr11  = `ACBDLR11_DEFAULT;      
      acbdlr12  = `ACBDLR12_DEFAULT;      
      acbdlr13  = `ACBDLR13_DEFAULT;      
      acbdlr14  = `ACBDLR14_DEFAULT;  
      rankidr   = `RANKIDR_DEFAULT;    
      riocr0    = `RIOCR0_DEFAULT;
      riocr1    = `RIOCR1_DEFAULT;
      riocr2    = `RIOCR2_DEFAULT;
      riocr3    = `RIOCR3_DEFAULT;
      riocr4    = `RIOCR4_DEFAULT;
      riocr5    = `RIOCR5_DEFAULT;
      aciocr0   = `ACIOCR0_DEFAULT;
      aciocr1   = `ACIOCR1_DEFAULT;
      aciocr2   = `ACIOCR2_DEFAULT;
      aciocr3   = `ACIOCR3_DEFAULT;
      aciocr4   = `ACIOCR4_DEFAULT;
      aciocr5   = `ACIOCR5_DEFAULT;
      dxccr     = `DXCCR_DEFAULT;
      dsgcr     = `DSGCR_DEFAULT;
      dcr       = `DCR_DEFAULT;
      dtpr0     = `DTPR0_DEFAULT;
      dtpr1     = `DTPR1_DEFAULT;
      dtpr2     = `DTPR2_DEFAULT;
      dtpr3     = `DTPR3_DEFAULT;
      dtpr4     = `DTPR4_DEFAULT;
      dtpr5     = `DTPR5_DEFAULT;
      dtpr6     = `DTPR6_DEFAULT;
      schcr0    = `SCHCR0_DEFAULT;
      schcr1    = `SCHCR1_DEFAULT;
      mr0       = `MR0_DEFAULT;
      for(i=0; i<pNO_OF_PRANKS;i=i+1)
      begin
        mr1[i]  = `MR1_DEFAULT;
        mr2[i]  = `MR2_DEFAULT;
        mr3[i]  = `MR3_DEFAULT;
      end
      mr4       = `MR4_DEFAULT;
      for(i=0; i<pNO_OF_PRANKS;i=i+1)
      begin
        mr5[i]  = `MR5_DEFAULT;
        mr6[i]  = `MR6_DEFAULT;
      end
      mr7       = `MR7_DEFAULT;
      for(i=0; i<pNO_OF_PRANKS;i=i+1)
      begin
        mr11[i] = `MR11_DEFAULT;
      end 
      for (rank_id =0; rank_id < pNO_OF_PRANKS; rank_id = rank_id + 1) begin 
        odtcr[rank_id]     = `ODTCR_DEFAULT;
      end
      aacr      = `AACR_DEFAULT;
      dtcr0     = `DTCR0_DEFAULT;
      dtcr1     = `DTCR1_DEFAULT;
      dtar0     = `DTAR0_DEFAULT;
      dtar1     = `DTAR1_DEFAULT;
      dtar2     = `DTAR2_DEFAULT;
      dtdr0     = `DTDR0_DEFAULT;
      dtdr1     = `DTDR1_DEFAULT;
      uddr0     = `UDDR0_DEFAULT;
      uddr1     = `UDDR1_DEFAULT;
      dtedr0    = `DTEDR0_DEFAULT;
      dtedr1    = `DTEDR1_DEFAULT;
      vtdr      = `VTDR_DEFAULT;

      rdimmgcr0 = `RDIMMGCR0_DEFAULT;
      rdimmgcr1 = `RDIMMGCR1_DEFAULT;
`ifdef FULL_SDRAM_INIT
      rdimmgcr1[18:16] = 3'b000;
`endif
      rdimmgcr2 = `RDIMMGCR2_DEFAULT;
      for(i=0; i<`DWC_NO_OF_DIMMS;i=i+1)
      begin
        rdimmcr0[i]  = `RDIMMCR0_DEFAULT;
        rdimmcr1[i]  = `RDIMMCR1_DEFAULT;
        rdimmcr2[i]  = `RDIMMCR2_DEFAULT;
        rdimmcr3[i]  = `RDIMMCR3_DEFAULT;
        rdimmcr4[i]  = `RDIMMCR4_DEFAULT;
      end

      dcuar     = `DCUAR_DEFAULT;
      dcudr     = `DCUDR_DEFAULT;
      dcurr     = `DCURR_DEFAULT;
      dculr     = `DCULR_DEFAULT;
      dcugcr    = `DCUGCR_DEFAULT;
      dcutpr    = `DCUTPR_DEFAULT;
      dcusr0    = `DCUSR0_DEFAULT;
      dcusr1    = `DCUSR1_DEFAULT;
                            
      bistrr    = `BISTRR_DEFAULT;
      bistmskr0 = `BISTMSKR0_DEFAULT;
      bistmskr1 = `BISTMSKR1_DEFAULT;
      bistmskr2 = `BISTMSKR2_DEFAULT;
      bistlsr   = `BISTLSR_DEFAULT;
      bistwcr   = `BISTWCR_DEFAULT;
      bistar0   = `BISTAR0_DEFAULT;
      bistar1   = `BISTAR1_DEFAULT;
      bistar2   = `BISTAR2_DEFAULT;
      bistar3   = `BISTAR3_DEFAULT;
      bistar4   = `BISTAR4_DEFAULT;
      bistudpr  = `BISTUDPR_DEFAULT;
      bistgsr   = `BISTGSR_DEFAULT;
      bistwer0  = `BISTWER0_DEFAULT;
      bistwer1  = `BISTWER1_DEFAULT;
      bistber0  = `BISTBER0_DEFAULT;
      bistber1  = `BISTBER1_DEFAULT;
      bistber2  = `BISTBER2_DEFAULT;
      bistber3  = `BISTBER3_DEFAULT;
      bistber4  = `BISTBER4_DEFAULT;
      bistber5  = `BISTBER5_DEFAULT;
      bistwcsr  = `BISTWCSR_DEFAULT;
      bistfwr0  = `BISTFWR0_DEFAULT;
      bistfwr1  = `BISTFWR1_DEFAULT;
      bistfwr2  = `BISTFWR2_DEFAULT;
      iovcr0    = `IOVCR0_DEFAULT;
      iovcr1    = `IOVCR1_DEFAULT;                       
      vtcr0     = `VTCR0_DEFAULT;
      vtcr1     = `VTCR1_DEFAULT;
      gpr0      = `GPR0_DEFAULT;
      gpr1      = `GPR1_DEFAULT;
      catr0     = `CATR0_DEFAULT;
      catr1     = `CATR1_DEFAULT;
      dqsdr0    = `DQSDR0_DEFAULT;
      dqsdr1    = `DQSDR1_DEFAULT;
      dqsdr2    = `DQSDR2_DEFAULT;
      zqcr = `ZQCR_DEFAULT;

      for (i=0; i<`DWC_NO_OF_ZQ_SEG; i=i+1)
        begin
          zqnpr[i] = `ZQNPR_DEFAULT;
          zqndr[i] = `ZQNDR_DEFAULT;
          zqnsr[i] = `ZQNSR_DEFAULT;
        end

      temp = `ACMDLR0_DEFAULT;
      acmdlr_iprd_value = temp[0  +: `LCDL_DLY_WIDTH];
      acmdlr_tprd_value = temp[16 +: `LCDL_DLY_WIDTH];

      temp = `ACMDLR1_DEFAULT;
      acmdlr_mdld_value = temp[0  +: `LCDL_DLY_WIDTH];

      temp = `ACBDLR0_DEFAULT;
      acbdlr0_ck0bd_value = temp[ 5: 0];
      acbdlr0_ck1bd_value = temp[13: 8];
      acbdlr0_ck2bd_value = temp[21:16];
      acbdlr0_ck3bd_value = temp[29:24];

      temp = `ACBDLR1_DEFAULT;
      acbdlr1_actbd_value = temp[ 5: 0];
      acbdlr1_a17bd_value = temp[13: 8];
      acbdlr1_a16bd_value  = temp[21:16];
      acbdlr1_parbd_value = temp[29:24];
      
      temp = `ACBDLR2_DEFAULT;
      acbdlr2_ba0bd_value = temp[ 5: 0];
      acbdlr2_ba1bd_value = temp[13: 8];
      acbdlr2_ba2bd_value = temp[21:16];
      acbdlr2_ba3bd_value = temp[29:24];

      temp = `ACBDLR3_DEFAULT;
      acbdlr3_cs0bd_value = temp[ 5: 0];
      acbdlr3_cs1bd_value = temp[13: 8];
      acbdlr3_cs2bd_value = temp[21:16];
      acbdlr3_cs3bd_value = temp[29:24];

      temp = `ACBDLR4_DEFAULT;
      acbdlr4_odt0bd_value = temp[ 4: 0];
      acbdlr4_odt1bd_value = temp[12: 8];
      acbdlr4_odt2bd_value = temp[20:16];
      acbdlr4_odt3bd_value = temp[28:24];

      temp = `ACBDLR5_DEFAULT;
      acbdlr5_cke0bd_value = temp[ 5: 0];
      acbdlr5_cke1bd_value = temp[13: 8];
      acbdlr5_cke2bd_value = temp[21:16];
      acbdlr5_cke3bd_value = temp[29:24];

      temp = `ACBDLR6_DEFAULT;
      acbdlr6_a00bd_value = temp[ 5: 0];
      acbdlr6_a01bd_value = temp[13: 8];
      acbdlr6_a02bd_value = temp[21:16];
      acbdlr6_a03bd_value = temp[29:24];

      temp = `ACBDLR7_DEFAULT;
      acbdlr7_a04bd_value = temp[ 5: 0];
      acbdlr7_a05bd_value = temp[13: 8];
      acbdlr7_a06bd_value = temp[21:16];
      acbdlr7_a07bd_value = temp[29:24];

      temp = `ACBDLR8_DEFAULT;
      acbdlr8_a08bd_value = temp[ 5: 0];
      acbdlr8_a09bd_value = temp[13: 8];
      acbdlr8_a10bd_value = temp[21:16];
      acbdlr8_a11bd_value = temp[29:24];

      temp = `ACBDLR9_DEFAULT;
      acbdlr9_a12bd_value = temp[ 5: 0];
      acbdlr9_a13bd_value = temp[13: 8];
      acbdlr9_a14bd_value = temp[21:16];
      acbdlr9_a15bd_value = temp[29:24];
      
      temp = `ACBDLR10_DEFAULT;
      acbdlr10_acpddbd_value = temp[ 5: 0];
      acbdlr10_cid0bd_value  = temp[13: 8];
      acbdlr10_cid1bd_value  = temp[21:16];
      acbdlr10_cid2bd_value  = temp[29:24];
      
      temp = `ACBDLR11_DEFAULT;
      acbdlr11_cs4bd_value  = temp[ 5: 0];
      acbdlr11_cs5bd_value  = temp[13: 8];
      acbdlr11_cs6bd_value  = temp[21:16];
      acbdlr11_cs7bd_value  = temp[29:24];
      
      temp = `ACBDLR12_DEFAULT;
      acbdlr12_cs8bd_value  = temp[ 5: 0];
      acbdlr12_cs9bd_value  = temp[13: 8];
      acbdlr12_cs10bd_value = temp[21:16];
      acbdlr12_cs11bd_value = temp[29:24];
      
      temp = `ACBDLR13_DEFAULT;
      acbdlr13_odt4bd_value = temp[ 5: 0];
      acbdlr13_odt5bd_value = temp[13: 8];
      acbdlr13_odt6bd_value = temp[21:16];
      acbdlr13_odt7bd_value = temp[29:24];
      
      temp = `ACBDLR14_DEFAULT;
      acbdlr14_cke4bd_value = temp[ 5: 0];
      acbdlr14_cke5bd_value = temp[13: 8];
      acbdlr14_cke6bd_value = temp[21:16];
      acbdlr14_cke7bd_value = temp[29:24];

      for (i=0; i<9; i=i+1)
        begin
          dxngcr0[i]   = `DXNGCR0_DEFAULT;
          dxngcr1[i]   = `DXNGCR1_DEFAULT;
          dxngcr2[i]   = `DXNGCR2_DEFAULT;
          dxngcr3[i]   = `DXNGCR3_DEFAULT;
          dxngcr4[i]   = `DXNGCR4_DEFAULT;
          dxngcr5[i]   = `DXNGCR5_DEFAULT;
          dxngcr6[i]   = `DXNGCR6_DEFAULT;
          dxngcr7[i]   = `DXNGCR7_DEFAULT;
          dxngcr8[i]   = `DXNGCR8_DEFAULT;
          dxngcr9[i]   = `DXNGCR9_DEFAULT;
          dxngsr0[i]   = `DXNGSR0_DEFAULT;
          dxngsr1[i]   = `DXNGSR1_DEFAULT;
          dxngsr2[i]   = `DXNGSR2_DEFAULT;
          dxngsr3[i]   = `DXNGSR3_DEFAULT;
          dxngsr4[i]   = `DXNGSR4_DEFAULT;
          dxngsr5[i]   = `DXNGSR5_DEFAULT;
          dxngsr6[i]   = `DXNGSR6_DEFAULT;
          dxnbdlr0[i]  = `DXNBDLR0_DEFAULT;
          dxnbdlr1[i]  = `DXNBDLR1_DEFAULT;
          dxnbdlr2[i]  = `DXNBDLR2_DEFAULT;
          dxnbdlr3[i]  = `DXNBDLR3_DEFAULT;
          dxnbdlr4[i]  = `DXNBDLR4_DEFAULT;
          dxnbdlr5[i]  = `DXNBDLR5_DEFAULT;
          dxnbdlr6[i]  = `DXNBDLR6_DEFAULT;
          dxnbdlr7[i]  = `DXNBDLR7_DEFAULT;
          dxnbdlr8[i]  = `DXNBDLR8_DEFAULT;
          dxnbdlr9[i]  = `DXNBDLR9_DEFAULT;
          for (rank_id =0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin 
              dxnlcdlr0[rank_id][i] = `DXNLCDLR0_DEFAULT;
              dxnlcdlr1[rank_id][i] = `DXNLCDLR1_DEFAULT;
              dxnlcdlr2[rank_id][i] = `DXNLCDLR2_DEFAULT;
              dxnlcdlr3[rank_id][i] = `DXNLCDLR3_DEFAULT;
              dxnlcdlr4[rank_id][i] = `DXNLCDLR4_DEFAULT;
              dxnlcdlr5[rank_id][i] = `DXNLCDLR5_DEFAULT;
          end
          dxnmdlr0[i]  = `DXNMDLR0_DEFAULT;
          dxnmdlr1[i]  = `DXNMDLR1_DEFAULT;
          for (rank_id =0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin 
              dxngtr0[rank_id][i]   = `DXNGTR0_DEFAULT;
          end

          gdqsprd_value [i] = 0.0;
          wlprd_value   [i] = 0.0;

          x4gdqsprd_value [i] = 0.0;
          x4wlprd_value   [i] = 0.0;
          
          dq0wbd_value  [i] = 0.0;
          dq1wbd_value  [i] = 0.0;
          dq2wbd_value  [i] = 0.0;
          dq3wbd_value  [i] = 0.0;
          dq4wbd_value  [i] = 0.0;
          dq5wbd_value  [i] = 0.0;
          dq6wbd_value  [i] = 0.0;
          dq7wbd_value  [i] = 0.0;
          dmwbd_value   [i] = 0.0;
          dswbd_value   [i] = 0.0;
          
          dq0rbd_value  [i] = 0.0;
          dq1rbd_value  [i] = 0.0;
          dq2rbd_value  [i] = 0.0;
          dq3rbd_value  [i] = 0.0;
          dq4rbd_value  [i] = 0.0;
          dq5rbd_value  [i] = 0.0;
          dq6rbd_value  [i] = 0.0;
          dq7rbd_value  [i] = 0.0;
          dmrbd_value   [i] = 0.0;
          
          dqsoebd_value [i] = 0.0;
          dqoebd_value  [i] = 0.0;
          dsrbd_value   [i] = 0.0;
          dsnrbd_value  [i] = 0.0;
         
          pdrbd_value   [i] = 0.0;
          terbd_value   [i] = 0.0;
          pddbd_value   [i] = 0.0; 
 
          x4dmwbd_value   [i] = 0.0;
          x4dswbd_value   [i] = 0.0;
          x4dqsoebd_value [i] = 0.0;
          x4dqoebd_value  [i] = 0.0;

          x4dmrbd_value   [i] = 0.0;
          x4dsrbd_value   [i] = 0.0;
          x4dsnrbd_value  [i] = 0.0;
         
          x4pdrbd_value   [i] = 0.0;
          x4terbd_value   [i] = 0.0;
          x4pddbd_value   [i] = 0.0; 
 
          for (rank_id =0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin 
              wld_value   [rank_id][i] = 0.0;
              rdqsd_value [rank_id][i] = 0.0;
              rdqsnd_value[rank_id][i] = 0.0;
              wdqd_value  [rank_id][i] = 0.0;
              rdqsgs_value[rank_id][i] = 0.0;
              dqsgd_value [rank_id][i] = 0.0;
              x4wld_value   [rank_id][i] = 0.0;
              x4rdqsd_value [rank_id][i] = 0.0;
              x4rdqsnd_value[rank_id][i] = 0.0;
              x4wdqd_value  [rank_id][i] = 0.0;
              x4rdqsgs_value[rank_id][i] = 0.0;
              x4dqsgd_value [rank_id][i] = 0.0;
          end
        end
      
      // controller registers      
      cdcr  = `CDCR_DEFAULT;
      drr   = `DRR_DEFAULT;

      // for DDR3 reset the memory array
`ifdef MICRON_DDR
      // *** TBD Micron memory resets the memory to X's on reset
      if (ddr3_mode === 1'b1)
        begin
          for (i=0; i<mem_used; i=i+1)
            begin
              ddr_sdram[i] = {`MEM_WIDTH{1'bx}};
              ddr_addr[i]  = {ADDR_WIDTH{1'bx}};
            end
        end
`endif

      // DCU caches
      for (i=0; i<`CCACHE_DEPTH; i=i+1) begin
        ccache[i] = {`CCACHE_DATA_WIDTH{1'b0}};
      end
      for (i=0; i<`ECACHE_DEPTH; i=i+1) begin
        ecache[i] = {`ECACHE_DATA_WIDTH{1'b0}};
      end
      for (i=0; i<`RCACHE_DEPTH; i=i+1) begin
        rcache[i] = {`RCACHE_DATA_WIDTH{1'b0}};
      end

      dcu_run       = 0;
      dcu_stop      = 0;
      dcu_stop_loop = 0;
      dcu_fail_stop = 0;
      dcu_reset     = 0;

      ctl_ccache_addr = 0;
      ctl_ecache_addr = 0;
      ctl_rcache_addr = 0;

      dcu_done     = 0;
      dcu_cap_fail = 0;
      dcu_cap_full = 0;
      dcu_read_cnt = 0;
      dcu_fail_cnt = 0;
      dcu_loop_cnt = 0;
      read_cnt     = 0;
      
      dcu_was_run  = 0;
    end // always @ (negedge rst_b)

  // clear the status registers using the PIR.CLRSR bit
  // the following status registers are cleared:
  //   - PGSR0[31:0]
  //   - PGSR1[31] - PARERR
  //   - DXnGSR[31:0]
  task clear_pir_registers;
    integer i;
    begin
      pir[17:0] = 18'b0;
    end
  endtask // clear_pir_registers
  
  task clear_zcal_status;
    integer i;
    begin
      pgsr0[20]    = 1'b0; //zcerr 
      for (i=0; i<4; i=i+1) begin
        zqnsr[i][11:0] = {12{1'b0}}; //zdone
      end
    end
  endtask // clear_zcal_status
  

  task clear_status_registers;
    integer i;
    begin
      pgsr0[0]     = 1'b0; //idone
      pgsr0[1]     = 1'b0; //pldone
      pgsr0[2]     = 1'b0; //dcdone      
      pgsr0[3]     = 1'b0; //zcdone
      pgsr0[4]     = 1'b0; //didone      
      pgsr0[5]     = 1'b0; //wldone
      pgsr0[6]     = 1'b0; //qsgdone
      pgsr0[7]     = 1'b0; //wladone
      pgsr0[8]     = 1'b0; //rddone
      pgsr0[9]     = 1'b0; //wddone
      pgsr0[10]    = 1'b0; //redone
      pgsr0[11]    = 1'b0; //wedone
      pgsr0[12]    = 1'b0; //cadone
      pgsr0[13]    = 1'b0; //srddone
      pgsr0[14]    = 1'b0; //vdone
      pgsr0[19]    = 1'b0; //verr
      pgsr0[20]    = 1'b0; //zcerr 
      pgsr0[21]    = 1'b0; //wlerr
      pgsr0[22]    = 1'b0; //qsgerr
      pgsr0[23]    = 1'b0; //wlaerr
      pgsr0[24]    = 1'b0; //rderr
      pgsr0[25]    = 1'b0; //wderr
      pgsr0[26]    = 1'b0; //reerr
      pgsr0[27]    = 1'b0; //weerr
      pgsr0[28]    = 1'b0; //caerr
      pgsr0[29]    = 1'b0; //cawrn
      pgsr0[30]    = 1'b0; //srderr
      pgsr0[31]    = 1'b0; //aplock
      pgsr1[31]    = 1'b0; //parerr      
      for (i=0; i<9; i=i+1) begin
        dxngsr0[i][5] = 1'b0;
        dxngsr0[i][6] = 1'b0;
        dxngsr0[i][29:26] = 4'b0000; //DDRG@MPHY: Why dont we make all zeros?
        dxngsr1[i] = {`REG_DATA_WIDTH{1'b0}};
        dxngsr2[i] = {`REG_DATA_WIDTH{1'b0}};
        dxngsr3[i] = {`REG_DATA_WIDTH{1'b0}};
        dxngsr4[i][5] = 1'b0;
        dxngsr4[i][6] = 1'b0;
        dxngsr4[i][31:26] = {6{1'b0}}; //DDRG@MPHY: Why dont we make all zeros?
      end
      for (i=0; i<4; i=i+1) begin
        zqnsr[i][11:0] = {12{1'b0}}; //zdone
      end
    end
  endtask // clear_status_registers
  
  // reset of DDL registers when DDL test mode is asserted
  always @(posedge dl_tmode) begin: ddl_test_mode_reset
    integer i, rank_id;
    
    if (dl_tmode === 1'b1) begin
      acmdlr0  = {`REG_DATA_WIDTH{1'b0}};
      acmdlr1  = {`REG_DATA_WIDTH{1'b0}};
      aclcdlr  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr0  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr1  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr2  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr3  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr4  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr5  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr6  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr7  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr8  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr9  = {`REG_DATA_WIDTH{1'b0}};
      acbdlr10 = {`REG_DATA_WIDTH{1'b0}};
      acbdlr11 = {`REG_DATA_WIDTH{1'b0}};
      acbdlr12 = {`REG_DATA_WIDTH{1'b0}};
      acbdlr13 = {`REG_DATA_WIDTH{1'b0}};
      acbdlr14 = {`REG_DATA_WIDTH{1'b0}};
      for (i=0; i<9; i=i+1) begin
        dxngcr0[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr1[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr2[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr3[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr4[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr5[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr6[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngcr7[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngsr0[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngsr1[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngsr2[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngsr3[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngsr4[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxngsr5[i]   = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr0[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr1[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr2[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr3[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr4[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr5[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr6[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr7[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr8[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnbdlr9[i]  = {`REG_DATA_WIDTH{1'b0}};
        for (rank_id =0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin 
            dxnlcdlr0[rank_id][i] = {`REG_DATA_WIDTH{1'b0}};
            dxnlcdlr1[rank_id][i] = {`REG_DATA_WIDTH{1'b0}};
            dxnlcdlr2[rank_id][i] = {`REG_DATA_WIDTH{1'b0}};
            dxnlcdlr3[rank_id][i] = {`REG_DATA_WIDTH{1'b0}};
            dxnlcdlr4[rank_id][i] = {`REG_DATA_WIDTH{1'b0}};
            dxnlcdlr5[rank_id][i] = {`REG_DATA_WIDTH{1'b0}};
        end
        dxnmdlr0[i]  = {`REG_DATA_WIDTH{1'b0}};
        dxnmdlr1[i]  = {`REG_DATA_WIDTH{1'b0}};
        for (rank_id =0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin 
            dxngtr0[rank_id][i]   = {`REG_DATA_WIDTH{1'b0}};
        end
      end
    end
  end

  // LCDL measures DDR period
  // LCDL 90 degrees measured value is measured period divided by 2
  // in PLL bypass mode, the clock frequency is very low and therefore
  // calibration maxes out
  always @(*)
    cal_ddr_prd_int = `CAL_DDR_PRD * (`PHYSYS.default_ddl_step_size / `PHYSYS.ddl_step_size );

  initial
    cal_ddr_prd_int = `CAL_DDR_PRD * (`PHYSYS.default_ddl_step_size / `PHYSYS.ddl_step_size );
  
  assign cal_ddr_prd[8:0] = (cal_ddr_prd_int > 9'h1FF) ? 9'h1FF : cal_ddr_prd_int;

  // in a few cases the DDL step size may be changed from its defautl value of 10ps
  assign cal_90deg_val = cal_ddr_prd/2;

  // updates registers with the values that are set after calibration
  task update_cal_values_emul;
    begin
      pgsr0[3:0] = {4{1'b1}};
      // also the default timing values may have been forced to smaller
      // values to speed simulation
`ifdef FULL_SDRAM_INIT
`else
      ptr0[31:21] = `PTR0_TPLLPD_DFLT;
      ptr0[20:6]  = `PTR0_TPLLGS_DFLT;
      ptr1[12:0]  = `PTR1_TPLLRST_DFLT;
      ptr1[31:15] = `PTR1_TPLLLCK_DFLT;
`endif
    end
  endtask // update_cal_values
  
  
  // updates registers with the values that are set after calibration
  task update_cal_values;
    integer i, rank_id;
    begin
      // after calibration, some LCDLs have values corresponding to 90
      // degreees phase shift or a full DDR period
      acmdlr0[0  +: `LCDL_DLY_WIDTH] = cal_ddr_prd*pACCTLCALCLK_FACTOR; // enabled by default
      acmdlr0[16 +: `LCDL_DLY_WIDTH] = cal_ddr_prd*pACCTLCALCLK_FACTOR;
      acmdlr1[0  +: `LCDL_DLY_WIDTH] = cal_ddr_prd*pACCTLCALCLK_FACTOR;

      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
        begin
          for (rank_id = 0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin
            dxnlcdlr1[rank_id][i][0 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
            dxnlcdlr3[rank_id][i][0 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
            dxnlcdlr4[rank_id][i][0 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
            dxnlcdlr5[rank_id][i][0 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
            
	          if (`DWC_DX_NO_OF_DQS == 2)
	            begin
                dxnlcdlr1[rank_id][i][16 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
                dxnlcdlr3[rank_id][i][16 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
                dxnlcdlr4[rank_id][i][16 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
                dxnlcdlr5[rank_id][i][16 +: `LCDL_DLY_WIDTH] = cal_90deg_val;
              end
          end
          
          dxnmdlr0[i] [0  +: `LCDL_DLY_WIDTH] = cal_ddr_prd*pDXCTLCALCLK_FACTOR;
          dxnmdlr0[i] [16 +: `LCDL_DLY_WIDTH] = cal_ddr_prd*pDXCTLCALCLK_FACTOR;
          dxnmdlr1[i] [0  +: `LCDL_DLY_WIDTH] = cal_ddr_prd*pDXCTLCALCLK_FACTOR;
          dxngsr0[i][16]    = dx_pll_share[i];
          dxngsr0[i][7  +: `LCDL_DLY_WIDTH]  = cal_ddr_prd; // full DDR period
          dxngsr0[i][17 +: `LCDL_DLY_WIDTH]  = cal_ddr_prd; // full DDR period
		      
          dxngsr2[i][31:23] = cal_ddr_prd;
          dxngsr2[i][22]    = 1'b0;
	        if (`DWC_DX_NO_OF_DQS == 2'd2)
	          begin
		          dxngsr4[i][7  +: `LCDL_DLY_WIDTH]  = cal_ddr_prd; // full DDR period
		          dxngsr4[i][17 +: `LCDL_DLY_WIDTH]  = cal_ddr_prd; // full DDR period
              dxngsr5[i][31:23] = cal_ddr_prd;
              dxngsr5[i][22]    = 1'b0;
            end
	        else
	          begin
		          dxngsr4[i][7  +: `LCDL_DLY_WIDTH]  = $random; // write in junk if not using X4 configuration
		          dxngsr4[i][17 +: `LCDL_DLY_WIDTH]  = $random; // write in junk if not using X4 configuration
              dxngsr5[i][31:23] = $random; // write in junk if not using X4 configuration
              dxngsr5[i][22]    = $random; // write in junk if not using X4 configuration
            end
          dxngsr0[i][2:0]   = 3'b000; // are always cleared after calibration
	        
	        if (`DWC_DX_NO_OF_DQS == 2'd2)
	          begin
              dxngsr4[i][2:0]   = 3'b000; // are always cleared after calibration 
	          end
	        else
	          begin
		          dxngsr4[i][2:0]   = $random;
	          end
	        
        end

      // after calibration, the status bits for PHY initialization, 
      // PLL initializatin, and calibration will have been done; the
      // ZQ calibration will also be done
      pgsr0[4:0] = {5{1'b1}};
      
      ////DDRG2MPHY: The below needs to be checked.. Both the register value and the hard coded value
      // normal ZCTRL initialization will move the status bits
      for (i=0; i<4; i=i+1)
        begin
`ifdef DWC_DDRPHY_NO_PZQ
          //TODO: need to check 
          zqndr[i][27:0] = 32'h000014a;
`else
          zqndr[i][31:0] = 32'h08080c0c;
`endif                    
        end

      // also the default timing values may have been forced to smaller
      // values to speed simulation
`ifdef FULL_SDRAM_INIT
`else
      ptr0[31:21] = `PTR0_TPLLPD_DFLT;
      ptr0[20:6]  = `PTR0_TPLLGS_DFLT;
      ptr1[12:0]  = `PTR1_TPLLRST_DFLT;
      ptr1[31:15] = `PTR1_TPLLLCK_DFLT;
`endif
    end
  endtask // update_cal_values
  
`ifdef DWC_DDRPHY_PLL_TYPEB
  always @(*) pllcr = pllcr0;
`endif

  // enable bytes
  // ------------
  // specific bytes may be disabled and the corresponding SDRAM chips
  // disconnected (deselected); refer to ddr_rank.v for details;
  // disabled bytes always return zeros on reads and are modelled here as a
  // write of zeros
  task enable_bytes;
    input [31:0] no_of_bytes; // valid values 1 to 8
    integer i, j;
    begin
      active_bytes = no_of_bytes;

      // set the mask when generating expected data (0 = masked)
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
        begin
          for (j=0; j<8; j=j+1)
            begin
              data_mask[8*i+j] = (i < active_bytes) ? 1'b1 : 1'b0;
            end
        end
    end
  endtask // enable_bytes

  task set_byte_enables;
    input [`DWC_NO_OF_BYTES-1:0] byte_en;
    integer i, j;
    begin
      // set the mask when generating expected data (0 = masked)
      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1) begin
        for (j=0; j<8; j=j+1) begin
            data_mask[8*i+j] = byte_en[i];
          end
      end
    end
  endtask // set_byte_enables

  task set_byte_enable_mask;
    input [`DWC_NO_OF_BYTES-1:0] byte_en;
    integer i, j;

    begin
      // set the mask when generating expected data (0 = masked)
      for (i = 0; i < `DWC_NO_OF_BYTES; i= i + 1)
        data_mask[(8 * i) +: 8] = {8{byte_en[i]}};
    end
  endtask // enable_bytes

  task set_channel_byte_enable_mask;
    input integer                chn_no;
    input [`DWC_NO_OF_BYTES-1:0] byte_en;
    integer i, j;

    begin
      // set the mask when generating expected data (0 = masked)
      for (i = 0; i < `DWC_NO_OF_BYTES; i= i + 1)
        if (chn_no == 0 && (i <`DWC_NO_OF_BYTES/2)) begin
          data_mask[(8 * i) +: 8] = {8{byte_en[i]}};
        end

        if (chn_no == 1 && (i >=`DWC_NO_OF_BYTES/2)) begin        
          data_mask[(8 * i) +: 8] = {8{byte_en[i]}};
        end
    end
  endtask // set_channel_byte_enable_mask

  task get_channel_byte_enable_mask;
    input integer            shrac_chn_or_norm_mode;
    output [`DATA_WIDTH-1:0] mask;

    begin
      // 0 -> Channel 0
      // 1 -> Channel 1
      // 2 -> Normal mode (`NON_SHARED_AC define used for this)

     `ifdef DWC_USE_SHARED_AC_TB
        // get the mask
        case (shrac_chn_or_norm_mode)
          0 : mask = {{`HOST_NX*8*pCHN1_DX8_NUM{1'b0}},{`HOST_NX{data_mask[pCHN0_DX8_NUM*8-1:0]}}}; 
          1 : mask = {{`HOST_NX*8*pCHN0_DX8_NUM{1'b0}},{`HOST_NX{data_mask[`DWC_NO_OF_BYTES*8-1:pCHN0_DX8_NUM*8]}}};
          2 : mask = {`HOST_NX{data_mask}};
          default : begin
            `SYS.error;
            $display("-> %0t [GRM] Unsupported shrac_chn_or_norm_mode type, = %0d", $time, shrac_chn_or_norm_mode);
          end
        endcase
     `else
        mask = {`HOST_NX{data_mask}};
     `endif
    end
  endtask // get_channel_byte_enable_mask

  // upon PLL bypass, the PLL will lose lock and regain lock after bypass
  always @(posedge pll_bypass)
    begin: pll_bypass_mode
      integer i;
      if (pll_bypass === 1'b1)
        begin
          // all PLLs will lose lock
          pgsr0[31] = 1'b0;
          for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
            begin
              dxngsr0[i][16] = 1'b0;
            end
          pll_in_bypass = 1'b1;
        end
    end

`ifndef DWC_DDRPHY_EMUL_XILINX 
  always @(negedge pll_bypass)
    begin: pll_mission_mode
      integer i;
      if (pll_bypass === 1'b0 && pll_in_bypass == 1'b1)
        begin
          // All existing PLLs will lose lock.
          // If there is no AC PLL, it will never go back in lock.
          if (pAC_PLL_SHARE == 0) begin
            pgsr0[31] <= #(`PLL_LOCK_CLKS*`CLK_NX*`SYS.tCLK_PRD) 1'b1;
          end  
          else begin
            pgsr0[31] <= 1'b0;
          end  

          for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
            begin
              dxngsr0[i][16] <= #(`PLL_LOCK_CLKS*`CLK_NX*`SYS.tCLK_PRD) 1'b1;
            end
          pll_in_bypass = 1'b0;
        end
    end
`endif
  
//DDRG2MPHY: Need to check whether the below is required or not? Need to change the hard coded values as well.

`ifndef DWC_DDRPHY_EMUL_XILINX 
  // upon impedance over-ride enable, the status is from the over-ride data
  always @(drv_zden)
    begin: zq_drv_override
      integer i;
      for (i=0; i<4; i=i+1)
        begin
          zqndr[i][15:0] = (drv_zden[i] == 1'b0) ? 16'h0c0c : zqndr[i][15:0];
        end
    end
  always @(odt_zden)
    begin: zq_odt_override
      integer i;
      for (i=0; i<4; i=i+1)
        begin
          zqndr[i][31:16] = (odt_zden[i] == 1'b0) ? 16'h0808 : zqndr[i][31:16];
        end
    end
`endif

//DDRG2MPHY: Commented below as ZDONE is not prsent in G2MPHY...
//  // upon zcal_done, update zqnsr bit 31, temporary probe into PUB
//  always @(*)
//    begin: zcal_done_udpate
//      integer i;
//      for (i=0;i<`DWC_NO_OF_ZQ; i=i+1)
//        begin
//`ifdef DWC_DDRPHY_NO_PZQ
//          zqnsr0[i][27:0] = zqncr0[i][27:0];
//          zqnsr0[i][31]   = 1'b1;
//`else
//          zqnsr0[i][31] = `PUB.cfg_zqnsr_zdone;
//`endif
//        end
//    end
//    

  
  //---------------------------------------------------------------------------
  // DDR SDRAM Access
  //---------------------------------------------------------------------------

  // write
  // -----
  // writes to a selected DDR SDRAM address
  task write;
    input [`ADDR_WIDTH-1:0]     addr;
    input [`HOST_DQS_WIDTH-1:0] mask;
    input [`PUB_DATA_WIDTH-1:0] data;
    input [31:0]                burst_no;

    reg [`DWC_DATA_WIDTH-1:0]   mem_data;
    reg [`DWC_DATA_WIDTH-1:0]   wr_data;
    reg [`DQS_WIDTH-1:0]        wr_mask;

    reg [`SDRAM_RANK_WIDTH-1:0]      rank;
    reg [`SDRAM_BANK_WIDTH-1:0] bank;
    reg [`SDRAM_ROW_WIDTH-1:0]  row;
    reg [`SDRAM_COL_WIDTH-1:0]  col;

    reg [7:0] data_byte;
    reg parity_bit;
    reg [`ADDR_WIDTH-1:0] mem_addr;
    integer burst_seq_no;
    reg [`ADDR_WIDTH-1:0] start_addr;
    reg [2:0] burst_addr;
    integer pub_clk_nx;
    
    integer i, j, k;
    begin
      // PUB (DCU) always runs in HDR mode
      pub_clk_nx = (dcu_run) ? `PUB_CLK_NX : `CLK_NX;
      
      // write twice to convert from SDR to DDR data
      {rank, bank, row, col} = addr;
      start_addr = {row, col};

      for (j=0; j<(2*pub_clk_nx); j=j+1)
        begin
          // get the next address in the order of access within the burst
          addr = burst_address(start_addr, burst_no, j);

          // read and modify the data based on write enables
          mem_addr = {rank, bank, row, addr[`SDRAM_COL_WIDTH-1:0]};

          get_memory_index(mem_addr);
          if (mem_found)
            begin
              mem_data = ddr_sdram[mem_index];
            end
          else
            begin
              if (mem_used == `MAX_MEM_LOCATIONS)
                begin
                  $write("    *** ERROR: GRM memory overflow: ");
                  $write("Increase size of `MAX_MEM_LOCATIONS define in the ");
                  $write("dictionary or turn off GRM automatic checking\n");
                  `SYS.log_error;
                  `END_SIMULATION;
                end
              else
                begin
                  mem_used = mem_used + 1;
                end
              mem_data = {`MEM_WIDTH{1'bx}};
            end

          wr_data = data[`DWC_DATA_WIDTH-1:0];
`ifdef DWC_LOOP_BACK
          // masks don't have any effect during loopback
          wr_mask = {`DQS_WIDTH{1'b0}};
`else
          wr_mask = mask[`DQS_WIDTH-1:0];
`endif
          
          for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
            begin
              data_byte = mem_data[7:0];

              // check for number of dqs per data byte for masking
              if (pNO_OF_DX_DQS == 2) begin

`ifdef DWC_DDRPHY_DMDQS_MUX 
                // on X4 mode, dm is not supported if MUXed
                // on x8 mode, DM is out of dqs[1] bit when DM USED is specified
  `ifdef DWC_DDRPHY_X4MODE                                
                  data_byte[3:0] = wr_data[3:0];
                  data_byte[7:4] = wr_data[7:4];
  `else
    `ifdef DWC_DX_DM_USE                
                if (wr_mask[i*2] !== 1'b1) begin
                  if (wr_mask[i*2] === 1'b0) begin
                    data_byte[7:0] = wr_data[7:0];
                  end
                  else 
                    data_byte[7:0] = {8{1'bx}};
                end
    `else
                // DM not used, hence all data are written            
                  data_byte[3:0] = wr_data[3:0];
                  data_byte[7:4] = wr_data[7:4];
    `endif                
  `endif                
`else
  // when DWC_DX_DM_USE is not specified
  `ifndef DWC_DX_DM_USE
                  data_byte[3:0] = wr_data[3:0];
                  data_byte[7:4] = wr_data[7:4];
  `else 
    `ifdef DWC_DDRPHY_X4MODE
                // Do not support dm for DDR4 in x4 mode
                if (!ddr4_mode) begin
                  if (wr_mask[i*2] !== 1'b1) begin
                    if (wr_mask[i*2] === 1'b0) begin
                      data_byte[3:0] = wr_data[3:0];
                    end
                    else 
                      data_byte[3:0] = {4{1'bx}};
                  end
                  if (wr_mask[i*2+1] !== 1'b1) begin
                    if (wr_mask[i*2+1] === 1'b0) begin
                      data_byte[7:4] = wr_data[7:4];
                    end
                    else
                      data_byte[7:4] = {4{1'bx}};
                  end
                end
                else begin
                  data_byte[3:0] = wr_data[3:0];
                  data_byte[7:4] = wr_data[7:4];
                end
    `else
                // non x4 mode; x4x2 as (pNO_OF_DX_DQS == 2)
                // dm is supported in this mode 
                if (wr_mask[i*2] !== 1'b1) begin
                  if (wr_mask[i*2] === 1'b0) begin
                    data_byte[7:0] = wr_data[7:0];
                  end
                  else 
                    data_byte[7:0] = {8{1'bx}};
                end
    `endif                               
  `endif
`endif                
              end
              // NON X4X2 mode; dm supported
              
              else begin
`ifdef DWC_DX_DM_USE  
                if (wr_mask[i] !== 1'b1) begin
                  // write data if it is not masked out
                  if (wr_mask[i] === 1'b0)
                    data_byte = wr_data[7:0];
                  else
                    data_byte  = {8{1'bx}};
                end
`else
                data_byte = wr_data[7:0];
`endif              
              end
   
              // mask off unused DQ pins on the most significant byte
              if (i == (`DWC_NO_OF_BYTES-1)) begin
                for (k=0; k<8; k=k+1) begin
                  if (k >= (8-msbyte_udq)) data_byte[k] = 1'b0;
                end
              end
              
              // next byte
              mem_data = mem_data >> 8;
              wr_data  = wr_data >> 8;
              mem_data[`DWC_DATA_WIDTH-1:
                       `DWC_DATA_WIDTH-8] = (i < active_bytes) ?
                                            data_byte :
                                            {8{1'b0}};
            end
      
          // write the modified word
          mem_data = error_mask^mem_data;
          
          ddr_sdram[mem_index] = mem_data;
          ddr_addr [mem_index] = mem_addr;
          
          // next DDR word
          data = data >> `DWC_DATA_WIDTH;
          mask = mask >> pNUM_LANES;
        end // for (j=0; j<(2*`CLK_NX); j=j+1)
    end
  endtask // write

  
  // read
  // ----
  // reads from a selected DDR SDRAM address
  task read;
    input [`ADDR_WIDTH-1:0] addr;
    input [31:0]            no_of_bursts;
    input                   cmd_flag;
    input                   channel_no;
    input [3:0]             rd_cmd;

    reg [`DWC_DATA_WIDTH-1:0]   mem_data;
    reg [`ADDR_WIDTH-1:0]       start_addr;
    reg [`PUB_DATA_WIDTH-1:0]   data;
    reg [PUB_MEM_WORD_WIDTH-1:0] mem_word;

    reg [`SDRAM_RANK_WIDTH-1:0] rank;
    reg [`SDRAM_BANK_WIDTH-1:0] bank;
    reg [`SDRAM_ROW_WIDTH-1:0]  row;
    reg [`SDRAM_COL_WIDTH-1:0]  col;

    reg [`ADDR_WIDTH-1:0] mem_addr;
    integer burst_no;
    integer j;
    integer pub_clk_nx;
    
    begin
      // PUB (DCU) always runs in HDR mode
       pub_clk_nx = (dcu_run) ? `PUB_CLK_NX : `CLK_NX;

      {rank, bank, row, col} = addr;

      start_addr = {row, col};
      for (burst_no=0; burst_no<no_of_bursts; burst_no=burst_no+1)
        begin
          for (j=0; j<(2*pub_clk_nx); j=j+1)
            begin
              data = data >> `DWC_DATA_WIDTH;
              
              //if (valid_bus(bank) && valid_bus(start_addr))
              if (valid_bus(bank) && ((rd_cmd==`SDRAM_READ) ? valid_bus(start_addr) : 1'b1))
                begin
                  // get the next address in the order of access within the burst
                  addr = burst_address(start_addr, burst_no, j);

                  // access the data
                  mem_addr = {rank, bank, row, addr[`SDRAM_COL_WIDTH-1:0]};
                  get_memory_index(mem_addr);
                  if (mem_found)
                    begin
                      mem_data = ddr_sdram[mem_index];
                    end
                  else
                    begin
                      mem_data = {`MEM_WIDTH{1'bx}};
                    end
                end
              else
                begin
                  mem_data = {`MEM_WIDTH{1'bx}};
                end

              if (dcu_run) begin
                data[PUB_VLD_DATA_WIDTH-1:PUB_VLD_DATA_WIDTH-`DWC_DATA_WIDTH] = mem_data;
              end else begin
                data[VLD_DATA_WIDTH-1:VLD_DATA_WIDTH-`DWC_DATA_WIDTH] = mem_data;
              end
            end

          // load the read data into the FIFO
          mem_word = data;

          if (dcu_run) begin
            dcu_capture_read_data(mem_word);
            @(posedge `SYS.dfi_phy_clk);
          end else begin
            if (check_read) //put_read_data(mem_word, cmd_flag);
`ifdef DWC_USE_SHARED_AC_TB  
              put_read_data(mem_word, cmd_flag, channel_no);
`else
              put_read_data(mem_word, cmd_flag,`NON_SHARED_AC);
`endif
          end
        end

      // keep count of how many reads have been transmitted by the host
      if (!dcu_run && check_read) begin
        if (read_cnt_en === 1'b1)
          host_reads_txd = host_reads_txd + 1;
        
        if (ddr3_blotf && no_of_bursts !== ctrl_burst_len)
          begin
            bl4_reads_txd = bl4_reads_txd + 1;
          end
      end
    end
  endtask // read


  // read data FIFO
  // --------------
  // fifos the expected read data
  task put_read_data;
    input [MEM_WORD_WIDTH-1:0] mem_word;
    input                      cmd_flag;
    input integer              shrac_chn_or_norm_mode;
    begin

      // write the words into the FIFO and increment write pointer
      if (shrac_chn_or_norm_mode%2 == 0) begin
        ch0_fifo[ch0_fifo_wrptr] = {cmd_flag, mem_word};
        ch0_fifo_wrptr = (ch0_fifo_wrptr < (FIFO_DEPTH-1)) ? ch0_fifo_wrptr + 1 : 0;
      end
      else begin
        ch1_fifo[ch1_fifo_wrptr] = {cmd_flag, mem_word};
        ch1_fifo_wrptr = (ch1_fifo_wrptr < (FIFO_DEPTH-1)) ? ch1_fifo_wrptr + 1 : 0;
      end
    end
  endtask // put_read_data

  
  // gets the read data from the FIFO
  task get_read_data;
    input integer            shrac_chn_or_norm_mode;
    output [`DATA_WIDTH-1:0] q;
    output                   cmd_flag;
    begin
`ifdef DWC_USE_SHARED_AC_TB      
      // read the word, clear the just read entry, and increment the read pointer
      if (shrac_chn_or_norm_mode%2 == 0) begin
        {cmd_flag, q} = ch0_fifo[ch0_fifo_rdptr];
        ch0_fifo[ch0_fifo_rdptr] = {FIFO_WIDTH{1'b0}};
        ch0_fifo_rdptr = (ch0_fifo_rdptr < (FIFO_DEPTH-1)) ? ch0_fifo_rdptr + 1 : 0;
      end
      else begin
        {cmd_flag, q} = ch1_fifo[ch1_fifo_rdptr];
        ch1_fifo[ch1_fifo_rdptr] = {FIFO_WIDTH{1'b0}};
        ch1_fifo_rdptr = (ch1_fifo_rdptr < (FIFO_DEPTH-1)) ? ch1_fifo_rdptr + 1 : 0;
      end
      
      // mask disabled bytes
      // Shared AC mode channel 0
      if (shrac_chn_or_norm_mode == 0) begin
        q = q & {{`HOST_NX*8*pCHN1_DX8_NUM{1'b0}},
                 {`HOST_NX{data_mask[pCHN0_DX8_NUM*8-1:0]}}};
      end else begin
        if (shrac_chn_or_norm_mode == 1) begin
          q = q & {{`HOST_NX*8*pCHN0_DX8_NUM{1'b0}},
                   {`HOST_NX{data_mask[`DWC_NO_OF_BYTES*8-1:pCHN0_DX8_NUM*8]}}};
        end else begin
          q = q & {`HOST_NX{data_mask}};
        end
      end

`else                 
      // read the word, clear the just read entry, and increment the read pointer
      {cmd_flag, q} = ch0_fifo[ch0_fifo_rdptr];
      ch0_fifo[ch0_fifo_rdptr] = {FIFO_WIDTH{1'b0}};
      ch0_fifo_rdptr = (ch0_fifo_rdptr < (FIFO_DEPTH-1)) ? ch0_fifo_rdptr + 1 : 0;


      q = q & {`HOST_NX{data_mask}};
`endif
    end
  endtask // get_read_data

  
  // burst address
  // -------------
  // returns the next address in the order of accesses within a burst
  // ***$$$%%%$: sequential burst type only; interleaved TBD
  function [`ADDR_WIDTH-1:0] burst_address;
    input [`ADDR_WIDTH-1:0] start_addr;     // starting DDR address
    input [31:0]                burst_no;       // burst no
    input [1:0]                 ddr_word_no;    // first or second DDR word

    integer burst_seq_no;
    reg [3:0] burst_addr_lsb;
    integer pub_clk_nx;
    begin
      // PUB (DCU) always runs in HDR mode
      pub_clk_nx = (dcu_run) ? `PUB_CLK_NX : `CLK_NX;
      
      burst_seq_no   = (2*pub_clk_nx)*burst_no + ddr_word_no;

      // Sequential burst addresses
      // Updated for burst length 16 but not sure
      // of start addresses other than 0.  Continuing the pattern 
      // anyway.

       
      burst_addr_lsb = ((start_addr[3:0] + burst_seq_no[3:0]) % 4) + (4 * (burst_seq_no[3:0] / 4));

      
      burst_address = start_addr;
      case (t_bl)
        5'b00010: burst_address[0]   = burst_addr_lsb[0];   // BL = 2
        5'b00100: burst_address[1:0] = burst_addr_lsb[1:0]; // BL = 4
        5'b01000: burst_address[2:0] = burst_addr_lsb[2:0]; // BL = 8
        //DMF BL=16
        5'b10000: burst_address[3:0] = burst_addr_lsb[3:0]; // BL = 16
        default: burst_address[1:0] = burst_addr_lsb[1:0]; // reserved: BL = 4
      endcase // case(t_bl)
    end
  endfunction // burst_address
  

  // associative array index
  // -----------------------
  task get_memory_index;
    input [`ADDR_WIDTH-1:0] mem_addr;
    begin
      mem_index = 0;
      mem_found = 1'b0;
      while ((mem_index < mem_used) && !mem_found)
        begin
          if (ddr_addr[mem_index] === mem_addr)
            begin
              mem_found = 1'b1;
            end
          else
            begin
              mem_index = mem_index + 1;
            end
        end
    end
  endtask // get_memory_index
  
  
  //---------------------------------------------------------------------------
  // DDR Controller Register Access
  //---------------------------------------------------------------------------
  // legal accesses to DDR controller registers
  
  // register write
  // --------------
  // writes to a selected DDR controller register
  task write_register;
    input [`REG_ADDR_WIDTH-1:0] addr;
    input [`REG_DATA_WIDTH-1:0] data;
    integer i, j, rank_id;
    reg [3:0] rankwid;
    
    begin
      if (valid_bus(addr))
        begin
          case (addr)
            // most bits in PIR are self clearing if init is triggered
            `PIR: begin
              // PIR init bits are self clearing if INIT bit is set; bypass 
              // bits are self clearing - for pir[15:0] due to unpredictability
              // of status, they are included in skip_special_bits.
              pir[17: 0] = (data[0]) ? {18{1'b0}} : {data[17:4],1'b0,data[2:0]};
              pir[19:18] = data[19:18];
              pir[28:20] = {7{1'b0}}; 
              `ifdef DWC_DDRPHY_EMUL_XILINX
                pir[30:29] = 2'b11;
              `else
                pir[30:29] = (data[0]) ? 2'b00   : data[30:29];
              `endif
              pir[31]    = {1{1'b0}}; 
            end
`ifdef DWC_PUB_CLOCK_GATING
            `CGCR: cgcr = data;
`endif
            `CGCR1: begin 
                      cgcr1[2:0]   = data[2:0]; // AC clock gating bits
                      cgcr1[11:3]  = {{(9-pNO_OF_BYTES){1'b0}}, data[3 +: pNO_OF_BYTES]}; // DX ctl_clk gating bits
                      cgcr1[20:12] = {{(9-pNO_OF_BYTES){1'b0}}, data[12 +: pNO_OF_BYTES]}; // DX ddr_clk gating bits
                      cgcr1[29:21] = {{(9-pNO_OF_BYTES){1'b0}}, data[21 +: pNO_OF_BYTES]}; // DX ctl_rd_clk gating bits
                      cgcr1[31:30] = 2'b00;  // reserved bits
                    end  
            `PGCR0: begin
               pgcr0   = {data[31:22],1'b0,data[20:0]};
               // clear zcal related status
               if (data[1] == 1'b1) begin
                 clear_zcal_status;
               end
               // When the INITBYP bit of PIR (PIR[31]) is set to 1, as per the PUB document PIR[15:0] bits should be cleared.
               // Here we are expecting these bits to be 0 using the below "if" statement --- Added on 02/03/12
               if (data[3]==1'b1) begin
                 clear_pir_registers;
               end
            end
            `PGCR1:   pgcr1   = data;
            `PGCR2:   pgcr2   = {1'd0, data[30:28], 8'd0, data[19:0]}; // PGCR2 DTPMXTMR is always 0 after change 1099721 && PGCR2.NOBUB [18] is reserved but RW
            `PGCR3:   pgcr3   = data;
            `PGCR4:   pgcr4   = data;
`ifdef DWC_DDRPHY_PLL_TYPEB
            `PGCR5:   pgcr5   = {data[31:12], {8{1'b0}}, data[3:0]};
`else
            `PGCR5:   pgcr5   = {data[31:16], {2{1'b0}}, data[13:12], {8{1'b0}}, data[3:0]};
`endif
            `PGCR6:   pgcr6   = data;
            `PGCR7:   pgcr7   = data;
            `PGCR8:   pgcr8   = data;
`ifdef DWC_DDRPHY_PLL_TYPEB
            `PLLCR0:  pllcr0  = data;
            `PLLCR1:  pllcr1  = data;
            `PLLCR2:  pllcr2  = data;
            `PLLCR3:  pllcr3  = data;
            `PLLCR4:  pllcr4  = data;
            `PLLCR5:  pllcr5  = data;
`else
            `PLLCR:   pllcr   = data;
`endif
            `PTR0:    ptr0    = data;
            `PTR1:    ptr1    = data;
            `PTR2:    ptr2    = data;
            `PTR3:    ptr3    = data;
            `PTR4:    ptr4    = data;
            `PTR5:    ptr5    = data;
            `PTR6:    ptr6    = data;
            `ACMDLR0:  begin
              acmdlr0 = data;
              acmdlr_iprd_value  = data[0  +: `LCDL_DLY_WIDTH];              
              acmdlr_tprd_value  = data[16 +: `LCDL_DLY_WIDTH];              
            end
            `ACMDLR1:  begin
              acmdlr1 = data[0  +: `LCDL_DLY_WIDTH];
              acmdlr_mdld_value  = data[0  +: `LCDL_DLY_WIDTH];              
            end
            `ACLCDLR:
              aclcdlr  = {{23{1'b0}},data[8:0]};
            `ACBDLR0:
              acbdlr0  = {{2{1'b0}},
                          ((`DWC_CK_WIDTH>=4)?data[29:24]:6'd0),
                          {2{1'b0}},
                          ((`DWC_CK_WIDTH>=3)?data[21:16]:6'd0),
                          {2{1'b0}},
                          ((`DWC_CK_WIDTH>=2)?data[13:8]:6'd0),
                          {2{1'b0}},
                          ((`DWC_CK_WIDTH>=1)?data[5:0]:6'd0)};
            `ACBDLR1:
              acbdlr1  = {{2{1'b0}},data[29:24],{2{1'b0}},data[21:16],{2{1'b0}},data[13:8],{2{1'b0}},data[5:0]};
            `ACBDLR2:
              acbdlr2  = {{2{1'b0}},data[29:24],{2{1'b0}},data[21:16],{2{1'b0}},data[13:8],{2{1'b0}},data[5:0]};
            `ACBDLR3:
              acbdlr3 = {{2{1'b0}},
                         ((`DWC_PHY_CS_N_WIDTH>=4)?data[29:24]:6'd0),
                         {2{1'b0}},                                
                         ((`DWC_PHY_CS_N_WIDTH>=3)?data[21:16]:6'd0),
                         {2{1'b0}},                                
                         ((`DWC_PHY_CS_N_WIDTH>=2)?data[13:8] :6'd0),
                         {2{1'b0}},                                
                         ((`DWC_PHY_CS_N_WIDTH>=1)?data[5:0]  :6'd0)};
            `ACBDLR4:
              acbdlr4 = {{2{1'b0}},
                         ((`DWC_PHY_ODT_WIDTH>=4)?data[29:24]:6'd0),
                         {2{1'b0}},                               
                         ((`DWC_PHY_ODT_WIDTH>=3)?data[21:16]:6'd0),
                         {2{1'b0}},                               
                         ((`DWC_PHY_ODT_WIDTH>=2)?data[13:8] :6'd0),
                         {2{1'b0}},                               
                         ((`DWC_PHY_ODT_WIDTH>=1)?data[5:0]  :6'd0)};
            `ACBDLR5:
              acbdlr5 = {{2{1'b0}},
                         ((`DWC_PHY_CKE_WIDTH>=4)?data[29:24]:6'd0),
                         {2{1'b0}},                               
                         ((`DWC_PHY_CKE_WIDTH>=3)?data[21:16]:6'd0),
                         {2{1'b0}},                               
                         ((`DWC_PHY_CKE_WIDTH>=2)?data[13:8] :6'd0),
                         {2{1'b0}},                               
                         ((`DWC_PHY_CKE_WIDTH>=1)?data[5:0]  :6'd0)};
            `ACBDLR6:
              acbdlr6  = {{2{1'b0}},data[29:24],{2{1'b0}},data[21:16],{2{1'b0}},data[13:8],{2{1'b0}},data[5:0]};
            `ACBDLR7:
              acbdlr7  = {{2{1'b0}},data[29:24],{2{1'b0}},data[21:16],{2{1'b0}},data[13:8],{2{1'b0}},data[5:0]};
            `ACBDLR8:
              acbdlr8  = {{2{1'b0}},data[29:24],{2{1'b0}},data[21:16],{2{1'b0}},data[13:8],{2{1'b0}},data[5:0]};
            `ACBDLR9:
              acbdlr9  = {{2{1'b0}},data[29:24],{2{1'b0}},data[21:16],{2{1'b0}},data[13:8],{2{1'b0}},data[5:0]};
            `ACBDLR10:
              acbdlr10 = {{2{1'b0}},
                          ((`DWC_CID_WIDTH>=3)?data[29:24]:6'd0),
                          {2{1'b0}},                           
                          ((`DWC_CID_WIDTH>=2)?data[21:16]:6'd0),
                          {2{1'b0}},                           
                          ((`DWC_CID_WIDTH>=1)?data[13:8]:6'd0),
                          {2{1'b0}},                               
                          data[5:0]}; 
            `ACBDLR11:
              acbdlr11 = {{2{1'b0}},
                          ((`DWC_PHY_CS_N_WIDTH>=8)?data[29:24]:6'd0),
                          {2{1'b0}},                                
                          ((`DWC_PHY_CS_N_WIDTH>=7)?data[21:16]:6'd0),
                          {2{1'b0}},                                
                          ((`DWC_PHY_CS_N_WIDTH>=6)?data[13:8] :6'd0),
                          {2{1'b0}},                                
                          ((`DWC_PHY_CS_N_WIDTH>=5)?data[5:0]  :6'd0)}; 
            `ACBDLR12:
              acbdlr12 = {{2{1'b0}},
                          ((`DWC_PHY_CS_N_WIDTH>=12)?data[29:24]:6'd0),
                          {2{1'b0}},
                          ((`DWC_PHY_CS_N_WIDTH>=11)?data[21:16]:6'd0),
                          {2{1'b0}},
                          ((`DWC_PHY_CS_N_WIDTH>=10)?data[13:8] :6'd0),
                          {2{1'b0}},
                          ((`DWC_PHY_CS_N_WIDTH>=9)?data[5:0]  :6'd0)};
            `ACBDLR13:
              acbdlr13 = {{2{1'b0}},
                          ((`DWC_PHY_ODT_WIDTH>=8)?data[29:24]:6'd0),
                          {2{1'b0}},                               
                          ((`DWC_PHY_ODT_WIDTH>=7)?data[21:16]:6'd0),
                          {2{1'b0}},                               
                          ((`DWC_PHY_ODT_WIDTH>=6)?data[13:8] :6'd0),
                          {2{1'b0}},                               
                          ((`DWC_PHY_ODT_WIDTH>=5)?data[5:0]  :6'd0)};
            `ACBDLR14:
              acbdlr14 = {{2{1'b0}},
                          ((`DWC_PHY_CKE_WIDTH>=8)?data[29:24]:6'd0),  
                          {2{1'b0}},                                   
                          ((`DWC_PHY_CKE_WIDTH>=7)?data[21:16]:6'd0),  
                          {2{1'b0}},                                   
                          ((`DWC_PHY_CKE_WIDTH>=6)?data[13:8] :6'd0),  
                          {2{1'b0}},                                   
                          ((`DWC_PHY_CKE_WIDTH>=5)?data[5:0]  :6'd0)};                   
            `RANKIDR: 
              rankidr  = {{12{1'b0}}, data[19:16], {12{1'b0}}, data[3:0]};     
            `RIOCR0:  riocr0    = {{4{1'b0}},
                                   (data[27] & (`DWC_PHY_CS_N_WIDTH==12)), 
                                   (data[26] & (`DWC_PHY_CS_N_WIDTH>=11)),
                                   (data[25] & (`DWC_PHY_CS_N_WIDTH>=10)), 
                                   (data[24] & (`DWC_PHY_CS_N_WIDTH>=9)), 
                                   (data[23] & (`DWC_PHY_CS_N_WIDTH>=8)),
                                   (data[22] & (`DWC_PHY_CS_N_WIDTH>=7)),
                                   (data[21] & (`DWC_PHY_CS_N_WIDTH>=6)), 
                                   (data[20] & (`DWC_PHY_CS_N_WIDTH>=5)),
                                   (data[19] & (`DWC_PHY_CS_N_WIDTH>=4)),
                                   (data[18] & (`DWC_PHY_CS_N_WIDTH>=3)), 
                                   (data[17] & (`DWC_PHY_CS_N_WIDTH>=2)), 
                                   (data[16] & (`DWC_PHY_CS_N_WIDTH>=1)),
                                   {4{1'b0}},
                                   data[11:0]};
            `RIOCR1:  riocr1    = {(data[31] & (`DWC_PHY_ODT_WIDTH>=8)),
                                   (data[30] & (`DWC_PHY_ODT_WIDTH>=7)),
                                   (data[29] & (`DWC_PHY_ODT_WIDTH>=6)), 
                                   (data[28] & (`DWC_PHY_ODT_WIDTH>=5)),
                                   (data[27] & (`DWC_PHY_ODT_WIDTH>=4)),
                                   (data[26] & (`DWC_PHY_ODT_WIDTH>=3)), 
                                   (data[25] & (`DWC_PHY_ODT_WIDTH>=2)), 
                                   (data[24] & (`DWC_PHY_ODT_WIDTH>=1)),
                                   (data[23] & (`DWC_PHY_ODT_WIDTH>=8)),
                                   (data[22] & (`DWC_PHY_ODT_WIDTH>=7)),
                                   (data[21] & (`DWC_PHY_ODT_WIDTH>=6)), 
                                   (data[20] & (`DWC_PHY_ODT_WIDTH>=5)),
                                   (data[19] & (`DWC_PHY_ODT_WIDTH>=4)),
                                   (data[18] & (`DWC_PHY_ODT_WIDTH>=3)), 
                                   (data[17] & (`DWC_PHY_ODT_WIDTH>=2)), 
                                   (data[16] & (`DWC_PHY_ODT_WIDTH>=1)),
                                   (data[15] & (`DWC_PHY_CKE_WIDTH==8)), 
                                   (data[14] & (`DWC_PHY_CKE_WIDTH>=7)),
                                   (data[13] & (`DWC_PHY_CKE_WIDTH>=6)), 
                                   (data[12] & (`DWC_PHY_CKE_WIDTH>=5)), 
                                   (data[11] & (`DWC_PHY_CKE_WIDTH>=4)),
                                   (data[10] & (`DWC_PHY_CKE_WIDTH>=3)), 
                                   (data[9]  & (`DWC_PHY_CKE_WIDTH>=2)),
                                   (data[8]  & (`DWC_PHY_ODT_WIDTH>=1)),
                                   (data[7] & (`DWC_PHY_CKE_WIDTH==8)), 
                                   (data[6] & (`DWC_PHY_CKE_WIDTH>=7)),
                                   (data[5] & (`DWC_PHY_CKE_WIDTH>=6)), 
                                   (data[4] & (`DWC_PHY_CKE_WIDTH>=5)), 
                                   (data[3] & (`DWC_PHY_CKE_WIDTH>=4)),
                                   (data[2] & (`DWC_PHY_CKE_WIDTH>=3)), 
                                   (data[1]  & (`DWC_PHY_CKE_WIDTH>=2)),
                                   (data[0]  & (`DWC_PHY_ODT_WIDTH>=1))};
            `RIOCR2:  riocr2    = {{2{1'b0}}, data[29:0]};
            `RIOCR3:  riocr3    = {{2{1'b0}}, data[29:0]};
            `RIOCR4:  riocr4    = {{{{(16-(2*`DWC_PHY_CKE_WIDTH)){1'b0}},{(2*`DWC_PHY_CKE_WIDTH){1'b1}}}& data[31:16]},
                                   {{{(16-(2*`DWC_PHY_CKE_WIDTH)){1'b0}},{(2*`DWC_PHY_CKE_WIDTH){1'b1}}}& data[15:0]}}  ;
            `RIOCR5:  riocr5    =  {{{{(16-(2*`DWC_PHY_ODT_WIDTH)){1'b0}},{(2*`DWC_PHY_ODT_WIDTH){1'b1}}}& data[31:16]},
                                   {{{(16-(2*`DWC_PHY_ODT_WIDTH)){1'b0}},{(2*`DWC_PHY_ODT_WIDTH){1'b1}}}& data[15:0]}}  ;
            `ACIOCR0:  aciocr0  = {data[31:26], 
                                  {12{1'b0}},
                                  (data[13]&(`DWC_CK_WIDTH==4)), (data[12]&(`DWC_CK_WIDTH>=3)), (data[11]&(`DWC_CK_WIDTH>=2)), (data[10]&(`DWC_CK_WIDTH>=1)),
                                  {1'b0},
                                  (data[8] &(`DWC_CK_WIDTH==4)),(data[7] &(`DWC_CK_WIDTH>=3)), (data[6] &(`DWC_CK_WIDTH>=2)), (data[5] &(`DWC_CK_WIDTH>=1)),
                                   data[4], {1{1'b0}}, data[2], {1{1'b0}}, data[0]};
            `ACIOCR1:  aciocr1 = data;
            `ACIOCR2:  aciocr2 = data;
            `ACIOCR3:  aciocr3 = {data[31:16], {8{1'b0}}, data[7:0]};
            `ACIOCR4:  aciocr4 = {data[31:16], {8{1'b0}}, data[7:0]};
            `ACIOCR5:  aciocr5  = data;
            `DXCCR:   dxccr   = data;
            `DSGCR:   dsgcr   = {{7{1'b0}},data[24:0]};
            `DCR:     dcr     = {{1{1'b0}},data[30:27],{9{1'b0}},data[17:0]};
            `DTPR0:   dtpr0   = data;
            `DTPR1:   dtpr1   = data;
            `DTPR2:   dtpr2   = data;      
            `DTPR3:   dtpr3   = data;
            `DTPR4:   dtpr4   = data;
            `DTPR5:   dtpr5   = data;
            `DTPR6:   dtpr6   = data;
            `SCHCR0:  schcr0   = data;
            `SCHCR1:  schcr1   = data;
            `MR0_REG: begin
              case(ddr_mode)
                `DDR4_MODE:   mr0 = {16'b0, data[15:0]};
                `DDR3_MODE:   mr0 = {16'b0, data[15:0]};
                `DDR2_MODE:   mr0 = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr0 = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr0 = {24'b0, data[7:0]};
                default:      mr0 = {16'b0, data[15:0]};  // DDRG2MPHY - should throw an error here?
              endcase
            end 
            `MR1_REG: begin
              rankwid = rankidr[0 +: 4];  
              case(ddr_mode)
                `DDR4_MODE:   mr1[rankwid] = {16'b0, data[15:0]};
                `DDR3_MODE:   mr1[rankwid] = {16'b0, data[15:0]};
                `DDR2_MODE:   mr1[0] = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr1[0] = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr1[0] = {24'b0, data[7:0]};
                default:      mr1[0] = {16'b0, data[15:0]};  // DDRG2MPHY - should throw an error here?
              endcase
            end
            `MR2_REG: begin
              rankwid = rankidr[0 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   mr2[rankwid] = {16'b0, data[15:0]};
                `DDR3_MODE:   mr2[rankwid] = {16'b0, data[15:0]};
                `DDR2_MODE:   mr2[0] = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr2[0] = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr2[0] = {24'b0, data[7:0]};  
                default:      mr2[0] = {16'b0, data[15:0]};  // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR3_REG: begin
              rankwid = rankidr[0 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   mr3[0] = {16'b0, data[15:0]};
                `DDR3_MODE:   mr3[0] = {16'b0, data[15:0]};
                `DDR2_MODE:   mr3[0] = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr3[rankwid] = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr3[rankwid] = {24'b0, data[7:0]};
                default:      mr3[0] = {16'b0, data[15:0]};  // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR4_REG: begin
              case(ddr_mode)
                `DDR4_MODE:   mr4 = {16'b0, data[15:0]};
                `DDR3_MODE:   mr4 = {16'b0, data[15:0]};
                `DDR2_MODE:   mr4 = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr4 = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr4 = {24'b0, data[7:0]};
                default:      mr4 = {16'b0, data[15:0]};  // DDRG3MPHY - should we throw an error here?
              endcase
            end
            `MR5_REG: begin
              rankwid = rankidr[0 +: 4]; 
              case(ddr_mode)
                `DDR4_MODE:   mr5[rankwid] = {16'b0, data[15:0]};
                `DDR3_MODE:   mr5[0] = {16'b0, data[15:0]};
                `DDR2_MODE:   mr5[0] = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr5[0] = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr5[0] = {24'b0, data[7:0]};
                default:      mr5[0] = {16'b0, data[15:0]};  // DDRG3MPHY - should we throw an error here?
              endcase
            end
            `MR6_REG: begin
              rankwid = rankidr[0 +: 4];  
              case(ddr_mode)
                `DDR4_MODE:   mr6[rankwid] = {16'b0, data[15:0]};
                `DDR3_MODE:   mr6[0] = {16'b0, data[15:0]};
                `DDR2_MODE:   mr6[0] = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr6[0] = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr6[0] = {24'b0, data[7:0]};
                default:      mr6[0] = {16'b0, data[15:0]};  // DDRG3MPHY - should we throw an error here?
              endcase
            end
            `MR7_REG: begin
              case(ddr_mode)
                `DDR4_MODE:   mr7 = {16'b0, data[15:0]};
                `DDR3_MODE:   mr7 = {16'b0, data[15:0]};
                `DDR2_MODE:   mr7 = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr7 = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr7 = {24'b0, data[7:0]};
                default:      mr7 = {16'b0, data[15:0]};  // DDRG3MPHY - should we throw an error here?
              endcase
            end
            `MR11_REG: begin
              rankwid = rankidr[0 +: 4]; 
              case(ddr_mode)
                `DDR4_MODE:   mr11[0] = {16'b0, data[15:0]};
                `DDR3_MODE:   mr11[0] = {16'b0, data[15:0]};
                `DDR2_MODE:   mr11[0] = {16'b0, data[15:0]};
                `LPDDR2_MODE: mr11[0] = {24'b0, data[7:0]};
                `LPDDR3_MODE: mr11[rankwid] = {24'b0, data[7:0]};
                default:      mr11[0] = {16'b0, data[15:0]};  // DDRG3MPHY - should we throw an error here?
              endcase
            end
            `ODTCR: begin
              rankwid = rankidr[0 +: 4];
              odtcr[rankwid]   = {4'b0000,
                                 {{{(12-pNO_OF_PRANKS){1'b0}}, {pNO_OF_PRANKS{1'b1}}} & data[27:16]},
                                 4'b000,
                                 {{{(12-pNO_OF_PRANKS){1'b0}}, {pNO_OF_PRANKS{1'b1}}} & data[11:0]}};
            end
            `AACR:    aacr     = data[31:0];
            `DTCR0:   dtcr0    = { data[31:28],
                                   2'b00,
                                   data[25:24],
                                   data[23:16],
                                   data[15:11],
                                   3'd0,
                                   data[7:6],
                                   2'b00,
                                   data[3:0]
                                };

            `DTCR1:   dtcr1   = {{{{(16-pNO_OF_LRANKS){1'b0}}, {pNO_OF_LRANKS{1'b1}}} &  data[31:16]}
                                 , 2'd0
                                 , data[13:12]
                                 , data[11: 8]
                                 , 1'd0
                                 , data[ 6: 4]
                                 , 1'd0
                                 , data[ 2: 0]
                                };
            `DTAR0:   dtar0 = {2'd0, data[29:20], 2'd0, data[17:0]};
            `DTAR1:   dtar1 = {7'd0, data[24:16], 7'd0, data[8:0]};
            `DTAR2:   dtar2 = {7'd0, data[24:16], 7'd0, data[8:0]};
            `DTDR0:   dtdr0   = data;
            `DTDR1:   dtdr1   = data;
	    
            `UDDR0:   uddr0   = data;
            `UDDR1:   uddr1   = data;

            `RDIMMGCR0: rdimmgcr0 = data;
            `RDIMMGCR1: rdimmgcr1 = data;
            `RDIMMGCR2: rdimmgcr2 = data;
            `RDIMMCR0 : begin 
              rankwid = rankidr[0 +: 4];
              rdimmcr0[rankwid]  = data;          
            end
            `RDIMMCR1 : begin 
              rankwid = rankidr[0 +: 4];
              rdimmcr1[rankwid]  = data;           
            end
            `RDIMMCR2 : begin 
              rankwid = rankidr[0 +: 4];
              rdimmcr2[rankwid]  = data;            
            end
            `RDIMMCR3 : begin 
              rankwid = rankidr[0 +: 4];
              rdimmcr3[rankwid]  = data;        
            end
            `RDIMMCR4 : begin 
              rankwid = rankidr[0 +: 4];
              rdimmcr4[rankwid]  = data;           
            end
            `DCUAR    : dcuar = data;
            `DCUDR    : begin 
              dcudr = data;

              // write the data to the selected cache
              write_dcu_cache(data);

              // increment cache addresses if configured to do so
              auto_increment_cache_address; 
            end
              
            `DCURR    : begin 
              dcurr = data;

              // execute the DCU instruction
              case (data[3:0])
                `DCU_RUN:       -> dcu_start_run;
                `DCU_STOP:      -> dcu_stop_run;
                `DCU_STOP_LOOP: -> dcu_stop_loop_run;
                `DCU_RESET:     -> dcu_start_reset;
              endcase // case (dcu_inst)
            end
            `DCULR    : dculr     = data;
            `DCUGCR   : dcugcr    = data;
            `DCUTPR   : dcutpr    = data;
                                                  
            `BISTRR   : bistrr    = data;
            `BISTMSKR0: bistmskr0 = {(12'd0|{data[20 +: `DWC_PHY_CS_N_WIDTH]}), data[19], 1'b0, data[17:0]};
            `BISTMSKR1: bistmskr1 = {data[31:27],
                                     (3'd0|{data[24 +: `DWC_CID_WIDTH]}),                 // CID mask bits 
                                     (8'd0|{data[16 +: `DWC_PHY_ODT_WIDTH]}),             // ODT mask bits   
                                     (8'd0|{data[8  +: `DWC_PHY_CKE_WIDTH]}),             // CKE mask bits
                                     data[7:4], 
                                     (`DWC_DX_NO_OF_DQS== 2)? data[3:0]: 4'd0};
            `BISTMSKR2: bistmskr2 = data;
            `BISTWCR  : bistwcr   = data;
            `BISTLSR  : begin
                          bistlsr                 = data;
                          first_access_lfsr_write = 1'b1;
                          first_access_lfsr_read  = 1'b1;
                        end
            `BISTAR0  : bistar0   = data;
            `BISTAR1  : bistar1   = data;
            `BISTAR2  : bistar2   = data;
            `BISTAR3  : bistar3   = data;
            `BISTAR4  : bistar4   = data;
            `BISTUDPR : bistudpr  = data;
            `IOVCR0   : iovcr0    = data;
            `IOVCR1   : iovcr1    = data;
            `VTCR0    : vtcr0     = data;
            `VTCR1    : vtcr1     = data;
            `GPR0     : gpr0      = data;
            `GPR1     : gpr1      = data;
            `CATR0    : catr0     = data;
            `CATR1    : catr1     = data;
            `DQSDR0   : dqsdr0    = data;
            `DQSDR1   : dqsdr1    = data;
            `DQSDR2   : dqsdr2    = data;
          endcase // case(addr)

          if (addr == `ZQCR ) zqcr = {{4{1'b0}},data[27],{2{1'b0}},data[24:8],{5{1'b0}},data[2:1],1'b0};

          for (i=0;i<`DWC_NO_OF_ZQ_SEG;i=i+1)
          begin
            if(addr == (`ZQ0PR + 8'h4*i)) begin
              zqnpr[i] = {data[31:28],{4{1'b0}},data[23:8], {8{1'b0}}};
            end
            if(addr == (`ZQ0DR + 8'h4*i)) begin
              zqndr[i][7:0]   = data[0+:`ZCTRL_IMP_WIDTH];
              zqndr[i][15:8]  = data[8+:`ZCTRL_IMP_WIDTH];
              zqndr[i][23:16] = data[16+:`ZCTRL_IMP_WIDTH];
              zqndr[i][31:24] = data[24+:`ZCTRL_IMP_WIDTH];
            end
          end
 
          for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
            begin
              if (addr == (`DX0GCR0    + `DX_REG_RANGE*i)) dxngcr0[i]    = data;
              if (addr == (`DX0GCR1    + `DX_REG_RANGE*i)) dxngcr1[i]    = data;
              if (addr == (`DX0GCR2    + `DX_REG_RANGE*i)) dxngcr2[i]    = data;
              if (addr == (`DX0GCR3    + `DX_REG_RANGE*i)) dxngcr3[i]    = data;
              if (addr == (`DX0GCR4    + `DX_REG_RANGE*i)) dxngcr4[i]    = data;
`ifndef DWC_NO_VREF_TRAIN                                                     
              if (addr == (`DX0GCR5    + `DX_REG_RANGE*i)) dxngcr5[i]    = data;
              if (addr == (`DX0GCR6    + `DX_REG_RANGE*i)) dxngcr6[i]    = data;
`endif
              if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                  if (addr == (`DX0GCR7    + `DX_REG_RANGE*i)) dxngcr7[i]    = data;
                  if (addr == (`DX0GCR8    + `DX_REG_RANGE*i)) dxngcr8[i]    = data;
                  if (addr == (`DX0GCR9    + `DX_REG_RANGE*i)) dxngcr9[i]    = data;
              end else begin
                  if (addr == (`DX0GCR7    + `DX_REG_RANGE*i)) dxngcr7[i]    = $random;
              end

              if (addr == (`DX0MDLR0   + `DX_REG_RANGE*i)) dxnmdlr0[i]   = data;
              if (addr == (`DX0MDLR1   + `DX_REG_RANGE*i)) dxnmdlr1[i]   = data;

              if (addr == (`DX0BDLR0  + `DX_REG_RANGE*i)) dxnbdlr0[i]  = data;
              if (addr == (`DX0BDLR1  + `DX_REG_RANGE*i)) dxnbdlr1[i]  = data;
              if (addr == (`DX0BDLR2  + `DX_REG_RANGE*i)) dxnbdlr2[i]  = data;
              if (addr == (`DX0BDLR3  + `DX_REG_RANGE*i)) dxnbdlr3[i]  = data;
              if (addr == (`DX0BDLR4  + `DX_REG_RANGE*i)) dxnbdlr4[i]  = data;
`ifdef DWC_DDRPHY_EMUL_XILINX
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dxnbdlr5[i][ 31:24]  = {(data[31:24]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=4)}}) }; 
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dxnbdlr5[i][ 23:16]  = {(data[23:16]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=3)}}) }; 
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dxnbdlr5[i][ 15: 8]  = {(data[15: 8]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=2)}}) };
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dxnbdlr5[i][  7: 0]  = {(data[ 7: 0]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=1)}}) };

              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) dxnbdlr6[i][ 31:24]  = {(data[31:24]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS==4)}}) }; 
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) dxnbdlr6[i][ 23:16]  = {(data[23:16]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=3)}}) }; 
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) dxnbdlr6[i][ 15: 8]  = {(data[15: 8]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=2)}}) };
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) dxnbdlr6[i][  7: 0]  = {(data[ 7: 0]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=1)}}) };
`else
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dxnbdlr5[i]  = data;
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) dxnbdlr6[i]  = data;
`endif // 
              if (`DWC_DX_NO_OF_DQS == 2'd2) begin
		            if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) dxnbdlr7[i]  = data;
`ifdef DWC_DDRPHY_EMUL_XILINX
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][ 31:24]  = {(data[31:24]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=4)}}) }; 
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][ 23:16]  = {(data[23:16]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=3)}}) }; 
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][ 15: 8]  = {(data[15: 8]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=2)}}) };
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][  7: 0]  = {(data[ 7: 0]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=1)}}) };

                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][ 31:24]  = {(data[31:24]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS==4)}}) }; 
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][ 23:16]  = {(data[23:16]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=3)}}) }; 
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][ 15: 8]  = {(data[15: 8]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=2)}}) };
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][  7: 0]  = {(data[ 7: 0]&{(4+pQ_WINDOW_WIDTH){(`DWC_NO_OF_RANKS>=1)}}) };
`else
		            if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i]  = data;
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i]  = data;
`endif
		          end else begin
		            if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) dxnbdlr7[i]  = $random;
`ifdef DWC_DDRPHY_EMUL_XILINX
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][ 31:24]  = {(4+pQ_WINDOW_WIDTH){1'b0} }; 
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][ 23:16]  = {(4+pQ_WINDOW_WIDTH){1'b0} }; 
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][ 15: 8]  = {(4+pQ_WINDOW_WIDTH){1'b0} };
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i][  7: 0]  = {(4+pQ_WINDOW_WIDTH){1'b0} };

                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][ 31:24]  = {(4+pQ_WINDOW_WIDTH){1'b0} }; 
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][ 23:16]  = {(4+pQ_WINDOW_WIDTH){1'b0} }; 
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][ 15: 8]  = {(4+pQ_WINDOW_WIDTH){1'b0} };
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i][  7: 0]  = {(4+pQ_WINDOW_WIDTH){1'b0} };
`else
		            if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) dxnbdlr8[i]  = $random;
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) dxnbdlr9[i]  = $random;
`endif
		          end // else: !if(`DWC_DX_NO_OF_DQS == 2'd2)

              if (addr == (`DX0BDLR0  + `DX_REG_RANGE*i)) dq0wbd_value[i]  = data[ 5: 0];
              if (addr == (`DX0BDLR0  + `DX_REG_RANGE*i)) dq1wbd_value[i]  = data[13: 8];
              if (addr == (`DX0BDLR0  + `DX_REG_RANGE*i)) dq2wbd_value[i]  = data[21:16];
              if (addr == (`DX0BDLR0  + `DX_REG_RANGE*i)) dq3wbd_value[i]  = data[29:24];

              if (addr == (`DX0BDLR1  + `DX_REG_RANGE*i)) dq4wbd_value[i]  = data[ 5: 0];
              if (addr == (`DX0BDLR1  + `DX_REG_RANGE*i)) dq5wbd_value[i]  = data[13: 8];
              if (addr == (`DX0BDLR1  + `DX_REG_RANGE*i)) dq6wbd_value[i]  = data[21:16];
              if (addr == (`DX0BDLR1  + `DX_REG_RANGE*i)) dq7wbd_value[i]  = data[29:24];

              if (addr == (`DX0BDLR2  + `DX_REG_RANGE*i)) dmwbd_value[i]   = data[ 5: 0];
              if (addr == (`DX0BDLR2  + `DX_REG_RANGE*i)) dswbd_value[i]   = data[13: 8];
              if (addr == (`DX0BDLR2  + `DX_REG_RANGE*i)) dqsoebd_value[i] = data[21:16];

              if (addr == (`DX0BDLR3  + `DX_REG_RANGE*i)) dq0rbd_value[i]  = data[ 5: 0];
              if (addr == (`DX0BDLR3  + `DX_REG_RANGE*i)) dq1rbd_value[i]  = data[13: 8];
              if (addr == (`DX0BDLR3  + `DX_REG_RANGE*i)) dq2rbd_value[i]  = data[21:16];
              if (addr == (`DX0BDLR3  + `DX_REG_RANGE*i)) dq3rbd_value[i]  = data[29:24];

              if (addr == (`DX0BDLR4  + `DX_REG_RANGE*i)) dq4rbd_value[i]  = data[ 5: 0];
              if (addr == (`DX0BDLR4  + `DX_REG_RANGE*i)) dq5rbd_value[i]  = data[13: 8];
              if (addr == (`DX0BDLR4  + `DX_REG_RANGE*i)) dq6rbd_value[i]  = data[21:16];
              if (addr == (`DX0BDLR4  + `DX_REG_RANGE*i)) dq7rbd_value[i]  = data[29:24];
              
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dmrbd_value[i]   = data[ 5: 0];
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dsrbd_value[i]   = data[13: 8];
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) dsnrbd_value[i]  = data[21:16];

              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) pddbd_value[i]   = data[ 5: 0];
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) pdrbd_value[i]   = data[13: 8];
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) terbd_value[i]   = data[21:16];

              if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) x4dmwbd_value[i]   = data[ 5: 0];
                if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) x4dswbd_value[i]   = data[13: 8];
                if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) x4dqsoebd_value[i] = data[21:16];
`ifdef DWC_DDRPHY_EMUL_XILINX
/*
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4_value[i]   = data[ 7: 0];
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4_value[i]   = data[15: 8];
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4_value[i]   = data[23:16];
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4_value[i]   = data[31:24];

                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4_value[i]   = data[ 7: 0];
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4_value[i]   = data[15: 8];
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4_value[i]   = data[23:16];
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4_value[i]   = data[31:24];
*/
`else
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4dmrbd_value[i]   = data[ 5: 0];
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4dsrbd_value[i]   = data[13: 8];
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) x4dsnrbd_value[i]  = data[21:16];

                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4pddbd_value[i]   = data[ 5: 0];
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4pdrbd_value[i]   = data[13: 8];
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) x4terbd_value[i]   = data[21:16];
`endif
              end // if (`DWC_DX_NO_OF_DQS == 2'd2)
               
              if (addr == (`DX0LCDLR0 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];
                dxnlcdlr0[rankwid][i][0 +: `LCDL_DLY_WIDTH] = data[0 +: `LCDL_DLY_WIDTH];
                `ifdef DWC_DDRPHY_X4X2
                  dxnlcdlr0[rankwid][i][16 +: `LCDL_DLY_WIDTH] = data[16 +: `LCDL_DLY_WIDTH];
                `endif
              end
              if (addr == (`DX0LCDLR1 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];
                dxnlcdlr1[rankwid][i][0 +: `LCDL_DLY_WIDTH] = data[0 +: `LCDL_DLY_WIDTH];
                `ifdef DWC_DDRPHY_X4X2
                  dxnlcdlr1[rankwid][i][16 +: `LCDL_DLY_WIDTH] = data[16 +: `LCDL_DLY_WIDTH];
                `endif
              end
//`ifdef DWC_DDRPHY_EMUL_XILINX
//              if (addr == (`DX0LCDLR2  + `DX_REG_RANGE*i)) dxnlcdlr2[i][(23+pDQ_DELAY_WIDTH):24]  = {(data[(23+pDQ_DELAY_WIDTH):24]&{pDQ_DELAY_WIDTH{(`DWC_NO_OF_RANKS==4)}}) };
//              if (addr == (`DX0LCDLR2  + `DX_REG_RANGE*i)) dxnlcdlr2[i][(15+pDQ_DELAY_WIDTH):16]  = {(data[(15+pDQ_DELAY_WIDTH):16]&{pDQ_DELAY_WIDTH{(`DWC_NO_OF_RANKS>=3)}}) };
//              if (addr == (`DX0LCDLR2  + `DX_REG_RANGE*i)) dxnlcdlr2[i][(7 +pDQ_DELAY_WIDTH): 8]  = {(data[(7 +pDQ_DELAY_WIDTH): 8]&{pDQ_DELAY_WIDTH{(`DWC_NO_OF_RANKS>=2)}}) };
//              if (addr == (`DX0LCDLR2  + `DX_REG_RANGE*i)) dxnlcdlr2[i][(pDQ_DELAY_WIDTH -1): 0]  = {(data[(pDQ_DELAY_WIDTH-1) : 0]&{pDQ_DELAY_WIDTH{(`DWC_NO_OF_RANKS>=1)}}) };
//`else
              if (addr == (`DX0LCDLR2 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];
                dxnlcdlr2[rankwid][i][0 +: `LCDL_DLY_WIDTH] = data[0 +: `LCDL_DLY_WIDTH];
                `ifdef DWC_DDRPHY_X4X2
                  dxnlcdlr2[rankwid][i][16 +: `LCDL_DLY_WIDTH] = data[16 +: `LCDL_DLY_WIDTH];
                `endif
              end
//`endif
              if (addr == (`DX0LCDLR3 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];
                dxnlcdlr3[rankwid][i][0 +: `LCDL_DLY_WIDTH] = data[0 +: `LCDL_DLY_WIDTH];
                `ifdef DWC_DDRPHY_X4X2
                  dxnlcdlr3[rankwid][i][16 +: `LCDL_DLY_WIDTH] = data[16 +: `LCDL_DLY_WIDTH];
                `endif
              end
              if (addr == (`DX0LCDLR4 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];
                dxnlcdlr4[rankwid][i][0 +: `LCDL_DLY_WIDTH] = data[0 +: `LCDL_DLY_WIDTH];
                `ifdef DWC_DDRPHY_X4X2
                  dxnlcdlr4[rankwid][i][16 +: `LCDL_DLY_WIDTH] = data[16 +: `LCDL_DLY_WIDTH];
                `endif
              end
              if (addr == (`DX0LCDLR5 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];
                dxnlcdlr5[rankwid][i][0 +: `LCDL_DLY_WIDTH] = data[0 +: `LCDL_DLY_WIDTH];
                `ifdef DWC_DDRPHY_X4X2
                  `ifndef DWC_DDRPHY_X8_ONLY
                dxnlcdlr5[rankwid][i][16 +: `LCDL_DLY_WIDTH] = data[16 +: `LCDL_DLY_WIDTH];
                  `endif
                `endif
              end
              

              if (addr == (`DX0LCDLR0 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];

                wld_value[rankwid][i] = data[0  +: `LCDL_DLY_WIDTH];
                if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                    x4wld_value[rankwid][i] = data[16 +: `LCDL_DLY_WIDTH];
                end
              end
              if (addr == (`DX0LCDLR1 + `DX_REG_RANGE*i))begin
                rankwid = rankidr[0 +: 4];

                wdqd_value[rankwid][i] = (data[0  +: `LCDL_DLY_WIDTH] * 2.0);
                if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                    x4wdqd_value[rankwid][i] = (data[16  +: `LCDL_DLY_WIDTH] * 2.0);
                end
              end

              if (addr == (`DX0LCDLR2 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];

                dqsgd_value[rankwid][i] = data[0  +: `LCDL_DLY_WIDTH];
                if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                   x4dqsgd_value[rankwid][i] = data[16  +: `LCDL_DLY_WIDTH];
                end
              end

              if (addr == (`DX0LCDLR3 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];

                rdqsd_value[rankwid][i] = (data[0  +: `LCDL_DLY_WIDTH] * 2.0);
                if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                   x4rdqsd_value[rankwid][i]  = (data[16  +: `LCDL_DLY_WIDTH] * 2.0);
                end
              end  
              if (addr == (`DX0LCDLR4 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];

                rdqsnd_value[rankwid][i] = (data[16 +: `LCDL_DLY_WIDTH] * 2.0);
                if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                   x4rdqsnd_value[rankwid][i] = (data[16 +: `LCDL_DLY_WIDTH] * 2.0);
                end
              end 
              if (addr == (`DX0LCDLR5 + `DX_REG_RANGE*i)) begin
                rankwid = rankidr[0 +: 4];

                rdqsgs_value[rankwid][i] = (data[16 +: `LCDL_DLY_WIDTH] * 2.0);
                if (`DWC_DX_NO_OF_DQS == 2'd2) begin
                   x4rdqsgs_value[rankwid][i] = (data[16 +: `LCDL_DLY_WIDTH] * 2.0);
                end
              end
		    
              if (addr == (`DX0MDLR0  + `DX_REG_RANGE*i)) dxnmdlr_iprd_value[i] = data[0  +: `LCDL_DLY_WIDTH];
              if (addr == (`DX0MDLR0  + `DX_REG_RANGE*i)) dxnmdlr_tprd_value[i] = data[16 +: `LCDL_DLY_WIDTH];
              if (addr == (`DX0MDLR1  + `DX_REG_RANGE*i)) dxnmdlr_mdld_value[i] = data[0  +: `LCDL_DLY_WIDTH];


              if (addr == (`DX0GTR0   + `DX_REG_RANGE*i)) begin 
                rankwid = rankidr[0+: 4];  
                dxngtr0[rankwid][i][4:0] = data[4:0];
                dxngtr0[rankwid][i][19:16] = data[19:16];
                `ifdef DWC_DDRPHY_X4X2
                 dxngtr0[rankwid][i][12:8] = data[12:8];
                 dxngtr0[rankwid][i][23:20] = data[23:20];
                `endif
		          end
            end // for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
        end // if (valid_bus(addr))
        else begin
          // invalid register selection: undefined write
          pir     = {`REG_DATA_WIDTH{1'bx}};
          pgcr0   = {`REG_DATA_WIDTH{1'bx}};
          pgcr1   = {`REG_DATA_WIDTH{1'bx}};
          pgcr2   = {`REG_DATA_WIDTH{1'bx}};
          pgcr3   = {`REG_DATA_WIDTH{1'bx}};
          pgcr4   = {`REG_DATA_WIDTH{1'bx}};
          pgcr5   = {`REG_DATA_WIDTH{1'bx}};
          pgcr6   = {`REG_DATA_WIDTH{1'bx}};
          pgcr7   = {`REG_DATA_WIDTH{1'bx}};
          pgcr8   = {`REG_DATA_WIDTH{1'bx}};
`ifdef DWC_DDRPHY_PLL_TYPEB
          pllcr0  = {`REG_DATA_WIDTH{1'bx}};
          pllcr1  = {`REG_DATA_WIDTH{1'bx}};
          pllcr2  = {`REG_DATA_WIDTH{1'bx}};
          pllcr3  = {`REG_DATA_WIDTH{1'bx}};
          pllcr4  = {`REG_DATA_WIDTH{1'bx}};
          pllcr5  = {`REG_DATA_WIDTH{1'bx}};
`else
          pllcr   = {`REG_DATA_WIDTH{1'bx}};
`endif
          ptr0    = {`REG_DATA_WIDTH{1'bx}};
          ptr1    = {`REG_DATA_WIDTH{1'bx}};
          ptr2    = {`REG_DATA_WIDTH{1'bx}};
          ptr3    = {`REG_DATA_WIDTH{1'bx}};
          ptr4    = {`REG_DATA_WIDTH{1'bx}};
          ptr5    = {`REG_DATA_WIDTH{1'bx}};
          ptr6    = {`REG_DATA_WIDTH{1'bx}};
          acmdlr0 = {`REG_DATA_WIDTH{1'bx}};
          acmdlr1 = {`REG_DATA_WIDTH{1'bx}};
          aclcdlr = {`REG_DATA_WIDTH{1'bx}};
          acmdlr_iprd_value  = {`REG_DATA_WIDTH{1'bx}};
          acmdlr_tprd_value  = {`REG_DATA_WIDTH{1'bx}};
          acmdlr_mdld_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr0        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr1        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr2        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr3        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr4        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr5        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr6        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr7        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr8        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr9        = {`REG_DATA_WIDTH{1'bx}};
          acbdlr10       = {`REG_DATA_WIDTH{1'bx}};
          acbdlr0_ck0bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr0_ck1bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr0_ck2bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr0_ck3bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr1_actbd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr1_a17bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr1_a16bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr1_parbd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr2_ba0bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr2_ba1bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr2_ba2bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr2_ba3bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr3_cs0bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr3_cs1bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr3_cs2bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr3_cs3bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr4_odt0bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr4_odt1bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr4_odt2bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr4_odt3bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr5_cke0bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr5_cke1bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr5_cke2bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr5_cke3bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr6_a00bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr6_a01bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr6_a02bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr6_a03bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr7_a04bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr7_a05bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr7_a06bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr7_a07bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr8_a08bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr8_a09bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr8_a10bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr8_a11bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr9_a12bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr9_a13bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr9_a14bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr9_a15bd_value = {`REG_DATA_WIDTH{1'bx}};
          acbdlr10_acpddbd_value = {`REG_DATA_WIDTH{1'bx}};  
          acbdlr10_cid0bd_value  = {`REG_DATA_WIDTH{1'bx}};   
          acbdlr10_cid1bd_value  = {`REG_DATA_WIDTH{1'bx}}; 
          acbdlr10_cid2bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr11_cs4bd_value   = {`REG_DATA_WIDTH{1'bx}};  
          acbdlr11_cs5bd_value   = {`REG_DATA_WIDTH{1'bx}};   
          acbdlr11_cs6bd_value   = {`REG_DATA_WIDTH{1'bx}}; 
          acbdlr11_cs7bd_value   = {`REG_DATA_WIDTH{1'bx}};
          acbdlr12_cs8bd_value   = {`REG_DATA_WIDTH{1'bx}};  
          acbdlr12_cs9bd_value   = {`REG_DATA_WIDTH{1'bx}};   
          acbdlr12_cs10bd_value  = {`REG_DATA_WIDTH{1'bx}}; 
          acbdlr12_cs11bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr13_odt4bd_value  = {`REG_DATA_WIDTH{1'bx}};  
          acbdlr13_odt5bd_value  = {`REG_DATA_WIDTH{1'bx}};   
          acbdlr13_odt6bd_value  = {`REG_DATA_WIDTH{1'bx}}; 
          acbdlr13_odt7bd_value  = {`REG_DATA_WIDTH{1'bx}};
          acbdlr14_cke4bd_value  = {`REG_DATA_WIDTH{1'bx}};  
          acbdlr14_cke5bd_value  = {`REG_DATA_WIDTH{1'bx}};   
          acbdlr14_cke6bd_value  = {`REG_DATA_WIDTH{1'bx}}; 
          acbdlr14_cke7bd_value  = {`REG_DATA_WIDTH{1'bx}};
          aclcdlr  = {`REG_DATA_WIDTH{1'bx}};
          rankidr  = {`REG_DATA_WIDTH{1'bx}};
          riocr0   = {`REG_DATA_WIDTH{1'bx}};
          riocr1   = {`REG_DATA_WIDTH{1'bx}};
          riocr2   = {`REG_DATA_WIDTH{1'bx}};
          riocr3   = {`REG_DATA_WIDTH{1'bx}};
          riocr4   = {`REG_DATA_WIDTH{1'bx}};
          riocr5   = {`REG_DATA_WIDTH{1'bx}};
          aciocr0  = {`REG_DATA_WIDTH{1'bx}};
          aciocr1  = {`REG_DATA_WIDTH{1'bx}};
          aciocr2  = {`REG_DATA_WIDTH{1'bx}};
          aciocr3  = {`REG_DATA_WIDTH{1'bx}};
          aciocr4  = {`REG_DATA_WIDTH{1'bx}};
          aciocr5  = {`REG_DATA_WIDTH{1'bx}};
          dxccr   = {`REG_DATA_WIDTH{1'bx}};
          dsgcr   = {`REG_DATA_WIDTH{1'bx}};
          dcr     = {`REG_DATA_WIDTH{1'bx}};
          dtpr0   = {`REG_DATA_WIDTH{1'bx}};
          dtpr1   = {`REG_DATA_WIDTH{1'bx}};
          dtpr2   = {`REG_DATA_WIDTH{1'bx}};
          dtpr3   = {`REG_DATA_WIDTH{1'bx}};
          dtpr4   = {`REG_DATA_WIDTH{1'bx}};
          dtpr5   = {`REG_DATA_WIDTH{1'bx}};
          dtpr6   = {`REG_DATA_WIDTH{1'bx}};

          schcr0  = {`REG_DATA_WIDTH{1'bx}};
          schcr1  = {`REG_DATA_WIDTH{1'bx}};
          mr0     = {`REG_DATA_WIDTH{1'bx}};
          for(i=0; i<pNO_OF_PRANKS;i=i+1)
          begin
            mr1[i]   = {`REG_DATA_WIDTH{1'bx}};
            mr2[i]   = {`REG_DATA_WIDTH{1'bx}};
            mr3[i]   = {`REG_DATA_WIDTH{1'bx}};
          end
          mr4     = {`REG_DATA_WIDTH{1'bx}};
          for(i=0; i<pNO_OF_PRANKS;i=i+1)
          begin
            mr5[i]   = {`REG_DATA_WIDTH{1'bx}};
            mr6[i]   = {`REG_DATA_WIDTH{1'bx}};
          end
          mr7     = {`REG_DATA_WIDTH{1'bx}};
          for(i=0; i<pNO_OF_PRANKS;i=i+1)
          begin
            mr11[i]    = {`REG_DATA_WIDTH{1'bx}};
          end
          for (rank_id = 0; rank_id < pNO_OF_PRANKS; rank_id = rank_id + 1) begin
            odtcr[rank_id]   = {`REG_DATA_WIDTH{1'bx}};
          end

          aacr    = {`REG_DATA_WIDTH{1'bx}};
          dtcr0   = {`REG_DATA_WIDTH{1'bx}};
          dtcr1   = {`REG_DATA_WIDTH{1'bx}};
          dtar0   = {`REG_DATA_WIDTH{1'bx}};
          dtar1   = {`REG_DATA_WIDTH{1'bx}};
          dtar2   = {`REG_DATA_WIDTH{1'bx}};
          dtar3   = {`REG_DATA_WIDTH{1'bx}};
          dtdr0   = {`REG_DATA_WIDTH{1'bx}};
          dtdr1   = {`REG_DATA_WIDTH{1'bx}};
          uddr0   = {`REG_DATA_WIDTH{1'bx}};
          uddr1   = {`REG_DATA_WIDTH{1'bx}};
          dtedr0  = {`REG_DATA_WIDTH{1'bx}};
          dtedr1  = {`REG_DATA_WIDTH{1'bx}};
          vtdr    = {`REG_DATA_WIDTH{1'bx}};

          rdimmgcr0 = {`REG_DATA_WIDTH{1'bx}};
          rdimmgcr1 = {`REG_DATA_WIDTH{1'bx}};
          rdimmgcr2 = {`REG_DATA_WIDTH{1'bx}};
          for(i=0;i<pMAX_NO_OF_DIMMS;i=i+1)
          begin
            rdimmcr0[i]  = {`REG_DATA_WIDTH{1'bx}};
            rdimmcr1[i]  = {`REG_DATA_WIDTH{1'bx}};
            rdimmcr2[i]  = {`REG_DATA_WIDTH{1'bx}};
            rdimmcr3[i]  = {`REG_DATA_WIDTH{1'bx}};
            rdimmcr4[i]  = {`REG_DATA_WIDTH{1'bx}};
          end

          dcuar     = {`REG_DATA_WIDTH{1'bx}};
          dcudr     = {`REG_DATA_WIDTH{1'bx}};
          dcurr     = {`REG_DATA_WIDTH{1'bx}};
          dculr     = {`REG_DATA_WIDTH{1'bx}};
          dcugcr    = {`REG_DATA_WIDTH{1'bx}};
          dcutpr    = {`REG_DATA_WIDTH{1'bx}};
                                    
          bistrr    = {`REG_DATA_WIDTH{1'bx}};
          bistmskr0 = {`REG_DATA_WIDTH{1'bx}};
          bistmskr1 = {`REG_DATA_WIDTH{1'bx}};
          bistmskr2 = {`REG_DATA_WIDTH{1'bx}};
          bistwcr   = {`REG_DATA_WIDTH{1'bx}};
          bistlsr   = {`REG_DATA_WIDTH{1'bx}};
          bistar0   = {`REG_DATA_WIDTH{1'bx}};
          bistar1   = {`REG_DATA_WIDTH{1'bx}};
          bistar2   = {`REG_DATA_WIDTH{1'bx}};
          bistar3   = {`REG_DATA_WIDTH{1'bx}};
          bistar4   = {`REG_DATA_WIDTH{1'bx}};
//`endif
          bistudpr  = {`REG_DATA_WIDTH{1'bx}};
          iovcr0    = {`REG_DATA_WIDTH{1'bx}};
          iovcr1    = {`REG_DATA_WIDTH{1'bx}};
          vtcr0     = {`REG_DATA_WIDTH{1'bx}};
          vtcr1     = {`REG_DATA_WIDTH{1'bx}};
 
          gpr0      = {`REG_DATA_WIDTH{1'bx}};
          gpr1      = {`REG_DATA_WIDTH{1'bx}};

          catr0     = {`REG_DATA_WIDTH{1'bx}};
          catr1     = {`REG_DATA_WIDTH{1'bx}};
          dqsdr0    = {`REG_DATA_WIDTH{1'bx}};
          dqsdr1    = {`REG_DATA_WIDTH{1'bx}};
          dqsdr2    = {`REG_DATA_WIDTH{1'bx}};
 
          zqcr = {`REG_DATA_WIDTH{1'bx}};

          for(i=0;i<`DWC_NO_OF_ZQ_SEG;i=i+1) begin
           zqnpr[i] = {`REG_DATA_WIDTH{1'bx}};
           zqndr[i] = {`REG_DATA_WIDTH{1'bx}};
          end
          for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
            begin
              dxngcr0[i]   = {`REG_DATA_WIDTH{1'bx}};
              dxngcr1[i]   = {`REG_DATA_WIDTH{1'bx}};
              dxngcr2[i]   = {`REG_DATA_WIDTH{1'bx}};
              dxngcr3[i]   = {`REG_DATA_WIDTH{1'bx}}; 
              dxngcr4[i]   = {`REG_DATA_WIDTH{1'bx}}; 
              dxngcr5[i]   = {`REG_DATA_WIDTH{1'bx}}; 
              dxngcr6[i]   = {`REG_DATA_WIDTH{1'bx}}; 
              dxngcr7[i]   = {`REG_DATA_WIDTH{1'bx}}; 
              dxnbdlr0[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr1[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr2[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr3[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr4[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr5[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr6[i]  = {`REG_DATA_WIDTH{1'bx}};        
              dxnbdlr7[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr8[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnbdlr9[i]  = {`REG_DATA_WIDTH{1'bx}};
              for (rank_id = 0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin
                  dxnlcdlr0[rank_id][i] = {`REG_DATA_WIDTH{1'bx}};
                  dxnlcdlr1[rank_id][i] = {`REG_DATA_WIDTH{1'bx}};
                  dxnlcdlr2[rank_id][i] = {`REG_DATA_WIDTH{1'bx}};
                  dxnlcdlr3[rank_id][i] = {`REG_DATA_WIDTH{1'bx}};
                  dxnlcdlr4[rank_id][i] = {`REG_DATA_WIDTH{1'bx}};
                  dxnlcdlr5[rank_id][i] = {`REG_DATA_WIDTH{1'bx}};
              end
              dxnmdlr0[i]  = {`REG_DATA_WIDTH{1'bx}};
              dxnmdlr1[i]  = {`REG_DATA_WIDTH{1'bx}};
              for (rank_id = 0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin
                  dxngtr0[rank_id][i]   = {`REG_DATA_WIDTH{1'bx}};
              end

              dq0wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq1wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq2wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq3wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq4wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};

              dq5wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq6wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq7wbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dmwbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};
              dswbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};  

              dqsoebd_value[i] = {`REG_DATA_WIDTH{1'bx}};
              dsrbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};
              dsnrbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              
              pdrbd_value  [i] = {`REG_DATA_WIDTH{1'bx}}; 
              terbd_value  [i] = {`REG_DATA_WIDTH{1'bx}};
              pddbd_value  [i] = {`REG_DATA_WIDTH{1'bx}};
 
              dq0rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq1rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq2rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq3rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq4rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              
              dq5rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq6rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dq7rbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              dmrbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};

              x4dmwbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};
              x4dswbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};  

              x4dqsoebd_value[i] = {`REG_DATA_WIDTH{1'bx}};
              x4dmrbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};
              x4dsrbd_value[i]   = {`REG_DATA_WIDTH{1'bx}};
              x4dsnrbd_value[i]  = {`REG_DATA_WIDTH{1'bx}};
              
              x4pdrbd_value  [i] = {`REG_DATA_WIDTH{1'bx}}; 
              x4terbd_value  [i] = {`REG_DATA_WIDTH{1'bx}};
              x4pddbd_value  [i] = {`REG_DATA_WIDTH{1'bx}};

              for (rank_id = 0; rank_id < pNO_OF_LRANKS; rank_id = rank_id + 1) begin
                  rdqsgs_value[rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  wdqd_value  [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  rdqsd_value [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  rdqsnd_value[rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  dqsgd_value [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  wld_value   [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                            
                  x4rdqsgs_value[rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  x4wdqd_value  [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  x4rdqsd_value [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  x4rdqsnd_value[rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  x4dqsgd_value [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
                  x4wld_value   [rank_id][i]  = {`REG_DATA_WIDTH{1'bx}};
              end

              dxnmdlr_iprd_value[i] = {`REG_DATA_WIDTH{1'bx}};
              dxnmdlr_tprd_value[i] = {`REG_DATA_WIDTH{1'bx}};             
              dxnmdlr_mdld_value[i] = {`REG_DATA_WIDTH{1'bx}};
              
            end
        end 
	   
	end 
       
  endtask // write_register
  

  // register read
  // -------------
  // reads from a selected DDR controller register
  task read_register;
    input [`REG_ADDR_WIDTH-1:0] addr;
    
    reg [`REG_DATA_WIDTH-1:0] data;
    reg [32:0] aciocr_tmp; // for dealing with bit width adjustments in ACIOCR registers
    integer i;
    reg [3:0] rankrid;

    
    begin
      if (valid_bus(addr))
        begin
          case (addr)
            `RIDR:    data = ridr;
            `PIR:     begin
                        `ifdef DWC_DDRPHY_EMUL_XILINX
                          data = {1'b0,{2{1'b1}},{9{1'b0}}, pir[19:4], 1'b0, pir[2:0]};
                          //data =  pir;
                        `else
                          data = {{12{1'b0}}, pir[19:4], 1'b0, pir[2:0]};
                        `endif
                      end
`ifdef DWC_PUB_CLOCK_GATING
            `CGCR:    data = cgcr;
`endif
            `CGCR1:   data = cgcr1;          
            `PGCR0:   
              begin
                 if (`DWC_DX_NO_OF_DQS == 1)
                   data = {pgcr0[31], 4'b0, pgcr0[26:6],2'b00,pgcr0[3:2],1'b0,pgcr0[0]}; //pgcr0[5,4,1] are self clearing
                 else
                   data = {pgcr0[31:6],2'b00,pgcr0[3:2],1'b0,pgcr0[0]}; //pgcr0[5,4,1] are self clearing
              end
                      
            `PGCR1:   data = {pgcr1[31:0]};
            `PGCR2:   data = {{1{1'b0}},pgcr2[30:28],{8{1'b0}},pgcr2[19:0]}; // PGCR2 DTPMXTMR is always 0 after change 1099721 && PGCR2.NOBUB [18] is reserved but RW
            `PGCR3:   data = {pgcr3[31:0]};
            `PGCR4:   data = {pgcr4[31:23], {2{1'b0}},pgcr4[20:0]};
`ifdef DWC_DDRPHY_PLL_TYPEB
            `PGCR5:   data = {pgcr5[31:12], {8{1'b0}}, pgcr5[3:0]};
`else
            `PGCR5:   data = {pgcr5[31:16], {2{1'b0}}, pgcr5[13:12], {8{1'b0}}, pgcr5[3:0]};
`endif
            `PGCR6:   data = {8'h00,pgcr6[23:3],1'b0,pgcr6[1:0]};
            `PGCR7:   data = {pgcr7[31:16], {8{1'b0}}, pgcr7[7:0]};
            `PGCR8:   data = {{22{1'b0}}, pgcr8[9:0]};
            `PGSR0:   begin
`ifdef DWC_DDRPHY_EMUL_XILINX
// Emulation models requires MMCM Lock (PLL) in all cases
                        data = {1'b1,pgsr0[30:19],{4{1'b0}},pgsr0[14:0]}; 
`else
   `ifdef DWC_PLL_BYPASS
                        data = {1'b0,pgsr0[30:19],{4{1'b0}},pgsr0[14:0]}; 
   `else
                        data = {1'b1,pgsr0[30:19],{4{1'b0}},pgsr0[14:0]}; 
   `endif
     `ifndef DWC_DDRPHY_PLL_USE
                        data[31] = 0; // AC PLL not expected to be locked
     `endif
// If there is no AC PLL, but a DX PLL is used, the AC will never lock.
                        if (pAC_PLL_SHARE == 1)  data[31] = 0; 
`endif                                          
                       end
            `PGSR1:   begin
              data = {pgsr1[31:29], {4{1'b0}}, pgsr1[24:0]};
              //Functional coverage
              `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
            end
`ifdef DWC_DDRPHY_PLL_TYPEB
            `PLLCR0:  data = pllcr0;
            `PLLCR1:  data = {pllcr1[31:16], {10{1'b0}},  pllcr1[5:0]};
            `PLLCR2:  data = pllcr2;
            `PLLCR3:  data = pllcr3;
            `PLLCR4:  data = pllcr4;
            `PLLCR5:  data = {{24{1'b0}},  pllcr5[7:0]};
`else
            `PLLCR:   data = {pllcr[31:29], {4{1'b0}},  pllcr[24:0]}; //DDRG2MPHY: Changed 9'b0 to 4'b0 on 08th Dec 2011
`endif
            `PTR0:    data = {ptr0[31:0]};
            `PTR1:    data = {ptr1[31:15], {2{1'b0}}, ptr1[12:0]};
            `PTR2:    data = {{12{1'b0}},ptr2[19:0]};
            `PTR3:    data = {{2{1'b0}}, ptr3[29:0]};
            `PTR4:    data = {{3{1'b0}}, ptr4[28:0]};
            `PTR5:    data = {ptr5[31:26], {2{1'b0}}, ptr5[23:14], {2{1'b0}}, ptr5[11:0]};
            `PTR6:    data = {{18{1'b0}}, ptr6[13:0]};
`ifdef DWC_DDRPHY_EMUL_XILINX
            `ACMDLR0: data = acmdlr0;
`else
            `ACMDLR0: data = {{7{1'b0}}, acmdlr0[24:16], {7{1'b0}},acmdlr0[8:0]};
`endif
            `ACMDLR1: data = {{23{1'b0}}, acmdlr1[8:0]};
            `ACLCDLR:  data = {{23{1'b0}}, aclcdlr[8:0]};
            `ACBDLR0:  data = {{2{1'b0}},acbdlr0[29:24],{2{1'b0}},acbdlr0[21:16],{2{1'b0}},acbdlr0[13:8],{2{1'b0}},acbdlr0[5:0]}; 
            `ACBDLR1:  data = {{2{1'b0}},acbdlr1[29:24],{2{1'b0}},acbdlr1[21:16],{2{1'b0}},acbdlr1[13:8],{2{1'b0}},acbdlr1[5:0]}; 
            `ACBDLR2:  data = {{2{1'b0}},acbdlr2[29:24],{2{1'b0}},acbdlr2[21:16],{2{1'b0}},acbdlr2[13:8],{2{1'b0}},acbdlr2[5:0]}; 
            `ACBDLR3:  data = {{2{1'b0}},acbdlr3[29:24],{2{1'b0}},acbdlr3[21:16],{2{1'b0}},acbdlr3[13:8],{2{1'b0}},acbdlr3[5:0]}; 
            `ACBDLR4:  data = {{2{1'b0}},acbdlr4[29:24],{2{1'b0}},acbdlr4[21:16],{2{1'b0}},acbdlr4[13:8],{2{1'b0}},acbdlr4[5:0]}; 
            `ACBDLR5:  data = {{2{1'b0}},acbdlr5[29:24],{2{1'b0}},acbdlr5[21:16],{2{1'b0}},acbdlr5[13:8],{2{1'b0}},acbdlr5[5:0]}; 
            `ACBDLR6:  data = {{2{1'b0}},acbdlr6[29:24],{2{1'b0}},acbdlr6[21:16],{2{1'b0}},acbdlr6[13:8],{2{1'b0}},acbdlr6[5:0]}; 
            `ACBDLR7:  data = {{2{1'b0}},acbdlr7[29:24],{2{1'b0}},acbdlr7[21:16],{2{1'b0}},acbdlr7[13:8],{2{1'b0}},acbdlr7[5:0]}; 
            `ACBDLR8:  data = {{2{1'b0}},acbdlr8[29:24],{2{1'b0}},acbdlr8[21:16],{2{1'b0}},acbdlr8[13:8],{2{1'b0}},acbdlr8[5:0]}; 
            `ACBDLR9:  data = {{2{1'b0}},acbdlr9[29:24],{2{1'b0}},acbdlr9[21:16],{2{1'b0}},acbdlr9[13:8],{2{1'b0}},acbdlr9[5:0]};
            `ACBDLR10: data = {{2{1'b0}},acbdlr10[29:24],{2{1'b0}},acbdlr10[21:16],{2{1'b0}},acbdlr10[13:8],{2{1'b0}},acbdlr10[5:0]};    
            `ACBDLR11: data = {{2{1'b0}},acbdlr11[29:24],{2{1'b0}},acbdlr11[21:16],{2{1'b0}},acbdlr11[13:8],{2{1'b0}},acbdlr11[5:0]};  
            `ACBDLR12: data = {{2{1'b0}},acbdlr12[29:24],{2{1'b0}},acbdlr12[21:16],{2{1'b0}},acbdlr12[13:8],{2{1'b0}},acbdlr12[5:0]};    
            `ACBDLR13: data = {{2{1'b0}},acbdlr13[29:24],{2{1'b0}},acbdlr13[21:16],{2{1'b0}},acbdlr13[13:8],{2{1'b0}},acbdlr13[5:0]};      
            `ACBDLR14: data = {{2{1'b0}},acbdlr14[29:24],{2{1'b0}},acbdlr14[21:16],{2{1'b0}},acbdlr14[13:8],{2{1'b0}},acbdlr14[5:0]};          
            `RANKIDR:  data = {{12{1'b0}},rankidr[19:16], {12{1'b0}}, rankidr[3:0]};
            `RIOCR0:  data = {{4{1'b0}}, ({`DWC_PHY_CS_N_WIDTH{1'b1}} & riocr0[27:16]),
                              {4{1'b0}}, ({`DWC_PHY_CS_N_WIDTH{1'b1}} & riocr0[11:0])};
            `RIOCR1:  data = {({`DWC_PHY_ODT_WIDTH{1'b1}} & riocr1[31:24]), riocr1[23:16],
                              ({`DWC_PHY_CKE_WIDTH{1'b1}} & riocr1[15: 8]), riocr1[7:0]};
            `RIOCR2:  data = {{2{1'b0}}, ({`DWC_CID_WIDTH{2'b11}} & riocr2[29:24]), ({`DWC_PHY_CS_N_WIDTH{2'b11}} & riocr2[23:0])};
            `RIOCR3:  data = {{2{1'b0}}, ({`DWC_CID_WIDTH{2'b11}} & riocr3[29:24]), ({`DWC_PHY_CS_N_WIDTH{2'b11}} & riocr3[23:0])};
            `RIOCR4:  data = {({`DWC_PHY_CKE_WIDTH{2'b11}} & riocr4[31:16]), ({`DWC_PHY_CKE_WIDTH{2'b11}} & riocr4[15:0])};
            `RIOCR5:  data = {({`DWC_PHY_ODT_WIDTH{2'b11}} & riocr5[31:16]), ({`DWC_PHY_ODT_WIDTH{2'b11}} & riocr5[15:0])};

            `ACIOCR0: data = {aciocr0[31:26], {4{1'b0}}, aciocr0[21:18], {4{1'b0}}, aciocr0[13:0]};

            `DXCCR:   begin
	       if (`DWC_DX_NO_OF_DQS == 1)
		 begin
		    data = {{2{1'b0}}, dxccr[29], {5{1'b0}}, dxccr[23:20], 2'b00, dxccr[17:0]};
		 end
	       else begin
		  data = {dxccr[31:29], {5{1'b0}}, dxccr[23:20], 2'b00, dxccr[17:0]};
	       end
	    end
            `ACIOCR1: data = aciocr1;
            `ACIOCR2: data = aciocr2;
            `ACIOCR3: data = {aciocr3[31:30], aciocr3[29:22], aciocr3[21:16], 8'd0, ({`DWC_CK_WIDTH{2'b11}} & aciocr3[7:0])};

            `ACIOCR4: data = {aciocr4[31:30], aciocr4[29:22], aciocr4[21:16], 8'd0, ({`DWC_CK_WIDTH{2'b11}} & aciocr4[7:0])};
            
            `DSGCR:   data = {{7{1'b0}},dsgcr[24:0]};
            `DCR:     data = {{1{1'b0}},dcr[30:27],{9{1'b0}},dcr[17:0]};
            `DTPR0:   data = {2'd0,dtpr0[29:24],1'd0,dtpr0[22:16],1'd0,dtpr0[14:8],4'd0,dtpr0[3:0]};
            `DTPR1:   data = {2'd0,dtpr1[29:24],dtpr1[23:16],5'd0,dtpr1[10:8],3'd0,dtpr1[4:0]};
            `DTPR2:   data = {3'd0,dtpr2[28],3'd0,dtpr2[24],4'd0,dtpr2[19:16],6'd0,dtpr2[9:0]};
            `DTPR3:   data = {dtpr3[31:16],5'd0,dtpr3[10:8],5'd0,dtpr3[2:0]};
            `DTPR4:   data = {2'd0,dtpr4[29:28],2'd0,dtpr4[25:16],4'd0,dtpr4[11:8],3'd0,dtpr4[4:0]};
            `DTPR5:   data = {8'd0,dtpr5[23:16],1'd0,dtpr5[14:8],3'd0,dtpr5[4:0]};
            `DTPR6:   data = {dtpr6[31:30],16'd0,dtpr6[13:8],2'd0,dtpr6[5:0]};
            `SCHCR0:  data = {schcr0[31:14], 2'b00, schcr0[11:4], schcr0[3:0]}; 
            `SCHCR1:  data = {schcr1[31:28], schcr1[27:4], 1'b0, schcr1[2], {2{1'b0}}}; 
            `MR0_REG:     begin
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr0[15:0]};
                `DDR3_MODE:   data = {{16{1'b0}}, mr0[15:0]};
                `DDR2_MODE:   data = {{16{1'b0}}, mr0[15:0]};
                `LPDDR2_MODE: data = {{24{1'b0}}, mr0[7:0]};
                `LPDDR3_MODE: data = {{24{1'b0}}, mr0[7:0]};
                default:      data = {{16{1'b0}}, mr0[15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end 
            `MR1_REG:     begin
              rankrid = rankidr[16 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr1[rankrid][15:0]};
                `DDR3_MODE:   data = {{16{1'b0}}, mr1[rankrid][15:0]};
                `DDR2_MODE:   data = {{16{1'b0}}, mr1[0][15:0]};
                `LPDDR2_MODE: data = {{24{1'b0}}, mr1[0][7:0]};
                `LPDDR3_MODE: data = {{24{1'b0}}, mr1[0][7:0]};
                default:      data = {{16{1'b0}}, mr1[0][15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR2_REG:     begin
              rankrid = rankidr[16 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr2[rankrid][15:0]};
                `DDR3_MODE:   data = {{16{1'b0}}, mr2[rankrid][15:0]};
                `DDR2_MODE:   data = {{16{1'b0}}, mr2[0][15:0]};
                `LPDDR2_MODE: data = {{24{1'b0}}, mr2[0][7:0]};
                `LPDDR3_MODE: data = {{24{1'b0}}, mr2[0][7:0]};
                default:      data = {{16{1'b0}}, mr2[0][15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR3_REG:     begin
              rankrid = rankidr[16 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr3[0][15:0]};
                `DDR3_MODE:   data = {{16{1'b0}}, mr3[0][15:0]};
                `DDR2_MODE:   data = {{16{1'b0}}, mr3[0][15:0]};
                `LPDDR2_MODE: data = {{24{1'b0}}, mr3[rankrid][7:0]};
                `LPDDR3_MODE: data = {{24{1'b0}}, mr3[rankrid][7:0]};
                default:      data = {{16{1'b0}}, mr3[0][15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR4_REG:     begin
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr4[15:0]};
                default:      data = {{16{1'b0}}, mr4[15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR5_REG:     begin
              rankrid = rankidr[16 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr5[rankrid][15:0]};
                default:      data = {{16{1'b0}}, mr5[0][15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR6_REG:     begin
              rankrid = rankidr[16 +: 4];
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr6[rankrid][15:0]};
                default:      data = {{16{1'b0}}, mr6[0][15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR7_REG:     begin
              case(ddr_mode)
                `DDR4_MODE:   data = {{16{1'b0}}, mr7[15:0]};
                default:      data = {{16{1'b0}}, mr7[15:0]};   // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `MR11_REG:     begin
              rankrid = rankidr[16 +: 4];
              case(ddr_mode)
                `LPDDR3_MODE:   data = {{16{1'b0}}, mr11[rankrid][7:0]};
                default:        data = {{16{1'b0}}, mr11[0][15:0]};  // DDRG2MPHY - should we throw an error here?
              endcase
            end
            `ODTCR: begin
              rankrid = rankidr[16 +: 4];                      
              data    = odtcr[rankrid];
            end
            `AACR:    data = aacr;
            `DTCR0:   data = dtcr0;
            `DTCR1:   data = {dtcr1[31:16], 2'd0, dtcr1[13:12], dtcr1[11:8], 1'd0, dtcr1[6:4], 1'd0, dtcr1[2:0]};
            `DTAR0:   data = {2'd0, dtar0[29:20], 2'd0, dtar0[17:0]};
            `DTAR1:   data = {7'd0, dtar1[24:16], 7'd0, dtar1[8:0]};
            `DTAR2:   data = {7'd0, dtar2[24:16], 7'd0, dtar2[8:0]};
            `DTDR0:   data = dtdr0;
            `DTDR1:   data = dtdr1;
            `UDDR0:   data = uddr0;
            `UDDR1:   data = uddr1;
            `DTEDR0:  data = dtedr0;
            `DTEDR1:  data = dtedr1;
            `VTDR:    data = {2'b00, vtdr[29:24], 2'b00, vtdr[21:16], 2'b00, vtdr[13:8], 2'b00, vtdr[5:0]};
            `RDIMMGCR0: data = {rdimmgcr0[31:16], 1'b0, rdimmgcr0[14], 10'd0, rdimmgcr0[3:0]};
            `RDIMMGCR1: data = {rdimmgcr1[31:28], 1'd0, rdimmgcr1[26:24], 1'b0, rdimmgcr1[22:20], 1'b0, rdimmgcr1[18:16], 2'b00, rdimmgcr1[13:0]};
            `RDIMMGCR2: data = rdimmgcr2;
            `RDIMMCR0 : begin
              rankrid = rankidr[16 +: 4];
              data = rdimmcr0[rankrid];
            end
            `RDIMMCR1 :begin
              rankrid = rankidr[16 +: 4];
              data = rdimmcr1[rankrid];
            end
            `RDIMMCR2 : begin
              rankrid = rankidr[16 +: 4];
              data = rdimmcr2[rankrid];
            end
            `RDIMMCR3 : begin
              rankrid = rankidr[16 +: 4];
              data = rdimmcr3[rankrid];
            end
            `RDIMMCR4 : begin
              rankrid = rankidr[16 +: 4];
              data = rdimmcr4[rankrid];
            end
            `DCUAR    : data = {{12{1'b0}}, dcuar[19:0]};
            `DCUDR    : begin

              // read the data from the selected cache
              read_dcu_cache(data);

              // increment cache addresses if configured to do so
              auto_increment_cache_address_read;
            end
            `DCURR    : data = {{8{1'b0}}, dcurr[23:0]};
            `DCULR    : data = {dculr[31:28], {10{1'b0}}, dculr[17:0]};
            `DCUGCR   : data = {{16{1'b0}}, dcugcr[15:0]};
            `DCUTPR   : data = {8'b0,dcutpr[23:0]};
            `DCUSR0   : data = {{29{1'b0}}, dcusr0[2:0]};
            `DCUSR1   : data = dcusr1;
                                           
            `BISTRR   : data = {1'b0, bistrr[30:0]};
            `BISTMSKR0: data = {(12'd0|{bistmskr0[20 +: `DWC_PHY_CS_N_WIDTH]}), bistmskr0[19], 1'b0, bistmskr0[17:0]};
            `BISTMSKR1: data = (`DWC_DX_NO_OF_DQS == 2'd2) ? {bistmskr1[31:27],
                                                            (3'd0|{bistmskr1[24 +: `DWC_CID_WIDTH]}),                 // CID mask bits 
                                                            (8'd0|{bistmskr1[16 +: `DWC_PHY_ODT_WIDTH]}),             // ODT mask bits   
                                                            (8'd0|{bistmskr1[8  +: `DWC_PHY_CKE_WIDTH]}),             // CKE mask bits
                                                            bistmskr1[7:4], 
                                                            bistmskr1[3:0]}
                                                           :  {bistmskr1[31:27],
                                                              (3'd0|{bistmskr1[24 +: `DWC_CID_WIDTH]}),                 // CID mask bits 
                                                              (8'd0|{bistmskr1[16 +: `DWC_PHY_ODT_WIDTH]}),             // ODT mask bits   
                                                              (8'd0|{bistmskr1[8  +: `DWC_PHY_CKE_WIDTH]}),             // CKE mask bits
                                                              bistmskr1[7:4], 
                                                              4'd0}
;
            `BISTMSKR2: data = bistmskr2;
            `BISTWCR  : data = {{16{1'b0}},  bistwcr[15:0]};
            `BISTLSR  : data = bistlsr;
            `BISTAR0  : data = {bistar0[31:28], 16'd0, bistar0[11:0]};
            `BISTAR1  : data = {{12{1'b0}}, bistar1[19:0]};
            `BISTAR2  : data = {bistar2[31:28], 16'd0, bistar2[11:0]};
            `BISTAR3  : data = {14'd0,  bistar3[17:0]};
            `BISTAR4  : data = {14'd0,  bistar4[17:0]};
            `BISTUDPR : data = bistudpr;
            `BISTGSR  : data = (`DWC_DX_NO_OF_DQS == 2'd2) ? {bistgsr[31:12],    1'b0  , bistgsr[10:0]} :
                                                             {bistgsr[31:20], {9{1'b0}}, bistgsr[10:0]};
            `BISTWER0 : data = {14'd0, bistwer0[17:0]};
            `BISTWER1 : data = {15'd0, bistwer1[15:0]};
            `BISTBER0 : data = bistber0;
            `BISTBER1 : data = bistber1;
            `BISTBER2 : data = bistber2;
            `BISTBER3 : data = bistber3;
            `BISTBER4 : data = {18'd0, bistber4[13:8], 4'd0, bistber4[3:0]};
            `BISTBER5 : data = bistber5;
            `BISTWCSR : data = bistwcsr;
            `BISTFWR0 : data = {bistfwr0[31:20], 1'b0, bistfwr0[18:0]};
            `BISTFWR1 : data = (`DWC_DX_NO_OF_DQS == 2'd2) ? {bistfwr1[31:24], 1'b0, bistfwr1[22:0]} :
                                                             {bistfwr1[31:28], 5'd0, bistfwr1[22:0]};
            `BISTFWR2 : data = {bistfwr2};
            `IOVCR0   : data = {iovcr0[31:24], 2'b00, iovcr0[21:16], 2'b00, iovcr0[13:8], 2'b00, iovcr0[5:0]};
            `IOVCR1   : data = {{22{1'b0}}, iovcr1[9:8] ,2'b00, iovcr1[5:0]};
            `VTCR0    : data = {vtcr0[31:27], 5'b0, vtcr0[21:0]};
            `VTCR1    : data = {vtcr1[31:12], 1'b0, vtcr1[10:0]};
            
            `GPR0     : data = gpr0;
            `GPR1     : data = gpr1;

            `CATR0    : data = {{11{1'b0}}, catr0[20:16], {3{1'b0}}, catr0[12:0]}; //Changed on 15th May 2012 as per PUB doc version 0.71
            `CATR1    : data = {{4{1'b0}}, catr1[27:0]};
            `DQSDR0   : data = {dqsdr0[31:8], 1'b0, dqsdr0[6:0]};
            `DQSDR1   : data = {{2{1'b0}}, dqsdr1[29:0]};
            `DQSDR2   : data = {{8{1'b0}}, dqsdr2[23:0]};
            default:  data = {`REG_DATA_WIDTH{1'b0}};
          endcase // case(addr)

           if (addr == `ZQCR) data = {{4{1'b0}},zqcr[27],{2{1'b0}},zqcr[24:8],{5{1'b0}},zqcr[2:1],1'b0};

           for (i=0; i<`DWC_NO_OF_ZQ_SEG; i=i+1)
            begin
              if (addr == (`ZQ0PR + 8'h04 * i)) begin
                data = {zqnpr[i][31:28],{4{1'b0}},zqnpr[i][23:0]};
              end //DDRG@MPHY: need to add FCOV statement
              
              if (addr == (`ZQ0DR + 8'h04 * i)) begin
                //data = {zqndr[i][31:29],1'b0,zqndr[i][27:0]};
                data = {zqndr[i][31:0]};
              end //DDRG@MPHY: need to add FCOV statement
  
              if (addr == (`ZQ0SR + 8'h04*i))  begin
                //data = {{22{1'b0}},zqnsr[i][9:0]};                 
                data = {{20{1'b0}},zqnsr[i][11:0]};                 
                //`FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
              end
            end

          for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
            begin
              if (addr == (`DX0GCR0    + `DX_REG_RANGE*i)) 
                data = {dxngcr0[i][31:30],{6{1'b0}},dxngcr0[i][23:16],{2{1'b0}},dxngcr0[i][13:7],{1'b0},dxngcr0[i][5],{1'b0},dxngcr0[i][3:0]};
              if (addr == (`DX0GCR1    + `DX_REG_RANGE*i)) 
                data = {dxngcr1[i][31:16],{16{1'b0}}};
              if (addr == (`DX0GCR2    + `DX_REG_RANGE*i)) 
                data = dxngcr2[i][31:0];
              if (addr == (`DX0GCR3    + `DX_REG_RANGE*i)) 
                data = {dxngcr3[i][31:18],{2{1'b0}}, dxngcr3[i][15:10], 2'b00, dxngcr3[i][7:2], 2'b00};
              if (addr == (`DX0GCR4    + `DX_REG_RANGE*i)) 
                data = {dxngcr4[i][31:25], 3'b000, dxngcr4[i][21:16], 2'b00, dxngcr4[i][13:8], 2'b00, dxngcr4[i][5:0]};
              if (addr == (`DX0GCR5    + `DX_REG_RANGE*i)) 
                data = {2'b00, dxngcr5[i][29:24], 2'b00,  dxngcr5[i][21:16], 2'b00, dxngcr5[i][13:8], 2'b00, dxngcr5[i][5:0]};
              if (addr == (`DX0GCR6    + `DX_REG_RANGE*i)) 
                data = {2'b00, dxngcr6[i][29:24], 2'b00,  dxngcr6[i][21:16], 2'b00, dxngcr6[i][13:8], 2'b00, dxngcr6[i][5:0]};

              if (`DWC_DX_NO_OF_DQS == 2) begin
                if (addr == (`DX0GCR7    + `DX_REG_RANGE*i)) 
                  data = {2'b00, dxngcr7[i][29:21], 1'b0, dxngcr7[i][19], 1'b0, dxngcr7[i][17:10], 2'b00, dxngcr7[i][7:2], 2'b00};
                if (addr == (`DX0GCR8    + `DX_REG_RANGE*i)) 
                  data = {2'b00, dxngcr8[i][29:24], 2'b00,  dxngcr8[i][21:16], 2'b00, dxngcr8[i][13:8], 2'b00, dxngcr8[i][5:0]};
                if (addr == (`DX0GCR9    + `DX_REG_RANGE*i)) 
                  data = {2'b00, dxngcr9[i][29:24], 2'b00,  dxngcr9[i][21:16], 2'b00, dxngcr9[i][13:8], 2'b00, dxngcr9[i][5:0]};
              end
              else begin
                if (addr == (`DX0GCR7    + `DX_REG_RANGE*i)) 
                  data = {`REG_DATA_WIDTH{1'h0}};
                if (addr == (`DX0GCR8    + `DX_REG_RANGE*i)) 
                  data = {`REG_DATA_WIDTH{1'h0}};
                if (addr == (`DX0GCR9    + `DX_REG_RANGE*i)) 
                  data = {`REG_DATA_WIDTH{1'h0}};
              end
              
              if (addr == (`DX0GSR0   + `DX_REG_RANGE*i)) begin
                data = {dxngsr0[i][31:30], 4'b0000, dxngsr0[i][25:0]};
                `ifdef DWC_PLL_BYPASS
                    data[16] = 1'b0;  
                `else
                  // look at PLL share variable and clear the PLL lock bit if current slice doesn't have PLL
                  data[16] = dx_pll_share[i];
                `endif
                `ifndef DWC_DDRPHY_PLL_USE
                  data[16] = 1'b0;
                `endif

                //Functional coverage
                `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
              end   
              if (addr == (`DX0GSR1   + `DX_REG_RANGE*i)) begin 
                data = {{7{1'b0}},dxngsr1[i][24:0]};         
                //Functional coverage
                `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
              end                    

              if (addr == (`DX0GSR2   + `DX_REG_RANGE*i)) begin
                data = {dxngsr2[i][31:22],1'b0, dxngsr2[i][20], {8{1'b0}}, dxngsr2[i][11:0]};  

                //Functional coverage
                `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
              end                    
              if (addr == (`DX0GSR3   + `DX_REG_RANGE*i)) begin
                data = {{8{1'b0}}, dxngsr3[i][23:8], {4{1'b0}}, dxngsr3[i][3:0]};  
                //Functional coverage
                `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
              end                    

              if (`DWC_DX_NO_OF_DQS == 2) begin
                if (addr == (`DX0GSR4   + `DX_REG_RANGE*i)) begin
                  data = {{6{1'b0}}, dxngsr4[i][25:17], {1'b0}, dxngsr4[i][15:0]};  
                  //Functional coverage
                  `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
                end                    
                if (addr == (`DX0GSR5   + `DX_REG_RANGE*i)) begin
                  data = {dxngsr5[i][31:22], 1'b0, dxngsr5[i][20], {8{1'b0}}, dxngsr5[i][11:0]};
                  //Functional coverage
                  `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
                end                    

                if (addr == (`DX0GSR6   + `DX_REG_RANGE*i)) begin
                  data = {{8{1'b0}}, dxngsr6[i][23:8], 4'b0000, dxngsr6[i][3:2], 2'b00};
                  
                  //Functional coverage
                  `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
                end                    
              end
              else begin
                if (addr == (`DX0GSR4   + `DX_REG_RANGE*i)) begin
                  data = {`REG_DATA_WIDTH{1'h0}};
                  //Functional coverage
                  `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
                end                    
                if (addr == (`DX0GSR5   + `DX_REG_RANGE*i)) begin
                  data = {`REG_DATA_WIDTH{1'h0}};
                  //Functional coverage
                  `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
                end                    

                if (addr == (`DX0GSR6   + `DX_REG_RANGE*i)) begin
                  data = {`REG_DATA_WIDTH{1'h0}};
                  //Functional coverage
                  `FCOV_REG.set_cov_registers_read_clear(addr, data,`VALUE_REGISTER_DATA);
                end                    
               end
              
              // DDRG2MPHY: new ddrg2mphy register definitions
              if (addr == (`DX0BDLR0  + `DX_REG_RANGE*i)) data = {{2{1'b0}},  dxnbdlr0[i][29:24],
                                                          {2{1'b0}},  dxnbdlr0[i][21:16],
                                                          {2{1'b0}},  dxnbdlr0[i][13: 8],
                                                          {2{1'b0}},  dxnbdlr0[i][ 5: 0] };
              if (addr == (`DX0BDLR1  + `DX_REG_RANGE*i)) data = {{2{1'b0}},  dxnbdlr1[i][29:24],
                                                          {2{1'b0}},  dxnbdlr1[i][21:16],
                                                          {2{1'b0}},  dxnbdlr1[i][13: 8],
                                                          {2{1'b0}},  dxnbdlr1[i][ 5: 0] };
              if (addr == (`DX0BDLR2  + `DX_REG_RANGE*i)) data = {{10{1'b0}}, dxnbdlr2[i][21:16],{2{1'b0}},dxnbdlr2[i][13:8],{2{1'b0}},dxnbdlr2[i][5:0]};
              if (addr == (`DX0BDLR3  + `DX_REG_RANGE*i)) data = {{2{1'b0}},  dxnbdlr3[i][29:24],
                                                          {2{1'b0}},  dxnbdlr3[i][21:16],
                                                          {2{1'b0}},  dxnbdlr3[i][13: 8],
                                                          {2{1'b0}},  dxnbdlr3[i][ 5: 0] };
              if (addr == (`DX0BDLR4  + `DX_REG_RANGE*i)) data = {{2{1'b0}},  dxnbdlr4[i][29:24],
                                                          {2{1'b0}},  dxnbdlr4[i][21:16],
                                                          {2{1'b0}},  dxnbdlr4[i][13: 8],
                                                          {2{1'b0}},  dxnbdlr4[i][ 5: 0] };
  `ifdef DWC_DDRPHY_EMUL_XILINX
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) data = dxnbdlr5[i];
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) data = dxnbdlr6[i];
  `else                                                        
              if (addr == (`DX0BDLR5  + `DX_REG_RANGE*i)) data = {{10{1'b0}}, dxnbdlr5[i][21:16],{2{1'b0}},dxnbdlr5[i][13:8],{2{1'b0}},dxnbdlr5[i][5:0]};
              if (addr == (`DX0BDLR6  + `DX_REG_RANGE*i)) data = {{10{1'b0}}, dxnbdlr6[i][21:16],{2{1'b0}},dxnbdlr6[i][13:8],{2{1'b0}},dxnbdlr6[i][5:0]};
  `endif //DWC_DDRPHY_EMUL_XILINX
 
              if (`DWC_DX_NO_OF_DQS == 2) begin
                if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) data = {{10{1'b0}},  dxnbdlr7[i][21:16],{2{1'b0}}, dxnbdlr7[i][13:8],{2{1'b0}}, dxnbdlr7[i][5:0]};

  `ifdef DWC_DDRPHY_EMUL_XILINX
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) data =   dxnbdlr8[i][31:0];
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) data =   dxnbdlr9[i][31:0];
  `else
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) data = {{10{1'b0}},  dxnbdlr8[i][21:16],{2{1'b0}}, dxnbdlr8[i][13:8],{2{1'b0}}, dxnbdlr8[i][5:0]};
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) data = {{10{1'b0}},  dxnbdlr9[i][21:16],{2{1'b0}}, dxnbdlr9[i][13:8],{2{1'b0}}, dxnbdlr9[i][5:0]};
  `endif	       
              end
              else begin
                if (addr == (`DX0BDLR7  + `DX_REG_RANGE*i)) data = {`REG_DATA_WIDTH{1'h0}};
                if (addr == (`DX0BDLR8  + `DX_REG_RANGE*i)) data = {`REG_DATA_WIDTH{1'h0}};
                if (addr == (`DX0BDLR9  + `DX_REG_RANGE*i)) data = {`REG_DATA_WIDTH{1'h0}};
              end  

              if (`DWC_DX_NO_OF_DQS == 2) begin
                if (addr == (`DX0LCDLR0 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, dxnlcdlr0[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr0[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                if (addr == (`DX0LCDLR1 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, dxnlcdlr1[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr1[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                //`ifdef DWC_DDRPHY_EMUL_XILINX
                //              if (addr == (`DX0LCDLR2  + `DX_REG_RANGE*i)) data = {{(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(23+pDQ_DELAY_WIDTH)   :24], 
                //                                                                   {(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(15+pDQ_DELAY_WIDTH)   :16], 
                //                                                                   {(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(7 +pDQ_DELAY_WIDTH)   : 8], 
                //                                                                   {(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(   pDQ_DELAY_WIDTH-1) : 0]};
                //`else
                if (addr == (`DX0LCDLR2 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, dxnlcdlr2[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr2[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                //`endif
                if (addr == (`DX0LCDLR3 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, dxnlcdlr3[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr3[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                if (addr == (`DX0LCDLR4 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, dxnlcdlr4[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr4[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                if (addr == (`DX0LCDLR5 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, dxnlcdlr5[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr5[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
              end
              else begin
                if (addr == (`DX0LCDLR0 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}}, {7{1'b0}}, dxnlcdlr0[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                if (addr == (`DX0LCDLR1 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}}, {7{1'b0}}, dxnlcdlr1[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                //`ifdef DWC_DDRPHY_EMUL_XILINX
                //              if (addr == (`DX0LCDLR2  + `DX_REG_RANGE*i)) data = {{(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(23+pDQ_DELAY_WIDTH)   :24], 
                //                                                                   {(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(15+pDQ_DELAY_WIDTH)   :16], 
                //                                                                   {(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(7 +pDQ_DELAY_WIDTH)   : 8], 
                //                                                                   {(8-pDQ_DELAY_WIDTH){1'b0}},  dxnlcdlr2[i][(   pDQ_DELAY_WIDTH-1) : 0]};
                //`else
                if (addr == (`DX0LCDLR2 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}}, {7{1'b0}}, dxnlcdlr2[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                //`endif
                if (addr == (`DX0LCDLR3 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}}, {7{1'b0}}, dxnlcdlr3[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                if (addr == (`DX0LCDLR4 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}}, {7{1'b0}}, dxnlcdlr4[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
                if (addr == (`DX0LCDLR5 + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}}, {7{1'b0}}, dxnlcdlr5[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
                end
              end                

                
              if (addr == (`DX0MDLR0  + `DX_REG_RANGE*i)) data = {{7{1'b0}}, dxnmdlr0[i] [16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnmdlr0[i] [0 +: `LCDL_DLY_WIDTH]};
              if (addr == (`DX0MDLR1  + `DX_REG_RANGE*i)) data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}},             {7{1'b0}}, dxnmdlr1[i] [0 +: `LCDL_DLY_WIDTH]};
              if (`DWC_DX_NO_OF_DQS == 2) begin
                if (addr == (`DX0GTR0   + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {8'd0, dxngtr0[rankrid][i][23:20], dxngtr0[rankrid][i][19:16], 3'd0, dxngtr0[rankrid][i][12:8], 3'd0, dxngtr0[rankrid][i][4:0]};
                end
              end
              else begin
                if (addr == (`DX0GTR0   + `DX_REG_RANGE*i)) begin
                  rankrid = rankidr[16 +: 4];
                  data = {8'd0, 4'd0, dxngtr0[rankrid][i][19:16], 3'd0, 5'd0, 3'd0, dxngtr0[rankrid][i][4:0]};
                end
              end                
            end // for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
	end // if (valid_bus(addr))
      else
        begin
          // invalid register selection: undefined read
          data = {`REG_DATA_WIDTH{1'bx}};
        end
      
      // load the read data into the register FIFO
      put_register_data(data, addr);
      
      cfg_reads_txd = cfg_reads_txd + 1;
      
    end
  endtask // read_register


  // Special reads from a selected DDR controller registers for fcov purpose
  task read_register_for_vt_drift_fcov;    
    reg [`REG_ADDR_WIDTH-1:0] addr;
    reg [`REG_DATA_WIDTH-1:0] data;
    integer i;
    reg rankrid;
    
    begin
      rankrid=rankidr[16 +: 4];
      addr = `ACBDLR0;
      data = {{2{1'b0}},acbdlr0[29:24],{2{1'b0}},acbdlr0[21:16],{2{1'b0}},acbdlr0[13:8],{2{1'b0}},acbdlr0[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR1;
      data = {{2{1'b0}},acbdlr1[29:24],{2{1'b0}},acbdlr1[21:16],{2{1'b0}},acbdlr1[13:8],{2{1'b0}},acbdlr1[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR2;
      data = {{2{1'b0}},acbdlr2[29:24],{2{1'b0}},acbdlr2[21:16],{2{1'b0}},acbdlr2[13:8],{2{1'b0}},acbdlr2[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR3;
      data = {{2{1'b0}},acbdlr3[29:24],{2{1'b0}},acbdlr3[21:16],{2{1'b0}},acbdlr3[13:8],{2{1'b0}},acbdlr3[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR4;
      data = {{2{1'b0}},acbdlr4[29:24],{2{1'b0}},acbdlr4[21:16],{2{1'b0}},acbdlr4[13:8],{2{1'b0}},acbdlr4[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR5;
      data = {{2{1'b0}},acbdlr5[29:24],{2{1'b0}},acbdlr5[21:16],{2{1'b0}},acbdlr5[13:8],{2{1'b0}},acbdlr5[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR6;
      data = {{2{1'b0}},acbdlr6[29:24],{2{1'b0}},acbdlr6[21:16],{2{1'b0}},acbdlr6[13:8],{2{1'b0}},acbdlr6[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR7;
      data = {{2{1'b0}},acbdlr7[29:24],{2{1'b0}},acbdlr7[21:16],{2{1'b0}},acbdlr7[13:8],{2{1'b0}},acbdlr7[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR8;
      data = {{2{1'b0}},acbdlr8[29:24],{2{1'b0}},acbdlr8[21:16],{2{1'b0}},acbdlr8[13:8],{2{1'b0}},acbdlr8[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR9;
      data = {{2{1'b0}},acbdlr9[29:24],{2{1'b0}},acbdlr9[21:16],{2{1'b0}},acbdlr9[13:8],{2{1'b0}},acbdlr9[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
      addr = `ACBDLR10;
      data = {{2{1'b0}},acbdlr10[29:24],{2{1'b0}},acbdlr10[21:16],{2{1'b0}},acbdlr10[13:8],{2{1'b0}},acbdlr10[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);   
      addr = `ACBDLR11;
      data = {{2{1'b0}},acbdlr11[29:24],{2{1'b0}},acbdlr11[21:16],{2{1'b0}},acbdlr11[13:8],{2{1'b0}},acbdlr11[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA); 
      addr = `ACBDLR12;
      data = {{2{1'b0}},acbdlr12[29:24],{2{1'b0}},acbdlr12[21:16],{2{1'b0}},acbdlr12[13:8],{2{1'b0}},acbdlr12[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);  
      addr = `ACBDLR13;
      data = {{2{1'b0}},acbdlr13[29:24],{2{1'b0}},acbdlr13[21:16],{2{1'b0}},acbdlr13[13:8],{2{1'b0}},acbdlr13[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
      addr = `ACBDLR14;
      data = {{2{1'b0}},acbdlr14[29:24],{2{1'b0}},acbdlr14[21:16],{2{1'b0}},acbdlr14[13:8],{2{1'b0}},acbdlr14[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);

      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
        begin
          addr = (`DX0BDLR0  + `DX_REG_RANGE*i);                               
          // DDR2GMPHY: old ddrphy register definitions
          // data = {{2{1'b0}},  dxnbdlr0[i][29:0]};
          // DDRG2MPHY: new ddrg2mphy register definitions
          data = {{2{1'b0}},  dxnbdlr0[i][29:24],
                  {2{1'b0}},  dxnbdlr0[i][21:16],
                  {2{1'b0}},  dxnbdlr0[i][13: 8],
                  {2{1'b0}},  dxnbdlr0[i][ 5: 0] };
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
          addr = (`DX0BDLR1  + `DX_REG_RANGE*i);                               
          // DDR2GMPHY: old ddrphy register definitions
          // data = {{2{1'b0}},  dxnbdlr1[i][29:0]};
          // DDRG2MPHY: new ddrg2mphy register definitions
          data = {{2{1'b0}},  dxnbdlr1[i][29:24],
                  {2{1'b0}},  dxnbdlr1[i][21:16],
                  {2{1'b0}},  dxnbdlr1[i][13: 8],
                  {2{1'b0}},  dxnbdlr1[i][ 5: 0] };
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                              
          addr = (`DX0BDLR2  + `DX_REG_RANGE*i);                               
          data = {{10{1'b0}}, dxnbdlr2[i][21:16],{2{1'b0}},dxnbdlr2[i][13:8],{2{1'b0}},dxnbdlr2[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               
          addr = (`DX0BDLR3  + `DX_REG_RANGE*i);                               
//        data = {{2{1'b0}},  dxnbdlr3[i][29:0]};
          data = {{2{1'b0}},  dxnbdlr3[i][29:24],
                  {2{1'b0}},  dxnbdlr3[i][21:16],
                  {2{1'b0}},  dxnbdlr3[i][13: 8],
                  {2{1'b0}},  dxnbdlr3[i][ 5: 0] };   
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                              
          addr = (`DX0BDLR4  + `DX_REG_RANGE*i);                              
//          data = {{2{1'b0}},  dxnbdlr4[i][29:0]};
          data = {{2{1'b0}},  dxnbdlr4[i][29:24],
                  {2{1'b0}},  dxnbdlr4[i][21:16],
                  {2{1'b0}},  dxnbdlr4[i][13: 8],
                  {2{1'b0}},  dxnbdlr4[i][ 5: 0] };  
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                
          addr = (`DX0BDLR5  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr5[i][21:16],{2{1'b0}},dxnbdlr5[i][13:8],{2{1'b0}},dxnbdlr5[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);  

          addr = (`DX0BDLR6  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr6[i][21:16],{2{1'b0}},dxnbdlr6[i][13:8],{2{1'b0}},dxnbdlr6[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
 
          addr = (`DX0BDLR7  + `DX_REG_RANGE*i);                               
          data = {{10{1'b0}}, dxnbdlr7[i][21:16],{2{1'b0}},dxnbdlr7[i][13:8],{2{1'b0}},dxnbdlr7[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0BDLR8  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr8[i][21:16],{2{1'b0}},dxnbdlr8[i][13:8],{2{1'b0}},dxnbdlr8[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);  

          addr = (`DX0BDLR9  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr9[i][21:16],{2{1'b0}},dxnbdlr9[i][13:8],{2{1'b0}},dxnbdlr9[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);

          addr = (`DX0LCDLR0 + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, dxnlcdlr0[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr0[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                

          addr = (`DX0LCDLR1 + `DX_REG_RANGE*i);               
          data = {{7{1'b0}}, dxnlcdlr1[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr1[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0LCDLR2 + `DX_REG_RANGE*i);                               
          data = {{7{1'b0}}, dxnlcdlr2[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr2[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0LCDLR3 + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, dxnlcdlr3[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr3[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                

          addr = (`DX0LCDLR4 + `DX_REG_RANGE*i);               
          data = {{7{1'b0}}, dxnlcdlr4[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr4[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0LCDLR5 + `DX_REG_RANGE*i);                               
          data = {{7{1'b0}}, dxnlcdlr5[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr5[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0MDLR0   + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, dxnmdlr0[i] [16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnmdlr0[i] [0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                               

          addr = (`DX0MDLR1   + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}},             {7{1'b0}}, dxnmdlr1[i] [0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                               
        end
    end                        
  endtask // read_register_for_vt_drift_fcov      
  

  // Special reads from a selected DDR controller registers for fcov purpose
  task read_register_for_cross_vt_drift_fcov;    
    reg [`REG_ADDR_WIDTH-1:0] addr;
    reg [`REG_DATA_WIDTH-1:0] data;
    integer i;
    reg rankrid;
    
    begin
      rankrid = rankidr[16 +: 4];
      addr = `ACBDLR0;
      data = {{2{1'b0}},acbdlr0[29:24],{2{1'b0}},acbdlr0[21:16],{2{1'b0}},acbdlr0[13:8],{2{1'b0}},acbdlr0[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR1;
      data = {{2{1'b0}},acbdlr1[29:24],{2{1'b0}},acbdlr1[21:16],{2{1'b0}},acbdlr1[13:8],{2{1'b0}},acbdlr1[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR2;
      data = {{2{1'b0}},acbdlr2[29:24],{2{1'b0}},acbdlr2[21:16],{2{1'b0}},acbdlr2[13:8],{2{1'b0}},acbdlr2[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR3;
      data = {{2{1'b0}},acbdlr3[29:24],{2{1'b0}},acbdlr3[21:16],{2{1'b0}},acbdlr3[13:8],{2{1'b0}},acbdlr3[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR4;
      data = {{2{1'b0}},acbdlr4[29:24],{2{1'b0}},acbdlr4[21:16],{2{1'b0}},acbdlr4[13:8],{2{1'b0}},acbdlr4[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR5;
      data = {{2{1'b0}},acbdlr5[29:24],{2{1'b0}},acbdlr5[21:16],{2{1'b0}},acbdlr5[13:8],{2{1'b0}},acbdlr5[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR6;
      data = {{2{1'b0}},acbdlr6[29:24],{2{1'b0}},acbdlr6[21:16],{2{1'b0}},acbdlr6[13:8],{2{1'b0}},acbdlr6[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR7;
      data = {{2{1'b0}},acbdlr7[29:24],{2{1'b0}},acbdlr7[21:16],{2{1'b0}},acbdlr7[13:8],{2{1'b0}},acbdlr7[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR8;
      data = {{2{1'b0}},acbdlr8[29:24],{2{1'b0}},acbdlr8[21:16],{2{1'b0}},acbdlr8[13:8],{2{1'b0}},acbdlr8[5:0]};
      //Functional coverage
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);        
      addr = `ACBDLR9;
      data = {{2{1'b0}},acbdlr9[29:24],{2{1'b0}},acbdlr9[21:16],{2{1'b0}},acbdlr9[13:8],{2{1'b0}},acbdlr9[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
      addr = `ACBDLR10;
      data = {{26{1'b0}},acbdlr10[5:0]};
      //Functional coverage      
      `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);      

      for (i=0; i<`DWC_NO_OF_BYTES; i=i+1)
        begin
          addr = (`DX0BDLR0  + `DX_REG_RANGE*i);                               
          // DDR2GMPHY: old ddrphy register definitions
          // data = {{2{1'b0}},  dxnbdlr0[i][29:0]};
          // DDRG2MPHY: new ddrg2mphy register definitions
          data = {{2{1'b0}},  dxnbdlr0[i][29:24],
                  {2{1'b0}},  dxnbdlr0[i][21:16],
                  {2{1'b0}},  dxnbdlr0[i][13: 8],
                  {2{1'b0}},  dxnbdlr0[i][ 5: 0] };
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
          addr = (`DX0BDLR1  + `DX_REG_RANGE*i);                               
          // DDR2GMPHY: old ddrphy register definitions
          // data = {{2{1'b0}},  dxnbdlr1[i][29:0]};
          // DDRG2MPHY: new ddrg2mphy register definitions
          data = {{2{1'b0}},  dxnbdlr1[i][29:24],
                  {2{1'b0}},  dxnbdlr1[i][21:16],
                  {2{1'b0}},  dxnbdlr1[i][13: 8],
                  {2{1'b0}},  dxnbdlr1[i][ 5: 0] };
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                              
          addr = (`DX0BDLR2  + `DX_REG_RANGE*i);                               
          data = {{10{1'b0}}, dxnbdlr2[i][21:16],{2{1'b0}},dxnbdlr2[i][13:8],{2{1'b0}},dxnbdlr2[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               
          addr = (`DX0BDLR3  + `DX_REG_RANGE*i);                               
          data = {{2{1'b0}},  dxnbdlr3[i][29:24],
                  {2{1'b0}},  dxnbdlr3[i][21:16],
                  {2{1'b0}},  dxnbdlr3[i][13: 8],
                  {2{1'b0}},  dxnbdlr3[i][ 5: 0] };   
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                              
          addr = (`DX0BDLR4  + `DX_REG_RANGE*i);                              
          data = {{2{1'b0}},  dxnbdlr4[i][29:24],
                  {2{1'b0}},  dxnbdlr4[i][21:16],
                  {2{1'b0}},  dxnbdlr4[i][13: 8],
                  {2{1'b0}},  dxnbdlr4[i][ 5: 0] };  
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                
          addr = (`DX0BDLR5  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr5[i][21:16],{2{1'b0}},dxnbdlr5[i][13:8],{2{1'b0}},dxnbdlr5[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);  

          addr = (`DX0BDLR6  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr6[i][21:16],{2{1'b0}},dxnbdlr6[i][13:8],{2{1'b0}},dxnbdlr6[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);
          addr = (`DX0BDLR7  + `DX_REG_RANGE*i);                               
          data = {{10{1'b0}}, dxnbdlr7[i][21:16],{2{1'b0}},dxnbdlr7[i][13:8],{2{1'b0}},dxnbdlr7[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               
          addr = (`DX0BDLR8  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr8[i][21:16],{2{1'b0}},dxnbdlr8[i][13:8],{2{1'b0}},dxnbdlr8[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);  

          addr = (`DX0BDLR9  + `DX_REG_RANGE*i); 
          data = {{10{1'b0}}, dxnbdlr9[i][21:16],{2{1'b0}},dxnbdlr9[i][13:8],{2{1'b0}},dxnbdlr9[i][5:0]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);

          addr = (`DX0LCDLR0 + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, dxnlcdlr0[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr0[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                

          addr = (`DX0LCDLR1 + `DX_REG_RANGE*i);               
          data = {{7{1'b0}}, dxnlcdlr1[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr1[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0LCDLR2 + `DX_REG_RANGE*i);                               
          data = {{7{1'b0}}, dxnlcdlr2[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr2[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0LCDLR3 + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, dxnlcdlr3[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr3[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                

          addr = (`DX0LCDLR4 + `DX_REG_RANGE*i);               
          data = {{7{1'b0}}, dxnlcdlr4[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr4[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0LCDLR5 + `DX_REG_RANGE*i);                               
          data = {{7{1'b0}}, dxnlcdlr5[rankrid][i][16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnlcdlr5[rankrid][i][0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);               

          addr = (`DX0MDLR0   + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, dxnmdlr0[i] [16 +: `LCDL_DLY_WIDTH], {7{1'b0}}, dxnmdlr0[i] [0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                               

          addr = (`DX0MDLR1   + `DX_REG_RANGE*i);                              
          data = {{7{1'b0}}, {`LCDL_DLY_WIDTH{1'b0}},             {7{1'b0}}, dxnmdlr1[i] [0 +: `LCDL_DLY_WIDTH]};
          //Functional coverage
          `FCOV_REG.set_cov_registers_write(addr, data,`VALUE_REGISTER_VT_DRIFT_DATA);                               
        end
    end                        
  endtask // read_register_for_cross_vt_drift_fcov   

  
  // register read data FIFO
  // -----------------------
  // fifos the expected register read data
  task put_register_data;
    input [`REG_DATA_WIDTH-1:0] reg_data;
    input [`REG_ADDR_WIDTH-1:0] reg_addr;

    integer                     fifo_wptr;
    reg [REG_FIFO_WIDTH-1:0]    fifo_data;
    begin
      // write the words into the FIFO
      fifo_wptr = reg_fifo_wrptr;
      fifo_data = {reg_addr, reg_data};
      reg_fifo[fifo_wptr] = fifo_data;

      // increment write pointer
      reg_fifo_wrptr = (fifo_wptr < (REG_FIFO_DEPTH-1)) ? fifo_wptr + 1 : 0;
    end
  endtask // put_register_data

`ifndef DWC_USE_SHARED_AC_TB
  always @(*)
  begin
    if(ch0_fifo_wrptr != ch0_fifo_rdptr)
      read_pending = 1'b1;
    else
      read_pending = 1'b0;
  end
`else
  // Need to update logic for Shared AC ch0/ch1 read pointers.
`endif

  // gets the read data from the register FIFO
  task get_register_data;
    output [`REG_DATA_WIDTH-1:0] q;
    output [`REG_ADDR_WIDTH-1:0] reg_addr;

    integer                      fifo_rptr;
    reg [REG_FIFO_WIDTH-1:0]     fifo_data;
    
    integer i;
    begin
      fifo_rptr = reg_fifo_rdptr;

      // read data from the FIFO
      fifo_data = reg_fifo[fifo_rptr];      
      {reg_addr, q} = fifo_data;

      // clear the just read entry
      reg_fifo[fifo_rptr] = {REG_FIFO_WIDTH{1'b0}};

      // increment the read pointer
      reg_fifo_rdptr = (fifo_rptr < (REG_FIFO_DEPTH-1)) ? fifo_rptr + 1 : 0;
    end
  endtask // get_register_data
  
//DDRG2MPHY: zden assignment

always @(*)
begin
  for(zden_cnt=0;zden_cnt<`DWC_NO_OF_ZQ_SEG;zden_cnt=zden_cnt+1)
  begin
    drv_zden[zden_cnt] = zqnpr[zden_cnt][31]; 
    odt_zden[zden_cnt] = zqnpr[zden_cnt][30]; 
  end
end

  // PHY register bits
  // -----------------
`ifdef DWC_DDRPHY_PLL_TYPEB
  assign pll_bypass = pllcr0[31] | pir[17];
`else
  assign pll_bypass = pllcr[31] | pir[17];
`endif

  assign dl_tmode   = pgcr0[6];
  assign io_lb_sel  = pgcr1[27];
  assign lb_sel     = bistrr[29:28];
  assign lb_ck_sel  = bistrr[27:26];
  assign lb_mode    = pgcr1[31];
  assign cken       = pgcr3[23:16];
  assign dqs_gatex  = dsgcr[7:6];

  assign rdimm      = rdimmgcr0[0];
  assign t_bcstab   = rdimmgcr1[13:0];
  assign t_bcmrd    = {1'b1, rdimmgcr1[18:16]};

  assign msbyte_udq = dxccr[17:15];
  assign udq_iom    = dxccr[21];

  // DCU register bits
  assign cache_word_addr      = dcuar[3:0];
  assign cache_slice_addr     = dcuar[7:4];
  assign cache_sel            = dcuar[9:8];
  assign cache_inc_addr       = dcuar[10];
  assign cache_access_type    = dcuar[11];
  assign cache_word_addr_r    = dcuar[15:12];
  assign cache_slice_addr_r   = dcuar[19:16];

  assign dcu_inst             = dcurr[3:0];
  assign ccache_start_addr    = dcurr[7:4];
  assign ccache_end_addr      = dcurr[11:8];
  assign dcu_stop_fail_cnt    = dcurr[19:12];
  assign dcu_stop_on_nfail    = dcurr[20];
  assign dcu_stop_cap_on_full = dcurr[21];
  assign dcu_read_cap_en      = dcurr[22];
  assign dcu_compare_en       = dcurr[23];
         
  assign loop_start_addr      = dculr[3:0];
  assign loop_end_addr        = dculr[7:4];
  assign loop_cnt             = dculr[15:8];
  assign loop_infinite        = dculr[16];
  assign dcu_inc_dram_addr    = dculr[17];
  assign xpctd_loop_end_addr  = dculr[31:28];
         
  assign dcu_cap_start_word   = dcugcr[15:0];

  assign {t_dcut3, t_dcut2, t_dcut1, t_dcut0} = dcutpr;

  // EMR3 register bits
  assign mpr_en[0] = mr3[0][2];

  assign ddr_burst_len  = t_bl;
  assign sdr_burst_len  = t_bl/2;
  assign ctrl_burst_len = t_bl/(2*`CLK_NX);
  assign pub_burst_len  = t_bl/(2*`PUB_CLK_NX);

  assign cmpr_all_bytes = (bistrr[25:22] > `DWC_NO_OF_BYTES) ? 1'b1 : 1'b0;
  assign cmpr_byte_sel  = (bistrr[25:22] > `DWC_NO_OF_BYTES) ? 0    : bistrr[25:22];

  
  // static register bits
  // --------------------
  // DCR register bits:
  assign ddr_mode     =  dcr[2:0];
  assign ddr4_mode    = (dcr[2:0] == `DDR4_MODE)   ? 1'b1 : 1'b0;
  assign ddr3_mode    = (dcr[2:0] == `DDR3_MODE)   ? 1'b1 : 1'b0;
  assign ddr2_mode    = (dcr[2:0] == `DDR2_MODE)   ? 1'b1 : 1'b0;
  assign lpddr2_mode  = (dcr[2:0] == `LPDDR2_MODE) ? 1'b1 : 1'b0;
  assign lpddr3_mode  = (dcr[2:0] == `LPDDR3_MODE) ? 1'b1 : 1'b0;
  assign lpddrx_mode  = lpddr2_mode | lpddr3_mode;
  assign lpddr2_s4    = (lpddr2_mode && dcr[9:8] == 2'b00) ? 1'b1 : 1'b0; //Changed lpddrx_mode and lpddrx_s4 to lpddr2_mode and lpdrr2_s4 respectively
  assign lpddr2_s2    = (lpddr2_mode && dcr[9:8] == 2'b01) ? 1'b1 : 1'b0; //Changed lpddrx_mode and lpddrx_s2 to lpddr2_mode and lpdrr2_s2 respectively
  assign ddr_2t       = dcr[28];

  assign ddr_8_bank   = dcr[3];

  // CDCR register bits:
  assign ddr_iowidth = cdcr[2:1];     // I/O width of each DDR SDRAM chip
  assign ddr_density = cdcr[5:3];     // density of each DDR SDRAM chip
  assign ddr_bytes   = cdcr[8:6];     // number of DDR bytes enabled
  assign ddr_ranks   = cdcr[11:10];   // DDR ranks
   
 // assign ddr_8_bank  = (((ddr3_mode | ddr_density[2] | ddr_density[1]) & !ddr4_mode) ||
 //                       (ddr4_mode && ddr_iowidth==2'b10));
  assign ddr_16_bank = ddr4_mode && (ddr_iowidth[1]==1'b0);

  assign sdram_chip  = {ddr_density, ddr_iowidth};
  assign max_banks   = (ddr_16_bank) ? 16: (ddr_8_bank) ? 8 : 4;
  
  // DTPR0/DTPR1 register bits
  assign t_mrd       = dtpr1[4:0];   // load mode to load mode
  assign t_wtr       = dtpr5[4:0];   // internal write to read
  assign t_rp        = (ddr_mode == `LPDDR3_MODE) ? dtpr0[14:8] + 7'd8 : dtpr0[14:8];  // precharge to activate
`ifdef DDR4
  assign t_mod       = dtpr1[10:8] + 24;
`else // DDR3
  assign t_mod       = dtpr1[10:8] + 12;
`endif
  assign t_rcd       = (ddr_mode == `LPDDR3_MODE) ? dtpr5[14:8] + 7'd8 : dtpr5[14:8];  // activate to read/write
  assign t_ras       = dtpr0[22:16]; // activate to precharge
  assign t_rrd       = dtpr0[29:24]; // activate to activate (different banks)
  assign t_rc        = dtpr5[23:16]; // activate to activate
  
  assign t_aond      = dtpr4[29:28]; // ODT turn-on delay
  assign t_rtw       = dtpr2[28];    // read to write
  assign t_rtodt     = dtpr2[24];
  assign t_faw       = dtpr1[23:16];  // 4-bank active window
  assign t_rfc       = dtpr4[25:16];
  assign t_wlmrd     = dtpr1[29:24];
  assign t_wlo       = dtpr4[11:8];
  assign t_dqsck     = dtpr3[2:0];
  assign t_dqsckmax  = dtpr3[10:8];

  // cas to cas delay within a bank groups
  always@(*) begin
  integer i;
    if (ddr4_mode) begin
      for(i=0; i<pNO_OF_PRANKS;i=i+1)
      begin
        case (mr6[i][12:10])
          3'b000   : t_ccd_l = 4;
          3'b001   : t_ccd_l = 5;
          3'b010   : t_ccd_l = 6;
          3'b011   : t_ccd_l = 7;
          3'b100   : t_ccd_l = 8;
          // codes 2 and 3 reserved for future use in DDR4
          default : t_ccd_l = 4;
        endcase
      end
    end else begin
      t_ccd_l = bl2;
    end
  end

  // cas to cas delay between bank groups
  always@(*) begin
    case (dtpr3[30:28])
      3'b000   : t_ccd_s = bl2; 
      3'b001   : t_ccd_s = bl2+1;
    endcase
  end

  always @(*) begin
    if (ddr_mode == `DDR4_MODE) begin
      case (mr0[11:9])
        3'b000:  t_rtp = 5'd5;
        3'b001:  t_rtp = 5'd6;
        3'b010:  t_rtp = 5'd7;
        3'b011:  t_rtp = 5'd8;
        3'b100:  t_rtp = 5'd9;
        3'b101:  t_rtp = 5'd10;
        3'b110:  t_rtp = 5'd12;
        3'b111:  t_rtp = 5'd12;
        default: t_rtp = 5'd12;
      endcase // case(mr0[11:9])
    end else begin
        t_rtp = dtpr0[3:0];   // internal read to precharge
    end
  end

  assign t_rpa       = (lpddrx_mode==1'b0) ? t_rp + ddr_8_bank :
                       (lpddr2_mode==1'b1) ? t_rp + ddr_8_bank : t_rp + 8;

  // decode timing parameters from register bits
  always @(*) begin
    // programmable burst length
    integer i;
    case (ddr_mode)
      `DDR3_MODE, `DDR4_MODE: begin
        case (mr0[1:0])
          2'b00:   bl = 5'b01000; // BL = 8 (fixed)
          2'b01:   bl = 5'b01000; // BL = 8 or 4 (on the fly) 
          2'b10:   bl = 5'b00100; // BL = 4 (fixed)
          default: bl = 5'b00100; // BL = reserved (uses default 4)
        endcase // case(mr0[1:0])
      end
      `LPDDR2_MODE: begin
        case (mr1[0][2:0])
          3'b010:  bl = 5'b00100; // BL = 4
          3'b011:  bl = 5'b01000; // BL = 8
          3'b100:  bl = 5'b10000; // BL = 16
          default: bl = 5'b00100; // BL = reserved (uses default 4)
        endcase // case (mr1[2:0])
      end
      `LPDDR3_MODE: begin
        case (mr1[0][2:0])
          3'b011:  bl = 5'b01000; // BL = 8
          default: bl = 5'b01000; // BL = reserved (uses default as 8 since only BL=8 is supported)
        endcase // case (mr1[2:0])
      end

      default: begin // DDR2
        case (mr0[2:0])
          3'b001:  bl = 5'b00010; // BL = 2
          3'b010:  bl = 5'b00100; // BL = 4 
          3'b011:  bl = 5'b01000; // BL = 8
          default: bl = 5'b00100; // BL = reserved (uses default 4)
        endcase // case(mr0[2:0])
      end
    endcase // case (ddr_mode)

    // CAS latency and CAS write latency
    case (ddr_mode)
      `DDR3_MODE: begin
        cl  = {1'b0, mr0[6:4]} + 4'd4 + {mr0[2], 3'b000};
        cwl = mr2[0][5:3] + 5;
      end
      `DDR4_MODE: begin
        case ({mr0[6:4], mr0[2]})
          0: cl = 9;
          1: cl = 10;
          2: cl = 11;
          3: cl = 12;
          4: cl = 13;
          5: cl = 14;
          6: cl = 15;
          7: cl = 16;
          8: cl = 18;
          9: cl = 20;
          10: cl = 22;
          11: cl = 24;
          13: cl = 17;
          14: cl = 19;
          15: cl = 21;
          default: begin
//ROB-TBD            `SYS.error;
//ROB-TBD            $display("ERROR: cl in DDR4_mode is undefined...");
          end
        endcase
        
 
        case (mr2[0][5:3])
          0: cwl = 9;
          1: cwl = 10;
          2: cwl = 11;
          3: cwl = 12;
          4: cwl = 14;
          5: cwl = 16;
          6: cwl = 18;
          default: begin
//ROB-TBD            `SYS.error;
//ROB-TBD            $display("ERROR: cwl in DDR4_mode is undefined...");
          end
        endcase
      end
      `DDR2_MODE: begin
        cl  = {3'b0,  mr0[6:4]};
        cwl = {3'b00, mr0[6:4]} - 1;
      end
      `LPDDR2_MODE: begin
        case (mr2[0][3:0])
          1: {cl, cwl} = {6'd3, 6'd1};
          2: {cl, cwl} = {6'd4, 6'd2};
          3: {cl, cwl} = {6'd5, 6'd2};
          4: {cl, cwl} = {6'd6, 6'd3};
          5: {cl, cwl} = {6'd7, 6'd4};
          6: {cl, cwl} = {6'd8, 6'd4};
        endcase // case (mr2[3:0])
      end
      `LPDDR3_MODE: begin    
          case (mr2[0][3:0])
            1: {cl, cwl} = {6'd3, 6'd1};
            4: {cl, cwl} = {6'd6, 6'd3}; //DDRG2MPHY: Changed mr2 value from 3 to 4 as per info from Elpida on 18th Jan 2012
            6: {cl, cwl} = {6'd8, 6'd4};
            7: {cl, cwl} = {6'd9, 6'd5};
          `ifdef LPDDR3_SET_A_LAT
            8: {cl, cwl} = {6'd10, 6'd6};
            9: {cl, cwl} = {6'd11, 6'd6};
           10: {cl, cwl} = {6'd12, 6'd6};
           12: {cl, cwl} = {6'd14, 6'd8};
           14: {cl, cwl} = {6'd16, 6'd8};
          `elsif LPDDR3_SET_B_LAT
            8: {cl, cwl} = {6'd10, 6'd8};
            9: {cl, cwl} = {6'd11, 6'd9};
           10: {cl, cwl} = {6'd12, 6'd9};
           12: {cl, cwl} = {6'd14, 6'd11};
           14: {cl, cwl} = {6'd16, 6'd13};
          `endif
          endcase // case (mr2[3:0])
        end
        default: begin
          cl  = {1'b0,  mr0[6:4]}; // DDR1/DDR2/LPDDR
          cwl = mr2[0][5:3] + 5;
        end
      endcase // case (ddr_mode)
    
    // write recovery
    case (ddr_mode)
      `DDR4_MODE: begin
        case (mr0[11:9])
          3'b000:  t_wr = 5'd10;
          3'b001:  t_wr = 5'd12;
          3'b010:  t_wr = 5'd14;
          3'b011:  t_wr = 5'd16;
          3'b100:  t_wr = 5'd18;
          3'b101:  t_wr = 5'd20;
          3'b110:  t_wr = 5'd24;
          3'b111:  t_wr = 5'd24;
          default: t_wr = 5'd24;
        endcase // case(mr0[11:9])
      end
      `DDR3_MODE: begin
        case (mr0[11:9])
          3'b000:  t_wr = 5'd16;
          3'b001:  t_wr = 5'd5;
          3'b010:  t_wr = 5'd6;
          3'b011:  t_wr = 5'd7;
          3'b100:  t_wr = 5'd8;
          3'b101:  t_wr = 5'd10;
          3'b110:  t_wr = 5'd12;
          3'b111:  t_wr = 5'd14;
          default: t_wr = 5'd16;
        endcase // case(mr0[11:9])
      end
      `DDR2_MODE: begin
        t_wr = {1'b0, mr0[11:9]} + 1;
      end
      `LPDDR2_MODE: begin
        case (mr1[0][7:5])
          3'b001:  t_wr = 5'd3;
          3'b010:  t_wr = 5'd4;
          3'b011:  t_wr = 5'd5;
          3'b100:  t_wr = 5'd6;
          3'b101:  t_wr = 5'd7;
          3'b110:  t_wr = 5'd8;
          default: t_wr = 5'd3; //DDRG2MPHY: Sreejith Changed from 8 to 3 on 14th Dec 2011
        endcase // case (mr1[7:5])
      end
      `LPDDR3_MODE: begin
        case ({mr2[0][4], mr1[0][7:5]})
          4'b0001:  t_wr = 5'd3;
          4'b0100:  t_wr = 5'd6;
          4'b0110:  t_wr = 5'd8;
          4'b0111:  t_wr = 5'd9;
          4'b1000:  t_wr = 5'd10;
          4'b1001:  t_wr = 5'd11;
          4'b1010:  t_wr = 5'd12;
          4'b1100:  t_wr = 5'd14;
          4'b1110:  t_wr = 5'd16;
          default:  t_wr = 5'd3;
        endcase
      end
      default: t_wr = 1; // DDR1/LPDDR1
    endcase // case (ddr_mode)
  end // always @ (*)

  always @(*) begin
    // additive CAS latency
    integer i;
    case (ddr_mode)
      `DDR3_MODE, `DDR4_MODE: begin
        case (mr1[0][4:3])
          2'b00:   al = 0;
          2'b01:   al = cl - 1;
          2'b10:   al = cl - 2;
          default: al = 0;
        endcase // case(mr[4:3])
      end
      `DDR2_MODE: begin
        al = {1'b0, mr1[0][5:3]};
      end
      default: al = 0;
    endcase // case (ddr_mode)
  end

  // DDR4 CA Parity Latency 
  assign ca_par_lat  = (ddr4_mode && (mr5[0][2:0] == 3'b001)) ? 4 :
                       (ddr4_mode && (mr5[0][2:0] == 3'b010)) ? 5 :
                       (ddr4_mode && (mr5[0][2:0] == 3'b011)) ? 6 :
                       (ddr4_mode && (mr5[0][2:0] == 3'b100)) ? 8 :
                                                             0;
  assign dll_off_mode = (ddr4_mode && (mr1[0][0]==1'b0)) || ((ddr3_mode || ddr2_mode) && (mr1[0][0]==1'b1));
  
  assign ddr3_bl     = mr0[1:0];
  assign ddr3_blotf  = ((ddr3_mode || ddr4_mode) && (mr0[1:0] == 2'b01)) ? 1'b1 : 1'b0;
  assign ddr3_bl4fxd = ((ddr3_mode || ddr4_mode) && (mr0[1:0] == 2'b10)) ? 1'b1 : 1'b0;
  
  generate
  genvar rank_idx;
  for(rank_idx=0; rank_idx<pNO_OF_PRANKS;rank_idx=rank_idx+1) 
    assign ddr3_odt_en = ((ddr3_mode & (mr1[rank_idx][9] | mr1[rank_idx][6] | mr1[rank_idx][2])) || 
                         (ddr4_mode & (|mr1[rank_idx][10:8]))) ;
  endgenerate

  assign t_bl  = bl;
  assign t_cl  = cl;
  assign t_cwl = cwl;
  assign t_al  = al;

  // derived timing parameters
  // NOTE: t_rd2wr in DDR2 should theoretically be bl2 + 2, but since the PHY
  //       DDR2 preamble is a full clock cycle, instead of the minimum 1/2
  //       clock cycle, an extra cycle has to be added to the timing, thus
  //       bl2 + 2 + 1
  // NOTE: because of tDQSS, effective latency for LPDDR2 is CWL+1/CL+1
  assign bl2        = bl[4:1];  // BL/2

  assign rdimm_cmd_lat  = (`DWC_RDIMM == 0) ?           3'd0 : 
                          (rdimmcr1[0][31:28] == 4'd0)? 3'd1 :
                          (rdimmcr1[0][31:28] == 4'd1)? 3'd2 :
                          (rdimmcr1[0][31:28] == 4'd2)? 3'd3 :
                          (rdimmcr1[0][31:28] == 4'd3)? 3'd4 :
                                                        3'd0;
  
  assign wl        = (ddr3_mode)  ? al + cwl                             : // DDR3 write latency
                     (ddr4_mode)  ? al + cwl + ca_par_lat + rdimm_cmd_lat: // DDR4 write latency
                     (lpddrx_mode)?  1 + cwl                             : // LPDDR2
                                    al +  cl - 1;                          // DDR2 write latency
  
  assign rl        = (lpddrx_mode) ? t_dqsck + cl                                  : // LPDDR2 read latency
                     (dll_off_mode)? al      + cl -1 + ca_par_lat + t_dqsck        : // DDR2/3 read latency DLL off mode
                     (ddr4_mode)   ? al      + cl    + ca_par_lat + rdimm_cmd_lat  : // DDR4   read latency
                                     al      + cl    + ca_par_lat;                   // DDR2/3 read latency
                   
  assign sdram_rl  = (lpddrx_mode) ? t_dqsck + cl                                  : // LPDDR2 read latency
                     (dll_off_mode)? al      + cl -1 + ca_par_lat + t_dqsck        : // DDR2/3 read latency DLL off mode
                     (ddr4_mode)   ? al      + cl    + ca_par_lat                  : // DDR4   read latency
                                     al      + cl    + ca_par_lat;                   // DDR2/3 read latency

  assign t_act2rw   = t_rcd - al;                // activate to read/write
  assign t_rd2pre   = (lpddr2_s2) ? al + bl2 + t_rtp - 1 :     // LPDDR2-S2 read to precharge S2/S4 only available in LPDDR2
                                    al + bl2 + t_rtp - 2;      // read to precharge
  assign t_wr2pre   = wl + bl2 + t_wr;           // write to precharge
  assign trd2wr     = (ddr3_mode)  ? bl2 + 2 + cl - cwl :             // DDR3 read to write
                      (ddr4_mode)  ? bl2 + 2 + cl - cwl :             // DDR3 read to write
                      (lpddrx_mode)? bl2 + 1 + t_dqsckmax + cl - cwl + dqs_gatex : // LPDDR2 read to write
                                     bl2 + 2 + 1;                     // DDR2 read to write
  assign t_wr2rd    = (ddr2_mode) ? 
                      cl - 1 + bl2 + t_wtr :     // DDR2 write to read
                      wl + bl2 + t_wtr;          // DDR3/LPDDR2/DDR1/LPDDR1 write to read
  assign t_rdap2act = t_rd2pre + t_rp;           // read w/ precharge to activate
  assign t_wrap2act = (lpddr3_mode)? t_wr2pre + t_rp :
                                     t_wr2pre + t_rp;           // write w/ precharge to activate

`ifdef DWC_DDRPHY_EMUL_XILINX
  always @(*) begin
    case ({t_rtodt, t_rtw})
      2'b00: t_rd2wr = trd2wr + 2;     // normal read-to-write delay
      2'b01: t_rd2wr = trd2wr + 4; // extra clock for bus turn-around
      2'b10: t_rd2wr = trd2wr + 6; // extra clock for read-to-ODT delay
      2'b11: t_rd2wr = trd2wr + 8; // two extra clocks for the above
    endcase // case({trtodt, trtw})
  end
`else
  always @(*) begin
    case ({t_rtodt, t_rtw})
      2'b00: t_rd2wr = trd2wr;     // normal read-to-write delay
      2'b01: t_rd2wr = trd2wr + 1; // extra clock for bus turn-around
      2'b10: t_rd2wr = trd2wr + 1; // extra clock for read-to-ODT delay
      2'b11: t_rd2wr = trd2wr + 2; // two extra clocks for the above
    endcase // case({trtodt, trtw})
  end
`endif
  assign ol = wl - 1;

  assign olp2 = ol + 2;

  // timing parameters are registered to avoid logic clouding on 
  // timing-critical signals
  always @(posedge clk or negedge rst_b)
    begin
      if (rst_b == 1'b0)
        begin
          ddr2_bl4   <= 1'b0;
          burst_len  <= {3{1'b0}};
          t_orwl_odd <= {3{1'b0}};
          t_wl       <= {tWRL_WIDTH{1'b0}};
          t_rl       <= {tWRL_WIDTH{1'b0}};
          t_ol       <= {tOL_WIDTH{1'b0}};
          t_wl_eq_1  <= 1'b0;
          t_rl_eq_3  <= 1'b0;
          pdr_burst_len  <= {2{1'b0}};
        end
      else
        begin
          pdr_burst_len  <=  (bl2 == 4'b1000)             ? 3'b011 :
                             (ddr3_mode || bl2 == 3'b100) ? 3'b001 :
                             (ddr4_mode || bl2 == 3'b100) ? 3'b001 :
                                                            3'b000 ;
          ddr2_bl4   <= (burst_len == 3'b000) ? 1'b1 : 1'b0;
          if (hdr_mode)
            begin
              burst_len  <= (bl2 == 4'b1000)             ? 3'b011 : // BL16
                            (ddr4_mode || bl2 == 3'b100) ? 3'b001 :
                            (ddr3_mode || bl2 == 3'b100) ? 3'b001 : 3'b000;
              t_orwl_odd <= {ol[0], rl[0], wl[0]};
              t_wl       <= {1'b0, wl          [tWRL_WIDTH-1:1]} - 1;
              t_rl       <= (rl == {{(tWRL_WIDTH-2){1'b0}}, 2'b11}) ?
                            {tWRL_WIDTH{1'b0}} : // special case RL = 3
                            {1'b0, rl          [tWRL_WIDTH-1:1]} - 2;
              t_ol       <= {1'b0, olp2        [tOL_WIDTH-1:1]};
              t_rl_eq_3  <= (rl == {{(tWRL_WIDTH-2){1'b0}}, 2'b11}) ?
                            1'b1 : // special case RL = 3
                            1'b0;
            end
          else
            begin
              burst_len  <= (ddr3_mode|ddr4_mode) ? 3'b011 : bl2 - 1;
              t_orwl_odd <= {ol[0], rl[0], wl[0]};
              t_wl       <= wl - 1;
              t_rl       <= rl - 2;
              t_ol       <= ol;
            end
        end
    end // always @ (posedge cfg_clk or negedge cfg_rst_b)

  assign t_xs   = dtpr2[9:0];
  assign t_xp   = dtpr4[4:0];
  assign t_cke  = dtpr2[19:16];
  assign t_dllk = dtpr3[25:16] +8'h80;  //add offset of 128 to programmed tdllk value

  // DRAM initialization timing
  assign tdinit0 = ptr3[19:0];
  assign tdinit1 = ptr3[29:20];
  assign tdinit2 = ptr4[17:0];
  assign tdinit3 = ptr4[28:18];
  
  always @(*) begin
    case(ddr_mode)
      `DDR4_MODE: 
        begin
          tdinitckelo = tdinit0;
          tdinitckehi = tdinit1;
          tdinitrst   = tdinit2;
          tdinitzq    = tdinit3;
        end
      `DDR3_MODE: 
        begin
          tdinitckelo = tdinit0;
          tdinitckehi = tdinit1;
          tdinitrst   = tdinit2;
          tdinitzq    = tdinit3;
        end
      `DDR2_MODE:
        begin
          tdinitckelo = tdinit0;
          tdinitckehi = tdinit1;
          tdinitrst   = tdinit2;
          tdinitzq    = tdinit3;
        end
      `LPDDR2_MODE:
        begin
          tdinitckelo = tdinit1;
          tdinitckehi = tdinit0;
          tdinitrst   = tdinit2;
          tdinitzq    = tdinit3;
        end
      `LPDDR3_MODE:
        begin
          tdinitckelo = tdinit1;
          tdinitckehi = tdinit0;
          tdinitrst   = tdinit2;
          tdinitzq    = tdinit3;
        end
      default:
        begin
          tdinitckelo = tdinit0;
          tdinitckehi = tdinit1;
          tdinitrst   = tdinit2;
          tdinitzq    = tdinit3;
        end
    endcase
  end
  
  
  // set write-leveling pipelines
  // ----------------------------
  // indicates whether a byte needs extra pipelining because write leveling
  // increased it's delay by 0 upto 4 clocks by increments of 0.5 clocks
  task set_wl_pipeline;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 
    input [pWLSL_WIDTH     -1:0] wl_extra_pipe;
    begin
`ifdef DDR2
      // no write leveling for DDR2
      wl_extra_pipe = 0;
`endif
      // Max wl_extra_pipe supported is 8 extra; ie: WL+4 which is WLSL==2*4 + 2 (offset)
      if (wl_extra_pipe <= 8)
        wl_pipe[rank_no][lane_no] = wl_extra_pipe + 2; // wlsl=4'h2 when WL=0
      else
        wl_pipe[rank_no][lane_no] = 8 + 2; // MAX out at 10 or wl_extra_pipe of 8 

      // write the expected write latency to the GRM latency registers
      update_wl_dxngtr0(rank_no, lane_no);
    end
  endtask // set_wl_pipeline


  // indicates whether a byte needs early pipelining because write leveling
  // mistakenly increased it's delay by 1 clock
  task set_wl_early_pipeline;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 
    input                        wl_early_pipe;
    begin
`ifdef DDR2
      // no write leveling for DDR2
      wl_early_pipe = 0;
`endif
      wl_pipe[rank_no][lane_no] = wl_early_pipe; // Write latency of -1   when wl_early_pipe is 0
                                                 // Write latency of -0.5 when wl_early_pipe is 1
      // write the expected write latency to the GRM latency registers
      update_wl_dxngtr0(rank_no, lane_no);
    end
  endtask // set_wl_early_pipeline


  task update_wl_dxngtr0;                   
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 
    begin
      if (`DWC_DX_NO_OF_DQS == 2'd1)
        begin
          `GRM.rankidr[0 +: 4] = rank_no;
          dxngtr0[rank_no][lane_no][16 +: pWLSL_WIDTH] = wl_pipe[rank_no][lane_no];
          `GRM.write_register(`DX0GTR0 + (`DX_REG_RANGE * lane_no), dxngtr0[rank_no][lane_no]);
          `FCOV_REG.set_cov_registers_write(`DX0GTR0 + (`DX_REG_RANGE * lane_no), dxngtr0[rank_no][lane_no],`VALUE_REGISTER_DATA);
        end
      else 
        begin
          if ( lane_no%2 == 0 )
            begin
              `GRM.rankidr[0 +: 4] = rank_no;
              dxngtr0[rank_no][lane_no/2][16 +: pWLSL_WIDTH] = wl_pipe[rank_no][lane_no];
              `GRM.write_register(`DX0GTR0 + (`DX_REG_RANGE * (lane_no/2)), dxngtr0[rank_no][lane_no/2]);
              `FCOV_REG.set_cov_registers_write(`DX0GTR0 + (`DX_REG_RANGE * (lane_no/2)), dxngtr0[rank_no][lane_no/2],`VALUE_REGISTER_DATA);
            end
          else
            begin
              `GRM.rankidr[0 +: 4] = rank_no;
              dxngtr0[rank_no][(lane_no-1)/2][20 +: pWLSL_WIDTH] = wl_pipe[rank_no][lane_no];
              `GRM.write_register(`DX0GTR0 + (`DX_REG_RANGE * ((lane_no-1)/2)), dxngtr0[rank_no][(lane_no-1)/2]);
              `FCOV_REG.set_cov_registers_write(`DX0GTR0 + (`DX_REG_RANGE * ((lane_no-1)/2)), dxngtr0[rank_no][(lane_no-1)/2],`VALUE_REGISTER_DATA);
            end
        end // else: !if(`DWC_DX_NO_OF_DQS == 2'd1)

      `GRM.rankidr[0 +: 4] = 0;
      
    end
  endtask

  // set DQS gating pipeline
  // -----------------------
  // indicates whether a byte needs extra DQS gating pipelining because because
  // its total DQS gating delay is more than 1 clock
  task set_dqs_gate_pipeline;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 
    input [pDGSL_WIDTH     -1:0] dqs_gate_pipe;
      
    integer                      rank_idx, lane_idx, nbl_idx;
    reg [pDGSL_WIDTH       -1:0] rsl;
    reg [pDGSL_WIDTH       -1:0] tmp_pipe [pNO_OF_LRANKS-1:0][pNUM_LANES-1:0];
    begin
      gdqs_pipe[rank_no][lane_no] = dqs_gate_pipe;
      
      // compute the maximum read system latency in the system
      max_rsl  = 0;
      tmp_pipe[rank_no][lane_no] = gdqs_pipe[rank_no][lane_no];
      for (rank_idx = 0; rank_idx < pNO_OF_LRANKS; rank_idx = rank_idx + 1) begin
        for (lane_idx = 0; lane_idx <pNUM_LANES; lane_idx = lane_idx +1) begin
          rsl = tmp_pipe[rank_idx][lane_idx];
          
          if (rsl > max_rsl) max_rsl = rsl;
        end
      end


      // write the expected latency to the GRM latency registers
      if (`DWC_DX_NO_OF_DQS == 2'd1)
        begin
          `GRM.rankidr[0 +: 4] = rank_no;
          dxngtr0[rank_no][lane_no][0 +: pDGSL_WIDTH] = dqs_gate_pipe;
          `GRM.write_register(`DX0GTR0 + (`DX_REG_RANGE * lane_no), dxngtr0[rank_no][lane_no]);
          `FCOV_REG.set_cov_registers_write(`DX0GTR0 + (`DX_REG_RANGE * lane_no), dxngtr0[rank_no][lane_no],`VALUE_REGISTER_DATA);
        end
      else 
        begin
          if ( lane_no%2 == 0 )
            begin
              `GRM.rankidr[0 +: 4] = rank_no;
              dxngtr0[rank_no][lane_no/2][0 +: pDGSL_WIDTH] = dqs_gate_pipe;
              `GRM.write_register(`DX0GTR0 + (`DX_REG_RANGE * (lane_no/2)), dxngtr0[rank_no][lane_no/2]);
              `FCOV_REG.set_cov_registers_write(`DX0GTR0 + (`DX_REG_RANGE * (lane_no/2)), dxngtr0[rank_no][lane_no/2],`VALUE_REGISTER_DATA);
            end
          else
            begin
              `GRM.rankidr[0 +: 4] = rank_no;
              dxngtr0[rank_no][(lane_no-1)/2][8 +: pDGSL_WIDTH] = dqs_gate_pipe;
              `GRM.write_register(`DX0GTR0 + (`DX_REG_RANGE * ((lane_no-1)/2)), dxngtr0[rank_no][(lane_no-1)/2]);
              `FCOV_REG.set_cov_registers_write(`DX0GTR0 + (`DX_REG_RANGE * ((lane_no-1)/2)), dxngtr0[rank_no][(lane_no-1)/2],`VALUE_REGISTER_DATA);
            end
        end // else: !if(`DWC_DX_NO_OF_DQS == 2'd1)
      `GRM.rankidr[0 +: 4] = 0;
    end
  endtask // set_dqs_gate_pipeline
  

  // system latencies used by the DFI when outside the PUB  
`ifdef NCVERILOG
  // current versions of NC-verilog don't seem to correctly use these arrays in
  // sensitivity list - using the clock instead
  always @(posedge `SYS.clk)
`else
    always @(*)
`endif
      begin: gdqs_system_latency
        integer i;

        for (rank_no = 0; rank_no < pNO_OF_LRANKS; rank_no = rank_no + 1) begin
          for (lane_no = 0; lane_no <pNUM_LANES; lane_no = lane_no +1) begin
            
            gdqs_rsl[rank_no][lane_no] = gdqs_pipe[rank_no][lane_no];
          end
        end
        
      end

`ifdef NCVERILOG
  // current versions of NC-verilog don't seem to correctly use these arrays in
  // sensitivity list - using the clock instead
  always @(posedge `SYS.clk)
`else
    always @(*)
`endif
      begin: wl_system_latency
        integer i;

        for (rank_no = 0; rank_no < pNO_OF_LRANKS; rank_no = rank_no + 1) begin
          for (lane_no = 0; lane_no <pNUM_LANES; lane_no = lane_no +1) begin
            wl_wsl[rank_no][lane_no] = wl_pipe[rank_no][lane_no];
          end
        end
      end

  
  function [pDGSL_WIDTH  -1:0] get_dqs_gate_pipeline;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 

    reg [pDGSL_WIDTH  -1:0] rsl;
    begin
      rsl = gdqs_pipe[rank_no][lane_no];
      get_dqs_gate_pipeline = rsl;
    end
  endfunction // get_dqs_gate_pipeline

  function [7:0] get_dqs_gate_lcdl_dly;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 
    reg [7:0]   lcdl_dly;
    begin
      if (`DWC_DX_NO_OF_DQS == 1) 
        begin
          
          lcdl_dly = dxnlcdlr2[rank_no][lane_no][0  +: `LCDL_DLY_WIDTH];
        end
      else
        begin
          if (lane_no %2 == 0) // These registers contain the values for nibble0
            begin
              
              lcdl_dly = dxnlcdlr2[rank_no][lane_no/2][0  +: `LCDL_DLY_WIDTH];
            end
          else // these registers contain nibble1 values
            begin
              lcdl_dly = dxnlcdlr2[rank_no][(lane_no-1)/2][16 +: `LCDL_DLY_WIDTH];
            end // else: !if(lane_no %2 == 0)
        end // else: !if(`DWC_DX_NO_OF_DQS == 1)
      
      get_dqs_gate_lcdl_dly = lcdl_dly;
    end
  endfunction // get_dqs_gate_lcdl_dly

  function [pWLSL_WIDTH-1:0] get_wl_pipeline;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 

    reg [pWLSL_WIDTH-1:0]        wsl;
    begin
      wsl             = wl_pipe[rank_no][lane_no];
      get_wl_pipeline = wsl;
    end
  endfunction // get_wl_pipeline

  function [7:0] get_wl_lcdl_dly;
    input [pNO_OF_LRANKS   -1:0] rank_no;
    input [pNUM_LANES      -1:0] lane_no; 

    reg [7:0]   lcdl_dly;
    begin
      if (`DWC_DX_NO_OF_DQS == 1) 
        begin
          
          lcdl_dly = dxnlcdlr0[rank_no][lane_no][0  +: `LCDL_DLY_WIDTH];
        end
      else
        begin
          if (lane_no %2 == 0) // These registers contain the values for nibble0
            begin
              lcdl_dly = dxnlcdlr0[rank_no][lane_no/2][0  +: `LCDL_DLY_WIDTH];
            end
          else // these registers contain nibble1 values
            begin
              lcdl_dly = dxnlcdlr0[rank_no][(lane_no-1)/2][16  +: `LCDL_DLY_WIDTH];
            end // else: !if(lane_no %2 == 0)
        end // else: !if(`DWC_DX_NO_OF_DQS == 1)
      get_wl_lcdl_dly = lcdl_dly;
    end
  endfunction // get_wl_lcdl_dly

  
  //---------------------------------------------------------------------------
  // ZQ calibration
  //---------------------------------------------------------------------------
  // expected values of ZQ calibration

  // expected ZQ calibration status
  // ------------------------------
  // sets the expected status bits for ZQ calibration
 
  task set_expected_zcal_done_status;
    input [31:0] zctrl_no;
    input        zdone;
    input        zerr;
    input [1:0]  opu;
    input [1:0]  opd;
    input [1:0]  zpu;
    input [1:0]  zpd;
    begin
`ifdef DWC_DDRPHY_NO_PZQ
`else
      //TODO: add pu_drv_sat, pd_drv_sat
      zqnsr[zctrl_no][9]    = zdone; 
      zqnsr[zctrl_no][8]    = zerr; 
      zqnsr[zctrl_no][7:6]  = opu;
      zqnsr[zctrl_no][5:4]  = opd;
      zqnsr[zctrl_no][3:2]  = zpu;
      zqnsr[zctrl_no][1:0]  = zpd;
`endif
    end
  endtask // set_expected_zcal_done_status

//DDRG2MPHY: Need to check how this is applicable for G2MPHY
//ZQDR is used to write the zctrl data... The status is also read from the same register?
  // sets the expected ZCTRL status and optionally reads the status registers
  task set_and_read_expected_zcal_status;
    input [31:0]                 zctrl_no; 
    input [`ZCTRL_ODT_WIDTH-1:0] zctrl_odt;
    input [`ZCTRL_DRV_WIDTH-1:0] zctrl_drv;
    input                        zqsr_read;
    begin
`ifdef DWC_DDRPHY_NO_PZQ
`else
    //zqndr[zctrl_no][31:16] = (zqnpr[zctrl_no][30]) ? zqndr[zctrl_no][31:16] : (~{`ZCTRL_ODT_WIDTH{`ZCAL_FSM.term_off}} & zctrl_odt);
    zqndr[zctrl_no][0+:8]  = (zqnpr[zctrl_no][31]) ? zqndr[zctrl_no][0+:`ZCTRL_IMP_WIDTH] : zctrl_drv[0+:`ZCTRL_IMP_WIDTH];
    zqndr[zctrl_no][8+:8]  = (zqnpr[zctrl_no][31]) ? zqndr[zctrl_no][8+:`ZCTRL_IMP_WIDTH] : zctrl_drv[`ZCTRL_IMP_WIDTH+:`ZCTRL_IMP_WIDTH];
    zqndr[zctrl_no][16+:8] = (zqnpr[zctrl_no][30]) ? zqndr[zctrl_no][16+:`ZCTRL_IMP_WIDTH]: 
                                                     (~{`ZCTRL_IMP_WIDTH{zqcr[1]}} & zctrl_odt[0+:`ZCTRL_IMP_WIDTH]);
    zqndr[zctrl_no][24+:8] = (zqnpr[zctrl_no][30]) ? zqndr[zctrl_no][24+:`ZCTRL_IMP_WIDTH]: 
                                                     (~{`ZCTRL_IMP_WIDTH{zqcr[1]}} & zctrl_odt[`ZCTRL_IMP_WIDTH+:`ZCTRL_IMP_WIDTH]);
`endif
    // read the status
    if (zqsr_read)
      begin
        @(posedge `CFG.clk);
        // TODO -> maybe this should be ZQ0SR for status register read???
        `CFG.read_register(`ZQ0SR + 4*zctrl_no);
        `CFG.read_register(`ZQ0DR + 4*zctrl_no);
      end
    end
  endtask // set_and_read_expected_zcal_status

  // sets expected ZCTRL status and reads the ZQnSR registers
  task read_expected_zcal_status;
    input [31:0]                 zctrl_no; 
    input [`ZCTRL_ODT_WIDTH-1:0] zctrl_odt;
    input [`ZCTRL_DRV_WIDTH-1:0] zctrl_drv;
    begin
      set_and_read_expected_zcal_status(zctrl_no, zctrl_odt, zctrl_drv, 1);
      // For LPDDR2, discard termination calibration values
      `ifdef LPDDR2
          if (zctrl_no == `DWC_NO_OF_ZQ_SEG-1) begin
              `GRM.zqcr[1] = 1'b1;
              `CFG.write_register(`ZQCR, `GRM.zqcr);
          end
      `endif
    end
  endtask // read_expected_zcal_status

  // only sets expected ZCTRL status without reading the ZQnSR registers
  task set_expected_zcal_status;
    input [31:0]                 zctrl_no; 
    input [`ZCTRL_ODT_WIDTH-1:0] zctrl_odt;
    input [`ZCTRL_DRV_WIDTH-1:0] zctrl_drv;
    begin
      set_and_read_expected_zcal_status(zctrl_no, zctrl_odt, zctrl_drv, 0);
    end
  endtask // set_expected_zcal_status


  // expected ZCTRL values
  // ---------------------
  // generates the expected value of the ZCTRL bus depending on the ZPROG or
  // target resistor
  function [`ZCTRL_WIDTH-1:0] generate_expected_zctrl_bus;
    input [11:0] zprog;        // [3:0] zprog_asym_drv_pu
                               // [7:4] zprog_asym_drv_pd
                               // [11:8] zprog_pu_odt_only
    input [1:0] pu_drv_adjust; // if set to 00, no adjustment
                               // if set to 01, multiply drive by 2/8
                               // if set to 10, multiply drive by 3/8
                               // if set to 11, multiply drive by 4/8
    input [1:0] pd_drv_adjust; // if set to 00, no adjustment
                               // if set to 01, multiply drive by 2/8
                               // if set to 10, multiply drive by 3/8
                               // if set to 11, multiply drive by 4/8
    
    integer    i;
    reg [4:0]                   pu_zout_trippoint;
    reg [4:0]                   pd_zout_trippoint;
    reg [4:0]                   odt_trippoint;
    reg [`ZCTRL_WIDTH-1:0]      zctrl;
    reg [2:0]                   pu_drv_adj_use;
    reg [2:0]                   pd_drv_adj_use;
    reg [`ZCTRL_IMP_WIDTH-1:0]  exp_zctrl_pu;
    reg [`ZCTRL_IMP_WIDTH-1:0]  exp_zctrl_pd;
    reg [`ZCTRL_IMP_WIDTH:0]    pu_adj_drv_code;
    reg [`ZCTRL_IMP_WIDTH:0]    pd_adj_drv_code;

    reg [`ZCTRL_IMP_WIDTH-1:0]  zout_pu_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0]  zout_pd_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0]  odt_pu_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0]  odt_pd_zctrl;
//    reg [`ZLSB_WIDTH-1:0]  zout_pu_zlsb;
//    reg [`ZLSB_WIDTH-1:0]  zout_pd_zlsb;
//    reg [`ZLSB_WIDTH-1:0]  odt_pu_zlsb;
//    reg [`ZLSB_WIDTH-1:0]  odt_pd_zlsb;
    
    begin
      // generate the expected trip points for output impedance and on-die 
      // termination      
      pu_zout_trippoint = get_target_trippoint(zprog[3:0]);
      pd_zout_trippoint = get_target_trippoint(zprog[7:4]);
      odt_trippoint     = get_target_trippoint(zprog[11:8]);
      exp_zctrl_pu = get_expected_zctrl(pu_zout_trippoint);
      exp_zctrl_pd = get_expected_zctrl(pd_zout_trippoint);

     // generate the expected output driver ZCTRL 
      pu_drv_adj_use  = {1'b0,pu_drv_adjust} + 3'b001;
      pd_drv_adj_use  = {1'b0,pd_drv_adjust} + 3'b001;
      pu_adj_drv_code = exp_zctrl_pu + ((pu_drv_adjust > 2'b00) ? (({3'b0,exp_zctrl_pu[`ZCTRL_IMP_WIDTH-1:3]}+{6'b0,exp_zctrl_pu[2]}) * pu_drv_adj_use) : 'b0);
      pd_adj_drv_code = exp_zctrl_pd + ((pd_drv_adjust > 2'b00) ? (({3'b0,exp_zctrl_pd[`ZCTRL_IMP_WIDTH-1:3]}+{6'b0,exp_zctrl_pd[2]}) * pd_drv_adj_use) : 'b0);
      zout_pu_zctrl = (pu_adj_drv_code > {`ZCTRL_IMP_WIDTH{1'b1}}) ? {`ZCTRL_IMP_WIDTH{1'b1}} : pu_adj_drv_code[`ZCTRL_IMP_WIDTH-1:0];
      zout_pd_zctrl = (pd_adj_drv_code > {`ZCTRL_IMP_WIDTH{1'b1}}) ? {`ZCTRL_IMP_WIDTH{1'b1}} : pd_adj_drv_code[`ZCTRL_IMP_WIDTH-1:0];
     // generate the expected on-die impedance ZCTRL
      odt_pu_zctrl  = get_expected_zctrl(odt_trippoint);
      odt_pd_zctrl  = get_expected_zctrl(odt_trippoint);

      // build up the expected ZCTRL bus
      zctrl = {odt_pu_zctrl, odt_pd_zctrl, zout_pu_zctrl, zout_pd_zctrl};
      
      generate_expected_zctrl_bus = zctrl;
    end
  endfunction // generate_expected_zctrl_bus

  // generates the target trippoint from ZRPOG settings
  function [4:0] get_target_trippoint;
//    input       cal_type;
    input [3:0] zprog;

//    reg [3:0]   cal_zprog;
    begin
//      cal_zprog = (cal_type == ZOUT_CAL) ? zprog[3:0] : zprog[7:4];
      
      case (zprog)
        4'b0000 : get_target_trippoint = 5'd0;
        4'b0001 : get_target_trippoint = 5'd2;
        4'b0010 : get_target_trippoint = 5'd2;
        4'b0011 : get_target_trippoint = 5'd4;
        4'b0100 : get_target_trippoint = 5'd4;
        4'b0101 : get_target_trippoint = 5'd6;
        4'b0110 : get_target_trippoint = 5'd8;
        4'b0111 : get_target_trippoint = 5'd8;
        4'b1000 : get_target_trippoint = 5'd10;
        4'b1001 : get_target_trippoint = 5'd10;
        4'b1010 : get_target_trippoint = 5'd12;
        4'b1011 : get_target_trippoint = 5'd12;
        4'b1100 : get_target_trippoint = 5'd14;
        4'b1101 : get_target_trippoint = 5'd16;
        4'b1110 : get_target_trippoint = 5'd16;
        default : get_target_trippoint = 5'd18;
      endcase // case (cal_zprog)
    end
  endfunction // get_target_trippoint

  
  // generates the expected ZCTRL from a target trip point for one calibration
  function [`ZCTRL_IMP_WIDTH-1:0] get_expected_zctrl;
    input [4:0] target_trip_point;
    begin
      // generate the expected ZCTRL encoding from a trip-point
      get_expected_zctrl = target_trip_point;
    end
  endfunction // get_expected_zctrl

  function [`ZCTRL_WIDTH-1:0] generate_zctrl_minus_1;
    input [`ZCTRL_WIDTH-1:0] zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] zout_pu_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] zout_pd_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] odt_pu_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] odt_pd_zctrl;
    begin
      {odt_pu_zctrl,
       odt_pd_zctrl,
       zout_pu_zctrl,
       zout_pd_zctrl} = zctrl;

      odt_pu_zctrl  = odt_pu_zctrl  - 1;
      odt_pd_zctrl  = odt_pd_zctrl  - 1;
      zout_pu_zctrl = zout_pu_zctrl - 1;
      zout_pd_zctrl = zout_pd_zctrl - 1;

      zctrl = {odt_pu_zctrl,
               odt_pd_zctrl,
               zout_pu_zctrl,
               zout_pd_zctrl};
      
      generate_zctrl_minus_1 = zctrl;
    end
  endfunction // generate_zctrl_minus_1


  function [`ZCTRL_WIDTH-1:0] generate_zctrl_plus_1;
    input [`ZCTRL_WIDTH-1:0] zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] zout_pu_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] zout_pd_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] odt_pu_zctrl;
    reg [`ZCTRL_IMP_WIDTH-1:0] odt_pd_zctrl;
    begin
      {odt_pu_zctrl,
       odt_pd_zctrl,
       zout_pu_zctrl,
       zout_pd_zctrl} = zctrl;

      odt_pu_zctrl  = odt_pu_zctrl  + 1;
      odt_pd_zctrl  = odt_pd_zctrl  + 1;
      zout_pu_zctrl = zout_pu_zctrl + 1;
      zout_pd_zctrl = zout_pd_zctrl + 1;

      zctrl = {odt_pu_zctrl,
               odt_pd_zctrl,
               zout_pu_zctrl,
               zout_pd_zctrl};
      
      generate_zctrl_plus_1 = zctrl;
    end
  endfunction // generate_zctrl_plus_1

  
  //---------------------------------------------------------------------------
  // Miscellaneous
  //---------------------------------------------------------------------------
  // miscellaneous tasks

  // log read output
  // ---------------
  // log (keep count of) read output received by different hosts, including
  // the configuration port
  task log_host_read_output;
    begin
      host_reads_rxd = host_reads_rxd + 1;
    end
  endtask // log_host_read_output

  task log_register_read_output;
    begin
      cfg_reads_rxd = cfg_reads_rxd + 1;
    end
  endtask // log_cfg_read_output


  // log burst length
  // ----------------
  // log the on-the-fly burst length that was used by the command
  // this is used by the monitor if the BFM is used to pop the expected data
  task log_burst_length;
    input bl4_otf;
    input rw_cmd;
    begin
      if (rw_cmd == `MSD_WRITE)
        wr_bl4_otf = bl4_otf;
      else
        rd_bl4_otf = bl4_otf;
    end
  endtask // log_burst_length

  function [2:0] get_burst_length;
    input rw_cmd;
    reg   bl4_otf;
    begin
      if (rw_cmd == `MSD_WRITE)
        bl4_otf = wr_bl4_otf;
      else
        bl4_otf = rd_bl4_otf;

      get_burst_length = (bl4_otf) ? 2/`CLK_NX : ctrl_burst_len;
    end
  endfunction // get_burst_length

  
  // valid bus/bit
  // -------------
  // checks if a variable or signal bus/bit has x's or z's
  function valid_bus;
    input [127:0] din;  // big enough to accomodate all buses
    begin
      valid_bus = (^(din) !== 1'bx);
    end
  endfunction // valid_bus

  function valid_bit;
    input din;
    begin
      valid_bit = (din !== 1'bx && din !== 1'bz);
    end
  endfunction // valid_bit


  // conversion between binary and gray code
  // ---------------------------------------
  function [3:0] gray2bin;
    input [3:0] gray_num;
    integer i;
    begin
      for (i=0; i<4; i=i+1)
        begin
          gray2bin[i] = ^(gray_num>> i);
        end
    end
  endfunction // gray2bin
  
  function [3:0] bin2gray;
    input [3:0] bin_num;
    begin
      bin2gray = (bin_num>> 1) ^ bin_num;
    end
  endfunction // bin2gray

  
  // controller register write
  // -------------------------
  // writes to a selected DDR controller (MCTL) register;
  // Note these registers are just for simulating registers that would normally be
  // in a memory controller - so only the GRM is written
  task write_controller_register;
    input [`REG_ADDR_WIDTH-1:0] addr;
    input [`REG_DATA_WIDTH-1:0] data;

    begin
      case (addr)
        `CDCR:    cdcr = data;
        `DRR:     drr  = data;
      endcase // case(addr)
      //Functional coverage Not necessay for the DDR3 PHY but may be used in the future,  it needs to activate the covergroups inside the ddr_fcov.v
      //`FCOV.set_cov_memory_timing_param(t_orwl_odd,t_mrd,t_rp,t_rrd,t_rc,t_faw,t_rfc,t_pre2act,t_act2rw,t_rd2pre,t_wr2pre,t_rd2wr,t_wr2rd,t_rdap2act,t_wrap2act);       
    end
  endtask // write_controller_register

  // DRR register bits
  assign ctrl_rfsh_en = drr [31];
  assign {ctrl_rfsh_burst, ctrl_rfsh_prd} = drr[21:0];

  
  //---------------------------------------------------------------------------
  // DRAM Command Unit (DCU)
  //---------------------------------------------------------------------------
  // generates expected values for command execution through the DCU

  // run/stop trigger
  // ----------------
  // triggers instruction running or stopping
  always @(dcu_start_run) begin
    // command issue to command execution latency
    repeat (tDCU_CMD_TO_RUN) @(posedge `CFG.clk);
    
    // clock domain crossing latency
    repeat (tDCU_RUN_TO_EXEC) @(posedge `SYS.dfi_phy_clk);
    
    // run the instructions
    run;
  end
  
  always @(dcu_stop_run) begin
    // command issue to command execution latency
    repeat (tDCU_CMD_TO_STOP) @(posedge `CFG.clk );
    
    // clock domain crossing latency
    repeat (tDCU_STOP_TO_EXEC) @(posedge `SYS.dfi_phy_clk);
    
    // run the instructions
    dcu_stop = 1'b1;
    @(posedge `SYS.dfi_phy_clk);
  end
  
  always @(dcu_stop_loop_run) begin
    // command issue to command execution latency
    repeat (tDCU_CMD_TO_STOP) @(posedge `CFG.clk );
    
    // clock domain crossing latency
    repeat (tDCU_STOP_TO_EXEC) @(posedge `SYS.dfi_phy_clk);
    
    // run the instructions
    dcu_stop_loop = 1'b1;
    @(posedge `SYS.dfi_phy_clk);
  end
  

  // instruction execution
  // ---------------------
  // execution of instructions through the command cache
  task run;
    integer i;
    reg [3:0] burst_len;
    reg [3:0] burst_no;
    reg       bl4_otf;
    reg       ddr3_bl4;
    reg       ddr3_bl4_nop;
    reg       grm_cmd;
    integer   loop_no;
    integer   rpt_no;
    reg [3:0] cmd_burst_len;

    integer ccache_addr;
    reg [`CCACHE_DATA_WIDTH-1:0] ccache_data;

    reg [`PUB_DATA_TYPE_WIDTH -1:0] data_type;
    
    reg [`DCU_DATA_WIDTH  -1:0] dcu_data;
    reg [`DCU_BYTE_WIDTH  -1:0] dcu_mask;
    reg [`PUB_DATA_WIDTH  -1:0] data;
    reg [`PUB_DQS_WIDTH   -1:0] mask;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] addr;
    reg [`DWC_PHY_BA_WIDTH+`DWC_PHY_BG_WIDTH  -1:0] bank;
    reg [`SDRAM_RANK_WIDTH-1:0] rank;
    reg [3                  :0] cmd;
    reg [1                  :0] tag;
    reg [`DTP_WIDTH       -1:0] dtp;
    reg [`DCU_RPT_WIDTH   -1:0] rpt;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] rd_addr;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] wr_addr;
    reg [31:0]                  dtp_val;
    reg [31:0]                  rpt_val;
    integer                     dtp_eff_val;

    reg                         rw_cmd;
    reg                         first_rd;
    reg                         first_wr;
    
    begin
      // indicates if DCU was run at least once
      dcu_was_run = 1'b1;
      
      // extract configuration parameters
      bl4_otf   = 0; // **TBD: add later
      ddr3_bl4  = ddr3_bl4fxd; // **TBD: | bl4_otf add later
      burst_len = (bl4_otf) ? 2/`PUB_CLK_NX : pub_burst_len;
      
      // execute instructions sequentially until end of instruction cache or
      // a STOP is issued
      @(posedge `SYS.dfi_phy_clk);
      dcu_reset_run_status;
      ccache_addr     = ccache_start_addr;
      ctl_ecache_addr = 0;//dcu_cap_start_word;//0;
      ctl_rcache_addr = 0;
      burst_no        = 0;
      dcu_run         = 1'b1;
      first_rd        = 1'b1;
      first_wr        = 1'b1;
      loop_no         = 0;
      ddr3_bl4_nop    = 0;
      while ((ccache_addr <= ccache_end_addr) && !(dcu_stop || dcu_fail_stop)) begin
      
        // read the instruction
        ccache_data = ccache[ccache_addr];
        if (`DWC_NO_OF_LRANKS > 1) begin
          {rpt, dtp, tag, cmd, rank, bank, addr, dcu_mask, dcu_data} = ccache_data;
        end else begin
          {rpt, dtp, tag, cmd,       bank, addr, dcu_mask, dcu_data} = ccache_data;
          rank = 0;
        end
        dtp_val = get_dram_timing_parameter(dtp);
        rpt_val = get_command_repeat(rpt);

        data_type = dcu_data;
        //data = get_encoded_pub_data(data_type);

`ifdef DWC_DDRPHY_EMUL_XILINX
        if(ccache_addr==0)begin
          // Reset 
          `ifdef DWC_DDRPHY_X4MODE
            dcu_emul_pattern=16'hA5E1;
          `else
            dcu_emul_pattern=32'hAA55EE11;
          `endif
          wr_cnt=0;
        end
`endif
        -> e_get_encoded_pub_data;

        get_encoded_pub_data(data_type,data);
        mask = {{pNUM_LANES{dcu_mask[3    ]}}, {pNUM_LANES{dcu_mask[2    ]}}, {pNUM_LANES{dcu_mask[1   ]}}, {pNUM_LANES{dcu_mask[0  ]}}};
        
        // execute the instruction so many times based on the repeat field
        grm_cmd = 1;

        for (rpt_no=0; rpt_no<(rpt_val+1); rpt_no=rpt_no+1) begin
          
        //  -> e_get_encoded_pub_data;
        //  get_encoded_pub_data(data_type,data);
          case (cmd)
            `SDRAM_WRITE, `WRITE_PRECHG: begin // write
              rd_cmd = 1'b0;
              rw_cmd = 1'b1;
              if (burst_no == 0 && dcu_bst_test) begin
                cmd_burst_len = get_effective_burst_length(ccache_addr);
              end else begin
                cmd_burst_len = burst_len;
              end
              
              if (first_wr || !dcu_inc_dram_addr) begin
                wr_addr = addr;
              end

              if (!ddr3_bl4_nop) begin
`ifdef DDR4
                `GRM.write(wr_addr, ~mask, data, burst_no);
`else
                `GRM.write(wr_addr, mask, data, burst_no);
`endif
              end

              if (burst_no == (cmd_burst_len-1)) begin
                burst_no = 0;
                // Increment write addr by the burst length - on a DDR3-BL4 the
                // addr is not incremented on the dummy write
                if (dcu_inc_dram_addr && !ddr3_bl4_nop) begin
                  wr_addr = wr_addr + 4*cmd_burst_len;
                end

                if (ddr3_bl4) begin
                  ddr3_bl4_nop = ~ddr3_bl4_nop;
                end
              end else begin
                burst_no = burst_no + 1;
              end

              first_wr = 0;
            end
            `SDRAM_READ, `READ_PRECHG: begin // read
              rd_cmd = 1'b1;
              rw_cmd = 1'b1;
`ifdef DWC_DDRPHY_EMUL_XILINX
              if(rpt_no==0)begin
                // Reset 
                `ifdef DWC_DDRPHY_X4MODE
                  dcu_emul_pattern=16'h0000A5E1;
                  dcu_emul_pattern_x4=32'hAA55EE11;
                `else
                  dcu_emul_pattern=32'hAA55EE11;
                `endif
              end
`endif
              
              if (burst_no == 0 && dcu_bst_test) begin
                cmd_burst_len = get_effective_burst_length(ccache_addr);
              end else begin
                cmd_burst_len = burst_len;
              end

              if (first_rd || !dcu_inc_dram_addr) begin
                rd_addr = addr;
              end
                
              ddr3_bl4 = ddr3_bl4fxd | bl4_otf;
              
              // the GRM expects only one read clock - send to GRM only on first
              // cycle of the burst
              if (burst_no == 0 && !ddr3_bl4_nop) begin
`ifdef DWC_USE_SHARED_AC_TB
                `GRM.read(rd_addr, cmd_burst_len, ddr3_bl4, rank%2, `SDRAM_READ);
`else
                `GRM.read(rd_addr, cmd_burst_len, ddr3_bl4, `NON_SHARED_AC, `SDRAM_READ);
`endif
              end

              if (burst_no == (cmd_burst_len-1)) begin
                burst_no = 0;
                // Increment read addr by the burst length - on a DDR3-BL4 the
                // addr is not incremented on the dummy write
                if (dcu_inc_dram_addr && !ddr3_bl4_nop) begin
                  rd_addr = rd_addr + 4*cmd_burst_len;
                end

                if (ddr3_bl4) begin
                  ddr3_bl4_nop = ~ddr3_bl4_nop;
                end
              end else begin
                burst_no = burst_no + 1;
              end

              first_rd = 0;
            end
            `TERMINATE: begin
              burst_no = 0;
            end
            default: begin
              rd_cmd = 1'b0;
              rw_cmd = 1'b0;
              // all other instructions such as activate, precharge, etc are
              // ignored because if they are executed wrongly the DRAM will
              // return wrong values
              grm_cmd = 0;
            end
          endcase // case (cmd)

          // for non-read/write commands, apply the DRAM timing parameter after each
          // command execution  
          if (!rw_cmd) begin
            dtp_eff_val = dtp_val/`PUB_CLK_NX; // correct for clock ratio;
            repeat (dtp_eff_val) @(posedge `SYS.dfi_phy_clk);
          end else begin
            // for read command, the wait clocks are in the read task
            if (!rd_cmd) @(posedge `SYS.dfi_phy_clk);
          end

          // stop on fail stops immediately, even stopping the repeat
          if (dcu_fail_stop) begin
            rpt_no = rpt_val+1; // force stop
          end

         // reset rd_cmd as get_encoded_pub_data depend on this to increment walking pattern
          rd_cmd = 1'b0;
          rw_cmd = 1'b0;
          
        end // for (rpt_no=0; rpt_no<(rpt_val+1); rpt_no=rpt_no+1)

        // loop around if necessary or execute the next sequential
        // instruction
        if ((ccache_addr === loop_end_addr) &&
            (loop_no < loop_cnt || (loop_infinite & ~dcu_stop_loop) === 1'b1)) begin
          ccache_addr = loop_start_addr;
          if (loop_no == 8'hFF)
            loop_no = 0;
          else
            loop_no = loop_no + 1;
          
          // wait for dcu to increment loop
`ifdef SDF_ANNOTATE
          wait (dcu_stop);
`elsif GATE_LEVEL_SIM
          wait (dcu_stop);
`else
          wait ((`PUB.u_DWC_ddrphy_dcu.u_dcu_cmd_drv.loop_cnt >= (loop_no-1)) ||
                (`PUB.u_DWC_ddrphy_dcu.u_dcu_cmd_drv.if_state == 
                 `PUB.u_DWC_ddrphy_dcu.u_dcu_cmd_drv.p_S_IF_IDLE));
`endif

        end else begin
          ccache_addr = ccache_addr + 1;
        end

        // for read/write commands, apply the DRAM timing parameter after all repeats
        // of command command execution and if the next command is not the same; 
        // since timing is applied at the end of the command, BL/2 clocks will already have been elapsed
        if (rw_cmd && (cmd !== get_next_dcu_command(ccache_addr))) begin
          dtp_eff_val = dtp_val - `PUB_CLK_NX*pub_burst_len - 1;
          dtp_eff_val = dtp_eff_val/`PUB_CLK_NX; // correct for clock ratio
          if (dtp_eff_val < 1) dtp_eff_val = 1;
          repeat (dtp_eff_val) @(posedge `SYS.dfi_phy_clk);
        end

        dcu_loop_cnt = loop_no;
        dcu_update_status_registers;
      end // while (ccache_addr < `CCACHE_DEPTH && !(final_stop_p1 == 1'b1))

      dcu_run  = 1'b0;
      dcu_done = 1'b1;
      dcu_stop = 1'b0;
      dcu_stop_loop = 1'b0;
      dcu_fail_stop = 0;

      dcu_update_status_registers;
    end
  endtask // run

  // get next DCU command to be executed
  function [3:0] get_next_dcu_command;
    input [31:0] ccache_addr;

    reg [`CCACHE_DATA_WIDTH-1:0] ccache_data;
    reg [`DCU_DATA_WIDTH  -1:0] dcu_data;
    reg [`DCU_BYTE_WIDTH  -1:0] dcu_mask;
    reg [`PUB_DATA_WIDTH  -1:0] data;
    reg [`PUB_DQS_WIDTH   -1:0] mask;
//    reg [`PUB_ADDR_WIDTH  -1:0] addr;
    reg [`DWC_PHY_ADDR_WIDTH  -1:0] addr;
    reg [`PUB_BANK_WIDTH  -1:0] bank;
    reg [`SDRAM_RANK_WIDTH-1:0] rank;
    reg [3                  :0] cmd;
    reg [1                  :0] tag;
    reg [`DTP_WIDTH       -1:0] dtp;
    reg [`DCU_RPT_WIDTH   -1:0] rpt;
    reg [31:0]                  rpt_val;
    
    begin
      // read the instruction
      ccache_data = ccache[ccache_addr];
      if (`DWC_NO_OF_RANKS > 1) begin
        {rpt, dtp, tag, cmd, rank, bank, addr, dcu_mask, dcu_data} = ccache_data;
      end else begin
        {rpt, dtp, tag, cmd,       bank, addr, dcu_mask, dcu_data} = ccache_data;
      end

      get_next_dcu_command = cmd;
    end
  endfunction // get_next_dcu_command

  function [3:0] get_effective_burst_length;
    input [31:0] ccache_start_addr;
    
    reg [3:0] burst_len;
    integer   acc_burst_len;
    reg       burst_end;

    integer   ccache_addr;
    reg [`CCACHE_DATA_WIDTH-1:0] ccache_data;

    reg [`DCU_DATA_WIDTH  -1:0] dcu_data;
    reg [`DCU_BYTE_WIDTH  -1:0] dcu_mask;
    reg [`PUB_DATA_WIDTH  -1:0] data;
    reg [`PUB_DQS_WIDTH   -1:0] mask;
//    reg [`PUB_ADDR_WIDTH  -1:0] addr;

    reg [`DWC_PHY_ADDR_WIDTH  -1:0] addr;
    
    reg [`PUB_BANK_WIDTH  -1:0] bank;
    reg [`SDRAM_RANK_WIDTH-1:0] rank;
    reg [3                  :0] cmd;
    reg [1                  :0] tag;
    reg [`DTP_WIDTH       -1:0] dtp;
    reg [`DCU_RPT_WIDTH   -1:0] rpt;
    reg [31:0]                  rpt_val;
    
    begin
      acc_burst_len = 0;
      burst_end     = 0;
      ccache_addr   = ccache_start_addr;
      while (!burst_end) begin
        // read the instruction
        ccache_data = ccache[ccache_addr];
        if (`DWC_NO_OF_RANKS > 1) begin
          {rpt, dtp, tag, cmd, rank, bank, addr, dcu_mask, dcu_data} = ccache_data;
        end else begin
          {rpt, dtp, tag, cmd,       bank, addr, dcu_mask, dcu_data} = ccache_data;
        end
        rpt_val = get_command_repeat(rpt);

        if (cmd == `TERMINATE || (acc_burst_len >= pub_burst_len)) begin
          burst_end = 1'b1;
        end else begin
          acc_burst_len = acc_burst_len + (rpt_val + 1);
        end

        ccache_addr = ccache_addr + 1;
      end

      get_effective_burst_length = acc_burst_len;
    end
  endfunction // get_effective_burst_length


  //function [`PUB_DATA_WIDTH-1:0] get_encoded_pub_data;
  task get_encoded_pub_data;
    input  reg [`PUB_DATA_TYPE_WIDTH-1:0] data_type;
    output reg [`PUB_DATA_WIDTH-1:0]      data;
    
    reg [7:0] d_beat [0:3];
    reg [`REG_DATA_WIDTH-1:0] lfsr;
    reg [`REG_DATA_WIDTH-1:0] lfsr_tmp;
    reg [`REG_DATA_WIDTH-1:0] tmp;
    integer idx;
    
    begin
      
      case (data_type)
        `PUB_DATA_0000_0000   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0000_0000;
        `PUB_DATA_FFFF_FFFF   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hFFFF_FFFF;
        `PUB_DATA_5555_5555   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h5555_5555;
        `PUB_DATA_AAAA_AAAA   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hAAAA_AAAA;
        `PUB_DATA_0000_5500   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0000_5500;
        `PUB_DATA_5555_0055   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h5555_0055;
        `PUB_DATA_0000_AA00   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0000_AA00;
        `PUB_DATA_AAAA_00AA   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hAAAA_00AA;
        `PUB_DATA_DTDR0       : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = dtdr0;
        `PUB_DATA_DTDR1       : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = dtdr1;
        `PUB_DATA_UDDR0       : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = uddr0;
        `PUB_DATA_UDDR1       : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = uddr1;

        `PUB_DATA_WALKING_1   : begin
                                  // READ command
                                  if (rd_cmd) begin
                                    {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = {{walking_1_read[2:0], walking_1_read[7:3]}, 
                                                                                    {walking_1_read[6:0], walking_1_read[7]  },
                                                                                    {walking_1_read[3:0], walking_1_read[7:4]},
                                                                                    {walking_1_read                     }};
                                    walking_1_read = {walking_1_read[5:0], walking_1_read[7:6]};
                                  end else begin // WRITE command
                                    {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = {{walking_1_write[2:0], walking_1_write[7:3]}, 
                                                                                    {walking_1_write[6:0], walking_1_write[7]  },
                                                                                    {walking_1_write[3:0], walking_1_write[7:4]},
                                                                                    {walking_1_write                     }};
                                    walking_1_write = {walking_1_write[5:0], walking_1_write[7:6]};
                                  end
                                end

        `PUB_DATA_WALKING_0   : begin
                                  // READ command
                                  if (rd_cmd) begin
                                    {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = {{walking_0_read[2:0], walking_0_read[7:3]}, 
                                                                                    {walking_0_read[6:0], walking_0_read[7]  },
                                                                                    {walking_0_read[3:0], walking_0_read[7:4]},
                                                                                    {walking_0_read                     }};
                                     walking_0_read = {walking_0_read[5:0], walking_0_read[7:6]};
                                  end else begin // WRITE command
                                    {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = {{walking_0_write[2:0], walking_0_write[7:3]}, 
                                                                                    {walking_0_write[6:0], walking_0_write[7]  },
                                                                                    {walking_0_write[3:0], walking_0_write[7:4]},
                                                                                    {walking_0_write                     }};
                                     walking_0_write = {walking_0_write[5:0], walking_0_write[7:6]};
                                  end
                                end

        `PUB_DATA_USER_PATTERN: begin
                                  // READ command
                                  if (rd_cmd) begin
                                    {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = {{4{i_user_pat_odd_read[(pos_read+3)%16], i_user_pat_even_read[(pos_read+3)%16]}},
                                                                                    {4{i_user_pat_odd_read[(pos_read+2)%16], i_user_pat_even_read[(pos_read+2)%16]}},
                                                                                    {4{i_user_pat_odd_read[(pos_read+1)%16], i_user_pat_even_read[(pos_read+1)%16]}},
                                                                                    {4{i_user_pat_odd_read[(pos_read+0)%16], i_user_pat_even_read[(pos_read+0)%16]}}};
                                     pos_read = pos_read + 4;
                                  end else begin // WRITE command
                                    {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = {{4{i_user_pat_odd_write[(pos_write+3)%16], i_user_pat_even_write[(pos_write+3)%16]}},
                                                                                    {4{i_user_pat_odd_write[(pos_write+2)%16], i_user_pat_even_write[(pos_write+2)%16]}},
                                                                                    {4{i_user_pat_odd_write[(pos_write+1)%16], i_user_pat_even_write[(pos_write+1)%16]}},
                                                                                    {4{i_user_pat_odd_write[(pos_write+0)%16], i_user_pat_even_write[(pos_write+0)%16]}}};
                                     pos_write = pos_write + 4;
                                  end  
                                end
        
        `PUB_DATA_LFSR        : begin

                                  // load a random seed into bistlsr when first time access
                                  // this will be the first lfsr pattern
                                  if (first_access_lfsr_write) begin
                                    lfsr           = `GRM.bistlsr;
                                    lfsr_reg_write = `GRM.bistlsr;
                                    first_access_lfsr_write= 1'b0;
                                  end
                                  else begin
                                    if (first_access_lfsr_read && rd_cmd) begin
                                      lfsr           = `GRM.bistlsr;
                                      lfsr_reg_read  = `GRM.bistlsr;
                                      first_access_lfsr_read = 1'b0;
                                    end
                                    else begin
                                      if (rd_cmd) begin
                                        -> e_get_encoded_lfsr_data_read;
                                        get_lfsr(lfsr_reg_read, lfsr);
                                        lfsr_reg_read  = lfsr;
                                      end else begin  
                                        -> e_get_encoded_lfsr_data_write;
                                        get_lfsr(lfsr_reg_write, lfsr);
                                        lfsr_reg_write = lfsr;
                                      end
                                    end
                                  end  
                                  {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = lfsr;
                                end
        `PUB_DATA_SCHCR0      : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0000_0000; // dummy - data is unique per byte
        `PUB_DATA_FF00_FF00   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hFF00_FF00;
        `PUB_DATA_FFFF_0000   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hFFFF_0000;
        `PUB_DATA_0000_FF00   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0000_FF00;
        `PUB_DATA_FFFF_00FF   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hFFFF_00FF;
        `PUB_DATA_00FF_00FF   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h00FF_00FF;
        `PUB_DATA_F0F0_F0F0   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'hF0F0_F0F0;
        `PUB_DATA_0F0F_0F0F   : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0F0F_0F0F;
`ifdef DWC_DDRPHY_EMUL_XILINX
  `ifdef DWC_DDRPHY_X4MODE
        `PUB_DATA_AA55EE11    : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = dcu_emul_pattern_x4;
  `else
        `PUB_DATA_AA55EE11    : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = dcu_emul_pattern;
  `endif
`endif

        default               : {d_beat[3], d_beat[2], d_beat[1], d_beat[0]} = 32'h0000_0000;
      endcase // case (i_data_gen_type)
      
`ifdef DWC_DDRPHY_EMUL_XILINX
      if(`GRM.bl==4)begin
        if(`GRM.run.cmd==`SDRAM_READ) begin
          dcu_emul_pattern =  dcu_emul_pattern+1;
        end else begin
          if(data_type == `PUB_DATA_AA55EE11)begin
            wr_cnt = wr_cnt+1;
            if(wr_cnt==2)begin
              wr_cnt = 0 ;
            end else begin
              if(wr_cnt==1)begin
                dcu_emul_pattern =  dcu_emul_pattern+1;
              end
            end
          end
        end
      end else begin
        if(data_type == `PUB_DATA_AA55EE11)begin
          dcu_emul_pattern =  dcu_emul_pattern+1;
        end
      end
      dcu_emul_pattern_x4 = {{2{dcu_emul_pattern[15:12]}},{2{dcu_emul_pattern[11:8]}},{2{dcu_emul_pattern[7:4]}},{2{dcu_emul_pattern[3:0]}}};
`endif
      
      data = {{`DWC_NO_OF_BYTES{d_beat[3]}},   // Data beat 3 for all bytes
              {`DWC_NO_OF_BYTES{d_beat[2]}},   // Data beat 2 for all bytes
              {`DWC_NO_OF_BYTES{d_beat[1]}},   // Data beat 1 for all bytes
              {`DWC_NO_OF_BYTES{d_beat[0]}}};  // Data beat 0 for all bytes
    end
  endtask // get_encoded_pub_data


  assign i_user_pat_odd_write [15:0]  = bistudpr[31:16];
  assign i_user_pat_even_write[15:0]  = bistudpr[15: 0];
  assign i_user_pat_odd_read  [15:0]  = bistudpr[31:16];
  assign i_user_pat_even_read [15:0]  = bistudpr[15: 0];

  task get_lfsr;
    input  reg [`REG_DATA_WIDTH-1:0] lfsr_reg;
    output reg [`REG_DATA_WIDTH-1:0] lfsr;
    reg        [`REG_DATA_WIDTH-1:0] lfsr_tmp;
    reg                              feedback;
    
    integer idx;
    
    begin
      lfsr_tmp = lfsr_reg;
      feedback = (^(lfsr_reg[`REG_DATA_WIDTH-1:1] & pLFSR_POLY[`REG_DATA_WIDTH-1:1])) ^ lfsr_reg[0];
      
      for (idx = 0; idx < `REG_DATA_WIDTH; idx = idx + 1) begin
        if (idx == (`REG_DATA_WIDTH - 1)) lfsr_reg[`REG_DATA_WIDTH - 1]  = feedback;
        else                              lfsr_reg[idx]                  = lfsr_tmp[idx + 1];
      end
      lfsr         = lfsr_reg;
      
    end
  endtask // get_lfsr
  

  // resets the status at the beginning of the run
  task dcu_reset_run_status;
    begin
      dcu_done     = 0;
      dcu_cap_fail = 0;
      dcu_cap_full = 0;
      dcu_read_cnt = 0;
      dcu_fail_cnt = 0;
      dcu_loop_cnt = 0;
      read_cnt     = 0;
    end
  endtask // dcu_reset_run_status
      

  // updates the two DCU status registers
  task dcu_update_status_registers;
    begin
      // DCUSR0
      dcusr0[0]     = dcu_done;
      dcusr0[1]     = dcu_cap_fail;
      dcusr0[2]     = dcu_cap_full;

      // DCUSR1
      dcusr1[15:0]  = dcu_read_cnt;
      dcusr1[23:16] = dcu_fail_cnt;
      dcusr1[31:24] = dcu_loop_cnt;
    end
  endtask // dcu_update_status_registers

  
  // DCU cache accesses
  // ------------------
  // configuration write to the caches
  task write_dcu_cache;
    input [`CFG_DATA_WIDTH-1:0] data;
    reg   [512-1:0] cache_word;
    integer i;
    integer cache_msb;
    integer slice_start_bit;
    integer slice_end_bit;
    begin
     slice_start_bit = `CFG_DATA_WIDTH*cache_slice_addr;
     slice_end_bit   = `CFG_DATA_WIDTH+slice_start_bit;

      // read the slice data from the cache
      case (cache_sel)
        `DCU_CCACHE: begin
          cache_word = ccache[cache_word_addr];
          if (slice_end_bit >= `CCACHE_DATA_WIDTH) begin
            slice_end_bit = `CCACHE_DATA_WIDTH - 1;
          end
        end
        `DCU_ECACHE: begin
          cache_word = ecache[cache_word_addr];
          if (slice_end_bit >= `ECACHE_DATA_WIDTH) begin
            slice_end_bit = `ECACHE_DATA_WIDTH - 1;
          end
        end
        `DCU_RCACHE: begin
          cache_word = rcache[cache_word_addr];
          if (slice_end_bit >= `RCACHE_DATA_WIDTH) begin
            slice_end_bit = `RCACHE_DATA_WIDTH - 1;
          end
        end
        default: begin
          cache_word = ccache[cache_word_addr];
          end
      endcase // case (cache_sel)

      // modify the slice data
      for (i=slice_start_bit; i<=slice_end_bit; i=i+1) begin
        cache_word[i] = data[i-slice_start_bit];
      end

      // write the slice data to the cache
      case (cache_sel)
        `DCU_CCACHE: ccache[cache_word_addr] = cache_word[`CCACHE_DATA_WIDTH-1:0];
        `DCU_ECACHE: ecache[cache_word_addr] = cache_word[`ECACHE_DATA_WIDTH-1:0];
        `DCU_RCACHE: rcache[cache_word_addr] = cache_word[`RCACHE_DATA_WIDTH-1:0];
      endcase // case (cache_sel)
    end
  endtask // write_dcu_cache

  // configuration read from cache
  task read_dcu_cache;
    output [`CFG_DATA_WIDTH-1:0] data;
    reg    [512-1:0] cache_word;
    integer i;
    integer cache_msb;
    integer slice_start_bit;
    integer slice_end_bit;
    begin
     slice_start_bit = `CFG_DATA_WIDTH*cache_slice_addr_r;
     slice_end_bit   = `CFG_DATA_WIDTH+slice_start_bit;

      // read the slice data from the cache
      cache_word = {512{1'b0}};
      case (cache_sel)
        `DCU_CCACHE: begin
          cache_word = ccache[cache_word_addr_r];
          if (slice_end_bit >= `CCACHE_DATA_WIDTH) begin
            slice_end_bit = `CCACHE_DATA_WIDTH - 1;
          end
        end
        `DCU_ECACHE: begin
          cache_word = ecache[cache_word_addr_r];
          if (slice_end_bit >= `ECACHE_DATA_WIDTH) begin
            slice_end_bit = `ECACHE_DATA_WIDTH - 1;
          end
        end
        `DCU_RCACHE: begin
          cache_word = rcache[cache_word_addr_r];
          if (slice_end_bit >= `RCACHE_DATA_WIDTH) begin
            slice_end_bit = `RCACHE_DATA_WIDTH - 1;
          end
        end
        default: begin
          cache_word = ccache[cache_word_addr_r];
          end
      endcase // case (cache_sel)

      // extract configuration data from the slice data
      data = {`CFG_DATA_WIDTH{1'b0}};
      for (i=slice_start_bit; i<=slice_end_bit; i=i+1) begin
        data[i-slice_start_bit] = cache_word[i];
      end
    end
  endtask // read_dcu_cache

  // captures read data into the read cache and optionally
  // compares with expected data
  task dcu_capture_read_data;
    input [`PUB_DATA_WIDTH-1:0] read_data;
    reg [`PUB_DATA_WIDTH-1:0] xpctd_data;
    reg [`PUB_DATA_WIDTH-1:0] xpctd_data_i;
    reg prev_dcu_cap_full;
    reg prev_dcu_fail_stop;
    integer idx_beat;
    integer idx_byte;
    integer idx_dq;
    reg [`PUB_DATA_TYPE_WIDTH -1:0] xpctd_data_type;
    
    begin
      prev_dcu_cap_full  = dcu_cap_full;
      prev_dcu_fail_stop = dcu_fail_stop;
      
      if (dcu_read_cap_en && !(dcu_stop_cap_on_full && dcu_cap_full) && !dcu_fail_stop) begin
        // capture and count the read data
        if (read_cnt >= dcu_cap_start_word) begin
          rcache[(read_cnt - dcu_cap_start_word)%`RCACHE_DEPTH][0*8 +: 8] = read_data[0*8*`DWC_NO_OF_BYTES + cmpr_byte_sel*8 +: 8];
          rcache[(read_cnt - dcu_cap_start_word)%`RCACHE_DEPTH][1*8 +: 8] = read_data[1*8*`DWC_NO_OF_BYTES + cmpr_byte_sel*8 +: 8];
          rcache[(read_cnt - dcu_cap_start_word)%`RCACHE_DEPTH][2*8 +: 8] = read_data[2*8*`DWC_NO_OF_BYTES + cmpr_byte_sel*8 +: 8];
          rcache[(read_cnt - dcu_cap_start_word)%`RCACHE_DEPTH][3*8 +: 8] = read_data[3*8*`DWC_NO_OF_BYTES + cmpr_byte_sel*8 +: 8];

          // check if capture cache is full and increment address
          if ((read_cnt - dcu_cap_start_word >= (`RCACHE_DEPTH-1)) && !dcu_cap_full) begin
            dcu_cap_full = 1;
          end
        end

        ctl_rcache_addr = (ctl_rcache_addr + 1) % `RCACHE_DEPTH;

      end

        xpctd_data_type = ecache[0][ctl_ecache_addr*`PUB_DATA_TYPE_WIDTH +: `PUB_DATA_TYPE_WIDTH];
          //xpctd_data      = get_encoded_pub_data(xpctd_data_type);
        get_encoded_pub_data(xpctd_data_type,xpctd_data);

        // The most significant bytes may have some of its DQs not used - for the the
        // read data comes back as zeros
        for (idx_beat=0; idx_beat<4; idx_beat=idx_beat+1) begin
          for (idx_byte=0; idx_byte<`DWC_NO_OF_BYTES; idx_byte=idx_byte+1) begin
            if (idx_byte == (`DWC_NO_OF_BYTES-1)) begin
              for (idx_dq=0; idx_dq<8; idx_dq=idx_dq+1) begin
                if (idx_dq >= (8-msbyte_udq)) begin
                  xpctd_data[idx_beat*`DWC_NO_OF_BYTES*8 + idx_byte*8 + idx_dq] = 1'b0;
                end
              end
            end
          end
        end

      // optionally compare the read data
      if ((dcu_compare_en) && (read_cnt >= dcu_cap_start_word) && !dcu_fail_stop && 
          !(dcu_stop_cap_on_full && dcu_cap_full)) begin  
      
        if (read_data !== xpctd_data) begin
          if (dcu_fail_cnt < {`DCU_FAIL_CNT_WIDTH{1'b1}}) begin
            dcu_fail_cnt = dcu_fail_cnt + 1;
          end
          dcu_cap_fail = 1;
        end

        // stop execution on nth fail if configured so
        if (dcu_stop_on_nfail && (dcu_fail_cnt == (dcu_stop_fail_cnt+1))) begin
          dcu_fail_stop = 1;
        end
      end

      if (!prev_dcu_fail_stop) begin
        read_cnt = read_cnt + 1;
        if (read_cnt <= {`DCU_READ_CNT_WIDTH{1'b1}})
          dcu_read_cnt = read_cnt;
        else  
          dcu_read_cnt = {`DCU_READ_CNT_WIDTH{1'b1}};
      end
    end

         // increment the expected data address
        ctl_ecache_addr = (ctl_ecache_addr == xpctd_loop_end_addr) ?
                          0 : ctl_ecache_addr + 1;

    
  endtask // dcu_capture_read_data
            
      
  // returns the maximum word and slice addressess of the caches
  task dcu_maximum_addresses;
    input  [1:0] cache_sel;
    output [`CACHE_ADDR_WIDTH-1:0] max_word_addr;
    output [3                  :0] max_slice_addr;
    begin
      case (cache_sel)
        `DCU_CCACHE: begin
          max_word_addr  = `CCACHE_DEPTH  - 1;
          max_slice_addr = `CCACHE_SLICES - 1;
        end                
       `DCU_ECACHE : begin     
          max_word_addr  = `ECACHE_DEPTH  - 1;
          max_slice_addr = `ECACHE_SLICES - 1;
        end
        `DCU_RCACHE: begin       
          max_word_addr  = `RCACHE_DEPTH  - 1;
          max_slice_addr = `RCACHE_SLICES - 1;
        end                
      endcase // case (cache_csel)
    end
  endtask // dcu_maximum_addresses

  
  // automatically increments the cache address when the DCUDR register is accessed
  task auto_increment_cache_address;
    reg [`CACHE_ADDR_WIDTH-1:0] cache_max_word_addr;
    reg [3                  :0] cache_max_slice_addr;
    begin
      if (cache_inc_addr) begin
        dcu_maximum_addresses (cache_sel, cache_max_word_addr, cache_max_slice_addr);
      
        if (dcuar[7:4] == cache_max_slice_addr) begin
          dcuar[7:4] = 0;
      
          if (dcuar[3:0] == cache_max_word_addr) begin
            dcuar[3:0] = 0;
          end else begin
            dcuar[3:0] = dcuar[3:0] + 1;
          end
        end else begin
          dcuar[7:4] = dcuar[7:4] + 1;
        end
      end
    end
  endtask // auto_increment_cache_address

  // automatically increments the cache address when the DCUDR register is accessed
  task auto_increment_cache_address_read;
    reg [`CACHE_ADDR_WIDTH-1:0] cache_max_word_addr;
    reg [3                  :0] cache_max_slice_addr;
    begin
      if (cache_inc_addr) begin
        dcu_maximum_addresses (cache_sel, cache_max_word_addr, cache_max_slice_addr);
      
        if (dcuar[19:16] == cache_max_slice_addr) begin
          dcuar[19:16] = 0;
      
          if (dcuar[15:12] == cache_max_word_addr) begin
            dcuar[15:12] = 0;
          end else begin
            dcuar[15:12] = dcuar[15:12] + 1;
          end
        end else begin
          dcuar[19:16] = dcuar[19:16] + 1;
        end
      end
    end
  endtask // auto_increment_cache_address_read

  // get DRAM timing parameter value
  function [31:0] get_dram_timing_parameter;
    input [`DCU_DTP_WIDTH-1:0] dtp;
    begin
      case (dtp)
        `DTP_tNODTP      : get_dram_timing_parameter = 1;
        `DTP_tRP         : get_dram_timing_parameter = t_rp;
        `DTP_tRAS        : get_dram_timing_parameter = t_ras;
        `DTP_tRRD        : get_dram_timing_parameter = t_rrd;
        `DTP_tRC         : get_dram_timing_parameter = t_rc;
        `DTP_tMRD        : get_dram_timing_parameter = t_mrd;
        `DTP_tMOD        : get_dram_timing_parameter = t_mod;
        `DTP_tFAW        : get_dram_timing_parameter = t_faw;
        `DTP_tRFC        : get_dram_timing_parameter = t_rfc;
        `DTP_tWLMRD      : get_dram_timing_parameter = t_wlmrd;
        `DTP_tWLO        : get_dram_timing_parameter = t_wlo;
        `DTP_tXS         : get_dram_timing_parameter = t_xs;
        `DTP_tXP         : get_dram_timing_parameter = t_xp;
        `DTP_tCKE        : get_dram_timing_parameter = t_cke;
        `DTP_tDLLK       : get_dram_timing_parameter = t_dllk;
        `DTP_tDINITRST   : get_dram_timing_parameter = tdinitrst;
        `DTP_tDINITCKELO : get_dram_timing_parameter = tdinitckelo;
        `DTP_tDINITCKEHI : get_dram_timing_parameter = tdinitckehi;
        `DTP_tDINITZQ    : get_dram_timing_parameter = tdinitzq;
        `DTP_tRPA        : get_dram_timing_parameter = t_rpa;
        `DTP_tPRE2ACT    : get_dram_timing_parameter = t_pre2act;
        `DTP_tACT2RW     : get_dram_timing_parameter = t_act2rw;
        `DTP_tRD2PRE     : get_dram_timing_parameter = t_rd2pre;
        `DTP_tWR2PRE     : get_dram_timing_parameter = t_wr2pre;
        `DTP_tRD2WR      : get_dram_timing_parameter = t_rd2wr;
        `DTP_tWR2RD      : get_dram_timing_parameter = t_wr2rd;
        `DTP_tRDAP2ACT   : get_dram_timing_parameter = t_rdap2act;
        `DTP_tWRAP2ACT   : get_dram_timing_parameter = t_wrap2act;
        `DTP_tDCUT0      : get_dram_timing_parameter = t_dcut0;
        `DTP_tDCUT1      : get_dram_timing_parameter = t_dcut1;
        `DTP_tDCUT2      : get_dram_timing_parameter = t_dcut2;
        `DTP_tDCUT3      : get_dram_timing_parameter = t_ccd_l;
        default:           get_dram_timing_parameter = 1;
      endcase
    end
  endfunction // get_dram_timing_parameter

  // get command repeat value
  function [31:0] get_command_repeat;
    input [`DCU_RPT_WIDTH-1:0] rpt;
    begin
      case (rpt)
        `DCU_NORPT  : get_command_repeat = 0;
        `DCU_RPT1X  : get_command_repeat = 1;
        `DCU_RPT4X  : get_command_repeat = 3;
        `DCU_RPT7X  : get_command_repeat = 7;
        `DCU_tBL    : get_command_repeat = pdr_burst_len;
        `DCU_tDCUT0 : get_command_repeat = t_dcut0;
        `DCU_tDCUT1 : get_command_repeat = t_dcut1;
        `DCU_tDCUT2 : get_command_repeat = t_dcut2;
        default     : get_command_repeat = 0;
      endcase
    end
  endfunction // get_command_repeat
  
  // returns size parameters for the caches
  task get_cache_parameters;
    input  [1                  :0] cache_sel;
    output [4                  :0] cache_depth;
    output [8                  :0] cache_width;
    output [3                  :0] cache_slices;
    begin
      case (cache_sel)
        `DCU_CCACHE: begin
          cache_depth  = `CCACHE_DEPTH;
          cache_width  = `CCACHE_DATA_WIDTH;
          cache_slices = `CCACHE_SLICES;
        end                
       `DCU_ECACHE : begin     
          cache_depth  = `ECACHE_DEPTH;
          cache_width  = `ECACHE_DATA_WIDTH;
          cache_slices = `ECACHE_SLICES;
        end
        `DCU_RCACHE: begin       
          cache_depth  = `RCACHE_DEPTH;
          cache_width  = `RCACHE_DATA_WIDTH;
          cache_slices = `RCACHE_SLICES;
        end                
      endcase // case (cache_csel)
    end
  endtask // get_cache_parameters
      
    
  // print GRM DCU caches
  task report_dcu_caches;
    integer cache_sel;
    integer cache_depth;
    integer i;
    begin
      for (cache_sel=`DCU_CCACHE; cache_sel<=`DCU_RCACHE; cache_sel=cache_sel+1) begin
        case (cache_sel)
          `DCU_CCACHE: cache_depth = `CCACHE_DEPTH;
          `DCU_ECACHE: cache_depth = `ECACHE_DEPTH;
          `DCU_RCACHE: cache_depth = `RCACHE_DEPTH;
        endcase // case (cache_sel)
  
        $display("");
        for (i=0; i<cache_depth; i=i+1) begin
          case (cache_sel)
            `DCU_CCACHE: $display("CCACHE[%0d] = %h", i, ccache[i]);
            `DCU_ECACHE: $display("ECACHE[%0d] = %h", i, ecache[i]);
            `DCU_RCACHE: $display("RCACHE[%0d] = %h", i, rcache[i]);
          endcase // case (cache_sel)
        end
      end
    end
  endtask // report_dcu_caches

endmodule // ddr_grm
