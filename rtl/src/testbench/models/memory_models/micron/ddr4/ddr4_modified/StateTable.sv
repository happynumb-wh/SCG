`ifndef STATE_TABLE_DEFINE
`define STATE_TABLE_DEFINE

import arch_package::*;
module StateTable();
    timeunit 1ps;
    timeprecision 1ps;
`include "StateTableCore.sv"
    initial begin
        INITCYCLENUM = 1000;
        _current_cycle = INITCYCLENUM;
        s_latched_cmd = new();
        _last_data_cmd = new();
        HardReset();
    end
    
    function void Initialize(string id, UTYPE_dutconfig dut_config, bit debug = 0);
        _id = id;
        _debug = debug;
        _dut_config = dut_config;
        HardReset();
    endfunction
    
    always @(s_dut_mode_config.rtt_park or
             s_dut_mode_config.rtt_write or
             s_dut_mode_config.rtt_nominal or
             s_dut_mode_config.ODI or
             s_dut_mode_config.write_levelization or
             s_dut_mode_config.MPR_enable or
             s_dut_mode_config.dm_enable or
             s_dut_mode_config.tDQS or
             s_dut_mode_config.CWL or
             s_dut_mode_config.CL or
             s_dut_mode_config.BL_reg or
             s_dut_mode_config.AL_reg or
             s_dut_mode_config.tDQS or
             s_dut_mode_config.CA_parity_latency or
             s_dut_mode_config.DLL_reset or
             s_dut_mode_config.dll_frozen or
             s_dut_mode_config.DLL_enable or
             s_dut_mode_config.write_dbi or
             s_dut_mode_config.read_dbi or
             s_dut_mode_config.MPS or
             s_dut_mode_config.qOff) begin
        tMOD_transition(_timing.tMODc);
    end
    
    always @(s_dut_mode_config.preamble_training) begin
        tMOD_transition(_timing.tSDOc_max);
    end
    
    always @(s_dut_mode_config.gear_down) begin
        _gear_down_reset <= #(0) 1;
        _gear_down_reset <= #(_timing.tCMD_GEARc*_timing.tCK) 0;
        GeardownToggle();
        tMOD_transition(_timing.tMODc);
    end

    task tMOD_transition(int cycles_to_ignore);
        for (int i=0;i<cycles_to_ignore;i++)
            _ODT_tMOD_transition <= #(_timing.tCK*i) 1; // Overwrite any previous #() 0.
        _ODT_tMOD_transition <= #(_timing.tCK*cycles_to_ignore) 0;
    endtask

endmodule : StateTable
`endif
