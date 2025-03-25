/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys. All rights reserved.                          *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Dictionary for DDR PHY                                        *
 *                                                                            *
 *****************************************************************************/

// defines configuration for the PHY
`define DWC_DDRPHY_GEN3                // PUB type is GEN3

`ifdef DWC_DDRPHY_TB_OVERRIDE
  `ifdef DWC_DDRPHY_EMUL_XILINX		   // Emulation
     `include "emul_dictionary.v"
  `endif
`endif

// Timescale
// ---------
`timescale 1ns/1ps


// Timing Parameters
// -----------------
 `define CLK_PRD_DDR4_1600J 1.250
 `define CLK_PRD_DDR4_1866L 1.072
 `define CLK_PRD_DDR4_2133N 0.938
 `define CLK_PRD_DDR4_2400  0.833
 `define CLK_PRD_DDR4_2666  0.75
 `define ddr2_tRFC_tolerance 10
 `define ddr3_tRFC_tolerance 10
 `define ddr4_tRFC_tolerance 10
 `define lpddr2_tRFC_tolerance 10
 `define lpddr3_tRFC_tolerance 10
  
  // clock period based on speed grade
  `ifdef DDR3_2133K 
    `define CLK_PRD 0.94  // JEDEC DDR3 ...
  `else 
    `ifdef DDR3_1866J 
      `define CLK_PRD 1.07
  `else 
    `ifdef DDR3_1600G 
      `define CLK_PRD 1.3
  `else 
        `ifdef DDR3_1333F 
        `define CLK_PRD 1.5
  `else 
        `ifdef DDR3_1066E 
          `ifdef DWC_DDRPHY_EMUL_XILINX                   
            `define CLK_PRD 1.876 //  Emulation; Friendly for PLL
          `else
            `define CLK_PRD 1.875
          `endif 
  `else 
        `ifdef DDR3_800D  
        `define CLK_PRD 2.5
  `else 
        `ifdef DDR3_667C  
        `define CLK_PRD 3.0    // just dummy speed grade
  `else 
        `ifdef DDR3_DBYP  
        `define CLK_PRD 8.0        // SDRAM DLL byp
  `else 
        `ifdef DDR2_1066E 
          `ifdef DWC_DDRPHY_EMUL_XILINX                  
            `define CLK_PRD 1.876  //  Emulation; Friendly for PLL
          `else
            `define CLK_PRD 1.875  // JEDEC DDR2 ...
          `endif
  `else 
        `ifdef DDR2_800D   
        `define CLK_PRD 2.5
  `else 
        `ifdef DDR2_800E   
        `define CLK_PRD 2.5
  `else 
        `ifdef DDR2_667C   
        `define CLK_PRD 3.0
  `else 
        `ifdef DDR2_533C   
        `define CLK_PRD 3.75
  `else 
        `ifdef DDR2_400B   
        `define CLK_PRD 5.0
  `else 
        `ifdef GDDR2_1000  
        `define CLK_PRD 2.0    // custom gDDR2
  `else 
        `ifdef LPDDR2_1066 
        `define CLK_PRD 2  // JEDEC LPDDR2 ...
  `else 
        `ifdef LPDDR2_933  
        `define CLK_PRD 2.15
  `else 
        `ifdef LPDDR2_800  
        `define CLK_PRD 2.5
  `else 
        `ifdef LPDDR2_667  
        `define CLK_PRD 3.0
  `else 
        `ifdef LPDDR2_533  
        `define CLK_PRD 3.75
  `else 
        `ifdef LPDDR2_400  
        `define CLK_PRD 5.0
  `else 
        `ifdef LPDDR2_250  
        `define CLK_PRD 8.0
  `else 
        `ifdef LPDDR3_2133 
        `define CLK_PRD 0.95  // JEDEC LPDDR3 ...
  `else 
        `ifdef LPDDR3_1866 
        `define CLK_PRD 1.072  // JEDEC LPDDR3 ...
  `else 
        `ifdef LPDDR3_1600 
        `define CLK_PRD 1.28  // JEDEC LPDDR3 ...
  `else 
        `ifdef LPDDR3_1466 
        `define CLK_PRD 1.365  // JEDEC LPDDR3 ...
  `else 
        `ifdef LPDDR3_1333  
        `define CLK_PRD 1.5
  `else 
        `ifdef LPDDR3_1200  
        `define CLK_PRD 1.67
  `else 
        `ifdef LPDDR3_1066  
        `define CLK_PRD 1.875
  `else 
        `ifdef LPDDR3_800  
        `define CLK_PRD 2.5
  `else 
        `ifdef LPDDR3_667  
        `define CLK_PRD 3.0
  `else 
        `ifdef LPDDR3_333  
        `define CLK_PRD 6.0
  `else 
        `ifdef LPDDR3_250 
        `define CLK_PRD 8.0
  
   // DDR4 
  `else 
   `ifdef DWC_RDBI_DDR4
     // RDBI clock period
     `ifdef DDR4_1600J
       `define CLK_PRD `CLK_PRD_DDR4_1600J
       `define CAL_DDR_PRD     8'h7E
       `ifdef CL_11   
         `define DDR4_1500_Timing
         `define CLK_PRD 1.51
         `define CAL_DDR_PRD     8'h97
       `elsif CL_12
         `ifdef CWL_9
           `define DDR4_1500_Timing
           `define CLK_PRD 1.51
           `define CAL_DDR_PRD     8'h97
         `elsif CWL_11
           `define DDR4_1250_Timing
           `define CLK_PRD 1.26    
           `define CAL_DDR_PRD     8'h7E
         `endif
       `elsif CL_13    
         `define DDR4_1250_Timing
         `define CLK_PRD 1.26
         `define CAL_DDR_PRD     8'h7E
       `elsif CL_14  
         `define DDR4_1250_Timing
         `define CLK_PRD 1.26
         `define CAL_DDR_PRD     8'h7E
       `else
         `define DDR4_1250_Timing
       `endif
     `else 
     `ifdef DDR4_1866L   
       `define CLK_PRD `CLK_PRD_DDR4_1866L
       `define CAL_DDR_PRD     8'h6B
       `ifdef CL_11 
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_12
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_14 
         `ifdef CWL_9
           `define DDR4_1250_Timing
           `define CLK_PRD 1.25     
           `define CAL_DDR_PRD     8'h7D	 
         `elsif CWL_11
           `define DDR4_1250_Timing
           `define CLK_PRD 1.25     
           `define CAL_DDR_PRD     8'h7D   
         `elsif CWL_10
           `define DDR4_1072_Timing
           `define CLK_PRD 1.072
           `define CAL_DDR_PRD     8'h6B
         `elsif CWL_12
           `define DDR4_1072_Timing
           `define CLK_PRD 1.08
           `define CAL_DDR_PRD     8'h6C
         `endif 	    
       `elsif CL_15 
         `define DDR4_1072_Timing
         `define CLK_PRD 1.072    
         `define CAL_DDR_PRD     8'h6B 	    
       `elsif CL_16 
         `define DDR4_1072_Timing
         `define CLK_PRD 1.072    
         `define CAL_DDR_PRD     8'h6B		
       `else
         `define DDR4_1072_Timing
       `endif
     `else 
     `ifdef DDR4_2133N   
       `define CLK_PRD `CLK_PRD_DDR4_2133N
       `define CAL_DDR_PRD     8'h5E
       `ifdef CL_11
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_12
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_14
         `define DDR4_1250_Timing
         `define CLK_PRD 1.26
         `define CAL_DDR_PRD     8'h7E	    
       `elsif CL_16 
         `ifdef CWL_10
           `define DDR4_1072_Timing
           `define CLK_PRD 1.072    
           `define CAL_DDR_PRD     8'h6B	      
         `elsif CWL_12 
           `define DDR4_1072_Timing
           `define CLK_PRD 1.072    
           `define CAL_DDR_PRD     8'h6B	      
         //`elsif CWL_11
         //  `define DDR4_938_Timing
         //  `define CLK_PRD 0.94
         //  `define CAL_DDR_PRD     8'h5E	      
         //`elsif CWL_14
         //  `define DDR4_938_Timing
         //  `define CLK_PRD 0.94
         //  `define CAL_DDR_PRD     8'h5E	      
         `endif 	    
       `elsif CL_17 
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E 	    
       `elsif CL_18 
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E        	    
       `elsif CL_19 
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E        	    
       `endif
     `else 
     `ifdef DDR4_2400   
       `define CLK_PRD `CLK_PRD_DDR4_2400
       `define CAL_DDR_PRD     8'h54
       `ifdef CL_11
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_12
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_14 
         `define DDR4_1250_Timing
         `define CLK_PRD 1.25
         `define CAL_DDR_PRD     8'h7D	    
       `elsif CL_16
         `define DDR4_1072_Timing
         `define CLK_PRD 1.072
         `define CAL_DDR_PRD     8'h6B	        
       `elsif CL_18
         `define DDR4_833_Timing
         `define CLK_PRD 0.84
         `define CAL_DDR_PRD     8'h54	        
       `elsif CL_19 
         `ifdef CWL_11
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E	      
         `elsif CWL_14
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E	        
         `else
           `define DDR4_833_Timing
           `define CLK_PRD 0.84
           `define CAL_DDR_PRD     8'h54	      
         `endif
       `elsif CL_21 
         `ifdef CWL_12
           `define DDR4_833_Timing
           `define CLK_PRD 0.84
           `define CAL_DDR_PRD     8'h54	        
         `else
           `define DDR4_833_Timing
           `define CLK_PRD 0.84
           `define CAL_DDR_PRD     8'h54	      
         `endif
       `endif // !`elsif CL_16
     `else 
        `ifdef DDR4_2666   
            `define CLK_PRD `CLK_PRD_DDR4_2666
            `define CAL_DDR_PRD     8'h4C
            `ifdef CL_11
              `define DDR4_1500_Timing
              `define CLK_PRD 1.50
              `define CAL_DDR_PRD     8'h96
            `elsif CL_12
              `define DDR4_1500_Timing
              `define CLK_PRD 1.50
              `define CAL_DDR_PRD     8'h96
            `elsif CL_13
              `ifdef CWL_9
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `elsif CWL_11
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `endif
            `elsif CL_14
              `ifdef CWL_9
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `elsif CWL_10
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `elsif CWL_11
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `elsif CWL_12
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `endif
            `elsif CL_15
              `ifdef CWL_10
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `elsif CWL_12
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `endif
            `elsif CL_16
              `ifdef CWL_10
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              //`elsif CWL_11
              //  `define DDR4_938_Timing
              //  `define CLK_PRD 0.94
              //  `define CAL_DDR_PRD     8'h5E
              `elsif CWL_12
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              //`elsif CWL_14
              //  `define DDR4_938_Timing
              //  `define CLK_PRD 0.94
              //  `define CAL_DDR_PRD     8'h5E
              `endif
            `elsif CL_17
              `ifdef CWL_11
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              //`elsif CWL_12
              //  `define DDR4_833_Timing
              //  `define CLK_PRD 0.84
              //  `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              //`elsif CWL_16
              //  `define DDR4_833_Timing
              //  `define CLK_PRD 0.84
              //  `define CAL_DDR_PRD     8'h54
              `endif
            `elsif CL_18
              `ifdef CWL_11
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `endif
            `elsif CL_19
              `ifdef CWL_11
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `endif
             `elsif CL_20
              `ifdef CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `elsif CL_21
              `ifdef CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `elsif CL_22
              `ifdef CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `elsif CL_23
              `ifdef CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `else
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `else
              `define DDR4_750_Timing
            `endif // !`elsif CL_23
     `else 
      `ifdef DDR4_DBYP   
           `define CLK_PRD 8
           //`define CAL_DDR_PRD     8'h2A
           `define CAL_DDR_PRD     8'hff
      `endif 
    `endif `endif `endif `endif `endif            
                
   `else  // !ifdef DWC_RDBI_DDR4 
     `ifdef DDR4_1600J
       `define CLK_PRD `CLK_PRD_DDR4_1600J
       `define CAL_DDR_PRD     8'h7E
       `ifdef CL_9   
         `define DDR4_1500_Timing
         `define CLK_PRD 1.51
         `define CAL_DDR_PRD     8'h97
       `elsif CL_10
         `ifdef CWL_9
           `define DDR4_1500_Timing
           `define CLK_PRD 1.51
           `define CAL_DDR_PRD     8'h97
         `elsif CWL_11
           `define DDR4_1250_Timing
           `define CLK_PRD 1.26    
           `define CAL_DDR_PRD     8'h7E
         `endif
       `elsif CL_11    
         `define DDR4_1250_Timing
         `define CLK_PRD 1.26
         `define CAL_DDR_PRD     8'h7E
       `elsif CL_12  
         `define DDR4_1250_Timing
         `define CLK_PRD 1.26
         `define CAL_DDR_PRD     8'h7E
       `else
         `define DDR4_1250_Timing
       `endif
     `else 
     `ifdef DDR4_1866L   
       `define CLK_PRD `CLK_PRD_DDR4_1866L
       `define CAL_DDR_PRD     8'h6B
       `ifdef CL_9 
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_10
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_12 
         `ifdef CWL_9
           `define DDR4_1250_Timing
           `define CLK_PRD 1.25     
           `define CAL_DDR_PRD     8'h7D	 
         `elsif CWL_11
           `define DDR4_1250_Timing
           `define CLK_PRD 1.25     
           `define CAL_DDR_PRD     8'h7D   
         `elsif CWL_10
           `define DDR4_1072_Timing
           `define CLK_PRD 1.072
           `define CAL_DDR_PRD     8'h6B
         `elsif CWL_12
           `define DDR4_1072_Timing
           `define CLK_PRD 1.08
           `define CAL_DDR_PRD     8'h6C
         `endif 	    
       `elsif CL_13 
         `define DDR4_1072_Timing
         `define CLK_PRD 1.072    
         `define CAL_DDR_PRD     8'h6B 	    
       `elsif CL_14 
         `define DDR4_1072_Timing
         `define CLK_PRD 1.072    
         `define CAL_DDR_PRD     8'h6B		
       `else
         `define DDR4_1072_Timing
       `endif
     `else 
     `ifdef DDR4_2133N   
       `define CLK_PRD `CLK_PRD_DDR4_2133N
       `define CAL_DDR_PRD     8'h5E
       `ifdef CL_9
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_10
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_12
         `define DDR4_1250_Timing
         `define CLK_PRD 1.26
         `define CAL_DDR_PRD     8'h7E	    
       `elsif CL_14 
         `ifdef CWL_10
           `define DDR4_1072_Timing
           `define CLK_PRD 1.072    
           `define CAL_DDR_PRD     8'h6B	      
         `elsif CWL_12 
           `define DDR4_1072_Timing
           `define CLK_PRD 1.072    
           `define CAL_DDR_PRD     8'h6B	      
         `elsif CWL_11
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E	      
         `elsif CWL_14
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E	      
         `endif 	    
       `elsif CL_15 
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E 	    
       `elsif CL_16 
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E        	    
       `endif
     `else 
     `ifdef DDR4_2400   
       `define CLK_PRD `CLK_PRD_DDR4_2400
       `define CAL_DDR_PRD     8'h54
       `ifdef CL_9
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_10
         `define DDR4_1500_Timing
         `define CLK_PRD 1.50
         `define CAL_DDR_PRD     8'h96	    
       `elsif CL_12 
         `define DDR4_1250_Timing
         `define CLK_PRD 1.25
         `define CAL_DDR_PRD     8'h7D	    
       `elsif CL_14
         `define DDR4_1072_Timing
         `define CLK_PRD 1.072
         `define CAL_DDR_PRD     8'h6B	        
       `elsif CL_15
         `define DDR4_833_Timing
         `define CLK_PRD 0.84
         `define CAL_DDR_PRD     8'h54	        
       `elsif CL_16 
         `ifdef CWL_11
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E	      
         `elsif CWL_14
           `define DDR4_938_Timing
           `define CLK_PRD 0.94
           `define CAL_DDR_PRD     8'h5E	        
         `else
           `define DDR4_833_Timing
           `define CLK_PRD 0.84
           `define CAL_DDR_PRD     8'h54	      
         `endif
       `elsif CL_18 
         `ifdef CWL_12
           `define DDR4_833_Timing
           `define CLK_PRD 0.84
           `define CAL_DDR_PRD     8'h54	        
         `else
           `define DDR4_833_Timing
           `define CLK_PRD 0.84
           `define CAL_DDR_PRD     8'h54	      
         `endif
       `endif // !`elsif CL_16
     `else 
        `ifdef DDR4_2666   
            `define CLK_PRD `CLK_PRD_DDR4_2666
            `define CAL_DDR_PRD     8'h4C
            `ifdef CL_9
              `define DDR4_1500_Timing
              `define CLK_PRD 1.50
              `define CAL_DDR_PRD     8'h96
            `elsif CL_10
              `define DDR4_1500_Timing
              `define CLK_PRD 1.50
              `define CAL_DDR_PRD     8'h96
            `elsif CL_11
              `ifdef CWL_9
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `elsif CWL_11
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `endif
            `elsif CL_12
              `ifdef CWL_9
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `elsif CWL_10
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `elsif CWL_11
                `define DDR4_1250_Timing
                `define CLK_PRD 1.25
                `define CAL_DDR_PRD     8'h7D
              `elsif CWL_12
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `endif
            `elsif CL_13
              `ifdef CWL_10
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `elsif CWL_12
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `endif
            `elsif CL_14
              `ifdef CWL_10
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `elsif CWL_11
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_12
                `define DDR4_1072_Timing
                `define CLK_PRD 1.072
                `define CAL_DDR_PRD     8'h6B
              `elsif CWL_14
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `endif
            `elsif CL_15
              `ifdef CWL_11
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `endif
            `elsif CL_16
              `ifdef CWL_11
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_938_Timing
                `define CLK_PRD 0.94
                `define CAL_DDR_PRD     8'h5E
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `endif
            `elsif CL_17
              `ifdef CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `elsif CL_18
              `ifdef CWL_12
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_16
                `define DDR4_833_Timing
                `define CLK_PRD 0.84
                `define CAL_DDR_PRD     8'h54
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `elsif CL_19
              `ifdef CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `elsif CL_20
              `ifdef CWL_14
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `elsif CWL_18
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `else
                `define DDR4_750_Timing
                `define CLK_PRD 0.75
                `define CAL_DDR_PRD     8'h4B
              `endif
            `else
              `define DDR4_750_Timing
            `endif // !`elsif CL_20
     `else 
      `ifdef DDR4_DBYP   
           `define CLK_PRD 8.0
           //`define CAL_DDR_PRD     8'h2A
           `define CAL_DDR_PRD     10'h31c
      `endif     
    `endif // !`ifdef DDR4_2666
                
  `endif `endif `endif `endif `endif `endif `endif
  `endif `endif `endif `endif `endif `endif `endif
  `endif `endif `endif `endif `endif `endif `endif 
  `endif `endif `endif `endif `endif `endif `endif
  `endif `endif `endif `endif `endif `endif `endif
  `endif `endif `endif
              
`define DWC_DRAM_CKAVG_ERR  10

`define CLK_DCYC          0.5             // default clock duty cycle = 50%
`define RST_CLKS          16              // width (clocks) of reset
`define NOPS_AFTER_RST    8               // NOPs required after reset
`define IB_LAT            6               // init bypass to any config command

// test vectors strobe position: vectors samples so many ns before both edges
// of the clock
`define TESTER_STROBE_POS 0.5

// NOPs required after any write to configuration and mode register before a
// new SDRAM command can be issued
// NOTE: The pipeline must be flushed of all commands before changing the
//       configuration
`define NOPS_AFTER_CFG    8

// PHY clock is either 2x or 1x controller clock
// host data width is either 4x or 2x DDR data width
`ifdef DWC_DDRPHY_HDR_MODE
  `define CLK_NX          2
  `define HOST_NX         4
`else
  `define CLK_NX          1
  `define HOST_NX         2
`endif

// internal PUB always in HDR mode
`define PUB_CLK_NX        2
`define PUB_HOST_NX       4

  // for PHY SDR mode, the timing values are twice the size as those in PHY HDR 
`ifdef DWC_PHY_SDR_MODE
  `define tVAL_NX         2
`else
  `define tVAL_NX         1
`endif

//PLL_SHARE Option to be taken care

`define ac_pll_share  `DWC_DX_AC_PLL_SHARE
`define dx_pll_share  `DWC_DX_PLL_SHARE

// auxiliary (secondary or slow) clock
`ifdef DWC_TCLK_PRD
  `define TCLK_PRD          `DWC_TCLK_PRD
`else      
  `ifdef DWC_DDRPHY_TB
    `ifdef DWC_DDRPHY_HDR_MODE
      `define TCLK_PRD      `DWC_CFGCLK_RATIO * `CLK_PRD
    `else
      `define TCLK_PRD      `DWC_CFGCLK_RATIO * (2.0*`CLK_PRD) // must be same as PUB clock which is now half
    `endif
  `else
    `define TCLK_PRD        `DWC_CFGCLK_RATIO * (4.0*`CLK_PRD)
  `endif
`endif

`ifdef DWC_TCLK_DUTY
  `define TCLK_DCYC         `DWC_TCLK_DUTY
`else
  `define TCLK_DCYC         0.5
`endif

// external bus clock
`ifdef DWC_XCLK_PRD
  `define XCLK_PRD            `DWC_XCLK_PRD
`else
  `define XCLK_PRD            `DWC_XCLK_RATIO * `TCLK_PRD
`endif

`ifdef DWC_XCLK_DUTY
  `define XCLK_DCYC         `DWC_XCLK_DUTY
`else
  `define XCLK_DCYC           0.5
`endif

// configuration clock perios
`define CFG_CLK_PRD         (`CLK_NX*`TCLK_PRD)

// number of clocks for PLL to lock (this is a specific PLL model number for
// how long it takes for the PLL lock signal to be asserted
`define PLL_LOCK_CLKS       1024

// CTRL or PHY initiated Update Requst and Acknowledge definitions
`define DFI_PHYUPD_TYPE0  8
`define DFI_PHYUPD_TYPE1  800
`define DFI_PHYUPD_TYPE2  30
`define DFI_PHYUPD_TYPE3  50

`define t_ctrlupd_min     8
`define t_ctrlupd_max     800

`define t_phyupd_resp     4

// in bypass mode, SDRAM clock period is 1/4 the value specified here
// because of clock division in the PLL
`ifdef DWC_PLL_BYPASS
  `define SDRAM_CK_PRD    (`CLK_PRD*4)
  `define DWC_DDR_CLK_EN
`else
  `define SDRAM_CK_PRD    `CLK_PRD
`endif

// drive DDR clock either when the PLL is in bypass mode or there is
// no PLL being used
`ifdef DWC_DDRPHY_PLL_USE
  `ifdef DWC_PLL_BYPASS
    `define DWC_DDR_CLK_EN
  `endif
`else
  `define DWC_DDR_CLK_EN
`endif


`define MAX_BOARD_DLY     (`CLK_PRD*1000*7)

// Fly_by_delay setting for write leveling 1.75 times of CLK_PRD
`define pWRITE_LEVEL_DLY_FACTOR         1.75  

// definitions for use if things have to be done on all bytes/bits
// NOTE: these are set to the number just above the max valid number
`define ALL_BYTES          9
`define ALL_DQ_BITS        8


// SDRAM rank encodings
`ifdef NO_OF_RANKS_1
  `define MSD_RANK_0                    // logic for SDRAM rank 0
`endif
`ifdef NO_OF_RANKS_2
  `define MSD_RANK_0                    // logic for SDRAM rank 0
  `define MSD_RANK_1                    // logic for SDRAM rank 1
`endif
`ifdef NO_OF_RANKS_3
  `define MSD_RANK_0                    // logic for SDRAM rank 0
  `define MSD_RANK_1                    // logic for SDRAM rank 1
  `define MSD_RANK_2                    // logic for SDRAM rank 2
`endif
`ifdef NO_OF_RANKS_4
  `define MSD_RANK_0                    // logic for SDRAM rank 0
  `define MSD_RANK_1                    // logic for SDRAM rank 1
  `define MSD_RANK_2                    // logic for SDRAM rank 2
  `define MSD_RANK_3                    // logic for SDRAM rank 3
`endif

`define SDRAM_RANK_WIDTH        ((`DWC_NO_OF_LRANKS > 8) ? 4 : \
                                 (`DWC_NO_OF_LRANKS > 4) ? 3 : \
                                 (`DWC_NO_OF_LRANKS > 2) ? 2 : 1)

`define CCACHE_SDRAM_RANK_WIDTH ((`DWC_NO_OF_LRANKS > 8)  ? 4 : \
                                 (`DWC_NO_OF_LRANKS > 4)  ? 3 : \
                                 (`DWC_NO_OF_LRANKS > 2)  ? 2 : \
                                 (`DWC_NO_OF_LRANKS == 1) ? 0 : 1)

// rank numbers
`define RANK_0             0
`define RANK_1             1
`define RANK_2             2
`define RANK_3             3
`define RANK_4             4
`define RANK_5             5
`define RANK_6             6
`define RANK_7             7
`define RANK_8             8
`define RANK_9             9
`define RANK_10            10
`define RANK_11            11
`define RANK_12            12
`define RANK_13            13
`define RANK_14            14
`define RANK_15            15
`define ALL_RANKS          16

// CK numbers
`define CK_0               0
`define CK_1               1
`define CK_2               2
`define ALL_CKS            3

`ifdef DDR4
  `define DDR_MASK_OFF     1'b1
  `define DDR_MASK_ON      1'b0
`else
  `define DDR_MASK_OFF     1'b0
  `define DDR_MASK_ON      1'b1
`endif

// if setting the number of ZQ to greater than 1 and you are not using the
// PHY configuration file, override the settings in the PHY configuration
// file since these are not automatically overrriden
`ifdef DWC_DDRPHY_TB_OVERRIDE
  `ifdef DWC_ZQ_2
    // put 2 ZQ in AC
    `define DWC_AC_NO_OF_ZIOHI    2
    `define DWC_AC_I1_NO_OF_ZQ    1
    `define DWC_AC_I1_NO_OF_VREF  1
    `define DWC_AC_Z1_NO_OF_VREF  1
  `endif
  `ifdef DWC_ZQ_3
    // put 3 ZQs in AC
    `define DWC_AC_NO_OF_ZIOHI    3
    `define DWC_AC_I1_NO_OF_ZQ    1
    `define DWC_AC_I1_NO_OF_VREF  1
    `define DWC_AC_Z1_NO_OF_VREF  1
    `define DWC_AC_I2_NO_OF_ZQ    1
    `define DWC_AC_I2_NO_OF_VREF  1
    `define DWC_AC_Z2_NO_OF_VREF  1
  `endif
  `ifdef DWC_ZQ_4
    // put 3 ZQs in AC and one in byte lane 0
    `undef  DWC_DX_ZQ_USE
    `undef  DWC_DX_VREF_USE

    `define DWC_AC_NO_OF_ZIOHI    3
    `define DWC_AC_I1_NO_OF_ZQ    1
    `define DWC_AC_I1_NO_OF_VREF  1
    `define DWC_AC_Z1_NO_OF_VREF  1
    `define DWC_AC_I2_NO_OF_ZQ    1
    `define DWC_AC_I2_NO_OF_VREF  1
    `define DWC_AC_Z2_NO_OF_VREF  1
    `define DWC_DX_NO_OF_ZIOHI    1
    `define DWC_DX_ZQ_USE         9'h001
    `define DWC_DX_VREF_USE       9'h001
    `define DWC_DX0_ZQ_NUM        3
    `define DWC_DX0_ZIOH_INUM     3
  `endif
`endif


// bus sizes
// ---------
// combined bus sizes of all SDRAMs ( default for 16M x 16)
`define DDR_ROW_WIDTH     `DWC_ADDR_WIDTH      // SDRAM row address width
`define DDR_COL_WIDTH     12                   // SDRAM col address width
`define DDR_RANK_WIDTH    `DWC_NO_OF_RANKS     // number of ranks

// not-used or not-available DQ bits of the most significant byte
`define DWC_MSBYTE_NUDQ   `DWC_MSBYTE_NDQ

`define DWC_DATA_WIDTH    (`DWC_NO_OF_BYTES*8) // SDRAM data width
`define DWC_EDATA_WIDTH   (`DWC_DATA_WIDTH-`DWC_MSBYTE_NUDQ) // SDRAM effective data width

`ifdef  DWC_USE_SHARED_AC
  `define CH0_DX8_BYTE_WIDTH  ((`DWC_NO_OF_BYTES - (`DWC_NO_OF_BYTES%2))/2)
  `define CH1_DX8_BYTE_WIDTH  (`DWC_NO_OF_BYTES   - `CH0_DX8_BYTE_WIDTH)
  `define CH0_DATA_WIDTH      (`CH0_DX8_BYTE_WIDTH*8)
  `define CH1_DATA_WIDTH      (`CH1_DX8_BYTE_WIDTH*8)
  `ifdef DW_8
    `define CH0_DWC_EDATA_WIDTH `DWC_EDATA_WIDTH
  `else
    `define CH0_DWC_EDATA_WIDTH `CH0_DATA_WIDTH
  `endif
  `define CH1_DWC_EDATA_WIDTH (`CH1_DATA_WIDTH - `DWC_MSBYTE_NUDQ)
`else
  `define CH0_DX8_BYTE_WIDTH (`DWC_NO_OF_BYTES)
  `define CH1_DX8_BYTE_WIDTH  0   
  `define CH0_DATA_WIDTH     (`CH0_DX8_BYTE_WIDTH*8)
  `define CH1_DATA_WIDTH      0
  `define CH0_DWC_EDATA_WIDTH (`DWC_EDATA_WIDTH)
  `define CH1_DWC_EDATA_WIDTH 0  
`endif    
              
//`define DDR_ADDR_WIDTH    `DDR_ROW_WIDTH      // SDRAM address width
//`define DDR_BYTE_WIDTH    (`DWC_DATA_WIDTH/8) // SDRAM byte/mask width
// PUB address and bank widths are always >13 and 3 respectively, but the
// hard macros (PHY + I/O) may be configured for less - in which case unused
// inputs to PUB are tied off
`define PUB_BANK_WIDTH   4
// LPDDR2/3 support enabled
`define PUB_ADDR_WIDTH   ((`DWC_ADDR_WIDTH < 16) ? 16: `DWC_ADDR_WIDTH)

// bus sizes for chip logic interface
`define BANK_WIDTH        `DWC_BANK_WIDTH             // bank select width
`define DATA_WIDTH        (`HOST_NX*`DWC_DATA_WIDTH)  // data bus width
`define EDATA_WIDTH       (`HOST_NX*`DWC_EDATA_WIDTH) // effective data bus width

`ifdef DWC_USE_SHARED_AC
  `define CH0_EDATA_WIDTH   (`HOST_NX*`CH0_DWC_EDATA_WIDTH) // effective data bus width for CH0
  `define CH1_EDATA_WIDTH   (`HOST_NX*`CH1_DWC_EDATA_WIDTH) // effective data bus width for CH1
`else
  `define CH0_EDATA_WIDTH   (`HOST_NX*`CH0_DWC_EDATA_WIDTH) // effective data bus width for CH0
  `define CH1_EDATA_WIDTH   0
`endif

`define BYTE_WIDTH        (`HOST_NX*`DWC_NO_OF_BYTES) // number of bytes
`define DQS_WIDTH         (`DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS) // number of bytes
`define HOST_DQS_WIDTH    (`HOST_NX*`DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS) // number of bytes
`define CMD_WIDTH         4                   // command bus width
`define CMD_FLAG_WIDTH    9                   // command flag width

`ifdef DWC_NO_OF_3DS_STACKS
  `define HOST_ADDR_WIDTH   ((`DWC_NO_OF_3DS_STACKS == 0) ? \
                            (`SDRAM_RANK_WIDTH + 4 + 18 + 11) : \
                            (`DWC_CID_WIDTH + `SDRAM_RANK_WIDTH + 4 + 18 + 11))         // host port address width
`else
  `define HOST_ADDR_WIDTH   (`SDRAM_RANK_WIDTH + 4 + 18 + 11)
`endif

`define DTP_WIDTH         5   // scheduler DRAM timing parameter width

`define DCU_RPT_WIDTH     3   // repeat field of DCU command
`define DCU_DTP_WIDTH     `DTP_WIDTH   // DRAM timing parameter width
`define DCU_TAG_WIDTH     2   // tag field of DCU command

`define REG_CMD_WIDTH     1   // register command width
`define REG_ADDR_WIDTH    10  // register address width
`define REG_BYTE_ADDR_WIDTH 2 // register byte address width
`define REG_DATA_WIDTH    32  // register data width
`define REG_BYTE_WIDTH    4   // number of bytes in register data
`define MR_DATA_WIDTH     14  // width of MR, EMR, EMR2, EMR3

`define DR_FIELD_INSTR_WIDTH  2               // TAP DR instruction field
`define DR_FIELD_ADDR_WIDTH   `REG_ADDR_WIDTH // TAP DR address field
`define DR_FIELD_DATA_WIDTH   `REG_DATA_WIDTH // TAP DR data field
`define DW_TAP_IR_WIDTH       3               // DW_tap block's IR width

`define CFG_CMD_WIDTH     `REG_CMD_WIDTH // alternative defines ...
`define CFG_ADDR_WIDTH    `REG_ADDR_WIDTH
`define CFG_BYTE_ADDR_WIDTH `REG_BYTE_ADDR_WIDTH
`define CFG_DATA_WIDTH    `REG_DATA_WIDTH  
`define CFG_BYTE_WIDTH    `REG_BYTE_WIDTH
`define RANKID_WR_WIDTH    4
`define RANKID_RD_WIDTH    4


`ifdef DWC_DDR_RDIMM_EN
   `define DWC_NO_OF_TRANKS   (`DWC_NO_OF_RANKS > 4)? 4: `DWC_NO_OF_RANKS   // trained ranks is number of physical ranks in RDIMM (maximum 4 ranks)
`elsif DWC_DDR_UDIMM_EN
   `define DWC_NO_OF_TRANKS   (`DWC_NO_OF_RANKS > 4)? 4: `DWC_NO_OF_RANKS   // trained ranks is number of physical ranks in UDIMM
`elsif DWC_DDR_LRDIMM_EN
   `define DWC_NO_OF_TRANKS   `DWC_NO_OF_RCD      // trained ranks is number of RCD chips in LRDIMM
`else
   `define DWC_NO_OF_TRANKS   (`DWC_NO_OF_RANKS > 4)? 4: `DWC_NO_OF_RANKS
`endif  
 


// width of timing parameters
`define tMRD_WIDTH        5
`define tRTP_WIDTH        4
`define tRP_WIDTH         7
`define tRFC_WIDTH        10
`define tWTR_WIDTH        5
`define tRCD_WIDTH        7
`define tRC_WIDTH         8
`define tRRD_WIDTH        6
`define tFAW_WIDTH        8
`define tMOD_WIDTH        3
`define tRAS_WIDTH        6
`define tDQSCK_WIDTH      3
`define tXS_WIDTH         10
`define tXP_WIDTH         5
`define tCKE_WIDTH        4
`define tDLLK_WIDTH       10
`define tWLMRD_WIDTH      6
`define tWLO_WIDTH        4
`define tCCD_L_WIDTH      3

`define tRFPRD_WIDTH      18

`define tDINIT0_WIDTH     20
`define tDINIT1_WIDTH     10
`define tDINIT2_WIDTH     18
`define tDINIT3_WIDTH     11
`define tDINITRST_WIDTH   18
`define tDINITCKELO_WIDTH 20
`define tDINITCKEHI_WIDTH 9 
`define tDINITZQ_WIDTH    11


`define PORT_ID_WIDTH     6   // max width of port ID (1 extra bit)

`define LCDL_DLY_WIDTH    9
`define BDL_DLY_WIDTH     6

`define WLD_FROM_BIT      0
`define X4_WLD_FROM_BIT   16                                                                              
`define WLD_TO_BIT        `WLD_FROM_BIT + (`LCDL_DLY_WIDTH-1)
`define X4_WLD_TO_BIT     `X4_WLD_FROM_BIT + (`LCDL_DLY_WIDTH-1)

`define DQSGD_FROM_BIT      0
`define X4_DQSGD_FROM_BIT   16                                                                              
`define DQSGD_TO_BIT        `DQSGD_FROM_BIT + (`LCDL_DLY_WIDTH-1)
`define X4_DQSGD_TO_BIT     `X4_DQSGD_FROM_BIT + (`LCDL_DLY_WIDTH-1)
                                                                                 
  
// operations
// ----------
// operation types:
// - the invisible bit [4] selects legal DDR controller commands when 0 or 
//   other operations when 1 (i.e. other operations start at 17
// - *_BL4 are for DDR3 on-the-fly burst length of 4 (burst chop); these
//   encodings must be similar to normal writes with bit[4] set to 1
`define CTRL_NOP          4'b0000     // no operation
`define LOAD_MODE         4'b0001     // SDRAM load mode register
`define SELF_REFRESH      4'b0010     // SDRAM self refresh entry
`define REFRESH           4'b0011     // SDRAM refresh
`define PRECHARGE         4'b0100     // SDRAM single bank precharge
`define PRECHARGE_ALL     4'b0101     // SDRAM all banks precharge
`define ACTIVATE          4'b0110     // SDRAM bank activate
`define SPECIAL_CMD       4'b0111     // SDRAM/controller special command
`define SDRAM_WRITE       4'b1000     // SDRAM write
`define WRITE_PRECHG      4'b1001     // SDRAM write with auto-precharge
`define SDRAM_READ        4'b1010     // SDRAM read
`define READ_PRECHG       4'b1011     // SDRAM read with auto-precharge
`define ZQCAL_SHORT       4'b1100     // SDRAM ZQ calibration short
`define READ_MODE         4'b1100     // LPDDR3/2 only - LPDDR3/2 read mode register
`define ZQCAL_LONG        4'b1101     // SDRAM ZQ calibration long
`define TERMINATE         4'b1101     // LPDDR3/2 only - Burst terminate
`define POWER_DOWN        4'b1110     // SDRAM power down entry
`define SDRAM_NOP         4'b1111     // SDRAM NOP

`define CFG_REG_READ      7'd16       // configuration register read 
`define CFG_REG_WRITE     7'd17       // configuration register write
`define POWER_DWN_EXIT    7'd18       // SDRAM power down exit
`define SELF_RFSH_EXIT    7'd19       // SDRAM self refresh exit
`define WRITE_BRST        7'd20       // SDRAM write data burst
`define WRITE_PRECHG_BRST 7'd21       // SDRAM write-precharge data burst 
`define READ_BRST         7'd22       // SDRAM read data burst
`define READ_PRECHG_BRST  7'd23       // SDRAM read-precharge data burst 

`define WRITE_BL4         7'd24       // SDRAM write BL4 on-the-fly (OTF)
`define WRITE_PRECHG_BL4  7'd25       // SDRAM write-precharge BL4 OTF
`define READ_BL4          7'd26       // SDRAM read data BL4 OTF
`define READ_PRECHG_BL4   7'd27       // SDRAM read-precharge BL4 OTF

`define DATA_OUT_BRST     7'd28       // burst of data coming out on outputs 
`define WR_DONE           7'd29       // write done
`define WR_DONE_BRST      7'd30       // write done burst
`define DESELECT          7'd31       // SDRAM device deselect
                                      
`define DATA_OUT          7'd33       // data coming out on outputs
`define DATA_IN           7'd34       // data driven on inputs
`define ADDR_IN           7'd35       // address data input
                                      
`define CHIP_CMD          7'd48       // chip operation
`define CHIP_DIN          7'd49       // data input by chip operation
`define CHIP_DOUT         7'd50       // data output by chip operation
`define CHIP_FLAG         7'd51       // chip full flag
`define CTRL_PIN          7'd52       // controller interface pins
`define MISC_OP           7'd53       // miscellaneous operations
                                      
`define SYS_TRAIN_DONE    7'd57       // training done
`define SYS_WLDONE        7'd58       // system write leveling done
`define SYS_TRST          7'd59       // system test reset
`define SYS_RST           7'd60       // system reset
                                      
`define BAD_MEM_OP        7'd61       // bad memory operation
`define END_INIT          7'd62       // end of initialization

`define JTAG_REG_READ     7'd63       // JTAG register read 
`define JTAG_REG_WRITE    7'd64       // JTAG register write

`define RDIMM_REG_WRITE   7'd65       // RDIMM buffer chip register write

`define END_SIM           7'd127      // end of simulation

// configuration register write
`define REG_READ          1'b0        // configuration register read 
`define REG_WRITE         1'b1        // configuration register write

`define ACTIVE_POWER_DN   1'b0        // active power down mode
`define PRECHG_POWER_DN   1'b1        // precharge power down mode
  
// special command encodings
`define RESET_LO          4'b0000     // SDRAM reset driven low
`define RESET_HI          4'b0001     // SDRAM reset driven high
`define CKE_LO            4'b0010     // SDRAM CKE driven low
`define CKE_HI            4'b0011     // SDRAM CKE driven high
`define CK_STOP           4'b0100     // SDRAM clock (CK) stop
`define CK_START          4'b0101     // SDRAM clock (CK) start
`define ODT_ON            4'b0110     // SDRAM ODT driven high
`define ODT_OFF           4'b0111     // SDRAM ODT driven low
`define DEEP_POWER_DOWN   4'b1000     // LPDDR2/3 SDRAM deep power down
`define RDIMMBCW          4'b1101     // Data buffer Control Register Write
`define RDIMMCRW          4'b1110     // RDIMM Control Register Write
`define MODE_EXIT         4'b1111     // power-down/self-refresh mode exit

// default number of accesses and iterations per test (during test development
// smaller numbers may be used by defining SHORT_SIM or -ss switch on runtc)
`ifdef SHORT_SIM
  `define NO_OF_B2B       8           // number of back to back accesses
  `define NO_OF_RND       16          // number of random accesses
  `define NOP_ITERATIONS  6           // iterations for different no of NOPs
`else                     
  `define NO_OF_B2B       16          // number of back to back accesses
  `define NO_OF_RND       200         // number of random accesses
  `define NOP_ITERATIONS  6           // iterations for different no of NOPs
`endif

// bank used for testcases that run on one bank only
`define DEFAULT_BANK      0           // default is to use bank 0
                          
// bank definitions       
`define BANK0             0
`define BANK1             1
`define BANK2             2
`define BANK3             3
`define ALL_BANKS         3'bzzz
                  
// DRAM initialization types
`define PUB_DRAM_INIT     2'b00 // using built-in PUB initialization
`define CTL_DRAM_INIT     2'b01 // controller initializes DRAM
`define CFG_DRAM_INIT     2'b10 // initialization through configuration port
                  
// read timing is the same as write timing at the host port, i.e.
// read command is maintained for the length of the burst as oppossed
// to only one clock cycle (set to zero otherwise)
`define FULL_RDTIMING     1

// basic write/read defines
`define MSD_WRITE         1'b0
`define MSD_READ          1'b1

// PHY soft resets
`define AC_DX_ONLY        1'b0 // reset only AC and DATX8
`define WHOLE_PHY         1'b1 // reset AC, DATX*, and PHYCTL

// I/O loopback selection
`define LB_IO_PAD         1'b0  // loopback through I/O pad side
`define LB_IO_CORE        1'b1  // loopback through I/O core side

// loopback DQS shift selection
`define LB_DQSS_AUTO      1'b0  // loopback DQS shift is automatically done by PUB
`define LB_DQSS_SW        1'b1  // loopback DQS shift is done by woftware

`define LB_GDQS_ON        2'b00 // loopback DQS gate always on
`define LB_GDQS_TRN       2'b01 // loopback DQS gate training will be triggered
`define LB_GDQS_SW        2'b10 // loopback DQS gate set by software
`define LB_GDQS_RSVD      2'b11 // reserved

// JTAG write and read latency (i.e from when read/write command
// is shifted in to when the actual write happens or when data is
// ready to be shifted out
`define JTAG_WR_LAT       (2 * `DWC_CDC_SYNC_STAGES)
`define JTAG_RD_LAT       (3 + (4 * `DWC_CDC_SYNC_STAGES) + `DWC_CFG_OUT_PIPE)

// traing using read/write or MPR
`define USE_RW            1'b0
`define USE_MPR           1'b1

// parity error injection point
`define PARERR_AT_BC      1'b0 // parity error injected at RDIMM buffer chip
`define PARERR_AT_MC      1'b1 // parity error injected at memory controller


// BIST definitions
// ----------------
`define BIST_NOP          3'b000
`define BIST_RUN          3'b001
`define BIST_STOP         3'b010
`define BIST_RESET        3'b011

`define BIST_LPBK_MODE    1'b0
`define BIST_DRAM_MODE    1'b1

`define BIST_WALKING_0    2'b00
`define BIST_WALKING_1    2'b01
`define BIST_LFSR_PSU_RND 2'b10
`define BIST_USER_PROG    2'b11


// scheduler and DCU definitions
// -----------------------------
// scheduler DRAM timing parameter (DTP)
`define DTP_tNODTP        5'd0
`define DTP_tRP           5'd1
`define DTP_tRAS          5'd2
`define DTP_tRRD          5'd3
`define DTP_tRC           5'd4
`define DTP_tMRD          5'd5
`define DTP_tMOD          5'd6
`define DTP_tFAW          5'd7
`define DTP_tRFC          5'd8
`define DTP_tWLMRD        5'd9
`define DTP_tWLO          5'd10
`define DTP_tXS           5'd11
`define DTP_tXP           5'd12
`define DTP_tCKE          5'd13
`define DTP_tDLLK         5'd14
`define DTP_tDINITRST     5'd15
`define DTP_tDINITCKELO   5'd16
`define DTP_tDINITCKEHI   5'd17
`define DTP_tDINITZQ      5'd18
`define DTP_tRPA          5'd19
`define DTP_tPRE2ACT      5'd20
`define DTP_tACT2RW       5'd21
`define DTP_tRD2PRE       5'd22
`define DTP_tWR2PRE       5'd23
`define DTP_tRD2WR        5'd24
`define DTP_tWR2RD        5'd25
`define DTP_tRDAP2ACT     5'd26
`define DTP_tWRAP2ACT     5'd27
`define DTP_tDCUT0        5'd28
`define DTP_tDCUT1        5'd29
`define DTP_tDCUT2        5'd30
`define DTP_tDCUT3        5'd31

`define DTP_tBCSTAB       5'd9
`define DTP_tBCMRD        5'd10

// DCU instructions
`define DCU_NOP           4'b0000
`define DCU_RUN           4'b0001
`define DCU_STOP          4'b0010
`define DCU_STOP_LOOP     4'b0011
`define DCU_RESET         4'b0100

`define DCU_READ          1'b0
`define DCU_WRITE         1'b1

// DCU repeat code
`define DCU_NORPT         3'd0  // execute once
`define DCU_RPT1X         3'd1  // execute twice
`define DCU_RPT4X         3'd2  // execute 4 times
`define DCU_RPT7X         3'd3  // execute 8 times
`define DCU_tBL           3'd4  // execute to create full DDR burst
`define DCU_tDCUT0        3'd5  // execute tDCUT0+1 times
`define DCU_tDCUT1        3'd6  // execute tDCUT1+1 times
`define DCU_tDCUT2        3'd7  // execute tDCUT2+1 times

`define DCU_NOTAG         2'd0
`define DCU_ALL_RANKS     2'd1


// PHY registers
// -------------
`define RIDR              10'h000
`define PIR               10'h001
`ifdef DWC_PUB_CLOCK_GATING
`define CGCR              10'h002
`endif
`define CGCR1             10'h003
`define PGCR0             10'h004
`define PGCR1             10'h005
`define PGCR2             10'h006
`define PGCR3             10'h007
`define PGCR4             10'h008
`define PGCR5             10'h009
`define PGCR6             10'h00A
`define PGCR7             10'h00B
`define PGCR8             10'h00C
`define PGSR0             10'h00D
`define PGSR1             10'h00E

`define PTR0              10'h010
`define PTR1              10'h011
`define PTR2              10'h012
`define PTR3              10'h013
`define PTR4              10'h014
`define PTR5              10'h015
`define PTR6              10'h016
`ifdef DWC_DDRPHY_PLL_TYPEB
`define PLLCR             10'h01A
`define PLLCR0            10'h01A
`define PLLCR1            10'h01B
`define PLLCR2            10'h01C
`define PLLCR3            10'h01D
`define PLLCR4            10'h01E
`define PLLCR5            10'h01F
`else
`define PLLCR             10'h020
`endif
`define DXCCR             10'h022
`define DSGCR             10'h024
`define ODTCR             10'h026
`define AACR              10'h028

`define GPR0              10'h030
`define GPR1              10'h031


`define DCR               10'h040
`define DTPR0             10'h044
`define DTPR1             10'h045
`define DTPR2             10'h046
`define DTPR3             10'h047
`define DTPR4             10'h048
`define DTPR5             10'h049
`define DTPR6             10'h04a

`define RDIMMGCR0         10'h050
`define RDIMMGCR1         10'h051
`define RDIMMGCR2         10'h052
`define RDIMMCR0          10'h054
`define RDIMMCR1          10'h055
`define RDIMMCR2          10'h056
`define RDIMMCR3          10'h057
`define RDIMMCR4          10'h058

`define SCHCR0            10'h05A
`define SCHCR1            10'h05B

`define MR0_REG           10'h060
`define MR1_REG           10'h061
`define MR2_REG           10'h062
`define MR3_REG           10'h063
`define MR4_REG           10'h064
`define MR5_REG           10'h065
`define MR6_REG           10'h066
`define MR7_REG           10'h067
`define MR11_REG          10'h06B

`define DTCR0             10'h080
`define DTCR1             10'h081
`define DTAR0             10'h082
`define DTAR1             10'h083
`define DTAR2             10'h084
`define DTDR0             10'h086
`define DTDR1             10'h087
`define UDDR0             10'h088
`define UDDR1             10'h089
`define DTEDR0            10'h08C
`define DTEDR1            10'h08D
`define DTEDR2            10'h08E
`define VTDR              10'h08F                                                                                 
`define CATR0             10'h090
`define CATR1             10'h091
`define DQSDR0            10'h094
`define DQSDR1            10'h095
`define DQSDR2            10'h096
                               
`define DCUAR             10'h0C0
`define DCUDR             10'h0C1
`define DCURR             10'h0C2
`define DCULR             10'h0C3
`define DCUGCR            10'h0C4
`define DCUTPR            10'h0C5
`define DCUSR0            10'h0C6
`define DCUSR1            10'h0C7

`define BISTRR            10'h100
`define BISTWCR           10'h101
`define BISTMSKR0         10'h102
`define BISTMSKR1         10'h103
`define BISTMSKR2         10'h104
`define BISTLSR           10'h105
`define BISTAR0           10'h106
`define BISTAR1           10'h107
`define BISTAR2           10'h108
`define BISTAR3           10'h109
`define BISTAR4           10'h10a
`define BISTUDPR          10'h10b
`define BISTGSR           10'h10c
`define BISTWER0          10'h10d
`define BISTWER1          10'h10e
`define BISTBER0          10'h10f
`define BISTBER1          10'h110
`define BISTBER2          10'h111
`define BISTBER3          10'h112
`define BISTBER4          10'h113
`define BISTWCSR          10'h114
`define BISTFWR0          10'h115
`define BISTFWR1          10'h116
`define BISTFWR2          10'h117
`define BISTBER5          10'h118

`define RANKIDR           10'h137
`define RIOCR0            10'h138
`define RIOCR1            10'h139
`define RIOCR2            10'h13a
`define RIOCR3            10'h13b
`define RIOCR4            10'h13c
`define RIOCR5            10'h13d
`define ACIOCR0           10'h140
`define ACIOCR1           10'h141
`define ACIOCR2           10'h142
`define ACIOCR3           10'h143
`define ACIOCR4           10'h144
`define ACIOCR5           10'h145
`define IOVCR0            10'h148
`define IOVCR1            10'h149
`define VTCR0             10'h14A
`define VTCR1             10'h14B
`define ACBDLR0           10'h150
`define ACBDLR1           10'h151
`define ACBDLR2           10'h152
`define ACBDLR3           10'h153
`define ACBDLR4           10'h154
`define ACBDLR5           10'h155
`define ACBDLR6           10'h156
`define ACBDLR7           10'h157
`define ACBDLR8           10'h158
`define ACBDLR9           10'h159
`define ACBDLR10          10'h15A
`define ACBDLR11          10'h15B
`define ACBDLR12          10'h15C
`define ACBDLR13          10'h15D
`define ACBDLR14          10'h15E
`define ACLCDLR           10'h160
`define ACMDLR0           10'h168
`define ACMDLR1           10'h169

`define ZQCR              10'h1A0
`define ZQ0PR             10'h1A1
`define ZQ0DR             10'h1A2
`define ZQ0SR             10'h1A3
`define ZQ1PR             10'h1A5
`define ZQ1DR             10'h1A6
`define ZQ1SR             10'h1A7
`define ZQ2PR             10'h1A9
`define ZQ2DR             10'h1Aa
`define ZQ2SR             10'h1Ab
`define ZQ3PR             10'h1Ad
`define ZQ3DR             10'h1Ae
`define ZQ3SR             10'h1Af

`define DX0GCR0           10'h1C0
`define DX0GCR1           10'h1C1
`define DX0GCR2           10'h1C2
`define DX0GCR3           10'h1C3
`define DX0GCR4           10'h1C4
`define DX0GCR5           10'h1C5
`define DX0GCR6           10'h1C6
`define DX0GCR7           10'h1C7
`define DX0GCR8           10'h1C8
`define DX0GCR9           10'h1C9
`define DX0BDLR0          10'h1D0
`define DX0BDLR1          10'h1D1
`define DX0BDLR2          10'h1D2
`define DX0BDLR3          10'h1D4
`define DX0BDLR4          10'h1D5
`define DX0BDLR5          10'h1D6
`define DX0BDLR6          10'h1D8
`define DX0BDLR7          10'h1D9
`define DX0BDLR8          10'h1DA
`define DX0BDLR9          10'h1DB
`define DX0LCDLR0         10'h1E0
`define DX0LCDLR1         10'h1E1
`define DX0LCDLR2         10'h1E2
`define DX0LCDLR3         10'h1E3
`define DX0LCDLR4         10'h1E4
`define DX0LCDLR5         10'h1E5
`define DX0MDLR0          10'h1E8
`define DX0MDLR1          10'h1E9
`define DX0GTR0           10'h1F0

`define DX0RSR0           10'h1F4
`define DX0RSR1           10'h1F5
`define DX0RSR2           10'h1F6
`define DX0RSR3           10'h1F7

`define DX0GSR0           10'h1F8
`define DX0GSR1           10'h1F9
`define DX0GSR2           10'h1FA
`define DX0GSR3           10'h1FB
`define DX0GSR4           10'h1FC
`define DX0GSR5           10'h1FD
`define DX0GSR6           10'h1FE

`define DX1GCR0           10'h200
`define DX1GCR1           10'h201
`define DX1GCR2           10'h202
`define DX1GCR3           10'h203
`define DX1GCR4           10'h204
`define DX1GCR5           10'h205
`define DX1GCR6           10'h206
`define DX1GCR7           10'h207
`define DX1GCR8           10'h208
`define DX1GCR9           10'h209
`define DX1BDLR0          10'h210
`define DX1BDLR1          10'h211
`define DX1BDLR2          10'h212
`define DX1BDLR3          10'h214
`define DX1BDLR4          10'h215
`define DX1BDLR5          10'h216
`define DX1BDLR6          10'h218
`define DX1BDLR7          10'h219
`define DX1BDLR8          10'h21A
`define DX1BDLR9          10'h21B
`define DX1LCDLR0         10'h220
`define DX1LCDLR1         10'h221
`define DX1LCDLR2         10'h222
`define DX1LCDLR3         10'h223
`define DX1LCDLR4         10'h224
`define DX1LCDLR5         10'h225
`define DX1MDLR0          10'h228
`define DX1MDLR1          10'h229
`define DX1GTR0           10'h230
`define DX1GTR1           10'h231
`define DX1RSR0           10'h234
`define DX1RSR1           10'h235
`define DX1RSR2           10'h236
`define DX1RSR3           10'h237
`define DX1GSR0           10'h238
`define DX1GSR1           10'h239
`define DX1GSR2           10'h23A
`define DX1GSR3           10'h23B
`define DX1GSR4           10'h23C
`define DX1GSR5           10'h23D
`define DX1GSR6           10'h23E

`define DX2GCR0           10'h240
`define DX2GCR1           10'h241
`define DX2GCR2           10'h242
`define DX2GCR3           10'h243
`define DX2GCR4           10'h244
`define DX2GCR5           10'h245
`define DX2GCR6           10'h246
`define DX2GCR7           10'h247
`define DX2GCR8           10'h248
`define DX2GCR9           10'h249
`define DX2BDLR0          10'h250
`define DX2BDLR1          10'h251
`define DX2BDLR2          10'h252
`define DX2BDLR3          10'h254
`define DX2BDLR4          10'h255
`define DX2BDLR5          10'h256
`define DX2BDLR6          10'h258
`define DX2BDLR7          10'h259
`define DX2BDLR8          10'h25A
`define DX2BDLR9          10'h25B
`define DX2LCDLR0         10'h260
`define DX2LCDLR1         10'h261
`define DX2LCDLR2         10'h262
`define DX2LCDLR3         10'h263
`define DX2LCDLR4         10'h264
`define DX2LCDLR5         10'h265
`define DX2MDLR0          10'h268
`define DX2MDLR1          10'h269
`define DX2GTR0           10'h270
`define DX2RSR0           10'h274
`define DX2RSR1           10'h275
`define DX2RSR2           10'h276
`define DX2RSR3           10'h277
`define DX2GSR0           10'h278
`define DX2GSR1           10'h279
`define DX2GSR2           10'h27A
`define DX2GSR3           10'h27B
`define DX2GSR4           10'h27C
`define DX2GSR5           10'h27D
`define DX2GSR6           10'h27E


`define DX3GCR0           10'h280
`define DX3GCR1           10'h281
`define DX3GCR2           10'h282
`define DX3GCR3           10'h283
`define DX3GCR4           10'h284
`define DX3GCR5           10'h285
`define DX3GCR6           10'h286
`define DX3GCR7           10'h287
`define DX3GCR8           10'h288
`define DX3GCR9           10'h289
`define DX3BDLR0          10'h290
`define DX3BDLR1          10'h291
`define DX3BDLR2          10'h292
`define DX3BDLR3          10'h294
`define DX3BDLR4          10'h295
`define DX3BDLR5          10'h296
`define DX3BDLR6          10'h298
`define DX3BDLR7          10'h299
`define DX3BDLR8          10'h29A
`define DX3BDLR9          10'h29B
`define DX3LCDLR0         10'h2A0
`define DX3LCDLR1         10'h2A1
`define DX3LCDLR2         10'h2A2
`define DX3LCDLR3         10'h2A3
`define DX3LCDLR4         10'h2A4
`define DX3LCDLR5         10'h2A5
`define DX3MDLR0          10'h2A8
`define DX3MDLR1          10'h2A9
`define DX3GTR0           10'h2B0
`define DX3RSR0           10'h2B4
`define DX3RSR1           10'h2B5
`define DX3RSR2           10'h2B6
`define DX3RSR3           10'h2B7
`define DX3GSR0           10'h2B8
`define DX3GSR1           10'h2B9
`define DX3GSR2           10'h2BA
`define DX3GSR3           10'h2BB
`define DX3GSR4           10'h2BC
`define DX3GSR5           10'h2BD
`define DX3GSR6           10'h2BE

`define DX4GCR0           10'h2C0
`define DX4GCR1           10'h2C1
`define DX4GCR2           10'h2C2
`define DX4GCR3           10'h2C3
`define DX4GCR4           10'h2C4
`define DX4GCR5           10'h2C5
`define DX4GCR6           10'h2C6
`define DX4GCR7           10'h2C7
`define DX4GCR8           10'h2C8
`define DX4GCR9           10'h2C9
`define DX4BDLR0          10'h2D0
`define DX4BDLR1          10'h2D1
`define DX4BDLR2          10'h2D2
`define DX4BDLR3          10'h2D4
`define DX4BDLR4          10'h2D5
`define DX4BDLR5          10'h2D6
`define DX4BDLR6          10'h2D8
`define DX4BDLR7          10'h2D9
`define DX4BDLR8          10'h2DA
`define DX4BDLR9          10'h2DB
`define DX4LCDLR0         10'h2E0
`define DX4LCDLR1         10'h2E1
`define DX4LCDLR2         10'h2E2
`define DX4LCDLR3         10'h2E3
`define DX4LCDLR4         10'h2E4
`define DX4LCDLR5         10'h2E5
`define DX4MDLR0          10'h2E8
`define DX4MDLR1          10'h2E9
`define DX4GTR0           10'h2F0
`define DX4RSR0           10'h2F4
`define DX4RSR1           10'h2F5
`define DX4RSR2           10'h2F6
`define DX4RSR3           10'h2F7
`define DX4GSR0           10'h2F8
`define DX4GSR1           10'h2F9
`define DX4GSR2           10'h2FA
`define DX4GSR3           10'h2FB
`define DX4GSR4           10'h2FC
`define DX4GSR5           10'h2FD
`define DX4GSR6           10'h2FE

`define DX5GCR0           10'h300
`define DX5GCR1           10'h301
`define DX5GCR2           10'h302
`define DX5GCR3           10'h303
`define DX5GCR4           10'h304
`define DX5GCR5           10'h305
`define DX5GCR6           10'h306
`define DX5GCR7           10'h307
`define DX5GCR8           10'h308
`define DX5GCR9           10'h309
`define DX5BDLR0          10'h310
`define DX5BDLR1          10'h311
`define DX5BDLR2          10'h312
`define DX5BDLR3          10'h314
`define DX5BDLR4          10'h315
`define DX5BDLR5          10'h316
`define DX5BDLR6          10'h318
`define DX5BDLR7          10'h319
`define DX5BDLR8          10'h31A
`define DX5BDLR9          10'h31B
`define DX5LCDLR0         10'h320
`define DX5LCDLR1         10'h321
`define DX5LCDLR2         10'h322
`define DX5LCDLR3         10'h323
`define DX5LCDLR4         10'h324
`define DX5LCDLR5         10'h325
`define DX5MDLR0          10'h328
`define DX5MDLR1          10'h329
`define DX5GTR0           10'h330
`define DX5RSR0           10'h334
`define DX5RSR1           10'h335
`define DX5RSR2           10'h336
`define DX5RSR3           10'h337
`define DX5GSR0           10'h338
`define DX5GSR1           10'h339
`define DX5GSR2           10'h33A
`define DX5GSR3           10'h33B
`define DX5GSR4           10'h33C
`define DX5GSR5           10'h33D
`define DX5GSR6           10'h33E

`define DX6GCR0           10'h340
`define DX6GCR1           10'h341
`define DX6GCR2           10'h342
`define DX6GCR3           10'h343
`define DX6GCR4           10'h344
`define DX6GCR5           10'h345
`define DX6GCR6           10'h346
`define DX6GCR7           10'h347
`define DX6GCR8           10'h348
`define DX6GCR9           10'h349
`define DX6BDLR0          10'h350
`define DX6BDLR1          10'h351
`define DX6BDLR2          10'h352
`define DX6BDLR3          10'h354
`define DX6BDLR4          10'h355
`define DX6BDLR5          10'h356
`define DX6BDLR6          10'h358
`define DX6BDLR7          10'h359
`define DX6BDLR8          10'h35A
`define DX6BDLR9          10'h35B
`define DX6LCDLR0         10'h360
`define DX6LCDLR1         10'h361
`define DX6LCDLR2         10'h362
`define DX6LCDLR3         10'h363
`define DX6LCDLR4         10'h364
`define DX6LCDLR5         10'h365
`define DX6MDLR0          10'h368
`define DX6MDLR1          10'h369
`define DX6GTR0           10'h370
`define DX6RSR0           10'h374
`define DX6RSR1           10'h375
`define DX6RSR2           10'h376
`define DX6RSR3           10'h377
`define DX6GSR0           10'h378
`define DX6GSR1           10'h379
`define DX6GSR2           10'h37A
`define DX6GSR3           10'h37B
`define DX6GSR4           10'h37C
`define DX6GSR5           10'h37D
`define DX6GSR6           10'h37E

`define DX7GCR0           10'h380
`define DX7GCR1           10'h381
`define DX7GCR2           10'h382
`define DX7GCR3           10'h383
`define DX7GCR4           10'h384
`define DX7GCR5           10'h385
`define DX7GCR6           10'h386
`define DX7GCR7           10'h387
`define DX7GCR8           10'h388
`define DX7GCR9           10'h389
`define DX7BDLR0          10'h390
`define DX7BDLR1          10'h391
`define DX7BDLR2          10'h392
`define DX7BDLR3          10'h394
`define DX7BDLR4          10'h395
`define DX7BDLR5          10'h396
`define DX7BDLR6          10'h398
`define DX7BDLR7          10'h399
`define DX7BDLR8          10'h39A
`define DX7BDLR9          10'h39B
`define DX7LCDLR0         10'h3A0
`define DX7LCDLR1         10'h3A1
`define DX7LCDLR2         10'h3A2
`define DX7LCDLR3         10'h3A3
`define DX7LCDLR4         10'h3A4
`define DX7LCDLR5         10'h3A5
`define DX7MDLR0          10'h3A8
`define DX7MDLR1          10'h3A9
`define DX7GTR0           10'h3B0
`define DX7RSR0           10'h3B4
`define DX7RSR1           10'h3B5
`define DX7RSR2           10'h3B6
`define DX7RSR3           10'h3B7
`define DX7GSR0           10'h3B8
`define DX7GSR1           10'h3B9
`define DX7GSR2           10'h3BA
`define DX7GSR3           10'h3BB
`define DX7GSR4           10'h3BC
`define DX7GSR5           10'h3BD
`define DX7GSR6           10'h3BE
                         
`define DX8GCR0           10'h3C0
`define DX8GCR1           10'h3C1
`define DX8GCR2           10'h3C2
`define DX8GCR3           10'h3C3
`define DX8GCR4           10'h3C4
`define DX8GCR5           10'h3C5
`define DX8GCR6           10'h3C6
`define DX8GCR7           10'h3C7
`define DX8GCR8           10'h3C8
`define DX8GCR9           10'h3C9
`define DX8BDLR0          10'h3D0
`define DX8BDLR1          10'h3D1
`define DX8BDLR2          10'h3D2
`define DX8BDLR3          10'h3D4
`define DX8BDLR4          10'h3D5
`define DX8BDLR5          10'h3D6
`define DX8BDLR6          10'h3D8
`define DX8BDLR7          10'h3D9
`define DX8BDLR8          10'h3DA
`define DX8BDLR9          10'h3DB
`define DX8LCDLR0         10'h3E0
`define DX8LCDLR1         10'h3E1
`define DX8LCDLR2         10'h3E2
`define DX8LCDLR3         10'h3E3
`define DX8LCDLR4         10'h3E4
`define DX8LCDLR5         10'h3E5
`define DX8MDLR0          10'h3E8
`define DX8MDLR1          10'h3E9
`define DX8GTR0           10'h3F0
`define DX8RSR0           10'h3F4
`define DX8RSR1           10'h3F5
`define DX8RSR2           10'h3F6
`define DX8RSR3           10'h3F7
`define DX8GSR0           10'h3F8
`define DX8GSR1           10'h3F9
`define DX8GSR2           10'h3FA
`define DX8GSR3           10'h3FB
`define DX8GSR4           10'h3FC
`define DX8GSR5           10'h3FD
`define DX8GSR6           10'h3FE

`define FIRST_REG_ADDR    `RIDR       // first register address
`define LAST_REG_ADDR     `DX8GSR6    // last register address
`define DX_REG_RANGE      10'h40      // each DX register range is 64 addresses
`define FIRST_DX0_REG     `DX0GCR0
`define LAST_DX0_REG      `DX0GSR6

// width of impedance control data
`define ZCTRL_WIDTH       `DWC_ZCTRL_WIDTH
`define ZLSB_WIDTH        3
`define ZCTRL_DRV_WIDTH   (`ZCTRL_WIDTH/2) // for eack the 2 drive control
`define ZCTRL_ODT_WIDTH   (`ZCTRL_WIDTH/2) // for eack the 2 termination control
`define ZCTRL_IMP_WIDTH   (`ZCTRL_WIDTH/4) // for the 4 impedance control
`define ZMSB_WIDTH        (`ZCTRL_IMP_WIDTH-`ZLSB_WIDTH)


// encoded PUB data
// ----------------
// PUB data is encoded: data specified is applied to all bytes and represents
// 4 beats of data
`define NO_OF_DATA_TYPES       16
`define PUB_DATA_TYPE_WIDTH    5
`define PUB_DATA_0000_0000     5'd0  // beat 0 = 8'h00,      beat 1 = 8'h00,       beat 2 = 8'b00,        beat 3 = 8'h00
`define PUB_DATA_FFFF_FFFF     5'd1  // beat 0 = 8'hFF,      beat 1 = 8'hFF,       beat 2 = 8'bFF,        beat 3 = 8'hFF
`define PUB_DATA_5555_5555     5'd2  // beat 0 = 8'h55,      beat 1 = 8'h55,       beat 2 = 8'b55,        beat 3 = 8'h55
`define PUB_DATA_AAAA_AAAA     5'd3  // beat 0 = 8'hAA,      beat 1 = 8'hAA,       beat 2 = 8'bAA,        beat 3 = 8'hAA
`define PUB_DATA_0000_5500     5'd4  // beat 0 = 8'h00,      beat 1 = 8'h55,       beat 2 = 8'b00,        beat 3 = 8'h00
`define PUB_DATA_5555_0055     5'd5  // beat 0 = 8'h55,      beat 1 = 8'h00,       beat 2 = 8'b55,        beat 3 = 8'h55
`define PUB_DATA_0000_AA00     5'd6  // beat 0 = 8'h00,      beat 1 = 8'hAA,       beat 2 = 8'b00,        beat 3 = 8'h00
`define PUB_DATA_AAAA_00AA     5'd7  // beat 0 = 8'hAA,      beat 1 = 8'h00,       beat 2 = 8'bAA,        beat 3 = 8'hAA
`define PUB_DATA_DTDR0         5'd8  // beat 0 = DTDR0[7:0], beat 1 = DTDR0[15:8], beat 2 = DTDR0[23:16], beat 3 = DTDR0[31:24]
`define PUB_DATA_DTDR1         5'd9  // beat 0 = DTDR1[7:0], beat 1 = DTDR1[15:8], beat 2 = DTDR1[23:16], beat 3 = DTDR1[31:24]
`define PUB_DATA_UDDR0         5'd10 // beat 0 = UDDR0[7:0], beat 1 = UDDR0[15:8], beat 2 = UDDR0[23:16], beat 3 = UDDR0[31:24]
`define PUB_DATA_UDDR1         5'd11 // beat 0 = UDDR1[7:0], beat 1 = UDDR1[15:8], beat 2 = UDDR1[23:16], beat 3 = UDDR1[31:24]
`define PUB_DATA_WALKING_1     5'd12 // beat 0 = walkign 1,  beat 1 = walking 1,   beat 2 = walking 1,    beat 3 = walking 1
`define PUB_DATA_WALKING_0     5'd13 // beat 0 = walkign 0,  beat 1 = walking 0,   beat 2 = walking 0,    beat 3 = walking 0
`define PUB_DATA_USER_PATTERN  5'd14 // beat 0 = user pat'n, beat 1 = user pat'n,  beat 2 = user pat'n,   beat 3 = user pat'n
`define PUB_DATA_LFSR          5'd15 // beat 0 = LFSR,       beat 1 = LFSR,        beat 2 = LFSR,         beat 3 = LFSR
`define PUB_DATA_SCHCR0        5'd16 // beat 0 = SCHCR0,     beat 1 = SCHCR0,      beat 2 = SCHCR0,       beat 3 = SCHCR0
`define PUB_DATA_FF00_FF00     5'd17 // beat 0 = 8'h00,      beat 1 = 8'hFF,       beat 2 = 8'b00,        beat 3 = 8'hFF
`define PUB_DATA_FFFF_0000     5'd18 // beat 0 = 8'h00,      beat 1 = 8'h00,       beat 2 = 8'bFF,        beat 3 = 8'hFF
`define PUB_DATA_0000_FF00     5'd19 // beat 0 = 8'h00,      beat 1 = 8'hFF,       beat 2 = 8'b00,        beat 3 = 8'h00
`define PUB_DATA_FFFF_00FF     5'd20 // beat 0 = 8'hFF,      beat 1 = 8'h00,       beat 2 = 8'bFF,        beat 3 = 8'hFF
`define PUB_DATA_00FF_00FF     5'd21 // beat 0 = 8'hFF,      beat 1 = 8'h00,       beat 2 = 8'bFF,        beat 3 = 8'h00
`define PUB_DATA_F0F0_F0F0     5'd22 // beat 0 = 8'hF0,      beat 1 = 8'hF0,       beat 2 = 8'bF0,        beat 3 = 8'hF0
`define PUB_DATA_0F0F_0F0F     5'd23 // beat 0 = 8'h0F,      beat 1 = 8'h0F,       beat 2 = 8'b0F,        beat 3 = 8'h0F
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define PUB_DATA_AA55EE11    5'd24 // 32'hAA55EE11
`endif

`define PUB_WALKING_1_8BIT_PAT  8'b0000_0001
`define PUB_WALKING_0_8BIT_PAT  8'b1111_1110
 
// width of DCU features
// ---------------------
// cache selection codes
`define DCU_CCACHE        2'b00 // command cache
`define DCU_ECACHE        2'b01 // expected data cache
`define DCU_RCACHE        2'b10 // read data cache

// cache depths
`define CCACHE_DEPTH       16
`define RCACHE_DEPTH       4
`define ECACHE_DEPTH       1
`define CACHE_ADDR_WIDTH   4
`define CACHE_LOOP_WIDTH   8 
`define DCU_FAIL_CNT_WIDTH 8
`define DCU_READ_CNT_WIDTH 16

// cache data widths and number of 32-bit slices
//  - data + mask + address + bank + rank + command + tag (2 bits) + repeat (5 bits)
`define PUB_DATA_WIDTH      (4*`DWC_DATA_WIDTH)  // DCU data bus width
`define PUB_BYTE_WIDTH      (4*`DWC_NO_OF_BYTES) // DCU number of bytes
`define PUB_DQS_WIDTH       (4*`DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS) // DCU number of bytes
`define DCU_DATA_WIDTH      `PUB_DATA_TYPE_WIDTH
`define DCU_BYTE_WIDTH      (4*`DWC_DX_NO_OF_DQS)
`define CCACHE_DATA_WIDTH (`DCU_DATA_WIDTH+`DCU_BYTE_WIDTH+`DWC_PHY_ADDR_WIDTH+`DWC_PHY_BG_WIDTH+`DWC_PHY_BA_WIDTH+`CCACHE_SDRAM_RANK_WIDTH+`CMD_WIDTH+`DCU_TAG_WIDTH+`DCU_DTP_WIDTH+`DCU_RPT_WIDTH)                                                 

`define CCACHE_SLICES       ((`CCACHE_DATA_WIDTH/`CFG_DATA_WIDTH) + ((`CCACHE_DATA_WIDTH %`CFG_DATA_WIDTH) > 0))
`define RCACHE_DATA_WIDTH 32
`define RCACHE_SLICES       ((`RCACHE_DATA_WIDTH/`CFG_DATA_WIDTH) + ((`RCACHE_DATA_WIDTH %`CFG_DATA_WIDTH) > 0))
`define ECACHE_DATA_WIDTH   (16*`DCU_DATA_WIDTH) // organized as wider 1-deep cache
`define ECACHE_SLICES       ((`ECACHE_DATA_WIDTH/`CFG_DATA_WIDTH) + ((`ECACHE_DATA_WIDTH %`CFG_DATA_WIDTH) > 0))


// controller registers              
// --------------------             
`define CDCR              8'd1    // controller DRAM configuration register
`define DRR               8'd4    // DRAM refresh register
`define TPR0              8'd5    // SDRAM timing parameters register 0
`define TPR1              8'd6    // SDRAM timing parameters register 1
`define TPR2              8'd7    // SDRAM timing parameters register 2
`define RSLR0             8'd8    // rank system latency register 0
`define RSLR1             8'd9    // rank system latency register 1
`define RSLR2             8'd10   // rank system latency register 2
`define RSLR3             8'd11   // rank system latency register 3
`define RDGR0             8'd12   // rank DQS gating register 0
`define RDGR1             8'd13   // rank DQS gating register 1
`define RDGR2             8'd14   // rank DQS gating register 2
`define RDGR3             8'd15   // rank DQS gating register 3

// ***TBD: temporary: chnage them to MRn in the code
`define MR                `MR0_REG
`define EMR1              `MR1_REG
`define EMR2              `MR2_REG
`define EMR3              `MR3_REG


// DDR SDRAM chip configuration
// ----------------------------
// bit positions = {density, I/O width, DDR mode (DDR3/DDR2)}
// *_*_BIT indicates which SDRAMs have the maximum number of bank, row and/or
// column address bits

// DDR4
// ----
// DDR4 2Gb
`ifdef DDR4_2Gbx4           
  `define SDRAM_CFG         6'b011_00_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   15
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx4              
  `define DDR4_X4
  `define DDR4_2G                                                                   
`endif

`ifdef DDR4_2Gbx8            
  `define SDRAM_CFG         6'b011_01_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   14
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
  `define DDR4_X8
  `define DDR4_2G                                                                   
`endif

`ifdef DDR4_2Gbx16            
  `define SDRAM_CFG         6'b011_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   14
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16              
  `define DDR4_X16
  `define DDR4_2G                                                                   
`endif                         

// DDR4
// ----
// DDR4 4Gb (x16) only model available from Elpida  
`ifdef DDR4_4Gbx4           
  `define SDRAM_CFG         6'b100_00_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   16
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx4              
  `define DDR4_X4
  `define DDR4_4G                                                                   
`endif

`ifdef DDR4_4Gbx8            
  `define SDRAM_CFG         6'b100_01_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   15
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
  `define DDR4_X8
  `define DDR4_4G                                                                   
`endif

`ifdef DDR4_4Gbx16            
  `define SDRAM_CFG         6'b100_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   15
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16              
  `define DDR4_X16
  `define DDR4_4G                                                                   
`endif                         

// DDR4
// ----
// DDR4 8Gb (x16) only model available from Elpida  
`ifdef DDR4_8Gbx4           
  `define SDRAM_CFG         6'b101_00_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   17
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx4              
  `define DDR4_X4
  `define DDR4_8G                                                                   
`endif

`ifdef DDR4_8Gbx8            
  `define SDRAM_CFG         6'b101_01_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   16
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
  `define DDR4_X8
  `define DDR4_8G                                                                   
`endif

`ifdef DDR4_8Gbx16            
  `define SDRAM_CFG         6'b101_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   16
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16              
  `define DDR4_X16
  `define DDR4_8G                                                                   
`endif                         

// DDR4
// ----
// DDR4 16Gb (x16) only model available from Elpida  
`ifdef DDR4_16Gbx4           
  `define SDRAM_CFG         6'b110_00_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   18
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx4              
  `define DDR4_X4
  `define DDR4_16G                                                                   
`endif

`ifdef DDR4_16Gbx8            
  `define SDRAM_CFG         6'b110_01_1
  `define SDRAM_BANK_WIDTH  4  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   17
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
  `define DDR4_X8
  `define DDR4_16G                                                                   
`endif

`ifdef DDR4_16Gbx16            
  `define SDRAM_CFG         6'b110_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   18  // a[17:0] address uses; with shared pins a[16] for ras_n; a[15] for cas_n; a[14] for we_n  
  `define SDRAM_ROW_CFG_WIDTH   17
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16              
  `define DDR4_X16
  `define DDR4_16G                                                                   
`endif                         


// DDR3
// ----
// DDR3 256Mb (x4, x8, x16)    
// *** NOTE: 256Mb is not a standard DDR3 part but has been added here to
//           verify address widths of 12 when in DDR3 mode
`ifdef DDR3_256Mbx4            
  `define SDRAM_CFG         6'b000_00_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   12 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif                         
                               
`ifdef DDR3_256Mbx8            
  `define SDRAM_CFG         6'b000_01_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   12 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif                         
                               
`ifdef DDR3_256Mbx16           
  `define SDRAM_CFG         6'b000_10_1
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   12
  `define SDRAM_COL_WIDTH   11
  `define SDRAMx16
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif

// DDR3 512Mb (x4, x8, x16)    
`ifdef DDR3_512Mbx4            
  `define SDRAM_CFG         6'b001_00_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif                         
                               
`ifdef DDR3_512Mbx8            
  `define SDRAM_CFG         6'b001_01_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif                         
                               
`ifdef DDR3_512Mbx16           
  `define SDRAM_CFG         6'b001_10_1
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   12
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif

// DDR3 1Gb (x4, x8, x16)
`ifdef DDR3_1Gbx4
  `define SDRAM_CFG         6'b010_00_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR3_1Gbx8              
  `define SDRAM_CFG         6'b010_01_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR3_1Gbx16             
  `define SDRAM_CFG         6'b010_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16             
  `define SDRAM_ADDR_LT_14    // SDRAM address is less than 14 bits              
`endif                         
                               
// DDR3 2Gb (x4, x8, x16)      
`ifdef DDR3_2Gbx4              
  `define SDRAM_CFG         6'b011_00_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR3_2Gbx8              
  `define SDRAM_CFG         6'b011_01_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR3_2Gbx16             
  `define SDRAM_CFG         6'b011_10_1
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   14
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
`endif
                               
// DDR3 4Gb (x4, x8, x16)      
`ifdef DDR3_4Gbx4              
  `define SDRAM_CFG         6'b100_00_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   16 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR3_4Gbx8              
  `define SDRAM_CFG         6'b100_01_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   16
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR3_4Gbx16             
  `define SDRAM_CFG         6'b100_10_1
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   15
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
`endif
                               
// DDR3 8Gb (x4, x8, x16)    
`ifdef DDR3_8Gbx4              
  `define SDRAM_CFG         6'b101_00_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   16 
  `define SDRAM_COL_WIDTH   12 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR3_8Gbx8              
  `define SDRAM_CFG         6'b101_01_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   16
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR3_8Gbx16             
  `define SDRAM_CFG         6'b101_10_1
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   16
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
`endif
                               
                               
// DDR2
// ----
// DDR2 256Mb (x4, x8, x16)    
`ifdef DDR2_256Mbx4            
  `define SDRAM_CFG         6'b000_00_0
  `define SDRAM_BANK_WIDTH  2  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR2_256Mbx8            
  `define SDRAM_CFG         6'b000_01_0
  `define SDRAM_BANK_WIDTH  2  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR2_256Mbx16           
  `define SDRAM_CFG         6'b000_10_0
  `define SDRAM_BANK_WIDTH  2  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   9  
  `define SDRAMx16             
`endif                         
                               
// DDR2 512Mb (x4, x8, x16)    
`ifdef DDR2_512Mbx4            
  `define SDRAM_CFG         6'b001_00_0
  `define SDRAM_BANK_WIDTH  2  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR2_512Mbx8            
  `define SDRAM_CFG         6'b001_01_0
  `define SDRAM_BANK_WIDTH  2  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR2_512Mbx16           
  `define SDRAM_CFG         6'b001_10_0
  `define SDRAM_BANK_WIDTH  2
  `define SDRAM_ROW_WIDTH   13
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
`endif

// DDR2 1Gb (x4, x8, x16)
`ifdef DDR2_1Gbx4
  `define SDRAM_CFG         6'b010_00_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR2_1Gbx8              
  `define SDRAM_CFG         6'b010_01_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR2_1Gbx16             
  `define SDRAM_CFG         6'b010_10_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16             
`endif                         
                               
// DDR2 2Gb (x4, x8, x16)      
`ifdef DDR2_2Gbx4              
  `define SDRAM_CFG         6'b011_00_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR2_2Gbx8              
  `define SDRAM_CFG         6'b011_01_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR2_2Gbx16             
  `define SDRAM_CFG         6'b011_10_0
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   14
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
`endif
           
// DDR2 4Gb (x4, x8, x16)      
`ifdef DDR2_4Gbx4              
  `define SDRAM_CFG         6'b100_00_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   16 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx4              
`endif                         
                               
`ifdef DDR2_4Gbx8              
  `define SDRAM_CFG         6'b100_01_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   16
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx8              
`endif                         
                               
`ifdef DDR2_4Gbx16             
  `define SDRAM_CFG         6'b100_10_0
  `define SDRAM_BANK_WIDTH  3
  `define SDRAM_ROW_WIDTH   15
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx16
`endif

// LPDDR2  (skip implementation for 64M, 128M, 256M, 512M, 2G, 4G, and 8G sdram config for time being)
// ------
// LPDDR2 1Gb (x8, x16, x32)
`ifdef LPDDR2_1Gbx8              
  `define SDRAM_CFG         6'b010_01_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx8              
`endif                         
                               
`ifdef LPDDR2_1Gbx16             
  `define SDRAM_CFG         6'b010_10_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx16             
`endif                         
                               
`ifdef LPDDR2_1Gbx32        // current not ran with run_regress     
  `define SDRAM_CFG         6'b010_11_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   13 
  `define SDRAM_COL_WIDTH   9 
  `define SDRAMx32
`endif           
              
//LPDDR2 4Gb (x8, x16, x32)
`ifdef LPDDR2_4Gbx8              
  `define SDRAM_CFG         6'b100_01_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   12 
  `define SDRAMx8              
`endif                         
                               
`ifdef LPDDR2_4Gbx16             
  `define SDRAM_CFG         6'b100_10_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx16             
`endif                         
                               
`ifdef LPDDR2_4Gbx32        // current not ran with run_regress     
  `define SDRAM_CFG         6'b100_11_0
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   10
  `define SDRAMx32
`endif                         

// LPDDR3 (skip implementation for sdram config: ex: 32G)
//         
// ------
//LPDDR3 4Gb (x16, x32)
`ifdef LPDDR3_4Gbx16             
  `define SDRAM_CFG         6'b100_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx16              
`endif
                                                                                 
`ifdef LPDDR3_4Gbx32              
  `define SDRAM_CFG         6'b100_11_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   14 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx32              
`endif
                                                                                 
//LPDDR3 6Gb (x16, x32)
`ifdef LPDDR3_6Gbx16             
  `define SDRAM_CFG         6'b100_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx16              
`endif
                                                                                 
`ifdef LPDDR3_6Gbx32              
  `define SDRAM_CFG         6'b100_11_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx32              
`endif
                                                                                    
//LPDDR3 8Gb (x16, x32)
`ifdef LPDDR3_8Gbx16             
  `define SDRAM_CFG         6'b100_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx16              
`endif
                                                                                 
`ifdef LPDDR3_8Gbx32              
  `define SDRAM_CFG         6'b100_11_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   10 
  `define SDRAMx32              
`endif
                                                                                 
//LPDDR3 16Gb (x16, x32)
`ifdef LPDDR3_16Gbx16             
  `define SDRAM_CFG         6'b100_10_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   12 
  `define SDRAMx16              
`endif
                                                                                 
`ifdef LPDDR3_16Gbx32              
  `define SDRAM_CFG         6'b100_11_1
  `define SDRAM_BANK_WIDTH  3  
  `define SDRAM_ROW_WIDTH   15 
  `define SDRAM_COL_WIDTH   11 
  `define SDRAMx32              
`endif

// tRFC_min parameter for ddr3 in ns
`ifdef den256Mb
  `define ddr3_tRFC_min_ns  90
`elsif den512Mb
  `define ddr3_tRFC_min_ns  90 	
`elsif den1024Mb
  `define ddr3_tRFC_min_ns  110 	
`elsif den2048Mb 
  `define ddr3_tRFC_min_ns  160  	
`elsif den4096Mb 
  `define ddr3_tRFC_min_ns  260 	
`else  //den8192Mb 
  `define ddr3_tRFC_min_ns  350 	
`endif 

// tRFC_min parameter for ddr4 in ns for REFRESH MODE 1X
`ifdef den2048Mb 
  `define ddr4_tRFC1_min_ns  160 	
`elsif den4096Mb 
  `define ddr4_tRFC1_min_ns  260 
`elsif den8192Mb 
  `define ddr4_tRFC1_min_ns  350  	
`else  //den16384Mb 
  `define ddr4_tRFC1_min_ns  350  	// TBD 
`endif 

// tRFC_min parameter for ddr4 in ns for REFRESH MODE 2X
`ifdef den2048Mb 
  `define ddr4_tRFC2_min_ns  110  	
`elsif den4096Mb 
  `define ddr4_tRFC2_min_ns  160 	
`elsif den8192Mb 
  `define ddr4_tRFC2_min_ns  260 	
`else  //den16384Mb 
  `define ddr4_tRFC2_min_ns  260 	// TBD 	
`endif 

// tRFC_min parameter for ddr4 in ns for REFRESH MODE 4X
`ifdef den2048Mb 
  `define ddr4_tRFC4_min_ns   90  	
`elsif den4096Mb 
  `define ddr4_tRFC4_min_ns  110 	
`elsif den8192Mb 
  `define ddr4_tRFC4_min_ns  160 	
`else  //den16384Mb 
  `define ddr4_tRFC4_min_ns  160 	// TBD 	
`endif 

// tRFC_min parameter for ddr2 in ns
`ifdef den256Mb
  `define ddr2_tRFC_min_ns   75
`elsif den512Mb
  `define ddr2_tRFC_min_ns  105
`elsif den1024Mb
  `define ddr2_tRFC_min_ns  128 	
`elsif den2048Mb 
  `define ddr2_tRFC_min_ns  195  	
`else //den4096Mb 
  `define ddr2_tRFC_min_ns  328 	
`endif 

// tRFC_min parameter for lpddr3 in ns
`ifdef den64Mb 
  `define lpddr2_tRFCab_min_ns   90 	
`elsif den128Mb
  `define lpddr2_tRFCab_min_ns   90
`elsif den256Mb 
  `define lpddr2_tRFCab_min_ns   90 	
`elsif den512Mb
  `define lpddr2_tRFCab_min_ns   90
`elsif den1024Mb
  `define lpddr2_tRFCab_min_ns  130
`elsif den2048Mb 
  `define lpddr2_tRFCab_min_ns  130 	
`elsif den4096Mb 
  `define lpddr2_tRFCab_min_ns  130 	
`else //den8192Mb 
  `define lpddr2_tRFCab_min_ns  210 	
`endif

// tRFC_min parameter for lpddr3 in ns
`ifdef den4096Mb 
  `define lpddr3_tRFCab_min_ns  130 	
`elsif den6144Mb
  `define lpddr3_tRFCab_min_ns  210
`elsif den8192Mb 
  `define lpddr3_tRFCab_min_ns  210 	
`else //den16384b
  `define lpddr3_tRFCab_min_ns  210
`endif

                                                                                 
                                                                                        
// timing parameters
// -----------------              
// one reperesentative for each speed grade: others TBD
`ifdef DDR4_DBYP
  // JEDEC DDR4  (9-9-9): 125 MHz
  `define tMOD            0     // tMOD =24
  `define tMRD            8     // is the exact value of tMRD (removed offset of 8)
  `define tRTP            6     // 7.5/1.2575 = 6
  `define tWTR            6     // 7.5/1.2575 = 6
  `define tRP             12
  `define tRCD            12
  `define tRAS            35
  `define tRRD            6
  `define tRC             36
  `define tFAW            36
  `define tRFC_min        (`ddr4_tRFC1_min_ns+`ddr4_tRFC_tolerance)/`CLK_PRD        // use REFRESH MODE 1X for as default
  `define tRFC_max        60000/`CLK_PRD
  `define tWR             2     // tWR = 12
  `define tXP             20
  `define tCKE            5
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define tWLO            15
`else
  `define tWLO            6
`endif
  `define tCCD_L          1
  `define QSPEED_BIN      10
`endif


// JEDEC DDR4
`ifdef DDR4_2666
  // JEDEC DDR4-2666  (15-15-15): 1333 MHz
  `define tMOD            6     // from DDR4_2400
  `define tMRD            9     // is the exact value of tMRD (removed offset of 8)
  `define tRTP            12    // from DDR4_2400: 10 *.833/.75 = 12
  `define tWTR            12    // from DDR4_2400: 10 *.833/.75 = 12
  `define tRP             18    // from DDR4_2400: 16 *.833/.75 = 18
  `define tRCD            18    // from DDR4_2400: 16 *.833/.75 = 18
  `define tRAS            43    // from DDR4_2400: 39 *.833/.75 = 43
  `define tRRD            10    // from DDR4_2400: 9 * .833/.75 = 10
  `define tRC             60    // from DDR4_2400: 54 * .833/.75 = 60
  `define tFAW            60    
  `define tRFC_min        (`ddr4_tRFC1_min_ns+`ddr4_tRFC_tolerance)/`CLK_PRD        // use REFRESH MODE 1X for as default
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             5     // 15/.75 = 20
  `define tXP             20    // from DDR4_2400
  `define tCKE            6     // from DDR4_2400 ?   
  `define tWLO            10    // from DDR4_2400 ?
  `define tCCD_L          2     // from DDR4_2400 ?

 `define QSPEED_BIN      15
`endif

`ifdef DDR4_2400
  // JEDEC DDR4-2400  (15-15-15): 1200 MHz
  `define tMOD            5     // tMOD = 17
  `define tMRD            8     // is the exact value of tMRD (removed offset of 8)
  `define tRTP            10    // 7.5/.833= 10
  `define tWTR            10    // 7.5/.833= 10
  `define tRP             16    // 12.5/.833=16
  `define tRCD            16    // from 15, tRCDmin violation
  `define tRAS            39    // 32/.833 = 39
  `define tRRD            9     // 
  `define tRC             54 
  `define tFAW            54
  `define tRFC_min        (`ddr4_tRFC1_min_ns+`ddr4_tRFC_tolerance)/`CLK_PRD        // use REFRESH MODE 1X for as default
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             5     // 15/.833 = 18
  `define tXP             20    
  `define tCKE            6
  `define tWLO            10
  `define tCCD_L          2

 `define QSPEED_BIN      15
`endif

`ifdef DDR4_2133N
  // JEDEC DDR4-2133N (14-14-14): 1066 MHz
  `define tMOD            5     // tMOD = 17
  `define tMRD            8     // is the exact value of tMRD (removed offset of 8)
  `define tRTP            8     // 7.5/.938=8
  `define tWTR            8     // 7.5/.938=8
  `define tRP             14    // 13.13/.938=14
  `define tRCD            14
  `define tRAS            36    // 33/.938=36
  `define tRRD            9
  `define tRC             50
  `define tFAW            50
  `define tRFC_min        (`ddr4_tRFC1_min_ns+`ddr4_tRFC_tolerance)/`CLK_PRD        // use REFRESH MODE 1X for as default
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             4     // tWR = 16
  `define tXP             20
  `define tCKE            6
  `define tWLO            10
  `define tCCD_L          2
 `endif

  `define QSPEED_BIN      14

`ifdef DDR4_1866L
  // JEDEC DDR4-1866L (12-12-12): 933 MHz
  `define tMOD            3     // tMOD = 15
  `define tMRD            8     // tis the exact value of tMRD (removed offset of 8)
  `define tRTP            8     // 7.5/1.071 = 8
  `define tWTR            8     // 7.5/1.071 = 8
  `define tRP             14
  `define tRCD            14
  `define tRAS            32
  `define tRRD            8
  `define tRC             44
  `define tFAW            44
  `define tRFC_min        (`ddr4_tRFC1_min_ns+`ddr4_tRFC_tolerance)/`CLK_PRD        // use REFRESH MODE 1X for as default
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             3     // tWR = 16 - 14 is too tight at exactly 933MHz
  `define tXP             20
  `define tCKE            5
  `define tWLO            9
  `define tCCD_L          1

 `define QSPEED_BIN      12
`endif                     

`ifdef DDR4_1600J
  // JEDEC DDR4-1600J (10-10-10): 800 MHz
  `define tMOD            0     // tMOD =24
  `define tMRD            8     // is the exact value of tMRD (removed offset of 8)
  `define tRTP            6     // 7.5/1.2575 = 6
  `define tWTR            6     // 7.5/1.2575 = 6
  `define tRP             12
  `define tRCD            12
  `define tRAS            35
  `define tRRD            6
  `define tRC             36
  `define tFAW            36
  `define tRFC_min        (`ddr4_tRFC1_min_ns+`ddr4_tRFC_tolerance)/`CLK_PRD        // use REFRESH MODE 1X for as default
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             2     // tWR = 12
  `define tXP             20
  `define tCKE            5
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define tWLO            15
`else
  `define tWLO            6
`endif
  `define tCCD_L          1
  `define QSPEED_BIN      10
`endif                     

// JEDEC DDR3/DDR2 (defines such as sg125G are for vendor-specific models)

// JEDEC DDR3
// ----------              
`ifdef DDR3_2133K
  // JEDEC DDR3-2133K (11-11-11): 1066 MHz
  `define tMOD            5     // tMOD = 17
  `define tMRD            4
  `define tRTP            9
  `define tWTR            9
  `define tRP             11
  `define tRCD            11
  `define tRAS            38
  `define tRRD             9
  `define tRC             49
`ifdef SDRAMx16                                                                                 
  `define tFAW            35
`else                                                                                 
  `define tFAW            25
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             0     // tWR = 16
  `define tXP             20
  `define tCKE            6
  `define tWLO            10
  `define sg0935K
  `define QSPEED_BIN      10
  `define CAL_DDR_PRD     9'h5E // LCDL measured DDR period
`endif                     

`ifdef DDR3_1866J
  // JEDEC DDR3-1866J (10-10-10): 933 MHz
  `define tMOD            3     // tMOD = 15
  `define tMRD            4
  `define tRTP            8
  `define tWTR            8
  `define tRP             10
  `define tRCD            10
  `define tRAS            33
  `define tRRD            8
  `define tRC             43
`ifdef SDRAMx16                                                                                 
  `define tFAW            35
`else                                                                                 
  `define tFAW            27
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             0     // tWR = 16
  `define tXP             20
  `define tCKE            5
  `define tWLO            9
  `define sg107J
  `define QSPEED_BIN      10
  `define CAL_DDR_PRD     9'h6A // LCDL measured DDR period
`endif                     

`ifdef DDR3_1600G
  // JEDEC DDR3-1600G (8-8-8): 800 MHz
  `define tMRD            4
  `define tRTP            6
  `define tWTR            6
  `define tRP             8
  `define tRCD            8
  `define tRAS            28
  `define tRRD            6
  `define tRC             36
`ifdef SDRAMx16                                                                                 
  `define tFAW            40
`else                                                                                 
  `define tFAW            30
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             6     // tWR = 12
  `define tXP             20
  `define tCKE            5
  `define tWLO            6
  `define sg125G
  `define QSPEED_BIN      10
  `define CAL_DDR_PRD     9'h82 // LCDL measured DDR period
`endif                     

`ifdef DDR3_1333F
  // JEDEC DDR3-1333F (7-7-7): 667 MHz
  `define tMRD            4
  `define tRTP            5
  `define tWTR            5
  `define tRP             7
  `define tRCD            7
  `define tRAS            24
  `define tRRD            5 
  `define tRC             31
`ifdef SDRAMx16                                                                                 
  `define tFAW            45
`else                                                                                 
  `define tFAW            30
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             5     // tWR = 10
  `define tXP             16
  `define tCKE            5
  `define tWLO            6
  `define sg15G
  `define QSPEED_BIN      6
  `define CAL_DDR_PRD     9'h96 // LCDL measured DDR period
`endif                     

`ifdef DDR3_1066E
  // JEDEC DDR3-1066E (6-6-6): 533 MHz
  `define tMRD            4
  `define tRTP            4
  `define tWTR            4
  `define tRP             6
  `define tRCD            6
  `define tRAS            20
  `define tRRD            4
  `define tRC             26
`ifdef SDRAMx16                                                                                 
  `define tFAW            50
`else                                                                                 
  `define tFAW            38
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             4     // tWR = 8
  `define tXP             13
  `define tCKE            4
  `define tWLO            5
  `define sg187F
  `define S1066E
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'hBA // LCDL measured DDR period
`endif                     

`ifdef DDR3_800D
  // JEDEC DDR3-800D (5-5-5): 400 MHz
  `define tMRD            4
  `define tRTP            4
  `define tWTR            4
  `define tRP             5
  `define tRCD            5
  `define tRAS            15
  `define tRRD            4
  `define tRC             20
`ifdef SDRAMx16                                                                                 
  `define tFAW            50
`else                                                                                 
  `define tFAW            40
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             2     // tWR = 6
  `define tXP             10
  `define tCKE            4
  `define tWLO            4
  `define sg25E
  `define S800D
  `define QSPEED_BIN      1
  `define CAL_DDR_PRD     9'hFA // LCDL measured DDR period   
`endif                     

`ifdef DDR3_667C
  // *** NOTE: this is just a dummy speed grade, uses JEDEC DDR3-800D (5-5-5): 333 MHz
  `define tMRD            4
  `define tRTP            4
  `define tWTR            4
  `define tRP             5
  `define tRCD            5
  `define tRAS            15
  `define tRRD            4
  `define tRC             20
`ifdef SDRAMx16                                                                                 
  `define tFAW            50
`else                                                                                 
  `define tFAW            40
`endif                                                                                 
  `define tRFC_min        (`ddr3_tRFC_min_ns+`ddr3_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             2     // tWR = 6
  `define tXP             10
  `define tCKE            4
  `define tWLO            4
  `define sg25E
  `define S800D
  `define QSPEED_BIN      1
  `define CAL_DDR_PRD     9'hFA // LCDL measured DDR period
`endif                     

`ifdef DDR3_DBYP
  // DDR3 SDRAM DLL Bypass: 125 MHz
  `define tMRD            4
  `define tRTP            4
  `define tWTR            4
  `define tRP             5
  `define tRCD            5
  `define tRAS            15
  `define tRRD            4
  `define tRC             20
  `define tFAW            20
  `define tRFC_min        16
  //`define tRFC_min        `ddr3_tRFC_min_ns/`CLK_PRD  
  `define tRFC_max        1000
  `define tWR             2     // tWR = 6
  `define tXP             10
  `define tCKE            4
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define tWLO            15
`else
  `define tWLO            4
`endif
  `define QSPEED_BIN      1
  `define CAL_DDR_PRD     10'h31c // LCDL measured DDR period
`endif


// JEDEC DDR2
// ----------              
`ifdef DDR2_1066E
  // JEDEC DDR2-1066E (6-6-6): 533 MHz
  `define tMRD            4
  `define tRTP            4
  `define tWTR            4
  `define tRP             6
  `define tRCD            6
  `define tRAS            22
  `define tRRD            4
  `define tRC             28
  `define tFAW            27
  `define tRFC_min        (`ddr2_tRFC_min_ns+`ddr2_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             7     // tWR = 8
  `define tXP             9
  `define sg187F
  `define CAL_DDR_PRD     9'hBA // LCDL measured DDR period
`endif                     

`ifdef DDR2_800D
  // JEDEC DDR2-800D (5-5-5): 400 MHz
  `define tMRD            2
  `define tRTP            3
  `define tWTR            3
  `define tRP             5
  `define tRCD            5
  `define tRAS            16
  `define tRRD            4
  `define tRC             24
  `define tFAW            20
  `define tRFC_min        (`ddr2_tRFC_min_ns+`ddr2_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             5     // tWR = 6
  `define tXP             8
  `define sg25E
  `define S800
  `define CAL_DDR_PRD     9'hFA // LCDL measured DDR period
`endif                     
                             
`ifdef DDR2_800E
  // JEDEC DDR2-800E (6-6-6): 400 MHz
  `define tMRD            2
  `define tRTP            3
  `define tWTR            4
  `define tRP             6
  `define tRCD            6
  `define tRAS            18    // ** TBD 18 ro 16 ?
  `define tRRD            4
  `define tRC             24    // ** TBD 24 ro 22 ?
  `define tFAW            20
  `define tRFC_min        (`ddr2_tRFC_min_ns+`ddr2_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             5     // tWR = 6
  `define tXP             8
  `define sg25
  `define CAL_DDR_PRD     9'hFA // LCDL measured DDR period
`endif                     
                             
`ifdef DDR2_667C
  // JEDEC DDR2-667C (4-4-4): 333 MHz
  `define tMRD            2
  `define tRTP            3
  `define tWTR            4
  `define tRP             4
  `define tRCD            4
  `define tRAS            14
  `define tRRD            4
  `define tRC             18
  `define tFAW            17
  `define tRFC_min        (`ddr2_tRFC_min_ns+`ddr2_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             4     // tWR = 5
  `define tXP             7
  `define sg3E
  `define CAL_DDR_PRD     9'h12C // LCDL measured DDR period
`endif                     
                           
`ifdef DDR2_533C
  // JEDEC DDR2-533C (4-4-4): 267 MHz
  `define tMRD            2
  `define tRTP            3
  `define tWTR            2
  `define tRP             4
  `define tRCD            4
  `define tRAS            11
  `define tRRD            3
  `define tRC             15
  `define tFAW            14
  `define tRFC_min        (`ddr2_tRFC_min_ns+`ddr2_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             4     // tWR = 5
  `define tXP             6
  `define sg37E
  `define CAL_DDR_PRD     9'h176 // LCDL measured DDR period
`endif                     
                           
`ifdef DDR2_400B
  // JEDEC DDR2-400B (5-5-5) : 200 MHz              
  `define tMRD            2
  `define tRTP            2
  `define tWTR            2
  `define tRP             3
  `define tRCD            3
  `define tRAS            8
  `define tRRD            2
  `define tRC             11
  `define tFAW            20
  `define tRFC_min        (`ddr2_tRFC_min_ns+`ddr2_tRFC_tolerance)/`CLK_PRD  
  `define tRFC_max        70000/`CLK_PRD
  `define tWR             2     // tWR = 3
  `define tXP             6
  `define sg5E
  `define CAL_DDR_PRD     9'h1F2 // LCDL measured DDR period
`endif                     

// JEDEC LPDDR2
// ------------              
// Note: tDQSCK is derived from the integer division of the SDRAM tDQSCK by
//       clock period (CLK_PRD), i.e. division without rounding up
//       tDQSCK_DGPS (phase select) is the remainder in 1/4 cycle units of
//       the division to match the exact tDQSCK of the SDRAM
//       tDQSCKMAX is derived from the integer division of the SDRAM
//       tDQSCKMAX by clock period (CLK_PRD) and rounding up
//       tDQSCKVAR is derived from the integer division of the SDRAM
//       (tDQSCKMAX-tDQSCK) by clock period (CLK_PRD) and rounding up
`ifdef LPDDR2_1066
  // JEDEC LPDDR2-1066: 533 MHz
  `define tMRD            4
  `define tRTP            4
  `define tWTR            5
  `define tRP             11
  `define tRCD            10
  `define tRAS            23
  `define tRRD            6
  `define tRC             33
  `define tFAW            27
  //`define tRFC_min        70
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        27800
  `define tWR             6     // tWR = 8
  `define tXP             13
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1  // (2.5-1.875)/(1.875/4)
  `define tDQSCKMAX       3
  `define tDQSCKVAR       2
  `define sg187
  `define S1066E
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'hC8 // LCDL measured DDR period
`endif                     

`ifdef LPDDR2_933
  // JEDEC LPDDR2-933: 466 MHz
  `define tMRD            5
  `define tRTP            4
  `define tWTR            4
  `define tRP             9
  `define tRCD            9
  `define tRAS            20
  `define tRRD            5
  `define tRC             29
  `define tFAW            20
  //`define tRFC_min        61
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        27800
  `define tWR             5     // tWR = 7
  `define tXP             8
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1
  `define tDQSCKMAX       3
  `define tDQSCKVAR       2
  `define sg215
  `define CAL_DDR_PRD     9'hD6 // LCDL measured DDR period
`endif                     
                               
`ifdef LPDDR2_800
  // JEDEC LPDDR2-800: 400 MHz
  `define tMRD            5
  `define tRTP            3
  `define tWTR            3
  `define tRP             8
  `define tRCD            8
  `define tRAS            17
  `define tRRD            4
  `define tRC             35
  `define tFAW            17
  //`define tRFC_min        52
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        27800
  `define tWR             4     // tWR = 6
  `define tXP             8
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd0
  `define tDQSCKMAX       3
  `define tDQSCKVAR       2
  `define sg25
  `define CAL_DDR_PRD     9'hFA // LCDL measured DDR period   
`endif                     
                             
`ifdef LPDDR2_667
  // JEDEC DDR2-667: 333 MHz
  `define tMRD            5
  `define tRTP            3
  `define tWTR            3
  `define tRP             6
  `define tRCD            6
  `define tRAS            14
  `define tRRD            4
  `define tRC             20
  `define tFAW            17
  //`define tRFC_min        44
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        23100
  `define tWR             4     // tWR = 5
  `define tXP             7
  `define tDQSCK          0
  `define tDQSCK_DGPS     2'd3
  `define tDQSCKMAX       2
  `define tDQSCKVAR       1
  `define sg3
  `define CAL_DDR_PRD     9'h12C // LCDL measured DDR period
`endif                     
                           
`ifdef LPDDR2_533
  // JEDEC LPDDR2-533: 267 MHz
  `define tMRD            5
  `define tRTP            3
  `define tWTR            2
  `define tRP             5
  `define tRCD            5
  `define tRAS            12
  `define tRRD            3
  `define tRC             17
  `define tFAW            14
  //`define tRFC_min        35
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        18400
  `define tWR             3     // tWR = 4
  `define tXP             6
  `define tDQSCK          0
  `define tDQSCK_DGPS     2'd3
  `define tDQSCKMAX       2
  `define tDQSCKVAR       1
  `define sg37
  `define CAL_DDR_PRD     9'h176 // LCDL measured DDR period
`endif                     
                           
`ifdef LPDDR2_400
  // JEDEC LPDDR2-400: 200 MHz              
  `define tMRD            5
  `define tRTP            2
  `define tWTR            2
  `define tRP             4
  `define tRCD            4
  `define tRAS            9
  `define tRRD            2
  `define tRC             13
  `define tFAW            10
  //`define tRFC_min        26
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        13800
  `define tWR             2     // tWR = 3
  `define tXP             6
  `define tDQSCK          0
  `define tDQSCK_DGPS     2'd2
  `define tDQSCKMAX       2
  `define tDQSCKVAR       1
  `define sg5
  `define CAL_DDR_PRD     9'h1F2 // LCDL measured DDR period
`endif  

`ifdef LPDDR2_250
  // JEDEC LPDDR2-250: 125 MHz
  `define tMRD            5
  `define tRTP            3
  `define tWTR            2
  `define tRP             5
  `define tRCD            5
  `define tRAS            12
  `define tRRD            3
  `define tRC             17
  `define tFAW            14
  //`define tRFC_min        35
  `define tRFC_min        (`lpddr2_tRFCab_min_ns+`lpddr2_tRFC_tolerance)/`CLK_PRD
  `define tRFC_max        18400
  `define tWR             3     // tWR = 4
  `define tXP             6
  `define tDQSCK          0
  `define tDQSCK_DGPS     2'd3
  `define tDQSCKMAX       2
  `define tDQSCKVAR       1
  `define sg37
  `define CAL_DDR_PRD     9'h176 // LCDL measured DDR period
`endif                          

`ifdef LPDDR3_2133
  // JEDEC LPDDR3-2133: 1066 MHz              
  `define tMRD            15        // max of (14ns or 10n CK)
  `define tRTP            8         // (7.5ns/0.939)
  `define tWTR            8         // (7.5ns/0.939)
  `define tRP             20        // DDRG2MPHY: 18ns (tRPpb(typ)/0.939)
  `define tRCD            20        // DDRG2MPHY: 18ns (tRCD(typ)/0.939) 
  `define tRAS            45        // DDRG2MPHY: 42ns tRAS(min/0.939)
  `define tRRD            11        // DDRG2MPHY: 10ns/0.939
  `define tRC             68        // DDRG2MPHY: Worst case is (tRAS+tRPab) = 63ns (63/0.939)
  `define tFAW            54        // DDRG2MPHY: 50 ns
  //`define tRFC_min        139       // DDRG2MPHY: tRFCab (130ns)
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // DDRG2MPHY: tRFCab (130ns)
  `define tWR             6         // tWR = 15ns /0.939 /DDRG2MPHY: This value should be 16 or 3'b110
  `define nWRE            1         // This should be 1 for nWR greater than 9
  `define tXP             8         // (7.5ns/0.939)
  `define tDQSCK          2
  `define tDQSCK_DGPS     2'd1      // (2.5-1.875)/(1.875/4) //DDRG2MPHY: Which parameter?
  `define tDQSCKMAX       6         // 5.5ns/CLK_PRD = 5.86
  `define tDQSCKVAR       2         // DDRG2MPHY: Which parameter?
  `define sg93                      // doesnt exist yet?
  // `define S1066
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h5F     // LCDL measured DDR period (Period/2*stepsize=> 939/10 => 94) =>5E
`endif 

`ifdef LPDDR3_1866
  // JEDEC LPDDR2-1866: 933 MHz
  `define tMRD            13        // max of (14ns or 10n CK)
  `define tRTP            7         // (7.5ns/1.072)
  `define tWTR            7         // (7.5ns/1.072)
  `define tRP             17        // (tRPpb(typ)/1.072) => 18ns/1.072 = 16.79
  `define tRCD            17        // (tRPpb(typ)/1.072) => 18ns/1.072 = 16.79
  `define tRAS            40        // 42ns/1.072 = 39.18
  `define tRRD            10        // 10ns/1.072 = 9.33
  `define tRC             59        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 63/1.072
  `define tFAW            47        // 50ns/1.072
  //`define tRFC_min        122       // 130ns/1.072
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // 130ns/1.072
  `define tWR             4         // tWR = 15ns /1.072 /DDRG2MPHY: This value should be 14 or 3'b100
  `define nWRE            1         // This should be 1 for nWR gretaer than 9
  `define tXP             7         // (7.5ns/1.072)
  `define tDQSCK          2
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       6         // 5.5ns/CLK_PRD = 5.13
  `define tDQSCKVAR       2         // DDRG2MPHY: Which parameter?
  `define sg107                     // doesnt exist yet?
  // `define S933
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h6C     // LCDL measured DDR period (Period/2*ddl_dtep_size)=> 1072/10 =>108 => 6C 
`endif

`ifdef LPDDR3_1600
  // JEDEC LPDDR3-1600: 800 MHz              
  `define tMRD            11        // max of (14ns or 10n CK)
  `define tRTP            6         // (7.5ns/1.2575)
  `define tWTR            6         // (7.5ns/1.2575)
  `define tRP             15        // DDRG2MPHY: 18ns (tRPpb(typ)/1.2575)
  `define tRCD            15        // DDRG2MPHY: 18ns (tRCD(typ)/1.2575) 
  `define tRAS            34        // DDRG2MPHY: 42ns tRAS(min/1.2575)
  `define tRRD            8         // DDRG2MPHY: 10ns
  `define tRC             51        // DDRG2MPHY: Worst case is (tRAS+tRPab) = 63ns, 51*tCK=63.75ns
  `define tFAW            40        // DDRG2MPHY: 50 ns
  //`define tRFC_min        104       // DDRG2MPHY: tRFCab (130ns)
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // DDRG2MPHY: tRFCab (130ns)
  `define tWR             2         // tWR = 15ns //DDRG2MPHY: This value should be  010
  `define nWRE            1         // This should be 1 for nWR greater than 9
  `define tXP             6         // (7.5ns/1.2575)
  `define tDQSCK          2
  `define tDQSCK_DGPS     2'd1      // (2.5-1.875)/(1.875/4) //DDRG2MPHY: Which parameter?
  `define tDQSCKMAX       5         // 5.5ns/CLK_PRD = 4.37
  `define tDQSCKVAR       2         // DDRG2MPHY: Which parameter?
  `define sg125
  // `define S800
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h80     // LCDL measured DDR period (Period/2*stepsize=> 1250/2*10 => 125/2) =>3F
`endif 

`ifdef LPDDR3_1466
  // JEDEC LPDDR2-1466: 733 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            6         // (7.5ns/1.36)
  `define tWTR            6         // max(7.5ns, 4nCK) = 7.5ns
  `define tRP             14        // (tRPpb(typ)/1.36) => 18ns/1.36 = 13.23
  `define tRCD            14        // (tRPpb(typ)/1.36) => 18ns/1.36 = 13.23
  `define tRAS            31        // 42ns/1.36 = 30.88
  `define tRRD            8         // 10ns/1.36 = 7.35
  `define tRC             47        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 47*tCK=63.92ns
  `define tFAW            37        // 50ns/1.36 = 36.76
  //`define tRFC_min        96        // 130ns/1.36 = 44.11
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // 130ns/1.36 = 95.6
  `define tWR             2         // tWR = 15ns /1.36 /DDRG2MPHY: This value round up to 12
  `define nWRE            1         // This should be 1 for nWR gretaer than 9
  `define tXP             6         // 7.5 / 1.36 = 5.5
  `define tDQSCK          2
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       4         // 5.5ns/CLK_PRD = 4.03
  `define tDQSCKVAR       2         // DDRG2MPHY: Which parameter?
  `define sg136
  // `define S733
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h88     // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

`ifdef LPDDR3_1333
  // JEDEC LPDDR3-1333: 667 MHz              
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            5
  `define tWTR            5
  `define tRP             12        // DDRG2MPHY: (tRPpb(typ)/1.5) => 18ns/1.5
  `define tRCD            12        // DDRG2MPHY: (tRPpb(typ)/1.5) => 18ns/1.5 
  `define tRAS            28        // DDRG2MPHY: 42ns tRAS(min)
  `define tRRD            7         // DDRG2MPHY: 10ns
  `define tRC             42        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 42*tCK=63ns
  `define tFAW            34        // DDRG2MPHY: 50 ns
  //`define tRFC_min        87        // DDRG2MPHY: tRFCpb (130ns)
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // DDRG2MPHY: tRFCab (130ns)
  `define tWR             0         // tWR = 15ns
  `define nWRE            1         // This should be 1 for nWR greater than 9
  `define tXP             4
  `define tDQSCK          2
  `define tDQSCK_DGPS     2'd1      // (2.5-1.875)/(1.875/4) //DDRG2MPHY: Which parameter?
  `define tDQSCKMAX       4         // 5.5ns/CLK_PRD = 3.67
  `define tDQSCKVAR       2         // DDRG2MPHY: Which parameter?
  `define sg15
  // `define S667
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h96     // LCDL measured DDR period (Period/2*stepsize=> 1500/2*10 => 150/2) =>4B

`endif 

`ifdef LPDDR3_1200
  // JEDEC LPDDR2-1200: 600 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            5         // (7.5ns/1.67) = 4.49
  `define tWTR            5         // max(7.5ns, 4nCK) = 7.5ns / 1.67 = 
  `define tRP             11        // (tRPpb(typ)/1.67) => 18ns/1.67 = 10.77
  `define tRCD            11        // (tRPpb(typ)/1.67) => 18ns/1.67 = 10.77
  `define tRAS            25        // 42ns/1.67 = 25.148
  `define tRRD            6         // 10ns/1.67 = 5.988
  `define tRC             38        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 38*tCK=63.46ns
  `define tFAW            30        // 50ns/1.67 = 29.94
  //`define tRFC_min        78        // 130ns/1.67 = 35.9
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // 130ns/1.67 = 77.84
  `define tWR             7         // tWR = RU(8.98)= 9 
  `define nWRE            0         // This should be 1 for nWR gretaer than 9
  `define tXP             5         // 7.5 / 1.67 = 4.49
  `define tDQSCK          2
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       3         // 3.29
  `define tDQSCKVAR       2         // DDRG2MPHY: Which parameter?
  `define sg167
  // `define S600
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'hA6     // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

`ifdef LPDDR3_1066
  // JEDEC LPDDR2-1066: 533 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            4         // Original 4 (7.5ns/1.875)
  `define tWTR            4
  `define tRP             10        // 10 (tRPpb(typ)/1.875) => 18ns/1.875
  `define tRCD            10        // 10 (tRPpb(typ)/1.875) => 18ns/1.875
  `define tRAS            23
  `define tRRD            6
  `define tRC             34        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 34*tCK=63.75
  `define tFAW            27
  //`define tRFC_min        70
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800
  `define tWR             6         // tWR = 8
  `define nWRE            0         // This should be 0 for nWR less than 9
  `define tXP             4
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       3         // 5.5ns/CLK_PRD = 2.93
  `define tDQSCKVAR       2
  `define sg187
  // `define S533
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'hBA     // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

`ifdef LPDDR3_800
  // JEDEC LPDDR2-800: 400 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            4         // (7.5ns or 4n ck)
  `define tWTR            4         // max(7.5ns, 4nCK) = 10ns
  `define tRP             8         // (tRPpb(typ)/2.5) => 18ns/2.5
  `define tRCD            8         // (tRPpb(typ)/2.5) => 18ns/2.5
  `define tRAS            17        // 42ns/2.5
  `define tRRD            4         // 10ns/2.5
  `define tRC             26        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 26*tCK=65ns
  `define tFAW            20        // 50ns/2.5
  //`define tRFC_min        52        // 60ns/2.5
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        27800     // 130ns/2.5
  `define tWR             4         // tWR = 6
  `define nWRE            0         // This should be 0 for nWR less than 9
  `define tXP             3
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       3         // 5.5ns/CLK_PRD = 2.2
  `define tDQSCKVAR       2
  `define sg25
  // `define S400
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'hFA     // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

`ifdef LPDDR3_667
  // JEDEC LPDDR2-667: 333 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            4         // (7.5ns/3.0)
  `define tWTR            4         // max(7.5ns, 4nCK) = 10ns
  `define tRP             6         // (tRPpb(typ)/3.0) => 18ns/3.0
  `define tRCD            6         // (tRPpb(typ)/3.0) => 18ns/3.0
  `define tRAS            14        // 42ns/3.0
  `define tRRD            4         // 10ns/3.0
  `define tRC             21        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 21*tCK=63ns
  `define tFAW            17        // 50ns/3.0
  //`define tRFC_min        44        // 130ns/3.0
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        23100     // 130ns/3.0
  `define tWR             4         // tWR = 6
  `define nWRE            0         // This should be 0 for nWR less than 9
  `define tXP             3
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       2         // 5.5ns/CLK_PRD = 1.83
  `define tDQSCKVAR       2
  `define sg3                       // doesnt exist yet?
  // `define S333
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h12C     // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

`ifdef LPDDR3_333
  // JEDEC LPDDR2-333: 166 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            4         // (7.5ns/6)
  `define tWTR            4         // max(7.5ns, 4nCK) = 24ns
  `define tRP             3         // (tRPpb(typ)/6) => 18ns/6
  `define tRCD            3         // (tRPpb(typ)/6) => 18ns/6
  `define tRAS            7         // 42ns/6
  `define tRRD            2         // max(10ns,2nCK)/6
  `define tRC             11        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 11*tCK=66ns
  `define tFAW            9         // 50ns/6
  //`define tRFC_min        22        // 60ns/6
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        13800     // 130ns/6
  `define tWR             4         // tWR=max(15ns,4nCK)= 4   There is no case where nwr=4 in MR1. So taking nWR=6 for which the value is 4
  `define nWRE            0         // This should be 0 for nWR less than 9
  `define tXP             3
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       1         // 5.5ns/CLK_PRD = 0.92
  `define tDQSCKVAR       2
  `define sg6
  // `define S166
  `define QSPEED_BIN      3
  //`define CAL_DDR_PRD     9'h12C    // LCDL measured DDR period (Period/2*ddl_dtep_size)
  `define CAL_DDR_PRD     9'h1FF    // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

`ifdef LPDDR3_250
  // JEDEC LPDDR3-250: 125 MHz
  `define tMRD            10        // max of (14ns or 10n CK)
  `define tRTP            4         // (7.5ns/3.0)
  `define tWTR            4         // max(7.5ns, 4nCK) = 10ns
  `define tRP             6         // (tRPpb(typ)/3.0) => 18ns/3.0
  `define tRCD            6         // (tRPpb(typ)/3.0) => 18ns/3.0
  `define tRAS            14        // 42ns/3.0
  `define tRRD            4         // 10ns/3.0
  `define tRC             21        // DDRG2MPHY: Worse case is (tRAS+tRPab) = 63ns, 21*tCK=63ns
  `define tFAW            17        // 50ns/3.0
  //`define tRFC_min        44        // 130ns/3.0
  `define tRFC_min        (`lpddr3_tRFCab_min_ns+`lpddr3_tRFC_tolerance)/`CLK_PRD       // tRFCab
  `define tRFC_max        23100     // 130ns/3.0
  `define tWR             4         // tWR = 6
  `define nWRE            0         // This should be 0 for nWR less than 9
  `define tXP             3
  `define tDQSCK          1
  `define tDQSCK_DGPS     2'd1      // Why used?
  `define tDQSCKMAX       1         // 5.5ns/CLK_PRD = 0.69
  `define tDQSCKVAR       2
  `define sg6
  // `define S125
  `define QSPEED_BIN      3
  `define CAL_DDR_PRD     9'h12C     // LCDL measured DDR period (Period/2*ddl_dtep_size)
`endif

// tDQSCK timing now used also in DDR3/4 DLL BYPASS mode
`ifdef DDR4
  // check if DLL BYPASS is used
  `ifdef DDR4_DBYP
    `ifdef ELPIDA_DDR
      `define tDQSCK          0  // model do not support
    `elsif MICRON_DDR
      `define tDQSCK          1  // model adds 1 clks Ceil(tDQSCK_dll_off/tck = 5.8ns / 8ns = 0.75)=1
    `endif
  `else 
    `define tDQSCK          0    // do not add if not dll bypass
  `endif
  `define tDQSCK_DGPS     2'd0
  `define tDQSCKMAX       0
  `define tDQSCKVAR       0
`else 
  `ifdef DDR3
    // DLL BYPASS and normal do not add extra tDQSCK
    `define tDQSCK          0
    `define tDQSCK_DGPS     2'd0
    `define tDQSCKMAX       0
    `define tDQSCKVAR       0
  `else 
    `ifdef DDR2
      // DLL BYPASS and normal do not add extra tDQSCK
      `define tDQSCK          0
      `define tDQSCK_DGPS     2'd0
      `define tDQSCKMAX       0
      `define tDQSCKVAR       0
    `else 
    `endif
  `endif
`endif                     

// Micron DDR3 model does not allow the ODT to be enabled immediately after
// the read postamble - set the read-to-ODT delay to 1 to insert an extra
// clock
`ifdef DDR3
  `ifdef MICRON_DDR
    `define tRTODT         1
  `else
    `define tRTODT         0
  `endif
`else
    `define tRTODT         0
`endif

// miscellaneous timing parameters
`ifdef tMOD
`else
  `ifdef DWC_DDR_RDIMM
    `define tMOD               1     // tMOD = 13
  `else
    `define tMOD               0     // tMOD = 12
  `endif
`endif
`define tWLMRD               40
`ifdef DDR3
  `define tDLLK              10'd512   // DLL locking time
  `define tXS                512
`else
  `ifdef DDR4
    `define tDLLK            10'd512   // DLL locking time
    `define tXS              512
  `else
    `define tCKE             15
    `define tDLLK            10'd200
    `define tXS              200
    `define tWLO             6
  `endif
`endif


// default timing parameters implemented on the controller
`define tMRD_c             5'd6
`define tMOD_c             3'd4
`define tRTP_c             4'd8
`define tRP_c              7'd14
`define tRFC_min_c         10'd374
`define tWTR_c             5'd8
`define tRCD_c             7'd14
`define tRC_c              8'd50
`define tRRD_c             4'd7
`define tFAW_c             6'd38
`define tRAS_c             7'd36
`define tRFC_max_c         18'd27800
`define tXS_c              10'd512
`define tXP_c              5'd26
`define tCKE_c             4'd6
`define tDLLK_c            10'd384
`define tWLMRD_c           6'd40
`define tWLO_c             4'd8
`define tDQSCK_c           3'd1
`define tDQSCKMAX_c        3'd1

`define tDINIT0_c          20'd533334
`define tDINIT1_c          9'd384      
`define tDINIT2_c          18'd213334
`define tDINIT3_c          11'd800  
    
`define pTPLLFFCGS         12'd854
`define pTPLLFFCRGS        10'd427      
`define pTPLLFRQSEL        6'd8
`define pTPLLRLCK          14'd5336

// these are values that are used during short SDRAM initialization
// i.e used everytime except for testcase runs with full SDRAM initialization
`define tBCSTAB_c_ssi      14'd32
`define tDLLLOCK_c_ssi     12'd20
`define tDINIT0_c_ssi      20'd100
`ifndef DDR4
`define tDINIT1_c_ssi      9'd160      
`else
`define tDINIT1_c_ssi      9'd360     // tRFCmin(260) + 5ns + 10ns divided by small `CLK_PRD=0.833
`endif
`ifdef LPDDR2      
  `define tDINIT2_c_ssi    18'd110
  `define tDINIT3_c_ssi    11'd150
`else
  `define tDINIT2_c_ssi    18'd80
  `ifdef DDR4      
    `ifdef MICRON_DDR
      `define tDINIT3_c_ssi  11'd1024
    `else
      `define tDINIT3_c_ssi  11'd1024
     `endif
  `else
    `define tDINIT3_c_ssi  11'd800
  `endif
`endif

// refresh period tolerance to cater for internal pipeline:
// this number must be subtracted from the programmed tolerance
`ifdef sg2
  // gDDR2
  `define RFSH_PRD_TOL     400
`else
  `define RFSH_PRD_TOL     200
`endif

// default (reset) vaues of registers
// (see PUB datasheet for definitions)
`define RIDR_DEFAULT      32'h0010_0100 //DDRG2MPHY: Changed from 32'h0000_0100
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define PIR_DEFAULT       32'h6000_0000
`else
  `define PIR_DEFAULT       32'h0000_0000
 `endif
`ifdef DWC_PUB_CLOCK_GATING
`define   CGCR_DEFAULT      32'h0000_00ff
 `endif

`define CGCR1_DEFAULT     32'h0000_0000

`ifdef DWC_DDRPHY_X4X2
  `define PGCR0_DEFAULT     32'h7FD8_1E00 //need to define this value if X4X2 mode
`else
 `define PGCR0_DEFAULT     32'h07D8_1E00
`endif

`define PGCR1_DEFAULT     32'h0200_4620
`define PGCR2_DEFAULT     32'h0001_2480
`define PGCR3_DEFAULT     32'hC0AA_0040
`define PGCR4_DEFAULT     32'h4000_0000
`define PGCR5_DEFAULT     32'h0101_0000
`define PGCR6_DEFAULT     32'h0001_3000
`define PGCR7_DEFAULT     32'h0004_0000
`define PGCR8_DEFAULT     32'h0000_0100
`define PGSR0_DEFAULT     32'h0000_0000
`define PGSR1_DEFAULT     32'h0000_0000
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define PLLCR_DEFAULT     32'h0000_0000
`else
  `ifdef DWC_DDRPHY_PLL_TYPEB
  `define PLLCR0_DEFAULT    32'h001C_0000
  `define PLLCR1_DEFAULT    32'h0000_0000
  `define PLLCR2_DEFAULT    32'h0000_0000
  `define PLLCR3_DEFAULT    32'h0000_0000
  `define PLLCR4_DEFAULT    32'h0000_0000
  `define PLLCR5_DEFAULT    32'h0000_0000
  `else
  `define PLLCR_DEFAULT     32'h0003_8000
  `endif
  
`endif
`define PTR0_DEFAULT      32'h42C2_1590
`define PTR1_DEFAULT      32'h682B_12C0
`define PTR2_DEFAULT     32'h0008_3DEF
`define PTR3_DEFAULT      ({{3{1'b0}}, `tDINIT1_c, `tDINIT0_c})
`define PTR4_DEFAULT      ({{4{1'b0}}, `tDINIT3_c, `tDINIT2_c})
`define PTR5_DEFAULT      ({`pTPLLFRQSEL, {2{1'b0}}, `pTPLLFFCRGS, {2{1'b0}}, `pTPLLFFCGS})
`define PTR6_DEFAULT      ({{18{1'b0}}, `pTPLLRLCK})

`define ACMDLR0_DEFAULT   32'h0000_0000
`define ACMDLR1_DEFAULT   32'h0000_0000
`define ACLCDLR_DEFAULT   32'h0000_0000

`define ACBDLR0_DEFAULT   32'h0000_0000
`define ACBDLR1_DEFAULT   32'h0000_0000
`define ACBDLR2_DEFAULT   32'h0000_0000
`define ACBDLR3_DEFAULT   32'h0000_0000
`define ACBDLR4_DEFAULT   32'h0000_0000
`define ACBDLR5_DEFAULT   32'h0000_0000
`define ACBDLR6_DEFAULT   32'h0000_0000
`define ACBDLR7_DEFAULT   32'h0000_0000
`define ACBDLR8_DEFAULT   32'h0000_0000
`define ACBDLR9_DEFAULT   32'h0000_0000
`define ACBDLR10_DEFAULT  32'h0000_0000
`define ACBDLR11_DEFAULT  32'h0000_0000
`define ACBDLR12_DEFAULT  32'h0000_0000
`define ACBDLR13_DEFAULT  32'h0000_0000
`define ACBDLR14_DEFAULT  32'h0000_0000

`define RANKIDR_DEFAULT   32'h0000_0000

`define RIOCR0_DEFAULT    {4'h0, (12'h000|{`DWC_PHY_CS_N_WIDTH{1'b1}}), 4'h0, 12'h0}
`define RIOCR1_DEFAULT    {(8'h00|{`DWC_PHY_ODT_WIDTH{1'b1}}), 8'h00, (8'h00|{`DWC_PHY_CKE_WIDTH{1'b1}}), 8'h00}
`define RIOCR2_DEFAULT    32'h0000_0000
`define RIOCR3_DEFAULT    32'h0000_0000
`define RIOCR4_DEFAULT    32'h0000_0000
`define RIOCR5_DEFAULT    32'h0000_0000

//DDRG2MPHY: Chnaged the bit[1] from 1 to 0
`define ACIOCR0_DEFAULT   {6'b001100, 4'h0, 8'b0000_0000, (4'b0000 |{`DWC_CK_WIDTH{1'b1}}), 10'h010}
`define ACIOCR1_DEFAULT    32'h0000_0000
`define ACIOCR2_DEFAULT    32'h0000_0000
`define ACIOCR3_DEFAULT    32'h0000_0000
`define ACIOCR4_DEFAULT    32'h0000_0000
`define ACIOCR5_DEFAULT    32'h0000_0000

`define DXCCR_DEFAULT      32'h20C0_1884

`define DSGCR_DEFAULT      {{9{1'b0}},|(`DWC_RRRMODE_DFLT),3'b100,|(`DWC_WRRMODE_DFLT),2'b00,16'h401B}

`define DCR_DEFAULT       32'h0000_040B
`define DCR_LPDDR3        32'h0000_0409

// ********************************* //
// ** GEN 3 MPHY DTPR DEFINITIONS ** //
// ********************************* //
`define DTPR0_DEFAULT     {4'd0, `tRRD_c ,1'd0, `tRAS_c ,1'd0, `tRP_c ,4'd0, `tRTP_c }
`define DTPR1_DEFAULT     {2'd0, `tWLMRD_c ,2'd0, `tFAW_c ,5'd0,3'd4,3'd0, `tMRD_c }
`define DTPR2_DEFAULT     {3'd0,1'b0,3'd0,1'b0,4'd0, `tCKE_c ,6'd0, `tXS_c }
`define DTPR3_DEFAULT     {3'b0,3'd0, `tDLLK_c ,5'd0, `tDQSCKMAX_c , 5'd0, `tDQSCK_c }
`define DTPR4_DEFAULT     {2'd0,2'd0,3'd0, `tRFC_min_c ,4'd0, `tWLO_c ,3'd0, `tXP_c }
`define DTPR5_DEFAULT     {8'd0, `tRC_c ,1'd0, `tRCD_c ,3'd0, `tWTR_c }
`define DTPR6_DEFAULT     {2'd0, 14'd0 ,3'd0, 5'd5 ,3'd0, 5'd5}

`define SCHCR0_DEFAULT    32'h0000_0000
`define SCHCR1_DEFAULT    32'h0000_0000

`define MR0_DEFAULT       32'h0000_0A52
`define MR1_DEFAULT       32'h0000_0000
`define MR2_DEFAULT       32'h0000_0000
`define MR3_DEFAULT       32'h0000_0000
`define MR4_DEFAULT       32'h0000_0000

`ifdef LPDDR2
  `define MR5_DEFAULT       32'h0000_0000
  `define MR6_DEFAULT       32'h0000_0000
`else
  `ifdef LPDDR3
    `define MR5_DEFAULT     32'h0000_0000
    `define MR6_DEFAULT     32'h0000_0000
  `else 
    `define MR5_DEFAULT     32'h0000_0400
  ` define MR6_DEFAULT      32'h0000_0400
  `endif 
`endif 
`define MR7_DEFAULT       32'h0000_0000
`define MR11_DEFAULT      32'h0000_0000

//`define ODTCR_DEFAULT     {(4'h8 & {`DWC_NO_OF_RANKS{1'b1}}),(4'h4 & {`DWC_NO_OF_RANKS{1'b1}}), \
//                           (4'h2 & {`DWC_NO_OF_RANKS{1'b1}}),(4'h1 & {`DWC_NO_OF_RANKS{1'b1}}), \
//                            16'h0000}

`define ODTCR_DEFAULT     {4'h0, 12'h001, 4'h0, 12'h000}

`define AACR_DEFAULT      32'h0000_00FF

`ifdef DWC_DDRPHY_EMUL_XILINX
  `define DTCR0_DEFAULT      32'h10000001
  `define DTCR1_DEFAULT      {(16'h0000|{`DWC_NO_OF_LRANKS{1'b1}}), 4'd0, 4'b1000, 4'd0, 4'b0000}
`else
  `define DTCR0_DEFAULT      32'h8000b087
  `define DTCR1_DEFAULT      {(16'h0000|{`DWC_NO_OF_LRANKS{1'b1}}), 4'd0, 4'b1010, 4'd3, 4'b0111}
`endif

`define DTAR0_DEFAULT     32'h0400_0000
`define DTAR1_DEFAULT     32'h0001_0000
`define DTAR2_DEFAULT     32'h0003_0002

`define DTDR0_DEFAULT     32'hDD22EE11
`define DTDR1_DEFAULT     32'h7788BB44

`define UDDR0_DEFAULT     32'h00000000
`define UDDR1_DEFAULT     32'h00000000

`ifdef DWC_DDRPHY_EMUL_XILINX 
  `define DTEDR0_DEFAULT    32'hFFFF_FFFF
`else
  `define DTEDR0_DEFAULT    32'h0000_0000
`endif
`define DTEDR1_DEFAULT    32'h0000_0000

`define RDIMMGCR0_DEFAULT 32'h3C41_0000

`define RDIMMGCR2_DEFAULT 32'h03FF_FFBF
`define RDIMMCR0_DEFAULT  `DWC_RDIMMCR0_DFLT
`define RDIMMCR1_DEFAULT  `DWC_RDIMMCR1_DFLT
`define RDIMMCR2_DEFAULT  32'h0000_0000
`define RDIMMCR3_DEFAULT  32'h0000_0000
`define RDIMMCR4_DEFAULT  32'h0000_0000

`define GPR0_DEFAULT      `DWC_GPR0_DFLT
`define GPR1_DEFAULT      `DWC_GPR1_DFLT

`define VTDR_DEFAULT      32'h3F00_3F00
`define CATR0_DEFAULT     32'h0014_1054
`define CATR1_DEFAULT     32'h0103_aaaa
`define DQSDR0_DEFAULT    32'h0000_0000
`define DQSDR1_DEFAULT    32'h0000_0000
`define DQSDR2_DEFAULT    32'h0000_0000

`define DCUAR_DEFAULT     32'h0000_0000
`define DCUDR_DEFAULT     32'h0000_0000
`define DCURR_DEFAULT     32'h0000_0000
`define DCULR_DEFAULT     32'hF000_0000
`define DCUGCR_DEFAULT    32'h0000_0000
`define DCUTPR_DEFAULT    32'h0000_0000
`define DCUSR0_DEFAULT    32'h0000_0000
`define DCUSR1_DEFAULT    32'h0000_0000
                          
`define BISTRR_DEFAULT    32'h03DE_0000
`define BISTMSKR0_DEFAULT 32'h0000_0000
`define BISTMSKR1_DEFAULT 32'h0000_0000
`define BISTMSKR2_DEFAULT 32'h0000_0000
`define BISTWCR_DEFAULT   32'h0000_0020
`define BISTLSR_DEFAULT   32'h1234_ABCD
`define BISTAR0_DEFAULT   32'h0000_0000
`define BISTAR1_DEFAULT   32'h000F_0000
`define BISTAR2_DEFAULT   32'hF000_0FFF
`define BISTAR3_DEFAULT   32'h0000_0000
`define BISTAR4_DEFAULT   32'h0003_FFFF
`define BISTUDPR_DEFAULT  32'hFFFF_0000
`define BISTGSR_DEFAULT   32'h0000_0000
`define BISTWER0_DEFAULT  32'h0000_0000
`define BISTWER1_DEFAULT  32'h0000_0000
`define BISTBER0_DEFAULT  32'h0000_0000
`define BISTBER1_DEFAULT  32'h0000_0000
`define BISTBER2_DEFAULT  32'h0000_0000
`define BISTBER3_DEFAULT  32'h0000_0000
`define BISTBER4_DEFAULT  32'h0000_0000
`define BISTBER5_DEFAULT  32'h0000_0000
`define BISTWCSR_DEFAULT  32'h0000_0000
`define BISTFWR0_DEFAULT  32'h0000_0000
`define BISTFWR1_DEFAULT  32'h0000_0000
`define BISTFWR2_DEFAULT  32'h0000_0000
`define VTCR0_DEFAULT     32'h7003_2019
`define VTCR1_DEFAULT     32'h0FC0_0072
`define IOVCR0_DEFAULT    32'h0F00_0009
`define IOVCR1_DEFAULT    32'h0000_0109

    
//DDRG2MPHY: commented below 6 lines
//  `define ZQNCR0_DEFAULT  32'h4000_1830

`ifdef DWC_DDRPHY_EMUL_XILINX
  `define ZQCR_DEFAULT      32'h0000_0000 
  `define ZQNPR_DEFAULT     32'h0000_0000
`else
  `define ZQCR_DEFAULT      32'h0005_8D00 
  `define ZQNPR_DEFAULT     32'h0007_BB00
`endif

`define ZQNDR_DEFAULT     32'h3838_3030
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define ZQNSR_DEFAULT     32'h0000_0000
`else
  `define ZQNSR_DEFAULT     32'h0000_0200
`endif

`define DXNGCR0_DEFAULT   32'h4000_0205
`define DXNGCR1_DEFAULT   32'h0000_0000
`define DXNGCR2_DEFAULT   32'h0000_0000
`define DXNGCR3_DEFAULT   32'hFFFC_0000
`define DXNGCR4_DEFAULT   32'h0E00_003c
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define DXNGCR5_DEFAULT   32'h0000_0000
  `define DXNGCR6_DEFAULT   32'h0000_0000
`else
  `ifdef DWC_NO_VREF_TRAIN                                                     
    `define DXNGCR5_DEFAULT   32'h0000_0000
    `define DXNGCR6_DEFAULT   32'h0000_0000
  `else
    `define DXNGCR5_DEFAULT   32'h0909_0909
    `define DXNGCR6_DEFAULT   32'h0909_0909
  `endif
`endif
`ifdef DWC_DDRPHY_X4X2
  `ifdef DWC_DDRPHY_X8_only
    `define DXNGCR7_DEFAULT   32'h0000_0000
    `define DXNGCR8_DEFAULT   32'h0000_0000
    `define DXNGCR9_DEFAULT   32'h0000_0000
  `else
    `define DXNGCR7_DEFAULT   32'h0081_0000
    `define DXNGCR8_DEFAULT   32'h0909_0909
    `define DXNGCR9_DEFAULT   32'h0909_0909
  `endif
`else // normal x8
  `define DXNGCR7_DEFAULT   32'h0000_0000
  `define DXNGCR8_DEFAULT   32'h0000_0000
  `define DXNGCR9_DEFAULT   32'h0000_0000
`endif

`define DXNGSR0_DEFAULT   32'h0000_0000
`define DXNGSR1_DEFAULT   32'h0000_0000
`define DXNGSR2_DEFAULT   32'h0000_0000
`define DXNGSR3_DEFAULT   32'h0000_0000
`define DXNGSR4_DEFAULT   32'h0000_0000
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define DXNGSR5_DEFAULT   32'h0040_0000
`else 
  `define DXNGSR5_DEFAULT   32'h0000_0000
`endif
`define DXNGSR6_DEFAULT   32'h0000_0000

`define DXNBDLR0_DEFAULT  32'h0000_0000
`define DXNBDLR1_DEFAULT  32'h0000_0000
`define DXNBDLR2_DEFAULT  32'h0000_0000
`define DXNBDLR3_DEFAULT  32'h0000_0000
`define DXNBDLR4_DEFAULT  32'h0000_0000
//DDRG2MPHY: added DXnBDLR5-6
`ifdef DWC_DDRPHY_EMUL_XILINX
  `ifdef DWC_DDRPHY_EMUL_XV7
    `define DXNBDLR5_DEFAULT  (32'h0000_0000|{`DWC_NO_OF_RANKS{8'h00}})
    `define DXNBDLR6_DEFAULT  (32'h0000_0000|{`DWC_NO_OF_RANKS{8'h00}})
  `else
    `define DXNBDLR5_DEFAULT  (32'h0000_0000|{`DWC_NO_OF_RANKS{8'h03}})
    `define DXNBDLR6_DEFAULT  (32'h0000_0000|{`DWC_NO_OF_RANKS{8'h03}})
  `endif
`else
  `define DXNBDLR5_DEFAULT  32'h0000_0000
  `define DXNBDLR6_DEFAULT  32'h0000_0000
`endif
`define DXNBDLR7_DEFAULT  32'h0000_0000
`define DXNBDLR8_DEFAULT  32'h0000_0000
`define DXNBDLR9_DEFAULT  32'h0000_0000

`define DXNLCDLR0_DEFAULT 32'h0000_0000
`define DXNLCDLR1_DEFAULT 32'h0000_0000
`define DXNLCDLR2_DEFAULT 32'h0000_0000
`define DXNLCDLR3_DEFAULT 32'h0000_0000
`define DXNLCDLR4_DEFAULT 32'h0000_0000
`ifdef DWC_DDRPHY_EMUL_XILINX
  `define DXNLCDLR5_DEFAULT 32'h0000_0000
`else
  `define DXNLCDLR5_DEFAULT 32'h0000_0000
`endif

`define DXNMDLR0_DEFAULT  32'h0000_0000
`define DXNMDLR1_DEFAULT  32'h0000_0000

`ifdef DWC_DDRPHY_X4X2
  `ifdef DWC_DDRPHY_X8_only
    `define DXNGTR0_DEFAULT   32'h0002_0000
  `else
    `define DXNGTR0_DEFAULT   32'h0022_0000
  `endif
`else
  `define DXNGTR0_DEFAULT   32'h0002_0000
`endif

`define DXNRSR0_DEFAULT   32'h0000_0000
`define DXNRSR1_DEFAULT   32'h0000_0000
`define DXNRSR2_DEFAULT   32'h0000_0000
`define DXNRSR3_DEFAULT   32'h0000_0000


// for fast simulation shorter initialization times are used
`define PTR0_TPLLPD_DFLT     11'h2F0
`define PTR0_TPLLGS_DFLT     15'h060
`define PTR1_TPLLRST_DFLT    13'h05F0
`define PTR1_TPLLLCK_DFLT    17'h0080
`define TPLLFFCGS_DFLT       12'd854
`define TPLLFFCRGS_DFLT      10'd427
`define TPLLRLCK_DFLT        14'd5336
// default (reset) vaues of registers
// (see controller datasheet for definitions)
`define CDCR_DEFAULT      32'h000004D2
`define DRR_DEFAULT       ({1'b1, {9{1'b0}}, 4'b0001, `tRFC_max_c})
`define RSLR_DEFAULT      32'h00000000
`define MR_DEFAULT        32'h00000A52
`define EMR_DEFAULT       32'h00000000
`define EMR2_DEFAULT      32'h00000000
`define EMR3_DEFAULT      32'h00000000
`define EMR1_DEFAULT      `EMR_DEFAULT

// word burst of 4 or 2
`define B4                1'b0        // word burst of 4 (default)
`define B2                1'b1        // word burst of 2

// SDRAM or register access
`define MEM_ACCESS        1'b0        // DDR SDRAM access
`define REG_ACCESS        1'b1        // controller register access
`define DIRECT_ACCESS     1'b1        // direct SDRAM array access

// test modes {scan_ms, test_mode}
`define MISSION_MODE      3'b000       // normal (mission) mode
`define IDDQ_MODE         3'b001       // IDDQ test mode
`define DLL_MONITOR       3'b010       // monitor DLL output
`define SCAN_MODE         3'b100       // scan test mode


// DDR SDRAM memory sizes
// ---------------------
// miscellaneous DDR SDRAM size parameters
`define NO_OF_BANKS       8 // up to 8 banks
`define BANK_DEPTH        (1<<`DWC_ADDR_WIDTH)
`define MEM_DEPTH         (`NO_OF_BANKS*`BANK_DEPTH)
`define MEM_WIDTH         `DWC_DATA_WIDTH
`define NO_OF_BYTES       (`DWC_DATA_WIDTH/8) // bytes in each word

// number of PHY lanes includes the data bytes + command lane
`define NO_OF_LANES       `DWC_NO_OF_BYTES + 1

`define ZCTRL_0           0 // impedance controller 0
`define ZCTRL_1           1 // impedance controller 1
`define ZCTRL_2           2 // impedance controller 2
`define ZCTRL_3           3 // impedance controller 3
`define ALL_ZCTRL         1 // all impedance controllers
`define CMDQ_DEPTH        8 // depth of controller command queues
  
// pin IDs
// -------
`define CK_PIN            6'b000000    // ck   : SDRAM CK clock
`define CKb_PIN           6'b000001    // ckb  : SDRAM CK# clock
`define CKE_PIN           6'b000010    // cke  : SDRAM clock enable
`define ODT_PIN           6'b000011    // odt  : SDRAM on-die termination
`define CSb_PIN           6'b000100    // csb  : SDRAM chip select
`define RASb_PIN          6'b000101    // rasb : SDRAM row address select
`define CASb_PIN          6'b000110    // casb : SDRAM column address select
`define WEb_PIN           6'b000111    // web  : SDRAM write enable
`define BA_PIN            6'b001000    // ba   : SDRAM bank address
`define A_PIN             6'b001001    // a    : SDRAM address
`define DM_PIN            6'b001010    // dm   : SDRAM data mask
`define DQS_PIN           6'b001011    // dqs  : SDRAM data strobe
`define DQSb_PIN          6'b001100    // dqsb : SDRAM data strobe #
`define DQ_PIN            6'b001101    // dq   : SDRAM data parity
                                      
`define RQVLD_PIN         6'b010000    // rqvld: request valid
`define CMD_PIN           6'b010001    // cmd  : command bus
`define RWBA_PIN          6'b010010    // rwba : read/write bank address
`define RWA_PIN           6'b010011    // rwa  : read/write address
`define D_PIN             6'b010101    // d    : data input
`define RQACK_PIN         6'b010111    // rqack: request acknowledge
`define QVLD_PIN          6'b011000    // qvld : data output valid
`define Q_PIN             6'b011001    // q    : data output
`define TAG_PIN           6'b011100    // tag  : tag input  
`define QTAG_PIN          6'b011101    // qtag : read tag output
`define WTAG_PIN          6'b011110    // wtag : write tag output

`define JTAG_RQVLD_PIN    6'b011111    // jtag rqvld: jtag request valid
`define JTAG_CMD_PIN      6'b100000    // jtag cmd  : jtag command bus
`define JTAG_D_PIN        6'b100001    // jtag d    : jtag data input
`define JTAG_A_PIN        6'b100010    // jtag a    : jtag SDRAM address
`define JTAG_QVLD_PIN     6'b100011    // jtag qvld : jtag data output valid
`define JTAG_Q_PIN        6'b100100    // jtag q    : jtag data output
`define ACTb_PIN          6'b100101    // actb : DDR4 SDRAM activate select

`define CQ_CLOCK          1'b0
`define CQb_CLOCK         1'b1

// transaction types
`define CHIP_CTRL         4'b0000      // between chip and controller
`define CTRL_SDRAM        4'b0001      // between controller and SDRAM
`define CHIP_PORT         4'b0010      // on the chip external port
`define CHIP_CFG          4'b0011      // between chip and controller configuration
`define CTRL_ACLB         4'b0100      // between controller and the PHY AC loopback
`define JTAG_CFG          4'b0101      // between chip and JTAG interface
`define CTRL_RDIMM        4'b0110      // between controller and RDIMM buffer chip
`define SYS_OP            4'b0111      // system operations
`define CHIP_CTRL_1       4'b1000      // between chip and controller 1
  
// error and warning types  
`define QERR              0           // read data (Q) error (mismatch)
`define SCANERR           4           // scan data mismatch
`define CTRLPINERR        5           // controller interface pin error (mismatch)
`define UNKNOWN_BANKS     6           // undefined bank selected for access
`define UNDFND_DDRRW      7           // undefined DDR access command
`define UNDFND_REGRW      8           // undefined controller register access command
`define BADSTIMULI        10          // bad testcase stimuli
`define UNKNOWN_REG       11          // Illegal register selected
`define RDCNTERR          13          // read count error
`define INITCMDERR        14          // initialization command sequence error
`define CMDTIMEERR        15          // command-to-command timing error
`define INITDATAERR       16          // initialization data error
`define INITWAITERR       17          // initialization wait time error
`define RFSHCMDERR        18          // auto_refresh command sequence error
`define RFSHPRDERR        19          // refresh period error
`define CHIPFLGERR        20          // chip flag error
`define RFSHNEVER         21          // refresh never happens
`define ODTERR            22          // ODT asserted too late in a write cycle
`define QTAGERR           23          // read output tag error
`define WTAGERR           24          // write tag error
`define TAGCNTERR         25          // write tag count error
`define WLERR             26          // write leveling error
`define ACLBERR           27          // AC loopback error
`define RTTERR            28          // RTT asserted incorrectly
`define RDIMM3CS          29          // RDIMM register write has 3 CS# bits asserted
`define PARERR            30          // RDIMM parity error (unexpected)
  
`define WARN_BASEID       32          // warnings start at this ID
`define DATAXWARN         33          // signal has X's or Z's
                                      // checking is turned off by testcase
`define CONCUR_DDRREG     35          // concurrent DDR and register access

// type of data patterns to generate
`define ALL_ZEROS         0           // D[n] = "0000", "0000", "0000" ...
`define ALL_ONES          1           // D[n] = "1111", "1111", "1111" ... 
`define ZEROS_ONES        2           // D[n] = "0000", "1111", "0000" ... 
`define WALKING_ONES      3           // D[n] = "0001", "0010", "0100" ... 
`define WALKING_ZEROS     4           // D[n] = "1110", "1101", "1011" ... 
`define SEQUENTIAL_DATA   5           // D[n] = x, x+1, x+2, ...
`define INCR_BY_2_DATA    6           // D[n] = x, x+2, x+4, ...
`define ALL_AAAA_DATA     7           // D[n] = "AAAA", "AAAA", "AAAA" ...
`define ALL_5555_DATA     8           // D[n] = "5555", "5555", "5555" ...
`define SEQUENTIAL_BYTES  9           // D[n] = "1111", "2222", "3333" ...
`define RANDOM_DATA       10          // D[n] = random
`define SAME_DATA         11          // D[n] are all the same (input)
`define TOGGLE_DATA       12          // D[n] are toggling data (input)
`define PREDFND_DATA      13          // D[n] = 0, 1, 2, latency-1, latency, ...
`define PORT_ID_DATA      14          // D[n] = "0101", "0101", "0101" ...
`define PORT_RANDOM_DATA  15          // D[n] = random + port id

// name of data pattern
`define DATA_PATTERN      0           // data pattern
`define ADDR_PATTERN      1           // address pattern
`define BANK_PATTERN      2           // bank pattern

// maximum pattern width (the bigger of data, address, or bank widths)
`define PAT_WIDTH         `DATA_WIDTH
`define MAX_PAT_NIBBLES   (`PAT_WIDTH/4)
`define MAX_PAT_BYTES     (`PAT_WIDTH/8)

`define MAX_RWDATA_DEPTH  4096        //**TBD**

`define RANDOM_NIBBLE     16          // randomly choose the nibble

// maximum number of unique locations for automatic checking of expected read
// results; this determines the size of the associative array used to
// mimick the SDRAM in the golden reference model
//`define MAX_MEM_LOCATIONS   10000
`define MAX_MEM_LOCATIONS 1200000

// maximum number of write data bursts that can be stored in the memory of the
// SDRAM model (2^this)
`define SDRAM_MEM_BITS    17

// cycle type
`define EVEN_CYCLES       0
`define ODD_CYCLES        1
`define ALL_CYCLES        2

// address type
`define NEXT_ADDR         0
`define PREV_ADDR         1
`define RND_ADDR          2

// method used for bypassing initialization
`define USE_PIN           1'b0
`define USE_REG           1'b1

// width and depth of stimulus vectors
//  - data + address + command + tag + request valids for all ports
//    (no tag for config port, and only 1-bit command and request valid)
`define HOST_TAG_WIDTH    1
`define CTRL_DATA_WIDTH   (`DATA_WIDTH+`BYTE_WIDTH)
`define HOST_VEC_WIDTH    (`CTRL_DATA_WIDTH+`HOST_ADDR_WIDTH+`CMD_WIDTH+`HOST_TAG_WIDTH+`NO_OF_PORTS)
`define CFG_VEC_WIDTH     (`REG_DATA_WIDTH+`REG_ADDR_WIDTH+`REG_CMD_WIDTH+1)
`define MAX_VEC_DEPTH     10000


// host BFMs and monitors
// -----------------------
`define MNT_CFG_WIDTH     5  // width of monitors configuration bus
`define CTRL_HOST_PORT    `NO_OF_PORTS   // host port on DDR controller
`define ALL_PORTS         `NO_OF_PORTS+1 // all host ports


// compiled SDRAM parameters
// -------------------------
// DDR mode
`define DDR_MODE_WIDTH    3
`define LPDDR2_MODE       3'b000
`define LPDDR3_MODE       3'b001
`define DDR2_MODE         3'b010
`define DDR3_MODE         3'b011
`define DDR4_MODE         3'b100

`ifdef DDR2       
  `define DDR_MODE        `DDR2_MODE
`endif       
`ifdef DDR3       
  `define DDR_MODE        `DDR3_MODE
`endif       
`ifdef DDR4       
  `define DDR_MODE        `DDR4_MODE
`endif       
`ifdef LPDDR2       
  `define DDR_MODE        `LPDDR2_MODE
`endif

`ifdef LPDDR3
 `define DDR_MODE         `LPDDR3_MODE
`endif 

`define LPDDR3_NO_TERM    0
`define LPDDR3_MID_TERM   1
`define LPDDR3_TERM       2
                                                     
// burst length
`ifdef BL_2
  `define BURST_LEN        3'b001
  `define BURST_DATA_WIDTH (1*`DATA_WIDTH)
  `define BURST_BYTE_WIDTH (1*`BYTE_WIDTH)
  `define BURST_ADDR_INC   2          
  `define BURST_ADDR_MSB   0          
`endif                                                                                 
`ifdef BL_4
  `ifdef DDR3
    `define BURST_LEN 2'b10
  `else
    `ifdef DDR4
      `define BURST_LEN 2'b10
    `else
      `define BURST_LEN 3'b010
    `endif
  `endif
  `define BURST_DATA_WIDTH (2*`DATA_WIDTH)
  `define BURST_BYTE_WIDTH (2*`BYTE_WIDTH)
  `define BURST_ADDR_INC   4          
  `define BURST_ADDR_MSB   1          
`endif
`ifdef BL_8
  `ifdef DDR3
    `define BURST_LEN 2'b00
  `else
    `ifdef DDR4
      `define BURST_LEN 2'b00
    `else
      `define BURST_LEN 3'b011
    `endif
  `endif
  `define BURST_DATA_WIDTH (4*`DATA_WIDTH)
  `define BURST_BYTE_WIDTH (4*`BYTE_WIDTH)
  `define BURST_ADDR_INC   8          
  `define BURST_ADDR_MSB   2          
`endif
`ifdef BL_16
  `define BURST_LEN 3'b100
  `define BURST_DATA_WIDTH (8*`DATA_WIDTH)
  `define BURST_BYTE_WIDTH (8*`BYTE_WIDTH)
  `define BURST_ADDR_INC   16         
  `define BURST_ADDR_MSB   3          
`endif
`ifdef BL_V
  `define BURST_LEN 2'b01
  `define BURST_DATA_WIDTH (4*`DATA_WIDTH)
  `define BURST_BYTE_WIDTH (4*`BYTE_WIDTH)
  `define BURST_ADDR_INC   8          
  `define BURST_ADDR_MSB   2          
`endif

`ifdef DDR4
  `ifdef CL_9
    `define CAS_LAT 4'b0000
    `define CAS_LATENCY 9                                                       
  `endif
  `ifdef CL_10
    `define CAS_LAT 4'b0001
    `define CAS_LATENCY 10                                                      
  `endif
  `ifdef CL_11
    `define CAS_LAT 4'b0010
    `define CAS_LATENCY 11                                                      
  `endif
  `ifdef CL_12
    `define CAS_LAT 4'b0011
    `define CAS_LATENCY 12                                                      
  `endif
  `ifdef CL_13
    `define CAS_LAT 4'b0100
    `define CAS_LATENCY 13                                                      
  `endif
  `ifdef CL_14
    `define CAS_LAT 4'b0101
    `define CAS_LATENCY 14                                                      
  `endif
  `ifdef CL_15
    `define CAS_LAT 4'b0110
    `define CAS_LATENCY 15                                                      
  `endif
  `ifdef CL_16
    `define CAS_LAT 4'b0111
    `define CAS_LATENCY 16                                                      
  `endif
  `ifdef CL_17
    `define CAS_LAT 4'b1101
    `define CAS_LATENCY 17                                                      
  `endif
  `ifdef CL_18
    `define CAS_LAT 4'b1000
    `define CAS_LATENCY 18                                                      
  `endif
  `ifdef CL_19
    `define CAS_LAT 4'b1110
    `define CAS_LATENCY 19                                                      
  `endif
  `ifdef CL_20
    `define CAS_LAT 4'b1001
    `define CAS_LATENCY 20                                                      
  `endif
  `ifdef CL_21
    `define CAS_LAT 4'b1111
    `define CAS_LATENCY 21                                                      
  `endif
  `ifdef CL_22
    `define CAS_LAT 4'b1010
    `define CAS_LATENCY 22                                                      
  `endif
  `ifdef CL_24
    `define CAS_LAT 4'b1011
    `define CAS_LATENCY 24                                                       
  `endif

  // CAS write latency
  `ifdef CWL_9
    `define CAS_WLAT 3'b000
  `endif
  `ifdef CWL_10
    `define CAS_WLAT 3'b001
  `endif
  `ifdef CWL_11
    `define CAS_WLAT 3'b010
  `endif
  `ifdef CWL_12
    `define CAS_WLAT 3'b011
  `endif
  `ifdef CWL_14
    `define CAS_WLAT 3'b100
  `endif
  `ifdef CWL_16
    `define CAS_WLAT 3'b101
  `endif
  `ifdef CWL_18
    `define CAS_WLAT 3'b110
  `endif
  `ifdef CWL_20
    `define CAS_WLAT 3'b111
  `endif

  // addtive CAS latency
  `ifdef AL_0
    `define ADD_LAT 2'b00
    `define ADD_LAT_VAL 0
  `endif
  `ifdef AL_1
    `define ADD_LAT 2'b01
    `define ADD_LAT_VAL (`CAS_LATENCY - 1)
  `endif
  `ifdef AL_2
    `define ADD_LAT 2'b10
    `define ADD_LAT_VAL (`CAS_LATENCY - 2)
  `endif
`endif


// CAS latency
`ifdef DDR3
  `ifdef CL_5
    `define CAS_LAT 4'b0010
    `define CAS_LATENCY 5                                                       
  `endif
  `ifdef CL_6
    `define CAS_LAT 4'b0100
    `define CAS_LATENCY 6                                                       
  `endif
  `ifdef CL_7
    `define CAS_LAT 4'b0110
    `define CAS_LATENCY 7                                                       
  `endif
  `ifdef CL_8
    `define CAS_LAT 4'b1000
    `define CAS_LATENCY 8                                                       
  `endif
  `ifdef CL_9
    `define CAS_LAT 4'b1010
    `define CAS_LATENCY 9                                                       
  `endif
  `ifdef CL_10
    `define CAS_LAT 4'b1100
    `define CAS_LATENCY 10                                                      
  `endif
  `ifdef CL_11
    `define CAS_LAT 4'b1110
    `define CAS_LATENCY 11                                                      
  `endif
  `ifdef CL_12
    `define CAS_LAT 4'b0001
    `define CAS_LATENCY 12                                                      
  `endif
  `ifdef CL_13
    `define CAS_LAT 4'b0011
    `define CAS_LATENCY 13                                                      
  `endif
  `ifdef CL_14
    `define CAS_LAT 4'b0101
    `define CAS_LATENCY 14                                                      
  `endif

  // CAS write latency
  `ifdef CWL_5
    `define CAS_WLAT 3'b000
  `endif
  `ifdef CWL_6
    `define CAS_WLAT 3'b001
  `endif
  `ifdef CWL_7
    `define CAS_WLAT 3'b010
  `endif
  `ifdef CWL_8
    `define CAS_WLAT 3'b011
  `endif
  `ifdef CWL_9
    `define CAS_WLAT 3'b100
  `endif
  `ifdef CWL_10
    `define CAS_WLAT 3'b101
  `endif
  `ifdef CWL_11
    `define CAS_WLAT 3'b110
  `endif
  `ifdef CWL_12
    `define CAS_WLAT 3'b111
  `endif

  // addtive CAS latency
  `ifdef AL_0
    `define ADD_LAT 2'b00
    `define ADD_LAT_VAL 0
  `endif
  `ifdef AL_1
    `define ADD_LAT 2'b01
    `define ADD_LAT_VAL (`CAS_LATENCY - 1)
  `endif
  `ifdef AL_2
    `define ADD_LAT 2'b10
    `define ADD_LAT_VAL (`CAS_LATENCY - 2)
  `endif
`endif

`ifdef DDR2
  `ifdef CL_3
    `define CAS_LAT 3'b011
  `endif
  `ifdef CL_4
    `define CAS_LAT 3'b100
  `endif
  `ifdef CL_5
    `define CAS_LAT 3'b101
  `endif
  `ifdef CL_6
    `define CAS_LAT 3'b110
  `endif

  `define CAS_WLAT 3'b000

  // addtive CAS latency
  `ifdef AL_0
    `define ADD_LAT 3'b000
  `endif
  `ifdef AL_1
    `define ADD_LAT 3'b001
  `endif
  `ifdef AL_2
    `define ADD_LAT 3'b010
  `endif
  `ifdef AL_3
    `define ADD_LAT 3'b011
  `endif
  `ifdef AL_4
    `define ADD_LAT 3'b100
  `endif
  `ifdef AL_5
    `define ADD_LAT 3'b101
  `endif
  `define ADD_LAT_VAL `ADD_LAT
`endif

`ifdef LPDDR3
  `ifdef CL_3
    `define CAS_LAT 4'b0001
  `endif
  `ifdef CL_6
    `define CAS_LAT 4'b0100
  `endif
  `ifdef CL_8
    `define CAS_LAT 4'b0110
  `endif
  `ifdef CL_9
    `define CAS_LAT 4'b0111
  `endif
  `ifdef CL_10
    `define CAS_LAT 4'b1000
  `endif
  `ifdef CL_11
    `define CAS_LAT 4'b1001
  `endif
  `ifdef CL_12
    `define CAS_LAT 4'b1010
  `endif
  `ifdef CL_14
    `define CAS_LAT 4'b1100
  `endif
  `ifdef CL_16
    `define CAS_LAT 4'b1110
  `endif


  `define CAS_WLAT 3'b000

  // addtive CAS latency
  `ifdef AL_0
    `define ADD_LAT 3'b000
  `endif
  `ifdef AL_1
    `define ADD_LAT 3'b001
  `endif
  `ifdef AL_2
    `define ADD_LAT 3'b010
  `endif
  `ifdef AL_3
    `define ADD_LAT 3'b011
  `endif
  `ifdef AL_4
    `define ADD_LAT 3'b100
  `endif
  `ifdef AL_5
    `define ADD_LAT 3'b101
  `endif
  `define ADD_LAT_VAL `ADD_LAT
`endif


`ifdef LPDDR2
  `ifdef CL_3
    `define CAS_LAT 4'b0001
  `endif
  `ifdef CL_4
    `define CAS_LAT 4'b0010
  `endif
  `ifdef CL_5
    `define CAS_LAT 4'b0011
  `endif
  `ifdef CL_6
    `define CAS_LAT 4'b0100
  `endif
  `ifdef CL_7
    `define CAS_LAT 4'b0101
  `endif
  `ifdef CL_8
    `define CAS_LAT 4'b0110
  `endif

  `define CAS_WLAT 3'b000

  // addtive CAS latency
  `ifdef AL_0
    `define ADD_LAT 3'b000
  `endif
  `ifdef AL_1
    `define ADD_LAT 3'b001
  `endif
  `ifdef AL_2
    `define ADD_LAT 3'b010
  `endif
  `ifdef AL_3
    `define ADD_LAT 3'b011
  `endif
  `ifdef AL_4
    `define ADD_LAT 3'b100
  `endif
  `ifdef AL_5
    `define ADD_LAT 3'b101
  `endif
  `define ADD_LAT_VAL `ADD_LAT
`endif

// if not specified on the command line, default ODT Rtt setting when running 
// testcases is 75 ohms for DDR2 and RZQ/4 for DDR3; 
`ifdef ODT_RTT
`else
  `define ODT_RTT         1 // RTT = 75 ohms (DDR2) or RZQ/4 (DDR3)
`endif

// during SDF annotated simulations of some processes, it may be necessary
// to delay the PHY reset signal to meet hold requirements on this signal
// (this is the case here because the PUB is not SDF-annotated)
`ifdef SDF_ANNOTATE
  `ifdef DWC_DDR_tsmc45gs
    `define PHYRSTN_HOLD_TIME 0.3
  `else
    `define PHYRSTN_HOLD_TIME 0.0
  `endif
`else
  `ifdef DWC_DDRPHY_ATPG_MODEL
    `define PHYRSTN_HOLD_TIME 0.3
  `else
    `define PHYRSTN_HOLD_TIME 0.0
  `endif
`endif

// default DQS gating delay
`ifdef SDF_ANNOTATE
  `ifdef SLOW_SDF
    `ifdef DDR2
      `define TSMC56GP_GDQS_DLY_DFLT 120
      `ifdef DWC_DDR_tsmc28hp
        `define GDQS_DLY_DFLT        120
      `endif
    `elsif DDR4  // DDR4
      `define TSMC56GP_GDQS_DLY_DFLT 140
      `ifdef DWC_DDR_tsmc28hp
        `define GDQS_DLY_DFLT        120
      `endif
    `else  // DDR3
      `define TSMC56GP_GDQS_DLY_DFLT 80
      `ifdef DWC_DDR_tsmc28hp
        `define GDQS_DLY_DFLT        120
      `endif
    `endif
  `else
    `ifdef DDR2
      `define TSMC56GP_GDQS_DLY_DFLT 240
    `elsif DDR4 
      `define TSMC56GP_GDQS_DLY_DFLT 260
    `else  // DDR3
      `define TSMC56GP_GDQS_DLY_DFLT 160
    `endif
  `endif

  // if doesn't require process-specific value, use TSMC65GP, otherwise define
  // above
  `ifdef GDQS_DLY_DFLT
  `else
    `define GDQS_DLY_DFLT   `TSMC56GP_GDQS_DLY_DFLT
  `endif
`else // !`ifdef SDF_ANNOTATE
  `ifdef DDR2
    `define GDQS_DLY_DFLT   140
    `ifdef DDR2_1066E 
      `define GDQS_DLY_DFLT  300
    `else 
      `ifdef DDR2_800D  
        `define GDQS_DLY_DFLT   140
      `else
        `ifdef DDR2_800E  
          `define GDQS_DLY_DFLT   140
        `else 
          `ifdef DDR2_667C  
            `define GDQS_DLY_DFLT  700
          `else 
            `ifdef DDR2_533C  
              `define GDQS_DLY_DFLT  700
            `else 
              `ifdef DDR2_400B  
                `define GDQS_DLY_DFLT   140
              `endif `endif `endif `endif `endif `endif
  `else
    // For LPDDR2 mode
    `ifdef LPDDR2
      `ifdef LPDDR2_1066 
        `define GDQS_DLY_DFLT  300
      `else 
        `ifdef LPDDR2_933  
          `define GDQS_DLY_DFLT   140
        `else 
          `ifdef LPDDR2_800  
            `define GDQS_DLY_DFLT   140
          `else 
            `ifdef LPDDR2_667  
              `define GDQS_DLY_DFLT  700
            `else 
              `ifdef LPDDR2_533  
                `define GDQS_DLY_DFLT  700
              `else 
                `ifdef LPDDR2_400  
                  `define GDQS_DLY_DFLT   140
                `else
                  `ifdef LPDDR2_250  
                    `define GDQS_DLY_DFLT   700
                  `endif `endif `endif `endif
                  `endif `endif `endif
    `else 
      // For DDR3 mode
      `ifdef DDR3
        `ifdef DDR3_2133K
          `define GDQS_DLY_DFLT   58
        `else
          `ifdef DDR3_1866J
            `define GDQS_DLY_DFLT   86
          `else
            `ifdef DDR3_1600G
              `define GDQS_DLY_DFLT   120 
            `else
              `ifdef DDR3_1333F
                `define GDQS_DLY_DFLT   148 
              `else
                `ifdef DDR3_1066E
                  `define GDQS_DLY_DFLT   184 
                `else
                  `ifdef DDR3_800D
                    `define GDQS_DLY_DFLT   268
                   `else
                     `ifdef DDR3_667C
                       `define GDQS_DLY_DFLT   280
                     `else  
                       `ifdef DDR3_DBYP
                         `define GDQS_DLY_DFLT   8000
                  `endif `endif `endif `endif `endif `endif
                `endif `endif
      `else
        // For DDR4 mode; Clock speed based on CL 
        `ifdef DDR4
         `ifdef DDR4_DBYP
           `define GDQS_DLY_DFLT   2000  // Calc of Delay in system.v TBD
         `else
           `ifdef CL_9                              
             `define GDQS_DLY_DFLT   304 
           `else
             `ifdef CL_10                              
               `define GDQS_DLY_DFLT   304 
             `else
               `ifdef CL_11                              
                 `define GDQS_DLY_DFLT   254 
               `else
                 `ifdef CL_12                              
                   `define GDQS_DLY_DFLT   254 
                 `else
                   `ifdef CL_13                              
                     `define GDQS_DLY_DFLT   216 
                   `else
                     `ifdef CL_14                             
                       `define GDQS_DLY_DFLT   216 
                     `else
                       `ifdef CL_15                             
                         `define GDQS_DLY_DFLT   168 
                       `else
                         `ifdef CL_16
                           `define GDQS_DLY_DFLT   190
                         `else
                           `ifdef CL_17
                             `define GDQS_DLY_DFLT   172
                           `else
                             `ifdef CL_18
                               `define GDQS_DLY_DFLT   172
                             `else
                               `ifdef CL_19
                                 `define GDQS_DLY_DFLT   190
                               `else
                                 `ifdef CL_20
                                   `define GDQS_DLY_DFLT   190
                                 `else
                                   `ifdef CL_24
                                     `define GDQS_DLY_DFLT   180
                               `endif `endif `endif `endif `endif
                               `endif `endif `endif `endif `endif
                               `endif `endif `endif
                               `endif
        `else
          `define GDQS_DLY_DFLT   60
        `endif
      `endif
    `endif
  `endif
`endif // !`ifdef SDF_ANNOTATE
                                                   


// delay line oscillator parameters
// --------------------------------
// process-specific expe
`ifdef SDF_ANNOTATE
   // TSMC 65nm GP
   `ifdef DWC_DDR_tsmc65gp
     `ifdef FAST_SDF
       `define AC_DL_OSC_HI 6.51
       `define AC_DL_OSC_LO 6.60
       `define DX_DL_OSC_HI 4.58
       `define DX_DL_OSC_LO 4.56
     `endif
     `ifdef TYPICAL_SDF
       `define AC_DL_OSC_HI 9.66
       `define AC_DL_OSC_LO 9.78
       `define DX_DL_OSC_HI 6.81
       `define DX_DL_OSC_LO 6.80
     `endif
     `ifdef SLOW_SDF
       `define AC_DL_OSC_HI 15.29
       `define AC_DL_OSC_LO 15.63
       `define DX_DL_OSC_HI 10.80
       `define DX_DL_OSC_LO 10.87
     `endif
   `endif

   // ST 55 LP
   `ifdef DWC_DDR_st55lp
     `ifdef FAST_SDF
       `define AC_DL_OSC_HI 6.51
       `define AC_DL_OSC_LO 6.60
       `define DX_DL_OSC_HI 4.58
       `define DX_DL_OSC_LO 4.56
     `endif
     `ifdef TYPICAL_SDF
       `define AC_DL_OSC_HI 9.66
       `define AC_DL_OSC_LO 9.78
       `define DX_DL_OSC_HI 6.81
       `define DX_DL_OSC_LO 6.80
     `endif
     `ifdef SLOW_SDF
       `define AC_DL_OSC_HI 15.29
       `define AC_DL_OSC_LO 15.63
       `define DX_DL_OSC_HI 10.80
       `define DX_DL_OSC_LO 10.87
     `endif
   `endif

   // SAMSUNG 45 LP
   `ifdef DWC_DDR_samsung45lp
     `ifdef FAST_SDF
       `define AC_DL_OSC_HI 6.51
       `define AC_DL_OSC_LO 6.60
       `define DX_DL_OSC_HI 4.58
       `define DX_DL_OSC_LO 4.56
     `endif
     `ifdef TYPICAL_SDF
       `define AC_DL_OSC_HI 9.66
       `define AC_DL_OSC_LO 9.78
       `define DX_DL_OSC_HI 6.81
       `define DX_DL_OSC_LO 6.80
     `endif
     `ifdef SLOW_SDF
       `define AC_DL_OSC_HI 15.29
       `define AC_DL_OSC_LO 15.63
       `define DX_DL_OSC_HI 10.80
       `define DX_DL_OSC_LO 10.87
     `endif
   `endif
`endif


// Num flyby delays
`ifdef SDRAMx32
  `define NUM_DEVICES ((`DWC_NO_OF_BYTES < 4) ? 1 : (`DWC_NO_OF_BYTES % 4 == 0) ? (`DWC_NO_OF_BYTES / 4) : ((`DWC_NO_OF_BYTES / 4) + 1))
`endif
`ifdef SDRAMx16
  `define NUM_DEVICES ((`DWC_NO_OF_BYTES < 2) ? 1 : (`DWC_NO_OF_BYTES % 2 == 0) ? (`DWC_NO_OF_BYTES / 2) : ((`DWC_NO_OF_BYTES / 2) + 1))
`endif
`ifdef SDRAMx8
  `define NUM_DEVICES `DWC_NO_OF_BYTES
`endif
`ifdef SDRAMx4
  `define NUM_DEVICES (`DWC_NO_OF_BYTES * 2)
`endif



// bus sizes of one SDRAM chip
// - data width, data mask width, and number of data strobes
`ifdef SDRAMx4
  `define SDRAM_DATA_WIDTH  4
  `define SDRAM_DM_WIDTH    1
  `define SDRAM_DS_WIDTH    1
  `define SDRAM_BYTE_WIDTH  1
  `define x4
`endif

`ifdef SDRAMx8
  `define SDRAM_DATA_WIDTH  8
  `define SDRAM_DM_WIDTH    1
  `define SDRAM_DS_WIDTH    1
  `define SDRAM_BYTE_WIDTH  1
  `define x8
`endif

`ifdef SDRAMx16
  `define SDRAM_DATA_WIDTH  16
  `define SDRAM_DM_WIDTH    2
  `define SDRAM_DS_WIDTH    2
  `define SDRAM_BYTE_WIDTH  2
  `define x16
`endif

`ifdef SDRAMx32
  `define SDRAM_DATA_WIDTH  32
  `define SDRAM_DM_WIDTH    4
  `define SDRAM_DS_WIDTH    4
  `define SDRAM_BYTE_WIDTH  4
  `define x32
`endif

`define SDRAM_PARITY_WIDTH  `SDRAM_DM_WIDTH

`ifndef LPDDRX
  `define SDRAM_ADDR_WIDTH    `SDRAM_ROW_WIDTH
`else
  `define SDRAM_ADDR_WIDTH    10
`endif

`define ADDR_WIDTH          (`SDRAM_BANK_WIDTH+`SDRAM_ROW_WIDTH+`SDRAM_COL_WIDTH+`SDRAM_RANK_WIDTH)


// Samsung/Qimonda/Hynix-specific defines
// Note: for testcases that disable bytes, chips that have multiple bytes
//       (x16/x32) need to be enabled together to simplify comparion
`ifdef SDRAMx4
  `define X4
  `define BYTE_INC          1
`endif
`ifdef SDRAMx8
  `define X8
  `define BYTE_INC          1
`endif
`ifdef SDRAMx16
  `define X16
  `define SDRAMx16or32
  `define BYTE_INC          2
`endif
`ifdef SDRAMx32
  `define X32
  `define SDRAMx16or32
  `define BYTE_INC          4
`endif

// DDR mode
`define MSD_DDR2            1'b0       // DDR2 device
`define MSD_DDR3            1'b1       // DDR3 device
`define MSD_DDR4            1'b1       // DDR4 device  ??

// DDR SDRAM chip density
`define MSD_DDR_256Mb       3'b000     // 256Mb SDRAM
`define MSD_DDR_512Mb       3'b001     // 512Mb SDRAM
`define MSD_DDR_1Gb         3'b010     // 1Gb   SDRAM
`define MSD_DDR_2Gb         3'b011     // 2Gb   SDRAM
`define MSD_DDR_4Gb         3'b100     // 4Gb   SDRAM
`define MSD_DDR_8Gb         3'b101     // 8Gb   SDRAM
`define MSD_DDR_16Gb        3'b110     // 16Gb  SDRAM
                              
// DDR SDRAM I/O width        
`define MSD_DDR_x4          2'b00      // 4-bit I/O width
`define MSD_DDR_x8          2'b01      // 8-bit I/O width
`define MSD_DDR_x16         2'b10      // 16-bit I/O width


// Controller/SDRAM Initialization
// -------------------------------
// full SDRAM initialization with all the wait times respected
`ifdef FULL_INIT
  `define FULL_SDRAM_INIT
`else
  `ifdef FULL_INIT_BYPASS
     `define FULL_SDRAM_INIT
   `endif
`endif

`ifdef FULL_SDRAM_INIT
  `define RDIMMGCR1_DEFAULT 32'h0000_0C80
`else                                                                                
  `define RDIMMGCR1_DEFAULT {20'h00000, `tBCSTAB_c_ssi}
`endif 

  // DIMM parameters
  // ---------------
  // maximum ranks per DIMM
`ifdef RDIMM_QUAD_RANK  
  `define DWC_MAX_RANKS_PER_DIMM  4
  `define DWC_CKE_PER_DIMM 2
  `define DWC_ODT_PER_DIMM 2
  `ifdef RDIMM_EQUAD_RANK
  `define DWC_CS_N_PER_DIMM 3
  `else
  `define DWC_CS_N_PER_DIMM 4
  `endif
`elsif RDIMM_DUAL_RANK   
  `define DWC_MAX_RANKS_PER_DIMM  2
  `define DWC_CKE_PER_DIMM 2
  `define DWC_ODT_PER_DIMM 2
  `define DWC_CS_N_PER_DIMM 2
`else
  `define DWC_MAX_RANKS_PER_DIMM  1
  `define DWC_CKE_PER_DIMM 1
  `define DWC_ODT_PER_DIMM 1
  `define DWC_CS_N_PER_DIMM 1
 `endif



`define DIRECT_DUAL_CS  1
`define DIRECT_QUAD_CS  2
`define ENCODED_QUAD_CS 3

`define DWC_NO_OF_DIMMS           (((`DWC_NO_OF_RANKS % `DWC_MAX_RANKS_PER_DIMM) == 0) ? \
                                   (`DWC_NO_OF_RANKS / `DWC_MAX_RANKS_PER_DIMM) : \
                                   (`DWC_NO_OF_RANKS / `DWC_MAX_RANKS_PER_DIMM) + 1)

  // number of ranks inside in each DIMM
`ifdef RDIMM_SINGLE_RANK  
  `define DWC_RANKS_PER_DIMM      1
`else
  `define DWC_RANKS_PER_DIMM      ((dwc_dim == (`DWC_NO_OF_DIMMS-1)) ? \
                                   (`DWC_NO_OF_RANKS - (dwc_dim*`DWC_MAX_RANKS_PER_DIMM)) : \
                                   `DWC_MAX_RANKS_PER_DIMM)
 `endif

// 3DS STACKS for TB Use

`ifdef DWC_NO_OF_3DS_STACKS
  `define NUM_3DS_STACKS `DWC_NO_OF_3DS_STACKS
`else 
  `define NUM_3DS_STACKS 0
`endif  

// Testbench Hierarchy Paths
// -------------------------
// hierarchy to design and testbench modules
// NOTE: chip and controller top-level are defined in the chip-level
//       dictionary if running chip-level testbench
`define TB                 tc.ddr_tb               // testbench
`define CHIP              `TB.ddr_chip             // chip
`define CORE              `CHIP.u_DWC_DDRPHY_core
`define PHY_TOP           `CHIP.u_DWC_DDRPHY_top
`define PHY               `PHY_TOP.u_DWC_DDRPHY
`define IO                `PHY.u_DWC_DDRPHY_io
`define IO_DELAY          `IO.U_board_dly
`define PUB               `PHY_TOP.u_DWC_ddrphy_pub
`define BIST              `PUB.u_DWC_ddrphy_bist
`define ACLB_BIST         `BIST.u_bist_ac_lb
`define DXLB_BIST         `BIST.u_bist_dx_lb
`define PHYCTL            `PUB.u_DWC_ddrphyctl
`define PHYCFG            `PUB.u_DWC_ddrphy_cfg
`define PHYDFI            `PUB.u_DWC_ddrphy_dfi
`define ZCAL_FSM          `PUB.u_DWC_ddrphy_init.u_DWC_ddrphy_init_phy.u_DWC_ddrphy_init_zctl
`define ZCAL_CFG          `PUB.u_DWC_ddrphy_cfg.u_zctl_reg[0].u_DWC_ddrphy_cfg_zctl
`define BRD_DLY           `IO.U_board_dly  // Board Delay
`define AC_BRD_DLY        `AC_IO.u_board_dly  // Board Delay
`define GRM               `TB.ddr_grm
`define CFG               `TB.cfg_bfm
`define SYS               `TB.system
`define PHYSYS            `TB.phy_system
`define CFG_MNT           `TB.cfg_mnt
`ifdef DWC_SHARED_AC   
  `define HOST            `TB.host_bfm_0
  `define HOST0           `TB.host_bfm_0
  `define HOST1           `TB.host_bfm_1
`else                                                       
  `define HOST            `TB.host_bfm_0
`endif
`ifdef DWC_SHARED_AC   
`define HOST_MNT          `TB.host_mnt_0
`define HOST_MNT0         `TB.host_mnt_0
`define HOST_MNT1         `TB.host_mnt_1
`else                                                       
`define HOST_MNT          `TB.host_mnt_0
`endif
`ifdef DWC_SHARED_AC   
`define MCTL              `TB.ddr_mctl_0
`define DFI               `TB.ddr_mctl_0.dfi_bfm
`define MCTL0             `TB.ddr_mctl_0
`define DFI0              `TB.ddr_mctl_0.dfi_bfm
`define MCTL1             `TB.ddr_mctl_1
`define DFI1              `TB.ddr_mctl_1.dfi_bfm
`define DFI_MNT_0         `TB.dfi_mnt_0
`define DFI_MNT_1         `TB.dfi_mnt_1
`define DFI_MNT           `TB.dfi_mnt_0
`else                                                       
`define MCTL              `TB.ddr_mctl_0
`define DFI               `TB.ddr_mctl_0.dfi_bfm
`define DFI_MNT           `TB.dfi_mnt_0
`endif
`define FCOV              `TB.ddr_fcov
`define FCOV_REG          `TB.ddr_reg_fcov
`define JTAG              `TB.jtag_bfm
`define EYE_MNT           `TB.eye_mnt

`define RANK              `TB.dwc_dimm[0].u_ddr_rank.dwc_rank[0].sdram_rank
`define RANK0             `TB.dwc_dimm[0].u_ddr_rank.dwc_rank[0].sdram_rank
`define RANK1             `TB.dwc_dimm[1].u_ddr_rank.dwc_rank[0].sdram_rank
`define RANK2             `TB.dwc_dimm[2].u_ddr_rank.dwc_rank[0].sdram_rank
`define RANK3             `TB.dwc_dimm[3].u_ddr_rank.dwc_rank[0].sdram_rank

`define RDIMM_ALERTN      `TB.alert_n_i

`define RANK0_MNT         `TB.dwc_dimm[0].dwc_rank_mnt[0].u_ddr_mnt
`define RANK1_MNT         `TB.dwc_dimm[1].dwc_rank_mnt[0].u_ddr_mnt
`define RANK2_MNT         `TB.dwc_dimm[2].dwc_rank_mnt[0].u_ddr_mnt
`define RANK3_MNT         `TB.dwc_dimm[3].dwc_rank_mnt[0].u_ddr_mnt
`define DWC_RANK_MNT(dwc_dim, dwc_rnk)      `TB.dwc_dimm[dwc_dim].dwc_rank_mnt[dwc_rnk].u_ddr_mnt

`define RANK_MNT          `RANK0_MNT
`define DDR_MNT           `RANK0_MNT
`define TC_RANK           `TB.dwc_rank[`DWC_NO_OF_RANKS-1].u_ddr_rank.sdram_rank
`define TC_RANK_MNT       `TB.dwc_rank_mnt[`DWC_NO_OF_RANKS-1].u_ddr_mnt
`define RDIMM             `TB.dwc_dimm[0].u_ddr_rank.SSTE32882

// PHY lanes
`define DX0               `PHY.dx[0].dx_top.u_DWC_DDRPHYDATX8_top.dx[0].u_DWC_DDRPHYDATX8     
`define DX1               `PHY.dx[1].dx_top.u_DWC_DDRPHYDATX8_top.dx[1].u_DWC_DDRPHYDATX8     
`define DX2               `PHY.dx[2].dx_top.u_DWC_DDRPHYDATX8_top.dx[2].u_DWC_DDRPHYDATX8    
`define DX3               `PHY.dx[3].dx_top.u_DWC_DDRPHYDATX8_top.dx[3].u_DWC_DDRPHYDATX8     
`define DX4               `PHY.dx[4].dx_top.u_DWC_DDRPHYDATX8_top.dx[4].u_DWC_DDRPHYDATX8     
`define DX5               `PHY.dx[5].dx_top.u_DWC_DDRPHYDATX8_top.dx[5].u_DWC_DDRPHYDATX8     
`define DX6               `PHY.dx[6].dx_top.u_DWC_DDRPHYDATX8_top.dx[6].u_DWC_DDRPHYDATX8     
`define DX7               `PHY.dx[7].dx_top.u_DWC_DDRPHYDATX8_top.dx[7].u_DWC_DDRPHYDATX8     
`define DX8               `PHY.dx[8].dx_top.u_DWC_DDRPHYDATX8_top.dx[8].u_DWC_DDRPHYDATX8     
`define DX0_IO            `PHY.dx[0].dx_top.u_DWC_DDRPHYDATX8_top.dx[0].u_DWC_DDRPHYDATX8_io     
`define DX1_IO            `PHY.dx[1].dx_top.u_DWC_DDRPHYDATX8_top.dx[1].u_DWC_DDRPHYDATX8_io      
`define DX2_IO            `PHY.dx[2].dx_top.u_DWC_DDRPHYDATX8_top.dx[2].u_DWC_DDRPHYDATX8_io     
`define DX3_IO            `PHY.dx[3].dx_top.u_DWC_DDRPHYDATX8_top.dx[3].u_DWC_DDRPHYDATX8_io      
`define DX4_IO            `PHY.dx[4].dx_top.u_DWC_DDRPHYDATX8_top.dx[4].u_DWC_DDRPHYDATX8_io      
`define DX5_IO            `PHY.dx[5].dx_top.u_DWC_DDRPHYDATX8_top.dx[5].u_DWC_DDRPHYDATX8_io      
`define DX6_IO            `PHY.dx[6].dx_top.u_DWC_DDRPHYDATX8_top.dx[6].u_DWC_DDRPHYDATX8_io      
`define DX7_IO            `PHY.dx[7].dx_top.u_DWC_DDRPHYDATX8_top.dx[7].u_DWC_DDRPHYDATX8_io      
`define DX8_IO            `PHY.dx[8].dx_top.u_DWC_DDRPHYDATX8_top.dx[8].u_DWC_DDRPHYDATX8_io      
`define AC                `PHY.u_DWC_DDRPHYAC_top.u_DWC_DDRPHYAC
`define AC_IO             `PHY.u_DWC_DDRPHYAC_top.u_DWC_DDRPHYAC_io
`define AC_TOP            `PHY.u_DWC_DDRPHYAC_top
`define AC_0              `AC.ac_0
`define AC_1              `AC.ac_1
`define AC_2              `AC.ac_2
`define AC_3              `AC.ac_3
`define AC_4              `AC.ac_4
`define AC_5              `AC.ac_5
`define AC_6              `AC.ac_6
`define AC_7              `AC.ac_7
`define AC_8              `AC.ac_8
`define AC_9              `AC.ac_9
`define AC_10             `AC.ac_10
`define AC_11             `AC.ac_11
`define AC_12             `AC.ac_12
`define AC_13             `AC.ac_13
`define AC_14             `AC.ac_14
`define AC_15             `AC.ac_15
`define AC_16             `AC.ac_16
`define AC_17             `AC.ac_17
`define AC_18             `AC.ac_18
`define AC_19             `AC.ac_19
`define AC_20             `AC.ac_20
`define AC_21             `AC.ac_21
`define AC_22             `AC.ac_22
`define AC_23             `AC.ac_23
`define AC_24             `AC.ac_24
`define AC_25             `AC.ac_25
`define AC_26             `AC.ac_26
`define AC_27             `AC.ac_27
`define AC_28             `AC.ac_28
`define AC_29             `AC.ac_29
`define AC_30             `AC.ac_30
`define AC_31             `AC.ac_31
`define AC_32             `AC.ac_32
`define AC_33             `AC.ac_33
`define AC_34             `AC.ac_34
`define AC_CK_0           `AC.ck_0
`define AC_CK_1           `AC.ck_1
`define AC_CK_2           `AC.ck_2
`define AC_CK_3           `AC.ck_3


// if two bytes share the PLL, the second byte will not have a unique DATX8_top instantiated
`define DWC_dx_top_byte    ((dwc_byte == 0 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h001) != 9'd0) || \
                            (dwc_byte == 1 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h002) != 9'd0) || \
                            (dwc_byte == 2 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h004) != 9'd0) || \
                            (dwc_byte == 3 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h008) != 9'd0) || \
                            (dwc_byte == 4 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h010) != 9'd0) || \
                            (dwc_byte == 5 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h020) != 9'd0) || \
                            (dwc_byte == 6 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h040) != 9'd0) || \
                            (dwc_byte == 7 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h080) != 9'd0) || \
                            (dwc_byte == 8 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h100) != 9'd0) ? (dwc_byte-1) : dwc_byte)
`define DWC_dx_top_BYTE_NO ((BYTE_NO  == 0 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h001) != 9'd0) || \
                            (BYTE_NO  == 1 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h002) != 9'd0) || \
                            (BYTE_NO  == 2 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h004) != 9'd0) || \
                            (BYTE_NO  == 3 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h008) != 9'd0) || \
                            (BYTE_NO  == 4 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h010) != 9'd0) || \
                            (BYTE_NO  == 5 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h020) != 9'd0) || \
                            (BYTE_NO  == 6 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h040) != 9'd0) || \
                            (BYTE_NO  == 7 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h080) != 9'd0) || \
                            (BYTE_NO  == 8 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h100) != 9'd0) ? (BYTE_NO-1) : BYTE_NO)
`define DWC_dx_top_byte_X4 ((dwc_byte == 0 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h001) != 9'd0) || \
                            (dwc_byte == 1 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h001) != 9'd0) || \
                            (dwc_byte == 2 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h002) != 9'd0) || \
                            (dwc_byte == 3 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h002) != 9'd0) || \
                            (dwc_byte == 4 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h004) != 9'd0) || \
                            (dwc_byte == 5 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h004) != 9'd0) || \
                            (dwc_byte == 6 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h008) != 9'd0) || \
                            (dwc_byte == 7 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h008) != 9'd0) || \
                            (dwc_byte == 8 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h010) != 9'd0) || \
                            (dwc_byte == 9 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h010) != 9'd0) || \
                            (dwc_byte == 10 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h020) != 9'd0) || \
                            (dwc_byte == 11 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h020) != 9'd0) || \
                            (dwc_byte == 12 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h040) != 9'd0) || \
                            (dwc_byte == 13 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h040) != 9'd0) || \
                            (dwc_byte == 14 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h080) != 9'd0) || \
                            (dwc_byte == 15 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h080) != 9'd0) || \
                            (dwc_byte == 16 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h100) != 9'd0) || \
                            (dwc_byte == 17 && ( (`DWC_DX_PLL_SHARE << 1) & 9'h100) != 9'd0)) ? ((dwc_byte/2)-1) : (dwc_byte/2)


// DX hierarchical paths used in loops of number of bytes

`ifdef DWC_DDRPHY_X4X2
  `define DXn_top           `PHY.dx[`DWC_dx_top_byte_X4].dx_top.u_DWC_DDRPHYDATX8_top
  `define DXn               `DXn_top.dx[dwc_byte/2].u_DWC_DDRPHYDATX8
  `define DXn_IO            `DXn_top.dx[dwc_byte/2].u_DWC_DDRPHYDATX8_io

  `define DXn_inst_top      `PHY.dx[`DWC_dx_top_byte_X4].dx_top.u_DWC_DDRPHYDATX8_top
  `define DXn_inst          `DXn_inst_top.dx[dwc_byte/2].u_DWC_DDRPHYDATX8    
  `define DXn_inst_IO       `DXn_inst_top.dx[dwc_byte/2].u_DWC_DDRPHYDATX8_io 
`else
  `define DXn_top           `PHY.dx[`DWC_dx_top_byte].dx_top.u_DWC_DDRPHYDATX8_top
  `define DXn               `DXn_top.dx[dwc_byte].u_DWC_DDRPHYDATX8    
  `define DXn_IO            `DXn_top.dx[dwc_byte].u_DWC_DDRPHYDATX8_io 

  `define DXn_inst_top      `PHY.dx[`DWC_dx_top_byte].dx_top.u_DWC_DDRPHYDATX8_top
  `define DXn_inst          `DXn_inst_top.dx[dwc_byte].u_DWC_DDRPHYDATX8    
  `define DXn_inst_IO       `DXn_inst_top.dx[dwc_byte].u_DWC_DDRPHYDATX8_io 
`endif

`define DATX8_INST(dwc_byte)        `DXn
`define EYE_PROBE(dwc_byte)         `DXn
`define DATX8_BRD_DLY(dwc_byte)     `DXn_IO.u_board_dly
`define RAM_PROBE(RANK_NO,RANK_NO_2,BYTE_NO) `TB.dwc_dimm[RANK_NO].u_ddr_rank.dwc_rank[RANK_NO_2].sdram_rank.dwc_sdram[BYTE_NO].xn_dram.u_sdram

`ifdef DWC_DDRPHY_TYPEAR
  `define DXn_core             `DXn.datx8_nopll     
  `define DX0_core             `DX0.datx8_nopll
  `define DX1_core             `DX1.datx8_nopll
  `define DX2_core             `DX2.datx8_nopll
  `define DX3_core             `DX3.datx8_nopll
  `define DX4_core             `DX4.datx8_nopll
  `define DX5_core             `DX5.datx8_nopll
  `define DX6_core             `DX6.datx8_nopll
  `define DX7_core             `DX7.datx8_nopll
  `define DX8_core             `DX8.datx8_nopll
                                                       
  `define DXn_core_l             `DXn.datx8_nopll_l     
  `define DX0_core_l             `DX0.datx8_nopll_l
  `define DX1_core_l             `DX1.datx8_nopll_l
  `define DX2_core_l             `DX2.datx8_nopll_l
  `define DX3_core_l             `DX3.datx8_nopll_l
  `define DX4_core_l             `DX4.datx8_nopll_l
  `define DX5_core_l             `DX5.datx8_nopll_l
  `define DX6_core_l             `DX6.datx8_nopll_l
  `define DX7_core_l             `DX7.datx8_nopll_l
  `define DX8_core_l             `DX8.datx8_nopll_l
`else
  `define DXn_core             `DXn
  `define DX0_core             `DX0
  `define DX1_core             `DX1
  `define DX2_core             `DX2
  `define DX3_core             `DX3
  `define DX4_core             `DX4
  `define DX5_core             `DX5
  `define DX6_core             `DX6
  `define DX7_core             `DX7
  `define DX8_core             `DX8
`endif

// PHY lanes PLLs
`define BYTE_0_PLL        `PHY.dx[0].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll
`define BYTE_1_PLL        `PHY.dx[1].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define BYTE_2_PLL        `PHY.dx[2].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define BYTE_3_PLL        `PHY.dx[3].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define BYTE_4_PLL        `PHY.dx[4].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define BYTE_5_PLL        `PHY.dx[5].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define BYTE_6_PLL        `PHY.dx[6].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define BYTE_7_PLL        `PHY.dx[7].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll      
`define BYTE_8_PLL        `PHY.dx[8].dx_top.u_DWC_DDRPHYDATX8_top.pll_ew_ns.u_pll     
`define CMD_PLL           `PHY.u_DWC_DDRPHYAC_top.pll_ew_ns.u_pll
`define DXn_PLL           `DXn_top.pll_ew_ns.u_pll

// board delays control signals
`define DWC_BOARD_DLY_WL       `SYS.write_levelling
`define DWC_BOARD_DLY_WL2      `SYS.write_levelling_2
`define DWC_BOARD_DLY_TCK      `SYS.board_dly_tck
`define DWC_BOARD_DLY_TCK_DIV4 `SYS.board_dly_tck_div4

  `define DX_CTRL         datx8_ctrl
`ifdef DWC_DDRPHY_X4X2
  `define DX_DQS0         datx8_dqs_0
  `define DX_DQS1         datx8_dqs_1
  `define DX_CLKGEN0      datx8_clkgen_0
  `define DX_CLKGEN1      datx8_clkgen_1


  `define DX_DQS_DDRCNT   datx8_sctrl.dqs_ddr_cnt_0
  `define DX_DQ_DDRCNT    datx8_sctrl.dq_ddr_cnt_0
  `define DX_CTRL_DDRCNT  datx8_sctrl.ctrl_ddr_cnt_0
`else
  `define DX_DQS0         datx8_dqs
  `define DX_DQS1         datx8_dqs
  `define DX_CLKGEN0      datx8_clkgen
  `define DX_CLKGEN1      datx8_clkgen

  `define DX_DQS_DDRCNT   datx8_sctrl.dqs_ddr_cnt
  `define DX_DQ_DDRCNT    datx8_sctrl.dq_ddr_cnt
  `define DX_CTRL_DDRCNT  datx8_sctrl.ctrl_ddr_cnt
`endif

// macro to show there are 2 DQS in the system
`ifdef DWC_DDRPHY_X4X2
  `ifndef DWC_DDRPHY_X8_ONLY
    `define DWC_NO_OF_DX_DQS_EQ_2
  `endif
`endif

// change the pin mapping for the case when in X4X2 and DWC_DDRPHY_DMDQS_MUX                                                                                  
// for non-customer defines.                                                                                
`ifdef DWC_DDRPHY_TB_OVERRIDE
  `ifdef DWC_DDRPHY_X4X2
    `ifdef DWC_DDRPHY_DMDQS_MUX                                                                                 
      // undefine the default mappings
      // byte 0
      `undef DWC_DX0_DQ0_PNUM
      `undef DWC_DX0_DQ1_PNUM
      `undef DWC_DX0_DQ2_PNUM
      `undef DWC_DX0_DQ3_PNUM
      `undef DWC_DX0_DM0_PNUM
      `undef DWC_DX0_DQ4_PNUM
      `undef DWC_DX0_DQ5_PNUM
      `undef DWC_DX0_DQ6_PNUM
      `undef DWC_DX0_DQ7_PNUM
      `undef DWC_DX0_DM1_PNUM

      // byte 1
      `undef DWC_DX1_DQ0_PNUM
      `undef DWC_DX1_DQ1_PNUM
      `undef DWC_DX1_DQ2_PNUM
      `undef DWC_DX1_DQ3_PNUM
      `undef DWC_DX1_DM0_PNUM
      `undef DWC_DX1_DQ4_PNUM
      `undef DWC_DX1_DQ5_PNUM
      `undef DWC_DX1_DQ6_PNUM
      `undef DWC_DX1_DQ7_PNUM
      `undef DWC_DX1_DM1_PNUM

      // byte 2
      `undef DWC_DX2_DQ0_PNUM
      `undef DWC_DX2_DQ1_PNUM
      `undef DWC_DX2_DQ2_PNUM
      `undef DWC_DX2_DQ3_PNUM
      `undef DWC_DX2_DM0_PNUM
      `undef DWC_DX2_DQ4_PNUM
      `undef DWC_DX2_DQ5_PNUM
      `undef DWC_DX2_DQ6_PNUM
      `undef DWC_DX2_DQ7_PNUM
      `undef DWC_DX2_DM1_PNUM

      // byte 3
      `undef DWC_DX3_DQ0_PNUM
      `undef DWC_DX3_DQ1_PNUM
      `undef DWC_DX3_DQ2_PNUM
      `undef DWC_DX3_DQ3_PNUM
      `undef DWC_DX3_DM0_PNUM
      `undef DWC_DX3_DQ4_PNUM
      `undef DWC_DX3_DQ5_PNUM
      `undef DWC_DX3_DQ6_PNUM
      `undef DWC_DX3_DQ7_PNUM
      `undef DWC_DX3_DM1_PNUM

      // byte 4
      `undef DWC_DX4_DQ0_PNUM
      `undef DWC_DX4_DQ1_PNUM
      `undef DWC_DX4_DQ2_PNUM
      `undef DWC_DX4_DQ3_PNUM
      `undef DWC_DX4_DM0_PNUM
      `undef DWC_DX4_DQ4_PNUM
      `undef DWC_DX4_DQ5_PNUM
      `undef DWC_DX4_DQ6_PNUM
      `undef DWC_DX4_DQ7_PNUM
      `undef DWC_DX4_DM1_PNUM

      // byte 5
      `undef DWC_DX5_DQ0_PNUM
      `undef DWC_DX5_DQ1_PNUM
      `undef DWC_DX5_DQ2_PNUM
      `undef DWC_DX5_DQ3_PNUM
      `undef DWC_DX5_DM0_PNUM
      `undef DWC_DX5_DQ4_PNUM
      `undef DWC_DX5_DQ5_PNUM
      `undef DWC_DX5_DQ6_PNUM
      `undef DWC_DX5_DQ7_PNUM
      `undef DWC_DX5_DM1_PNUM

      // byte 6
      `undef DWC_DX6_DQ0_PNUM
      `undef DWC_DX6_DQ1_PNUM
      `undef DWC_DX6_DQ2_PNUM
      `undef DWC_DX6_DQ3_PNUM
      `undef DWC_DX6_DM0_PNUM
      `undef DWC_DX6_DQ4_PNUM
      `undef DWC_DX6_DQ5_PNUM
      `undef DWC_DX6_DQ6_PNUM
      `undef DWC_DX6_DQ7_PNUM
      `undef DWC_DX6_DM1_PNUM

      // byte 7
      `undef DWC_DX7_DQ0_PNUM
      `undef DWC_DX7_DQ1_PNUM
      `undef DWC_DX7_DQ2_PNUM
      `undef DWC_DX7_DQ3_PNUM
      `undef DWC_DX7_DM0_PNUM
      `undef DWC_DX7_DQ4_PNUM
      `undef DWC_DX7_DQ5_PNUM
      `undef DWC_DX7_DQ6_PNUM
      `undef DWC_DX7_DQ7_PNUM
      `undef DWC_DX7_DM1_PNUM

      // byte 8
      `undef DWC_DX8_DQ0_PNUM
      `undef DWC_DX8_DQ1_PNUM
      `undef DWC_DX8_DQ2_PNUM
      `undef DWC_DX8_DQ3_PNUM
      `undef DWC_DX8_DM0_PNUM
      `undef DWC_DX8_DQ4_PNUM
      `undef DWC_DX8_DQ5_PNUM
      `undef DWC_DX8_DQ6_PNUM
      `undef DWC_DX8_DQ7_PNUM
      `undef DWC_DX8_DM1_PNUM

      // redefibne for X4X2
      // byte 0
      `define DWC_DX0_DQ0_PNUM                0
      `define DWC_DX0_DQ1_PNUM                1
      `define DWC_DX0_DQ2_PNUM                2
      `define DWC_DX0_DQ3_PNUM                3
      `define DWC_DX0_DM0_PNUM                8
      `define DWC_DX0_DQ4_PNUM                5
      `define DWC_DX0_DQ5_PNUM                6
      `define DWC_DX0_DQ6_PNUM                7
      `define DWC_DX0_DQ7_PNUM                9
      `define DWC_DX0_DM1_PNUM                4

      // byte 1
      `define DWC_DX1_DQ0_PNUM                0
      `define DWC_DX1_DQ1_PNUM                1
      `define DWC_DX1_DQ2_PNUM                2
      `define DWC_DX1_DQ3_PNUM                3
      `define DWC_DX1_DM0_PNUM                8
      `define DWC_DX1_DQ4_PNUM                5
      `define DWC_DX1_DQ5_PNUM                6
      `define DWC_DX1_DQ6_PNUM                7
      `define DWC_DX1_DQ7_PNUM                9
      `define DWC_DX1_DM1_PNUM                4

      // byte 2
      `define DWC_DX2_DQ0_PNUM                0
      `define DWC_DX2_DQ1_PNUM                1
      `define DWC_DX2_DQ2_PNUM                2
      `define DWC_DX2_DQ3_PNUM                3
      `define DWC_DX2_DM0_PNUM                8
      `define DWC_DX2_DQ4_PNUM                5
      `define DWC_DX2_DQ5_PNUM                6
      `define DWC_DX2_DQ6_PNUM                7
      `define DWC_DX2_DQ7_PNUM                9
      `define DWC_DX2_DM1_PNUM                4

      // byte 3
      `define DWC_DX3_DQ0_PNUM                0
      `define DWC_DX3_DQ1_PNUM                1
      `define DWC_DX3_DQ2_PNUM                2
      `define DWC_DX3_DQ3_PNUM                3
      `define DWC_DX3_DM0_PNUM                8
      `define DWC_DX3_DQ4_PNUM                5
      `define DWC_DX3_DQ5_PNUM                6
      `define DWC_DX3_DQ6_PNUM                7
      `define DWC_DX3_DQ7_PNUM                9
      `define DWC_DX3_DM1_PNUM                4

      // byte 4
      `define DWC_DX4_DQ0_PNUM                0
      `define DWC_DX4_DQ1_PNUM                1
      `define DWC_DX4_DQ2_PNUM                2
      `define DWC_DX4_DQ3_PNUM                3
      `define DWC_DX4_DM0_PNUM                8
      `define DWC_DX4_DQ4_PNUM                5
      `define DWC_DX4_DQ5_PNUM                6
      `define DWC_DX4_DQ6_PNUM                7
      `define DWC_DX4_DQ7_PNUM                9
      `define DWC_DX4_DM1_PNUM                4

      // byte 5
      `define DWC_DX5_DQ0_PNUM                0
      `define DWC_DX5_DQ1_PNUM                1
      `define DWC_DX5_DQ2_PNUM                2
      `define DWC_DX5_DQ3_PNUM                3
      `define DWC_DX5_DM0_PNUM                8
      `define DWC_DX5_DQ4_PNUM                5
      `define DWC_DX5_DQ5_PNUM                6
      `define DWC_DX5_DQ6_PNUM                7
      `define DWC_DX5_DQ7_PNUM                9
      `define DWC_DX5_DM1_PNUM                4

      // byte 6
      `define DWC_DX6_DQ0_PNUM                0
      `define DWC_DX6_DQ1_PNUM                1
      `define DWC_DX6_DQ2_PNUM                2
      `define DWC_DX6_DQ3_PNUM                3
      `define DWC_DX6_DM0_PNUM                8
      `define DWC_DX6_DQ4_PNUM                5
      `define DWC_DX6_DQ5_PNUM                6
      `define DWC_DX6_DQ6_PNUM                7
      `define DWC_DX6_DQ7_PNUM                9
      `define DWC_DX6_DM1_PNUM                4

      // byte 7
      `define DWC_DX7_DQ0_PNUM                0
      `define DWC_DX7_DQ1_PNUM                1
      `define DWC_DX7_DQ2_PNUM                2
      `define DWC_DX7_DQ3_PNUM                3
      `define DWC_DX7_DM0_PNUM                8
      `define DWC_DX7_DQ4_PNUM                5
      `define DWC_DX7_DQ5_PNUM                6
      `define DWC_DX7_DQ6_PNUM                7
      `define DWC_DX7_DQ7_PNUM                9
      `define DWC_DX7_DM1_PNUM                4

      // byte 8
      `define DWC_DX8_DQ0_PNUM                0
      `define DWC_DX8_DQ1_PNUM                1
      `define DWC_DX8_DQ2_PNUM                2
      `define DWC_DX8_DQ3_PNUM                3
      `define DWC_DX8_DM0_PNUM                8
      `define DWC_DX8_DQ4_PNUM                5
      `define DWC_DX8_DQ5_PNUM                6
      `define DWC_DX8_DQ6_PNUM                7
      `define DWC_DX8_DQ7_PNUM                9
      `define DWC_DX8_DM1_PNUM                4
    `else
      `ifndef DWC_DDRPHY_X8_ONLY
        // undefine the default mappings
        // byte 0
        `undef DWC_DX0_DQ0_PNUM
        `undef DWC_DX0_DQ1_PNUM
        `undef DWC_DX0_DQ2_PNUM
        `undef DWC_DX0_DQ3_PNUM
        `undef DWC_DX0_DM0_PNUM
        `undef DWC_DX0_DQ4_PNUM
        `undef DWC_DX0_DQ5_PNUM
        `undef DWC_DX0_DQ6_PNUM
        `undef DWC_DX0_DQ7_PNUM
        `undef DWC_DX0_DM1_PNUM

        // byte 1
        `undef DWC_DX1_DQ0_PNUM
        `undef DWC_DX1_DQ1_PNUM
        `undef DWC_DX1_DQ2_PNUM
        `undef DWC_DX1_DQ3_PNUM
        `undef DWC_DX1_DM0_PNUM
        `undef DWC_DX1_DQ4_PNUM
        `undef DWC_DX1_DQ5_PNUM
        `undef DWC_DX1_DQ6_PNUM
        `undef DWC_DX1_DQ7_PNUM
        `undef DWC_DX1_DM1_PNUM

        // byte 2
        `undef DWC_DX2_DQ0_PNUM
        `undef DWC_DX2_DQ1_PNUM
        `undef DWC_DX2_DQ2_PNUM
        `undef DWC_DX2_DQ3_PNUM
        `undef DWC_DX2_DM0_PNUM
        `undef DWC_DX2_DQ4_PNUM
        `undef DWC_DX2_DQ5_PNUM
        `undef DWC_DX2_DQ6_PNUM
        `undef DWC_DX2_DQ7_PNUM
        `undef DWC_DX2_DM1_PNUM

        // byte 3
        `undef DWC_DX3_DQ0_PNUM
        `undef DWC_DX3_DQ1_PNUM
        `undef DWC_DX3_DQ2_PNUM
        `undef DWC_DX3_DQ3_PNUM
        `undef DWC_DX3_DM0_PNUM
        `undef DWC_DX3_DQ4_PNUM
        `undef DWC_DX3_DQ5_PNUM
        `undef DWC_DX3_DQ6_PNUM
        `undef DWC_DX3_DQ7_PNUM
        `undef DWC_DX3_DM1_PNUM

        // byte 4
        `undef DWC_DX4_DQ0_PNUM
        `undef DWC_DX4_DQ1_PNUM
        `undef DWC_DX4_DQ2_PNUM
        `undef DWC_DX4_DQ3_PNUM
        `undef DWC_DX4_DM0_PNUM
        `undef DWC_DX4_DQ4_PNUM
        `undef DWC_DX4_DQ5_PNUM
        `undef DWC_DX4_DQ6_PNUM
        `undef DWC_DX4_DQ7_PNUM
        `undef DWC_DX4_DM1_PNUM

        // byte 5
        `undef DWC_DX5_DQ0_PNUM
        `undef DWC_DX5_DQ1_PNUM
        `undef DWC_DX5_DQ2_PNUM
        `undef DWC_DX5_DQ3_PNUM
        `undef DWC_DX5_DM0_PNUM
        `undef DWC_DX5_DQ4_PNUM
        `undef DWC_DX5_DQ5_PNUM
        `undef DWC_DX5_DQ6_PNUM
        `undef DWC_DX5_DQ7_PNUM
        `undef DWC_DX5_DM1_PNUM

        // byte 6
        `undef DWC_DX6_DQ0_PNUM
        `undef DWC_DX6_DQ1_PNUM
        `undef DWC_DX6_DQ2_PNUM
        `undef DWC_DX6_DQ3_PNUM
        `undef DWC_DX6_DM0_PNUM
        `undef DWC_DX6_DQ4_PNUM
        `undef DWC_DX6_DQ5_PNUM
        `undef DWC_DX6_DQ6_PNUM
        `undef DWC_DX6_DQ7_PNUM
        `undef DWC_DX6_DM1_PNUM

        // byte 7
        `undef DWC_DX7_DQ0_PNUM
        `undef DWC_DX7_DQ1_PNUM
        `undef DWC_DX7_DQ2_PNUM
        `undef DWC_DX7_DQ3_PNUM
        `undef DWC_DX7_DM0_PNUM
        `undef DWC_DX7_DQ4_PNUM
        `undef DWC_DX7_DQ5_PNUM
        `undef DWC_DX7_DQ6_PNUM
        `undef DWC_DX7_DQ7_PNUM
        `undef DWC_DX7_DM1_PNUM

        // byte 8
        `undef DWC_DX8_DQ0_PNUM
        `undef DWC_DX8_DQ1_PNUM
        `undef DWC_DX8_DQ2_PNUM
        `undef DWC_DX8_DQ3_PNUM
        `undef DWC_DX8_DM0_PNUM
        `undef DWC_DX8_DQ4_PNUM
        `undef DWC_DX8_DQ5_PNUM
        `undef DWC_DX8_DQ6_PNUM
        `undef DWC_DX8_DQ7_PNUM
        `undef DWC_DX8_DM1_PNUM

        // redefibne for X4X2
        // byte 0
        `define DWC_DX0_DQ0_PNUM                0
        `define DWC_DX0_DQ1_PNUM                1
        `define DWC_DX0_DQ2_PNUM                2
        `define DWC_DX0_DQ3_PNUM                3
        `define DWC_DX0_DM0_PNUM                4
        `define DWC_DX0_DQ4_PNUM                5
        `define DWC_DX0_DQ5_PNUM                6
        `define DWC_DX0_DQ6_PNUM                7
        `define DWC_DX0_DQ7_PNUM                8
        `define DWC_DX0_DM1_PNUM                9

        // byte 1
        `define DWC_DX1_DQ0_PNUM                0
        `define DWC_DX1_DQ1_PNUM                1
        `define DWC_DX1_DQ2_PNUM                2
        `define DWC_DX1_DQ3_PNUM                3
        `define DWC_DX1_DM0_PNUM                4
        `define DWC_DX1_DQ4_PNUM                5
        `define DWC_DX1_DQ5_PNUM                6
        `define DWC_DX1_DQ6_PNUM                7
        `define DWC_DX1_DQ7_PNUM                8
        `define DWC_DX1_DM1_PNUM                9

        // byte 2
        `define DWC_DX2_DQ0_PNUM                0
        `define DWC_DX2_DQ1_PNUM                1
        `define DWC_DX2_DQ2_PNUM                2
        `define DWC_DX2_DQ3_PNUM                3
        `define DWC_DX2_DM0_PNUM                4
        `define DWC_DX2_DQ4_PNUM                5
        `define DWC_DX2_DQ5_PNUM                6
        `define DWC_DX2_DQ6_PNUM                7
        `define DWC_DX2_DQ7_PNUM                8
        `define DWC_DX2_DM1_PNUM                9

        // byte 3
        `define DWC_DX3_DQ0_PNUM                0
        `define DWC_DX3_DQ1_PNUM                1
        `define DWC_DX3_DQ2_PNUM                2
        `define DWC_DX3_DQ3_PNUM                3
        `define DWC_DX3_DM0_PNUM                4
        `define DWC_DX3_DQ4_PNUM                5
        `define DWC_DX3_DQ5_PNUM                6
        `define DWC_DX3_DQ6_PNUM                7
        `define DWC_DX3_DQ7_PNUM                8
        `define DWC_DX3_DM1_PNUM                9

        // byte 4
        `define DWC_DX4_DQ0_PNUM                0
        `define DWC_DX4_DQ1_PNUM                1
        `define DWC_DX4_DQ2_PNUM                2
        `define DWC_DX4_DQ3_PNUM                3
        `define DWC_DX4_DM0_PNUM                4
        `define DWC_DX4_DQ4_PNUM                5
        `define DWC_DX4_DQ5_PNUM                6
        `define DWC_DX4_DQ6_PNUM                7
        `define DWC_DX4_DQ7_PNUM                8
        `define DWC_DX4_DM1_PNUM                9

        // byte 5
        `define DWC_DX5_DQ0_PNUM                0
        `define DWC_DX5_DQ1_PNUM                1
        `define DWC_DX5_DQ2_PNUM                2
        `define DWC_DX5_DQ3_PNUM                3
        `define DWC_DX5_DM0_PNUM                4
        `define DWC_DX5_DQ4_PNUM                5
        `define DWC_DX5_DQ5_PNUM                6
        `define DWC_DX5_DQ6_PNUM                7
        `define DWC_DX5_DQ7_PNUM                8
        `define DWC_DX5_DM1_PNUM                9

        // byte 6
        `define DWC_DX6_DQ0_PNUM                0
        `define DWC_DX6_DQ1_PNUM                1
        `define DWC_DX6_DQ2_PNUM                2
        `define DWC_DX6_DQ3_PNUM                3
        `define DWC_DX6_DM0_PNUM                4
        `define DWC_DX6_DQ4_PNUM                5
        `define DWC_DX6_DQ5_PNUM                6
        `define DWC_DX6_DQ6_PNUM                7
        `define DWC_DX6_DQ7_PNUM                8
        `define DWC_DX6_DM1_PNUM                9

        // byte 7
        `define DWC_DX7_DQ0_PNUM                0
        `define DWC_DX7_DQ1_PNUM                1
        `define DWC_DX7_DQ2_PNUM                2
        `define DWC_DX7_DQ3_PNUM                3
        `define DWC_DX7_DM0_PNUM                4
        `define DWC_DX7_DQ4_PNUM                5
        `define DWC_DX7_DQ5_PNUM                6
        `define DWC_DX7_DQ6_PNUM                7
        `define DWC_DX7_DQ7_PNUM                8
        `define DWC_DX7_DM1_PNUM                9

        // byte 8
        `define DWC_DX8_DQ0_PNUM                0
        `define DWC_DX8_DQ1_PNUM                1
        `define DWC_DX8_DQ2_PNUM                2
        `define DWC_DX8_DQ3_PNUM                3
        `define DWC_DX8_DM0_PNUM                4
        `define DWC_DX8_DQ4_PNUM                5
        `define DWC_DX8_DQ5_PNUM                6
        `define DWC_DX8_DQ6_PNUM                7
        `define DWC_DX8_DQ7_PNUM                8
        `define DWC_DX8_DM1_PNUM                9
      `endif
    `endif
  `endif
`endif
                                                                                 
// universal and commonly used tasks or variables
`define END_SIMULATION       `SYS.end_simulation(1)
`define END_SIMULATION_EVENT `SYS.e_end_simulation

// For Shared AC channel definition                                                      
`define SHARED_AC_CHN_0   0                                                       
`define SHARED_AC_CHN_1   1                                                       
`define NON_SHARED_AC     2                                                       

// file paths and pointers
// -----------------------
`define TC_VEC_FILE       "../log/tc.vec"
`define SVB_VEC_FILE      "../log/svb.vec"
`define TC_VCD_FILE       "../log/tc.vcd"
`define TC_VCDE_FILE      "../log/tc.vcde"
`define AC_VCDE_FILE      "../log/ac.vcde"
`define DX_VCDE_FILE      "../log/dx.vcde"
`define TC_LOG_FILE       "../log/tc.log"
`define SHM_NCWAVE_FILE   "./ncwaves.shm"
`define SHM_XLWAVE_FILE   "./xlwaves.shm"
`ifdef REGRESSION_RUN
  `define AC_SDF_FILE       "./lib/data/ddrphyac.sdf"
  `define ACX48_SDF_FILE       "./lib/data/ddrphyacx48.sdf"
  `define DX_SDF_FILE       "./lib/data/ddrphydx.sdf"
  `define DX4_SDF_FILE      "./lib/data/ddrphydx4.sdf"
`else
  `ifdef DWC_DDRPHY_BUILD
    `define AC_SDF_FILE       "./lib/data/ddrphyac.sdf"
    `define ACX48_SDF_FILE       "./lib/data/ddrphyacx48.sdf"
    `define DX_SDF_FILE       "./lib/data/ddrphydx.sdf"
    `define DX4_SDF_FILE      "./lib/data/ddrphydx4.sdf"
  `else
    `define AC_SDF_FILE       "../lib/data/ddrphyac.sdf"
    `define ACX48_SDF_FILE       "../lib/data/ddrphyacx48.sdf"
    `define DX_SDF_FILE       "../lib/data/ddrphydx.sdf"
    `define DX4_SDF_FILE      "../lib/data/ddrphydx4.sdf"
  `endif
`endif
  
`define TC_LOG            `SYS.tc_log_file_ptr  // file pointer to log file

`define ERROR_OFF         0
`define ERROR_ON          1

`define SVA_ERR           assertion_err_msg
`define SVA_INFO          assertion_msg

// Timeout for specific ddrphy stages
`define TIMEOUT_SYS_RESET_COUNT    10000  * `CFG_CLK_PRD/`CLK_PRD
`define TIMEOUT_PLL_INIT_COUNT     100000 * `CFG_CLK_PRD/`CLK_PRD
`define TIMEOUT_PHY_CAL_COUNT      100000 * `CFG_CLK_PRD/`CLK_PRD
`ifdef DWC_PLL_BYPASS
  `define TIMEOUT_PHY_INIT_COUNT     12000000 * `CFG_CLK_PRD/`CLK_PRD
`else
  `define TIMEOUT_PHY_INIT_COUNT     300000 * `CFG_CLK_PRD/`CLK_PRD
`endif
`ifdef FULL_INIT_BYPASS
  `define TIMEOUT_SDRAM_INIT_COUNT   400000
`else
  `ifdef FULL_INIT
    `define TIMEOUT_SDRAM_INIT_COUNT   1200000
  `else
    `define TIMEOUT_SDRAM_INIT_COUNT   100000 * `CFG_CLK_PRD/`CLK_PRD
  `endif
`endif
`define TIMEOUT_WRITE_LEVELING_COUNT     100000 * `CFG_CLK_PRD/`CLK_PRD
`define TIMEOUT_DQS_GATE_TRAIN_COUNT     100000 * `CFG_CLK_PRD/`CLK_PRD
`define TIMEOUT_PHY_READY_COUNT          100000 * `CFG_CLK_PRD/`CLK_PRD

`define ON                         1'b1
`define TRUE                       1'b1
`define OFF                        1'b0
`define FALSE                      1'b0

`define TOGGLE_REGISTER_DATA           1
`define VALUE_REGISTER_DATA            0
`define VALUE_REGISTER_VT_DRIFT_DATA   2
// DDRPHY Reserved addresses
`define RESERVED_14                9'h0E
`define RESERVED_15                9'h0F
`define RESERVED_16                9'h10
`define RESERVED_17                9'h11
`define RESERVED_18                9'h12
`define RESERVED_19                9'h13
`define RESERVED_20                9'h14
`define RESERVED_21                9'h15
`define RESERVED_22                9'h16
`define RESERVED_23                9'h17
`define RESERVED_24                9'h18
`define RESERVED_25                9'h19
`define RESERVED_26                9'h1A
`define RESERVED_27                9'h1B
`define RESERVED_28                9'h1C
`define RESERVED_29                9'h1D
`define RESERVED_30                9'h1E
`define RESERVED_31                9'h1F
`define RESERVED_32                9'h20
`define RESERVED_33                9'h21
`define RESERVED_34                9'h22
`define RESERVED_35                9'h23
`define RESERVED_36                9'h24
`define RESERVED_37                9'h25
`define RESERVED_38                9'h26
`define RESERVED_39                9'h27
`define RESERVED_40                9'h28
`define RESERVED_41                9'h29
`define RESERVED_42                9'h2A
`define RESERVED_43                9'h2B
`define RESERVED_44                9'h2C
`define RESERVED_45                9'h2D
`define RESERVED_46                9'h2E
`define RESERVED_47                9'h2F
`define RESERVED_48                9'h30
`define RESERVED_49                9'h31
`define RESERVED_50                9'h32
`define RESERVED_51                9'h33
`define RESERVED_52                9'h34
`define RESERVED_53                9'h35
`define RESERVED_54                9'h36
`define RESERVED_55                9'h37
`define RESERVED_56                9'h38
`define RESERVED_57                9'h39
`define RESERVED_58                9'h3A
`define RESERVED_59                9'h3B
`define RESERVED_60                9'h3C
`define RESERVED_61                9'h3D
`define RESERVED_62                9'h3E
`define RESERVED_63                9'h3F
`define RESERVED_64                9'h40
`define RESERVED_65                9'h41
`define RESERVED_66                9'h42
`define RESERVED_67                9'h43
`define RESERVED_68                9'h44
`define RESERVED_69                9'h45
`define RESERVED_70                9'h46
`define RESERVED_71                9'h47
`define RESERVED_72                9'h48
`define RESERVED_73                9'h49
`define RESERVED_74                9'h4A
`define RESERVED_75                9'h4B
`define RESERVED_76                9'h4C
`define RESERVED_77                9'h4D
`define RESERVED_78                9'h4E
`define RESERVED_79                9'h4F
`define RESERVED_80                9'h50
`define RESERVED_81                9'h51
`define RESERVED_82                9'h52
`define RESERVED_83                9'h53
`define RESERVED_84                9'h54
`define RESERVED_85                9'h55
`define RESERVED_86                9'h56
`define RESERVED_87                9'h57
`define RESERVED_88                9'h58
`define RESERVED_89                9'h59
`define RESERVED_90                9'h5A
`define RESERVED_91                9'h5B
`define RESERVED_92                9'h5C
`define RESERVED_93                9'h5D
`define RESERVED_94                9'h5E
`define RESERVED_95                9'h5F
`define RESERVED_96                9'h60
`define RESERVED_97                9'h61
`define RESERVED_98                9'h62
`define RESERVED_99                9'h63
`define RESERVED_100               9'h64
`define RESERVED_101               9'h65
`define RESERVED_102               9'h66
`define RESERVED_103               9'h67
`define RESERVED_124               9'h7C
`define RESERVED_125               9'h7D
`define RESERVED_126               9'h7E
`define RESERVED_127               9'h7F
`define RESERVED_140               9'h8C
`define RESERVED_141               9'h8D
`define RESERVED_142               9'h8E
`define RESERVED_156               9'h9C
`define RESERVED_157               9'h9D
`define RESERVED_158               9'h9E
`define RESERVED_159               9'h9F
`define RESERVED_172               9'hAC
`define RESERVED_173               9'hAD
`define RESERVED_174               9'hAE
`define RESERVED_175               9'hAF
`define RESERVED_188               9'hBC
`define RESERVED_189               9'hBD
`define RESERVED_190               9'hBE
`define RESERVED_191               9'hBF
`define RESERVED_204               9'hCC
`define RESERVED_205               9'hCD
`define RESERVED_206               9'hCE
`define RESERVED_207               9'hCF
`define RESERVED_220               9'hDC
`define RESERVED_221               9'hDD
`define RESERVED_222               9'hDE
`define RESERVED_223               9'hDF
`define RESERVED_236               9'hEC
`define RESERVED_237               9'hED
`define RESERVED_238               9'hEE
`define RESERVED_239               9'hEF
`define RESERVED_252               9'hFC
`define RESERVED_253               9'hFD
`define RESERVED_254               9'hFE
`define RESERVED_255               9'hFF
// VT drift scenario define
`define VT_DRIFT_INC_W_UPD         0
`define VT_DRIFT_INC_W_OUT_UPD     1
`define VT_DRIFT_DEC_W_UPD         2
`define VT_DRIFT_DEC_W_OUT_UPD     3
`define VT_DRIFT_RANDOM_W_UPD      4
`define VT_DRIFT_RANDOM_W_OUT_UPD  5
//DDRPHY Engine define
`define DQSG_SCN  0
`define WL_SCN    1
`define VT_SCN    2
`define DQSD_SCN  3
// DQS/DQ drift scenario define
`define DQS_DQ_DRIFT_INC            0
`define DQS_DQ_DRIFT_DEC            1
`define DQS_DQ_DRIFT_RANDOM         2
// DQS/DQ fixed phased define
`define DQS_DQ_PHASED_POS_QUARTER           0
`define DQS_DQ_PHASED_POS_HALF              1
`define DQS_DQ_PHASED_POS_3QUARTERS         2
`define DQS_DQ_PHASED_POS_FULL              3
`define DQS_DQ_PHASED_NEG_QUARTER           4
`define DQS_DQ_PHASED_NEG_HALF              5
`define DQS_DQ_PHASED_NEG_3QUARTERS         6
`define DQS_DQ_PHASED_NEG_FULL              7
//VT DRift with DQS/DQ drift
`define VT_DRIFT_W_DQS_DQ_DRIFT_INC      0
`define VT_DRIFT_W_DQS_DQ_DRIFT_RND      1
//VT DRift with WL
`define VT_DRIFT_W_WL_INC      0
`define VT_DRIFT_W_WL_RND      1
//DATA DESKEW
`define READ_DATA_DESKEW    0
`define WRITE_DATA_DESKEW   1
// VT UPDATE REQUEST
`define NO_REQ_VT_UPD      0      
`define PHY_REQ_VT_UPD     1                                                              
`define CTRL_REQ_VT_UPD    2        


// for SMODE, define offsets for different functions
`ifdef DWC_DDRPHY_SMODE
  `define SMODE_OFFSET_NO_INIT_ON_RST   3
  `define SMODE_OFFSET_INIT_RST         6
  `define SMODE_OFFSET_ZCAL_INIT_EN     9
  `define SMODE_OFFSET_PLL_INIT_EN      8
  `define SMODE_OFFSET_DDL_INIT_EN      7
`endif

          
	  
  //Board delay defines
`define OUT      0
`define IN       1

// DX delays types
`define DQ_0        0// 7'b0000000
`define DQ_1        1// 7'b0000001
`define DQ_2        2// 7'b0000010
`define DQ_3        3// 7'b0000011
`define DQ_4        4// 7'b0000100
`define DQ_5        5// 7'b0000101
`define DQ_6        6// 7'b0000110
`define DQ_7        7// 7'b0000111
`define DQ_8        8// 7'b0001000
`define DQ_9        9// 7'b0001001
`define DQ_10      10// 7'b0001010
`define DQ_11      11// 7'b0001011
`define DQ_12      12// 7'b0001100
`define DQ_13      13// 7'b0001101
`define DQ_14      14// 7'b0001110
`define DQ_15      15// 7'b0001111
`define DQ_16      16// 7'b0000000
`define DQ_17      17// 7'b0000001
`define DQ_18      18// 7'b0000010
`define DQ_19      19// 7'b0000011
`define DQ_20      20// 7'b0000100
`define DQ_21      21// 7'b0000101
`define DQ_22      22// 7'b0000110
`define DQ_23      23// 7'b0000111
`define DQ_24      24// 7'b0001000
`define DQ_25      25// 7'b0001001
`define DQ_26      26// 7'b0001010
`define DQ_27      27// 7'b0001011
`define DQ_28      28// 7'b0001100
`define DQ_29      29// 7'b0001101
`define DQ_30      30// 7'b0001110
`define DQ_31      31// 7'b0001111
`define DQ_0_PDD   32// 7'b0100000
`define DQ_1_PDD   33// 7'b0100001
`define DQ_2_PDD   34// 7'b0100010
`define DQ_3_PDD   35// 7'b0100011
`define DQ_4_PDD   36// 7'b0100100
`define DQ_5_PDD   37// 7'b0100101
`define DQ_6_PDD   38// 7'b0100110
`define DQ_7_PDD   39// 7'b0100111
`define DQ_0_PDR   40// 7'b0101000
`define DQ_1_PDR   41// 7'b0101001
`define DQ_2_PDR   42// 7'b0101010
`define DQ_3_PDR   43// 7'b0101011
`define DQ_4_PDR   44// 7'b0101100
`define DQ_5_PDR   45// 7'b0101101
`define DQ_6_PDR   46// 7'b0101110
`define DQ_7_PDR   47// 7'b0101111
`define DQ_0_TE    48// 7'b0110000
`define DQ_1_TE    49// 7'b0110001
`define DQ_2_TE    50// 7'b0110010
`define DQ_3_TE    51// 7'b0110011
`define DQ_4_TE    52// 7'b0110100
`define DQ_5_TE    53// 7'b0110101
`define DQ_6_TE    54// 7'b0110110
`define DQ_7_TE    55// 7'b0110111
`define DM         64// 7'b1000000
`define DM_PDD     65// 7'b1000001
`define DM_PDR     66// 7'b1000010
`define DM_TE      67// 7'b1000011
`define DQS        68// 7'b1000100
`define DQS_PDD    69// 7'b1000101
`define DQS_PDR    70// 7'b1000110
`define DQS_TE     71// 7'b1000111
`define DQSN       72// 7'b1001000
`define DQSN_PDD   73// 7'b1001001
`define DQSN_PDR   74// 7'b1001010
`define DQSN_TE    75// 7'b1001011
`define DQSG       80// 7'b1010000
`define DQSG_PDD   81// 7'b1010001
`define DQSG_PDR   82// 7'b1010010
`define DQSG_TE    83// 7'b1010011

`define DQS_1      84// x16 support
`define DQS_2      85// x32 support
`define DQS_3      86// x32 support
`define DQSN_1     87// x16 support
`define DQSN_2     88// x32 support
`define DQSN_3     89// x32 support
`define DM_1       90// x16 support
`define DM_2       91// x32 support
`define DM_3       92// x32 support

`define DQ_DCD     93// x32 support
`define DM_DCD     94// x32 support
`define DQS_DCD    95// x16 support

// AC delays types
`define ADDR_0      0// 5'b00000
`define ADDR_1      1// 5'b00001
`define ADDR_2      2// 5'b00010
`define ADDR_3      3// 5'b00011
`define ADDR_4      4// 5'b00100
`define ADDR_5      5// 5'b00101
`define ADDR_6      6// 5'b00110
`define ADDR_7      7// 5'b00111
`define ADDR_8      8// 5'b01000
`define ADDR_9      9// 5'b01001
`define ADDR_10    10// 5'b01010
`define ADDR_11    11// 5'b01011
`define ADDR_12    12// 5'b01100
`define ADDR_13    13// 5'b01101
`define ADDR_14    14// 5'b01110
`define ADDR_15    15// 5'b01111
`define ADDR_16    16// 5'b10000
`define ADDR_17    17// 5'b10001
`define CMD_BA0    18// 5'b10010
`define CMD_BA1    19// 5'b10011
`define CMD_BA2    20// 5'b10101
`define CMD_BA3    21// 5'b10110
`define CMD_ACT    22// 5'b10111
`define CMD_PARIN  23// 5'b10100
`define CMD_ALERTN 24// 5'b10100
`define CMD_ODT    25// 5'b10110
`define CMD_CKE    26// 5'b10111
`define CMD_CSN    27// 5'b11000
`define AC_CK      28// 5'b11100
`define AC_CKN     29// 5'b11100
`define AC_CK0     33// 5'b11100
`define AC_CK1     34// 5'b11101
`define AC_CK2     35// 5'b11110
`define AC_CK3     36// 5'b11110
`define CMD_CID0   30// 5'b11000
`define CMD_CID1   31// 5'b11000
`define CMD_CID2   32// 5'b11000

//PVT specific characteristics of the delay lines max and min values
`define NDL_ZERO_DELAY_PVT_MIN      80
`define NDL_ZERO_DELAY_PVT_MAX      350
`define LCDL_ZERO_DELAY_PVT_MIN     80
`define LCDL_ZERO_DELAY_PVT_MAX     350
`define BDL_ZERO_DELAY_PVT_MIN      80
`define BDL_ZERO_DELAY_PVT_MAX      420
`define LCDL_STEP_SIZE_PVT_MIN      8
`define LCDL_STEP_SIZE_PVT_MAX      25
`define BDL_STEP_SIZE_PVT_MIN       8
`define BDL_STEP_SIZE_PVT_MAX       25
`define IO_DOUT_PAD_PVT_MIN         500
`define IO_DOUT_PAD_PVT_MAX         1350
`define IO_PAD_DIN_PVT_MIN          240
`define IO_PAD_DIN_PVT_MAX          650
`define IO_DOUT_OE_PVT_MIN          500
`define IO_DOUT_OE_PVT_MAX          1350

//Print_mode options on print_board_cfg
`define PRINT_BOARD_CFG_ALL 10'h3FF
`define PRINT_BOARD_CFG_AC  10'h200   
`define PRINT_BOARD_CFG_DX  10'h1FF
`define PRINT_BOARD_CFG_DX0 10'h001 
`define PRINT_BOARD_CFG_DX1 10'h002
`define PRINT_BOARD_CFG_DX2 10'h004 
`define PRINT_BOARD_CFG_DX3 10'h008
`define PRINT_BOARD_CFG_DX4 10'h010 
`define PRINT_BOARD_CFG_DX5 10'h020
`define PRINT_BOARD_CFG_DX6 10'h040 
`define PRINT_BOARD_CFG_DX7 10'h080
`define PRINT_BOARD_CFG_DX8 10'h100

//Board topologies
`define NO_BOARD_TOPOLOGY               0
`define BC_MATCHED_FLYBY_TOPOLOGY       1
`define AVG_MATCHED_FLYBY_TOPOLOGY      2
`define WC_MATCHED_FLYBY_TOPOLOGY       3
`define BC_MATCHED_T_TOPOLOGY           4
`define AVG_MATCHED_T_TOPOLOGY          5
`define WC_MATCHED_T_TOPOLOGY           6
`define BC_UNMATCH_FLYBY_TOPOLOGY       7
`define AVG_UNMATCH_FLYBY_TOPOLOGY      8
`define WC_UNMATCH_FLYBY_TOPOLOGY       9
`define BC_UNMATCH_T_TOPOLOGY           10
`define AVG_UNMATCH_T_TOPOLOGY          11
`define WC_UNMATCH_T_TOPOLOGY           12
      
//PLL jitter model
`define JIT_CLOCK_X4X2                  0  
`define JIT_CLOCK_X1                    1 
`define JIT_BOTH_CLOCKS                 2   
        
//Read path checker
`define RD_CHECKER            `TB.read_path_checker

`define  DATX8_DQ0_INSTANCE   `DXn.datx8_dq_0
`define  DATX8_DQ1_INSTANCE   `DXn.datx8_dq_1
`define  DATX8_DQ2_INSTANCE   `DXn.datx8_dq_2
`define  DATX8_DQ3_INSTANCE   `DXn.datx8_dq_3
`define  DATX8_DQ4_INSTANCE   `DXn.datx8_dq_4
`define  DATX8_DQ5_INSTANCE   `DXn.datx8_dq_5
`define  DATX8_DQ6_INSTANCE   `DXn.datx8_dq_6
`define  DATX8_DQ7_INSTANCE   `DXn.datx8_dq_7
`define  DATX8_DQ8_INSTANCE   `DXn.datx8_dq_7
`define  DATX8_DQS_INSTANCE   `DXn.`DX_DQS0
`define  DATX8_DQS_INSTANCE_X4_0   `DXn.`DX_DQS0
`define  DATX8_DQS_INSTANCE_X4_1   `DXn.`DX_DQS1
// --- FIFO checker parameters
`define  RD_CHK_PTR_GAP        3     //number of FIFO input (writing) clock cycles gap required for data read from any position
`define  RD_CHK_WR_SETUP       0.15  //FIFO writing setup time in fraction of the write clock period
`define  RD_CHK_WR_HOLD        0.10  //FIFO writing hold time in fraction of the write clock period
`define  RD_CHK_VERBOSE        1      // 0 = no messages
                                      // 1 = flag any FIFO violations once, QS gate check errors once (default)
                                      // 2 = flag any FIFO violations and QS gate check errors or warnings, everytime
`define AC_MDL_LCDL_PATH    `AC.ac_ctrl.mdl_lcdl   // AC MDL LCDL
