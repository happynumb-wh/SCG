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
    `ifdef CSNCIDMUX
      parameter pC_BITS    = 1;
    `else
      parameter pC_BITS    = `DWC_CID_WIDTH;
    `endif
    parameter pBA_BITS   = `DWC_PHY_BA_WIDTH;
    parameter pDM_BITS   = CONFIGURED_DM_BITS;
    parameter pADDR_BITS = 14;
    parameter pDQ_BITS   = CONFIGURED_DQ_BITS;
    parameter pDQS_BITS  = CONFIGURED_DQS_BITS;
    parameter pBG_BITS   = `DWC_PHY_BG_WIDTH;
    parameter pCHIP_NO  = 0;

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
    
    import arch_package::*;
    import proj_package::*;

    `include "timing_tasks.sv"

  `ifdef LPDDR4MPHY
    DDR4_if 
	#(.CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS))
	iDDR4(
                  .DM_n(dm_tdqs),
                  .DQ(dq),
                  .DQS_t(dqs),
                  .DQS_c(dqs_n)
                  );
  `else
    DDR4_if iDDR4(
                  .DM_n(dm_tdqs),
                  .DQ(dq),
                  .DQS_t(dqs),
                  .DQS_c(dqs_n)
                  );
  `endif

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
  `ifdef LPDDR4MPHY
    ddr4_model 
	#(.CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS),
	  .CONFIGURED_DENSITY(CONFIGURED_DENSITY))
	golden_model(.model_enable(model_enable),
                            .iDDR4(iDDR4));
  `else
   ddr4_model golden_model(.model_enable(model_enable),
                            .iDDR4(iDDR4));
  `endif




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

   //Start of DEBUG signals
   reg   cke_d;
   always @(posedge ck) cke_d <= cke;
   reg   dbg_MRS[7];
   reg   dbg_REF;
   reg   dbg_SRE;
   reg   dbg_SRX;
   reg   dbg_PRE[2**pBG_BITS][2**pBA_BITS];
   reg   dbg_PREA;
   reg   dbg_ACT;
   reg   dbg_WR;
   reg   dbg_WRA;
   reg   dbg_RD;
   reg   dbg_RDA;
   reg   dbg_DES;
   reg   dbg_ZQCL;
   reg   dbg_ZQCS;

   bit   dbg_PDA_mode                = 0;
   bit   dbg_vref_dq_train_en        = 0;
   bit   dbg_write_levelization_mode = 0;
   bit   dbg_write_CRC               = 0;
   
   //to make it easy to see commands on the waveform viewer (see table 16 of JEDEC spec)
   generate
      genvar dbg_mr_num;
      for (dbg_mr_num = 0; dbg_mr_num < 7; dbg_mr_num++) begin: mr_num
         always_comb dbg_MRS[dbg_mr_num]  =  cke_d &  cke & ~cs_n &  act & ~ras_n & ~cas_n & ~we_n & (dbg_mr_num == {bg[0], ba[1:0]});
      end
   endgenerate
   always_comb  dbg_REF  =  cke_d &  cke & ~cs_n &  act & ~ras_n & ~cas_n &  we_n;
   always_comb  dbg_SRE  =  cke_d & ~cke & ~cs_n &  act & ~ras_n & ~cas_n &  we_n;
   always_comb  dbg_SRX  = ~cke_d &  cke & ~cs_n &  act &  ras_n &  cas_n &  we_n;
   generate
      genvar dbg_bg;
      genvar dbg_ba;
      for (dbg_bg=0; dbg_bg<2**pBG_BITS; dbg_bg++) begin
         for (dbg_ba=0; dbg_ba<2**pBA_BITS; dbg_ba++) begin
            always_comb dbg_PRE[dbg_bg][dbg_ba] = cke_d &&  cke && !cs_n &&  act && !ras_n && cas_n && !we_n && (bg == dbg_bg) && (ba == dbg_ba) && !addr[10];
         end
      end
   endgenerate
   always_comb  dbg_PREA =  cke_d &  cke & ~cs_n &  act & ~ras_n &  cas_n & ~we_n  & addr[10];
   always_comb  dbg_ACT  =  cke_d &  cke & ~cs_n & ~act;
   always_comb  dbg_WR   =  cke_d &  cke & ~cs_n &  act &  ras_n & ~cas_n & ~we_n & ~addr[10];
   always_comb  dbg_WRA  =  cke_d &  cke & ~cs_n &  act &  ras_n & ~cas_n & ~we_n &  addr[10];
   always_comb  dbg_RD   =  cke_d &  cke & ~cs_n &  act &  ras_n & ~cas_n &  we_n & ~addr[10];
   always_comb  dbg_RDA  =  cke_d &  cke & ~cs_n &  act &  ras_n & ~cas_n &  we_n &  addr[10];
   always_comb  dbg_DES  =  cke_d &  cke &  cs_n;
   always_comb  dbg_ZQCL =  cke_d &  cke & ~cs_n &  act &  ras_n &  cas_n & ~we_n &  addr[10];
   always_comb  dbg_ZQCS =  cke_d &  cke & ~cs_n &  act &  ras_n &  cas_n & ~we_n & ~addr[10];

   always @(negedge dbg_MRS[3]) dbg_PDA_mode                = addr[4];
   always @(negedge dbg_MRS[6]) dbg_vref_dq_train_en        = addr[7];
   always @(negedge dbg_MRS[1]) dbg_write_levelization_mode = addr[7];
   always @(negedge dbg_MRS[2]) dbg_write_CRC               = addr[12];
   //End of DEBUG signals


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
    
