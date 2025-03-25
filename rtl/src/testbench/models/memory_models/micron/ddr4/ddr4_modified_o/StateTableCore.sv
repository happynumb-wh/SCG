UTYPE_DutModeConfig s_dut_mode_config;
DDR4_cmd s_latched_cmd, _last_data_cmd;

string _id;
bit _debug;
bit[2047:0] _debug_parity_alert_width;
UTYPE_TimingParameters _timing;
UTYPE_dutconfig _dut_config;
int INITCYCLENUM;

// state variables
logic [MAX_ROW_ADDR_BITS-1:0] _open_row_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
logic _open_banks[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
bit _in_self_refresh, _in_active_pd, _in_precharge_pd;
bit _in_max_power_save, _max_power_save_exit_cs;
bit _delayed_precharge;
int _delayed_precharge_rank, _delayed_precharge_bank, _delayed_precharge_group;
int _delayed_lmr_cycles[$];
UTYPE_DutModeConfig _delayed_lmr_mode_configs[$];
DDR4_cmd _delayed_lmr_pkts[$];
longint rank_by_bank[longint];
bit _dynamic_fast_self_refresh;

// cycle check variables
int _cRD_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0], _cRDA_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
int _cWR_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0], _cWRA_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
int _cACT_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
longint _tACT_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0], _tACT_by_group[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0], _tACT_any_bank;
int _cAP_delay_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0], _cPRE_by_bank[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
int _cRD_by_group[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0], _cWR_by_group[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0], _cACT_by_group[MAX_RANKS-1:0][MAX_BANK_GROUPS-1:0];
int _cRD_any_bank, _cRDA_any_bank, _cWR_any_bank, _cWRA_any_bank, _cPRE_any_bank, _cACT_any_bank;
int _cRD_mpr, _cWR_mpr, _RD_mpr_page;
int _clast_data_cmd, _clast_last_data_cmd;
int _cLMR_any_bank, _cLMR_ignored, _cLMR_extend_tMRD;
int _cZQ_any, _cZQCL_init, _cZQCL, _cZQCS;
int _cREF_any_rank, _cREF_by_rank[MAX_RANKS-1:0], _cREF_fly_by_rank[MAX_RANKS-1:0];
int _cPREA, _cBST, _cNOCLK, _cSREFE, _cSREFX, _cPDX, _cPPDE, _cAPDE, _cMPS_entry, _cMPS_exit;
bit _vrefDQ_at_PDX, _last_PDE_active;
int _cFAWs[$:FAW_DEPTH];
int _cODT_high, _cODT_low;
bit _ODT_tMOD_transition;
bit _ODT_last_transition, _ODT_sync, _ODT_enter_transition, _ODT_exit_transition;
int _cpreamble_training, _cpreamble_training_exit;
int _cTRR_enter, _cTRR_exit, _TRR_precharges;
longint _tSREFE, _tSREFX, _tPDX, _tPPDE, _tAPDE, _tREF_any_bank;
longint _tparity_error_begin, _tparity_block_commands_on, _tparity_block_commands_off;
longint _tpreamble_training_entry, _tpreamble_training_exit;
bit _parity_block_commands;
int _parity_off;

logic [MAX_ADDR_BITS-1:0] _LMR_cache[MAX_BANK_GROUPS-1:0][MAX_BANKS_PER_GROUP-1:0];
logic [MPR_DATA_BITS-1:0] _MPR_pattern[MAX_MPR_PATTERNS];
logic [MPR_DATA_BITS-1:0] _MPR_default_pattern[MAX_MPR_PATTERNS];
logic [MPR_DATA_BITS-1:0] _MPR_temp[MAX_MPR_TEMPS];
logic [MPR_DATA_BITS-1:0] _MPR_error_log[MAX_MPR_PATTERNS];
logic[MPR_DATA_BITS*MAX_MPR_PATTERNS-1:0] _debug_MPR_error_log;
int _temp_sensor_value, _temp_sensor_range;

int _current_cycle;
int _cDLL_reset, _ctCK_change, _cCAL_change;
bit _last_DLL_state;
bit _gear_down_reset;
int _cGeardown_sync, _cGeardown_toggle;
int _added_cycle;

function int RequiredNops(DDR4_cmd cmdpkt, inout string spec_string);
    int WL, CWL, WR, rd_BL, wr_BL, RL, AL, CAL, BL, PL, dynamic_tRFCc, dynamic_tRFC, dynamic_tRFCc_dlr, dynamic_tRFC_dlr;
    int rl_to_wl, wl_to_rl, write_crc_dm, precharge_wr_bl;
    int cACT_this_bank, cPRE_this_bank;
    int cRD_this_bank, cRDA_this_bank, cWR_this_bank, cWRA_this_bank;
    int nops[$], max_nop;
    
    max_nop = 0;
    if (1 == PendingLMR()) begin
        UTYPE_DutModeConfig new_mode_config;
        
        new_mode_config = _delayed_lmr_mode_configs[0];
        RL = new_mode_config.RL - new_mode_config.CA_parity_latency;
        WR = new_mode_config.write_recovery;
        AL = new_mode_config.AL;
        WL = new_mode_config.WL_calculated - new_mode_config.CA_parity_latency;
        CWL = new_mode_config.CWL;
        CAL = new_mode_config.CAL;
        BL = new_mode_config.BL;
        PL = new_mode_config.CA_parity_latency;
    end else begin
        RL = s_dut_mode_config.RL - s_dut_mode_config.CA_parity_latency;
        WR = s_dut_mode_config.write_recovery;
        AL = s_dut_mode_config.AL;
        WL = s_dut_mode_config.WL_calculated - s_dut_mode_config.CA_parity_latency;
        CWL = s_dut_mode_config.CWL;
        CAL = s_dut_mode_config.CAL;
        BL = s_dut_mode_config.BL;
        PL = s_dut_mode_config.CA_parity_latency;
    end
    rl_to_wl = RL - WL;
    wl_to_rl = WL - RL;
    rd_BL = BL;
    if (1 == s_dut_mode_config.write_crc_enable) begin
        wr_BL = BL + MAX_CRC_TRANSFERS;
        // tWR is measured from last burst of data. wr_BL/precharge_wr_bl both contain the CRC burst.
        // Account for this in one or the other, not both.
        if (1 == s_dut_mode_config.dm_enable) begin
            if ((rBL4 == s_dut_mode_config.BL_reg) && (8 == BL))
                write_crc_dm = _timing.tWR_CRC_DMc - 3;
            else
                write_crc_dm = _timing.tWR_CRC_DMc - 1;
        end else begin
            write_crc_dm = 0;
            if ((rBL4 == s_dut_mode_config.BL_reg) && (8 == BL))
                WR = WR - 3; // tWR starts after the data burst (before the '1 part of CRC).
            else
                WR = WR - 1;
        end
    end else begin
        wr_BL = BL;
        write_crc_dm = 0;
    end
    GetDynamictRFC(cmdpkt.rank, dynamic_tRFC, dynamic_tRFCc, dynamic_tRFC_dlr, dynamic_tRFCc_dlr);
    precharge_wr_bl = PrechargeWriteBL(wr_BL);
    // cmdpkt can have rank,bg,ba bits that should be ignored, so make the data valid based on the DUT's current configuration.
    cmdpkt.rank = cmdpkt.rank & _dut_config.rank_mask;
    cmdpkt.bank_group = cmdpkt.bank_group & _dut_config.bank_group_mask;
    cmdpkt.bank = cmdpkt.bank & _dut_config.bank_mask;
    cACT_this_bank = _cACT_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank];
    cPRE_this_bank = _cPRE_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank];
    cRD_this_bank = _cRD_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank];
    cRDA_this_bank = _cRDA_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank];
    cWR_this_bank = _cWR_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank];
    cWRA_this_bank = _cWRA_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank];

    $sformat(spec_string, "%0s BG:%0h B:%0h A:%0h (BL:%0d WL:%0d RL:%0d) @%0t Required:", 
            cmdpkt.cmd.name(), cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, rd_BL, WL, RL, $time);
    if ((cmdpkt.cmd != cmdNOP) && (cmdpkt.cmd != cmdNOCLK) && (cmdpkt.cmd != cmdDES) &&
        (cmdpkt.cmd != cmdSREFX) && (cmdpkt.cmd != cmdPDX)) begin
        if(_cSREFE > _cSREFX)
            nops.push_back(CheckClockSpec(_cSREFX + TimeToClocks(cmdpkt.tCK, _timing.tXSR) + CAL - _current_cycle, "tXSR + CAL", spec_string));
        if ((0 == OpenBanks()) && (cmdLMR != cmdpkt.cmd)) begin
            nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
            nops.push_back(CheckClockSpec(_cLMR_ignored + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
            nops.push_back(CheckClockSpec(_cGeardown_sync + _timing.tMODc - _current_cycle, "tCMD_GEAR", spec_string));
        end
        if ((cmdLMR != cmdpkt.cmd) && (cmdZQ != cmdpkt.cmd))
            nops.push_back(CheckClockSpec(_cDLL_reset + _timing.tDLLKc - _current_cycle, "tDLLKc", spec_string));
        nops.push_back(CheckClockSpec(_cZQCL_init + _timing.tZQinitc - _current_cycle, "tZQinit", spec_string));
        nops.push_back(CheckClockSpec(_cZQCL + _timing.tZQoperc - _current_cycle, "tZQoper", spec_string));
        nops.push_back(CheckClockSpec(_cZQCS + _timing.tZQCSc - _current_cycle, "tZQCS", spec_string));
        // tXSDLLc/tXPDLLc is for cmds that do require a locked DLL.
        if ((cmdRD == cmdpkt.cmd) || (cmdRDA == cmdpkt.cmd)) begin
            if (s_dut_mode_config.DLL_enable) begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSDLLc + CAL + PL - _current_cycle, "tXSDLL + CAL + PL", spec_string));
            end else begin
                if (_dynamic_fast_self_refresh) begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc + CAL + PL - _current_cycle, "tXSFast + CAL + PL", spec_string));
                end else begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc + CAL + PL - _current_cycle, "tXSc + CAL + PL",  spec_string));
                end
            end
            nops.push_back(CheckClockSpec(_cPDX + _timing.tXPc + CAL + PL - _current_cycle, "tXPc + CAL + PL", spec_string));
            nops.push_back(CheckClockSpec(_cMPS_exit + _timing.tXMPDLLc - _current_cycle, "tXMPDLL", spec_string));
        end else if ((cmdWR == cmdpkt.cmd) || (cmdWRA == cmdpkt.cmd)) begin
            if (1 == ODTDynamicEnabled()) begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSDLLc + CAL + PL - _current_cycle, "tXSDLL + CAL + PL", spec_string));
                nops.push_back(CheckClockSpec(_cPDX + _timing.tXPc + CAL + PL - _current_cycle, "tXPc + CAL + PL", spec_string));
                nops.push_back(CheckClockSpec(_cMPS_exit + _timing.tXMPDLLc - _current_cycle, "tXMPDLL", spec_string));
            end else begin
                if (_dynamic_fast_self_refresh) begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc + CAL + PL - _current_cycle, "tXSFast + CAL + PL", spec_string));
                end else begin
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc + CAL + PL - _current_cycle, "tXSc + CAL + PL", spec_string));
                end
                nops.push_back(CheckClockSpec(_cPDX + _timing.tXPc + CAL + PL - _current_cycle, "tXPc + CAL + PL", spec_string));
                nops.push_back(CheckClockSpec(_cMPS_exit + _timing.tXMPc - _current_cycle, "tXMP", spec_string));
            end
        end else begin
            if (_cPDX > 0) begin
                longint tXP_64bit;
                
                tXP_64bit = _tPDX + _timing.tXP - $time;
                nops.push_back(CheckTimeSpec(tXP_64bit, cmdpkt.tCK, "tXP", spec_string));
                nops.push_back(CheckClockSpec(_cPDX + _timing.tXPc + CAL + PL - _current_cycle, "tXP + CAL + PL", spec_string));
            end
            if (_cSREFX > 0) begin
                longint tXS_64bit, tXS_Fast_64bit;
                
                tXS_64bit = _tSREFX + _timing.tXS - $time;
                tXS_Fast_64bit = _tSREFX + _timing.tXS_Fast - $time;
                if ((cmdZQ == cmdpkt.cmd) || (1 == tXSFastLMR(cmdpkt)) || _dynamic_fast_self_refresh) begin
                    nops.push_back(CheckTimeSpec(tXS_Fast_64bit, cmdpkt.tCK, "tXS_Fast", spec_string));
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc + CAL + PL - _current_cycle, "tXS_Fast + CAL + PL", spec_string));
                end else begin
                    nops.push_back(CheckTimeSpec(tXS_64bit, cmdpkt.tCK, "tXS", spec_string));
                    nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc + CAL + PL - _current_cycle, "tXS + CAL + PL", spec_string));
                end
            end
            if (_cMPS_exit > 0) begin
                nops.push_back(CheckClockSpec(_cMPS_exit + _timing.tXMPc - _current_cycle, "tXMP", spec_string));
            end
        end
    end
    case (cmdpkt.cmd)
    cmdACT: begin
        nops.push_back(CheckClockSpec(_cREF_by_rank[cmdpkt.rank] + dynamic_tRFCc - _current_cycle, "tRFC", spec_string));
        if (_dut_config.ranks > 1) begin
            for (int rank=0;rank<_dut_config.ranks;rank++)
                nops.push_back(CheckClockSpec(_cREF_by_rank[rank] + dynamic_tRFCc_dlr - _current_cycle, "tRFC_dlr", spec_string));
        end
        nops.push_back(CheckClockSpec(_cPREA + _timing.tRPc - _current_cycle, "tRP", spec_string));
        nops.push_back(CheckClockSpec(cPRE_this_bank + _timing.tRPc - _current_cycle, "tRP", spec_string));
        nops.push_back(CheckClockSpec(cACT_this_bank + _timing.tRASc + _timing.tRPc - _current_cycle, "tRAS + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cFAWs[FAW_DEPTH-1] + TimeToClocks(cmdpkt.tCK, _timing.tFAW) - _current_cycle, "tFAW", spec_string));
        nops.push_back(CheckClockSpec(cRDA_this_bank + RL + rd_BL/2 - _current_cycle, "RL + BL/2", spec_string));
        nops.push_back(CheckClockSpec(cRDA_this_bank + AL + _timing.tRTPc + _timing.tRPc - _current_cycle, "AL+tRTP+tRP", spec_string));
        nops.push_back(CheckClockSpec(cWRA_this_bank + WL + precharge_wr_bl/2 + WR + _timing.tRPc + write_crc_dm - 
                                        _current_cycle, "WL + BL/2 + WR + tRP", spec_string));
        for (int rank=0;rank<_dut_config.ranks;rank++) begin
            if (rank == cmdpkt.rank) begin
                for (int group=0;group<MAX_BANK_GROUPS;group++) begin
                    if (cmdpkt.bank_group == group) begin
                        nops.push_back(CheckClockSpec(_cACT_by_group[cmdpkt.rank][group] + _timing.tRRDc_L - _current_cycle, "tRRDc_L", spec_string));
                        nops.push_back(CheckTimeSpec(_tACT_by_group[cmdpkt.rank][group] + _timing.tRRD_L - $time, cmdpkt.tCK, "tRRD_L", spec_string));
                    end else begin
                        nops.push_back(CheckClockSpec(_cACT_by_group[cmdpkt.rank][group] + _timing.tRRDc_S - _current_cycle, "tRRDc_S", spec_string));
                        nops.push_back(CheckTimeSpec(_tACT_by_group[cmdpkt.rank][group] + _timing.tRRD_S - $time, cmdpkt.tCK, "tRRD_S", spec_string));
                    end
                end
            end else begin
                nops.push_back(CheckClockSpec(_cACT_any_bank + _timing.tRRDc_dlr - _current_cycle, "tRRD_dlr", spec_string));
                nops.push_back(CheckClockSpec(_cFAWs[FAW_DEPTH-1] + _timing.tFAWc_dlr - _current_cycle, "tFAW_dlr", spec_string));
            end
        end
        if((_cAP_delay_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] > 0) && 0) begin
            nops.push_back(CheckClockSpec(cRDA_this_bank + _cAP_delay_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] - _current_cycle, "tAPDELAY", spec_string));
            nops.push_back(CheckClockSpec(cWRA_this_bank + _cAP_delay_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] - _current_cycle, "tAPDELAY", spec_string));
        end
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
        nops.push_back(CheckClockSpec(cWR_this_bank + WL + wr_BL/2 + WR + write_crc_dm - _current_cycle, "WL + BL/2 + WR", spec_string));
        nops.push_back(CheckClockSpec(cRD_this_bank + RL + rd_BL/2 - _current_cycle, "RL + BL/2", spec_string));
    end
    
    cmdPRE: begin
        nops.push_back(CheckClockSpec(cACT_this_bank + _timing.tRASc - _current_cycle, "tRAS", spec_string));
        nops.push_back(CheckClockSpec(cWR_this_bank + WL+precharge_wr_bl/2 + WR + write_crc_dm - _current_cycle, "tWR (WL + BL/2 + WR)", spec_string));
        nops.push_back(CheckClockSpec(cRD_this_bank + _timing.tRTPc + AL - _current_cycle, "tRTP + AL", spec_string));
        nops.push_back(CheckClockSpec(cRD_this_bank + 2 - _current_cycle, "tMIN2", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
        nops.push_back(CheckClockSpec(cRDA_this_bank + _timing.tRTPc + AL - _current_cycle, "tRTP + AL", spec_string));
        nops.push_back(CheckClockSpec(cWRA_this_bank + WL+precharge_wr_bl/2+WR + write_crc_dm - _current_cycle, "tWR (WL + BL/2 + WR)", spec_string));
        nops.push_back(CheckClockSpec(_cREF_by_rank[cmdpkt.rank] + dynamic_tRFCc - _current_cycle, "tRFC", spec_string));
        if (_dut_config.ranks > 1) begin
            for (int rank=0;rank<_dut_config.ranks;rank++)
                nops.push_back(CheckClockSpec(_cREF_by_rank[rank] + dynamic_tRFCc_dlr - _current_cycle, "tRFC_dlr", spec_string));
        end
    end

    cmdPREA: begin
        nops.push_back(CheckClockSpec(_cREF_by_rank[cmdpkt.rank] + dynamic_tRFCc - _current_cycle, "tRFC", spec_string));
        if (_dut_config.ranks > 1) begin
            for (int rank=0;rank<_dut_config.ranks;rank++)
                nops.push_back(CheckClockSpec(_cREF_by_rank[rank] + dynamic_tRFCc_dlr - _current_cycle, "tRFC_dlr", spec_string));
        end
        for (int rank=0;rank<MAX_RANKS;rank++) begin
            for (int group=0;group<MAX_BANK_GROUPS;group++) begin
                for (int bank=0;bank<MAX_BANKS_PER_GROUP;bank++) begin
                    nops.push_back(CheckClockSpec(_cACT_by_bank[rank][group][bank] + _timing.tRASc - _current_cycle, "tRAS", spec_string));
                    nops.push_back(CheckClockSpec(_cWR_by_bank[rank][group][bank] + WL+precharge_wr_bl/2 + WR + write_crc_dm - _current_cycle, 
                                                "tWRBURST (WL + BL/2 + WR)", spec_string));
                    nops.push_back(CheckClockSpec(_cRD_by_bank[rank][group][bank] + _timing.tRTPc + AL - _current_cycle, "tRTP + AL", spec_string)); 
                    nops.push_back(CheckClockSpec(_cRD_by_bank[rank][group][bank] + 2 - _current_cycle, "tMIN2", spec_string));
                end
            end
        end
        nops.push_back(CheckClockSpec(_cRDA_any_bank + _timing.tRTPc + AL - _current_cycle, "tRTP + AL", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + WL+precharge_wr_bl/2+WR + write_crc_dm - _current_cycle, 
                                      "tWR (WL + BL/2 + WR)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
    end

    cmdWR, cmdWRA: begin
        if (_timing.tRCDc - AL < 1)
            nops.push_back(CheckClockSpec(cACT_this_bank + 1 - _current_cycle, "tRCD-AL", spec_string));
        else
            nops.push_back(CheckClockSpec(cACT_this_bank + (_timing.tRCDc - AL) - _current_cycle, "tRCD-AL", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + TimeToClocks(cmdpkt.tCK, _timing.tDQSCK_max) - _current_cycle, "tDQSCKmax", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + TimeToClocks(cmdpkt.tCK, _timing.tDQSCK_max) - _current_cycle, "tDQSCKmax", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + 4 - _current_cycle, "tCCD min (4)", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + 4 - _current_cycle, "tCCD min (4)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_any_bank + wr_BL/2 - _current_cycle, "tWRBURST", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + wr_BL/2 - _current_cycle, "tWRABURST", spec_string));
        for (int rank=0;rank<MAX_RANKS;rank++) begin
            for (int group=0;group<MAX_BANK_GROUPS;group++) begin
                if (cmdpkt.bank_group == group) begin
                    int tCCDc_max;
                    tCCDc_max = FindMax(TimeToClocks(cmdpkt.tCK, _timing.tCCD_L), _timing.tCCDc_L);
                    nops.push_back(CheckClockSpec(_cRD_by_group[rank][group] + rl_to_wl + s_dut_mode_config.wr_preamble_clocks + rd_BL/2 + 1
                                                  - _current_cycle, "(RL + BL/2 - WL + wr_preamble_clocks + 1)", spec_string));
                    nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + tCCDc_max - _current_cycle, "tCCD_L (WR)", spec_string));
                end else begin
                    nops.push_back(CheckClockSpec(_cRD_by_group[rank][group] + rl_to_wl + s_dut_mode_config.wr_preamble_clocks + rd_BL/2 + 1
                                                  - _current_cycle, "(RL + BL/2 - WL + wr_preamble_clocks + 1)", spec_string));
                    nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + _timing.tCCDc_S - _current_cycle, "tCCD_S (WR)", spec_string));
                end
            end
        end
        if (0 == OpenBank(.rank(cmdpkt.rank), .bg(cmdpkt.bank_group), .ba(cmdpkt.bank))) begin
            nops.push_back(CheckClockSpec(_cPREA + _timing.tRPc - _current_cycle, "tRP", spec_string));
            nops.push_back(CheckClockSpec(cPRE_this_bank + _timing.tRPc - _current_cycle, "tRP", spec_string));
        end
        nops.push_back(CheckClockSpec(cWRA_this_bank + WL+wr_BL/2+WR - _current_cycle, "tWRABURST (WL + BL/2 + WR)", spec_string));
        nops.push_back(CheckClockSpec(cRDA_this_bank + RL+rd_BL/2 - _current_cycle, "tRDABURST (RL + BL/2)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
        if (1 == ODTDynamicEnabled()) begin
        nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, "tDLLKc",  spec_string));
        end
        nops.push_back(CheckClockSpec(_cWR_mpr + _timing.tWR_MPRc - _current_cycle, "MPR(WR) tWR_MPR", spec_string));
        nops.push_back(CheckClockSpec(_cRD_mpr + RL + BL/2 + _timing.tMPRRc - _current_cycle, "MPR(RD) RL + BL/2 + tMPRR", spec_string));
        if (1 == InMPRAccess()) begin
            nops.push_back(CheckClockSpec(_cREF_by_rank[cmdpkt.rank] + dynamic_tRFCc - _current_cycle, "tRFC (mpr)", spec_string));
            if (_dut_config.ranks > 1) begin
                for (int rank=0;rank<_dut_config.ranks;rank++)
                    nops.push_back(CheckClockSpec(_cREF_by_rank[rank] + dynamic_tRFCc_dlr - _current_cycle, "tRFC_dlr (mpr)", spec_string));
            end
        end
    end

    cmdRD, cmdRDA: begin
        if (_timing.tRCDc - AL < 1)
            nops.push_back(CheckClockSpec(cACT_this_bank + 1 - _current_cycle, "tRCD-AL", spec_string));
        else
            nops.push_back(CheckClockSpec(cACT_this_bank + (_timing.tRCDc - AL) - _current_cycle, "tRCD-AL", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + rd_BL/2 - _current_cycle, "tRDBURST", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + rd_BL/2 - _current_cycle, "tRDABURST", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + wl_to_rl + wr_BL/2 + write_crc_dm - _current_cycle, 
                                      "tWRABURST (WL - RL + BL/2)", spec_string));
        nops.push_back(CheckClockSpec(cWRA_this_bank + WL + wr_BL/2 + WR + _timing.tWTRc_L_CRC_DM - _current_cycle, "tWRABURST (WL + BL/2 + WR + tWTR_L_CRC_DM)", spec_string));
        for (int rank=0;rank<MAX_RANKS;rank++) begin
            for (int group=0;group<MAX_BANK_GROUPS;group++) begin
                if ((cmdpkt.rank == rank) && (cmdpkt.bank_group == group)) begin
                    int tCCDc_max, tWTRc_max;
                    tWTRc_max = FindMax(TimeToClocks(cmdpkt.tCK, _timing.tWTR_L), _timing.tWTRc_L);
                    tCCDc_max = FindMax(TimeToClocks(cmdpkt.tCK, _timing.tCCD_L), _timing.tCCDc_L);
                    if (1 == s_dut_mode_config.write_crc_enable) begin
                        if ((1 != s_dut_mode_config.dm_enable) && (rBL4 == s_dut_mode_config.BL_reg))
                            nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + 2 + tWTRc_max - _current_cycle, 
                                        "tWTR_L (CWL + 2 + tWTRc_L)", spec_string));
                        else if (1 == s_dut_mode_config.dm_enable)
                            nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + BL/2 + tWTRc_max + _timing.tWTRc_L_CRC_DM - _current_cycle, 
                                        "tWTR_L (CWL + 4 + tWTRc_L + tWTR_L_CRC_DM)", spec_string));
                        else
                            nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + BL/2 + tWTRc_max - _current_cycle, 
                                        "tWTR_L (CWL + 4 + tWTRc_L)", spec_string));

                    end else begin
                        nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + precharge_wr_bl/2 + tWTRc_max - _current_cycle, 
                                    "tWTR_L (CWL + BL/2 + tWTRc_L)", spec_string));
                    end
                    nops.push_back(CheckClockSpec(_cRD_by_group[rank][group] + tCCDc_max - _current_cycle, "tCCD_L (RD)", spec_string));
                end else begin
                    int tWTRc_max;
                    tWTRc_max = FindMax(TimeToClocks(cmdpkt.tCK, _timing.tWTR_S), _timing.tWTRc_S);
                    if (1 == s_dut_mode_config.write_crc_enable) begin
                        if ((1 != s_dut_mode_config.dm_enable) && (rBL4 == s_dut_mode_config.BL_reg))
                            nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + 2 + tWTRc_max - _current_cycle, 
                                        "tWTR_S (CWL + 2 + tWTRc_S)", spec_string));
                        else if (1 == s_dut_mode_config.dm_enable)
                            nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + BL/2 + tWTRc_max + _timing.tWTRc_S_CRC_DM - _current_cycle, 
                                        "tWTR_S (CWL + 4 + tWTRc_S + tWTR_S_CRC_DM)", spec_string));
                        else
                            nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + BL/2 + tWTRc_max - _current_cycle, 
                                        "tWTR_S (CWL + 4 + tWTRc_S)", spec_string));
                    end else begin
                        nops.push_back(CheckClockSpec(_cWR_by_group[rank][group] + CWL + precharge_wr_bl/2 + tWTRc_max - _current_cycle, 
                                    "tWTR_S (CWL + BL/2 + tWTRc_S)", spec_string));
                    end
                    nops.push_back(CheckClockSpec(_cRD_by_group[rank][group] + _timing.tCCDc_S - _current_cycle, "tCCD_S (RD)", spec_string));
                end
            end
        end
        if (0 == OpenBank(.rank(cmdpkt.rank), .bg(cmdpkt.bank_group), .ba(cmdpkt.bank))) begin
            nops.push_back(CheckClockSpec(_cPREA + _timing.tRPc - _current_cycle, "tRP", spec_string));
            nops.push_back(CheckClockSpec(cPRE_this_bank + _timing.tRPc - _current_cycle, "tRP", spec_string));
        end
        nops.push_back(CheckClockSpec(cRDA_this_bank + RL+rd_BL/2 - _current_cycle, "tRDABURST (RL + BL/2)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMOD + PL + CAL", spec_string));
        if (s_dut_mode_config.DLL_enable) begin
            nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, "tDLLKc", spec_string));
        end else begin
            if (_dynamic_fast_self_refresh) begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXS_Fastc - _current_cycle, "tXSFast", spec_string));
            end else begin
                nops.push_back(CheckClockSpec(_cSREFX + _timing.tXSc - _current_cycle, "tXSc", spec_string));
            end
        end
        nops.push_back(CheckClockSpec(_cWR_mpr + _timing.tWR_MPRc - _current_cycle, "MPR(WR) tWR_MPR", spec_string));
        if (MPR_PATTERN == _RD_mpr_page)
            if ((2 == s_dut_mode_config.rd_preamble_clocks) && (1 == _timing.tCCDc_S[0]))
                nops.push_back(CheckClockSpec(_cRD_mpr + _timing.tCCDc_S + 1 - _current_cycle, "MPR Page0 (RD) tCCD_S", spec_string));
            else
                nops.push_back(CheckClockSpec(_cRD_mpr + _timing.tCCDc_S - _current_cycle, "MPR Page0 (RD) tCCD_S", spec_string));
        else begin
            if ((2 == s_dut_mode_config.rd_preamble_clocks) && (1 == _timing.tCCDc_L[0]))
                nops.push_back(CheckClockSpec(_cRD_mpr + _timing.tCCDc_L + 1 - _current_cycle, "MPR Page1/2/3 (RD) tCCD_L", spec_string));
            else
                nops.push_back(CheckClockSpec(_cRD_mpr + _timing.tCCDc_L - _current_cycle, "MPR Page1/2/3 (RD) tCCD_L", spec_string));
        end
        if (1 == InMPRAccess()) begin
            nops.push_back(CheckClockSpec(_cREF_by_rank[cmdpkt.rank] + dynamic_tRFCc - _current_cycle, "tRFC (mpr)", spec_string));
            if (_dut_config.ranks > 1) begin
                for (int rank=0;rank<_dut_config.ranks;rank++)
                    nops.push_back(CheckClockSpec(_cREF_by_rank[rank] + dynamic_tRFCc_dlr - _current_cycle, "tRFC_dlr", spec_string));
            end
        end
    end

    cmdLMR: begin
        longint tRFC_64bit;
        
        nops.push_back(CheckClockSpec(_cPREA + _timing.tRPc - _current_cycle, "tRP", spec_string));
        nops.push_back(CheckClockSpec(_cPRE_any_bank + _timing.tRPc - _current_cycle, "tRPc", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + AL + _timing.tRTPc + _timing.tRPc - _current_cycle, "AL + tRTP + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + RL + PL + rd_BL/2 - _current_cycle, "RL + PL + BL/2", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + RL + PL + rd_BL/2 - _current_cycle, "RL + PL + BL/2", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + WL + PL + precharge_wr_bl/2 + WR + _timing.tRPc + write_crc_dm - _current_cycle, "WL + PL + BL/2 + WR + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cWR_any_bank + WL + PL + wr_BL/2 + WR + _timing.tRPc + write_crc_dm - _current_cycle, "WL + PL + BL/2 + WR + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cREF_any_rank + dynamic_tRFCc - _current_cycle, "tRFC", spec_string));
        tRFC_64bit = _tREF_any_bank + dynamic_tRFC - $time;
        nops.push_back(CheckTimeSpec(tRFC_64bit, cmdpkt.tCK, "tRFC", spec_string));
        // When CAL is increased, there cannot be another LMR until CAL takes effect. This prevents the 2nd LMR clobbering the 1st.
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMRDc + CAL + PL + _parity_off - _current_cycle, "tMRDc (tMRDc + CAL + PL)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_extend_tMRD + _timing.tMODc + CAL + PL + _parity_off - _current_cycle, "tMODc (LMR with PL/CAL/GD changes)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_mpr + _timing.tWR_MPRc + _timing.tMPRRc - _current_cycle, "MPR(WR) tWR_MPR + tMPRR", spec_string));
        nops.push_back(CheckClockSpec(_cRD_mpr + RL + _timing.tMPRRc + 4 - _current_cycle, "MPR(RD) RL + 4 + tMPRR", spec_string));
    end

    cmdBST: begin
        nops.push_back(CheckClockSpec(_cRDA_any_bank + rd_BL/2 - _current_cycle, "tRDABURST", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + wr_BL/2 + write_crc_dm  - _current_cycle, "tWRABURST", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMODc + PL + CAL", spec_string));
    end

    cmdREFA, cmdREF: begin
        nops.push_back(CheckClockSpec(_cPREA + _timing.tRPc - _current_cycle, "tRP", spec_string));
        nops.push_back(CheckClockSpec(_cPRE_any_bank + _timing.tRPc - _current_cycle, "tRP", spec_string));
        nops.push_back(CheckClockSpec(_cACT_any_bank + _timing.tRASc + _timing.tRPc - _current_cycle, "tRAS + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cREF_by_rank[cmdpkt.rank] + dynamic_tRFCc - _current_cycle, "tRFC", spec_string));
        if (_dut_config.ranks > 1) begin
            for (int rank=0;rank<_dut_config.ranks;rank++)
                nops.push_back(CheckClockSpec(_cREF_by_rank[rank] + dynamic_tRFCc_dlr - _current_cycle, "tRFC_dlr", spec_string));
        end
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMODc + PL + CAL", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + RL + rd_BL/2 - _current_cycle, "RL + BL/2", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + AL + _timing.tRTPc + _timing.tRPc - _current_cycle, "AL + tRTP + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + RL + rd_BL/2 - _current_cycle, "RL + BL/2", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + WL+precharge_wr_bl/2 + WR + _timing.tRPc + write_crc_dm - _current_cycle, "WL + BL/2 + WR + tRP)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_any_bank + WL+precharge_wr_bl/2 + WR + _timing.tRPc + write_crc_dm - _current_cycle, "WL + BL/2 + WR + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cWR_mpr + _timing.tWR_MPRc - _current_cycle, "MPR(WR) tWR_MPR", spec_string));
        nops.push_back(CheckClockSpec(_cRD_mpr + RL + _timing.tMPRRc + 4 - _current_cycle, "MPR(RD) RL + 4 + tMPRR", spec_string));
    end

    cmdSREFE: begin
        // SREFE ignores CAL but must account for other commands which use CAL.
        nops.push_back(CheckClockSpec(_cPRE_any_bank + TimeToClocks(cmdpkt.tCK, _timing.tRP) + CAL - _current_cycle, "tRP (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cACT_any_bank + _timing.tRASc + _timing.tRPc +CAL - _current_cycle, "tRAS + tRP (+CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cREF_any_rank + TimeToClocks(cmdpkt.tCK, dynamic_tRFC) + CAL - _current_cycle, "tRFC (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + RL + PL + rd_BL/2 + CAL - _current_cycle, "tRDABURST (RL + BL/2 + CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + AL + _timing.tRTPc + _timing.tRPc - _current_cycle, "AL + tRTP + tRP", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + RL + PL + rd_BL/2 + CAL - _current_cycle, "tRDBURST (RL + BL/2 + CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + WL + PL + precharge_wr_bl/2 + WR + CAL + _timing.tRPc + write_crc_dm - _current_cycle, "tWRABURST (WL + BL/2 + WR + CAL + tRP)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_any_bank + WL + PL + precharge_wr_bl/2 + WR + CAL + _timing.tRPc + write_crc_dm - _current_cycle, "tWRBURST (WL + BL/2 + WR + CAL + tRP)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + PL + CAL - _current_cycle, "tMODc + PL + CAL", spec_string));
        nops.push_back(CheckClockSpec(_cWR_mpr + _timing.tWR_MPRc - _current_cycle, "MPR(WR) tWR_MPR", spec_string));
        nops.push_back(CheckClockSpec(_cRD_mpr + RL + _timing.tMPRRc + 4 - _current_cycle, "MPR(RD) RL + 4 + tMPRR", spec_string));
    end

    cmdPPDE, cmdAPDE: begin
        // PDE ignores CAL but must account for other commands which use CAL.
        nops.push_back(CheckClockSpec(_cACT_any_bank + _timing.tACTPDENc + CAL - _current_cycle, "tACTPDENc (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cPRE_any_bank + _timing.tPREPDENc + CAL - _current_cycle, "tPREPDENc (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_any_bank + _timing.tWRPDENc + write_crc_dm - _current_cycle,  "tWRPDEN", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + _timing.tWRAPDENc + write_crc_dm - _current_cycle, "tWRAPDEN", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + _timing.tRDPDENc - _current_cycle, "tRDPDEN (RD)", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + _timing.tRDPDENc - _current_cycle, "tRDPDEN (RDA)", spec_string));
        nops.push_back(CheckClockSpec(_cREF_any_rank + _timing.tREFPDENc + CAL - _current_cycle, "tREFPDENc (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + TimeToClocks(cmdpkt.tCK, _timing.tMRSPDEN) + CAL - _current_cycle, "tMRSPDEN (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMRSPDENc + CAL - _current_cycle, "tMRSPDENc (+ CAL)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_mpr + _timing.tWRPDENc + write_crc_dm - _current_cycle, "tWRPDEN", spec_string));
        nops.push_back(CheckClockSpec(_cRD_mpr + _timing.tRDPDENc - _current_cycle, "tRDPDEN (RD)", spec_string));
    end

    cmdSREFX: begin
        longint tCKESR_64bit;
        
        nops.push_back(CheckClockSpec(_cNOCLK + _timing.tCKSRXc - _current_cycle, "tCKSRX", spec_string));
        nops.push_back(CheckClockSpec(_cSREFE + _timing.tCKEc + 1 + PL - _current_cycle, "tCKE + 1nCK + PL", spec_string));
        tCKESR_64bit = _tSREFE + _timing.tCKE + cmdpkt.tCK + (PL*cmdpkt.tCK) - $time;
        nops.push_back(CheckTimeSpec(tCKESR_64bit, cmdpkt.tCK, "tCKESR", spec_string));
    end

    cmdPDX: begin
        longint tPD_64bit;
        
        nops.push_back(CheckClockSpec(_cNOCLK + _timing.tPDc - _current_cycle, "tPD", spec_string));
        nops.push_back(CheckClockSpec(_cPPDE + _timing.tPDc - _current_cycle, "tPD", spec_string));
        nops.push_back(CheckClockSpec(_cAPDE + _timing.tPDc - _current_cycle, "tPD", spec_string));
        tPD_64bit = _tPPDE + _timing.tPD - $time;
        nops.push_back(CheckTimeSpec(tPD_64bit, cmdpkt.tCK, "tPD", spec_string));
        tPD_64bit = _tAPDE + _timing.tPD - $time;
        nops.push_back(CheckTimeSpec(tPD_64bit, cmdpkt.tCK, "tPD", spec_string));
    end

    cmdZQ: begin
        if (1 == cmdpkt.addr[AUTOPRECHARGEADDR])
            nops.push_back(CheckClockSpec(_cZQCL + _timing.tZQoperc - _current_cycle, "tZQoper", spec_string));
        else
            nops.push_back(CheckClockSpec(_cZQCS + _timing.tZQCSc - _current_cycle, "tZQCS", spec_string));
    end
    
    cmdNOCLK: begin
        nops.push_back(CheckClockSpec(_cSREFE + _timing.tCKSREc - _current_cycle, "tCKSREc", spec_string));
        nops.push_back(CheckClockSpec(_cRD_any_bank + RL + PL + rd_BL/2 - _current_cycle, "tRDBURST (RL + BL/2)", spec_string));
        nops.push_back(CheckClockSpec(_cRDA_any_bank + RL + PL + rd_BL/2 - _current_cycle, "tRDABURST (RL + BL/2)", spec_string));
        nops.push_back(CheckClockSpec(_cWR_any_bank + WL + PL + wr_BL/2 + WR + write_crc_dm - _current_cycle, "tWRBURST (WL + BL/2 + WR)", spec_string));
        nops.push_back(CheckClockSpec(_cWRA_any_bank + WL + PL + wr_BL/2 + WR + write_crc_dm - _current_cycle, "tWRABURST (WL + BL/2 + WR)", spec_string));
    end
    endcase
    
    // This should be a call to FindQueueMax(), but vcs did not handle 'automatic' correctly.
    begin
        int next;
        while (nops.size()) begin
            next = nops.pop_front();
            if (next > max_nop) begin
                max_nop = next;
            end
        end
    end
    return max_nop;
endfunction

function bit tXSFastLMR(DDR4_cmd cmdpkt);
    bit retval;
    logic[MAX_ADDR_BITS-1:0] mr_cache;
    
    if (cmdLMR != cmdpkt.cmd)
        return 0;
    retval = 0;
    mr_cache = _LMR_cache[cmdpkt.bank_group & _dut_config.bank_group_mask][cmdpkt.bank & _dut_config.bank_mask];
    // Only allow CL & WR changes.
    if (MR0 == ((cmdpkt.bank_group << BANK_GROUP_SHIFT) | (cmdpkt.bank << BANK_SHIFT))) begin
        if (0 == ((~MR0_RESERVED_BITS & (mr_cache ^ cmdpkt.addr) & ~(MR0_CL_MASK | MR0_WR_MASK)) & ((2**MAX_MODEREG_SET_BITS)-1)))
            retval = 1;
    end
    // Only allow a CWL change.
    if (MR2 == ((cmdpkt.bank_group << BANK_GROUP_SHIFT) | (cmdpkt.bank << BANK_SHIFT))) begin
        if (0 == ((~MR2_RESERVED_BITS & (mr_cache ^ cmdpkt.addr) & ~MR2_CWL_MASK) & ((2**MAX_MODEREG_SET_BITS)-1)))
            retval = 1;
    end
    // Only allow a gear down change.
    if (MR3 == ((cmdpkt.bank_group << BANK_GROUP_SHIFT) | (cmdpkt.bank << BANK_SHIFT))) begin
        if (0 == ((~MR3_RESERVED_BITS & (mr_cache ^ cmdpkt.addr) & ~MR3_GEARDOWN_MASK) & ((2**MAX_MODEREG_SET_BITS)-1)))
            retval = 1;
    end
    if (1 == s_dut_mode_config.perdram_addr)
        retval = 0;
    return retval;
endfunction

function int TimeToClocks(int tCK, int spec);
    if ((spec % tCK) != 0)
        return (spec / tCK) + 1; // Ceiling.
    else
        return spec/tCK;
endfunction

function int CheckClockSpec(int spec_nops, string spec_string, inout string return_str);
    if (spec_nops > 0) begin
        $sformat(return_str, "%0s\n\t%0s - %0d clocks.", return_str, spec_string, spec_nops);
        return spec_nops;
    end
    return 0;
endfunction

function int CheckTimeSpec(longint spec, int tCK, string spec_string, inout string return_str);
    if (spec > 0) begin
        $sformat(return_str, "%0s\n\t%0s - %0dps | %0d clocks.", return_str, spec_string, spec, TimeToClocks(tCK, spec));
        return TimeToClocks(tCK, spec);
    end
    return 0;
endfunction

function void HardReset();
    reg [MODEREG_BITS-1:0] mode_regs[MAX_MODEREGS];
    
    InitTable();
    s_dut_mode_config = DefaultDutModeConfig();
    ModeToAddrDecode(s_dut_mode_config, mode_regs);
    for (int i=0;i<MAX_MODEREGS;i++) begin
        _LMR_cache[i[3:2]][i[1:0]] = mode_regs[i];
    end
endfunction

function bit ReceivingCmds();
    if(_in_self_refresh || InPowerDown() || _in_max_power_save)
        return 0;
    else
        return 1;
endfunction

function void UpdateTable(DDR4_cmd cmdpkt, int cmd_cycle_delay = 0, bit print = 0);
    UTYPE_DutModeConfig old_dut_mode;
    
    old_dut_mode = s_dut_mode_config;
    if (1 == _delayed_precharge) begin
        _open_banks[_delayed_precharge_rank][_delayed_precharge_group][_delayed_precharge_bank] = 0;
        _delayed_precharge = 0;
        if(_debug || print) $display("%0s::StateTable delayed precharge closed BG:%0h B:%0h @%0t", 
                                        _id, _delayed_precharge_group, _delayed_precharge_bank, $time);
    end
    if (1 == PendingLMR()) begin
        int latching_cycle;
        
        latching_cycle = _delayed_lmr_cycles.pop_front();
        if (_current_cycle == latching_cycle) begin
            DDR4_cmd cmdpkt;
            cmdpkt = _delayed_lmr_pkts.pop_front();
            _LMR_cache[cmdpkt.bank_group & _dut_config.bank_group_mask][cmdpkt.bank & _dut_config.bank_mask] = 
                       cmdpkt.addr & ((2**MAX_MODEREG_SET_BITS)-1);
            s_dut_mode_config = _delayed_lmr_mode_configs.pop_front();
        end else begin
            _delayed_lmr_cycles.push_front(latching_cycle);
        end
    end
    // cmdpkt can be raw bus signals, so make the data valid based on the DUT's current configuration.
    cmdpkt.rank = cmdpkt.rank & _dut_config.rank_mask;
    cmdpkt.bank_group = cmdpkt.bank_group & _dut_config.bank_group_mask;
    cmdpkt.bank = cmdpkt.bank & _dut_config.bank_mask;
    
    if(print) begin
        if(ReceivingCmds() == 0) 
            $display("%0s:State is not receiving cmds (%0s) (PD:%0d SR:%0d) @%0t", 
                        _id, cmdpkt.cmd.name(), InPowerDown(), _in_self_refresh, $time);
        else if ((cmdNOP != cmdpkt.cmd) && (cmdDES != cmdpkt.cmd))
            $display("%0s:Updating table[%0d] %0s R:%0h BG:%0h B:%0d A:%0h ODT:%0b @%0t", 
                _id, _current_cycle, cmdpkt.cmd.name(), cmdpkt.rank, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, cmdpkt.odt, $time);
    end
    case (cmdpkt.cmd)
        cmdACT: begin
            if ((ReceivingCmds() == 1) && (0 == OpenBank(.rank(cmdpkt.rank), .bg(cmdpkt.bank_group), .ba(cmdpkt.bank)))) begin
                int dummy_val;
                
                _open_banks[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = 1;
                _open_row_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = cmdpkt.addr & _dut_config.row_mask;
                _cACT_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = _current_cycle;
                _cACT_by_group[cmdpkt.rank][cmdpkt.bank_group]= _current_cycle;
                _cACT_any_bank = _current_cycle;
                _tACT_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = $time;
                _tACT_by_group[cmdpkt.rank][cmdpkt.bank_group] = $time;
                _tACT_any_bank = $time;
                dummy_val = _cFAWs.pop_back(); // Avoid a queue size runtime warning.
                _cFAWs.push_front(_current_cycle);
                if(_debug || print) $display("%0s::StateTable Opened R:%0h BG:%0h B:%0h R:%0h @%0t", _id, cmdpkt.rank, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
            end 
        end
        cmdPRE: begin 
            if (ReceivingCmds() == 1) begin
                _open_banks[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = 0;
                _cPRE_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = _current_cycle;
                _cPRE_any_bank = _current_cycle;
                _cAP_delay_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = 0;
                if ((1 == s_dut_mode_config.trr_enable) && 
                    (s_dut_mode_config.trr_bg == cmdpkt.bank_group) && (s_dut_mode_config.trr_ba == cmdpkt.bank)) begin
                    if (_TRR_precharges < 2) begin
                        _TRR_precharges = _TRR_precharges + 1;
                    end else begin
                        s_dut_mode_config.trr_enable = 0;
                        _TRR_precharges = 0;
                    end
                end
                if(_debug || print) $display("%0s::StateTable PRE closed BG:%0h B:%0h (%0d Open) @%0t", _id, cmdpkt.bank_group, cmdpkt.bank, OpenBanks(), $time);
            end
        end
        cmdPREA: begin
            if (ReceivingCmds() == 1) begin
                for(int group=0;group<_dut_config.bank_groups;group++) begin
                    for(int bank=0;bank<_dut_config.banks_per_group;bank++) begin
                        _open_banks[cmdpkt.rank][group][bank] = 0;
                        _cPRE_by_bank[cmdpkt.rank][group][bank] = _current_cycle;
                        _cAP_delay_by_bank[cmdpkt.rank][group][bank] = 0;
                    end
                end
                _cPREA = _current_cycle;
                _cPRE_any_bank = _current_cycle;
                if(_debug || print) $display("%0s::StateTable PREA closed all banks @%0t", _id, $time);
            end
        end
        cmdWR: begin
            if (ReceivingCmds() == 1) begin
                if ((1 == OpenBank(cmdpkt.rank, cmdpkt.bank_group, cmdpkt.bank)) || (1 == InMPRAccess())) begin
                    if (1 == InMPRAccess()) begin
                        if (_debug || print) $display("%0s::StateTable MPR WR BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        _cWR_mpr = _current_cycle;
                    end else begin
                        if (_debug || print) $display("%0s::StateTable WR BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        UpdateBL(CheckDynamicBL(cmdpkt.addr, s_dut_mode_config.write_crc_enable));
                        _cWR_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = _current_cycle;
                        _cWR_by_group[cmdpkt.rank][cmdpkt.bank_group] = _current_cycle;
                        _cWR_any_bank = _current_cycle;
                        _last_data_cmd.Clone(cmdpkt);
                        _clast_last_data_cmd = _clast_data_cmd;
                        _clast_data_cmd = _current_cycle;
                    end
                end else begin
                    if(_debug || print) $display("%0s::StateTable WR BG:%0h B:%0h CLOSED @%0t", _id, cmdpkt.bank_group, cmdpkt.bank, $time);
                    cmdpkt.cmd = cmdNOP;
                end
            end
        end
        cmdWRA: begin 
            if (ReceivingCmds() == 1) begin
                if((1 == OpenBank(cmdpkt.rank, cmdpkt.bank_group, cmdpkt.bank)) || (1 == InMPRAccess())) begin
                    if (1 == InMPRAccess()) begin
                        if (_debug || print) $display("%0s::StateTable MPR WRA BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        _cWR_mpr = _current_cycle;
                    end else begin
                        if (_debug || print) $display("%0s::StateTable WRA BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        UpdateBL(CheckDynamicBL(cmdpkt.addr, s_dut_mode_config.write_crc_enable));
                        _cAP_delay_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = s_dut_mode_config.WL_calculated;
                        _cWR_by_group[cmdpkt.rank][cmdpkt.bank_group] = _current_cycle;
                        _cWRA_any_bank = _current_cycle;
                        _cWRA_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = _current_cycle;
                        _last_data_cmd.Clone(cmdpkt);
                        _last_data_cmd.cmd = cmdWR;
                        _clast_last_data_cmd = _clast_data_cmd;
                        _clast_data_cmd = _current_cycle;
                    end
                end else begin
                    if(_debug || print) $display("%0s::StateTable WRA BG:%0h B:%0h CLOSED @%0t", _id, cmdpkt.bank_group, cmdpkt.bank, $time);
                    cmdpkt.cmd = cmdNOP;
                end
                _delayed_precharge = 1;
                _delayed_precharge_rank = cmdpkt.rank;
                _delayed_precharge_bank = cmdpkt.bank;
                _delayed_precharge_group = cmdpkt.bank_group;
            end
        end
        cmdRD: begin
            if (ReceivingCmds() == 1) begin
                if ((1 == OpenBank(cmdpkt.rank, cmdpkt.bank_group, cmdpkt.bank)) || (1 == InMPRAccess()) || (1 === InPreambleTraining())) begin
                    if (1 == InMPRAccess()) begin
                        if (_debug || print) $display("%0s::StateTable MPR RD BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        _cRD_mpr = _current_cycle;
                        _RD_mpr_page = s_dut_mode_config.MPR_page;
                    end else if (1 == InPreambleTraining()) begin
                        if (_debug || print) $display("%0s::StateTable Read Training RD BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                    end else begin
                        if (_debug || print) $display("%0s::StateTable RD BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        UpdateBL(CheckDynamicBL(cmdpkt.addr, 0));
                        _cRD_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = _current_cycle;
                        _cRD_by_group[cmdpkt.rank][cmdpkt.bank_group] = _current_cycle;
                        _cRD_any_bank = _current_cycle;
                        _last_data_cmd.Clone(cmdpkt);
                        _clast_last_data_cmd = _clast_data_cmd;
                        _clast_data_cmd = _current_cycle;
                    end
                end else begin
                    if(_debug || print) $display("%0s::StateTable RD BG:%0h B:%0h CLOSED @%0t", _id, cmdpkt.bank_group, cmdpkt.bank, $time);
                    cmdpkt.cmd = cmdNOP;
                end
            end
        end
        cmdRDA: begin
            if (ReceivingCmds() == 1) begin
                if ((1 == OpenBank(cmdpkt.rank, cmdpkt.bank_group, cmdpkt.bank)) || (1 == InMPRAccess()) || (1 === InPreambleTraining())) begin
                    if (1 == InMPRAccess()) begin
                        if (_debug || print) $display("%0s::StateTable MPR RDA BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        _cRD_mpr = _current_cycle;
                    end else if (1 == InPreambleTraining()) begin
                        if (_debug || print) $display("%0s::StateTable Read Training RD BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                    end else begin
                        if (_debug || print) $display("%0s::StateTable RDA BG:%0h B:%0h C:%0h @%0t", 
                            _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, $time);
                        UpdateBL(CheckDynamicBL(cmdpkt.addr, 0));
                        _cAP_delay_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = s_dut_mode_config.RL;
                        _cRD_by_group[cmdpkt.rank][cmdpkt.bank_group] = _current_cycle;
                        _cRDA_any_bank = _current_cycle;
                        _cRDA_by_bank[cmdpkt.rank][cmdpkt.bank_group][cmdpkt.bank] = _current_cycle;
                        _last_data_cmd.Clone(cmdpkt);
                        _last_data_cmd.cmd = cmdRD;
                        _clast_last_data_cmd = _clast_data_cmd;
                        _clast_data_cmd = _current_cycle;
                    end
                end else begin
                    if(_debug || print) $display("%0s::StateTable RDA BG:%0h B:%0h CLOSED @%0t", _id, cmdpkt.bank_group, cmdpkt.bank, $time);
                    cmdpkt.cmd = cmdNOP;
                end
                _delayed_precharge = 1;
                _delayed_precharge_rank = cmdpkt.rank;
                _delayed_precharge_bank = cmdpkt.bank;
                _delayed_precharge_group = cmdpkt.bank_group;
            end
        end
        cmdLMR: begin
            UpdateLMR(cmdpkt, cmd_cycle_delay, print);
        end
        cmdBST: begin 
            if (ReceivingCmds() == 1) begin
                _cBST = _current_cycle;
            end
        end
        cmdREF, cmdREFA: begin
            if (ReceivingCmds() == 1) begin
                _cREF_any_rank = _current_cycle;
                _cREF_by_rank[cmdpkt.rank] = _current_cycle;
                if (1 == cmdpkt.bank_group[0])
                    _cREF_fly_by_rank[cmdpkt.rank] = _current_cycle;
                _tREF_any_bank = $time;
                if (_debug || print) 
                    $display("%0s::StateTable REF BG:%0h @%0t", _id, cmdpkt.bank_group, $time);
            end
        end
        cmdSREFE: begin
            if (ReceivingCmds() == 1) begin
                _cSREFE = _current_cycle + cmd_cycle_delay;
                _tSREFE = $time + (cmd_cycle_delay * cmdpkt.tCK);
                _in_self_refresh = 1;
                if(_debug || print) $display("%0s::StateTable SREFE @%0t", _id, $time);
            end
        end
        cmdSREFX: begin
            _cSREFX = _current_cycle;
            _tSREFX = $time;
            _in_self_refresh = 0;
            s_dut_mode_config.gear_down = 0;
            _dynamic_fast_self_refresh = s_dut_mode_config.fast_self_refresh;
            if(_debug || print) $display("%0s::StateTable SREFX @%0t", _id, $time);
        end
        cmdPPDE,
        cmdAPDE : begin
            if (ReceivingCmds() == 1) begin
                if (0 == OpenBanks()) begin
                    _cPPDE = _current_cycle;
                    _tPPDE = $time;
                    _in_active_pd = 0;
                    _in_precharge_pd = 1;
                    _last_PDE_active = 0;
                    if(_debug || print) $display("%0s::StateTable PPDE @%0t", _id, $time);
                end else begin
                    _cAPDE = _current_cycle;
                    _tAPDE = $time;
                    _in_active_pd = 1;
                    _in_precharge_pd = 0;
                    _last_PDE_active = 1;
                    if(_debug || print) $display("%0s::StateTable APDE @%0t", _id, $time);
                end
            end
        end
        cmdPDX: begin
            _cPDX = _current_cycle;
            _tPDX = $time;
            _vrefDQ_at_PDX = 1; // Spec does not state how to disable vrefDQ.
            _in_active_pd = 0;
            _in_precharge_pd = 0;
            if(_debug || print) $display("%0s::StateTable PDX @%0t", _id, $time);
        end
        cmdNOCLK: begin
            _cNOCLK = _current_cycle;
        end
        cmdNOP, cmdDES: begin
        end
        cmdZQ: begin
            _cZQ_any = _current_cycle;
            if (1 == cmdpkt.addr[AUTOPRECHARGEADDR])
                if (_cZQCL_init > 0)
                    _cZQCL = _current_cycle;
                else
                    _cZQCL_init = _current_cycle;
            else
                _cZQCS = _current_cycle;
        end
        default: begin
            $display("%0s::ERROR in StateTable:UpdateTable() invalid command %0s @%0t", _id, cmdpkt.cmd.name(), $time);
        end
    endcase
    UpdateODT(cmdpkt.odt, cmdpkt.cmd);
    // update dutstate
    s_latched_cmd.cycle_count = _current_cycle;
    s_latched_cmd.cmd = cmdpkt.cmd;
    // rawCmd was on bus...ie the exiting PDX cmdpkt.cmd
    if(cmdpkt.cmd == cmdPDX)
        s_latched_cmd.raw_cmd = cmdpkt.raw_cmd;
    s_latched_cmd.rank = cmdpkt.rank;
    s_latched_cmd.bank_group = cmdpkt.bank_group;
    s_latched_cmd.bank = cmdpkt.bank;
    s_latched_cmd.addr = cmdpkt.addr;
    s_latched_cmd.sim_time = $time;
    _current_cycle++;
endfunction

function void UpdateLMR(DDR4_cmd cmdpkt, int cmd_cycle_delay, bit print = 0);
    int lmr_addr;
    
    lmr_addr = GetLMRAddr(cmdpkt);
    if (ReceivingCmds() == 1) begin
        if (1 == ReservedBitsSet(lmr_addr)) begin
            if (print)
                $display("%0s::StateTable WARNING::LMR %0h has reserved bits set and will be ignored. @%0t.", 
                        _id, lmr_addr, $time);
            _cLMR_ignored = _current_cycle + cmd_cycle_delay;
        end else if (0 != OpenBanks()) begin
            $display("%0s::StateTable ERROR::LMR with open banks (%0d open) @%0t", _id, OpenBanks(), $time);
        end else begin
            UTYPE_DutModeConfig new_mode_config;
            
            new_mode_config = AddrToModeDecode(lmr_addr, s_dut_mode_config);
            _cLMR_any_bank = _current_cycle + cmd_cycle_delay;
            if (new_mode_config.DLL_reset) begin
                _cDLL_reset = _current_cycle + cmd_cycle_delay;
                new_mode_config.DLL_reset = 0; // Reset bit is self-clearing
                _LMR_cache[cmdpkt.bank_group & _dut_config.bank_group_mask][cmdpkt.bank & _dut_config.bank_mask] &= ~MR0_DLL_RESET;
            end
            if (1 == new_mode_config.preamble_training) begin
                _tpreamble_training_entry = $time + (_timing.tCK*cmd_cycle_delay);
                _cpreamble_training = _current_cycle + cmd_cycle_delay;
            end
            if ((1 == InPreambleTraining()) && (0 == new_mode_config.preamble_training)) begin
                _tpreamble_training_exit = $time + (_timing.tCK*cmd_cycle_delay);
                _cpreamble_training_exit = _current_cycle + cmd_cycle_delay;
            end
            // Turning off PL takes +PL to actually turn off.
            _parity_off = 0;
            if (new_mode_config.CA_parity_latency < s_dut_mode_config.CA_parity_latency) begin
                _parity_off = 4;
            end
            if ((new_mode_config.CA_parity_latency != s_dut_mode_config.CA_parity_latency) ||
                (new_mode_config.CAL != s_dut_mode_config.CAL) ||
                (new_mode_config.gear_down != s_dut_mode_config.gear_down)) begin
                _cLMR_extend_tMRD = _current_cycle + cmd_cycle_delay;
            end
            // Turning parity off clears the parity error log.
            if ((CAPARITY_L0 != s_dut_mode_config.CA_parity_latency) && (CAPARITY_L0 == new_mode_config.CA_parity_latency))
                WriteParityErrorLog(.mpr3('0), .mpr2('1), .mpr1('1), .mpr0('1));
            if (new_mode_config.CAL != s_dut_mode_config.CAL) begin
                _cCAL_change = _current_cycle + cmd_cycle_delay;
            end
            if (cmd_cycle_delay > 0) begin
                _delayed_lmr_cycles.push_back(_current_cycle + cmd_cycle_delay);
                _delayed_lmr_mode_configs.push_back(new_mode_config);
                _delayed_lmr_pkts.push_back(cmdpkt);
            end else begin
                s_dut_mode_config = new_mode_config;
                _LMR_cache[cmdpkt.bank_group & _dut_config.bank_group_mask][cmdpkt.bank & _dut_config.bank_mask] = cmdpkt.addr & ((2**MAX_MODEREG_SET_BITS)-1);
            end
            if (1 == new_mode_config.MPS) begin
                _cMPS_entry = _current_cycle + cmd_cycle_delay + _timing.tMPEDc;
                _in_max_power_save = 1;
                _max_power_save_exit_cs = 0;
                s_dut_mode_config.gear_down = 0;
            end
            if (1 == new_mode_config.trr_enable) begin
                _cTRR_enter = _current_cycle;
                _TRR_precharges = 0;
            end
            if(_debug || print) $display("%0s::StateTable LMR BG:%0h B:%0h A:%0h (lmrA:%0h) @%0t", 
                _id, cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, lmr_addr, $time);
        end
    end
endfunction

function bit PendingLMR();
    if (_delayed_lmr_cycles.size() > 0)
        return 1;
    return 0;
endfunction

function void GetDynamictRFC(int rank, inout int tRFC, inout int tRFCc, inout int tRFC_dlr, inout int tRFCc_dlr);
    if ((REF_2X == s_dut_mode_config.refresh_mode) || 
        ((REF_FLY2X == s_dut_mode_config.refresh_mode) && (_cREF_fly_by_rank[rank] == _cREF_by_rank[rank]))) begin
        tRFCc = _timing.tRFC2c;
        tRFC = _timing.tRFC2;
    end else if ((REF_4X == s_dut_mode_config.refresh_mode) || 
        ((REF_FLY4X == s_dut_mode_config.refresh_mode) && (_cREF_fly_by_rank[rank] == _cREF_by_rank[rank]))) begin
        tRFCc = _timing.tRFC4c;
        tRFC = _timing.tRFC4;
    end else begin
        tRFCc = _timing.tRFCc;
        tRFC = _timing.tRFC;
    end
    tRFC_dlr = tRFC/3;
    tRFCc_dlr = tRFCc/3;
endfunction

function bit ODTEnabled();
    if (ODTNominalEnabled() || ODTDynamicEnabled() || ODTParkEnabled())
        return 1;
    return 0;
endfunction

function bit ODTNominalEnabled();
    if (RTTN_DIS != s_dut_mode_config.rtt_nominal)
        return 1;
    return 0;
endfunction

function bit ODTDynamicEnabled();
    if (RTTW_DIS != s_dut_mode_config.rtt_write)
        return 1;
    return 0;
endfunction

function bit ODTParkEnabled();
    if (RTTP_DIS != s_dut_mode_config.rtt_park)
        return 1;
    return 0;
endfunction

function int ODTLon();
    `ifdef ODT_CWL2
    return s_dut_mode_config.WL_calculated - 2;
    `endif
    return s_dut_mode_config.WL_calculated - (s_dut_mode_config.wr_preamble_clocks + 1);
endfunction

function int ODTLoff();
    `ifdef ODT_CWL2
    return s_dut_mode_config.WL_calculated - 2;
    `endif
    return s_dut_mode_config.WL_calculated - (s_dut_mode_config.wr_preamble_clocks + 1);
endfunction

function int ODTLcwn(int bl);
    return bl/2 + s_dut_mode_config.WL_calculated + s_dut_mode_config.write_crc_enable;
endfunction

function int tANPDc();
    return ODTLon() + 1;
endfunction

function void UpdateODT(logic odt, UTYPE_cmdtype cmd);
    UpdateODTEdges(odt, cmd);
    UpdateODTModes(cmd);
endfunction

function void UpdateODTEdges(logic odt, UTYPE_cmdtype cmd);
    // ODT is sync so a clk is required.
    if (cmdNOCLK != cmd) begin
        if (1 == odt) begin
            if (0 == _ODT_last_transition) begin
                _cODT_high = _current_cycle;
                _ODT_last_transition = 1;
            end
        end else if (0 == odt) begin
            if (1 == _ODT_last_transition) begin
                _cODT_low = _current_cycle;
                _ODT_last_transition = 0;
            end
        end
    end
endfunction

function void UpdateODTModes(input UTYPE_cmdtype cmd);
    if (0 == s_dut_mode_config.DLL_enable)
        _ODT_sync = 0;
    else
        _ODT_sync = 1;
    
    if (1 == ODTEnabled()) begin
        if (cmdSREFE == cmd)
            _ODT_enter_transition = 1;
        if (cmdSREFX == cmd)
            _ODT_exit_transition = 1;
    end
    
    if (1 == _ODT_enter_transition) begin
        if ((_current_cycle > (_cPPDE + _timing.tCPDEDc + ODTLoff())) &&
            (_current_cycle > (_cREF_any_rank + _timing.tRFCc - tANPDc())) &&
            (_current_cycle > (_cSREFE + _timing.tCPDEDc + ODTLoff()))) begin
            _ODT_enter_transition = 0;
        end
    end
    if (1 == _ODT_exit_transition) begin
        if ((_current_cycle > (_cPDX + _timing.tXPDLLc + ODTLon())) &&
            (_current_cycle > (_cSREFX + ODTLoff()))) begin
            _ODT_exit_transition = 0;
        end
    end
endfunction

function bit ODTSync();
    return _ODT_sync;
endfunction

function bit ODTEnterTransition();
    return _ODT_enter_transition;
endfunction

function bit ODTExitTransition();
    return _ODT_exit_transition;
endfunction

function bit ODTAnyTransition();
    return ODTEnterTransition() | ODTExitTransition() | _ODT_tMOD_transition;
endfunction

function int RequiredODTCycles(input bit odt_level, inout string spec_string);
    int nops[$], max_nop;
    string cycle_string;
    
    nops.delete();
    max_nop = 0;
    cycle_string = "";
    if ((1 == ODTNominalEnabled()) || ((1 == PendingLMR()) && (RTTN_DIS != _delayed_lmr_mode_configs[0].rtt_nominal))) begin
        if (0 == odt_level) begin
            nops.push_back(CheckClockSpec(_cODT_high + _timing.tODTHc - _current_cycle, "ODTH4", cycle_string));
        end else begin
            if ((1 == PendingLMR()) || (1 == s_dut_mode_config.perdram_addr))
                nops.push_back(CheckClockSpec(1, "LMR (ODT != 1)", cycle_string));
            nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + s_dut_mode_config.CA_parity_latency 
                                          - _current_cycle, "tMODc", cycle_string));
            nops.push_back(CheckClockSpec(_cLMR_ignored + _timing.tMODc + s_dut_mode_config.CA_parity_latency 
                                          - _current_cycle, "tMODc", cycle_string));
            if (_current_cycle > _cSREFE) // Do not check until in SREF.
                nops.push_back(CheckClockSpec(_cSREFE + _timing.tDLLKc - _current_cycle, "tDLLK", cycle_string));
        end
        if (((_cODT_high > _cODT_low) && (0 == odt_level)) ||
            ((_cODT_low > _cODT_high) && (1 == odt_level))) begin
            nops.push_back(CheckClockSpec(_cDLL_reset + _timing.tDLLKc - _current_cycle, "tDLLK", cycle_string));
            nops.push_back(CheckClockSpec(_cSREFX + _timing.tDLLKc - _current_cycle, "tDLLK (SREFX)", cycle_string));
            nops.push_back(CheckClockSpec(_ctCK_change + ODTLon() - _current_cycle, "tCK change", cycle_string));
            nops.push_back(CheckClockSpec(_cGeardown_sync + ODTLon() - _current_cycle, "gear down sync", cycle_string));
            nops.push_back(CheckClockSpec(_cGeardown_toggle + ODTLon() - _current_cycle, "gear down change", cycle_string));
            nops.push_back(CheckClockSpec(_cLMR_any_bank + _timing.tMODc + ODTLon() 
                                          - _current_cycle, "tMODc + ODTLon", cycle_string));
            nops.push_back(CheckClockSpec(_cLMR_ignored + _timing.tMODc + ODTLon() 
                                          - _current_cycle, "tMODc + ODTLon", cycle_string));
        end
    end
    // This should be a call to FindQueueMax(), but vcs did not handle 'automatic' correctly.
    begin
        int next;
        while (nops.size()) begin
            next = nops.pop_front();
            if (next > max_nop) begin
                max_nop = next;
            end
        end
    end
    if (max_nop > 0)
        $sformat(spec_string, "ODT %0b @%0t Required:%0s", odt_level, $time, cycle_string);
    return max_nop;
endfunction

function bit RequireDeselects();
    if ((1 == CAParityEnabled()) || (_cCAL_change + _timing.tMODc + _timing.tCALc_min > _current_cycle)) begin
        return 1;
    end
    return 0;
endfunction

function int PerDramLatency();
    return s_dut_mode_config.WL_calculated;
endfunction

// This function MASKS invalid bg,ba values for the current configuration.
function bit OpenRow(logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg, logic[MAX_BANK_BITS-1:0] ba, 
                        output logic[MAX_ROW_ADDR_BITS-1:0] row);
    rank = rank & _dut_config.rank_mask;
    bg = bg & _dut_config.bank_group_mask;
    ba = ba & _dut_config.bank_mask;
    if (1 == OpenBank(.rank(rank), .bg(bg), .ba(ba))) begin
        row = _open_row_by_bank[rank][bg][ba];
        return 1;
    end else begin
        return 0;
    end
endfunction

// This function MASKS invalid bg,ba values for the current configuration.
function bit OpenBank(logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg, logic[MAX_BANK_BITS-1:0] ba);
    rank = rank & _dut_config.rank_mask;
    bg = bg & _dut_config.bank_group_mask;
    ba = ba & _dut_config.bank_mask;
    if (1 == _open_banks[rank][bg][ba]) begin
        return 1;
    end else begin
        return 0;
    end
endfunction

function int OpenBanks();
    int openBanks;
    openBanks = 0;
    for (int rank=0;rank<MAX_RANKS;rank++) begin
        for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
            for (int ba=0;ba<MAX_BANKS_PER_GROUP;ba++) begin
                if (OpenBank(.rank(rank), .bg(bg), .ba(ba)))
                    openBanks += 1;
            end
        end
    end
    return openBanks;
endfunction

function int OpenBanksInGroup(logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg);
    int openBanks;
    openBanks = 0;
    rank = rank & _dut_config.rank_mask;
    bg = bg & _dut_config.bank_group_mask;
    for (int ba=0;ba<MAX_BANKS_PER_GROUP;ba++) begin
        if (OpenBank(.rank(rank), .bg(bg), .ba(ba)))
            openBanks += 1;
    end
    return openBanks;
endfunction

function void CloseAllBanks();
    for (int rank=0;rank<MAX_RANKS;rank++) begin
        for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
            for (int ba=0;ba<MAX_BANKS_PER_GROUP;ba++) begin
                _open_banks[rank][bg][ba] = 0;
            end
        end
    end
endfunction

function int OpenRank(int rank);
    int open_rank;
    
    open_rank = 0;
    for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
        open_rank += OpenBanksInGroup(.rank(rank), .bg(bg));
    end
    return open_rank;
endfunction

function void GeardownSync();
    _cGeardown_sync = _current_cycle;
endfunction

function void GeardownToggle();
    _cGeardown_toggle = _current_cycle;
endfunction

// With 2 preamble clks, there must be an even number of nops.
task VerifyBurstSpacing(DDR4_cmd cmdpkt, inout int nops);
    int invalid_nops;
    
    invalid_nops = s_dut_mode_config.BL/2 + 1;
    _added_cycle = 0;
    if ((cmdRD == cmdpkt.cmd) || (cmdRDA == cmdpkt.cmd) || (cmdWR == cmdpkt.cmd) || (cmdWRA == cmdpkt.cmd)) begin
        if (2 == s_dut_mode_config.rd_preamble_clocks) begin
            if ((invalid_nops == ((_current_cycle - _cRD_any_bank) + nops)) ||
                (invalid_nops == ((_current_cycle - _cRDA_any_bank) + nops))) begin
                nops = nops + 1;
            end
        end
        if (2 == s_dut_mode_config.wr_preamble_clocks) begin
            if ((invalid_nops == (_current_cycle - _cWR_any_bank) + nops - s_dut_mode_config.write_crc_enable) ||
                (invalid_nops == (_current_cycle - _cWRA_any_bank) + nops - s_dut_mode_config.write_crc_enable)) begin
                    nops = nops + 1;
            end
        end
    end
endtask
    
function logic[MAX_ADDR_BITS-1:0] GetLMRCache(logic[MAX_BANK_GROUP_BITS-1:0] bank_group, logic[MAX_BANK_BITS-1:0] bank);
    bank_group = bank_group & _dut_config.bank_group_mask;
    bank = bank & _dut_config.bank_mask;
    return _LMR_cache[bank_group][bank];
endfunction

function void WriteMPR(logic[MAX_BANK_GROUP_BITS-1:0] bg, logic[MAX_BANK_BITS-1:0] ba, reg[MAX_COL_ADDR_BITS-1:0] addr, 
                       UTYPE_mprpage mpr_page, UTYPE_mpr mpr_mode);
    bg = bg & _dut_config.bank_group_mask;
    ba = ba & _dut_config.bank_mask;
    if (MPR_PATTERN == mpr_page) begin
        _MPR_pattern[ba[1:0]] = addr[MPR_DATA_BITS-1:0];
        if (1 || _debug)
            $display("%0s::StateTable MPR Write Data:%0b Mode:%0s Pattern[%0d]:%0h @%0t", 
                    _id, addr, mpr_mode.name(), ba[1:0], _MPR_pattern[ba[1:0]], $time);
    end else begin
        $display("%0s::StateTable ERROR::MPR write is only available for MPR patterns in page 0 (not %s) @%0t", _id, mpr_page.name(), $time);
    end
endfunction

function void WriteParityErrorLog(input logic[MPR_DATA_BITS-1:0] mpr3, input logic[MPR_DATA_BITS-1:0] mpr2,
                                  input logic[MPR_DATA_BITS-1:0] mpr1, input logic[MPR_DATA_BITS-1:0] mpr0);
    _MPR_error_log[0] = mpr0;
    _MPR_error_log[1] = mpr1;
    _MPR_error_log[2] = mpr2;
    _MPR_error_log[3] = mpr3;
    _debug_MPR_error_log = {mpr3, mpr2, mpr1, mpr0};
endfunction

function logic[MAX_DQ_BITS-1:0] ReadMPR(logic[MAX_BANK_GROUP_BITS-1:0] bg, logic[MAX_BANK_BITS-1:0] ba, bit[MAX_COL_ADDR_BITS-1:0] addr, 
                                        UTYPE_mprpage mpr_page, UTYPE_mpr mpr_mode, int burst_position);
    logic[MPR_DATA_BITS-1:0] raw_data[MAX_MPR_PATTERNS];
    
    bg = bg & _dut_config.bank_group_mask;
    ba = ba & _dut_config.bank_mask;
    if (MPR_PATTERN == mpr_page) begin
        for (int i=0;i<MAX_MPR_PATTERNS;i++) begin
            int pat;
            pat = i+ba[1:0];
            if (STAGGERED == mpr_mode)
                pat = pat[1:0];
            raw_data[i] = GetMPRPattern(pat);
        end
    end else if (MPR_PAGE3 == mpr_page) begin
        $display("%0s::StateTable ERROR::MPR 'Page3' read is reserved for vendor use @%0t", _id, $time);
        return 'x;
    end else if (MPR_MODEREG == mpr_page) begin
        if (mpr_mode != SERIAL) begin
            $display("%0s::StateTable ERROR::MPR 'Mode Register' read is only available in serial mode @%0t", _id, $time);
        end else begin
            BuildMPRData(GetMRSReadout(ba), raw_data);
        end
    end else if (MPR_PARITY == mpr_page) begin
        if (mpr_mode != SERIAL) begin
            $display("%0s::StateTable ERROR::MPR 'C/A Parity Log' read is only available in serial mode @%0t", _id, $time);
        end else begin
            _MPR_error_log[3][5:3] = _LMR_cache[1][1][2:0]; // CA parity latency.
            _MPR_error_log[3][6] = s_dut_mode_config.CA_parity_error;
            _MPR_error_log[3][7] = s_dut_mode_config.crc_error;
            for (int i=0;i<MAX_MPR_PATTERNS;i++) begin
                raw_data[i] = _MPR_error_log[ba[1:0]];
            end
        end
    end
    if (_debug) begin
        $display("%0s::StateTable %s in %s MPR Data [%0h %0h %0h %0h] @%0t", 
                _id, mpr_page.name(), mpr_mode.name(), raw_data[0], raw_data[1], raw_data[2], raw_data[3], $time);
    end
    burst_position = (0 == addr[2]) ? burst_position : (4 + burst_position) & 'h7; // Account for CA2 wrapping.
    return MPRDataToDQ(raw_data, mpr_mode, (7 - burst_position));
endfunction

function logic[MPR_DATA_BITS-1:0] GetMRSReadout(logic[MAX_BANK_BITS-1:0] ba);
    logic[MPR_DATA_BITS-1:0] mrs_readout_bits;
    
    mrs_readout_bits = '0;
    // Map directly to the MR registers.
    case (ba)
        0: begin
            mrs_readout_bits[7] = proj_package::ppr_available(_dut_config);
            mrs_readout_bits[5] = _LMR_cache[0][2][11];
            mrs_readout_bits[4:3] = _temp_sensor_range[1:0];
            mrs_readout_bits[2] = _LMR_cache[0][2][12];
            mrs_readout_bits[1:0] = _LMR_cache[0][2][10:9];
        end
        1: begin
            mrs_readout_bits[7] = s_dut_mode_config.vref_training_range;
            mrs_readout_bits[6:1] = s_dut_mode_config.vref_training_offset;
            mrs_readout_bits[0] = _LMR_cache[0][3][3];
        end
        2: begin
            mrs_readout_bits[7:5] = _LMR_cache[0][0][6:4];
            mrs_readout_bits[4] = _LMR_cache[0][0][2];
            mrs_readout_bits[2:0] = _LMR_cache[0][2][5:3];
        end
        3: begin
            mrs_readout_bits[7:5] = _LMR_cache[0][1][10:8];
            mrs_readout_bits[4:2] = _LMR_cache[1][1][8:6];
            mrs_readout_bits[1:0] = _LMR_cache[0][1][2:1];
        end
    endcase
    return mrs_readout_bits;
endfunction

function logic[MAX_DQ_BITS-1:0] MPRDataToDQ(logic[MPR_DATA_BITS-1:0] mpr_data[MAX_MPR_PATTERNS], UTYPE_mpr mpr_mode, int burst_position);
    logic[MAX_DQ_BITS-1:0] return_data;
    
    return_data = 'x;
    case (mpr_mode)
        SERIAL: begin
            return_data = {MAX_DQ_BITS{mpr_data[0][burst_position]}};
        end
        PARALLEL: begin
            logic[MPR_DATA_BITS-1:0] data;
            
            for (int i=0;i<MPR_DATA_BITS;i++) begin
                data[(MPR_DATA_BITS - 1) - i] = mpr_data[0][i];
            end
            return_data = '0;
            return_data = data | (data << MPR_DATA_BITS);
        end
        STAGGERED: begin
            for (int dq=0;dq<MAX_DQ_BITS;dq++) begin
                return_data[dq] = mpr_data[dq[1:0]][burst_position];
            end
        end
        default: begin
            $display("%0s::StateTable ERROR::Unsupported MPR mode '%0s' @%0t", _id, mpr_mode.name(), $time);
        end
    endcase
    return return_data;
endfunction

function void BuildMPRData(logic[MPR_DATA_BITS-1:0] in_data, output logic[MPR_DATA_BITS-1:0] out_data[MAX_MPR_PATTERNS]);
    for (int i=0;i<MAX_MPR_PATTERNS;i++) begin
        out_data[i] = in_data;
    end
endfunction

function logic[MPR_DATA_BITS-1:0] GetMPRPattern(logic[MPR_SELECT_BITS-1:0] pat);
    return _MPR_pattern[pat];
endfunction

function logic[MPR_DATA_BITS-1:0] GetDefaultMPRPattern(logic[MPR_SELECT_BITS-1:0] pat);
    return _MPR_default_pattern[pat];
endfunction

function bit CalculateParity(logic[3:0] cmd, logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg, 
                                logic [MAX_BANK_BITS-1:0] ba, logic [MAX_ADDR_BITS-1:0] addr);
    addr = (1 == _dut_config.row_mask[17]) ? (addr & 20'h7fff) : (addr & 20'h3fff);
    return ^{cmd, rank, bg, ba, addr};
endfunction

function bit ClearParityError(DDR4_cmd cmdpkt);
    if (cmdpkt.cmd == cmdLMR) begin
        UTYPE_DutModeConfig dut_config;
        
        dut_config = AddrToModeDecode(GetLMRAddr(cmdpkt), s_dut_mode_config);
        if (0 == dut_config.CA_parity_error)
            return 1;
    end
    return 0;
endfunction

function bit CAParityEnabled();
    if (CAPARITY_L0 !== s_dut_mode_config.CA_parity_latency)
        return 1;
    return 0;
endfunction

function void SetParityError(bit enable);
    if (1 == enable) begin
        s_dut_mode_config.CA_parity_error = 1;
        s_dut_mode_config.trr_enable = 0;
        _tparity_error_begin = $time;
    end else begin
        s_dut_mode_config.CA_parity_error = 0;
    end
    SetParityBlockCommands(enable);
endfunction

function int GetParityAlertOnDelay();
    return (s_dut_mode_config.CA_parity_latency*_timing.tCK + _timing.tPAR_ALERT_ON);
endfunction

function int GetParityAlertWidth();
    int tRAS_max, nops[$], max_nop, precharge_wr_bl, write_crc_dm, adjustment, fixed_delay;
    string spec_string;
    
    _debug_parity_alert_width = "";
    spec_string = "";
    precharge_wr_bl = PrechargeWriteBL((1 == s_dut_mode_config.write_crc_enable) ? (s_dut_mode_config.BL + MAX_CRC_TRANSFERS) : s_dut_mode_config.BL);
    // Subtract one from tWR_CRC_DMc since the BL contains CRC burst.
    write_crc_dm = ((1 == s_dut_mode_config.write_crc_enable) && (1 == s_dut_mode_config.dm_enable)) ? (_timing.tWR_CRC_DMc - 1) : 0;
    nops.push_back(CheckClockSpec(_cRD_any_bank + s_dut_mode_config.AL + s_dut_mode_config.CA_parity_latency + 4 
                                  - _current_cycle, "RD", spec_string));
    nops.push_back(CheckClockSpec(_cRDA_any_bank + s_dut_mode_config.AL + s_dut_mode_config.CA_parity_latency + _timing.tRTPc + 1 
                                  - _current_cycle, "RDA", spec_string));
    nops.push_back(CheckClockSpec(_cWR_any_bank + s_dut_mode_config.WL_calculated + precharge_wr_bl/2 + write_crc_dm + 3 
                                  - _current_cycle, "WR", spec_string));
    nops.push_back(CheckClockSpec(_cWRA_any_bank + s_dut_mode_config.WL_calculated + precharge_wr_bl/2 + write_crc_dm + s_dut_mode_config.write_recovery
                                  - _current_cycle, "WRA", spec_string));
    max_nop = 0;
    begin
        int next;
        while (nops.size()) begin
            next = nops.pop_front();
            if (next > max_nop) begin
                max_nop = next;
            end
        end
    end
    tRAS_max = _timing.tRAS + (s_dut_mode_config.CA_parity_latency*_timing.tCK);
    fixed_delay = 32000; // TODO: Calculate the actual value. This is just a place holder.
    if ((max_nop * _timing.tCK) > tRAS_max) begin
        tRAS_max = max_nop * _timing.tCK;
        adjustment = _timing.tPAR_tRP_holdoff_adjustment;
        $sformat(_debug_parity_alert_width, "tRAS:%0d %0s tRP:%0d (adj:%0d) (fixed:%0d)", 
                 tRAS_max, spec_string, _timing.tRP, _timing.tPAR_tRP_holdoff_adjustment, fixed_delay);
    end else begin
        adjustment = _timing.tPAR_tRP_tRAS_adjustment;
        $sformat(_debug_parity_alert_width, "tRAS:%0d tRP:%0d (adj:%0d) (fixed:%0d)", 
                 tRAS_max, _timing.tRP, _timing.tPAR_tRP_tRAS_adjustment, fixed_delay);
    end
    return (tRAS_max + _timing.tRP + adjustment + fixed_delay);
endfunction

function bit GetParityBlockCommands();
    return _parity_block_commands;
endfunction

function void SetParityBlockCommands(bit enable);
    if (1 == enable) begin
        _parity_block_commands = 1;
        _tparity_block_commands_on = $time + GetParityAlertOnDelay();
        _tparity_block_commands_off = $time + GetParityAlertOnDelay() + GetParityAlertWidth() + s_dut_mode_config.CA_parity_latency - _timing.tPAR_ALERT_OFF;
    end else begin
        _parity_block_commands = 0;
    end
endfunction

function bit CheckParityBlockCommands();
    if ($time < _tparity_block_commands_off)
        return 1;
    return 0;
endfunction

function bit CheckParityCloseBanks();
    if (($time - _tparity_error_begin) > _timing.tPAR_CLOSE_BANKS)
        return 1;
    return 0;
endfunction

function void SetCRCError();
    s_dut_mode_config.crc_error = 1;
endfunction

function bit InSelfRefresh();
    return _in_self_refresh;
endfunction

function bit InPowerDown();
    return (_in_active_pd || _in_precharge_pd);
endfunction

function bit InActivePowerDown();
    return _in_active_pd;
endfunction

function bit InPrechargePowerDown();
    return _in_precharge_pd;
endfunction

function bit InMaxPowerSave();
    if ((1 == _in_max_power_save) && 
        ((1 == s_dut_mode_config.MPS) ||
         (1 == MaxPowerSaveExitT5()) || 
         (0 == _max_power_save_exit_cs))) begin
        _in_max_power_save = 1;
        return 1;
    end
    _in_max_power_save = 0;
    return 0;
endfunction

function bit MaxPowerSaveExitT5();
    if (_cMPS_exit + _timing.tMPX_H/_timing.tCK > _current_cycle) begin
        return 1;
    end
    return 0;
endfunction

function void ExitMaxPowerSaveMR();
    s_dut_mode_config.MPS = 0;
    _cMPS_exit = _current_cycle;
endfunction

function void ExitMaxPowerSaveCS();
    _max_power_save_exit_cs = 1;
endfunction

function void ExitMaxPowerSave();
    _in_max_power_save = 0;
    ExitMaxPowerSaveMR();
    ExitMaxPowerSaveCS();
endfunction

function bit InPreambleTraining();
    return s_dut_mode_config.preamble_training;
endfunction

function bit PreambleTrainingtSDOExpired();
    if ((1 == InPreambleTraining()) && 
        (($time - _tpreamble_training_entry) > _timing.tSDO))
        return 1;
    return 0;
endfunction

function bit PreambleTrainingExiting();
    if (_tpreamble_training_exit > _tpreamble_training_entry) begin
        if ($time < (_tpreamble_training_exit + _timing.tSDO))
            return 1;
    end
    return 0;
endfunction

function logic[MAX_DQ_BITS-1:0] PreambleTrainingPattern();
    return 16'h5555;
endfunction

function bit InMPRAccess();
    return s_dut_mode_config.MPR_enable;
endfunction

function UTYPE_mpr MPRMode();
    return s_dut_mode_config.MPR_mode;
endfunction

function int CheckFlyBL(logic[MAX_COL_ADDR_BITS-1:0] col);
    int active_bl;
    
    case (s_dut_mode_config.BL_reg)
        rBLFLY : begin
            if (0 == col[BLFLYSELECT])
                active_bl = 4;
            else
                active_bl = 8;
        end
        rBL8 : active_bl = 8;
        rBL4 : active_bl = 4;
    endcase
    return active_bl;
endfunction

function int CheckDynamicBL(logic[MAX_COL_ADDR_BITS-1:0] col, bit crc_enable);
    int active_bl;
    
    active_bl = CheckFlyBL(col);
    if (crc_enable) // CRC is always 8.
        active_bl = 8;
    return active_bl;
endfunction

// Wrapper required for vcs 'SystemVerilog feature not yet implemented. Usupported complex reference to a non-static class property.'
function int GetBL();
    return s_dut_mode_config.BL;
endfunction

function int PrechargeWriteBL(int default_bl = GetBL());
    int return_bl;
    
    return_bl = default_bl;
    if ((rBLFLY == s_dut_mode_config.BL_reg) && (4 == s_dut_mode_config.BL)) begin
        return_bl = 8 + ((1 == s_dut_mode_config.write_crc_enable) ? MAX_CRC_TRANSFERS : 0);
    end
    return return_bl;
endfunction

function void UpdateBL(int bl);
    s_dut_mode_config.BL = bl;
endfunction

function void UpdateTiming(UTYPE_TimingParameters ts);
    if (_timing.ts_loaded != ts.ts_loaded)
        _ctCK_change = _current_cycle;
    _timing = ts;
endfunction

function void SetTemperature(int temperature);
    if (temperature < (90 - 128)) begin
        _temp_sensor_range = 3;
        _temp_sensor_value = 90 - 128;
        return;
    end
    if (temperature > (90 + 127)) begin
        _temp_sensor_range = 3;
        _temp_sensor_value = 90 + 127;
        return;
    end
    _temp_sensor_value = temperature;
    if (temperature < 0)
        _temp_sensor_range = 3;
    else if (temperature < 45)
        _temp_sensor_range = 0;
    else if (temperature < 85)
        _temp_sensor_range = 1;
    else if (temperature < 95)
        _temp_sensor_range = 2;
    else
        _temp_sensor_range = 3;
endfunction

function void InitTable();
    int a_long_time_ago;
    int many_cycles_ago;
    a_long_time_ago = -1000000;  // 1000 ns
    many_cycles_ago = -100000;    // 100000 cycles
    CloseAllBanks();
    for (int rank=0;rank<MAX_RANKS;rank++) begin
        for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
            for (int ba=0;ba< MAX_BANKS_PER_GROUP;ba++) begin
                _cACT_by_bank[rank][bg][ba] = '0;
                _tACT_by_bank[rank][bg][ba] = a_long_time_ago;
                _cPRE_by_bank[rank][bg][ba] = '0;
                _cWR_by_bank[rank][bg][ba] = '0;
                _cRD_by_bank[rank][bg][ba] = '0;
                _cWRA_by_bank[rank][bg][ba] = '0;
                _cRDA_by_bank[rank][bg][ba] = '0;
                _cAP_delay_by_bank[rank][bg][ba] ='0;
                _LMR_cache[bg][ba] = 'x;
            end
        end
    end
    for (int rank=0;rank<MAX_RANKS;rank++) begin
        _cREF_by_rank[rank] = many_cycles_ago;
        _cREF_fly_by_rank[rank] = many_cycles_ago;
        for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
            _cACT_by_group[rank][bg] = '0;
            _tACT_by_group[rank][bg] = a_long_time_ago;
            _cWR_by_group[rank][bg] = '0;
            _cRD_by_group[rank][bg] = '0;
        end
    end
    _cRD_any_bank = many_cycles_ago;
    _cRDA_any_bank = many_cycles_ago;
    _cRD_mpr = many_cycles_ago;
    _cWR_any_bank = many_cycles_ago;
    _cWRA_any_bank = many_cycles_ago;
    _cWR_mpr = many_cycles_ago;
    _cPRE_any_bank = many_cycles_ago;
    _cACT_any_bank = many_cycles_ago;
    _tACT_any_bank = a_long_time_ago;
    _cLMR_any_bank = many_cycles_ago;
    _cLMR_ignored = many_cycles_ago;
    _cLMR_extend_tMRD = many_cycles_ago;
    _cREF_any_rank = many_cycles_ago;
    _cPREA = many_cycles_ago;
    _cBST = many_cycles_ago;
    _cNOCLK = many_cycles_ago;
    _cSREFE = many_cycles_ago;
    _cSREFX = many_cycles_ago;
    _cPDX = many_cycles_ago;
    _cPPDE = many_cycles_ago;
    _cAPDE = many_cycles_ago;
    _cZQ_any = many_cycles_ago;
    _cZQCL_init = many_cycles_ago;
    _cZQCL = many_cycles_ago;
    _cZQCS = many_cycles_ago;
    _tPDX = a_long_time_ago;
    _tPPDE = a_long_time_ago;
    _tAPDE = a_long_time_ago;
    _tSREFX = a_long_time_ago;
    _tSREFE = a_long_time_ago;
    _tREF_any_bank = a_long_time_ago;
    _tpreamble_training_entry = a_long_time_ago;
    _tpreamble_training_exit = a_long_time_ago;
    _cMPS_entry = many_cycles_ago;
    _cMPS_exit = many_cycles_ago;
    _cDLL_reset = many_cycles_ago;
    _in_self_refresh = 0;
    _in_precharge_pd = 0;
    _in_active_pd = 0;
    _in_max_power_save = 0;
    _max_power_save_exit_cs = 0;
    _cFAWs.delete();
    for (int i=0;i<FAW_DEPTH;i++) begin
        _cFAWs.push_back(0);
    end
    _cODT_high = many_cycles_ago;
    _cODT_low = many_cycles_ago;
    _parity_block_commands = 0;
    _tparity_error_begin = a_long_time_ago;
    _tparity_block_commands_on = a_long_time_ago;
    _tparity_block_commands_off = a_long_time_ago;
    _ODT_last_transition = 0;
    _ODT_sync = 1;
    _last_DLL_state = 0;
    _delayed_lmr_cycles.delete();
    _delayed_lmr_mode_configs.delete();
    _delayed_lmr_pkts.delete();
    _temp_sensor_range = 'b11;
    _MPR_default_pattern[0] = MPR_PAT_DEFAULT0;
    _MPR_default_pattern[1] = MPR_PAT_DEFAULT1;
    _MPR_default_pattern[2] = MPR_PAT_DEFAULT2;
    _MPR_default_pattern[3] = MPR_PAT_DEFAULT3;
    _MPR_temp[0] = MPR_TEMP0;
    _MPR_temp[1] = MPR_TEMP1;
    _MPR_temp[2] = MPR_TEMP2;
    _MPR_temp[3] = MPR_TEMP3;
    _MPR_pattern[0] = _MPR_default_pattern[0];
    _MPR_pattern[1] = _MPR_default_pattern[1];
    _MPR_pattern[2] = _MPR_default_pattern[2];
    _MPR_pattern[3] = _MPR_default_pattern[3];
    WriteParityErrorLog(.mpr3('0), .mpr2('1), .mpr1('1), .mpr0('1));
    // Insert normal bank count keys.
    for (longint i=0;i<_dut_config.banks_per_group * _dut_config.bank_groups;i++) begin
        rank_by_bank[i] = i / _dut_config.banks_per_rank;
    end
    // Insert combined bank keys.
    for(int group=0;group<_dut_config.bank_groups;group++) begin
        for(int bank=0;bank<_dut_config.banks_per_group;bank++) begin
            rank_by_bank[{group,bank}] = {group[1:0],bank[1:0]} / _dut_config.banks_per_rank;
        end
    end
endfunction 

function int CycleIndex(int cycle);
    int MAXCYCLEPIPE;
    MAXCYCLEPIPE = 10000; // value > the biggest cycle based spec
    CycleIndex = cycle%MAXCYCLEPIPE;
endfunction

function int GetLMRAddr(DDR4_cmd cmdpkt);
    int bank_group, bank, addr, lmr_addr;
    
    bank_group = cmdpkt.bank_group & _dut_config.bank_group_mask;
    bank = cmdpkt.bank & _dut_config.bank_mask;
    addr = cmdpkt.addr & ((2**MAX_ADDR_BITS)-1);
    lmr_addr = addr | (bank << BANK_SHIFT) | (bank_group << BANK_GROUP_SHIFT);
    return lmr_addr;
endfunction
    
function UTYPE_DutModeConfig AddrToModeDecode(int addr, UTYPE_DutModeConfig modeconfig_in, bit check_reserved_bits = 1);
    if (ReservedBitsSet(addr) && (1 == check_reserved_bits)) begin
        if (_debug)
            $display("%0s::StateTable WARNING::LMR %0h has reserved bits set and modeconfig_in will not be modified. @%0t.", 
                    _id, addr, $time);
        return modeconfig_in;
    end
    AddrToModeDecode = modeconfig_in;
    
    if ((addr & MR7) == MR7) begin
    end else if ((addr & MR6) == MR6) begin
        if ((addr & MR6_VREF_MASK) == MR6_VREF_ENB) begin // training_offset/range are only updated when vref is enabled.
            AddrToModeDecode.vref_training = 1;
            AddrToModeDecode.vref_training_offset = ((addr & MR6_VREF_OFFSET_MASK) & ~MR6) >> MR6_VREF_OFFSET_SHIFT;
            if ((addr & MR6_VREF_RANGE_2) == MR6_VREF_RANGE_MASK)
                AddrToModeDecode.vref_training_range = 1;
            else
                AddrToModeDecode.vref_training_range = 0;
        end else begin
            AddrToModeDecode.vref_training = 0;
        end
        case (addr & MR6_tCCDL_MASK)
            MR6_tCCDL_4: AddrToModeDecode.tCCD_L = 4;
            MR6_tCCDL_5: AddrToModeDecode.tCCD_L = 5;
            MR6_tCCDL_6: AddrToModeDecode.tCCD_L = 6;
            MR6_tCCDL_7: AddrToModeDecode.tCCD_L = 7;
            MR6_tCCDL_8: AddrToModeDecode.tCCD_L = 8;
            default: AddrToModeDecode.tCCD_L = 8;
        endcase
    end else if ((addr & MR5) == MR5) begin
        AddrToModeDecode.CA_parity_latency = CAPARITY_L0;
        if (1 == _dut_config.CA_parity_latency_feature) begin
            case (addr & MR5_PARITY_LATENCY_MASK)
                MR5_PARITY_LATENCY_0: AddrToModeDecode.CA_parity_latency = CAPARITY_L0;
                MR5_PARITY_LATENCY_4: AddrToModeDecode.CA_parity_latency = CAPARITY_L4;
                MR5_PARITY_LATENCY_5: AddrToModeDecode.CA_parity_latency = CAPARITY_L5;
                MR5_PARITY_LATENCY_6: AddrToModeDecode.CA_parity_latency = CAPARITY_L6;
                MR5_PARITY_LATENCY_RES4: AddrToModeDecode.CA_parity_latency = CAPARITY_RES4;
                MR5_PARITY_LATENCY_RES5: AddrToModeDecode.CA_parity_latency = CAPARITY_RES5;
                MR5_PARITY_LATENCY_RES6: AddrToModeDecode.CA_parity_latency = CAPARITY_RES6;
                MR5_PARITY_LATENCY_RES7: AddrToModeDecode.CA_parity_latency = CAPARITY_RES7;
                default: AddrToModeDecode.CA_parity_latency = CAPARITY_L0;
            endcase
        end
        if ((1 == _dut_config.crc_error_feature) && ((addr & MR5_CRC_ERROR) == MR5_CRC_MASK))
            AddrToModeDecode.crc_error = 1;
        else
            AddrToModeDecode.crc_error = 0;
        if ((addr & MR5_PARITY_ERROR_MASK) == MR5_PARITY_ERROR_MASK)
            AddrToModeDecode.CA_parity_error = 1;
        else
            AddrToModeDecode.CA_parity_error = 0;
        if ((addr & MR5_ODT_BUFFER_MASK) == MR5_ODT_BUFFER_MASK)
            AddrToModeDecode.odt_buffer_disable = 1;
        else
            AddrToModeDecode.odt_buffer_disable = 0;
        AddrToModeDecode.rtt_park = RTTP_DIS;
        case (addr & MR5_RTTP_MASK)
            MR5_RTTP_DIS: AddrToModeDecode.rtt_park = RTTP_DIS;
            MR5_RTTP_60: AddrToModeDecode.rtt_park = RTTP_60;
            MR5_RTTP_120: AddrToModeDecode.rtt_park = RTTP_120;
            MR5_RTTP_40: AddrToModeDecode.rtt_park = RTTP_40;
            MR5_RTTP_240: AddrToModeDecode.rtt_park = RTTP_240;
            MR5_RTTP_48: AddrToModeDecode.rtt_park = RTTP_48;
            MR5_RTTP_80: AddrToModeDecode.rtt_park = RTTP_80;
            MR5_RTTP_34: AddrToModeDecode.rtt_park = RTTP_34;
            default: AddrToModeDecode.rtt_park = RTTP_DIS;
        endcase
        if ((1 == _dut_config.dll_frozen_feature) && ((addr & MR5_DLL_FROZEN_ENB) == MR5_DLL_FROZEN_MASK))
            AddrToModeDecode.dll_frozen = 1;
        else
            AddrToModeDecode.dll_frozen = 0;
        if ((1 == _dut_config.sticky_parity_error_feature) && ((addr & MR5_STICKY_PARITY_ENB) == MR5_STICKY_PARITY_MASK))
            AddrToModeDecode.sticky_parity_error = 1;
        else
            AddrToModeDecode.sticky_parity_error = 0;
        if (((1 == _dut_config.dm_enable_feature) && ((addr & MR5_DM_MASK) == MR5_DM_ENB)))
            AddrToModeDecode.latched_dm_enable = 1;
        else
            AddrToModeDecode.latched_dm_enable = 0;
        if (((1 == _dut_config.dm_enable_feature) && ((addr & MR5_DM_MASK) == MR5_DM_ENB)) && (0 == modeconfig_in.tDQS))
            AddrToModeDecode.dm_enable = 1;
        else begin
            AddrToModeDecode.dm_enable = 0;
        end
        if (((1 == _dut_config.write_dbi_feature) && ((addr & MR5_WRITE_DBI_MASK) == MR5_WRITE_DBI_MASK)) && (4 != _dut_config.by_mode))
            AddrToModeDecode.latched_write_dbi = 1;
        else
            AddrToModeDecode.latched_write_dbi = 0;
        if (((1 == _dut_config.write_dbi_feature) && ((addr & MR5_WRITE_DBI_MASK) == MR5_WRITE_DBI_MASK)) && 
             (0 == AddrToModeDecode.tDQS) && (0 == AddrToModeDecode.dm_enable) && (4 != _dut_config.by_mode))
            AddrToModeDecode.write_dbi = 1;
        else
            AddrToModeDecode.write_dbi = 0;
        if (((1 == _dut_config.read_dbi_feature) && ((addr & MR5_READ_DBI_MASK) == MR5_READ_DBI_MASK)) && (4 != _dut_config.by_mode))
            AddrToModeDecode.latched_read_dbi = 1;
        else
            AddrToModeDecode.latched_read_dbi = 0;
        if (((1 == _dut_config.read_dbi_feature) && ((addr & MR5_READ_DBI_MASK) == MR5_READ_DBI_MASK)) && 
             (0 == AddrToModeDecode.tDQS) && (4 != _dut_config.by_mode))
            AddrToModeDecode.read_dbi = 1;
        else
            AddrToModeDecode.read_dbi = 0;
    end else if ((addr & MR4) == MR4) begin
        if ((1 == _dut_config.MPS_feature) && ((addr & MR4_MPS_MASK) == MR4_MPS_MASK))
            AddrToModeDecode.MPS = 1;
        else
            AddrToModeDecode.MPS = 0;
        if ((addr & MR4_TCRR_MASK) == MR4_TCRR_EXT)
            AddrToModeDecode.TCR_range = 1;
        else
            AddrToModeDecode.TCR_range = 0;
        if ((addr & MR4_TCRM_MASK) == MR4_TCRM_MASK) begin
            AddrToModeDecode.TCR_mode = 1;
            AddrToModeDecode.refresh_mode = REF_1X; // Disable fg refresh.
        end else
            AddrToModeDecode.TCR_mode = 0;
        if ((addr & MR4_VREFMON_MASK) == MR4_VREFMON_ENB)
            AddrToModeDecode.vref_monitor = 1;
        else
            AddrToModeDecode.vref_monitor = 0;
        AddrToModeDecode.CAL = DEF_CAL;
        if (1 == _dut_config.CAL_feature) begin
            case (addr & MR4_CAL_MASK)
                MR4_CAL0: AddrToModeDecode.CAL = 0;
                MR4_CAL3: AddrToModeDecode.CAL = 3;
                MR4_CAL4: AddrToModeDecode.CAL = 4;
                MR4_CAL5: AddrToModeDecode.CAL = 5;
                MR4_CAL6: AddrToModeDecode.CAL = 6;
                MR4_CAL8: AddrToModeDecode.CAL = 8;
                default: AddrToModeDecode.CAL = DEF_CAL;
            endcase
        end
        if ((addr & MR4_SREF_FAST) == MR4_SREF_MASK)
            AddrToModeDecode.fast_self_refresh = 1;
        else
            AddrToModeDecode.fast_self_refresh = 0;
        if ((1 == _dut_config.preamble_training_feature) && ((addr & MR4_PRETRAIN_MASK) == MR4_PRETRAIN_MASK))
            AddrToModeDecode.preamble_training = 1;
        else
            AddrToModeDecode.preamble_training = 0;
        if ((1 == _dut_config.rd_preamble_clocks_feature) && ((addr & MR4_RDPRE_MASK) == MR4_RDPRE_2CLK))
            AddrToModeDecode.rd_preamble_clocks = 2;
        else
            AddrToModeDecode.rd_preamble_clocks = 1;
        if ((1 == _dut_config.wr_preamble_clocks_feature) && ((addr & MR4_WRPRE_MASK) == MR4_WRPRE_2CLK))
            AddrToModeDecode.wr_preamble_clocks = 2;
        else
            AddrToModeDecode.wr_preamble_clocks = 1;
        if ((1 == _dut_config.ppr_feature) && ((addr & MR4_PPR_MASK) == MR4_PPR_ENB))
            AddrToModeDecode.ppr_enable = 1;
        else
            AddrToModeDecode.ppr_enable = 0;
    end else if ((addr & MR3) == MR3) begin
        AddrToModeDecode.MPR_page = MPR_PATTERN;
        case (addr & MR3_MPR_PAGE_MASK)
            MR3_MPR_PATTERN: AddrToModeDecode.MPR_page = MPR_PATTERN;
            MR3_MPR_PARITY: AddrToModeDecode.MPR_page = MPR_PARITY;
            MR3_MPR_MODEREG: AddrToModeDecode.MPR_page = MPR_MODEREG;
            MR3_MPR_PAGE3: AddrToModeDecode.MPR_page = MPR_PAGE3;
            default: AddrToModeDecode.MPR_page = MPR_PATTERN;
        endcase
        if ((addr & MR3_MPR_ENB_MASK) == MR3_MPR_ENB_MASK)
            AddrToModeDecode.MPR_enable = 1;
        else
            AddrToModeDecode.MPR_enable = 0;
        if ((1 == _dut_config.gear_down_feature) && ((addr & MR3_GEARDOWN_MASK) == MR3_GEARDOWN_MASK))
            AddrToModeDecode.gear_down = 1;
        else
            AddrToModeDecode.gear_down = 0;
        if ((1 == _dut_config.perdram_addr_feature) && ((addr & MR3_PERDRAM_MASK) == MR3_PERDRAM_MASK))
            AddrToModeDecode.perdram_addr = 1;
        else
            AddrToModeDecode.perdram_addr = 0;
        if ((addr & MR3_TEMP_MASK) == MR3_TEMP_ENB)
            AddrToModeDecode.temp_sense_enable = 1;
        else
            AddrToModeDecode.temp_sense_enable = 0;
        if (1 == _dut_config.refresh_mode_feature) begin
            case (addr & MR3_REFMODE_MASK)
                MR3_REFMODE_NORM: AddrToModeDecode.refresh_mode = REF_1X;
                MR3_REFMODE_2X: AddrToModeDecode.refresh_mode = REF_2X;
                MR3_REFMODE_4X: AddrToModeDecode.refresh_mode = REF_4X;
                MR3_REFMODE_RES3: AddrToModeDecode.refresh_mode = REF_RES3;
                MR3_REFMODE_RES4: AddrToModeDecode.refresh_mode = REF_RES4;
                MR3_REFMODE_FLY2X: AddrToModeDecode.refresh_mode = REF_FLY2X;
                MR3_REFMODE_FLY4X: AddrToModeDecode.refresh_mode = REF_FLY4X;
                MR3_REFMODE_RES7: AddrToModeDecode.refresh_mode = REF_RES7;
                default: AddrToModeDecode.refresh_mode = REF_1X;
            endcase
            if (REF_1X != AddrToModeDecode.refresh_mode)
                AddrToModeDecode.TCR_mode = 0;
        end
        AddrToModeDecode.delay_write_crc_dm = DEF_DELAY_WRITE;
        case (addr & MR3_DELAY_WRITE_MASK)
            MR3_DELAY_WRITE_4: AddrToModeDecode.delay_write_crc_dm = DELAY_WRITE_4;
            MR3_DELAY_WRITE_5: AddrToModeDecode.delay_write_crc_dm = DELAY_WRITE_5;
            MR3_DELAY_WRITE_6: AddrToModeDecode.delay_write_crc_dm = DELAY_WRITE_6;
            MR3_DELAY_WRITE_RES3: AddrToModeDecode.delay_write_crc_dm = DELAY_WRITE_RES3;
            default: AddrToModeDecode.delay_write_crc_dm = DEF_DELAY_WRITE;
        endcase
        AddrToModeDecode.MPR_mode = DEF_MPR_MODE;
        case (addr & MR3_MPR_MODE_MASK)
            MR3_MPR_SERIAL: AddrToModeDecode.MPR_mode = SERIAL;
            MR3_MPR_PARALLEL: AddrToModeDecode.MPR_mode = PARALLEL;
            MR3_MPR_STAGGERED: AddrToModeDecode.MPR_mode = STAGGERED;
            MR3_MPR_RES3: AddrToModeDecode.MPR_mode = MPR_RES3;
            default: AddrToModeDecode.MPR_mode = DEF_MPR_MODE;
        endcase
    end else if ((addr & MR2) == MR2) begin
        AddrToModeDecode.trr_ba = 0;
        case (addr & MR2_TRR_BA_MASK)
            MR2_TRR_BA0: AddrToModeDecode.trr_ba = 0;
            MR2_TRR_BA1: AddrToModeDecode.trr_ba = 1;
            MR2_TRR_BA2: AddrToModeDecode.trr_ba = 2;
            MR2_TRR_BA3: AddrToModeDecode.trr_ba = 3;
            default: AddrToModeDecode.trr_ba = 0;
        endcase
        AddrToModeDecode.trr_bg = 0;
        case (addr & MR2_TRR_BG_MASK)
            MR2_TRR_BG0: AddrToModeDecode.trr_bg = 0;
            MR2_TRR_BG1: AddrToModeDecode.trr_bg = 1;
            MR2_TRR_BG2: AddrToModeDecode.trr_bg = 2;
            MR2_TRR_BG3: AddrToModeDecode.trr_bg = 3;
            default: AddrToModeDecode.trr_bg = 0;
        endcase
        AddrToModeDecode.CWL = DEF_CWL;
        case (addr & MR2_CWL_MASK)
            MR2_CWL9: AddrToModeDecode.CWL = 9;
            MR2_CWL10: AddrToModeDecode.CWL = 10;
            MR2_CWL11: AddrToModeDecode.CWL = 11;
            MR2_CWL12: AddrToModeDecode.CWL = 12;
            MR2_CWL14: AddrToModeDecode.CWL = 14;
            MR2_CWL16: AddrToModeDecode.CWL = 16;
            MR2_CWL18: AddrToModeDecode.CWL = 18;
            default: AddrToModeDecode.CWL = DEF_CWL;
        endcase
        AddrToModeDecode.LPASR = DEF_LPASR;
        if (1 == _dut_config.LPASR_feature) begin
            case (addr & MR2_LPASR_MASK)
                MR2_LPASR_NORM: AddrToModeDecode.LPASR = LPASR_NORM;
                MR2_LPASR_EXT: AddrToModeDecode.LPASR = LPASR_EXTENDED;
                MR2_LPASR_RED: AddrToModeDecode.LPASR = LPASR_REDUCED;
                MR2_LPASR_AUTO: AddrToModeDecode.LPASR = LPASR_AUTO;
                default: AddrToModeDecode.LPASR = DEF_LPASR;
            endcase
        end
        AddrToModeDecode.rtt_write = RTTW_DIS;
        case (addr & MR2_RTTW_MASK)
            MR2_RTTW_DIS: AddrToModeDecode.rtt_write = RTTW_DIS;
            MR2_RTTW_120: AddrToModeDecode.rtt_write = RTTW_120;
            MR2_RTTW_240: AddrToModeDecode.rtt_write = RTTW_240;
            MR2_RTTW_Z: AddrToModeDecode.rtt_write = RTTW_Z;
            MR2_RTTW_80: AddrToModeDecode.rtt_write = RTTW_80;
            MR2_RTTW_RES5: AddrToModeDecode.rtt_write = RTTW_RES5;
            MR2_RTTW_RES6: AddrToModeDecode.rtt_write = RTTW_RES6;
            MR2_RTTW_RES7: AddrToModeDecode.rtt_write = RTTW_RES7;
            default: AddrToModeDecode.rtt_write = RTTW_DIS;
        endcase
        if ((addr & MR2_TRR_ENB_MASK) == MR2_TRR_ENB)
            AddrToModeDecode.trr_enable = 1;
        else
            AddrToModeDecode.trr_enable = 0;
        if ((1 == _dut_config.write_crc_feature) && ((addr & MR2_CRC_WRITE_DATA_MASK) == MR2_CRC_WRITE_DATA_MASK))
            AddrToModeDecode.write_crc_enable = 1;
        else
            AddrToModeDecode.write_crc_enable = 0;
    end else if ((addr & MR1) == MR1) begin
        if ((addr & MR1_DLL_MASK) == MR1_DLL_MASK) begin
            AddrToModeDecode.DLL_enable = 1;
        end else begin
            AddrToModeDecode.DLL_enable = 0;
        end
        AddrToModeDecode.AL = 0;
        AddrToModeDecode.AL_reg = rAL0;
        case (addr & MR1_AL_MASK)
            MR1_AL0: begin AddrToModeDecode.AL = 0; AddrToModeDecode.AL_reg = rAL0;end
            MR1_ALCLN1: begin AddrToModeDecode.AL = AddrToModeDecode.CL - 1;
                AddrToModeDecode.AL_reg = rALN1; end
            MR1_ALCLN2: begin AddrToModeDecode.AL = AddrToModeDecode.CL - 2;
                AddrToModeDecode.AL_reg = rALN2; end
            default: begin AddrToModeDecode.AL = 0; AddrToModeDecode.AL_reg = rAL0;end
        endcase
        AddrToModeDecode.ODI = ODI_34;
        case (addr & MR1_ODI_MASK)
            MR1_ODI_34: AddrToModeDecode.ODI = ODI_34;
            MR1_ODI_48: AddrToModeDecode.ODI = ODI_48;
            MR1_ODI_40: AddrToModeDecode.ODI = ODI_40;
            MR1_ODI_RES3: AddrToModeDecode.ODI = ODI_RES3;
            default: AddrToModeDecode.ODI = ODI_34;
        endcase
        if ((addr & MR1_WL_MASK) == MR1_WL_MASK)
            AddrToModeDecode.write_levelization = 1;
        else
            AddrToModeDecode.write_levelization = 0;
        AddrToModeDecode.rtt_nominal = RTTN_DIS;
        case (addr & MR1_RTTN_MASK)
            MR1_RTTN_DIS: AddrToModeDecode.rtt_nominal = RTTN_DIS;
            MR1_RTTN_60: AddrToModeDecode.rtt_nominal = RTTN_60;
            MR1_RTTN_120: AddrToModeDecode.rtt_nominal = RTTN_120;
            MR1_RTTN_40: AddrToModeDecode.rtt_nominal = RTTN_40;
            MR1_RTTN_240: AddrToModeDecode.rtt_nominal = RTTN_240;
            MR1_RTTN_48: AddrToModeDecode.rtt_nominal = RTTN_48;
            MR1_RTTN_80: AddrToModeDecode.rtt_nominal = RTTN_80;
            MR1_RTTN_34: AddrToModeDecode.rtt_nominal = RTTN_34;
            default: AddrToModeDecode.rtt_nominal = RTTN_DIS;
        endcase
        if ((1 == _dut_config.tDQS_feature) && ((addr & MR1_TDQS_MASK) == MR1_TDQS_MASK) &&
            (8 == _dut_config.by_mode)) begin
            // tDQS enabled automatically disables DM/write_dbi/read_dbi
            AddrToModeDecode.dm_enable = 0;
            AddrToModeDecode.read_dbi = 0;
            AddrToModeDecode.write_dbi = 0;
            modeconfig_in.dm_enable = 0;
            modeconfig_in.read_dbi = 0;
            modeconfig_in.write_dbi = 0;
            if (1 != modeconfig_in.tDQS) begin
                AddrToModeDecode.latched_dm_enable = AddrToModeDecode.dm_enable; 
                AddrToModeDecode.latched_read_dbi = AddrToModeDecode.read_dbi;
                AddrToModeDecode.latched_write_dbi = AddrToModeDecode.write_dbi;
            end
            AddrToModeDecode.tDQS = 1;
        end else begin
            // tDQS disabled automatically restores DM/write_dbi/read_dbi
            AddrToModeDecode.tDQS = 0;
            AddrToModeDecode.dm_enable = AddrToModeDecode.latched_dm_enable;
            AddrToModeDecode.read_dbi = AddrToModeDecode.latched_read_dbi;
            AddrToModeDecode.write_dbi = AddrToModeDecode.latched_write_dbi;
        end
        if ((addr & MR1_QOFF_MASK) == MR1_QOFF_MASK)
            AddrToModeDecode.qOff = 1;
        else
            AddrToModeDecode.qOff = 0;
    end else begin
        int oldCL;
        oldCL = AddrToModeDecode.CL;
        
        AddrToModeDecode.BL = 8;
        case (addr & MR0_BL_MASK)
            MR0_BL8: begin AddrToModeDecode.BL = 8; AddrToModeDecode.BL_reg = rBL8; end
            MR0_BLFLY: begin AddrToModeDecode.BL = 8; AddrToModeDecode.BL_reg =  rBLFLY; end
            MR0_BL4: begin AddrToModeDecode.BL = 4; AddrToModeDecode.BL_reg = rBL4; end
            default: begin AddrToModeDecode.BL = DEF_BL; AddrToModeDecode.BL_reg = rBLFLY; end
        endcase
        AddrToModeDecode.BT = SEQ;
        case (addr & MR0_BT_MASK)
            MR0_SEQ: AddrToModeDecode.BT = SEQ;
            MR0_INTLV: AddrToModeDecode.BT = INT;
            default: AddrToModeDecode.BT = DEF_BT;
        endcase
        AddrToModeDecode.CL = DEF_CL;
        case (addr & MR0_CL_MASK)
            MR0_CL5: AddrToModeDecode.CL = 5;
            MR0_CL9: AddrToModeDecode.CL = 9;
            MR0_CL10: AddrToModeDecode.CL = 10;
            MR0_CL11: AddrToModeDecode.CL = 11;
            MR0_CL12: AddrToModeDecode.CL = 12;
            MR0_CL13: AddrToModeDecode.CL = 13;
            MR0_CL14: AddrToModeDecode.CL = 14;
            MR0_CL15: AddrToModeDecode.CL = 15;
            MR0_CL16: AddrToModeDecode.CL = 16;
            MR0_CL17: AddrToModeDecode.CL = 17;
            MR0_CL18: AddrToModeDecode.CL = 18;
            MR0_CL19: AddrToModeDecode.CL = 19;
            MR0_CL20: AddrToModeDecode.CL = 20;
            MR0_CL21: AddrToModeDecode.CL = 21;
            MR0_CL22: AddrToModeDecode.CL = 22;
            MR0_CL24: AddrToModeDecode.CL = 24;
            default: AddrToModeDecode.CL = DEF_CL;
        endcase
        if (AddrToModeDecode.AL != 0)
            AddrToModeDecode.AL = AddrToModeDecode.AL + (AddrToModeDecode.CL - oldCL);
        AddrToModeDecode.DLL_reset = 0;
        if ((addr & MR0_DLL_RESET) == MR0_DLL_RESET) begin
            AddrToModeDecode.DLL_reset = 1;
        end
        AddrToModeDecode.write_recovery = 10;
        case (addr & MR0_WR_MASK)
            MR0_WR10: AddrToModeDecode.write_recovery = 10;
            MR0_WR12: AddrToModeDecode.write_recovery = 12;
            MR0_WR14: AddrToModeDecode.write_recovery = 14;
            MR0_WR16: AddrToModeDecode.write_recovery = 16;
            MR0_WR18: AddrToModeDecode.write_recovery = 18;
            MR0_WR20: AddrToModeDecode.write_recovery = 20;
            MR0_WR24: AddrToModeDecode.write_recovery = 24;
            MR0_WR_RES7: AddrToModeDecode.write_recovery = 10;
            default: AddrToModeDecode.write_recovery = DEF_WR;
        endcase
    end
    // calculate values everytime since they may be on different LMR registers
    AddrToModeDecode.RL = AddrToModeDecode.CL + AddrToModeDecode.AL + AddrToModeDecode.CA_parity_latency - 
                          ((1 == AddrToModeDecode.DLL_enable) ? 0 : 1);
    AddrToModeDecode.RL = AddrToModeDecode.RL + ((0 == AddrToModeDecode.DLL_enable) ? (_timing.tDQSCK_dll_off/_timing.tCK) : 0);
    AddrToModeDecode.WL_calculated = AddrToModeDecode.CWL + AddrToModeDecode.AL + AddrToModeDecode.CA_parity_latency;
endfunction

function void ModeToAddrDecode(UTYPE_DutModeConfig modeconfig, output reg [MODEREG_BITS-1:0] mode_regs[MAX_MODEREGS]);
    reg [MODEREG_BITS-1:0] bl_bits, bt_bits, cl_bits, dll_reset_bits, wr_bits;
    reg [MODEREG_BITS-1:0] odi_bits, rtt_bits, al_bits, wl_bits, dll_enb_bits, tdqs_bits, qoff_bits;
    reg [MODEREG_BITS-1:0] trr_ba_bits, trr_bg_bits, cwl_bits, lpasr_bits, wrtt_bits, trr_enable_bits, crc_write_data_bits;
    reg [MODEREG_BITS-1:0] mpr_page_bits, mpr_enable_bits, mpr_mode_bits, gear_down_bits, perdram_bits, delay_write_bits,
                           refresh_mode_bits, ts_bits;
    reg [MODEREG_BITS-1:0] dcc_bits, mps_bits, tcrr_bits, tcrm_bits, vref_monitor_bits, cal_bits,
                           fast_self_refresh_bits, preamble_training_bits, rd_preamble_bits, wr_preamble_bits, ppr_enable_bits;
    reg [MODEREG_BITS-1:0] ca_parity_latency_bits, crc_error_bits, ca_parity_error_bits, odt_buffer_disable_bits,
                           rttp_bits, sticky_parity_bits, dll_frozen_bits, dm_bits, write_dbi_bits, read_dbi_bits;
    reg [MODEREG_BITS-1:0] vref_offset_bits, vref_range_bits, vref_training_bits, tCCD_L_bits;

    // default to all 0s (but set the MR select bits)
    for (int i=0;i<MAX_MODEREGS;i++) begin
        mode_regs[i] = '0 | (i << BANK_SHIFT);
    end
    
    // MR0
    case (modeconfig.BL_reg)
        rBL8: bl_bits = MR0_BL8;
        rBLFLY: bl_bits = MR0_BLFLY;
        rBL4: bl_bits = MR0_BL4;
        3: bl_bits = MR0_BLRES;
        default: bl_bits = MR0_DEF_BL;
    endcase
    
    case (modeconfig.BT)
        SEQ: bt_bits = MR0_SEQ;
        INT: bt_bits = MR0_INTLV;
        default: bt_bits = MR0_DEF_BT;
    endcase
    
    case (modeconfig.CL)
        5: cl_bits = MR0_CL5;
        9: cl_bits = MR0_CL9;
        10: cl_bits = MR0_CL10;
        11: cl_bits = MR0_CL11;
        12: cl_bits = MR0_CL12;
        13: cl_bits = MR0_CL13;
        14: cl_bits = MR0_CL14;
        15: cl_bits = MR0_CL15;
        16: cl_bits = MR0_CL16;
        17: cl_bits = MR0_CL17;
        18: cl_bits = MR0_CL18;
        19: cl_bits = MR0_CL19;
        20: cl_bits = MR0_CL20;
        21: cl_bits = MR0_CL21;
        22: cl_bits = MR0_CL22;
        24: cl_bits = MR0_CL24;
        default: cl_bits = MR0_DEF_CL;
    endcase
    
    dll_reset_bits = '0;
    if (modeconfig.DLL_reset)
        dll_reset_bits = MR0_DLL_RESET;
    
    case (modeconfig.write_recovery)
        10: wr_bits = MR0_WR10;
        12: wr_bits = MR0_WR12;
        14: wr_bits = MR0_WR14;
        16: wr_bits = MR0_WR16;
        18: wr_bits = MR0_WR18;
        20: wr_bits = MR0_WR20;
        24: wr_bits = MR0_WR24;
        default: wr_bits = MR0_DEF_WR;
    endcase
    
    mode_regs[0] = bl_bits | bt_bits | cl_bits | dll_reset_bits | wr_bits;
    
    // MR1
    if (modeconfig.DLL_enable)
        dll_enb_bits = MR1_DLL_ENB;
    else
        dll_enb_bits = MR1_DLL_DIS;
    
    case (modeconfig.AL_reg)
        rAL0: al_bits = MR1_AL0;
        rALN1: al_bits = MR1_ALCLN1;
        rALN2: al_bits = MR1_ALCLN2;
        default: al_bits = MR1_DEF_AL;
    endcase
    
    case (modeconfig.ODI)
        ODI_34: odi_bits = MR1_ODI_34;
        ODI_48: odi_bits = MR1_ODI_48;
        ODI_40: odi_bits = MR1_ODI_40;
        ODI_RES3: odi_bits = MR1_ODI_RES3;
        default: odi_bits = MR1_ODI_34;
    endcase
    
    if (modeconfig.write_levelization)
        wl_bits = MR1_WL_ENB;
    else
        wl_bits = MR1_WL_DIS;
        
    case (modeconfig.rtt_nominal)
        RTTN_DIS: rtt_bits = MR1_RTTN_DIS;
        RTTN_60: rtt_bits = MR1_RTTN_60;
        RTTN_120: rtt_bits = MR1_RTTN_120;
        RTTN_40: rtt_bits = MR1_RTTN_40;
        RTTN_34: rtt_bits = MR1_RTTN_34;
        RTTN_48: rtt_bits = MR1_RTTN_48;
        RTTN_80: rtt_bits = MR1_RTTN_80;
        RTTN_240: rtt_bits = MR1_RTTN_240;
        default: rtt_bits = MR1_DEF_RTTN;
    endcase
    
    if (modeconfig.tDQS)
        tdqs_bits = MR1_TDQS_ENB;
    else
        tdqs_bits = MR1_TDQS_DIS;
    
    if (modeconfig.qOff)
        qoff_bits = MR1_QOFF_DIS;
    else
        qoff_bits = MR1_QOFF_ENB;
    
    mode_regs[1] = dll_enb_bits | odi_bits | rtt_bits | al_bits | wl_bits | tdqs_bits | qoff_bits;
    
    // MR2
    case (modeconfig.trr_ba)
        0: trr_ba_bits = MR2_TRR_BA0;
        1: trr_ba_bits = MR2_TRR_BA1;
        2: trr_ba_bits = MR2_TRR_BA2;
        3: trr_ba_bits = MR2_TRR_BA3;
        default: trr_ba_bits = MR2_TRR_BA0;
    endcase
    
    case (modeconfig.trr_bg)
        0: trr_bg_bits = MR2_TRR_BG0;
        1: trr_bg_bits = MR2_TRR_BG1;
        2: trr_bg_bits = MR2_TRR_BG2;
        3: trr_bg_bits = MR2_TRR_BG3;
        default: trr_bg_bits = MR2_TRR_BG0;
    endcase
    
    case (modeconfig.CWL)
        9: cwl_bits = MR2_CWL9;
        10: cwl_bits = MR2_CWL10;
        11: cwl_bits = MR2_CWL11;
        12: cwl_bits = MR2_CWL12;
        14: cwl_bits = MR2_CWL14;
        16: cwl_bits = MR2_CWL16;
        18: cwl_bits = MR2_CWL18;
        default: cwl_bits = MR2_DEF_CWL;
    endcase
    
    case (modeconfig.LPASR)
        LPASR_NORM: lpasr_bits = MR2_LPASR_NORM;
        LPASR_EXTENDED: lpasr_bits = MR2_LPASR_EXT;
        LPASR_REDUCED: lpasr_bits = MR2_LPASR_RED;
        LPASR_AUTO: lpasr_bits = MR2_LPASR_AUTO;
        default: lpasr_bits = MR2_LPASR_DEF;
    endcase
    
    case (modeconfig.rtt_write)
        RTTW_DIS: wrtt_bits = MR2_RTTW_DIS;
        RTTW_120: wrtt_bits = MR2_RTTW_120;
        RTTW_240: wrtt_bits = MR2_RTTW_240;
        RTTW_Z: wrtt_bits = MR2_RTTW_Z;
        RTTW_80: wrtt_bits = MR2_RTTW_80;
        RTTW_RES5: wrtt_bits = MR2_RTTW_RES5;
        RTTW_RES6: wrtt_bits = MR2_RTTW_RES6;
        RTTW_RES7: wrtt_bits = MR2_RTTW_RES7;
        default: wrtt_bits = MR2_RTTW_DIS;
    endcase
    
    if (modeconfig.trr_enable)
        trr_enable_bits = MR2_TRR_ENB;
    else
        trr_enable_bits = MR2_TRR_DIS;
    if (modeconfig.write_crc_enable)
        crc_write_data_bits = MR2_CRC_WRITE_DATA_ENB;
    else
        crc_write_data_bits = MR2_CRC_WRITE_DATA_DIS;
    
    mode_regs[2] = trr_ba_bits | trr_bg_bits | cwl_bits | lpasr_bits | wrtt_bits | trr_enable_bits | crc_write_data_bits;

    // MR3
    case (modeconfig.MPR_page)
        MPR_PATTERN: mpr_page_bits = MR3_MPR_PATTERN;
        MPR_PARITY: mpr_page_bits = MR3_MPR_PARITY;
        MPR_MODEREG: mpr_page_bits = MR3_MPR_MODEREG;
        MPR_PAGE3: mpr_page_bits = MR3_MPR_PAGE3;
        default: mpr_page_bits = MR3_DEF_MPR_PAGE;
    endcase
    if (modeconfig.MPR_enable)
        mpr_enable_bits = MR3_MPR_ENB;
    else
        mpr_enable_bits = MR3_MPR_DIS;
    if (modeconfig.gear_down)
        gear_down_bits = MR3_GEARDOWN_QUARTER;
    else
        gear_down_bits = MR3_GEARDOWN_HALF;
    if (modeconfig.perdram_addr)
        perdram_bits = MR3_PERDRAM_ENB;
    else
        perdram_bits = MR3_PERDRAM_DIS;
    if (modeconfig.temp_sense_enable)
        ts_bits = MR3_TEMP_ENB;
    else
        ts_bits = MR3_TEMP_DIS;
    case (modeconfig.refresh_mode)
        REF_1X: refresh_mode_bits = MR3_REFMODE_NORM;
        REF_2X: refresh_mode_bits = MR3_REFMODE_2X;
        REF_4X: refresh_mode_bits = MR3_REFMODE_4X;
        REF_RES3: refresh_mode_bits = MR3_REFMODE_RES3;
        REF_RES4: refresh_mode_bits = MR3_REFMODE_RES4;
        REF_FLY2X: refresh_mode_bits = MR3_REFMODE_FLY2X;
        REF_FLY4X: refresh_mode_bits = MR3_REFMODE_FLY4X;
        REF_RES7: refresh_mode_bits = MR3_REFMODE_RES7;
        default: refresh_mode_bits = MR3_REFMODE_NORM;
    endcase
    case (modeconfig.delay_write_crc_dm)
       DELAY_WRITE_4: delay_write_bits = MR3_DELAY_WRITE_4;
       DELAY_WRITE_5: delay_write_bits = MR3_DELAY_WRITE_5;
       DELAY_WRITE_6: delay_write_bits = MR3_DELAY_WRITE_6;
       DELAY_WRITE_RES3: delay_write_bits = MR3_DELAY_WRITE_RES3;
        default: mpr_mode_bits = MR3_DEF_DELAY_WRITE;
    endcase
    case (modeconfig.MPR_mode)
        SERIAL: mpr_mode_bits = MR3_MPR_SERIAL;
        PARALLEL: mpr_mode_bits = MR3_MPR_PARALLEL;
        STAGGERED: mpr_mode_bits = MR3_MPR_STAGGERED;
        MPR_RES3: mpr_mode_bits = MR3_MPR_RES3;
        default: mpr_mode_bits = MR3_DEF_MPR_MODE;
    endcase
    mode_regs[3] = mpr_page_bits | mpr_enable_bits | gear_down_bits | perdram_bits | ts_bits | refresh_mode_bits | delay_write_bits | mpr_mode_bits;
            
    // MR4
    if (modeconfig.MPS)
        mps_bits = MR4_MPS_ENB;
    else
        mps_bits = MR4_MPS_DIS;
    if (modeconfig.TCR_range)
        tcrr_bits = MR4_TCRR_EXT;
    else
        tcrr_bits = MR4_TCRR_NORM;
    if (modeconfig.TCR_mode)
        tcrm_bits = MR4_TCRM_ENB;
    else
        tcrm_bits = MR4_TCRM_DIS;
    if (modeconfig.vref_monitor)
        vref_monitor_bits = MR4_VREFMON_ENB;
    else
        vref_monitor_bits = MR4_VREFMON_DIS;
    case (modeconfig.CAL)
        0: cal_bits = MR4_CAL0;
        3: cal_bits = MR4_CAL3;
        4: cal_bits = MR4_CAL4;
        5: cal_bits = MR4_CAL5;
        6: cal_bits = MR4_CAL6;
        8: cal_bits = MR4_CAL8;
        default: cal_bits = MR4_DEF_CAL;
    endcase
    if (modeconfig.fast_self_refresh)
        fast_self_refresh_bits = MR4_SREF_FAST;
    else
        fast_self_refresh_bits  = MR4_SREF_SLOW;
    if (modeconfig.preamble_training)
        preamble_training_bits = MR4_PRETRAIN_ENB;
    else
        preamble_training_bits = MR4_PRETRAIN_DIS;
    if (2 == modeconfig.rd_preamble_clocks)
        rd_preamble_bits = MR4_RDPRE_2CLK;
    else
        rd_preamble_bits = MR4_RDPRE_1CLK;
    if (2 == modeconfig.wr_preamble_clocks)
        wr_preamble_bits = MR4_WRPRE_2CLK;
    else
        wr_preamble_bits = MR4_WRPRE_1CLK;
    if (1 == modeconfig.ppr_enable)
        ppr_enable_bits = MR4_PPR_ENB;
    else
        ppr_enable_bits = MR4_PPR_DIS;
    mode_regs[4] = dcc_bits | mps_bits | tcrr_bits | tcrm_bits | vref_monitor_bits | cal_bits |
                   fast_self_refresh_bits | preamble_training_bits | rd_preamble_bits | wr_preamble_bits | ppr_enable_bits;
    // MR5
    case (modeconfig.CA_parity_latency)
        CAPARITY_L0: ca_parity_latency_bits = MR5_PARITY_LATENCY_0;
        CAPARITY_L4: ca_parity_latency_bits = MR5_PARITY_LATENCY_4;
        CAPARITY_L5: ca_parity_latency_bits = MR5_PARITY_LATENCY_5;
        CAPARITY_L6: ca_parity_latency_bits = MR5_PARITY_LATENCY_6;
        CAPARITY_RES4: ca_parity_latency_bits = MR5_PARITY_LATENCY_RES4;
        CAPARITY_RES5: ca_parity_latency_bits = MR5_PARITY_LATENCY_RES5;
        CAPARITY_RES6: ca_parity_latency_bits = MR5_PARITY_LATENCY_RES6;
        CAPARITY_RES7: ca_parity_latency_bits = MR5_PARITY_LATENCY_RES7;
        default: ca_parity_latency_bits = MR5_PARITY_LATENCY_0;
    endcase
    if (modeconfig.crc_error)
        crc_error_bits = MR5_CRC_ERROR;
    else
        crc_error_bits = MR5_CRC_CLEAR;
    if (1 == modeconfig.CA_parity_error)
        ca_parity_error_bits = MR5_PARITY_ERROR_ERROR;
    else
        ca_parity_error_bits = MR5_PARITY_ERROR_CLEAR;
    if (modeconfig.odt_buffer_disable)
        odt_buffer_disable_bits = MR5_ODT_BUFFER_DIS;
    else
        odt_buffer_disable_bits = MR5_ODT_BUFFER_ENB;
    case (modeconfig.rtt_park)
        RTTP_DIS: rttp_bits = MR5_RTTP_DIS;
        RTTP_60: rttp_bits = MR5_RTTP_60;
        RTTP_120: rttp_bits = MR5_RTTP_120;
        RTTP_40: rttp_bits = MR5_RTTP_40;
        RTTP_240: rttp_bits = MR5_RTTP_240;
        RTTP_48: rttp_bits = MR5_RTTP_48;
        RTTP_80: rttp_bits = MR5_RTTP_80;
        RTTP_34: rttp_bits = MR5_RTTP_34;
        default: rttp_bits = MR5_DEF_RTTP;
    endcase
    if (modeconfig.sticky_parity_error)
        sticky_parity_bits = MR5_STICKY_PARITY_ENB;
    else
        sticky_parity_bits = MR5_STICKY_PARITY_DIS;
    if (modeconfig.dm_enable)
        dm_bits = MR5_DM_ENB;
    else
        dm_bits = MR5_DM_DIS;
    if (modeconfig.read_dbi)
        read_dbi_bits = MR5_READ_DBI_ENB;
    else
        read_dbi_bits = MR5_READ_DBI_DIS;
    if (modeconfig.write_dbi)
        write_dbi_bits  = MR5_WRITE_DBI_ENB;
    else
        write_dbi_bits = MR5_WRITE_DBI_DIS;
    if (modeconfig.dll_frozen)
        dll_frozen_bits = MR5_DLL_FROZEN_ENB;
    else
        dll_frozen_bits = MR5_DLL_FROZEN_DIS;
    mode_regs[5] = ca_parity_latency_bits | crc_error_bits | ca_parity_error_bits | odt_buffer_disable_bits |
                   rttp_bits | sticky_parity_bits | dm_bits | write_dbi_bits | read_dbi_bits | dll_frozen_bits;
    // MR6
    vref_offset_bits = ((modeconfig.vref_training_offset << MR6_VREF_OFFSET_SHIFT) & MR6_VREF_OFFSET_MASK) | MR6;
    if (modeconfig.vref_training_range)
        vref_range_bits = MR6_VREF_RANGE_2;
    else
        vref_range_bits = MR6_VREF_RANGE_1;
    if (modeconfig.vref_training)
        vref_training_bits = MR6_VREF_ENB;
    else
        vref_training_bits = MR6_VREF_DIS;
    case (modeconfig.tCCD_L)
        4: tCCD_L_bits = MR6_tCCDL_4;
        5: tCCD_L_bits = MR6_tCCDL_5;
        6: tCCD_L_bits = MR6_tCCDL_6;
        7: tCCD_L_bits = MR6_tCCDL_7;
        8: tCCD_L_bits = MR6_tCCDL_8;
        10: tCCD_L_bits = MR6_tCCDL_RES6; // Default is a reserved case.
        default: tCCD_L_bits = MR6_tCCDL_8;
    endcase
    mode_regs[6] = vref_offset_bits | vref_range_bits | vref_training_bits | tCCD_L_bits;
endfunction

function bit ReservedBitsSet(int addr);
    if ((addr & MR7) == MR7) begin
        if ((addr & MR7_RESERVED_BITS) != MR7) begin
            return 1;
        end
    end else if ((addr & MR6) == MR6) begin
        if ((addr & MR6_RESERVED_BITS) != MR6) begin
            return 1;
        end
    end else if ((addr & MR5) == MR5) begin
        if ((addr & MR5_RESERVED_BITS) != MR5) begin
            return 1;
        end
    end else if ((addr & MR4) == MR4) begin
        if ((addr & MR4_RESERVED_BITS) != MR4) begin
            return 1;
        end
    end else if ((addr & MR3) == MR3) begin
        if ((addr & MR3_RESERVED_BITS) != MR3) begin
            return 1;
        end
    end else if ((addr & MR2) == MR2) begin
        if ((addr & MR2_RESERVED_BITS) != MR2) begin
            return 1;
        end
    end else if ((addr & MR1) == MR1) begin
        if ((addr & MR1_RESERVED_BITS) != MR1) begin
            return 1;
        end
    end else begin
        if ((addr & MR0_RESERVED_BITS) != MR0) begin
            return 1;
        end
    end
    return 0;
endfunction
    
function bit ReadDBIEnable(logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data);
    if (PopCount(0, data) > 4)
        return 1;
    return 0;
endfunction

function int GetVrefTrainingPercentage();
    int start_val;
    
    if (1 == s_dut_mode_config.vref_training_range)
        start_val = 4500;
    else
        start_val = 6000;
    return (start_val + (65 * s_dut_mode_config.vref_training_offset));
endfunction

function int PopCount(logic count_what, logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data);
    int pop_count;
    
    pop_count = 0;
    for (int i=0;i<MAX_DQ_BITS/MAX_DM_BITS;i++) begin
        if (count_what == data[i])
            pop_count++;
    end
    return pop_count;
endfunction
    
function UTYPE_DutModeConfig DefaultDutModeConfig(
                                    input UTYPE_blreg bl_reg = rBL8,
                                    input UTYPE_bt bt = DEF_BT,
                                    input int cl = DEF_CL,
                                    input UTYPE_alreg al_reg = rAL0,
                                    input int cwl = DEF_CWL,
                                    input int write_recovery = DEF_WR,
                                    input bit dll_enable = 0,
                                    input UTYPE_odi odi = ODI_34,
                                    input UTYPE_rttn rtt_nominal = RTTN_DIS,
                                    input bit write_levelization = 0,
                                    input bit dll_reset = 0,
                                    input bit tdqs = 0,
                                    input bit qoff = 1,
                                    input UTYPE_lpasr lpasr = LPASR_EXTENDED,
                                    input UTYPE_rttw rtt_write = RTTW_DIS,
                                    input bit trr_enable = 0,
                                    input int trr_ba = 0,
                                    input int trr_bg = 0,
                                    input bit write_crc_enable = 0,
                                    input bit mpr_enable = 0,
                                    input UTYPE_mprpage mpr_page = MPR_PATTERN,
                                    input UTYPE_mpr mpr_mode = DEF_MPR_MODE,
                                    input UTYPE_delay_write_crc_dm delay_write_crc_dm = DEF_DELAY_WRITE,
                                    input bit gear_down = 0,
                                    input bit mps = 0,
                                    input bit tcr_range = 0,
                                    input bit tcr_mode = 0,
                                    input int cal = DEF_CAL,
                                    input bit preamble_training = 0,
                                    input int rd_preamble_clocks = 1,
                                    input int wr_preamble_clocks = 1,
                                    input bit ppr_enable = 0,
                                    input bit perdram_addr = 0,
                                    input bit dm_enable = 0,
                                    input bit write_dbi = 0,
                                    input bit read_dbi = 0,
                                    input UTYPE_caparity_latency ca_parity_latency = CAPARITY_L0,
                                    input bit crc_error = 0,
                                    input bit ca_parity_error = 0,
                                    input bit temp_sense_enable = 0,
                                    input UTYPE_rttp rtt_park = RTTP_DIS,
                                    input bit sticky_parity_error = 0,
                                    input bit dll_frozen = 0,
                                    input UTYPE_refmode refresh_mode = REF_1X,
                                    input int tCCD_L = proj_package::DEF_CCD_L,
                                    input bit fast_self_refresh = 0,
                                    input bit vref_training_range = 0,
                                    input bit vref_training = 0,
                                    input int vref_training_offset = 'b1111,
                                    input bit vref_monitor = 0,
                                    input bit odt_buffer_disable = 0
                                    );
    UTYPE_DutModeConfig mode_config;
    
    mode_config.BL_reg = bl_reg;
    mode_config.BT = bt;
    mode_config.CL = cl;
    mode_config.AL_reg = al_reg;
    mode_config.write_recovery = write_recovery;
    mode_config.DLL_enable = dll_enable;
    mode_config.ODI = odi;
    mode_config.rtt_nominal = rtt_nominal;
    mode_config.write_levelization = write_levelization;
    mode_config.DLL_reset = dll_reset;
    mode_config.tDQS = tdqs;
    mode_config.qOff = qoff;
    mode_config.LPASR = lpasr;
    mode_config.CWL = cwl; // cas_write_latency
    mode_config.rtt_write = rtt_write;
    mode_config.trr_enable = trr_enable;
    mode_config.trr_ba = trr_ba;
    mode_config.trr_bg = trr_bg;
    mode_config.write_crc_enable = write_crc_enable;
    mode_config.MPR_enable = mpr_enable;
    mode_config.MPR_page = mpr_page;
    mode_config.MPR_mode = mpr_mode;
    mode_config.delay_write_crc_dm = delay_write_crc_dm;
    mode_config.gear_down = gear_down;
    mode_config.MPS = mps;
    mode_config.TCR_range = tcr_range;
    mode_config.TCR_mode = tcr_mode;
    mode_config.CAL = cal;
    mode_config.preamble_training = preamble_training;
    mode_config.rd_preamble_clocks = rd_preamble_clocks;
    mode_config.wr_preamble_clocks = wr_preamble_clocks;
    mode_config.ppr_enable = ppr_enable;
    mode_config.perdram_addr = perdram_addr;
    mode_config.dm_enable = dm_enable;
    mode_config.write_dbi = write_dbi;
    mode_config.read_dbi = read_dbi;
    mode_config.CA_parity_latency = ca_parity_latency;
    mode_config.crc_error = crc_error;
    mode_config.rtt_park = rtt_park;
    mode_config.sticky_parity_error = sticky_parity_error;
    mode_config.dll_frozen = dll_frozen;
    mode_config.refresh_mode = refresh_mode;
    mode_config.CA_parity_error = ca_parity_error;
    mode_config.temp_sense_enable = temp_sense_enable;
    mode_config.tCCD_L = tCCD_L;
    mode_config.fast_self_refresh = fast_self_refresh;
    mode_config.vref_training_offset = vref_training_offset;
    mode_config.vref_training_range = vref_training_range;
    mode_config.vref_training = vref_training;
    mode_config.odt_buffer_disable = odt_buffer_disable;
    // Calculated values not directly tied to LMR bits.
    mode_config.AL = 0;
    mode_config.BL = DEF_BL;
    mode_config.RL = DEF_CL;
    mode_config.WL_calculated = DEF_CWL;
    
    return mode_config;
endfunction

function void PrintDutModeConfig(UTYPE_DutModeConfig mode_config, string header);
    for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
        for (int ba=0;ba<MAX_BANKS_PER_GROUP;ba++) begin
            $display("\tLMR[%0h][%0h] = %0h", bg, ba, _LMR_cache[bg][ba]);
        end
    end
    $display("=== DutModeConfig(%0s) %0s @%0t ===", _id, header, $time);
    $display("BL:%0d", mode_config.BL);
    $display("RL:%0d", mode_config.RL);
    $display("WL:%0d", mode_config.WL_calculated);
    $display("BT:%0d", mode_config.BT);
    $display("AL:%0d", mode_config.AL);
    $display("BL_reg:%0d", mode_config.BL_reg);
    $display("CL:%0d", mode_config.CL);
    $display("CWL:%0d", mode_config.CWL);
    $display("AL_reg:%0d", mode_config.AL_reg);
    $display("write_recovery:%0d", mode_config.write_recovery);
    $display("DLL_enable:%0d", mode_config.DLL_enable);
    $display("ODI:%0d", mode_config.ODI);
    $display("rtt_nominal: %0d", mode_config.rtt_nominal);
    $display("write_levelization:%0d", mode_config.write_levelization);
    $display("DLL_reset:%0d", mode_config.DLL_reset);
    $display("tDQS:%0d", mode_config.tDQS);
    $display("qOff:%0d", mode_config.qOff);
    $display("LPASR:%0d", mode_config.LPASR);
    $display("rtt_write:%0d", mode_config.rtt_write);
    $display("write_crc_enable:%0d", mode_config.write_crc_enable);
    $display("MPR_enable:%0d", mode_config.MPR_enable);
    $display("MPR_mode:%0d", mode_config.MPR_mode);
    $display("gear_down:%0d", mode_config.gear_down);
    $display("MPS:%0d", mode_config.MPS);
    $display("TCR_range:%0d", mode_config.TCR_range);
    $display("TCR_mode:%0d", mode_config.TCR_mode);
    $display("CAL:%0d", mode_config.CAL);
    $display("preamble_training:%0d", mode_config.preamble_training);
    $display("rd_preamble_clocks:%0d", mode_config.rd_preamble_clocks);
    $display("wr_preamble_clocks:%0d", mode_config.wr_preamble_clocks);
    $display("ppr_enable:%0d", mode_config.ppr_enable);
    $display("perdram_addr:%0d", mode_config.perdram_addr);
    $display("dm_enable:%0d", mode_config.dm_enable);
    $display("write_dbi:%0d", mode_config.write_dbi);
    $display("read_dbi:%0d", mode_config.read_dbi);
    $display("ca_parity_latency:%0d", mode_config.CA_parity_latency);
    $display("crc_error:%0d", mode_config.crc_error);
    $display("rtt_park:%0d", mode_config.rtt_park);
    $display("dll_frozen:%0d", mode_config.dll_frozen);
    $display("refresh_mode:%0d", mode_config.refresh_mode);
    $display("parity_error:%0d", mode_config.CA_parity_error);
endfunction

function void PrintLMR();
    $display("LMRs[bg][ba] @%0t", $time);
    for (int bg=0;bg<MAX_BANK_GROUPS;bg++) begin
        for (int ba=0;ba<MAX_BANKS_PER_GROUP;ba++) begin
            $display("\tLMR[%0h][%0h] = %0h", bg, ba, _LMR_cache[bg][ba]);
        end
    end
endfunction

function int FindMax(int first, int second);
    if (first > second)
        return first;
    return second;
endfunction

