`include "arch_defines.v"
`include "StateTable.sv"
module ddr4 (
    rst_n,
    ck,
    ck_n,
    cke,
    cs_n,
    ras_n,
    cas_n,
    we_n,
    c,
    ba,
    addr,
    dm_tdqs,
    dq,
    dqs,
    dqs_n,
    odt,
    // new for ddr4
    act,
    alert_n,
    parity,
    ten,
    bg
    
);
    parameter pC_BITS    = 3;
    parameter pBA_BITS   = 2;
    parameter pDM_BITS   = CONFIGURED_DM_BITS;
    parameter pADDR_BITS = 14;
    parameter pDQ_BITS   = CONFIGURED_DQ_BITS;
    parameter pDQS_BITS  = CONFIGURED_DQS_BITS;
    parameter pBG_BITS   = `DWC_PHY_BG_WIDTH;
    parameter pCHIP_NO  = 0;

    
    import arch_package::*;
    import proj_package::*;
    StateTable _state();
    `include "timing_tasks.sv"
    DDR4_if iDDR4();

    reg clk_val, clk_enb;
    bit[159:0] func_str;
    UTYPE_dutconfig _dut_config;
    DDR4_cmd active_cmd;
    UTYPE_TimingParameters timing;
    wire model_enable;
    reg model_enable_val;
    wire odt_wire;
    UTYPE_cmdtype driving_cmd;

    // Component instantiation
    ddr4_model golden_model(.model_enable(model_enable),
                            .iDDR4(iDDR4));

    // Declare Ports
    input   rst_n;
    input   ck;
    input   ck_n;
    input   cke;
    input   cs_n;
    input   ras_n;
    input   cas_n;
    input   we_n;
    input   [pC_BITS-1:0] c;
    input   [pBA_BITS-1:0] ba;
    input   [pADDR_BITS-1:0] addr;
    inout   [pDM_BITS-1:0]   dm_tdqs;
    inout   [pDQ_BITS-1:0]   dq;
    inout   [pDQS_BITS-1:0]  dqs;
    inout   [pDQS_BITS-1:0]  dqs_n;
    input   odt;

    input  act;
    output alert_n;
    input  parity;
    input  ten;
    input  [pBG_BITS-1:0] bg;


    // input
     assign iDDR4.RESET_n = rst_n;
     assign iDDR4.CK[0]   = ck_n;
     assign iDDR4.CK[1]   = ck;

    assign iDDR4.CKE       = cke;
    assign iDDR4.CS_n      = cs_n;
    assign iDDR4.RAS_n_A16 = ras_n;

    assign iDDR4.CAS_n_A15 = cas_n;
    assign iDDR4.WE_n_A14  = we_n;    
    assign iDDR4.C[pC_BITS-1:0]       = c;
    assign iDDR4.BA[pBA_BITS-1:0]     = ba;
    assign iDDR4.ADDR[pADDR_BITS-1:0] = addr;
    assign iDDR4.ODT     = odt;
    
    assign iDDR4.ACT_n     = act;
    assign iDDR4.PARITY  = parity;
    assign iDDR4.TEN     = ten;
    assign iDDR4.BG[pBG_BITS-1:0]     = bg;

    // output
    assign alert_n       = iDDR4.ALERT_n;

    wire [pDQ_BITS-1:0] phy_oe;
   reg [`DWC_NO_OF_BYTES][`DWC_DX_NO_OF_DQS-1:0] dqs_phy_oe;
   
    // inout
    // Use tran primitive to connect b/w inout port of systemverilog interface and inout port.
    genvar dm_wdt;
    genvar dq_wdt;
    genvar dqs_wdt;
    reg [pDQ_BITS-1:0] dp_driver; // TEMP

    generate
        for (dm_wdt = 0 ; dm_wdt < pDM_BITS ; dm_wdt++) begin : DM_LOOP
           tran tran_dm (iDDR4.DM_n[dm_wdt] , dm_tdqs[dm_wdt]);
        end
    endgenerate
   

   generate
      for (dq_wdt = 0 ; dq_wdt < pDQ_BITS ; dq_wdt++) begin : DQ_LOOP
//         tran  U_tran_dq   (iDDR4.DQ [dq_wdt]  , dq   [dq_wdt]);
         // each byte_lane is (pCHIP_NO*pDQ_BITS/8) + (dq_wdt/8); 
         assign phy_oe[dq_wdt] = `PHY.dx[(pCHIP_NO*pDQ_BITS/8)+(dq_wdt/8)].dx_top.u_DWC_DDRPHYDATX8_top.dx[(pCHIP_NO*pDQ_BITS/8)+(dq_wdt/8)].u_DWC_DDRPHYDATX8_io.io_dx.cfg_dq[dq_wdt%8].pad_dq.ZE_internal;
         assign iDDR4.DQ [dq_wdt] =  phy_oe[dq_wdt]                ? dq [dq_wdt]      : 1'bz;
         assign dq [dq_wdt]       =  ~phy_oe[dq_wdt] ? iDDR4.DQ [dq_wdt]: 1'bz;
         always @(dq) dp_driver [dq_wdt] = $countdrivers(dq[dq_wdt]); //TEMP
      end
   endgenerate


   //`DWC_NO_OF_BYTES
   genvar                                         dqs_byte_no;
   genvar                                         dqs_oe_bits;
   generate
      for (dqs_byte_no = 0 ; dqs_byte_no < `DWC_NO_OF_BYTES; dqs_byte_no++) begin
         assign dqs_phy_oe[dqs_byte_no][`DWC_DX_NO_OF_DQS-1:0] = `PHY.dx[dqs_byte_no].dx_top.u_DWC_DDRPHYDATX8_top.dqs_oe[`DWC_DX_NO_OF_DQS-1:0];
      end
   endgenerate

    generate
        for (dqs_wdt = 0 ; dqs_wdt < pDQS_BITS ; dqs_wdt++) begin : DQS_LOOP
//             tran  U_tran_dqs   (iDDR4.DQS_t [dqs_wdt]  , dqs   [dqs_wdt]);
//             tran  U_tran_dqs_n (iDDR4.DQS_c [dqs_wdt]  , dqs_n [dqs_wdt]);
             assign iDDR4.DQS_c[dqs_wdt] =  |dqs_phy_oe[dqs_wdt+2*pCHIP_NO][`DWC_DX_NO_OF_DQS-1:0] ? dqs_n[dqs_wdt] : 1'bz;
             assign dqs_n[dqs_wdt]       =  |dqs_phy_oe[dqs_wdt+2*pCHIP_NO][`DWC_DX_NO_OF_DQS-1:0] ? 1'bz           : iDDR4.DQS_c[dqs_wdt];
             assign iDDR4.DQS_t[dqs_wdt] =  |dqs_phy_oe[dqs_wdt+2*pCHIP_NO][`DWC_DX_NO_OF_DQS-1:0] ? dqs[dqs_wdt] : 1'bz;
             assign dqs[dqs_wdt]         =  |dqs_phy_oe[dqs_wdt+2*pCHIP_NO][`DWC_DX_NO_OF_DQS-1:0] ? 1'bz         : iDDR4.DQS_t[dqs_wdt];
//             assign iDDR4.DQS_c[dqs_wdt] =  !golden_model.dqs_out_enb ? dqs_n[dqs_wdt] : 1'bz;
//             assign dqs_n[dqs_wdt]       =  !golden_model.dqs_out_enb ? 1'bz           : iDDR4.DQS_c[dqs_wdt];
//             assign iDDR4.DQS_t[dqs_wdt] =  !golden_model.dqs_out_enb ? dqs[dqs_wdt] : 1'bz;
//             assign dqs[dqs_wdt]         =  !golden_model.dqs_out_enb ? 1'bz         : iDDR4.DQS_t[dqs_wdt];
        end
    endgenerate


//    assign iDDR4.DM   = dm_tdqs ;
//    assign iDDR4.DQ   = dq      ;
//    assign iDDR4.DQS  = dqs     ;
//    assign iDDR4.DQS_ = dqs_n   ;

//    assign dm_tdqs    = iDDR4.DM  ; 
//    assign dq         = iDDR4.DQ  ;
//    assign dqs        = iDDR4.DQS ;
//    assign dqs_n      = iDDR4.DQS_;

    function int GetWidth();
        return _dut_config.by_mode;
    endfunction

    function [MAX_DQ_BITS*MAX_BURST_LEN-1:0] BurstOrderData(input [MAX_DQ_BITS*MAX_BURST_LEN-1:0] sequential_data_start_0,
                                                            input [MAX_COL_ADDR_BITS-1:0] col, input int burst_length, input UTYPE_bt burst_type);
        reg [MAX_COL_ADDR_BITS-1:0] col_out;
        reg [MAX_COL_ADDR_BITS-1:0] col_out0;
        reg [MAX_COL_ADDR_BITS-1:0] col_out1;
        
        BurstOrderData = sequential_data_start_0;
        for (int i=0;i<burst_length/2;i++) begin
            col_out = ((col % burst_length) ^ 2*i) & (burst_length-1); // wrapped and masked
            // even bursts are the same w/ SEQ or INT
            if(col_out % 2 == 0) begin
                col_out0 = col_out;
                col_out1 = col_out + 1;
            // odd bursts vary between SEQ and INT
            end else begin
                col_out0 = col_out;
                if(burst_type == SEQ) begin
                    col_out1 = col_out;
                    col_out1[1:0] = col_out + 1;
                end else begin
                    col_out1 = col_out - 1;
                end
            end
            for (int j=0; j<MAX_DQ_BITS; j++) begin
                BurstOrderData[j+2*(i)*MAX_DQ_BITS] = sequential_data_start_0[j+(col_out0*MAX_DQ_BITS)];
                BurstOrderData[j+(2*(i)+1)*MAX_DQ_BITS] = sequential_data_start_0[j+(col_out1*MAX_DQ_BITS)];
            end
        end 
        return BurstOrderData;
    endfunction

    initial $timeformat (-12, 1, " ps", 1);


endmodule
    
