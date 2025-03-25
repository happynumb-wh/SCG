//-----------------------------------------------------------------------------
//
// Copyright (c) 2010 Synopsys Incorporated.				   
// 									   
// This file contains confidential, proprietary information and trade	   
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written	   
// permission of Synopsys Incorporated. 				   
// 
// DESCRIPTION: DDR PHY BIST verification testcases common routines
//-----------------------------------------------------------------------------
// PUB Data Train common utilities (dt_common_param.v)
//-----------------------------------------------------------------------------
//
  

//---------------------------------------------------------------------------
// Parameters
//---------------------------------------------------------------------------
  // DTCR
  localparam pDTRPTN_WIDTH           = 4;
  localparam pDTRNK_WIDTH            = 2;
  localparam pDTMPR_WIDTH            = 1;
  localparam pDTCMPD_WIDTH           = 1;
  localparam pDTWDQM_WIDTH           = 4;
  localparam pDTWBDDM_WIDTH          = 1;
  localparam pDTBDC_WIDTH            = 1;
  localparam pDTDBS_WIDTH            = 4;
  localparam pDTDEN_WIDTH            = 1;
  localparam pDTDSTP_WIDTH           = 1;
  localparam pDTEXD_WIDTH            = 1;
  localparam pDTEXG_WIDTH            = 1;
  localparam pRANKEN_WIDTH           = `DWC_NO_OF_RANKS;
  localparam pRFSHDT_WIDTH           = 4;

  localparam pDTRPTN_FROM_BIT        = 0;
  localparam pDTRNK_FROM_BIT         = 4;
  localparam pDTMPR_FROM_BIT         = 6;
  localparam pDTCMPD_FROM_BIT        = 7;
  localparam pDTWDQM_FROM_BIT        = 8;
  localparam pDTWBDDM_FROM_BIT       = 12;
  localparam pDTBDC_FROM_BIT         = 13;
  localparam pDTDBS_FROM_BIT         = 16;
  localparam pDTDEN_FROM_BIT         = 20;
  localparam pDTDSTP_FROM_BIT        = 21;
  localparam pDTEXD_FROM_BIT         = 22;
  localparam pDTEXG_FROM_BIT         = 23;
  localparam pRANKEN_FROM_BIT        = 24;
  localparam pRFSHDT_FROM_BIT        = 28;

  localparam pDTRPTN_TO_BIT          = pDTRPTN_WIDTH-1  + pDTRPTN_FROM_BIT;
  localparam pDTRNK_TO_BIT           = pDTRNK_WIDTH-1   + pDTRNK_FROM_BIT;
  localparam pDTMPR_TO_BIT           = pDTMPR_WIDTH-1   + pDTMPR_FROM_BIT;
  localparam pDTCMPD_TO_BIT          = pDTCMPD_WIDTH-1  + pDTCMPD_FROM_BIT;
  localparam pDTWDQM_TO_BIT          = pDTWDQM_WIDTH-1  + pDTWDQM_FROM_BIT;
  localparam pDTWBDDM_TO_BIT         = pDTWBDDM_WIDTH-1 + pDTWBDDM_FROM_BIT;
  localparam pDTBDC_TO_BIT           = pDTBDC_WIDTH-1   + pDTBDC_FROM_BIT;
  localparam pDTDBS_TO_BIT           = pDTDBS_WIDTH-1   + pDTDBS_FROM_BIT;
  localparam pDTDEN_TO_BIT           = pDTDEN_WIDTH-1   + pDTDEN_FROM_BIT;
  localparam pDTDSTP_TO_BIT          = pDTDSTP_WIDTH-1  + pDTDSTP_FROM_BIT;
  localparam pDTEXD_TO_BIT           = pDTEXD_WIDTH-1   + pDTEXD_FROM_BIT;
  localparam pDTEXG_TO_BIT           = pDTEXG_WIDTH-1   + pDTEXG_FROM_BIT;
  localparam pRANKEN_TO_BIT          = pRANKEN_WIDTH-1  + pRANKEN_FROM_BIT;
  localparam pRFSHDT_TO_BIT          = pRFSHDT_WIDTH-1  + pRFSHDT_FROM_BIT;

  // DTAR0-3
  localparam pDTBANK_WIDTH           = 4;     
  localparam pDTCOL_WIDTH            = 9;       
  localparam pDTROW_WIDTH            = 18;      
  localparam pDTBANK_FROM_BIT        = 24;     
  localparam pDTROW_FROM_BIT         = 0;      
  localparam pDTCOL0_FROM_BIT        = 0;       
  localparam pDTCOL1_FROM_BIT        = 16;       
  localparam pDTCOL2_FROM_BIT        = 0;       
  localparam pDTCOL3_FROM_BIT        = 16;       
  localparam pDTBANK_TO_BIT          = pDTBANK_WIDTH-1 + pDTBANK_FROM_BIT;        
  localparam pDTROW_TO_BIT           = pDTROW_WIDTH-1  + pDTROW_FROM_BIT;        
  localparam pDTCOL0_TO_BIT          = pDTCOL_WIDTH-1  + pDTCOL0_FROM_BIT;        
  localparam pDTCOL1_TO_BIT          = pDTCOL_WIDTH-1  + pDTCOL1_FROM_BIT;        
  localparam pDTCOL2_TO_BIT          = pDTCOL_WIDTH-1  + pDTCOL2_FROM_BIT;        
  localparam pDTCOL3_TO_BIT          = pDTCOL_WIDTH-1  + pDTCOL3_FROM_BIT;        
                                     
  // DTDR0 and DTDR1                 
  localparam pDTDR_WIDTH             = 32;       
  localparam pDTDR_FROM_BIT          = 0;       
  localparam pDTDR_TO_BIT            = pDTDR_WIDTH-1 + pDTDR_FROM_BIT;        

