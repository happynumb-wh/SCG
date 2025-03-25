`ifndef MEMORY_ARRAY_DEFINE
`define MEMORY_ARRAY_DEFINE

package MemArray;
timeunit 1ps;
timeprecision 1ps;
import arch_package::*;

typedef struct packed unsigned {
    bit [MAX_RANK_BITS-1:0] rank;
    bit [MAX_BANK_GROUP_BITS-1:0] bank_group;
    bit [MAX_BANK_BITS-1:0] bank;
    bit [MAX_ROW_ADDR_BITS-1:0] row;
    bit [MAX_COL_ADDR_BITS-1:0] col;
    bit [MAX_DM_BITS-1:0] dm;
} memKey_type;
    
class MemorySection;
    byte rw;
    time written;
    time read;
    time accessed;
    logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data;
    function new(byte rw_, time written_, logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data_);
        rw = rw_; written = written_; data = data_; accessed = written_;
    endfunction
endclass

class MemoryArray;
    MemorySection _storage[memKey_type];
    string _parent;
    reg _unwritten_memory_default;
    bit _debug;
    bit _print_warnings;
    bit _print_verification_details;
    int _write_without_read;
    int _read_never_wrote;
    int _verified;
    int _decay_time_in_psec; // Anything negative is infinity
    function logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] Read(memKey_type storage_key);
        MemorySection memory_section;
        logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] return_data;
        return_data = {MAX_DQ_BITS/MAX_DM_BITS{_unwritten_memory_default}};
        if (_storage.exists(storage_key)) begin
            memory_section = _storage[storage_key];
            if ((_decay_time_in_psec > -1) && ($time - memory_section.accessed) > _decay_time_in_psec) begin
                if(_debug || _print_warnings) begin 
                    $display ("%0s:WARNING: Reading decayed address: C:%0h BG:%0h B:%0h R:%0h C:%0h dm:%0h (limit:%0dps actual:%0dps) @%0t", _parent, 
                        storage_key.rank, storage_key.bank_group, storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, 
                        _decay_time_in_psec, $time - memory_section.accessed, $time);
                end
                return 'x;
            end
            return_data = memory_section.data;
            memory_section.rw = "V";
            memory_section.accessed = $time;
            memory_section.read = $time;
            _storage[storage_key] = memory_section;
            if(_debug)
                $display ("%0s:Read C:%0h BG:%0h B:%0h R:%0h C:%0h dm:%0h (data:%0h) (written @%0t) @%0t", _parent, storage_key.rank, storage_key.bank_group,
                          storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, memory_section.data, memory_section.written, $time);
        end else begin
            _read_never_wrote = _read_never_wrote + 1;
            if(_debug || _print_warnings) begin 
                $display ("%0s:WARNING: Reading unwritten address: C:%0h BG:%0h B:%0h R:%0h C:%0h dm:%0h @%0t", _parent, 
                    storage_key.rank, storage_key.bank_group, storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, $time);
            end
        end
        return return_data;
    endfunction
    function time TimeWritten(memKey_type storage_key);
        if (_storage.exists(storage_key)) begin
            MemorySection memory_section;
            
            memory_section = _storage[storage_key];
            return memory_section.written;
        end
        return 0;
    endfunction
    function time TimeRead(memKey_type storage_key);
        if (_storage.exists(storage_key)) begin
            MemorySection memory_section;
            
            memory_section = _storage[storage_key];
            return memory_section.read;
        end
        return 0;
    endfunction
    function void Write(memKey_type storage_key, logic [MAX_DQ_BITS/MAX_DM_BITS-1:0] data);
        MemorySection memory_section;
        if (_storage.exists(storage_key)) begin
            memory_section = _storage[storage_key];
            if (memory_section.rw == "w") begin
                _write_without_read = _write_without_read + 1;
//                 if (_debug || _print_warnings) begin
//                     $display ("WARNING:%0s: Write w/o reading: bank:%0h row:%0h col:%0h dm:%0h @%0t (previous write @%0t)",
//                         _parent, storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, $time, memory_section.written);
//                 end
            end
        end
        memory_section = new("w", $time, data);
        _storage[storage_key] = memory_section;
        if (^data === 'x) begin
            if (_debug || _print_warnings) begin
                $display ("%0s:WARNING: Writing unknowns: C:%0h BG:%0h B:%0h R:%0h C:%0h dm:%0h data:%0h @%0t", _parent, 
                    storage_key.rank, storage_key.bank_group, storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, data, $time);
            end
        end
        if(_debug)
            $display ("%0s:Write C:%0h BG:%0h B:%0h R:%0h C:%0h dm:%0h data:%0h @%0t", _parent, 
                storage_key.rank, storage_key.bank_group, storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, data, $time);
    endfunction
    function void Clear();
        _storage.delete;
        _DefaultCounters();
        $display("%0s:Cleared MemoryArray @%0t", _parent, $time);
    endfunction
    function void Verify();
        memKey_type storage_key;
        MemorySection memory_section;
        int num_fails;
        num_fails = 0;
        if (_storage.num() > 0) begin
            if (_storage.first(storage_key)) begin
                do begin
                    memory_section = _storage[storage_key];
                    if (memory_section.rw == "w") begin
                        num_fails = num_fails + 1;
                        if (_debug || _print_verification_details) begin
                            $display ("%0s:WARNING: Memory never read: C:%0h BG:%0h B:%0h R:%0h C:%0h dm:%0h Written @%0t", _parent, 
                                storage_key.rank, storage_key.bank_group, storage_key.bank, storage_key.row, storage_key.col, storage_key.dm, memory_section.written);
                        end
                    end else begin
                        _verified = _verified + 1;
                    end
                end while (_storage.next(storage_key));
            end
            $display("%0s Memory Verification: %0d sections written with %0d never read", _parent, _storage.num(), num_fails);
            $display("\tSections: Verified:%0d || Write w/o read:%0d || Read w/o write:%0d", _verified, _write_without_read, _read_never_wrote);
        end
    endfunction
    function void _DefaultCounters();
        _write_without_read = 0;
        _read_never_wrote = 0;
        _verified = 0;
    endfunction
    function void SetDecayTime(int decay_time_in_psec);
        _decay_time_in_psec = decay_time_in_psec;
    endfunction
    function int GetDecayTime();
        return _decay_time_in_psec;
    endfunction
    function void SetInternals(bit print_warnings = _print_warnings, bit debug = _debug);
        _print_warnings = print_warnings;
        _debug = debug;
    endfunction
    function void SetUnwrittenMemoryDefault(logic unwritten_memory_default);
        _unwritten_memory_default = unwritten_memory_default;
    endfunction
    function new(string parent, bit print_warnings, bit print_verification_details, 
                 bit debug, int decay_time_in_psec, logic unwritten_memory_default);
        _parent = parent;
        _debug = debug;
        _print_warnings = print_warnings;
        _print_verification_details = print_verification_details;
        _decay_time_in_psec = decay_time_in_psec;
        SetUnwrittenMemoryDefault(unwritten_memory_default);
        _DefaultCounters();
    endfunction
    function bit InitializeWithFile(string memory_file);
        integer fh;
        string error_str, line, comment, file_config;
        int err_number, line_number, values, rank, bg, ba, row, col, by_mode, bl, test_by_mode, test_bl;
        logic[MAX_DQ_BITS*MAX_BURST_LEN-1:0] wr_data, rd_data;
        
        fh = $fopen(memory_file,"r");
        if (0 == fh) begin
            err_number = $ferror(fh, error_str);
            $display("ERROR:Cannot open file '%0s'. Failed to initialize memory with a file.", memory_file);
            return 1;
        end else begin
            $display("Initializing memory from data in '%0s'.", memory_file);
        end
        
        line_number = 0;
        by_mode = 8;
        bl = 8;
        $display("\tReading data in x%0d and bl:%0d mode (Change with 'config <4,8,16> <4,8>' in this file).", by_mode, bl);
        while ($fgets(line, fh) > 0) begin
            line_number = line_number + 1;
            values = $sscanf(line, "%s\n", comment);
            if (("#" == comment[0]) || (0 == values)) begin
                continue;
            end
            values = $sscanf(line, "%s %d %d\n", file_config, test_by_mode, test_bl);
            if ("config" == file_config) begin
                case (values)
                    3: begin // Two numbers are used to define data width and bl.
                        case (test_by_mode)
                            4,8,16,32: begin
                                by_mode = test_by_mode;
                                $display("\t'%s' set write data width to x%0d.", memory_file, by_mode);
                            end
                            default: begin
                                $display("\tERROR: Failed to set write data to x%0d. Only <4,8,16> are valid.", test_by_mode);
                            end
                        endcase
                        case (test_bl)
                            4,8: begin
                                bl = test_bl;
                                $display("\t'%s' set write data burst length to %0d.", memory_file, bl);
                            end
                            default: begin
                                $display("\tERROR: Failed to write data burst length to %0d. Only <4,8> are valid.", test_bl);
                            end
                        endcase
                        continue;
                    end
                    default: begin
                        string no_nl;
                        
                        no_nl = line.substr(0, line.len() - 2);
                        $display("\tERROR: %0s:%0d '%0s'. Expecting 'config <4,8,16> <4,8>' to set file configuration", 
                                 memory_file, line_number, no_nl);
                        continue;
                    end
                endcase
            end
            values = $sscanf(line, "%h %h %h %h %h %h\n", rank, bg, ba, row, col, wr_data);
            case (values)
                5: begin
                    rank = '0;
                    values = $sscanf(line, "%h %h %h %h %h\n", bg, ba, row, col, wr_data);
                end
                6: begin
                end
                default: begin
                    string no_nl;
                    
                    no_nl = line.substr(0, line.len() - 2);
                    $display("\tERROR: %0s:%0d '%0s'. Expecting 5 or 6 hex values ([rank] bg ba row col data) or 'config <width> <bl>'.", 
                             memory_file, line_number, no_nl);
                    continue;
                end
            endcase
            $display("C:%0h BG:%0h BA:%0h R:%0h C:%0h D:%0h", rank, bg, ba, row, col, wr_data);
            BurstWrite(.rank(rank), .bg(bg), .ba(ba), .row(row), .col(col), .data(wr_data), .bl(bl), .by_mode(by_mode));
            rd_data = BurstRead(.rank(rank), .bg(bg), .ba(ba), .row(row), .col(col), .bl(bl), .by_mode(by_mode));
        end
        return 1;
    endfunction
    function void BurstWrite(logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg, logic[MAX_BANK_BITS-1:0] ba, 
                             logic[MAX_ROW_ADDR_BITS-1:0] row, logic[MAX_COL_ADDR_BITS-1:0] col,
                             logic[32*8-1:0] data, int bl, int by_mode);
        memKey_type mem_key;
        bit saved_debug;
        
        mem_key.rank = rank;
        mem_key.bank_group = bg;
        mem_key.bank = ba;
        mem_key.row = row;
        saved_debug = _debug;
        _debug = 1;
        $display("Writing x%0d bl:%0d data:%0h", by_mode, bl, data);
        for (int i=0;i<bl;i++) begin
            mem_key.col = ((col & (-1*bl)) | i);
            if (by_mode >= 32) begin
                mem_key.dm = 3;
                Write(mem_key, data >> (i*by_mode)+24);
                mem_key.dm = 2;
                Write(mem_key, data >> (i*by_mode)+16);
            end
            if (by_mode >= 16) begin
                mem_key.dm = 1;
                Write(mem_key, data >> (i*by_mode)+8);
            end
            mem_key.dm = 0;
            Write(mem_key, data >> i*by_mode);
        end
        _debug = saved_debug;
    endfunction
    function logic[32*8-1:0] BurstRead(logic[MAX_RANK_BITS-1:0] rank, logic[MAX_BANK_GROUP_BITS-1:0] bg, 
                                       logic[MAX_BANK_BITS-1:0] ba, logic[MAX_ROW_ADDR_BITS-1:0] row, 
                                       logic[MAX_COL_ADDR_BITS-1:0] col, int bl, int by_mode);
        memKey_type mem_key;
        logic[32*8-1:0] rd_data;
        bit saved_debug;
        
        mem_key.rank = rank;
        mem_key.bank_group = bg;
        mem_key.bank = ba;
        mem_key.row = row;
        rd_data = {8{_unwritten_memory_default}};
        saved_debug = _debug;
        _debug = 1;;
        for (int i=0;i<bl;i++) begin
            logic [7:0] data0, data1, data2, data3;
            mem_key.col = ((col & (-1*bl)) | i);
            if (by_mode >= 32) begin
                mem_key.dm = 3;
                data3 = Read(mem_key);
                mem_key.dm = 2;
                data2 = Read(mem_key);
            end
            if (by_mode >= 16) begin
                mem_key.dm = 1;
                data1 = Read(mem_key);
            end
            mem_key.dm = 0;
            data0 = Read(mem_key);
            rd_data |= ({data3, data2, data1, data0} << i*by_mode);
        end
        _debug = saved_debug;
        return rd_data;
    endfunction
endclass

endpackage

`endif
