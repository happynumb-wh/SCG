// Module:                      dfi_vip
// SOMA file:                   /remote/ca09h2/changm/denali/dfi_vip.soma
// Initial contents file:       
// Simulation control flags:    

// PLEASE do not remove, modify or comment out the timescale declaration below.
// Doing so will cause the scheduling of the pins in Denali models to be
// inaccurate and cause simulation problems and possible undetected errors or
// erroneous errors.  It must remain `timescale 10fs/10fs for accurate simulation.   
`timescale 10fs/10fs

module dfi_vip(
    clk,
    reset_n,
    dfi_address,
    dfi_bank,
    dfi_cas_n,
    dfi_cke,
    dfi_cs_n,
    dfi_odt,
    dfi_ras_n,
    dfi_we_n,
    dfi_reset_n,
    dfi_wrdata_en,
    dfi_wrdata,
    dfi_wrdata_mask,
    dfi_rddata_en,
    dfi_rddata,
    dfi_rddata_valid,
    dfi_ctrlupd_ack,
    dfi_ctrlupd_req,
    dfi_phyupd_ack,
    dfi_phyupd_req,
    dfi_phyupd_type,
    dfi_dram_clk_disable,
    dfi_init_complete,
    dfi_rdlvl_en,
    dfi_rdlvl_gate_en,
    dfi_rdlvl_req,
    dfi_rdlvl_gate_req,
    dfi_rdlvl_load,
    dfi_rdlvl_resp,
    dfi_rdlvl_cs_n,
    dfi_rdlvl_edge,
    dfi_rdlvl_delay_0,
    dfi_rdlvl_delay_1,
    dfi_rdlvl_delay_2,
    dfi_rdlvl_delay_3,
    dfi_rdlvl_gate_delay_0,
    dfi_rdlvl_gate_delay_1,
    dfi_rdlvl_gate_delay_2,
    dfi_rdlvl_gate_delay_3,
    dfi_rdlvl_mode,
    dfi_rdlvl_gate_mode,
    dfi_wrlvl_en,
    dfi_wrlvl_req,
    dfi_wrlvl_load,
    dfi_wrlvl_resp,
    dfi_wrlvl_cs_n,
    dfi_wrlvl_delay_0,
    dfi_wrlvl_delay_1,
    dfi_wrlvl_delay_2,
    dfi_wrlvl_delay_3,
    dfi_wrlvl_mode,
    dfi_wrlvl_strobe
);
    parameter interface_soma = "/remote/ca09h2/changm/denali/dfi_vip.soma";
    parameter init_file   = "";
    parameter sim_control = "";
    input clk;
    input reset_n;
    input [15:0] dfi_address;
    input [2:0] dfi_bank;
    input dfi_cas_n;
    input [3:0] dfi_cke;
    input [3:0] dfi_cs_n;
    input [3:0] dfi_odt;
    input dfi_ras_n;
    input dfi_we_n;
    input [3:0] dfi_reset_n;
    input [3:0] dfi_wrdata_en;
    input [63:0] dfi_wrdata;
    input [7:0] dfi_wrdata_mask;
    input [3:0] dfi_rddata_en;
    input [63:0] dfi_rddata;
    input dfi_rddata_valid;
    input dfi_ctrlupd_ack;
    input dfi_ctrlupd_req;
    input dfi_phyupd_ack;
    input dfi_phyupd_req;
    input [1:0] dfi_phyupd_type;
    input [3:0] dfi_dram_clk_disable;
    input dfi_init_complete;
    input [7:0] dfi_rdlvl_en;
    input [7:0] dfi_rdlvl_gate_en;
    input [7:0] dfi_rdlvl_req;
    input [7:0] dfi_rdlvl_gate_req;
    input [7:0] dfi_rdlvl_load;
    input [63:0] dfi_rdlvl_resp;
    input [3:0] dfi_rdlvl_cs_n;
    input [7:0] dfi_rdlvl_edge;
    input [3:0] dfi_rdlvl_delay_0;
    input [3:0] dfi_rdlvl_delay_1;
    input [3:0] dfi_rdlvl_delay_2;
    input [3:0] dfi_rdlvl_delay_3;
    input [3:0] dfi_rdlvl_gate_delay_0;
    input [3:0] dfi_rdlvl_gate_delay_1;
    input [3:0] dfi_rdlvl_gate_delay_2;
    input [3:0] dfi_rdlvl_gate_delay_3;
    input [1:0] dfi_rdlvl_mode;
    input [1:0] dfi_rdlvl_gate_mode;
    input [7:0] dfi_wrlvl_en;
    input [7:0] dfi_wrlvl_req;
    input [7:0] dfi_wrlvl_load;
    input [63:0] dfi_wrlvl_resp;
    input [3:0] dfi_wrlvl_cs_n;
    input [3:0] dfi_wrlvl_delay_0;
    input [3:0] dfi_wrlvl_delay_1;
    input [3:0] dfi_wrlvl_delay_2;
    input [3:0] dfi_wrlvl_delay_3;
    input [1:0] dfi_wrlvl_mode;
    input [7:0] dfi_wrlvl_strobe;
initial
    $dfi_access(clk,reset_n,dfi_address,dfi_bank,dfi_cas_n,dfi_cke,dfi_cs_n,dfi_odt,dfi_ras_n,dfi_we_n,dfi_reset_n,dfi_wrdata_en,dfi_wrdata,dfi_wrdata_mask,dfi_rddata_en,dfi_rddata,dfi_rddata_valid,dfi_ctrlupd_ack,dfi_ctrlupd_req,dfi_phyupd_ack,dfi_phyupd_req,dfi_phyupd_type,dfi_dram_clk_disable,dfi_init_complete,dfi_rdlvl_en,dfi_rdlvl_gate_en,dfi_rdlvl_req,dfi_rdlvl_gate_req,dfi_rdlvl_load,dfi_rdlvl_resp,dfi_rdlvl_cs_n,dfi_rdlvl_edge,dfi_rdlvl_delay_0,dfi_rdlvl_delay_1,dfi_rdlvl_delay_2,dfi_rdlvl_delay_3,dfi_rdlvl_gate_delay_0,dfi_rdlvl_gate_delay_1,dfi_rdlvl_gate_delay_2,dfi_rdlvl_gate_delay_3,dfi_rdlvl_mode,dfi_rdlvl_gate_mode,dfi_wrlvl_en,dfi_wrlvl_req,dfi_wrlvl_load,dfi_wrlvl_resp,dfi_wrlvl_cs_n,dfi_wrlvl_delay_0,dfi_wrlvl_delay_1,dfi_wrlvl_delay_2,dfi_wrlvl_delay_3,dfi_wrlvl_mode,dfi_wrlvl_strobe);
endmodule

