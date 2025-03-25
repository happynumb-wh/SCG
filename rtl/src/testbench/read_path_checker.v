//-----------------------------------------------------------------------------
//
// Copyright (c) 2013 Synopsys Incorporated.				   
// 									   
// This file contains confidential, proprietary information and trade	   
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written	   
// permission of Synopsys Incorporated. 				   
// 
// DESCRIPTION: DDR PHY verification "read path" checker
//-----------------------------------------------------------------------------
// 
// - probes DDR Read DQ / DQS path signals to continuously verify the following:
//    * QS gate is properly framing the sequence of read strobes, according to
//      the selected gate mode of operation
//    * the read FIFO input (writing) clock and data transitions meet specified
//      setup/hold timing
//    * the read and write FIFO pointers pass through each position with enough
//      cycles elapsed to validate STA assumptions
//-----------------------------------------------------------------------------

`timescale 1ps / 1fs

module read_path_checker();

// --- FIFO checker parameters
parameter   pFIFO_RD_PTR_GAP =  2.5  ; //number of FIFO input (writing) clock cycles gap required for data read from any position
parameter   pFIFO_WR_SETUP   =  0.15 ; //FIFO writing setup time in fraction of the write clock period
parameter   pFIFO_WR_HOLD    =  0.15 ; //FIFO writing hold time in fraction of the write clock period
parameter   pVERBOSITY       =  1    ; // 0 = no messages
                                       // 1 = flag any FIFO violations once, QS gate check errors once
                                       // 2 = flag any FIFO violations and QS gate check errors or warnings, everytime

parameter      pSDRAM_WR_SETUP  =     0.15   ;
parameter      pSDRAM_WR_HOLD   =     0.15   ;

`ifdef VMM_VERIF
  int      pCLK_PRD_ps  = 1000;
`else
  parameter      pCLK_PRD_ps       =   (`CLK_PRD * 1e3)  ;
`endif

reg      enable_fifo_sh_checks  ;
reg      enable_fifo_ptr_checks ;
reg      enable_fifo_ouflow_checks  ;
reg      sdram_enable_sh_checks ; 
reg      warning_severity       ;                

initial begin
  enable_fifo_sh_checks         = 1'b0  ;
  enable_fifo_ptr_checks        = 1'b0  ;
  enable_fifo_ouflow_checks     = 1'b0  ;
  sdram_enable_sh_checks        = 1'b0  ;
  warning_severity              = 1'b0  ;
end  

//FIFO writing signals
reg         datx8_dq_rbdl_do_n [`DWC_NO_OF_BYTES-1 :0][9:0][3:0]     ;  //9 bits in DATX8 + DQS
reg         datx8_qs_first_clk [`DWC_NO_OF_BYTES-1 :0][9:0][3:0]     ;  //clocks for first sampling stage of BDL output
//FIFO reading signals are read directly from DXn (bit-independent)
reg [3:0]        datx8_rd_ptr       [`DWC_NO_OF_BYTES-1 :0]     ;  //read pointer
//reg [`DWC_NO_OF_BYTES-1 :0]        datx8_ctl_rd_clk             ;  //FIFO read clock
//Setup/hold checks
real  t_fifo_wr_clk        [`DWC_NO_OF_BYTES-1 :0][9:0][3:0]      ;  //$realtime stamp for qs_fifo instances write clock
real  t_fifo_wr            [`DWC_NO_OF_BYTES-1 :0][9:0][3:0]      ; 

real  t_sdram_wr_strobe    [`DWC_NO_OF_RANKS-1 :0][`DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS-1 :0]      ;  //$realtime stamp for qs_fifo instances write clock
reg   sdram_pre_dq         [`DWC_NO_OF_RANKS-1 :0][`DWC_NO_OF_BYTES-1 :0]      ;
real  t_sdram_wr           [`DWC_NO_OF_RANKS-1 :0][`DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS-1 :0][7:0] ;

real  t_fifo_wr_posx       [`DWC_NO_OF_BYTES-1 :0][3:0] ;

reg   [3:0]    t_fifo_seq_check_b0  [`DWC_NO_OF_BYTES-1 :0]   ;
reg   [3:0]    t_fifo_seq_check_b1  [`DWC_NO_OF_BYTES-1 :0]   ;

integer   bit_idx   ;

reg  [`DWC_NO_OF_BYTES*11-1 : 0]   violations_history           ;    
reg  [`DWC_NO_OF_BYTES*8 -1 : 0]   sdram_violations_history     ;
reg  [`DWC_NO_OF_BYTES*`DWC_DX_NO_OF_DQS   -1 : 0]   sdram_sh_checks_valid        ;

initial begin
  violations_history        =  {(`DWC_NO_OF_BYTES*11){1'b0}} ;   //the MSByte is for FIFO gap violations
  sdram_violations_history  =  {(`DWC_NO_OF_BYTES*8){1'b0}} ;
end

event ev_debug  ;


`ifdef SYNTHESIS
`else
  `ifdef VMM_VERIF
  //---------------------------------------------------------------------------
  //pragma synthesis_off
  //---------------------------------------------------------------------------
  //  SVA
  //---------------------------------------------------------------------------
  vmm_log log = new("tb_read_path_checker", "tb_read_path_checker");
  // Assertions for overflow and underflow of fifos
  property check_fifo_write_error(clk,address,fifo_state);
    @(posedge clk) ( (($onehot(address) && !(| (address & fifo_state)) ) || (!address)) || !enable_fifo_ouflow_checks);
  endproperty
  
  property check_fifo_read_error(clk,address,fifo_state);
    @(posedge clk) ( (($onehot0(address) && (| (address & fifo_state)) ) || (!address)) || !enable_fifo_ouflow_checks);
  endproperty
  //---------------------------------------------------------------------------
  //pragma synthesis_on
  //---------------------------------------------------------------------------
  `endif
`endif

`ifndef DWC_DDRPHY_EMUL_XILINX

generate
genvar dwc_byte, dwc_dim, dwc_rnk, bit_no, clk_idx ;
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  u_sig_probes
  initial  datx8_dq_rbdl_do_n [dwc_byte][0][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][0][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][1][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][1][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][2][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][2][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][3][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][3][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][4][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][4][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][5][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][5][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][6][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][6][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][7][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][7][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][8][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][8][1] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][9][0] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][9][1] = 1'b0 ;
`ifdef SDRAMx4
  initial  datx8_dq_rbdl_do_n [dwc_byte][9][2] = 1'b0 ;
  initial  datx8_dq_rbdl_do_n [dwc_byte][9][3] = 1'b0 ;
`endif
  initial  datx8_qs_first_clk [dwc_byte][0][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][0][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][1][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][1][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][2][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][2][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][3][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][3][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][4][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][4][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][5][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][5][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][6][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][6][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][7][0] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][7][1] = 1'b1 ;
  initial  datx8_qs_first_clk [dwc_byte][8][0] = 1'b0 ;
  initial  datx8_qs_first_clk [dwc_byte][8][1] = 1'b0 ;
  initial  datx8_qs_first_clk [dwc_byte][9][0] = 1'b0 ;
  initial  datx8_qs_first_clk [dwc_byte][9][1] = 1'b0 ;
`ifdef SDRAMx4
  initial  datx8_qs_first_clk [dwc_byte][9][2] = 1'b0 ;
  initial  datx8_qs_first_clk [dwc_byte][9][3] = 1'b0 ;
`endif
  //signal probes
  always@(`DATX8_DQ0_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][0][0] = `DATX8_DQ0_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ0_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][0][1] = `DATX8_DQ0_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ1_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][1][0] = `DATX8_DQ1_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ1_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][1][1] = `DATX8_DQ1_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ2_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][2][0] = `DATX8_DQ2_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ2_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][2][1] = `DATX8_DQ2_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ3_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][3][0] = `DATX8_DQ3_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ3_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][3][1] = `DATX8_DQ3_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ4_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][4][0] = `DATX8_DQ4_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ4_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][4][1] = `DATX8_DQ4_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ5_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][5][0] = `DATX8_DQ5_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ5_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][5][1] = `DATX8_DQ5_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ6_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][6][0] = `DATX8_DQ6_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ6_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][6][1] = `DATX8_DQ6_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ7_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][7][0] = `DATX8_DQ7_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ7_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][7][1] = `DATX8_DQ7_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ8_INSTANCE.qs_q_ff.D)  datx8_dq_rbdl_do_n [dwc_byte][8][0] = `DATX8_DQ8_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQ8_INSTANCE.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][8][1] = `DATX8_DQ8_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;

`ifdef SDRAMx4
  always@(`DATX8_DQS_INSTANCE_X4_0.qs_q_ff.D)      datx8_dq_rbdl_do_n [dwc_byte][9][0] = `DATX8_DQS_INSTANCE_X4_0.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE_X4_0.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][9][1] = `DATX8_DQS_INSTANCE_X4_0.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE_X4_1.qs_q_ff.D)      datx8_dq_rbdl_do_n [dwc_byte][9][2] = `DATX8_DQS_INSTANCE_X4_1.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE_X4_1.qs_n_q_ff_1.D)  datx8_dq_rbdl_do_n [dwc_byte][9][3] = `DATX8_DQS_INSTANCE_X4_1.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
`else
  always@(`DATX8_DQS_INSTANCE.qs_q_ff.D)           datx8_dq_rbdl_do_n [dwc_byte][9][0] = `DATX8_DQS_INSTANCE.qs_q_ff.D /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE.qs_n_q_ff_1.D)       datx8_dq_rbdl_do_n [dwc_byte][9][1] = `DATX8_DQS_INSTANCE.qs_n_q_ff_1.D /*rbdl_do_n*/ ;
`endif
  
  always@(`DATX8_DQ0_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][0][0] = `DATX8_DQ0_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ0_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][0][1] = `DATX8_DQ0_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ1_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][1][0] = `DATX8_DQ1_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ1_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][1][1] = `DATX8_DQ1_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ2_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][2][0] = `DATX8_DQ2_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ2_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][2][1] = `DATX8_DQ2_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ3_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][3][0] = `DATX8_DQ3_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ3_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][3][1] = `DATX8_DQ3_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ4_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][4][0] = `DATX8_DQ4_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ4_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][4][1] = `DATX8_DQ4_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ5_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][5][0] = `DATX8_DQ5_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ5_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][5][1] = `DATX8_DQ5_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ6_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][6][0] = `DATX8_DQ6_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ6_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][6][1] = `DATX8_DQ6_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ7_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][7][0] = `DATX8_DQ7_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ7_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][7][1] = `DATX8_DQ7_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ8_INSTANCE.qs_q_ff.CK)  datx8_qs_first_clk [dwc_byte][8][0] = `DATX8_DQ8_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQ8_INSTANCE.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][8][1] = `DATX8_DQ8_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;

`ifdef SDRAMx4
  always@(`DATX8_DQS_INSTANCE_X4_0.qs_q_ff.CK)      datx8_qs_first_clk [dwc_byte][9][0] = `DATX8_DQS_INSTANCE_X4_0.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE_X4_0.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][9][1] = `DATX8_DQS_INSTANCE_X4_0.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE_X4_1.qs_q_ff.CK)      datx8_qs_first_clk [dwc_byte][9][2] = `DATX8_DQS_INSTANCE_X4_1.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE_X4_1.qs_n_q_ff_1.CK)  datx8_qs_first_clk [dwc_byte][9][3] = `DATX8_DQS_INSTANCE_X4_1.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
`else
  always@(`DATX8_DQS_INSTANCE.qs_q_ff.CK)           datx8_qs_first_clk [dwc_byte][9][0] = `DATX8_DQS_INSTANCE.qs_q_ff.CK /*rbdl_do_n*/ ;
  always@(`DATX8_DQS_INSTANCE.qs_n_q_ff_1.CK)       datx8_qs_first_clk [dwc_byte][9][1] = `DATX8_DQS_INSTANCE.qs_n_q_ff_1.CK /*rbdl_do_n*/ ;
`endif
/*  
  always@(`DATX8_DQ1_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][1] = `DATX8_DQ1_INSTANCE.rbdl_do_n ;
  always@(`DATX8_DQ2_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][2] = `DATX8_DQ2_INSTANCE.rbdl_do_n ;
  always@(`DATX8_DQ3_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][3] = `DATX8_DQ3_INSTANCE.rbdl_do_n ;
  always@(`DATX8_DQ4_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][4] = `DATX8_DQ4_INSTANCE.rbdl_do_n ;
  always@(`DATX8_DQ5_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][5] = `DATX8_DQ5_INSTANCE.rbdl_do_n ;
  always@(`DATX8_DQ6_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][6] = `DATX8_DQ6_INSTANCE.rbdl_do_n ;
  always@(`DATX8_DQ7_INSTANCE.rbdl_do_n)  datx8_dq_rbdl_do_n [dwc_byte][7] = `DATX8_DQ7_INSTANCE.rbdl_do_n ;
*/
end  // loop dwc_byte

//setup/hold checks
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  u_sh_checks
  for (clk_idx = 0; clk_idx < 2; clk_idx = clk_idx + 1) begin :  u_sh_checks_clkidx
    for (bit_no = 0; bit_no < 9; bit_no = bit_no + 1) begin :  u_sh_checks_clkidx_bit
      initial     t_fifo_wr_clk [dwc_byte][bit_no][clk_idx] = -1000.0 ;
      always@(posedge datx8_qs_first_clk [dwc_byte][bit_no][clk_idx])
        
`ifdef SDRAMx4
        if ((`DATX8_DQS_INSTANCE.dqs_gate.qs_gate_nand.Y==1'b1 && (bit_no<4)) || 
            (`DATX8_DQS_INSTANCE_X4_1.dqs_gate.qs_gate_nand.Y==1'b1 && (bit_no>3)))  begin  //if DQS gate is 0 there will be no qsn clock
`else
        if (`DATX8_DQS_INSTANCE.dqs_gate.qs_gate_nand.Y==1'b1)  begin  //if DQS gate is 0 there will be no qsn clock
`endif

          if (($realtime - t_fifo_wr[dwc_byte][bit_no][clk_idx])/pCLK_PRD_ps < pFIFO_WR_SETUP  && enable_fifo_sh_checks) begin
            if ( ((pVERBOSITY == 1)&&(violations_history[dwc_byte*10 + bit_no]==1'b0)) || (pVERBOSITY == 2))
            `ifdef VMM_VERIF
              `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO setup time violation for byte %0d bit %0d",dwc_byte,bit_no));
            `else
              $display("[QS FIFO checker]   Read path FIFO setup time violation for byte %0d bit %0d at time %0t",dwc_byte,bit_no,$time);
            `endif  
            violations_history[dwc_byte*10 + bit_no] = 1'b1 ;
            `ifndef VMM_VERIF
              if (warning_severity==1'b1) `SYS.warning ;
            `endif
          end
        t_fifo_wr_clk [dwc_byte][bit_no][clk_idx] = $realtime;
      end
      
      initial     t_fifo_wr [dwc_byte][bit_no][clk_idx] = -10.0 ;   
      always@(datx8_dq_rbdl_do_n [dwc_byte][bit_no][clk_idx]) begin
        if (($realtime - t_fifo_wr_clk [dwc_byte][bit_no][clk_idx])/pCLK_PRD_ps < pFIFO_WR_HOLD  && enable_fifo_sh_checks) begin
          if ( ((pVERBOSITY == 1)&&(violations_history[dwc_byte*10 + bit_no]==1'b0)) || (pVERBOSITY == 2))
          `ifdef VMM_VERIF
            `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO hold time violation for byte %0d bit %0d",dwc_byte,bit_no));
          `else
            $display("[QS FIFO checker]   Read path FIFO hold time violation for byte %0d bit %0d at time %0t",dwc_byte,bit_no,$time);
          `endif  
          violations_history[dwc_byte*10 + bit_no] = 1'b1 ;
          `ifndef VMM_VERIF
            if (warning_severity==1'b1) `SYS.warning ;
          `endif
        end  
        t_fifo_wr [dwc_byte][bit_no][clk_idx] = $realtime;
      end    
    end  //u_sh_checks_clkidx_bit 
    
    initial     t_fifo_wr_clk [dwc_byte][9][clk_idx]   = -1000.0 ;
    initial     t_fifo_wr_clk [dwc_byte][9][clk_idx+2] = -1000.0 ;
  
    always@(posedge datx8_qs_first_clk [dwc_byte][9][clk_idx]) 
      if (`DATX8_DQS_INSTANCE.dqs_gate.qs_gate_nand.Y==1'b1) begin  //if DQS gate is 0 there will be no qsn clock
        if (($realtime - t_fifo_wr[dwc_byte][9][clk_idx])/pCLK_PRD_ps < pFIFO_WR_SETUP  && enable_fifo_sh_checks) begin
          if ( ((pVERBOSITY == 1)&&(violations_history[dwc_byte*10 + 9]==1'b0)) || (pVERBOSITY == 2))
          `ifdef VMM_VERIF
            `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO setup time violation for byte %0d DQS",dwc_byte));
          `else
            $display("[QS FIFO checker]   Read path FIFO setup time violation for byte %0d DQS at time %0t",dwc_byte,$time);
          `endif  
          violations_history[dwc_byte*10 + 9] = 1'b1 ;
          `ifndef VMM_VERIF
            if (warning_severity==1'b1) `SYS.warning ;
          `endif
        end
      t_fifo_wr_clk [dwc_byte][9][clk_idx]   = $realtime ;
    end

    always@(posedge datx8_qs_first_clk [dwc_byte][9][clk_idx+2]) 
      if (`DATX8_DQS_INSTANCE_X4_1.dqs_gate.qs_gate_nand.Y==1'b1) begin  //if DQS gate is 0 there will be no qsn clock
        if (($realtime - t_fifo_wr[dwc_byte][9][clk_idx+2])/pCLK_PRD_ps < pFIFO_WR_SETUP  && enable_fifo_sh_checks) begin
          if ( ((pVERBOSITY == 1)&&(violations_history[dwc_byte*10 + 9]==1'b0)) || (pVERBOSITY == 2))
          `ifdef VMM_VERIF
            `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO setup time violation for byte %0d DQS",dwc_byte));
          `else
            $display("[QS FIFO checker]   Read path FIFO setup time violation for byte %0d DQS at time %0t",dwc_byte,$time);
          `endif  
          violations_history[dwc_byte*10 + 9] = 1'b1 ;
          `ifndef VMM_VERIF
            if (warning_severity==1'b1) `SYS.warning ;
          `endif
        end
      t_fifo_wr_clk [dwc_byte][9][clk_idx+2] = $realtime ;
    end
    
    initial     t_fifo_wr [dwc_byte][9][clk_idx]   = -10.0 ;   
    initial     t_fifo_wr [dwc_byte][9][clk_idx+2] = -10.0 ;  
 
    always@(datx8_dq_rbdl_do_n [dwc_byte][9][clk_idx]) begin
      if (($realtime - t_fifo_wr_clk [dwc_byte][9][clk_idx])/pCLK_PRD_ps < pFIFO_WR_HOLD  && enable_fifo_sh_checks) begin
        if ( ((pVERBOSITY == 1)&&(violations_history[dwc_byte*10 + 9]==1'b0)) || (pVERBOSITY == 2))
        `ifdef VMM_VERIF
          `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO hold time violation for byte %0d DQS",dwc_byte));
        `else
          $display("[QS FIFO checker]   Read path FIFO hold time violation for byte %0d DQS at time %0t",dwc_byte,$time);
        `endif  
        violations_history[dwc_byte*10 + 9] = 1'b1 ;
        `ifndef VMM_VERIF
          if (warning_severity==1'b1) `SYS.warning ;
        `endif
      end  
      t_fifo_wr [dwc_byte][9][clk_idx] = $realtime ;
    end 
    
    always@(datx8_dq_rbdl_do_n [dwc_byte][9][clk_idx+2]) begin
      if (($realtime - t_fifo_wr_clk [dwc_byte][9][clk_idx+2])/pCLK_PRD_ps < pFIFO_WR_HOLD  && enable_fifo_sh_checks) begin
        if ( ((pVERBOSITY == 1)&&(violations_history[dwc_byte*10 + 9]==1'b0)) || (pVERBOSITY == 2))
        `ifdef VMM_VERIF
          `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO hold time violation for byte %0d DQS",dwc_byte));
        `else
          $display("[QS FIFO checker]   Read path FIFO hold time violation for byte %0d DQS at time %0t",dwc_byte,$time);
        `endif  
        violations_history[dwc_byte*10 + 9] = 1'b1 ;
        `ifndef VMM_VERIF
          if (warning_severity==1'b1) `SYS.warning ;
        `endif
      end  
      t_fifo_wr [dwc_byte][9][clk_idx+2] = $realtime ;
    end 
    
  end // loop bit_no  
end  // loop dwc_byte

//sufficient pointer gap
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  u_ptr_checks
  initial begin
    t_fifo_wr_posx[dwc_byte][0] = -500.0 ;
    t_fifo_wr_posx[dwc_byte][1] = -500.0 ;
    t_fifo_wr_posx[dwc_byte][2] = -500.0 ;
    t_fifo_wr_posx[dwc_byte][3] = -500.0 ;
    t_fifo_seq_check_b0[dwc_byte]  = 4'b0000 ;
    t_fifo_seq_check_b1[dwc_byte]  = 4'b0000 ;
  end
  always@(posedge `DATX8_DQS_INSTANCE.qs_n_dly_clk) 
    case(`DATX8_DQS_INSTANCE.qs_n_ptr[7:4])  //one-hot encoding alternating between FIFO registers     
    4'b0010 :  begin 
                 t_fifo_wr_posx[dwc_byte][1] <= $realtime ;
                 if ((t_fifo_seq_check_b1[dwc_byte] & 4'b0010) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 1 / high segment without preceding read out for byte %0d",dwc_byte));
                   `else
                     $display("[QS FIFO checker]   FIFO pointer written to position 1 / high segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] | 4'b0010 ;
               end
    4'b0001 :  begin 
                 t_fifo_wr_posx[dwc_byte][0] <= $realtime ;
                 if ((t_fifo_seq_check_b1[dwc_byte] & 4'b0001) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 0 / high segment without preceding read out for byte %0d",dwc_byte));
                   `else
                     $display("[QS FIFO checker]   FIFO pointer written to position 0 / high segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif   
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif 
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] | 4'b0001 ;
               end 
    4'b0100 :  begin 
                 t_fifo_wr_posx[dwc_byte][2] <= $realtime ;
                 if ((t_fifo_seq_check_b1[dwc_byte] & 4'b0100) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 2 / high segment without preceding read out for byte %0d",dwc_byte));
                   `else
                     $display("[QS FIFO checker]   FIFO pointer written to position 2 / high segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] | 4'b0100 ;
               end
    4'b1000 :  begin 
                 t_fifo_wr_posx[dwc_byte][3] <= $realtime ;
                 if ((t_fifo_seq_check_b1[dwc_byte] & 4'b1000) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 3 / high segment without preceding read out for byte %0d",dwc_byte));
                   `else
                     $display("[QS FIFO checker]   FIFO pointer written to position 3 / high segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] | 4'b1000 ;
               end
    //4'b0000 :  begin end  // This is expected - writing to the other FIFO segment
    default :  if (`DATX8_DQS_INSTANCE.qs_n_ptr[7:4]!=4'b0000) begin
                 `ifdef VMM_VERIF
                   `vmm_warning(log, "[QS FIFO checker]  Warning -> FIFO write pointer captured with inconsistent value!");
                 `else
                   $display("[QS FIFO checker]  Warning -> FIFO write pointer captured with inconsistent value at %0t",$time);
                 `endif
                 `ifndef VMM_VERIF
                   if (warning_severity==1'b1) `SYS.warning ;
                 `endif
               end  
    endcase
    
  always@(posedge `DATX8_DQS_INSTANCE.qs_n_dly_clk) 
    case(`DATX8_DQS_INSTANCE.qs_n_ptr[3:0])  //one-hot encoding alternating between FIFO registers   
    4'b0010 :  begin 
                 t_fifo_wr_posx[dwc_byte][1] <= $realtime ;
                 if ((t_fifo_seq_check_b0[dwc_byte] & 4'b0010) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 1 / low segment without preceding read out for byte %0d",dwc_byte));
                   `else
                     $display("[QS FIFO checker]   FIFO pointer written to position 1 / low segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] | 4'b0010 ;
               end
    4'b0001 :  begin 
                 t_fifo_wr_posx[dwc_byte][0] <= $realtime ;
                 if ((t_fifo_seq_check_b0[dwc_byte] & 4'b0001) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 0 / low segment without preceding read out for byte %0d",dwc_byte));
                   `else                   
                     $display("[QS FIFO checker]   FIFO pointer written to position 0 / low segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] | 4'b0001 ;
               end   
    4'b0100 :  begin 
                 t_fifo_wr_posx[dwc_byte][2] <= $realtime ;
                 if ((t_fifo_seq_check_b0[dwc_byte] & 4'b0100) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 2 / low segment without preceding read out for byte %0d",dwc_byte));
                   `else  
                     $display("[QS FIFO checker]   FIFO pointer written to position 2 / low segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] | 4'b0100 ;
               end
    4'b1000 :  begin 
                 t_fifo_wr_posx[dwc_byte][3] <= $realtime ;
                 if ((t_fifo_seq_check_b0[dwc_byte] & 4'b1000) && enable_fifo_ouflow_checks) begin
                   if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                   `ifdef VMM_VERIF
                     `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer written to position 3 / low segment without preceding read out for byte %0d",dwc_byte));
                   `else                    
                     $display("[QS FIFO checker]   FIFO pointer written to position 3 / low segment without preceding read out for byte %0d at time %0t",dwc_byte,$time);
                   `endif  
                   violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
                 end
                 if (enable_fifo_ouflow_checks) t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] | 4'b1000 ;
               end
    //4'b0000 :  begin end  // This is expected - writing to the other FIFO segment
    default :  if (`DATX8_DQS_INSTANCE.qs_n_ptr[3:0]!=4'b0000) begin
                 $display("[QS FIFO checker]  Warning -> FIFO write pointer captured with inconsistent value at %0t",$time);
                   `ifndef VMM_VERIF
                     if (warning_severity==1'b1) `SYS.warning ;
                   `endif
               end  
    endcase
    
  initial   datx8_rd_ptr [dwc_byte] = 4'b0000 ;
    
  always@(posedge `DATX8_DQS_INSTANCE.ctl_rd_clk) begin
    if ((`DATX8_DQS_INSTANCE.rd_ptr != datx8_rd_ptr[dwc_byte]) && (datx8_rd_ptr[dwc_byte]!=4'b0000) && (`DATX8_DQS_INSTANCE.rd_sync_rst_n)) begin
      case(`DATX8_DQS_INSTANCE.rd_ptr)  //full case (one hot encoding)
      4'b0010   :  begin
                     if ( ($realtime - t_fifo_wr_posx[dwc_byte][1])/pCLK_PRD_ps < pFIFO_RD_PTR_GAP && enable_fifo_ptr_checks ) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d",dwc_byte));
                       `else                         
                         $display("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     if (((t_fifo_seq_check_b0[dwc_byte] | 4'b1101) != 4'b1111) && ((t_fifo_seq_check_b1[dwc_byte] | 4'b1101) != 4'b1111) && enable_fifo_ouflow_checks) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer read from position 1 without having been written for byte %0d",dwc_byte));
                       `else 
                         $display("[QS FIFO checker]   FIFO pointer read from position 1 without having been written for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] & 4'b1101 ;
                     t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] & 4'b1101 ;
                   end    
      4'b0001   :  begin
                     if ( ($realtime - t_fifo_wr_posx[dwc_byte][0])/pCLK_PRD_ps < pFIFO_RD_PTR_GAP && enable_fifo_ptr_checks ) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d",dwc_byte));
                       `else                        
                         $display("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     if (((t_fifo_seq_check_b0[dwc_byte] | 4'b1110) != 4'b1111) && ((t_fifo_seq_check_b1[dwc_byte] | 4'b1110) != 4'b1111) && enable_fifo_ouflow_checks) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer read from position 0 without having been written for byte %0d",dwc_byte));
                       `else 
                         $display("[QS FIFO checker]   FIFO pointer read from position 0 without having been written for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] & 4'b1110 ;
                     t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] & 4'b1110 ;
                   end  
      4'b0100   :  begin
                     if ( ($realtime - t_fifo_wr_posx[dwc_byte][2])/pCLK_PRD_ps < pFIFO_RD_PTR_GAP && enable_fifo_ptr_checks ) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d",dwc_byte));
                       `else 
                         $display("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     if (((t_fifo_seq_check_b0[dwc_byte] | 4'b1011) != 4'b1111) && ((t_fifo_seq_check_b1[dwc_byte] | 4'b1011) != 4'b1111) && enable_fifo_ouflow_checks) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer read from position 2 without having been written for byte %0d",dwc_byte));
                       `else 
                         $display("[QS FIFO checker]   FIFO pointer read from position 2 without having been written for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] & 4'b1011 ;
                     t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] & 4'b1011 ;
                   end    
      4'b1000   :  begin
                     if ( ($realtime - t_fifo_wr_posx[dwc_byte][3])/pCLK_PRD_ps < pFIFO_RD_PTR_GAP && enable_fifo_ptr_checks ) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d",dwc_byte));
                       `else 
                         $display("[QS FIFO checker]   Read path FIFO pointer gap violation for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     if (((t_fifo_seq_check_b0[dwc_byte] | 4'b0111) != 4'b1111) && ((t_fifo_seq_check_b1[dwc_byte] | 4'b0111) != 4'b1111) && enable_fifo_ouflow_checks) begin
                       if ( ((pVERBOSITY == 1)&&(violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte]==1'b0)) || (pVERBOSITY == 2))
                       `ifdef VMM_VERIF
                         `vmm_warning(log, $psprintf("[QS FIFO checker]   FIFO pointer read from position 3 without having been written for byte %0d",dwc_byte));
                       `else 
                         $display("[QS FIFO checker]   FIFO pointer read from position 3 without having been written for byte %0d at time %0t",dwc_byte,$time);
                       `endif  
                       violations_history[`DWC_NO_OF_BYTES*10 + dwc_byte] <= 1'b1 ;
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                     end
                     t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] & 4'b0111 ;
                     t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] & 4'b0111 ;
                   end 
                                
      default   :  begin
                   `ifdef VMM_VERIF
                     `vmm_warning(log, "[QS FIFO checker]  Warning -> FIFO read pointer captured with inconsistent value!");
                   `else  
                     $display("[QS FIFO checker]  Warning -> FIFO read pointer captured with inconsistent value at %0t",$time);
                   `endif 
                      `ifndef VMM_VERIF
                        if (warning_severity==1'b1) `SYS.warning ;
                      `endif
                   end     
      endcase
    end
    else begin
      t_fifo_seq_check_b0[dwc_byte] <= t_fifo_seq_check_b0[dwc_byte] & ~`DATX8_DQS_INSTANCE.rd_ptr ;
      t_fifo_seq_check_b1[dwc_byte] <= t_fifo_seq_check_b1[dwc_byte] & ~`DATX8_DQS_INSTANCE.rd_ptr ;
    end
    
    datx8_rd_ptr [dwc_byte] <= `DATX8_DQS_INSTANCE.rd_ptr ;    
  end  
end  // loop dwc_byte


//SDRAM-side setup and hold checks
`ifdef DWC_DDRPHY_X4X2  
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  u_sdram_sh_checks_valid
  //DQS_0E [0]
  always@(posedge `DXn_IO.dqs_oe[0]) begin  //wait for writes to distinguish from reads
    sdram_sh_checks_valid[dwc_byte*2] <= sdram_enable_sh_checks ;
    while (`DXn_IO.dqs_oe[0] || (`DXn_IO.dqs[0] !== 1'bz)) @(`DXn_IO.dqs_oe[0] or `DXn_IO.dqs[0]);
    sdram_sh_checks_valid[dwc_byte*2]   <= 1'b0 ;
  end
  `ifdef DWC_DDRPHY_X4MODE 
  //DQS_0E [1]
  always@(posedge `DXn_IO.dqs_oe[1]) begin  //wait for writes to distinguish from reads
    sdram_sh_checks_valid[dwc_byte*2+1] <= sdram_enable_sh_checks ;
    while (`DXn_IO.dqs_oe[1] || (`DXn_IO.dqs[1] !== 1'bz)) @(`DXn_IO.dqs_oe[1] or `DXn_IO.dqs[1]);
    sdram_sh_checks_valid[dwc_byte*2+1] <= 1'b0 ;
  end
  `endif
end
  
`else
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  u_sdram_sh_checks_valid
  always@(posedge `DXn_IO.dqs_oe) begin  //wait for writes to distinguish from reads
    sdram_sh_checks_valid[dwc_byte] <= sdram_enable_sh_checks ;
    while (`DXn_IO.dqs_oe || (`DXn_IO.dqs !== 1'bz)) @(`DXn_IO.dqs_oe or `DXn_IO.dqs);
    sdram_sh_checks_valid[dwc_byte] <= 1'b0 ;
  end
end
      
`endif
  


  
//setup/hold checks
`ifdef DWC_USE_SHARED_AC
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES/2; dwc_byte = dwc_byte + 1) begin :  u_sdram_sh_checks
`else
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  u_sdram_sh_checks
`endif
  for (dwc_dim = 0; dwc_dim < `DWC_NO_OF_DIMMS; dwc_dim = dwc_dim + 1) begin :  u_sdram_sh_checks_rnk
    for (dwc_rnk = 0; dwc_rnk < `DWC_RANKS_PER_DIMM; dwc_rnk = dwc_rnk + 1) begin :  u_sdram_sh_checks_rnk_2
    initial sdram_pre_dq[dwc_dim][dwc_byte]  = 1'bz ;
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS
    `ifdef SDRAMx32
      always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dq_i[8*(dwc_byte % 4)+: 8]) sdram_pre_dq[dwc_dim][dwc_byte] = #0.1 ^`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dq_i[8*(dwc_byte % 4)+: 8] ;
    `elsif SDRAMx16
      always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dq_i[8*(dwc_byte % 2)+: 8]) sdram_pre_dq[dwc_dim][dwc_byte] = #0.1 ^`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dq_i[8*(dwc_byte % 2)+: 8] ;
    `else  
      always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dq_i) sdram_pre_dq[dwc_dim][dwc_byte] = #0.1 ^`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dq_i ;
    `endif
  `else
    `ifdef SDRAMx32
      always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dq[8*(dwc_byte % 4)+: 8]) sdram_pre_dq[dwc_dim][dwc_byte] = #0.1 ^`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dq[8*(dwc_byte % 4)+: 8] ;
    `elsif SDRAMx16
      always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dq[8*(dwc_byte % 2)+: 8]) sdram_pre_dq[dwc_dim][dwc_byte] = #0.1 ^`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dq[8*(dwc_byte % 2)+: 8] ;
    `else  
      always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dq) sdram_pre_dq[dwc_dim][dwc_byte] = #0.1 ^`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dq ;
    `endif
  `endif
    
    initial     t_sdram_wr_strobe [dwc_dim][dwc_byte] = -1000.0 ;
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS
    `ifdef SDRAMx32
      always@(posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dqs_i[dwc_byte % 4] or posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dqs_n_i[dwc_byte % 4])  
      if ( (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dqs_i[dwc_byte % 4]!==1'bz) && (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dqs_n_i[dwc_byte % 4]!==1'bz) && 
           (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bz) && (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bx) ) begin
    `elsif SDRAMx16
      always@(posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dqs_i[dwc_byte % 2] or posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dqs_n_i[dwc_byte % 2])  
      if ( (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dqs_i[dwc_byte % 2]!==1'bz) && (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dqs_n_i[dwc_byte % 2]!==1'bz) && 
           (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bz) && (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bx) ) begin
    `else
      always@(posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dqs_i or posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dqs_n_i) 
      if ( (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dqs_i!==1'bz) && (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dqs_n_i!==1'bz) && 
           (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bz) && (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bx) ) begin
    `endif  
  `else
    `ifdef SDRAMx32
      always@(posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dqs[dwc_byte % 4] or posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dqs_n[dwc_byte % 4])  
      if ( (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dqs[dwc_byte % 4]!==1'bz) && (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dqs_n[dwc_byte % 4]!==1'bz) && 
           (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bz) && (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bx) ) begin
    `elsif SDRAMx16
      always@(posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dqs[dwc_byte % 2] or posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dqs_n[dwc_byte % 2])  
      if ( (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dqs[dwc_byte % 2]!==1'bz) && (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dqs_n[dwc_byte % 2]!==1'bz) && 
           (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bz) && (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bx) ) begin
    `else
      always@(posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dqs or posedge `RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dqs_n) 
      if ( (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dqs!==1'bz) && (`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dqs_n!==1'bz) && 
           (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bz) && (sdram_pre_dq[dwc_dim][dwc_byte]!==1'bx) ) begin
    `endif
  `endif
        
`ifdef SDRAMx4
      for (bit_idx = 0; bit_idx < 4; bit_idx = bit_idx + 1) 
`else
      for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) 
`endif

`ifdef DWC_NO_OF_DX_DQS_EQ_2
      if ((($realtime - t_sdram_wr[dwc_dim][dwc_byte][bit_idx])/pCLK_PRD_ps < pSDRAM_WR_SETUP  && sdram_sh_checks_valid[2*dwc_byte]) || 
          (($realtime - t_sdram_wr[dwc_dim][dwc_byte][bit_idx])/pCLK_PRD_ps < pSDRAM_WR_SETUP  && sdram_sh_checks_valid[2*dwc_byte+1]))begin
`else
      if (($realtime - t_sdram_wr[dwc_dim][dwc_byte][bit_idx])/pCLK_PRD_ps < pSDRAM_WR_SETUP  && sdram_sh_checks_valid[dwc_byte]) begin
`endif
`ifdef SDRAMx4
        if ( ((pVERBOSITY == 1)&&(sdram_violations_history[dwc_byte*4 + bit_idx]==1'b0)) || (pVERBOSITY == 2))
`else
        if ( ((pVERBOSITY == 1)&&(sdram_violations_history[dwc_byte*8 + bit_idx]==1'b0)) || (pVERBOSITY == 2))
`endif
          `ifdef VMM_VERIF
            `vmm_warning(log, $psprintf("[QS FIFO checker]   SDRAM write setup time violation for rank %0d byte %0d bit %0d",dwc_dim,dwc_byte,bit_idx));
          `else 
            $display("[QS FIFO checker]   SDRAM write setup time violation for rank %0d byte %0d bit %0d at time %0t",dwc_dim,dwc_byte,bit_idx,$time);
          `endif  
`ifdef SDRAMx4
        sdram_violations_history[dwc_byte*4 + bit_idx] = 1'b1 ;
`else
        sdram_violations_history[dwc_byte*8 + bit_idx] = 1'b1 ;
`endif
        `ifndef VMM_VERIF
          if (warning_severity==1'b1) `SYS.warning ;
        `endif
      end
      t_sdram_wr_strobe [dwc_dim][dwc_byte] = $realtime ;
    end

`ifdef SDRAMx4
    for (bit_no = 0; bit_no < 4; bit_no = bit_no + 1) begin :  u_sh_checks_bit_indx
`else
    for (bit_no = 0; bit_no < 8; bit_no = bit_no + 1) begin :  u_sh_checks_bit_indx
`endif
      initial begin
        t_sdram_wr [dwc_dim][dwc_byte][bit_no] = -10.0 ;    
      end
  `ifdef BIDIRECTIONAL_SDRAM_DELAYS      
    `ifdef SDRAMx32
        always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).board_delay_model.dq_i[(dwc_byte % 4)*8 + bit_no]) begin
    `elsif SDRAMx16
        always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).board_delay_model.dq_i[(dwc_byte % 2)*8 + bit_no]) begin
    `else
        always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).board_delay_model.dq_i[bit_no]) begin
    `endif
  `else         
    `ifdef SDRAMx32
        always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/4).dq[(dwc_byte % 4)*8 + bit_no]) begin
    `elsif SDRAMx16
        always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte/2).dq[(dwc_byte % 2)*8 + bit_no]) begin
    `else
        always@(`RAM_PROBE(dwc_dim,dwc_rnk,dwc_byte).dq[bit_no]) begin
    `endif
  `endif

`ifdef DWC_NO_OF_DX_DQS_EQ_2
        if ((($realtime - t_sdram_wr_strobe [dwc_dim][dwc_byte])/pCLK_PRD_ps < pSDRAM_WR_HOLD  && sdram_sh_checks_valid[2*dwc_byte]) ||
            (($realtime - t_sdram_wr_strobe [dwc_dim][dwc_byte])/pCLK_PRD_ps < pSDRAM_WR_HOLD  && sdram_sh_checks_valid[2*dwc_byte+1]))  begin
`else
        if (($realtime - t_sdram_wr_strobe [dwc_dim][dwc_byte])/pCLK_PRD_ps < pSDRAM_WR_HOLD  && sdram_sh_checks_valid[dwc_byte]) begin
`endif
          
`ifdef SDRAMx4
          if ( ((pVERBOSITY == 1)&&(sdram_violations_history[dwc_byte*4 + bit_no]==1'b0)) || (pVERBOSITY == 2))
`else
          if ( ((pVERBOSITY == 1)&&(sdram_violations_history[dwc_byte*8 + bit_no]==1'b0)) || (pVERBOSITY == 2))
`endif
          `ifdef VMM_VERIF
            `vmm_warning(log, $psprintf("[QS FIFO checker]   SDRAM write hold time violation for rank %0d byte %0d bit %0d",dwc_dim,dwc_byte,bit_no));
          `else           
            $display("[QS FIFO checker]   SDRAM write hold time violation for rank %0d byte %0d bit %0d at time %0t",dwc_dim,dwc_byte,bit_no,$time);
          `endif  
          `ifdef SDRAMx4
            sdram_violations_history[dwc_byte*4 + bit_no] = 1'b1 ;
          `else
            sdram_violations_history[dwc_byte*8 + bit_no] = 1'b1 ;
          `endif
          `ifndef VMM_VERIF
            if (warning_severity==1'b1) `SYS.warning ;
          `endif
        end  
        t_sdram_wr [dwc_dim][dwc_byte][bit_no] = $realtime ;
      end 
    end  // loop bit_indx
  end
  end   // loop dwc_dim
end  // loop dwc_byte

`ifdef SYNTHESIS
`else
  `ifdef VMM_VERIF
  //---------------------------------------------------------------------------
  //pragma synthesis_off
  //---------------------------------------------------------------------------
//assertions array
for (dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin :  sva_read_path_checker_assert_array
  sva_rd_checker_wr_err_1 : assert property (check_fifo_write_error(`DATX8_DQS_INSTANCE.qs_n_dly_clk,`DATX8_DQS_INSTANCE.qs_n_ptr[7:4],t_fifo_seq_check_b1[dwc_byte]))
    else `vmm_error(log, $psprintf("SVA ERROR: Read path FIFO writing to unread position in byte %0d",dwc_byte));
  sva_rd_checker_wr_err_0 : assert property (check_fifo_write_error(`DATX8_DQS_INSTANCE.qs_n_dly_clk,`DATX8_DQS_INSTANCE.qs_n_ptr[3:0],t_fifo_seq_check_b0[dwc_byte]))
    else `vmm_error(log, $psprintf("SVA ERROR: Read path FIFO writing to unread position in byte %0d",dwc_byte));
  sva_rd_checker_rd_err_0 : assert property (check_fifo_read_error(`DATX8_DQS_INSTANCE.ctl_rd_clk,`DATX8_DQS_INSTANCE.rd_ptr,t_fifo_seq_check_b0[dwc_byte]))
    else `vmm_error(log, $psprintf("SVA ERROR: Read path FIFO reading from unwritten position in byte %0d",dwc_byte));
  sva_rd_checker_rd_err_1 : assert property (check_fifo_read_error(`DATX8_DQS_INSTANCE.ctl_rd_clk,`DATX8_DQS_INSTANCE.rd_ptr,t_fifo_seq_check_b1[dwc_byte]))
    else `vmm_error(log, $psprintf("SVA ERROR: Read path FIFO reading from unwritten position in byte %0d",dwc_byte));
end
  //---------------------------------------------------------------------------
  //pragma synthesis_on
  //---------------------------------------------------------------------------
  `endif  
`endif

endgenerate
`endif

endmodule   
  
