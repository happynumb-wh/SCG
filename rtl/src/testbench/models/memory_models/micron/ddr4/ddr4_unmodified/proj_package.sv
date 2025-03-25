package proj_package;
    timeunit 1ps;
    timeprecision 1ps;
    import arch_package::*;
    
    parameter DEF_CCD_L = 10;

    function void project_dut_config(inout UTYPE_dutconfig dut_config);
        dut_config.min_CL_dll_off = 5;
        dut_config.max_CL_dll_off = 10;
        dut_config.max_CL_dbi_enabled = 20;
        dut_config.max_CL_dbi_disabled = 18;
        dut_config.min_CL_dbi_enabled = 10;
        dut_config.min_CL_dbi_disabled = 9;
        dut_config.cl_17_19_21_feature = 1;
        dut_config.ignore_dbi_with_mpr = 0;
        dut_config.min_CL  = 9;
        dut_config.max_CL  = 24;
        dut_config.min_CWL = MIN_CWL;
        dut_config.max_CWL = 18;
        dut_config.max_CAL = 8;
    endfunction

    function int GetCWLSpeed(input UTYPE_DutModeConfig dut_mode_config, input UTYPE_TS ts);
        int cwl;
        
        cwl = 9;
        case (ts)
            TS_1875,
            TS_1500,
            TS_1250 : begin
                cwl = 9;
                if ((2 == dut_mode_config.wr_preamble_clocks) || (1 == dut_mode_config.gear_down))
                    cwl = 10;
            end 
            TS_1072 : begin
                cwl = 10;
                if (2 == dut_mode_config.wr_preamble_clocks)
                    cwl = (1 == dut_mode_config.gear_down) ? 12 : 11;
            end 
            TS_938 : begin
                cwl = 11;
                if ((2 == dut_mode_config.wr_preamble_clocks) || (1 == dut_mode_config.gear_down))
                    cwl = 12;
            end 
            TS_833 : begin
                cwl = 12;
                if (2 == dut_mode_config.wr_preamble_clocks)
                    cwl = 14;
            end 
            TS_750 : begin
                cwl = 14;
                if (2 == dut_mode_config.wr_preamble_clocks)
                    cwl = 16;
            end 
            TS_682 : begin
                cwl = 16;
                if (2 == dut_mode_config.wr_preamble_clocks)
                    cwl = 18;
            end 
            TS_625 : begin
                cwl = 18;
            end
        endcase
        return cwl;
    endfunction
    
    function void GetCLSpeedRange(input UTYPE_DutModeConfig dut_mode_config, output UTYPE_TS slowest, output UTYPE_TS fastest, output UTYPE_TS ideal);
        case (dut_mode_config.CL)
            5,6,7,8,9: begin
                ideal = TS_1500;
                slowest = TS_1500; fastest = TS_1500;
            end
            10: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1500;
                    slowest = TS_1500; fastest = TS_1500;
                end else begin
                    ideal = TS_1500;
                    slowest = TS_1500; fastest = TS_1500;
                end
            end
            11: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1500;
                    slowest = TS_1500; fastest = TS_1500;
                end else begin
                    ideal = TS_1250;
                    slowest = TS_1500; fastest = TS_1250;
                end
            end
            12: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1500;
                    slowest = TS_1500; fastest = TS_1500;
                end else begin
                    ideal = TS_1250;
                    slowest = TS_1500; fastest = TS_1250;
                end
            end
            13: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1250;
                    slowest = TS_1500; fastest = TS_1250;
                end else begin
                    ideal = TS_1072;
                    slowest = TS_1250; fastest = TS_1072;
                end
            end
            14: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1250;
                    slowest = TS_1500; fastest = TS_1250;
                end else begin
                    ideal = TS_1072;
                    slowest = TS_1250; fastest = TS_938;
                end
            end
            15: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1072;
                    slowest = TS_1250; fastest = TS_1072;
                end else begin
                    ideal = TS_938;
                    slowest = TS_1072; fastest = TS_833;
                end
            end
            16: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_1072;
                    slowest = TS_1250; fastest = TS_1072;
                end else begin
                    ideal = TS_938;
                    slowest = TS_938; fastest = TS_833;
                end
            end
            17, 18: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_938;
                    slowest = TS_1072; fastest = TS_938;
                end else begin
                    ideal = TS_833;
                    slowest = TS_938; fastest = TS_833;
                end
            end
            19, 20: begin
                if (1 == dut_mode_config.read_dbi) begin
                    ideal = TS_938;
                    slowest = TS_938; fastest = TS_833;
                end else begin
                    ideal = TS_833;
                    slowest = TS_833; fastest = TS_833;
                end
            end
            21, 22: begin
                ideal = TS_833;
                slowest = TS_833; fastest = TS_833;
            end
            24: begin
                ideal = TS_833;
                slowest = TS_833; fastest = TS_833;
            end
        endcase
    endfunction
    
    function int GettCCD_LSpeed(input UTYPE_DutModeConfig dut_mode_config, input UTYPE_TS ts);
        int tCCD_L;
        
        tCCD_L = 4;
        case (ts)
            TS_1250,
            TS_1072 : begin
                tCCD_L = ((2 == dut_mode_config.wr_preamble_clocks) || (1 == dut_mode_config.gear_down)) ? 6 : 5;
            end 
            TS_938,
            TS_833 : begin
                tCCD_L = 6;
            end
        endcase
        return tCCD_L;
    endfunction

    function int GetMintWR(input UTYPE_DutModeConfig dut_mode_config, int tWRc, int tRTPc);
        int min_setting;
        
        min_setting = (tRTPc*2) > tWRc ? tRTPc*2 : tWRc;
        if (1 == dut_mode_config.gear_down)
            min_setting = min_setting + (min_setting % 4);
        else
            min_setting = min_setting + (min_setting % 2);
        if (min_setting < MIN_WR)
            min_setting = MIN_WR;
        else if (min_setting > MAX_WR)
            min_setting = MAX_WR;
        return min_setting;
    endfunction
    
    function UTYPE_delay_write_crc_dm GettWR_CRC_DMSpeed(input UTYPE_DutModeConfig dut_mode_config, input UTYPE_TS ts);
        UTYPE_delay_write_crc_dm tWR_CRC_DM;
        
        tWR_CRC_DM = DELAY_WRITE_5;
        case (ts)
            TS_1875,
            TS_1500,
            TS_1250 : begin
                tWR_CRC_DM = DELAY_WRITE_4;
            end 
        endcase
        return tWR_CRC_DM;
    endfunction
    
    
    function bit ppr_available(input UTYPE_dutconfig dut_config);
        return dut_config.ppr_feature;
    endfunction
        
endpackage
