`timescale 1ns/1ps
//`include "dictionary.v"
module ddr_svt_dut_sv_wrapper (svt_axi_if axi_if,svt_apb_if apb_dut_master_if, axi_reset_if axi_dut_reset_if);
//==================================
// widths of AXI interface signals
//==================================
localparam AXI_ADDR_WIDTH = 36;
localparam AXI_DATA_WIDTH = 256;
localparam AXI_ID_WIDTH = 16;
localparam AXI_LEN_WIDTH = 8;
localparam AXI_SIZE_WIDTH = 3;
localparam AXI_BURST_WIDTH = 2;
localparam AXI_CACHE_WIDTH = 4;
localparam AXI_PROT_WIDTH = 3;
localparam AXI_QOS_WIDTH = 4;
localparam AXI_REGION_WIDTH = 4;
localparam AXI_USER_WIDTH = 8;
localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH/8;
localparam AXI_RESP_WIDTH = 2;

reg system_reset;

logic init_start;

	wire [1:0] ddr_ck_t;
	wire [1:0] ddr_ck_c;
	wire [1:0] ddr_cke;
	wire [1:0] ddr_cs_n;
	wire [1:0] ddr_odt;
	wire ddr_act_n;
	wire [7:0] ddr_dm_n;
	wire [1:0] ddr_bg;
	wire [1:0] ddr_ba;
	wire [17:0] ddr_a;
	wire ddr_reset_n;
	wire [63:0] ddr_dq;
	wire [7:0] ddr_dqs_t;
	wire [7:0] ddr_dqs_c;
	wire ddr_par;
	wire ddr_alert_n;
	wire ddr_ten;
    wire local_awready;
    wire local_arready;
    wire local_rvalid;
    wire local_rlast;
    wire [`SVT_AXI_MAX_DATA_WIDTH-1:0] local_rdata;
    wire [`SVT_AXI_RESP_WIDTH-1:0] local_rresp;
    wire [`SVT_AXI_MAX_ID_WIDTH-1:0] local_rid;
    wire local_wready;
    wire local_bvalid;
    wire [`SVT_AXI_RESP_WIDTH-1:0] local_bresp;
    wire [`SVT_AXI_MAX_ID_WIDTH-1:0] local_bid;
	logic core_ddrc_core_clk;
	logic core_ddrc_rstn;
	logic aresetn_0;
	logic aclk_0;
	logic csysreq_0;
	logic csysack_0;
	logic cactive_0;
	logic csysreq_1;
	logic csysack_1;
	logic cactive_1;
	logic csysreq_2;
	logic csysack_2;
	logic cactive_2;
	logic csysreq_3;
	logic csysack_3;
	logic cactive_3;
	logic [AXI_ID_WIDTH-1:0] awid_0;
	logic [AXI_ADDR_WIDTH-1:0] awaddr_0;
	logic [7:0] awlen_0;
	logic [2:0] awsize_0;
	logic [1:0] awburst_0;
	logic [0:0] awlock_0;
	logic [3:0] awcache_0;
	logic [2:0] awprot_0;
	logic awuser_0;
	logic awvalid_0;
	logic awready_0;
	logic [3:0] awqos_0;
	logic awurgent_0;
	logic awpoison_0;
	logic awpoison_intr_0;
	logic awautopre_0;
	logic [3:0] awregion_0;
	logic [2:0] waq_wcount_0;
	logic waq_pop_0;
	logic waq_push_0;
	logic waq_split_0;
	logic [255:0] wdata_0;
	logic [31:0] wstrb_0;
	logic wlast_0;
	logic wvalid_0;
	logic wready_0;
	logic wuser_0;
	logic [AXI_ID_WIDTH-1:0] bid_0;
	logic [1:0] bresp_0;
	logic buser_0;
	logic bvalid_0;
	logic bready_0;
	logic [AXI_ID_WIDTH-1:0] arid_0;
	logic [AXI_ADDR_WIDTH-1:0] araddr_0;
	logic [7:0] arlen_0;
	logic [2:0] arsize_0;
	logic [1:0] arburst_0;
	logic [0:0] arlock_0;
	logic [3:0] arcache_0;
	logic [2:0] arprot_0;
	logic aruser_0;
	logic arvalid_0;
	logic arready_0;
	logic [3:0] arqos_0;
	logic arpoison_0;
	logic arpoison_intr_0;
	logic arautopre_0;
	logic [3:0] arregion_0;
	logic arurgent_0;
	logic [2:0] raq_wcount_0;
	logic raq_pop_0;
	logic raq_push_0;
	logic raq_split_0;
	logic [AXI_ID_WIDTH-1:0] rid_0;
	logic [255:0] rdata_0;
	logic [1:0] rresp_0;
	logic rlast_0;
	logic rvalid_0;
	logic rready_0;
	
	logic [255:0] hif_mrr_data;
	logic hif_mrr_data_valid;
	logic csysreq_ddrc;
	logic csysack_ddrc;
	logic cactive_ddrc;
	logic [1:0] stat_ddrc_reg_selfref_type;
	logic [6:0] lpr_credit_cnt;
	logic [6:0] hpr_credit_cnt;
	logic [6:0] wr_credit_cnt;
	logic mc_scanmode;
	logic mc_scan_resetn;
	logic [1:0] pa_rmask;
	logic [0:0] pa_wmask;
	logic bist_mode;
	logic bist_mux;
	logic bist_start;
	logic bist_complete;
	logic bist_error;
	logic bscan_TDI;
	logic bscan_TDO;
	logic bscan_clockDR;
	logic bscan_mode;
	logic bscan_shiftDR;
	logic bscan_updateDR;
	logic ddr_plllock;
	logic phy_scanclk;
	logic phy_scanrstn;
	logic phy_scanen;
	logic phy_scanmode;
	logic [164:0] phy_scanin;
	logic [164:0] phy_scanout;
	logic pclk;
	logic presetn;
	logic [31:0] paddr;
	logic [31:0] pwdata;
	logic pwrite;
    logic [2:0] psel;
	logic [1:0] psel_mc;
	logic [1:0] psel_phy;
	logic [1:0] psel_baiyang;
	logic penable;
	logic [2:0] pready;
	logic [1:0] pready_mc;
	logic [1:0] pready_phy;
	logic [1:0] pready_baiyang;
    logic [31:0] prdata;
	logic [31:0] prdata_mc;
	logic [31:0] prdata_phy;
	logic [31:0] prdata_baiyang;
	logic pslverr_mc;
	logic pslverr_phy;
	logic pslverr_baiyang;
	logic bist_dfi_init_start;
	logic dfi_init_complete;
	logic test1a_rrb_0;
	logic test1b_rrb_0;
	logic test1a_port1;
	logic test1b_port1;
	logic test1a_port2;
	logic test1b_port2;
	logic test1a_port3;
	logic test1b_port3;
	logic [3:0] rma_rrb_0;
	logic [3:0] rmb_rrb_0;
	logic [3:0] rma_port1;
	logic [3:0] rmb_port1;
	logic [3:0] rma_port2;
	logic [3:0] rmb_port2;
	logic [3:0] rma_port3;
	logic [3:0] rmb_port3;
	logic rmea_rrb_0;
	logic rmeb_rrb_0;
	logic rmea_port1;
	logic rmeb_port1;
	logic rmea_port2;
	logic rmeb_port2;
	logic rmea_port3;
	logic rmeb_port3;
	logic test1a_wdata;
	logic test1b_wdata;
	logic rma_wdata;
	logic rmb_wdata;
	logic rmea_wdata;
	logic rmeb_wdata;
	logic init_rstn;
ddr_wrapper i_ddr_wrapper (
	.ddr_ck_t                       (ddr_ck_t                                                 ),
	.ddr_ck_c                       (ddr_ck_c                                                 ),
	.ddr_cke                        (ddr_cke                                                  ),
	.ddr_cs_n                       (ddr_cs_n                                                 ),
	.ddr_odt                        (ddr_odt                                                  ),
	.ddr_act_n                      (ddr_act_n                                                ),
	.ddr_dm_n                       (ddr_dm_n                                                 ),
	.ddr_bg                         (ddr_bg                                                   ),
	.ddr_ba                         (ddr_ba                                                   ),
	.ddr_a                          (ddr_a                                                    ),
	.ddr_reset_n                    (ddr_reset_n                                              ),
	.ddr_dq                         (ddr_dq                                                   ),
	.ddr_dqs_t                      (ddr_dqs_t                                                ),
	.ddr_dqs_c                      (ddr_dqs_c                                                ),
	.ddr_par                        (ddr_par                                                  ),
	.ddr_alert_n                    (ddr_alert_n                                              ),
	.ddr_ten                        (ddr_ten                                                  ),
	.system_reset                   (system_reset                                             ),
	.core_ddrc_core_clk             (core_ddrc_core_clk                                       ),
	.core_ddrc_rstn                 (axi_reset_if.core_ddrc_rstn /*& init_rstn*/                  ),
	.aresetn_0                      (axi_if.master_if[0].aresetn /*& init_rstn */                 ),
	.aclk_0                         (axi_if.common_aclk                                       ),
	// .awid_0                         (axi_if.master_if[0].awid                                 ),
	// .awaddr_0                       (axi_if.master_if[0].awaddr                               ),
	// .awlen_0                        (axi_if.master_if[0].awlen                                ),
	// .awsize_0                       (axi_if.master_if[0].awsize                               ),
	// .awburst_0                      (axi_if.master_if[0].awburst                              ),
	// .awlock_0                       (axi_if.master_if[0].awlock                               ),
	// .awcache_0                      (axi_if.master_if[0].awcache                              ),
	// .awprot_0                       (axi_if.master_if[0].awprot                               ),
	// .awuser_0                       (8'b00000000                                              ),
	// .awvalid_0                      (axi_if.master_if[0].awvalid                              ),
	// .awready_0                      (axi_if.master_if[0].awready                              ),
	// .awqos_0                        (axi_if.master_if[0].awqos                                ),
	// .awregion_0                     (4'h0                                                     ),
	// .wdata_0                        (axi_if.master_if[0].wdata                                ),
	// .wstrb_0                        (axi_if.master_if[0].wstrb                                ),
	// .wlast_0                        (axi_if.master_if[0].wlast                                ),
	// .wvalid_0                       (axi_if.master_if[0].wvalid                               ),
	// .wready_0                       (axi_if.master_if[0].wready                               ),
	// .wuser_0                        (8'b00000000                                              ),
	// .bid_0                          (axi_if.master_if[0].bid                                  ),
	// .bresp_0                        (axi_if.master_if[0].bresp                                ),
	// .buser_0                        (axi_if.master_if[0].buser                                ),
	// .bvalid_0                       (axi_if.master_if[0].bvalid                               ),
	// .bready_0                       (axi_if.master_if[0].bready                               ),
	// .arid_0                         (axi_if.master_if[0].arid                                 ),
	// .araddr_0                       (axi_if.master_if[0].araddr                               ),
	// .arlen_0                        (axi_if.master_if[0].arlen                                ),
	// .arsize_0                       (axi_if.master_if[0].arsize                               ),
	// .arburst_0                      (axi_if.master_if[0].arburst                              ),
	// .arlock_0                       (axi_if.master_if[0].arlock                               ),
	// .arcache_0                      (axi_if.master_if[0].arcache                              ),
	// .arprot_0                       (axi_if.master_if[0].arprot                               ),
	// .aruser_0                       (8'b00000000                                              ),
	// .arvalid_0                      (axi_if.master_if[0].arvalid                              ),
	// .arready_0                      (axi_if.master_if[0].arready                              ),
	// .arqos_0                        (axi_if.master_if[0].awqos                                ),
	// .arregion_0                     (4'h0                                                     ),
	// .rid_0                          (axi_if.master_if[0].rid                                  ),
	// .rdata_0                        (axi_if.master_if[0].rdata                                ),
	// .rresp_0                        (axi_if.master_if[0].rresp                                ),
	// .ruser_0                        (axi_if.master_if[0].ruser                                ),
	// .rlast_0                        (axi_if.master_if[0].rlast                                ),
	// .rvalid_0                       (axi_if.master_if[0].rvalid                               ),
	// .rready_0                       (axi_if.master_if[0].rready                               ),
	.mc_scanmode                    (1'b0                                                     ),
	.mc_scan_resetn                 (1'b0                                                     ),
	.bist_mode                      (1'b0                                                     ),
	.bist_mux                       (1'b0                                                     ),
	.bist_start                     (1'b0                                                     ),
	.bist_complete                  (                                                         ),
	.bist_error                     (                                                         ),
	.bscan_TDI                      (1'b0                                                     ),
	.bscan_TDO                      (                                                         ),
	.bscan_clockDR                  (1'b0                                                     ),
	.bscan_mode                     (1'b0                                                     ),
	.bscan_shiftDR                  (1'b0                                                     ),
	.bscan_updateDR                 (1'b0                                                     ),
	.ddr_plllock                    (ddr_plllock                                              ),
	.phy_scanclk                    (pclk                                                     ),
	.phy_scanrstn                   (1'b1                                                     ),
	.phy_scanmode                   (1'b0                                                     ),
	.phy_scanen                     (1'b0                                                     ),
	.phy_scanin                     (165'h0                                                   ),
	.phy_scanout                    (                                                         ),
	.pclk                           (apb_dut_master_if.pclk                                   ),
	.presetn                        (apb_dut_master_if.presetn                                ),
	.paddr_mc                       (apb_dut_master_if.paddr[15:0]                            ),
	.paddr_phy                      (apb_dut_master_if.paddr[15:0]                            ),
	.paddr_baiyang                  (apb_dut_master_if.paddr[15:0]                            ),
	.pwdata_mc                      (apb_dut_master_if.pwdata                                 ),
	.pwdata_phy                     (apb_dut_master_if.pwdata                                 ),
	.pwdata_baiyang                 (apb_dut_master_if.pwdata                                 ),
	.pwrite_mc                      (apb_dut_master_if.pwrite                                 ),
	.pwrite_phy                     (apb_dut_master_if.pwrite                                 ),
	.pwrite_baiyang                 (apb_dut_master_if.pwrite                                 ),
	.psel_mc                        (psel[0]                                                  ),
	.psel_phy                       (psel[1]                                                  ),
	.psel_baiyang					(psel[2]												  ),
	.penable_mc                     (apb_dut_master_if.penable                                ),
	.penable_phy                    (apb_dut_master_if.penable                                ),
	.penable_baiyang				(apb_dut_master_if.penable								  ),
	.pready_mc                      (1'b0             	                                      ),
	.pready_phy                     (pready[1]                                                ),
	.pready_baiyang					(pready[2]												  ),
	.prdata_mc                      (prdata_mc                                                ),
	.prdata_phy                     (prdata_phy                                               ),
	.prdata_baiyang					(prdata_baiyang										  	  ),
	.pslverr_mc                     (pslverr_mc                                               ),
	// .pslverr_phy                    (pslverr_phy                                              ),
	.pslverr_baiyang				(pslverr_baiyang										  ),
	.bist_dfi_init_start            (bist_dfi_init_start                                      ),
	.dfi_init_complete              (dfi_init_complete                                        ),
	.test1a_rrb_0                   (1'b0                                                     ),
	.test1b_rrb_0                   (1'b0                                                     ),
	.rma_rrb_0                      (4'h3                                                     ),
	.rmb_rrb_0                      (4'h0                                                     ),
	.rmea_rrb_0                     (1'b0                                                     ),
	.rmeb_rrb_0                     (1'b0                                                     ),
	.test1a_wdata                   (1'b0                                                     ),
	.test1b_wdata                   (1'b0                                                     ),
	.rma_wdata                      (4'h3                                                     ),
	.rmb_wdata                      (4'h3                                                     ),
	.rmea_wdata                     (1'b0                                                     ),
	.rmeb_wdata                     (1'b0                                                     ),
	.dft_mode						(1'b0                                                     ),
    .dft_lgc_rstn					(1'b1                                                     ),
    .scan_mode						(1'b0                                                     ),
    .dft_glb_gt_se                  (1'b0 													  ),
    // .bufferen_core                  (1'b1                                                     )
    .phy_bist_mode                  (1'b0                                                     )
);
assign pready[0]	=	1'b0	;//sys MC
assign psel[0] = (apb_dut_master_if.psel && (apb_dut_master_if.paddr[31:16] == 16'h3106));
assign psel[1] = (apb_dut_master_if.psel && (apb_dut_master_if.paddr[31:16] == 16'h3107));; 
assign psel[2] = (apb_dut_master_if.psel && (apb_dut_master_if.paddr[31:16] == 16'h3108));  
assign prdata = psel[0] ? prdata_mc : psel[1] ? prdata_phy : prdata_baiyang;
assign apb_dut_master_if.slave_if[0].pready = |pready;
assign apb_dut_master_if.slave_if[0].prdata = {dfi_init_complete, 3'h0, prdata[27:0]};
assign pslverr = /**/ /*| pslverr_phy*/  pslverr_baiyang;//pslverr_mc
assign apb_dut_master_if.slave_if[0].pslverr = pslverr;
//assign apb_dut_master_if.slave_if[0].pready = |(pready_mc | pready_phy);
//assign apb_dut_master_if.slave_if[0].prdata = {dfi_init_complete, 3'h0, apb_dut_master_if.paddr[28] ? prdata_mc[27:0] : prdata_phy[27:0]};

/*always_ff @(posedge apb_dut_master_if.pclk) begin
	if(~apb_dut_master_if.presetn) begin
		init_rstn <= 1'b0;
	end else if ((apb_dut_master_if.paddr[15:0] == 16'h0ff4) && psel[0]) begin
		init_rstn <= 1'b1;
	end
end*/

genvar i;
generate for (i = 0; i < 8; i = i + 1) begin :rank0

ddr4_model_top r0_ddr4_model_top (
	.ddr_dm    (ddr_dm_n[i]              ),
	.ddr_dq    (ddr_dq[i * 8 + 7 : i * 8]),
	.ddr_dqs   (ddr_dqs_t[i]             ),
	.ddr_dqsb  (ddr_dqs_c[i]             ),
	.ddr_alertn(                         ),
	.ddr_ck    (ddr_ck_t[0]              ),
	.ddr_ckb   (ddr_ck_c[0]              ),
	.ddr_actn  (ddr_act_n                ),
	.ddr_parity(                         ),
	.ddr_rstn  (ddr_reset_n              ),
	.ddr_ten   (                         ),
	.ddr_csb   (ddr_cs_n[0]              ),
	.ddr_cke   (ddr_cke[0]               ),
	.ddr_odt   (ddr_odt[0]               ),
	.ddr_bg    (ddr_bg                   ),
	.ddr_ba    (ddr_ba                   ),
	.ddr_addr  (ddr_a                    )
);
end
endgenerate


 initial begin
    $fsdbAutoSwitchDumpfile(200,"test.fsdb",100);
    $fsdbDumpfile("test.fsdb");
    $fsdbDumpvars(0, test_top, "+mda");
    $fsdbDumpflush();
 end

  initial begin
    system_reset = 1 ;
    #400 ;
    system_reset = 0 ;
  end

initial begin
	//$fsdbDumpfile("test.fsdb");
	//$fsdbDumpvars();

    presetn = 1'b0;
    #100 presetn = 1'b1;
end

initial begin
	pclk = 1'b0;
	forever begin
		# 2.5 pclk = ~pclk;
	end
end

initial begin
	aclk_0 = 1'b0;
	forever begin
		# 1.67 aclk_0 = ~aclk_0;
	end
end

initial begin
	core_ddrc_core_clk = 1'b0;
	forever begin
		# 0.833 core_ddrc_core_clk = ~core_ddrc_core_clk;
	end
end

`ifdef TEST_TRACE

function void memory_write(int row, int col , int ba, int bg, logic [511:0] data);
		int k;
		int offset;
		logic [63:0] d = 64'h0;
		bit [8*8-1 : 0] rdata = 64'h0;
		// k -> chip num
		for (k = 0; k < 8; k = k + 1) begin
			// offset = k * 8;
			offset = k*8;
			for (int j = 0; j < 8; j = j + 1) begin
				d[8*j +: 8] = data[64*j+offset +: 8];
			end
			// this code can't compile, don't know why
			// rank0[k].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			// the code is bad, but can compile
			if (k == 0) rank0[0].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 1) rank0[1].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 2) rank0[2].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 3) rank0[3].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 4) rank0[4].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 5) rank0[5].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 6) rank0[6].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
			if (k == 7) rank0[7].r0_ddr4_model_top.u0_r0._storage.BurstWrite(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .data(d), .bl(8), .by_mode(8));
		
			// if (k == 0) rdata = rank0[0].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 1) rdata = rank0[1].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 2) rdata = rank0[2].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 3) rdata = rank0[3].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 4) rdata = rank0[4].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 5) rdata = rank0[5].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 6) rdata = rank0[6].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			// if (k == 7) rdata = rank0[7].r0_ddr4_model_top.u0_r0._storage.BurstRead(.rank(0), .bg(bg), .ba(ba), .row(row), .col(col), .bl(8), .by_mode(8));
			
		end
endfunction

initial begin
    string trace_file;
    string line;
	string log_file = "trace.log";
    int fd;
	int log_fd;
    bit [31:0] addr;
	// automatic logic [23:0] rdata;
    logic [`UI_DATA_WIDTH - 1 : 0] random_data;
    if (!$value$plusargs("trace_file=%s", trace_file)) begin
        trace_file = "./traces/cactusADM_0_rand100w.txt.simple";
    end
    $display("trace_file is %s, initializing data_memory~~~", trace_file);
    i_ddr_wrapper.u_axi_virtual_master.trace_file = trace_file;



	log_fd = $fopen(log_file, "w");
    if (log_fd) $display("File was opened successfully");
    else begin
        $error("File open failed");
        $finish;
    end
	i_ddr_wrapper.u_axi_virtual_master.log_fd = log_fd;
	i_ddr_wrapper.u_scoreboard.log_fd = log_fd;

    fd = $fopen(trace_file, "r");
    if (fd) $display("File %s was opened successfully", trace_file);
    else begin
        $error("File open failed");
        $finish;
    end

	wait(i_ddr_wrapper.training_done == 1'b1);
	#(200);
    while (!$feof(fd)) begin
        $fgets(line, fd);
        // addr = AXIaddr2MemAddr(line.substr(4, line.len() - 1).atohex());
        addr = line.substr(4, line.len() - 1).atohex() >> 6;
		// addr[1] = 1'b0;
        random_data = $urandom_range(0, {32{1'b1}});
        for (int i = 0; i < `UI_DATA_WIDTH / 32; i = i + 1) begin
            random_data[32 * i +: 32] = $urandom_range(0, {32{1'b1}});
        end
		// just a hack for chip 0 backdoor write
		for (int k = 0; k < 8; k = k + 1) begin
			random_data[64*k +: 8] = 8'h0;
		end
        i_ddr_wrapper.u_scoreboard.data_memory[addr] = random_data;
		assert(i_ddr_wrapper.u_scoreboard.data_memory[addr] == random_data) 
		// begin
			// $display("Data read fit with data write to chip");
		// end
		else begin
			$display("Error! \n data; write_data:%h; read_data:%h;", random_data, i_ddr_wrapper.u_scoreboard.data_memory[addr]);
            $error("data check false!");
			$finish;
		end
	memory_write(.row(addr[25:11]), .col({addr[10:4], 3'h0}), .ba(addr[3:2]), .bg(addr[1:0]), .data(random_data));
        //$display("Back Door write memory addr is group:%h, bank:%h, row:%h; col:%h; ", addr[1:0], addr[3:2], addr[25:11], {addr[10:4], 3'h0});

		// $display("rdata = %h", rdata);
	end
    $fclose(fd);
    #100;
end
`endif


endmodule
