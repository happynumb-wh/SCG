#------------------------------------------------------------------------
#
#                    (C) COPYRIGHT 2013 SYNOPSYS, INC.
#                            ALL RIGHTS RESERVED
#
#  This software and the associated documentation are confidential and
#  proprietary to Synopsys, Inc.  Your use or disclosure of this
#  software is subject to the terms and conditions of a written
#  license agreement between you, or your company, and Synopsys, Inc.
#
# The entire notice above must be reproduced on all authorized copies.
#
#------------------------------------------------------------------------

# Script to make certain modifications to Micron models 

if {[regexp {DWC_ddr_umctl2} [get_top_design_name]]} {
    #type of memory to be modified . "ALL" means all models
    set tc_ddr_mode      "ALL" 
    set encrypted_ddr4_model    [get_activity_parameter $activity   Encrypted_DDR4_Model]
    set simulator               [get_activity_parameter $activity   SimChoice]

    # Find directory in which to do the modifications
    set source_dir            [get_logical_dir sim]/testbench/models/memory/micron/download ; # used for DDR2/3/mDDR/LPDDR2

    if {$encrypted_ddr4_model} {
        if {$simulator == "VCS"} {
            set source_dir_ddr4 [get_logical_dir sim]/testbench/models/memory/micron/download/ddr4/protected_vcs
        } else {
            set source_dir_ddr4 [get_logical_dir sim]/testbench/models/memory/micron/download/ddr4/protected_nc
        }
    } else {
        if {$simulator == "VCS"} {
            set source_dir_ddr4 [get_logical_dir sim]/testbench/models/memory/micron/download/ddr4/open_vcs
        } else {
            set source_dir_ddr4 [get_logical_dir sim]/testbench/models/memory/micron/download/ddr4/open_nc
        }
    }

    set dest_dir [get_logical_dir sim]/testbench/models/memory/micron/modified
} else {
    #type of memory to be modified (DDR2,DDR3,DDR4,LPDDR1,LPDDR2,LPDDR3)
    set tc_ddr_mode  [get_configuration_parameter Tc_ddr_mode]
    #location of the original model
    set source_dir   [get_configuration_parameter Source_dir]
    #location of the modified model
    set dest_dir     [get_configuration_parameter Dest_dir]
}

if {![file exists $dest_dir]} {
    file mkdir $dest_dir
}

#########################################################################
# ddr2.v:
if {$tc_ddr_mode == "DDR2"} {
    puts "[info script]: modifying DDR2 model"
    source $script_dir/modify_micron_ddr2_model.tcl
    # The ModifyMicronDdr2Model procedure modifies both ddr2.v and ddr2_parameters.vh
    ModifyMicronDdr2Model $src_dir $dst_dir
}


#########################################################################
# ddr3.v:
if {($tc_ddr_mode == "DDR3") || ($tc_ddr_mode == "ALL")} {

    if {[file exists $source_dir/ddr3.v]} {
        puts "[info script] modifying Micron DDR3 model"
        if {[file exists $dest_dir/ddr3.v]} { file delete $dest_dir/ddr3.v}
        set ddr3_orig [open $source_dir/ddr3.v r]
        set ddr3_modi [open $dest_dir/ddr3.v a]
        
        set initial_flag 0
        set in_include_statements 0
    
        while {[gets $ddr3_orig line] >=0} {
    
            if {[regexp {define MAX_PIPE} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi " "
                puts $ddr3_modi "    reg  check_clocks;"
                puts $ddr3_modi "    reg  check_dq_setup_hold;"    
                puts $ddr3_modi "    reg  check_dq_pulse_width;"    
                puts $ddr3_modi "    reg  check_dqs_ck_setup_hold;"    
                puts $ddr3_modi "    reg  check_rfc_max;"       
                puts $ddr3_modi "    reg  check_cmd_addr_timing;"    
                puts $ddr3_modi "    reg  check_ctrl_addr_pulse_width;"       
                puts $ddr3_modi "    reg  check_odth;"    
                puts $ddr3_modi "    reg  check_dqs_latch;"    
                puts $ddr3_modi "    reg  check_pd_max;"
                puts $ddr3_modi "    event  e_tm_dqs_neg;"
                puts $ddr3_modi " "        
            } elseif {[regexp {integer seed;} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi "    integer tdqsck_dlloff_rnd;"
            } elseif {[regexp {string char;} $line]} {
                puts $ddr3_modi "        reg \[255:0\] char1;"
                puts $ddr3_modi "        integer i;"
            } elseif {[regexp {integer i = 0} $line]} {
                puts $ddr3_modi "        for \( i = 0; i < `BANKS; i = i + 1\)"
            } elseif {[regexp {, addr, char, data} $line]} {
                puts $ddr3_modi "            fio_status = \$fscanf\(in, \"\%h \%s \%h\", addr, char1, data\);"
            } elseif {[regexp {reg            diff_ck;} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi "    real                         cmd_dly;    // command board delay"
                puts $ddr3_modi "    real                         wr_dly;     // write board delay"
                puts $ddr3_modi "    real                         rd_dly;     // read board delay"
                puts $ddr3_modi "    real                         ck_dly;     // extra write delay on CK/CK#"
                puts $ddr3_modi "    real                         qs_dly;     // extra read delay on strobes"
                puts $ddr3_modi "    real                         dqs_dly;    // extra read delay on DQS strobe"
                puts $ddr3_modi "    real                         dqs_b_dly;  // extra read delay on DQS# strobe"
                puts $ddr3_modi ""
                puts $ddr3_modi "    reg                          gen_error;"
                puts $ddr3_modi "    reg \[7:0\]                    gen_error_bitpos;"
                puts $ddr3_modi "    reg \[63:0\]                   error_mask;"
                puts $ddr3_modi "    reg \[63:0\]                   error_mask_ns;"
                puts $ddr3_modi "    reg                          wl_feedback_on_all_bits;"
                puts $ddr3_modi "    integer                      wl_feedback_on_bit;"
                puts $ddr3_modi ""
                puts $ddr3_modi "    // board delays are zeros by default (testcases can change these values"
                puts $ddr3_modi "    // through hierarchy to simulate different board delays"
                puts $ddr3_modi "    initial"
                puts $ddr3_modi "    begin"
                puts $ddr3_modi "        cmd_dly   = 0.0;"
                puts $ddr3_modi "        wr_dly    = 0.0;"
                puts $ddr3_modi "        rd_dly    = 0.0;"
                puts $ddr3_modi "        ck_dly    = 0.0;"
                puts $ddr3_modi "        qs_dly    = 0.0;"
                puts $ddr3_modi "        dqs_dly   = 0.0;"
                puts $ddr3_modi "        dqs_b_dly = 0.0;"
                puts $ddr3_modi "        check_clocks = 1'b1;"
                puts $ddr3_modi "        check_dq_setup_hold = 1'b1;"
                puts $ddr3_modi "        check_dq_pulse_width = 1'b1;"
                puts $ddr3_modi "        check_dqs_ck_setup_hold = 1'b1;"
                puts $ddr3_modi "        check_rfc_max = 1'b1;"
                puts $ddr3_modi "        check_cmd_addr_timing = 1'b1;"
                puts $ddr3_modi "        check_ctrl_addr_pulse_width = 1'b1;"
                puts $ddr3_modi " `ifdef DRAM_NO_CHECK_ODTH"
                puts $ddr3_modi "        check_odth = 1'b0;"
                puts $ddr3_modi " `else"
                puts $ddr3_modi "        check_odth = 1'b1;"
                puts $ddr3_modi " `endif"
                puts $ddr3_modi "        check_dqs_latch = 1'b1;"
                puts $ddr3_modi "        check_pd_max = 1'b1;"
                puts $ddr3_modi "        gen_error = 1'b0;"
                puts $ddr3_modi "        gen_error_bitpos = 0;"
                puts $ddr3_modi "        error_mask = {64{1'b0}};"
                puts $ddr3_modi "        error_mask_ns = {64{1'b0}};"
                puts $ddr3_modi "        wl_feedback_on_all_bits = 1'b0;"
                puts $ddr3_modi "        wl_feedback_on_bit      = 0;"
                puts $ddr3_modi "    end"
                puts $ddr3_modi ""
                puts $ddr3_modi "    reg \[DQS_BITS-1:0\]     dqs_out_en_dly_bd;"
                puts $ddr3_modi "    reg \[DQS_BITS-1:0\]     dqs_out_dly_bd;"
                puts $ddr3_modi "    reg \[DQ_BITS-1:0\]      dq_out_en_dly_bd;"
                puts $ddr3_modi "    reg \[DQ_BITS-1:0\]      dq_out_dly_bd;"
                puts $ddr3_modi ""
                puts $ddr3_modi "    // added write board delay"
                puts $ddr3_modi "    always @\(rst_n  \) rst_n_in  <= #BUS_DELAY rst_n;"
                puts $ddr3_modi "    always @\(ck     \) ck_in     <= #\(BUS_DELAY+cmd_dly\) ck;"
                puts $ddr3_modi "    always @\(ck_n   \) ck_n_in   <= #\(BUS_DELAY+cmd_dly\) ck_n;"
                puts $ddr3_modi "    always @\(cke    \) cke_in    <= #\(BUS_DELAY+cmd_dly\) cke;"
                puts $ddr3_modi "    always @\(cs_n   \) cs_n_in   <= #\(BUS_DELAY+cmd_dly\) cs_n;"
                puts $ddr3_modi "    always @\(ras_n  \) ras_n_in  <= #\(BUS_DELAY+cmd_dly\) ras_n;"
                puts $ddr3_modi "    always @\(cas_n  \) cas_n_in  <= #\(BUS_DELAY+cmd_dly\) cas_n;"
                puts $ddr3_modi "    always @\(we_n   \) we_n_in   <= #\(BUS_DELAY+cmd_dly\) we_n;"
                puts $ddr3_modi "    always @\(dm_tdqs\) dm_in     <= #\(BUS_DELAY+wr_dly\) dm_tdqs;"
                puts $ddr3_modi "    always @\(ba     \) ba_in     <= #\(BUS_DELAY+cmd_dly\) ba;"
                puts $ddr3_modi "    always @\(addr   \) addr_in   <= #\(BUS_DELAY+cmd_dly\) addr;"
                puts $ddr3_modi "    always @\(dq     \) dq_in     <= #\(BUS_DELAY+wr_dly\) dq;"
                puts $ddr3_modi "    always @\(dqs or dqs_n\) dqs_in <=#\(BUS_DELAY+wr_dly\) \(dqs_n<<32\) | dqs;"
                puts $ddr3_modi "    always @\(odt    \) if \(!feature_odt_hi\) odt_in    <= #\(BUS_DELAY+cmd_dly\) odt;"
                puts $ddr3_modi ""
                for { set i 1 } { $i <= 18 } { incr i } {
                    gets $ddr3_orig line
                }
            } elseif {[regexp {timeformat} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi "`ifdef USE_TDQSCK_DLLDIS_RND"
                puts $ddr3_modi "          seed=`SEED;"
                puts $ddr3_modi "          tdqsck_dlloff_rnd = \$dist_uniform\(seed, TDQSCK_DLLDIS_MIN, TDQSCK_DLLDIS_MAX\);"
                puts $ddr3_modi "`else"
                puts $ddr3_modi "          seed = RANDOM_SEED;"
                puts $ddr3_modi "`endif" 
                gets $ddr3_orig line              
            } elseif {[regexp {integer                rdq_cntr;} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi ""
                puts $ddr3_modi "    // output \(read\) board delays"
                puts $ddr3_modi "    always @\(dqs_out_en_dly\) dqs_out_en_dly_bd <= #\(rd_dly+qs_dly\) dqs_out_en_dly;"
                puts $ddr3_modi "    always @\(dqs_out_dly\)    dqs_out_dly_bd    <= #\(rd_dly+qs_dly\) dqs_out_dly;"
                puts $ddr3_modi "    always @\(dq_out_en_dly\)  dq_out_en_dly_bd  <= #\(rd_dly\) dq_out_en_dly;"
                puts $ddr3_modi "    always @\(dq_out_dly\)     dq_out_dly_bd     <= #\(rd_dly\) dq_out_dly;"
                puts $ddr3_modi ""
                puts $ddr3_modi "    // use signals with output delays (original code commented out)"
                puts $ddr3_modi "    bufif1 buf_dqs    \[DQS_BITS-1:0\] \(dqs,     dqs_out_dly_bd,  dqs_out_en_dly_bd & {DQS_BITS{out_en}}\);"
                puts $ddr3_modi "    bufif1 buf_dqs_n  \[DQS_BITS-1:0\] \(dqs_n,   ~dqs_out_dly_bd, dqs_out_en_dly_bd & {DQS_BITS{out_en}}\);"
                puts $ddr3_modi "    bufif1 buf_dq     \[DQ_BITS-1:0\]  \(dq,      dq_out_dly_bd,   dq_out_en_dly_bd  & {DQ_BITS {out_en}}\);" 
                for { set i 1 } { $i <= 4 } { incr i } {
                    gets $ddr3_orig line
                }
            } elseif {[regexp {tm_cke_cmd > TPD_MAX} $line]} {
                puts $ddr3_modi "                            if \(check_pd_max && \(\$time - tm_cke_cmd > TPD_MAX\)\)"
            } elseif {[regexp {500000000} $line]} {   
                puts $ddr3_modi "`ifdef FULL_SDRAM_INIT"
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi $line
                puts $ddr3_modi "`endif"
            } elseif {[regexp {task data_task} $line]} { 
                puts $ddr3_modi $line  
                puts $ddr3_modi "        integer tdqsck_dlloff;" 
            } elseif {[regexp {ERROR:  tZQinit violation} $line]} {
                puts $ddr3_modi "            {1'bx, DIFF_BANK , ZQ       , SELF_REF } : begin"
                puts $ddr3_modi "`ifndef CLK_FREQ_CHG"
                puts $ddr3_modi "                                                              if \(ck_cntr - ck_zqinit < TZQINIT\)"
                puts $ddr3_modi "            \$display \(\"\%m: at time \%t ERROR:  tZQinit violation during \%s\", \$time, cmd_string\[cmd\]\);"
                puts $ddr3_modi "`endif"  
            } elseif {[regexp {ERROR:  tMOD violation during ODT transition} $line]} {
                puts $ddr3_modi "                            \$display \(\"\%m: at time \%t ERROR:  tMOD violation during ODT transition\",\$time\);"
                puts $ddr3_modi "`ifndef CLK_FREQ_CHG"
                puts $ddr3_modi "                        if \(ck_cntr - ck_zqinit < TZQINIT\)"
                puts $ddr3_modi "                            \$display \(\"\%m: at time \%t ERROR:  TZQinit violation during ODT transition\", \$time\);"
                puts $ddr3_modi "`endif" 
                gets $ddr3_orig line
                gets $ddr3_orig line
            } elseif {[regexp {tDSS violation on} $line]} {
                puts $ddr3_modi "                        if \(check_dqs_ck_setup_hold\) begin "
                puts $ddr3_modi "                          \$display \(\"\%m: at time \%t ERROR: tDSS violation on \%s bit \%d\", \$time, dqs_string\[i/32\], i\%32);"                
                puts $ddr3_modi "                          \$display \(\"\%m: at time \%t ERROR: tm_dqs_neg\[\%0d\] = \%0d\", \$time, i, tm_dqs_neg\[i\]);"                
                puts $ddr3_modi "                        end"                
                puts $ddr3_modi "                    if \(check_write_dqs_high\[i\] && check_dqs_latch\)"
                puts $ddr3_modi "                        \$display \(\"\%m: at time \%t ERROR: \%s bit \%d latching edge required during the preceding clock period.\", \$time, dqs_string\[i/32\], i\%32);"
                for { set i 1 } { $i <= 2 } { incr i } {
                    gets $ddr3_orig line
                }
            } elseif {[regexp {tck_avg/2.0} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi "                            if \(check_dqs_ck_setup_hold\) \$display \(\"\%m: at time \%t ERROR: tDQSS violation on \%s bit \%d\", \$time, dqs_string\[i/32\], i\%32\);"                
                gets $ddr3_orig line
                gets $ddr3_orig line
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi "                    if \(check_write_dqs_low\[i\] && check_dqs_latch\)"
                gets $ddr3_orig line
                puts $ddr3_modi $line
            } elseif {[regexp {dqsck_min, dqsck_max} $line]} {
                puts $ddr3_modi "`ifdef MODELSIM"
                puts $ddr3_modi "                    dqsck\[i\] = dqsck_min;"
                puts $ddr3_modi "`else"
                puts $ddr3_modi $line
                puts $ddr3_modi "`endif"
            } elseif {[regexp {dqsq_min, dqsq_max} $line]} {
                puts $ddr3_modi "`ifdef MODELSIM"
                puts $ddr3_modi "                                dq_out_dly   \[i*`DQ_PER_DQS + j\] <= #\(tck_avg/2 + dqsq_min\) dq_out\[i*`DQ_PER_DQS + j\];"
                puts $ddr3_modi "`else"
                puts $ddr3_modi $line
                puts $ddr3_modi "`endif"
            } elseif {[regexp {TDQSCK_DLLDIS;} $line]} {
                puts $ddr3_modi "                    begin"
                puts $ddr3_modi "`ifdef USE_TDQSCK_DLLDIS_MIN"
                puts $ddr3_modi "                      tdqsck_dlloff = TDQSCK_DLLDIS_MIN;"
                puts $ddr3_modi "`elsif USE_TDQSCK_DLLDIS_MAX"
                puts $ddr3_modi "                      tdqsck_dlloff = TDQSCK_DLLDIS_MAX;"
                puts $ddr3_modi "`elsif USE_TDQSCK_DLLDIS_RND"
                puts $ddr3_modi "                      tdqsck_dlloff =  tdqsck_dlloff_rnd;"
                puts $ddr3_modi "`else"
                puts $ddr3_modi "                      tdqsck_dlloff = TDQSCK_DLLDIS;"
                puts $ddr3_modi "`endif"
                puts $ddr3_modi "                    out_delay = \(\$rtoi\(tck_avg/2\) > 50000) ? 0 : \$rtoi\(tck_avg/2\) + tdqsck_dlloff;"
                puts $ddr3_modi "                    end"
            } elseif {[regexp {200000000} $line]} {
                puts $ddr3_modi "            if \(check_clocks\) begin"
                puts $ddr3_modi "`ifdef FULL_SDRAM_INIT"
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi $line
                puts $ddr3_modi "`endif"
                puts $ddr3_modi "                if \(cke_in !== 1'b0 && \$time > 0.001\)"
                puts $ddr3_modi "                    \$display \(\"\%m: at time \%t ERROR: CKE must be inactive when RST_N goes inactive.\", \$time);"
                puts $ddr3_modi "                if \(\$time - tm_cke < 10000 && \$time > 5000)"
                puts $ddr3_modi "                    \$display \(\"\%m: at time \%t ERROR: CKE must be maintained inactive for 10 ns before RST_N goes inactive.\", \$time\);"
                puts $ddr3_modi "            end"
                for { set i 1 } { $i <= 4 } { incr i } {
                    gets $ddr3_orig line
                }
            } elseif {[regexp {tIS violation on ODT} $line]} {
                puts $ddr3_modi "                        if \(check_clocks\)  \$display \(\"\%m: at time \%t ERROR: tIS violation on ODT by \%t\", \$time, tm_odt + TIS - \$time\);"
            } elseif {[regexp {check accumulated} $line]} {
                puts $ddr3_modi "                        if (check_clocks)"
                puts $ddr3_modi "                        begin"
                puts $ddr3_modi $line
                for { set i 1 } { $i <= 38 } { incr i } {
                    gets $ddr3_orig line
                    puts $ddr3_modi $line
                }
                puts $ddr3_modi "                        end"
            } elseif {[regexp {not valid} $line]} {
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi $line
                puts $ddr3_modi "                        end"
                puts $ddr3_modi "                        `endif"
            } elseif {[regexp {init_mode_reg\[0\]} $line]} {
                puts $ddr3_modi $line
                puts $ddr3_modi "                        `ifndef CLK_FREQ_CHG"
                puts $ddr3_modi "                        if \(check_clocks\)"
                puts $ddr3_modi "                        begin"
            } elseif {[regexp {CK and CK_N are} $line]} {
                puts $ddr3_modi "            if \(check_clocks\)    \$display \(\"\%m: at time \%t ERROR: CK and CK_N are not allowed to go to an unknown state.\", \$time);"
            } elseif {[regexp {15e3} $line]} {
                puts $ddr3_modi "                                9 : if \(\(tck_avg < 1070.0\) || \(tck_avg >= 1250.0\)\) \$display \(\"%m: at time \%t ERROR: CWL = \%d is illegal @tCK\(avg\) = \%f\", \$time, cas_write_latency, tck_avg\);"
                puts $ddr3_modi "                                10: if \(\(tck_avg < 938.0\) || \(tck_avg >= 1070.0\)\) \$display \(\"%m: at time \%t ERROR: CWL = \%d is illegal @tCK\(avg\) = \%f\", \$time, cas_write_latency, tck_avg\);"
                gets $ddr3_orig line
            } elseif {[regexp {!odt_in &&} $line]} {
                puts $ddr3_modi "                        if \(check_odth && !odt_in && \(ck_cntr - ck_odt < ODTH4\)\)"
                gets $ddr3_orig line
                puts $ddr3_modi $line
                puts $ddr3_modi "                        if \(check_odth && !odt_in && \(ck_cntr - ck_odth8 - ODTH8 < 0\)\)"
                gets $ddr3_orig line
                gets $ddr3_orig line
                puts $ddr3_modi $line
            } elseif {[regexp {tm_dqs_pos\[i\] < TWLH} $line]} {
                puts $ddr3_modi "//$line"
                gets $ddr3_orig line
                puts $ddr3_modi "//$line"
            } elseif {[regexp {tDSH violation on} $line]} {
                puts $ddr3_modi "                        if \(check_dqs_ck_setup_hold\) \$display \(\"\%m: at time \%t ERROR: tDSH violation on \%s bit \%d\", \$time, dqs_string\[i/32\], i\%32\);"
            } elseif {[regexp {Invalid latching edge on} $line]} {
                puts $ddr3_modi "                if\(check_dqs_latch\)"
                puts $ddr3_modi $line
            } elseif {[regexp {tm_ck_pos =} $line]} {
                for { set i 1 } { $i <= 4 } { incr i } {
                    puts $ddr3_modi $line
                    gets $ddr3_orig line
                }
                puts $ddr3_modi "                    if \(dll_locked  && check_clocks && check_strict_timing\) begin"            
            } elseif {[regexp {tDS violation on DQ} $line]} {
                puts $ddr3_modi "                            if \(check_dq_setup_hold\) \$display \(\"\%m: at time \%t ERROR: tDS violation on DQ bit \%d by \%t\", \$time, i*`DQ_PER_DQS+j, tm_dq\[\(i\%32\)*`DQ_PER_DQS+j\] + TDS - \$time\);"            
            } elseif {[regexp {tDS violation on DM} $line]} {
                puts $ddr3_modi "                    if \(check_dq_setup_hold\) \$display \(\"\%m: at time \%t ERROR: tDS violation on DM bit %d by \%t\", \$time, i,  tm_dm\[i\%32\] + TDS - \$time\);"            
            } elseif {[regexp {tDH violation on DM bit} $line]} {
                puts $ddr3_modi "                if \(check_dq_setup_hold\) \$display \(\"\%m: at time \%t ERROR:   tDH violation on DM bit \%d by \%t\", \$time, i, tm_dqs\[i\] + TDH - \$time\);"            
            } elseif {[regexp {tDIPW violation on DM bit} $line]} {
                puts $ddr3_modi "                    if \(check_dq_pulse_width\) \$display \(\"\%m: at time \%t ERROR: tDIPW violation on DM bit \%d by \%t\", \$time, i, tm_dm\[i\] + TDIPW - \$time\);"           
            } elseif {[regexp {tDH violation on DQ bit} $line]} {
                puts $ddr3_modi "                if \(check_dq_setup_hold\) \$display \(\"\%m: at time \%t ERROR:   tDH violation on DQ bit \%d by \%t\", \$time, i, tm_dqs\[i/`DQ_PER_DQS\] + TDH - \$time\);"            
            } elseif {[regexp {tDIPW violation on DQ bit} $line]} {
                puts $ddr3_modi "                   if \(check_dq_pulse_width\)  \$display \(\"\%m: at time \%t ERROR: tDIPW violation on DQ bit \%d by \%t\", \$time, i, tm_dq\[i\] + TDIPW - \$time\);"           
            } elseif {[regexp {cmd_addr_string\[i\], tm_ck_pos} $line]} {
                puts $ddr3_modi "                if \(check_cmd_addr_timing\) \$display \(\"\%m: at time \%t ERROR:  tIH violation on \%s by \%t\", \$time, cmd_addr_string\[i\], tm_ck_pos + TIH - \$time\);"
                gets $ddr3_orig line
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi "                if \(check_cmd_addr_timing\) \$display \(\"\%m: at time \%t ERROR:  tIH violation on \%s by \%t\", \$time, cmd_addr_string\[i\], tm_ck_pos + TIH - \$time\);"         
                gets $ddr3_orig line
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi "                if \(check_ctrl_addr_pulse_width\) \$display \(\"\%m: at time \%t ERROR: tIPW violation on %s by \%t\", \$time, cmd_addr_string\[i\], tm_cmd_addr\[i\] + TIPW - \$time\);"
                gets $ddr3_orig line
                puts $ddr3_modi $line
                gets $ddr3_orig line
                puts $ddr3_modi "                if \(check_ctrl_addr_pulse_width\) \$display \(\"\%m: at time \%t ERROR: tIPW violation on %s by \%t\", \$time, cmd_addr_string\[i\], tm_cmd_addr\[i\] + TIPW - \$time\);"
            } elseif {[regexp {tm_ck_pos < TWLS} $line]} {
                puts $ddr3_modi "//$line"
                gets $ddr3_orig line
                puts $ddr3_modi "//$line"    
            } elseif {[regexp {\#\(TWLO\)} $line]} {
                for { set i 1 } { $i <= 12 } { incr i } {
                    gets $ddr3_orig line
                }
                puts $ddr3_modi "        if \(wl_feedback_on_all_bits\) begin"
                puts $ddr3_modi "          for \(j=0; j<`DQ_PER_DQS; j=j+1\) begin"
                puts $ddr3_modi "            dq_out_en_dly\[i*`DQ_PER_DQS+j\] <= #\(TWLO\) 1'b1;"
                puts $ddr3_modi "            dq_out_dly\[i*`DQ_PER_DQS+j\]    <= #\(TWLO\) diff_ck;"
                puts $ddr3_modi "          end"
                puts $ddr3_modi "        end"
                puts $ddr3_modi "        else begin"
                puts $ddr3_modi "          // Only on one particular bit"
                puts $ddr3_modi "          for \(j=0; j<`DQ_PER_DQS; j=j+1\) begin"
                puts $ddr3_modi "            if \(j!= wl_feedback_on_bit\) begin" 
                puts $ddr3_modi "              dq_out_en_dly\[i*`DQ_PER_DQS+j\] <= #\(TWLO + TWLOE\) 1'b1;"
                puts $ddr3_modi "              dq_out_dly\[i*`DQ_PER_DQS+j\]    <= #\(TWLO + TWLOE\) 1'b0;"
                puts $ddr3_modi "            end"
                puts $ddr3_modi "            else begin"
                puts $ddr3_modi "              dq_out_en_dly\[i*`DQ_PER_DQS + wl_feedback_on_bit\] <= #\(TWLO\) 1'b1;"  
                puts $ddr3_modi "              dq_out_dly\[i*`DQ_PER_DQS + wl_feedback_on_bit\]    <= #\(TWLO\) diff_ck;"
                puts $ddr3_modi "            end"
                puts $ddr3_modi "          end"
                puts $ddr3_modi "        end"  
            } elseif {[regexp {tDQSL violation} $line]} {
                puts $ddr3_modi "                            if \(check_dq_pulse_width\) \$display \(\"\%m: at time \%t ERROR: tDQSL violation on %s bit \%d\", \$time, dqs_string\[i/32\], i\%32\);"
            } elseif {[regexp {tIH violation on ODT} $line]} {
                puts $ddr3_modi "                if \(check_cmd_addr_timing\) \$display \(\"\%m: at time \%t ERROR:  tIH violation on ODT by \%t\", \$time, tm_ck_pos + TIH - \$time\);"
            } elseif {[regexp {tIPW violation on ODT} $line]} {
                puts $ddr3_modi "                if \(check_cmd_addr_timing\) \$display \(\"\%m: at time \%t ERROR:  tIPW violation on ODT by \%t\", \$time, tm_odt + TIPW - \$time\);"
            } elseif {[regexp {tIH violation on CKE} $line]} {
                puts $ddr3_modi "                    if \(check_cmd_addr_timing\) \$display \(\"\%m: at time \%t ERROR:  tIH violation on CKE by \%t\", \$time, tm_ck_pos + TIH - \$time\);"            
            } elseif {[regexp {tIPW violation on CKE} $line]} {
               puts $ddr3_modi "                    if \(check_cmd_addr_timing\) \$display \(\"\%m: at time \%t ERROR:  tIPW violation on CKE by \%t\", \$time, tm_cke + TIPW - \$time\);"            
            } elseif {[regexp {tIPW violation on CKE} $line]} {
            } elseif {[regexp {!er_trfc_max && !in_self_refresh} $line]} {
                puts $ddr3_modi "            if (!er_trfc_max && !in_self_refresh && check_rfc_max) begin"
	        } elseif {[regexp {\(abs_value\(tjit_per_rtime\) - TJIT_PER >= 1.0\)} $line]} {
                puts $ddr3_modi "			if (\(abs_value\(tjit_per_rtime\) - TJIT_PER >= 1.0\) && !disable_jitter)"
	        } elseif {[regexp {\(abs_value\(tjit_cc_time\) - TJIT_CC >= 1.0\)} $line]} {
                puts $ddr3_modi "			if (\(abs_value\(tjit_cc_time\) - TJIT_CC >= 1.0\) && !disable_jitter)"
            } elseif {[regexp {negedge dqs_in\[\s*(\d+)\]\)\s+dqs_neg_timing_check} $line -> bit]} {
                set line "always @(negedge dqs_in\[$bit\]) if (dqs_in\[$bit\] == 1'b0) dqs_neg_timing_check($bit);"
                puts $ddr3_modi $line
            } elseif {[regexp {posedge dqs_in\[\s*(\d+)\]\)\s+dqs_neg_timing_check} $line -> bit]} {
                set line "always @(posedge dqs_in\[$bit\]) if (dqs_in\[$bit\] == 1'b1) dqs_neg_timing_check($bit);"
                puts $ddr3_modi $line
            # Filter out some race condition for dqs_neg_timing_check	    
            } elseif {[regexp {tm_dqs_neg\[i\] = \$time;} $line]}  {
                puts $ddr3_modi "        if (dqs_in\[i\] !== prev_dqs_in\[i\]) begin "
                puts $ddr3_modi "          tm_dqs_neg\[i\] = \$time;"
                puts $ddr3_modi "           -> e_tm_dqs_neg;"
                puts $ddr3_modi "        end" 
	          # Filter out Xs at start of simulation
            #} elseif {[regexp { if \(cke_in !== 1\'b0} $line ]} {
            #    puts $ddr3_modi "            if (cke_in !== 1'b0 && \$time>10000)"
            # Filter out false errors of "CKE must be maintained inactive" at start of simulation
            } elseif {[regexp { if \(\$time - tm_cke < 10000} $line ]} {
                puts $ddr3_modi "            if (\$time - tm_cke < 10000 && \$time>10000)"
            # Remove include statements for individual density parameter files - using a single parameters file instead
            } elseif {[regexp {ifdef.*den} $line]} {
                puts $ddr3_modi "`define den1024Mb 1"
                puts $ddr3_modi "`include \"ddr3_parameters.vh\""
                set in_include_statements 1
            } elseif {[regexp {endif} $line]} {
                if {$in_include_statements} {
                    set in_include_statements 0
                } else {
                    puts $ddr3_modi $line
                }
            } elseif {$in_include_statements} {
        
            # Remove define MAX_MEM - use a sparse model, so we don't run out of memory
            } elseif {[regexp  {`define MAX_MEM} $line]} {
  	        } elseif {[regexp {> TIS\)} $line]} {
                puts $ddr3_modi "                if (check_clocks)"
                puts $ddr3_modi "                begin"
                puts $ddr3_modi $line
                for { set i 1 } { $i <= 9 } { incr i } {
                    gets $ddr3_orig line
                    puts $ddr3_modi $line
                }
                puts $ddr3_modi "                end"
            } elseif {[regexp {if \(terr_nper_rtime - TERR_} $line]} {
	            regsub {if \(terr_nper_rtime - TERR_} $line {if ((!disable_terr) \&\& (terr_nper_rtime - TERR_} line
                if {[regexp {PER >= 1.0\) } $line]} {
	            regsub {PER >= 1.0\)} $line {PER >= 1.0))} line
	        }
                puts $ddr3_modi $line
	        # For x4 8GB devices, we need to use column bit 13.  Need to change the assignment of col in read/write branches
            } elseif {[regexp {addr\[BC-1} $line]} {
                regsub {addr\[BC-1} $line {addr[BC+1], addr[BC-1} line
                puts $ddr3_modi $line           
            # RD/RDA command after SRX in DLL-off mode
            } else {
                puts $ddr3_modi $line
            }
        }
    
        close $ddr3_modi
        close $ddr3_orig
    }

#########################################################################
# ddr3_parameters.vh

    if {[file exists $source_dir/1024Mb_ddr3_parameters.vh]} {

        if {[file exists $dest_dir/ddr3_parameters.vh]} { file delete $dest_dir/ddr3_parameters.vh}
        set ddr3p_orig [open $source_dir/1024Mb_ddr3_parameters.vh r]
        set ddr3p_modi [open $dest_dir/ddr3_parameters.vh a]

        set store_15e 0
        set store_125e 0
        while {[gets $ddr3p_orig line] >=0} {
            # Add sg15F speed bin. Similar to sg15E, so store section with most of the timing params and modify it appropriately
            if {[regexp {`elsif sg15E } $line ]} {
                set store_15e 1
                set text_15e $line\n;
                set text_15f ""
            } elseif {[regexp {`elsif sg15 } $line ]} {
                set store_15e 0 
                regsub -all {sg15E} $text_15e {sg15F} text_15f
                regsub -all {1333H} $text_15f {1333G} text_15f
                regsub -all {9-9-9} $text_15f {8-8-8} text_15f
                regsub {(parameter TRC\s*=\s*) (\d+)} $text_15f {\1 48000} text_15f
                regsub {(parameter TRCD\s*=\s*) (\d+)} $text_15f {\1 12000} text_15f
                regsub {(parameter TRP\s*=\s*) (\d+)} $text_15f {\1 12000} text_15f
                regsub {(parameter TAA_MIN\s*=\s*) (\d+)} $text_15f {\1 12000} text_15f
                regsub {(parameter CL_TIME\s*=\s*) (\d+)} $text_15f {\1 12000} text_15f
                puts $ddr3p_modi $text_15f
                puts $ddr3p_modi $text_15e
                puts $ddr3p_modi $line
            } elseif {$store_15e == 1} {
                append text_15e "$line\n"
            } elseif {[regexp {JEDEC DDR3-1866} $line]} {
                puts $ddr3p_modi "`elsif sg093E                             // sg093E is equivalent to the JEDEC DDR3-2133 \(13-13-13\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =     935; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      50; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     100; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =      74; // tERR\(2per\) ps    Accumulated Error \(2-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =      87; // tERR\(3per\) ps    Accumulated Error \(3-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =      97; // tERR\(4per\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     105; // tERR\(5per\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     111; // tERR\(6per\) ps    Accumulated Error \(6-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     116; // tERR\(7per\) ps    Accumulated Error \(7-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     121; // tERR\(8per\) ps    Accumulated Error \(8-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     125; // tERR\(9per\) ps    Accumulated Error \(9-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     128; // tERR\(10per\)ps    Accumulated Error \(10-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     132; // tERR\(11per\)ps    Accumulated Error \(11-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     134; // tERR\(12per\)ps    Accumulated Error \(12-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =       5; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =      20; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =      70; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "    parameter TDSS             =    0.18; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.18; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TDQSCK           =     175; // tDQSCK     ps    DQS output access time from CK/CK"
                puts $ddr3p_modi "    parameter TQSH             =    0.40; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.40; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TDIPW            =     280; // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =     470; // tIPW       ps    Control and Address input Pulse Width"  
                puts $ddr3p_modi "    parameter TIS              =      35; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =      75; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   33000; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   47155; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   12155; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   12155; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    6000; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     180; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     122; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     122; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TWLO             =    7500; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "    parameter TAA_MIN          =   12155; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   12155; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "`elsif sg093F                             // sg093F is equivalent to the JEDEC DDR3-2133 \(12-12-12\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =     935; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      50; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     100; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =      74; // tERR\(2per\) ps    Accumulated Error \(2-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =      87; // tERR\(3per\) ps    Accumulated Error \(3-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =      97; // tERR\(4per\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     105; // tERR\(5per\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     111; // tERR\(6per\) ps    Accumulated Error \(6-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     116; // tERR\(7per\) ps    Accumulated Error \(7-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     121; // tERR\(8per\) ps    Accumulated Error \(8-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     125; // tERR\(9per\) ps    Accumulated Error \(9-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     128; // tERR\(10per\)ps    Accumulated Error \(10-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     132; // tERR\(11per\)ps    Accumulated Error \(11-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     134; // tERR\(12per\)ps    Accumulated Error \(12-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =       5; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =      20; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =      70; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "    parameter TDSS             =    0.18; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.18; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TDQSCK           =     175; // tDQSCK     ps    DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TQSH             =    0.40; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.40; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TDIPW            =     280; // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =     470; // tIPW       ps    Control and Address input Pulse Width"  
                puts $ddr3p_modi "    parameter TIS              =      35; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =      75; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   33000; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   46220; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   11220; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   11220; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    6000; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     180; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     122; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     122; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TWLO             =    7500; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "    parameter TAA_MIN          =   11220; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   11220; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "`elsif sg0935K                            // sg0935G is equivelant to the JEDEC DDR3-2133 \(11-11-11\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =     935; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      70; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     140; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =     103; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     125; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     140; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     150; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     162; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     171; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     180; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     185; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     190; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     195; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     200; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =     115; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =     115; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =     100; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSCK           =     200; // tDQSCK     tCK   DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TIS              =     180; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     180; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   35000 - `DWC_DRAM_CKAVG_ERR; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   45000 - `DWC_DRAM_CKAVG_ERR; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   10285 - `DWC_DRAM_CKAVG_ERR; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   10285 - `DWC_DRAM_CKAVG_ERR; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    5000 - `DWC_DRAM_CKAVG_ERR; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000 - `DWC_DRAM_CKAVG_ERR; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     250; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     195; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     195; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TAA_MIN          =   10285 - `DWC_DRAM_CKAVG_ERR; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =    9350 - `DWC_DRAM_CKAVG_ERR; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "    parameter TDIPW            =    280;  // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "    parameter TDSS             =    0.20; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.20; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TQSH             =    0.38; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.38; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =     561; // tIPW       ps    Control and Address input Pulse Width  0.6*tCK=0.6*0.935"
                puts $ddr3p_modi "    parameter TWLO             =    9000; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "`elsif sg107E                             // sg107E is equivalent to the JEDEC DDR3-1866 \(12-12-12\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =    1070; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      60; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     120; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =      88; // tERR\(2per\) ps    Accumulated Error \(2-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     105; // tERR\(3per\) ps    Accumulated Error \(3-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     117; // tERR\(4per\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     126; // tERR\(5per\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     133; // tERR\(6per\) ps    Accumulated Error \(6-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     139; // tERR\(7per\) ps    Accumulated Error \(7-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     145; // tERR\(8per\) ps    Accumulated Error \(8-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     150; // tERR\(9per\) ps    Accumulated Error \(9-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     154; // tERR\(10per\)ps    Accumulated Error \(10-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     158; // tERR\(11per\)ps    Accumulated Error \(11-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     161; // tERR\(12per\)ps    Accumulated Error \(12-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =      10; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =      20; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =      80; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "    parameter TDSS             =    0.18; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.18; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TDQSCK           =     200; // tDQSCK     ps    DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TQSH             =    0.40; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.40; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TDIPW            =     320; // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =     535; // tIPW       ps    Control and Address input Pulse Width"  
                puts $ddr3p_modi "    parameter TIS              =      50; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     100; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   34000; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   47840; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   12840; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   12840; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    6000; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     200; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     140; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     140; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TWLO             =    7500; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "    parameter TAA_MIN          =   12840; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   12840; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "`elsif sg107F                             // sg107F  is equivalent to the JEDEC DDR3-1866 \(11-11-11\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =    1070; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      60; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     120; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =      88; // tERR\(2per\) ps    Accumulated Error \(2-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     105; // tERR\(3per\) ps    Accumulated Error \(3-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     117; // tERR\(4per\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     126; // tERR\(5per\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     133; // tERR\(6per\) ps    Accumulated Error \(6-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     139; // tERR\(7per\) ps    Accumulated Error \(7-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     145; // tERR\(8per\) ps    Accumulated Error \(8-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     150; // tERR\(9per\) ps    Accumulated Error \(9-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     154; // tERR\(10per\)ps    Accumulated Error \(10-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     158; // tERR\(11per\)ps    Accumulated Error \(11-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     161; // tERR\(12per\)ps    Accumulated Error \(12-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =      10; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =      20; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =      80; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "    parameter TDSS             =    0.18; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.18; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TDQSCK           =     200; // tDQSCK     ps    DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TQSH             =    0.40; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.40; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TDIPW            =     320; // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =     535; // tIPW       ps    Control and Address input Pulse Width" 
                puts $ddr3p_modi "    parameter TIS              =      50; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     100; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   34000; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   46770; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   11770; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   11770; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    6000; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     200; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     140; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     140; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TWLO             =    7500; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "    parameter TAA_MIN          =   11770; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   11770; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "`elsif sg107J                       // sg107J is equivelant to the JEDEC DDR3-1866J \(10-10-10\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =    1070; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      70; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     140; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =     103; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     125; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     140; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     150; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     162; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     171; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     180; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     185; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     190; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     195; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     200; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =     115; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =     115; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =     100; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSCK           =     200; // tDQSCK     tCK   DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TIS              =     180; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     180; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   35000 - `DWC_DRAM_CKAVG_ERR; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   45000 - `DWC_DRAM_CKAVG_ERR; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   10700 - `DWC_DRAM_CKAVG_ERR; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   10700 - `DWC_DRAM_CKAVG_ERR; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    5000 - `DWC_DRAM_CKAVG_ERR; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000 - `DWC_DRAM_CKAVG_ERR; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     250; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     195; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     195; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TAA_MIN          =   10700 - `DWC_DRAM_CKAVG_ERR; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =    9630 - `DWC_DRAM_CKAVG_ERR; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "    parameter TDIPW            =    320;  // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "	  parameter TDSS             =    0.20; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "	  parameter TDSH             =    0.20; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "	  parameter TQSH             =    0.38; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "	  parameter TQSL             =    0.38; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "	  parameter TIPW             =     642; // tIPW       ps    Control and Address input Pulse Width  0.6*tCK=0.6*1070"
                puts $ddr3p_modi "	  parameter TWLO             =    9000; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "`elsif sg125G                       // sg125G is equivelant to the JEDEC DDR3-1600 \(8-8-8\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =    1250; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      70; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     140; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =     103; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     125; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     140; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     150; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     162; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     171; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     180; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     185; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     190; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     195; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     200; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =     115; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =     115; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =     100; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSCK           =     200; // tDQSCK     tCK   DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TIS              =     180; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     180; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   35000 - `DWC_DRAM_CKAVG_ERR; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   45000 - `DWC_DRAM_CKAVG_ERR; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   10000 - `DWC_DRAM_CKAVG_ERR; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   10000 - `DWC_DRAM_CKAVG_ERR; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    5000 - `DWC_DRAM_CKAVG_ERR; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5000 - `DWC_DRAM_CKAVG_ERR; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     250; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     195; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     195; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TAA_MIN          =   10000 - `DWC_DRAM_CKAVG_ERR; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   10000 - `DWC_DRAM_CKAVG_ERR; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "    parameter TDIPW            =    360;  // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TDQSS            =    0.27; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "	  parameter TDSS             =    0.20; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "	  parameter TDSH             =    0.20; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "	  parameter TQSH             =    0.38; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.38; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "	  parameter TIPW             =     750; // tIPW       ps    Control and Address input Pulse Width  0.6*tCK=0.6*1250"
                puts $ddr3p_modi "	  parameter TWLO             =    9000; // tWLO       ps    Write levelization output delay"            
                puts $ddr3p_modi "`elsif sg15G                              // sg15G is equivelant to the JEDEC DDR3-1333F \(7-7-7\) speed bin"
                puts $ddr3p_modi "	parameter TCK_MIN          =    1500; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      80; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     160; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =     118; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     140; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     155; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     168; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     177; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     186; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     193; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     200; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     205; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     210; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     215; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =     150; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =     150; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =     125; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSCK           =     255; // tDQSCK     tCK   DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TIS              =     240; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     240; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   36000 - `DWC_DRAM_CKAVG_ERR; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   46500 - `DWC_DRAM_CKAVG_ERR; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   10500 - `DWC_DRAM_CKAVG_ERR; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   10500 - `DWC_DRAM_CKAVG_ERR; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    6000 - `DWC_DRAM_CKAVG_ERR; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5625 - `DWC_DRAM_CKAVG_ERR; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     250; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     195; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     195; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TAA_MIN          =   10500 - `DWC_DRAM_CKAVG_ERR; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   10500 - `DWC_DRAM_CKAVG_ERR; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "    parameter TDIPW            =    400;  // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "	  parameter TDQSS            =    0.25; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "	  parameter TDSS             =    0.20; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.20; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TQSH             =    0.38; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.38; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =     900; // tIPW       ps    Control and Address input Pulse Width  0.6*tCK=0.6*1500"
                puts $ddr3p_modi "    parameter TWLO             =    9000; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi "`elsif sg187F                       // sg187F is equivelant to the JEDEC DDR3-1066E \(6-6-6\) speed bin"
                puts $ddr3p_modi "    parameter TCK_MIN          =    1875; // tCK        ps    Minimum Clock Cycle Time"
                puts $ddr3p_modi "    parameter TJIT_PER         =      90; // tJIT\(per\)  ps    Period JItter"
                puts $ddr3p_modi "    parameter TJIT_CC          =     180; // tJIT\(cc\)   ps    Cycle to Cycle jitter"
                puts $ddr3p_modi "    parameter TERR_2PER        =     132; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_3PER        =     157; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_4PER        =     175; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_5PER        =     188; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_6PER        =     200; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_7PER        =     209; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_8PER        =     217; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_9PER        =     224; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_10PER       =     231; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TERR_11PER       =     237; // tERR\(nper\) ps    Accumulated Error \(5-cycle\)"
                puts $ddr3p_modi "    parameter TERR_12PER       =     242; // tERR\(nper\) ps    Accumulated Error \(4-cycle\)"
                puts $ddr3p_modi "    parameter TDS              =     200; // tDS        ps    DQ and DM input setup time relative to DQS"
                puts $ddr3p_modi "    parameter TDH              =     200; // tDH        ps    DQ and DM input hold time relative to DQS"
                puts $ddr3p_modi "    parameter TDQSQ            =     150; // tDQSQ      ps    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $ddr3p_modi "    parameter TDQSCK           =     300; // tDQSCK     tCK   DQS output access time from CK/CK#"
                puts $ddr3p_modi "    parameter TIS              =     300; // tIS        ps    Input Setup Time"
                puts $ddr3p_modi "    parameter TIH              =     300; // tIH        ps    Input Hold Time"
                puts $ddr3p_modi "    parameter TRAS_MIN         =   37500; // tRAS       ps    Minimum Active to Precharge command time"
                puts $ddr3p_modi "    parameter TRC              =   48750; // tRC        ps    Active to Active/Auto Refresh command time"
                puts $ddr3p_modi "    parameter TRCD             =   11250; // tRCD       ps    Active to Read/Write command time"
                puts $ddr3p_modi "    parameter TRP              =   11250; // tRP        ps    Precharge command period"
                puts $ddr3p_modi "    parameter TXP              =    7500; // tXP        ps    Exit power down to a valid command"
                puts $ddr3p_modi "    parameter TCKE             =    5625; // tCKE       ps    CKE minimum high or low pulse width"
                puts $ddr3p_modi "    parameter TAON             =     300; // tAON       ps    RTT turn-on from ODTLon reference"
                puts $ddr3p_modi "    parameter TWLS             =     245; // tWLS       ps    Setup time for tDQS flop"
                puts $ddr3p_modi "    parameter TWLH             =     245; // tWLH       ps    Hold time of tDQS flop"
                puts $ddr3p_modi "    parameter TAA_MIN          =   11250; // TAA        ps    Internal READ command to first data"
                puts $ddr3p_modi "    parameter CL_TIME          =   11250 - `DWC_DRAM_CKAVG_ERR; // CL         ps    Minimum CAS Latency"
                puts $ddr3p_modi "    parameter TDIPW            =    490;  // tDIPW      ps    DQ and DM input Pulse Width"
                puts $ddr3p_modi "    parameter TDQSS            =    0.25; // tDQSS      tCK   Rising clock edge to DQS/DQS# latching transition"
                puts $ddr3p_modi "    parameter TDSS             =    0.20; // tDSS       tCK   DQS falling edge to CLK rising \(setup time\)"
                puts $ddr3p_modi "    parameter TDSH             =    0.20; // tDSH       tCK   DQS falling edge from CLK rising \(hold time\)"
                puts $ddr3p_modi "    parameter TQSH             =    0.38; // tQSH       tCK   DQS Output High Pulse Width"
                puts $ddr3p_modi "    parameter TQSL             =    0.38; // tQSL       tCK   DQS Output Low Pulse Width"
                puts $ddr3p_modi "    parameter TIPW             =    1125; // tIPW       ps    Control and Address input Pulse Width  0.6*tCK=0.6*1875"
                puts $ddr3p_modi "    parameter TWLO             =    9000; // tWLO       ps    Write levelization output delay"
                puts $ddr3p_modi $line 
            } elseif {[regexp {TCK_MAX} $line]} {
                puts $ddr3p_modi "    parameter TCK_MAX          =    10000; // tCK        ps    Maximum Clock Cycle Time"
            } elseif {[regexp {DLLDIS} $line]} {
                puts $ddr3p_modi "    parameter TDQSCK_DLLDIS    =  10000; // tDQSCK\(DLL_off\)  ps"
                puts $ddr3p_modi "    parameter TDQSCK_DLLDIS_MIN =  1000;    // tDQSCK\(DLL_off\)  ps"
                puts $ddr3p_modi "    parameter TDQSCK_DLLDIS_MAX =  10000;   // tDQSCK\(DLL_off\)  ps"               
            } elseif {[regexp {ifdef x16} $line]} {
                puts $ddr3_modi $line
                for { set i 1 } { $i <= 3 } { incr i } {
                    gets $ddr3_orig line
                    puts $ddr3_modi $line
                }
                puts $ddr3p_modi "  `elsif sg093E"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   35000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg093F"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   35000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg0935K"
                puts $ddr3p_modi "    parameter TRRD             =    7500; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   45000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg107E"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   35000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg107F"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   35000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg107J"
                puts $ddr3p_modi "    parameter TRRD             =    7500; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   45000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg125G"
                puts $ddr3p_modi "    parameter TRRD             =    7500; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   45000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg15G"
                puts $ddr3p_modi "    parameter TRRD             =    7500; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   45000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg187F"
                puts $ddr3p_modi "    parameter TRRD             =    7500; // tRRD       ps     \(2KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   45000; // tFAW       ps     \(2KB page size\) Four Bank Activate window"            
            } elseif {[regexp {lse // x4, x8} $line]} {
                puts $ddr3_modi $line
                for { set i 1 } { $i <= 3 } { incr i } {
                    gets $ddr3_orig line
                    puts $ddr3_modi $line
                }
                puts $ddr3p_modi "  `elsif sg093E"
                puts $ddr3p_modi "    parameter TRRD             =    5000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   25000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg093F"
                puts $ddr3p_modi "    parameter TRRD             =    5000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   25000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg0935K"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   30000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg107E"
                puts $ddr3p_modi "    parameter TRRD             =    5000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   25000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg107F"
                puts $ddr3p_modi "    parameter TRRD             =    5000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   25000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg107J"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   30000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg125G"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   30000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg15G"
                puts $ddr3p_modi "    parameter TRRD             =    6000; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   30000; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                puts $ddr3p_modi "  `elsif sg187F"
                puts $ddr3p_modi "    parameter TRRD             =    7500; // tRRD       ps     \(1KB page size\) Active bank a to Active bank b command time"
                puts $ddr3p_modi "    parameter TFAW             =   37500; // tFAW       ps     \(1KB page size\) Four Bank Activate window"
                
            } elseif {[regexp {\s*parameter TRRD\s*=\s*\d+.*} $line trrd]} {
                puts $ddr3p_modi $line
            } elseif {[regexp {\s*parameter TFAW\s*=\s*\d+.*} $line tfaw]} {
                puts $ddr3p_modi $line
            } elseif {[regexp { `elsif sg15$} $line]} {
                puts $ddr3p_modi "  `elsif sg15F"
                puts $ddr3p_modi $trrd
                puts $ddr3p_modi $tfaw
                puts $ddr3p_modi $line
            } elseif {[regexp {^`elsif sg15E$} $line]} {
                puts $ddr3p_modi "`elsif sg15F"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd8},"
                puts $ddr3p_modi "        {4'd7, 4'd9},"
                puts $ddr3p_modi "        {4'd7, 4'd10}: valid_cl = 1;"
                puts $ddr3p_modi $line
            # Add sg125F speed bin. Similar to sg125E, so store section with most of the timing params and modify it appropriately
            #} elseif {[regexp {`elsif sg125E } $line ]} {
#                set store_125e 1
#                set text_125e $line\n;
#                set text_125f ""
#            } elseif {[regexp {`elsif sg125 } $line]} {
#                set store_125e 0
#                regsub -all {sg125E} $text_125e {sg125F} text_125f
#                regsub -all {10-10-10} $text_125f {9-9-9} text_125f
#                regsub {(parameter TRC\s*=\s*) (\d+)} $text_125f {\1 46250} text_125f
#                regsub {(parameter TRCD\s*=\s*) (\d+)} $text_125f {\1 11250} text_125f
#                regsub {(parameter TRP\s*=\s*) (\d+)} $text_125f {\1 11250} text_125f
#                regsub {(parameter TAA_MIN\s*=\s*) (\d+)} $text_125f {\1 11250} text_125f
#                regsub {(parameter CL_TIME\s*=\s*) (\d+)} $text_125f {\1 11250} text_125f
#                puts $ddr3p_modi $text_125f
#                puts $ddr3p_modi $text_125e
#                puts $ddr3p_modi $line
#            } elseif {$store_125e == 1} {
#                append text_125e "$line\n"
            } elseif {[regexp { `elsif sg125$} $line]} {
                puts $ddr3p_modi "  `elsif sg125F"
                puts $ddr3p_modi $trrd
                puts $ddr3p_modi $tfaw
                puts $ddr3p_modi $line
            } elseif {[regexp {^`elsif sg125E$} $line]} {
                puts $ddr3p_modi "`elsif sg125F"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd8},"
                puts $ddr3p_modi "        {4'd7, 4'd9},"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd9},"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11}: valid_cl = 1;"
                puts $ddr3p_modi $line
            } elseif {[regexp {cwl, cl} $line]} {
                puts $ddr3_modi $line
                for { set i 1 } { $i <= 10 } { incr i } {
                    gets $ddr3_orig line
                    puts $ddr3_modi $line
                }
                puts $ddr3p_modi "`elsif sg093E"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd12},"
                puts $ddr3p_modi "        {4'd9, 4'd13},"
                puts $ddr3p_modi "        {4'd10, 4'd13},"
                puts $ddr3p_modi "        {4'd10, 4'd14}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg093F"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd9 },"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd12},"
                puts $ddr3p_modi "        {4'd9, 4'd13},"
                puts $ddr3p_modi "        {4'd10, 4'd12},"
                puts $ddr3p_modi "        {4'd10, 4'd13},"
                puts $ddr3p_modi "        {4'd10, 4'd14}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg0935K"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd7 },"
                puts $ddr3p_modi "        {4'd7, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd9 },"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd10},"
                puts $ddr3p_modi "        {4'd9, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd12},"
                puts $ddr3p_modi "        {4'd9, 4'd13},"
                puts $ddr3p_modi "        {4'd10, 4'd11},"
                puts $ddr3p_modi "        {4'd10, 4'd12},"
                puts $ddr3p_modi "        {4'd10, 4'd13},"
                puts $ddr3p_modi "        {4'd10, 4'd14}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg107E"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd12},"
                puts $ddr3p_modi "        {4'd9, 4'd13}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg107F"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd12},"
                puts $ddr3p_modi "        {4'd9, 4'd13}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg107J"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd9 },"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd11},"
                puts $ddr3p_modi "        {4'd9, 4'd12},"
                puts $ddr3p_modi "        {4'd9, 4'd13}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg125G"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd7 },"
                puts $ddr3p_modi "        {4'd7, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd8},"
                puts $ddr3p_modi "        {4'd8, 4'd9},"
                puts $ddr3p_modi "        {4'd8, 4'd10},"
                puts $ddr3p_modi "        {4'd8, 4'd11}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg15G"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd7 },"
                puts $ddr3p_modi "        {4'd7, 4'd8 },"
                puts $ddr3p_modi "        {4'd7, 4'd9 },"
                puts $ddr3p_modi "        {4'd7, 4'd10}: valid_cl = 1;"
                puts $ddr3p_modi "`elsif sg187F"
                puts $ddr3p_modi "        {4'd5, 4'd5 },"
                puts $ddr3p_modi "        {4'd5, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd6 },"
                puts $ddr3p_modi "        {4'd6, 4'd7 },"
                puts $ddr3p_modi "        {4'd6, 4'd8 }: valid_cl = 1;"
            # Need different TRFC depending on device density
            } elseif {[regexp {parameter TRFC_MIN\s*=\s*(\d+)} $line -> trfc_min]} {
                puts $ddr3p_modi "`ifdef den512Mb"
                regsub $trfc_min $line 90000 line_new
                puts $ddr3p_modi $line_new
            
                puts $ddr3p_modi "`elsif den1024Mb"
                regsub $trfc_min $line 110000 line_new
                puts $ddr3p_modi $line_new
            
                puts $ddr3p_modi "`elsif den2048Mb"
                regsub $trfc_min $line 160000 line_new
                puts $ddr3p_modi $line_new
            
                puts $ddr3p_modi "`elsif den4096Mb"
                regsub $trfc_min $line 260000 line_new
                puts $ddr3p_modi $line_new
            
                puts $ddr3p_modi "`elsif den8192Mb"
                regsub $trfc_min $line 350000 line_new
                puts $ddr3p_modi $line_new
            
                puts $ddr3p_modi "`endif"
    
            # Need to modify definition of TXS to make it dependent on TRFC
            } elseif {[regexp {parameter TXS\s*=\s*(\d+)} $line -> txs]} {
                regsub $txs $line "TRFC_MIN + 10000" line
                puts $ddr3p_modi $line
	    # Need to modify definition of TRFC_MAX to JEDEC value
	    } elseif {[regexp {parameter TRFC_MAX\s*=\s*(\d+)} $line -> trfc_max]} {
                regsub $trfc_max $line 70200000 line
                puts $ddr3p_modi $line

            # Remove MAX_MEM define
            } elseif {[regexp {define\s+MAX_MEM} $line]} {
                puts $ddr3p_modi "// `define MAX_MEM"
            } else {
                puts $ddr3p_modi $line
            }
        }
    
        close $ddr3p_modi
        close $ddr3p_orig
    }
}
#########################################################################
# mobile_ddr.v
if {($tc_ddr_mode == "LPDDR1") || ($tc_ddr_mode == "ALL")} {
    if {[file exists $source_dir/mobile_ddr.v]} {

        if {[file exists $dest_dir/mobile_ddr.v]} { file delete $dest_dir/mobile_ddr.v}
        set mddr_orig [open $source_dir/mobile_ddr.v r]
        set mddr_modi [open $dest_dir/mobile_ddr.v a]
        while {[gets $mddr_orig line] >=0} {
            # Update to stop false errors firing at start of simulation and when clock is restarted just after it is removed/stopped
            if {[regexp {reg (clock_stop)} $line -> clkstp] } {
                puts $mddr_modi $line
                regsub $clkstp $line {prev_clock_stop} line
                puts $mddr_modi $line
            } elseif {[regexp {if \(Cke & Clk_Chk_enable} $line] } {
                puts $mddr_modi "        prev_clock_stop = clock_stop;"
                puts $mddr_modi $line
            } elseif {[regexp {MIN\).*(clock_stop)} $line -> clkstp]} {
                regsub $clkstp $line {clock_stop \&\& ~prev_clock_stop \&\& ($realtime > 2 * clk_period)} line
                puts $mddr_modi $line
        
            # Replace Debug wire with a parameter (defined in mobile_ddr_parameters.vh)
            } elseif {[regexp {wire\s+Debug} $line]} {
            # Get setup violations from setuphold at start-up because Clk input goes from x to 1. Fix this by using
            # diff_ck_wire in the setuphold, and initialize diff_ck to 1.  Need to define diff_ck_wire because NCSim
            # doesn't like using a reg in a setuphold statemetn
            } elseif {[regexp {reg\s+diff_ck} $line]} {
                puts $mddr_modi $line
                puts $mddr_modi "    // Initialize diff_ck to 1 to avoid setup violations at startup"
                puts $mddr_modi "    wire diff_ck_wire = diff_ck;"
                puts $mddr_modi "    initial diff_ck = 1'b1;"
            } elseif {[regexp {setuphold\(posedge (Clk)} $line]} {
                regsub {Clk} $line {diff_ck_wire} line_new
                puts $mddr_modi $line_new
            # Initialise Read_pipeline to avoid bus conflict errors at startup
            } elseif {[regexp {initial\s+begin} $line] } {    
                puts $mddr_modi $line
                puts $mddr_modi "        Read_pipeline = {`MAX_PIPE{1'b0}};"
            # Definition of tWR_cycle can give incorrect answer if clk_period varies slightly
            # below nominal period.  Add a ps to avoid this
            } elseif {[regexp {tWR_cycle\s+=} $line]} { 
                regsub {\(\s*tWR} $line {((tWR - 0.001)} line
                puts $mddr_modi $line
            } else {
                puts $mddr_modi $line
            }
        }
        close $mddr_modi
        close $mddr_orig

    }

#########################################################################
# mobile_ddr_parameters.vh
    foreach filename [glob -nocomplain $source_dir/*_mobile_ddr_parameters.vh] {
        set filename_only [file tail $filename]
        if {[file exists $dest_dir/$filename_only]} { file delete $dest_dir/$filename_only}
        set mddrp_orig [open $source_dir/$filename_only r]
        set mddrp_modi [open $dest_dir/$filename_only a]
        set endifs_required 0
        set in_sg75 0
        while {[gets $mddrp_orig line] >=0} {
            # Add Debug parameter - removed as wire from mobile_ddr.v
            if {[regexp {SYMBOL} $line]} {
                puts $mddrp_modi "    parameter Debug = 0;"
                puts $mddrp_modi $line
	    # 256Mb version is missing sg5 and sg54
            } elseif {[regexp {^\`ifdef sg6} $line]} {
                puts $mddrp_modi "`ifdef sg5                                //              Timing Parameters for -5 (CL = 3)"
                puts $mddrp_modi "    parameter tAC3_max         =     5.0; // tAC    ns    Access window of DQ from CK/CK#"
                puts $mddrp_modi "    parameter tAC2_max         =     6.5; // tAC    ns    Access window of DQ from CK/CK#"
                puts $mddrp_modi "    parameter tCK              =     5.0; // tCK    ns    Nominal Clock Cycle Time"
                puts $mddrp_modi "    parameter tCK3_min         =     5.0; // tCK    ns    Nominal Clock Cycle Time"
                puts $mddrp_modi "    parameter tCK2_min         =    12.0; // tCK    ns    Nominal Clock Cycle Time"
                puts $mddrp_modi "    parameter tDQSQ            =    0.40; // tDQSQ  ns    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $mddrp_modi "    parameter tHZ3_max         =     5.0; // tHZ    ns    Data-out high Z window from CK/CK#"
                puts $mddrp_modi "    parameter tHZ2_max         =     6.5; // tHZ    ns    Data-out high Z window from CK/CK#"
                puts $mddrp_modi "    parameter tRAS             =    40.0; // tRAS   ns    Active to Precharge command time"
                puts $mddrp_modi "    parameter tRC              =    55.0; // tRC    ns    Active to Active/Auto Refresh command time"
                puts $mddrp_modi "    parameter tRCD             =    15.0; // tRCD   ns    Active to Read/Write command time"
                puts $mddrp_modi "    parameter tRP              =    15.0; // tRP    ns    Precharge command period"
                puts $mddrp_modi "    parameter tRRD             =    10.0; // tRRD   ns    Active bank a to Active bank b command time"
                puts $mddrp_modi "    parameter tWTR             =     2.0; // tWTR  tCK    Internal Write-to-Read command delay"
                puts $mddrp_modi "    parameter tXP              =    10.0; // tXP    ns    Exit power-down to first valid cmd *note: In data sheet this is specified as one clk, but min tck fails before tXP on the actual part"
                puts $mddrp_modi "`else `ifdef sg54                         //              Timing Parameters for -6 (CL = 3)"
                puts $mddrp_modi "    parameter tAC3_max         =     5.0; // tAC    ns    Access window of DQ from CK/CK#"
                puts $mddrp_modi "    parameter tAC2_max         =     6.5; // tAC    ns    Access window of DQ from CK/CK#"
                puts $mddrp_modi "    parameter tCK              =     5.4; // tCK    ns    Nominal Clock Cycle Time"
                puts $mddrp_modi "    parameter tCK3_min         =     5.4; // tCK    ns    Nominal Clock Cycle Time"
                puts $mddrp_modi "    parameter tCK2_min         =    12.0; // tCK    ns    Nominal Clock Cycle Time"
                puts $mddrp_modi "    parameter tDQSQ            =    0.45; // tDQSQ  ns    DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $mddrp_modi "    parameter tHZ3_max         =     5.0; // tHZ    ns    Data-out high Z window from CK/CK#"
                puts $mddrp_modi "    parameter tHZ2_max         =     6.5; // tHZ    ns    Data-out high Z window from CK/CK#"
                puts $mddrp_modi "    parameter tRAS             =    42.0; // tRAS   ns    Active to Precharge command time"
                puts $mddrp_modi "    parameter tRC              =    59.4; // tRC    ns    Active to Active/Auto Refresh command time"
                puts $mddrp_modi "    parameter tRCD             =    16.2; // tRCD   ns    Active to Read/Write command time"
                puts $mddrp_modi "    parameter tRP              =    16.2; // tRP    ns    Precharge command period"
                puts $mddrp_modi "    parameter tRRD             =    10.8; // tRRD   ns    Active bank a to Active bank b command time"
                puts $mddrp_modi "    parameter tWTR             =     2.0; // tWTR  tCK    Internal Write-to-Read command delay"
                puts $mddrp_modi "    parameter tXP              =    10.8; // tXP    ns    Exit power-down to first valid cmd *note: In data sheet this is specified as one clk, but min tck fails before tXP on the actual part"
                puts $mddrp_modi "`else `ifdef sg6                          //              Timing Parameters for -6 (CL = 3)"
                set endifs_required [expr $endifs_required + 2]

	    # all versions are missing sg10

	    } elseif {[regexp {sg75} $line]} {
	        puts $mddrp_modi "`else `ifdef sg10"
	        puts $mddrp_modi "    parameter tAC3_max         =     6.0; // tAC    ns    Access window of DQ from CK/CK#"
	        puts $mddrp_modi "    parameter tAC2_max         =     6.5; // tAC    ns    Access window of DQ from CK/CK#"
	        puts $mddrp_modi "    parameter tCK              =    10.0; // tCK    ns    Nominal Clock Cycle Time"
	        puts $mddrp_modi "    parameter tCK3_min         =    10.0; // tCK    ns    Nominal Clock Cycle Time"
	        puts $mddrp_modi "    parameter tCK2_min         =    12.0; // tCK    ns    Nominal Clock Cycle Time"
	        puts $mddrp_modi "    parameter tDQSQ            =    0.70; // tDQSQ  ns    DQS-DQ skew, DQS to last DQ valid, per group, per access"
	        puts $mddrp_modi "    parameter tHZ3_max         =     6.0; // tHZ    ns    Data-out high Z window from CK/CK#"
	        puts $mddrp_modi "    parameter tHZ2_max         =     6.5; // tHZ    ns    Data-out high Z window from CK/CK#"
	        puts $mddrp_modi "    parameter tRAS             =    50.0; // tRAS   ns    Active to Precharge command time"
	        puts $mddrp_modi "    parameter tRC              =    80.0; // tRC    ns    Active to Active/Auto Refresh command time"
	        puts $mddrp_modi "    parameter tRCD             =    30.0; // tRCD   ns    Active to Read/Write command time"
	        puts $mddrp_modi "    parameter tRP              =    30.0; // tRP    ns    Precharge command period"
	        puts $mddrp_modi "    parameter tRRD             =    15.0; // tRRD   ns    Active bank a to Active bank b command time"
	        puts $mddrp_modi "    parameter tWTR             =     1.0; // tWTR  tCK    Internal Write-to-Read command delay"
	        puts $mddrp_modi "    parameter tXP              =    10.0; // tXP    ns    Exit power-down to first valid cmd Note: spec'd as 2 * tCK"
	        puts $mddrp_modi $line
                set endifs_required [expr $endifs_required + 1]
                set in_sg75 1
	    
	    } elseif {[regexp {parameter tAC2_min} $line]} {
                for {set i 0} { $i < $endifs_required} {incr i} {
                    puts $mddrp_modi "`endif"
                }
	        puts $mddrp_modi $line
	  
            # Some versions have tWR defined within the "ifdef sg*"; others just at the end.  Clean this up by removing them all and just putting at
            # the end.  Otherwise, the addition of timing versions (above) will be inconsistent
            } elseif {[regexp {tWR} $line] } {
                # Don't write line containing tWR
            } elseif {[regexp {tSRR} $line] } {
                puts $mddrp_modi "     parameter tWR              =    15.0; // tWR    ns    Write recovery time"
                puts $mddrp_modi $line
        
            # For sg75, some versions have incorrect value of tRC.  Should be 67.5ns
            } elseif {[regexp {parameter tRC\s*=\s*(\d+\.\d+)} $line -> trc] && $in_sg75} {
                regsub $trc $line {67.5} line
                puts $mddrp_modi $line
                set in_sg75 0
	    
            # Need different TRFC depending on device density
            } elseif {[regexp {parameter tRFC\s*=\s*(\d+\.\d+)} $line -> trfc_min]} {
                puts $mddrp_modi "`ifdef den64Mb"; 
                regsub $trfc_min $line 80 line_new
                puts $mddrp_modi $line_new
	    
	        puts $mddrp_modi "`elsif den128Mb"; 
                regsub $trfc_min $line 80 line_new
                puts $mddrp_modi $line_new
    
                puts $mddrp_modi "`elsif den256Mb"
                regsub $trfc_min $line 80 line_new
                puts $mddrp_modi $line_new
    
                puts $mddrp_modi "`elsif den512Mb"
                regsub $trfc_min $line 110 line_new
                puts $mddrp_modi $line_new
            
                puts $mddrp_modi "`elsif den1024Mb"
                regsub $trfc_min $line 140 line_new
                puts $mddrp_modi $line_new
            
                puts $mddrp_modi "`elsif den2048Mb"
                regsub $trfc_min $line 140 line_new
                puts $mddrp_modi $line_new
            
                puts $mddrp_modi "`endif"

	    
            } else {
                puts $mddrp_modi $line
            }
        }
        close $mddrp_modi
        close $mddrp_orig
    }
}

#########################################################################
# mobile_ddr2.v
if {($tc_ddr_mode == "LPDDR2") || ($tc_ddr_mode == "ALL")} {
    if {[file exists $source_dir/mobile_ddr2.v]} {

        if {[file exists $dest_dir/mobile_ddr2.v]} { file delete $dest_dir/mobile_ddr2.v}
        set mddr2_orig [open $source_dir/mobile_ddr2.v r]
        set mddr2_modi [open $dest_dir/mobile_ddr2.v a]
        
        #initial begin flag
        set initial_flag 0
        #delay code flag
        set delay_code_flag 0
        #replace signals names, flag
        set r_sig 0
        while {[gets $mddr2_orig line] >=0} {
            # Change tINIT3 violations from error to warning to allow shorter initialization times in simulation
            if { [regexp {tINIT3 violation} $line] } {
                regsub {ERROR} $line {WARN} line
                puts $mddr2_modi $line
            # Replace mcd_info wire with a parameter (defined in mobile_ddr2_parameters.vh)
            } elseif {[regexp {integer\s+mcd_info} $line]} {
                puts $mddr2_modi $line 
            } elseif {[regexp {mcd_info = 0} $line]} {
	        # Cause false fire - need to replace with the actual value (the x in NOP_CMD definition causes problem)
                puts $mddr2_modi $line 
            } elseif {[regexp {cmd \!\=\= NOP_CMD} $line]} {
                regsub {cmd \!\=\= NOP_CMD} $line {cmd[4:1] !== 4'b1111} line
                puts $mddr2_modi $line
            # Temp. derating: initialize mr[4] to 8'h83, and don't allow it to be written by MRW.  Can be driven directly from tests
            } elseif { [regexp {parameter MRRBIT = 1'b0;} $line] } {        
                puts $mddr2_modi $line
                puts $mddr2_modi " "
                puts $mddr2_modi "    // Added to simulate board delays"
                puts $mddr2_modi "    real  cmd_dly;    // command board delay"
                puts $mddr2_modi "    real  wr_dly;     // write board delay"
                puts $mddr2_modi "    real  rd_dly;     // read board delay"
                puts $mddr2_modi "    real  ck_dly;     // extra write delay on CK/CK#"
                puts $mddr2_modi "    real  qs_dly;     // extra read delay on strobes"
                puts $mddr2_modi "    real  dqs_dly;    // extra read delay on DQS strobe"
                puts $mddr2_modi "    real  dqs_b_dly;  // extra read delay on DQS# strobe"
                puts $mddr2_modi " "
                puts $mddr2_modi "    //  Added flags to disable certain checks."
                puts $mddr2_modi "    reg  check_clocks;"
                puts $mddr2_modi "    reg  check_dq_setup_hold;"
                puts $mddr2_modi "    reg  check_dq_pulse_width;"
                puts $mddr2_modi "    reg  check_rfc_max;"
                puts $mddr2_modi " "
                puts $mddr2_modi "    `ifdef OVRD_TDQSCK"
                puts $mddr2_modi "    real  rnd_tdqsck;  // extra read delay on DQS# strobe"
                puts $mddr2_modi "    `endif"
            #initialize the board delays
             } elseif { [regexp {initial begin} $line]  && ($initial_flag == 0)} { 
                puts $mddr2_modi $line
                puts $mddr2_modi " "
                puts $mddr2_modi "    wr_dly    = 0.0;"
                puts $mddr2_modi "    rd_dly    = 0.0;"
                puts $mddr2_modi "    ck_dly    = 0.0;"
                puts $mddr2_modi "    qs_dly    = 0.0;"
                puts $mddr2_modi "    dqs_dly   = 0.0;"
                puts $mddr2_modi "    dqs_b_dly = 0.0;"
                puts $mddr2_modi " "
                puts $mddr2_modi "    check_clocks                  = 1'b1;"
                puts $mddr2_modi "    check_dq_setup_hold           = 1'b1;"
                puts $mddr2_modi "    check_rfc_max                 = 1'b1;" 
                puts $mddr2_modi " "                
                puts $mddr2_modi "    `ifdef OVRD_TDQSCK"
                puts $mddr2_modi "    `ifdef TDQSCK_VALUE"
                puts $mddr2_modi "      // tDQSCK value passed in thru command line, use this"
                puts $mddr2_modi "      rnd_tdqsck = `TDQSCK_VALUE;"
                puts $mddr2_modi "    `else"
                puts $mddr2_modi "      // create a randmoized tDQSCK"
                puts $mddr2_modi "      rnd_tdqsck = \$random%\(TDQSCK_MAX-TDQSCK\);"
                puts $mddr2_modi "      if (rnd_tdqsck < 0)"
                puts $mddr2_modi "        rnd_tdqsck = -rnd_tdqsck;"
                puts $mddr2_modi "      rnd_tdqsck = TDQSCK+rnd_tdqsck; "
                puts $mddr2_modi "    `endif"
                puts $mddr2_modi "     \$display\(\"\[MOBILE_DDR2\] rnd_tdqsck = %0d\", rnd_tdqsck\);"
                puts $mddr2_modi "    `endif"
                puts $mddr2_modi " "
                set initial_flag 1
                set delay_code_flag 1
            #add board delay and extra always code
            } elseif { [regexp {task chk_err} $line] && ($delay_code_flag == 1) } {        
                set delay_code_flag 0
                #delays
                puts $mddr2_modi " "
                puts $mddr2_modi "    always @(ck   ) ck_in       <= #(wr_dly) ck   ;"
                puts $mddr2_modi "    always @(ck_n ) ck_n_in     <= #(wr_dly) ck_n ;"
                puts $mddr2_modi "    always @(cke  ) cke_in      <= #(wr_dly) cke  ;"
                puts $mddr2_modi "    always @(cs_n ) cs_n_in     <= #(wr_dly) cs_n ;"
                puts $mddr2_modi "    always @(ca   ) ca_in       <= #(wr_dly) ca   ;"
                puts $mddr2_modi "    always @(dm   ) dm_wr_in    <= #(wr_dly) dm   ;"
                puts $mddr2_modi "    always @(dq   ) dq_wr_in    <= #(wr_dly) dq   ;"
                puts $mddr2_modi "    always @(dqs  ) dqs_wr_in   <= #(wr_dly) dqs  ;"
                puts $mddr2_modi "    always @(dqs_n) dqs_n_wr_in <= #(wr_dly) dqs_n;"
                puts $mddr2_modi " "
                puts $mddr2_modi $line
                #add new signal variables
            } elseif { [regexp {// clock} $line] } {        
                puts $mddr2_modi "    reg                       ck_in;"
                puts $mddr2_modi "    reg                       ck_n_in;"
                puts $mddr2_modi "    reg                       cke_in;"
                puts $mddr2_modi "    reg                       cs_n_in;"
                puts $mddr2_modi "    reg     \[CA_BITS-1:0\]   ca_in;"
                puts $mddr2_modi "    reg     \[DM_BITS-1:0\]   dm_wr_in;"
                puts $mddr2_modi "    reg     \[DQ_BITS-1:0\]   dq_wr_in;"
                puts $mddr2_modi "    reg     \[DQS_BITS-1:0\]  dqs_wr_in;"
                puts $mddr2_modi "    reg     \[DQS_BITS-1:0\]  dqs_n_wr_in;"
                puts $mddr2_modi "    // transmit"
                puts $mddr2_modi "    reg                       dqs_out_en_bd;"
                puts $mddr2_modi "    reg                       dqs_out_bd;"
                puts $mddr2_modi "    reg                       dq_out_en_bd;"
                puts $mddr2_modi "    reg      \[DQ_BITS-1:0\]   dq_out_bd;"
                puts $mddr2_modi " "
                puts $mddr2_modi "    // clock"
                set r_sig 1 
            } elseif { [regexp {bufif1} $line] } {
                gets $mddr2_orig line
                gets $mddr2_orig line
                puts $mddr2_modi "    always @\(dqs_out_en\) dqs_out_en_bd <= #\(rd_dly\) dqs_out_en;"
                puts $mddr2_modi "    always @\(dqs_out\)    dqs_out_bd    <= #\(rd_dly\) dqs_out;"
                puts $mddr2_modi "    always @\(dq_out_en\)  dq_out_en_bd  <= #\(rd_dly\) dq_out_en;"
                puts $mddr2_modi "    always @\(dq_out\)     dq_out_bd     <= #\(rd_dly\) dq_out;"
                puts $mddr2_modi ""
                puts $mddr2_modi "    bufif1 buf_dqs    \[DQS_BITS-1:0\] \(dqs,    \{DQS_BITS\{dqs_out_bd\}\}, dqs_out_en_bd\);"
                puts $mddr2_modi "    bufif1 buf_dqs_n  \[DQS_BITS-1:0\] \(dqs_n, \{DQS_BITS\{~dqs_out_bd\}\}, dqs_out_en_bd\);"
                puts $mddr2_modi "    bufif1 buf_dq      \[DQ_BITS-1:0\] \(dq,                  dq_out_bd,  dq_out_en_bd\);"
            } elseif { [regexp {// rx} $line] } {
                puts $mddr2_modi $line
                puts $mddr2_modi "    wire                  \[7:0\] dm_in = dm_wr_in;"
                puts $mddr2_modi "    wire                 \[63:0\] dq_in = dq_wr_in;"
            } elseif { [regexp {dqs_out_en <=} $line] } {
                for { set i 1 } { $i <= 4 } { incr i } {
                    gets $mddr2_orig line
                }
                puts $mddr2_modi "          `ifdef OVRD_TDQSCK"
                puts $mddr2_modi "            dqs_out_en <= #\(rnd_tdqsck\) \(|rd_pipeline\[1:0\]\);"
                puts $mddr2_modi "            dq_out_en  <= #\(rnd_tdqsck\) \(rd_pipeline\[0\]\);"
                puts $mddr2_modi "          `else"
                puts $mddr2_modi "            dqs_out_en <= #\(TDQSCK\) \(|rd_pipeline\[1:0\]\);"
                puts $mddr2_modi "            dq_out_en  <= #\(TDQSCK\) \(rd_pipeline\[0\]\);"
                puts $mddr2_modi "          `endif"
                puts $mddr2_modi "        end"
                puts $mddr2_modi "          `ifdef OVRD_TDQSCK"
                puts $mddr2_modi "              dqs_out <= #\(rnd_tdqsck\) rd_pipeline\[0\] && diff_ck;"
                puts $mddr2_modi "              dq_out  <= #\(rnd_tdqsck\) dq_temp;"
                puts $mddr2_modi "          `else"
                puts $mddr2_modi "              dqs_out <= #\(TDQSCK\) rd_pipeline\[0\] && diff_ck;"
                puts $mddr2_modi "              dq_out  <= #\(TDQSCK\) dq_temp;"
                puts $mddr2_modi "          `endif"
            #cke
            } elseif {[regexp {wire 			cke_in = cke;} $line]  && ($r_sig == 1)} {
            #dm 
            } elseif {[regexp {\[7:0\] dm_in = dm;} $line]  && ($r_sig == 1)} {
            #dq
            } elseif {[regexp {\[63:0\] dq_in = dq;} $line]  && ($r_sig == 1)} {
            #dqs
            } elseif {[regexp {dqs_even = dqs} $line]  && ($r_sig == 1)} {
                regsub {dqs_even = dqs} $line {dqs_even = dqs_wr_in} line
                puts $mddr2_modi $line
            #dqs_n
            } elseif {[regexp {dqs_odd = dqs_n} $line]  && ($r_sig == 1)} {
                regsub {dqs_n} $line {dqs_n_wr_in} line
                puts $mddr2_modi $line
            } elseif {[regexp {\$fdisplay\(mcd_error} $line] } {
                puts $mddr2_modi "            \$fdisplay\(mcd_error, \"\%m at time \%t ERROR: \%0s\", \$time, msg\);"
            } elseif {[regexp {\$fdisplay\(mcd_warn} $line] } {
                puts $mddr2_modi "            \$fdisplay\(mcd_warn, \"\%m at time \%t WARNING: \%0s\", \$time, msg\);"
            } else {
                puts $mddr2_modi $line
            }
        }
        close $mddr2_modi
        close $mddr2_orig
    }

#########################################################################
# mobile_ddr2_parameters.vh
    if {[file exists $source_dir/mobile_ddr2_parameters.vh]} {

        if {[file exists $dest_dir/mobile_ddr2_parameters.vh]} { file delete $dest_dir/mobile_ddr2_parameters.vh}
        set mddr2p_orig [open $source_dir/mobile_ddr2_parameters.vh r]
        set mddr2p_modi [open $dest_dir/mobile_ddr2_parameters.vh a]
        while {[gets $mddr2p_orig line] >=0} {
            # Remove define lpddr2_4Gb from start of file - these are defined in ddr2_mdefines.v
            if {[regexp {define lpddr2_4Gb} $line]} {
            } elseif {[regexp {\`ifdef sg25} $line]} {
                puts $mddr2p_modi $line
            } elseif {[regexp {parameter XP\s*=\s*(\d+)} $line -> xp]} {
	            regsub $xp $line 2 line
                puts $mddr2p_modi $line
            # Need different TRFCAB depending on device density
	        } elseif {[regexp {parameter TRFCAB\s*=\s*(\d+)} $line -> trfcab]} {
	            puts $mddr2p_modi "`ifdef lpddr2_8Gb"
	            regsub $trfcab $line 210000 line_new
                puts $mddr2p_modi $line_new

	            puts $mddr2p_modi "`elsif lpddr2_4Gb"
                regsub $trfcab $line 130000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif lpddr2_2Gb"
                regsub $trfcab $line 130000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif lpddr2_1Gb"
                regsub $trfcab $line 130000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`else"
                regsub $trfcab $line 90000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`endif"
                puts $mddr2p_modi "    parameter TXSR		 =	TRFCAB + 10000;"

	            # Need to modify definition of TXRS to make it dependent on TRFCAB
	            # done above so remove subsequent defination
	        } elseif {[regexp {parameter TXSR\s*=\s*(\d+)} $line]} {
	        } elseif {[regexp {parameter TREFBW\s*=\s*(\d+)} $line -> trfbw]} {

	        puts $mddr2p_modi "`ifdef lpddr2_8Gb"
                regsub $trfbw $line 6720000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif lpddr2_4Gb"
                regsub $trfbw $line 4160000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif lpddr2_2Gb"
                regsub $trfbw $line 4160000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif lpddr2_1Gb"
                regsub $trfbw $line 4160000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`else"
                regsub $trfbw $line 2880000 line_new
                puts $mddr2p_modi $line_new 	   

                puts $mddr2p_modi "`endif"

            } elseif {[regexp {parameter TRPPB\s*=\s*(\d+)} $line -> trppb]} {

	    	    puts $mddr2p_modi "`ifdef LPDDR2_FAST"
            	regsub $trppb $line 15000 line_new
            	puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif LPDDR2_TYP"
                regsub $trppb $line 18000 line_new
                puts $mddr2p_modi $line_new

            	puts $mddr2p_modi "`elsif LPDDR2_SLOW"
            	regsub $trppb $line 24000 line_new
            	puts $mddr2p_modi $line_new

	    	    puts $mddr2p_modi "`endif"

	    	    puts $mddr2p_modi "`ifdef baw3"
            	puts $mddr2p_modi "    parameter TRPAB  	   =	  TRPPB + 3000;"
	    	    puts $mddr2p_modi "`else"
	    	    puts $mddr2p_modi "    parameter TRPAB  	   =	  TRPPB;"
            	puts $mddr2p_modi "`endif"

	       # TRPAB defined above   
	       } elseif {[regexp {parameter TRPAB\s*=\s*(\d+)} $line]} {

	       # fast process selected at slower speed grade LPDDR2-400 so decrease clock cycles   
	       } elseif {[regexp {parameter RPAB\s*=\s*(\d+)} $line]} {
 
                puts $mddr2p_modi "`ifdef LPDDR2_FAST"
                puts $mddr2p_modi "    parameter RPAB		  =	 3;"
                puts $mddr2p_modi "`else"
                puts $mddr2p_modi "    parameter RPAB		  =	 4;"
                puts $mddr2p_modi "`endif"

            } elseif {[regexp {parameter TRCD\s*=\s*(\d+)} $line -> trcd]} {

                puts $mddr2p_modi "`ifdef LPDDR2_FAST"
                regsub $trcd $line 15000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif LPDDR2_TYP"
                regsub $trcd $line 18000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`elsif LPDDR2_SLOW"
                regsub $trcd $line 24000 line_new
                puts $mddr2p_modi $line_new

                puts $mddr2p_modi "`endif"

	        } elseif {[regexp {// Simulation parameters} $line]} {
                puts $mddr2_modi $line
                puts $mddr2_modi "parameter BUS_DELAY        =       0; // delay in picoseconds"
            } elseif {[regexp {parameter STOP_ON_ERROR} $line]} {
                puts $mddr2_modi "    parameter STOP_ON_ERROR     =          0; // If set to 1, the model will halt on errors"
            } else {
             	puts $mddr2p_modi $line
            }
        }

        close $mddr2p_modi
        close $mddr2p_orig
    }
}

#source [get_logical_dir bin]/modify_micron_models_lpddr3.tcl
#########################################################################
# mobile_ddr3.v
if {($tc_ddr_mode == "LPDDR3") || ($tc_ddr_mode == "ALL")} {
    if {[file exists $source_dir/mobile_ddr3.v]} {
        if {[file exists $dest_dir/mobile_ddr3.v]} { file delete $dest_dir/mobile_ddr3.v}
        set mddr3_orig [open $source_dir/mobile_ddr3.v r]
        set mddr3_modi [open $dest_dir/mobile_ddr3.v a]
        
	#puts $mddr3_modi "`define LPDDR3_TYP"
        while {[gets $mddr3_orig line] >=0} {
            # Change tINIT3, tINIT4, tINIT5 and tZQINIT violations from error to warning to allow shorter initialization times in simulation
            if { [regexp {tINIT(3|4|5) violation} $line] } {
                regsub {ERROR} $line {WARN} line
                puts $mddr3_modi $line
	    } elseif { [regexp {tZQINIT violation} $line] } {
                regsub {ERROR} $line {WARN} line
                puts $mddr3_modi $line	     
	    
        # Replace mcd_info wire with a parameter (defined in mobile_ddr3_parameters.vh)
        } elseif {[regexp {integer\s+mcd_info} $line]} {
	    
	    } elseif {[regexp {mcd_info = 0} $line]} {
	
	    } elseif {[regexp {reg \[3:0\] 				nwr} $line]} {
                regsub {3:0} $line {4:0} line
                puts $mddr3_modi $line
        } elseif { [regexp {mr\[4\]} $line] } {
                regsub {8'hxx} $line {8'h03} line
                puts $mddr3_modi $line
	       
            # Check for tREFBW is incorrect - only triggers on 10th refresh within tREFBW window
            } elseif {[regexp {if \(j > 8\)} $line]} {
                regsub {8} $line {7} line
                puts $mddr3_modi $line
            } else {
                puts $mddr3_modi $line
            }
        }
	
        close $mddr3_modi
        close $mddr3_orig
    }
    
    if {[file exists $dest_dir/mobile_ddr3_tmp.v]} { file delete $dest_dir/mobile_ddr3_tmp.v}
    set mddr3_orig [open $dest_dir/mobile_ddr3.v r]
    set mddr3_modi  [open $dest_dir/mobile_ddr3_tmp.v w+]
    #set mddr3_modi [open $dest_dir/mobile_ddr3.v w]
    
    #code being read is inside mobile_ddr3 module
    set lpddr3_flag 1    
    #initial begin flag
    set initial_flag 0
    #delay code flag
    set delay_code_flag 0
    #replace signals names, flag
    set r_sig 0
    
    while {[gets $mddr3_orig line] >=0} {
        #code inside mobile_ddr3 module
        if { [regexp {module mobile_ddr3 } $line] } {        
            puts $mddr3_modi $line
            set lpddr3_flag 1 
        #do not analyse code outside mobile_ddr3 module
        } elseif { $lpddr3_flag == 0 } {        
            puts $mddr3_modi $line            
        } elseif { $lpddr3_flag == 1 && [regexp {endmodule} $line] } {        
            puts $mddr3_modi $line
            set lpddr3_flag 0 
        #Add variables to simulate board delays
        } elseif { [regexp {parameter MRRBIT = 1'b0;} $line] } {        
            puts $mddr3_modi $line
            puts $mddr3_modi " "
            puts $mddr3_modi "    // Added to simulate board delays"
            puts $mddr3_modi "    real  cmd_dly;    // command board delay"
            puts $mddr3_modi "    real  wr_dly;     // write board delay"
            puts $mddr3_modi "    real  rd_dly;     // read board delay"
            puts $mddr3_modi "    real  ck_dly;     // extra write delay on CK/CK#"
            puts $mddr3_modi "    real  qs_dly;     // extra read delay on strobes"
            puts $mddr3_modi "    real  dqs_dly;    // extra read delay on DQS strobe"
            puts $mddr3_modi "    real  dqs_b_dly;  // extra read delay on DQS# strobe"
            puts $mddr3_modi " "
            puts $mddr3_modi "    `ifdef OVRD_TDQSCK"
            puts $mddr3_modi "    real  rnd_tdqsck;  // extra read delay on DQS# strobe"
            puts $mddr3_modi "    `endif"
        #initialize the board delays
         } elseif { [regexp {initial begin} $line]  && ($initial_flag == 0)} { 
            puts $mddr3_modi $line
            puts $mddr3_modi " "
            puts $mddr3_modi "    dqs_out_en_dly   = 0;"
            puts $mddr3_modi "    dq_out_en_dly   = 0;"
            puts $mddr3_modi "    dqs_out_ca_en_dly   = 0;"
            puts $mddr3_modi "    cmd_dly   = 0.0;"
            puts $mddr3_modi "    wr_dly    = 0.0;"
            puts $mddr3_modi "    rd_dly    = 0.0;"
            puts $mddr3_modi "    ck_dly    = 0.0;"
            puts $mddr3_modi "    qs_dly    = 0.0;"
            puts $mddr3_modi "    dqs_dly   = 0.0;"
            puts $mddr3_modi "    dqs_b_dly = 0.0;"
            puts $mddr3_modi " "
            puts $mddr3_modi "    `ifdef OVRD_TDQSCK"
            puts $mddr3_modi "    `ifdef TDQSCK_VALUE"
            puts $mddr3_modi "      // tDQSCK value passed in thru command line, use this"
            puts $mddr3_modi "      rnd_tdqsck = `TDQSCK_VALUE;"
            puts $mddr3_modi "    `else"
            puts $mddr3_modi "      // create a randmoized tDQSCK"
            puts $mddr3_modi "      rnd_tdqsck = \$random%\(TDQSCK_MAX-TDQSCK\);"
            puts $mddr3_modi "      if (rnd_tdqsck < 0)"
            puts $mddr3_modi "        rnd_tdqsck = -rnd_tdqsck;"
            puts $mddr3_modi "      rnd_tdqsck = TDQSCK+rnd_tdqsck; "
            puts $mddr3_modi "    `endif"
            puts $mddr3_modi "     \$display\(\"\[MOBILE_DDR3\] rnd_tdqsck = %0d\", rnd_tdqsck\);"
            puts $mddr3_modi "    `endif"
            puts $mddr3_modi " "
            set initial_flag 1
            set delay_code_flag 1
        #add board delay and extra always code
        } elseif { [regexp {end} $line] && ($delay_code_flag == 1) } {        
            set delay_code_flag 0
            puts $mddr3_modi $line
            #delays
            puts $mddr3_modi " "
            puts $mddr3_modi "    //Fly-by CA board delay"
            puts $mddr3_modi "    always @\(ck     \) ck_in     <= #\(BUS_DELAY+cmd_dly\) ck;"
            puts $mddr3_modi "    always @\(ck_n   \) ck_n_in   <= #\(BUS_DELAY+cmd_dly\) ck_n;"
            puts $mddr3_modi "    always @\(cke    \) cke_in    <= #\(BUS_DELAY+cmd_dly\) cke;"
            puts $mddr3_modi "    always @\(cs_n   \) cs_n_in   <= #\(BUS_DELAY+cmd_dly\) cs_n;"
            puts $mddr3_modi "    always @\(ca     \) ca_in     <= #\(BUS_DELAY+cmd_dly\) ca;"
            puts $mddr3_modi "    //always @\(odt    \) if \(!feature_odt_hi\) odt_in    <= #\(BUS_DELAY+cmd_dly\) odt;"
            puts $mddr3_modi "    always @\(odt    \) odt_in    <= #\(BUS_DELAY+cmd_dly) odt;"
            puts $mddr3_modi "    //Write data lanes board delay"
            puts $mddr3_modi "    always @\(dm     \) dm_in     <= #\(BUS_DELAY+wr_dly\) dm;"
            puts $mddr3_modi "    always @\(dq     \) dq_in     <= #\(BUS_DELAY+wr_dly\) dq;"
            puts $mddr3_modi "    always @\(dqs    \) dqs_in    <= #\(BUS_DELAY+wr_dly\) dqs;"
            puts $mddr3_modi "    always @\(dqs_n  \) dqs_n_in  <= #\(BUS_DELAY+wr_dly\) dqs_n;"
            puts $mddr3_modi "    //Read data lanes board delay"
            puts $mddr3_modi "    always @\(dqs_out_en\) dqs_out_en_dly <= #\(rd_dly+qs_dly\) dqs_out_en;"
            puts $mddr3_modi "    always @\(dqs_out\)    dqs_out_dly    <= #\(rd_dly+qs_dly\) dqs_out;"
            puts $mddr3_modi "    always @\(dq_out_en\)  dq_out_en_dly  <= #\(rd_dly\) dq_out_en;"
            puts $mddr3_modi "    always @\(dq_out\)     dq_out_dly     <= #\(rd_dly\) dq_out;"
            puts $mddr3_modi " "
            puts $mddr3_modi "    always @\(dqs_out_ca_en\) dqs_out_ca_en_dly <= #\(rd_dly+qs_dly\) dqs_out_ca_en;"
            puts $mddr3_modi "    always @\(dqs_out_ca\)    dqs_out_ca_dly    <= #\(rd_dly+qs_dly\) dqs_out_ca;"
            puts $mddr3_modi "    always @\(dqs_out_ca_n\)    dqs_out_ca_n_dly    <= #\(rd_dly+qs_dly\) dqs_out_ca_n;"            
        #add new signal variables
        } elseif { [regexp {// clock} $line] } {        
            puts $mddr3_modi "    // delayed signals"
            puts $mddr3_modi "    // receive"
            puts $mddr3_modi "    reg                       ck_in;"
            puts $mddr3_modi "    reg                       ck_n_in;"
            puts $mddr3_modi "    reg                       cke_in;"
            puts $mddr3_modi "    reg                       cs_n_in;"
            puts $mddr3_modi "    reg     \[CA_BITS-1:0\]     ca_in;"
            puts $mddr3_modi "    reg     \[DM_BITS-1:0\]     dm_in;"
            puts $mddr3_modi "    reg     \[DQ_BITS-1:0\]     dq_in;"
            puts $mddr3_modi "    reg     \[DQS_BITS-1:0\]    dqs_in;"
            puts $mddr3_modi "    reg     \[DQS_BITS-1:0\]    dqs_n_in;"
            puts $mddr3_modi "    reg                         odt_in;"
            puts $mddr3_modi "    // transmit"
            puts $mddr3_modi "    reg                       dqs_out_en_dly;"
            puts $mddr3_modi "    reg                       dqs_out_dly;"
            puts $mddr3_modi "    reg                       dq_out_en_dly;"
            puts $mddr3_modi "    reg      \[DQ_BITS-1:0\]   dq_out_dly;"
            puts $mddr3_modi "    reg                       dqs_out_ca_en_dly;"
            puts $mddr3_modi "    reg      \[DQS_BITS-1:0\]   dqs_out_ca_dly;"
            puts $mddr3_modi "    reg      \[DQS_BITS-1:0\]   dqs_out_ca_n_dly;"
            puts $mddr3_modi " "
            puts $mddr3_modi "    // clock"
            set r_sig 1            
        #replace signals names 
        #multiple replacement
        } elseif {[regexp {cke, \~cs_n \? \{ca\[0\], ca\[1\], ca\[2\], ca\[3\]\}} $line]  && ($r_sig == 1)} {
            regsub {cke, \~cs_n \? \{ca\[0\], ca\[1\], ca\[2\], ca\[3\]\}} $line {cke_in, ~cs_n_in ? {ca_in[0], ca_in[1], ca_in[2], ca_in[3]}} line
            puts $mddr3_modi $line
        #ck
        } elseif {[regexp {always @\(posedge ck\)        diff_ck <= ck;} $line]  && ($r_sig == 1)} {
            regsub {always @\(posedge ck\)        diff_ck <= ck;} $line {always @(posedge ck_in)        diff_ck <= ck_in;} line
            puts $mddr3_modi $line        
        } elseif {[regexp {odt_rd_dis \<= #\(TDQSCK-300} $line]} {
            puts $mddr3_modi "         `ifdef OVRD_TDQSCK"
            puts $mddr3_modi "              odt_rd_dis <= #\(rnd_tdqsck-300\) \(|\{rd_pipeline\[2:0\],rd_pipeline_prevbit0\}\);"
            puts $mddr3_modi "              dqs_out_en <= #\(rnd_tdqsck\) \(|rd_pipeline\[1:0\]\);"
            puts $mddr3_modi "              dq_out_en <= #\(rnd_tdqsck\) \(rd_pipeline\[0\]\); "
            puts $mddr3_modi "         `else"
            puts $mddr3_modi $line     
        } elseif {[regexp {rd_pipeline_prevbit0 = rd_pipeline\[0\];} $line]} {
            puts $mddr3_modi "         `endif"
            puts $mddr3_modi $line     
        } elseif {[regexp {dqs_out \<= #\(TDQSCK\) rd_pipeline\[0\] && diff_ck;} $line]} {
            puts $mddr3_modi "         `ifdef OVRD_TDQSCK"
            puts $mddr3_modi "            dqs_out \<= #\(rnd_tdqsck\) rd_pipeline\[0\] && diff_ck;"
            puts $mddr3_modi "            dq_out \<= #\(rnd_tdqsck\) dq_temp;"
            puts $mddr3_modi "         `else"
            puts $mddr3_modi $line        
        } elseif {[regexp {dq_out \<= #\(TDQSCK\) dq_temp;} $line]} {
            puts $mddr3_modi $line        
            puts $mddr3_modi "         `endif"
        } elseif {[regexp {TWLO ck;} $line]  && ($r_sig == 1)} {
            regsub {ck} $line {ck_in} line
            puts $mddr3_modi $line     
        #ck_n
        } elseif {[regexp {always @\(posedge ck_n\)      diff_ck <= \~ck_n;} $line]  && ($r_sig == 1)} {
            regsub {always @\(posedge ck_n\)      diff_ck <= \~ck_n;} $line {always @(posedge ck_n_in)      diff_ck <= ~ck_n_in;} line
            puts $mddr3_modi $line        
        #cke
        } elseif {[regexp {wire 			cke_in = cke;} $line]  && ($r_sig == 1)} {                 
        } elseif {[regexp {cke === 1'bx} $line]  && ($r_sig == 1)} {
            regsub {cke} $line {cke_in} line
            puts $mddr3_modi $line 
        #cs_n
        } elseif {[regexp {cs_n} $line]  && ($r_sig == 1)} {
            regsub -all {cs_n} $line {cs_n_in} line
            puts $mddr3_modi $line     
        #ca
        } elseif {[regexp {ca === 1'bx\) \|\| \(\|ca} $line]  && ($r_sig == 1)} {
            regsub {ca === 1'bx\) \|\| \(\|ca} $line {ca_in === 1'bx) || (|ca_in} line
            puts $mddr3_modi $line     
        } elseif {[regexp {ca\[9:8\], ca_q\[6:2\], ca\[7:0\]} $line]  && ($r_sig == 1)} {
            regsub -all {ca\[9:8\], ca_q\[6:2\], ca\[7:0\]} $line {ca_in[9:8], ca_q[6:2], ca_in[7:0]} line
            puts $mddr3_modi $line   
        } elseif {[regexp { ca\[} $line]  && ($r_sig == 1)} {
            regsub -all { ca\[} $line { ca_in[} line
            puts $mddr3_modi $line               
        } elseif {[regexp {\{ca\[} $line]  && ($r_sig == 1)} {
            regsub -all {ca\[} $line {ca_in[} line
            puts $mddr3_modi $line               
        } elseif {[regexp {\(ca\[} $line]  && ($r_sig == 1)} {
            regsub -all {ca\[} $line {ca_in[} line
            puts $mddr3_modi $line               
        } elseif {[regexp {ca_q \<= ca} $line]  && ($r_sig == 1)} {
            regsub {ca_q \<= ca} $line {ca_q <= ca_in} line
            puts $mddr3_modi $line     
        #dm 
        } elseif {[regexp {\[7:0\] dm_in = dm;} $line]  && ($r_sig == 1)} {
        #dq
        } elseif {[regexp {\[63:0\] dq_in = dq;} $line]  && ($r_sig == 1)} {          
        #dqs
        } elseif {[regexp {dqs_even = dqs} $line]  && ($r_sig == 1)} {
            regsub {dqs_even = dqs} $line {dqs_even = dqs_in} line
            puts $mddr3_modi $line
        #dqs_n
        } elseif {[regexp {dqs_odd = dqs_n} $line]  && ($r_sig == 1)} {
            regsub {dqs_n} $line {dqs_n_in} line
            puts $mddr3_modi $line           
        #odt
        } elseif {[regexp { always @\(odt or} $line]  && ($r_sig == 1)} {
            regsub {odt} $line {odt_in} line
            puts $mddr3_modi $line
        } elseif {[regexp {odt===1'b1} $line]  && ($r_sig == 1)} {
            regsub {odt} $line {odt_in} line
            puts $mddr3_modi $line
        #multiple replacements for outputs
        } elseif {[regexp {\{DQS_BITS\{dqs_out\}\}, dqs_out_en\);} $line]  && ($r_sig == 1)} {
            regsub {\{DQS_BITS\{dqs_out\}\}, dqs_out_en\);} $line {{DQS_BITS{dqs_out_dly}}, dqs_out_en_dly);} line
            puts $mddr3_modi $line
        } elseif {[regexp {\{DQS_BITS\{\~dqs_out\}\}, dqs_out_en\)} $line]  && ($r_sig == 1)} {
            regsub {\{DQS_BITS\{\~dqs_out\}\}, dqs_out_en\)} $line {{DQS_BITS{~dqs_out_dly}}, dqs_out_en_dly)} line
            puts $mddr3_modi $line
        } elseif {[regexp {dq_out,  dq_out_en} $line]  && ($r_sig == 1)} {
            regsub {dq_out,  dq_out_en} $line {dq_out_dly,  dq_out_en_dly} line
            puts $mddr3_modi $line
        } elseif {[regexp {dqs_out_ca, dqs_out_ca_en} $line]  && ($r_sig == 1)} {
            regsub {dqs_out_ca, dqs_out_ca_en} $line {dqs_out_ca_dly, dqs_out_ca_en_dly} line
            puts $mddr3_modi $line        
        } elseif {[regexp {dqs_out_ca_n, dqs_out_ca_en} $line]  && ($r_sig == 1)} {
            regsub {dqs_out_ca_n, dqs_out_ca_en} $line {dqs_out_ca_n_dly, dqs_out_ca_en_dly} line
            puts $mddr3_modi $line     
        } elseif {[regexp {^\s*\{REFAB_CMD.*TRFCAB.*tRFCab violation} $line]} {
            puts $mddr3_modi "            {REFAB_CMD, SREF_CMD } : begin if (check_rfc_max && (\$time - tm_refa < TRFCAB)) ERROR (\"tRFCab violation\")\; end";
        } elseif {[regexp {^\s*\{REFPB_CMD.*tm_ref.*TRFCPB.*tRFCpb violation} $line]} {
            puts $mddr3_modi "            {REFPB_CMD, SREF_CMD } : begin if (check_rfc_max && (\$time - tm_ref < TRFCPB)) ERROR (\"tRFCpb violation\")\; end";
        } elseif {[regexp {^\s*\{REFPB_CMD.*tm_bank_ref.*tRFCpb violation} $line]} {
            puts $mddr3_modi "            {REFPB_CMD, ACT_CMD  } : begin if (check_rfc_max && (\$time - tm_bank_ref\[ba\] < TRFCPB)) ERROR (\"tRFCpb violation\"); if ((ck_cntr - ck_ref < RRD) || (\$time - tm_ref < TRRD)) ERROR (\"tRRD violation\")\; end";
        } elseif {[regexp {\$fdisplay\(mcd_error} $line] } {
            puts $mddr3_modi "            \$fdisplay\(mcd_error, \"\%m at time \%t ERROR: \%0s\", \$time, msg\);"     
        } elseif {[regexp {\$fdisplay\(mcd_warn} $line] } {                                                           
            puts $mddr3_modi "            \$fdisplay\(mcd_warn, \"\%m at time \%t WARNING: \%0s\", \$time, msg\);"    
        #everything else is just copied
        } else {
            puts $mddr3_modi $line
        }
    }    
    close $mddr3_orig
    close $mddr3_modi
    
    if {[file exists $dest_dir/mobile_ddr3.v]} { file delete $dest_dir/mobile_ddr3.v}
    set mddr3_orig  [open $dest_dir/mobile_ddr3_tmp.v r]
    set mddr3_modi [open $dest_dir/mobile_ddr3.v w+]
    while {[gets $mddr3_orig line] >=0} {
        puts $mddr3_modi $line
    }
    close $mddr3_orig
    close $mddr3_modi
    
    if {[file exists $dest_dir/mobile_ddr3_tmp.v]} { file delete $dest_dir/mobile_ddr3_tmp.v}
    set mddr3_orig [open $dest_dir/mobile_ddr3.v r]
    set mddr3_modi  [open $dest_dir/mobile_ddr3_tmp.v w+]
    #set mddr3_modi [open $dest_dir/mobile_ddr3.v w]
    
    #code being read is inside mobile_ddr3 module
    set lpddr3_flag 1    
    #initial begin flag
    set initial_flag 0   
    
    while {[gets $mddr3_orig line] >=0} {
        #code inside mobile_ddr3 module
        if { [regexp {module mobile_ddr3 } $line] } {        
            puts $mddr3_modi $line
            set lpddr3_flag 1 
        #do not analyse code outside mobile_ddr3 module
        } elseif { $lpddr3_flag == 0 } {        
            puts $mddr3_modi $line            
        } elseif { $lpddr3_flag == 1 && [regexp {endmodule} $line] } {        
            puts $mddr3_modi $line
            set lpddr3_flag 0 
        # Adding flags to disable certain checks. These will be used in certain tests that
        # are known to cause memory violations in the model. - CHECK CODE NOT IMPLEMENTED
        } elseif { [regexp {parameter MRRBIT = 1'b0;} $line] } {        
            puts $mddr3_modi $line
            puts $mddr3_modi " "
            puts $mddr3_modi "    //  Added flags to disable certain checks."
            puts $mddr3_modi "    reg  check_clocks;"
            puts $mddr3_modi "    reg  check_dq_setup_hold;"
            puts $mddr3_modi "    reg  check_dq_pulse_width;"
            puts $mddr3_modi "    reg  check_dqs_ck_setup_hold;"
            puts $mddr3_modi "    reg  check_ctrl_addr_pulse_width;"
            puts $mddr3_modi "    reg  check_cmd_addr_timing;"
            puts $mddr3_modi "    reg  check_rfc_max;"
            puts $mddr3_modi " "
        #initialize the board delays
         } elseif { [regexp {initial begin} $line]  && ($initial_flag == 0)} { 
            puts $mddr3_modi $line
            puts $mddr3_modi " "
            puts $mddr3_modi "    check_clocks                  = 1'b1;"
            puts $mddr3_modi "    check_dq_setup_hold           = 1'b1;"
            puts $mddr3_modi "    check_dq_pulse_width          = 1'b1;"
            puts $mddr3_modi "    check_dqs_ck_setup_hold       = 1'b1;"
            puts $mddr3_modi "    check_ctrl_addr_pulse_width   = 1'b1;"
            puts $mddr3_modi "    check_cmd_addr_timing         = 1'b1;"
            puts $mddr3_modi "    check_rfc_max                 = 1'b1;"            
            puts $mddr3_modi " "
            set initial_flag 1                  
        #everything else is just copied
        } else {
            puts $mddr3_modi $line
        }
    }    
    close $mddr3_orig
    close $mddr3_modi
        
    #Save values#######################################
    #files
    if {[file exists $dest_dir/mobile_ddr3.v]} { file delete $dest_dir/mobile_ddr3.v}
    set mddr3_orig  [open $dest_dir/mobile_ddr3_tmp.v r]
    set mddr3_modi [open $dest_dir/mobile_ddr3.v w+]
    while {[gets $mddr3_orig line] >=0} {
        puts $mddr3_modi $line
    }
    close $mddr3_orig
    close $mddr3_modi
    
    if {[file exists $dest_dir/mobile_ddr3_tmp.v]} { file delete $dest_dir/mobile_ddr3_tmp.v}
    

#########################################################################
# mobile_ddr3_parameters.vh
    if {[file exists $source_dir/mobile_ddr3_parameters.vh]} {

      if {[file exists $dest_dir/mobile_ddr3_parameters.vh]} { file delete $dest_dir/mobile_ddr3_parameters.vh}
        set mddr3p_orig [open $source_dir/mobile_ddr3_parameters.vh r]
        set mddr3p_modi [open $dest_dir/mobile_ddr3_parameters.vh a]
        while {[gets $mddr3p_orig line] >=0} {
    
            # Remove define MAX_MEM - use a sparse model, so we don't run out of memory
            if {[regexp {define MAX_MEM} $line]} {
            # Add mcd_info parameter - Add 2 speed grade param definitions: sg3 and sg93
            } elseif {[regexp {\`ifdef sg125} $line]} {
                puts $mddr3p_modi "    parameter mcd_info = 0;"
                puts $mddr3p_modi "`ifdef sg3"
                puts $mddr3p_modi "    parameter TCK_MIN           =       3000; // tCK      ps  Minimum Clock Cycle Time"
                puts $mddr3p_modi "    parameter TDQSQ             =        280; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $mddr3p_modi "    parameter TDS               =        350; // tDS      ps  DQ and DM input setup time relative to DQS"
                puts $mddr3p_modi "    parameter TDH               =        350; // tDH      ps  DQ and DM input hold time relative to DQS"
                puts $mddr3p_modi "    parameter TIS               =        370; // tIS      ps  Input Setup Time"
                puts $mddr3p_modi "    parameter TIH               =        370; // tIH      ps  Input Hold Time"
                puts $mddr3p_modi "    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay"
                puts $mddr3p_modi "`else `ifdef sg93"
                puts $mddr3p_modi "    parameter TCK_MIN           =        938; // tCK      ps  Minimum Clock Cycle Time"
                puts $mddr3p_modi "    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $mddr3p_modi "    parameter TDS               =        150; // tDS      ps  DQ and DM input setup time relative to DQS"
                puts $mddr3p_modi "    parameter TDH               =        150; // tDH      ps  DQ and DM input hold time relative to DQS"
                puts $mddr3p_modi "    parameter TIS               =        150; // tIS      ps  Input Setup Time"
                puts $mddr3p_modi "    parameter TIH               =        150; // tIH      ps  Input Hold Time"
                puts $mddr3p_modi "    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay"
                puts $mddr3p_modi "`else `ifdef sg107"
                puts $mddr3p_modi "    parameter TCK_MIN           =        1072; // tCK      ps  Minimum Clock Cycle Time"
                puts $mddr3p_modi "    parameter TDQSQ             =        200; // tDQSQ    ps  DQS-DQ skew, DQS to last DQ valid, per group, per access"
                puts $mddr3p_modi "    parameter TDS               =        150; // tDS      ps  DQ and DM input setup time relative to DQS"
                puts $mddr3p_modi "    parameter TDH               =        150; // tDH      ps  DQ and DM input hold time relative to DQS"
                puts $mddr3p_modi "    parameter TIS               =        150; // tIS      ps  Input Setup Time"
                puts $mddr3p_modi "    parameter TIH               =        150; // tIH      ps  Input Hold Time"
                puts $mddr3p_modi "    parameter TWTR              =       7500; // tWTR     ps  Write to Read command delay"

                puts $mddr3p_modi "`else `ifdef sg125"
                # Need different TRFCAB depending on device density
            } elseif {[regexp {\`endif \`endif \`endif \`endif} $line]} {
                puts $mddr3p_modi "`endif `endif `endif `endif `endif `endif `endif `endif `endif `endif `endif"
            } elseif {[regexp {// Simulation parameters} $line]} {
                puts $mddr3_modi $line
                puts $mddr3_modi "parameter BUS_DELAY        =       0; // delay in picoseconds"
        
            } elseif {[regexp {parameter TRFCAB\s*=\s*(\d+)} $line -> trfcab]} {
    
                puts $mddr3p_modi "`ifdef lpddr3_8Gb"
                regsub $trfcab $line 210000 line_new
                puts $mddr3p_modi $line_new
                
                puts $mddr3p_modi "`elsif lpddr3_4Gb"
                regsub $trfcab $line 130000 line_new
                puts $mddr3p_modi $line_new
                        
                puts $mddr3p_modi "`else"
                regsub $trfcab $line 130000 line_new
                puts $mddr3p_modi $line_new
            
                puts $mddr3p_modi "`endif"
                puts $mddr3p_modi "    parameter TXSR             =      TRFCAB + 10000;"
        
                # Need to modify definition of TXRS to make it dependent on TRFCAB
                # done above so remove subsequent defination
            } elseif {[regexp {parameter TXSR\s*=\s*(\d+)} $line]} {
        
            } elseif {[regexp {parameter TREFBW\s*=\s*(\d+)} $line -> trfbw]} {
    
                puts $mddr3p_modi "`ifdef lpddr3_8Gb"
                regsub $trfbw $line 6720000 line_new
                puts $mddr3p_modi $line_new
                
                puts $mddr3p_modi "`elsif lpddr3_4Gb"
                regsub $trfbw $line 4160000 line_new
                puts $mddr3p_modi $line_new
                        
                puts $mddr3p_modi "`else"
                regsub $trfbw $line 4160000 line_new
                puts $mddr3p_modi $line_new            
            
                puts $mddr3p_modi "`endif"
        
            } elseif {[regexp {parameter TRPPB\s*=\s*(\d+)} $line -> trppb]} {
    
                puts $mddr3p_modi "`ifdef LPDDR3_FAST"
                regsub $trppb $line 15000 line_new
                puts $mddr3p_modi $line_new
                
                puts $mddr3p_modi "`elsif LPDDR3_TYP"
                regsub $trppb $line 18000 line_new
                puts $mddr3p_modi $line_new
            
                puts $mddr3p_modi "`elsif LPDDR3_SLOW"
                regsub $trppb $line 24000 line_new
                puts $mddr3p_modi $line_new
        
                puts $mddr3p_modi "`endif"
        
                puts $mddr3p_modi "    parameter TRPAB             =      TRPPB + 3000;"
    
    
            # TRPAB defined above    
            } elseif {[regexp {parameter TRPAB\s*=\s*(\d+)} $line]} {
    
     
            # fast process selected at slower speed grade LPDDR2-400 so decrease clock cycles   
            } elseif {[regexp {parameter RPAB\s*=\s*(\d+)} $line]} {
    
                puts $mddr3p_modi "`ifdef LPDDR3_FAST"
                puts $mddr3p_modi "    parameter RPAB             =      3;"
                puts $mddr3p_modi "`else"
                puts $mddr3p_modi "    parameter RPAB             =      4;"
                puts $mddr3p_modi "`endif"
         
        
            } elseif {[regexp {parameter TRCD\s*=\s*(\d+)} $line -> trcd]} {
    
                puts $mddr3p_modi "`ifdef LPDDR3_FAST"
                regsub $trcd $line 15000 line_new
                puts $mddr3p_modi $line_new
                    
                puts $mddr3p_modi "`elsif LPDDR3_TYP"
                regsub $trcd $line 18000 line_new
                puts $mddr3p_modi $line_new
            
                puts $mddr3p_modi "`elsif LPDDR3_SLOW"
                regsub $trcd $line 24000 line_new
                puts $mddr3p_modi $line_new
        
                puts $mddr3p_modi "`endif"
        
        
            } elseif {[regexp {parameter TDQSCK\s*=\s*2000} $line]} {
            # puts $mddr3p_modi "// \[MODIFIED CODE\]"
                puts $mddr3p_modi "    parameter TDQSCK           =    2500; // tDQSCK ps    DQS output access time from CK/CK#"
            } else {
                puts $mddr3p_modi $line
            }
        }
        close $mddr3p_modi
        close $mddr3p_orig
    }
}


##########################################################################
## DDR4 - meant to work with version 0.998 of Micron models
if {($tc_ddr_mode == "DDR4") || ($tc_ddr_mode == "ALL")} {
    puts "[info script]: modifying DDR4 model"
    source $script_dir/modify_micron_ddr4_model.tcl
    ModifyMicronDdr4Model $src_dir $dst_dir
}
