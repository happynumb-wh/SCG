/****************************************************************************************
*
*   File Name:  ddr4_model.sv
*
*   Dependencies:
*                arch_package.sv // Defines parameters, enums and structures for DDR4.
*                proj_package.sv // Defines parameters, enums and structures for this specific DDR4.
*                interface.sv   // Defines 'interface iDDR4'.
*                MemoryArray.sv // Defines 'class MemoryArray'.
*                StateTable.sv  // Defines 'module StateTable'.
*                timing_tasks.sv // Defines enums and timing parameters for multiple timesets.
*
*   Disclaimer   This software code and all associated documentation, comments or other 
*   of Warranty: information (collectively "Software") is provided "AS IS" without 
*                warranty of any kind. MICRON TECHNOLOGY, INC. ("MTI") EXPRESSLY 
*                DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
*                TO, NONINFRINGEMENT OF THIRD PARTY RIGHTS, AND ANY IMPLIED WARRANTIES 
*                OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. MTI DOES NOT 
*                WARRANT THAT THE SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE 
*                OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. 
*                FURTHERMORE, MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR 
*                THE RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS, 
*                ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT OF USE 
*                OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO EVENT SHALL MTI, 
*                ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE LIABLE FOR ANY DIRECT, 
*                INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR SPECIAL DAMAGES (INCLUDING, 
*                WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, 
*                OR LOSS OF INFORMATION) ARISING OUT OF YOUR USE OF OR INABILITY TO USE 
*                THE SOFTWARE, EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
*                DAMAGES. Because some jurisdictions prohibit the exclusion or 
*                limitation of liability for consequential or incidental damages, the 
*                above limitation may not apply to you.
*
*                Copyright 2010 Micron Technology, Inc. All rights reserved.
*/
`include "arch_defines.v"
`include "StateTable.sv"
`include "MemoryArray.sv"

module ddr4_model #(parameter _id = 0) (
    inout wire model_enable,
    interface iDDR4
);
    timeunit 1ps;
    timeprecision 1ps;
    import arch_package::*;
    wire[3:0] cmd = {iDDR4.ACT_n, iDDR4.RAS_n_A16, iDDR4.CAS_n_A15, iDDR4.WE_n_A14}; 
    
    // Initialization
    int init;
    bit[6:0] initialized_mr;
    time tm_cke, tm_pwr;
    time tm_reset_n_neg, tm_reset_n_pos;

`ifdef MODEL_DEBUG_MEMORY
    parameter bit DEBUG_MEMORY = 1;
    parameter bit DEBUG_PIPE = 1;
`else
    parameter bit DEBUG_MEMORY = 0;
    parameter bit DEBUG_PIPE = 0;
`endif

`ifdef MODEL_DEBUG_CMDS
    parameter bit DEBUG_ALL_CMDS = 1;
    parameter bit DEBUG_RDWR_CMDS = 1;
`else
    parameter bit DEBUG_ALL_CMDS = 0;
    parameter bit DEBUG_RDWR_CMDS = 0;
`endif
    parameter int DECAY_TIME_IN_PS = -1;

    `define MAX_PIPE 2*(MAX_RL+MAX_BURST_LEN+MAX_CAL)
    
    // clock
    time tck;
    int previous_tck;
    time tm_ck_pos;
    reg diff_ck;
    bit cmd_violation;
    bit odt_violation;
    bit in_boundary_scan;
    bit in_write_levelization;
    
    StateTable _state();
    DDR4_cmd _last_cmd;
    UTYPE_DutModeConfig _debug_config;
    UTYPE_cmdtype _debug_cmd;
    reg[MAX_ADDR_BITS-1:0] _debug_cmd_addr;
    reg[MAX_BANK_GROUP_BITS-1:0] _debug_cmd_bg;
    reg[MAX_BANK_BITS-1:0] _debug_cmd_ba;
    MemArray::memKey_type rd_mem_key, wr_mem_key;
    time _last_written_ns;
    bit parity_error, parity_ignore_cmd, parity_suspect_cmd, parity_blocked_wr, parity_double_block;
    UTYPE_TimingParameters timing;
    bit lock_timing_parameters, silent_violations;
    int locked_tck;
    DDR4_cmd perdram_cmdpkts[$];
    `include "timing_tasks.sv"
    
    // pipelines
    reg[`MAX_PIPE:0] wr_pipe;
    reg[`MAX_PIPE:0] rd_pipe;
    reg[`MAX_PIPE:0] odt_pin_pipe;
    reg[`MAX_PIPE:0] odt_wr_pipe;
    reg[MAX_BL-1:0] bl_pipe[`MAX_PIPE:0];
    reg[MAX_BL-1:0] bl_data_pipe[`MAX_PIPE:0];
    reg[MAX_BANK_BITS-1:0] ba_pipe[`MAX_PIPE:0];
    reg[MAX_BANK_GROUP_BITS-1:0] bg_pipe[`MAX_PIPE:0];
    reg[MAX_RANK_BITS-1:0] rank_pipe[`MAX_PIPE:0];
    reg[MAX_ROW_ADDR_BITS-1:0] row_pipe[`MAX_PIPE:0];
    reg[MAX_COL_ADDR_BITS-1:0] col_pipe[`MAX_PIPE:0];
    bit[`MAX_PIPE:0] perdram_pipe;
    reg prev_cke;
    
    reg cs_queue[$];
    reg delayed_cs;
    
    reg neg_en;
    // RX.
    wire[CONFIGURED_DQ_BITS-1:0] dq_in;
    assign dq_in = iDDR4.DQ;
    reg[CONFIGURED_DQ_BITS-1:0] dq_in_pos;
    reg[CONFIGURED_DQ_BITS-1:0] dq_in_neg;
    wire[CONFIGURED_DQS_BITS-1:0] dqs_in;
    assign dqs_in = iDDR4.DQS_t;
    wire[CONFIGURED_DQS_BITS-1:0] dqs_n_in;
    assign dqs_n_in = iDDR4.DQS_c;
    wire[CONFIGURED_DM_BITS-1:0] dm_in;
    assign dm_in = iDDR4.DM_n;
    reg[CONFIGURED_DM_BITS-1:0] dm_in_pos;
    reg[CONFIGURED_DM_BITS-1:0] dm_in_neg;
    // TX.
    reg dqs_out_enb;
    reg dqs_out;
    reg dq_out_enb, dq_out_enb_ideal;
    reg dm_out_enb;
    wire bscan_out_enb;
    parameter BSCAN_DELAY = 20_000;
    parameter BSCAN_OE_TF = 2_000;
    parameter BSCAN_OE_TR = 4_000;
    wire [MAX_DQ_BITS-1:0] bscan_dq_out;
    wire [MAX_DQS_BITS-1:0] bscan_dqst_out;
    wire [MAX_DQS_BITS-1:0] bscan_dqsc_out;
    reg[CONFIGURED_DQ_BITS-1:0] dq_out;
    reg[CONFIGURED_DM_BITS-1:0] dm_out;
    logic alert_value;
    time crc_alert_end, crc_alert_begin;
    bit crc_error, crc_skipped_error;
    bufif1 buf_dqs[CONFIGURED_DQS_BITS-1:0] (iDDR4.DQS_t, {CONFIGURED_DQS_BITS{dqs_out}}, dqs_out_enb);
    bufif1 buf_dqs_n[CONFIGURED_DQS_BITS-1:0] (iDDR4.DQS_c, {CONFIGURED_DQS_BITS{~dqs_out}}, dqs_out_enb);
    bufif1 buf_dq[CONFIGURED_DQ_BITS-1:0] (iDDR4.DQ, dq_out, dq_out_enb);
    bufif1 buf_dm[CONFIGURED_DM_BITS-1:0] (iDDR4.DM_n, dm_out, dm_out_enb);
    int dqs_state; // 1:start 2:normal 3:finish 0:hold

    bufif1 bscan_buf_dqs_t[CONFIGURED_DQS_BITS-1:0] (iDDR4.DQS_t, bscan_dqst_out[CONFIGURED_DQS_BITS-1:0], bscan_out_enb);
    bufif1 bscan_buf_dqs_c[CONFIGURED_DQS_BITS-1:0] (iDDR4.DQS_c, bscan_dqsc_out[CONFIGURED_DQS_BITS-1:0], bscan_out_enb);
    bufif1 bscan_buf_dq[CONFIGURED_DQ_BITS-1:0] (iDDR4.DQ, bscan_dq_out[CONFIGURED_DQ_BITS-1:0], bscan_out_enb);

    int wr_burst_pos, rd_burst_pos, dqs_toggle;
    bit dqs_toggle_warning;
    reg [CONFIGURED_DQ_BITS-1:0] dq_temp;
    reg [CONFIGURED_DM_BITS-1:0] dm_temp;
    logic[MAX_DQ_BITS*(MAX_BURST_LEN+MAX_CRC_TRANSFERS)-1:0] wr_dq_burst;
    logic[MAX_DQ_BITS*(MAX_BURST_LEN+MAX_CRC_TRANSFERS)-1:0] raw_wr_dq_burst;
    logic[MAX_DBI_BITS*(MAX_BURST_LEN+MAX_CRC_TRANSFERS)-1:0] wr_dm_burst;
    logic[MAX_DQ_BITS*(MAX_BURST_LEN+MAX_CRC_TRANSFERS)-1:0] rd_dq_burst;
    logic[MAX_DBI_BITS*(MAX_BURST_LEN+MAX_CRC_TRANSFERS)-1:0] rd_dm_burst;

    import MemArray::MemoryArray;
    MemoryArray _storage;
    import MemArray::memKey_type;
    logic[MAX_DQ_BITS/MAX_DM_BITS-1:0] _delayed_write[memKey_type];
    UTYPE_dutconfig _dut_config;
    int vref_target, vref_training_setting, vref_min, vref_max, vref_tolerance;
    Class_CRC _CRC;
    
    reg[RTT_BITS-1:0] term_park, term_dynamic, term_nominal;
    reg[RTT_BITS-1:0] rtt_dq, rtt_dqs, rtt_dm, odi_dq, odi_dqs, odi_dm;
    reg[RTT_BITS-1:0] odi_dq_dll_disable, odi_dqs_dll_disable;
    reg rtt_dq_x, rtt_dqs_x, rtt_dm_x, odi_dq_x, odi_dqs_x, odi_dm_x, term_x;
    longint term_x_stop;
    longint rtt_dq_x_hold, rtt_dqs_x_hold;
    longint odt_async_transition;
    int unknown_odt_pipe, last_odt_delay;
                
    
    bit gear_down_clk, gear_down_clk_synced, gear_down_sync_clk, gear_down_1N2N;
    reg gear_down_odt;
    always @(posedge iDDR4.CK[1]) begin : always_ck_t
        diff_ck <= iDDR4.CK[1];
    end
    always @(posedge iDDR4.CK[0]) begin : always_ck_c
        diff_ck <= ~iDDR4.CK[0];
    end
    always @(negedge iDDR4.CS_n) begin : always_cs
        if ((1 == GetGeardown()) && (0 == gear_down_clk_synced)) begin
            gear_down_clk_synced = 1;
            gear_down_sync_clk <= #(0) 1;
            gear_down_sync_clk <= #(tCK) 0;
            gear_down_1N2N <= #(0) 1;
            gear_down_1N2N <= #(timing.tCMD_GEARc*tCK) 0;
            _state.GeardownSync();
        end 
    end
    always @(posedge iDDR4.CKE) begin : always_cke_mps
        if ((1 == GetMPS()) && (0 == iDDR4.CS_n))
            _state.ExitMaxPowerSaveMR();
    end
    always @(posedge iDDR4.CS_n) begin : always_cs_mps
        if (0 == GetMPS())
            _state.ExitMaxPowerSaveCS();
    end
    always @(posedge gear_down_1N2N) begin : always_gd
        if ((1 == _state.ODTNominalEnabled()) && (1 == iDDR4.PWR)) begin
            term_x <= #(0) 'x;
            term_x <= #((timing.tCMD_GEARc + _state.ODTLoff())*tCK) '1;
            term_x_stop <= $time + ((timing.tCMD_GEARc + _state.ODTLoff())*tCK);
        end
    end
    
    always @(_state._ODT_tMOD_transition) begin : always_odt_trans
        if ((1 === _state._ODT_tMOD_transition) && (1 == iDDR4.PWR)) begin
            term_x = 'x;
            odi_dm = 'z; // LMR can modify read_dbi.
            if (0 == _state.ODTSync()) begin
                rtt_dq_x = '1;
                rtt_dqs_x = '1;
            end
        end else begin
            term_x = '1;
        end
    end
    
    always @(posedge _state._ODT_enter_transition or posedge _state._ODT_exit_transition) begin : always_odt_trans_start
        if ($time < term_x_stop)
            term_x <= #(term_x_stop - $time) 'x;
        term_x = 'x;
    end
    
    always @(negedge _state._ODT_enter_transition or negedge _state._ODT_exit_transition) begin : always_odt_trans_stop
        if ((0 == _state._ODT_enter_transition) && (0 == _state._ODT_exit_transition))
            term_x = '1;
    end
    initial begin
        `ifdef DDR4_X4
            _dut_config.by_mode = 4;
        `elsif DDR4_X8
            _dut_config.by_mode = 8;
        `elsif DDR4_X16
            _dut_config.by_mode = 16;
        `endif
        `ifdef DDR4_2G
            _dut_config.density = _2G;
        `elsif DDR4_4G
            _dut_config.density = _4G;
        `elsif DDR4_8G
            _dut_config.density = _8G;
        `elsif DDR4_16G
            _dut_config.density = _16G;
        `endif
        `ifdef RANK_2H
            _dut_config.rank_mask = 'b1;
            _dut_config.ranks = 2;
        `elsif RANK_4H
            _dut_config.rank_mask = 'b11;
            _dut_config.ranks = 4;
        `elsif RANK_8H
            _dut_config.rank_mask = 'b111;
            _dut_config.ranks = 8;
        `else
            _dut_config.rank_mask = 'b0;
            _dut_config.ranks = 1;
        `endif
        arch_package::dut_config_populate(_dut_config);
        proj_package::project_dut_config(_dut_config);
        _storage = new(.parent("Model"), .print_warnings(1), .print_verification_details(0), 
                       .debug(DEBUG_MEMORY), .decay_time_in_psec(DECAY_TIME_IN_PS), .unwritten_memory_default(1'bx));
        _state.Initialize("Model", _dut_config, DEBUG_ALL_CMDS | DEBUG_RDWR_CMDS);
        SetModelTimingDefault();
        $display("Model based on DDR4 DDS version 0.995 11/06/2013");
        tm_cke = 0;
        vref_min = 4500;
        vref_max = 9250;
        vref_target = (vref_min + vref_max)/2;
        vref_tolerance = 1500;
        lock_timing_parameters = 0;
        locked_tck = timing.tCK;
        silent_violations = 0;
        init = 1;
        initialized_mr = '0;
        neg_en = 0;
        flush_pipes();
        dqs_out_enb = 0;
        dq_out_enb = 0;
        dq_out_enb_ideal = 0;
        dm_out_enb = 0;
        gear_down_clk_synced = 0;
        cmd_violation = 0;
        odt_violation = 0;
        parity_error = 0;
        parity_blocked_wr = 0;
        parity_ignore_cmd = 0;
        in_boundary_scan = 0;
        in_write_levelization = 0;
        alert_value <= #(0) 1;
        ResetCALQueue();
        delayed_cs = 1;
        _debug_cmd = cmdNOP;
        _debug_cmd_bg = '0;
        _debug_cmd_ba = '0;
        _debug_cmd_addr = '0;
        dq_out = 'z;
        dqs_out = 'z;
        dm_out = 'z;
        term_park = 'z;
        term_nominal = 'z;
        term_dynamic = 'z;
        _CRC = new(_dut_config.by_mode, DEBUG_MEMORY | DEBUG_ALL_CMDS);
        _last_cmd = new();
        HardReset();
    end

    `ifdef DDR4_X16

        xor  #(BSCAN_DELAY,BSCAN_DELAY) B0 (bscan_dq_out[0],iDDR4.ADDR[1],iDDR4.ADDR[6],iDDR4.PARITY);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B1 (bscan_dq_out[1],iDDR4.ADDR[8],iDDR4.ALERT_n,iDDR4.ADDR[9]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B2 (bscan_dq_out[2],iDDR4.ADDR[2],iDDR4.ADDR[5],iDDR4.ADDR[13]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B3 (bscan_dq_out[3],iDDR4.ADDR[0],iDDR4.ADDR[7],iDDR4.ADDR[11]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B4 (bscan_dq_out[4],iDDR4.CK[0],iDDR4.ODT,iDDR4.CAS_n_A15);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B5 (bscan_dq_out[5],iDDR4.CKE,iDDR4.RAS_n_A16,iDDR4.ADDR[10]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B6 (bscan_dq_out[6],iDDR4.ACT_n,iDDR4.ADDR[4],iDDR4.BA[1]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B7 (bscan_dq_out[7],iDDR4.DM_n[1],iDDR4.DM_n[0],iDDR4.CK[1]);
        
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B8 (bscan_dq_out[8],iDDR4.ADDR[1],iDDR4.ADDR[6],iDDR4.PARITY);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B9 (bscan_dq_out[9],iDDR4.ADDR[8],iDDR4.ALERT_n,iDDR4.ADDR[9]);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B10 (bscan_dq_out[10],iDDR4.ADDR[2],iDDR4.ADDR[5],iDDR4.ADDR[13]);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B11 (bscan_dq_out[11],iDDR4.ADDR[0],iDDR4.ADDR[7],iDDR4.ADDR[11]);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B12 (bscan_dq_out[12],iDDR4.CK[0],iDDR4.ODT,iDDR4.CAS_n_A15);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B13 (bscan_dq_out[13],iDDR4.CKE,iDDR4.RAS_n_A16,iDDR4.ADDR[10]);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B14 (bscan_dq_out[14],iDDR4.ACT_n,iDDR4.ADDR[4],iDDR4.BA[1]);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B15 (bscan_dq_out[15],iDDR4.DM_n[1],iDDR4.DM_n[0],iDDR4.CK[1]);
        
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B16 (bscan_dqst_out[0],iDDR4.WE_n_A14,iDDR4.ADDR[12],iDDR4.BA[0]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B17 (bscan_dqsc_out[0],iDDR4.BG[0],iDDR4.ADDR[3],iDDR4.RESET_n);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B18 (bscan_dqst_out[1],iDDR4.WE_n_A14,iDDR4.ADDR[12],iDDR4.BA[0]);
        xnor #(BSCAN_DELAY,BSCAN_DELAY) B19 (bscan_dqsc_out[1],iDDR4.BG[0],iDDR4.ADDR[3],iDDR4.RESET_n);
    
    `elsif DDR4_X8
    
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B0 (bscan_dq_out[0],iDDR4.ADDR[1],iDDR4.ADDR[6],iDDR4.PARITY);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B1 (bscan_dq_out[1],iDDR4.ADDR[8],iDDR4.ALERT_n,iDDR4.ADDR[9]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B2 (bscan_dq_out[2],iDDR4.ADDR[2],iDDR4.ADDR[5],iDDR4.ADDR[13]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B3 (bscan_dq_out[3],iDDR4.ADDR[0],iDDR4.ADDR[7],iDDR4.ADDR[11]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B4 (bscan_dq_out[4],iDDR4.CK[0],iDDR4.ODT,iDDR4.CAS_n_A15);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B5 (bscan_dq_out[5],iDDR4.CKE,iDDR4.RAS_n_A16,iDDR4.ADDR[10]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B6 (bscan_dq_out[6],iDDR4.ACT_n,iDDR4.ADDR[4],iDDR4.BA[1]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B7 (bscan_dq_out[7],iDDR4.BG[1],iDDR4.DM_n[0],iDDR4.CK[1]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B8 (bscan_dqst_out[0],iDDR4.WE_n_A14,iDDR4.ADDR[12],iDDR4.BA[0]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B9 (bscan_dqsc_out[0],iDDR4.BG[0],iDDR4.ADDR[3],iDDR4.RESET_n);
    
    `else
        
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B0 (bscan_dq_out[0],iDDR4.ADDR[1],iDDR4.ADDR[6],iDDR4.PARITY,iDDR4.ADDR[8],iDDR4.ALERT_n,iDDR4.ADDR[9]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B1 (bscan_dq_out[1],iDDR4.ADDR[2],iDDR4.ADDR[5],iDDR4.ADDR[13],iDDR4.ADDR[0],iDDR4.ADDR[7],iDDR4.ADDR[11]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B2 (bscan_dq_out[2],iDDR4.CK[0],iDDR4.ODT,iDDR4.CAS_n_A15,iDDR4.CKE,iDDR4.RAS_n_A16,iDDR4.ADDR[10]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B3 (bscan_dq_out[3],iDDR4.ACT_n,iDDR4.ADDR[4],iDDR4.BA[1],iDDR4.BG[1],iDDR4.CK[1]);
        
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B4 (bscan_dqst_out[0],iDDR4.WE_n_A14,iDDR4.ADDR[12],iDDR4.BA[0]);
        xor  #(BSCAN_DELAY,BSCAN_DELAY) B5 (bscan_dqsc_out[0],iDDR4.BG[0],iDDR4.ADDR[3],iDDR4.RESET_n);
        
    `endif

    function void flush_pipes();
        wr_pipe = '0;
        rd_pipe = '0;
        odt_pin_pipe = '0;
        odt_wr_pipe = '0;
        perdram_pipe = '0;
        reset_burst_counters();
    endfunction
    
    function void reset_burst_counters();
        rd_burst_pos = 0;
        wr_burst_pos = 0;
        dqs_toggle = '1;
        dqs_toggle_warning = 0;
        wr_dq_burst = 'z;
        raw_wr_dq_burst = 'z;
        rd_dq_burst = 'z;
    endfunction
    
    task EraseMemory();
        _storage.Verify();
        _storage.Clear();
    endtask

    and #(BSCAN_OE_TR,BSCAN_OE_TF) BSE(bscan_out_enb,in_boundary_scan,~iDDR4.CS_n);
    always @(alert_value) iDDR4.ALERT_n = alert_value;

    always @(negedge iDDR4.PWR) begin : always_pwr_down
        init = 1;
        initialized_mr = '0;
        if (model_enable) begin
            _storage.Verify();
            _storage.Clear();
            HardReset();
            iDDR4.ALERT_n <= #(timing.tPAR_ALERT_OFF) 1;
        end
    end
    
    always @(posedge iDDR4.PWR) begin : always_pwr_up
        tm_pwr = $time;
    end
    
    always @(posedge iDDR4.CKE) begin : always_cke
        tm_cke = $time;
    end
    
    always @(posedge iDDR4.RESET_n) begin : always_reset_pos
        tm_reset_n_pos = $time;
    end
    
    always @(negedge iDDR4.RESET_n) begin : always_reset_neg
        tm_reset_n_neg = $time;
        if (model_enable && (0 === iDDR4.RESET_n)) begin
            iDDR4.ALERT_n <= #(timing.tPAR_ALERT_OFF) 1;
            init = 3;
            initialized_mr = '0;
            dqs_out_enb = 0;
            dq_out_enb = 0;
            dm_out_enb = 0;
            rtt_dq = 'z;
            rtt_dqs = 'z;
            rtt_dm = 'z;
            odi_dq = 'z;
            odi_dqs = 'z;
            odi_dm = 'z;
            HardReset();
        end
    end
    
    always @(posedge iDDR4.TEN) begin : always_ten_pos
        alert_value = '1;
        dqs_out_enb = 0;
        dq_out_enb = 0;
        dq_out_enb_ideal = 0;
        dm_out_enb = 0;
        in_boundary_scan = 1;
    end
    
    always @(negedge iDDR4.TEN) begin : always_ten_neg
        alert_value = '1;
        in_boundary_scan = 0;
        HardReset();
    end
    
    always @(_state.s_dut_mode_config) begin : always_dmc
        _debug_config = _state.s_dut_mode_config;
        if (1 == GetWriteLevelization()) begin
            dq_temp = '1;
            in_write_levelization = 1;
        end else begin
            if ((1 == in_write_levelization) && (1 === GetqOff()))
                dq_out_enb <= #(timing.tWLO_nominal) '0;
            in_write_levelization = 0;
        end
    end
    function void HardReset();
        flush_pipes();
        term_x = '1;
        cs_queue.delete();
        perdram_cmdpkts.delete();
        _state.HardReset();
    endfunction
        
    function bit VerifyParity(logic[3:0] cmd, logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg,
                              logic[MAX_BANK_BITS-1:0] ba, logic[MAX_ADDR_BITS-1:0] addr, logic parity);
        bit expect_parity;
        expect_parity = _state.CalculateParity(cmd, rank, bg, ba, addr);
        if (parity != expect_parity)
            return 0;
        return 1;
    endfunction

    always @(diff_ck && model_enable && (0 == in_boundary_scan)) begin : always_diff_ck
        reg [MAX_COL_ADDR_BITS:0] rd_wr_col;
        logic [MAX_BANK_GROUP_BITS-1:0] configured_bg;
        logic [MAX_BANK_BITS-1:0] configured_ba;
        logic [MAX_RANK_BITS-1:0] configured_rank;
        string msg;
        DDR4_cmd cmdpkt, perdram_cmdpkt;
        string spec_str;
        bit wr, rd, pre_lmr_gear_down;
        
        cmdpkt = new();
        wr = 0; rd = 0;
        if (diff_ck) begin : if_diff_ck
            bit ignore_cmd;
            
            if (cs_queue.size() > 0)
                delayed_cs = cs_queue.pop_back(); // Throw away.
            // Make sure CAL cycles later the gear down sync command is ignored.
            if ((0 != GetCAL()) && (1 == gear_down_sync_clk)) begin
                cs_queue.push_front('1);
            end else begin
                cs_queue.push_front(iDDR4.CS_n);
            end
            if (1 == _state.ReceivingCmds())
                delayed_cs = cs_queue[GetCAL()];
            else
                delayed_cs = '1;
            
            ignore_cmd = 0;
            if ((1 == GetGeardown()) && (1 == gear_down_clk_synced))
                gear_down_clk <= ~gear_down_clk;
            if ((((1 == GetGeardown()) && (1 === gear_down_clk)) || (1 == gear_down_sync_clk)) ||
                (1 == _state.InMaxPowerSave()) || (0 == iDDR4.RESET_n) || (0 == iDDR4.PWR)) begin
                ignore_cmd = 1;
            end
            if ((1 == GetGeardown()) && (0 === gear_down_clk))
                gear_down_odt = iDDR4.ODT;
            
            // Mask the invalid bits for this configuration.
            configured_rank = iDDR4.C & _dut_config.rank_mask;
            configured_bg = iDDR4.BG & _dut_config.bank_group_mask;
            configured_ba = iDDR4.BA & _dut_config.bank_mask;
            
            case (init)
                1: begin // RESET_N pulse width.
                    if (iDDR4.RESET_n) begin
                        if ((tm_reset_n_pos - tm_reset_n_neg) < timing.tRESET) begin 
                            $display("%m:VIOLATION: tRESET must be %0d (measured from negedge RESET_N to posedge RESET_N) @%0t", timing.tRESET, $time);
                        end
                        init = 2;
                    end
                end
                2: begin // RESET_N high to CKE high.
                    if (iDDR4.CKE) begin
                        if ((tm_cke - tm_reset_n_pos) < timing.tRESETCKE) begin
                            $display("%m:VIOLATION: tRESETCKE must be %0d (measured from posedge RESET_N to posedge CKE) @%0t", timing.tRESETCKE, $time);
                        end
                    end
                    init = 3;
                end
                3: begin // CKE high to LMR.
                    casex ({iDDR4.CKE, delayed_cs, cmd})
                        6'b0xxxxx, {1'b1, DESEL_CMD}, {1'b1, NOP_CMD}: begin
                        end
                        {1'b1, LOAD_MODE_CMD}: begin
                            if (($time - tm_cke) < timing.tXPR) begin
                                $display("%m:VIOLATION: tXPR @%0t", $time);
                            end
                            initialized_mr[(configured_bg*4) + configured_ba] = 1;
                            if ((0 != init) && (&initialized_mr)) begin
                                init = 0;
                                $display("%m:Initialization complete @%0t", $time);
                            end
                        end
                        default: begin
                        end
                    endcase
                end
            endcase

            // shift pipelines
            if (|wr_pipe || |rd_pipe || |odt_wr_pipe) begin
                wr_pipe <= (wr_pipe >> 1);
                rd_pipe <= (rd_pipe >> 1);
                odt_wr_pipe <= (odt_wr_pipe >> 1);
                for (int i=0; i<`MAX_PIPE; i++) begin
                    rank_pipe[i]  <= rank_pipe[i+1];
                    bg_pipe[i]  <= bg_pipe[i+1];
                    ba_pipe[i]  <= ba_pipe[i+1];
                    row_pipe[i] <= row_pipe[i+1];
                    col_pipe[i] <= col_pipe[i+1];
                    bl_pipe[i] <= bl_pipe[i+1];
                    bl_data_pipe[i] <= bl_data_pipe[i+1];
                end
            end
            if (1 == GetPerDramAddr()) begin
                perdram_pipe <= (perdram_pipe >> 1);
            end
            odt_pin_pipe <= (odt_pin_pipe >> 1);

            if ((1 == GetPerDramAddr()) && (1'b1 === iDDR4.CKE) && (1'b0 === ignore_cmd)) begin : check_perdram
                casex ({delayed_cs, cmd})
                    LOAD_MODE_CMD, DESEL_CMD : begin
                    end
                    NOP_CMD : begin
                        ignore_cmd = 1; // Do not calculate parity.
                    end
                    default: begin
                        $display("%m:ERROR:Only LMR commands are allowed in per dram @%0t", $time);
                        ignore_cmd = 1;
                    end
                endcase
            end
            parity_error = 0;
            parity_ignore_cmd = 0;
            // Handle parity (will over write ALERT_N setting from CRC).
            if ((1 == _state.CAParityEnabled()) && (1 == _state.ReceivingCmds()) && (0 == ignore_cmd)) begin : check_parity
                int dynamic_tRFC, dynamic_tRFCc, dynamic_tRFC_dlr, dynamic_tRFCc_dlr;
                bit use_a17;
                if (1 == _state.GetParityBlockCommands()) begin
                    if (1 == _state.CheckParityCloseBanks()) begin
                        _state.CloseAllBanks();
                    end
                    if (1 == _state.CheckParityBlockCommands()) begin
                        // Writes go through to match the chip's ODTDynamic toggle.
                        if ({1'b1, 1'b0, WRITE_CMD} == {iDDR4.CKE, ignore_cmd, delayed_cs, cmd}) begin
                            parity_ignore_cmd = 1;
                        end else begin
                            delayed_cs = 1;
                            parity_ignore_cmd = 1;
                        end
                    end else begin
                        _state.SetParityBlockCommands(.enable(0));
                        $display("%m:Parity block commands cleared @%0t", $time);
                    end
                end
                _state.GetDynamictRFC(configured_rank, dynamic_tRFC, dynamic_tRFCc, dynamic_tRFC_dlr, dynamic_tRFCc_dlr);
                use_a17 = (1 == _dut_config.row_mask[17]) ? iDDR4.ADDR_17 : 0;
                if ((1'b0 === delayed_cs) && 
                    ((0 == GetParityError()) || ((1 == GetParityError()) && (1 == GetStickyParityError()))) &&
                    // Parity is turned off PL after REF until tRFC.
                     (((_state._cREF_any_rank + GetCAParityLatency()) > _state._current_cycle) ||
                      (_state._current_cycle >= ((_state._cREF_any_rank + dynamic_tRFCc) - (GetCAParityLatency() + GetCAL())))) &&
                     (0 == VerifyParity({iDDR4.ACT_n, iDDR4.RAS_n_A16, iDDR4.CAS_n_A15, iDDR4.WE_n_A14}, configured_rank,
                                        configured_bg, configured_ba, {use_a17, iDDR4.ADDR}, iDDR4.PARITY))) begin
                    int tPAR_LOW, tPAR_LOW_max;
                    
                    tPAR_LOW = _state.GetParityAlertOnDelay();
                    tPAR_LOW_max = GetCAParityLatency()*timing.tCK + timing.tPAR_ALERT_ON_max;
                    tPAR_LOW = tPAR_LOW_max - 1;
                    _state.WriteParityErrorLog(.mpr3({GetCRCError(), 1'b1, _state._LMR_cache[1][1][2:0], configured_rank}),
                                               .mpr2({iDDR4.PARITY, iDDR4.ACT_n, iDDR4.BG, iDDR4.BA, use_a17, iDDR4.RAS_n_A16}),
                                               .mpr1({iDDR4.CAS_n_A15, iDDR4.WE_n_A14, iDDR4.ADDR[13:8]}), 
                                               .mpr0(iDDR4.ADDR[7:0]));
                    _state.SetParityError(.enable(1));
                    alert_value <= #(tPAR_LOW) '0;
                    if ( _state.GetParityAlertWidth() > timing.tPAR_ALERT_PW_max)
                        alert_value <= #(tPAR_LOW + timing.tPAR_ALERT_PW_max) '1;
                    else
                        alert_value <= #(tPAR_LOW + _state.GetParityAlertWidth()) '1;
                    if (crc_alert_end > $time)
                        alert_value <= #(crc_alert_end - $time) '0;
                    $display("%m:Parity error (cke:%0b cs:%0b cmd:%0b) and alert mode entered @%0t", iDDR4.CKE, delayed_cs, cmd, $time);
                    delayed_cs = 1;
                    parity_error = 1;
                end
            end
            // command decode
            casex ({iDDR4.CKE, ignore_cmd, delayed_cs, cmd})
                {1'b1, 1'b0, LOAD_MODE_CMD} : begin : lmr_decode
                    cmdpkt.raw_cmd = cmdLMR;
                    if (_state.OpenBanks() != 0) begin 
                        $display("%m:ERROR:All banks must be Precharged prior to cmdLMR (%0d are open) @%0t", _state.OpenBanks(), $time);
                    end else begin
                        cmdpkt.cmd = cmdLMR;
                        ResetCALQueue();
                        if (1 == GetParityError()) begin
                            DDR4_cmd lmr_pkt;
                            
                            lmr_pkt = new();
                            lmr_pkt.Populate(cmdLMR, configured_rank, configured_bg, configured_ba, iDDR4.ADDR, tck);
                            if (1 == _state.ClearParityError(lmr_pkt)) begin
                                _state.SetParityError(.enable(0));
                                _state.WriteParityErrorLog(.mpr3('0), .mpr2('1), .mpr1('1), .mpr0('1));
                                $display("%m:Parity error mode cleared @%0t", $time);
                            end
                        end
                        if (DEBUG_ALL_CMDS) $display("%m:cmdLMR C:%0h BG:%0h B:%0h A:%0h @%0t", configured_rank, configured_bg, configured_ba, iDDR4.ADDR, $time);
                    end
                end
                {1'b1, 1'b0, REFRESH_CMD} : begin : ref_decode
                    if (|init) begin
                        $display("%m:ERROR: Initialization sequence must be complete prior to cmdREF @%0t", $time);
                    end else begin
                        if ((_dut_config.ranks < 2) && (_state.OpenBanks() != 0)) begin
                            $display("%m:ERROR:All banks must be precharged prior to cmdREF (%0d are open) @%0t", _state.OpenBanks(), $time);
                        end else if ((_dut_config.ranks > 1) && (_state.OpenRank(configured_rank) != 0)) begin
                            $display("%m:ERROR:All banks must be precharged prior to cmdREF (%0d are open in rank %0h) @%0t", 
                                    _state.OpenRank(configured_rank), configured_rank, $time);
                        end else begin
                            cmdpkt.cmd = cmdREF;
                            if (1 == iDDR4.ADDR[AUTOPRECHARGEADDR]) begin
                                cmdpkt.cmd = cmdREFA;
                            end
                            if (DEBUG_ALL_CMDS) $display("%m:cmdREF C:%0h BG:%0h A10:%0b B:%0h @%0t", 
                                                         configured_rank, configured_bg, iDDR4.ADDR[AUTOPRECHARGEADDR], configured_ba, $time);
                        end
                    end
                end
                {1'b0, 1'b0, SELF_REF_CMD} : begin : sref_decode
                    if (_state.InSelfRefresh() || _state.InPowerDown()) begin
                        cmdpkt.cmd = cmdNOP;
                    end else begin
                        if (|init) begin
                            $display("%m:ERROR: Initialization sequence must be complete prior to cmdSREFE @%0t", $time);
                        end else if (_state.OpenBanks() > 0) begin
                            $display("%m:ERROR: All banks must be Precharged prior to cmdSREFE @%0t", $time);
                        end else begin
                            cmdpkt.cmd = cmdSREFE;
                            if (DEBUG_ALL_CMDS) $display("%m: cmdSREFE @%0t", $time);
                        end
                    end
                end
                {1'b1, 1'b0, ACTIVATE_CMD} : begin : act_decode
                    cmdpkt.raw_cmd = cmdACT;
                    if (|init) begin
                        $display("%m:ERROR: Initialization sequence must be complete prior to cmdACT @%0t", $time);
                    end else if (1 == _state.OpenBank(configured_rank, configured_bg, configured_ba)) begin
                        $display("%m:ERROR: C:%0h BG:%0h B:%0h must be Precharged prior to cmdACT R:%0h @%0t", 
                                configured_rank, configured_bg, configured_ba, {iDDR4.RAS_n_A16, iDDR4.CAS_n_A15, iDDR4.WE_n_A14, iDDR4.ADDR}, $time);
                    end else begin
                        cmdpkt.cmd = cmdACT;
                        if (DEBUG_ALL_CMDS) $display("%m:cmdACT C:%0h BG:%0h B:%0h R:%0h @%0t", 
                                                configured_rank, configured_bg, configured_ba,  {iDDR4.RAS_n_A16, iDDR4.CAS_n_A15, iDDR4.WE_n_A14, iDDR4.ADDR}, $time);
                        if (GetCWL() > _dut_config.max_CWL)
                            $display("%m:ERROR:CWL:%0d > max:%0d @%0t", GetCWL(), _dut_config.max_CWL, $time);
                        if (GetCWL() < _dut_config.min_CWL)
                            $display("%m:ERROR:CWL:%0d < min:%0d @%0t", GetCWL(), _dut_config.min_CWL, $time);
                        if (1 == GetDLLEnable()) begin
                            if (GetCL() > _dut_config.max_CL) begin
                                $display("%m:WARNING:CL:%0d > max:%0d (DLL enabled) @%0t", GetCL(), _dut_config.max_CL, $time);
                            end
                            if (GetCL() < _dut_config.min_CL) begin
                                $display("%m:WARNING:CL:%0d < min:%0d (DLL enabled) @%0t", GetCL(), _dut_config.min_CL, $time);
                            end
                        end else begin
                            if (GetCL() > _dut_config.max_CL_dll_off) begin
                                $display("%m:WARNING:CL:%0d > max:%0d (DLL disabled) @%0t", GetCL(), _dut_config.max_CL_dll_off, $time);
                            end
                            if (GetCL() < _dut_config.min_CL_dll_off) begin
                                $display("%m:WARNING:CL:%0d < min:%0d (DLL disabled) @%0t", GetCL(), _dut_config.min_CL_dll_off, $time);
                            end
                            if (tCK > 8000) begin
                                $display("%m:WARNING:tck:%0d > max:%0dns (DLL disabled) @%0t", tck, 8, $time);
                            end
                        end
                        if (((1 == GetRdDBI()) && (GetCL() < _dut_config.min_CL_dbi_enabled)) ||
                            ((1 == GetRdDBI()) && (GetCL() > _dut_config.max_CL_dbi_enabled)) ||
                            ((0 == GetRdDBI()) && (GetCL() > _dut_config.max_CL_dbi_disabled))) begin
                            $display("%m:ERROR:INVALID SETTING CL:%0d DBI:%0b @%0t", GetCL(), GetRdDBI(), $time);
                        end
                        VerifyMR();
                    end 
                end
                {1'b1, 1'b0, WRITE_CMD} : begin : wr_decode
                    int wl, row, bl;
                    reg [MAX_COL_ADDR_BITS:0] modified_col;
                    bit fill_pipe;

                    cmdpkt.raw_cmd = cmdWR;
                    if (1 == iDDR4.ADDR[AUTOPRECHARGEADDR]) begin
                        cmdpkt.raw_cmd = cmdWRA;
                    end
                    fill_pipe = 0;
                    bl = _state.CheckDynamicBL(iDDR4.ADDR, GetWriteCRCEnable());
                    wl = GetWL();
                    modified_col = iDDR4.ADDR;
                    modified_col = modified_col & ~(1'b1 << BLFLYSELECT);
                    modified_col = modified_col & ~(1'b1 << AUTOPRECHARGEADDR);
                    modified_col = modified_col & _dut_config.col_mask;
                    if (|init) begin
                        $display("%m:ERROR: Initialization sequence must be complete prior to cmdWR @%0t", $time);
                    end else if (1 === _state.InMPRAccess()) begin
                        _state.WriteMPR(configured_bg, configured_ba, modified_col, GetMPRPage(), GetMPRMode());
                        cmdpkt.cmd = cmdWR;
                        $sformat (msg, "cmdWR (MPR) BG:%0h B:%0h WL:%0d BL:%0d @%0t", configured_bg, configured_ba, wl, bl, $time);
                        if (DEBUG_ALL_CMDS || DEBUG_RDWR_CMDS) $display("%m:%0s", msg);
                    end else if (0 == _state.OpenBank(configured_rank, configured_bg, configured_ba)) begin : wr_closed
                        int burst_cycles;
                        
                        burst_cycles = (1 == GetWriteCRCEnable()) ? ((bl/2)+(MAX_CRC_TRANSFERS/2)) : (bl/2);
                        for (int i=0; i<burst_cycles; i++) begin
                            odt_wr_pipe[wl+i] <= 1'b1;
                        end
                        if (0 == _state.OpenBanks())
                            $display("%m:ERROR: BG:%0h B:%0h must be activated prior to cmdWR (all closed) C:%0h @%0t", configured_bg, configured_ba, 
                                    iDDR4.ADDR & ~(1'b1 << AUTOPRECHARGEADDR), $time);
                        else
                            $display("%m:ERROR: BG:%0h B:%0h must be activated prior to cmdWR C:%0h @%0t", configured_bg, configured_ba, 
                                    iDDR4.ADDR & ~(1'b1 << AUTOPRECHARGEADDR), $time);
                    end else if (iDDR4.ADDR >= 1<<MAX_COL_ADDR_BITS) begin
                        $display("%m:ERROR: cmdWR C:%0h does not exist (maximum C:%0h) @%0t", iDDR4.ADDR, (1<<MAX_COL_ADDR_BITS)-1, $time);
                    end else if (0 == _state.GetParityBlockCommands()) begin : wr_open
                        fill_pipe = 1;
                        cmdpkt.cmd = cmdWR;
                        if (1 == iDDR4.ADDR[AUTOPRECHARGEADDR]) begin
                            cmdpkt.cmd = cmdWRA;
                        end
                        if (0 == _state.OpenRow(configured_rank, configured_bg, configured_ba, row)) begin
                            $display("Error:Writing to a closed bank");
                        end
                        $sformat(msg, "cmdWR BG:%0h B:%0h R:%0h C:%h AP:%0d WL:%0d BL:%0d @%0t", 
                                configured_bg, configured_ba, row, modified_col, iDDR4.ADDR[AUTOPRECHARGEADDR], 
                                GetWL(), bl, $time);
                        if (DEBUG_ALL_CMDS || DEBUG_RDWR_CMDS) $display("%m:%0s", msg);
                    end
                    if (fill_pipe) begin : wr_fill_pipe
                        for (int i=0; i<bl/2; i++) begin
                            reg[MAX_COL_ADDR_BITS-1:0] pipe_col;
                            
                            wr_pipe[wl+i] <= 1'b1;
                            odt_wr_pipe[wl+i] <= 1'b1;
                            rank_pipe[wl+i] <= configured_rank;
                            bg_pipe[wl+i] <= configured_bg;
                            ba_pipe[wl+i] <= configured_ba;
                            row_pipe[wl+i] <= row;
                            bl_pipe[wl+i] <= bl;
                            if (1 === _state.InMPRAccess()) begin
                                col_pipe[wl+i] <= modified_col;
                            end else begin
                                if (1 == GetWriteCRCEnable()) begin
                                    bl_data_pipe[wl+i] <= _state.CheckFlyBL(iDDR4.ADDR);
                                    pipe_col = (modified_col & ~(_state.CheckFlyBL(iDDR4.ADDR)-1)) | 
                                               (modified_col%_state.CheckFlyBL(iDDR4.ADDR)^ 2*i); // wrap
                                end else begin
                                    bl_data_pipe[wl+i] <= bl;
                                    pipe_col = (modified_col & ~(bl-1)) | (modified_col%bl^ 2*i); // wrap
                                end
                                col_pipe[wl+i] <= pipe_col;
                            end
                            if (DEBUG_PIPE) $display("WrPipe %0d -> %0h C:%0h (%0d/%0d)@%0t", 
                                                     i, pipe_col | i, modified_col, bl, _state.CheckFlyBL(modified_col), $time);
                        end
                        if (1 == GetWriteCRCEnable()) begin
                            for (int i=0; i<MAX_CRC_TRANSFERS/2; i++) begin
                                wr_pipe[wl+bl/2+i] <= 1'b1;
                                odt_wr_pipe[wl+bl/2+i] <= 1'b1;
                                bl_pipe[wl+bl/2+i] <= bl;
                                bl_data_pipe[wl+bl/2+i] <= _state.CheckFlyBL(iDDR4.ADDR);
                            end
                        end
                    end
                end
                {1'b1, 1'b0, READ_CMD} : begin : rd_decode
                    int rl, bl, row;
                    bit fill_pipe, read_from_closed_bank;
                    reg [MAX_COL_ADDR_BITS:0] modified_col;

                    cmdpkt.raw_cmd = cmdRD;
                    if (1 == iDDR4.ADDR[AUTOPRECHARGEADDR]) begin
                        cmdpkt.raw_cmd = cmdRDA;
                    end
                    fill_pipe = 0;
                    read_from_closed_bank = 0;
                    bl = _state.CheckDynamicBL(iDDR4.ADDR, 0);
                    rl = GetRL() - 1;
                    modified_col = iDDR4.ADDR;
                    modified_col = modified_col & ~(1'b1 << BLFLYSELECT);
                    modified_col = modified_col & ~(1'b1 << AUTOPRECHARGEADDR);
                    modified_col = modified_col & _dut_config.col_mask;
                    if (|init) begin
                        $display("%m:ERROR: Initialization sequence must be complete prior to cmdRD @%0t", $time);
                    end else if ((1 == _state.InMPRAccess()) || (1 == GetPreambleTraining())) begin
                        fill_pipe = 1;
                        bl = _state.CheckDynamicBL(.col(iDDR4.ADDR), .crc_enable(0)); // CRC does not function with MPR.
                        cmdpkt.cmd = cmdRD;
                        if (1 == GetPreambleTraining())
                            $sformat (msg, "cmdRD (Preamble) BG:%0h B:%0h RL:%0d BL:%0d @%0t", configured_bg, configured_ba, rl, bl, $time);
                        else
                            $sformat (msg, "cmdRD (MPR) BG:%0h B:%0h RL:%0d BL:%0d @%0t", configured_bg, configured_ba, rl, bl, $time);
                        if (DEBUG_ALL_CMDS || DEBUG_RDWR_CMDS) $display("%m:%0s", msg);
                    end else if (0 == _state.OpenBank(configured_rank, configured_bg, configured_ba)) begin : rd_closed
                        $display("%m:ERROR: BG:%0h B:%0h must be activated prior to cmdRD (cmd ignored) C:%0h @%0t", 
                                configured_bg, configured_ba, iDDR4.ADDR & ~(1'b1 << AUTOPRECHARGEADDR), $time);
                    end else if (iDDR4.ADDR >= 1<<MAX_COL_ADDR_BITS) begin
                        $display("%m:ERROR: cmdRD C:%0h does not exist (maximum C:%0h) @%0t", iDDR4.ADDR, (1<<MAX_COL_ADDR_BITS)-1, $time);
                    end else if (0 == _state.GetParityBlockCommands()) begin : rd_open
                        fill_pipe = 1;
                        cmdpkt.cmd = cmdRD;
                        if (1 == iDDR4.ADDR[AUTOPRECHARGEADDR]) begin
                            cmdpkt.cmd = cmdRDA;
                        end
                        if (0 == _state.OpenRow(configured_rank, configured_bg, configured_ba, row)) begin
                            read_from_closed_bank = 1;
                            $display("%m:ERROR: BG:%0h B:%0h must be activated prior to cmdRD ('x data) C:%0h @%0t", 
                                    configured_bg, configured_ba, iDDR4.ADDR & ~(1'b1 << AUTOPRECHARGEADDR), $time);
                        end
                        $sformat (msg, "cmdRD BG:%0h B:%0h R:%0h C:%h AP:%0d RL:%0d BL:%0d @%0t", configured_bg, configured_ba,
                                row, modified_col, iDDR4.ADDR[AUTOPRECHARGEADDR], rl, bl, $time);
                        if (DEBUG_ALL_CMDS || DEBUG_RDWR_CMDS) $display("%m:%0s", msg);
                    end
                    if (fill_pipe) begin : rd_fill_pipe
                        for (int i=0; i<bl/2; i++) begin
                            reg[MAX_COL_ADDR_BITS-1:0] pipe_col;
                            
                            rd_pipe[rl+i] <= 1'b1;
                            rank_pipe[rl+i] <= configured_rank;
                            bg_pipe[rl+i] <= configured_bg;
                            ba_pipe[rl+i] <= configured_ba;
                            row_pipe[rl+i] <= row;
                            bl_pipe[rl+i] <= bl;
                            if (1 === _state.InMPRAccess()) begin
                                col_pipe[rl+i] <= modified_col;
                            end else begin
                                bl_data_pipe[rl+i] <= bl;
                                pipe_col = (modified_col & ~(bl-1)) + (modified_col%bl ^ 2*i); // wrap
                                col_pipe[rl+i] <= pipe_col;
                            end
                            if (1 == read_from_closed_bank) begin
                                col_pipe[rl+i] <= 2**MAX_COL_ADDR_BITS - 2; // Read from an address that does not exist.
                            end
                            if (DEBUG_PIPE) $display("RdPipe %0d -> %0h C:%0h (%0d/%0d) @%0t", 
                                                     i, pipe_col, modified_col, bl, _state.CheckFlyBL(modified_col), $time);
                        end
                    end
                end
                {1'b1, 1'b0, PRECHARGE_CMD} : begin : pre_decode
                    cmdpkt.raw_cmd = cmdPRE;
                    if (iDDR4.ADDR[AUTOPRECHARGEADDR] == 1)
                        cmdpkt.raw_cmd = cmdPREA;
                    // A PRECHARGE_CMD command will be treated as a NOP if there is no open row in that bank.
                    if (_state.OpenBanks() > 0) begin
                        if (|init) begin
                            $display("%m:ERROR: Initialization sequence must be complete prior to cmdPRE @%0t", $time);
                        end
                        if (DEBUG_ALL_CMDS) $display("%m:cmdPRE BG:%0h B:%0h AP:%0b @%0t", 
                                                     configured_bg, configured_ba, iDDR4.ADDR[AUTOPRECHARGEADDR], $time);
                    end else begin
                        if (DEBUG_ALL_CMDS) $display("%m:WARNING: Precharge ignored all banks closed @%0t", $time);
                    end
                    if ((1 == iDDR4.ADDR[AUTOPRECHARGEADDR]) && (_state.OpenBanks() > 0))
                        cmdpkt.cmd = cmdPREA;
                    else if ((0 == iDDR4.ADDR[AUTOPRECHARGEADDR]) && (1 == _state.OpenBank(configured_rank, configured_bg, configured_ba)))
                        cmdpkt.cmd = cmdPRE;
                end
                {1'b1, 1'b0, ZQ_CMD} : begin : zq_decode
                    if (_state.OpenBanks() > 0) begin
                        $display("%m:ERROR: cmdZQ Failure. All banks must be Precharged. @%0t", $time);
                    end else begin
                        cmdpkt.cmd = cmdZQ;
                        if (DEBUG_ALL_CMDS) $display ("%m:cmdZQ @%0t", $time);
                    end
                end
                {1'b1, 1'b0, DESEL_CMD} : cmdpkt.cmd = cmdDES;
                {1'b1, 1'b0, NOP_CMD}, // Possible SREFX.
                {7'b11xxxxx} : begin    // Ignored due to gear_down.
                    cmdpkt.cmd = cmdDES;
                end
                default : begin
                     // CKE == 0 commands are handled below and only report an error if the power is enabled.
                    if ((1 == iDDR4.CKE) && (1 == iDDR4.PWR))
                        $display("%m:ERROR: ILLEGAL COMMAND cke:%0h cs:%0h cmd{act,ras,cas,we}:0x%0h @%0t", 
                                 iDDR4.CKE, delayed_cs, cmd, $time);
                end
            endcase
            
            // Commands not delayed by CAL.
            casex ({iDDR4.CKE, iDDR4.CS_n, cmd})
                {1'b1, NOP_CMD},
                {1'b1, DESEL_CMD} : begin // Possible SREFX
                    if (1 == _state.InSelfRefresh()) begin
                        cmdpkt.cmd = cmdSREFX;
                        ResetCALQueue();
                        odt_pin_pipe <= '0; // Flush entire ODT pipe.
                        if (DEBUG_ALL_CMDS) $display("%m: cmdSREFX @%0t", $time);
                    end
                end
                6'b0xxxxx : begin
                    if (cmdSREFE == cmdpkt.cmd) begin // Command was already decoded since SRE is delayed by CAL.
                    end else if (_state.InSelfRefresh() || _state.InPowerDown()) begin
                        cmdpkt.cmd = cmdNOP;
                        if (DEBUG_ALL_CMDS) $display("%m: In SR or PD. Command is ignored @%0t", $time);
                    end else if (_state.OpenBanks() > 0) begin
                        cmdpkt.cmd = cmdAPDE;
                        if (DEBUG_ALL_CMDS) $display("%m: cmdAPDE @%0t", $time);
                    end else begin
                        cmdpkt.cmd = cmdPPDE;
                        if (DEBUG_ALL_CMDS) $display("%m: cmdPPDE @%0t", $time);
                    end
                end
                default : begin
                end
            endcase
            
            if (1 == _state.ODTSync()) begin
                odt_pin_pipe[_state.ODTLoff() - 1] <= (1 == GetGeardown()) ? gear_down_odt : iDDR4.ODT;
                // Pipe is changing so fill w/ unknowns.
                if (_state.ODTLoff() != last_odt_delay) begin
                    unknown_odt_pipe = _state.ODTLoff() + timing.tMODc;
                end
                unknown_odt_pipe = (unknown_odt_pipe > 0) ? unknown_odt_pipe - 1 : 0;
                if ((1 == _state.ODTNominalEnabled()) && (unknown_odt_pipe > 0)) begin
                    ignore_all_rtt(.start_ignore(0), .stop_ignore(tck));
                end
                last_odt_delay = _state.ODTLoff();
            end else begin
                odt_pin_pipe[0] <= (1 == GetGeardown()) ? gear_down_odt : iDDR4.ODT;
            end
            tck <= $time - tm_ck_pos;
            tm_ck_pos <= $time;
            cmdpkt.rank = configured_rank;
            cmdpkt.bank_group = configured_bg;
            cmdpkt.bank = configured_ba;
            if (cmdpkt.cmd == cmdACT) begin : act_a17
                bit use_a17;
                
                use_a17 = (1 == _dut_config.row_mask[17]) ? iDDR4.ADDR_17 : 0;
                cmdpkt.addr = {use_a17, iDDR4.RAS_n_A16, iDDR4.CAS_n_A15, iDDR4.WE_n_A14, iDDR4.ADDR[13:0]};
            end else begin
                cmdpkt.addr = iDDR4.ADDR;
            end
            cmdpkt.odt = iDDR4.ODT;
            cmdpkt.tCK = tck;
            // All commands w/ CKE==1 except SREFX exit power down.
            if (_state.InPowerDown() && (1'b1 == iDDR4.CKE) && (cmdpkt.cmd != cmdSREFX)) begin
                cmdpkt.raw_cmd = cmdpkt.cmd;
                cmdpkt.cmd = cmdPDX;
                ResetCALQueue();
                if (DEBUG_ALL_CMDS) $display("%m: PDX @%0t", $time);
            end
            _debug_cmd = cmdpkt.cmd;
            _debug_cmd_bg = cmdpkt.bank_group;
            _debug_cmd_ba = cmdpkt.bank;
            _debug_cmd_addr = cmdpkt.addr;
            // Violations print an error, but the command is processed normally.
            if (_state.RequiredNops(cmdpkt, spec_str) > 0) begin
                if ((1 != GetPerDramAddr()) || (cmdLMR != cmdpkt.cmd)) begin // Cannot check since the LMR may be to another chip.
                    $display("%m:VIOLATION: %0s", spec_str);
                    cmd_violation = 1;
                end
            end else begin
                cmd_violation = 0;
            end
            if (1 == GetWriteLevelization()) begin
                case (cmdpkt.cmd)
                    cmdLMR, cmdNOP, cmdDES: begin end
                    default: begin
                        $display("%m:ERROR: Only MRS and DESELECT commands all allowed during write levelization @%0t", $time);
                    end
                endcase
            end
            // Limit ODT warnings to certain sequences.
            if ((_state.RequiredODTCycles(cmdpkt.odt, spec_str) > 0) && (1 == _state.ODTNominalEnabled()) &&
                 (1 == iDDR4.RESET_n) && (1 == iDDR4.PWR) && (0 == _state.ODTAnyTransition())) begin
                if (0 == odt_violation) // Only report a violation for the first edge.
                    $display("%m:ODT VIOLATION: %0s @%0t", spec_str, $time);
                odt_violation = 1;
            end else begin
                odt_violation = 0;
            end
            // Clone the command before handling PerDramAddr.
            _last_cmd.Clone(cmdpkt);
            // Per DRAM delays loading LMR until DQ is verified.
            if ((1 == GetPerDramAddr()) && (cmdLMR == cmdpkt.cmd)) begin
                if (DEBUG_ALL_CMDS)
                    $display("Holding off LMR (%0h:%0h:%0h) for %0d clks @%0t", 
                             cmdpkt.bank_group, cmdpkt.bank, cmdpkt.addr, GetWL()-1, $time);
                perdram_pipe[_state.PerDramLatency()] <= 1'b1;
                perdram_cmdpkt = new();
                perdram_cmdpkt.Clone(cmdpkt);
                perdram_cmdpkts.push_back(perdram_cmdpkt);
                // A delayed LMR is a NOP now.
                cmdpkt.cmd = cmdNOP;
            end
            pre_lmr_gear_down = GetGeardown();
            _state.UpdateTable(.cmdpkt(cmdpkt), .cmd_cycle_delay(0), .print(DEBUG_ALL_CMDS));
        end
        
        // Specs need to be updated when timing changes.
        if (previous_tck != tck) begin : handle_ts
            UTYPE_TS ts;
            
            if ((0 == lock_timing_parameters) && FindTimesetCeiling(tck, ts)) begin
                if (ts != timing.ts_loaded) begin
                    $display("%m:Updating timeset:%0s for tck:%0d @%0t.", ts.name(), tck, $time);
                    SetModelTiming(ts);
                end
            end else begin
//                     $display("%m:WARNING:Unable to find timeset for tck:%0d @%0t. Timeset is not updated.", tck, $time);
            end
            previous_tck = tck;
        end

        // Even bursts are the same w/ SEQ or INT
        if (col_pipe[0]%2 == 0) begin
            rd_wr_col = col_pipe[0] + diff_ck;
        // Odd bursts vary between SEQ and INT
        end else begin
            rd_wr_col = col_pipe[0];
            if (GetBT() == SEQ) begin
                rd_wr_col[1:0] = col_pipe[0] + diff_ck;
            end else begin
                rd_wr_col = col_pipe[0] - diff_ck;
            end
        end
        
        // If not ReceivingCmds(), the input buffers are off.
        if (wr_pipe[0]) begin : handle_wr_pipe
            reg [CONFIGURED_DQ_BITS-1:0] dqIn;
            reg [CONFIGURED_DM_BITS-1:0] dmIn;
            logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data;
            int last_dqs_toggle;
            
            wr = 1;
            wr_mem_key.rank = rank_pipe[0];
            wr_mem_key.bank_group = bg_pipe[0];
            wr_mem_key.bank = ba_pipe[0];
            wr_mem_key.row = row_pipe[0];
            // Wr is always 0-BL
            wr_mem_key.col = (rd_wr_col & (-1*bl_data_pipe[0])) | wr_burst_pos;
            if (diff_ck) begin
                dqIn = dq_in_neg;
                dmIn = dm_in_neg;
            end else begin
                dqIn = dq_in_pos;
                dmIn = dm_in_pos;
            end
            if (1 === GetVrefTraining()) begin : vref_train
                int tolerance;
                tolerance = ((vref_min+vref_max)/2*(vref_tolerance/100))/100;
                vref_training_setting = _state.GetVrefTrainingPercentage();
                if ((_state.GetVrefTrainingPercentage() < (vref_target - tolerance)) ||
                    (_state.GetVrefTrainingPercentage() > (vref_target + tolerance))) begin
                    dqIn ^= $urandom_range(1, (2**CONFIGURED_DQ_BITS)-1);
                    dmIn ^= $urandom_range(1, (2**CONFIGURED_DM_BITS)-1);
                end
            end
            begin : wr_burst
                reg[CONFIGURED_DQ_BITS-1:0] raw_dq;
                
                dq_temp = '0;
                dm_temp = '0;
                raw_dq = '0;
                for (int i=0; i<_dut_config.num_dms; i++) begin
                    data = (dqIn & _dut_config.dq_mask) >> (i*MAX_DQ_BITS/MAX_DM_BITS);
                    raw_dq |= data << (i*MAX_DQ_BITS/MAX_DM_BITS);
                    if ((1 == GetWrDBI()) && !dmIn[i]) begin
                        data = ~data;
                    end
                    dq_temp |= data << (i*MAX_DQ_BITS/MAX_DM_BITS);
                    if (dmIn[i] || (0 == GetDMEnable())) begin
                        wr_mem_key.dm = i;
                        if (wr_burst_pos < bl_data_pipe[0]) begin
                            if ((1'bx === term_x) && (1 == parity_suspect_cmd)) begin
                                $display("%m:WRITE blocked BG:%0h B:%0h R:%0h C:%0h Burst:%0d Pipe:%0d @%0t",
                                        wr_mem_key.bank_group, wr_mem_key.bank, wr_mem_key.row, wr_mem_key.col, wr_burst_pos, bl_data_pipe[0], $time);
                                parity_blocked_wr <= #(0) 1;
                                parity_blocked_wr <= #(2*tCK) 0;
                                data = 'x;
                            end
                            // A write may be prevented with a CRC error.
                            if ((1 == GetWriteCRCEnable()) && (1 == GetDMEnable())) begin
                                _delayed_write[wr_mem_key] = data;
                            end else begin
                                _storage.Write(wr_mem_key, data);
                            end
                        end else begin
                            if (DEBUG_PIPE)
                                $display("%m:WRITE prevented BG:%0h B:%0h R:%0h C:%0h Burst:%0d Pipe:%0d @%0t",
                                         wr_mem_key.bank_group, wr_mem_key.bank, wr_mem_key.row, wr_mem_key.col, wr_burst_pos, bl_data_pipe[0], $time);
                        end
                    end
                end
                dm_temp = dmIn & _dut_config.dm_mask;
                wr_dq_burst = (wr_dq_burst & ~(_dut_config.dq_mask << (wr_burst_pos*MAX_DQ_BITS))) | 
                              ((dq_temp & _dut_config.dq_mask) << (wr_burst_pos*MAX_DQ_BITS));
                raw_wr_dq_burst = (raw_wr_dq_burst & ~(_dut_config.dq_mask << (wr_burst_pos*MAX_DQ_BITS))) | 
                              ((raw_dq & _dut_config.dq_mask) << (wr_burst_pos*MAX_DQ_BITS));
                wr_dm_burst = (wr_dm_burst & ~(_dut_config.dm_mask << (wr_burst_pos*MAX_DM_BITS))) | 
                              ((dm_temp & _dut_config.dm_mask) << (wr_burst_pos*MAX_DM_BITS));
            end
            wr_burst_pos = wr_burst_pos + 1;
            if (last_dqs_toggle == dqs_toggle) begin
                dqs_toggle_warning = 1;
                $display("%m:WARNING:Expecting DQS to toggle around write burst @%0t", $time);
            end
            last_dqs_toggle = dqs_toggle;
            if (1 == GetWriteCRCEnable()) begin : wr_crc
                if (wr_burst_pos > (bl_pipe[0] + MAX_CRC_TRANSFERS - 1)) begin
                    bit[MAX_DQ_BITS-1:0] exp_crc;
                    bit[MAX_DQ_BITS-1:0] actual_crc;
                    bit[MAX_DQ_BITS-1:0] crc_mask;
                    
                    crc_mask = 'hff; // 8 equations CRC0-CRC7.
                    if (16 == _dut_config.by_mode)
                        crc_mask = 'hffff; // 16 equations CRC0-CRC15.
                    // DM is ignored in the calculation.
                    if ((0 == GetDMEnable()) && (0 == GetWrDBI()))
                        exp_crc = _CRC.Calculate(wr_dq_burst, '1) & crc_mask;
                    else // CRC is calculated w/ received data (not inverted w/ DBI).
                        exp_crc = _CRC.Calculate(raw_wr_dq_burst, wr_dm_burst) & crc_mask;
                    actual_crc = _CRC.GetCRC(wr_dq_burst);
                    crc_error <= #(0) 0;
                    crc_skipped_error <= #(0) 0;
                    if (exp_crc != actual_crc) begin
                        crc_error <= #(0) 1;
                        crc_error <= #(timing.tCK) 0;
                        _state.SetCRCError();
                        $display("%m:ERROR:CRC failure. Expected:%0h Actual:%0h @%0t", exp_crc, actual_crc, $time);
                        if (0 == _state._parity_block_commands) begin
                            if (($time - crc_alert_begin) <= (timing.tCRC_ALERT_PWc*timing.tCK)) begin
                                crc_skipped_error <= #(0) 1;
                                crc_skipped_error <= #(timing.tCK) 0;
                            end else begin
                                alert_value <= #(timing.tCRC_ALERT) '0;
                                alert_value <= #(timing.tCRC_ALERT + (timing.tCK*timing.tCRC_ALERT_PWc)) '1;
                                crc_alert_begin = $time;
                                crc_alert_end = $time + timing.tCRC_ALERT + (timing.tCK*timing.tCRC_ALERT_PWc);
                            end
                        end
                    end
                    if ((1'bx === term_x) && (1 == parity_suspect_cmd)) begin
                        $display("%m:WRITE blocked BG:%0h B:%0h R:%0h C:%0h Burst:%0d Pipe:%0d @%0t",
                                wr_mem_key.bank_group, wr_mem_key.bank, wr_mem_key.row, wr_mem_key.col, wr_burst_pos, bl_data_pipe[0], $time);
                        parity_blocked_wr <= #(0) 1;
                        parity_blocked_wr <= #(2*tCK) 0;
                    end
                    // Write unless there was a CRC error w/ DM enabled.
                    if ((exp_crc == actual_crc) || (0 == GetDMEnable())) begin
                        memKey_type write_key;
                        if(_delayed_write.first(write_key)) begin
                            for (int i=0;i<_delayed_write.num();i++) begin
                                _storage.Write(write_key, _delayed_write[write_key]);
                                if(!_delayed_write.next(write_key))
                                    break;
                            end
                        end
                    end else if ((16 == _dut_config.by_mode) && (exp_crc != actual_crc) && (1 == GetDMEnable())) begin
                        memKey_type write_key;
                        if(_delayed_write.first(write_key)) begin
                            for (int i=0;i<_delayed_write.num();i++) begin
                                if (((0 == write_key.dm) && ('0 == ((exp_crc ^ actual_crc) & 'h00ff))) ||
                                    ((1 == write_key.dm) && ('0 == ((exp_crc ^ actual_crc) & 'hff00))))
                                    _storage.Write(write_key, _delayed_write[write_key]);
                                if(!_delayed_write.next(write_key))
                                    break;
                            end
                        end
                    end
                    wr_burst_pos = 0;
                    wr_dq_burst = '1;
                    raw_wr_dq_burst = '1;
                    wr_dm_burst = '1;
                    _delayed_write.delete();
                end
            end else if (wr_burst_pos > bl_pipe[0]-1) begin
                wr_burst_pos = 0;
            end
            if (DEBUG_PIPE) $display ("%m:WR BG:%0h B:%0h R:%0h C:%0h dm:%0h data:%0h @%0t",
                wr_mem_key.bank_group, wr_mem_key.bank, wr_mem_key.row, wr_mem_key.col, wr_mem_key.dm, dq_temp, $time);
        end

        // Read.
        // Set dq/dqs output enable.
        if (diff_ck && (1 !== GetqOff())) begin : handle_dqs
            if (1 === GetPreambleTraining()) begin
                if (_state.PreambleTrainingtSDOExpired()) begin
                    dqs_out_enb = '1;
                end else begin
                    dqs_out_enb = '0;
                end
            end else if (1 === _state.PreambleTrainingExiting()) begin
                dqs_out_enb = '1;
            // Keep dqs on if it is a minimum spaced burst (1 nCK w/ 1 clk pre or 2 nCK w/ 2 clk pre).
            end else if (((1 == GetRdPreambleClocks()) && (rd_pipe[0] == 1'b1) && (rd_pipe[1] != 1'b1) && (rd_pipe[2] == 1'b1)) ||
                         ((2 == GetRdPreambleClocks()) && (rd_pipe[0] == 1'b1) && (rd_pipe[1] != 1'b1) && (rd_pipe[3] == 1'b1))) begin
                dqs_out_enb <= #(timing.tDQSCK) '1;
                dq_out_enb <= #(tck/2 + timing.tDQSCK + ((timing.tRPSTp*tck)/100)) (rd_pipe[1]);
                dq_out_enb_ideal <= #(tck/2 + ((timing.tRPSTp*tck)/100)) (rd_pipe[1]);
                dqs_state = 0;
            // Shorten the postamble if the next cycle is not a read.
            end else if ((rd_pipe[0] == 1'b1) && (rd_pipe[1] != 1'b1)) begin
                dqs_out_enb <= #(tck/2 + timing.tDQSCK + ((timing.tRPSTp*tck)/100)) (rd_pipe[1]);
                dq_out_enb <= #(tck/2 + timing.tDQSCK + ((timing.tRPSTp*tck)/100)) (rd_pipe[1]);
                dq_out_enb_ideal <= #(tck/2 + ((timing.tRPSTp*tck)/100)) (rd_pipe[1]);
                dqs_state = 3;
            // Create preamble if a burst is starting.
            end else if (rd_pipe[0] != 1'b1 && 
                        ((rd_pipe[1] == 1'b1) || ((2 == GetRdPreambleClocks()) && (rd_pipe[2] == 1'b1)))) begin
                dqs_out_enb <= #(timing.tDQSCK + (((100-timing.tRPREp)*tck)/100)) '1;
                dqs_state = 1;
            end else begin
                dqs_out_enb <= #(timing.tDQSCK) (rd_pipe[0]);
                dqs_state = 2;
            end
            if (0 == GetWriteLevelization())
                dq_out_enb <= #(timing.tDQSCK) (rd_pipe[0]);
            else begin
                dq_out_enb <= #(timing.tDQSCK) '1;
            end
            dq_out_enb_ideal <= (rd_pipe[0]);
            if (1 == GetRdDBI()) begin
                if ((1 == _dut_config.ignore_dbi_with_mpr) && ((1 === _state.InMPRAccess()))) begin
                    dm_out_enb <= #(timing.tDQSCK) '0;
                end else begin
                    dm_out_enb <= #(timing.tDQSCK) (rd_pipe[0]);
                end
            end else begin
                dm_out_enb <= #(timing.tDQSCK) '0;
            end
        end
        // Preamble training does not have a preamble.
        if (1 === GetPreambleTraining()) begin
            if (0 == rd_pipe[0]) begin
                dqs_out <= #(timing.tDQSCK) '0;
            end else begin
                dqs_out <= #(timing.tDQSCK) rd_pipe[0] && diff_ck;
            end
        // Insert preamble if a rd is starting and a burst is not finishing.
        end else if (~rd_pipe[0] && (rd_pipe[1] || rd_pipe[2]))
            if (~dq_out_enb_ideal) begin // Starting a burst. Use 'ideal' incase tDQSCK > 0.5*tCK.
                dqs_out <= #(timing.tDQSCK) 1;
            end else begin // In a burst.
                dqs_out <= #(timing.tDQSCK) 1 && diff_ck;
            end
        else begin
            dqs_out <= #(timing.tDQSCK) rd_pipe[0] && diff_ck;
        end
        dq_out <= #(timing.tDQSCK + timing.tDQSQ) dq_temp;
        dm_out <= #(timing.tDQSCK + timing.tDQSQ) dm_temp;

        // Read data copied to dq_temp.
        if (rd_pipe[0]) begin : handle_rd_pipe
            logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data0, data1;
            logic dm0, dm1;

            rd = 1;
            data0 = 'z; data1 = 'z;
            dm0 = 'z; dm1 = 'z;
            rd_mem_key.rank = rank_pipe[0];
            rd_mem_key.bank_group = bg_pipe[0];
            rd_mem_key.bank = ba_pipe[0];
            rd_mem_key.row = row_pipe[0];
            rd_mem_key.col = rd_wr_col;
            if ((1 === _state.InMPRAccess()) || (1 === GetPreambleTraining())) begin : rd_mpr
                dq_temp = _state.ReadMPR(.bg(bg_pipe[0]), .ba(ba_pipe[0]), .addr(col_pipe[0]), 
                                         .mpr_page(GetMPRPage()), .mpr_mode(GetMPRMode()), .burst_position(rd_burst_pos));
                if (1 == GetRdDBI()) begin
                    if ((0 == _dut_config.ignore_dbi_with_mpr) || (1 === GetPreambleTraining())) begin
                        dm_temp = '1;
                    end
                end
            end else begin : rd_norm
                for (int i=0;i<_dut_config.num_dms;i++) begin
                    rd_mem_key.dm = i;
                    if (0 == i) begin
                        if (rd_burst_pos < bl_data_pipe[0])
                            data0 = _storage.Read(rd_mem_key) & _dut_config.dq_mask;
                        else begin
                            data0 = '1;
                            if (DEBUG_PIPE) begin
                                $display("%m:READ prevented BG:%0h B:%0h R:%0h C:%0h Burst:%0d Pipe:%0d @%0t",
                                         rd_mem_key.bank_group, rd_mem_key.bank, rd_mem_key.row, rd_mem_key.col, rd_burst_pos, bl_data_pipe[0], $time);
                            end
                        end
                        if (1 == GetRdDBI()) begin
                            if (1 == _state.ReadDBIEnable(data0))  begin
                                data0 = ~data0;
                                dm0 = '0;
                            end else
                                dm0 = '1;
                            if (1'bx === &data0)
                                dm0 = &data0;
                        end else begin
                            dm0 = '1;
                        end
                    end else if (1 == i) begin
                        if (rd_burst_pos < bl_data_pipe[0])
                            data1 = _storage.Read(rd_mem_key) & _dut_config.dq_mask;
                        else begin
                            data1 = '1;
                            if (DEBUG_PIPE) begin
                                $display("%m:READ prevented BG:%0h B:%0h R:%0h C:%0h Burst:%0d Pipe:%0d @%0t",
                                         rd_mem_key.bank_group, rd_mem_key.bank, rd_mem_key.row, rd_mem_key.col, rd_burst_pos, bl_data_pipe[0], $time);
                            end
                        end
                        if (1 == GetRdDBI()) begin
                            if (1 == _state.ReadDBIEnable(data1)) begin
                                data1 = ~data1;
                                dm1 = '0;
                            end else
                                dm1 = '1;
                            if (1'bx === &data1)
                                dm1 = &data1;
                        end else begin
                            dm1 = '1;
                        end
                    end
                end
                _last_written_ns = _storage.TimeWritten(rd_mem_key) / 1000;
                dq_temp = {data1, data0};
                dm_temp = {dm1, dm0};
                rd_dq_burst = (rd_dq_burst & ~(_dut_config.dq_mask << (rd_burst_pos*MAX_DQ_BITS))) | 
                              ((dq_temp & _dut_config.dq_mask) << (rd_burst_pos*MAX_DQ_BITS));
                rd_dm_burst = (rd_dm_burst & ~(_dut_config.dm_mask << (rd_burst_pos*MAX_DM_BITS))) | 
                              ((dm_temp & _dut_config.dm_mask) << (rd_burst_pos*MAX_DM_BITS));
            end
            rd_burst_pos = rd_burst_pos + 1;
            if (rd_burst_pos > bl_pipe[0]-1) begin
                rd_burst_pos = 0;
            end
            if (DEBUG_PIPE) $display ("%m:RD BG:%0h B:%0h R:%0h C:%0h dm:%0h data:%0h @%0t",
                rd_mem_key.bank_group, rd_mem_key.bank, rd_mem_key.row, rd_mem_key.col, rd_mem_key.dm, dq_temp, $time);
        end
        if (1 == perdram_pipe[0] && diff_ck) begin : perdram
            if (perdram_cmdpkts.size() > 0) begin
                perdram_cmdpkt = perdram_cmdpkts.pop_front();
                if (0 == dq_in[0]) begin
                    if (DEBUG_ALL_CMDS)
                        $display("LMR valid (%0h:%0h:%0h) @%0t", perdram_cmdpkt.bank_group, perdram_cmdpkt.bank, perdram_cmdpkt.addr, $time);
                    _state.UpdateLMR(perdram_cmdpkt, 0, DEBUG_ALL_CMDS);
                end else begin
                    if (DEBUG_ALL_CMDS)
                        $display("LMR ignored (%0h:%0h:%0h) Data:%0h @%0t", 
                                perdram_cmdpkt.bank_group, perdram_cmdpkt.bank, perdram_cmdpkt.addr, dq_in, $time);
                end
            end else begin
                $display("%m:ERROR:Missing per dram LMR command @%0t", $time);
            end
        end
        if (diff_ck) begin
            if (1 == _state.ODTSync() || (0 != init)) begin
                handle_sync_odt();
            end else
                handle_async_odt();
        end
    end

    function void ResetCALQueue();
        cs_queue.delete();
        for (int i=0;i<=MAX_CAL;i++) begin
            cs_queue.push_front(1);
        end
    endfunction
    
    always @(posedge dqs_n_in[0]) DQSNegReceiver(0, {MAX_DQ_BITS/MAX_DM_BITS{1'b1}});
    always @(posedge dqs_in[0]) DQSPosReceiver(0, {MAX_DQ_BITS/MAX_DM_BITS{1'b1}});
    `ifdef DDR4_X16
        always @(posedge dqs_n_in[1]) DQSNegReceiver(1, {MAX_DQ_BITS/MAX_DM_BITS{1'b1}}<<(1*MAX_DQ_BITS/MAX_DM_BITS));
        always @(posedge dqs_in[1]) DQSPosReceiver(1, {MAX_DQ_BITS/MAX_DM_BITS{1'b1}}<<(1*MAX_DQ_BITS/MAX_DM_BITS));
    `endif
    always @(dqs_in[0]) begin
        dqs_toggle += 1;
        dqs_toggle_warning = 0;
    end

    task automatic DQSPosReceiver(int i, logic[CONFIGURED_DQ_BITS-1:0] bit_mask);
        dm_in_pos[i] = dm_in[i];
        dq_in_pos = (dq_in & bit_mask) | (dq_in_pos & ~bit_mask);
        if (DEBUG_PIPE) $display("%m:Receive pos DQ:%0h (raw:%0h) @%0t", dq_in_pos, dq_in, $time);
    endtask

    task automatic DQSNegReceiver(int i, logic[CONFIGURED_DQ_BITS-1:0] bit_mask);
        dm_in_neg[i] = dm_in[i];
        dq_in_neg = (dq_in & bit_mask) | (dq_in_neg & ~bit_mask);
        if (DEBUG_PIPE) $display("%m:Receive neg DQ:%0h (raw:%0h) @%0t", dq_in_neg, dq_in, $time);
    endtask

    always @(posedge dqs_in[0]) begin
        if (1 == GetWriteLevelization()) begin
            if (16 == _dut_config.by_mode) begin
            `ifdef DDR4_X16
                if (1 == iDDR4.CK[1])
                    dq_temp[7:0] <= #(timing.tWLO_nominal + timing.tWLOE_nominal) '1;
                else
                    dq_temp[7:0] <= #(timing.tWLO_nominal + timing.tWLOE_nominal) '0;
            `endif
            end else begin
                if (1 == iDDR4.CK[1])
                    dq_temp <= #(timing.tWLO_nominal + timing.tWLOE_nominal) '1;
                else
                    dq_temp <= #(timing.tWLO_nominal + timing.tWLOE_nominal) '0;
            end
        end
    end

    `ifdef DDR4_X16
    always @(posedge dqs_in[1]) begin
        if ((1 == GetWriteLevelization()) && (16 == _dut_config.by_mode)) begin
            if (1 == iDDR4.CK[1])
                dq_temp[15:8] <= #(timing.tWLO_nominal + timing.tWLOE_nominal) '1;
            else
                dq_temp[15:8] <= #(timing.tWLO_nominal + timing.tWLOE_nominal) '0;
        end
    end
    `endif
    
    task SetModelTimingDefault();
        `ifdef DDR4_1875_Timing
            SetModelTiming(TS_1875);
        `elsif DDR4_1500_Timing
            SetModelTiming(TS_1500);
        `elsif DDR4_1250_Timing
            SetModelTiming(TS_1250);
        `elsif DDR4_1072_Timing
            SetModelTiming(TS_1072);
        `elsif DDR4_938_Timing
            SetModelTiming(TS_938);
        `elsif DDR4_833_Timing
            SetModelTiming(TS_833);
        `elsif DDR4_750_Timing
            SetModelTiming(TS_750);
        `elsif DDR4_682_Timing
            SetModelTiming(TS_682);
        `elsif DDR4_625_Timing
            SetModelTiming(TS_625);
        `else
            SetModelTiming(TS_1500);
        `endif
    endtask
    
    task SetModelTiming(input UTYPE_TS ts);
        SetTimingStruct(ts);
    endtask

    always @(timing) begin
        _state.UpdateTiming(timing);
    end
    
    always @(_state.s_dut_mode_config or timing.tCK or timing.tDQSCK_dll_off or timing.tDQSCK_dll_on) begin
        timing.tRDPDENc = GetRL() + 4 + 1;
        if (rBL4 == GetBLReg()) begin
            timing.tWRPDENc = GetWL() + 2 + timing.tWRc + GetCAL();
            timing.tWRAPDENc = GetWL() + 2 + GetWriteRecovery() + 1 + GetCAL();
        end else begin
            timing.tWRPDENc = GetWL() + 4 + timing.tWRc + GetCAL();
            timing.tWRAPDENc = GetWL() + 4 + GetWriteRecovery() + 1 + GetCAL();
        end
        timing.tCCDc_L = GettCCD_L();
        timing.tCCD_L = (0 == lock_timing_parameters) ? GettCCD_L()*timing.tCK : GettCCD_L()*locked_tck;
        timing.tRTPc = GetWriteRecovery() / 2;
        timing.tRTP = (0 == lock_timing_parameters) ? (GetWriteRecovery()/2)*timing.tCK : (GetWriteRecovery()/2)*locked_tck;
        if (0 == GetDLLEnable()) begin
            if (timing.tDQSCK_dll_off > timing.tCK)
                timing.tDQSCK = (0 == lock_timing_parameters) ? timing.tDQSCK_dll_off % timing.tCK : timing.tDQSCK_dll_off % locked_tck;
            else
                timing.tDQSCK = timing.tDQSCK_dll_off;
            // Force RL to update if necessary (prevent during write levelization since the model restarts WL).
            if (0 == GetWriteLevelization())
                _state.s_dut_mode_config = _state.AddrToModeDecode(_state._LMR_cache[1][2] | MR6, _state.s_dut_mode_config);
        end else begin
            timing.tDQSCK = timing.tDQSCK_dll_on;
        end
        if (2 == GetWrPreambleClocks()) begin
            timing.tDQSSp_min = timing.tDQSSp_2tCK_min;
            timing.tDQSSp_min = timing.tDQSSp_2tCK_min;
        end else begin
            timing.tDQSSp_min = timing.tDQSSp_1tCK_min;
            timing.tDQSSp_min = timing.tDQSSp_1tCK_min;
        end
        timing.tWR_CRC_DMc = GetDelayWriteCRCDM();
    end
    
    always @(negedge _state._gear_down_reset) begin
        gear_down_clk_synced <= 0;
        gear_down_clk <= 0;
        gear_down_1N2N <= 0;
    end
    
    task handle_sync_odt();
        reg[RTT_BITS-1:0] next_term_nominal, next_term_park, next_term_dynamic, next_odi_dq, next_odi_dqs, rtt_nominal_value;
        
        rtt_nominal_value = (1 == _state.ODTNominalEnabled()) ? GetRTTNominal() : 'z;
        next_term_nominal = (odt_pin_pipe[0] && !_state.InSelfRefresh() && (0 == _state.InMaxPowerSave()) && !((1 == GetqOff()) && (0 == GetWriteLevelization()))) ?
                            rtt_nominal_value : 'z;
        next_term_park = ((1 == _state.ODTParkEnabled()) && (0 == GetqOff()) && !_state.InSelfRefresh() && (0 == _state.InMaxPowerSave())) ? 
                            GetRTTPark() : 'z;
        next_term_dynamic = 'z;
        if ((1 == _state.ODTDynamicEnabled()) && (1 == GetDLLEnable())) begin
            // Satisfy ODTLcnw using a wr_pipe[starting in wr_preamble_clocks-] and ODTLcwn with wr_pipe[1+].
            for (int i=1; i<GetWrPreambleClocks() + 3;i++) begin
                if (1 == wr_pipe[i])  begin
                    next_term_dynamic = (0 == GetqOff()) ? GetRTTWrite() : 'z;
                    break;
                end else if (1 == odt_wr_pipe[i]) begin
                    next_term_dynamic = ((0 == GetqOff()) && (1 == _state.ODTDynamicEnabled())) ? 'x : 'z;
                    break;
                end
            end
        end
        if (((2 == GetRdPreambleClocks()) && (1 === rd_pipe[2])) ||
            ((1 == GetRdPreambleClocks()) && (1 === rd_pipe[1])) ||
             (1 === rd_pipe[0])) begin
            next_odi_dqs = ((0 == GetqOff()) || (GetPreambleTraining())) ? GetODI() : 'z;
        end else begin
            next_odi_dqs = (1 == _state.PreambleTrainingtSDOExpired()) ? GetODI() : 'z;
        end
        if (1 === rd_pipe[0]) begin
            next_odi_dq = (0 == GetqOff()) ? GetODI() : 'z;
        end else begin
            next_odi_dq = ((1 == GetWriteLevelization()) && (0 == GetqOff())) ? GetODI() : 'z;
        end
        
        term_nominal <= #(timing.tADCp*tCK/100) next_term_nominal;
        term_park <= #(timing.tADCp*tCK/100) next_term_park;
        term_dynamic <= #(timing.tADCp*tCK/100) next_term_dynamic;
        odi_dq <= #(timing.tDQSCK + 1) next_odi_dq;
        odi_dqs <= #(timing.tDQSCK + 1) next_odi_dqs;
        if (1 == GetRdDBI()) begin
            if ((0 == _dut_config.ignore_dbi_with_mpr) || (0 === _state.InMPRAccess()))
                odi_dm <= #(timing.tDQSCK + 1) next_odi_dq;
        end
        
        if (('z === odi_dqs) && ('z !== next_odi_dqs)) begin
            odi_dqs_x <= #(timing.tDQSCK) 'x;
            odi_dqs_x <= #(timing.tDQSCK + timing.tAON_max) '1;
        end
        if (('z === odi_dq) && ('z !== next_odi_dq)) begin
            odi_dq_x <= #(timing.tDQSCK) 'x;
            odi_dq_x <= #(timing.tDQSCK + timing.tAON_max) '1;
            if (1 == GetRdDBI()) begin
                odi_dm_x <= #(timing.tDQSCK) 'x;
                odi_dm_x <= #(timing.tDQSCK + timing.tAON_max) '1;
            end
        end
        
        if (((2 == GetRdPreambleClocks()) && (1 === rd_pipe[3])) ||
            ((1 == GetRdPreambleClocks()) && (1 === rd_pipe[2]))) begin // Starting a read.
            bit rtt_on;
            
            rtt_dqs <= #(timing.tADCp*tCK/100) 'z;
            rtt_on = 0;
            if (('z !== odi_dqs) && ('z === next_odi_dqs)) begin // Finishing a read.
                if ('z !== term_nominal)
                    rtt_dqs <= #(0) term_nominal;
                else
                    rtt_dqs <= #(0) term_park;
                if (('z !== term_nominal) || ('z !== term_park)) begin
                    rtt_dqs_x <= #(0) 'x;
                    rtt_dqs_x <= #(timing.tAON_max) '1;
                    rtt_on = 1;
                end
                odi_dqs_x <= #(timing.tDQSCK) 'x;
                odi_dqs_x <= #(timing.tDQSCK + timing.tAON_max) '1;
            end
            if (('z === term_nominal) && ('z !== next_term_nominal) && ('z === next_odi_dqs)) begin
                rtt_on = 1;
            end
            if ((('z === next_odi_dqs) && ('z !== rtt_dqs)) || (1 == rtt_on)) begin
                rtt_dqs_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dqs_x <= #(timing.tADCp_max*tCK/100) '1;
            end
        end else if ('z !== next_odi_dqs) begin // In a read.
        end else if ('z !== next_term_dynamic) begin // In a write.
            rtt_dqs <= #(timing.tADCp*tCK/100) (RTTW_Z == next_term_dynamic) ? 'z : next_term_dynamic;
            if ('x === next_term_dynamic) begin
                rtt_dqs_x <= #(timing.tADCp_min*tCK/100) 'x;
            end else if ('z === term_dynamic) begin
                rtt_dqs_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dqs_x <= #(timing.tADCp_max*tCK/100) '1;
            end
            if (('z !== odi_dqs) && ('z === next_odi_dqs)) begin // Finishing a read.
                odi_dqs_x <= #(timing.tDQSCK) 'x;
                odi_dqs_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                if ('z !== term_nominal) begin
                    rtt_dqs <= #(0) term_nominal;
                end else begin
                    rtt_dqs <= #(0) term_park;
                end
                if (('z !== term_nominal) || ('z !== term_park)) begin
                    rtt_dqs_x <= #(0) 'x;
                    rtt_dqs_x <= #(timing.tAON_max) '1;
                end
            end
        end else begin
            bit finishing_read, forced_nominal;
            
            finishing_read = 0;
            if ('z !== odi_dqs) begin // Finishing a read.
                finishing_read = 1;
                if ('z !== term_nominal) begin
                    rtt_dqs <= #(0) term_nominal;
                    forced_nominal = 1;
                end else begin
                    rtt_dqs <= #(0) term_park;
                    forced_nominal = 0;
                end
                if (('z !== term_nominal) || ('z !== term_park)) begin
                    rtt_dqs_x <= #(0) 'x;
                    rtt_dqs_x <= #(timing.tAON_max) '1;
                end
                odi_dqs_x <= #(timing.tDQSCK) 'x;
                odi_dqs_x <= #(timing.tDQSCK + timing.tAON_max) '1;
            end
            if ('z !== next_term_nominal) begin
                rtt_dqs <= #(timing.tADCp*tCK/100) next_term_nominal;
                if (((0 == finishing_read) && (rtt_dqs !== next_term_nominal)) || 
                    ((1 == finishing_read) && (0 == forced_nominal))) begin
                    rtt_dqs_x <= #(timing.tADCp_min*tCK/100) 'x;
                    rtt_dqs_x <= #(timing.tADCp_max*tCK/100) '1;
                end
            end else begin
                rtt_dqs <= #(timing.tADCp*tCK/100) next_term_park;
                if (((0 == finishing_read) && (rtt_dqs !== next_term_park)) ||
                    ((1 == finishing_read) && (1 == forced_nominal))) begin
                    rtt_dqs_x <= #(timing.tADCp_min*tCK/100) 'x;
                    if (('x === term_dynamic) && (0 == _state.OpenBanks())) begin  // Dynamic->park transition time is slower for closed bank writes.
                        rtt_dqs_x <= #(timing.tADCp_max*tCK/100 + (1.5*timing.tCK)) '1;
                    end else begin
                        rtt_dqs_x <= #(timing.tADCp_max*tCK/100) '1;
                    end
                end
            end
        end
        
        if ((('z !== next_odi_dqs) && (1 == GetRdPreambleClocks())) ||
            (('z === odi_dq) && ('z !== odi_dqs) && (2 == GetRdPreambleClocks()))) begin // Staring a read.
            bit rtt_on;
            
            rtt_dq <= #(timing.tADCp*tCK/100) 'z;
            rtt_on = 0;
            if (('z !== odi_dq) && (('z === next_odi_dq))) begin // Finishing a read.
                if ('z !== term_nominal)
                    rtt_dq <= #(0) term_nominal;
                else
                    rtt_dq <= #(0) term_park;
                if (('z !== term_nominal) || ('z !== term_park)) begin
                    rtt_dq_x <= #(0) 'x;
                    rtt_dq_x <= #(timing.tAON_max) '1;
                    rtt_on = 1;
                end
                odi_dq_x <= #(timing.tDQSCK) 'x;
                odi_dq_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                if (1 == GetRdDBI()) begin
                    odi_dm_x <= #(timing.tDQSCK) 'x;
                    odi_dm_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                end
            end
            if (('z !== rtt_dq) || (1 == rtt_on)) begin
                rtt_dq_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dq_x <= #(timing.tADCp_max*tCK/100) '1;
            end
        end else if ('z !== next_odi_dq) begin // In a read.
        end else if ('z !== next_term_dynamic) begin // In a write.
            rtt_dq <= #(timing.tADCp*tCK/100) (RTTW_Z == next_term_dynamic) ? 'z : next_term_dynamic;
            if ('x === next_term_dynamic) begin
                rtt_dq_x <= #(timing.tADCp_min*tCK/100) 'x;
            end else if ('z === term_dynamic) begin
                rtt_dq_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dq_x <= #(timing.tADCp_max*tCK/100) '1;
            end
            if (('z !== odi_dq) && (('z === next_odi_dq))) begin // Finishing a read.
                odi_dq_x <= #(timing.tDQSCK) 'x;
                odi_dq_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                if (1 == GetRdDBI()) begin
                    odi_dm_x <= #(timing.tDQSCK) 'x;
                    odi_dm_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                end
                if ('z !== term_nominal) begin
                    rtt_dq <= #(0) term_nominal;
                end else begin
                    rtt_dq <= #(0) term_park;
                end
                if (('z !== term_nominal) || ('z !== term_park)) begin
                    rtt_dq_x <= #(0) 'x;
                    rtt_dq_x <= #(timing.tAON_max) '1;
                end
            end
        end else begin // All other states.
            bit finishing_read, forced_nominal;
            
            finishing_read = 0;
            if ('z !== odi_dq) begin // Finishing a read.
                finishing_read = 1;
                if ('z !== term_nominal) begin
                    rtt_dq <= #(0) term_nominal;
                    forced_nominal = 1;
                end else begin
                    rtt_dq <= #(0) term_park;
                    forced_nominal = 0;
                end
                if (('z !== term_nominal) || ('z !== term_park)) begin
                    rtt_dq_x <= #(0) 'x;
                    rtt_dq_x <= #(timing.tAON_max) '1;
                end
                odi_dq_x <= #(timing.tDQSCK) 'x;
                odi_dq_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                if (1 == GetRdDBI()) begin
                    odi_dm_x <= #(timing.tDQSCK) 'x;
                    odi_dm_x <= #(timing.tDQSCK + timing.tAON_max) '1;
                end
            end
            if ('z !== next_term_nominal) begin
                rtt_dq <= #(timing.tADCp*tCK/100) next_term_nominal;
                if (((0 == finishing_read) && (rtt_dq !== next_term_nominal)) || 
                    ((1 == finishing_read) && (0 == forced_nominal))) begin
                    rtt_dq_x <= #(timing.tADCp_min*tCK/100) 'x;
                    rtt_dq_x <= #(timing.tADCp_max*tCK/100) '1;
                end
            end else begin
                rtt_dq <= #(timing.tADCp*tCK/100) next_term_park;
                if (((0 == finishing_read) && (rtt_dq !== next_term_park)) || 
                    ((1 == finishing_read) && (1 == forced_nominal))) begin
                    rtt_dq_x <= #(timing.tADCp_min*tCK/100) 'x;
                    if (('x === term_dynamic) && (0 == _state.OpenBanks())) begin  // Dynamic->park transition time is slower for closed bank writes.
                        rtt_dq_x <= #(timing.tADCp_max*tCK/100 + timing.tCK) '1;
                    end else begin
                        rtt_dq_x <= #(timing.tADCp_max*tCK/100) '1;
                    end
                end
            end
        end
        if ('z !== next_term_dynamic) begin // In a write.
            rtt_dm <= #(timing.tADCp*tCK/100) (RTTW_Z == next_term_dynamic) ? 'z : next_term_dynamic;
            if ('x === next_term_dynamic) begin
                rtt_dm_x <= #(timing.tADCp_min*tCK/100) 'x;
            end else if ('z === term_dynamic) begin
                rtt_dm_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dm_x <= #(timing.tADCp_max*tCK/100) '1;
            end
        end else if ('z !== next_term_nominal) begin
            rtt_dm <= #(timing.tADCp*tCK/100) next_term_nominal;
            if (rtt_dm !== next_term_nominal) begin
                rtt_dm_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dm_x <= #(timing.tADCp_max*tCK/100) '1;
            end
        end else begin
            rtt_dm <= #(timing.tADCp*tCK/100) next_term_park;
            if (rtt_dm !== next_term_park) begin
                rtt_dm_x <= #(timing.tADCp_min*tCK/100) 'x;
                rtt_dm_x <= #(timing.tADCp_max*tCK/100) '1;
            end
        end
    endtask
    
    task handle_async_odt();
        reg[RTT_BITS-1:0] next_term_nominal, next_term_park, next_odi_dq, next_odi_dqs, rtt_nominal_value;
        int odi_dq_delay;
        bit odt_transition;
        int dq_block, dqs_block;
        
        #(1); // Delay until the ODT pipe is in the current cycle since tDQSCK can be < tCK.
        rtt_nominal_value = (1 == _state.ODTNominalEnabled()) ? GetRTTNominal() : 'z;
        next_term_nominal = (odt_pin_pipe[0] && !_state.InSelfRefresh() && (0 == _state.InMaxPowerSave()) && !((1 == GetqOff()) && (0 == GetWriteLevelization()))) ?
                            rtt_nominal_value : 'z;
        next_term_park = ((1 == _state.ODTParkEnabled()) && (0 == GetqOff()) && !_state.InSelfRefresh() && (0 == _state.InMaxPowerSave())) ? GetRTTPark() : 'z;
        if (term_nominal !== next_term_nominal) begin
            odt_async_transition = $time;
        end
        term_nominal <= #(timing.tAONPD_min) next_term_nominal;
        term_park <= #(timing.tAONPD_min) next_term_park;
        if (((2 == GetRdPreambleClocks()) && (1 === rd_pipe[2])) ||
            ((1 == GetRdPreambleClocks()) && (1 === rd_pipe[1])) ||
             (1 === rd_pipe[0])) begin
            next_odi_dqs = ((0 == GetqOff()) || (GetPreambleTraining())) ? GetODI() : 'z;
        end else begin
            next_odi_dqs = (1 == _state.PreambleTrainingtSDOExpired()) ? GetODI() : 'z;
        end
        if (1 === rd_pipe[0]) begin
            next_odi_dq = (0 == GetqOff()) ? GetODI() : 'z;
        end else begin
            next_odi_dq = ((1 == GetWriteLevelization()) && (0 == GetqOff())) ? GetODI() : 'z;
        end
        odi_dq_delay = timing.tCK + timing.tDQSCK;
        odi_dq <= #(odi_dq_delay) next_odi_dq;
        odi_dqs <= #(odi_dq_delay) next_odi_dqs;
        if (1 == GetRdDBI()) begin
            if ((0 == _dut_config.ignore_dbi_with_mpr) || (0 === _state.InMPRAccess()))
                odi_dm <= #(odi_dq_delay) next_odi_dq;
        end
            
        dqs_block = 0;
        // Starting a read.
        if (('z === odi_dqs_dll_disable) && ('z !== next_odi_dqs)) begin
            dqs_block = 1;
            odi_dqs_x <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'x;
            odi_dqs_x <= #(odi_dq_delay) '1;
            if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
                rtt_dqs <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'z;
                if (rtt_dqs !== next_term_nominal) begin // Nominal is starting or finishing at the same time as read starting.
                    rtt_dqs_x <= #(timing.tAONPD_min) 'x;
                    if ((rtt_dqs_x_hold > $time) && (rtt_dqs_x_hold < ($time + odi_dq_delay)))
                        rtt_dqs_x <= #(rtt_dqs_x_hold - $time) 'x;
                end else
                    rtt_dqs_x <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'x;
                rtt_dqs_x <= #(odi_dq_delay) '1;
            end
        // Finishing a read.
        end else if (('z !== odi_dqs_dll_disable) && ('z === next_odi_dqs)) begin
            dqs_block = 2;
            odi_dqs_x <= #(odi_dq_delay) 'x;
            odi_dqs_x <= #(odi_dq_delay + (timing.tAOFASp*timing.tCK/100)) '1;
            if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
                int max_delay;
                if ('z !== next_term_nominal)
                    rtt_dqs <= #(odi_dq_delay) next_term_nominal;
                else
                    rtt_dqs <= #(odi_dq_delay) next_term_park;
                rtt_dqs_x <= #(odi_dq_delay) 'x;
                if (term_nominal !== next_term_nominal) // Nominal is starting or finishing at the same time as read ending.
                    max_delay = (timing.tAONPD_max + odi_dq_delay) - timing.tDQSCK;
                else
                    max_delay = odi_dq_delay + (timing.tAOFASp*timing.tCK/100);
                rtt_dqs_x <= #(max_delay) '1;
                if (rtt_dqs_x_hold > $time) begin // Overwrite the pending start compare time.
                    rtt_dqs_x <= #(rtt_dqs_x_hold - $time) 'x;
                end
                rtt_dqs_x_hold = $time + max_delay;
            end
        // In a read.
        end else if ('z !== next_odi_dqs) begin
            dqs_block = 3;
            if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
                rtt_dqs <= #(odi_dq_delay) 'z;
            end
        end else if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
            int on_delay, max_delay;
            
            dqs_block = 4;
            on_delay = ('z !== odi_dqs) ? timing.tDQSCK : timing.tAONPD_min;
            max_delay = timing.tAONPD_max;
            odt_transition = 0;
            if ('z !== next_term_nominal) begin
                rtt_dqs <= #(on_delay) next_term_nominal;
                if (term_nominal !== next_term_nominal) begin
                    odt_transition = 1;
                end
            end else begin
                rtt_dqs <= #(on_delay) next_term_park;
                if (rtt_dqs !== next_term_park) begin
                    odt_transition = 1;
                end
            end
            if ((1 == odt_transition) || ('z !== odi_dqs)) begin
                rtt_dqs_x <= #(on_delay) 'x;
                rtt_dqs_x <= #(max_delay) '1;
                if ((rtt_dqs_x_hold > $time) && (rtt_dqs_x_hold < ($time + max_delay))) begin // Overwrite the pending start compare time.
                    rtt_dqs_x <= #(rtt_dqs_x_hold - $time) 'x;
                end
                rtt_dqs_x_hold = $time + max_delay;
            end
        // RTT is off.
        end else begin
            rtt_dqs <= #(odi_dq_delay) 'z;
        end
        
        // Starting a read.
        if (('z === odi_dq_dll_disable) && ('z !== next_odi_dq)) begin
            dq_block = 1;
            odi_dq_x <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'x;
            odi_dq_x <= #(odi_dq_delay) '1;
            if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
                rtt_dq <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'z;
                rtt_dm <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'z;
                if (rtt_dq !== next_term_nominal) begin // Nominal is starting or finishing at the same time as read starting.
                    rtt_dq_x <= #(timing.tAONPD_min) 'x;
                    rtt_dm_x <= #(timing.tAONPD_min) 'x;
                    if ((rtt_dq_x_hold > $time) && (rtt_dq_x_hold < ($time + odi_dq_delay))) begin
                        rtt_dq_x <= #(rtt_dq_x_hold - $time) 'x;
                        rtt_dm_x <= #(rtt_dq_x_hold - $time) 'x;
                    end
               end else begin
                    rtt_dq_x <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'x;
                    rtt_dm_x <= #(odi_dq_delay - (timing.tAOFASp*timing.tCK/100)) 'x;
                end
                rtt_dq_x <= #(odi_dq_delay) '1;
                rtt_dm_x <= #(odi_dq_delay) '1;
            end
        // Finishing a read.
        end else if (('z !== odi_dq_dll_disable) && ('z === next_odi_dq)) begin
            dq_block = 2;
            odi_dq_x <= #(odi_dq_delay) 'x;
            odi_dq_x <= #(odi_dq_delay + (timing.tAOFASp*timing.tCK/100)) '1;
            if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
                int max_delay;
                if ('z !== next_term_nominal) begin
                    rtt_dq <= #(odi_dq_delay) next_term_nominal;
                    rtt_dm <= #(odi_dq_delay) next_term_nominal;
                end else begin
                    rtt_dq <= #(odi_dq_delay) next_term_park;
                    rtt_dm <= #(odi_dq_delay) next_term_park;
                end
                rtt_dq_x <= #(odi_dq_delay) 'x;
                rtt_dm_x <= #(odi_dq_delay) 'x;
                if (term_nominal !== next_term_nominal) // Nominal is starting or finishing at the same time as read ending.
                    max_delay = (timing.tAONPD_max + odi_dq_delay) - timing.tDQSCK;
                else
                    max_delay = odi_dq_delay + (timing.tAOFASp*timing.tCK/100);
                rtt_dq_x <= #(max_delay) '1;
                rtt_dm_x <= #(max_delay) '1;
                if (rtt_dq_x_hold > $time) begin // Overwrite the pending start compare time.
                    rtt_dq_x <= #(rtt_dq_x_hold - $time) 'x;
                    rtt_dm_x <= #(rtt_dq_x_hold - $time) 'x;
                end
                rtt_dq_x_hold = $time + max_delay;
            end
        // In a read.
        end else if ('z !== next_odi_dq) begin
            dq_block = 3;
            if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
                rtt_dq <= #(odi_dq_delay) 'z;
                rtt_dm <= #(odi_dq_delay) 'z;
            end
        end else if ((1 == _state.ODTNominalEnabled()) || (1 == _state.ODTParkEnabled())) begin
            int on_delay, max_delay;
            
            dq_block = 4;
            on_delay = ('z !== odi_dq) ? timing.tDQSCK : timing.tAONPD_min;
            max_delay = timing.tAONPD_max;
            odt_transition = 0;
            if ('z !== next_term_nominal) begin
                rtt_dq <= #(on_delay) next_term_nominal;
                rtt_dm <= #(on_delay) next_term_nominal;
                if (term_nominal !== next_term_nominal) begin
                    odt_transition = 1;
                end
            end else begin
                rtt_dq <= #(on_delay) next_term_park;
                rtt_dm <= #(on_delay) next_term_park;
                if (rtt_dq !== next_term_park) begin
                    odt_transition = 1;
                end
            end
            if ((1 == odt_transition) || ('z !== odi_dq)) begin
                rtt_dq_x <= #(on_delay) 'x;
                rtt_dq_x <= #(max_delay) '1;
                rtt_dm_x <= #(on_delay) 'x;
                rtt_dm_x <= #(max_delay) '1;
                if ((rtt_dq_x_hold > $time) && (rtt_dq_x_hold < ($time + max_delay))) begin // Overwrite the pending start compare time.
                    rtt_dq_x <= #(rtt_dq_x_hold - $time) 'x;
                    rtt_dm_x <= #(rtt_dq_x_hold - $time) 'x;
                end
                rtt_dq_x_hold = $time + max_delay;
            end
        // RTT is off.
        end else begin
            rtt_dq <= #(odi_dq_delay) 'z;
            rtt_dm <= #(odi_dq_delay) 'z;
        end
        odi_dq_dll_disable = next_odi_dq;
        odi_dqs_dll_disable = next_odi_dqs;
    endtask
    task ignore_all_rtt(int start_ignore, int stop_ignore);
        rtt_dq_x <= #start_ignore 'x;
        rtt_dqs_x <= #start_ignore 'x;
        rtt_dm_x <= #start_ignore 'x;
        odi_dq_x <= #start_ignore 'x;
        odi_dqs_x <= #start_ignore 'x;
        odi_dm_x <= #start_ignore 'x;
        rtt_dq_x <= #(timing.tADCp_max*stop_ignore/100 + 1) 'x;
        rtt_dqs_x <= #(timing.tADCp_max*stop_ignore/100 + 1) 'x;
        rtt_dm_x <= #(timing.tADCp_max*stop_ignore/100 + 1) 'x;
        odi_dq_x <= #(timing.tADCp_max*stop_ignore/100 + 1) 'x;
        odi_dqs_x <= #(timing.tADCp_max*stop_ignore/100 + 1) 'x;
        odi_dm_x <= #(timing.tADCp_max*stop_ignore/100 + 1) 'x;
        rtt_dq_x <= #(stop_ignore) 1'b1;
        rtt_dqs_x <= #(stop_ignore) 1'b1;
        rtt_dm_x <= #(stop_ignore) 1'b1;
        odi_dq_x <= #(stop_ignore) 1'b1;
        odi_dqs_x <= #(stop_ignore) 1'b1;
        odi_dm_x <= #(stop_ignore) 1'b1;
    endtask
    function void VerifyMR();
        int ideal_cwl, ideal_tCCD_L;
        UTYPE_TS slowest_ts, fastest_ts, ideal_ts;
        
        if (0 == GetDLLEnable())
            return;
            
        proj_package::GetCLSpeedRange(GetDutModeConfig(), slowest_ts, fastest_ts, ideal_ts);
        ideal_tCCD_L = proj_package::GettCCD_LSpeed(GetDutModeConfig(), timing.ts_loaded);
        ideal_cwl = proj_package::GetCWLSpeed(GetDutModeConfig(), timing.ts_loaded);
        
        if (GetWriteRecovery() < proj_package::GetMintWR(GetDutModeConfig(), timing.tWRc, timing.tRTPc)) begin
            $display("%m:tWR/tRTP SPEC_VIOLATION tWR spec:%0d loaded:%0d tRTP spec:%0d loaded:%0d @%0t", 
                     timing.tWRc, GetWriteRecovery(), timing.tRTPc*timing.tCK, (GetWriteRecovery()/2)*timing.tCK, $time);
        end
        if ((timing.ts_loaded > fastest_ts) || (timing.ts_loaded < slowest_ts))
            $display("%m:tCK SPEC_VIOLATION spec:%0s to %0s loaded:%0s @%0t", slowest_ts.name(), fastest_ts.name(), timing.ts_loaded.name(), $time);
        if (1 == GetGeardown()) begin
            if (GetWriteRecovery() % 4 != 0) begin
                $display("%m:GD_WR SPEC_VIOLATION loaded:%0d @%0t", GetWriteRecovery(), $time);
            end
            if (GetCL() % 2 != 0) begin
                $display("%m:GD_CL SPEC_VIOLATION loaded:%0d @%0t", GetCL(), $time);
            end
            if (rALN1 == GetALReg()) begin
                $display("%m:GD_AL SPEC_VIOLATION loaded:%0d @%0t",GetALReg() , $time);
            end
            if (GetCWL() % 2 != 0) begin
                $display("%m:GD_CWL SPEC_VIOLATION loaded:%0d @%0t", GetCWL(), $time);
            end
            if (GetCAL() % 2 != 0) begin
                $display("%m:GD_CAL SPEC_VIOLATION loaded:%0d @%0t", GetCAL(), $time);
            end
            if (CAPARITY_L5 == GetCAParityLatency()) begin
                $display("%m:GD_PL SPEC_VIOLATION loaded:%0d @%0t", GetCAParityLatency(), $time);
            end
            if (GettCCD_L() % 2 != 0) begin
                $display("%m:GD_tCCDL SPEC_VIOLATION loaded:%0d @%0t", GettCCD_L(), $time);
            end
        end else begin
            if (GetCWL() < ideal_cwl)
                $display("%m:CWL SPEC_VIOLATION spec:%0d loaded:%0d @%0t", ideal_cwl, GetCWL(), $time);
            if (GettCCD_L() < ideal_tCCD_L)
                $display("%m:tCCD_L SPEC_VIOLATION spec:%0d loaded:%0d @%0t", ideal_tCCD_L, GettCCD_L(), $time);
        end
    endfunction
    function void set_silent_violations(bit silent);
        silent_violations = silent;
    endfunction
    function void set_timing_parameter_lock(bit locked);
        lock_timing_parameters = locked;
        locked_tck = timing.tCK;
    endfunction
    function bit initialize_memory_with_file(string memory_file);
        return _storage.InitializeWithFile(memory_file);
    endfunction
    function bit memory_read(bit[MAX_BANK_GROUP_BITS-1:0] bg, bit[MAX_BANK_BITS-1:0] ba, bit[MAX_ROW_ADDR_BITS-1:0] row, 
                             bit[MAX_COL_ADDR_BITS-1:0] col, output logic[MAX_DQ_BITS*MAX_BURST_LEN-1:0] data);
        MemArray::memKey_type mem_key;
        
        data = '0;
        mem_key.rank = 0;
        mem_key.bank_group = bg;
        mem_key.bank = ba;
        mem_key.row = row;
        for (int i=0;i<MAX_BURST_LEN;i++) begin
            logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data0, data1;
            
            mem_key.col = ((col & (-1*MAX_BURST_LEN)) | i) & _dut_config.col_mask;
            for (int dmBit=0; dmBit<_dut_config.num_dms; dmBit=dmBit+1) begin
                mem_key.dm = dmBit;
                if (0 == dmBit) begin
                    data0 = _storage.Read(mem_key);
                end else if (1 == dmBit) begin
                    data1 = _storage.Read(mem_key);
                end
            end
            data |= {data1, data0} << i*MAX_DQ_BITS;
        end
    endfunction
    function bit memory_write(bit[MAX_BANK_GROUP_BITS-1:0] bg, bit[MAX_BANK_BITS-1:0] ba, bit[MAX_ROW_ADDR_BITS-1:0] row, 
                              bit[MAX_COL_ADDR_BITS-1:0] col, logic[MAX_DQ_BITS*MAX_BURST_LEN-1:0] data);
        MemArray::memKey_type mem_key;
        logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] wr_data;
        
        mem_key.rank = 0;
        mem_key.bank_group = bg;
        mem_key.bank = ba;
        mem_key.row = row;
        for (int i=0;i<MAX_BURST_LEN;i++) begin
            mem_key.col = ((col & (-1*MAX_BURST_LEN)) | i) & _dut_config.col_mask;
            for (int dmBit=0; dmBit<_dut_config.num_dms; dmBit++) begin
                mem_key.dm = dmBit;
                wr_data = data >> ((i*MAX_DQ_BITS)+(dmBit*MAX_DQ_BITS/MAX_DM_BITS));
                _storage.Write(mem_key, wr_data);
            end
        end
    endfunction
    function void set_unwritten_memory_default(logic unwritten_memory_default);
        _storage.SetUnwrittenMemoryDefault(unwritten_memory_default);
    endfunction
    function void set_vref_target(int percentage_in_hundreds);
        if (percentage_in_hundreds > vref_max)
            vref_target = vref_max;
        else if (percentage_in_hundreds < vref_min)
            vref_target = vref_min;
        else
            vref_target = percentage_in_hundreds;
    endfunction
    function void set_vref_tolerance(int percentage_in_hundreds);
        vref_tolerance = percentage_in_hundreds;
    endfunction
    // Accessor/wrapper functions for model mode register settings.
    // NCVerilog cannot access a packed structure in a module so a temp local is created.
    function UTYPE_DutModeConfig GetDutModeConfig();
        return _state.s_dut_mode_config;
    endfunction
    function void SetDutModeConfig(UTYPE_DutModeConfig dut_mode_config);
        _state.s_dut_mode_config = dut_mode_config;
    endfunction
    function int GetBL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.BL;
    endfunction
    function UTYPE_blreg GetBLReg();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.BL_reg;
    endfunction
    function UTYPE_bt GetBT();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.BT;
    endfunction
    function int GetCL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.CL;
    endfunction
    function int GetWriteRecovery();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.write_recovery;
    endfunction
    function bit GetDLLEnable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.DLL_enable;
    endfunction
    function UTYPE_odi GetODI();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.ODI;
    endfunction
    function UTYPE_rttn GetRTTNominal();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.rtt_nominal;
    endfunction
    function UTYPE_alreg GetALReg;
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.AL_reg;
    endfunction
    function int GetAL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.AL;
    endfunction
    function bit GetWriteLevelization();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.write_levelization;
    endfunction
    function bit GetDLLReset();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.DLL_reset;
    endfunction
    function bit GettDQS();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.tDQS;
    endfunction
    function bit GetqOff();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.qOff;
    endfunction
    function int GetCWL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.CWL;
    endfunction
    function UTYPE_lpasr GetLPASR();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.LPASR;
    endfunction
    function UTYPE_rttw GetRTTWrite();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.rtt_write;
    endfunction
    function bit GetTRREnable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.trr_enable;
    endfunction
    function int GetTRRBank();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.trr_ba;
    endfunction
    function int GetTRRBankGroup();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.trr_bg;
    endfunction
    function bit GetWriteCRCEnable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.write_crc_enable;
    endfunction
    function bit GetMPREnable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.MPR_enable;
    endfunction
    function UTYPE_mpr GetMPRMode();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.MPR_mode;
    endfunction
    function UTYPE_mprpage GetMPRPage();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.MPR_page;
    endfunction
    function UTYPE_delay_write_crc_dm GetDelayWriteCRCDM();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.delay_write_crc_dm;
    endfunction
    function bit GetMPS();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.MPS;
    endfunction
    function bit GetTCRMode();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.TCR_mode;
    endfunction
    function bit GetTCRRange();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.TCR_range;
    endfunction
    function int GetCAL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.CAL;
    endfunction
    function bit GetPreambleTraining();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.preamble_training;
    endfunction
    function int GetRdPreambleClocks();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.rd_preamble_clocks;
    endfunction
    function int GetWrPreambleClocks();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.wr_preamble_clocks;
    endfunction
    function bit GetPPREnable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.ppr_enable;
    endfunction
    function bit GetTempSense();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.temp_sense_enable;
    endfunction
    function bit GetPerDramAddr();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.perdram_addr;
    endfunction
    function bit GetGeardown();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.gear_down;
    endfunction
    function bit GetDMEnable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.dm_enable;
    endfunction
    function bit GetWrDBI();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.write_dbi;
    endfunction
    function bit GetRdDBI();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.read_dbi;
    endfunction
    function UTYPE_caparity_latency GetCAParityLatency();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.CA_parity_latency;
    endfunction
    function bit GetCRCError();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.crc_error;
    endfunction
    function UTYPE_rttp GetRTTPark();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.rtt_park;
    endfunction
    function bit GetStickyParityError();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.sticky_parity_error;
    endfunction
    function bit GetDLLFrozen();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.dll_frozen;
    endfunction
    function UTYPE_refmode GetRefreshMode();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.refresh_mode;
    endfunction
    function bit GetParityError();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.CA_parity_error;
    endfunction
    function bit GetFastSelfRefresh();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.fast_self_refresh;
    endfunction
    function bit GetVrefTraining();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.vref_training;
    endfunction
    function int GettCCD_L();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.tCCD_L;
    endfunction
    function int GetODTBufferDisable();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.odt_buffer_disable;
    endfunction
    function int GetRL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.RL;
    endfunction
    function int GetWL();
        UTYPE_DutModeConfig dmc;
        dmc = _state.s_dut_mode_config;
        return dmc.WL_calculated;
    endfunction
    function int GetWidth();
        return _dut_config.by_mode;
    endfunction
endmodule


