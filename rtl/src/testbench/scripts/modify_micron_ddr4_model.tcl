#----------------------------------------------------------------------------
# Title         : modify_micron_ddr4_model
# Project       : ddrphy_common
#-----------------------------------------------------------------------------
# File          : modify_micron_ddr4_model.tcl
# Author        : Simon Robidas  <robidas@ca09cs004.internal.synopsys.com>
# Created       : 
# Last modified : 
#-----------------------------------------------------------------------------
# Description :
# Modifies the Micron DDR4 model for use in the directed verilog testbench. The
# global variable $script_dir is set by modify_micron_models_wrapper.tcl.
#-----------------------------------------------------------------------------
# Copyright (c) 2014 by Synopsys This model is the confidential and
# proprietary property of Synopsys and the possession or use of this
# file requires a written license from Synopsys.
#------------------------------------------------------------------------------

source $script_dir/file_utils.tcl

## This procedure ensures this script is using tclsh version 8.4 or later.
proc CheckTclshVersion {} {
    set version [info patchlevel]
    if {$version < 8.4} {
        puts "[info script].CheckTclshVersion: ERROR: Current tclsh version is $version. We require 8.4 or later"
        exit
    } else {
        puts "[info script].CheckTclshVersion: tclsh version $version is used"
    }
}

## This procedure will copy over all unmodified model files to a new directory. This procedure also makes sure
# all the model files are present and accounted for.
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will copy the modified model files to. If the path doesn't exist it will be created.
proc CopyModelFiles {unmodifiedDir modifiedDir} {
    CheckDirExistsIfNotCreate $modifiedDir
    CopyFile [file join $unmodifiedDir MemoryArray.sv]    $modifiedDir
    CopyFile [file join $unmodifiedDir StateTable.sv]     $modifiedDir
    CopyFile [file join $unmodifiedDir arch_defines.v]    $modifiedDir
    CopyFile [file join $unmodifiedDir dimm.vh]           $modifiedDir
    CopyFile [file join $unmodifiedDir dimm_interface.sv] $modifiedDir
    CopyFile [file join $unmodifiedDir dimm_subtest.vh]   $modifiedDir
    CopyFile [file join $unmodifiedDir dimm_tb.sv]        $modifiedDir
    CopyFile [file join $unmodifiedDir memory_file.txt]   $modifiedDir
    CopyFile [file join $unmodifiedDir readme.txt]        $modifiedDir
    CopyFile [file join $unmodifiedDir readme_dimm.txt]   $modifiedDir
    CopyFile [file join $unmodifiedDir run_dimm_vcs]      $modifiedDir
    CopyFile [file join $unmodifiedDir run_vcs]           $modifiedDir
    CopyFile [file join $unmodifiedDir subtest.vh]        $modifiedDir
    CopyFile [file join $unmodifiedDir tb.sv]             $modifiedDir
}

## This procedure modifies the interface.sv file distributed by Micron
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files.
proc ModifyInterface {unmodifiedDir modifiedDir} {
    set fileName [file join $unmodifiedDir interface.sv]

    set interface [GetLines $fileName]
    set interface [ReplaceLine $interface {    import arch_package::*;} ""]
    set newDeclaration [list {import arch_package::*;} {interface DDR4_if(inout[CONFIGURED_DM_BITS-1:0] DM_n,} {                  inout [CONFIGURED_DQ_BITS-1:0]  DQ,} {                  inout [CONFIGURED_DQS_BITS-1:0] DQS_t,} {                  inout [CONFIGURED_DQS_BITS-1:0] DQS_c);}]
    set interface [ReplaceLine $interface {interface DDR4_if;} $newDeclaration]
    set interface [ReplaceLine $interface "*wire?CONFIGURED_DM_BITS-1:0\] DM_n;*" ""]
    set interface [ReplaceLine $interface "*wire?CONFIGURED_DQ_BITS-1:0\] DQ;" ""]
    set interface [ReplaceLine $interface "*wire?CONFIGURED_DQS_BITS-1:0\] DQS_t;" ""]
    set interface [ReplaceLine $interface "*wire?CONFIGURED_DQS_BITS-1:0\] DQS_c;" ""]

    puts "[info script].ModifyInterface: creating a modified copy of $fileName in this directory: $modifiedDir"
    set modifiedFileName [file join $modifiedDir [file tail $fileName]]
    WriteListToFile $modifiedFileName $interface
}

## This procedure modifies the arch_package.sv file distributed by Micron
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files.
proc ModifyArchPackage {unmodifiedDir modifiedDir} {
    set fileName [file join $unmodifiedDir arch_package.sv]

    set archPackage [GetLines $fileName]
    set newElement  [split {    parameter int MAX_COL_ADDR_BITS   = 14; // Include AP/BLFLY} \n]
    set archPackage [ReplaceLine $archPackage {    parameter int MAX_COL_ADDR_BITS   = 13; // Include AP/BLFLY} $newElement]
    set newElement  [split {    parameter int MAX_BANK_BITS       = `DWC_PHY_BA_WIDTH;} \n]
    set archPackage [ReplaceLine $archPackage {    parameter int MAX_BANK_BITS       = 2;} $newElement]
    set newElement  [split {    parameter int MAX_RANK_BITS       = `DWC_CID_WIDTH;} \n]
    set archPackage [ReplaceLine $archPackage {    parameter int MAX_RANK_BITS       = 3;} $newElement]
    set newElement  [split {    parameter int MAX_BANK_GROUP_BITS = `DWC_PHY_BG_WIDTH;} \n]
    set archPackage [ReplaceLine $archPackage {    parameter int MAX_BANK_GROUP_BITS = 2;} $newElement]
    set newElement  [split {                  DLL_OFF,NUM_TS} \n]
    set archPackage [ReplaceLine $archPackage {                  NUM_TS} $newElement]

    puts "[info script].ModifyArchPackage: creating a modified copy of $fileName in this directory: $modifiedDir"
    set modifiedFileName [file join $modifiedDir [file tail $fileName]]
    WriteListToFile $modifiedFileName $archPackage
}

## This procedure modifies the StateTableCore.sv file distributed by Micron
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files.
proc ModifyStateTableCore {unmodifiedDir modifiedDir} {
    set verbose 1
    set fileName [file join $unmodifiedDir StateTableCore.sv]

    set stateTableCore [GetLines $fileName]
    set stateTableCore [ReplaceLine $stateTableCore "*longint rank_by_bank?longint\];*" [list {longint rank_by_bank[longint];} {bit _dynamic_fast_self_refresh;}] ]
    set newElement [split {            if (s_dut_mode_config.DLL_enable) begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSDLLc + CAL + PL - _current_cycle, "tXSDLL + CAL + PL", spec_string));
            end else begin
                if (_dynamic_fast_self_refresh) begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc + CAL + PL - _current_cycle, "tXSFast + CAL + PL", spec_string));
                end else begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc + CAL + PL - _current_cycle, "tXSc + CAL + PL",  spec_string));
                end
            end} \n]
    set stateTableCore [ReplaceLine $stateTableCore "*nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSDLLc + CAL + PL - _current_cycle, \"tXSDLL + CAL + PL\", spec_string));*" $newElement]
    set newElement [split {                if (_dynamic_fast_self_refresh) begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc + CAL + PL - _current_cycle, "tXSFast + CAL + PL", spec_string));
                end else begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc + CAL + PL - _current_cycle, "tXSc + CAL + PL", spec_string));
                end} \n]
    set stateTableCore [ReplaceLine $stateTableCore "*nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc + CAL + PL - _current_cycle, \"tXSc + CAL + PL\", spec_string));*" $newElement]
    set newElement [split {                if ((cmdZQ == cmdpkt.cmd) || (1 == tXSFastLMR(cmdpkt)) || _dynamic_fast_self_refresh) begin} \n]
    set stateTableCore [ReplaceLine $stateTableCore "*if ((cmdZQ == cmdpkt.cmd) || (1 == tXSFastLMR(cmdpkt))) begin*" $newElement]
    set newElement [split {        if (1 == ODTDynamicEnabled()) begin
        nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, "tDLLKc",  spec_string));
        end} \n]
    set stateTableCore [ReplaceLine $stateTableCore "*nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, \"tDLLKc\", spec_string));*" $newElement]
    set newElement [split {        if (s_dut_mode_config.DLL_enable) begin
            nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, "tDLLKc", spec_string));
        end else begin
            if (_dynamic_fast_self_refresh) begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc - _current_cycle, "tXSFast", spec_string));
            end else begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc - _current_cycle, "tXSc", spec_string));
            end
        end} \n]
    set stateTableCore [ReplaceLine $stateTableCore "*nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, \"tDLLKc\", spec_string));*" $newElement]
    set newElement [split {            _dynamic_fast_self_refresh = s_dut_mode_config.fast_self_refresh;
            if(_debug || print) $display("%0s::StateTable SREFX @%0t", _id, $time);} \n]
    set stateTableCore [ReplaceLine $stateTableCore "*if(_debug || print) \$display(\"%0s::StateTable SREFX @%0t\", _id, \$time);*" $newElement]

    puts "[info script].ModifyStateTableCore: creating a modified copy of $fileName in this directory: $modifiedDir"
    set modifiedFileName [file join $modifiedDir [file tail $fileName]]
    WriteListToFile $modifiedFileName $stateTableCore
}

## This procedure modifies the ddr4_model.sv file distributed by Micron
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files.
proc ModifyDdr4Model {unmodifiedDir modifiedDir} {
    set verbose 1
    set fileName [file join $unmodifiedDir ddr4_model.sv]

    set unmodifiedDdr4Model [GetLines $fileName]
    set modifiedDdr4Model {}

    set newElement [split {                        if (((tm_reset_n_pos - tm_reset_n_neg) < timing.tRESET) && reset_check) begin} \n]
    set unmodifiedDdr4Model [ReplaceLine $unmodifiedDdr4Model "*if ((tm_reset_n_pos - tm_reset_n_neg) < timing.tRESET) begin*" $newElement]

    # Replace all VIOLATION display messages in model by calls to `vmm_error(log, message)
    # Same for all ERROR display messages. Warning display messages will be converted to `vmm_warning and all other display messages
    # will be converted to vmm_note.
    for {set unmodifiedFileLineNumber 1} {$unmodifiedFileLineNumber <= [llength $unmodifiedDdr4Model]} {incr unmodifiedFileLineNumber 1} {
        # In TCL, lists start at index 0. So line 1 from fileName is at index 0 of unmodifiedDdr4Model.
        set unmodifiedListIndex [expr $unmodifiedFileLineNumber - 1]
        switch $unmodifiedFileLineNumber {
            71 {
                lappend modifiedDdr4Model {    parameter pRST_DFLT = `DWC_RST_DFLT;}
            }
            73 {
                lappend modifiedDdr4Model {    reg reset_check;}
            }
            261 {
                lappend modifiedDdr4Model {        `ifdef DWC_NO_OF_3DS_STACKS `ifndef CSNCIDMUX
        if (`DWC_NO_OF_3DS_STACKS == 2) begin}
            }
            264 {
                lappend modifiedDdr4Model {        end else if (`DWC_NO_OF_3DS_STACKS == 4) begin}
            }
            267 {
                lappend modifiedDdr4Model {        end else if (`DWC_NO_OF_3DS_STACKS == 8) begin}
            }
            270 {
                lappend modifiedDdr4Model {        end else begin}
            }
            273 {
                lappend modifiedDdr4Model {        end  `else _dut_config.rank_mask = 'b0; _dut_config.ranks = 1; `endif
        `else
            _dut_config.rank_mask = 'b0;
            _dut_config.ranks = 1;
        `endif}
            }
            281 {
                lappend modifiedDdr4Model {        reset_check = 1;}
            }
            461 {
                lappend modifiedDdr4Model {            in_write_levelization = 1;}
                lappend modifiedDdr4Model {            // SNPS: Added to fix behavior of Qoff during write leveling}
                lappend modifiedDdr4Model {            if (0 === GetqOff())} 
                lappend modifiedDdr4Model {              dq_out_enb <= #(timing.tWLO_max*2) '1;}
                lappend modifiedDdr4Model {            else} 
                lappend modifiedDdr4Model {              dq_out_enb <= #(timing.tWLO_nominal) '0;}
            }
            514 {
                lappend modifiedDdr4Model {            if((init == 1 && pRST_DFLT == 1) || cmd === 4'bxxxx) begin}
                lappend modifiedDdr4Model {              ignore_cmd = 1;}
                lappend modifiedDdr4Model {            end}
                lappend modifiedDdr4Model [lindex $unmodifiedDdr4Model $unmodifiedListIndex]
            }
            551 {
                lappend modifiedDdr4Model {                                $display("%m:VIOLATION: tXPR (measured: %0d \t lower limit: %0d @%0t", ($time - tm_cke), timing.tXPR, $time);}
            }
            553 {
                lappend modifiedDdr4Model {                            initialized_mr[(configured_bg[0]*4) + configured_ba] = 1;}
            }
            665 {
                lappend modifiedDdr4Model {                            lmr_pkt.Populate(cmdLMR, configured_rank, configured_bg[0], configured_ba, iDDR4.ADDR, tck);}
            }
            1171 {
                lappend modifiedDdr4Model {            if(wr_burst_pos!==(MAX_BURST_LEN-1)) last_dqs_toggle = dqs_toggle;}
            }
            1182 {
                lappend modifiedDdr4Model {                    if ( 0 == GetWrDBI() ) }
            }
            1282 {
                lappend modifiedDdr4Model {            //else begin // SNPS: write leveling in progress, see block always_dmc}
            }
            1283 {
                lappend modifiedDdr4Model {            //    dq_out_enb <= #(timing.tDQSCK) '1; }
            }
            1284 {
                lappend modifiedDdr4Model {            //end}
            }
            1501 {
                lappend modifiedDdr4Model {        `elsif DDR4_DBYP
            SetModelTiming(DLL_OFF);
        `else}
            }
            default {
                lappend modifiedDdr4Model [lindex $unmodifiedDdr4Model $unmodifiedListIndex]
            }
        }
    }


    puts "[info script].ModifyDdr4Model: creating a modified copy of $fileName in this directory: $modifiedDir"
    set modifiedFileName [file join $modifiedDir [file tail $fileName]]
    WriteListToFile $modifiedFileName $modifiedDdr4Model
}

## This procedure modifies the proj_package.sv file distributed by Micron
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files.
proc ModifyProjPackage {unmodifiedDir modifiedDir} {
    set verbose 1
    set fileName [file join $unmodifiedDir proj_package.sv]
    
    set projPackage [GetLines $fileName]
    set newElement [split {        dut_config.max_CL_dbi_enabled = 23;//SNPS: modified to support DDR4-2666} \n]
    set projPackage [ReplaceLine $projPackage {        dut_config.max_CL_dbi_enabled = 20;} $newElement]
    set newElement [split {        dut_config.max_CL_dbi_disabled = 20;//SNPS: modified to support DDR4-2666} \n]
    set projPackage [ReplaceLine $projPackage {        dut_config.max_CL_dbi_disabled = 18;} $newElement]
    set newElement [split {                slowest = TS_1875; fastest = TS_1500;//SNPS: modified to comply with table 80 of JEDEC spec} \n]
    set replaceOccuranceNb 1
    set projPackage [ReplaceLine $projPackage {                slowest = TS_1500; fastest = TS_1500;} $newElement $replaceOccuranceNb]
    set replaceOccuranceNb 2
    set newElement [split {// SNPS: Modified to test 2666 speed
//                    slowest = TS_938; fastest = TS_833;
                    slowest = TS_938; fastest = TS_750;} \n]
    set projPackage [ReplaceLine $projPackage {                    slowest = TS_938; fastest = TS_833;} $newElement $replaceOccuranceNb]
    set newElement [split {// SNPS: Modified to test 2666 speed
//                    slowest = TS_833; fastest = TS_833;
                    slowest = TS_833; fastest = TS_750;} \n]
    set projPackage [ReplaceLine $projPackage {                    slowest = TS_833; fastest = TS_833;} $newElement]
    set replaceOccuranceNb 2
    set newElement [split {// SNPS: Modified to test 2666 speed
//                slowest = TS_833; fastest = TS_833;
                slowest = TS_833; fastest = TS_750;} \n]
    set projPackage [ReplaceLine $projPackage {                slowest = TS_833; fastest = TS_833;} $newElement $replaceOccuranceNb]
    set replaceOccuranceNb 3
    set newElement [split {// SNPS: Modified to test 2666 speed
//                slowest = TS_833; fastest = TS_833;
                slowest = TS_833; fastest = TS_750;} \n]
    set projPackage [ReplaceLine $projPackage {                slowest = TS_833; fastest = TS_833;} $newElement $replaceOccuranceNb]

    puts "[info script].ModifyProjPackage: creating a modified copy of $fileName in this directory: $modifiedDir"
    set modifiedFileName [file join $modifiedDir [file tail $fileName]]
    WriteListToFile $modifiedFileName $projPackage
}

## This procedure modifies the timing_task.sv file distributed by Micron
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files.
proc ModifyTimingTask {unmodifiedDir modifiedDir} {
    set verbose 1
    set fileName [file join $unmodifiedDir timing_tasks.sv]

    set unmodifiedTimingTasks [GetLines $fileName]
    set modifiedTimingTasks {}

    # Replace all VIOLATION display messages in model by calls to `vmm_error(log, message)
    # Same for all ERROR display messages. Warning display messages will be converted to `vmm_warning and all other display messages
    # will be converted to vmm_note.
    for {set unmodifiedFileLineNumber 1} {$unmodifiedFileLineNumber <= [llength $unmodifiedTimingTasks]} {incr unmodifiedFileLineNumber 1} {
        # In TCL, lists start at index 0. So line 1 from fileName is at index 0 of unmodifiedTimingTasks.
        set unmodifiedListIndex [expr $unmodifiedFileLineNumber - 1]
        switch $unmodifiedFileLineNumber {
            348 { lappend modifiedTimingTasks {    // DDR4_                   1066    1333      1600     1866   2133   2400    2667    2934    3200    250   }}
            349 { lappend modifiedTimingTasks {    // UTYPE_TS             TS_1875 TS_1500   TS_1250  TS_1072 TS_938 TS_833  TS_750  TS_682  TS_625  DLL_OFF }}
            350 { lappend modifiedTimingTasks {    //          tParam      ------- -------   -------  ------- ------ ------  ------  ------  ------  ------  }}
            351 { lappend modifiedTimingTasks {    SetTSArray (TS_LOADED,       1,      1,        1,       1,     1,     1,      1,      1,      1,      1 );}}
            352 { lappend modifiedTimingTasks {    SetTSArray (itCK_min,     1875,   1500,     1250,    1072,   938,   833,    750,    682,    625,   8000 );}}
            353 { lappend modifiedTimingTasks {    SetTSArray (itCK_max,     1875,   1500,     1250,    1072,   938,   833,    750,    682,    625,   8000 );}}
            354 { lappend modifiedTimingTasks {    SetTSArray (itDQSQ,          0,      0,        0,       0,     0,     0,      0,      0,      0,      0 );}}
            355 { lappend modifiedTimingTasks {    SetTSArray (itDS,          125,    125,      125,     125,   125,   125,    125,    125,    125,    125 );}}
            356 { lappend modifiedTimingTasks {    SetTSArray (itDH,          125,    125,      125,     125,   125,   125,    125,    125,    125,    125 );}}
            357 { lappend modifiedTimingTasks {    SetTSArray (itIPW,         938,    750,      560,     535,   470,   416,    375,    341,    312,    938 );}}
            358 { lappend modifiedTimingTasks {    SetTSArray (itDQSCK,         0,      0,        0,       0,     0,     0,      0,      0,      0,      0 );}}
            359 { lappend modifiedTimingTasks {    SetTSArray (itDQSCK_min,  -375,   -300,     -225,    -195,  -180,  -166,   -150,   -136,   -125,   -375 );}}
            360 { lappend modifiedTimingTasks {    SetTSArray (itDQSCK_max,   375,    300,      225,     195,   180,   166,    150,    136,    125,    375 );}}
            361 { lappend modifiedTimingTasks {    SetTSArray (itDLLKc_min,   512,    512,      512,     512,   512,   512,    512,    512,    512,    512 );}}
            362 { lappend modifiedTimingTasks {    SetTSArray (itRTP,        7500,   7500,     7500,    7500,  7500,  7500,   7500,   6000,   6000,   7500 );}}
            363 { lappend modifiedTimingTasks {    SetTSArray (itWTRc_S,        2,      2,        2,       2,     2,     2,      2,      2,      2,      2 );}}
            364 { lappend modifiedTimingTasks {    SetTSArray (itWTRc_L,        4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            365 { lappend modifiedTimingTasks {    SetTSArray (itWTR_S,      2500,   2500,     2500,    2500,  2500,  2500,   2500,   2500,   2500,   2500 );}}
            366 { lappend modifiedTimingTasks {    SetTSArray (itWTR_L,      7500,   7500,     7500,    7500,  7500,  7500,   7500,   7500,   7500,   7500 );}}
            367 { lappend modifiedTimingTasks {    SetTSArray (itWTRc_S_CRC_DM, 5,      5,        5,       5,     5,     5,      5,      6,      6,      5 );}}
            368 { lappend modifiedTimingTasks {    SetTSArray (itWTRc_L_CRC_DM, 5,      5,        5,       5,     5,     5,      5,      6,      6,      5 );}}
            369 { lappend modifiedTimingTasks {    SetTSArray (itWR,        15000,  15000,    15000,   15000, 15000, 15000,  15000,  15000,  15000,  15000 );}}
            370 { lappend modifiedTimingTasks {    SetTSArray (itMOD,       45000,  36000,    30000,   25728, 22512, 20000,  18000,  16368,  15000,  45000 );}}
            371 { lappend modifiedTimingTasks {    SetTSArray (itRCD,       17000,  16000,    15000,   15000, 13130, 12500,  12500,  12500,  12500,  17000 );}}
            372 { lappend modifiedTimingTasks {    SetTSArray (itRC,        56000,  55000,    50000,   49000, 46130, 44500,  44500,  44500,  44500,  56000 );}}
            373 { lappend modifiedTimingTasks {    SetTSArray (itRP,        17000,  16000,    15000,   15000, 13130, 12500,  12500,  12500,  12500,  17000 );}}
            374 { lappend modifiedTimingTasks {    SetTSArray (itRP_ref,    30000,  30000,    30000,   30000, 30000, 30000,  30000,  30000,  30000,  30000 );}}
            375 { lappend modifiedTimingTasks {    SetTSArray (itCCD_L,      6250,   6250,      6250,   5355,  5355,  5000,   5000,   5000,   5000,   6250 );}}
            376 { lappend modifiedTimingTasks {    SetTSArray (itCCDc_S,        4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            377 { lappend modifiedTimingTasks {    SetTSArray (itCCDc_L,        5,      5,        5,       5,     5,     5,      5,      5,      5,      5 );}}
            378 { lappend modifiedTimingTasks {    SetTSArray (itRAS,       39000,  39000,    35000,   34000, 33000, 32000,  32000,  32000,  32000,  39000 );}}
            379 { lappend modifiedTimingTasks {    SetTSArray (itRRDc_S_512,    4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            380 { lappend modifiedTimingTasks {    SetTSArray (itRRDc_S_1k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            381 { lappend modifiedTimingTasks {    SetTSArray (itRRDc_S_2k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            382 { lappend modifiedTimingTasks {    SetTSArray (itRRDc_L_512,    4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            383 { lappend modifiedTimingTasks {    SetTSArray (itRRDc_L_1k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            384 { lappend modifiedTimingTasks {    SetTSArray (itRRDc_L_2k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            385 { lappend modifiedTimingTasks {    SetTSArray (itRRD_S_512,  7500,   6000,     5000,    4200,  3700,  3300,   3300,   3300,   3300,   7500 );}}
            386 { lappend modifiedTimingTasks {    SetTSArray (itRRD_S_1k,   7500,   6000,     5000,    4200,  3700,  3300,   3300,   3300,   3300,   7500 );}}
            387 { lappend modifiedTimingTasks {    SetTSArray (itRRD_S_2k,   7500,   6000,     6000,    5300,  5300,  5300,   5300,   5300,   5300,   7500 );}}
            388 { lappend modifiedTimingTasks {    SetTSArray (itRRD_L_512,  7500,   6000,     6000,    5300,  5300,  4900,   4900,   4900,   4900,   7500 );}}
            389 { lappend modifiedTimingTasks {    SetTSArray (itRRD_L_1k,   7500,   6000,     6000,    5300,  5300,  4900,   4900,   4900,   4900,   7500 );}}
            390 { lappend modifiedTimingTasks {    SetTSArray (itRRD_L_2k,   7500,   7500,     7500,    6400,  6400,  6400,   6400,   6400,   6400,   7500 );}}
            391 { lappend modifiedTimingTasks {    SetTSArray (itFAW_512,   20000,  20000,    20000,   17000, 15000, 13000,  13000,  13000,  13000,  20000 );}}
            392 { lappend modifiedTimingTasks {    SetTSArray (itFAW_1k,    25000,  25000,    25000,   23000, 21000, 21000,  21000,  21000,  21000,  25000 );}}
            393 { lappend modifiedTimingTasks {    SetTSArray (itFAW_2k,    35000,  35000,    35000,   30000, 30000, 30000,  30000,  30000,  30000,  35000 );}}
            394 { lappend modifiedTimingTasks {    SetTSArray (itIS,          170,    170,      170,     170,   170,   170,    170,    170,    170,    170 );}}
            395 { lappend modifiedTimingTasks {    SetTSArray (itIH,          120,    120,      120,     120,   120,   120,    120,    120,    120,    120 );}}
            396 { lappend modifiedTimingTasks {    SetTSArray (itDIPW,        560,    450,      360,     320,   280,   250,    230,    200,    190,    560 );}}
            397 { lappend modifiedTimingTasks {    SetTSArray (itCKE,        5625,   5000,     5000,    5000,  5000,  5000,   5000,   5000,   5000,   5625 );}}
            398 { lappend modifiedTimingTasks {    SetTSArray (itCPDEDc,        4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );}}
            399 { lappend modifiedTimingTasks {    SetTSArray (itXP,         7500,   6000,     6000,    6000,  6000,  6000,   6000,   6000,   6000,   7500 );}}
            400 { lappend modifiedTimingTasks {    SetTSArray (itXPDLL,     24000,  24000,    24000,   24000, 24000, 24000,  24000,  24000,  24000,  24000 );}}
            401 { lappend modifiedTimingTasks {    SetTSArray (itACTPDENc,      0,      0,        0,       0,     1,     1,      1,      1,      1,      0 );}}
            402 { lappend modifiedTimingTasks {    SetTSArray (itPREPDENc,      0,      0,        0,       0,     1,     1,      1,      1,      1,      0 );}}
            403 { lappend modifiedTimingTasks {    SetTSArray (itREFPDENc,      0,      0,        0,       0,     1,     1,      1,      1,      1,      0 );}}
            404 { lappend modifiedTimingTasks {    SetTSArray (itZQinitc,    1024,   1024,     1024,    1024,  1024,  1024,   1024,   1024,   1024,   1024 );}}
            405 { lappend modifiedTimingTasks {    SetTSArray (itZQoperc,     512,    512,      512,     512,   512,   512,    512,    512,    512,    512 );}}
            406 { lappend modifiedTimingTasks {    SetTSArray (itZQCSc,       128,    128,      128,     128,   128,   128,    128,    128,    128,    128 );}}
            407 { lappend modifiedTimingTasks {    SetTSArray (itWLS,         244,    195,      163,     140,   122,   109,     98,     89,     82,    244 );}}
            408 { lappend modifiedTimingTasks {    SetTSArray (itWLH,         244,    195,      163,     140,   122,   109,     98,     89,     82,    244 );}}
            409 { lappend modifiedTimingTasks {    SetTSArray (itAON_min,    -225,   -225,     -225,    -195,  -180,  -180,   -180,   -180,   -180,   -225 );}}
            410 { lappend modifiedTimingTasks {    SetTSArray (itAON_max,     225,    225,      225,     195,   180,   180,    180,    180,    180,    225 );}}
            411 { lappend modifiedTimingTasks {    SetTSArray (itPAR_ALERT_PWc, 48,    47,       72,      84,    96,   108,    108,    108,    108,     48 );}}
            412 { lappend modifiedTimingTasks {    SetTSArray (itPAR_ALERT_PWc_min,32, 40,       48,      56,    64,    72,     72,     72,     72,     32 );}}
            413 { lappend modifiedTimingTasks {    SetTSArray (itPAR_ALERT_PWc_max,80,100,       96,     112,   128,   144,    160,    176,    192,     80 );}}
            428 { lappend modifiedTimingTasks {                int ts_938, int ts_833, int ts_750, int ts_682, int ts_625, int dll_off);}}
            438 { lappend modifiedTimingTasks {    tt_timesets[DLL_OFF][spec] = dll_off;
endtask}}
            default {
                lappend modifiedTimingTasks [lindex $unmodifiedTimingTasks $unmodifiedListIndex]
            }
        }
    }
    puts "[info script].ModifyTimingTask: creating a modified copy of $fileName in this directory: $modifiedDir"
    set modifiedFileName [file join $modifiedDir [file tail $fileName]]
    WriteListToFile $modifiedFileName $modifiedTimingTasks
}


## This procedure modifies all relevant Micron DDR4 model files and copies files which do not need to be modified
# \param unmodifiedDir Path where we can find the unmodified model files
# \param modifiedDir Path where we will deposit the modified model files. If the path doesn't exist it will be created.
proc ModifyMicronDdr4Model {unmodifiedDir modifiedDir} {
    CheckTclshVersion
    CopyModelFiles       $unmodifiedDir $modifiedDir
    ModifyInterface      $unmodifiedDir $modifiedDir
    ModifyArchPackage    $unmodifiedDir $modifiedDir
    ModifyStateTableCore $unmodifiedDir $modifiedDir
    ModifyDdr4Model      $unmodifiedDir $modifiedDir
    ModifyProjPackage    $unmodifiedDir $modifiedDir
    ModifyTimingTask     $unmodifiedDir $modifiedDir
}






