/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DDR SDRAM enumerated type definitions                         *
 *              Enumerated type definitions used in several files.            *
 *                                                                            *
 *****************************************************************************/

typedef enum bit[4:0] {DQBIT0 = 0, DQBIT1 = 1, DQBIT2 = 2, DQBIT3 = 3, DQBIT4 = 4,
		       DQBIT5 = 5, DQBIT6 = 6, DQBIT7 = 7, DQBIT8 = 8, DQBIT9 = 9,
		       DQBIT10 = 10, DQBIT11 = 11, DQBIT12 = 12, DQBIT13 = 13, DQBIT14 = 14,
		       DQBIT15 = 15, DQBIT16 = 16, DQBIT17 = 17, DQBIT18 = 18, DQBIT19 = 19,
		       DQBIT20 = 20, DQBIT21 = 21, DQBIT22 = 22, DQBIT23 = 23, DQBIT24 = 24,
		       DQBIT25 = 25, DQBIT26 = 26, DQBIT27 = 27, DQBIT28 = 28, DQBIT29 = 29,
		       DQBIT30 = 30, DQBIT31 = 31} dq_bits_e;
  
typedef enum bit[2:0] { 
      CMD_DELAY   = 3'd0,    // command path board dealy 
			WRITE_DELAY = 3'd1,    // write data path board delay
			READ_DELAY  = 3'd2,    // read data path board delay
			CK_DELAY    = 3'd3,    // CK/CK# extra delay (on top of write delay)
			QS_DELAY    = 3'd4,    // DQS/DQS# extra delay (on top of read delay)
			DQS_DELAY   = 3'd5,    // DQS extra delay (on top of DQS/DQS# delay)
			DQSb_DELAY  = 3'd6,    // DQS# extra delay (on top of DQS/DQS# delay)
			FLYBY_DELAY = 3'd7     // command fly-by delay
			} board_delay_type_e;

typedef enum bit { 
       DQS_STROBE  = 1'b0,    // DQS pin
		   DQSb_STROBE = 1'b1     // DQS# pin
		   } dqs_pin_type_e;