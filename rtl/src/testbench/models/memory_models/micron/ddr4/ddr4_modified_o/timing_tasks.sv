typedef enum {
    TS_LOADED,
    itCK_min, itCK_max,
    itDQSQ, itQHp, itDS, itDH, itIPW,
    itRPREp, itRPSTp, itQSHp, itQSLp, 
    itWPSTp, itWPREp, itDQSCK, itDQSCK_min, itDQSCK_max,
    itDQSLp, itDQSHp, itDQSSp, itDQSSp_min, itDQSSp_max,
    itDLLKc_min, itRTP, itRTPc, itWTRc_S, itWTRc_L, itWTR_S, itWTR_L, itWTRc_S_CRC_DM, itWTRc_L_CRC_DM, itWR, itMRDc, itMOD, itMODc,
    itRCD, itRP, itRP_ref, itRC, itCCDc_S, itCCDc_L, itCCD_L,
    itRRDc_S_512, itRRDc_L_512, itRRDc_S_1k, itRRDc_L_1k, itRRDc_S_2k, itRRDc_L_2k, 
    itRRD_S_512, itRRD_L_512, itRRD_S_1k, itRRD_L_1k, itRRD_S_2k, itRRD_L_2k, 
    itRAS, itFAW_512, itFAW_1k, itFAW_2k, itIS, itIH, itDIPW,
    itXPR,
    itPAR_ALERT_PWc, itPAR_ALERT_PWc_min, itPAR_ALERT_PWc_max,
    itXS, itXSDLLc, itCKESR, 
    itCKSREc, itCKSRE, itCKSRXc, itCKSRX, itXSR,
    itXP, itXPc, itXPDLL, itXPDLLc, itCKE, itCKEc, itCPDEDc, itPD, itPDc, 
    itACTPDENc, itPREPDENc, itREFPDENc, itMRSPDEN,
    itZQinitc, itZQoperc, itZQCSc,
    itWLS, itWLH, itAON_min, itAON_max,
    NUM_TIMESPEC	
} UTYPE_time_spec;

// timing definition in tCK units
integer tt_timesets [0:NUM_TS-1][0:NUM_TIMESPEC-1];
integer tCK;
integer tOffset;
int max_tCK, min_tCK;

initial begin
    LoadTiming();
end

// tCK and tOffset are the 'master' values.
always @(tCK) begin
    timing.tCK = tCK;
end
always @(tOffset) begin
    timing.tOffset = tOffset;
end

task SettCK(input integer _tCK);
    tCK = _tCK;
    tOffset = _tCK;
endtask
    
task SetTimingStruct(input UTYPE_TS ts, UTYPE_tCKMode tck_mode = TCK_MIN);
    if (tt_timesets[ts][TS_LOADED] != 1) begin
        UTYPE_TS temp_ts; // 6.2 does not support name() on structures.
        
        temp_ts = timing.ts_loaded;
        $display("SetTiming:ERROR: Invalid timeset requested '%0s' @%0t. Timeset stays at '%0s'.", 
                    ts.name(), $time, temp_ts.name());
        return;
    end
    
    if(tck_mode === TCK_MAX) begin
        SettCK(tt_timesets[ts][itCK_max]);
    end else if(tck_mode === TCK_RANDOM) begin
        integer rand_tckmode;
        
        rand_tckmode = $urandom % 100;
        if (rand_tckmode < 10) // 10%
            SettCK($urandom_range(tt_timesets[ts][itCK_min], tt_timesets[ts][itCK_max]));
        else if (rand_tckmode < 20) // 10%
            SettCK(tt_timesets[ts][itCK_max]);
        else // 80%
            SettCK(tt_timesets[ts][itCK_min]);
    end else
        SettCK(tt_timesets[ts][itCK_min]);
        
    $display("Setting Timeset:%0s with tCk:%0d @%0t", ts.name(), tCK, $time);
    timing.ts_loaded = ts;
    timing.tck_mode = tck_mode;
    // Clock timing.
    timing.ClockDutyCycle = 50;
    timing.tCK_min = tt_timesets[ts][itCK_min];
    timing.tCK_max = tt_timesets[ts][itCK_max];
    timing.tCHp_min = 48;
    timing.tCHp_min = 52;
    // Data timing.
    timing.tDQSQ = tt_timesets[ts][itDQSQ];
    timing.tQHp = 38;
    timing.tDS = tt_timesets[ts][itDS];
    timing.tDH = tt_timesets[ts][itDH];
    timing.tIPW = tt_timesets[ts][itIPW];
    // Data strobe timing.
    if (0 < tt_timesets[ts][itRPREp])
        timing.tRPREp = tt_timesets[ts][itRPREp];
    else
        timing.tRPREp = 100;
    if (0 < tt_timesets[ts][itRPSTp])
        timing.tRPSTp = tt_timesets[ts][itRPSTp];
    else
        timing.tRPSTp = 50;
    timing.tQSHp = 40;
    timing.tQSLp = 40;
    timing.tWPSTp = 50;
    timing.tWPREp = 100;
    timing.tDQSCK = tt_timesets[ts][itDQSCK];
    timing.tDQSCK_dll_on = tt_timesets[ts][itDQSCK];
    timing.tDQSCK_min = tt_timesets[ts][itDQSCK_min];
    timing.tDQSCK_max = tt_timesets[ts][itDQSCK_max];
    timing.tDQSCK_dll_off = 5800;
    timing.tDQSCK_dll_off_min = 1000;
    timing.tDQSCK_dll_off_max = 9000;
    timing.tDQSLp = 50;
    timing.tDQSLp_min = 45;
    timing.tDQSLp_max = 55;
    timing.tDQSHp = 50;
    timing.tDQSHp_min = 45;
    timing.tDQSHp_max = 55;
    timing.tDQSSp = 0; // Nominal.
    timing.tDQSSp_1tCK_min = -27;
    timing.tDQSSp_1tCK_max = 27;
    timing.tDQSSp_2tCK_min = timing.tDQSSp_1tCK_min;
    timing.tDQSSp_2tCK_max = timing.tDQSSp_1tCK_max;
    timing.tDQSSp_min = timing.tDQSSp_1tCK_min;
    timing.tDQSSp_max = timing.tDQSSp_1tCK_max;
    // Command and address timing.
    timing.tDLLKc = tt_timesets[ts][itDLLKc_min];
    timing.tRTP = tt_timesets[ts][itRTP];
    timing.tRTPc = ParamInClks(tt_timesets[ts][itRTP], tt_timesets[ts][itCK_min]);
    timing.tRTP_min = tt_timesets[ts][itRTP];
    timing.tRTPc_min = 4;
    timing.tWTR_S = tt_timesets[ts][itWTR_S];
    timing.tWTRc_S = tt_timesets[ts][itWTRc_S];
    timing.tWTR_L = tt_timesets[ts][itWTR_L];
    timing.tWTRc_L = tt_timesets[ts][itWTRc_L];
    timing.tWTR_S_CRC_DM = tt_timesets[ts][itWTRc_S_CRC_DM] * tt_timesets[ts][itCK_min];
    timing.tWTRc_S_CRC_DM = tt_timesets[ts][itWTRc_S_CRC_DM];
    timing.tWTR_L_CRC_DM = tt_timesets[ts][itWTRc_L_CRC_DM] * tt_timesets[ts][itCK_min];
    timing.tWTRc_L_CRC_DM = tt_timesets[ts][itWTRc_L_CRC_DM];
    timing.tWR = tt_timesets[ts][itWR];
    timing.tWRc = ParamInClks(tt_timesets[ts][itWR], tt_timesets[ts][itCK_min]);
    timing.tWR_CRC_DMc = 5;
    timing.tMRDc = 8;
    timing.tMOD = tt_timesets[ts][itMOD];
    timing.tMODc = ParamInClks(tt_timesets[ts][itMOD], tt_timesets[ts][itCK_min]);
    timing.tMPRRc = 1;
    timing.tWR_MPRc = timing.tMODc;
    timing.tRCD = tt_timesets[ts][itRCD];
    timing.tRCDc = ParamInClks(tt_timesets[ts][itRCD], tt_timesets[ts][itCK_min]);
    timing.tRP = tt_timesets[ts][itRP];
    timing.tRPc = ParamInClks(tt_timesets[ts][itRP], tt_timesets[ts][itCK_min]);
    timing.tRP_ref_internal = tt_timesets[ts][itRP_ref];
    timing.tRPc_ref_internal = ParamInClks(tt_timesets[ts][itRP_ref], tt_timesets[ts][itCK_min]);
    timing.tRC = tt_timesets[ts][itRC];
    timing.tRCc = ParamInClks(tt_timesets[ts][itRC], tt_timesets[ts][itCK_min]);
    timing.tCCD_S = tt_timesets[ts][itCCDc_S] * tt_timesets[ts][itCK_min];
    timing.tCCDc_S = tt_timesets[ts][itCCDc_S];
    timing.tCCD_L = tt_timesets[ts][itCCD_L];
    timing.tCCDc_L = tt_timesets[ts][itCCDc_L];
    timing.tRAS = tt_timesets[ts][itRAS];
    timing.tRASc = ParamInClks(tt_timesets[ts][itRAS], tt_timesets[ts][itCK_min]);
    timing.tPAR_CLOSE_BANKS = timing.tRAS;
    timing.tPAR_ALERT_ON = 1400;
    timing.tPAR_ALERT_ON_max = 6000;
    timing.tPAR_ALERT_ON_CYCLES = 4;
    timing.tPAR_ALERT_OFF = 3000;
    timing.tPAR_tRP_tRAS_adjustment = 2000;
    timing.tPAR_tRP_holdoff_adjustment = 1450;
    timing.tPAR_ALERT_PWc = tt_timesets[ts][itPAR_ALERT_PWc];
    timing.tPAR_ALERT_PWc_min = tt_timesets[ts][itPAR_ALERT_PWc_min];
    timing.tPAR_ALERT_PWc_max = tt_timesets[ts][itPAR_ALERT_PWc_max];
    timing.tPAR_ALERT_PW = timing.tPAR_ALERT_PWc * tt_timesets[ts][itCK_min];
    timing.tPAR_ALERT_PW_min = timing.tPAR_ALERT_PWc_min * tt_timesets[ts][itCK_min];
    timing.tPAR_ALERT_PW_max = timing.tPAR_ALERT_PWc_max * tt_timesets[ts][itCK_min];
    timing.tCRC_ALERT = 9000;
    timing.tCRC_ALERT_max = 13000;
    timing.tCRC_ALERT_PWc_min = 6;
    timing.tCRC_ALERT_PWc_max = 10;
    timing.tCRC_ALERT_PWc = 7;
    if (16 == GetWidth()) begin
        timing.tFAW = tt_timesets[ts][itFAW_2k];
        timing.tFAWc_dlr = 28;
        timing.tRRDc_S = tt_timesets[ts][itRRDc_S_2k];
        timing.tRRDc_L = tt_timesets[ts][itRRDc_L_2k];
        timing.tRRD_S = tt_timesets[ts][itRRD_S_2k];
        timing.tRRD_L = tt_timesets[ts][itRRD_L_2k];
    end else if (4 == GetWidth()) begin
        timing.tFAW = tt_timesets[ts][itFAW_512];
        timing.tFAWc_dlr = 16;
        timing.tRRDc_S = tt_timesets[ts][itRRDc_S_512];
        timing.tRRDc_L = tt_timesets[ts][itRRDc_L_512];
        timing.tRRD_S = tt_timesets[ts][itRRD_S_512];
        timing.tRRD_L = tt_timesets[ts][itRRD_L_512];
    end else begin
        timing.tFAW = tt_timesets[ts][itFAW_1k];
        timing.tFAWc_dlr = 20;
        timing.tRRDc_S = tt_timesets[ts][itRRDc_S_1k];
        timing.tRRDc_L = tt_timesets[ts][itRRDc_L_1k];
        timing.tRRD_S = tt_timesets[ts][itRRD_S_1k];
        timing.tRRD_L = tt_timesets[ts][itRRD_L_1k];
    end
    timing.tRRDc_dlr = 4;
    timing.tIS = tt_timesets[ts][itIS];
    timing.tIH = tt_timesets[ts][itIH];
    timing.tDIPW = tt_timesets[ts][itDIPW];
    // Refresh timing.
    `ifdef DDR4_2G
        timing.tRFC1 = 160000;
        timing.tRFC2 = 110000;
        timing.tRFC4 = 90000;
    `elsif DDR4_4G
        timing.tRFC1 = 260000;
        timing.tRFC2 = 160000;
        timing.tRFC4 = 110000;
    `elsif DDR4_8G
        timing.tRFC1 = 350000;
        timing.tRFC2 = 260000;
        timing.tRFC4 = 160000;
    `elsif DDR4_16G
        timing.tRFC1 = 350000;
        timing.tRFC2 = 260000;
        timing.tRFC4 = 160000;
    `endif
    timing.tRFC = timing.tRFC1;
    timing.tRFCc = ParamInClks(timing.tRFC1, tt_timesets[ts][itCK_min]);
    timing.tRFC1c = ParamInClks(timing.tRFC1, tt_timesets[ts][itCK_min]);
    timing.tRFC2c = ParamInClks(timing.tRFC2, tt_timesets[ts][itCK_min]);
    timing.tRFC4c = ParamInClks(timing.tRFC4, tt_timesets[ts][itCK_min]);
    // Reset timing.
    timing.tXPR = timing.tRFC + 10000;
    // Self refresh timing.
    timing.tXS = timing.tRFC + 10000;
    timing.tXSc = ParamInClks(timing.tRFC + 10000, tt_timesets[ts][itCK_min]);
    timing.tXS_Fast = timing.tRFC4 + 10000;
    timing.tXS_Fastc = ParamInClks(timing.tXS_Fast, tt_timesets[ts][itCK_min]);
    timing.tXSDLLc = tt_timesets[ts][itDLLKc_min];
    timing.tCKESRc = ParamInClks(tt_timesets[ts][itCKE], tt_timesets[ts][itCK_min]) + 1;
    timing.tCKSRE = 10000;
    timing.tCKSREc = ParamInClks(timing.tCKSRE, tt_timesets[ts][itCK_min]);
    if (timing.tCKSREc < 5) begin
        timing.tCKSREc = 5;
        timing.tCKSRE = timing.tCKSREc * tt_timesets[ts][itCK_min];
    end
    timing.tCKSRX = 10000;
    timing.tCKSRXc = ParamInClks(timing.tCKSRX, tt_timesets[ts][itCK_min]);
    if (timing.tCKSRXc < 5) begin
        timing.tCKSRXc = 5;
        timing.tCKSRX = timing.tCKSRXc * tt_timesets[ts][itCK_min];
    end
    timing.tXSR = timing.tRFC + 10000;
    // Power down timing.
    if (timing.tCK_min > 1500) begin
        timing.tXPc = 4;
        timing.tXP = 4 * timing.tCK_min;
    end else begin
        timing.tXP = 6000;
        timing.tXPc = ParamInClks(6000, tt_timesets[ts][itCK_min]);
    end
    timing.tXPDLL = tt_timesets[ts][itXPDLL];
    timing.tXPDLLc = ParamInClks(tt_timesets[ts][itXPDLL], tt_timesets[ts][itCK_min]);
    timing.tCKE = tt_timesets[ts][itCKE];
    timing.tCKEc = ParamInClks(tt_timesets[ts][itCKE], tt_timesets[ts][itCK_min]);
    timing.tCPDEDc = tt_timesets[ts][itCPDEDc];
    timing.tPD = tt_timesets[ts][itCKE];
    timing.tPDc = ParamInClks(tt_timesets[ts][itCKE], tt_timesets[ts][itCK_min]);
    // tRDPDEN/tWRPDEN are calculated dynamically.
    timing.tACTPDENc = tt_timesets[ts][itACTPDENc];
    timing.tPREPDENc = tt_timesets[ts][itPREPDENc];
    timing.tREFPDENc = tt_timesets[ts][itREFPDENc];
    timing.tMRSPDENc = timing.tMODc;
    timing.tMRSPDEN = tt_timesets[ts][itMOD];
    // Initialization timing.
    timing.tPWRUP = 100000;
    timing.tRESET = 100000; // Stable power @100ns ramp @200us.
    timing.tRESETCKE = 100000; // Spec is 500us.
    timing.tODTHc = 4;
    timing.tZQinitc = tt_timesets[ts][itZQinitc];
    timing.tZQoperc = tt_timesets[ts][itZQoperc];
    timing.tZQCSc = tt_timesets[ts][itZQCSc];
    // Write leveling.
    timing.tWLMRDc = 40;
    timing.tWLDQSENc = 25;
    timing.tWLS = tt_timesets[ts][itWLS];
    timing.tWLSc = ParamInClks(tt_timesets[ts][itWLS], tt_timesets[ts][itCK_min]);
    timing.tWLH = tt_timesets[ts][itWLH];
    timing.tWLHc = ParamInClks(tt_timesets[ts][itWLH], tt_timesets[ts][itCK_min]);
    timing.tWLO_min = 0;
    timing.tWLOc_min = 0;
    timing.tWLO_max = 7500;
    timing.tWLOc_max = ParamInClks(timing.tWLO_max, tt_timesets[ts][itCK_min]);
    timing.tWLOE_min = 0;
    timing.tWLOEc_min = 0;
    timing.tWLOE_max = 2000;
    timing.tWLOEc_max = ParamInClks(timing.tWLOE_max, tt_timesets[ts][itCK_min]);
    timing.tWLO_nominal = (timing.tWLO_min + timing.tWLO_max)/2;
    timing.tWLOE_nominal = (timing.tWLOE_min + timing.tWLOE_max)/2;
    // ODT Timing.
    timing.tAON = 0;
    timing.tAON_min = tt_timesets[ts][itAON_min];
    timing.tAON_max = tt_timesets[ts][itAON_max];
    timing.tAOF = 0;
    timing.tAOFp = 50;
    timing.tAOFp_min = 30;
    timing.tAOFp_max = 70;
    timing.tADCp = 50;
    timing.tADCp_min = 30;
    timing.tADCp_max = 70;
    timing.tAONPD = 5000;
    timing.tAONPDc = 5000/tt_timesets[ts][itCK_min]; // Do not round ntCK up.
    timing.tAONPD_min = 1000;
    timing.tAONPD_max = 10000;
    timing.tAOFPD = 5000;
    timing.tAOFPDc = 5000/tt_timesets[ts][itCK_min]; // Do not round ntCK up.
    timing.tAOFPD_min = 1000;
    timing.tAOFPD_max = 10000;
    timing.tAOFASp = 50; // Async time for ODT forced off (read).
    timing.tAONASp_max = 20; // Async ODT turn on/off.
    // Read preamble training.
    timing.tSDO_max = timing.tMOD + 9000;
    timing.tSDOc_max = ParamInClks(timing.tSDO_max, tt_timesets[ts][itCK_min]);
    timing.tSDO = 7000;
    timing.tSDOc = ParamInClks(timing.tSDO, tt_timesets[ts][itCK_min]);
    // Gear down setup.
    timing.tSYNC_GEARc = (0 == (timing.tMODc % 2)) ? timing.tMODc + 4 : timing.tMODc + 5;
    timing.tCMD_GEARc = (0 == (timing.tMODc % 2)) ? timing.tMODc : timing.tMODc + 1;
    timing.tGD_TRANSITIONc = MAX_WL;
    // Maximum power saving setup.
    timing.tMPED = timing.tMOD + timing.tCPDEDc*timing.tCK;
    timing.tCKMPE = timing.tMOD + timing.tCPDEDc*timing.tCK;
    timing.tCKMPX = timing.tCKSRX;
    timing.tMPX_H = 2*timing.tCK;
    timing.tMPEDc = timing.tMODc + timing.tCPDEDc;
    timing.tCKMPEc = timing.tMODc + timing.tCPDEDc;
    timing.tCKMPXc = timing.tCKSRXc;
    timing.tXMPc = timing.tXSc;
    timing.tXMPDLLc = timing.tXMPc + timing.tXSDLLc;
    // CAL setup.
    timing.tCAL_min = 3750;
    timing.tCALc_min = ParamInClks(timing.tCAL_min, tt_timesets[ts][itCK_min]);
    // Boundary scan.
    timing.tBSCAN_Enable = 100000;
    timing.tBSCAN_Valid = 20000;
    timing.tBSCAN_Valid = 7000; // Tighter than spec.
    // Per project settings.
    timing.tWLO_project = 6300;
endtask
    
task LoadTiming();
    $display("Loading timesets for '%m' @%0t", $time);
    // All timesets initialize to UNLOADED.
    for (int i=0;i<NUM_TS;i++) begin
        tt_timesets[i][TS_LOADED] = 0;
    end
    // DDR4_                   1066    1333      1600     1866   2133   2400    2667    2934    3200    250   
    // UTYPE_TS             TS_1875 TS_1500   TS_1250  TS_1072 TS_938 TS_833  TS_750  TS_682  TS_625  DLL_OFF 
    //          tParam      ------- -------   -------  ------- ------ ------  ------  ------  ------  ------  
    SetTSArray (TS_LOADED,       1,      1,        1,       1,     1,     1,      1,      1,      1,      1 );
    SetTSArray (itCK_min,     1875,   1500,     1250,    1072,   938,   833,    750,    682,    625,   8000 );
    SetTSArray (itCK_max,     1875,   1500,     1250,    1072,   938,   833,    750,    682,    625,   8000 );
    SetTSArray (itDQSQ,          0,      0,        0,       0,     0,     0,      0,      0,      0,      0 );
    SetTSArray (itDS,          125,    125,      125,     125,   125,   125,    125,    125,    125,    125 );
    SetTSArray (itDH,          125,    125,      125,     125,   125,   125,    125,    125,    125,    125 );
    SetTSArray (itIPW,         938,    750,      560,     535,   470,   416,    375,    341,    312,    938 );
    SetTSArray (itDQSCK,         0,      0,        0,       0,     0,     0,      0,      0,      0,      0 );
    SetTSArray (itDQSCK_min,  -375,   -300,     -225,    -195,  -180,  -166,   -150,   -136,   -125,   -375 );
    SetTSArray (itDQSCK_max,   375,    300,      225,     195,   180,   166,    150,    136,    125,    375 );
    SetTSArray (itDLLKc_min,   512,    512,      512,     512,   512,   512,    512,    512,    512,    512 );
    SetTSArray (itRTP,        7500,   7500,     7500,    7500,  7500,  7500,   7500,   6000,   6000,   7500 );
    SetTSArray (itWTRc_S,        2,      2,        2,       2,     2,     2,      2,      2,      2,      2 );
    SetTSArray (itWTRc_L,        4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itWTR_S,      2500,   2500,     2500,    2500,  2500,  2500,   2500,   2500,   2500,   2500 );
    SetTSArray (itWTR_L,      7500,   7500,     7500,    7500,  7500,  7500,   7500,   7500,   7500,   7500 );
    SetTSArray (itWTRc_S_CRC_DM, 5,      5,        5,       5,     5,     5,      5,      6,      6,      5 );
    SetTSArray (itWTRc_L_CRC_DM, 5,      5,        5,       5,     5,     5,      5,      6,      6,      5 );
    SetTSArray (itWR,        15000,  15000,    15000,   15000, 15000, 15000,  15000,  15000,  15000,  15000 );
    SetTSArray (itMOD,       45000,  36000,    30000,   25728, 22512, 20000,  18000,  16368,  15000,  45000 );
    SetTSArray (itRCD,       17000,  16000,    15000,   15000, 13130, 12500,  12500,  12500,  12500,  17000 );
    SetTSArray (itRC,        56000,  55000,    50000,   49000, 46130, 44500,  44500,  44500,  44500,  56000 );
    SetTSArray (itRP,        17000,  16000,    15000,   15000, 13130, 12500,  12500,  12500,  12500,  17000 );
    SetTSArray (itRP_ref,    30000,  30000,    30000,   30000, 30000, 30000,  30000,  30000,  30000,  30000 );
    SetTSArray (itCCD_L,      6250,   6250,      6250,   5355,  5355,  5000,   5000,   5000,   5000,   6250 );
    SetTSArray (itCCDc_S,        4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itCCDc_L,        5,      5,        5,       5,     5,     5,      5,      5,      5,      5 );
    SetTSArray (itRAS,       39000,  39000,    35000,   34000, 33000, 32000,  32000,  32000,  32000,  39000 );
    SetTSArray (itRRDc_S_512,    4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itRRDc_S_1k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itRRDc_S_2k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itRRDc_L_512,    4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itRRDc_L_1k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itRRDc_L_2k,     4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itRRD_S_512,  7500,   6000,     5000,    4200,  3700,  3300,   3300,   3300,   3300,   7500 );
    SetTSArray (itRRD_S_1k,   7500,   6000,     5000,    4200,  3700,  3300,   3300,   3300,   3300,   7500 );
    SetTSArray (itRRD_S_2k,   7500,   6000,     6000,    5300,  5300,  5300,   5300,   5300,   5300,   7500 );
    SetTSArray (itRRD_L_512,  7500,   6000,     6000,    5300,  5300,  4900,   4900,   4900,   4900,   7500 );
    SetTSArray (itRRD_L_1k,   7500,   6000,     6000,    5300,  5300,  4900,   4900,   4900,   4900,   7500 );
    SetTSArray (itRRD_L_2k,   7500,   7500,     7500,    6400,  6400,  6400,   6400,   6400,   6400,   7500 );
    SetTSArray (itFAW_512,   20000,  20000,    20000,   17000, 15000, 13000,  13000,  13000,  13000,  20000 );
    SetTSArray (itFAW_1k,    25000,  25000,    25000,   23000, 21000, 21000,  21000,  21000,  21000,  25000 );
    SetTSArray (itFAW_2k,    35000,  35000,    35000,   30000, 30000, 30000,  30000,  30000,  30000,  35000 );
    SetTSArray (itIS,          170,    170,      170,     170,   170,   170,    170,    170,    170,    170 );
    SetTSArray (itIH,          120,    120,      120,     120,   120,   120,    120,    120,    120,    120 );
    SetTSArray (itDIPW,        560,    450,      360,     320,   280,   250,    230,    200,    190,    560 );
    SetTSArray (itCKE,        5625,   5000,     5000,    5000,  5000,  5000,   5000,   5000,   5000,   5625 );
    SetTSArray (itCPDEDc,        4,      4,        4,       4,     4,     4,      4,      4,      4,      4 );
    SetTSArray (itXP,         7500,   6000,     6000,    6000,  6000,  6000,   6000,   6000,   6000,   7500 );
    SetTSArray (itXPDLL,     24000,  24000,    24000,   24000, 24000, 24000,  24000,  24000,  24000,  24000 );
    SetTSArray (itACTPDENc,      0,      0,        0,       0,     1,     1,      1,      1,      1,      0 );
    SetTSArray (itPREPDENc,      0,      0,        0,       0,     1,     1,      1,      1,      1,      0 );
    SetTSArray (itREFPDENc,      0,      0,        0,       0,     1,     1,      1,      1,      1,      0 );
    SetTSArray (itZQinitc,    1024,   1024,     1024,    1024,  1024,  1024,   1024,   1024,   1024,   1024 );
    SetTSArray (itZQoperc,     512,    512,      512,     512,   512,   512,    512,    512,    512,    512 );
    SetTSArray (itZQCSc,       128,    128,      128,     128,   128,   128,    128,    128,    128,    128 );
    SetTSArray (itWLS,         244,    195,      163,     140,   122,   109,     98,     89,     82,    244 );
    SetTSArray (itWLH,         244,    195,      163,     140,   122,   109,     98,     89,     82,    244 );
    SetTSArray (itAON_min,    -225,   -225,     -225,    -195,  -180,  -180,   -180,   -180,   -180,   -225 );
    SetTSArray (itAON_max,     225,    225,      225,     195,   180,   180,    180,    180,    180,    225 );
    SetTSArray (itPAR_ALERT_PWc, 48,    47,       72,      84,    96,   108,    108,    108,    108,     48 );
    SetTSArray (itPAR_ALERT_PWc_min,32, 40,       48,      56,    64,    72,     72,     72,     72,     32 );
    SetTSArray (itPAR_ALERT_PWc_max,80,100,       96,     112,   128,   144,    160,    176,    192,     80 );
    for (UTYPE_TS ts=ts.first();ts<ts.last();ts=ts.next()) begin
        if (1 == tt_timesets[ts][TS_LOADED]) begin
            if (tt_timesets[ts][itCK_min] < min_tCK)
                min_tCK = tt_timesets[ts][itCK_min];
            if (tt_timesets[ts][itCK_max] > max_tCK)
                max_tCK = tt_timesets[ts][itCK_max];
            $display("\tLoaded timeset:%0s", ts.name());
        end else begin
            $display("\tTimeset:%0s was not loaded.", ts.name());
        end
    end
endtask
    
task SetTSArray(UTYPE_time_spec spec, int ts_1875, int ts_1500, int ts_1250, int ts_1072, 
                int ts_938, int ts_833, int ts_750, int ts_682, int ts_625, int dll_off);
    tt_timesets[TS_1875][spec] = ts_1875;
    tt_timesets[TS_1500][spec] = ts_1500;
    tt_timesets[TS_1250][spec] = ts_1250;
    tt_timesets[TS_1072][spec] = ts_1072;
    tt_timesets[TS_938][spec] = ts_938;
    tt_timesets[TS_833][spec] = ts_833;
    tt_timesets[TS_750][spec] = ts_750;
    tt_timesets[TS_682][spec] = ts_682;
    tt_timesets[TS_625][spec] = ts_625;
    tt_timesets[DLL_OFF][spec] = dll_off;
endtask

function bit FindTimesetCeiling(int tck, output UTYPE_TS new_ts);
    int ps_cushion;
    ps_cushion = 100000000; // Absolute max tCK.
    for (UTYPE_TS ts=ts.first();ts<ts.last();ts=ts.next()) begin
        if ((1 == tt_timesets[ts][TS_LOADED]) && (tck <= tt_timesets[ts][itCK_min])) begin
            if ((tt_timesets[ts][itCK_max] - tck) < ps_cushion) begin
                new_ts = ts;
                ps_cushion = tt_timesets[ts][itCK_max] - tck;
            end
        end
    end
    if (ps_cushion != 100000000)
        return 1;
    else
        return 0;
endfunction

function int ParamInClks(int param_in_ps, int tCK_in_ps);
    if (0 == (param_in_ps % tCK_in_ps))
        return (param_in_ps / tCK_in_ps);
    else
        return ((param_in_ps / tCK_in_ps) + 1);
endfunction

function int GetTimesetValue(UTYPE_time_spec spec, UTYPE_TS ts=timing.ts_loaded);
    return tt_timesets[ts][spec];
endfunction

