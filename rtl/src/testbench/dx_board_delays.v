/******************************************************************************
 *                                                                            *
 * Copyright (c) 2010 Synopsys                        .                       *
 *                                                                            *
 * This file contains confidential, proprietary information and trade         *
 * secrets of Synopsys. No part of this document may be used, reproduced      *
 * or transmitted in any form or by any means without prior written           *
 * permission of Synopsys Incorporated.                                       *
 *                                                                            *
 * DESCRIPTION: Board Delay                                                   *
 *                                                                            *
 *****************************************************************************/

`timescale 1fs/1fs  // Set the timescale for board delays


module dx_board_dly
  #(
    // Parameters
    parameter pDX_NUM = 2,  // byte lane number
    parameter pNO_OF_DX_DQS = `DWC_DX_NO_OF_DQS // number of DQS signals per DX macro
   )
   (
    // Port list
    output reg  [8            -1:0] phyio_d_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dm_dly,
    output reg  [8            -1:0] phyio_d_oe_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dm_oe_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_qs_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_qsn_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_qs_did_dly,
    output reg  [8            -1:0] phyio_q_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_qm_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_ds_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dsn_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_ds_oe_dly,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dsn_oe_dly,

    input  wire [8            -1:0] phyio_d,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dm,
    input  wire [8            -1:0] phyio_d_oe,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dm_oe,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_qs,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_qs_n,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_qs_did,
    input  wire [8            -1:0] phyio_q,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_qm,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_ds,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_ds_n,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_ds_oe,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_ds_n_oe,  
     
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_g_dout      ,  
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_g_dout_dly  ,     
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_g_oe        ,  
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_g_oe_dly    ,    
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_g_di        ,  
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_g_di_dly    ,   
     
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_pdd         ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_pdr         ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_te          ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_pdd_dly     ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_pdr_dly     ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_te_dly      ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_n_pdd       ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_n_pdr       ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_n_te        ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_n_pdd_dly   ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_n_pdr_dly   ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_n_te_dly    ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_g_pdd       ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_g_pdr       ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dqs_g_te        ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_g_pdd_dly   ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_g_pdr_dly   ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dqs_g_te_dly    ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dm_pdd          ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dm_pdr          ,
    input  wire [pNO_OF_DX_DQS-1:0] phyio_dm_te           ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dm_pdd_dly      ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dm_pdr_dly      ,
    output reg  [pNO_OF_DX_DQS-1:0] phyio_dm_te_dly       ,
    input  wire [8            -1:0] phyio_dq_pdd          ,
    input  wire [8            -1:0] phyio_dq_pdr          ,
    input  wire [8            -1:0] phyio_dq_te           ,
    output reg  [8            -1:0] phyio_dq_pdd_dly      ,
    output reg  [8            -1:0] phyio_dq_pdr_dly      ,
    output reg  [8            -1:0] phyio_dq_te_dly       , 

    input wire                      write_levelling_2,
    input wire                      write_levelling,
    input wire  [64           -1:0] tck,
    input wire  [64           -1:0] tck_div4
   );


  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  localparam    NO_OF_DQ_DLYS   = 8;
  localparam    NO_OF_DM_DLYS   = `DWC_DX_NO_OF_DQS;
  localparam    NO_OF_DQS_DLYS  = `DWC_DX_NO_OF_DQS;

  // define PI to use in $sin function


  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  // Byte delays:
  // Fixed (board) delays
  integer      dq_do_board_dly       [0:NO_OF_DQ_DLYS-1];
  integer      dq_di_board_dly       [0:NO_OF_DQ_DLYS-1];
  integer      dm_do_board_dly       [0:NO_OF_DM_DLYS-1];
  integer      dm_di_board_dly       [0:NO_OF_DM_DLYS-1];
  integer      dqs_do_board_dly      [0:NO_OF_DQS_DLYS-1];
  integer      dqs_di_board_dly      [0:NO_OF_DQS_DLYS-1];
  integer      dqs_did_board_dly     [0:NO_OF_DQS_DLYS-1];
  integer      dqsn_do_board_dly     [0:NO_OF_DQS_DLYS-1];
  integer      dqsn_di_board_dly     [0:NO_OF_DQS_DLYS-1];

  integer      dqs_g_dout_board_dly  [0:NO_OF_DQS_DLYS-1];  
  integer      dqs_g_di_board_dly    [0:NO_OF_DQS_DLYS-1];   

  integer      dqs_pdd_board_dly     [0:NO_OF_DQS_DLYS-1];
  integer      dqs_pdr_board_dly     [0:NO_OF_DQS_DLYS-1];
  integer      dqs_te_board_dly      [0:NO_OF_DQS_DLYS-1];
  integer      dqs_n_pdd_board_dly   [0:NO_OF_DQS_DLYS-1];
  integer      dqs_n_pdr_board_dly   [0:NO_OF_DQS_DLYS-1];
  integer      dqs_n_te_board_dly    [0:NO_OF_DQS_DLYS-1];
  integer      dqs_g_pdd_board_dly   [0:NO_OF_DQS_DLYS-1];
  integer      dqs_g_pdr_board_dly   [0:NO_OF_DQS_DLYS-1];
  integer      dqs_g_te_board_dly    [0:NO_OF_DQS_DLYS-1];
  integer      dm_pdd_board_dly      [0:NO_OF_DM_DLYS-1];
  integer      dm_pdr_board_dly      [0:NO_OF_DM_DLYS-1];
  integer      dm_te_board_dly       [0:NO_OF_DM_DLYS-1];
  integer      dq_pdd_board_dly      [0:NO_OF_DQ_DLYS-1];
  integer      dq_pdr_board_dly      [0:NO_OF_DQ_DLYS-1];
  integer      dq_te_board_dly       [0:NO_OF_DQ_DLYS-1];

 
  genvar       dx_bit;
  genvar       dqs_bit;
  integer      dx_bit_no;
     
  //glitch suppression   
  time qs_posedge_det     [pNO_OF_DX_DQS-1:0];
  time qs_negedge_det     [pNO_OF_DX_DQS-1:0];
  time qs_did_posedge_det [pNO_OF_DX_DQS-1:0];
  time qs_did_negedge_det [pNO_OF_DX_DQS-1:0];
  time qsn_posedge_det    [pNO_OF_DX_DQS-1:0];
  time qsn_negedge_det    [pNO_OF_DX_DQS-1:0];
  time qm_posedge_det     [pNO_OF_DX_DQS-1:0]; 
  time qm_negedge_det     [pNO_OF_DX_DQS-1:0];
  time q_posedge_det      [7:0];
  time q_negedge_det      [7:0];
  
  reg  [pNO_OF_DX_DQS-1:0] qm_posedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qm_negedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qs_posedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qs_negedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qs_did_posedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qs_did_negedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qsn_posedge_val;
  reg  [pNO_OF_DX_DQS-1:0] qsn_negedge_val;


  //---------------------------------------------------------------------------
  // External Delay Setting Tasks
  //---------------------------------------------------------------------------
  // tasks to directly set the delays, jitter and DCD on the AC and DQ/DQS
  // signals from external testcase or testbench task

  // delay initialization
  // --------------------
  // all delays are by default initialized to zero
  initial
    begin: initialize_delays
      integer dq_bit_no;
      integer i;

      for (dx_bit_no=0; dx_bit_no<NO_OF_DQS_DLYS; dx_bit_no=dx_bit_no+1) begin
        dqs_do_board_dly      [dx_bit_no]  = 0;
        dqs_di_board_dly      [dx_bit_no]  = 0;
        dqs_did_board_dly     [dx_bit_no]  = 0;
        dqsn_do_board_dly     [dx_bit_no]  = 0;
        dqsn_di_board_dly     [dx_bit_no]  = 0;
        dm_do_board_dly       [dx_bit_no]  = 0;
        dm_di_board_dly       [dx_bit_no]  = 0;
  
        dqs_g_dout_board_dly  [dx_bit_no]  = 0;      
        dqs_g_di_board_dly    [dx_bit_no]  = 0;       
        
        dqs_pdd_board_dly     [dx_bit_no]  = 0;
        dqs_pdr_board_dly     [dx_bit_no]  = 0;
        dqs_te_board_dly      [dx_bit_no]  = 0;
        dqs_n_pdd_board_dly   [dx_bit_no]  = 0;
        dqs_n_pdr_board_dly   [dx_bit_no]  = 0;
        dqs_n_te_board_dly    [dx_bit_no]  = 0;
        dqs_g_pdd_board_dly   [dx_bit_no]  = 0;
        dqs_g_pdr_board_dly   [dx_bit_no]  = 0;
        dqs_g_te_board_dly    [dx_bit_no]  = 0;
        dm_pdd_board_dly      [dx_bit_no]  = 0;
        dm_pdr_board_dly      [dx_bit_no]  = 0;
        dm_te_board_dly       [dx_bit_no]  = 0;
      end        

      for (dq_bit_no=0; dq_bit_no<8; dq_bit_no=dq_bit_no+1) begin
        dq_do_board_dly  [dq_bit_no]  = 0;
        dq_di_board_dly  [dq_bit_no]  = 0;
        
        dq_pdd_board_dly [dq_bit_no]  = 0;
        dq_pdr_board_dly [dq_bit_no]  = 0;
      end 
    end
  
  task set_dx_signal_board_delay;
    input integer dx_signal;
    input integer direction;  //typecast -> was previously a binary input
    input integer index;
    input integer i_dly;

    integer       dly;
    
    begin

      // scale the delay...input is ps but timescale is fs
      dly = i_dly * 1000;
      
      //$display("Delay: Direction = %0d, Signal = %0d, index = %0d, value = %0d", direction, dx_signal, index, dly);
        case (direction)
         `OUT : begin
           case(dx_signal)
             `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7 : begin
               dq_do_board_dly[dx_signal - `DQ_0] = dly;
             end
             `DQ_0_PDD, `DQ_1_PDD, `DQ_2_PDD, `DQ_3_PDD, `DQ_4_PDD, `DQ_5_PDD, `DQ_6_PDD, `DQ_7_PDD : begin
               dq_pdd_board_dly[dx_signal - `DQ_0_PDD] = dly;
             end   
             `DQ_0_PDR, `DQ_1_PDR, `DQ_2_PDR, `DQ_3_PDR, `DQ_4_PDR, `DQ_5_PDR, `DQ_6_PDR, `DQ_7_PDR : begin
               dq_pdr_board_dly[dx_signal - `DQ_0_PDR] = dly;
             end
             `DQ_0_TE, `DQ_1_TE, `DQ_2_TE, `DQ_3_TE, `DQ_4_TE, `DQ_5_TE, `DQ_6_TE, `DQ_7_TE : begin
               dq_te_board_dly[dx_signal - `DQ_0_TE] = dly;
             end                                     
             `DQS : begin
               dqs_do_board_dly[index] = dly;
             end
             `DQS_PDD : begin
               dqs_pdd_board_dly [index] = dly;
             end    
             `DQS_PDR : begin
               dqs_pdr_board_dly [index] = dly;
             end
             `DQS_TE : begin
               dqs_te_board_dly [index] = dly;
             end                       
             `DQSN : begin
               dqsn_do_board_dly [index] = dly;
             end
             `DQSN_PDD : begin
               dqs_n_pdd_board_dly [index] = dly;
             end    
             `DQSN_PDR : begin
               dqs_n_pdr_board_dly [index] = dly;
             end
             `DQSN_TE : begin
               dqs_n_te_board_dly [index] = dly;
             end 
             `DM : begin
               dm_do_board_dly [index] = dly;
             end
             `DM_PDD : begin
               dm_pdd_board_dly [index] = dly;
             end    
             `DM_PDR : begin
               dm_pdr_board_dly [index] = dly;
             end
             `DM_TE : begin
               dm_te_board_dly [index] = dly;
             end 
             `DQSG : begin
               dqs_g_dout_board_dly [index] = dly;
             end
             `DQSG_PDD : begin
               dqs_g_pdd_board_dly [index] = dly;
             end    
             `DQSG_PDR : begin
               dqs_g_pdr_board_dly [index] = dly;
             end
             `DQSG_TE : begin
               dqs_g_te_board_dly [index] = dly;
             end  
  	         default   : begin
               $display("-> %0t: ==> WARNING: [set_dx_signal_board_delay] incorrect or missing direction/signal specification on task call.", $time);
             end
           endcase
         end
         `IN : begin
           case(dx_signal)
             `DQ_0, `DQ_1, `DQ_2, `DQ_3, `DQ_4, `DQ_5, `DQ_6, `DQ_7 : begin
               dq_di_board_dly[dx_signal - `DQ_0] = dly;
             end
             `DQS : begin
               dqs_di_board_dly [index] = dly;
               dqs_did_board_dly [index] = dly;
             end
             `DQSN: begin
               dqsn_di_board_dly[index] = dly;
             end
             `DM  : begin
               dm_di_board_dly  [index] = dly;
             end
             `DQSG  : begin
               dqs_g_di_board_dly  [index] = dly;
             end 
  	         default   : begin
               $display("-> %0t: ==> WARNING: [set_dx_signal_board_delay] incorrect or missing direction/signal specification on task call.", $time);
             end
           endcase 
         end
       endcase // case ({direction, dx_signal})
     end
 endtask // set_dx_signal_board_delay        


  // Per rank delayed signals, with added skews, random+sinusoidal jitter and DCD
  // ---------------
  
  integer case_lock = 1;
  
  generate
  for(dqs_bit=0; dqs_bit<pNO_OF_DX_DQS; dqs_bit=dqs_bit+1) begin : dqs_dm_do_dly
      //DM Delays
      always @(posedge phyio_dm[dqs_bit])         phyio_dm_dly[dqs_bit]         <= #(dm_do_board_dly[dqs_bit])       phyio_dm[dqs_bit];
      always @(negedge phyio_dm[dqs_bit])         phyio_dm_dly[dqs_bit]         <= #(dm_do_board_dly[dqs_bit])       phyio_dm[dqs_bit];      
         
      always @(posedge phyio_dm_oe[dqs_bit])      phyio_dm_oe_dly[dqs_bit]      <= #(dm_do_board_dly[dqs_bit])       phyio_dm_oe[dqs_bit];
      always @(negedge phyio_dm_oe[dqs_bit])      phyio_dm_oe_dly[dqs_bit]      <= #(dm_do_board_dly[dqs_bit])       phyio_dm_oe[dqs_bit];  

      always @(posedge phyio_dm_pdd[dqs_bit])     phyio_dm_pdd_dly[dqs_bit]     <= #(dm_pdd_board_dly[dqs_bit])      phyio_dm_pdd[dqs_bit];  
      always @(negedge phyio_dm_pdd[dqs_bit])     phyio_dm_pdd_dly[dqs_bit]     <= #(dm_pdd_board_dly[dqs_bit])      phyio_dm_pdd[dqs_bit]; 
      
      always @(posedge phyio_dm_pdr[dqs_bit])     phyio_dm_pdr_dly[dqs_bit]     <= #(dm_pdr_board_dly[dqs_bit])      phyio_dm_pdr[dqs_bit];  
      always @(negedge phyio_dm_pdr[dqs_bit])     phyio_dm_pdr_dly[dqs_bit]     <= #(dm_pdr_board_dly[dqs_bit])      phyio_dm_pdr[dqs_bit];  
      
      always @(posedge phyio_dm_te[dqs_bit])      phyio_dm_te_dly[dqs_bit]      <= #(dm_te_board_dly[dqs_bit] )      phyio_dm_te[dqs_bit];        
      always @(negedge phyio_dm_te[dqs_bit])      phyio_dm_te_dly[dqs_bit]      <= #(dm_te_board_dly[dqs_bit] )      phyio_dm_te[dqs_bit];         

      //DQS Delays
      always @(posedge phyio_ds[dqs_bit])         phyio_ds_dly[dqs_bit]         <= #(dqs_do_board_dly[dqs_bit])     phyio_ds[dqs_bit];
      always @(negedge phyio_ds[dqs_bit])         phyio_ds_dly[dqs_bit]         <= #(dqs_do_board_dly[dqs_bit])     phyio_ds[dqs_bit];

      always @(posedge phyio_ds_oe[dqs_bit])      phyio_ds_oe_dly[dqs_bit]      <= #(dqs_do_board_dly[dqs_bit])     phyio_ds_oe[dqs_bit];
      always @(negedge phyio_ds_oe[dqs_bit])      phyio_ds_oe_dly[dqs_bit]      <= #(dqs_do_board_dly[dqs_bit])     phyio_ds_oe[dqs_bit];      
 
      always @(posedge phyio_ds_n[dqs_bit])       phyio_dsn_dly[dqs_bit]        <= #(dqsn_do_board_dly[dqs_bit])    phyio_ds_n[dqs_bit];
      always @(negedge phyio_ds_n[dqs_bit])       phyio_dsn_dly[dqs_bit]        <= #(dqsn_do_board_dly[dqs_bit])    phyio_ds_n[dqs_bit];
      
      always @(posedge phyio_ds_n_oe[dqs_bit])    phyio_dsn_oe_dly[dqs_bit]     <= #(dqsn_do_board_dly[dqs_bit])    phyio_ds_n_oe[dqs_bit];
      always @(negedge phyio_ds_n_oe[dqs_bit])    phyio_dsn_oe_dly[dqs_bit]     <= #(dqsn_do_board_dly[dqs_bit])    phyio_ds_n_oe[dqs_bit];      
         
      always @(posedge phyio_dqs_g_dout[dqs_bit]) phyio_dqs_g_dout_dly[dqs_bit] <= #(dqs_g_dout_board_dly[dqs_bit]) phyio_dqs_g_dout[dqs_bit];  
      always @(negedge phyio_dqs_g_dout[dqs_bit]) phyio_dqs_g_dout_dly[dqs_bit] <= #(dqs_g_dout_board_dly[dqs_bit]) phyio_dqs_g_dout[dqs_bit]; 
         
      always @(posedge phyio_dqs_g_oe[dqs_bit])   phyio_dqs_g_oe_dly[dqs_bit]   <= #(dqs_g_dout_board_dly[dqs_bit]) phyio_dqs_g_oe[dqs_bit];  
      always @(negedge phyio_dqs_g_oe[dqs_bit])   phyio_dqs_g_oe_dly[dqs_bit]   <= #(dqs_g_dout_board_dly[dqs_bit]) phyio_dqs_g_oe[dqs_bit]; 
         
      always @(posedge phyio_dqs_pdd[dqs_bit])    phyio_dqs_pdd_dly[dqs_bit]    <= #(dqs_pdd_board_dly[dqs_bit])    phyio_dqs_pdd[dqs_bit];  
      always @(negedge phyio_dqs_pdd[dqs_bit])    phyio_dqs_pdd_dly[dqs_bit]    <= #(dqs_pdd_board_dly[dqs_bit])    phyio_dqs_pdd[dqs_bit];  

      always @(posedge phyio_dqs_pdr[dqs_bit])    phyio_dqs_pdr_dly[dqs_bit]    <= #(dqs_pdr_board_dly[dqs_bit])    phyio_dqs_pdr[dqs_bit];  
      always @(negedge phyio_dqs_pdr[dqs_bit])    phyio_dqs_pdr_dly[dqs_bit]    <= #(dqs_pdr_board_dly[dqs_bit])    phyio_dqs_pdr[dqs_bit];       

      always @(posedge phyio_dqs_te[dqs_bit])     phyio_dqs_te_dly[dqs_bit]     <= #(dqs_te_board_dly[dqs_bit])     phyio_dqs_te[dqs_bit]; 
      always @(negedge phyio_dqs_te[dqs_bit])     phyio_dqs_te_dly[dqs_bit]     <= #(dqs_te_board_dly[dqs_bit])     phyio_dqs_te[dqs_bit];           
         
      always @(posedge phyio_dqs_n_pdd[dqs_bit])  phyio_dqs_n_pdd_dly[dqs_bit]  <= #(dqs_n_pdd_board_dly[dqs_bit])  phyio_dqs_n_pdd[dqs_bit];  
      always @(negedge phyio_dqs_n_pdd[dqs_bit])  phyio_dqs_n_pdd_dly[dqs_bit]  <= #(dqs_n_pdd_board_dly[dqs_bit])  phyio_dqs_n_pdd[dqs_bit];        

      always @(posedge phyio_dqs_n_pdr[dqs_bit])  phyio_dqs_n_pdr_dly[dqs_bit]  <= #(dqs_n_pdr_board_dly[dqs_bit])  phyio_dqs_n_pdr[dqs_bit];  
      always @(negedge phyio_dqs_n_pdr[dqs_bit])  phyio_dqs_n_pdr_dly[dqs_bit]  <= #(dqs_n_pdr_board_dly[dqs_bit])  phyio_dqs_n_pdr[dqs_bit];       

      always @(posedge phyio_dqs_n_te[dqs_bit])   phyio_dqs_n_te_dly[dqs_bit]   <= #(dqs_n_te_board_dly[dqs_bit])   phyio_dqs_n_te[dqs_bit];
      always @(negedge phyio_dqs_n_te[dqs_bit])   phyio_dqs_n_te_dly[dqs_bit]   <= #(dqs_n_te_board_dly[dqs_bit])   phyio_dqs_n_te[dqs_bit];      
         
      always @(posedge phyio_dqs_g_pdd[dqs_bit])  phyio_dqs_g_pdd_dly[dqs_bit]  <= #(dqs_g_pdd_board_dly[dqs_bit])  phyio_dqs_g_pdd[dqs_bit];  
      always @(negedge phyio_dqs_g_pdd[dqs_bit])  phyio_dqs_g_pdd_dly[dqs_bit]  <= #(dqs_g_pdd_board_dly[dqs_bit])  phyio_dqs_g_pdd[dqs_bit];        

      always @(posedge phyio_dqs_g_pdr[dqs_bit])  phyio_dqs_g_pdr_dly[dqs_bit]  <= #(dqs_g_pdr_board_dly[dqs_bit])  phyio_dqs_g_pdr[dqs_bit];  
      always @(negedge phyio_dqs_g_pdr[dqs_bit])  phyio_dqs_g_pdr_dly[dqs_bit]  <= #(dqs_g_pdr_board_dly[dqs_bit])  phyio_dqs_g_pdr[dqs_bit];
      
      always @(posedge phyio_dqs_g_te[dqs_bit])   phyio_dqs_g_te_dly[dqs_bit]   <= #(dqs_g_te_board_dly[dqs_bit])   phyio_dqs_g_te[dqs_bit];  
      always @(negedge phyio_dqs_g_te[dqs_bit])   phyio_dqs_g_te_dly[dqs_bit]   <= #(dqs_g_te_board_dly[dqs_bit])   phyio_dqs_g_te[dqs_bit];  
    end
  endgenerate

  initial begin
    integer i;
    for(i=0;i<pNO_OF_DX_DQS;i=i+1) begin
      qs_posedge_det[i]  =0;
      qs_negedge_det[i]  =0;
      qs_did_posedge_det[i]  =0;
      qs_did_negedge_det[i]  =0;
      qsn_posedge_det[i] =0;
      qsn_negedge_det[i] =0;
      qm_posedge_det[i]  =0;
      qm_negedge_det[i]  =0;
    end
    q_posedge_det[0] = 0;
    q_posedge_det[1] = 0;
    q_posedge_det[2] = 0;
    q_posedge_det[3] = 0;
    q_posedge_det[4] = 0;
    q_posedge_det[5] = 0;
    q_posedge_det[6] = 0;
    q_posedge_det[7] = 0;
    q_negedge_det[0] = 0;
    q_negedge_det[1] = 0;
    q_negedge_det[2] = 0;
    q_negedge_det[3] = 0;
    q_negedge_det[4] = 0;
    q_negedge_det[5] = 0;
    q_negedge_det[6] = 0;
    q_negedge_det[7] = 0;
  end  

  generate
  for(dqs_bit=0; dqs_bit<pNO_OF_DX_DQS; dqs_bit=dqs_bit+1) begin : dqs_dm_di_dly
    //iDM delays
    always @(posedge phyio_qm[dqs_bit]) begin
       qm_posedge_det[dqs_bit] = $time ;
       qm_posedge_val[dqs_bit] = phyio_qm[dqs_bit];
       #0;
       if (qm_negedge_det[dqs_bit] == qm_posedge_det[dqs_bit]) begin
         if (phyio_qm[dqs_bit] === 1'b1) begin
             phyio_qm_dly[dqs_bit]  <=  #(dm_di_board_dly[dqs_bit]) phyio_qm[dqs_bit];
         end
       end
       else begin
           phyio_qm_dly[dqs_bit]  <= #(dm_di_board_dly[dqs_bit]) phyio_qm[dqs_bit];
       end  
    end     
    
    always @(negedge phyio_qm[dqs_bit]) begin
       qm_negedge_det[dqs_bit] = $time ;
       qm_negedge_val[dqs_bit] = phyio_qm[dqs_bit];
       #0;
       if (qm_negedge_det[dqs_bit] == qm_posedge_det[dqs_bit]) begin
         if (phyio_qm[dqs_bit] === 1'b0) begin
             phyio_qm_dly[dqs_bit]  <=  #(dm_di_board_dly[dqs_bit]) phyio_qm[dqs_bit];
         end
       end
       else begin
           phyio_qm_dly[dqs_bit]  <= #(dm_di_board_dly[dqs_bit]) phyio_qm[dqs_bit];
       end  
    end
    
    //iDQS delays
    always @(posedge phyio_qs[dqs_bit]) begin
       qs_posedge_det[dqs_bit] = $time ;
       qs_posedge_val[dqs_bit] = phyio_qs[dqs_bit];
       #0;
      if (((qs_posedge_val[dqs_bit] === 1'bx)&&(qs_negedge_val[dqs_bit] !== 1'b0)) || 
          ((qs_posedge_val[dqs_bit] === 1'b1) && (qs_negedge_det[dqs_bit] != qs_posedge_det[dqs_bit]))) begin
           phyio_qs_dly[dqs_bit]  <= #(dqs_di_board_dly[dqs_bit]) phyio_qs[dqs_bit];
      end
    end   
    
    always @(negedge phyio_qs[dqs_bit]) begin
       qs_negedge_det[dqs_bit] = $time ;
       qs_negedge_val[dqs_bit] = phyio_qs[dqs_bit];
       #0;
       if (((qs_negedge_val[dqs_bit] === 1'bx)&&(qs_posedge_val[dqs_bit] !== 1'b1)) || 
           ((qs_negedge_val[dqs_bit] === 1'b0) && (qs_negedge_det[dqs_bit] != qs_posedge_det[dqs_bit]))) begin
           phyio_qs_dly[dqs_bit] <= #(dqs_di_board_dly[dqs_bit]) phyio_qs[dqs_bit];
       end   
    end   
    
    //iDQS DID delays
    always @(posedge phyio_qs_did[dqs_bit]) begin
       qs_did_posedge_det[dqs_bit] = $time ;
       qs_did_posedge_val[dqs_bit] = phyio_qs[dqs_bit];
       #0;
      if (((qs_did_posedge_val[dqs_bit] === 1'bx)&&(qs_did_negedge_val[dqs_bit] !== 1'b0)) || 
          ((qs_did_posedge_val[dqs_bit] === 1'b1) && (qs_did_negedge_det[dqs_bit] != qs_did_posedge_det[dqs_bit]))) begin
           phyio_qs_did_dly[dqs_bit]  <= #(dqs_did_board_dly[dqs_bit]) phyio_qs_did[dqs_bit];
      end
    end   
    
    always @(negedge phyio_qs_did[dqs_bit]) begin
       qs_did_negedge_det[dqs_bit] = $time ;
       qs_did_negedge_val[dqs_bit] = phyio_qs[dqs_bit];
       #0;
       if (((qs_did_negedge_val[dqs_bit] === 1'bx)&&(qs_did_posedge_val[dqs_bit] !== 1'b1)) || 
           ((qs_did_negedge_val[dqs_bit] === 1'b0) && (qs_did_negedge_det[dqs_bit] != qs_did_posedge_det[dqs_bit]))) begin
           phyio_qs_did_dly[dqs_bit] <= #(dqs_did_board_dly[dqs_bit]) phyio_qs_did[dqs_bit];
       end   
    end   
    
    //iDQSN delays
    always @(posedge phyio_qs_n[dqs_bit]) begin
       qsn_posedge_det[dqs_bit] = $time ;
       qsn_posedge_val[dqs_bit] = phyio_qs_n[dqs_bit];
       #0;
      if (((qsn_posedge_val[dqs_bit] === 1'bx)&&(qsn_negedge_val[dqs_bit] !== 1'b0)) ||
          ((qsn_posedge_val[dqs_bit] === 1'b1) && (qsn_negedge_det[dqs_bit] != qsn_posedge_det[dqs_bit]))) begin
          phyio_qsn_dly[dqs_bit] <= #(dqsn_di_board_dly[dqs_bit]) phyio_qs_n[dqs_bit];
      end     
    end     
    
    always @(negedge phyio_qs_n[dqs_bit]) begin
       qsn_negedge_det[dqs_bit] = $time ;
       qsn_negedge_val[dqs_bit] = phyio_qs_n[dqs_bit];
       #0;
      if (((qsn_negedge_val[dqs_bit] === 1'bx)&&(qsn_posedge_val[dqs_bit] !== 1'b1)) ||
          ((qsn_negedge_val[dqs_bit] === 1'b0) && (qsn_negedge_det[dqs_bit] != qsn_posedge_det[dqs_bit]))) begin
          phyio_qsn_dly[dqs_bit] <= #(dqsn_di_board_dly[dqs_bit]) phyio_qs_n[dqs_bit];
      end
    end      
       
    //iDQSG delays  
    always @(posedge phyio_dqs_g_di[dqs_bit]) phyio_dqs_g_di_dly[dqs_bit]  <= #(dqs_g_di_board_dly[dqs_bit]) phyio_dqs_g_di[dqs_bit];  
    always @(negedge phyio_dqs_g_di[dqs_bit]) phyio_dqs_g_di_dly[dqs_bit]  <= #(dqs_g_di_board_dly[dqs_bit]) phyio_dqs_g_di[dqs_bit]; 

  end
endgenerate
    
  //DQ delays
  generate
  for(dx_bit=0; dx_bit<8; dx_bit=dx_bit+1) begin : gdx_bit

    //oDQ delays
    always @(posedge phyio_d[dx_bit])    phyio_d_dly[dx_bit]     <= #(dq_do_board_dly[dx_bit]) phyio_d[dx_bit];
    always @(negedge phyio_d[dx_bit])    phyio_d_dly[dx_bit]     <= #(dq_do_board_dly[dx_bit]) phyio_d[dx_bit];
    
    always @(posedge phyio_d_oe[dx_bit]) phyio_d_oe_dly[dx_bit]  <= #(dq_do_board_dly[dx_bit]) phyio_d_oe[dx_bit];
    always @(negedge phyio_d_oe[dx_bit]) phyio_d_oe_dly[dx_bit]  <= #(dq_do_board_dly[dx_bit]) phyio_d_oe[dx_bit];
    
    //iDQ delays
    always @(posedge phyio_q[dx_bit]) begin: g_bit_q_posedge_delays
      q_posedge_det[dx_bit] = $time ;
      #0;
      if (q_negedge_det[dx_bit] == q_posedge_det[dx_bit]) begin
        if (phyio_q[dx_bit] === 1'b1)
          phyio_q_dly[dx_bit]  <= #(dq_di_board_dly[dx_bit]) phyio_q[dx_bit];
      end   
      else begin
        phyio_q_dly[dx_bit]  <= #(dq_di_board_dly[dx_bit]) phyio_q[dx_bit];
      end                                           
    end 
    
    always @(negedge phyio_q[dx_bit]) begin: g_bit_q_negedge_delays
     q_negedge_det[dx_bit] = $time ;
     #0;
     if (q_negedge_det[dx_bit] == q_posedge_det[dx_bit]) begin
       if (phyio_q[dx_bit] === 1'b0)
         phyio_q_dly[dx_bit]  <= #(dq_di_board_dly[dx_bit]) phyio_q[dx_bit];
     end   
     else begin
       phyio_q_dly[dx_bit]  <= #(dq_di_board_dly[dx_bit]) phyio_q[dx_bit];
     end                                           
    end 
    
    //PDD, PDR, TE
    always@(posedge phyio_dq_pdd[dx_bit]) phyio_dq_pdd_dly[dx_bit]  <= #(dq_pdd_board_dly[dx_bit]) phyio_dq_pdd[dx_bit];
    always@(negedge phyio_dq_pdd[dx_bit]) phyio_dq_pdd_dly[dx_bit]  <= #(dq_pdd_board_dly[dx_bit]) phyio_dq_pdd[dx_bit];
      
    always@(posedge phyio_dq_pdr[dx_bit]) phyio_dq_pdr_dly[dx_bit]  <= #(dq_pdr_board_dly[dx_bit]) phyio_dq_pdr[dx_bit];
    always@(negedge phyio_dq_pdr[dx_bit]) phyio_dq_pdr_dly[dx_bit]  <= #(dq_pdr_board_dly[dx_bit]) phyio_dq_pdr[dx_bit];    
      
    always@(posedge phyio_dq_te[dx_bit])  phyio_dq_te_dly[dx_bit]   <= #(dq_te_board_dly[dx_bit])  phyio_dq_te[dx_bit];
    always@(negedge phyio_dq_te[dx_bit])  phyio_dq_te_dly[dx_bit]   <= #(dq_te_board_dly[dx_bit])  phyio_dq_te[dx_bit];    
    
  end // block: gdx_bit
  
  endgenerate

endmodule // dx_board_dly
