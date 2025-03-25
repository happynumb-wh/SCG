/******************************************************************************
 *                                                                            *
 * Copyright (c) 2008 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: DQS DQ Drift                                                  *
 *                                                                            *
 *****************************************************************************/

module dqs_dq_drift

  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  #( parameter m_enl = 2 ) // Number of data lanes 
    
    //---------------------------------------------------------------------------
    // Port list
    //---------------------------------------------------------------------------
    (   
        output wire     [m_enl-1:0]   phyio_qs_drift_dly,   
        output wire [(m_enl*8)-1:0]   phyio_q_drift_dly,    
    
        input wire     [m_enl-1:0]    phyio_qs_no_drift,       
        input wire [(m_enl*8)-1:0]    phyio_q_no_drift,        

        input wire                    dqs_dq_drifting,
        input wire                    ctl_clk   
        );

  localparam m_edw = m_enl*8; // data width (incl. ecc) of ddr bus


  // Delayed signals
  reg [m_edw-1:0] r_phyio_q_drift_dly;  
  reg [m_enl-1:0] r_phyio_qs_drift_dly;
  
  
  // Will be used for controlling when to add the dqs_dq derifting
  integer         add_dqs_dq_drifting;

  
  // Setup delays on read/write paths to random values
  // -------------------------------------------------
  initial begin : mad_delays
    integer j;
    
    #10; // Need to wait until seed is set in top level TB
    
    add_dqs_dq_drifting  = 0; // Turn off by default
    
  end  // initial


`ifdef DDR3_1600G    
  //always @(posedge ctl_clk)
  always @(*)  
    begin: dqs_dq_phased
      if(dqs_dq_drifting == 1'b1) begin
  `ifdef DQS_DLY_QTR_CLK        
        r_phyio_qs_drift_dly   <= #0.15625 phyio_qs_no_drift;               
        r_phyio_q_drift_dly    <= #0.15625 phyio_q_no_drift;       
        `elsif DQS_DLY_HLF_CLK        
          r_phyio_qs_drift_dly   <= #0.3125 phyio_qs_no_drift;         
        r_phyio_q_drift_dly    <= #0.3125 phyio_q_no_drift;             
        `elsif DQS_DLY_3QTRS_CLK       
          r_phyio_qs_drift_dly   <= #0.46875 phyio_qs_no_drift;                   
        r_dphyio_q_drift_dly    <= #0.46875 phyio_q_no_drift;           
        `elsif DQS_DLY_FULL_CLK        
          r_phyio_qs_drift_dly   <= #`CLK_PRD phyio_qs_no_drift;                 
        r_phyio_q_drift_dly    <= #`CLK_PRD phyio_q_no_drift; 
  `else         
        r_phyio_qs_drift_dly   <= phyio_qs_no_drift;               
        r_phyio_q_drift_dly    <= phyio_q_no_drift;        
  `endif // !`ifdef DQS_DLY_QTR_CLK
      end // if (dqs_dq_drifting == 1'b1)
      else begin
        r_phyio_qs_drift_dly   <= phyio_qs_no_drift;               
        r_phyio_q_drift_dly    <= phyio_q_no_drift; 
      end  
    end            
  
`endif   

  assign phyio_qs_drift_dly = r_phyio_qs_drift_dly;
  assign phyio_q_drift_dly = r_phyio_q_drift_dly;
  
endmodule
