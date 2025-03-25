//-----------------------------------------------------------------------------
//
// Copyright (c) 2011 Synopsys Incorporated.				   
// 									   
// This file contains confidential, proprietary information and trade	   
// secrets of Synopsys. No part of this document may be used, reproduced   
// or transmitted in any form or by any means without prior written	   
// permission of Synopsys Incorporated. 				   
// 
// DESCRIPTION: DDR PHY verification "eye diagram" plotter
//-----------------------------------------------------------------------------
// 
//  - probes DDR Write and Read DQ / DQS / DQS# both prior to the PHY's delay
//    lines which adjust timing for the signals and after those delay lines
//  - a master flag eye_monitor_active is set to enable the recording of signal
//    timings into a series of 60-bit histograms, spanning 3 DDR clock periods 
//    with 20 points per period
//  - the Read eye diagram shows the PHY's capability in creating the DQ/DQS
//    quadrature phase relationship and compensating DQ skew; the Write eye
//    diagram shows the PHY's capability to compensate the modeled board delays
//    through its own delay lines
//  - In the Write eye diagrams (under non-ideal conditions), DQ and DQS are 
//    supposed to be unaligned at the PHY's delay lines (to compensate the board
//    delays), resulting in near-perfect alignment at the SDRAM. Conversely, for
//    Read eyes, data prior to the PHY's delay lines is supposed to reflect the
//    non-ideal board delays applied, whereas after the delay lines the alignment
//    should be again near-perfect
//  - this module includes a series of auxiliary tasks to generate the eye plots
//    into a simulator text log file and assist in data training algorithms 
//    verification:
//      print_eye_diagrams -> this task creates the ASCII framing and plots the
//        60-bit eye alignment (timing histogram) in graphic form, for a single 
//        byte lane (0 to DWC_NO_OF_BYTES) or all (-1)
//      get_eye_plots -> wrapper task for simplified eye diagram plotting. Calls
//        NO_OF_ACCESSES memory accesses (WR+RD) each with NO_BL8S_EYE_SCOPE to
//        obtain information for the eye diagrams, and plots them for the chosen
//        byte lane (or all)
//      compare_dl_vs_tb -> exceuting this task after training completes reads
//        out the converged delay line tap selection values and compares them
//        with the testbench-applied DQ skew and DQ-to-DQS delay:
//            RD DQS LCDL + RD DQS BDL - avg RD DQ BDL = 1/2 DDR clk - dqs_delay
//            WR DQ LCDL + avg WR DQ BDL - WR DQS BDL = 1/2 DDR clk + dqs_delay
//            max WR DQ BDLs - min WR DQ BDLs = write DQ pk-pk skew
//            max RD DQ BDLs - min RD DQ BDLs = read DQ pk-pk skew
//      update_dl_step_value -> auxiliary task for compare_dl_vs_tb to get the 
//         present delay line unit step value (nominally 10ps) for the above
//         comparisons
//      check_training_status -> reads out PGSR0, DXnGSR0, DTEDR0, DTEDR1 to 
//         evaluate the data training error/warning bits and DL spans. Comparison
//         with PGSR0 / DXnGSR0 expected values causes the internal variables
//         error_vector and warning_vector to be set for the corresponding failed
//         or warned data training step:
//            bit 0 -> WL step 1 error/warning
//            bit 1 -> QS gate training error/warning
//            bit 2 -> WL step 2 error/warning
//            bit 3 -> RD bit deskewing error/warning
//            bit 4 -> WR bit deskewing error/warning
//            bit 5 -> RD eye centering error/warning
//            bit 6 -> WR eye centering error/warning
//            bit 7 -> delay line value comparison error/warning
//         and optionally according to the nowarn boolean input to the task,
//         `SYS.error and `SYS.warning are called
//      clear_error_flags -> resets error_vector and warning_vector
//
//-----------------------------------------------------------------------------
module eye_mnt();

  //only two different values are used for "ideal" DQ/DQS positions
  parameter  BASE_DQS_HIST  =   {20'd0,1'b1,19'd0,1'b1,19'd0}  ;
  parameter  BASE_DQ_HIST   =   {10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;
  parameter  WR_RD_GUARD_BAND  =   2   ;  //ns
  parameter  DQS_WIDTH  = (`SDRAM_DATA_WIDTH == 16) ?  2 : 1 ;

  `ifdef XTEND_EYE_DATA
  parameter NO_OF_ACCESSES = 250 ;
  parameter NO_BL8S_EYE_SCOPE = 500 ;   //only used for jitter testing, so makes sense to have same paramenter
  `else
  parameter NO_OF_ACCESSES = 5 ;
  parameter NO_BL8S_EYE_SCOPE = 10 ;
  `endif
  parameter BDL_DELAY_STEP_PS = 10 ;
 
  parameter DL_DELAY_TOLERANCE = 0.03 ; //adimensional; amount of tolerance in DL value checks before warning is flagged 

  parameter QS_GATE_CHECKER_TYPE = 1 ;
  parameter DQDQS_EYE_CHECKER_TOLERANCE = 2.0 ; //number of DL steps admitted as maximum tolerance in auto checking the DQ-DQS alignment
  parameter QS_GATE_CHECKER_TOLERANCE = 3.0 ; //number of DL steps admitted as maximum tolerance in auto checking the DQ-DQS alignment

// eye diagram plotting variables
  // READ -> probes on DQS/DQSN and DQ at input to PHY (i.e., after the DATX8_io where delays are inserted)
  wire   [`DWC_NO_OF_BYTES - 1 : 0]    rd_dqs_pre_dl    ;
  wire   [`DWC_NO_OF_BYTES - 1 : 0]    rd_dqsn_pre_dl   ;
  wire   [7:0]     rd_dq_pre_dl    [`DWC_NO_OF_BYTES - 1 : 0]   ;   
  reg   [7:0]     rd_dq_pre_dl_i    [`DWC_NO_OF_BYTES - 1 : 0]   ;                                      
  // READ -> probes on DQS/DQSN and DQ after delay lines (i.e., the actual data and strobe signals)
  //         may be more troublesome to probe on post-CTS sims
  wire   [`DWC_NO_OF_BYTES - 1 : 0]    rd_dqs_post_dl    ;
  wire   [`DWC_NO_OF_BYTES - 1 : 0]    rd_dqsn_post_dl   ;
  wire   [7:0]     rd_dq_post_dl    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  reg   [7:0]     rd_dq_post_dl_i    [`DWC_NO_OF_BYTES - 1 : 0]   ;                                      
  // WRITE -> probes on DQS/DQSN and DQ at output from PHY (i.e., after the DATX8_io where the alignment should be near-ideal)
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqs_pre_dl    ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqsn_pre_dl   ;
  wire    [7:0]     wr_dq_pre_dl    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    wr_dm_pre_dl    [`DWC_NO_OF_BYTES - 1 : 0]   ;                                      
  // WRITE -> probes on DQS/DQSN and DQ after board_delays block to observe effect of skewing to memory (and the PHY's compensation of it)
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqs_post_dl_0    ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqsn_post_dl_0   ;
  wire   [7:0]     wr_dq_post_dl_0    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    wr_dm_post_dl_0    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqs_post_dl_1    ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqsn_post_dl_1   ;
  wire   [7:0]     wr_dq_post_dl_1    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    wr_dm_post_dl_1    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqs_post_dl_2    ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqsn_post_dl_2   ;
  wire   [7:0]     wr_dq_post_dl_2    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    wr_dm_post_dl_2    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqs_post_dl_3    ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqsn_post_dl_3   ;
  wire   [7:0]     wr_dq_post_dl_3    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  wire    wr_dm_post_dl_3    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    qs_gate_probe     ;
  wire    [`DWC_NO_OF_BYTES - 1 : 0]    qs_bdl_out_probe  ;
  
  reg    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqs_post_dl    ;
  reg    [`DWC_NO_OF_BYTES - 1 : 0]    wr_dqsn_post_dl   ;
  reg   [7:0]     wr_dq_post_dl    [`DWC_NO_OF_BYTES - 1 : 0]   ;
  reg    wr_dm_post_dl   [`DWC_NO_OF_BYTES - 1 : 0]   ;
  integer    active_rnk  = 0 ;  
  
  event      clear_eye_monitors      ;
  
  reg        eye_monitoring_active   ;
  
  integer    dl_seeding_active   ;
  reg        use_masked_data     ;
  integer    masked_data_sel     ;
  
  real       read_dqs_dcd_value = 0.0 ;  //QS gate framing expected to deviate by -this/2 on the RE and +this/2 on the FE
                                    // i.e., positive value of read_dqs_dcd_value matches wider "1"s DCD on DQS
  
  reg        rd_predl_dqs_0dev_detect   [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        rd_predl_dqsn_0dev_detect  [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        rd_predl_dq_0dev_detect    [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        rd_postdl_dqs_0dev_detect  [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        rd_postdl_dqsn_0dev_detect [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        rd_postdl_dq_0dev_detect   [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_predl_dqs_0dev_detect   [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_predl_dqsn_0dev_detect  [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_predl_dq_0dev_detect    [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_predl_dm_0dev_detect    [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_postdl_dqs_0dev_detect  [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_postdl_dqsn_0dev_detect [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_postdl_dq_0dev_detect   [`DWC_NO_OF_BYTES - 1 : 0]      ;
  reg        wr_postdl_dm_0dev_detect   [`DWC_NO_OF_BYTES - 1 : 0]      ;
  
  //added by Jose to measure and output pk-pk DQ skew and max DQS-to-DQ displacement
  real       rd_predl_min_t  [`DWC_NO_OF_BYTES - 1 : 0]  ;
  real       rd_postdl_min_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_postdl_dqs_min_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_postdl_dqs_max_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_predl_min_t  [`DWC_NO_OF_BYTES - 1 : 0]  ;
  real       wr_postdl_min_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_predl_max_t  [`DWC_NO_OF_BYTES - 1 : 0]  ;
  real       rd_postdl_max_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_predl_max_t  [`DWC_NO_OF_BYTES - 1 : 0]  ;
  real       wr_postdl_max_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_postdl_dqs_min_t  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_postdl_dqs_max_t  [`DWC_NO_OF_BYTES - 1 : 0] ;

integer   indx  ;
integer   max_dq_rd_jitter  [`DWC_NO_OF_BYTES - 1 : 0] ;
integer   max_dqs_rd_jitter [`DWC_NO_OF_BYTES - 1 : 0] ;
integer   max_dq_wr_jitter  [`DWC_NO_OF_BYTES - 1 : 0] ;
integer   max_dqs_wr_jitter [`DWC_NO_OF_BYTES - 1 : 0] ;
  
  
  real       base_rd_predl_dqs_pos  [`DWC_NO_OF_BYTES - 1 : 0]       ;
  real       base_wr_predl_dqs_pos  [`DWC_NO_OF_BYTES - 1 : 0]       ;
  
  reg [59:0] rd_predl_dq_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;
  reg [59:0] wr_predl_dq_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ; 
  reg [59:0] wr_predl_dm_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;  
  reg [59:0] rd_predl_dqs_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;
  reg [59:0] wr_predl_dqs_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;   
  
  real       base_rd_postdl_dqs_pos  [`DWC_NO_OF_BYTES - 1 : 0]       ;
  real       base_wr_postdl_dqs_pos  [`DWC_NO_OF_BYTES - 1 : 0]       ;
  
  reg [59:0] rd_postdl_dq_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;
  reg [59:0] wr_postdl_dq_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ; 
  reg [59:0] wr_postdl_dm_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ; 
  reg [59:0] rd_postdl_dqs_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;
  reg [59:0] wr_postdl_dqs_histogram [`DWC_NO_OF_BYTES - 1 : 0]   ;
  
  integer    byte_cnt   ;
  integer    rd_predl_dqs_hist_bin_indx   [`DWC_NO_OF_BYTES - 1 : 0];
  integer    rd_predl_dq_hist_bin_indx    [`DWC_NO_OF_BYTES - 1 : 0];
  integer    wr_predl_dqs_hist_bin_indx   [`DWC_NO_OF_BYTES - 1 : 0];
  integer    wr_predl_dq_hist_bin_indx    [`DWC_NO_OF_BYTES - 1 : 0];
  integer    rd_postdl_dqs_hist_bin_indx  [`DWC_NO_OF_BYTES - 1 : 0];
  integer    rd_postdl_dq_hist_bin_indx   [`DWC_NO_OF_BYTES - 1 : 0];
  integer    wr_postdl_dqs_hist_bin_indx  [`DWC_NO_OF_BYTES - 1 : 0];
  integer    wr_postdl_dq_hist_bin_indx   [`DWC_NO_OF_BYTES - 1 : 0];
  
  real       rd_predl_dqs_dev   [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_predl_dqsn_dev  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_predl_dq_dev    [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_predl_dqs_dev   [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_predl_dqsn_dev  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_predl_dq_dev    [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_postdl_dqs_dev  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_postdl_dqsn_dev [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       rd_postdl_dq_dev   [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_postdl_dqs_dev  [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_postdl_dqsn_dev [`DWC_NO_OF_BYTES - 1 : 0] ;
  real       wr_postdl_dq_dev   [`DWC_NO_OF_BYTES - 1 : 0] ;
  
// QS gate checker variables
reg [`DWC_NO_OF_BYTES-1 : 0]          last_dqs_strobe_checker ;
real  t_gate_posedge [`DWC_NO_OF_BYTES-1 : 0] ;
real  t_1st_dqs_strobe [`DWC_NO_OF_BYTES-1 : 0] ;
real  t_last_dqs_strobe [`DWC_NO_OF_BYTES-1 : 0] ;
real  t_gate_negedge [`DWC_NO_OF_BYTES-1 : 0] ;
reg      enable_qsgate_checks   ;
initial  enable_qsgate_checks = 1'b0 ;

  event check_rd_dq_postdl_dev ;
  event check_rd_dq_dqs_postdl ;
  event check_wr_dq_postdl_dev ;
  event check_wr_dq_dqs_postdl ;
  event override_dl            ;

  //for write accesses to the memory, there is the need to safeguard them from triggering read histogram updates
  reg        [`DWC_NO_OF_BYTES - 1 : 0]  read_vs_write_guard  ;  
  
  // auxiliary tasks variables
  reg  [31:0]   tempstore ;
  real          expected_dl_step_value = 0.0    ;
  integer       last_bank   = 0            ;
  reg   [7:0]   error_vector               ;
  reg   [7:0]   warning_vector             ;
  integer       jitter_error_counter       ;

  reg /*unsigned*/   [7:0]  wr_dq_lcdl_value   , base_wr_dq_lcdl_value   ;
  reg /*unsigned*/   [7:0]  rd_dqs_lcdl_value  , base_rd_dqs_lcdl_value  ;
  reg /*unsigned*/   [5:0]  max_wr_dq_bdl_value    , min_wr_dq_bdl_value    , basemax_wr_dq_bdl_value    , basemin_wr_dq_bdl_value    ;
  reg /*unsigned*/   [5:0]  max_rd_dq_bdl_value    , min_rd_dq_bdl_value    , basemax_rd_dq_bdl_value    , basemin_rd_dq_bdl_value    ;
  reg /*unsigned*/   [5:0]  wr_dqs_bdl_value   , base_wr_dqs_bdl_value   ;
  reg /*unsigned*/   [5:0]  rd_dqs_bdl_value   , base_rd_dqs_bdl_value   ;
real   lhs_check_rd_dq_skew, lhs_check_rd_dq_dqs, lhs_check_wr_dq_skew, lhs_check_wr_dq_dqs ;
real   rhs_check_rd_dq_skew, rhs_check_rd_dq_dqs, rhs_check_wr_dq_skew, rhs_check_wr_dq_dqs ;
  
initial begin  
`ifdef DDR2  
  dl_seeding_active = 0 ;
`elsif PROBE_DATA_EYES
  `ifdef ALWAYS_SEED
     dl_seeding_active = 1 ;  
  `else `ifdef NEVER_SEED  
     dl_seeding_active = 0 ;
  `else   
    `SYS.RANDOM_RANGE(`SYS.seed_rr,0,1,dl_seeding_active) ;
  `endif `endif  
`else
  dl_seeding_active = 0 ;  
`endif
 
  if (dl_seeding_active==0) $display("[EYE_MNT - INFO] Delay lines are NOT seeded");
  else if (dl_seeding_active==1) $display("[EYE_MNT - INFO] Delay line seeding is ENABLED");
end
  
  initial begin
     eye_monitoring_active = 1'b0 ;
     for (byte_cnt=0; byte_cnt <`DWC_NO_OF_BYTES; byte_cnt=byte_cnt+1) begin
        base_rd_predl_dqs_pos[byte_cnt] = 0 ;
        base_wr_predl_dqs_pos[byte_cnt] = 0 ;
        rd_predl_dq_histogram[byte_cnt]   = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        wr_predl_dq_histogram[byte_cnt]   = BASE_DQ_HIST ;//{10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;  
        wr_predl_dm_histogram[byte_cnt]   = BASE_DQ_HIST ;
        rd_predl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        wr_predl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ; 
        base_rd_postdl_dqs_pos[byte_cnt] = 0 ;
        base_wr_postdl_dqs_pos[byte_cnt] = 0 ;
        rd_postdl_dq_histogram[byte_cnt]   = BASE_DQ_HIST ;//{10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;
        wr_postdl_dq_histogram[byte_cnt]   = BASE_DQ_HIST ;//{10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;
        wr_postdl_dm_histogram[byte_cnt]   = BASE_DQ_HIST ;
        rd_postdl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        wr_postdl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        
        rd_predl_min_t[byte_cnt] = 9999  ;
        rd_postdl_min_t[byte_cnt] = 9999  ;
        wr_predl_min_t[byte_cnt] = 9999  ;
        wr_postdl_min_t[byte_cnt] = 9999  ;
        rd_predl_max_t[byte_cnt] = -9999 ;
        rd_postdl_max_t[byte_cnt] = -9999 ;
        wr_predl_max_t[byte_cnt] = -9999 ;   
        wr_postdl_max_t[byte_cnt] = -9999 ;
        rd_postdl_dqs_min_t[byte_cnt] = 9999 ;
        rd_postdl_dqs_max_t[byte_cnt] = -9999 ;
        wr_postdl_dqs_min_t[byte_cnt] = 9999 ;
        wr_postdl_dqs_max_t[byte_cnt] = -9999 ;
             
        rd_predl_dqs_0dev_detect[byte_cnt]    = 1'b0     ;
        rd_predl_dqsn_0dev_detect[byte_cnt]   = 1'b0     ;
        rd_predl_dq_0dev_detect[byte_cnt]     = 1'b0     ;
        rd_postdl_dqs_0dev_detect[byte_cnt]   = 1'b0     ;
        rd_postdl_dqsn_0dev_detect[byte_cnt]  = 1'b0     ;
        rd_postdl_dq_0dev_detect[byte_cnt]    = 1'b0     ;
        wr_predl_dqs_0dev_detect[byte_cnt]    = 1'b0     ;
        wr_predl_dqsn_0dev_detect[byte_cnt]   = 1'b0     ;
        wr_predl_dq_0dev_detect[byte_cnt]     = 1'b0     ;
        wr_predl_dm_0dev_detect[byte_cnt]     = 1'b0     ;
        wr_postdl_dqs_0dev_detect[byte_cnt]   = 1'b0     ;
        wr_postdl_dqsn_0dev_detect[byte_cnt]  = 1'b0     ;
        wr_postdl_dq_0dev_detect[byte_cnt]    = 1'b0     ;
        wr_postdl_dm_0dev_detect[byte_cnt]    = 1'b0     ;
     end
  end
  always@(clear_eye_monitors)  begin
     for (byte_cnt=0; byte_cnt <`DWC_NO_OF_BYTES; byte_cnt=byte_cnt+1) begin
        base_rd_predl_dqs_pos[byte_cnt] = 0 ;
        base_wr_predl_dqs_pos[byte_cnt] = 0 ;
        rd_predl_dq_histogram[byte_cnt]   = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        wr_predl_dq_histogram[byte_cnt]   = BASE_DQ_HIST ;//{10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;  
        rd_predl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        wr_predl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ; 
        base_rd_postdl_dqs_pos[byte_cnt] = 0 ;
        base_wr_postdl_dqs_pos[byte_cnt] = 0 ;
        rd_postdl_dq_histogram[byte_cnt]   = BASE_DQ_HIST ;//{10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;
        wr_postdl_dq_histogram[byte_cnt]   = BASE_DQ_HIST ;//{10'd0,1'b1,19'd0,1'b1,19'd0,1'b1,9'd0} ;
        rd_postdl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        wr_postdl_dqs_histogram[byte_cnt]  = BASE_DQS_HIST ;//{20'd0,1'b1,19'd0,1'b1,19'd0}  ;
        
        rd_predl_min_t[byte_cnt] = 9999  ;
        rd_postdl_min_t[byte_cnt] = 9999  ;
        wr_predl_min_t[byte_cnt] = 9999  ;
        wr_postdl_min_t[byte_cnt] = 9999  ;
        rd_predl_max_t[byte_cnt] = -9999 ;
        rd_postdl_max_t[byte_cnt] = -9999 ;
        wr_predl_max_t[byte_cnt] = -9999 ;   
        wr_postdl_max_t[byte_cnt] = -9999 ;
        rd_postdl_dqs_min_t[byte_cnt] = 9999 ;
        rd_postdl_dqs_max_t[byte_cnt] = -9999 ;
        wr_postdl_dqs_min_t[byte_cnt] = 9999 ;
        wr_postdl_dqs_max_t[byte_cnt] = -9999 ;
        
        rd_predl_dqs_0dev_detect[byte_cnt]    = 1'b0     ;
        rd_predl_dqsn_0dev_detect[byte_cnt]   = 1'b0     ;
        rd_predl_dq_0dev_detect[byte_cnt]     = 1'b0     ;
        rd_postdl_dqs_0dev_detect[byte_cnt]   = 1'b0     ;
        rd_postdl_dqsn_0dev_detect[byte_cnt]  = 1'b0     ;
        rd_postdl_dq_0dev_detect[byte_cnt]    = 1'b0     ;
        wr_predl_dqs_0dev_detect[byte_cnt]    = 1'b0     ;
        wr_predl_dqsn_0dev_detect[byte_cnt]   = 1'b0     ;
        wr_predl_dq_0dev_detect[byte_cnt]     = 1'b0     ;
        wr_predl_dm_0dev_detect[byte_cnt]     = 1'b0     ;
        wr_postdl_dqs_0dev_detect[byte_cnt]   = 1'b0     ;
        wr_postdl_dqsn_0dev_detect[byte_cnt]  = 1'b0     ;
        wr_postdl_dq_0dev_detect[byte_cnt]    = 1'b0     ;
        wr_postdl_dm_0dev_detect[byte_cnt]    = 1'b0     ;
     end
  end
  
  generate
    genvar eye_byte;
    `ifdef DWC_USE_SHARED_AC
    for (eye_byte=0; eye_byte< `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 ; eye_byte=eye_byte+1) begin: u_set_ram_assigns                                
      //WRITE - after dx_board_dly.v the signals should be aligned for the SDRAM
      assign  wr_dqs_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;

      assign  wr_dqs_post_dl_1[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_1[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_1[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_1[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;

      assign  wr_dqs_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;

      assign  wr_dqs_post_dl_3[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_3[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_3[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_3[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
    end
    for (eye_byte=`DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2; eye_byte< `DWC_NO_OF_BYTES; eye_byte=eye_byte+1) begin: u_set_ram_assigns_ch1                               
      //WRITE - after dx_board_dly.v the signals should be aligned for the SDRAM
      assign  wr_dqs_post_dl_0[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_0[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_0[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_0[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
      
      assign  wr_dqs_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;

      assign  wr_dqs_post_dl_2[eye_byte] = `RAM_PROBE(3 % `DWC_NO_OF_RANKS,0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_2[eye_byte] = `RAM_PROBE(3 % `DWC_NO_OF_RANKS,0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_2[eye_byte] = `RAM_PROBE(3 % `DWC_NO_OF_RANKS,0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_2[eye_byte] = `RAM_PROBE(3 % `DWC_NO_OF_RANKS,0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;

      assign  wr_dqs_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0, (3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)/2 - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
    end
    `else
    //for (eye_byte=0; eye_byte<`DWC_NO_OF_BYTES; eye_byte=eye_byte+1) begin: u_set_ram_assigns                                
    for (eye_byte=0; eye_byte<`DWC_NO_OF_BYTES/(`SDRAM_DATA_WIDTH/8); eye_byte=eye_byte+1) begin: u_set_ram_assigns                                
      //WRITE - after dx_board_dly.v the signals should be aligned for the SDRAM
      assign  wr_dqs_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_0[eye_byte] = `RAM_PROBE(0 % `DWC_NO_OF_RANKS, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
      
      assign  wr_dqs_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_1[eye_byte] = `RAM_PROBE(0, 1 % `DWC_NO_OF_RANKS,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
      
      assign  wr_dqs_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_2[eye_byte] = `RAM_PROBE((`DWC_NO_OF_RANKS/2) - 1, 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
      
      assign  wr_dqs_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs[eye_byte % DQS_WIDTH]  ; 
      assign  wr_dqsn_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dqs_n[eye_byte % DQS_WIDTH]  ;
      assign  wr_dq_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dq[8*(eye_byte % DQS_WIDTH) +:8] ;
      assign  wr_dm_post_dl_3[eye_byte] = `RAM_PROBE((3 % `DWC_NO_OF_RANKS) > 1 ? 1 : 0,(3 % `DWC_NO_OF_RANKS) > 0 ? 1 : 0,(eye_byte - (eye_byte % DQS_WIDTH))/DQS_WIDTH).dm[eye_byte % DQS_WIDTH] ;
    end
    `endif  
  endgenerate    
              
  generate
     genvar dwc_byte;
     // set eye monitor probed signals
    for (dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) begin: u_set_assigns
      //READ
      assign  qs_gate_probe[dwc_byte] = `EYE_PROBE(dwc_byte).`DX_DQS0.dqs_gate.qs_n_gate ;
      assign  qs_bdl_out_probe[dwc_byte] = `EYE_PROBE(dwc_byte).`DX_DQS0.dqs_gate.qs_n_ungated_i ;
      // DXn_top = `PHY.dx[`DWC_dx_top_byte].dx_top.u_DWC_DDRPHYDATX8_top
      
      assign  rd_dqs_pre_dl[dwc_byte] = `DXn_top.dqs_di  ;
      assign  rd_dqsn_pre_dl[dwc_byte] = `DXn_top.dqs_n_di  ;
      assign  rd_dq_pre_dl[dwc_byte] = `DXn_top.dq_di ;
      
      assign  rd_dqs_post_dl[dwc_byte] = `EYE_PROBE(dwc_byte).`DX_DQS0.qs_clk  ;
      assign  rd_dqsn_post_dl[dwc_byte] = `EYE_PROBE(dwc_byte).`DX_DQS0.qs_n_clk  ;  //need to add Type B PHY support!
      assign  rd_dq_post_dl[dwc_byte] =  { `EYE_PROBE(dwc_byte).datx8_dq_7.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_6.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_5.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_4.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_3.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_2.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_1.rbdl_do_n ,
                                           `EYE_PROBE(dwc_byte).datx8_dq_0.rbdl_do_n } ;
      always@(*) case(active_rnk)
         0  :  begin
                 wr_dqs_post_dl[dwc_byte] = wr_dqs_post_dl_0[dwc_byte] ;
                 wr_dqsn_post_dl[dwc_byte] = wr_dqsn_post_dl_0[dwc_byte] ;
                 wr_dq_post_dl[dwc_byte] = wr_dq_post_dl_0[dwc_byte] ;
                 wr_dm_post_dl[dwc_byte] = wr_dm_post_dl_0[dwc_byte] ;
               end  
         1  :  begin
                 wr_dqs_post_dl[dwc_byte] = wr_dqs_post_dl_1[dwc_byte] ;
                 wr_dqsn_post_dl[dwc_byte] = wr_dqsn_post_dl_1[dwc_byte] ;
                 wr_dq_post_dl[dwc_byte] = wr_dq_post_dl_1[dwc_byte] ;
                 wr_dm_post_dl[dwc_byte] = wr_dm_post_dl_1[dwc_byte] ;
               end
         2  :  begin
                 wr_dqs_post_dl[dwc_byte] = wr_dqs_post_dl_2[dwc_byte] ;
                 wr_dqsn_post_dl[dwc_byte] = wr_dqsn_post_dl_2[dwc_byte] ;
                 wr_dq_post_dl[dwc_byte] = wr_dq_post_dl_2[dwc_byte] ;
                 wr_dm_post_dl[dwc_byte] = wr_dm_post_dl_2[dwc_byte] ;
               end
         3  :  begin
                 wr_dqs_post_dl[dwc_byte] = wr_dqs_post_dl_3[dwc_byte] ;
                 wr_dqsn_post_dl[dwc_byte] = wr_dqsn_post_dl_3[dwc_byte] ;
                 wr_dq_post_dl[dwc_byte] = wr_dq_post_dl_3[dwc_byte] ;
                 wr_dm_post_dl[dwc_byte] = wr_dm_post_dl_3[dwc_byte] ;
               end
         endcase      
      always@(rd_dq_pre_dl[dwc_byte]) rd_dq_pre_dl_i[dwc_byte] <= rd_dq_pre_dl[dwc_byte] ;
      always@(rd_dq_post_dl[dwc_byte]) rd_dq_post_dl_i[dwc_byte] <= rd_dq_post_dl[dwc_byte] ;
      
      // pre_dl write signals are actually probed after the Delay Lines, but allow for a mirror image of the board skews to be observed
      assign  wr_dqs_pre_dl[dwc_byte] = `EYE_PROBE(dwc_byte).ds  ;
      assign  wr_dqsn_pre_dl[dwc_byte] = `EYE_PROBE(dwc_byte).ds_n  ;
      assign  wr_dq_pre_dl[dwc_byte] = `EYE_PROBE(dwc_byte).d[7:0]  ; 
      assign  wr_dm_pre_dl[dwc_byte] = `EYE_PROBE(dwc_byte).d[8]  ;
      
    end
    // set eye monitor "always" processes
    for (dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) begin: u_set_monitors
      //GUARD
      // DXn_top = `PHY.dx[`DWC_dx_top_byte].dx_top.u_DWC_DDRPHYDATX8_top
      always@(`DXn_top.dqs_oe)
        if (`DXn_top.dqs_oe===1'b0) begin
           read_vs_write_guard[dwc_byte] = 1'bx ;
           read_vs_write_guard[dwc_byte] <= #(WR_RD_GUARD_BAND) 1'b1 ;
        end
        else if (`DXn_top.dqs_oe===1'b1) begin
           read_vs_write_guard[dwc_byte] = 1'bx ;
           read_vs_write_guard[dwc_byte] <= #(WR_RD_GUARD_BAND) 1'b0 ;
        end 
      //READ
      always@(posedge rd_dqs_pre_dl[dwc_byte]) begin #0.01;
        //it is normally impossible for a valid base DQS position to be "time 0" 
        if ( (eye_monitoring_active === 1'b1) && (base_rd_predl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b1) ) begin
           //find the offset (positive or negative) to the "nominal" DQS strobe position measured by
           //whole clock periods counted from base_rd_predl_dqs_pos
           rd_predl_dqs_dev[dwc_byte] = ($realtime-base_rd_predl_dqs_pos[dwc_byte])/`CLK_PRD 
                              //$rtoi function truncates rather than rounding, so we are left with the fractional part of the SDR-converted timestamp
                              - $rtoi(($realtime-base_rd_predl_dqs_pos[dwc_byte])/`CLK_PRD) ;
           //if fractional part of SDR-converted timestamp is > 0.5 SDR, signal is being captured e.g. after 79.8 SDR from base point instead of 80
           // -> a negative deviation.   
           if (rd_predl_dqs_dev[dwc_byte] > 0.5)  rd_predl_dqs_dev[dwc_byte] = rd_predl_dqs_dev[dwc_byte] - 1.0 ;  //already in U.I.
           rd_predl_dqs_dev[dwc_byte] = rd_predl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period 
           //histogram bins span 3 DDR CLK periods, with 20 points per each period:
           //   1 period before DQS strobe
           //   1 period from DQS to DQS# (nominal)
           //   1 period after DQS# strobe
           rd_predl_dqs_hist_bin_indx[dwc_byte] = $rtoi(rd_predl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;  //compensate $rtoi trunc.
           if (rd_predl_dqs_hist_bin_indx[dwc_byte] < 0)    rd_predl_dqs_histogram[dwc_byte] = rd_predl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*rd_predl_dqs_hist_bin_indx[dwc_byte])) & 60'h003ff_ffc00_00000);
           else  rd_predl_dqs_histogram[dwc_byte] = rd_predl_dqs_histogram[dwc_byte] | 
           /*don't affect DQS#*/ ((BASE_DQS_HIST >> rd_predl_dqs_hist_bin_indx[dwc_byte]) & 60'h003ff_ffc00_00000); 
           if (rd_predl_dqs_hist_bin_indx[dwc_byte]==0)   rd_predl_dqs_0dev_detect[dwc_byte]  = 1'b1 ;
        end
      end
      always@(posedge rd_dqsn_pre_dl[dwc_byte]) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_rd_predl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b1) ) begin
           //the "nominal" DQS# strobe position is offset from DQS nominal by 0.5*`CLK_PRD        
           //for DQS# just need to subtract 0.5 off the result   
           rd_predl_dqs_dev[dwc_byte] = ($realtime-base_rd_predl_dqs_pos[dwc_byte])/`CLK_PRD 
                              - $rtoi(($realtime-base_rd_predl_dqs_pos[dwc_byte])/`CLK_PRD) -0.5 ;
           rd_predl_dqs_dev[dwc_byte] = rd_predl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period           
           rd_predl_dqs_hist_bin_indx[dwc_byte] = $rtoi(rd_predl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (rd_predl_dqs_hist_bin_indx[dwc_byte] < 0)    rd_predl_dqs_histogram[dwc_byte] = rd_predl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*rd_predl_dqs_hist_bin_indx[dwc_byte])) & 60'h00000_003ff_ffc00);
           else  rd_predl_dqs_histogram[dwc_byte] = rd_predl_dqs_histogram[dwc_byte] | 
           /*don't affect DQS */ ((BASE_DQS_HIST >> rd_predl_dqs_hist_bin_indx[dwc_byte]) & 60'h00000_003ff_ffc00); 
           if (rd_predl_dqs_hist_bin_indx[dwc_byte]==0)   rd_predl_dqsn_0dev_detect[dwc_byte]  = 1'b1 ; 
        end
      end
      always@(rd_dq_pre_dl[dwc_byte]) if ((rd_dq_pre_dl[dwc_byte]!==8'bxxxxxxxx)&&(rd_dq_pre_dl_i[dwc_byte]!==8'bxxxxxxxx)) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_rd_predl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b1) ) begin
           rd_predl_dq_dev[dwc_byte] = ($realtime-base_rd_predl_dqs_pos[dwc_byte])/(`CLK_PRD/2.0) 
                              - $rtoi(($realtime-base_rd_predl_dqs_pos[dwc_byte])/(`CLK_PRD/2.0)) ;
           if (rd_predl_dq_dev[dwc_byte] > 0.5)  rd_predl_dq_dev[dwc_byte] = rd_predl_dq_dev[dwc_byte] - 1.0 ;  //already in U.I.
           
          /***** store min-max deviation for reporting  ****/
          if (rd_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0>rd_predl_max_t[dwc_byte]) rd_predl_max_t[dwc_byte]=rd_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          if (rd_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0<rd_predl_min_t[dwc_byte]) rd_predl_min_t[dwc_byte]=rd_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
           
           rd_predl_dq_hist_bin_indx[dwc_byte] = $rtoi(rd_predl_dq_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (rd_predl_dq_hist_bin_indx[dwc_byte] < 0)    rd_predl_dq_histogram[dwc_byte] = rd_predl_dq_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*rd_predl_dq_hist_bin_indx[dwc_byte])) );
           else  rd_predl_dq_histogram[dwc_byte] = rd_predl_dq_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST >> rd_predl_dq_hist_bin_indx[dwc_byte]) ); 
           if (rd_predl_dq_hist_bin_indx[dwc_byte]==0)   rd_predl_dq_0dev_detect[dwc_byte]  = 1'b1 ; 
        end                    
      end
      
      always@(posedge rd_dqs_post_dl[dwc_byte]) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_rd_postdl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b1) ) begin
           rd_postdl_dqs_dev[dwc_byte] = ($realtime-base_rd_postdl_dqs_pos[dwc_byte])/`CLK_PRD 
                              - $rtoi(($realtime-base_rd_postdl_dqs_pos[dwc_byte])/`CLK_PRD) ;
           if (rd_postdl_dqs_dev[dwc_byte] > 0.5)  rd_postdl_dqs_dev[dwc_byte] = rd_postdl_dqs_dev[dwc_byte] - 1.0 ;
           rd_postdl_dqs_dev[dwc_byte] = rd_postdl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period
           
           /***** store min-max deviation for reporting  ****/
           if (rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0>rd_postdl_dqs_max_t[dwc_byte]) rd_postdl_dqs_max_t[dwc_byte]=rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           if (rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0<rd_postdl_dqs_min_t[dwc_byte]) rd_postdl_dqs_min_t[dwc_byte]=rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           
           rd_postdl_dqs_hist_bin_indx[dwc_byte] = $rtoi(rd_postdl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (rd_postdl_dqs_hist_bin_indx[dwc_byte] < 0)    rd_postdl_dqs_histogram[dwc_byte] = rd_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*rd_postdl_dqs_hist_bin_indx[dwc_byte])) & 60'h003ff_ffc00_00000);
           else  rd_postdl_dqs_histogram[dwc_byte] = rd_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST >> rd_postdl_dqs_hist_bin_indx[dwc_byte]) & 60'h003ff_ffc00_00000);  
           if (rd_postdl_dqs_hist_bin_indx[dwc_byte]==0)   rd_postdl_dqs_0dev_detect[dwc_byte]  = 1'b1 ; 
        end
      end
      always@(posedge rd_dqsn_post_dl[dwc_byte]) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_rd_postdl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b1) ) begin
           rd_postdl_dqs_dev[dwc_byte] = ($realtime-base_rd_postdl_dqs_pos[dwc_byte])/`CLK_PRD 
                              - $rtoi(($realtime-base_rd_postdl_dqs_pos[dwc_byte])/`CLK_PRD) -0.5 ;  
           rd_postdl_dqs_dev[dwc_byte] = rd_postdl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period
           
           /***** store min-max deviation for reporting  ****/
           if (rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0>rd_postdl_dqs_max_t[dwc_byte]) rd_postdl_dqs_max_t[dwc_byte]=rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           if (rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0<rd_postdl_dqs_min_t[dwc_byte]) rd_postdl_dqs_min_t[dwc_byte]=rd_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           
           rd_postdl_dqs_hist_bin_indx[dwc_byte] = $rtoi(rd_postdl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ; 
           if (rd_postdl_dqs_hist_bin_indx[dwc_byte] < 0)    rd_postdl_dqs_histogram[dwc_byte] = rd_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*rd_postdl_dqs_hist_bin_indx[dwc_byte])) & 60'h00000_003ff_ffc00);
           else  rd_postdl_dqs_histogram[dwc_byte] = rd_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST >> rd_postdl_dqs_hist_bin_indx[dwc_byte]) & 60'h00000_003ff_ffc00); 
           if (rd_postdl_dqs_hist_bin_indx[dwc_byte]==0)   rd_postdl_dqsn_0dev_detect[dwc_byte]  = 1'b1 ;
        end
      end
      always@(rd_dq_post_dl[dwc_byte]) if ((rd_dq_post_dl[dwc_byte]!==8'bxxxxxxxx)&&(rd_dq_post_dl_i[dwc_byte]!==8'bxxxxxxxx)) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_rd_postdl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b1) ) begin
           //After the delay lines, DQ and DQS are supposed to be 1/2 DDR clock (1/4 SDR) apart
           rd_postdl_dq_dev[dwc_byte] = ($realtime-base_rd_postdl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0) 
                              - $rtoi(($realtime-base_rd_postdl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0)) ;
           if (rd_postdl_dq_dev[dwc_byte] > 0.5)  rd_postdl_dq_dev[dwc_byte] = rd_postdl_dq_dev[dwc_byte] - 1.0 ;
          
          /***** store min-max deviation for reporting  ****/
          if (rd_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0>rd_postdl_max_t[dwc_byte]) rd_postdl_max_t[dwc_byte]=rd_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          if (rd_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0<rd_postdl_min_t[dwc_byte]) rd_postdl_min_t[dwc_byte]=rd_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          
           rd_postdl_dq_hist_bin_indx[dwc_byte] = $rtoi(rd_postdl_dq_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (rd_postdl_dq_hist_bin_indx[dwc_byte] < 0)    rd_postdl_dq_histogram[dwc_byte] = rd_postdl_dq_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST << (-1*rd_postdl_dq_hist_bin_indx[dwc_byte])) );
           else  rd_postdl_dq_histogram[dwc_byte] = rd_postdl_dq_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST >> rd_postdl_dq_hist_bin_indx[dwc_byte]) );
           if (rd_postdl_dq_hist_bin_indx[dwc_byte]==0)   rd_postdl_dq_0dev_detect[dwc_byte]  = 1'b1 ;                 
        end    
      end  
      
      //WRITE
      always@(posedge wr_dqs_pre_dl[dwc_byte]) begin #0.01;
        //it is normally impossible for a valid base DQS position to be "time 0" 
        if ( (eye_monitoring_active === 1'b1) && (base_wr_predl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b0) ) begin 
           //find the offset (positive or negative) to the "nominal" DQS strobe position measured by
           //whole clock periods counted from base_wr_predl_dqs_pos
           wr_predl_dqs_dev[dwc_byte] = ($realtime-base_wr_predl_dqs_pos[dwc_byte])/`CLK_PRD 
                              //$rtoi function truncates rather than rounding, so we are left with the fractional part of the SDR-converted timestamp
                              - $rtoi(($realtime-base_wr_predl_dqs_pos[dwc_byte])/`CLK_PRD) ;
           //if fractional part of SDR-converted timestamp is > 0.5 SDR, signal is being captured e.g. after 79.8 SDR from base point instead of 80
           // -> a negative deviation.   
           if (wr_predl_dqs_dev[dwc_byte] > 0.5)  wr_predl_dqs_dev[dwc_byte] = wr_predl_dqs_dev[dwc_byte] - 1.0 ;
           wr_predl_dqs_dev[dwc_byte] = wr_predl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period
           //histogram bins span 3 DDR CLK periods, with 20 points per each period:
           //   1 period before DQS strobe
           //   1 period from DQS to DQS# (nominal)
           //   1 period after DQS# strobe
           wr_predl_dqs_hist_bin_indx[dwc_byte] = $rtoi(wr_predl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;  //compensate $rtoi trunc.
           if (wr_predl_dqs_hist_bin_indx[dwc_byte] < 0)    wr_predl_dqs_histogram[dwc_byte] = wr_predl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*wr_predl_dqs_hist_bin_indx[dwc_byte])) & 60'h003ff_ffc00_00000);
           else  wr_predl_dqs_histogram[dwc_byte] = wr_predl_dqs_histogram[dwc_byte] | 
           /*don't affect DQS#*/ ((BASE_DQS_HIST >> wr_predl_dqs_hist_bin_indx[dwc_byte]) & 60'h003ff_ffc00_00000); 
           if (wr_predl_dqs_hist_bin_indx[dwc_byte]==0)   wr_predl_dqs_0dev_detect[dwc_byte]  = 1'b1 ;
        end
      end
      always@(posedge wr_dqsn_pre_dl[dwc_byte]) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_wr_predl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b0) ) begin
           //the "nominal" DQS# strobe position is offset from DQS nominal by 0.5*`CLK_PRD        
           //for DQS# just need to subtract 0.5 off the result   
           wr_predl_dqs_dev[dwc_byte] = ($realtime-base_wr_predl_dqs_pos[dwc_byte])/`CLK_PRD 
                              - $rtoi(($realtime-base_wr_predl_dqs_pos[dwc_byte])/`CLK_PRD) -0.5 ;
           wr_predl_dqs_dev[dwc_byte] = wr_predl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period
           wr_predl_dqs_hist_bin_indx[dwc_byte] = $rtoi(wr_predl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_predl_dqs_hist_bin_indx[dwc_byte] < 0)    wr_predl_dqs_histogram[dwc_byte] = wr_predl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*wr_predl_dqs_hist_bin_indx[dwc_byte])) & 60'h00000_003ff_ffc00);
           else  wr_predl_dqs_histogram[dwc_byte] = wr_predl_dqs_histogram[dwc_byte] | 
           /*don't affect DQS */ ((BASE_DQS_HIST >> wr_predl_dqs_hist_bin_indx[dwc_byte]) & 60'h00000_003ff_ffc00);
           if (wr_predl_dqs_hist_bin_indx[dwc_byte]==0)   wr_predl_dqsn_0dev_detect[dwc_byte]  = 1'b1 ; 
        end
      end
      always@(wr_dq_pre_dl[dwc_byte]) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_wr_predl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b0) ) begin 
           //Before the delay lines, WDQ and WDQS are still "supposed" to be 1/2 DDR clock (1/4 SDR) apart -> this will mirror the board skew
           wr_predl_dq_dev[dwc_byte] = ($realtime-base_wr_predl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0) 
                              - $rtoi(($realtime-base_wr_predl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0)) ;
           if (wr_predl_dq_dev[dwc_byte] > 0.5)  wr_predl_dq_dev[dwc_byte] = wr_predl_dq_dev[dwc_byte] - 1.0 ;
           
          /***** store min-max deviation for reporting  ****/
          if (wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0>wr_predl_max_t[dwc_byte]) wr_predl_max_t[dwc_byte]=wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          if (wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0<wr_predl_min_t[dwc_byte]) wr_predl_min_t[dwc_byte]=wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          
           wr_predl_dq_hist_bin_indx[dwc_byte] = $rtoi(wr_predl_dq_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_predl_dq_hist_bin_indx[dwc_byte] < 0)    wr_predl_dq_histogram[dwc_byte] = wr_predl_dq_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST << (-1*wr_predl_dq_hist_bin_indx[dwc_byte])) );
           else  wr_predl_dq_histogram[dwc_byte] = wr_predl_dq_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST >> wr_predl_dq_hist_bin_indx[dwc_byte]) );
           if (wr_predl_dq_hist_bin_indx[dwc_byte]==0)   wr_predl_dq_0dev_detect[dwc_byte]  = 1'b1 ;
        end                    
      end
      always@(wr_dm_pre_dl[dwc_byte]) begin #0.01; 
        if ( (eye_monitoring_active === 1'b1) && (base_wr_predl_dqs_pos[dwc_byte] != 0) 
           && (read_vs_write_guard[dwc_byte]===1'b0) && (use_masked_data==1'b1) ) begin 
           //Before the delay lines, WDQ and WDQS are still "supposed" to be 1/2 DDR clock (1/4 SDR) apart -> this will mirror the board skew
           wr_predl_dq_dev[dwc_byte] = ($realtime-base_wr_predl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0) 
                              - $rtoi(($realtime-base_wr_predl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0)) ;
           if (wr_predl_dq_dev[dwc_byte] > 0.5)  wr_predl_dq_dev[dwc_byte] = wr_predl_dq_dev[dwc_byte] - 1.0 ;
           
          /***** store min-max deviation for reporting  ****/
          if (wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0>wr_predl_max_t[dwc_byte]) wr_predl_max_t[dwc_byte]=wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          if (wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0<wr_predl_min_t[dwc_byte]) wr_predl_min_t[dwc_byte]=wr_predl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          
           wr_predl_dq_hist_bin_indx[dwc_byte] = $rtoi(wr_predl_dq_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_predl_dq_hist_bin_indx[dwc_byte] < 0)    wr_predl_dm_histogram[dwc_byte] = wr_predl_dm_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST << (-1*wr_predl_dq_hist_bin_indx[dwc_byte])) );
           else  wr_predl_dm_histogram[dwc_byte] = wr_predl_dm_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST >> wr_predl_dq_hist_bin_indx[dwc_byte]) );
           if (wr_predl_dq_hist_bin_indx[dwc_byte]==0)   wr_predl_dm_0dev_detect[dwc_byte]  = 1'b1 ;
        end                    
      end
      
      always@(posedge wr_dqs_post_dl[dwc_byte])  begin #0.01;
        if ( (eye_monitoring_active === 1'b1) && (base_wr_postdl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b0) ) begin
           wr_postdl_dqs_dev[dwc_byte] = ($realtime-base_wr_postdl_dqs_pos[dwc_byte])/`CLK_PRD 
                              - $rtoi(($realtime-base_wr_postdl_dqs_pos[dwc_byte])/`CLK_PRD) ;
           if (wr_postdl_dqs_dev[dwc_byte] > 0.5)  wr_postdl_dqs_dev[dwc_byte] = wr_postdl_dqs_dev[dwc_byte] - 1.0 ;
           wr_postdl_dqs_dev[dwc_byte] = wr_postdl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period
           
           /***** store min-max deviation for reporting  ****/
           if (wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0>wr_postdl_dqs_max_t[dwc_byte]) wr_postdl_dqs_max_t[dwc_byte]=wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           if (wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0<wr_postdl_dqs_min_t[dwc_byte]) wr_postdl_dqs_min_t[dwc_byte]=wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           
           wr_postdl_dqs_hist_bin_indx[dwc_byte] = $rtoi(wr_postdl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_postdl_dqs_hist_bin_indx[dwc_byte] < 0)    wr_postdl_dqs_histogram[dwc_byte] = wr_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*wr_postdl_dqs_hist_bin_indx[dwc_byte])) & 60'h003ff_ffc00_00000);
           else  wr_postdl_dqs_histogram[dwc_byte] = wr_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST >> wr_postdl_dqs_hist_bin_indx[dwc_byte]) & 60'h003ff_ffc00_00000); 
           if (wr_postdl_dqs_hist_bin_indx[dwc_byte]==0)   wr_postdl_dqs_0dev_detect[dwc_byte]  = 1'b1 ;
        end
      end
      always@(posedge wr_dqsn_post_dl[dwc_byte])  begin #0.01;
        if ( (eye_monitoring_active === 1'b1) && (base_wr_postdl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b0) ) begin
           wr_postdl_dqs_dev[dwc_byte] = ($realtime-base_wr_postdl_dqs_pos[dwc_byte])/`CLK_PRD 
                              - $rtoi(($realtime-base_wr_postdl_dqs_pos[dwc_byte])/`CLK_PRD) -0.5 ;
           wr_postdl_dqs_dev[dwc_byte] = wr_postdl_dqs_dev[dwc_byte]*2.0 ; //scale to DDR period
           
           /***** store min-max deviation for reporting  ****/
           if (wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0>wr_postdl_dqs_max_t[dwc_byte]) wr_postdl_dqs_max_t[dwc_byte]=wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           if (wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0<wr_postdl_dqs_min_t[dwc_byte]) wr_postdl_dqs_min_t[dwc_byte]=wr_postdl_dqs_dev[dwc_byte]*`CLK_PRD*500.0;
           
           wr_postdl_dqs_hist_bin_indx[dwc_byte] = $rtoi(wr_postdl_dqs_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_postdl_dqs_hist_bin_indx[dwc_byte] < 0)    wr_postdl_dqs_histogram[dwc_byte] = wr_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST << (-1*wr_postdl_dqs_hist_bin_indx[dwc_byte])) & 60'h00000_003ff_ffc00);
           else  wr_postdl_dqs_histogram[dwc_byte] = wr_postdl_dqs_histogram[dwc_byte] | 
                            ((BASE_DQS_HIST >> wr_postdl_dqs_hist_bin_indx[dwc_byte]) & 60'h00000_003ff_ffc00);  
           if (wr_postdl_dqs_hist_bin_indx[dwc_byte]==0)   wr_postdl_dqsn_0dev_detect[dwc_byte]  = 1'b1 ;
        end
      end
      always@(wr_dq_post_dl[dwc_byte]) begin #0.01;
        if ( (eye_monitoring_active === 1'b1) && (base_wr_postdl_dqs_pos[dwc_byte] != 0) && (read_vs_write_guard[dwc_byte]===1'b0) ) begin   
           //After the delay lines, DQ and DQS are supposed to be 1/2 DDR clock (1/4 SDR) apart
           wr_postdl_dq_dev[dwc_byte] = ($realtime-base_wr_postdl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0) 
                              - $rtoi(($realtime-base_wr_postdl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0));
           if (wr_postdl_dq_dev[dwc_byte] > 0.5)  wr_postdl_dq_dev[dwc_byte] = wr_postdl_dq_dev[dwc_byte] - 1.0 ;
           
          /***** store min-max deviation for reporting  ****/
          if (wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0>wr_postdl_max_t[dwc_byte]) wr_postdl_max_t[dwc_byte]=wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          if (wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0<wr_postdl_min_t[dwc_byte]) wr_postdl_min_t[dwc_byte]=wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          
           wr_postdl_dq_hist_bin_indx[dwc_byte] = $rtoi(wr_postdl_dq_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_postdl_dq_hist_bin_indx[dwc_byte] < 0)    wr_postdl_dq_histogram[dwc_byte] = wr_postdl_dq_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST << (-1*wr_postdl_dq_hist_bin_indx[dwc_byte])) );
           else  wr_postdl_dq_histogram[dwc_byte] = wr_postdl_dq_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST >> wr_postdl_dq_hist_bin_indx[dwc_byte]) ); 
           if (wr_postdl_dq_hist_bin_indx[dwc_byte]==0)   wr_postdl_dq_0dev_detect[dwc_byte]  = 1'b1 ;
        end        
      end
      always@(wr_dm_post_dl[dwc_byte]) begin #0.01;
        if ( (eye_monitoring_active === 1'b1) && (base_wr_postdl_dqs_pos[dwc_byte] != 0) 
           && (read_vs_write_guard[dwc_byte]===1'b0) && (use_masked_data==1'b1) ) begin
           //After the delay lines, DQ and DQS are supposed to be 1/2 DDR clock (1/4 SDR) apart
           wr_postdl_dq_dev[dwc_byte] = ($realtime-base_wr_postdl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0) 
                              - $rtoi(($realtime-base_wr_postdl_dqs_pos[dwc_byte]-0.25*`CLK_PRD)/(`CLK_PRD/2.0));
           if (wr_postdl_dq_dev[dwc_byte] > 0.5)  wr_postdl_dq_dev[dwc_byte] = wr_postdl_dq_dev[dwc_byte] - 1.0 ;
           
          /***** store min-max deviation for reporting  ****/
          if (wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0>wr_postdl_max_t[dwc_byte]) wr_postdl_max_t[dwc_byte]=wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          if (wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0<wr_postdl_min_t[dwc_byte]) wr_postdl_min_t[dwc_byte]=wr_postdl_dq_dev[dwc_byte]*`CLK_PRD*500.0;
          
           wr_postdl_dq_hist_bin_indx[dwc_byte] = $rtoi(wr_postdl_dq_dev[dwc_byte]/(`CLK_PRD/40.0) + 0.5) ;
           if (wr_postdl_dq_hist_bin_indx[dwc_byte] < 0)    wr_postdl_dm_histogram[dwc_byte] = wr_postdl_dm_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST << (-1*wr_postdl_dq_hist_bin_indx[dwc_byte])) );
           else  wr_postdl_dm_histogram[dwc_byte] = wr_postdl_dm_histogram[dwc_byte] | 
                            ((BASE_DQ_HIST >> wr_postdl_dq_hist_bin_indx[dwc_byte]) ); 
           if (wr_postdl_dq_hist_bin_indx[dwc_byte]==0)   wr_postdl_dm_0dev_detect[dwc_byte]  = 1'b1 ;
        end        
      end
           
      always@(clear_eye_monitors) fork
          while(base_rd_predl_dqs_pos[dwc_byte]==0 && eye_monitoring_active==1'b1) @(posedge rd_dqs_pre_dl[dwc_byte] or negedge eye_monitoring_active)
            if ( (rd_dqs_pre_dl[dwc_byte]===1'b1)&&(read_vs_write_guard[dwc_byte]===1'b1) )
               base_rd_predl_dqs_pos[dwc_byte] = $realtime  ;
          while(base_rd_postdl_dqs_pos[dwc_byte]==0 && eye_monitoring_active==1'b1) @(posedge rd_dqs_post_dl[dwc_byte] or negedge eye_monitoring_active)
            if ( (rd_dqs_post_dl[dwc_byte]===1'b1)&&(read_vs_write_guard[dwc_byte]===1'b1) )
               base_rd_postdl_dqs_pos[dwc_byte] = $realtime  ;
          while(base_wr_predl_dqs_pos[dwc_byte]==0 && eye_monitoring_active==1'b1) @(posedge wr_dqs_pre_dl[dwc_byte]  or negedge eye_monitoring_active)
            if ( (wr_dqs_pre_dl[dwc_byte]===1'b1)&&(read_vs_write_guard[dwc_byte]===1'b0) )
               base_wr_predl_dqs_pos[dwc_byte] = $realtime  ;
          while(base_wr_postdl_dqs_pos[dwc_byte]==0 && eye_monitoring_active==1'b1) @(posedge wr_dqs_post_dl[dwc_byte] or negedge eye_monitoring_active)
            if ( (wr_dqs_post_dl[dwc_byte]===1'b1)&&(read_vs_write_guard[dwc_byte]===1'b0) )
               base_wr_postdl_dqs_pos[dwc_byte] = $realtime  ;
      join /*
      always@(ddr_tb.ddr_chip.u_DWC_DDRPHY_top.u_DWC_DDRPHY.dq_oe[ dwc_byte*8 +: 8 ])
      if (ddr_tb.ddr_chip.u_DWC_DDRPHY_top.u_DWC_DDRPHY.dq_oe[ dwc_byte*8 +: 8 ]!=8'hFF) begin
         base_wr_predl_dqs_pos[dwc_byte] = 0 ;
         base_wr_postdl_dqs_pos[dwc_byte] = 0 ;
      end
      else if (ddr_tb.ddr_chip.u_DWC_DDRPHY_top.u_DWC_DDRPHY.dq_oe[ dwc_byte*8 +: 8 ]!=8'h00) begin
         base_rd_predl_dqs_pos[dwc_byte] = 0 ;
         base_rd_postdl_dqs_pos[dwc_byte] = 0 ;
      end      */
    end 
      
    for (dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) begin: checkdev
      always@(check_rd_dq_postdl_dev) begin
        if ( rd_postdl_max_t[dwc_byte] - rd_postdl_min_t[dwc_byte] > (DQDQS_EYE_CHECKER_TOLERANCE+2)*expected_dl_step_value*1e3 + max_dq_rd_jitter[dwc_byte])  //RD Deskewing  
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if (warning_vector[3]!=1'b1) `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: RD Deskewing : deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, rd_postdl_min_t[dwc_byte], rd_postdl_max_t[dwc_byte]);
            error_vector[3] = 1'b1 ;
          end
          else $display("-> %0t: INFO: RD Deskewing : higher deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, rd_postdl_min_t[dwc_byte], rd_postdl_max_t[dwc_byte]);   
        end
        else if ( rd_postdl_max_t[dwc_byte] - rd_postdl_min_t[dwc_byte] > DQDQS_EYE_CHECKER_TOLERANCE*expected_dl_step_value*1e3 + max_dq_rd_jitter[dwc_byte])  //RD Deskewing  
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if (warning_vector[3]!=1'b1) `SYS.warning;
            $display("-> %0t: [SYSTEM] WARNING: RD Deskewing : deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, rd_postdl_min_t[dwc_byte], rd_postdl_max_t[dwc_byte]);
            warning_vector[3] = 1'b1 ;
          end
          else $display("-> %0t: INFO: RD Deskewing : higher deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, rd_postdl_min_t[dwc_byte], rd_postdl_max_t[dwc_byte]);    
        end
        else $display("-> %0t: RD Deskewing : deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, rd_postdl_min_t[dwc_byte], rd_postdl_max_t[dwc_byte]); 
        $display("\t [for reference] A total jitter of %6.3g ps was applied on RD DQ",max_dq_rd_jitter[dwc_byte]);
      end  
      always@(check_wr_dq_postdl_dev)  begin
        if ( wr_postdl_max_t[dwc_byte] - wr_postdl_min_t[dwc_byte] > (DQDQS_EYE_CHECKER_TOLERANCE+2)*expected_dl_step_value*1e3 + max_dq_wr_jitter[dwc_byte])  //WR Deskewing  
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if (warning_vector[4]!=1'b1) `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: WR Deskewing : deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, wr_postdl_min_t[dwc_byte], wr_postdl_max_t[dwc_byte]);
            error_vector[4] = 1'b1 ;
          end
          else $display("-> %0t: INFO: WR Deskewing : higher deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, wr_postdl_min_t[dwc_byte], wr_postdl_max_t[dwc_byte]);  
        end
        else if ( wr_postdl_max_t[dwc_byte] - wr_postdl_min_t[dwc_byte] > DQDQS_EYE_CHECKER_TOLERANCE*expected_dl_step_value*1e3 + max_dq_wr_jitter[dwc_byte])  //WR Deskewing  
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if (warning_vector[4]!=1'b1) `SYS.warning;
            $display("-> %0t: [SYSTEM] WARNING: WR Deskewing : deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, wr_postdl_min_t[dwc_byte], wr_postdl_max_t[dwc_byte]);
            warning_vector[4] = 1'b1 ;
          end
          else $display("-> %0t: INFO: WR Deskewing : higher deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, wr_postdl_min_t[dwc_byte], wr_postdl_max_t[dwc_byte]);  
        end
        else $display("-> %0t: WR Deskewing : deviation in DQ alignment -> %6.3g ps to %6.3g ps",$time, wr_postdl_min_t[dwc_byte], wr_postdl_max_t[dwc_byte]);  
        $display("\t [for reference] A total jitter of %6.3g ps was applied on WR DQ",max_dq_wr_jitter[dwc_byte]);
      end  
      always@(check_rd_dq_dqs_postdl) begin
        if ( ( rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0 >
                        (DQDQS_EYE_CHECKER_TOLERANCE+2)*expected_dl_step_value*1e3 + max_dqs_rd_jitter[dwc_byte]) ||
           ( rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0 <
                       -1.0*(DQDQS_EYE_CHECKER_TOLERANCE+2)*expected_dl_step_value*1e3 - max_dqs_rd_jitter[dwc_byte]) )  //RD Centering
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin 
            if ((warning_vector[5]!=1'b1)&&(warning_vector[3]!=1'b1)) `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: RD Centering : deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0,
                                                           rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0);
            error_vector[5] = 1'b1 ;
          end
          else   
            $display("-> %0t: [SYSTEM] INFO: RD Centering : higher deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0,
                                                           rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0);
        end
        else if ( ( rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0 >
                        DQDQS_EYE_CHECKER_TOLERANCE*expected_dl_step_value*1e3 + max_dqs_rd_jitter[dwc_byte]) ||
           ( rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0 <
                       -1.0*DQDQS_EYE_CHECKER_TOLERANCE*expected_dl_step_value*1e3 - max_dqs_rd_jitter[dwc_byte]) )  //RD Centering
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if ((warning_vector[5]!=1'b1)&&(warning_vector[3]!=1'b1)) `SYS.warning;
            $display("-> %0t: [SYSTEM] WARNING: RD Centering : deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0,
                                                           rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0);
            warning_vector[5] = 1'b1 ;
          end
          else    
            $display("-> %0t: [SYSTEM] INFO: RD Centering : higher deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0,
                                                           rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0);
        end
        else $display("-> %0t: RD Centering : deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           rd_postdl_dqs_min_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0,
                                                           rd_postdl_dqs_max_t[dwc_byte]-(rd_postdl_min_t[dwc_byte]+rd_postdl_max_t[dwc_byte])/2.0); 
        $display("\t [for reference] A total jitter of %6.3g ps was applied on RD DQS",max_dqs_rd_jitter[dwc_byte]);
      end  
      always@(check_wr_dq_dqs_postdl)  begin
        if ( ( wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0 >
                        (DQDQS_EYE_CHECKER_TOLERANCE+2)*expected_dl_step_value*1e3 + max_dqs_wr_jitter[dwc_byte]) ||
           ( wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0 <
                       -1.0*(DQDQS_EYE_CHECKER_TOLERANCE+2)*expected_dl_step_value*1e3 - max_dqs_wr_jitter[dwc_byte]) )  //WR Centering
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if ((warning_vector[6]!=1'b1)&&(warning_vector[4]!=1'b1)) `SYS.error;
            $display("-> %0t: [SYSTEM] ERROR: WR Centering : deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0,
                                                           wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0);
            error_vector[6] = 1'b1 ;
          end
          else  
            $display("-> %0t: [SYSTEM] INFO: WR Centering : higher deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0,
                                                           wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0);
        end
        else if ( ( wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0 >
                        DQDQS_EYE_CHECKER_TOLERANCE*expected_dl_step_value*1e3 + max_dqs_wr_jitter[dwc_byte]) ||
           ( wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0 <
                       -1.0*DQDQS_EYE_CHECKER_TOLERANCE*expected_dl_step_value*1e3 - max_dqs_wr_jitter[dwc_byte]) )  //WR Centering
        begin
          if (/*(`CLK_PRD < 2.5)||dl_seeding_active*/dl_seeding_active) begin
            if ((warning_vector[6]!=1'b1)&&(warning_vector[4]!=1'b1)) `SYS.warning;
            $display("-> %0t: [SYSTEM] WARNING: WR Centering : deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0,
                                                           wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0);
            warning_vector[6] = 1'b1 ;
          end
          else  
            $display("-> %0t: [SYSTEM] INFO: WR Centering : higher deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,          
                                                           wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0,
                                                           wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0);
        end
        else $display("-> %0t: WR Centering : deviation in DQ-DQS alignment -> %6.3g ps to %6.3g ps",$time,
                                                           wr_postdl_dqs_min_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0,
                                                           wr_postdl_dqs_max_t[dwc_byte]-(wr_postdl_min_t[dwc_byte]+wr_postdl_max_t[dwc_byte])/2.0); 
        $display("\t [for reference] A total jitter of %6.3g ps was applied on WR DQS",max_dqs_wr_jitter[dwc_byte]);
      end  
    end
    
    for (dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) begin: dloverride       
      always@(override_dl) begin
        force `EYE_PROBE(dwc_byte).datx8_dq_0.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_1.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_2.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_3.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_4.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_5.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_6.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_7.q_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).`DX_DQS0.qs_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).`DX_DQS0.qs_lcdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        //force `EYE_PROBE(dwc_byte).`DX_DQS0.qsen_lcdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_0.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_1.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_2.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_3.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_4.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_5.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_6.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).datx8_dq_7.d_bdl.stepsize  = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).`DX_CLKGEN0.ddr_wdq_lcdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ;
        force `EYE_PROBE(dwc_byte).`DX_DQS0.ds_bdl.stepsize = 0.02 ;//`CLK_PRD/125.0 ; 
      end
    end  
  endgenerate

`ifdef DWC_DDRPHY_BOARD_DELAYS
  generate
//    genvar  dwc_byte ;
    for (dwc_byte=0; dwc_byte<`DWC_NO_OF_BYTES; dwc_byte=dwc_byte+1) begin: jittermonitor   
      //always@(`DATX8_BRD_DLY(dwc_byte).dq_di_rj_cap or `DATX8_BRD_DLY(dwc_byte).dq_di_sj_amp or `DATX8_BRD_DLY(dwc_byte).dq_di_dcd_dly) begin
      always@(*) begin
        max_dq_rd_jitter[dwc_byte] = 0 ;
        for (indx=0;indx < `DATX8_BRD_DLY(dwc_byte).NO_OF_DQ_DLYS;indx=indx+1) if (`DATX8_BRD_DLY(dwc_byte).dq_di_rj_cap[indx] +
                                                                                  `DATX8_BRD_DLY(dwc_byte).dq_di_sj_amp[indx] + 
                                                                                  `DATX8_BRD_DLY(dwc_byte).dq_di_dcd_dly[indx] > max_dq_rd_jitter[dwc_byte] )
        max_dq_rd_jitter[dwc_byte] = `DATX8_BRD_DLY(dwc_byte).dq_di_rj_cap[indx] + 
                                    `DATX8_BRD_DLY(dwc_byte).dq_di_sj_amp[indx] + 
                                    `DATX8_BRD_DLY(dwc_byte).dq_di_dcd_dly[indx]  ;
      end      
      //always@(`DATX8_BRD_DLY(dwc_byte).dqs_di_rj_cap or `DATX8_BRD_DLY(dwc_byte).dqs_di_sj_amp or `DATX8_BRD_DLY(dwc_byte).dqs_di_dcd_dly or
      //  `DATX8_BRD_DLY(dwc_byte).dqsn_di_rj_cap or `DATX8_BRD_DLY(dwc_byte).dqsn_di_sj_amp or `DATX8_BRD_DLY(dwc_byte).dqsn_di_dcd_dly)  begin
      always@(*) begin  
        max_dqs_rd_jitter[dwc_byte] = `DATX8_BRD_DLY(dwc_byte).dqs_di_rj_cap[0] + `DATX8_BRD_DLY(dwc_byte).dqs_di_sj_amp[0] + `DATX8_BRD_DLY(dwc_byte).dqs_di_dcd_dly[0]  ;
        if (`DATX8_BRD_DLY(dwc_byte).dqsn_di_rj_cap[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_di_sj_amp[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_di_dcd_dly[0] > max_dqs_rd_jitter[dwc_byte])
          max_dqs_rd_jitter[dwc_byte] = `DATX8_BRD_DLY(dwc_byte).dqsn_di_rj_cap[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_di_sj_amp[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_di_dcd_dly[0]  ;
      end      

      //always@(`DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap or `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp or `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly) begin
      always@(*) begin
         max_dq_wr_jitter[dwc_byte] = 0 ;
         for (indx=0;indx < `DATX8_BRD_DLY(dwc_byte).NO_OF_DQ_DLYS;indx=indx+1) if (`DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap[indx] +
                                                                                   `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp[indx] + 
                                                                                   `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly[indx] > max_dq_wr_jitter[dwc_byte] )
         max_dq_wr_jitter[dwc_byte] = `DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap[indx] + 
                                     `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp[indx] + 
                                     `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly[indx]  ;
      end      
      //always@(`DATX8_BRD_DLY(dwc_byte).dqs_do_rj_cap or `DATX8_BRD_DLY(dwc_byte).dqs_do_sj_amp or `DATX8_BRD_DLY(dwc_byte).dqs_do_dcd_dly or
      //  `DATX8_BRD_DLY(dwc_byte).dqsn_do_rj_cap or `DATX8_BRD_DLY(dwc_byte).dqsn_do_sj_amp or `DATX8_BRD_DLY(dwc_byte).dqsn_do_dcd_dly)  begin
      always@(*) begin
        max_dqs_wr_jitter[dwc_byte] = `DATX8_BRD_DLY(dwc_byte).dqs_do_rj_cap[0] + `DATX8_BRD_DLY(dwc_byte).dqs_do_sj_amp[0] + `DATX8_BRD_DLY(dwc_byte).dqs_do_dcd_dly[0]  ;
        if (`DATX8_BRD_DLY(dwc_byte).dqsn_do_rj_cap[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_do_sj_amp[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_do_dcd_dly[0] > max_dqs_wr_jitter[dwc_byte])
          max_dqs_wr_jitter[dwc_byte] = `DATX8_BRD_DLY(dwc_byte).dqsn_do_rj_cap[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_do_sj_amp[0] + `DATX8_BRD_DLY(dwc_byte).dqsn_do_dcd_dly[0]  ;
      end
    end
  endgenerate      
`endif
        
  wire   [59:0]  testwire_read_dqs  ;
  wire   [59:0]  testwire_read_dq_hist   ; 
  wire   [59:0]  testwire_read_dq_hist_postdl   ;
  assign    testwire_read_dqs  = rd_predl_dqs_histogram[0]  ;
  assign    testwire_read_dq_hist  = rd_predl_dq_histogram[0]  ;  
  assign    testwire_read_dq_hist_postdl  = rd_postdl_dq_histogram[0]  ;
  
  wire   [59:0]  testwire_write_dqs  ;
  wire   [59:0]  testwire_write_dq   ;                             
  wire   [59:0]  testwire_write_dq_predl   ;
  assign    testwire_write_dqs  = wr_postdl_dqs_histogram[0]  ;
  assign    testwire_write_dq  = wr_postdl_dm_histogram[0]  ;
  assign    testwire_write_dq_predl  = wr_predl_dm_histogram[0]  ;
  
  wire  [7:0] testwire_read_dq_pre_dl        ;
  assign      testwire_read_dq_pre_dl = rd_dq_pre_dl[0]       ;  
  wire  [7:0] testwire_read_dq_post_dl        ;
  assign      testwire_read_dq_post_dl = rd_dq_post_dl[0]       ;
  wire  [7:0] testwire_write_dq_pre_dl        ;
  assign      testwire_write_dq_pre_dl = wr_dq_pre_dl[0]       ;  
  wire  [7:0] testwire_write_dq_post_dl        ;
  assign      testwire_write_dq_post_dl = wr_dq_post_dl[0]       ;
  real        testwire_realprobe1, testwire_realprobe2, testwire_realprobe3, testwire_realprobe4 ; 
  always@(wr_predl_dm_0dev_detect[0])    testwire_realprobe1 = wr_predl_dm_0dev_detect[0] ;
  always@(wr_predl_dqs_dev[0])    testwire_realprobe2 = wr_predl_dqs_dev[0] ;
  always@(wr_predl_dq_dev[0])    testwire_realprobe3 = wr_predl_dq_dev[0] ;
  always@(wr_predl_max_t[0])    testwire_realprobe4 = wr_predl_max_t[0] ;
  
  task print_eye_diagrams ;
  
  input  integer byte_no ;
  
  reg    dqs_rise_edge_passed ;
  reg    [(60+20)*8 -1 : 0]  table_line ;
  integer  line_char ;
  integer  byte_loop ;
  
  begin
     dqs_rise_edge_passed = 1'b0 ;
     case(byte_no)
     0,1,2,3,4,5,6,7,8 :    begin
              $display("");
              $sformat(table_line,"-");
              for(line_char=0;line_char<34;line_char=line_char+1) $sformat(table_line,"%0s-",table_line);
              $sformat(table_line,"%0sBYTE NR. %d",table_line,byte_no);                                  
              for(line_char=0;line_char<35;line_char=line_char+1) $sformat(table_line,"%0s-",table_line);
              $display("\t%0s",table_line);
              //PRE DL RD DQS
              $sformat(table_line,"READ DQS/# pre-DL   ");
              if (base_rd_predl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_predl_dqs_0dev_detect[byte_no]!=1'b1)   rd_predl_dqs_histogram[byte_no]  = rd_predl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (rd_predl_dqsn_0dev_detect[byte_no]!=1'b1)  rd_predl_dqs_histogram[byte_no]  = rd_predl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h111111,30'h000000});         
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(rd_predl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_predl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end   
              end
              $display("\t%0s",table_line);
              //PRE DL RD DQ
              $sformat(table_line,"READ DQ pre-DL      ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_predl_dq_0dev_detect[byte_no]!=1'b1)   rd_predl_dq_histogram[byte_no]  = rd_predl_dq_histogram[byte_no] & ~BASE_DQS_HIST ;
              if (base_rd_predl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_predl_dq_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              //POST DL RD DQS
              $sformat(table_line,"READ DQS/# post-DL  ");
              if (base_rd_postdl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_postdl_dqs_0dev_detect[byte_no]!=1'b1)   rd_postdl_dqs_histogram[byte_no]  = rd_postdl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (rd_postdl_dqsn_0dev_detect[byte_no]!=1'b1)  rd_postdl_dqs_histogram[byte_no]  = rd_postdl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h111111,30'h000000});
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(rd_postdl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_postdl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              end   
              $display("\t%0s",table_line);
              //POST DL RD DQ
              $sformat(table_line,"READ DQ post-DL     ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_postdl_dq_0dev_detect[byte_no]!=1'b1)   rd_postdl_dq_histogram[byte_no]  = rd_postdl_dq_histogram[byte_no] & ~BASE_DQ_HIST ;
              if (base_rd_postdl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_postdl_dq_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              
              //PRE DL WR DQS
              $sformat(table_line,"WRITE DQS/# post-DL ");
              if (base_wr_predl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_predl_dqs_0dev_detect[byte_no]!=1'b1)   wr_predl_dqs_histogram[byte_no]  = wr_predl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (wr_predl_dqsn_0dev_detect[byte_no]!=1'b1)  wr_predl_dqs_histogram[byte_no]  = wr_predl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h111111,30'h000000});
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(wr_predl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_predl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              end   
              $display("\t%0s",table_line);
              //PRE DL WR DQ
              $sformat(table_line,"WRITE DQ post-DL    ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_predl_dq_0dev_detect[byte_no]!=1'b1)   wr_predl_dq_histogram[byte_no]  = wr_predl_dq_histogram[byte_no] & ~BASE_DQ_HIST ;
              if (base_wr_predl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_predl_dq_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              $sformat(table_line,"WRITE DM post-DL    ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_predl_dm_0dev_detect[byte_no]!=1'b1)   wr_predl_dm_histogram[byte_no]  = wr_predl_dm_histogram[byte_no] & ~BASE_DQ_HIST ;
              if (base_wr_predl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_predl_dm_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sM",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              //POST DL WR DQS
              $sformat(table_line,"WRITE DQS/# @SDRAM  ");
              if (base_wr_postdl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_postdl_dqs_0dev_detect[byte_no]!=1'b1)   wr_postdl_dqs_histogram[byte_no]  = wr_postdl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (wr_postdl_dqsn_0dev_detect[byte_no]!=1'b1)  wr_postdl_dqs_histogram[byte_no]  = wr_postdl_dqs_histogram[byte_no] & (~BASE_DQS_HIST | {30'h111111,30'h000000});
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(wr_postdl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_postdl_dqs_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end 
              end  
              $display("\t%0s",table_line);
              //POST DL WR DQ
              $sformat(table_line,"WRITE DQ @SDRAM     ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_postdl_dq_0dev_detect[byte_no]!=1'b1)   wr_postdl_dq_histogram[byte_no]  = wr_postdl_dq_histogram[byte_no] & ~BASE_DQ_HIST ;
              if (base_wr_postdl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_postdl_dq_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              $sformat(table_line,"WRITE DQ @SDRAM     ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_postdl_dm_0dev_detect[byte_no]!=1'b1)   wr_postdl_dm_histogram[byte_no]  = wr_postdl_dm_histogram[byte_no] & ~BASE_DQ_HIST ;
              if (base_wr_postdl_dqs_pos[byte_no]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_postdl_dm_histogram[byte_no] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sM",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              $display("|-- DQ skew RD - postDL --|-- DQ skew WR - @SDRAM --|");
              $display("|  %6.3g min |  %6.3g max |  %6.3g min |  %6.3g max |",rd_postdl_min_t[byte_no],rd_postdl_max_t[byte_no],
                                                           wr_postdl_min_t[byte_no],wr_postdl_max_t[byte_no]);
              $display("|- DQDQS dev RD - postDL -|- DQDQS dev WR - @SDRAM -|");
              $display("|  %6.3g min |  %6.3g max |  %6.3g min |  %6.3g max |",
                                                           rd_postdl_dqs_min_t[byte_no]-(rd_postdl_min_t[byte_no]+rd_postdl_max_t[byte_no])/2.0,
                                                           rd_postdl_dqs_max_t[byte_no]-(rd_postdl_min_t[byte_no]+rd_postdl_max_t[byte_no])/2.0,
                                                           wr_postdl_dqs_min_t[byte_no]-(wr_postdl_min_t[byte_no]+wr_postdl_max_t[byte_no])/2.0,
                                                           wr_postdl_dqs_max_t[byte_no]-(wr_postdl_min_t[byte_no]+wr_postdl_max_t[byte_no])/2.0);
              $display("|-------------------------|-------------------------|");
        end
  default  :  begin
              for(byte_loop=0;byte_loop<`DWC_NO_OF_BYTES;byte_loop=byte_loop+1) begin 
              $display("");
              $sformat(table_line,"-");
              for(line_char=0;line_char<34;line_char=line_char+1) $sformat(table_line,"%0s-",table_line);
              $sformat(table_line,"%0sBYTE NR. %d",table_line,byte_loop);                                  
              for(line_char=0;line_char<35;line_char=line_char+1) $sformat(table_line,"%0s-",table_line);
              $display("\t%0s",table_line);
              //PRE DL RD DQS
              $sformat(table_line,"READ DQS/# pre-DL   ");
              if (base_rd_predl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_predl_dqs_0dev_detect[byte_loop]!=1'b1)   rd_predl_dqs_histogram[byte_loop]  = rd_predl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (rd_predl_dqsn_0dev_detect[byte_loop]!=1'b1)  rd_predl_dqs_histogram[byte_loop]  = rd_predl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h111111,30'h000000});         
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(rd_predl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_predl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end   
              end
              $display("\t%0s",table_line);
              //PRE DL RD DQ
              $sformat(table_line,"READ DQ pre-DL      ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_predl_dq_0dev_detect[byte_loop]!=1'b1)   rd_predl_dq_histogram[byte_loop]  = rd_predl_dq_histogram[byte_loop] & ~BASE_DQS_HIST ;
              if (base_rd_predl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_predl_dq_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              //POST DL RD DQS
              $sformat(table_line,"READ DQS/# post-DL  ");
              if (base_rd_postdl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_postdl_dqs_0dev_detect[byte_loop]!=1'b1)   rd_postdl_dqs_histogram[byte_loop]  = rd_postdl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (rd_postdl_dqsn_0dev_detect[byte_loop]!=1'b1)  rd_postdl_dqs_histogram[byte_loop]  = rd_postdl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h111111,30'h000000});
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(rd_postdl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_postdl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              end   
              $display("\t%0s",table_line);
              //POST DL RD DQ
              $sformat(table_line,"READ DQ post-DL     ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (rd_postdl_dq_0dev_detect[byte_loop]!=1'b1)   rd_postdl_dq_histogram[byte_loop]  = rd_postdl_dq_histogram[byte_loop] & ~BASE_DQ_HIST ;
              if (base_rd_postdl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(rd_postdl_dq_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              
              //PRE DL WR DQS
              $sformat(table_line,"WRITE DQS/# post-DL ");
              if (base_wr_predl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_predl_dqs_0dev_detect[byte_loop]!=1'b1)   wr_predl_dqs_histogram[byte_loop]  = wr_predl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (wr_predl_dqsn_0dev_detect[byte_loop]!=1'b1)  wr_predl_dqs_histogram[byte_loop]  = wr_predl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h111111,30'h000000});
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(wr_predl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_predl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              end   
              $display("\t%0s",table_line);
              //PRE DL WR DQ
              $sformat(table_line,"WRITE DQ post-DL    ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_predl_dq_0dev_detect[byte_loop]!=1'b1)   wr_predl_dq_histogram[byte_loop]  = wr_predl_dq_histogram[byte_loop] & ~BASE_DQ_HIST ;
              if (base_wr_predl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_predl_dq_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              $sformat(table_line,"WRITE DM post-DL    ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_predl_dm_0dev_detect[byte_loop]!=1'b1)   wr_predl_dm_histogram[byte_loop]  = wr_predl_dm_histogram[byte_loop] & ~BASE_DQ_HIST ;
              if (base_wr_predl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_predl_dm_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sM",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end
              $display("\t%0s",table_line);
              //POST DL WR DQS
              $sformat(table_line,"WRITE DQS/# @SDRAM  ");
              if (base_wr_postdl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else begin
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_postdl_dqs_0dev_detect[byte_loop]!=1'b1)   wr_postdl_dqs_histogram[byte_loop]  = wr_postdl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h000000,30'h111111}); 
              if (wr_postdl_dqsn_0dev_detect[byte_loop]!=1'b1)  wr_postdl_dqs_histogram[byte_loop]  = wr_postdl_dqs_histogram[byte_loop] & (~BASE_DQS_HIST | {30'h111111,30'h000000});
              for(line_char=0;line_char<30;line_char=line_char+1) begin
                 if ( |(wr_postdl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s^",table_line);
                    dqs_rise_edge_passed = 1'b1 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end
              for(line_char=30;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_postdl_dqs_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  begin
                    $sformat(table_line,"%0s!",table_line);
                    dqs_rise_edge_passed = 1'b0 ;
                 end
                 else if (dqs_rise_edge_passed == 1'b0 ) $sformat(table_line,"%0s_",table_line);
                 else  $sformat(table_line,"%0s'",table_line);
              end 
              end  
              $display("\t%0s",table_line);
              //POST DL WR DQ
              $sformat(table_line,"WRITE DQ @SDRAM     ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_postdl_dq_0dev_detect[byte_loop]!=1'b1)   wr_postdl_dq_histogram[byte_loop]  = wr_postdl_dq_histogram[byte_loop] & ~BASE_DQ_HIST ;
              if (base_wr_postdl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_postdl_dq_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sx",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end 
              $display("\t%0s",table_line);
              $sformat(table_line,"WRITE DM @SDRAM     ");
              //pre-process base vector if no 0-dev (centered) values have been observed (the base point must be removed)
              if (wr_postdl_dm_0dev_detect[byte_loop]!=1'b1)   wr_postdl_dm_histogram[byte_loop]  = wr_postdl_dm_histogram[byte_loop] & ~BASE_DQ_HIST ;
              if (base_wr_postdl_dqs_pos[byte_loop]==0) $sformat(table_line,"%0s No data available...",table_line);
              else for(line_char=0;line_char<60;line_char=line_char+1) begin
                 if ( |(wr_postdl_dm_histogram[byte_loop] & ({1'b1,59'd0} >> line_char)) == 1'b1 )  $sformat(table_line,"%0sM",table_line);
                 else  $sformat(table_line,"%0s-",table_line);
              end 
              $display("\t%0s",table_line);
              end
              for(byte_loop=0;byte_loop<`DWC_NO_OF_BYTES;byte_loop=byte_loop+1) begin
              $display("|--------------- BYTE NR. %d --------------|",byte_loop);
              $display("|-- DQ skew RD - postDL --|-- DQ skew WR - @SDRAM --|");
              $display("|  %6.3g min |  %6.3g max |  %6.3g min |  %6.3g max |",rd_postdl_min_t[byte_loop],rd_postdl_max_t[byte_loop],
                                                           wr_postdl_min_t[byte_loop],wr_postdl_max_t[byte_loop]);
              $display("|- DQDQS dev RD - postDL -|- DQDQS dev WR - @SDRAM -|");
              $display("|  %6.3g min |  %6.3g max |  %6.3g min |  %6.3g max |",
                                                           rd_postdl_dqs_min_t[byte_loop]-(rd_postdl_min_t[byte_loop]+rd_postdl_max_t[byte_loop])/2.0,
                                                           rd_postdl_dqs_max_t[byte_loop]-(rd_postdl_min_t[byte_loop]+rd_postdl_max_t[byte_loop])/2.0,
                                                           wr_postdl_dqs_min_t[byte_loop]-(wr_postdl_min_t[byte_loop]+wr_postdl_max_t[byte_loop])/2.0,
                                                           wr_postdl_dqs_max_t[byte_loop]-(wr_postdl_min_t[byte_loop]+wr_postdl_max_t[byte_loop])/2.0);
              $display("|-------------------------|-------------------------|");
              end
         end
  endcase
  $display("");
  end
  endtask         

//------------------------------------------------
//additional verification tasks
//------------------------------------------------
 

task  update_dl_step_value ;

input  [15:0]   rdwr ;
input  [23:0]   dqdqs ;
input  [31:0]   bdllcdl ;

//`DX_DQS0.ds_bdl (write strobe path BDL)
//`DX_DQS0.qs_lcdl (read DQS LCDL)
//`DX_DQS0.qs_bdl (read DQS BDL)
//datx8_dq_0.d_bdl (write data BDL)
//datx8_dq_0.q_bdl (read data BDL)
//`DX_CLKGEN0.ddr_wdq_lcdl (write DQ LCDL)

begin/*
  if (rdwr=="RD") begin
    if (dqdqs=="DQ") begin
      expected_dl_step_value = `DATX8_INST(0).datx8_dq_0.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_0.q_bdl.pvtscale ;
      $display("`DATX8_INST(0).datx8_dq_0.q_bdl.stepsize : %5.3g",`DATX8_INST(0).datx8_dq_0.q_bdl.stepsize);
      $display("`DATX8_INST(0).datx8_dq_0.q_bdl.pvtscale : %5.3g",`DATX8_INST(0).datx8_dq_0.q_bdl.pvtscale);
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_1.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_1.q_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_2.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_2.q_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_3.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_3.q_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_4.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_4.q_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_5.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_5.q_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_6.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_6.q_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_7.q_bdl.stepsize*`DATX8_INST(0).datx8_dq_7.q_bdl.pvtscale ;  
      expected_dl_step_value = expected_dl_step_value / 8.0 ;
    end
    else if (dqdqs=="DQS") begin
      if (bdllcdl=="BDL") expected_dl_step_value = `DATX8_INST(0).`DX_DQS0.qs_bdl.stepsize*`DATX8_INST(0).`DX_DQS0.qs_bdl.pvtscale ;
      else if (bdllcdl=="LCDL") expected_dl_step_value = `DATX8_INST(0).`DX_DQS0.qs_lcdl.stepsize*`DATX8_INST(0).`DX_DQS0.qs_lcdl.pvtscale ;
    end
  end
  else if (rdwr=="WR") begin
    if (dqdqs=="DQ") begin
      if (bdllcdl=="BDL") begin
      expected_dl_step_value = `DATX8_INST(0).datx8_dq_0.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_0.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_1.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_1.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_2.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_2.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_3.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_3.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_4.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_4.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_5.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_5.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_6.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_6.d_bdl.pvtscale ;
      expected_dl_step_value = expected_dl_step_value + `DATX8_INST(0).datx8_dq_7.d_bdl.stepsize*`DATX8_INST(0).datx8_dq_7.d_bdl.pvtscale ;  
      expected_dl_step_value = expected_dl_step_value / 8.0 ;
      end
      else if (bdllcdl=="LCDL")
      expected_dl_step_value = `DATX8_INST(0).`DX_CLKGEN0.ddr_wdq_lcdl.stepsize*`DATX8_INST(0).`DX_CLKGEN0.ddr_wdq_lcdl.pvtscale ;
    end
    else if (dqdqs=="DQS") expected_dl_step_value = `DATX8_INST(0).`DX_DQS0.ds_bdl.stepsize*`DATX8_INST(0).`DX_DQS0.ds_bdl.pvtscale ;
  end*/
end

endtask

task    compare_dl_vs_tb ;

//this task is always performed on Byte Lane 0, and only there

input  rd_pkpk_skew ;   
input  rd_dqs_delay ;
input  wr_pkpk_skew ;   
input  wr_dqs_delay ;
real   rd_pkpk_skew ;
real   rd_dqs_delay ;
real   wr_pkpk_skew ;
real   wr_dqs_delay ;

real   avg_dq_bdl_value ;

//real   lhs_check_rd_dq_skew, lhs_check_rd_dq_dqs, lhs_check_wr_dq_skew, lhs_check_wr_dq_dqs ;
//real   rhs_check_rd_dq_skew, rhs_check_rd_dq_dqs, rhs_check_wr_dq_skew, rhs_check_wr_dq_dqs ;
//DL_DELAY_TOLERANCE

begin
  capture_base_dl_values(0,"GET");
  //Compare RD DQ min/max values with total pkpk_skew
  update_dl_step_value("RD","DQ","BDL");
  lhs_check_rd_dq_skew = (max_rd_dq_bdl_value - min_rd_dq_bdl_value)*expected_dl_step_value ;
  rhs_check_rd_dq_skew = rd_pkpk_skew ;
  if ( (lhs_check_rd_dq_skew + expected_dl_step_value >= rhs_check_rd_dq_skew) && (lhs_check_rd_dq_skew - expected_dl_step_value <= rhs_check_rd_dq_skew) )
    $display("OK ---> RD pk-pk skew matches DL values...");
  else if ( (lhs_check_rd_dq_skew + 2.0*expected_dl_step_value >= rhs_check_rd_dq_skew) && (lhs_check_rd_dq_skew - 2.0*expected_dl_step_value <= rhs_check_rd_dq_skew) ) begin
    $display("Warning: measured RD DQ BDL value span of %5.2f does not match stimuli of %5.2f ns pk-pk DQ skew!",lhs_check_rd_dq_skew,rhs_check_rd_dq_skew);
    warning_vector[7] = 1'b1 ;
  end else begin  
    $display("ERROR: measured RD DQ BDL value span of %5.2f does not match stimuli of %5.2f ns pk-pk DQ skew!",lhs_check_rd_dq_skew,rhs_check_rd_dq_skew);
    error_vector[7] = 1'b1 ;
  end  
  //if ( (lhs_check / rhs_check < (1.0 - DL_DELAY_TOLERANCE)) || (lhs_check / rhs_check > (1.0 + DL_DELAY_TOLERANCE)) )
  //  $display("WARNING: measured RD DQ BDL value span of %5.2f does not match stimuli of %5.2f ps pk-pk DQ skew!",lhs_check,rhs_check);
  //else $display("OK ---> RD pk-pk skew matches DL values...");
  //for next calcs
  avg_dq_bdl_value = (max_rd_dq_bdl_value - min_rd_dq_bdl_value)*expected_dl_step_value/2.0 + min_rd_dq_bdl_value*expected_dl_step_value ; //typecast!
  #0.1;
  
  //Compare RD DQS LCDL + RD DQS BDL - *average* of RD DQ BDL values against 1/2 DDR clk period - dqs_delay
  update_dl_step_value("RD","DQS","LCDL");
  lhs_check_rd_dq_dqs = rd_dqs_lcdl_value*expected_dl_step_value ;
  update_dl_step_value("RD","DQS","BDL");
  lhs_check_rd_dq_dqs = lhs_check_rd_dq_dqs + rd_dqs_bdl_value*expected_dl_step_value ;
  lhs_check_rd_dq_dqs = lhs_check_rd_dq_dqs - avg_dq_bdl_value ;  
  rhs_check_rd_dq_dqs = `CLK_PRD/4.0 - rd_dqs_delay ;  // CLK_PRD = 2*DDR clk period
  if ( (lhs_check_rd_dq_dqs + expected_dl_step_value >= rhs_check_rd_dq_dqs) && (lhs_check_rd_dq_dqs - expected_dl_step_value <= rhs_check_rd_dq_dqs) )
    $display("OK ---> RD DQS delay matches DL values...");
  else if ( (lhs_check_rd_dq_dqs + 2.0*expected_dl_step_value >= rhs_check_rd_dq_dqs) && (lhs_check_rd_dq_dqs - 2.0*expected_dl_step_value <= rhs_check_rd_dq_dqs) )begin
    $display("Warning: measured RD DQ / DQS DL values do not match stimuli of %5.2f ns DQS delay!",rd_dqs_delay);
    $display("RD DQS LCDL + RD DQS BDL - RD DQ BDL avg = %5.2f vs. 1/2 DDR CK - DQS delay = %5.2f",lhs_check_rd_dq_dqs,rhs_check_rd_dq_dqs);
    warning_vector[7] = 1'b1 ;
  end else begin  
    $display("ERROR: measured RD DQ / DQS DL values do not match stimuli of %5.2f ns DQS delay!",rd_dqs_delay);
    $display("RD DQS LCDL + RD DQS BDL - RD DQ BDL avg = %5.2f vs. 1/2 DDR CK - DQS delay = %5.2f",lhs_check_rd_dq_dqs,rhs_check_rd_dq_dqs);
    error_vector[7] = 1'b1 ;
  end 
  #0.1;
  
  //Compare WR DQ min/max values with total pkpk_skew
  update_dl_step_value("WR","DQ","BDL");
  lhs_check_wr_dq_skew = (max_wr_dq_bdl_value - min_wr_dq_bdl_value)*expected_dl_step_value ;
  rhs_check_wr_dq_skew = wr_pkpk_skew ;
  if ( (lhs_check_wr_dq_skew + expected_dl_step_value >= rhs_check_wr_dq_skew) && (lhs_check_wr_dq_skew - expected_dl_step_value <= rhs_check_wr_dq_skew) )
    $display("OK ---> WR pk-pk skew matches DL values...");
  else if ( (lhs_check_wr_dq_skew + 2.0*expected_dl_step_value >= rhs_check_wr_dq_skew) && (lhs_check_wr_dq_skew - 2.0*expected_dl_step_value <= rhs_check_wr_dq_skew) ) begin
    $display("Warning: measured WR DQ BDL value span of %5.2f does not match stimuli of %5.2f ns pk-pk DQ skew!",lhs_check_wr_dq_skew,rhs_check_wr_dq_skew);
    warning_vector[7] = 1'b1 ;
  end else begin
    $display("ERROR: measured WR DQ BDL value span of %5.2f does not match stimuli of %5.2f ns pk-pk DQ skew!",lhs_check_wr_dq_skew,rhs_check_wr_dq_skew);
    error_vector[7] = 1'b1 ;
  end
  //for next calcs
  avg_dq_bdl_value = (max_wr_dq_bdl_value - min_wr_dq_bdl_value)*expected_dl_step_value/2.0 + min_wr_dq_bdl_value*expected_dl_step_value; //typecast!
  #0.1;
  
  //Compare WR DQ LCDL + *average* of WR DQ BDL values against - WR DQS BDL against 1/2 DDR clk period + dqs_delay
  update_dl_step_value("WR","DQ","LCDL");
  lhs_check_wr_dq_dqs = wr_dq_lcdl_value*expected_dl_step_value + avg_dq_bdl_value ;
  update_dl_step_value("WR","DQS","BDL");
  lhs_check_wr_dq_dqs = lhs_check_wr_dq_dqs - wr_dqs_bdl_value*expected_dl_step_value ;
  rhs_check_wr_dq_dqs = `CLK_PRD/4.0 + wr_dqs_delay ;  // CLK_PRD = 2*DDR clk period
  if ( (lhs_check_wr_dq_dqs + expected_dl_step_value >= rhs_check_wr_dq_dqs) && (lhs_check_wr_dq_dqs - expected_dl_step_value <= rhs_check_wr_dq_dqs) )
    $display("OK ---> WR DQS delay matches DL values...");
  else if ( (lhs_check_wr_dq_dqs + expected_dl_step_value >= rhs_check_wr_dq_dqs + `CLK_PRD/2.0) && (lhs_check_wr_dq_dqs - expected_dl_step_value <= rhs_check_wr_dq_dqs + `CLK_PRD/2.0) )
    $display("OK ---> WR DQS delay matches DL values (with 1 DDR CK excess)...");
  else if ( (lhs_check_wr_dq_dqs + 2.0*expected_dl_step_value >= rhs_check_wr_dq_dqs) && (lhs_check_wr_dq_dqs - 2.0*expected_dl_step_value <= rhs_check_wr_dq_dqs) ) begin
    $display("Warning: measured WR DQ / DQS DL values do not match stimuli of %5.2f ns DQS delay!",wr_dqs_delay);
    $display("WR DQ LCDL + WR DQ BDL avg - WR DQS BDL = %5.2f vs. 1/2 DDR CK + DQS delay = %5.2f",lhs_check_wr_dq_dqs,rhs_check_wr_dq_dqs);
    warning_vector[7] = 1'b1 ;
  end else begin
    $display("ERROR: measured WR DQ / DQS DL values do not match stimuli of %5.2f ns DQS delay!",wr_dqs_delay);
    $display("WR DQ LCDL + WR DQ BDL avg - WR DQS BDL = %5.2f vs. 1/2 DDR CK + DQS delay = %5.2f",lhs_check_wr_dq_dqs,rhs_check_wr_dq_dqs);
    error_vector[7] = 1'b1 ;
  end  
end

endtask

task clear_error_flags  ;

begin
   error_vector    = 8'h00     ;
   warning_vector  = 8'h00     ;
   jitter_error_counter = 0    ;
  // bit 0 -> WL step 1 error/warning
  // bit 1 -> QS gate training error/warning
  // bit 2 -> WL step 2 error/warning
  // bit 3 -> RD bit deskewing error/warning
  // bit 4 -> WR bit deskewing error/warning
  // bit 5 -> RD eye centering error/warning
  // bit 6 -> WR eye centering error/warning
  // bit 7 -> delay line value comparison error/warning
end

endtask

event qsgate_timeout ;

//check_qs_gate
generate
  for(dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin : check_qs_gate

  initial begin
    while (1) begin  :  check_qs_gate_byte
      if (enable_qsgate_checks != 1'b1) wait (enable_qsgate_checks == 1'b1);
      else begin
        t_gate_posedge[dwc_byte]    = 0.0 ;
        t_1st_dqs_strobe[dwc_byte]  = 0.0 ;
        t_last_dqs_strobe[dwc_byte] = 0.0 ;
        t_gate_negedge[dwc_byte]    = 0.0 ;
        last_dqs_strobe_checker[dwc_byte] = 1'b0 ;
        if (read_vs_write_guard[dwc_byte]!==1'b1) while(read_vs_write_guard[dwc_byte]!==1'b1) begin
          wait(read_vs_write_guard[dwc_byte]) ;
          #(5.0*`CLK_PRD) ;   //enough time to allow delay on DQS to reach PHY back (preventing false last strobe calcs)
        end
        begin  : GATEP 
          //$display("gatep");
          if (read_vs_write_guard[dwc_byte]!==1'b1) while(read_vs_write_guard[dwc_byte]!==1'b1)  wait(read_vs_write_guard[dwc_byte]) ;
          @(posedge qs_gate_probe[dwc_byte]) t_gate_posedge[dwc_byte] = $realtime ;
          /*
          if ((t_gate_posedge[dwc_byte] != 0.0)&&(t_1st_dqs_strobe[dwc_byte] != 0.0)&&(t_last_dqs_strobe[dwc_byte] != 0.0)&&(t_gate_negedge[dwc_byte] != 0.0))
            disable TIMEOUT ;
          */  
        end
        fork 
        begin  : TIMEOUT 
          repeat (200) @(posedge `CFG.clk);  //poll every 200 cycles for a read sequence to measure
          //$display("timeout");
          //disable  GATEP ;
          disable  FSTROBE ;
          disable  GATEN ;
          disable  LSTROBE ;
          -> qsgate_timeout ;
        end
        begin  : FSTROBE  
          //$display("fstrobe");
          if (read_vs_write_guard[dwc_byte]!==1'b1) while(read_vs_write_guard[dwc_byte]!==1'b1)  wait(read_vs_write_guard[dwc_byte]) ;
          @(posedge qs_bdl_out_probe[dwc_byte]) t_1st_dqs_strobe[dwc_byte] = $realtime ;
          if ((t_gate_posedge[dwc_byte] != 0.0)&&(t_1st_dqs_strobe[dwc_byte] != 0.0)&&(t_last_dqs_strobe[dwc_byte] != 0.0)&&(t_gate_negedge[dwc_byte] != 0.0))
            disable TIMEOUT ;
        end   
        begin  : GATEN 
          //$display("gaten");
          if (read_vs_write_guard[dwc_byte]!==1'b1) while(read_vs_write_guard[dwc_byte]!==1'b1)  wait(read_vs_write_guard[dwc_byte]) ;
          @(negedge qs_gate_probe[dwc_byte]) t_gate_negedge[dwc_byte] = $realtime ;
          if ((t_gate_posedge[dwc_byte] != 0.0)&&(t_1st_dqs_strobe[dwc_byte] != 0.0)&&(t_last_dqs_strobe[dwc_byte] != 0.0)&&(t_gate_negedge[dwc_byte] != 0.0))
            disable TIMEOUT ;
        end
        begin  : LSTROBE 
          //$display("lstrobe"); 
          if (read_vs_write_guard[dwc_byte]!==1'b1) while(read_vs_write_guard[dwc_byte]!==1'b1)  wait(read_vs_write_guard[dwc_byte]) ;
          last_dqs_strobe_checker = 1'b0 ;
          @(posedge qs_bdl_out_probe[dwc_byte]); //at least 1 DQS pulse
          @(negedge qs_bdl_out_probe[dwc_byte]) t_last_dqs_strobe[dwc_byte] = $realtime ;
          while(last_dqs_strobe_checker[dwc_byte]!=1'b1) fork
          begin : LASTSTROBE 
            @(/*negedge */qs_bdl_out_probe[dwc_byte]);
            if (qs_bdl_out_probe[dwc_byte]===1'b0) t_last_dqs_strobe[dwc_byte] = $realtime ;
            disable  LASTSTROBE_TO ;
          end
          begin : LASTSTROBE_TO
            #3 ;  //3ns is greater than any DDR system QS pulse width (max -> 5ns CLK_PRD --> 2.5ns QS pulse)
            last_dqs_strobe_checker[dwc_byte] = 1'b1 ;
            disable   LASTSTROBE ;
          end
          join     
          if ((t_gate_posedge[dwc_byte] != 0.0)&&(t_1st_dqs_strobe[dwc_byte] != 0.0)&&(t_last_dqs_strobe[dwc_byte] != 0.0)&&(t_gate_negedge[dwc_byte] != 0.0))
            disable TIMEOUT ;
        end 
        join
  
   //now check if values make sense
   //$display("---- Checking QS gate behavior for byte lane %d ----",byteid);
   /*if ( ( t_gate_posedge[dwc_byte] == 0.0) || ( t_1st_dqs_strobe[dwc_byte] == 0.0) || ( t_last_dqs_strobe[dwc_byte] == 0.0) || ( t_gate_negedge[dwc_byte] == 0.0) )
       $display("ERROR! [%t]  Attempted to check QS gating framing of DQS strobe in byte %d but did not capture a mem. read",$time,dwc_byte);
   else */
        if ( ( t_gate_posedge[dwc_byte]   < t_1st_dqs_strobe[dwc_byte]  ) &&
             ( t_1st_dqs_strobe[dwc_byte] < t_last_dqs_strobe[dwc_byte] ) &&
             ( t_last_dqs_strobe[dwc_byte]< t_gate_negedge[dwc_byte]    ) )  begin
          $display("Byte %d: Successfully captured QS gating comparison values",dwc_byte);  
          $display("\t-> Lead margin %5.3g ns --> OK",t_1st_dqs_strobe[dwc_byte] - t_gate_posedge[dwc_byte]);
          $display("\t Trail margin %5.3g ns --> OK",t_gate_negedge[dwc_byte] - t_last_dqs_strobe[dwc_byte]);
        end     
        else begin
          $display("WARNING: Byte %d: Sequence QSgaterise->DQSposedge->DQSnegedge->QSgatefall not captured in that order",dwc_byte);
        `ifndef SOFT_Q_ERRORS
          `SYS.error ;
        `endif   
          error_vector[1] = 1'b1 ;
        end   //else
      end     //if enable_qsgate_checks
    end       //while(1)  
  end         //initial begin
end  //loop dwc_byte
   /*
   repeat (1000) @(posedge `CFG.clk);  //wait for everything to flush out
   //if all is OK, check framing
   if ( ( t_gate_posedge   < t_1st_dqs_strobe  ) &&
        ( t_1st_dqs_strobe < t_last_dqs_strobe ) &&
        ( t_last_dqs_strobe< t_gate_negedge    ) ) begin
     `CFG.read_register_data(`DSGCR,tempstore);
     
     $display("---- Checking QS gate behavior for byte lane %d ----",byteid);
     if (QS_GATE_CHECKER_TYPE==1'b0) begin   //default     
     if (tempstore[6]==1'b1) begin // extended gate
        $display("Using extended QS gate. ");
        if ((t_1st_dqs_strobe - t_gate_posedge)>=`CLK_PRD - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - 
             read_dqs_dcd_value/2.0e3)  // 1 full period for extended gate
          $display("\t-> Lead margin %5.3g ns --> OK",t_1st_dqs_strobe - t_gate_posedge);
        else begin
          $display("\t-> WARNING:  Lead margin %5.3g ns --> Short!",t_1st_dqs_strobe - t_gate_posedge);
          $display("\t \t Limit : %5.3g ns",`CLK_PRD - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - read_dqs_dcd_value/2.0e3);
          `ifndef SOFT_Q_ERRORS
            `SYS.warning ;
          `endif   
          warning_vector[1] = 1'b1 ;
        end  
        if ((t_gate_negedge - t_last_dqs_strobe)>=`CLK_PRD - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - 
             read_dqs_dcd_value/2.0e3)  // 1 full period for extended gate
          $display("\t Trail margin %5.3g ns --> OK",t_gate_negedge - t_last_dqs_strobe);  
        else begin
          $display("\t WARNING:  Trail margin %5.3g ns --> Short!",t_gate_negedge - t_last_dqs_strobe);
          $display("\t \t Limit : %5.3g ns",`CLK_PRD - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - read_dqs_dcd_value/2.0e3);
          `ifndef SOFT_Q_ERRORS
            `SYS.warning ;
          `endif   
          warning_vector[1] = 1'b1 ;
        end
     end
     else begin  //non-extended gate  
        $display("Using default (non-extended) QS gate. ");
        if ((t_1st_dqs_strobe - t_gate_posedge)>=`CLK_PRD*0.25 - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - 
             read_dqs_dcd_value/2.0e3)  // quarter-period for normal gate
          $display("\t Lead margin %5.3g ns --> OK",t_1st_dqs_strobe - t_gate_posedge);
        else begin
          $display("\t WARNING:  Lead margin %5.3g ns --> Short!",t_1st_dqs_strobe - t_gate_posedge);
          $display("\t \t Limit : %5.3g ns",`CLK_PRD*0.25 - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - read_dqs_dcd_value/2.0e3);
          `ifndef SOFT_Q_ERRORS
            `SYS.warning ;
          `endif   
          warning_vector[1] = 1'b1 ;
        end  
        if ((t_gate_negedge - t_last_dqs_strobe)>=`CLK_PRD*0.25 - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - 
             read_dqs_dcd_value/2.0e3)  // quarter-period for normal gate
          $display("\t Trail margin %5.3g ns --> OK",t_gate_negedge - t_last_dqs_strobe);
        else begin
          $display("\t WARNING:  Trail margin %5.3g ns --> Short!",t_gate_negedge - t_last_dqs_strobe);
          $display("\t \t Limit : %5.3g ns",`CLK_PRD*0.25 - QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value - read_dqs_dcd_value/2.0e3);
          `ifndef SOFT_Q_ERRORS
            `SYS.warning ;
          `endif   
          warning_vector[1] = 1'b1 ;
        end
     end
     end
     else begin // strict margins   
     if (tempstore[6]==1'b1) begin // extended gate
        $display("Using extended QS gate. ");
        if (((t_1st_dqs_strobe - t_gate_posedge)>=`CLK_PRD*1.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value)&&
	    ((t_1st_dqs_strobe - t_gate_posedge)<=`CLK_PRD*1.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value))
          // 1 + 1/4 period for extended gate
          $display("\t Lead margin %5.3g ns --> OK",t_1st_dqs_strobe - t_gate_posedge);
        else begin
          $display("\t WARNING:  Lead margin %5.3g ns --> NOT OK!",t_1st_dqs_strobe - t_gate_posedge);
          $display("\t \t Limit : %5.3g - %5.3g ns",`CLK_PRD*1.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value,
                                                    `CLK_PRD*1.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value);
          //`ifndef SOFT_Q_ERRORS
          //  `SYS.warning ;
          //`endif   
          //warning_vector[1] = 1'b1 ;
        end  
        if (((t_gate_negedge - t_last_dqs_strobe)>=`CLK_PRD*1.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value)&&
	    ((t_gate_negedge - t_last_dqs_strobe)<=`CLK_PRD*1.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value))
          // 1 full period for extended gate
          $display("\t Trail margin %5.3g ns --> OK",t_gate_negedge - t_last_dqs_strobe); 
        else begin
          $display("\t WARNING:  Trail margin %5.3g ns --> NOT OK!",t_gate_negedge - t_last_dqs_strobe);
          $display("\t \t Limit : %5.3g - %5.3g ns",`CLK_PRD*1.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value,
                                                    `CLK_PRD*1.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value);
          //`ifndef SOFT_Q_ERRORS
          //  `SYS.warning ;
          //`endif   
          //warning_vector[1] = 1'b1 ;
        end
     end
     else begin  //non-extended gate  
        $display("Using default (non-extended) QS gate. ");
        if (((t_1st_dqs_strobe - t_gate_posedge)>=`CLK_PRD*0.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value)&&
	    ((t_1st_dqs_strobe - t_gate_posedge)<=`CLK_PRD*0.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value))
          $display("\t Lead margin %5.3g ns --> OK",t_1st_dqs_strobe - t_gate_posedge);
        else begin
          $display("\t WARNING:  Lead margin %5.3g ns --> NOT OK!",t_1st_dqs_strobe - t_gate_posedge);
          $display("\t \t Limit : %5.3g - %5.3g ns",`CLK_PRD*0.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value,
                                                    `CLK_PRD*0.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value);
          //`ifndef SOFT_Q_ERRORS
          //  `SYS.warning ;
          //`endif   
          //warning_vector[1] = 1'b1 ;
        end  
        if (((t_gate_negedge - t_last_dqs_strobe)>=`CLK_PRD*0.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value)&&
	    ((t_gate_negedge - t_last_dqs_strobe)<=`CLK_PRD*0.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value))
          $display("\t Trail margin %5.3g ns --> OK",t_gate_negedge - t_last_dqs_strobe);  
        else begin
          $display("\t WARNING:  Trail margin %5.3g ns --> NOT OK!",t_gate_negedge - t_last_dqs_strobe);
          $display("\t \t Limit : %5.3g - %5.3g ns",`CLK_PRD*0.25-(read_dqs_dcd_value/2.0e3)-QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value,
                                                    `CLK_PRD*0.25+(read_dqs_dcd_value/2.0e3)+QS_GATE_CHECKER_TOLERANCE*expected_dl_step_value);
          //`ifndef SOFT_Q_ERRORS
          //  `SYS.warning ;
          //`endif   
          //warning_vector[1] = 1'b1 ;
        end
     end
     end
   end
   
   //report incorrect QS gate order (1st DQS strobe before QS gate assertion or QS gate deassertion before last strobe)
   if ( t_gate_posedge > t_1st_dqs_strobe ) begin
      $display("ERROR:  QS gate assert occuring after 1st QS strobe by %5.3g ns",t_gate_posedge - t_1st_dqs_strobe);
      `ifndef SOFT_Q_ERRORS
        `SYS.error ;
      `endif   
      error_vector[1] = 1'b1 ;
   end   
   if ( t_gate_negedge < t_last_dqs_strobe ) begin
      $display("ERROR:  QS gate deassert occuring before last QS strobe by %5.3g ns",t_last_dqs_strobe - t_gate_negedge);
      `ifndef SOFT_Q_ERRORS
        `SYS.error ;
      `endif   
      error_vector[1] = 1'b1 ;
 */ 

endgenerate          
  
task get_eye_plots ;
  
  input  byte_choice ;
  inout  last_bank ;
  integer   byte_choice ;
  integer   last_bank ;
  integer   byteid ; //qs gate checker aux variable
  
  reg [1:0] rank;
  reg [`SDRAM_BANK_WIDTH-1:0] bank;
  reg [`SDRAM_ROW_WIDTH-1:0]  row;
  reg [`SDRAM_COL_WIDTH-1:0]  col;
  
  begin            
        /////////////////////////////////////////////
        // Perform some random accessees to memory //
        /////////////////////////////////////////////
        // arbitrary access locations
        rank = active_rnk;  //only rank 0 is used
        bank = (last_bank + 1) % `NO_OF_BANKS ;
        row  = 45;
        col  = 16;
        
        //issue precharge_all command to ensure used bank is activated
        `HOST.precharge_all(rank);
        
        //enable eye monitors
        `EYE_MNT.eye_monitoring_active = 1'b1 ;
        -> `EYE_MNT.clear_eye_monitors ;
        
        // execute a few DDR accesses
        `HOST.execute_ddr_accesses(NO_OF_ACCESSES, rank, bank, row, col);
        `HOST.nops(50);
        
        // now execute back-to-back writes to different ranks
        repeat (NO_BL8S_EYE_SCOPE) begin
          use_masked_data = {$random(`SYS.seed_rr)} % 2;
          if (use_masked_data)
             `HOST.set_wrdata_mask_val(`HOST.wrdata_ptr,{1'b0,{(`BURST_BYTE_WIDTH-2){$random(`SYS.seed_rr)%2}},1'b0});  //prevent first and last beats from having DM
          else
             `HOST.set_wrdata_mask_val(`HOST.wrdata_ptr,{`BURST_BYTE_WIDTH{1'b0}});
          `HOST.write({rank, bank, row, col});
          `HOST.read({rank, bank, row, col});
          repeat (20) @(posedge `CFG.clk);
        end
        
      for(byteid=0;byteid<`DWC_NO_OF_BYTES;byteid=byteid+1) begin
        fork
          `HOST.write({rank, bank, row, col});
          begin
            // no shared AC in G3MPHY
            /*if (`TB.pNUM_CHANNELS == 2) begin
              if (rank % 2 == 0) begin 
                if (read_vs_write_guard[0]!==1'b0) while (read_vs_write_guard[0]!==1'b0) @(read_vs_write_guard[0]);
                @(read_vs_write_guard[0]); //transition to 1'bx at the end of write
              end
              else if (rank % 2 == 1) begin
                if (read_vs_write_guard[`DWC_NO_OF_BYTES-1]!==1'b0) while (read_vs_write_guard[`DWC_NO_OF_BYTES-1]!==1'b0) @(read_vs_write_guard[`DWC_NO_OF_BYTES-1]);
                @(read_vs_write_guard[`DWC_NO_OF_BYTES-1]); //transition to 1'bx at the end of write
              end                 
            end  
            else begin */ 
              if (read_vs_write_guard[0]!==1'b0) while (read_vs_write_guard[0]!==1'b0) @(read_vs_write_guard[0]);
              @(read_vs_write_guard[0]); //transition to 1'bx at the end of write
            //end
          end    
        join  
        fork
          `HOST.read({rank, bank, row, col});  
          /*if(`TB.pNUM_CHANNELS == 2) begin  //shared AC mode
            if ( (rank % 2 == 0)&&(byteid < `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)) ) check_qs_gate(byteid) ; 
            else if ( (rank % 2 == 1)&&(byteid >= `DWC_NO_OF_BYTES/2 - (`DWC_NO_OF_BYTES % 2)) ) check_qs_gate(byteid) ;
          end
          else   //normal mode (i.e. single channel)    */
            enable_qsgate_checks = 1'b1 ; //check_qs_gate(byteid) ;
        join
/*         
        `GRM.dxccr[12:5] = 8'b01001100 ;
        `CFG.write_register(`DXCCR, `GRM.dxccr);
        `CFG.read_register_data(`PGCR7,tempstore);
        tempstore[23] = !tempstore[23];  //reverse QS gate mode
        `GRM.pgcr7[23] = tempstore[23];
        `CFG.write_register(`PGCR7,tempstore);
        
        #10;
                
       // fork
          `HOST.read({rank, bank, row, col});  
           // check_qs_gate(byteid) ;
       // join
*/         
      end  
        `EYE_MNT.print_eye_diagrams(byte_choice);
        `ifdef SOFT_Q_ERRORS        
        `else
        -> check_rd_dq_postdl_dev ;
        -> check_rd_dq_dqs_postdl ;
        -> check_wr_dq_postdl_dev ;
        -> check_wr_dq_dqs_postdl ;         
        `endif                
        `EYE_MNT.eye_monitoring_active = 1'b0 ;  
        #1000;    
        -> `EYE_MNT.clear_eye_monitors ;
        
        last_bank = bank ;   
  end
endtask


   
   
task capture_base_dl_values ;
  
  input    byte_lane ;
  integer  byte_lane ;
  input  [23:0]  call_type ;
  
  reg  [31:0]    tmp_BDLR0     ;
  reg  [31:0]    tmp_BDLR1     ;
  reg  [31:0]    tmp_BDLR2     ;
  reg  [31:0]    tmp_BDLR3     ;
  reg  [31:0]    tmp_BDLR4     ;
  reg  [31:0]    tmp_BDLR5     ;
  reg  [31:0]    tmp_LCDLR4    ;
  reg  [31:0]    tmp_LCDLR5    ;
  
  begin
        max_wr_dq_bdl_value   = 6'd0 ;
        min_wr_dq_bdl_value   = 6'h3F ;
        max_rd_dq_bdl_value   = 'd0 ;
        min_rd_dq_bdl_value   = 6'h3F ;
        
     `CFG.disable_read_compare;
     `CFG.read_register_data(`DX0BDLR0 + 8'h40*byte_lane, tmp_BDLR0);
     `CFG.read_register_data(`DX0BDLR1 + 8'h40*byte_lane, tmp_BDLR1);
     `CFG.read_register_data(`DX0BDLR2 + 8'h40*byte_lane, tmp_BDLR2);
     `CFG.read_register_data(`DX0BDLR3 + 8'h40*byte_lane, tmp_BDLR3);
     `CFG.read_register_data(`DX0BDLR4 + 8'h40*byte_lane, tmp_BDLR4);
     `CFG.read_register_data(`DX0BDLR5 + 8'h40*byte_lane, tmp_BDLR5);
     `CFG.read_register_data(`DX0LCDLR4 + 8'h40*byte_lane, tmp_LCDLR4);
     `CFG.read_register_data(`DX0LCDLR5 + 8'h40*byte_lane, tmp_LCDLR5);
      repeat (10) @(posedge `CFG.clk);     
     `CFG.enable_read_compare;
     if(tmp_BDLR0[ 5: 0] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR0[ 5: 0] ;
     if(tmp_BDLR0[13: 8] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR0[13: 8] ;
     if(tmp_BDLR0[21:16] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR0[21:16] ;
     if(tmp_BDLR0[29:24] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR0[29:24] ;
     if(tmp_BDLR1[ 5: 0] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR1[ 5: 0] ;
     if(tmp_BDLR1[13: 8] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR1[13: 8] ;
     if(tmp_BDLR1[21:16] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR1[21:16] ;
     if(tmp_BDLR1[29:24] > max_wr_dq_bdl_value) max_wr_dq_bdl_value = tmp_BDLR1[29:24] ;
     wr_dqs_bdl_value = tmp_BDLR2[13: 8] ;
     
     if(tmp_BDLR0[ 5: 0] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR0[ 5: 0] ;
     if(tmp_BDLR0[13: 8] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR0[13: 8] ;
     if(tmp_BDLR0[21:16] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR0[21:16] ;
     if(tmp_BDLR0[29:24] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR0[29:24] ;
     if(tmp_BDLR1[ 5: 0] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR1[ 5: 0] ;
     if(tmp_BDLR1[13: 8] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR1[13: 8] ;
     if(tmp_BDLR1[21:16] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR1[21:16] ;
     if(tmp_BDLR1[29:24] < min_wr_dq_bdl_value) min_wr_dq_bdl_value = tmp_BDLR1[29:24] ;
     
     if(tmp_BDLR3[ 5: 0] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR3[ 5: 0] ;
     if(tmp_BDLR3[13: 8] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR3[13: 8] ;
     if(tmp_BDLR3[21:16] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR3[21:16] ;
     if(tmp_BDLR3[29:24] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR3[29:24] ;
     if(tmp_BDLR4[ 5: 0] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR4[ 5: 0] ;
     if(tmp_BDLR4[13: 8] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR4[13: 8] ;
     if(tmp_BDLR4[21:16] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR4[21:16] ;
     if(tmp_BDLR4[29:24] > max_rd_dq_bdl_value) max_rd_dq_bdl_value = tmp_BDLR4[29:24] ;
     rd_dqs_bdl_value = tmp_BDLR5[13: 8] ;
     
     if(tmp_BDLR3[ 5: 0] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR3[ 5: 0] ;
     if(tmp_BDLR3[13: 8] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR3[13: 8] ;
     if(tmp_BDLR3[21:16] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR3[21:16] ;
     if(tmp_BDLR3[29:24] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR3[29:24] ;
     if(tmp_BDLR4[ 5: 0] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR4[ 5: 0] ;
     if(tmp_BDLR4[13: 8] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR4[13: 8] ;
     if(tmp_BDLR4[21:16] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR4[21:16] ;
     if(tmp_BDLR4[29:24] < min_rd_dq_bdl_value) min_rd_dq_bdl_value = tmp_BDLR4[29:24] ;
     
     wr_dq_lcdl_value  = tmp_LCDLR5[ 7: 0] ;
     rd_dqs_lcdl_value = tmp_LCDLR4[ 7: 0] ;
     //if(tmp_LCDLR1[23:16] > max_rd_dqs_lcdl_value) max_rd_dqs_lcdl_value = tmp_LCDLR1[23:16] ;   do not compare DQSN for now
     //if(tmp_LCDLR1[23:16] < min_rd_dqs_lcdl_value) min_rd_dqs_lcdl_value = tmp_LCDLR1[23:16] ;   do not compare DQSN for now
                   
      if ( (call_type=="SET") || (call_type=="set") ) begin 
         $display("Capturing 'base' delay line values...");
         base_rd_dqs_lcdl_value = rd_dqs_lcdl_value ;
         base_wr_dq_lcdl_value  = wr_dq_lcdl_value  ;
         basemax_rd_dq_bdl_value   = max_rd_dq_bdl_value   ;
         basemax_wr_dq_bdl_value   = max_wr_dq_bdl_value   ; 
         base_rd_dqs_bdl_value  = rd_dqs_bdl_value  ; 
         base_wr_dqs_bdl_value  = wr_dqs_bdl_value  ;
         basemin_rd_dq_bdl_value   = min_rd_dq_bdl_value   ;
         basemin_wr_dq_bdl_value   = min_wr_dq_bdl_value   ; 
         $display("------------------------------------------");
         $display("RD DQS LCDL value for byte %d : %h ",byte_lane,base_rd_dqs_lcdl_value);
         $display("RD DQS BDL  value for byte %d : %h ",byte_lane,base_rd_dqs_bdl_value );
         $display("Max/min RD DQ  BDL  value for byte %d : %h / %h",byte_lane,basemax_rd_dq_bdl_value  ,basemin_rd_dq_bdl_value  );
         $display("WR DQS BDL  value for byte %d : %h ",byte_lane,base_wr_dqs_bdl_value );
         $display("WR DQ  LCDL value for byte %d : %h ",byte_lane,base_wr_dq_lcdl_value );
         $display("Max/min WR DQ  BDL  value for byte %d : %h / %h",byte_lane,basemax_wr_dq_bdl_value  ,basemin_wr_dq_bdl_value  );
         $display("------------------------------------------");
      end
      else if ( (call_type=="GET") || (call_type=="get") ) begin
        $display("Capturing updated delay line values...");
        $display("------------------------------------------");
         $display("RD DQS LCDL value for byte %d : %h ",byte_lane,rd_dqs_lcdl_value);
         $display("RD DQS BDL  value for byte %d : %h ",byte_lane,rd_dqs_bdl_value );
         $display("Max/min RD DQ  BDL  value for byte %d : %h / %h",byte_lane,max_rd_dq_bdl_value  ,min_rd_dq_bdl_value  );
         $display("WR DQS BDL  value for byte %d : %h ",byte_lane,wr_dqs_bdl_value );
         $display("WR DQ  LCDL value for byte %d : %h ",byte_lane,wr_dq_lcdl_value );
         $display("Max/min WR DQ  BDL  value for byte %d : %h / %h",byte_lane,max_wr_dq_bdl_value  ,min_wr_dq_bdl_value  );
        $display("------------------------------------------");
         $display("Dev in RD DQS LCDL value for byte -%d : %d",byte_lane, rd_dqs_lcdl_value - base_rd_dqs_lcdl_value );
         $display("Dev in RD DQS BDL  value for byte -%d : %d",byte_lane, rd_dqs_bdl_value - base_rd_dqs_bdl_value  );
         $display("Max/min dev in RD DQ  BDL  value for byte -%d : %d / %d",byte_lane,max_rd_dq_bdl_value - basemax_rd_dq_bdl_value,min_rd_dq_bdl_value - basemin_rd_dq_bdl_value);
         $display("Dev in WR DQS BDL  value for byte -%d : %d",byte_lane, rd_dqs_bdl_value - base_rd_dqs_bdl_value );
         $display("Dev in WR DQ  LCDL value for byte -%d : %d",byte_lane, wr_dq_lcdl_value - base_wr_dq_lcdl_value );
         $display("Max/min dev in WR DQ  BDL  value for byte -%d : %d / %d",byte_lane,max_wr_dq_bdl_value - basemax_wr_dq_bdl_value,min_wr_dq_bdl_value - basemin_wr_dq_bdl_value);
         $display("------------------------------------------");
      end      
  end
  
endtask
      
  
  
task check_training_status ;
  
  input    nowarn    ;
  // nowarn = 0 --> warnings and errors are logged into `SYS.error / `SYS.warning
  // nowarn = 1 --> warnings and errors are signalled but not logged
  reg [31:0]                  tmp;
  integer                 byte_no;
  
  reg                capacity_ok ;
  
  begin
        ///////////////////////////
        // Check Training Status //
        ///////////////////////////
        // disable read compare because the Golden Ref Model won't contain updated status results
        `CFG.disable_read_compare;
        `CFG.read_register_data(`PGSR0, tmp);
         // check WL status
         if ((`PUB.wl_done == 1'b1)&&({tmp[21], tmp[5]} != {1'b0,1'b1}))  
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: Write Levelling : Expect PGSR0 [21,5] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[21], tmp[5]});
             error_vector[0] = 1'b1 ;
           end
         // check gate training status
         if ((`PUB.qs_gate_done == 1'b1)&&({tmp[22], tmp[6]} != {1'b0,1'b1}))  
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: DQS Gate Training : Expect PGSR0 [22,6] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[22], tmp[6]});
             error_vector[1] = 1'b1 ;
           end
         // check write levelling adjustment status
         if ((`PUB.wl_adj_done == 1'b1)&&({tmp[23], tmp[7]} != {1'b0,1'b1}))  
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: Write Levelling Adjustment : Expect PGSR0 [23,7] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[23], tmp[7]});
             error_vector[2] = 1'b1 ;
           end
         // check read bit de-skew status
         if ((`PUB.rd_dskw_done == 1'b1)&&({tmp[24], tmp[8]} != {1'b0,1'b1}))  
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: Read Bit De-skew : Expect PGSR0 [24,8] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[24], tmp[8]});
             error_vector[3] = 1'b1 ;
           end
         // check write bit de-skew status
         if ((`PUB.wr_dskw_done == 1'b1)&&({tmp[25], tmp[9]} != {1'b0,1'b1}))  
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: Write Bit De-skew : Expect PGSR0 [25,9] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[25], tmp[9]});
             error_vector[4] = 1'b1 ;
           end
         // check read bit centering status
         if ((`PUB.rd_eye_done == 1'b1)&&({tmp[26], tmp[10]} != {1'b0,1'b1}))  
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: Read Bit Centering : Expect PGSR0 [26,10] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[26], tmp[10]});
             error_vector[5] = 1'b1 ;
           end
         // check write bit centering status
         if ((`PUB.wr_eye_done == 1'b1)&&({tmp[27], tmp[11]} != {1'b0,1'b1}))
           begin
             if (nowarn !== 1'b1) `SYS.error;
             $display("-> %0t: [SYSTEM] ERROR: Write Bit Centering : Expect PGSR0 [27,11] = %0h got %0h", $time, {1'b0,1'b1}, {tmp[27], tmp[11]});
             error_vector[6] = 1'b1 ;
           end
  
        // check the data eye training warning and error registers
        // if we are running at 2.5ns or larger clk period AND not seeding the DLs, the warning severity is reduced (regardless of DDR2/3)
        for (byte_no=0; byte_no<`DWC_NO_OF_BYTES; byte_no=byte_no+1) begin
            compute_dtalgos_capacity(byte_no,active_rnk,capacity_ok);
            //capacity_ok = 1'b1 ;
          //if (`CLK_PRD <= 2.5) begin
            `CFG.read_register_data(`DX0GSR2+(byte_no*8'h40), tmp);
            if (tmp[7] != 1'b0)  
              begin
                if /*((nowarn !== 1'b1)&&((`CLK_PRD < 2.5)||dl_seeding_active))*/((nowarn !== 1'b1)&&capacity_ok) `SYS.warning;
                warning_vector[6] = 1'b1 ;
                $display("-> %0t: [SYSTEM] WARNING: Write Eye Centering : Expect DX%0dGSR2 [7] = %0h got %0h", $time, byte_no, 1'b0, tmp[7]);
              end
            if (tmp[6] != 1'b0)  
              begin
                if (nowarn !== 1'b1) `SYS.error;
                $display("-> %0t: [SYSTEM] ERROR: Write Eye Centering : Expect DX%0dGSR2 [6] = %0h got %0h", $time, byte_no, 1'b0, tmp[6]);
                error_vector[6] = 1'b1 ;
              end
            if (tmp[5] != 1'b0)  
              begin
                if /*((nowarn !== 1'b1)&&((`CLK_PRD < 2.5)||dl_seeding_active))*/((nowarn !== 1'b1)&&capacity_ok) `SYS.warning;
                $display("-> %0t: [SYSTEM] WARNING: Read Eye Centering : Expect DX%0dGSR2 [5] = %0h got %0h", $time, byte_no, 1'b0, tmp[5]);
                warning_vector[5] = 1'b1 ;
              end
            if (tmp[4] != 1'b0)  
              begin
                if (nowarn !== 1'b1) `SYS.error;
                $display("-> %0t: [SYSTEM] ERROR: Read Eye Centering : Expect DX%0dGSR2 [4] = %0h got %0h", $time, byte_no, 1'b0, tmp[4]);
                error_vector[5] = 1'b1 ;
              end
            if (tmp[3] != 1'b0)  
              begin
                if /*((nowarn !== 1'b1)&&((`CLK_PRD < 2.5)||dl_seeding_active))*/((nowarn !== 1'b1)&&capacity_ok) `SYS.warning;
                $display("-> %0t: [SYSTEM] WARNING: Write Bit Deskewing : Expect DX%0dGSR2 [3] = %0h got %0h", $time, byte_no, 1'b0, tmp[3]);
                warning_vector[4] = 1'b1 ;
              end
            if (tmp[2] != 1'b0)  
              begin
                if (nowarn !== 1'b1) `SYS.error;
                $display("-> %0t: [SYSTEM] ERROR: Write Bit Deskewing : Expect DX%0dGSR2 [2] = %0h got %0h", $time, byte_no, 1'b0, tmp[2]);
                error_vector[4] = 1'b1 ;
              end
            if (tmp[1] != 1'b0)  
              begin
                if /*((nowarn !== 1'b1)&&((`CLK_PRD < 2.5)||dl_seeding_active))*/((nowarn !== 1'b1)&&capacity_ok) `SYS.warning;
                $display("-> %0t: [SYSTEM] WARNING: Read Bit Deskewing : Expect DX%0dGSR2 [1] = %0h got %0h", $time, byte_no, 1'b0, tmp[1]);
                warning_vector[3] = 1'b1 ;
              end
            if (tmp[0] != 1'b0)  
              begin
                if (nowarn !== 1'b1) `SYS.error;
                $display("-> %0t: [SYSTEM] ERROR: Read Bit Deskewing : Expect DX%0dGSR2 [0] = %0h got %0h", $time, byte_no, 1'b0, tmp[0]);
                error_vector[3] = 1'b1 ;
              end
          end
          
        // if all else is correct, check BDL/LCDL converged values
        for (byte_no=0; byte_no<`DWC_NO_OF_BYTES; byte_no=byte_no+1) if (`CLK_PRD <= 2.5) begin
           `GRM.dtcr[19:16] = byte_no;  //typecast!
           `CFG.write_register(`DTCR0, `GRM.dtcr);
           $display("------->  BYTE LANE %d <-------",byte_no);
           if (`PUB.wr_eye_done == 1'b1) begin
              `CFG.read_register_data(`DTEDR0, tmp);
              $display("--- DTEDR0 results from WR eye centering ---");
              $display("WDQ LCDL : min %d   max %d",tmp[7:0], tmp[15:8]);
              $display("WDQ BDL  : min %d   max %d",tmp[23:16], tmp[31:24]);
              $display("--------------------------------------------");
           end   
           if (`PUB.rd_eye_done == 1'b1) begin
              `CFG.read_register_data(`DTEDR1, tmp);
              $display("--- DTEDR1 results from RD eye centering ---");
              $display("RDQS LCDL: min %d   max %d",tmp[7:0], tmp[15:8]);
              $display("RDQ BDL  : min %d   max %d",tmp[23:16], tmp[31:24]);
              $display("--------------------------------------------");
           end
        end
        // re-enable read compare
        repeat (10) @(posedge `CFG.clk);
        `CFG.enable_read_compare;        //corrected by Jose 2010-12-14
  end
endtask

task  ensure_dl_step_scaled  ;
begin
   -> override_dl  ;
end
endtask

task bdlload  ;
  
  input  [23:0]  preseedBDLs  ;
  input          lcdlstoo  ; // 0 -> just BDLs, 1 -> LCDLs as well
  
  reg   [31:0]  tempstore ;
  
  real          auxcalc      ;
  real          auxcalc2     ;
  integer       byte_no      ;
  
  begin    
     `CFG.disable_read_compare;   
      /////////////////////////////
      // Load initial BDL delays //
      /////////////////////////////
      // since the BDLs are initially at a zero delay value, seeding the delays allows the algorithm to move the data backwards and forwards
      // this can improve the eye centering results
      // loading a value of x10 for all write path bdls
      //for (byte_no=0; byte_no<no_of_bytes; byte_no=byte_no+1)
      if (preseedBDLs==="MID") begin
      for (byte_no=0; byte_no<`DWC_NO_OF_BYTES; byte_no=byte_no+1)
        begin
          `GRM.dxnbdlr0[byte_no] = {2'h0, 6'h10, 6'h10, 6'h10, 6'h10, 6'h10};
          `CFG.write_register(`DX0BDLR0+(byte_no*8'h40), `GRM.dxnbdlr0[byte_no]);
          `ifdef DDR2 
          `CFG.read_register_data(`DX0BDLR1+(byte_no*8'h40),tempstore);
          `GRM.dxnbdlr1[byte_no] = {tempstore[31:24], 6'h10, 6'h10, 6'h10, 6'h10};  //do not alter QS BDL
          `else
          `GRM.dxnbdlr1[byte_no] = {2'h0, 6'h10, 6'h10, 6'h10, 6'h10, 6'h10};
          `endif
          `CFG.write_register(`DX0BDLR1+(byte_no*8'h40), `GRM.dxnbdlr1[byte_no]);
          `GRM.dxnbdlr2[byte_no] = {2'h0, 6'h00, 6'h00, 6'h10, 6'h10, 6'h10};
          `CFG.write_register(`DX0BDLR2+(byte_no*8'h40), `GRM.dxnbdlr2[byte_no]);  
          `GRM.dxnbdlr3[byte_no] = {2'h0, 6'h10, 6'h10, 6'h10, 6'h10, 6'h10};
          `CFG.write_register(`DX0BDLR3+(byte_no*8'h40), `GRM.dxnbdlr3[byte_no]);
          `GRM.dxnbdlr4[byte_no] = {2'h0, 6'h00, 6'h00, 6'h10, 6'h10, 6'h10};
          `CFG.write_register(`DX0BDLR4+(byte_no*8'h40), `GRM.dxnbdlr4[byte_no]);
          if (lcdlstoo===1'b1) begin
             //`GRM.dxnlcdlr0[byte_no] = {8'h20, 8'h20, 8'h20, 8'h20};
             //`CFG.write_register(`DX0LCDLR0+(byte_no*8'h40), `GRM.dxnlcdlr0[byte_no]);
             `GRM.dxnlcdlr1[byte_no] = {8'h00, 8'h20, 8'h20, 8'h20};
             `CFG.write_register(`DX0LCDLR1+(byte_no*8'h40), `GRM.dxnlcdlr1[byte_no]);
             `GRM.dxnlcdlr2[byte_no] = {8'h20, 8'h20, 8'h20, 8'h20};
             `CFG.write_register(`DX0LCDLR2+(byte_no*8'h40), `GRM.dxnlcdlr2[byte_no]);
          end
          `ifdef DWC_DDRPHY_X4MODE
          `GRM.dxnbdlr7[byte_no] = {2'h0, 6'h00, 6'h00, 6'h10, 6'h10, 6'h10};
          `CFG.write_register(`DX0BDLR7+(byte_no*8'h40), `GRM.dxnbdlr7[byte_no]);  
           
          `endif
        end   
      end
      else if (preseedBDLs==="MAX") begin
      for (byte_no=0; byte_no<`DWC_NO_OF_BYTES; byte_no=byte_no+1)
        begin
          `GRM.dxnbdlr0[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR0+(byte_no*8'h40), `GRM.dxnbdlr0[byte_no]);
          `ifdef DDR2 
          `CFG.read_register_data(`DX0BDLR1+(byte_no*8'h40),tempstore);
          `GRM.dxnbdlr1[byte_no] = {tempstore[31:24], 6'h20, 6'h20, 6'h20, 6'h20};  //do not alter QS BDL
          `else
          `GRM.dxnbdlr1[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `endif
          `CFG.write_register(`DX0BDLR1+(byte_no*8'h40), `GRM.dxnbdlr1[byte_no]);
          `GRM.dxnbdlr2[byte_no] = {2'h0, 6'h00, 6'h00, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR2+(byte_no*8'h40), `GRM.dxnbdlr2[byte_no]);  
          `GRM.dxnbdlr3[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR3+(byte_no*8'h40), `GRM.dxnbdlr3[byte_no]);
          `GRM.dxnbdlr4[byte_no] = {2'h0, 6'h00, 6'h00, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR4+(byte_no*8'h40), `GRM.dxnbdlr4[byte_no]);
          if (lcdlstoo===1'b1) begin
             //`GRM.dxnlcdlr0[byte_no] = {8'h40, 8'h40, 8'h40, 8'h40};
             //`CFG.write_register(`DX0LCDLR0+(byte_no*8'h40), `GRM.dxnlcdlr0[byte_no]);
             `GRM.dxnlcdlr1[byte_no] = {8'h00, 8'h40, 8'h40, 8'h40};
             `CFG.write_register(`DX0LCDLR1+(byte_no*8'h40), `GRM.dxnlcdlr1[byte_no]);
             `GRM.dxnlcdlr2[byte_no] = {8'h40, 8'h40, 8'h40, 8'h40};
             `CFG.write_register(`DX0LCDLR2+(byte_no*8'h40), `GRM.dxnlcdlr2[byte_no]);
          end
          `ifdef DWC_DDRPHY_X4MODE
          `GRM.dxnbdlr7[byte_no] = {2'h0, 6'h00, 6'h00, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR7+(byte_no*8'h40), `GRM.dxnbdlr7[byte_no]);  
          `endif
        end   
      end
      else if (preseedBDLs==="MIN") begin
      for (byte_no=0; byte_no<`DWC_NO_OF_BYTES; byte_no=byte_no+1)
        begin
          `GRM.dxnbdlr0[byte_no] = {2'h0, 6'h00, 6'h00, 6'h00, 6'h00, 6'h00};
          `CFG.write_register(`DX0BDLR0+(byte_no*8'h40), `GRM.dxnbdlr0[byte_no]);
          `ifdef DDR2 
          `CFG.read_register_data(`DX0BDLR1+(byte_no*8'h40),tempstore);
          `GRM.dxnbdlr1[byte_no] = {tempstore[31:24], 6'h00, 6'h00, 6'h00, 6'h00};  //do not alter QS BDL
          `else
          `GRM.dxnbdlr1[byte_no] = {2'h0, 6'h00, 6'h00, 6'h00, 6'h00, 6'h00};
          `endif
          `CFG.write_register(`DX0BDLR1+(byte_no*8'h40), `GRM.dxnbdlr1[byte_no]);
          `GRM.dxnbdlr2[byte_no] = {2'h0, 6'h00, 6'h00, 6'h00, 6'h00, 6'h00};
          `CFG.write_register(`DX0BDLR2+(byte_no*8'h40), `GRM.dxnbdlr2[byte_no]);  
          `GRM.dxnbdlr3[byte_no] = {2'h0, 6'h00, 6'h00, 6'h00, 6'h00, 6'h00};
          `CFG.write_register(`DX0BDLR3+(byte_no*8'h40), `GRM.dxnbdlr3[byte_no]);
          `GRM.dxnbdlr4[byte_no] = {2'h0, 6'h00, 6'h00, 6'h00, 6'h00, 6'h00};
          `CFG.write_register(`DX0BDLR4+(byte_no*8'h40), `GRM.dxnbdlr4[byte_no]);
          if (lcdlstoo===1'b1) begin
             //`GRM.dxnlcdlr0[byte_no] = {8'h00, 8'h00, 8'h00, 8'h00};
             //`CFG.write_register(`DX0LCDLR0+(byte_no*8'h40), `GRM.dxnlcdlr0[byte_no]);
             `GRM.dxnlcdlr1[byte_no] = {8'h00, 8'h00, 8'h00, 8'h00};
             `CFG.write_register(`DX0LCDLR1+(byte_no*8'h40), `GRM.dxnlcdlr1[byte_no]);
             `GRM.dxnlcdlr2[byte_no] = {8'h00, 8'h00, 8'h00, 8'h00};
             `CFG.write_register(`DX0LCDLR2+(byte_no*8'h40), `GRM.dxnlcdlr2[byte_no]);
          end
          `ifdef DWC_DDRPHY_X4MODE
          `GRM.dxnbdlr7[byte_no] = {2'h0, 6'h00, 6'h00, 6'h00, 6'h00, 6'h00};
          `CFG.write_register(`DX0BDLR7+(byte_no*8'h40), `GRM.dxnbdlr7[byte_no]);
          `endif
        end   
      end 
      else if (preseedBDLs==="CST") begin   //custom mode for DDR2 Debug
      for (byte_no=0; byte_no<`DWC_NO_OF_BYTES; byte_no=byte_no+1)
        begin
          `GRM.dxnbdlr0[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR0+(byte_no*8'h40), `GRM.dxnbdlr0[byte_no]);/*
          `ifdef DDR2 
          `CFG.read_register_data(`DX0BDLR1+(byte_no*8'h40),tempstore);
          `GRM.dxnbdlr1[byte_no] = {tempstore[31:24], 6'h00, 6'h00, 6'h00, 6'h00};  //do not alter QS BDL
          `else*/
          `GRM.dxnbdlr1[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          //`endif
          `CFG.write_register(`DX0BDLR1+(byte_no*8'h40), `GRM.dxnbdlr1[byte_no]);
          `GRM.dxnbdlr2[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR2+(byte_no*8'h40), `GRM.dxnbdlr2[byte_no]);  
          `GRM.dxnbdlr3[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR3+(byte_no*8'h40), `GRM.dxnbdlr3[byte_no]);
          `GRM.dxnbdlr4[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR4+(byte_no*8'h40), `GRM.dxnbdlr4[byte_no]);
          if (lcdlstoo===1'b1) begin
             //`GRM.dxnlcdlr0[byte_no] = {8'h00, 8'h00, 8'h00, 8'h00};
             //`CFG.write_register(`DX0LCDLR0+(byte_no*8'h40), `GRM.dxnlcdlr0[byte_no]);
             `GRM.dxnlcdlr1[byte_no] = {8'h80, 8'h80, 8'h80, 8'h80};
             `CFG.write_register(`DX0LCDLR1+(byte_no*8'h40), `GRM.dxnlcdlr1[byte_no]);
             `GRM.dxnlcdlr2[byte_no] = {8'h80, 8'h80, 8'h80, 8'h80};
             `CFG.write_register(`DX0LCDLR2+(byte_no*8'h40), `GRM.dxnlcdlr2[byte_no]);
          end
          `ifdef DWC_DDRPHY_X4MODE

          `GRM.dxnbdlr7[byte_no] = {2'h0, 6'h20, 6'h20, 6'h20, 6'h20, 6'h20};
          `CFG.write_register(`DX0BDLR7+(byte_no*8'h40), `GRM.dxnbdlr7[byte_no]);  
          `endif
        end   
      end 
      repeat (10) @(posedge `CFG.clk);
      `CFG.enable_read_compare;
  end
  
  endtask   


  task update_read_dqs_dcd_value ;
  
  input  value  ;
  real   value  ;
  begin
     read_dqs_dcd_value = value ;
  end
  endtask 
  
  
     
  real    dq_out_dly_max  [`DWC_NO_OF_RANKS-1:0] [`DWC_NO_OF_BYTES-1:0]  ;
  real    dq_out_dly_min  [`DWC_NO_OF_RANKS-1:0] [`DWC_NO_OF_BYTES-1:0]  ;  
  real    dqs_out_dly_max [`DWC_NO_OF_RANKS-1:0] [`DWC_NO_OF_BYTES-1:0]  ;  
  real    dqs_out_dly_min [`DWC_NO_OF_RANKS-1:0] [`DWC_NO_OF_BYTES-1:0]  ; 
  integer bit_indx  [`DWC_NO_OF_RANKS-1:0] [`DWC_NO_OF_BYTES-1:0] ; 
  
`ifdef DWC_DDRPHY_BOARD_DELAYS 
  generate
    genvar rank_no ;
    for(rank_no = 0; rank_no < `DWC_NO_OF_RANKS; rank_no = rank_no + 1) begin : get_minmax_dly_ranks
       for(dwc_byte = 0; dwc_byte < `DWC_NO_OF_BYTES; dwc_byte = dwc_byte + 1) begin : get_minmax_dly_ranks
       
          always@( `DATX8_BRD_DLY(dwc_byte).dq_do_board_dly or `DATX8_BRD_DLY(dwc_byte).dq_do_skew_dly or `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly
		    or `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp or `DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap) begin
            dq_out_dly_max[rank_no][dwc_byte] = 0.0 ;
            for (bit_indx[rank_no][dwc_byte]=rank_no*8;bit_indx[rank_no][dwc_byte]<rank_no*8+8;bit_indx[rank_no][dwc_byte]=bit_indx[rank_no][dwc_byte]+1) begin
               if ( `DATX8_BRD_DLY(dwc_byte).dq_do_board_dly[bit_indx[rank_no][dwc_byte]] + `DATX8_BRD_DLY(dwc_byte).dq_do_skew_dly[bit_indx[rank_no][dwc_byte]] 
                  + `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly[bit_indx[rank_no][dwc_byte]]/2.0 + `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp[bit_indx[rank_no][dwc_byte]]
                  + `DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap[bit_indx[rank_no][dwc_byte]]*1000.0/2.0  > dq_out_dly_max[rank_no][dwc_byte] )
                  dq_out_dly_max[rank_no][dwc_byte] = ( `DATX8_BRD_DLY(dwc_byte).dq_do_board_dly[bit_indx[rank_no][dwc_byte]] + `DATX8_BRD_DLY(dwc_byte).dq_do_skew_dly[bit_indx[rank_no][dwc_byte]] 
                  + `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly[bit_indx[rank_no][dwc_byte]]/2.0 + `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp[bit_indx[rank_no][dwc_byte]]
                  + `DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap[bit_indx[rank_no][dwc_byte]]*1000.0/2.0 );
            end
            dq_out_dly_min[rank_no][dwc_byte] = dq_out_dly_max[rank_no][dwc_byte] ;
            for (bit_indx[rank_no][dwc_byte]=rank_no*8;bit_indx[rank_no][dwc_byte]<rank_no*8+8;bit_indx[rank_no][dwc_byte]=bit_indx[rank_no][dwc_byte]+1) begin
               if ( `DATX8_BRD_DLY(dwc_byte).dq_do_board_dly[bit_indx[rank_no][dwc_byte]] + `DATX8_BRD_DLY(dwc_byte).dq_do_skew_dly[bit_indx[rank_no][dwc_byte]] 
                  - `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly[bit_indx[rank_no][dwc_byte]]/2.0 - `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp[bit_indx[rank_no][dwc_byte]]
                  - `DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap[bit_indx[rank_no][dwc_byte]]*1000.0/2.0  < dq_out_dly_min[rank_no][dwc_byte] )
                  dq_out_dly_min[rank_no][dwc_byte] = ( `DATX8_BRD_DLY(dwc_byte).dq_do_board_dly[bit_indx[rank_no][dwc_byte]] + `DATX8_BRD_DLY(dwc_byte).dq_do_skew_dly[bit_indx[rank_no][dwc_byte]] 
                  - `DATX8_BRD_DLY(dwc_byte).dq_do_dcd_dly[bit_indx[rank_no][dwc_byte]]/2.0 - `DATX8_BRD_DLY(dwc_byte).dq_do_sj_amp[bit_indx[rank_no][dwc_byte]]
                  - `DATX8_BRD_DLY(dwc_byte).dq_do_rj_cap[bit_indx[rank_no][dwc_byte]]*1000.0/2.0 );
            end
         end
         always@(*) begin  
           dqs_out_dly_max[rank_no][dwc_byte] = ( `DATX8_BRD_DLY(dwc_byte).dqs_do_board_dly[rank_no*8] + `DATX8_BRD_DLY(dwc_byte).dqs_do_skew_dly[rank_no*8] 
              + `DATX8_BRD_DLY(dwc_byte).dqs_do_dcd_dly[rank_no*8]/2.0 + `DATX8_BRD_DLY(dwc_byte).dqs_do_sj_amp[rank_no*8] + `DATX8_BRD_DLY(dwc_byte).dqs_do_rj_cap[rank_no*8]*1000.0/2.0 );     
           dqs_out_dly_min[rank_no][dwc_byte] = ( `DATX8_BRD_DLY(dwc_byte).dqs_do_board_dly[rank_no*8] + `DATX8_BRD_DLY(dwc_byte).dqs_do_skew_dly[rank_no*8] 
              - `DATX8_BRD_DLY(dwc_byte).dqs_do_dcd_dly[rank_no*8]/2.0 - `DATX8_BRD_DLY(dwc_byte).dqs_do_sj_amp[rank_no*8] - `DATX8_BRD_DLY(dwc_byte).dqs_do_rj_cap[rank_no*8]*1000.0/2.0 );
         end     
       end
    end
  endgenerate
`endif

  task compute_dtalgos_capacity ;
  
  input  byte_no  ;
  input  rank_no  ;
  output  ok_nokz ;
  integer byte_no  ;
  integer rank_no  ;
  reg   ok_nokz ;
  real  dl_stepsize_tmp ;
  real  dq_pkpk_span ;
  real  dq_to_dqs_delay_up ;
  real  dq_to_dqs_delay_down ;
  real  aux1, aux2 ;
  
  begin
    ok_nokz = 1'b0 ;
    dl_stepsize_tmp = `AC_MDL_LCDL_PATH.stepsize ;
`ifdef DWC_DDRPHY_BOARD_DELAYS     
    dq_pkpk_span = dq_out_dly_max[rank_no][byte_no] - dq_out_dly_min[rank_no][byte_no] ;
    //higher DQ delay to SDRAM -> DQS early -> algos stress going DOWN with WDQ to meet it
    dq_to_dqs_delay_down = dq_out_dly_max[rank_no][byte_no] + `CLK_PRD/4.0 - dqs_out_dly_min[rank_no][byte_no] ;
    //higher DQS delay to SDRAM -> DQS late -> algos stress going UP with WDQ to meet it
    dq_to_dqs_delay_up = dq_out_dly_min[rank_no][byte_no] + `CLK_PRD/4.0 - dqs_out_dly_max[rank_no][byte_no] ;
`else
    dq_pkpk_span = 0.0 ;
    //higher DQ delay to SDRAM -> DQS early -> algos stress going DOWN with WDQ to meet it
    dq_to_dqs_delay_down = `CLK_PRD/4.0  ;
    //higher DQS delay to SDRAM -> DQS late -> algos stress going UP with WDQ to meet it
    dq_to_dqs_delay_up = `CLK_PRD/4.0   ;
`endif    
    aux1 = `CLK_PRD/4.0 ;
    aux2 = 0.0 ; //{1'b0, `PUB.ctl_dtwdqm}*dl_stepsize_tmp ;
    //computation
    case(dl_seeding_active)
    1'b0   :   begin   // no seeding, lax WDQ margin
                 if  ( ( dq_to_dqs_delay_down > aux1 - aux2 ) ||
                       ( dq_to_dqs_delay_up > (255 + 63 /*- {1'b0, `PUB.ctl_dtwdqm}*/)*dl_stepsize_tmp - `CLK_PRD/4.0 ) )
                   ok_nokz = 1'b0 ;
                 else   ok_nokz = 1'b1 ;
               end   /*     
    2'b01  :   begin   // no seeding, strict WDQ margin
                 if  ( ( dq_to_dqs_delay_down > `CLK_PRD/8.0 ) ||
                       ( dq_to_dqs_delay_up > (255 + 63)*dl_stepsize_tmp - `CLK_PRD*3.0/8.0 ) )
                   ok_nokz = 1'b0 ;
                 else   ok_nokz = 1'b1 ;
               end     */   
    1'b1   :   begin   // seeding, lax WDQ margin
                 if  ( ( dq_to_dqs_delay_down > `CLK_PRD/4.0 - /*{1'b0, `PUB.ctl_dtwdqm}*dl_stepsize_tmp*/ + 32*dl_stepsize_tmp ) ||
                       ( dq_to_dqs_delay_up > (255 + 31 /*- {1'b0, `PUB.ctl_dtwdqm}*/)*dl_stepsize_tmp - `CLK_PRD/4.0 ) )
                   ok_nokz = 1'b0 ;
                 else   ok_nokz = 1'b1 ;
               end    /*    
    2'b11  :   begin   // seeding, strict WDQ margin
                 if  ( ( dq_to_dqs_delay_down > `CLK_PRD/8.0 + 32*dl_stepsize_tmp ) ||
                       ( dq_to_dqs_delay_up > (255 + 31)*dl_stepsize_tmp - `CLK_PRD*3.0/8.0 ) )
                   ok_nokz = 1'b0 ;
                 else   ok_nokz = 1'b1 ;
               end*/        
    endcase           
    
  end
  
  endtask
        
endmodule
